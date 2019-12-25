
obj/user/faultio.debug：     文件格式 elf32-i386


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
  80002c:	e8 3e 00 00 00       	call   80006f <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>
#include <inc/x86.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 08             	sub    $0x8,%esp

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
  800039:	9c                   	pushf  
  80003a:	58                   	pop    %eax
        int x, r;
	int nsecs = 1;
	int secno = 0;
	int diskno = 1;

	if (read_eflags() & FL_IOPL_3)
  80003b:	f6 c4 30             	test   $0x30,%ah
  80003e:	75 1d                	jne    80005d <umain+0x2a>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800040:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  800045:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80004a:	ee                   	out    %al,(%dx)

	// this outb to select disk 1 should result in a general protection
	// fault, because user-level code shouldn't be able to use the io space.
	outb(0x1F6, 0xE0 | (1<<4));

        cprintf("%s: made it here --- bug\n");
  80004b:	83 ec 0c             	sub    $0xc,%esp
  80004e:	68 ee 1d 80 00       	push   $0x801dee
  800053:	e8 0c 01 00 00       	call   800164 <cprintf>
}
  800058:	83 c4 10             	add    $0x10,%esp
  80005b:	c9                   	leave  
  80005c:	c3                   	ret    
		cprintf("eflags wrong\n");
  80005d:	83 ec 0c             	sub    $0xc,%esp
  800060:	68 e0 1d 80 00       	push   $0x801de0
  800065:	e8 fa 00 00 00       	call   800164 <cprintf>
  80006a:	83 c4 10             	add    $0x10,%esp
  80006d:	eb d1                	jmp    800040 <umain+0xd>

0080006f <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80006f:	55                   	push   %ebp
  800070:	89 e5                	mov    %esp,%ebp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800077:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  80007a:	e8 bf 0a 00 00       	call   800b3e <sys_getenvid>
	thisenv = envs + ENVX(envid); 
  80007f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800084:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800087:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008c:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800091:	85 db                	test   %ebx,%ebx
  800093:	7e 07                	jle    80009c <libmain+0x2d>
		binaryname = argv[0];
  800095:	8b 06                	mov    (%esi),%eax
  800097:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80009c:	83 ec 08             	sub    $0x8,%esp
  80009f:	56                   	push   %esi
  8000a0:	53                   	push   %ebx
  8000a1:	e8 8d ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000a6:	e8 0a 00 00 00       	call   8000b5 <exit>
}
  8000ab:	83 c4 10             	add    $0x10,%esp
  8000ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000b1:	5b                   	pop    %ebx
  8000b2:	5e                   	pop    %esi
  8000b3:	5d                   	pop    %ebp
  8000b4:	c3                   	ret    

008000b5 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000bb:	e8 83 0e 00 00       	call   800f43 <close_all>
	sys_env_destroy(0);
  8000c0:	83 ec 0c             	sub    $0xc,%esp
  8000c3:	6a 00                	push   $0x0
  8000c5:	e8 33 0a 00 00       	call   800afd <sys_env_destroy>
}
  8000ca:	83 c4 10             	add    $0x10,%esp
  8000cd:	c9                   	leave  
  8000ce:	c3                   	ret    

008000cf <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000cf:	55                   	push   %ebp
  8000d0:	89 e5                	mov    %esp,%ebp
  8000d2:	53                   	push   %ebx
  8000d3:	83 ec 04             	sub    $0x4,%esp
  8000d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000d9:	8b 13                	mov    (%ebx),%edx
  8000db:	8d 42 01             	lea    0x1(%edx),%eax
  8000de:	89 03                	mov    %eax,(%ebx)
  8000e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000e3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000e7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000ec:	74 09                	je     8000f7 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000ee:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f5:	c9                   	leave  
  8000f6:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	68 ff 00 00 00       	push   $0xff
  8000ff:	8d 43 08             	lea    0x8(%ebx),%eax
  800102:	50                   	push   %eax
  800103:	e8 b8 09 00 00       	call   800ac0 <sys_cputs>
		b->idx = 0;
  800108:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80010e:	83 c4 10             	add    $0x10,%esp
  800111:	eb db                	jmp    8000ee <putch+0x1f>

00800113 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800113:	55                   	push   %ebp
  800114:	89 e5                	mov    %esp,%ebp
  800116:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80011c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800123:	00 00 00 
	b.cnt = 0;
  800126:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80012d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800130:	ff 75 0c             	pushl  0xc(%ebp)
  800133:	ff 75 08             	pushl  0x8(%ebp)
  800136:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80013c:	50                   	push   %eax
  80013d:	68 cf 00 80 00       	push   $0x8000cf
  800142:	e8 1a 01 00 00       	call   800261 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800147:	83 c4 08             	add    $0x8,%esp
  80014a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800150:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800156:	50                   	push   %eax
  800157:	e8 64 09 00 00       	call   800ac0 <sys_cputs>

	return b.cnt;
}
  80015c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800162:	c9                   	leave  
  800163:	c3                   	ret    

00800164 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80016a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80016d:	50                   	push   %eax
  80016e:	ff 75 08             	pushl  0x8(%ebp)
  800171:	e8 9d ff ff ff       	call   800113 <vcprintf>
	va_end(ap);

	return cnt;
}
  800176:	c9                   	leave  
  800177:	c3                   	ret    

00800178 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	57                   	push   %edi
  80017c:	56                   	push   %esi
  80017d:	53                   	push   %ebx
  80017e:	83 ec 1c             	sub    $0x1c,%esp
  800181:	89 c7                	mov    %eax,%edi
  800183:	89 d6                	mov    %edx,%esi
  800185:	8b 45 08             	mov    0x8(%ebp),%eax
  800188:	8b 55 0c             	mov    0xc(%ebp),%edx
  80018b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80018e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800191:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800194:	bb 00 00 00 00       	mov    $0x0,%ebx
  800199:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80019c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80019f:	39 d3                	cmp    %edx,%ebx
  8001a1:	72 05                	jb     8001a8 <printnum+0x30>
  8001a3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001a6:	77 7a                	ja     800222 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001a8:	83 ec 0c             	sub    $0xc,%esp
  8001ab:	ff 75 18             	pushl  0x18(%ebp)
  8001ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8001b1:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001b4:	53                   	push   %ebx
  8001b5:	ff 75 10             	pushl  0x10(%ebp)
  8001b8:	83 ec 08             	sub    $0x8,%esp
  8001bb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001be:	ff 75 e0             	pushl  -0x20(%ebp)
  8001c1:	ff 75 dc             	pushl  -0x24(%ebp)
  8001c4:	ff 75 d8             	pushl  -0x28(%ebp)
  8001c7:	e8 c4 19 00 00       	call   801b90 <__udivdi3>
  8001cc:	83 c4 18             	add    $0x18,%esp
  8001cf:	52                   	push   %edx
  8001d0:	50                   	push   %eax
  8001d1:	89 f2                	mov    %esi,%edx
  8001d3:	89 f8                	mov    %edi,%eax
  8001d5:	e8 9e ff ff ff       	call   800178 <printnum>
  8001da:	83 c4 20             	add    $0x20,%esp
  8001dd:	eb 13                	jmp    8001f2 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001df:	83 ec 08             	sub    $0x8,%esp
  8001e2:	56                   	push   %esi
  8001e3:	ff 75 18             	pushl  0x18(%ebp)
  8001e6:	ff d7                	call   *%edi
  8001e8:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001eb:	83 eb 01             	sub    $0x1,%ebx
  8001ee:	85 db                	test   %ebx,%ebx
  8001f0:	7f ed                	jg     8001df <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001f2:	83 ec 08             	sub    $0x8,%esp
  8001f5:	56                   	push   %esi
  8001f6:	83 ec 04             	sub    $0x4,%esp
  8001f9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001fc:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ff:	ff 75 dc             	pushl  -0x24(%ebp)
  800202:	ff 75 d8             	pushl  -0x28(%ebp)
  800205:	e8 a6 1a 00 00       	call   801cb0 <__umoddi3>
  80020a:	83 c4 14             	add    $0x14,%esp
  80020d:	0f be 80 12 1e 80 00 	movsbl 0x801e12(%eax),%eax
  800214:	50                   	push   %eax
  800215:	ff d7                	call   *%edi
}
  800217:	83 c4 10             	add    $0x10,%esp
  80021a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021d:	5b                   	pop    %ebx
  80021e:	5e                   	pop    %esi
  80021f:	5f                   	pop    %edi
  800220:	5d                   	pop    %ebp
  800221:	c3                   	ret    
  800222:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800225:	eb c4                	jmp    8001eb <printnum+0x73>

00800227 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800227:	55                   	push   %ebp
  800228:	89 e5                	mov    %esp,%ebp
  80022a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80022d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800231:	8b 10                	mov    (%eax),%edx
  800233:	3b 50 04             	cmp    0x4(%eax),%edx
  800236:	73 0a                	jae    800242 <sprintputch+0x1b>
		*b->buf++ = ch;
  800238:	8d 4a 01             	lea    0x1(%edx),%ecx
  80023b:	89 08                	mov    %ecx,(%eax)
  80023d:	8b 45 08             	mov    0x8(%ebp),%eax
  800240:	88 02                	mov    %al,(%edx)
}
  800242:	5d                   	pop    %ebp
  800243:	c3                   	ret    

00800244 <printfmt>:
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80024a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80024d:	50                   	push   %eax
  80024e:	ff 75 10             	pushl  0x10(%ebp)
  800251:	ff 75 0c             	pushl  0xc(%ebp)
  800254:	ff 75 08             	pushl  0x8(%ebp)
  800257:	e8 05 00 00 00       	call   800261 <vprintfmt>
}
  80025c:	83 c4 10             	add    $0x10,%esp
  80025f:	c9                   	leave  
  800260:	c3                   	ret    

