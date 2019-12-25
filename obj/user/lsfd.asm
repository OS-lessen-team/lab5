
obj/user/lsfd.debug：     文件格式 elf32-i386


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
  80002c:	e8 e0 00 00 00       	call   800111 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <usage>:
#include <inc/lib.h>

void
usage(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	cprintf("usage: lsfd [-1]\n");
  800039:	68 e0 20 80 00       	push   $0x8020e0
  80003e:	e8 c3 01 00 00       	call   800206 <cprintf>
	exit();
  800043:	e8 0f 01 00 00       	call   800157 <exit>
}
  800048:	83 c4 10             	add    $0x10,%esp
  80004b:	c9                   	leave  
  80004c:	c3                   	ret    

0080004d <umain>:

void
umain(int argc, char **argv)
{
  80004d:	55                   	push   %ebp
  80004e:	89 e5                	mov    %esp,%ebp
  800050:	57                   	push   %edi
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	81 ec b0 00 00 00    	sub    $0xb0,%esp
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
  800059:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80005f:	50                   	push   %eax
  800060:	ff 75 0c             	pushl  0xc(%ebp)
  800063:	8d 45 08             	lea    0x8(%ebp),%eax
  800066:	50                   	push   %eax
  800067:	e8 a3 0d 00 00       	call   800e0f <argstart>
	while ((i = argnext(&args)) >= 0)
  80006c:	83 c4 10             	add    $0x10,%esp
	int i, usefprint = 0;
  80006f:	bf 00 00 00 00       	mov    $0x0,%edi
	while ((i = argnext(&args)) >= 0)
  800074:	8d 9d 4c ff ff ff    	lea    -0xb4(%ebp),%ebx
		if (i == '1')
			usefprint = 1;
  80007a:	be 01 00 00 00       	mov    $0x1,%esi
	while ((i = argnext(&args)) >= 0)
  80007f:	83 ec 0c             	sub    $0xc,%esp
  800082:	53                   	push   %ebx
  800083:	e8 b7 0d 00 00       	call   800e3f <argnext>
  800088:	83 c4 10             	add    $0x10,%esp
  80008b:	85 c0                	test   %eax,%eax
  80008d:	78 10                	js     80009f <umain+0x52>
		if (i == '1')
  80008f:	83 f8 31             	cmp    $0x31,%eax
  800092:	75 04                	jne    800098 <umain+0x4b>
			usefprint = 1;
  800094:	89 f7                	mov    %esi,%edi
  800096:	eb e7                	jmp    80007f <umain+0x32>
		else
			usage();
  800098:	e8 96 ff ff ff       	call   800033 <usage>
  80009d:	eb e0                	jmp    80007f <umain+0x32>

	for (i = 0; i < 32; i++)
  80009f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fstat(i, &st) >= 0) {
  8000a4:	8d b5 5c ff ff ff    	lea    -0xa4(%ebp),%esi
  8000aa:	eb 26                	jmp    8000d2 <umain+0x85>
			if (usefprint)
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
  8000ac:	83 ec 08             	sub    $0x8,%esp
  8000af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000b2:	ff 70 04             	pushl  0x4(%eax)
  8000b5:	ff 75 dc             	pushl  -0x24(%ebp)
  8000b8:	ff 75 e0             	pushl  -0x20(%ebp)
  8000bb:	56                   	push   %esi
  8000bc:	53                   	push   %ebx
  8000bd:	68 f4 20 80 00       	push   $0x8020f4
  8000c2:	e8 3f 01 00 00       	call   800206 <cprintf>
  8000c7:	83 c4 20             	add    $0x20,%esp
	for (i = 0; i < 32; i++)
  8000ca:	83 c3 01             	add    $0x1,%ebx
  8000cd:	83 fb 20             	cmp    $0x20,%ebx
  8000d0:	74 37                	je     800109 <umain+0xbc>
		if (fstat(i, &st) >= 0) {
  8000d2:	83 ec 08             	sub    $0x8,%esp
  8000d5:	56                   	push   %esi
  8000d6:	53                   	push   %ebx
  8000d7:	e8 66 13 00 00       	call   801442 <fstat>
  8000dc:	83 c4 10             	add    $0x10,%esp
  8000df:	85 c0                	test   %eax,%eax
  8000e1:	78 e7                	js     8000ca <umain+0x7d>
			if (usefprint)
  8000e3:	85 ff                	test   %edi,%edi
  8000e5:	74 c5                	je     8000ac <umain+0x5f>
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
  8000e7:	83 ec 04             	sub    $0x4,%esp
  8000ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000ed:	ff 70 04             	pushl  0x4(%eax)
  8000f0:	ff 75 dc             	pushl  -0x24(%ebp)
  8000f3:	ff 75 e0             	pushl  -0x20(%ebp)
  8000f6:	56                   	push   %esi
  8000f7:	53                   	push   %ebx
  8000f8:	68 f4 20 80 00       	push   $0x8020f4
  8000fd:	6a 01                	push   $0x1
  8000ff:	e8 2b 17 00 00       	call   80182f <fprintf>
  800104:	83 c4 20             	add    $0x20,%esp
  800107:	eb c1                	jmp    8000ca <umain+0x7d>
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
		}
}
  800109:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010c:	5b                   	pop    %ebx
  80010d:	5e                   	pop    %esi
  80010e:	5f                   	pop    %edi
  80010f:	5d                   	pop    %ebp
  800110:	c3                   	ret    

00800111 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800111:	55                   	push   %ebp
  800112:	89 e5                	mov    %esp,%ebp
  800114:	56                   	push   %esi
  800115:	53                   	push   %ebx
  800116:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800119:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  80011c:	e8 bf 0a 00 00       	call   800be0 <sys_getenvid>
	thisenv = envs + ENVX(envid); 
  800121:	25 ff 03 00 00       	and    $0x3ff,%eax
  800126:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800129:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80012e:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800133:	85 db                	test   %ebx,%ebx
  800135:	7e 07                	jle    80013e <libmain+0x2d>
		binaryname = argv[0];
  800137:	8b 06                	mov    (%esi),%eax
  800139:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80013e:	83 ec 08             	sub    $0x8,%esp
  800141:	56                   	push   %esi
  800142:	53                   	push   %ebx
  800143:	e8 05 ff ff ff       	call   80004d <umain>

	// exit gracefully
	exit();
  800148:	e8 0a 00 00 00       	call   800157 <exit>
}
  80014d:	83 c4 10             	add    $0x10,%esp
  800150:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800153:	5b                   	pop    %ebx
  800154:	5e                   	pop    %esi
  800155:	5d                   	pop    %ebp
  800156:	c3                   	ret    

00800157 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80015d:	e8 d7 0f 00 00       	call   801139 <close_all>
	sys_env_destroy(0);
  800162:	83 ec 0c             	sub    $0xc,%esp
  800165:	6a 00                	push   $0x0
  800167:	e8 33 0a 00 00       	call   800b9f <sys_env_destroy>
}
  80016c:	83 c4 10             	add    $0x10,%esp
  80016f:	c9                   	leave  
  800170:	c3                   	ret    

00800171 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800171:	55                   	push   %ebp
  800172:	89 e5                	mov    %esp,%ebp
  800174:	53                   	push   %ebx
  800175:	83 ec 04             	sub    $0x4,%esp
  800178:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80017b:	8b 13                	mov    (%ebx),%edx
  80017d:	8d 42 01             	lea    0x1(%edx),%eax
  800180:	89 03                	mov    %eax,(%ebx)
  800182:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800185:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800189:	3d ff 00 00 00       	cmp    $0xff,%eax
  80018e:	74 09                	je     800199 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800190:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800194:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800197:	c9                   	leave  
  800198:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800199:	83 ec 08             	sub    $0x8,%esp
  80019c:	68 ff 00 00 00       	push   $0xff
  8001a1:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a4:	50                   	push   %eax
  8001a5:	e8 b8 09 00 00       	call   800b62 <sys_cputs>
		b->idx = 0;
  8001aa:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b0:	83 c4 10             	add    $0x10,%esp
  8001b3:	eb db                	jmp    800190 <putch+0x1f>

008001b5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001b5:	55                   	push   %ebp
  8001b6:	89 e5                	mov    %esp,%ebp
  8001b8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001be:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c5:	00 00 00 
	b.cnt = 0;
  8001c8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001cf:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d2:	ff 75 0c             	pushl  0xc(%ebp)
  8001d5:	ff 75 08             	pushl  0x8(%ebp)
  8001d8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001de:	50                   	push   %eax
  8001df:	68 71 01 80 00       	push   $0x800171
  8001e4:	e8 1a 01 00 00       	call   800303 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e9:	83 c4 08             	add    $0x8,%esp
  8001ec:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001f2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f8:	50                   	push   %eax
  8001f9:	e8 64 09 00 00       	call   800b62 <sys_cputs>

	return b.cnt;
}
  8001fe:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800204:	c9                   	leave  
  800205:	c3                   	ret    

00800206 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800206:	55                   	push   %ebp
  800207:	89 e5                	mov    %esp,%ebp
  800209:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80020c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80020f:	50                   	push   %eax
  800210:	ff 75 08             	pushl  0x8(%ebp)
  800213:	e8 9d ff ff ff       	call   8001b5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800218:	c9                   	leave  
  800219:	c3                   	ret    

0080021a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80021a:	55                   	push   %ebp
  80021b:	89 e5                	mov    %esp,%ebp
  80021d:	57                   	push   %edi
  80021e:	56                   	push   %esi
  80021f:	53                   	push   %ebx
  800220:	83 ec 1c             	sub    $0x1c,%esp
  800223:	89 c7                	mov    %eax,%edi
  800225:	89 d6                	mov    %edx,%esi
  800227:	8b 45 08             	mov    0x8(%ebp),%eax
  80022a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80022d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800230:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800233:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800236:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80023e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800241:	39 d3                	cmp    %edx,%ebx
  800243:	72 05                	jb     80024a <printnum+0x30>
  800245:	39 45 10             	cmp    %eax,0x10(%ebp)
  800248:	77 7a                	ja     8002c4 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80024a:	83 ec 0c             	sub    $0xc,%esp
  80024d:	ff 75 18             	pushl  0x18(%ebp)
  800250:	8b 45 14             	mov    0x14(%ebp),%eax
  800253:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800256:	53                   	push   %ebx
  800257:	ff 75 10             	pushl  0x10(%ebp)
  80025a:	83 ec 08             	sub    $0x8,%esp
  80025d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800260:	ff 75 e0             	pushl  -0x20(%ebp)
  800263:	ff 75 dc             	pushl  -0x24(%ebp)
  800266:	ff 75 d8             	pushl  -0x28(%ebp)
  800269:	e8 32 1c 00 00       	call   801ea0 <__udivdi3>
  80026e:	83 c4 18             	add    $0x18,%esp
  800271:	52                   	push   %edx
  800272:	50                   	push   %eax
  800273:	89 f2                	mov    %esi,%edx
  800275:	89 f8                	mov    %edi,%eax
  800277:	e8 9e ff ff ff       	call   80021a <printnum>
  80027c:	83 c4 20             	add    $0x20,%esp
  80027f:	eb 13                	jmp    800294 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800281:	83 ec 08             	sub    $0x8,%esp
  800284:	56                   	push   %esi
  800285:	ff 75 18             	pushl  0x18(%ebp)
  800288:	ff d7                	call   *%edi
  80028a:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80028d:	83 eb 01             	sub    $0x1,%ebx
  800290:	85 db                	test   %ebx,%ebx
  800292:	7f ed                	jg     800281 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800294:	83 ec 08             	sub    $0x8,%esp
  800297:	56                   	push   %esi
  800298:	83 ec 04             	sub    $0x4,%esp
  80029b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80029e:	ff 75 e0             	pushl  -0x20(%ebp)
  8002a1:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a4:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a7:	e8 14 1d 00 00       	call   801fc0 <__umoddi3>
  8002ac:	83 c4 14             	add    $0x14,%esp
  8002af:	0f be 80 26 21 80 00 	movsbl 0x802126(%eax),%eax
  8002b6:	50                   	push   %eax
  8002b7:	ff d7                	call   *%edi
}
  8002b9:	83 c4 10             	add    $0x10,%esp
  8002bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002bf:	5b                   	pop    %ebx
  8002c0:	5e                   	pop    %esi
  8002c1:	5f                   	pop    %edi
  8002c2:	5d                   	pop    %ebp
  8002c3:	c3                   	ret    
  8002c4:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002c7:	eb c4                	jmp    80028d <printnum+0x73>

008002c9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002c9:	55                   	push   %ebp
  8002ca:	89 e5                	mov    %esp,%ebp
  8002cc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002cf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002d3:	8b 10                	mov    (%eax),%edx
  8002d5:	3b 50 04             	cmp    0x4(%eax),%edx
  8002d8:	73 0a                	jae    8002e4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002da:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002dd:	89 08                	mov    %ecx,(%eax)
  8002df:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e2:	88 02                	mov    %al,(%edx)
}
  8002e4:	5d                   	pop    %ebp
  8002e5:	c3                   	ret    

008002e6 <printfmt>:
{
  8002e6:	55                   	push   %ebp
  8002e7:	89 e5                	mov    %esp,%ebp
  8002e9:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002ec:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002ef:	50                   	push   %eax
  8002f0:	ff 75 10             	pushl  0x10(%ebp)
  8002f3:	ff 75 0c             	pushl  0xc(%ebp)
  8002f6:	ff 75 08             	pushl  0x8(%ebp)
  8002f9:	e8 05 00 00 00       	call   800303 <vprintfmt>
}
  8002fe:	83 c4 10             	add    $0x10,%esp
  800301:	c9                   	leave  
  800302:	c3                   	ret    

