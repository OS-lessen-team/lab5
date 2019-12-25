
obj/user/testpteshare.debug：     文件格式 elf32-i386


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
  80002c:	e8 65 01 00 00       	call   800196 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <childofspawn>:
	breakpoint();
}

void
childofspawn(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	strcpy(VA, msg2);
  800039:	ff 35 00 30 80 00    	pushl  0x803000
  80003f:	68 00 00 00 a0       	push   $0xa0000000
  800044:	e8 a7 08 00 00       	call   8008f0 <strcpy>
	exit();
  800049:	e8 8e 01 00 00       	call   8001dc <exit>
}
  80004e:	83 c4 10             	add    $0x10,%esp
  800051:	c9                   	leave  
  800052:	c3                   	ret    

00800053 <umain>:
{
  800053:	55                   	push   %ebp
  800054:	89 e5                	mov    %esp,%ebp
  800056:	53                   	push   %ebx
  800057:	83 ec 04             	sub    $0x4,%esp
	if (argc != 0)
  80005a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80005e:	0f 85 d2 00 00 00    	jne    800136 <umain+0xe3>
	if ((r = sys_page_alloc(0, VA, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800064:	83 ec 04             	sub    $0x4,%esp
  800067:	68 07 04 00 00       	push   $0x407
  80006c:	68 00 00 00 a0       	push   $0xa0000000
  800071:	6a 00                	push   $0x0
  800073:	e8 71 0c 00 00       	call   800ce9 <sys_page_alloc>
  800078:	83 c4 10             	add    $0x10,%esp
  80007b:	85 c0                	test   %eax,%eax
  80007d:	0f 88 bd 00 00 00    	js     800140 <umain+0xed>
	if ((r = fork()) < 0)
  800083:	e8 54 0f 00 00       	call   800fdc <fork>
  800088:	89 c3                	mov    %eax,%ebx
  80008a:	85 c0                	test   %eax,%eax
  80008c:	0f 88 c0 00 00 00    	js     800152 <umain+0xff>
	if (r == 0) {
  800092:	85 c0                	test   %eax,%eax
  800094:	0f 84 ca 00 00 00    	je     800164 <umain+0x111>
	wait(r);
  80009a:	83 ec 0c             	sub    $0xc,%esp
  80009d:	53                   	push   %ebx
  80009e:	e8 3e 22 00 00       	call   8022e1 <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000a3:	83 c4 08             	add    $0x8,%esp
  8000a6:	ff 35 04 30 80 00    	pushl  0x803004
  8000ac:	68 00 00 00 a0       	push   $0xa0000000
  8000b1:	e8 e0 08 00 00       	call   800996 <strcmp>
  8000b6:	83 c4 08             	add    $0x8,%esp
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	b8 c0 28 80 00       	mov    $0x8028c0,%eax
  8000c0:	ba c6 28 80 00       	mov    $0x8028c6,%edx
  8000c5:	0f 45 c2             	cmovne %edx,%eax
  8000c8:	50                   	push   %eax
  8000c9:	68 f3 28 80 00       	push   $0x8028f3
  8000ce:	e8 fe 01 00 00       	call   8002d1 <cprintf>
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  8000d3:	6a 00                	push   $0x0
  8000d5:	68 0e 29 80 00       	push   $0x80290e
  8000da:	68 13 29 80 00       	push   $0x802913
  8000df:	68 12 29 80 00       	push   $0x802912
  8000e4:	e8 2e 1e 00 00       	call   801f17 <spawnl>
  8000e9:	83 c4 20             	add    $0x20,%esp
  8000ec:	85 c0                	test   %eax,%eax
  8000ee:	0f 88 90 00 00 00    	js     800184 <umain+0x131>
	wait(r);
  8000f4:	83 ec 0c             	sub    $0xc,%esp
  8000f7:	50                   	push   %eax
  8000f8:	e8 e4 21 00 00       	call   8022e1 <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  8000fd:	83 c4 08             	add    $0x8,%esp
  800100:	ff 35 00 30 80 00    	pushl  0x803000
  800106:	68 00 00 00 a0       	push   $0xa0000000
  80010b:	e8 86 08 00 00       	call   800996 <strcmp>
  800110:	83 c4 08             	add    $0x8,%esp
  800113:	85 c0                	test   %eax,%eax
  800115:	b8 c0 28 80 00       	mov    $0x8028c0,%eax
  80011a:	ba c6 28 80 00       	mov    $0x8028c6,%edx
  80011f:	0f 45 c2             	cmovne %edx,%eax
  800122:	50                   	push   %eax
  800123:	68 2a 29 80 00       	push   $0x80292a
  800128:	e8 a4 01 00 00       	call   8002d1 <cprintf>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  80012d:	cc                   	int3   
}
  80012e:	83 c4 10             	add    $0x10,%esp
  800131:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800134:	c9                   	leave  
  800135:	c3                   	ret    
		childofspawn();
  800136:	e8 f8 fe ff ff       	call   800033 <childofspawn>
  80013b:	e9 24 ff ff ff       	jmp    800064 <umain+0x11>
		panic("sys_page_alloc: %e", r);
  800140:	50                   	push   %eax
  800141:	68 cc 28 80 00       	push   $0x8028cc
  800146:	6a 13                	push   $0x13
  800148:	68 df 28 80 00       	push   $0x8028df
  80014d:	e8 a4 00 00 00       	call   8001f6 <_panic>
		panic("fork: %e", r);
  800152:	50                   	push   %eax
  800153:	68 19 2d 80 00       	push   $0x802d19
  800158:	6a 17                	push   $0x17
  80015a:	68 df 28 80 00       	push   $0x8028df
  80015f:	e8 92 00 00 00       	call   8001f6 <_panic>
		strcpy(VA, msg);
  800164:	83 ec 08             	sub    $0x8,%esp
  800167:	ff 35 04 30 80 00    	pushl  0x803004
  80016d:	68 00 00 00 a0       	push   $0xa0000000
  800172:	e8 79 07 00 00       	call   8008f0 <strcpy>
		exit();
  800177:	e8 60 00 00 00       	call   8001dc <exit>
  80017c:	83 c4 10             	add    $0x10,%esp
  80017f:	e9 16 ff ff ff       	jmp    80009a <umain+0x47>
		panic("spawn: %e", r);
  800184:	50                   	push   %eax
  800185:	68 20 29 80 00       	push   $0x802920
  80018a:	6a 21                	push   $0x21
  80018c:	68 df 28 80 00       	push   $0x8028df
  800191:	e8 60 00 00 00       	call   8001f6 <_panic>

00800196 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800196:	55                   	push   %ebp
  800197:	89 e5                	mov    %esp,%ebp
  800199:	56                   	push   %esi
  80019a:	53                   	push   %ebx
  80019b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80019e:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  8001a1:	e8 05 0b 00 00       	call   800cab <sys_getenvid>
	thisenv = envs + ENVX(envid); 
  8001a6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001ab:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001ae:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001b3:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001b8:	85 db                	test   %ebx,%ebx
  8001ba:	7e 07                	jle    8001c3 <libmain+0x2d>
		binaryname = argv[0];
  8001bc:	8b 06                	mov    (%esi),%eax
  8001be:	a3 08 30 80 00       	mov    %eax,0x803008

	// call user main routine
	umain(argc, argv);
  8001c3:	83 ec 08             	sub    $0x8,%esp
  8001c6:	56                   	push   %esi
  8001c7:	53                   	push   %ebx
  8001c8:	e8 86 fe ff ff       	call   800053 <umain>

	// exit gracefully
	exit();
  8001cd:	e8 0a 00 00 00       	call   8001dc <exit>
}
  8001d2:	83 c4 10             	add    $0x10,%esp
  8001d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001d8:	5b                   	pop    %ebx
  8001d9:	5e                   	pop    %esi
  8001da:	5d                   	pop    %ebp
  8001db:	c3                   	ret    

008001dc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001dc:	55                   	push   %ebp
  8001dd:	89 e5                	mov    %esp,%ebp
  8001df:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001e2:	e8 bb 11 00 00       	call   8013a2 <close_all>
	sys_env_destroy(0);
  8001e7:	83 ec 0c             	sub    $0xc,%esp
  8001ea:	6a 00                	push   $0x0
  8001ec:	e8 79 0a 00 00       	call   800c6a <sys_env_destroy>
}
  8001f1:	83 c4 10             	add    $0x10,%esp
  8001f4:	c9                   	leave  
  8001f5:	c3                   	ret    

008001f6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001f6:	55                   	push   %ebp
  8001f7:	89 e5                	mov    %esp,%ebp
  8001f9:	56                   	push   %esi
  8001fa:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001fb:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001fe:	8b 35 08 30 80 00    	mov    0x803008,%esi
  800204:	e8 a2 0a 00 00       	call   800cab <sys_getenvid>
  800209:	83 ec 0c             	sub    $0xc,%esp
  80020c:	ff 75 0c             	pushl  0xc(%ebp)
  80020f:	ff 75 08             	pushl  0x8(%ebp)
  800212:	56                   	push   %esi
  800213:	50                   	push   %eax
  800214:	68 70 29 80 00       	push   $0x802970
  800219:	e8 b3 00 00 00       	call   8002d1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80021e:	83 c4 18             	add    $0x18,%esp
  800221:	53                   	push   %ebx
  800222:	ff 75 10             	pushl  0x10(%ebp)
  800225:	e8 56 00 00 00       	call   800280 <vcprintf>
	cprintf("\n");
  80022a:	c7 04 24 d2 2e 80 00 	movl   $0x802ed2,(%esp)
  800231:	e8 9b 00 00 00       	call   8002d1 <cprintf>
  800236:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800239:	cc                   	int3   
  80023a:	eb fd                	jmp    800239 <_panic+0x43>

0080023c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80023c:	55                   	push   %ebp
  80023d:	89 e5                	mov    %esp,%ebp
  80023f:	53                   	push   %ebx
  800240:	83 ec 04             	sub    $0x4,%esp
  800243:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800246:	8b 13                	mov    (%ebx),%edx
  800248:	8d 42 01             	lea    0x1(%edx),%eax
  80024b:	89 03                	mov    %eax,(%ebx)
  80024d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800250:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800254:	3d ff 00 00 00       	cmp    $0xff,%eax
  800259:	74 09                	je     800264 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80025b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80025f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800262:	c9                   	leave  
  800263:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800264:	83 ec 08             	sub    $0x8,%esp
  800267:	68 ff 00 00 00       	push   $0xff
  80026c:	8d 43 08             	lea    0x8(%ebx),%eax
  80026f:	50                   	push   %eax
  800270:	e8 b8 09 00 00       	call   800c2d <sys_cputs>
		b->idx = 0;
  800275:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80027b:	83 c4 10             	add    $0x10,%esp
  80027e:	eb db                	jmp    80025b <putch+0x1f>

00800280 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800289:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800290:	00 00 00 
	b.cnt = 0;
  800293:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80029a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80029d:	ff 75 0c             	pushl  0xc(%ebp)
  8002a0:	ff 75 08             	pushl  0x8(%ebp)
  8002a3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002a9:	50                   	push   %eax
  8002aa:	68 3c 02 80 00       	push   $0x80023c
  8002af:	e8 1a 01 00 00       	call   8003ce <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002b4:	83 c4 08             	add    $0x8,%esp
  8002b7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002bd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002c3:	50                   	push   %eax
  8002c4:	e8 64 09 00 00       	call   800c2d <sys_cputs>

	return b.cnt;
}
  8002c9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002cf:	c9                   	leave  
  8002d0:	c3                   	ret    

008002d1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002d1:	55                   	push   %ebp
  8002d2:	89 e5                	mov    %esp,%ebp
  8002d4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002d7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002da:	50                   	push   %eax
  8002db:	ff 75 08             	pushl  0x8(%ebp)
  8002de:	e8 9d ff ff ff       	call   800280 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002e3:	c9                   	leave  
  8002e4:	c3                   	ret    

008002e5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002e5:	55                   	push   %ebp
  8002e6:	89 e5                	mov    %esp,%ebp
  8002e8:	57                   	push   %edi
  8002e9:	56                   	push   %esi
  8002ea:	53                   	push   %ebx
  8002eb:	83 ec 1c             	sub    $0x1c,%esp
  8002ee:	89 c7                	mov    %eax,%edi
  8002f0:	89 d6                	mov    %edx,%esi
  8002f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002f8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002fb:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002fe:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800301:	bb 00 00 00 00       	mov    $0x0,%ebx
  800306:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800309:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80030c:	39 d3                	cmp    %edx,%ebx
  80030e:	72 05                	jb     800315 <printnum+0x30>
  800310:	39 45 10             	cmp    %eax,0x10(%ebp)
  800313:	77 7a                	ja     80038f <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800315:	83 ec 0c             	sub    $0xc,%esp
  800318:	ff 75 18             	pushl  0x18(%ebp)
  80031b:	8b 45 14             	mov    0x14(%ebp),%eax
  80031e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800321:	53                   	push   %ebx
  800322:	ff 75 10             	pushl  0x10(%ebp)
  800325:	83 ec 08             	sub    $0x8,%esp
  800328:	ff 75 e4             	pushl  -0x1c(%ebp)
  80032b:	ff 75 e0             	pushl  -0x20(%ebp)
  80032e:	ff 75 dc             	pushl  -0x24(%ebp)
  800331:	ff 75 d8             	pushl  -0x28(%ebp)
  800334:	e8 47 23 00 00       	call   802680 <__udivdi3>
  800339:	83 c4 18             	add    $0x18,%esp
  80033c:	52                   	push   %edx
  80033d:	50                   	push   %eax
  80033e:	89 f2                	mov    %esi,%edx
  800340:	89 f8                	mov    %edi,%eax
  800342:	e8 9e ff ff ff       	call   8002e5 <printnum>
  800347:	83 c4 20             	add    $0x20,%esp
  80034a:	eb 13                	jmp    80035f <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80034c:	83 ec 08             	sub    $0x8,%esp
  80034f:	56                   	push   %esi
  800350:	ff 75 18             	pushl  0x18(%ebp)
  800353:	ff d7                	call   *%edi
  800355:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800358:	83 eb 01             	sub    $0x1,%ebx
  80035b:	85 db                	test   %ebx,%ebx
  80035d:	7f ed                	jg     80034c <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80035f:	83 ec 08             	sub    $0x8,%esp
  800362:	56                   	push   %esi
  800363:	83 ec 04             	sub    $0x4,%esp
  800366:	ff 75 e4             	pushl  -0x1c(%ebp)
  800369:	ff 75 e0             	pushl  -0x20(%ebp)
  80036c:	ff 75 dc             	pushl  -0x24(%ebp)
  80036f:	ff 75 d8             	pushl  -0x28(%ebp)
  800372:	e8 29 24 00 00       	call   8027a0 <__umoddi3>
  800377:	83 c4 14             	add    $0x14,%esp
  80037a:	0f be 80 93 29 80 00 	movsbl 0x802993(%eax),%eax
  800381:	50                   	push   %eax
  800382:	ff d7                	call   *%edi
}
  800384:	83 c4 10             	add    $0x10,%esp
  800387:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80038a:	5b                   	pop    %ebx
  80038b:	5e                   	pop    %esi
  80038c:	5f                   	pop    %edi
  80038d:	5d                   	pop    %ebp
  80038e:	c3                   	ret    
  80038f:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800392:	eb c4                	jmp    800358 <printnum+0x73>

00800394 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800394:	55                   	push   %ebp
  800395:	89 e5                	mov    %esp,%ebp
  800397:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80039a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80039e:	8b 10                	mov    (%eax),%edx
  8003a0:	3b 50 04             	cmp    0x4(%eax),%edx
  8003a3:	73 0a                	jae    8003af <sprintputch+0x1b>
		*b->buf++ = ch;
  8003a5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003a8:	89 08                	mov    %ecx,(%eax)
  8003aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ad:	88 02                	mov    %al,(%edx)
}
  8003af:	5d                   	pop    %ebp
  8003b0:	c3                   	ret    

008003b1 <printfmt>:
{
  8003b1:	55                   	push   %ebp
  8003b2:	89 e5                	mov    %esp,%ebp
  8003b4:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8003b7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003ba:	50                   	push   %eax
  8003bb:	ff 75 10             	pushl  0x10(%ebp)
  8003be:	ff 75 0c             	pushl  0xc(%ebp)
  8003c1:	ff 75 08             	pushl  0x8(%ebp)
  8003c4:	e8 05 00 00 00       	call   8003ce <vprintfmt>
}
  8003c9:	83 c4 10             	add    $0x10,%esp
  8003cc:	c9                   	leave  
  8003cd:	c3                   	ret    

