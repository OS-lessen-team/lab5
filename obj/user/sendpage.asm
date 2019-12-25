
obj/user/sendpage.debug：     文件格式 elf32-i386


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
  80002c:	e8 6e 01 00 00       	call   80019f <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#define TEMP_ADDR	((char*)0xa00000)
#define TEMP_ADDR_CHILD	((char*)0xb00000)

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	envid_t who;

	if ((who = fork()) == 0) {
  800039:	e8 61 0f 00 00       	call   800f9f <fork>
  80003e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800041:	85 c0                	test   %eax,%eax
  800043:	0f 85 9e 00 00 00    	jne    8000e7 <umain+0xb4>
		// Child
		ipc_recv(&who, TEMP_ADDR_CHILD, 0);
  800049:	83 ec 04             	sub    $0x4,%esp
  80004c:	6a 00                	push   $0x0
  80004e:	68 00 00 b0 00       	push   $0xb00000
  800053:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800056:	50                   	push   %eax
  800057:	e8 33 11 00 00       	call   80118f <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  80005c:	83 c4 0c             	add    $0xc,%esp
  80005f:	68 00 00 b0 00       	push   $0xb00000
  800064:	ff 75 f4             	pushl  -0xc(%ebp)
  800067:	68 a0 22 80 00       	push   $0x8022a0
  80006c:	e8 23 02 00 00       	call   800294 <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800071:	83 c4 04             	add    $0x4,%esp
  800074:	ff 35 04 30 80 00    	pushl  0x803004
  80007a:	e8 fd 07 00 00       	call   80087c <strlen>
  80007f:	83 c4 0c             	add    $0xc,%esp
  800082:	50                   	push   %eax
  800083:	ff 35 04 30 80 00    	pushl  0x803004
  800089:	68 00 00 b0 00       	push   $0xb00000
  80008e:	e8 ec 08 00 00       	call   80097f <strncmp>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	74 3b                	je     8000d5 <umain+0xa2>
			cprintf("child received correct message\n");

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  80009a:	83 ec 0c             	sub    $0xc,%esp
  80009d:	ff 35 00 30 80 00    	pushl  0x803000
  8000a3:	e8 d4 07 00 00       	call   80087c <strlen>
  8000a8:	83 c4 0c             	add    $0xc,%esp
  8000ab:	83 c0 01             	add    $0x1,%eax
  8000ae:	50                   	push   %eax
  8000af:	ff 35 00 30 80 00    	pushl  0x803000
  8000b5:	68 00 00 b0 00       	push   $0xb00000
  8000ba:	e8 ea 09 00 00       	call   800aa9 <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000bf:	6a 07                	push   $0x7
  8000c1:	68 00 00 b0 00       	push   $0xb00000
  8000c6:	6a 00                	push   $0x0
  8000c8:	ff 75 f4             	pushl  -0xc(%ebp)
  8000cb:	e8 26 11 00 00       	call   8011f6 <ipc_send>
		return;
  8000d0:	83 c4 20             	add    $0x20,%esp
	ipc_recv(&who, TEMP_ADDR, 0);
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
		cprintf("parent received correct message\n");
	return;
}
  8000d3:	c9                   	leave  
  8000d4:	c3                   	ret    
			cprintf("child received correct message\n");
  8000d5:	83 ec 0c             	sub    $0xc,%esp
  8000d8:	68 b4 22 80 00       	push   $0x8022b4
  8000dd:	e8 b2 01 00 00       	call   800294 <cprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	eb b3                	jmp    80009a <umain+0x67>
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  8000e7:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ec:	8b 40 48             	mov    0x48(%eax),%eax
  8000ef:	83 ec 04             	sub    $0x4,%esp
  8000f2:	6a 07                	push   $0x7
  8000f4:	68 00 00 a0 00       	push   $0xa00000
  8000f9:	50                   	push   %eax
  8000fa:	e8 ad 0b 00 00       	call   800cac <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  8000ff:	83 c4 04             	add    $0x4,%esp
  800102:	ff 35 04 30 80 00    	pushl  0x803004
  800108:	e8 6f 07 00 00       	call   80087c <strlen>
  80010d:	83 c4 0c             	add    $0xc,%esp
  800110:	83 c0 01             	add    $0x1,%eax
  800113:	50                   	push   %eax
  800114:	ff 35 04 30 80 00    	pushl  0x803004
  80011a:	68 00 00 a0 00       	push   $0xa00000
  80011f:	e8 85 09 00 00       	call   800aa9 <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800124:	6a 07                	push   $0x7
  800126:	68 00 00 a0 00       	push   $0xa00000
  80012b:	6a 00                	push   $0x0
  80012d:	ff 75 f4             	pushl  -0xc(%ebp)
  800130:	e8 c1 10 00 00       	call   8011f6 <ipc_send>
	ipc_recv(&who, TEMP_ADDR, 0);
  800135:	83 c4 1c             	add    $0x1c,%esp
  800138:	6a 00                	push   $0x0
  80013a:	68 00 00 a0 00       	push   $0xa00000
  80013f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800142:	50                   	push   %eax
  800143:	e8 47 10 00 00       	call   80118f <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  800148:	83 c4 0c             	add    $0xc,%esp
  80014b:	68 00 00 a0 00       	push   $0xa00000
  800150:	ff 75 f4             	pushl  -0xc(%ebp)
  800153:	68 a0 22 80 00       	push   $0x8022a0
  800158:	e8 37 01 00 00       	call   800294 <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  80015d:	83 c4 04             	add    $0x4,%esp
  800160:	ff 35 00 30 80 00    	pushl  0x803000
  800166:	e8 11 07 00 00       	call   80087c <strlen>
  80016b:	83 c4 0c             	add    $0xc,%esp
  80016e:	50                   	push   %eax
  80016f:	ff 35 00 30 80 00    	pushl  0x803000
  800175:	68 00 00 a0 00       	push   $0xa00000
  80017a:	e8 00 08 00 00       	call   80097f <strncmp>
  80017f:	83 c4 10             	add    $0x10,%esp
  800182:	85 c0                	test   %eax,%eax
  800184:	0f 85 49 ff ff ff    	jne    8000d3 <umain+0xa0>
		cprintf("parent received correct message\n");
  80018a:	83 ec 0c             	sub    $0xc,%esp
  80018d:	68 d4 22 80 00       	push   $0x8022d4
  800192:	e8 fd 00 00 00       	call   800294 <cprintf>
  800197:	83 c4 10             	add    $0x10,%esp
  80019a:	e9 34 ff ff ff       	jmp    8000d3 <umain+0xa0>

0080019f <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80019f:	55                   	push   %ebp
  8001a0:	89 e5                	mov    %esp,%ebp
  8001a2:	56                   	push   %esi
  8001a3:	53                   	push   %ebx
  8001a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001a7:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  8001aa:	e8 bf 0a 00 00       	call   800c6e <sys_getenvid>
	thisenv = envs + ENVX(envid); 
  8001af:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001b4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001b7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001bc:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001c1:	85 db                	test   %ebx,%ebx
  8001c3:	7e 07                	jle    8001cc <libmain+0x2d>
		binaryname = argv[0];
  8001c5:	8b 06                	mov    (%esi),%eax
  8001c7:	a3 08 30 80 00       	mov    %eax,0x803008

	// call user main routine
	umain(argc, argv);
  8001cc:	83 ec 08             	sub    $0x8,%esp
  8001cf:	56                   	push   %esi
  8001d0:	53                   	push   %ebx
  8001d1:	e8 5d fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001d6:	e8 0a 00 00 00       	call   8001e5 <exit>
}
  8001db:	83 c4 10             	add    $0x10,%esp
  8001de:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001e1:	5b                   	pop    %ebx
  8001e2:	5e                   	pop    %esi
  8001e3:	5d                   	pop    %ebp
  8001e4:	c3                   	ret    

008001e5 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001e5:	55                   	push   %ebp
  8001e6:	89 e5                	mov    %esp,%ebp
  8001e8:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001eb:	e8 69 12 00 00       	call   801459 <close_all>
	sys_env_destroy(0);
  8001f0:	83 ec 0c             	sub    $0xc,%esp
  8001f3:	6a 00                	push   $0x0
  8001f5:	e8 33 0a 00 00       	call   800c2d <sys_env_destroy>
}
  8001fa:	83 c4 10             	add    $0x10,%esp
  8001fd:	c9                   	leave  
  8001fe:	c3                   	ret    

008001ff <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001ff:	55                   	push   %ebp
  800200:	89 e5                	mov    %esp,%ebp
  800202:	53                   	push   %ebx
  800203:	83 ec 04             	sub    $0x4,%esp
  800206:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800209:	8b 13                	mov    (%ebx),%edx
  80020b:	8d 42 01             	lea    0x1(%edx),%eax
  80020e:	89 03                	mov    %eax,(%ebx)
  800210:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800213:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800217:	3d ff 00 00 00       	cmp    $0xff,%eax
  80021c:	74 09                	je     800227 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80021e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800222:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800225:	c9                   	leave  
  800226:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800227:	83 ec 08             	sub    $0x8,%esp
  80022a:	68 ff 00 00 00       	push   $0xff
  80022f:	8d 43 08             	lea    0x8(%ebx),%eax
  800232:	50                   	push   %eax
  800233:	e8 b8 09 00 00       	call   800bf0 <sys_cputs>
		b->idx = 0;
  800238:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80023e:	83 c4 10             	add    $0x10,%esp
  800241:	eb db                	jmp    80021e <putch+0x1f>

00800243 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800243:	55                   	push   %ebp
  800244:	89 e5                	mov    %esp,%ebp
  800246:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80024c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800253:	00 00 00 
	b.cnt = 0;
  800256:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80025d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800260:	ff 75 0c             	pushl  0xc(%ebp)
  800263:	ff 75 08             	pushl  0x8(%ebp)
  800266:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80026c:	50                   	push   %eax
  80026d:	68 ff 01 80 00       	push   $0x8001ff
  800272:	e8 1a 01 00 00       	call   800391 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800277:	83 c4 08             	add    $0x8,%esp
  80027a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800280:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800286:	50                   	push   %eax
  800287:	e8 64 09 00 00       	call   800bf0 <sys_cputs>

	return b.cnt;
}
  80028c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800292:	c9                   	leave  
  800293:	c3                   	ret    

00800294 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800294:	55                   	push   %ebp
  800295:	89 e5                	mov    %esp,%ebp
  800297:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80029a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80029d:	50                   	push   %eax
  80029e:	ff 75 08             	pushl  0x8(%ebp)
  8002a1:	e8 9d ff ff ff       	call   800243 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002a6:	c9                   	leave  
  8002a7:	c3                   	ret    

008002a8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a8:	55                   	push   %ebp
  8002a9:	89 e5                	mov    %esp,%ebp
  8002ab:	57                   	push   %edi
  8002ac:	56                   	push   %esi
  8002ad:	53                   	push   %ebx
  8002ae:	83 ec 1c             	sub    $0x1c,%esp
  8002b1:	89 c7                	mov    %eax,%edi
  8002b3:	89 d6                	mov    %edx,%esi
  8002b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002be:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002c1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002cc:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002cf:	39 d3                	cmp    %edx,%ebx
  8002d1:	72 05                	jb     8002d8 <printnum+0x30>
  8002d3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002d6:	77 7a                	ja     800352 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d8:	83 ec 0c             	sub    $0xc,%esp
  8002db:	ff 75 18             	pushl  0x18(%ebp)
  8002de:	8b 45 14             	mov    0x14(%ebp),%eax
  8002e1:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002e4:	53                   	push   %ebx
  8002e5:	ff 75 10             	pushl  0x10(%ebp)
  8002e8:	83 ec 08             	sub    $0x8,%esp
  8002eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8002f1:	ff 75 dc             	pushl  -0x24(%ebp)
  8002f4:	ff 75 d8             	pushl  -0x28(%ebp)
  8002f7:	e8 54 1d 00 00       	call   802050 <__udivdi3>
  8002fc:	83 c4 18             	add    $0x18,%esp
  8002ff:	52                   	push   %edx
  800300:	50                   	push   %eax
  800301:	89 f2                	mov    %esi,%edx
  800303:	89 f8                	mov    %edi,%eax
  800305:	e8 9e ff ff ff       	call   8002a8 <printnum>
  80030a:	83 c4 20             	add    $0x20,%esp
  80030d:	eb 13                	jmp    800322 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80030f:	83 ec 08             	sub    $0x8,%esp
  800312:	56                   	push   %esi
  800313:	ff 75 18             	pushl  0x18(%ebp)
  800316:	ff d7                	call   *%edi
  800318:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80031b:	83 eb 01             	sub    $0x1,%ebx
  80031e:	85 db                	test   %ebx,%ebx
  800320:	7f ed                	jg     80030f <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800322:	83 ec 08             	sub    $0x8,%esp
  800325:	56                   	push   %esi
  800326:	83 ec 04             	sub    $0x4,%esp
  800329:	ff 75 e4             	pushl  -0x1c(%ebp)
  80032c:	ff 75 e0             	pushl  -0x20(%ebp)
  80032f:	ff 75 dc             	pushl  -0x24(%ebp)
  800332:	ff 75 d8             	pushl  -0x28(%ebp)
  800335:	e8 36 1e 00 00       	call   802170 <__umoddi3>
  80033a:	83 c4 14             	add    $0x14,%esp
  80033d:	0f be 80 4c 23 80 00 	movsbl 0x80234c(%eax),%eax
  800344:	50                   	push   %eax
  800345:	ff d7                	call   *%edi
}
  800347:	83 c4 10             	add    $0x10,%esp
  80034a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034d:	5b                   	pop    %ebx
  80034e:	5e                   	pop    %esi
  80034f:	5f                   	pop    %edi
  800350:	5d                   	pop    %ebp
  800351:	c3                   	ret    
  800352:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800355:	eb c4                	jmp    80031b <printnum+0x73>

00800357 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
  80035a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80035d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800361:	8b 10                	mov    (%eax),%edx
  800363:	3b 50 04             	cmp    0x4(%eax),%edx
  800366:	73 0a                	jae    800372 <sprintputch+0x1b>
		*b->buf++ = ch;
  800368:	8d 4a 01             	lea    0x1(%edx),%ecx
  80036b:	89 08                	mov    %ecx,(%eax)
  80036d:	8b 45 08             	mov    0x8(%ebp),%eax
  800370:	88 02                	mov    %al,(%edx)
}
  800372:	5d                   	pop    %ebp
  800373:	c3                   	ret    

00800374 <printfmt>:
{
  800374:	55                   	push   %ebp
  800375:	89 e5                	mov    %esp,%ebp
  800377:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80037a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80037d:	50                   	push   %eax
  80037e:	ff 75 10             	pushl  0x10(%ebp)
  800381:	ff 75 0c             	pushl  0xc(%ebp)
  800384:	ff 75 08             	pushl  0x8(%ebp)
  800387:	e8 05 00 00 00       	call   800391 <vprintfmt>
}
  80038c:	83 c4 10             	add    $0x10,%esp
  80038f:	c9                   	leave  
  800390:	c3                   	ret    