00800303 <vprintfmt>:
{
  800303:	55                   	push   %ebp
  800304:	89 e5                	mov    %esp,%ebp
  800306:	57                   	push   %edi
  800307:	56                   	push   %esi
  800308:	53                   	push   %ebx
  800309:	83 ec 2c             	sub    $0x2c,%esp
  80030c:	8b 75 08             	mov    0x8(%ebp),%esi
  80030f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800312:	8b 7d 10             	mov    0x10(%ebp),%edi
  800315:	e9 c1 03 00 00       	jmp    8006db <vprintfmt+0x3d8>
		padc = ' ';
  80031a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  80031e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800325:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  80032c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800333:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800338:	8d 47 01             	lea    0x1(%edi),%eax
  80033b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80033e:	0f b6 17             	movzbl (%edi),%edx
  800341:	8d 42 dd             	lea    -0x23(%edx),%eax
  800344:	3c 55                	cmp    $0x55,%al
  800346:	0f 87 12 04 00 00    	ja     80075e <vprintfmt+0x45b>
  80034c:	0f b6 c0             	movzbl %al,%eax
  80034f:	ff 24 85 60 22 80 00 	jmp    *0x802260(,%eax,4)
  800356:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800359:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80035d:	eb d9                	jmp    800338 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80035f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800362:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800366:	eb d0                	jmp    800338 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800368:	0f b6 d2             	movzbl %dl,%edx
  80036b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80036e:	b8 00 00 00 00       	mov    $0x0,%eax
  800373:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800376:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800379:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80037d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800380:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800383:	83 f9 09             	cmp    $0x9,%ecx
  800386:	77 55                	ja     8003dd <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800388:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80038b:	eb e9                	jmp    800376 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  80038d:	8b 45 14             	mov    0x14(%ebp),%eax
  800390:	8b 00                	mov    (%eax),%eax
  800392:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800395:	8b 45 14             	mov    0x14(%ebp),%eax
  800398:	8d 40 04             	lea    0x4(%eax),%eax
  80039b:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80039e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003a1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003a5:	79 91                	jns    800338 <vprintfmt+0x35>
				width = precision, precision = -1;
  8003a7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ad:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003b4:	eb 82                	jmp    800338 <vprintfmt+0x35>
  8003b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003b9:	85 c0                	test   %eax,%eax
  8003bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8003c0:	0f 49 d0             	cmovns %eax,%edx
  8003c3:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003c9:	e9 6a ff ff ff       	jmp    800338 <vprintfmt+0x35>
  8003ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003d1:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003d8:	e9 5b ff ff ff       	jmp    800338 <vprintfmt+0x35>
  8003dd:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003e0:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003e3:	eb bc                	jmp    8003a1 <vprintfmt+0x9e>
			lflag++;
  8003e5:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003eb:	e9 48 ff ff ff       	jmp    800338 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8003f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f3:	8d 78 04             	lea    0x4(%eax),%edi
  8003f6:	83 ec 08             	sub    $0x8,%esp
  8003f9:	53                   	push   %ebx
  8003fa:	ff 30                	pushl  (%eax)
  8003fc:	ff d6                	call   *%esi
			break;
  8003fe:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800401:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800404:	e9 cf 02 00 00       	jmp    8006d8 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  800409:	8b 45 14             	mov    0x14(%ebp),%eax
  80040c:	8d 78 04             	lea    0x4(%eax),%edi
  80040f:	8b 00                	mov    (%eax),%eax
  800411:	99                   	cltd   
  800412:	31 d0                	xor    %edx,%eax
  800414:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800416:	83 f8 0f             	cmp    $0xf,%eax
  800419:	7f 23                	jg     80043e <vprintfmt+0x13b>
  80041b:	8b 14 85 c0 23 80 00 	mov    0x8023c0(,%eax,4),%edx
  800422:	85 d2                	test   %edx,%edx
  800424:	74 18                	je     80043e <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800426:	52                   	push   %edx
  800427:	68 f1 24 80 00       	push   $0x8024f1
  80042c:	53                   	push   %ebx
  80042d:	56                   	push   %esi
  80042e:	e8 b3 fe ff ff       	call   8002e6 <printfmt>
  800433:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800436:	89 7d 14             	mov    %edi,0x14(%ebp)
  800439:	e9 9a 02 00 00       	jmp    8006d8 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  80043e:	50                   	push   %eax
  80043f:	68 3e 21 80 00       	push   $0x80213e
  800444:	53                   	push   %ebx
  800445:	56                   	push   %esi
  800446:	e8 9b fe ff ff       	call   8002e6 <printfmt>
  80044b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80044e:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800451:	e9 82 02 00 00       	jmp    8006d8 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  800456:	8b 45 14             	mov    0x14(%ebp),%eax
  800459:	83 c0 04             	add    $0x4,%eax
  80045c:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80045f:	8b 45 14             	mov    0x14(%ebp),%eax
  800462:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800464:	85 ff                	test   %edi,%edi
  800466:	b8 37 21 80 00       	mov    $0x802137,%eax
  80046b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80046e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800472:	0f 8e bd 00 00 00    	jle    800535 <vprintfmt+0x232>
  800478:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80047c:	75 0e                	jne    80048c <vprintfmt+0x189>
  80047e:	89 75 08             	mov    %esi,0x8(%ebp)
  800481:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800484:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800487:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80048a:	eb 6d                	jmp    8004f9 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  80048c:	83 ec 08             	sub    $0x8,%esp
  80048f:	ff 75 d0             	pushl  -0x30(%ebp)
  800492:	57                   	push   %edi
  800493:	e8 6e 03 00 00       	call   800806 <strnlen>
  800498:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80049b:	29 c1                	sub    %eax,%ecx
  80049d:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004a0:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004a3:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004a7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004aa:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004ad:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004af:	eb 0f                	jmp    8004c0 <vprintfmt+0x1bd>
					putch(padc, putdat);
  8004b1:	83 ec 08             	sub    $0x8,%esp
  8004b4:	53                   	push   %ebx
  8004b5:	ff 75 e0             	pushl  -0x20(%ebp)
  8004b8:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ba:	83 ef 01             	sub    $0x1,%edi
  8004bd:	83 c4 10             	add    $0x10,%esp
  8004c0:	85 ff                	test   %edi,%edi
  8004c2:	7f ed                	jg     8004b1 <vprintfmt+0x1ae>
  8004c4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004c7:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004ca:	85 c9                	test   %ecx,%ecx
  8004cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d1:	0f 49 c1             	cmovns %ecx,%eax
  8004d4:	29 c1                	sub    %eax,%ecx
  8004d6:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004dc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004df:	89 cb                	mov    %ecx,%ebx
  8004e1:	eb 16                	jmp    8004f9 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8004e3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004e7:	75 31                	jne    80051a <vprintfmt+0x217>
					putch(ch, putdat);
  8004e9:	83 ec 08             	sub    $0x8,%esp
  8004ec:	ff 75 0c             	pushl  0xc(%ebp)
  8004ef:	50                   	push   %eax
  8004f0:	ff 55 08             	call   *0x8(%ebp)
  8004f3:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004f6:	83 eb 01             	sub    $0x1,%ebx
  8004f9:	83 c7 01             	add    $0x1,%edi
  8004fc:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800500:	0f be c2             	movsbl %dl,%eax
  800503:	85 c0                	test   %eax,%eax
  800505:	74 59                	je     800560 <vprintfmt+0x25d>
  800507:	85 f6                	test   %esi,%esi
  800509:	78 d8                	js     8004e3 <vprintfmt+0x1e0>
  80050b:	83 ee 01             	sub    $0x1,%esi
  80050e:	79 d3                	jns    8004e3 <vprintfmt+0x1e0>
  800510:	89 df                	mov    %ebx,%edi
  800512:	8b 75 08             	mov    0x8(%ebp),%esi
  800515:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800518:	eb 37                	jmp    800551 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  80051a:	0f be d2             	movsbl %dl,%edx
  80051d:	83 ea 20             	sub    $0x20,%edx
  800520:	83 fa 5e             	cmp    $0x5e,%edx
  800523:	76 c4                	jbe    8004e9 <vprintfmt+0x1e6>
					putch('?', putdat);
  800525:	83 ec 08             	sub    $0x8,%esp
  800528:	ff 75 0c             	pushl  0xc(%ebp)
  80052b:	6a 3f                	push   $0x3f
  80052d:	ff 55 08             	call   *0x8(%ebp)
  800530:	83 c4 10             	add    $0x10,%esp
  800533:	eb c1                	jmp    8004f6 <vprintfmt+0x1f3>
  800535:	89 75 08             	mov    %esi,0x8(%ebp)
  800538:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80053b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80053e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800541:	eb b6                	jmp    8004f9 <vprintfmt+0x1f6>
				putch(' ', putdat);
  800543:	83 ec 08             	sub    $0x8,%esp
  800546:	53                   	push   %ebx
  800547:	6a 20                	push   $0x20
  800549:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80054b:	83 ef 01             	sub    $0x1,%edi
  80054e:	83 c4 10             	add    $0x10,%esp
  800551:	85 ff                	test   %edi,%edi
  800553:	7f ee                	jg     800543 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800555:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800558:	89 45 14             	mov    %eax,0x14(%ebp)
  80055b:	e9 78 01 00 00       	jmp    8006d8 <vprintfmt+0x3d5>
  800560:	89 df                	mov    %ebx,%edi
  800562:	8b 75 08             	mov    0x8(%ebp),%esi
  800565:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800568:	eb e7                	jmp    800551 <vprintfmt+0x24e>
	if (lflag >= 2)
  80056a:	83 f9 01             	cmp    $0x1,%ecx
  80056d:	7e 3f                	jle    8005ae <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  80056f:	8b 45 14             	mov    0x14(%ebp),%eax
  800572:	8b 50 04             	mov    0x4(%eax),%edx
  800575:	8b 00                	mov    (%eax),%eax
  800577:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80057d:	8b 45 14             	mov    0x14(%ebp),%eax
  800580:	8d 40 08             	lea    0x8(%eax),%eax
  800583:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800586:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80058a:	79 5c                	jns    8005e8 <vprintfmt+0x2e5>
				putch('-', putdat);
  80058c:	83 ec 08             	sub    $0x8,%esp
  80058f:	53                   	push   %ebx
  800590:	6a 2d                	push   $0x2d
  800592:	ff d6                	call   *%esi
				num = -(long long) num;
  800594:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800597:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80059a:	f7 da                	neg    %edx
  80059c:	83 d1 00             	adc    $0x0,%ecx
  80059f:	f7 d9                	neg    %ecx
  8005a1:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005a4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005a9:	e9 10 01 00 00       	jmp    8006be <vprintfmt+0x3bb>
	else if (lflag)
  8005ae:	85 c9                	test   %ecx,%ecx
  8005b0:	75 1b                	jne    8005cd <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8005b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b5:	8b 00                	mov    (%eax),%eax
  8005b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ba:	89 c1                	mov    %eax,%ecx
  8005bc:	c1 f9 1f             	sar    $0x1f,%ecx
  8005bf:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c5:	8d 40 04             	lea    0x4(%eax),%eax
  8005c8:	89 45 14             	mov    %eax,0x14(%ebp)
  8005cb:	eb b9                	jmp    800586 <vprintfmt+0x283>
		return va_arg(*ap, long);
  8005cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d0:	8b 00                	mov    (%eax),%eax
  8005d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d5:	89 c1                	mov    %eax,%ecx
  8005d7:	c1 f9 1f             	sar    $0x1f,%ecx
  8005da:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e0:	8d 40 04             	lea    0x4(%eax),%eax
  8005e3:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e6:	eb 9e                	jmp    800586 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8005e8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005eb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005ee:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f3:	e9 c6 00 00 00       	jmp    8006be <vprintfmt+0x3bb>
	if (lflag >= 2)
  8005f8:	83 f9 01             	cmp    $0x1,%ecx
  8005fb:	7e 18                	jle    800615 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8005fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800600:	8b 10                	mov    (%eax),%edx
  800602:	8b 48 04             	mov    0x4(%eax),%ecx
  800605:	8d 40 08             	lea    0x8(%eax),%eax
  800608:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80060b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800610:	e9 a9 00 00 00       	jmp    8006be <vprintfmt+0x3bb>
	else if (lflag)
  800615:	85 c9                	test   %ecx,%ecx
  800617:	75 1a                	jne    800633 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  800619:	8b 45 14             	mov    0x14(%ebp),%eax
  80061c:	8b 10                	mov    (%eax),%edx
  80061e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800623:	8d 40 04             	lea    0x4(%eax),%eax
  800626:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800629:	b8 0a 00 00 00       	mov    $0xa,%eax
  80062e:	e9 8b 00 00 00       	jmp    8006be <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800633:	8b 45 14             	mov    0x14(%ebp),%eax
  800636:	8b 10                	mov    (%eax),%edx
  800638:	b9 00 00 00 00       	mov    $0x0,%ecx
  80063d:	8d 40 04             	lea    0x4(%eax),%eax
  800640:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800643:	b8 0a 00 00 00       	mov    $0xa,%eax
  800648:	eb 74                	jmp    8006be <vprintfmt+0x3bb>
	if (lflag >= 2)
  80064a:	83 f9 01             	cmp    $0x1,%ecx
  80064d:	7e 15                	jle    800664 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  80064f:	8b 45 14             	mov    0x14(%ebp),%eax
  800652:	8b 10                	mov    (%eax),%edx
  800654:	8b 48 04             	mov    0x4(%eax),%ecx
  800657:	8d 40 08             	lea    0x8(%eax),%eax
  80065a:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80065d:	b8 08 00 00 00       	mov    $0x8,%eax
  800662:	eb 5a                	jmp    8006be <vprintfmt+0x3bb>
	else if (lflag)
  800664:	85 c9                	test   %ecx,%ecx
  800666:	75 17                	jne    80067f <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  800668:	8b 45 14             	mov    0x14(%ebp),%eax
  80066b:	8b 10                	mov    (%eax),%edx
  80066d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800672:	8d 40 04             	lea    0x4(%eax),%eax
  800675:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800678:	b8 08 00 00 00       	mov    $0x8,%eax
  80067d:	eb 3f                	jmp    8006be <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80067f:	8b 45 14             	mov    0x14(%ebp),%eax
  800682:	8b 10                	mov    (%eax),%edx
  800684:	b9 00 00 00 00       	mov    $0x0,%ecx
  800689:	8d 40 04             	lea    0x4(%eax),%eax
  80068c:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80068f:	b8 08 00 00 00       	mov    $0x8,%eax
  800694:	eb 28                	jmp    8006be <vprintfmt+0x3bb>
			putch('0', putdat);
  800696:	83 ec 08             	sub    $0x8,%esp
  800699:	53                   	push   %ebx
  80069a:	6a 30                	push   $0x30
  80069c:	ff d6                	call   *%esi
			putch('x', putdat);
  80069e:	83 c4 08             	add    $0x8,%esp
  8006a1:	53                   	push   %ebx
  8006a2:	6a 78                	push   $0x78
  8006a4:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a9:	8b 10                	mov    (%eax),%edx
  8006ab:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006b0:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006b3:	8d 40 04             	lea    0x4(%eax),%eax
  8006b6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b9:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006be:	83 ec 0c             	sub    $0xc,%esp
  8006c1:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006c5:	57                   	push   %edi
  8006c6:	ff 75 e0             	pushl  -0x20(%ebp)
  8006c9:	50                   	push   %eax
  8006ca:	51                   	push   %ecx
  8006cb:	52                   	push   %edx
  8006cc:	89 da                	mov    %ebx,%edx
  8006ce:	89 f0                	mov    %esi,%eax
  8006d0:	e8 45 fb ff ff       	call   80021a <printnum>
			break;
  8006d5:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8006d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006db:	83 c7 01             	add    $0x1,%edi
  8006de:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006e2:	83 f8 25             	cmp    $0x25,%eax
  8006e5:	0f 84 2f fc ff ff    	je     80031a <vprintfmt+0x17>
			if (ch == '\0')
  8006eb:	85 c0                	test   %eax,%eax
  8006ed:	0f 84 8b 00 00 00    	je     80077e <vprintfmt+0x47b>
			putch(ch, putdat);
  8006f3:	83 ec 08             	sub    $0x8,%esp
  8006f6:	53                   	push   %ebx
  8006f7:	50                   	push   %eax
  8006f8:	ff d6                	call   *%esi
  8006fa:	83 c4 10             	add    $0x10,%esp
  8006fd:	eb dc                	jmp    8006db <vprintfmt+0x3d8>
	if (lflag >= 2)
  8006ff:	83 f9 01             	cmp    $0x1,%ecx
  800702:	7e 15                	jle    800719 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  800704:	8b 45 14             	mov    0x14(%ebp),%eax
  800707:	8b 10                	mov    (%eax),%edx
  800709:	8b 48 04             	mov    0x4(%eax),%ecx
  80070c:	8d 40 08             	lea    0x8(%eax),%eax
  80070f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800712:	b8 10 00 00 00       	mov    $0x10,%eax
  800717:	eb a5                	jmp    8006be <vprintfmt+0x3bb>
	else if (lflag)
  800719:	85 c9                	test   %ecx,%ecx
  80071b:	75 17                	jne    800734 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  80071d:	8b 45 14             	mov    0x14(%ebp),%eax
  800720:	8b 10                	mov    (%eax),%edx
  800722:	b9 00 00 00 00       	mov    $0x0,%ecx
  800727:	8d 40 04             	lea    0x4(%eax),%eax
  80072a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80072d:	b8 10 00 00 00       	mov    $0x10,%eax
  800732:	eb 8a                	jmp    8006be <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800734:	8b 45 14             	mov    0x14(%ebp),%eax
  800737:	8b 10                	mov    (%eax),%edx
  800739:	b9 00 00 00 00       	mov    $0x0,%ecx
  80073e:	8d 40 04             	lea    0x4(%eax),%eax
  800741:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800744:	b8 10 00 00 00       	mov    $0x10,%eax
  800749:	e9 70 ff ff ff       	jmp    8006be <vprintfmt+0x3bb>
			putch(ch, putdat);
  80074e:	83 ec 08             	sub    $0x8,%esp
  800751:	53                   	push   %ebx
  800752:	6a 25                	push   $0x25
  800754:	ff d6                	call   *%esi
			break;
  800756:	83 c4 10             	add    $0x10,%esp
  800759:	e9 7a ff ff ff       	jmp    8006d8 <vprintfmt+0x3d5>
			putch('%', putdat);
  80075e:	83 ec 08             	sub    $0x8,%esp
  800761:	53                   	push   %ebx
  800762:	6a 25                	push   $0x25
  800764:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800766:	83 c4 10             	add    $0x10,%esp
  800769:	89 f8                	mov    %edi,%eax
  80076b:	eb 03                	jmp    800770 <vprintfmt+0x46d>
  80076d:	83 e8 01             	sub    $0x1,%eax
  800770:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800774:	75 f7                	jne    80076d <vprintfmt+0x46a>
  800776:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800779:	e9 5a ff ff ff       	jmp    8006d8 <vprintfmt+0x3d5>
}
  80077e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800781:	5b                   	pop    %ebx
  800782:	5e                   	pop    %esi
  800783:	5f                   	pop    %edi
  800784:	5d                   	pop    %ebp
  800785:	c3                   	ret    

00800786 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800786:	55                   	push   %ebp
  800787:	89 e5                	mov    %esp,%ebp
  800789:	83 ec 18             	sub    $0x18,%esp
  80078c:	8b 45 08             	mov    0x8(%ebp),%eax
  80078f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800792:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800795:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800799:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80079c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007a3:	85 c0                	test   %eax,%eax
  8007a5:	74 26                	je     8007cd <vsnprintf+0x47>
  8007a7:	85 d2                	test   %edx,%edx
  8007a9:	7e 22                	jle    8007cd <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007ab:	ff 75 14             	pushl  0x14(%ebp)
  8007ae:	ff 75 10             	pushl  0x10(%ebp)
  8007b1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007b4:	50                   	push   %eax
  8007b5:	68 c9 02 80 00       	push   $0x8002c9
  8007ba:	e8 44 fb ff ff       	call   800303 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007c2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007c8:	83 c4 10             	add    $0x10,%esp
}
  8007cb:	c9                   	leave  
  8007cc:	c3                   	ret    
		return -E_INVAL;
  8007cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007d2:	eb f7                	jmp    8007cb <vsnprintf+0x45>

008007d4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007d4:	55                   	push   %ebp
  8007d5:	89 e5                	mov    %esp,%ebp
  8007d7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007da:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007dd:	50                   	push   %eax
  8007de:	ff 75 10             	pushl  0x10(%ebp)
  8007e1:	ff 75 0c             	pushl  0xc(%ebp)
  8007e4:	ff 75 08             	pushl  0x8(%ebp)
  8007e7:	e8 9a ff ff ff       	call   800786 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007ec:	c9                   	leave  
  8007ed:	c3                   	ret    

008007ee <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007ee:	55                   	push   %ebp
  8007ef:	89 e5                	mov    %esp,%ebp
  8007f1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f9:	eb 03                	jmp    8007fe <strlen+0x10>
		n++;
  8007fb:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007fe:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800802:	75 f7                	jne    8007fb <strlen+0xd>
	return n;
}
  800804:	5d                   	pop    %ebp
  800805:	c3                   	ret    

00800806 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800806:	55                   	push   %ebp
  800807:	89 e5                	mov    %esp,%ebp
  800809:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80080c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80080f:	b8 00 00 00 00       	mov    $0x0,%eax
  800814:	eb 03                	jmp    800819 <strnlen+0x13>
		n++;
  800816:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800819:	39 d0                	cmp    %edx,%eax
  80081b:	74 06                	je     800823 <strnlen+0x1d>
  80081d:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800821:	75 f3                	jne    800816 <strnlen+0x10>
	return n;
}
  800823:	5d                   	pop    %ebp
  800824:	c3                   	ret    

00800825 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800825:	55                   	push   %ebp
  800826:	89 e5                	mov    %esp,%ebp
  800828:	53                   	push   %ebx
  800829:	8b 45 08             	mov    0x8(%ebp),%eax
  80082c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80082f:	89 c2                	mov    %eax,%edx
  800831:	83 c1 01             	add    $0x1,%ecx
  800834:	83 c2 01             	add    $0x1,%edx
  800837:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80083b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80083e:	84 db                	test   %bl,%bl
  800840:	75 ef                	jne    800831 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800842:	5b                   	pop    %ebx
  800843:	5d                   	pop    %ebp
  800844:	c3                   	ret    

00800845 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800845:	55                   	push   %ebp
  800846:	89 e5                	mov    %esp,%ebp
  800848:	53                   	push   %ebx
  800849:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80084c:	53                   	push   %ebx
  80084d:	e8 9c ff ff ff       	call   8007ee <strlen>
  800852:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800855:	ff 75 0c             	pushl  0xc(%ebp)
  800858:	01 d8                	add    %ebx,%eax
  80085a:	50                   	push   %eax
  80085b:	e8 c5 ff ff ff       	call   800825 <strcpy>
	return dst;
}
  800860:	89 d8                	mov    %ebx,%eax
  800862:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800865:	c9                   	leave  
  800866:	c3                   	ret    

00800867 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	56                   	push   %esi
  80086b:	53                   	push   %ebx
  80086c:	8b 75 08             	mov    0x8(%ebp),%esi
  80086f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800872:	89 f3                	mov    %esi,%ebx
  800874:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800877:	89 f2                	mov    %esi,%edx
  800879:	eb 0f                	jmp    80088a <strncpy+0x23>
		*dst++ = *src;
  80087b:	83 c2 01             	add    $0x1,%edx
  80087e:	0f b6 01             	movzbl (%ecx),%eax
  800881:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800884:	80 39 01             	cmpb   $0x1,(%ecx)
  800887:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80088a:	39 da                	cmp    %ebx,%edx
  80088c:	75 ed                	jne    80087b <strncpy+0x14>
	}
	return ret;
}
  80088e:	89 f0                	mov    %esi,%eax
  800890:	5b                   	pop    %ebx
  800891:	5e                   	pop    %esi
  800892:	5d                   	pop    %ebp
  800893:	c3                   	ret    

00800894 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	56                   	push   %esi
  800898:	53                   	push   %ebx
  800899:	8b 75 08             	mov    0x8(%ebp),%esi
  80089c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008a2:	89 f0                	mov    %esi,%eax
  8008a4:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008a8:	85 c9                	test   %ecx,%ecx
  8008aa:	75 0b                	jne    8008b7 <strlcpy+0x23>
  8008ac:	eb 17                	jmp    8008c5 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008ae:	83 c2 01             	add    $0x1,%edx
  8008b1:	83 c0 01             	add    $0x1,%eax
  8008b4:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8008b7:	39 d8                	cmp    %ebx,%eax
  8008b9:	74 07                	je     8008c2 <strlcpy+0x2e>
  8008bb:	0f b6 0a             	movzbl (%edx),%ecx
  8008be:	84 c9                	test   %cl,%cl
  8008c0:	75 ec                	jne    8008ae <strlcpy+0x1a>
		*dst = '\0';
  8008c2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008c5:	29 f0                	sub    %esi,%eax
}
  8008c7:	5b                   	pop    %ebx
  8008c8:	5e                   	pop    %esi
  8008c9:	5d                   	pop    %ebp
  8008ca:	c3                   	ret    

