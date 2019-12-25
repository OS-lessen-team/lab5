
obj/user/testpipe.debug：     文件格式 elf32-i386


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
  80002c:	e8 a5 02 00 00       	call   8002d6 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char *msg = "Now is the time for all good men to come to the aid of their party.";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 7c             	sub    $0x7c,%esp
	char buf[100];
	int i, pid, p[2];

	binaryname = "pipereadeof";
  80003b:	c7 05 04 30 80 00 20 	movl   $0x802420,0x803004
  800042:	24 80 00 

	if ((i = pipe(p)) < 0)
  800045:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800048:	50                   	push   %eax
  800049:	e8 73 1c 00 00       	call   801cc1 <pipe>
  80004e:	89 c6                	mov    %eax,%esi
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	0f 88 1f 01 00 00    	js     80017a <umain+0x147>
		panic("pipe: %e", i);

	if ((pid = fork()) < 0)
  80005b:	e8 bc 10 00 00       	call   80111c <fork>
  800060:	89 c3                	mov    %eax,%ebx
  800062:	85 c0                	test   %eax,%eax
  800064:	0f 88 22 01 00 00    	js     80018c <umain+0x159>
		panic("fork: %e", i);

	if (pid == 0) {
  80006a:	85 c0                	test   %eax,%eax
  80006c:	0f 85 58 01 00 00    	jne    8001ca <umain+0x197>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[1]);
  800072:	a1 04 40 80 00       	mov    0x804004,%eax
  800077:	8b 40 48             	mov    0x48(%eax),%eax
  80007a:	83 ec 04             	sub    $0x4,%esp
  80007d:	ff 75 90             	pushl  -0x70(%ebp)
  800080:	50                   	push   %eax
  800081:	68 45 24 80 00       	push   $0x802445
  800086:	e8 86 03 00 00       	call   800411 <cprintf>
		close(p[1]);
  80008b:	83 c4 04             	add    $0x4,%esp
  80008e:	ff 75 90             	pushl  -0x70(%ebp)
  800091:	e8 21 14 00 00       	call   8014b7 <close>
		cprintf("[%08x] pipereadeof readn %d\n", thisenv->env_id, p[0]);
  800096:	a1 04 40 80 00       	mov    0x804004,%eax
  80009b:	8b 40 48             	mov    0x48(%eax),%eax
  80009e:	83 c4 0c             	add    $0xc,%esp
  8000a1:	ff 75 8c             	pushl  -0x74(%ebp)
  8000a4:	50                   	push   %eax
  8000a5:	68 62 24 80 00       	push   $0x802462
  8000aa:	e8 62 03 00 00       	call   800411 <cprintf>
		i = readn(p[0], buf, sizeof buf-1);
  8000af:	83 c4 0c             	add    $0xc,%esp
  8000b2:	6a 63                	push   $0x63
  8000b4:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000b7:	50                   	push   %eax
  8000b8:	ff 75 8c             	pushl  -0x74(%ebp)
  8000bb:	e8 ba 15 00 00       	call   80167a <readn>
  8000c0:	89 c6                	mov    %eax,%esi
		if (i < 0)
  8000c2:	83 c4 10             	add    $0x10,%esp
  8000c5:	85 c0                	test   %eax,%eax
  8000c7:	0f 88 d1 00 00 00    	js     80019e <umain+0x16b>
			panic("read: %e", i);
		buf[i] = 0;
  8000cd:	c6 44 05 94 00       	movb   $0x0,-0x6c(%ebp,%eax,1)
		if (strcmp(buf, msg) == 0)
  8000d2:	83 ec 08             	sub    $0x8,%esp
  8000d5:	ff 35 00 30 80 00    	pushl  0x803000
  8000db:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000de:	50                   	push   %eax
  8000df:	e8 f2 09 00 00       	call   800ad6 <strcmp>
  8000e4:	83 c4 10             	add    $0x10,%esp
  8000e7:	85 c0                	test   %eax,%eax
  8000e9:	0f 85 c1 00 00 00    	jne    8001b0 <umain+0x17d>
			cprintf("\npipe read closed properly\n");
  8000ef:	83 ec 0c             	sub    $0xc,%esp
  8000f2:	68 88 24 80 00       	push   $0x802488
  8000f7:	e8 15 03 00 00       	call   800411 <cprintf>
  8000fc:	83 c4 10             	add    $0x10,%esp
		else
			cprintf("\ngot %d bytes: %s\n", i, buf);
		exit();
  8000ff:	e8 18 02 00 00       	call   80031c <exit>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
			panic("write: %e", i);
		close(p[1]);
	}
	wait(pid);
  800104:	83 ec 0c             	sub    $0xc,%esp
  800107:	53                   	push   %ebx
  800108:	e8 30 1d 00 00       	call   801e3d <wait>

	binaryname = "pipewriteeof";
  80010d:	c7 05 04 30 80 00 de 	movl   $0x8024de,0x803004
  800114:	24 80 00 
	if ((i = pipe(p)) < 0)
  800117:	8d 45 8c             	lea    -0x74(%ebp),%eax
  80011a:	89 04 24             	mov    %eax,(%esp)
  80011d:	e8 9f 1b 00 00       	call   801cc1 <pipe>
  800122:	89 c6                	mov    %eax,%esi
  800124:	83 c4 10             	add    $0x10,%esp
  800127:	85 c0                	test   %eax,%eax
  800129:	0f 88 34 01 00 00    	js     800263 <umain+0x230>
		panic("pipe: %e", i);

	if ((pid = fork()) < 0)
  80012f:	e8 e8 0f 00 00       	call   80111c <fork>
  800134:	89 c3                	mov    %eax,%ebx
  800136:	85 c0                	test   %eax,%eax
  800138:	0f 88 37 01 00 00    	js     800275 <umain+0x242>
		panic("fork: %e", i);

	if (pid == 0) {
  80013e:	85 c0                	test   %eax,%eax
  800140:	0f 84 41 01 00 00    	je     800287 <umain+0x254>
				break;
		}
		cprintf("\npipe write closed properly\n");
		exit();
	}
	close(p[0]);
  800146:	83 ec 0c             	sub    $0xc,%esp
  800149:	ff 75 8c             	pushl  -0x74(%ebp)
  80014c:	e8 66 13 00 00       	call   8014b7 <close>
	close(p[1]);
  800151:	83 c4 04             	add    $0x4,%esp
  800154:	ff 75 90             	pushl  -0x70(%ebp)
  800157:	e8 5b 13 00 00       	call   8014b7 <close>
	wait(pid);
  80015c:	89 1c 24             	mov    %ebx,(%esp)
  80015f:	e8 d9 1c 00 00       	call   801e3d <wait>

	cprintf("pipe tests passed\n");
  800164:	c7 04 24 0c 25 80 00 	movl   $0x80250c,(%esp)
  80016b:	e8 a1 02 00 00       	call   800411 <cprintf>
}
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800176:	5b                   	pop    %ebx
  800177:	5e                   	pop    %esi
  800178:	5d                   	pop    %ebp
  800179:	c3                   	ret    
		panic("pipe: %e", i);
  80017a:	50                   	push   %eax
  80017b:	68 2c 24 80 00       	push   $0x80242c
  800180:	6a 0e                	push   $0xe
  800182:	68 35 24 80 00       	push   $0x802435
  800187:	e8 aa 01 00 00       	call   800336 <_panic>
		panic("fork: %e", i);
  80018c:	56                   	push   %esi
  80018d:	68 19 29 80 00       	push   $0x802919
  800192:	6a 11                	push   $0x11
  800194:	68 35 24 80 00       	push   $0x802435
  800199:	e8 98 01 00 00       	call   800336 <_panic>
			panic("read: %e", i);
  80019e:	50                   	push   %eax
  80019f:	68 7f 24 80 00       	push   $0x80247f
  8001a4:	6a 19                	push   $0x19
  8001a6:	68 35 24 80 00       	push   $0x802435
  8001ab:	e8 86 01 00 00       	call   800336 <_panic>
			cprintf("\ngot %d bytes: %s\n", i, buf);
  8001b0:	83 ec 04             	sub    $0x4,%esp
  8001b3:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8001b6:	50                   	push   %eax
  8001b7:	56                   	push   %esi
  8001b8:	68 a4 24 80 00       	push   $0x8024a4
  8001bd:	e8 4f 02 00 00       	call   800411 <cprintf>
  8001c2:	83 c4 10             	add    $0x10,%esp
  8001c5:	e9 35 ff ff ff       	jmp    8000ff <umain+0xcc>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[0]);
  8001ca:	a1 04 40 80 00       	mov    0x804004,%eax
  8001cf:	8b 40 48             	mov    0x48(%eax),%eax
  8001d2:	83 ec 04             	sub    $0x4,%esp
  8001d5:	ff 75 8c             	pushl  -0x74(%ebp)
  8001d8:	50                   	push   %eax
  8001d9:	68 45 24 80 00       	push   $0x802445
  8001de:	e8 2e 02 00 00       	call   800411 <cprintf>
		close(p[0]);
  8001e3:	83 c4 04             	add    $0x4,%esp
  8001e6:	ff 75 8c             	pushl  -0x74(%ebp)
  8001e9:	e8 c9 12 00 00       	call   8014b7 <close>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
  8001ee:	a1 04 40 80 00       	mov    0x804004,%eax
  8001f3:	8b 40 48             	mov    0x48(%eax),%eax
  8001f6:	83 c4 0c             	add    $0xc,%esp
  8001f9:	ff 75 90             	pushl  -0x70(%ebp)
  8001fc:	50                   	push   %eax
  8001fd:	68 b7 24 80 00       	push   $0x8024b7
  800202:	e8 0a 02 00 00       	call   800411 <cprintf>
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
  800207:	83 c4 04             	add    $0x4,%esp
  80020a:	ff 35 00 30 80 00    	pushl  0x803000
  800210:	e8 e4 07 00 00       	call   8009f9 <strlen>
  800215:	83 c4 0c             	add    $0xc,%esp
  800218:	50                   	push   %eax
  800219:	ff 35 00 30 80 00    	pushl  0x803000
  80021f:	ff 75 90             	pushl  -0x70(%ebp)
  800222:	e8 9a 14 00 00       	call   8016c1 <write>
  800227:	89 c6                	mov    %eax,%esi
  800229:	83 c4 04             	add    $0x4,%esp
  80022c:	ff 35 00 30 80 00    	pushl  0x803000
  800232:	e8 c2 07 00 00       	call   8009f9 <strlen>
  800237:	83 c4 10             	add    $0x10,%esp
  80023a:	39 f0                	cmp    %esi,%eax
  80023c:	75 13                	jne    800251 <umain+0x21e>
		close(p[1]);
  80023e:	83 ec 0c             	sub    $0xc,%esp
  800241:	ff 75 90             	pushl  -0x70(%ebp)
  800244:	e8 6e 12 00 00       	call   8014b7 <close>
  800249:	83 c4 10             	add    $0x10,%esp
  80024c:	e9 b3 fe ff ff       	jmp    800104 <umain+0xd1>
			panic("write: %e", i);
  800251:	56                   	push   %esi
  800252:	68 d4 24 80 00       	push   $0x8024d4
  800257:	6a 25                	push   $0x25
  800259:	68 35 24 80 00       	push   $0x802435
  80025e:	e8 d3 00 00 00       	call   800336 <_panic>
		panic("pipe: %e", i);
  800263:	50                   	push   %eax
  800264:	68 2c 24 80 00       	push   $0x80242c
  800269:	6a 2c                	push   $0x2c
  80026b:	68 35 24 80 00       	push   $0x802435
  800270:	e8 c1 00 00 00       	call   800336 <_panic>
		panic("fork: %e", i);
  800275:	56                   	push   %esi
  800276:	68 19 29 80 00       	push   $0x802919
  80027b:	6a 2f                	push   $0x2f
  80027d:	68 35 24 80 00       	push   $0x802435
  800282:	e8 af 00 00 00       	call   800336 <_panic>
		close(p[0]);
  800287:	83 ec 0c             	sub    $0xc,%esp
  80028a:	ff 75 8c             	pushl  -0x74(%ebp)
  80028d:	e8 25 12 00 00       	call   8014b7 <close>
  800292:	83 c4 10             	add    $0x10,%esp
			cprintf(".");
  800295:	83 ec 0c             	sub    $0xc,%esp
  800298:	68 eb 24 80 00       	push   $0x8024eb
  80029d:	e8 6f 01 00 00       	call   800411 <cprintf>
			if (write(p[1], "x", 1) != 1)
  8002a2:	83 c4 0c             	add    $0xc,%esp
  8002a5:	6a 01                	push   $0x1
  8002a7:	68 ed 24 80 00       	push   $0x8024ed
  8002ac:	ff 75 90             	pushl  -0x70(%ebp)
  8002af:	e8 0d 14 00 00       	call   8016c1 <write>
  8002b4:	83 c4 10             	add    $0x10,%esp
  8002b7:	83 f8 01             	cmp    $0x1,%eax
  8002ba:	74 d9                	je     800295 <umain+0x262>
		cprintf("\npipe write closed properly\n");
  8002bc:	83 ec 0c             	sub    $0xc,%esp
  8002bf:	68 ef 24 80 00       	push   $0x8024ef
  8002c4:	e8 48 01 00 00       	call   800411 <cprintf>
		exit();
  8002c9:	e8 4e 00 00 00       	call   80031c <exit>
  8002ce:	83 c4 10             	add    $0x10,%esp
  8002d1:	e9 70 fe ff ff       	jmp    800146 <umain+0x113>

008002d6 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
  8002d9:	56                   	push   %esi
  8002da:	53                   	push   %ebx
  8002db:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002de:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  8002e1:	e8 05 0b 00 00       	call   800deb <sys_getenvid>
	thisenv = envs + ENVX(envid); 
  8002e6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002eb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8002ee:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002f3:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002f8:	85 db                	test   %ebx,%ebx
  8002fa:	7e 07                	jle    800303 <libmain+0x2d>
		binaryname = argv[0];
  8002fc:	8b 06                	mov    (%esi),%eax
  8002fe:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  800303:	83 ec 08             	sub    $0x8,%esp
  800306:	56                   	push   %esi
  800307:	53                   	push   %ebx
  800308:	e8 26 fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80030d:	e8 0a 00 00 00       	call   80031c <exit>
}
  800312:	83 c4 10             	add    $0x10,%esp
  800315:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800318:	5b                   	pop    %ebx
  800319:	5e                   	pop    %esi
  80031a:	5d                   	pop    %ebp
  80031b:	c3                   	ret    

0080031c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
  80031f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800322:	e8 bb 11 00 00       	call   8014e2 <close_all>
	sys_env_destroy(0);
  800327:	83 ec 0c             	sub    $0xc,%esp
  80032a:	6a 00                	push   $0x0
  80032c:	e8 79 0a 00 00       	call   800daa <sys_env_destroy>
}
  800331:	83 c4 10             	add    $0x10,%esp
  800334:	c9                   	leave  
  800335:	c3                   	ret    

00800336 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800336:	55                   	push   %ebp
  800337:	89 e5                	mov    %esp,%ebp
  800339:	56                   	push   %esi
  80033a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80033b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80033e:	8b 35 04 30 80 00    	mov    0x803004,%esi
  800344:	e8 a2 0a 00 00       	call   800deb <sys_getenvid>
  800349:	83 ec 0c             	sub    $0xc,%esp
  80034c:	ff 75 0c             	pushl  0xc(%ebp)
  80034f:	ff 75 08             	pushl  0x8(%ebp)
  800352:	56                   	push   %esi
  800353:	50                   	push   %eax
  800354:	68 70 25 80 00       	push   $0x802570
  800359:	e8 b3 00 00 00       	call   800411 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80035e:	83 c4 18             	add    $0x18,%esp
  800361:	53                   	push   %ebx
  800362:	ff 75 10             	pushl  0x10(%ebp)
  800365:	e8 56 00 00 00       	call   8003c0 <vcprintf>
	cprintf("\n");
  80036a:	c7 04 24 60 24 80 00 	movl   $0x802460,(%esp)
  800371:	e8 9b 00 00 00       	call   800411 <cprintf>
  800376:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800379:	cc                   	int3   
  80037a:	eb fd                	jmp    800379 <_panic+0x43>

0080037c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80037c:	55                   	push   %ebp
  80037d:	89 e5                	mov    %esp,%ebp
  80037f:	53                   	push   %ebx
  800380:	83 ec 04             	sub    $0x4,%esp
  800383:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800386:	8b 13                	mov    (%ebx),%edx
  800388:	8d 42 01             	lea    0x1(%edx),%eax
  80038b:	89 03                	mov    %eax,(%ebx)
  80038d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800390:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800394:	3d ff 00 00 00       	cmp    $0xff,%eax
  800399:	74 09                	je     8003a4 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80039b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80039f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003a2:	c9                   	leave  
  8003a3:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003a4:	83 ec 08             	sub    $0x8,%esp
  8003a7:	68 ff 00 00 00       	push   $0xff
  8003ac:	8d 43 08             	lea    0x8(%ebx),%eax
  8003af:	50                   	push   %eax
  8003b0:	e8 b8 09 00 00       	call   800d6d <sys_cputs>
		b->idx = 0;
  8003b5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003bb:	83 c4 10             	add    $0x10,%esp
  8003be:	eb db                	jmp    80039b <putch+0x1f>

008003c0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003c0:	55                   	push   %ebp
  8003c1:	89 e5                	mov    %esp,%ebp
  8003c3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003c9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003d0:	00 00 00 
	b.cnt = 0;
  8003d3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003da:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003dd:	ff 75 0c             	pushl  0xc(%ebp)
  8003e0:	ff 75 08             	pushl  0x8(%ebp)
  8003e3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003e9:	50                   	push   %eax
  8003ea:	68 7c 03 80 00       	push   $0x80037c
  8003ef:	e8 1a 01 00 00       	call   80050e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003f4:	83 c4 08             	add    $0x8,%esp
  8003f7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003fd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800403:	50                   	push   %eax
  800404:	e8 64 09 00 00       	call   800d6d <sys_cputs>

	return b.cnt;
}
  800409:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80040f:	c9                   	leave  
  800410:	c3                   	ret    

00800411 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800411:	55                   	push   %ebp
  800412:	89 e5                	mov    %esp,%ebp
  800414:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800417:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80041a:	50                   	push   %eax
  80041b:	ff 75 08             	pushl  0x8(%ebp)
  80041e:	e8 9d ff ff ff       	call   8003c0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800423:	c9                   	leave  
  800424:	c3                   	ret    

00800425 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800425:	55                   	push   %ebp
  800426:	89 e5                	mov    %esp,%ebp
  800428:	57                   	push   %edi
  800429:	56                   	push   %esi
  80042a:	53                   	push   %ebx
  80042b:	83 ec 1c             	sub    $0x1c,%esp
  80042e:	89 c7                	mov    %eax,%edi
  800430:	89 d6                	mov    %edx,%esi
  800432:	8b 45 08             	mov    0x8(%ebp),%eax
  800435:	8b 55 0c             	mov    0xc(%ebp),%edx
  800438:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80043b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80043e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800441:	bb 00 00 00 00       	mov    $0x0,%ebx
  800446:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800449:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80044c:	39 d3                	cmp    %edx,%ebx
  80044e:	72 05                	jb     800455 <printnum+0x30>
  800450:	39 45 10             	cmp    %eax,0x10(%ebp)
  800453:	77 7a                	ja     8004cf <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800455:	83 ec 0c             	sub    $0xc,%esp
  800458:	ff 75 18             	pushl  0x18(%ebp)
  80045b:	8b 45 14             	mov    0x14(%ebp),%eax
  80045e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800461:	53                   	push   %ebx
  800462:	ff 75 10             	pushl  0x10(%ebp)
  800465:	83 ec 08             	sub    $0x8,%esp
  800468:	ff 75 e4             	pushl  -0x1c(%ebp)
  80046b:	ff 75 e0             	pushl  -0x20(%ebp)
  80046e:	ff 75 dc             	pushl  -0x24(%ebp)
  800471:	ff 75 d8             	pushl  -0x28(%ebp)
  800474:	e8 57 1d 00 00       	call   8021d0 <__udivdi3>
  800479:	83 c4 18             	add    $0x18,%esp
  80047c:	52                   	push   %edx
  80047d:	50                   	push   %eax
  80047e:	89 f2                	mov    %esi,%edx
  800480:	89 f8                	mov    %edi,%eax
  800482:	e8 9e ff ff ff       	call   800425 <printnum>
  800487:	83 c4 20             	add    $0x20,%esp
  80048a:	eb 13                	jmp    80049f <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80048c:	83 ec 08             	sub    $0x8,%esp
  80048f:	56                   	push   %esi
  800490:	ff 75 18             	pushl  0x18(%ebp)
  800493:	ff d7                	call   *%edi
  800495:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800498:	83 eb 01             	sub    $0x1,%ebx
  80049b:	85 db                	test   %ebx,%ebx
  80049d:	7f ed                	jg     80048c <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80049f:	83 ec 08             	sub    $0x8,%esp
  8004a2:	56                   	push   %esi
  8004a3:	83 ec 04             	sub    $0x4,%esp
  8004a6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004a9:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ac:	ff 75 dc             	pushl  -0x24(%ebp)
  8004af:	ff 75 d8             	pushl  -0x28(%ebp)
  8004b2:	e8 39 1e 00 00       	call   8022f0 <__umoddi3>
  8004b7:	83 c4 14             	add    $0x14,%esp
  8004ba:	0f be 80 93 25 80 00 	movsbl 0x802593(%eax),%eax
  8004c1:	50                   	push   %eax
  8004c2:	ff d7                	call   *%edi
}
  8004c4:	83 c4 10             	add    $0x10,%esp
  8004c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004ca:	5b                   	pop    %ebx
  8004cb:	5e                   	pop    %esi
  8004cc:	5f                   	pop    %edi
  8004cd:	5d                   	pop    %ebp
  8004ce:	c3                   	ret    
  8004cf:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004d2:	eb c4                	jmp    800498 <printnum+0x73>

