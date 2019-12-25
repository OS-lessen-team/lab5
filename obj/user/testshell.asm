
obj/user/testshell.debug：     文件格式 elf32-i386


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
  80002c:	e8 5f 04 00 00       	call   800490 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <wrong>:
	breakpoint();
}

void
wrong(int rfd, int kfd, int off)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	81 ec 84 00 00 00    	sub    $0x84,%esp
  80003f:	8b 75 08             	mov    0x8(%ebp),%esi
  800042:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800045:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char buf[100];
	int n;

	seek(rfd, off);
  800048:	53                   	push   %ebx
  800049:	56                   	push   %esi
  80004a:	e8 ae 18 00 00       	call   8018fd <seek>
	seek(kfd, off);
  80004f:	83 c4 08             	add    $0x8,%esp
  800052:	53                   	push   %ebx
  800053:	57                   	push   %edi
  800054:	e8 a4 18 00 00       	call   8018fd <seek>

	cprintf("shell produced incorrect output.\n");
  800059:	c7 04 24 40 2a 80 00 	movl   $0x802a40,(%esp)
  800060:	e8 66 05 00 00       	call   8005cb <cprintf>
	cprintf("expected:\n===\n");
  800065:	c7 04 24 ab 2a 80 00 	movl   $0x802aab,(%esp)
  80006c:	e8 5a 05 00 00       	call   8005cb <cprintf>
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800071:	83 c4 10             	add    $0x10,%esp
  800074:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  800077:	eb 0d                	jmp    800086 <wrong+0x53>
		sys_cputs(buf, n);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	e8 a4 0e 00 00       	call   800f27 <sys_cputs>
  800083:	83 c4 10             	add    $0x10,%esp
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800086:	83 ec 04             	sub    $0x4,%esp
  800089:	6a 63                	push   $0x63
  80008b:	53                   	push   %ebx
  80008c:	57                   	push   %edi
  80008d:	e8 1b 17 00 00       	call   8017ad <read>
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	85 c0                	test   %eax,%eax
  800097:	7f e0                	jg     800079 <wrong+0x46>
	cprintf("===\ngot:\n===\n");
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	68 ba 2a 80 00       	push   $0x802aba
  8000a1:	e8 25 05 00 00       	call   8005cb <cprintf>
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  8000ac:	eb 0d                	jmp    8000bb <wrong+0x88>
		sys_cputs(buf, n);
  8000ae:	83 ec 08             	sub    $0x8,%esp
  8000b1:	50                   	push   %eax
  8000b2:	53                   	push   %ebx
  8000b3:	e8 6f 0e 00 00       	call   800f27 <sys_cputs>
  8000b8:	83 c4 10             	add    $0x10,%esp
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000bb:	83 ec 04             	sub    $0x4,%esp
  8000be:	6a 63                	push   $0x63
  8000c0:	53                   	push   %ebx
  8000c1:	56                   	push   %esi
  8000c2:	e8 e6 16 00 00       	call   8017ad <read>
  8000c7:	83 c4 10             	add    $0x10,%esp
  8000ca:	85 c0                	test   %eax,%eax
  8000cc:	7f e0                	jg     8000ae <wrong+0x7b>
	cprintf("===\n");
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	68 b5 2a 80 00       	push   $0x802ab5
  8000d6:	e8 f0 04 00 00       	call   8005cb <cprintf>
	exit();
  8000db:	e8 f6 03 00 00       	call   8004d6 <exit>
}
  8000e0:	83 c4 10             	add    $0x10,%esp
  8000e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <umain>:
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 38             	sub    $0x38,%esp
	close(0);
  8000f4:	6a 00                	push   $0x0
  8000f6:	e8 76 15 00 00       	call   801671 <close>
	close(1);
  8000fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800102:	e8 6a 15 00 00       	call   801671 <close>
	opencons();
  800107:	e8 32 03 00 00       	call   80043e <opencons>
	opencons();
  80010c:	e8 2d 03 00 00       	call   80043e <opencons>
	if ((rfd = open("testshell.sh", O_RDONLY)) < 0)
  800111:	83 c4 08             	add    $0x8,%esp
  800114:	6a 00                	push   $0x0
  800116:	68 c8 2a 80 00       	push   $0x802ac8
  80011b:	e8 e5 1a 00 00       	call   801c05 <open>
  800120:	89 c3                	mov    %eax,%ebx
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	0f 88 e9 00 00 00    	js     800216 <umain+0x12b>
	if ((wfd = pipe(pfds)) < 0)
  80012d:	83 ec 0c             	sub    $0xc,%esp
  800130:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800133:	50                   	push   %eax
  800134:	e8 26 23 00 00       	call   80245f <pipe>
  800139:	83 c4 10             	add    $0x10,%esp
  80013c:	85 c0                	test   %eax,%eax
  80013e:	0f 88 e4 00 00 00    	js     800228 <umain+0x13d>
	wfd = pfds[1];
  800144:	8b 75 e0             	mov    -0x20(%ebp),%esi
	cprintf("running sh -x < testshell.sh | cat\n");
  800147:	83 ec 0c             	sub    $0xc,%esp
  80014a:	68 64 2a 80 00       	push   $0x802a64
  80014f:	e8 77 04 00 00       	call   8005cb <cprintf>
	if ((r = fork()) < 0)
  800154:	e8 7d 11 00 00       	call   8012d6 <fork>
  800159:	83 c4 10             	add    $0x10,%esp
  80015c:	85 c0                	test   %eax,%eax
  80015e:	0f 88 d6 00 00 00    	js     80023a <umain+0x14f>
	if (r == 0) {
  800164:	85 c0                	test   %eax,%eax
  800166:	75 6f                	jne    8001d7 <umain+0xec>
		dup(rfd, 0);
  800168:	83 ec 08             	sub    $0x8,%esp
  80016b:	6a 00                	push   $0x0
  80016d:	53                   	push   %ebx
  80016e:	e8 4e 15 00 00       	call   8016c1 <dup>
		dup(wfd, 1);
  800173:	83 c4 08             	add    $0x8,%esp
  800176:	6a 01                	push   $0x1
  800178:	56                   	push   %esi
  800179:	e8 43 15 00 00       	call   8016c1 <dup>
		close(rfd);
  80017e:	89 1c 24             	mov    %ebx,(%esp)
  800181:	e8 eb 14 00 00       	call   801671 <close>
		close(wfd);
  800186:	89 34 24             	mov    %esi,(%esp)
  800189:	e8 e3 14 00 00       	call   801671 <close>
		if ((r = spawnl("/sh", "sh", "-x", 0)) < 0)
  80018e:	6a 00                	push   $0x0
  800190:	68 05 2b 80 00       	push   $0x802b05
  800195:	68 d2 2a 80 00       	push   $0x802ad2
  80019a:	68 08 2b 80 00       	push   $0x802b08
  80019f:	e8 6d 20 00 00       	call   802211 <spawnl>
  8001a4:	89 c7                	mov    %eax,%edi
  8001a6:	83 c4 20             	add    $0x20,%esp
  8001a9:	85 c0                	test   %eax,%eax
  8001ab:	0f 88 9b 00 00 00    	js     80024c <umain+0x161>
		close(0);
  8001b1:	83 ec 0c             	sub    $0xc,%esp
  8001b4:	6a 00                	push   $0x0
  8001b6:	e8 b6 14 00 00       	call   801671 <close>
		close(1);
  8001bb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001c2:	e8 aa 14 00 00       	call   801671 <close>
		wait(r);
  8001c7:	89 3c 24             	mov    %edi,(%esp)
  8001ca:	e8 0c 24 00 00       	call   8025db <wait>
		exit();
  8001cf:	e8 02 03 00 00       	call   8004d6 <exit>
  8001d4:	83 c4 10             	add    $0x10,%esp
	close(rfd);
  8001d7:	83 ec 0c             	sub    $0xc,%esp
  8001da:	53                   	push   %ebx
  8001db:	e8 91 14 00 00       	call   801671 <close>
	close(wfd);
  8001e0:	89 34 24             	mov    %esi,(%esp)
  8001e3:	e8 89 14 00 00       	call   801671 <close>
	rfd = pfds[0];
  8001e8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001eb:	89 45 d0             	mov    %eax,-0x30(%ebp)
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  8001ee:	83 c4 08             	add    $0x8,%esp
  8001f1:	6a 00                	push   $0x0
  8001f3:	68 16 2b 80 00       	push   $0x802b16
  8001f8:	e8 08 1a 00 00       	call   801c05 <open>
  8001fd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800200:	83 c4 10             	add    $0x10,%esp
  800203:	85 c0                	test   %eax,%eax
  800205:	78 57                	js     80025e <umain+0x173>
  800207:	be 01 00 00 00       	mov    $0x1,%esi
	nloff = 0;
  80020c:	bf 00 00 00 00       	mov    $0x0,%edi
  800211:	e9 9a 00 00 00       	jmp    8002b0 <umain+0x1c5>
		panic("open testshell.sh: %e", rfd);
  800216:	50                   	push   %eax
  800217:	68 d5 2a 80 00       	push   $0x802ad5
  80021c:	6a 13                	push   $0x13
  80021e:	68 eb 2a 80 00       	push   $0x802aeb
  800223:	e8 c8 02 00 00       	call   8004f0 <_panic>
		panic("pipe: %e", wfd);
  800228:	50                   	push   %eax
  800229:	68 fc 2a 80 00       	push   $0x802afc
  80022e:	6a 15                	push   $0x15
  800230:	68 eb 2a 80 00       	push   $0x802aeb
  800235:	e8 b6 02 00 00       	call   8004f0 <_panic>
		panic("fork: %e", r);
  80023a:	50                   	push   %eax
  80023b:	68 19 2f 80 00       	push   $0x802f19
  800240:	6a 1a                	push   $0x1a
  800242:	68 eb 2a 80 00       	push   $0x802aeb
  800247:	e8 a4 02 00 00       	call   8004f0 <_panic>
			panic("spawn: %e", r);
  80024c:	50                   	push   %eax
  80024d:	68 0c 2b 80 00       	push   $0x802b0c
  800252:	6a 21                	push   $0x21
  800254:	68 eb 2a 80 00       	push   $0x802aeb
  800259:	e8 92 02 00 00       	call   8004f0 <_panic>
		panic("open testshell.key for reading: %e", kfd);
  80025e:	50                   	push   %eax
  80025f:	68 88 2a 80 00       	push   $0x802a88
  800264:	6a 2c                	push   $0x2c
  800266:	68 eb 2a 80 00       	push   $0x802aeb
  80026b:	e8 80 02 00 00       	call   8004f0 <_panic>
			panic("reading testshell.out: %e", n1);
  800270:	53                   	push   %ebx
  800271:	68 24 2b 80 00       	push   $0x802b24
  800276:	6a 33                	push   $0x33
  800278:	68 eb 2a 80 00       	push   $0x802aeb
  80027d:	e8 6e 02 00 00       	call   8004f0 <_panic>
			panic("reading testshell.key: %e", n2);
  800282:	50                   	push   %eax
  800283:	68 3e 2b 80 00       	push   $0x802b3e
  800288:	6a 35                	push   $0x35
  80028a:	68 eb 2a 80 00       	push   $0x802aeb
  80028f:	e8 5c 02 00 00       	call   8004f0 <_panic>
			wrong(rfd, kfd, nloff);
  800294:	83 ec 04             	sub    $0x4,%esp
  800297:	57                   	push   %edi
  800298:	ff 75 d4             	pushl  -0x2c(%ebp)
  80029b:	ff 75 d0             	pushl  -0x30(%ebp)
  80029e:	e8 90 fd ff ff       	call   800033 <wrong>
  8002a3:	83 c4 10             	add    $0x10,%esp
			nloff = off+1;
  8002a6:	80 7d e7 0a          	cmpb   $0xa,-0x19(%ebp)
  8002aa:	0f 44 fe             	cmove  %esi,%edi
  8002ad:	83 c6 01             	add    $0x1,%esi
		n1 = read(rfd, &c1, 1);
  8002b0:	83 ec 04             	sub    $0x4,%esp
  8002b3:	6a 01                	push   $0x1
  8002b5:	8d 45 e7             	lea    -0x19(%ebp),%eax
  8002b8:	50                   	push   %eax
  8002b9:	ff 75 d0             	pushl  -0x30(%ebp)
  8002bc:	e8 ec 14 00 00       	call   8017ad <read>
  8002c1:	89 c3                	mov    %eax,%ebx
		n2 = read(kfd, &c2, 1);
  8002c3:	83 c4 0c             	add    $0xc,%esp
  8002c6:	6a 01                	push   $0x1
  8002c8:	8d 45 e6             	lea    -0x1a(%ebp),%eax
  8002cb:	50                   	push   %eax
  8002cc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002cf:	e8 d9 14 00 00       	call   8017ad <read>
		if (n1 < 0)
  8002d4:	83 c4 10             	add    $0x10,%esp
  8002d7:	85 db                	test   %ebx,%ebx
  8002d9:	78 95                	js     800270 <umain+0x185>
		if (n2 < 0)
  8002db:	85 c0                	test   %eax,%eax
  8002dd:	78 a3                	js     800282 <umain+0x197>
		if (n1 == 0 && n2 == 0)
  8002df:	89 da                	mov    %ebx,%edx
  8002e1:	09 c2                	or     %eax,%edx
  8002e3:	74 15                	je     8002fa <umain+0x20f>
		if (n1 != 1 || n2 != 1 || c1 != c2)
  8002e5:	83 fb 01             	cmp    $0x1,%ebx
  8002e8:	75 aa                	jne    800294 <umain+0x1a9>
  8002ea:	83 f8 01             	cmp    $0x1,%eax
  8002ed:	75 a5                	jne    800294 <umain+0x1a9>
  8002ef:	0f b6 45 e6          	movzbl -0x1a(%ebp),%eax
  8002f3:	38 45 e7             	cmp    %al,-0x19(%ebp)
  8002f6:	75 9c                	jne    800294 <umain+0x1a9>
  8002f8:	eb ac                	jmp    8002a6 <umain+0x1bb>
	cprintf("shell ran correctly\n");
  8002fa:	83 ec 0c             	sub    $0xc,%esp
  8002fd:	68 58 2b 80 00       	push   $0x802b58
  800302:	e8 c4 02 00 00       	call   8005cb <cprintf>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  800307:	cc                   	int3   
}
  800308:	83 c4 10             	add    $0x10,%esp
  80030b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80030e:	5b                   	pop    %ebx
  80030f:	5e                   	pop    %esi
  800310:	5f                   	pop    %edi
  800311:	5d                   	pop    %ebp
  800312:	c3                   	ret    

00800313 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800316:	b8 00 00 00 00       	mov    $0x0,%eax
  80031b:	5d                   	pop    %ebp
  80031c:	c3                   	ret    

0080031d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800323:	68 6d 2b 80 00       	push   $0x802b6d
  800328:	ff 75 0c             	pushl  0xc(%ebp)
  80032b:	e8 ba 08 00 00       	call   800bea <strcpy>
	return 0;
}
  800330:	b8 00 00 00 00       	mov    $0x0,%eax
  800335:	c9                   	leave  
  800336:	c3                   	ret    

00800337 <devcons_write>:
{
  800337:	55                   	push   %ebp
  800338:	89 e5                	mov    %esp,%ebp
  80033a:	57                   	push   %edi
  80033b:	56                   	push   %esi
  80033c:	53                   	push   %ebx
  80033d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800343:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800348:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  80034e:	eb 2f                	jmp    80037f <devcons_write+0x48>
		m = n - tot;
  800350:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800353:	29 f3                	sub    %esi,%ebx
  800355:	83 fb 7f             	cmp    $0x7f,%ebx
  800358:	b8 7f 00 00 00       	mov    $0x7f,%eax
  80035d:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800360:	83 ec 04             	sub    $0x4,%esp
  800363:	53                   	push   %ebx
  800364:	89 f0                	mov    %esi,%eax
  800366:	03 45 0c             	add    0xc(%ebp),%eax
  800369:	50                   	push   %eax
  80036a:	57                   	push   %edi
  80036b:	e8 08 0a 00 00       	call   800d78 <memmove>
		sys_cputs(buf, m);
  800370:	83 c4 08             	add    $0x8,%esp
  800373:	53                   	push   %ebx
  800374:	57                   	push   %edi
  800375:	e8 ad 0b 00 00       	call   800f27 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  80037a:	01 de                	add    %ebx,%esi
  80037c:	83 c4 10             	add    $0x10,%esp
  80037f:	3b 75 10             	cmp    0x10(%ebp),%esi
  800382:	72 cc                	jb     800350 <devcons_write+0x19>
}
  800384:	89 f0                	mov    %esi,%eax
  800386:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800389:	5b                   	pop    %ebx
  80038a:	5e                   	pop    %esi
  80038b:	5f                   	pop    %edi
  80038c:	5d                   	pop    %ebp
  80038d:	c3                   	ret    

0080038e <devcons_read>:
{
  80038e:	55                   	push   %ebp
  80038f:	89 e5                	mov    %esp,%ebp
  800391:	83 ec 08             	sub    $0x8,%esp
  800394:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800399:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80039d:	75 07                	jne    8003a6 <devcons_read+0x18>
}
  80039f:	c9                   	leave  
  8003a0:	c3                   	ret    
		sys_yield();
  8003a1:	e8 1e 0c 00 00       	call   800fc4 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8003a6:	e8 9a 0b 00 00       	call   800f45 <sys_cgetc>
  8003ab:	85 c0                	test   %eax,%eax
  8003ad:	74 f2                	je     8003a1 <devcons_read+0x13>
	if (c < 0)
  8003af:	85 c0                	test   %eax,%eax
  8003b1:	78 ec                	js     80039f <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  8003b3:	83 f8 04             	cmp    $0x4,%eax
  8003b6:	74 0c                	je     8003c4 <devcons_read+0x36>
	*(char*)vbuf = c;
  8003b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003bb:	88 02                	mov    %al,(%edx)
	return 1;
  8003bd:	b8 01 00 00 00       	mov    $0x1,%eax
  8003c2:	eb db                	jmp    80039f <devcons_read+0x11>
		return 0;
  8003c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c9:	eb d4                	jmp    80039f <devcons_read+0x11>

008003cb <cputchar>:
{
  8003cb:	55                   	push   %ebp
  8003cc:	89 e5                	mov    %esp,%ebp
  8003ce:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8003d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d4:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8003d7:	6a 01                	push   $0x1
  8003d9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8003dc:	50                   	push   %eax
  8003dd:	e8 45 0b 00 00       	call   800f27 <sys_cputs>
}
  8003e2:	83 c4 10             	add    $0x10,%esp
  8003e5:	c9                   	leave  
  8003e6:	c3                   	ret    

008003e7 <getchar>:
{
  8003e7:	55                   	push   %ebp
  8003e8:	89 e5                	mov    %esp,%ebp
  8003ea:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  8003ed:	6a 01                	push   $0x1
  8003ef:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8003f2:	50                   	push   %eax
  8003f3:	6a 00                	push   $0x0
  8003f5:	e8 b3 13 00 00       	call   8017ad <read>
	if (r < 0)
  8003fa:	83 c4 10             	add    $0x10,%esp
  8003fd:	85 c0                	test   %eax,%eax
  8003ff:	78 08                	js     800409 <getchar+0x22>
	if (r < 1)
  800401:	85 c0                	test   %eax,%eax
  800403:	7e 06                	jle    80040b <getchar+0x24>
	return c;
  800405:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800409:	c9                   	leave  
  80040a:	c3                   	ret    
		return -E_EOF;
  80040b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800410:	eb f7                	jmp    800409 <getchar+0x22>

00800412 <iscons>:
{
  800412:	55                   	push   %ebp
  800413:	89 e5                	mov    %esp,%ebp
  800415:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800418:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80041b:	50                   	push   %eax
  80041c:	ff 75 08             	pushl  0x8(%ebp)
  80041f:	e8 18 11 00 00       	call   80153c <fd_lookup>
  800424:	83 c4 10             	add    $0x10,%esp
  800427:	85 c0                	test   %eax,%eax
  800429:	78 11                	js     80043c <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  80042b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80042e:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800434:	39 10                	cmp    %edx,(%eax)
  800436:	0f 94 c0             	sete   %al
  800439:	0f b6 c0             	movzbl %al,%eax
}
  80043c:	c9                   	leave  
  80043d:	c3                   	ret    

0080043e <opencons>:
{
  80043e:	55                   	push   %ebp
  80043f:	89 e5                	mov    %esp,%ebp
  800441:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800444:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800447:	50                   	push   %eax
  800448:	e8 a0 10 00 00       	call   8014ed <fd_alloc>
  80044d:	83 c4 10             	add    $0x10,%esp
  800450:	85 c0                	test   %eax,%eax
  800452:	78 3a                	js     80048e <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800454:	83 ec 04             	sub    $0x4,%esp
  800457:	68 07 04 00 00       	push   $0x407
  80045c:	ff 75 f4             	pushl  -0xc(%ebp)
  80045f:	6a 00                	push   $0x0
  800461:	e8 7d 0b 00 00       	call   800fe3 <sys_page_alloc>
  800466:	83 c4 10             	add    $0x10,%esp
  800469:	85 c0                	test   %eax,%eax
  80046b:	78 21                	js     80048e <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  80046d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800470:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800476:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800478:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80047b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800482:	83 ec 0c             	sub    $0xc,%esp
  800485:	50                   	push   %eax
  800486:	e8 3b 10 00 00       	call   8014c6 <fd2num>
  80048b:	83 c4 10             	add    $0x10,%esp
}
  80048e:	c9                   	leave  
  80048f:	c3                   	ret    

00800490 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800490:	55                   	push   %ebp
  800491:	89 e5                	mov    %esp,%ebp
  800493:	56                   	push   %esi
  800494:	53                   	push   %ebx
  800495:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800498:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  80049b:	e8 05 0b 00 00       	call   800fa5 <sys_getenvid>
	thisenv = envs + ENVX(envid); 
  8004a0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004a5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8004a8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8004ad:	a3 04 50 80 00       	mov    %eax,0x805004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8004b2:	85 db                	test   %ebx,%ebx
  8004b4:	7e 07                	jle    8004bd <libmain+0x2d>
		binaryname = argv[0];
  8004b6:	8b 06                	mov    (%esi),%eax
  8004b8:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  8004bd:	83 ec 08             	sub    $0x8,%esp
  8004c0:	56                   	push   %esi
  8004c1:	53                   	push   %ebx
  8004c2:	e8 24 fc ff ff       	call   8000eb <umain>

	// exit gracefully
	exit();
  8004c7:	e8 0a 00 00 00       	call   8004d6 <exit>
}
  8004cc:	83 c4 10             	add    $0x10,%esp
  8004cf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004d2:	5b                   	pop    %ebx
  8004d3:	5e                   	pop    %esi
  8004d4:	5d                   	pop    %ebp
  8004d5:	c3                   	ret    

008004d6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8004d6:	55                   	push   %ebp
  8004d7:	89 e5                	mov    %esp,%ebp
  8004d9:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8004dc:	e8 bb 11 00 00       	call   80169c <close_all>
	sys_env_destroy(0);
  8004e1:	83 ec 0c             	sub    $0xc,%esp
  8004e4:	6a 00                	push   $0x0
  8004e6:	e8 79 0a 00 00       	call   800f64 <sys_env_destroy>
}
  8004eb:	83 c4 10             	add    $0x10,%esp
  8004ee:	c9                   	leave  
  8004ef:	c3                   	ret    

008004f0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8004f0:	55                   	push   %ebp
  8004f1:	89 e5                	mov    %esp,%ebp
  8004f3:	56                   	push   %esi
  8004f4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8004f5:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8004f8:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  8004fe:	e8 a2 0a 00 00       	call   800fa5 <sys_getenvid>
  800503:	83 ec 0c             	sub    $0xc,%esp
  800506:	ff 75 0c             	pushl  0xc(%ebp)
  800509:	ff 75 08             	pushl  0x8(%ebp)
  80050c:	56                   	push   %esi
  80050d:	50                   	push   %eax
  80050e:	68 84 2b 80 00       	push   $0x802b84
  800513:	e8 b3 00 00 00       	call   8005cb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800518:	83 c4 18             	add    $0x18,%esp
  80051b:	53                   	push   %ebx
  80051c:	ff 75 10             	pushl  0x10(%ebp)
  80051f:	e8 56 00 00 00       	call   80057a <vcprintf>
	cprintf("\n");
  800524:	c7 04 24 b8 2a 80 00 	movl   $0x802ab8,(%esp)
  80052b:	e8 9b 00 00 00       	call   8005cb <cprintf>
  800530:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800533:	cc                   	int3   
  800534:	eb fd                	jmp    800533 <_panic+0x43>

