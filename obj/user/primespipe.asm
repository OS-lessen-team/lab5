
obj/user/primespipe.debug：     文件格式 elf32-i386


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
  80002c:	e8 04 02 00 00       	call   800235 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(int fd)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  80003f:	8d 75 e0             	lea    -0x20(%ebp),%esi
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);

	cprintf("%d\n", p);

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800042:	8d 7d d8             	lea    -0x28(%ebp),%edi
	if ((r = readn(fd, &p, 4)) != 4)
  800045:	83 ec 04             	sub    $0x4,%esp
  800048:	6a 04                	push   $0x4
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	e8 88 15 00 00       	call   8015d9 <readn>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	83 f8 04             	cmp    $0x4,%eax
  800057:	75 4b                	jne    8000a4 <primeproc+0x71>
	cprintf("%d\n", p);
  800059:	83 ec 08             	sub    $0x8,%esp
  80005c:	ff 75 e0             	pushl  -0x20(%ebp)
  80005f:	68 61 23 80 00       	push   $0x802361
  800064:	e8 07 03 00 00       	call   800370 <cprintf>
	if ((i=pipe(pfd)) < 0)
  800069:	89 3c 24             	mov    %edi,(%esp)
  80006c:	e8 af 1b 00 00       	call   801c20 <pipe>
  800071:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800074:	83 c4 10             	add    $0x10,%esp
  800077:	85 c0                	test   %eax,%eax
  800079:	78 49                	js     8000c4 <primeproc+0x91>
		panic("pipe: %e", i);
	if ((id = fork()) < 0)
  80007b:	e8 fb 0f 00 00       	call   80107b <fork>
  800080:	85 c0                	test   %eax,%eax
  800082:	78 52                	js     8000d6 <primeproc+0xa3>
		panic("fork: %e", id);
	if (id == 0) {
  800084:	85 c0                	test   %eax,%eax
  800086:	75 60                	jne    8000e8 <primeproc+0xb5>
		close(fd);
  800088:	83 ec 0c             	sub    $0xc,%esp
  80008b:	53                   	push   %ebx
  80008c:	e8 85 13 00 00       	call   801416 <close>
		close(pfd[1]);
  800091:	83 c4 04             	add    $0x4,%esp
  800094:	ff 75 dc             	pushl  -0x24(%ebp)
  800097:	e8 7a 13 00 00       	call   801416 <close>
		fd = pfd[0];
  80009c:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		goto top;
  80009f:	83 c4 10             	add    $0x10,%esp
  8000a2:	eb a1                	jmp    800045 <primeproc+0x12>
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);
  8000a4:	83 ec 0c             	sub    $0xc,%esp
  8000a7:	85 c0                	test   %eax,%eax
  8000a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ae:	0f 4e d0             	cmovle %eax,%edx
  8000b1:	52                   	push   %edx
  8000b2:	50                   	push   %eax
  8000b3:	68 20 23 80 00       	push   $0x802320
  8000b8:	6a 15                	push   $0x15
  8000ba:	68 4f 23 80 00       	push   $0x80234f
  8000bf:	e8 d1 01 00 00       	call   800295 <_panic>
		panic("pipe: %e", i);
  8000c4:	50                   	push   %eax
  8000c5:	68 65 23 80 00       	push   $0x802365
  8000ca:	6a 1b                	push   $0x1b
  8000cc:	68 4f 23 80 00       	push   $0x80234f
  8000d1:	e8 bf 01 00 00       	call   800295 <_panic>
		panic("fork: %e", id);
  8000d6:	50                   	push   %eax
  8000d7:	68 79 27 80 00       	push   $0x802779
  8000dc:	6a 1d                	push   $0x1d
  8000de:	68 4f 23 80 00       	push   $0x80234f
  8000e3:	e8 ad 01 00 00       	call   800295 <_panic>
	}

	close(pfd[0]);
  8000e8:	83 ec 0c             	sub    $0xc,%esp
  8000eb:	ff 75 d8             	pushl  -0x28(%ebp)
  8000ee:	e8 23 13 00 00       	call   801416 <close>
	wfd = pfd[1];
  8000f3:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8000f6:	83 c4 10             	add    $0x10,%esp

	// filter out multiples of our prime
	for (;;) {
		if ((r=readn(fd, &i, 4)) != 4)
  8000f9:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8000fc:	83 ec 04             	sub    $0x4,%esp
  8000ff:	6a 04                	push   $0x4
  800101:	56                   	push   %esi
  800102:	53                   	push   %ebx
  800103:	e8 d1 14 00 00       	call   8015d9 <readn>
  800108:	83 c4 10             	add    $0x10,%esp
  80010b:	83 f8 04             	cmp    $0x4,%eax
  80010e:	75 42                	jne    800152 <primeproc+0x11f>
			panic("primeproc %d readn %d %d %e", p, fd, r, r >= 0 ? 0 : r);
		if (i%p)
  800110:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800113:	99                   	cltd   
  800114:	f7 7d e0             	idivl  -0x20(%ebp)
  800117:	85 d2                	test   %edx,%edx
  800119:	74 e1                	je     8000fc <primeproc+0xc9>
			if ((r=write(wfd, &i, 4)) != 4)
  80011b:	83 ec 04             	sub    $0x4,%esp
  80011e:	6a 04                	push   $0x4
  800120:	56                   	push   %esi
  800121:	57                   	push   %edi
  800122:	e8 f9 14 00 00       	call   801620 <write>
  800127:	83 c4 10             	add    $0x10,%esp
  80012a:	83 f8 04             	cmp    $0x4,%eax
  80012d:	74 cd                	je     8000fc <primeproc+0xc9>
				panic("primeproc %d write: %d %e", p, r, r >= 0 ? 0 : r);
  80012f:	83 ec 08             	sub    $0x8,%esp
  800132:	85 c0                	test   %eax,%eax
  800134:	ba 00 00 00 00       	mov    $0x0,%edx
  800139:	0f 4e d0             	cmovle %eax,%edx
  80013c:	52                   	push   %edx
  80013d:	50                   	push   %eax
  80013e:	ff 75 e0             	pushl  -0x20(%ebp)
  800141:	68 8a 23 80 00       	push   $0x80238a
  800146:	6a 2e                	push   $0x2e
  800148:	68 4f 23 80 00       	push   $0x80234f
  80014d:	e8 43 01 00 00       	call   800295 <_panic>
			panic("primeproc %d readn %d %d %e", p, fd, r, r >= 0 ? 0 : r);
  800152:	83 ec 04             	sub    $0x4,%esp
  800155:	85 c0                	test   %eax,%eax
  800157:	ba 00 00 00 00       	mov    $0x0,%edx
  80015c:	0f 4e d0             	cmovle %eax,%edx
  80015f:	52                   	push   %edx
  800160:	50                   	push   %eax
  800161:	53                   	push   %ebx
  800162:	ff 75 e0             	pushl  -0x20(%ebp)
  800165:	68 6e 23 80 00       	push   $0x80236e
  80016a:	6a 2b                	push   $0x2b
  80016c:	68 4f 23 80 00       	push   $0x80234f
  800171:	e8 1f 01 00 00       	call   800295 <_panic>

00800176 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  800176:	55                   	push   %ebp
  800177:	89 e5                	mov    %esp,%ebp
  800179:	53                   	push   %ebx
  80017a:	83 ec 20             	sub    $0x20,%esp
	int i, id, p[2], r;

	binaryname = "primespipe";
  80017d:	c7 05 00 30 80 00 a4 	movl   $0x8023a4,0x803000
  800184:	23 80 00 

	if ((i=pipe(p)) < 0)
  800187:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80018a:	50                   	push   %eax
  80018b:	e8 90 1a 00 00       	call   801c20 <pipe>
  800190:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800193:	83 c4 10             	add    $0x10,%esp
  800196:	85 c0                	test   %eax,%eax
  800198:	78 23                	js     8001bd <umain+0x47>
		panic("pipe: %e", i);

	// fork the first prime process in the chain
	if ((id=fork()) < 0)
  80019a:	e8 dc 0e 00 00       	call   80107b <fork>
  80019f:	85 c0                	test   %eax,%eax
  8001a1:	78 2c                	js     8001cf <umain+0x59>
		panic("fork: %e", id);

	if (id == 0) {
  8001a3:	85 c0                	test   %eax,%eax
  8001a5:	75 3a                	jne    8001e1 <umain+0x6b>
		close(p[1]);
  8001a7:	83 ec 0c             	sub    $0xc,%esp
  8001aa:	ff 75 f0             	pushl  -0x10(%ebp)
  8001ad:	e8 64 12 00 00       	call   801416 <close>
		primeproc(p[0]);
  8001b2:	83 c4 04             	add    $0x4,%esp
  8001b5:	ff 75 ec             	pushl  -0x14(%ebp)
  8001b8:	e8 76 fe ff ff       	call   800033 <primeproc>
		panic("pipe: %e", i);
  8001bd:	50                   	push   %eax
  8001be:	68 65 23 80 00       	push   $0x802365
  8001c3:	6a 3a                	push   $0x3a
  8001c5:	68 4f 23 80 00       	push   $0x80234f
  8001ca:	e8 c6 00 00 00       	call   800295 <_panic>
		panic("fork: %e", id);
  8001cf:	50                   	push   %eax
  8001d0:	68 79 27 80 00       	push   $0x802779
  8001d5:	6a 3e                	push   $0x3e
  8001d7:	68 4f 23 80 00       	push   $0x80234f
  8001dc:	e8 b4 00 00 00       	call   800295 <_panic>
	}

	close(p[0]);
  8001e1:	83 ec 0c             	sub    $0xc,%esp
  8001e4:	ff 75 ec             	pushl  -0x14(%ebp)
  8001e7:	e8 2a 12 00 00       	call   801416 <close>

	// feed all the integers through
	for (i=2;; i++)
  8001ec:	c7 45 f4 02 00 00 00 	movl   $0x2,-0xc(%ebp)
  8001f3:	83 c4 10             	add    $0x10,%esp
		if ((r=write(p[1], &i, 4)) != 4)
  8001f6:	8d 5d f4             	lea    -0xc(%ebp),%ebx
  8001f9:	83 ec 04             	sub    $0x4,%esp
  8001fc:	6a 04                	push   $0x4
  8001fe:	53                   	push   %ebx
  8001ff:	ff 75 f0             	pushl  -0x10(%ebp)
  800202:	e8 19 14 00 00       	call   801620 <write>
  800207:	83 c4 10             	add    $0x10,%esp
  80020a:	83 f8 04             	cmp    $0x4,%eax
  80020d:	75 06                	jne    800215 <umain+0x9f>
	for (i=2;; i++)
  80020f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
		if ((r=write(p[1], &i, 4)) != 4)
  800213:	eb e4                	jmp    8001f9 <umain+0x83>
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
  800215:	83 ec 0c             	sub    $0xc,%esp
  800218:	85 c0                	test   %eax,%eax
  80021a:	ba 00 00 00 00       	mov    $0x0,%edx
  80021f:	0f 4e d0             	cmovle %eax,%edx
  800222:	52                   	push   %edx
  800223:	50                   	push   %eax
  800224:	68 af 23 80 00       	push   $0x8023af
  800229:	6a 4a                	push   $0x4a
  80022b:	68 4f 23 80 00       	push   $0x80234f
  800230:	e8 60 00 00 00       	call   800295 <_panic>

00800235 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800235:	55                   	push   %ebp
  800236:	89 e5                	mov    %esp,%ebp
  800238:	56                   	push   %esi
  800239:	53                   	push   %ebx
  80023a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80023d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800240:	e8 05 0b 00 00       	call   800d4a <sys_getenvid>
	thisenv = envs + ENVX(envid); 
  800245:	25 ff 03 00 00       	and    $0x3ff,%eax
  80024a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80024d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800252:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800257:	85 db                	test   %ebx,%ebx
  800259:	7e 07                	jle    800262 <libmain+0x2d>
		binaryname = argv[0];
  80025b:	8b 06                	mov    (%esi),%eax
  80025d:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800262:	83 ec 08             	sub    $0x8,%esp
  800265:	56                   	push   %esi
  800266:	53                   	push   %ebx
  800267:	e8 0a ff ff ff       	call   800176 <umain>

	// exit gracefully
	exit();
  80026c:	e8 0a 00 00 00       	call   80027b <exit>
}
  800271:	83 c4 10             	add    $0x10,%esp
  800274:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800277:	5b                   	pop    %ebx
  800278:	5e                   	pop    %esi
  800279:	5d                   	pop    %ebp
  80027a:	c3                   	ret    

0080027b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80027b:	55                   	push   %ebp
  80027c:	89 e5                	mov    %esp,%ebp
  80027e:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800281:	e8 bb 11 00 00       	call   801441 <close_all>
	sys_env_destroy(0);
  800286:	83 ec 0c             	sub    $0xc,%esp
  800289:	6a 00                	push   $0x0
  80028b:	e8 79 0a 00 00       	call   800d09 <sys_env_destroy>
}
  800290:	83 c4 10             	add    $0x10,%esp
  800293:	c9                   	leave  
  800294:	c3                   	ret    

00800295 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800295:	55                   	push   %ebp
  800296:	89 e5                	mov    %esp,%ebp
  800298:	56                   	push   %esi
  800299:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80029a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80029d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8002a3:	e8 a2 0a 00 00       	call   800d4a <sys_getenvid>
  8002a8:	83 ec 0c             	sub    $0xc,%esp
  8002ab:	ff 75 0c             	pushl  0xc(%ebp)
  8002ae:	ff 75 08             	pushl  0x8(%ebp)
  8002b1:	56                   	push   %esi
  8002b2:	50                   	push   %eax
  8002b3:	68 d4 23 80 00       	push   $0x8023d4
  8002b8:	e8 b3 00 00 00       	call   800370 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002bd:	83 c4 18             	add    $0x18,%esp
  8002c0:	53                   	push   %ebx
  8002c1:	ff 75 10             	pushl  0x10(%ebp)
  8002c4:	e8 56 00 00 00       	call   80031f <vcprintf>
	cprintf("\n");
  8002c9:	c7 04 24 63 23 80 00 	movl   $0x802363,(%esp)
  8002d0:	e8 9b 00 00 00       	call   800370 <cprintf>
  8002d5:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002d8:	cc                   	int3   
  8002d9:	eb fd                	jmp    8002d8 <_panic+0x43>

008002db <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002db:	55                   	push   %ebp
  8002dc:	89 e5                	mov    %esp,%ebp
  8002de:	53                   	push   %ebx
  8002df:	83 ec 04             	sub    $0x4,%esp
  8002e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002e5:	8b 13                	mov    (%ebx),%edx
  8002e7:	8d 42 01             	lea    0x1(%edx),%eax
  8002ea:	89 03                	mov    %eax,(%ebx)
  8002ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002ef:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002f3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002f8:	74 09                	je     800303 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8002fa:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800301:	c9                   	leave  
  800302:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800303:	83 ec 08             	sub    $0x8,%esp
  800306:	68 ff 00 00 00       	push   $0xff
  80030b:	8d 43 08             	lea    0x8(%ebx),%eax
  80030e:	50                   	push   %eax
  80030f:	e8 b8 09 00 00       	call   800ccc <sys_cputs>
		b->idx = 0;
  800314:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80031a:	83 c4 10             	add    $0x10,%esp
  80031d:	eb db                	jmp    8002fa <putch+0x1f>

0080031f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80031f:	55                   	push   %ebp
  800320:	89 e5                	mov    %esp,%ebp
  800322:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800328:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80032f:	00 00 00 
	b.cnt = 0;
  800332:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800339:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80033c:	ff 75 0c             	pushl  0xc(%ebp)
  80033f:	ff 75 08             	pushl  0x8(%ebp)
  800342:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800348:	50                   	push   %eax
  800349:	68 db 02 80 00       	push   $0x8002db
  80034e:	e8 1a 01 00 00       	call   80046d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800353:	83 c4 08             	add    $0x8,%esp
  800356:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80035c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800362:	50                   	push   %eax
  800363:	e8 64 09 00 00       	call   800ccc <sys_cputs>

	return b.cnt;
}
  800368:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80036e:	c9                   	leave  
  80036f:	c3                   	ret    

00800370 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800370:	55                   	push   %ebp
  800371:	89 e5                	mov    %esp,%ebp
  800373:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800376:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800379:	50                   	push   %eax
  80037a:	ff 75 08             	pushl  0x8(%ebp)
  80037d:	e8 9d ff ff ff       	call   80031f <vcprintf>
	va_end(ap);

	return cnt;
}
  800382:	c9                   	leave  
  800383:	c3                   	ret    

00800384 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	57                   	push   %edi
  800388:	56                   	push   %esi
  800389:	53                   	push   %ebx
  80038a:	83 ec 1c             	sub    $0x1c,%esp
  80038d:	89 c7                	mov    %eax,%edi
  80038f:	89 d6                	mov    %edx,%esi
  800391:	8b 45 08             	mov    0x8(%ebp),%eax
  800394:	8b 55 0c             	mov    0xc(%ebp),%edx
  800397:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80039a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80039d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8003a0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003a5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003a8:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003ab:	39 d3                	cmp    %edx,%ebx
  8003ad:	72 05                	jb     8003b4 <printnum+0x30>
  8003af:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003b2:	77 7a                	ja     80042e <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003b4:	83 ec 0c             	sub    $0xc,%esp
  8003b7:	ff 75 18             	pushl  0x18(%ebp)
  8003ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bd:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003c0:	53                   	push   %ebx
  8003c1:	ff 75 10             	pushl  0x10(%ebp)
  8003c4:	83 ec 08             	sub    $0x8,%esp
  8003c7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ca:	ff 75 e0             	pushl  -0x20(%ebp)
  8003cd:	ff 75 dc             	pushl  -0x24(%ebp)
  8003d0:	ff 75 d8             	pushl  -0x28(%ebp)
  8003d3:	e8 08 1d 00 00       	call   8020e0 <__udivdi3>
  8003d8:	83 c4 18             	add    $0x18,%esp
  8003db:	52                   	push   %edx
  8003dc:	50                   	push   %eax
  8003dd:	89 f2                	mov    %esi,%edx
  8003df:	89 f8                	mov    %edi,%eax
  8003e1:	e8 9e ff ff ff       	call   800384 <printnum>
  8003e6:	83 c4 20             	add    $0x20,%esp
  8003e9:	eb 13                	jmp    8003fe <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003eb:	83 ec 08             	sub    $0x8,%esp
  8003ee:	56                   	push   %esi
  8003ef:	ff 75 18             	pushl  0x18(%ebp)
  8003f2:	ff d7                	call   *%edi
  8003f4:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8003f7:	83 eb 01             	sub    $0x1,%ebx
  8003fa:	85 db                	test   %ebx,%ebx
  8003fc:	7f ed                	jg     8003eb <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003fe:	83 ec 08             	sub    $0x8,%esp
  800401:	56                   	push   %esi
  800402:	83 ec 04             	sub    $0x4,%esp
  800405:	ff 75 e4             	pushl  -0x1c(%ebp)
  800408:	ff 75 e0             	pushl  -0x20(%ebp)
  80040b:	ff 75 dc             	pushl  -0x24(%ebp)
  80040e:	ff 75 d8             	pushl  -0x28(%ebp)
  800411:	e8 ea 1d 00 00       	call   802200 <__umoddi3>
  800416:	83 c4 14             	add    $0x14,%esp
  800419:	0f be 80 f7 23 80 00 	movsbl 0x8023f7(%eax),%eax
  800420:	50                   	push   %eax
  800421:	ff d7                	call   *%edi
}
  800423:	83 c4 10             	add    $0x10,%esp
  800426:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800429:	5b                   	pop    %ebx
  80042a:	5e                   	pop    %esi
  80042b:	5f                   	pop    %edi
  80042c:	5d                   	pop    %ebp
  80042d:	c3                   	ret    
  80042e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800431:	eb c4                	jmp    8003f7 <printnum+0x73>

00800433 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800433:	55                   	push   %ebp
  800434:	89 e5                	mov    %esp,%ebp
  800436:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800439:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80043d:	8b 10                	mov    (%eax),%edx
  80043f:	3b 50 04             	cmp    0x4(%eax),%edx
  800442:	73 0a                	jae    80044e <sprintputch+0x1b>
		*b->buf++ = ch;
  800444:	8d 4a 01             	lea    0x1(%edx),%ecx
  800447:	89 08                	mov    %ecx,(%eax)
  800449:	8b 45 08             	mov    0x8(%ebp),%eax
  80044c:	88 02                	mov    %al,(%edx)
}
  80044e:	5d                   	pop    %ebp
  80044f:	c3                   	ret    

00800450 <printfmt>:
{
  800450:	55                   	push   %ebp
  800451:	89 e5                	mov    %esp,%ebp
  800453:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800456:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800459:	50                   	push   %eax
  80045a:	ff 75 10             	pushl  0x10(%ebp)
  80045d:	ff 75 0c             	pushl  0xc(%ebp)
  800460:	ff 75 08             	pushl  0x8(%ebp)
  800463:	e8 05 00 00 00       	call   80046d <vprintfmt>
}
  800468:	83 c4 10             	add    $0x10,%esp
  80046b:	c9                   	leave  
  80046c:	c3                   	ret    