008004d4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004d4:	55                   	push   %ebp
  8004d5:	89 e5                	mov    %esp,%ebp
  8004d7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004da:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004de:	8b 10                	mov    (%eax),%edx
  8004e0:	3b 50 04             	cmp    0x4(%eax),%edx
  8004e3:	73 0a                	jae    8004ef <sprintputch+0x1b>
		*b->buf++ = ch;
  8004e5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004e8:	89 08                	mov    %ecx,(%eax)
  8004ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ed:	88 02                	mov    %al,(%edx)
}
  8004ef:	5d                   	pop    %ebp
  8004f0:	c3                   	ret    

008004f1 <printfmt>:
{
  8004f1:	55                   	push   %ebp
  8004f2:	89 e5                	mov    %esp,%ebp
  8004f4:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004f7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004fa:	50                   	push   %eax
  8004fb:	ff 75 10             	pushl  0x10(%ebp)
  8004fe:	ff 75 0c             	pushl  0xc(%ebp)
  800501:	ff 75 08             	pushl  0x8(%ebp)
  800504:	e8 05 00 00 00       	call   80050e <vprintfmt>
}
  800509:	83 c4 10             	add    $0x10,%esp
  80050c:	c9                   	leave  
  80050d:	c3                   	ret    

0080050e <vprintfmt>:
{
  80050e:	55                   	push   %ebp
  80050f:	89 e5                	mov    %esp,%ebp
  800511:	57                   	push   %edi
  800512:	56                   	push   %esi
  800513:	53                   	push   %ebx
  800514:	83 ec 2c             	sub    $0x2c,%esp
  800517:	8b 75 08             	mov    0x8(%ebp),%esi
  80051a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80051d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800520:	e9 c1 03 00 00       	jmp    8008e6 <vprintfmt+0x3d8>
		padc = ' ';
  800525:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800529:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800530:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800537:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80053e:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800543:	8d 47 01             	lea    0x1(%edi),%eax
  800546:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800549:	0f b6 17             	movzbl (%edi),%edx
  80054c:	8d 42 dd             	lea    -0x23(%edx),%eax
  80054f:	3c 55                	cmp    $0x55,%al
  800551:	0f 87 12 04 00 00    	ja     800969 <vprintfmt+0x45b>
  800557:	0f b6 c0             	movzbl %al,%eax
  80055a:	ff 24 85 e0 26 80 00 	jmp    *0x8026e0(,%eax,4)
  800561:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800564:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800568:	eb d9                	jmp    800543 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80056a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80056d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800571:	eb d0                	jmp    800543 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800573:	0f b6 d2             	movzbl %dl,%edx
  800576:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800579:	b8 00 00 00 00       	mov    $0x0,%eax
  80057e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800581:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800584:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800588:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80058b:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80058e:	83 f9 09             	cmp    $0x9,%ecx
  800591:	77 55                	ja     8005e8 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800593:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800596:	eb e9                	jmp    800581 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  800598:	8b 45 14             	mov    0x14(%ebp),%eax
  80059b:	8b 00                	mov    (%eax),%eax
  80059d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a3:	8d 40 04             	lea    0x4(%eax),%eax
  8005a6:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8005ac:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005b0:	79 91                	jns    800543 <vprintfmt+0x35>
				width = precision, precision = -1;
  8005b2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005b5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005b8:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005bf:	eb 82                	jmp    800543 <vprintfmt+0x35>
  8005c1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005c4:	85 c0                	test   %eax,%eax
  8005c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8005cb:	0f 49 d0             	cmovns %eax,%edx
  8005ce:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005d4:	e9 6a ff ff ff       	jmp    800543 <vprintfmt+0x35>
  8005d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005dc:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005e3:	e9 5b ff ff ff       	jmp    800543 <vprintfmt+0x35>
  8005e8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005eb:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005ee:	eb bc                	jmp    8005ac <vprintfmt+0x9e>
			lflag++;
  8005f0:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8005f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005f6:	e9 48 ff ff ff       	jmp    800543 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8005fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fe:	8d 78 04             	lea    0x4(%eax),%edi
  800601:	83 ec 08             	sub    $0x8,%esp
  800604:	53                   	push   %ebx
  800605:	ff 30                	pushl  (%eax)
  800607:	ff d6                	call   *%esi
			break;
  800609:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80060c:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80060f:	e9 cf 02 00 00       	jmp    8008e3 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  800614:	8b 45 14             	mov    0x14(%ebp),%eax
  800617:	8d 78 04             	lea    0x4(%eax),%edi
  80061a:	8b 00                	mov    (%eax),%eax
  80061c:	99                   	cltd   
  80061d:	31 d0                	xor    %edx,%eax
  80061f:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800621:	83 f8 0f             	cmp    $0xf,%eax
  800624:	7f 23                	jg     800649 <vprintfmt+0x13b>
  800626:	8b 14 85 40 28 80 00 	mov    0x802840(,%eax,4),%edx
  80062d:	85 d2                	test   %edx,%edx
  80062f:	74 18                	je     800649 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800631:	52                   	push   %edx
  800632:	68 05 2a 80 00       	push   $0x802a05
  800637:	53                   	push   %ebx
  800638:	56                   	push   %esi
  800639:	e8 b3 fe ff ff       	call   8004f1 <printfmt>
  80063e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800641:	89 7d 14             	mov    %edi,0x14(%ebp)
  800644:	e9 9a 02 00 00       	jmp    8008e3 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  800649:	50                   	push   %eax
  80064a:	68 ab 25 80 00       	push   $0x8025ab
  80064f:	53                   	push   %ebx
  800650:	56                   	push   %esi
  800651:	e8 9b fe ff ff       	call   8004f1 <printfmt>
  800656:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800659:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80065c:	e9 82 02 00 00       	jmp    8008e3 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  800661:	8b 45 14             	mov    0x14(%ebp),%eax
  800664:	83 c0 04             	add    $0x4,%eax
  800667:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80066a:	8b 45 14             	mov    0x14(%ebp),%eax
  80066d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80066f:	85 ff                	test   %edi,%edi
  800671:	b8 a4 25 80 00       	mov    $0x8025a4,%eax
  800676:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800679:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80067d:	0f 8e bd 00 00 00    	jle    800740 <vprintfmt+0x232>
  800683:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800687:	75 0e                	jne    800697 <vprintfmt+0x189>
  800689:	89 75 08             	mov    %esi,0x8(%ebp)
  80068c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80068f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800692:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800695:	eb 6d                	jmp    800704 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  800697:	83 ec 08             	sub    $0x8,%esp
  80069a:	ff 75 d0             	pushl  -0x30(%ebp)
  80069d:	57                   	push   %edi
  80069e:	e8 6e 03 00 00       	call   800a11 <strnlen>
  8006a3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006a6:	29 c1                	sub    %eax,%ecx
  8006a8:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8006ab:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006ae:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006b2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006b5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006b8:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ba:	eb 0f                	jmp    8006cb <vprintfmt+0x1bd>
					putch(padc, putdat);
  8006bc:	83 ec 08             	sub    $0x8,%esp
  8006bf:	53                   	push   %ebx
  8006c0:	ff 75 e0             	pushl  -0x20(%ebp)
  8006c3:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c5:	83 ef 01             	sub    $0x1,%edi
  8006c8:	83 c4 10             	add    $0x10,%esp
  8006cb:	85 ff                	test   %edi,%edi
  8006cd:	7f ed                	jg     8006bc <vprintfmt+0x1ae>
  8006cf:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006d2:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006d5:	85 c9                	test   %ecx,%ecx
  8006d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8006dc:	0f 49 c1             	cmovns %ecx,%eax
  8006df:	29 c1                	sub    %eax,%ecx
  8006e1:	89 75 08             	mov    %esi,0x8(%ebp)
  8006e4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006e7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006ea:	89 cb                	mov    %ecx,%ebx
  8006ec:	eb 16                	jmp    800704 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8006ee:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006f2:	75 31                	jne    800725 <vprintfmt+0x217>
					putch(ch, putdat);
  8006f4:	83 ec 08             	sub    $0x8,%esp
  8006f7:	ff 75 0c             	pushl  0xc(%ebp)
  8006fa:	50                   	push   %eax
  8006fb:	ff 55 08             	call   *0x8(%ebp)
  8006fe:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800701:	83 eb 01             	sub    $0x1,%ebx
  800704:	83 c7 01             	add    $0x1,%edi
  800707:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  80070b:	0f be c2             	movsbl %dl,%eax
  80070e:	85 c0                	test   %eax,%eax
  800710:	74 59                	je     80076b <vprintfmt+0x25d>
  800712:	85 f6                	test   %esi,%esi
  800714:	78 d8                	js     8006ee <vprintfmt+0x1e0>
  800716:	83 ee 01             	sub    $0x1,%esi
  800719:	79 d3                	jns    8006ee <vprintfmt+0x1e0>
  80071b:	89 df                	mov    %ebx,%edi
  80071d:	8b 75 08             	mov    0x8(%ebp),%esi
  800720:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800723:	eb 37                	jmp    80075c <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  800725:	0f be d2             	movsbl %dl,%edx
  800728:	83 ea 20             	sub    $0x20,%edx
  80072b:	83 fa 5e             	cmp    $0x5e,%edx
  80072e:	76 c4                	jbe    8006f4 <vprintfmt+0x1e6>
					putch('?', putdat);
  800730:	83 ec 08             	sub    $0x8,%esp
  800733:	ff 75 0c             	pushl  0xc(%ebp)
  800736:	6a 3f                	push   $0x3f
  800738:	ff 55 08             	call   *0x8(%ebp)
  80073b:	83 c4 10             	add    $0x10,%esp
  80073e:	eb c1                	jmp    800701 <vprintfmt+0x1f3>
  800740:	89 75 08             	mov    %esi,0x8(%ebp)
  800743:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800746:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800749:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80074c:	eb b6                	jmp    800704 <vprintfmt+0x1f6>
				putch(' ', putdat);
  80074e:	83 ec 08             	sub    $0x8,%esp
  800751:	53                   	push   %ebx
  800752:	6a 20                	push   $0x20
  800754:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800756:	83 ef 01             	sub    $0x1,%edi
  800759:	83 c4 10             	add    $0x10,%esp
  80075c:	85 ff                	test   %edi,%edi
  80075e:	7f ee                	jg     80074e <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800760:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800763:	89 45 14             	mov    %eax,0x14(%ebp)
  800766:	e9 78 01 00 00       	jmp    8008e3 <vprintfmt+0x3d5>
  80076b:	89 df                	mov    %ebx,%edi
  80076d:	8b 75 08             	mov    0x8(%ebp),%esi
  800770:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800773:	eb e7                	jmp    80075c <vprintfmt+0x24e>
	if (lflag >= 2)
  800775:	83 f9 01             	cmp    $0x1,%ecx
  800778:	7e 3f                	jle    8007b9 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  80077a:	8b 45 14             	mov    0x14(%ebp),%eax
  80077d:	8b 50 04             	mov    0x4(%eax),%edx
  800780:	8b 00                	mov    (%eax),%eax
  800782:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800785:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800788:	8b 45 14             	mov    0x14(%ebp),%eax
  80078b:	8d 40 08             	lea    0x8(%eax),%eax
  80078e:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800791:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800795:	79 5c                	jns    8007f3 <vprintfmt+0x2e5>
				putch('-', putdat);
  800797:	83 ec 08             	sub    $0x8,%esp
  80079a:	53                   	push   %ebx
  80079b:	6a 2d                	push   $0x2d
  80079d:	ff d6                	call   *%esi
				num = -(long long) num;
  80079f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007a2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007a5:	f7 da                	neg    %edx
  8007a7:	83 d1 00             	adc    $0x0,%ecx
  8007aa:	f7 d9                	neg    %ecx
  8007ac:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007af:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007b4:	e9 10 01 00 00       	jmp    8008c9 <vprintfmt+0x3bb>
	else if (lflag)
  8007b9:	85 c9                	test   %ecx,%ecx
  8007bb:	75 1b                	jne    8007d8 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8007bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c0:	8b 00                	mov    (%eax),%eax
  8007c2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007c5:	89 c1                	mov    %eax,%ecx
  8007c7:	c1 f9 1f             	sar    $0x1f,%ecx
  8007ca:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d0:	8d 40 04             	lea    0x4(%eax),%eax
  8007d3:	89 45 14             	mov    %eax,0x14(%ebp)
  8007d6:	eb b9                	jmp    800791 <vprintfmt+0x283>
		return va_arg(*ap, long);
  8007d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007db:	8b 00                	mov    (%eax),%eax
  8007dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e0:	89 c1                	mov    %eax,%ecx
  8007e2:	c1 f9 1f             	sar    $0x1f,%ecx
  8007e5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007eb:	8d 40 04             	lea    0x4(%eax),%eax
  8007ee:	89 45 14             	mov    %eax,0x14(%ebp)
  8007f1:	eb 9e                	jmp    800791 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8007f3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007f6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007f9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007fe:	e9 c6 00 00 00       	jmp    8008c9 <vprintfmt+0x3bb>
	if (lflag >= 2)
  800803:	83 f9 01             	cmp    $0x1,%ecx
  800806:	7e 18                	jle    800820 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  800808:	8b 45 14             	mov    0x14(%ebp),%eax
  80080b:	8b 10                	mov    (%eax),%edx
  80080d:	8b 48 04             	mov    0x4(%eax),%ecx
  800810:	8d 40 08             	lea    0x8(%eax),%eax
  800813:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800816:	b8 0a 00 00 00       	mov    $0xa,%eax
  80081b:	e9 a9 00 00 00       	jmp    8008c9 <vprintfmt+0x3bb>
	else if (lflag)
  800820:	85 c9                	test   %ecx,%ecx
  800822:	75 1a                	jne    80083e <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  800824:	8b 45 14             	mov    0x14(%ebp),%eax
  800827:	8b 10                	mov    (%eax),%edx
  800829:	b9 00 00 00 00       	mov    $0x0,%ecx
  80082e:	8d 40 04             	lea    0x4(%eax),%eax
  800831:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800834:	b8 0a 00 00 00       	mov    $0xa,%eax
  800839:	e9 8b 00 00 00       	jmp    8008c9 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80083e:	8b 45 14             	mov    0x14(%ebp),%eax
  800841:	8b 10                	mov    (%eax),%edx
  800843:	b9 00 00 00 00       	mov    $0x0,%ecx
  800848:	8d 40 04             	lea    0x4(%eax),%eax
  80084b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80084e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800853:	eb 74                	jmp    8008c9 <vprintfmt+0x3bb>
	if (lflag >= 2)
  800855:	83 f9 01             	cmp    $0x1,%ecx
  800858:	7e 15                	jle    80086f <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  80085a:	8b 45 14             	mov    0x14(%ebp),%eax
  80085d:	8b 10                	mov    (%eax),%edx
  80085f:	8b 48 04             	mov    0x4(%eax),%ecx
  800862:	8d 40 08             	lea    0x8(%eax),%eax
  800865:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800868:	b8 08 00 00 00       	mov    $0x8,%eax
  80086d:	eb 5a                	jmp    8008c9 <vprintfmt+0x3bb>
	else if (lflag)
  80086f:	85 c9                	test   %ecx,%ecx
  800871:	75 17                	jne    80088a <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  800873:	8b 45 14             	mov    0x14(%ebp),%eax
  800876:	8b 10                	mov    (%eax),%edx
  800878:	b9 00 00 00 00       	mov    $0x0,%ecx
  80087d:	8d 40 04             	lea    0x4(%eax),%eax
  800880:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800883:	b8 08 00 00 00       	mov    $0x8,%eax
  800888:	eb 3f                	jmp    8008c9 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80088a:	8b 45 14             	mov    0x14(%ebp),%eax
  80088d:	8b 10                	mov    (%eax),%edx
  80088f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800894:	8d 40 04             	lea    0x4(%eax),%eax
  800897:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80089a:	b8 08 00 00 00       	mov    $0x8,%eax
  80089f:	eb 28                	jmp    8008c9 <vprintfmt+0x3bb>
			putch('0', putdat);
  8008a1:	83 ec 08             	sub    $0x8,%esp
  8008a4:	53                   	push   %ebx
  8008a5:	6a 30                	push   $0x30
  8008a7:	ff d6                	call   *%esi
			putch('x', putdat);
  8008a9:	83 c4 08             	add    $0x8,%esp
  8008ac:	53                   	push   %ebx
  8008ad:	6a 78                	push   $0x78
  8008af:	ff d6                	call   *%esi
			num = (unsigned long long)
  8008b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b4:	8b 10                	mov    (%eax),%edx
  8008b6:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8008bb:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8008be:	8d 40 04             	lea    0x4(%eax),%eax
  8008c1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008c4:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8008c9:	83 ec 0c             	sub    $0xc,%esp
  8008cc:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008d0:	57                   	push   %edi
  8008d1:	ff 75 e0             	pushl  -0x20(%ebp)
  8008d4:	50                   	push   %eax
  8008d5:	51                   	push   %ecx
  8008d6:	52                   	push   %edx
  8008d7:	89 da                	mov    %ebx,%edx
  8008d9:	89 f0                	mov    %esi,%eax
  8008db:	e8 45 fb ff ff       	call   800425 <printnum>
			break;
  8008e0:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8008e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008e6:	83 c7 01             	add    $0x1,%edi
  8008e9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008ed:	83 f8 25             	cmp    $0x25,%eax
  8008f0:	0f 84 2f fc ff ff    	je     800525 <vprintfmt+0x17>
			if (ch == '\0')
  8008f6:	85 c0                	test   %eax,%eax
  8008f8:	0f 84 8b 00 00 00    	je     800989 <vprintfmt+0x47b>
			putch(ch, putdat);
  8008fe:	83 ec 08             	sub    $0x8,%esp
  800901:	53                   	push   %ebx
  800902:	50                   	push   %eax
  800903:	ff d6                	call   *%esi
  800905:	83 c4 10             	add    $0x10,%esp
  800908:	eb dc                	jmp    8008e6 <vprintfmt+0x3d8>
	if (lflag >= 2)
  80090a:	83 f9 01             	cmp    $0x1,%ecx
  80090d:	7e 15                	jle    800924 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  80090f:	8b 45 14             	mov    0x14(%ebp),%eax
  800912:	8b 10                	mov    (%eax),%edx
  800914:	8b 48 04             	mov    0x4(%eax),%ecx
  800917:	8d 40 08             	lea    0x8(%eax),%eax
  80091a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80091d:	b8 10 00 00 00       	mov    $0x10,%eax
  800922:	eb a5                	jmp    8008c9 <vprintfmt+0x3bb>
	else if (lflag)
  800924:	85 c9                	test   %ecx,%ecx
  800926:	75 17                	jne    80093f <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  800928:	8b 45 14             	mov    0x14(%ebp),%eax
  80092b:	8b 10                	mov    (%eax),%edx
  80092d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800932:	8d 40 04             	lea    0x4(%eax),%eax
  800935:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800938:	b8 10 00 00 00       	mov    $0x10,%eax
  80093d:	eb 8a                	jmp    8008c9 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80093f:	8b 45 14             	mov    0x14(%ebp),%eax
  800942:	8b 10                	mov    (%eax),%edx
  800944:	b9 00 00 00 00       	mov    $0x0,%ecx
  800949:	8d 40 04             	lea    0x4(%eax),%eax
  80094c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80094f:	b8 10 00 00 00       	mov    $0x10,%eax
  800954:	e9 70 ff ff ff       	jmp    8008c9 <vprintfmt+0x3bb>
			putch(ch, putdat);
  800959:	83 ec 08             	sub    $0x8,%esp
  80095c:	53                   	push   %ebx
  80095d:	6a 25                	push   $0x25
  80095f:	ff d6                	call   *%esi
			break;
  800961:	83 c4 10             	add    $0x10,%esp
  800964:	e9 7a ff ff ff       	jmp    8008e3 <vprintfmt+0x3d5>
			putch('%', putdat);
  800969:	83 ec 08             	sub    $0x8,%esp
  80096c:	53                   	push   %ebx
  80096d:	6a 25                	push   $0x25
  80096f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800971:	83 c4 10             	add    $0x10,%esp
  800974:	89 f8                	mov    %edi,%eax
  800976:	eb 03                	jmp    80097b <vprintfmt+0x46d>
  800978:	83 e8 01             	sub    $0x1,%eax
  80097b:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80097f:	75 f7                	jne    800978 <vprintfmt+0x46a>
  800981:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800984:	e9 5a ff ff ff       	jmp    8008e3 <vprintfmt+0x3d5>
}
  800989:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80098c:	5b                   	pop    %ebx
  80098d:	5e                   	pop    %esi
  80098e:	5f                   	pop    %edi
  80098f:	5d                   	pop    %ebp
  800990:	c3                   	ret    

