
obj/user/testpiperace.debug：     文件格式 elf32-i386


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
  80002c:	e8 bf 01 00 00       	call   8001f0 <libmain>
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
  800038:	83 ec 1c             	sub    $0x1c,%esp
	int p[2], r, pid, i, max;
	void *va;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for dup race...\n");
  80003b:	68 e0 22 80 00       	push   $0x8022e0
  800040:	e8 e6 02 00 00       	call   80032b <cprintf>
	if ((r = pipe(p)) < 0)
  800045:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800048:	89 04 24             	mov    %eax,(%esp)
  80004b:	e8 ba 1c 00 00       	call   801d0a <pipe>
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	78 5b                	js     8000b2 <umain+0x7f>
		panic("pipe: %e", r);
	max = 200;
	if ((r = fork()) < 0)
  800057:	e8 da 0f 00 00       	call   801036 <fork>
  80005c:	89 c6                	mov    %eax,%esi
  80005e:	85 c0                	test   %eax,%eax
  800060:	78 62                	js     8000c4 <umain+0x91>
		panic("fork: %e", r);
	if (r == 0) {
  800062:	85 c0                	test   %eax,%eax
  800064:	74 70                	je     8000d6 <umain+0xa3>
		}
		// do something to be not runnable besides exiting
		ipc_recv(0,0,0);
	}
	pid = r;
	cprintf("pid is %d\n", pid);
  800066:	83 ec 08             	sub    $0x8,%esp
  800069:	56                   	push   %esi
  80006a:	68 31 23 80 00       	push   $0x802331
  80006f:	e8 b7 02 00 00       	call   80032b <cprintf>
	va = 0;
	kid = &envs[ENVX(pid)];
  800074:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	cprintf("kid is %d\n", kid-envs);
  80007a:	83 c4 08             	add    $0x8,%esp
  80007d:	6b c6 7c             	imul   $0x7c,%esi,%eax
  800080:	c1 f8 02             	sar    $0x2,%eax
  800083:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
  800089:	50                   	push   %eax
  80008a:	68 3c 23 80 00       	push   $0x80233c
  80008f:	e8 97 02 00 00       	call   80032b <cprintf>
	dup(p[0], 10);
  800094:	83 c4 08             	add    $0x8,%esp
  800097:	6a 0a                	push   $0xa
  800099:	ff 75 f0             	pushl  -0x10(%ebp)
  80009c:	e8 74 14 00 00       	call   801515 <dup>
	while (kid->env_status == ENV_RUNNABLE)
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	6b de 7c             	imul   $0x7c,%esi,%ebx
  8000a7:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8000ad:	e9 92 00 00 00       	jmp    800144 <umain+0x111>
		panic("pipe: %e", r);
  8000b2:	50                   	push   %eax
  8000b3:	68 f9 22 80 00       	push   $0x8022f9
  8000b8:	6a 0d                	push   $0xd
  8000ba:	68 02 23 80 00       	push   $0x802302
  8000bf:	e8 8c 01 00 00       	call   800250 <_panic>
		panic("fork: %e", r);
  8000c4:	50                   	push   %eax
  8000c5:	68 79 27 80 00       	push   $0x802779
  8000ca:	6a 10                	push   $0x10
  8000cc:	68 02 23 80 00       	push   $0x802302
  8000d1:	e8 7a 01 00 00       	call   800250 <_panic>
		close(p[1]);
  8000d6:	83 ec 0c             	sub    $0xc,%esp
  8000d9:	ff 75 f4             	pushl  -0xc(%ebp)
  8000dc:	e8 e4 13 00 00       	call   8014c5 <close>
  8000e1:	83 c4 10             	add    $0x10,%esp
  8000e4:	bb c8 00 00 00       	mov    $0xc8,%ebx
  8000e9:	eb 0a                	jmp    8000f5 <umain+0xc2>
			sys_yield();
  8000eb:	e8 34 0c 00 00       	call   800d24 <sys_yield>
		for (i=0; i<max; i++) {
  8000f0:	83 eb 01             	sub    $0x1,%ebx
  8000f3:	74 29                	je     80011e <umain+0xeb>
			if(pipeisclosed(p[0])){
  8000f5:	83 ec 0c             	sub    $0xc,%esp
  8000f8:	ff 75 f0             	pushl  -0x10(%ebp)
  8000fb:	e8 53 1d 00 00       	call   801e53 <pipeisclosed>
  800100:	83 c4 10             	add    $0x10,%esp
  800103:	85 c0                	test   %eax,%eax
  800105:	74 e4                	je     8000eb <umain+0xb8>
				cprintf("RACE: pipe appears closed\n");
  800107:	83 ec 0c             	sub    $0xc,%esp
  80010a:	68 16 23 80 00       	push   $0x802316
  80010f:	e8 17 02 00 00       	call   80032b <cprintf>
				exit();
  800114:	e8 1d 01 00 00       	call   800236 <exit>
  800119:	83 c4 10             	add    $0x10,%esp
  80011c:	eb cd                	jmp    8000eb <umain+0xb8>
		ipc_recv(0,0,0);
  80011e:	83 ec 04             	sub    $0x4,%esp
  800121:	6a 00                	push   $0x0
  800123:	6a 00                	push   $0x0
  800125:	6a 00                	push   $0x0
  800127:	e8 fa 10 00 00       	call   801226 <ipc_recv>
  80012c:	83 c4 10             	add    $0x10,%esp
  80012f:	e9 32 ff ff ff       	jmp    800066 <umain+0x33>
		dup(p[0], 10);
  800134:	83 ec 08             	sub    $0x8,%esp
  800137:	6a 0a                	push   $0xa
  800139:	ff 75 f0             	pushl  -0x10(%ebp)
  80013c:	e8 d4 13 00 00       	call   801515 <dup>
  800141:	83 c4 10             	add    $0x10,%esp
	while (kid->env_status == ENV_RUNNABLE)
  800144:	8b 53 54             	mov    0x54(%ebx),%edx
  800147:	83 fa 02             	cmp    $0x2,%edx
  80014a:	74 e8                	je     800134 <umain+0x101>

	cprintf("child done with loop\n");
  80014c:	83 ec 0c             	sub    $0xc,%esp
  80014f:	68 47 23 80 00       	push   $0x802347
  800154:	e8 d2 01 00 00       	call   80032b <cprintf>
	if (pipeisclosed(p[0]))
  800159:	83 c4 04             	add    $0x4,%esp
  80015c:	ff 75 f0             	pushl  -0x10(%ebp)
  80015f:	e8 ef 1c 00 00       	call   801e53 <pipeisclosed>
  800164:	83 c4 10             	add    $0x10,%esp
  800167:	85 c0                	test   %eax,%eax
  800169:	75 48                	jne    8001b3 <umain+0x180>
		panic("somehow the other end of p[0] got closed!");
	if ((r = fd_lookup(p[0], &fd)) < 0)
  80016b:	83 ec 08             	sub    $0x8,%esp
  80016e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800171:	50                   	push   %eax
  800172:	ff 75 f0             	pushl  -0x10(%ebp)
  800175:	e8 16 12 00 00       	call   801390 <fd_lookup>
  80017a:	83 c4 10             	add    $0x10,%esp
  80017d:	85 c0                	test   %eax,%eax
  80017f:	78 46                	js     8001c7 <umain+0x194>
		panic("cannot look up p[0]: %e", r);
	va = fd2data(fd);
  800181:	83 ec 0c             	sub    $0xc,%esp
  800184:	ff 75 ec             	pushl  -0x14(%ebp)
  800187:	e8 9e 11 00 00       	call   80132a <fd2data>
	if (pageref(va) != 3+1)
  80018c:	89 04 24             	mov    %eax,(%esp)
  80018f:	e8 6a 19 00 00       	call   801afe <pageref>
  800194:	83 c4 10             	add    $0x10,%esp
  800197:	83 f8 04             	cmp    $0x4,%eax
  80019a:	74 3d                	je     8001d9 <umain+0x1a6>
		cprintf("\nchild detected race\n");
  80019c:	83 ec 0c             	sub    $0xc,%esp
  80019f:	68 75 23 80 00       	push   $0x802375
  8001a4:	e8 82 01 00 00       	call   80032b <cprintf>
  8001a9:	83 c4 10             	add    $0x10,%esp
	else
		cprintf("\nrace didn't happen\n", max);
}
  8001ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001af:	5b                   	pop    %ebx
  8001b0:	5e                   	pop    %esi
  8001b1:	5d                   	pop    %ebp
  8001b2:	c3                   	ret    
		panic("somehow the other end of p[0] got closed!");
  8001b3:	83 ec 04             	sub    $0x4,%esp
  8001b6:	68 a0 23 80 00       	push   $0x8023a0
  8001bb:	6a 3a                	push   $0x3a
  8001bd:	68 02 23 80 00       	push   $0x802302
  8001c2:	e8 89 00 00 00       	call   800250 <_panic>
		panic("cannot look up p[0]: %e", r);
  8001c7:	50                   	push   %eax
  8001c8:	68 5d 23 80 00       	push   $0x80235d
  8001cd:	6a 3c                	push   $0x3c
  8001cf:	68 02 23 80 00       	push   $0x802302
  8001d4:	e8 77 00 00 00       	call   800250 <_panic>
		cprintf("\nrace didn't happen\n", max);
  8001d9:	83 ec 08             	sub    $0x8,%esp
  8001dc:	68 c8 00 00 00       	push   $0xc8
  8001e1:	68 8b 23 80 00       	push   $0x80238b
  8001e6:	e8 40 01 00 00       	call   80032b <cprintf>
  8001eb:	83 c4 10             	add    $0x10,%esp
}
  8001ee:	eb bc                	jmp    8001ac <umain+0x179>

008001f0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	56                   	push   %esi
  8001f4:	53                   	push   %ebx
  8001f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001f8:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  8001fb:	e8 05 0b 00 00       	call   800d05 <sys_getenvid>
	thisenv = envs + ENVX(envid); 
  800200:	25 ff 03 00 00       	and    $0x3ff,%eax
  800205:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800208:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80020d:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800212:	85 db                	test   %ebx,%ebx
  800214:	7e 07                	jle    80021d <libmain+0x2d>
		binaryname = argv[0];
  800216:	8b 06                	mov    (%esi),%eax
  800218:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80021d:	83 ec 08             	sub    $0x8,%esp
  800220:	56                   	push   %esi
  800221:	53                   	push   %ebx
  800222:	e8 0c fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800227:	e8 0a 00 00 00       	call   800236 <exit>
}
  80022c:	83 c4 10             	add    $0x10,%esp
  80022f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800232:	5b                   	pop    %ebx
  800233:	5e                   	pop    %esi
  800234:	5d                   	pop    %ebp
  800235:	c3                   	ret    

00800236 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80023c:	e8 af 12 00 00       	call   8014f0 <close_all>
	sys_env_destroy(0);
  800241:	83 ec 0c             	sub    $0xc,%esp
  800244:	6a 00                	push   $0x0
  800246:	e8 79 0a 00 00       	call   800cc4 <sys_env_destroy>
}
  80024b:	83 c4 10             	add    $0x10,%esp
  80024e:	c9                   	leave  
  80024f:	c3                   	ret    

00800250 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	56                   	push   %esi
  800254:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800255:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800258:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80025e:	e8 a2 0a 00 00       	call   800d05 <sys_getenvid>
  800263:	83 ec 0c             	sub    $0xc,%esp
  800266:	ff 75 0c             	pushl  0xc(%ebp)
  800269:	ff 75 08             	pushl  0x8(%ebp)
  80026c:	56                   	push   %esi
  80026d:	50                   	push   %eax
  80026e:	68 d4 23 80 00       	push   $0x8023d4
  800273:	e8 b3 00 00 00       	call   80032b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800278:	83 c4 18             	add    $0x18,%esp
  80027b:	53                   	push   %ebx
  80027c:	ff 75 10             	pushl  0x10(%ebp)
  80027f:	e8 56 00 00 00       	call   8002da <vcprintf>
	cprintf("\n");
  800284:	c7 04 24 f7 22 80 00 	movl   $0x8022f7,(%esp)
  80028b:	e8 9b 00 00 00       	call   80032b <cprintf>
  800290:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800293:	cc                   	int3   
  800294:	eb fd                	jmp    800293 <_panic+0x43>

00800296 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800296:	55                   	push   %ebp
  800297:	89 e5                	mov    %esp,%ebp
  800299:	53                   	push   %ebx
  80029a:	83 ec 04             	sub    $0x4,%esp
  80029d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002a0:	8b 13                	mov    (%ebx),%edx
  8002a2:	8d 42 01             	lea    0x1(%edx),%eax
  8002a5:	89 03                	mov    %eax,(%ebx)
  8002a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002aa:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002ae:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002b3:	74 09                	je     8002be <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8002b5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002bc:	c9                   	leave  
  8002bd:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8002be:	83 ec 08             	sub    $0x8,%esp
  8002c1:	68 ff 00 00 00       	push   $0xff
  8002c6:	8d 43 08             	lea    0x8(%ebx),%eax
  8002c9:	50                   	push   %eax
  8002ca:	e8 b8 09 00 00       	call   800c87 <sys_cputs>
		b->idx = 0;
  8002cf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002d5:	83 c4 10             	add    $0x10,%esp
  8002d8:	eb db                	jmp    8002b5 <putch+0x1f>

008002da <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002da:	55                   	push   %ebp
  8002db:	89 e5                	mov    %esp,%ebp
  8002dd:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002e3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002ea:	00 00 00 
	b.cnt = 0;
  8002ed:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002f4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002f7:	ff 75 0c             	pushl  0xc(%ebp)
  8002fa:	ff 75 08             	pushl  0x8(%ebp)
  8002fd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800303:	50                   	push   %eax
  800304:	68 96 02 80 00       	push   $0x800296
  800309:	e8 1a 01 00 00       	call   800428 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80030e:	83 c4 08             	add    $0x8,%esp
  800311:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800317:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80031d:	50                   	push   %eax
  80031e:	e8 64 09 00 00       	call   800c87 <sys_cputs>

	return b.cnt;
}
  800323:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800329:	c9                   	leave  
  80032a:	c3                   	ret    

0080032b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80032b:	55                   	push   %ebp
  80032c:	89 e5                	mov    %esp,%ebp
  80032e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800331:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800334:	50                   	push   %eax
  800335:	ff 75 08             	pushl  0x8(%ebp)
  800338:	e8 9d ff ff ff       	call   8002da <vcprintf>
	va_end(ap);

	return cnt;
}
  80033d:	c9                   	leave  
  80033e:	c3                   	ret    

0080033f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80033f:	55                   	push   %ebp
  800340:	89 e5                	mov    %esp,%ebp
  800342:	57                   	push   %edi
  800343:	56                   	push   %esi
  800344:	53                   	push   %ebx
  800345:	83 ec 1c             	sub    $0x1c,%esp
  800348:	89 c7                	mov    %eax,%edi
  80034a:	89 d6                	mov    %edx,%esi
  80034c:	8b 45 08             	mov    0x8(%ebp),%eax
  80034f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800352:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800355:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800358:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80035b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800360:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800363:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800366:	39 d3                	cmp    %edx,%ebx
  800368:	72 05                	jb     80036f <printnum+0x30>
  80036a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80036d:	77 7a                	ja     8003e9 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80036f:	83 ec 0c             	sub    $0xc,%esp
  800372:	ff 75 18             	pushl  0x18(%ebp)
  800375:	8b 45 14             	mov    0x14(%ebp),%eax
  800378:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80037b:	53                   	push   %ebx
  80037c:	ff 75 10             	pushl  0x10(%ebp)
  80037f:	83 ec 08             	sub    $0x8,%esp
  800382:	ff 75 e4             	pushl  -0x1c(%ebp)
  800385:	ff 75 e0             	pushl  -0x20(%ebp)
  800388:	ff 75 dc             	pushl  -0x24(%ebp)
  80038b:	ff 75 d8             	pushl  -0x28(%ebp)
  80038e:	e8 0d 1d 00 00       	call   8020a0 <__udivdi3>
  800393:	83 c4 18             	add    $0x18,%esp
  800396:	52                   	push   %edx
  800397:	50                   	push   %eax
  800398:	89 f2                	mov    %esi,%edx
  80039a:	89 f8                	mov    %edi,%eax
  80039c:	e8 9e ff ff ff       	call   80033f <printnum>
  8003a1:	83 c4 20             	add    $0x20,%esp
  8003a4:	eb 13                	jmp    8003b9 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003a6:	83 ec 08             	sub    $0x8,%esp
  8003a9:	56                   	push   %esi
  8003aa:	ff 75 18             	pushl  0x18(%ebp)
  8003ad:	ff d7                	call   *%edi
  8003af:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8003b2:	83 eb 01             	sub    $0x1,%ebx
  8003b5:	85 db                	test   %ebx,%ebx
  8003b7:	7f ed                	jg     8003a6 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003b9:	83 ec 08             	sub    $0x8,%esp
  8003bc:	56                   	push   %esi
  8003bd:	83 ec 04             	sub    $0x4,%esp
  8003c0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003c3:	ff 75 e0             	pushl  -0x20(%ebp)
  8003c6:	ff 75 dc             	pushl  -0x24(%ebp)
  8003c9:	ff 75 d8             	pushl  -0x28(%ebp)
  8003cc:	e8 ef 1d 00 00       	call   8021c0 <__umoddi3>
  8003d1:	83 c4 14             	add    $0x14,%esp
  8003d4:	0f be 80 f7 23 80 00 	movsbl 0x8023f7(%eax),%eax
  8003db:	50                   	push   %eax
  8003dc:	ff d7                	call   *%edi
}
  8003de:	83 c4 10             	add    $0x10,%esp
  8003e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003e4:	5b                   	pop    %ebx
  8003e5:	5e                   	pop    %esi
  8003e6:	5f                   	pop    %edi
  8003e7:	5d                   	pop    %ebp
  8003e8:	c3                   	ret    
  8003e9:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003ec:	eb c4                	jmp    8003b2 <printnum+0x73>

008003ee <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ee:	55                   	push   %ebp
  8003ef:	89 e5                	mov    %esp,%ebp
  8003f1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003f4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003f8:	8b 10                	mov    (%eax),%edx
  8003fa:	3b 50 04             	cmp    0x4(%eax),%edx
  8003fd:	73 0a                	jae    800409 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003ff:	8d 4a 01             	lea    0x1(%edx),%ecx
  800402:	89 08                	mov    %ecx,(%eax)
  800404:	8b 45 08             	mov    0x8(%ebp),%eax
  800407:	88 02                	mov    %al,(%edx)
}
  800409:	5d                   	pop    %ebp
  80040a:	c3                   	ret    

0080040b <printfmt>:
{
  80040b:	55                   	push   %ebp
  80040c:	89 e5                	mov    %esp,%ebp
  80040e:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800411:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800414:	50                   	push   %eax
  800415:	ff 75 10             	pushl  0x10(%ebp)
  800418:	ff 75 0c             	pushl  0xc(%ebp)
  80041b:	ff 75 08             	pushl  0x8(%ebp)
  80041e:	e8 05 00 00 00       	call   800428 <vprintfmt>
}
  800423:	83 c4 10             	add    $0x10,%esp
  800426:	c9                   	leave  
  800427:	c3                   	ret    