00800391 <vprintfmt>:
{
  800391:	55                   	push   %ebp
  800392:	89 e5                	mov    %esp,%ebp
  800394:	57                   	push   %edi
  800395:	56                   	push   %esi
  800396:	53                   	push   %ebx
  800397:	83 ec 2c             	sub    $0x2c,%esp
  80039a:	8b 75 08             	mov    0x8(%ebp),%esi
  80039d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003a0:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003a3:	e9 c1 03 00 00       	jmp    800769 <vprintfmt+0x3d8>
		padc = ' ';
  8003a8:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8003ac:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8003b3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8003ba:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003c1:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003c6:	8d 47 01             	lea    0x1(%edi),%eax
  8003c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003cc:	0f b6 17             	movzbl (%edi),%edx
  8003cf:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003d2:	3c 55                	cmp    $0x55,%al
  8003d4:	0f 87 12 04 00 00    	ja     8007ec <vprintfmt+0x45b>
  8003da:	0f b6 c0             	movzbl %al,%eax
  8003dd:	ff 24 85 80 24 80 00 	jmp    *0x802480(,%eax,4)
  8003e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8003e7:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8003eb:	eb d9                	jmp    8003c6 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8003ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  8003f0:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003f4:	eb d0                	jmp    8003c6 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8003f6:	0f b6 d2             	movzbl %dl,%edx
  8003f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800401:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800404:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800407:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80040b:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80040e:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800411:	83 f9 09             	cmp    $0x9,%ecx
  800414:	77 55                	ja     80046b <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800416:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800419:	eb e9                	jmp    800404 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  80041b:	8b 45 14             	mov    0x14(%ebp),%eax
  80041e:	8b 00                	mov    (%eax),%eax
  800420:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800423:	8b 45 14             	mov    0x14(%ebp),%eax
  800426:	8d 40 04             	lea    0x4(%eax),%eax
  800429:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80042c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80042f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800433:	79 91                	jns    8003c6 <vprintfmt+0x35>
				width = precision, precision = -1;
  800435:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800438:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80043b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800442:	eb 82                	jmp    8003c6 <vprintfmt+0x35>
  800444:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800447:	85 c0                	test   %eax,%eax
  800449:	ba 00 00 00 00       	mov    $0x0,%edx
  80044e:	0f 49 d0             	cmovns %eax,%edx
  800451:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800454:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800457:	e9 6a ff ff ff       	jmp    8003c6 <vprintfmt+0x35>
  80045c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80045f:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800466:	e9 5b ff ff ff       	jmp    8003c6 <vprintfmt+0x35>
  80046b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80046e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800471:	eb bc                	jmp    80042f <vprintfmt+0x9e>
			lflag++;
  800473:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800476:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800479:	e9 48 ff ff ff       	jmp    8003c6 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  80047e:	8b 45 14             	mov    0x14(%ebp),%eax
  800481:	8d 78 04             	lea    0x4(%eax),%edi
  800484:	83 ec 08             	sub    $0x8,%esp
  800487:	53                   	push   %ebx
  800488:	ff 30                	pushl  (%eax)
  80048a:	ff d6                	call   *%esi
			break;
  80048c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80048f:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800492:	e9 cf 02 00 00       	jmp    800766 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  800497:	8b 45 14             	mov    0x14(%ebp),%eax
  80049a:	8d 78 04             	lea    0x4(%eax),%edi
  80049d:	8b 00                	mov    (%eax),%eax
  80049f:	99                   	cltd   
  8004a0:	31 d0                	xor    %edx,%eax
  8004a2:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004a4:	83 f8 0f             	cmp    $0xf,%eax
  8004a7:	7f 23                	jg     8004cc <vprintfmt+0x13b>
  8004a9:	8b 14 85 e0 25 80 00 	mov    0x8025e0(,%eax,4),%edx
  8004b0:	85 d2                	test   %edx,%edx
  8004b2:	74 18                	je     8004cc <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8004b4:	52                   	push   %edx
  8004b5:	68 c5 27 80 00       	push   $0x8027c5
  8004ba:	53                   	push   %ebx
  8004bb:	56                   	push   %esi
  8004bc:	e8 b3 fe ff ff       	call   800374 <printfmt>
  8004c1:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004c4:	89 7d 14             	mov    %edi,0x14(%ebp)
  8004c7:	e9 9a 02 00 00       	jmp    800766 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  8004cc:	50                   	push   %eax
  8004cd:	68 64 23 80 00       	push   $0x802364
  8004d2:	53                   	push   %ebx
  8004d3:	56                   	push   %esi
  8004d4:	e8 9b fe ff ff       	call   800374 <printfmt>
  8004d9:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004dc:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8004df:	e9 82 02 00 00       	jmp    800766 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  8004e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e7:	83 c0 04             	add    $0x4,%eax
  8004ea:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8004ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f0:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004f2:	85 ff                	test   %edi,%edi
  8004f4:	b8 5d 23 80 00       	mov    $0x80235d,%eax
  8004f9:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004fc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800500:	0f 8e bd 00 00 00    	jle    8005c3 <vprintfmt+0x232>
  800506:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80050a:	75 0e                	jne    80051a <vprintfmt+0x189>
  80050c:	89 75 08             	mov    %esi,0x8(%ebp)
  80050f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800512:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800515:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800518:	eb 6d                	jmp    800587 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  80051a:	83 ec 08             	sub    $0x8,%esp
  80051d:	ff 75 d0             	pushl  -0x30(%ebp)
  800520:	57                   	push   %edi
  800521:	e8 6e 03 00 00       	call   800894 <strnlen>
  800526:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800529:	29 c1                	sub    %eax,%ecx
  80052b:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80052e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800531:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800535:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800538:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80053b:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  80053d:	eb 0f                	jmp    80054e <vprintfmt+0x1bd>
					putch(padc, putdat);
  80053f:	83 ec 08             	sub    $0x8,%esp
  800542:	53                   	push   %ebx
  800543:	ff 75 e0             	pushl  -0x20(%ebp)
  800546:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800548:	83 ef 01             	sub    $0x1,%edi
  80054b:	83 c4 10             	add    $0x10,%esp
  80054e:	85 ff                	test   %edi,%edi
  800550:	7f ed                	jg     80053f <vprintfmt+0x1ae>
  800552:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800555:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800558:	85 c9                	test   %ecx,%ecx
  80055a:	b8 00 00 00 00       	mov    $0x0,%eax
  80055f:	0f 49 c1             	cmovns %ecx,%eax
  800562:	29 c1                	sub    %eax,%ecx
  800564:	89 75 08             	mov    %esi,0x8(%ebp)
  800567:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80056a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80056d:	89 cb                	mov    %ecx,%ebx
  80056f:	eb 16                	jmp    800587 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  800571:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800575:	75 31                	jne    8005a8 <vprintfmt+0x217>
					putch(ch, putdat);
  800577:	83 ec 08             	sub    $0x8,%esp
  80057a:	ff 75 0c             	pushl  0xc(%ebp)
  80057d:	50                   	push   %eax
  80057e:	ff 55 08             	call   *0x8(%ebp)
  800581:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800584:	83 eb 01             	sub    $0x1,%ebx
  800587:	83 c7 01             	add    $0x1,%edi
  80058a:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  80058e:	0f be c2             	movsbl %dl,%eax
  800591:	85 c0                	test   %eax,%eax
  800593:	74 59                	je     8005ee <vprintfmt+0x25d>
  800595:	85 f6                	test   %esi,%esi
  800597:	78 d8                	js     800571 <vprintfmt+0x1e0>
  800599:	83 ee 01             	sub    $0x1,%esi
  80059c:	79 d3                	jns    800571 <vprintfmt+0x1e0>
  80059e:	89 df                	mov    %ebx,%edi
  8005a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a6:	eb 37                	jmp    8005df <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8005a8:	0f be d2             	movsbl %dl,%edx
  8005ab:	83 ea 20             	sub    $0x20,%edx
  8005ae:	83 fa 5e             	cmp    $0x5e,%edx
  8005b1:	76 c4                	jbe    800577 <vprintfmt+0x1e6>
					putch('?', putdat);
  8005b3:	83 ec 08             	sub    $0x8,%esp
  8005b6:	ff 75 0c             	pushl  0xc(%ebp)
  8005b9:	6a 3f                	push   $0x3f
  8005bb:	ff 55 08             	call   *0x8(%ebp)
  8005be:	83 c4 10             	add    $0x10,%esp
  8005c1:	eb c1                	jmp    800584 <vprintfmt+0x1f3>
  8005c3:	89 75 08             	mov    %esi,0x8(%ebp)
  8005c6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005c9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005cc:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005cf:	eb b6                	jmp    800587 <vprintfmt+0x1f6>
				putch(' ', putdat);
  8005d1:	83 ec 08             	sub    $0x8,%esp
  8005d4:	53                   	push   %ebx
  8005d5:	6a 20                	push   $0x20
  8005d7:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8005d9:	83 ef 01             	sub    $0x1,%edi
  8005dc:	83 c4 10             	add    $0x10,%esp
  8005df:	85 ff                	test   %edi,%edi
  8005e1:	7f ee                	jg     8005d1 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  8005e3:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005e6:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e9:	e9 78 01 00 00       	jmp    800766 <vprintfmt+0x3d5>
  8005ee:	89 df                	mov    %ebx,%edi
  8005f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8005f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005f6:	eb e7                	jmp    8005df <vprintfmt+0x24e>
	if (lflag >= 2)
  8005f8:	83 f9 01             	cmp    $0x1,%ecx
  8005fb:	7e 3f                	jle    80063c <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  8005fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800600:	8b 50 04             	mov    0x4(%eax),%edx
  800603:	8b 00                	mov    (%eax),%eax
  800605:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800608:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80060b:	8b 45 14             	mov    0x14(%ebp),%eax
  80060e:	8d 40 08             	lea    0x8(%eax),%eax
  800611:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800614:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800618:	79 5c                	jns    800676 <vprintfmt+0x2e5>
				putch('-', putdat);
  80061a:	83 ec 08             	sub    $0x8,%esp
  80061d:	53                   	push   %ebx
  80061e:	6a 2d                	push   $0x2d
  800620:	ff d6                	call   *%esi
				num = -(long long) num;
  800622:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800625:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800628:	f7 da                	neg    %edx
  80062a:	83 d1 00             	adc    $0x0,%ecx
  80062d:	f7 d9                	neg    %ecx
  80062f:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800632:	b8 0a 00 00 00       	mov    $0xa,%eax
  800637:	e9 10 01 00 00       	jmp    80074c <vprintfmt+0x3bb>
	else if (lflag)
  80063c:	85 c9                	test   %ecx,%ecx
  80063e:	75 1b                	jne    80065b <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800640:	8b 45 14             	mov    0x14(%ebp),%eax
  800643:	8b 00                	mov    (%eax),%eax
  800645:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800648:	89 c1                	mov    %eax,%ecx
  80064a:	c1 f9 1f             	sar    $0x1f,%ecx
  80064d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800650:	8b 45 14             	mov    0x14(%ebp),%eax
  800653:	8d 40 04             	lea    0x4(%eax),%eax
  800656:	89 45 14             	mov    %eax,0x14(%ebp)
  800659:	eb b9                	jmp    800614 <vprintfmt+0x283>
		return va_arg(*ap, long);
  80065b:	8b 45 14             	mov    0x14(%ebp),%eax
  80065e:	8b 00                	mov    (%eax),%eax
  800660:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800663:	89 c1                	mov    %eax,%ecx
  800665:	c1 f9 1f             	sar    $0x1f,%ecx
  800668:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80066b:	8b 45 14             	mov    0x14(%ebp),%eax
  80066e:	8d 40 04             	lea    0x4(%eax),%eax
  800671:	89 45 14             	mov    %eax,0x14(%ebp)
  800674:	eb 9e                	jmp    800614 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  800676:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800679:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80067c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800681:	e9 c6 00 00 00       	jmp    80074c <vprintfmt+0x3bb>
	if (lflag >= 2)
  800686:	83 f9 01             	cmp    $0x1,%ecx
  800689:	7e 18                	jle    8006a3 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  80068b:	8b 45 14             	mov    0x14(%ebp),%eax
  80068e:	8b 10                	mov    (%eax),%edx
  800690:	8b 48 04             	mov    0x4(%eax),%ecx
  800693:	8d 40 08             	lea    0x8(%eax),%eax
  800696:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800699:	b8 0a 00 00 00       	mov    $0xa,%eax
  80069e:	e9 a9 00 00 00       	jmp    80074c <vprintfmt+0x3bb>
	else if (lflag)
  8006a3:	85 c9                	test   %ecx,%ecx
  8006a5:	75 1a                	jne    8006c1 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  8006a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006aa:	8b 10                	mov    (%eax),%edx
  8006ac:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b1:	8d 40 04             	lea    0x4(%eax),%eax
  8006b4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006b7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006bc:	e9 8b 00 00 00       	jmp    80074c <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8006c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c4:	8b 10                	mov    (%eax),%edx
  8006c6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006cb:	8d 40 04             	lea    0x4(%eax),%eax
  8006ce:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006d1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006d6:	eb 74                	jmp    80074c <vprintfmt+0x3bb>
	if (lflag >= 2)
  8006d8:	83 f9 01             	cmp    $0x1,%ecx
  8006db:	7e 15                	jle    8006f2 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  8006dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e0:	8b 10                	mov    (%eax),%edx
  8006e2:	8b 48 04             	mov    0x4(%eax),%ecx
  8006e5:	8d 40 08             	lea    0x8(%eax),%eax
  8006e8:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8006eb:	b8 08 00 00 00       	mov    $0x8,%eax
  8006f0:	eb 5a                	jmp    80074c <vprintfmt+0x3bb>
	else if (lflag)
  8006f2:	85 c9                	test   %ecx,%ecx
  8006f4:	75 17                	jne    80070d <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  8006f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f9:	8b 10                	mov    (%eax),%edx
  8006fb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800700:	8d 40 04             	lea    0x4(%eax),%eax
  800703:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800706:	b8 08 00 00 00       	mov    $0x8,%eax
  80070b:	eb 3f                	jmp    80074c <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80070d:	8b 45 14             	mov    0x14(%ebp),%eax
  800710:	8b 10                	mov    (%eax),%edx
  800712:	b9 00 00 00 00       	mov    $0x0,%ecx
  800717:	8d 40 04             	lea    0x4(%eax),%eax
  80071a:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80071d:	b8 08 00 00 00       	mov    $0x8,%eax
  800722:	eb 28                	jmp    80074c <vprintfmt+0x3bb>
			putch('0', putdat);
  800724:	83 ec 08             	sub    $0x8,%esp
  800727:	53                   	push   %ebx
  800728:	6a 30                	push   $0x30
  80072a:	ff d6                	call   *%esi
			putch('x', putdat);
  80072c:	83 c4 08             	add    $0x8,%esp
  80072f:	53                   	push   %ebx
  800730:	6a 78                	push   $0x78
  800732:	ff d6                	call   *%esi
			num = (unsigned long long)
  800734:	8b 45 14             	mov    0x14(%ebp),%eax
  800737:	8b 10                	mov    (%eax),%edx
  800739:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80073e:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800741:	8d 40 04             	lea    0x4(%eax),%eax
  800744:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800747:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80074c:	83 ec 0c             	sub    $0xc,%esp
  80074f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800753:	57                   	push   %edi
  800754:	ff 75 e0             	pushl  -0x20(%ebp)
  800757:	50                   	push   %eax
  800758:	51                   	push   %ecx
  800759:	52                   	push   %edx
  80075a:	89 da                	mov    %ebx,%edx
  80075c:	89 f0                	mov    %esi,%eax
  80075e:	e8 45 fb ff ff       	call   8002a8 <printnum>
			break;
  800763:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800766:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800769:	83 c7 01             	add    $0x1,%edi
  80076c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800770:	83 f8 25             	cmp    $0x25,%eax
  800773:	0f 84 2f fc ff ff    	je     8003a8 <vprintfmt+0x17>
			if (ch == '\0')
  800779:	85 c0                	test   %eax,%eax
  80077b:	0f 84 8b 00 00 00    	je     80080c <vprintfmt+0x47b>
			putch(ch, putdat);
  800781:	83 ec 08             	sub    $0x8,%esp
  800784:	53                   	push   %ebx
  800785:	50                   	push   %eax
  800786:	ff d6                	call   *%esi
  800788:	83 c4 10             	add    $0x10,%esp
  80078b:	eb dc                	jmp    800769 <vprintfmt+0x3d8>
	if (lflag >= 2)
  80078d:	83 f9 01             	cmp    $0x1,%ecx
  800790:	7e 15                	jle    8007a7 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  800792:	8b 45 14             	mov    0x14(%ebp),%eax
  800795:	8b 10                	mov    (%eax),%edx
  800797:	8b 48 04             	mov    0x4(%eax),%ecx
  80079a:	8d 40 08             	lea    0x8(%eax),%eax
  80079d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007a0:	b8 10 00 00 00       	mov    $0x10,%eax
  8007a5:	eb a5                	jmp    80074c <vprintfmt+0x3bb>
	else if (lflag)
  8007a7:	85 c9                	test   %ecx,%ecx
  8007a9:	75 17                	jne    8007c2 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  8007ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ae:	8b 10                	mov    (%eax),%edx
  8007b0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007b5:	8d 40 04             	lea    0x4(%eax),%eax
  8007b8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007bb:	b8 10 00 00 00       	mov    $0x10,%eax
  8007c0:	eb 8a                	jmp    80074c <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8007c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c5:	8b 10                	mov    (%eax),%edx
  8007c7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007cc:	8d 40 04             	lea    0x4(%eax),%eax
  8007cf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007d2:	b8 10 00 00 00       	mov    $0x10,%eax
  8007d7:	e9 70 ff ff ff       	jmp    80074c <vprintfmt+0x3bb>
			putch(ch, putdat);
  8007dc:	83 ec 08             	sub    $0x8,%esp
  8007df:	53                   	push   %ebx
  8007e0:	6a 25                	push   $0x25
  8007e2:	ff d6                	call   *%esi
			break;
  8007e4:	83 c4 10             	add    $0x10,%esp
  8007e7:	e9 7a ff ff ff       	jmp    800766 <vprintfmt+0x3d5>
			putch('%', putdat);
  8007ec:	83 ec 08             	sub    $0x8,%esp
  8007ef:	53                   	push   %ebx
  8007f0:	6a 25                	push   $0x25
  8007f2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007f4:	83 c4 10             	add    $0x10,%esp
  8007f7:	89 f8                	mov    %edi,%eax
  8007f9:	eb 03                	jmp    8007fe <vprintfmt+0x46d>
  8007fb:	83 e8 01             	sub    $0x1,%eax
  8007fe:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800802:	75 f7                	jne    8007fb <vprintfmt+0x46a>
  800804:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800807:	e9 5a ff ff ff       	jmp    800766 <vprintfmt+0x3d5>
}
  80080c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80080f:	5b                   	pop    %ebx
  800810:	5e                   	pop    %esi
  800811:	5f                   	pop    %edi
  800812:	5d                   	pop    %ebp
  800813:	c3                   	ret    

00800814 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800814:	55                   	push   %ebp
  800815:	89 e5                	mov    %esp,%ebp
  800817:	83 ec 18             	sub    $0x18,%esp
  80081a:	8b 45 08             	mov    0x8(%ebp),%eax
  80081d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800820:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800823:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800827:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80082a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800831:	85 c0                	test   %eax,%eax
  800833:	74 26                	je     80085b <vsnprintf+0x47>
  800835:	85 d2                	test   %edx,%edx
  800837:	7e 22                	jle    80085b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800839:	ff 75 14             	pushl  0x14(%ebp)
  80083c:	ff 75 10             	pushl  0x10(%ebp)
  80083f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800842:	50                   	push   %eax
  800843:	68 57 03 80 00       	push   $0x800357
  800848:	e8 44 fb ff ff       	call   800391 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80084d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800850:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800853:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800856:	83 c4 10             	add    $0x10,%esp
}
  800859:	c9                   	leave  
  80085a:	c3                   	ret    
		return -E_INVAL;
  80085b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800860:	eb f7                	jmp    800859 <vsnprintf+0x45>

00800862 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800868:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80086b:	50                   	push   %eax
  80086c:	ff 75 10             	pushl  0x10(%ebp)
  80086f:	ff 75 0c             	pushl  0xc(%ebp)
  800872:	ff 75 08             	pushl  0x8(%ebp)
  800875:	e8 9a ff ff ff       	call   800814 <vsnprintf>
	va_end(ap);

	return rc;
}
  80087a:	c9                   	leave  
  80087b:	c3                   	ret    

0080087c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800882:	b8 00 00 00 00       	mov    $0x0,%eax
  800887:	eb 03                	jmp    80088c <strlen+0x10>
		n++;
  800889:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80088c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800890:	75 f7                	jne    800889 <strlen+0xd>
	return n;
}
  800892:	5d                   	pop    %ebp
  800893:	c3                   	ret    

00800894 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80089a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80089d:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a2:	eb 03                	jmp    8008a7 <strnlen+0x13>
		n++;
  8008a4:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008a7:	39 d0                	cmp    %edx,%eax
  8008a9:	74 06                	je     8008b1 <strnlen+0x1d>
  8008ab:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008af:	75 f3                	jne    8008a4 <strnlen+0x10>
	return n;
}
  8008b1:	5d                   	pop    %ebp
  8008b2:	c3                   	ret    

008008b3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008b3:	55                   	push   %ebp
  8008b4:	89 e5                	mov    %esp,%ebp
  8008b6:	53                   	push   %ebx
  8008b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008bd:	89 c2                	mov    %eax,%edx
  8008bf:	83 c1 01             	add    $0x1,%ecx
  8008c2:	83 c2 01             	add    $0x1,%edx
  8008c5:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008c9:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008cc:	84 db                	test   %bl,%bl
  8008ce:	75 ef                	jne    8008bf <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008d0:	5b                   	pop    %ebx
  8008d1:	5d                   	pop    %ebp
  8008d2:	c3                   	ret    

008008d3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008d3:	55                   	push   %ebp
  8008d4:	89 e5                	mov    %esp,%ebp
  8008d6:	53                   	push   %ebx
  8008d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008da:	53                   	push   %ebx
  8008db:	e8 9c ff ff ff       	call   80087c <strlen>
  8008e0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008e3:	ff 75 0c             	pushl  0xc(%ebp)
  8008e6:	01 d8                	add    %ebx,%eax
  8008e8:	50                   	push   %eax
  8008e9:	e8 c5 ff ff ff       	call   8008b3 <strcpy>
	return dst;
}
  8008ee:	89 d8                	mov    %ebx,%eax
  8008f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008f3:	c9                   	leave  
  8008f4:	c3                   	ret    

008008f5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	56                   	push   %esi
  8008f9:	53                   	push   %ebx
  8008fa:	8b 75 08             	mov    0x8(%ebp),%esi
  8008fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800900:	89 f3                	mov    %esi,%ebx
  800902:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800905:	89 f2                	mov    %esi,%edx
  800907:	eb 0f                	jmp    800918 <strncpy+0x23>
		*dst++ = *src;
  800909:	83 c2 01             	add    $0x1,%edx
  80090c:	0f b6 01             	movzbl (%ecx),%eax
  80090f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800912:	80 39 01             	cmpb   $0x1,(%ecx)
  800915:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800918:	39 da                	cmp    %ebx,%edx
  80091a:	75 ed                	jne    800909 <strncpy+0x14>
	}
	return ret;
}
  80091c:	89 f0                	mov    %esi,%eax
  80091e:	5b                   	pop    %ebx
  80091f:	5e                   	pop    %esi
  800920:	5d                   	pop    %ebp
  800921:	c3                   	ret    

00800922 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	56                   	push   %esi
  800926:	53                   	push   %ebx
  800927:	8b 75 08             	mov    0x8(%ebp),%esi
  80092a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800930:	89 f0                	mov    %esi,%eax
  800932:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800936:	85 c9                	test   %ecx,%ecx
  800938:	75 0b                	jne    800945 <strlcpy+0x23>
  80093a:	eb 17                	jmp    800953 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80093c:	83 c2 01             	add    $0x1,%edx
  80093f:	83 c0 01             	add    $0x1,%eax
  800942:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800945:	39 d8                	cmp    %ebx,%eax
  800947:	74 07                	je     800950 <strlcpy+0x2e>
  800949:	0f b6 0a             	movzbl (%edx),%ecx
  80094c:	84 c9                	test   %cl,%cl
  80094e:	75 ec                	jne    80093c <strlcpy+0x1a>
		*dst = '\0';
  800950:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800953:	29 f0                	sub    %esi,%eax
}
  800955:	5b                   	pop    %ebx
  800956:	5e                   	pop    %esi
  800957:	5d                   	pop    %ebp
  800958:	c3                   	ret    

00800959 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800959:	55                   	push   %ebp
  80095a:	89 e5                	mov    %esp,%ebp
  80095c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80095f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800962:	eb 06                	jmp    80096a <strcmp+0x11>
		p++, q++;
  800964:	83 c1 01             	add    $0x1,%ecx
  800967:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80096a:	0f b6 01             	movzbl (%ecx),%eax
  80096d:	84 c0                	test   %al,%al
  80096f:	74 04                	je     800975 <strcmp+0x1c>
  800971:	3a 02                	cmp    (%edx),%al
  800973:	74 ef                	je     800964 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800975:	0f b6 c0             	movzbl %al,%eax
  800978:	0f b6 12             	movzbl (%edx),%edx
  80097b:	29 d0                	sub    %edx,%eax
}
  80097d:	5d                   	pop    %ebp
  80097e:	c3                   	ret    