00800991 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
  800994:	83 ec 18             	sub    $0x18,%esp
  800997:	8b 45 08             	mov    0x8(%ebp),%eax
  80099a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80099d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009a0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009a4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009ae:	85 c0                	test   %eax,%eax
  8009b0:	74 26                	je     8009d8 <vsnprintf+0x47>
  8009b2:	85 d2                	test   %edx,%edx
  8009b4:	7e 22                	jle    8009d8 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009b6:	ff 75 14             	pushl  0x14(%ebp)
  8009b9:	ff 75 10             	pushl  0x10(%ebp)
  8009bc:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009bf:	50                   	push   %eax
  8009c0:	68 d4 04 80 00       	push   $0x8004d4
  8009c5:	e8 44 fb ff ff       	call   80050e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009cd:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009d3:	83 c4 10             	add    $0x10,%esp
}
  8009d6:	c9                   	leave  
  8009d7:	c3                   	ret    
		return -E_INVAL;
  8009d8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009dd:	eb f7                	jmp    8009d6 <vsnprintf+0x45>

008009df <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009e5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009e8:	50                   	push   %eax
  8009e9:	ff 75 10             	pushl  0x10(%ebp)
  8009ec:	ff 75 0c             	pushl  0xc(%ebp)
  8009ef:	ff 75 08             	pushl  0x8(%ebp)
  8009f2:	e8 9a ff ff ff       	call   800991 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009f7:	c9                   	leave  
  8009f8:	c3                   	ret    

008009f9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009f9:	55                   	push   %ebp
  8009fa:	89 e5                	mov    %esp,%ebp
  8009fc:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800a04:	eb 03                	jmp    800a09 <strlen+0x10>
		n++;
  800a06:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800a09:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a0d:	75 f7                	jne    800a06 <strlen+0xd>
	return n;
}
  800a0f:	5d                   	pop    %ebp
  800a10:	c3                   	ret    

00800a11 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a11:	55                   	push   %ebp
  800a12:	89 e5                	mov    %esp,%ebp
  800a14:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a17:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a1a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1f:	eb 03                	jmp    800a24 <strnlen+0x13>
		n++;
  800a21:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a24:	39 d0                	cmp    %edx,%eax
  800a26:	74 06                	je     800a2e <strnlen+0x1d>
  800a28:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a2c:	75 f3                	jne    800a21 <strnlen+0x10>
	return n;
}
  800a2e:	5d                   	pop    %ebp
  800a2f:	c3                   	ret    

00800a30 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	53                   	push   %ebx
  800a34:	8b 45 08             	mov    0x8(%ebp),%eax
  800a37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a3a:	89 c2                	mov    %eax,%edx
  800a3c:	83 c1 01             	add    $0x1,%ecx
  800a3f:	83 c2 01             	add    $0x1,%edx
  800a42:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a46:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a49:	84 db                	test   %bl,%bl
  800a4b:	75 ef                	jne    800a3c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a4d:	5b                   	pop    %ebx
  800a4e:	5d                   	pop    %ebp
  800a4f:	c3                   	ret    

00800a50 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	53                   	push   %ebx
  800a54:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a57:	53                   	push   %ebx
  800a58:	e8 9c ff ff ff       	call   8009f9 <strlen>
  800a5d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a60:	ff 75 0c             	pushl  0xc(%ebp)
  800a63:	01 d8                	add    %ebx,%eax
  800a65:	50                   	push   %eax
  800a66:	e8 c5 ff ff ff       	call   800a30 <strcpy>
	return dst;
}
  800a6b:	89 d8                	mov    %ebx,%eax
  800a6d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a70:	c9                   	leave  
  800a71:	c3                   	ret    

00800a72 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a72:	55                   	push   %ebp
  800a73:	89 e5                	mov    %esp,%ebp
  800a75:	56                   	push   %esi
  800a76:	53                   	push   %ebx
  800a77:	8b 75 08             	mov    0x8(%ebp),%esi
  800a7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a7d:	89 f3                	mov    %esi,%ebx
  800a7f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a82:	89 f2                	mov    %esi,%edx
  800a84:	eb 0f                	jmp    800a95 <strncpy+0x23>
		*dst++ = *src;
  800a86:	83 c2 01             	add    $0x1,%edx
  800a89:	0f b6 01             	movzbl (%ecx),%eax
  800a8c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a8f:	80 39 01             	cmpb   $0x1,(%ecx)
  800a92:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800a95:	39 da                	cmp    %ebx,%edx
  800a97:	75 ed                	jne    800a86 <strncpy+0x14>
	}
	return ret;
}
  800a99:	89 f0                	mov    %esi,%eax
  800a9b:	5b                   	pop    %ebx
  800a9c:	5e                   	pop    %esi
  800a9d:	5d                   	pop    %ebp
  800a9e:	c3                   	ret    

00800a9f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a9f:	55                   	push   %ebp
  800aa0:	89 e5                	mov    %esp,%ebp
  800aa2:	56                   	push   %esi
  800aa3:	53                   	push   %ebx
  800aa4:	8b 75 08             	mov    0x8(%ebp),%esi
  800aa7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aaa:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800aad:	89 f0                	mov    %esi,%eax
  800aaf:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ab3:	85 c9                	test   %ecx,%ecx
  800ab5:	75 0b                	jne    800ac2 <strlcpy+0x23>
  800ab7:	eb 17                	jmp    800ad0 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800ab9:	83 c2 01             	add    $0x1,%edx
  800abc:	83 c0 01             	add    $0x1,%eax
  800abf:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800ac2:	39 d8                	cmp    %ebx,%eax
  800ac4:	74 07                	je     800acd <strlcpy+0x2e>
  800ac6:	0f b6 0a             	movzbl (%edx),%ecx
  800ac9:	84 c9                	test   %cl,%cl
  800acb:	75 ec                	jne    800ab9 <strlcpy+0x1a>
		*dst = '\0';
  800acd:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800ad0:	29 f0                	sub    %esi,%eax
}
  800ad2:	5b                   	pop    %ebx
  800ad3:	5e                   	pop    %esi
  800ad4:	5d                   	pop    %ebp
  800ad5:	c3                   	ret    

00800ad6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ad6:	55                   	push   %ebp
  800ad7:	89 e5                	mov    %esp,%ebp
  800ad9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800adc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800adf:	eb 06                	jmp    800ae7 <strcmp+0x11>
		p++, q++;
  800ae1:	83 c1 01             	add    $0x1,%ecx
  800ae4:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800ae7:	0f b6 01             	movzbl (%ecx),%eax
  800aea:	84 c0                	test   %al,%al
  800aec:	74 04                	je     800af2 <strcmp+0x1c>
  800aee:	3a 02                	cmp    (%edx),%al
  800af0:	74 ef                	je     800ae1 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800af2:	0f b6 c0             	movzbl %al,%eax
  800af5:	0f b6 12             	movzbl (%edx),%edx
  800af8:	29 d0                	sub    %edx,%eax
}
  800afa:	5d                   	pop    %ebp
  800afb:	c3                   	ret    

00800afc <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800afc:	55                   	push   %ebp
  800afd:	89 e5                	mov    %esp,%ebp
  800aff:	53                   	push   %ebx
  800b00:	8b 45 08             	mov    0x8(%ebp),%eax
  800b03:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b06:	89 c3                	mov    %eax,%ebx
  800b08:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b0b:	eb 06                	jmp    800b13 <strncmp+0x17>
		n--, p++, q++;
  800b0d:	83 c0 01             	add    $0x1,%eax
  800b10:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b13:	39 d8                	cmp    %ebx,%eax
  800b15:	74 16                	je     800b2d <strncmp+0x31>
  800b17:	0f b6 08             	movzbl (%eax),%ecx
  800b1a:	84 c9                	test   %cl,%cl
  800b1c:	74 04                	je     800b22 <strncmp+0x26>
  800b1e:	3a 0a                	cmp    (%edx),%cl
  800b20:	74 eb                	je     800b0d <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b22:	0f b6 00             	movzbl (%eax),%eax
  800b25:	0f b6 12             	movzbl (%edx),%edx
  800b28:	29 d0                	sub    %edx,%eax
}
  800b2a:	5b                   	pop    %ebx
  800b2b:	5d                   	pop    %ebp
  800b2c:	c3                   	ret    
		return 0;
  800b2d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b32:	eb f6                	jmp    800b2a <strncmp+0x2e>

00800b34 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b3e:	0f b6 10             	movzbl (%eax),%edx
  800b41:	84 d2                	test   %dl,%dl
  800b43:	74 09                	je     800b4e <strchr+0x1a>
		if (*s == c)
  800b45:	38 ca                	cmp    %cl,%dl
  800b47:	74 0a                	je     800b53 <strchr+0x1f>
	for (; *s; s++)
  800b49:	83 c0 01             	add    $0x1,%eax
  800b4c:	eb f0                	jmp    800b3e <strchr+0xa>
			return (char *) s;
	return 0;
  800b4e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b53:	5d                   	pop    %ebp
  800b54:	c3                   	ret    

00800b55 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b5f:	eb 03                	jmp    800b64 <strfind+0xf>
  800b61:	83 c0 01             	add    $0x1,%eax
  800b64:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b67:	38 ca                	cmp    %cl,%dl
  800b69:	74 04                	je     800b6f <strfind+0x1a>
  800b6b:	84 d2                	test   %dl,%dl
  800b6d:	75 f2                	jne    800b61 <strfind+0xc>
			break;
	return (char *) s;
}
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    

00800b71 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	57                   	push   %edi
  800b75:	56                   	push   %esi
  800b76:	53                   	push   %ebx
  800b77:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b7a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b7d:	85 c9                	test   %ecx,%ecx
  800b7f:	74 13                	je     800b94 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b81:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b87:	75 05                	jne    800b8e <memset+0x1d>
  800b89:	f6 c1 03             	test   $0x3,%cl
  800b8c:	74 0d                	je     800b9b <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b91:	fc                   	cld    
  800b92:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b94:	89 f8                	mov    %edi,%eax
  800b96:	5b                   	pop    %ebx
  800b97:	5e                   	pop    %esi
  800b98:	5f                   	pop    %edi
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    
		c &= 0xFF;
  800b9b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b9f:	89 d3                	mov    %edx,%ebx
  800ba1:	c1 e3 08             	shl    $0x8,%ebx
  800ba4:	89 d0                	mov    %edx,%eax
  800ba6:	c1 e0 18             	shl    $0x18,%eax
  800ba9:	89 d6                	mov    %edx,%esi
  800bab:	c1 e6 10             	shl    $0x10,%esi
  800bae:	09 f0                	or     %esi,%eax
  800bb0:	09 c2                	or     %eax,%edx
  800bb2:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800bb4:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800bb7:	89 d0                	mov    %edx,%eax
  800bb9:	fc                   	cld    
  800bba:	f3 ab                	rep stos %eax,%es:(%edi)
  800bbc:	eb d6                	jmp    800b94 <memset+0x23>

00800bbe <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	57                   	push   %edi
  800bc2:	56                   	push   %esi
  800bc3:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bc9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bcc:	39 c6                	cmp    %eax,%esi
  800bce:	73 35                	jae    800c05 <memmove+0x47>
  800bd0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bd3:	39 c2                	cmp    %eax,%edx
  800bd5:	76 2e                	jbe    800c05 <memmove+0x47>
		s += n;
		d += n;
  800bd7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bda:	89 d6                	mov    %edx,%esi
  800bdc:	09 fe                	or     %edi,%esi
  800bde:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800be4:	74 0c                	je     800bf2 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800be6:	83 ef 01             	sub    $0x1,%edi
  800be9:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800bec:	fd                   	std    
  800bed:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bef:	fc                   	cld    
  800bf0:	eb 21                	jmp    800c13 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bf2:	f6 c1 03             	test   $0x3,%cl
  800bf5:	75 ef                	jne    800be6 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bf7:	83 ef 04             	sub    $0x4,%edi
  800bfa:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bfd:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c00:	fd                   	std    
  800c01:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c03:	eb ea                	jmp    800bef <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c05:	89 f2                	mov    %esi,%edx
  800c07:	09 c2                	or     %eax,%edx
  800c09:	f6 c2 03             	test   $0x3,%dl
  800c0c:	74 09                	je     800c17 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c0e:	89 c7                	mov    %eax,%edi
  800c10:	fc                   	cld    
  800c11:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c13:	5e                   	pop    %esi
  800c14:	5f                   	pop    %edi
  800c15:	5d                   	pop    %ebp
  800c16:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c17:	f6 c1 03             	test   $0x3,%cl
  800c1a:	75 f2                	jne    800c0e <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c1c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c1f:	89 c7                	mov    %eax,%edi
  800c21:	fc                   	cld    
  800c22:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c24:	eb ed                	jmp    800c13 <memmove+0x55>

00800c26 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c29:	ff 75 10             	pushl  0x10(%ebp)
  800c2c:	ff 75 0c             	pushl  0xc(%ebp)
  800c2f:	ff 75 08             	pushl  0x8(%ebp)
  800c32:	e8 87 ff ff ff       	call   800bbe <memmove>
}
  800c37:	c9                   	leave  
  800c38:	c3                   	ret    

00800c39 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c39:	55                   	push   %ebp
  800c3a:	89 e5                	mov    %esp,%ebp
  800c3c:	56                   	push   %esi
  800c3d:	53                   	push   %ebx
  800c3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c41:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c44:	89 c6                	mov    %eax,%esi
  800c46:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c49:	39 f0                	cmp    %esi,%eax
  800c4b:	74 1c                	je     800c69 <memcmp+0x30>
		if (*s1 != *s2)
  800c4d:	0f b6 08             	movzbl (%eax),%ecx
  800c50:	0f b6 1a             	movzbl (%edx),%ebx
  800c53:	38 d9                	cmp    %bl,%cl
  800c55:	75 08                	jne    800c5f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800c57:	83 c0 01             	add    $0x1,%eax
  800c5a:	83 c2 01             	add    $0x1,%edx
  800c5d:	eb ea                	jmp    800c49 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800c5f:	0f b6 c1             	movzbl %cl,%eax
  800c62:	0f b6 db             	movzbl %bl,%ebx
  800c65:	29 d8                	sub    %ebx,%eax
  800c67:	eb 05                	jmp    800c6e <memcmp+0x35>
	}

	return 0;
  800c69:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c6e:	5b                   	pop    %ebx
  800c6f:	5e                   	pop    %esi
  800c70:	5d                   	pop    %ebp
  800c71:	c3                   	ret    

00800c72 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c72:	55                   	push   %ebp
  800c73:	89 e5                	mov    %esp,%ebp
  800c75:	8b 45 08             	mov    0x8(%ebp),%eax
  800c78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c7b:	89 c2                	mov    %eax,%edx
  800c7d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c80:	39 d0                	cmp    %edx,%eax
  800c82:	73 09                	jae    800c8d <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c84:	38 08                	cmp    %cl,(%eax)
  800c86:	74 05                	je     800c8d <memfind+0x1b>
	for (; s < ends; s++)
  800c88:	83 c0 01             	add    $0x1,%eax
  800c8b:	eb f3                	jmp    800c80 <memfind+0xe>
			break;
	return (void *) s;
}
  800c8d:	5d                   	pop    %ebp
  800c8e:	c3                   	ret    

00800c8f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c8f:	55                   	push   %ebp
  800c90:	89 e5                	mov    %esp,%ebp
  800c92:	57                   	push   %edi
  800c93:	56                   	push   %esi
  800c94:	53                   	push   %ebx
  800c95:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c98:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c9b:	eb 03                	jmp    800ca0 <strtol+0x11>
		s++;
  800c9d:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800ca0:	0f b6 01             	movzbl (%ecx),%eax
  800ca3:	3c 20                	cmp    $0x20,%al
  800ca5:	74 f6                	je     800c9d <strtol+0xe>
  800ca7:	3c 09                	cmp    $0x9,%al
  800ca9:	74 f2                	je     800c9d <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800cab:	3c 2b                	cmp    $0x2b,%al
  800cad:	74 2e                	je     800cdd <strtol+0x4e>
	int neg = 0;
  800caf:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800cb4:	3c 2d                	cmp    $0x2d,%al
  800cb6:	74 2f                	je     800ce7 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cb8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800cbe:	75 05                	jne    800cc5 <strtol+0x36>
  800cc0:	80 39 30             	cmpb   $0x30,(%ecx)
  800cc3:	74 2c                	je     800cf1 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cc5:	85 db                	test   %ebx,%ebx
  800cc7:	75 0a                	jne    800cd3 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cc9:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800cce:	80 39 30             	cmpb   $0x30,(%ecx)
  800cd1:	74 28                	je     800cfb <strtol+0x6c>
		base = 10;
  800cd3:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd8:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800cdb:	eb 50                	jmp    800d2d <strtol+0x9e>
		s++;
  800cdd:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800ce0:	bf 00 00 00 00       	mov    $0x0,%edi
  800ce5:	eb d1                	jmp    800cb8 <strtol+0x29>
		s++, neg = 1;
  800ce7:	83 c1 01             	add    $0x1,%ecx
  800cea:	bf 01 00 00 00       	mov    $0x1,%edi
  800cef:	eb c7                	jmp    800cb8 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cf1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800cf5:	74 0e                	je     800d05 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800cf7:	85 db                	test   %ebx,%ebx
  800cf9:	75 d8                	jne    800cd3 <strtol+0x44>
		s++, base = 8;
  800cfb:	83 c1 01             	add    $0x1,%ecx
  800cfe:	bb 08 00 00 00       	mov    $0x8,%ebx
  800d03:	eb ce                	jmp    800cd3 <strtol+0x44>
		s += 2, base = 16;
  800d05:	83 c1 02             	add    $0x2,%ecx
  800d08:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d0d:	eb c4                	jmp    800cd3 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800d0f:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d12:	89 f3                	mov    %esi,%ebx
  800d14:	80 fb 19             	cmp    $0x19,%bl
  800d17:	77 29                	ja     800d42 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800d19:	0f be d2             	movsbl %dl,%edx
  800d1c:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d1f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d22:	7d 30                	jge    800d54 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800d24:	83 c1 01             	add    $0x1,%ecx
  800d27:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d2b:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800d2d:	0f b6 11             	movzbl (%ecx),%edx
  800d30:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d33:	89 f3                	mov    %esi,%ebx
  800d35:	80 fb 09             	cmp    $0x9,%bl
  800d38:	77 d5                	ja     800d0f <strtol+0x80>
			dig = *s - '0';
  800d3a:	0f be d2             	movsbl %dl,%edx
  800d3d:	83 ea 30             	sub    $0x30,%edx
  800d40:	eb dd                	jmp    800d1f <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800d42:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d45:	89 f3                	mov    %esi,%ebx
  800d47:	80 fb 19             	cmp    $0x19,%bl
  800d4a:	77 08                	ja     800d54 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800d4c:	0f be d2             	movsbl %dl,%edx
  800d4f:	83 ea 37             	sub    $0x37,%edx
  800d52:	eb cb                	jmp    800d1f <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800d54:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d58:	74 05                	je     800d5f <strtol+0xd0>
		*endptr = (char *) s;
  800d5a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d5d:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800d5f:	89 c2                	mov    %eax,%edx
  800d61:	f7 da                	neg    %edx
  800d63:	85 ff                	test   %edi,%edi
  800d65:	0f 45 c2             	cmovne %edx,%eax
}
  800d68:	5b                   	pop    %ebx
  800d69:	5e                   	pop    %esi
  800d6a:	5f                   	pop    %edi
  800d6b:	5d                   	pop    %ebp
  800d6c:	c3                   	ret    

00800d6d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d6d:	55                   	push   %ebp
  800d6e:	89 e5                	mov    %esp,%ebp
  800d70:	57                   	push   %edi
  800d71:	56                   	push   %esi
  800d72:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d73:	b8 00 00 00 00       	mov    $0x0,%eax
  800d78:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7e:	89 c3                	mov    %eax,%ebx
  800d80:	89 c7                	mov    %eax,%edi
  800d82:	89 c6                	mov    %eax,%esi
  800d84:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d86:	5b                   	pop    %ebx
  800d87:	5e                   	pop    %esi
  800d88:	5f                   	pop    %edi
  800d89:	5d                   	pop    %ebp
  800d8a:	c3                   	ret    

00800d8b <sys_cgetc>:

int
sys_cgetc(void)
{
  800d8b:	55                   	push   %ebp
  800d8c:	89 e5                	mov    %esp,%ebp
  800d8e:	57                   	push   %edi
  800d8f:	56                   	push   %esi
  800d90:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d91:	ba 00 00 00 00       	mov    $0x0,%edx
  800d96:	b8 01 00 00 00       	mov    $0x1,%eax
  800d9b:	89 d1                	mov    %edx,%ecx
  800d9d:	89 d3                	mov    %edx,%ebx
  800d9f:	89 d7                	mov    %edx,%edi
  800da1:	89 d6                	mov    %edx,%esi
  800da3:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800da5:	5b                   	pop    %ebx
  800da6:	5e                   	pop    %esi
  800da7:	5f                   	pop    %edi
  800da8:	5d                   	pop    %ebp
  800da9:	c3                   	ret    

00800daa <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
  800dad:	57                   	push   %edi
  800dae:	56                   	push   %esi
  800daf:	53                   	push   %ebx
  800db0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800db3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800db8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbb:	b8 03 00 00 00       	mov    $0x3,%eax
  800dc0:	89 cb                	mov    %ecx,%ebx
  800dc2:	89 cf                	mov    %ecx,%edi
  800dc4:	89 ce                	mov    %ecx,%esi
  800dc6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dc8:	85 c0                	test   %eax,%eax
  800dca:	7f 08                	jg     800dd4 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800dcc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dcf:	5b                   	pop    %ebx
  800dd0:	5e                   	pop    %esi
  800dd1:	5f                   	pop    %edi
  800dd2:	5d                   	pop    %ebp
  800dd3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd4:	83 ec 0c             	sub    $0xc,%esp
  800dd7:	50                   	push   %eax
  800dd8:	6a 03                	push   $0x3
  800dda:	68 9f 28 80 00       	push   $0x80289f
  800ddf:	6a 23                	push   $0x23
  800de1:	68 bc 28 80 00       	push   $0x8028bc
  800de6:	e8 4b f5 ff ff       	call   800336 <_panic>

00800deb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800deb:	55                   	push   %ebp
  800dec:	89 e5                	mov    %esp,%ebp
  800dee:	57                   	push   %edi
  800def:	56                   	push   %esi
  800df0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800df1:	ba 00 00 00 00       	mov    $0x0,%edx
  800df6:	b8 02 00 00 00       	mov    $0x2,%eax
  800dfb:	89 d1                	mov    %edx,%ecx
  800dfd:	89 d3                	mov    %edx,%ebx
  800dff:	89 d7                	mov    %edx,%edi
  800e01:	89 d6                	mov    %edx,%esi
  800e03:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e05:	5b                   	pop    %ebx
  800e06:	5e                   	pop    %esi
  800e07:	5f                   	pop    %edi
  800e08:	5d                   	pop    %ebp
  800e09:	c3                   	ret    

00800e0a <sys_yield>:

void
sys_yield(void)
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	57                   	push   %edi
  800e0e:	56                   	push   %esi
  800e0f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e10:	ba 00 00 00 00       	mov    $0x0,%edx
  800e15:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e1a:	89 d1                	mov    %edx,%ecx
  800e1c:	89 d3                	mov    %edx,%ebx
  800e1e:	89 d7                	mov    %edx,%edi
  800e20:	89 d6                	mov    %edx,%esi
  800e22:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e24:	5b                   	pop    %ebx
  800e25:	5e                   	pop    %esi
  800e26:	5f                   	pop    %edi
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    

00800e29 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	57                   	push   %edi
  800e2d:	56                   	push   %esi
  800e2e:	53                   	push   %ebx
  800e2f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e32:	be 00 00 00 00       	mov    $0x0,%esi
  800e37:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3d:	b8 04 00 00 00       	mov    $0x4,%eax
  800e42:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e45:	89 f7                	mov    %esi,%edi
  800e47:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e49:	85 c0                	test   %eax,%eax
  800e4b:	7f 08                	jg     800e55 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e50:	5b                   	pop    %ebx
  800e51:	5e                   	pop    %esi
  800e52:	5f                   	pop    %edi
  800e53:	5d                   	pop    %ebp
  800e54:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e55:	83 ec 0c             	sub    $0xc,%esp
  800e58:	50                   	push   %eax
  800e59:	6a 04                	push   $0x4
  800e5b:	68 9f 28 80 00       	push   $0x80289f
  800e60:	6a 23                	push   $0x23
  800e62:	68 bc 28 80 00       	push   $0x8028bc
  800e67:	e8 ca f4 ff ff       	call   800336 <_panic>

00800e6c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e6c:	55                   	push   %ebp
  800e6d:	89 e5                	mov    %esp,%ebp
  800e6f:	57                   	push   %edi
  800e70:	56                   	push   %esi
  800e71:	53                   	push   %ebx
  800e72:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e75:	8b 55 08             	mov    0x8(%ebp),%edx
  800e78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7b:	b8 05 00 00 00       	mov    $0x5,%eax
  800e80:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e83:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e86:	8b 75 18             	mov    0x18(%ebp),%esi
  800e89:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e8b:	85 c0                	test   %eax,%eax
  800e8d:	7f 08                	jg     800e97 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e92:	5b                   	pop    %ebx
  800e93:	5e                   	pop    %esi
  800e94:	5f                   	pop    %edi
  800e95:	5d                   	pop    %ebp
  800e96:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e97:	83 ec 0c             	sub    $0xc,%esp
  800e9a:	50                   	push   %eax
  800e9b:	6a 05                	push   $0x5
  800e9d:	68 9f 28 80 00       	push   $0x80289f
  800ea2:	6a 23                	push   $0x23
  800ea4:	68 bc 28 80 00       	push   $0x8028bc
  800ea9:	e8 88 f4 ff ff       	call   800336 <_panic>

00800eae <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800eae:	55                   	push   %ebp
  800eaf:	89 e5                	mov    %esp,%ebp
  800eb1:	57                   	push   %edi
  800eb2:	56                   	push   %esi
  800eb3:	53                   	push   %ebx
  800eb4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800eb7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ebc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec2:	b8 06 00 00 00       	mov    $0x6,%eax
  800ec7:	89 df                	mov    %ebx,%edi
  800ec9:	89 de                	mov    %ebx,%esi
  800ecb:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ecd:	85 c0                	test   %eax,%eax
  800ecf:	7f 08                	jg     800ed9 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ed1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ed4:	5b                   	pop    %ebx
  800ed5:	5e                   	pop    %esi
  800ed6:	5f                   	pop    %edi
  800ed7:	5d                   	pop    %ebp
  800ed8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed9:	83 ec 0c             	sub    $0xc,%esp
  800edc:	50                   	push   %eax
  800edd:	6a 06                	push   $0x6
  800edf:	68 9f 28 80 00       	push   $0x80289f
  800ee4:	6a 23                	push   $0x23
  800ee6:	68 bc 28 80 00       	push   $0x8028bc
  800eeb:	e8 46 f4 ff ff       	call   800336 <_panic>

00800ef0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ef0:	55                   	push   %ebp
  800ef1:	89 e5                	mov    %esp,%ebp
  800ef3:	57                   	push   %edi
  800ef4:	56                   	push   %esi
  800ef5:	53                   	push   %ebx
  800ef6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ef9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800efe:	8b 55 08             	mov    0x8(%ebp),%edx
  800f01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f04:	b8 08 00 00 00       	mov    $0x8,%eax
  800f09:	89 df                	mov    %ebx,%edi
  800f0b:	89 de                	mov    %ebx,%esi
  800f0d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f0f:	85 c0                	test   %eax,%eax
  800f11:	7f 08                	jg     800f1b <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f16:	5b                   	pop    %ebx
  800f17:	5e                   	pop    %esi
  800f18:	5f                   	pop    %edi
  800f19:	5d                   	pop    %ebp
  800f1a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f1b:	83 ec 0c             	sub    $0xc,%esp
  800f1e:	50                   	push   %eax
  800f1f:	6a 08                	push   $0x8
  800f21:	68 9f 28 80 00       	push   $0x80289f
  800f26:	6a 23                	push   $0x23
  800f28:	68 bc 28 80 00       	push   $0x8028bc
  800f2d:	e8 04 f4 ff ff       	call   800336 <_panic>

00800f32 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f32:	55                   	push   %ebp
  800f33:	89 e5                	mov    %esp,%ebp
  800f35:	57                   	push   %edi
  800f36:	56                   	push   %esi
  800f37:	53                   	push   %ebx
  800f38:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f3b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f40:	8b 55 08             	mov    0x8(%ebp),%edx
  800f43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f46:	b8 09 00 00 00       	mov    $0x9,%eax
  800f4b:	89 df                	mov    %ebx,%edi
  800f4d:	89 de                	mov    %ebx,%esi
  800f4f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f51:	85 c0                	test   %eax,%eax
  800f53:	7f 08                	jg     800f5d <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f58:	5b                   	pop    %ebx
  800f59:	5e                   	pop    %esi
  800f5a:	5f                   	pop    %edi
  800f5b:	5d                   	pop    %ebp
  800f5c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f5d:	83 ec 0c             	sub    $0xc,%esp
  800f60:	50                   	push   %eax
  800f61:	6a 09                	push   $0x9
  800f63:	68 9f 28 80 00       	push   $0x80289f
  800f68:	6a 23                	push   $0x23
  800f6a:	68 bc 28 80 00       	push   $0x8028bc
  800f6f:	e8 c2 f3 ff ff       	call   800336 <_panic>

00800f74 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f74:	55                   	push   %ebp
  800f75:	89 e5                	mov    %esp,%ebp
  800f77:	57                   	push   %edi
  800f78:	56                   	push   %esi
  800f79:	53                   	push   %ebx
  800f7a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f7d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f82:	8b 55 08             	mov    0x8(%ebp),%edx
  800f85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f88:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f8d:	89 df                	mov    %ebx,%edi
  800f8f:	89 de                	mov    %ebx,%esi
  800f91:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f93:	85 c0                	test   %eax,%eax
  800f95:	7f 08                	jg     800f9f <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f9a:	5b                   	pop    %ebx
  800f9b:	5e                   	pop    %esi
  800f9c:	5f                   	pop    %edi
  800f9d:	5d                   	pop    %ebp
  800f9e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f9f:	83 ec 0c             	sub    $0xc,%esp
  800fa2:	50                   	push   %eax
  800fa3:	6a 0a                	push   $0xa
  800fa5:	68 9f 28 80 00       	push   $0x80289f
  800faa:	6a 23                	push   $0x23
  800fac:	68 bc 28 80 00       	push   $0x8028bc
  800fb1:	e8 80 f3 ff ff       	call   800336 <_panic>

00800fb6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fb6:	55                   	push   %ebp
  800fb7:	89 e5                	mov    %esp,%ebp
  800fb9:	57                   	push   %edi
  800fba:	56                   	push   %esi
  800fbb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800fbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800fbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc2:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fc7:	be 00 00 00 00       	mov    $0x0,%esi
  800fcc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fcf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fd2:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800fd4:	5b                   	pop    %ebx
  800fd5:	5e                   	pop    %esi
  800fd6:	5f                   	pop    %edi
  800fd7:	5d                   	pop    %ebp
  800fd8:	c3                   	ret    

00800fd9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800fd9:	55                   	push   %ebp
  800fda:	89 e5                	mov    %esp,%ebp
  800fdc:	57                   	push   %edi
  800fdd:	56                   	push   %esi
  800fde:	53                   	push   %ebx
  800fdf:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800fe2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fe7:	8b 55 08             	mov    0x8(%ebp),%edx
  800fea:	b8 0d 00 00 00       	mov    $0xd,%eax
  800fef:	89 cb                	mov    %ecx,%ebx
  800ff1:	89 cf                	mov    %ecx,%edi
  800ff3:	89 ce                	mov    %ecx,%esi
  800ff5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ff7:	85 c0                	test   %eax,%eax
  800ff9:	7f 08                	jg     801003 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ffb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ffe:	5b                   	pop    %ebx
  800fff:	5e                   	pop    %esi
  801000:	5f                   	pop    %edi
  801001:	5d                   	pop    %ebp
  801002:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801003:	83 ec 0c             	sub    $0xc,%esp
  801006:	50                   	push   %eax
  801007:	6a 0d                	push   $0xd
  801009:	68 9f 28 80 00       	push   $0x80289f
  80100e:	6a 23                	push   $0x23
  801010:	68 bc 28 80 00       	push   $0x8028bc
  801015:	e8 1c f3 ff ff       	call   800336 <_panic>

0080101a <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80101a:	55                   	push   %ebp
  80101b:	89 e5                	mov    %esp,%ebp
  80101d:	53                   	push   %ebx
  80101e:	83 ec 04             	sub    $0x4,%esp
  801021:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  801024:	8b 02                	mov    (%edx),%eax
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  801026:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  80102a:	0f 84 9c 00 00 00    	je     8010cc <pgfault+0xb2>
  801030:	89 c2                	mov    %eax,%edx
  801032:	c1 ea 16             	shr    $0x16,%edx
  801035:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80103c:	f6 c2 01             	test   $0x1,%dl
  80103f:	0f 84 87 00 00 00    	je     8010cc <pgfault+0xb2>
  801045:	89 c2                	mov    %eax,%edx
  801047:	c1 ea 0c             	shr    $0xc,%edx
  80104a:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  801051:	f6 c1 01             	test   $0x1,%cl
  801054:	74 76                	je     8010cc <pgfault+0xb2>
  801056:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80105d:	f6 c6 08             	test   $0x8,%dh
  801060:	74 6a                	je     8010cc <pgfault+0xb2>
		panic("not copy-on-write");
	addr = ROUNDDOWN(addr, PGSIZE);
  801062:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801067:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P) < 0)
  801069:	83 ec 04             	sub    $0x4,%esp
  80106c:	6a 07                	push   $0x7
  80106e:	68 00 f0 7f 00       	push   $0x7ff000
  801073:	6a 00                	push   $0x0
  801075:	e8 af fd ff ff       	call   800e29 <sys_page_alloc>
  80107a:	83 c4 10             	add    $0x10,%esp
  80107d:	85 c0                	test   %eax,%eax
  80107f:	78 5f                	js     8010e0 <pgfault+0xc6>
		panic("sys_page_alloc");
	memcpy(PFTEMP, addr, PGSIZE);
  801081:	83 ec 04             	sub    $0x4,%esp
  801084:	68 00 10 00 00       	push   $0x1000
  801089:	53                   	push   %ebx
  80108a:	68 00 f0 7f 00       	push   $0x7ff000
  80108f:	e8 92 fb ff ff       	call   800c26 <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P) < 0)
  801094:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80109b:	53                   	push   %ebx
  80109c:	6a 00                	push   $0x0
  80109e:	68 00 f0 7f 00       	push   $0x7ff000
  8010a3:	6a 00                	push   $0x0
  8010a5:	e8 c2 fd ff ff       	call   800e6c <sys_page_map>
  8010aa:	83 c4 20             	add    $0x20,%esp
  8010ad:	85 c0                	test   %eax,%eax
  8010af:	78 43                	js     8010f4 <pgfault+0xda>
		panic("sys_page_map");
	if (sys_page_unmap(0, PFTEMP) < 0)
  8010b1:	83 ec 08             	sub    $0x8,%esp
  8010b4:	68 00 f0 7f 00       	push   $0x7ff000
  8010b9:	6a 00                	push   $0x0
  8010bb:	e8 ee fd ff ff       	call   800eae <sys_page_unmap>
  8010c0:	83 c4 10             	add    $0x10,%esp
  8010c3:	85 c0                	test   %eax,%eax
  8010c5:	78 41                	js     801108 <pgfault+0xee>
		panic("sys_page_unmap");
	return;
}
  8010c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010ca:	c9                   	leave  
  8010cb:	c3                   	ret    
		panic("not copy-on-write");
  8010cc:	83 ec 04             	sub    $0x4,%esp
  8010cf:	68 ca 28 80 00       	push   $0x8028ca
  8010d4:	6a 25                	push   $0x25
  8010d6:	68 dc 28 80 00       	push   $0x8028dc
  8010db:	e8 56 f2 ff ff       	call   800336 <_panic>
		panic("sys_page_alloc");
  8010e0:	83 ec 04             	sub    $0x4,%esp
  8010e3:	68 e7 28 80 00       	push   $0x8028e7
  8010e8:	6a 28                	push   $0x28
  8010ea:	68 dc 28 80 00       	push   $0x8028dc
  8010ef:	e8 42 f2 ff ff       	call   800336 <_panic>
		panic("sys_page_map");
  8010f4:	83 ec 04             	sub    $0x4,%esp
  8010f7:	68 f6 28 80 00       	push   $0x8028f6
  8010fc:	6a 2b                	push   $0x2b
  8010fe:	68 dc 28 80 00       	push   $0x8028dc
  801103:	e8 2e f2 ff ff       	call   800336 <_panic>
		panic("sys_page_unmap");
  801108:	83 ec 04             	sub    $0x4,%esp
  80110b:	68 03 29 80 00       	push   $0x802903
  801110:	6a 2d                	push   $0x2d
  801112:	68 dc 28 80 00       	push   $0x8028dc
  801117:	e8 1a f2 ff ff       	call   800336 <_panic>