00800428 <vprintfmt>:
{
  800428:	55                   	push   %ebp
  800429:	89 e5                	mov    %esp,%ebp
  80042b:	57                   	push   %edi
  80042c:	56                   	push   %esi
  80042d:	53                   	push   %ebx
  80042e:	83 ec 2c             	sub    $0x2c,%esp
  800431:	8b 75 08             	mov    0x8(%ebp),%esi
  800434:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800437:	8b 7d 10             	mov    0x10(%ebp),%edi
  80043a:	e9 c1 03 00 00       	jmp    800800 <vprintfmt+0x3d8>
		padc = ' ';
  80043f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800443:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  80044a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800451:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800458:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80045d:	8d 47 01             	lea    0x1(%edi),%eax
  800460:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800463:	0f b6 17             	movzbl (%edi),%edx
  800466:	8d 42 dd             	lea    -0x23(%edx),%eax
  800469:	3c 55                	cmp    $0x55,%al
  80046b:	0f 87 12 04 00 00    	ja     800883 <vprintfmt+0x45b>
  800471:	0f b6 c0             	movzbl %al,%eax
  800474:	ff 24 85 40 25 80 00 	jmp    *0x802540(,%eax,4)
  80047b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80047e:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800482:	eb d9                	jmp    80045d <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800484:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800487:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80048b:	eb d0                	jmp    80045d <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80048d:	0f b6 d2             	movzbl %dl,%edx
  800490:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800493:	b8 00 00 00 00       	mov    $0x0,%eax
  800498:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80049b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80049e:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8004a2:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8004a5:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8004a8:	83 f9 09             	cmp    $0x9,%ecx
  8004ab:	77 55                	ja     800502 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  8004ad:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8004b0:	eb e9                	jmp    80049b <vprintfmt+0x73>
			precision = va_arg(ap, int);
  8004b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b5:	8b 00                	mov    (%eax),%eax
  8004b7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bd:	8d 40 04             	lea    0x4(%eax),%eax
  8004c0:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8004c6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004ca:	79 91                	jns    80045d <vprintfmt+0x35>
				width = precision, precision = -1;
  8004cc:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004cf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004d9:	eb 82                	jmp    80045d <vprintfmt+0x35>
  8004db:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004de:	85 c0                	test   %eax,%eax
  8004e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e5:	0f 49 d0             	cmovns %eax,%edx
  8004e8:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ee:	e9 6a ff ff ff       	jmp    80045d <vprintfmt+0x35>
  8004f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8004f6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004fd:	e9 5b ff ff ff       	jmp    80045d <vprintfmt+0x35>
  800502:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800505:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800508:	eb bc                	jmp    8004c6 <vprintfmt+0x9e>
			lflag++;
  80050a:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80050d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800510:	e9 48 ff ff ff       	jmp    80045d <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  800515:	8b 45 14             	mov    0x14(%ebp),%eax
  800518:	8d 78 04             	lea    0x4(%eax),%edi
  80051b:	83 ec 08             	sub    $0x8,%esp
  80051e:	53                   	push   %ebx
  80051f:	ff 30                	pushl  (%eax)
  800521:	ff d6                	call   *%esi
			break;
  800523:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800526:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800529:	e9 cf 02 00 00       	jmp    8007fd <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  80052e:	8b 45 14             	mov    0x14(%ebp),%eax
  800531:	8d 78 04             	lea    0x4(%eax),%edi
  800534:	8b 00                	mov    (%eax),%eax
  800536:	99                   	cltd   
  800537:	31 d0                	xor    %edx,%eax
  800539:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80053b:	83 f8 0f             	cmp    $0xf,%eax
  80053e:	7f 23                	jg     800563 <vprintfmt+0x13b>
  800540:	8b 14 85 a0 26 80 00 	mov    0x8026a0(,%eax,4),%edx
  800547:	85 d2                	test   %edx,%edx
  800549:	74 18                	je     800563 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  80054b:	52                   	push   %edx
  80054c:	68 85 28 80 00       	push   $0x802885
  800551:	53                   	push   %ebx
  800552:	56                   	push   %esi
  800553:	e8 b3 fe ff ff       	call   80040b <printfmt>
  800558:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80055b:	89 7d 14             	mov    %edi,0x14(%ebp)
  80055e:	e9 9a 02 00 00       	jmp    8007fd <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  800563:	50                   	push   %eax
  800564:	68 0f 24 80 00       	push   $0x80240f
  800569:	53                   	push   %ebx
  80056a:	56                   	push   %esi
  80056b:	e8 9b fe ff ff       	call   80040b <printfmt>
  800570:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800573:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800576:	e9 82 02 00 00       	jmp    8007fd <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  80057b:	8b 45 14             	mov    0x14(%ebp),%eax
  80057e:	83 c0 04             	add    $0x4,%eax
  800581:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800584:	8b 45 14             	mov    0x14(%ebp),%eax
  800587:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800589:	85 ff                	test   %edi,%edi
  80058b:	b8 08 24 80 00       	mov    $0x802408,%eax
  800590:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800593:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800597:	0f 8e bd 00 00 00    	jle    80065a <vprintfmt+0x232>
  80059d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005a1:	75 0e                	jne    8005b1 <vprintfmt+0x189>
  8005a3:	89 75 08             	mov    %esi,0x8(%ebp)
  8005a6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005a9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005ac:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005af:	eb 6d                	jmp    80061e <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b1:	83 ec 08             	sub    $0x8,%esp
  8005b4:	ff 75 d0             	pushl  -0x30(%ebp)
  8005b7:	57                   	push   %edi
  8005b8:	e8 6e 03 00 00       	call   80092b <strnlen>
  8005bd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005c0:	29 c1                	sub    %eax,%ecx
  8005c2:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8005c5:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005c8:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005cc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005cf:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005d2:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d4:	eb 0f                	jmp    8005e5 <vprintfmt+0x1bd>
					putch(padc, putdat);
  8005d6:	83 ec 08             	sub    $0x8,%esp
  8005d9:	53                   	push   %ebx
  8005da:	ff 75 e0             	pushl  -0x20(%ebp)
  8005dd:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005df:	83 ef 01             	sub    $0x1,%edi
  8005e2:	83 c4 10             	add    $0x10,%esp
  8005e5:	85 ff                	test   %edi,%edi
  8005e7:	7f ed                	jg     8005d6 <vprintfmt+0x1ae>
  8005e9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005ec:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8005ef:	85 c9                	test   %ecx,%ecx
  8005f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8005f6:	0f 49 c1             	cmovns %ecx,%eax
  8005f9:	29 c1                	sub    %eax,%ecx
  8005fb:	89 75 08             	mov    %esi,0x8(%ebp)
  8005fe:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800601:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800604:	89 cb                	mov    %ecx,%ebx
  800606:	eb 16                	jmp    80061e <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  800608:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80060c:	75 31                	jne    80063f <vprintfmt+0x217>
					putch(ch, putdat);
  80060e:	83 ec 08             	sub    $0x8,%esp
  800611:	ff 75 0c             	pushl  0xc(%ebp)
  800614:	50                   	push   %eax
  800615:	ff 55 08             	call   *0x8(%ebp)
  800618:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80061b:	83 eb 01             	sub    $0x1,%ebx
  80061e:	83 c7 01             	add    $0x1,%edi
  800621:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800625:	0f be c2             	movsbl %dl,%eax
  800628:	85 c0                	test   %eax,%eax
  80062a:	74 59                	je     800685 <vprintfmt+0x25d>
  80062c:	85 f6                	test   %esi,%esi
  80062e:	78 d8                	js     800608 <vprintfmt+0x1e0>
  800630:	83 ee 01             	sub    $0x1,%esi
  800633:	79 d3                	jns    800608 <vprintfmt+0x1e0>
  800635:	89 df                	mov    %ebx,%edi
  800637:	8b 75 08             	mov    0x8(%ebp),%esi
  80063a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80063d:	eb 37                	jmp    800676 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  80063f:	0f be d2             	movsbl %dl,%edx
  800642:	83 ea 20             	sub    $0x20,%edx
  800645:	83 fa 5e             	cmp    $0x5e,%edx
  800648:	76 c4                	jbe    80060e <vprintfmt+0x1e6>
					putch('?', putdat);
  80064a:	83 ec 08             	sub    $0x8,%esp
  80064d:	ff 75 0c             	pushl  0xc(%ebp)
  800650:	6a 3f                	push   $0x3f
  800652:	ff 55 08             	call   *0x8(%ebp)
  800655:	83 c4 10             	add    $0x10,%esp
  800658:	eb c1                	jmp    80061b <vprintfmt+0x1f3>
  80065a:	89 75 08             	mov    %esi,0x8(%ebp)
  80065d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800660:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800663:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800666:	eb b6                	jmp    80061e <vprintfmt+0x1f6>
				putch(' ', putdat);
  800668:	83 ec 08             	sub    $0x8,%esp
  80066b:	53                   	push   %ebx
  80066c:	6a 20                	push   $0x20
  80066e:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800670:	83 ef 01             	sub    $0x1,%edi
  800673:	83 c4 10             	add    $0x10,%esp
  800676:	85 ff                	test   %edi,%edi
  800678:	7f ee                	jg     800668 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  80067a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80067d:	89 45 14             	mov    %eax,0x14(%ebp)
  800680:	e9 78 01 00 00       	jmp    8007fd <vprintfmt+0x3d5>
  800685:	89 df                	mov    %ebx,%edi
  800687:	8b 75 08             	mov    0x8(%ebp),%esi
  80068a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80068d:	eb e7                	jmp    800676 <vprintfmt+0x24e>
	if (lflag >= 2)
  80068f:	83 f9 01             	cmp    $0x1,%ecx
  800692:	7e 3f                	jle    8006d3 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800694:	8b 45 14             	mov    0x14(%ebp),%eax
  800697:	8b 50 04             	mov    0x4(%eax),%edx
  80069a:	8b 00                	mov    (%eax),%eax
  80069c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80069f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a5:	8d 40 08             	lea    0x8(%eax),%eax
  8006a8:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8006ab:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006af:	79 5c                	jns    80070d <vprintfmt+0x2e5>
				putch('-', putdat);
  8006b1:	83 ec 08             	sub    $0x8,%esp
  8006b4:	53                   	push   %ebx
  8006b5:	6a 2d                	push   $0x2d
  8006b7:	ff d6                	call   *%esi
				num = -(long long) num;
  8006b9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006bc:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006bf:	f7 da                	neg    %edx
  8006c1:	83 d1 00             	adc    $0x0,%ecx
  8006c4:	f7 d9                	neg    %ecx
  8006c6:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006c9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ce:	e9 10 01 00 00       	jmp    8007e3 <vprintfmt+0x3bb>
	else if (lflag)
  8006d3:	85 c9                	test   %ecx,%ecx
  8006d5:	75 1b                	jne    8006f2 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8006d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006da:	8b 00                	mov    (%eax),%eax
  8006dc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006df:	89 c1                	mov    %eax,%ecx
  8006e1:	c1 f9 1f             	sar    $0x1f,%ecx
  8006e4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ea:	8d 40 04             	lea    0x4(%eax),%eax
  8006ed:	89 45 14             	mov    %eax,0x14(%ebp)
  8006f0:	eb b9                	jmp    8006ab <vprintfmt+0x283>
		return va_arg(*ap, long);
  8006f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f5:	8b 00                	mov    (%eax),%eax
  8006f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006fa:	89 c1                	mov    %eax,%ecx
  8006fc:	c1 f9 1f             	sar    $0x1f,%ecx
  8006ff:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800702:	8b 45 14             	mov    0x14(%ebp),%eax
  800705:	8d 40 04             	lea    0x4(%eax),%eax
  800708:	89 45 14             	mov    %eax,0x14(%ebp)
  80070b:	eb 9e                	jmp    8006ab <vprintfmt+0x283>
			num = getint(&ap, lflag);
  80070d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800710:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800713:	b8 0a 00 00 00       	mov    $0xa,%eax
  800718:	e9 c6 00 00 00       	jmp    8007e3 <vprintfmt+0x3bb>
	if (lflag >= 2)
  80071d:	83 f9 01             	cmp    $0x1,%ecx
  800720:	7e 18                	jle    80073a <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  800722:	8b 45 14             	mov    0x14(%ebp),%eax
  800725:	8b 10                	mov    (%eax),%edx
  800727:	8b 48 04             	mov    0x4(%eax),%ecx
  80072a:	8d 40 08             	lea    0x8(%eax),%eax
  80072d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800730:	b8 0a 00 00 00       	mov    $0xa,%eax
  800735:	e9 a9 00 00 00       	jmp    8007e3 <vprintfmt+0x3bb>
	else if (lflag)
  80073a:	85 c9                	test   %ecx,%ecx
  80073c:	75 1a                	jne    800758 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  80073e:	8b 45 14             	mov    0x14(%ebp),%eax
  800741:	8b 10                	mov    (%eax),%edx
  800743:	b9 00 00 00 00       	mov    $0x0,%ecx
  800748:	8d 40 04             	lea    0x4(%eax),%eax
  80074b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80074e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800753:	e9 8b 00 00 00       	jmp    8007e3 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800758:	8b 45 14             	mov    0x14(%ebp),%eax
  80075b:	8b 10                	mov    (%eax),%edx
  80075d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800762:	8d 40 04             	lea    0x4(%eax),%eax
  800765:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800768:	b8 0a 00 00 00       	mov    $0xa,%eax
  80076d:	eb 74                	jmp    8007e3 <vprintfmt+0x3bb>
	if (lflag >= 2)
  80076f:	83 f9 01             	cmp    $0x1,%ecx
  800772:	7e 15                	jle    800789 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  800774:	8b 45 14             	mov    0x14(%ebp),%eax
  800777:	8b 10                	mov    (%eax),%edx
  800779:	8b 48 04             	mov    0x4(%eax),%ecx
  80077c:	8d 40 08             	lea    0x8(%eax),%eax
  80077f:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800782:	b8 08 00 00 00       	mov    $0x8,%eax
  800787:	eb 5a                	jmp    8007e3 <vprintfmt+0x3bb>
	else if (lflag)
  800789:	85 c9                	test   %ecx,%ecx
  80078b:	75 17                	jne    8007a4 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  80078d:	8b 45 14             	mov    0x14(%ebp),%eax
  800790:	8b 10                	mov    (%eax),%edx
  800792:	b9 00 00 00 00       	mov    $0x0,%ecx
  800797:	8d 40 04             	lea    0x4(%eax),%eax
  80079a:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80079d:	b8 08 00 00 00       	mov    $0x8,%eax
  8007a2:	eb 3f                	jmp    8007e3 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8007a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a7:	8b 10                	mov    (%eax),%edx
  8007a9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007ae:	8d 40 04             	lea    0x4(%eax),%eax
  8007b1:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8007b4:	b8 08 00 00 00       	mov    $0x8,%eax
  8007b9:	eb 28                	jmp    8007e3 <vprintfmt+0x3bb>
			putch('0', putdat);
  8007bb:	83 ec 08             	sub    $0x8,%esp
  8007be:	53                   	push   %ebx
  8007bf:	6a 30                	push   $0x30
  8007c1:	ff d6                	call   *%esi
			putch('x', putdat);
  8007c3:	83 c4 08             	add    $0x8,%esp
  8007c6:	53                   	push   %ebx
  8007c7:	6a 78                	push   $0x78
  8007c9:	ff d6                	call   *%esi
			num = (unsigned long long)
  8007cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ce:	8b 10                	mov    (%eax),%edx
  8007d0:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8007d5:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8007d8:	8d 40 04             	lea    0x4(%eax),%eax
  8007db:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007de:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8007e3:	83 ec 0c             	sub    $0xc,%esp
  8007e6:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007ea:	57                   	push   %edi
  8007eb:	ff 75 e0             	pushl  -0x20(%ebp)
  8007ee:	50                   	push   %eax
  8007ef:	51                   	push   %ecx
  8007f0:	52                   	push   %edx
  8007f1:	89 da                	mov    %ebx,%edx
  8007f3:	89 f0                	mov    %esi,%eax
  8007f5:	e8 45 fb ff ff       	call   80033f <printnum>
			break;
  8007fa:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8007fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800800:	83 c7 01             	add    $0x1,%edi
  800803:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800807:	83 f8 25             	cmp    $0x25,%eax
  80080a:	0f 84 2f fc ff ff    	je     80043f <vprintfmt+0x17>
			if (ch == '\0')
  800810:	85 c0                	test   %eax,%eax
  800812:	0f 84 8b 00 00 00    	je     8008a3 <vprintfmt+0x47b>
			putch(ch, putdat);
  800818:	83 ec 08             	sub    $0x8,%esp
  80081b:	53                   	push   %ebx
  80081c:	50                   	push   %eax
  80081d:	ff d6                	call   *%esi
  80081f:	83 c4 10             	add    $0x10,%esp
  800822:	eb dc                	jmp    800800 <vprintfmt+0x3d8>
	if (lflag >= 2)
  800824:	83 f9 01             	cmp    $0x1,%ecx
  800827:	7e 15                	jle    80083e <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  800829:	8b 45 14             	mov    0x14(%ebp),%eax
  80082c:	8b 10                	mov    (%eax),%edx
  80082e:	8b 48 04             	mov    0x4(%eax),%ecx
  800831:	8d 40 08             	lea    0x8(%eax),%eax
  800834:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800837:	b8 10 00 00 00       	mov    $0x10,%eax
  80083c:	eb a5                	jmp    8007e3 <vprintfmt+0x3bb>
	else if (lflag)
  80083e:	85 c9                	test   %ecx,%ecx
  800840:	75 17                	jne    800859 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  800842:	8b 45 14             	mov    0x14(%ebp),%eax
  800845:	8b 10                	mov    (%eax),%edx
  800847:	b9 00 00 00 00       	mov    $0x0,%ecx
  80084c:	8d 40 04             	lea    0x4(%eax),%eax
  80084f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800852:	b8 10 00 00 00       	mov    $0x10,%eax
  800857:	eb 8a                	jmp    8007e3 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800859:	8b 45 14             	mov    0x14(%ebp),%eax
  80085c:	8b 10                	mov    (%eax),%edx
  80085e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800863:	8d 40 04             	lea    0x4(%eax),%eax
  800866:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800869:	b8 10 00 00 00       	mov    $0x10,%eax
  80086e:	e9 70 ff ff ff       	jmp    8007e3 <vprintfmt+0x3bb>
			putch(ch, putdat);
  800873:	83 ec 08             	sub    $0x8,%esp
  800876:	53                   	push   %ebx
  800877:	6a 25                	push   $0x25
  800879:	ff d6                	call   *%esi
			break;
  80087b:	83 c4 10             	add    $0x10,%esp
  80087e:	e9 7a ff ff ff       	jmp    8007fd <vprintfmt+0x3d5>
			putch('%', putdat);
  800883:	83 ec 08             	sub    $0x8,%esp
  800886:	53                   	push   %ebx
  800887:	6a 25                	push   $0x25
  800889:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80088b:	83 c4 10             	add    $0x10,%esp
  80088e:	89 f8                	mov    %edi,%eax
  800890:	eb 03                	jmp    800895 <vprintfmt+0x46d>
  800892:	83 e8 01             	sub    $0x1,%eax
  800895:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800899:	75 f7                	jne    800892 <vprintfmt+0x46a>
  80089b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80089e:	e9 5a ff ff ff       	jmp    8007fd <vprintfmt+0x3d5>
}
  8008a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008a6:	5b                   	pop    %ebx
  8008a7:	5e                   	pop    %esi
  8008a8:	5f                   	pop    %edi
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	83 ec 18             	sub    $0x18,%esp
  8008b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008b7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008ba:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008be:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008c1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008c8:	85 c0                	test   %eax,%eax
  8008ca:	74 26                	je     8008f2 <vsnprintf+0x47>
  8008cc:	85 d2                	test   %edx,%edx
  8008ce:	7e 22                	jle    8008f2 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008d0:	ff 75 14             	pushl  0x14(%ebp)
  8008d3:	ff 75 10             	pushl  0x10(%ebp)
  8008d6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008d9:	50                   	push   %eax
  8008da:	68 ee 03 80 00       	push   $0x8003ee
  8008df:	e8 44 fb ff ff       	call   800428 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008e7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008ed:	83 c4 10             	add    $0x10,%esp
}
  8008f0:	c9                   	leave  
  8008f1:	c3                   	ret    
		return -E_INVAL;
  8008f2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008f7:	eb f7                	jmp    8008f0 <vsnprintf+0x45>

008008f9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008f9:	55                   	push   %ebp
  8008fa:	89 e5                	mov    %esp,%ebp
  8008fc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008ff:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800902:	50                   	push   %eax
  800903:	ff 75 10             	pushl  0x10(%ebp)
  800906:	ff 75 0c             	pushl  0xc(%ebp)
  800909:	ff 75 08             	pushl  0x8(%ebp)
  80090c:	e8 9a ff ff ff       	call   8008ab <vsnprintf>
	va_end(ap);

	return rc;
}
  800911:	c9                   	leave  
  800912:	c3                   	ret    

00800913 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800913:	55                   	push   %ebp
  800914:	89 e5                	mov    %esp,%ebp
  800916:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800919:	b8 00 00 00 00       	mov    $0x0,%eax
  80091e:	eb 03                	jmp    800923 <strlen+0x10>
		n++;
  800920:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800923:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800927:	75 f7                	jne    800920 <strlen+0xd>
	return n;
}
  800929:	5d                   	pop    %ebp
  80092a:	c3                   	ret    

0080092b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80092b:	55                   	push   %ebp
  80092c:	89 e5                	mov    %esp,%ebp
  80092e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800931:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800934:	b8 00 00 00 00       	mov    $0x0,%eax
  800939:	eb 03                	jmp    80093e <strnlen+0x13>
		n++;
  80093b:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80093e:	39 d0                	cmp    %edx,%eax
  800940:	74 06                	je     800948 <strnlen+0x1d>
  800942:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800946:	75 f3                	jne    80093b <strnlen+0x10>
	return n;
}
  800948:	5d                   	pop    %ebp
  800949:	c3                   	ret    