0080046d <vprintfmt>:
{
  80046d:	55                   	push   %ebp
  80046e:	89 e5                	mov    %esp,%ebp
  800470:	57                   	push   %edi
  800471:	56                   	push   %esi
  800472:	53                   	push   %ebx
  800473:	83 ec 2c             	sub    $0x2c,%esp
  800476:	8b 75 08             	mov    0x8(%ebp),%esi
  800479:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80047c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80047f:	e9 c1 03 00 00       	jmp    800845 <vprintfmt+0x3d8>
		padc = ' ';
  800484:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800488:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  80048f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800496:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80049d:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8004a2:	8d 47 01             	lea    0x1(%edi),%eax
  8004a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004a8:	0f b6 17             	movzbl (%edi),%edx
  8004ab:	8d 42 dd             	lea    -0x23(%edx),%eax
  8004ae:	3c 55                	cmp    $0x55,%al
  8004b0:	0f 87 12 04 00 00    	ja     8008c8 <vprintfmt+0x45b>
  8004b6:	0f b6 c0             	movzbl %al,%eax
  8004b9:	ff 24 85 40 25 80 00 	jmp    *0x802540(,%eax,4)
  8004c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8004c3:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8004c7:	eb d9                	jmp    8004a2 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8004c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  8004cc:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004d0:	eb d0                	jmp    8004a2 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8004d2:	0f b6 d2             	movzbl %dl,%edx
  8004d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8004d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004dd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8004e0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004e3:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8004e7:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8004ea:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8004ed:	83 f9 09             	cmp    $0x9,%ecx
  8004f0:	77 55                	ja     800547 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  8004f2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8004f5:	eb e9                	jmp    8004e0 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  8004f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fa:	8b 00                	mov    (%eax),%eax
  8004fc:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800502:	8d 40 04             	lea    0x4(%eax),%eax
  800505:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800508:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80050b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80050f:	79 91                	jns    8004a2 <vprintfmt+0x35>
				width = precision, precision = -1;
  800511:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800514:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800517:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80051e:	eb 82                	jmp    8004a2 <vprintfmt+0x35>
  800520:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800523:	85 c0                	test   %eax,%eax
  800525:	ba 00 00 00 00       	mov    $0x0,%edx
  80052a:	0f 49 d0             	cmovns %eax,%edx
  80052d:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800530:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800533:	e9 6a ff ff ff       	jmp    8004a2 <vprintfmt+0x35>
  800538:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80053b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800542:	e9 5b ff ff ff       	jmp    8004a2 <vprintfmt+0x35>
  800547:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80054a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80054d:	eb bc                	jmp    80050b <vprintfmt+0x9e>
			lflag++;
  80054f:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800552:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800555:	e9 48 ff ff ff       	jmp    8004a2 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  80055a:	8b 45 14             	mov    0x14(%ebp),%eax
  80055d:	8d 78 04             	lea    0x4(%eax),%edi
  800560:	83 ec 08             	sub    $0x8,%esp
  800563:	53                   	push   %ebx
  800564:	ff 30                	pushl  (%eax)
  800566:	ff d6                	call   *%esi
			break;
  800568:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80056b:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80056e:	e9 cf 02 00 00       	jmp    800842 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  800573:	8b 45 14             	mov    0x14(%ebp),%eax
  800576:	8d 78 04             	lea    0x4(%eax),%edi
  800579:	8b 00                	mov    (%eax),%eax
  80057b:	99                   	cltd   
  80057c:	31 d0                	xor    %edx,%eax
  80057e:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800580:	83 f8 0f             	cmp    $0xf,%eax
  800583:	7f 23                	jg     8005a8 <vprintfmt+0x13b>
  800585:	8b 14 85 a0 26 80 00 	mov    0x8026a0(,%eax,4),%edx
  80058c:	85 d2                	test   %edx,%edx
  80058e:	74 18                	je     8005a8 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800590:	52                   	push   %edx
  800591:	68 65 28 80 00       	push   $0x802865
  800596:	53                   	push   %ebx
  800597:	56                   	push   %esi
  800598:	e8 b3 fe ff ff       	call   800450 <printfmt>
  80059d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8005a0:	89 7d 14             	mov    %edi,0x14(%ebp)
  8005a3:	e9 9a 02 00 00       	jmp    800842 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  8005a8:	50                   	push   %eax
  8005a9:	68 0f 24 80 00       	push   $0x80240f
  8005ae:	53                   	push   %ebx
  8005af:	56                   	push   %esi
  8005b0:	e8 9b fe ff ff       	call   800450 <printfmt>
  8005b5:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8005b8:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8005bb:	e9 82 02 00 00       	jmp    800842 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  8005c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c3:	83 c0 04             	add    $0x4,%eax
  8005c6:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8005c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cc:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005ce:	85 ff                	test   %edi,%edi
  8005d0:	b8 08 24 80 00       	mov    $0x802408,%eax
  8005d5:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005d8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005dc:	0f 8e bd 00 00 00    	jle    80069f <vprintfmt+0x232>
  8005e2:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005e6:	75 0e                	jne    8005f6 <vprintfmt+0x189>
  8005e8:	89 75 08             	mov    %esi,0x8(%ebp)
  8005eb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005ee:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005f1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005f4:	eb 6d                	jmp    800663 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f6:	83 ec 08             	sub    $0x8,%esp
  8005f9:	ff 75 d0             	pushl  -0x30(%ebp)
  8005fc:	57                   	push   %edi
  8005fd:	e8 6e 03 00 00       	call   800970 <strnlen>
  800602:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800605:	29 c1                	sub    %eax,%ecx
  800607:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80060a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80060d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800611:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800614:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800617:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800619:	eb 0f                	jmp    80062a <vprintfmt+0x1bd>
					putch(padc, putdat);
  80061b:	83 ec 08             	sub    $0x8,%esp
  80061e:	53                   	push   %ebx
  80061f:	ff 75 e0             	pushl  -0x20(%ebp)
  800622:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800624:	83 ef 01             	sub    $0x1,%edi
  800627:	83 c4 10             	add    $0x10,%esp
  80062a:	85 ff                	test   %edi,%edi
  80062c:	7f ed                	jg     80061b <vprintfmt+0x1ae>
  80062e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800631:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800634:	85 c9                	test   %ecx,%ecx
  800636:	b8 00 00 00 00       	mov    $0x0,%eax
  80063b:	0f 49 c1             	cmovns %ecx,%eax
  80063e:	29 c1                	sub    %eax,%ecx
  800640:	89 75 08             	mov    %esi,0x8(%ebp)
  800643:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800646:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800649:	89 cb                	mov    %ecx,%ebx
  80064b:	eb 16                	jmp    800663 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  80064d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800651:	75 31                	jne    800684 <vprintfmt+0x217>
					putch(ch, putdat);
  800653:	83 ec 08             	sub    $0x8,%esp
  800656:	ff 75 0c             	pushl  0xc(%ebp)
  800659:	50                   	push   %eax
  80065a:	ff 55 08             	call   *0x8(%ebp)
  80065d:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800660:	83 eb 01             	sub    $0x1,%ebx
  800663:	83 c7 01             	add    $0x1,%edi
  800666:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  80066a:	0f be c2             	movsbl %dl,%eax
  80066d:	85 c0                	test   %eax,%eax
  80066f:	74 59                	je     8006ca <vprintfmt+0x25d>
  800671:	85 f6                	test   %esi,%esi
  800673:	78 d8                	js     80064d <vprintfmt+0x1e0>
  800675:	83 ee 01             	sub    $0x1,%esi
  800678:	79 d3                	jns    80064d <vprintfmt+0x1e0>
  80067a:	89 df                	mov    %ebx,%edi
  80067c:	8b 75 08             	mov    0x8(%ebp),%esi
  80067f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800682:	eb 37                	jmp    8006bb <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  800684:	0f be d2             	movsbl %dl,%edx
  800687:	83 ea 20             	sub    $0x20,%edx
  80068a:	83 fa 5e             	cmp    $0x5e,%edx
  80068d:	76 c4                	jbe    800653 <vprintfmt+0x1e6>
					putch('?', putdat);
  80068f:	83 ec 08             	sub    $0x8,%esp
  800692:	ff 75 0c             	pushl  0xc(%ebp)
  800695:	6a 3f                	push   $0x3f
  800697:	ff 55 08             	call   *0x8(%ebp)
  80069a:	83 c4 10             	add    $0x10,%esp
  80069d:	eb c1                	jmp    800660 <vprintfmt+0x1f3>
  80069f:	89 75 08             	mov    %esi,0x8(%ebp)
  8006a2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006a5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006a8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006ab:	eb b6                	jmp    800663 <vprintfmt+0x1f6>
				putch(' ', putdat);
  8006ad:	83 ec 08             	sub    $0x8,%esp
  8006b0:	53                   	push   %ebx
  8006b1:	6a 20                	push   $0x20
  8006b3:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8006b5:	83 ef 01             	sub    $0x1,%edi
  8006b8:	83 c4 10             	add    $0x10,%esp
  8006bb:	85 ff                	test   %edi,%edi
  8006bd:	7f ee                	jg     8006ad <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  8006bf:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006c2:	89 45 14             	mov    %eax,0x14(%ebp)
  8006c5:	e9 78 01 00 00       	jmp    800842 <vprintfmt+0x3d5>
  8006ca:	89 df                	mov    %ebx,%edi
  8006cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8006cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006d2:	eb e7                	jmp    8006bb <vprintfmt+0x24e>
	if (lflag >= 2)
  8006d4:	83 f9 01             	cmp    $0x1,%ecx
  8006d7:	7e 3f                	jle    800718 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  8006d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006dc:	8b 50 04             	mov    0x4(%eax),%edx
  8006df:	8b 00                	mov    (%eax),%eax
  8006e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ea:	8d 40 08             	lea    0x8(%eax),%eax
  8006ed:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8006f0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006f4:	79 5c                	jns    800752 <vprintfmt+0x2e5>
				putch('-', putdat);
  8006f6:	83 ec 08             	sub    $0x8,%esp
  8006f9:	53                   	push   %ebx
  8006fa:	6a 2d                	push   $0x2d
  8006fc:	ff d6                	call   *%esi
				num = -(long long) num;
  8006fe:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800701:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800704:	f7 da                	neg    %edx
  800706:	83 d1 00             	adc    $0x0,%ecx
  800709:	f7 d9                	neg    %ecx
  80070b:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80070e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800713:	e9 10 01 00 00       	jmp    800828 <vprintfmt+0x3bb>
	else if (lflag)
  800718:	85 c9                	test   %ecx,%ecx
  80071a:	75 1b                	jne    800737 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  80071c:	8b 45 14             	mov    0x14(%ebp),%eax
  80071f:	8b 00                	mov    (%eax),%eax
  800721:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800724:	89 c1                	mov    %eax,%ecx
  800726:	c1 f9 1f             	sar    $0x1f,%ecx
  800729:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80072c:	8b 45 14             	mov    0x14(%ebp),%eax
  80072f:	8d 40 04             	lea    0x4(%eax),%eax
  800732:	89 45 14             	mov    %eax,0x14(%ebp)
  800735:	eb b9                	jmp    8006f0 <vprintfmt+0x283>
		return va_arg(*ap, long);
  800737:	8b 45 14             	mov    0x14(%ebp),%eax
  80073a:	8b 00                	mov    (%eax),%eax
  80073c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80073f:	89 c1                	mov    %eax,%ecx
  800741:	c1 f9 1f             	sar    $0x1f,%ecx
  800744:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800747:	8b 45 14             	mov    0x14(%ebp),%eax
  80074a:	8d 40 04             	lea    0x4(%eax),%eax
  80074d:	89 45 14             	mov    %eax,0x14(%ebp)
  800750:	eb 9e                	jmp    8006f0 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  800752:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800755:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800758:	b8 0a 00 00 00       	mov    $0xa,%eax
  80075d:	e9 c6 00 00 00       	jmp    800828 <vprintfmt+0x3bb>
	if (lflag >= 2)
  800762:	83 f9 01             	cmp    $0x1,%ecx
  800765:	7e 18                	jle    80077f <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  800767:	8b 45 14             	mov    0x14(%ebp),%eax
  80076a:	8b 10                	mov    (%eax),%edx
  80076c:	8b 48 04             	mov    0x4(%eax),%ecx
  80076f:	8d 40 08             	lea    0x8(%eax),%eax
  800772:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800775:	b8 0a 00 00 00       	mov    $0xa,%eax
  80077a:	e9 a9 00 00 00       	jmp    800828 <vprintfmt+0x3bb>
	else if (lflag)
  80077f:	85 c9                	test   %ecx,%ecx
  800781:	75 1a                	jne    80079d <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  800783:	8b 45 14             	mov    0x14(%ebp),%eax
  800786:	8b 10                	mov    (%eax),%edx
  800788:	b9 00 00 00 00       	mov    $0x0,%ecx
  80078d:	8d 40 04             	lea    0x4(%eax),%eax
  800790:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800793:	b8 0a 00 00 00       	mov    $0xa,%eax
  800798:	e9 8b 00 00 00       	jmp    800828 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80079d:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a0:	8b 10                	mov    (%eax),%edx
  8007a2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007a7:	8d 40 04             	lea    0x4(%eax),%eax
  8007aa:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007ad:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007b2:	eb 74                	jmp    800828 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8007b4:	83 f9 01             	cmp    $0x1,%ecx
  8007b7:	7e 15                	jle    8007ce <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  8007b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bc:	8b 10                	mov    (%eax),%edx
  8007be:	8b 48 04             	mov    0x4(%eax),%ecx
  8007c1:	8d 40 08             	lea    0x8(%eax),%eax
  8007c4:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8007c7:	b8 08 00 00 00       	mov    $0x8,%eax
  8007cc:	eb 5a                	jmp    800828 <vprintfmt+0x3bb>
	else if (lflag)
  8007ce:	85 c9                	test   %ecx,%ecx
  8007d0:	75 17                	jne    8007e9 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  8007d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d5:	8b 10                	mov    (%eax),%edx
  8007d7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007dc:	8d 40 04             	lea    0x4(%eax),%eax
  8007df:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8007e2:	b8 08 00 00 00       	mov    $0x8,%eax
  8007e7:	eb 3f                	jmp    800828 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8007e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ec:	8b 10                	mov    (%eax),%edx
  8007ee:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007f3:	8d 40 04             	lea    0x4(%eax),%eax
  8007f6:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8007f9:	b8 08 00 00 00       	mov    $0x8,%eax
  8007fe:	eb 28                	jmp    800828 <vprintfmt+0x3bb>
			putch('0', putdat);
  800800:	83 ec 08             	sub    $0x8,%esp
  800803:	53                   	push   %ebx
  800804:	6a 30                	push   $0x30
  800806:	ff d6                	call   *%esi
			putch('x', putdat);
  800808:	83 c4 08             	add    $0x8,%esp
  80080b:	53                   	push   %ebx
  80080c:	6a 78                	push   $0x78
  80080e:	ff d6                	call   *%esi
			num = (unsigned long long)
  800810:	8b 45 14             	mov    0x14(%ebp),%eax
  800813:	8b 10                	mov    (%eax),%edx
  800815:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80081a:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80081d:	8d 40 04             	lea    0x4(%eax),%eax
  800820:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800823:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800828:	83 ec 0c             	sub    $0xc,%esp
  80082b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80082f:	57                   	push   %edi
  800830:	ff 75 e0             	pushl  -0x20(%ebp)
  800833:	50                   	push   %eax
  800834:	51                   	push   %ecx
  800835:	52                   	push   %edx
  800836:	89 da                	mov    %ebx,%edx
  800838:	89 f0                	mov    %esi,%eax
  80083a:	e8 45 fb ff ff       	call   800384 <printnum>
			break;
  80083f:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800842:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800845:	83 c7 01             	add    $0x1,%edi
  800848:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80084c:	83 f8 25             	cmp    $0x25,%eax
  80084f:	0f 84 2f fc ff ff    	je     800484 <vprintfmt+0x17>
			if (ch == '\0')
  800855:	85 c0                	test   %eax,%eax
  800857:	0f 84 8b 00 00 00    	je     8008e8 <vprintfmt+0x47b>
			putch(ch, putdat);
  80085d:	83 ec 08             	sub    $0x8,%esp
  800860:	53                   	push   %ebx
  800861:	50                   	push   %eax
  800862:	ff d6                	call   *%esi
  800864:	83 c4 10             	add    $0x10,%esp
  800867:	eb dc                	jmp    800845 <vprintfmt+0x3d8>
	if (lflag >= 2)
  800869:	83 f9 01             	cmp    $0x1,%ecx
  80086c:	7e 15                	jle    800883 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  80086e:	8b 45 14             	mov    0x14(%ebp),%eax
  800871:	8b 10                	mov    (%eax),%edx
  800873:	8b 48 04             	mov    0x4(%eax),%ecx
  800876:	8d 40 08             	lea    0x8(%eax),%eax
  800879:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80087c:	b8 10 00 00 00       	mov    $0x10,%eax
  800881:	eb a5                	jmp    800828 <vprintfmt+0x3bb>
	else if (lflag)
  800883:	85 c9                	test   %ecx,%ecx
  800885:	75 17                	jne    80089e <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  800887:	8b 45 14             	mov    0x14(%ebp),%eax
  80088a:	8b 10                	mov    (%eax),%edx
  80088c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800891:	8d 40 04             	lea    0x4(%eax),%eax
  800894:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800897:	b8 10 00 00 00       	mov    $0x10,%eax
  80089c:	eb 8a                	jmp    800828 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80089e:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a1:	8b 10                	mov    (%eax),%edx
  8008a3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008a8:	8d 40 04             	lea    0x4(%eax),%eax
  8008ab:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008ae:	b8 10 00 00 00       	mov    $0x10,%eax
  8008b3:	e9 70 ff ff ff       	jmp    800828 <vprintfmt+0x3bb>
			putch(ch, putdat);
  8008b8:	83 ec 08             	sub    $0x8,%esp
  8008bb:	53                   	push   %ebx
  8008bc:	6a 25                	push   $0x25
  8008be:	ff d6                	call   *%esi
			break;
  8008c0:	83 c4 10             	add    $0x10,%esp
  8008c3:	e9 7a ff ff ff       	jmp    800842 <vprintfmt+0x3d5>
			putch('%', putdat);
  8008c8:	83 ec 08             	sub    $0x8,%esp
  8008cb:	53                   	push   %ebx
  8008cc:	6a 25                	push   $0x25
  8008ce:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008d0:	83 c4 10             	add    $0x10,%esp
  8008d3:	89 f8                	mov    %edi,%eax
  8008d5:	eb 03                	jmp    8008da <vprintfmt+0x46d>
  8008d7:	83 e8 01             	sub    $0x1,%eax
  8008da:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8008de:	75 f7                	jne    8008d7 <vprintfmt+0x46a>
  8008e0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008e3:	e9 5a ff ff ff       	jmp    800842 <vprintfmt+0x3d5>
}
  8008e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008eb:	5b                   	pop    %ebx
  8008ec:	5e                   	pop    %esi
  8008ed:	5f                   	pop    %edi
  8008ee:	5d                   	pop    %ebp
  8008ef:	c3                   	ret    

008008f0 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
  8008f3:	83 ec 18             	sub    $0x18,%esp
  8008f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008fc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008ff:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800903:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800906:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80090d:	85 c0                	test   %eax,%eax
  80090f:	74 26                	je     800937 <vsnprintf+0x47>
  800911:	85 d2                	test   %edx,%edx
  800913:	7e 22                	jle    800937 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800915:	ff 75 14             	pushl  0x14(%ebp)
  800918:	ff 75 10             	pushl  0x10(%ebp)
  80091b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80091e:	50                   	push   %eax
  80091f:	68 33 04 80 00       	push   $0x800433
  800924:	e8 44 fb ff ff       	call   80046d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800929:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80092c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80092f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800932:	83 c4 10             	add    $0x10,%esp
}
  800935:	c9                   	leave  
  800936:	c3                   	ret    
		return -E_INVAL;
  800937:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80093c:	eb f7                	jmp    800935 <vsnprintf+0x45>

0080093e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800944:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800947:	50                   	push   %eax
  800948:	ff 75 10             	pushl  0x10(%ebp)
  80094b:	ff 75 0c             	pushl  0xc(%ebp)
  80094e:	ff 75 08             	pushl  0x8(%ebp)
  800951:	e8 9a ff ff ff       	call   8008f0 <vsnprintf>
	va_end(ap);

	return rc;
}
  800956:	c9                   	leave  
  800957:	c3                   	ret    