00800536 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800536:	55                   	push   %ebp
  800537:	89 e5                	mov    %esp,%ebp
  800539:	53                   	push   %ebx
  80053a:	83 ec 04             	sub    $0x4,%esp
  80053d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800540:	8b 13                	mov    (%ebx),%edx
  800542:	8d 42 01             	lea    0x1(%edx),%eax
  800545:	89 03                	mov    %eax,(%ebx)
  800547:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80054a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80054e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800553:	74 09                	je     80055e <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800555:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800559:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80055c:	c9                   	leave  
  80055d:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80055e:	83 ec 08             	sub    $0x8,%esp
  800561:	68 ff 00 00 00       	push   $0xff
  800566:	8d 43 08             	lea    0x8(%ebx),%eax
  800569:	50                   	push   %eax
  80056a:	e8 b8 09 00 00       	call   800f27 <sys_cputs>
		b->idx = 0;
  80056f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800575:	83 c4 10             	add    $0x10,%esp
  800578:	eb db                	jmp    800555 <putch+0x1f>

0080057a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80057a:	55                   	push   %ebp
  80057b:	89 e5                	mov    %esp,%ebp
  80057d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800583:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80058a:	00 00 00 
	b.cnt = 0;
  80058d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800594:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800597:	ff 75 0c             	pushl  0xc(%ebp)
  80059a:	ff 75 08             	pushl  0x8(%ebp)
  80059d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8005a3:	50                   	push   %eax
  8005a4:	68 36 05 80 00       	push   $0x800536
  8005a9:	e8 1a 01 00 00       	call   8006c8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005ae:	83 c4 08             	add    $0x8,%esp
  8005b1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8005b7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8005bd:	50                   	push   %eax
  8005be:	e8 64 09 00 00       	call   800f27 <sys_cputs>

	return b.cnt;
}
  8005c3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8005c9:	c9                   	leave  
  8005ca:	c3                   	ret    

008005cb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8005cb:	55                   	push   %ebp
  8005cc:	89 e5                	mov    %esp,%ebp
  8005ce:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8005d1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8005d4:	50                   	push   %eax
  8005d5:	ff 75 08             	pushl  0x8(%ebp)
  8005d8:	e8 9d ff ff ff       	call   80057a <vcprintf>
	va_end(ap);

	return cnt;
}
  8005dd:	c9                   	leave  
  8005de:	c3                   	ret    

008005df <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005df:	55                   	push   %ebp
  8005e0:	89 e5                	mov    %esp,%ebp
  8005e2:	57                   	push   %edi
  8005e3:	56                   	push   %esi
  8005e4:	53                   	push   %ebx
  8005e5:	83 ec 1c             	sub    $0x1c,%esp
  8005e8:	89 c7                	mov    %eax,%edi
  8005ea:	89 d6                	mov    %edx,%esi
  8005ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f5:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005f8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8005fb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800600:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800603:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800606:	39 d3                	cmp    %edx,%ebx
  800608:	72 05                	jb     80060f <printnum+0x30>
  80060a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80060d:	77 7a                	ja     800689 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80060f:	83 ec 0c             	sub    $0xc,%esp
  800612:	ff 75 18             	pushl  0x18(%ebp)
  800615:	8b 45 14             	mov    0x14(%ebp),%eax
  800618:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80061b:	53                   	push   %ebx
  80061c:	ff 75 10             	pushl  0x10(%ebp)
  80061f:	83 ec 08             	sub    $0x8,%esp
  800622:	ff 75 e4             	pushl  -0x1c(%ebp)
  800625:	ff 75 e0             	pushl  -0x20(%ebp)
  800628:	ff 75 dc             	pushl  -0x24(%ebp)
  80062b:	ff 75 d8             	pushl  -0x28(%ebp)
  80062e:	e8 bd 21 00 00       	call   8027f0 <__udivdi3>
  800633:	83 c4 18             	add    $0x18,%esp
  800636:	52                   	push   %edx
  800637:	50                   	push   %eax
  800638:	89 f2                	mov    %esi,%edx
  80063a:	89 f8                	mov    %edi,%eax
  80063c:	e8 9e ff ff ff       	call   8005df <printnum>
  800641:	83 c4 20             	add    $0x20,%esp
  800644:	eb 13                	jmp    800659 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800646:	83 ec 08             	sub    $0x8,%esp
  800649:	56                   	push   %esi
  80064a:	ff 75 18             	pushl  0x18(%ebp)
  80064d:	ff d7                	call   *%edi
  80064f:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800652:	83 eb 01             	sub    $0x1,%ebx
  800655:	85 db                	test   %ebx,%ebx
  800657:	7f ed                	jg     800646 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800659:	83 ec 08             	sub    $0x8,%esp
  80065c:	56                   	push   %esi
  80065d:	83 ec 04             	sub    $0x4,%esp
  800660:	ff 75 e4             	pushl  -0x1c(%ebp)
  800663:	ff 75 e0             	pushl  -0x20(%ebp)
  800666:	ff 75 dc             	pushl  -0x24(%ebp)
  800669:	ff 75 d8             	pushl  -0x28(%ebp)
  80066c:	e8 9f 22 00 00       	call   802910 <__umoddi3>
  800671:	83 c4 14             	add    $0x14,%esp
  800674:	0f be 80 a7 2b 80 00 	movsbl 0x802ba7(%eax),%eax
  80067b:	50                   	push   %eax
  80067c:	ff d7                	call   *%edi
}
  80067e:	83 c4 10             	add    $0x10,%esp
  800681:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800684:	5b                   	pop    %ebx
  800685:	5e                   	pop    %esi
  800686:	5f                   	pop    %edi
  800687:	5d                   	pop    %ebp
  800688:	c3                   	ret    
  800689:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80068c:	eb c4                	jmp    800652 <printnum+0x73>

0080068e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80068e:	55                   	push   %ebp
  80068f:	89 e5                	mov    %esp,%ebp
  800691:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800694:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800698:	8b 10                	mov    (%eax),%edx
  80069a:	3b 50 04             	cmp    0x4(%eax),%edx
  80069d:	73 0a                	jae    8006a9 <sprintputch+0x1b>
		*b->buf++ = ch;
  80069f:	8d 4a 01             	lea    0x1(%edx),%ecx
  8006a2:	89 08                	mov    %ecx,(%eax)
  8006a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a7:	88 02                	mov    %al,(%edx)
}
  8006a9:	5d                   	pop    %ebp
  8006aa:	c3                   	ret    

008006ab <printfmt>:
{
  8006ab:	55                   	push   %ebp
  8006ac:	89 e5                	mov    %esp,%ebp
  8006ae:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8006b1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8006b4:	50                   	push   %eax
  8006b5:	ff 75 10             	pushl  0x10(%ebp)
  8006b8:	ff 75 0c             	pushl  0xc(%ebp)
  8006bb:	ff 75 08             	pushl  0x8(%ebp)
  8006be:	e8 05 00 00 00       	call   8006c8 <vprintfmt>
}
  8006c3:	83 c4 10             	add    $0x10,%esp
  8006c6:	c9                   	leave  
  8006c7:	c3                   	ret    

008006c8 <vprintfmt>:
{
  8006c8:	55                   	push   %ebp
  8006c9:	89 e5                	mov    %esp,%ebp
  8006cb:	57                   	push   %edi
  8006cc:	56                   	push   %esi
  8006cd:	53                   	push   %ebx
  8006ce:	83 ec 2c             	sub    $0x2c,%esp
  8006d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8006d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006d7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8006da:	e9 c1 03 00 00       	jmp    800aa0 <vprintfmt+0x3d8>
		padc = ' ';
  8006df:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8006e3:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8006ea:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8006f1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8006f8:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8006fd:	8d 47 01             	lea    0x1(%edi),%eax
  800700:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800703:	0f b6 17             	movzbl (%edi),%edx
  800706:	8d 42 dd             	lea    -0x23(%edx),%eax
  800709:	3c 55                	cmp    $0x55,%al
  80070b:	0f 87 12 04 00 00    	ja     800b23 <vprintfmt+0x45b>
  800711:	0f b6 c0             	movzbl %al,%eax
  800714:	ff 24 85 e0 2c 80 00 	jmp    *0x802ce0(,%eax,4)
  80071b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80071e:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800722:	eb d9                	jmp    8006fd <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800724:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800727:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80072b:	eb d0                	jmp    8006fd <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80072d:	0f b6 d2             	movzbl %dl,%edx
  800730:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800733:	b8 00 00 00 00       	mov    $0x0,%eax
  800738:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80073b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80073e:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800742:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800745:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800748:	83 f9 09             	cmp    $0x9,%ecx
  80074b:	77 55                	ja     8007a2 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  80074d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800750:	eb e9                	jmp    80073b <vprintfmt+0x73>
			precision = va_arg(ap, int);
  800752:	8b 45 14             	mov    0x14(%ebp),%eax
  800755:	8b 00                	mov    (%eax),%eax
  800757:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80075a:	8b 45 14             	mov    0x14(%ebp),%eax
  80075d:	8d 40 04             	lea    0x4(%eax),%eax
  800760:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800763:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800766:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80076a:	79 91                	jns    8006fd <vprintfmt+0x35>
				width = precision, precision = -1;
  80076c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80076f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800772:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800779:	eb 82                	jmp    8006fd <vprintfmt+0x35>
  80077b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80077e:	85 c0                	test   %eax,%eax
  800780:	ba 00 00 00 00       	mov    $0x0,%edx
  800785:	0f 49 d0             	cmovns %eax,%edx
  800788:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80078b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80078e:	e9 6a ff ff ff       	jmp    8006fd <vprintfmt+0x35>
  800793:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800796:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80079d:	e9 5b ff ff ff       	jmp    8006fd <vprintfmt+0x35>
  8007a2:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8007a5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8007a8:	eb bc                	jmp    800766 <vprintfmt+0x9e>
			lflag++;
  8007aa:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8007ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8007b0:	e9 48 ff ff ff       	jmp    8006fd <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8007b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b8:	8d 78 04             	lea    0x4(%eax),%edi
  8007bb:	83 ec 08             	sub    $0x8,%esp
  8007be:	53                   	push   %ebx
  8007bf:	ff 30                	pushl  (%eax)
  8007c1:	ff d6                	call   *%esi
			break;
  8007c3:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8007c6:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8007c9:	e9 cf 02 00 00       	jmp    800a9d <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8007ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d1:	8d 78 04             	lea    0x4(%eax),%edi
  8007d4:	8b 00                	mov    (%eax),%eax
  8007d6:	99                   	cltd   
  8007d7:	31 d0                	xor    %edx,%eax
  8007d9:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8007db:	83 f8 0f             	cmp    $0xf,%eax
  8007de:	7f 23                	jg     800803 <vprintfmt+0x13b>
  8007e0:	8b 14 85 40 2e 80 00 	mov    0x802e40(,%eax,4),%edx
  8007e7:	85 d2                	test   %edx,%edx
  8007e9:	74 18                	je     800803 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8007eb:	52                   	push   %edx
  8007ec:	68 05 30 80 00       	push   $0x803005
  8007f1:	53                   	push   %ebx
  8007f2:	56                   	push   %esi
  8007f3:	e8 b3 fe ff ff       	call   8006ab <printfmt>
  8007f8:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8007fb:	89 7d 14             	mov    %edi,0x14(%ebp)
  8007fe:	e9 9a 02 00 00       	jmp    800a9d <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  800803:	50                   	push   %eax
  800804:	68 bf 2b 80 00       	push   $0x802bbf
  800809:	53                   	push   %ebx
  80080a:	56                   	push   %esi
  80080b:	e8 9b fe ff ff       	call   8006ab <printfmt>
  800810:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800813:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800816:	e9 82 02 00 00       	jmp    800a9d <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  80081b:	8b 45 14             	mov    0x14(%ebp),%eax
  80081e:	83 c0 04             	add    $0x4,%eax
  800821:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800824:	8b 45 14             	mov    0x14(%ebp),%eax
  800827:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800829:	85 ff                	test   %edi,%edi
  80082b:	b8 b8 2b 80 00       	mov    $0x802bb8,%eax
  800830:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800833:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800837:	0f 8e bd 00 00 00    	jle    8008fa <vprintfmt+0x232>
  80083d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800841:	75 0e                	jne    800851 <vprintfmt+0x189>
  800843:	89 75 08             	mov    %esi,0x8(%ebp)
  800846:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800849:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80084c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80084f:	eb 6d                	jmp    8008be <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  800851:	83 ec 08             	sub    $0x8,%esp
  800854:	ff 75 d0             	pushl  -0x30(%ebp)
  800857:	57                   	push   %edi
  800858:	e8 6e 03 00 00       	call   800bcb <strnlen>
  80085d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800860:	29 c1                	sub    %eax,%ecx
  800862:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800865:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800868:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80086c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80086f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800872:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800874:	eb 0f                	jmp    800885 <vprintfmt+0x1bd>
					putch(padc, putdat);
  800876:	83 ec 08             	sub    $0x8,%esp
  800879:	53                   	push   %ebx
  80087a:	ff 75 e0             	pushl  -0x20(%ebp)
  80087d:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80087f:	83 ef 01             	sub    $0x1,%edi
  800882:	83 c4 10             	add    $0x10,%esp
  800885:	85 ff                	test   %edi,%edi
  800887:	7f ed                	jg     800876 <vprintfmt+0x1ae>
  800889:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80088c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80088f:	85 c9                	test   %ecx,%ecx
  800891:	b8 00 00 00 00       	mov    $0x0,%eax
  800896:	0f 49 c1             	cmovns %ecx,%eax
  800899:	29 c1                	sub    %eax,%ecx
  80089b:	89 75 08             	mov    %esi,0x8(%ebp)
  80089e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8008a1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8008a4:	89 cb                	mov    %ecx,%ebx
  8008a6:	eb 16                	jmp    8008be <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8008a8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8008ac:	75 31                	jne    8008df <vprintfmt+0x217>
					putch(ch, putdat);
  8008ae:	83 ec 08             	sub    $0x8,%esp
  8008b1:	ff 75 0c             	pushl  0xc(%ebp)
  8008b4:	50                   	push   %eax
  8008b5:	ff 55 08             	call   *0x8(%ebp)
  8008b8:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008bb:	83 eb 01             	sub    $0x1,%ebx
  8008be:	83 c7 01             	add    $0x1,%edi
  8008c1:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8008c5:	0f be c2             	movsbl %dl,%eax
  8008c8:	85 c0                	test   %eax,%eax
  8008ca:	74 59                	je     800925 <vprintfmt+0x25d>
  8008cc:	85 f6                	test   %esi,%esi
  8008ce:	78 d8                	js     8008a8 <vprintfmt+0x1e0>
  8008d0:	83 ee 01             	sub    $0x1,%esi
  8008d3:	79 d3                	jns    8008a8 <vprintfmt+0x1e0>
  8008d5:	89 df                	mov    %ebx,%edi
  8008d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008dd:	eb 37                	jmp    800916 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8008df:	0f be d2             	movsbl %dl,%edx
  8008e2:	83 ea 20             	sub    $0x20,%edx
  8008e5:	83 fa 5e             	cmp    $0x5e,%edx
  8008e8:	76 c4                	jbe    8008ae <vprintfmt+0x1e6>
					putch('?', putdat);
  8008ea:	83 ec 08             	sub    $0x8,%esp
  8008ed:	ff 75 0c             	pushl  0xc(%ebp)
  8008f0:	6a 3f                	push   $0x3f
  8008f2:	ff 55 08             	call   *0x8(%ebp)
  8008f5:	83 c4 10             	add    $0x10,%esp
  8008f8:	eb c1                	jmp    8008bb <vprintfmt+0x1f3>
  8008fa:	89 75 08             	mov    %esi,0x8(%ebp)
  8008fd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800900:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800903:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800906:	eb b6                	jmp    8008be <vprintfmt+0x1f6>
				putch(' ', putdat);
  800908:	83 ec 08             	sub    $0x8,%esp
  80090b:	53                   	push   %ebx
  80090c:	6a 20                	push   $0x20
  80090e:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800910:	83 ef 01             	sub    $0x1,%edi
  800913:	83 c4 10             	add    $0x10,%esp
  800916:	85 ff                	test   %edi,%edi
  800918:	7f ee                	jg     800908 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  80091a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80091d:	89 45 14             	mov    %eax,0x14(%ebp)
  800920:	e9 78 01 00 00       	jmp    800a9d <vprintfmt+0x3d5>
  800925:	89 df                	mov    %ebx,%edi
  800927:	8b 75 08             	mov    0x8(%ebp),%esi
  80092a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80092d:	eb e7                	jmp    800916 <vprintfmt+0x24e>
	if (lflag >= 2)
  80092f:	83 f9 01             	cmp    $0x1,%ecx
  800932:	7e 3f                	jle    800973 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800934:	8b 45 14             	mov    0x14(%ebp),%eax
  800937:	8b 50 04             	mov    0x4(%eax),%edx
  80093a:	8b 00                	mov    (%eax),%eax
  80093c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80093f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800942:	8b 45 14             	mov    0x14(%ebp),%eax
  800945:	8d 40 08             	lea    0x8(%eax),%eax
  800948:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80094b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80094f:	79 5c                	jns    8009ad <vprintfmt+0x2e5>
				putch('-', putdat);
  800951:	83 ec 08             	sub    $0x8,%esp
  800954:	53                   	push   %ebx
  800955:	6a 2d                	push   $0x2d
  800957:	ff d6                	call   *%esi
				num = -(long long) num;
  800959:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80095c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80095f:	f7 da                	neg    %edx
  800961:	83 d1 00             	adc    $0x0,%ecx
  800964:	f7 d9                	neg    %ecx
  800966:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800969:	b8 0a 00 00 00       	mov    $0xa,%eax
  80096e:	e9 10 01 00 00       	jmp    800a83 <vprintfmt+0x3bb>
	else if (lflag)
  800973:	85 c9                	test   %ecx,%ecx
  800975:	75 1b                	jne    800992 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800977:	8b 45 14             	mov    0x14(%ebp),%eax
  80097a:	8b 00                	mov    (%eax),%eax
  80097c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80097f:	89 c1                	mov    %eax,%ecx
  800981:	c1 f9 1f             	sar    $0x1f,%ecx
  800984:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800987:	8b 45 14             	mov    0x14(%ebp),%eax
  80098a:	8d 40 04             	lea    0x4(%eax),%eax
  80098d:	89 45 14             	mov    %eax,0x14(%ebp)
  800990:	eb b9                	jmp    80094b <vprintfmt+0x283>
		return va_arg(*ap, long);
  800992:	8b 45 14             	mov    0x14(%ebp),%eax
  800995:	8b 00                	mov    (%eax),%eax
  800997:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80099a:	89 c1                	mov    %eax,%ecx
  80099c:	c1 f9 1f             	sar    $0x1f,%ecx
  80099f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8009a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a5:	8d 40 04             	lea    0x4(%eax),%eax
  8009a8:	89 45 14             	mov    %eax,0x14(%ebp)
  8009ab:	eb 9e                	jmp    80094b <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8009ad:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8009b0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8009b3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009b8:	e9 c6 00 00 00       	jmp    800a83 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8009bd:	83 f9 01             	cmp    $0x1,%ecx
  8009c0:	7e 18                	jle    8009da <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8009c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c5:	8b 10                	mov    (%eax),%edx
  8009c7:	8b 48 04             	mov    0x4(%eax),%ecx
  8009ca:	8d 40 08             	lea    0x8(%eax),%eax
  8009cd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8009d0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009d5:	e9 a9 00 00 00       	jmp    800a83 <vprintfmt+0x3bb>
	else if (lflag)
  8009da:	85 c9                	test   %ecx,%ecx
  8009dc:	75 1a                	jne    8009f8 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  8009de:	8b 45 14             	mov    0x14(%ebp),%eax
  8009e1:	8b 10                	mov    (%eax),%edx
  8009e3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009e8:	8d 40 04             	lea    0x4(%eax),%eax
  8009eb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8009ee:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009f3:	e9 8b 00 00 00       	jmp    800a83 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8009f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8009fb:	8b 10                	mov    (%eax),%edx
  8009fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a02:	8d 40 04             	lea    0x4(%eax),%eax
  800a05:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800a08:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a0d:	eb 74                	jmp    800a83 <vprintfmt+0x3bb>
	if (lflag >= 2)
  800a0f:	83 f9 01             	cmp    $0x1,%ecx
  800a12:	7e 15                	jle    800a29 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  800a14:	8b 45 14             	mov    0x14(%ebp),%eax
  800a17:	8b 10                	mov    (%eax),%edx
  800a19:	8b 48 04             	mov    0x4(%eax),%ecx
  800a1c:	8d 40 08             	lea    0x8(%eax),%eax
  800a1f:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800a22:	b8 08 00 00 00       	mov    $0x8,%eax
  800a27:	eb 5a                	jmp    800a83 <vprintfmt+0x3bb>
	else if (lflag)
  800a29:	85 c9                	test   %ecx,%ecx
  800a2b:	75 17                	jne    800a44 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  800a2d:	8b 45 14             	mov    0x14(%ebp),%eax
  800a30:	8b 10                	mov    (%eax),%edx
  800a32:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a37:	8d 40 04             	lea    0x4(%eax),%eax
  800a3a:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800a3d:	b8 08 00 00 00       	mov    $0x8,%eax
  800a42:	eb 3f                	jmp    800a83 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800a44:	8b 45 14             	mov    0x14(%ebp),%eax
  800a47:	8b 10                	mov    (%eax),%edx
  800a49:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a4e:	8d 40 04             	lea    0x4(%eax),%eax
  800a51:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800a54:	b8 08 00 00 00       	mov    $0x8,%eax
  800a59:	eb 28                	jmp    800a83 <vprintfmt+0x3bb>
			putch('0', putdat);
  800a5b:	83 ec 08             	sub    $0x8,%esp
  800a5e:	53                   	push   %ebx
  800a5f:	6a 30                	push   $0x30
  800a61:	ff d6                	call   *%esi
			putch('x', putdat);
  800a63:	83 c4 08             	add    $0x8,%esp
  800a66:	53                   	push   %ebx
  800a67:	6a 78                	push   $0x78
  800a69:	ff d6                	call   *%esi
			num = (unsigned long long)
  800a6b:	8b 45 14             	mov    0x14(%ebp),%eax
  800a6e:	8b 10                	mov    (%eax),%edx
  800a70:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800a75:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800a78:	8d 40 04             	lea    0x4(%eax),%eax
  800a7b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800a7e:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800a83:	83 ec 0c             	sub    $0xc,%esp
  800a86:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800a8a:	57                   	push   %edi
  800a8b:	ff 75 e0             	pushl  -0x20(%ebp)
  800a8e:	50                   	push   %eax
  800a8f:	51                   	push   %ecx
  800a90:	52                   	push   %edx
  800a91:	89 da                	mov    %ebx,%edx
  800a93:	89 f0                	mov    %esi,%eax
  800a95:	e8 45 fb ff ff       	call   8005df <printnum>
			break;
  800a9a:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800a9d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800aa0:	83 c7 01             	add    $0x1,%edi
  800aa3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800aa7:	83 f8 25             	cmp    $0x25,%eax
  800aaa:	0f 84 2f fc ff ff    	je     8006df <vprintfmt+0x17>
			if (ch == '\0')
  800ab0:	85 c0                	test   %eax,%eax
  800ab2:	0f 84 8b 00 00 00    	je     800b43 <vprintfmt+0x47b>
			putch(ch, putdat);
  800ab8:	83 ec 08             	sub    $0x8,%esp
  800abb:	53                   	push   %ebx
  800abc:	50                   	push   %eax
  800abd:	ff d6                	call   *%esi
  800abf:	83 c4 10             	add    $0x10,%esp
  800ac2:	eb dc                	jmp    800aa0 <vprintfmt+0x3d8>
	if (lflag >= 2)
  800ac4:	83 f9 01             	cmp    $0x1,%ecx
  800ac7:	7e 15                	jle    800ade <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  800ac9:	8b 45 14             	mov    0x14(%ebp),%eax
  800acc:	8b 10                	mov    (%eax),%edx
  800ace:	8b 48 04             	mov    0x4(%eax),%ecx
  800ad1:	8d 40 08             	lea    0x8(%eax),%eax
  800ad4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800ad7:	b8 10 00 00 00       	mov    $0x10,%eax
  800adc:	eb a5                	jmp    800a83 <vprintfmt+0x3bb>
	else if (lflag)
  800ade:	85 c9                	test   %ecx,%ecx
  800ae0:	75 17                	jne    800af9 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  800ae2:	8b 45 14             	mov    0x14(%ebp),%eax
  800ae5:	8b 10                	mov    (%eax),%edx
  800ae7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aec:	8d 40 04             	lea    0x4(%eax),%eax
  800aef:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800af2:	b8 10 00 00 00       	mov    $0x10,%eax
  800af7:	eb 8a                	jmp    800a83 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800af9:	8b 45 14             	mov    0x14(%ebp),%eax
  800afc:	8b 10                	mov    (%eax),%edx
  800afe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b03:	8d 40 04             	lea    0x4(%eax),%eax
  800b06:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800b09:	b8 10 00 00 00       	mov    $0x10,%eax
  800b0e:	e9 70 ff ff ff       	jmp    800a83 <vprintfmt+0x3bb>
			putch(ch, putdat);
  800b13:	83 ec 08             	sub    $0x8,%esp
  800b16:	53                   	push   %ebx
  800b17:	6a 25                	push   $0x25
  800b19:	ff d6                	call   *%esi
			break;
  800b1b:	83 c4 10             	add    $0x10,%esp
  800b1e:	e9 7a ff ff ff       	jmp    800a9d <vprintfmt+0x3d5>
			putch('%', putdat);
  800b23:	83 ec 08             	sub    $0x8,%esp
  800b26:	53                   	push   %ebx
  800b27:	6a 25                	push   $0x25
  800b29:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b2b:	83 c4 10             	add    $0x10,%esp
  800b2e:	89 f8                	mov    %edi,%eax
  800b30:	eb 03                	jmp    800b35 <vprintfmt+0x46d>
  800b32:	83 e8 01             	sub    $0x1,%eax
  800b35:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800b39:	75 f7                	jne    800b32 <vprintfmt+0x46a>
  800b3b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b3e:	e9 5a ff ff ff       	jmp    800a9d <vprintfmt+0x3d5>
}
  800b43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b46:	5b                   	pop    %ebx
  800b47:	5e                   	pop    %esi
  800b48:	5f                   	pop    %edi
  800b49:	5d                   	pop    %ebp
  800b4a:	c3                   	ret    