0080097f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	53                   	push   %ebx
  800983:	8b 45 08             	mov    0x8(%ebp),%eax
  800986:	8b 55 0c             	mov    0xc(%ebp),%edx
  800989:	89 c3                	mov    %eax,%ebx
  80098b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80098e:	eb 06                	jmp    800996 <strncmp+0x17>
		n--, p++, q++;
  800990:	83 c0 01             	add    $0x1,%eax
  800993:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800996:	39 d8                	cmp    %ebx,%eax
  800998:	74 16                	je     8009b0 <strncmp+0x31>
  80099a:	0f b6 08             	movzbl (%eax),%ecx
  80099d:	84 c9                	test   %cl,%cl
  80099f:	74 04                	je     8009a5 <strncmp+0x26>
  8009a1:	3a 0a                	cmp    (%edx),%cl
  8009a3:	74 eb                	je     800990 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a5:	0f b6 00             	movzbl (%eax),%eax
  8009a8:	0f b6 12             	movzbl (%edx),%edx
  8009ab:	29 d0                	sub    %edx,%eax
}
  8009ad:	5b                   	pop    %ebx
  8009ae:	5d                   	pop    %ebp
  8009af:	c3                   	ret    
		return 0;
  8009b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b5:	eb f6                	jmp    8009ad <strncmp+0x2e>

008009b7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c1:	0f b6 10             	movzbl (%eax),%edx
  8009c4:	84 d2                	test   %dl,%dl
  8009c6:	74 09                	je     8009d1 <strchr+0x1a>
		if (*s == c)
  8009c8:	38 ca                	cmp    %cl,%dl
  8009ca:	74 0a                	je     8009d6 <strchr+0x1f>
	for (; *s; s++)
  8009cc:	83 c0 01             	add    $0x1,%eax
  8009cf:	eb f0                	jmp    8009c1 <strchr+0xa>
			return (char *) s;
	return 0;
  8009d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d6:	5d                   	pop    %ebp
  8009d7:	c3                   	ret    

008009d8 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009d8:	55                   	push   %ebp
  8009d9:	89 e5                	mov    %esp,%ebp
  8009db:	8b 45 08             	mov    0x8(%ebp),%eax
  8009de:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009e2:	eb 03                	jmp    8009e7 <strfind+0xf>
  8009e4:	83 c0 01             	add    $0x1,%eax
  8009e7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009ea:	38 ca                	cmp    %cl,%dl
  8009ec:	74 04                	je     8009f2 <strfind+0x1a>
  8009ee:	84 d2                	test   %dl,%dl
  8009f0:	75 f2                	jne    8009e4 <strfind+0xc>
			break;
	return (char *) s;
}
  8009f2:	5d                   	pop    %ebp
  8009f3:	c3                   	ret    

008009f4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009f4:	55                   	push   %ebp
  8009f5:	89 e5                	mov    %esp,%ebp
  8009f7:	57                   	push   %edi
  8009f8:	56                   	push   %esi
  8009f9:	53                   	push   %ebx
  8009fa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009fd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a00:	85 c9                	test   %ecx,%ecx
  800a02:	74 13                	je     800a17 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a04:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a0a:	75 05                	jne    800a11 <memset+0x1d>
  800a0c:	f6 c1 03             	test   $0x3,%cl
  800a0f:	74 0d                	je     800a1e <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a11:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a14:	fc                   	cld    
  800a15:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a17:	89 f8                	mov    %edi,%eax
  800a19:	5b                   	pop    %ebx
  800a1a:	5e                   	pop    %esi
  800a1b:	5f                   	pop    %edi
  800a1c:	5d                   	pop    %ebp
  800a1d:	c3                   	ret    
		c &= 0xFF;
  800a1e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a22:	89 d3                	mov    %edx,%ebx
  800a24:	c1 e3 08             	shl    $0x8,%ebx
  800a27:	89 d0                	mov    %edx,%eax
  800a29:	c1 e0 18             	shl    $0x18,%eax
  800a2c:	89 d6                	mov    %edx,%esi
  800a2e:	c1 e6 10             	shl    $0x10,%esi
  800a31:	09 f0                	or     %esi,%eax
  800a33:	09 c2                	or     %eax,%edx
  800a35:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800a37:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a3a:	89 d0                	mov    %edx,%eax
  800a3c:	fc                   	cld    
  800a3d:	f3 ab                	rep stos %eax,%es:(%edi)
  800a3f:	eb d6                	jmp    800a17 <memset+0x23>

00800a41 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	57                   	push   %edi
  800a45:	56                   	push   %esi
  800a46:	8b 45 08             	mov    0x8(%ebp),%eax
  800a49:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a4c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a4f:	39 c6                	cmp    %eax,%esi
  800a51:	73 35                	jae    800a88 <memmove+0x47>
  800a53:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a56:	39 c2                	cmp    %eax,%edx
  800a58:	76 2e                	jbe    800a88 <memmove+0x47>
		s += n;
		d += n;
  800a5a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a5d:	89 d6                	mov    %edx,%esi
  800a5f:	09 fe                	or     %edi,%esi
  800a61:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a67:	74 0c                	je     800a75 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a69:	83 ef 01             	sub    $0x1,%edi
  800a6c:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a6f:	fd                   	std    
  800a70:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a72:	fc                   	cld    
  800a73:	eb 21                	jmp    800a96 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a75:	f6 c1 03             	test   $0x3,%cl
  800a78:	75 ef                	jne    800a69 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a7a:	83 ef 04             	sub    $0x4,%edi
  800a7d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a80:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a83:	fd                   	std    
  800a84:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a86:	eb ea                	jmp    800a72 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a88:	89 f2                	mov    %esi,%edx
  800a8a:	09 c2                	or     %eax,%edx
  800a8c:	f6 c2 03             	test   $0x3,%dl
  800a8f:	74 09                	je     800a9a <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a91:	89 c7                	mov    %eax,%edi
  800a93:	fc                   	cld    
  800a94:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a96:	5e                   	pop    %esi
  800a97:	5f                   	pop    %edi
  800a98:	5d                   	pop    %ebp
  800a99:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a9a:	f6 c1 03             	test   $0x3,%cl
  800a9d:	75 f2                	jne    800a91 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a9f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800aa2:	89 c7                	mov    %eax,%edi
  800aa4:	fc                   	cld    
  800aa5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa7:	eb ed                	jmp    800a96 <memmove+0x55>

00800aa9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aa9:	55                   	push   %ebp
  800aaa:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800aac:	ff 75 10             	pushl  0x10(%ebp)
  800aaf:	ff 75 0c             	pushl  0xc(%ebp)
  800ab2:	ff 75 08             	pushl  0x8(%ebp)
  800ab5:	e8 87 ff ff ff       	call   800a41 <memmove>
}
  800aba:	c9                   	leave  
  800abb:	c3                   	ret    

00800abc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	56                   	push   %esi
  800ac0:	53                   	push   %ebx
  800ac1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ac7:	89 c6                	mov    %eax,%esi
  800ac9:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800acc:	39 f0                	cmp    %esi,%eax
  800ace:	74 1c                	je     800aec <memcmp+0x30>
		if (*s1 != *s2)
  800ad0:	0f b6 08             	movzbl (%eax),%ecx
  800ad3:	0f b6 1a             	movzbl (%edx),%ebx
  800ad6:	38 d9                	cmp    %bl,%cl
  800ad8:	75 08                	jne    800ae2 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ada:	83 c0 01             	add    $0x1,%eax
  800add:	83 c2 01             	add    $0x1,%edx
  800ae0:	eb ea                	jmp    800acc <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800ae2:	0f b6 c1             	movzbl %cl,%eax
  800ae5:	0f b6 db             	movzbl %bl,%ebx
  800ae8:	29 d8                	sub    %ebx,%eax
  800aea:	eb 05                	jmp    800af1 <memcmp+0x35>
	}

	return 0;
  800aec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af1:	5b                   	pop    %ebx
  800af2:	5e                   	pop    %esi
  800af3:	5d                   	pop    %ebp
  800af4:	c3                   	ret    

00800af5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800af5:	55                   	push   %ebp
  800af6:	89 e5                	mov    %esp,%ebp
  800af8:	8b 45 08             	mov    0x8(%ebp),%eax
  800afb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800afe:	89 c2                	mov    %eax,%edx
  800b00:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b03:	39 d0                	cmp    %edx,%eax
  800b05:	73 09                	jae    800b10 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b07:	38 08                	cmp    %cl,(%eax)
  800b09:	74 05                	je     800b10 <memfind+0x1b>
	for (; s < ends; s++)
  800b0b:	83 c0 01             	add    $0x1,%eax
  800b0e:	eb f3                	jmp    800b03 <memfind+0xe>
			break;
	return (void *) s;
}
  800b10:	5d                   	pop    %ebp
  800b11:	c3                   	ret    

00800b12 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b12:	55                   	push   %ebp
  800b13:	89 e5                	mov    %esp,%ebp
  800b15:	57                   	push   %edi
  800b16:	56                   	push   %esi
  800b17:	53                   	push   %ebx
  800b18:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b1e:	eb 03                	jmp    800b23 <strtol+0x11>
		s++;
  800b20:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b23:	0f b6 01             	movzbl (%ecx),%eax
  800b26:	3c 20                	cmp    $0x20,%al
  800b28:	74 f6                	je     800b20 <strtol+0xe>
  800b2a:	3c 09                	cmp    $0x9,%al
  800b2c:	74 f2                	je     800b20 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b2e:	3c 2b                	cmp    $0x2b,%al
  800b30:	74 2e                	je     800b60 <strtol+0x4e>
	int neg = 0;
  800b32:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b37:	3c 2d                	cmp    $0x2d,%al
  800b39:	74 2f                	je     800b6a <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b3b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b41:	75 05                	jne    800b48 <strtol+0x36>
  800b43:	80 39 30             	cmpb   $0x30,(%ecx)
  800b46:	74 2c                	je     800b74 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b48:	85 db                	test   %ebx,%ebx
  800b4a:	75 0a                	jne    800b56 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b4c:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800b51:	80 39 30             	cmpb   $0x30,(%ecx)
  800b54:	74 28                	je     800b7e <strtol+0x6c>
		base = 10;
  800b56:	b8 00 00 00 00       	mov    $0x0,%eax
  800b5b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b5e:	eb 50                	jmp    800bb0 <strtol+0x9e>
		s++;
  800b60:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b63:	bf 00 00 00 00       	mov    $0x0,%edi
  800b68:	eb d1                	jmp    800b3b <strtol+0x29>
		s++, neg = 1;
  800b6a:	83 c1 01             	add    $0x1,%ecx
  800b6d:	bf 01 00 00 00       	mov    $0x1,%edi
  800b72:	eb c7                	jmp    800b3b <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b74:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b78:	74 0e                	je     800b88 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b7a:	85 db                	test   %ebx,%ebx
  800b7c:	75 d8                	jne    800b56 <strtol+0x44>
		s++, base = 8;
  800b7e:	83 c1 01             	add    $0x1,%ecx
  800b81:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b86:	eb ce                	jmp    800b56 <strtol+0x44>
		s += 2, base = 16;
  800b88:	83 c1 02             	add    $0x2,%ecx
  800b8b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b90:	eb c4                	jmp    800b56 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800b92:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b95:	89 f3                	mov    %esi,%ebx
  800b97:	80 fb 19             	cmp    $0x19,%bl
  800b9a:	77 29                	ja     800bc5 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b9c:	0f be d2             	movsbl %dl,%edx
  800b9f:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ba2:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ba5:	7d 30                	jge    800bd7 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ba7:	83 c1 01             	add    $0x1,%ecx
  800baa:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bae:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800bb0:	0f b6 11             	movzbl (%ecx),%edx
  800bb3:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bb6:	89 f3                	mov    %esi,%ebx
  800bb8:	80 fb 09             	cmp    $0x9,%bl
  800bbb:	77 d5                	ja     800b92 <strtol+0x80>
			dig = *s - '0';
  800bbd:	0f be d2             	movsbl %dl,%edx
  800bc0:	83 ea 30             	sub    $0x30,%edx
  800bc3:	eb dd                	jmp    800ba2 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800bc5:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bc8:	89 f3                	mov    %esi,%ebx
  800bca:	80 fb 19             	cmp    $0x19,%bl
  800bcd:	77 08                	ja     800bd7 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800bcf:	0f be d2             	movsbl %dl,%edx
  800bd2:	83 ea 37             	sub    $0x37,%edx
  800bd5:	eb cb                	jmp    800ba2 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bd7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bdb:	74 05                	je     800be2 <strtol+0xd0>
		*endptr = (char *) s;
  800bdd:	8b 75 0c             	mov    0xc(%ebp),%esi
  800be0:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800be2:	89 c2                	mov    %eax,%edx
  800be4:	f7 da                	neg    %edx
  800be6:	85 ff                	test   %edi,%edi
  800be8:	0f 45 c2             	cmovne %edx,%eax
}
  800beb:	5b                   	pop    %ebx
  800bec:	5e                   	pop    %esi
  800bed:	5f                   	pop    %edi
  800bee:	5d                   	pop    %ebp
  800bef:	c3                   	ret    

00800bf0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bf0:	55                   	push   %ebp
  800bf1:	89 e5                	mov    %esp,%ebp
  800bf3:	57                   	push   %edi
  800bf4:	56                   	push   %esi
  800bf5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bf6:	b8 00 00 00 00       	mov    $0x0,%eax
  800bfb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c01:	89 c3                	mov    %eax,%ebx
  800c03:	89 c7                	mov    %eax,%edi
  800c05:	89 c6                	mov    %eax,%esi
  800c07:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c09:	5b                   	pop    %ebx
  800c0a:	5e                   	pop    %esi
  800c0b:	5f                   	pop    %edi
  800c0c:	5d                   	pop    %ebp
  800c0d:	c3                   	ret    

00800c0e <sys_cgetc>:

int
sys_cgetc(void)
{
  800c0e:	55                   	push   %ebp
  800c0f:	89 e5                	mov    %esp,%ebp
  800c11:	57                   	push   %edi
  800c12:	56                   	push   %esi
  800c13:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c14:	ba 00 00 00 00       	mov    $0x0,%edx
  800c19:	b8 01 00 00 00       	mov    $0x1,%eax
  800c1e:	89 d1                	mov    %edx,%ecx
  800c20:	89 d3                	mov    %edx,%ebx
  800c22:	89 d7                	mov    %edx,%edi
  800c24:	89 d6                	mov    %edx,%esi
  800c26:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c28:	5b                   	pop    %ebx
  800c29:	5e                   	pop    %esi
  800c2a:	5f                   	pop    %edi
  800c2b:	5d                   	pop    %ebp
  800c2c:	c3                   	ret    

00800c2d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c2d:	55                   	push   %ebp
  800c2e:	89 e5                	mov    %esp,%ebp
  800c30:	57                   	push   %edi
  800c31:	56                   	push   %esi
  800c32:	53                   	push   %ebx
  800c33:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c36:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3e:	b8 03 00 00 00       	mov    $0x3,%eax
  800c43:	89 cb                	mov    %ecx,%ebx
  800c45:	89 cf                	mov    %ecx,%edi
  800c47:	89 ce                	mov    %ecx,%esi
  800c49:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c4b:	85 c0                	test   %eax,%eax
  800c4d:	7f 08                	jg     800c57 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c52:	5b                   	pop    %ebx
  800c53:	5e                   	pop    %esi
  800c54:	5f                   	pop    %edi
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c57:	83 ec 0c             	sub    $0xc,%esp
  800c5a:	50                   	push   %eax
  800c5b:	6a 03                	push   $0x3
  800c5d:	68 3f 26 80 00       	push   $0x80263f
  800c62:	6a 23                	push   $0x23
  800c64:	68 5c 26 80 00       	push   $0x80265c
  800c69:	e8 c3 12 00 00       	call   801f31 <_panic>

00800c6e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c6e:	55                   	push   %ebp
  800c6f:	89 e5                	mov    %esp,%ebp
  800c71:	57                   	push   %edi
  800c72:	56                   	push   %esi
  800c73:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c74:	ba 00 00 00 00       	mov    $0x0,%edx
  800c79:	b8 02 00 00 00       	mov    $0x2,%eax
  800c7e:	89 d1                	mov    %edx,%ecx
  800c80:	89 d3                	mov    %edx,%ebx
  800c82:	89 d7                	mov    %edx,%edi
  800c84:	89 d6                	mov    %edx,%esi
  800c86:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c88:	5b                   	pop    %ebx
  800c89:	5e                   	pop    %esi
  800c8a:	5f                   	pop    %edi
  800c8b:	5d                   	pop    %ebp
  800c8c:	c3                   	ret    

00800c8d <sys_yield>:

void
sys_yield(void)
{
  800c8d:	55                   	push   %ebp
  800c8e:	89 e5                	mov    %esp,%ebp
  800c90:	57                   	push   %edi
  800c91:	56                   	push   %esi
  800c92:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c93:	ba 00 00 00 00       	mov    $0x0,%edx
  800c98:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c9d:	89 d1                	mov    %edx,%ecx
  800c9f:	89 d3                	mov    %edx,%ebx
  800ca1:	89 d7                	mov    %edx,%edi
  800ca3:	89 d6                	mov    %edx,%esi
  800ca5:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ca7:	5b                   	pop    %ebx
  800ca8:	5e                   	pop    %esi
  800ca9:	5f                   	pop    %edi
  800caa:	5d                   	pop    %ebp
  800cab:	c3                   	ret    

00800cac <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cac:	55                   	push   %ebp
  800cad:	89 e5                	mov    %esp,%ebp
  800caf:	57                   	push   %edi
  800cb0:	56                   	push   %esi
  800cb1:	53                   	push   %ebx
  800cb2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cb5:	be 00 00 00 00       	mov    $0x0,%esi
  800cba:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc0:	b8 04 00 00 00       	mov    $0x4,%eax
  800cc5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc8:	89 f7                	mov    %esi,%edi
  800cca:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ccc:	85 c0                	test   %eax,%eax
  800cce:	7f 08                	jg     800cd8 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd3:	5b                   	pop    %ebx
  800cd4:	5e                   	pop    %esi
  800cd5:	5f                   	pop    %edi
  800cd6:	5d                   	pop    %ebp
  800cd7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd8:	83 ec 0c             	sub    $0xc,%esp
  800cdb:	50                   	push   %eax
  800cdc:	6a 04                	push   $0x4
  800cde:	68 3f 26 80 00       	push   $0x80263f
  800ce3:	6a 23                	push   $0x23
  800ce5:	68 5c 26 80 00       	push   $0x80265c
  800cea:	e8 42 12 00 00       	call   801f31 <_panic>

00800cef <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cef:	55                   	push   %ebp
  800cf0:	89 e5                	mov    %esp,%ebp
  800cf2:	57                   	push   %edi
  800cf3:	56                   	push   %esi
  800cf4:	53                   	push   %ebx
  800cf5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfe:	b8 05 00 00 00       	mov    $0x5,%eax
  800d03:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d06:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d09:	8b 75 18             	mov    0x18(%ebp),%esi
  800d0c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d0e:	85 c0                	test   %eax,%eax
  800d10:	7f 08                	jg     800d1a <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d15:	5b                   	pop    %ebx
  800d16:	5e                   	pop    %esi
  800d17:	5f                   	pop    %edi
  800d18:	5d                   	pop    %ebp
  800d19:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1a:	83 ec 0c             	sub    $0xc,%esp
  800d1d:	50                   	push   %eax
  800d1e:	6a 05                	push   $0x5
  800d20:	68 3f 26 80 00       	push   $0x80263f
  800d25:	6a 23                	push   $0x23
  800d27:	68 5c 26 80 00       	push   $0x80265c
  800d2c:	e8 00 12 00 00       	call   801f31 <_panic>

00800d31 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d31:	55                   	push   %ebp
  800d32:	89 e5                	mov    %esp,%ebp
  800d34:	57                   	push   %edi
  800d35:	56                   	push   %esi
  800d36:	53                   	push   %ebx
  800d37:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d3a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d45:	b8 06 00 00 00       	mov    $0x6,%eax
  800d4a:	89 df                	mov    %ebx,%edi
  800d4c:	89 de                	mov    %ebx,%esi
  800d4e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d50:	85 c0                	test   %eax,%eax
  800d52:	7f 08                	jg     800d5c <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d57:	5b                   	pop    %ebx
  800d58:	5e                   	pop    %esi
  800d59:	5f                   	pop    %edi
  800d5a:	5d                   	pop    %ebp
  800d5b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5c:	83 ec 0c             	sub    $0xc,%esp
  800d5f:	50                   	push   %eax
  800d60:	6a 06                	push   $0x6
  800d62:	68 3f 26 80 00       	push   $0x80263f
  800d67:	6a 23                	push   $0x23
  800d69:	68 5c 26 80 00       	push   $0x80265c
  800d6e:	e8 be 11 00 00       	call   801f31 <_panic>

00800d73 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
  800d76:	57                   	push   %edi
  800d77:	56                   	push   %esi
  800d78:	53                   	push   %ebx
  800d79:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d7c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d81:	8b 55 08             	mov    0x8(%ebp),%edx
  800d84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d87:	b8 08 00 00 00       	mov    $0x8,%eax
  800d8c:	89 df                	mov    %ebx,%edi
  800d8e:	89 de                	mov    %ebx,%esi
  800d90:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d92:	85 c0                	test   %eax,%eax
  800d94:	7f 08                	jg     800d9e <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d99:	5b                   	pop    %ebx
  800d9a:	5e                   	pop    %esi
  800d9b:	5f                   	pop    %edi
  800d9c:	5d                   	pop    %ebp
  800d9d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9e:	83 ec 0c             	sub    $0xc,%esp
  800da1:	50                   	push   %eax
  800da2:	6a 08                	push   $0x8
  800da4:	68 3f 26 80 00       	push   $0x80263f
  800da9:	6a 23                	push   $0x23
  800dab:	68 5c 26 80 00       	push   $0x80265c
  800db0:	e8 7c 11 00 00       	call   801f31 <_panic>

00800db5 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800db5:	55                   	push   %ebp
  800db6:	89 e5                	mov    %esp,%ebp
  800db8:	57                   	push   %edi
  800db9:	56                   	push   %esi
  800dba:	53                   	push   %ebx
  800dbb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dbe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc9:	b8 09 00 00 00       	mov    $0x9,%eax
  800dce:	89 df                	mov    %ebx,%edi
  800dd0:	89 de                	mov    %ebx,%esi
  800dd2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dd4:	85 c0                	test   %eax,%eax
  800dd6:	7f 08                	jg     800de0 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ddb:	5b                   	pop    %ebx
  800ddc:	5e                   	pop    %esi
  800ddd:	5f                   	pop    %edi
  800dde:	5d                   	pop    %ebp
  800ddf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800de0:	83 ec 0c             	sub    $0xc,%esp
  800de3:	50                   	push   %eax
  800de4:	6a 09                	push   $0x9
  800de6:	68 3f 26 80 00       	push   $0x80263f
  800deb:	6a 23                	push   $0x23
  800ded:	68 5c 26 80 00       	push   $0x80265c
  800df2:	e8 3a 11 00 00       	call   801f31 <_panic>

00800df7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800df7:	55                   	push   %ebp
  800df8:	89 e5                	mov    %esp,%ebp
  800dfa:	57                   	push   %edi
  800dfb:	56                   	push   %esi
  800dfc:	53                   	push   %ebx
  800dfd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e00:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e05:	8b 55 08             	mov    0x8(%ebp),%edx
  800e08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e10:	89 df                	mov    %ebx,%edi
  800e12:	89 de                	mov    %ebx,%esi
  800e14:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e16:	85 c0                	test   %eax,%eax
  800e18:	7f 08                	jg     800e22 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1d:	5b                   	pop    %ebx
  800e1e:	5e                   	pop    %esi
  800e1f:	5f                   	pop    %edi
  800e20:	5d                   	pop    %ebp
  800e21:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e22:	83 ec 0c             	sub    $0xc,%esp
  800e25:	50                   	push   %eax
  800e26:	6a 0a                	push   $0xa
  800e28:	68 3f 26 80 00       	push   $0x80263f
  800e2d:	6a 23                	push   $0x23
  800e2f:	68 5c 26 80 00       	push   $0x80265c
  800e34:	e8 f8 10 00 00       	call   801f31 <_panic>

00800e39 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e39:	55                   	push   %ebp
  800e3a:	89 e5                	mov    %esp,%ebp
  800e3c:	57                   	push   %edi
  800e3d:	56                   	push   %esi
  800e3e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e45:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e4a:	be 00 00 00 00       	mov    $0x0,%esi
  800e4f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e52:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e55:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e57:	5b                   	pop    %ebx
  800e58:	5e                   	pop    %esi
  800e59:	5f                   	pop    %edi
  800e5a:	5d                   	pop    %ebp
  800e5b:	c3                   	ret    

00800e5c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e5c:	55                   	push   %ebp
  800e5d:	89 e5                	mov    %esp,%ebp
  800e5f:	57                   	push   %edi
  800e60:	56                   	push   %esi
  800e61:	53                   	push   %ebx
  800e62:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e65:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e72:	89 cb                	mov    %ecx,%ebx
  800e74:	89 cf                	mov    %ecx,%edi
  800e76:	89 ce                	mov    %ecx,%esi
  800e78:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e7a:	85 c0                	test   %eax,%eax
  800e7c:	7f 08                	jg     800e86 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e81:	5b                   	pop    %ebx
  800e82:	5e                   	pop    %esi
  800e83:	5f                   	pop    %edi
  800e84:	5d                   	pop    %ebp
  800e85:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e86:	83 ec 0c             	sub    $0xc,%esp
  800e89:	50                   	push   %eax
  800e8a:	6a 0d                	push   $0xd
  800e8c:	68 3f 26 80 00       	push   $0x80263f
  800e91:	6a 23                	push   $0x23
  800e93:	68 5c 26 80 00       	push   $0x80265c
  800e98:	e8 94 10 00 00       	call   801f31 <_panic>

00800e9d <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e9d:	55                   	push   %ebp
  800e9e:	89 e5                	mov    %esp,%ebp
  800ea0:	53                   	push   %ebx
  800ea1:	83 ec 04             	sub    $0x4,%esp
  800ea4:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800ea7:	8b 02                	mov    (%edx),%eax
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800ea9:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800ead:	0f 84 9c 00 00 00    	je     800f4f <pgfault+0xb2>
  800eb3:	89 c2                	mov    %eax,%edx
  800eb5:	c1 ea 16             	shr    $0x16,%edx
  800eb8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ebf:	f6 c2 01             	test   $0x1,%dl
  800ec2:	0f 84 87 00 00 00    	je     800f4f <pgfault+0xb2>
  800ec8:	89 c2                	mov    %eax,%edx
  800eca:	c1 ea 0c             	shr    $0xc,%edx
  800ecd:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800ed4:	f6 c1 01             	test   $0x1,%cl
  800ed7:	74 76                	je     800f4f <pgfault+0xb2>
  800ed9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ee0:	f6 c6 08             	test   $0x8,%dh
  800ee3:	74 6a                	je     800f4f <pgfault+0xb2>
		panic("not copy-on-write");
	addr = ROUNDDOWN(addr, PGSIZE);
  800ee5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800eea:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P) < 0)
  800eec:	83 ec 04             	sub    $0x4,%esp
  800eef:	6a 07                	push   $0x7
  800ef1:	68 00 f0 7f 00       	push   $0x7ff000
  800ef6:	6a 00                	push   $0x0
  800ef8:	e8 af fd ff ff       	call   800cac <sys_page_alloc>
  800efd:	83 c4 10             	add    $0x10,%esp
  800f00:	85 c0                	test   %eax,%eax
  800f02:	78 5f                	js     800f63 <pgfault+0xc6>
		panic("sys_page_alloc");
	memcpy(PFTEMP, addr, PGSIZE);
  800f04:	83 ec 04             	sub    $0x4,%esp
  800f07:	68 00 10 00 00       	push   $0x1000
  800f0c:	53                   	push   %ebx
  800f0d:	68 00 f0 7f 00       	push   $0x7ff000
  800f12:	e8 92 fb ff ff       	call   800aa9 <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P) < 0)
  800f17:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f1e:	53                   	push   %ebx
  800f1f:	6a 00                	push   $0x0
  800f21:	68 00 f0 7f 00       	push   $0x7ff000
  800f26:	6a 00                	push   $0x0
  800f28:	e8 c2 fd ff ff       	call   800cef <sys_page_map>
  800f2d:	83 c4 20             	add    $0x20,%esp
  800f30:	85 c0                	test   %eax,%eax
  800f32:	78 43                	js     800f77 <pgfault+0xda>
		panic("sys_page_map");
	if (sys_page_unmap(0, PFTEMP) < 0)
  800f34:	83 ec 08             	sub    $0x8,%esp
  800f37:	68 00 f0 7f 00       	push   $0x7ff000
  800f3c:	6a 00                	push   $0x0
  800f3e:	e8 ee fd ff ff       	call   800d31 <sys_page_unmap>
  800f43:	83 c4 10             	add    $0x10,%esp
  800f46:	85 c0                	test   %eax,%eax
  800f48:	78 41                	js     800f8b <pgfault+0xee>
		panic("sys_page_unmap");
	return;
}
  800f4a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f4d:	c9                   	leave  
  800f4e:	c3                   	ret    
		panic("not copy-on-write");
  800f4f:	83 ec 04             	sub    $0x4,%esp
  800f52:	68 6a 26 80 00       	push   $0x80266a
  800f57:	6a 25                	push   $0x25
  800f59:	68 7c 26 80 00       	push   $0x80267c
  800f5e:	e8 ce 0f 00 00       	call   801f31 <_panic>
		panic("sys_page_alloc");
  800f63:	83 ec 04             	sub    $0x4,%esp
  800f66:	68 87 26 80 00       	push   $0x802687
  800f6b:	6a 28                	push   $0x28
  800f6d:	68 7c 26 80 00       	push   $0x80267c
  800f72:	e8 ba 0f 00 00       	call   801f31 <_panic>
		panic("sys_page_map");
  800f77:	83 ec 04             	sub    $0x4,%esp
  800f7a:	68 96 26 80 00       	push   $0x802696
  800f7f:	6a 2b                	push   $0x2b
  800f81:	68 7c 26 80 00       	push   $0x80267c
  800f86:	e8 a6 0f 00 00       	call   801f31 <_panic>
		panic("sys_page_unmap");
  800f8b:	83 ec 04             	sub    $0x4,%esp
  800f8e:	68 a3 26 80 00       	push   $0x8026a3
  800f93:	6a 2d                	push   $0x2d
  800f95:	68 7c 26 80 00       	push   $0x80267c
  800f9a:	e8 92 0f 00 00       	call   801f31 <_panic>

00800f9f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f9f:	55                   	push   %ebp
  800fa0:	89 e5                	mov    %esp,%ebp
  800fa2:	57                   	push   %edi
  800fa3:	56                   	push   %esi
  800fa4:	53                   	push   %ebx
  800fa5:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800fa8:	68 9d 0e 80 00       	push   $0x800e9d
  800fad:	e8 c5 0f 00 00       	call   801f77 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fb2:	b8 07 00 00 00       	mov    $0x7,%eax
  800fb7:	cd 30                	int    $0x30
  800fb9:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid;
	uint32_t addr;
	envid = sys_exofork();
	if (envid == 0) {
  800fbc:	83 c4 10             	add    $0x10,%esp
  800fbf:	85 c0                	test   %eax,%eax
  800fc1:	74 12                	je     800fd5 <fork+0x36>
  800fc3:	89 c7                	mov    %eax,%edi
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	if (envid < 0)
  800fc5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800fc9:	78 26                	js     800ff1 <fork+0x52>
		panic("sys_exofork: %e", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  800fcb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fd0:	e9 94 00 00 00       	jmp    801069 <fork+0xca>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fd5:	e8 94 fc ff ff       	call   800c6e <sys_getenvid>
  800fda:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fdf:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fe2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fe7:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800fec:	e9 51 01 00 00       	jmp    801142 <fork+0x1a3>
		panic("sys_exofork: %e", envid);
  800ff1:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ff4:	68 b2 26 80 00       	push   $0x8026b2
  800ff9:	6a 6e                	push   $0x6e
  800ffb:	68 7c 26 80 00       	push   $0x80267c
  801000:	e8 2c 0f 00 00       	call   801f31 <_panic>
        	sys_page_map(0, addr, envid, addr, PTE_SYSCALL);
  801005:	83 ec 0c             	sub    $0xc,%esp
  801008:	68 07 0e 00 00       	push   $0xe07
  80100d:	56                   	push   %esi
  80100e:	57                   	push   %edi
  80100f:	56                   	push   %esi
  801010:	6a 00                	push   $0x0
  801012:	e8 d8 fc ff ff       	call   800cef <sys_page_map>
  801017:	83 c4 20             	add    $0x20,%esp
  80101a:	eb 3b                	jmp    801057 <fork+0xb8>
        	if ((r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  80101c:	83 ec 0c             	sub    $0xc,%esp
  80101f:	68 05 08 00 00       	push   $0x805
  801024:	56                   	push   %esi
  801025:	57                   	push   %edi
  801026:	56                   	push   %esi
  801027:	6a 00                	push   $0x0
  801029:	e8 c1 fc ff ff       	call   800cef <sys_page_map>
  80102e:	83 c4 20             	add    $0x20,%esp
  801031:	85 c0                	test   %eax,%eax
  801033:	0f 88 a9 00 00 00    	js     8010e2 <fork+0x143>
        	if ((r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  801039:	83 ec 0c             	sub    $0xc,%esp
  80103c:	68 05 08 00 00       	push   $0x805
  801041:	56                   	push   %esi
  801042:	6a 00                	push   $0x0
  801044:	56                   	push   %esi
  801045:	6a 00                	push   $0x0
  801047:	e8 a3 fc ff ff       	call   800cef <sys_page_map>
  80104c:	83 c4 20             	add    $0x20,%esp
  80104f:	85 c0                	test   %eax,%eax
  801051:	0f 88 9d 00 00 00    	js     8010f4 <fork+0x155>
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  801057:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80105d:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801063:	0f 84 9d 00 00 00    	je     801106 <fork+0x167>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  801069:	89 d8                	mov    %ebx,%eax
  80106b:	c1 e8 16             	shr    $0x16,%eax
  80106e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801075:	a8 01                	test   $0x1,%al
  801077:	74 de                	je     801057 <fork+0xb8>
  801079:	89 d8                	mov    %ebx,%eax
  80107b:	c1 e8 0c             	shr    $0xc,%eax
  80107e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801085:	f6 c2 01             	test   $0x1,%dl
  801088:	74 cd                	je     801057 <fork+0xb8>
			&& (uvpt[PGNUM(addr)] & PTE_U)) {
  80108a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801091:	f6 c2 04             	test   $0x4,%dl
  801094:	74 c1                	je     801057 <fork+0xb8>
	void *addr = (void*) (pn*PGSIZE);
  801096:	89 c6                	mov    %eax,%esi
  801098:	c1 e6 0c             	shl    $0xc,%esi
    	if (uvpt[pn] & PTE_SHARE) {
  80109b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010a2:	f6 c6 04             	test   $0x4,%dh
  8010a5:	0f 85 5a ff ff ff    	jne    801005 <fork+0x66>
    	} else if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  8010ab:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010b2:	f6 c2 02             	test   $0x2,%dl
  8010b5:	0f 85 61 ff ff ff    	jne    80101c <fork+0x7d>
  8010bb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010c2:	f6 c4 08             	test   $0x8,%ah
  8010c5:	0f 85 51 ff ff ff    	jne    80101c <fork+0x7d>
        		sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  8010cb:	83 ec 0c             	sub    $0xc,%esp
  8010ce:	6a 05                	push   $0x5
  8010d0:	56                   	push   %esi
  8010d1:	57                   	push   %edi
  8010d2:	56                   	push   %esi
  8010d3:	6a 00                	push   $0x0
  8010d5:	e8 15 fc ff ff       	call   800cef <sys_page_map>
  8010da:	83 c4 20             	add    $0x20,%esp
  8010dd:	e9 75 ff ff ff       	jmp    801057 <fork+0xb8>
            		panic("sys_page_map：%e", r);
  8010e2:	50                   	push   %eax
  8010e3:	68 c2 26 80 00       	push   $0x8026c2
  8010e8:	6a 47                	push   $0x47
  8010ea:	68 7c 26 80 00       	push   $0x80267c
  8010ef:	e8 3d 0e 00 00       	call   801f31 <_panic>
            		panic("sys_page_map：%e", r);
  8010f4:	50                   	push   %eax
  8010f5:	68 c2 26 80 00       	push   $0x8026c2
  8010fa:	6a 49                	push   $0x49
  8010fc:	68 7c 26 80 00       	push   $0x80267c
  801101:	e8 2b 0e 00 00       	call   801f31 <_panic>
			duppage(envid, PGNUM(addr));
		}

	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  801106:	83 ec 04             	sub    $0x4,%esp
  801109:	6a 07                	push   $0x7
  80110b:	68 00 f0 bf ee       	push   $0xeebff000
  801110:	ff 75 e4             	pushl  -0x1c(%ebp)
  801113:	e8 94 fb ff ff       	call   800cac <sys_page_alloc>
  801118:	83 c4 10             	add    $0x10,%esp
  80111b:	85 c0                	test   %eax,%eax
  80111d:	78 2e                	js     80114d <fork+0x1ae>
		panic("1");
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80111f:	83 ec 08             	sub    $0x8,%esp
  801122:	68 e6 1f 80 00       	push   $0x801fe6
  801127:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80112a:	57                   	push   %edi
  80112b:	e8 c7 fc ff ff       	call   800df7 <sys_env_set_pgfault_upcall>

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  801130:	83 c4 08             	add    $0x8,%esp
  801133:	6a 02                	push   $0x2
  801135:	57                   	push   %edi
  801136:	e8 38 fc ff ff       	call   800d73 <sys_env_set_status>
  80113b:	83 c4 10             	add    $0x10,%esp
  80113e:	85 c0                	test   %eax,%eax
  801140:	78 1f                	js     801161 <fork+0x1c2>
		panic("sys_env_set_status");

	return envid;
	panic("fork not implemented");
}
  801142:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801145:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801148:	5b                   	pop    %ebx
  801149:	5e                   	pop    %esi
  80114a:	5f                   	pop    %edi
  80114b:	5d                   	pop    %ebp
  80114c:	c3                   	ret    
		panic("1");
  80114d:	83 ec 04             	sub    $0x4,%esp
  801150:	68 d4 26 80 00       	push   $0x8026d4
  801155:	6a 77                	push   $0x77
  801157:	68 7c 26 80 00       	push   $0x80267c
  80115c:	e8 d0 0d 00 00       	call   801f31 <_panic>
		panic("sys_env_set_status");
  801161:	83 ec 04             	sub    $0x4,%esp
  801164:	68 d6 26 80 00       	push   $0x8026d6
  801169:	6a 7c                	push   $0x7c
  80116b:	68 7c 26 80 00       	push   $0x80267c
  801170:	e8 bc 0d 00 00       	call   801f31 <_panic>

00801175 <sfork>:

// Challenge!
int
sfork(void)
{
  801175:	55                   	push   %ebp
  801176:	89 e5                	mov    %esp,%ebp
  801178:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80117b:	68 e9 26 80 00       	push   $0x8026e9
  801180:	68 86 00 00 00       	push   $0x86
  801185:	68 7c 26 80 00       	push   $0x80267c
  80118a:	e8 a2 0d 00 00       	call   801f31 <_panic>

0080118f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80118f:	55                   	push   %ebp
  801190:	89 e5                	mov    %esp,%ebp
  801192:	56                   	push   %esi
  801193:	53                   	push   %ebx
  801194:	8b 75 08             	mov    0x8(%ebp),%esi
  801197:	8b 45 0c             	mov    0xc(%ebp),%eax
  80119a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  80119d:	85 f6                	test   %esi,%esi
  80119f:	74 06                	je     8011a7 <ipc_recv+0x18>
  8011a1:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  8011a7:	85 db                	test   %ebx,%ebx
  8011a9:	74 06                	je     8011b1 <ipc_recv+0x22>
  8011ab:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  8011b1:	85 c0                	test   %eax,%eax
  8011b3:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  8011b8:	0f 44 c2             	cmove  %edx,%eax
	int ret = sys_ipc_recv(pg);
  8011bb:	83 ec 0c             	sub    $0xc,%esp
  8011be:	50                   	push   %eax
  8011bf:	e8 98 fc ff ff       	call   800e5c <sys_ipc_recv>
	if (ret) return ret;
  8011c4:	83 c4 10             	add    $0x10,%esp
  8011c7:	85 c0                	test   %eax,%eax
  8011c9:	75 24                	jne    8011ef <ipc_recv+0x60>
	if (from_env_store)
  8011cb:	85 f6                	test   %esi,%esi
  8011cd:	74 0a                	je     8011d9 <ipc_recv+0x4a>
		*from_env_store = thisenv->env_ipc_from;
  8011cf:	a1 04 40 80 00       	mov    0x804004,%eax
  8011d4:	8b 40 74             	mov    0x74(%eax),%eax
  8011d7:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  8011d9:	85 db                	test   %ebx,%ebx
  8011db:	74 0a                	je     8011e7 <ipc_recv+0x58>
		*perm_store = thisenv->env_ipc_perm;
  8011dd:	a1 04 40 80 00       	mov    0x804004,%eax
  8011e2:	8b 40 78             	mov    0x78(%eax),%eax
  8011e5:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  8011e7:	a1 04 40 80 00       	mov    0x804004,%eax
  8011ec:	8b 40 70             	mov    0x70(%eax),%eax
}
  8011ef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011f2:	5b                   	pop    %ebx
  8011f3:	5e                   	pop    %esi
  8011f4:	5d                   	pop    %ebp
  8011f5:	c3                   	ret    

008011f6 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8011f6:	55                   	push   %ebp
  8011f7:	89 e5                	mov    %esp,%ebp
  8011f9:	57                   	push   %edi
  8011fa:	56                   	push   %esi
  8011fb:	53                   	push   %ebx
  8011fc:	83 ec 0c             	sub    $0xc,%esp
  8011ff:	8b 7d 08             	mov    0x8(%ebp),%edi
  801202:	8b 75 0c             	mov    0xc(%ebp),%esi
  801205:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  801208:	85 db                	test   %ebx,%ebx
  80120a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80120f:	0f 44 d8             	cmove  %eax,%ebx
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801212:	ff 75 14             	pushl  0x14(%ebp)
  801215:	53                   	push   %ebx
  801216:	56                   	push   %esi
  801217:	57                   	push   %edi
  801218:	e8 1c fc ff ff       	call   800e39 <sys_ipc_try_send>
  80121d:	83 c4 10             	add    $0x10,%esp
  801220:	85 c0                	test   %eax,%eax
  801222:	74 1e                	je     801242 <ipc_send+0x4c>
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801224:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801227:	75 07                	jne    801230 <ipc_send+0x3a>
		sys_yield();
  801229:	e8 5f fa ff ff       	call   800c8d <sys_yield>
  80122e:	eb e2                	jmp    801212 <ipc_send+0x1c>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801230:	50                   	push   %eax
  801231:	68 ff 26 80 00       	push   $0x8026ff
  801236:	6a 36                	push   $0x36
  801238:	68 16 27 80 00       	push   $0x802716
  80123d:	e8 ef 0c 00 00       	call   801f31 <_panic>
	}
}
  801242:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801245:	5b                   	pop    %ebx
  801246:	5e                   	pop    %esi
  801247:	5f                   	pop    %edi
  801248:	5d                   	pop    %ebp
  801249:	c3                   	ret    

0080124a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80124a:	55                   	push   %ebp
  80124b:	89 e5                	mov    %esp,%ebp
  80124d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801250:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801255:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801258:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80125e:	8b 52 50             	mov    0x50(%edx),%edx
  801261:	39 ca                	cmp    %ecx,%edx
  801263:	74 11                	je     801276 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801265:	83 c0 01             	add    $0x1,%eax
  801268:	3d 00 04 00 00       	cmp    $0x400,%eax
  80126d:	75 e6                	jne    801255 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  80126f:	b8 00 00 00 00       	mov    $0x0,%eax
  801274:	eb 0b                	jmp    801281 <ipc_find_env+0x37>
			return envs[i].env_id;
  801276:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801279:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80127e:	8b 40 48             	mov    0x48(%eax),%eax
}
  801281:	5d                   	pop    %ebp
  801282:	c3                   	ret    

00801283 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801283:	55                   	push   %ebp
  801284:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801286:	8b 45 08             	mov    0x8(%ebp),%eax
  801289:	05 00 00 00 30       	add    $0x30000000,%eax
  80128e:	c1 e8 0c             	shr    $0xc,%eax
}
  801291:	5d                   	pop    %ebp
  801292:	c3                   	ret    