008008cb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008cb:	55                   	push   %ebp
  8008cc:	89 e5                	mov    %esp,%ebp
  8008ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008d4:	eb 06                	jmp    8008dc <strcmp+0x11>
		p++, q++;
  8008d6:	83 c1 01             	add    $0x1,%ecx
  8008d9:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008dc:	0f b6 01             	movzbl (%ecx),%eax
  8008df:	84 c0                	test   %al,%al
  8008e1:	74 04                	je     8008e7 <strcmp+0x1c>
  8008e3:	3a 02                	cmp    (%edx),%al
  8008e5:	74 ef                	je     8008d6 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e7:	0f b6 c0             	movzbl %al,%eax
  8008ea:	0f b6 12             	movzbl (%edx),%edx
  8008ed:	29 d0                	sub    %edx,%eax
}
  8008ef:	5d                   	pop    %ebp
  8008f0:	c3                   	ret    

008008f1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	53                   	push   %ebx
  8008f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008fb:	89 c3                	mov    %eax,%ebx
  8008fd:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800900:	eb 06                	jmp    800908 <strncmp+0x17>
		n--, p++, q++;
  800902:	83 c0 01             	add    $0x1,%eax
  800905:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800908:	39 d8                	cmp    %ebx,%eax
  80090a:	74 16                	je     800922 <strncmp+0x31>
  80090c:	0f b6 08             	movzbl (%eax),%ecx
  80090f:	84 c9                	test   %cl,%cl
  800911:	74 04                	je     800917 <strncmp+0x26>
  800913:	3a 0a                	cmp    (%edx),%cl
  800915:	74 eb                	je     800902 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800917:	0f b6 00             	movzbl (%eax),%eax
  80091a:	0f b6 12             	movzbl (%edx),%edx
  80091d:	29 d0                	sub    %edx,%eax
}
  80091f:	5b                   	pop    %ebx
  800920:	5d                   	pop    %ebp
  800921:	c3                   	ret    
		return 0;
  800922:	b8 00 00 00 00       	mov    $0x0,%eax
  800927:	eb f6                	jmp    80091f <strncmp+0x2e>

00800929 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	8b 45 08             	mov    0x8(%ebp),%eax
  80092f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800933:	0f b6 10             	movzbl (%eax),%edx
  800936:	84 d2                	test   %dl,%dl
  800938:	74 09                	je     800943 <strchr+0x1a>
		if (*s == c)
  80093a:	38 ca                	cmp    %cl,%dl
  80093c:	74 0a                	je     800948 <strchr+0x1f>
	for (; *s; s++)
  80093e:	83 c0 01             	add    $0x1,%eax
  800941:	eb f0                	jmp    800933 <strchr+0xa>
			return (char *) s;
	return 0;
  800943:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800948:	5d                   	pop    %ebp
  800949:	c3                   	ret    

0080094a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	8b 45 08             	mov    0x8(%ebp),%eax
  800950:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800954:	eb 03                	jmp    800959 <strfind+0xf>
  800956:	83 c0 01             	add    $0x1,%eax
  800959:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80095c:	38 ca                	cmp    %cl,%dl
  80095e:	74 04                	je     800964 <strfind+0x1a>
  800960:	84 d2                	test   %dl,%dl
  800962:	75 f2                	jne    800956 <strfind+0xc>
			break;
	return (char *) s;
}
  800964:	5d                   	pop    %ebp
  800965:	c3                   	ret    

00800966 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800966:	55                   	push   %ebp
  800967:	89 e5                	mov    %esp,%ebp
  800969:	57                   	push   %edi
  80096a:	56                   	push   %esi
  80096b:	53                   	push   %ebx
  80096c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80096f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800972:	85 c9                	test   %ecx,%ecx
  800974:	74 13                	je     800989 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800976:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80097c:	75 05                	jne    800983 <memset+0x1d>
  80097e:	f6 c1 03             	test   $0x3,%cl
  800981:	74 0d                	je     800990 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800983:	8b 45 0c             	mov    0xc(%ebp),%eax
  800986:	fc                   	cld    
  800987:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800989:	89 f8                	mov    %edi,%eax
  80098b:	5b                   	pop    %ebx
  80098c:	5e                   	pop    %esi
  80098d:	5f                   	pop    %edi
  80098e:	5d                   	pop    %ebp
  80098f:	c3                   	ret    
		c &= 0xFF;
  800990:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800994:	89 d3                	mov    %edx,%ebx
  800996:	c1 e3 08             	shl    $0x8,%ebx
  800999:	89 d0                	mov    %edx,%eax
  80099b:	c1 e0 18             	shl    $0x18,%eax
  80099e:	89 d6                	mov    %edx,%esi
  8009a0:	c1 e6 10             	shl    $0x10,%esi
  8009a3:	09 f0                	or     %esi,%eax
  8009a5:	09 c2                	or     %eax,%edx
  8009a7:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  8009a9:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009ac:	89 d0                	mov    %edx,%eax
  8009ae:	fc                   	cld    
  8009af:	f3 ab                	rep stos %eax,%es:(%edi)
  8009b1:	eb d6                	jmp    800989 <memset+0x23>

008009b3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009b3:	55                   	push   %ebp
  8009b4:	89 e5                	mov    %esp,%ebp
  8009b6:	57                   	push   %edi
  8009b7:	56                   	push   %esi
  8009b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009be:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009c1:	39 c6                	cmp    %eax,%esi
  8009c3:	73 35                	jae    8009fa <memmove+0x47>
  8009c5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009c8:	39 c2                	cmp    %eax,%edx
  8009ca:	76 2e                	jbe    8009fa <memmove+0x47>
		s += n;
		d += n;
  8009cc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009cf:	89 d6                	mov    %edx,%esi
  8009d1:	09 fe                	or     %edi,%esi
  8009d3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009d9:	74 0c                	je     8009e7 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009db:	83 ef 01             	sub    $0x1,%edi
  8009de:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009e1:	fd                   	std    
  8009e2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009e4:	fc                   	cld    
  8009e5:	eb 21                	jmp    800a08 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e7:	f6 c1 03             	test   $0x3,%cl
  8009ea:	75 ef                	jne    8009db <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009ec:	83 ef 04             	sub    $0x4,%edi
  8009ef:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009f2:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009f5:	fd                   	std    
  8009f6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009f8:	eb ea                	jmp    8009e4 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009fa:	89 f2                	mov    %esi,%edx
  8009fc:	09 c2                	or     %eax,%edx
  8009fe:	f6 c2 03             	test   $0x3,%dl
  800a01:	74 09                	je     800a0c <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a03:	89 c7                	mov    %eax,%edi
  800a05:	fc                   	cld    
  800a06:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a08:	5e                   	pop    %esi
  800a09:	5f                   	pop    %edi
  800a0a:	5d                   	pop    %ebp
  800a0b:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a0c:	f6 c1 03             	test   $0x3,%cl
  800a0f:	75 f2                	jne    800a03 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a11:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a14:	89 c7                	mov    %eax,%edi
  800a16:	fc                   	cld    
  800a17:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a19:	eb ed                	jmp    800a08 <memmove+0x55>

00800a1b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a1b:	55                   	push   %ebp
  800a1c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a1e:	ff 75 10             	pushl  0x10(%ebp)
  800a21:	ff 75 0c             	pushl  0xc(%ebp)
  800a24:	ff 75 08             	pushl  0x8(%ebp)
  800a27:	e8 87 ff ff ff       	call   8009b3 <memmove>
}
  800a2c:	c9                   	leave  
  800a2d:	c3                   	ret    

00800a2e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a2e:	55                   	push   %ebp
  800a2f:	89 e5                	mov    %esp,%ebp
  800a31:	56                   	push   %esi
  800a32:	53                   	push   %ebx
  800a33:	8b 45 08             	mov    0x8(%ebp),%eax
  800a36:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a39:	89 c6                	mov    %eax,%esi
  800a3b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a3e:	39 f0                	cmp    %esi,%eax
  800a40:	74 1c                	je     800a5e <memcmp+0x30>
		if (*s1 != *s2)
  800a42:	0f b6 08             	movzbl (%eax),%ecx
  800a45:	0f b6 1a             	movzbl (%edx),%ebx
  800a48:	38 d9                	cmp    %bl,%cl
  800a4a:	75 08                	jne    800a54 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a4c:	83 c0 01             	add    $0x1,%eax
  800a4f:	83 c2 01             	add    $0x1,%edx
  800a52:	eb ea                	jmp    800a3e <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a54:	0f b6 c1             	movzbl %cl,%eax
  800a57:	0f b6 db             	movzbl %bl,%ebx
  800a5a:	29 d8                	sub    %ebx,%eax
  800a5c:	eb 05                	jmp    800a63 <memcmp+0x35>
	}

	return 0;
  800a5e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a63:	5b                   	pop    %ebx
  800a64:	5e                   	pop    %esi
  800a65:	5d                   	pop    %ebp
  800a66:	c3                   	ret    

00800a67 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a67:	55                   	push   %ebp
  800a68:	89 e5                	mov    %esp,%ebp
  800a6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a70:	89 c2                	mov    %eax,%edx
  800a72:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a75:	39 d0                	cmp    %edx,%eax
  800a77:	73 09                	jae    800a82 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a79:	38 08                	cmp    %cl,(%eax)
  800a7b:	74 05                	je     800a82 <memfind+0x1b>
	for (; s < ends; s++)
  800a7d:	83 c0 01             	add    $0x1,%eax
  800a80:	eb f3                	jmp    800a75 <memfind+0xe>
			break;
	return (void *) s;
}
  800a82:	5d                   	pop    %ebp
  800a83:	c3                   	ret    

00800a84 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	57                   	push   %edi
  800a88:	56                   	push   %esi
  800a89:	53                   	push   %ebx
  800a8a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a8d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a90:	eb 03                	jmp    800a95 <strtol+0x11>
		s++;
  800a92:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a95:	0f b6 01             	movzbl (%ecx),%eax
  800a98:	3c 20                	cmp    $0x20,%al
  800a9a:	74 f6                	je     800a92 <strtol+0xe>
  800a9c:	3c 09                	cmp    $0x9,%al
  800a9e:	74 f2                	je     800a92 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800aa0:	3c 2b                	cmp    $0x2b,%al
  800aa2:	74 2e                	je     800ad2 <strtol+0x4e>
	int neg = 0;
  800aa4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800aa9:	3c 2d                	cmp    $0x2d,%al
  800aab:	74 2f                	je     800adc <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aad:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ab3:	75 05                	jne    800aba <strtol+0x36>
  800ab5:	80 39 30             	cmpb   $0x30,(%ecx)
  800ab8:	74 2c                	je     800ae6 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aba:	85 db                	test   %ebx,%ebx
  800abc:	75 0a                	jne    800ac8 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800abe:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800ac3:	80 39 30             	cmpb   $0x30,(%ecx)
  800ac6:	74 28                	je     800af0 <strtol+0x6c>
		base = 10;
  800ac8:	b8 00 00 00 00       	mov    $0x0,%eax
  800acd:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ad0:	eb 50                	jmp    800b22 <strtol+0x9e>
		s++;
  800ad2:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800ad5:	bf 00 00 00 00       	mov    $0x0,%edi
  800ada:	eb d1                	jmp    800aad <strtol+0x29>
		s++, neg = 1;
  800adc:	83 c1 01             	add    $0x1,%ecx
  800adf:	bf 01 00 00 00       	mov    $0x1,%edi
  800ae4:	eb c7                	jmp    800aad <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ae6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aea:	74 0e                	je     800afa <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800aec:	85 db                	test   %ebx,%ebx
  800aee:	75 d8                	jne    800ac8 <strtol+0x44>
		s++, base = 8;
  800af0:	83 c1 01             	add    $0x1,%ecx
  800af3:	bb 08 00 00 00       	mov    $0x8,%ebx
  800af8:	eb ce                	jmp    800ac8 <strtol+0x44>
		s += 2, base = 16;
  800afa:	83 c1 02             	add    $0x2,%ecx
  800afd:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b02:	eb c4                	jmp    800ac8 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800b04:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b07:	89 f3                	mov    %esi,%ebx
  800b09:	80 fb 19             	cmp    $0x19,%bl
  800b0c:	77 29                	ja     800b37 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b0e:	0f be d2             	movsbl %dl,%edx
  800b11:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b14:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b17:	7d 30                	jge    800b49 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b19:	83 c1 01             	add    $0x1,%ecx
  800b1c:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b20:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b22:	0f b6 11             	movzbl (%ecx),%edx
  800b25:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b28:	89 f3                	mov    %esi,%ebx
  800b2a:	80 fb 09             	cmp    $0x9,%bl
  800b2d:	77 d5                	ja     800b04 <strtol+0x80>
			dig = *s - '0';
  800b2f:	0f be d2             	movsbl %dl,%edx
  800b32:	83 ea 30             	sub    $0x30,%edx
  800b35:	eb dd                	jmp    800b14 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800b37:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b3a:	89 f3                	mov    %esi,%ebx
  800b3c:	80 fb 19             	cmp    $0x19,%bl
  800b3f:	77 08                	ja     800b49 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b41:	0f be d2             	movsbl %dl,%edx
  800b44:	83 ea 37             	sub    $0x37,%edx
  800b47:	eb cb                	jmp    800b14 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b49:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b4d:	74 05                	je     800b54 <strtol+0xd0>
		*endptr = (char *) s;
  800b4f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b52:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b54:	89 c2                	mov    %eax,%edx
  800b56:	f7 da                	neg    %edx
  800b58:	85 ff                	test   %edi,%edi
  800b5a:	0f 45 c2             	cmovne %edx,%eax
}
  800b5d:	5b                   	pop    %ebx
  800b5e:	5e                   	pop    %esi
  800b5f:	5f                   	pop    %edi
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	57                   	push   %edi
  800b66:	56                   	push   %esi
  800b67:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b68:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b73:	89 c3                	mov    %eax,%ebx
  800b75:	89 c7                	mov    %eax,%edi
  800b77:	89 c6                	mov    %eax,%esi
  800b79:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b7b:	5b                   	pop    %ebx
  800b7c:	5e                   	pop    %esi
  800b7d:	5f                   	pop    %edi
  800b7e:	5d                   	pop    %ebp
  800b7f:	c3                   	ret    

00800b80 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	57                   	push   %edi
  800b84:	56                   	push   %esi
  800b85:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b86:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b90:	89 d1                	mov    %edx,%ecx
  800b92:	89 d3                	mov    %edx,%ebx
  800b94:	89 d7                	mov    %edx,%edi
  800b96:	89 d6                	mov    %edx,%esi
  800b98:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b9a:	5b                   	pop    %ebx
  800b9b:	5e                   	pop    %esi
  800b9c:	5f                   	pop    %edi
  800b9d:	5d                   	pop    %ebp
  800b9e:	c3                   	ret    

00800b9f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	57                   	push   %edi
  800ba3:	56                   	push   %esi
  800ba4:	53                   	push   %ebx
  800ba5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ba8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bad:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb0:	b8 03 00 00 00       	mov    $0x3,%eax
  800bb5:	89 cb                	mov    %ecx,%ebx
  800bb7:	89 cf                	mov    %ecx,%edi
  800bb9:	89 ce                	mov    %ecx,%esi
  800bbb:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bbd:	85 c0                	test   %eax,%eax
  800bbf:	7f 08                	jg     800bc9 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc4:	5b                   	pop    %ebx
  800bc5:	5e                   	pop    %esi
  800bc6:	5f                   	pop    %edi
  800bc7:	5d                   	pop    %ebp
  800bc8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc9:	83 ec 0c             	sub    $0xc,%esp
  800bcc:	50                   	push   %eax
  800bcd:	6a 03                	push   $0x3
  800bcf:	68 1f 24 80 00       	push   $0x80241f
  800bd4:	6a 23                	push   $0x23
  800bd6:	68 3c 24 80 00       	push   $0x80243c
  800bdb:	e8 46 11 00 00       	call   801d26 <_panic>

00800be0 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800be0:	55                   	push   %ebp
  800be1:	89 e5                	mov    %esp,%ebp
  800be3:	57                   	push   %edi
  800be4:	56                   	push   %esi
  800be5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800be6:	ba 00 00 00 00       	mov    $0x0,%edx
  800beb:	b8 02 00 00 00       	mov    $0x2,%eax
  800bf0:	89 d1                	mov    %edx,%ecx
  800bf2:	89 d3                	mov    %edx,%ebx
  800bf4:	89 d7                	mov    %edx,%edi
  800bf6:	89 d6                	mov    %edx,%esi
  800bf8:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bfa:	5b                   	pop    %ebx
  800bfb:	5e                   	pop    %esi
  800bfc:	5f                   	pop    %edi
  800bfd:	5d                   	pop    %ebp
  800bfe:	c3                   	ret    

00800bff <sys_yield>:

void
sys_yield(void)
{
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	57                   	push   %edi
  800c03:	56                   	push   %esi
  800c04:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c05:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c0f:	89 d1                	mov    %edx,%ecx
  800c11:	89 d3                	mov    %edx,%ebx
  800c13:	89 d7                	mov    %edx,%edi
  800c15:	89 d6                	mov    %edx,%esi
  800c17:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c19:	5b                   	pop    %ebx
  800c1a:	5e                   	pop    %esi
  800c1b:	5f                   	pop    %edi
  800c1c:	5d                   	pop    %ebp
  800c1d:	c3                   	ret    

00800c1e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c1e:	55                   	push   %ebp
  800c1f:	89 e5                	mov    %esp,%ebp
  800c21:	57                   	push   %edi
  800c22:	56                   	push   %esi
  800c23:	53                   	push   %ebx
  800c24:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c27:	be 00 00 00 00       	mov    $0x0,%esi
  800c2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c32:	b8 04 00 00 00       	mov    $0x4,%eax
  800c37:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c3a:	89 f7                	mov    %esi,%edi
  800c3c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c3e:	85 c0                	test   %eax,%eax
  800c40:	7f 08                	jg     800c4a <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c45:	5b                   	pop    %ebx
  800c46:	5e                   	pop    %esi
  800c47:	5f                   	pop    %edi
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4a:	83 ec 0c             	sub    $0xc,%esp
  800c4d:	50                   	push   %eax
  800c4e:	6a 04                	push   $0x4
  800c50:	68 1f 24 80 00       	push   $0x80241f
  800c55:	6a 23                	push   $0x23
  800c57:	68 3c 24 80 00       	push   $0x80243c
  800c5c:	e8 c5 10 00 00       	call   801d26 <_panic>

00800c61 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	57                   	push   %edi
  800c65:	56                   	push   %esi
  800c66:	53                   	push   %ebx
  800c67:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c70:	b8 05 00 00 00       	mov    $0x5,%eax
  800c75:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c78:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c7b:	8b 75 18             	mov    0x18(%ebp),%esi
  800c7e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c80:	85 c0                	test   %eax,%eax
  800c82:	7f 08                	jg     800c8c <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c87:	5b                   	pop    %ebx
  800c88:	5e                   	pop    %esi
  800c89:	5f                   	pop    %edi
  800c8a:	5d                   	pop    %ebp
  800c8b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8c:	83 ec 0c             	sub    $0xc,%esp
  800c8f:	50                   	push   %eax
  800c90:	6a 05                	push   $0x5
  800c92:	68 1f 24 80 00       	push   $0x80241f
  800c97:	6a 23                	push   $0x23
  800c99:	68 3c 24 80 00       	push   $0x80243c
  800c9e:	e8 83 10 00 00       	call   801d26 <_panic>

00800ca3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ca3:	55                   	push   %ebp
  800ca4:	89 e5                	mov    %esp,%ebp
  800ca6:	57                   	push   %edi
  800ca7:	56                   	push   %esi
  800ca8:	53                   	push   %ebx
  800ca9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cac:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb7:	b8 06 00 00 00       	mov    $0x6,%eax
  800cbc:	89 df                	mov    %ebx,%edi
  800cbe:	89 de                	mov    %ebx,%esi
  800cc0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cc2:	85 c0                	test   %eax,%eax
  800cc4:	7f 08                	jg     800cce <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc9:	5b                   	pop    %ebx
  800cca:	5e                   	pop    %esi
  800ccb:	5f                   	pop    %edi
  800ccc:	5d                   	pop    %ebp
  800ccd:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cce:	83 ec 0c             	sub    $0xc,%esp
  800cd1:	50                   	push   %eax
  800cd2:	6a 06                	push   $0x6
  800cd4:	68 1f 24 80 00       	push   $0x80241f
  800cd9:	6a 23                	push   $0x23
  800cdb:	68 3c 24 80 00       	push   $0x80243c
  800ce0:	e8 41 10 00 00       	call   801d26 <_panic>

00800ce5 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ce5:	55                   	push   %ebp
  800ce6:	89 e5                	mov    %esp,%ebp
  800ce8:	57                   	push   %edi
  800ce9:	56                   	push   %esi
  800cea:	53                   	push   %ebx
  800ceb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cee:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf9:	b8 08 00 00 00       	mov    $0x8,%eax
  800cfe:	89 df                	mov    %ebx,%edi
  800d00:	89 de                	mov    %ebx,%esi
  800d02:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d04:	85 c0                	test   %eax,%eax
  800d06:	7f 08                	jg     800d10 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0b:	5b                   	pop    %ebx
  800d0c:	5e                   	pop    %esi
  800d0d:	5f                   	pop    %edi
  800d0e:	5d                   	pop    %ebp
  800d0f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d10:	83 ec 0c             	sub    $0xc,%esp
  800d13:	50                   	push   %eax
  800d14:	6a 08                	push   $0x8
  800d16:	68 1f 24 80 00       	push   $0x80241f
  800d1b:	6a 23                	push   $0x23
  800d1d:	68 3c 24 80 00       	push   $0x80243c
  800d22:	e8 ff 0f 00 00       	call   801d26 <_panic>

00800d27 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	57                   	push   %edi
  800d2b:	56                   	push   %esi
  800d2c:	53                   	push   %ebx
  800d2d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d30:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d35:	8b 55 08             	mov    0x8(%ebp),%edx
  800d38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3b:	b8 09 00 00 00       	mov    $0x9,%eax
  800d40:	89 df                	mov    %ebx,%edi
  800d42:	89 de                	mov    %ebx,%esi
  800d44:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d46:	85 c0                	test   %eax,%eax
  800d48:	7f 08                	jg     800d52 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4d:	5b                   	pop    %ebx
  800d4e:	5e                   	pop    %esi
  800d4f:	5f                   	pop    %edi
  800d50:	5d                   	pop    %ebp
  800d51:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d52:	83 ec 0c             	sub    $0xc,%esp
  800d55:	50                   	push   %eax
  800d56:	6a 09                	push   $0x9
  800d58:	68 1f 24 80 00       	push   $0x80241f
  800d5d:	6a 23                	push   $0x23
  800d5f:	68 3c 24 80 00       	push   $0x80243c
  800d64:	e8 bd 0f 00 00       	call   801d26 <_panic>

00800d69 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d69:	55                   	push   %ebp
  800d6a:	89 e5                	mov    %esp,%ebp
  800d6c:	57                   	push   %edi
  800d6d:	56                   	push   %esi
  800d6e:	53                   	push   %ebx
  800d6f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d72:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d77:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d82:	89 df                	mov    %ebx,%edi
  800d84:	89 de                	mov    %ebx,%esi
  800d86:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d88:	85 c0                	test   %eax,%eax
  800d8a:	7f 08                	jg     800d94 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d8f:	5b                   	pop    %ebx
  800d90:	5e                   	pop    %esi
  800d91:	5f                   	pop    %edi
  800d92:	5d                   	pop    %ebp
  800d93:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d94:	83 ec 0c             	sub    $0xc,%esp
  800d97:	50                   	push   %eax
  800d98:	6a 0a                	push   $0xa
  800d9a:	68 1f 24 80 00       	push   $0x80241f
  800d9f:	6a 23                	push   $0x23
  800da1:	68 3c 24 80 00       	push   $0x80243c
  800da6:	e8 7b 0f 00 00       	call   801d26 <_panic>

00800dab <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dab:	55                   	push   %ebp
  800dac:	89 e5                	mov    %esp,%ebp
  800dae:	57                   	push   %edi
  800daf:	56                   	push   %esi
  800db0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800db1:	8b 55 08             	mov    0x8(%ebp),%edx
  800db4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dbc:	be 00 00 00 00       	mov    $0x0,%esi
  800dc1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dc4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dc7:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dc9:	5b                   	pop    %ebx
  800dca:	5e                   	pop    %esi
  800dcb:	5f                   	pop    %edi
  800dcc:	5d                   	pop    %ebp
  800dcd:	c3                   	ret    

00800dce <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dce:	55                   	push   %ebp
  800dcf:	89 e5                	mov    %esp,%ebp
  800dd1:	57                   	push   %edi
  800dd2:	56                   	push   %esi
  800dd3:	53                   	push   %ebx
  800dd4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dd7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ddc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddf:	b8 0d 00 00 00       	mov    $0xd,%eax
  800de4:	89 cb                	mov    %ecx,%ebx
  800de6:	89 cf                	mov    %ecx,%edi
  800de8:	89 ce                	mov    %ecx,%esi
  800dea:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dec:	85 c0                	test   %eax,%eax
  800dee:	7f 08                	jg     800df8 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800df0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df3:	5b                   	pop    %ebx
  800df4:	5e                   	pop    %esi
  800df5:	5f                   	pop    %edi
  800df6:	5d                   	pop    %ebp
  800df7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800df8:	83 ec 0c             	sub    $0xc,%esp
  800dfb:	50                   	push   %eax
  800dfc:	6a 0d                	push   $0xd
  800dfe:	68 1f 24 80 00       	push   $0x80241f
  800e03:	6a 23                	push   $0x23
  800e05:	68 3c 24 80 00       	push   $0x80243c
  800e0a:	e8 17 0f 00 00       	call   801d26 <_panic>

00800e0f <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800e0f:	55                   	push   %ebp
  800e10:	89 e5                	mov    %esp,%ebp
  800e12:	8b 55 08             	mov    0x8(%ebp),%edx
  800e15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e18:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  800e1b:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  800e1d:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  800e20:	83 3a 01             	cmpl   $0x1,(%edx)
  800e23:	7e 09                	jle    800e2e <argstart+0x1f>
  800e25:	ba f1 20 80 00       	mov    $0x8020f1,%edx
  800e2a:	85 c9                	test   %ecx,%ecx
  800e2c:	75 05                	jne    800e33 <argstart+0x24>
  800e2e:	ba 00 00 00 00       	mov    $0x0,%edx
  800e33:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  800e36:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  800e3d:	5d                   	pop    %ebp
  800e3e:	c3                   	ret    

00800e3f <argnext>:

int
argnext(struct Argstate *args)
{
  800e3f:	55                   	push   %ebp
  800e40:	89 e5                	mov    %esp,%ebp
  800e42:	53                   	push   %ebx
  800e43:	83 ec 04             	sub    $0x4,%esp
  800e46:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  800e49:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  800e50:	8b 43 08             	mov    0x8(%ebx),%eax
  800e53:	85 c0                	test   %eax,%eax
  800e55:	74 72                	je     800ec9 <argnext+0x8a>
		return -1;

	if (!*args->curarg) {
  800e57:	80 38 00             	cmpb   $0x0,(%eax)
  800e5a:	75 48                	jne    800ea4 <argnext+0x65>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  800e5c:	8b 0b                	mov    (%ebx),%ecx
  800e5e:	83 39 01             	cmpl   $0x1,(%ecx)
  800e61:	74 58                	je     800ebb <argnext+0x7c>
		    || args->argv[1][0] != '-'
  800e63:	8b 53 04             	mov    0x4(%ebx),%edx
  800e66:	8b 42 04             	mov    0x4(%edx),%eax
  800e69:	80 38 2d             	cmpb   $0x2d,(%eax)
  800e6c:	75 4d                	jne    800ebb <argnext+0x7c>
		    || args->argv[1][1] == '\0')
  800e6e:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800e72:	74 47                	je     800ebb <argnext+0x7c>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  800e74:	83 c0 01             	add    $0x1,%eax
  800e77:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800e7a:	83 ec 04             	sub    $0x4,%esp
  800e7d:	8b 01                	mov    (%ecx),%eax
  800e7f:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  800e86:	50                   	push   %eax
  800e87:	8d 42 08             	lea    0x8(%edx),%eax
  800e8a:	50                   	push   %eax
  800e8b:	83 c2 04             	add    $0x4,%edx
  800e8e:	52                   	push   %edx
  800e8f:	e8 1f fb ff ff       	call   8009b3 <memmove>
		(*args->argc)--;
  800e94:	8b 03                	mov    (%ebx),%eax
  800e96:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  800e99:	8b 43 08             	mov    0x8(%ebx),%eax
  800e9c:	83 c4 10             	add    $0x10,%esp
  800e9f:	80 38 2d             	cmpb   $0x2d,(%eax)
  800ea2:	74 11                	je     800eb5 <argnext+0x76>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  800ea4:	8b 53 08             	mov    0x8(%ebx),%edx
  800ea7:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  800eaa:	83 c2 01             	add    $0x1,%edx
  800ead:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  800eb0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eb3:	c9                   	leave  
  800eb4:	c3                   	ret    
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  800eb5:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800eb9:	75 e9                	jne    800ea4 <argnext+0x65>
	args->curarg = 0;
  800ebb:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  800ec2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800ec7:	eb e7                	jmp    800eb0 <argnext+0x71>
		return -1;
  800ec9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800ece:	eb e0                	jmp    800eb0 <argnext+0x71>

00800ed0 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
  800ed3:	53                   	push   %ebx
  800ed4:	83 ec 04             	sub    $0x4,%esp
  800ed7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  800eda:	8b 43 08             	mov    0x8(%ebx),%eax
  800edd:	85 c0                	test   %eax,%eax
  800edf:	74 5b                	je     800f3c <argnextvalue+0x6c>
		return 0;
	if (*args->curarg) {
  800ee1:	80 38 00             	cmpb   $0x0,(%eax)
  800ee4:	74 12                	je     800ef8 <argnextvalue+0x28>
		args->argvalue = args->curarg;
  800ee6:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  800ee9:	c7 43 08 f1 20 80 00 	movl   $0x8020f1,0x8(%ebx)
		(*args->argc)--;
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
  800ef0:	8b 43 0c             	mov    0xc(%ebx),%eax
}
  800ef3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ef6:	c9                   	leave  
  800ef7:	c3                   	ret    
	} else if (*args->argc > 1) {
  800ef8:	8b 13                	mov    (%ebx),%edx
  800efa:	83 3a 01             	cmpl   $0x1,(%edx)
  800efd:	7f 10                	jg     800f0f <argnextvalue+0x3f>
		args->argvalue = 0;
  800eff:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  800f06:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  800f0d:	eb e1                	jmp    800ef0 <argnextvalue+0x20>
		args->argvalue = args->argv[1];
  800f0f:	8b 43 04             	mov    0x4(%ebx),%eax
  800f12:	8b 48 04             	mov    0x4(%eax),%ecx
  800f15:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800f18:	83 ec 04             	sub    $0x4,%esp
  800f1b:	8b 12                	mov    (%edx),%edx
  800f1d:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  800f24:	52                   	push   %edx
  800f25:	8d 50 08             	lea    0x8(%eax),%edx
  800f28:	52                   	push   %edx
  800f29:	83 c0 04             	add    $0x4,%eax
  800f2c:	50                   	push   %eax
  800f2d:	e8 81 fa ff ff       	call   8009b3 <memmove>
		(*args->argc)--;
  800f32:	8b 03                	mov    (%ebx),%eax
  800f34:	83 28 01             	subl   $0x1,(%eax)
  800f37:	83 c4 10             	add    $0x10,%esp
  800f3a:	eb b4                	jmp    800ef0 <argnextvalue+0x20>
		return 0;
  800f3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800f41:	eb b0                	jmp    800ef3 <argnextvalue+0x23>

00800f43 <argvalue>:
{
  800f43:	55                   	push   %ebp
  800f44:	89 e5                	mov    %esp,%ebp
  800f46:	83 ec 08             	sub    $0x8,%esp
  800f49:	8b 55 08             	mov    0x8(%ebp),%edx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  800f4c:	8b 42 0c             	mov    0xc(%edx),%eax
  800f4f:	85 c0                	test   %eax,%eax
  800f51:	74 02                	je     800f55 <argvalue+0x12>
}
  800f53:	c9                   	leave  
  800f54:	c3                   	ret    
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  800f55:	83 ec 0c             	sub    $0xc,%esp
  800f58:	52                   	push   %edx
  800f59:	e8 72 ff ff ff       	call   800ed0 <argnextvalue>
  800f5e:	83 c4 10             	add    $0x10,%esp
  800f61:	eb f0                	jmp    800f53 <argvalue+0x10>

00800f63 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f63:	55                   	push   %ebp
  800f64:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f66:	8b 45 08             	mov    0x8(%ebp),%eax
  800f69:	05 00 00 00 30       	add    $0x30000000,%eax
  800f6e:	c1 e8 0c             	shr    $0xc,%eax
}
  800f71:	5d                   	pop    %ebp
  800f72:	c3                   	ret    

00800f73 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f73:	55                   	push   %ebp
  800f74:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f76:	8b 45 08             	mov    0x8(%ebp),%eax
  800f79:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800f7e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f83:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f88:	5d                   	pop    %ebp
  800f89:	c3                   	ret    

00800f8a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f8a:	55                   	push   %ebp
  800f8b:	89 e5                	mov    %esp,%ebp
  800f8d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f90:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f95:	89 c2                	mov    %eax,%edx
  800f97:	c1 ea 16             	shr    $0x16,%edx
  800f9a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fa1:	f6 c2 01             	test   $0x1,%dl
  800fa4:	74 2a                	je     800fd0 <fd_alloc+0x46>
  800fa6:	89 c2                	mov    %eax,%edx
  800fa8:	c1 ea 0c             	shr    $0xc,%edx
  800fab:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fb2:	f6 c2 01             	test   $0x1,%dl
  800fb5:	74 19                	je     800fd0 <fd_alloc+0x46>
  800fb7:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800fbc:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800fc1:	75 d2                	jne    800f95 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800fc3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800fc9:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800fce:	eb 07                	jmp    800fd7 <fd_alloc+0x4d>
			*fd_store = fd;
  800fd0:	89 01                	mov    %eax,(%ecx)
			return 0;
  800fd2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fd7:	5d                   	pop    %ebp
  800fd8:	c3                   	ret    

00800fd9 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800fd9:	55                   	push   %ebp
  800fda:	89 e5                	mov    %esp,%ebp
  800fdc:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800fdf:	83 f8 1f             	cmp    $0x1f,%eax
  800fe2:	77 36                	ja     80101a <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800fe4:	c1 e0 0c             	shl    $0xc,%eax
  800fe7:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800fec:	89 c2                	mov    %eax,%edx
  800fee:	c1 ea 16             	shr    $0x16,%edx
  800ff1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ff8:	f6 c2 01             	test   $0x1,%dl
  800ffb:	74 24                	je     801021 <fd_lookup+0x48>
  800ffd:	89 c2                	mov    %eax,%edx
  800fff:	c1 ea 0c             	shr    $0xc,%edx
  801002:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801009:	f6 c2 01             	test   $0x1,%dl
  80100c:	74 1a                	je     801028 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80100e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801011:	89 02                	mov    %eax,(%edx)
	return 0;
  801013:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801018:	5d                   	pop    %ebp
  801019:	c3                   	ret    
		return -E_INVAL;
  80101a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80101f:	eb f7                	jmp    801018 <fd_lookup+0x3f>
		return -E_INVAL;
  801021:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801026:	eb f0                	jmp    801018 <fd_lookup+0x3f>
  801028:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80102d:	eb e9                	jmp    801018 <fd_lookup+0x3f>

0080102f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80102f:	55                   	push   %ebp
  801030:	89 e5                	mov    %esp,%ebp
  801032:	83 ec 08             	sub    $0x8,%esp
  801035:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801038:	ba c8 24 80 00       	mov    $0x8024c8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80103d:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  801042:	39 08                	cmp    %ecx,(%eax)
  801044:	74 33                	je     801079 <dev_lookup+0x4a>
  801046:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  801049:	8b 02                	mov    (%edx),%eax
  80104b:	85 c0                	test   %eax,%eax
  80104d:	75 f3                	jne    801042 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80104f:	a1 04 40 80 00       	mov    0x804004,%eax
  801054:	8b 40 48             	mov    0x48(%eax),%eax
  801057:	83 ec 04             	sub    $0x4,%esp
  80105a:	51                   	push   %ecx
  80105b:	50                   	push   %eax
  80105c:	68 4c 24 80 00       	push   $0x80244c
  801061:	e8 a0 f1 ff ff       	call   800206 <cprintf>
	*dev = 0;
  801066:	8b 45 0c             	mov    0xc(%ebp),%eax
  801069:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80106f:	83 c4 10             	add    $0x10,%esp
  801072:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801077:	c9                   	leave  
  801078:	c3                   	ret    
			*dev = devtab[i];
  801079:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80107c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80107e:	b8 00 00 00 00       	mov    $0x0,%eax
  801083:	eb f2                	jmp    801077 <dev_lookup+0x48>

00801085 <fd_close>:
{
  801085:	55                   	push   %ebp
  801086:	89 e5                	mov    %esp,%ebp
  801088:	57                   	push   %edi
  801089:	56                   	push   %esi
  80108a:	53                   	push   %ebx
  80108b:	83 ec 1c             	sub    $0x1c,%esp
  80108e:	8b 75 08             	mov    0x8(%ebp),%esi
  801091:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801094:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801097:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801098:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80109e:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8010a1:	50                   	push   %eax
  8010a2:	e8 32 ff ff ff       	call   800fd9 <fd_lookup>
  8010a7:	89 c3                	mov    %eax,%ebx
  8010a9:	83 c4 08             	add    $0x8,%esp
  8010ac:	85 c0                	test   %eax,%eax
  8010ae:	78 05                	js     8010b5 <fd_close+0x30>
	    || fd != fd2)
  8010b0:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8010b3:	74 16                	je     8010cb <fd_close+0x46>
		return (must_exist ? r : 0);
  8010b5:	89 f8                	mov    %edi,%eax
  8010b7:	84 c0                	test   %al,%al
  8010b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8010be:	0f 44 d8             	cmove  %eax,%ebx
}
  8010c1:	89 d8                	mov    %ebx,%eax
  8010c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010c6:	5b                   	pop    %ebx
  8010c7:	5e                   	pop    %esi
  8010c8:	5f                   	pop    %edi
  8010c9:	5d                   	pop    %ebp
  8010ca:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8010cb:	83 ec 08             	sub    $0x8,%esp
  8010ce:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8010d1:	50                   	push   %eax
  8010d2:	ff 36                	pushl  (%esi)
  8010d4:	e8 56 ff ff ff       	call   80102f <dev_lookup>
  8010d9:	89 c3                	mov    %eax,%ebx
  8010db:	83 c4 10             	add    $0x10,%esp
  8010de:	85 c0                	test   %eax,%eax
  8010e0:	78 15                	js     8010f7 <fd_close+0x72>
		if (dev->dev_close)
  8010e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8010e5:	8b 40 10             	mov    0x10(%eax),%eax
  8010e8:	85 c0                	test   %eax,%eax
  8010ea:	74 1b                	je     801107 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  8010ec:	83 ec 0c             	sub    $0xc,%esp
  8010ef:	56                   	push   %esi
  8010f0:	ff d0                	call   *%eax
  8010f2:	89 c3                	mov    %eax,%ebx
  8010f4:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8010f7:	83 ec 08             	sub    $0x8,%esp
  8010fa:	56                   	push   %esi
  8010fb:	6a 00                	push   $0x0
  8010fd:	e8 a1 fb ff ff       	call   800ca3 <sys_page_unmap>
	return r;
  801102:	83 c4 10             	add    $0x10,%esp
  801105:	eb ba                	jmp    8010c1 <fd_close+0x3c>
			r = 0;
  801107:	bb 00 00 00 00       	mov    $0x0,%ebx
  80110c:	eb e9                	jmp    8010f7 <fd_close+0x72>