00800261 <vprintfmt>:
{
  800261:	55                   	push   %ebp
  800262:	89 e5                	mov    %esp,%ebp
  800264:	57                   	push   %edi
  800265:	56                   	push   %esi
  800266:	53                   	push   %ebx
  800267:	83 ec 2c             	sub    $0x2c,%esp
  80026a:	8b 75 08             	mov    0x8(%ebp),%esi
  80026d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800270:	8b 7d 10             	mov    0x10(%ebp),%edi
  800273:	e9 c1 03 00 00       	jmp    800639 <vprintfmt+0x3d8>
		padc = ' ';
  800278:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  80027c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800283:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  80028a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800291:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800296:	8d 47 01             	lea    0x1(%edi),%eax
  800299:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80029c:	0f b6 17             	movzbl (%edi),%edx
  80029f:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002a2:	3c 55                	cmp    $0x55,%al
  8002a4:	0f 87 12 04 00 00    	ja     8006bc <vprintfmt+0x45b>
  8002aa:	0f b6 c0             	movzbl %al,%eax
  8002ad:	ff 24 85 60 1f 80 00 	jmp    *0x801f60(,%eax,4)
  8002b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002b7:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8002bb:	eb d9                	jmp    800296 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8002bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  8002c0:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002c4:	eb d0                	jmp    800296 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8002c6:	0f b6 d2             	movzbl %dl,%edx
  8002c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8002d1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002d4:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002d7:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002db:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002de:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002e1:	83 f9 09             	cmp    $0x9,%ecx
  8002e4:	77 55                	ja     80033b <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  8002e6:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8002e9:	eb e9                	jmp    8002d4 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  8002eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8002ee:	8b 00                	mov    (%eax),%eax
  8002f0:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8002f6:	8d 40 04             	lea    0x4(%eax),%eax
  8002f9:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8002fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8002ff:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800303:	79 91                	jns    800296 <vprintfmt+0x35>
				width = precision, precision = -1;
  800305:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800308:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80030b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800312:	eb 82                	jmp    800296 <vprintfmt+0x35>
  800314:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800317:	85 c0                	test   %eax,%eax
  800319:	ba 00 00 00 00       	mov    $0x0,%edx
  80031e:	0f 49 d0             	cmovns %eax,%edx
  800321:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800324:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800327:	e9 6a ff ff ff       	jmp    800296 <vprintfmt+0x35>
  80032c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80032f:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800336:	e9 5b ff ff ff       	jmp    800296 <vprintfmt+0x35>
  80033b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80033e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800341:	eb bc                	jmp    8002ff <vprintfmt+0x9e>
			lflag++;
  800343:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800346:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800349:	e9 48 ff ff ff       	jmp    800296 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  80034e:	8b 45 14             	mov    0x14(%ebp),%eax
  800351:	8d 78 04             	lea    0x4(%eax),%edi
  800354:	83 ec 08             	sub    $0x8,%esp
  800357:	53                   	push   %ebx
  800358:	ff 30                	pushl  (%eax)
  80035a:	ff d6                	call   *%esi
			break;
  80035c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80035f:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800362:	e9 cf 02 00 00       	jmp    800636 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  800367:	8b 45 14             	mov    0x14(%ebp),%eax
  80036a:	8d 78 04             	lea    0x4(%eax),%edi
  80036d:	8b 00                	mov    (%eax),%eax
  80036f:	99                   	cltd   
  800370:	31 d0                	xor    %edx,%eax
  800372:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800374:	83 f8 0f             	cmp    $0xf,%eax
  800377:	7f 23                	jg     80039c <vprintfmt+0x13b>
  800379:	8b 14 85 c0 20 80 00 	mov    0x8020c0(,%eax,4),%edx
  800380:	85 d2                	test   %edx,%edx
  800382:	74 18                	je     80039c <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800384:	52                   	push   %edx
  800385:	68 f1 21 80 00       	push   $0x8021f1
  80038a:	53                   	push   %ebx
  80038b:	56                   	push   %esi
  80038c:	e8 b3 fe ff ff       	call   800244 <printfmt>
  800391:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800394:	89 7d 14             	mov    %edi,0x14(%ebp)
  800397:	e9 9a 02 00 00       	jmp    800636 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  80039c:	50                   	push   %eax
  80039d:	68 2a 1e 80 00       	push   $0x801e2a
  8003a2:	53                   	push   %ebx
  8003a3:	56                   	push   %esi
  8003a4:	e8 9b fe ff ff       	call   800244 <printfmt>
  8003a9:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003ac:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003af:	e9 82 02 00 00       	jmp    800636 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  8003b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b7:	83 c0 04             	add    $0x4,%eax
  8003ba:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c0:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003c2:	85 ff                	test   %edi,%edi
  8003c4:	b8 23 1e 80 00       	mov    $0x801e23,%eax
  8003c9:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8003cc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003d0:	0f 8e bd 00 00 00    	jle    800493 <vprintfmt+0x232>
  8003d6:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8003da:	75 0e                	jne    8003ea <vprintfmt+0x189>
  8003dc:	89 75 08             	mov    %esi,0x8(%ebp)
  8003df:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8003e2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8003e5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8003e8:	eb 6d                	jmp    800457 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003ea:	83 ec 08             	sub    $0x8,%esp
  8003ed:	ff 75 d0             	pushl  -0x30(%ebp)
  8003f0:	57                   	push   %edi
  8003f1:	e8 6e 03 00 00       	call   800764 <strnlen>
  8003f6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003f9:	29 c1                	sub    %eax,%ecx
  8003fb:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8003fe:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800401:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800405:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800408:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80040b:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  80040d:	eb 0f                	jmp    80041e <vprintfmt+0x1bd>
					putch(padc, putdat);
  80040f:	83 ec 08             	sub    $0x8,%esp
  800412:	53                   	push   %ebx
  800413:	ff 75 e0             	pushl  -0x20(%ebp)
  800416:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800418:	83 ef 01             	sub    $0x1,%edi
  80041b:	83 c4 10             	add    $0x10,%esp
  80041e:	85 ff                	test   %edi,%edi
  800420:	7f ed                	jg     80040f <vprintfmt+0x1ae>
  800422:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800425:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800428:	85 c9                	test   %ecx,%ecx
  80042a:	b8 00 00 00 00       	mov    $0x0,%eax
  80042f:	0f 49 c1             	cmovns %ecx,%eax
  800432:	29 c1                	sub    %eax,%ecx
  800434:	89 75 08             	mov    %esi,0x8(%ebp)
  800437:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80043a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80043d:	89 cb                	mov    %ecx,%ebx
  80043f:	eb 16                	jmp    800457 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  800441:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800445:	75 31                	jne    800478 <vprintfmt+0x217>
					putch(ch, putdat);
  800447:	83 ec 08             	sub    $0x8,%esp
  80044a:	ff 75 0c             	pushl  0xc(%ebp)
  80044d:	50                   	push   %eax
  80044e:	ff 55 08             	call   *0x8(%ebp)
  800451:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800454:	83 eb 01             	sub    $0x1,%ebx
  800457:	83 c7 01             	add    $0x1,%edi
  80045a:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  80045e:	0f be c2             	movsbl %dl,%eax
  800461:	85 c0                	test   %eax,%eax
  800463:	74 59                	je     8004be <vprintfmt+0x25d>
  800465:	85 f6                	test   %esi,%esi
  800467:	78 d8                	js     800441 <vprintfmt+0x1e0>
  800469:	83 ee 01             	sub    $0x1,%esi
  80046c:	79 d3                	jns    800441 <vprintfmt+0x1e0>
  80046e:	89 df                	mov    %ebx,%edi
  800470:	8b 75 08             	mov    0x8(%ebp),%esi
  800473:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800476:	eb 37                	jmp    8004af <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  800478:	0f be d2             	movsbl %dl,%edx
  80047b:	83 ea 20             	sub    $0x20,%edx
  80047e:	83 fa 5e             	cmp    $0x5e,%edx
  800481:	76 c4                	jbe    800447 <vprintfmt+0x1e6>
					putch('?', putdat);
  800483:	83 ec 08             	sub    $0x8,%esp
  800486:	ff 75 0c             	pushl  0xc(%ebp)
  800489:	6a 3f                	push   $0x3f
  80048b:	ff 55 08             	call   *0x8(%ebp)
  80048e:	83 c4 10             	add    $0x10,%esp
  800491:	eb c1                	jmp    800454 <vprintfmt+0x1f3>
  800493:	89 75 08             	mov    %esi,0x8(%ebp)
  800496:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800499:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80049c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80049f:	eb b6                	jmp    800457 <vprintfmt+0x1f6>
				putch(' ', putdat);
  8004a1:	83 ec 08             	sub    $0x8,%esp
  8004a4:	53                   	push   %ebx
  8004a5:	6a 20                	push   $0x20
  8004a7:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004a9:	83 ef 01             	sub    $0x1,%edi
  8004ac:	83 c4 10             	add    $0x10,%esp
  8004af:	85 ff                	test   %edi,%edi
  8004b1:	7f ee                	jg     8004a1 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  8004b3:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004b6:	89 45 14             	mov    %eax,0x14(%ebp)
  8004b9:	e9 78 01 00 00       	jmp    800636 <vprintfmt+0x3d5>
  8004be:	89 df                	mov    %ebx,%edi
  8004c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8004c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004c6:	eb e7                	jmp    8004af <vprintfmt+0x24e>
	if (lflag >= 2)
  8004c8:	83 f9 01             	cmp    $0x1,%ecx
  8004cb:	7e 3f                	jle    80050c <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  8004cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d0:	8b 50 04             	mov    0x4(%eax),%edx
  8004d3:	8b 00                	mov    (%eax),%eax
  8004d5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004d8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004db:	8b 45 14             	mov    0x14(%ebp),%eax
  8004de:	8d 40 08             	lea    0x8(%eax),%eax
  8004e1:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8004e4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004e8:	79 5c                	jns    800546 <vprintfmt+0x2e5>
				putch('-', putdat);
  8004ea:	83 ec 08             	sub    $0x8,%esp
  8004ed:	53                   	push   %ebx
  8004ee:	6a 2d                	push   $0x2d
  8004f0:	ff d6                	call   *%esi
				num = -(long long) num;
  8004f2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004f5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004f8:	f7 da                	neg    %edx
  8004fa:	83 d1 00             	adc    $0x0,%ecx
  8004fd:	f7 d9                	neg    %ecx
  8004ff:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800502:	b8 0a 00 00 00       	mov    $0xa,%eax
  800507:	e9 10 01 00 00       	jmp    80061c <vprintfmt+0x3bb>
	else if (lflag)
  80050c:	85 c9                	test   %ecx,%ecx
  80050e:	75 1b                	jne    80052b <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800510:	8b 45 14             	mov    0x14(%ebp),%eax
  800513:	8b 00                	mov    (%eax),%eax
  800515:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800518:	89 c1                	mov    %eax,%ecx
  80051a:	c1 f9 1f             	sar    $0x1f,%ecx
  80051d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800520:	8b 45 14             	mov    0x14(%ebp),%eax
  800523:	8d 40 04             	lea    0x4(%eax),%eax
  800526:	89 45 14             	mov    %eax,0x14(%ebp)
  800529:	eb b9                	jmp    8004e4 <vprintfmt+0x283>
		return va_arg(*ap, long);
  80052b:	8b 45 14             	mov    0x14(%ebp),%eax
  80052e:	8b 00                	mov    (%eax),%eax
  800530:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800533:	89 c1                	mov    %eax,%ecx
  800535:	c1 f9 1f             	sar    $0x1f,%ecx
  800538:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80053b:	8b 45 14             	mov    0x14(%ebp),%eax
  80053e:	8d 40 04             	lea    0x4(%eax),%eax
  800541:	89 45 14             	mov    %eax,0x14(%ebp)
  800544:	eb 9e                	jmp    8004e4 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  800546:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800549:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80054c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800551:	e9 c6 00 00 00       	jmp    80061c <vprintfmt+0x3bb>
	if (lflag >= 2)
  800556:	83 f9 01             	cmp    $0x1,%ecx
  800559:	7e 18                	jle    800573 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  80055b:	8b 45 14             	mov    0x14(%ebp),%eax
  80055e:	8b 10                	mov    (%eax),%edx
  800560:	8b 48 04             	mov    0x4(%eax),%ecx
  800563:	8d 40 08             	lea    0x8(%eax),%eax
  800566:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800569:	b8 0a 00 00 00       	mov    $0xa,%eax
  80056e:	e9 a9 00 00 00       	jmp    80061c <vprintfmt+0x3bb>
	else if (lflag)
  800573:	85 c9                	test   %ecx,%ecx
  800575:	75 1a                	jne    800591 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  800577:	8b 45 14             	mov    0x14(%ebp),%eax
  80057a:	8b 10                	mov    (%eax),%edx
  80057c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800581:	8d 40 04             	lea    0x4(%eax),%eax
  800584:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800587:	b8 0a 00 00 00       	mov    $0xa,%eax
  80058c:	e9 8b 00 00 00       	jmp    80061c <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800591:	8b 45 14             	mov    0x14(%ebp),%eax
  800594:	8b 10                	mov    (%eax),%edx
  800596:	b9 00 00 00 00       	mov    $0x0,%ecx
  80059b:	8d 40 04             	lea    0x4(%eax),%eax
  80059e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005a1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005a6:	eb 74                	jmp    80061c <vprintfmt+0x3bb>
	if (lflag >= 2)
  8005a8:	83 f9 01             	cmp    $0x1,%ecx
  8005ab:	7e 15                	jle    8005c2 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  8005ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b0:	8b 10                	mov    (%eax),%edx
  8005b2:	8b 48 04             	mov    0x4(%eax),%ecx
  8005b5:	8d 40 08             	lea    0x8(%eax),%eax
  8005b8:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005bb:	b8 08 00 00 00       	mov    $0x8,%eax
  8005c0:	eb 5a                	jmp    80061c <vprintfmt+0x3bb>
	else if (lflag)
  8005c2:	85 c9                	test   %ecx,%ecx
  8005c4:	75 17                	jne    8005dd <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  8005c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c9:	8b 10                	mov    (%eax),%edx
  8005cb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d0:	8d 40 04             	lea    0x4(%eax),%eax
  8005d3:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005d6:	b8 08 00 00 00       	mov    $0x8,%eax
  8005db:	eb 3f                	jmp    80061c <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8005dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e0:	8b 10                	mov    (%eax),%edx
  8005e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e7:	8d 40 04             	lea    0x4(%eax),%eax
  8005ea:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005ed:	b8 08 00 00 00       	mov    $0x8,%eax
  8005f2:	eb 28                	jmp    80061c <vprintfmt+0x3bb>
			putch('0', putdat);
  8005f4:	83 ec 08             	sub    $0x8,%esp
  8005f7:	53                   	push   %ebx
  8005f8:	6a 30                	push   $0x30
  8005fa:	ff d6                	call   *%esi
			putch('x', putdat);
  8005fc:	83 c4 08             	add    $0x8,%esp
  8005ff:	53                   	push   %ebx
  800600:	6a 78                	push   $0x78
  800602:	ff d6                	call   *%esi
			num = (unsigned long long)
  800604:	8b 45 14             	mov    0x14(%ebp),%eax
  800607:	8b 10                	mov    (%eax),%edx
  800609:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80060e:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800611:	8d 40 04             	lea    0x4(%eax),%eax
  800614:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800617:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80061c:	83 ec 0c             	sub    $0xc,%esp
  80061f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800623:	57                   	push   %edi
  800624:	ff 75 e0             	pushl  -0x20(%ebp)
  800627:	50                   	push   %eax
  800628:	51                   	push   %ecx
  800629:	52                   	push   %edx
  80062a:	89 da                	mov    %ebx,%edx
  80062c:	89 f0                	mov    %esi,%eax
  80062e:	e8 45 fb ff ff       	call   800178 <printnum>
			break;
  800633:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800636:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800639:	83 c7 01             	add    $0x1,%edi
  80063c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800640:	83 f8 25             	cmp    $0x25,%eax
  800643:	0f 84 2f fc ff ff    	je     800278 <vprintfmt+0x17>
			if (ch == '\0')
  800649:	85 c0                	test   %eax,%eax
  80064b:	0f 84 8b 00 00 00    	je     8006dc <vprintfmt+0x47b>
			putch(ch, putdat);
  800651:	83 ec 08             	sub    $0x8,%esp
  800654:	53                   	push   %ebx
  800655:	50                   	push   %eax
  800656:	ff d6                	call   *%esi
  800658:	83 c4 10             	add    $0x10,%esp
  80065b:	eb dc                	jmp    800639 <vprintfmt+0x3d8>
	if (lflag >= 2)
  80065d:	83 f9 01             	cmp    $0x1,%ecx
  800660:	7e 15                	jle    800677 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  800662:	8b 45 14             	mov    0x14(%ebp),%eax
  800665:	8b 10                	mov    (%eax),%edx
  800667:	8b 48 04             	mov    0x4(%eax),%ecx
  80066a:	8d 40 08             	lea    0x8(%eax),%eax
  80066d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800670:	b8 10 00 00 00       	mov    $0x10,%eax
  800675:	eb a5                	jmp    80061c <vprintfmt+0x3bb>
	else if (lflag)
  800677:	85 c9                	test   %ecx,%ecx
  800679:	75 17                	jne    800692 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  80067b:	8b 45 14             	mov    0x14(%ebp),%eax
  80067e:	8b 10                	mov    (%eax),%edx
  800680:	b9 00 00 00 00       	mov    $0x0,%ecx
  800685:	8d 40 04             	lea    0x4(%eax),%eax
  800688:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80068b:	b8 10 00 00 00       	mov    $0x10,%eax
  800690:	eb 8a                	jmp    80061c <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800692:	8b 45 14             	mov    0x14(%ebp),%eax
  800695:	8b 10                	mov    (%eax),%edx
  800697:	b9 00 00 00 00       	mov    $0x0,%ecx
  80069c:	8d 40 04             	lea    0x4(%eax),%eax
  80069f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006a2:	b8 10 00 00 00       	mov    $0x10,%eax
  8006a7:	e9 70 ff ff ff       	jmp    80061c <vprintfmt+0x3bb>
			putch(ch, putdat);
  8006ac:	83 ec 08             	sub    $0x8,%esp
  8006af:	53                   	push   %ebx
  8006b0:	6a 25                	push   $0x25
  8006b2:	ff d6                	call   *%esi
			break;
  8006b4:	83 c4 10             	add    $0x10,%esp
  8006b7:	e9 7a ff ff ff       	jmp    800636 <vprintfmt+0x3d5>
			putch('%', putdat);
  8006bc:	83 ec 08             	sub    $0x8,%esp
  8006bf:	53                   	push   %ebx
  8006c0:	6a 25                	push   $0x25
  8006c2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006c4:	83 c4 10             	add    $0x10,%esp
  8006c7:	89 f8                	mov    %edi,%eax
  8006c9:	eb 03                	jmp    8006ce <vprintfmt+0x46d>
  8006cb:	83 e8 01             	sub    $0x1,%eax
  8006ce:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006d2:	75 f7                	jne    8006cb <vprintfmt+0x46a>
  8006d4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006d7:	e9 5a ff ff ff       	jmp    800636 <vprintfmt+0x3d5>
}
  8006dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006df:	5b                   	pop    %ebx
  8006e0:	5e                   	pop    %esi
  8006e1:	5f                   	pop    %edi
  8006e2:	5d                   	pop    %ebp
  8006e3:	c3                   	ret    

008006e4 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006e4:	55                   	push   %ebp
  8006e5:	89 e5                	mov    %esp,%ebp
  8006e7:	83 ec 18             	sub    $0x18,%esp
  8006ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ed:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006f3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006f7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800701:	85 c0                	test   %eax,%eax
  800703:	74 26                	je     80072b <vsnprintf+0x47>
  800705:	85 d2                	test   %edx,%edx
  800707:	7e 22                	jle    80072b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800709:	ff 75 14             	pushl  0x14(%ebp)
  80070c:	ff 75 10             	pushl  0x10(%ebp)
  80070f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800712:	50                   	push   %eax
  800713:	68 27 02 80 00       	push   $0x800227
  800718:	e8 44 fb ff ff       	call   800261 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80071d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800720:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800723:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800726:	83 c4 10             	add    $0x10,%esp
}
  800729:	c9                   	leave  
  80072a:	c3                   	ret    
		return -E_INVAL;
  80072b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800730:	eb f7                	jmp    800729 <vsnprintf+0x45>

00800732 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800732:	55                   	push   %ebp
  800733:	89 e5                	mov    %esp,%ebp
  800735:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800738:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80073b:	50                   	push   %eax
  80073c:	ff 75 10             	pushl  0x10(%ebp)
  80073f:	ff 75 0c             	pushl  0xc(%ebp)
  800742:	ff 75 08             	pushl  0x8(%ebp)
  800745:	e8 9a ff ff ff       	call   8006e4 <vsnprintf>
	va_end(ap);

	return rc;
}
  80074a:	c9                   	leave  
  80074b:	c3                   	ret    

0080074c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80074c:	55                   	push   %ebp
  80074d:	89 e5                	mov    %esp,%ebp
  80074f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800752:	b8 00 00 00 00       	mov    $0x0,%eax
  800757:	eb 03                	jmp    80075c <strlen+0x10>
		n++;
  800759:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80075c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800760:	75 f7                	jne    800759 <strlen+0xd>
	return n;
}
  800762:	5d                   	pop    %ebp
  800763:	c3                   	ret    

00800764 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800764:	55                   	push   %ebp
  800765:	89 e5                	mov    %esp,%ebp
  800767:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80076a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80076d:	b8 00 00 00 00       	mov    $0x0,%eax
  800772:	eb 03                	jmp    800777 <strnlen+0x13>
		n++;
  800774:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800777:	39 d0                	cmp    %edx,%eax
  800779:	74 06                	je     800781 <strnlen+0x1d>
  80077b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80077f:	75 f3                	jne    800774 <strnlen+0x10>
	return n;
}
  800781:	5d                   	pop    %ebp
  800782:	c3                   	ret    

00800783 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800783:	55                   	push   %ebp
  800784:	89 e5                	mov    %esp,%ebp
  800786:	53                   	push   %ebx
  800787:	8b 45 08             	mov    0x8(%ebp),%eax
  80078a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80078d:	89 c2                	mov    %eax,%edx
  80078f:	83 c1 01             	add    $0x1,%ecx
  800792:	83 c2 01             	add    $0x1,%edx
  800795:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800799:	88 5a ff             	mov    %bl,-0x1(%edx)
  80079c:	84 db                	test   %bl,%bl
  80079e:	75 ef                	jne    80078f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007a0:	5b                   	pop    %ebx
  8007a1:	5d                   	pop    %ebp
  8007a2:	c3                   	ret    

008007a3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007a3:	55                   	push   %ebp
  8007a4:	89 e5                	mov    %esp,%ebp
  8007a6:	53                   	push   %ebx
  8007a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007aa:	53                   	push   %ebx
  8007ab:	e8 9c ff ff ff       	call   80074c <strlen>
  8007b0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007b3:	ff 75 0c             	pushl  0xc(%ebp)
  8007b6:	01 d8                	add    %ebx,%eax
  8007b8:	50                   	push   %eax
  8007b9:	e8 c5 ff ff ff       	call   800783 <strcpy>
	return dst;
}
  8007be:	89 d8                	mov    %ebx,%eax
  8007c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c3:	c9                   	leave  
  8007c4:	c3                   	ret    

008007c5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007c5:	55                   	push   %ebp
  8007c6:	89 e5                	mov    %esp,%ebp
  8007c8:	56                   	push   %esi
  8007c9:	53                   	push   %ebx
  8007ca:	8b 75 08             	mov    0x8(%ebp),%esi
  8007cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d0:	89 f3                	mov    %esi,%ebx
  8007d2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d5:	89 f2                	mov    %esi,%edx
  8007d7:	eb 0f                	jmp    8007e8 <strncpy+0x23>
		*dst++ = *src;
  8007d9:	83 c2 01             	add    $0x1,%edx
  8007dc:	0f b6 01             	movzbl (%ecx),%eax
  8007df:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007e2:	80 39 01             	cmpb   $0x1,(%ecx)
  8007e5:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8007e8:	39 da                	cmp    %ebx,%edx
  8007ea:	75 ed                	jne    8007d9 <strncpy+0x14>
	}
	return ret;
}
  8007ec:	89 f0                	mov    %esi,%eax
  8007ee:	5b                   	pop    %ebx
  8007ef:	5e                   	pop    %esi
  8007f0:	5d                   	pop    %ebp
  8007f1:	c3                   	ret    

008007f2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	56                   	push   %esi
  8007f6:	53                   	push   %ebx
  8007f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8007fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007fd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800800:	89 f0                	mov    %esi,%eax
  800802:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800806:	85 c9                	test   %ecx,%ecx
  800808:	75 0b                	jne    800815 <strlcpy+0x23>
  80080a:	eb 17                	jmp    800823 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80080c:	83 c2 01             	add    $0x1,%edx
  80080f:	83 c0 01             	add    $0x1,%eax
  800812:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800815:	39 d8                	cmp    %ebx,%eax
  800817:	74 07                	je     800820 <strlcpy+0x2e>
  800819:	0f b6 0a             	movzbl (%edx),%ecx
  80081c:	84 c9                	test   %cl,%cl
  80081e:	75 ec                	jne    80080c <strlcpy+0x1a>
		*dst = '\0';
  800820:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800823:	29 f0                	sub    %esi,%eax
}
  800825:	5b                   	pop    %ebx
  800826:	5e                   	pop    %esi
  800827:	5d                   	pop    %ebp
  800828:	c3                   	ret    