00800958 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80095e:	b8 00 00 00 00       	mov    $0x0,%eax
  800963:	eb 03                	jmp    800968 <strlen+0x10>
		n++;
  800965:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800968:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80096c:	75 f7                	jne    800965 <strlen+0xd>
	return n;
}
  80096e:	5d                   	pop    %ebp
  80096f:	c3                   	ret    

00800970 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800976:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800979:	b8 00 00 00 00       	mov    $0x0,%eax
  80097e:	eb 03                	jmp    800983 <strnlen+0x13>
		n++;
  800980:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800983:	39 d0                	cmp    %edx,%eax
  800985:	74 06                	je     80098d <strnlen+0x1d>
  800987:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80098b:	75 f3                	jne    800980 <strnlen+0x10>
	return n;
}
  80098d:	5d                   	pop    %ebp
  80098e:	c3                   	ret    

0080098f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80098f:	55                   	push   %ebp
  800990:	89 e5                	mov    %esp,%ebp
  800992:	53                   	push   %ebx
  800993:	8b 45 08             	mov    0x8(%ebp),%eax
  800996:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800999:	89 c2                	mov    %eax,%edx
  80099b:	83 c1 01             	add    $0x1,%ecx
  80099e:	83 c2 01             	add    $0x1,%edx
  8009a1:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009a5:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009a8:	84 db                	test   %bl,%bl
  8009aa:	75 ef                	jne    80099b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009ac:	5b                   	pop    %ebx
  8009ad:	5d                   	pop    %ebp
  8009ae:	c3                   	ret    

008009af <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
  8009b2:	53                   	push   %ebx
  8009b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009b6:	53                   	push   %ebx
  8009b7:	e8 9c ff ff ff       	call   800958 <strlen>
  8009bc:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009bf:	ff 75 0c             	pushl  0xc(%ebp)
  8009c2:	01 d8                	add    %ebx,%eax
  8009c4:	50                   	push   %eax
  8009c5:	e8 c5 ff ff ff       	call   80098f <strcpy>
	return dst;
}
  8009ca:	89 d8                	mov    %ebx,%eax
  8009cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009cf:	c9                   	leave  
  8009d0:	c3                   	ret    

008009d1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009d1:	55                   	push   %ebp
  8009d2:	89 e5                	mov    %esp,%ebp
  8009d4:	56                   	push   %esi
  8009d5:	53                   	push   %ebx
  8009d6:	8b 75 08             	mov    0x8(%ebp),%esi
  8009d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009dc:	89 f3                	mov    %esi,%ebx
  8009de:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009e1:	89 f2                	mov    %esi,%edx
  8009e3:	eb 0f                	jmp    8009f4 <strncpy+0x23>
		*dst++ = *src;
  8009e5:	83 c2 01             	add    $0x1,%edx
  8009e8:	0f b6 01             	movzbl (%ecx),%eax
  8009eb:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009ee:	80 39 01             	cmpb   $0x1,(%ecx)
  8009f1:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8009f4:	39 da                	cmp    %ebx,%edx
  8009f6:	75 ed                	jne    8009e5 <strncpy+0x14>
	}
	return ret;
}
  8009f8:	89 f0                	mov    %esi,%eax
  8009fa:	5b                   	pop    %ebx
  8009fb:	5e                   	pop    %esi
  8009fc:	5d                   	pop    %ebp
  8009fd:	c3                   	ret    

008009fe <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	56                   	push   %esi
  800a02:	53                   	push   %ebx
  800a03:	8b 75 08             	mov    0x8(%ebp),%esi
  800a06:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a09:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800a0c:	89 f0                	mov    %esi,%eax
  800a0e:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a12:	85 c9                	test   %ecx,%ecx
  800a14:	75 0b                	jne    800a21 <strlcpy+0x23>
  800a16:	eb 17                	jmp    800a2f <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a18:	83 c2 01             	add    $0x1,%edx
  800a1b:	83 c0 01             	add    $0x1,%eax
  800a1e:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800a21:	39 d8                	cmp    %ebx,%eax
  800a23:	74 07                	je     800a2c <strlcpy+0x2e>
  800a25:	0f b6 0a             	movzbl (%edx),%ecx
  800a28:	84 c9                	test   %cl,%cl
  800a2a:	75 ec                	jne    800a18 <strlcpy+0x1a>
		*dst = '\0';
  800a2c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a2f:	29 f0                	sub    %esi,%eax
}
  800a31:	5b                   	pop    %ebx
  800a32:	5e                   	pop    %esi
  800a33:	5d                   	pop    %ebp
  800a34:	c3                   	ret    

00800a35 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
  800a38:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a3b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a3e:	eb 06                	jmp    800a46 <strcmp+0x11>
		p++, q++;
  800a40:	83 c1 01             	add    $0x1,%ecx
  800a43:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800a46:	0f b6 01             	movzbl (%ecx),%eax
  800a49:	84 c0                	test   %al,%al
  800a4b:	74 04                	je     800a51 <strcmp+0x1c>
  800a4d:	3a 02                	cmp    (%edx),%al
  800a4f:	74 ef                	je     800a40 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a51:	0f b6 c0             	movzbl %al,%eax
  800a54:	0f b6 12             	movzbl (%edx),%edx
  800a57:	29 d0                	sub    %edx,%eax
}
  800a59:	5d                   	pop    %ebp
  800a5a:	c3                   	ret    

00800a5b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	53                   	push   %ebx
  800a5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a62:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a65:	89 c3                	mov    %eax,%ebx
  800a67:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a6a:	eb 06                	jmp    800a72 <strncmp+0x17>
		n--, p++, q++;
  800a6c:	83 c0 01             	add    $0x1,%eax
  800a6f:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a72:	39 d8                	cmp    %ebx,%eax
  800a74:	74 16                	je     800a8c <strncmp+0x31>
  800a76:	0f b6 08             	movzbl (%eax),%ecx
  800a79:	84 c9                	test   %cl,%cl
  800a7b:	74 04                	je     800a81 <strncmp+0x26>
  800a7d:	3a 0a                	cmp    (%edx),%cl
  800a7f:	74 eb                	je     800a6c <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a81:	0f b6 00             	movzbl (%eax),%eax
  800a84:	0f b6 12             	movzbl (%edx),%edx
  800a87:	29 d0                	sub    %edx,%eax
}
  800a89:	5b                   	pop    %ebx
  800a8a:	5d                   	pop    %ebp
  800a8b:	c3                   	ret    
		return 0;
  800a8c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a91:	eb f6                	jmp    800a89 <strncmp+0x2e>

00800a93 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a93:	55                   	push   %ebp
  800a94:	89 e5                	mov    %esp,%ebp
  800a96:	8b 45 08             	mov    0x8(%ebp),%eax
  800a99:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a9d:	0f b6 10             	movzbl (%eax),%edx
  800aa0:	84 d2                	test   %dl,%dl
  800aa2:	74 09                	je     800aad <strchr+0x1a>
		if (*s == c)
  800aa4:	38 ca                	cmp    %cl,%dl
  800aa6:	74 0a                	je     800ab2 <strchr+0x1f>
	for (; *s; s++)
  800aa8:	83 c0 01             	add    $0x1,%eax
  800aab:	eb f0                	jmp    800a9d <strchr+0xa>
			return (char *) s;
	return 0;
  800aad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ab2:	5d                   	pop    %ebp
  800ab3:	c3                   	ret    

00800ab4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ab4:	55                   	push   %ebp
  800ab5:	89 e5                	mov    %esp,%ebp
  800ab7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aba:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800abe:	eb 03                	jmp    800ac3 <strfind+0xf>
  800ac0:	83 c0 01             	add    $0x1,%eax
  800ac3:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ac6:	38 ca                	cmp    %cl,%dl
  800ac8:	74 04                	je     800ace <strfind+0x1a>
  800aca:	84 d2                	test   %dl,%dl
  800acc:	75 f2                	jne    800ac0 <strfind+0xc>
			break;
	return (char *) s;
}
  800ace:	5d                   	pop    %ebp
  800acf:	c3                   	ret    

00800ad0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
  800ad3:	57                   	push   %edi
  800ad4:	56                   	push   %esi
  800ad5:	53                   	push   %ebx
  800ad6:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ad9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800adc:	85 c9                	test   %ecx,%ecx
  800ade:	74 13                	je     800af3 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ae0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ae6:	75 05                	jne    800aed <memset+0x1d>
  800ae8:	f6 c1 03             	test   $0x3,%cl
  800aeb:	74 0d                	je     800afa <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800aed:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af0:	fc                   	cld    
  800af1:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800af3:	89 f8                	mov    %edi,%eax
  800af5:	5b                   	pop    %ebx
  800af6:	5e                   	pop    %esi
  800af7:	5f                   	pop    %edi
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    
		c &= 0xFF;
  800afa:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800afe:	89 d3                	mov    %edx,%ebx
  800b00:	c1 e3 08             	shl    $0x8,%ebx
  800b03:	89 d0                	mov    %edx,%eax
  800b05:	c1 e0 18             	shl    $0x18,%eax
  800b08:	89 d6                	mov    %edx,%esi
  800b0a:	c1 e6 10             	shl    $0x10,%esi
  800b0d:	09 f0                	or     %esi,%eax
  800b0f:	09 c2                	or     %eax,%edx
  800b11:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800b13:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800b16:	89 d0                	mov    %edx,%eax
  800b18:	fc                   	cld    
  800b19:	f3 ab                	rep stos %eax,%es:(%edi)
  800b1b:	eb d6                	jmp    800af3 <memset+0x23>

00800b1d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b1d:	55                   	push   %ebp
  800b1e:	89 e5                	mov    %esp,%ebp
  800b20:	57                   	push   %edi
  800b21:	56                   	push   %esi
  800b22:	8b 45 08             	mov    0x8(%ebp),%eax
  800b25:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b28:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b2b:	39 c6                	cmp    %eax,%esi
  800b2d:	73 35                	jae    800b64 <memmove+0x47>
  800b2f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b32:	39 c2                	cmp    %eax,%edx
  800b34:	76 2e                	jbe    800b64 <memmove+0x47>
		s += n;
		d += n;
  800b36:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b39:	89 d6                	mov    %edx,%esi
  800b3b:	09 fe                	or     %edi,%esi
  800b3d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b43:	74 0c                	je     800b51 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b45:	83 ef 01             	sub    $0x1,%edi
  800b48:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b4b:	fd                   	std    
  800b4c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b4e:	fc                   	cld    
  800b4f:	eb 21                	jmp    800b72 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b51:	f6 c1 03             	test   $0x3,%cl
  800b54:	75 ef                	jne    800b45 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b56:	83 ef 04             	sub    $0x4,%edi
  800b59:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b5c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b5f:	fd                   	std    
  800b60:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b62:	eb ea                	jmp    800b4e <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b64:	89 f2                	mov    %esi,%edx
  800b66:	09 c2                	or     %eax,%edx
  800b68:	f6 c2 03             	test   $0x3,%dl
  800b6b:	74 09                	je     800b76 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b6d:	89 c7                	mov    %eax,%edi
  800b6f:	fc                   	cld    
  800b70:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b72:	5e                   	pop    %esi
  800b73:	5f                   	pop    %edi
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b76:	f6 c1 03             	test   $0x3,%cl
  800b79:	75 f2                	jne    800b6d <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b7b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b7e:	89 c7                	mov    %eax,%edi
  800b80:	fc                   	cld    
  800b81:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b83:	eb ed                	jmp    800b72 <memmove+0x55>

00800b85 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b88:	ff 75 10             	pushl  0x10(%ebp)
  800b8b:	ff 75 0c             	pushl  0xc(%ebp)
  800b8e:	ff 75 08             	pushl  0x8(%ebp)
  800b91:	e8 87 ff ff ff       	call   800b1d <memmove>
}
  800b96:	c9                   	leave  
  800b97:	c3                   	ret    

00800b98 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b98:	55                   	push   %ebp
  800b99:	89 e5                	mov    %esp,%ebp
  800b9b:	56                   	push   %esi
  800b9c:	53                   	push   %ebx
  800b9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ba3:	89 c6                	mov    %eax,%esi
  800ba5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ba8:	39 f0                	cmp    %esi,%eax
  800baa:	74 1c                	je     800bc8 <memcmp+0x30>
		if (*s1 != *s2)
  800bac:	0f b6 08             	movzbl (%eax),%ecx
  800baf:	0f b6 1a             	movzbl (%edx),%ebx
  800bb2:	38 d9                	cmp    %bl,%cl
  800bb4:	75 08                	jne    800bbe <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800bb6:	83 c0 01             	add    $0x1,%eax
  800bb9:	83 c2 01             	add    $0x1,%edx
  800bbc:	eb ea                	jmp    800ba8 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800bbe:	0f b6 c1             	movzbl %cl,%eax
  800bc1:	0f b6 db             	movzbl %bl,%ebx
  800bc4:	29 d8                	sub    %ebx,%eax
  800bc6:	eb 05                	jmp    800bcd <memcmp+0x35>
	}

	return 0;
  800bc8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bcd:	5b                   	pop    %ebx
  800bce:	5e                   	pop    %esi
  800bcf:	5d                   	pop    %ebp
  800bd0:	c3                   	ret    

00800bd1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800bda:	89 c2                	mov    %eax,%edx
  800bdc:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bdf:	39 d0                	cmp    %edx,%eax
  800be1:	73 09                	jae    800bec <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800be3:	38 08                	cmp    %cl,(%eax)
  800be5:	74 05                	je     800bec <memfind+0x1b>
	for (; s < ends; s++)
  800be7:	83 c0 01             	add    $0x1,%eax
  800bea:	eb f3                	jmp    800bdf <memfind+0xe>
			break;
	return (void *) s;
}
  800bec:	5d                   	pop    %ebp
  800bed:	c3                   	ret    

00800bee <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bee:	55                   	push   %ebp
  800bef:	89 e5                	mov    %esp,%ebp
  800bf1:	57                   	push   %edi
  800bf2:	56                   	push   %esi
  800bf3:	53                   	push   %ebx
  800bf4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bf7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bfa:	eb 03                	jmp    800bff <strtol+0x11>
		s++;
  800bfc:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800bff:	0f b6 01             	movzbl (%ecx),%eax
  800c02:	3c 20                	cmp    $0x20,%al
  800c04:	74 f6                	je     800bfc <strtol+0xe>
  800c06:	3c 09                	cmp    $0x9,%al
  800c08:	74 f2                	je     800bfc <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800c0a:	3c 2b                	cmp    $0x2b,%al
  800c0c:	74 2e                	je     800c3c <strtol+0x4e>
	int neg = 0;
  800c0e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800c13:	3c 2d                	cmp    $0x2d,%al
  800c15:	74 2f                	je     800c46 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c17:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c1d:	75 05                	jne    800c24 <strtol+0x36>
  800c1f:	80 39 30             	cmpb   $0x30,(%ecx)
  800c22:	74 2c                	je     800c50 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c24:	85 db                	test   %ebx,%ebx
  800c26:	75 0a                	jne    800c32 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c28:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800c2d:	80 39 30             	cmpb   $0x30,(%ecx)
  800c30:	74 28                	je     800c5a <strtol+0x6c>
		base = 10;
  800c32:	b8 00 00 00 00       	mov    $0x0,%eax
  800c37:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800c3a:	eb 50                	jmp    800c8c <strtol+0x9e>
		s++;
  800c3c:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800c3f:	bf 00 00 00 00       	mov    $0x0,%edi
  800c44:	eb d1                	jmp    800c17 <strtol+0x29>
		s++, neg = 1;
  800c46:	83 c1 01             	add    $0x1,%ecx
  800c49:	bf 01 00 00 00       	mov    $0x1,%edi
  800c4e:	eb c7                	jmp    800c17 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c50:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c54:	74 0e                	je     800c64 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800c56:	85 db                	test   %ebx,%ebx
  800c58:	75 d8                	jne    800c32 <strtol+0x44>
		s++, base = 8;
  800c5a:	83 c1 01             	add    $0x1,%ecx
  800c5d:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c62:	eb ce                	jmp    800c32 <strtol+0x44>
		s += 2, base = 16;
  800c64:	83 c1 02             	add    $0x2,%ecx
  800c67:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c6c:	eb c4                	jmp    800c32 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800c6e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c71:	89 f3                	mov    %esi,%ebx
  800c73:	80 fb 19             	cmp    $0x19,%bl
  800c76:	77 29                	ja     800ca1 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800c78:	0f be d2             	movsbl %dl,%edx
  800c7b:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c7e:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c81:	7d 30                	jge    800cb3 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800c83:	83 c1 01             	add    $0x1,%ecx
  800c86:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c8a:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c8c:	0f b6 11             	movzbl (%ecx),%edx
  800c8f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c92:	89 f3                	mov    %esi,%ebx
  800c94:	80 fb 09             	cmp    $0x9,%bl
  800c97:	77 d5                	ja     800c6e <strtol+0x80>
			dig = *s - '0';
  800c99:	0f be d2             	movsbl %dl,%edx
  800c9c:	83 ea 30             	sub    $0x30,%edx
  800c9f:	eb dd                	jmp    800c7e <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800ca1:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ca4:	89 f3                	mov    %esi,%ebx
  800ca6:	80 fb 19             	cmp    $0x19,%bl
  800ca9:	77 08                	ja     800cb3 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800cab:	0f be d2             	movsbl %dl,%edx
  800cae:	83 ea 37             	sub    $0x37,%edx
  800cb1:	eb cb                	jmp    800c7e <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800cb3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cb7:	74 05                	je     800cbe <strtol+0xd0>
		*endptr = (char *) s;
  800cb9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cbc:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800cbe:	89 c2                	mov    %eax,%edx
  800cc0:	f7 da                	neg    %edx
  800cc2:	85 ff                	test   %edi,%edi
  800cc4:	0f 45 c2             	cmovne %edx,%eax
}
  800cc7:	5b                   	pop    %ebx
  800cc8:	5e                   	pop    %esi
  800cc9:	5f                   	pop    %edi
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    

00800ccc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	57                   	push   %edi
  800cd0:	56                   	push   %esi
  800cd1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cd2:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdd:	89 c3                	mov    %eax,%ebx
  800cdf:	89 c7                	mov    %eax,%edi
  800ce1:	89 c6                	mov    %eax,%esi
  800ce3:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ce5:	5b                   	pop    %ebx
  800ce6:	5e                   	pop    %esi
  800ce7:	5f                   	pop    %edi
  800ce8:	5d                   	pop    %ebp
  800ce9:	c3                   	ret    

00800cea <sys_cgetc>:

int
sys_cgetc(void)
{
  800cea:	55                   	push   %ebp
  800ceb:	89 e5                	mov    %esp,%ebp
  800ced:	57                   	push   %edi
  800cee:	56                   	push   %esi
  800cef:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cf0:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf5:	b8 01 00 00 00       	mov    $0x1,%eax
  800cfa:	89 d1                	mov    %edx,%ecx
  800cfc:	89 d3                	mov    %edx,%ebx
  800cfe:	89 d7                	mov    %edx,%edi
  800d00:	89 d6                	mov    %edx,%esi
  800d02:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d04:	5b                   	pop    %ebx
  800d05:	5e                   	pop    %esi
  800d06:	5f                   	pop    %edi
  800d07:	5d                   	pop    %ebp
  800d08:	c3                   	ret    

00800d09 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d09:	55                   	push   %ebp
  800d0a:	89 e5                	mov    %esp,%ebp
  800d0c:	57                   	push   %edi
  800d0d:	56                   	push   %esi
  800d0e:	53                   	push   %ebx
  800d0f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d12:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d17:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1a:	b8 03 00 00 00       	mov    $0x3,%eax
  800d1f:	89 cb                	mov    %ecx,%ebx
  800d21:	89 cf                	mov    %ecx,%edi
  800d23:	89 ce                	mov    %ecx,%esi
  800d25:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d27:	85 c0                	test   %eax,%eax
  800d29:	7f 08                	jg     800d33 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2e:	5b                   	pop    %ebx
  800d2f:	5e                   	pop    %esi
  800d30:	5f                   	pop    %edi
  800d31:	5d                   	pop    %ebp
  800d32:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d33:	83 ec 0c             	sub    $0xc,%esp
  800d36:	50                   	push   %eax
  800d37:	6a 03                	push   $0x3
  800d39:	68 ff 26 80 00       	push   $0x8026ff
  800d3e:	6a 23                	push   $0x23
  800d40:	68 1c 27 80 00       	push   $0x80271c
  800d45:	e8 4b f5 ff ff       	call   800295 <_panic>

00800d4a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d4a:	55                   	push   %ebp
  800d4b:	89 e5                	mov    %esp,%ebp
  800d4d:	57                   	push   %edi
  800d4e:	56                   	push   %esi
  800d4f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d50:	ba 00 00 00 00       	mov    $0x0,%edx
  800d55:	b8 02 00 00 00       	mov    $0x2,%eax
  800d5a:	89 d1                	mov    %edx,%ecx
  800d5c:	89 d3                	mov    %edx,%ebx
  800d5e:	89 d7                	mov    %edx,%edi
  800d60:	89 d6                	mov    %edx,%esi
  800d62:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d64:	5b                   	pop    %ebx
  800d65:	5e                   	pop    %esi
  800d66:	5f                   	pop    %edi
  800d67:	5d                   	pop    %ebp
  800d68:	c3                   	ret    

00800d69 <sys_yield>:

void
sys_yield(void)
{
  800d69:	55                   	push   %ebp
  800d6a:	89 e5                	mov    %esp,%ebp
  800d6c:	57                   	push   %edi
  800d6d:	56                   	push   %esi
  800d6e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d6f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d74:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d79:	89 d1                	mov    %edx,%ecx
  800d7b:	89 d3                	mov    %edx,%ebx
  800d7d:	89 d7                	mov    %edx,%edi
  800d7f:	89 d6                	mov    %edx,%esi
  800d81:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d83:	5b                   	pop    %ebx
  800d84:	5e                   	pop    %esi
  800d85:	5f                   	pop    %edi
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    

00800d88 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	57                   	push   %edi
  800d8c:	56                   	push   %esi
  800d8d:	53                   	push   %ebx
  800d8e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d91:	be 00 00 00 00       	mov    $0x0,%esi
  800d96:	8b 55 08             	mov    0x8(%ebp),%edx
  800d99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9c:	b8 04 00 00 00       	mov    $0x4,%eax
  800da1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da4:	89 f7                	mov    %esi,%edi
  800da6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800da8:	85 c0                	test   %eax,%eax
  800daa:	7f 08                	jg     800db4 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800daf:	5b                   	pop    %ebx
  800db0:	5e                   	pop    %esi
  800db1:	5f                   	pop    %edi
  800db2:	5d                   	pop    %ebp
  800db3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800db4:	83 ec 0c             	sub    $0xc,%esp
  800db7:	50                   	push   %eax
  800db8:	6a 04                	push   $0x4
  800dba:	68 ff 26 80 00       	push   $0x8026ff
  800dbf:	6a 23                	push   $0x23
  800dc1:	68 1c 27 80 00       	push   $0x80271c
  800dc6:	e8 ca f4 ff ff       	call   800295 <_panic>

00800dcb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800dcb:	55                   	push   %ebp
  800dcc:	89 e5                	mov    %esp,%ebp
  800dce:	57                   	push   %edi
  800dcf:	56                   	push   %esi
  800dd0:	53                   	push   %ebx
  800dd1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dda:	b8 05 00 00 00       	mov    $0x5,%eax
  800ddf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800de2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800de5:	8b 75 18             	mov    0x18(%ebp),%esi
  800de8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dea:	85 c0                	test   %eax,%eax
  800dec:	7f 08                	jg     800df6 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800dee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df1:	5b                   	pop    %ebx
  800df2:	5e                   	pop    %esi
  800df3:	5f                   	pop    %edi
  800df4:	5d                   	pop    %ebp
  800df5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800df6:	83 ec 0c             	sub    $0xc,%esp
  800df9:	50                   	push   %eax
  800dfa:	6a 05                	push   $0x5
  800dfc:	68 ff 26 80 00       	push   $0x8026ff
  800e01:	6a 23                	push   $0x23
  800e03:	68 1c 27 80 00       	push   $0x80271c
  800e08:	e8 88 f4 ff ff       	call   800295 <_panic>

00800e0d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e0d:	55                   	push   %ebp
  800e0e:	89 e5                	mov    %esp,%ebp
  800e10:	57                   	push   %edi
  800e11:	56                   	push   %esi
  800e12:	53                   	push   %ebx
  800e13:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e16:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e21:	b8 06 00 00 00       	mov    $0x6,%eax
  800e26:	89 df                	mov    %ebx,%edi
  800e28:	89 de                	mov    %ebx,%esi
  800e2a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e2c:	85 c0                	test   %eax,%eax
  800e2e:	7f 08                	jg     800e38 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e33:	5b                   	pop    %ebx
  800e34:	5e                   	pop    %esi
  800e35:	5f                   	pop    %edi
  800e36:	5d                   	pop    %ebp
  800e37:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e38:	83 ec 0c             	sub    $0xc,%esp
  800e3b:	50                   	push   %eax
  800e3c:	6a 06                	push   $0x6
  800e3e:	68 ff 26 80 00       	push   $0x8026ff
  800e43:	6a 23                	push   $0x23
  800e45:	68 1c 27 80 00       	push   $0x80271c
  800e4a:	e8 46 f4 ff ff       	call   800295 <_panic>

00800e4f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e4f:	55                   	push   %ebp
  800e50:	89 e5                	mov    %esp,%ebp
  800e52:	57                   	push   %edi
  800e53:	56                   	push   %esi
  800e54:	53                   	push   %ebx
  800e55:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e58:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e63:	b8 08 00 00 00       	mov    $0x8,%eax
  800e68:	89 df                	mov    %ebx,%edi
  800e6a:	89 de                	mov    %ebx,%esi
  800e6c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e6e:	85 c0                	test   %eax,%eax
  800e70:	7f 08                	jg     800e7a <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e72:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e75:	5b                   	pop    %ebx
  800e76:	5e                   	pop    %esi
  800e77:	5f                   	pop    %edi
  800e78:	5d                   	pop    %ebp
  800e79:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e7a:	83 ec 0c             	sub    $0xc,%esp
  800e7d:	50                   	push   %eax
  800e7e:	6a 08                	push   $0x8
  800e80:	68 ff 26 80 00       	push   $0x8026ff
  800e85:	6a 23                	push   $0x23
  800e87:	68 1c 27 80 00       	push   $0x80271c
  800e8c:	e8 04 f4 ff ff       	call   800295 <_panic>

00800e91 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e91:	55                   	push   %ebp
  800e92:	89 e5                	mov    %esp,%ebp
  800e94:	57                   	push   %edi
  800e95:	56                   	push   %esi
  800e96:	53                   	push   %ebx
  800e97:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e9a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea5:	b8 09 00 00 00       	mov    $0x9,%eax
  800eaa:	89 df                	mov    %ebx,%edi
  800eac:	89 de                	mov    %ebx,%esi
  800eae:	cd 30                	int    $0x30
	if(check && ret > 0)
  800eb0:	85 c0                	test   %eax,%eax
  800eb2:	7f 08                	jg     800ebc <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800eb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eb7:	5b                   	pop    %ebx
  800eb8:	5e                   	pop    %esi
  800eb9:	5f                   	pop    %edi
  800eba:	5d                   	pop    %ebp
  800ebb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ebc:	83 ec 0c             	sub    $0xc,%esp
  800ebf:	50                   	push   %eax
  800ec0:	6a 09                	push   $0x9
  800ec2:	68 ff 26 80 00       	push   $0x8026ff
  800ec7:	6a 23                	push   $0x23
  800ec9:	68 1c 27 80 00       	push   $0x80271c
  800ece:	e8 c2 f3 ff ff       	call   800295 <_panic>

00800ed3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ed3:	55                   	push   %ebp
  800ed4:	89 e5                	mov    %esp,%ebp
  800ed6:	57                   	push   %edi
  800ed7:	56                   	push   %esi
  800ed8:	53                   	push   %ebx
  800ed9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800edc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ee1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800eec:	89 df                	mov    %ebx,%edi
  800eee:	89 de                	mov    %ebx,%esi
  800ef0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ef2:	85 c0                	test   %eax,%eax
  800ef4:	7f 08                	jg     800efe <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ef6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ef9:	5b                   	pop    %ebx
  800efa:	5e                   	pop    %esi
  800efb:	5f                   	pop    %edi
  800efc:	5d                   	pop    %ebp
  800efd:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800efe:	83 ec 0c             	sub    $0xc,%esp
  800f01:	50                   	push   %eax
  800f02:	6a 0a                	push   $0xa
  800f04:	68 ff 26 80 00       	push   $0x8026ff
  800f09:	6a 23                	push   $0x23
  800f0b:	68 1c 27 80 00       	push   $0x80271c
  800f10:	e8 80 f3 ff ff       	call   800295 <_panic>

00800f15 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f15:	55                   	push   %ebp
  800f16:	89 e5                	mov    %esp,%ebp
  800f18:	57                   	push   %edi
  800f19:	56                   	push   %esi
  800f1a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f21:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f26:	be 00 00 00 00       	mov    $0x0,%esi
  800f2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f2e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f31:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f33:	5b                   	pop    %ebx
  800f34:	5e                   	pop    %esi
  800f35:	5f                   	pop    %edi
  800f36:	5d                   	pop    %ebp
  800f37:	c3                   	ret    

00800f38 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f38:	55                   	push   %ebp
  800f39:	89 e5                	mov    %esp,%ebp
  800f3b:	57                   	push   %edi
  800f3c:	56                   	push   %esi
  800f3d:	53                   	push   %ebx
  800f3e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f41:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f46:	8b 55 08             	mov    0x8(%ebp),%edx
  800f49:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f4e:	89 cb                	mov    %ecx,%ebx
  800f50:	89 cf                	mov    %ecx,%edi
  800f52:	89 ce                	mov    %ecx,%esi
  800f54:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f56:	85 c0                	test   %eax,%eax
  800f58:	7f 08                	jg     800f62 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f5d:	5b                   	pop    %ebx
  800f5e:	5e                   	pop    %esi
  800f5f:	5f                   	pop    %edi
  800f60:	5d                   	pop    %ebp
  800f61:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f62:	83 ec 0c             	sub    $0xc,%esp
  800f65:	50                   	push   %eax
  800f66:	6a 0d                	push   $0xd
  800f68:	68 ff 26 80 00       	push   $0x8026ff
  800f6d:	6a 23                	push   $0x23
  800f6f:	68 1c 27 80 00       	push   $0x80271c
  800f74:	e8 1c f3 ff ff       	call   800295 <_panic>

00800f79 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f79:	55                   	push   %ebp
  800f7a:	89 e5                	mov    %esp,%ebp
  800f7c:	53                   	push   %ebx
  800f7d:	83 ec 04             	sub    $0x4,%esp
  800f80:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800f83:	8b 02                	mov    (%edx),%eax
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800f85:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800f89:	0f 84 9c 00 00 00    	je     80102b <pgfault+0xb2>
  800f8f:	89 c2                	mov    %eax,%edx
  800f91:	c1 ea 16             	shr    $0x16,%edx
  800f94:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f9b:	f6 c2 01             	test   $0x1,%dl
  800f9e:	0f 84 87 00 00 00    	je     80102b <pgfault+0xb2>
  800fa4:	89 c2                	mov    %eax,%edx
  800fa6:	c1 ea 0c             	shr    $0xc,%edx
  800fa9:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800fb0:	f6 c1 01             	test   $0x1,%cl
  800fb3:	74 76                	je     80102b <pgfault+0xb2>
  800fb5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fbc:	f6 c6 08             	test   $0x8,%dh
  800fbf:	74 6a                	je     80102b <pgfault+0xb2>
		panic("not copy-on-write");
	addr = ROUNDDOWN(addr, PGSIZE);
  800fc1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800fc6:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P) < 0)
  800fc8:	83 ec 04             	sub    $0x4,%esp
  800fcb:	6a 07                	push   $0x7
  800fcd:	68 00 f0 7f 00       	push   $0x7ff000
  800fd2:	6a 00                	push   $0x0
  800fd4:	e8 af fd ff ff       	call   800d88 <sys_page_alloc>
  800fd9:	83 c4 10             	add    $0x10,%esp
  800fdc:	85 c0                	test   %eax,%eax
  800fde:	78 5f                	js     80103f <pgfault+0xc6>
		panic("sys_page_alloc");
	memcpy(PFTEMP, addr, PGSIZE);
  800fe0:	83 ec 04             	sub    $0x4,%esp
  800fe3:	68 00 10 00 00       	push   $0x1000
  800fe8:	53                   	push   %ebx
  800fe9:	68 00 f0 7f 00       	push   $0x7ff000
  800fee:	e8 92 fb ff ff       	call   800b85 <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P) < 0)
  800ff3:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ffa:	53                   	push   %ebx
  800ffb:	6a 00                	push   $0x0
  800ffd:	68 00 f0 7f 00       	push   $0x7ff000
  801002:	6a 00                	push   $0x0
  801004:	e8 c2 fd ff ff       	call   800dcb <sys_page_map>
  801009:	83 c4 20             	add    $0x20,%esp
  80100c:	85 c0                	test   %eax,%eax
  80100e:	78 43                	js     801053 <pgfault+0xda>
		panic("sys_page_map");
	if (sys_page_unmap(0, PFTEMP) < 0)
  801010:	83 ec 08             	sub    $0x8,%esp
  801013:	68 00 f0 7f 00       	push   $0x7ff000
  801018:	6a 00                	push   $0x0
  80101a:	e8 ee fd ff ff       	call   800e0d <sys_page_unmap>
  80101f:	83 c4 10             	add    $0x10,%esp
  801022:	85 c0                	test   %eax,%eax
  801024:	78 41                	js     801067 <pgfault+0xee>
		panic("sys_page_unmap");
	return;
}
  801026:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801029:	c9                   	leave  
  80102a:	c3                   	ret    
		panic("not copy-on-write");
  80102b:	83 ec 04             	sub    $0x4,%esp
  80102e:	68 2a 27 80 00       	push   $0x80272a
  801033:	6a 25                	push   $0x25
  801035:	68 3c 27 80 00       	push   $0x80273c
  80103a:	e8 56 f2 ff ff       	call   800295 <_panic>
		panic("sys_page_alloc");
  80103f:	83 ec 04             	sub    $0x4,%esp
  801042:	68 47 27 80 00       	push   $0x802747
  801047:	6a 28                	push   $0x28
  801049:	68 3c 27 80 00       	push   $0x80273c
  80104e:	e8 42 f2 ff ff       	call   800295 <_panic>
		panic("sys_page_map");
  801053:	83 ec 04             	sub    $0x4,%esp
  801056:	68 56 27 80 00       	push   $0x802756
  80105b:	6a 2b                	push   $0x2b
  80105d:	68 3c 27 80 00       	push   $0x80273c
  801062:	e8 2e f2 ff ff       	call   800295 <_panic>
		panic("sys_page_unmap");
  801067:	83 ec 04             	sub    $0x4,%esp
  80106a:	68 63 27 80 00       	push   $0x802763
  80106f:	6a 2d                	push   $0x2d
  801071:	68 3c 27 80 00       	push   $0x80273c
  801076:	e8 1a f2 ff ff       	call   800295 <_panic>