0080111c <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80111c:	55                   	push   %ebp
  80111d:	89 e5                	mov    %esp,%ebp
  80111f:	57                   	push   %edi
  801120:	56                   	push   %esi
  801121:	53                   	push   %ebx
  801122:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  801125:	68 1a 10 80 00       	push   $0x80101a
  80112a:	e8 da 0e 00 00       	call   802009 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80112f:	b8 07 00 00 00       	mov    $0x7,%eax
  801134:	cd 30                	int    $0x30
  801136:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid;
	uint32_t addr;
	envid = sys_exofork();
	if (envid == 0) {
  801139:	83 c4 10             	add    $0x10,%esp
  80113c:	85 c0                	test   %eax,%eax
  80113e:	74 12                	je     801152 <fork+0x36>
  801140:	89 c7                	mov    %eax,%edi
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	if (envid < 0)
  801142:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801146:	78 26                	js     80116e <fork+0x52>
		panic("sys_exofork: %e", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  801148:	bb 00 00 00 00       	mov    $0x0,%ebx
  80114d:	e9 94 00 00 00       	jmp    8011e6 <fork+0xca>
		thisenv = &envs[ENVX(sys_getenvid())];
  801152:	e8 94 fc ff ff       	call   800deb <sys_getenvid>
  801157:	25 ff 03 00 00       	and    $0x3ff,%eax
  80115c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80115f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801164:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801169:	e9 51 01 00 00       	jmp    8012bf <fork+0x1a3>
		panic("sys_exofork: %e", envid);
  80116e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801171:	68 12 29 80 00       	push   $0x802912
  801176:	6a 6e                	push   $0x6e
  801178:	68 dc 28 80 00       	push   $0x8028dc
  80117d:	e8 b4 f1 ff ff       	call   800336 <_panic>
        	sys_page_map(0, addr, envid, addr, PTE_SYSCALL);
  801182:	83 ec 0c             	sub    $0xc,%esp
  801185:	68 07 0e 00 00       	push   $0xe07
  80118a:	56                   	push   %esi
  80118b:	57                   	push   %edi
  80118c:	56                   	push   %esi
  80118d:	6a 00                	push   $0x0
  80118f:	e8 d8 fc ff ff       	call   800e6c <sys_page_map>
  801194:	83 c4 20             	add    $0x20,%esp
  801197:	eb 3b                	jmp    8011d4 <fork+0xb8>
        	if ((r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  801199:	83 ec 0c             	sub    $0xc,%esp
  80119c:	68 05 08 00 00       	push   $0x805
  8011a1:	56                   	push   %esi
  8011a2:	57                   	push   %edi
  8011a3:	56                   	push   %esi
  8011a4:	6a 00                	push   $0x0
  8011a6:	e8 c1 fc ff ff       	call   800e6c <sys_page_map>
  8011ab:	83 c4 20             	add    $0x20,%esp
  8011ae:	85 c0                	test   %eax,%eax
  8011b0:	0f 88 a9 00 00 00    	js     80125f <fork+0x143>
        	if ((r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  8011b6:	83 ec 0c             	sub    $0xc,%esp
  8011b9:	68 05 08 00 00       	push   $0x805
  8011be:	56                   	push   %esi
  8011bf:	6a 00                	push   $0x0
  8011c1:	56                   	push   %esi
  8011c2:	6a 00                	push   $0x0
  8011c4:	e8 a3 fc ff ff       	call   800e6c <sys_page_map>
  8011c9:	83 c4 20             	add    $0x20,%esp
  8011cc:	85 c0                	test   %eax,%eax
  8011ce:	0f 88 9d 00 00 00    	js     801271 <fork+0x155>
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  8011d4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8011da:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8011e0:	0f 84 9d 00 00 00    	je     801283 <fork+0x167>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  8011e6:	89 d8                	mov    %ebx,%eax
  8011e8:	c1 e8 16             	shr    $0x16,%eax
  8011eb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011f2:	a8 01                	test   $0x1,%al
  8011f4:	74 de                	je     8011d4 <fork+0xb8>
  8011f6:	89 d8                	mov    %ebx,%eax
  8011f8:	c1 e8 0c             	shr    $0xc,%eax
  8011fb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801202:	f6 c2 01             	test   $0x1,%dl
  801205:	74 cd                	je     8011d4 <fork+0xb8>
			&& (uvpt[PGNUM(addr)] & PTE_U)) {
  801207:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80120e:	f6 c2 04             	test   $0x4,%dl
  801211:	74 c1                	je     8011d4 <fork+0xb8>
	void *addr = (void*) (pn*PGSIZE);
  801213:	89 c6                	mov    %eax,%esi
  801215:	c1 e6 0c             	shl    $0xc,%esi
    	if (uvpt[pn] & PTE_SHARE) {
  801218:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80121f:	f6 c6 04             	test   $0x4,%dh
  801222:	0f 85 5a ff ff ff    	jne    801182 <fork+0x66>
    	} else if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  801228:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80122f:	f6 c2 02             	test   $0x2,%dl
  801232:	0f 85 61 ff ff ff    	jne    801199 <fork+0x7d>
  801238:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80123f:	f6 c4 08             	test   $0x8,%ah
  801242:	0f 85 51 ff ff ff    	jne    801199 <fork+0x7d>
        		sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  801248:	83 ec 0c             	sub    $0xc,%esp
  80124b:	6a 05                	push   $0x5
  80124d:	56                   	push   %esi
  80124e:	57                   	push   %edi
  80124f:	56                   	push   %esi
  801250:	6a 00                	push   $0x0
  801252:	e8 15 fc ff ff       	call   800e6c <sys_page_map>
  801257:	83 c4 20             	add    $0x20,%esp
  80125a:	e9 75 ff ff ff       	jmp    8011d4 <fork+0xb8>
            		panic("sys_page_map：%e", r);
  80125f:	50                   	push   %eax
  801260:	68 22 29 80 00       	push   $0x802922
  801265:	6a 47                	push   $0x47
  801267:	68 dc 28 80 00       	push   $0x8028dc
  80126c:	e8 c5 f0 ff ff       	call   800336 <_panic>
            		panic("sys_page_map：%e", r);
  801271:	50                   	push   %eax
  801272:	68 22 29 80 00       	push   $0x802922
  801277:	6a 49                	push   $0x49
  801279:	68 dc 28 80 00       	push   $0x8028dc
  80127e:	e8 b3 f0 ff ff       	call   800336 <_panic>
			duppage(envid, PGNUM(addr));
		}

	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  801283:	83 ec 04             	sub    $0x4,%esp
  801286:	6a 07                	push   $0x7
  801288:	68 00 f0 bf ee       	push   $0xeebff000
  80128d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801290:	e8 94 fb ff ff       	call   800e29 <sys_page_alloc>
  801295:	83 c4 10             	add    $0x10,%esp
  801298:	85 c0                	test   %eax,%eax
  80129a:	78 2e                	js     8012ca <fork+0x1ae>
		panic("1");
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80129c:	83 ec 08             	sub    $0x8,%esp
  80129f:	68 78 20 80 00       	push   $0x802078
  8012a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012a7:	57                   	push   %edi
  8012a8:	e8 c7 fc ff ff       	call   800f74 <sys_env_set_pgfault_upcall>

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  8012ad:	83 c4 08             	add    $0x8,%esp
  8012b0:	6a 02                	push   $0x2
  8012b2:	57                   	push   %edi
  8012b3:	e8 38 fc ff ff       	call   800ef0 <sys_env_set_status>
  8012b8:	83 c4 10             	add    $0x10,%esp
  8012bb:	85 c0                	test   %eax,%eax
  8012bd:	78 1f                	js     8012de <fork+0x1c2>
		panic("sys_env_set_status");

	return envid;
	panic("fork not implemented");
}
  8012bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012c5:	5b                   	pop    %ebx
  8012c6:	5e                   	pop    %esi
  8012c7:	5f                   	pop    %edi
  8012c8:	5d                   	pop    %ebp
  8012c9:	c3                   	ret    
		panic("1");
  8012ca:	83 ec 04             	sub    $0x4,%esp
  8012cd:	68 34 29 80 00       	push   $0x802934
  8012d2:	6a 77                	push   $0x77
  8012d4:	68 dc 28 80 00       	push   $0x8028dc
  8012d9:	e8 58 f0 ff ff       	call   800336 <_panic>
		panic("sys_env_set_status");
  8012de:	83 ec 04             	sub    $0x4,%esp
  8012e1:	68 36 29 80 00       	push   $0x802936
  8012e6:	6a 7c                	push   $0x7c
  8012e8:	68 dc 28 80 00       	push   $0x8028dc
  8012ed:	e8 44 f0 ff ff       	call   800336 <_panic>

008012f2 <sfork>:

// Challenge!
int
sfork(void)
{
  8012f2:	55                   	push   %ebp
  8012f3:	89 e5                	mov    %esp,%ebp
  8012f5:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8012f8:	68 49 29 80 00       	push   $0x802949
  8012fd:	68 86 00 00 00       	push   $0x86
  801302:	68 dc 28 80 00       	push   $0x8028dc
  801307:	e8 2a f0 ff ff       	call   800336 <_panic>

0080130c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80130c:	55                   	push   %ebp
  80130d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80130f:	8b 45 08             	mov    0x8(%ebp),%eax
  801312:	05 00 00 00 30       	add    $0x30000000,%eax
  801317:	c1 e8 0c             	shr    $0xc,%eax
}
  80131a:	5d                   	pop    %ebp
  80131b:	c3                   	ret    

0080131c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80131c:	55                   	push   %ebp
  80131d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80131f:	8b 45 08             	mov    0x8(%ebp),%eax
  801322:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801327:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80132c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801331:	5d                   	pop    %ebp
  801332:	c3                   	ret    

00801333 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801333:	55                   	push   %ebp
  801334:	89 e5                	mov    %esp,%ebp
  801336:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801339:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80133e:	89 c2                	mov    %eax,%edx
  801340:	c1 ea 16             	shr    $0x16,%edx
  801343:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80134a:	f6 c2 01             	test   $0x1,%dl
  80134d:	74 2a                	je     801379 <fd_alloc+0x46>
  80134f:	89 c2                	mov    %eax,%edx
  801351:	c1 ea 0c             	shr    $0xc,%edx
  801354:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80135b:	f6 c2 01             	test   $0x1,%dl
  80135e:	74 19                	je     801379 <fd_alloc+0x46>
  801360:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801365:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80136a:	75 d2                	jne    80133e <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80136c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801372:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801377:	eb 07                	jmp    801380 <fd_alloc+0x4d>
			*fd_store = fd;
  801379:	89 01                	mov    %eax,(%ecx)
			return 0;
  80137b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801380:	5d                   	pop    %ebp
  801381:	c3                   	ret    

00801382 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801382:	55                   	push   %ebp
  801383:	89 e5                	mov    %esp,%ebp
  801385:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801388:	83 f8 1f             	cmp    $0x1f,%eax
  80138b:	77 36                	ja     8013c3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80138d:	c1 e0 0c             	shl    $0xc,%eax
  801390:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801395:	89 c2                	mov    %eax,%edx
  801397:	c1 ea 16             	shr    $0x16,%edx
  80139a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013a1:	f6 c2 01             	test   $0x1,%dl
  8013a4:	74 24                	je     8013ca <fd_lookup+0x48>
  8013a6:	89 c2                	mov    %eax,%edx
  8013a8:	c1 ea 0c             	shr    $0xc,%edx
  8013ab:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013b2:	f6 c2 01             	test   $0x1,%dl
  8013b5:	74 1a                	je     8013d1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013ba:	89 02                	mov    %eax,(%edx)
	return 0;
  8013bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013c1:	5d                   	pop    %ebp
  8013c2:	c3                   	ret    
		return -E_INVAL;
  8013c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013c8:	eb f7                	jmp    8013c1 <fd_lookup+0x3f>
		return -E_INVAL;
  8013ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013cf:	eb f0                	jmp    8013c1 <fd_lookup+0x3f>
  8013d1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013d6:	eb e9                	jmp    8013c1 <fd_lookup+0x3f>

008013d8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013d8:	55                   	push   %ebp
  8013d9:	89 e5                	mov    %esp,%ebp
  8013db:	83 ec 08             	sub    $0x8,%esp
  8013de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013e1:	ba dc 29 80 00       	mov    $0x8029dc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013e6:	b8 08 30 80 00       	mov    $0x803008,%eax
		if (devtab[i]->dev_id == dev_id) {
  8013eb:	39 08                	cmp    %ecx,(%eax)
  8013ed:	74 33                	je     801422 <dev_lookup+0x4a>
  8013ef:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  8013f2:	8b 02                	mov    (%edx),%eax
  8013f4:	85 c0                	test   %eax,%eax
  8013f6:	75 f3                	jne    8013eb <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013f8:	a1 04 40 80 00       	mov    0x804004,%eax
  8013fd:	8b 40 48             	mov    0x48(%eax),%eax
  801400:	83 ec 04             	sub    $0x4,%esp
  801403:	51                   	push   %ecx
  801404:	50                   	push   %eax
  801405:	68 60 29 80 00       	push   $0x802960
  80140a:	e8 02 f0 ff ff       	call   800411 <cprintf>
	*dev = 0;
  80140f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801412:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801418:	83 c4 10             	add    $0x10,%esp
  80141b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801420:	c9                   	leave  
  801421:	c3                   	ret    
			*dev = devtab[i];
  801422:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801425:	89 01                	mov    %eax,(%ecx)
			return 0;
  801427:	b8 00 00 00 00       	mov    $0x0,%eax
  80142c:	eb f2                	jmp    801420 <dev_lookup+0x48>

0080142e <fd_close>:
{
  80142e:	55                   	push   %ebp
  80142f:	89 e5                	mov    %esp,%ebp
  801431:	57                   	push   %edi
  801432:	56                   	push   %esi
  801433:	53                   	push   %ebx
  801434:	83 ec 1c             	sub    $0x1c,%esp
  801437:	8b 75 08             	mov    0x8(%ebp),%esi
  80143a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80143d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801440:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801441:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801447:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80144a:	50                   	push   %eax
  80144b:	e8 32 ff ff ff       	call   801382 <fd_lookup>
  801450:	89 c3                	mov    %eax,%ebx
  801452:	83 c4 08             	add    $0x8,%esp
  801455:	85 c0                	test   %eax,%eax
  801457:	78 05                	js     80145e <fd_close+0x30>
	    || fd != fd2)
  801459:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80145c:	74 16                	je     801474 <fd_close+0x46>
		return (must_exist ? r : 0);
  80145e:	89 f8                	mov    %edi,%eax
  801460:	84 c0                	test   %al,%al
  801462:	b8 00 00 00 00       	mov    $0x0,%eax
  801467:	0f 44 d8             	cmove  %eax,%ebx
}
  80146a:	89 d8                	mov    %ebx,%eax
  80146c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80146f:	5b                   	pop    %ebx
  801470:	5e                   	pop    %esi
  801471:	5f                   	pop    %edi
  801472:	5d                   	pop    %ebp
  801473:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801474:	83 ec 08             	sub    $0x8,%esp
  801477:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80147a:	50                   	push   %eax
  80147b:	ff 36                	pushl  (%esi)
  80147d:	e8 56 ff ff ff       	call   8013d8 <dev_lookup>
  801482:	89 c3                	mov    %eax,%ebx
  801484:	83 c4 10             	add    $0x10,%esp
  801487:	85 c0                	test   %eax,%eax
  801489:	78 15                	js     8014a0 <fd_close+0x72>
		if (dev->dev_close)
  80148b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80148e:	8b 40 10             	mov    0x10(%eax),%eax
  801491:	85 c0                	test   %eax,%eax
  801493:	74 1b                	je     8014b0 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  801495:	83 ec 0c             	sub    $0xc,%esp
  801498:	56                   	push   %esi
  801499:	ff d0                	call   *%eax
  80149b:	89 c3                	mov    %eax,%ebx
  80149d:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8014a0:	83 ec 08             	sub    $0x8,%esp
  8014a3:	56                   	push   %esi
  8014a4:	6a 00                	push   $0x0
  8014a6:	e8 03 fa ff ff       	call   800eae <sys_page_unmap>
	return r;
  8014ab:	83 c4 10             	add    $0x10,%esp
  8014ae:	eb ba                	jmp    80146a <fd_close+0x3c>
			r = 0;
  8014b0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014b5:	eb e9                	jmp    8014a0 <fd_close+0x72>

008014b7 <close>:

int
close(int fdnum)
{
  8014b7:	55                   	push   %ebp
  8014b8:	89 e5                	mov    %esp,%ebp
  8014ba:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c0:	50                   	push   %eax
  8014c1:	ff 75 08             	pushl  0x8(%ebp)
  8014c4:	e8 b9 fe ff ff       	call   801382 <fd_lookup>
  8014c9:	83 c4 08             	add    $0x8,%esp
  8014cc:	85 c0                	test   %eax,%eax
  8014ce:	78 10                	js     8014e0 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8014d0:	83 ec 08             	sub    $0x8,%esp
  8014d3:	6a 01                	push   $0x1
  8014d5:	ff 75 f4             	pushl  -0xc(%ebp)
  8014d8:	e8 51 ff ff ff       	call   80142e <fd_close>
  8014dd:	83 c4 10             	add    $0x10,%esp
}
  8014e0:	c9                   	leave  
  8014e1:	c3                   	ret    

008014e2 <close_all>:

void
close_all(void)
{
  8014e2:	55                   	push   %ebp
  8014e3:	89 e5                	mov    %esp,%ebp
  8014e5:	53                   	push   %ebx
  8014e6:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014e9:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014ee:	83 ec 0c             	sub    $0xc,%esp
  8014f1:	53                   	push   %ebx
  8014f2:	e8 c0 ff ff ff       	call   8014b7 <close>
	for (i = 0; i < MAXFD; i++)
  8014f7:	83 c3 01             	add    $0x1,%ebx
  8014fa:	83 c4 10             	add    $0x10,%esp
  8014fd:	83 fb 20             	cmp    $0x20,%ebx
  801500:	75 ec                	jne    8014ee <close_all+0xc>
}
  801502:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801505:	c9                   	leave  
  801506:	c3                   	ret    

00801507 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801507:	55                   	push   %ebp
  801508:	89 e5                	mov    %esp,%ebp
  80150a:	57                   	push   %edi
  80150b:	56                   	push   %esi
  80150c:	53                   	push   %ebx
  80150d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801510:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801513:	50                   	push   %eax
  801514:	ff 75 08             	pushl  0x8(%ebp)
  801517:	e8 66 fe ff ff       	call   801382 <fd_lookup>
  80151c:	89 c3                	mov    %eax,%ebx
  80151e:	83 c4 08             	add    $0x8,%esp
  801521:	85 c0                	test   %eax,%eax
  801523:	0f 88 81 00 00 00    	js     8015aa <dup+0xa3>
		return r;
	close(newfdnum);
  801529:	83 ec 0c             	sub    $0xc,%esp
  80152c:	ff 75 0c             	pushl  0xc(%ebp)
  80152f:	e8 83 ff ff ff       	call   8014b7 <close>

	newfd = INDEX2FD(newfdnum);
  801534:	8b 75 0c             	mov    0xc(%ebp),%esi
  801537:	c1 e6 0c             	shl    $0xc,%esi
  80153a:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801540:	83 c4 04             	add    $0x4,%esp
  801543:	ff 75 e4             	pushl  -0x1c(%ebp)
  801546:	e8 d1 fd ff ff       	call   80131c <fd2data>
  80154b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80154d:	89 34 24             	mov    %esi,(%esp)
  801550:	e8 c7 fd ff ff       	call   80131c <fd2data>
  801555:	83 c4 10             	add    $0x10,%esp
  801558:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80155a:	89 d8                	mov    %ebx,%eax
  80155c:	c1 e8 16             	shr    $0x16,%eax
  80155f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801566:	a8 01                	test   $0x1,%al
  801568:	74 11                	je     80157b <dup+0x74>
  80156a:	89 d8                	mov    %ebx,%eax
  80156c:	c1 e8 0c             	shr    $0xc,%eax
  80156f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801576:	f6 c2 01             	test   $0x1,%dl
  801579:	75 39                	jne    8015b4 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80157b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80157e:	89 d0                	mov    %edx,%eax
  801580:	c1 e8 0c             	shr    $0xc,%eax
  801583:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80158a:	83 ec 0c             	sub    $0xc,%esp
  80158d:	25 07 0e 00 00       	and    $0xe07,%eax
  801592:	50                   	push   %eax
  801593:	56                   	push   %esi
  801594:	6a 00                	push   $0x0
  801596:	52                   	push   %edx
  801597:	6a 00                	push   $0x0
  801599:	e8 ce f8 ff ff       	call   800e6c <sys_page_map>
  80159e:	89 c3                	mov    %eax,%ebx
  8015a0:	83 c4 20             	add    $0x20,%esp
  8015a3:	85 c0                	test   %eax,%eax
  8015a5:	78 31                	js     8015d8 <dup+0xd1>
		goto err;

	return newfdnum;
  8015a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8015aa:	89 d8                	mov    %ebx,%eax
  8015ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015af:	5b                   	pop    %ebx
  8015b0:	5e                   	pop    %esi
  8015b1:	5f                   	pop    %edi
  8015b2:	5d                   	pop    %ebp
  8015b3:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015b4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015bb:	83 ec 0c             	sub    $0xc,%esp
  8015be:	25 07 0e 00 00       	and    $0xe07,%eax
  8015c3:	50                   	push   %eax
  8015c4:	57                   	push   %edi
  8015c5:	6a 00                	push   $0x0
  8015c7:	53                   	push   %ebx
  8015c8:	6a 00                	push   $0x0
  8015ca:	e8 9d f8 ff ff       	call   800e6c <sys_page_map>
  8015cf:	89 c3                	mov    %eax,%ebx
  8015d1:	83 c4 20             	add    $0x20,%esp
  8015d4:	85 c0                	test   %eax,%eax
  8015d6:	79 a3                	jns    80157b <dup+0x74>
	sys_page_unmap(0, newfd);
  8015d8:	83 ec 08             	sub    $0x8,%esp
  8015db:	56                   	push   %esi
  8015dc:	6a 00                	push   $0x0
  8015de:	e8 cb f8 ff ff       	call   800eae <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015e3:	83 c4 08             	add    $0x8,%esp
  8015e6:	57                   	push   %edi
  8015e7:	6a 00                	push   $0x0
  8015e9:	e8 c0 f8 ff ff       	call   800eae <sys_page_unmap>
	return r;
  8015ee:	83 c4 10             	add    $0x10,%esp
  8015f1:	eb b7                	jmp    8015aa <dup+0xa3>

008015f3 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015f3:	55                   	push   %ebp
  8015f4:	89 e5                	mov    %esp,%ebp
  8015f6:	53                   	push   %ebx
  8015f7:	83 ec 14             	sub    $0x14,%esp
  8015fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015fd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801600:	50                   	push   %eax
  801601:	53                   	push   %ebx
  801602:	e8 7b fd ff ff       	call   801382 <fd_lookup>
  801607:	83 c4 08             	add    $0x8,%esp
  80160a:	85 c0                	test   %eax,%eax
  80160c:	78 3f                	js     80164d <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80160e:	83 ec 08             	sub    $0x8,%esp
  801611:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801614:	50                   	push   %eax
  801615:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801618:	ff 30                	pushl  (%eax)
  80161a:	e8 b9 fd ff ff       	call   8013d8 <dev_lookup>
  80161f:	83 c4 10             	add    $0x10,%esp
  801622:	85 c0                	test   %eax,%eax
  801624:	78 27                	js     80164d <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801626:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801629:	8b 42 08             	mov    0x8(%edx),%eax
  80162c:	83 e0 03             	and    $0x3,%eax
  80162f:	83 f8 01             	cmp    $0x1,%eax
  801632:	74 1e                	je     801652 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801634:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801637:	8b 40 08             	mov    0x8(%eax),%eax
  80163a:	85 c0                	test   %eax,%eax
  80163c:	74 35                	je     801673 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80163e:	83 ec 04             	sub    $0x4,%esp
  801641:	ff 75 10             	pushl  0x10(%ebp)
  801644:	ff 75 0c             	pushl  0xc(%ebp)
  801647:	52                   	push   %edx
  801648:	ff d0                	call   *%eax
  80164a:	83 c4 10             	add    $0x10,%esp
}
  80164d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801650:	c9                   	leave  
  801651:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801652:	a1 04 40 80 00       	mov    0x804004,%eax
  801657:	8b 40 48             	mov    0x48(%eax),%eax
  80165a:	83 ec 04             	sub    $0x4,%esp
  80165d:	53                   	push   %ebx
  80165e:	50                   	push   %eax
  80165f:	68 a1 29 80 00       	push   $0x8029a1
  801664:	e8 a8 ed ff ff       	call   800411 <cprintf>
		return -E_INVAL;
  801669:	83 c4 10             	add    $0x10,%esp
  80166c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801671:	eb da                	jmp    80164d <read+0x5a>
		return -E_NOT_SUPP;
  801673:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801678:	eb d3                	jmp    80164d <read+0x5a>

0080167a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80167a:	55                   	push   %ebp
  80167b:	89 e5                	mov    %esp,%ebp
  80167d:	57                   	push   %edi
  80167e:	56                   	push   %esi
  80167f:	53                   	push   %ebx
  801680:	83 ec 0c             	sub    $0xc,%esp
  801683:	8b 7d 08             	mov    0x8(%ebp),%edi
  801686:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801689:	bb 00 00 00 00       	mov    $0x0,%ebx
  80168e:	39 f3                	cmp    %esi,%ebx
  801690:	73 25                	jae    8016b7 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801692:	83 ec 04             	sub    $0x4,%esp
  801695:	89 f0                	mov    %esi,%eax
  801697:	29 d8                	sub    %ebx,%eax
  801699:	50                   	push   %eax
  80169a:	89 d8                	mov    %ebx,%eax
  80169c:	03 45 0c             	add    0xc(%ebp),%eax
  80169f:	50                   	push   %eax
  8016a0:	57                   	push   %edi
  8016a1:	e8 4d ff ff ff       	call   8015f3 <read>
		if (m < 0)
  8016a6:	83 c4 10             	add    $0x10,%esp
  8016a9:	85 c0                	test   %eax,%eax
  8016ab:	78 08                	js     8016b5 <readn+0x3b>
			return m;
		if (m == 0)
  8016ad:	85 c0                	test   %eax,%eax
  8016af:	74 06                	je     8016b7 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  8016b1:	01 c3                	add    %eax,%ebx
  8016b3:	eb d9                	jmp    80168e <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8016b5:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8016b7:	89 d8                	mov    %ebx,%eax
  8016b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016bc:	5b                   	pop    %ebx
  8016bd:	5e                   	pop    %esi
  8016be:	5f                   	pop    %edi
  8016bf:	5d                   	pop    %ebp
  8016c0:	c3                   	ret    

008016c1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016c1:	55                   	push   %ebp
  8016c2:	89 e5                	mov    %esp,%ebp
  8016c4:	53                   	push   %ebx
  8016c5:	83 ec 14             	sub    $0x14,%esp
  8016c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016cb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016ce:	50                   	push   %eax
  8016cf:	53                   	push   %ebx
  8016d0:	e8 ad fc ff ff       	call   801382 <fd_lookup>
  8016d5:	83 c4 08             	add    $0x8,%esp
  8016d8:	85 c0                	test   %eax,%eax
  8016da:	78 3a                	js     801716 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016dc:	83 ec 08             	sub    $0x8,%esp
  8016df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e2:	50                   	push   %eax
  8016e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e6:	ff 30                	pushl  (%eax)
  8016e8:	e8 eb fc ff ff       	call   8013d8 <dev_lookup>
  8016ed:	83 c4 10             	add    $0x10,%esp
  8016f0:	85 c0                	test   %eax,%eax
  8016f2:	78 22                	js     801716 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016fb:	74 1e                	je     80171b <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801700:	8b 52 0c             	mov    0xc(%edx),%edx
  801703:	85 d2                	test   %edx,%edx
  801705:	74 35                	je     80173c <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801707:	83 ec 04             	sub    $0x4,%esp
  80170a:	ff 75 10             	pushl  0x10(%ebp)
  80170d:	ff 75 0c             	pushl  0xc(%ebp)
  801710:	50                   	push   %eax
  801711:	ff d2                	call   *%edx
  801713:	83 c4 10             	add    $0x10,%esp
}
  801716:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801719:	c9                   	leave  
  80171a:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80171b:	a1 04 40 80 00       	mov    0x804004,%eax
  801720:	8b 40 48             	mov    0x48(%eax),%eax
  801723:	83 ec 04             	sub    $0x4,%esp
  801726:	53                   	push   %ebx
  801727:	50                   	push   %eax
  801728:	68 bd 29 80 00       	push   $0x8029bd
  80172d:	e8 df ec ff ff       	call   800411 <cprintf>
		return -E_INVAL;
  801732:	83 c4 10             	add    $0x10,%esp
  801735:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80173a:	eb da                	jmp    801716 <write+0x55>
		return -E_NOT_SUPP;
  80173c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801741:	eb d3                	jmp    801716 <write+0x55>

00801743 <seek>:

int
seek(int fdnum, off_t offset)
{
  801743:	55                   	push   %ebp
  801744:	89 e5                	mov    %esp,%ebp
  801746:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801749:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80174c:	50                   	push   %eax
  80174d:	ff 75 08             	pushl  0x8(%ebp)
  801750:	e8 2d fc ff ff       	call   801382 <fd_lookup>
  801755:	83 c4 08             	add    $0x8,%esp
  801758:	85 c0                	test   %eax,%eax
  80175a:	78 0e                	js     80176a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80175c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80175f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801762:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801765:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80176a:	c9                   	leave  
  80176b:	c3                   	ret    

0080176c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80176c:	55                   	push   %ebp
  80176d:	89 e5                	mov    %esp,%ebp
  80176f:	53                   	push   %ebx
  801770:	83 ec 14             	sub    $0x14,%esp
  801773:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801776:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801779:	50                   	push   %eax
  80177a:	53                   	push   %ebx
  80177b:	e8 02 fc ff ff       	call   801382 <fd_lookup>
  801780:	83 c4 08             	add    $0x8,%esp
  801783:	85 c0                	test   %eax,%eax
  801785:	78 37                	js     8017be <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801787:	83 ec 08             	sub    $0x8,%esp
  80178a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80178d:	50                   	push   %eax
  80178e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801791:	ff 30                	pushl  (%eax)
  801793:	e8 40 fc ff ff       	call   8013d8 <dev_lookup>
  801798:	83 c4 10             	add    $0x10,%esp
  80179b:	85 c0                	test   %eax,%eax
  80179d:	78 1f                	js     8017be <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80179f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017a6:	74 1b                	je     8017c3 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8017a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017ab:	8b 52 18             	mov    0x18(%edx),%edx
  8017ae:	85 d2                	test   %edx,%edx
  8017b0:	74 32                	je     8017e4 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017b2:	83 ec 08             	sub    $0x8,%esp
  8017b5:	ff 75 0c             	pushl  0xc(%ebp)
  8017b8:	50                   	push   %eax
  8017b9:	ff d2                	call   *%edx
  8017bb:	83 c4 10             	add    $0x10,%esp
}
  8017be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017c1:	c9                   	leave  
  8017c2:	c3                   	ret    
			thisenv->env_id, fdnum);
  8017c3:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017c8:	8b 40 48             	mov    0x48(%eax),%eax
  8017cb:	83 ec 04             	sub    $0x4,%esp
  8017ce:	53                   	push   %ebx
  8017cf:	50                   	push   %eax
  8017d0:	68 80 29 80 00       	push   $0x802980
  8017d5:	e8 37 ec ff ff       	call   800411 <cprintf>
		return -E_INVAL;
  8017da:	83 c4 10             	add    $0x10,%esp
  8017dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017e2:	eb da                	jmp    8017be <ftruncate+0x52>
		return -E_NOT_SUPP;
  8017e4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017e9:	eb d3                	jmp    8017be <ftruncate+0x52>

008017eb <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017eb:	55                   	push   %ebp
  8017ec:	89 e5                	mov    %esp,%ebp
  8017ee:	53                   	push   %ebx
  8017ef:	83 ec 14             	sub    $0x14,%esp
  8017f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017f5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017f8:	50                   	push   %eax
  8017f9:	ff 75 08             	pushl  0x8(%ebp)
  8017fc:	e8 81 fb ff ff       	call   801382 <fd_lookup>
  801801:	83 c4 08             	add    $0x8,%esp
  801804:	85 c0                	test   %eax,%eax
  801806:	78 4b                	js     801853 <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801808:	83 ec 08             	sub    $0x8,%esp
  80180b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80180e:	50                   	push   %eax
  80180f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801812:	ff 30                	pushl  (%eax)
  801814:	e8 bf fb ff ff       	call   8013d8 <dev_lookup>
  801819:	83 c4 10             	add    $0x10,%esp
  80181c:	85 c0                	test   %eax,%eax
  80181e:	78 33                	js     801853 <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  801820:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801823:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801827:	74 2f                	je     801858 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801829:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80182c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801833:	00 00 00 
	stat->st_isdir = 0;
  801836:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80183d:	00 00 00 
	stat->st_dev = dev;
  801840:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801846:	83 ec 08             	sub    $0x8,%esp
  801849:	53                   	push   %ebx
  80184a:	ff 75 f0             	pushl  -0x10(%ebp)
  80184d:	ff 50 14             	call   *0x14(%eax)
  801850:	83 c4 10             	add    $0x10,%esp
}
  801853:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801856:	c9                   	leave  
  801857:	c3                   	ret    
		return -E_NOT_SUPP;
  801858:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80185d:	eb f4                	jmp    801853 <fstat+0x68>