0080110e <close>:

int
close(int fdnum)
{
  80110e:	55                   	push   %ebp
  80110f:	89 e5                	mov    %esp,%ebp
  801111:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801114:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801117:	50                   	push   %eax
  801118:	ff 75 08             	pushl  0x8(%ebp)
  80111b:	e8 b9 fe ff ff       	call   800fd9 <fd_lookup>
  801120:	83 c4 08             	add    $0x8,%esp
  801123:	85 c0                	test   %eax,%eax
  801125:	78 10                	js     801137 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801127:	83 ec 08             	sub    $0x8,%esp
  80112a:	6a 01                	push   $0x1
  80112c:	ff 75 f4             	pushl  -0xc(%ebp)
  80112f:	e8 51 ff ff ff       	call   801085 <fd_close>
  801134:	83 c4 10             	add    $0x10,%esp
}
  801137:	c9                   	leave  
  801138:	c3                   	ret    

00801139 <close_all>:

void
close_all(void)
{
  801139:	55                   	push   %ebp
  80113a:	89 e5                	mov    %esp,%ebp
  80113c:	53                   	push   %ebx
  80113d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801140:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801145:	83 ec 0c             	sub    $0xc,%esp
  801148:	53                   	push   %ebx
  801149:	e8 c0 ff ff ff       	call   80110e <close>
	for (i = 0; i < MAXFD; i++)
  80114e:	83 c3 01             	add    $0x1,%ebx
  801151:	83 c4 10             	add    $0x10,%esp
  801154:	83 fb 20             	cmp    $0x20,%ebx
  801157:	75 ec                	jne    801145 <close_all+0xc>
}
  801159:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80115c:	c9                   	leave  
  80115d:	c3                   	ret    

0080115e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80115e:	55                   	push   %ebp
  80115f:	89 e5                	mov    %esp,%ebp
  801161:	57                   	push   %edi
  801162:	56                   	push   %esi
  801163:	53                   	push   %ebx
  801164:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801167:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80116a:	50                   	push   %eax
  80116b:	ff 75 08             	pushl  0x8(%ebp)
  80116e:	e8 66 fe ff ff       	call   800fd9 <fd_lookup>
  801173:	89 c3                	mov    %eax,%ebx
  801175:	83 c4 08             	add    $0x8,%esp
  801178:	85 c0                	test   %eax,%eax
  80117a:	0f 88 81 00 00 00    	js     801201 <dup+0xa3>
		return r;
	close(newfdnum);
  801180:	83 ec 0c             	sub    $0xc,%esp
  801183:	ff 75 0c             	pushl  0xc(%ebp)
  801186:	e8 83 ff ff ff       	call   80110e <close>

	newfd = INDEX2FD(newfdnum);
  80118b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80118e:	c1 e6 0c             	shl    $0xc,%esi
  801191:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801197:	83 c4 04             	add    $0x4,%esp
  80119a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80119d:	e8 d1 fd ff ff       	call   800f73 <fd2data>
  8011a2:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8011a4:	89 34 24             	mov    %esi,(%esp)
  8011a7:	e8 c7 fd ff ff       	call   800f73 <fd2data>
  8011ac:	83 c4 10             	add    $0x10,%esp
  8011af:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8011b1:	89 d8                	mov    %ebx,%eax
  8011b3:	c1 e8 16             	shr    $0x16,%eax
  8011b6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011bd:	a8 01                	test   $0x1,%al
  8011bf:	74 11                	je     8011d2 <dup+0x74>
  8011c1:	89 d8                	mov    %ebx,%eax
  8011c3:	c1 e8 0c             	shr    $0xc,%eax
  8011c6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011cd:	f6 c2 01             	test   $0x1,%dl
  8011d0:	75 39                	jne    80120b <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011d2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8011d5:	89 d0                	mov    %edx,%eax
  8011d7:	c1 e8 0c             	shr    $0xc,%eax
  8011da:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011e1:	83 ec 0c             	sub    $0xc,%esp
  8011e4:	25 07 0e 00 00       	and    $0xe07,%eax
  8011e9:	50                   	push   %eax
  8011ea:	56                   	push   %esi
  8011eb:	6a 00                	push   $0x0
  8011ed:	52                   	push   %edx
  8011ee:	6a 00                	push   $0x0
  8011f0:	e8 6c fa ff ff       	call   800c61 <sys_page_map>
  8011f5:	89 c3                	mov    %eax,%ebx
  8011f7:	83 c4 20             	add    $0x20,%esp
  8011fa:	85 c0                	test   %eax,%eax
  8011fc:	78 31                	js     80122f <dup+0xd1>
		goto err;

	return newfdnum;
  8011fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801201:	89 d8                	mov    %ebx,%eax
  801203:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801206:	5b                   	pop    %ebx
  801207:	5e                   	pop    %esi
  801208:	5f                   	pop    %edi
  801209:	5d                   	pop    %ebp
  80120a:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80120b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801212:	83 ec 0c             	sub    $0xc,%esp
  801215:	25 07 0e 00 00       	and    $0xe07,%eax
  80121a:	50                   	push   %eax
  80121b:	57                   	push   %edi
  80121c:	6a 00                	push   $0x0
  80121e:	53                   	push   %ebx
  80121f:	6a 00                	push   $0x0
  801221:	e8 3b fa ff ff       	call   800c61 <sys_page_map>
  801226:	89 c3                	mov    %eax,%ebx
  801228:	83 c4 20             	add    $0x20,%esp
  80122b:	85 c0                	test   %eax,%eax
  80122d:	79 a3                	jns    8011d2 <dup+0x74>
	sys_page_unmap(0, newfd);
  80122f:	83 ec 08             	sub    $0x8,%esp
  801232:	56                   	push   %esi
  801233:	6a 00                	push   $0x0
  801235:	e8 69 fa ff ff       	call   800ca3 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80123a:	83 c4 08             	add    $0x8,%esp
  80123d:	57                   	push   %edi
  80123e:	6a 00                	push   $0x0
  801240:	e8 5e fa ff ff       	call   800ca3 <sys_page_unmap>
	return r;
  801245:	83 c4 10             	add    $0x10,%esp
  801248:	eb b7                	jmp    801201 <dup+0xa3>

0080124a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80124a:	55                   	push   %ebp
  80124b:	89 e5                	mov    %esp,%ebp
  80124d:	53                   	push   %ebx
  80124e:	83 ec 14             	sub    $0x14,%esp
  801251:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801254:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801257:	50                   	push   %eax
  801258:	53                   	push   %ebx
  801259:	e8 7b fd ff ff       	call   800fd9 <fd_lookup>
  80125e:	83 c4 08             	add    $0x8,%esp
  801261:	85 c0                	test   %eax,%eax
  801263:	78 3f                	js     8012a4 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801265:	83 ec 08             	sub    $0x8,%esp
  801268:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80126b:	50                   	push   %eax
  80126c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80126f:	ff 30                	pushl  (%eax)
  801271:	e8 b9 fd ff ff       	call   80102f <dev_lookup>
  801276:	83 c4 10             	add    $0x10,%esp
  801279:	85 c0                	test   %eax,%eax
  80127b:	78 27                	js     8012a4 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80127d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801280:	8b 42 08             	mov    0x8(%edx),%eax
  801283:	83 e0 03             	and    $0x3,%eax
  801286:	83 f8 01             	cmp    $0x1,%eax
  801289:	74 1e                	je     8012a9 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80128b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80128e:	8b 40 08             	mov    0x8(%eax),%eax
  801291:	85 c0                	test   %eax,%eax
  801293:	74 35                	je     8012ca <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801295:	83 ec 04             	sub    $0x4,%esp
  801298:	ff 75 10             	pushl  0x10(%ebp)
  80129b:	ff 75 0c             	pushl  0xc(%ebp)
  80129e:	52                   	push   %edx
  80129f:	ff d0                	call   *%eax
  8012a1:	83 c4 10             	add    $0x10,%esp
}
  8012a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a7:	c9                   	leave  
  8012a8:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8012a9:	a1 04 40 80 00       	mov    0x804004,%eax
  8012ae:	8b 40 48             	mov    0x48(%eax),%eax
  8012b1:	83 ec 04             	sub    $0x4,%esp
  8012b4:	53                   	push   %ebx
  8012b5:	50                   	push   %eax
  8012b6:	68 8d 24 80 00       	push   $0x80248d
  8012bb:	e8 46 ef ff ff       	call   800206 <cprintf>
		return -E_INVAL;
  8012c0:	83 c4 10             	add    $0x10,%esp
  8012c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012c8:	eb da                	jmp    8012a4 <read+0x5a>
		return -E_NOT_SUPP;
  8012ca:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012cf:	eb d3                	jmp    8012a4 <read+0x5a>

008012d1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8012d1:	55                   	push   %ebp
  8012d2:	89 e5                	mov    %esp,%ebp
  8012d4:	57                   	push   %edi
  8012d5:	56                   	push   %esi
  8012d6:	53                   	push   %ebx
  8012d7:	83 ec 0c             	sub    $0xc,%esp
  8012da:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012dd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012e0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012e5:	39 f3                	cmp    %esi,%ebx
  8012e7:	73 25                	jae    80130e <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012e9:	83 ec 04             	sub    $0x4,%esp
  8012ec:	89 f0                	mov    %esi,%eax
  8012ee:	29 d8                	sub    %ebx,%eax
  8012f0:	50                   	push   %eax
  8012f1:	89 d8                	mov    %ebx,%eax
  8012f3:	03 45 0c             	add    0xc(%ebp),%eax
  8012f6:	50                   	push   %eax
  8012f7:	57                   	push   %edi
  8012f8:	e8 4d ff ff ff       	call   80124a <read>
		if (m < 0)
  8012fd:	83 c4 10             	add    $0x10,%esp
  801300:	85 c0                	test   %eax,%eax
  801302:	78 08                	js     80130c <readn+0x3b>
			return m;
		if (m == 0)
  801304:	85 c0                	test   %eax,%eax
  801306:	74 06                	je     80130e <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  801308:	01 c3                	add    %eax,%ebx
  80130a:	eb d9                	jmp    8012e5 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80130c:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80130e:	89 d8                	mov    %ebx,%eax
  801310:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801313:	5b                   	pop    %ebx
  801314:	5e                   	pop    %esi
  801315:	5f                   	pop    %edi
  801316:	5d                   	pop    %ebp
  801317:	c3                   	ret    

00801318 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801318:	55                   	push   %ebp
  801319:	89 e5                	mov    %esp,%ebp
  80131b:	53                   	push   %ebx
  80131c:	83 ec 14             	sub    $0x14,%esp
  80131f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801322:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801325:	50                   	push   %eax
  801326:	53                   	push   %ebx
  801327:	e8 ad fc ff ff       	call   800fd9 <fd_lookup>
  80132c:	83 c4 08             	add    $0x8,%esp
  80132f:	85 c0                	test   %eax,%eax
  801331:	78 3a                	js     80136d <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801333:	83 ec 08             	sub    $0x8,%esp
  801336:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801339:	50                   	push   %eax
  80133a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80133d:	ff 30                	pushl  (%eax)
  80133f:	e8 eb fc ff ff       	call   80102f <dev_lookup>
  801344:	83 c4 10             	add    $0x10,%esp
  801347:	85 c0                	test   %eax,%eax
  801349:	78 22                	js     80136d <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80134b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80134e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801352:	74 1e                	je     801372 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801354:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801357:	8b 52 0c             	mov    0xc(%edx),%edx
  80135a:	85 d2                	test   %edx,%edx
  80135c:	74 35                	je     801393 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80135e:	83 ec 04             	sub    $0x4,%esp
  801361:	ff 75 10             	pushl  0x10(%ebp)
  801364:	ff 75 0c             	pushl  0xc(%ebp)
  801367:	50                   	push   %eax
  801368:	ff d2                	call   *%edx
  80136a:	83 c4 10             	add    $0x10,%esp
}
  80136d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801370:	c9                   	leave  
  801371:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801372:	a1 04 40 80 00       	mov    0x804004,%eax
  801377:	8b 40 48             	mov    0x48(%eax),%eax
  80137a:	83 ec 04             	sub    $0x4,%esp
  80137d:	53                   	push   %ebx
  80137e:	50                   	push   %eax
  80137f:	68 a9 24 80 00       	push   $0x8024a9
  801384:	e8 7d ee ff ff       	call   800206 <cprintf>
		return -E_INVAL;
  801389:	83 c4 10             	add    $0x10,%esp
  80138c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801391:	eb da                	jmp    80136d <write+0x55>
		return -E_NOT_SUPP;
  801393:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801398:	eb d3                	jmp    80136d <write+0x55>

0080139a <seek>:

int
seek(int fdnum, off_t offset)
{
  80139a:	55                   	push   %ebp
  80139b:	89 e5                	mov    %esp,%ebp
  80139d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013a0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8013a3:	50                   	push   %eax
  8013a4:	ff 75 08             	pushl  0x8(%ebp)
  8013a7:	e8 2d fc ff ff       	call   800fd9 <fd_lookup>
  8013ac:	83 c4 08             	add    $0x8,%esp
  8013af:	85 c0                	test   %eax,%eax
  8013b1:	78 0e                	js     8013c1 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8013b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8013b9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8013bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013c1:	c9                   	leave  
  8013c2:	c3                   	ret    

008013c3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8013c3:	55                   	push   %ebp
  8013c4:	89 e5                	mov    %esp,%ebp
  8013c6:	53                   	push   %ebx
  8013c7:	83 ec 14             	sub    $0x14,%esp
  8013ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013d0:	50                   	push   %eax
  8013d1:	53                   	push   %ebx
  8013d2:	e8 02 fc ff ff       	call   800fd9 <fd_lookup>
  8013d7:	83 c4 08             	add    $0x8,%esp
  8013da:	85 c0                	test   %eax,%eax
  8013dc:	78 37                	js     801415 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013de:	83 ec 08             	sub    $0x8,%esp
  8013e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013e4:	50                   	push   %eax
  8013e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013e8:	ff 30                	pushl  (%eax)
  8013ea:	e8 40 fc ff ff       	call   80102f <dev_lookup>
  8013ef:	83 c4 10             	add    $0x10,%esp
  8013f2:	85 c0                	test   %eax,%eax
  8013f4:	78 1f                	js     801415 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013f9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013fd:	74 1b                	je     80141a <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8013ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801402:	8b 52 18             	mov    0x18(%edx),%edx
  801405:	85 d2                	test   %edx,%edx
  801407:	74 32                	je     80143b <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801409:	83 ec 08             	sub    $0x8,%esp
  80140c:	ff 75 0c             	pushl  0xc(%ebp)
  80140f:	50                   	push   %eax
  801410:	ff d2                	call   *%edx
  801412:	83 c4 10             	add    $0x10,%esp
}
  801415:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801418:	c9                   	leave  
  801419:	c3                   	ret    
			thisenv->env_id, fdnum);
  80141a:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80141f:	8b 40 48             	mov    0x48(%eax),%eax
  801422:	83 ec 04             	sub    $0x4,%esp
  801425:	53                   	push   %ebx
  801426:	50                   	push   %eax
  801427:	68 6c 24 80 00       	push   $0x80246c
  80142c:	e8 d5 ed ff ff       	call   800206 <cprintf>
		return -E_INVAL;
  801431:	83 c4 10             	add    $0x10,%esp
  801434:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801439:	eb da                	jmp    801415 <ftruncate+0x52>
		return -E_NOT_SUPP;
  80143b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801440:	eb d3                	jmp    801415 <ftruncate+0x52>

00801442 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801442:	55                   	push   %ebp
  801443:	89 e5                	mov    %esp,%ebp
  801445:	53                   	push   %ebx
  801446:	83 ec 14             	sub    $0x14,%esp
  801449:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80144c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80144f:	50                   	push   %eax
  801450:	ff 75 08             	pushl  0x8(%ebp)
  801453:	e8 81 fb ff ff       	call   800fd9 <fd_lookup>
  801458:	83 c4 08             	add    $0x8,%esp
  80145b:	85 c0                	test   %eax,%eax
  80145d:	78 4b                	js     8014aa <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80145f:	83 ec 08             	sub    $0x8,%esp
  801462:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801465:	50                   	push   %eax
  801466:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801469:	ff 30                	pushl  (%eax)
  80146b:	e8 bf fb ff ff       	call   80102f <dev_lookup>
  801470:	83 c4 10             	add    $0x10,%esp
  801473:	85 c0                	test   %eax,%eax
  801475:	78 33                	js     8014aa <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  801477:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80147a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80147e:	74 2f                	je     8014af <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801480:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801483:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80148a:	00 00 00 
	stat->st_isdir = 0;
  80148d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801494:	00 00 00 
	stat->st_dev = dev;
  801497:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80149d:	83 ec 08             	sub    $0x8,%esp
  8014a0:	53                   	push   %ebx
  8014a1:	ff 75 f0             	pushl  -0x10(%ebp)
  8014a4:	ff 50 14             	call   *0x14(%eax)
  8014a7:	83 c4 10             	add    $0x10,%esp
}
  8014aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014ad:	c9                   	leave  
  8014ae:	c3                   	ret    
		return -E_NOT_SUPP;
  8014af:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014b4:	eb f4                	jmp    8014aa <fstat+0x68>

008014b6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8014b6:	55                   	push   %ebp
  8014b7:	89 e5                	mov    %esp,%ebp
  8014b9:	56                   	push   %esi
  8014ba:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8014bb:	83 ec 08             	sub    $0x8,%esp
  8014be:	6a 00                	push   $0x0
  8014c0:	ff 75 08             	pushl  0x8(%ebp)
  8014c3:	e8 da 01 00 00       	call   8016a2 <open>
  8014c8:	89 c3                	mov    %eax,%ebx
  8014ca:	83 c4 10             	add    $0x10,%esp
  8014cd:	85 c0                	test   %eax,%eax
  8014cf:	78 1b                	js     8014ec <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8014d1:	83 ec 08             	sub    $0x8,%esp
  8014d4:	ff 75 0c             	pushl  0xc(%ebp)
  8014d7:	50                   	push   %eax
  8014d8:	e8 65 ff ff ff       	call   801442 <fstat>
  8014dd:	89 c6                	mov    %eax,%esi
	close(fd);
  8014df:	89 1c 24             	mov    %ebx,(%esp)
  8014e2:	e8 27 fc ff ff       	call   80110e <close>
	return r;
  8014e7:	83 c4 10             	add    $0x10,%esp
  8014ea:	89 f3                	mov    %esi,%ebx
}
  8014ec:	89 d8                	mov    %ebx,%eax
  8014ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014f1:	5b                   	pop    %ebx
  8014f2:	5e                   	pop    %esi
  8014f3:	5d                   	pop    %ebp
  8014f4:	c3                   	ret    