0080094a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	53                   	push   %ebx
  80094e:	8b 45 08             	mov    0x8(%ebp),%eax
  800951:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800954:	89 c2                	mov    %eax,%edx
  800956:	83 c1 01             	add    $0x1,%ecx
  800959:	83 c2 01             	add    $0x1,%edx
  80095c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800960:	88 5a ff             	mov    %bl,-0x1(%edx)
  800963:	84 db                	test   %bl,%bl
  800965:	75 ef                	jne    800956 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800967:	5b                   	pop    %ebx
  800968:	5d                   	pop    %ebp
  800969:	c3                   	ret    

0080096a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	53                   	push   %ebx
  80096e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800971:	53                   	push   %ebx
  800972:	e8 9c ff ff ff       	call   800913 <strlen>
  800977:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80097a:	ff 75 0c             	pushl  0xc(%ebp)
  80097d:	01 d8                	add    %ebx,%eax
  80097f:	50                   	push   %eax
  800980:	e8 c5 ff ff ff       	call   80094a <strcpy>
	return dst;
}
  800985:	89 d8                	mov    %ebx,%eax
  800987:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80098a:	c9                   	leave  
  80098b:	c3                   	ret    

0080098c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	56                   	push   %esi
  800990:	53                   	push   %ebx
  800991:	8b 75 08             	mov    0x8(%ebp),%esi
  800994:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800997:	89 f3                	mov    %esi,%ebx
  800999:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80099c:	89 f2                	mov    %esi,%edx
  80099e:	eb 0f                	jmp    8009af <strncpy+0x23>
		*dst++ = *src;
  8009a0:	83 c2 01             	add    $0x1,%edx
  8009a3:	0f b6 01             	movzbl (%ecx),%eax
  8009a6:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009a9:	80 39 01             	cmpb   $0x1,(%ecx)
  8009ac:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8009af:	39 da                	cmp    %ebx,%edx
  8009b1:	75 ed                	jne    8009a0 <strncpy+0x14>
	}
	return ret;
}
  8009b3:	89 f0                	mov    %esi,%eax
  8009b5:	5b                   	pop    %ebx
  8009b6:	5e                   	pop    %esi
  8009b7:	5d                   	pop    %ebp
  8009b8:	c3                   	ret    

008009b9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	56                   	push   %esi
  8009bd:	53                   	push   %ebx
  8009be:	8b 75 08             	mov    0x8(%ebp),%esi
  8009c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8009c7:	89 f0                	mov    %esi,%eax
  8009c9:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009cd:	85 c9                	test   %ecx,%ecx
  8009cf:	75 0b                	jne    8009dc <strlcpy+0x23>
  8009d1:	eb 17                	jmp    8009ea <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009d3:	83 c2 01             	add    $0x1,%edx
  8009d6:	83 c0 01             	add    $0x1,%eax
  8009d9:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8009dc:	39 d8                	cmp    %ebx,%eax
  8009de:	74 07                	je     8009e7 <strlcpy+0x2e>
  8009e0:	0f b6 0a             	movzbl (%edx),%ecx
  8009e3:	84 c9                	test   %cl,%cl
  8009e5:	75 ec                	jne    8009d3 <strlcpy+0x1a>
		*dst = '\0';
  8009e7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009ea:	29 f0                	sub    %esi,%eax
}
  8009ec:	5b                   	pop    %ebx
  8009ed:	5e                   	pop    %esi
  8009ee:	5d                   	pop    %ebp
  8009ef:	c3                   	ret    

008009f0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009f0:	55                   	push   %ebp
  8009f1:	89 e5                	mov    %esp,%ebp
  8009f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009f9:	eb 06                	jmp    800a01 <strcmp+0x11>
		p++, q++;
  8009fb:	83 c1 01             	add    $0x1,%ecx
  8009fe:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800a01:	0f b6 01             	movzbl (%ecx),%eax
  800a04:	84 c0                	test   %al,%al
  800a06:	74 04                	je     800a0c <strcmp+0x1c>
  800a08:	3a 02                	cmp    (%edx),%al
  800a0a:	74 ef                	je     8009fb <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a0c:	0f b6 c0             	movzbl %al,%eax
  800a0f:	0f b6 12             	movzbl (%edx),%edx
  800a12:	29 d0                	sub    %edx,%eax
}
  800a14:	5d                   	pop    %ebp
  800a15:	c3                   	ret    

00800a16 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a16:	55                   	push   %ebp
  800a17:	89 e5                	mov    %esp,%ebp
  800a19:	53                   	push   %ebx
  800a1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a20:	89 c3                	mov    %eax,%ebx
  800a22:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a25:	eb 06                	jmp    800a2d <strncmp+0x17>
		n--, p++, q++;
  800a27:	83 c0 01             	add    $0x1,%eax
  800a2a:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a2d:	39 d8                	cmp    %ebx,%eax
  800a2f:	74 16                	je     800a47 <strncmp+0x31>
  800a31:	0f b6 08             	movzbl (%eax),%ecx
  800a34:	84 c9                	test   %cl,%cl
  800a36:	74 04                	je     800a3c <strncmp+0x26>
  800a38:	3a 0a                	cmp    (%edx),%cl
  800a3a:	74 eb                	je     800a27 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a3c:	0f b6 00             	movzbl (%eax),%eax
  800a3f:	0f b6 12             	movzbl (%edx),%edx
  800a42:	29 d0                	sub    %edx,%eax
}
  800a44:	5b                   	pop    %ebx
  800a45:	5d                   	pop    %ebp
  800a46:	c3                   	ret    
		return 0;
  800a47:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4c:	eb f6                	jmp    800a44 <strncmp+0x2e>

00800a4e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a4e:	55                   	push   %ebp
  800a4f:	89 e5                	mov    %esp,%ebp
  800a51:	8b 45 08             	mov    0x8(%ebp),%eax
  800a54:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a58:	0f b6 10             	movzbl (%eax),%edx
  800a5b:	84 d2                	test   %dl,%dl
  800a5d:	74 09                	je     800a68 <strchr+0x1a>
		if (*s == c)
  800a5f:	38 ca                	cmp    %cl,%dl
  800a61:	74 0a                	je     800a6d <strchr+0x1f>
	for (; *s; s++)
  800a63:	83 c0 01             	add    $0x1,%eax
  800a66:	eb f0                	jmp    800a58 <strchr+0xa>
			return (char *) s;
	return 0;
  800a68:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a6d:	5d                   	pop    %ebp
  800a6e:	c3                   	ret    

00800a6f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a6f:	55                   	push   %ebp
  800a70:	89 e5                	mov    %esp,%ebp
  800a72:	8b 45 08             	mov    0x8(%ebp),%eax
  800a75:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a79:	eb 03                	jmp    800a7e <strfind+0xf>
  800a7b:	83 c0 01             	add    $0x1,%eax
  800a7e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a81:	38 ca                	cmp    %cl,%dl
  800a83:	74 04                	je     800a89 <strfind+0x1a>
  800a85:	84 d2                	test   %dl,%dl
  800a87:	75 f2                	jne    800a7b <strfind+0xc>
			break;
	return (char *) s;
}
  800a89:	5d                   	pop    %ebp
  800a8a:	c3                   	ret    

00800a8b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	57                   	push   %edi
  800a8f:	56                   	push   %esi
  800a90:	53                   	push   %ebx
  800a91:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a94:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a97:	85 c9                	test   %ecx,%ecx
  800a99:	74 13                	je     800aae <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a9b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aa1:	75 05                	jne    800aa8 <memset+0x1d>
  800aa3:	f6 c1 03             	test   $0x3,%cl
  800aa6:	74 0d                	je     800ab5 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800aa8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aab:	fc                   	cld    
  800aac:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aae:	89 f8                	mov    %edi,%eax
  800ab0:	5b                   	pop    %ebx
  800ab1:	5e                   	pop    %esi
  800ab2:	5f                   	pop    %edi
  800ab3:	5d                   	pop    %ebp
  800ab4:	c3                   	ret    
		c &= 0xFF;
  800ab5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ab9:	89 d3                	mov    %edx,%ebx
  800abb:	c1 e3 08             	shl    $0x8,%ebx
  800abe:	89 d0                	mov    %edx,%eax
  800ac0:	c1 e0 18             	shl    $0x18,%eax
  800ac3:	89 d6                	mov    %edx,%esi
  800ac5:	c1 e6 10             	shl    $0x10,%esi
  800ac8:	09 f0                	or     %esi,%eax
  800aca:	09 c2                	or     %eax,%edx
  800acc:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800ace:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800ad1:	89 d0                	mov    %edx,%eax
  800ad3:	fc                   	cld    
  800ad4:	f3 ab                	rep stos %eax,%es:(%edi)
  800ad6:	eb d6                	jmp    800aae <memset+0x23>

00800ad8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	57                   	push   %edi
  800adc:	56                   	push   %esi
  800add:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ae6:	39 c6                	cmp    %eax,%esi
  800ae8:	73 35                	jae    800b1f <memmove+0x47>
  800aea:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aed:	39 c2                	cmp    %eax,%edx
  800aef:	76 2e                	jbe    800b1f <memmove+0x47>
		s += n;
		d += n;
  800af1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800af4:	89 d6                	mov    %edx,%esi
  800af6:	09 fe                	or     %edi,%esi
  800af8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800afe:	74 0c                	je     800b0c <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b00:	83 ef 01             	sub    $0x1,%edi
  800b03:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b06:	fd                   	std    
  800b07:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b09:	fc                   	cld    
  800b0a:	eb 21                	jmp    800b2d <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b0c:	f6 c1 03             	test   $0x3,%cl
  800b0f:	75 ef                	jne    800b00 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b11:	83 ef 04             	sub    $0x4,%edi
  800b14:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b17:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b1a:	fd                   	std    
  800b1b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b1d:	eb ea                	jmp    800b09 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b1f:	89 f2                	mov    %esi,%edx
  800b21:	09 c2                	or     %eax,%edx
  800b23:	f6 c2 03             	test   $0x3,%dl
  800b26:	74 09                	je     800b31 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b28:	89 c7                	mov    %eax,%edi
  800b2a:	fc                   	cld    
  800b2b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b2d:	5e                   	pop    %esi
  800b2e:	5f                   	pop    %edi
  800b2f:	5d                   	pop    %ebp
  800b30:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b31:	f6 c1 03             	test   $0x3,%cl
  800b34:	75 f2                	jne    800b28 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b36:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b39:	89 c7                	mov    %eax,%edi
  800b3b:	fc                   	cld    
  800b3c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b3e:	eb ed                	jmp    800b2d <memmove+0x55>

00800b40 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b43:	ff 75 10             	pushl  0x10(%ebp)
  800b46:	ff 75 0c             	pushl  0xc(%ebp)
  800b49:	ff 75 08             	pushl  0x8(%ebp)
  800b4c:	e8 87 ff ff ff       	call   800ad8 <memmove>
}
  800b51:	c9                   	leave  
  800b52:	c3                   	ret    

00800b53 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b53:	55                   	push   %ebp
  800b54:	89 e5                	mov    %esp,%ebp
  800b56:	56                   	push   %esi
  800b57:	53                   	push   %ebx
  800b58:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b5e:	89 c6                	mov    %eax,%esi
  800b60:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b63:	39 f0                	cmp    %esi,%eax
  800b65:	74 1c                	je     800b83 <memcmp+0x30>
		if (*s1 != *s2)
  800b67:	0f b6 08             	movzbl (%eax),%ecx
  800b6a:	0f b6 1a             	movzbl (%edx),%ebx
  800b6d:	38 d9                	cmp    %bl,%cl
  800b6f:	75 08                	jne    800b79 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b71:	83 c0 01             	add    $0x1,%eax
  800b74:	83 c2 01             	add    $0x1,%edx
  800b77:	eb ea                	jmp    800b63 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b79:	0f b6 c1             	movzbl %cl,%eax
  800b7c:	0f b6 db             	movzbl %bl,%ebx
  800b7f:	29 d8                	sub    %ebx,%eax
  800b81:	eb 05                	jmp    800b88 <memcmp+0x35>
	}

	return 0;
  800b83:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b88:	5b                   	pop    %ebx
  800b89:	5e                   	pop    %esi
  800b8a:	5d                   	pop    %ebp
  800b8b:	c3                   	ret    

00800b8c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b8c:	55                   	push   %ebp
  800b8d:	89 e5                	mov    %esp,%ebp
  800b8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b95:	89 c2                	mov    %eax,%edx
  800b97:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b9a:	39 d0                	cmp    %edx,%eax
  800b9c:	73 09                	jae    800ba7 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b9e:	38 08                	cmp    %cl,(%eax)
  800ba0:	74 05                	je     800ba7 <memfind+0x1b>
	for (; s < ends; s++)
  800ba2:	83 c0 01             	add    $0x1,%eax
  800ba5:	eb f3                	jmp    800b9a <memfind+0xe>
			break;
	return (void *) s;
}
  800ba7:	5d                   	pop    %ebp
  800ba8:	c3                   	ret    

00800ba9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ba9:	55                   	push   %ebp
  800baa:	89 e5                	mov    %esp,%ebp
  800bac:	57                   	push   %edi
  800bad:	56                   	push   %esi
  800bae:	53                   	push   %ebx
  800baf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bb2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bb5:	eb 03                	jmp    800bba <strtol+0x11>
		s++;
  800bb7:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800bba:	0f b6 01             	movzbl (%ecx),%eax
  800bbd:	3c 20                	cmp    $0x20,%al
  800bbf:	74 f6                	je     800bb7 <strtol+0xe>
  800bc1:	3c 09                	cmp    $0x9,%al
  800bc3:	74 f2                	je     800bb7 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800bc5:	3c 2b                	cmp    $0x2b,%al
  800bc7:	74 2e                	je     800bf7 <strtol+0x4e>
	int neg = 0;
  800bc9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800bce:	3c 2d                	cmp    $0x2d,%al
  800bd0:	74 2f                	je     800c01 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bd2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bd8:	75 05                	jne    800bdf <strtol+0x36>
  800bda:	80 39 30             	cmpb   $0x30,(%ecx)
  800bdd:	74 2c                	je     800c0b <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bdf:	85 db                	test   %ebx,%ebx
  800be1:	75 0a                	jne    800bed <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800be3:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800be8:	80 39 30             	cmpb   $0x30,(%ecx)
  800beb:	74 28                	je     800c15 <strtol+0x6c>
		base = 10;
  800bed:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf2:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bf5:	eb 50                	jmp    800c47 <strtol+0x9e>
		s++;
  800bf7:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800bfa:	bf 00 00 00 00       	mov    $0x0,%edi
  800bff:	eb d1                	jmp    800bd2 <strtol+0x29>
		s++, neg = 1;
  800c01:	83 c1 01             	add    $0x1,%ecx
  800c04:	bf 01 00 00 00       	mov    $0x1,%edi
  800c09:	eb c7                	jmp    800bd2 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c0b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c0f:	74 0e                	je     800c1f <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800c11:	85 db                	test   %ebx,%ebx
  800c13:	75 d8                	jne    800bed <strtol+0x44>
		s++, base = 8;
  800c15:	83 c1 01             	add    $0x1,%ecx
  800c18:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c1d:	eb ce                	jmp    800bed <strtol+0x44>
		s += 2, base = 16;
  800c1f:	83 c1 02             	add    $0x2,%ecx
  800c22:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c27:	eb c4                	jmp    800bed <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800c29:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c2c:	89 f3                	mov    %esi,%ebx
  800c2e:	80 fb 19             	cmp    $0x19,%bl
  800c31:	77 29                	ja     800c5c <strtol+0xb3>
			dig = *s - 'a' + 10;
  800c33:	0f be d2             	movsbl %dl,%edx
  800c36:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c39:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c3c:	7d 30                	jge    800c6e <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800c3e:	83 c1 01             	add    $0x1,%ecx
  800c41:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c45:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c47:	0f b6 11             	movzbl (%ecx),%edx
  800c4a:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c4d:	89 f3                	mov    %esi,%ebx
  800c4f:	80 fb 09             	cmp    $0x9,%bl
  800c52:	77 d5                	ja     800c29 <strtol+0x80>
			dig = *s - '0';
  800c54:	0f be d2             	movsbl %dl,%edx
  800c57:	83 ea 30             	sub    $0x30,%edx
  800c5a:	eb dd                	jmp    800c39 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800c5c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c5f:	89 f3                	mov    %esi,%ebx
  800c61:	80 fb 19             	cmp    $0x19,%bl
  800c64:	77 08                	ja     800c6e <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c66:	0f be d2             	movsbl %dl,%edx
  800c69:	83 ea 37             	sub    $0x37,%edx
  800c6c:	eb cb                	jmp    800c39 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c6e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c72:	74 05                	je     800c79 <strtol+0xd0>
		*endptr = (char *) s;
  800c74:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c77:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c79:	89 c2                	mov    %eax,%edx
  800c7b:	f7 da                	neg    %edx
  800c7d:	85 ff                	test   %edi,%edi
  800c7f:	0f 45 c2             	cmovne %edx,%eax
}
  800c82:	5b                   	pop    %ebx
  800c83:	5e                   	pop    %esi
  800c84:	5f                   	pop    %edi
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	57                   	push   %edi
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c8d:	b8 00 00 00 00       	mov    $0x0,%eax
  800c92:	8b 55 08             	mov    0x8(%ebp),%edx
  800c95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c98:	89 c3                	mov    %eax,%ebx
  800c9a:	89 c7                	mov    %eax,%edi
  800c9c:	89 c6                	mov    %eax,%esi
  800c9e:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ca0:	5b                   	pop    %ebx
  800ca1:	5e                   	pop    %esi
  800ca2:	5f                   	pop    %edi
  800ca3:	5d                   	pop    %ebp
  800ca4:	c3                   	ret    

00800ca5 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	57                   	push   %edi
  800ca9:	56                   	push   %esi
  800caa:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cab:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb0:	b8 01 00 00 00       	mov    $0x1,%eax
  800cb5:	89 d1                	mov    %edx,%ecx
  800cb7:	89 d3                	mov    %edx,%ebx
  800cb9:	89 d7                	mov    %edx,%edi
  800cbb:	89 d6                	mov    %edx,%esi
  800cbd:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cbf:	5b                   	pop    %ebx
  800cc0:	5e                   	pop    %esi
  800cc1:	5f                   	pop    %edi
  800cc2:	5d                   	pop    %ebp
  800cc3:	c3                   	ret    

00800cc4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	57                   	push   %edi
  800cc8:	56                   	push   %esi
  800cc9:	53                   	push   %ebx
  800cca:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ccd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd5:	b8 03 00 00 00       	mov    $0x3,%eax
  800cda:	89 cb                	mov    %ecx,%ebx
  800cdc:	89 cf                	mov    %ecx,%edi
  800cde:	89 ce                	mov    %ecx,%esi
  800ce0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ce2:	85 c0                	test   %eax,%eax
  800ce4:	7f 08                	jg     800cee <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ce6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce9:	5b                   	pop    %ebx
  800cea:	5e                   	pop    %esi
  800ceb:	5f                   	pop    %edi
  800cec:	5d                   	pop    %ebp
  800ced:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cee:	83 ec 0c             	sub    $0xc,%esp
  800cf1:	50                   	push   %eax
  800cf2:	6a 03                	push   $0x3
  800cf4:	68 ff 26 80 00       	push   $0x8026ff
  800cf9:	6a 23                	push   $0x23
  800cfb:	68 1c 27 80 00       	push   $0x80271c
  800d00:	e8 4b f5 ff ff       	call   800250 <_panic>

00800d05 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d05:	55                   	push   %ebp
  800d06:	89 e5                	mov    %esp,%ebp
  800d08:	57                   	push   %edi
  800d09:	56                   	push   %esi
  800d0a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d0b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d10:	b8 02 00 00 00       	mov    $0x2,%eax
  800d15:	89 d1                	mov    %edx,%ecx
  800d17:	89 d3                	mov    %edx,%ebx
  800d19:	89 d7                	mov    %edx,%edi
  800d1b:	89 d6                	mov    %edx,%esi
  800d1d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d1f:	5b                   	pop    %ebx
  800d20:	5e                   	pop    %esi
  800d21:	5f                   	pop    %edi
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    

00800d24 <sys_yield>:

void
sys_yield(void)
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	57                   	push   %edi
  800d28:	56                   	push   %esi
  800d29:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d2f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d34:	89 d1                	mov    %edx,%ecx
  800d36:	89 d3                	mov    %edx,%ebx
  800d38:	89 d7                	mov    %edx,%edi
  800d3a:	89 d6                	mov    %edx,%esi
  800d3c:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d3e:	5b                   	pop    %ebx
  800d3f:	5e                   	pop    %esi
  800d40:	5f                   	pop    %edi
  800d41:	5d                   	pop    %ebp
  800d42:	c3                   	ret    