00800b4b <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b4b:	55                   	push   %ebp
  800b4c:	89 e5                	mov    %esp,%ebp
  800b4e:	83 ec 18             	sub    $0x18,%esp
  800b51:	8b 45 08             	mov    0x8(%ebp),%eax
  800b54:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b57:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b5a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b5e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b61:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b68:	85 c0                	test   %eax,%eax
  800b6a:	74 26                	je     800b92 <vsnprintf+0x47>
  800b6c:	85 d2                	test   %edx,%edx
  800b6e:	7e 22                	jle    800b92 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b70:	ff 75 14             	pushl  0x14(%ebp)
  800b73:	ff 75 10             	pushl  0x10(%ebp)
  800b76:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b79:	50                   	push   %eax
  800b7a:	68 8e 06 80 00       	push   $0x80068e
  800b7f:	e8 44 fb ff ff       	call   8006c8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b84:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b87:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b8d:	83 c4 10             	add    $0x10,%esp
}
  800b90:	c9                   	leave  
  800b91:	c3                   	ret    
		return -E_INVAL;
  800b92:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b97:	eb f7                	jmp    800b90 <vsnprintf+0x45>

00800b99 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b99:	55                   	push   %ebp
  800b9a:	89 e5                	mov    %esp,%ebp
  800b9c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b9f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800ba2:	50                   	push   %eax
  800ba3:	ff 75 10             	pushl  0x10(%ebp)
  800ba6:	ff 75 0c             	pushl  0xc(%ebp)
  800ba9:	ff 75 08             	pushl  0x8(%ebp)
  800bac:	e8 9a ff ff ff       	call   800b4b <vsnprintf>
	va_end(ap);

	return rc;
}
  800bb1:	c9                   	leave  
  800bb2:	c3                   	ret    

00800bb3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800bb9:	b8 00 00 00 00       	mov    $0x0,%eax
  800bbe:	eb 03                	jmp    800bc3 <strlen+0x10>
		n++;
  800bc0:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800bc3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800bc7:	75 f7                	jne    800bc0 <strlen+0xd>
	return n;
}
  800bc9:	5d                   	pop    %ebp
  800bca:	c3                   	ret    

00800bcb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bd1:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bd4:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd9:	eb 03                	jmp    800bde <strnlen+0x13>
		n++;
  800bdb:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bde:	39 d0                	cmp    %edx,%eax
  800be0:	74 06                	je     800be8 <strnlen+0x1d>
  800be2:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800be6:	75 f3                	jne    800bdb <strnlen+0x10>
	return n;
}
  800be8:	5d                   	pop    %ebp
  800be9:	c3                   	ret    

00800bea <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800bea:	55                   	push   %ebp
  800beb:	89 e5                	mov    %esp,%ebp
  800bed:	53                   	push   %ebx
  800bee:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800bf4:	89 c2                	mov    %eax,%edx
  800bf6:	83 c1 01             	add    $0x1,%ecx
  800bf9:	83 c2 01             	add    $0x1,%edx
  800bfc:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800c00:	88 5a ff             	mov    %bl,-0x1(%edx)
  800c03:	84 db                	test   %bl,%bl
  800c05:	75 ef                	jne    800bf6 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800c07:	5b                   	pop    %ebx
  800c08:	5d                   	pop    %ebp
  800c09:	c3                   	ret    

00800c0a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	53                   	push   %ebx
  800c0e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c11:	53                   	push   %ebx
  800c12:	e8 9c ff ff ff       	call   800bb3 <strlen>
  800c17:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800c1a:	ff 75 0c             	pushl  0xc(%ebp)
  800c1d:	01 d8                	add    %ebx,%eax
  800c1f:	50                   	push   %eax
  800c20:	e8 c5 ff ff ff       	call   800bea <strcpy>
	return dst;
}
  800c25:	89 d8                	mov    %ebx,%eax
  800c27:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c2a:	c9                   	leave  
  800c2b:	c3                   	ret    

00800c2c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	56                   	push   %esi
  800c30:	53                   	push   %ebx
  800c31:	8b 75 08             	mov    0x8(%ebp),%esi
  800c34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c37:	89 f3                	mov    %esi,%ebx
  800c39:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c3c:	89 f2                	mov    %esi,%edx
  800c3e:	eb 0f                	jmp    800c4f <strncpy+0x23>
		*dst++ = *src;
  800c40:	83 c2 01             	add    $0x1,%edx
  800c43:	0f b6 01             	movzbl (%ecx),%eax
  800c46:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c49:	80 39 01             	cmpb   $0x1,(%ecx)
  800c4c:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800c4f:	39 da                	cmp    %ebx,%edx
  800c51:	75 ed                	jne    800c40 <strncpy+0x14>
	}
	return ret;
}
  800c53:	89 f0                	mov    %esi,%eax
  800c55:	5b                   	pop    %ebx
  800c56:	5e                   	pop    %esi
  800c57:	5d                   	pop    %ebp
  800c58:	c3                   	ret    

00800c59 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c59:	55                   	push   %ebp
  800c5a:	89 e5                	mov    %esp,%ebp
  800c5c:	56                   	push   %esi
  800c5d:	53                   	push   %ebx
  800c5e:	8b 75 08             	mov    0x8(%ebp),%esi
  800c61:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c64:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c67:	89 f0                	mov    %esi,%eax
  800c69:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c6d:	85 c9                	test   %ecx,%ecx
  800c6f:	75 0b                	jne    800c7c <strlcpy+0x23>
  800c71:	eb 17                	jmp    800c8a <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800c73:	83 c2 01             	add    $0x1,%edx
  800c76:	83 c0 01             	add    $0x1,%eax
  800c79:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800c7c:	39 d8                	cmp    %ebx,%eax
  800c7e:	74 07                	je     800c87 <strlcpy+0x2e>
  800c80:	0f b6 0a             	movzbl (%edx),%ecx
  800c83:	84 c9                	test   %cl,%cl
  800c85:	75 ec                	jne    800c73 <strlcpy+0x1a>
		*dst = '\0';
  800c87:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800c8a:	29 f0                	sub    %esi,%eax
}
  800c8c:	5b                   	pop    %ebx
  800c8d:	5e                   	pop    %esi
  800c8e:	5d                   	pop    %ebp
  800c8f:	c3                   	ret    

00800c90 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c90:	55                   	push   %ebp
  800c91:	89 e5                	mov    %esp,%ebp
  800c93:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c96:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c99:	eb 06                	jmp    800ca1 <strcmp+0x11>
		p++, q++;
  800c9b:	83 c1 01             	add    $0x1,%ecx
  800c9e:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800ca1:	0f b6 01             	movzbl (%ecx),%eax
  800ca4:	84 c0                	test   %al,%al
  800ca6:	74 04                	je     800cac <strcmp+0x1c>
  800ca8:	3a 02                	cmp    (%edx),%al
  800caa:	74 ef                	je     800c9b <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800cac:	0f b6 c0             	movzbl %al,%eax
  800caf:	0f b6 12             	movzbl (%edx),%edx
  800cb2:	29 d0                	sub    %edx,%eax
}
  800cb4:	5d                   	pop    %ebp
  800cb5:	c3                   	ret    

00800cb6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800cb6:	55                   	push   %ebp
  800cb7:	89 e5                	mov    %esp,%ebp
  800cb9:	53                   	push   %ebx
  800cba:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cc0:	89 c3                	mov    %eax,%ebx
  800cc2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800cc5:	eb 06                	jmp    800ccd <strncmp+0x17>
		n--, p++, q++;
  800cc7:	83 c0 01             	add    $0x1,%eax
  800cca:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800ccd:	39 d8                	cmp    %ebx,%eax
  800ccf:	74 16                	je     800ce7 <strncmp+0x31>
  800cd1:	0f b6 08             	movzbl (%eax),%ecx
  800cd4:	84 c9                	test   %cl,%cl
  800cd6:	74 04                	je     800cdc <strncmp+0x26>
  800cd8:	3a 0a                	cmp    (%edx),%cl
  800cda:	74 eb                	je     800cc7 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800cdc:	0f b6 00             	movzbl (%eax),%eax
  800cdf:	0f b6 12             	movzbl (%edx),%edx
  800ce2:	29 d0                	sub    %edx,%eax
}
  800ce4:	5b                   	pop    %ebx
  800ce5:	5d                   	pop    %ebp
  800ce6:	c3                   	ret    
		return 0;
  800ce7:	b8 00 00 00 00       	mov    $0x0,%eax
  800cec:	eb f6                	jmp    800ce4 <strncmp+0x2e>

00800cee <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800cee:	55                   	push   %ebp
  800cef:	89 e5                	mov    %esp,%ebp
  800cf1:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cf8:	0f b6 10             	movzbl (%eax),%edx
  800cfb:	84 d2                	test   %dl,%dl
  800cfd:	74 09                	je     800d08 <strchr+0x1a>
		if (*s == c)
  800cff:	38 ca                	cmp    %cl,%dl
  800d01:	74 0a                	je     800d0d <strchr+0x1f>
	for (; *s; s++)
  800d03:	83 c0 01             	add    $0x1,%eax
  800d06:	eb f0                	jmp    800cf8 <strchr+0xa>
			return (char *) s;
	return 0;
  800d08:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d0d:	5d                   	pop    %ebp
  800d0e:	c3                   	ret    

00800d0f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d0f:	55                   	push   %ebp
  800d10:	89 e5                	mov    %esp,%ebp
  800d12:	8b 45 08             	mov    0x8(%ebp),%eax
  800d15:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d19:	eb 03                	jmp    800d1e <strfind+0xf>
  800d1b:	83 c0 01             	add    $0x1,%eax
  800d1e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800d21:	38 ca                	cmp    %cl,%dl
  800d23:	74 04                	je     800d29 <strfind+0x1a>
  800d25:	84 d2                	test   %dl,%dl
  800d27:	75 f2                	jne    800d1b <strfind+0xc>
			break;
	return (char *) s;
}
  800d29:	5d                   	pop    %ebp
  800d2a:	c3                   	ret    

00800d2b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d2b:	55                   	push   %ebp
  800d2c:	89 e5                	mov    %esp,%ebp
  800d2e:	57                   	push   %edi
  800d2f:	56                   	push   %esi
  800d30:	53                   	push   %ebx
  800d31:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d34:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d37:	85 c9                	test   %ecx,%ecx
  800d39:	74 13                	je     800d4e <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d3b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d41:	75 05                	jne    800d48 <memset+0x1d>
  800d43:	f6 c1 03             	test   $0x3,%cl
  800d46:	74 0d                	je     800d55 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d48:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d4b:	fc                   	cld    
  800d4c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d4e:	89 f8                	mov    %edi,%eax
  800d50:	5b                   	pop    %ebx
  800d51:	5e                   	pop    %esi
  800d52:	5f                   	pop    %edi
  800d53:	5d                   	pop    %ebp
  800d54:	c3                   	ret    
		c &= 0xFF;
  800d55:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d59:	89 d3                	mov    %edx,%ebx
  800d5b:	c1 e3 08             	shl    $0x8,%ebx
  800d5e:	89 d0                	mov    %edx,%eax
  800d60:	c1 e0 18             	shl    $0x18,%eax
  800d63:	89 d6                	mov    %edx,%esi
  800d65:	c1 e6 10             	shl    $0x10,%esi
  800d68:	09 f0                	or     %esi,%eax
  800d6a:	09 c2                	or     %eax,%edx
  800d6c:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800d6e:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800d71:	89 d0                	mov    %edx,%eax
  800d73:	fc                   	cld    
  800d74:	f3 ab                	rep stos %eax,%es:(%edi)
  800d76:	eb d6                	jmp    800d4e <memset+0x23>

00800d78 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d78:	55                   	push   %ebp
  800d79:	89 e5                	mov    %esp,%ebp
  800d7b:	57                   	push   %edi
  800d7c:	56                   	push   %esi
  800d7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d80:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d83:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d86:	39 c6                	cmp    %eax,%esi
  800d88:	73 35                	jae    800dbf <memmove+0x47>
  800d8a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d8d:	39 c2                	cmp    %eax,%edx
  800d8f:	76 2e                	jbe    800dbf <memmove+0x47>
		s += n;
		d += n;
  800d91:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d94:	89 d6                	mov    %edx,%esi
  800d96:	09 fe                	or     %edi,%esi
  800d98:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d9e:	74 0c                	je     800dac <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800da0:	83 ef 01             	sub    $0x1,%edi
  800da3:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800da6:	fd                   	std    
  800da7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800da9:	fc                   	cld    
  800daa:	eb 21                	jmp    800dcd <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800dac:	f6 c1 03             	test   $0x3,%cl
  800daf:	75 ef                	jne    800da0 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800db1:	83 ef 04             	sub    $0x4,%edi
  800db4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800db7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800dba:	fd                   	std    
  800dbb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800dbd:	eb ea                	jmp    800da9 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800dbf:	89 f2                	mov    %esi,%edx
  800dc1:	09 c2                	or     %eax,%edx
  800dc3:	f6 c2 03             	test   $0x3,%dl
  800dc6:	74 09                	je     800dd1 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800dc8:	89 c7                	mov    %eax,%edi
  800dca:	fc                   	cld    
  800dcb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800dcd:	5e                   	pop    %esi
  800dce:	5f                   	pop    %edi
  800dcf:	5d                   	pop    %ebp
  800dd0:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800dd1:	f6 c1 03             	test   $0x3,%cl
  800dd4:	75 f2                	jne    800dc8 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800dd6:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800dd9:	89 c7                	mov    %eax,%edi
  800ddb:	fc                   	cld    
  800ddc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800dde:	eb ed                	jmp    800dcd <memmove+0x55>

00800de0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800de0:	55                   	push   %ebp
  800de1:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800de3:	ff 75 10             	pushl  0x10(%ebp)
  800de6:	ff 75 0c             	pushl  0xc(%ebp)
  800de9:	ff 75 08             	pushl  0x8(%ebp)
  800dec:	e8 87 ff ff ff       	call   800d78 <memmove>
}
  800df1:	c9                   	leave  
  800df2:	c3                   	ret    

00800df3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800df3:	55                   	push   %ebp
  800df4:	89 e5                	mov    %esp,%ebp
  800df6:	56                   	push   %esi
  800df7:	53                   	push   %ebx
  800df8:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dfe:	89 c6                	mov    %eax,%esi
  800e00:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e03:	39 f0                	cmp    %esi,%eax
  800e05:	74 1c                	je     800e23 <memcmp+0x30>
		if (*s1 != *s2)
  800e07:	0f b6 08             	movzbl (%eax),%ecx
  800e0a:	0f b6 1a             	movzbl (%edx),%ebx
  800e0d:	38 d9                	cmp    %bl,%cl
  800e0f:	75 08                	jne    800e19 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800e11:	83 c0 01             	add    $0x1,%eax
  800e14:	83 c2 01             	add    $0x1,%edx
  800e17:	eb ea                	jmp    800e03 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800e19:	0f b6 c1             	movzbl %cl,%eax
  800e1c:	0f b6 db             	movzbl %bl,%ebx
  800e1f:	29 d8                	sub    %ebx,%eax
  800e21:	eb 05                	jmp    800e28 <memcmp+0x35>
	}

	return 0;
  800e23:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e28:	5b                   	pop    %ebx
  800e29:	5e                   	pop    %esi
  800e2a:	5d                   	pop    %ebp
  800e2b:	c3                   	ret    

00800e2c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e2c:	55                   	push   %ebp
  800e2d:	89 e5                	mov    %esp,%ebp
  800e2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800e35:	89 c2                	mov    %eax,%edx
  800e37:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e3a:	39 d0                	cmp    %edx,%eax
  800e3c:	73 09                	jae    800e47 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e3e:	38 08                	cmp    %cl,(%eax)
  800e40:	74 05                	je     800e47 <memfind+0x1b>
	for (; s < ends; s++)
  800e42:	83 c0 01             	add    $0x1,%eax
  800e45:	eb f3                	jmp    800e3a <memfind+0xe>
			break;
	return (void *) s;
}
  800e47:	5d                   	pop    %ebp
  800e48:	c3                   	ret    

00800e49 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e49:	55                   	push   %ebp
  800e4a:	89 e5                	mov    %esp,%ebp
  800e4c:	57                   	push   %edi
  800e4d:	56                   	push   %esi
  800e4e:	53                   	push   %ebx
  800e4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e52:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e55:	eb 03                	jmp    800e5a <strtol+0x11>
		s++;
  800e57:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800e5a:	0f b6 01             	movzbl (%ecx),%eax
  800e5d:	3c 20                	cmp    $0x20,%al
  800e5f:	74 f6                	je     800e57 <strtol+0xe>
  800e61:	3c 09                	cmp    $0x9,%al
  800e63:	74 f2                	je     800e57 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800e65:	3c 2b                	cmp    $0x2b,%al
  800e67:	74 2e                	je     800e97 <strtol+0x4e>
	int neg = 0;
  800e69:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800e6e:	3c 2d                	cmp    $0x2d,%al
  800e70:	74 2f                	je     800ea1 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e72:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800e78:	75 05                	jne    800e7f <strtol+0x36>
  800e7a:	80 39 30             	cmpb   $0x30,(%ecx)
  800e7d:	74 2c                	je     800eab <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e7f:	85 db                	test   %ebx,%ebx
  800e81:	75 0a                	jne    800e8d <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e83:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800e88:	80 39 30             	cmpb   $0x30,(%ecx)
  800e8b:	74 28                	je     800eb5 <strtol+0x6c>
		base = 10;
  800e8d:	b8 00 00 00 00       	mov    $0x0,%eax
  800e92:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800e95:	eb 50                	jmp    800ee7 <strtol+0x9e>
		s++;
  800e97:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800e9a:	bf 00 00 00 00       	mov    $0x0,%edi
  800e9f:	eb d1                	jmp    800e72 <strtol+0x29>
		s++, neg = 1;
  800ea1:	83 c1 01             	add    $0x1,%ecx
  800ea4:	bf 01 00 00 00       	mov    $0x1,%edi
  800ea9:	eb c7                	jmp    800e72 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800eab:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800eaf:	74 0e                	je     800ebf <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800eb1:	85 db                	test   %ebx,%ebx
  800eb3:	75 d8                	jne    800e8d <strtol+0x44>
		s++, base = 8;
  800eb5:	83 c1 01             	add    $0x1,%ecx
  800eb8:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ebd:	eb ce                	jmp    800e8d <strtol+0x44>
		s += 2, base = 16;
  800ebf:	83 c1 02             	add    $0x2,%ecx
  800ec2:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ec7:	eb c4                	jmp    800e8d <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800ec9:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ecc:	89 f3                	mov    %esi,%ebx
  800ece:	80 fb 19             	cmp    $0x19,%bl
  800ed1:	77 29                	ja     800efc <strtol+0xb3>
			dig = *s - 'a' + 10;
  800ed3:	0f be d2             	movsbl %dl,%edx
  800ed6:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ed9:	3b 55 10             	cmp    0x10(%ebp),%edx
  800edc:	7d 30                	jge    800f0e <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ede:	83 c1 01             	add    $0x1,%ecx
  800ee1:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ee5:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ee7:	0f b6 11             	movzbl (%ecx),%edx
  800eea:	8d 72 d0             	lea    -0x30(%edx),%esi
  800eed:	89 f3                	mov    %esi,%ebx
  800eef:	80 fb 09             	cmp    $0x9,%bl
  800ef2:	77 d5                	ja     800ec9 <strtol+0x80>
			dig = *s - '0';
  800ef4:	0f be d2             	movsbl %dl,%edx
  800ef7:	83 ea 30             	sub    $0x30,%edx
  800efa:	eb dd                	jmp    800ed9 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800efc:	8d 72 bf             	lea    -0x41(%edx),%esi
  800eff:	89 f3                	mov    %esi,%ebx
  800f01:	80 fb 19             	cmp    $0x19,%bl
  800f04:	77 08                	ja     800f0e <strtol+0xc5>
			dig = *s - 'A' + 10;
  800f06:	0f be d2             	movsbl %dl,%edx
  800f09:	83 ea 37             	sub    $0x37,%edx
  800f0c:	eb cb                	jmp    800ed9 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800f0e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f12:	74 05                	je     800f19 <strtol+0xd0>
		*endptr = (char *) s;
  800f14:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f17:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800f19:	89 c2                	mov    %eax,%edx
  800f1b:	f7 da                	neg    %edx
  800f1d:	85 ff                	test   %edi,%edi
  800f1f:	0f 45 c2             	cmovne %edx,%eax
}
  800f22:	5b                   	pop    %ebx
  800f23:	5e                   	pop    %esi
  800f24:	5f                   	pop    %edi
  800f25:	5d                   	pop    %ebp
  800f26:	c3                   	ret    

00800f27 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800f27:	55                   	push   %ebp
  800f28:	89 e5                	mov    %esp,%ebp
  800f2a:	57                   	push   %edi
  800f2b:	56                   	push   %esi
  800f2c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f2d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f32:	8b 55 08             	mov    0x8(%ebp),%edx
  800f35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f38:	89 c3                	mov    %eax,%ebx
  800f3a:	89 c7                	mov    %eax,%edi
  800f3c:	89 c6                	mov    %eax,%esi
  800f3e:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800f40:	5b                   	pop    %ebx
  800f41:	5e                   	pop    %esi
  800f42:	5f                   	pop    %edi
  800f43:	5d                   	pop    %ebp
  800f44:	c3                   	ret    

00800f45 <sys_cgetc>:

int
sys_cgetc(void)
{
  800f45:	55                   	push   %ebp
  800f46:	89 e5                	mov    %esp,%ebp
  800f48:	57                   	push   %edi
  800f49:	56                   	push   %esi
  800f4a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f50:	b8 01 00 00 00       	mov    $0x1,%eax
  800f55:	89 d1                	mov    %edx,%ecx
  800f57:	89 d3                	mov    %edx,%ebx
  800f59:	89 d7                	mov    %edx,%edi
  800f5b:	89 d6                	mov    %edx,%esi
  800f5d:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800f5f:	5b                   	pop    %ebx
  800f60:	5e                   	pop    %esi
  800f61:	5f                   	pop    %edi
  800f62:	5d                   	pop    %ebp
  800f63:	c3                   	ret    

00800f64 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800f64:	55                   	push   %ebp
  800f65:	89 e5                	mov    %esp,%ebp
  800f67:	57                   	push   %edi
  800f68:	56                   	push   %esi
  800f69:	53                   	push   %ebx
  800f6a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f6d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f72:	8b 55 08             	mov    0x8(%ebp),%edx
  800f75:	b8 03 00 00 00       	mov    $0x3,%eax
  800f7a:	89 cb                	mov    %ecx,%ebx
  800f7c:	89 cf                	mov    %ecx,%edi
  800f7e:	89 ce                	mov    %ecx,%esi
  800f80:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f82:	85 c0                	test   %eax,%eax
  800f84:	7f 08                	jg     800f8e <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f89:	5b                   	pop    %ebx
  800f8a:	5e                   	pop    %esi
  800f8b:	5f                   	pop    %edi
  800f8c:	5d                   	pop    %ebp
  800f8d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f8e:	83 ec 0c             	sub    $0xc,%esp
  800f91:	50                   	push   %eax
  800f92:	6a 03                	push   $0x3
  800f94:	68 9f 2e 80 00       	push   $0x802e9f
  800f99:	6a 23                	push   $0x23
  800f9b:	68 bc 2e 80 00       	push   $0x802ebc
  800fa0:	e8 4b f5 ff ff       	call   8004f0 <_panic>

00800fa5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800fa5:	55                   	push   %ebp
  800fa6:	89 e5                	mov    %esp,%ebp
  800fa8:	57                   	push   %edi
  800fa9:	56                   	push   %esi
  800faa:	53                   	push   %ebx
	asm volatile("int %1\n"
  800fab:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb0:	b8 02 00 00 00       	mov    $0x2,%eax
  800fb5:	89 d1                	mov    %edx,%ecx
  800fb7:	89 d3                	mov    %edx,%ebx
  800fb9:	89 d7                	mov    %edx,%edi
  800fbb:	89 d6                	mov    %edx,%esi
  800fbd:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800fbf:	5b                   	pop    %ebx
  800fc0:	5e                   	pop    %esi
  800fc1:	5f                   	pop    %edi
  800fc2:	5d                   	pop    %ebp
  800fc3:	c3                   	ret    

00800fc4 <sys_yield>:

void
sys_yield(void)
{
  800fc4:	55                   	push   %ebp
  800fc5:	89 e5                	mov    %esp,%ebp
  800fc7:	57                   	push   %edi
  800fc8:	56                   	push   %esi
  800fc9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800fca:	ba 00 00 00 00       	mov    $0x0,%edx
  800fcf:	b8 0b 00 00 00       	mov    $0xb,%eax
  800fd4:	89 d1                	mov    %edx,%ecx
  800fd6:	89 d3                	mov    %edx,%ebx
  800fd8:	89 d7                	mov    %edx,%edi
  800fda:	89 d6                	mov    %edx,%esi
  800fdc:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800fde:	5b                   	pop    %ebx
  800fdf:	5e                   	pop    %esi
  800fe0:	5f                   	pop    %edi
  800fe1:	5d                   	pop    %ebp
  800fe2:	c3                   	ret    

00800fe3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800fe3:	55                   	push   %ebp
  800fe4:	89 e5                	mov    %esp,%ebp
  800fe6:	57                   	push   %edi
  800fe7:	56                   	push   %esi
  800fe8:	53                   	push   %ebx
  800fe9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800fec:	be 00 00 00 00       	mov    $0x0,%esi
  800ff1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ff7:	b8 04 00 00 00       	mov    $0x4,%eax
  800ffc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fff:	89 f7                	mov    %esi,%edi
  801001:	cd 30                	int    $0x30
	if(check && ret > 0)
  801003:	85 c0                	test   %eax,%eax
  801005:	7f 08                	jg     80100f <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801007:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80100a:	5b                   	pop    %ebx
  80100b:	5e                   	pop    %esi
  80100c:	5f                   	pop    %edi
  80100d:	5d                   	pop    %ebp
  80100e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80100f:	83 ec 0c             	sub    $0xc,%esp
  801012:	50                   	push   %eax
  801013:	6a 04                	push   $0x4
  801015:	68 9f 2e 80 00       	push   $0x802e9f
  80101a:	6a 23                	push   $0x23
  80101c:	68 bc 2e 80 00       	push   $0x802ebc
  801021:	e8 ca f4 ff ff       	call   8004f0 <_panic>

00801026 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801026:	55                   	push   %ebp
  801027:	89 e5                	mov    %esp,%ebp
  801029:	57                   	push   %edi
  80102a:	56                   	push   %esi
  80102b:	53                   	push   %ebx
  80102c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80102f:	8b 55 08             	mov    0x8(%ebp),%edx
  801032:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801035:	b8 05 00 00 00       	mov    $0x5,%eax
  80103a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80103d:	8b 7d 14             	mov    0x14(%ebp),%edi
  801040:	8b 75 18             	mov    0x18(%ebp),%esi
  801043:	cd 30                	int    $0x30
	if(check && ret > 0)
  801045:	85 c0                	test   %eax,%eax
  801047:	7f 08                	jg     801051 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801049:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80104c:	5b                   	pop    %ebx
  80104d:	5e                   	pop    %esi
  80104e:	5f                   	pop    %edi
  80104f:	5d                   	pop    %ebp
  801050:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801051:	83 ec 0c             	sub    $0xc,%esp
  801054:	50                   	push   %eax
  801055:	6a 05                	push   $0x5
  801057:	68 9f 2e 80 00       	push   $0x802e9f
  80105c:	6a 23                	push   $0x23
  80105e:	68 bc 2e 80 00       	push   $0x802ebc
  801063:	e8 88 f4 ff ff       	call   8004f0 <_panic>

00801068 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801068:	55                   	push   %ebp
  801069:	89 e5                	mov    %esp,%ebp
  80106b:	57                   	push   %edi
  80106c:	56                   	push   %esi
  80106d:	53                   	push   %ebx
  80106e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801071:	bb 00 00 00 00       	mov    $0x0,%ebx
  801076:	8b 55 08             	mov    0x8(%ebp),%edx
  801079:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80107c:	b8 06 00 00 00       	mov    $0x6,%eax
  801081:	89 df                	mov    %ebx,%edi
  801083:	89 de                	mov    %ebx,%esi
  801085:	cd 30                	int    $0x30
	if(check && ret > 0)
  801087:	85 c0                	test   %eax,%eax
  801089:	7f 08                	jg     801093 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80108b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80108e:	5b                   	pop    %ebx
  80108f:	5e                   	pop    %esi
  801090:	5f                   	pop    %edi
  801091:	5d                   	pop    %ebp
  801092:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801093:	83 ec 0c             	sub    $0xc,%esp
  801096:	50                   	push   %eax
  801097:	6a 06                	push   $0x6
  801099:	68 9f 2e 80 00       	push   $0x802e9f
  80109e:	6a 23                	push   $0x23
  8010a0:	68 bc 2e 80 00       	push   $0x802ebc
  8010a5:	e8 46 f4 ff ff       	call   8004f0 <_panic>

008010aa <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8010aa:	55                   	push   %ebp
  8010ab:	89 e5                	mov    %esp,%ebp
  8010ad:	57                   	push   %edi
  8010ae:	56                   	push   %esi
  8010af:	53                   	push   %ebx
  8010b0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8010b3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8010bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010be:	b8 08 00 00 00       	mov    $0x8,%eax
  8010c3:	89 df                	mov    %ebx,%edi
  8010c5:	89 de                	mov    %ebx,%esi
  8010c7:	cd 30                	int    $0x30
	if(check && ret > 0)
  8010c9:	85 c0                	test   %eax,%eax
  8010cb:	7f 08                	jg     8010d5 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8010cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d0:	5b                   	pop    %ebx
  8010d1:	5e                   	pop    %esi
  8010d2:	5f                   	pop    %edi
  8010d3:	5d                   	pop    %ebp
  8010d4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8010d5:	83 ec 0c             	sub    $0xc,%esp
  8010d8:	50                   	push   %eax
  8010d9:	6a 08                	push   $0x8
  8010db:	68 9f 2e 80 00       	push   $0x802e9f
  8010e0:	6a 23                	push   $0x23
  8010e2:	68 bc 2e 80 00       	push   $0x802ebc
  8010e7:	e8 04 f4 ff ff       	call   8004f0 <_panic>

008010ec <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8010ec:	55                   	push   %ebp
  8010ed:	89 e5                	mov    %esp,%ebp
  8010ef:	57                   	push   %edi
  8010f0:	56                   	push   %esi
  8010f1:	53                   	push   %ebx
  8010f2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8010f5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8010fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801100:	b8 09 00 00 00       	mov    $0x9,%eax
  801105:	89 df                	mov    %ebx,%edi
  801107:	89 de                	mov    %ebx,%esi
  801109:	cd 30                	int    $0x30
	if(check && ret > 0)
  80110b:	85 c0                	test   %eax,%eax
  80110d:	7f 08                	jg     801117 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80110f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801112:	5b                   	pop    %ebx
  801113:	5e                   	pop    %esi
  801114:	5f                   	pop    %edi
  801115:	5d                   	pop    %ebp
  801116:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801117:	83 ec 0c             	sub    $0xc,%esp
  80111a:	50                   	push   %eax
  80111b:	6a 09                	push   $0x9
  80111d:	68 9f 2e 80 00       	push   $0x802e9f
  801122:	6a 23                	push   $0x23
  801124:	68 bc 2e 80 00       	push   $0x802ebc
  801129:	e8 c2 f3 ff ff       	call   8004f0 <_panic>

0080112e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80112e:	55                   	push   %ebp
  80112f:	89 e5                	mov    %esp,%ebp
  801131:	57                   	push   %edi
  801132:	56                   	push   %esi
  801133:	53                   	push   %ebx
  801134:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801137:	bb 00 00 00 00       	mov    $0x0,%ebx
  80113c:	8b 55 08             	mov    0x8(%ebp),%edx
  80113f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801142:	b8 0a 00 00 00       	mov    $0xa,%eax
  801147:	89 df                	mov    %ebx,%edi
  801149:	89 de                	mov    %ebx,%esi
  80114b:	cd 30                	int    $0x30
	if(check && ret > 0)
  80114d:	85 c0                	test   %eax,%eax
  80114f:	7f 08                	jg     801159 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801151:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801154:	5b                   	pop    %ebx
  801155:	5e                   	pop    %esi
  801156:	5f                   	pop    %edi
  801157:	5d                   	pop    %ebp
  801158:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801159:	83 ec 0c             	sub    $0xc,%esp
  80115c:	50                   	push   %eax
  80115d:	6a 0a                	push   $0xa
  80115f:	68 9f 2e 80 00       	push   $0x802e9f
  801164:	6a 23                	push   $0x23
  801166:	68 bc 2e 80 00       	push   $0x802ebc
  80116b:	e8 80 f3 ff ff       	call   8004f0 <_panic>

00801170 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801170:	55                   	push   %ebp
  801171:	89 e5                	mov    %esp,%ebp
  801173:	57                   	push   %edi
  801174:	56                   	push   %esi
  801175:	53                   	push   %ebx
	asm volatile("int %1\n"
  801176:	8b 55 08             	mov    0x8(%ebp),%edx
  801179:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80117c:	b8 0c 00 00 00       	mov    $0xc,%eax
  801181:	be 00 00 00 00       	mov    $0x0,%esi
  801186:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801189:	8b 7d 14             	mov    0x14(%ebp),%edi
  80118c:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80118e:	5b                   	pop    %ebx
  80118f:	5e                   	pop    %esi
  801190:	5f                   	pop    %edi
  801191:	5d                   	pop    %ebp
  801192:	c3                   	ret    

00801193 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801193:	55                   	push   %ebp
  801194:	89 e5                	mov    %esp,%ebp
  801196:	57                   	push   %edi
  801197:	56                   	push   %esi
  801198:	53                   	push   %ebx
  801199:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80119c:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8011a4:	b8 0d 00 00 00       	mov    $0xd,%eax
  8011a9:	89 cb                	mov    %ecx,%ebx
  8011ab:	89 cf                	mov    %ecx,%edi
  8011ad:	89 ce                	mov    %ecx,%esi
  8011af:	cd 30                	int    $0x30
	if(check && ret > 0)
  8011b1:	85 c0                	test   %eax,%eax
  8011b3:	7f 08                	jg     8011bd <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8011b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b8:	5b                   	pop    %ebx
  8011b9:	5e                   	pop    %esi
  8011ba:	5f                   	pop    %edi
  8011bb:	5d                   	pop    %ebp
  8011bc:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8011bd:	83 ec 0c             	sub    $0xc,%esp
  8011c0:	50                   	push   %eax
  8011c1:	6a 0d                	push   $0xd
  8011c3:	68 9f 2e 80 00       	push   $0x802e9f
  8011c8:	6a 23                	push   $0x23
  8011ca:	68 bc 2e 80 00       	push   $0x802ebc
  8011cf:	e8 1c f3 ff ff       	call   8004f0 <_panic>

008011d4 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8011d4:	55                   	push   %ebp
  8011d5:	89 e5                	mov    %esp,%ebp
  8011d7:	53                   	push   %ebx
  8011d8:	83 ec 04             	sub    $0x4,%esp
  8011db:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  8011de:	8b 02                	mov    (%edx),%eax
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  8011e0:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  8011e4:	0f 84 9c 00 00 00    	je     801286 <pgfault+0xb2>
  8011ea:	89 c2                	mov    %eax,%edx
  8011ec:	c1 ea 16             	shr    $0x16,%edx
  8011ef:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011f6:	f6 c2 01             	test   $0x1,%dl
  8011f9:	0f 84 87 00 00 00    	je     801286 <pgfault+0xb2>
  8011ff:	89 c2                	mov    %eax,%edx
  801201:	c1 ea 0c             	shr    $0xc,%edx
  801204:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  80120b:	f6 c1 01             	test   $0x1,%cl
  80120e:	74 76                	je     801286 <pgfault+0xb2>
  801210:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801217:	f6 c6 08             	test   $0x8,%dh
  80121a:	74 6a                	je     801286 <pgfault+0xb2>
		panic("not copy-on-write");
	addr = ROUNDDOWN(addr, PGSIZE);
  80121c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801221:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P) < 0)
  801223:	83 ec 04             	sub    $0x4,%esp
  801226:	6a 07                	push   $0x7
  801228:	68 00 f0 7f 00       	push   $0x7ff000
  80122d:	6a 00                	push   $0x0
  80122f:	e8 af fd ff ff       	call   800fe3 <sys_page_alloc>
  801234:	83 c4 10             	add    $0x10,%esp
  801237:	85 c0                	test   %eax,%eax
  801239:	78 5f                	js     80129a <pgfault+0xc6>
		panic("sys_page_alloc");
	memcpy(PFTEMP, addr, PGSIZE);
  80123b:	83 ec 04             	sub    $0x4,%esp
  80123e:	68 00 10 00 00       	push   $0x1000
  801243:	53                   	push   %ebx
  801244:	68 00 f0 7f 00       	push   $0x7ff000
  801249:	e8 92 fb ff ff       	call   800de0 <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P) < 0)
  80124e:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801255:	53                   	push   %ebx
  801256:	6a 00                	push   $0x0
  801258:	68 00 f0 7f 00       	push   $0x7ff000
  80125d:	6a 00                	push   $0x0
  80125f:	e8 c2 fd ff ff       	call   801026 <sys_page_map>
  801264:	83 c4 20             	add    $0x20,%esp
  801267:	85 c0                	test   %eax,%eax
  801269:	78 43                	js     8012ae <pgfault+0xda>
		panic("sys_page_map");
	if (sys_page_unmap(0, PFTEMP) < 0)
  80126b:	83 ec 08             	sub    $0x8,%esp
  80126e:	68 00 f0 7f 00       	push   $0x7ff000
  801273:	6a 00                	push   $0x0
  801275:	e8 ee fd ff ff       	call   801068 <sys_page_unmap>
  80127a:	83 c4 10             	add    $0x10,%esp
  80127d:	85 c0                	test   %eax,%eax
  80127f:	78 41                	js     8012c2 <pgfault+0xee>
		panic("sys_page_unmap");
	return;
}
  801281:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801284:	c9                   	leave  
  801285:	c3                   	ret    
		panic("not copy-on-write");
  801286:	83 ec 04             	sub    $0x4,%esp
  801289:	68 ca 2e 80 00       	push   $0x802eca
  80128e:	6a 25                	push   $0x25
  801290:	68 dc 2e 80 00       	push   $0x802edc
  801295:	e8 56 f2 ff ff       	call   8004f0 <_panic>
		panic("sys_page_alloc");
  80129a:	83 ec 04             	sub    $0x4,%esp
  80129d:	68 e7 2e 80 00       	push   $0x802ee7
  8012a2:	6a 28                	push   $0x28
  8012a4:	68 dc 2e 80 00       	push   $0x802edc
  8012a9:	e8 42 f2 ff ff       	call   8004f0 <_panic>
		panic("sys_page_map");
  8012ae:	83 ec 04             	sub    $0x4,%esp
  8012b1:	68 f6 2e 80 00       	push   $0x802ef6
  8012b6:	6a 2b                	push   $0x2b
  8012b8:	68 dc 2e 80 00       	push   $0x802edc
  8012bd:	e8 2e f2 ff ff       	call   8004f0 <_panic>
		panic("sys_page_unmap");
  8012c2:	83 ec 04             	sub    $0x4,%esp
  8012c5:	68 03 2f 80 00       	push   $0x802f03
  8012ca:	6a 2d                	push   $0x2d
  8012cc:	68 dc 2e 80 00       	push   $0x802edc
  8012d1:	e8 1a f2 ff ff       	call   8004f0 <_panic>