0080185f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80185f:	55                   	push   %ebp
  801860:	89 e5                	mov    %esp,%ebp
  801862:	56                   	push   %esi
  801863:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801864:	83 ec 08             	sub    $0x8,%esp
  801867:	6a 00                	push   $0x0
  801869:	ff 75 08             	pushl  0x8(%ebp)
  80186c:	e8 da 01 00 00       	call   801a4b <open>
  801871:	89 c3                	mov    %eax,%ebx
  801873:	83 c4 10             	add    $0x10,%esp
  801876:	85 c0                	test   %eax,%eax
  801878:	78 1b                	js     801895 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80187a:	83 ec 08             	sub    $0x8,%esp
  80187d:	ff 75 0c             	pushl  0xc(%ebp)
  801880:	50                   	push   %eax
  801881:	e8 65 ff ff ff       	call   8017eb <fstat>
  801886:	89 c6                	mov    %eax,%esi
	close(fd);
  801888:	89 1c 24             	mov    %ebx,(%esp)
  80188b:	e8 27 fc ff ff       	call   8014b7 <close>
	return r;
  801890:	83 c4 10             	add    $0x10,%esp
  801893:	89 f3                	mov    %esi,%ebx
}
  801895:	89 d8                	mov    %ebx,%eax
  801897:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80189a:	5b                   	pop    %ebx
  80189b:	5e                   	pop    %esi
  80189c:	5d                   	pop    %ebp
  80189d:	c3                   	ret    

0080189e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80189e:	55                   	push   %ebp
  80189f:	89 e5                	mov    %esp,%ebp
  8018a1:	56                   	push   %esi
  8018a2:	53                   	push   %ebx
  8018a3:	89 c6                	mov    %eax,%esi
  8018a5:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8018a7:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8018ae:	74 27                	je     8018d7 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018b0:	6a 07                	push   $0x7
  8018b2:	68 00 50 80 00       	push   $0x805000
  8018b7:	56                   	push   %esi
  8018b8:	ff 35 00 40 80 00    	pushl  0x804000
  8018be:	e8 42 08 00 00       	call   802105 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018c3:	83 c4 0c             	add    $0xc,%esp
  8018c6:	6a 00                	push   $0x0
  8018c8:	53                   	push   %ebx
  8018c9:	6a 00                	push   $0x0
  8018cb:	e8 ce 07 00 00       	call   80209e <ipc_recv>
}
  8018d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018d3:	5b                   	pop    %ebx
  8018d4:	5e                   	pop    %esi
  8018d5:	5d                   	pop    %ebp
  8018d6:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018d7:	83 ec 0c             	sub    $0xc,%esp
  8018da:	6a 01                	push   $0x1
  8018dc:	e8 78 08 00 00       	call   802159 <ipc_find_env>
  8018e1:	a3 00 40 80 00       	mov    %eax,0x804000
  8018e6:	83 c4 10             	add    $0x10,%esp
  8018e9:	eb c5                	jmp    8018b0 <fsipc+0x12>

008018eb <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018eb:	55                   	push   %ebp
  8018ec:	89 e5                	mov    %esp,%ebp
  8018ee:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f4:	8b 40 0c             	mov    0xc(%eax),%eax
  8018f7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018ff:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801904:	ba 00 00 00 00       	mov    $0x0,%edx
  801909:	b8 02 00 00 00       	mov    $0x2,%eax
  80190e:	e8 8b ff ff ff       	call   80189e <fsipc>
}
  801913:	c9                   	leave  
  801914:	c3                   	ret    

00801915 <devfile_flush>:
{
  801915:	55                   	push   %ebp
  801916:	89 e5                	mov    %esp,%ebp
  801918:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80191b:	8b 45 08             	mov    0x8(%ebp),%eax
  80191e:	8b 40 0c             	mov    0xc(%eax),%eax
  801921:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801926:	ba 00 00 00 00       	mov    $0x0,%edx
  80192b:	b8 06 00 00 00       	mov    $0x6,%eax
  801930:	e8 69 ff ff ff       	call   80189e <fsipc>
}
  801935:	c9                   	leave  
  801936:	c3                   	ret    

00801937 <devfile_stat>:
{
  801937:	55                   	push   %ebp
  801938:	89 e5                	mov    %esp,%ebp
  80193a:	53                   	push   %ebx
  80193b:	83 ec 04             	sub    $0x4,%esp
  80193e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801941:	8b 45 08             	mov    0x8(%ebp),%eax
  801944:	8b 40 0c             	mov    0xc(%eax),%eax
  801947:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80194c:	ba 00 00 00 00       	mov    $0x0,%edx
  801951:	b8 05 00 00 00       	mov    $0x5,%eax
  801956:	e8 43 ff ff ff       	call   80189e <fsipc>
  80195b:	85 c0                	test   %eax,%eax
  80195d:	78 2c                	js     80198b <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80195f:	83 ec 08             	sub    $0x8,%esp
  801962:	68 00 50 80 00       	push   $0x805000
  801967:	53                   	push   %ebx
  801968:	e8 c3 f0 ff ff       	call   800a30 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80196d:	a1 80 50 80 00       	mov    0x805080,%eax
  801972:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801978:	a1 84 50 80 00       	mov    0x805084,%eax
  80197d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801983:	83 c4 10             	add    $0x10,%esp
  801986:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80198b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80198e:	c9                   	leave  
  80198f:	c3                   	ret    

00801990 <devfile_write>:
{
  801990:	55                   	push   %ebp
  801991:	89 e5                	mov    %esp,%ebp
  801993:	83 ec 0c             	sub    $0xc,%esp
  801996:	8b 45 10             	mov    0x10(%ebp),%eax
    	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801999:	8b 55 08             	mov    0x8(%ebp),%edx
  80199c:	8b 52 0c             	mov    0xc(%edx),%edx
  80199f:	89 15 00 50 80 00    	mov    %edx,0x805000
    	fsipcbuf.write.req_n = n;
  8019a5:	a3 04 50 80 00       	mov    %eax,0x805004
    	memmove(fsipcbuf.write.req_buf, buf, n);
  8019aa:	50                   	push   %eax
  8019ab:	ff 75 0c             	pushl  0xc(%ebp)
  8019ae:	68 08 50 80 00       	push   $0x805008
  8019b3:	e8 06 f2 ff ff       	call   800bbe <memmove>
    	return fsipc(FSREQ_WRITE, NULL);
  8019b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8019bd:	b8 04 00 00 00       	mov    $0x4,%eax
  8019c2:	e8 d7 fe ff ff       	call   80189e <fsipc>
}
  8019c7:	c9                   	leave  
  8019c8:	c3                   	ret    

008019c9 <devfile_read>:
{
  8019c9:	55                   	push   %ebp
  8019ca:	89 e5                	mov    %esp,%ebp
  8019cc:	56                   	push   %esi
  8019cd:	53                   	push   %ebx
  8019ce:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d4:	8b 40 0c             	mov    0xc(%eax),%eax
  8019d7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019dc:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8019e7:	b8 03 00 00 00       	mov    $0x3,%eax
  8019ec:	e8 ad fe ff ff       	call   80189e <fsipc>
  8019f1:	89 c3                	mov    %eax,%ebx
  8019f3:	85 c0                	test   %eax,%eax
  8019f5:	78 1f                	js     801a16 <devfile_read+0x4d>
	assert(r <= n);
  8019f7:	39 f0                	cmp    %esi,%eax
  8019f9:	77 24                	ja     801a1f <devfile_read+0x56>
	assert(r <= PGSIZE);
  8019fb:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a00:	7f 33                	jg     801a35 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a02:	83 ec 04             	sub    $0x4,%esp
  801a05:	50                   	push   %eax
  801a06:	68 00 50 80 00       	push   $0x805000
  801a0b:	ff 75 0c             	pushl  0xc(%ebp)
  801a0e:	e8 ab f1 ff ff       	call   800bbe <memmove>
	return r;
  801a13:	83 c4 10             	add    $0x10,%esp
}
  801a16:	89 d8                	mov    %ebx,%eax
  801a18:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a1b:	5b                   	pop    %ebx
  801a1c:	5e                   	pop    %esi
  801a1d:	5d                   	pop    %ebp
  801a1e:	c3                   	ret    
	assert(r <= n);
  801a1f:	68 ec 29 80 00       	push   $0x8029ec
  801a24:	68 f3 29 80 00       	push   $0x8029f3
  801a29:	6a 7c                	push   $0x7c
  801a2b:	68 08 2a 80 00       	push   $0x802a08
  801a30:	e8 01 e9 ff ff       	call   800336 <_panic>
	assert(r <= PGSIZE);
  801a35:	68 13 2a 80 00       	push   $0x802a13
  801a3a:	68 f3 29 80 00       	push   $0x8029f3
  801a3f:	6a 7d                	push   $0x7d
  801a41:	68 08 2a 80 00       	push   $0x802a08
  801a46:	e8 eb e8 ff ff       	call   800336 <_panic>

00801a4b <open>:
{
  801a4b:	55                   	push   %ebp
  801a4c:	89 e5                	mov    %esp,%ebp
  801a4e:	56                   	push   %esi
  801a4f:	53                   	push   %ebx
  801a50:	83 ec 1c             	sub    $0x1c,%esp
  801a53:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801a56:	56                   	push   %esi
  801a57:	e8 9d ef ff ff       	call   8009f9 <strlen>
  801a5c:	83 c4 10             	add    $0x10,%esp
  801a5f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a64:	7f 6c                	jg     801ad2 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801a66:	83 ec 0c             	sub    $0xc,%esp
  801a69:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a6c:	50                   	push   %eax
  801a6d:	e8 c1 f8 ff ff       	call   801333 <fd_alloc>
  801a72:	89 c3                	mov    %eax,%ebx
  801a74:	83 c4 10             	add    $0x10,%esp
  801a77:	85 c0                	test   %eax,%eax
  801a79:	78 3c                	js     801ab7 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801a7b:	83 ec 08             	sub    $0x8,%esp
  801a7e:	56                   	push   %esi
  801a7f:	68 00 50 80 00       	push   $0x805000
  801a84:	e8 a7 ef ff ff       	call   800a30 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a89:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a8c:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a91:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a94:	b8 01 00 00 00       	mov    $0x1,%eax
  801a99:	e8 00 fe ff ff       	call   80189e <fsipc>
  801a9e:	89 c3                	mov    %eax,%ebx
  801aa0:	83 c4 10             	add    $0x10,%esp
  801aa3:	85 c0                	test   %eax,%eax
  801aa5:	78 19                	js     801ac0 <open+0x75>
	return fd2num(fd);
  801aa7:	83 ec 0c             	sub    $0xc,%esp
  801aaa:	ff 75 f4             	pushl  -0xc(%ebp)
  801aad:	e8 5a f8 ff ff       	call   80130c <fd2num>
  801ab2:	89 c3                	mov    %eax,%ebx
  801ab4:	83 c4 10             	add    $0x10,%esp
}
  801ab7:	89 d8                	mov    %ebx,%eax
  801ab9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801abc:	5b                   	pop    %ebx
  801abd:	5e                   	pop    %esi
  801abe:	5d                   	pop    %ebp
  801abf:	c3                   	ret    
		fd_close(fd, 0);
  801ac0:	83 ec 08             	sub    $0x8,%esp
  801ac3:	6a 00                	push   $0x0
  801ac5:	ff 75 f4             	pushl  -0xc(%ebp)
  801ac8:	e8 61 f9 ff ff       	call   80142e <fd_close>
		return r;
  801acd:	83 c4 10             	add    $0x10,%esp
  801ad0:	eb e5                	jmp    801ab7 <open+0x6c>
		return -E_BAD_PATH;
  801ad2:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801ad7:	eb de                	jmp    801ab7 <open+0x6c>

00801ad9 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801ad9:	55                   	push   %ebp
  801ada:	89 e5                	mov    %esp,%ebp
  801adc:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801adf:	ba 00 00 00 00       	mov    $0x0,%edx
  801ae4:	b8 08 00 00 00       	mov    $0x8,%eax
  801ae9:	e8 b0 fd ff ff       	call   80189e <fsipc>
}
  801aee:	c9                   	leave  
  801aef:	c3                   	ret    

00801af0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801af0:	55                   	push   %ebp
  801af1:	89 e5                	mov    %esp,%ebp
  801af3:	56                   	push   %esi
  801af4:	53                   	push   %ebx
  801af5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801af8:	83 ec 0c             	sub    $0xc,%esp
  801afb:	ff 75 08             	pushl  0x8(%ebp)
  801afe:	e8 19 f8 ff ff       	call   80131c <fd2data>
  801b03:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b05:	83 c4 08             	add    $0x8,%esp
  801b08:	68 1f 2a 80 00       	push   $0x802a1f
  801b0d:	53                   	push   %ebx
  801b0e:	e8 1d ef ff ff       	call   800a30 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b13:	8b 46 04             	mov    0x4(%esi),%eax
  801b16:	2b 06                	sub    (%esi),%eax
  801b18:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b1e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b25:	00 00 00 
	stat->st_dev = &devpipe;
  801b28:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801b2f:	30 80 00 
	return 0;
}
  801b32:	b8 00 00 00 00       	mov    $0x0,%eax
  801b37:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b3a:	5b                   	pop    %ebx
  801b3b:	5e                   	pop    %esi
  801b3c:	5d                   	pop    %ebp
  801b3d:	c3                   	ret    

00801b3e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b3e:	55                   	push   %ebp
  801b3f:	89 e5                	mov    %esp,%ebp
  801b41:	53                   	push   %ebx
  801b42:	83 ec 0c             	sub    $0xc,%esp
  801b45:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b48:	53                   	push   %ebx
  801b49:	6a 00                	push   $0x0
  801b4b:	e8 5e f3 ff ff       	call   800eae <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b50:	89 1c 24             	mov    %ebx,(%esp)
  801b53:	e8 c4 f7 ff ff       	call   80131c <fd2data>
  801b58:	83 c4 08             	add    $0x8,%esp
  801b5b:	50                   	push   %eax
  801b5c:	6a 00                	push   $0x0
  801b5e:	e8 4b f3 ff ff       	call   800eae <sys_page_unmap>
}
  801b63:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b66:	c9                   	leave  
  801b67:	c3                   	ret    

00801b68 <_pipeisclosed>:
{
  801b68:	55                   	push   %ebp
  801b69:	89 e5                	mov    %esp,%ebp
  801b6b:	57                   	push   %edi
  801b6c:	56                   	push   %esi
  801b6d:	53                   	push   %ebx
  801b6e:	83 ec 1c             	sub    $0x1c,%esp
  801b71:	89 c7                	mov    %eax,%edi
  801b73:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801b75:	a1 04 40 80 00       	mov    0x804004,%eax
  801b7a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801b7d:	83 ec 0c             	sub    $0xc,%esp
  801b80:	57                   	push   %edi
  801b81:	e8 0c 06 00 00       	call   802192 <pageref>
  801b86:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801b89:	89 34 24             	mov    %esi,(%esp)
  801b8c:	e8 01 06 00 00       	call   802192 <pageref>
		nn = thisenv->env_runs;
  801b91:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b97:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b9a:	83 c4 10             	add    $0x10,%esp
  801b9d:	39 cb                	cmp    %ecx,%ebx
  801b9f:	74 1b                	je     801bbc <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801ba1:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801ba4:	75 cf                	jne    801b75 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ba6:	8b 42 58             	mov    0x58(%edx),%eax
  801ba9:	6a 01                	push   $0x1
  801bab:	50                   	push   %eax
  801bac:	53                   	push   %ebx
  801bad:	68 26 2a 80 00       	push   $0x802a26
  801bb2:	e8 5a e8 ff ff       	call   800411 <cprintf>
  801bb7:	83 c4 10             	add    $0x10,%esp
  801bba:	eb b9                	jmp    801b75 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801bbc:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801bbf:	0f 94 c0             	sete   %al
  801bc2:	0f b6 c0             	movzbl %al,%eax
}
  801bc5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bc8:	5b                   	pop    %ebx
  801bc9:	5e                   	pop    %esi
  801bca:	5f                   	pop    %edi
  801bcb:	5d                   	pop    %ebp
  801bcc:	c3                   	ret    