00800d43 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d43:	55                   	push   %ebp
  800d44:	89 e5                	mov    %esp,%ebp
  800d46:	57                   	push   %edi
  800d47:	56                   	push   %esi
  800d48:	53                   	push   %ebx
  800d49:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d4c:	be 00 00 00 00       	mov    $0x0,%esi
  800d51:	8b 55 08             	mov    0x8(%ebp),%edx
  800d54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d57:	b8 04 00 00 00       	mov    $0x4,%eax
  800d5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d5f:	89 f7                	mov    %esi,%edi
  800d61:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d63:	85 c0                	test   %eax,%eax
  800d65:	7f 08                	jg     800d6f <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6a:	5b                   	pop    %ebx
  800d6b:	5e                   	pop    %esi
  800d6c:	5f                   	pop    %edi
  800d6d:	5d                   	pop    %ebp
  800d6e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6f:	83 ec 0c             	sub    $0xc,%esp
  800d72:	50                   	push   %eax
  800d73:	6a 04                	push   $0x4
  800d75:	68 ff 26 80 00       	push   $0x8026ff
  800d7a:	6a 23                	push   $0x23
  800d7c:	68 1c 27 80 00       	push   $0x80271c
  800d81:	e8 ca f4 ff ff       	call   800250 <_panic>

00800d86 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d86:	55                   	push   %ebp
  800d87:	89 e5                	mov    %esp,%ebp
  800d89:	57                   	push   %edi
  800d8a:	56                   	push   %esi
  800d8b:	53                   	push   %ebx
  800d8c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d95:	b8 05 00 00 00       	mov    $0x5,%eax
  800d9a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d9d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800da0:	8b 75 18             	mov    0x18(%ebp),%esi
  800da3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800da5:	85 c0                	test   %eax,%eax
  800da7:	7f 08                	jg     800db1 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800da9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dac:	5b                   	pop    %ebx
  800dad:	5e                   	pop    %esi
  800dae:	5f                   	pop    %edi
  800daf:	5d                   	pop    %ebp
  800db0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800db1:	83 ec 0c             	sub    $0xc,%esp
  800db4:	50                   	push   %eax
  800db5:	6a 05                	push   $0x5
  800db7:	68 ff 26 80 00       	push   $0x8026ff
  800dbc:	6a 23                	push   $0x23
  800dbe:	68 1c 27 80 00       	push   $0x80271c
  800dc3:	e8 88 f4 ff ff       	call   800250 <_panic>

00800dc8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	57                   	push   %edi
  800dcc:	56                   	push   %esi
  800dcd:	53                   	push   %ebx
  800dce:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dd1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ddc:	b8 06 00 00 00       	mov    $0x6,%eax
  800de1:	89 df                	mov    %ebx,%edi
  800de3:	89 de                	mov    %ebx,%esi
  800de5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800de7:	85 c0                	test   %eax,%eax
  800de9:	7f 08                	jg     800df3 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800deb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dee:	5b                   	pop    %ebx
  800def:	5e                   	pop    %esi
  800df0:	5f                   	pop    %edi
  800df1:	5d                   	pop    %ebp
  800df2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800df3:	83 ec 0c             	sub    $0xc,%esp
  800df6:	50                   	push   %eax
  800df7:	6a 06                	push   $0x6
  800df9:	68 ff 26 80 00       	push   $0x8026ff
  800dfe:	6a 23                	push   $0x23
  800e00:	68 1c 27 80 00       	push   $0x80271c
  800e05:	e8 46 f4 ff ff       	call   800250 <_panic>

00800e0a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	57                   	push   %edi
  800e0e:	56                   	push   %esi
  800e0f:	53                   	push   %ebx
  800e10:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e13:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e18:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1e:	b8 08 00 00 00       	mov    $0x8,%eax
  800e23:	89 df                	mov    %ebx,%edi
  800e25:	89 de                	mov    %ebx,%esi
  800e27:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e29:	85 c0                	test   %eax,%eax
  800e2b:	7f 08                	jg     800e35 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e30:	5b                   	pop    %ebx
  800e31:	5e                   	pop    %esi
  800e32:	5f                   	pop    %edi
  800e33:	5d                   	pop    %ebp
  800e34:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e35:	83 ec 0c             	sub    $0xc,%esp
  800e38:	50                   	push   %eax
  800e39:	6a 08                	push   $0x8
  800e3b:	68 ff 26 80 00       	push   $0x8026ff
  800e40:	6a 23                	push   $0x23
  800e42:	68 1c 27 80 00       	push   $0x80271c
  800e47:	e8 04 f4 ff ff       	call   800250 <_panic>

00800e4c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	57                   	push   %edi
  800e50:	56                   	push   %esi
  800e51:	53                   	push   %ebx
  800e52:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e55:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e60:	b8 09 00 00 00       	mov    $0x9,%eax
  800e65:	89 df                	mov    %ebx,%edi
  800e67:	89 de                	mov    %ebx,%esi
  800e69:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e6b:	85 c0                	test   %eax,%eax
  800e6d:	7f 08                	jg     800e77 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e72:	5b                   	pop    %ebx
  800e73:	5e                   	pop    %esi
  800e74:	5f                   	pop    %edi
  800e75:	5d                   	pop    %ebp
  800e76:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e77:	83 ec 0c             	sub    $0xc,%esp
  800e7a:	50                   	push   %eax
  800e7b:	6a 09                	push   $0x9
  800e7d:	68 ff 26 80 00       	push   $0x8026ff
  800e82:	6a 23                	push   $0x23
  800e84:	68 1c 27 80 00       	push   $0x80271c
  800e89:	e8 c2 f3 ff ff       	call   800250 <_panic>

00800e8e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e8e:	55                   	push   %ebp
  800e8f:	89 e5                	mov    %esp,%ebp
  800e91:	57                   	push   %edi
  800e92:	56                   	push   %esi
  800e93:	53                   	push   %ebx
  800e94:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e97:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ea7:	89 df                	mov    %ebx,%edi
  800ea9:	89 de                	mov    %ebx,%esi
  800eab:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ead:	85 c0                	test   %eax,%eax
  800eaf:	7f 08                	jg     800eb9 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800eb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eb4:	5b                   	pop    %ebx
  800eb5:	5e                   	pop    %esi
  800eb6:	5f                   	pop    %edi
  800eb7:	5d                   	pop    %ebp
  800eb8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb9:	83 ec 0c             	sub    $0xc,%esp
  800ebc:	50                   	push   %eax
  800ebd:	6a 0a                	push   $0xa
  800ebf:	68 ff 26 80 00       	push   $0x8026ff
  800ec4:	6a 23                	push   $0x23
  800ec6:	68 1c 27 80 00       	push   $0x80271c
  800ecb:	e8 80 f3 ff ff       	call   800250 <_panic>

00800ed0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
  800ed3:	57                   	push   %edi
  800ed4:	56                   	push   %esi
  800ed5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ed6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800edc:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ee1:	be 00 00 00 00       	mov    $0x0,%esi
  800ee6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ee9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800eec:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800eee:	5b                   	pop    %ebx
  800eef:	5e                   	pop    %esi
  800ef0:	5f                   	pop    %edi
  800ef1:	5d                   	pop    %ebp
  800ef2:	c3                   	ret    

00800ef3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ef3:	55                   	push   %ebp
  800ef4:	89 e5                	mov    %esp,%ebp
  800ef6:	57                   	push   %edi
  800ef7:	56                   	push   %esi
  800ef8:	53                   	push   %ebx
  800ef9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800efc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f01:	8b 55 08             	mov    0x8(%ebp),%edx
  800f04:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f09:	89 cb                	mov    %ecx,%ebx
  800f0b:	89 cf                	mov    %ecx,%edi
  800f0d:	89 ce                	mov    %ecx,%esi
  800f0f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f11:	85 c0                	test   %eax,%eax
  800f13:	7f 08                	jg     800f1d <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f18:	5b                   	pop    %ebx
  800f19:	5e                   	pop    %esi
  800f1a:	5f                   	pop    %edi
  800f1b:	5d                   	pop    %ebp
  800f1c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f1d:	83 ec 0c             	sub    $0xc,%esp
  800f20:	50                   	push   %eax
  800f21:	6a 0d                	push   $0xd
  800f23:	68 ff 26 80 00       	push   $0x8026ff
  800f28:	6a 23                	push   $0x23
  800f2a:	68 1c 27 80 00       	push   $0x80271c
  800f2f:	e8 1c f3 ff ff       	call   800250 <_panic>

00800f34 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f34:	55                   	push   %ebp
  800f35:	89 e5                	mov    %esp,%ebp
  800f37:	53                   	push   %ebx
  800f38:	83 ec 04             	sub    $0x4,%esp
  800f3b:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800f3e:	8b 02                	mov    (%edx),%eax
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800f40:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800f44:	0f 84 9c 00 00 00    	je     800fe6 <pgfault+0xb2>
  800f4a:	89 c2                	mov    %eax,%edx
  800f4c:	c1 ea 16             	shr    $0x16,%edx
  800f4f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f56:	f6 c2 01             	test   $0x1,%dl
  800f59:	0f 84 87 00 00 00    	je     800fe6 <pgfault+0xb2>
  800f5f:	89 c2                	mov    %eax,%edx
  800f61:	c1 ea 0c             	shr    $0xc,%edx
  800f64:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800f6b:	f6 c1 01             	test   $0x1,%cl
  800f6e:	74 76                	je     800fe6 <pgfault+0xb2>
  800f70:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f77:	f6 c6 08             	test   $0x8,%dh
  800f7a:	74 6a                	je     800fe6 <pgfault+0xb2>
		panic("not copy-on-write");
	addr = ROUNDDOWN(addr, PGSIZE);
  800f7c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f81:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P) < 0)
  800f83:	83 ec 04             	sub    $0x4,%esp
  800f86:	6a 07                	push   $0x7
  800f88:	68 00 f0 7f 00       	push   $0x7ff000
  800f8d:	6a 00                	push   $0x0
  800f8f:	e8 af fd ff ff       	call   800d43 <sys_page_alloc>
  800f94:	83 c4 10             	add    $0x10,%esp
  800f97:	85 c0                	test   %eax,%eax
  800f99:	78 5f                	js     800ffa <pgfault+0xc6>
		panic("sys_page_alloc");
	memcpy(PFTEMP, addr, PGSIZE);
  800f9b:	83 ec 04             	sub    $0x4,%esp
  800f9e:	68 00 10 00 00       	push   $0x1000
  800fa3:	53                   	push   %ebx
  800fa4:	68 00 f0 7f 00       	push   $0x7ff000
  800fa9:	e8 92 fb ff ff       	call   800b40 <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P) < 0)
  800fae:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800fb5:	53                   	push   %ebx
  800fb6:	6a 00                	push   $0x0
  800fb8:	68 00 f0 7f 00       	push   $0x7ff000
  800fbd:	6a 00                	push   $0x0
  800fbf:	e8 c2 fd ff ff       	call   800d86 <sys_page_map>
  800fc4:	83 c4 20             	add    $0x20,%esp
  800fc7:	85 c0                	test   %eax,%eax
  800fc9:	78 43                	js     80100e <pgfault+0xda>
		panic("sys_page_map");
	if (sys_page_unmap(0, PFTEMP) < 0)
  800fcb:	83 ec 08             	sub    $0x8,%esp
  800fce:	68 00 f0 7f 00       	push   $0x7ff000
  800fd3:	6a 00                	push   $0x0
  800fd5:	e8 ee fd ff ff       	call   800dc8 <sys_page_unmap>
  800fda:	83 c4 10             	add    $0x10,%esp
  800fdd:	85 c0                	test   %eax,%eax
  800fdf:	78 41                	js     801022 <pgfault+0xee>
		panic("sys_page_unmap");
	return;
}
  800fe1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fe4:	c9                   	leave  
  800fe5:	c3                   	ret    
		panic("not copy-on-write");
  800fe6:	83 ec 04             	sub    $0x4,%esp
  800fe9:	68 2a 27 80 00       	push   $0x80272a
  800fee:	6a 25                	push   $0x25
  800ff0:	68 3c 27 80 00       	push   $0x80273c
  800ff5:	e8 56 f2 ff ff       	call   800250 <_panic>
		panic("sys_page_alloc");
  800ffa:	83 ec 04             	sub    $0x4,%esp
  800ffd:	68 47 27 80 00       	push   $0x802747
  801002:	6a 28                	push   $0x28
  801004:	68 3c 27 80 00       	push   $0x80273c
  801009:	e8 42 f2 ff ff       	call   800250 <_panic>
		panic("sys_page_map");
  80100e:	83 ec 04             	sub    $0x4,%esp
  801011:	68 56 27 80 00       	push   $0x802756
  801016:	6a 2b                	push   $0x2b
  801018:	68 3c 27 80 00       	push   $0x80273c
  80101d:	e8 2e f2 ff ff       	call   800250 <_panic>
		panic("sys_page_unmap");
  801022:	83 ec 04             	sub    $0x4,%esp
  801025:	68 63 27 80 00       	push   $0x802763
  80102a:	6a 2d                	push   $0x2d
  80102c:	68 3c 27 80 00       	push   $0x80273c
  801031:	e8 1a f2 ff ff       	call   800250 <_panic>

00801036 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801036:	55                   	push   %ebp
  801037:	89 e5                	mov    %esp,%ebp
  801039:	57                   	push   %edi
  80103a:	56                   	push   %esi
  80103b:	53                   	push   %ebx
  80103c:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  80103f:	68 34 0f 80 00       	push   $0x800f34
  801044:	e8 ba 0f 00 00       	call   802003 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801049:	b8 07 00 00 00       	mov    $0x7,%eax
  80104e:	cd 30                	int    $0x30
  801050:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid;
	uint32_t addr;
	envid = sys_exofork();
	if (envid == 0) {
  801053:	83 c4 10             	add    $0x10,%esp
  801056:	85 c0                	test   %eax,%eax
  801058:	74 12                	je     80106c <fork+0x36>
  80105a:	89 c7                	mov    %eax,%edi
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	if (envid < 0)
  80105c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801060:	78 26                	js     801088 <fork+0x52>
		panic("sys_exofork: %e", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  801062:	bb 00 00 00 00       	mov    $0x0,%ebx
  801067:	e9 94 00 00 00       	jmp    801100 <fork+0xca>
		thisenv = &envs[ENVX(sys_getenvid())];
  80106c:	e8 94 fc ff ff       	call   800d05 <sys_getenvid>
  801071:	25 ff 03 00 00       	and    $0x3ff,%eax
  801076:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801079:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80107e:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801083:	e9 51 01 00 00       	jmp    8011d9 <fork+0x1a3>
		panic("sys_exofork: %e", envid);
  801088:	ff 75 e4             	pushl  -0x1c(%ebp)
  80108b:	68 72 27 80 00       	push   $0x802772
  801090:	6a 6e                	push   $0x6e
  801092:	68 3c 27 80 00       	push   $0x80273c
  801097:	e8 b4 f1 ff ff       	call   800250 <_panic>
        	sys_page_map(0, addr, envid, addr, PTE_SYSCALL);
  80109c:	83 ec 0c             	sub    $0xc,%esp
  80109f:	68 07 0e 00 00       	push   $0xe07
  8010a4:	56                   	push   %esi
  8010a5:	57                   	push   %edi
  8010a6:	56                   	push   %esi
  8010a7:	6a 00                	push   $0x0
  8010a9:	e8 d8 fc ff ff       	call   800d86 <sys_page_map>
  8010ae:	83 c4 20             	add    $0x20,%esp
  8010b1:	eb 3b                	jmp    8010ee <fork+0xb8>
        	if ((r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  8010b3:	83 ec 0c             	sub    $0xc,%esp
  8010b6:	68 05 08 00 00       	push   $0x805
  8010bb:	56                   	push   %esi
  8010bc:	57                   	push   %edi
  8010bd:	56                   	push   %esi
  8010be:	6a 00                	push   $0x0
  8010c0:	e8 c1 fc ff ff       	call   800d86 <sys_page_map>
  8010c5:	83 c4 20             	add    $0x20,%esp
  8010c8:	85 c0                	test   %eax,%eax
  8010ca:	0f 88 a9 00 00 00    	js     801179 <fork+0x143>
        	if ((r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  8010d0:	83 ec 0c             	sub    $0xc,%esp
  8010d3:	68 05 08 00 00       	push   $0x805
  8010d8:	56                   	push   %esi
  8010d9:	6a 00                	push   $0x0
  8010db:	56                   	push   %esi
  8010dc:	6a 00                	push   $0x0
  8010de:	e8 a3 fc ff ff       	call   800d86 <sys_page_map>
  8010e3:	83 c4 20             	add    $0x20,%esp
  8010e6:	85 c0                	test   %eax,%eax
  8010e8:	0f 88 9d 00 00 00    	js     80118b <fork+0x155>
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  8010ee:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010f4:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8010fa:	0f 84 9d 00 00 00    	je     80119d <fork+0x167>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  801100:	89 d8                	mov    %ebx,%eax
  801102:	c1 e8 16             	shr    $0x16,%eax
  801105:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80110c:	a8 01                	test   $0x1,%al
  80110e:	74 de                	je     8010ee <fork+0xb8>
  801110:	89 d8                	mov    %ebx,%eax
  801112:	c1 e8 0c             	shr    $0xc,%eax
  801115:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80111c:	f6 c2 01             	test   $0x1,%dl
  80111f:	74 cd                	je     8010ee <fork+0xb8>
			&& (uvpt[PGNUM(addr)] & PTE_U)) {
  801121:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801128:	f6 c2 04             	test   $0x4,%dl
  80112b:	74 c1                	je     8010ee <fork+0xb8>
	void *addr = (void*) (pn*PGSIZE);
  80112d:	89 c6                	mov    %eax,%esi
  80112f:	c1 e6 0c             	shl    $0xc,%esi
    	if (uvpt[pn] & PTE_SHARE) {
  801132:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801139:	f6 c6 04             	test   $0x4,%dh
  80113c:	0f 85 5a ff ff ff    	jne    80109c <fork+0x66>
    	} else if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  801142:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801149:	f6 c2 02             	test   $0x2,%dl
  80114c:	0f 85 61 ff ff ff    	jne    8010b3 <fork+0x7d>
  801152:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801159:	f6 c4 08             	test   $0x8,%ah
  80115c:	0f 85 51 ff ff ff    	jne    8010b3 <fork+0x7d>
        		sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  801162:	83 ec 0c             	sub    $0xc,%esp
  801165:	6a 05                	push   $0x5
  801167:	56                   	push   %esi
  801168:	57                   	push   %edi
  801169:	56                   	push   %esi
  80116a:	6a 00                	push   $0x0
  80116c:	e8 15 fc ff ff       	call   800d86 <sys_page_map>
  801171:	83 c4 20             	add    $0x20,%esp
  801174:	e9 75 ff ff ff       	jmp    8010ee <fork+0xb8>
            		panic("sys_page_map：%e", r);
  801179:	50                   	push   %eax
  80117a:	68 82 27 80 00       	push   $0x802782
  80117f:	6a 47                	push   $0x47
  801181:	68 3c 27 80 00       	push   $0x80273c
  801186:	e8 c5 f0 ff ff       	call   800250 <_panic>
            		panic("sys_page_map：%e", r);
  80118b:	50                   	push   %eax
  80118c:	68 82 27 80 00       	push   $0x802782
  801191:	6a 49                	push   $0x49
  801193:	68 3c 27 80 00       	push   $0x80273c
  801198:	e8 b3 f0 ff ff       	call   800250 <_panic>
			duppage(envid, PGNUM(addr));
		}

	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  80119d:	83 ec 04             	sub    $0x4,%esp
  8011a0:	6a 07                	push   $0x7
  8011a2:	68 00 f0 bf ee       	push   $0xeebff000
  8011a7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011aa:	e8 94 fb ff ff       	call   800d43 <sys_page_alloc>
  8011af:	83 c4 10             	add    $0x10,%esp
  8011b2:	85 c0                	test   %eax,%eax
  8011b4:	78 2e                	js     8011e4 <fork+0x1ae>
		panic("1");
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8011b6:	83 ec 08             	sub    $0x8,%esp
  8011b9:	68 72 20 80 00       	push   $0x802072
  8011be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8011c1:	57                   	push   %edi
  8011c2:	e8 c7 fc ff ff       	call   800e8e <sys_env_set_pgfault_upcall>

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  8011c7:	83 c4 08             	add    $0x8,%esp
  8011ca:	6a 02                	push   $0x2
  8011cc:	57                   	push   %edi
  8011cd:	e8 38 fc ff ff       	call   800e0a <sys_env_set_status>
  8011d2:	83 c4 10             	add    $0x10,%esp
  8011d5:	85 c0                	test   %eax,%eax
  8011d7:	78 1f                	js     8011f8 <fork+0x1c2>
		panic("sys_env_set_status");

	return envid;
	panic("fork not implemented");
}
  8011d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011df:	5b                   	pop    %ebx
  8011e0:	5e                   	pop    %esi
  8011e1:	5f                   	pop    %edi
  8011e2:	5d                   	pop    %ebp
  8011e3:	c3                   	ret    
		panic("1");
  8011e4:	83 ec 04             	sub    $0x4,%esp
  8011e7:	68 94 27 80 00       	push   $0x802794
  8011ec:	6a 77                	push   $0x77
  8011ee:	68 3c 27 80 00       	push   $0x80273c
  8011f3:	e8 58 f0 ff ff       	call   800250 <_panic>
		panic("sys_env_set_status");
  8011f8:	83 ec 04             	sub    $0x4,%esp
  8011fb:	68 96 27 80 00       	push   $0x802796
  801200:	6a 7c                	push   $0x7c
  801202:	68 3c 27 80 00       	push   $0x80273c
  801207:	e8 44 f0 ff ff       	call   800250 <_panic>

0080120c <sfork>:

// Challenge!
int
sfork(void)
{
  80120c:	55                   	push   %ebp
  80120d:	89 e5                	mov    %esp,%ebp
  80120f:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801212:	68 a9 27 80 00       	push   $0x8027a9
  801217:	68 86 00 00 00       	push   $0x86
  80121c:	68 3c 27 80 00       	push   $0x80273c
  801221:	e8 2a f0 ff ff       	call   800250 <_panic>

00801226 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801226:	55                   	push   %ebp
  801227:	89 e5                	mov    %esp,%ebp
  801229:	56                   	push   %esi
  80122a:	53                   	push   %ebx
  80122b:	8b 75 08             	mov    0x8(%ebp),%esi
  80122e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801231:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  801234:	85 f6                	test   %esi,%esi
  801236:	74 06                	je     80123e <ipc_recv+0x18>
  801238:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  80123e:	85 db                	test   %ebx,%ebx
  801240:	74 06                	je     801248 <ipc_recv+0x22>
  801242:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801248:	85 c0                	test   %eax,%eax
  80124a:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  80124f:	0f 44 c2             	cmove  %edx,%eax
	int ret = sys_ipc_recv(pg);
  801252:	83 ec 0c             	sub    $0xc,%esp
  801255:	50                   	push   %eax
  801256:	e8 98 fc ff ff       	call   800ef3 <sys_ipc_recv>
	if (ret) return ret;
  80125b:	83 c4 10             	add    $0x10,%esp
  80125e:	85 c0                	test   %eax,%eax
  801260:	75 24                	jne    801286 <ipc_recv+0x60>
	if (from_env_store)
  801262:	85 f6                	test   %esi,%esi
  801264:	74 0a                	je     801270 <ipc_recv+0x4a>
		*from_env_store = thisenv->env_ipc_from;
  801266:	a1 04 40 80 00       	mov    0x804004,%eax
  80126b:	8b 40 74             	mov    0x74(%eax),%eax
  80126e:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801270:	85 db                	test   %ebx,%ebx
  801272:	74 0a                	je     80127e <ipc_recv+0x58>
		*perm_store = thisenv->env_ipc_perm;
  801274:	a1 04 40 80 00       	mov    0x804004,%eax
  801279:	8b 40 78             	mov    0x78(%eax),%eax
  80127c:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  80127e:	a1 04 40 80 00       	mov    0x804004,%eax
  801283:	8b 40 70             	mov    0x70(%eax),%eax
}
  801286:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801289:	5b                   	pop    %ebx
  80128a:	5e                   	pop    %esi
  80128b:	5d                   	pop    %ebp
  80128c:	c3                   	ret    

0080128d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80128d:	55                   	push   %ebp
  80128e:	89 e5                	mov    %esp,%ebp
  801290:	57                   	push   %edi
  801291:	56                   	push   %esi
  801292:	53                   	push   %ebx
  801293:	83 ec 0c             	sub    $0xc,%esp
  801296:	8b 7d 08             	mov    0x8(%ebp),%edi
  801299:	8b 75 0c             	mov    0xc(%ebp),%esi
  80129c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  80129f:	85 db                	test   %ebx,%ebx
  8012a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8012a6:	0f 44 d8             	cmove  %eax,%ebx
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  8012a9:	ff 75 14             	pushl  0x14(%ebp)
  8012ac:	53                   	push   %ebx
  8012ad:	56                   	push   %esi
  8012ae:	57                   	push   %edi
  8012af:	e8 1c fc ff ff       	call   800ed0 <sys_ipc_try_send>
  8012b4:	83 c4 10             	add    $0x10,%esp
  8012b7:	85 c0                	test   %eax,%eax
  8012b9:	74 1e                	je     8012d9 <ipc_send+0x4c>
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  8012bb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8012be:	75 07                	jne    8012c7 <ipc_send+0x3a>
		sys_yield();
  8012c0:	e8 5f fa ff ff       	call   800d24 <sys_yield>
  8012c5:	eb e2                	jmp    8012a9 <ipc_send+0x1c>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  8012c7:	50                   	push   %eax
  8012c8:	68 bf 27 80 00       	push   $0x8027bf
  8012cd:	6a 36                	push   $0x36
  8012cf:	68 d6 27 80 00       	push   $0x8027d6
  8012d4:	e8 77 ef ff ff       	call   800250 <_panic>
	}
}
  8012d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012dc:	5b                   	pop    %ebx
  8012dd:	5e                   	pop    %esi
  8012de:	5f                   	pop    %edi
  8012df:	5d                   	pop    %ebp
  8012e0:	c3                   	ret    

008012e1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8012e1:	55                   	push   %ebp
  8012e2:	89 e5                	mov    %esp,%ebp
  8012e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8012e7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8012ec:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8012ef:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8012f5:	8b 52 50             	mov    0x50(%edx),%edx
  8012f8:	39 ca                	cmp    %ecx,%edx
  8012fa:	74 11                	je     80130d <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  8012fc:	83 c0 01             	add    $0x1,%eax
  8012ff:	3d 00 04 00 00       	cmp    $0x400,%eax
  801304:	75 e6                	jne    8012ec <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801306:	b8 00 00 00 00       	mov    $0x0,%eax
  80130b:	eb 0b                	jmp    801318 <ipc_find_env+0x37>
			return envs[i].env_id;
  80130d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801310:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801315:	8b 40 48             	mov    0x48(%eax),%eax
}
  801318:	5d                   	pop    %ebp
  801319:	c3                   	ret    

0080131a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80131a:	55                   	push   %ebp
  80131b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80131d:	8b 45 08             	mov    0x8(%ebp),%eax
  801320:	05 00 00 00 30       	add    $0x30000000,%eax
  801325:	c1 e8 0c             	shr    $0xc,%eax
}
  801328:	5d                   	pop    %ebp
  801329:	c3                   	ret    