0080107b <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80107b:	55                   	push   %ebp
  80107c:	89 e5                	mov    %esp,%ebp
  80107e:	57                   	push   %edi
  80107f:	56                   	push   %esi
  801080:	53                   	push   %ebx
  801081:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  801084:	68 79 0f 80 00       	push   $0x800f79
  801089:	e8 8b 0e 00 00       	call   801f19 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80108e:	b8 07 00 00 00       	mov    $0x7,%eax
  801093:	cd 30                	int    $0x30
  801095:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid;
	uint32_t addr;
	envid = sys_exofork();
	if (envid == 0) {
  801098:	83 c4 10             	add    $0x10,%esp
  80109b:	85 c0                	test   %eax,%eax
  80109d:	74 12                	je     8010b1 <fork+0x36>
  80109f:	89 c7                	mov    %eax,%edi
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	if (envid < 0)
  8010a1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8010a5:	78 26                	js     8010cd <fork+0x52>
		panic("sys_exofork: %e", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  8010a7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010ac:	e9 94 00 00 00       	jmp    801145 <fork+0xca>
		thisenv = &envs[ENVX(sys_getenvid())];
  8010b1:	e8 94 fc ff ff       	call   800d4a <sys_getenvid>
  8010b6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010bb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010be:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010c3:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  8010c8:	e9 51 01 00 00       	jmp    80121e <fork+0x1a3>
		panic("sys_exofork: %e", envid);
  8010cd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010d0:	68 72 27 80 00       	push   $0x802772
  8010d5:	6a 6e                	push   $0x6e
  8010d7:	68 3c 27 80 00       	push   $0x80273c
  8010dc:	e8 b4 f1 ff ff       	call   800295 <_panic>
        	sys_page_map(0, addr, envid, addr, PTE_SYSCALL);
  8010e1:	83 ec 0c             	sub    $0xc,%esp
  8010e4:	68 07 0e 00 00       	push   $0xe07
  8010e9:	56                   	push   %esi
  8010ea:	57                   	push   %edi
  8010eb:	56                   	push   %esi
  8010ec:	6a 00                	push   $0x0
  8010ee:	e8 d8 fc ff ff       	call   800dcb <sys_page_map>
  8010f3:	83 c4 20             	add    $0x20,%esp
  8010f6:	eb 3b                	jmp    801133 <fork+0xb8>
        	if ((r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  8010f8:	83 ec 0c             	sub    $0xc,%esp
  8010fb:	68 05 08 00 00       	push   $0x805
  801100:	56                   	push   %esi
  801101:	57                   	push   %edi
  801102:	56                   	push   %esi
  801103:	6a 00                	push   $0x0
  801105:	e8 c1 fc ff ff       	call   800dcb <sys_page_map>
  80110a:	83 c4 20             	add    $0x20,%esp
  80110d:	85 c0                	test   %eax,%eax
  80110f:	0f 88 a9 00 00 00    	js     8011be <fork+0x143>
        	if ((r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  801115:	83 ec 0c             	sub    $0xc,%esp
  801118:	68 05 08 00 00       	push   $0x805
  80111d:	56                   	push   %esi
  80111e:	6a 00                	push   $0x0
  801120:	56                   	push   %esi
  801121:	6a 00                	push   $0x0
  801123:	e8 a3 fc ff ff       	call   800dcb <sys_page_map>
  801128:	83 c4 20             	add    $0x20,%esp
  80112b:	85 c0                	test   %eax,%eax
  80112d:	0f 88 9d 00 00 00    	js     8011d0 <fork+0x155>
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  801133:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801139:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80113f:	0f 84 9d 00 00 00    	je     8011e2 <fork+0x167>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  801145:	89 d8                	mov    %ebx,%eax
  801147:	c1 e8 16             	shr    $0x16,%eax
  80114a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801151:	a8 01                	test   $0x1,%al
  801153:	74 de                	je     801133 <fork+0xb8>
  801155:	89 d8                	mov    %ebx,%eax
  801157:	c1 e8 0c             	shr    $0xc,%eax
  80115a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801161:	f6 c2 01             	test   $0x1,%dl
  801164:	74 cd                	je     801133 <fork+0xb8>
			&& (uvpt[PGNUM(addr)] & PTE_U)) {
  801166:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80116d:	f6 c2 04             	test   $0x4,%dl
  801170:	74 c1                	je     801133 <fork+0xb8>
	void *addr = (void*) (pn*PGSIZE);
  801172:	89 c6                	mov    %eax,%esi
  801174:	c1 e6 0c             	shl    $0xc,%esi
    	if (uvpt[pn] & PTE_SHARE) {
  801177:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80117e:	f6 c6 04             	test   $0x4,%dh
  801181:	0f 85 5a ff ff ff    	jne    8010e1 <fork+0x66>
    	} else if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  801187:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80118e:	f6 c2 02             	test   $0x2,%dl
  801191:	0f 85 61 ff ff ff    	jne    8010f8 <fork+0x7d>
  801197:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80119e:	f6 c4 08             	test   $0x8,%ah
  8011a1:	0f 85 51 ff ff ff    	jne    8010f8 <fork+0x7d>
        		sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  8011a7:	83 ec 0c             	sub    $0xc,%esp
  8011aa:	6a 05                	push   $0x5
  8011ac:	56                   	push   %esi
  8011ad:	57                   	push   %edi
  8011ae:	56                   	push   %esi
  8011af:	6a 00                	push   $0x0
  8011b1:	e8 15 fc ff ff       	call   800dcb <sys_page_map>
  8011b6:	83 c4 20             	add    $0x20,%esp
  8011b9:	e9 75 ff ff ff       	jmp    801133 <fork+0xb8>
            		panic("sys_page_map：%e", r);
  8011be:	50                   	push   %eax
  8011bf:	68 82 27 80 00       	push   $0x802782
  8011c4:	6a 47                	push   $0x47
  8011c6:	68 3c 27 80 00       	push   $0x80273c
  8011cb:	e8 c5 f0 ff ff       	call   800295 <_panic>
            		panic("sys_page_map：%e", r);
  8011d0:	50                   	push   %eax
  8011d1:	68 82 27 80 00       	push   $0x802782
  8011d6:	6a 49                	push   $0x49
  8011d8:	68 3c 27 80 00       	push   $0x80273c
  8011dd:	e8 b3 f0 ff ff       	call   800295 <_panic>
			duppage(envid, PGNUM(addr));
		}

	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  8011e2:	83 ec 04             	sub    $0x4,%esp
  8011e5:	6a 07                	push   $0x7
  8011e7:	68 00 f0 bf ee       	push   $0xeebff000
  8011ec:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ef:	e8 94 fb ff ff       	call   800d88 <sys_page_alloc>
  8011f4:	83 c4 10             	add    $0x10,%esp
  8011f7:	85 c0                	test   %eax,%eax
  8011f9:	78 2e                	js     801229 <fork+0x1ae>
		panic("1");
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8011fb:	83 ec 08             	sub    $0x8,%esp
  8011fe:	68 88 1f 80 00       	push   $0x801f88
  801203:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801206:	57                   	push   %edi
  801207:	e8 c7 fc ff ff       	call   800ed3 <sys_env_set_pgfault_upcall>

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  80120c:	83 c4 08             	add    $0x8,%esp
  80120f:	6a 02                	push   $0x2
  801211:	57                   	push   %edi
  801212:	e8 38 fc ff ff       	call   800e4f <sys_env_set_status>
  801217:	83 c4 10             	add    $0x10,%esp
  80121a:	85 c0                	test   %eax,%eax
  80121c:	78 1f                	js     80123d <fork+0x1c2>
		panic("sys_env_set_status");

	return envid;
	panic("fork not implemented");
}
  80121e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801221:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801224:	5b                   	pop    %ebx
  801225:	5e                   	pop    %esi
  801226:	5f                   	pop    %edi
  801227:	5d                   	pop    %ebp
  801228:	c3                   	ret    
		panic("1");
  801229:	83 ec 04             	sub    $0x4,%esp
  80122c:	68 94 27 80 00       	push   $0x802794
  801231:	6a 77                	push   $0x77
  801233:	68 3c 27 80 00       	push   $0x80273c
  801238:	e8 58 f0 ff ff       	call   800295 <_panic>
		panic("sys_env_set_status");
  80123d:	83 ec 04             	sub    $0x4,%esp
  801240:	68 96 27 80 00       	push   $0x802796
  801245:	6a 7c                	push   $0x7c
  801247:	68 3c 27 80 00       	push   $0x80273c
  80124c:	e8 44 f0 ff ff       	call   800295 <_panic>

00801251 <sfork>:

// Challenge!
int
sfork(void)
{
  801251:	55                   	push   %ebp
  801252:	89 e5                	mov    %esp,%ebp
  801254:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801257:	68 a9 27 80 00       	push   $0x8027a9
  80125c:	68 86 00 00 00       	push   $0x86
  801261:	68 3c 27 80 00       	push   $0x80273c
  801266:	e8 2a f0 ff ff       	call   800295 <_panic>

0080126b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80126b:	55                   	push   %ebp
  80126c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80126e:	8b 45 08             	mov    0x8(%ebp),%eax
  801271:	05 00 00 00 30       	add    $0x30000000,%eax
  801276:	c1 e8 0c             	shr    $0xc,%eax
}
  801279:	5d                   	pop    %ebp
  80127a:	c3                   	ret    

0080127b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80127b:	55                   	push   %ebp
  80127c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80127e:	8b 45 08             	mov    0x8(%ebp),%eax
  801281:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801286:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80128b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801290:	5d                   	pop    %ebp
  801291:	c3                   	ret    

00801292 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801292:	55                   	push   %ebp
  801293:	89 e5                	mov    %esp,%ebp
  801295:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801298:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80129d:	89 c2                	mov    %eax,%edx
  80129f:	c1 ea 16             	shr    $0x16,%edx
  8012a2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012a9:	f6 c2 01             	test   $0x1,%dl
  8012ac:	74 2a                	je     8012d8 <fd_alloc+0x46>
  8012ae:	89 c2                	mov    %eax,%edx
  8012b0:	c1 ea 0c             	shr    $0xc,%edx
  8012b3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012ba:	f6 c2 01             	test   $0x1,%dl
  8012bd:	74 19                	je     8012d8 <fd_alloc+0x46>
  8012bf:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8012c4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012c9:	75 d2                	jne    80129d <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012cb:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012d1:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8012d6:	eb 07                	jmp    8012df <fd_alloc+0x4d>
			*fd_store = fd;
  8012d8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012da:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012df:	5d                   	pop    %ebp
  8012e0:	c3                   	ret    

008012e1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012e1:	55                   	push   %ebp
  8012e2:	89 e5                	mov    %esp,%ebp
  8012e4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012e7:	83 f8 1f             	cmp    $0x1f,%eax
  8012ea:	77 36                	ja     801322 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012ec:	c1 e0 0c             	shl    $0xc,%eax
  8012ef:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012f4:	89 c2                	mov    %eax,%edx
  8012f6:	c1 ea 16             	shr    $0x16,%edx
  8012f9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801300:	f6 c2 01             	test   $0x1,%dl
  801303:	74 24                	je     801329 <fd_lookup+0x48>
  801305:	89 c2                	mov    %eax,%edx
  801307:	c1 ea 0c             	shr    $0xc,%edx
  80130a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801311:	f6 c2 01             	test   $0x1,%dl
  801314:	74 1a                	je     801330 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801316:	8b 55 0c             	mov    0xc(%ebp),%edx
  801319:	89 02                	mov    %eax,(%edx)
	return 0;
  80131b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801320:	5d                   	pop    %ebp
  801321:	c3                   	ret    
		return -E_INVAL;
  801322:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801327:	eb f7                	jmp    801320 <fd_lookup+0x3f>
		return -E_INVAL;
  801329:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80132e:	eb f0                	jmp    801320 <fd_lookup+0x3f>
  801330:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801335:	eb e9                	jmp    801320 <fd_lookup+0x3f>

00801337 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801337:	55                   	push   %ebp
  801338:	89 e5                	mov    %esp,%ebp
  80133a:	83 ec 08             	sub    $0x8,%esp
  80133d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801340:	ba 3c 28 80 00       	mov    $0x80283c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801345:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  80134a:	39 08                	cmp    %ecx,(%eax)
  80134c:	74 33                	je     801381 <dev_lookup+0x4a>
  80134e:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  801351:	8b 02                	mov    (%edx),%eax
  801353:	85 c0                	test   %eax,%eax
  801355:	75 f3                	jne    80134a <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801357:	a1 04 40 80 00       	mov    0x804004,%eax
  80135c:	8b 40 48             	mov    0x48(%eax),%eax
  80135f:	83 ec 04             	sub    $0x4,%esp
  801362:	51                   	push   %ecx
  801363:	50                   	push   %eax
  801364:	68 c0 27 80 00       	push   $0x8027c0
  801369:	e8 02 f0 ff ff       	call   800370 <cprintf>
	*dev = 0;
  80136e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801371:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801377:	83 c4 10             	add    $0x10,%esp
  80137a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80137f:	c9                   	leave  
  801380:	c3                   	ret    
			*dev = devtab[i];
  801381:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801384:	89 01                	mov    %eax,(%ecx)
			return 0;
  801386:	b8 00 00 00 00       	mov    $0x0,%eax
  80138b:	eb f2                	jmp    80137f <dev_lookup+0x48>

0080138d <fd_close>:
{
  80138d:	55                   	push   %ebp
  80138e:	89 e5                	mov    %esp,%ebp
  801390:	57                   	push   %edi
  801391:	56                   	push   %esi
  801392:	53                   	push   %ebx
  801393:	83 ec 1c             	sub    $0x1c,%esp
  801396:	8b 75 08             	mov    0x8(%ebp),%esi
  801399:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80139c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80139f:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013a0:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013a6:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013a9:	50                   	push   %eax
  8013aa:	e8 32 ff ff ff       	call   8012e1 <fd_lookup>
  8013af:	89 c3                	mov    %eax,%ebx
  8013b1:	83 c4 08             	add    $0x8,%esp
  8013b4:	85 c0                	test   %eax,%eax
  8013b6:	78 05                	js     8013bd <fd_close+0x30>
	    || fd != fd2)
  8013b8:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8013bb:	74 16                	je     8013d3 <fd_close+0x46>
		return (must_exist ? r : 0);
  8013bd:	89 f8                	mov    %edi,%eax
  8013bf:	84 c0                	test   %al,%al
  8013c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8013c6:	0f 44 d8             	cmove  %eax,%ebx
}
  8013c9:	89 d8                	mov    %ebx,%eax
  8013cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013ce:	5b                   	pop    %ebx
  8013cf:	5e                   	pop    %esi
  8013d0:	5f                   	pop    %edi
  8013d1:	5d                   	pop    %ebp
  8013d2:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013d3:	83 ec 08             	sub    $0x8,%esp
  8013d6:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8013d9:	50                   	push   %eax
  8013da:	ff 36                	pushl  (%esi)
  8013dc:	e8 56 ff ff ff       	call   801337 <dev_lookup>
  8013e1:	89 c3                	mov    %eax,%ebx
  8013e3:	83 c4 10             	add    $0x10,%esp
  8013e6:	85 c0                	test   %eax,%eax
  8013e8:	78 15                	js     8013ff <fd_close+0x72>
		if (dev->dev_close)
  8013ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013ed:	8b 40 10             	mov    0x10(%eax),%eax
  8013f0:	85 c0                	test   %eax,%eax
  8013f2:	74 1b                	je     80140f <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  8013f4:	83 ec 0c             	sub    $0xc,%esp
  8013f7:	56                   	push   %esi
  8013f8:	ff d0                	call   *%eax
  8013fa:	89 c3                	mov    %eax,%ebx
  8013fc:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8013ff:	83 ec 08             	sub    $0x8,%esp
  801402:	56                   	push   %esi
  801403:	6a 00                	push   $0x0
  801405:	e8 03 fa ff ff       	call   800e0d <sys_page_unmap>
	return r;
  80140a:	83 c4 10             	add    $0x10,%esp
  80140d:	eb ba                	jmp    8013c9 <fd_close+0x3c>
			r = 0;
  80140f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801414:	eb e9                	jmp    8013ff <fd_close+0x72>

00801416 <close>:

int
close(int fdnum)
{
  801416:	55                   	push   %ebp
  801417:	89 e5                	mov    %esp,%ebp
  801419:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80141c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80141f:	50                   	push   %eax
  801420:	ff 75 08             	pushl  0x8(%ebp)
  801423:	e8 b9 fe ff ff       	call   8012e1 <fd_lookup>
  801428:	83 c4 08             	add    $0x8,%esp
  80142b:	85 c0                	test   %eax,%eax
  80142d:	78 10                	js     80143f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80142f:	83 ec 08             	sub    $0x8,%esp
  801432:	6a 01                	push   $0x1
  801434:	ff 75 f4             	pushl  -0xc(%ebp)
  801437:	e8 51 ff ff ff       	call   80138d <fd_close>
  80143c:	83 c4 10             	add    $0x10,%esp
}
  80143f:	c9                   	leave  
  801440:	c3                   	ret    

00801441 <close_all>:

void
close_all(void)
{
  801441:	55                   	push   %ebp
  801442:	89 e5                	mov    %esp,%ebp
  801444:	53                   	push   %ebx
  801445:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801448:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80144d:	83 ec 0c             	sub    $0xc,%esp
  801450:	53                   	push   %ebx
  801451:	e8 c0 ff ff ff       	call   801416 <close>
	for (i = 0; i < MAXFD; i++)
  801456:	83 c3 01             	add    $0x1,%ebx
  801459:	83 c4 10             	add    $0x10,%esp
  80145c:	83 fb 20             	cmp    $0x20,%ebx
  80145f:	75 ec                	jne    80144d <close_all+0xc>
}
  801461:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801464:	c9                   	leave  
  801465:	c3                   	ret    

00801466 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801466:	55                   	push   %ebp
  801467:	89 e5                	mov    %esp,%ebp
  801469:	57                   	push   %edi
  80146a:	56                   	push   %esi
  80146b:	53                   	push   %ebx
  80146c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80146f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801472:	50                   	push   %eax
  801473:	ff 75 08             	pushl  0x8(%ebp)
  801476:	e8 66 fe ff ff       	call   8012e1 <fd_lookup>
  80147b:	89 c3                	mov    %eax,%ebx
  80147d:	83 c4 08             	add    $0x8,%esp
  801480:	85 c0                	test   %eax,%eax
  801482:	0f 88 81 00 00 00    	js     801509 <dup+0xa3>
		return r;
	close(newfdnum);
  801488:	83 ec 0c             	sub    $0xc,%esp
  80148b:	ff 75 0c             	pushl  0xc(%ebp)
  80148e:	e8 83 ff ff ff       	call   801416 <close>

	newfd = INDEX2FD(newfdnum);
  801493:	8b 75 0c             	mov    0xc(%ebp),%esi
  801496:	c1 e6 0c             	shl    $0xc,%esi
  801499:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80149f:	83 c4 04             	add    $0x4,%esp
  8014a2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014a5:	e8 d1 fd ff ff       	call   80127b <fd2data>
  8014aa:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8014ac:	89 34 24             	mov    %esi,(%esp)
  8014af:	e8 c7 fd ff ff       	call   80127b <fd2data>
  8014b4:	83 c4 10             	add    $0x10,%esp
  8014b7:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014b9:	89 d8                	mov    %ebx,%eax
  8014bb:	c1 e8 16             	shr    $0x16,%eax
  8014be:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014c5:	a8 01                	test   $0x1,%al
  8014c7:	74 11                	je     8014da <dup+0x74>
  8014c9:	89 d8                	mov    %ebx,%eax
  8014cb:	c1 e8 0c             	shr    $0xc,%eax
  8014ce:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014d5:	f6 c2 01             	test   $0x1,%dl
  8014d8:	75 39                	jne    801513 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014da:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014dd:	89 d0                	mov    %edx,%eax
  8014df:	c1 e8 0c             	shr    $0xc,%eax
  8014e2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014e9:	83 ec 0c             	sub    $0xc,%esp
  8014ec:	25 07 0e 00 00       	and    $0xe07,%eax
  8014f1:	50                   	push   %eax
  8014f2:	56                   	push   %esi
  8014f3:	6a 00                	push   $0x0
  8014f5:	52                   	push   %edx
  8014f6:	6a 00                	push   $0x0
  8014f8:	e8 ce f8 ff ff       	call   800dcb <sys_page_map>
  8014fd:	89 c3                	mov    %eax,%ebx
  8014ff:	83 c4 20             	add    $0x20,%esp
  801502:	85 c0                	test   %eax,%eax
  801504:	78 31                	js     801537 <dup+0xd1>
		goto err;

	return newfdnum;
  801506:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801509:	89 d8                	mov    %ebx,%eax
  80150b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80150e:	5b                   	pop    %ebx
  80150f:	5e                   	pop    %esi
  801510:	5f                   	pop    %edi
  801511:	5d                   	pop    %ebp
  801512:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801513:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80151a:	83 ec 0c             	sub    $0xc,%esp
  80151d:	25 07 0e 00 00       	and    $0xe07,%eax
  801522:	50                   	push   %eax
  801523:	57                   	push   %edi
  801524:	6a 00                	push   $0x0
  801526:	53                   	push   %ebx
  801527:	6a 00                	push   $0x0
  801529:	e8 9d f8 ff ff       	call   800dcb <sys_page_map>
  80152e:	89 c3                	mov    %eax,%ebx
  801530:	83 c4 20             	add    $0x20,%esp
  801533:	85 c0                	test   %eax,%eax
  801535:	79 a3                	jns    8014da <dup+0x74>
	sys_page_unmap(0, newfd);
  801537:	83 ec 08             	sub    $0x8,%esp
  80153a:	56                   	push   %esi
  80153b:	6a 00                	push   $0x0
  80153d:	e8 cb f8 ff ff       	call   800e0d <sys_page_unmap>
	sys_page_unmap(0, nva);
  801542:	83 c4 08             	add    $0x8,%esp
  801545:	57                   	push   %edi
  801546:	6a 00                	push   $0x0
  801548:	e8 c0 f8 ff ff       	call   800e0d <sys_page_unmap>
	return r;
  80154d:	83 c4 10             	add    $0x10,%esp
  801550:	eb b7                	jmp    801509 <dup+0xa3>

00801552 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801552:	55                   	push   %ebp
  801553:	89 e5                	mov    %esp,%ebp
  801555:	53                   	push   %ebx
  801556:	83 ec 14             	sub    $0x14,%esp
  801559:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80155c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80155f:	50                   	push   %eax
  801560:	53                   	push   %ebx
  801561:	e8 7b fd ff ff       	call   8012e1 <fd_lookup>
  801566:	83 c4 08             	add    $0x8,%esp
  801569:	85 c0                	test   %eax,%eax
  80156b:	78 3f                	js     8015ac <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80156d:	83 ec 08             	sub    $0x8,%esp
  801570:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801573:	50                   	push   %eax
  801574:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801577:	ff 30                	pushl  (%eax)
  801579:	e8 b9 fd ff ff       	call   801337 <dev_lookup>
  80157e:	83 c4 10             	add    $0x10,%esp
  801581:	85 c0                	test   %eax,%eax
  801583:	78 27                	js     8015ac <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801585:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801588:	8b 42 08             	mov    0x8(%edx),%eax
  80158b:	83 e0 03             	and    $0x3,%eax
  80158e:	83 f8 01             	cmp    $0x1,%eax
  801591:	74 1e                	je     8015b1 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801593:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801596:	8b 40 08             	mov    0x8(%eax),%eax
  801599:	85 c0                	test   %eax,%eax
  80159b:	74 35                	je     8015d2 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80159d:	83 ec 04             	sub    $0x4,%esp
  8015a0:	ff 75 10             	pushl  0x10(%ebp)
  8015a3:	ff 75 0c             	pushl  0xc(%ebp)
  8015a6:	52                   	push   %edx
  8015a7:	ff d0                	call   *%eax
  8015a9:	83 c4 10             	add    $0x10,%esp
}
  8015ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015af:	c9                   	leave  
  8015b0:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015b1:	a1 04 40 80 00       	mov    0x804004,%eax
  8015b6:	8b 40 48             	mov    0x48(%eax),%eax
  8015b9:	83 ec 04             	sub    $0x4,%esp
  8015bc:	53                   	push   %ebx
  8015bd:	50                   	push   %eax
  8015be:	68 01 28 80 00       	push   $0x802801
  8015c3:	e8 a8 ed ff ff       	call   800370 <cprintf>
		return -E_INVAL;
  8015c8:	83 c4 10             	add    $0x10,%esp
  8015cb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015d0:	eb da                	jmp    8015ac <read+0x5a>
		return -E_NOT_SUPP;
  8015d2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015d7:	eb d3                	jmp    8015ac <read+0x5a>

008015d9 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015d9:	55                   	push   %ebp
  8015da:	89 e5                	mov    %esp,%ebp
  8015dc:	57                   	push   %edi
  8015dd:	56                   	push   %esi
  8015de:	53                   	push   %ebx
  8015df:	83 ec 0c             	sub    $0xc,%esp
  8015e2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015e5:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015ed:	39 f3                	cmp    %esi,%ebx
  8015ef:	73 25                	jae    801616 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015f1:	83 ec 04             	sub    $0x4,%esp
  8015f4:	89 f0                	mov    %esi,%eax
  8015f6:	29 d8                	sub    %ebx,%eax
  8015f8:	50                   	push   %eax
  8015f9:	89 d8                	mov    %ebx,%eax
  8015fb:	03 45 0c             	add    0xc(%ebp),%eax
  8015fe:	50                   	push   %eax
  8015ff:	57                   	push   %edi
  801600:	e8 4d ff ff ff       	call   801552 <read>
		if (m < 0)
  801605:	83 c4 10             	add    $0x10,%esp
  801608:	85 c0                	test   %eax,%eax
  80160a:	78 08                	js     801614 <readn+0x3b>
			return m;
		if (m == 0)
  80160c:	85 c0                	test   %eax,%eax
  80160e:	74 06                	je     801616 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  801610:	01 c3                	add    %eax,%ebx
  801612:	eb d9                	jmp    8015ed <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801614:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801616:	89 d8                	mov    %ebx,%eax
  801618:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80161b:	5b                   	pop    %ebx
  80161c:	5e                   	pop    %esi
  80161d:	5f                   	pop    %edi
  80161e:	5d                   	pop    %ebp
  80161f:	c3                   	ret    

00801620 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801620:	55                   	push   %ebp
  801621:	89 e5                	mov    %esp,%ebp
  801623:	53                   	push   %ebx
  801624:	83 ec 14             	sub    $0x14,%esp
  801627:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80162a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80162d:	50                   	push   %eax
  80162e:	53                   	push   %ebx
  80162f:	e8 ad fc ff ff       	call   8012e1 <fd_lookup>
  801634:	83 c4 08             	add    $0x8,%esp
  801637:	85 c0                	test   %eax,%eax
  801639:	78 3a                	js     801675 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80163b:	83 ec 08             	sub    $0x8,%esp
  80163e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801641:	50                   	push   %eax
  801642:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801645:	ff 30                	pushl  (%eax)
  801647:	e8 eb fc ff ff       	call   801337 <dev_lookup>
  80164c:	83 c4 10             	add    $0x10,%esp
  80164f:	85 c0                	test   %eax,%eax
  801651:	78 22                	js     801675 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801653:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801656:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80165a:	74 1e                	je     80167a <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80165c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80165f:	8b 52 0c             	mov    0xc(%edx),%edx
  801662:	85 d2                	test   %edx,%edx
  801664:	74 35                	je     80169b <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801666:	83 ec 04             	sub    $0x4,%esp
  801669:	ff 75 10             	pushl  0x10(%ebp)
  80166c:	ff 75 0c             	pushl  0xc(%ebp)
  80166f:	50                   	push   %eax
  801670:	ff d2                	call   *%edx
  801672:	83 c4 10             	add    $0x10,%esp
}
  801675:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801678:	c9                   	leave  
  801679:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80167a:	a1 04 40 80 00       	mov    0x804004,%eax
  80167f:	8b 40 48             	mov    0x48(%eax),%eax
  801682:	83 ec 04             	sub    $0x4,%esp
  801685:	53                   	push   %ebx
  801686:	50                   	push   %eax
  801687:	68 1d 28 80 00       	push   $0x80281d
  80168c:	e8 df ec ff ff       	call   800370 <cprintf>
		return -E_INVAL;
  801691:	83 c4 10             	add    $0x10,%esp
  801694:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801699:	eb da                	jmp    801675 <write+0x55>
		return -E_NOT_SUPP;
  80169b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016a0:	eb d3                	jmp    801675 <write+0x55>

008016a2 <seek>:

int
seek(int fdnum, off_t offset)
{
  8016a2:	55                   	push   %ebp
  8016a3:	89 e5                	mov    %esp,%ebp
  8016a5:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016a8:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016ab:	50                   	push   %eax
  8016ac:	ff 75 08             	pushl  0x8(%ebp)
  8016af:	e8 2d fc ff ff       	call   8012e1 <fd_lookup>
  8016b4:	83 c4 08             	add    $0x8,%esp
  8016b7:	85 c0                	test   %eax,%eax
  8016b9:	78 0e                	js     8016c9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016be:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016c1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016c9:	c9                   	leave  
  8016ca:	c3                   	ret    

008016cb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016cb:	55                   	push   %ebp
  8016cc:	89 e5                	mov    %esp,%ebp
  8016ce:	53                   	push   %ebx
  8016cf:	83 ec 14             	sub    $0x14,%esp
  8016d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016d5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d8:	50                   	push   %eax
  8016d9:	53                   	push   %ebx
  8016da:	e8 02 fc ff ff       	call   8012e1 <fd_lookup>
  8016df:	83 c4 08             	add    $0x8,%esp
  8016e2:	85 c0                	test   %eax,%eax
  8016e4:	78 37                	js     80171d <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e6:	83 ec 08             	sub    $0x8,%esp
  8016e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ec:	50                   	push   %eax
  8016ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f0:	ff 30                	pushl  (%eax)
  8016f2:	e8 40 fc ff ff       	call   801337 <dev_lookup>
  8016f7:	83 c4 10             	add    $0x10,%esp
  8016fa:	85 c0                	test   %eax,%eax
  8016fc:	78 1f                	js     80171d <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801701:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801705:	74 1b                	je     801722 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801707:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80170a:	8b 52 18             	mov    0x18(%edx),%edx
  80170d:	85 d2                	test   %edx,%edx
  80170f:	74 32                	je     801743 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801711:	83 ec 08             	sub    $0x8,%esp
  801714:	ff 75 0c             	pushl  0xc(%ebp)
  801717:	50                   	push   %eax
  801718:	ff d2                	call   *%edx
  80171a:	83 c4 10             	add    $0x10,%esp
}
  80171d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801720:	c9                   	leave  
  801721:	c3                   	ret    
			thisenv->env_id, fdnum);
  801722:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801727:	8b 40 48             	mov    0x48(%eax),%eax
  80172a:	83 ec 04             	sub    $0x4,%esp
  80172d:	53                   	push   %ebx
  80172e:	50                   	push   %eax
  80172f:	68 e0 27 80 00       	push   $0x8027e0
  801734:	e8 37 ec ff ff       	call   800370 <cprintf>
		return -E_INVAL;
  801739:	83 c4 10             	add    $0x10,%esp
  80173c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801741:	eb da                	jmp    80171d <ftruncate+0x52>
		return -E_NOT_SUPP;
  801743:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801748:	eb d3                	jmp    80171d <ftruncate+0x52>