008003ce <vprintfmt>:
{
  8003ce:	55                   	push   %ebp
  8003cf:	89 e5                	mov    %esp,%ebp
  8003d1:	57                   	push   %edi
  8003d2:	56                   	push   %esi
  8003d3:	53                   	push   %ebx
  8003d4:	83 ec 2c             	sub    $0x2c,%esp
  8003d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8003da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003dd:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003e0:	e9 c1 03 00 00       	jmp    8007a6 <vprintfmt+0x3d8>
		padc = ' ';
  8003e5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8003e9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003f0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8003f7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003fe:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800403:	8d 47 01             	lea    0x1(%edi),%eax
  800406:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800409:	0f b6 17             	movzbl (%edi),%edx
  80040c:	8d 42 dd             	lea    -0x23(%edx),%eax
  80040f:	3c 55                	cmp    $0x55,%al
  800411:	0f 87 12 04 00 00    	ja     800829 <vprintfmt+0x45b>
  800417:	0f b6 c0             	movzbl %al,%eax
  80041a:	ff 24 85 e0 2a 80 00 	jmp    *0x802ae0(,%eax,4)
  800421:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800424:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800428:	eb d9                	jmp    800403 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80042a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80042d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800431:	eb d0                	jmp    800403 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800433:	0f b6 d2             	movzbl %dl,%edx
  800436:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800439:	b8 00 00 00 00       	mov    $0x0,%eax
  80043e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800441:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800444:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800448:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80044b:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80044e:	83 f9 09             	cmp    $0x9,%ecx
  800451:	77 55                	ja     8004a8 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800453:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800456:	eb e9                	jmp    800441 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  800458:	8b 45 14             	mov    0x14(%ebp),%eax
  80045b:	8b 00                	mov    (%eax),%eax
  80045d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800460:	8b 45 14             	mov    0x14(%ebp),%eax
  800463:	8d 40 04             	lea    0x4(%eax),%eax
  800466:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800469:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80046c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800470:	79 91                	jns    800403 <vprintfmt+0x35>
				width = precision, precision = -1;
  800472:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800475:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800478:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80047f:	eb 82                	jmp    800403 <vprintfmt+0x35>
  800481:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800484:	85 c0                	test   %eax,%eax
  800486:	ba 00 00 00 00       	mov    $0x0,%edx
  80048b:	0f 49 d0             	cmovns %eax,%edx
  80048e:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800491:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800494:	e9 6a ff ff ff       	jmp    800403 <vprintfmt+0x35>
  800499:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80049c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004a3:	e9 5b ff ff ff       	jmp    800403 <vprintfmt+0x35>
  8004a8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004ab:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004ae:	eb bc                	jmp    80046c <vprintfmt+0x9e>
			lflag++;
  8004b0:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8004b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004b6:	e9 48 ff ff ff       	jmp    800403 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8004bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004be:	8d 78 04             	lea    0x4(%eax),%edi
  8004c1:	83 ec 08             	sub    $0x8,%esp
  8004c4:	53                   	push   %ebx
  8004c5:	ff 30                	pushl  (%eax)
  8004c7:	ff d6                	call   *%esi
			break;
  8004c9:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004cc:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8004cf:	e9 cf 02 00 00       	jmp    8007a3 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8004d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d7:	8d 78 04             	lea    0x4(%eax),%edi
  8004da:	8b 00                	mov    (%eax),%eax
  8004dc:	99                   	cltd   
  8004dd:	31 d0                	xor    %edx,%eax
  8004df:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004e1:	83 f8 0f             	cmp    $0xf,%eax
  8004e4:	7f 23                	jg     800509 <vprintfmt+0x13b>
  8004e6:	8b 14 85 40 2c 80 00 	mov    0x802c40(,%eax,4),%edx
  8004ed:	85 d2                	test   %edx,%edx
  8004ef:	74 18                	je     800509 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8004f1:	52                   	push   %edx
  8004f2:	68 05 2e 80 00       	push   $0x802e05
  8004f7:	53                   	push   %ebx
  8004f8:	56                   	push   %esi
  8004f9:	e8 b3 fe ff ff       	call   8003b1 <printfmt>
  8004fe:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800501:	89 7d 14             	mov    %edi,0x14(%ebp)
  800504:	e9 9a 02 00 00       	jmp    8007a3 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  800509:	50                   	push   %eax
  80050a:	68 ab 29 80 00       	push   $0x8029ab
  80050f:	53                   	push   %ebx
  800510:	56                   	push   %esi
  800511:	e8 9b fe ff ff       	call   8003b1 <printfmt>
  800516:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800519:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80051c:	e9 82 02 00 00       	jmp    8007a3 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  800521:	8b 45 14             	mov    0x14(%ebp),%eax
  800524:	83 c0 04             	add    $0x4,%eax
  800527:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80052a:	8b 45 14             	mov    0x14(%ebp),%eax
  80052d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80052f:	85 ff                	test   %edi,%edi
  800531:	b8 a4 29 80 00       	mov    $0x8029a4,%eax
  800536:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800539:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80053d:	0f 8e bd 00 00 00    	jle    800600 <vprintfmt+0x232>
  800543:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800547:	75 0e                	jne    800557 <vprintfmt+0x189>
  800549:	89 75 08             	mov    %esi,0x8(%ebp)
  80054c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80054f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800552:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800555:	eb 6d                	jmp    8005c4 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  800557:	83 ec 08             	sub    $0x8,%esp
  80055a:	ff 75 d0             	pushl  -0x30(%ebp)
  80055d:	57                   	push   %edi
  80055e:	e8 6e 03 00 00       	call   8008d1 <strnlen>
  800563:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800566:	29 c1                	sub    %eax,%ecx
  800568:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80056b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80056e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800572:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800575:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800578:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  80057a:	eb 0f                	jmp    80058b <vprintfmt+0x1bd>
					putch(padc, putdat);
  80057c:	83 ec 08             	sub    $0x8,%esp
  80057f:	53                   	push   %ebx
  800580:	ff 75 e0             	pushl  -0x20(%ebp)
  800583:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800585:	83 ef 01             	sub    $0x1,%edi
  800588:	83 c4 10             	add    $0x10,%esp
  80058b:	85 ff                	test   %edi,%edi
  80058d:	7f ed                	jg     80057c <vprintfmt+0x1ae>
  80058f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800592:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800595:	85 c9                	test   %ecx,%ecx
  800597:	b8 00 00 00 00       	mov    $0x0,%eax
  80059c:	0f 49 c1             	cmovns %ecx,%eax
  80059f:	29 c1                	sub    %eax,%ecx
  8005a1:	89 75 08             	mov    %esi,0x8(%ebp)
  8005a4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005a7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005aa:	89 cb                	mov    %ecx,%ebx
  8005ac:	eb 16                	jmp    8005c4 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8005ae:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005b2:	75 31                	jne    8005e5 <vprintfmt+0x217>
					putch(ch, putdat);
  8005b4:	83 ec 08             	sub    $0x8,%esp
  8005b7:	ff 75 0c             	pushl  0xc(%ebp)
  8005ba:	50                   	push   %eax
  8005bb:	ff 55 08             	call   *0x8(%ebp)
  8005be:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c1:	83 eb 01             	sub    $0x1,%ebx
  8005c4:	83 c7 01             	add    $0x1,%edi
  8005c7:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8005cb:	0f be c2             	movsbl %dl,%eax
  8005ce:	85 c0                	test   %eax,%eax
  8005d0:	74 59                	je     80062b <vprintfmt+0x25d>
  8005d2:	85 f6                	test   %esi,%esi
  8005d4:	78 d8                	js     8005ae <vprintfmt+0x1e0>
  8005d6:	83 ee 01             	sub    $0x1,%esi
  8005d9:	79 d3                	jns    8005ae <vprintfmt+0x1e0>
  8005db:	89 df                	mov    %ebx,%edi
  8005dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8005e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005e3:	eb 37                	jmp    80061c <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8005e5:	0f be d2             	movsbl %dl,%edx
  8005e8:	83 ea 20             	sub    $0x20,%edx
  8005eb:	83 fa 5e             	cmp    $0x5e,%edx
  8005ee:	76 c4                	jbe    8005b4 <vprintfmt+0x1e6>
					putch('?', putdat);
  8005f0:	83 ec 08             	sub    $0x8,%esp
  8005f3:	ff 75 0c             	pushl  0xc(%ebp)
  8005f6:	6a 3f                	push   $0x3f
  8005f8:	ff 55 08             	call   *0x8(%ebp)
  8005fb:	83 c4 10             	add    $0x10,%esp
  8005fe:	eb c1                	jmp    8005c1 <vprintfmt+0x1f3>
  800600:	89 75 08             	mov    %esi,0x8(%ebp)
  800603:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800606:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800609:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80060c:	eb b6                	jmp    8005c4 <vprintfmt+0x1f6>
				putch(' ', putdat);
  80060e:	83 ec 08             	sub    $0x8,%esp
  800611:	53                   	push   %ebx
  800612:	6a 20                	push   $0x20
  800614:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800616:	83 ef 01             	sub    $0x1,%edi
  800619:	83 c4 10             	add    $0x10,%esp
  80061c:	85 ff                	test   %edi,%edi
  80061e:	7f ee                	jg     80060e <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800620:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800623:	89 45 14             	mov    %eax,0x14(%ebp)
  800626:	e9 78 01 00 00       	jmp    8007a3 <vprintfmt+0x3d5>
  80062b:	89 df                	mov    %ebx,%edi
  80062d:	8b 75 08             	mov    0x8(%ebp),%esi
  800630:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800633:	eb e7                	jmp    80061c <vprintfmt+0x24e>
	if (lflag >= 2)
  800635:	83 f9 01             	cmp    $0x1,%ecx
  800638:	7e 3f                	jle    800679 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  80063a:	8b 45 14             	mov    0x14(%ebp),%eax
  80063d:	8b 50 04             	mov    0x4(%eax),%edx
  800640:	8b 00                	mov    (%eax),%eax
  800642:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800645:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800648:	8b 45 14             	mov    0x14(%ebp),%eax
  80064b:	8d 40 08             	lea    0x8(%eax),%eax
  80064e:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800651:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800655:	79 5c                	jns    8006b3 <vprintfmt+0x2e5>
				putch('-', putdat);
  800657:	83 ec 08             	sub    $0x8,%esp
  80065a:	53                   	push   %ebx
  80065b:	6a 2d                	push   $0x2d
  80065d:	ff d6                	call   *%esi
				num = -(long long) num;
  80065f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800662:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800665:	f7 da                	neg    %edx
  800667:	83 d1 00             	adc    $0x0,%ecx
  80066a:	f7 d9                	neg    %ecx
  80066c:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80066f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800674:	e9 10 01 00 00       	jmp    800789 <vprintfmt+0x3bb>
	else if (lflag)
  800679:	85 c9                	test   %ecx,%ecx
  80067b:	75 1b                	jne    800698 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  80067d:	8b 45 14             	mov    0x14(%ebp),%eax
  800680:	8b 00                	mov    (%eax),%eax
  800682:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800685:	89 c1                	mov    %eax,%ecx
  800687:	c1 f9 1f             	sar    $0x1f,%ecx
  80068a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80068d:	8b 45 14             	mov    0x14(%ebp),%eax
  800690:	8d 40 04             	lea    0x4(%eax),%eax
  800693:	89 45 14             	mov    %eax,0x14(%ebp)
  800696:	eb b9                	jmp    800651 <vprintfmt+0x283>
		return va_arg(*ap, long);
  800698:	8b 45 14             	mov    0x14(%ebp),%eax
  80069b:	8b 00                	mov    (%eax),%eax
  80069d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006a0:	89 c1                	mov    %eax,%ecx
  8006a2:	c1 f9 1f             	sar    $0x1f,%ecx
  8006a5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ab:	8d 40 04             	lea    0x4(%eax),%eax
  8006ae:	89 45 14             	mov    %eax,0x14(%ebp)
  8006b1:	eb 9e                	jmp    800651 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8006b3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006b6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8006b9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006be:	e9 c6 00 00 00       	jmp    800789 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8006c3:	83 f9 01             	cmp    $0x1,%ecx
  8006c6:	7e 18                	jle    8006e0 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8006c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cb:	8b 10                	mov    (%eax),%edx
  8006cd:	8b 48 04             	mov    0x4(%eax),%ecx
  8006d0:	8d 40 08             	lea    0x8(%eax),%eax
  8006d3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006d6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006db:	e9 a9 00 00 00       	jmp    800789 <vprintfmt+0x3bb>
	else if (lflag)
  8006e0:	85 c9                	test   %ecx,%ecx
  8006e2:	75 1a                	jne    8006fe <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  8006e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e7:	8b 10                	mov    (%eax),%edx
  8006e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ee:	8d 40 04             	lea    0x4(%eax),%eax
  8006f1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006f4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006f9:	e9 8b 00 00 00       	jmp    800789 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8006fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800701:	8b 10                	mov    (%eax),%edx
  800703:	b9 00 00 00 00       	mov    $0x0,%ecx
  800708:	8d 40 04             	lea    0x4(%eax),%eax
  80070b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80070e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800713:	eb 74                	jmp    800789 <vprintfmt+0x3bb>
	if (lflag >= 2)
  800715:	83 f9 01             	cmp    $0x1,%ecx
  800718:	7e 15                	jle    80072f <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  80071a:	8b 45 14             	mov    0x14(%ebp),%eax
  80071d:	8b 10                	mov    (%eax),%edx
  80071f:	8b 48 04             	mov    0x4(%eax),%ecx
  800722:	8d 40 08             	lea    0x8(%eax),%eax
  800725:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800728:	b8 08 00 00 00       	mov    $0x8,%eax
  80072d:	eb 5a                	jmp    800789 <vprintfmt+0x3bb>
	else if (lflag)
  80072f:	85 c9                	test   %ecx,%ecx
  800731:	75 17                	jne    80074a <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  800733:	8b 45 14             	mov    0x14(%ebp),%eax
  800736:	8b 10                	mov    (%eax),%edx
  800738:	b9 00 00 00 00       	mov    $0x0,%ecx
  80073d:	8d 40 04             	lea    0x4(%eax),%eax
  800740:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800743:	b8 08 00 00 00       	mov    $0x8,%eax
  800748:	eb 3f                	jmp    800789 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80074a:	8b 45 14             	mov    0x14(%ebp),%eax
  80074d:	8b 10                	mov    (%eax),%edx
  80074f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800754:	8d 40 04             	lea    0x4(%eax),%eax
  800757:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80075a:	b8 08 00 00 00       	mov    $0x8,%eax
  80075f:	eb 28                	jmp    800789 <vprintfmt+0x3bb>
			putch('0', putdat);
  800761:	83 ec 08             	sub    $0x8,%esp
  800764:	53                   	push   %ebx
  800765:	6a 30                	push   $0x30
  800767:	ff d6                	call   *%esi
			putch('x', putdat);
  800769:	83 c4 08             	add    $0x8,%esp
  80076c:	53                   	push   %ebx
  80076d:	6a 78                	push   $0x78
  80076f:	ff d6                	call   *%esi
			num = (unsigned long long)
  800771:	8b 45 14             	mov    0x14(%ebp),%eax
  800774:	8b 10                	mov    (%eax),%edx
  800776:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80077b:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80077e:	8d 40 04             	lea    0x4(%eax),%eax
  800781:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800784:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800789:	83 ec 0c             	sub    $0xc,%esp
  80078c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800790:	57                   	push   %edi
  800791:	ff 75 e0             	pushl  -0x20(%ebp)
  800794:	50                   	push   %eax
  800795:	51                   	push   %ecx
  800796:	52                   	push   %edx
  800797:	89 da                	mov    %ebx,%edx
  800799:	89 f0                	mov    %esi,%eax
  80079b:	e8 45 fb ff ff       	call   8002e5 <printnum>
			break;
  8007a0:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8007a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007a6:	83 c7 01             	add    $0x1,%edi
  8007a9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007ad:	83 f8 25             	cmp    $0x25,%eax
  8007b0:	0f 84 2f fc ff ff    	je     8003e5 <vprintfmt+0x17>
			if (ch == '\0')
  8007b6:	85 c0                	test   %eax,%eax
  8007b8:	0f 84 8b 00 00 00    	je     800849 <vprintfmt+0x47b>
			putch(ch, putdat);
  8007be:	83 ec 08             	sub    $0x8,%esp
  8007c1:	53                   	push   %ebx
  8007c2:	50                   	push   %eax
  8007c3:	ff d6                	call   *%esi
  8007c5:	83 c4 10             	add    $0x10,%esp
  8007c8:	eb dc                	jmp    8007a6 <vprintfmt+0x3d8>
	if (lflag >= 2)
  8007ca:	83 f9 01             	cmp    $0x1,%ecx
  8007cd:	7e 15                	jle    8007e4 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  8007cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d2:	8b 10                	mov    (%eax),%edx
  8007d4:	8b 48 04             	mov    0x4(%eax),%ecx
  8007d7:	8d 40 08             	lea    0x8(%eax),%eax
  8007da:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007dd:	b8 10 00 00 00       	mov    $0x10,%eax
  8007e2:	eb a5                	jmp    800789 <vprintfmt+0x3bb>
	else if (lflag)
  8007e4:	85 c9                	test   %ecx,%ecx
  8007e6:	75 17                	jne    8007ff <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  8007e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007eb:	8b 10                	mov    (%eax),%edx
  8007ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007f2:	8d 40 04             	lea    0x4(%eax),%eax
  8007f5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007f8:	b8 10 00 00 00       	mov    $0x10,%eax
  8007fd:	eb 8a                	jmp    800789 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8007ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800802:	8b 10                	mov    (%eax),%edx
  800804:	b9 00 00 00 00       	mov    $0x0,%ecx
  800809:	8d 40 04             	lea    0x4(%eax),%eax
  80080c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80080f:	b8 10 00 00 00       	mov    $0x10,%eax
  800814:	e9 70 ff ff ff       	jmp    800789 <vprintfmt+0x3bb>
			putch(ch, putdat);
  800819:	83 ec 08             	sub    $0x8,%esp
  80081c:	53                   	push   %ebx
  80081d:	6a 25                	push   $0x25
  80081f:	ff d6                	call   *%esi
			break;
  800821:	83 c4 10             	add    $0x10,%esp
  800824:	e9 7a ff ff ff       	jmp    8007a3 <vprintfmt+0x3d5>
			putch('%', putdat);
  800829:	83 ec 08             	sub    $0x8,%esp
  80082c:	53                   	push   %ebx
  80082d:	6a 25                	push   $0x25
  80082f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800831:	83 c4 10             	add    $0x10,%esp
  800834:	89 f8                	mov    %edi,%eax
  800836:	eb 03                	jmp    80083b <vprintfmt+0x46d>
  800838:	83 e8 01             	sub    $0x1,%eax
  80083b:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80083f:	75 f7                	jne    800838 <vprintfmt+0x46a>
  800841:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800844:	e9 5a ff ff ff       	jmp    8007a3 <vprintfmt+0x3d5>
}
  800849:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80084c:	5b                   	pop    %ebx
  80084d:	5e                   	pop    %esi
  80084e:	5f                   	pop    %edi
  80084f:	5d                   	pop    %ebp
  800850:	c3                   	ret    

00800851 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	83 ec 18             	sub    $0x18,%esp
  800857:	8b 45 08             	mov    0x8(%ebp),%eax
  80085a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80085d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800860:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800864:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800867:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80086e:	85 c0                	test   %eax,%eax
  800870:	74 26                	je     800898 <vsnprintf+0x47>
  800872:	85 d2                	test   %edx,%edx
  800874:	7e 22                	jle    800898 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800876:	ff 75 14             	pushl  0x14(%ebp)
  800879:	ff 75 10             	pushl  0x10(%ebp)
  80087c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80087f:	50                   	push   %eax
  800880:	68 94 03 80 00       	push   $0x800394
  800885:	e8 44 fb ff ff       	call   8003ce <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80088a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80088d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800890:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800893:	83 c4 10             	add    $0x10,%esp
}
  800896:	c9                   	leave  
  800897:	c3                   	ret    
		return -E_INVAL;
  800898:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80089d:	eb f7                	jmp    800896 <vsnprintf+0x45>

0080089f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008a5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008a8:	50                   	push   %eax
  8008a9:	ff 75 10             	pushl  0x10(%ebp)
  8008ac:	ff 75 0c             	pushl  0xc(%ebp)
  8008af:	ff 75 08             	pushl  0x8(%ebp)
  8008b2:	e8 9a ff ff ff       	call   800851 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008b7:	c9                   	leave  
  8008b8:	c3                   	ret    

008008b9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c4:	eb 03                	jmp    8008c9 <strlen+0x10>
		n++;
  8008c6:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008c9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008cd:	75 f7                	jne    8008c6 <strlen+0xd>
	return n;
}
  8008cf:	5d                   	pop    %ebp
  8008d0:	c3                   	ret    

008008d1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008d1:	55                   	push   %ebp
  8008d2:	89 e5                	mov    %esp,%ebp
  8008d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d7:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008da:	b8 00 00 00 00       	mov    $0x0,%eax
  8008df:	eb 03                	jmp    8008e4 <strnlen+0x13>
		n++;
  8008e1:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008e4:	39 d0                	cmp    %edx,%eax
  8008e6:	74 06                	je     8008ee <strnlen+0x1d>
  8008e8:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008ec:	75 f3                	jne    8008e1 <strnlen+0x10>
	return n;
}
  8008ee:	5d                   	pop    %ebp
  8008ef:	c3                   	ret    

008008f0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
  8008f3:	53                   	push   %ebx
  8008f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008fa:	89 c2                	mov    %eax,%edx
  8008fc:	83 c1 01             	add    $0x1,%ecx
  8008ff:	83 c2 01             	add    $0x1,%edx
  800902:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800906:	88 5a ff             	mov    %bl,-0x1(%edx)
  800909:	84 db                	test   %bl,%bl
  80090b:	75 ef                	jne    8008fc <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80090d:	5b                   	pop    %ebx
  80090e:	5d                   	pop    %ebp
  80090f:	c3                   	ret    

00800910 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	53                   	push   %ebx
  800914:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800917:	53                   	push   %ebx
  800918:	e8 9c ff ff ff       	call   8008b9 <strlen>
  80091d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800920:	ff 75 0c             	pushl  0xc(%ebp)
  800923:	01 d8                	add    %ebx,%eax
  800925:	50                   	push   %eax
  800926:	e8 c5 ff ff ff       	call   8008f0 <strcpy>
	return dst;
}
  80092b:	89 d8                	mov    %ebx,%eax
  80092d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800930:	c9                   	leave  
  800931:	c3                   	ret    

00800932 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
  800935:	56                   	push   %esi
  800936:	53                   	push   %ebx
  800937:	8b 75 08             	mov    0x8(%ebp),%esi
  80093a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80093d:	89 f3                	mov    %esi,%ebx
  80093f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800942:	89 f2                	mov    %esi,%edx
  800944:	eb 0f                	jmp    800955 <strncpy+0x23>
		*dst++ = *src;
  800946:	83 c2 01             	add    $0x1,%edx
  800949:	0f b6 01             	movzbl (%ecx),%eax
  80094c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80094f:	80 39 01             	cmpb   $0x1,(%ecx)
  800952:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800955:	39 da                	cmp    %ebx,%edx
  800957:	75 ed                	jne    800946 <strncpy+0x14>
	}
	return ret;
}
  800959:	89 f0                	mov    %esi,%eax
  80095b:	5b                   	pop    %ebx
  80095c:	5e                   	pop    %esi
  80095d:	5d                   	pop    %ebp
  80095e:	c3                   	ret    

0080095f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	56                   	push   %esi
  800963:	53                   	push   %ebx
  800964:	8b 75 08             	mov    0x8(%ebp),%esi
  800967:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80096d:	89 f0                	mov    %esi,%eax
  80096f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800973:	85 c9                	test   %ecx,%ecx
  800975:	75 0b                	jne    800982 <strlcpy+0x23>
  800977:	eb 17                	jmp    800990 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800979:	83 c2 01             	add    $0x1,%edx
  80097c:	83 c0 01             	add    $0x1,%eax
  80097f:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800982:	39 d8                	cmp    %ebx,%eax
  800984:	74 07                	je     80098d <strlcpy+0x2e>
  800986:	0f b6 0a             	movzbl (%edx),%ecx
  800989:	84 c9                	test   %cl,%cl
  80098b:	75 ec                	jne    800979 <strlcpy+0x1a>
		*dst = '\0';
  80098d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800990:	29 f0                	sub    %esi,%eax
}
  800992:	5b                   	pop    %ebx
  800993:	5e                   	pop    %esi
  800994:	5d                   	pop    %ebp
  800995:	c3                   	ret    

00800996 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80099c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80099f:	eb 06                	jmp    8009a7 <strcmp+0x11>
		p++, q++;
  8009a1:	83 c1 01             	add    $0x1,%ecx
  8009a4:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009a7:	0f b6 01             	movzbl (%ecx),%eax
  8009aa:	84 c0                	test   %al,%al
  8009ac:	74 04                	je     8009b2 <strcmp+0x1c>
  8009ae:	3a 02                	cmp    (%edx),%al
  8009b0:	74 ef                	je     8009a1 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b2:	0f b6 c0             	movzbl %al,%eax
  8009b5:	0f b6 12             	movzbl (%edx),%edx
  8009b8:	29 d0                	sub    %edx,%eax
}
  8009ba:	5d                   	pop    %ebp
  8009bb:	c3                   	ret    

008009bc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	53                   	push   %ebx
  8009c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c6:	89 c3                	mov    %eax,%ebx
  8009c8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009cb:	eb 06                	jmp    8009d3 <strncmp+0x17>
		n--, p++, q++;
  8009cd:	83 c0 01             	add    $0x1,%eax
  8009d0:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009d3:	39 d8                	cmp    %ebx,%eax
  8009d5:	74 16                	je     8009ed <strncmp+0x31>
  8009d7:	0f b6 08             	movzbl (%eax),%ecx
  8009da:	84 c9                	test   %cl,%cl
  8009dc:	74 04                	je     8009e2 <strncmp+0x26>
  8009de:	3a 0a                	cmp    (%edx),%cl
  8009e0:	74 eb                	je     8009cd <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009e2:	0f b6 00             	movzbl (%eax),%eax
  8009e5:	0f b6 12             	movzbl (%edx),%edx
  8009e8:	29 d0                	sub    %edx,%eax
}
  8009ea:	5b                   	pop    %ebx
  8009eb:	5d                   	pop    %ebp
  8009ec:	c3                   	ret    
		return 0;
  8009ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f2:	eb f6                	jmp    8009ea <strncmp+0x2e>

008009f4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009f4:	55                   	push   %ebp
  8009f5:	89 e5                	mov    %esp,%ebp
  8009f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fa:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009fe:	0f b6 10             	movzbl (%eax),%edx
  800a01:	84 d2                	test   %dl,%dl
  800a03:	74 09                	je     800a0e <strchr+0x1a>
		if (*s == c)
  800a05:	38 ca                	cmp    %cl,%dl
  800a07:	74 0a                	je     800a13 <strchr+0x1f>
	for (; *s; s++)
  800a09:	83 c0 01             	add    $0x1,%eax
  800a0c:	eb f0                	jmp    8009fe <strchr+0xa>
			return (char *) s;
	return 0;
  800a0e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a13:	5d                   	pop    %ebp
  800a14:	c3                   	ret    

00800a15 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a1f:	eb 03                	jmp    800a24 <strfind+0xf>
  800a21:	83 c0 01             	add    $0x1,%eax
  800a24:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a27:	38 ca                	cmp    %cl,%dl
  800a29:	74 04                	je     800a2f <strfind+0x1a>
  800a2b:	84 d2                	test   %dl,%dl
  800a2d:	75 f2                	jne    800a21 <strfind+0xc>
			break;
	return (char *) s;
}
  800a2f:	5d                   	pop    %ebp
  800a30:	c3                   	ret    

00800a31 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a31:	55                   	push   %ebp
  800a32:	89 e5                	mov    %esp,%ebp
  800a34:	57                   	push   %edi
  800a35:	56                   	push   %esi
  800a36:	53                   	push   %ebx
  800a37:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a3a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a3d:	85 c9                	test   %ecx,%ecx
  800a3f:	74 13                	je     800a54 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a41:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a47:	75 05                	jne    800a4e <memset+0x1d>
  800a49:	f6 c1 03             	test   $0x3,%cl
  800a4c:	74 0d                	je     800a5b <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a51:	fc                   	cld    
  800a52:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a54:	89 f8                	mov    %edi,%eax
  800a56:	5b                   	pop    %ebx
  800a57:	5e                   	pop    %esi
  800a58:	5f                   	pop    %edi
  800a59:	5d                   	pop    %ebp
  800a5a:	c3                   	ret    
		c &= 0xFF;
  800a5b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a5f:	89 d3                	mov    %edx,%ebx
  800a61:	c1 e3 08             	shl    $0x8,%ebx
  800a64:	89 d0                	mov    %edx,%eax
  800a66:	c1 e0 18             	shl    $0x18,%eax
  800a69:	89 d6                	mov    %edx,%esi
  800a6b:	c1 e6 10             	shl    $0x10,%esi
  800a6e:	09 f0                	or     %esi,%eax
  800a70:	09 c2                	or     %eax,%edx
  800a72:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800a74:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a77:	89 d0                	mov    %edx,%eax
  800a79:	fc                   	cld    
  800a7a:	f3 ab                	rep stos %eax,%es:(%edi)
  800a7c:	eb d6                	jmp    800a54 <memset+0x23>