008012d6 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8012d6:	55                   	push   %ebp
  8012d7:	89 e5                	mov    %esp,%ebp
  8012d9:	57                   	push   %edi
  8012da:	56                   	push   %esi
  8012db:	53                   	push   %ebx
  8012dc:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  8012df:	68 d4 11 80 00       	push   $0x8011d4
  8012e4:	e8 41 13 00 00       	call   80262a <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8012e9:	b8 07 00 00 00       	mov    $0x7,%eax
  8012ee:	cd 30                	int    $0x30
  8012f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid;
	uint32_t addr;
	envid = sys_exofork();
	if (envid == 0) {
  8012f3:	83 c4 10             	add    $0x10,%esp
  8012f6:	85 c0                	test   %eax,%eax
  8012f8:	74 12                	je     80130c <fork+0x36>
  8012fa:	89 c7                	mov    %eax,%edi
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	if (envid < 0)
  8012fc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801300:	78 26                	js     801328 <fork+0x52>
		panic("sys_exofork: %e", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  801302:	bb 00 00 00 00       	mov    $0x0,%ebx
  801307:	e9 94 00 00 00       	jmp    8013a0 <fork+0xca>
		thisenv = &envs[ENVX(sys_getenvid())];
  80130c:	e8 94 fc ff ff       	call   800fa5 <sys_getenvid>
  801311:	25 ff 03 00 00       	and    $0x3ff,%eax
  801316:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801319:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80131e:	a3 04 50 80 00       	mov    %eax,0x805004
		return 0;
  801323:	e9 51 01 00 00       	jmp    801479 <fork+0x1a3>
		panic("sys_exofork: %e", envid);
  801328:	ff 75 e4             	pushl  -0x1c(%ebp)
  80132b:	68 12 2f 80 00       	push   $0x802f12
  801330:	6a 6e                	push   $0x6e
  801332:	68 dc 2e 80 00       	push   $0x802edc
  801337:	e8 b4 f1 ff ff       	call   8004f0 <_panic>
        	sys_page_map(0, addr, envid, addr, PTE_SYSCALL);
  80133c:	83 ec 0c             	sub    $0xc,%esp
  80133f:	68 07 0e 00 00       	push   $0xe07
  801344:	56                   	push   %esi
  801345:	57                   	push   %edi
  801346:	56                   	push   %esi
  801347:	6a 00                	push   $0x0
  801349:	e8 d8 fc ff ff       	call   801026 <sys_page_map>
  80134e:	83 c4 20             	add    $0x20,%esp
  801351:	eb 3b                	jmp    80138e <fork+0xb8>
        	if ((r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  801353:	83 ec 0c             	sub    $0xc,%esp
  801356:	68 05 08 00 00       	push   $0x805
  80135b:	56                   	push   %esi
  80135c:	57                   	push   %edi
  80135d:	56                   	push   %esi
  80135e:	6a 00                	push   $0x0
  801360:	e8 c1 fc ff ff       	call   801026 <sys_page_map>
  801365:	83 c4 20             	add    $0x20,%esp
  801368:	85 c0                	test   %eax,%eax
  80136a:	0f 88 a9 00 00 00    	js     801419 <fork+0x143>
        	if ((r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  801370:	83 ec 0c             	sub    $0xc,%esp
  801373:	68 05 08 00 00       	push   $0x805
  801378:	56                   	push   %esi
  801379:	6a 00                	push   $0x0
  80137b:	56                   	push   %esi
  80137c:	6a 00                	push   $0x0
  80137e:	e8 a3 fc ff ff       	call   801026 <sys_page_map>
  801383:	83 c4 20             	add    $0x20,%esp
  801386:	85 c0                	test   %eax,%eax
  801388:	0f 88 9d 00 00 00    	js     80142b <fork+0x155>
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  80138e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801394:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80139a:	0f 84 9d 00 00 00    	je     80143d <fork+0x167>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  8013a0:	89 d8                	mov    %ebx,%eax
  8013a2:	c1 e8 16             	shr    $0x16,%eax
  8013a5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013ac:	a8 01                	test   $0x1,%al
  8013ae:	74 de                	je     80138e <fork+0xb8>
  8013b0:	89 d8                	mov    %ebx,%eax
  8013b2:	c1 e8 0c             	shr    $0xc,%eax
  8013b5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013bc:	f6 c2 01             	test   $0x1,%dl
  8013bf:	74 cd                	je     80138e <fork+0xb8>
			&& (uvpt[PGNUM(addr)] & PTE_U)) {
  8013c1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013c8:	f6 c2 04             	test   $0x4,%dl
  8013cb:	74 c1                	je     80138e <fork+0xb8>
	void *addr = (void*) (pn*PGSIZE);
  8013cd:	89 c6                	mov    %eax,%esi
  8013cf:	c1 e6 0c             	shl    $0xc,%esi
    	if (uvpt[pn] & PTE_SHARE) {
  8013d2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013d9:	f6 c6 04             	test   $0x4,%dh
  8013dc:	0f 85 5a ff ff ff    	jne    80133c <fork+0x66>
    	} else if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  8013e2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013e9:	f6 c2 02             	test   $0x2,%dl
  8013ec:	0f 85 61 ff ff ff    	jne    801353 <fork+0x7d>
  8013f2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013f9:	f6 c4 08             	test   $0x8,%ah
  8013fc:	0f 85 51 ff ff ff    	jne    801353 <fork+0x7d>
        		sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  801402:	83 ec 0c             	sub    $0xc,%esp
  801405:	6a 05                	push   $0x5
  801407:	56                   	push   %esi
  801408:	57                   	push   %edi
  801409:	56                   	push   %esi
  80140a:	6a 00                	push   $0x0
  80140c:	e8 15 fc ff ff       	call   801026 <sys_page_map>
  801411:	83 c4 20             	add    $0x20,%esp
  801414:	e9 75 ff ff ff       	jmp    80138e <fork+0xb8>
            		panic("sys_page_map：%e", r);
  801419:	50                   	push   %eax
  80141a:	68 22 2f 80 00       	push   $0x802f22
  80141f:	6a 47                	push   $0x47
  801421:	68 dc 2e 80 00       	push   $0x802edc
  801426:	e8 c5 f0 ff ff       	call   8004f0 <_panic>
            		panic("sys_page_map：%e", r);
  80142b:	50                   	push   %eax
  80142c:	68 22 2f 80 00       	push   $0x802f22
  801431:	6a 49                	push   $0x49
  801433:	68 dc 2e 80 00       	push   $0x802edc
  801438:	e8 b3 f0 ff ff       	call   8004f0 <_panic>
			duppage(envid, PGNUM(addr));
		}

	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  80143d:	83 ec 04             	sub    $0x4,%esp
  801440:	6a 07                	push   $0x7
  801442:	68 00 f0 bf ee       	push   $0xeebff000
  801447:	ff 75 e4             	pushl  -0x1c(%ebp)
  80144a:	e8 94 fb ff ff       	call   800fe3 <sys_page_alloc>
  80144f:	83 c4 10             	add    $0x10,%esp
  801452:	85 c0                	test   %eax,%eax
  801454:	78 2e                	js     801484 <fork+0x1ae>
		panic("1");
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801456:	83 ec 08             	sub    $0x8,%esp
  801459:	68 99 26 80 00       	push   $0x802699
  80145e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801461:	57                   	push   %edi
  801462:	e8 c7 fc ff ff       	call   80112e <sys_env_set_pgfault_upcall>

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  801467:	83 c4 08             	add    $0x8,%esp
  80146a:	6a 02                	push   $0x2
  80146c:	57                   	push   %edi
  80146d:	e8 38 fc ff ff       	call   8010aa <sys_env_set_status>
  801472:	83 c4 10             	add    $0x10,%esp
  801475:	85 c0                	test   %eax,%eax
  801477:	78 1f                	js     801498 <fork+0x1c2>
		panic("sys_env_set_status");

	return envid;
	panic("fork not implemented");
}
  801479:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80147c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80147f:	5b                   	pop    %ebx
  801480:	5e                   	pop    %esi
  801481:	5f                   	pop    %edi
  801482:	5d                   	pop    %ebp
  801483:	c3                   	ret    
		panic("1");
  801484:	83 ec 04             	sub    $0x4,%esp
  801487:	68 34 2f 80 00       	push   $0x802f34
  80148c:	6a 77                	push   $0x77
  80148e:	68 dc 2e 80 00       	push   $0x802edc
  801493:	e8 58 f0 ff ff       	call   8004f0 <_panic>
		panic("sys_env_set_status");
  801498:	83 ec 04             	sub    $0x4,%esp
  80149b:	68 36 2f 80 00       	push   $0x802f36
  8014a0:	6a 7c                	push   $0x7c
  8014a2:	68 dc 2e 80 00       	push   $0x802edc
  8014a7:	e8 44 f0 ff ff       	call   8004f0 <_panic>

008014ac <sfork>:

// Challenge!
int
sfork(void)
{
  8014ac:	55                   	push   %ebp
  8014ad:	89 e5                	mov    %esp,%ebp
  8014af:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8014b2:	68 49 2f 80 00       	push   $0x802f49
  8014b7:	68 86 00 00 00       	push   $0x86
  8014bc:	68 dc 2e 80 00       	push   $0x802edc
  8014c1:	e8 2a f0 ff ff       	call   8004f0 <_panic>

008014c6 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8014c6:	55                   	push   %ebp
  8014c7:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8014cc:	05 00 00 00 30       	add    $0x30000000,%eax
  8014d1:	c1 e8 0c             	shr    $0xc,%eax
}
  8014d4:	5d                   	pop    %ebp
  8014d5:	c3                   	ret    

008014d6 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8014d6:	55                   	push   %ebp
  8014d7:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8014dc:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8014e1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8014e6:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8014eb:	5d                   	pop    %ebp
  8014ec:	c3                   	ret    

008014ed <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8014ed:	55                   	push   %ebp
  8014ee:	89 e5                	mov    %esp,%ebp
  8014f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014f3:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8014f8:	89 c2                	mov    %eax,%edx
  8014fa:	c1 ea 16             	shr    $0x16,%edx
  8014fd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801504:	f6 c2 01             	test   $0x1,%dl
  801507:	74 2a                	je     801533 <fd_alloc+0x46>
  801509:	89 c2                	mov    %eax,%edx
  80150b:	c1 ea 0c             	shr    $0xc,%edx
  80150e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801515:	f6 c2 01             	test   $0x1,%dl
  801518:	74 19                	je     801533 <fd_alloc+0x46>
  80151a:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80151f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801524:	75 d2                	jne    8014f8 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801526:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80152c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801531:	eb 07                	jmp    80153a <fd_alloc+0x4d>
			*fd_store = fd;
  801533:	89 01                	mov    %eax,(%ecx)
			return 0;
  801535:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80153a:	5d                   	pop    %ebp
  80153b:	c3                   	ret    

0080153c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80153c:	55                   	push   %ebp
  80153d:	89 e5                	mov    %esp,%ebp
  80153f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801542:	83 f8 1f             	cmp    $0x1f,%eax
  801545:	77 36                	ja     80157d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801547:	c1 e0 0c             	shl    $0xc,%eax
  80154a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80154f:	89 c2                	mov    %eax,%edx
  801551:	c1 ea 16             	shr    $0x16,%edx
  801554:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80155b:	f6 c2 01             	test   $0x1,%dl
  80155e:	74 24                	je     801584 <fd_lookup+0x48>
  801560:	89 c2                	mov    %eax,%edx
  801562:	c1 ea 0c             	shr    $0xc,%edx
  801565:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80156c:	f6 c2 01             	test   $0x1,%dl
  80156f:	74 1a                	je     80158b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801571:	8b 55 0c             	mov    0xc(%ebp),%edx
  801574:	89 02                	mov    %eax,(%edx)
	return 0;
  801576:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80157b:	5d                   	pop    %ebp
  80157c:	c3                   	ret    
		return -E_INVAL;
  80157d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801582:	eb f7                	jmp    80157b <fd_lookup+0x3f>
		return -E_INVAL;
  801584:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801589:	eb f0                	jmp    80157b <fd_lookup+0x3f>
  80158b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801590:	eb e9                	jmp    80157b <fd_lookup+0x3f>

00801592 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801592:	55                   	push   %ebp
  801593:	89 e5                	mov    %esp,%ebp
  801595:	83 ec 08             	sub    $0x8,%esp
  801598:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80159b:	ba dc 2f 80 00       	mov    $0x802fdc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8015a0:	b8 20 40 80 00       	mov    $0x804020,%eax
		if (devtab[i]->dev_id == dev_id) {
  8015a5:	39 08                	cmp    %ecx,(%eax)
  8015a7:	74 33                	je     8015dc <dev_lookup+0x4a>
  8015a9:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  8015ac:	8b 02                	mov    (%edx),%eax
  8015ae:	85 c0                	test   %eax,%eax
  8015b0:	75 f3                	jne    8015a5 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8015b2:	a1 04 50 80 00       	mov    0x805004,%eax
  8015b7:	8b 40 48             	mov    0x48(%eax),%eax
  8015ba:	83 ec 04             	sub    $0x4,%esp
  8015bd:	51                   	push   %ecx
  8015be:	50                   	push   %eax
  8015bf:	68 60 2f 80 00       	push   $0x802f60
  8015c4:	e8 02 f0 ff ff       	call   8005cb <cprintf>
	*dev = 0;
  8015c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015cc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8015d2:	83 c4 10             	add    $0x10,%esp
  8015d5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8015da:	c9                   	leave  
  8015db:	c3                   	ret    
			*dev = devtab[i];
  8015dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015df:	89 01                	mov    %eax,(%ecx)
			return 0;
  8015e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8015e6:	eb f2                	jmp    8015da <dev_lookup+0x48>

008015e8 <fd_close>:
{
  8015e8:	55                   	push   %ebp
  8015e9:	89 e5                	mov    %esp,%ebp
  8015eb:	57                   	push   %edi
  8015ec:	56                   	push   %esi
  8015ed:	53                   	push   %ebx
  8015ee:	83 ec 1c             	sub    $0x1c,%esp
  8015f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8015f4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015f7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015fa:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8015fb:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801601:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801604:	50                   	push   %eax
  801605:	e8 32 ff ff ff       	call   80153c <fd_lookup>
  80160a:	89 c3                	mov    %eax,%ebx
  80160c:	83 c4 08             	add    $0x8,%esp
  80160f:	85 c0                	test   %eax,%eax
  801611:	78 05                	js     801618 <fd_close+0x30>
	    || fd != fd2)
  801613:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801616:	74 16                	je     80162e <fd_close+0x46>
		return (must_exist ? r : 0);
  801618:	89 f8                	mov    %edi,%eax
  80161a:	84 c0                	test   %al,%al
  80161c:	b8 00 00 00 00       	mov    $0x0,%eax
  801621:	0f 44 d8             	cmove  %eax,%ebx
}
  801624:	89 d8                	mov    %ebx,%eax
  801626:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801629:	5b                   	pop    %ebx
  80162a:	5e                   	pop    %esi
  80162b:	5f                   	pop    %edi
  80162c:	5d                   	pop    %ebp
  80162d:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80162e:	83 ec 08             	sub    $0x8,%esp
  801631:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801634:	50                   	push   %eax
  801635:	ff 36                	pushl  (%esi)
  801637:	e8 56 ff ff ff       	call   801592 <dev_lookup>
  80163c:	89 c3                	mov    %eax,%ebx
  80163e:	83 c4 10             	add    $0x10,%esp
  801641:	85 c0                	test   %eax,%eax
  801643:	78 15                	js     80165a <fd_close+0x72>
		if (dev->dev_close)
  801645:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801648:	8b 40 10             	mov    0x10(%eax),%eax
  80164b:	85 c0                	test   %eax,%eax
  80164d:	74 1b                	je     80166a <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  80164f:	83 ec 0c             	sub    $0xc,%esp
  801652:	56                   	push   %esi
  801653:	ff d0                	call   *%eax
  801655:	89 c3                	mov    %eax,%ebx
  801657:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80165a:	83 ec 08             	sub    $0x8,%esp
  80165d:	56                   	push   %esi
  80165e:	6a 00                	push   $0x0
  801660:	e8 03 fa ff ff       	call   801068 <sys_page_unmap>
	return r;
  801665:	83 c4 10             	add    $0x10,%esp
  801668:	eb ba                	jmp    801624 <fd_close+0x3c>
			r = 0;
  80166a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80166f:	eb e9                	jmp    80165a <fd_close+0x72>

00801671 <close>:

int
close(int fdnum)
{
  801671:	55                   	push   %ebp
  801672:	89 e5                	mov    %esp,%ebp
  801674:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801677:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80167a:	50                   	push   %eax
  80167b:	ff 75 08             	pushl  0x8(%ebp)
  80167e:	e8 b9 fe ff ff       	call   80153c <fd_lookup>
  801683:	83 c4 08             	add    $0x8,%esp
  801686:	85 c0                	test   %eax,%eax
  801688:	78 10                	js     80169a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80168a:	83 ec 08             	sub    $0x8,%esp
  80168d:	6a 01                	push   $0x1
  80168f:	ff 75 f4             	pushl  -0xc(%ebp)
  801692:	e8 51 ff ff ff       	call   8015e8 <fd_close>
  801697:	83 c4 10             	add    $0x10,%esp
}
  80169a:	c9                   	leave  
  80169b:	c3                   	ret    

0080169c <close_all>:

void
close_all(void)
{
  80169c:	55                   	push   %ebp
  80169d:	89 e5                	mov    %esp,%ebp
  80169f:	53                   	push   %ebx
  8016a0:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8016a3:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8016a8:	83 ec 0c             	sub    $0xc,%esp
  8016ab:	53                   	push   %ebx
  8016ac:	e8 c0 ff ff ff       	call   801671 <close>
	for (i = 0; i < MAXFD; i++)
  8016b1:	83 c3 01             	add    $0x1,%ebx
  8016b4:	83 c4 10             	add    $0x10,%esp
  8016b7:	83 fb 20             	cmp    $0x20,%ebx
  8016ba:	75 ec                	jne    8016a8 <close_all+0xc>
}
  8016bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016bf:	c9                   	leave  
  8016c0:	c3                   	ret    

008016c1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8016c1:	55                   	push   %ebp
  8016c2:	89 e5                	mov    %esp,%ebp
  8016c4:	57                   	push   %edi
  8016c5:	56                   	push   %esi
  8016c6:	53                   	push   %ebx
  8016c7:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8016ca:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016cd:	50                   	push   %eax
  8016ce:	ff 75 08             	pushl  0x8(%ebp)
  8016d1:	e8 66 fe ff ff       	call   80153c <fd_lookup>
  8016d6:	89 c3                	mov    %eax,%ebx
  8016d8:	83 c4 08             	add    $0x8,%esp
  8016db:	85 c0                	test   %eax,%eax
  8016dd:	0f 88 81 00 00 00    	js     801764 <dup+0xa3>
		return r;
	close(newfdnum);
  8016e3:	83 ec 0c             	sub    $0xc,%esp
  8016e6:	ff 75 0c             	pushl  0xc(%ebp)
  8016e9:	e8 83 ff ff ff       	call   801671 <close>

	newfd = INDEX2FD(newfdnum);
  8016ee:	8b 75 0c             	mov    0xc(%ebp),%esi
  8016f1:	c1 e6 0c             	shl    $0xc,%esi
  8016f4:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8016fa:	83 c4 04             	add    $0x4,%esp
  8016fd:	ff 75 e4             	pushl  -0x1c(%ebp)
  801700:	e8 d1 fd ff ff       	call   8014d6 <fd2data>
  801705:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801707:	89 34 24             	mov    %esi,(%esp)
  80170a:	e8 c7 fd ff ff       	call   8014d6 <fd2data>
  80170f:	83 c4 10             	add    $0x10,%esp
  801712:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801714:	89 d8                	mov    %ebx,%eax
  801716:	c1 e8 16             	shr    $0x16,%eax
  801719:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801720:	a8 01                	test   $0x1,%al
  801722:	74 11                	je     801735 <dup+0x74>
  801724:	89 d8                	mov    %ebx,%eax
  801726:	c1 e8 0c             	shr    $0xc,%eax
  801729:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801730:	f6 c2 01             	test   $0x1,%dl
  801733:	75 39                	jne    80176e <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801735:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801738:	89 d0                	mov    %edx,%eax
  80173a:	c1 e8 0c             	shr    $0xc,%eax
  80173d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801744:	83 ec 0c             	sub    $0xc,%esp
  801747:	25 07 0e 00 00       	and    $0xe07,%eax
  80174c:	50                   	push   %eax
  80174d:	56                   	push   %esi
  80174e:	6a 00                	push   $0x0
  801750:	52                   	push   %edx
  801751:	6a 00                	push   $0x0
  801753:	e8 ce f8 ff ff       	call   801026 <sys_page_map>
  801758:	89 c3                	mov    %eax,%ebx
  80175a:	83 c4 20             	add    $0x20,%esp
  80175d:	85 c0                	test   %eax,%eax
  80175f:	78 31                	js     801792 <dup+0xd1>
		goto err;

	return newfdnum;
  801761:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801764:	89 d8                	mov    %ebx,%eax
  801766:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801769:	5b                   	pop    %ebx
  80176a:	5e                   	pop    %esi
  80176b:	5f                   	pop    %edi
  80176c:	5d                   	pop    %ebp
  80176d:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80176e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801775:	83 ec 0c             	sub    $0xc,%esp
  801778:	25 07 0e 00 00       	and    $0xe07,%eax
  80177d:	50                   	push   %eax
  80177e:	57                   	push   %edi
  80177f:	6a 00                	push   $0x0
  801781:	53                   	push   %ebx
  801782:	6a 00                	push   $0x0
  801784:	e8 9d f8 ff ff       	call   801026 <sys_page_map>
  801789:	89 c3                	mov    %eax,%ebx
  80178b:	83 c4 20             	add    $0x20,%esp
  80178e:	85 c0                	test   %eax,%eax
  801790:	79 a3                	jns    801735 <dup+0x74>
	sys_page_unmap(0, newfd);
  801792:	83 ec 08             	sub    $0x8,%esp
  801795:	56                   	push   %esi
  801796:	6a 00                	push   $0x0
  801798:	e8 cb f8 ff ff       	call   801068 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80179d:	83 c4 08             	add    $0x8,%esp
  8017a0:	57                   	push   %edi
  8017a1:	6a 00                	push   $0x0
  8017a3:	e8 c0 f8 ff ff       	call   801068 <sys_page_unmap>
	return r;
  8017a8:	83 c4 10             	add    $0x10,%esp
  8017ab:	eb b7                	jmp    801764 <dup+0xa3>

008017ad <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8017ad:	55                   	push   %ebp
  8017ae:	89 e5                	mov    %esp,%ebp
  8017b0:	53                   	push   %ebx
  8017b1:	83 ec 14             	sub    $0x14,%esp
  8017b4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017b7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017ba:	50                   	push   %eax
  8017bb:	53                   	push   %ebx
  8017bc:	e8 7b fd ff ff       	call   80153c <fd_lookup>
  8017c1:	83 c4 08             	add    $0x8,%esp
  8017c4:	85 c0                	test   %eax,%eax
  8017c6:	78 3f                	js     801807 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017c8:	83 ec 08             	sub    $0x8,%esp
  8017cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017ce:	50                   	push   %eax
  8017cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017d2:	ff 30                	pushl  (%eax)
  8017d4:	e8 b9 fd ff ff       	call   801592 <dev_lookup>
  8017d9:	83 c4 10             	add    $0x10,%esp
  8017dc:	85 c0                	test   %eax,%eax
  8017de:	78 27                	js     801807 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8017e0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017e3:	8b 42 08             	mov    0x8(%edx),%eax
  8017e6:	83 e0 03             	and    $0x3,%eax
  8017e9:	83 f8 01             	cmp    $0x1,%eax
  8017ec:	74 1e                	je     80180c <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8017ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017f1:	8b 40 08             	mov    0x8(%eax),%eax
  8017f4:	85 c0                	test   %eax,%eax
  8017f6:	74 35                	je     80182d <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8017f8:	83 ec 04             	sub    $0x4,%esp
  8017fb:	ff 75 10             	pushl  0x10(%ebp)
  8017fe:	ff 75 0c             	pushl  0xc(%ebp)
  801801:	52                   	push   %edx
  801802:	ff d0                	call   *%eax
  801804:	83 c4 10             	add    $0x10,%esp
}
  801807:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80180a:	c9                   	leave  
  80180b:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80180c:	a1 04 50 80 00       	mov    0x805004,%eax
  801811:	8b 40 48             	mov    0x48(%eax),%eax
  801814:	83 ec 04             	sub    $0x4,%esp
  801817:	53                   	push   %ebx
  801818:	50                   	push   %eax
  801819:	68 a1 2f 80 00       	push   $0x802fa1
  80181e:	e8 a8 ed ff ff       	call   8005cb <cprintf>
		return -E_INVAL;
  801823:	83 c4 10             	add    $0x10,%esp
  801826:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80182b:	eb da                	jmp    801807 <read+0x5a>
		return -E_NOT_SUPP;
  80182d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801832:	eb d3                	jmp    801807 <read+0x5a>

00801834 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801834:	55                   	push   %ebp
  801835:	89 e5                	mov    %esp,%ebp
  801837:	57                   	push   %edi
  801838:	56                   	push   %esi
  801839:	53                   	push   %ebx
  80183a:	83 ec 0c             	sub    $0xc,%esp
  80183d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801840:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801843:	bb 00 00 00 00       	mov    $0x0,%ebx
  801848:	39 f3                	cmp    %esi,%ebx
  80184a:	73 25                	jae    801871 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80184c:	83 ec 04             	sub    $0x4,%esp
  80184f:	89 f0                	mov    %esi,%eax
  801851:	29 d8                	sub    %ebx,%eax
  801853:	50                   	push   %eax
  801854:	89 d8                	mov    %ebx,%eax
  801856:	03 45 0c             	add    0xc(%ebp),%eax
  801859:	50                   	push   %eax
  80185a:	57                   	push   %edi
  80185b:	e8 4d ff ff ff       	call   8017ad <read>
		if (m < 0)
  801860:	83 c4 10             	add    $0x10,%esp
  801863:	85 c0                	test   %eax,%eax
  801865:	78 08                	js     80186f <readn+0x3b>
			return m;
		if (m == 0)
  801867:	85 c0                	test   %eax,%eax
  801869:	74 06                	je     801871 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  80186b:	01 c3                	add    %eax,%ebx
  80186d:	eb d9                	jmp    801848 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80186f:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801871:	89 d8                	mov    %ebx,%eax
  801873:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801876:	5b                   	pop    %ebx
  801877:	5e                   	pop    %esi
  801878:	5f                   	pop    %edi
  801879:	5d                   	pop    %ebp
  80187a:	c3                   	ret    

0080187b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80187b:	55                   	push   %ebp
  80187c:	89 e5                	mov    %esp,%ebp
  80187e:	53                   	push   %ebx
  80187f:	83 ec 14             	sub    $0x14,%esp
  801882:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801885:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801888:	50                   	push   %eax
  801889:	53                   	push   %ebx
  80188a:	e8 ad fc ff ff       	call   80153c <fd_lookup>
  80188f:	83 c4 08             	add    $0x8,%esp
  801892:	85 c0                	test   %eax,%eax
  801894:	78 3a                	js     8018d0 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801896:	83 ec 08             	sub    $0x8,%esp
  801899:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80189c:	50                   	push   %eax
  80189d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018a0:	ff 30                	pushl  (%eax)
  8018a2:	e8 eb fc ff ff       	call   801592 <dev_lookup>
  8018a7:	83 c4 10             	add    $0x10,%esp
  8018aa:	85 c0                	test   %eax,%eax
  8018ac:	78 22                	js     8018d0 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018b1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018b5:	74 1e                	je     8018d5 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8018b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018ba:	8b 52 0c             	mov    0xc(%edx),%edx
  8018bd:	85 d2                	test   %edx,%edx
  8018bf:	74 35                	je     8018f6 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8018c1:	83 ec 04             	sub    $0x4,%esp
  8018c4:	ff 75 10             	pushl  0x10(%ebp)
  8018c7:	ff 75 0c             	pushl  0xc(%ebp)
  8018ca:	50                   	push   %eax
  8018cb:	ff d2                	call   *%edx
  8018cd:	83 c4 10             	add    $0x10,%esp
}
  8018d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d3:	c9                   	leave  
  8018d4:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8018d5:	a1 04 50 80 00       	mov    0x805004,%eax
  8018da:	8b 40 48             	mov    0x48(%eax),%eax
  8018dd:	83 ec 04             	sub    $0x4,%esp
  8018e0:	53                   	push   %ebx
  8018e1:	50                   	push   %eax
  8018e2:	68 bd 2f 80 00       	push   $0x802fbd
  8018e7:	e8 df ec ff ff       	call   8005cb <cprintf>
		return -E_INVAL;
  8018ec:	83 c4 10             	add    $0x10,%esp
  8018ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018f4:	eb da                	jmp    8018d0 <write+0x55>
		return -E_NOT_SUPP;
  8018f6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018fb:	eb d3                	jmp    8018d0 <write+0x55>

008018fd <seek>:

int
seek(int fdnum, off_t offset)
{
  8018fd:	55                   	push   %ebp
  8018fe:	89 e5                	mov    %esp,%ebp
  801900:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801903:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801906:	50                   	push   %eax
  801907:	ff 75 08             	pushl  0x8(%ebp)
  80190a:	e8 2d fc ff ff       	call   80153c <fd_lookup>
  80190f:	83 c4 08             	add    $0x8,%esp
  801912:	85 c0                	test   %eax,%eax
  801914:	78 0e                	js     801924 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801916:	8b 55 0c             	mov    0xc(%ebp),%edx
  801919:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80191c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80191f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801924:	c9                   	leave  
  801925:	c3                   	ret    

00801926 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801926:	55                   	push   %ebp
  801927:	89 e5                	mov    %esp,%ebp
  801929:	53                   	push   %ebx
  80192a:	83 ec 14             	sub    $0x14,%esp
  80192d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801930:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801933:	50                   	push   %eax
  801934:	53                   	push   %ebx
  801935:	e8 02 fc ff ff       	call   80153c <fd_lookup>
  80193a:	83 c4 08             	add    $0x8,%esp
  80193d:	85 c0                	test   %eax,%eax
  80193f:	78 37                	js     801978 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801941:	83 ec 08             	sub    $0x8,%esp
  801944:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801947:	50                   	push   %eax
  801948:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80194b:	ff 30                	pushl  (%eax)
  80194d:	e8 40 fc ff ff       	call   801592 <dev_lookup>
  801952:	83 c4 10             	add    $0x10,%esp
  801955:	85 c0                	test   %eax,%eax
  801957:	78 1f                	js     801978 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801959:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80195c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801960:	74 1b                	je     80197d <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801962:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801965:	8b 52 18             	mov    0x18(%edx),%edx
  801968:	85 d2                	test   %edx,%edx
  80196a:	74 32                	je     80199e <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80196c:	83 ec 08             	sub    $0x8,%esp
  80196f:	ff 75 0c             	pushl  0xc(%ebp)
  801972:	50                   	push   %eax
  801973:	ff d2                	call   *%edx
  801975:	83 c4 10             	add    $0x10,%esp
}
  801978:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80197b:	c9                   	leave  
  80197c:	c3                   	ret    
			thisenv->env_id, fdnum);
  80197d:	a1 04 50 80 00       	mov    0x805004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801982:	8b 40 48             	mov    0x48(%eax),%eax
  801985:	83 ec 04             	sub    $0x4,%esp
  801988:	53                   	push   %ebx
  801989:	50                   	push   %eax
  80198a:	68 80 2f 80 00       	push   $0x802f80
  80198f:	e8 37 ec ff ff       	call   8005cb <cprintf>
		return -E_INVAL;
  801994:	83 c4 10             	add    $0x10,%esp
  801997:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80199c:	eb da                	jmp    801978 <ftruncate+0x52>
		return -E_NOT_SUPP;
  80199e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8019a3:	eb d3                	jmp    801978 <ftruncate+0x52>

008019a5 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8019a5:	55                   	push   %ebp
  8019a6:	89 e5                	mov    %esp,%ebp
  8019a8:	53                   	push   %ebx
  8019a9:	83 ec 14             	sub    $0x14,%esp
  8019ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019b2:	50                   	push   %eax
  8019b3:	ff 75 08             	pushl  0x8(%ebp)
  8019b6:	e8 81 fb ff ff       	call   80153c <fd_lookup>
  8019bb:	83 c4 08             	add    $0x8,%esp
  8019be:	85 c0                	test   %eax,%eax
  8019c0:	78 4b                	js     801a0d <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019c2:	83 ec 08             	sub    $0x8,%esp
  8019c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019c8:	50                   	push   %eax
  8019c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019cc:	ff 30                	pushl  (%eax)
  8019ce:	e8 bf fb ff ff       	call   801592 <dev_lookup>
  8019d3:	83 c4 10             	add    $0x10,%esp
  8019d6:	85 c0                	test   %eax,%eax
  8019d8:	78 33                	js     801a0d <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  8019da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019dd:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8019e1:	74 2f                	je     801a12 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8019e3:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8019e6:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8019ed:	00 00 00 
	stat->st_isdir = 0;
  8019f0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019f7:	00 00 00 
	stat->st_dev = dev;
  8019fa:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a00:	83 ec 08             	sub    $0x8,%esp
  801a03:	53                   	push   %ebx
  801a04:	ff 75 f0             	pushl  -0x10(%ebp)
  801a07:	ff 50 14             	call   *0x14(%eax)
  801a0a:	83 c4 10             	add    $0x10,%esp
}
  801a0d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a10:	c9                   	leave  
  801a11:	c3                   	ret    
		return -E_NOT_SUPP;
  801a12:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a17:	eb f4                	jmp    801a0d <fstat+0x68>