0080174a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80174a:	55                   	push   %ebp
  80174b:	89 e5                	mov    %esp,%ebp
  80174d:	53                   	push   %ebx
  80174e:	83 ec 14             	sub    $0x14,%esp
  801751:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801754:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801757:	50                   	push   %eax
  801758:	ff 75 08             	pushl  0x8(%ebp)
  80175b:	e8 81 fb ff ff       	call   8012e1 <fd_lookup>
  801760:	83 c4 08             	add    $0x8,%esp
  801763:	85 c0                	test   %eax,%eax
  801765:	78 4b                	js     8017b2 <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801767:	83 ec 08             	sub    $0x8,%esp
  80176a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80176d:	50                   	push   %eax
  80176e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801771:	ff 30                	pushl  (%eax)
  801773:	e8 bf fb ff ff       	call   801337 <dev_lookup>
  801778:	83 c4 10             	add    $0x10,%esp
  80177b:	85 c0                	test   %eax,%eax
  80177d:	78 33                	js     8017b2 <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  80177f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801782:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801786:	74 2f                	je     8017b7 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801788:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80178b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801792:	00 00 00 
	stat->st_isdir = 0;
  801795:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80179c:	00 00 00 
	stat->st_dev = dev;
  80179f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017a5:	83 ec 08             	sub    $0x8,%esp
  8017a8:	53                   	push   %ebx
  8017a9:	ff 75 f0             	pushl  -0x10(%ebp)
  8017ac:	ff 50 14             	call   *0x14(%eax)
  8017af:	83 c4 10             	add    $0x10,%esp
}
  8017b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017b5:	c9                   	leave  
  8017b6:	c3                   	ret    
		return -E_NOT_SUPP;
  8017b7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017bc:	eb f4                	jmp    8017b2 <fstat+0x68>

008017be <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017be:	55                   	push   %ebp
  8017bf:	89 e5                	mov    %esp,%ebp
  8017c1:	56                   	push   %esi
  8017c2:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017c3:	83 ec 08             	sub    $0x8,%esp
  8017c6:	6a 00                	push   $0x0
  8017c8:	ff 75 08             	pushl  0x8(%ebp)
  8017cb:	e8 da 01 00 00       	call   8019aa <open>
  8017d0:	89 c3                	mov    %eax,%ebx
  8017d2:	83 c4 10             	add    $0x10,%esp
  8017d5:	85 c0                	test   %eax,%eax
  8017d7:	78 1b                	js     8017f4 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017d9:	83 ec 08             	sub    $0x8,%esp
  8017dc:	ff 75 0c             	pushl  0xc(%ebp)
  8017df:	50                   	push   %eax
  8017e0:	e8 65 ff ff ff       	call   80174a <fstat>
  8017e5:	89 c6                	mov    %eax,%esi
	close(fd);
  8017e7:	89 1c 24             	mov    %ebx,(%esp)
  8017ea:	e8 27 fc ff ff       	call   801416 <close>
	return r;
  8017ef:	83 c4 10             	add    $0x10,%esp
  8017f2:	89 f3                	mov    %esi,%ebx
}
  8017f4:	89 d8                	mov    %ebx,%eax
  8017f6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017f9:	5b                   	pop    %ebx
  8017fa:	5e                   	pop    %esi
  8017fb:	5d                   	pop    %ebp
  8017fc:	c3                   	ret    

008017fd <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017fd:	55                   	push   %ebp
  8017fe:	89 e5                	mov    %esp,%ebp
  801800:	56                   	push   %esi
  801801:	53                   	push   %ebx
  801802:	89 c6                	mov    %eax,%esi
  801804:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801806:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80180d:	74 27                	je     801836 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80180f:	6a 07                	push   $0x7
  801811:	68 00 50 80 00       	push   $0x805000
  801816:	56                   	push   %esi
  801817:	ff 35 00 40 80 00    	pushl  0x804000
  80181d:	e8 f3 07 00 00       	call   802015 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801822:	83 c4 0c             	add    $0xc,%esp
  801825:	6a 00                	push   $0x0
  801827:	53                   	push   %ebx
  801828:	6a 00                	push   $0x0
  80182a:	e8 7f 07 00 00       	call   801fae <ipc_recv>
}
  80182f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801832:	5b                   	pop    %ebx
  801833:	5e                   	pop    %esi
  801834:	5d                   	pop    %ebp
  801835:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801836:	83 ec 0c             	sub    $0xc,%esp
  801839:	6a 01                	push   $0x1
  80183b:	e8 29 08 00 00       	call   802069 <ipc_find_env>
  801840:	a3 00 40 80 00       	mov    %eax,0x804000
  801845:	83 c4 10             	add    $0x10,%esp
  801848:	eb c5                	jmp    80180f <fsipc+0x12>

0080184a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80184a:	55                   	push   %ebp
  80184b:	89 e5                	mov    %esp,%ebp
  80184d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801850:	8b 45 08             	mov    0x8(%ebp),%eax
  801853:	8b 40 0c             	mov    0xc(%eax),%eax
  801856:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80185b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80185e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801863:	ba 00 00 00 00       	mov    $0x0,%edx
  801868:	b8 02 00 00 00       	mov    $0x2,%eax
  80186d:	e8 8b ff ff ff       	call   8017fd <fsipc>
}
  801872:	c9                   	leave  
  801873:	c3                   	ret    

00801874 <devfile_flush>:
{
  801874:	55                   	push   %ebp
  801875:	89 e5                	mov    %esp,%ebp
  801877:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80187a:	8b 45 08             	mov    0x8(%ebp),%eax
  80187d:	8b 40 0c             	mov    0xc(%eax),%eax
  801880:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801885:	ba 00 00 00 00       	mov    $0x0,%edx
  80188a:	b8 06 00 00 00       	mov    $0x6,%eax
  80188f:	e8 69 ff ff ff       	call   8017fd <fsipc>
}
  801894:	c9                   	leave  
  801895:	c3                   	ret    

00801896 <devfile_stat>:
{
  801896:	55                   	push   %ebp
  801897:	89 e5                	mov    %esp,%ebp
  801899:	53                   	push   %ebx
  80189a:	83 ec 04             	sub    $0x4,%esp
  80189d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a3:	8b 40 0c             	mov    0xc(%eax),%eax
  8018a6:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b0:	b8 05 00 00 00       	mov    $0x5,%eax
  8018b5:	e8 43 ff ff ff       	call   8017fd <fsipc>
  8018ba:	85 c0                	test   %eax,%eax
  8018bc:	78 2c                	js     8018ea <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018be:	83 ec 08             	sub    $0x8,%esp
  8018c1:	68 00 50 80 00       	push   $0x805000
  8018c6:	53                   	push   %ebx
  8018c7:	e8 c3 f0 ff ff       	call   80098f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018cc:	a1 80 50 80 00       	mov    0x805080,%eax
  8018d1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018d7:	a1 84 50 80 00       	mov    0x805084,%eax
  8018dc:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018e2:	83 c4 10             	add    $0x10,%esp
  8018e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018ed:	c9                   	leave  
  8018ee:	c3                   	ret    

008018ef <devfile_write>:
{
  8018ef:	55                   	push   %ebp
  8018f0:	89 e5                	mov    %esp,%ebp
  8018f2:	83 ec 0c             	sub    $0xc,%esp
  8018f5:	8b 45 10             	mov    0x10(%ebp),%eax
    	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8018fb:	8b 52 0c             	mov    0xc(%edx),%edx
  8018fe:	89 15 00 50 80 00    	mov    %edx,0x805000
    	fsipcbuf.write.req_n = n;
  801904:	a3 04 50 80 00       	mov    %eax,0x805004
    	memmove(fsipcbuf.write.req_buf, buf, n);
  801909:	50                   	push   %eax
  80190a:	ff 75 0c             	pushl  0xc(%ebp)
  80190d:	68 08 50 80 00       	push   $0x805008
  801912:	e8 06 f2 ff ff       	call   800b1d <memmove>
    	return fsipc(FSREQ_WRITE, NULL);
  801917:	ba 00 00 00 00       	mov    $0x0,%edx
  80191c:	b8 04 00 00 00       	mov    $0x4,%eax
  801921:	e8 d7 fe ff ff       	call   8017fd <fsipc>
}
  801926:	c9                   	leave  
  801927:	c3                   	ret    

00801928 <devfile_read>:
{
  801928:	55                   	push   %ebp
  801929:	89 e5                	mov    %esp,%ebp
  80192b:	56                   	push   %esi
  80192c:	53                   	push   %ebx
  80192d:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801930:	8b 45 08             	mov    0x8(%ebp),%eax
  801933:	8b 40 0c             	mov    0xc(%eax),%eax
  801936:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80193b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801941:	ba 00 00 00 00       	mov    $0x0,%edx
  801946:	b8 03 00 00 00       	mov    $0x3,%eax
  80194b:	e8 ad fe ff ff       	call   8017fd <fsipc>
  801950:	89 c3                	mov    %eax,%ebx
  801952:	85 c0                	test   %eax,%eax
  801954:	78 1f                	js     801975 <devfile_read+0x4d>
	assert(r <= n);
  801956:	39 f0                	cmp    %esi,%eax
  801958:	77 24                	ja     80197e <devfile_read+0x56>
	assert(r <= PGSIZE);
  80195a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80195f:	7f 33                	jg     801994 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801961:	83 ec 04             	sub    $0x4,%esp
  801964:	50                   	push   %eax
  801965:	68 00 50 80 00       	push   $0x805000
  80196a:	ff 75 0c             	pushl  0xc(%ebp)
  80196d:	e8 ab f1 ff ff       	call   800b1d <memmove>
	return r;
  801972:	83 c4 10             	add    $0x10,%esp
}
  801975:	89 d8                	mov    %ebx,%eax
  801977:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80197a:	5b                   	pop    %ebx
  80197b:	5e                   	pop    %esi
  80197c:	5d                   	pop    %ebp
  80197d:	c3                   	ret    
	assert(r <= n);
  80197e:	68 4c 28 80 00       	push   $0x80284c
  801983:	68 53 28 80 00       	push   $0x802853
  801988:	6a 7c                	push   $0x7c
  80198a:	68 68 28 80 00       	push   $0x802868
  80198f:	e8 01 e9 ff ff       	call   800295 <_panic>
	assert(r <= PGSIZE);
  801994:	68 73 28 80 00       	push   $0x802873
  801999:	68 53 28 80 00       	push   $0x802853
  80199e:	6a 7d                	push   $0x7d
  8019a0:	68 68 28 80 00       	push   $0x802868
  8019a5:	e8 eb e8 ff ff       	call   800295 <_panic>

008019aa <open>:
{
  8019aa:	55                   	push   %ebp
  8019ab:	89 e5                	mov    %esp,%ebp
  8019ad:	56                   	push   %esi
  8019ae:	53                   	push   %ebx
  8019af:	83 ec 1c             	sub    $0x1c,%esp
  8019b2:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8019b5:	56                   	push   %esi
  8019b6:	e8 9d ef ff ff       	call   800958 <strlen>
  8019bb:	83 c4 10             	add    $0x10,%esp
  8019be:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019c3:	7f 6c                	jg     801a31 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8019c5:	83 ec 0c             	sub    $0xc,%esp
  8019c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019cb:	50                   	push   %eax
  8019cc:	e8 c1 f8 ff ff       	call   801292 <fd_alloc>
  8019d1:	89 c3                	mov    %eax,%ebx
  8019d3:	83 c4 10             	add    $0x10,%esp
  8019d6:	85 c0                	test   %eax,%eax
  8019d8:	78 3c                	js     801a16 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8019da:	83 ec 08             	sub    $0x8,%esp
  8019dd:	56                   	push   %esi
  8019de:	68 00 50 80 00       	push   $0x805000
  8019e3:	e8 a7 ef ff ff       	call   80098f <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019eb:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019f3:	b8 01 00 00 00       	mov    $0x1,%eax
  8019f8:	e8 00 fe ff ff       	call   8017fd <fsipc>
  8019fd:	89 c3                	mov    %eax,%ebx
  8019ff:	83 c4 10             	add    $0x10,%esp
  801a02:	85 c0                	test   %eax,%eax
  801a04:	78 19                	js     801a1f <open+0x75>
	return fd2num(fd);
  801a06:	83 ec 0c             	sub    $0xc,%esp
  801a09:	ff 75 f4             	pushl  -0xc(%ebp)
  801a0c:	e8 5a f8 ff ff       	call   80126b <fd2num>
  801a11:	89 c3                	mov    %eax,%ebx
  801a13:	83 c4 10             	add    $0x10,%esp
}
  801a16:	89 d8                	mov    %ebx,%eax
  801a18:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a1b:	5b                   	pop    %ebx
  801a1c:	5e                   	pop    %esi
  801a1d:	5d                   	pop    %ebp
  801a1e:	c3                   	ret    
		fd_close(fd, 0);
  801a1f:	83 ec 08             	sub    $0x8,%esp
  801a22:	6a 00                	push   $0x0
  801a24:	ff 75 f4             	pushl  -0xc(%ebp)
  801a27:	e8 61 f9 ff ff       	call   80138d <fd_close>
		return r;
  801a2c:	83 c4 10             	add    $0x10,%esp
  801a2f:	eb e5                	jmp    801a16 <open+0x6c>
		return -E_BAD_PATH;
  801a31:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801a36:	eb de                	jmp    801a16 <open+0x6c>

00801a38 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a38:	55                   	push   %ebp
  801a39:	89 e5                	mov    %esp,%ebp
  801a3b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a3e:	ba 00 00 00 00       	mov    $0x0,%edx
  801a43:	b8 08 00 00 00       	mov    $0x8,%eax
  801a48:	e8 b0 fd ff ff       	call   8017fd <fsipc>
}
  801a4d:	c9                   	leave  
  801a4e:	c3                   	ret    

00801a4f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a4f:	55                   	push   %ebp
  801a50:	89 e5                	mov    %esp,%ebp
  801a52:	56                   	push   %esi
  801a53:	53                   	push   %ebx
  801a54:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a57:	83 ec 0c             	sub    $0xc,%esp
  801a5a:	ff 75 08             	pushl  0x8(%ebp)
  801a5d:	e8 19 f8 ff ff       	call   80127b <fd2data>
  801a62:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a64:	83 c4 08             	add    $0x8,%esp
  801a67:	68 7f 28 80 00       	push   $0x80287f
  801a6c:	53                   	push   %ebx
  801a6d:	e8 1d ef ff ff       	call   80098f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a72:	8b 46 04             	mov    0x4(%esi),%eax
  801a75:	2b 06                	sub    (%esi),%eax
  801a77:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a7d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a84:	00 00 00 
	stat->st_dev = &devpipe;
  801a87:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a8e:	30 80 00 
	return 0;
}
  801a91:	b8 00 00 00 00       	mov    $0x0,%eax
  801a96:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a99:	5b                   	pop    %ebx
  801a9a:	5e                   	pop    %esi
  801a9b:	5d                   	pop    %ebp
  801a9c:	c3                   	ret    

00801a9d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a9d:	55                   	push   %ebp
  801a9e:	89 e5                	mov    %esp,%ebp
  801aa0:	53                   	push   %ebx
  801aa1:	83 ec 0c             	sub    $0xc,%esp
  801aa4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801aa7:	53                   	push   %ebx
  801aa8:	6a 00                	push   $0x0
  801aaa:	e8 5e f3 ff ff       	call   800e0d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801aaf:	89 1c 24             	mov    %ebx,(%esp)
  801ab2:	e8 c4 f7 ff ff       	call   80127b <fd2data>
  801ab7:	83 c4 08             	add    $0x8,%esp
  801aba:	50                   	push   %eax
  801abb:	6a 00                	push   $0x0
  801abd:	e8 4b f3 ff ff       	call   800e0d <sys_page_unmap>
}
  801ac2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ac5:	c9                   	leave  
  801ac6:	c3                   	ret    

00801ac7 <_pipeisclosed>:
{
  801ac7:	55                   	push   %ebp
  801ac8:	89 e5                	mov    %esp,%ebp
  801aca:	57                   	push   %edi
  801acb:	56                   	push   %esi
  801acc:	53                   	push   %ebx
  801acd:	83 ec 1c             	sub    $0x1c,%esp
  801ad0:	89 c7                	mov    %eax,%edi
  801ad2:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801ad4:	a1 04 40 80 00       	mov    0x804004,%eax
  801ad9:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801adc:	83 ec 0c             	sub    $0xc,%esp
  801adf:	57                   	push   %edi
  801ae0:	e8 bd 05 00 00       	call   8020a2 <pageref>
  801ae5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801ae8:	89 34 24             	mov    %esi,(%esp)
  801aeb:	e8 b2 05 00 00       	call   8020a2 <pageref>
		nn = thisenv->env_runs;
  801af0:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801af6:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801af9:	83 c4 10             	add    $0x10,%esp
  801afc:	39 cb                	cmp    %ecx,%ebx
  801afe:	74 1b                	je     801b1b <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801b00:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b03:	75 cf                	jne    801ad4 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b05:	8b 42 58             	mov    0x58(%edx),%eax
  801b08:	6a 01                	push   $0x1
  801b0a:	50                   	push   %eax
  801b0b:	53                   	push   %ebx
  801b0c:	68 86 28 80 00       	push   $0x802886
  801b11:	e8 5a e8 ff ff       	call   800370 <cprintf>
  801b16:	83 c4 10             	add    $0x10,%esp
  801b19:	eb b9                	jmp    801ad4 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801b1b:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b1e:	0f 94 c0             	sete   %al
  801b21:	0f b6 c0             	movzbl %al,%eax
}
  801b24:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b27:	5b                   	pop    %ebx
  801b28:	5e                   	pop    %esi
  801b29:	5f                   	pop    %edi
  801b2a:	5d                   	pop    %ebp
  801b2b:	c3                   	ret    