0080132a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80132a:	55                   	push   %ebp
  80132b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80132d:	8b 45 08             	mov    0x8(%ebp),%eax
  801330:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801335:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80133a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80133f:	5d                   	pop    %ebp
  801340:	c3                   	ret    

00801341 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801341:	55                   	push   %ebp
  801342:	89 e5                	mov    %esp,%ebp
  801344:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801347:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80134c:	89 c2                	mov    %eax,%edx
  80134e:	c1 ea 16             	shr    $0x16,%edx
  801351:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801358:	f6 c2 01             	test   $0x1,%dl
  80135b:	74 2a                	je     801387 <fd_alloc+0x46>
  80135d:	89 c2                	mov    %eax,%edx
  80135f:	c1 ea 0c             	shr    $0xc,%edx
  801362:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801369:	f6 c2 01             	test   $0x1,%dl
  80136c:	74 19                	je     801387 <fd_alloc+0x46>
  80136e:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801373:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801378:	75 d2                	jne    80134c <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80137a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801380:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801385:	eb 07                	jmp    80138e <fd_alloc+0x4d>
			*fd_store = fd;
  801387:	89 01                	mov    %eax,(%ecx)
			return 0;
  801389:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80138e:	5d                   	pop    %ebp
  80138f:	c3                   	ret    

00801390 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801390:	55                   	push   %ebp
  801391:	89 e5                	mov    %esp,%ebp
  801393:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801396:	83 f8 1f             	cmp    $0x1f,%eax
  801399:	77 36                	ja     8013d1 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80139b:	c1 e0 0c             	shl    $0xc,%eax
  80139e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013a3:	89 c2                	mov    %eax,%edx
  8013a5:	c1 ea 16             	shr    $0x16,%edx
  8013a8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013af:	f6 c2 01             	test   $0x1,%dl
  8013b2:	74 24                	je     8013d8 <fd_lookup+0x48>
  8013b4:	89 c2                	mov    %eax,%edx
  8013b6:	c1 ea 0c             	shr    $0xc,%edx
  8013b9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013c0:	f6 c2 01             	test   $0x1,%dl
  8013c3:	74 1a                	je     8013df <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013c8:	89 02                	mov    %eax,(%edx)
	return 0;
  8013ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013cf:	5d                   	pop    %ebp
  8013d0:	c3                   	ret    
		return -E_INVAL;
  8013d1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013d6:	eb f7                	jmp    8013cf <fd_lookup+0x3f>
		return -E_INVAL;
  8013d8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013dd:	eb f0                	jmp    8013cf <fd_lookup+0x3f>
  8013df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013e4:	eb e9                	jmp    8013cf <fd_lookup+0x3f>

008013e6 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013e6:	55                   	push   %ebp
  8013e7:	89 e5                	mov    %esp,%ebp
  8013e9:	83 ec 08             	sub    $0x8,%esp
  8013ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013ef:	ba 5c 28 80 00       	mov    $0x80285c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013f4:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  8013f9:	39 08                	cmp    %ecx,(%eax)
  8013fb:	74 33                	je     801430 <dev_lookup+0x4a>
  8013fd:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  801400:	8b 02                	mov    (%edx),%eax
  801402:	85 c0                	test   %eax,%eax
  801404:	75 f3                	jne    8013f9 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801406:	a1 04 40 80 00       	mov    0x804004,%eax
  80140b:	8b 40 48             	mov    0x48(%eax),%eax
  80140e:	83 ec 04             	sub    $0x4,%esp
  801411:	51                   	push   %ecx
  801412:	50                   	push   %eax
  801413:	68 e0 27 80 00       	push   $0x8027e0
  801418:	e8 0e ef ff ff       	call   80032b <cprintf>
	*dev = 0;
  80141d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801420:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801426:	83 c4 10             	add    $0x10,%esp
  801429:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80142e:	c9                   	leave  
  80142f:	c3                   	ret    
			*dev = devtab[i];
  801430:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801433:	89 01                	mov    %eax,(%ecx)
			return 0;
  801435:	b8 00 00 00 00       	mov    $0x0,%eax
  80143a:	eb f2                	jmp    80142e <dev_lookup+0x48>

0080143c <fd_close>:
{
  80143c:	55                   	push   %ebp
  80143d:	89 e5                	mov    %esp,%ebp
  80143f:	57                   	push   %edi
  801440:	56                   	push   %esi
  801441:	53                   	push   %ebx
  801442:	83 ec 1c             	sub    $0x1c,%esp
  801445:	8b 75 08             	mov    0x8(%ebp),%esi
  801448:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80144b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80144e:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80144f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801455:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801458:	50                   	push   %eax
  801459:	e8 32 ff ff ff       	call   801390 <fd_lookup>
  80145e:	89 c3                	mov    %eax,%ebx
  801460:	83 c4 08             	add    $0x8,%esp
  801463:	85 c0                	test   %eax,%eax
  801465:	78 05                	js     80146c <fd_close+0x30>
	    || fd != fd2)
  801467:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80146a:	74 16                	je     801482 <fd_close+0x46>
		return (must_exist ? r : 0);
  80146c:	89 f8                	mov    %edi,%eax
  80146e:	84 c0                	test   %al,%al
  801470:	b8 00 00 00 00       	mov    $0x0,%eax
  801475:	0f 44 d8             	cmove  %eax,%ebx
}
  801478:	89 d8                	mov    %ebx,%eax
  80147a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80147d:	5b                   	pop    %ebx
  80147e:	5e                   	pop    %esi
  80147f:	5f                   	pop    %edi
  801480:	5d                   	pop    %ebp
  801481:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801482:	83 ec 08             	sub    $0x8,%esp
  801485:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801488:	50                   	push   %eax
  801489:	ff 36                	pushl  (%esi)
  80148b:	e8 56 ff ff ff       	call   8013e6 <dev_lookup>
  801490:	89 c3                	mov    %eax,%ebx
  801492:	83 c4 10             	add    $0x10,%esp
  801495:	85 c0                	test   %eax,%eax
  801497:	78 15                	js     8014ae <fd_close+0x72>
		if (dev->dev_close)
  801499:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80149c:	8b 40 10             	mov    0x10(%eax),%eax
  80149f:	85 c0                	test   %eax,%eax
  8014a1:	74 1b                	je     8014be <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  8014a3:	83 ec 0c             	sub    $0xc,%esp
  8014a6:	56                   	push   %esi
  8014a7:	ff d0                	call   *%eax
  8014a9:	89 c3                	mov    %eax,%ebx
  8014ab:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8014ae:	83 ec 08             	sub    $0x8,%esp
  8014b1:	56                   	push   %esi
  8014b2:	6a 00                	push   $0x0
  8014b4:	e8 0f f9 ff ff       	call   800dc8 <sys_page_unmap>
	return r;
  8014b9:	83 c4 10             	add    $0x10,%esp
  8014bc:	eb ba                	jmp    801478 <fd_close+0x3c>
			r = 0;
  8014be:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014c3:	eb e9                	jmp    8014ae <fd_close+0x72>

008014c5 <close>:

int
close(int fdnum)
{
  8014c5:	55                   	push   %ebp
  8014c6:	89 e5                	mov    %esp,%ebp
  8014c8:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ce:	50                   	push   %eax
  8014cf:	ff 75 08             	pushl  0x8(%ebp)
  8014d2:	e8 b9 fe ff ff       	call   801390 <fd_lookup>
  8014d7:	83 c4 08             	add    $0x8,%esp
  8014da:	85 c0                	test   %eax,%eax
  8014dc:	78 10                	js     8014ee <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8014de:	83 ec 08             	sub    $0x8,%esp
  8014e1:	6a 01                	push   $0x1
  8014e3:	ff 75 f4             	pushl  -0xc(%ebp)
  8014e6:	e8 51 ff ff ff       	call   80143c <fd_close>
  8014eb:	83 c4 10             	add    $0x10,%esp
}
  8014ee:	c9                   	leave  
  8014ef:	c3                   	ret    

008014f0 <close_all>:

void
close_all(void)
{
  8014f0:	55                   	push   %ebp
  8014f1:	89 e5                	mov    %esp,%ebp
  8014f3:	53                   	push   %ebx
  8014f4:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014f7:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014fc:	83 ec 0c             	sub    $0xc,%esp
  8014ff:	53                   	push   %ebx
  801500:	e8 c0 ff ff ff       	call   8014c5 <close>
	for (i = 0; i < MAXFD; i++)
  801505:	83 c3 01             	add    $0x1,%ebx
  801508:	83 c4 10             	add    $0x10,%esp
  80150b:	83 fb 20             	cmp    $0x20,%ebx
  80150e:	75 ec                	jne    8014fc <close_all+0xc>
}
  801510:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801513:	c9                   	leave  
  801514:	c3                   	ret    

00801515 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801515:	55                   	push   %ebp
  801516:	89 e5                	mov    %esp,%ebp
  801518:	57                   	push   %edi
  801519:	56                   	push   %esi
  80151a:	53                   	push   %ebx
  80151b:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80151e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801521:	50                   	push   %eax
  801522:	ff 75 08             	pushl  0x8(%ebp)
  801525:	e8 66 fe ff ff       	call   801390 <fd_lookup>
  80152a:	89 c3                	mov    %eax,%ebx
  80152c:	83 c4 08             	add    $0x8,%esp
  80152f:	85 c0                	test   %eax,%eax
  801531:	0f 88 81 00 00 00    	js     8015b8 <dup+0xa3>
		return r;
	close(newfdnum);
  801537:	83 ec 0c             	sub    $0xc,%esp
  80153a:	ff 75 0c             	pushl  0xc(%ebp)
  80153d:	e8 83 ff ff ff       	call   8014c5 <close>

	newfd = INDEX2FD(newfdnum);
  801542:	8b 75 0c             	mov    0xc(%ebp),%esi
  801545:	c1 e6 0c             	shl    $0xc,%esi
  801548:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80154e:	83 c4 04             	add    $0x4,%esp
  801551:	ff 75 e4             	pushl  -0x1c(%ebp)
  801554:	e8 d1 fd ff ff       	call   80132a <fd2data>
  801559:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80155b:	89 34 24             	mov    %esi,(%esp)
  80155e:	e8 c7 fd ff ff       	call   80132a <fd2data>
  801563:	83 c4 10             	add    $0x10,%esp
  801566:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801568:	89 d8                	mov    %ebx,%eax
  80156a:	c1 e8 16             	shr    $0x16,%eax
  80156d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801574:	a8 01                	test   $0x1,%al
  801576:	74 11                	je     801589 <dup+0x74>
  801578:	89 d8                	mov    %ebx,%eax
  80157a:	c1 e8 0c             	shr    $0xc,%eax
  80157d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801584:	f6 c2 01             	test   $0x1,%dl
  801587:	75 39                	jne    8015c2 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801589:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80158c:	89 d0                	mov    %edx,%eax
  80158e:	c1 e8 0c             	shr    $0xc,%eax
  801591:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801598:	83 ec 0c             	sub    $0xc,%esp
  80159b:	25 07 0e 00 00       	and    $0xe07,%eax
  8015a0:	50                   	push   %eax
  8015a1:	56                   	push   %esi
  8015a2:	6a 00                	push   $0x0
  8015a4:	52                   	push   %edx
  8015a5:	6a 00                	push   $0x0
  8015a7:	e8 da f7 ff ff       	call   800d86 <sys_page_map>
  8015ac:	89 c3                	mov    %eax,%ebx
  8015ae:	83 c4 20             	add    $0x20,%esp
  8015b1:	85 c0                	test   %eax,%eax
  8015b3:	78 31                	js     8015e6 <dup+0xd1>
		goto err;

	return newfdnum;
  8015b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8015b8:	89 d8                	mov    %ebx,%eax
  8015ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015bd:	5b                   	pop    %ebx
  8015be:	5e                   	pop    %esi
  8015bf:	5f                   	pop    %edi
  8015c0:	5d                   	pop    %ebp
  8015c1:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015c2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015c9:	83 ec 0c             	sub    $0xc,%esp
  8015cc:	25 07 0e 00 00       	and    $0xe07,%eax
  8015d1:	50                   	push   %eax
  8015d2:	57                   	push   %edi
  8015d3:	6a 00                	push   $0x0
  8015d5:	53                   	push   %ebx
  8015d6:	6a 00                	push   $0x0
  8015d8:	e8 a9 f7 ff ff       	call   800d86 <sys_page_map>
  8015dd:	89 c3                	mov    %eax,%ebx
  8015df:	83 c4 20             	add    $0x20,%esp
  8015e2:	85 c0                	test   %eax,%eax
  8015e4:	79 a3                	jns    801589 <dup+0x74>
	sys_page_unmap(0, newfd);
  8015e6:	83 ec 08             	sub    $0x8,%esp
  8015e9:	56                   	push   %esi
  8015ea:	6a 00                	push   $0x0
  8015ec:	e8 d7 f7 ff ff       	call   800dc8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015f1:	83 c4 08             	add    $0x8,%esp
  8015f4:	57                   	push   %edi
  8015f5:	6a 00                	push   $0x0
  8015f7:	e8 cc f7 ff ff       	call   800dc8 <sys_page_unmap>
	return r;
  8015fc:	83 c4 10             	add    $0x10,%esp
  8015ff:	eb b7                	jmp    8015b8 <dup+0xa3>