00800829 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800829:	55                   	push   %ebp
  80082a:	89 e5                	mov    %esp,%ebp
  80082c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80082f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800832:	eb 06                	jmp    80083a <strcmp+0x11>
		p++, q++;
  800834:	83 c1 01             	add    $0x1,%ecx
  800837:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80083a:	0f b6 01             	movzbl (%ecx),%eax
  80083d:	84 c0                	test   %al,%al
  80083f:	74 04                	je     800845 <strcmp+0x1c>
  800841:	3a 02                	cmp    (%edx),%al
  800843:	74 ef                	je     800834 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800845:	0f b6 c0             	movzbl %al,%eax
  800848:	0f b6 12             	movzbl (%edx),%edx
  80084b:	29 d0                	sub    %edx,%eax
}
  80084d:	5d                   	pop    %ebp
  80084e:	c3                   	ret    

0080084f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	53                   	push   %ebx
  800853:	8b 45 08             	mov    0x8(%ebp),%eax
  800856:	8b 55 0c             	mov    0xc(%ebp),%edx
  800859:	89 c3                	mov    %eax,%ebx
  80085b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80085e:	eb 06                	jmp    800866 <strncmp+0x17>
		n--, p++, q++;
  800860:	83 c0 01             	add    $0x1,%eax
  800863:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800866:	39 d8                	cmp    %ebx,%eax
  800868:	74 16                	je     800880 <strncmp+0x31>
  80086a:	0f b6 08             	movzbl (%eax),%ecx
  80086d:	84 c9                	test   %cl,%cl
  80086f:	74 04                	je     800875 <strncmp+0x26>
  800871:	3a 0a                	cmp    (%edx),%cl
  800873:	74 eb                	je     800860 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800875:	0f b6 00             	movzbl (%eax),%eax
  800878:	0f b6 12             	movzbl (%edx),%edx
  80087b:	29 d0                	sub    %edx,%eax
}
  80087d:	5b                   	pop    %ebx
  80087e:	5d                   	pop    %ebp
  80087f:	c3                   	ret    
		return 0;
  800880:	b8 00 00 00 00       	mov    $0x0,%eax
  800885:	eb f6                	jmp    80087d <strncmp+0x2e>

00800887 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	8b 45 08             	mov    0x8(%ebp),%eax
  80088d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800891:	0f b6 10             	movzbl (%eax),%edx
  800894:	84 d2                	test   %dl,%dl
  800896:	74 09                	je     8008a1 <strchr+0x1a>
		if (*s == c)
  800898:	38 ca                	cmp    %cl,%dl
  80089a:	74 0a                	je     8008a6 <strchr+0x1f>
	for (; *s; s++)
  80089c:	83 c0 01             	add    $0x1,%eax
  80089f:	eb f0                	jmp    800891 <strchr+0xa>
			return (char *) s;
	return 0;
  8008a1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008a6:	5d                   	pop    %ebp
  8008a7:	c3                   	ret    

008008a8 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008a8:	55                   	push   %ebp
  8008a9:	89 e5                	mov    %esp,%ebp
  8008ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ae:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008b2:	eb 03                	jmp    8008b7 <strfind+0xf>
  8008b4:	83 c0 01             	add    $0x1,%eax
  8008b7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008ba:	38 ca                	cmp    %cl,%dl
  8008bc:	74 04                	je     8008c2 <strfind+0x1a>
  8008be:	84 d2                	test   %dl,%dl
  8008c0:	75 f2                	jne    8008b4 <strfind+0xc>
			break;
	return (char *) s;
}
  8008c2:	5d                   	pop    %ebp
  8008c3:	c3                   	ret    

008008c4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008c4:	55                   	push   %ebp
  8008c5:	89 e5                	mov    %esp,%ebp
  8008c7:	57                   	push   %edi
  8008c8:	56                   	push   %esi
  8008c9:	53                   	push   %ebx
  8008ca:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008cd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008d0:	85 c9                	test   %ecx,%ecx
  8008d2:	74 13                	je     8008e7 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008d4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008da:	75 05                	jne    8008e1 <memset+0x1d>
  8008dc:	f6 c1 03             	test   $0x3,%cl
  8008df:	74 0d                	je     8008ee <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e4:	fc                   	cld    
  8008e5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008e7:	89 f8                	mov    %edi,%eax
  8008e9:	5b                   	pop    %ebx
  8008ea:	5e                   	pop    %esi
  8008eb:	5f                   	pop    %edi
  8008ec:	5d                   	pop    %ebp
  8008ed:	c3                   	ret    
		c &= 0xFF;
  8008ee:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008f2:	89 d3                	mov    %edx,%ebx
  8008f4:	c1 e3 08             	shl    $0x8,%ebx
  8008f7:	89 d0                	mov    %edx,%eax
  8008f9:	c1 e0 18             	shl    $0x18,%eax
  8008fc:	89 d6                	mov    %edx,%esi
  8008fe:	c1 e6 10             	shl    $0x10,%esi
  800901:	09 f0                	or     %esi,%eax
  800903:	09 c2                	or     %eax,%edx
  800905:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800907:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80090a:	89 d0                	mov    %edx,%eax
  80090c:	fc                   	cld    
  80090d:	f3 ab                	rep stos %eax,%es:(%edi)
  80090f:	eb d6                	jmp    8008e7 <memset+0x23>

00800911 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
  800914:	57                   	push   %edi
  800915:	56                   	push   %esi
  800916:	8b 45 08             	mov    0x8(%ebp),%eax
  800919:	8b 75 0c             	mov    0xc(%ebp),%esi
  80091c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80091f:	39 c6                	cmp    %eax,%esi
  800921:	73 35                	jae    800958 <memmove+0x47>
  800923:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800926:	39 c2                	cmp    %eax,%edx
  800928:	76 2e                	jbe    800958 <memmove+0x47>
		s += n;
		d += n;
  80092a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80092d:	89 d6                	mov    %edx,%esi
  80092f:	09 fe                	or     %edi,%esi
  800931:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800937:	74 0c                	je     800945 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800939:	83 ef 01             	sub    $0x1,%edi
  80093c:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80093f:	fd                   	std    
  800940:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800942:	fc                   	cld    
  800943:	eb 21                	jmp    800966 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800945:	f6 c1 03             	test   $0x3,%cl
  800948:	75 ef                	jne    800939 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80094a:	83 ef 04             	sub    $0x4,%edi
  80094d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800950:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800953:	fd                   	std    
  800954:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800956:	eb ea                	jmp    800942 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800958:	89 f2                	mov    %esi,%edx
  80095a:	09 c2                	or     %eax,%edx
  80095c:	f6 c2 03             	test   $0x3,%dl
  80095f:	74 09                	je     80096a <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800961:	89 c7                	mov    %eax,%edi
  800963:	fc                   	cld    
  800964:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800966:	5e                   	pop    %esi
  800967:	5f                   	pop    %edi
  800968:	5d                   	pop    %ebp
  800969:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096a:	f6 c1 03             	test   $0x3,%cl
  80096d:	75 f2                	jne    800961 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80096f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800972:	89 c7                	mov    %eax,%edi
  800974:	fc                   	cld    
  800975:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800977:	eb ed                	jmp    800966 <memmove+0x55>

00800979 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800979:	55                   	push   %ebp
  80097a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80097c:	ff 75 10             	pushl  0x10(%ebp)
  80097f:	ff 75 0c             	pushl  0xc(%ebp)
  800982:	ff 75 08             	pushl  0x8(%ebp)
  800985:	e8 87 ff ff ff       	call   800911 <memmove>
}
  80098a:	c9                   	leave  
  80098b:	c3                   	ret    

0080098c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	56                   	push   %esi
  800990:	53                   	push   %ebx
  800991:	8b 45 08             	mov    0x8(%ebp),%eax
  800994:	8b 55 0c             	mov    0xc(%ebp),%edx
  800997:	89 c6                	mov    %eax,%esi
  800999:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80099c:	39 f0                	cmp    %esi,%eax
  80099e:	74 1c                	je     8009bc <memcmp+0x30>
		if (*s1 != *s2)
  8009a0:	0f b6 08             	movzbl (%eax),%ecx
  8009a3:	0f b6 1a             	movzbl (%edx),%ebx
  8009a6:	38 d9                	cmp    %bl,%cl
  8009a8:	75 08                	jne    8009b2 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009aa:	83 c0 01             	add    $0x1,%eax
  8009ad:	83 c2 01             	add    $0x1,%edx
  8009b0:	eb ea                	jmp    80099c <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8009b2:	0f b6 c1             	movzbl %cl,%eax
  8009b5:	0f b6 db             	movzbl %bl,%ebx
  8009b8:	29 d8                	sub    %ebx,%eax
  8009ba:	eb 05                	jmp    8009c1 <memcmp+0x35>
	}

	return 0;
  8009bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c1:	5b                   	pop    %ebx
  8009c2:	5e                   	pop    %esi
  8009c3:	5d                   	pop    %ebp
  8009c4:	c3                   	ret    

008009c5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
  8009c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009ce:	89 c2                	mov    %eax,%edx
  8009d0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009d3:	39 d0                	cmp    %edx,%eax
  8009d5:	73 09                	jae    8009e0 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d7:	38 08                	cmp    %cl,(%eax)
  8009d9:	74 05                	je     8009e0 <memfind+0x1b>
	for (; s < ends; s++)
  8009db:	83 c0 01             	add    $0x1,%eax
  8009de:	eb f3                	jmp    8009d3 <memfind+0xe>
			break;
	return (void *) s;
}
  8009e0:	5d                   	pop    %ebp
  8009e1:	c3                   	ret    

008009e2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009e2:	55                   	push   %ebp
  8009e3:	89 e5                	mov    %esp,%ebp
  8009e5:	57                   	push   %edi
  8009e6:	56                   	push   %esi
  8009e7:	53                   	push   %ebx
  8009e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ee:	eb 03                	jmp    8009f3 <strtol+0x11>
		s++;
  8009f0:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  8009f3:	0f b6 01             	movzbl (%ecx),%eax
  8009f6:	3c 20                	cmp    $0x20,%al
  8009f8:	74 f6                	je     8009f0 <strtol+0xe>
  8009fa:	3c 09                	cmp    $0x9,%al
  8009fc:	74 f2                	je     8009f0 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8009fe:	3c 2b                	cmp    $0x2b,%al
  800a00:	74 2e                	je     800a30 <strtol+0x4e>
	int neg = 0;
  800a02:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a07:	3c 2d                	cmp    $0x2d,%al
  800a09:	74 2f                	je     800a3a <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a0b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a11:	75 05                	jne    800a18 <strtol+0x36>
  800a13:	80 39 30             	cmpb   $0x30,(%ecx)
  800a16:	74 2c                	je     800a44 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a18:	85 db                	test   %ebx,%ebx
  800a1a:	75 0a                	jne    800a26 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a1c:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a21:	80 39 30             	cmpb   $0x30,(%ecx)
  800a24:	74 28                	je     800a4e <strtol+0x6c>
		base = 10;
  800a26:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a2e:	eb 50                	jmp    800a80 <strtol+0x9e>
		s++;
  800a30:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a33:	bf 00 00 00 00       	mov    $0x0,%edi
  800a38:	eb d1                	jmp    800a0b <strtol+0x29>
		s++, neg = 1;
  800a3a:	83 c1 01             	add    $0x1,%ecx
  800a3d:	bf 01 00 00 00       	mov    $0x1,%edi
  800a42:	eb c7                	jmp    800a0b <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a44:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a48:	74 0e                	je     800a58 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a4a:	85 db                	test   %ebx,%ebx
  800a4c:	75 d8                	jne    800a26 <strtol+0x44>
		s++, base = 8;
  800a4e:	83 c1 01             	add    $0x1,%ecx
  800a51:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a56:	eb ce                	jmp    800a26 <strtol+0x44>
		s += 2, base = 16;
  800a58:	83 c1 02             	add    $0x2,%ecx
  800a5b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a60:	eb c4                	jmp    800a26 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800a62:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a65:	89 f3                	mov    %esi,%ebx
  800a67:	80 fb 19             	cmp    $0x19,%bl
  800a6a:	77 29                	ja     800a95 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800a6c:	0f be d2             	movsbl %dl,%edx
  800a6f:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a72:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a75:	7d 30                	jge    800aa7 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800a77:	83 c1 01             	add    $0x1,%ecx
  800a7a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a7e:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a80:	0f b6 11             	movzbl (%ecx),%edx
  800a83:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a86:	89 f3                	mov    %esi,%ebx
  800a88:	80 fb 09             	cmp    $0x9,%bl
  800a8b:	77 d5                	ja     800a62 <strtol+0x80>
			dig = *s - '0';
  800a8d:	0f be d2             	movsbl %dl,%edx
  800a90:	83 ea 30             	sub    $0x30,%edx
  800a93:	eb dd                	jmp    800a72 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800a95:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a98:	89 f3                	mov    %esi,%ebx
  800a9a:	80 fb 19             	cmp    $0x19,%bl
  800a9d:	77 08                	ja     800aa7 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a9f:	0f be d2             	movsbl %dl,%edx
  800aa2:	83 ea 37             	sub    $0x37,%edx
  800aa5:	eb cb                	jmp    800a72 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800aa7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aab:	74 05                	je     800ab2 <strtol+0xd0>
		*endptr = (char *) s;
  800aad:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ab0:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ab2:	89 c2                	mov    %eax,%edx
  800ab4:	f7 da                	neg    %edx
  800ab6:	85 ff                	test   %edi,%edi
  800ab8:	0f 45 c2             	cmovne %edx,%eax
}
  800abb:	5b                   	pop    %ebx
  800abc:	5e                   	pop    %esi
  800abd:	5f                   	pop    %edi
  800abe:	5d                   	pop    %ebp
  800abf:	c3                   	ret    

00800ac0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ac0:	55                   	push   %ebp
  800ac1:	89 e5                	mov    %esp,%ebp
  800ac3:	57                   	push   %edi
  800ac4:	56                   	push   %esi
  800ac5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ac6:	b8 00 00 00 00       	mov    $0x0,%eax
  800acb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ace:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ad1:	89 c3                	mov    %eax,%ebx
  800ad3:	89 c7                	mov    %eax,%edi
  800ad5:	89 c6                	mov    %eax,%esi
  800ad7:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ad9:	5b                   	pop    %ebx
  800ada:	5e                   	pop    %esi
  800adb:	5f                   	pop    %edi
  800adc:	5d                   	pop    %ebp
  800add:	c3                   	ret    

00800ade <sys_cgetc>:

int
sys_cgetc(void)
{
  800ade:	55                   	push   %ebp
  800adf:	89 e5                	mov    %esp,%ebp
  800ae1:	57                   	push   %edi
  800ae2:	56                   	push   %esi
  800ae3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ae4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae9:	b8 01 00 00 00       	mov    $0x1,%eax
  800aee:	89 d1                	mov    %edx,%ecx
  800af0:	89 d3                	mov    %edx,%ebx
  800af2:	89 d7                	mov    %edx,%edi
  800af4:	89 d6                	mov    %edx,%esi
  800af6:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800af8:	5b                   	pop    %ebx
  800af9:	5e                   	pop    %esi
  800afa:	5f                   	pop    %edi
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	57                   	push   %edi
  800b01:	56                   	push   %esi
  800b02:	53                   	push   %ebx
  800b03:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b06:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b0e:	b8 03 00 00 00       	mov    $0x3,%eax
  800b13:	89 cb                	mov    %ecx,%ebx
  800b15:	89 cf                	mov    %ecx,%edi
  800b17:	89 ce                	mov    %ecx,%esi
  800b19:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b1b:	85 c0                	test   %eax,%eax
  800b1d:	7f 08                	jg     800b27 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b22:	5b                   	pop    %ebx
  800b23:	5e                   	pop    %esi
  800b24:	5f                   	pop    %edi
  800b25:	5d                   	pop    %ebp
  800b26:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b27:	83 ec 0c             	sub    $0xc,%esp
  800b2a:	50                   	push   %eax
  800b2b:	6a 03                	push   $0x3
  800b2d:	68 1f 21 80 00       	push   $0x80211f
  800b32:	6a 23                	push   $0x23
  800b34:	68 3c 21 80 00       	push   $0x80213c
  800b39:	e8 dd 0e 00 00       	call   801a1b <_panic>

00800b3e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
  800b41:	57                   	push   %edi
  800b42:	56                   	push   %esi
  800b43:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b44:	ba 00 00 00 00       	mov    $0x0,%edx
  800b49:	b8 02 00 00 00       	mov    $0x2,%eax
  800b4e:	89 d1                	mov    %edx,%ecx
  800b50:	89 d3                	mov    %edx,%ebx
  800b52:	89 d7                	mov    %edx,%edi
  800b54:	89 d6                	mov    %edx,%esi
  800b56:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b58:	5b                   	pop    %ebx
  800b59:	5e                   	pop    %esi
  800b5a:	5f                   	pop    %edi
  800b5b:	5d                   	pop    %ebp
  800b5c:	c3                   	ret    

00800b5d <sys_yield>:

void
sys_yield(void)
{
  800b5d:	55                   	push   %ebp
  800b5e:	89 e5                	mov    %esp,%ebp
  800b60:	57                   	push   %edi
  800b61:	56                   	push   %esi
  800b62:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b63:	ba 00 00 00 00       	mov    $0x0,%edx
  800b68:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b6d:	89 d1                	mov    %edx,%ecx
  800b6f:	89 d3                	mov    %edx,%ebx
  800b71:	89 d7                	mov    %edx,%edi
  800b73:	89 d6                	mov    %edx,%esi
  800b75:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b77:	5b                   	pop    %ebx
  800b78:	5e                   	pop    %esi
  800b79:	5f                   	pop    %edi
  800b7a:	5d                   	pop    %ebp
  800b7b:	c3                   	ret    

00800b7c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	57                   	push   %edi
  800b80:	56                   	push   %esi
  800b81:	53                   	push   %ebx
  800b82:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b85:	be 00 00 00 00       	mov    $0x0,%esi
  800b8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b90:	b8 04 00 00 00       	mov    $0x4,%eax
  800b95:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b98:	89 f7                	mov    %esi,%edi
  800b9a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b9c:	85 c0                	test   %eax,%eax
  800b9e:	7f 08                	jg     800ba8 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ba0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba3:	5b                   	pop    %ebx
  800ba4:	5e                   	pop    %esi
  800ba5:	5f                   	pop    %edi
  800ba6:	5d                   	pop    %ebp
  800ba7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba8:	83 ec 0c             	sub    $0xc,%esp
  800bab:	50                   	push   %eax
  800bac:	6a 04                	push   $0x4
  800bae:	68 1f 21 80 00       	push   $0x80211f
  800bb3:	6a 23                	push   $0x23
  800bb5:	68 3c 21 80 00       	push   $0x80213c
  800bba:	e8 5c 0e 00 00       	call   801a1b <_panic>

00800bbf <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bbf:	55                   	push   %ebp
  800bc0:	89 e5                	mov    %esp,%ebp
  800bc2:	57                   	push   %edi
  800bc3:	56                   	push   %esi
  800bc4:	53                   	push   %ebx
  800bc5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bce:	b8 05 00 00 00       	mov    $0x5,%eax
  800bd3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bd9:	8b 75 18             	mov    0x18(%ebp),%esi
  800bdc:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bde:	85 c0                	test   %eax,%eax
  800be0:	7f 08                	jg     800bea <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800be2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be5:	5b                   	pop    %ebx
  800be6:	5e                   	pop    %esi
  800be7:	5f                   	pop    %edi
  800be8:	5d                   	pop    %ebp
  800be9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bea:	83 ec 0c             	sub    $0xc,%esp
  800bed:	50                   	push   %eax
  800bee:	6a 05                	push   $0x5
  800bf0:	68 1f 21 80 00       	push   $0x80211f
  800bf5:	6a 23                	push   $0x23
  800bf7:	68 3c 21 80 00       	push   $0x80213c
  800bfc:	e8 1a 0e 00 00       	call   801a1b <_panic>

00800c01 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
  800c04:	57                   	push   %edi
  800c05:	56                   	push   %esi
  800c06:	53                   	push   %ebx
  800c07:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c0a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c15:	b8 06 00 00 00       	mov    $0x6,%eax
  800c1a:	89 df                	mov    %ebx,%edi
  800c1c:	89 de                	mov    %ebx,%esi
  800c1e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c20:	85 c0                	test   %eax,%eax
  800c22:	7f 08                	jg     800c2c <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c24:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c27:	5b                   	pop    %ebx
  800c28:	5e                   	pop    %esi
  800c29:	5f                   	pop    %edi
  800c2a:	5d                   	pop    %ebp
  800c2b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2c:	83 ec 0c             	sub    $0xc,%esp
  800c2f:	50                   	push   %eax
  800c30:	6a 06                	push   $0x6
  800c32:	68 1f 21 80 00       	push   $0x80211f
  800c37:	6a 23                	push   $0x23
  800c39:	68 3c 21 80 00       	push   $0x80213c
  800c3e:	e8 d8 0d 00 00       	call   801a1b <_panic>

00800c43 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	57                   	push   %edi
  800c47:	56                   	push   %esi
  800c48:	53                   	push   %ebx
  800c49:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c4c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c51:	8b 55 08             	mov    0x8(%ebp),%edx
  800c54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c57:	b8 08 00 00 00       	mov    $0x8,%eax
  800c5c:	89 df                	mov    %ebx,%edi
  800c5e:	89 de                	mov    %ebx,%esi
  800c60:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c62:	85 c0                	test   %eax,%eax
  800c64:	7f 08                	jg     800c6e <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c69:	5b                   	pop    %ebx
  800c6a:	5e                   	pop    %esi
  800c6b:	5f                   	pop    %edi
  800c6c:	5d                   	pop    %ebp
  800c6d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6e:	83 ec 0c             	sub    $0xc,%esp
  800c71:	50                   	push   %eax
  800c72:	6a 08                	push   $0x8
  800c74:	68 1f 21 80 00       	push   $0x80211f
  800c79:	6a 23                	push   $0x23
  800c7b:	68 3c 21 80 00       	push   $0x80213c
  800c80:	e8 96 0d 00 00       	call   801a1b <_panic>

00800c85 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c85:	55                   	push   %ebp
  800c86:	89 e5                	mov    %esp,%ebp
  800c88:	57                   	push   %edi
  800c89:	56                   	push   %esi
  800c8a:	53                   	push   %ebx
  800c8b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c8e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c93:	8b 55 08             	mov    0x8(%ebp),%edx
  800c96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c99:	b8 09 00 00 00       	mov    $0x9,%eax
  800c9e:	89 df                	mov    %ebx,%edi
  800ca0:	89 de                	mov    %ebx,%esi
  800ca2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ca4:	85 c0                	test   %eax,%eax
  800ca6:	7f 08                	jg     800cb0 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ca8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cab:	5b                   	pop    %ebx
  800cac:	5e                   	pop    %esi
  800cad:	5f                   	pop    %edi
  800cae:	5d                   	pop    %ebp
  800caf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb0:	83 ec 0c             	sub    $0xc,%esp
  800cb3:	50                   	push   %eax
  800cb4:	6a 09                	push   $0x9
  800cb6:	68 1f 21 80 00       	push   $0x80211f
  800cbb:	6a 23                	push   $0x23
  800cbd:	68 3c 21 80 00       	push   $0x80213c
  800cc2:	e8 54 0d 00 00       	call   801a1b <_panic>

00800cc7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cc7:	55                   	push   %ebp
  800cc8:	89 e5                	mov    %esp,%ebp
  800cca:	57                   	push   %edi
  800ccb:	56                   	push   %esi
  800ccc:	53                   	push   %ebx
  800ccd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cd0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ce0:	89 df                	mov    %ebx,%edi
  800ce2:	89 de                	mov    %ebx,%esi
  800ce4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ce6:	85 c0                	test   %eax,%eax
  800ce8:	7f 08                	jg     800cf2 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ced:	5b                   	pop    %ebx
  800cee:	5e                   	pop    %esi
  800cef:	5f                   	pop    %edi
  800cf0:	5d                   	pop    %ebp
  800cf1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf2:	83 ec 0c             	sub    $0xc,%esp
  800cf5:	50                   	push   %eax
  800cf6:	6a 0a                	push   $0xa
  800cf8:	68 1f 21 80 00       	push   $0x80211f
  800cfd:	6a 23                	push   $0x23
  800cff:	68 3c 21 80 00       	push   $0x80213c
  800d04:	e8 12 0d 00 00       	call   801a1b <_panic>

00800d09 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d09:	55                   	push   %ebp
  800d0a:	89 e5                	mov    %esp,%ebp
  800d0c:	57                   	push   %edi
  800d0d:	56                   	push   %esi
  800d0e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d15:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d1a:	be 00 00 00 00       	mov    $0x0,%esi
  800d1f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d22:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d25:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d27:	5b                   	pop    %ebx
  800d28:	5e                   	pop    %esi
  800d29:	5f                   	pop    %edi
  800d2a:	5d                   	pop    %ebp
  800d2b:	c3                   	ret    

00800d2c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d2c:	55                   	push   %ebp
  800d2d:	89 e5                	mov    %esp,%ebp
  800d2f:	57                   	push   %edi
  800d30:	56                   	push   %esi
  800d31:	53                   	push   %ebx
  800d32:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d35:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d42:	89 cb                	mov    %ecx,%ebx
  800d44:	89 cf                	mov    %ecx,%edi
  800d46:	89 ce                	mov    %ecx,%esi
  800d48:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d4a:	85 c0                	test   %eax,%eax
  800d4c:	7f 08                	jg     800d56 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d51:	5b                   	pop    %ebx
  800d52:	5e                   	pop    %esi
  800d53:	5f                   	pop    %edi
  800d54:	5d                   	pop    %ebp
  800d55:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d56:	83 ec 0c             	sub    $0xc,%esp
  800d59:	50                   	push   %eax
  800d5a:	6a 0d                	push   $0xd
  800d5c:	68 1f 21 80 00       	push   $0x80211f
  800d61:	6a 23                	push   $0x23
  800d63:	68 3c 21 80 00       	push   $0x80213c
  800d68:	e8 ae 0c 00 00       	call   801a1b <_panic>

00800d6d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d6d:	55                   	push   %ebp
  800d6e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d70:	8b 45 08             	mov    0x8(%ebp),%eax
  800d73:	05 00 00 00 30       	add    $0x30000000,%eax
  800d78:	c1 e8 0c             	shr    $0xc,%eax
}
  800d7b:	5d                   	pop    %ebp
  800d7c:	c3                   	ret    

00800d7d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d7d:	55                   	push   %ebp
  800d7e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d80:	8b 45 08             	mov    0x8(%ebp),%eax
  800d83:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800d88:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d8d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d92:	5d                   	pop    %ebp
  800d93:	c3                   	ret    

00800d94 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d94:	55                   	push   %ebp
  800d95:	89 e5                	mov    %esp,%ebp
  800d97:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d9a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d9f:	89 c2                	mov    %eax,%edx
  800da1:	c1 ea 16             	shr    $0x16,%edx
  800da4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dab:	f6 c2 01             	test   $0x1,%dl
  800dae:	74 2a                	je     800dda <fd_alloc+0x46>
  800db0:	89 c2                	mov    %eax,%edx
  800db2:	c1 ea 0c             	shr    $0xc,%edx
  800db5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dbc:	f6 c2 01             	test   $0x1,%dl
  800dbf:	74 19                	je     800dda <fd_alloc+0x46>
  800dc1:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800dc6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800dcb:	75 d2                	jne    800d9f <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800dcd:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800dd3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800dd8:	eb 07                	jmp    800de1 <fd_alloc+0x4d>
			*fd_store = fd;
  800dda:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ddc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800de1:	5d                   	pop    %ebp
  800de2:	c3                   	ret    

00800de3 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800de3:	55                   	push   %ebp
  800de4:	89 e5                	mov    %esp,%ebp
  800de6:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800de9:	83 f8 1f             	cmp    $0x1f,%eax
  800dec:	77 36                	ja     800e24 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800dee:	c1 e0 0c             	shl    $0xc,%eax
  800df1:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800df6:	89 c2                	mov    %eax,%edx
  800df8:	c1 ea 16             	shr    $0x16,%edx
  800dfb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e02:	f6 c2 01             	test   $0x1,%dl
  800e05:	74 24                	je     800e2b <fd_lookup+0x48>
  800e07:	89 c2                	mov    %eax,%edx
  800e09:	c1 ea 0c             	shr    $0xc,%edx
  800e0c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e13:	f6 c2 01             	test   $0x1,%dl
  800e16:	74 1a                	je     800e32 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e18:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e1b:	89 02                	mov    %eax,(%edx)
	return 0;
  800e1d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e22:	5d                   	pop    %ebp
  800e23:	c3                   	ret    
		return -E_INVAL;
  800e24:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e29:	eb f7                	jmp    800e22 <fd_lookup+0x3f>
		return -E_INVAL;
  800e2b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e30:	eb f0                	jmp    800e22 <fd_lookup+0x3f>
  800e32:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e37:	eb e9                	jmp    800e22 <fd_lookup+0x3f>

00800e39 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e39:	55                   	push   %ebp
  800e3a:	89 e5                	mov    %esp,%ebp
  800e3c:	83 ec 08             	sub    $0x8,%esp
  800e3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e42:	ba c8 21 80 00       	mov    $0x8021c8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e47:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800e4c:	39 08                	cmp    %ecx,(%eax)
  800e4e:	74 33                	je     800e83 <dev_lookup+0x4a>
  800e50:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800e53:	8b 02                	mov    (%edx),%eax
  800e55:	85 c0                	test   %eax,%eax
  800e57:	75 f3                	jne    800e4c <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e59:	a1 04 40 80 00       	mov    0x804004,%eax
  800e5e:	8b 40 48             	mov    0x48(%eax),%eax
  800e61:	83 ec 04             	sub    $0x4,%esp
  800e64:	51                   	push   %ecx
  800e65:	50                   	push   %eax
  800e66:	68 4c 21 80 00       	push   $0x80214c
  800e6b:	e8 f4 f2 ff ff       	call   800164 <cprintf>
	*dev = 0;
  800e70:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e73:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e79:	83 c4 10             	add    $0x10,%esp
  800e7c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e81:	c9                   	leave  
  800e82:	c3                   	ret    
			*dev = devtab[i];
  800e83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e86:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e88:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8d:	eb f2                	jmp    800e81 <dev_lookup+0x48>

00800e8f <fd_close>:
{
  800e8f:	55                   	push   %ebp
  800e90:	89 e5                	mov    %esp,%ebp
  800e92:	57                   	push   %edi
  800e93:	56                   	push   %esi
  800e94:	53                   	push   %ebx
  800e95:	83 ec 1c             	sub    $0x1c,%esp
  800e98:	8b 75 08             	mov    0x8(%ebp),%esi
  800e9b:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e9e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ea1:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ea2:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800ea8:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800eab:	50                   	push   %eax
  800eac:	e8 32 ff ff ff       	call   800de3 <fd_lookup>
  800eb1:	89 c3                	mov    %eax,%ebx
  800eb3:	83 c4 08             	add    $0x8,%esp
  800eb6:	85 c0                	test   %eax,%eax
  800eb8:	78 05                	js     800ebf <fd_close+0x30>
	    || fd != fd2)
  800eba:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800ebd:	74 16                	je     800ed5 <fd_close+0x46>
		return (must_exist ? r : 0);
  800ebf:	89 f8                	mov    %edi,%eax
  800ec1:	84 c0                	test   %al,%al
  800ec3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec8:	0f 44 d8             	cmove  %eax,%ebx
}
  800ecb:	89 d8                	mov    %ebx,%eax
  800ecd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ed0:	5b                   	pop    %ebx
  800ed1:	5e                   	pop    %esi
  800ed2:	5f                   	pop    %edi
  800ed3:	5d                   	pop    %ebp
  800ed4:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ed5:	83 ec 08             	sub    $0x8,%esp
  800ed8:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800edb:	50                   	push   %eax
  800edc:	ff 36                	pushl  (%esi)
  800ede:	e8 56 ff ff ff       	call   800e39 <dev_lookup>
  800ee3:	89 c3                	mov    %eax,%ebx
  800ee5:	83 c4 10             	add    $0x10,%esp
  800ee8:	85 c0                	test   %eax,%eax
  800eea:	78 15                	js     800f01 <fd_close+0x72>
		if (dev->dev_close)
  800eec:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800eef:	8b 40 10             	mov    0x10(%eax),%eax
  800ef2:	85 c0                	test   %eax,%eax
  800ef4:	74 1b                	je     800f11 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  800ef6:	83 ec 0c             	sub    $0xc,%esp
  800ef9:	56                   	push   %esi
  800efa:	ff d0                	call   *%eax
  800efc:	89 c3                	mov    %eax,%ebx
  800efe:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800f01:	83 ec 08             	sub    $0x8,%esp
  800f04:	56                   	push   %esi
  800f05:	6a 00                	push   $0x0
  800f07:	e8 f5 fc ff ff       	call   800c01 <sys_page_unmap>
	return r;
  800f0c:	83 c4 10             	add    $0x10,%esp
  800f0f:	eb ba                	jmp    800ecb <fd_close+0x3c>
			r = 0;
  800f11:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f16:	eb e9                	jmp    800f01 <fd_close+0x72>

00800f18 <close>:

int
close(int fdnum)
{
  800f18:	55                   	push   %ebp
  800f19:	89 e5                	mov    %esp,%ebp
  800f1b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f1e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f21:	50                   	push   %eax
  800f22:	ff 75 08             	pushl  0x8(%ebp)
  800f25:	e8 b9 fe ff ff       	call   800de3 <fd_lookup>
  800f2a:	83 c4 08             	add    $0x8,%esp
  800f2d:	85 c0                	test   %eax,%eax
  800f2f:	78 10                	js     800f41 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f31:	83 ec 08             	sub    $0x8,%esp
  800f34:	6a 01                	push   $0x1
  800f36:	ff 75 f4             	pushl  -0xc(%ebp)
  800f39:	e8 51 ff ff ff       	call   800e8f <fd_close>
  800f3e:	83 c4 10             	add    $0x10,%esp
}
  800f41:	c9                   	leave  
  800f42:	c3                   	ret    

00800f43 <close_all>:

void
close_all(void)
{
  800f43:	55                   	push   %ebp
  800f44:	89 e5                	mov    %esp,%ebp
  800f46:	53                   	push   %ebx
  800f47:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f4a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f4f:	83 ec 0c             	sub    $0xc,%esp
  800f52:	53                   	push   %ebx
  800f53:	e8 c0 ff ff ff       	call   800f18 <close>
	for (i = 0; i < MAXFD; i++)
  800f58:	83 c3 01             	add    $0x1,%ebx
  800f5b:	83 c4 10             	add    $0x10,%esp
  800f5e:	83 fb 20             	cmp    $0x20,%ebx
  800f61:	75 ec                	jne    800f4f <close_all+0xc>
}
  800f63:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f66:	c9                   	leave  
  800f67:	c3                   	ret    