00801b2c <devpipe_write>:
{
  801b2c:	55                   	push   %ebp
  801b2d:	89 e5                	mov    %esp,%ebp
  801b2f:	57                   	push   %edi
  801b30:	56                   	push   %esi
  801b31:	53                   	push   %ebx
  801b32:	83 ec 28             	sub    $0x28,%esp
  801b35:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801b38:	56                   	push   %esi
  801b39:	e8 3d f7 ff ff       	call   80127b <fd2data>
  801b3e:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b40:	83 c4 10             	add    $0x10,%esp
  801b43:	bf 00 00 00 00       	mov    $0x0,%edi
  801b48:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b4b:	74 4f                	je     801b9c <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b4d:	8b 43 04             	mov    0x4(%ebx),%eax
  801b50:	8b 0b                	mov    (%ebx),%ecx
  801b52:	8d 51 20             	lea    0x20(%ecx),%edx
  801b55:	39 d0                	cmp    %edx,%eax
  801b57:	72 14                	jb     801b6d <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801b59:	89 da                	mov    %ebx,%edx
  801b5b:	89 f0                	mov    %esi,%eax
  801b5d:	e8 65 ff ff ff       	call   801ac7 <_pipeisclosed>
  801b62:	85 c0                	test   %eax,%eax
  801b64:	75 3a                	jne    801ba0 <devpipe_write+0x74>
			sys_yield();
  801b66:	e8 fe f1 ff ff       	call   800d69 <sys_yield>
  801b6b:	eb e0                	jmp    801b4d <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b70:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b74:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b77:	89 c2                	mov    %eax,%edx
  801b79:	c1 fa 1f             	sar    $0x1f,%edx
  801b7c:	89 d1                	mov    %edx,%ecx
  801b7e:	c1 e9 1b             	shr    $0x1b,%ecx
  801b81:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b84:	83 e2 1f             	and    $0x1f,%edx
  801b87:	29 ca                	sub    %ecx,%edx
  801b89:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b8d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b91:	83 c0 01             	add    $0x1,%eax
  801b94:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801b97:	83 c7 01             	add    $0x1,%edi
  801b9a:	eb ac                	jmp    801b48 <devpipe_write+0x1c>
	return i;
  801b9c:	89 f8                	mov    %edi,%eax
  801b9e:	eb 05                	jmp    801ba5 <devpipe_write+0x79>
				return 0;
  801ba0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ba5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ba8:	5b                   	pop    %ebx
  801ba9:	5e                   	pop    %esi
  801baa:	5f                   	pop    %edi
  801bab:	5d                   	pop    %ebp
  801bac:	c3                   	ret    

00801bad <devpipe_read>:
{
  801bad:	55                   	push   %ebp
  801bae:	89 e5                	mov    %esp,%ebp
  801bb0:	57                   	push   %edi
  801bb1:	56                   	push   %esi
  801bb2:	53                   	push   %ebx
  801bb3:	83 ec 18             	sub    $0x18,%esp
  801bb6:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801bb9:	57                   	push   %edi
  801bba:	e8 bc f6 ff ff       	call   80127b <fd2data>
  801bbf:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801bc1:	83 c4 10             	add    $0x10,%esp
  801bc4:	be 00 00 00 00       	mov    $0x0,%esi
  801bc9:	3b 75 10             	cmp    0x10(%ebp),%esi
  801bcc:	74 47                	je     801c15 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801bce:	8b 03                	mov    (%ebx),%eax
  801bd0:	3b 43 04             	cmp    0x4(%ebx),%eax
  801bd3:	75 22                	jne    801bf7 <devpipe_read+0x4a>
			if (i > 0)
  801bd5:	85 f6                	test   %esi,%esi
  801bd7:	75 14                	jne    801bed <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801bd9:	89 da                	mov    %ebx,%edx
  801bdb:	89 f8                	mov    %edi,%eax
  801bdd:	e8 e5 fe ff ff       	call   801ac7 <_pipeisclosed>
  801be2:	85 c0                	test   %eax,%eax
  801be4:	75 33                	jne    801c19 <devpipe_read+0x6c>
			sys_yield();
  801be6:	e8 7e f1 ff ff       	call   800d69 <sys_yield>
  801beb:	eb e1                	jmp    801bce <devpipe_read+0x21>
				return i;
  801bed:	89 f0                	mov    %esi,%eax
}
  801bef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bf2:	5b                   	pop    %ebx
  801bf3:	5e                   	pop    %esi
  801bf4:	5f                   	pop    %edi
  801bf5:	5d                   	pop    %ebp
  801bf6:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bf7:	99                   	cltd   
  801bf8:	c1 ea 1b             	shr    $0x1b,%edx
  801bfb:	01 d0                	add    %edx,%eax
  801bfd:	83 e0 1f             	and    $0x1f,%eax
  801c00:	29 d0                	sub    %edx,%eax
  801c02:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801c07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c0a:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801c0d:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801c10:	83 c6 01             	add    $0x1,%esi
  801c13:	eb b4                	jmp    801bc9 <devpipe_read+0x1c>
	return i;
  801c15:	89 f0                	mov    %esi,%eax
  801c17:	eb d6                	jmp    801bef <devpipe_read+0x42>
				return 0;
  801c19:	b8 00 00 00 00       	mov    $0x0,%eax
  801c1e:	eb cf                	jmp    801bef <devpipe_read+0x42>

00801c20 <pipe>:
{
  801c20:	55                   	push   %ebp
  801c21:	89 e5                	mov    %esp,%ebp
  801c23:	56                   	push   %esi
  801c24:	53                   	push   %ebx
  801c25:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801c28:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c2b:	50                   	push   %eax
  801c2c:	e8 61 f6 ff ff       	call   801292 <fd_alloc>
  801c31:	89 c3                	mov    %eax,%ebx
  801c33:	83 c4 10             	add    $0x10,%esp
  801c36:	85 c0                	test   %eax,%eax
  801c38:	78 5b                	js     801c95 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c3a:	83 ec 04             	sub    $0x4,%esp
  801c3d:	68 07 04 00 00       	push   $0x407
  801c42:	ff 75 f4             	pushl  -0xc(%ebp)
  801c45:	6a 00                	push   $0x0
  801c47:	e8 3c f1 ff ff       	call   800d88 <sys_page_alloc>
  801c4c:	89 c3                	mov    %eax,%ebx
  801c4e:	83 c4 10             	add    $0x10,%esp
  801c51:	85 c0                	test   %eax,%eax
  801c53:	78 40                	js     801c95 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  801c55:	83 ec 0c             	sub    $0xc,%esp
  801c58:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c5b:	50                   	push   %eax
  801c5c:	e8 31 f6 ff ff       	call   801292 <fd_alloc>
  801c61:	89 c3                	mov    %eax,%ebx
  801c63:	83 c4 10             	add    $0x10,%esp
  801c66:	85 c0                	test   %eax,%eax
  801c68:	78 1b                	js     801c85 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c6a:	83 ec 04             	sub    $0x4,%esp
  801c6d:	68 07 04 00 00       	push   $0x407
  801c72:	ff 75 f0             	pushl  -0x10(%ebp)
  801c75:	6a 00                	push   $0x0
  801c77:	e8 0c f1 ff ff       	call   800d88 <sys_page_alloc>
  801c7c:	89 c3                	mov    %eax,%ebx
  801c7e:	83 c4 10             	add    $0x10,%esp
  801c81:	85 c0                	test   %eax,%eax
  801c83:	79 19                	jns    801c9e <pipe+0x7e>
	sys_page_unmap(0, fd0);
  801c85:	83 ec 08             	sub    $0x8,%esp
  801c88:	ff 75 f4             	pushl  -0xc(%ebp)
  801c8b:	6a 00                	push   $0x0
  801c8d:	e8 7b f1 ff ff       	call   800e0d <sys_page_unmap>
  801c92:	83 c4 10             	add    $0x10,%esp
}
  801c95:	89 d8                	mov    %ebx,%eax
  801c97:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c9a:	5b                   	pop    %ebx
  801c9b:	5e                   	pop    %esi
  801c9c:	5d                   	pop    %ebp
  801c9d:	c3                   	ret    
	va = fd2data(fd0);
  801c9e:	83 ec 0c             	sub    $0xc,%esp
  801ca1:	ff 75 f4             	pushl  -0xc(%ebp)
  801ca4:	e8 d2 f5 ff ff       	call   80127b <fd2data>
  801ca9:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cab:	83 c4 0c             	add    $0xc,%esp
  801cae:	68 07 04 00 00       	push   $0x407
  801cb3:	50                   	push   %eax
  801cb4:	6a 00                	push   $0x0
  801cb6:	e8 cd f0 ff ff       	call   800d88 <sys_page_alloc>
  801cbb:	89 c3                	mov    %eax,%ebx
  801cbd:	83 c4 10             	add    $0x10,%esp
  801cc0:	85 c0                	test   %eax,%eax
  801cc2:	0f 88 8c 00 00 00    	js     801d54 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cc8:	83 ec 0c             	sub    $0xc,%esp
  801ccb:	ff 75 f0             	pushl  -0x10(%ebp)
  801cce:	e8 a8 f5 ff ff       	call   80127b <fd2data>
  801cd3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cda:	50                   	push   %eax
  801cdb:	6a 00                	push   $0x0
  801cdd:	56                   	push   %esi
  801cde:	6a 00                	push   $0x0
  801ce0:	e8 e6 f0 ff ff       	call   800dcb <sys_page_map>
  801ce5:	89 c3                	mov    %eax,%ebx
  801ce7:	83 c4 20             	add    $0x20,%esp
  801cea:	85 c0                	test   %eax,%eax
  801cec:	78 58                	js     801d46 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801cee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cf7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801cf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cfc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801d03:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d06:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d0c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d11:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801d18:	83 ec 0c             	sub    $0xc,%esp
  801d1b:	ff 75 f4             	pushl  -0xc(%ebp)
  801d1e:	e8 48 f5 ff ff       	call   80126b <fd2num>
  801d23:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d26:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d28:	83 c4 04             	add    $0x4,%esp
  801d2b:	ff 75 f0             	pushl  -0x10(%ebp)
  801d2e:	e8 38 f5 ff ff       	call   80126b <fd2num>
  801d33:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d36:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d39:	83 c4 10             	add    $0x10,%esp
  801d3c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d41:	e9 4f ff ff ff       	jmp    801c95 <pipe+0x75>
	sys_page_unmap(0, va);
  801d46:	83 ec 08             	sub    $0x8,%esp
  801d49:	56                   	push   %esi
  801d4a:	6a 00                	push   $0x0
  801d4c:	e8 bc f0 ff ff       	call   800e0d <sys_page_unmap>
  801d51:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801d54:	83 ec 08             	sub    $0x8,%esp
  801d57:	ff 75 f0             	pushl  -0x10(%ebp)
  801d5a:	6a 00                	push   $0x0
  801d5c:	e8 ac f0 ff ff       	call   800e0d <sys_page_unmap>
  801d61:	83 c4 10             	add    $0x10,%esp
  801d64:	e9 1c ff ff ff       	jmp    801c85 <pipe+0x65>

00801d69 <pipeisclosed>:
{
  801d69:	55                   	push   %ebp
  801d6a:	89 e5                	mov    %esp,%ebp
  801d6c:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d6f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d72:	50                   	push   %eax
  801d73:	ff 75 08             	pushl  0x8(%ebp)
  801d76:	e8 66 f5 ff ff       	call   8012e1 <fd_lookup>
  801d7b:	83 c4 10             	add    $0x10,%esp
  801d7e:	85 c0                	test   %eax,%eax
  801d80:	78 18                	js     801d9a <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801d82:	83 ec 0c             	sub    $0xc,%esp
  801d85:	ff 75 f4             	pushl  -0xc(%ebp)
  801d88:	e8 ee f4 ff ff       	call   80127b <fd2data>
	return _pipeisclosed(fd, p);
  801d8d:	89 c2                	mov    %eax,%edx
  801d8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d92:	e8 30 fd ff ff       	call   801ac7 <_pipeisclosed>
  801d97:	83 c4 10             	add    $0x10,%esp
}
  801d9a:	c9                   	leave  
  801d9b:	c3                   	ret    

00801d9c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d9c:	55                   	push   %ebp
  801d9d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d9f:	b8 00 00 00 00       	mov    $0x0,%eax
  801da4:	5d                   	pop    %ebp
  801da5:	c3                   	ret    

00801da6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801da6:	55                   	push   %ebp
  801da7:	89 e5                	mov    %esp,%ebp
  801da9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801dac:	68 99 28 80 00       	push   $0x802899
  801db1:	ff 75 0c             	pushl  0xc(%ebp)
  801db4:	e8 d6 eb ff ff       	call   80098f <strcpy>
	return 0;
}
  801db9:	b8 00 00 00 00       	mov    $0x0,%eax
  801dbe:	c9                   	leave  
  801dbf:	c3                   	ret    

00801dc0 <devcons_write>:
{
  801dc0:	55                   	push   %ebp
  801dc1:	89 e5                	mov    %esp,%ebp
  801dc3:	57                   	push   %edi
  801dc4:	56                   	push   %esi
  801dc5:	53                   	push   %ebx
  801dc6:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801dcc:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801dd1:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801dd7:	eb 2f                	jmp    801e08 <devcons_write+0x48>
		m = n - tot;
  801dd9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ddc:	29 f3                	sub    %esi,%ebx
  801dde:	83 fb 7f             	cmp    $0x7f,%ebx
  801de1:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801de6:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801de9:	83 ec 04             	sub    $0x4,%esp
  801dec:	53                   	push   %ebx
  801ded:	89 f0                	mov    %esi,%eax
  801def:	03 45 0c             	add    0xc(%ebp),%eax
  801df2:	50                   	push   %eax
  801df3:	57                   	push   %edi
  801df4:	e8 24 ed ff ff       	call   800b1d <memmove>
		sys_cputs(buf, m);
  801df9:	83 c4 08             	add    $0x8,%esp
  801dfc:	53                   	push   %ebx
  801dfd:	57                   	push   %edi
  801dfe:	e8 c9 ee ff ff       	call   800ccc <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801e03:	01 de                	add    %ebx,%esi
  801e05:	83 c4 10             	add    $0x10,%esp
  801e08:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e0b:	72 cc                	jb     801dd9 <devcons_write+0x19>
}
  801e0d:	89 f0                	mov    %esi,%eax
  801e0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e12:	5b                   	pop    %ebx
  801e13:	5e                   	pop    %esi
  801e14:	5f                   	pop    %edi
  801e15:	5d                   	pop    %ebp
  801e16:	c3                   	ret    

00801e17 <devcons_read>:
{
  801e17:	55                   	push   %ebp
  801e18:	89 e5                	mov    %esp,%ebp
  801e1a:	83 ec 08             	sub    $0x8,%esp
  801e1d:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801e22:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e26:	75 07                	jne    801e2f <devcons_read+0x18>
}
  801e28:	c9                   	leave  
  801e29:	c3                   	ret    
		sys_yield();
  801e2a:	e8 3a ef ff ff       	call   800d69 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801e2f:	e8 b6 ee ff ff       	call   800cea <sys_cgetc>
  801e34:	85 c0                	test   %eax,%eax
  801e36:	74 f2                	je     801e2a <devcons_read+0x13>
	if (c < 0)
  801e38:	85 c0                	test   %eax,%eax
  801e3a:	78 ec                	js     801e28 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801e3c:	83 f8 04             	cmp    $0x4,%eax
  801e3f:	74 0c                	je     801e4d <devcons_read+0x36>
	*(char*)vbuf = c;
  801e41:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e44:	88 02                	mov    %al,(%edx)
	return 1;
  801e46:	b8 01 00 00 00       	mov    $0x1,%eax
  801e4b:	eb db                	jmp    801e28 <devcons_read+0x11>
		return 0;
  801e4d:	b8 00 00 00 00       	mov    $0x0,%eax
  801e52:	eb d4                	jmp    801e28 <devcons_read+0x11>

00801e54 <cputchar>:
{
  801e54:	55                   	push   %ebp
  801e55:	89 e5                	mov    %esp,%ebp
  801e57:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e5d:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801e60:	6a 01                	push   $0x1
  801e62:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e65:	50                   	push   %eax
  801e66:	e8 61 ee ff ff       	call   800ccc <sys_cputs>
}
  801e6b:	83 c4 10             	add    $0x10,%esp
  801e6e:	c9                   	leave  
  801e6f:	c3                   	ret    

00801e70 <getchar>:
{
  801e70:	55                   	push   %ebp
  801e71:	89 e5                	mov    %esp,%ebp
  801e73:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801e76:	6a 01                	push   $0x1
  801e78:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e7b:	50                   	push   %eax
  801e7c:	6a 00                	push   $0x0
  801e7e:	e8 cf f6 ff ff       	call   801552 <read>
	if (r < 0)
  801e83:	83 c4 10             	add    $0x10,%esp
  801e86:	85 c0                	test   %eax,%eax
  801e88:	78 08                	js     801e92 <getchar+0x22>
	if (r < 1)
  801e8a:	85 c0                	test   %eax,%eax
  801e8c:	7e 06                	jle    801e94 <getchar+0x24>
	return c;
  801e8e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801e92:	c9                   	leave  
  801e93:	c3                   	ret    
		return -E_EOF;
  801e94:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801e99:	eb f7                	jmp    801e92 <getchar+0x22>

00801e9b <iscons>:
{
  801e9b:	55                   	push   %ebp
  801e9c:	89 e5                	mov    %esp,%ebp
  801e9e:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ea1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ea4:	50                   	push   %eax
  801ea5:	ff 75 08             	pushl  0x8(%ebp)
  801ea8:	e8 34 f4 ff ff       	call   8012e1 <fd_lookup>
  801ead:	83 c4 10             	add    $0x10,%esp
  801eb0:	85 c0                	test   %eax,%eax
  801eb2:	78 11                	js     801ec5 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801eb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ebd:	39 10                	cmp    %edx,(%eax)
  801ebf:	0f 94 c0             	sete   %al
  801ec2:	0f b6 c0             	movzbl %al,%eax
}
  801ec5:	c9                   	leave  
  801ec6:	c3                   	ret    

00801ec7 <opencons>:
{
  801ec7:	55                   	push   %ebp
  801ec8:	89 e5                	mov    %esp,%ebp
  801eca:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801ecd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ed0:	50                   	push   %eax
  801ed1:	e8 bc f3 ff ff       	call   801292 <fd_alloc>
  801ed6:	83 c4 10             	add    $0x10,%esp
  801ed9:	85 c0                	test   %eax,%eax
  801edb:	78 3a                	js     801f17 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801edd:	83 ec 04             	sub    $0x4,%esp
  801ee0:	68 07 04 00 00       	push   $0x407
  801ee5:	ff 75 f4             	pushl  -0xc(%ebp)
  801ee8:	6a 00                	push   $0x0
  801eea:	e8 99 ee ff ff       	call   800d88 <sys_page_alloc>
  801eef:	83 c4 10             	add    $0x10,%esp
  801ef2:	85 c0                	test   %eax,%eax
  801ef4:	78 21                	js     801f17 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801ef6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801eff:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f01:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f04:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f0b:	83 ec 0c             	sub    $0xc,%esp
  801f0e:	50                   	push   %eax
  801f0f:	e8 57 f3 ff ff       	call   80126b <fd2num>
  801f14:	83 c4 10             	add    $0x10,%esp
}
  801f17:	c9                   	leave  
  801f18:	c3                   	ret    

00801f19 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f19:	55                   	push   %ebp
  801f1a:	89 e5                	mov    %esp,%ebp
  801f1c:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f1f:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f26:	74 20                	je     801f48 <set_pgfault_handler+0x2f>
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
			panic("set_pgfault_handler:sys_page_alloc failed");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f28:	8b 45 08             	mov    0x8(%ebp),%eax
  801f2b:	a3 00 60 80 00       	mov    %eax,0x806000
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801f30:	83 ec 08             	sub    $0x8,%esp
  801f33:	68 88 1f 80 00       	push   $0x801f88
  801f38:	6a 00                	push   $0x0
  801f3a:	e8 94 ef ff ff       	call   800ed3 <sys_env_set_pgfault_upcall>
  801f3f:	83 c4 10             	add    $0x10,%esp
  801f42:	85 c0                	test   %eax,%eax
  801f44:	78 2e                	js     801f74 <set_pgfault_handler+0x5b>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
}
  801f46:	c9                   	leave  
  801f47:	c3                   	ret    
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  801f48:	83 ec 04             	sub    $0x4,%esp
  801f4b:	6a 07                	push   $0x7
  801f4d:	68 00 f0 bf ee       	push   $0xeebff000
  801f52:	6a 00                	push   $0x0
  801f54:	e8 2f ee ff ff       	call   800d88 <sys_page_alloc>
  801f59:	83 c4 10             	add    $0x10,%esp
  801f5c:	85 c0                	test   %eax,%eax
  801f5e:	79 c8                	jns    801f28 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler:sys_page_alloc failed");
  801f60:	83 ec 04             	sub    $0x4,%esp
  801f63:	68 a8 28 80 00       	push   $0x8028a8
  801f68:	6a 21                	push   $0x21
  801f6a:	68 0c 29 80 00       	push   $0x80290c
  801f6f:	e8 21 e3 ff ff       	call   800295 <_panic>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  801f74:	83 ec 04             	sub    $0x4,%esp
  801f77:	68 d4 28 80 00       	push   $0x8028d4
  801f7c:	6a 27                	push   $0x27
  801f7e:	68 0c 29 80 00       	push   $0x80290c
  801f83:	e8 0d e3 ff ff       	call   800295 <_panic>