00800a7e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	57                   	push   %edi
  800a82:	56                   	push   %esi
  800a83:	8b 45 08             	mov    0x8(%ebp),%eax
  800a86:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a89:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a8c:	39 c6                	cmp    %eax,%esi
  800a8e:	73 35                	jae    800ac5 <memmove+0x47>
  800a90:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a93:	39 c2                	cmp    %eax,%edx
  800a95:	76 2e                	jbe    800ac5 <memmove+0x47>
		s += n;
		d += n;
  800a97:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a9a:	89 d6                	mov    %edx,%esi
  800a9c:	09 fe                	or     %edi,%esi
  800a9e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aa4:	74 0c                	je     800ab2 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800aa6:	83 ef 01             	sub    $0x1,%edi
  800aa9:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800aac:	fd                   	std    
  800aad:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aaf:	fc                   	cld    
  800ab0:	eb 21                	jmp    800ad3 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab2:	f6 c1 03             	test   $0x3,%cl
  800ab5:	75 ef                	jne    800aa6 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ab7:	83 ef 04             	sub    $0x4,%edi
  800aba:	8d 72 fc             	lea    -0x4(%edx),%esi
  800abd:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800ac0:	fd                   	std    
  800ac1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ac3:	eb ea                	jmp    800aaf <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac5:	89 f2                	mov    %esi,%edx
  800ac7:	09 c2                	or     %eax,%edx
  800ac9:	f6 c2 03             	test   $0x3,%dl
  800acc:	74 09                	je     800ad7 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ace:	89 c7                	mov    %eax,%edi
  800ad0:	fc                   	cld    
  800ad1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ad3:	5e                   	pop    %esi
  800ad4:	5f                   	pop    %edi
  800ad5:	5d                   	pop    %ebp
  800ad6:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad7:	f6 c1 03             	test   $0x3,%cl
  800ada:	75 f2                	jne    800ace <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800adc:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800adf:	89 c7                	mov    %eax,%edi
  800ae1:	fc                   	cld    
  800ae2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ae4:	eb ed                	jmp    800ad3 <memmove+0x55>

00800ae6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ae9:	ff 75 10             	pushl  0x10(%ebp)
  800aec:	ff 75 0c             	pushl  0xc(%ebp)
  800aef:	ff 75 08             	pushl  0x8(%ebp)
  800af2:	e8 87 ff ff ff       	call   800a7e <memmove>
}
  800af7:	c9                   	leave  
  800af8:	c3                   	ret    

00800af9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
  800afc:	56                   	push   %esi
  800afd:	53                   	push   %ebx
  800afe:	8b 45 08             	mov    0x8(%ebp),%eax
  800b01:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b04:	89 c6                	mov    %eax,%esi
  800b06:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b09:	39 f0                	cmp    %esi,%eax
  800b0b:	74 1c                	je     800b29 <memcmp+0x30>
		if (*s1 != *s2)
  800b0d:	0f b6 08             	movzbl (%eax),%ecx
  800b10:	0f b6 1a             	movzbl (%edx),%ebx
  800b13:	38 d9                	cmp    %bl,%cl
  800b15:	75 08                	jne    800b1f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b17:	83 c0 01             	add    $0x1,%eax
  800b1a:	83 c2 01             	add    $0x1,%edx
  800b1d:	eb ea                	jmp    800b09 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b1f:	0f b6 c1             	movzbl %cl,%eax
  800b22:	0f b6 db             	movzbl %bl,%ebx
  800b25:	29 d8                	sub    %ebx,%eax
  800b27:	eb 05                	jmp    800b2e <memcmp+0x35>
	}

	return 0;
  800b29:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b2e:	5b                   	pop    %ebx
  800b2f:	5e                   	pop    %esi
  800b30:	5d                   	pop    %ebp
  800b31:	c3                   	ret    

00800b32 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b32:	55                   	push   %ebp
  800b33:	89 e5                	mov    %esp,%ebp
  800b35:	8b 45 08             	mov    0x8(%ebp),%eax
  800b38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b3b:	89 c2                	mov    %eax,%edx
  800b3d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b40:	39 d0                	cmp    %edx,%eax
  800b42:	73 09                	jae    800b4d <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b44:	38 08                	cmp    %cl,(%eax)
  800b46:	74 05                	je     800b4d <memfind+0x1b>
	for (; s < ends; s++)
  800b48:	83 c0 01             	add    $0x1,%eax
  800b4b:	eb f3                	jmp    800b40 <memfind+0xe>
			break;
	return (void *) s;
}
  800b4d:	5d                   	pop    %ebp
  800b4e:	c3                   	ret    

00800b4f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b4f:	55                   	push   %ebp
  800b50:	89 e5                	mov    %esp,%ebp
  800b52:	57                   	push   %edi
  800b53:	56                   	push   %esi
  800b54:	53                   	push   %ebx
  800b55:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b58:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b5b:	eb 03                	jmp    800b60 <strtol+0x11>
		s++;
  800b5d:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b60:	0f b6 01             	movzbl (%ecx),%eax
  800b63:	3c 20                	cmp    $0x20,%al
  800b65:	74 f6                	je     800b5d <strtol+0xe>
  800b67:	3c 09                	cmp    $0x9,%al
  800b69:	74 f2                	je     800b5d <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b6b:	3c 2b                	cmp    $0x2b,%al
  800b6d:	74 2e                	je     800b9d <strtol+0x4e>
	int neg = 0;
  800b6f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b74:	3c 2d                	cmp    $0x2d,%al
  800b76:	74 2f                	je     800ba7 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b78:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b7e:	75 05                	jne    800b85 <strtol+0x36>
  800b80:	80 39 30             	cmpb   $0x30,(%ecx)
  800b83:	74 2c                	je     800bb1 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b85:	85 db                	test   %ebx,%ebx
  800b87:	75 0a                	jne    800b93 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b89:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800b8e:	80 39 30             	cmpb   $0x30,(%ecx)
  800b91:	74 28                	je     800bbb <strtol+0x6c>
		base = 10;
  800b93:	b8 00 00 00 00       	mov    $0x0,%eax
  800b98:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b9b:	eb 50                	jmp    800bed <strtol+0x9e>
		s++;
  800b9d:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800ba0:	bf 00 00 00 00       	mov    $0x0,%edi
  800ba5:	eb d1                	jmp    800b78 <strtol+0x29>
		s++, neg = 1;
  800ba7:	83 c1 01             	add    $0x1,%ecx
  800baa:	bf 01 00 00 00       	mov    $0x1,%edi
  800baf:	eb c7                	jmp    800b78 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bb1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bb5:	74 0e                	je     800bc5 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800bb7:	85 db                	test   %ebx,%ebx
  800bb9:	75 d8                	jne    800b93 <strtol+0x44>
		s++, base = 8;
  800bbb:	83 c1 01             	add    $0x1,%ecx
  800bbe:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bc3:	eb ce                	jmp    800b93 <strtol+0x44>
		s += 2, base = 16;
  800bc5:	83 c1 02             	add    $0x2,%ecx
  800bc8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bcd:	eb c4                	jmp    800b93 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800bcf:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bd2:	89 f3                	mov    %esi,%ebx
  800bd4:	80 fb 19             	cmp    $0x19,%bl
  800bd7:	77 29                	ja     800c02 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800bd9:	0f be d2             	movsbl %dl,%edx
  800bdc:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bdf:	3b 55 10             	cmp    0x10(%ebp),%edx
  800be2:	7d 30                	jge    800c14 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800be4:	83 c1 01             	add    $0x1,%ecx
  800be7:	0f af 45 10          	imul   0x10(%ebp),%eax
  800beb:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800bed:	0f b6 11             	movzbl (%ecx),%edx
  800bf0:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bf3:	89 f3                	mov    %esi,%ebx
  800bf5:	80 fb 09             	cmp    $0x9,%bl
  800bf8:	77 d5                	ja     800bcf <strtol+0x80>
			dig = *s - '0';
  800bfa:	0f be d2             	movsbl %dl,%edx
  800bfd:	83 ea 30             	sub    $0x30,%edx
  800c00:	eb dd                	jmp    800bdf <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800c02:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c05:	89 f3                	mov    %esi,%ebx
  800c07:	80 fb 19             	cmp    $0x19,%bl
  800c0a:	77 08                	ja     800c14 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c0c:	0f be d2             	movsbl %dl,%edx
  800c0f:	83 ea 37             	sub    $0x37,%edx
  800c12:	eb cb                	jmp    800bdf <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c14:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c18:	74 05                	je     800c1f <strtol+0xd0>
		*endptr = (char *) s;
  800c1a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c1d:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c1f:	89 c2                	mov    %eax,%edx
  800c21:	f7 da                	neg    %edx
  800c23:	85 ff                	test   %edi,%edi
  800c25:	0f 45 c2             	cmovne %edx,%eax
}
  800c28:	5b                   	pop    %ebx
  800c29:	5e                   	pop    %esi
  800c2a:	5f                   	pop    %edi
  800c2b:	5d                   	pop    %ebp
  800c2c:	c3                   	ret    

00800c2d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c2d:	55                   	push   %ebp
  800c2e:	89 e5                	mov    %esp,%ebp
  800c30:	57                   	push   %edi
  800c31:	56                   	push   %esi
  800c32:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c33:	b8 00 00 00 00       	mov    $0x0,%eax
  800c38:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3e:	89 c3                	mov    %eax,%ebx
  800c40:	89 c7                	mov    %eax,%edi
  800c42:	89 c6                	mov    %eax,%esi
  800c44:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c46:	5b                   	pop    %ebx
  800c47:	5e                   	pop    %esi
  800c48:	5f                   	pop    %edi
  800c49:	5d                   	pop    %ebp
  800c4a:	c3                   	ret    

00800c4b <sys_cgetc>:

int
sys_cgetc(void)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	57                   	push   %edi
  800c4f:	56                   	push   %esi
  800c50:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c51:	ba 00 00 00 00       	mov    $0x0,%edx
  800c56:	b8 01 00 00 00       	mov    $0x1,%eax
  800c5b:	89 d1                	mov    %edx,%ecx
  800c5d:	89 d3                	mov    %edx,%ebx
  800c5f:	89 d7                	mov    %edx,%edi
  800c61:	89 d6                	mov    %edx,%esi
  800c63:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c65:	5b                   	pop    %ebx
  800c66:	5e                   	pop    %esi
  800c67:	5f                   	pop    %edi
  800c68:	5d                   	pop    %ebp
  800c69:	c3                   	ret    

00800c6a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c6a:	55                   	push   %ebp
  800c6b:	89 e5                	mov    %esp,%ebp
  800c6d:	57                   	push   %edi
  800c6e:	56                   	push   %esi
  800c6f:	53                   	push   %ebx
  800c70:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c73:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c78:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7b:	b8 03 00 00 00       	mov    $0x3,%eax
  800c80:	89 cb                	mov    %ecx,%ebx
  800c82:	89 cf                	mov    %ecx,%edi
  800c84:	89 ce                	mov    %ecx,%esi
  800c86:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c88:	85 c0                	test   %eax,%eax
  800c8a:	7f 08                	jg     800c94 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8f:	5b                   	pop    %ebx
  800c90:	5e                   	pop    %esi
  800c91:	5f                   	pop    %edi
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c94:	83 ec 0c             	sub    $0xc,%esp
  800c97:	50                   	push   %eax
  800c98:	6a 03                	push   $0x3
  800c9a:	68 9f 2c 80 00       	push   $0x802c9f
  800c9f:	6a 23                	push   $0x23
  800ca1:	68 bc 2c 80 00       	push   $0x802cbc
  800ca6:	e8 4b f5 ff ff       	call   8001f6 <_panic>

00800cab <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	57                   	push   %edi
  800caf:	56                   	push   %esi
  800cb0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cb1:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb6:	b8 02 00 00 00       	mov    $0x2,%eax
  800cbb:	89 d1                	mov    %edx,%ecx
  800cbd:	89 d3                	mov    %edx,%ebx
  800cbf:	89 d7                	mov    %edx,%edi
  800cc1:	89 d6                	mov    %edx,%esi
  800cc3:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cc5:	5b                   	pop    %ebx
  800cc6:	5e                   	pop    %esi
  800cc7:	5f                   	pop    %edi
  800cc8:	5d                   	pop    %ebp
  800cc9:	c3                   	ret    

00800cca <sys_yield>:

void
sys_yield(void)
{
  800cca:	55                   	push   %ebp
  800ccb:	89 e5                	mov    %esp,%ebp
  800ccd:	57                   	push   %edi
  800cce:	56                   	push   %esi
  800ccf:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cd0:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cda:	89 d1                	mov    %edx,%ecx
  800cdc:	89 d3                	mov    %edx,%ebx
  800cde:	89 d7                	mov    %edx,%edi
  800ce0:	89 d6                	mov    %edx,%esi
  800ce2:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ce4:	5b                   	pop    %ebx
  800ce5:	5e                   	pop    %esi
  800ce6:	5f                   	pop    %edi
  800ce7:	5d                   	pop    %ebp
  800ce8:	c3                   	ret    

00800ce9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ce9:	55                   	push   %ebp
  800cea:	89 e5                	mov    %esp,%ebp
  800cec:	57                   	push   %edi
  800ced:	56                   	push   %esi
  800cee:	53                   	push   %ebx
  800cef:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cf2:	be 00 00 00 00       	mov    $0x0,%esi
  800cf7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfd:	b8 04 00 00 00       	mov    $0x4,%eax
  800d02:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d05:	89 f7                	mov    %esi,%edi
  800d07:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d09:	85 c0                	test   %eax,%eax
  800d0b:	7f 08                	jg     800d15 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d10:	5b                   	pop    %ebx
  800d11:	5e                   	pop    %esi
  800d12:	5f                   	pop    %edi
  800d13:	5d                   	pop    %ebp
  800d14:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d15:	83 ec 0c             	sub    $0xc,%esp
  800d18:	50                   	push   %eax
  800d19:	6a 04                	push   $0x4
  800d1b:	68 9f 2c 80 00       	push   $0x802c9f
  800d20:	6a 23                	push   $0x23
  800d22:	68 bc 2c 80 00       	push   $0x802cbc
  800d27:	e8 ca f4 ff ff       	call   8001f6 <_panic>

00800d2c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d2c:	55                   	push   %ebp
  800d2d:	89 e5                	mov    %esp,%ebp
  800d2f:	57                   	push   %edi
  800d30:	56                   	push   %esi
  800d31:	53                   	push   %ebx
  800d32:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d35:	8b 55 08             	mov    0x8(%ebp),%edx
  800d38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3b:	b8 05 00 00 00       	mov    $0x5,%eax
  800d40:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d43:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d46:	8b 75 18             	mov    0x18(%ebp),%esi
  800d49:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d4b:	85 c0                	test   %eax,%eax
  800d4d:	7f 08                	jg     800d57 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d52:	5b                   	pop    %ebx
  800d53:	5e                   	pop    %esi
  800d54:	5f                   	pop    %edi
  800d55:	5d                   	pop    %ebp
  800d56:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d57:	83 ec 0c             	sub    $0xc,%esp
  800d5a:	50                   	push   %eax
  800d5b:	6a 05                	push   $0x5
  800d5d:	68 9f 2c 80 00       	push   $0x802c9f
  800d62:	6a 23                	push   $0x23
  800d64:	68 bc 2c 80 00       	push   $0x802cbc
  800d69:	e8 88 f4 ff ff       	call   8001f6 <_panic>

00800d6e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d6e:	55                   	push   %ebp
  800d6f:	89 e5                	mov    %esp,%ebp
  800d71:	57                   	push   %edi
  800d72:	56                   	push   %esi
  800d73:	53                   	push   %ebx
  800d74:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d77:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d82:	b8 06 00 00 00       	mov    $0x6,%eax
  800d87:	89 df                	mov    %ebx,%edi
  800d89:	89 de                	mov    %ebx,%esi
  800d8b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d8d:	85 c0                	test   %eax,%eax
  800d8f:	7f 08                	jg     800d99 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d94:	5b                   	pop    %ebx
  800d95:	5e                   	pop    %esi
  800d96:	5f                   	pop    %edi
  800d97:	5d                   	pop    %ebp
  800d98:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d99:	83 ec 0c             	sub    $0xc,%esp
  800d9c:	50                   	push   %eax
  800d9d:	6a 06                	push   $0x6
  800d9f:	68 9f 2c 80 00       	push   $0x802c9f
  800da4:	6a 23                	push   $0x23
  800da6:	68 bc 2c 80 00       	push   $0x802cbc
  800dab:	e8 46 f4 ff ff       	call   8001f6 <_panic>

00800db0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800db0:	55                   	push   %ebp
  800db1:	89 e5                	mov    %esp,%ebp
  800db3:	57                   	push   %edi
  800db4:	56                   	push   %esi
  800db5:	53                   	push   %ebx
  800db6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800db9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc4:	b8 08 00 00 00       	mov    $0x8,%eax
  800dc9:	89 df                	mov    %ebx,%edi
  800dcb:	89 de                	mov    %ebx,%esi
  800dcd:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dcf:	85 c0                	test   %eax,%eax
  800dd1:	7f 08                	jg     800ddb <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dd3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd6:	5b                   	pop    %ebx
  800dd7:	5e                   	pop    %esi
  800dd8:	5f                   	pop    %edi
  800dd9:	5d                   	pop    %ebp
  800dda:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ddb:	83 ec 0c             	sub    $0xc,%esp
  800dde:	50                   	push   %eax
  800ddf:	6a 08                	push   $0x8
  800de1:	68 9f 2c 80 00       	push   $0x802c9f
  800de6:	6a 23                	push   $0x23
  800de8:	68 bc 2c 80 00       	push   $0x802cbc
  800ded:	e8 04 f4 ff ff       	call   8001f6 <_panic>

00800df2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800df2:	55                   	push   %ebp
  800df3:	89 e5                	mov    %esp,%ebp
  800df5:	57                   	push   %edi
  800df6:	56                   	push   %esi
  800df7:	53                   	push   %ebx
  800df8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dfb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e00:	8b 55 08             	mov    0x8(%ebp),%edx
  800e03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e06:	b8 09 00 00 00       	mov    $0x9,%eax
  800e0b:	89 df                	mov    %ebx,%edi
  800e0d:	89 de                	mov    %ebx,%esi
  800e0f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e11:	85 c0                	test   %eax,%eax
  800e13:	7f 08                	jg     800e1d <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e18:	5b                   	pop    %ebx
  800e19:	5e                   	pop    %esi
  800e1a:	5f                   	pop    %edi
  800e1b:	5d                   	pop    %ebp
  800e1c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1d:	83 ec 0c             	sub    $0xc,%esp
  800e20:	50                   	push   %eax
  800e21:	6a 09                	push   $0x9
  800e23:	68 9f 2c 80 00       	push   $0x802c9f
  800e28:	6a 23                	push   $0x23
  800e2a:	68 bc 2c 80 00       	push   $0x802cbc
  800e2f:	e8 c2 f3 ff ff       	call   8001f6 <_panic>

00800e34 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e34:	55                   	push   %ebp
  800e35:	89 e5                	mov    %esp,%ebp
  800e37:	57                   	push   %edi
  800e38:	56                   	push   %esi
  800e39:	53                   	push   %ebx
  800e3a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e3d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e42:	8b 55 08             	mov    0x8(%ebp),%edx
  800e45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e48:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e4d:	89 df                	mov    %ebx,%edi
  800e4f:	89 de                	mov    %ebx,%esi
  800e51:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e53:	85 c0                	test   %eax,%eax
  800e55:	7f 08                	jg     800e5f <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e5a:	5b                   	pop    %ebx
  800e5b:	5e                   	pop    %esi
  800e5c:	5f                   	pop    %edi
  800e5d:	5d                   	pop    %ebp
  800e5e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e5f:	83 ec 0c             	sub    $0xc,%esp
  800e62:	50                   	push   %eax
  800e63:	6a 0a                	push   $0xa
  800e65:	68 9f 2c 80 00       	push   $0x802c9f
  800e6a:	6a 23                	push   $0x23
  800e6c:	68 bc 2c 80 00       	push   $0x802cbc
  800e71:	e8 80 f3 ff ff       	call   8001f6 <_panic>

00800e76 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e76:	55                   	push   %ebp
  800e77:	89 e5                	mov    %esp,%ebp
  800e79:	57                   	push   %edi
  800e7a:	56                   	push   %esi
  800e7b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e82:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e87:	be 00 00 00 00       	mov    $0x0,%esi
  800e8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e8f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e92:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e94:	5b                   	pop    %ebx
  800e95:	5e                   	pop    %esi
  800e96:	5f                   	pop    %edi
  800e97:	5d                   	pop    %ebp
  800e98:	c3                   	ret    

00800e99 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e99:	55                   	push   %ebp
  800e9a:	89 e5                	mov    %esp,%ebp
  800e9c:	57                   	push   %edi
  800e9d:	56                   	push   %esi
  800e9e:	53                   	push   %ebx
  800e9f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ea2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ea7:	8b 55 08             	mov    0x8(%ebp),%edx
  800eaa:	b8 0d 00 00 00       	mov    $0xd,%eax
  800eaf:	89 cb                	mov    %ecx,%ebx
  800eb1:	89 cf                	mov    %ecx,%edi
  800eb3:	89 ce                	mov    %ecx,%esi
  800eb5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800eb7:	85 c0                	test   %eax,%eax
  800eb9:	7f 08                	jg     800ec3 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ebb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ebe:	5b                   	pop    %ebx
  800ebf:	5e                   	pop    %esi
  800ec0:	5f                   	pop    %edi
  800ec1:	5d                   	pop    %ebp
  800ec2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec3:	83 ec 0c             	sub    $0xc,%esp
  800ec6:	50                   	push   %eax
  800ec7:	6a 0d                	push   $0xd
  800ec9:	68 9f 2c 80 00       	push   $0x802c9f
  800ece:	6a 23                	push   $0x23
  800ed0:	68 bc 2c 80 00       	push   $0x802cbc
  800ed5:	e8 1c f3 ff ff       	call   8001f6 <_panic>

00800eda <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800eda:	55                   	push   %ebp
  800edb:	89 e5                	mov    %esp,%ebp
  800edd:	53                   	push   %ebx
  800ede:	83 ec 04             	sub    $0x4,%esp
  800ee1:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800ee4:	8b 02                	mov    (%edx),%eax
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800ee6:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800eea:	0f 84 9c 00 00 00    	je     800f8c <pgfault+0xb2>
  800ef0:	89 c2                	mov    %eax,%edx
  800ef2:	c1 ea 16             	shr    $0x16,%edx
  800ef5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800efc:	f6 c2 01             	test   $0x1,%dl
  800eff:	0f 84 87 00 00 00    	je     800f8c <pgfault+0xb2>
  800f05:	89 c2                	mov    %eax,%edx
  800f07:	c1 ea 0c             	shr    $0xc,%edx
  800f0a:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800f11:	f6 c1 01             	test   $0x1,%cl
  800f14:	74 76                	je     800f8c <pgfault+0xb2>
  800f16:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f1d:	f6 c6 08             	test   $0x8,%dh
  800f20:	74 6a                	je     800f8c <pgfault+0xb2>
		panic("not copy-on-write");
	addr = ROUNDDOWN(addr, PGSIZE);
  800f22:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f27:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P) < 0)
  800f29:	83 ec 04             	sub    $0x4,%esp
  800f2c:	6a 07                	push   $0x7
  800f2e:	68 00 f0 7f 00       	push   $0x7ff000
  800f33:	6a 00                	push   $0x0
  800f35:	e8 af fd ff ff       	call   800ce9 <sys_page_alloc>
  800f3a:	83 c4 10             	add    $0x10,%esp
  800f3d:	85 c0                	test   %eax,%eax
  800f3f:	78 5f                	js     800fa0 <pgfault+0xc6>
		panic("sys_page_alloc");
	memcpy(PFTEMP, addr, PGSIZE);
  800f41:	83 ec 04             	sub    $0x4,%esp
  800f44:	68 00 10 00 00       	push   $0x1000
  800f49:	53                   	push   %ebx
  800f4a:	68 00 f0 7f 00       	push   $0x7ff000
  800f4f:	e8 92 fb ff ff       	call   800ae6 <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P) < 0)
  800f54:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f5b:	53                   	push   %ebx
  800f5c:	6a 00                	push   $0x0
  800f5e:	68 00 f0 7f 00       	push   $0x7ff000
  800f63:	6a 00                	push   $0x0
  800f65:	e8 c2 fd ff ff       	call   800d2c <sys_page_map>
  800f6a:	83 c4 20             	add    $0x20,%esp
  800f6d:	85 c0                	test   %eax,%eax
  800f6f:	78 43                	js     800fb4 <pgfault+0xda>
		panic("sys_page_map");
	if (sys_page_unmap(0, PFTEMP) < 0)
  800f71:	83 ec 08             	sub    $0x8,%esp
  800f74:	68 00 f0 7f 00       	push   $0x7ff000
  800f79:	6a 00                	push   $0x0
  800f7b:	e8 ee fd ff ff       	call   800d6e <sys_page_unmap>
  800f80:	83 c4 10             	add    $0x10,%esp
  800f83:	85 c0                	test   %eax,%eax
  800f85:	78 41                	js     800fc8 <pgfault+0xee>
		panic("sys_page_unmap");
	return;
}
  800f87:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f8a:	c9                   	leave  
  800f8b:	c3                   	ret    
		panic("not copy-on-write");
  800f8c:	83 ec 04             	sub    $0x4,%esp
  800f8f:	68 ca 2c 80 00       	push   $0x802cca
  800f94:	6a 25                	push   $0x25
  800f96:	68 dc 2c 80 00       	push   $0x802cdc
  800f9b:	e8 56 f2 ff ff       	call   8001f6 <_panic>
		panic("sys_page_alloc");
  800fa0:	83 ec 04             	sub    $0x4,%esp
  800fa3:	68 e7 2c 80 00       	push   $0x802ce7
  800fa8:	6a 28                	push   $0x28
  800faa:	68 dc 2c 80 00       	push   $0x802cdc
  800faf:	e8 42 f2 ff ff       	call   8001f6 <_panic>
		panic("sys_page_map");
  800fb4:	83 ec 04             	sub    $0x4,%esp
  800fb7:	68 f6 2c 80 00       	push   $0x802cf6
  800fbc:	6a 2b                	push   $0x2b
  800fbe:	68 dc 2c 80 00       	push   $0x802cdc
  800fc3:	e8 2e f2 ff ff       	call   8001f6 <_panic>
		panic("sys_page_unmap");
  800fc8:	83 ec 04             	sub    $0x4,%esp
  800fcb:	68 03 2d 80 00       	push   $0x802d03
  800fd0:	6a 2d                	push   $0x2d
  800fd2:	68 dc 2c 80 00       	push   $0x802cdc
  800fd7:	e8 1a f2 ff ff       	call   8001f6 <_panic>