00800f68 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f68:	55                   	push   %ebp
  800f69:	89 e5                	mov    %esp,%ebp
  800f6b:	57                   	push   %edi
  800f6c:	56                   	push   %esi
  800f6d:	53                   	push   %ebx
  800f6e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f71:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f74:	50                   	push   %eax
  800f75:	ff 75 08             	pushl  0x8(%ebp)
  800f78:	e8 66 fe ff ff       	call   800de3 <fd_lookup>
  800f7d:	89 c3                	mov    %eax,%ebx
  800f7f:	83 c4 08             	add    $0x8,%esp
  800f82:	85 c0                	test   %eax,%eax
  800f84:	0f 88 81 00 00 00    	js     80100b <dup+0xa3>
		return r;
	close(newfdnum);
  800f8a:	83 ec 0c             	sub    $0xc,%esp
  800f8d:	ff 75 0c             	pushl  0xc(%ebp)
  800f90:	e8 83 ff ff ff       	call   800f18 <close>

	newfd = INDEX2FD(newfdnum);
  800f95:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f98:	c1 e6 0c             	shl    $0xc,%esi
  800f9b:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800fa1:	83 c4 04             	add    $0x4,%esp
  800fa4:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fa7:	e8 d1 fd ff ff       	call   800d7d <fd2data>
  800fac:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800fae:	89 34 24             	mov    %esi,(%esp)
  800fb1:	e8 c7 fd ff ff       	call   800d7d <fd2data>
  800fb6:	83 c4 10             	add    $0x10,%esp
  800fb9:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fbb:	89 d8                	mov    %ebx,%eax
  800fbd:	c1 e8 16             	shr    $0x16,%eax
  800fc0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fc7:	a8 01                	test   $0x1,%al
  800fc9:	74 11                	je     800fdc <dup+0x74>
  800fcb:	89 d8                	mov    %ebx,%eax
  800fcd:	c1 e8 0c             	shr    $0xc,%eax
  800fd0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fd7:	f6 c2 01             	test   $0x1,%dl
  800fda:	75 39                	jne    801015 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fdc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fdf:	89 d0                	mov    %edx,%eax
  800fe1:	c1 e8 0c             	shr    $0xc,%eax
  800fe4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800feb:	83 ec 0c             	sub    $0xc,%esp
  800fee:	25 07 0e 00 00       	and    $0xe07,%eax
  800ff3:	50                   	push   %eax
  800ff4:	56                   	push   %esi
  800ff5:	6a 00                	push   $0x0
  800ff7:	52                   	push   %edx
  800ff8:	6a 00                	push   $0x0
  800ffa:	e8 c0 fb ff ff       	call   800bbf <sys_page_map>
  800fff:	89 c3                	mov    %eax,%ebx
  801001:	83 c4 20             	add    $0x20,%esp
  801004:	85 c0                	test   %eax,%eax
  801006:	78 31                	js     801039 <dup+0xd1>
		goto err;

	return newfdnum;
  801008:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80100b:	89 d8                	mov    %ebx,%eax
  80100d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801010:	5b                   	pop    %ebx
  801011:	5e                   	pop    %esi
  801012:	5f                   	pop    %edi
  801013:	5d                   	pop    %ebp
  801014:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801015:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80101c:	83 ec 0c             	sub    $0xc,%esp
  80101f:	25 07 0e 00 00       	and    $0xe07,%eax
  801024:	50                   	push   %eax
  801025:	57                   	push   %edi
  801026:	6a 00                	push   $0x0
  801028:	53                   	push   %ebx
  801029:	6a 00                	push   $0x0
  80102b:	e8 8f fb ff ff       	call   800bbf <sys_page_map>
  801030:	89 c3                	mov    %eax,%ebx
  801032:	83 c4 20             	add    $0x20,%esp
  801035:	85 c0                	test   %eax,%eax
  801037:	79 a3                	jns    800fdc <dup+0x74>
	sys_page_unmap(0, newfd);
  801039:	83 ec 08             	sub    $0x8,%esp
  80103c:	56                   	push   %esi
  80103d:	6a 00                	push   $0x0
  80103f:	e8 bd fb ff ff       	call   800c01 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801044:	83 c4 08             	add    $0x8,%esp
  801047:	57                   	push   %edi
  801048:	6a 00                	push   $0x0
  80104a:	e8 b2 fb ff ff       	call   800c01 <sys_page_unmap>
	return r;
  80104f:	83 c4 10             	add    $0x10,%esp
  801052:	eb b7                	jmp    80100b <dup+0xa3>

00801054 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801054:	55                   	push   %ebp
  801055:	89 e5                	mov    %esp,%ebp
  801057:	53                   	push   %ebx
  801058:	83 ec 14             	sub    $0x14,%esp
  80105b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80105e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801061:	50                   	push   %eax
  801062:	53                   	push   %ebx
  801063:	e8 7b fd ff ff       	call   800de3 <fd_lookup>
  801068:	83 c4 08             	add    $0x8,%esp
  80106b:	85 c0                	test   %eax,%eax
  80106d:	78 3f                	js     8010ae <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80106f:	83 ec 08             	sub    $0x8,%esp
  801072:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801075:	50                   	push   %eax
  801076:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801079:	ff 30                	pushl  (%eax)
  80107b:	e8 b9 fd ff ff       	call   800e39 <dev_lookup>
  801080:	83 c4 10             	add    $0x10,%esp
  801083:	85 c0                	test   %eax,%eax
  801085:	78 27                	js     8010ae <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801087:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80108a:	8b 42 08             	mov    0x8(%edx),%eax
  80108d:	83 e0 03             	and    $0x3,%eax
  801090:	83 f8 01             	cmp    $0x1,%eax
  801093:	74 1e                	je     8010b3 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801095:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801098:	8b 40 08             	mov    0x8(%eax),%eax
  80109b:	85 c0                	test   %eax,%eax
  80109d:	74 35                	je     8010d4 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80109f:	83 ec 04             	sub    $0x4,%esp
  8010a2:	ff 75 10             	pushl  0x10(%ebp)
  8010a5:	ff 75 0c             	pushl  0xc(%ebp)
  8010a8:	52                   	push   %edx
  8010a9:	ff d0                	call   *%eax
  8010ab:	83 c4 10             	add    $0x10,%esp
}
  8010ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010b1:	c9                   	leave  
  8010b2:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010b3:	a1 04 40 80 00       	mov    0x804004,%eax
  8010b8:	8b 40 48             	mov    0x48(%eax),%eax
  8010bb:	83 ec 04             	sub    $0x4,%esp
  8010be:	53                   	push   %ebx
  8010bf:	50                   	push   %eax
  8010c0:	68 8d 21 80 00       	push   $0x80218d
  8010c5:	e8 9a f0 ff ff       	call   800164 <cprintf>
		return -E_INVAL;
  8010ca:	83 c4 10             	add    $0x10,%esp
  8010cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010d2:	eb da                	jmp    8010ae <read+0x5a>
		return -E_NOT_SUPP;
  8010d4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8010d9:	eb d3                	jmp    8010ae <read+0x5a>

008010db <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010db:	55                   	push   %ebp
  8010dc:	89 e5                	mov    %esp,%ebp
  8010de:	57                   	push   %edi
  8010df:	56                   	push   %esi
  8010e0:	53                   	push   %ebx
  8010e1:	83 ec 0c             	sub    $0xc,%esp
  8010e4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010e7:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010ea:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010ef:	39 f3                	cmp    %esi,%ebx
  8010f1:	73 25                	jae    801118 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010f3:	83 ec 04             	sub    $0x4,%esp
  8010f6:	89 f0                	mov    %esi,%eax
  8010f8:	29 d8                	sub    %ebx,%eax
  8010fa:	50                   	push   %eax
  8010fb:	89 d8                	mov    %ebx,%eax
  8010fd:	03 45 0c             	add    0xc(%ebp),%eax
  801100:	50                   	push   %eax
  801101:	57                   	push   %edi
  801102:	e8 4d ff ff ff       	call   801054 <read>
		if (m < 0)
  801107:	83 c4 10             	add    $0x10,%esp
  80110a:	85 c0                	test   %eax,%eax
  80110c:	78 08                	js     801116 <readn+0x3b>
			return m;
		if (m == 0)
  80110e:	85 c0                	test   %eax,%eax
  801110:	74 06                	je     801118 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  801112:	01 c3                	add    %eax,%ebx
  801114:	eb d9                	jmp    8010ef <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801116:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801118:	89 d8                	mov    %ebx,%eax
  80111a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80111d:	5b                   	pop    %ebx
  80111e:	5e                   	pop    %esi
  80111f:	5f                   	pop    %edi
  801120:	5d                   	pop    %ebp
  801121:	c3                   	ret    

00801122 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801122:	55                   	push   %ebp
  801123:	89 e5                	mov    %esp,%ebp
  801125:	53                   	push   %ebx
  801126:	83 ec 14             	sub    $0x14,%esp
  801129:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80112c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80112f:	50                   	push   %eax
  801130:	53                   	push   %ebx
  801131:	e8 ad fc ff ff       	call   800de3 <fd_lookup>
  801136:	83 c4 08             	add    $0x8,%esp
  801139:	85 c0                	test   %eax,%eax
  80113b:	78 3a                	js     801177 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80113d:	83 ec 08             	sub    $0x8,%esp
  801140:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801143:	50                   	push   %eax
  801144:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801147:	ff 30                	pushl  (%eax)
  801149:	e8 eb fc ff ff       	call   800e39 <dev_lookup>
  80114e:	83 c4 10             	add    $0x10,%esp
  801151:	85 c0                	test   %eax,%eax
  801153:	78 22                	js     801177 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801155:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801158:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80115c:	74 1e                	je     80117c <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80115e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801161:	8b 52 0c             	mov    0xc(%edx),%edx
  801164:	85 d2                	test   %edx,%edx
  801166:	74 35                	je     80119d <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801168:	83 ec 04             	sub    $0x4,%esp
  80116b:	ff 75 10             	pushl  0x10(%ebp)
  80116e:	ff 75 0c             	pushl  0xc(%ebp)
  801171:	50                   	push   %eax
  801172:	ff d2                	call   *%edx
  801174:	83 c4 10             	add    $0x10,%esp
}
  801177:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80117a:	c9                   	leave  
  80117b:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80117c:	a1 04 40 80 00       	mov    0x804004,%eax
  801181:	8b 40 48             	mov    0x48(%eax),%eax
  801184:	83 ec 04             	sub    $0x4,%esp
  801187:	53                   	push   %ebx
  801188:	50                   	push   %eax
  801189:	68 a9 21 80 00       	push   $0x8021a9
  80118e:	e8 d1 ef ff ff       	call   800164 <cprintf>
		return -E_INVAL;
  801193:	83 c4 10             	add    $0x10,%esp
  801196:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80119b:	eb da                	jmp    801177 <write+0x55>
		return -E_NOT_SUPP;
  80119d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011a2:	eb d3                	jmp    801177 <write+0x55>

008011a4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8011a4:	55                   	push   %ebp
  8011a5:	89 e5                	mov    %esp,%ebp
  8011a7:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011aa:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011ad:	50                   	push   %eax
  8011ae:	ff 75 08             	pushl  0x8(%ebp)
  8011b1:	e8 2d fc ff ff       	call   800de3 <fd_lookup>
  8011b6:	83 c4 08             	add    $0x8,%esp
  8011b9:	85 c0                	test   %eax,%eax
  8011bb:	78 0e                	js     8011cb <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011c3:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011cb:	c9                   	leave  
  8011cc:	c3                   	ret    

008011cd <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011cd:	55                   	push   %ebp
  8011ce:	89 e5                	mov    %esp,%ebp
  8011d0:	53                   	push   %ebx
  8011d1:	83 ec 14             	sub    $0x14,%esp
  8011d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011d7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011da:	50                   	push   %eax
  8011db:	53                   	push   %ebx
  8011dc:	e8 02 fc ff ff       	call   800de3 <fd_lookup>
  8011e1:	83 c4 08             	add    $0x8,%esp
  8011e4:	85 c0                	test   %eax,%eax
  8011e6:	78 37                	js     80121f <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011e8:	83 ec 08             	sub    $0x8,%esp
  8011eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ee:	50                   	push   %eax
  8011ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011f2:	ff 30                	pushl  (%eax)
  8011f4:	e8 40 fc ff ff       	call   800e39 <dev_lookup>
  8011f9:	83 c4 10             	add    $0x10,%esp
  8011fc:	85 c0                	test   %eax,%eax
  8011fe:	78 1f                	js     80121f <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801200:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801203:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801207:	74 1b                	je     801224 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801209:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80120c:	8b 52 18             	mov    0x18(%edx),%edx
  80120f:	85 d2                	test   %edx,%edx
  801211:	74 32                	je     801245 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801213:	83 ec 08             	sub    $0x8,%esp
  801216:	ff 75 0c             	pushl  0xc(%ebp)
  801219:	50                   	push   %eax
  80121a:	ff d2                	call   *%edx
  80121c:	83 c4 10             	add    $0x10,%esp
}
  80121f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801222:	c9                   	leave  
  801223:	c3                   	ret    
			thisenv->env_id, fdnum);
  801224:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801229:	8b 40 48             	mov    0x48(%eax),%eax
  80122c:	83 ec 04             	sub    $0x4,%esp
  80122f:	53                   	push   %ebx
  801230:	50                   	push   %eax
  801231:	68 6c 21 80 00       	push   $0x80216c
  801236:	e8 29 ef ff ff       	call   800164 <cprintf>
		return -E_INVAL;
  80123b:	83 c4 10             	add    $0x10,%esp
  80123e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801243:	eb da                	jmp    80121f <ftruncate+0x52>
		return -E_NOT_SUPP;
  801245:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80124a:	eb d3                	jmp    80121f <ftruncate+0x52>

0080124c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80124c:	55                   	push   %ebp
  80124d:	89 e5                	mov    %esp,%ebp
  80124f:	53                   	push   %ebx
  801250:	83 ec 14             	sub    $0x14,%esp
  801253:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801256:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801259:	50                   	push   %eax
  80125a:	ff 75 08             	pushl  0x8(%ebp)
  80125d:	e8 81 fb ff ff       	call   800de3 <fd_lookup>
  801262:	83 c4 08             	add    $0x8,%esp
  801265:	85 c0                	test   %eax,%eax
  801267:	78 4b                	js     8012b4 <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801269:	83 ec 08             	sub    $0x8,%esp
  80126c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80126f:	50                   	push   %eax
  801270:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801273:	ff 30                	pushl  (%eax)
  801275:	e8 bf fb ff ff       	call   800e39 <dev_lookup>
  80127a:	83 c4 10             	add    $0x10,%esp
  80127d:	85 c0                	test   %eax,%eax
  80127f:	78 33                	js     8012b4 <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  801281:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801284:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801288:	74 2f                	je     8012b9 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80128a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80128d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801294:	00 00 00 
	stat->st_isdir = 0;
  801297:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80129e:	00 00 00 
	stat->st_dev = dev;
  8012a1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012a7:	83 ec 08             	sub    $0x8,%esp
  8012aa:	53                   	push   %ebx
  8012ab:	ff 75 f0             	pushl  -0x10(%ebp)
  8012ae:	ff 50 14             	call   *0x14(%eax)
  8012b1:	83 c4 10             	add    $0x10,%esp
}
  8012b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012b7:	c9                   	leave  
  8012b8:	c3                   	ret    
		return -E_NOT_SUPP;
  8012b9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012be:	eb f4                	jmp    8012b4 <fstat+0x68>

008012c0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012c0:	55                   	push   %ebp
  8012c1:	89 e5                	mov    %esp,%ebp
  8012c3:	56                   	push   %esi
  8012c4:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012c5:	83 ec 08             	sub    $0x8,%esp
  8012c8:	6a 00                	push   $0x0
  8012ca:	ff 75 08             	pushl  0x8(%ebp)
  8012cd:	e8 da 01 00 00       	call   8014ac <open>
  8012d2:	89 c3                	mov    %eax,%ebx
  8012d4:	83 c4 10             	add    $0x10,%esp
  8012d7:	85 c0                	test   %eax,%eax
  8012d9:	78 1b                	js     8012f6 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012db:	83 ec 08             	sub    $0x8,%esp
  8012de:	ff 75 0c             	pushl  0xc(%ebp)
  8012e1:	50                   	push   %eax
  8012e2:	e8 65 ff ff ff       	call   80124c <fstat>
  8012e7:	89 c6                	mov    %eax,%esi
	close(fd);
  8012e9:	89 1c 24             	mov    %ebx,(%esp)
  8012ec:	e8 27 fc ff ff       	call   800f18 <close>
	return r;
  8012f1:	83 c4 10             	add    $0x10,%esp
  8012f4:	89 f3                	mov    %esi,%ebx
}
  8012f6:	89 d8                	mov    %ebx,%eax
  8012f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012fb:	5b                   	pop    %ebx
  8012fc:	5e                   	pop    %esi
  8012fd:	5d                   	pop    %ebp
  8012fe:	c3                   	ret    

008012ff <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012ff:	55                   	push   %ebp
  801300:	89 e5                	mov    %esp,%ebp
  801302:	56                   	push   %esi
  801303:	53                   	push   %ebx
  801304:	89 c6                	mov    %eax,%esi
  801306:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801308:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80130f:	74 27                	je     801338 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801311:	6a 07                	push   $0x7
  801313:	68 00 50 80 00       	push   $0x805000
  801318:	56                   	push   %esi
  801319:	ff 35 00 40 80 00    	pushl  0x804000
  80131f:	e8 a4 07 00 00       	call   801ac8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801324:	83 c4 0c             	add    $0xc,%esp
  801327:	6a 00                	push   $0x0
  801329:	53                   	push   %ebx
  80132a:	6a 00                	push   $0x0
  80132c:	e8 30 07 00 00       	call   801a61 <ipc_recv>
}
  801331:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801334:	5b                   	pop    %ebx
  801335:	5e                   	pop    %esi
  801336:	5d                   	pop    %ebp
  801337:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801338:	83 ec 0c             	sub    $0xc,%esp
  80133b:	6a 01                	push   $0x1
  80133d:	e8 da 07 00 00       	call   801b1c <ipc_find_env>
  801342:	a3 00 40 80 00       	mov    %eax,0x804000
  801347:	83 c4 10             	add    $0x10,%esp
  80134a:	eb c5                	jmp    801311 <fsipc+0x12>