008014f5 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014f5:	55                   	push   %ebp
  8014f6:	89 e5                	mov    %esp,%ebp
  8014f8:	56                   	push   %esi
  8014f9:	53                   	push   %ebx
  8014fa:	89 c6                	mov    %eax,%esi
  8014fc:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8014fe:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801505:	74 27                	je     80152e <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801507:	6a 07                	push   $0x7
  801509:	68 00 50 80 00       	push   $0x805000
  80150e:	56                   	push   %esi
  80150f:	ff 35 00 40 80 00    	pushl  0x804000
  801515:	e8 b9 08 00 00       	call   801dd3 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80151a:	83 c4 0c             	add    $0xc,%esp
  80151d:	6a 00                	push   $0x0
  80151f:	53                   	push   %ebx
  801520:	6a 00                	push   $0x0
  801522:	e8 45 08 00 00       	call   801d6c <ipc_recv>
}
  801527:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80152a:	5b                   	pop    %ebx
  80152b:	5e                   	pop    %esi
  80152c:	5d                   	pop    %ebp
  80152d:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80152e:	83 ec 0c             	sub    $0xc,%esp
  801531:	6a 01                	push   $0x1
  801533:	e8 ef 08 00 00       	call   801e27 <ipc_find_env>
  801538:	a3 00 40 80 00       	mov    %eax,0x804000
  80153d:	83 c4 10             	add    $0x10,%esp
  801540:	eb c5                	jmp    801507 <fsipc+0x12>

00801542 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801542:	55                   	push   %ebp
  801543:	89 e5                	mov    %esp,%ebp
  801545:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801548:	8b 45 08             	mov    0x8(%ebp),%eax
  80154b:	8b 40 0c             	mov    0xc(%eax),%eax
  80154e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801553:	8b 45 0c             	mov    0xc(%ebp),%eax
  801556:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80155b:	ba 00 00 00 00       	mov    $0x0,%edx
  801560:	b8 02 00 00 00       	mov    $0x2,%eax
  801565:	e8 8b ff ff ff       	call   8014f5 <fsipc>
}
  80156a:	c9                   	leave  
  80156b:	c3                   	ret    

0080156c <devfile_flush>:
{
  80156c:	55                   	push   %ebp
  80156d:	89 e5                	mov    %esp,%ebp
  80156f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801572:	8b 45 08             	mov    0x8(%ebp),%eax
  801575:	8b 40 0c             	mov    0xc(%eax),%eax
  801578:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80157d:	ba 00 00 00 00       	mov    $0x0,%edx
  801582:	b8 06 00 00 00       	mov    $0x6,%eax
  801587:	e8 69 ff ff ff       	call   8014f5 <fsipc>
}
  80158c:	c9                   	leave  
  80158d:	c3                   	ret    

0080158e <devfile_stat>:
{
  80158e:	55                   	push   %ebp
  80158f:	89 e5                	mov    %esp,%ebp
  801591:	53                   	push   %ebx
  801592:	83 ec 04             	sub    $0x4,%esp
  801595:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801598:	8b 45 08             	mov    0x8(%ebp),%eax
  80159b:	8b 40 0c             	mov    0xc(%eax),%eax
  80159e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8015a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8015a8:	b8 05 00 00 00       	mov    $0x5,%eax
  8015ad:	e8 43 ff ff ff       	call   8014f5 <fsipc>
  8015b2:	85 c0                	test   %eax,%eax
  8015b4:	78 2c                	js     8015e2 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8015b6:	83 ec 08             	sub    $0x8,%esp
  8015b9:	68 00 50 80 00       	push   $0x805000
  8015be:	53                   	push   %ebx
  8015bf:	e8 61 f2 ff ff       	call   800825 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8015c4:	a1 80 50 80 00       	mov    0x805080,%eax
  8015c9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8015cf:	a1 84 50 80 00       	mov    0x805084,%eax
  8015d4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8015da:	83 c4 10             	add    $0x10,%esp
  8015dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015e5:	c9                   	leave  
  8015e6:	c3                   	ret    

008015e7 <devfile_write>:
{
  8015e7:	55                   	push   %ebp
  8015e8:	89 e5                	mov    %esp,%ebp
  8015ea:	83 ec 0c             	sub    $0xc,%esp
  8015ed:	8b 45 10             	mov    0x10(%ebp),%eax
    	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8015f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8015f3:	8b 52 0c             	mov    0xc(%edx),%edx
  8015f6:	89 15 00 50 80 00    	mov    %edx,0x805000
    	fsipcbuf.write.req_n = n;
  8015fc:	a3 04 50 80 00       	mov    %eax,0x805004
    	memmove(fsipcbuf.write.req_buf, buf, n);
  801601:	50                   	push   %eax
  801602:	ff 75 0c             	pushl  0xc(%ebp)
  801605:	68 08 50 80 00       	push   $0x805008
  80160a:	e8 a4 f3 ff ff       	call   8009b3 <memmove>
    	return fsipc(FSREQ_WRITE, NULL);
  80160f:	ba 00 00 00 00       	mov    $0x0,%edx
  801614:	b8 04 00 00 00       	mov    $0x4,%eax
  801619:	e8 d7 fe ff ff       	call   8014f5 <fsipc>
}
  80161e:	c9                   	leave  
  80161f:	c3                   	ret    

00801620 <devfile_read>:
{
  801620:	55                   	push   %ebp
  801621:	89 e5                	mov    %esp,%ebp
  801623:	56                   	push   %esi
  801624:	53                   	push   %ebx
  801625:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801628:	8b 45 08             	mov    0x8(%ebp),%eax
  80162b:	8b 40 0c             	mov    0xc(%eax),%eax
  80162e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801633:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801639:	ba 00 00 00 00       	mov    $0x0,%edx
  80163e:	b8 03 00 00 00       	mov    $0x3,%eax
  801643:	e8 ad fe ff ff       	call   8014f5 <fsipc>
  801648:	89 c3                	mov    %eax,%ebx
  80164a:	85 c0                	test   %eax,%eax
  80164c:	78 1f                	js     80166d <devfile_read+0x4d>
	assert(r <= n);
  80164e:	39 f0                	cmp    %esi,%eax
  801650:	77 24                	ja     801676 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801652:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801657:	7f 33                	jg     80168c <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801659:	83 ec 04             	sub    $0x4,%esp
  80165c:	50                   	push   %eax
  80165d:	68 00 50 80 00       	push   $0x805000
  801662:	ff 75 0c             	pushl  0xc(%ebp)
  801665:	e8 49 f3 ff ff       	call   8009b3 <memmove>
	return r;
  80166a:	83 c4 10             	add    $0x10,%esp
}
  80166d:	89 d8                	mov    %ebx,%eax
  80166f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801672:	5b                   	pop    %ebx
  801673:	5e                   	pop    %esi
  801674:	5d                   	pop    %ebp
  801675:	c3                   	ret    
	assert(r <= n);
  801676:	68 d8 24 80 00       	push   $0x8024d8
  80167b:	68 df 24 80 00       	push   $0x8024df
  801680:	6a 7c                	push   $0x7c
  801682:	68 f4 24 80 00       	push   $0x8024f4
  801687:	e8 9a 06 00 00       	call   801d26 <_panic>
	assert(r <= PGSIZE);
  80168c:	68 ff 24 80 00       	push   $0x8024ff
  801691:	68 df 24 80 00       	push   $0x8024df
  801696:	6a 7d                	push   $0x7d
  801698:	68 f4 24 80 00       	push   $0x8024f4
  80169d:	e8 84 06 00 00       	call   801d26 <_panic>

008016a2 <open>:
{
  8016a2:	55                   	push   %ebp
  8016a3:	89 e5                	mov    %esp,%ebp
  8016a5:	56                   	push   %esi
  8016a6:	53                   	push   %ebx
  8016a7:	83 ec 1c             	sub    $0x1c,%esp
  8016aa:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8016ad:	56                   	push   %esi
  8016ae:	e8 3b f1 ff ff       	call   8007ee <strlen>
  8016b3:	83 c4 10             	add    $0x10,%esp
  8016b6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8016bb:	7f 6c                	jg     801729 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8016bd:	83 ec 0c             	sub    $0xc,%esp
  8016c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016c3:	50                   	push   %eax
  8016c4:	e8 c1 f8 ff ff       	call   800f8a <fd_alloc>
  8016c9:	89 c3                	mov    %eax,%ebx
  8016cb:	83 c4 10             	add    $0x10,%esp
  8016ce:	85 c0                	test   %eax,%eax
  8016d0:	78 3c                	js     80170e <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8016d2:	83 ec 08             	sub    $0x8,%esp
  8016d5:	56                   	push   %esi
  8016d6:	68 00 50 80 00       	push   $0x805000
  8016db:	e8 45 f1 ff ff       	call   800825 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8016e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016e3:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8016e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016eb:	b8 01 00 00 00       	mov    $0x1,%eax
  8016f0:	e8 00 fe ff ff       	call   8014f5 <fsipc>
  8016f5:	89 c3                	mov    %eax,%ebx
  8016f7:	83 c4 10             	add    $0x10,%esp
  8016fa:	85 c0                	test   %eax,%eax
  8016fc:	78 19                	js     801717 <open+0x75>
	return fd2num(fd);
  8016fe:	83 ec 0c             	sub    $0xc,%esp
  801701:	ff 75 f4             	pushl  -0xc(%ebp)
  801704:	e8 5a f8 ff ff       	call   800f63 <fd2num>
  801709:	89 c3                	mov    %eax,%ebx
  80170b:	83 c4 10             	add    $0x10,%esp
}
  80170e:	89 d8                	mov    %ebx,%eax
  801710:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801713:	5b                   	pop    %ebx
  801714:	5e                   	pop    %esi
  801715:	5d                   	pop    %ebp
  801716:	c3                   	ret    
		fd_close(fd, 0);
  801717:	83 ec 08             	sub    $0x8,%esp
  80171a:	6a 00                	push   $0x0
  80171c:	ff 75 f4             	pushl  -0xc(%ebp)
  80171f:	e8 61 f9 ff ff       	call   801085 <fd_close>
		return r;
  801724:	83 c4 10             	add    $0x10,%esp
  801727:	eb e5                	jmp    80170e <open+0x6c>
		return -E_BAD_PATH;
  801729:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80172e:	eb de                	jmp    80170e <open+0x6c>

00801730 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801730:	55                   	push   %ebp
  801731:	89 e5                	mov    %esp,%ebp
  801733:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801736:	ba 00 00 00 00       	mov    $0x0,%edx
  80173b:	b8 08 00 00 00       	mov    $0x8,%eax
  801740:	e8 b0 fd ff ff       	call   8014f5 <fsipc>
}
  801745:	c9                   	leave  
  801746:	c3                   	ret    

00801747 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801747:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80174b:	7e 38                	jle    801785 <writebuf+0x3e>
{
  80174d:	55                   	push   %ebp
  80174e:	89 e5                	mov    %esp,%ebp
  801750:	53                   	push   %ebx
  801751:	83 ec 08             	sub    $0x8,%esp
  801754:	89 c3                	mov    %eax,%ebx
		ssize_t result = write(b->fd, b->buf, b->idx);
  801756:	ff 70 04             	pushl  0x4(%eax)
  801759:	8d 40 10             	lea    0x10(%eax),%eax
  80175c:	50                   	push   %eax
  80175d:	ff 33                	pushl  (%ebx)
  80175f:	e8 b4 fb ff ff       	call   801318 <write>
		if (result > 0)
  801764:	83 c4 10             	add    $0x10,%esp
  801767:	85 c0                	test   %eax,%eax
  801769:	7e 03                	jle    80176e <writebuf+0x27>
			b->result += result;
  80176b:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80176e:	39 43 04             	cmp    %eax,0x4(%ebx)
  801771:	74 0d                	je     801780 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  801773:	85 c0                	test   %eax,%eax
  801775:	ba 00 00 00 00       	mov    $0x0,%edx
  80177a:	0f 4f c2             	cmovg  %edx,%eax
  80177d:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801780:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801783:	c9                   	leave  
  801784:	c3                   	ret    
  801785:	f3 c3                	repz ret 

00801787 <putch>:

static void
putch(int ch, void *thunk)
{
  801787:	55                   	push   %ebp
  801788:	89 e5                	mov    %esp,%ebp
  80178a:	53                   	push   %ebx
  80178b:	83 ec 04             	sub    $0x4,%esp
  80178e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801791:	8b 53 04             	mov    0x4(%ebx),%edx
  801794:	8d 42 01             	lea    0x1(%edx),%eax
  801797:	89 43 04             	mov    %eax,0x4(%ebx)
  80179a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80179d:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8017a1:	3d 00 01 00 00       	cmp    $0x100,%eax
  8017a6:	74 06                	je     8017ae <putch+0x27>
		writebuf(b);
		b->idx = 0;
	}
}
  8017a8:	83 c4 04             	add    $0x4,%esp
  8017ab:	5b                   	pop    %ebx
  8017ac:	5d                   	pop    %ebp
  8017ad:	c3                   	ret    
		writebuf(b);
  8017ae:	89 d8                	mov    %ebx,%eax
  8017b0:	e8 92 ff ff ff       	call   801747 <writebuf>
		b->idx = 0;
  8017b5:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
}
  8017bc:	eb ea                	jmp    8017a8 <putch+0x21>

008017be <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8017be:	55                   	push   %ebp
  8017bf:	89 e5                	mov    %esp,%ebp
  8017c1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8017c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ca:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8017d0:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8017d7:	00 00 00 
	b.result = 0;
  8017da:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8017e1:	00 00 00 
	b.error = 1;
  8017e4:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8017eb:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8017ee:	ff 75 10             	pushl  0x10(%ebp)
  8017f1:	ff 75 0c             	pushl  0xc(%ebp)
  8017f4:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8017fa:	50                   	push   %eax
  8017fb:	68 87 17 80 00       	push   $0x801787
  801800:	e8 fe ea ff ff       	call   800303 <vprintfmt>
	if (b.idx > 0)
  801805:	83 c4 10             	add    $0x10,%esp
  801808:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  80180f:	7f 11                	jg     801822 <vfprintf+0x64>
		writebuf(&b);

	return (b.result ? b.result : b.error);
  801811:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801817:	85 c0                	test   %eax,%eax
  801819:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801820:	c9                   	leave  
  801821:	c3                   	ret    
		writebuf(&b);
  801822:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801828:	e8 1a ff ff ff       	call   801747 <writebuf>
  80182d:	eb e2                	jmp    801811 <vfprintf+0x53>

0080182f <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  80182f:	55                   	push   %ebp
  801830:	89 e5                	mov    %esp,%ebp
  801832:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801835:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801838:	50                   	push   %eax
  801839:	ff 75 0c             	pushl  0xc(%ebp)
  80183c:	ff 75 08             	pushl  0x8(%ebp)
  80183f:	e8 7a ff ff ff       	call   8017be <vfprintf>
	va_end(ap);

	return cnt;
}
  801844:	c9                   	leave  
  801845:	c3                   	ret    

00801846 <printf>:

int
printf(const char *fmt, ...)
{
  801846:	55                   	push   %ebp
  801847:	89 e5                	mov    %esp,%ebp
  801849:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80184c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  80184f:	50                   	push   %eax
  801850:	ff 75 08             	pushl  0x8(%ebp)
  801853:	6a 01                	push   $0x1
  801855:	e8 64 ff ff ff       	call   8017be <vfprintf>
	va_end(ap);

	return cnt;
}
  80185a:	c9                   	leave  
  80185b:	c3                   	ret    

0080185c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80185c:	55                   	push   %ebp
  80185d:	89 e5                	mov    %esp,%ebp
  80185f:	56                   	push   %esi
  801860:	53                   	push   %ebx
  801861:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801864:	83 ec 0c             	sub    $0xc,%esp
  801867:	ff 75 08             	pushl  0x8(%ebp)
  80186a:	e8 04 f7 ff ff       	call   800f73 <fd2data>
  80186f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801871:	83 c4 08             	add    $0x8,%esp
  801874:	68 0b 25 80 00       	push   $0x80250b
  801879:	53                   	push   %ebx
  80187a:	e8 a6 ef ff ff       	call   800825 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80187f:	8b 46 04             	mov    0x4(%esi),%eax
  801882:	2b 06                	sub    (%esi),%eax
  801884:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80188a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801891:	00 00 00 
	stat->st_dev = &devpipe;
  801894:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80189b:	30 80 00 
	return 0;
}
  80189e:	b8 00 00 00 00       	mov    $0x0,%eax
  8018a3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018a6:	5b                   	pop    %ebx
  8018a7:	5e                   	pop    %esi
  8018a8:	5d                   	pop    %ebp
  8018a9:	c3                   	ret    

008018aa <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018aa:	55                   	push   %ebp
  8018ab:	89 e5                	mov    %esp,%ebp
  8018ad:	53                   	push   %ebx
  8018ae:	83 ec 0c             	sub    $0xc,%esp
  8018b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8018b4:	53                   	push   %ebx
  8018b5:	6a 00                	push   $0x0
  8018b7:	e8 e7 f3 ff ff       	call   800ca3 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8018bc:	89 1c 24             	mov    %ebx,(%esp)
  8018bf:	e8 af f6 ff ff       	call   800f73 <fd2data>
  8018c4:	83 c4 08             	add    $0x8,%esp
  8018c7:	50                   	push   %eax
  8018c8:	6a 00                	push   $0x0
  8018ca:	e8 d4 f3 ff ff       	call   800ca3 <sys_page_unmap>
}
  8018cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d2:	c9                   	leave  
  8018d3:	c3                   	ret    

008018d4 <_pipeisclosed>:
{
  8018d4:	55                   	push   %ebp
  8018d5:	89 e5                	mov    %esp,%ebp
  8018d7:	57                   	push   %edi
  8018d8:	56                   	push   %esi
  8018d9:	53                   	push   %ebx
  8018da:	83 ec 1c             	sub    $0x1c,%esp
  8018dd:	89 c7                	mov    %eax,%edi
  8018df:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8018e1:	a1 04 40 80 00       	mov    0x804004,%eax
  8018e6:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8018e9:	83 ec 0c             	sub    $0xc,%esp
  8018ec:	57                   	push   %edi
  8018ed:	e8 6e 05 00 00       	call   801e60 <pageref>
  8018f2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8018f5:	89 34 24             	mov    %esi,(%esp)
  8018f8:	e8 63 05 00 00       	call   801e60 <pageref>
		nn = thisenv->env_runs;
  8018fd:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801903:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801906:	83 c4 10             	add    $0x10,%esp
  801909:	39 cb                	cmp    %ecx,%ebx
  80190b:	74 1b                	je     801928 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  80190d:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801910:	75 cf                	jne    8018e1 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801912:	8b 42 58             	mov    0x58(%edx),%eax
  801915:	6a 01                	push   $0x1
  801917:	50                   	push   %eax
  801918:	53                   	push   %ebx
  801919:	68 12 25 80 00       	push   $0x802512
  80191e:	e8 e3 e8 ff ff       	call   800206 <cprintf>
  801923:	83 c4 10             	add    $0x10,%esp
  801926:	eb b9                	jmp    8018e1 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801928:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80192b:	0f 94 c0             	sete   %al
  80192e:	0f b6 c0             	movzbl %al,%eax
}
  801931:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801934:	5b                   	pop    %ebx
  801935:	5e                   	pop    %esi
  801936:	5f                   	pop    %edi
  801937:	5d                   	pop    %ebp
  801938:	c3                   	ret    