00801601 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801601:	55                   	push   %ebp
  801602:	89 e5                	mov    %esp,%ebp
  801604:	53                   	push   %ebx
  801605:	83 ec 14             	sub    $0x14,%esp
  801608:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80160b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80160e:	50                   	push   %eax
  80160f:	53                   	push   %ebx
  801610:	e8 7b fd ff ff       	call   801390 <fd_lookup>
  801615:	83 c4 08             	add    $0x8,%esp
  801618:	85 c0                	test   %eax,%eax
  80161a:	78 3f                	js     80165b <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80161c:	83 ec 08             	sub    $0x8,%esp
  80161f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801622:	50                   	push   %eax
  801623:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801626:	ff 30                	pushl  (%eax)
  801628:	e8 b9 fd ff ff       	call   8013e6 <dev_lookup>
  80162d:	83 c4 10             	add    $0x10,%esp
  801630:	85 c0                	test   %eax,%eax
  801632:	78 27                	js     80165b <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801634:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801637:	8b 42 08             	mov    0x8(%edx),%eax
  80163a:	83 e0 03             	and    $0x3,%eax
  80163d:	83 f8 01             	cmp    $0x1,%eax
  801640:	74 1e                	je     801660 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801642:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801645:	8b 40 08             	mov    0x8(%eax),%eax
  801648:	85 c0                	test   %eax,%eax
  80164a:	74 35                	je     801681 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80164c:	83 ec 04             	sub    $0x4,%esp
  80164f:	ff 75 10             	pushl  0x10(%ebp)
  801652:	ff 75 0c             	pushl  0xc(%ebp)
  801655:	52                   	push   %edx
  801656:	ff d0                	call   *%eax
  801658:	83 c4 10             	add    $0x10,%esp
}
  80165b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80165e:	c9                   	leave  
  80165f:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801660:	a1 04 40 80 00       	mov    0x804004,%eax
  801665:	8b 40 48             	mov    0x48(%eax),%eax
  801668:	83 ec 04             	sub    $0x4,%esp
  80166b:	53                   	push   %ebx
  80166c:	50                   	push   %eax
  80166d:	68 21 28 80 00       	push   $0x802821
  801672:	e8 b4 ec ff ff       	call   80032b <cprintf>
		return -E_INVAL;
  801677:	83 c4 10             	add    $0x10,%esp
  80167a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80167f:	eb da                	jmp    80165b <read+0x5a>
		return -E_NOT_SUPP;
  801681:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801686:	eb d3                	jmp    80165b <read+0x5a>

00801688 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801688:	55                   	push   %ebp
  801689:	89 e5                	mov    %esp,%ebp
  80168b:	57                   	push   %edi
  80168c:	56                   	push   %esi
  80168d:	53                   	push   %ebx
  80168e:	83 ec 0c             	sub    $0xc,%esp
  801691:	8b 7d 08             	mov    0x8(%ebp),%edi
  801694:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801697:	bb 00 00 00 00       	mov    $0x0,%ebx
  80169c:	39 f3                	cmp    %esi,%ebx
  80169e:	73 25                	jae    8016c5 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016a0:	83 ec 04             	sub    $0x4,%esp
  8016a3:	89 f0                	mov    %esi,%eax
  8016a5:	29 d8                	sub    %ebx,%eax
  8016a7:	50                   	push   %eax
  8016a8:	89 d8                	mov    %ebx,%eax
  8016aa:	03 45 0c             	add    0xc(%ebp),%eax
  8016ad:	50                   	push   %eax
  8016ae:	57                   	push   %edi
  8016af:	e8 4d ff ff ff       	call   801601 <read>
		if (m < 0)
  8016b4:	83 c4 10             	add    $0x10,%esp
  8016b7:	85 c0                	test   %eax,%eax
  8016b9:	78 08                	js     8016c3 <readn+0x3b>
			return m;
		if (m == 0)
  8016bb:	85 c0                	test   %eax,%eax
  8016bd:	74 06                	je     8016c5 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  8016bf:	01 c3                	add    %eax,%ebx
  8016c1:	eb d9                	jmp    80169c <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016c3:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8016c5:	89 d8                	mov    %ebx,%eax
  8016c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016ca:	5b                   	pop    %ebx
  8016cb:	5e                   	pop    %esi
  8016cc:	5f                   	pop    %edi
  8016cd:	5d                   	pop    %ebp
  8016ce:	c3                   	ret    

008016cf <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016cf:	55                   	push   %ebp
  8016d0:	89 e5                	mov    %esp,%ebp
  8016d2:	53                   	push   %ebx
  8016d3:	83 ec 14             	sub    $0x14,%esp
  8016d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016d9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016dc:	50                   	push   %eax
  8016dd:	53                   	push   %ebx
  8016de:	e8 ad fc ff ff       	call   801390 <fd_lookup>
  8016e3:	83 c4 08             	add    $0x8,%esp
  8016e6:	85 c0                	test   %eax,%eax
  8016e8:	78 3a                	js     801724 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ea:	83 ec 08             	sub    $0x8,%esp
  8016ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f0:	50                   	push   %eax
  8016f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f4:	ff 30                	pushl  (%eax)
  8016f6:	e8 eb fc ff ff       	call   8013e6 <dev_lookup>
  8016fb:	83 c4 10             	add    $0x10,%esp
  8016fe:	85 c0                	test   %eax,%eax
  801700:	78 22                	js     801724 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801702:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801705:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801709:	74 1e                	je     801729 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80170b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80170e:	8b 52 0c             	mov    0xc(%edx),%edx
  801711:	85 d2                	test   %edx,%edx
  801713:	74 35                	je     80174a <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801715:	83 ec 04             	sub    $0x4,%esp
  801718:	ff 75 10             	pushl  0x10(%ebp)
  80171b:	ff 75 0c             	pushl  0xc(%ebp)
  80171e:	50                   	push   %eax
  80171f:	ff d2                	call   *%edx
  801721:	83 c4 10             	add    $0x10,%esp
}
  801724:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801727:	c9                   	leave  
  801728:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801729:	a1 04 40 80 00       	mov    0x804004,%eax
  80172e:	8b 40 48             	mov    0x48(%eax),%eax
  801731:	83 ec 04             	sub    $0x4,%esp
  801734:	53                   	push   %ebx
  801735:	50                   	push   %eax
  801736:	68 3d 28 80 00       	push   $0x80283d
  80173b:	e8 eb eb ff ff       	call   80032b <cprintf>
		return -E_INVAL;
  801740:	83 c4 10             	add    $0x10,%esp
  801743:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801748:	eb da                	jmp    801724 <write+0x55>
		return -E_NOT_SUPP;
  80174a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80174f:	eb d3                	jmp    801724 <write+0x55>

00801751 <seek>:

int
seek(int fdnum, off_t offset)
{
  801751:	55                   	push   %ebp
  801752:	89 e5                	mov    %esp,%ebp
  801754:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801757:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80175a:	50                   	push   %eax
  80175b:	ff 75 08             	pushl  0x8(%ebp)
  80175e:	e8 2d fc ff ff       	call   801390 <fd_lookup>
  801763:	83 c4 08             	add    $0x8,%esp
  801766:	85 c0                	test   %eax,%eax
  801768:	78 0e                	js     801778 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80176a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80176d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801770:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801773:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801778:	c9                   	leave  
  801779:	c3                   	ret    

0080177a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80177a:	55                   	push   %ebp
  80177b:	89 e5                	mov    %esp,%ebp
  80177d:	53                   	push   %ebx
  80177e:	83 ec 14             	sub    $0x14,%esp
  801781:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801784:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801787:	50                   	push   %eax
  801788:	53                   	push   %ebx
  801789:	e8 02 fc ff ff       	call   801390 <fd_lookup>
  80178e:	83 c4 08             	add    $0x8,%esp
  801791:	85 c0                	test   %eax,%eax
  801793:	78 37                	js     8017cc <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801795:	83 ec 08             	sub    $0x8,%esp
  801798:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80179b:	50                   	push   %eax
  80179c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80179f:	ff 30                	pushl  (%eax)
  8017a1:	e8 40 fc ff ff       	call   8013e6 <dev_lookup>
  8017a6:	83 c4 10             	add    $0x10,%esp
  8017a9:	85 c0                	test   %eax,%eax
  8017ab:	78 1f                	js     8017cc <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017b4:	74 1b                	je     8017d1 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8017b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017b9:	8b 52 18             	mov    0x18(%edx),%edx
  8017bc:	85 d2                	test   %edx,%edx
  8017be:	74 32                	je     8017f2 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017c0:	83 ec 08             	sub    $0x8,%esp
  8017c3:	ff 75 0c             	pushl  0xc(%ebp)
  8017c6:	50                   	push   %eax
  8017c7:	ff d2                	call   *%edx
  8017c9:	83 c4 10             	add    $0x10,%esp
}
  8017cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017cf:	c9                   	leave  
  8017d0:	c3                   	ret    
			thisenv->env_id, fdnum);
  8017d1:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017d6:	8b 40 48             	mov    0x48(%eax),%eax
  8017d9:	83 ec 04             	sub    $0x4,%esp
  8017dc:	53                   	push   %ebx
  8017dd:	50                   	push   %eax
  8017de:	68 00 28 80 00       	push   $0x802800
  8017e3:	e8 43 eb ff ff       	call   80032b <cprintf>
		return -E_INVAL;
  8017e8:	83 c4 10             	add    $0x10,%esp
  8017eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017f0:	eb da                	jmp    8017cc <ftruncate+0x52>
		return -E_NOT_SUPP;
  8017f2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017f7:	eb d3                	jmp    8017cc <ftruncate+0x52>

008017f9 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017f9:	55                   	push   %ebp
  8017fa:	89 e5                	mov    %esp,%ebp
  8017fc:	53                   	push   %ebx
  8017fd:	83 ec 14             	sub    $0x14,%esp
  801800:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801803:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801806:	50                   	push   %eax
  801807:	ff 75 08             	pushl  0x8(%ebp)
  80180a:	e8 81 fb ff ff       	call   801390 <fd_lookup>
  80180f:	83 c4 08             	add    $0x8,%esp
  801812:	85 c0                	test   %eax,%eax
  801814:	78 4b                	js     801861 <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801816:	83 ec 08             	sub    $0x8,%esp
  801819:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80181c:	50                   	push   %eax
  80181d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801820:	ff 30                	pushl  (%eax)
  801822:	e8 bf fb ff ff       	call   8013e6 <dev_lookup>
  801827:	83 c4 10             	add    $0x10,%esp
  80182a:	85 c0                	test   %eax,%eax
  80182c:	78 33                	js     801861 <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  80182e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801831:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801835:	74 2f                	je     801866 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801837:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80183a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801841:	00 00 00 
	stat->st_isdir = 0;
  801844:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80184b:	00 00 00 
	stat->st_dev = dev;
  80184e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801854:	83 ec 08             	sub    $0x8,%esp
  801857:	53                   	push   %ebx
  801858:	ff 75 f0             	pushl  -0x10(%ebp)
  80185b:	ff 50 14             	call   *0x14(%eax)
  80185e:	83 c4 10             	add    $0x10,%esp
}
  801861:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801864:	c9                   	leave  
  801865:	c3                   	ret    
		return -E_NOT_SUPP;
  801866:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80186b:	eb f4                	jmp    801861 <fstat+0x68>

0080186d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80186d:	55                   	push   %ebp
  80186e:	89 e5                	mov    %esp,%ebp
  801870:	56                   	push   %esi
  801871:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801872:	83 ec 08             	sub    $0x8,%esp
  801875:	6a 00                	push   $0x0
  801877:	ff 75 08             	pushl  0x8(%ebp)
  80187a:	e8 da 01 00 00       	call   801a59 <open>
  80187f:	89 c3                	mov    %eax,%ebx
  801881:	83 c4 10             	add    $0x10,%esp
  801884:	85 c0                	test   %eax,%eax
  801886:	78 1b                	js     8018a3 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801888:	83 ec 08             	sub    $0x8,%esp
  80188b:	ff 75 0c             	pushl  0xc(%ebp)
  80188e:	50                   	push   %eax
  80188f:	e8 65 ff ff ff       	call   8017f9 <fstat>
  801894:	89 c6                	mov    %eax,%esi
	close(fd);
  801896:	89 1c 24             	mov    %ebx,(%esp)
  801899:	e8 27 fc ff ff       	call   8014c5 <close>
	return r;
  80189e:	83 c4 10             	add    $0x10,%esp
  8018a1:	89 f3                	mov    %esi,%ebx
}
  8018a3:	89 d8                	mov    %ebx,%eax
  8018a5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018a8:	5b                   	pop    %ebx
  8018a9:	5e                   	pop    %esi
  8018aa:	5d                   	pop    %ebp
  8018ab:	c3                   	ret    

008018ac <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018ac:	55                   	push   %ebp
  8018ad:	89 e5                	mov    %esp,%ebp
  8018af:	56                   	push   %esi
  8018b0:	53                   	push   %ebx
  8018b1:	89 c6                	mov    %eax,%esi
  8018b3:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8018b5:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8018bc:	74 27                	je     8018e5 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018be:	6a 07                	push   $0x7
  8018c0:	68 00 50 80 00       	push   $0x805000
  8018c5:	56                   	push   %esi
  8018c6:	ff 35 00 40 80 00    	pushl  0x804000
  8018cc:	e8 bc f9 ff ff       	call   80128d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018d1:	83 c4 0c             	add    $0xc,%esp
  8018d4:	6a 00                	push   $0x0
  8018d6:	53                   	push   %ebx
  8018d7:	6a 00                	push   $0x0
  8018d9:	e8 48 f9 ff ff       	call   801226 <ipc_recv>
}
  8018de:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018e1:	5b                   	pop    %ebx
  8018e2:	5e                   	pop    %esi
  8018e3:	5d                   	pop    %ebp
  8018e4:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018e5:	83 ec 0c             	sub    $0xc,%esp
  8018e8:	6a 01                	push   $0x1
  8018ea:	e8 f2 f9 ff ff       	call   8012e1 <ipc_find_env>
  8018ef:	a3 00 40 80 00       	mov    %eax,0x804000
  8018f4:	83 c4 10             	add    $0x10,%esp
  8018f7:	eb c5                	jmp    8018be <fsipc+0x12>

008018f9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018f9:	55                   	push   %ebp
  8018fa:	89 e5                	mov    %esp,%ebp
  8018fc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801902:	8b 40 0c             	mov    0xc(%eax),%eax
  801905:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80190a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80190d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801912:	ba 00 00 00 00       	mov    $0x0,%edx
  801917:	b8 02 00 00 00       	mov    $0x2,%eax
  80191c:	e8 8b ff ff ff       	call   8018ac <fsipc>
}
  801921:	c9                   	leave  
  801922:	c3                   	ret    

00801923 <devfile_flush>:
{
  801923:	55                   	push   %ebp
  801924:	89 e5                	mov    %esp,%ebp
  801926:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801929:	8b 45 08             	mov    0x8(%ebp),%eax
  80192c:	8b 40 0c             	mov    0xc(%eax),%eax
  80192f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801934:	ba 00 00 00 00       	mov    $0x0,%edx
  801939:	b8 06 00 00 00       	mov    $0x6,%eax
  80193e:	e8 69 ff ff ff       	call   8018ac <fsipc>
}
  801943:	c9                   	leave  
  801944:	c3                   	ret    

00801945 <devfile_stat>:
{
  801945:	55                   	push   %ebp
  801946:	89 e5                	mov    %esp,%ebp
  801948:	53                   	push   %ebx
  801949:	83 ec 04             	sub    $0x4,%esp
  80194c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80194f:	8b 45 08             	mov    0x8(%ebp),%eax
  801952:	8b 40 0c             	mov    0xc(%eax),%eax
  801955:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80195a:	ba 00 00 00 00       	mov    $0x0,%edx
  80195f:	b8 05 00 00 00       	mov    $0x5,%eax
  801964:	e8 43 ff ff ff       	call   8018ac <fsipc>
  801969:	85 c0                	test   %eax,%eax
  80196b:	78 2c                	js     801999 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80196d:	83 ec 08             	sub    $0x8,%esp
  801970:	68 00 50 80 00       	push   $0x805000
  801975:	53                   	push   %ebx
  801976:	e8 cf ef ff ff       	call   80094a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80197b:	a1 80 50 80 00       	mov    0x805080,%eax
  801980:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801986:	a1 84 50 80 00       	mov    0x805084,%eax
  80198b:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801991:	83 c4 10             	add    $0x10,%esp
  801994:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801999:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80199c:	c9                   	leave  
  80199d:	c3                   	ret    

0080199e <devfile_write>:
{
  80199e:	55                   	push   %ebp
  80199f:	89 e5                	mov    %esp,%ebp
  8019a1:	83 ec 0c             	sub    $0xc,%esp
  8019a4:	8b 45 10             	mov    0x10(%ebp),%eax
    	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8019a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8019aa:	8b 52 0c             	mov    0xc(%edx),%edx
  8019ad:	89 15 00 50 80 00    	mov    %edx,0x805000
    	fsipcbuf.write.req_n = n;
  8019b3:	a3 04 50 80 00       	mov    %eax,0x805004
    	memmove(fsipcbuf.write.req_buf, buf, n);
  8019b8:	50                   	push   %eax
  8019b9:	ff 75 0c             	pushl  0xc(%ebp)
  8019bc:	68 08 50 80 00       	push   $0x805008
  8019c1:	e8 12 f1 ff ff       	call   800ad8 <memmove>
    	return fsipc(FSREQ_WRITE, NULL);
  8019c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8019cb:	b8 04 00 00 00       	mov    $0x4,%eax
  8019d0:	e8 d7 fe ff ff       	call   8018ac <fsipc>
}
  8019d5:	c9                   	leave  
  8019d6:	c3                   	ret    

008019d7 <devfile_read>:
{
  8019d7:	55                   	push   %ebp
  8019d8:	89 e5                	mov    %esp,%ebp
  8019da:	56                   	push   %esi
  8019db:	53                   	push   %ebx
  8019dc:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019df:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e2:	8b 40 0c             	mov    0xc(%eax),%eax
  8019e5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019ea:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f5:	b8 03 00 00 00       	mov    $0x3,%eax
  8019fa:	e8 ad fe ff ff       	call   8018ac <fsipc>
  8019ff:	89 c3                	mov    %eax,%ebx
  801a01:	85 c0                	test   %eax,%eax
  801a03:	78 1f                	js     801a24 <devfile_read+0x4d>
	assert(r <= n);
  801a05:	39 f0                	cmp    %esi,%eax
  801a07:	77 24                	ja     801a2d <devfile_read+0x56>
	assert(r <= PGSIZE);
  801a09:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a0e:	7f 33                	jg     801a43 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a10:	83 ec 04             	sub    $0x4,%esp
  801a13:	50                   	push   %eax
  801a14:	68 00 50 80 00       	push   $0x805000
  801a19:	ff 75 0c             	pushl  0xc(%ebp)
  801a1c:	e8 b7 f0 ff ff       	call   800ad8 <memmove>
	return r;
  801a21:	83 c4 10             	add    $0x10,%esp
}
  801a24:	89 d8                	mov    %ebx,%eax
  801a26:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a29:	5b                   	pop    %ebx
  801a2a:	5e                   	pop    %esi
  801a2b:	5d                   	pop    %ebp
  801a2c:	c3                   	ret    
	assert(r <= n);
  801a2d:	68 6c 28 80 00       	push   $0x80286c
  801a32:	68 73 28 80 00       	push   $0x802873
  801a37:	6a 7c                	push   $0x7c
  801a39:	68 88 28 80 00       	push   $0x802888
  801a3e:	e8 0d e8 ff ff       	call   800250 <_panic>
	assert(r <= PGSIZE);
  801a43:	68 93 28 80 00       	push   $0x802893
  801a48:	68 73 28 80 00       	push   $0x802873
  801a4d:	6a 7d                	push   $0x7d
  801a4f:	68 88 28 80 00       	push   $0x802888
  801a54:	e8 f7 e7 ff ff       	call   800250 <_panic>

00801a59 <open>:
{
  801a59:	55                   	push   %ebp
  801a5a:	89 e5                	mov    %esp,%ebp
  801a5c:	56                   	push   %esi
  801a5d:	53                   	push   %ebx
  801a5e:	83 ec 1c             	sub    $0x1c,%esp
  801a61:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801a64:	56                   	push   %esi
  801a65:	e8 a9 ee ff ff       	call   800913 <strlen>
  801a6a:	83 c4 10             	add    $0x10,%esp
  801a6d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a72:	7f 6c                	jg     801ae0 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801a74:	83 ec 0c             	sub    $0xc,%esp
  801a77:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a7a:	50                   	push   %eax
  801a7b:	e8 c1 f8 ff ff       	call   801341 <fd_alloc>
  801a80:	89 c3                	mov    %eax,%ebx
  801a82:	83 c4 10             	add    $0x10,%esp
  801a85:	85 c0                	test   %eax,%eax
  801a87:	78 3c                	js     801ac5 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801a89:	83 ec 08             	sub    $0x8,%esp
  801a8c:	56                   	push   %esi
  801a8d:	68 00 50 80 00       	push   $0x805000
  801a92:	e8 b3 ee ff ff       	call   80094a <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a97:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a9a:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a9f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801aa2:	b8 01 00 00 00       	mov    $0x1,%eax
  801aa7:	e8 00 fe ff ff       	call   8018ac <fsipc>
  801aac:	89 c3                	mov    %eax,%ebx
  801aae:	83 c4 10             	add    $0x10,%esp
  801ab1:	85 c0                	test   %eax,%eax
  801ab3:	78 19                	js     801ace <open+0x75>
	return fd2num(fd);
  801ab5:	83 ec 0c             	sub    $0xc,%esp
  801ab8:	ff 75 f4             	pushl  -0xc(%ebp)
  801abb:	e8 5a f8 ff ff       	call   80131a <fd2num>
  801ac0:	89 c3                	mov    %eax,%ebx
  801ac2:	83 c4 10             	add    $0x10,%esp
}
  801ac5:	89 d8                	mov    %ebx,%eax
  801ac7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aca:	5b                   	pop    %ebx
  801acb:	5e                   	pop    %esi
  801acc:	5d                   	pop    %ebp
  801acd:	c3                   	ret    
		fd_close(fd, 0);
  801ace:	83 ec 08             	sub    $0x8,%esp
  801ad1:	6a 00                	push   $0x0
  801ad3:	ff 75 f4             	pushl  -0xc(%ebp)
  801ad6:	e8 61 f9 ff ff       	call   80143c <fd_close>
		return r;
  801adb:	83 c4 10             	add    $0x10,%esp
  801ade:	eb e5                	jmp    801ac5 <open+0x6c>
		return -E_BAD_PATH;
  801ae0:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801ae5:	eb de                	jmp    801ac5 <open+0x6c>

00801ae7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801ae7:	55                   	push   %ebp
  801ae8:	89 e5                	mov    %esp,%ebp
  801aea:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801aed:	ba 00 00 00 00       	mov    $0x0,%edx
  801af2:	b8 08 00 00 00       	mov    $0x8,%eax
  801af7:	e8 b0 fd ff ff       	call   8018ac <fsipc>
}
  801afc:	c9                   	leave  
  801afd:	c3                   	ret    