0080134c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80134c:	55                   	push   %ebp
  80134d:	89 e5                	mov    %esp,%ebp
  80134f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801352:	8b 45 08             	mov    0x8(%ebp),%eax
  801355:	8b 40 0c             	mov    0xc(%eax),%eax
  801358:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80135d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801360:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801365:	ba 00 00 00 00       	mov    $0x0,%edx
  80136a:	b8 02 00 00 00       	mov    $0x2,%eax
  80136f:	e8 8b ff ff ff       	call   8012ff <fsipc>
}
  801374:	c9                   	leave  
  801375:	c3                   	ret    

00801376 <devfile_flush>:
{
  801376:	55                   	push   %ebp
  801377:	89 e5                	mov    %esp,%ebp
  801379:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80137c:	8b 45 08             	mov    0x8(%ebp),%eax
  80137f:	8b 40 0c             	mov    0xc(%eax),%eax
  801382:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801387:	ba 00 00 00 00       	mov    $0x0,%edx
  80138c:	b8 06 00 00 00       	mov    $0x6,%eax
  801391:	e8 69 ff ff ff       	call   8012ff <fsipc>
}
  801396:	c9                   	leave  
  801397:	c3                   	ret    

00801398 <devfile_stat>:
{
  801398:	55                   	push   %ebp
  801399:	89 e5                	mov    %esp,%ebp
  80139b:	53                   	push   %ebx
  80139c:	83 ec 04             	sub    $0x4,%esp
  80139f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a5:	8b 40 0c             	mov    0xc(%eax),%eax
  8013a8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8013b2:	b8 05 00 00 00       	mov    $0x5,%eax
  8013b7:	e8 43 ff ff ff       	call   8012ff <fsipc>
  8013bc:	85 c0                	test   %eax,%eax
  8013be:	78 2c                	js     8013ec <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013c0:	83 ec 08             	sub    $0x8,%esp
  8013c3:	68 00 50 80 00       	push   $0x805000
  8013c8:	53                   	push   %ebx
  8013c9:	e8 b5 f3 ff ff       	call   800783 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013ce:	a1 80 50 80 00       	mov    0x805080,%eax
  8013d3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013d9:	a1 84 50 80 00       	mov    0x805084,%eax
  8013de:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013e4:	83 c4 10             	add    $0x10,%esp
  8013e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ef:	c9                   	leave  
  8013f0:	c3                   	ret    

008013f1 <devfile_write>:
{
  8013f1:	55                   	push   %ebp
  8013f2:	89 e5                	mov    %esp,%ebp
  8013f4:	83 ec 0c             	sub    $0xc,%esp
  8013f7:	8b 45 10             	mov    0x10(%ebp),%eax
    	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8013fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8013fd:	8b 52 0c             	mov    0xc(%edx),%edx
  801400:	89 15 00 50 80 00    	mov    %edx,0x805000
    	fsipcbuf.write.req_n = n;
  801406:	a3 04 50 80 00       	mov    %eax,0x805004
    	memmove(fsipcbuf.write.req_buf, buf, n);
  80140b:	50                   	push   %eax
  80140c:	ff 75 0c             	pushl  0xc(%ebp)
  80140f:	68 08 50 80 00       	push   $0x805008
  801414:	e8 f8 f4 ff ff       	call   800911 <memmove>
    	return fsipc(FSREQ_WRITE, NULL);
  801419:	ba 00 00 00 00       	mov    $0x0,%edx
  80141e:	b8 04 00 00 00       	mov    $0x4,%eax
  801423:	e8 d7 fe ff ff       	call   8012ff <fsipc>
}
  801428:	c9                   	leave  
  801429:	c3                   	ret    

0080142a <devfile_read>:
{
  80142a:	55                   	push   %ebp
  80142b:	89 e5                	mov    %esp,%ebp
  80142d:	56                   	push   %esi
  80142e:	53                   	push   %ebx
  80142f:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801432:	8b 45 08             	mov    0x8(%ebp),%eax
  801435:	8b 40 0c             	mov    0xc(%eax),%eax
  801438:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80143d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801443:	ba 00 00 00 00       	mov    $0x0,%edx
  801448:	b8 03 00 00 00       	mov    $0x3,%eax
  80144d:	e8 ad fe ff ff       	call   8012ff <fsipc>
  801452:	89 c3                	mov    %eax,%ebx
  801454:	85 c0                	test   %eax,%eax
  801456:	78 1f                	js     801477 <devfile_read+0x4d>
	assert(r <= n);
  801458:	39 f0                	cmp    %esi,%eax
  80145a:	77 24                	ja     801480 <devfile_read+0x56>
	assert(r <= PGSIZE);
  80145c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801461:	7f 33                	jg     801496 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801463:	83 ec 04             	sub    $0x4,%esp
  801466:	50                   	push   %eax
  801467:	68 00 50 80 00       	push   $0x805000
  80146c:	ff 75 0c             	pushl  0xc(%ebp)
  80146f:	e8 9d f4 ff ff       	call   800911 <memmove>
	return r;
  801474:	83 c4 10             	add    $0x10,%esp
}
  801477:	89 d8                	mov    %ebx,%eax
  801479:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80147c:	5b                   	pop    %ebx
  80147d:	5e                   	pop    %esi
  80147e:	5d                   	pop    %ebp
  80147f:	c3                   	ret    
	assert(r <= n);
  801480:	68 d8 21 80 00       	push   $0x8021d8
  801485:	68 df 21 80 00       	push   $0x8021df
  80148a:	6a 7c                	push   $0x7c
  80148c:	68 f4 21 80 00       	push   $0x8021f4
  801491:	e8 85 05 00 00       	call   801a1b <_panic>
	assert(r <= PGSIZE);
  801496:	68 ff 21 80 00       	push   $0x8021ff
  80149b:	68 df 21 80 00       	push   $0x8021df
  8014a0:	6a 7d                	push   $0x7d
  8014a2:	68 f4 21 80 00       	push   $0x8021f4
  8014a7:	e8 6f 05 00 00       	call   801a1b <_panic>

008014ac <open>:
{
  8014ac:	55                   	push   %ebp
  8014ad:	89 e5                	mov    %esp,%ebp
  8014af:	56                   	push   %esi
  8014b0:	53                   	push   %ebx
  8014b1:	83 ec 1c             	sub    $0x1c,%esp
  8014b4:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8014b7:	56                   	push   %esi
  8014b8:	e8 8f f2 ff ff       	call   80074c <strlen>
  8014bd:	83 c4 10             	add    $0x10,%esp
  8014c0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014c5:	7f 6c                	jg     801533 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8014c7:	83 ec 0c             	sub    $0xc,%esp
  8014ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014cd:	50                   	push   %eax
  8014ce:	e8 c1 f8 ff ff       	call   800d94 <fd_alloc>
  8014d3:	89 c3                	mov    %eax,%ebx
  8014d5:	83 c4 10             	add    $0x10,%esp
  8014d8:	85 c0                	test   %eax,%eax
  8014da:	78 3c                	js     801518 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8014dc:	83 ec 08             	sub    $0x8,%esp
  8014df:	56                   	push   %esi
  8014e0:	68 00 50 80 00       	push   $0x805000
  8014e5:	e8 99 f2 ff ff       	call   800783 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014ed:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014f5:	b8 01 00 00 00       	mov    $0x1,%eax
  8014fa:	e8 00 fe ff ff       	call   8012ff <fsipc>
  8014ff:	89 c3                	mov    %eax,%ebx
  801501:	83 c4 10             	add    $0x10,%esp
  801504:	85 c0                	test   %eax,%eax
  801506:	78 19                	js     801521 <open+0x75>
	return fd2num(fd);
  801508:	83 ec 0c             	sub    $0xc,%esp
  80150b:	ff 75 f4             	pushl  -0xc(%ebp)
  80150e:	e8 5a f8 ff ff       	call   800d6d <fd2num>
  801513:	89 c3                	mov    %eax,%ebx
  801515:	83 c4 10             	add    $0x10,%esp
}
  801518:	89 d8                	mov    %ebx,%eax
  80151a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80151d:	5b                   	pop    %ebx
  80151e:	5e                   	pop    %esi
  80151f:	5d                   	pop    %ebp
  801520:	c3                   	ret    
		fd_close(fd, 0);
  801521:	83 ec 08             	sub    $0x8,%esp
  801524:	6a 00                	push   $0x0
  801526:	ff 75 f4             	pushl  -0xc(%ebp)
  801529:	e8 61 f9 ff ff       	call   800e8f <fd_close>
		return r;
  80152e:	83 c4 10             	add    $0x10,%esp
  801531:	eb e5                	jmp    801518 <open+0x6c>
		return -E_BAD_PATH;
  801533:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801538:	eb de                	jmp    801518 <open+0x6c>

0080153a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80153a:	55                   	push   %ebp
  80153b:	89 e5                	mov    %esp,%ebp
  80153d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801540:	ba 00 00 00 00       	mov    $0x0,%edx
  801545:	b8 08 00 00 00       	mov    $0x8,%eax
  80154a:	e8 b0 fd ff ff       	call   8012ff <fsipc>
}
  80154f:	c9                   	leave  
  801550:	c3                   	ret    

00801551 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801551:	55                   	push   %ebp
  801552:	89 e5                	mov    %esp,%ebp
  801554:	56                   	push   %esi
  801555:	53                   	push   %ebx
  801556:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801559:	83 ec 0c             	sub    $0xc,%esp
  80155c:	ff 75 08             	pushl  0x8(%ebp)
  80155f:	e8 19 f8 ff ff       	call   800d7d <fd2data>
  801564:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801566:	83 c4 08             	add    $0x8,%esp
  801569:	68 0b 22 80 00       	push   $0x80220b
  80156e:	53                   	push   %ebx
  80156f:	e8 0f f2 ff ff       	call   800783 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801574:	8b 46 04             	mov    0x4(%esi),%eax
  801577:	2b 06                	sub    (%esi),%eax
  801579:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80157f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801586:	00 00 00 
	stat->st_dev = &devpipe;
  801589:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801590:	30 80 00 
	return 0;
}
  801593:	b8 00 00 00 00       	mov    $0x0,%eax
  801598:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80159b:	5b                   	pop    %ebx
  80159c:	5e                   	pop    %esi
  80159d:	5d                   	pop    %ebp
  80159e:	c3                   	ret    

0080159f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80159f:	55                   	push   %ebp
  8015a0:	89 e5                	mov    %esp,%ebp
  8015a2:	53                   	push   %ebx
  8015a3:	83 ec 0c             	sub    $0xc,%esp
  8015a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8015a9:	53                   	push   %ebx
  8015aa:	6a 00                	push   $0x0
  8015ac:	e8 50 f6 ff ff       	call   800c01 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8015b1:	89 1c 24             	mov    %ebx,(%esp)
  8015b4:	e8 c4 f7 ff ff       	call   800d7d <fd2data>
  8015b9:	83 c4 08             	add    $0x8,%esp
  8015bc:	50                   	push   %eax
  8015bd:	6a 00                	push   $0x0
  8015bf:	e8 3d f6 ff ff       	call   800c01 <sys_page_unmap>
}
  8015c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c7:	c9                   	leave  
  8015c8:	c3                   	ret    

008015c9 <_pipeisclosed>:
{
  8015c9:	55                   	push   %ebp
  8015ca:	89 e5                	mov    %esp,%ebp
  8015cc:	57                   	push   %edi
  8015cd:	56                   	push   %esi
  8015ce:	53                   	push   %ebx
  8015cf:	83 ec 1c             	sub    $0x1c,%esp
  8015d2:	89 c7                	mov    %eax,%edi
  8015d4:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8015d6:	a1 04 40 80 00       	mov    0x804004,%eax
  8015db:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8015de:	83 ec 0c             	sub    $0xc,%esp
  8015e1:	57                   	push   %edi
  8015e2:	e8 6e 05 00 00       	call   801b55 <pageref>
  8015e7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8015ea:	89 34 24             	mov    %esi,(%esp)
  8015ed:	e8 63 05 00 00       	call   801b55 <pageref>
		nn = thisenv->env_runs;
  8015f2:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8015f8:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8015fb:	83 c4 10             	add    $0x10,%esp
  8015fe:	39 cb                	cmp    %ecx,%ebx
  801600:	74 1b                	je     80161d <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801602:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801605:	75 cf                	jne    8015d6 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801607:	8b 42 58             	mov    0x58(%edx),%eax
  80160a:	6a 01                	push   $0x1
  80160c:	50                   	push   %eax
  80160d:	53                   	push   %ebx
  80160e:	68 12 22 80 00       	push   $0x802212
  801613:	e8 4c eb ff ff       	call   800164 <cprintf>
  801618:	83 c4 10             	add    $0x10,%esp
  80161b:	eb b9                	jmp    8015d6 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  80161d:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801620:	0f 94 c0             	sete   %al
  801623:	0f b6 c0             	movzbl %al,%eax
}
  801626:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801629:	5b                   	pop    %ebx
  80162a:	5e                   	pop    %esi
  80162b:	5f                   	pop    %edi
  80162c:	5d                   	pop    %ebp
  80162d:	c3                   	ret    