00801a19 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a19:	55                   	push   %ebp
  801a1a:	89 e5                	mov    %esp,%ebp
  801a1c:	56                   	push   %esi
  801a1d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a1e:	83 ec 08             	sub    $0x8,%esp
  801a21:	6a 00                	push   $0x0
  801a23:	ff 75 08             	pushl  0x8(%ebp)
  801a26:	e8 da 01 00 00       	call   801c05 <open>
  801a2b:	89 c3                	mov    %eax,%ebx
  801a2d:	83 c4 10             	add    $0x10,%esp
  801a30:	85 c0                	test   %eax,%eax
  801a32:	78 1b                	js     801a4f <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801a34:	83 ec 08             	sub    $0x8,%esp
  801a37:	ff 75 0c             	pushl  0xc(%ebp)
  801a3a:	50                   	push   %eax
  801a3b:	e8 65 ff ff ff       	call   8019a5 <fstat>
  801a40:	89 c6                	mov    %eax,%esi
	close(fd);
  801a42:	89 1c 24             	mov    %ebx,(%esp)
  801a45:	e8 27 fc ff ff       	call   801671 <close>
	return r;
  801a4a:	83 c4 10             	add    $0x10,%esp
  801a4d:	89 f3                	mov    %esi,%ebx
}
  801a4f:	89 d8                	mov    %ebx,%eax
  801a51:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a54:	5b                   	pop    %ebx
  801a55:	5e                   	pop    %esi
  801a56:	5d                   	pop    %ebp
  801a57:	c3                   	ret    

00801a58 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a58:	55                   	push   %ebp
  801a59:	89 e5                	mov    %esp,%ebp
  801a5b:	56                   	push   %esi
  801a5c:	53                   	push   %ebx
  801a5d:	89 c6                	mov    %eax,%esi
  801a5f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801a61:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801a68:	74 27                	je     801a91 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a6a:	6a 07                	push   $0x7
  801a6c:	68 00 60 80 00       	push   $0x806000
  801a71:	56                   	push   %esi
  801a72:	ff 35 00 50 80 00    	pushl  0x805000
  801a78:	e8 a9 0c 00 00       	call   802726 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a7d:	83 c4 0c             	add    $0xc,%esp
  801a80:	6a 00                	push   $0x0
  801a82:	53                   	push   %ebx
  801a83:	6a 00                	push   $0x0
  801a85:	e8 35 0c 00 00       	call   8026bf <ipc_recv>
}
  801a8a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a8d:	5b                   	pop    %ebx
  801a8e:	5e                   	pop    %esi
  801a8f:	5d                   	pop    %ebp
  801a90:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a91:	83 ec 0c             	sub    $0xc,%esp
  801a94:	6a 01                	push   $0x1
  801a96:	e8 df 0c 00 00       	call   80277a <ipc_find_env>
  801a9b:	a3 00 50 80 00       	mov    %eax,0x805000
  801aa0:	83 c4 10             	add    $0x10,%esp
  801aa3:	eb c5                	jmp    801a6a <fsipc+0x12>

00801aa5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801aa5:	55                   	push   %ebp
  801aa6:	89 e5                	mov    %esp,%ebp
  801aa8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801aab:	8b 45 08             	mov    0x8(%ebp),%eax
  801aae:	8b 40 0c             	mov    0xc(%eax),%eax
  801ab1:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801ab6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ab9:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801abe:	ba 00 00 00 00       	mov    $0x0,%edx
  801ac3:	b8 02 00 00 00       	mov    $0x2,%eax
  801ac8:	e8 8b ff ff ff       	call   801a58 <fsipc>
}
  801acd:	c9                   	leave  
  801ace:	c3                   	ret    

00801acf <devfile_flush>:
{
  801acf:	55                   	push   %ebp
  801ad0:	89 e5                	mov    %esp,%ebp
  801ad2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801ad5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad8:	8b 40 0c             	mov    0xc(%eax),%eax
  801adb:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801ae0:	ba 00 00 00 00       	mov    $0x0,%edx
  801ae5:	b8 06 00 00 00       	mov    $0x6,%eax
  801aea:	e8 69 ff ff ff       	call   801a58 <fsipc>
}
  801aef:	c9                   	leave  
  801af0:	c3                   	ret    

00801af1 <devfile_stat>:
{
  801af1:	55                   	push   %ebp
  801af2:	89 e5                	mov    %esp,%ebp
  801af4:	53                   	push   %ebx
  801af5:	83 ec 04             	sub    $0x4,%esp
  801af8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801afb:	8b 45 08             	mov    0x8(%ebp),%eax
  801afe:	8b 40 0c             	mov    0xc(%eax),%eax
  801b01:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b06:	ba 00 00 00 00       	mov    $0x0,%edx
  801b0b:	b8 05 00 00 00       	mov    $0x5,%eax
  801b10:	e8 43 ff ff ff       	call   801a58 <fsipc>
  801b15:	85 c0                	test   %eax,%eax
  801b17:	78 2c                	js     801b45 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b19:	83 ec 08             	sub    $0x8,%esp
  801b1c:	68 00 60 80 00       	push   $0x806000
  801b21:	53                   	push   %ebx
  801b22:	e8 c3 f0 ff ff       	call   800bea <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b27:	a1 80 60 80 00       	mov    0x806080,%eax
  801b2c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b32:	a1 84 60 80 00       	mov    0x806084,%eax
  801b37:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b3d:	83 c4 10             	add    $0x10,%esp
  801b40:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b45:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b48:	c9                   	leave  
  801b49:	c3                   	ret    

00801b4a <devfile_write>:
{
  801b4a:	55                   	push   %ebp
  801b4b:	89 e5                	mov    %esp,%ebp
  801b4d:	83 ec 0c             	sub    $0xc,%esp
  801b50:	8b 45 10             	mov    0x10(%ebp),%eax
    	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801b53:	8b 55 08             	mov    0x8(%ebp),%edx
  801b56:	8b 52 0c             	mov    0xc(%edx),%edx
  801b59:	89 15 00 60 80 00    	mov    %edx,0x806000
    	fsipcbuf.write.req_n = n;
  801b5f:	a3 04 60 80 00       	mov    %eax,0x806004
    	memmove(fsipcbuf.write.req_buf, buf, n);
  801b64:	50                   	push   %eax
  801b65:	ff 75 0c             	pushl  0xc(%ebp)
  801b68:	68 08 60 80 00       	push   $0x806008
  801b6d:	e8 06 f2 ff ff       	call   800d78 <memmove>
    	return fsipc(FSREQ_WRITE, NULL);
  801b72:	ba 00 00 00 00       	mov    $0x0,%edx
  801b77:	b8 04 00 00 00       	mov    $0x4,%eax
  801b7c:	e8 d7 fe ff ff       	call   801a58 <fsipc>
}
  801b81:	c9                   	leave  
  801b82:	c3                   	ret    

00801b83 <devfile_read>:
{
  801b83:	55                   	push   %ebp
  801b84:	89 e5                	mov    %esp,%ebp
  801b86:	56                   	push   %esi
  801b87:	53                   	push   %ebx
  801b88:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8e:	8b 40 0c             	mov    0xc(%eax),%eax
  801b91:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801b96:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b9c:	ba 00 00 00 00       	mov    $0x0,%edx
  801ba1:	b8 03 00 00 00       	mov    $0x3,%eax
  801ba6:	e8 ad fe ff ff       	call   801a58 <fsipc>
  801bab:	89 c3                	mov    %eax,%ebx
  801bad:	85 c0                	test   %eax,%eax
  801baf:	78 1f                	js     801bd0 <devfile_read+0x4d>
	assert(r <= n);
  801bb1:	39 f0                	cmp    %esi,%eax
  801bb3:	77 24                	ja     801bd9 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801bb5:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801bba:	7f 33                	jg     801bef <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801bbc:	83 ec 04             	sub    $0x4,%esp
  801bbf:	50                   	push   %eax
  801bc0:	68 00 60 80 00       	push   $0x806000
  801bc5:	ff 75 0c             	pushl  0xc(%ebp)
  801bc8:	e8 ab f1 ff ff       	call   800d78 <memmove>
	return r;
  801bcd:	83 c4 10             	add    $0x10,%esp
}
  801bd0:	89 d8                	mov    %ebx,%eax
  801bd2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bd5:	5b                   	pop    %ebx
  801bd6:	5e                   	pop    %esi
  801bd7:	5d                   	pop    %ebp
  801bd8:	c3                   	ret    
	assert(r <= n);
  801bd9:	68 ec 2f 80 00       	push   $0x802fec
  801bde:	68 f3 2f 80 00       	push   $0x802ff3
  801be3:	6a 7c                	push   $0x7c
  801be5:	68 08 30 80 00       	push   $0x803008
  801bea:	e8 01 e9 ff ff       	call   8004f0 <_panic>
	assert(r <= PGSIZE);
  801bef:	68 13 30 80 00       	push   $0x803013
  801bf4:	68 f3 2f 80 00       	push   $0x802ff3
  801bf9:	6a 7d                	push   $0x7d
  801bfb:	68 08 30 80 00       	push   $0x803008
  801c00:	e8 eb e8 ff ff       	call   8004f0 <_panic>

00801c05 <open>:
{
  801c05:	55                   	push   %ebp
  801c06:	89 e5                	mov    %esp,%ebp
  801c08:	56                   	push   %esi
  801c09:	53                   	push   %ebx
  801c0a:	83 ec 1c             	sub    $0x1c,%esp
  801c0d:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801c10:	56                   	push   %esi
  801c11:	e8 9d ef ff ff       	call   800bb3 <strlen>
  801c16:	83 c4 10             	add    $0x10,%esp
  801c19:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c1e:	7f 6c                	jg     801c8c <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801c20:	83 ec 0c             	sub    $0xc,%esp
  801c23:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c26:	50                   	push   %eax
  801c27:	e8 c1 f8 ff ff       	call   8014ed <fd_alloc>
  801c2c:	89 c3                	mov    %eax,%ebx
  801c2e:	83 c4 10             	add    $0x10,%esp
  801c31:	85 c0                	test   %eax,%eax
  801c33:	78 3c                	js     801c71 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801c35:	83 ec 08             	sub    $0x8,%esp
  801c38:	56                   	push   %esi
  801c39:	68 00 60 80 00       	push   $0x806000
  801c3e:	e8 a7 ef ff ff       	call   800bea <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c43:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c46:	a3 00 64 80 00       	mov    %eax,0x806400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c4b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c4e:	b8 01 00 00 00       	mov    $0x1,%eax
  801c53:	e8 00 fe ff ff       	call   801a58 <fsipc>
  801c58:	89 c3                	mov    %eax,%ebx
  801c5a:	83 c4 10             	add    $0x10,%esp
  801c5d:	85 c0                	test   %eax,%eax
  801c5f:	78 19                	js     801c7a <open+0x75>
	return fd2num(fd);
  801c61:	83 ec 0c             	sub    $0xc,%esp
  801c64:	ff 75 f4             	pushl  -0xc(%ebp)
  801c67:	e8 5a f8 ff ff       	call   8014c6 <fd2num>
  801c6c:	89 c3                	mov    %eax,%ebx
  801c6e:	83 c4 10             	add    $0x10,%esp
}
  801c71:	89 d8                	mov    %ebx,%eax
  801c73:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c76:	5b                   	pop    %ebx
  801c77:	5e                   	pop    %esi
  801c78:	5d                   	pop    %ebp
  801c79:	c3                   	ret    
		fd_close(fd, 0);
  801c7a:	83 ec 08             	sub    $0x8,%esp
  801c7d:	6a 00                	push   $0x0
  801c7f:	ff 75 f4             	pushl  -0xc(%ebp)
  801c82:	e8 61 f9 ff ff       	call   8015e8 <fd_close>
		return r;
  801c87:	83 c4 10             	add    $0x10,%esp
  801c8a:	eb e5                	jmp    801c71 <open+0x6c>
		return -E_BAD_PATH;
  801c8c:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801c91:	eb de                	jmp    801c71 <open+0x6c>

00801c93 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c93:	55                   	push   %ebp
  801c94:	89 e5                	mov    %esp,%ebp
  801c96:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c99:	ba 00 00 00 00       	mov    $0x0,%edx
  801c9e:	b8 08 00 00 00       	mov    $0x8,%eax
  801ca3:	e8 b0 fd ff ff       	call   801a58 <fsipc>
}
  801ca8:	c9                   	leave  
  801ca9:	c3                   	ret    