00800fdc <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fdc:	55                   	push   %ebp
  800fdd:	89 e5                	mov    %esp,%ebp
  800fdf:	57                   	push   %edi
  800fe0:	56                   	push   %esi
  800fe1:	53                   	push   %ebx
  800fe2:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800fe5:	68 da 0e 80 00       	push   $0x800eda
  800fea:	e8 be 14 00 00       	call   8024ad <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fef:	b8 07 00 00 00       	mov    $0x7,%eax
  800ff4:	cd 30                	int    $0x30
  800ff6:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid;
	uint32_t addr;
	envid = sys_exofork();
	if (envid == 0) {
  800ff9:	83 c4 10             	add    $0x10,%esp
  800ffc:	85 c0                	test   %eax,%eax
  800ffe:	74 12                	je     801012 <fork+0x36>
  801000:	89 c7                	mov    %eax,%edi
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	if (envid < 0)
  801002:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801006:	78 26                	js     80102e <fork+0x52>
		panic("sys_exofork: %e", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  801008:	bb 00 00 00 00       	mov    $0x0,%ebx
  80100d:	e9 94 00 00 00       	jmp    8010a6 <fork+0xca>
		thisenv = &envs[ENVX(sys_getenvid())];
  801012:	e8 94 fc ff ff       	call   800cab <sys_getenvid>
  801017:	25 ff 03 00 00       	and    $0x3ff,%eax
  80101c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80101f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801024:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801029:	e9 51 01 00 00       	jmp    80117f <fork+0x1a3>
		panic("sys_exofork: %e", envid);
  80102e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801031:	68 12 2d 80 00       	push   $0x802d12
  801036:	6a 6e                	push   $0x6e
  801038:	68 dc 2c 80 00       	push   $0x802cdc
  80103d:	e8 b4 f1 ff ff       	call   8001f6 <_panic>
        	sys_page_map(0, addr, envid, addr, PTE_SYSCALL);
  801042:	83 ec 0c             	sub    $0xc,%esp
  801045:	68 07 0e 00 00       	push   $0xe07
  80104a:	56                   	push   %esi
  80104b:	57                   	push   %edi
  80104c:	56                   	push   %esi
  80104d:	6a 00                	push   $0x0
  80104f:	e8 d8 fc ff ff       	call   800d2c <sys_page_map>
  801054:	83 c4 20             	add    $0x20,%esp
  801057:	eb 3b                	jmp    801094 <fork+0xb8>
        	if ((r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  801059:	83 ec 0c             	sub    $0xc,%esp
  80105c:	68 05 08 00 00       	push   $0x805
  801061:	56                   	push   %esi
  801062:	57                   	push   %edi
  801063:	56                   	push   %esi
  801064:	6a 00                	push   $0x0
  801066:	e8 c1 fc ff ff       	call   800d2c <sys_page_map>
  80106b:	83 c4 20             	add    $0x20,%esp
  80106e:	85 c0                	test   %eax,%eax
  801070:	0f 88 a9 00 00 00    	js     80111f <fork+0x143>
        	if ((r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  801076:	83 ec 0c             	sub    $0xc,%esp
  801079:	68 05 08 00 00       	push   $0x805
  80107e:	56                   	push   %esi
  80107f:	6a 00                	push   $0x0
  801081:	56                   	push   %esi
  801082:	6a 00                	push   $0x0
  801084:	e8 a3 fc ff ff       	call   800d2c <sys_page_map>
  801089:	83 c4 20             	add    $0x20,%esp
  80108c:	85 c0                	test   %eax,%eax
  80108e:	0f 88 9d 00 00 00    	js     801131 <fork+0x155>
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  801094:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80109a:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8010a0:	0f 84 9d 00 00 00    	je     801143 <fork+0x167>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  8010a6:	89 d8                	mov    %ebx,%eax
  8010a8:	c1 e8 16             	shr    $0x16,%eax
  8010ab:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010b2:	a8 01                	test   $0x1,%al
  8010b4:	74 de                	je     801094 <fork+0xb8>
  8010b6:	89 d8                	mov    %ebx,%eax
  8010b8:	c1 e8 0c             	shr    $0xc,%eax
  8010bb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010c2:	f6 c2 01             	test   $0x1,%dl
  8010c5:	74 cd                	je     801094 <fork+0xb8>
			&& (uvpt[PGNUM(addr)] & PTE_U)) {
  8010c7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010ce:	f6 c2 04             	test   $0x4,%dl
  8010d1:	74 c1                	je     801094 <fork+0xb8>
	void *addr = (void*) (pn*PGSIZE);
  8010d3:	89 c6                	mov    %eax,%esi
  8010d5:	c1 e6 0c             	shl    $0xc,%esi
    	if (uvpt[pn] & PTE_SHARE) {
  8010d8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010df:	f6 c6 04             	test   $0x4,%dh
  8010e2:	0f 85 5a ff ff ff    	jne    801042 <fork+0x66>
    	} else if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  8010e8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010ef:	f6 c2 02             	test   $0x2,%dl
  8010f2:	0f 85 61 ff ff ff    	jne    801059 <fork+0x7d>
  8010f8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010ff:	f6 c4 08             	test   $0x8,%ah
  801102:	0f 85 51 ff ff ff    	jne    801059 <fork+0x7d>
        		sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  801108:	83 ec 0c             	sub    $0xc,%esp
  80110b:	6a 05                	push   $0x5
  80110d:	56                   	push   %esi
  80110e:	57                   	push   %edi
  80110f:	56                   	push   %esi
  801110:	6a 00                	push   $0x0
  801112:	e8 15 fc ff ff       	call   800d2c <sys_page_map>
  801117:	83 c4 20             	add    $0x20,%esp
  80111a:	e9 75 ff ff ff       	jmp    801094 <fork+0xb8>
            		panic("sys_page_map：%e", r);
  80111f:	50                   	push   %eax
  801120:	68 22 2d 80 00       	push   $0x802d22
  801125:	6a 47                	push   $0x47
  801127:	68 dc 2c 80 00       	push   $0x802cdc
  80112c:	e8 c5 f0 ff ff       	call   8001f6 <_panic>
            		panic("sys_page_map：%e", r);
  801131:	50                   	push   %eax
  801132:	68 22 2d 80 00       	push   $0x802d22
  801137:	6a 49                	push   $0x49
  801139:	68 dc 2c 80 00       	push   $0x802cdc
  80113e:	e8 b3 f0 ff ff       	call   8001f6 <_panic>
			duppage(envid, PGNUM(addr));
		}

	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  801143:	83 ec 04             	sub    $0x4,%esp
  801146:	6a 07                	push   $0x7
  801148:	68 00 f0 bf ee       	push   $0xeebff000
  80114d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801150:	e8 94 fb ff ff       	call   800ce9 <sys_page_alloc>
  801155:	83 c4 10             	add    $0x10,%esp
  801158:	85 c0                	test   %eax,%eax
  80115a:	78 2e                	js     80118a <fork+0x1ae>
		panic("1");
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80115c:	83 ec 08             	sub    $0x8,%esp
  80115f:	68 1c 25 80 00       	push   $0x80251c
  801164:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801167:	57                   	push   %edi
  801168:	e8 c7 fc ff ff       	call   800e34 <sys_env_set_pgfault_upcall>

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  80116d:	83 c4 08             	add    $0x8,%esp
  801170:	6a 02                	push   $0x2
  801172:	57                   	push   %edi
  801173:	e8 38 fc ff ff       	call   800db0 <sys_env_set_status>
  801178:	83 c4 10             	add    $0x10,%esp
  80117b:	85 c0                	test   %eax,%eax
  80117d:	78 1f                	js     80119e <fork+0x1c2>
		panic("sys_env_set_status");

	return envid;
	panic("fork not implemented");
}
  80117f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801182:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801185:	5b                   	pop    %ebx
  801186:	5e                   	pop    %esi
  801187:	5f                   	pop    %edi
  801188:	5d                   	pop    %ebp
  801189:	c3                   	ret    
		panic("1");
  80118a:	83 ec 04             	sub    $0x4,%esp
  80118d:	68 34 2d 80 00       	push   $0x802d34
  801192:	6a 77                	push   $0x77
  801194:	68 dc 2c 80 00       	push   $0x802cdc
  801199:	e8 58 f0 ff ff       	call   8001f6 <_panic>
		panic("sys_env_set_status");
  80119e:	83 ec 04             	sub    $0x4,%esp
  8011a1:	68 36 2d 80 00       	push   $0x802d36
  8011a6:	6a 7c                	push   $0x7c
  8011a8:	68 dc 2c 80 00       	push   $0x802cdc
  8011ad:	e8 44 f0 ff ff       	call   8001f6 <_panic>

008011b2 <sfork>:

// Challenge!
int
sfork(void)
{
  8011b2:	55                   	push   %ebp
  8011b3:	89 e5                	mov    %esp,%ebp
  8011b5:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011b8:	68 49 2d 80 00       	push   $0x802d49
  8011bd:	68 86 00 00 00       	push   $0x86
  8011c2:	68 dc 2c 80 00       	push   $0x802cdc
  8011c7:	e8 2a f0 ff ff       	call   8001f6 <_panic>

008011cc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011cc:	55                   	push   %ebp
  8011cd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d2:	05 00 00 00 30       	add    $0x30000000,%eax
  8011d7:	c1 e8 0c             	shr    $0xc,%eax
}
  8011da:	5d                   	pop    %ebp
  8011db:	c3                   	ret    

008011dc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011dc:	55                   	push   %ebp
  8011dd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011df:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e2:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8011e7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011ec:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011f1:	5d                   	pop    %ebp
  8011f2:	c3                   	ret    

008011f3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011f3:	55                   	push   %ebp
  8011f4:	89 e5                	mov    %esp,%ebp
  8011f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011f9:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011fe:	89 c2                	mov    %eax,%edx
  801200:	c1 ea 16             	shr    $0x16,%edx
  801203:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80120a:	f6 c2 01             	test   $0x1,%dl
  80120d:	74 2a                	je     801239 <fd_alloc+0x46>
  80120f:	89 c2                	mov    %eax,%edx
  801211:	c1 ea 0c             	shr    $0xc,%edx
  801214:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80121b:	f6 c2 01             	test   $0x1,%dl
  80121e:	74 19                	je     801239 <fd_alloc+0x46>
  801220:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801225:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80122a:	75 d2                	jne    8011fe <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80122c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801232:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801237:	eb 07                	jmp    801240 <fd_alloc+0x4d>
			*fd_store = fd;
  801239:	89 01                	mov    %eax,(%ecx)
			return 0;
  80123b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801240:	5d                   	pop    %ebp
  801241:	c3                   	ret    

00801242 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801242:	55                   	push   %ebp
  801243:	89 e5                	mov    %esp,%ebp
  801245:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801248:	83 f8 1f             	cmp    $0x1f,%eax
  80124b:	77 36                	ja     801283 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80124d:	c1 e0 0c             	shl    $0xc,%eax
  801250:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801255:	89 c2                	mov    %eax,%edx
  801257:	c1 ea 16             	shr    $0x16,%edx
  80125a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801261:	f6 c2 01             	test   $0x1,%dl
  801264:	74 24                	je     80128a <fd_lookup+0x48>
  801266:	89 c2                	mov    %eax,%edx
  801268:	c1 ea 0c             	shr    $0xc,%edx
  80126b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801272:	f6 c2 01             	test   $0x1,%dl
  801275:	74 1a                	je     801291 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801277:	8b 55 0c             	mov    0xc(%ebp),%edx
  80127a:	89 02                	mov    %eax,(%edx)
	return 0;
  80127c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801281:	5d                   	pop    %ebp
  801282:	c3                   	ret    
		return -E_INVAL;
  801283:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801288:	eb f7                	jmp    801281 <fd_lookup+0x3f>
		return -E_INVAL;
  80128a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80128f:	eb f0                	jmp    801281 <fd_lookup+0x3f>
  801291:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801296:	eb e9                	jmp    801281 <fd_lookup+0x3f>

00801298 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801298:	55                   	push   %ebp
  801299:	89 e5                	mov    %esp,%ebp
  80129b:	83 ec 08             	sub    $0x8,%esp
  80129e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012a1:	ba dc 2d 80 00       	mov    $0x802ddc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012a6:	b8 0c 30 80 00       	mov    $0x80300c,%eax
		if (devtab[i]->dev_id == dev_id) {
  8012ab:	39 08                	cmp    %ecx,(%eax)
  8012ad:	74 33                	je     8012e2 <dev_lookup+0x4a>
  8012af:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  8012b2:	8b 02                	mov    (%edx),%eax
  8012b4:	85 c0                	test   %eax,%eax
  8012b6:	75 f3                	jne    8012ab <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012b8:	a1 04 40 80 00       	mov    0x804004,%eax
  8012bd:	8b 40 48             	mov    0x48(%eax),%eax
  8012c0:	83 ec 04             	sub    $0x4,%esp
  8012c3:	51                   	push   %ecx
  8012c4:	50                   	push   %eax
  8012c5:	68 60 2d 80 00       	push   $0x802d60
  8012ca:	e8 02 f0 ff ff       	call   8002d1 <cprintf>
	*dev = 0;
  8012cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012d2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012d8:	83 c4 10             	add    $0x10,%esp
  8012db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012e0:	c9                   	leave  
  8012e1:	c3                   	ret    
			*dev = devtab[i];
  8012e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012e5:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ec:	eb f2                	jmp    8012e0 <dev_lookup+0x48>

008012ee <fd_close>:
{
  8012ee:	55                   	push   %ebp
  8012ef:	89 e5                	mov    %esp,%ebp
  8012f1:	57                   	push   %edi
  8012f2:	56                   	push   %esi
  8012f3:	53                   	push   %ebx
  8012f4:	83 ec 1c             	sub    $0x1c,%esp
  8012f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8012fa:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012fd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801300:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801301:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801307:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80130a:	50                   	push   %eax
  80130b:	e8 32 ff ff ff       	call   801242 <fd_lookup>
  801310:	89 c3                	mov    %eax,%ebx
  801312:	83 c4 08             	add    $0x8,%esp
  801315:	85 c0                	test   %eax,%eax
  801317:	78 05                	js     80131e <fd_close+0x30>
	    || fd != fd2)
  801319:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80131c:	74 16                	je     801334 <fd_close+0x46>
		return (must_exist ? r : 0);
  80131e:	89 f8                	mov    %edi,%eax
  801320:	84 c0                	test   %al,%al
  801322:	b8 00 00 00 00       	mov    $0x0,%eax
  801327:	0f 44 d8             	cmove  %eax,%ebx
}
  80132a:	89 d8                	mov    %ebx,%eax
  80132c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80132f:	5b                   	pop    %ebx
  801330:	5e                   	pop    %esi
  801331:	5f                   	pop    %edi
  801332:	5d                   	pop    %ebp
  801333:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801334:	83 ec 08             	sub    $0x8,%esp
  801337:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80133a:	50                   	push   %eax
  80133b:	ff 36                	pushl  (%esi)
  80133d:	e8 56 ff ff ff       	call   801298 <dev_lookup>
  801342:	89 c3                	mov    %eax,%ebx
  801344:	83 c4 10             	add    $0x10,%esp
  801347:	85 c0                	test   %eax,%eax
  801349:	78 15                	js     801360 <fd_close+0x72>
		if (dev->dev_close)
  80134b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80134e:	8b 40 10             	mov    0x10(%eax),%eax
  801351:	85 c0                	test   %eax,%eax
  801353:	74 1b                	je     801370 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  801355:	83 ec 0c             	sub    $0xc,%esp
  801358:	56                   	push   %esi
  801359:	ff d0                	call   *%eax
  80135b:	89 c3                	mov    %eax,%ebx
  80135d:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801360:	83 ec 08             	sub    $0x8,%esp
  801363:	56                   	push   %esi
  801364:	6a 00                	push   $0x0
  801366:	e8 03 fa ff ff       	call   800d6e <sys_page_unmap>
	return r;
  80136b:	83 c4 10             	add    $0x10,%esp
  80136e:	eb ba                	jmp    80132a <fd_close+0x3c>
			r = 0;
  801370:	bb 00 00 00 00       	mov    $0x0,%ebx
  801375:	eb e9                	jmp    801360 <fd_close+0x72>

00801377 <close>:

int
close(int fdnum)
{
  801377:	55                   	push   %ebp
  801378:	89 e5                	mov    %esp,%ebp
  80137a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80137d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801380:	50                   	push   %eax
  801381:	ff 75 08             	pushl  0x8(%ebp)
  801384:	e8 b9 fe ff ff       	call   801242 <fd_lookup>
  801389:	83 c4 08             	add    $0x8,%esp
  80138c:	85 c0                	test   %eax,%eax
  80138e:	78 10                	js     8013a0 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801390:	83 ec 08             	sub    $0x8,%esp
  801393:	6a 01                	push   $0x1
  801395:	ff 75 f4             	pushl  -0xc(%ebp)
  801398:	e8 51 ff ff ff       	call   8012ee <fd_close>
  80139d:	83 c4 10             	add    $0x10,%esp
}
  8013a0:	c9                   	leave  
  8013a1:	c3                   	ret    

008013a2 <close_all>:

void
close_all(void)
{
  8013a2:	55                   	push   %ebp
  8013a3:	89 e5                	mov    %esp,%ebp
  8013a5:	53                   	push   %ebx
  8013a6:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013a9:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013ae:	83 ec 0c             	sub    $0xc,%esp
  8013b1:	53                   	push   %ebx
  8013b2:	e8 c0 ff ff ff       	call   801377 <close>
	for (i = 0; i < MAXFD; i++)
  8013b7:	83 c3 01             	add    $0x1,%ebx
  8013ba:	83 c4 10             	add    $0x10,%esp
  8013bd:	83 fb 20             	cmp    $0x20,%ebx
  8013c0:	75 ec                	jne    8013ae <close_all+0xc>
}
  8013c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c5:	c9                   	leave  
  8013c6:	c3                   	ret    

008013c7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013c7:	55                   	push   %ebp
  8013c8:	89 e5                	mov    %esp,%ebp
  8013ca:	57                   	push   %edi
  8013cb:	56                   	push   %esi
  8013cc:	53                   	push   %ebx
  8013cd:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013d0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013d3:	50                   	push   %eax
  8013d4:	ff 75 08             	pushl  0x8(%ebp)
  8013d7:	e8 66 fe ff ff       	call   801242 <fd_lookup>
  8013dc:	89 c3                	mov    %eax,%ebx
  8013de:	83 c4 08             	add    $0x8,%esp
  8013e1:	85 c0                	test   %eax,%eax
  8013e3:	0f 88 81 00 00 00    	js     80146a <dup+0xa3>
		return r;
	close(newfdnum);
  8013e9:	83 ec 0c             	sub    $0xc,%esp
  8013ec:	ff 75 0c             	pushl  0xc(%ebp)
  8013ef:	e8 83 ff ff ff       	call   801377 <close>

	newfd = INDEX2FD(newfdnum);
  8013f4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013f7:	c1 e6 0c             	shl    $0xc,%esi
  8013fa:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801400:	83 c4 04             	add    $0x4,%esp
  801403:	ff 75 e4             	pushl  -0x1c(%ebp)
  801406:	e8 d1 fd ff ff       	call   8011dc <fd2data>
  80140b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80140d:	89 34 24             	mov    %esi,(%esp)
  801410:	e8 c7 fd ff ff       	call   8011dc <fd2data>
  801415:	83 c4 10             	add    $0x10,%esp
  801418:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80141a:	89 d8                	mov    %ebx,%eax
  80141c:	c1 e8 16             	shr    $0x16,%eax
  80141f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801426:	a8 01                	test   $0x1,%al
  801428:	74 11                	je     80143b <dup+0x74>
  80142a:	89 d8                	mov    %ebx,%eax
  80142c:	c1 e8 0c             	shr    $0xc,%eax
  80142f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801436:	f6 c2 01             	test   $0x1,%dl
  801439:	75 39                	jne    801474 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80143b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80143e:	89 d0                	mov    %edx,%eax
  801440:	c1 e8 0c             	shr    $0xc,%eax
  801443:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80144a:	83 ec 0c             	sub    $0xc,%esp
  80144d:	25 07 0e 00 00       	and    $0xe07,%eax
  801452:	50                   	push   %eax
  801453:	56                   	push   %esi
  801454:	6a 00                	push   $0x0
  801456:	52                   	push   %edx
  801457:	6a 00                	push   $0x0
  801459:	e8 ce f8 ff ff       	call   800d2c <sys_page_map>
  80145e:	89 c3                	mov    %eax,%ebx
  801460:	83 c4 20             	add    $0x20,%esp
  801463:	85 c0                	test   %eax,%eax
  801465:	78 31                	js     801498 <dup+0xd1>
		goto err;

	return newfdnum;
  801467:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80146a:	89 d8                	mov    %ebx,%eax
  80146c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80146f:	5b                   	pop    %ebx
  801470:	5e                   	pop    %esi
  801471:	5f                   	pop    %edi
  801472:	5d                   	pop    %ebp
  801473:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801474:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80147b:	83 ec 0c             	sub    $0xc,%esp
  80147e:	25 07 0e 00 00       	and    $0xe07,%eax
  801483:	50                   	push   %eax
  801484:	57                   	push   %edi
  801485:	6a 00                	push   $0x0
  801487:	53                   	push   %ebx
  801488:	6a 00                	push   $0x0
  80148a:	e8 9d f8 ff ff       	call   800d2c <sys_page_map>
  80148f:	89 c3                	mov    %eax,%ebx
  801491:	83 c4 20             	add    $0x20,%esp
  801494:	85 c0                	test   %eax,%eax
  801496:	79 a3                	jns    80143b <dup+0x74>
	sys_page_unmap(0, newfd);
  801498:	83 ec 08             	sub    $0x8,%esp
  80149b:	56                   	push   %esi
  80149c:	6a 00                	push   $0x0
  80149e:	e8 cb f8 ff ff       	call   800d6e <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014a3:	83 c4 08             	add    $0x8,%esp
  8014a6:	57                   	push   %edi
  8014a7:	6a 00                	push   $0x0
  8014a9:	e8 c0 f8 ff ff       	call   800d6e <sys_page_unmap>
	return r;
  8014ae:	83 c4 10             	add    $0x10,%esp
  8014b1:	eb b7                	jmp    80146a <dup+0xa3>

008014b3 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014b3:	55                   	push   %ebp
  8014b4:	89 e5                	mov    %esp,%ebp
  8014b6:	53                   	push   %ebx
  8014b7:	83 ec 14             	sub    $0x14,%esp
  8014ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014bd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014c0:	50                   	push   %eax
  8014c1:	53                   	push   %ebx
  8014c2:	e8 7b fd ff ff       	call   801242 <fd_lookup>
  8014c7:	83 c4 08             	add    $0x8,%esp
  8014ca:	85 c0                	test   %eax,%eax
  8014cc:	78 3f                	js     80150d <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ce:	83 ec 08             	sub    $0x8,%esp
  8014d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d4:	50                   	push   %eax
  8014d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d8:	ff 30                	pushl  (%eax)
  8014da:	e8 b9 fd ff ff       	call   801298 <dev_lookup>
  8014df:	83 c4 10             	add    $0x10,%esp
  8014e2:	85 c0                	test   %eax,%eax
  8014e4:	78 27                	js     80150d <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014e6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014e9:	8b 42 08             	mov    0x8(%edx),%eax
  8014ec:	83 e0 03             	and    $0x3,%eax
  8014ef:	83 f8 01             	cmp    $0x1,%eax
  8014f2:	74 1e                	je     801512 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8014f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014f7:	8b 40 08             	mov    0x8(%eax),%eax
  8014fa:	85 c0                	test   %eax,%eax
  8014fc:	74 35                	je     801533 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014fe:	83 ec 04             	sub    $0x4,%esp
  801501:	ff 75 10             	pushl  0x10(%ebp)
  801504:	ff 75 0c             	pushl  0xc(%ebp)
  801507:	52                   	push   %edx
  801508:	ff d0                	call   *%eax
  80150a:	83 c4 10             	add    $0x10,%esp
}
  80150d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801510:	c9                   	leave  
  801511:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801512:	a1 04 40 80 00       	mov    0x804004,%eax
  801517:	8b 40 48             	mov    0x48(%eax),%eax
  80151a:	83 ec 04             	sub    $0x4,%esp
  80151d:	53                   	push   %ebx
  80151e:	50                   	push   %eax
  80151f:	68 a1 2d 80 00       	push   $0x802da1
  801524:	e8 a8 ed ff ff       	call   8002d1 <cprintf>
		return -E_INVAL;
  801529:	83 c4 10             	add    $0x10,%esp
  80152c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801531:	eb da                	jmp    80150d <read+0x5a>
		return -E_NOT_SUPP;
  801533:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801538:	eb d3                	jmp    80150d <read+0x5a>

0080153a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80153a:	55                   	push   %ebp
  80153b:	89 e5                	mov    %esp,%ebp
  80153d:	57                   	push   %edi
  80153e:	56                   	push   %esi
  80153f:	53                   	push   %ebx
  801540:	83 ec 0c             	sub    $0xc,%esp
  801543:	8b 7d 08             	mov    0x8(%ebp),%edi
  801546:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801549:	bb 00 00 00 00       	mov    $0x0,%ebx
  80154e:	39 f3                	cmp    %esi,%ebx
  801550:	73 25                	jae    801577 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801552:	83 ec 04             	sub    $0x4,%esp
  801555:	89 f0                	mov    %esi,%eax
  801557:	29 d8                	sub    %ebx,%eax
  801559:	50                   	push   %eax
  80155a:	89 d8                	mov    %ebx,%eax
  80155c:	03 45 0c             	add    0xc(%ebp),%eax
  80155f:	50                   	push   %eax
  801560:	57                   	push   %edi
  801561:	e8 4d ff ff ff       	call   8014b3 <read>
		if (m < 0)
  801566:	83 c4 10             	add    $0x10,%esp
  801569:	85 c0                	test   %eax,%eax
  80156b:	78 08                	js     801575 <readn+0x3b>
			return m;
		if (m == 0)
  80156d:	85 c0                	test   %eax,%eax
  80156f:	74 06                	je     801577 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  801571:	01 c3                	add    %eax,%ebx
  801573:	eb d9                	jmp    80154e <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801575:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801577:	89 d8                	mov    %ebx,%eax
  801579:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80157c:	5b                   	pop    %ebx
  80157d:	5e                   	pop    %esi
  80157e:	5f                   	pop    %edi
  80157f:	5d                   	pop    %ebp
  801580:	c3                   	ret    

00801581 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801581:	55                   	push   %ebp
  801582:	89 e5                	mov    %esp,%ebp
  801584:	53                   	push   %ebx
  801585:	83 ec 14             	sub    $0x14,%esp
  801588:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80158b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80158e:	50                   	push   %eax
  80158f:	53                   	push   %ebx
  801590:	e8 ad fc ff ff       	call   801242 <fd_lookup>
  801595:	83 c4 08             	add    $0x8,%esp
  801598:	85 c0                	test   %eax,%eax
  80159a:	78 3a                	js     8015d6 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80159c:	83 ec 08             	sub    $0x8,%esp
  80159f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a2:	50                   	push   %eax
  8015a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a6:	ff 30                	pushl  (%eax)
  8015a8:	e8 eb fc ff ff       	call   801298 <dev_lookup>
  8015ad:	83 c4 10             	add    $0x10,%esp
  8015b0:	85 c0                	test   %eax,%eax
  8015b2:	78 22                	js     8015d6 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015bb:	74 1e                	je     8015db <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015c0:	8b 52 0c             	mov    0xc(%edx),%edx
  8015c3:	85 d2                	test   %edx,%edx
  8015c5:	74 35                	je     8015fc <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015c7:	83 ec 04             	sub    $0x4,%esp
  8015ca:	ff 75 10             	pushl  0x10(%ebp)
  8015cd:	ff 75 0c             	pushl  0xc(%ebp)
  8015d0:	50                   	push   %eax
  8015d1:	ff d2                	call   *%edx
  8015d3:	83 c4 10             	add    $0x10,%esp
}
  8015d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015d9:	c9                   	leave  
  8015da:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015db:	a1 04 40 80 00       	mov    0x804004,%eax
  8015e0:	8b 40 48             	mov    0x48(%eax),%eax
  8015e3:	83 ec 04             	sub    $0x4,%esp
  8015e6:	53                   	push   %ebx
  8015e7:	50                   	push   %eax
  8015e8:	68 bd 2d 80 00       	push   $0x802dbd
  8015ed:	e8 df ec ff ff       	call   8002d1 <cprintf>
		return -E_INVAL;
  8015f2:	83 c4 10             	add    $0x10,%esp
  8015f5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015fa:	eb da                	jmp    8015d6 <write+0x55>
		return -E_NOT_SUPP;
  8015fc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801601:	eb d3                	jmp    8015d6 <write+0x55>

00801603 <seek>:

int
seek(int fdnum, off_t offset)
{
  801603:	55                   	push   %ebp
  801604:	89 e5                	mov    %esp,%ebp
  801606:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801609:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80160c:	50                   	push   %eax
  80160d:	ff 75 08             	pushl  0x8(%ebp)
  801610:	e8 2d fc ff ff       	call   801242 <fd_lookup>
  801615:	83 c4 08             	add    $0x8,%esp
  801618:	85 c0                	test   %eax,%eax
  80161a:	78 0e                	js     80162a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80161c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80161f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801622:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801625:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80162a:	c9                   	leave  
  80162b:	c3                   	ret    

0080162c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80162c:	55                   	push   %ebp
  80162d:	89 e5                	mov    %esp,%ebp
  80162f:	53                   	push   %ebx
  801630:	83 ec 14             	sub    $0x14,%esp
  801633:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801636:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801639:	50                   	push   %eax
  80163a:	53                   	push   %ebx
  80163b:	e8 02 fc ff ff       	call   801242 <fd_lookup>
  801640:	83 c4 08             	add    $0x8,%esp
  801643:	85 c0                	test   %eax,%eax
  801645:	78 37                	js     80167e <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801647:	83 ec 08             	sub    $0x8,%esp
  80164a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80164d:	50                   	push   %eax
  80164e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801651:	ff 30                	pushl  (%eax)
  801653:	e8 40 fc ff ff       	call   801298 <dev_lookup>
  801658:	83 c4 10             	add    $0x10,%esp
  80165b:	85 c0                	test   %eax,%eax
  80165d:	78 1f                	js     80167e <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80165f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801662:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801666:	74 1b                	je     801683 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801668:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80166b:	8b 52 18             	mov    0x18(%edx),%edx
  80166e:	85 d2                	test   %edx,%edx
  801670:	74 32                	je     8016a4 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801672:	83 ec 08             	sub    $0x8,%esp
  801675:	ff 75 0c             	pushl  0xc(%ebp)
  801678:	50                   	push   %eax
  801679:	ff d2                	call   *%edx
  80167b:	83 c4 10             	add    $0x10,%esp
}
  80167e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801681:	c9                   	leave  
  801682:	c3                   	ret    
			thisenv->env_id, fdnum);
  801683:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801688:	8b 40 48             	mov    0x48(%eax),%eax
  80168b:	83 ec 04             	sub    $0x4,%esp
  80168e:	53                   	push   %ebx
  80168f:	50                   	push   %eax
  801690:	68 80 2d 80 00       	push   $0x802d80
  801695:	e8 37 ec ff ff       	call   8002d1 <cprintf>
		return -E_INVAL;
  80169a:	83 c4 10             	add    $0x10,%esp
  80169d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016a2:	eb da                	jmp    80167e <ftruncate+0x52>
		return -E_NOT_SUPP;
  8016a4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016a9:	eb d3                	jmp    80167e <ftruncate+0x52>

008016ab <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016ab:	55                   	push   %ebp
  8016ac:	89 e5                	mov    %esp,%ebp
  8016ae:	53                   	push   %ebx
  8016af:	83 ec 14             	sub    $0x14,%esp
  8016b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016b5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016b8:	50                   	push   %eax
  8016b9:	ff 75 08             	pushl  0x8(%ebp)
  8016bc:	e8 81 fb ff ff       	call   801242 <fd_lookup>
  8016c1:	83 c4 08             	add    $0x8,%esp
  8016c4:	85 c0                	test   %eax,%eax
  8016c6:	78 4b                	js     801713 <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c8:	83 ec 08             	sub    $0x8,%esp
  8016cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ce:	50                   	push   %eax
  8016cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016d2:	ff 30                	pushl  (%eax)
  8016d4:	e8 bf fb ff ff       	call   801298 <dev_lookup>
  8016d9:	83 c4 10             	add    $0x10,%esp
  8016dc:	85 c0                	test   %eax,%eax
  8016de:	78 33                	js     801713 <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  8016e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016e3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016e7:	74 2f                	je     801718 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016e9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016ec:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016f3:	00 00 00 
	stat->st_isdir = 0;
  8016f6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016fd:	00 00 00 
	stat->st_dev = dev;
  801700:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801706:	83 ec 08             	sub    $0x8,%esp
  801709:	53                   	push   %ebx
  80170a:	ff 75 f0             	pushl  -0x10(%ebp)
  80170d:	ff 50 14             	call   *0x14(%eax)
  801710:	83 c4 10             	add    $0x10,%esp
}
  801713:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801716:	c9                   	leave  
  801717:	c3                   	ret    
		return -E_NOT_SUPP;
  801718:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80171d:	eb f4                	jmp    801713 <fstat+0x68>