00801afe <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801afe:	55                   	push   %ebp
  801aff:	89 e5                	mov    %esp,%ebp
  801b01:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b04:	89 d0                	mov    %edx,%eax
  801b06:	c1 e8 16             	shr    $0x16,%eax
  801b09:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b10:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801b15:	f6 c1 01             	test   $0x1,%cl
  801b18:	74 1d                	je     801b37 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801b1a:	c1 ea 0c             	shr    $0xc,%edx
  801b1d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b24:	f6 c2 01             	test   $0x1,%dl
  801b27:	74 0e                	je     801b37 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b29:	c1 ea 0c             	shr    $0xc,%edx
  801b2c:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b33:	ef 
  801b34:	0f b7 c0             	movzwl %ax,%eax
}
  801b37:	5d                   	pop    %ebp
  801b38:	c3                   	ret    

00801b39 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b39:	55                   	push   %ebp
  801b3a:	89 e5                	mov    %esp,%ebp
  801b3c:	56                   	push   %esi
  801b3d:	53                   	push   %ebx
  801b3e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b41:	83 ec 0c             	sub    $0xc,%esp
  801b44:	ff 75 08             	pushl  0x8(%ebp)
  801b47:	e8 de f7 ff ff       	call   80132a <fd2data>
  801b4c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b4e:	83 c4 08             	add    $0x8,%esp
  801b51:	68 9f 28 80 00       	push   $0x80289f
  801b56:	53                   	push   %ebx
  801b57:	e8 ee ed ff ff       	call   80094a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b5c:	8b 46 04             	mov    0x4(%esi),%eax
  801b5f:	2b 06                	sub    (%esi),%eax
  801b61:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b67:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b6e:	00 00 00 
	stat->st_dev = &devpipe;
  801b71:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b78:	30 80 00 
	return 0;
}
  801b7b:	b8 00 00 00 00       	mov    $0x0,%eax
  801b80:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b83:	5b                   	pop    %ebx
  801b84:	5e                   	pop    %esi
  801b85:	5d                   	pop    %ebp
  801b86:	c3                   	ret    

00801b87 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b87:	55                   	push   %ebp
  801b88:	89 e5                	mov    %esp,%ebp
  801b8a:	53                   	push   %ebx
  801b8b:	83 ec 0c             	sub    $0xc,%esp
  801b8e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b91:	53                   	push   %ebx
  801b92:	6a 00                	push   $0x0
  801b94:	e8 2f f2 ff ff       	call   800dc8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b99:	89 1c 24             	mov    %ebx,(%esp)
  801b9c:	e8 89 f7 ff ff       	call   80132a <fd2data>
  801ba1:	83 c4 08             	add    $0x8,%esp
  801ba4:	50                   	push   %eax
  801ba5:	6a 00                	push   $0x0
  801ba7:	e8 1c f2 ff ff       	call   800dc8 <sys_page_unmap>
}
  801bac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801baf:	c9                   	leave  
  801bb0:	c3                   	ret    

00801bb1 <_pipeisclosed>:
{
  801bb1:	55                   	push   %ebp
  801bb2:	89 e5                	mov    %esp,%ebp
  801bb4:	57                   	push   %edi
  801bb5:	56                   	push   %esi
  801bb6:	53                   	push   %ebx
  801bb7:	83 ec 1c             	sub    $0x1c,%esp
  801bba:	89 c7                	mov    %eax,%edi
  801bbc:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801bbe:	a1 04 40 80 00       	mov    0x804004,%eax
  801bc3:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801bc6:	83 ec 0c             	sub    $0xc,%esp
  801bc9:	57                   	push   %edi
  801bca:	e8 2f ff ff ff       	call   801afe <pageref>
  801bcf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801bd2:	89 34 24             	mov    %esi,(%esp)
  801bd5:	e8 24 ff ff ff       	call   801afe <pageref>
		nn = thisenv->env_runs;
  801bda:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801be0:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801be3:	83 c4 10             	add    $0x10,%esp
  801be6:	39 cb                	cmp    %ecx,%ebx
  801be8:	74 1b                	je     801c05 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801bea:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801bed:	75 cf                	jne    801bbe <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bef:	8b 42 58             	mov    0x58(%edx),%eax
  801bf2:	6a 01                	push   $0x1
  801bf4:	50                   	push   %eax
  801bf5:	53                   	push   %ebx
  801bf6:	68 a6 28 80 00       	push   $0x8028a6
  801bfb:	e8 2b e7 ff ff       	call   80032b <cprintf>
  801c00:	83 c4 10             	add    $0x10,%esp
  801c03:	eb b9                	jmp    801bbe <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801c05:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801c08:	0f 94 c0             	sete   %al
  801c0b:	0f b6 c0             	movzbl %al,%eax
}
  801c0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c11:	5b                   	pop    %ebx
  801c12:	5e                   	pop    %esi
  801c13:	5f                   	pop    %edi
  801c14:	5d                   	pop    %ebp
  801c15:	c3                   	ret    

00801c16 <devpipe_write>:
{
  801c16:	55                   	push   %ebp
  801c17:	89 e5                	mov    %esp,%ebp
  801c19:	57                   	push   %edi
  801c1a:	56                   	push   %esi
  801c1b:	53                   	push   %ebx
  801c1c:	83 ec 28             	sub    $0x28,%esp
  801c1f:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801c22:	56                   	push   %esi
  801c23:	e8 02 f7 ff ff       	call   80132a <fd2data>
  801c28:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c2a:	83 c4 10             	add    $0x10,%esp
  801c2d:	bf 00 00 00 00       	mov    $0x0,%edi
  801c32:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c35:	74 4f                	je     801c86 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c37:	8b 43 04             	mov    0x4(%ebx),%eax
  801c3a:	8b 0b                	mov    (%ebx),%ecx
  801c3c:	8d 51 20             	lea    0x20(%ecx),%edx
  801c3f:	39 d0                	cmp    %edx,%eax
  801c41:	72 14                	jb     801c57 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801c43:	89 da                	mov    %ebx,%edx
  801c45:	89 f0                	mov    %esi,%eax
  801c47:	e8 65 ff ff ff       	call   801bb1 <_pipeisclosed>
  801c4c:	85 c0                	test   %eax,%eax
  801c4e:	75 3a                	jne    801c8a <devpipe_write+0x74>
			sys_yield();
  801c50:	e8 cf f0 ff ff       	call   800d24 <sys_yield>
  801c55:	eb e0                	jmp    801c37 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c5a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c5e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c61:	89 c2                	mov    %eax,%edx
  801c63:	c1 fa 1f             	sar    $0x1f,%edx
  801c66:	89 d1                	mov    %edx,%ecx
  801c68:	c1 e9 1b             	shr    $0x1b,%ecx
  801c6b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c6e:	83 e2 1f             	and    $0x1f,%edx
  801c71:	29 ca                	sub    %ecx,%edx
  801c73:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c77:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c7b:	83 c0 01             	add    $0x1,%eax
  801c7e:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801c81:	83 c7 01             	add    $0x1,%edi
  801c84:	eb ac                	jmp    801c32 <devpipe_write+0x1c>
	return i;
  801c86:	89 f8                	mov    %edi,%eax
  801c88:	eb 05                	jmp    801c8f <devpipe_write+0x79>
				return 0;
  801c8a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c92:	5b                   	pop    %ebx
  801c93:	5e                   	pop    %esi
  801c94:	5f                   	pop    %edi
  801c95:	5d                   	pop    %ebp
  801c96:	c3                   	ret    

00801c97 <devpipe_read>:
{
  801c97:	55                   	push   %ebp
  801c98:	89 e5                	mov    %esp,%ebp
  801c9a:	57                   	push   %edi
  801c9b:	56                   	push   %esi
  801c9c:	53                   	push   %ebx
  801c9d:	83 ec 18             	sub    $0x18,%esp
  801ca0:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801ca3:	57                   	push   %edi
  801ca4:	e8 81 f6 ff ff       	call   80132a <fd2data>
  801ca9:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801cab:	83 c4 10             	add    $0x10,%esp
  801cae:	be 00 00 00 00       	mov    $0x0,%esi
  801cb3:	3b 75 10             	cmp    0x10(%ebp),%esi
  801cb6:	74 47                	je     801cff <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801cb8:	8b 03                	mov    (%ebx),%eax
  801cba:	3b 43 04             	cmp    0x4(%ebx),%eax
  801cbd:	75 22                	jne    801ce1 <devpipe_read+0x4a>
			if (i > 0)
  801cbf:	85 f6                	test   %esi,%esi
  801cc1:	75 14                	jne    801cd7 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801cc3:	89 da                	mov    %ebx,%edx
  801cc5:	89 f8                	mov    %edi,%eax
  801cc7:	e8 e5 fe ff ff       	call   801bb1 <_pipeisclosed>
  801ccc:	85 c0                	test   %eax,%eax
  801cce:	75 33                	jne    801d03 <devpipe_read+0x6c>
			sys_yield();
  801cd0:	e8 4f f0 ff ff       	call   800d24 <sys_yield>
  801cd5:	eb e1                	jmp    801cb8 <devpipe_read+0x21>
				return i;
  801cd7:	89 f0                	mov    %esi,%eax
}
  801cd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cdc:	5b                   	pop    %ebx
  801cdd:	5e                   	pop    %esi
  801cde:	5f                   	pop    %edi
  801cdf:	5d                   	pop    %ebp
  801ce0:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ce1:	99                   	cltd   
  801ce2:	c1 ea 1b             	shr    $0x1b,%edx
  801ce5:	01 d0                	add    %edx,%eax
  801ce7:	83 e0 1f             	and    $0x1f,%eax
  801cea:	29 d0                	sub    %edx,%eax
  801cec:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801cf1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cf4:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801cf7:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801cfa:	83 c6 01             	add    $0x1,%esi
  801cfd:	eb b4                	jmp    801cb3 <devpipe_read+0x1c>
	return i;
  801cff:	89 f0                	mov    %esi,%eax
  801d01:	eb d6                	jmp    801cd9 <devpipe_read+0x42>
				return 0;
  801d03:	b8 00 00 00 00       	mov    $0x0,%eax
  801d08:	eb cf                	jmp    801cd9 <devpipe_read+0x42>

00801d0a <pipe>:
{
  801d0a:	55                   	push   %ebp
  801d0b:	89 e5                	mov    %esp,%ebp
  801d0d:	56                   	push   %esi
  801d0e:	53                   	push   %ebx
  801d0f:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801d12:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d15:	50                   	push   %eax
  801d16:	e8 26 f6 ff ff       	call   801341 <fd_alloc>
  801d1b:	89 c3                	mov    %eax,%ebx
  801d1d:	83 c4 10             	add    $0x10,%esp
  801d20:	85 c0                	test   %eax,%eax
  801d22:	78 5b                	js     801d7f <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d24:	83 ec 04             	sub    $0x4,%esp
  801d27:	68 07 04 00 00       	push   $0x407
  801d2c:	ff 75 f4             	pushl  -0xc(%ebp)
  801d2f:	6a 00                	push   $0x0
  801d31:	e8 0d f0 ff ff       	call   800d43 <sys_page_alloc>
  801d36:	89 c3                	mov    %eax,%ebx
  801d38:	83 c4 10             	add    $0x10,%esp
  801d3b:	85 c0                	test   %eax,%eax
  801d3d:	78 40                	js     801d7f <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  801d3f:	83 ec 0c             	sub    $0xc,%esp
  801d42:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d45:	50                   	push   %eax
  801d46:	e8 f6 f5 ff ff       	call   801341 <fd_alloc>
  801d4b:	89 c3                	mov    %eax,%ebx
  801d4d:	83 c4 10             	add    $0x10,%esp
  801d50:	85 c0                	test   %eax,%eax
  801d52:	78 1b                	js     801d6f <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d54:	83 ec 04             	sub    $0x4,%esp
  801d57:	68 07 04 00 00       	push   $0x407
  801d5c:	ff 75 f0             	pushl  -0x10(%ebp)
  801d5f:	6a 00                	push   $0x0
  801d61:	e8 dd ef ff ff       	call   800d43 <sys_page_alloc>
  801d66:	89 c3                	mov    %eax,%ebx
  801d68:	83 c4 10             	add    $0x10,%esp
  801d6b:	85 c0                	test   %eax,%eax
  801d6d:	79 19                	jns    801d88 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  801d6f:	83 ec 08             	sub    $0x8,%esp
  801d72:	ff 75 f4             	pushl  -0xc(%ebp)
  801d75:	6a 00                	push   $0x0
  801d77:	e8 4c f0 ff ff       	call   800dc8 <sys_page_unmap>
  801d7c:	83 c4 10             	add    $0x10,%esp
}
  801d7f:	89 d8                	mov    %ebx,%eax
  801d81:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d84:	5b                   	pop    %ebx
  801d85:	5e                   	pop    %esi
  801d86:	5d                   	pop    %ebp
  801d87:	c3                   	ret    
	va = fd2data(fd0);
  801d88:	83 ec 0c             	sub    $0xc,%esp
  801d8b:	ff 75 f4             	pushl  -0xc(%ebp)
  801d8e:	e8 97 f5 ff ff       	call   80132a <fd2data>
  801d93:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d95:	83 c4 0c             	add    $0xc,%esp
  801d98:	68 07 04 00 00       	push   $0x407
  801d9d:	50                   	push   %eax
  801d9e:	6a 00                	push   $0x0
  801da0:	e8 9e ef ff ff       	call   800d43 <sys_page_alloc>
  801da5:	89 c3                	mov    %eax,%ebx
  801da7:	83 c4 10             	add    $0x10,%esp
  801daa:	85 c0                	test   %eax,%eax
  801dac:	0f 88 8c 00 00 00    	js     801e3e <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801db2:	83 ec 0c             	sub    $0xc,%esp
  801db5:	ff 75 f0             	pushl  -0x10(%ebp)
  801db8:	e8 6d f5 ff ff       	call   80132a <fd2data>
  801dbd:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801dc4:	50                   	push   %eax
  801dc5:	6a 00                	push   $0x0
  801dc7:	56                   	push   %esi
  801dc8:	6a 00                	push   $0x0
  801dca:	e8 b7 ef ff ff       	call   800d86 <sys_page_map>
  801dcf:	89 c3                	mov    %eax,%ebx
  801dd1:	83 c4 20             	add    $0x20,%esp
  801dd4:	85 c0                	test   %eax,%eax
  801dd6:	78 58                	js     801e30 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801dd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ddb:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801de1:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801de3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801de6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801ded:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801df0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801df6:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801df8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dfb:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801e02:	83 ec 0c             	sub    $0xc,%esp
  801e05:	ff 75 f4             	pushl  -0xc(%ebp)
  801e08:	e8 0d f5 ff ff       	call   80131a <fd2num>
  801e0d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e10:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e12:	83 c4 04             	add    $0x4,%esp
  801e15:	ff 75 f0             	pushl  -0x10(%ebp)
  801e18:	e8 fd f4 ff ff       	call   80131a <fd2num>
  801e1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e20:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e23:	83 c4 10             	add    $0x10,%esp
  801e26:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e2b:	e9 4f ff ff ff       	jmp    801d7f <pipe+0x75>
	sys_page_unmap(0, va);
  801e30:	83 ec 08             	sub    $0x8,%esp
  801e33:	56                   	push   %esi
  801e34:	6a 00                	push   $0x0
  801e36:	e8 8d ef ff ff       	call   800dc8 <sys_page_unmap>
  801e3b:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801e3e:	83 ec 08             	sub    $0x8,%esp
  801e41:	ff 75 f0             	pushl  -0x10(%ebp)
  801e44:	6a 00                	push   $0x0
  801e46:	e8 7d ef ff ff       	call   800dc8 <sys_page_unmap>
  801e4b:	83 c4 10             	add    $0x10,%esp
  801e4e:	e9 1c ff ff ff       	jmp    801d6f <pipe+0x65>

00801e53 <pipeisclosed>:
{
  801e53:	55                   	push   %ebp
  801e54:	89 e5                	mov    %esp,%ebp
  801e56:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e59:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e5c:	50                   	push   %eax
  801e5d:	ff 75 08             	pushl  0x8(%ebp)
  801e60:	e8 2b f5 ff ff       	call   801390 <fd_lookup>
  801e65:	83 c4 10             	add    $0x10,%esp
  801e68:	85 c0                	test   %eax,%eax
  801e6a:	78 18                	js     801e84 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801e6c:	83 ec 0c             	sub    $0xc,%esp
  801e6f:	ff 75 f4             	pushl  -0xc(%ebp)
  801e72:	e8 b3 f4 ff ff       	call   80132a <fd2data>
	return _pipeisclosed(fd, p);
  801e77:	89 c2                	mov    %eax,%edx
  801e79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e7c:	e8 30 fd ff ff       	call   801bb1 <_pipeisclosed>
  801e81:	83 c4 10             	add    $0x10,%esp
}
  801e84:	c9                   	leave  
  801e85:	c3                   	ret    

00801e86 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e86:	55                   	push   %ebp
  801e87:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e89:	b8 00 00 00 00       	mov    $0x0,%eax
  801e8e:	5d                   	pop    %ebp
  801e8f:	c3                   	ret    

00801e90 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e90:	55                   	push   %ebp
  801e91:	89 e5                	mov    %esp,%ebp
  801e93:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e96:	68 be 28 80 00       	push   $0x8028be
  801e9b:	ff 75 0c             	pushl  0xc(%ebp)
  801e9e:	e8 a7 ea ff ff       	call   80094a <strcpy>
	return 0;
}
  801ea3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ea8:	c9                   	leave  
  801ea9:	c3                   	ret    

00801eaa <devcons_write>:
{
  801eaa:	55                   	push   %ebp
  801eab:	89 e5                	mov    %esp,%ebp
  801ead:	57                   	push   %edi
  801eae:	56                   	push   %esi
  801eaf:	53                   	push   %ebx
  801eb0:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801eb6:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801ebb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801ec1:	eb 2f                	jmp    801ef2 <devcons_write+0x48>
		m = n - tot;
  801ec3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ec6:	29 f3                	sub    %esi,%ebx
  801ec8:	83 fb 7f             	cmp    $0x7f,%ebx
  801ecb:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801ed0:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801ed3:	83 ec 04             	sub    $0x4,%esp
  801ed6:	53                   	push   %ebx
  801ed7:	89 f0                	mov    %esi,%eax
  801ed9:	03 45 0c             	add    0xc(%ebp),%eax
  801edc:	50                   	push   %eax
  801edd:	57                   	push   %edi
  801ede:	e8 f5 eb ff ff       	call   800ad8 <memmove>
		sys_cputs(buf, m);
  801ee3:	83 c4 08             	add    $0x8,%esp
  801ee6:	53                   	push   %ebx
  801ee7:	57                   	push   %edi
  801ee8:	e8 9a ed ff ff       	call   800c87 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801eed:	01 de                	add    %ebx,%esi
  801eef:	83 c4 10             	add    $0x10,%esp
  801ef2:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ef5:	72 cc                	jb     801ec3 <devcons_write+0x19>
}
  801ef7:	89 f0                	mov    %esi,%eax
  801ef9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801efc:	5b                   	pop    %ebx
  801efd:	5e                   	pop    %esi
  801efe:	5f                   	pop    %edi
  801eff:	5d                   	pop    %ebp
  801f00:	c3                   	ret    