00801caa <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801caa:	55                   	push   %ebp
  801cab:	89 e5                	mov    %esp,%ebp
  801cad:	57                   	push   %edi
  801cae:	56                   	push   %esi
  801caf:	53                   	push   %ebx
  801cb0:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801cb6:	6a 00                	push   $0x0
  801cb8:	ff 75 08             	pushl  0x8(%ebp)
  801cbb:	e8 45 ff ff ff       	call   801c05 <open>
  801cc0:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  801cc6:	83 c4 10             	add    $0x10,%esp
  801cc9:	85 c0                	test   %eax,%eax
  801ccb:	0f 88 40 03 00 00    	js     802011 <spawn+0x367>
  801cd1:	89 c7                	mov    %eax,%edi
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801cd3:	83 ec 04             	sub    $0x4,%esp
  801cd6:	68 00 02 00 00       	push   $0x200
  801cdb:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801ce1:	50                   	push   %eax
  801ce2:	57                   	push   %edi
  801ce3:	e8 4c fb ff ff       	call   801834 <readn>
  801ce8:	83 c4 10             	add    $0x10,%esp
  801ceb:	3d 00 02 00 00       	cmp    $0x200,%eax
  801cf0:	75 5d                	jne    801d4f <spawn+0xa5>
	    || elf->e_magic != ELF_MAGIC) {
  801cf2:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801cf9:	45 4c 46 
  801cfc:	75 51                	jne    801d4f <spawn+0xa5>
  801cfe:	b8 07 00 00 00       	mov    $0x7,%eax
  801d03:	cd 30                	int    $0x30
  801d05:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801d0b:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801d11:	85 c0                	test   %eax,%eax
  801d13:	0f 88 a5 04 00 00    	js     8021be <spawn+0x514>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801d19:	25 ff 03 00 00       	and    $0x3ff,%eax
  801d1e:	6b f0 7c             	imul   $0x7c,%eax,%esi
  801d21:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801d27:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801d2d:	b9 11 00 00 00       	mov    $0x11,%ecx
  801d32:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801d34:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801d3a:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801d40:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  801d45:	be 00 00 00 00       	mov    $0x0,%esi
  801d4a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801d4d:	eb 4b                	jmp    801d9a <spawn+0xf0>
		close(fd);
  801d4f:	83 ec 0c             	sub    $0xc,%esp
  801d52:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801d58:	e8 14 f9 ff ff       	call   801671 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801d5d:	83 c4 0c             	add    $0xc,%esp
  801d60:	68 7f 45 4c 46       	push   $0x464c457f
  801d65:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801d6b:	68 1f 30 80 00       	push   $0x80301f
  801d70:	e8 56 e8 ff ff       	call   8005cb <cprintf>
		return -E_NOT_EXEC;
  801d75:	83 c4 10             	add    $0x10,%esp
  801d78:	c7 85 90 fd ff ff f2 	movl   $0xfffffff2,-0x270(%ebp)
  801d7f:	ff ff ff 
  801d82:	e9 8a 02 00 00       	jmp    802011 <spawn+0x367>
		string_size += strlen(argv[argc]) + 1;
  801d87:	83 ec 0c             	sub    $0xc,%esp
  801d8a:	50                   	push   %eax
  801d8b:	e8 23 ee ff ff       	call   800bb3 <strlen>
  801d90:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  801d94:	83 c3 01             	add    $0x1,%ebx
  801d97:	83 c4 10             	add    $0x10,%esp
  801d9a:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801da1:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801da4:	85 c0                	test   %eax,%eax
  801da6:	75 df                	jne    801d87 <spawn+0xdd>
  801da8:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801dae:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801db4:	bf 00 10 40 00       	mov    $0x401000,%edi
  801db9:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801dbb:	89 fa                	mov    %edi,%edx
  801dbd:	83 e2 fc             	and    $0xfffffffc,%edx
  801dc0:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801dc7:	29 c2                	sub    %eax,%edx
  801dc9:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801dcf:	8d 42 f8             	lea    -0x8(%edx),%eax
  801dd2:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801dd7:	0f 86 f2 03 00 00    	jbe    8021cf <spawn+0x525>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801ddd:	83 ec 04             	sub    $0x4,%esp
  801de0:	6a 07                	push   $0x7
  801de2:	68 00 00 40 00       	push   $0x400000
  801de7:	6a 00                	push   $0x0
  801de9:	e8 f5 f1 ff ff       	call   800fe3 <sys_page_alloc>
  801dee:	83 c4 10             	add    $0x10,%esp
  801df1:	85 c0                	test   %eax,%eax
  801df3:	0f 88 db 03 00 00    	js     8021d4 <spawn+0x52a>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801df9:	be 00 00 00 00       	mov    $0x0,%esi
  801dfe:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  801e04:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801e07:	eb 30                	jmp    801e39 <spawn+0x18f>
		argv_store[i] = UTEMP2USTACK(string_store);
  801e09:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801e0f:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801e15:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  801e18:	83 ec 08             	sub    $0x8,%esp
  801e1b:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801e1e:	57                   	push   %edi
  801e1f:	e8 c6 ed ff ff       	call   800bea <strcpy>
		string_store += strlen(argv[i]) + 1;
  801e24:	83 c4 04             	add    $0x4,%esp
  801e27:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801e2a:	e8 84 ed ff ff       	call   800bb3 <strlen>
  801e2f:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  801e33:	83 c6 01             	add    $0x1,%esi
  801e36:	83 c4 10             	add    $0x10,%esp
  801e39:	39 b5 8c fd ff ff    	cmp    %esi,-0x274(%ebp)
  801e3f:	7f c8                	jg     801e09 <spawn+0x15f>
	}
	argv_store[argc] = 0;
  801e41:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801e47:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801e4d:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801e54:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801e5a:	0f 85 8c 00 00 00    	jne    801eec <spawn+0x242>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801e60:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801e66:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801e6c:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801e6f:	89 f8                	mov    %edi,%eax
  801e71:	8b bd 88 fd ff ff    	mov    -0x278(%ebp),%edi
  801e77:	89 78 f8             	mov    %edi,-0x8(%eax)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801e7a:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801e7f:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801e85:	83 ec 0c             	sub    $0xc,%esp
  801e88:	6a 07                	push   $0x7
  801e8a:	68 00 d0 bf ee       	push   $0xeebfd000
  801e8f:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e95:	68 00 00 40 00       	push   $0x400000
  801e9a:	6a 00                	push   $0x0
  801e9c:	e8 85 f1 ff ff       	call   801026 <sys_page_map>
  801ea1:	89 c3                	mov    %eax,%ebx
  801ea3:	83 c4 20             	add    $0x20,%esp
  801ea6:	85 c0                	test   %eax,%eax
  801ea8:	0f 88 46 03 00 00    	js     8021f4 <spawn+0x54a>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801eae:	83 ec 08             	sub    $0x8,%esp
  801eb1:	68 00 00 40 00       	push   $0x400000
  801eb6:	6a 00                	push   $0x0
  801eb8:	e8 ab f1 ff ff       	call   801068 <sys_page_unmap>
  801ebd:	89 c3                	mov    %eax,%ebx
  801ebf:	83 c4 10             	add    $0x10,%esp
  801ec2:	85 c0                	test   %eax,%eax
  801ec4:	0f 88 2a 03 00 00    	js     8021f4 <spawn+0x54a>
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801eca:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801ed0:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801ed7:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801edd:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801ee4:	00 00 00 
  801ee7:	e9 56 01 00 00       	jmp    802042 <spawn+0x398>
	assert(string_store == (char*)UTEMP + PGSIZE);
  801eec:	68 94 30 80 00       	push   $0x803094
  801ef1:	68 f3 2f 80 00       	push   $0x802ff3
  801ef6:	68 f2 00 00 00       	push   $0xf2
  801efb:	68 39 30 80 00       	push   $0x803039
  801f00:	e8 eb e5 ff ff       	call   8004f0 <_panic>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801f05:	83 ec 04             	sub    $0x4,%esp
  801f08:	6a 07                	push   $0x7
  801f0a:	68 00 00 40 00       	push   $0x400000
  801f0f:	6a 00                	push   $0x0
  801f11:	e8 cd f0 ff ff       	call   800fe3 <sys_page_alloc>
  801f16:	83 c4 10             	add    $0x10,%esp
  801f19:	85 c0                	test   %eax,%eax
  801f1b:	0f 88 be 02 00 00    	js     8021df <spawn+0x535>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801f21:	83 ec 08             	sub    $0x8,%esp
  801f24:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801f2a:	01 f0                	add    %esi,%eax
  801f2c:	50                   	push   %eax
  801f2d:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801f33:	e8 c5 f9 ff ff       	call   8018fd <seek>
  801f38:	83 c4 10             	add    $0x10,%esp
  801f3b:	85 c0                	test   %eax,%eax
  801f3d:	0f 88 a3 02 00 00    	js     8021e6 <spawn+0x53c>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801f43:	83 ec 04             	sub    $0x4,%esp
  801f46:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801f4c:	29 f0                	sub    %esi,%eax
  801f4e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801f53:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801f58:	0f 47 c1             	cmova  %ecx,%eax
  801f5b:	50                   	push   %eax
  801f5c:	68 00 00 40 00       	push   $0x400000
  801f61:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  801f67:	e8 c8 f8 ff ff       	call   801834 <readn>
  801f6c:	83 c4 10             	add    $0x10,%esp
  801f6f:	85 c0                	test   %eax,%eax
  801f71:	0f 88 76 02 00 00    	js     8021ed <spawn+0x543>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801f77:	83 ec 0c             	sub    $0xc,%esp
  801f7a:	57                   	push   %edi
  801f7b:	03 b5 88 fd ff ff    	add    -0x278(%ebp),%esi
  801f81:	56                   	push   %esi
  801f82:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801f88:	68 00 00 40 00       	push   $0x400000
  801f8d:	6a 00                	push   $0x0
  801f8f:	e8 92 f0 ff ff       	call   801026 <sys_page_map>
  801f94:	83 c4 20             	add    $0x20,%esp
  801f97:	85 c0                	test   %eax,%eax
  801f99:	0f 88 80 00 00 00    	js     80201f <spawn+0x375>
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
  801f9f:	83 ec 08             	sub    $0x8,%esp
  801fa2:	68 00 00 40 00       	push   $0x400000
  801fa7:	6a 00                	push   $0x0
  801fa9:	e8 ba f0 ff ff       	call   801068 <sys_page_unmap>
  801fae:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < memsz; i += PGSIZE) {
  801fb1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801fb7:	89 de                	mov    %ebx,%esi
  801fb9:	39 9d 8c fd ff ff    	cmp    %ebx,-0x274(%ebp)
  801fbf:	76 73                	jbe    802034 <spawn+0x38a>
		if (i >= filesz) {
  801fc1:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  801fc7:	0f 87 38 ff ff ff    	ja     801f05 <spawn+0x25b>
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801fcd:	83 ec 04             	sub    $0x4,%esp
  801fd0:	57                   	push   %edi
  801fd1:	03 b5 88 fd ff ff    	add    -0x278(%ebp),%esi
  801fd7:	56                   	push   %esi
  801fd8:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801fde:	e8 00 f0 ff ff       	call   800fe3 <sys_page_alloc>
  801fe3:	83 c4 10             	add    $0x10,%esp
  801fe6:	85 c0                	test   %eax,%eax
  801fe8:	79 c7                	jns    801fb1 <spawn+0x307>
  801fea:	89 c7                	mov    %eax,%edi
	sys_env_destroy(child);
  801fec:	83 ec 0c             	sub    $0xc,%esp
  801fef:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801ff5:	e8 6a ef ff ff       	call   800f64 <sys_env_destroy>
	close(fd);
  801ffa:	83 c4 04             	add    $0x4,%esp
  801ffd:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  802003:	e8 69 f6 ff ff       	call   801671 <close>
	return r;
  802008:	83 c4 10             	add    $0x10,%esp
  80200b:	89 bd 90 fd ff ff    	mov    %edi,-0x270(%ebp)
}
  802011:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  802017:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80201a:	5b                   	pop    %ebx
  80201b:	5e                   	pop    %esi
  80201c:	5f                   	pop    %edi
  80201d:	5d                   	pop    %ebp
  80201e:	c3                   	ret    
				panic("spawn: sys_page_map data: %e", r);
  80201f:	50                   	push   %eax
  802020:	68 45 30 80 00       	push   $0x803045
  802025:	68 25 01 00 00       	push   $0x125
  80202a:	68 39 30 80 00       	push   $0x803039
  80202f:	e8 bc e4 ff ff       	call   8004f0 <_panic>
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802034:	83 85 7c fd ff ff 01 	addl   $0x1,-0x284(%ebp)
  80203b:	83 85 78 fd ff ff 20 	addl   $0x20,-0x288(%ebp)
  802042:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802049:	3b 85 7c fd ff ff    	cmp    -0x284(%ebp),%eax
  80204f:	7e 71                	jle    8020c2 <spawn+0x418>
		if (ph->p_type != ELF_PROG_LOAD)
  802051:	8b 8d 78 fd ff ff    	mov    -0x288(%ebp),%ecx
  802057:	83 39 01             	cmpl   $0x1,(%ecx)
  80205a:	75 d8                	jne    802034 <spawn+0x38a>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  80205c:	8b 41 18             	mov    0x18(%ecx),%eax
  80205f:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  802062:	83 f8 01             	cmp    $0x1,%eax
  802065:	19 ff                	sbb    %edi,%edi
  802067:	83 e7 fe             	and    $0xfffffffe,%edi
  80206a:	83 c7 07             	add    $0x7,%edi
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  80206d:	8b 71 04             	mov    0x4(%ecx),%esi
  802070:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  802076:	8b 59 10             	mov    0x10(%ecx),%ebx
  802079:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  80207f:	8b 41 14             	mov    0x14(%ecx),%eax
  802082:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  802088:	8b 51 08             	mov    0x8(%ecx),%edx
  80208b:	89 95 88 fd ff ff    	mov    %edx,-0x278(%ebp)
	if ((i = PGOFF(va))) {
  802091:	89 d0                	mov    %edx,%eax
  802093:	25 ff 0f 00 00       	and    $0xfff,%eax
  802098:	74 1e                	je     8020b8 <spawn+0x40e>
		va -= i;
  80209a:	29 c2                	sub    %eax,%edx
  80209c:	89 95 88 fd ff ff    	mov    %edx,-0x278(%ebp)
		memsz += i;
  8020a2:	01 85 8c fd ff ff    	add    %eax,-0x274(%ebp)
		filesz += i;
  8020a8:	01 c3                	add    %eax,%ebx
  8020aa:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
		fileoffset -= i;
  8020b0:	29 c6                	sub    %eax,%esi
  8020b2:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
	for (i = 0; i < memsz; i += PGSIZE) {
  8020b8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020bd:	e9 f5 fe ff ff       	jmp    801fb7 <spawn+0x30d>
	close(fd);
  8020c2:	83 ec 0c             	sub    $0xc,%esp
  8020c5:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  8020cb:	e8 a1 f5 ff ff       	call   801671 <close>
  8020d0:	83 c4 10             	add    $0x10,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
    	uintptr_t addr;
    	for (addr = 0; addr < UTOP; addr += PGSIZE) {
  8020d3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020d8:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
  8020de:	eb 0e                	jmp    8020ee <spawn+0x444>
  8020e0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8020e6:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  8020ec:	74 58                	je     802146 <spawn+0x49c>
        	if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U) && (uvpt[PGNUM(addr)] & PTE_SHARE)) {
  8020ee:	89 d8                	mov    %ebx,%eax
  8020f0:	c1 e8 16             	shr    $0x16,%eax
  8020f3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8020fa:	a8 01                	test   $0x1,%al
  8020fc:	74 e2                	je     8020e0 <spawn+0x436>
  8020fe:	89 d8                	mov    %ebx,%eax
  802100:	c1 e8 0c             	shr    $0xc,%eax
  802103:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80210a:	f6 c2 01             	test   $0x1,%dl
  80210d:	74 d1                	je     8020e0 <spawn+0x436>
  80210f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802116:	f6 c2 04             	test   $0x4,%dl
  802119:	74 c5                	je     8020e0 <spawn+0x436>
  80211b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802122:	f6 c6 04             	test   $0x4,%dh
  802125:	74 b9                	je     8020e0 <spawn+0x436>
            		sys_page_map(0, (void*)addr, child, (void*)addr, (uvpt[PGNUM(addr)] & PTE_SYSCALL));
  802127:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80212e:	83 ec 0c             	sub    $0xc,%esp
  802131:	25 07 0e 00 00       	and    $0xe07,%eax
  802136:	50                   	push   %eax
  802137:	53                   	push   %ebx
  802138:	56                   	push   %esi
  802139:	53                   	push   %ebx
  80213a:	6a 00                	push   $0x0
  80213c:	e8 e5 ee ff ff       	call   801026 <sys_page_map>
  802141:	83 c4 20             	add    $0x20,%esp
  802144:	eb 9a                	jmp    8020e0 <spawn+0x436>
	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  802146:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  80214d:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802150:	83 ec 08             	sub    $0x8,%esp
  802153:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802159:	50                   	push   %eax
  80215a:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802160:	e8 87 ef ff ff       	call   8010ec <sys_env_set_trapframe>
  802165:	83 c4 10             	add    $0x10,%esp
  802168:	85 c0                	test   %eax,%eax
  80216a:	78 28                	js     802194 <spawn+0x4ea>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  80216c:	83 ec 08             	sub    $0x8,%esp
  80216f:	6a 02                	push   $0x2
  802171:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802177:	e8 2e ef ff ff       	call   8010aa <sys_env_set_status>
  80217c:	83 c4 10             	add    $0x10,%esp
  80217f:	85 c0                	test   %eax,%eax
  802181:	78 26                	js     8021a9 <spawn+0x4ff>
	return child;
  802183:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802189:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  80218f:	e9 7d fe ff ff       	jmp    802011 <spawn+0x367>
		panic("sys_env_set_trapframe: %e", r);
  802194:	50                   	push   %eax
  802195:	68 62 30 80 00       	push   $0x803062
  80219a:	68 86 00 00 00       	push   $0x86
  80219f:	68 39 30 80 00       	push   $0x803039
  8021a4:	e8 47 e3 ff ff       	call   8004f0 <_panic>
		panic("sys_env_set_status: %e", r);
  8021a9:	50                   	push   %eax
  8021aa:	68 7c 30 80 00       	push   $0x80307c
  8021af:	68 89 00 00 00       	push   $0x89
  8021b4:	68 39 30 80 00       	push   $0x803039
  8021b9:	e8 32 e3 ff ff       	call   8004f0 <_panic>
		return r;
  8021be:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8021c4:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  8021ca:	e9 42 fe ff ff       	jmp    802011 <spawn+0x367>
		return -E_NO_MEM;
  8021cf:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return r;
  8021d4:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  8021da:	e9 32 fe ff ff       	jmp    802011 <spawn+0x367>
  8021df:	89 c7                	mov    %eax,%edi
  8021e1:	e9 06 fe ff ff       	jmp    801fec <spawn+0x342>
  8021e6:	89 c7                	mov    %eax,%edi
  8021e8:	e9 ff fd ff ff       	jmp    801fec <spawn+0x342>
  8021ed:	89 c7                	mov    %eax,%edi
  8021ef:	e9 f8 fd ff ff       	jmp    801fec <spawn+0x342>
	sys_page_unmap(0, UTEMP);
  8021f4:	83 ec 08             	sub    $0x8,%esp
  8021f7:	68 00 00 40 00       	push   $0x400000
  8021fc:	6a 00                	push   $0x0
  8021fe:	e8 65 ee ff ff       	call   801068 <sys_page_unmap>
  802203:	83 c4 10             	add    $0x10,%esp
  802206:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  80220c:	e9 00 fe ff ff       	jmp    802011 <spawn+0x367>

00802211 <spawnl>:
{
  802211:	55                   	push   %ebp
  802212:	89 e5                	mov    %esp,%ebp
  802214:	57                   	push   %edi
  802215:	56                   	push   %esi
  802216:	53                   	push   %ebx
  802217:	83 ec 0c             	sub    $0xc,%esp
	va_start(vl, arg0);
  80221a:	8d 55 10             	lea    0x10(%ebp),%edx
	int argc=0;
  80221d:	b8 00 00 00 00       	mov    $0x0,%eax
	while(va_arg(vl, void *) != NULL)
  802222:	eb 05                	jmp    802229 <spawnl+0x18>
		argc++;
  802224:	83 c0 01             	add    $0x1,%eax
	while(va_arg(vl, void *) != NULL)
  802227:	89 ca                	mov    %ecx,%edx
  802229:	8d 4a 04             	lea    0x4(%edx),%ecx
  80222c:	83 3a 00             	cmpl   $0x0,(%edx)
  80222f:	75 f3                	jne    802224 <spawnl+0x13>
	const char *argv[argc+2];
  802231:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  802238:	83 e2 f0             	and    $0xfffffff0,%edx
  80223b:	29 d4                	sub    %edx,%esp
  80223d:	8d 54 24 03          	lea    0x3(%esp),%edx
  802241:	c1 ea 02             	shr    $0x2,%edx
  802244:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  80224b:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  80224d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802250:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  802257:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  80225e:	00 
	va_start(vl, arg0);
  80225f:	8d 4d 10             	lea    0x10(%ebp),%ecx
  802262:	89 c2                	mov    %eax,%edx
	for(i=0;i<argc;i++)
  802264:	b8 00 00 00 00       	mov    $0x0,%eax
  802269:	eb 0b                	jmp    802276 <spawnl+0x65>
		argv[i+1] = va_arg(vl, const char *);
  80226b:	83 c0 01             	add    $0x1,%eax
  80226e:	8b 39                	mov    (%ecx),%edi
  802270:	89 3c 83             	mov    %edi,(%ebx,%eax,4)
  802273:	8d 49 04             	lea    0x4(%ecx),%ecx
	for(i=0;i<argc;i++)
  802276:	39 d0                	cmp    %edx,%eax
  802278:	75 f1                	jne    80226b <spawnl+0x5a>
	return spawn(prog, argv);
  80227a:	83 ec 08             	sub    $0x8,%esp
  80227d:	56                   	push   %esi
  80227e:	ff 75 08             	pushl  0x8(%ebp)
  802281:	e8 24 fa ff ff       	call   801caa <spawn>
}
  802286:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802289:	5b                   	pop    %ebx
  80228a:	5e                   	pop    %esi
  80228b:	5f                   	pop    %edi
  80228c:	5d                   	pop    %ebp
  80228d:	c3                   	ret    

0080228e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80228e:	55                   	push   %ebp
  80228f:	89 e5                	mov    %esp,%ebp
  802291:	56                   	push   %esi
  802292:	53                   	push   %ebx
  802293:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802296:	83 ec 0c             	sub    $0xc,%esp
  802299:	ff 75 08             	pushl  0x8(%ebp)
  80229c:	e8 35 f2 ff ff       	call   8014d6 <fd2data>
  8022a1:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8022a3:	83 c4 08             	add    $0x8,%esp
  8022a6:	68 ba 30 80 00       	push   $0x8030ba
  8022ab:	53                   	push   %ebx
  8022ac:	e8 39 e9 ff ff       	call   800bea <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8022b1:	8b 46 04             	mov    0x4(%esi),%eax
  8022b4:	2b 06                	sub    (%esi),%eax
  8022b6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8022bc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8022c3:	00 00 00 
	stat->st_dev = &devpipe;
  8022c6:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  8022cd:	40 80 00 
	return 0;
}
  8022d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8022d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022d8:	5b                   	pop    %ebx
  8022d9:	5e                   	pop    %esi
  8022da:	5d                   	pop    %ebp
  8022db:	c3                   	ret    

008022dc <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8022dc:	55                   	push   %ebp
  8022dd:	89 e5                	mov    %esp,%ebp
  8022df:	53                   	push   %ebx
  8022e0:	83 ec 0c             	sub    $0xc,%esp
  8022e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8022e6:	53                   	push   %ebx
  8022e7:	6a 00                	push   $0x0
  8022e9:	e8 7a ed ff ff       	call   801068 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8022ee:	89 1c 24             	mov    %ebx,(%esp)
  8022f1:	e8 e0 f1 ff ff       	call   8014d6 <fd2data>
  8022f6:	83 c4 08             	add    $0x8,%esp
  8022f9:	50                   	push   %eax
  8022fa:	6a 00                	push   $0x0
  8022fc:	e8 67 ed ff ff       	call   801068 <sys_page_unmap>
}
  802301:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802304:	c9                   	leave  
  802305:	c3                   	ret    

00802306 <_pipeisclosed>:
{
  802306:	55                   	push   %ebp
  802307:	89 e5                	mov    %esp,%ebp
  802309:	57                   	push   %edi
  80230a:	56                   	push   %esi
  80230b:	53                   	push   %ebx
  80230c:	83 ec 1c             	sub    $0x1c,%esp
  80230f:	89 c7                	mov    %eax,%edi
  802311:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  802313:	a1 04 50 80 00       	mov    0x805004,%eax
  802318:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80231b:	83 ec 0c             	sub    $0xc,%esp
  80231e:	57                   	push   %edi
  80231f:	e8 8f 04 00 00       	call   8027b3 <pageref>
  802324:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  802327:	89 34 24             	mov    %esi,(%esp)
  80232a:	e8 84 04 00 00       	call   8027b3 <pageref>
		nn = thisenv->env_runs;
  80232f:	8b 15 04 50 80 00    	mov    0x805004,%edx
  802335:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802338:	83 c4 10             	add    $0x10,%esp
  80233b:	39 cb                	cmp    %ecx,%ebx
  80233d:	74 1b                	je     80235a <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  80233f:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802342:	75 cf                	jne    802313 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802344:	8b 42 58             	mov    0x58(%edx),%eax
  802347:	6a 01                	push   $0x1
  802349:	50                   	push   %eax
  80234a:	53                   	push   %ebx
  80234b:	68 c1 30 80 00       	push   $0x8030c1
  802350:	e8 76 e2 ff ff       	call   8005cb <cprintf>
  802355:	83 c4 10             	add    $0x10,%esp
  802358:	eb b9                	jmp    802313 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  80235a:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80235d:	0f 94 c0             	sete   %al
  802360:	0f b6 c0             	movzbl %al,%eax
}
  802363:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802366:	5b                   	pop    %ebx
  802367:	5e                   	pop    %esi
  802368:	5f                   	pop    %edi
  802369:	5d                   	pop    %ebp
  80236a:	c3                   	ret    

0080236b <devpipe_write>:
{
  80236b:	55                   	push   %ebp
  80236c:	89 e5                	mov    %esp,%ebp
  80236e:	57                   	push   %edi
  80236f:	56                   	push   %esi
  802370:	53                   	push   %ebx
  802371:	83 ec 28             	sub    $0x28,%esp
  802374:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  802377:	56                   	push   %esi
  802378:	e8 59 f1 ff ff       	call   8014d6 <fd2data>
  80237d:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80237f:	83 c4 10             	add    $0x10,%esp
  802382:	bf 00 00 00 00       	mov    $0x0,%edi
  802387:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80238a:	74 4f                	je     8023db <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80238c:	8b 43 04             	mov    0x4(%ebx),%eax
  80238f:	8b 0b                	mov    (%ebx),%ecx
  802391:	8d 51 20             	lea    0x20(%ecx),%edx
  802394:	39 d0                	cmp    %edx,%eax
  802396:	72 14                	jb     8023ac <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  802398:	89 da                	mov    %ebx,%edx
  80239a:	89 f0                	mov    %esi,%eax
  80239c:	e8 65 ff ff ff       	call   802306 <_pipeisclosed>
  8023a1:	85 c0                	test   %eax,%eax
  8023a3:	75 3a                	jne    8023df <devpipe_write+0x74>
			sys_yield();
  8023a5:	e8 1a ec ff ff       	call   800fc4 <sys_yield>
  8023aa:	eb e0                	jmp    80238c <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8023ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8023af:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8023b3:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8023b6:	89 c2                	mov    %eax,%edx
  8023b8:	c1 fa 1f             	sar    $0x1f,%edx
  8023bb:	89 d1                	mov    %edx,%ecx
  8023bd:	c1 e9 1b             	shr    $0x1b,%ecx
  8023c0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8023c3:	83 e2 1f             	and    $0x1f,%edx
  8023c6:	29 ca                	sub    %ecx,%edx
  8023c8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8023cc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8023d0:	83 c0 01             	add    $0x1,%eax
  8023d3:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8023d6:	83 c7 01             	add    $0x1,%edi
  8023d9:	eb ac                	jmp    802387 <devpipe_write+0x1c>
	return i;
  8023db:	89 f8                	mov    %edi,%eax
  8023dd:	eb 05                	jmp    8023e4 <devpipe_write+0x79>
				return 0;
  8023df:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8023e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023e7:	5b                   	pop    %ebx
  8023e8:	5e                   	pop    %esi
  8023e9:	5f                   	pop    %edi
  8023ea:	5d                   	pop    %ebp
  8023eb:	c3                   	ret    

008023ec <devpipe_read>:
{
  8023ec:	55                   	push   %ebp
  8023ed:	89 e5                	mov    %esp,%ebp
  8023ef:	57                   	push   %edi
  8023f0:	56                   	push   %esi
  8023f1:	53                   	push   %ebx
  8023f2:	83 ec 18             	sub    $0x18,%esp
  8023f5:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8023f8:	57                   	push   %edi
  8023f9:	e8 d8 f0 ff ff       	call   8014d6 <fd2data>
  8023fe:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802400:	83 c4 10             	add    $0x10,%esp
  802403:	be 00 00 00 00       	mov    $0x0,%esi
  802408:	3b 75 10             	cmp    0x10(%ebp),%esi
  80240b:	74 47                	je     802454 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  80240d:	8b 03                	mov    (%ebx),%eax
  80240f:	3b 43 04             	cmp    0x4(%ebx),%eax
  802412:	75 22                	jne    802436 <devpipe_read+0x4a>
			if (i > 0)
  802414:	85 f6                	test   %esi,%esi
  802416:	75 14                	jne    80242c <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  802418:	89 da                	mov    %ebx,%edx
  80241a:	89 f8                	mov    %edi,%eax
  80241c:	e8 e5 fe ff ff       	call   802306 <_pipeisclosed>
  802421:	85 c0                	test   %eax,%eax
  802423:	75 33                	jne    802458 <devpipe_read+0x6c>
			sys_yield();
  802425:	e8 9a eb ff ff       	call   800fc4 <sys_yield>
  80242a:	eb e1                	jmp    80240d <devpipe_read+0x21>
				return i;
  80242c:	89 f0                	mov    %esi,%eax
}
  80242e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802431:	5b                   	pop    %ebx
  802432:	5e                   	pop    %esi
  802433:	5f                   	pop    %edi
  802434:	5d                   	pop    %ebp
  802435:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802436:	99                   	cltd   
  802437:	c1 ea 1b             	shr    $0x1b,%edx
  80243a:	01 d0                	add    %edx,%eax
  80243c:	83 e0 1f             	and    $0x1f,%eax
  80243f:	29 d0                	sub    %edx,%eax
  802441:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802446:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802449:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  80244c:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  80244f:	83 c6 01             	add    $0x1,%esi
  802452:	eb b4                	jmp    802408 <devpipe_read+0x1c>
	return i;
  802454:	89 f0                	mov    %esi,%eax
  802456:	eb d6                	jmp    80242e <devpipe_read+0x42>
				return 0;
  802458:	b8 00 00 00 00       	mov    $0x0,%eax
  80245d:	eb cf                	jmp    80242e <devpipe_read+0x42>

0080245f <pipe>:
{
  80245f:	55                   	push   %ebp
  802460:	89 e5                	mov    %esp,%ebp
  802462:	56                   	push   %esi
  802463:	53                   	push   %ebx
  802464:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  802467:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80246a:	50                   	push   %eax
  80246b:	e8 7d f0 ff ff       	call   8014ed <fd_alloc>
  802470:	89 c3                	mov    %eax,%ebx
  802472:	83 c4 10             	add    $0x10,%esp
  802475:	85 c0                	test   %eax,%eax
  802477:	78 5b                	js     8024d4 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802479:	83 ec 04             	sub    $0x4,%esp
  80247c:	68 07 04 00 00       	push   $0x407
  802481:	ff 75 f4             	pushl  -0xc(%ebp)
  802484:	6a 00                	push   $0x0
  802486:	e8 58 eb ff ff       	call   800fe3 <sys_page_alloc>
  80248b:	89 c3                	mov    %eax,%ebx
  80248d:	83 c4 10             	add    $0x10,%esp
  802490:	85 c0                	test   %eax,%eax
  802492:	78 40                	js     8024d4 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  802494:	83 ec 0c             	sub    $0xc,%esp
  802497:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80249a:	50                   	push   %eax
  80249b:	e8 4d f0 ff ff       	call   8014ed <fd_alloc>
  8024a0:	89 c3                	mov    %eax,%ebx
  8024a2:	83 c4 10             	add    $0x10,%esp
  8024a5:	85 c0                	test   %eax,%eax
  8024a7:	78 1b                	js     8024c4 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8024a9:	83 ec 04             	sub    $0x4,%esp
  8024ac:	68 07 04 00 00       	push   $0x407
  8024b1:	ff 75 f0             	pushl  -0x10(%ebp)
  8024b4:	6a 00                	push   $0x0
  8024b6:	e8 28 eb ff ff       	call   800fe3 <sys_page_alloc>
  8024bb:	89 c3                	mov    %eax,%ebx
  8024bd:	83 c4 10             	add    $0x10,%esp
  8024c0:	85 c0                	test   %eax,%eax
  8024c2:	79 19                	jns    8024dd <pipe+0x7e>
	sys_page_unmap(0, fd0);
  8024c4:	83 ec 08             	sub    $0x8,%esp
  8024c7:	ff 75 f4             	pushl  -0xc(%ebp)
  8024ca:	6a 00                	push   $0x0
  8024cc:	e8 97 eb ff ff       	call   801068 <sys_page_unmap>
  8024d1:	83 c4 10             	add    $0x10,%esp
}
  8024d4:	89 d8                	mov    %ebx,%eax
  8024d6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8024d9:	5b                   	pop    %ebx
  8024da:	5e                   	pop    %esi
  8024db:	5d                   	pop    %ebp
  8024dc:	c3                   	ret    
	va = fd2data(fd0);
  8024dd:	83 ec 0c             	sub    $0xc,%esp
  8024e0:	ff 75 f4             	pushl  -0xc(%ebp)
  8024e3:	e8 ee ef ff ff       	call   8014d6 <fd2data>
  8024e8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8024ea:	83 c4 0c             	add    $0xc,%esp
  8024ed:	68 07 04 00 00       	push   $0x407
  8024f2:	50                   	push   %eax
  8024f3:	6a 00                	push   $0x0
  8024f5:	e8 e9 ea ff ff       	call   800fe3 <sys_page_alloc>
  8024fa:	89 c3                	mov    %eax,%ebx
  8024fc:	83 c4 10             	add    $0x10,%esp
  8024ff:	85 c0                	test   %eax,%eax
  802501:	0f 88 8c 00 00 00    	js     802593 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802507:	83 ec 0c             	sub    $0xc,%esp
  80250a:	ff 75 f0             	pushl  -0x10(%ebp)
  80250d:	e8 c4 ef ff ff       	call   8014d6 <fd2data>
  802512:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802519:	50                   	push   %eax
  80251a:	6a 00                	push   $0x0
  80251c:	56                   	push   %esi
  80251d:	6a 00                	push   $0x0
  80251f:	e8 02 eb ff ff       	call   801026 <sys_page_map>
  802524:	89 c3                	mov    %eax,%ebx
  802526:	83 c4 20             	add    $0x20,%esp
  802529:	85 c0                	test   %eax,%eax
  80252b:	78 58                	js     802585 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  80252d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802530:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802536:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802538:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80253b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  802542:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802545:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  80254b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80254d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802550:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  802557:	83 ec 0c             	sub    $0xc,%esp
  80255a:	ff 75 f4             	pushl  -0xc(%ebp)
  80255d:	e8 64 ef ff ff       	call   8014c6 <fd2num>
  802562:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802565:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802567:	83 c4 04             	add    $0x4,%esp
  80256a:	ff 75 f0             	pushl  -0x10(%ebp)
  80256d:	e8 54 ef ff ff       	call   8014c6 <fd2num>
  802572:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802575:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802578:	83 c4 10             	add    $0x10,%esp
  80257b:	bb 00 00 00 00       	mov    $0x0,%ebx
  802580:	e9 4f ff ff ff       	jmp    8024d4 <pipe+0x75>
	sys_page_unmap(0, va);
  802585:	83 ec 08             	sub    $0x8,%esp
  802588:	56                   	push   %esi
  802589:	6a 00                	push   $0x0
  80258b:	e8 d8 ea ff ff       	call   801068 <sys_page_unmap>
  802590:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  802593:	83 ec 08             	sub    $0x8,%esp
  802596:	ff 75 f0             	pushl  -0x10(%ebp)
  802599:	6a 00                	push   $0x0
  80259b:	e8 c8 ea ff ff       	call   801068 <sys_page_unmap>
  8025a0:	83 c4 10             	add    $0x10,%esp
  8025a3:	e9 1c ff ff ff       	jmp    8024c4 <pipe+0x65>

008025a8 <pipeisclosed>:
{
  8025a8:	55                   	push   %ebp
  8025a9:	89 e5                	mov    %esp,%ebp
  8025ab:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8025ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025b1:	50                   	push   %eax
  8025b2:	ff 75 08             	pushl  0x8(%ebp)
  8025b5:	e8 82 ef ff ff       	call   80153c <fd_lookup>
  8025ba:	83 c4 10             	add    $0x10,%esp
  8025bd:	85 c0                	test   %eax,%eax
  8025bf:	78 18                	js     8025d9 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  8025c1:	83 ec 0c             	sub    $0xc,%esp
  8025c4:	ff 75 f4             	pushl  -0xc(%ebp)
  8025c7:	e8 0a ef ff ff       	call   8014d6 <fd2data>
	return _pipeisclosed(fd, p);
  8025cc:	89 c2                	mov    %eax,%edx
  8025ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025d1:	e8 30 fd ff ff       	call   802306 <_pipeisclosed>
  8025d6:	83 c4 10             	add    $0x10,%esp
}
  8025d9:	c9                   	leave  
  8025da:	c3                   	ret    

008025db <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8025db:	55                   	push   %ebp
  8025dc:	89 e5                	mov    %esp,%ebp
  8025de:	56                   	push   %esi
  8025df:	53                   	push   %ebx
  8025e0:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8025e3:	85 f6                	test   %esi,%esi
  8025e5:	74 13                	je     8025fa <wait+0x1f>
	e = &envs[ENVX(envid)];
  8025e7:	89 f3                	mov    %esi,%ebx
  8025e9:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8025ef:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  8025f2:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8025f8:	eb 1b                	jmp    802615 <wait+0x3a>
	assert(envid != 0);
  8025fa:	68 d9 30 80 00       	push   $0x8030d9
  8025ff:	68 f3 2f 80 00       	push   $0x802ff3
  802604:	6a 09                	push   $0x9
  802606:	68 e4 30 80 00       	push   $0x8030e4
  80260b:	e8 e0 de ff ff       	call   8004f0 <_panic>
		sys_yield();
  802610:	e8 af e9 ff ff       	call   800fc4 <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802615:	8b 43 48             	mov    0x48(%ebx),%eax
  802618:	39 f0                	cmp    %esi,%eax
  80261a:	75 07                	jne    802623 <wait+0x48>
  80261c:	8b 43 54             	mov    0x54(%ebx),%eax
  80261f:	85 c0                	test   %eax,%eax
  802621:	75 ed                	jne    802610 <wait+0x35>
}
  802623:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802626:	5b                   	pop    %ebx
  802627:	5e                   	pop    %esi
  802628:	5d                   	pop    %ebp
  802629:	c3                   	ret    

0080262a <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80262a:	55                   	push   %ebp
  80262b:	89 e5                	mov    %esp,%ebp
  80262d:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802630:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802637:	74 20                	je     802659 <set_pgfault_handler+0x2f>
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
			panic("set_pgfault_handler:sys_page_alloc failed");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802639:	8b 45 08             	mov    0x8(%ebp),%eax
  80263c:	a3 00 70 80 00       	mov    %eax,0x807000
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  802641:	83 ec 08             	sub    $0x8,%esp
  802644:	68 99 26 80 00       	push   $0x802699
  802649:	6a 00                	push   $0x0
  80264b:	e8 de ea ff ff       	call   80112e <sys_env_set_pgfault_upcall>
  802650:	83 c4 10             	add    $0x10,%esp
  802653:	85 c0                	test   %eax,%eax
  802655:	78 2e                	js     802685 <set_pgfault_handler+0x5b>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
}
  802657:	c9                   	leave  
  802658:	c3                   	ret    
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  802659:	83 ec 04             	sub    $0x4,%esp
  80265c:	6a 07                	push   $0x7
  80265e:	68 00 f0 bf ee       	push   $0xeebff000
  802663:	6a 00                	push   $0x0
  802665:	e8 79 e9 ff ff       	call   800fe3 <sys_page_alloc>
  80266a:	83 c4 10             	add    $0x10,%esp
  80266d:	85 c0                	test   %eax,%eax
  80266f:	79 c8                	jns    802639 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler:sys_page_alloc failed");
  802671:	83 ec 04             	sub    $0x4,%esp
  802674:	68 f0 30 80 00       	push   $0x8030f0
  802679:	6a 21                	push   $0x21
  80267b:	68 54 31 80 00       	push   $0x803154
  802680:	e8 6b de ff ff       	call   8004f0 <_panic>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  802685:	83 ec 04             	sub    $0x4,%esp
  802688:	68 1c 31 80 00       	push   $0x80311c
  80268d:	6a 27                	push   $0x27
  80268f:	68 54 31 80 00       	push   $0x803154
  802694:	e8 57 de ff ff       	call   8004f0 <_panic>