00801293 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801293:	55                   	push   %ebp
  801294:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801296:	8b 45 08             	mov    0x8(%ebp),%eax
  801299:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80129e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012a3:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012a8:	5d                   	pop    %ebp
  8012a9:	c3                   	ret    

008012aa <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012aa:	55                   	push   %ebp
  8012ab:	89 e5                	mov    %esp,%ebp
  8012ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012b0:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012b5:	89 c2                	mov    %eax,%edx
  8012b7:	c1 ea 16             	shr    $0x16,%edx
  8012ba:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012c1:	f6 c2 01             	test   $0x1,%dl
  8012c4:	74 2a                	je     8012f0 <fd_alloc+0x46>
  8012c6:	89 c2                	mov    %eax,%edx
  8012c8:	c1 ea 0c             	shr    $0xc,%edx
  8012cb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012d2:	f6 c2 01             	test   $0x1,%dl
  8012d5:	74 19                	je     8012f0 <fd_alloc+0x46>
  8012d7:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8012dc:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012e1:	75 d2                	jne    8012b5 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012e3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012e9:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8012ee:	eb 07                	jmp    8012f7 <fd_alloc+0x4d>
			*fd_store = fd;
  8012f0:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012f7:	5d                   	pop    %ebp
  8012f8:	c3                   	ret    

008012f9 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012f9:	55                   	push   %ebp
  8012fa:	89 e5                	mov    %esp,%ebp
  8012fc:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012ff:	83 f8 1f             	cmp    $0x1f,%eax
  801302:	77 36                	ja     80133a <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801304:	c1 e0 0c             	shl    $0xc,%eax
  801307:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80130c:	89 c2                	mov    %eax,%edx
  80130e:	c1 ea 16             	shr    $0x16,%edx
  801311:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801318:	f6 c2 01             	test   $0x1,%dl
  80131b:	74 24                	je     801341 <fd_lookup+0x48>
  80131d:	89 c2                	mov    %eax,%edx
  80131f:	c1 ea 0c             	shr    $0xc,%edx
  801322:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801329:	f6 c2 01             	test   $0x1,%dl
  80132c:	74 1a                	je     801348 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80132e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801331:	89 02                	mov    %eax,(%edx)
	return 0;
  801333:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801338:	5d                   	pop    %ebp
  801339:	c3                   	ret    
		return -E_INVAL;
  80133a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80133f:	eb f7                	jmp    801338 <fd_lookup+0x3f>
		return -E_INVAL;
  801341:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801346:	eb f0                	jmp    801338 <fd_lookup+0x3f>
  801348:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80134d:	eb e9                	jmp    801338 <fd_lookup+0x3f>

0080134f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80134f:	55                   	push   %ebp
  801350:	89 e5                	mov    %esp,%ebp
  801352:	83 ec 08             	sub    $0x8,%esp
  801355:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801358:	ba 9c 27 80 00       	mov    $0x80279c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80135d:	b8 0c 30 80 00       	mov    $0x80300c,%eax
		if (devtab[i]->dev_id == dev_id) {
  801362:	39 08                	cmp    %ecx,(%eax)
  801364:	74 33                	je     801399 <dev_lookup+0x4a>
  801366:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  801369:	8b 02                	mov    (%edx),%eax
  80136b:	85 c0                	test   %eax,%eax
  80136d:	75 f3                	jne    801362 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80136f:	a1 04 40 80 00       	mov    0x804004,%eax
  801374:	8b 40 48             	mov    0x48(%eax),%eax
  801377:	83 ec 04             	sub    $0x4,%esp
  80137a:	51                   	push   %ecx
  80137b:	50                   	push   %eax
  80137c:	68 20 27 80 00       	push   $0x802720
  801381:	e8 0e ef ff ff       	call   800294 <cprintf>
	*dev = 0;
  801386:	8b 45 0c             	mov    0xc(%ebp),%eax
  801389:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80138f:	83 c4 10             	add    $0x10,%esp
  801392:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801397:	c9                   	leave  
  801398:	c3                   	ret    
			*dev = devtab[i];
  801399:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80139c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80139e:	b8 00 00 00 00       	mov    $0x0,%eax
  8013a3:	eb f2                	jmp    801397 <dev_lookup+0x48>

008013a5 <fd_close>:
{
  8013a5:	55                   	push   %ebp
  8013a6:	89 e5                	mov    %esp,%ebp
  8013a8:	57                   	push   %edi
  8013a9:	56                   	push   %esi
  8013aa:	53                   	push   %ebx
  8013ab:	83 ec 1c             	sub    $0x1c,%esp
  8013ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8013b1:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013b4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013b7:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013b8:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013be:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013c1:	50                   	push   %eax
  8013c2:	e8 32 ff ff ff       	call   8012f9 <fd_lookup>
  8013c7:	89 c3                	mov    %eax,%ebx
  8013c9:	83 c4 08             	add    $0x8,%esp
  8013cc:	85 c0                	test   %eax,%eax
  8013ce:	78 05                	js     8013d5 <fd_close+0x30>
	    || fd != fd2)
  8013d0:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8013d3:	74 16                	je     8013eb <fd_close+0x46>
		return (must_exist ? r : 0);
  8013d5:	89 f8                	mov    %edi,%eax
  8013d7:	84 c0                	test   %al,%al
  8013d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8013de:	0f 44 d8             	cmove  %eax,%ebx
}
  8013e1:	89 d8                	mov    %ebx,%eax
  8013e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013e6:	5b                   	pop    %ebx
  8013e7:	5e                   	pop    %esi
  8013e8:	5f                   	pop    %edi
  8013e9:	5d                   	pop    %ebp
  8013ea:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013eb:	83 ec 08             	sub    $0x8,%esp
  8013ee:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8013f1:	50                   	push   %eax
  8013f2:	ff 36                	pushl  (%esi)
  8013f4:	e8 56 ff ff ff       	call   80134f <dev_lookup>
  8013f9:	89 c3                	mov    %eax,%ebx
  8013fb:	83 c4 10             	add    $0x10,%esp
  8013fe:	85 c0                	test   %eax,%eax
  801400:	78 15                	js     801417 <fd_close+0x72>
		if (dev->dev_close)
  801402:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801405:	8b 40 10             	mov    0x10(%eax),%eax
  801408:	85 c0                	test   %eax,%eax
  80140a:	74 1b                	je     801427 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  80140c:	83 ec 0c             	sub    $0xc,%esp
  80140f:	56                   	push   %esi
  801410:	ff d0                	call   *%eax
  801412:	89 c3                	mov    %eax,%ebx
  801414:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801417:	83 ec 08             	sub    $0x8,%esp
  80141a:	56                   	push   %esi
  80141b:	6a 00                	push   $0x0
  80141d:	e8 0f f9 ff ff       	call   800d31 <sys_page_unmap>
	return r;
  801422:	83 c4 10             	add    $0x10,%esp
  801425:	eb ba                	jmp    8013e1 <fd_close+0x3c>
			r = 0;
  801427:	bb 00 00 00 00       	mov    $0x0,%ebx
  80142c:	eb e9                	jmp    801417 <fd_close+0x72>

0080142e <close>:

int
close(int fdnum)
{
  80142e:	55                   	push   %ebp
  80142f:	89 e5                	mov    %esp,%ebp
  801431:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801434:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801437:	50                   	push   %eax
  801438:	ff 75 08             	pushl  0x8(%ebp)
  80143b:	e8 b9 fe ff ff       	call   8012f9 <fd_lookup>
  801440:	83 c4 08             	add    $0x8,%esp
  801443:	85 c0                	test   %eax,%eax
  801445:	78 10                	js     801457 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801447:	83 ec 08             	sub    $0x8,%esp
  80144a:	6a 01                	push   $0x1
  80144c:	ff 75 f4             	pushl  -0xc(%ebp)
  80144f:	e8 51 ff ff ff       	call   8013a5 <fd_close>
  801454:	83 c4 10             	add    $0x10,%esp
}
  801457:	c9                   	leave  
  801458:	c3                   	ret    

00801459 <close_all>:

void
close_all(void)
{
  801459:	55                   	push   %ebp
  80145a:	89 e5                	mov    %esp,%ebp
  80145c:	53                   	push   %ebx
  80145d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801460:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801465:	83 ec 0c             	sub    $0xc,%esp
  801468:	53                   	push   %ebx
  801469:	e8 c0 ff ff ff       	call   80142e <close>
	for (i = 0; i < MAXFD; i++)
  80146e:	83 c3 01             	add    $0x1,%ebx
  801471:	83 c4 10             	add    $0x10,%esp
  801474:	83 fb 20             	cmp    $0x20,%ebx
  801477:	75 ec                	jne    801465 <close_all+0xc>
}
  801479:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80147c:	c9                   	leave  
  80147d:	c3                   	ret    

0080147e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80147e:	55                   	push   %ebp
  80147f:	89 e5                	mov    %esp,%ebp
  801481:	57                   	push   %edi
  801482:	56                   	push   %esi
  801483:	53                   	push   %ebx
  801484:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801487:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80148a:	50                   	push   %eax
  80148b:	ff 75 08             	pushl  0x8(%ebp)
  80148e:	e8 66 fe ff ff       	call   8012f9 <fd_lookup>
  801493:	89 c3                	mov    %eax,%ebx
  801495:	83 c4 08             	add    $0x8,%esp
  801498:	85 c0                	test   %eax,%eax
  80149a:	0f 88 81 00 00 00    	js     801521 <dup+0xa3>
		return r;
	close(newfdnum);
  8014a0:	83 ec 0c             	sub    $0xc,%esp
  8014a3:	ff 75 0c             	pushl  0xc(%ebp)
  8014a6:	e8 83 ff ff ff       	call   80142e <close>

	newfd = INDEX2FD(newfdnum);
  8014ab:	8b 75 0c             	mov    0xc(%ebp),%esi
  8014ae:	c1 e6 0c             	shl    $0xc,%esi
  8014b1:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8014b7:	83 c4 04             	add    $0x4,%esp
  8014ba:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014bd:	e8 d1 fd ff ff       	call   801293 <fd2data>
  8014c2:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8014c4:	89 34 24             	mov    %esi,(%esp)
  8014c7:	e8 c7 fd ff ff       	call   801293 <fd2data>
  8014cc:	83 c4 10             	add    $0x10,%esp
  8014cf:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014d1:	89 d8                	mov    %ebx,%eax
  8014d3:	c1 e8 16             	shr    $0x16,%eax
  8014d6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014dd:	a8 01                	test   $0x1,%al
  8014df:	74 11                	je     8014f2 <dup+0x74>
  8014e1:	89 d8                	mov    %ebx,%eax
  8014e3:	c1 e8 0c             	shr    $0xc,%eax
  8014e6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014ed:	f6 c2 01             	test   $0x1,%dl
  8014f0:	75 39                	jne    80152b <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014f2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014f5:	89 d0                	mov    %edx,%eax
  8014f7:	c1 e8 0c             	shr    $0xc,%eax
  8014fa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801501:	83 ec 0c             	sub    $0xc,%esp
  801504:	25 07 0e 00 00       	and    $0xe07,%eax
  801509:	50                   	push   %eax
  80150a:	56                   	push   %esi
  80150b:	6a 00                	push   $0x0
  80150d:	52                   	push   %edx
  80150e:	6a 00                	push   $0x0
  801510:	e8 da f7 ff ff       	call   800cef <sys_page_map>
  801515:	89 c3                	mov    %eax,%ebx
  801517:	83 c4 20             	add    $0x20,%esp
  80151a:	85 c0                	test   %eax,%eax
  80151c:	78 31                	js     80154f <dup+0xd1>
		goto err;

	return newfdnum;
  80151e:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801521:	89 d8                	mov    %ebx,%eax
  801523:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801526:	5b                   	pop    %ebx
  801527:	5e                   	pop    %esi
  801528:	5f                   	pop    %edi
  801529:	5d                   	pop    %ebp
  80152a:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80152b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801532:	83 ec 0c             	sub    $0xc,%esp
  801535:	25 07 0e 00 00       	and    $0xe07,%eax
  80153a:	50                   	push   %eax
  80153b:	57                   	push   %edi
  80153c:	6a 00                	push   $0x0
  80153e:	53                   	push   %ebx
  80153f:	6a 00                	push   $0x0
  801541:	e8 a9 f7 ff ff       	call   800cef <sys_page_map>
  801546:	89 c3                	mov    %eax,%ebx
  801548:	83 c4 20             	add    $0x20,%esp
  80154b:	85 c0                	test   %eax,%eax
  80154d:	79 a3                	jns    8014f2 <dup+0x74>
	sys_page_unmap(0, newfd);
  80154f:	83 ec 08             	sub    $0x8,%esp
  801552:	56                   	push   %esi
  801553:	6a 00                	push   $0x0
  801555:	e8 d7 f7 ff ff       	call   800d31 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80155a:	83 c4 08             	add    $0x8,%esp
  80155d:	57                   	push   %edi
  80155e:	6a 00                	push   $0x0
  801560:	e8 cc f7 ff ff       	call   800d31 <sys_page_unmap>
	return r;
  801565:	83 c4 10             	add    $0x10,%esp
  801568:	eb b7                	jmp    801521 <dup+0xa3>

0080156a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80156a:	55                   	push   %ebp
  80156b:	89 e5                	mov    %esp,%ebp
  80156d:	53                   	push   %ebx
  80156e:	83 ec 14             	sub    $0x14,%esp
  801571:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801574:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801577:	50                   	push   %eax
  801578:	53                   	push   %ebx
  801579:	e8 7b fd ff ff       	call   8012f9 <fd_lookup>
  80157e:	83 c4 08             	add    $0x8,%esp
  801581:	85 c0                	test   %eax,%eax
  801583:	78 3f                	js     8015c4 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801585:	83 ec 08             	sub    $0x8,%esp
  801588:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80158b:	50                   	push   %eax
  80158c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80158f:	ff 30                	pushl  (%eax)
  801591:	e8 b9 fd ff ff       	call   80134f <dev_lookup>
  801596:	83 c4 10             	add    $0x10,%esp
  801599:	85 c0                	test   %eax,%eax
  80159b:	78 27                	js     8015c4 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80159d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015a0:	8b 42 08             	mov    0x8(%edx),%eax
  8015a3:	83 e0 03             	and    $0x3,%eax
  8015a6:	83 f8 01             	cmp    $0x1,%eax
  8015a9:	74 1e                	je     8015c9 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8015ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015ae:	8b 40 08             	mov    0x8(%eax),%eax
  8015b1:	85 c0                	test   %eax,%eax
  8015b3:	74 35                	je     8015ea <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015b5:	83 ec 04             	sub    $0x4,%esp
  8015b8:	ff 75 10             	pushl  0x10(%ebp)
  8015bb:	ff 75 0c             	pushl  0xc(%ebp)
  8015be:	52                   	push   %edx
  8015bf:	ff d0                	call   *%eax
  8015c1:	83 c4 10             	add    $0x10,%esp
}
  8015c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c7:	c9                   	leave  
  8015c8:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015c9:	a1 04 40 80 00       	mov    0x804004,%eax
  8015ce:	8b 40 48             	mov    0x48(%eax),%eax
  8015d1:	83 ec 04             	sub    $0x4,%esp
  8015d4:	53                   	push   %ebx
  8015d5:	50                   	push   %eax
  8015d6:	68 61 27 80 00       	push   $0x802761
  8015db:	e8 b4 ec ff ff       	call   800294 <cprintf>
		return -E_INVAL;
  8015e0:	83 c4 10             	add    $0x10,%esp
  8015e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015e8:	eb da                	jmp    8015c4 <read+0x5a>
		return -E_NOT_SUPP;
  8015ea:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015ef:	eb d3                	jmp    8015c4 <read+0x5a>

008015f1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015f1:	55                   	push   %ebp
  8015f2:	89 e5                	mov    %esp,%ebp
  8015f4:	57                   	push   %edi
  8015f5:	56                   	push   %esi
  8015f6:	53                   	push   %ebx
  8015f7:	83 ec 0c             	sub    $0xc,%esp
  8015fa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015fd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801600:	bb 00 00 00 00       	mov    $0x0,%ebx
  801605:	39 f3                	cmp    %esi,%ebx
  801607:	73 25                	jae    80162e <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801609:	83 ec 04             	sub    $0x4,%esp
  80160c:	89 f0                	mov    %esi,%eax
  80160e:	29 d8                	sub    %ebx,%eax
  801610:	50                   	push   %eax
  801611:	89 d8                	mov    %ebx,%eax
  801613:	03 45 0c             	add    0xc(%ebp),%eax
  801616:	50                   	push   %eax
  801617:	57                   	push   %edi
  801618:	e8 4d ff ff ff       	call   80156a <read>
		if (m < 0)
  80161d:	83 c4 10             	add    $0x10,%esp
  801620:	85 c0                	test   %eax,%eax
  801622:	78 08                	js     80162c <readn+0x3b>
			return m;
		if (m == 0)
  801624:	85 c0                	test   %eax,%eax
  801626:	74 06                	je     80162e <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  801628:	01 c3                	add    %eax,%ebx
  80162a:	eb d9                	jmp    801605 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80162c:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80162e:	89 d8                	mov    %ebx,%eax
  801630:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801633:	5b                   	pop    %ebx
  801634:	5e                   	pop    %esi
  801635:	5f                   	pop    %edi
  801636:	5d                   	pop    %ebp
  801637:	c3                   	ret    