00801939 <devpipe_write>:
{
  801939:	55                   	push   %ebp
  80193a:	89 e5                	mov    %esp,%ebp
  80193c:	57                   	push   %edi
  80193d:	56                   	push   %esi
  80193e:	53                   	push   %ebx
  80193f:	83 ec 28             	sub    $0x28,%esp
  801942:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801945:	56                   	push   %esi
  801946:	e8 28 f6 ff ff       	call   800f73 <fd2data>
  80194b:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80194d:	83 c4 10             	add    $0x10,%esp
  801950:	bf 00 00 00 00       	mov    $0x0,%edi
  801955:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801958:	74 4f                	je     8019a9 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80195a:	8b 43 04             	mov    0x4(%ebx),%eax
  80195d:	8b 0b                	mov    (%ebx),%ecx
  80195f:	8d 51 20             	lea    0x20(%ecx),%edx
  801962:	39 d0                	cmp    %edx,%eax
  801964:	72 14                	jb     80197a <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801966:	89 da                	mov    %ebx,%edx
  801968:	89 f0                	mov    %esi,%eax
  80196a:	e8 65 ff ff ff       	call   8018d4 <_pipeisclosed>
  80196f:	85 c0                	test   %eax,%eax
  801971:	75 3a                	jne    8019ad <devpipe_write+0x74>
			sys_yield();
  801973:	e8 87 f2 ff ff       	call   800bff <sys_yield>
  801978:	eb e0                	jmp    80195a <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80197a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80197d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801981:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801984:	89 c2                	mov    %eax,%edx
  801986:	c1 fa 1f             	sar    $0x1f,%edx
  801989:	89 d1                	mov    %edx,%ecx
  80198b:	c1 e9 1b             	shr    $0x1b,%ecx
  80198e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801991:	83 e2 1f             	and    $0x1f,%edx
  801994:	29 ca                	sub    %ecx,%edx
  801996:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80199a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80199e:	83 c0 01             	add    $0x1,%eax
  8019a1:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8019a4:	83 c7 01             	add    $0x1,%edi
  8019a7:	eb ac                	jmp    801955 <devpipe_write+0x1c>
	return i;
  8019a9:	89 f8                	mov    %edi,%eax
  8019ab:	eb 05                	jmp    8019b2 <devpipe_write+0x79>
				return 0;
  8019ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019b5:	5b                   	pop    %ebx
  8019b6:	5e                   	pop    %esi
  8019b7:	5f                   	pop    %edi
  8019b8:	5d                   	pop    %ebp
  8019b9:	c3                   	ret    

008019ba <devpipe_read>:
{
  8019ba:	55                   	push   %ebp
  8019bb:	89 e5                	mov    %esp,%ebp
  8019bd:	57                   	push   %edi
  8019be:	56                   	push   %esi
  8019bf:	53                   	push   %ebx
  8019c0:	83 ec 18             	sub    $0x18,%esp
  8019c3:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8019c6:	57                   	push   %edi
  8019c7:	e8 a7 f5 ff ff       	call   800f73 <fd2data>
  8019cc:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8019ce:	83 c4 10             	add    $0x10,%esp
  8019d1:	be 00 00 00 00       	mov    $0x0,%esi
  8019d6:	3b 75 10             	cmp    0x10(%ebp),%esi
  8019d9:	74 47                	je     801a22 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  8019db:	8b 03                	mov    (%ebx),%eax
  8019dd:	3b 43 04             	cmp    0x4(%ebx),%eax
  8019e0:	75 22                	jne    801a04 <devpipe_read+0x4a>
			if (i > 0)
  8019e2:	85 f6                	test   %esi,%esi
  8019e4:	75 14                	jne    8019fa <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  8019e6:	89 da                	mov    %ebx,%edx
  8019e8:	89 f8                	mov    %edi,%eax
  8019ea:	e8 e5 fe ff ff       	call   8018d4 <_pipeisclosed>
  8019ef:	85 c0                	test   %eax,%eax
  8019f1:	75 33                	jne    801a26 <devpipe_read+0x6c>
			sys_yield();
  8019f3:	e8 07 f2 ff ff       	call   800bff <sys_yield>
  8019f8:	eb e1                	jmp    8019db <devpipe_read+0x21>
				return i;
  8019fa:	89 f0                	mov    %esi,%eax
}
  8019fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019ff:	5b                   	pop    %ebx
  801a00:	5e                   	pop    %esi
  801a01:	5f                   	pop    %edi
  801a02:	5d                   	pop    %ebp
  801a03:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a04:	99                   	cltd   
  801a05:	c1 ea 1b             	shr    $0x1b,%edx
  801a08:	01 d0                	add    %edx,%eax
  801a0a:	83 e0 1f             	and    $0x1f,%eax
  801a0d:	29 d0                	sub    %edx,%eax
  801a0f:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801a14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a17:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801a1a:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801a1d:	83 c6 01             	add    $0x1,%esi
  801a20:	eb b4                	jmp    8019d6 <devpipe_read+0x1c>
	return i;
  801a22:	89 f0                	mov    %esi,%eax
  801a24:	eb d6                	jmp    8019fc <devpipe_read+0x42>
				return 0;
  801a26:	b8 00 00 00 00       	mov    $0x0,%eax
  801a2b:	eb cf                	jmp    8019fc <devpipe_read+0x42>

00801a2d <pipe>:
{
  801a2d:	55                   	push   %ebp
  801a2e:	89 e5                	mov    %esp,%ebp
  801a30:	56                   	push   %esi
  801a31:	53                   	push   %ebx
  801a32:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801a35:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a38:	50                   	push   %eax
  801a39:	e8 4c f5 ff ff       	call   800f8a <fd_alloc>
  801a3e:	89 c3                	mov    %eax,%ebx
  801a40:	83 c4 10             	add    $0x10,%esp
  801a43:	85 c0                	test   %eax,%eax
  801a45:	78 5b                	js     801aa2 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a47:	83 ec 04             	sub    $0x4,%esp
  801a4a:	68 07 04 00 00       	push   $0x407
  801a4f:	ff 75 f4             	pushl  -0xc(%ebp)
  801a52:	6a 00                	push   $0x0
  801a54:	e8 c5 f1 ff ff       	call   800c1e <sys_page_alloc>
  801a59:	89 c3                	mov    %eax,%ebx
  801a5b:	83 c4 10             	add    $0x10,%esp
  801a5e:	85 c0                	test   %eax,%eax
  801a60:	78 40                	js     801aa2 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  801a62:	83 ec 0c             	sub    $0xc,%esp
  801a65:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a68:	50                   	push   %eax
  801a69:	e8 1c f5 ff ff       	call   800f8a <fd_alloc>
  801a6e:	89 c3                	mov    %eax,%ebx
  801a70:	83 c4 10             	add    $0x10,%esp
  801a73:	85 c0                	test   %eax,%eax
  801a75:	78 1b                	js     801a92 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a77:	83 ec 04             	sub    $0x4,%esp
  801a7a:	68 07 04 00 00       	push   $0x407
  801a7f:	ff 75 f0             	pushl  -0x10(%ebp)
  801a82:	6a 00                	push   $0x0
  801a84:	e8 95 f1 ff ff       	call   800c1e <sys_page_alloc>
  801a89:	89 c3                	mov    %eax,%ebx
  801a8b:	83 c4 10             	add    $0x10,%esp
  801a8e:	85 c0                	test   %eax,%eax
  801a90:	79 19                	jns    801aab <pipe+0x7e>
	sys_page_unmap(0, fd0);
  801a92:	83 ec 08             	sub    $0x8,%esp
  801a95:	ff 75 f4             	pushl  -0xc(%ebp)
  801a98:	6a 00                	push   $0x0
  801a9a:	e8 04 f2 ff ff       	call   800ca3 <sys_page_unmap>
  801a9f:	83 c4 10             	add    $0x10,%esp
}
  801aa2:	89 d8                	mov    %ebx,%eax
  801aa4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aa7:	5b                   	pop    %ebx
  801aa8:	5e                   	pop    %esi
  801aa9:	5d                   	pop    %ebp
  801aaa:	c3                   	ret    
	va = fd2data(fd0);
  801aab:	83 ec 0c             	sub    $0xc,%esp
  801aae:	ff 75 f4             	pushl  -0xc(%ebp)
  801ab1:	e8 bd f4 ff ff       	call   800f73 <fd2data>
  801ab6:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ab8:	83 c4 0c             	add    $0xc,%esp
  801abb:	68 07 04 00 00       	push   $0x407
  801ac0:	50                   	push   %eax
  801ac1:	6a 00                	push   $0x0
  801ac3:	e8 56 f1 ff ff       	call   800c1e <sys_page_alloc>
  801ac8:	89 c3                	mov    %eax,%ebx
  801aca:	83 c4 10             	add    $0x10,%esp
  801acd:	85 c0                	test   %eax,%eax
  801acf:	0f 88 8c 00 00 00    	js     801b61 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ad5:	83 ec 0c             	sub    $0xc,%esp
  801ad8:	ff 75 f0             	pushl  -0x10(%ebp)
  801adb:	e8 93 f4 ff ff       	call   800f73 <fd2data>
  801ae0:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ae7:	50                   	push   %eax
  801ae8:	6a 00                	push   $0x0
  801aea:	56                   	push   %esi
  801aeb:	6a 00                	push   $0x0
  801aed:	e8 6f f1 ff ff       	call   800c61 <sys_page_map>
  801af2:	89 c3                	mov    %eax,%ebx
  801af4:	83 c4 20             	add    $0x20,%esp
  801af7:	85 c0                	test   %eax,%eax
  801af9:	78 58                	js     801b53 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801afb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801afe:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b04:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b06:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b09:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801b10:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b13:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b19:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b1e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801b25:	83 ec 0c             	sub    $0xc,%esp
  801b28:	ff 75 f4             	pushl  -0xc(%ebp)
  801b2b:	e8 33 f4 ff ff       	call   800f63 <fd2num>
  801b30:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b33:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b35:	83 c4 04             	add    $0x4,%esp
  801b38:	ff 75 f0             	pushl  -0x10(%ebp)
  801b3b:	e8 23 f4 ff ff       	call   800f63 <fd2num>
  801b40:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b43:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801b46:	83 c4 10             	add    $0x10,%esp
  801b49:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b4e:	e9 4f ff ff ff       	jmp    801aa2 <pipe+0x75>
	sys_page_unmap(0, va);
  801b53:	83 ec 08             	sub    $0x8,%esp
  801b56:	56                   	push   %esi
  801b57:	6a 00                	push   $0x0
  801b59:	e8 45 f1 ff ff       	call   800ca3 <sys_page_unmap>
  801b5e:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801b61:	83 ec 08             	sub    $0x8,%esp
  801b64:	ff 75 f0             	pushl  -0x10(%ebp)
  801b67:	6a 00                	push   $0x0
  801b69:	e8 35 f1 ff ff       	call   800ca3 <sys_page_unmap>
  801b6e:	83 c4 10             	add    $0x10,%esp
  801b71:	e9 1c ff ff ff       	jmp    801a92 <pipe+0x65>

00801b76 <pipeisclosed>:
{
  801b76:	55                   	push   %ebp
  801b77:	89 e5                	mov    %esp,%ebp
  801b79:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b7c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b7f:	50                   	push   %eax
  801b80:	ff 75 08             	pushl  0x8(%ebp)
  801b83:	e8 51 f4 ff ff       	call   800fd9 <fd_lookup>
  801b88:	83 c4 10             	add    $0x10,%esp
  801b8b:	85 c0                	test   %eax,%eax
  801b8d:	78 18                	js     801ba7 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801b8f:	83 ec 0c             	sub    $0xc,%esp
  801b92:	ff 75 f4             	pushl  -0xc(%ebp)
  801b95:	e8 d9 f3 ff ff       	call   800f73 <fd2data>
	return _pipeisclosed(fd, p);
  801b9a:	89 c2                	mov    %eax,%edx
  801b9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b9f:	e8 30 fd ff ff       	call   8018d4 <_pipeisclosed>
  801ba4:	83 c4 10             	add    $0x10,%esp
}
  801ba7:	c9                   	leave  
  801ba8:	c3                   	ret    

00801ba9 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ba9:	55                   	push   %ebp
  801baa:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801bac:	b8 00 00 00 00       	mov    $0x0,%eax
  801bb1:	5d                   	pop    %ebp
  801bb2:	c3                   	ret    

00801bb3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801bb3:	55                   	push   %ebp
  801bb4:	89 e5                	mov    %esp,%ebp
  801bb6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801bb9:	68 2a 25 80 00       	push   $0x80252a
  801bbe:	ff 75 0c             	pushl  0xc(%ebp)
  801bc1:	e8 5f ec ff ff       	call   800825 <strcpy>
	return 0;
}
  801bc6:	b8 00 00 00 00       	mov    $0x0,%eax
  801bcb:	c9                   	leave  
  801bcc:	c3                   	ret    

00801bcd <devcons_write>:
{
  801bcd:	55                   	push   %ebp
  801bce:	89 e5                	mov    %esp,%ebp
  801bd0:	57                   	push   %edi
  801bd1:	56                   	push   %esi
  801bd2:	53                   	push   %ebx
  801bd3:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801bd9:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801bde:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801be4:	eb 2f                	jmp    801c15 <devcons_write+0x48>
		m = n - tot;
  801be6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801be9:	29 f3                	sub    %esi,%ebx
  801beb:	83 fb 7f             	cmp    $0x7f,%ebx
  801bee:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801bf3:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801bf6:	83 ec 04             	sub    $0x4,%esp
  801bf9:	53                   	push   %ebx
  801bfa:	89 f0                	mov    %esi,%eax
  801bfc:	03 45 0c             	add    0xc(%ebp),%eax
  801bff:	50                   	push   %eax
  801c00:	57                   	push   %edi
  801c01:	e8 ad ed ff ff       	call   8009b3 <memmove>
		sys_cputs(buf, m);
  801c06:	83 c4 08             	add    $0x8,%esp
  801c09:	53                   	push   %ebx
  801c0a:	57                   	push   %edi
  801c0b:	e8 52 ef ff ff       	call   800b62 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801c10:	01 de                	add    %ebx,%esi
  801c12:	83 c4 10             	add    $0x10,%esp
  801c15:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c18:	72 cc                	jb     801be6 <devcons_write+0x19>
}
  801c1a:	89 f0                	mov    %esi,%eax
  801c1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c1f:	5b                   	pop    %ebx
  801c20:	5e                   	pop    %esi
  801c21:	5f                   	pop    %edi
  801c22:	5d                   	pop    %ebp
  801c23:	c3                   	ret    

00801c24 <devcons_read>:
{
  801c24:	55                   	push   %ebp
  801c25:	89 e5                	mov    %esp,%ebp
  801c27:	83 ec 08             	sub    $0x8,%esp
  801c2a:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801c2f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c33:	75 07                	jne    801c3c <devcons_read+0x18>
}
  801c35:	c9                   	leave  
  801c36:	c3                   	ret    
		sys_yield();
  801c37:	e8 c3 ef ff ff       	call   800bff <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801c3c:	e8 3f ef ff ff       	call   800b80 <sys_cgetc>
  801c41:	85 c0                	test   %eax,%eax
  801c43:	74 f2                	je     801c37 <devcons_read+0x13>
	if (c < 0)
  801c45:	85 c0                	test   %eax,%eax
  801c47:	78 ec                	js     801c35 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801c49:	83 f8 04             	cmp    $0x4,%eax
  801c4c:	74 0c                	je     801c5a <devcons_read+0x36>
	*(char*)vbuf = c;
  801c4e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c51:	88 02                	mov    %al,(%edx)
	return 1;
  801c53:	b8 01 00 00 00       	mov    $0x1,%eax
  801c58:	eb db                	jmp    801c35 <devcons_read+0x11>
		return 0;
  801c5a:	b8 00 00 00 00       	mov    $0x0,%eax
  801c5f:	eb d4                	jmp    801c35 <devcons_read+0x11>

00801c61 <cputchar>:
{
  801c61:	55                   	push   %ebp
  801c62:	89 e5                	mov    %esp,%ebp
  801c64:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c67:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6a:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801c6d:	6a 01                	push   $0x1
  801c6f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c72:	50                   	push   %eax
  801c73:	e8 ea ee ff ff       	call   800b62 <sys_cputs>
}
  801c78:	83 c4 10             	add    $0x10,%esp
  801c7b:	c9                   	leave  
  801c7c:	c3                   	ret    

00801c7d <getchar>:
{
  801c7d:	55                   	push   %ebp
  801c7e:	89 e5                	mov    %esp,%ebp
  801c80:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801c83:	6a 01                	push   $0x1
  801c85:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c88:	50                   	push   %eax
  801c89:	6a 00                	push   $0x0
  801c8b:	e8 ba f5 ff ff       	call   80124a <read>
	if (r < 0)
  801c90:	83 c4 10             	add    $0x10,%esp
  801c93:	85 c0                	test   %eax,%eax
  801c95:	78 08                	js     801c9f <getchar+0x22>
	if (r < 1)
  801c97:	85 c0                	test   %eax,%eax
  801c99:	7e 06                	jle    801ca1 <getchar+0x24>
	return c;
  801c9b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801c9f:	c9                   	leave  
  801ca0:	c3                   	ret    
		return -E_EOF;
  801ca1:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801ca6:	eb f7                	jmp    801c9f <getchar+0x22>

00801ca8 <iscons>:
{
  801ca8:	55                   	push   %ebp
  801ca9:	89 e5                	mov    %esp,%ebp
  801cab:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cb1:	50                   	push   %eax
  801cb2:	ff 75 08             	pushl  0x8(%ebp)
  801cb5:	e8 1f f3 ff ff       	call   800fd9 <fd_lookup>
  801cba:	83 c4 10             	add    $0x10,%esp
  801cbd:	85 c0                	test   %eax,%eax
  801cbf:	78 11                	js     801cd2 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801cc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cca:	39 10                	cmp    %edx,(%eax)
  801ccc:	0f 94 c0             	sete   %al
  801ccf:	0f b6 c0             	movzbl %al,%eax
}
  801cd2:	c9                   	leave  
  801cd3:	c3                   	ret    

00801cd4 <opencons>:
{
  801cd4:	55                   	push   %ebp
  801cd5:	89 e5                	mov    %esp,%ebp
  801cd7:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801cda:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cdd:	50                   	push   %eax
  801cde:	e8 a7 f2 ff ff       	call   800f8a <fd_alloc>
  801ce3:	83 c4 10             	add    $0x10,%esp
  801ce6:	85 c0                	test   %eax,%eax
  801ce8:	78 3a                	js     801d24 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801cea:	83 ec 04             	sub    $0x4,%esp
  801ced:	68 07 04 00 00       	push   $0x407
  801cf2:	ff 75 f4             	pushl  -0xc(%ebp)
  801cf5:	6a 00                	push   $0x0
  801cf7:	e8 22 ef ff ff       	call   800c1e <sys_page_alloc>
  801cfc:	83 c4 10             	add    $0x10,%esp
  801cff:	85 c0                	test   %eax,%eax
  801d01:	78 21                	js     801d24 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801d03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d06:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d0c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d11:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d18:	83 ec 0c             	sub    $0xc,%esp
  801d1b:	50                   	push   %eax
  801d1c:	e8 42 f2 ff ff       	call   800f63 <fd2num>
  801d21:	83 c4 10             	add    $0x10,%esp
}
  801d24:	c9                   	leave  
  801d25:	c3                   	ret    

00801d26 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d26:	55                   	push   %ebp
  801d27:	89 e5                	mov    %esp,%ebp
  801d29:	56                   	push   %esi
  801d2a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d2b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d2e:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d34:	e8 a7 ee ff ff       	call   800be0 <sys_getenvid>
  801d39:	83 ec 0c             	sub    $0xc,%esp
  801d3c:	ff 75 0c             	pushl  0xc(%ebp)
  801d3f:	ff 75 08             	pushl  0x8(%ebp)
  801d42:	56                   	push   %esi
  801d43:	50                   	push   %eax
  801d44:	68 38 25 80 00       	push   $0x802538
  801d49:	e8 b8 e4 ff ff       	call   800206 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d4e:	83 c4 18             	add    $0x18,%esp
  801d51:	53                   	push   %ebx
  801d52:	ff 75 10             	pushl  0x10(%ebp)
  801d55:	e8 5b e4 ff ff       	call   8001b5 <vcprintf>
	cprintf("\n");
  801d5a:	c7 04 24 f0 20 80 00 	movl   $0x8020f0,(%esp)
  801d61:	e8 a0 e4 ff ff       	call   800206 <cprintf>
  801d66:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d69:	cc                   	int3   
  801d6a:	eb fd                	jmp    801d69 <_panic+0x43>

00801d6c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801d6c:	55                   	push   %ebp
  801d6d:	89 e5                	mov    %esp,%ebp
  801d6f:	56                   	push   %esi
  801d70:	53                   	push   %ebx
  801d71:	8b 75 08             	mov    0x8(%ebp),%esi
  801d74:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d77:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  801d7a:	85 f6                	test   %esi,%esi
  801d7c:	74 06                	je     801d84 <ipc_recv+0x18>
  801d7e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801d84:	85 db                	test   %ebx,%ebx
  801d86:	74 06                	je     801d8e <ipc_recv+0x22>
  801d88:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801d8e:	85 c0                	test   %eax,%eax
  801d90:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801d95:	0f 44 c2             	cmove  %edx,%eax
	int ret = sys_ipc_recv(pg);
  801d98:	83 ec 0c             	sub    $0xc,%esp
  801d9b:	50                   	push   %eax
  801d9c:	e8 2d f0 ff ff       	call   800dce <sys_ipc_recv>
	if (ret) return ret;
  801da1:	83 c4 10             	add    $0x10,%esp
  801da4:	85 c0                	test   %eax,%eax
  801da6:	75 24                	jne    801dcc <ipc_recv+0x60>
	if (from_env_store)
  801da8:	85 f6                	test   %esi,%esi
  801daa:	74 0a                	je     801db6 <ipc_recv+0x4a>
		*from_env_store = thisenv->env_ipc_from;
  801dac:	a1 04 40 80 00       	mov    0x804004,%eax
  801db1:	8b 40 74             	mov    0x74(%eax),%eax
  801db4:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801db6:	85 db                	test   %ebx,%ebx
  801db8:	74 0a                	je     801dc4 <ipc_recv+0x58>
		*perm_store = thisenv->env_ipc_perm;
  801dba:	a1 04 40 80 00       	mov    0x804004,%eax
  801dbf:	8b 40 78             	mov    0x78(%eax),%eax
  801dc2:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801dc4:	a1 04 40 80 00       	mov    0x804004,%eax
  801dc9:	8b 40 70             	mov    0x70(%eax),%eax
}
  801dcc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dcf:	5b                   	pop    %ebx
  801dd0:	5e                   	pop    %esi
  801dd1:	5d                   	pop    %ebp
  801dd2:	c3                   	ret    