00802699 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802699:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80269a:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  80269f:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8026a1:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %eax
  8026a4:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  8026a8:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  8026ab:	89 44 24 30          	mov    %eax,0x30(%esp)
	movl 40(%esp), %ebx
  8026af:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  8026b3:	89 18                	mov    %ebx,(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  8026b5:	83 c4 08             	add    $0x8,%esp
	popal
  8026b8:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  8026b9:	83 c4 04             	add    $0x4,%esp
	popfl
  8026bc:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8026bd:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8026be:	c3                   	ret    

008026bf <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8026bf:	55                   	push   %ebp
  8026c0:	89 e5                	mov    %esp,%ebp
  8026c2:	56                   	push   %esi
  8026c3:	53                   	push   %ebx
  8026c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8026c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026ca:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  8026cd:	85 f6                	test   %esi,%esi
  8026cf:	74 06                	je     8026d7 <ipc_recv+0x18>
  8026d1:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  8026d7:	85 db                	test   %ebx,%ebx
  8026d9:	74 06                	je     8026e1 <ipc_recv+0x22>
  8026db:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  8026e1:	85 c0                	test   %eax,%eax
  8026e3:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  8026e8:	0f 44 c2             	cmove  %edx,%eax
	int ret = sys_ipc_recv(pg);
  8026eb:	83 ec 0c             	sub    $0xc,%esp
  8026ee:	50                   	push   %eax
  8026ef:	e8 9f ea ff ff       	call   801193 <sys_ipc_recv>
	if (ret) return ret;
  8026f4:	83 c4 10             	add    $0x10,%esp
  8026f7:	85 c0                	test   %eax,%eax
  8026f9:	75 24                	jne    80271f <ipc_recv+0x60>
	if (from_env_store)
  8026fb:	85 f6                	test   %esi,%esi
  8026fd:	74 0a                	je     802709 <ipc_recv+0x4a>
		*from_env_store = thisenv->env_ipc_from;
  8026ff:	a1 04 50 80 00       	mov    0x805004,%eax
  802704:	8b 40 74             	mov    0x74(%eax),%eax
  802707:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  802709:	85 db                	test   %ebx,%ebx
  80270b:	74 0a                	je     802717 <ipc_recv+0x58>
		*perm_store = thisenv->env_ipc_perm;
  80270d:	a1 04 50 80 00       	mov    0x805004,%eax
  802712:	8b 40 78             	mov    0x78(%eax),%eax
  802715:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  802717:	a1 04 50 80 00       	mov    0x805004,%eax
  80271c:	8b 40 70             	mov    0x70(%eax),%eax
}
  80271f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802722:	5b                   	pop    %ebx
  802723:	5e                   	pop    %esi
  802724:	5d                   	pop    %ebp
  802725:	c3                   	ret    

00802726 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802726:	55                   	push   %ebp
  802727:	89 e5                	mov    %esp,%ebp
  802729:	57                   	push   %edi
  80272a:	56                   	push   %esi
  80272b:	53                   	push   %ebx
  80272c:	83 ec 0c             	sub    $0xc,%esp
  80272f:	8b 7d 08             	mov    0x8(%ebp),%edi
  802732:	8b 75 0c             	mov    0xc(%ebp),%esi
  802735:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  802738:	85 db                	test   %ebx,%ebx
  80273a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80273f:	0f 44 d8             	cmove  %eax,%ebx
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  802742:	ff 75 14             	pushl  0x14(%ebp)
  802745:	53                   	push   %ebx
  802746:	56                   	push   %esi
  802747:	57                   	push   %edi
  802748:	e8 23 ea ff ff       	call   801170 <sys_ipc_try_send>
  80274d:	83 c4 10             	add    $0x10,%esp
  802750:	85 c0                	test   %eax,%eax
  802752:	74 1e                	je     802772 <ipc_send+0x4c>
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  802754:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802757:	75 07                	jne    802760 <ipc_send+0x3a>
		sys_yield();
  802759:	e8 66 e8 ff ff       	call   800fc4 <sys_yield>
  80275e:	eb e2                	jmp    802742 <ipc_send+0x1c>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  802760:	50                   	push   %eax
  802761:	68 62 31 80 00       	push   $0x803162
  802766:	6a 36                	push   $0x36
  802768:	68 79 31 80 00       	push   $0x803179
  80276d:	e8 7e dd ff ff       	call   8004f0 <_panic>
	}
}
  802772:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802775:	5b                   	pop    %ebx
  802776:	5e                   	pop    %esi
  802777:	5f                   	pop    %edi
  802778:	5d                   	pop    %ebp
  802779:	c3                   	ret    

0080277a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80277a:	55                   	push   %ebp
  80277b:	89 e5                	mov    %esp,%ebp
  80277d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802780:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802785:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802788:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80278e:	8b 52 50             	mov    0x50(%edx),%edx
  802791:	39 ca                	cmp    %ecx,%edx
  802793:	74 11                	je     8027a6 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  802795:	83 c0 01             	add    $0x1,%eax
  802798:	3d 00 04 00 00       	cmp    $0x400,%eax
  80279d:	75 e6                	jne    802785 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  80279f:	b8 00 00 00 00       	mov    $0x0,%eax
  8027a4:	eb 0b                	jmp    8027b1 <ipc_find_env+0x37>
			return envs[i].env_id;
  8027a6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8027a9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8027ae:	8b 40 48             	mov    0x48(%eax),%eax
}
  8027b1:	5d                   	pop    %ebp
  8027b2:	c3                   	ret    

008027b3 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8027b3:	55                   	push   %ebp
  8027b4:	89 e5                	mov    %esp,%ebp
  8027b6:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8027b9:	89 d0                	mov    %edx,%eax
  8027bb:	c1 e8 16             	shr    $0x16,%eax
  8027be:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8027c5:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  8027ca:	f6 c1 01             	test   $0x1,%cl
  8027cd:	74 1d                	je     8027ec <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  8027cf:	c1 ea 0c             	shr    $0xc,%edx
  8027d2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8027d9:	f6 c2 01             	test   $0x1,%dl
  8027dc:	74 0e                	je     8027ec <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8027de:	c1 ea 0c             	shr    $0xc,%edx
  8027e1:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8027e8:	ef 
  8027e9:	0f b7 c0             	movzwl %ax,%eax
}
  8027ec:	5d                   	pop    %ebp
  8027ed:	c3                   	ret    
  8027ee:	66 90                	xchg   %ax,%ax

008027f0 <__udivdi3>:
  8027f0:	55                   	push   %ebp
  8027f1:	57                   	push   %edi
  8027f2:	56                   	push   %esi
  8027f3:	53                   	push   %ebx
  8027f4:	83 ec 1c             	sub    $0x1c,%esp
  8027f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8027fb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8027ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  802803:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  802807:	85 d2                	test   %edx,%edx
  802809:	75 35                	jne    802840 <__udivdi3+0x50>
  80280b:	39 f3                	cmp    %esi,%ebx
  80280d:	0f 87 bd 00 00 00    	ja     8028d0 <__udivdi3+0xe0>
  802813:	85 db                	test   %ebx,%ebx
  802815:	89 d9                	mov    %ebx,%ecx
  802817:	75 0b                	jne    802824 <__udivdi3+0x34>
  802819:	b8 01 00 00 00       	mov    $0x1,%eax
  80281e:	31 d2                	xor    %edx,%edx
  802820:	f7 f3                	div    %ebx
  802822:	89 c1                	mov    %eax,%ecx
  802824:	31 d2                	xor    %edx,%edx
  802826:	89 f0                	mov    %esi,%eax
  802828:	f7 f1                	div    %ecx
  80282a:	89 c6                	mov    %eax,%esi
  80282c:	89 e8                	mov    %ebp,%eax
  80282e:	89 f7                	mov    %esi,%edi
  802830:	f7 f1                	div    %ecx
  802832:	89 fa                	mov    %edi,%edx
  802834:	83 c4 1c             	add    $0x1c,%esp
  802837:	5b                   	pop    %ebx
  802838:	5e                   	pop    %esi
  802839:	5f                   	pop    %edi
  80283a:	5d                   	pop    %ebp
  80283b:	c3                   	ret    
  80283c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802840:	39 f2                	cmp    %esi,%edx
  802842:	77 7c                	ja     8028c0 <__udivdi3+0xd0>
  802844:	0f bd fa             	bsr    %edx,%edi
  802847:	83 f7 1f             	xor    $0x1f,%edi
  80284a:	0f 84 98 00 00 00    	je     8028e8 <__udivdi3+0xf8>
  802850:	89 f9                	mov    %edi,%ecx
  802852:	b8 20 00 00 00       	mov    $0x20,%eax
  802857:	29 f8                	sub    %edi,%eax
  802859:	d3 e2                	shl    %cl,%edx
  80285b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80285f:	89 c1                	mov    %eax,%ecx
  802861:	89 da                	mov    %ebx,%edx
  802863:	d3 ea                	shr    %cl,%edx
  802865:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802869:	09 d1                	or     %edx,%ecx
  80286b:	89 f2                	mov    %esi,%edx
  80286d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802871:	89 f9                	mov    %edi,%ecx
  802873:	d3 e3                	shl    %cl,%ebx
  802875:	89 c1                	mov    %eax,%ecx
  802877:	d3 ea                	shr    %cl,%edx
  802879:	89 f9                	mov    %edi,%ecx
  80287b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80287f:	d3 e6                	shl    %cl,%esi
  802881:	89 eb                	mov    %ebp,%ebx
  802883:	89 c1                	mov    %eax,%ecx
  802885:	d3 eb                	shr    %cl,%ebx
  802887:	09 de                	or     %ebx,%esi
  802889:	89 f0                	mov    %esi,%eax
  80288b:	f7 74 24 08          	divl   0x8(%esp)
  80288f:	89 d6                	mov    %edx,%esi
  802891:	89 c3                	mov    %eax,%ebx
  802893:	f7 64 24 0c          	mull   0xc(%esp)
  802897:	39 d6                	cmp    %edx,%esi
  802899:	72 0c                	jb     8028a7 <__udivdi3+0xb7>
  80289b:	89 f9                	mov    %edi,%ecx
  80289d:	d3 e5                	shl    %cl,%ebp
  80289f:	39 c5                	cmp    %eax,%ebp
  8028a1:	73 5d                	jae    802900 <__udivdi3+0x110>
  8028a3:	39 d6                	cmp    %edx,%esi
  8028a5:	75 59                	jne    802900 <__udivdi3+0x110>
  8028a7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8028aa:	31 ff                	xor    %edi,%edi
  8028ac:	89 fa                	mov    %edi,%edx
  8028ae:	83 c4 1c             	add    $0x1c,%esp
  8028b1:	5b                   	pop    %ebx
  8028b2:	5e                   	pop    %esi
  8028b3:	5f                   	pop    %edi
  8028b4:	5d                   	pop    %ebp
  8028b5:	c3                   	ret    
  8028b6:	8d 76 00             	lea    0x0(%esi),%esi
  8028b9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8028c0:	31 ff                	xor    %edi,%edi
  8028c2:	31 c0                	xor    %eax,%eax
  8028c4:	89 fa                	mov    %edi,%edx
  8028c6:	83 c4 1c             	add    $0x1c,%esp
  8028c9:	5b                   	pop    %ebx
  8028ca:	5e                   	pop    %esi
  8028cb:	5f                   	pop    %edi
  8028cc:	5d                   	pop    %ebp
  8028cd:	c3                   	ret    
  8028ce:	66 90                	xchg   %ax,%ax
  8028d0:	31 ff                	xor    %edi,%edi
  8028d2:	89 e8                	mov    %ebp,%eax
  8028d4:	89 f2                	mov    %esi,%edx
  8028d6:	f7 f3                	div    %ebx
  8028d8:	89 fa                	mov    %edi,%edx
  8028da:	83 c4 1c             	add    $0x1c,%esp
  8028dd:	5b                   	pop    %ebx
  8028de:	5e                   	pop    %esi
  8028df:	5f                   	pop    %edi
  8028e0:	5d                   	pop    %ebp
  8028e1:	c3                   	ret    
  8028e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8028e8:	39 f2                	cmp    %esi,%edx
  8028ea:	72 06                	jb     8028f2 <__udivdi3+0x102>
  8028ec:	31 c0                	xor    %eax,%eax
  8028ee:	39 eb                	cmp    %ebp,%ebx
  8028f0:	77 d2                	ja     8028c4 <__udivdi3+0xd4>
  8028f2:	b8 01 00 00 00       	mov    $0x1,%eax
  8028f7:	eb cb                	jmp    8028c4 <__udivdi3+0xd4>
  8028f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802900:	89 d8                	mov    %ebx,%eax
  802902:	31 ff                	xor    %edi,%edi
  802904:	eb be                	jmp    8028c4 <__udivdi3+0xd4>
  802906:	66 90                	xchg   %ax,%ax
  802908:	66 90                	xchg   %ax,%ax
  80290a:	66 90                	xchg   %ax,%ax
  80290c:	66 90                	xchg   %ax,%ax
  80290e:	66 90                	xchg   %ax,%ax

00802910 <__umoddi3>:
  802910:	55                   	push   %ebp
  802911:	57                   	push   %edi
  802912:	56                   	push   %esi
  802913:	53                   	push   %ebx
  802914:	83 ec 1c             	sub    $0x1c,%esp
  802917:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80291b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80291f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802923:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802927:	85 ed                	test   %ebp,%ebp
  802929:	89 f0                	mov    %esi,%eax
  80292b:	89 da                	mov    %ebx,%edx
  80292d:	75 19                	jne    802948 <__umoddi3+0x38>
  80292f:	39 df                	cmp    %ebx,%edi
  802931:	0f 86 b1 00 00 00    	jbe    8029e8 <__umoddi3+0xd8>
  802937:	f7 f7                	div    %edi
  802939:	89 d0                	mov    %edx,%eax
  80293b:	31 d2                	xor    %edx,%edx
  80293d:	83 c4 1c             	add    $0x1c,%esp
  802940:	5b                   	pop    %ebx
  802941:	5e                   	pop    %esi
  802942:	5f                   	pop    %edi
  802943:	5d                   	pop    %ebp
  802944:	c3                   	ret    
  802945:	8d 76 00             	lea    0x0(%esi),%esi
  802948:	39 dd                	cmp    %ebx,%ebp
  80294a:	77 f1                	ja     80293d <__umoddi3+0x2d>
  80294c:	0f bd cd             	bsr    %ebp,%ecx
  80294f:	83 f1 1f             	xor    $0x1f,%ecx
  802952:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802956:	0f 84 b4 00 00 00    	je     802a10 <__umoddi3+0x100>
  80295c:	b8 20 00 00 00       	mov    $0x20,%eax
  802961:	89 c2                	mov    %eax,%edx
  802963:	8b 44 24 04          	mov    0x4(%esp),%eax
  802967:	29 c2                	sub    %eax,%edx
  802969:	89 c1                	mov    %eax,%ecx
  80296b:	89 f8                	mov    %edi,%eax
  80296d:	d3 e5                	shl    %cl,%ebp
  80296f:	89 d1                	mov    %edx,%ecx
  802971:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802975:	d3 e8                	shr    %cl,%eax
  802977:	09 c5                	or     %eax,%ebp
  802979:	8b 44 24 04          	mov    0x4(%esp),%eax
  80297d:	89 c1                	mov    %eax,%ecx
  80297f:	d3 e7                	shl    %cl,%edi
  802981:	89 d1                	mov    %edx,%ecx
  802983:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802987:	89 df                	mov    %ebx,%edi
  802989:	d3 ef                	shr    %cl,%edi
  80298b:	89 c1                	mov    %eax,%ecx
  80298d:	89 f0                	mov    %esi,%eax
  80298f:	d3 e3                	shl    %cl,%ebx
  802991:	89 d1                	mov    %edx,%ecx
  802993:	89 fa                	mov    %edi,%edx
  802995:	d3 e8                	shr    %cl,%eax
  802997:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80299c:	09 d8                	or     %ebx,%eax
  80299e:	f7 f5                	div    %ebp
  8029a0:	d3 e6                	shl    %cl,%esi
  8029a2:	89 d1                	mov    %edx,%ecx
  8029a4:	f7 64 24 08          	mull   0x8(%esp)
  8029a8:	39 d1                	cmp    %edx,%ecx
  8029aa:	89 c3                	mov    %eax,%ebx
  8029ac:	89 d7                	mov    %edx,%edi
  8029ae:	72 06                	jb     8029b6 <__umoddi3+0xa6>
  8029b0:	75 0e                	jne    8029c0 <__umoddi3+0xb0>
  8029b2:	39 c6                	cmp    %eax,%esi
  8029b4:	73 0a                	jae    8029c0 <__umoddi3+0xb0>
  8029b6:	2b 44 24 08          	sub    0x8(%esp),%eax
  8029ba:	19 ea                	sbb    %ebp,%edx
  8029bc:	89 d7                	mov    %edx,%edi
  8029be:	89 c3                	mov    %eax,%ebx
  8029c0:	89 ca                	mov    %ecx,%edx
  8029c2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8029c7:	29 de                	sub    %ebx,%esi
  8029c9:	19 fa                	sbb    %edi,%edx
  8029cb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  8029cf:	89 d0                	mov    %edx,%eax
  8029d1:	d3 e0                	shl    %cl,%eax
  8029d3:	89 d9                	mov    %ebx,%ecx
  8029d5:	d3 ee                	shr    %cl,%esi
  8029d7:	d3 ea                	shr    %cl,%edx
  8029d9:	09 f0                	or     %esi,%eax
  8029db:	83 c4 1c             	add    $0x1c,%esp
  8029de:	5b                   	pop    %ebx
  8029df:	5e                   	pop    %esi
  8029e0:	5f                   	pop    %edi
  8029e1:	5d                   	pop    %ebp
  8029e2:	c3                   	ret    
  8029e3:	90                   	nop
  8029e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8029e8:	85 ff                	test   %edi,%edi
  8029ea:	89 f9                	mov    %edi,%ecx
  8029ec:	75 0b                	jne    8029f9 <__umoddi3+0xe9>
  8029ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8029f3:	31 d2                	xor    %edx,%edx
  8029f5:	f7 f7                	div    %edi
  8029f7:	89 c1                	mov    %eax,%ecx
  8029f9:	89 d8                	mov    %ebx,%eax
  8029fb:	31 d2                	xor    %edx,%edx
  8029fd:	f7 f1                	div    %ecx
  8029ff:	89 f0                	mov    %esi,%eax
  802a01:	f7 f1                	div    %ecx
  802a03:	e9 31 ff ff ff       	jmp    802939 <__umoddi3+0x29>
  802a08:	90                   	nop
  802a09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802a10:	39 dd                	cmp    %ebx,%ebp
  802a12:	72 08                	jb     802a1c <__umoddi3+0x10c>
  802a14:	39 f7                	cmp    %esi,%edi
  802a16:	0f 87 21 ff ff ff    	ja     80293d <__umoddi3+0x2d>
  802a1c:	89 da                	mov    %ebx,%edx
  802a1e:	89 f0                	mov    %esi,%eax
  802a20:	29 f8                	sub    %edi,%eax
  802a22:	19 ea                	sbb    %ebp,%edx
  802a24:	e9 14 ff ff ff       	jmp    80293d <__umoddi3+0x2d>