00801bcd <devpipe_write>:
{
  801bcd:	55                   	push   %ebp
  801bce:	89 e5                	mov    %esp,%ebp
  801bd0:	57                   	push   %edi
  801bd1:	56                   	push   %esi
  801bd2:	53                   	push   %ebx
  801bd3:	83 ec 28             	sub    $0x28,%esp
  801bd6:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801bd9:	56                   	push   %esi
  801bda:	e8 3d f7 ff ff       	call   80131c <fd2data>
  801bdf:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801be1:	83 c4 10             	add    $0x10,%esp
  801be4:	bf 00 00 00 00       	mov    $0x0,%edi
  801be9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801bec:	74 4f                	je     801c3d <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bee:	8b 43 04             	mov    0x4(%ebx),%eax
  801bf1:	8b 0b                	mov    (%ebx),%ecx
  801bf3:	8d 51 20             	lea    0x20(%ecx),%edx
  801bf6:	39 d0                	cmp    %edx,%eax
  801bf8:	72 14                	jb     801c0e <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801bfa:	89 da                	mov    %ebx,%edx
  801bfc:	89 f0                	mov    %esi,%eax
  801bfe:	e8 65 ff ff ff       	call   801b68 <_pipeisclosed>
  801c03:	85 c0                	test   %eax,%eax
  801c05:	75 3a                	jne    801c41 <devpipe_write+0x74>
			sys_yield();
  801c07:	e8 fe f1 ff ff       	call   800e0a <sys_yield>
  801c0c:	eb e0                	jmp    801bee <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c11:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c15:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c18:	89 c2                	mov    %eax,%edx
  801c1a:	c1 fa 1f             	sar    $0x1f,%edx
  801c1d:	89 d1                	mov    %edx,%ecx
  801c1f:	c1 e9 1b             	shr    $0x1b,%ecx
  801c22:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c25:	83 e2 1f             	and    $0x1f,%edx
  801c28:	29 ca                	sub    %ecx,%edx
  801c2a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c2e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c32:	83 c0 01             	add    $0x1,%eax
  801c35:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801c38:	83 c7 01             	add    $0x1,%edi
  801c3b:	eb ac                	jmp    801be9 <devpipe_write+0x1c>
	return i;
  801c3d:	89 f8                	mov    %edi,%eax
  801c3f:	eb 05                	jmp    801c46 <devpipe_write+0x79>
				return 0;
  801c41:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c46:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c49:	5b                   	pop    %ebx
  801c4a:	5e                   	pop    %esi
  801c4b:	5f                   	pop    %edi
  801c4c:	5d                   	pop    %ebp
  801c4d:	c3                   	ret    

00801c4e <devpipe_read>:
{
  801c4e:	55                   	push   %ebp
  801c4f:	89 e5                	mov    %esp,%ebp
  801c51:	57                   	push   %edi
  801c52:	56                   	push   %esi
  801c53:	53                   	push   %ebx
  801c54:	83 ec 18             	sub    $0x18,%esp
  801c57:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801c5a:	57                   	push   %edi
  801c5b:	e8 bc f6 ff ff       	call   80131c <fd2data>
  801c60:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c62:	83 c4 10             	add    $0x10,%esp
  801c65:	be 00 00 00 00       	mov    $0x0,%esi
  801c6a:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c6d:	74 47                	je     801cb6 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801c6f:	8b 03                	mov    (%ebx),%eax
  801c71:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c74:	75 22                	jne    801c98 <devpipe_read+0x4a>
			if (i > 0)
  801c76:	85 f6                	test   %esi,%esi
  801c78:	75 14                	jne    801c8e <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801c7a:	89 da                	mov    %ebx,%edx
  801c7c:	89 f8                	mov    %edi,%eax
  801c7e:	e8 e5 fe ff ff       	call   801b68 <_pipeisclosed>
  801c83:	85 c0                	test   %eax,%eax
  801c85:	75 33                	jne    801cba <devpipe_read+0x6c>
			sys_yield();
  801c87:	e8 7e f1 ff ff       	call   800e0a <sys_yield>
  801c8c:	eb e1                	jmp    801c6f <devpipe_read+0x21>
				return i;
  801c8e:	89 f0                	mov    %esi,%eax
}
  801c90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c93:	5b                   	pop    %ebx
  801c94:	5e                   	pop    %esi
  801c95:	5f                   	pop    %edi
  801c96:	5d                   	pop    %ebp
  801c97:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c98:	99                   	cltd   
  801c99:	c1 ea 1b             	shr    $0x1b,%edx
  801c9c:	01 d0                	add    %edx,%eax
  801c9e:	83 e0 1f             	and    $0x1f,%eax
  801ca1:	29 d0                	sub    %edx,%eax
  801ca3:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801ca8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cab:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801cae:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801cb1:	83 c6 01             	add    $0x1,%esi
  801cb4:	eb b4                	jmp    801c6a <devpipe_read+0x1c>
	return i;
  801cb6:	89 f0                	mov    %esi,%eax
  801cb8:	eb d6                	jmp    801c90 <devpipe_read+0x42>
				return 0;
  801cba:	b8 00 00 00 00       	mov    $0x0,%eax
  801cbf:	eb cf                	jmp    801c90 <devpipe_read+0x42>

00801cc1 <pipe>:
{
  801cc1:	55                   	push   %ebp
  801cc2:	89 e5                	mov    %esp,%ebp
  801cc4:	56                   	push   %esi
  801cc5:	53                   	push   %ebx
  801cc6:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801cc9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ccc:	50                   	push   %eax
  801ccd:	e8 61 f6 ff ff       	call   801333 <fd_alloc>
  801cd2:	89 c3                	mov    %eax,%ebx
  801cd4:	83 c4 10             	add    $0x10,%esp
  801cd7:	85 c0                	test   %eax,%eax
  801cd9:	78 5b                	js     801d36 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cdb:	83 ec 04             	sub    $0x4,%esp
  801cde:	68 07 04 00 00       	push   $0x407
  801ce3:	ff 75 f4             	pushl  -0xc(%ebp)
  801ce6:	6a 00                	push   $0x0
  801ce8:	e8 3c f1 ff ff       	call   800e29 <sys_page_alloc>
  801ced:	89 c3                	mov    %eax,%ebx
  801cef:	83 c4 10             	add    $0x10,%esp
  801cf2:	85 c0                	test   %eax,%eax
  801cf4:	78 40                	js     801d36 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  801cf6:	83 ec 0c             	sub    $0xc,%esp
  801cf9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cfc:	50                   	push   %eax
  801cfd:	e8 31 f6 ff ff       	call   801333 <fd_alloc>
  801d02:	89 c3                	mov    %eax,%ebx
  801d04:	83 c4 10             	add    $0x10,%esp
  801d07:	85 c0                	test   %eax,%eax
  801d09:	78 1b                	js     801d26 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d0b:	83 ec 04             	sub    $0x4,%esp
  801d0e:	68 07 04 00 00       	push   $0x407
  801d13:	ff 75 f0             	pushl  -0x10(%ebp)
  801d16:	6a 00                	push   $0x0
  801d18:	e8 0c f1 ff ff       	call   800e29 <sys_page_alloc>
  801d1d:	89 c3                	mov    %eax,%ebx
  801d1f:	83 c4 10             	add    $0x10,%esp
  801d22:	85 c0                	test   %eax,%eax
  801d24:	79 19                	jns    801d3f <pipe+0x7e>
	sys_page_unmap(0, fd0);
  801d26:	83 ec 08             	sub    $0x8,%esp
  801d29:	ff 75 f4             	pushl  -0xc(%ebp)
  801d2c:	6a 00                	push   $0x0
  801d2e:	e8 7b f1 ff ff       	call   800eae <sys_page_unmap>
  801d33:	83 c4 10             	add    $0x10,%esp
}
  801d36:	89 d8                	mov    %ebx,%eax
  801d38:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d3b:	5b                   	pop    %ebx
  801d3c:	5e                   	pop    %esi
  801d3d:	5d                   	pop    %ebp
  801d3e:	c3                   	ret    
	va = fd2data(fd0);
  801d3f:	83 ec 0c             	sub    $0xc,%esp
  801d42:	ff 75 f4             	pushl  -0xc(%ebp)
  801d45:	e8 d2 f5 ff ff       	call   80131c <fd2data>
  801d4a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d4c:	83 c4 0c             	add    $0xc,%esp
  801d4f:	68 07 04 00 00       	push   $0x407
  801d54:	50                   	push   %eax
  801d55:	6a 00                	push   $0x0
  801d57:	e8 cd f0 ff ff       	call   800e29 <sys_page_alloc>
  801d5c:	89 c3                	mov    %eax,%ebx
  801d5e:	83 c4 10             	add    $0x10,%esp
  801d61:	85 c0                	test   %eax,%eax
  801d63:	0f 88 8c 00 00 00    	js     801df5 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d69:	83 ec 0c             	sub    $0xc,%esp
  801d6c:	ff 75 f0             	pushl  -0x10(%ebp)
  801d6f:	e8 a8 f5 ff ff       	call   80131c <fd2data>
  801d74:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d7b:	50                   	push   %eax
  801d7c:	6a 00                	push   $0x0
  801d7e:	56                   	push   %esi
  801d7f:	6a 00                	push   $0x0
  801d81:	e8 e6 f0 ff ff       	call   800e6c <sys_page_map>
  801d86:	89 c3                	mov    %eax,%ebx
  801d88:	83 c4 20             	add    $0x20,%esp
  801d8b:	85 c0                	test   %eax,%eax
  801d8d:	78 58                	js     801de7 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801d8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d92:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801d98:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d9d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801da4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801da7:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801dad:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801daf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801db2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801db9:	83 ec 0c             	sub    $0xc,%esp
  801dbc:	ff 75 f4             	pushl  -0xc(%ebp)
  801dbf:	e8 48 f5 ff ff       	call   80130c <fd2num>
  801dc4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dc7:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801dc9:	83 c4 04             	add    $0x4,%esp
  801dcc:	ff 75 f0             	pushl  -0x10(%ebp)
  801dcf:	e8 38 f5 ff ff       	call   80130c <fd2num>
  801dd4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dd7:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801dda:	83 c4 10             	add    $0x10,%esp
  801ddd:	bb 00 00 00 00       	mov    $0x0,%ebx
  801de2:	e9 4f ff ff ff       	jmp    801d36 <pipe+0x75>
	sys_page_unmap(0, va);
  801de7:	83 ec 08             	sub    $0x8,%esp
  801dea:	56                   	push   %esi
  801deb:	6a 00                	push   $0x0
  801ded:	e8 bc f0 ff ff       	call   800eae <sys_page_unmap>
  801df2:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801df5:	83 ec 08             	sub    $0x8,%esp
  801df8:	ff 75 f0             	pushl  -0x10(%ebp)
  801dfb:	6a 00                	push   $0x0
  801dfd:	e8 ac f0 ff ff       	call   800eae <sys_page_unmap>
  801e02:	83 c4 10             	add    $0x10,%esp
  801e05:	e9 1c ff ff ff       	jmp    801d26 <pipe+0x65>

00801e0a <pipeisclosed>:
{
  801e0a:	55                   	push   %ebp
  801e0b:	89 e5                	mov    %esp,%ebp
  801e0d:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e10:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e13:	50                   	push   %eax
  801e14:	ff 75 08             	pushl  0x8(%ebp)
  801e17:	e8 66 f5 ff ff       	call   801382 <fd_lookup>
  801e1c:	83 c4 10             	add    $0x10,%esp
  801e1f:	85 c0                	test   %eax,%eax
  801e21:	78 18                	js     801e3b <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801e23:	83 ec 0c             	sub    $0xc,%esp
  801e26:	ff 75 f4             	pushl  -0xc(%ebp)
  801e29:	e8 ee f4 ff ff       	call   80131c <fd2data>
	return _pipeisclosed(fd, p);
  801e2e:	89 c2                	mov    %eax,%edx
  801e30:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e33:	e8 30 fd ff ff       	call   801b68 <_pipeisclosed>
  801e38:	83 c4 10             	add    $0x10,%esp
}
  801e3b:	c9                   	leave  
  801e3c:	c3                   	ret    

00801e3d <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801e3d:	55                   	push   %ebp
  801e3e:	89 e5                	mov    %esp,%ebp
  801e40:	56                   	push   %esi
  801e41:	53                   	push   %ebx
  801e42:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801e45:	85 f6                	test   %esi,%esi
  801e47:	74 13                	je     801e5c <wait+0x1f>
	e = &envs[ENVX(envid)];
  801e49:	89 f3                	mov    %esi,%ebx
  801e4b:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801e51:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  801e54:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  801e5a:	eb 1b                	jmp    801e77 <wait+0x3a>
	assert(envid != 0);
  801e5c:	68 3e 2a 80 00       	push   $0x802a3e
  801e61:	68 f3 29 80 00       	push   $0x8029f3
  801e66:	6a 09                	push   $0x9
  801e68:	68 49 2a 80 00       	push   $0x802a49
  801e6d:	e8 c4 e4 ff ff       	call   800336 <_panic>
		sys_yield();
  801e72:	e8 93 ef ff ff       	call   800e0a <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801e77:	8b 43 48             	mov    0x48(%ebx),%eax
  801e7a:	39 f0                	cmp    %esi,%eax
  801e7c:	75 07                	jne    801e85 <wait+0x48>
  801e7e:	8b 43 54             	mov    0x54(%ebx),%eax
  801e81:	85 c0                	test   %eax,%eax
  801e83:	75 ed                	jne    801e72 <wait+0x35>
}
  801e85:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e88:	5b                   	pop    %ebx
  801e89:	5e                   	pop    %esi
  801e8a:	5d                   	pop    %ebp
  801e8b:	c3                   	ret    

00801e8c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e8c:	55                   	push   %ebp
  801e8d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e8f:	b8 00 00 00 00       	mov    $0x0,%eax
  801e94:	5d                   	pop    %ebp
  801e95:	c3                   	ret    

00801e96 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e96:	55                   	push   %ebp
  801e97:	89 e5                	mov    %esp,%ebp
  801e99:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e9c:	68 54 2a 80 00       	push   $0x802a54
  801ea1:	ff 75 0c             	pushl  0xc(%ebp)
  801ea4:	e8 87 eb ff ff       	call   800a30 <strcpy>
	return 0;
}
  801ea9:	b8 00 00 00 00       	mov    $0x0,%eax
  801eae:	c9                   	leave  
  801eaf:	c3                   	ret    

00801eb0 <devcons_write>:
{
  801eb0:	55                   	push   %ebp
  801eb1:	89 e5                	mov    %esp,%ebp
  801eb3:	57                   	push   %edi
  801eb4:	56                   	push   %esi
  801eb5:	53                   	push   %ebx
  801eb6:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801ebc:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801ec1:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801ec7:	eb 2f                	jmp    801ef8 <devcons_write+0x48>
		m = n - tot;
  801ec9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ecc:	29 f3                	sub    %esi,%ebx
  801ece:	83 fb 7f             	cmp    $0x7f,%ebx
  801ed1:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801ed6:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801ed9:	83 ec 04             	sub    $0x4,%esp
  801edc:	53                   	push   %ebx
  801edd:	89 f0                	mov    %esi,%eax
  801edf:	03 45 0c             	add    0xc(%ebp),%eax
  801ee2:	50                   	push   %eax
  801ee3:	57                   	push   %edi
  801ee4:	e8 d5 ec ff ff       	call   800bbe <memmove>
		sys_cputs(buf, m);
  801ee9:	83 c4 08             	add    $0x8,%esp
  801eec:	53                   	push   %ebx
  801eed:	57                   	push   %edi
  801eee:	e8 7a ee ff ff       	call   800d6d <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801ef3:	01 de                	add    %ebx,%esi
  801ef5:	83 c4 10             	add    $0x10,%esp
  801ef8:	3b 75 10             	cmp    0x10(%ebp),%esi
  801efb:	72 cc                	jb     801ec9 <devcons_write+0x19>
}
  801efd:	89 f0                	mov    %esi,%eax
  801eff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f02:	5b                   	pop    %ebx
  801f03:	5e                   	pop    %esi
  801f04:	5f                   	pop    %edi
  801f05:	5d                   	pop    %ebp
  801f06:	c3                   	ret    

00801f07 <devcons_read>:
{
  801f07:	55                   	push   %ebp
  801f08:	89 e5                	mov    %esp,%ebp
  801f0a:	83 ec 08             	sub    $0x8,%esp
  801f0d:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801f12:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f16:	75 07                	jne    801f1f <devcons_read+0x18>
}
  801f18:	c9                   	leave  
  801f19:	c3                   	ret    
		sys_yield();
  801f1a:	e8 eb ee ff ff       	call   800e0a <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801f1f:	e8 67 ee ff ff       	call   800d8b <sys_cgetc>
  801f24:	85 c0                	test   %eax,%eax
  801f26:	74 f2                	je     801f1a <devcons_read+0x13>
	if (c < 0)
  801f28:	85 c0                	test   %eax,%eax
  801f2a:	78 ec                	js     801f18 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801f2c:	83 f8 04             	cmp    $0x4,%eax
  801f2f:	74 0c                	je     801f3d <devcons_read+0x36>
	*(char*)vbuf = c;
  801f31:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f34:	88 02                	mov    %al,(%edx)
	return 1;
  801f36:	b8 01 00 00 00       	mov    $0x1,%eax
  801f3b:	eb db                	jmp    801f18 <devcons_read+0x11>
		return 0;
  801f3d:	b8 00 00 00 00       	mov    $0x0,%eax
  801f42:	eb d4                	jmp    801f18 <devcons_read+0x11>

00801f44 <cputchar>:
{
  801f44:	55                   	push   %ebp
  801f45:	89 e5                	mov    %esp,%ebp
  801f47:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f4a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f4d:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801f50:	6a 01                	push   $0x1
  801f52:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f55:	50                   	push   %eax
  801f56:	e8 12 ee ff ff       	call   800d6d <sys_cputs>
}
  801f5b:	83 c4 10             	add    $0x10,%esp
  801f5e:	c9                   	leave  
  801f5f:	c3                   	ret    

00801f60 <getchar>:
{
  801f60:	55                   	push   %ebp
  801f61:	89 e5                	mov    %esp,%ebp
  801f63:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801f66:	6a 01                	push   $0x1
  801f68:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f6b:	50                   	push   %eax
  801f6c:	6a 00                	push   $0x0
  801f6e:	e8 80 f6 ff ff       	call   8015f3 <read>
	if (r < 0)
  801f73:	83 c4 10             	add    $0x10,%esp
  801f76:	85 c0                	test   %eax,%eax
  801f78:	78 08                	js     801f82 <getchar+0x22>
	if (r < 1)
  801f7a:	85 c0                	test   %eax,%eax
  801f7c:	7e 06                	jle    801f84 <getchar+0x24>
	return c;
  801f7e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801f82:	c9                   	leave  
  801f83:	c3                   	ret    
		return -E_EOF;
  801f84:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801f89:	eb f7                	jmp    801f82 <getchar+0x22>

00801f8b <iscons>:
{
  801f8b:	55                   	push   %ebp
  801f8c:	89 e5                	mov    %esp,%ebp
  801f8e:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f91:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f94:	50                   	push   %eax
  801f95:	ff 75 08             	pushl  0x8(%ebp)
  801f98:	e8 e5 f3 ff ff       	call   801382 <fd_lookup>
  801f9d:	83 c4 10             	add    $0x10,%esp
  801fa0:	85 c0                	test   %eax,%eax
  801fa2:	78 11                	js     801fb5 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801fa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fa7:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801fad:	39 10                	cmp    %edx,(%eax)
  801faf:	0f 94 c0             	sete   %al
  801fb2:	0f b6 c0             	movzbl %al,%eax
}
  801fb5:	c9                   	leave  
  801fb6:	c3                   	ret    

00801fb7 <opencons>:
{
  801fb7:	55                   	push   %ebp
  801fb8:	89 e5                	mov    %esp,%ebp
  801fba:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801fbd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fc0:	50                   	push   %eax
  801fc1:	e8 6d f3 ff ff       	call   801333 <fd_alloc>
  801fc6:	83 c4 10             	add    $0x10,%esp
  801fc9:	85 c0                	test   %eax,%eax
  801fcb:	78 3a                	js     802007 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fcd:	83 ec 04             	sub    $0x4,%esp
  801fd0:	68 07 04 00 00       	push   $0x407
  801fd5:	ff 75 f4             	pushl  -0xc(%ebp)
  801fd8:	6a 00                	push   $0x0
  801fda:	e8 4a ee ff ff       	call   800e29 <sys_page_alloc>
  801fdf:	83 c4 10             	add    $0x10,%esp
  801fe2:	85 c0                	test   %eax,%eax
  801fe4:	78 21                	js     802007 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801fe6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fe9:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801fef:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ff1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ff4:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ffb:	83 ec 0c             	sub    $0xc,%esp
  801ffe:	50                   	push   %eax
  801fff:	e8 08 f3 ff ff       	call   80130c <fd2num>
  802004:	83 c4 10             	add    $0x10,%esp
}
  802007:	c9                   	leave  
  802008:	c3                   	ret    

00802009 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802009:	55                   	push   %ebp
  80200a:	89 e5                	mov    %esp,%ebp
  80200c:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80200f:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802016:	74 20                	je     802038 <set_pgfault_handler+0x2f>
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
			panic("set_pgfault_handler:sys_page_alloc failed");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802018:	8b 45 08             	mov    0x8(%ebp),%eax
  80201b:	a3 00 60 80 00       	mov    %eax,0x806000
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  802020:	83 ec 08             	sub    $0x8,%esp
  802023:	68 78 20 80 00       	push   $0x802078
  802028:	6a 00                	push   $0x0
  80202a:	e8 45 ef ff ff       	call   800f74 <sys_env_set_pgfault_upcall>
  80202f:	83 c4 10             	add    $0x10,%esp
  802032:	85 c0                	test   %eax,%eax
  802034:	78 2e                	js     802064 <set_pgfault_handler+0x5b>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
}
  802036:	c9                   	leave  
  802037:	c3                   	ret    
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  802038:	83 ec 04             	sub    $0x4,%esp
  80203b:	6a 07                	push   $0x7
  80203d:	68 00 f0 bf ee       	push   $0xeebff000
  802042:	6a 00                	push   $0x0
  802044:	e8 e0 ed ff ff       	call   800e29 <sys_page_alloc>
  802049:	83 c4 10             	add    $0x10,%esp
  80204c:	85 c0                	test   %eax,%eax
  80204e:	79 c8                	jns    802018 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler:sys_page_alloc failed");
  802050:	83 ec 04             	sub    $0x4,%esp
  802053:	68 60 2a 80 00       	push   $0x802a60
  802058:	6a 21                	push   $0x21
  80205a:	68 c4 2a 80 00       	push   $0x802ac4
  80205f:	e8 d2 e2 ff ff       	call   800336 <_panic>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  802064:	83 ec 04             	sub    $0x4,%esp
  802067:	68 8c 2a 80 00       	push   $0x802a8c
  80206c:	6a 27                	push   $0x27
  80206e:	68 c4 2a 80 00       	push   $0x802ac4
  802073:	e8 be e2 ff ff       	call   800336 <_panic>