0080171f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80171f:	55                   	push   %ebp
  801720:	89 e5                	mov    %esp,%ebp
  801722:	56                   	push   %esi
  801723:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801724:	83 ec 08             	sub    $0x8,%esp
  801727:	6a 00                	push   $0x0
  801729:	ff 75 08             	pushl  0x8(%ebp)
  80172c:	e8 da 01 00 00       	call   80190b <open>
  801731:	89 c3                	mov    %eax,%ebx
  801733:	83 c4 10             	add    $0x10,%esp
  801736:	85 c0                	test   %eax,%eax
  801738:	78 1b                	js     801755 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80173a:	83 ec 08             	sub    $0x8,%esp
  80173d:	ff 75 0c             	pushl  0xc(%ebp)
  801740:	50                   	push   %eax
  801741:	e8 65 ff ff ff       	call   8016ab <fstat>
  801746:	89 c6                	mov    %eax,%esi
	close(fd);
  801748:	89 1c 24             	mov    %ebx,(%esp)
  80174b:	e8 27 fc ff ff       	call   801377 <close>
	return r;
  801750:	83 c4 10             	add    $0x10,%esp
  801753:	89 f3                	mov    %esi,%ebx
}
  801755:	89 d8                	mov    %ebx,%eax
  801757:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80175a:	5b                   	pop    %ebx
  80175b:	5e                   	pop    %esi
  80175c:	5d                   	pop    %ebp
  80175d:	c3                   	ret    

0080175e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80175e:	55                   	push   %ebp
  80175f:	89 e5                	mov    %esp,%ebp
  801761:	56                   	push   %esi
  801762:	53                   	push   %ebx
  801763:	89 c6                	mov    %eax,%esi
  801765:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801767:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80176e:	74 27                	je     801797 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801770:	6a 07                	push   $0x7
  801772:	68 00 50 80 00       	push   $0x805000
  801777:	56                   	push   %esi
  801778:	ff 35 00 40 80 00    	pushl  0x804000
  80177e:	e8 26 0e 00 00       	call   8025a9 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801783:	83 c4 0c             	add    $0xc,%esp
  801786:	6a 00                	push   $0x0
  801788:	53                   	push   %ebx
  801789:	6a 00                	push   $0x0
  80178b:	e8 b2 0d 00 00       	call   802542 <ipc_recv>
}
  801790:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801793:	5b                   	pop    %ebx
  801794:	5e                   	pop    %esi
  801795:	5d                   	pop    %ebp
  801796:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801797:	83 ec 0c             	sub    $0xc,%esp
  80179a:	6a 01                	push   $0x1
  80179c:	e8 5c 0e 00 00       	call   8025fd <ipc_find_env>
  8017a1:	a3 00 40 80 00       	mov    %eax,0x804000
  8017a6:	83 c4 10             	add    $0x10,%esp
  8017a9:	eb c5                	jmp    801770 <fsipc+0x12>

008017ab <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017ab:	55                   	push   %ebp
  8017ac:	89 e5                	mov    %esp,%ebp
  8017ae:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b4:	8b 40 0c             	mov    0xc(%eax),%eax
  8017b7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017bf:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c9:	b8 02 00 00 00       	mov    $0x2,%eax
  8017ce:	e8 8b ff ff ff       	call   80175e <fsipc>
}
  8017d3:	c9                   	leave  
  8017d4:	c3                   	ret    

008017d5 <devfile_flush>:
{
  8017d5:	55                   	push   %ebp
  8017d6:	89 e5                	mov    %esp,%ebp
  8017d8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017db:	8b 45 08             	mov    0x8(%ebp),%eax
  8017de:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e1:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8017eb:	b8 06 00 00 00       	mov    $0x6,%eax
  8017f0:	e8 69 ff ff ff       	call   80175e <fsipc>
}
  8017f5:	c9                   	leave  
  8017f6:	c3                   	ret    

008017f7 <devfile_stat>:
{
  8017f7:	55                   	push   %ebp
  8017f8:	89 e5                	mov    %esp,%ebp
  8017fa:	53                   	push   %ebx
  8017fb:	83 ec 04             	sub    $0x4,%esp
  8017fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801801:	8b 45 08             	mov    0x8(%ebp),%eax
  801804:	8b 40 0c             	mov    0xc(%eax),%eax
  801807:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80180c:	ba 00 00 00 00       	mov    $0x0,%edx
  801811:	b8 05 00 00 00       	mov    $0x5,%eax
  801816:	e8 43 ff ff ff       	call   80175e <fsipc>
  80181b:	85 c0                	test   %eax,%eax
  80181d:	78 2c                	js     80184b <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80181f:	83 ec 08             	sub    $0x8,%esp
  801822:	68 00 50 80 00       	push   $0x805000
  801827:	53                   	push   %ebx
  801828:	e8 c3 f0 ff ff       	call   8008f0 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80182d:	a1 80 50 80 00       	mov    0x805080,%eax
  801832:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801838:	a1 84 50 80 00       	mov    0x805084,%eax
  80183d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801843:	83 c4 10             	add    $0x10,%esp
  801846:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80184b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80184e:	c9                   	leave  
  80184f:	c3                   	ret    

00801850 <devfile_write>:
{
  801850:	55                   	push   %ebp
  801851:	89 e5                	mov    %esp,%ebp
  801853:	83 ec 0c             	sub    $0xc,%esp
  801856:	8b 45 10             	mov    0x10(%ebp),%eax
    	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801859:	8b 55 08             	mov    0x8(%ebp),%edx
  80185c:	8b 52 0c             	mov    0xc(%edx),%edx
  80185f:	89 15 00 50 80 00    	mov    %edx,0x805000
    	fsipcbuf.write.req_n = n;
  801865:	a3 04 50 80 00       	mov    %eax,0x805004
    	memmove(fsipcbuf.write.req_buf, buf, n);
  80186a:	50                   	push   %eax
  80186b:	ff 75 0c             	pushl  0xc(%ebp)
  80186e:	68 08 50 80 00       	push   $0x805008
  801873:	e8 06 f2 ff ff       	call   800a7e <memmove>
    	return fsipc(FSREQ_WRITE, NULL);
  801878:	ba 00 00 00 00       	mov    $0x0,%edx
  80187d:	b8 04 00 00 00       	mov    $0x4,%eax
  801882:	e8 d7 fe ff ff       	call   80175e <fsipc>
}
  801887:	c9                   	leave  
  801888:	c3                   	ret    

00801889 <devfile_read>:
{
  801889:	55                   	push   %ebp
  80188a:	89 e5                	mov    %esp,%ebp
  80188c:	56                   	push   %esi
  80188d:	53                   	push   %ebx
  80188e:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801891:	8b 45 08             	mov    0x8(%ebp),%eax
  801894:	8b 40 0c             	mov    0xc(%eax),%eax
  801897:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80189c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a7:	b8 03 00 00 00       	mov    $0x3,%eax
  8018ac:	e8 ad fe ff ff       	call   80175e <fsipc>
  8018b1:	89 c3                	mov    %eax,%ebx
  8018b3:	85 c0                	test   %eax,%eax
  8018b5:	78 1f                	js     8018d6 <devfile_read+0x4d>
	assert(r <= n);
  8018b7:	39 f0                	cmp    %esi,%eax
  8018b9:	77 24                	ja     8018df <devfile_read+0x56>
	assert(r <= PGSIZE);
  8018bb:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018c0:	7f 33                	jg     8018f5 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018c2:	83 ec 04             	sub    $0x4,%esp
  8018c5:	50                   	push   %eax
  8018c6:	68 00 50 80 00       	push   $0x805000
  8018cb:	ff 75 0c             	pushl  0xc(%ebp)
  8018ce:	e8 ab f1 ff ff       	call   800a7e <memmove>
	return r;
  8018d3:	83 c4 10             	add    $0x10,%esp
}
  8018d6:	89 d8                	mov    %ebx,%eax
  8018d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018db:	5b                   	pop    %ebx
  8018dc:	5e                   	pop    %esi
  8018dd:	5d                   	pop    %ebp
  8018de:	c3                   	ret    
	assert(r <= n);
  8018df:	68 ec 2d 80 00       	push   $0x802dec
  8018e4:	68 f3 2d 80 00       	push   $0x802df3
  8018e9:	6a 7c                	push   $0x7c
  8018eb:	68 08 2e 80 00       	push   $0x802e08
  8018f0:	e8 01 e9 ff ff       	call   8001f6 <_panic>
	assert(r <= PGSIZE);
  8018f5:	68 13 2e 80 00       	push   $0x802e13
  8018fa:	68 f3 2d 80 00       	push   $0x802df3
  8018ff:	6a 7d                	push   $0x7d
  801901:	68 08 2e 80 00       	push   $0x802e08
  801906:	e8 eb e8 ff ff       	call   8001f6 <_panic>

0080190b <open>:
{
  80190b:	55                   	push   %ebp
  80190c:	89 e5                	mov    %esp,%ebp
  80190e:	56                   	push   %esi
  80190f:	53                   	push   %ebx
  801910:	83 ec 1c             	sub    $0x1c,%esp
  801913:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801916:	56                   	push   %esi
  801917:	e8 9d ef ff ff       	call   8008b9 <strlen>
  80191c:	83 c4 10             	add    $0x10,%esp
  80191f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801924:	7f 6c                	jg     801992 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801926:	83 ec 0c             	sub    $0xc,%esp
  801929:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80192c:	50                   	push   %eax
  80192d:	e8 c1 f8 ff ff       	call   8011f3 <fd_alloc>
  801932:	89 c3                	mov    %eax,%ebx
  801934:	83 c4 10             	add    $0x10,%esp
  801937:	85 c0                	test   %eax,%eax
  801939:	78 3c                	js     801977 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  80193b:	83 ec 08             	sub    $0x8,%esp
  80193e:	56                   	push   %esi
  80193f:	68 00 50 80 00       	push   $0x805000
  801944:	e8 a7 ef ff ff       	call   8008f0 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801949:	8b 45 0c             	mov    0xc(%ebp),%eax
  80194c:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801951:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801954:	b8 01 00 00 00       	mov    $0x1,%eax
  801959:	e8 00 fe ff ff       	call   80175e <fsipc>
  80195e:	89 c3                	mov    %eax,%ebx
  801960:	83 c4 10             	add    $0x10,%esp
  801963:	85 c0                	test   %eax,%eax
  801965:	78 19                	js     801980 <open+0x75>
	return fd2num(fd);
  801967:	83 ec 0c             	sub    $0xc,%esp
  80196a:	ff 75 f4             	pushl  -0xc(%ebp)
  80196d:	e8 5a f8 ff ff       	call   8011cc <fd2num>
  801972:	89 c3                	mov    %eax,%ebx
  801974:	83 c4 10             	add    $0x10,%esp
}
  801977:	89 d8                	mov    %ebx,%eax
  801979:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80197c:	5b                   	pop    %ebx
  80197d:	5e                   	pop    %esi
  80197e:	5d                   	pop    %ebp
  80197f:	c3                   	ret    
		fd_close(fd, 0);
  801980:	83 ec 08             	sub    $0x8,%esp
  801983:	6a 00                	push   $0x0
  801985:	ff 75 f4             	pushl  -0xc(%ebp)
  801988:	e8 61 f9 ff ff       	call   8012ee <fd_close>
		return r;
  80198d:	83 c4 10             	add    $0x10,%esp
  801990:	eb e5                	jmp    801977 <open+0x6c>
		return -E_BAD_PATH;
  801992:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801997:	eb de                	jmp    801977 <open+0x6c>

00801999 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801999:	55                   	push   %ebp
  80199a:	89 e5                	mov    %esp,%ebp
  80199c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80199f:	ba 00 00 00 00       	mov    $0x0,%edx
  8019a4:	b8 08 00 00 00       	mov    $0x8,%eax
  8019a9:	e8 b0 fd ff ff       	call   80175e <fsipc>
}
  8019ae:	c9                   	leave  
  8019af:	c3                   	ret    