00801dd3 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801dd3:	55                   	push   %ebp
  801dd4:	89 e5                	mov    %esp,%ebp
  801dd6:	57                   	push   %edi
  801dd7:	56                   	push   %esi
  801dd8:	53                   	push   %ebx
  801dd9:	83 ec 0c             	sub    $0xc,%esp
  801ddc:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ddf:	8b 75 0c             	mov    0xc(%ebp),%esi
  801de2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  801de5:	85 db                	test   %ebx,%ebx
  801de7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801dec:	0f 44 d8             	cmove  %eax,%ebx
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801def:	ff 75 14             	pushl  0x14(%ebp)
  801df2:	53                   	push   %ebx
  801df3:	56                   	push   %esi
  801df4:	57                   	push   %edi
  801df5:	e8 b1 ef ff ff       	call   800dab <sys_ipc_try_send>
  801dfa:	83 c4 10             	add    $0x10,%esp
  801dfd:	85 c0                	test   %eax,%eax
  801dff:	74 1e                	je     801e1f <ipc_send+0x4c>
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801e01:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e04:	75 07                	jne    801e0d <ipc_send+0x3a>
		sys_yield();
  801e06:	e8 f4 ed ff ff       	call   800bff <sys_yield>
  801e0b:	eb e2                	jmp    801def <ipc_send+0x1c>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801e0d:	50                   	push   %eax
  801e0e:	68 5c 25 80 00       	push   $0x80255c
  801e13:	6a 36                	push   $0x36
  801e15:	68 73 25 80 00       	push   $0x802573
  801e1a:	e8 07 ff ff ff       	call   801d26 <_panic>
	}
}
  801e1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e22:	5b                   	pop    %ebx
  801e23:	5e                   	pop    %esi
  801e24:	5f                   	pop    %edi
  801e25:	5d                   	pop    %ebp
  801e26:	c3                   	ret    

00801e27 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801e27:	55                   	push   %ebp
  801e28:	89 e5                	mov    %esp,%ebp
  801e2a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801e2d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801e32:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801e35:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801e3b:	8b 52 50             	mov    0x50(%edx),%edx
  801e3e:	39 ca                	cmp    %ecx,%edx
  801e40:	74 11                	je     801e53 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801e42:	83 c0 01             	add    $0x1,%eax
  801e45:	3d 00 04 00 00       	cmp    $0x400,%eax
  801e4a:	75 e6                	jne    801e32 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801e4c:	b8 00 00 00 00       	mov    $0x0,%eax
  801e51:	eb 0b                	jmp    801e5e <ipc_find_env+0x37>
			return envs[i].env_id;
  801e53:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801e56:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801e5b:	8b 40 48             	mov    0x48(%eax),%eax
}
  801e5e:	5d                   	pop    %ebp
  801e5f:	c3                   	ret    

00801e60 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e60:	55                   	push   %ebp
  801e61:	89 e5                	mov    %esp,%ebp
  801e63:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e66:	89 d0                	mov    %edx,%eax
  801e68:	c1 e8 16             	shr    $0x16,%eax
  801e6b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801e72:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801e77:	f6 c1 01             	test   $0x1,%cl
  801e7a:	74 1d                	je     801e99 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801e7c:	c1 ea 0c             	shr    $0xc,%edx
  801e7f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801e86:	f6 c2 01             	test   $0x1,%dl
  801e89:	74 0e                	je     801e99 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801e8b:	c1 ea 0c             	shr    $0xc,%edx
  801e8e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801e95:	ef 
  801e96:	0f b7 c0             	movzwl %ax,%eax
}
  801e99:	5d                   	pop    %ebp
  801e9a:	c3                   	ret    
  801e9b:	66 90                	xchg   %ax,%ax
  801e9d:	66 90                	xchg   %ax,%ax
  801e9f:	90                   	nop

00801ea0 <__udivdi3>:
  801ea0:	55                   	push   %ebp
  801ea1:	57                   	push   %edi
  801ea2:	56                   	push   %esi
  801ea3:	53                   	push   %ebx
  801ea4:	83 ec 1c             	sub    $0x1c,%esp
  801ea7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801eab:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801eaf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801eb3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801eb7:	85 d2                	test   %edx,%edx
  801eb9:	75 35                	jne    801ef0 <__udivdi3+0x50>
  801ebb:	39 f3                	cmp    %esi,%ebx
  801ebd:	0f 87 bd 00 00 00    	ja     801f80 <__udivdi3+0xe0>
  801ec3:	85 db                	test   %ebx,%ebx
  801ec5:	89 d9                	mov    %ebx,%ecx
  801ec7:	75 0b                	jne    801ed4 <__udivdi3+0x34>
  801ec9:	b8 01 00 00 00       	mov    $0x1,%eax
  801ece:	31 d2                	xor    %edx,%edx
  801ed0:	f7 f3                	div    %ebx
  801ed2:	89 c1                	mov    %eax,%ecx
  801ed4:	31 d2                	xor    %edx,%edx
  801ed6:	89 f0                	mov    %esi,%eax
  801ed8:	f7 f1                	div    %ecx
  801eda:	89 c6                	mov    %eax,%esi
  801edc:	89 e8                	mov    %ebp,%eax
  801ede:	89 f7                	mov    %esi,%edi
  801ee0:	f7 f1                	div    %ecx
  801ee2:	89 fa                	mov    %edi,%edx
  801ee4:	83 c4 1c             	add    $0x1c,%esp
  801ee7:	5b                   	pop    %ebx
  801ee8:	5e                   	pop    %esi
  801ee9:	5f                   	pop    %edi
  801eea:	5d                   	pop    %ebp
  801eeb:	c3                   	ret    
  801eec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ef0:	39 f2                	cmp    %esi,%edx
  801ef2:	77 7c                	ja     801f70 <__udivdi3+0xd0>
  801ef4:	0f bd fa             	bsr    %edx,%edi
  801ef7:	83 f7 1f             	xor    $0x1f,%edi
  801efa:	0f 84 98 00 00 00    	je     801f98 <__udivdi3+0xf8>
  801f00:	89 f9                	mov    %edi,%ecx
  801f02:	b8 20 00 00 00       	mov    $0x20,%eax
  801f07:	29 f8                	sub    %edi,%eax
  801f09:	d3 e2                	shl    %cl,%edx
  801f0b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801f0f:	89 c1                	mov    %eax,%ecx
  801f11:	89 da                	mov    %ebx,%edx
  801f13:	d3 ea                	shr    %cl,%edx
  801f15:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801f19:	09 d1                	or     %edx,%ecx
  801f1b:	89 f2                	mov    %esi,%edx
  801f1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f21:	89 f9                	mov    %edi,%ecx
  801f23:	d3 e3                	shl    %cl,%ebx
  801f25:	89 c1                	mov    %eax,%ecx
  801f27:	d3 ea                	shr    %cl,%edx
  801f29:	89 f9                	mov    %edi,%ecx
  801f2b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801f2f:	d3 e6                	shl    %cl,%esi
  801f31:	89 eb                	mov    %ebp,%ebx
  801f33:	89 c1                	mov    %eax,%ecx
  801f35:	d3 eb                	shr    %cl,%ebx
  801f37:	09 de                	or     %ebx,%esi
  801f39:	89 f0                	mov    %esi,%eax
  801f3b:	f7 74 24 08          	divl   0x8(%esp)
  801f3f:	89 d6                	mov    %edx,%esi
  801f41:	89 c3                	mov    %eax,%ebx
  801f43:	f7 64 24 0c          	mull   0xc(%esp)
  801f47:	39 d6                	cmp    %edx,%esi
  801f49:	72 0c                	jb     801f57 <__udivdi3+0xb7>
  801f4b:	89 f9                	mov    %edi,%ecx
  801f4d:	d3 e5                	shl    %cl,%ebp
  801f4f:	39 c5                	cmp    %eax,%ebp
  801f51:	73 5d                	jae    801fb0 <__udivdi3+0x110>
  801f53:	39 d6                	cmp    %edx,%esi
  801f55:	75 59                	jne    801fb0 <__udivdi3+0x110>
  801f57:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801f5a:	31 ff                	xor    %edi,%edi
  801f5c:	89 fa                	mov    %edi,%edx
  801f5e:	83 c4 1c             	add    $0x1c,%esp
  801f61:	5b                   	pop    %ebx
  801f62:	5e                   	pop    %esi
  801f63:	5f                   	pop    %edi
  801f64:	5d                   	pop    %ebp
  801f65:	c3                   	ret    
  801f66:	8d 76 00             	lea    0x0(%esi),%esi
  801f69:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801f70:	31 ff                	xor    %edi,%edi
  801f72:	31 c0                	xor    %eax,%eax
  801f74:	89 fa                	mov    %edi,%edx
  801f76:	83 c4 1c             	add    $0x1c,%esp
  801f79:	5b                   	pop    %ebx
  801f7a:	5e                   	pop    %esi
  801f7b:	5f                   	pop    %edi
  801f7c:	5d                   	pop    %ebp
  801f7d:	c3                   	ret    
  801f7e:	66 90                	xchg   %ax,%ax
  801f80:	31 ff                	xor    %edi,%edi
  801f82:	89 e8                	mov    %ebp,%eax
  801f84:	89 f2                	mov    %esi,%edx
  801f86:	f7 f3                	div    %ebx
  801f88:	89 fa                	mov    %edi,%edx
  801f8a:	83 c4 1c             	add    $0x1c,%esp
  801f8d:	5b                   	pop    %ebx
  801f8e:	5e                   	pop    %esi
  801f8f:	5f                   	pop    %edi
  801f90:	5d                   	pop    %ebp
  801f91:	c3                   	ret    
  801f92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f98:	39 f2                	cmp    %esi,%edx
  801f9a:	72 06                	jb     801fa2 <__udivdi3+0x102>
  801f9c:	31 c0                	xor    %eax,%eax
  801f9e:	39 eb                	cmp    %ebp,%ebx
  801fa0:	77 d2                	ja     801f74 <__udivdi3+0xd4>
  801fa2:	b8 01 00 00 00       	mov    $0x1,%eax
  801fa7:	eb cb                	jmp    801f74 <__udivdi3+0xd4>
  801fa9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fb0:	89 d8                	mov    %ebx,%eax
  801fb2:	31 ff                	xor    %edi,%edi
  801fb4:	eb be                	jmp    801f74 <__udivdi3+0xd4>
  801fb6:	66 90                	xchg   %ax,%ax
  801fb8:	66 90                	xchg   %ax,%ax
  801fba:	66 90                	xchg   %ax,%ax
  801fbc:	66 90                	xchg   %ax,%ax
  801fbe:	66 90                	xchg   %ax,%ax

00801fc0 <__umoddi3>:
  801fc0:	55                   	push   %ebp
  801fc1:	57                   	push   %edi
  801fc2:	56                   	push   %esi
  801fc3:	53                   	push   %ebx
  801fc4:	83 ec 1c             	sub    $0x1c,%esp
  801fc7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801fcb:	8b 74 24 30          	mov    0x30(%esp),%esi
  801fcf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801fd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fd7:	85 ed                	test   %ebp,%ebp
  801fd9:	89 f0                	mov    %esi,%eax
  801fdb:	89 da                	mov    %ebx,%edx
  801fdd:	75 19                	jne    801ff8 <__umoddi3+0x38>
  801fdf:	39 df                	cmp    %ebx,%edi
  801fe1:	0f 86 b1 00 00 00    	jbe    802098 <__umoddi3+0xd8>
  801fe7:	f7 f7                	div    %edi
  801fe9:	89 d0                	mov    %edx,%eax
  801feb:	31 d2                	xor    %edx,%edx
  801fed:	83 c4 1c             	add    $0x1c,%esp
  801ff0:	5b                   	pop    %ebx
  801ff1:	5e                   	pop    %esi
  801ff2:	5f                   	pop    %edi
  801ff3:	5d                   	pop    %ebp
  801ff4:	c3                   	ret    
  801ff5:	8d 76 00             	lea    0x0(%esi),%esi
  801ff8:	39 dd                	cmp    %ebx,%ebp
  801ffa:	77 f1                	ja     801fed <__umoddi3+0x2d>
  801ffc:	0f bd cd             	bsr    %ebp,%ecx
  801fff:	83 f1 1f             	xor    $0x1f,%ecx
  802002:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802006:	0f 84 b4 00 00 00    	je     8020c0 <__umoddi3+0x100>
  80200c:	b8 20 00 00 00       	mov    $0x20,%eax
  802011:	89 c2                	mov    %eax,%edx
  802013:	8b 44 24 04          	mov    0x4(%esp),%eax
  802017:	29 c2                	sub    %eax,%edx
  802019:	89 c1                	mov    %eax,%ecx
  80201b:	89 f8                	mov    %edi,%eax
  80201d:	d3 e5                	shl    %cl,%ebp
  80201f:	89 d1                	mov    %edx,%ecx
  802021:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802025:	d3 e8                	shr    %cl,%eax
  802027:	09 c5                	or     %eax,%ebp
  802029:	8b 44 24 04          	mov    0x4(%esp),%eax
  80202d:	89 c1                	mov    %eax,%ecx
  80202f:	d3 e7                	shl    %cl,%edi
  802031:	89 d1                	mov    %edx,%ecx
  802033:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802037:	89 df                	mov    %ebx,%edi
  802039:	d3 ef                	shr    %cl,%edi
  80203b:	89 c1                	mov    %eax,%ecx
  80203d:	89 f0                	mov    %esi,%eax
  80203f:	d3 e3                	shl    %cl,%ebx
  802041:	89 d1                	mov    %edx,%ecx
  802043:	89 fa                	mov    %edi,%edx
  802045:	d3 e8                	shr    %cl,%eax
  802047:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80204c:	09 d8                	or     %ebx,%eax
  80204e:	f7 f5                	div    %ebp
  802050:	d3 e6                	shl    %cl,%esi
  802052:	89 d1                	mov    %edx,%ecx
  802054:	f7 64 24 08          	mull   0x8(%esp)
  802058:	39 d1                	cmp    %edx,%ecx
  80205a:	89 c3                	mov    %eax,%ebx
  80205c:	89 d7                	mov    %edx,%edi
  80205e:	72 06                	jb     802066 <__umoddi3+0xa6>
  802060:	75 0e                	jne    802070 <__umoddi3+0xb0>
  802062:	39 c6                	cmp    %eax,%esi
  802064:	73 0a                	jae    802070 <__umoddi3+0xb0>
  802066:	2b 44 24 08          	sub    0x8(%esp),%eax
  80206a:	19 ea                	sbb    %ebp,%edx
  80206c:	89 d7                	mov    %edx,%edi
  80206e:	89 c3                	mov    %eax,%ebx
  802070:	89 ca                	mov    %ecx,%edx
  802072:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  802077:	29 de                	sub    %ebx,%esi
  802079:	19 fa                	sbb    %edi,%edx
  80207b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80207f:	89 d0                	mov    %edx,%eax
  802081:	d3 e0                	shl    %cl,%eax
  802083:	89 d9                	mov    %ebx,%ecx
  802085:	d3 ee                	shr    %cl,%esi
  802087:	d3 ea                	shr    %cl,%edx
  802089:	09 f0                	or     %esi,%eax
  80208b:	83 c4 1c             	add    $0x1c,%esp
  80208e:	5b                   	pop    %ebx
  80208f:	5e                   	pop    %esi
  802090:	5f                   	pop    %edi
  802091:	5d                   	pop    %ebp
  802092:	c3                   	ret    
  802093:	90                   	nop
  802094:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802098:	85 ff                	test   %edi,%edi
  80209a:	89 f9                	mov    %edi,%ecx
  80209c:	75 0b                	jne    8020a9 <__umoddi3+0xe9>
  80209e:	b8 01 00 00 00       	mov    $0x1,%eax
  8020a3:	31 d2                	xor    %edx,%edx
  8020a5:	f7 f7                	div    %edi
  8020a7:	89 c1                	mov    %eax,%ecx
  8020a9:	89 d8                	mov    %ebx,%eax
  8020ab:	31 d2                	xor    %edx,%edx
  8020ad:	f7 f1                	div    %ecx
  8020af:	89 f0                	mov    %esi,%eax
  8020b1:	f7 f1                	div    %ecx
  8020b3:	e9 31 ff ff ff       	jmp    801fe9 <__umoddi3+0x29>
  8020b8:	90                   	nop
  8020b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020c0:	39 dd                	cmp    %ebx,%ebp
  8020c2:	72 08                	jb     8020cc <__umoddi3+0x10c>
  8020c4:	39 f7                	cmp    %esi,%edi
  8020c6:	0f 87 21 ff ff ff    	ja     801fed <__umoddi3+0x2d>
  8020cc:	89 da                	mov    %ebx,%edx
  8020ce:	89 f0                	mov    %esi,%eax
  8020d0:	29 f8                	sub    %edi,%eax
  8020d2:	19 ea                	sbb    %ebp,%edx
  8020d4:	e9 14 ff ff ff       	jmp    801fed <__umoddi3+0x2d>