00802078 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802078:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802079:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80207e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802080:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %eax
  802083:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  802087:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  80208a:	89 44 24 30          	mov    %eax,0x30(%esp)
	movl 40(%esp), %ebx
  80208e:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  802092:	89 18                	mov    %ebx,(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  802094:	83 c4 08             	add    $0x8,%esp
	popal
  802097:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  802098:	83 c4 04             	add    $0x4,%esp
	popfl
  80209b:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80209c:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80209d:	c3                   	ret    

0080209e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80209e:	55                   	push   %ebp
  80209f:	89 e5                	mov    %esp,%ebp
  8020a1:	56                   	push   %esi
  8020a2:	53                   	push   %ebx
  8020a3:	8b 75 08             	mov    0x8(%ebp),%esi
  8020a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020a9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  8020ac:	85 f6                	test   %esi,%esi
  8020ae:	74 06                	je     8020b6 <ipc_recv+0x18>
  8020b0:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  8020b6:	85 db                	test   %ebx,%ebx
  8020b8:	74 06                	je     8020c0 <ipc_recv+0x22>
  8020ba:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  8020c0:	85 c0                	test   %eax,%eax
  8020c2:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  8020c7:	0f 44 c2             	cmove  %edx,%eax
	int ret = sys_ipc_recv(pg);
  8020ca:	83 ec 0c             	sub    $0xc,%esp
  8020cd:	50                   	push   %eax
  8020ce:	e8 06 ef ff ff       	call   800fd9 <sys_ipc_recv>
	if (ret) return ret;
  8020d3:	83 c4 10             	add    $0x10,%esp
  8020d6:	85 c0                	test   %eax,%eax
  8020d8:	75 24                	jne    8020fe <ipc_recv+0x60>
	if (from_env_store)
  8020da:	85 f6                	test   %esi,%esi
  8020dc:	74 0a                	je     8020e8 <ipc_recv+0x4a>
		*from_env_store = thisenv->env_ipc_from;
  8020de:	a1 04 40 80 00       	mov    0x804004,%eax
  8020e3:	8b 40 74             	mov    0x74(%eax),%eax
  8020e6:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  8020e8:	85 db                	test   %ebx,%ebx
  8020ea:	74 0a                	je     8020f6 <ipc_recv+0x58>
		*perm_store = thisenv->env_ipc_perm;
  8020ec:	a1 04 40 80 00       	mov    0x804004,%eax
  8020f1:	8b 40 78             	mov    0x78(%eax),%eax
  8020f4:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  8020f6:	a1 04 40 80 00       	mov    0x804004,%eax
  8020fb:	8b 40 70             	mov    0x70(%eax),%eax
}
  8020fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802101:	5b                   	pop    %ebx
  802102:	5e                   	pop    %esi
  802103:	5d                   	pop    %ebp
  802104:	c3                   	ret    

00802105 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802105:	55                   	push   %ebp
  802106:	89 e5                	mov    %esp,%ebp
  802108:	57                   	push   %edi
  802109:	56                   	push   %esi
  80210a:	53                   	push   %ebx
  80210b:	83 ec 0c             	sub    $0xc,%esp
  80210e:	8b 7d 08             	mov    0x8(%ebp),%edi
  802111:	8b 75 0c             	mov    0xc(%ebp),%esi
  802114:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  802117:	85 db                	test   %ebx,%ebx
  802119:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80211e:	0f 44 d8             	cmove  %eax,%ebx
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  802121:	ff 75 14             	pushl  0x14(%ebp)
  802124:	53                   	push   %ebx
  802125:	56                   	push   %esi
  802126:	57                   	push   %edi
  802127:	e8 8a ee ff ff       	call   800fb6 <sys_ipc_try_send>
  80212c:	83 c4 10             	add    $0x10,%esp
  80212f:	85 c0                	test   %eax,%eax
  802131:	74 1e                	je     802151 <ipc_send+0x4c>
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  802133:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802136:	75 07                	jne    80213f <ipc_send+0x3a>
		sys_yield();
  802138:	e8 cd ec ff ff       	call   800e0a <sys_yield>
  80213d:	eb e2                	jmp    802121 <ipc_send+0x1c>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  80213f:	50                   	push   %eax
  802140:	68 d2 2a 80 00       	push   $0x802ad2
  802145:	6a 36                	push   $0x36
  802147:	68 e9 2a 80 00       	push   $0x802ae9
  80214c:	e8 e5 e1 ff ff       	call   800336 <_panic>
	}
}
  802151:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802154:	5b                   	pop    %ebx
  802155:	5e                   	pop    %esi
  802156:	5f                   	pop    %edi
  802157:	5d                   	pop    %ebp
  802158:	c3                   	ret    

00802159 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802159:	55                   	push   %ebp
  80215a:	89 e5                	mov    %esp,%ebp
  80215c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80215f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802164:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802167:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80216d:	8b 52 50             	mov    0x50(%edx),%edx
  802170:	39 ca                	cmp    %ecx,%edx
  802172:	74 11                	je     802185 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  802174:	83 c0 01             	add    $0x1,%eax
  802177:	3d 00 04 00 00       	cmp    $0x400,%eax
  80217c:	75 e6                	jne    802164 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  80217e:	b8 00 00 00 00       	mov    $0x0,%eax
  802183:	eb 0b                	jmp    802190 <ipc_find_env+0x37>
			return envs[i].env_id;
  802185:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802188:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80218d:	8b 40 48             	mov    0x48(%eax),%eax
}
  802190:	5d                   	pop    %ebp
  802191:	c3                   	ret    

00802192 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802192:	55                   	push   %ebp
  802193:	89 e5                	mov    %esp,%ebp
  802195:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802198:	89 d0                	mov    %edx,%eax
  80219a:	c1 e8 16             	shr    $0x16,%eax
  80219d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8021a4:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  8021a9:	f6 c1 01             	test   $0x1,%cl
  8021ac:	74 1d                	je     8021cb <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  8021ae:	c1 ea 0c             	shr    $0xc,%edx
  8021b1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8021b8:	f6 c2 01             	test   $0x1,%dl
  8021bb:	74 0e                	je     8021cb <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021bd:	c1 ea 0c             	shr    $0xc,%edx
  8021c0:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021c7:	ef 
  8021c8:	0f b7 c0             	movzwl %ax,%eax
}
  8021cb:	5d                   	pop    %ebp
  8021cc:	c3                   	ret    
  8021cd:	66 90                	xchg   %ax,%ax
  8021cf:	90                   	nop

008021d0 <__udivdi3>:
  8021d0:	55                   	push   %ebp
  8021d1:	57                   	push   %edi
  8021d2:	56                   	push   %esi
  8021d3:	53                   	push   %ebx
  8021d4:	83 ec 1c             	sub    $0x1c,%esp
  8021d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021db:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8021df:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021e3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8021e7:	85 d2                	test   %edx,%edx
  8021e9:	75 35                	jne    802220 <__udivdi3+0x50>
  8021eb:	39 f3                	cmp    %esi,%ebx
  8021ed:	0f 87 bd 00 00 00    	ja     8022b0 <__udivdi3+0xe0>
  8021f3:	85 db                	test   %ebx,%ebx
  8021f5:	89 d9                	mov    %ebx,%ecx
  8021f7:	75 0b                	jne    802204 <__udivdi3+0x34>
  8021f9:	b8 01 00 00 00       	mov    $0x1,%eax
  8021fe:	31 d2                	xor    %edx,%edx
  802200:	f7 f3                	div    %ebx
  802202:	89 c1                	mov    %eax,%ecx
  802204:	31 d2                	xor    %edx,%edx
  802206:	89 f0                	mov    %esi,%eax
  802208:	f7 f1                	div    %ecx
  80220a:	89 c6                	mov    %eax,%esi
  80220c:	89 e8                	mov    %ebp,%eax
  80220e:	89 f7                	mov    %esi,%edi
  802210:	f7 f1                	div    %ecx
  802212:	89 fa                	mov    %edi,%edx
  802214:	83 c4 1c             	add    $0x1c,%esp
  802217:	5b                   	pop    %ebx
  802218:	5e                   	pop    %esi
  802219:	5f                   	pop    %edi
  80221a:	5d                   	pop    %ebp
  80221b:	c3                   	ret    
  80221c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802220:	39 f2                	cmp    %esi,%edx
  802222:	77 7c                	ja     8022a0 <__udivdi3+0xd0>
  802224:	0f bd fa             	bsr    %edx,%edi
  802227:	83 f7 1f             	xor    $0x1f,%edi
  80222a:	0f 84 98 00 00 00    	je     8022c8 <__udivdi3+0xf8>
  802230:	89 f9                	mov    %edi,%ecx
  802232:	b8 20 00 00 00       	mov    $0x20,%eax
  802237:	29 f8                	sub    %edi,%eax
  802239:	d3 e2                	shl    %cl,%edx
  80223b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80223f:	89 c1                	mov    %eax,%ecx
  802241:	89 da                	mov    %ebx,%edx
  802243:	d3 ea                	shr    %cl,%edx
  802245:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802249:	09 d1                	or     %edx,%ecx
  80224b:	89 f2                	mov    %esi,%edx
  80224d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802251:	89 f9                	mov    %edi,%ecx
  802253:	d3 e3                	shl    %cl,%ebx
  802255:	89 c1                	mov    %eax,%ecx
  802257:	d3 ea                	shr    %cl,%edx
  802259:	89 f9                	mov    %edi,%ecx
  80225b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80225f:	d3 e6                	shl    %cl,%esi
  802261:	89 eb                	mov    %ebp,%ebx
  802263:	89 c1                	mov    %eax,%ecx
  802265:	d3 eb                	shr    %cl,%ebx
  802267:	09 de                	or     %ebx,%esi
  802269:	89 f0                	mov    %esi,%eax
  80226b:	f7 74 24 08          	divl   0x8(%esp)
  80226f:	89 d6                	mov    %edx,%esi
  802271:	89 c3                	mov    %eax,%ebx
  802273:	f7 64 24 0c          	mull   0xc(%esp)
  802277:	39 d6                	cmp    %edx,%esi
  802279:	72 0c                	jb     802287 <__udivdi3+0xb7>
  80227b:	89 f9                	mov    %edi,%ecx
  80227d:	d3 e5                	shl    %cl,%ebp
  80227f:	39 c5                	cmp    %eax,%ebp
  802281:	73 5d                	jae    8022e0 <__udivdi3+0x110>
  802283:	39 d6                	cmp    %edx,%esi
  802285:	75 59                	jne    8022e0 <__udivdi3+0x110>
  802287:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80228a:	31 ff                	xor    %edi,%edi
  80228c:	89 fa                	mov    %edi,%edx
  80228e:	83 c4 1c             	add    $0x1c,%esp
  802291:	5b                   	pop    %ebx
  802292:	5e                   	pop    %esi
  802293:	5f                   	pop    %edi
  802294:	5d                   	pop    %ebp
  802295:	c3                   	ret    
  802296:	8d 76 00             	lea    0x0(%esi),%esi
  802299:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8022a0:	31 ff                	xor    %edi,%edi
  8022a2:	31 c0                	xor    %eax,%eax
  8022a4:	89 fa                	mov    %edi,%edx
  8022a6:	83 c4 1c             	add    $0x1c,%esp
  8022a9:	5b                   	pop    %ebx
  8022aa:	5e                   	pop    %esi
  8022ab:	5f                   	pop    %edi
  8022ac:	5d                   	pop    %ebp
  8022ad:	c3                   	ret    
  8022ae:	66 90                	xchg   %ax,%ax
  8022b0:	31 ff                	xor    %edi,%edi
  8022b2:	89 e8                	mov    %ebp,%eax
  8022b4:	89 f2                	mov    %esi,%edx
  8022b6:	f7 f3                	div    %ebx
  8022b8:	89 fa                	mov    %edi,%edx
  8022ba:	83 c4 1c             	add    $0x1c,%esp
  8022bd:	5b                   	pop    %ebx
  8022be:	5e                   	pop    %esi
  8022bf:	5f                   	pop    %edi
  8022c0:	5d                   	pop    %ebp
  8022c1:	c3                   	ret    
  8022c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022c8:	39 f2                	cmp    %esi,%edx
  8022ca:	72 06                	jb     8022d2 <__udivdi3+0x102>
  8022cc:	31 c0                	xor    %eax,%eax
  8022ce:	39 eb                	cmp    %ebp,%ebx
  8022d0:	77 d2                	ja     8022a4 <__udivdi3+0xd4>
  8022d2:	b8 01 00 00 00       	mov    $0x1,%eax
  8022d7:	eb cb                	jmp    8022a4 <__udivdi3+0xd4>
  8022d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022e0:	89 d8                	mov    %ebx,%eax
  8022e2:	31 ff                	xor    %edi,%edi
  8022e4:	eb be                	jmp    8022a4 <__udivdi3+0xd4>
  8022e6:	66 90                	xchg   %ax,%ax
  8022e8:	66 90                	xchg   %ax,%ax
  8022ea:	66 90                	xchg   %ax,%ax
  8022ec:	66 90                	xchg   %ax,%ax
  8022ee:	66 90                	xchg   %ax,%ax

008022f0 <__umoddi3>:
  8022f0:	55                   	push   %ebp
  8022f1:	57                   	push   %edi
  8022f2:	56                   	push   %esi
  8022f3:	53                   	push   %ebx
  8022f4:	83 ec 1c             	sub    $0x1c,%esp
  8022f7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8022fb:	8b 74 24 30          	mov    0x30(%esp),%esi
  8022ff:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802303:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802307:	85 ed                	test   %ebp,%ebp
  802309:	89 f0                	mov    %esi,%eax
  80230b:	89 da                	mov    %ebx,%edx
  80230d:	75 19                	jne    802328 <__umoddi3+0x38>
  80230f:	39 df                	cmp    %ebx,%edi
  802311:	0f 86 b1 00 00 00    	jbe    8023c8 <__umoddi3+0xd8>
  802317:	f7 f7                	div    %edi
  802319:	89 d0                	mov    %edx,%eax
  80231b:	31 d2                	xor    %edx,%edx
  80231d:	83 c4 1c             	add    $0x1c,%esp
  802320:	5b                   	pop    %ebx
  802321:	5e                   	pop    %esi
  802322:	5f                   	pop    %edi
  802323:	5d                   	pop    %ebp
  802324:	c3                   	ret    
  802325:	8d 76 00             	lea    0x0(%esi),%esi
  802328:	39 dd                	cmp    %ebx,%ebp
  80232a:	77 f1                	ja     80231d <__umoddi3+0x2d>
  80232c:	0f bd cd             	bsr    %ebp,%ecx
  80232f:	83 f1 1f             	xor    $0x1f,%ecx
  802332:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802336:	0f 84 b4 00 00 00    	je     8023f0 <__umoddi3+0x100>
  80233c:	b8 20 00 00 00       	mov    $0x20,%eax
  802341:	89 c2                	mov    %eax,%edx
  802343:	8b 44 24 04          	mov    0x4(%esp),%eax
  802347:	29 c2                	sub    %eax,%edx
  802349:	89 c1                	mov    %eax,%ecx
  80234b:	89 f8                	mov    %edi,%eax
  80234d:	d3 e5                	shl    %cl,%ebp
  80234f:	89 d1                	mov    %edx,%ecx
  802351:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802355:	d3 e8                	shr    %cl,%eax
  802357:	09 c5                	or     %eax,%ebp
  802359:	8b 44 24 04          	mov    0x4(%esp),%eax
  80235d:	89 c1                	mov    %eax,%ecx
  80235f:	d3 e7                	shl    %cl,%edi
  802361:	89 d1                	mov    %edx,%ecx
  802363:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802367:	89 df                	mov    %ebx,%edi
  802369:	d3 ef                	shr    %cl,%edi
  80236b:	89 c1                	mov    %eax,%ecx
  80236d:	89 f0                	mov    %esi,%eax
  80236f:	d3 e3                	shl    %cl,%ebx
  802371:	89 d1                	mov    %edx,%ecx
  802373:	89 fa                	mov    %edi,%edx
  802375:	d3 e8                	shr    %cl,%eax
  802377:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80237c:	09 d8                	or     %ebx,%eax
  80237e:	f7 f5                	div    %ebp
  802380:	d3 e6                	shl    %cl,%esi
  802382:	89 d1                	mov    %edx,%ecx
  802384:	f7 64 24 08          	mull   0x8(%esp)
  802388:	39 d1                	cmp    %edx,%ecx
  80238a:	89 c3                	mov    %eax,%ebx
  80238c:	89 d7                	mov    %edx,%edi
  80238e:	72 06                	jb     802396 <__umoddi3+0xa6>
  802390:	75 0e                	jne    8023a0 <__umoddi3+0xb0>
  802392:	39 c6                	cmp    %eax,%esi
  802394:	73 0a                	jae    8023a0 <__umoddi3+0xb0>
  802396:	2b 44 24 08          	sub    0x8(%esp),%eax
  80239a:	19 ea                	sbb    %ebp,%edx
  80239c:	89 d7                	mov    %edx,%edi
  80239e:	89 c3                	mov    %eax,%ebx
  8023a0:	89 ca                	mov    %ecx,%edx
  8023a2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8023a7:	29 de                	sub    %ebx,%esi
  8023a9:	19 fa                	sbb    %edi,%edx
  8023ab:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  8023af:	89 d0                	mov    %edx,%eax
  8023b1:	d3 e0                	shl    %cl,%eax
  8023b3:	89 d9                	mov    %ebx,%ecx
  8023b5:	d3 ee                	shr    %cl,%esi
  8023b7:	d3 ea                	shr    %cl,%edx
  8023b9:	09 f0                	or     %esi,%eax
  8023bb:	83 c4 1c             	add    $0x1c,%esp
  8023be:	5b                   	pop    %ebx
  8023bf:	5e                   	pop    %esi
  8023c0:	5f                   	pop    %edi
  8023c1:	5d                   	pop    %ebp
  8023c2:	c3                   	ret    
  8023c3:	90                   	nop
  8023c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023c8:	85 ff                	test   %edi,%edi
  8023ca:	89 f9                	mov    %edi,%ecx
  8023cc:	75 0b                	jne    8023d9 <__umoddi3+0xe9>
  8023ce:	b8 01 00 00 00       	mov    $0x1,%eax
  8023d3:	31 d2                	xor    %edx,%edx
  8023d5:	f7 f7                	div    %edi
  8023d7:	89 c1                	mov    %eax,%ecx
  8023d9:	89 d8                	mov    %ebx,%eax
  8023db:	31 d2                	xor    %edx,%edx
  8023dd:	f7 f1                	div    %ecx
  8023df:	89 f0                	mov    %esi,%eax
  8023e1:	f7 f1                	div    %ecx
  8023e3:	e9 31 ff ff ff       	jmp    802319 <__umoddi3+0x29>
  8023e8:	90                   	nop
  8023e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023f0:	39 dd                	cmp    %ebx,%ebp
  8023f2:	72 08                	jb     8023fc <__umoddi3+0x10c>
  8023f4:	39 f7                	cmp    %esi,%edi
  8023f6:	0f 87 21 ff ff ff    	ja     80231d <__umoddi3+0x2d>
  8023fc:	89 da                	mov    %ebx,%edx
  8023fe:	89 f0                	mov    %esi,%eax
  802400:	29 f8                	sub    %edi,%eax
  802402:	19 ea                	sbb    %ebp,%edx
  802404:	e9 14 ff ff ff       	jmp    80231d <__umoddi3+0x2d>