008019b0 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8019b0:	55                   	push   %ebp
  8019b1:	89 e5                	mov    %esp,%ebp
  8019b3:	57                   	push   %edi
  8019b4:	56                   	push   %esi
  8019b5:	53                   	push   %ebx
  8019b6:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8019bc:	6a 00                	push   $0x0
  8019be:	ff 75 08             	pushl  0x8(%ebp)
  8019c1:	e8 45 ff ff ff       	call   80190b <open>
  8019c6:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  8019cc:	83 c4 10             	add    $0x10,%esp
  8019cf:	85 c0                	test   %eax,%eax
  8019d1:	0f 88 40 03 00 00    	js     801d17 <spawn+0x367>
  8019d7:	89 c7                	mov    %eax,%edi
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8019d9:	83 ec 04             	sub    $0x4,%esp
  8019dc:	68 00 02 00 00       	push   $0x200
  8019e1:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8019e7:	50                   	push   %eax
  8019e8:	57                   	push   %edi
  8019e9:	e8 4c fb ff ff       	call   80153a <readn>
  8019ee:	83 c4 10             	add    $0x10,%esp
  8019f1:	3d 00 02 00 00       	cmp    $0x200,%eax
  8019f6:	75 5d                	jne    801a55 <spawn+0xa5>
	    || elf->e_magic != ELF_MAGIC) {
  8019f8:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8019ff:	45 4c 46 
  801a02:	75 51                	jne    801a55 <spawn+0xa5>
  801a04:	b8 07 00 00 00       	mov    $0x7,%eax
  801a09:	cd 30                	int    $0x30
  801a0b:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801a11:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801a17:	85 c0                	test   %eax,%eax
  801a19:	0f 88 a5 04 00 00    	js     801ec4 <spawn+0x514>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801a1f:	25 ff 03 00 00       	and    $0x3ff,%eax
  801a24:	6b f0 7c             	imul   $0x7c,%eax,%esi
  801a27:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801a2d:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801a33:	b9 11 00 00 00       	mov    $0x11,%ecx
  801a38:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801a3a:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801a40:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801a46:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  801a4b:	be 00 00 00 00       	mov    $0x0,%esi
  801a50:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a53:	eb 4b                	jmp    801aa0 <spawn+0xf0>
		close(fd);
  801a55:	83 ec 0c             	sub    $0xc,%esp
  801a58:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801a5e:	e8 14 f9 ff ff       	call   801377 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801a63:	83 c4 0c             	add    $0xc,%esp
  801a66:	68 7f 45 4c 46       	push   $0x464c457f
  801a6b:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801a71:	68 1f 2e 80 00       	push   $0x802e1f
  801a76:	e8 56 e8 ff ff       	call   8002d1 <cprintf>
		return -E_NOT_EXEC;
  801a7b:	83 c4 10             	add    $0x10,%esp
  801a7e:	c7 85 90 fd ff ff f2 	movl   $0xfffffff2,-0x270(%ebp)
  801a85:	ff ff ff 
  801a88:	e9 8a 02 00 00       	jmp    801d17 <spawn+0x367>
		string_size += strlen(argv[argc]) + 1;
  801a8d:	83 ec 0c             	sub    $0xc,%esp
  801a90:	50                   	push   %eax
  801a91:	e8 23 ee ff ff       	call   8008b9 <strlen>
  801a96:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  801a9a:	83 c3 01             	add    $0x1,%ebx
  801a9d:	83 c4 10             	add    $0x10,%esp
  801aa0:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801aa7:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801aaa:	85 c0                	test   %eax,%eax
  801aac:	75 df                	jne    801a8d <spawn+0xdd>
  801aae:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801ab4:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801aba:	bf 00 10 40 00       	mov    $0x401000,%edi
  801abf:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801ac1:	89 fa                	mov    %edi,%edx
  801ac3:	83 e2 fc             	and    $0xfffffffc,%edx
  801ac6:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801acd:	29 c2                	sub    %eax,%edx
  801acf:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801ad5:	8d 42 f8             	lea    -0x8(%edx),%eax
  801ad8:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801add:	0f 86 f2 03 00 00    	jbe    801ed5 <spawn+0x525>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801ae3:	83 ec 04             	sub    $0x4,%esp
  801ae6:	6a 07                	push   $0x7
  801ae8:	68 00 00 40 00       	push   $0x400000
  801aed:	6a 00                	push   $0x0
  801aef:	e8 f5 f1 ff ff       	call   800ce9 <sys_page_alloc>
  801af4:	83 c4 10             	add    $0x10,%esp
  801af7:	85 c0                	test   %eax,%eax
  801af9:	0f 88 db 03 00 00    	js     801eda <spawn+0x52a>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801aff:	be 00 00 00 00       	mov    $0x0,%esi
  801b04:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  801b0a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801b0d:	eb 30                	jmp    801b3f <spawn+0x18f>
		argv_store[i] = UTEMP2USTACK(string_store);
  801b0f:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801b15:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801b1b:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  801b1e:	83 ec 08             	sub    $0x8,%esp
  801b21:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801b24:	57                   	push   %edi
  801b25:	e8 c6 ed ff ff       	call   8008f0 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801b2a:	83 c4 04             	add    $0x4,%esp
  801b2d:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801b30:	e8 84 ed ff ff       	call   8008b9 <strlen>
  801b35:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  801b39:	83 c6 01             	add    $0x1,%esi
  801b3c:	83 c4 10             	add    $0x10,%esp
  801b3f:	39 b5 8c fd ff ff    	cmp    %esi,-0x274(%ebp)
  801b45:	7f c8                	jg     801b0f <spawn+0x15f>
	}
	argv_store[argc] = 0;
  801b47:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801b4d:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801b53:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801b5a:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801b60:	0f 85 8c 00 00 00    	jne    801bf2 <spawn+0x242>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801b66:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801b6c:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801b72:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801b75:	89 f8                	mov    %edi,%eax
  801b77:	8b bd 88 fd ff ff    	mov    -0x278(%ebp),%edi
  801b7d:	89 78 f8             	mov    %edi,-0x8(%eax)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801b80:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801b85:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801b8b:	83 ec 0c             	sub    $0xc,%esp
  801b8e:	6a 07                	push   $0x7
  801b90:	68 00 d0 bf ee       	push   $0xeebfd000
  801b95:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b9b:	68 00 00 40 00       	push   $0x400000
  801ba0:	6a 00                	push   $0x0
  801ba2:	e8 85 f1 ff ff       	call   800d2c <sys_page_map>
  801ba7:	89 c3                	mov    %eax,%ebx
  801ba9:	83 c4 20             	add    $0x20,%esp
  801bac:	85 c0                	test   %eax,%eax
  801bae:	0f 88 46 03 00 00    	js     801efa <spawn+0x54a>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801bb4:	83 ec 08             	sub    $0x8,%esp
  801bb7:	68 00 00 40 00       	push   $0x400000
  801bbc:	6a 00                	push   $0x0
  801bbe:	e8 ab f1 ff ff       	call   800d6e <sys_page_unmap>
  801bc3:	89 c3                	mov    %eax,%ebx
  801bc5:	83 c4 10             	add    $0x10,%esp
  801bc8:	85 c0                	test   %eax,%eax
  801bca:	0f 88 2a 03 00 00    	js     801efa <spawn+0x54a>
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801bd0:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801bd6:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801bdd:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801be3:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801bea:	00 00 00 
  801bed:	e9 56 01 00 00       	jmp    801d48 <spawn+0x398>
	assert(string_store == (char*)UTEMP + PGSIZE);
  801bf2:	68 94 2e 80 00       	push   $0x802e94
  801bf7:	68 f3 2d 80 00       	push   $0x802df3
  801bfc:	68 f2 00 00 00       	push   $0xf2
  801c01:	68 39 2e 80 00       	push   $0x802e39
  801c06:	e8 eb e5 ff ff       	call   8001f6 <_panic>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801c0b:	83 ec 04             	sub    $0x4,%esp
  801c0e:	6a 07                	push   $0x7
  801c10:	68 00 00 40 00       	push   $0x400000
  801c15:	6a 00                	push   $0x0
  801c17:	e8 cd f0 ff ff       	call   800ce9 <sys_page_alloc>
  801c1c:	83 c4 10             	add    $0x10,%esp
  801c1f:	85 c0                	test   %eax,%eax
  801c21:	0f 88 be 02 00 00    	js     801ee5 <spawn+0x535>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801c27:	83 ec 08             	sub    $0x8,%esp
  801c2a:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801c30:	01 f0                	add    %esi,%eax
  801c32:	50                   	push   %eax
  801c33:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801c39:	e8 c5 f9 ff ff       	call   801603 <seek>
  801c3e:	83 c4 10             	add    $0x10,%esp
  801c41:	85 c0                	test   %eax,%eax
  801c43:	0f 88 a3 02 00 00    	js     801eec <spawn+0x53c>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801c49:	83 ec 04             	sub    $0x4,%esp
  801c4c:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801c52:	29 f0                	sub    %esi,%eax
  801c54:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c59:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801c5e:	0f 47 c1             	cmova  %ecx,%eax
  801c61:	50                   	push   %eax
  801c62:	68 00 00 40 00       	push   $0x400000
  801c67:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801c6d:	e8 c8 f8 ff ff       	call   80153a <readn>
  801c72:	83 c4 10             	add    $0x10,%esp
  801c75:	85 c0                	test   %eax,%eax
  801c77:	0f 88 76 02 00 00    	js     801ef3 <spawn+0x543>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801c7d:	83 ec 0c             	sub    $0xc,%esp
  801c80:	57                   	push   %edi
  801c81:	03 b5 88 fd ff ff    	add    -0x278(%ebp),%esi
  801c87:	56                   	push   %esi
  801c88:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801c8e:	68 00 00 40 00       	push   $0x400000
  801c93:	6a 00                	push   $0x0
  801c95:	e8 92 f0 ff ff       	call   800d2c <sys_page_map>
  801c9a:	83 c4 20             	add    $0x20,%esp
  801c9d:	85 c0                	test   %eax,%eax
  801c9f:	0f 88 80 00 00 00    	js     801d25 <spawn+0x375>
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
  801ca5:	83 ec 08             	sub    $0x8,%esp
  801ca8:	68 00 00 40 00       	push   $0x400000
  801cad:	6a 00                	push   $0x0
  801caf:	e8 ba f0 ff ff       	call   800d6e <sys_page_unmap>
  801cb4:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < memsz; i += PGSIZE) {
  801cb7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801cbd:	89 de                	mov    %ebx,%esi
  801cbf:	39 9d 8c fd ff ff    	cmp    %ebx,-0x274(%ebp)
  801cc5:	76 73                	jbe    801d3a <spawn+0x38a>
		if (i >= filesz) {
  801cc7:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  801ccd:	0f 87 38 ff ff ff    	ja     801c0b <spawn+0x25b>
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801cd3:	83 ec 04             	sub    $0x4,%esp
  801cd6:	57                   	push   %edi
  801cd7:	03 b5 88 fd ff ff    	add    -0x278(%ebp),%esi
  801cdd:	56                   	push   %esi
  801cde:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801ce4:	e8 00 f0 ff ff       	call   800ce9 <sys_page_alloc>
  801ce9:	83 c4 10             	add    $0x10,%esp
  801cec:	85 c0                	test   %eax,%eax
  801cee:	79 c7                	jns    801cb7 <spawn+0x307>
  801cf0:	89 c7                	mov    %eax,%edi
	sys_env_destroy(child);
  801cf2:	83 ec 0c             	sub    $0xc,%esp
  801cf5:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801cfb:	e8 6a ef ff ff       	call   800c6a <sys_env_destroy>
	close(fd);
  801d00:	83 c4 04             	add    $0x4,%esp
  801d03:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801d09:	e8 69 f6 ff ff       	call   801377 <close>
	return r;
  801d0e:	83 c4 10             	add    $0x10,%esp
  801d11:	89 bd 90 fd ff ff    	mov    %edi,-0x270(%ebp)
}
  801d17:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801d1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d20:	5b                   	pop    %ebx
  801d21:	5e                   	pop    %esi
  801d22:	5f                   	pop    %edi
  801d23:	5d                   	pop    %ebp
  801d24:	c3                   	ret    
				panic("spawn: sys_page_map data: %e", r);
  801d25:	50                   	push   %eax
  801d26:	68 45 2e 80 00       	push   $0x802e45
  801d2b:	68 25 01 00 00       	push   $0x125
  801d30:	68 39 2e 80 00       	push   $0x802e39
  801d35:	e8 bc e4 ff ff       	call   8001f6 <_panic>
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801d3a:	83 85 7c fd ff ff 01 	addl   $0x1,-0x284(%ebp)
  801d41:	83 85 78 fd ff ff 20 	addl   $0x20,-0x288(%ebp)
  801d48:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801d4f:	3b 85 7c fd ff ff    	cmp    -0x284(%ebp),%eax
  801d55:	7e 71                	jle    801dc8 <spawn+0x418>
		if (ph->p_type != ELF_PROG_LOAD)
  801d57:	8b 8d 78 fd ff ff    	mov    -0x288(%ebp),%ecx
  801d5d:	83 39 01             	cmpl   $0x1,(%ecx)
  801d60:	75 d8                	jne    801d3a <spawn+0x38a>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801d62:	8b 41 18             	mov    0x18(%ecx),%eax
  801d65:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801d68:	83 f8 01             	cmp    $0x1,%eax
  801d6b:	19 ff                	sbb    %edi,%edi
  801d6d:	83 e7 fe             	and    $0xfffffffe,%edi
  801d70:	83 c7 07             	add    $0x7,%edi
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801d73:	8b 71 04             	mov    0x4(%ecx),%esi
  801d76:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  801d7c:	8b 59 10             	mov    0x10(%ecx),%ebx
  801d7f:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801d85:	8b 41 14             	mov    0x14(%ecx),%eax
  801d88:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801d8e:	8b 51 08             	mov    0x8(%ecx),%edx
  801d91:	89 95 88 fd ff ff    	mov    %edx,-0x278(%ebp)
	if ((i = PGOFF(va))) {
  801d97:	89 d0                	mov    %edx,%eax
  801d99:	25 ff 0f 00 00       	and    $0xfff,%eax
  801d9e:	74 1e                	je     801dbe <spawn+0x40e>
		va -= i;
  801da0:	29 c2                	sub    %eax,%edx
  801da2:	89 95 88 fd ff ff    	mov    %edx,-0x278(%ebp)
		memsz += i;
  801da8:	01 85 8c fd ff ff    	add    %eax,-0x274(%ebp)
		filesz += i;
  801dae:	01 c3                	add    %eax,%ebx
  801db0:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
		fileoffset -= i;
  801db6:	29 c6                	sub    %eax,%esi
  801db8:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
	for (i = 0; i < memsz; i += PGSIZE) {
  801dbe:	bb 00 00 00 00       	mov    $0x0,%ebx
  801dc3:	e9 f5 fe ff ff       	jmp    801cbd <spawn+0x30d>
	close(fd);
  801dc8:	83 ec 0c             	sub    $0xc,%esp
  801dcb:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801dd1:	e8 a1 f5 ff ff       	call   801377 <close>
  801dd6:	83 c4 10             	add    $0x10,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
    	uintptr_t addr;
    	for (addr = 0; addr < UTOP; addr += PGSIZE) {
  801dd9:	bb 00 00 00 00       	mov    $0x0,%ebx
  801dde:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
  801de4:	eb 0e                	jmp    801df4 <spawn+0x444>
  801de6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801dec:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801df2:	74 58                	je     801e4c <spawn+0x49c>
        	if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U) && (uvpt[PGNUM(addr)] & PTE_SHARE)) {
  801df4:	89 d8                	mov    %ebx,%eax
  801df6:	c1 e8 16             	shr    $0x16,%eax
  801df9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801e00:	a8 01                	test   $0x1,%al
  801e02:	74 e2                	je     801de6 <spawn+0x436>
  801e04:	89 d8                	mov    %ebx,%eax
  801e06:	c1 e8 0c             	shr    $0xc,%eax
  801e09:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801e10:	f6 c2 01             	test   $0x1,%dl
  801e13:	74 d1                	je     801de6 <spawn+0x436>
  801e15:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801e1c:	f6 c2 04             	test   $0x4,%dl
  801e1f:	74 c5                	je     801de6 <spawn+0x436>
  801e21:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801e28:	f6 c6 04             	test   $0x4,%dh
  801e2b:	74 b9                	je     801de6 <spawn+0x436>
            		sys_page_map(0, (void*)addr, child, (void*)addr, (uvpt[PGNUM(addr)] & PTE_SYSCALL));
  801e2d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801e34:	83 ec 0c             	sub    $0xc,%esp
  801e37:	25 07 0e 00 00       	and    $0xe07,%eax
  801e3c:	50                   	push   %eax
  801e3d:	53                   	push   %ebx
  801e3e:	56                   	push   %esi
  801e3f:	53                   	push   %ebx
  801e40:	6a 00                	push   $0x0
  801e42:	e8 e5 ee ff ff       	call   800d2c <sys_page_map>
  801e47:	83 c4 20             	add    $0x20,%esp
  801e4a:	eb 9a                	jmp    801de6 <spawn+0x436>
	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801e4c:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801e53:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801e56:	83 ec 08             	sub    $0x8,%esp
  801e59:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801e5f:	50                   	push   %eax
  801e60:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e66:	e8 87 ef ff ff       	call   800df2 <sys_env_set_trapframe>
  801e6b:	83 c4 10             	add    $0x10,%esp
  801e6e:	85 c0                	test   %eax,%eax
  801e70:	78 28                	js     801e9a <spawn+0x4ea>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801e72:	83 ec 08             	sub    $0x8,%esp
  801e75:	6a 02                	push   $0x2
  801e77:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e7d:	e8 2e ef ff ff       	call   800db0 <sys_env_set_status>
  801e82:	83 c4 10             	add    $0x10,%esp
  801e85:	85 c0                	test   %eax,%eax
  801e87:	78 26                	js     801eaf <spawn+0x4ff>
	return child;
  801e89:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801e8f:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  801e95:	e9 7d fe ff ff       	jmp    801d17 <spawn+0x367>
		panic("sys_env_set_trapframe: %e", r);
  801e9a:	50                   	push   %eax
  801e9b:	68 62 2e 80 00       	push   $0x802e62
  801ea0:	68 86 00 00 00       	push   $0x86
  801ea5:	68 39 2e 80 00       	push   $0x802e39
  801eaa:	e8 47 e3 ff ff       	call   8001f6 <_panic>
		panic("sys_env_set_status: %e", r);
  801eaf:	50                   	push   %eax
  801eb0:	68 7c 2e 80 00       	push   $0x802e7c
  801eb5:	68 89 00 00 00       	push   $0x89
  801eba:	68 39 2e 80 00       	push   $0x802e39
  801ebf:	e8 32 e3 ff ff       	call   8001f6 <_panic>
		return r;
  801ec4:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801eca:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  801ed0:	e9 42 fe ff ff       	jmp    801d17 <spawn+0x367>
		return -E_NO_MEM;
  801ed5:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return r;
  801eda:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  801ee0:	e9 32 fe ff ff       	jmp    801d17 <spawn+0x367>
  801ee5:	89 c7                	mov    %eax,%edi
  801ee7:	e9 06 fe ff ff       	jmp    801cf2 <spawn+0x342>
  801eec:	89 c7                	mov    %eax,%edi
  801eee:	e9 ff fd ff ff       	jmp    801cf2 <spawn+0x342>
  801ef3:	89 c7                	mov    %eax,%edi
  801ef5:	e9 f8 fd ff ff       	jmp    801cf2 <spawn+0x342>
	sys_page_unmap(0, UTEMP);
  801efa:	83 ec 08             	sub    $0x8,%esp
  801efd:	68 00 00 40 00       	push   $0x400000
  801f02:	6a 00                	push   $0x0
  801f04:	e8 65 ee ff ff       	call   800d6e <sys_page_unmap>
  801f09:	83 c4 10             	add    $0x10,%esp
  801f0c:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801f12:	e9 00 fe ff ff       	jmp    801d17 <spawn+0x367>

00801f17 <spawnl>:
{
  801f17:	55                   	push   %ebp
  801f18:	89 e5                	mov    %esp,%ebp
  801f1a:	57                   	push   %edi
  801f1b:	56                   	push   %esi
  801f1c:	53                   	push   %ebx
  801f1d:	83 ec 0c             	sub    $0xc,%esp
	va_start(vl, arg0);
  801f20:	8d 55 10             	lea    0x10(%ebp),%edx
	int argc=0;
  801f23:	b8 00 00 00 00       	mov    $0x0,%eax
	while(va_arg(vl, void *) != NULL)
  801f28:	eb 05                	jmp    801f2f <spawnl+0x18>
		argc++;
  801f2a:	83 c0 01             	add    $0x1,%eax
	while(va_arg(vl, void *) != NULL)
  801f2d:	89 ca                	mov    %ecx,%edx
  801f2f:	8d 4a 04             	lea    0x4(%edx),%ecx
  801f32:	83 3a 00             	cmpl   $0x0,(%edx)
  801f35:	75 f3                	jne    801f2a <spawnl+0x13>
	const char *argv[argc+2];
  801f37:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801f3e:	83 e2 f0             	and    $0xfffffff0,%edx
  801f41:	29 d4                	sub    %edx,%esp
  801f43:	8d 54 24 03          	lea    0x3(%esp),%edx
  801f47:	c1 ea 02             	shr    $0x2,%edx
  801f4a:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801f51:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801f53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f56:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801f5d:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801f64:	00 
	va_start(vl, arg0);
  801f65:	8d 4d 10             	lea    0x10(%ebp),%ecx
  801f68:	89 c2                	mov    %eax,%edx
	for(i=0;i<argc;i++)
  801f6a:	b8 00 00 00 00       	mov    $0x0,%eax
  801f6f:	eb 0b                	jmp    801f7c <spawnl+0x65>
		argv[i+1] = va_arg(vl, const char *);
  801f71:	83 c0 01             	add    $0x1,%eax
  801f74:	8b 39                	mov    (%ecx),%edi
  801f76:	89 3c 83             	mov    %edi,(%ebx,%eax,4)
  801f79:	8d 49 04             	lea    0x4(%ecx),%ecx
	for(i=0;i<argc;i++)
  801f7c:	39 d0                	cmp    %edx,%eax
  801f7e:	75 f1                	jne    801f71 <spawnl+0x5a>
	return spawn(prog, argv);
  801f80:	83 ec 08             	sub    $0x8,%esp
  801f83:	56                   	push   %esi
  801f84:	ff 75 08             	pushl  0x8(%ebp)
  801f87:	e8 24 fa ff ff       	call   8019b0 <spawn>
}
  801f8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f8f:	5b                   	pop    %ebx
  801f90:	5e                   	pop    %esi
  801f91:	5f                   	pop    %edi
  801f92:	5d                   	pop    %ebp
  801f93:	c3                   	ret    

00801f94 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f94:	55                   	push   %ebp
  801f95:	89 e5                	mov    %esp,%ebp
  801f97:	56                   	push   %esi
  801f98:	53                   	push   %ebx
  801f99:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f9c:	83 ec 0c             	sub    $0xc,%esp
  801f9f:	ff 75 08             	pushl  0x8(%ebp)
  801fa2:	e8 35 f2 ff ff       	call   8011dc <fd2data>
  801fa7:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801fa9:	83 c4 08             	add    $0x8,%esp
  801fac:	68 ba 2e 80 00       	push   $0x802eba
  801fb1:	53                   	push   %ebx
  801fb2:	e8 39 e9 ff ff       	call   8008f0 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801fb7:	8b 46 04             	mov    0x4(%esi),%eax
  801fba:	2b 06                	sub    (%esi),%eax
  801fbc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801fc2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801fc9:	00 00 00 
	stat->st_dev = &devpipe;
  801fcc:	c7 83 88 00 00 00 28 	movl   $0x803028,0x88(%ebx)
  801fd3:	30 80 00 
	return 0;
}
  801fd6:	b8 00 00 00 00       	mov    $0x0,%eax
  801fdb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fde:	5b                   	pop    %ebx
  801fdf:	5e                   	pop    %esi
  801fe0:	5d                   	pop    %ebp
  801fe1:	c3                   	ret    

00801fe2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801fe2:	55                   	push   %ebp
  801fe3:	89 e5                	mov    %esp,%ebp
  801fe5:	53                   	push   %ebx
  801fe6:	83 ec 0c             	sub    $0xc,%esp
  801fe9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801fec:	53                   	push   %ebx
  801fed:	6a 00                	push   $0x0
  801fef:	e8 7a ed ff ff       	call   800d6e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ff4:	89 1c 24             	mov    %ebx,(%esp)
  801ff7:	e8 e0 f1 ff ff       	call   8011dc <fd2data>
  801ffc:	83 c4 08             	add    $0x8,%esp
  801fff:	50                   	push   %eax
  802000:	6a 00                	push   $0x0
  802002:	e8 67 ed ff ff       	call   800d6e <sys_page_unmap>
}
  802007:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80200a:	c9                   	leave  
  80200b:	c3                   	ret    

0080200c <_pipeisclosed>:
{
  80200c:	55                   	push   %ebp
  80200d:	89 e5                	mov    %esp,%ebp
  80200f:	57                   	push   %edi
  802010:	56                   	push   %esi
  802011:	53                   	push   %ebx
  802012:	83 ec 1c             	sub    $0x1c,%esp
  802015:	89 c7                	mov    %eax,%edi
  802017:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  802019:	a1 04 40 80 00       	mov    0x804004,%eax
  80201e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802021:	83 ec 0c             	sub    $0xc,%esp
  802024:	57                   	push   %edi
  802025:	e8 0c 06 00 00       	call   802636 <pageref>
  80202a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80202d:	89 34 24             	mov    %esi,(%esp)
  802030:	e8 01 06 00 00       	call   802636 <pageref>
		nn = thisenv->env_runs;
  802035:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80203b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80203e:	83 c4 10             	add    $0x10,%esp
  802041:	39 cb                	cmp    %ecx,%ebx
  802043:	74 1b                	je     802060 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  802045:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802048:	75 cf                	jne    802019 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80204a:	8b 42 58             	mov    0x58(%edx),%eax
  80204d:	6a 01                	push   $0x1
  80204f:	50                   	push   %eax
  802050:	53                   	push   %ebx
  802051:	68 c1 2e 80 00       	push   $0x802ec1
  802056:	e8 76 e2 ff ff       	call   8002d1 <cprintf>
  80205b:	83 c4 10             	add    $0x10,%esp
  80205e:	eb b9                	jmp    802019 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  802060:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802063:	0f 94 c0             	sete   %al
  802066:	0f b6 c0             	movzbl %al,%eax
}
  802069:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80206c:	5b                   	pop    %ebx
  80206d:	5e                   	pop    %esi
  80206e:	5f                   	pop    %edi
  80206f:	5d                   	pop    %ebp
  802070:	c3                   	ret    

00802071 <devpipe_write>:
{
  802071:	55                   	push   %ebp
  802072:	89 e5                	mov    %esp,%ebp
  802074:	57                   	push   %edi
  802075:	56                   	push   %esi
  802076:	53                   	push   %ebx
  802077:	83 ec 28             	sub    $0x28,%esp
  80207a:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  80207d:	56                   	push   %esi
  80207e:	e8 59 f1 ff ff       	call   8011dc <fd2data>
  802083:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802085:	83 c4 10             	add    $0x10,%esp
  802088:	bf 00 00 00 00       	mov    $0x0,%edi
  80208d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802090:	74 4f                	je     8020e1 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802092:	8b 43 04             	mov    0x4(%ebx),%eax
  802095:	8b 0b                	mov    (%ebx),%ecx
  802097:	8d 51 20             	lea    0x20(%ecx),%edx
  80209a:	39 d0                	cmp    %edx,%eax
  80209c:	72 14                	jb     8020b2 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  80209e:	89 da                	mov    %ebx,%edx
  8020a0:	89 f0                	mov    %esi,%eax
  8020a2:	e8 65 ff ff ff       	call   80200c <_pipeisclosed>
  8020a7:	85 c0                	test   %eax,%eax
  8020a9:	75 3a                	jne    8020e5 <devpipe_write+0x74>
			sys_yield();
  8020ab:	e8 1a ec ff ff       	call   800cca <sys_yield>
  8020b0:	eb e0                	jmp    802092 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8020b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020b5:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8020b9:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8020bc:	89 c2                	mov    %eax,%edx
  8020be:	c1 fa 1f             	sar    $0x1f,%edx
  8020c1:	89 d1                	mov    %edx,%ecx
  8020c3:	c1 e9 1b             	shr    $0x1b,%ecx
  8020c6:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8020c9:	83 e2 1f             	and    $0x1f,%edx
  8020cc:	29 ca                	sub    %ecx,%edx
  8020ce:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8020d2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8020d6:	83 c0 01             	add    $0x1,%eax
  8020d9:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8020dc:	83 c7 01             	add    $0x1,%edi
  8020df:	eb ac                	jmp    80208d <devpipe_write+0x1c>
	return i;
  8020e1:	89 f8                	mov    %edi,%eax
  8020e3:	eb 05                	jmp    8020ea <devpipe_write+0x79>
				return 0;
  8020e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020ed:	5b                   	pop    %ebx
  8020ee:	5e                   	pop    %esi
  8020ef:	5f                   	pop    %edi
  8020f0:	5d                   	pop    %ebp
  8020f1:	c3                   	ret    

008020f2 <devpipe_read>:
{
  8020f2:	55                   	push   %ebp
  8020f3:	89 e5                	mov    %esp,%ebp
  8020f5:	57                   	push   %edi
  8020f6:	56                   	push   %esi
  8020f7:	53                   	push   %ebx
  8020f8:	83 ec 18             	sub    $0x18,%esp
  8020fb:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8020fe:	57                   	push   %edi
  8020ff:	e8 d8 f0 ff ff       	call   8011dc <fd2data>
  802104:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802106:	83 c4 10             	add    $0x10,%esp
  802109:	be 00 00 00 00       	mov    $0x0,%esi
  80210e:	3b 75 10             	cmp    0x10(%ebp),%esi
  802111:	74 47                	je     80215a <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  802113:	8b 03                	mov    (%ebx),%eax
  802115:	3b 43 04             	cmp    0x4(%ebx),%eax
  802118:	75 22                	jne    80213c <devpipe_read+0x4a>
			if (i > 0)
  80211a:	85 f6                	test   %esi,%esi
  80211c:	75 14                	jne    802132 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  80211e:	89 da                	mov    %ebx,%edx
  802120:	89 f8                	mov    %edi,%eax
  802122:	e8 e5 fe ff ff       	call   80200c <_pipeisclosed>
  802127:	85 c0                	test   %eax,%eax
  802129:	75 33                	jne    80215e <devpipe_read+0x6c>
			sys_yield();
  80212b:	e8 9a eb ff ff       	call   800cca <sys_yield>
  802130:	eb e1                	jmp    802113 <devpipe_read+0x21>
				return i;
  802132:	89 f0                	mov    %esi,%eax
}
  802134:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802137:	5b                   	pop    %ebx
  802138:	5e                   	pop    %esi
  802139:	5f                   	pop    %edi
  80213a:	5d                   	pop    %ebp
  80213b:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80213c:	99                   	cltd   
  80213d:	c1 ea 1b             	shr    $0x1b,%edx
  802140:	01 d0                	add    %edx,%eax
  802142:	83 e0 1f             	and    $0x1f,%eax
  802145:	29 d0                	sub    %edx,%eax
  802147:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  80214c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80214f:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  802152:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  802155:	83 c6 01             	add    $0x1,%esi
  802158:	eb b4                	jmp    80210e <devpipe_read+0x1c>
	return i;
  80215a:	89 f0                	mov    %esi,%eax
  80215c:	eb d6                	jmp    802134 <devpipe_read+0x42>
				return 0;
  80215e:	b8 00 00 00 00       	mov    $0x0,%eax
  802163:	eb cf                	jmp    802134 <devpipe_read+0x42>

00802165 <pipe>:
{
  802165:	55                   	push   %ebp
  802166:	89 e5                	mov    %esp,%ebp
  802168:	56                   	push   %esi
  802169:	53                   	push   %ebx
  80216a:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  80216d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802170:	50                   	push   %eax
  802171:	e8 7d f0 ff ff       	call   8011f3 <fd_alloc>
  802176:	89 c3                	mov    %eax,%ebx
  802178:	83 c4 10             	add    $0x10,%esp
  80217b:	85 c0                	test   %eax,%eax
  80217d:	78 5b                	js     8021da <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80217f:	83 ec 04             	sub    $0x4,%esp
  802182:	68 07 04 00 00       	push   $0x407
  802187:	ff 75 f4             	pushl  -0xc(%ebp)
  80218a:	6a 00                	push   $0x0
  80218c:	e8 58 eb ff ff       	call   800ce9 <sys_page_alloc>
  802191:	89 c3                	mov    %eax,%ebx
  802193:	83 c4 10             	add    $0x10,%esp
  802196:	85 c0                	test   %eax,%eax
  802198:	78 40                	js     8021da <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  80219a:	83 ec 0c             	sub    $0xc,%esp
  80219d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8021a0:	50                   	push   %eax
  8021a1:	e8 4d f0 ff ff       	call   8011f3 <fd_alloc>
  8021a6:	89 c3                	mov    %eax,%ebx
  8021a8:	83 c4 10             	add    $0x10,%esp
  8021ab:	85 c0                	test   %eax,%eax
  8021ad:	78 1b                	js     8021ca <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021af:	83 ec 04             	sub    $0x4,%esp
  8021b2:	68 07 04 00 00       	push   $0x407
  8021b7:	ff 75 f0             	pushl  -0x10(%ebp)
  8021ba:	6a 00                	push   $0x0
  8021bc:	e8 28 eb ff ff       	call   800ce9 <sys_page_alloc>
  8021c1:	89 c3                	mov    %eax,%ebx
  8021c3:	83 c4 10             	add    $0x10,%esp
  8021c6:	85 c0                	test   %eax,%eax
  8021c8:	79 19                	jns    8021e3 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  8021ca:	83 ec 08             	sub    $0x8,%esp
  8021cd:	ff 75 f4             	pushl  -0xc(%ebp)
  8021d0:	6a 00                	push   $0x0
  8021d2:	e8 97 eb ff ff       	call   800d6e <sys_page_unmap>
  8021d7:	83 c4 10             	add    $0x10,%esp
}
  8021da:	89 d8                	mov    %ebx,%eax
  8021dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021df:	5b                   	pop    %ebx
  8021e0:	5e                   	pop    %esi
  8021e1:	5d                   	pop    %ebp
  8021e2:	c3                   	ret    
	va = fd2data(fd0);
  8021e3:	83 ec 0c             	sub    $0xc,%esp
  8021e6:	ff 75 f4             	pushl  -0xc(%ebp)
  8021e9:	e8 ee ef ff ff       	call   8011dc <fd2data>
  8021ee:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021f0:	83 c4 0c             	add    $0xc,%esp
  8021f3:	68 07 04 00 00       	push   $0x407
  8021f8:	50                   	push   %eax
  8021f9:	6a 00                	push   $0x0
  8021fb:	e8 e9 ea ff ff       	call   800ce9 <sys_page_alloc>
  802200:	89 c3                	mov    %eax,%ebx
  802202:	83 c4 10             	add    $0x10,%esp
  802205:	85 c0                	test   %eax,%eax
  802207:	0f 88 8c 00 00 00    	js     802299 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80220d:	83 ec 0c             	sub    $0xc,%esp
  802210:	ff 75 f0             	pushl  -0x10(%ebp)
  802213:	e8 c4 ef ff ff       	call   8011dc <fd2data>
  802218:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80221f:	50                   	push   %eax
  802220:	6a 00                	push   $0x0
  802222:	56                   	push   %esi
  802223:	6a 00                	push   $0x0
  802225:	e8 02 eb ff ff       	call   800d2c <sys_page_map>
  80222a:	89 c3                	mov    %eax,%ebx
  80222c:	83 c4 20             	add    $0x20,%esp
  80222f:	85 c0                	test   %eax,%eax
  802231:	78 58                	js     80228b <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  802233:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802236:	8b 15 28 30 80 00    	mov    0x803028,%edx
  80223c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80223e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802241:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  802248:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80224b:	8b 15 28 30 80 00    	mov    0x803028,%edx
  802251:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802253:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802256:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  80225d:	83 ec 0c             	sub    $0xc,%esp
  802260:	ff 75 f4             	pushl  -0xc(%ebp)
  802263:	e8 64 ef ff ff       	call   8011cc <fd2num>
  802268:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80226b:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80226d:	83 c4 04             	add    $0x4,%esp
  802270:	ff 75 f0             	pushl  -0x10(%ebp)
  802273:	e8 54 ef ff ff       	call   8011cc <fd2num>
  802278:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80227b:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80227e:	83 c4 10             	add    $0x10,%esp
  802281:	bb 00 00 00 00       	mov    $0x0,%ebx
  802286:	e9 4f ff ff ff       	jmp    8021da <pipe+0x75>
	sys_page_unmap(0, va);
  80228b:	83 ec 08             	sub    $0x8,%esp
  80228e:	56                   	push   %esi
  80228f:	6a 00                	push   $0x0
  802291:	e8 d8 ea ff ff       	call   800d6e <sys_page_unmap>
  802296:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  802299:	83 ec 08             	sub    $0x8,%esp
  80229c:	ff 75 f0             	pushl  -0x10(%ebp)
  80229f:	6a 00                	push   $0x0
  8022a1:	e8 c8 ea ff ff       	call   800d6e <sys_page_unmap>
  8022a6:	83 c4 10             	add    $0x10,%esp
  8022a9:	e9 1c ff ff ff       	jmp    8021ca <pipe+0x65>

008022ae <pipeisclosed>:
{
  8022ae:	55                   	push   %ebp
  8022af:	89 e5                	mov    %esp,%ebp
  8022b1:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022b7:	50                   	push   %eax
  8022b8:	ff 75 08             	pushl  0x8(%ebp)
  8022bb:	e8 82 ef ff ff       	call   801242 <fd_lookup>
  8022c0:	83 c4 10             	add    $0x10,%esp
  8022c3:	85 c0                	test   %eax,%eax
  8022c5:	78 18                	js     8022df <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  8022c7:	83 ec 0c             	sub    $0xc,%esp
  8022ca:	ff 75 f4             	pushl  -0xc(%ebp)
  8022cd:	e8 0a ef ff ff       	call   8011dc <fd2data>
	return _pipeisclosed(fd, p);
  8022d2:	89 c2                	mov    %eax,%edx
  8022d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022d7:	e8 30 fd ff ff       	call   80200c <_pipeisclosed>
  8022dc:	83 c4 10             	add    $0x10,%esp
}
  8022df:	c9                   	leave  
  8022e0:	c3                   	ret    

008022e1 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8022e1:	55                   	push   %ebp
  8022e2:	89 e5                	mov    %esp,%ebp
  8022e4:	56                   	push   %esi
  8022e5:	53                   	push   %ebx
  8022e6:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8022e9:	85 f6                	test   %esi,%esi
  8022eb:	74 13                	je     802300 <wait+0x1f>
	e = &envs[ENVX(envid)];
  8022ed:	89 f3                	mov    %esi,%ebx
  8022ef:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8022f5:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  8022f8:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8022fe:	eb 1b                	jmp    80231b <wait+0x3a>
	assert(envid != 0);
  802300:	68 d9 2e 80 00       	push   $0x802ed9
  802305:	68 f3 2d 80 00       	push   $0x802df3
  80230a:	6a 09                	push   $0x9
  80230c:	68 e4 2e 80 00       	push   $0x802ee4
  802311:	e8 e0 de ff ff       	call   8001f6 <_panic>
		sys_yield();
  802316:	e8 af e9 ff ff       	call   800cca <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80231b:	8b 43 48             	mov    0x48(%ebx),%eax
  80231e:	39 f0                	cmp    %esi,%eax
  802320:	75 07                	jne    802329 <wait+0x48>
  802322:	8b 43 54             	mov    0x54(%ebx),%eax
  802325:	85 c0                	test   %eax,%eax
  802327:	75 ed                	jne    802316 <wait+0x35>
}
  802329:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80232c:	5b                   	pop    %ebx
  80232d:	5e                   	pop    %esi
  80232e:	5d                   	pop    %ebp
  80232f:	c3                   	ret    

00802330 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802330:	55                   	push   %ebp
  802331:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802333:	b8 00 00 00 00       	mov    $0x0,%eax
  802338:	5d                   	pop    %ebp
  802339:	c3                   	ret    

0080233a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80233a:	55                   	push   %ebp
  80233b:	89 e5                	mov    %esp,%ebp
  80233d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802340:	68 ef 2e 80 00       	push   $0x802eef
  802345:	ff 75 0c             	pushl  0xc(%ebp)
  802348:	e8 a3 e5 ff ff       	call   8008f0 <strcpy>
	return 0;
}
  80234d:	b8 00 00 00 00       	mov    $0x0,%eax
  802352:	c9                   	leave  
  802353:	c3                   	ret    