00801638 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801638:	55                   	push   %ebp
  801639:	89 e5                	mov    %esp,%ebp
  80163b:	53                   	push   %ebx
  80163c:	83 ec 14             	sub    $0x14,%esp
  80163f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801642:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801645:	50                   	push   %eax
  801646:	53                   	push   %ebx
  801647:	e8 ad fc ff ff       	call   8012f9 <fd_lookup>
  80164c:	83 c4 08             	add    $0x8,%esp
  80164f:	85 c0                	test   %eax,%eax
  801651:	78 3a                	js     80168d <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801653:	83 ec 08             	sub    $0x8,%esp
  801656:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801659:	50                   	push   %eax
  80165a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80165d:	ff 30                	pushl  (%eax)
  80165f:	e8 eb fc ff ff       	call   80134f <dev_lookup>
  801664:	83 c4 10             	add    $0x10,%esp
  801667:	85 c0                	test   %eax,%eax
  801669:	78 22                	js     80168d <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80166b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80166e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801672:	74 1e                	je     801692 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801674:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801677:	8b 52 0c             	mov    0xc(%edx),%edx
  80167a:	85 d2                	test   %edx,%edx
  80167c:	74 35                	je     8016b3 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80167e:	83 ec 04             	sub    $0x4,%esp
  801681:	ff 75 10             	pushl  0x10(%ebp)
  801684:	ff 75 0c             	pushl  0xc(%ebp)
  801687:	50                   	push   %eax
  801688:	ff d2                	call   *%edx
  80168a:	83 c4 10             	add    $0x10,%esp
}
  80168d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801690:	c9                   	leave  
  801691:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801692:	a1 04 40 80 00       	mov    0x804004,%eax
  801697:	8b 40 48             	mov    0x48(%eax),%eax
  80169a:	83 ec 04             	sub    $0x4,%esp
  80169d:	53                   	push   %ebx
  80169e:	50                   	push   %eax
  80169f:	68 7d 27 80 00       	push   $0x80277d
  8016a4:	e8 eb eb ff ff       	call   800294 <cprintf>
		return -E_INVAL;
  8016a9:	83 c4 10             	add    $0x10,%esp
  8016ac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016b1:	eb da                	jmp    80168d <write+0x55>
		return -E_NOT_SUPP;
  8016b3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016b8:	eb d3                	jmp    80168d <write+0x55>

008016ba <seek>:

int
seek(int fdnum, off_t offset)
{
  8016ba:	55                   	push   %ebp
  8016bb:	89 e5                	mov    %esp,%ebp
  8016bd:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016c0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016c3:	50                   	push   %eax
  8016c4:	ff 75 08             	pushl  0x8(%ebp)
  8016c7:	e8 2d fc ff ff       	call   8012f9 <fd_lookup>
  8016cc:	83 c4 08             	add    $0x8,%esp
  8016cf:	85 c0                	test   %eax,%eax
  8016d1:	78 0e                	js     8016e1 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016d9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016e1:	c9                   	leave  
  8016e2:	c3                   	ret    

008016e3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016e3:	55                   	push   %ebp
  8016e4:	89 e5                	mov    %esp,%ebp
  8016e6:	53                   	push   %ebx
  8016e7:	83 ec 14             	sub    $0x14,%esp
  8016ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016ed:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016f0:	50                   	push   %eax
  8016f1:	53                   	push   %ebx
  8016f2:	e8 02 fc ff ff       	call   8012f9 <fd_lookup>
  8016f7:	83 c4 08             	add    $0x8,%esp
  8016fa:	85 c0                	test   %eax,%eax
  8016fc:	78 37                	js     801735 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016fe:	83 ec 08             	sub    $0x8,%esp
  801701:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801704:	50                   	push   %eax
  801705:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801708:	ff 30                	pushl  (%eax)
  80170a:	e8 40 fc ff ff       	call   80134f <dev_lookup>
  80170f:	83 c4 10             	add    $0x10,%esp
  801712:	85 c0                	test   %eax,%eax
  801714:	78 1f                	js     801735 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801716:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801719:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80171d:	74 1b                	je     80173a <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80171f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801722:	8b 52 18             	mov    0x18(%edx),%edx
  801725:	85 d2                	test   %edx,%edx
  801727:	74 32                	je     80175b <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801729:	83 ec 08             	sub    $0x8,%esp
  80172c:	ff 75 0c             	pushl  0xc(%ebp)
  80172f:	50                   	push   %eax
  801730:	ff d2                	call   *%edx
  801732:	83 c4 10             	add    $0x10,%esp
}
  801735:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801738:	c9                   	leave  
  801739:	c3                   	ret    
			thisenv->env_id, fdnum);
  80173a:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80173f:	8b 40 48             	mov    0x48(%eax),%eax
  801742:	83 ec 04             	sub    $0x4,%esp
  801745:	53                   	push   %ebx
  801746:	50                   	push   %eax
  801747:	68 40 27 80 00       	push   $0x802740
  80174c:	e8 43 eb ff ff       	call   800294 <cprintf>
		return -E_INVAL;
  801751:	83 c4 10             	add    $0x10,%esp
  801754:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801759:	eb da                	jmp    801735 <ftruncate+0x52>
		return -E_NOT_SUPP;
  80175b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801760:	eb d3                	jmp    801735 <ftruncate+0x52>

00801762 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801762:	55                   	push   %ebp
  801763:	89 e5                	mov    %esp,%ebp
  801765:	53                   	push   %ebx
  801766:	83 ec 14             	sub    $0x14,%esp
  801769:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80176c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80176f:	50                   	push   %eax
  801770:	ff 75 08             	pushl  0x8(%ebp)
  801773:	e8 81 fb ff ff       	call   8012f9 <fd_lookup>
  801778:	83 c4 08             	add    $0x8,%esp
  80177b:	85 c0                	test   %eax,%eax
  80177d:	78 4b                	js     8017ca <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80177f:	83 ec 08             	sub    $0x8,%esp
  801782:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801785:	50                   	push   %eax
  801786:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801789:	ff 30                	pushl  (%eax)
  80178b:	e8 bf fb ff ff       	call   80134f <dev_lookup>
  801790:	83 c4 10             	add    $0x10,%esp
  801793:	85 c0                	test   %eax,%eax
  801795:	78 33                	js     8017ca <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  801797:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80179a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80179e:	74 2f                	je     8017cf <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017a0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017a3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017aa:	00 00 00 
	stat->st_isdir = 0;
  8017ad:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017b4:	00 00 00 
	stat->st_dev = dev;
  8017b7:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017bd:	83 ec 08             	sub    $0x8,%esp
  8017c0:	53                   	push   %ebx
  8017c1:	ff 75 f0             	pushl  -0x10(%ebp)
  8017c4:	ff 50 14             	call   *0x14(%eax)
  8017c7:	83 c4 10             	add    $0x10,%esp
}
  8017ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017cd:	c9                   	leave  
  8017ce:	c3                   	ret    
		return -E_NOT_SUPP;
  8017cf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017d4:	eb f4                	jmp    8017ca <fstat+0x68>

008017d6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017d6:	55                   	push   %ebp
  8017d7:	89 e5                	mov    %esp,%ebp
  8017d9:	56                   	push   %esi
  8017da:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017db:	83 ec 08             	sub    $0x8,%esp
  8017de:	6a 00                	push   $0x0
  8017e0:	ff 75 08             	pushl  0x8(%ebp)
  8017e3:	e8 da 01 00 00       	call   8019c2 <open>
  8017e8:	89 c3                	mov    %eax,%ebx
  8017ea:	83 c4 10             	add    $0x10,%esp
  8017ed:	85 c0                	test   %eax,%eax
  8017ef:	78 1b                	js     80180c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017f1:	83 ec 08             	sub    $0x8,%esp
  8017f4:	ff 75 0c             	pushl  0xc(%ebp)
  8017f7:	50                   	push   %eax
  8017f8:	e8 65 ff ff ff       	call   801762 <fstat>
  8017fd:	89 c6                	mov    %eax,%esi
	close(fd);
  8017ff:	89 1c 24             	mov    %ebx,(%esp)
  801802:	e8 27 fc ff ff       	call   80142e <close>
	return r;
  801807:	83 c4 10             	add    $0x10,%esp
  80180a:	89 f3                	mov    %esi,%ebx
}
  80180c:	89 d8                	mov    %ebx,%eax
  80180e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801811:	5b                   	pop    %ebx
  801812:	5e                   	pop    %esi
  801813:	5d                   	pop    %ebp
  801814:	c3                   	ret    

00801815 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801815:	55                   	push   %ebp
  801816:	89 e5                	mov    %esp,%ebp
  801818:	56                   	push   %esi
  801819:	53                   	push   %ebx
  80181a:	89 c6                	mov    %eax,%esi
  80181c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80181e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801825:	74 27                	je     80184e <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801827:	6a 07                	push   $0x7
  801829:	68 00 50 80 00       	push   $0x805000
  80182e:	56                   	push   %esi
  80182f:	ff 35 00 40 80 00    	pushl  0x804000
  801835:	e8 bc f9 ff ff       	call   8011f6 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80183a:	83 c4 0c             	add    $0xc,%esp
  80183d:	6a 00                	push   $0x0
  80183f:	53                   	push   %ebx
  801840:	6a 00                	push   $0x0
  801842:	e8 48 f9 ff ff       	call   80118f <ipc_recv>
}
  801847:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80184a:	5b                   	pop    %ebx
  80184b:	5e                   	pop    %esi
  80184c:	5d                   	pop    %ebp
  80184d:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80184e:	83 ec 0c             	sub    $0xc,%esp
  801851:	6a 01                	push   $0x1
  801853:	e8 f2 f9 ff ff       	call   80124a <ipc_find_env>
  801858:	a3 00 40 80 00       	mov    %eax,0x804000
  80185d:	83 c4 10             	add    $0x10,%esp
  801860:	eb c5                	jmp    801827 <fsipc+0x12>

00801862 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801862:	55                   	push   %ebp
  801863:	89 e5                	mov    %esp,%ebp
  801865:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801868:	8b 45 08             	mov    0x8(%ebp),%eax
  80186b:	8b 40 0c             	mov    0xc(%eax),%eax
  80186e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801873:	8b 45 0c             	mov    0xc(%ebp),%eax
  801876:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80187b:	ba 00 00 00 00       	mov    $0x0,%edx
  801880:	b8 02 00 00 00       	mov    $0x2,%eax
  801885:	e8 8b ff ff ff       	call   801815 <fsipc>
}
  80188a:	c9                   	leave  
  80188b:	c3                   	ret    

0080188c <devfile_flush>:
{
  80188c:	55                   	push   %ebp
  80188d:	89 e5                	mov    %esp,%ebp
  80188f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801892:	8b 45 08             	mov    0x8(%ebp),%eax
  801895:	8b 40 0c             	mov    0xc(%eax),%eax
  801898:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80189d:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a2:	b8 06 00 00 00       	mov    $0x6,%eax
  8018a7:	e8 69 ff ff ff       	call   801815 <fsipc>
}
  8018ac:	c9                   	leave  
  8018ad:	c3                   	ret    

008018ae <devfile_stat>:
{
  8018ae:	55                   	push   %ebp
  8018af:	89 e5                	mov    %esp,%ebp
  8018b1:	53                   	push   %ebx
  8018b2:	83 ec 04             	sub    $0x4,%esp
  8018b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8018bb:	8b 40 0c             	mov    0xc(%eax),%eax
  8018be:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c8:	b8 05 00 00 00       	mov    $0x5,%eax
  8018cd:	e8 43 ff ff ff       	call   801815 <fsipc>
  8018d2:	85 c0                	test   %eax,%eax
  8018d4:	78 2c                	js     801902 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018d6:	83 ec 08             	sub    $0x8,%esp
  8018d9:	68 00 50 80 00       	push   $0x805000
  8018de:	53                   	push   %ebx
  8018df:	e8 cf ef ff ff       	call   8008b3 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018e4:	a1 80 50 80 00       	mov    0x805080,%eax
  8018e9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018ef:	a1 84 50 80 00       	mov    0x805084,%eax
  8018f4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018fa:	83 c4 10             	add    $0x10,%esp
  8018fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801902:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801905:	c9                   	leave  
  801906:	c3                   	ret    

00801907 <devfile_write>:
{
  801907:	55                   	push   %ebp
  801908:	89 e5                	mov    %esp,%ebp
  80190a:	83 ec 0c             	sub    $0xc,%esp
  80190d:	8b 45 10             	mov    0x10(%ebp),%eax
    	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801910:	8b 55 08             	mov    0x8(%ebp),%edx
  801913:	8b 52 0c             	mov    0xc(%edx),%edx
  801916:	89 15 00 50 80 00    	mov    %edx,0x805000
    	fsipcbuf.write.req_n = n;
  80191c:	a3 04 50 80 00       	mov    %eax,0x805004
    	memmove(fsipcbuf.write.req_buf, buf, n);
  801921:	50                   	push   %eax
  801922:	ff 75 0c             	pushl  0xc(%ebp)
  801925:	68 08 50 80 00       	push   $0x805008
  80192a:	e8 12 f1 ff ff       	call   800a41 <memmove>
    	return fsipc(FSREQ_WRITE, NULL);
  80192f:	ba 00 00 00 00       	mov    $0x0,%edx
  801934:	b8 04 00 00 00       	mov    $0x4,%eax
  801939:	e8 d7 fe ff ff       	call   801815 <fsipc>
}
  80193e:	c9                   	leave  
  80193f:	c3                   	ret    

00801940 <devfile_read>:
{
  801940:	55                   	push   %ebp
  801941:	89 e5                	mov    %esp,%ebp
  801943:	56                   	push   %esi
  801944:	53                   	push   %ebx
  801945:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801948:	8b 45 08             	mov    0x8(%ebp),%eax
  80194b:	8b 40 0c             	mov    0xc(%eax),%eax
  80194e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801953:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801959:	ba 00 00 00 00       	mov    $0x0,%edx
  80195e:	b8 03 00 00 00       	mov    $0x3,%eax
  801963:	e8 ad fe ff ff       	call   801815 <fsipc>
  801968:	89 c3                	mov    %eax,%ebx
  80196a:	85 c0                	test   %eax,%eax
  80196c:	78 1f                	js     80198d <devfile_read+0x4d>
	assert(r <= n);
  80196e:	39 f0                	cmp    %esi,%eax
  801970:	77 24                	ja     801996 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801972:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801977:	7f 33                	jg     8019ac <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801979:	83 ec 04             	sub    $0x4,%esp
  80197c:	50                   	push   %eax
  80197d:	68 00 50 80 00       	push   $0x805000
  801982:	ff 75 0c             	pushl  0xc(%ebp)
  801985:	e8 b7 f0 ff ff       	call   800a41 <memmove>
	return r;
  80198a:	83 c4 10             	add    $0x10,%esp
}
  80198d:	89 d8                	mov    %ebx,%eax
  80198f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801992:	5b                   	pop    %ebx
  801993:	5e                   	pop    %esi
  801994:	5d                   	pop    %ebp
  801995:	c3                   	ret    
	assert(r <= n);
  801996:	68 ac 27 80 00       	push   $0x8027ac
  80199b:	68 b3 27 80 00       	push   $0x8027b3
  8019a0:	6a 7c                	push   $0x7c
  8019a2:	68 c8 27 80 00       	push   $0x8027c8
  8019a7:	e8 85 05 00 00       	call   801f31 <_panic>
	assert(r <= PGSIZE);
  8019ac:	68 d3 27 80 00       	push   $0x8027d3
  8019b1:	68 b3 27 80 00       	push   $0x8027b3
  8019b6:	6a 7d                	push   $0x7d
  8019b8:	68 c8 27 80 00       	push   $0x8027c8
  8019bd:	e8 6f 05 00 00       	call   801f31 <_panic>

008019c2 <open>:
{
  8019c2:	55                   	push   %ebp
  8019c3:	89 e5                	mov    %esp,%ebp
  8019c5:	56                   	push   %esi
  8019c6:	53                   	push   %ebx
  8019c7:	83 ec 1c             	sub    $0x1c,%esp
  8019ca:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8019cd:	56                   	push   %esi
  8019ce:	e8 a9 ee ff ff       	call   80087c <strlen>
  8019d3:	83 c4 10             	add    $0x10,%esp
  8019d6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019db:	7f 6c                	jg     801a49 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8019dd:	83 ec 0c             	sub    $0xc,%esp
  8019e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019e3:	50                   	push   %eax
  8019e4:	e8 c1 f8 ff ff       	call   8012aa <fd_alloc>
  8019e9:	89 c3                	mov    %eax,%ebx
  8019eb:	83 c4 10             	add    $0x10,%esp
  8019ee:	85 c0                	test   %eax,%eax
  8019f0:	78 3c                	js     801a2e <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8019f2:	83 ec 08             	sub    $0x8,%esp
  8019f5:	56                   	push   %esi
  8019f6:	68 00 50 80 00       	push   $0x805000
  8019fb:	e8 b3 ee ff ff       	call   8008b3 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a00:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a03:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a08:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a0b:	b8 01 00 00 00       	mov    $0x1,%eax
  801a10:	e8 00 fe ff ff       	call   801815 <fsipc>
  801a15:	89 c3                	mov    %eax,%ebx
  801a17:	83 c4 10             	add    $0x10,%esp
  801a1a:	85 c0                	test   %eax,%eax
  801a1c:	78 19                	js     801a37 <open+0x75>
	return fd2num(fd);
  801a1e:	83 ec 0c             	sub    $0xc,%esp
  801a21:	ff 75 f4             	pushl  -0xc(%ebp)
  801a24:	e8 5a f8 ff ff       	call   801283 <fd2num>
  801a29:	89 c3                	mov    %eax,%ebx
  801a2b:	83 c4 10             	add    $0x10,%esp
}
  801a2e:	89 d8                	mov    %ebx,%eax
  801a30:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a33:	5b                   	pop    %ebx
  801a34:	5e                   	pop    %esi
  801a35:	5d                   	pop    %ebp
  801a36:	c3                   	ret    
		fd_close(fd, 0);
  801a37:	83 ec 08             	sub    $0x8,%esp
  801a3a:	6a 00                	push   $0x0
  801a3c:	ff 75 f4             	pushl  -0xc(%ebp)
  801a3f:	e8 61 f9 ff ff       	call   8013a5 <fd_close>
		return r;
  801a44:	83 c4 10             	add    $0x10,%esp
  801a47:	eb e5                	jmp    801a2e <open+0x6c>
		return -E_BAD_PATH;
  801a49:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801a4e:	eb de                	jmp    801a2e <open+0x6c>

00801a50 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a50:	55                   	push   %ebp
  801a51:	89 e5                	mov    %esp,%ebp
  801a53:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a56:	ba 00 00 00 00       	mov    $0x0,%edx
  801a5b:	b8 08 00 00 00       	mov    $0x8,%eax
  801a60:	e8 b0 fd ff ff       	call   801815 <fsipc>
}
  801a65:	c9                   	leave  
  801a66:	c3                   	ret    