00801f01 <devcons_read>:
{
  801f01:	55                   	push   %ebp
  801f02:	89 e5                	mov    %esp,%ebp
  801f04:	83 ec 08             	sub    $0x8,%esp
  801f07:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801f0c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f10:	75 07                	jne    801f19 <devcons_read+0x18>
}
  801f12:	c9                   	leave  
  801f13:	c3                   	ret    
		sys_yield();
  801f14:	e8 0b ee ff ff       	call   800d24 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801f19:	e8 87 ed ff ff       	call   800ca5 <sys_cgetc>
  801f1e:	85 c0                	test   %eax,%eax
  801f20:	74 f2                	je     801f14 <devcons_read+0x13>
	if (c < 0)
  801f22:	85 c0                	test   %eax,%eax
  801f24:	78 ec                	js     801f12 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801f26:	83 f8 04             	cmp    $0x4,%eax
  801f29:	74 0c                	je     801f37 <devcons_read+0x36>
	*(char*)vbuf = c;
  801f2b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f2e:	88 02                	mov    %al,(%edx)
	return 1;
  801f30:	b8 01 00 00 00       	mov    $0x1,%eax
  801f35:	eb db                	jmp    801f12 <devcons_read+0x11>
		return 0;
  801f37:	b8 00 00 00 00       	mov    $0x0,%eax
  801f3c:	eb d4                	jmp    801f12 <devcons_read+0x11>

00801f3e <cputchar>:
{
  801f3e:	55                   	push   %ebp
  801f3f:	89 e5                	mov    %esp,%ebp
  801f41:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f44:	8b 45 08             	mov    0x8(%ebp),%eax
  801f47:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801f4a:	6a 01                	push   $0x1
  801f4c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f4f:	50                   	push   %eax
  801f50:	e8 32 ed ff ff       	call   800c87 <sys_cputs>
}
  801f55:	83 c4 10             	add    $0x10,%esp
  801f58:	c9                   	leave  
  801f59:	c3                   	ret    

00801f5a <getchar>:
{
  801f5a:	55                   	push   %ebp
  801f5b:	89 e5                	mov    %esp,%ebp
  801f5d:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801f60:	6a 01                	push   $0x1
  801f62:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f65:	50                   	push   %eax
  801f66:	6a 00                	push   $0x0
  801f68:	e8 94 f6 ff ff       	call   801601 <read>
	if (r < 0)
  801f6d:	83 c4 10             	add    $0x10,%esp
  801f70:	85 c0                	test   %eax,%eax
  801f72:	78 08                	js     801f7c <getchar+0x22>
	if (r < 1)
  801f74:	85 c0                	test   %eax,%eax
  801f76:	7e 06                	jle    801f7e <getchar+0x24>
	return c;
  801f78:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801f7c:	c9                   	leave  
  801f7d:	c3                   	ret    
		return -E_EOF;
  801f7e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801f83:	eb f7                	jmp    801f7c <getchar+0x22>

00801f85 <iscons>:
{
  801f85:	55                   	push   %ebp
  801f86:	89 e5                	mov    %esp,%ebp
  801f88:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f8b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f8e:	50                   	push   %eax
  801f8f:	ff 75 08             	pushl  0x8(%ebp)
  801f92:	e8 f9 f3 ff ff       	call   801390 <fd_lookup>
  801f97:	83 c4 10             	add    $0x10,%esp
  801f9a:	85 c0                	test   %eax,%eax
  801f9c:	78 11                	js     801faf <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801f9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fa1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fa7:	39 10                	cmp    %edx,(%eax)
  801fa9:	0f 94 c0             	sete   %al
  801fac:	0f b6 c0             	movzbl %al,%eax
}
  801faf:	c9                   	leave  
  801fb0:	c3                   	ret    

00801fb1 <opencons>:
{
  801fb1:	55                   	push   %ebp
  801fb2:	89 e5                	mov    %esp,%ebp
  801fb4:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801fb7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fba:	50                   	push   %eax
  801fbb:	e8 81 f3 ff ff       	call   801341 <fd_alloc>
  801fc0:	83 c4 10             	add    $0x10,%esp
  801fc3:	85 c0                	test   %eax,%eax
  801fc5:	78 3a                	js     802001 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fc7:	83 ec 04             	sub    $0x4,%esp
  801fca:	68 07 04 00 00       	push   $0x407
  801fcf:	ff 75 f4             	pushl  -0xc(%ebp)
  801fd2:	6a 00                	push   $0x0
  801fd4:	e8 6a ed ff ff       	call   800d43 <sys_page_alloc>
  801fd9:	83 c4 10             	add    $0x10,%esp
  801fdc:	85 c0                	test   %eax,%eax
  801fde:	78 21                	js     802001 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801fe0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fe3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fe9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801feb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fee:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ff5:	83 ec 0c             	sub    $0xc,%esp
  801ff8:	50                   	push   %eax
  801ff9:	e8 1c f3 ff ff       	call   80131a <fd2num>
  801ffe:	83 c4 10             	add    $0x10,%esp
}
  802001:	c9                   	leave  
  802002:	c3                   	ret    

00802003 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802003:	55                   	push   %ebp
  802004:	89 e5                	mov    %esp,%ebp
  802006:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802009:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802010:	74 20                	je     802032 <set_pgfault_handler+0x2f>
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
			panic("set_pgfault_handler:sys_page_alloc failed");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802012:	8b 45 08             	mov    0x8(%ebp),%eax
  802015:	a3 00 60 80 00       	mov    %eax,0x806000
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  80201a:	83 ec 08             	sub    $0x8,%esp
  80201d:	68 72 20 80 00       	push   $0x802072
  802022:	6a 00                	push   $0x0
  802024:	e8 65 ee ff ff       	call   800e8e <sys_env_set_pgfault_upcall>
  802029:	83 c4 10             	add    $0x10,%esp
  80202c:	85 c0                	test   %eax,%eax
  80202e:	78 2e                	js     80205e <set_pgfault_handler+0x5b>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
}
  802030:	c9                   	leave  
  802031:	c3                   	ret    
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  802032:	83 ec 04             	sub    $0x4,%esp
  802035:	6a 07                	push   $0x7
  802037:	68 00 f0 bf ee       	push   $0xeebff000
  80203c:	6a 00                	push   $0x0
  80203e:	e8 00 ed ff ff       	call   800d43 <sys_page_alloc>
  802043:	83 c4 10             	add    $0x10,%esp
  802046:	85 c0                	test   %eax,%eax
  802048:	79 c8                	jns    802012 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler:sys_page_alloc failed");
  80204a:	83 ec 04             	sub    $0x4,%esp
  80204d:	68 cc 28 80 00       	push   $0x8028cc
  802052:	6a 21                	push   $0x21
  802054:	68 30 29 80 00       	push   $0x802930
  802059:	e8 f2 e1 ff ff       	call   800250 <_panic>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  80205e:	83 ec 04             	sub    $0x4,%esp
  802061:	68 f8 28 80 00       	push   $0x8028f8
  802066:	6a 27                	push   $0x27
  802068:	68 30 29 80 00       	push   $0x802930
  80206d:	e8 de e1 ff ff       	call   800250 <_panic>

00802072 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802072:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802073:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802078:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80207a:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %eax
  80207d:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  802081:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  802084:	89 44 24 30          	mov    %eax,0x30(%esp)
	movl 40(%esp), %ebx
  802088:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  80208c:	89 18                	mov    %ebx,(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  80208e:	83 c4 08             	add    $0x8,%esp
	popal
  802091:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  802092:	83 c4 04             	add    $0x4,%esp
	popfl
  802095:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802096:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802097:	c3                   	ret    
  802098:	66 90                	xchg   %ax,%ax
  80209a:	66 90                	xchg   %ax,%ax
  80209c:	66 90                	xchg   %ax,%ax
  80209e:	66 90                	xchg   %ax,%ax

008020a0 <__udivdi3>:
  8020a0:	55                   	push   %ebp
  8020a1:	57                   	push   %edi
  8020a2:	56                   	push   %esi
  8020a3:	53                   	push   %ebx
  8020a4:	83 ec 1c             	sub    $0x1c,%esp
  8020a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020ab:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8020af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020b3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8020b7:	85 d2                	test   %edx,%edx
  8020b9:	75 35                	jne    8020f0 <__udivdi3+0x50>
  8020bb:	39 f3                	cmp    %esi,%ebx
  8020bd:	0f 87 bd 00 00 00    	ja     802180 <__udivdi3+0xe0>
  8020c3:	85 db                	test   %ebx,%ebx
  8020c5:	89 d9                	mov    %ebx,%ecx
  8020c7:	75 0b                	jne    8020d4 <__udivdi3+0x34>
  8020c9:	b8 01 00 00 00       	mov    $0x1,%eax
  8020ce:	31 d2                	xor    %edx,%edx
  8020d0:	f7 f3                	div    %ebx
  8020d2:	89 c1                	mov    %eax,%ecx
  8020d4:	31 d2                	xor    %edx,%edx
  8020d6:	89 f0                	mov    %esi,%eax
  8020d8:	f7 f1                	div    %ecx
  8020da:	89 c6                	mov    %eax,%esi
  8020dc:	89 e8                	mov    %ebp,%eax
  8020de:	89 f7                	mov    %esi,%edi
  8020e0:	f7 f1                	div    %ecx
  8020e2:	89 fa                	mov    %edi,%edx
  8020e4:	83 c4 1c             	add    $0x1c,%esp
  8020e7:	5b                   	pop    %ebx
  8020e8:	5e                   	pop    %esi
  8020e9:	5f                   	pop    %edi
  8020ea:	5d                   	pop    %ebp
  8020eb:	c3                   	ret    
  8020ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020f0:	39 f2                	cmp    %esi,%edx
  8020f2:	77 7c                	ja     802170 <__udivdi3+0xd0>
  8020f4:	0f bd fa             	bsr    %edx,%edi
  8020f7:	83 f7 1f             	xor    $0x1f,%edi
  8020fa:	0f 84 98 00 00 00    	je     802198 <__udivdi3+0xf8>
  802100:	89 f9                	mov    %edi,%ecx
  802102:	b8 20 00 00 00       	mov    $0x20,%eax
  802107:	29 f8                	sub    %edi,%eax
  802109:	d3 e2                	shl    %cl,%edx
  80210b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80210f:	89 c1                	mov    %eax,%ecx
  802111:	89 da                	mov    %ebx,%edx
  802113:	d3 ea                	shr    %cl,%edx
  802115:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802119:	09 d1                	or     %edx,%ecx
  80211b:	89 f2                	mov    %esi,%edx
  80211d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802121:	89 f9                	mov    %edi,%ecx
  802123:	d3 e3                	shl    %cl,%ebx
  802125:	89 c1                	mov    %eax,%ecx
  802127:	d3 ea                	shr    %cl,%edx
  802129:	89 f9                	mov    %edi,%ecx
  80212b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80212f:	d3 e6                	shl    %cl,%esi
  802131:	89 eb                	mov    %ebp,%ebx
  802133:	89 c1                	mov    %eax,%ecx
  802135:	d3 eb                	shr    %cl,%ebx
  802137:	09 de                	or     %ebx,%esi
  802139:	89 f0                	mov    %esi,%eax
  80213b:	f7 74 24 08          	divl   0x8(%esp)
  80213f:	89 d6                	mov    %edx,%esi
  802141:	89 c3                	mov    %eax,%ebx
  802143:	f7 64 24 0c          	mull   0xc(%esp)
  802147:	39 d6                	cmp    %edx,%esi
  802149:	72 0c                	jb     802157 <__udivdi3+0xb7>
  80214b:	89 f9                	mov    %edi,%ecx
  80214d:	d3 e5                	shl    %cl,%ebp
  80214f:	39 c5                	cmp    %eax,%ebp
  802151:	73 5d                	jae    8021b0 <__udivdi3+0x110>
  802153:	39 d6                	cmp    %edx,%esi
  802155:	75 59                	jne    8021b0 <__udivdi3+0x110>
  802157:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80215a:	31 ff                	xor    %edi,%edi
  80215c:	89 fa                	mov    %edi,%edx
  80215e:	83 c4 1c             	add    $0x1c,%esp
  802161:	5b                   	pop    %ebx
  802162:	5e                   	pop    %esi
  802163:	5f                   	pop    %edi
  802164:	5d                   	pop    %ebp
  802165:	c3                   	ret    
  802166:	8d 76 00             	lea    0x0(%esi),%esi
  802169:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802170:	31 ff                	xor    %edi,%edi
  802172:	31 c0                	xor    %eax,%eax
  802174:	89 fa                	mov    %edi,%edx
  802176:	83 c4 1c             	add    $0x1c,%esp
  802179:	5b                   	pop    %ebx
  80217a:	5e                   	pop    %esi
  80217b:	5f                   	pop    %edi
  80217c:	5d                   	pop    %ebp
  80217d:	c3                   	ret    
  80217e:	66 90                	xchg   %ax,%ax
  802180:	31 ff                	xor    %edi,%edi
  802182:	89 e8                	mov    %ebp,%eax
  802184:	89 f2                	mov    %esi,%edx
  802186:	f7 f3                	div    %ebx
  802188:	89 fa                	mov    %edi,%edx
  80218a:	83 c4 1c             	add    $0x1c,%esp
  80218d:	5b                   	pop    %ebx
  80218e:	5e                   	pop    %esi
  80218f:	5f                   	pop    %edi
  802190:	5d                   	pop    %ebp
  802191:	c3                   	ret    
  802192:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802198:	39 f2                	cmp    %esi,%edx
  80219a:	72 06                	jb     8021a2 <__udivdi3+0x102>
  80219c:	31 c0                	xor    %eax,%eax
  80219e:	39 eb                	cmp    %ebp,%ebx
  8021a0:	77 d2                	ja     802174 <__udivdi3+0xd4>
  8021a2:	b8 01 00 00 00       	mov    $0x1,%eax
  8021a7:	eb cb                	jmp    802174 <__udivdi3+0xd4>
  8021a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021b0:	89 d8                	mov    %ebx,%eax
  8021b2:	31 ff                	xor    %edi,%edi
  8021b4:	eb be                	jmp    802174 <__udivdi3+0xd4>
  8021b6:	66 90                	xchg   %ax,%ax
  8021b8:	66 90                	xchg   %ax,%ax
  8021ba:	66 90                	xchg   %ax,%ax
  8021bc:	66 90                	xchg   %ax,%ax
  8021be:	66 90                	xchg   %ax,%ax

008021c0 <__umoddi3>:
  8021c0:	55                   	push   %ebp
  8021c1:	57                   	push   %edi
  8021c2:	56                   	push   %esi
  8021c3:	53                   	push   %ebx
  8021c4:	83 ec 1c             	sub    $0x1c,%esp
  8021c7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8021cb:	8b 74 24 30          	mov    0x30(%esp),%esi
  8021cf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8021d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021d7:	85 ed                	test   %ebp,%ebp
  8021d9:	89 f0                	mov    %esi,%eax
  8021db:	89 da                	mov    %ebx,%edx
  8021dd:	75 19                	jne    8021f8 <__umoddi3+0x38>
  8021df:	39 df                	cmp    %ebx,%edi
  8021e1:	0f 86 b1 00 00 00    	jbe    802298 <__umoddi3+0xd8>
  8021e7:	f7 f7                	div    %edi
  8021e9:	89 d0                	mov    %edx,%eax
  8021eb:	31 d2                	xor    %edx,%edx
  8021ed:	83 c4 1c             	add    $0x1c,%esp
  8021f0:	5b                   	pop    %ebx
  8021f1:	5e                   	pop    %esi
  8021f2:	5f                   	pop    %edi
  8021f3:	5d                   	pop    %ebp
  8021f4:	c3                   	ret    
  8021f5:	8d 76 00             	lea    0x0(%esi),%esi
  8021f8:	39 dd                	cmp    %ebx,%ebp
  8021fa:	77 f1                	ja     8021ed <__umoddi3+0x2d>
  8021fc:	0f bd cd             	bsr    %ebp,%ecx
  8021ff:	83 f1 1f             	xor    $0x1f,%ecx
  802202:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802206:	0f 84 b4 00 00 00    	je     8022c0 <__umoddi3+0x100>
  80220c:	b8 20 00 00 00       	mov    $0x20,%eax
  802211:	89 c2                	mov    %eax,%edx
  802213:	8b 44 24 04          	mov    0x4(%esp),%eax
  802217:	29 c2                	sub    %eax,%edx
  802219:	89 c1                	mov    %eax,%ecx
  80221b:	89 f8                	mov    %edi,%eax
  80221d:	d3 e5                	shl    %cl,%ebp
  80221f:	89 d1                	mov    %edx,%ecx
  802221:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802225:	d3 e8                	shr    %cl,%eax
  802227:	09 c5                	or     %eax,%ebp
  802229:	8b 44 24 04          	mov    0x4(%esp),%eax
  80222d:	89 c1                	mov    %eax,%ecx
  80222f:	d3 e7                	shl    %cl,%edi
  802231:	89 d1                	mov    %edx,%ecx
  802233:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802237:	89 df                	mov    %ebx,%edi
  802239:	d3 ef                	shr    %cl,%edi
  80223b:	89 c1                	mov    %eax,%ecx
  80223d:	89 f0                	mov    %esi,%eax
  80223f:	d3 e3                	shl    %cl,%ebx
  802241:	89 d1                	mov    %edx,%ecx
  802243:	89 fa                	mov    %edi,%edx
  802245:	d3 e8                	shr    %cl,%eax
  802247:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80224c:	09 d8                	or     %ebx,%eax
  80224e:	f7 f5                	div    %ebp
  802250:	d3 e6                	shl    %cl,%esi
  802252:	89 d1                	mov    %edx,%ecx
  802254:	f7 64 24 08          	mull   0x8(%esp)
  802258:	39 d1                	cmp    %edx,%ecx
  80225a:	89 c3                	mov    %eax,%ebx
  80225c:	89 d7                	mov    %edx,%edi
  80225e:	72 06                	jb     802266 <__umoddi3+0xa6>
  802260:	75 0e                	jne    802270 <__umoddi3+0xb0>
  802262:	39 c6                	cmp    %eax,%esi
  802264:	73 0a                	jae    802270 <__umoddi3+0xb0>
  802266:	2b 44 24 08          	sub    0x8(%esp),%eax
  80226a:	19 ea                	sbb    %ebp,%edx
  80226c:	89 d7                	mov    %edx,%edi
  80226e:	89 c3                	mov    %eax,%ebx
  802270:	89 ca                	mov    %ecx,%edx
  802272:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  802277:	29 de                	sub    %ebx,%esi
  802279:	19 fa                	sbb    %edi,%edx
  80227b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80227f:	89 d0                	mov    %edx,%eax
  802281:	d3 e0                	shl    %cl,%eax
  802283:	89 d9                	mov    %ebx,%ecx
  802285:	d3 ee                	shr    %cl,%esi
  802287:	d3 ea                	shr    %cl,%edx
  802289:	09 f0                	or     %esi,%eax
  80228b:	83 c4 1c             	add    $0x1c,%esp
  80228e:	5b                   	pop    %ebx
  80228f:	5e                   	pop    %esi
  802290:	5f                   	pop    %edi
  802291:	5d                   	pop    %ebp
  802292:	c3                   	ret    
  802293:	90                   	nop
  802294:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802298:	85 ff                	test   %edi,%edi
  80229a:	89 f9                	mov    %edi,%ecx
  80229c:	75 0b                	jne    8022a9 <__umoddi3+0xe9>
  80229e:	b8 01 00 00 00       	mov    $0x1,%eax
  8022a3:	31 d2                	xor    %edx,%edx
  8022a5:	f7 f7                	div    %edi
  8022a7:	89 c1                	mov    %eax,%ecx
  8022a9:	89 d8                	mov    %ebx,%eax
  8022ab:	31 d2                	xor    %edx,%edx
  8022ad:	f7 f1                	div    %ecx
  8022af:	89 f0                	mov    %esi,%eax
  8022b1:	f7 f1                	div    %ecx
  8022b3:	e9 31 ff ff ff       	jmp    8021e9 <__umoddi3+0x29>
  8022b8:	90                   	nop
  8022b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022c0:	39 dd                	cmp    %ebx,%ebp
  8022c2:	72 08                	jb     8022cc <__umoddi3+0x10c>
  8022c4:	39 f7                	cmp    %esi,%edi
  8022c6:	0f 87 21 ff ff ff    	ja     8021ed <__umoddi3+0x2d>
  8022cc:	89 da                	mov    %ebx,%edx
  8022ce:	89 f0                	mov    %esi,%eax
  8022d0:	29 f8                	sub    %edi,%eax
  8022d2:	19 ea                	sbb    %ebp,%edx
  8022d4:	e9 14 ff ff ff       	jmp    8021ed <__umoddi3+0x2d>