00802354 <devcons_write>:
{
  802354:	55                   	push   %ebp
  802355:	89 e5                	mov    %esp,%ebp
  802357:	57                   	push   %edi
  802358:	56                   	push   %esi
  802359:	53                   	push   %ebx
  80235a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  802360:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802365:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  80236b:	eb 2f                	jmp    80239c <devcons_write+0x48>
		m = n - tot;
  80236d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802370:	29 f3                	sub    %esi,%ebx
  802372:	83 fb 7f             	cmp    $0x7f,%ebx
  802375:	b8 7f 00 00 00       	mov    $0x7f,%eax
  80237a:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80237d:	83 ec 04             	sub    $0x4,%esp
  802380:	53                   	push   %ebx
  802381:	89 f0                	mov    %esi,%eax
  802383:	03 45 0c             	add    0xc(%ebp),%eax
  802386:	50                   	push   %eax
  802387:	57                   	push   %edi
  802388:	e8 f1 e6 ff ff       	call   800a7e <memmove>
		sys_cputs(buf, m);
  80238d:	83 c4 08             	add    $0x8,%esp
  802390:	53                   	push   %ebx
  802391:	57                   	push   %edi
  802392:	e8 96 e8 ff ff       	call   800c2d <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  802397:	01 de                	add    %ebx,%esi
  802399:	83 c4 10             	add    $0x10,%esp
  80239c:	3b 75 10             	cmp    0x10(%ebp),%esi
  80239f:	72 cc                	jb     80236d <devcons_write+0x19>
}
  8023a1:	89 f0                	mov    %esi,%eax
  8023a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023a6:	5b                   	pop    %ebx
  8023a7:	5e                   	pop    %esi
  8023a8:	5f                   	pop    %edi
  8023a9:	5d                   	pop    %ebp
  8023aa:	c3                   	ret    

008023ab <devcons_read>:
{
  8023ab:	55                   	push   %ebp
  8023ac:	89 e5                	mov    %esp,%ebp
  8023ae:	83 ec 08             	sub    $0x8,%esp
  8023b1:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8023b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8023ba:	75 07                	jne    8023c3 <devcons_read+0x18>
}
  8023bc:	c9                   	leave  
  8023bd:	c3                   	ret    
		sys_yield();
  8023be:	e8 07 e9 ff ff       	call   800cca <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8023c3:	e8 83 e8 ff ff       	call   800c4b <sys_cgetc>
  8023c8:	85 c0                	test   %eax,%eax
  8023ca:	74 f2                	je     8023be <devcons_read+0x13>
	if (c < 0)
  8023cc:	85 c0                	test   %eax,%eax
  8023ce:	78 ec                	js     8023bc <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  8023d0:	83 f8 04             	cmp    $0x4,%eax
  8023d3:	74 0c                	je     8023e1 <devcons_read+0x36>
	*(char*)vbuf = c;
  8023d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023d8:	88 02                	mov    %al,(%edx)
	return 1;
  8023da:	b8 01 00 00 00       	mov    $0x1,%eax
  8023df:	eb db                	jmp    8023bc <devcons_read+0x11>
		return 0;
  8023e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8023e6:	eb d4                	jmp    8023bc <devcons_read+0x11>

008023e8 <cputchar>:
{
  8023e8:	55                   	push   %ebp
  8023e9:	89 e5                	mov    %esp,%ebp
  8023eb:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8023ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8023f1:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8023f4:	6a 01                	push   $0x1
  8023f6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8023f9:	50                   	push   %eax
  8023fa:	e8 2e e8 ff ff       	call   800c2d <sys_cputs>
}
  8023ff:	83 c4 10             	add    $0x10,%esp
  802402:	c9                   	leave  
  802403:	c3                   	ret    