00801a67 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a67:	55                   	push   %ebp
  801a68:	89 e5                	mov    %esp,%ebp
  801a6a:	56                   	push   %esi
  801a6b:	53                   	push   %ebx
  801a6c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a6f:	83 ec 0c             	sub    $0xc,%esp
  801a72:	ff 75 08             	pushl  0x8(%ebp)
  801a75:	e8 19 f8 ff ff       	call   801293 <fd2data>
  801a7a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a7c:	83 c4 08             	add    $0x8,%esp
  801a7f:	68 df 27 80 00       	push   $0x8027df
  801a84:	53                   	push   %ebx
  801a85:	e8 29 ee ff ff       	call   8008b3 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a8a:	8b 46 04             	mov    0x4(%esi),%eax
  801a8d:	2b 06                	sub    (%esi),%eax
  801a8f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a95:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a9c:	00 00 00 
	stat->st_dev = &devpipe;
  801a9f:	c7 83 88 00 00 00 28 	movl   $0x803028,0x88(%ebx)
  801aa6:	30 80 00 
	return 0;
}
  801aa9:	b8 00 00 00 00       	mov    $0x0,%eax
  801aae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ab1:	5b                   	pop    %ebx
  801ab2:	5e                   	pop    %esi
  801ab3:	5d                   	pop    %ebp
  801ab4:	c3                   	ret    

00801ab5 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ab5:	55                   	push   %ebp
  801ab6:	89 e5                	mov    %esp,%ebp
  801ab8:	53                   	push   %ebx
  801ab9:	83 ec 0c             	sub    $0xc,%esp
  801abc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801abf:	53                   	push   %ebx
  801ac0:	6a 00                	push   $0x0
  801ac2:	e8 6a f2 ff ff       	call   800d31 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ac7:	89 1c 24             	mov    %ebx,(%esp)
  801aca:	e8 c4 f7 ff ff       	call   801293 <fd2data>
  801acf:	83 c4 08             	add    $0x8,%esp
  801ad2:	50                   	push   %eax
  801ad3:	6a 00                	push   $0x0
  801ad5:	e8 57 f2 ff ff       	call   800d31 <sys_page_unmap>
}
  801ada:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801add:	c9                   	leave  
  801ade:	c3                   	ret    

00801adf <_pipeisclosed>:
{
  801adf:	55                   	push   %ebp
  801ae0:	89 e5                	mov    %esp,%ebp
  801ae2:	57                   	push   %edi
  801ae3:	56                   	push   %esi
  801ae4:	53                   	push   %ebx
  801ae5:	83 ec 1c             	sub    $0x1c,%esp
  801ae8:	89 c7                	mov    %eax,%edi
  801aea:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801aec:	a1 04 40 80 00       	mov    0x804004,%eax
  801af1:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801af4:	83 ec 0c             	sub    $0xc,%esp
  801af7:	57                   	push   %edi
  801af8:	e8 0f 05 00 00       	call   80200c <pageref>
  801afd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801b00:	89 34 24             	mov    %esi,(%esp)
  801b03:	e8 04 05 00 00       	call   80200c <pageref>
		nn = thisenv->env_runs;
  801b08:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b0e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b11:	83 c4 10             	add    $0x10,%esp
  801b14:	39 cb                	cmp    %ecx,%ebx
  801b16:	74 1b                	je     801b33 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801b18:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b1b:	75 cf                	jne    801aec <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b1d:	8b 42 58             	mov    0x58(%edx),%eax
  801b20:	6a 01                	push   $0x1
  801b22:	50                   	push   %eax
  801b23:	53                   	push   %ebx
  801b24:	68 e6 27 80 00       	push   $0x8027e6
  801b29:	e8 66 e7 ff ff       	call   800294 <cprintf>
  801b2e:	83 c4 10             	add    $0x10,%esp
  801b31:	eb b9                	jmp    801aec <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801b33:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b36:	0f 94 c0             	sete   %al
  801b39:	0f b6 c0             	movzbl %al,%eax
}
  801b3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b3f:	5b                   	pop    %ebx
  801b40:	5e                   	pop    %esi
  801b41:	5f                   	pop    %edi
  801b42:	5d                   	pop    %ebp
  801b43:	c3                   	ret    

00801b44 <devpipe_write>:
{
  801b44:	55                   	push   %ebp
  801b45:	89 e5                	mov    %esp,%ebp
  801b47:	57                   	push   %edi
  801b48:	56                   	push   %esi
  801b49:	53                   	push   %ebx
  801b4a:	83 ec 28             	sub    $0x28,%esp
  801b4d:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801b50:	56                   	push   %esi
  801b51:	e8 3d f7 ff ff       	call   801293 <fd2data>
  801b56:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b58:	83 c4 10             	add    $0x10,%esp
  801b5b:	bf 00 00 00 00       	mov    $0x0,%edi
  801b60:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b63:	74 4f                	je     801bb4 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b65:	8b 43 04             	mov    0x4(%ebx),%eax
  801b68:	8b 0b                	mov    (%ebx),%ecx
  801b6a:	8d 51 20             	lea    0x20(%ecx),%edx
  801b6d:	39 d0                	cmp    %edx,%eax
  801b6f:	72 14                	jb     801b85 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801b71:	89 da                	mov    %ebx,%edx
  801b73:	89 f0                	mov    %esi,%eax
  801b75:	e8 65 ff ff ff       	call   801adf <_pipeisclosed>
  801b7a:	85 c0                	test   %eax,%eax
  801b7c:	75 3a                	jne    801bb8 <devpipe_write+0x74>
			sys_yield();
  801b7e:	e8 0a f1 ff ff       	call   800c8d <sys_yield>
  801b83:	eb e0                	jmp    801b65 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b88:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b8c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b8f:	89 c2                	mov    %eax,%edx
  801b91:	c1 fa 1f             	sar    $0x1f,%edx
  801b94:	89 d1                	mov    %edx,%ecx
  801b96:	c1 e9 1b             	shr    $0x1b,%ecx
  801b99:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b9c:	83 e2 1f             	and    $0x1f,%edx
  801b9f:	29 ca                	sub    %ecx,%edx
  801ba1:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ba5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ba9:	83 c0 01             	add    $0x1,%eax
  801bac:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801baf:	83 c7 01             	add    $0x1,%edi
  801bb2:	eb ac                	jmp    801b60 <devpipe_write+0x1c>
	return i;
  801bb4:	89 f8                	mov    %edi,%eax
  801bb6:	eb 05                	jmp    801bbd <devpipe_write+0x79>
				return 0;
  801bb8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bc0:	5b                   	pop    %ebx
  801bc1:	5e                   	pop    %esi
  801bc2:	5f                   	pop    %edi
  801bc3:	5d                   	pop    %ebp
  801bc4:	c3                   	ret    

00801bc5 <devpipe_read>:
{
  801bc5:	55                   	push   %ebp
  801bc6:	89 e5                	mov    %esp,%ebp
  801bc8:	57                   	push   %edi
  801bc9:	56                   	push   %esi
  801bca:	53                   	push   %ebx
  801bcb:	83 ec 18             	sub    $0x18,%esp
  801bce:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801bd1:	57                   	push   %edi
  801bd2:	e8 bc f6 ff ff       	call   801293 <fd2data>
  801bd7:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801bd9:	83 c4 10             	add    $0x10,%esp
  801bdc:	be 00 00 00 00       	mov    $0x0,%esi
  801be1:	3b 75 10             	cmp    0x10(%ebp),%esi
  801be4:	74 47                	je     801c2d <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801be6:	8b 03                	mov    (%ebx),%eax
  801be8:	3b 43 04             	cmp    0x4(%ebx),%eax
  801beb:	75 22                	jne    801c0f <devpipe_read+0x4a>
			if (i > 0)
  801bed:	85 f6                	test   %esi,%esi
  801bef:	75 14                	jne    801c05 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801bf1:	89 da                	mov    %ebx,%edx
  801bf3:	89 f8                	mov    %edi,%eax
  801bf5:	e8 e5 fe ff ff       	call   801adf <_pipeisclosed>
  801bfa:	85 c0                	test   %eax,%eax
  801bfc:	75 33                	jne    801c31 <devpipe_read+0x6c>
			sys_yield();
  801bfe:	e8 8a f0 ff ff       	call   800c8d <sys_yield>
  801c03:	eb e1                	jmp    801be6 <devpipe_read+0x21>
				return i;
  801c05:	89 f0                	mov    %esi,%eax
}
  801c07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c0a:	5b                   	pop    %ebx
  801c0b:	5e                   	pop    %esi
  801c0c:	5f                   	pop    %edi
  801c0d:	5d                   	pop    %ebp
  801c0e:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c0f:	99                   	cltd   
  801c10:	c1 ea 1b             	shr    $0x1b,%edx
  801c13:	01 d0                	add    %edx,%eax
  801c15:	83 e0 1f             	and    $0x1f,%eax
  801c18:	29 d0                	sub    %edx,%eax
  801c1a:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801c1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c22:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801c25:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801c28:	83 c6 01             	add    $0x1,%esi
  801c2b:	eb b4                	jmp    801be1 <devpipe_read+0x1c>
	return i;
  801c2d:	89 f0                	mov    %esi,%eax
  801c2f:	eb d6                	jmp    801c07 <devpipe_read+0x42>
				return 0;
  801c31:	b8 00 00 00 00       	mov    $0x0,%eax
  801c36:	eb cf                	jmp    801c07 <devpipe_read+0x42>

00801c38 <pipe>:
{
  801c38:	55                   	push   %ebp
  801c39:	89 e5                	mov    %esp,%ebp
  801c3b:	56                   	push   %esi
  801c3c:	53                   	push   %ebx
  801c3d:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801c40:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c43:	50                   	push   %eax
  801c44:	e8 61 f6 ff ff       	call   8012aa <fd_alloc>
  801c49:	89 c3                	mov    %eax,%ebx
  801c4b:	83 c4 10             	add    $0x10,%esp
  801c4e:	85 c0                	test   %eax,%eax
  801c50:	78 5b                	js     801cad <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c52:	83 ec 04             	sub    $0x4,%esp
  801c55:	68 07 04 00 00       	push   $0x407
  801c5a:	ff 75 f4             	pushl  -0xc(%ebp)
  801c5d:	6a 00                	push   $0x0
  801c5f:	e8 48 f0 ff ff       	call   800cac <sys_page_alloc>
  801c64:	89 c3                	mov    %eax,%ebx
  801c66:	83 c4 10             	add    $0x10,%esp
  801c69:	85 c0                	test   %eax,%eax
  801c6b:	78 40                	js     801cad <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  801c6d:	83 ec 0c             	sub    $0xc,%esp
  801c70:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c73:	50                   	push   %eax
  801c74:	e8 31 f6 ff ff       	call   8012aa <fd_alloc>
  801c79:	89 c3                	mov    %eax,%ebx
  801c7b:	83 c4 10             	add    $0x10,%esp
  801c7e:	85 c0                	test   %eax,%eax
  801c80:	78 1b                	js     801c9d <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c82:	83 ec 04             	sub    $0x4,%esp
  801c85:	68 07 04 00 00       	push   $0x407
  801c8a:	ff 75 f0             	pushl  -0x10(%ebp)
  801c8d:	6a 00                	push   $0x0
  801c8f:	e8 18 f0 ff ff       	call   800cac <sys_page_alloc>
  801c94:	89 c3                	mov    %eax,%ebx
  801c96:	83 c4 10             	add    $0x10,%esp
  801c99:	85 c0                	test   %eax,%eax
  801c9b:	79 19                	jns    801cb6 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  801c9d:	83 ec 08             	sub    $0x8,%esp
  801ca0:	ff 75 f4             	pushl  -0xc(%ebp)
  801ca3:	6a 00                	push   $0x0
  801ca5:	e8 87 f0 ff ff       	call   800d31 <sys_page_unmap>
  801caa:	83 c4 10             	add    $0x10,%esp
}
  801cad:	89 d8                	mov    %ebx,%eax
  801caf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cb2:	5b                   	pop    %ebx
  801cb3:	5e                   	pop    %esi
  801cb4:	5d                   	pop    %ebp
  801cb5:	c3                   	ret    
	va = fd2data(fd0);
  801cb6:	83 ec 0c             	sub    $0xc,%esp
  801cb9:	ff 75 f4             	pushl  -0xc(%ebp)
  801cbc:	e8 d2 f5 ff ff       	call   801293 <fd2data>
  801cc1:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cc3:	83 c4 0c             	add    $0xc,%esp
  801cc6:	68 07 04 00 00       	push   $0x407
  801ccb:	50                   	push   %eax
  801ccc:	6a 00                	push   $0x0
  801cce:	e8 d9 ef ff ff       	call   800cac <sys_page_alloc>
  801cd3:	89 c3                	mov    %eax,%ebx
  801cd5:	83 c4 10             	add    $0x10,%esp
  801cd8:	85 c0                	test   %eax,%eax
  801cda:	0f 88 8c 00 00 00    	js     801d6c <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ce0:	83 ec 0c             	sub    $0xc,%esp
  801ce3:	ff 75 f0             	pushl  -0x10(%ebp)
  801ce6:	e8 a8 f5 ff ff       	call   801293 <fd2data>
  801ceb:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cf2:	50                   	push   %eax
  801cf3:	6a 00                	push   $0x0
  801cf5:	56                   	push   %esi
  801cf6:	6a 00                	push   $0x0
  801cf8:	e8 f2 ef ff ff       	call   800cef <sys_page_map>
  801cfd:	89 c3                	mov    %eax,%ebx
  801cff:	83 c4 20             	add    $0x20,%esp
  801d02:	85 c0                	test   %eax,%eax
  801d04:	78 58                	js     801d5e <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801d06:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d09:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801d0f:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d11:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d14:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801d1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d1e:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801d24:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d26:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d29:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801d30:	83 ec 0c             	sub    $0xc,%esp
  801d33:	ff 75 f4             	pushl  -0xc(%ebp)
  801d36:	e8 48 f5 ff ff       	call   801283 <fd2num>
  801d3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d3e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d40:	83 c4 04             	add    $0x4,%esp
  801d43:	ff 75 f0             	pushl  -0x10(%ebp)
  801d46:	e8 38 f5 ff ff       	call   801283 <fd2num>
  801d4b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d4e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d51:	83 c4 10             	add    $0x10,%esp
  801d54:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d59:	e9 4f ff ff ff       	jmp    801cad <pipe+0x75>
	sys_page_unmap(0, va);
  801d5e:	83 ec 08             	sub    $0x8,%esp
  801d61:	56                   	push   %esi
  801d62:	6a 00                	push   $0x0
  801d64:	e8 c8 ef ff ff       	call   800d31 <sys_page_unmap>
  801d69:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801d6c:	83 ec 08             	sub    $0x8,%esp
  801d6f:	ff 75 f0             	pushl  -0x10(%ebp)
  801d72:	6a 00                	push   $0x0
  801d74:	e8 b8 ef ff ff       	call   800d31 <sys_page_unmap>
  801d79:	83 c4 10             	add    $0x10,%esp
  801d7c:	e9 1c ff ff ff       	jmp    801c9d <pipe+0x65>

00801d81 <pipeisclosed>:
{
  801d81:	55                   	push   %ebp
  801d82:	89 e5                	mov    %esp,%ebp
  801d84:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d87:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d8a:	50                   	push   %eax
  801d8b:	ff 75 08             	pushl  0x8(%ebp)
  801d8e:	e8 66 f5 ff ff       	call   8012f9 <fd_lookup>
  801d93:	83 c4 10             	add    $0x10,%esp
  801d96:	85 c0                	test   %eax,%eax
  801d98:	78 18                	js     801db2 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801d9a:	83 ec 0c             	sub    $0xc,%esp
  801d9d:	ff 75 f4             	pushl  -0xc(%ebp)
  801da0:	e8 ee f4 ff ff       	call   801293 <fd2data>
	return _pipeisclosed(fd, p);
  801da5:	89 c2                	mov    %eax,%edx
  801da7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801daa:	e8 30 fd ff ff       	call   801adf <_pipeisclosed>
  801daf:	83 c4 10             	add    $0x10,%esp
}
  801db2:	c9                   	leave  
  801db3:	c3                   	ret    

00801db4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801db4:	55                   	push   %ebp
  801db5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801db7:	b8 00 00 00 00       	mov    $0x0,%eax
  801dbc:	5d                   	pop    %ebp
  801dbd:	c3                   	ret    

00801dbe <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801dbe:	55                   	push   %ebp
  801dbf:	89 e5                	mov    %esp,%ebp
  801dc1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801dc4:	68 fe 27 80 00       	push   $0x8027fe
  801dc9:	ff 75 0c             	pushl  0xc(%ebp)
  801dcc:	e8 e2 ea ff ff       	call   8008b3 <strcpy>
	return 0;
}
  801dd1:	b8 00 00 00 00       	mov    $0x0,%eax
  801dd6:	c9                   	leave  
  801dd7:	c3                   	ret    

00801dd8 <devcons_write>:
{
  801dd8:	55                   	push   %ebp
  801dd9:	89 e5                	mov    %esp,%ebp
  801ddb:	57                   	push   %edi
  801ddc:	56                   	push   %esi
  801ddd:	53                   	push   %ebx
  801dde:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801de4:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801de9:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801def:	eb 2f                	jmp    801e20 <devcons_write+0x48>
		m = n - tot;
  801df1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801df4:	29 f3                	sub    %esi,%ebx
  801df6:	83 fb 7f             	cmp    $0x7f,%ebx
  801df9:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801dfe:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801e01:	83 ec 04             	sub    $0x4,%esp
  801e04:	53                   	push   %ebx
  801e05:	89 f0                	mov    %esi,%eax
  801e07:	03 45 0c             	add    0xc(%ebp),%eax
  801e0a:	50                   	push   %eax
  801e0b:	57                   	push   %edi
  801e0c:	e8 30 ec ff ff       	call   800a41 <memmove>
		sys_cputs(buf, m);
  801e11:	83 c4 08             	add    $0x8,%esp
  801e14:	53                   	push   %ebx
  801e15:	57                   	push   %edi
  801e16:	e8 d5 ed ff ff       	call   800bf0 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801e1b:	01 de                	add    %ebx,%esi
  801e1d:	83 c4 10             	add    $0x10,%esp
  801e20:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e23:	72 cc                	jb     801df1 <devcons_write+0x19>
}
  801e25:	89 f0                	mov    %esi,%eax
  801e27:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e2a:	5b                   	pop    %ebx
  801e2b:	5e                   	pop    %esi
  801e2c:	5f                   	pop    %edi
  801e2d:	5d                   	pop    %ebp
  801e2e:	c3                   	ret    

00801e2f <devcons_read>:
{
  801e2f:	55                   	push   %ebp
  801e30:	89 e5                	mov    %esp,%ebp
  801e32:	83 ec 08             	sub    $0x8,%esp
  801e35:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801e3a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e3e:	75 07                	jne    801e47 <devcons_read+0x18>
}
  801e40:	c9                   	leave  
  801e41:	c3                   	ret    
		sys_yield();
  801e42:	e8 46 ee ff ff       	call   800c8d <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801e47:	e8 c2 ed ff ff       	call   800c0e <sys_cgetc>
  801e4c:	85 c0                	test   %eax,%eax
  801e4e:	74 f2                	je     801e42 <devcons_read+0x13>
	if (c < 0)
  801e50:	85 c0                	test   %eax,%eax
  801e52:	78 ec                	js     801e40 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801e54:	83 f8 04             	cmp    $0x4,%eax
  801e57:	74 0c                	je     801e65 <devcons_read+0x36>
	*(char*)vbuf = c;
  801e59:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e5c:	88 02                	mov    %al,(%edx)
	return 1;
  801e5e:	b8 01 00 00 00       	mov    $0x1,%eax
  801e63:	eb db                	jmp    801e40 <devcons_read+0x11>
		return 0;
  801e65:	b8 00 00 00 00       	mov    $0x0,%eax
  801e6a:	eb d4                	jmp    801e40 <devcons_read+0x11>

00801e6c <cputchar>:
{
  801e6c:	55                   	push   %ebp
  801e6d:	89 e5                	mov    %esp,%ebp
  801e6f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e72:	8b 45 08             	mov    0x8(%ebp),%eax
  801e75:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801e78:	6a 01                	push   $0x1
  801e7a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e7d:	50                   	push   %eax
  801e7e:	e8 6d ed ff ff       	call   800bf0 <sys_cputs>
}
  801e83:	83 c4 10             	add    $0x10,%esp
  801e86:	c9                   	leave  
  801e87:	c3                   	ret    