0080162e <devpipe_write>:
{
  80162e:	55                   	push   %ebp
  80162f:	89 e5                	mov    %esp,%ebp
  801631:	57                   	push   %edi
  801632:	56                   	push   %esi
  801633:	53                   	push   %ebx
  801634:	83 ec 28             	sub    $0x28,%esp
  801637:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  80163a:	56                   	push   %esi
  80163b:	e8 3d f7 ff ff       	call   800d7d <fd2data>
  801640:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801642:	83 c4 10             	add    $0x10,%esp
  801645:	bf 00 00 00 00       	mov    $0x0,%edi
  80164a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80164d:	74 4f                	je     80169e <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80164f:	8b 43 04             	mov    0x4(%ebx),%eax
  801652:	8b 0b                	mov    (%ebx),%ecx
  801654:	8d 51 20             	lea    0x20(%ecx),%edx
  801657:	39 d0                	cmp    %edx,%eax
  801659:	72 14                	jb     80166f <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  80165b:	89 da                	mov    %ebx,%edx
  80165d:	89 f0                	mov    %esi,%eax
  80165f:	e8 65 ff ff ff       	call   8015c9 <_pipeisclosed>
  801664:	85 c0                	test   %eax,%eax
  801666:	75 3a                	jne    8016a2 <devpipe_write+0x74>
			sys_yield();
  801668:	e8 f0 f4 ff ff       	call   800b5d <sys_yield>
  80166d:	eb e0                	jmp    80164f <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80166f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801672:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801676:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801679:	89 c2                	mov    %eax,%edx
  80167b:	c1 fa 1f             	sar    $0x1f,%edx
  80167e:	89 d1                	mov    %edx,%ecx
  801680:	c1 e9 1b             	shr    $0x1b,%ecx
  801683:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801686:	83 e2 1f             	and    $0x1f,%edx
  801689:	29 ca                	sub    %ecx,%edx
  80168b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80168f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801693:	83 c0 01             	add    $0x1,%eax
  801696:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801699:	83 c7 01             	add    $0x1,%edi
  80169c:	eb ac                	jmp    80164a <devpipe_write+0x1c>
	return i;
  80169e:	89 f8                	mov    %edi,%eax
  8016a0:	eb 05                	jmp    8016a7 <devpipe_write+0x79>
				return 0;
  8016a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016aa:	5b                   	pop    %ebx
  8016ab:	5e                   	pop    %esi
  8016ac:	5f                   	pop    %edi
  8016ad:	5d                   	pop    %ebp
  8016ae:	c3                   	ret    

008016af <devpipe_read>:
{
  8016af:	55                   	push   %ebp
  8016b0:	89 e5                	mov    %esp,%ebp
  8016b2:	57                   	push   %edi
  8016b3:	56                   	push   %esi
  8016b4:	53                   	push   %ebx
  8016b5:	83 ec 18             	sub    $0x18,%esp
  8016b8:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8016bb:	57                   	push   %edi
  8016bc:	e8 bc f6 ff ff       	call   800d7d <fd2data>
  8016c1:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8016c3:	83 c4 10             	add    $0x10,%esp
  8016c6:	be 00 00 00 00       	mov    $0x0,%esi
  8016cb:	3b 75 10             	cmp    0x10(%ebp),%esi
  8016ce:	74 47                	je     801717 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  8016d0:	8b 03                	mov    (%ebx),%eax
  8016d2:	3b 43 04             	cmp    0x4(%ebx),%eax
  8016d5:	75 22                	jne    8016f9 <devpipe_read+0x4a>
			if (i > 0)
  8016d7:	85 f6                	test   %esi,%esi
  8016d9:	75 14                	jne    8016ef <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  8016db:	89 da                	mov    %ebx,%edx
  8016dd:	89 f8                	mov    %edi,%eax
  8016df:	e8 e5 fe ff ff       	call   8015c9 <_pipeisclosed>
  8016e4:	85 c0                	test   %eax,%eax
  8016e6:	75 33                	jne    80171b <devpipe_read+0x6c>
			sys_yield();
  8016e8:	e8 70 f4 ff ff       	call   800b5d <sys_yield>
  8016ed:	eb e1                	jmp    8016d0 <devpipe_read+0x21>
				return i;
  8016ef:	89 f0                	mov    %esi,%eax
}
  8016f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016f4:	5b                   	pop    %ebx
  8016f5:	5e                   	pop    %esi
  8016f6:	5f                   	pop    %edi
  8016f7:	5d                   	pop    %ebp
  8016f8:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016f9:	99                   	cltd   
  8016fa:	c1 ea 1b             	shr    $0x1b,%edx
  8016fd:	01 d0                	add    %edx,%eax
  8016ff:	83 e0 1f             	and    $0x1f,%eax
  801702:	29 d0                	sub    %edx,%eax
  801704:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801709:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80170c:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  80170f:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801712:	83 c6 01             	add    $0x1,%esi
  801715:	eb b4                	jmp    8016cb <devpipe_read+0x1c>
	return i;
  801717:	89 f0                	mov    %esi,%eax
  801719:	eb d6                	jmp    8016f1 <devpipe_read+0x42>
				return 0;
  80171b:	b8 00 00 00 00       	mov    $0x0,%eax
  801720:	eb cf                	jmp    8016f1 <devpipe_read+0x42>

00801722 <pipe>:
{
  801722:	55                   	push   %ebp
  801723:	89 e5                	mov    %esp,%ebp
  801725:	56                   	push   %esi
  801726:	53                   	push   %ebx
  801727:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  80172a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80172d:	50                   	push   %eax
  80172e:	e8 61 f6 ff ff       	call   800d94 <fd_alloc>
  801733:	89 c3                	mov    %eax,%ebx
  801735:	83 c4 10             	add    $0x10,%esp
  801738:	85 c0                	test   %eax,%eax
  80173a:	78 5b                	js     801797 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80173c:	83 ec 04             	sub    $0x4,%esp
  80173f:	68 07 04 00 00       	push   $0x407
  801744:	ff 75 f4             	pushl  -0xc(%ebp)
  801747:	6a 00                	push   $0x0
  801749:	e8 2e f4 ff ff       	call   800b7c <sys_page_alloc>
  80174e:	89 c3                	mov    %eax,%ebx
  801750:	83 c4 10             	add    $0x10,%esp
  801753:	85 c0                	test   %eax,%eax
  801755:	78 40                	js     801797 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  801757:	83 ec 0c             	sub    $0xc,%esp
  80175a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80175d:	50                   	push   %eax
  80175e:	e8 31 f6 ff ff       	call   800d94 <fd_alloc>
  801763:	89 c3                	mov    %eax,%ebx
  801765:	83 c4 10             	add    $0x10,%esp
  801768:	85 c0                	test   %eax,%eax
  80176a:	78 1b                	js     801787 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80176c:	83 ec 04             	sub    $0x4,%esp
  80176f:	68 07 04 00 00       	push   $0x407
  801774:	ff 75 f0             	pushl  -0x10(%ebp)
  801777:	6a 00                	push   $0x0
  801779:	e8 fe f3 ff ff       	call   800b7c <sys_page_alloc>
  80177e:	89 c3                	mov    %eax,%ebx
  801780:	83 c4 10             	add    $0x10,%esp
  801783:	85 c0                	test   %eax,%eax
  801785:	79 19                	jns    8017a0 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  801787:	83 ec 08             	sub    $0x8,%esp
  80178a:	ff 75 f4             	pushl  -0xc(%ebp)
  80178d:	6a 00                	push   $0x0
  80178f:	e8 6d f4 ff ff       	call   800c01 <sys_page_unmap>
  801794:	83 c4 10             	add    $0x10,%esp
}
  801797:	89 d8                	mov    %ebx,%eax
  801799:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80179c:	5b                   	pop    %ebx
  80179d:	5e                   	pop    %esi
  80179e:	5d                   	pop    %ebp
  80179f:	c3                   	ret    
	va = fd2data(fd0);
  8017a0:	83 ec 0c             	sub    $0xc,%esp
  8017a3:	ff 75 f4             	pushl  -0xc(%ebp)
  8017a6:	e8 d2 f5 ff ff       	call   800d7d <fd2data>
  8017ab:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017ad:	83 c4 0c             	add    $0xc,%esp
  8017b0:	68 07 04 00 00       	push   $0x407
  8017b5:	50                   	push   %eax
  8017b6:	6a 00                	push   $0x0
  8017b8:	e8 bf f3 ff ff       	call   800b7c <sys_page_alloc>
  8017bd:	89 c3                	mov    %eax,%ebx
  8017bf:	83 c4 10             	add    $0x10,%esp
  8017c2:	85 c0                	test   %eax,%eax
  8017c4:	0f 88 8c 00 00 00    	js     801856 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017ca:	83 ec 0c             	sub    $0xc,%esp
  8017cd:	ff 75 f0             	pushl  -0x10(%ebp)
  8017d0:	e8 a8 f5 ff ff       	call   800d7d <fd2data>
  8017d5:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8017dc:	50                   	push   %eax
  8017dd:	6a 00                	push   $0x0
  8017df:	56                   	push   %esi
  8017e0:	6a 00                	push   $0x0
  8017e2:	e8 d8 f3 ff ff       	call   800bbf <sys_page_map>
  8017e7:	89 c3                	mov    %eax,%ebx
  8017e9:	83 c4 20             	add    $0x20,%esp
  8017ec:	85 c0                	test   %eax,%eax
  8017ee:	78 58                	js     801848 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  8017f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017f3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017f9:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8017fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017fe:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801805:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801808:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80180e:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801810:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801813:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  80181a:	83 ec 0c             	sub    $0xc,%esp
  80181d:	ff 75 f4             	pushl  -0xc(%ebp)
  801820:	e8 48 f5 ff ff       	call   800d6d <fd2num>
  801825:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801828:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80182a:	83 c4 04             	add    $0x4,%esp
  80182d:	ff 75 f0             	pushl  -0x10(%ebp)
  801830:	e8 38 f5 ff ff       	call   800d6d <fd2num>
  801835:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801838:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80183b:	83 c4 10             	add    $0x10,%esp
  80183e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801843:	e9 4f ff ff ff       	jmp    801797 <pipe+0x75>
	sys_page_unmap(0, va);
  801848:	83 ec 08             	sub    $0x8,%esp
  80184b:	56                   	push   %esi
  80184c:	6a 00                	push   $0x0
  80184e:	e8 ae f3 ff ff       	call   800c01 <sys_page_unmap>
  801853:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801856:	83 ec 08             	sub    $0x8,%esp
  801859:	ff 75 f0             	pushl  -0x10(%ebp)
  80185c:	6a 00                	push   $0x0
  80185e:	e8 9e f3 ff ff       	call   800c01 <sys_page_unmap>
  801863:	83 c4 10             	add    $0x10,%esp
  801866:	e9 1c ff ff ff       	jmp    801787 <pipe+0x65>

0080186b <pipeisclosed>:
{
  80186b:	55                   	push   %ebp
  80186c:	89 e5                	mov    %esp,%ebp
  80186e:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801871:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801874:	50                   	push   %eax
  801875:	ff 75 08             	pushl  0x8(%ebp)
  801878:	e8 66 f5 ff ff       	call   800de3 <fd_lookup>
  80187d:	83 c4 10             	add    $0x10,%esp
  801880:	85 c0                	test   %eax,%eax
  801882:	78 18                	js     80189c <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801884:	83 ec 0c             	sub    $0xc,%esp
  801887:	ff 75 f4             	pushl  -0xc(%ebp)
  80188a:	e8 ee f4 ff ff       	call   800d7d <fd2data>
	return _pipeisclosed(fd, p);
  80188f:	89 c2                	mov    %eax,%edx
  801891:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801894:	e8 30 fd ff ff       	call   8015c9 <_pipeisclosed>
  801899:	83 c4 10             	add    $0x10,%esp
}
  80189c:	c9                   	leave  
  80189d:	c3                   	ret    

0080189e <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80189e:	55                   	push   %ebp
  80189f:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8018a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8018a6:	5d                   	pop    %ebp
  8018a7:	c3                   	ret    

008018a8 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8018a8:	55                   	push   %ebp
  8018a9:	89 e5                	mov    %esp,%ebp
  8018ab:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8018ae:	68 2a 22 80 00       	push   $0x80222a
  8018b3:	ff 75 0c             	pushl  0xc(%ebp)
  8018b6:	e8 c8 ee ff ff       	call   800783 <strcpy>
	return 0;
}
  8018bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8018c0:	c9                   	leave  
  8018c1:	c3                   	ret    

008018c2 <devcons_write>:
{
  8018c2:	55                   	push   %ebp
  8018c3:	89 e5                	mov    %esp,%ebp
  8018c5:	57                   	push   %edi
  8018c6:	56                   	push   %esi
  8018c7:	53                   	push   %ebx
  8018c8:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8018ce:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8018d3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8018d9:	eb 2f                	jmp    80190a <devcons_write+0x48>
		m = n - tot;
  8018db:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018de:	29 f3                	sub    %esi,%ebx
  8018e0:	83 fb 7f             	cmp    $0x7f,%ebx
  8018e3:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8018e8:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8018eb:	83 ec 04             	sub    $0x4,%esp
  8018ee:	53                   	push   %ebx
  8018ef:	89 f0                	mov    %esi,%eax
  8018f1:	03 45 0c             	add    0xc(%ebp),%eax
  8018f4:	50                   	push   %eax
  8018f5:	57                   	push   %edi
  8018f6:	e8 16 f0 ff ff       	call   800911 <memmove>
		sys_cputs(buf, m);
  8018fb:	83 c4 08             	add    $0x8,%esp
  8018fe:	53                   	push   %ebx
  8018ff:	57                   	push   %edi
  801900:	e8 bb f1 ff ff       	call   800ac0 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801905:	01 de                	add    %ebx,%esi
  801907:	83 c4 10             	add    $0x10,%esp
  80190a:	3b 75 10             	cmp    0x10(%ebp),%esi
  80190d:	72 cc                	jb     8018db <devcons_write+0x19>
}
  80190f:	89 f0                	mov    %esi,%eax
  801911:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801914:	5b                   	pop    %ebx
  801915:	5e                   	pop    %esi
  801916:	5f                   	pop    %edi
  801917:	5d                   	pop    %ebp
  801918:	c3                   	ret    

00801919 <devcons_read>:
{
  801919:	55                   	push   %ebp
  80191a:	89 e5                	mov    %esp,%ebp
  80191c:	83 ec 08             	sub    $0x8,%esp
  80191f:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801924:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801928:	75 07                	jne    801931 <devcons_read+0x18>
}
  80192a:	c9                   	leave  
  80192b:	c3                   	ret    
		sys_yield();
  80192c:	e8 2c f2 ff ff       	call   800b5d <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801931:	e8 a8 f1 ff ff       	call   800ade <sys_cgetc>
  801936:	85 c0                	test   %eax,%eax
  801938:	74 f2                	je     80192c <devcons_read+0x13>
	if (c < 0)
  80193a:	85 c0                	test   %eax,%eax
  80193c:	78 ec                	js     80192a <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  80193e:	83 f8 04             	cmp    $0x4,%eax
  801941:	74 0c                	je     80194f <devcons_read+0x36>
	*(char*)vbuf = c;
  801943:	8b 55 0c             	mov    0xc(%ebp),%edx
  801946:	88 02                	mov    %al,(%edx)
	return 1;
  801948:	b8 01 00 00 00       	mov    $0x1,%eax
  80194d:	eb db                	jmp    80192a <devcons_read+0x11>
		return 0;
  80194f:	b8 00 00 00 00       	mov    $0x0,%eax
  801954:	eb d4                	jmp    80192a <devcons_read+0x11>

00801956 <cputchar>:
{
  801956:	55                   	push   %ebp
  801957:	89 e5                	mov    %esp,%ebp
  801959:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80195c:	8b 45 08             	mov    0x8(%ebp),%eax
  80195f:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801962:	6a 01                	push   $0x1
  801964:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801967:	50                   	push   %eax
  801968:	e8 53 f1 ff ff       	call   800ac0 <sys_cputs>
}
  80196d:	83 c4 10             	add    $0x10,%esp
  801970:	c9                   	leave  
  801971:	c3                   	ret    

00801972 <getchar>:
{
  801972:	55                   	push   %ebp
  801973:	89 e5                	mov    %esp,%ebp
  801975:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801978:	6a 01                	push   $0x1
  80197a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80197d:	50                   	push   %eax
  80197e:	6a 00                	push   $0x0
  801980:	e8 cf f6 ff ff       	call   801054 <read>
	if (r < 0)
  801985:	83 c4 10             	add    $0x10,%esp
  801988:	85 c0                	test   %eax,%eax
  80198a:	78 08                	js     801994 <getchar+0x22>
	if (r < 1)
  80198c:	85 c0                	test   %eax,%eax
  80198e:	7e 06                	jle    801996 <getchar+0x24>
	return c;
  801990:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801994:	c9                   	leave  
  801995:	c3                   	ret    
		return -E_EOF;
  801996:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80199b:	eb f7                	jmp    801994 <getchar+0x22>

0080199d <iscons>:
{
  80199d:	55                   	push   %ebp
  80199e:	89 e5                	mov    %esp,%ebp
  8019a0:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019a6:	50                   	push   %eax
  8019a7:	ff 75 08             	pushl  0x8(%ebp)
  8019aa:	e8 34 f4 ff ff       	call   800de3 <fd_lookup>
  8019af:	83 c4 10             	add    $0x10,%esp
  8019b2:	85 c0                	test   %eax,%eax
  8019b4:	78 11                	js     8019c7 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  8019b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019b9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019bf:	39 10                	cmp    %edx,(%eax)
  8019c1:	0f 94 c0             	sete   %al
  8019c4:	0f b6 c0             	movzbl %al,%eax
}
  8019c7:	c9                   	leave  
  8019c8:	c3                   	ret    

008019c9 <opencons>:
{
  8019c9:	55                   	push   %ebp
  8019ca:	89 e5                	mov    %esp,%ebp
  8019cc:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8019cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019d2:	50                   	push   %eax
  8019d3:	e8 bc f3 ff ff       	call   800d94 <fd_alloc>
  8019d8:	83 c4 10             	add    $0x10,%esp
  8019db:	85 c0                	test   %eax,%eax
  8019dd:	78 3a                	js     801a19 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019df:	83 ec 04             	sub    $0x4,%esp
  8019e2:	68 07 04 00 00       	push   $0x407
  8019e7:	ff 75 f4             	pushl  -0xc(%ebp)
  8019ea:	6a 00                	push   $0x0
  8019ec:	e8 8b f1 ff ff       	call   800b7c <sys_page_alloc>
  8019f1:	83 c4 10             	add    $0x10,%esp
  8019f4:	85 c0                	test   %eax,%eax
  8019f6:	78 21                	js     801a19 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8019f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019fb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a01:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a06:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a0d:	83 ec 0c             	sub    $0xc,%esp
  801a10:	50                   	push   %eax
  801a11:	e8 57 f3 ff ff       	call   800d6d <fd2num>
  801a16:	83 c4 10             	add    $0x10,%esp
}
  801a19:	c9                   	leave  
  801a1a:	c3                   	ret    

00801a1b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a1b:	55                   	push   %ebp
  801a1c:	89 e5                	mov    %esp,%ebp
  801a1e:	56                   	push   %esi
  801a1f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a20:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a23:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a29:	e8 10 f1 ff ff       	call   800b3e <sys_getenvid>
  801a2e:	83 ec 0c             	sub    $0xc,%esp
  801a31:	ff 75 0c             	pushl  0xc(%ebp)
  801a34:	ff 75 08             	pushl  0x8(%ebp)
  801a37:	56                   	push   %esi
  801a38:	50                   	push   %eax
  801a39:	68 38 22 80 00       	push   $0x802238
  801a3e:	e8 21 e7 ff ff       	call   800164 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a43:	83 c4 18             	add    $0x18,%esp
  801a46:	53                   	push   %ebx
  801a47:	ff 75 10             	pushl  0x10(%ebp)
  801a4a:	e8 c4 e6 ff ff       	call   800113 <vcprintf>
	cprintf("\n");
  801a4f:	c7 04 24 23 22 80 00 	movl   $0x802223,(%esp)
  801a56:	e8 09 e7 ff ff       	call   800164 <cprintf>
  801a5b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a5e:	cc                   	int3   
  801a5f:	eb fd                	jmp    801a5e <_panic+0x43>

00801a61 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a61:	55                   	push   %ebp
  801a62:	89 e5                	mov    %esp,%ebp
  801a64:	56                   	push   %esi
  801a65:	53                   	push   %ebx
  801a66:	8b 75 08             	mov    0x8(%ebp),%esi
  801a69:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  801a6f:	85 f6                	test   %esi,%esi
  801a71:	74 06                	je     801a79 <ipc_recv+0x18>
  801a73:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801a79:	85 db                	test   %ebx,%ebx
  801a7b:	74 06                	je     801a83 <ipc_recv+0x22>
  801a7d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801a83:	85 c0                	test   %eax,%eax
  801a85:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801a8a:	0f 44 c2             	cmove  %edx,%eax
	int ret = sys_ipc_recv(pg);
  801a8d:	83 ec 0c             	sub    $0xc,%esp
  801a90:	50                   	push   %eax
  801a91:	e8 96 f2 ff ff       	call   800d2c <sys_ipc_recv>
	if (ret) return ret;
  801a96:	83 c4 10             	add    $0x10,%esp
  801a99:	85 c0                	test   %eax,%eax
  801a9b:	75 24                	jne    801ac1 <ipc_recv+0x60>
	if (from_env_store)
  801a9d:	85 f6                	test   %esi,%esi
  801a9f:	74 0a                	je     801aab <ipc_recv+0x4a>
		*from_env_store = thisenv->env_ipc_from;
  801aa1:	a1 04 40 80 00       	mov    0x804004,%eax
  801aa6:	8b 40 74             	mov    0x74(%eax),%eax
  801aa9:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801aab:	85 db                	test   %ebx,%ebx
  801aad:	74 0a                	je     801ab9 <ipc_recv+0x58>
		*perm_store = thisenv->env_ipc_perm;
  801aaf:	a1 04 40 80 00       	mov    0x804004,%eax
  801ab4:	8b 40 78             	mov    0x78(%eax),%eax
  801ab7:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801ab9:	a1 04 40 80 00       	mov    0x804004,%eax
  801abe:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ac1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ac4:	5b                   	pop    %ebx
  801ac5:	5e                   	pop    %esi
  801ac6:	5d                   	pop    %ebp
  801ac7:	c3                   	ret    

00801ac8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ac8:	55                   	push   %ebp
  801ac9:	89 e5                	mov    %esp,%ebp
  801acb:	57                   	push   %edi
  801acc:	56                   	push   %esi
  801acd:	53                   	push   %ebx
  801ace:	83 ec 0c             	sub    $0xc,%esp
  801ad1:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ad4:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ad7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  801ada:	85 db                	test   %ebx,%ebx
  801adc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801ae1:	0f 44 d8             	cmove  %eax,%ebx
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801ae4:	ff 75 14             	pushl  0x14(%ebp)
  801ae7:	53                   	push   %ebx
  801ae8:	56                   	push   %esi
  801ae9:	57                   	push   %edi
  801aea:	e8 1a f2 ff ff       	call   800d09 <sys_ipc_try_send>
  801aef:	83 c4 10             	add    $0x10,%esp
  801af2:	85 c0                	test   %eax,%eax
  801af4:	74 1e                	je     801b14 <ipc_send+0x4c>
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801af6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801af9:	75 07                	jne    801b02 <ipc_send+0x3a>
		sys_yield();
  801afb:	e8 5d f0 ff ff       	call   800b5d <sys_yield>
  801b00:	eb e2                	jmp    801ae4 <ipc_send+0x1c>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801b02:	50                   	push   %eax
  801b03:	68 5c 22 80 00       	push   $0x80225c
  801b08:	6a 36                	push   $0x36
  801b0a:	68 73 22 80 00       	push   $0x802273
  801b0f:	e8 07 ff ff ff       	call   801a1b <_panic>
	}
}
  801b14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b17:	5b                   	pop    %ebx
  801b18:	5e                   	pop    %esi
  801b19:	5f                   	pop    %edi
  801b1a:	5d                   	pop    %ebp
  801b1b:	c3                   	ret    