00801f88 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f88:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f89:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f8e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f90:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %eax
  801f93:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  801f97:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  801f9a:	89 44 24 30          	mov    %eax,0x30(%esp)
	movl 40(%esp), %ebx
  801f9e:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801fa2:	89 18                	mov    %ebx,(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  801fa4:	83 c4 08             	add    $0x8,%esp
	popal
  801fa7:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  801fa8:	83 c4 04             	add    $0x4,%esp
	popfl
  801fab:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801fac:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801fad:	c3                   	ret    

00801fae <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fae:	55                   	push   %ebp
  801faf:	89 e5                	mov    %esp,%ebp
  801fb1:	56                   	push   %esi
  801fb2:	53                   	push   %ebx
  801fb3:	8b 75 08             	mov    0x8(%ebp),%esi
  801fb6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fb9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  801fbc:	85 f6                	test   %esi,%esi
  801fbe:	74 06                	je     801fc6 <ipc_recv+0x18>
  801fc0:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801fc6:	85 db                	test   %ebx,%ebx
  801fc8:	74 06                	je     801fd0 <ipc_recv+0x22>
  801fca:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801fd0:	85 c0                	test   %eax,%eax
  801fd2:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801fd7:	0f 44 c2             	cmove  %edx,%eax
	int ret = sys_ipc_recv(pg);
  801fda:	83 ec 0c             	sub    $0xc,%esp
  801fdd:	50                   	push   %eax
  801fde:	e8 55 ef ff ff       	call   800f38 <sys_ipc_recv>
	if (ret) return ret;
  801fe3:	83 c4 10             	add    $0x10,%esp
  801fe6:	85 c0                	test   %eax,%eax
  801fe8:	75 24                	jne    80200e <ipc_recv+0x60>
	if (from_env_store)
  801fea:	85 f6                	test   %esi,%esi
  801fec:	74 0a                	je     801ff8 <ipc_recv+0x4a>
		*from_env_store = thisenv->env_ipc_from;
  801fee:	a1 04 40 80 00       	mov    0x804004,%eax
  801ff3:	8b 40 74             	mov    0x74(%eax),%eax
  801ff6:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801ff8:	85 db                	test   %ebx,%ebx
  801ffa:	74 0a                	je     802006 <ipc_recv+0x58>
		*perm_store = thisenv->env_ipc_perm;
  801ffc:	a1 04 40 80 00       	mov    0x804004,%eax
  802001:	8b 40 78             	mov    0x78(%eax),%eax
  802004:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  802006:	a1 04 40 80 00       	mov    0x804004,%eax
  80200b:	8b 40 70             	mov    0x70(%eax),%eax
}
  80200e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802011:	5b                   	pop    %ebx
  802012:	5e                   	pop    %esi
  802013:	5d                   	pop    %ebp
  802014:	c3                   	ret    

00802015 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802015:	55                   	push   %ebp
  802016:	89 e5                	mov    %esp,%ebp
  802018:	57                   	push   %edi
  802019:	56                   	push   %esi
  80201a:	53                   	push   %ebx
  80201b:	83 ec 0c             	sub    $0xc,%esp
  80201e:	8b 7d 08             	mov    0x8(%ebp),%edi
  802021:	8b 75 0c             	mov    0xc(%ebp),%esi
  802024:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  802027:	85 db                	test   %ebx,%ebx
  802029:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80202e:	0f 44 d8             	cmove  %eax,%ebx
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  802031:	ff 75 14             	pushl  0x14(%ebp)
  802034:	53                   	push   %ebx
  802035:	56                   	push   %esi
  802036:	57                   	push   %edi
  802037:	e8 d9 ee ff ff       	call   800f15 <sys_ipc_try_send>
  80203c:	83 c4 10             	add    $0x10,%esp
  80203f:	85 c0                	test   %eax,%eax
  802041:	74 1e                	je     802061 <ipc_send+0x4c>
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  802043:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802046:	75 07                	jne    80204f <ipc_send+0x3a>
		sys_yield();
  802048:	e8 1c ed ff ff       	call   800d69 <sys_yield>
  80204d:	eb e2                	jmp    802031 <ipc_send+0x1c>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  80204f:	50                   	push   %eax
  802050:	68 1a 29 80 00       	push   $0x80291a
  802055:	6a 36                	push   $0x36
  802057:	68 31 29 80 00       	push   $0x802931
  80205c:	e8 34 e2 ff ff       	call   800295 <_panic>
	}
}
  802061:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802064:	5b                   	pop    %ebx
  802065:	5e                   	pop    %esi
  802066:	5f                   	pop    %edi
  802067:	5d                   	pop    %ebp
  802068:	c3                   	ret    

00802069 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802069:	55                   	push   %ebp
  80206a:	89 e5                	mov    %esp,%ebp
  80206c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80206f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802074:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802077:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80207d:	8b 52 50             	mov    0x50(%edx),%edx
  802080:	39 ca                	cmp    %ecx,%edx
  802082:	74 11                	je     802095 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  802084:	83 c0 01             	add    $0x1,%eax
  802087:	3d 00 04 00 00       	cmp    $0x400,%eax
  80208c:	75 e6                	jne    802074 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  80208e:	b8 00 00 00 00       	mov    $0x0,%eax
  802093:	eb 0b                	jmp    8020a0 <ipc_find_env+0x37>
			return envs[i].env_id;
  802095:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802098:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80209d:	8b 40 48             	mov    0x48(%eax),%eax
}
  8020a0:	5d                   	pop    %ebp
  8020a1:	c3                   	ret    

008020a2 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020a2:	55                   	push   %ebp
  8020a3:	89 e5                	mov    %esp,%ebp
  8020a5:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020a8:	89 d0                	mov    %edx,%eax
  8020aa:	c1 e8 16             	shr    $0x16,%eax
  8020ad:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020b4:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  8020b9:	f6 c1 01             	test   $0x1,%cl
  8020bc:	74 1d                	je     8020db <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  8020be:	c1 ea 0c             	shr    $0xc,%edx
  8020c1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020c8:	f6 c2 01             	test   $0x1,%dl
  8020cb:	74 0e                	je     8020db <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020cd:	c1 ea 0c             	shr    $0xc,%edx
  8020d0:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020d7:	ef 
  8020d8:	0f b7 c0             	movzwl %ax,%eax
}
  8020db:	5d                   	pop    %ebp
  8020dc:	c3                   	ret    
  8020dd:	66 90                	xchg   %ax,%ax
  8020df:	90                   	nop

008020e0 <__udivdi3>:
  8020e0:	55                   	push   %ebp
  8020e1:	57                   	push   %edi
  8020e2:	56                   	push   %esi
  8020e3:	53                   	push   %ebx
  8020e4:	83 ec 1c             	sub    $0x1c,%esp
  8020e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020eb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8020ef:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020f3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8020f7:	85 d2                	test   %edx,%edx
  8020f9:	75 35                	jne    802130 <__udivdi3+0x50>
  8020fb:	39 f3                	cmp    %esi,%ebx
  8020fd:	0f 87 bd 00 00 00    	ja     8021c0 <__udivdi3+0xe0>
  802103:	85 db                	test   %ebx,%ebx
  802105:	89 d9                	mov    %ebx,%ecx
  802107:	75 0b                	jne    802114 <__udivdi3+0x34>
  802109:	b8 01 00 00 00       	mov    $0x1,%eax
  80210e:	31 d2                	xor    %edx,%edx
  802110:	f7 f3                	div    %ebx
  802112:	89 c1                	mov    %eax,%ecx
  802114:	31 d2                	xor    %edx,%edx
  802116:	89 f0                	mov    %esi,%eax
  802118:	f7 f1                	div    %ecx
  80211a:	89 c6                	mov    %eax,%esi
  80211c:	89 e8                	mov    %ebp,%eax
  80211e:	89 f7                	mov    %esi,%edi
  802120:	f7 f1                	div    %ecx
  802122:	89 fa                	mov    %edi,%edx
  802124:	83 c4 1c             	add    $0x1c,%esp
  802127:	5b                   	pop    %ebx
  802128:	5e                   	pop    %esi
  802129:	5f                   	pop    %edi
  80212a:	5d                   	pop    %ebp
  80212b:	c3                   	ret    
  80212c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802130:	39 f2                	cmp    %esi,%edx
  802132:	77 7c                	ja     8021b0 <__udivdi3+0xd0>
  802134:	0f bd fa             	bsr    %edx,%edi
  802137:	83 f7 1f             	xor    $0x1f,%edi
  80213a:	0f 84 98 00 00 00    	je     8021d8 <__udivdi3+0xf8>
  802140:	89 f9                	mov    %edi,%ecx
  802142:	b8 20 00 00 00       	mov    $0x20,%eax
  802147:	29 f8                	sub    %edi,%eax
  802149:	d3 e2                	shl    %cl,%edx
  80214b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80214f:	89 c1                	mov    %eax,%ecx
  802151:	89 da                	mov    %ebx,%edx
  802153:	d3 ea                	shr    %cl,%edx
  802155:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802159:	09 d1                	or     %edx,%ecx
  80215b:	89 f2                	mov    %esi,%edx
  80215d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802161:	89 f9                	mov    %edi,%ecx
  802163:	d3 e3                	shl    %cl,%ebx
  802165:	89 c1                	mov    %eax,%ecx
  802167:	d3 ea                	shr    %cl,%edx
  802169:	89 f9                	mov    %edi,%ecx
  80216b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80216f:	d3 e6                	shl    %cl,%esi
  802171:	89 eb                	mov    %ebp,%ebx
  802173:	89 c1                	mov    %eax,%ecx
  802175:	d3 eb                	shr    %cl,%ebx
  802177:	09 de                	or     %ebx,%esi
  802179:	89 f0                	mov    %esi,%eax
  80217b:	f7 74 24 08          	divl   0x8(%esp)
  80217f:	89 d6                	mov    %edx,%esi
  802181:	89 c3                	mov    %eax,%ebx
  802183:	f7 64 24 0c          	mull   0xc(%esp)
  802187:	39 d6                	cmp    %edx,%esi
  802189:	72 0c                	jb     802197 <__udivdi3+0xb7>
  80218b:	89 f9                	mov    %edi,%ecx
  80218d:	d3 e5                	shl    %cl,%ebp
  80218f:	39 c5                	cmp    %eax,%ebp
  802191:	73 5d                	jae    8021f0 <__udivdi3+0x110>
  802193:	39 d6                	cmp    %edx,%esi
  802195:	75 59                	jne    8021f0 <__udivdi3+0x110>
  802197:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80219a:	31 ff                	xor    %edi,%edi
  80219c:	89 fa                	mov    %edi,%edx
  80219e:	83 c4 1c             	add    $0x1c,%esp
  8021a1:	5b                   	pop    %ebx
  8021a2:	5e                   	pop    %esi
  8021a3:	5f                   	pop    %edi
  8021a4:	5d                   	pop    %ebp
  8021a5:	c3                   	ret    
  8021a6:	8d 76 00             	lea    0x0(%esi),%esi
  8021a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8021b0:	31 ff                	xor    %edi,%edi
  8021b2:	31 c0                	xor    %eax,%eax
  8021b4:	89 fa                	mov    %edi,%edx
  8021b6:	83 c4 1c             	add    $0x1c,%esp
  8021b9:	5b                   	pop    %ebx
  8021ba:	5e                   	pop    %esi
  8021bb:	5f                   	pop    %edi
  8021bc:	5d                   	pop    %ebp
  8021bd:	c3                   	ret    
  8021be:	66 90                	xchg   %ax,%ax
  8021c0:	31 ff                	xor    %edi,%edi
  8021c2:	89 e8                	mov    %ebp,%eax
  8021c4:	89 f2                	mov    %esi,%edx
  8021c6:	f7 f3                	div    %ebx
  8021c8:	89 fa                	mov    %edi,%edx
  8021ca:	83 c4 1c             	add    $0x1c,%esp
  8021cd:	5b                   	pop    %ebx
  8021ce:	5e                   	pop    %esi
  8021cf:	5f                   	pop    %edi
  8021d0:	5d                   	pop    %ebp
  8021d1:	c3                   	ret    
  8021d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021d8:	39 f2                	cmp    %esi,%edx
  8021da:	72 06                	jb     8021e2 <__udivdi3+0x102>
  8021dc:	31 c0                	xor    %eax,%eax
  8021de:	39 eb                	cmp    %ebp,%ebx
  8021e0:	77 d2                	ja     8021b4 <__udivdi3+0xd4>
  8021e2:	b8 01 00 00 00       	mov    $0x1,%eax
  8021e7:	eb cb                	jmp    8021b4 <__udivdi3+0xd4>
  8021e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021f0:	89 d8                	mov    %ebx,%eax
  8021f2:	31 ff                	xor    %edi,%edi
  8021f4:	eb be                	jmp    8021b4 <__udivdi3+0xd4>
  8021f6:	66 90                	xchg   %ax,%ax
  8021f8:	66 90                	xchg   %ax,%ax
  8021fa:	66 90                	xchg   %ax,%ax
  8021fc:	66 90                	xchg   %ax,%ax
  8021fe:	66 90                	xchg   %ax,%ax

00802200 <__umoddi3>:
  802200:	55                   	push   %ebp
  802201:	57                   	push   %edi
  802202:	56                   	push   %esi
  802203:	53                   	push   %ebx
  802204:	83 ec 1c             	sub    $0x1c,%esp
  802207:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80220b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80220f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802213:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802217:	85 ed                	test   %ebp,%ebp
  802219:	89 f0                	mov    %esi,%eax
  80221b:	89 da                	mov    %ebx,%edx
  80221d:	75 19                	jne    802238 <__umoddi3+0x38>
  80221f:	39 df                	cmp    %ebx,%edi
  802221:	0f 86 b1 00 00 00    	jbe    8022d8 <__umoddi3+0xd8>
  802227:	f7 f7                	div    %edi
  802229:	89 d0                	mov    %edx,%eax
  80222b:	31 d2                	xor    %edx,%edx
  80222d:	83 c4 1c             	add    $0x1c,%esp
  802230:	5b                   	pop    %ebx
  802231:	5e                   	pop    %esi
  802232:	5f                   	pop    %edi
  802233:	5d                   	pop    %ebp
  802234:	c3                   	ret    
  802235:	8d 76 00             	lea    0x0(%esi),%esi
  802238:	39 dd                	cmp    %ebx,%ebp
  80223a:	77 f1                	ja     80222d <__umoddi3+0x2d>
  80223c:	0f bd cd             	bsr    %ebp,%ecx
  80223f:	83 f1 1f             	xor    $0x1f,%ecx
  802242:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802246:	0f 84 b4 00 00 00    	je     802300 <__umoddi3+0x100>
  80224c:	b8 20 00 00 00       	mov    $0x20,%eax
  802251:	89 c2                	mov    %eax,%edx
  802253:	8b 44 24 04          	mov    0x4(%esp),%eax
  802257:	29 c2                	sub    %eax,%edx
  802259:	89 c1                	mov    %eax,%ecx
  80225b:	89 f8                	mov    %edi,%eax
  80225d:	d3 e5                	shl    %cl,%ebp
  80225f:	89 d1                	mov    %edx,%ecx
  802261:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802265:	d3 e8                	shr    %cl,%eax
  802267:	09 c5                	or     %eax,%ebp
  802269:	8b 44 24 04          	mov    0x4(%esp),%eax
  80226d:	89 c1                	mov    %eax,%ecx
  80226f:	d3 e7                	shl    %cl,%edi
  802271:	89 d1                	mov    %edx,%ecx
  802273:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802277:	89 df                	mov    %ebx,%edi
  802279:	d3 ef                	shr    %cl,%edi
  80227b:	89 c1                	mov    %eax,%ecx
  80227d:	89 f0                	mov    %esi,%eax
  80227f:	d3 e3                	shl    %cl,%ebx
  802281:	89 d1                	mov    %edx,%ecx
  802283:	89 fa                	mov    %edi,%edx
  802285:	d3 e8                	shr    %cl,%eax
  802287:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80228c:	09 d8                	or     %ebx,%eax
  80228e:	f7 f5                	div    %ebp
  802290:	d3 e6                	shl    %cl,%esi
  802292:	89 d1                	mov    %edx,%ecx
  802294:	f7 64 24 08          	mull   0x8(%esp)
  802298:	39 d1                	cmp    %edx,%ecx
  80229a:	89 c3                	mov    %eax,%ebx
  80229c:	89 d7                	mov    %edx,%edi
  80229e:	72 06                	jb     8022a6 <__umoddi3+0xa6>
  8022a0:	75 0e                	jne    8022b0 <__umoddi3+0xb0>
  8022a2:	39 c6                	cmp    %eax,%esi
  8022a4:	73 0a                	jae    8022b0 <__umoddi3+0xb0>
  8022a6:	2b 44 24 08          	sub    0x8(%esp),%eax
  8022aa:	19 ea                	sbb    %ebp,%edx
  8022ac:	89 d7                	mov    %edx,%edi
  8022ae:	89 c3                	mov    %eax,%ebx
  8022b0:	89 ca                	mov    %ecx,%edx
  8022b2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8022b7:	29 de                	sub    %ebx,%esi
  8022b9:	19 fa                	sbb    %edi,%edx
  8022bb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  8022bf:	89 d0                	mov    %edx,%eax
  8022c1:	d3 e0                	shl    %cl,%eax
  8022c3:	89 d9                	mov    %ebx,%ecx
  8022c5:	d3 ee                	shr    %cl,%esi
  8022c7:	d3 ea                	shr    %cl,%edx
  8022c9:	09 f0                	or     %esi,%eax
  8022cb:	83 c4 1c             	add    $0x1c,%esp
  8022ce:	5b                   	pop    %ebx
  8022cf:	5e                   	pop    %esi
  8022d0:	5f                   	pop    %edi
  8022d1:	5d                   	pop    %ebp
  8022d2:	c3                   	ret    
  8022d3:	90                   	nop
  8022d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022d8:	85 ff                	test   %edi,%edi
  8022da:	89 f9                	mov    %edi,%ecx
  8022dc:	75 0b                	jne    8022e9 <__umoddi3+0xe9>
  8022de:	b8 01 00 00 00       	mov    $0x1,%eax
  8022e3:	31 d2                	xor    %edx,%edx
  8022e5:	f7 f7                	div    %edi
  8022e7:	89 c1                	mov    %eax,%ecx
  8022e9:	89 d8                	mov    %ebx,%eax
  8022eb:	31 d2                	xor    %edx,%edx
  8022ed:	f7 f1                	div    %ecx
  8022ef:	89 f0                	mov    %esi,%eax
  8022f1:	f7 f1                	div    %ecx
  8022f3:	e9 31 ff ff ff       	jmp    802229 <__umoddi3+0x29>
  8022f8:	90                   	nop
  8022f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802300:	39 dd                	cmp    %ebx,%ebp
  802302:	72 08                	jb     80230c <__umoddi3+0x10c>
  802304:	39 f7                	cmp    %esi,%edi
  802306:	0f 87 21 ff ff ff    	ja     80222d <__umoddi3+0x2d>
  80230c:	89 da                	mov    %ebx,%edx
  80230e:	89 f0                	mov    %esi,%eax
  802310:	29 f8                	sub    %edi,%eax
  802312:	19 ea                	sbb    %ebp,%edx
  802314:	e9 14 ff ff ff       	jmp    80222d <__umoddi3+0x2d>