00802404 <getchar>:
{
  802404:	55                   	push   %ebp
  802405:	89 e5                	mov    %esp,%ebp
  802407:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80240a:	6a 01                	push   $0x1
  80240c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80240f:	50                   	push   %eax
  802410:	6a 00                	push   $0x0
  802412:	e8 9c f0 ff ff       	call   8014b3 <read>
	if (r < 0)
  802417:	83 c4 10             	add    $0x10,%esp
  80241a:	85 c0                	test   %eax,%eax
  80241c:	78 08                	js     802426 <getchar+0x22>
	if (r < 1)
  80241e:	85 c0                	test   %eax,%eax
  802420:	7e 06                	jle    802428 <getchar+0x24>
	return c;
  802422:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802426:	c9                   	leave  
  802427:	c3                   	ret    
		return -E_EOF;
  802428:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80242d:	eb f7                	jmp    802426 <getchar+0x22>

0080242f <iscons>:
{
  80242f:	55                   	push   %ebp
  802430:	89 e5                	mov    %esp,%ebp
  802432:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802435:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802438:	50                   	push   %eax
  802439:	ff 75 08             	pushl  0x8(%ebp)
  80243c:	e8 01 ee ff ff       	call   801242 <fd_lookup>
  802441:	83 c4 10             	add    $0x10,%esp
  802444:	85 c0                	test   %eax,%eax
  802446:	78 11                	js     802459 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  802448:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80244b:	8b 15 44 30 80 00    	mov    0x803044,%edx
  802451:	39 10                	cmp    %edx,(%eax)
  802453:	0f 94 c0             	sete   %al
  802456:	0f b6 c0             	movzbl %al,%eax
}
  802459:	c9                   	leave  
  80245a:	c3                   	ret    

0080245b <opencons>:
{
  80245b:	55                   	push   %ebp
  80245c:	89 e5                	mov    %esp,%ebp
  80245e:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802461:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802464:	50                   	push   %eax
  802465:	e8 89 ed ff ff       	call   8011f3 <fd_alloc>
  80246a:	83 c4 10             	add    $0x10,%esp
  80246d:	85 c0                	test   %eax,%eax
  80246f:	78 3a                	js     8024ab <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802471:	83 ec 04             	sub    $0x4,%esp
  802474:	68 07 04 00 00       	push   $0x407
  802479:	ff 75 f4             	pushl  -0xc(%ebp)
  80247c:	6a 00                	push   $0x0
  80247e:	e8 66 e8 ff ff       	call   800ce9 <sys_page_alloc>
  802483:	83 c4 10             	add    $0x10,%esp
  802486:	85 c0                	test   %eax,%eax
  802488:	78 21                	js     8024ab <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  80248a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80248d:	8b 15 44 30 80 00    	mov    0x803044,%edx
  802493:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802495:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802498:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80249f:	83 ec 0c             	sub    $0xc,%esp
  8024a2:	50                   	push   %eax
  8024a3:	e8 24 ed ff ff       	call   8011cc <fd2num>
  8024a8:	83 c4 10             	add    $0x10,%esp
}
  8024ab:	c9                   	leave  
  8024ac:	c3                   	ret    

008024ad <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8024ad:	55                   	push   %ebp
  8024ae:	89 e5                	mov    %esp,%ebp
  8024b0:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8024b3:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8024ba:	74 20                	je     8024dc <set_pgfault_handler+0x2f>
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
			panic("set_pgfault_handler:sys_page_alloc failed");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8024bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8024bf:	a3 00 60 80 00       	mov    %eax,0x806000
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  8024c4:	83 ec 08             	sub    $0x8,%esp
  8024c7:	68 1c 25 80 00       	push   $0x80251c
  8024cc:	6a 00                	push   $0x0
  8024ce:	e8 61 e9 ff ff       	call   800e34 <sys_env_set_pgfault_upcall>
  8024d3:	83 c4 10             	add    $0x10,%esp
  8024d6:	85 c0                	test   %eax,%eax
  8024d8:	78 2e                	js     802508 <set_pgfault_handler+0x5b>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
}
  8024da:	c9                   	leave  
  8024db:	c3                   	ret    
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  8024dc:	83 ec 04             	sub    $0x4,%esp
  8024df:	6a 07                	push   $0x7
  8024e1:	68 00 f0 bf ee       	push   $0xeebff000
  8024e6:	6a 00                	push   $0x0
  8024e8:	e8 fc e7 ff ff       	call   800ce9 <sys_page_alloc>
  8024ed:	83 c4 10             	add    $0x10,%esp
  8024f0:	85 c0                	test   %eax,%eax
  8024f2:	79 c8                	jns    8024bc <set_pgfault_handler+0xf>
			panic("set_pgfault_handler:sys_page_alloc failed");
  8024f4:	83 ec 04             	sub    $0x4,%esp
  8024f7:	68 fc 2e 80 00       	push   $0x802efc
  8024fc:	6a 21                	push   $0x21
  8024fe:	68 60 2f 80 00       	push   $0x802f60
  802503:	e8 ee dc ff ff       	call   8001f6 <_panic>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  802508:	83 ec 04             	sub    $0x4,%esp
  80250b:	68 28 2f 80 00       	push   $0x802f28
  802510:	6a 27                	push   $0x27
  802512:	68 60 2f 80 00       	push   $0x802f60
  802517:	e8 da dc ff ff       	call   8001f6 <_panic>

0080251c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80251c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80251d:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802522:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802524:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %eax
  802527:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  80252b:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  80252e:	89 44 24 30          	mov    %eax,0x30(%esp)
	movl 40(%esp), %ebx
  802532:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  802536:	89 18                	mov    %ebx,(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  802538:	83 c4 08             	add    $0x8,%esp
	popal
  80253b:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  80253c:	83 c4 04             	add    $0x4,%esp
	popfl
  80253f:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802540:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802541:	c3                   	ret    

00802542 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802542:	55                   	push   %ebp
  802543:	89 e5                	mov    %esp,%ebp
  802545:	56                   	push   %esi
  802546:	53                   	push   %ebx
  802547:	8b 75 08             	mov    0x8(%ebp),%esi
  80254a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80254d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  802550:	85 f6                	test   %esi,%esi
  802552:	74 06                	je     80255a <ipc_recv+0x18>
  802554:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  80255a:	85 db                	test   %ebx,%ebx
  80255c:	74 06                	je     802564 <ipc_recv+0x22>
  80255e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  802564:	85 c0                	test   %eax,%eax
  802566:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  80256b:	0f 44 c2             	cmove  %edx,%eax
	int ret = sys_ipc_recv(pg);
  80256e:	83 ec 0c             	sub    $0xc,%esp
  802571:	50                   	push   %eax
  802572:	e8 22 e9 ff ff       	call   800e99 <sys_ipc_recv>
	if (ret) return ret;
  802577:	83 c4 10             	add    $0x10,%esp
  80257a:	85 c0                	test   %eax,%eax
  80257c:	75 24                	jne    8025a2 <ipc_recv+0x60>
	if (from_env_store)
  80257e:	85 f6                	test   %esi,%esi
  802580:	74 0a                	je     80258c <ipc_recv+0x4a>
		*from_env_store = thisenv->env_ipc_from;
  802582:	a1 04 40 80 00       	mov    0x804004,%eax
  802587:	8b 40 74             	mov    0x74(%eax),%eax
  80258a:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  80258c:	85 db                	test   %ebx,%ebx
  80258e:	74 0a                	je     80259a <ipc_recv+0x58>
		*perm_store = thisenv->env_ipc_perm;
  802590:	a1 04 40 80 00       	mov    0x804004,%eax
  802595:	8b 40 78             	mov    0x78(%eax),%eax
  802598:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  80259a:	a1 04 40 80 00       	mov    0x804004,%eax
  80259f:	8b 40 70             	mov    0x70(%eax),%eax
}
  8025a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8025a5:	5b                   	pop    %ebx
  8025a6:	5e                   	pop    %esi
  8025a7:	5d                   	pop    %ebp
  8025a8:	c3                   	ret    

008025a9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8025a9:	55                   	push   %ebp
  8025aa:	89 e5                	mov    %esp,%ebp
  8025ac:	57                   	push   %edi
  8025ad:	56                   	push   %esi
  8025ae:	53                   	push   %ebx
  8025af:	83 ec 0c             	sub    $0xc,%esp
  8025b2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8025b5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8025b8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  8025bb:	85 db                	test   %ebx,%ebx
  8025bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8025c2:	0f 44 d8             	cmove  %eax,%ebx
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  8025c5:	ff 75 14             	pushl  0x14(%ebp)
  8025c8:	53                   	push   %ebx
  8025c9:	56                   	push   %esi
  8025ca:	57                   	push   %edi
  8025cb:	e8 a6 e8 ff ff       	call   800e76 <sys_ipc_try_send>
  8025d0:	83 c4 10             	add    $0x10,%esp
  8025d3:	85 c0                	test   %eax,%eax
  8025d5:	74 1e                	je     8025f5 <ipc_send+0x4c>
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  8025d7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8025da:	75 07                	jne    8025e3 <ipc_send+0x3a>
		sys_yield();
  8025dc:	e8 e9 e6 ff ff       	call   800cca <sys_yield>
  8025e1:	eb e2                	jmp    8025c5 <ipc_send+0x1c>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  8025e3:	50                   	push   %eax
  8025e4:	68 6e 2f 80 00       	push   $0x802f6e
  8025e9:	6a 36                	push   $0x36
  8025eb:	68 85 2f 80 00       	push   $0x802f85
  8025f0:	e8 01 dc ff ff       	call   8001f6 <_panic>
	}
}
  8025f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025f8:	5b                   	pop    %ebx
  8025f9:	5e                   	pop    %esi
  8025fa:	5f                   	pop    %edi
  8025fb:	5d                   	pop    %ebp
  8025fc:	c3                   	ret    

008025fd <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8025fd:	55                   	push   %ebp
  8025fe:	89 e5                	mov    %esp,%ebp
  802600:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802603:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802608:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80260b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802611:	8b 52 50             	mov    0x50(%edx),%edx
  802614:	39 ca                	cmp    %ecx,%edx
  802616:	74 11                	je     802629 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  802618:	83 c0 01             	add    $0x1,%eax
  80261b:	3d 00 04 00 00       	cmp    $0x400,%eax
  802620:	75 e6                	jne    802608 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  802622:	b8 00 00 00 00       	mov    $0x0,%eax
  802627:	eb 0b                	jmp    802634 <ipc_find_env+0x37>
			return envs[i].env_id;
  802629:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80262c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802631:	8b 40 48             	mov    0x48(%eax),%eax
}
  802634:	5d                   	pop    %ebp
  802635:	c3                   	ret    

00802636 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802636:	55                   	push   %ebp
  802637:	89 e5                	mov    %esp,%ebp
  802639:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80263c:	89 d0                	mov    %edx,%eax
  80263e:	c1 e8 16             	shr    $0x16,%eax
  802641:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802648:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  80264d:	f6 c1 01             	test   $0x1,%cl
  802650:	74 1d                	je     80266f <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  802652:	c1 ea 0c             	shr    $0xc,%edx
  802655:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80265c:	f6 c2 01             	test   $0x1,%dl
  80265f:	74 0e                	je     80266f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802661:	c1 ea 0c             	shr    $0xc,%edx
  802664:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80266b:	ef 
  80266c:	0f b7 c0             	movzwl %ax,%eax
}
  80266f:	5d                   	pop    %ebp
  802670:	c3                   	ret    
  802671:	66 90                	xchg   %ax,%ax
  802673:	66 90                	xchg   %ax,%ax
  802675:	66 90                	xchg   %ax,%ax
  802677:	66 90                	xchg   %ax,%ax
  802679:	66 90                	xchg   %ax,%ax
  80267b:	66 90                	xchg   %ax,%ax
  80267d:	66 90                	xchg   %ax,%ax
  80267f:	90                   	nop

00802680 <__udivdi3>:
  802680:	55                   	push   %ebp
  802681:	57                   	push   %edi
  802682:	56                   	push   %esi
  802683:	53                   	push   %ebx
  802684:	83 ec 1c             	sub    $0x1c,%esp
  802687:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80268b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  80268f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802693:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  802697:	85 d2                	test   %edx,%edx
  802699:	75 35                	jne    8026d0 <__udivdi3+0x50>
  80269b:	39 f3                	cmp    %esi,%ebx
  80269d:	0f 87 bd 00 00 00    	ja     802760 <__udivdi3+0xe0>
  8026a3:	85 db                	test   %ebx,%ebx
  8026a5:	89 d9                	mov    %ebx,%ecx
  8026a7:	75 0b                	jne    8026b4 <__udivdi3+0x34>
  8026a9:	b8 01 00 00 00       	mov    $0x1,%eax
  8026ae:	31 d2                	xor    %edx,%edx
  8026b0:	f7 f3                	div    %ebx
  8026b2:	89 c1                	mov    %eax,%ecx
  8026b4:	31 d2                	xor    %edx,%edx
  8026b6:	89 f0                	mov    %esi,%eax
  8026b8:	f7 f1                	div    %ecx
  8026ba:	89 c6                	mov    %eax,%esi
  8026bc:	89 e8                	mov    %ebp,%eax
  8026be:	89 f7                	mov    %esi,%edi
  8026c0:	f7 f1                	div    %ecx
  8026c2:	89 fa                	mov    %edi,%edx
  8026c4:	83 c4 1c             	add    $0x1c,%esp
  8026c7:	5b                   	pop    %ebx
  8026c8:	5e                   	pop    %esi
  8026c9:	5f                   	pop    %edi
  8026ca:	5d                   	pop    %ebp
  8026cb:	c3                   	ret    
  8026cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026d0:	39 f2                	cmp    %esi,%edx
  8026d2:	77 7c                	ja     802750 <__udivdi3+0xd0>
  8026d4:	0f bd fa             	bsr    %edx,%edi
  8026d7:	83 f7 1f             	xor    $0x1f,%edi
  8026da:	0f 84 98 00 00 00    	je     802778 <__udivdi3+0xf8>
  8026e0:	89 f9                	mov    %edi,%ecx
  8026e2:	b8 20 00 00 00       	mov    $0x20,%eax
  8026e7:	29 f8                	sub    %edi,%eax
  8026e9:	d3 e2                	shl    %cl,%edx
  8026eb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8026ef:	89 c1                	mov    %eax,%ecx
  8026f1:	89 da                	mov    %ebx,%edx
  8026f3:	d3 ea                	shr    %cl,%edx
  8026f5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8026f9:	09 d1                	or     %edx,%ecx
  8026fb:	89 f2                	mov    %esi,%edx
  8026fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802701:	89 f9                	mov    %edi,%ecx
  802703:	d3 e3                	shl    %cl,%ebx
  802705:	89 c1                	mov    %eax,%ecx
  802707:	d3 ea                	shr    %cl,%edx
  802709:	89 f9                	mov    %edi,%ecx
  80270b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80270f:	d3 e6                	shl    %cl,%esi
  802711:	89 eb                	mov    %ebp,%ebx
  802713:	89 c1                	mov    %eax,%ecx
  802715:	d3 eb                	shr    %cl,%ebx
  802717:	09 de                	or     %ebx,%esi
  802719:	89 f0                	mov    %esi,%eax
  80271b:	f7 74 24 08          	divl   0x8(%esp)
  80271f:	89 d6                	mov    %edx,%esi
  802721:	89 c3                	mov    %eax,%ebx
  802723:	f7 64 24 0c          	mull   0xc(%esp)
  802727:	39 d6                	cmp    %edx,%esi
  802729:	72 0c                	jb     802737 <__udivdi3+0xb7>
  80272b:	89 f9                	mov    %edi,%ecx
  80272d:	d3 e5                	shl    %cl,%ebp
  80272f:	39 c5                	cmp    %eax,%ebp
  802731:	73 5d                	jae    802790 <__udivdi3+0x110>
  802733:	39 d6                	cmp    %edx,%esi
  802735:	75 59                	jne    802790 <__udivdi3+0x110>
  802737:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80273a:	31 ff                	xor    %edi,%edi
  80273c:	89 fa                	mov    %edi,%edx
  80273e:	83 c4 1c             	add    $0x1c,%esp
  802741:	5b                   	pop    %ebx
  802742:	5e                   	pop    %esi
  802743:	5f                   	pop    %edi
  802744:	5d                   	pop    %ebp
  802745:	c3                   	ret    
  802746:	8d 76 00             	lea    0x0(%esi),%esi
  802749:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802750:	31 ff                	xor    %edi,%edi
  802752:	31 c0                	xor    %eax,%eax
  802754:	89 fa                	mov    %edi,%edx
  802756:	83 c4 1c             	add    $0x1c,%esp
  802759:	5b                   	pop    %ebx
  80275a:	5e                   	pop    %esi
  80275b:	5f                   	pop    %edi
  80275c:	5d                   	pop    %ebp
  80275d:	c3                   	ret    
  80275e:	66 90                	xchg   %ax,%ax
  802760:	31 ff                	xor    %edi,%edi
  802762:	89 e8                	mov    %ebp,%eax
  802764:	89 f2                	mov    %esi,%edx
  802766:	f7 f3                	div    %ebx
  802768:	89 fa                	mov    %edi,%edx
  80276a:	83 c4 1c             	add    $0x1c,%esp
  80276d:	5b                   	pop    %ebx
  80276e:	5e                   	pop    %esi
  80276f:	5f                   	pop    %edi
  802770:	5d                   	pop    %ebp
  802771:	c3                   	ret    
  802772:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802778:	39 f2                	cmp    %esi,%edx
  80277a:	72 06                	jb     802782 <__udivdi3+0x102>
  80277c:	31 c0                	xor    %eax,%eax
  80277e:	39 eb                	cmp    %ebp,%ebx
  802780:	77 d2                	ja     802754 <__udivdi3+0xd4>
  802782:	b8 01 00 00 00       	mov    $0x1,%eax
  802787:	eb cb                	jmp    802754 <__udivdi3+0xd4>
  802789:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802790:	89 d8                	mov    %ebx,%eax
  802792:	31 ff                	xor    %edi,%edi
  802794:	eb be                	jmp    802754 <__udivdi3+0xd4>
  802796:	66 90                	xchg   %ax,%ax
  802798:	66 90                	xchg   %ax,%ax
  80279a:	66 90                	xchg   %ax,%ax
  80279c:	66 90                	xchg   %ax,%ax
  80279e:	66 90                	xchg   %ax,%ax

008027a0 <__umoddi3>:
  8027a0:	55                   	push   %ebp
  8027a1:	57                   	push   %edi
  8027a2:	56                   	push   %esi
  8027a3:	53                   	push   %ebx
  8027a4:	83 ec 1c             	sub    $0x1c,%esp
  8027a7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8027ab:	8b 74 24 30          	mov    0x30(%esp),%esi
  8027af:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8027b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8027b7:	85 ed                	test   %ebp,%ebp
  8027b9:	89 f0                	mov    %esi,%eax
  8027bb:	89 da                	mov    %ebx,%edx
  8027bd:	75 19                	jne    8027d8 <__umoddi3+0x38>
  8027bf:	39 df                	cmp    %ebx,%edi
  8027c1:	0f 86 b1 00 00 00    	jbe    802878 <__umoddi3+0xd8>
  8027c7:	f7 f7                	div    %edi
  8027c9:	89 d0                	mov    %edx,%eax
  8027cb:	31 d2                	xor    %edx,%edx
  8027cd:	83 c4 1c             	add    $0x1c,%esp
  8027d0:	5b                   	pop    %ebx
  8027d1:	5e                   	pop    %esi
  8027d2:	5f                   	pop    %edi
  8027d3:	5d                   	pop    %ebp
  8027d4:	c3                   	ret    
  8027d5:	8d 76 00             	lea    0x0(%esi),%esi
  8027d8:	39 dd                	cmp    %ebx,%ebp
  8027da:	77 f1                	ja     8027cd <__umoddi3+0x2d>
  8027dc:	0f bd cd             	bsr    %ebp,%ecx
  8027df:	83 f1 1f             	xor    $0x1f,%ecx
  8027e2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8027e6:	0f 84 b4 00 00 00    	je     8028a0 <__umoddi3+0x100>
  8027ec:	b8 20 00 00 00       	mov    $0x20,%eax
  8027f1:	89 c2                	mov    %eax,%edx
  8027f3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8027f7:	29 c2                	sub    %eax,%edx
  8027f9:	89 c1                	mov    %eax,%ecx
  8027fb:	89 f8                	mov    %edi,%eax
  8027fd:	d3 e5                	shl    %cl,%ebp
  8027ff:	89 d1                	mov    %edx,%ecx
  802801:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802805:	d3 e8                	shr    %cl,%eax
  802807:	09 c5                	or     %eax,%ebp
  802809:	8b 44 24 04          	mov    0x4(%esp),%eax
  80280d:	89 c1                	mov    %eax,%ecx
  80280f:	d3 e7                	shl    %cl,%edi
  802811:	89 d1                	mov    %edx,%ecx
  802813:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802817:	89 df                	mov    %ebx,%edi
  802819:	d3 ef                	shr    %cl,%edi
  80281b:	89 c1                	mov    %eax,%ecx
  80281d:	89 f0                	mov    %esi,%eax
  80281f:	d3 e3                	shl    %cl,%ebx
  802821:	89 d1                	mov    %edx,%ecx
  802823:	89 fa                	mov    %edi,%edx
  802825:	d3 e8                	shr    %cl,%eax
  802827:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80282c:	09 d8                	or     %ebx,%eax
  80282e:	f7 f5                	div    %ebp
  802830:	d3 e6                	shl    %cl,%esi
  802832:	89 d1                	mov    %edx,%ecx
  802834:	f7 64 24 08          	mull   0x8(%esp)
  802838:	39 d1                	cmp    %edx,%ecx
  80283a:	89 c3                	mov    %eax,%ebx
  80283c:	89 d7                	mov    %edx,%edi
  80283e:	72 06                	jb     802846 <__umoddi3+0xa6>
  802840:	75 0e                	jne    802850 <__umoddi3+0xb0>
  802842:	39 c6                	cmp    %eax,%esi
  802844:	73 0a                	jae    802850 <__umoddi3+0xb0>
  802846:	2b 44 24 08          	sub    0x8(%esp),%eax
  80284a:	19 ea                	sbb    %ebp,%edx
  80284c:	89 d7                	mov    %edx,%edi
  80284e:	89 c3                	mov    %eax,%ebx
  802850:	89 ca                	mov    %ecx,%edx
  802852:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  802857:	29 de                	sub    %ebx,%esi
  802859:	19 fa                	sbb    %edi,%edx
  80285b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80285f:	89 d0                	mov    %edx,%eax
  802861:	d3 e0                	shl    %cl,%eax
  802863:	89 d9                	mov    %ebx,%ecx
  802865:	d3 ee                	shr    %cl,%esi
  802867:	d3 ea                	shr    %cl,%edx
  802869:	09 f0                	or     %esi,%eax
  80286b:	83 c4 1c             	add    $0x1c,%esp
  80286e:	5b                   	pop    %ebx
  80286f:	5e                   	pop    %esi
  802870:	5f                   	pop    %edi
  802871:	5d                   	pop    %ebp
  802872:	c3                   	ret    
  802873:	90                   	nop
  802874:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802878:	85 ff                	test   %edi,%edi
  80287a:	89 f9                	mov    %edi,%ecx
  80287c:	75 0b                	jne    802889 <__umoddi3+0xe9>
  80287e:	b8 01 00 00 00       	mov    $0x1,%eax
  802883:	31 d2                	xor    %edx,%edx
  802885:	f7 f7                	div    %edi
  802887:	89 c1                	mov    %eax,%ecx
  802889:	89 d8                	mov    %ebx,%eax
  80288b:	31 d2                	xor    %edx,%edx
  80288d:	f7 f1                	div    %ecx
  80288f:	89 f0                	mov    %esi,%eax
  802891:	f7 f1                	div    %ecx
  802893:	e9 31 ff ff ff       	jmp    8027c9 <__umoddi3+0x29>
  802898:	90                   	nop
  802899:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8028a0:	39 dd                	cmp    %ebx,%ebp
  8028a2:	72 08                	jb     8028ac <__umoddi3+0x10c>
  8028a4:	39 f7                	cmp    %esi,%edi
  8028a6:	0f 87 21 ff ff ff    	ja     8027cd <__umoddi3+0x2d>
  8028ac:	89 da                	mov    %ebx,%edx
  8028ae:	89 f0                	mov    %esi,%eax
  8028b0:	29 f8                	sub    %edi,%eax
  8028b2:	19 ea                	sbb    %ebp,%edx
  8028b4:	e9 14 ff ff ff       	jmp    8027cd <__umoddi3+0x2d>