00801b1c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b1c:	55                   	push   %ebp
  801b1d:	89 e5                	mov    %esp,%ebp
  801b1f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b22:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b27:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b2a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b30:	8b 52 50             	mov    0x50(%edx),%edx
  801b33:	39 ca                	cmp    %ecx,%edx
  801b35:	74 11                	je     801b48 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801b37:	83 c0 01             	add    $0x1,%eax
  801b3a:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b3f:	75 e6                	jne    801b27 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801b41:	b8 00 00 00 00       	mov    $0x0,%eax
  801b46:	eb 0b                	jmp    801b53 <ipc_find_env+0x37>
			return envs[i].env_id;
  801b48:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b4b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b50:	8b 40 48             	mov    0x48(%eax),%eax
}
  801b53:	5d                   	pop    %ebp
  801b54:	c3                   	ret    

00801b55 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b55:	55                   	push   %ebp
  801b56:	89 e5                	mov    %esp,%ebp
  801b58:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b5b:	89 d0                	mov    %edx,%eax
  801b5d:	c1 e8 16             	shr    $0x16,%eax
  801b60:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b67:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801b6c:	f6 c1 01             	test   $0x1,%cl
  801b6f:	74 1d                	je     801b8e <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801b71:	c1 ea 0c             	shr    $0xc,%edx
  801b74:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b7b:	f6 c2 01             	test   $0x1,%dl
  801b7e:	74 0e                	je     801b8e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b80:	c1 ea 0c             	shr    $0xc,%edx
  801b83:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b8a:	ef 
  801b8b:	0f b7 c0             	movzwl %ax,%eax
}
  801b8e:	5d                   	pop    %ebp
  801b8f:	c3                   	ret    

00801b90 <__udivdi3>:
  801b90:	55                   	push   %ebp
  801b91:	57                   	push   %edi
  801b92:	56                   	push   %esi
  801b93:	53                   	push   %ebx
  801b94:	83 ec 1c             	sub    $0x1c,%esp
  801b97:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801b9b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801b9f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801ba3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801ba7:	85 d2                	test   %edx,%edx
  801ba9:	75 35                	jne    801be0 <__udivdi3+0x50>
  801bab:	39 f3                	cmp    %esi,%ebx
  801bad:	0f 87 bd 00 00 00    	ja     801c70 <__udivdi3+0xe0>
  801bb3:	85 db                	test   %ebx,%ebx
  801bb5:	89 d9                	mov    %ebx,%ecx
  801bb7:	75 0b                	jne    801bc4 <__udivdi3+0x34>
  801bb9:	b8 01 00 00 00       	mov    $0x1,%eax
  801bbe:	31 d2                	xor    %edx,%edx
  801bc0:	f7 f3                	div    %ebx
  801bc2:	89 c1                	mov    %eax,%ecx
  801bc4:	31 d2                	xor    %edx,%edx
  801bc6:	89 f0                	mov    %esi,%eax
  801bc8:	f7 f1                	div    %ecx
  801bca:	89 c6                	mov    %eax,%esi
  801bcc:	89 e8                	mov    %ebp,%eax
  801bce:	89 f7                	mov    %esi,%edi
  801bd0:	f7 f1                	div    %ecx
  801bd2:	89 fa                	mov    %edi,%edx
  801bd4:	83 c4 1c             	add    $0x1c,%esp
  801bd7:	5b                   	pop    %ebx
  801bd8:	5e                   	pop    %esi
  801bd9:	5f                   	pop    %edi
  801bda:	5d                   	pop    %ebp
  801bdb:	c3                   	ret    
  801bdc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801be0:	39 f2                	cmp    %esi,%edx
  801be2:	77 7c                	ja     801c60 <__udivdi3+0xd0>
  801be4:	0f bd fa             	bsr    %edx,%edi
  801be7:	83 f7 1f             	xor    $0x1f,%edi
  801bea:	0f 84 98 00 00 00    	je     801c88 <__udivdi3+0xf8>
  801bf0:	89 f9                	mov    %edi,%ecx
  801bf2:	b8 20 00 00 00       	mov    $0x20,%eax
  801bf7:	29 f8                	sub    %edi,%eax
  801bf9:	d3 e2                	shl    %cl,%edx
  801bfb:	89 54 24 08          	mov    %edx,0x8(%esp)
  801bff:	89 c1                	mov    %eax,%ecx
  801c01:	89 da                	mov    %ebx,%edx
  801c03:	d3 ea                	shr    %cl,%edx
  801c05:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801c09:	09 d1                	or     %edx,%ecx
  801c0b:	89 f2                	mov    %esi,%edx
  801c0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c11:	89 f9                	mov    %edi,%ecx
  801c13:	d3 e3                	shl    %cl,%ebx
  801c15:	89 c1                	mov    %eax,%ecx
  801c17:	d3 ea                	shr    %cl,%edx
  801c19:	89 f9                	mov    %edi,%ecx
  801c1b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c1f:	d3 e6                	shl    %cl,%esi
  801c21:	89 eb                	mov    %ebp,%ebx
  801c23:	89 c1                	mov    %eax,%ecx
  801c25:	d3 eb                	shr    %cl,%ebx
  801c27:	09 de                	or     %ebx,%esi
  801c29:	89 f0                	mov    %esi,%eax
  801c2b:	f7 74 24 08          	divl   0x8(%esp)
  801c2f:	89 d6                	mov    %edx,%esi
  801c31:	89 c3                	mov    %eax,%ebx
  801c33:	f7 64 24 0c          	mull   0xc(%esp)
  801c37:	39 d6                	cmp    %edx,%esi
  801c39:	72 0c                	jb     801c47 <__udivdi3+0xb7>
  801c3b:	89 f9                	mov    %edi,%ecx
  801c3d:	d3 e5                	shl    %cl,%ebp
  801c3f:	39 c5                	cmp    %eax,%ebp
  801c41:	73 5d                	jae    801ca0 <__udivdi3+0x110>
  801c43:	39 d6                	cmp    %edx,%esi
  801c45:	75 59                	jne    801ca0 <__udivdi3+0x110>
  801c47:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801c4a:	31 ff                	xor    %edi,%edi
  801c4c:	89 fa                	mov    %edi,%edx
  801c4e:	83 c4 1c             	add    $0x1c,%esp
  801c51:	5b                   	pop    %ebx
  801c52:	5e                   	pop    %esi
  801c53:	5f                   	pop    %edi
  801c54:	5d                   	pop    %ebp
  801c55:	c3                   	ret    
  801c56:	8d 76 00             	lea    0x0(%esi),%esi
  801c59:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801c60:	31 ff                	xor    %edi,%edi
  801c62:	31 c0                	xor    %eax,%eax
  801c64:	89 fa                	mov    %edi,%edx
  801c66:	83 c4 1c             	add    $0x1c,%esp
  801c69:	5b                   	pop    %ebx
  801c6a:	5e                   	pop    %esi
  801c6b:	5f                   	pop    %edi
  801c6c:	5d                   	pop    %ebp
  801c6d:	c3                   	ret    
  801c6e:	66 90                	xchg   %ax,%ax
  801c70:	31 ff                	xor    %edi,%edi
  801c72:	89 e8                	mov    %ebp,%eax
  801c74:	89 f2                	mov    %esi,%edx
  801c76:	f7 f3                	div    %ebx
  801c78:	89 fa                	mov    %edi,%edx
  801c7a:	83 c4 1c             	add    $0x1c,%esp
  801c7d:	5b                   	pop    %ebx
  801c7e:	5e                   	pop    %esi
  801c7f:	5f                   	pop    %edi
  801c80:	5d                   	pop    %ebp
  801c81:	c3                   	ret    
  801c82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c88:	39 f2                	cmp    %esi,%edx
  801c8a:	72 06                	jb     801c92 <__udivdi3+0x102>
  801c8c:	31 c0                	xor    %eax,%eax
  801c8e:	39 eb                	cmp    %ebp,%ebx
  801c90:	77 d2                	ja     801c64 <__udivdi3+0xd4>
  801c92:	b8 01 00 00 00       	mov    $0x1,%eax
  801c97:	eb cb                	jmp    801c64 <__udivdi3+0xd4>
  801c99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ca0:	89 d8                	mov    %ebx,%eax
  801ca2:	31 ff                	xor    %edi,%edi
  801ca4:	eb be                	jmp    801c64 <__udivdi3+0xd4>
  801ca6:	66 90                	xchg   %ax,%ax
  801ca8:	66 90                	xchg   %ax,%ax
  801caa:	66 90                	xchg   %ax,%ax
  801cac:	66 90                	xchg   %ax,%ax
  801cae:	66 90                	xchg   %ax,%ax

00801cb0 <__umoddi3>:
  801cb0:	55                   	push   %ebp
  801cb1:	57                   	push   %edi
  801cb2:	56                   	push   %esi
  801cb3:	53                   	push   %ebx
  801cb4:	83 ec 1c             	sub    $0x1c,%esp
  801cb7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801cbb:	8b 74 24 30          	mov    0x30(%esp),%esi
  801cbf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801cc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cc7:	85 ed                	test   %ebp,%ebp
  801cc9:	89 f0                	mov    %esi,%eax
  801ccb:	89 da                	mov    %ebx,%edx
  801ccd:	75 19                	jne    801ce8 <__umoddi3+0x38>
  801ccf:	39 df                	cmp    %ebx,%edi
  801cd1:	0f 86 b1 00 00 00    	jbe    801d88 <__umoddi3+0xd8>
  801cd7:	f7 f7                	div    %edi
  801cd9:	89 d0                	mov    %edx,%eax
  801cdb:	31 d2                	xor    %edx,%edx
  801cdd:	83 c4 1c             	add    $0x1c,%esp
  801ce0:	5b                   	pop    %ebx
  801ce1:	5e                   	pop    %esi
  801ce2:	5f                   	pop    %edi
  801ce3:	5d                   	pop    %ebp
  801ce4:	c3                   	ret    
  801ce5:	8d 76 00             	lea    0x0(%esi),%esi
  801ce8:	39 dd                	cmp    %ebx,%ebp
  801cea:	77 f1                	ja     801cdd <__umoddi3+0x2d>
  801cec:	0f bd cd             	bsr    %ebp,%ecx
  801cef:	83 f1 1f             	xor    $0x1f,%ecx
  801cf2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801cf6:	0f 84 b4 00 00 00    	je     801db0 <__umoddi3+0x100>
  801cfc:	b8 20 00 00 00       	mov    $0x20,%eax
  801d01:	89 c2                	mov    %eax,%edx
  801d03:	8b 44 24 04          	mov    0x4(%esp),%eax
  801d07:	29 c2                	sub    %eax,%edx
  801d09:	89 c1                	mov    %eax,%ecx
  801d0b:	89 f8                	mov    %edi,%eax
  801d0d:	d3 e5                	shl    %cl,%ebp
  801d0f:	89 d1                	mov    %edx,%ecx
  801d11:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801d15:	d3 e8                	shr    %cl,%eax
  801d17:	09 c5                	or     %eax,%ebp
  801d19:	8b 44 24 04          	mov    0x4(%esp),%eax
  801d1d:	89 c1                	mov    %eax,%ecx
  801d1f:	d3 e7                	shl    %cl,%edi
  801d21:	89 d1                	mov    %edx,%ecx
  801d23:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801d27:	89 df                	mov    %ebx,%edi
  801d29:	d3 ef                	shr    %cl,%edi
  801d2b:	89 c1                	mov    %eax,%ecx
  801d2d:	89 f0                	mov    %esi,%eax
  801d2f:	d3 e3                	shl    %cl,%ebx
  801d31:	89 d1                	mov    %edx,%ecx
  801d33:	89 fa                	mov    %edi,%edx
  801d35:	d3 e8                	shr    %cl,%eax
  801d37:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801d3c:	09 d8                	or     %ebx,%eax
  801d3e:	f7 f5                	div    %ebp
  801d40:	d3 e6                	shl    %cl,%esi
  801d42:	89 d1                	mov    %edx,%ecx
  801d44:	f7 64 24 08          	mull   0x8(%esp)
  801d48:	39 d1                	cmp    %edx,%ecx
  801d4a:	89 c3                	mov    %eax,%ebx
  801d4c:	89 d7                	mov    %edx,%edi
  801d4e:	72 06                	jb     801d56 <__umoddi3+0xa6>
  801d50:	75 0e                	jne    801d60 <__umoddi3+0xb0>
  801d52:	39 c6                	cmp    %eax,%esi
  801d54:	73 0a                	jae    801d60 <__umoddi3+0xb0>
  801d56:	2b 44 24 08          	sub    0x8(%esp),%eax
  801d5a:	19 ea                	sbb    %ebp,%edx
  801d5c:	89 d7                	mov    %edx,%edi
  801d5e:	89 c3                	mov    %eax,%ebx
  801d60:	89 ca                	mov    %ecx,%edx
  801d62:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801d67:	29 de                	sub    %ebx,%esi
  801d69:	19 fa                	sbb    %edi,%edx
  801d6b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  801d6f:	89 d0                	mov    %edx,%eax
  801d71:	d3 e0                	shl    %cl,%eax
  801d73:	89 d9                	mov    %ebx,%ecx
  801d75:	d3 ee                	shr    %cl,%esi
  801d77:	d3 ea                	shr    %cl,%edx
  801d79:	09 f0                	or     %esi,%eax
  801d7b:	83 c4 1c             	add    $0x1c,%esp
  801d7e:	5b                   	pop    %ebx
  801d7f:	5e                   	pop    %esi
  801d80:	5f                   	pop    %edi
  801d81:	5d                   	pop    %ebp
  801d82:	c3                   	ret    
  801d83:	90                   	nop
  801d84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d88:	85 ff                	test   %edi,%edi
  801d8a:	89 f9                	mov    %edi,%ecx
  801d8c:	75 0b                	jne    801d99 <__umoddi3+0xe9>
  801d8e:	b8 01 00 00 00       	mov    $0x1,%eax
  801d93:	31 d2                	xor    %edx,%edx
  801d95:	f7 f7                	div    %edi
  801d97:	89 c1                	mov    %eax,%ecx
  801d99:	89 d8                	mov    %ebx,%eax
  801d9b:	31 d2                	xor    %edx,%edx
  801d9d:	f7 f1                	div    %ecx
  801d9f:	89 f0                	mov    %esi,%eax
  801da1:	f7 f1                	div    %ecx
  801da3:	e9 31 ff ff ff       	jmp    801cd9 <__umoddi3+0x29>
  801da8:	90                   	nop
  801da9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801db0:	39 dd                	cmp    %ebx,%ebp
  801db2:	72 08                	jb     801dbc <__umoddi3+0x10c>
  801db4:	39 f7                	cmp    %esi,%edi
  801db6:	0f 87 21 ff ff ff    	ja     801cdd <__umoddi3+0x2d>
  801dbc:	89 da                	mov    %ebx,%edx
  801dbe:	89 f0                	mov    %esi,%eax
  801dc0:	29 f8                	sub    %edi,%eax
  801dc2:	19 ea                	sbb    %ebp,%edx
  801dc4:	e9 14 ff ff ff       	jmp    801cdd <__umoddi3+0x2d>