00801e88 <getchar>:
{
  801e88:	55                   	push   %ebp
  801e89:	89 e5                	mov    %esp,%ebp
  801e8b:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801e8e:	6a 01                	push   $0x1
  801e90:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e93:	50                   	push   %eax
  801e94:	6a 00                	push   $0x0
  801e96:	e8 cf f6 ff ff       	call   80156a <read>
	if (r < 0)
  801e9b:	83 c4 10             	add    $0x10,%esp
  801e9e:	85 c0                	test   %eax,%eax
  801ea0:	78 08                	js     801eaa <getchar+0x22>
	if (r < 1)
  801ea2:	85 c0                	test   %eax,%eax
  801ea4:	7e 06                	jle    801eac <getchar+0x24>
	return c;
  801ea6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801eaa:	c9                   	leave  
  801eab:	c3                   	ret    
		return -E_EOF;
  801eac:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801eb1:	eb f7                	jmp    801eaa <getchar+0x22>

00801eb3 <iscons>:
{
  801eb3:	55                   	push   %ebp
  801eb4:	89 e5                	mov    %esp,%ebp
  801eb6:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801eb9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ebc:	50                   	push   %eax
  801ebd:	ff 75 08             	pushl  0x8(%ebp)
  801ec0:	e8 34 f4 ff ff       	call   8012f9 <fd_lookup>
  801ec5:	83 c4 10             	add    $0x10,%esp
  801ec8:	85 c0                	test   %eax,%eax
  801eca:	78 11                	js     801edd <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801ecc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ecf:	8b 15 44 30 80 00    	mov    0x803044,%edx
  801ed5:	39 10                	cmp    %edx,(%eax)
  801ed7:	0f 94 c0             	sete   %al
  801eda:	0f b6 c0             	movzbl %al,%eax
}
  801edd:	c9                   	leave  
  801ede:	c3                   	ret    

00801edf <opencons>:
{
  801edf:	55                   	push   %ebp
  801ee0:	89 e5                	mov    %esp,%ebp
  801ee2:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801ee5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ee8:	50                   	push   %eax
  801ee9:	e8 bc f3 ff ff       	call   8012aa <fd_alloc>
  801eee:	83 c4 10             	add    $0x10,%esp
  801ef1:	85 c0                	test   %eax,%eax
  801ef3:	78 3a                	js     801f2f <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ef5:	83 ec 04             	sub    $0x4,%esp
  801ef8:	68 07 04 00 00       	push   $0x407
  801efd:	ff 75 f4             	pushl  -0xc(%ebp)
  801f00:	6a 00                	push   $0x0
  801f02:	e8 a5 ed ff ff       	call   800cac <sys_page_alloc>
  801f07:	83 c4 10             	add    $0x10,%esp
  801f0a:	85 c0                	test   %eax,%eax
  801f0c:	78 21                	js     801f2f <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801f0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f11:	8b 15 44 30 80 00    	mov    0x803044,%edx
  801f17:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f1c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f23:	83 ec 0c             	sub    $0xc,%esp
  801f26:	50                   	push   %eax
  801f27:	e8 57 f3 ff ff       	call   801283 <fd2num>
  801f2c:	83 c4 10             	add    $0x10,%esp
}
  801f2f:	c9                   	leave  
  801f30:	c3                   	ret    

00801f31 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801f31:	55                   	push   %ebp
  801f32:	89 e5                	mov    %esp,%ebp
  801f34:	56                   	push   %esi
  801f35:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801f36:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801f39:	8b 35 08 30 80 00    	mov    0x803008,%esi
  801f3f:	e8 2a ed ff ff       	call   800c6e <sys_getenvid>
  801f44:	83 ec 0c             	sub    $0xc,%esp
  801f47:	ff 75 0c             	pushl  0xc(%ebp)
  801f4a:	ff 75 08             	pushl  0x8(%ebp)
  801f4d:	56                   	push   %esi
  801f4e:	50                   	push   %eax
  801f4f:	68 0c 28 80 00       	push   $0x80280c
  801f54:	e8 3b e3 ff ff       	call   800294 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f59:	83 c4 18             	add    $0x18,%esp
  801f5c:	53                   	push   %ebx
  801f5d:	ff 75 10             	pushl  0x10(%ebp)
  801f60:	e8 de e2 ff ff       	call   800243 <vcprintf>
	cprintf("\n");
  801f65:	c7 04 24 f7 27 80 00 	movl   $0x8027f7,(%esp)
  801f6c:	e8 23 e3 ff ff       	call   800294 <cprintf>
  801f71:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f74:	cc                   	int3   
  801f75:	eb fd                	jmp    801f74 <_panic+0x43>

00801f77 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f77:	55                   	push   %ebp
  801f78:	89 e5                	mov    %esp,%ebp
  801f7a:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f7d:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f84:	74 20                	je     801fa6 <set_pgfault_handler+0x2f>
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
			panic("set_pgfault_handler:sys_page_alloc failed");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f86:	8b 45 08             	mov    0x8(%ebp),%eax
  801f89:	a3 00 60 80 00       	mov    %eax,0x806000
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801f8e:	83 ec 08             	sub    $0x8,%esp
  801f91:	68 e6 1f 80 00       	push   $0x801fe6
  801f96:	6a 00                	push   $0x0
  801f98:	e8 5a ee ff ff       	call   800df7 <sys_env_set_pgfault_upcall>
  801f9d:	83 c4 10             	add    $0x10,%esp
  801fa0:	85 c0                	test   %eax,%eax
  801fa2:	78 2e                	js     801fd2 <set_pgfault_handler+0x5b>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
}
  801fa4:	c9                   	leave  
  801fa5:	c3                   	ret    
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  801fa6:	83 ec 04             	sub    $0x4,%esp
  801fa9:	6a 07                	push   $0x7
  801fab:	68 00 f0 bf ee       	push   $0xeebff000
  801fb0:	6a 00                	push   $0x0
  801fb2:	e8 f5 ec ff ff       	call   800cac <sys_page_alloc>
  801fb7:	83 c4 10             	add    $0x10,%esp
  801fba:	85 c0                	test   %eax,%eax
  801fbc:	79 c8                	jns    801f86 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler:sys_page_alloc failed");
  801fbe:	83 ec 04             	sub    $0x4,%esp
  801fc1:	68 30 28 80 00       	push   $0x802830
  801fc6:	6a 21                	push   $0x21
  801fc8:	68 94 28 80 00       	push   $0x802894
  801fcd:	e8 5f ff ff ff       	call   801f31 <_panic>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  801fd2:	83 ec 04             	sub    $0x4,%esp
  801fd5:	68 5c 28 80 00       	push   $0x80285c
  801fda:	6a 27                	push   $0x27
  801fdc:	68 94 28 80 00       	push   $0x802894
  801fe1:	e8 4b ff ff ff       	call   801f31 <_panic>

00801fe6 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801fe6:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801fe7:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801fec:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801fee:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %eax
  801ff1:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  801ff5:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  801ff8:	89 44 24 30          	mov    %eax,0x30(%esp)
	movl 40(%esp), %ebx
  801ffc:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  802000:	89 18                	mov    %ebx,(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  802002:	83 c4 08             	add    $0x8,%esp
	popal
  802005:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  802006:	83 c4 04             	add    $0x4,%esp
	popfl
  802009:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80200a:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80200b:	c3                   	ret    

0080200c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80200c:	55                   	push   %ebp
  80200d:	89 e5                	mov    %esp,%ebp
  80200f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802012:	89 d0                	mov    %edx,%eax
  802014:	c1 e8 16             	shr    $0x16,%eax
  802017:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80201e:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  802023:	f6 c1 01             	test   $0x1,%cl
  802026:	74 1d                	je     802045 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  802028:	c1 ea 0c             	shr    $0xc,%edx
  80202b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802032:	f6 c2 01             	test   $0x1,%dl
  802035:	74 0e                	je     802045 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802037:	c1 ea 0c             	shr    $0xc,%edx
  80203a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802041:	ef 
  802042:	0f b7 c0             	movzwl %ax,%eax
}
  802045:	5d                   	pop    %ebp
  802046:	c3                   	ret    
  802047:	66 90                	xchg   %ax,%ax
  802049:	66 90                	xchg   %ax,%ax
  80204b:	66 90                	xchg   %ax,%ax
  80204d:	66 90                	xchg   %ax,%ax
  80204f:	90                   	nop

00802050 <__udivdi3>:
  802050:	55                   	push   %ebp
  802051:	57                   	push   %edi
  802052:	56                   	push   %esi
  802053:	53                   	push   %ebx
  802054:	83 ec 1c             	sub    $0x1c,%esp
  802057:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80205b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  80205f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802063:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  802067:	85 d2                	test   %edx,%edx
  802069:	75 35                	jne    8020a0 <__udivdi3+0x50>
  80206b:	39 f3                	cmp    %esi,%ebx
  80206d:	0f 87 bd 00 00 00    	ja     802130 <__udivdi3+0xe0>
  802073:	85 db                	test   %ebx,%ebx
  802075:	89 d9                	mov    %ebx,%ecx
  802077:	75 0b                	jne    802084 <__udivdi3+0x34>
  802079:	b8 01 00 00 00       	mov    $0x1,%eax
  80207e:	31 d2                	xor    %edx,%edx
  802080:	f7 f3                	div    %ebx
  802082:	89 c1                	mov    %eax,%ecx
  802084:	31 d2                	xor    %edx,%edx
  802086:	89 f0                	mov    %esi,%eax
  802088:	f7 f1                	div    %ecx
  80208a:	89 c6                	mov    %eax,%esi
  80208c:	89 e8                	mov    %ebp,%eax
  80208e:	89 f7                	mov    %esi,%edi
  802090:	f7 f1                	div    %ecx
  802092:	89 fa                	mov    %edi,%edx
  802094:	83 c4 1c             	add    $0x1c,%esp
  802097:	5b                   	pop    %ebx
  802098:	5e                   	pop    %esi
  802099:	5f                   	pop    %edi
  80209a:	5d                   	pop    %ebp
  80209b:	c3                   	ret    
  80209c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020a0:	39 f2                	cmp    %esi,%edx
  8020a2:	77 7c                	ja     802120 <__udivdi3+0xd0>
  8020a4:	0f bd fa             	bsr    %edx,%edi
  8020a7:	83 f7 1f             	xor    $0x1f,%edi
  8020aa:	0f 84 98 00 00 00    	je     802148 <__udivdi3+0xf8>
  8020b0:	89 f9                	mov    %edi,%ecx
  8020b2:	b8 20 00 00 00       	mov    $0x20,%eax
  8020b7:	29 f8                	sub    %edi,%eax
  8020b9:	d3 e2                	shl    %cl,%edx
  8020bb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8020bf:	89 c1                	mov    %eax,%ecx
  8020c1:	89 da                	mov    %ebx,%edx
  8020c3:	d3 ea                	shr    %cl,%edx
  8020c5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8020c9:	09 d1                	or     %edx,%ecx
  8020cb:	89 f2                	mov    %esi,%edx
  8020cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020d1:	89 f9                	mov    %edi,%ecx
  8020d3:	d3 e3                	shl    %cl,%ebx
  8020d5:	89 c1                	mov    %eax,%ecx
  8020d7:	d3 ea                	shr    %cl,%edx
  8020d9:	89 f9                	mov    %edi,%ecx
  8020db:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8020df:	d3 e6                	shl    %cl,%esi
  8020e1:	89 eb                	mov    %ebp,%ebx
  8020e3:	89 c1                	mov    %eax,%ecx
  8020e5:	d3 eb                	shr    %cl,%ebx
  8020e7:	09 de                	or     %ebx,%esi
  8020e9:	89 f0                	mov    %esi,%eax
  8020eb:	f7 74 24 08          	divl   0x8(%esp)
  8020ef:	89 d6                	mov    %edx,%esi
  8020f1:	89 c3                	mov    %eax,%ebx
  8020f3:	f7 64 24 0c          	mull   0xc(%esp)
  8020f7:	39 d6                	cmp    %edx,%esi
  8020f9:	72 0c                	jb     802107 <__udivdi3+0xb7>
  8020fb:	89 f9                	mov    %edi,%ecx
  8020fd:	d3 e5                	shl    %cl,%ebp
  8020ff:	39 c5                	cmp    %eax,%ebp
  802101:	73 5d                	jae    802160 <__udivdi3+0x110>
  802103:	39 d6                	cmp    %edx,%esi
  802105:	75 59                	jne    802160 <__udivdi3+0x110>
  802107:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80210a:	31 ff                	xor    %edi,%edi
  80210c:	89 fa                	mov    %edi,%edx
  80210e:	83 c4 1c             	add    $0x1c,%esp
  802111:	5b                   	pop    %ebx
  802112:	5e                   	pop    %esi
  802113:	5f                   	pop    %edi
  802114:	5d                   	pop    %ebp
  802115:	c3                   	ret    
  802116:	8d 76 00             	lea    0x0(%esi),%esi
  802119:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802120:	31 ff                	xor    %edi,%edi
  802122:	31 c0                	xor    %eax,%eax
  802124:	89 fa                	mov    %edi,%edx
  802126:	83 c4 1c             	add    $0x1c,%esp
  802129:	5b                   	pop    %ebx
  80212a:	5e                   	pop    %esi
  80212b:	5f                   	pop    %edi
  80212c:	5d                   	pop    %ebp
  80212d:	c3                   	ret    
  80212e:	66 90                	xchg   %ax,%ax
  802130:	31 ff                	xor    %edi,%edi
  802132:	89 e8                	mov    %ebp,%eax
  802134:	89 f2                	mov    %esi,%edx
  802136:	f7 f3                	div    %ebx
  802138:	89 fa                	mov    %edi,%edx
  80213a:	83 c4 1c             	add    $0x1c,%esp
  80213d:	5b                   	pop    %ebx
  80213e:	5e                   	pop    %esi
  80213f:	5f                   	pop    %edi
  802140:	5d                   	pop    %ebp
  802141:	c3                   	ret    
  802142:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802148:	39 f2                	cmp    %esi,%edx
  80214a:	72 06                	jb     802152 <__udivdi3+0x102>
  80214c:	31 c0                	xor    %eax,%eax
  80214e:	39 eb                	cmp    %ebp,%ebx
  802150:	77 d2                	ja     802124 <__udivdi3+0xd4>
  802152:	b8 01 00 00 00       	mov    $0x1,%eax
  802157:	eb cb                	jmp    802124 <__udivdi3+0xd4>
  802159:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802160:	89 d8                	mov    %ebx,%eax
  802162:	31 ff                	xor    %edi,%edi
  802164:	eb be                	jmp    802124 <__udivdi3+0xd4>
  802166:	66 90                	xchg   %ax,%ax
  802168:	66 90                	xchg   %ax,%ax
  80216a:	66 90                	xchg   %ax,%ax
  80216c:	66 90                	xchg   %ax,%ax
  80216e:	66 90                	xchg   %ax,%ax

00802170 <__umoddi3>:
  802170:	55                   	push   %ebp
  802171:	57                   	push   %edi
  802172:	56                   	push   %esi
  802173:	53                   	push   %ebx
  802174:	83 ec 1c             	sub    $0x1c,%esp
  802177:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80217b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80217f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802183:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802187:	85 ed                	test   %ebp,%ebp
  802189:	89 f0                	mov    %esi,%eax
  80218b:	89 da                	mov    %ebx,%edx
  80218d:	75 19                	jne    8021a8 <__umoddi3+0x38>
  80218f:	39 df                	cmp    %ebx,%edi
  802191:	0f 86 b1 00 00 00    	jbe    802248 <__umoddi3+0xd8>
  802197:	f7 f7                	div    %edi
  802199:	89 d0                	mov    %edx,%eax
  80219b:	31 d2                	xor    %edx,%edx
  80219d:	83 c4 1c             	add    $0x1c,%esp
  8021a0:	5b                   	pop    %ebx
  8021a1:	5e                   	pop    %esi
  8021a2:	5f                   	pop    %edi
  8021a3:	5d                   	pop    %ebp
  8021a4:	c3                   	ret    
  8021a5:	8d 76 00             	lea    0x0(%esi),%esi
  8021a8:	39 dd                	cmp    %ebx,%ebp
  8021aa:	77 f1                	ja     80219d <__umoddi3+0x2d>
  8021ac:	0f bd cd             	bsr    %ebp,%ecx
  8021af:	83 f1 1f             	xor    $0x1f,%ecx
  8021b2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8021b6:	0f 84 b4 00 00 00    	je     802270 <__umoddi3+0x100>
  8021bc:	b8 20 00 00 00       	mov    $0x20,%eax
  8021c1:	89 c2                	mov    %eax,%edx
  8021c3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021c7:	29 c2                	sub    %eax,%edx
  8021c9:	89 c1                	mov    %eax,%ecx
  8021cb:	89 f8                	mov    %edi,%eax
  8021cd:	d3 e5                	shl    %cl,%ebp
  8021cf:	89 d1                	mov    %edx,%ecx
  8021d1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8021d5:	d3 e8                	shr    %cl,%eax
  8021d7:	09 c5                	or     %eax,%ebp
  8021d9:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021dd:	89 c1                	mov    %eax,%ecx
  8021df:	d3 e7                	shl    %cl,%edi
  8021e1:	89 d1                	mov    %edx,%ecx
  8021e3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8021e7:	89 df                	mov    %ebx,%edi
  8021e9:	d3 ef                	shr    %cl,%edi
  8021eb:	89 c1                	mov    %eax,%ecx
  8021ed:	89 f0                	mov    %esi,%eax
  8021ef:	d3 e3                	shl    %cl,%ebx
  8021f1:	89 d1                	mov    %edx,%ecx
  8021f3:	89 fa                	mov    %edi,%edx
  8021f5:	d3 e8                	shr    %cl,%eax
  8021f7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8021fc:	09 d8                	or     %ebx,%eax
  8021fe:	f7 f5                	div    %ebp
  802200:	d3 e6                	shl    %cl,%esi
  802202:	89 d1                	mov    %edx,%ecx
  802204:	f7 64 24 08          	mull   0x8(%esp)
  802208:	39 d1                	cmp    %edx,%ecx
  80220a:	89 c3                	mov    %eax,%ebx
  80220c:	89 d7                	mov    %edx,%edi
  80220e:	72 06                	jb     802216 <__umoddi3+0xa6>
  802210:	75 0e                	jne    802220 <__umoddi3+0xb0>
  802212:	39 c6                	cmp    %eax,%esi
  802214:	73 0a                	jae    802220 <__umoddi3+0xb0>
  802216:	2b 44 24 08          	sub    0x8(%esp),%eax
  80221a:	19 ea                	sbb    %ebp,%edx
  80221c:	89 d7                	mov    %edx,%edi
  80221e:	89 c3                	mov    %eax,%ebx
  802220:	89 ca                	mov    %ecx,%edx
  802222:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  802227:	29 de                	sub    %ebx,%esi
  802229:	19 fa                	sbb    %edi,%edx
  80222b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80222f:	89 d0                	mov    %edx,%eax
  802231:	d3 e0                	shl    %cl,%eax
  802233:	89 d9                	mov    %ebx,%ecx
  802235:	d3 ee                	shr    %cl,%esi
  802237:	d3 ea                	shr    %cl,%edx
  802239:	09 f0                	or     %esi,%eax
  80223b:	83 c4 1c             	add    $0x1c,%esp
  80223e:	5b                   	pop    %ebx
  80223f:	5e                   	pop    %esi
  802240:	5f                   	pop    %edi
  802241:	5d                   	pop    %ebp
  802242:	c3                   	ret    
  802243:	90                   	nop
  802244:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802248:	85 ff                	test   %edi,%edi
  80224a:	89 f9                	mov    %edi,%ecx
  80224c:	75 0b                	jne    802259 <__umoddi3+0xe9>
  80224e:	b8 01 00 00 00       	mov    $0x1,%eax
  802253:	31 d2                	xor    %edx,%edx
  802255:	f7 f7                	div    %edi
  802257:	89 c1                	mov    %eax,%ecx
  802259:	89 d8                	mov    %ebx,%eax
  80225b:	31 d2                	xor    %edx,%edx
  80225d:	f7 f1                	div    %ecx
  80225f:	89 f0                	mov    %esi,%eax
  802261:	f7 f1                	div    %ecx
  802263:	e9 31 ff ff ff       	jmp    802199 <__umoddi3+0x29>
  802268:	90                   	nop
  802269:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802270:	39 dd                	cmp    %ebx,%ebp
  802272:	72 08                	jb     80227c <__umoddi3+0x10c>
  802274:	39 f7                	cmp    %esi,%edi
  802276:	0f 87 21 ff ff ff    	ja     80219d <__umoddi3+0x2d>
  80227c:	89 da                	mov    %ebx,%edx
  80227e:	89 f0                	mov    %esi,%eax
  802280:	29 f8                	sub    %edi,%eax
  802282:	19 ea                	sbb    %ebp,%edx
  802284:	e9 14 ff ff ff       	jmp    80219d <__umoddi3+0x2d>
