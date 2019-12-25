
obj/user/sh.debug：     文件格式 elf32-i386


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
  80002c:	e8 ea 09 00 00       	call   800a1b <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <_gettoken>:
#define WHITESPACE " \t\r\n"
#define SYMBOLS "<|>&;()"

int
_gettoken(char *s, char **p1, char **p2)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int t;

	if (s == 0) {
  80003b:	85 db                	test   %ebx,%ebx
  80003d:	74 1d                	je     80005c <_gettoken+0x29>
		if (debug > 1)
			cprintf("GETTOKEN NULL\n");
		return 0;
	}

	if (debug > 1)
  80003f:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800046:	7f 34                	jg     80007c <_gettoken+0x49>
		cprintf("GETTOKEN: %s\n", s);

	*p1 = 0;
  800048:	8b 45 0c             	mov    0xc(%ebp),%eax
  80004b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*p2 = 0;
  800051:	8b 45 10             	mov    0x10(%ebp),%eax
  800054:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	while (strchr(WHITESPACE, *s))
  80005a:	eb 3a                	jmp    800096 <_gettoken+0x63>
		return 0;
  80005c:	be 00 00 00 00       	mov    $0x0,%esi
		if (debug > 1)
  800061:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800068:	7e 59                	jle    8000c3 <_gettoken+0x90>
			cprintf("GETTOKEN NULL\n");
  80006a:	83 ec 0c             	sub    $0xc,%esp
  80006d:	68 20 33 80 00       	push   $0x803320
  800072:	e8 df 0a 00 00       	call   800b56 <cprintf>
  800077:	83 c4 10             	add    $0x10,%esp
  80007a:	eb 47                	jmp    8000c3 <_gettoken+0x90>
		cprintf("GETTOKEN: %s\n", s);
  80007c:	83 ec 08             	sub    $0x8,%esp
  80007f:	53                   	push   %ebx
  800080:	68 2f 33 80 00       	push   $0x80332f
  800085:	e8 cc 0a 00 00       	call   800b56 <cprintf>
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	eb b9                	jmp    800048 <_gettoken+0x15>
		*s++ = 0;
  80008f:	83 c3 01             	add    $0x1,%ebx
  800092:	c6 43 ff 00          	movb   $0x0,-0x1(%ebx)
	while (strchr(WHITESPACE, *s))
  800096:	83 ec 08             	sub    $0x8,%esp
  800099:	0f be 03             	movsbl (%ebx),%eax
  80009c:	50                   	push   %eax
  80009d:	68 3d 33 80 00       	push   $0x80333d
  8000a2:	e8 c2 12 00 00       	call   801369 <strchr>
  8000a7:	83 c4 10             	add    $0x10,%esp
  8000aa:	85 c0                	test   %eax,%eax
  8000ac:	75 e1                	jne    80008f <_gettoken+0x5c>
	if (*s == 0) {
  8000ae:	0f b6 03             	movzbl (%ebx),%eax
  8000b1:	84 c0                	test   %al,%al
  8000b3:	75 29                	jne    8000de <_gettoken+0xab>
		if (debug > 1)
			cprintf("EOL\n");
		return 0;
  8000b5:	be 00 00 00 00       	mov    $0x0,%esi
		if (debug > 1)
  8000ba:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  8000c1:	7f 09                	jg     8000cc <_gettoken+0x99>
		**p2 = 0;
		cprintf("WORD: %s\n", *p1);
		**p2 = t;
	}
	return 'w';
}
  8000c3:	89 f0                	mov    %esi,%eax
  8000c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c8:	5b                   	pop    %ebx
  8000c9:	5e                   	pop    %esi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    
			cprintf("EOL\n");
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	68 42 33 80 00       	push   $0x803342
  8000d4:	e8 7d 0a 00 00       	call   800b56 <cprintf>
  8000d9:	83 c4 10             	add    $0x10,%esp
  8000dc:	eb e5                	jmp    8000c3 <_gettoken+0x90>
	if (strchr(SYMBOLS, *s)) {
  8000de:	83 ec 08             	sub    $0x8,%esp
  8000e1:	0f be c0             	movsbl %al,%eax
  8000e4:	50                   	push   %eax
  8000e5:	68 53 33 80 00       	push   $0x803353
  8000ea:	e8 7a 12 00 00       	call   801369 <strchr>
  8000ef:	83 c4 10             	add    $0x10,%esp
  8000f2:	85 c0                	test   %eax,%eax
  8000f4:	74 2f                	je     800125 <_gettoken+0xf2>
		t = *s;
  8000f6:	0f be 33             	movsbl (%ebx),%esi
		*p1 = s;
  8000f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000fc:	89 18                	mov    %ebx,(%eax)
		*s++ = 0;
  8000fe:	c6 03 00             	movb   $0x0,(%ebx)
  800101:	83 c3 01             	add    $0x1,%ebx
  800104:	8b 45 10             	mov    0x10(%ebp),%eax
  800107:	89 18                	mov    %ebx,(%eax)
		if (debug > 1)
  800109:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800110:	7e b1                	jle    8000c3 <_gettoken+0x90>
			cprintf("TOK %c\n", t);
  800112:	83 ec 08             	sub    $0x8,%esp
  800115:	56                   	push   %esi
  800116:	68 47 33 80 00       	push   $0x803347
  80011b:	e8 36 0a 00 00       	call   800b56 <cprintf>
  800120:	83 c4 10             	add    $0x10,%esp
  800123:	eb 9e                	jmp    8000c3 <_gettoken+0x90>
	*p1 = s;
  800125:	8b 45 0c             	mov    0xc(%ebp),%eax
  800128:	89 18                	mov    %ebx,(%eax)
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  80012a:	eb 03                	jmp    80012f <_gettoken+0xfc>
		s++;
  80012c:	83 c3 01             	add    $0x1,%ebx
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  80012f:	0f b6 03             	movzbl (%ebx),%eax
  800132:	84 c0                	test   %al,%al
  800134:	74 18                	je     80014e <_gettoken+0x11b>
  800136:	83 ec 08             	sub    $0x8,%esp
  800139:	0f be c0             	movsbl %al,%eax
  80013c:	50                   	push   %eax
  80013d:	68 4f 33 80 00       	push   $0x80334f
  800142:	e8 22 12 00 00       	call   801369 <strchr>
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	85 c0                	test   %eax,%eax
  80014c:	74 de                	je     80012c <_gettoken+0xf9>
	*p2 = s;
  80014e:	8b 45 10             	mov    0x10(%ebp),%eax
  800151:	89 18                	mov    %ebx,(%eax)
	return 'w';
  800153:	be 77 00 00 00       	mov    $0x77,%esi
	if (debug > 1) {
  800158:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  80015f:	0f 8e 5e ff ff ff    	jle    8000c3 <_gettoken+0x90>
		t = **p2;
  800165:	0f b6 33             	movzbl (%ebx),%esi
		**p2 = 0;
  800168:	c6 03 00             	movb   $0x0,(%ebx)
		cprintf("WORD: %s\n", *p1);
  80016b:	83 ec 08             	sub    $0x8,%esp
  80016e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800171:	ff 30                	pushl  (%eax)
  800173:	68 5b 33 80 00       	push   $0x80335b
  800178:	e8 d9 09 00 00       	call   800b56 <cprintf>
		**p2 = t;
  80017d:	8b 45 10             	mov    0x10(%ebp),%eax
  800180:	8b 00                	mov    (%eax),%eax
  800182:	89 f2                	mov    %esi,%edx
  800184:	88 10                	mov    %dl,(%eax)
  800186:	83 c4 10             	add    $0x10,%esp
	return 'w';
  800189:	be 77 00 00 00       	mov    $0x77,%esi
  80018e:	e9 30 ff ff ff       	jmp    8000c3 <_gettoken+0x90>

00800193 <gettoken>:

int
gettoken(char *s, char **p1)
{
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	83 ec 08             	sub    $0x8,%esp
  800199:	8b 45 08             	mov    0x8(%ebp),%eax
	static int c, nc;
	static char* np1, *np2;

	if (s) {
  80019c:	85 c0                	test   %eax,%eax
  80019e:	74 22                	je     8001c2 <gettoken+0x2f>
		nc = _gettoken(s, &np1, &np2);
  8001a0:	83 ec 04             	sub    $0x4,%esp
  8001a3:	68 0c 50 80 00       	push   $0x80500c
  8001a8:	68 10 50 80 00       	push   $0x805010
  8001ad:	50                   	push   %eax
  8001ae:	e8 80 fe ff ff       	call   800033 <_gettoken>
  8001b3:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  8001b8:	83 c4 10             	add    $0x10,%esp
  8001bb:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	c = nc;
	*p1 = np1;
	nc = _gettoken(np2, &np1, &np2);
	return c;
}
  8001c0:	c9                   	leave  
  8001c1:	c3                   	ret    
	c = nc;
  8001c2:	a1 08 50 80 00       	mov    0x805008,%eax
  8001c7:	a3 04 50 80 00       	mov    %eax,0x805004
	*p1 = np1;
  8001cc:	8b 15 10 50 80 00    	mov    0x805010,%edx
  8001d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001d5:	89 10                	mov    %edx,(%eax)
	nc = _gettoken(np2, &np1, &np2);
  8001d7:	83 ec 04             	sub    $0x4,%esp
  8001da:	68 0c 50 80 00       	push   $0x80500c
  8001df:	68 10 50 80 00       	push   $0x805010
  8001e4:	ff 35 0c 50 80 00    	pushl  0x80500c
  8001ea:	e8 44 fe ff ff       	call   800033 <_gettoken>
  8001ef:	a3 08 50 80 00       	mov    %eax,0x805008
	return c;
  8001f4:	a1 04 50 80 00       	mov    0x805004,%eax
  8001f9:	83 c4 10             	add    $0x10,%esp
  8001fc:	eb c2                	jmp    8001c0 <gettoken+0x2d>

008001fe <runcmd>:
{
  8001fe:	55                   	push   %ebp
  8001ff:	89 e5                	mov    %esp,%ebp
  800201:	57                   	push   %edi
  800202:	56                   	push   %esi
  800203:	53                   	push   %ebx
  800204:	81 ec 64 04 00 00    	sub    $0x464,%esp
	gettoken(s, 0);
  80020a:	6a 00                	push   $0x0
  80020c:	ff 75 08             	pushl  0x8(%ebp)
  80020f:	e8 7f ff ff ff       	call   800193 <gettoken>
  800214:	83 c4 10             	add    $0x10,%esp
		switch ((c = gettoken(0, &t))) {
  800217:	8d 75 a4             	lea    -0x5c(%ebp),%esi
	argc = 0;
  80021a:	bf 00 00 00 00       	mov    $0x0,%edi
		switch ((c = gettoken(0, &t))) {
  80021f:	83 ec 08             	sub    $0x8,%esp
  800222:	56                   	push   %esi
  800223:	6a 00                	push   $0x0
  800225:	e8 69 ff ff ff       	call   800193 <gettoken>
  80022a:	89 c3                	mov    %eax,%ebx
  80022c:	83 c4 10             	add    $0x10,%esp
  80022f:	83 f8 3e             	cmp    $0x3e,%eax
  800232:	0f 84 39 01 00 00    	je     800371 <runcmd+0x173>
  800238:	83 f8 3e             	cmp    $0x3e,%eax
  80023b:	7f 4b                	jg     800288 <runcmd+0x8a>
  80023d:	85 c0                	test   %eax,%eax
  80023f:	0f 84 1c 02 00 00    	je     800461 <runcmd+0x263>
  800245:	83 f8 3c             	cmp    $0x3c,%eax
  800248:	0f 85 78 02 00 00    	jne    8004c6 <runcmd+0x2c8>
			if (gettoken(0, &t) != 'w') {
  80024e:	83 ec 08             	sub    $0x8,%esp
  800251:	56                   	push   %esi
  800252:	6a 00                	push   $0x0
  800254:	e8 3a ff ff ff       	call   800193 <gettoken>
  800259:	83 c4 10             	add    $0x10,%esp
  80025c:	83 f8 77             	cmp    $0x77,%eax
  80025f:	0f 85 be 00 00 00    	jne    800323 <runcmd+0x125>
            		if ((fd = open(t, O_RDONLY)) < 0) {
  800265:	83 ec 08             	sub    $0x8,%esp
  800268:	6a 00                	push   $0x0
  80026a:	ff 75 a4             	pushl  -0x5c(%ebp)
  80026d:	e8 62 21 00 00       	call   8023d4 <open>
  800272:	89 c3                	mov    %eax,%ebx
  800274:	83 c4 10             	add    $0x10,%esp
  800277:	85 c0                	test   %eax,%eax
  800279:	0f 88 be 00 00 00    	js     80033d <runcmd+0x13f>
            		if (fd != 0) {
  80027f:	85 c0                	test   %eax,%eax
  800281:	74 9c                	je     80021f <runcmd+0x21>
  800283:	e9 ce 00 00 00       	jmp    800356 <runcmd+0x158>
		switch ((c = gettoken(0, &t))) {
  800288:	83 f8 77             	cmp    $0x77,%eax
  80028b:	74 6b                	je     8002f8 <runcmd+0xfa>
  80028d:	83 f8 7c             	cmp    $0x7c,%eax
  800290:	0f 85 30 02 00 00    	jne    8004c6 <runcmd+0x2c8>
			if ((r = pipe(p)) < 0) {
  800296:	83 ec 0c             	sub    $0xc,%esp
  800299:	8d 85 9c fb ff ff    	lea    -0x464(%ebp),%eax
  80029f:	50                   	push   %eax
  8002a0:	e8 9e 2a 00 00       	call   802d43 <pipe>
  8002a5:	83 c4 10             	add    $0x10,%esp
  8002a8:	85 c0                	test   %eax,%eax
  8002aa:	0f 88 43 01 00 00    	js     8003f3 <runcmd+0x1f5>
			if (debug)
  8002b0:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8002b7:	0f 85 51 01 00 00    	jne    80040e <runcmd+0x210>
			if ((r = fork()) < 0) {
  8002bd:	e8 8f 16 00 00       	call   801951 <fork>
  8002c2:	89 c3                	mov    %eax,%ebx
  8002c4:	85 c0                	test   %eax,%eax
  8002c6:	0f 88 63 01 00 00    	js     80042f <runcmd+0x231>
			if (r == 0) {
  8002cc:	85 c0                	test   %eax,%eax
  8002ce:	0f 85 71 01 00 00    	jne    800445 <runcmd+0x247>
				if (p[0] != 0) {
  8002d4:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  8002da:	85 c0                	test   %eax,%eax
  8002dc:	0f 85 a5 01 00 00    	jne    800487 <runcmd+0x289>
				close(p[1]);
  8002e2:	83 ec 0c             	sub    $0xc,%esp
  8002e5:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  8002eb:	e8 50 1b 00 00       	call   801e40 <close>
				goto again;
  8002f0:	83 c4 10             	add    $0x10,%esp
  8002f3:	e9 22 ff ff ff       	jmp    80021a <runcmd+0x1c>
			if (argc == MAXARGS) {
  8002f8:	83 ff 10             	cmp    $0x10,%edi
  8002fb:	74 0f                	je     80030c <runcmd+0x10e>
			argv[argc++] = t;
  8002fd:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  800300:	89 44 bd a8          	mov    %eax,-0x58(%ebp,%edi,4)
  800304:	8d 7f 01             	lea    0x1(%edi),%edi
			break;
  800307:	e9 13 ff ff ff       	jmp    80021f <runcmd+0x21>
				cprintf("too many arguments\n");
  80030c:	83 ec 0c             	sub    $0xc,%esp
  80030f:	68 65 33 80 00       	push   $0x803365
  800314:	e8 3d 08 00 00       	call   800b56 <cprintf>
				exit();
  800319:	e8 43 07 00 00       	call   800a61 <exit>
  80031e:	83 c4 10             	add    $0x10,%esp
  800321:	eb da                	jmp    8002fd <runcmd+0xff>
				cprintf("syntax error: < not followed by word\n");
  800323:	83 ec 0c             	sub    $0xc,%esp
  800326:	68 9c 34 80 00       	push   $0x80349c
  80032b:	e8 26 08 00 00       	call   800b56 <cprintf>
				exit();
  800330:	e8 2c 07 00 00       	call   800a61 <exit>
  800335:	83 c4 10             	add    $0x10,%esp
  800338:	e9 28 ff ff ff       	jmp    800265 <runcmd+0x67>
                		cprintf("open %s for write: %e", t, fd);
  80033d:	83 ec 04             	sub    $0x4,%esp
  800340:	50                   	push   %eax
  800341:	ff 75 a4             	pushl  -0x5c(%ebp)
  800344:	68 79 33 80 00       	push   $0x803379
  800349:	e8 08 08 00 00       	call   800b56 <cprintf>
                		exit();
  80034e:	e8 0e 07 00 00       	call   800a61 <exit>
  800353:	83 c4 10             	add    $0x10,%esp
                		dup(fd, 0);
  800356:	83 ec 08             	sub    $0x8,%esp
  800359:	6a 00                	push   $0x0
  80035b:	53                   	push   %ebx
  80035c:	e8 2f 1b 00 00       	call   801e90 <dup>
                		close(fd);
  800361:	89 1c 24             	mov    %ebx,(%esp)
  800364:	e8 d7 1a 00 00       	call   801e40 <close>
  800369:	83 c4 10             	add    $0x10,%esp
  80036c:	e9 ae fe ff ff       	jmp    80021f <runcmd+0x21>
			if (gettoken(0, &t) != 'w') {
  800371:	83 ec 08             	sub    $0x8,%esp
  800374:	56                   	push   %esi
  800375:	6a 00                	push   $0x0
  800377:	e8 17 fe ff ff       	call   800193 <gettoken>
  80037c:	83 c4 10             	add    $0x10,%esp
  80037f:	83 f8 77             	cmp    $0x77,%eax
  800382:	75 3d                	jne    8003c1 <runcmd+0x1c3>
			if ((fd = open(t, O_WRONLY|O_CREAT|O_TRUNC)) < 0) {
  800384:	83 ec 08             	sub    $0x8,%esp
  800387:	68 01 03 00 00       	push   $0x301
  80038c:	ff 75 a4             	pushl  -0x5c(%ebp)
  80038f:	e8 40 20 00 00       	call   8023d4 <open>
  800394:	89 c3                	mov    %eax,%ebx
  800396:	83 c4 10             	add    $0x10,%esp
  800399:	85 c0                	test   %eax,%eax
  80039b:	78 3b                	js     8003d8 <runcmd+0x1da>
			if (fd != 1) {
  80039d:	83 fb 01             	cmp    $0x1,%ebx
  8003a0:	0f 84 79 fe ff ff    	je     80021f <runcmd+0x21>
				dup(fd, 1);
  8003a6:	83 ec 08             	sub    $0x8,%esp
  8003a9:	6a 01                	push   $0x1
  8003ab:	53                   	push   %ebx
  8003ac:	e8 df 1a 00 00       	call   801e90 <dup>
				close(fd);
  8003b1:	89 1c 24             	mov    %ebx,(%esp)
  8003b4:	e8 87 1a 00 00       	call   801e40 <close>
  8003b9:	83 c4 10             	add    $0x10,%esp
  8003bc:	e9 5e fe ff ff       	jmp    80021f <runcmd+0x21>
				cprintf("syntax error: > not followed by word\n");
  8003c1:	83 ec 0c             	sub    $0xc,%esp
  8003c4:	68 c4 34 80 00       	push   $0x8034c4
  8003c9:	e8 88 07 00 00       	call   800b56 <cprintf>
				exit();
  8003ce:	e8 8e 06 00 00       	call   800a61 <exit>
  8003d3:	83 c4 10             	add    $0x10,%esp
  8003d6:	eb ac                	jmp    800384 <runcmd+0x186>
				cprintf("open %s for write: %e", t, fd);
  8003d8:	83 ec 04             	sub    $0x4,%esp
  8003db:	50                   	push   %eax
  8003dc:	ff 75 a4             	pushl  -0x5c(%ebp)
  8003df:	68 79 33 80 00       	push   $0x803379
  8003e4:	e8 6d 07 00 00       	call   800b56 <cprintf>
				exit();
  8003e9:	e8 73 06 00 00       	call   800a61 <exit>
  8003ee:	83 c4 10             	add    $0x10,%esp
  8003f1:	eb aa                	jmp    80039d <runcmd+0x19f>
				cprintf("pipe: %e", r);
  8003f3:	83 ec 08             	sub    $0x8,%esp
  8003f6:	50                   	push   %eax
  8003f7:	68 8f 33 80 00       	push   $0x80338f
  8003fc:	e8 55 07 00 00       	call   800b56 <cprintf>
				exit();
  800401:	e8 5b 06 00 00       	call   800a61 <exit>
  800406:	83 c4 10             	add    $0x10,%esp
  800409:	e9 a2 fe ff ff       	jmp    8002b0 <runcmd+0xb2>
				cprintf("PIPE: %d %d\n", p[0], p[1]);
  80040e:	83 ec 04             	sub    $0x4,%esp
  800411:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  800417:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  80041d:	68 98 33 80 00       	push   $0x803398
  800422:	e8 2f 07 00 00       	call   800b56 <cprintf>
  800427:	83 c4 10             	add    $0x10,%esp
  80042a:	e9 8e fe ff ff       	jmp    8002bd <runcmd+0xbf>
				cprintf("fork: %e", r);
  80042f:	83 ec 08             	sub    $0x8,%esp
  800432:	50                   	push   %eax
  800433:	68 c9 38 80 00       	push   $0x8038c9
  800438:	e8 19 07 00 00       	call   800b56 <cprintf>
				exit();
  80043d:	e8 1f 06 00 00       	call   800a61 <exit>
  800442:	83 c4 10             	add    $0x10,%esp
				if (p[1] != 1) {
  800445:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  80044b:	83 f8 01             	cmp    $0x1,%eax
  80044e:	75 58                	jne    8004a8 <runcmd+0x2aa>
				close(p[0]);
  800450:	83 ec 0c             	sub    $0xc,%esp
  800453:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  800459:	e8 e2 19 00 00       	call   801e40 <close>
				goto runit;
  80045e:	83 c4 10             	add    $0x10,%esp
	if(argc == 0) {
  800461:	85 ff                	test   %edi,%edi
  800463:	75 73                	jne    8004d8 <runcmd+0x2da>
		if (debug)
  800465:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80046c:	0f 84 f0 00 00 00    	je     800562 <runcmd+0x364>
			cprintf("EMPTY COMMAND\n");
  800472:	83 ec 0c             	sub    $0xc,%esp
  800475:	68 cb 33 80 00       	push   $0x8033cb
  80047a:	e8 d7 06 00 00       	call   800b56 <cprintf>
  80047f:	83 c4 10             	add    $0x10,%esp
  800482:	e9 db 00 00 00       	jmp    800562 <runcmd+0x364>
					dup(p[0], 0);
  800487:	83 ec 08             	sub    $0x8,%esp
  80048a:	6a 00                	push   $0x0
  80048c:	50                   	push   %eax
  80048d:	e8 fe 19 00 00       	call   801e90 <dup>
					close(p[0]);
  800492:	83 c4 04             	add    $0x4,%esp
  800495:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  80049b:	e8 a0 19 00 00       	call   801e40 <close>
  8004a0:	83 c4 10             	add    $0x10,%esp
  8004a3:	e9 3a fe ff ff       	jmp    8002e2 <runcmd+0xe4>
					dup(p[1], 1);
  8004a8:	83 ec 08             	sub    $0x8,%esp
  8004ab:	6a 01                	push   $0x1
  8004ad:	50                   	push   %eax
  8004ae:	e8 dd 19 00 00       	call   801e90 <dup>
					close(p[1]);
  8004b3:	83 c4 04             	add    $0x4,%esp
  8004b6:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  8004bc:	e8 7f 19 00 00       	call   801e40 <close>
  8004c1:	83 c4 10             	add    $0x10,%esp
  8004c4:	eb 8a                	jmp    800450 <runcmd+0x252>
			panic("bad return %d from gettoken", c);
  8004c6:	53                   	push   %ebx
  8004c7:	68 a5 33 80 00       	push   $0x8033a5
  8004cc:	6a 77                	push   $0x77
  8004ce:	68 c1 33 80 00       	push   $0x8033c1
  8004d3:	e8 a3 05 00 00       	call   800a7b <_panic>
	if (argv[0][0] != '/') {
  8004d8:	8b 45 a8             	mov    -0x58(%ebp),%eax
  8004db:	80 38 2f             	cmpb   $0x2f,(%eax)
  8004de:	0f 85 86 00 00 00    	jne    80056a <runcmd+0x36c>
	argv[argc] = 0;
  8004e4:	c7 44 bd a8 00 00 00 	movl   $0x0,-0x58(%ebp,%edi,4)
  8004eb:	00 
	if (debug) {
  8004ec:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8004f3:	0f 85 99 00 00 00    	jne    800592 <runcmd+0x394>
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
  8004f9:	83 ec 08             	sub    $0x8,%esp
  8004fc:	8d 45 a8             	lea    -0x58(%ebp),%eax
  8004ff:	50                   	push   %eax
  800500:	ff 75 a8             	pushl  -0x58(%ebp)
  800503:	e8 86 20 00 00       	call   80258e <spawn>
  800508:	89 c6                	mov    %eax,%esi
  80050a:	83 c4 10             	add    $0x10,%esp
  80050d:	85 c0                	test   %eax,%eax
  80050f:	0f 88 cb 00 00 00    	js     8005e0 <runcmd+0x3e2>
	close_all();
  800515:	e8 51 19 00 00       	call   801e6b <close_all>
		if (debug)
  80051a:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800521:	0f 85 06 01 00 00    	jne    80062d <runcmd+0x42f>
		wait(r);
  800527:	83 ec 0c             	sub    $0xc,%esp
  80052a:	56                   	push   %esi
  80052b:	e8 8f 29 00 00       	call   802ebf <wait>
		if (debug)
  800530:	83 c4 10             	add    $0x10,%esp
  800533:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80053a:	0f 85 0c 01 00 00    	jne    80064c <runcmd+0x44e>
	if (pipe_child) {
  800540:	85 db                	test   %ebx,%ebx
  800542:	74 19                	je     80055d <runcmd+0x35f>
		wait(pipe_child);
  800544:	83 ec 0c             	sub    $0xc,%esp
  800547:	53                   	push   %ebx
  800548:	e8 72 29 00 00       	call   802ebf <wait>
		if (debug)
  80054d:	83 c4 10             	add    $0x10,%esp
  800550:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800557:	0f 85 0a 01 00 00    	jne    800667 <runcmd+0x469>
	exit();
  80055d:	e8 ff 04 00 00       	call   800a61 <exit>
}
  800562:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800565:	5b                   	pop    %ebx
  800566:	5e                   	pop    %esi
  800567:	5f                   	pop    %edi
  800568:	5d                   	pop    %ebp
  800569:	c3                   	ret    
		argv0buf[0] = '/';
  80056a:	c6 85 a4 fb ff ff 2f 	movb   $0x2f,-0x45c(%ebp)
		strcpy(argv0buf + 1, argv[0]);
  800571:	83 ec 08             	sub    $0x8,%esp
  800574:	50                   	push   %eax
  800575:	8d b5 a4 fb ff ff    	lea    -0x45c(%ebp),%esi
  80057b:	8d 85 a5 fb ff ff    	lea    -0x45b(%ebp),%eax
  800581:	50                   	push   %eax
  800582:	e8 de 0c 00 00       	call   801265 <strcpy>
		argv[0] = argv0buf;
  800587:	89 75 a8             	mov    %esi,-0x58(%ebp)
  80058a:	83 c4 10             	add    $0x10,%esp
  80058d:	e9 52 ff ff ff       	jmp    8004e4 <runcmd+0x2e6>
		cprintf("[%08x] SPAWN:", thisenv->env_id);
  800592:	a1 24 54 80 00       	mov    0x805424,%eax
  800597:	8b 40 48             	mov    0x48(%eax),%eax
  80059a:	83 ec 08             	sub    $0x8,%esp
  80059d:	50                   	push   %eax
  80059e:	68 da 33 80 00       	push   $0x8033da
  8005a3:	e8 ae 05 00 00       	call   800b56 <cprintf>
  8005a8:	8d 75 a8             	lea    -0x58(%ebp),%esi
		for (i = 0; argv[i]; i++)
  8005ab:	83 c4 10             	add    $0x10,%esp
  8005ae:	83 c6 04             	add    $0x4,%esi
  8005b1:	8b 46 fc             	mov    -0x4(%esi),%eax
  8005b4:	85 c0                	test   %eax,%eax
  8005b6:	74 13                	je     8005cb <runcmd+0x3cd>
			cprintf(" %s", argv[i]);
  8005b8:	83 ec 08             	sub    $0x8,%esp
  8005bb:	50                   	push   %eax
  8005bc:	68 62 34 80 00       	push   $0x803462
  8005c1:	e8 90 05 00 00       	call   800b56 <cprintf>
  8005c6:	83 c4 10             	add    $0x10,%esp
  8005c9:	eb e3                	jmp    8005ae <runcmd+0x3b0>
		cprintf("\n");
  8005cb:	83 ec 0c             	sub    $0xc,%esp
  8005ce:	68 40 33 80 00       	push   $0x803340
  8005d3:	e8 7e 05 00 00       	call   800b56 <cprintf>
  8005d8:	83 c4 10             	add    $0x10,%esp
  8005db:	e9 19 ff ff ff       	jmp    8004f9 <runcmd+0x2fb>
		cprintf("spawn %s: %e\n", argv[0], r);
  8005e0:	83 ec 04             	sub    $0x4,%esp
  8005e3:	50                   	push   %eax
  8005e4:	ff 75 a8             	pushl  -0x58(%ebp)
  8005e7:	68 e8 33 80 00       	push   $0x8033e8
  8005ec:	e8 65 05 00 00       	call   800b56 <cprintf>
	close_all();
  8005f1:	e8 75 18 00 00       	call   801e6b <close_all>
  8005f6:	83 c4 10             	add    $0x10,%esp
	if (pipe_child) {
  8005f9:	85 db                	test   %ebx,%ebx
  8005fb:	0f 84 5c ff ff ff    	je     80055d <runcmd+0x35f>
		if (debug)
  800601:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800608:	0f 84 36 ff ff ff    	je     800544 <runcmd+0x346>
			cprintf("[%08x] WAIT pipe_child %08x\n", thisenv->env_id, pipe_child);
  80060e:	a1 24 54 80 00       	mov    0x805424,%eax
  800613:	8b 40 48             	mov    0x48(%eax),%eax
  800616:	83 ec 04             	sub    $0x4,%esp
  800619:	53                   	push   %ebx
  80061a:	50                   	push   %eax
  80061b:	68 21 34 80 00       	push   $0x803421
  800620:	e8 31 05 00 00       	call   800b56 <cprintf>
  800625:	83 c4 10             	add    $0x10,%esp
  800628:	e9 17 ff ff ff       	jmp    800544 <runcmd+0x346>
			cprintf("[%08x] WAIT %s %08x\n", thisenv->env_id, argv[0], r);
  80062d:	a1 24 54 80 00       	mov    0x805424,%eax
  800632:	8b 40 48             	mov    0x48(%eax),%eax
  800635:	56                   	push   %esi
  800636:	ff 75 a8             	pushl  -0x58(%ebp)
  800639:	50                   	push   %eax
  80063a:	68 f6 33 80 00       	push   $0x8033f6
  80063f:	e8 12 05 00 00       	call   800b56 <cprintf>
  800644:	83 c4 10             	add    $0x10,%esp
  800647:	e9 db fe ff ff       	jmp    800527 <runcmd+0x329>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  80064c:	a1 24 54 80 00       	mov    0x805424,%eax
  800651:	8b 40 48             	mov    0x48(%eax),%eax
  800654:	83 ec 08             	sub    $0x8,%esp
  800657:	50                   	push   %eax
  800658:	68 0b 34 80 00       	push   $0x80340b
  80065d:	e8 f4 04 00 00       	call   800b56 <cprintf>
  800662:	83 c4 10             	add    $0x10,%esp
  800665:	eb 92                	jmp    8005f9 <runcmd+0x3fb>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  800667:	a1 24 54 80 00       	mov    0x805424,%eax
  80066c:	8b 40 48             	mov    0x48(%eax),%eax
  80066f:	83 ec 08             	sub    $0x8,%esp
  800672:	50                   	push   %eax
  800673:	68 0b 34 80 00       	push   $0x80340b
  800678:	e8 d9 04 00 00       	call   800b56 <cprintf>
  80067d:	83 c4 10             	add    $0x10,%esp
  800680:	e9 d8 fe ff ff       	jmp    80055d <runcmd+0x35f>

00800685 <usage>:


void
usage(void)
{
  800685:	55                   	push   %ebp
  800686:	89 e5                	mov    %esp,%ebp
  800688:	83 ec 14             	sub    $0x14,%esp
	cprintf("usage: sh [-dix] [command-file]\n");
  80068b:	68 ec 34 80 00       	push   $0x8034ec
  800690:	e8 c1 04 00 00       	call   800b56 <cprintf>
	exit();
  800695:	e8 c7 03 00 00       	call   800a61 <exit>
}
  80069a:	83 c4 10             	add    $0x10,%esp
  80069d:	c9                   	leave  
  80069e:	c3                   	ret    

0080069f <umain>:

void
umain(int argc, char **argv)
{
  80069f:	55                   	push   %ebp
  8006a0:	89 e5                	mov    %esp,%ebp
  8006a2:	57                   	push   %edi
  8006a3:	56                   	push   %esi
  8006a4:	53                   	push   %ebx
  8006a5:	83 ec 30             	sub    $0x30,%esp
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
  8006a8:	8d 45 d8             	lea    -0x28(%ebp),%eax
  8006ab:	50                   	push   %eax
  8006ac:	ff 75 0c             	pushl  0xc(%ebp)
  8006af:	8d 45 08             	lea    0x8(%ebp),%eax
  8006b2:	50                   	push   %eax
  8006b3:	e8 89 14 00 00       	call   801b41 <argstart>
	while ((r = argnext(&args)) >= 0)
  8006b8:	83 c4 10             	add    $0x10,%esp
	echocmds = 0;
  8006bb:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
	interactive = '?';
  8006c2:	bf 3f 00 00 00       	mov    $0x3f,%edi
	while ((r = argnext(&args)) >= 0)
  8006c7:	8d 5d d8             	lea    -0x28(%ebp),%ebx
		switch (r) {
		case 'd':
			debug++;
			break;
		case 'i':
			interactive = 1;
  8006ca:	be 01 00 00 00       	mov    $0x1,%esi
	while ((r = argnext(&args)) >= 0)
  8006cf:	eb 03                	jmp    8006d4 <umain+0x35>
			break;
		case 'x':
			echocmds = 1;
  8006d1:	89 75 d4             	mov    %esi,-0x2c(%ebp)
	while ((r = argnext(&args)) >= 0)
  8006d4:	83 ec 0c             	sub    $0xc,%esp
  8006d7:	53                   	push   %ebx
  8006d8:	e8 94 14 00 00       	call   801b71 <argnext>
  8006dd:	83 c4 10             	add    $0x10,%esp
  8006e0:	85 c0                	test   %eax,%eax
  8006e2:	78 23                	js     800707 <umain+0x68>
		switch (r) {
  8006e4:	83 f8 69             	cmp    $0x69,%eax
  8006e7:	74 1a                	je     800703 <umain+0x64>
  8006e9:	83 f8 78             	cmp    $0x78,%eax
  8006ec:	74 e3                	je     8006d1 <umain+0x32>
  8006ee:	83 f8 64             	cmp    $0x64,%eax
  8006f1:	74 07                	je     8006fa <umain+0x5b>
			break;
		default:
			usage();
  8006f3:	e8 8d ff ff ff       	call   800685 <usage>
  8006f8:	eb da                	jmp    8006d4 <umain+0x35>
			debug++;
  8006fa:	83 05 00 50 80 00 01 	addl   $0x1,0x805000
			break;
  800701:	eb d1                	jmp    8006d4 <umain+0x35>
			interactive = 1;
  800703:	89 f7                	mov    %esi,%edi
  800705:	eb cd                	jmp    8006d4 <umain+0x35>
		}

	if (argc > 2)
  800707:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  80070b:	7f 1f                	jg     80072c <umain+0x8d>
		usage();
	if (argc == 2) {
  80070d:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  800711:	74 20                	je     800733 <umain+0x94>
		close(0);
		if ((r = open(argv[1], O_RDONLY)) < 0)
			panic("open %s: %e", argv[1], r);
		assert(r == 0);
	}
	if (interactive == '?')
  800713:	83 ff 3f             	cmp    $0x3f,%edi
  800716:	74 77                	je     80078f <umain+0xf0>
  800718:	85 ff                	test   %edi,%edi
  80071a:	bf 66 34 80 00       	mov    $0x803466,%edi
  80071f:	b8 00 00 00 00       	mov    $0x0,%eax
  800724:	0f 44 f8             	cmove  %eax,%edi
  800727:	e9 08 01 00 00       	jmp    800834 <umain+0x195>
		usage();
  80072c:	e8 54 ff ff ff       	call   800685 <usage>
  800731:	eb da                	jmp    80070d <umain+0x6e>
		close(0);
  800733:	83 ec 0c             	sub    $0xc,%esp
  800736:	6a 00                	push   $0x0
  800738:	e8 03 17 00 00       	call   801e40 <close>
		if ((r = open(argv[1], O_RDONLY)) < 0)
  80073d:	83 c4 08             	add    $0x8,%esp
  800740:	6a 00                	push   $0x0
  800742:	8b 45 0c             	mov    0xc(%ebp),%eax
  800745:	ff 70 04             	pushl  0x4(%eax)
  800748:	e8 87 1c 00 00       	call   8023d4 <open>
  80074d:	83 c4 10             	add    $0x10,%esp
  800750:	85 c0                	test   %eax,%eax
  800752:	78 1d                	js     800771 <umain+0xd2>
		assert(r == 0);
  800754:	85 c0                	test   %eax,%eax
  800756:	74 bb                	je     800713 <umain+0x74>
  800758:	68 4a 34 80 00       	push   $0x80344a
  80075d:	68 51 34 80 00       	push   $0x803451
  800762:	68 28 01 00 00       	push   $0x128
  800767:	68 c1 33 80 00       	push   $0x8033c1
  80076c:	e8 0a 03 00 00       	call   800a7b <_panic>
			panic("open %s: %e", argv[1], r);
  800771:	83 ec 0c             	sub    $0xc,%esp
  800774:	50                   	push   %eax
  800775:	8b 45 0c             	mov    0xc(%ebp),%eax
  800778:	ff 70 04             	pushl  0x4(%eax)
  80077b:	68 3e 34 80 00       	push   $0x80343e
  800780:	68 27 01 00 00       	push   $0x127
  800785:	68 c1 33 80 00       	push   $0x8033c1
  80078a:	e8 ec 02 00 00       	call   800a7b <_panic>
		interactive = iscons(0);
  80078f:	83 ec 0c             	sub    $0xc,%esp
  800792:	6a 00                	push   $0x0
  800794:	e8 04 02 00 00       	call   80099d <iscons>
  800799:	89 c7                	mov    %eax,%edi
  80079b:	83 c4 10             	add    $0x10,%esp
  80079e:	e9 75 ff ff ff       	jmp    800718 <umain+0x79>
	while (1) {
		char *buf;

		buf = readline(interactive ? "$ " : NULL);
		if (buf == NULL) {
			if (debug)
  8007a3:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007aa:	75 0a                	jne    8007b6 <umain+0x117>
				cprintf("EXITING\n");
			exit();	// end of file
  8007ac:	e8 b0 02 00 00       	call   800a61 <exit>
  8007b1:	e9 94 00 00 00       	jmp    80084a <umain+0x1ab>
				cprintf("EXITING\n");
  8007b6:	83 ec 0c             	sub    $0xc,%esp
  8007b9:	68 69 34 80 00       	push   $0x803469
  8007be:	e8 93 03 00 00       	call   800b56 <cprintf>
  8007c3:	83 c4 10             	add    $0x10,%esp
  8007c6:	eb e4                	jmp    8007ac <umain+0x10d>
		}
		if (debug)
			cprintf("LINE: %s\n", buf);
  8007c8:	83 ec 08             	sub    $0x8,%esp
  8007cb:	53                   	push   %ebx
  8007cc:	68 72 34 80 00       	push   $0x803472
  8007d1:	e8 80 03 00 00       	call   800b56 <cprintf>
  8007d6:	83 c4 10             	add    $0x10,%esp
  8007d9:	eb 7c                	jmp    800857 <umain+0x1b8>
		if (buf[0] == '#')
			continue;
		if (echocmds)
			printf("# %s\n", buf);
  8007db:	83 ec 08             	sub    $0x8,%esp
  8007de:	53                   	push   %ebx
  8007df:	68 7c 34 80 00       	push   $0x80347c
  8007e4:	e8 8f 1d 00 00       	call   802578 <printf>
  8007e9:	83 c4 10             	add    $0x10,%esp
  8007ec:	eb 78                	jmp    800866 <umain+0x1c7>
		if (debug)
			cprintf("BEFORE FORK\n");
  8007ee:	83 ec 0c             	sub    $0xc,%esp
  8007f1:	68 82 34 80 00       	push   $0x803482
  8007f6:	e8 5b 03 00 00       	call   800b56 <cprintf>
  8007fb:	83 c4 10             	add    $0x10,%esp
  8007fe:	eb 73                	jmp    800873 <umain+0x1d4>
		if ((r = fork()) < 0)
			panic("fork: %e", r);
  800800:	50                   	push   %eax
  800801:	68 c9 38 80 00       	push   $0x8038c9
  800806:	68 3f 01 00 00       	push   $0x13f
  80080b:	68 c1 33 80 00       	push   $0x8033c1
  800810:	e8 66 02 00 00       	call   800a7b <_panic>
		if (debug)
			cprintf("FORK: %d\n", r);
  800815:	83 ec 08             	sub    $0x8,%esp
  800818:	50                   	push   %eax
  800819:	68 8f 34 80 00       	push   $0x80348f
  80081e:	e8 33 03 00 00       	call   800b56 <cprintf>
  800823:	83 c4 10             	add    $0x10,%esp
  800826:	eb 5f                	jmp    800887 <umain+0x1e8>
		if (r == 0) {
			runcmd(buf);
			exit();
		} else
			wait(r);
  800828:	83 ec 0c             	sub    $0xc,%esp
  80082b:	56                   	push   %esi
  80082c:	e8 8e 26 00 00       	call   802ebf <wait>
  800831:	83 c4 10             	add    $0x10,%esp
		buf = readline(interactive ? "$ " : NULL);
  800834:	83 ec 0c             	sub    $0xc,%esp
  800837:	57                   	push   %edi
  800838:	e8 01 09 00 00       	call   80113e <readline>
  80083d:	89 c3                	mov    %eax,%ebx
		if (buf == NULL) {
  80083f:	83 c4 10             	add    $0x10,%esp
  800842:	85 c0                	test   %eax,%eax
  800844:	0f 84 59 ff ff ff    	je     8007a3 <umain+0x104>
		if (debug)
  80084a:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800851:	0f 85 71 ff ff ff    	jne    8007c8 <umain+0x129>
		if (buf[0] == '#')
  800857:	80 3b 23             	cmpb   $0x23,(%ebx)
  80085a:	74 d8                	je     800834 <umain+0x195>
		if (echocmds)
  80085c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800860:	0f 85 75 ff ff ff    	jne    8007db <umain+0x13c>
		if (debug)
  800866:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80086d:	0f 85 7b ff ff ff    	jne    8007ee <umain+0x14f>
		if ((r = fork()) < 0)
  800873:	e8 d9 10 00 00       	call   801951 <fork>
  800878:	89 c6                	mov    %eax,%esi
  80087a:	85 c0                	test   %eax,%eax
  80087c:	78 82                	js     800800 <umain+0x161>
		if (debug)
  80087e:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800885:	75 8e                	jne    800815 <umain+0x176>
		if (r == 0) {
  800887:	85 f6                	test   %esi,%esi
  800889:	75 9d                	jne    800828 <umain+0x189>
			runcmd(buf);
  80088b:	83 ec 0c             	sub    $0xc,%esp
  80088e:	53                   	push   %ebx
  80088f:	e8 6a f9 ff ff       	call   8001fe <runcmd>
			exit();
  800894:	e8 c8 01 00 00       	call   800a61 <exit>
  800899:	83 c4 10             	add    $0x10,%esp
  80089c:	eb 96                	jmp    800834 <umain+0x195>

0080089e <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80089e:	55                   	push   %ebp
  80089f:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8008a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a6:	5d                   	pop    %ebp
  8008a7:	c3                   	ret    

008008a8 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8008a8:	55                   	push   %ebp
  8008a9:	89 e5                	mov    %esp,%ebp
  8008ab:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8008ae:	68 0d 35 80 00       	push   $0x80350d
  8008b3:	ff 75 0c             	pushl  0xc(%ebp)
  8008b6:	e8 aa 09 00 00       	call   801265 <strcpy>
	return 0;
}
  8008bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c0:	c9                   	leave  
  8008c1:	c3                   	ret    

008008c2 <devcons_write>:
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	57                   	push   %edi
  8008c6:	56                   	push   %esi
  8008c7:	53                   	push   %ebx
  8008c8:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8008ce:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8008d3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8008d9:	eb 2f                	jmp    80090a <devcons_write+0x48>
		m = n - tot;
  8008db:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8008de:	29 f3                	sub    %esi,%ebx
  8008e0:	83 fb 7f             	cmp    $0x7f,%ebx
  8008e3:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8008e8:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8008eb:	83 ec 04             	sub    $0x4,%esp
  8008ee:	53                   	push   %ebx
  8008ef:	89 f0                	mov    %esi,%eax
  8008f1:	03 45 0c             	add    0xc(%ebp),%eax
  8008f4:	50                   	push   %eax
  8008f5:	57                   	push   %edi
  8008f6:	e8 f8 0a 00 00       	call   8013f3 <memmove>
		sys_cputs(buf, m);
  8008fb:	83 c4 08             	add    $0x8,%esp
  8008fe:	53                   	push   %ebx
  8008ff:	57                   	push   %edi
  800900:	e8 9d 0c 00 00       	call   8015a2 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800905:	01 de                	add    %ebx,%esi
  800907:	83 c4 10             	add    $0x10,%esp
  80090a:	3b 75 10             	cmp    0x10(%ebp),%esi
  80090d:	72 cc                	jb     8008db <devcons_write+0x19>
}
  80090f:	89 f0                	mov    %esi,%eax
  800911:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800914:	5b                   	pop    %ebx
  800915:	5e                   	pop    %esi
  800916:	5f                   	pop    %edi
  800917:	5d                   	pop    %ebp
  800918:	c3                   	ret    

00800919 <devcons_read>:
{
  800919:	55                   	push   %ebp
  80091a:	89 e5                	mov    %esp,%ebp
  80091c:	83 ec 08             	sub    $0x8,%esp
  80091f:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800924:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800928:	75 07                	jne    800931 <devcons_read+0x18>
}
  80092a:	c9                   	leave  
  80092b:	c3                   	ret    
		sys_yield();
  80092c:	e8 0e 0d 00 00       	call   80163f <sys_yield>
	while ((c = sys_cgetc()) == 0)
  800931:	e8 8a 0c 00 00       	call   8015c0 <sys_cgetc>
  800936:	85 c0                	test   %eax,%eax
  800938:	74 f2                	je     80092c <devcons_read+0x13>
	if (c < 0)
  80093a:	85 c0                	test   %eax,%eax
  80093c:	78 ec                	js     80092a <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  80093e:	83 f8 04             	cmp    $0x4,%eax
  800941:	74 0c                	je     80094f <devcons_read+0x36>
	*(char*)vbuf = c;
  800943:	8b 55 0c             	mov    0xc(%ebp),%edx
  800946:	88 02                	mov    %al,(%edx)
	return 1;
  800948:	b8 01 00 00 00       	mov    $0x1,%eax
  80094d:	eb db                	jmp    80092a <devcons_read+0x11>
		return 0;
  80094f:	b8 00 00 00 00       	mov    $0x0,%eax
  800954:	eb d4                	jmp    80092a <devcons_read+0x11>

00800956 <cputchar>:
{
  800956:	55                   	push   %ebp
  800957:	89 e5                	mov    %esp,%ebp
  800959:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80095c:	8b 45 08             	mov    0x8(%ebp),%eax
  80095f:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800962:	6a 01                	push   $0x1
  800964:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800967:	50                   	push   %eax
  800968:	e8 35 0c 00 00       	call   8015a2 <sys_cputs>
}
  80096d:	83 c4 10             	add    $0x10,%esp
  800970:	c9                   	leave  
  800971:	c3                   	ret    

00800972 <getchar>:
{
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
  800975:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800978:	6a 01                	push   $0x1
  80097a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80097d:	50                   	push   %eax
  80097e:	6a 00                	push   $0x0
  800980:	e8 f7 15 00 00       	call   801f7c <read>
	if (r < 0)
  800985:	83 c4 10             	add    $0x10,%esp
  800988:	85 c0                	test   %eax,%eax
  80098a:	78 08                	js     800994 <getchar+0x22>
	if (r < 1)
  80098c:	85 c0                	test   %eax,%eax
  80098e:	7e 06                	jle    800996 <getchar+0x24>
	return c;
  800990:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800994:	c9                   	leave  
  800995:	c3                   	ret    
		return -E_EOF;
  800996:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80099b:	eb f7                	jmp    800994 <getchar+0x22>

0080099d <iscons>:
{
  80099d:	55                   	push   %ebp
  80099e:	89 e5                	mov    %esp,%ebp
  8009a0:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8009a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009a6:	50                   	push   %eax
  8009a7:	ff 75 08             	pushl  0x8(%ebp)
  8009aa:	e8 5c 13 00 00       	call   801d0b <fd_lookup>
  8009af:	83 c4 10             	add    $0x10,%esp
  8009b2:	85 c0                	test   %eax,%eax
  8009b4:	78 11                	js     8009c7 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  8009b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009b9:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8009bf:	39 10                	cmp    %edx,(%eax)
  8009c1:	0f 94 c0             	sete   %al
  8009c4:	0f b6 c0             	movzbl %al,%eax
}
  8009c7:	c9                   	leave  
  8009c8:	c3                   	ret    

008009c9 <opencons>:
{
  8009c9:	55                   	push   %ebp
  8009ca:	89 e5                	mov    %esp,%ebp
  8009cc:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8009cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009d2:	50                   	push   %eax
  8009d3:	e8 e4 12 00 00       	call   801cbc <fd_alloc>
  8009d8:	83 c4 10             	add    $0x10,%esp
  8009db:	85 c0                	test   %eax,%eax
  8009dd:	78 3a                	js     800a19 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8009df:	83 ec 04             	sub    $0x4,%esp
  8009e2:	68 07 04 00 00       	push   $0x407
  8009e7:	ff 75 f4             	pushl  -0xc(%ebp)
  8009ea:	6a 00                	push   $0x0
  8009ec:	e8 6d 0c 00 00       	call   80165e <sys_page_alloc>
  8009f1:	83 c4 10             	add    $0x10,%esp
  8009f4:	85 c0                	test   %eax,%eax
  8009f6:	78 21                	js     800a19 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8009f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009fb:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800a01:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a06:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800a0d:	83 ec 0c             	sub    $0xc,%esp
  800a10:	50                   	push   %eax
  800a11:	e8 7f 12 00 00       	call   801c95 <fd2num>
  800a16:	83 c4 10             	add    $0x10,%esp
}
  800a19:	c9                   	leave  
  800a1a:	c3                   	ret    

00800a1b <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800a1b:	55                   	push   %ebp
  800a1c:	89 e5                	mov    %esp,%ebp
  800a1e:	56                   	push   %esi
  800a1f:	53                   	push   %ebx
  800a20:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a23:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800a26:	e8 f5 0b 00 00       	call   801620 <sys_getenvid>
	thisenv = envs + ENVX(envid); 
  800a2b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800a30:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800a33:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800a38:	a3 24 54 80 00       	mov    %eax,0x805424
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800a3d:	85 db                	test   %ebx,%ebx
  800a3f:	7e 07                	jle    800a48 <libmain+0x2d>
		binaryname = argv[0];
  800a41:	8b 06                	mov    (%esi),%eax
  800a43:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  800a48:	83 ec 08             	sub    $0x8,%esp
  800a4b:	56                   	push   %esi
  800a4c:	53                   	push   %ebx
  800a4d:	e8 4d fc ff ff       	call   80069f <umain>

	// exit gracefully
	exit();
  800a52:	e8 0a 00 00 00       	call   800a61 <exit>
}
  800a57:	83 c4 10             	add    $0x10,%esp
  800a5a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a5d:	5b                   	pop    %ebx
  800a5e:	5e                   	pop    %esi
  800a5f:	5d                   	pop    %ebp
  800a60:	c3                   	ret    

00800a61 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800a61:	55                   	push   %ebp
  800a62:	89 e5                	mov    %esp,%ebp
  800a64:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800a67:	e8 ff 13 00 00       	call   801e6b <close_all>
	sys_env_destroy(0);
  800a6c:	83 ec 0c             	sub    $0xc,%esp
  800a6f:	6a 00                	push   $0x0
  800a71:	e8 69 0b 00 00       	call   8015df <sys_env_destroy>
}
  800a76:	83 c4 10             	add    $0x10,%esp
  800a79:	c9                   	leave  
  800a7a:	c3                   	ret    

00800a7b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800a7b:	55                   	push   %ebp
  800a7c:	89 e5                	mov    %esp,%ebp
  800a7e:	56                   	push   %esi
  800a7f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800a80:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800a83:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  800a89:	e8 92 0b 00 00       	call   801620 <sys_getenvid>
  800a8e:	83 ec 0c             	sub    $0xc,%esp
  800a91:	ff 75 0c             	pushl  0xc(%ebp)
  800a94:	ff 75 08             	pushl  0x8(%ebp)
  800a97:	56                   	push   %esi
  800a98:	50                   	push   %eax
  800a99:	68 24 35 80 00       	push   $0x803524
  800a9e:	e8 b3 00 00 00       	call   800b56 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800aa3:	83 c4 18             	add    $0x18,%esp
  800aa6:	53                   	push   %ebx
  800aa7:	ff 75 10             	pushl  0x10(%ebp)
  800aaa:	e8 56 00 00 00       	call   800b05 <vcprintf>
	cprintf("\n");
  800aaf:	c7 04 24 40 33 80 00 	movl   $0x803340,(%esp)
  800ab6:	e8 9b 00 00 00       	call   800b56 <cprintf>
  800abb:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800abe:	cc                   	int3   
  800abf:	eb fd                	jmp    800abe <_panic+0x43>

00800ac1 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800ac1:	55                   	push   %ebp
  800ac2:	89 e5                	mov    %esp,%ebp
  800ac4:	53                   	push   %ebx
  800ac5:	83 ec 04             	sub    $0x4,%esp
  800ac8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800acb:	8b 13                	mov    (%ebx),%edx
  800acd:	8d 42 01             	lea    0x1(%edx),%eax
  800ad0:	89 03                	mov    %eax,(%ebx)
  800ad2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ad5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800ad9:	3d ff 00 00 00       	cmp    $0xff,%eax
  800ade:	74 09                	je     800ae9 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800ae0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800ae4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ae7:	c9                   	leave  
  800ae8:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800ae9:	83 ec 08             	sub    $0x8,%esp
  800aec:	68 ff 00 00 00       	push   $0xff
  800af1:	8d 43 08             	lea    0x8(%ebx),%eax
  800af4:	50                   	push   %eax
  800af5:	e8 a8 0a 00 00       	call   8015a2 <sys_cputs>
		b->idx = 0;
  800afa:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800b00:	83 c4 10             	add    $0x10,%esp
  800b03:	eb db                	jmp    800ae0 <putch+0x1f>

00800b05 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800b05:	55                   	push   %ebp
  800b06:	89 e5                	mov    %esp,%ebp
  800b08:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800b0e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800b15:	00 00 00 
	b.cnt = 0;
  800b18:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800b1f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800b22:	ff 75 0c             	pushl  0xc(%ebp)
  800b25:	ff 75 08             	pushl  0x8(%ebp)
  800b28:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800b2e:	50                   	push   %eax
  800b2f:	68 c1 0a 80 00       	push   $0x800ac1
  800b34:	e8 1a 01 00 00       	call   800c53 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800b39:	83 c4 08             	add    $0x8,%esp
  800b3c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800b42:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800b48:	50                   	push   %eax
  800b49:	e8 54 0a 00 00       	call   8015a2 <sys_cputs>

	return b.cnt;
}
  800b4e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800b54:	c9                   	leave  
  800b55:	c3                   	ret    

00800b56 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800b5c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800b5f:	50                   	push   %eax
  800b60:	ff 75 08             	pushl  0x8(%ebp)
  800b63:	e8 9d ff ff ff       	call   800b05 <vcprintf>
	va_end(ap);

	return cnt;
}
  800b68:	c9                   	leave  
  800b69:	c3                   	ret    

00800b6a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800b6a:	55                   	push   %ebp
  800b6b:	89 e5                	mov    %esp,%ebp
  800b6d:	57                   	push   %edi
  800b6e:	56                   	push   %esi
  800b6f:	53                   	push   %ebx
  800b70:	83 ec 1c             	sub    $0x1c,%esp
  800b73:	89 c7                	mov    %eax,%edi
  800b75:	89 d6                	mov    %edx,%esi
  800b77:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b7d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b80:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800b83:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b86:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b8b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800b8e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800b91:	39 d3                	cmp    %edx,%ebx
  800b93:	72 05                	jb     800b9a <printnum+0x30>
  800b95:	39 45 10             	cmp    %eax,0x10(%ebp)
  800b98:	77 7a                	ja     800c14 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800b9a:	83 ec 0c             	sub    $0xc,%esp
  800b9d:	ff 75 18             	pushl  0x18(%ebp)
  800ba0:	8b 45 14             	mov    0x14(%ebp),%eax
  800ba3:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800ba6:	53                   	push   %ebx
  800ba7:	ff 75 10             	pushl  0x10(%ebp)
  800baa:	83 ec 08             	sub    $0x8,%esp
  800bad:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bb0:	ff 75 e0             	pushl  -0x20(%ebp)
  800bb3:	ff 75 dc             	pushl  -0x24(%ebp)
  800bb6:	ff 75 d8             	pushl  -0x28(%ebp)
  800bb9:	e8 22 25 00 00       	call   8030e0 <__udivdi3>
  800bbe:	83 c4 18             	add    $0x18,%esp
  800bc1:	52                   	push   %edx
  800bc2:	50                   	push   %eax
  800bc3:	89 f2                	mov    %esi,%edx
  800bc5:	89 f8                	mov    %edi,%eax
  800bc7:	e8 9e ff ff ff       	call   800b6a <printnum>
  800bcc:	83 c4 20             	add    $0x20,%esp
  800bcf:	eb 13                	jmp    800be4 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800bd1:	83 ec 08             	sub    $0x8,%esp
  800bd4:	56                   	push   %esi
  800bd5:	ff 75 18             	pushl  0x18(%ebp)
  800bd8:	ff d7                	call   *%edi
  800bda:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800bdd:	83 eb 01             	sub    $0x1,%ebx
  800be0:	85 db                	test   %ebx,%ebx
  800be2:	7f ed                	jg     800bd1 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800be4:	83 ec 08             	sub    $0x8,%esp
  800be7:	56                   	push   %esi
  800be8:	83 ec 04             	sub    $0x4,%esp
  800beb:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bee:	ff 75 e0             	pushl  -0x20(%ebp)
  800bf1:	ff 75 dc             	pushl  -0x24(%ebp)
  800bf4:	ff 75 d8             	pushl  -0x28(%ebp)
  800bf7:	e8 04 26 00 00       	call   803200 <__umoddi3>
  800bfc:	83 c4 14             	add    $0x14,%esp
  800bff:	0f be 80 47 35 80 00 	movsbl 0x803547(%eax),%eax
  800c06:	50                   	push   %eax
  800c07:	ff d7                	call   *%edi
}
  800c09:	83 c4 10             	add    $0x10,%esp
  800c0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0f:	5b                   	pop    %ebx
  800c10:	5e                   	pop    %esi
  800c11:	5f                   	pop    %edi
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    
  800c14:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800c17:	eb c4                	jmp    800bdd <printnum+0x73>

00800c19 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800c19:	55                   	push   %ebp
  800c1a:	89 e5                	mov    %esp,%ebp
  800c1c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800c1f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800c23:	8b 10                	mov    (%eax),%edx
  800c25:	3b 50 04             	cmp    0x4(%eax),%edx
  800c28:	73 0a                	jae    800c34 <sprintputch+0x1b>
		*b->buf++ = ch;
  800c2a:	8d 4a 01             	lea    0x1(%edx),%ecx
  800c2d:	89 08                	mov    %ecx,(%eax)
  800c2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c32:	88 02                	mov    %al,(%edx)
}
  800c34:	5d                   	pop    %ebp
  800c35:	c3                   	ret    

00800c36 <printfmt>:
{
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800c3c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800c3f:	50                   	push   %eax
  800c40:	ff 75 10             	pushl  0x10(%ebp)
  800c43:	ff 75 0c             	pushl  0xc(%ebp)
  800c46:	ff 75 08             	pushl  0x8(%ebp)
  800c49:	e8 05 00 00 00       	call   800c53 <vprintfmt>
}
  800c4e:	83 c4 10             	add    $0x10,%esp
  800c51:	c9                   	leave  
  800c52:	c3                   	ret    

00800c53 <vprintfmt>:
{
  800c53:	55                   	push   %ebp
  800c54:	89 e5                	mov    %esp,%ebp
  800c56:	57                   	push   %edi
  800c57:	56                   	push   %esi
  800c58:	53                   	push   %ebx
  800c59:	83 ec 2c             	sub    $0x2c,%esp
  800c5c:	8b 75 08             	mov    0x8(%ebp),%esi
  800c5f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c62:	8b 7d 10             	mov    0x10(%ebp),%edi
  800c65:	e9 c1 03 00 00       	jmp    80102b <vprintfmt+0x3d8>
		padc = ' ';
  800c6a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800c6e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800c75:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800c7c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800c83:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800c88:	8d 47 01             	lea    0x1(%edi),%eax
  800c8b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c8e:	0f b6 17             	movzbl (%edi),%edx
  800c91:	8d 42 dd             	lea    -0x23(%edx),%eax
  800c94:	3c 55                	cmp    $0x55,%al
  800c96:	0f 87 12 04 00 00    	ja     8010ae <vprintfmt+0x45b>
  800c9c:	0f b6 c0             	movzbl %al,%eax
  800c9f:	ff 24 85 80 36 80 00 	jmp    *0x803680(,%eax,4)
  800ca6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800ca9:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800cad:	eb d9                	jmp    800c88 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800caf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800cb2:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800cb6:	eb d0                	jmp    800c88 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800cb8:	0f b6 d2             	movzbl %dl,%edx
  800cbb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800cbe:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800cc6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800cc9:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800ccd:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800cd0:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800cd3:	83 f9 09             	cmp    $0x9,%ecx
  800cd6:	77 55                	ja     800d2d <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800cd8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800cdb:	eb e9                	jmp    800cc6 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  800cdd:	8b 45 14             	mov    0x14(%ebp),%eax
  800ce0:	8b 00                	mov    (%eax),%eax
  800ce2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800ce5:	8b 45 14             	mov    0x14(%ebp),%eax
  800ce8:	8d 40 04             	lea    0x4(%eax),%eax
  800ceb:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800cee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800cf1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800cf5:	79 91                	jns    800c88 <vprintfmt+0x35>
				width = precision, precision = -1;
  800cf7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800cfa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800cfd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800d04:	eb 82                	jmp    800c88 <vprintfmt+0x35>
  800d06:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800d09:	85 c0                	test   %eax,%eax
  800d0b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d10:	0f 49 d0             	cmovns %eax,%edx
  800d13:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800d16:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800d19:	e9 6a ff ff ff       	jmp    800c88 <vprintfmt+0x35>
  800d1e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800d21:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800d28:	e9 5b ff ff ff       	jmp    800c88 <vprintfmt+0x35>
  800d2d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800d30:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800d33:	eb bc                	jmp    800cf1 <vprintfmt+0x9e>
			lflag++;
  800d35:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800d38:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800d3b:	e9 48 ff ff ff       	jmp    800c88 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  800d40:	8b 45 14             	mov    0x14(%ebp),%eax
  800d43:	8d 78 04             	lea    0x4(%eax),%edi
  800d46:	83 ec 08             	sub    $0x8,%esp
  800d49:	53                   	push   %ebx
  800d4a:	ff 30                	pushl  (%eax)
  800d4c:	ff d6                	call   *%esi
			break;
  800d4e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800d51:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800d54:	e9 cf 02 00 00       	jmp    801028 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  800d59:	8b 45 14             	mov    0x14(%ebp),%eax
  800d5c:	8d 78 04             	lea    0x4(%eax),%edi
  800d5f:	8b 00                	mov    (%eax),%eax
  800d61:	99                   	cltd   
  800d62:	31 d0                	xor    %edx,%eax
  800d64:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800d66:	83 f8 0f             	cmp    $0xf,%eax
  800d69:	7f 23                	jg     800d8e <vprintfmt+0x13b>
  800d6b:	8b 14 85 e0 37 80 00 	mov    0x8037e0(,%eax,4),%edx
  800d72:	85 d2                	test   %edx,%edx
  800d74:	74 18                	je     800d8e <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800d76:	52                   	push   %edx
  800d77:	68 63 34 80 00       	push   $0x803463
  800d7c:	53                   	push   %ebx
  800d7d:	56                   	push   %esi
  800d7e:	e8 b3 fe ff ff       	call   800c36 <printfmt>
  800d83:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800d86:	89 7d 14             	mov    %edi,0x14(%ebp)
  800d89:	e9 9a 02 00 00       	jmp    801028 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  800d8e:	50                   	push   %eax
  800d8f:	68 5f 35 80 00       	push   $0x80355f
  800d94:	53                   	push   %ebx
  800d95:	56                   	push   %esi
  800d96:	e8 9b fe ff ff       	call   800c36 <printfmt>
  800d9b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800d9e:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800da1:	e9 82 02 00 00       	jmp    801028 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  800da6:	8b 45 14             	mov    0x14(%ebp),%eax
  800da9:	83 c0 04             	add    $0x4,%eax
  800dac:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800daf:	8b 45 14             	mov    0x14(%ebp),%eax
  800db2:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800db4:	85 ff                	test   %edi,%edi
  800db6:	b8 58 35 80 00       	mov    $0x803558,%eax
  800dbb:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800dbe:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800dc2:	0f 8e bd 00 00 00    	jle    800e85 <vprintfmt+0x232>
  800dc8:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800dcc:	75 0e                	jne    800ddc <vprintfmt+0x189>
  800dce:	89 75 08             	mov    %esi,0x8(%ebp)
  800dd1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800dd4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800dd7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800dda:	eb 6d                	jmp    800e49 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  800ddc:	83 ec 08             	sub    $0x8,%esp
  800ddf:	ff 75 d0             	pushl  -0x30(%ebp)
  800de2:	57                   	push   %edi
  800de3:	e8 5e 04 00 00       	call   801246 <strnlen>
  800de8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800deb:	29 c1                	sub    %eax,%ecx
  800ded:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800df0:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800df3:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800df7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800dfa:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800dfd:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800dff:	eb 0f                	jmp    800e10 <vprintfmt+0x1bd>
					putch(padc, putdat);
  800e01:	83 ec 08             	sub    $0x8,%esp
  800e04:	53                   	push   %ebx
  800e05:	ff 75 e0             	pushl  -0x20(%ebp)
  800e08:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800e0a:	83 ef 01             	sub    $0x1,%edi
  800e0d:	83 c4 10             	add    $0x10,%esp
  800e10:	85 ff                	test   %edi,%edi
  800e12:	7f ed                	jg     800e01 <vprintfmt+0x1ae>
  800e14:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800e17:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800e1a:	85 c9                	test   %ecx,%ecx
  800e1c:	b8 00 00 00 00       	mov    $0x0,%eax
  800e21:	0f 49 c1             	cmovns %ecx,%eax
  800e24:	29 c1                	sub    %eax,%ecx
  800e26:	89 75 08             	mov    %esi,0x8(%ebp)
  800e29:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e2c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e2f:	89 cb                	mov    %ecx,%ebx
  800e31:	eb 16                	jmp    800e49 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  800e33:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800e37:	75 31                	jne    800e6a <vprintfmt+0x217>
					putch(ch, putdat);
  800e39:	83 ec 08             	sub    $0x8,%esp
  800e3c:	ff 75 0c             	pushl  0xc(%ebp)
  800e3f:	50                   	push   %eax
  800e40:	ff 55 08             	call   *0x8(%ebp)
  800e43:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e46:	83 eb 01             	sub    $0x1,%ebx
  800e49:	83 c7 01             	add    $0x1,%edi
  800e4c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800e50:	0f be c2             	movsbl %dl,%eax
  800e53:	85 c0                	test   %eax,%eax
  800e55:	74 59                	je     800eb0 <vprintfmt+0x25d>
  800e57:	85 f6                	test   %esi,%esi
  800e59:	78 d8                	js     800e33 <vprintfmt+0x1e0>
  800e5b:	83 ee 01             	sub    $0x1,%esi
  800e5e:	79 d3                	jns    800e33 <vprintfmt+0x1e0>
  800e60:	89 df                	mov    %ebx,%edi
  800e62:	8b 75 08             	mov    0x8(%ebp),%esi
  800e65:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e68:	eb 37                	jmp    800ea1 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  800e6a:	0f be d2             	movsbl %dl,%edx
  800e6d:	83 ea 20             	sub    $0x20,%edx
  800e70:	83 fa 5e             	cmp    $0x5e,%edx
  800e73:	76 c4                	jbe    800e39 <vprintfmt+0x1e6>
					putch('?', putdat);
  800e75:	83 ec 08             	sub    $0x8,%esp
  800e78:	ff 75 0c             	pushl  0xc(%ebp)
  800e7b:	6a 3f                	push   $0x3f
  800e7d:	ff 55 08             	call   *0x8(%ebp)
  800e80:	83 c4 10             	add    $0x10,%esp
  800e83:	eb c1                	jmp    800e46 <vprintfmt+0x1f3>
  800e85:	89 75 08             	mov    %esi,0x8(%ebp)
  800e88:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e8b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e8e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800e91:	eb b6                	jmp    800e49 <vprintfmt+0x1f6>
				putch(' ', putdat);
  800e93:	83 ec 08             	sub    $0x8,%esp
  800e96:	53                   	push   %ebx
  800e97:	6a 20                	push   $0x20
  800e99:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800e9b:	83 ef 01             	sub    $0x1,%edi
  800e9e:	83 c4 10             	add    $0x10,%esp
  800ea1:	85 ff                	test   %edi,%edi
  800ea3:	7f ee                	jg     800e93 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800ea5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800ea8:	89 45 14             	mov    %eax,0x14(%ebp)
  800eab:	e9 78 01 00 00       	jmp    801028 <vprintfmt+0x3d5>
  800eb0:	89 df                	mov    %ebx,%edi
  800eb2:	8b 75 08             	mov    0x8(%ebp),%esi
  800eb5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800eb8:	eb e7                	jmp    800ea1 <vprintfmt+0x24e>
	if (lflag >= 2)
  800eba:	83 f9 01             	cmp    $0x1,%ecx
  800ebd:	7e 3f                	jle    800efe <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800ebf:	8b 45 14             	mov    0x14(%ebp),%eax
  800ec2:	8b 50 04             	mov    0x4(%eax),%edx
  800ec5:	8b 00                	mov    (%eax),%eax
  800ec7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800eca:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800ecd:	8b 45 14             	mov    0x14(%ebp),%eax
  800ed0:	8d 40 08             	lea    0x8(%eax),%eax
  800ed3:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800ed6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800eda:	79 5c                	jns    800f38 <vprintfmt+0x2e5>
				putch('-', putdat);
  800edc:	83 ec 08             	sub    $0x8,%esp
  800edf:	53                   	push   %ebx
  800ee0:	6a 2d                	push   $0x2d
  800ee2:	ff d6                	call   *%esi
				num = -(long long) num;
  800ee4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800ee7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800eea:	f7 da                	neg    %edx
  800eec:	83 d1 00             	adc    $0x0,%ecx
  800eef:	f7 d9                	neg    %ecx
  800ef1:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800ef4:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ef9:	e9 10 01 00 00       	jmp    80100e <vprintfmt+0x3bb>
	else if (lflag)
  800efe:	85 c9                	test   %ecx,%ecx
  800f00:	75 1b                	jne    800f1d <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800f02:	8b 45 14             	mov    0x14(%ebp),%eax
  800f05:	8b 00                	mov    (%eax),%eax
  800f07:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800f0a:	89 c1                	mov    %eax,%ecx
  800f0c:	c1 f9 1f             	sar    $0x1f,%ecx
  800f0f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800f12:	8b 45 14             	mov    0x14(%ebp),%eax
  800f15:	8d 40 04             	lea    0x4(%eax),%eax
  800f18:	89 45 14             	mov    %eax,0x14(%ebp)
  800f1b:	eb b9                	jmp    800ed6 <vprintfmt+0x283>
		return va_arg(*ap, long);
  800f1d:	8b 45 14             	mov    0x14(%ebp),%eax
  800f20:	8b 00                	mov    (%eax),%eax
  800f22:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800f25:	89 c1                	mov    %eax,%ecx
  800f27:	c1 f9 1f             	sar    $0x1f,%ecx
  800f2a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800f2d:	8b 45 14             	mov    0x14(%ebp),%eax
  800f30:	8d 40 04             	lea    0x4(%eax),%eax
  800f33:	89 45 14             	mov    %eax,0x14(%ebp)
  800f36:	eb 9e                	jmp    800ed6 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  800f38:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800f3b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800f3e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f43:	e9 c6 00 00 00       	jmp    80100e <vprintfmt+0x3bb>
	if (lflag >= 2)
  800f48:	83 f9 01             	cmp    $0x1,%ecx
  800f4b:	7e 18                	jle    800f65 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  800f4d:	8b 45 14             	mov    0x14(%ebp),%eax
  800f50:	8b 10                	mov    (%eax),%edx
  800f52:	8b 48 04             	mov    0x4(%eax),%ecx
  800f55:	8d 40 08             	lea    0x8(%eax),%eax
  800f58:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800f5b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f60:	e9 a9 00 00 00       	jmp    80100e <vprintfmt+0x3bb>
	else if (lflag)
  800f65:	85 c9                	test   %ecx,%ecx
  800f67:	75 1a                	jne    800f83 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  800f69:	8b 45 14             	mov    0x14(%ebp),%eax
  800f6c:	8b 10                	mov    (%eax),%edx
  800f6e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f73:	8d 40 04             	lea    0x4(%eax),%eax
  800f76:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800f79:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f7e:	e9 8b 00 00 00       	jmp    80100e <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800f83:	8b 45 14             	mov    0x14(%ebp),%eax
  800f86:	8b 10                	mov    (%eax),%edx
  800f88:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f8d:	8d 40 04             	lea    0x4(%eax),%eax
  800f90:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800f93:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f98:	eb 74                	jmp    80100e <vprintfmt+0x3bb>
	if (lflag >= 2)
  800f9a:	83 f9 01             	cmp    $0x1,%ecx
  800f9d:	7e 15                	jle    800fb4 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  800f9f:	8b 45 14             	mov    0x14(%ebp),%eax
  800fa2:	8b 10                	mov    (%eax),%edx
  800fa4:	8b 48 04             	mov    0x4(%eax),%ecx
  800fa7:	8d 40 08             	lea    0x8(%eax),%eax
  800faa:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800fad:	b8 08 00 00 00       	mov    $0x8,%eax
  800fb2:	eb 5a                	jmp    80100e <vprintfmt+0x3bb>
	else if (lflag)
  800fb4:	85 c9                	test   %ecx,%ecx
  800fb6:	75 17                	jne    800fcf <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  800fb8:	8b 45 14             	mov    0x14(%ebp),%eax
  800fbb:	8b 10                	mov    (%eax),%edx
  800fbd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fc2:	8d 40 04             	lea    0x4(%eax),%eax
  800fc5:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800fc8:	b8 08 00 00 00       	mov    $0x8,%eax
  800fcd:	eb 3f                	jmp    80100e <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800fcf:	8b 45 14             	mov    0x14(%ebp),%eax
  800fd2:	8b 10                	mov    (%eax),%edx
  800fd4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fd9:	8d 40 04             	lea    0x4(%eax),%eax
  800fdc:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800fdf:	b8 08 00 00 00       	mov    $0x8,%eax
  800fe4:	eb 28                	jmp    80100e <vprintfmt+0x3bb>
			putch('0', putdat);
  800fe6:	83 ec 08             	sub    $0x8,%esp
  800fe9:	53                   	push   %ebx
  800fea:	6a 30                	push   $0x30
  800fec:	ff d6                	call   *%esi
			putch('x', putdat);
  800fee:	83 c4 08             	add    $0x8,%esp
  800ff1:	53                   	push   %ebx
  800ff2:	6a 78                	push   $0x78
  800ff4:	ff d6                	call   *%esi
			num = (unsigned long long)
  800ff6:	8b 45 14             	mov    0x14(%ebp),%eax
  800ff9:	8b 10                	mov    (%eax),%edx
  800ffb:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801000:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801003:	8d 40 04             	lea    0x4(%eax),%eax
  801006:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801009:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80100e:	83 ec 0c             	sub    $0xc,%esp
  801011:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801015:	57                   	push   %edi
  801016:	ff 75 e0             	pushl  -0x20(%ebp)
  801019:	50                   	push   %eax
  80101a:	51                   	push   %ecx
  80101b:	52                   	push   %edx
  80101c:	89 da                	mov    %ebx,%edx
  80101e:	89 f0                	mov    %esi,%eax
  801020:	e8 45 fb ff ff       	call   800b6a <printnum>
			break;
  801025:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  801028:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80102b:	83 c7 01             	add    $0x1,%edi
  80102e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801032:	83 f8 25             	cmp    $0x25,%eax
  801035:	0f 84 2f fc ff ff    	je     800c6a <vprintfmt+0x17>
			if (ch == '\0')
  80103b:	85 c0                	test   %eax,%eax
  80103d:	0f 84 8b 00 00 00    	je     8010ce <vprintfmt+0x47b>
			putch(ch, putdat);
  801043:	83 ec 08             	sub    $0x8,%esp
  801046:	53                   	push   %ebx
  801047:	50                   	push   %eax
  801048:	ff d6                	call   *%esi
  80104a:	83 c4 10             	add    $0x10,%esp
  80104d:	eb dc                	jmp    80102b <vprintfmt+0x3d8>
	if (lflag >= 2)
  80104f:	83 f9 01             	cmp    $0x1,%ecx
  801052:	7e 15                	jle    801069 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  801054:	8b 45 14             	mov    0x14(%ebp),%eax
  801057:	8b 10                	mov    (%eax),%edx
  801059:	8b 48 04             	mov    0x4(%eax),%ecx
  80105c:	8d 40 08             	lea    0x8(%eax),%eax
  80105f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801062:	b8 10 00 00 00       	mov    $0x10,%eax
  801067:	eb a5                	jmp    80100e <vprintfmt+0x3bb>
	else if (lflag)
  801069:	85 c9                	test   %ecx,%ecx
  80106b:	75 17                	jne    801084 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  80106d:	8b 45 14             	mov    0x14(%ebp),%eax
  801070:	8b 10                	mov    (%eax),%edx
  801072:	b9 00 00 00 00       	mov    $0x0,%ecx
  801077:	8d 40 04             	lea    0x4(%eax),%eax
  80107a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80107d:	b8 10 00 00 00       	mov    $0x10,%eax
  801082:	eb 8a                	jmp    80100e <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  801084:	8b 45 14             	mov    0x14(%ebp),%eax
  801087:	8b 10                	mov    (%eax),%edx
  801089:	b9 00 00 00 00       	mov    $0x0,%ecx
  80108e:	8d 40 04             	lea    0x4(%eax),%eax
  801091:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801094:	b8 10 00 00 00       	mov    $0x10,%eax
  801099:	e9 70 ff ff ff       	jmp    80100e <vprintfmt+0x3bb>
			putch(ch, putdat);
  80109e:	83 ec 08             	sub    $0x8,%esp
  8010a1:	53                   	push   %ebx
  8010a2:	6a 25                	push   $0x25
  8010a4:	ff d6                	call   *%esi
			break;
  8010a6:	83 c4 10             	add    $0x10,%esp
  8010a9:	e9 7a ff ff ff       	jmp    801028 <vprintfmt+0x3d5>
			putch('%', putdat);
  8010ae:	83 ec 08             	sub    $0x8,%esp
  8010b1:	53                   	push   %ebx
  8010b2:	6a 25                	push   $0x25
  8010b4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8010b6:	83 c4 10             	add    $0x10,%esp
  8010b9:	89 f8                	mov    %edi,%eax
  8010bb:	eb 03                	jmp    8010c0 <vprintfmt+0x46d>
  8010bd:	83 e8 01             	sub    $0x1,%eax
  8010c0:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8010c4:	75 f7                	jne    8010bd <vprintfmt+0x46a>
  8010c6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010c9:	e9 5a ff ff ff       	jmp    801028 <vprintfmt+0x3d5>
}
  8010ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d1:	5b                   	pop    %ebx
  8010d2:	5e                   	pop    %esi
  8010d3:	5f                   	pop    %edi
  8010d4:	5d                   	pop    %ebp
  8010d5:	c3                   	ret    

008010d6 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8010d6:	55                   	push   %ebp
  8010d7:	89 e5                	mov    %esp,%ebp
  8010d9:	83 ec 18             	sub    $0x18,%esp
  8010dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8010df:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8010e2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8010e5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8010e9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8010ec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8010f3:	85 c0                	test   %eax,%eax
  8010f5:	74 26                	je     80111d <vsnprintf+0x47>
  8010f7:	85 d2                	test   %edx,%edx
  8010f9:	7e 22                	jle    80111d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8010fb:	ff 75 14             	pushl  0x14(%ebp)
  8010fe:	ff 75 10             	pushl  0x10(%ebp)
  801101:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801104:	50                   	push   %eax
  801105:	68 19 0c 80 00       	push   $0x800c19
  80110a:	e8 44 fb ff ff       	call   800c53 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80110f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801112:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801115:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801118:	83 c4 10             	add    $0x10,%esp
}
  80111b:	c9                   	leave  
  80111c:	c3                   	ret    
		return -E_INVAL;
  80111d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801122:	eb f7                	jmp    80111b <vsnprintf+0x45>

00801124 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801124:	55                   	push   %ebp
  801125:	89 e5                	mov    %esp,%ebp
  801127:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80112a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80112d:	50                   	push   %eax
  80112e:	ff 75 10             	pushl  0x10(%ebp)
  801131:	ff 75 0c             	pushl  0xc(%ebp)
  801134:	ff 75 08             	pushl  0x8(%ebp)
  801137:	e8 9a ff ff ff       	call   8010d6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80113c:	c9                   	leave  
  80113d:	c3                   	ret    

0080113e <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  80113e:	55                   	push   %ebp
  80113f:	89 e5                	mov    %esp,%ebp
  801141:	57                   	push   %edi
  801142:	56                   	push   %esi
  801143:	53                   	push   %ebx
  801144:	83 ec 0c             	sub    $0xc,%esp
  801147:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  80114a:	85 c0                	test   %eax,%eax
  80114c:	74 13                	je     801161 <readline+0x23>
		fprintf(1, "%s", prompt);
  80114e:	83 ec 04             	sub    $0x4,%esp
  801151:	50                   	push   %eax
  801152:	68 63 34 80 00       	push   $0x803463
  801157:	6a 01                	push   $0x1
  801159:	e8 03 14 00 00       	call   802561 <fprintf>
  80115e:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  801161:	83 ec 0c             	sub    $0xc,%esp
  801164:	6a 00                	push   $0x0
  801166:	e8 32 f8 ff ff       	call   80099d <iscons>
  80116b:	89 c7                	mov    %eax,%edi
  80116d:	83 c4 10             	add    $0x10,%esp
	i = 0;
  801170:	be 00 00 00 00       	mov    $0x0,%esi
  801175:	eb 4b                	jmp    8011c2 <readline+0x84>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  801177:	b8 00 00 00 00       	mov    $0x0,%eax
			if (c != -E_EOF)
  80117c:	83 fb f8             	cmp    $0xfffffff8,%ebx
  80117f:	75 08                	jne    801189 <readline+0x4b>
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
  801181:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801184:	5b                   	pop    %ebx
  801185:	5e                   	pop    %esi
  801186:	5f                   	pop    %edi
  801187:	5d                   	pop    %ebp
  801188:	c3                   	ret    
				cprintf("read error: %e\n", c);
  801189:	83 ec 08             	sub    $0x8,%esp
  80118c:	53                   	push   %ebx
  80118d:	68 3f 38 80 00       	push   $0x80383f
  801192:	e8 bf f9 ff ff       	call   800b56 <cprintf>
  801197:	83 c4 10             	add    $0x10,%esp
			return NULL;
  80119a:	b8 00 00 00 00       	mov    $0x0,%eax
  80119f:	eb e0                	jmp    801181 <readline+0x43>
			if (echoing)
  8011a1:	85 ff                	test   %edi,%edi
  8011a3:	75 05                	jne    8011aa <readline+0x6c>
			i--;
  8011a5:	83 ee 01             	sub    $0x1,%esi
  8011a8:	eb 18                	jmp    8011c2 <readline+0x84>
				cputchar('\b');
  8011aa:	83 ec 0c             	sub    $0xc,%esp
  8011ad:	6a 08                	push   $0x8
  8011af:	e8 a2 f7 ff ff       	call   800956 <cputchar>
  8011b4:	83 c4 10             	add    $0x10,%esp
  8011b7:	eb ec                	jmp    8011a5 <readline+0x67>
			buf[i++] = c;
  8011b9:	88 9e 20 50 80 00    	mov    %bl,0x805020(%esi)
  8011bf:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
  8011c2:	e8 ab f7 ff ff       	call   800972 <getchar>
  8011c7:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  8011c9:	85 c0                	test   %eax,%eax
  8011cb:	78 aa                	js     801177 <readline+0x39>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  8011cd:	83 f8 08             	cmp    $0x8,%eax
  8011d0:	0f 94 c2             	sete   %dl
  8011d3:	83 f8 7f             	cmp    $0x7f,%eax
  8011d6:	0f 94 c0             	sete   %al
  8011d9:	08 c2                	or     %al,%dl
  8011db:	74 04                	je     8011e1 <readline+0xa3>
  8011dd:	85 f6                	test   %esi,%esi
  8011df:	7f c0                	jg     8011a1 <readline+0x63>
		} else if (c >= ' ' && i < BUFLEN-1) {
  8011e1:	83 fb 1f             	cmp    $0x1f,%ebx
  8011e4:	7e 1a                	jle    801200 <readline+0xc2>
  8011e6:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  8011ec:	7f 12                	jg     801200 <readline+0xc2>
			if (echoing)
  8011ee:	85 ff                	test   %edi,%edi
  8011f0:	74 c7                	je     8011b9 <readline+0x7b>
				cputchar(c);
  8011f2:	83 ec 0c             	sub    $0xc,%esp
  8011f5:	53                   	push   %ebx
  8011f6:	e8 5b f7 ff ff       	call   800956 <cputchar>
  8011fb:	83 c4 10             	add    $0x10,%esp
  8011fe:	eb b9                	jmp    8011b9 <readline+0x7b>
		} else if (c == '\n' || c == '\r') {
  801200:	83 fb 0a             	cmp    $0xa,%ebx
  801203:	74 05                	je     80120a <readline+0xcc>
  801205:	83 fb 0d             	cmp    $0xd,%ebx
  801208:	75 b8                	jne    8011c2 <readline+0x84>
			if (echoing)
  80120a:	85 ff                	test   %edi,%edi
  80120c:	75 11                	jne    80121f <readline+0xe1>
			buf[i] = 0;
  80120e:	c6 86 20 50 80 00 00 	movb   $0x0,0x805020(%esi)
			return buf;
  801215:	b8 20 50 80 00       	mov    $0x805020,%eax
  80121a:	e9 62 ff ff ff       	jmp    801181 <readline+0x43>
				cputchar('\n');
  80121f:	83 ec 0c             	sub    $0xc,%esp
  801222:	6a 0a                	push   $0xa
  801224:	e8 2d f7 ff ff       	call   800956 <cputchar>
  801229:	83 c4 10             	add    $0x10,%esp
  80122c:	eb e0                	jmp    80120e <readline+0xd0>

0080122e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80122e:	55                   	push   %ebp
  80122f:	89 e5                	mov    %esp,%ebp
  801231:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801234:	b8 00 00 00 00       	mov    $0x0,%eax
  801239:	eb 03                	jmp    80123e <strlen+0x10>
		n++;
  80123b:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80123e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801242:	75 f7                	jne    80123b <strlen+0xd>
	return n;
}
  801244:	5d                   	pop    %ebp
  801245:	c3                   	ret    

00801246 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801246:	55                   	push   %ebp
  801247:	89 e5                	mov    %esp,%ebp
  801249:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80124c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80124f:	b8 00 00 00 00       	mov    $0x0,%eax
  801254:	eb 03                	jmp    801259 <strnlen+0x13>
		n++;
  801256:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801259:	39 d0                	cmp    %edx,%eax
  80125b:	74 06                	je     801263 <strnlen+0x1d>
  80125d:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801261:	75 f3                	jne    801256 <strnlen+0x10>
	return n;
}
  801263:	5d                   	pop    %ebp
  801264:	c3                   	ret    

00801265 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801265:	55                   	push   %ebp
  801266:	89 e5                	mov    %esp,%ebp
  801268:	53                   	push   %ebx
  801269:	8b 45 08             	mov    0x8(%ebp),%eax
  80126c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80126f:	89 c2                	mov    %eax,%edx
  801271:	83 c1 01             	add    $0x1,%ecx
  801274:	83 c2 01             	add    $0x1,%edx
  801277:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80127b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80127e:	84 db                	test   %bl,%bl
  801280:	75 ef                	jne    801271 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801282:	5b                   	pop    %ebx
  801283:	5d                   	pop    %ebp
  801284:	c3                   	ret    

00801285 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801285:	55                   	push   %ebp
  801286:	89 e5                	mov    %esp,%ebp
  801288:	53                   	push   %ebx
  801289:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80128c:	53                   	push   %ebx
  80128d:	e8 9c ff ff ff       	call   80122e <strlen>
  801292:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801295:	ff 75 0c             	pushl  0xc(%ebp)
  801298:	01 d8                	add    %ebx,%eax
  80129a:	50                   	push   %eax
  80129b:	e8 c5 ff ff ff       	call   801265 <strcpy>
	return dst;
}
  8012a0:	89 d8                	mov    %ebx,%eax
  8012a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a5:	c9                   	leave  
  8012a6:	c3                   	ret    

008012a7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8012a7:	55                   	push   %ebp
  8012a8:	89 e5                	mov    %esp,%ebp
  8012aa:	56                   	push   %esi
  8012ab:	53                   	push   %ebx
  8012ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8012af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012b2:	89 f3                	mov    %esi,%ebx
  8012b4:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8012b7:	89 f2                	mov    %esi,%edx
  8012b9:	eb 0f                	jmp    8012ca <strncpy+0x23>
		*dst++ = *src;
  8012bb:	83 c2 01             	add    $0x1,%edx
  8012be:	0f b6 01             	movzbl (%ecx),%eax
  8012c1:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8012c4:	80 39 01             	cmpb   $0x1,(%ecx)
  8012c7:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8012ca:	39 da                	cmp    %ebx,%edx
  8012cc:	75 ed                	jne    8012bb <strncpy+0x14>
	}
	return ret;
}
  8012ce:	89 f0                	mov    %esi,%eax
  8012d0:	5b                   	pop    %ebx
  8012d1:	5e                   	pop    %esi
  8012d2:	5d                   	pop    %ebp
  8012d3:	c3                   	ret    

008012d4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8012d4:	55                   	push   %ebp
  8012d5:	89 e5                	mov    %esp,%ebp
  8012d7:	56                   	push   %esi
  8012d8:	53                   	push   %ebx
  8012d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8012dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012df:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8012e2:	89 f0                	mov    %esi,%eax
  8012e4:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8012e8:	85 c9                	test   %ecx,%ecx
  8012ea:	75 0b                	jne    8012f7 <strlcpy+0x23>
  8012ec:	eb 17                	jmp    801305 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8012ee:	83 c2 01             	add    $0x1,%edx
  8012f1:	83 c0 01             	add    $0x1,%eax
  8012f4:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8012f7:	39 d8                	cmp    %ebx,%eax
  8012f9:	74 07                	je     801302 <strlcpy+0x2e>
  8012fb:	0f b6 0a             	movzbl (%edx),%ecx
  8012fe:	84 c9                	test   %cl,%cl
  801300:	75 ec                	jne    8012ee <strlcpy+0x1a>
		*dst = '\0';
  801302:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801305:	29 f0                	sub    %esi,%eax
}
  801307:	5b                   	pop    %ebx
  801308:	5e                   	pop    %esi
  801309:	5d                   	pop    %ebp
  80130a:	c3                   	ret    

0080130b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80130b:	55                   	push   %ebp
  80130c:	89 e5                	mov    %esp,%ebp
  80130e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801311:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801314:	eb 06                	jmp    80131c <strcmp+0x11>
		p++, q++;
  801316:	83 c1 01             	add    $0x1,%ecx
  801319:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80131c:	0f b6 01             	movzbl (%ecx),%eax
  80131f:	84 c0                	test   %al,%al
  801321:	74 04                	je     801327 <strcmp+0x1c>
  801323:	3a 02                	cmp    (%edx),%al
  801325:	74 ef                	je     801316 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801327:	0f b6 c0             	movzbl %al,%eax
  80132a:	0f b6 12             	movzbl (%edx),%edx
  80132d:	29 d0                	sub    %edx,%eax
}
  80132f:	5d                   	pop    %ebp
  801330:	c3                   	ret    

00801331 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801331:	55                   	push   %ebp
  801332:	89 e5                	mov    %esp,%ebp
  801334:	53                   	push   %ebx
  801335:	8b 45 08             	mov    0x8(%ebp),%eax
  801338:	8b 55 0c             	mov    0xc(%ebp),%edx
  80133b:	89 c3                	mov    %eax,%ebx
  80133d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801340:	eb 06                	jmp    801348 <strncmp+0x17>
		n--, p++, q++;
  801342:	83 c0 01             	add    $0x1,%eax
  801345:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  801348:	39 d8                	cmp    %ebx,%eax
  80134a:	74 16                	je     801362 <strncmp+0x31>
  80134c:	0f b6 08             	movzbl (%eax),%ecx
  80134f:	84 c9                	test   %cl,%cl
  801351:	74 04                	je     801357 <strncmp+0x26>
  801353:	3a 0a                	cmp    (%edx),%cl
  801355:	74 eb                	je     801342 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801357:	0f b6 00             	movzbl (%eax),%eax
  80135a:	0f b6 12             	movzbl (%edx),%edx
  80135d:	29 d0                	sub    %edx,%eax
}
  80135f:	5b                   	pop    %ebx
  801360:	5d                   	pop    %ebp
  801361:	c3                   	ret    
		return 0;
  801362:	b8 00 00 00 00       	mov    $0x0,%eax
  801367:	eb f6                	jmp    80135f <strncmp+0x2e>

00801369 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801369:	55                   	push   %ebp
  80136a:	89 e5                	mov    %esp,%ebp
  80136c:	8b 45 08             	mov    0x8(%ebp),%eax
  80136f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801373:	0f b6 10             	movzbl (%eax),%edx
  801376:	84 d2                	test   %dl,%dl
  801378:	74 09                	je     801383 <strchr+0x1a>
		if (*s == c)
  80137a:	38 ca                	cmp    %cl,%dl
  80137c:	74 0a                	je     801388 <strchr+0x1f>
	for (; *s; s++)
  80137e:	83 c0 01             	add    $0x1,%eax
  801381:	eb f0                	jmp    801373 <strchr+0xa>
			return (char *) s;
	return 0;
  801383:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801388:	5d                   	pop    %ebp
  801389:	c3                   	ret    

0080138a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80138a:	55                   	push   %ebp
  80138b:	89 e5                	mov    %esp,%ebp
  80138d:	8b 45 08             	mov    0x8(%ebp),%eax
  801390:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801394:	eb 03                	jmp    801399 <strfind+0xf>
  801396:	83 c0 01             	add    $0x1,%eax
  801399:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80139c:	38 ca                	cmp    %cl,%dl
  80139e:	74 04                	je     8013a4 <strfind+0x1a>
  8013a0:	84 d2                	test   %dl,%dl
  8013a2:	75 f2                	jne    801396 <strfind+0xc>
			break;
	return (char *) s;
}
  8013a4:	5d                   	pop    %ebp
  8013a5:	c3                   	ret    

008013a6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8013a6:	55                   	push   %ebp
  8013a7:	89 e5                	mov    %esp,%ebp
  8013a9:	57                   	push   %edi
  8013aa:	56                   	push   %esi
  8013ab:	53                   	push   %ebx
  8013ac:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013af:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8013b2:	85 c9                	test   %ecx,%ecx
  8013b4:	74 13                	je     8013c9 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8013b6:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8013bc:	75 05                	jne    8013c3 <memset+0x1d>
  8013be:	f6 c1 03             	test   $0x3,%cl
  8013c1:	74 0d                	je     8013d0 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8013c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013c6:	fc                   	cld    
  8013c7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8013c9:	89 f8                	mov    %edi,%eax
  8013cb:	5b                   	pop    %ebx
  8013cc:	5e                   	pop    %esi
  8013cd:	5f                   	pop    %edi
  8013ce:	5d                   	pop    %ebp
  8013cf:	c3                   	ret    
		c &= 0xFF;
  8013d0:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8013d4:	89 d3                	mov    %edx,%ebx
  8013d6:	c1 e3 08             	shl    $0x8,%ebx
  8013d9:	89 d0                	mov    %edx,%eax
  8013db:	c1 e0 18             	shl    $0x18,%eax
  8013de:	89 d6                	mov    %edx,%esi
  8013e0:	c1 e6 10             	shl    $0x10,%esi
  8013e3:	09 f0                	or     %esi,%eax
  8013e5:	09 c2                	or     %eax,%edx
  8013e7:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  8013e9:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8013ec:	89 d0                	mov    %edx,%eax
  8013ee:	fc                   	cld    
  8013ef:	f3 ab                	rep stos %eax,%es:(%edi)
  8013f1:	eb d6                	jmp    8013c9 <memset+0x23>

008013f3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8013f3:	55                   	push   %ebp
  8013f4:	89 e5                	mov    %esp,%ebp
  8013f6:	57                   	push   %edi
  8013f7:	56                   	push   %esi
  8013f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8013fb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013fe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801401:	39 c6                	cmp    %eax,%esi
  801403:	73 35                	jae    80143a <memmove+0x47>
  801405:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801408:	39 c2                	cmp    %eax,%edx
  80140a:	76 2e                	jbe    80143a <memmove+0x47>
		s += n;
		d += n;
  80140c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80140f:	89 d6                	mov    %edx,%esi
  801411:	09 fe                	or     %edi,%esi
  801413:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801419:	74 0c                	je     801427 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80141b:	83 ef 01             	sub    $0x1,%edi
  80141e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  801421:	fd                   	std    
  801422:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801424:	fc                   	cld    
  801425:	eb 21                	jmp    801448 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801427:	f6 c1 03             	test   $0x3,%cl
  80142a:	75 ef                	jne    80141b <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80142c:	83 ef 04             	sub    $0x4,%edi
  80142f:	8d 72 fc             	lea    -0x4(%edx),%esi
  801432:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801435:	fd                   	std    
  801436:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801438:	eb ea                	jmp    801424 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80143a:	89 f2                	mov    %esi,%edx
  80143c:	09 c2                	or     %eax,%edx
  80143e:	f6 c2 03             	test   $0x3,%dl
  801441:	74 09                	je     80144c <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801443:	89 c7                	mov    %eax,%edi
  801445:	fc                   	cld    
  801446:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801448:	5e                   	pop    %esi
  801449:	5f                   	pop    %edi
  80144a:	5d                   	pop    %ebp
  80144b:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80144c:	f6 c1 03             	test   $0x3,%cl
  80144f:	75 f2                	jne    801443 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801451:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801454:	89 c7                	mov    %eax,%edi
  801456:	fc                   	cld    
  801457:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801459:	eb ed                	jmp    801448 <memmove+0x55>

0080145b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80145b:	55                   	push   %ebp
  80145c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80145e:	ff 75 10             	pushl  0x10(%ebp)
  801461:	ff 75 0c             	pushl  0xc(%ebp)
  801464:	ff 75 08             	pushl  0x8(%ebp)
  801467:	e8 87 ff ff ff       	call   8013f3 <memmove>
}
  80146c:	c9                   	leave  
  80146d:	c3                   	ret    

0080146e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80146e:	55                   	push   %ebp
  80146f:	89 e5                	mov    %esp,%ebp
  801471:	56                   	push   %esi
  801472:	53                   	push   %ebx
  801473:	8b 45 08             	mov    0x8(%ebp),%eax
  801476:	8b 55 0c             	mov    0xc(%ebp),%edx
  801479:	89 c6                	mov    %eax,%esi
  80147b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80147e:	39 f0                	cmp    %esi,%eax
  801480:	74 1c                	je     80149e <memcmp+0x30>
		if (*s1 != *s2)
  801482:	0f b6 08             	movzbl (%eax),%ecx
  801485:	0f b6 1a             	movzbl (%edx),%ebx
  801488:	38 d9                	cmp    %bl,%cl
  80148a:	75 08                	jne    801494 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  80148c:	83 c0 01             	add    $0x1,%eax
  80148f:	83 c2 01             	add    $0x1,%edx
  801492:	eb ea                	jmp    80147e <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  801494:	0f b6 c1             	movzbl %cl,%eax
  801497:	0f b6 db             	movzbl %bl,%ebx
  80149a:	29 d8                	sub    %ebx,%eax
  80149c:	eb 05                	jmp    8014a3 <memcmp+0x35>
	}

	return 0;
  80149e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014a3:	5b                   	pop    %ebx
  8014a4:	5e                   	pop    %esi
  8014a5:	5d                   	pop    %ebp
  8014a6:	c3                   	ret    

008014a7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8014a7:	55                   	push   %ebp
  8014a8:	89 e5                	mov    %esp,%ebp
  8014aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8014b0:	89 c2                	mov    %eax,%edx
  8014b2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8014b5:	39 d0                	cmp    %edx,%eax
  8014b7:	73 09                	jae    8014c2 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8014b9:	38 08                	cmp    %cl,(%eax)
  8014bb:	74 05                	je     8014c2 <memfind+0x1b>
	for (; s < ends; s++)
  8014bd:	83 c0 01             	add    $0x1,%eax
  8014c0:	eb f3                	jmp    8014b5 <memfind+0xe>
			break;
	return (void *) s;
}
  8014c2:	5d                   	pop    %ebp
  8014c3:	c3                   	ret    

008014c4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8014c4:	55                   	push   %ebp
  8014c5:	89 e5                	mov    %esp,%ebp
  8014c7:	57                   	push   %edi
  8014c8:	56                   	push   %esi
  8014c9:	53                   	push   %ebx
  8014ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014cd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8014d0:	eb 03                	jmp    8014d5 <strtol+0x11>
		s++;
  8014d2:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  8014d5:	0f b6 01             	movzbl (%ecx),%eax
  8014d8:	3c 20                	cmp    $0x20,%al
  8014da:	74 f6                	je     8014d2 <strtol+0xe>
  8014dc:	3c 09                	cmp    $0x9,%al
  8014de:	74 f2                	je     8014d2 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8014e0:	3c 2b                	cmp    $0x2b,%al
  8014e2:	74 2e                	je     801512 <strtol+0x4e>
	int neg = 0;
  8014e4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8014e9:	3c 2d                	cmp    $0x2d,%al
  8014eb:	74 2f                	je     80151c <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8014ed:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8014f3:	75 05                	jne    8014fa <strtol+0x36>
  8014f5:	80 39 30             	cmpb   $0x30,(%ecx)
  8014f8:	74 2c                	je     801526 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8014fa:	85 db                	test   %ebx,%ebx
  8014fc:	75 0a                	jne    801508 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8014fe:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  801503:	80 39 30             	cmpb   $0x30,(%ecx)
  801506:	74 28                	je     801530 <strtol+0x6c>
		base = 10;
  801508:	b8 00 00 00 00       	mov    $0x0,%eax
  80150d:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801510:	eb 50                	jmp    801562 <strtol+0x9e>
		s++;
  801512:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  801515:	bf 00 00 00 00       	mov    $0x0,%edi
  80151a:	eb d1                	jmp    8014ed <strtol+0x29>
		s++, neg = 1;
  80151c:	83 c1 01             	add    $0x1,%ecx
  80151f:	bf 01 00 00 00       	mov    $0x1,%edi
  801524:	eb c7                	jmp    8014ed <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801526:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80152a:	74 0e                	je     80153a <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  80152c:	85 db                	test   %ebx,%ebx
  80152e:	75 d8                	jne    801508 <strtol+0x44>
		s++, base = 8;
  801530:	83 c1 01             	add    $0x1,%ecx
  801533:	bb 08 00 00 00       	mov    $0x8,%ebx
  801538:	eb ce                	jmp    801508 <strtol+0x44>
		s += 2, base = 16;
  80153a:	83 c1 02             	add    $0x2,%ecx
  80153d:	bb 10 00 00 00       	mov    $0x10,%ebx
  801542:	eb c4                	jmp    801508 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  801544:	8d 72 9f             	lea    -0x61(%edx),%esi
  801547:	89 f3                	mov    %esi,%ebx
  801549:	80 fb 19             	cmp    $0x19,%bl
  80154c:	77 29                	ja     801577 <strtol+0xb3>
			dig = *s - 'a' + 10;
  80154e:	0f be d2             	movsbl %dl,%edx
  801551:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801554:	3b 55 10             	cmp    0x10(%ebp),%edx
  801557:	7d 30                	jge    801589 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801559:	83 c1 01             	add    $0x1,%ecx
  80155c:	0f af 45 10          	imul   0x10(%ebp),%eax
  801560:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801562:	0f b6 11             	movzbl (%ecx),%edx
  801565:	8d 72 d0             	lea    -0x30(%edx),%esi
  801568:	89 f3                	mov    %esi,%ebx
  80156a:	80 fb 09             	cmp    $0x9,%bl
  80156d:	77 d5                	ja     801544 <strtol+0x80>
			dig = *s - '0';
  80156f:	0f be d2             	movsbl %dl,%edx
  801572:	83 ea 30             	sub    $0x30,%edx
  801575:	eb dd                	jmp    801554 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  801577:	8d 72 bf             	lea    -0x41(%edx),%esi
  80157a:	89 f3                	mov    %esi,%ebx
  80157c:	80 fb 19             	cmp    $0x19,%bl
  80157f:	77 08                	ja     801589 <strtol+0xc5>
			dig = *s - 'A' + 10;
  801581:	0f be d2             	movsbl %dl,%edx
  801584:	83 ea 37             	sub    $0x37,%edx
  801587:	eb cb                	jmp    801554 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  801589:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80158d:	74 05                	je     801594 <strtol+0xd0>
		*endptr = (char *) s;
  80158f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801592:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801594:	89 c2                	mov    %eax,%edx
  801596:	f7 da                	neg    %edx
  801598:	85 ff                	test   %edi,%edi
  80159a:	0f 45 c2             	cmovne %edx,%eax
}
  80159d:	5b                   	pop    %ebx
  80159e:	5e                   	pop    %esi
  80159f:	5f                   	pop    %edi
  8015a0:	5d                   	pop    %ebp
  8015a1:	c3                   	ret    

008015a2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8015a2:	55                   	push   %ebp
  8015a3:	89 e5                	mov    %esp,%ebp
  8015a5:	57                   	push   %edi
  8015a6:	56                   	push   %esi
  8015a7:	53                   	push   %ebx
	asm volatile("int %1\n"
  8015a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8015ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8015b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015b3:	89 c3                	mov    %eax,%ebx
  8015b5:	89 c7                	mov    %eax,%edi
  8015b7:	89 c6                	mov    %eax,%esi
  8015b9:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8015bb:	5b                   	pop    %ebx
  8015bc:	5e                   	pop    %esi
  8015bd:	5f                   	pop    %edi
  8015be:	5d                   	pop    %ebp
  8015bf:	c3                   	ret    

008015c0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8015c0:	55                   	push   %ebp
  8015c1:	89 e5                	mov    %esp,%ebp
  8015c3:	57                   	push   %edi
  8015c4:	56                   	push   %esi
  8015c5:	53                   	push   %ebx
	asm volatile("int %1\n"
  8015c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8015cb:	b8 01 00 00 00       	mov    $0x1,%eax
  8015d0:	89 d1                	mov    %edx,%ecx
  8015d2:	89 d3                	mov    %edx,%ebx
  8015d4:	89 d7                	mov    %edx,%edi
  8015d6:	89 d6                	mov    %edx,%esi
  8015d8:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8015da:	5b                   	pop    %ebx
  8015db:	5e                   	pop    %esi
  8015dc:	5f                   	pop    %edi
  8015dd:	5d                   	pop    %ebp
  8015de:	c3                   	ret    

008015df <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8015df:	55                   	push   %ebp
  8015e0:	89 e5                	mov    %esp,%ebp
  8015e2:	57                   	push   %edi
  8015e3:	56                   	push   %esi
  8015e4:	53                   	push   %ebx
  8015e5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8015e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8015f0:	b8 03 00 00 00       	mov    $0x3,%eax
  8015f5:	89 cb                	mov    %ecx,%ebx
  8015f7:	89 cf                	mov    %ecx,%edi
  8015f9:	89 ce                	mov    %ecx,%esi
  8015fb:	cd 30                	int    $0x30
	if(check && ret > 0)
  8015fd:	85 c0                	test   %eax,%eax
  8015ff:	7f 08                	jg     801609 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801601:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801604:	5b                   	pop    %ebx
  801605:	5e                   	pop    %esi
  801606:	5f                   	pop    %edi
  801607:	5d                   	pop    %ebp
  801608:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801609:	83 ec 0c             	sub    $0xc,%esp
  80160c:	50                   	push   %eax
  80160d:	6a 03                	push   $0x3
  80160f:	68 4f 38 80 00       	push   $0x80384f
  801614:	6a 23                	push   $0x23
  801616:	68 6c 38 80 00       	push   $0x80386c
  80161b:	e8 5b f4 ff ff       	call   800a7b <_panic>

00801620 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801620:	55                   	push   %ebp
  801621:	89 e5                	mov    %esp,%ebp
  801623:	57                   	push   %edi
  801624:	56                   	push   %esi
  801625:	53                   	push   %ebx
	asm volatile("int %1\n"
  801626:	ba 00 00 00 00       	mov    $0x0,%edx
  80162b:	b8 02 00 00 00       	mov    $0x2,%eax
  801630:	89 d1                	mov    %edx,%ecx
  801632:	89 d3                	mov    %edx,%ebx
  801634:	89 d7                	mov    %edx,%edi
  801636:	89 d6                	mov    %edx,%esi
  801638:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80163a:	5b                   	pop    %ebx
  80163b:	5e                   	pop    %esi
  80163c:	5f                   	pop    %edi
  80163d:	5d                   	pop    %ebp
  80163e:	c3                   	ret    

0080163f <sys_yield>:

void
sys_yield(void)
{
  80163f:	55                   	push   %ebp
  801640:	89 e5                	mov    %esp,%ebp
  801642:	57                   	push   %edi
  801643:	56                   	push   %esi
  801644:	53                   	push   %ebx
	asm volatile("int %1\n"
  801645:	ba 00 00 00 00       	mov    $0x0,%edx
  80164a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80164f:	89 d1                	mov    %edx,%ecx
  801651:	89 d3                	mov    %edx,%ebx
  801653:	89 d7                	mov    %edx,%edi
  801655:	89 d6                	mov    %edx,%esi
  801657:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801659:	5b                   	pop    %ebx
  80165a:	5e                   	pop    %esi
  80165b:	5f                   	pop    %edi
  80165c:	5d                   	pop    %ebp
  80165d:	c3                   	ret    

0080165e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80165e:	55                   	push   %ebp
  80165f:	89 e5                	mov    %esp,%ebp
  801661:	57                   	push   %edi
  801662:	56                   	push   %esi
  801663:	53                   	push   %ebx
  801664:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801667:	be 00 00 00 00       	mov    $0x0,%esi
  80166c:	8b 55 08             	mov    0x8(%ebp),%edx
  80166f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801672:	b8 04 00 00 00       	mov    $0x4,%eax
  801677:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80167a:	89 f7                	mov    %esi,%edi
  80167c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80167e:	85 c0                	test   %eax,%eax
  801680:	7f 08                	jg     80168a <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801682:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801685:	5b                   	pop    %ebx
  801686:	5e                   	pop    %esi
  801687:	5f                   	pop    %edi
  801688:	5d                   	pop    %ebp
  801689:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80168a:	83 ec 0c             	sub    $0xc,%esp
  80168d:	50                   	push   %eax
  80168e:	6a 04                	push   $0x4
  801690:	68 4f 38 80 00       	push   $0x80384f
  801695:	6a 23                	push   $0x23
  801697:	68 6c 38 80 00       	push   $0x80386c
  80169c:	e8 da f3 ff ff       	call   800a7b <_panic>

008016a1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8016a1:	55                   	push   %ebp
  8016a2:	89 e5                	mov    %esp,%ebp
  8016a4:	57                   	push   %edi
  8016a5:	56                   	push   %esi
  8016a6:	53                   	push   %ebx
  8016a7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8016aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8016ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016b0:	b8 05 00 00 00       	mov    $0x5,%eax
  8016b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8016b8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8016bb:	8b 75 18             	mov    0x18(%ebp),%esi
  8016be:	cd 30                	int    $0x30
	if(check && ret > 0)
  8016c0:	85 c0                	test   %eax,%eax
  8016c2:	7f 08                	jg     8016cc <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8016c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016c7:	5b                   	pop    %ebx
  8016c8:	5e                   	pop    %esi
  8016c9:	5f                   	pop    %edi
  8016ca:	5d                   	pop    %ebp
  8016cb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8016cc:	83 ec 0c             	sub    $0xc,%esp
  8016cf:	50                   	push   %eax
  8016d0:	6a 05                	push   $0x5
  8016d2:	68 4f 38 80 00       	push   $0x80384f
  8016d7:	6a 23                	push   $0x23
  8016d9:	68 6c 38 80 00       	push   $0x80386c
  8016de:	e8 98 f3 ff ff       	call   800a7b <_panic>

008016e3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8016e3:	55                   	push   %ebp
  8016e4:	89 e5                	mov    %esp,%ebp
  8016e6:	57                   	push   %edi
  8016e7:	56                   	push   %esi
  8016e8:	53                   	push   %ebx
  8016e9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8016ec:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8016f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016f7:	b8 06 00 00 00       	mov    $0x6,%eax
  8016fc:	89 df                	mov    %ebx,%edi
  8016fe:	89 de                	mov    %ebx,%esi
  801700:	cd 30                	int    $0x30
	if(check && ret > 0)
  801702:	85 c0                	test   %eax,%eax
  801704:	7f 08                	jg     80170e <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801706:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801709:	5b                   	pop    %ebx
  80170a:	5e                   	pop    %esi
  80170b:	5f                   	pop    %edi
  80170c:	5d                   	pop    %ebp
  80170d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80170e:	83 ec 0c             	sub    $0xc,%esp
  801711:	50                   	push   %eax
  801712:	6a 06                	push   $0x6
  801714:	68 4f 38 80 00       	push   $0x80384f
  801719:	6a 23                	push   $0x23
  80171b:	68 6c 38 80 00       	push   $0x80386c
  801720:	e8 56 f3 ff ff       	call   800a7b <_panic>

00801725 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801725:	55                   	push   %ebp
  801726:	89 e5                	mov    %esp,%ebp
  801728:	57                   	push   %edi
  801729:	56                   	push   %esi
  80172a:	53                   	push   %ebx
  80172b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80172e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801733:	8b 55 08             	mov    0x8(%ebp),%edx
  801736:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801739:	b8 08 00 00 00       	mov    $0x8,%eax
  80173e:	89 df                	mov    %ebx,%edi
  801740:	89 de                	mov    %ebx,%esi
  801742:	cd 30                	int    $0x30
	if(check && ret > 0)
  801744:	85 c0                	test   %eax,%eax
  801746:	7f 08                	jg     801750 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801748:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80174b:	5b                   	pop    %ebx
  80174c:	5e                   	pop    %esi
  80174d:	5f                   	pop    %edi
  80174e:	5d                   	pop    %ebp
  80174f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801750:	83 ec 0c             	sub    $0xc,%esp
  801753:	50                   	push   %eax
  801754:	6a 08                	push   $0x8
  801756:	68 4f 38 80 00       	push   $0x80384f
  80175b:	6a 23                	push   $0x23
  80175d:	68 6c 38 80 00       	push   $0x80386c
  801762:	e8 14 f3 ff ff       	call   800a7b <_panic>

00801767 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801767:	55                   	push   %ebp
  801768:	89 e5                	mov    %esp,%ebp
  80176a:	57                   	push   %edi
  80176b:	56                   	push   %esi
  80176c:	53                   	push   %ebx
  80176d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801770:	bb 00 00 00 00       	mov    $0x0,%ebx
  801775:	8b 55 08             	mov    0x8(%ebp),%edx
  801778:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80177b:	b8 09 00 00 00       	mov    $0x9,%eax
  801780:	89 df                	mov    %ebx,%edi
  801782:	89 de                	mov    %ebx,%esi
  801784:	cd 30                	int    $0x30
	if(check && ret > 0)
  801786:	85 c0                	test   %eax,%eax
  801788:	7f 08                	jg     801792 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80178a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80178d:	5b                   	pop    %ebx
  80178e:	5e                   	pop    %esi
  80178f:	5f                   	pop    %edi
  801790:	5d                   	pop    %ebp
  801791:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801792:	83 ec 0c             	sub    $0xc,%esp
  801795:	50                   	push   %eax
  801796:	6a 09                	push   $0x9
  801798:	68 4f 38 80 00       	push   $0x80384f
  80179d:	6a 23                	push   $0x23
  80179f:	68 6c 38 80 00       	push   $0x80386c
  8017a4:	e8 d2 f2 ff ff       	call   800a7b <_panic>

008017a9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8017a9:	55                   	push   %ebp
  8017aa:	89 e5                	mov    %esp,%ebp
  8017ac:	57                   	push   %edi
  8017ad:	56                   	push   %esi
  8017ae:	53                   	push   %ebx
  8017af:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8017b2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8017ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017bd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8017c2:	89 df                	mov    %ebx,%edi
  8017c4:	89 de                	mov    %ebx,%esi
  8017c6:	cd 30                	int    $0x30
	if(check && ret > 0)
  8017c8:	85 c0                	test   %eax,%eax
  8017ca:	7f 08                	jg     8017d4 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8017cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017cf:	5b                   	pop    %ebx
  8017d0:	5e                   	pop    %esi
  8017d1:	5f                   	pop    %edi
  8017d2:	5d                   	pop    %ebp
  8017d3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8017d4:	83 ec 0c             	sub    $0xc,%esp
  8017d7:	50                   	push   %eax
  8017d8:	6a 0a                	push   $0xa
  8017da:	68 4f 38 80 00       	push   $0x80384f
  8017df:	6a 23                	push   $0x23
  8017e1:	68 6c 38 80 00       	push   $0x80386c
  8017e6:	e8 90 f2 ff ff       	call   800a7b <_panic>

008017eb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8017eb:	55                   	push   %ebp
  8017ec:	89 e5                	mov    %esp,%ebp
  8017ee:	57                   	push   %edi
  8017ef:	56                   	push   %esi
  8017f0:	53                   	push   %ebx
	asm volatile("int %1\n"
  8017f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8017f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017f7:	b8 0c 00 00 00       	mov    $0xc,%eax
  8017fc:	be 00 00 00 00       	mov    $0x0,%esi
  801801:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801804:	8b 7d 14             	mov    0x14(%ebp),%edi
  801807:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801809:	5b                   	pop    %ebx
  80180a:	5e                   	pop    %esi
  80180b:	5f                   	pop    %edi
  80180c:	5d                   	pop    %ebp
  80180d:	c3                   	ret    

0080180e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80180e:	55                   	push   %ebp
  80180f:	89 e5                	mov    %esp,%ebp
  801811:	57                   	push   %edi
  801812:	56                   	push   %esi
  801813:	53                   	push   %ebx
  801814:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801817:	b9 00 00 00 00       	mov    $0x0,%ecx
  80181c:	8b 55 08             	mov    0x8(%ebp),%edx
  80181f:	b8 0d 00 00 00       	mov    $0xd,%eax
  801824:	89 cb                	mov    %ecx,%ebx
  801826:	89 cf                	mov    %ecx,%edi
  801828:	89 ce                	mov    %ecx,%esi
  80182a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80182c:	85 c0                	test   %eax,%eax
  80182e:	7f 08                	jg     801838 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801830:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801833:	5b                   	pop    %ebx
  801834:	5e                   	pop    %esi
  801835:	5f                   	pop    %edi
  801836:	5d                   	pop    %ebp
  801837:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801838:	83 ec 0c             	sub    $0xc,%esp
  80183b:	50                   	push   %eax
  80183c:	6a 0d                	push   $0xd
  80183e:	68 4f 38 80 00       	push   $0x80384f
  801843:	6a 23                	push   $0x23
  801845:	68 6c 38 80 00       	push   $0x80386c
  80184a:	e8 2c f2 ff ff       	call   800a7b <_panic>

0080184f <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80184f:	55                   	push   %ebp
  801850:	89 e5                	mov    %esp,%ebp
  801852:	53                   	push   %ebx
  801853:	83 ec 04             	sub    $0x4,%esp
  801856:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  801859:	8b 02                	mov    (%edx),%eax
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  80185b:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  80185f:	0f 84 9c 00 00 00    	je     801901 <pgfault+0xb2>
  801865:	89 c2                	mov    %eax,%edx
  801867:	c1 ea 16             	shr    $0x16,%edx
  80186a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801871:	f6 c2 01             	test   $0x1,%dl
  801874:	0f 84 87 00 00 00    	je     801901 <pgfault+0xb2>
  80187a:	89 c2                	mov    %eax,%edx
  80187c:	c1 ea 0c             	shr    $0xc,%edx
  80187f:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  801886:	f6 c1 01             	test   $0x1,%cl
  801889:	74 76                	je     801901 <pgfault+0xb2>
  80188b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801892:	f6 c6 08             	test   $0x8,%dh
  801895:	74 6a                	je     801901 <pgfault+0xb2>
		panic("not copy-on-write");
	addr = ROUNDDOWN(addr, PGSIZE);
  801897:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80189c:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P) < 0)
  80189e:	83 ec 04             	sub    $0x4,%esp
  8018a1:	6a 07                	push   $0x7
  8018a3:	68 00 f0 7f 00       	push   $0x7ff000
  8018a8:	6a 00                	push   $0x0
  8018aa:	e8 af fd ff ff       	call   80165e <sys_page_alloc>
  8018af:	83 c4 10             	add    $0x10,%esp
  8018b2:	85 c0                	test   %eax,%eax
  8018b4:	78 5f                	js     801915 <pgfault+0xc6>
		panic("sys_page_alloc");
	memcpy(PFTEMP, addr, PGSIZE);
  8018b6:	83 ec 04             	sub    $0x4,%esp
  8018b9:	68 00 10 00 00       	push   $0x1000
  8018be:	53                   	push   %ebx
  8018bf:	68 00 f0 7f 00       	push   $0x7ff000
  8018c4:	e8 92 fb ff ff       	call   80145b <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P) < 0)
  8018c9:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8018d0:	53                   	push   %ebx
  8018d1:	6a 00                	push   $0x0
  8018d3:	68 00 f0 7f 00       	push   $0x7ff000
  8018d8:	6a 00                	push   $0x0
  8018da:	e8 c2 fd ff ff       	call   8016a1 <sys_page_map>
  8018df:	83 c4 20             	add    $0x20,%esp
  8018e2:	85 c0                	test   %eax,%eax
  8018e4:	78 43                	js     801929 <pgfault+0xda>
		panic("sys_page_map");
	if (sys_page_unmap(0, PFTEMP) < 0)
  8018e6:	83 ec 08             	sub    $0x8,%esp
  8018e9:	68 00 f0 7f 00       	push   $0x7ff000
  8018ee:	6a 00                	push   $0x0
  8018f0:	e8 ee fd ff ff       	call   8016e3 <sys_page_unmap>
  8018f5:	83 c4 10             	add    $0x10,%esp
  8018f8:	85 c0                	test   %eax,%eax
  8018fa:	78 41                	js     80193d <pgfault+0xee>
		panic("sys_page_unmap");
	return;
}
  8018fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018ff:	c9                   	leave  
  801900:	c3                   	ret    
		panic("not copy-on-write");
  801901:	83 ec 04             	sub    $0x4,%esp
  801904:	68 7a 38 80 00       	push   $0x80387a
  801909:	6a 25                	push   $0x25
  80190b:	68 8c 38 80 00       	push   $0x80388c
  801910:	e8 66 f1 ff ff       	call   800a7b <_panic>
		panic("sys_page_alloc");
  801915:	83 ec 04             	sub    $0x4,%esp
  801918:	68 97 38 80 00       	push   $0x803897
  80191d:	6a 28                	push   $0x28
  80191f:	68 8c 38 80 00       	push   $0x80388c
  801924:	e8 52 f1 ff ff       	call   800a7b <_panic>
		panic("sys_page_map");
  801929:	83 ec 04             	sub    $0x4,%esp
  80192c:	68 a6 38 80 00       	push   $0x8038a6
  801931:	6a 2b                	push   $0x2b
  801933:	68 8c 38 80 00       	push   $0x80388c
  801938:	e8 3e f1 ff ff       	call   800a7b <_panic>
		panic("sys_page_unmap");
  80193d:	83 ec 04             	sub    $0x4,%esp
  801940:	68 b3 38 80 00       	push   $0x8038b3
  801945:	6a 2d                	push   $0x2d
  801947:	68 8c 38 80 00       	push   $0x80388c
  80194c:	e8 2a f1 ff ff       	call   800a7b <_panic>

00801951 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801951:	55                   	push   %ebp
  801952:	89 e5                	mov    %esp,%ebp
  801954:	57                   	push   %edi
  801955:	56                   	push   %esi
  801956:	53                   	push   %ebx
  801957:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  80195a:	68 4f 18 80 00       	push   $0x80184f
  80195f:	e8 aa 15 00 00       	call   802f0e <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801964:	b8 07 00 00 00       	mov    $0x7,%eax
  801969:	cd 30                	int    $0x30
  80196b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid;
	uint32_t addr;
	envid = sys_exofork();
	if (envid == 0) {
  80196e:	83 c4 10             	add    $0x10,%esp
  801971:	85 c0                	test   %eax,%eax
  801973:	74 12                	je     801987 <fork+0x36>
  801975:	89 c7                	mov    %eax,%edi
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	if (envid < 0)
  801977:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80197b:	78 26                	js     8019a3 <fork+0x52>
		panic("sys_exofork: %e", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  80197d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801982:	e9 94 00 00 00       	jmp    801a1b <fork+0xca>
		thisenv = &envs[ENVX(sys_getenvid())];
  801987:	e8 94 fc ff ff       	call   801620 <sys_getenvid>
  80198c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801991:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801994:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801999:	a3 24 54 80 00       	mov    %eax,0x805424
		return 0;
  80199e:	e9 51 01 00 00       	jmp    801af4 <fork+0x1a3>
		panic("sys_exofork: %e", envid);
  8019a3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019a6:	68 c2 38 80 00       	push   $0x8038c2
  8019ab:	6a 6e                	push   $0x6e
  8019ad:	68 8c 38 80 00       	push   $0x80388c
  8019b2:	e8 c4 f0 ff ff       	call   800a7b <_panic>
        	sys_page_map(0, addr, envid, addr, PTE_SYSCALL);
  8019b7:	83 ec 0c             	sub    $0xc,%esp
  8019ba:	68 07 0e 00 00       	push   $0xe07
  8019bf:	56                   	push   %esi
  8019c0:	57                   	push   %edi
  8019c1:	56                   	push   %esi
  8019c2:	6a 00                	push   $0x0
  8019c4:	e8 d8 fc ff ff       	call   8016a1 <sys_page_map>
  8019c9:	83 c4 20             	add    $0x20,%esp
  8019cc:	eb 3b                	jmp    801a09 <fork+0xb8>
        	if ((r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  8019ce:	83 ec 0c             	sub    $0xc,%esp
  8019d1:	68 05 08 00 00       	push   $0x805
  8019d6:	56                   	push   %esi
  8019d7:	57                   	push   %edi
  8019d8:	56                   	push   %esi
  8019d9:	6a 00                	push   $0x0
  8019db:	e8 c1 fc ff ff       	call   8016a1 <sys_page_map>
  8019e0:	83 c4 20             	add    $0x20,%esp
  8019e3:	85 c0                	test   %eax,%eax
  8019e5:	0f 88 a9 00 00 00    	js     801a94 <fork+0x143>
        	if ((r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  8019eb:	83 ec 0c             	sub    $0xc,%esp
  8019ee:	68 05 08 00 00       	push   $0x805
  8019f3:	56                   	push   %esi
  8019f4:	6a 00                	push   $0x0
  8019f6:	56                   	push   %esi
  8019f7:	6a 00                	push   $0x0
  8019f9:	e8 a3 fc ff ff       	call   8016a1 <sys_page_map>
  8019fe:	83 c4 20             	add    $0x20,%esp
  801a01:	85 c0                	test   %eax,%eax
  801a03:	0f 88 9d 00 00 00    	js     801aa6 <fork+0x155>
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  801a09:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801a0f:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801a15:	0f 84 9d 00 00 00    	je     801ab8 <fork+0x167>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  801a1b:	89 d8                	mov    %ebx,%eax
  801a1d:	c1 e8 16             	shr    $0x16,%eax
  801a20:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801a27:	a8 01                	test   $0x1,%al
  801a29:	74 de                	je     801a09 <fork+0xb8>
  801a2b:	89 d8                	mov    %ebx,%eax
  801a2d:	c1 e8 0c             	shr    $0xc,%eax
  801a30:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801a37:	f6 c2 01             	test   $0x1,%dl
  801a3a:	74 cd                	je     801a09 <fork+0xb8>
			&& (uvpt[PGNUM(addr)] & PTE_U)) {
  801a3c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801a43:	f6 c2 04             	test   $0x4,%dl
  801a46:	74 c1                	je     801a09 <fork+0xb8>
	void *addr = (void*) (pn*PGSIZE);
  801a48:	89 c6                	mov    %eax,%esi
  801a4a:	c1 e6 0c             	shl    $0xc,%esi
    	if (uvpt[pn] & PTE_SHARE) {
  801a4d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801a54:	f6 c6 04             	test   $0x4,%dh
  801a57:	0f 85 5a ff ff ff    	jne    8019b7 <fork+0x66>
    	} else if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  801a5d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801a64:	f6 c2 02             	test   $0x2,%dl
  801a67:	0f 85 61 ff ff ff    	jne    8019ce <fork+0x7d>
  801a6d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a74:	f6 c4 08             	test   $0x8,%ah
  801a77:	0f 85 51 ff ff ff    	jne    8019ce <fork+0x7d>
        		sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  801a7d:	83 ec 0c             	sub    $0xc,%esp
  801a80:	6a 05                	push   $0x5
  801a82:	56                   	push   %esi
  801a83:	57                   	push   %edi
  801a84:	56                   	push   %esi
  801a85:	6a 00                	push   $0x0
  801a87:	e8 15 fc ff ff       	call   8016a1 <sys_page_map>
  801a8c:	83 c4 20             	add    $0x20,%esp
  801a8f:	e9 75 ff ff ff       	jmp    801a09 <fork+0xb8>
            		panic("sys_page_map：%e", r);
  801a94:	50                   	push   %eax
  801a95:	68 d2 38 80 00       	push   $0x8038d2
  801a9a:	6a 47                	push   $0x47
  801a9c:	68 8c 38 80 00       	push   $0x80388c
  801aa1:	e8 d5 ef ff ff       	call   800a7b <_panic>
            		panic("sys_page_map：%e", r);
  801aa6:	50                   	push   %eax
  801aa7:	68 d2 38 80 00       	push   $0x8038d2
  801aac:	6a 49                	push   $0x49
  801aae:	68 8c 38 80 00       	push   $0x80388c
  801ab3:	e8 c3 ef ff ff       	call   800a7b <_panic>
			duppage(envid, PGNUM(addr));
		}

	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  801ab8:	83 ec 04             	sub    $0x4,%esp
  801abb:	6a 07                	push   $0x7
  801abd:	68 00 f0 bf ee       	push   $0xeebff000
  801ac2:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ac5:	e8 94 fb ff ff       	call   80165e <sys_page_alloc>
  801aca:	83 c4 10             	add    $0x10,%esp
  801acd:	85 c0                	test   %eax,%eax
  801acf:	78 2e                	js     801aff <fork+0x1ae>
		panic("1");
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801ad1:	83 ec 08             	sub    $0x8,%esp
  801ad4:	68 7d 2f 80 00       	push   $0x802f7d
  801ad9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801adc:	57                   	push   %edi
  801add:	e8 c7 fc ff ff       	call   8017a9 <sys_env_set_pgfault_upcall>

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  801ae2:	83 c4 08             	add    $0x8,%esp
  801ae5:	6a 02                	push   $0x2
  801ae7:	57                   	push   %edi
  801ae8:	e8 38 fc ff ff       	call   801725 <sys_env_set_status>
  801aed:	83 c4 10             	add    $0x10,%esp
  801af0:	85 c0                	test   %eax,%eax
  801af2:	78 1f                	js     801b13 <fork+0x1c2>
		panic("sys_env_set_status");

	return envid;
	panic("fork not implemented");
}
  801af4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801af7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801afa:	5b                   	pop    %ebx
  801afb:	5e                   	pop    %esi
  801afc:	5f                   	pop    %edi
  801afd:	5d                   	pop    %ebp
  801afe:	c3                   	ret    
		panic("1");
  801aff:	83 ec 04             	sub    $0x4,%esp
  801b02:	68 e4 38 80 00       	push   $0x8038e4
  801b07:	6a 77                	push   $0x77
  801b09:	68 8c 38 80 00       	push   $0x80388c
  801b0e:	e8 68 ef ff ff       	call   800a7b <_panic>
		panic("sys_env_set_status");
  801b13:	83 ec 04             	sub    $0x4,%esp
  801b16:	68 e6 38 80 00       	push   $0x8038e6
  801b1b:	6a 7c                	push   $0x7c
  801b1d:	68 8c 38 80 00       	push   $0x80388c
  801b22:	e8 54 ef ff ff       	call   800a7b <_panic>

00801b27 <sfork>:

// Challenge!
int
sfork(void)
{
  801b27:	55                   	push   %ebp
  801b28:	89 e5                	mov    %esp,%ebp
  801b2a:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801b2d:	68 f9 38 80 00       	push   $0x8038f9
  801b32:	68 86 00 00 00       	push   $0x86
  801b37:	68 8c 38 80 00       	push   $0x80388c
  801b3c:	e8 3a ef ff ff       	call   800a7b <_panic>

00801b41 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801b41:	55                   	push   %ebp
  801b42:	89 e5                	mov    %esp,%ebp
  801b44:	8b 55 08             	mov    0x8(%ebp),%edx
  801b47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b4a:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801b4d:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801b4f:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801b52:	83 3a 01             	cmpl   $0x1,(%edx)
  801b55:	7e 09                	jle    801b60 <argstart+0x1f>
  801b57:	ba 41 33 80 00       	mov    $0x803341,%edx
  801b5c:	85 c9                	test   %ecx,%ecx
  801b5e:	75 05                	jne    801b65 <argstart+0x24>
  801b60:	ba 00 00 00 00       	mov    $0x0,%edx
  801b65:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801b68:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801b6f:	5d                   	pop    %ebp
  801b70:	c3                   	ret    

00801b71 <argnext>:

int
argnext(struct Argstate *args)
{
  801b71:	55                   	push   %ebp
  801b72:	89 e5                	mov    %esp,%ebp
  801b74:	53                   	push   %ebx
  801b75:	83 ec 04             	sub    $0x4,%esp
  801b78:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801b7b:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801b82:	8b 43 08             	mov    0x8(%ebx),%eax
  801b85:	85 c0                	test   %eax,%eax
  801b87:	74 72                	je     801bfb <argnext+0x8a>
		return -1;

	if (!*args->curarg) {
  801b89:	80 38 00             	cmpb   $0x0,(%eax)
  801b8c:	75 48                	jne    801bd6 <argnext+0x65>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801b8e:	8b 0b                	mov    (%ebx),%ecx
  801b90:	83 39 01             	cmpl   $0x1,(%ecx)
  801b93:	74 58                	je     801bed <argnext+0x7c>
		    || args->argv[1][0] != '-'
  801b95:	8b 53 04             	mov    0x4(%ebx),%edx
  801b98:	8b 42 04             	mov    0x4(%edx),%eax
  801b9b:	80 38 2d             	cmpb   $0x2d,(%eax)
  801b9e:	75 4d                	jne    801bed <argnext+0x7c>
		    || args->argv[1][1] == '\0')
  801ba0:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801ba4:	74 47                	je     801bed <argnext+0x7c>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801ba6:	83 c0 01             	add    $0x1,%eax
  801ba9:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801bac:	83 ec 04             	sub    $0x4,%esp
  801baf:	8b 01                	mov    (%ecx),%eax
  801bb1:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801bb8:	50                   	push   %eax
  801bb9:	8d 42 08             	lea    0x8(%edx),%eax
  801bbc:	50                   	push   %eax
  801bbd:	83 c2 04             	add    $0x4,%edx
  801bc0:	52                   	push   %edx
  801bc1:	e8 2d f8 ff ff       	call   8013f3 <memmove>
		(*args->argc)--;
  801bc6:	8b 03                	mov    (%ebx),%eax
  801bc8:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801bcb:	8b 43 08             	mov    0x8(%ebx),%eax
  801bce:	83 c4 10             	add    $0x10,%esp
  801bd1:	80 38 2d             	cmpb   $0x2d,(%eax)
  801bd4:	74 11                	je     801be7 <argnext+0x76>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801bd6:	8b 53 08             	mov    0x8(%ebx),%edx
  801bd9:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801bdc:	83 c2 01             	add    $0x1,%edx
  801bdf:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801be2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801be5:	c9                   	leave  
  801be6:	c3                   	ret    
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801be7:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801beb:	75 e9                	jne    801bd6 <argnext+0x65>
	args->curarg = 0;
  801bed:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801bf4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801bf9:	eb e7                	jmp    801be2 <argnext+0x71>
		return -1;
  801bfb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801c00:	eb e0                	jmp    801be2 <argnext+0x71>

00801c02 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801c02:	55                   	push   %ebp
  801c03:	89 e5                	mov    %esp,%ebp
  801c05:	53                   	push   %ebx
  801c06:	83 ec 04             	sub    $0x4,%esp
  801c09:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801c0c:	8b 43 08             	mov    0x8(%ebx),%eax
  801c0f:	85 c0                	test   %eax,%eax
  801c11:	74 5b                	je     801c6e <argnextvalue+0x6c>
		return 0;
	if (*args->curarg) {
  801c13:	80 38 00             	cmpb   $0x0,(%eax)
  801c16:	74 12                	je     801c2a <argnextvalue+0x28>
		args->argvalue = args->curarg;
  801c18:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801c1b:	c7 43 08 41 33 80 00 	movl   $0x803341,0x8(%ebx)
		(*args->argc)--;
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
  801c22:	8b 43 0c             	mov    0xc(%ebx),%eax
}
  801c25:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c28:	c9                   	leave  
  801c29:	c3                   	ret    
	} else if (*args->argc > 1) {
  801c2a:	8b 13                	mov    (%ebx),%edx
  801c2c:	83 3a 01             	cmpl   $0x1,(%edx)
  801c2f:	7f 10                	jg     801c41 <argnextvalue+0x3f>
		args->argvalue = 0;
  801c31:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801c38:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  801c3f:	eb e1                	jmp    801c22 <argnextvalue+0x20>
		args->argvalue = args->argv[1];
  801c41:	8b 43 04             	mov    0x4(%ebx),%eax
  801c44:	8b 48 04             	mov    0x4(%eax),%ecx
  801c47:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801c4a:	83 ec 04             	sub    $0x4,%esp
  801c4d:	8b 12                	mov    (%edx),%edx
  801c4f:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801c56:	52                   	push   %edx
  801c57:	8d 50 08             	lea    0x8(%eax),%edx
  801c5a:	52                   	push   %edx
  801c5b:	83 c0 04             	add    $0x4,%eax
  801c5e:	50                   	push   %eax
  801c5f:	e8 8f f7 ff ff       	call   8013f3 <memmove>
		(*args->argc)--;
  801c64:	8b 03                	mov    (%ebx),%eax
  801c66:	83 28 01             	subl   $0x1,(%eax)
  801c69:	83 c4 10             	add    $0x10,%esp
  801c6c:	eb b4                	jmp    801c22 <argnextvalue+0x20>
		return 0;
  801c6e:	b8 00 00 00 00       	mov    $0x0,%eax
  801c73:	eb b0                	jmp    801c25 <argnextvalue+0x23>

00801c75 <argvalue>:
{
  801c75:	55                   	push   %ebp
  801c76:	89 e5                	mov    %esp,%ebp
  801c78:	83 ec 08             	sub    $0x8,%esp
  801c7b:	8b 55 08             	mov    0x8(%ebp),%edx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801c7e:	8b 42 0c             	mov    0xc(%edx),%eax
  801c81:	85 c0                	test   %eax,%eax
  801c83:	74 02                	je     801c87 <argvalue+0x12>
}
  801c85:	c9                   	leave  
  801c86:	c3                   	ret    
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801c87:	83 ec 0c             	sub    $0xc,%esp
  801c8a:	52                   	push   %edx
  801c8b:	e8 72 ff ff ff       	call   801c02 <argnextvalue>
  801c90:	83 c4 10             	add    $0x10,%esp
  801c93:	eb f0                	jmp    801c85 <argvalue+0x10>

00801c95 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801c95:	55                   	push   %ebp
  801c96:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801c98:	8b 45 08             	mov    0x8(%ebp),%eax
  801c9b:	05 00 00 00 30       	add    $0x30000000,%eax
  801ca0:	c1 e8 0c             	shr    $0xc,%eax
}
  801ca3:	5d                   	pop    %ebp
  801ca4:	c3                   	ret    

00801ca5 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801ca5:	55                   	push   %ebp
  801ca6:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801ca8:	8b 45 08             	mov    0x8(%ebp),%eax
  801cab:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801cb0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801cb5:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801cba:	5d                   	pop    %ebp
  801cbb:	c3                   	ret    

00801cbc <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801cbc:	55                   	push   %ebp
  801cbd:	89 e5                	mov    %esp,%ebp
  801cbf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cc2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801cc7:	89 c2                	mov    %eax,%edx
  801cc9:	c1 ea 16             	shr    $0x16,%edx
  801ccc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801cd3:	f6 c2 01             	test   $0x1,%dl
  801cd6:	74 2a                	je     801d02 <fd_alloc+0x46>
  801cd8:	89 c2                	mov    %eax,%edx
  801cda:	c1 ea 0c             	shr    $0xc,%edx
  801cdd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801ce4:	f6 c2 01             	test   $0x1,%dl
  801ce7:	74 19                	je     801d02 <fd_alloc+0x46>
  801ce9:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801cee:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801cf3:	75 d2                	jne    801cc7 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801cf5:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801cfb:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801d00:	eb 07                	jmp    801d09 <fd_alloc+0x4d>
			*fd_store = fd;
  801d02:	89 01                	mov    %eax,(%ecx)
			return 0;
  801d04:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d09:	5d                   	pop    %ebp
  801d0a:	c3                   	ret    

00801d0b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801d0b:	55                   	push   %ebp
  801d0c:	89 e5                	mov    %esp,%ebp
  801d0e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801d11:	83 f8 1f             	cmp    $0x1f,%eax
  801d14:	77 36                	ja     801d4c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801d16:	c1 e0 0c             	shl    $0xc,%eax
  801d19:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801d1e:	89 c2                	mov    %eax,%edx
  801d20:	c1 ea 16             	shr    $0x16,%edx
  801d23:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801d2a:	f6 c2 01             	test   $0x1,%dl
  801d2d:	74 24                	je     801d53 <fd_lookup+0x48>
  801d2f:	89 c2                	mov    %eax,%edx
  801d31:	c1 ea 0c             	shr    $0xc,%edx
  801d34:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801d3b:	f6 c2 01             	test   $0x1,%dl
  801d3e:	74 1a                	je     801d5a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801d40:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d43:	89 02                	mov    %eax,(%edx)
	return 0;
  801d45:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d4a:	5d                   	pop    %ebp
  801d4b:	c3                   	ret    
		return -E_INVAL;
  801d4c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801d51:	eb f7                	jmp    801d4a <fd_lookup+0x3f>
		return -E_INVAL;
  801d53:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801d58:	eb f0                	jmp    801d4a <fd_lookup+0x3f>
  801d5a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801d5f:	eb e9                	jmp    801d4a <fd_lookup+0x3f>

00801d61 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801d61:	55                   	push   %ebp
  801d62:	89 e5                	mov    %esp,%ebp
  801d64:	83 ec 08             	sub    $0x8,%esp
  801d67:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d6a:	ba 8c 39 80 00       	mov    $0x80398c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801d6f:	b8 20 40 80 00       	mov    $0x804020,%eax
		if (devtab[i]->dev_id == dev_id) {
  801d74:	39 08                	cmp    %ecx,(%eax)
  801d76:	74 33                	je     801dab <dev_lookup+0x4a>
  801d78:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  801d7b:	8b 02                	mov    (%edx),%eax
  801d7d:	85 c0                	test   %eax,%eax
  801d7f:	75 f3                	jne    801d74 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801d81:	a1 24 54 80 00       	mov    0x805424,%eax
  801d86:	8b 40 48             	mov    0x48(%eax),%eax
  801d89:	83 ec 04             	sub    $0x4,%esp
  801d8c:	51                   	push   %ecx
  801d8d:	50                   	push   %eax
  801d8e:	68 10 39 80 00       	push   $0x803910
  801d93:	e8 be ed ff ff       	call   800b56 <cprintf>
	*dev = 0;
  801d98:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d9b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801da1:	83 c4 10             	add    $0x10,%esp
  801da4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801da9:	c9                   	leave  
  801daa:	c3                   	ret    
			*dev = devtab[i];
  801dab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801dae:	89 01                	mov    %eax,(%ecx)
			return 0;
  801db0:	b8 00 00 00 00       	mov    $0x0,%eax
  801db5:	eb f2                	jmp    801da9 <dev_lookup+0x48>

00801db7 <fd_close>:
{
  801db7:	55                   	push   %ebp
  801db8:	89 e5                	mov    %esp,%ebp
  801dba:	57                   	push   %edi
  801dbb:	56                   	push   %esi
  801dbc:	53                   	push   %ebx
  801dbd:	83 ec 1c             	sub    $0x1c,%esp
  801dc0:	8b 75 08             	mov    0x8(%ebp),%esi
  801dc3:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801dc6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801dc9:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801dca:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801dd0:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801dd3:	50                   	push   %eax
  801dd4:	e8 32 ff ff ff       	call   801d0b <fd_lookup>
  801dd9:	89 c3                	mov    %eax,%ebx
  801ddb:	83 c4 08             	add    $0x8,%esp
  801dde:	85 c0                	test   %eax,%eax
  801de0:	78 05                	js     801de7 <fd_close+0x30>
	    || fd != fd2)
  801de2:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801de5:	74 16                	je     801dfd <fd_close+0x46>
		return (must_exist ? r : 0);
  801de7:	89 f8                	mov    %edi,%eax
  801de9:	84 c0                	test   %al,%al
  801deb:	b8 00 00 00 00       	mov    $0x0,%eax
  801df0:	0f 44 d8             	cmove  %eax,%ebx
}
  801df3:	89 d8                	mov    %ebx,%eax
  801df5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801df8:	5b                   	pop    %ebx
  801df9:	5e                   	pop    %esi
  801dfa:	5f                   	pop    %edi
  801dfb:	5d                   	pop    %ebp
  801dfc:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801dfd:	83 ec 08             	sub    $0x8,%esp
  801e00:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801e03:	50                   	push   %eax
  801e04:	ff 36                	pushl  (%esi)
  801e06:	e8 56 ff ff ff       	call   801d61 <dev_lookup>
  801e0b:	89 c3                	mov    %eax,%ebx
  801e0d:	83 c4 10             	add    $0x10,%esp
  801e10:	85 c0                	test   %eax,%eax
  801e12:	78 15                	js     801e29 <fd_close+0x72>
		if (dev->dev_close)
  801e14:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e17:	8b 40 10             	mov    0x10(%eax),%eax
  801e1a:	85 c0                	test   %eax,%eax
  801e1c:	74 1b                	je     801e39 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  801e1e:	83 ec 0c             	sub    $0xc,%esp
  801e21:	56                   	push   %esi
  801e22:	ff d0                	call   *%eax
  801e24:	89 c3                	mov    %eax,%ebx
  801e26:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801e29:	83 ec 08             	sub    $0x8,%esp
  801e2c:	56                   	push   %esi
  801e2d:	6a 00                	push   $0x0
  801e2f:	e8 af f8 ff ff       	call   8016e3 <sys_page_unmap>
	return r;
  801e34:	83 c4 10             	add    $0x10,%esp
  801e37:	eb ba                	jmp    801df3 <fd_close+0x3c>
			r = 0;
  801e39:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e3e:	eb e9                	jmp    801e29 <fd_close+0x72>

00801e40 <close>:

int
close(int fdnum)
{
  801e40:	55                   	push   %ebp
  801e41:	89 e5                	mov    %esp,%ebp
  801e43:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e46:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e49:	50                   	push   %eax
  801e4a:	ff 75 08             	pushl  0x8(%ebp)
  801e4d:	e8 b9 fe ff ff       	call   801d0b <fd_lookup>
  801e52:	83 c4 08             	add    $0x8,%esp
  801e55:	85 c0                	test   %eax,%eax
  801e57:	78 10                	js     801e69 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801e59:	83 ec 08             	sub    $0x8,%esp
  801e5c:	6a 01                	push   $0x1
  801e5e:	ff 75 f4             	pushl  -0xc(%ebp)
  801e61:	e8 51 ff ff ff       	call   801db7 <fd_close>
  801e66:	83 c4 10             	add    $0x10,%esp
}
  801e69:	c9                   	leave  
  801e6a:	c3                   	ret    

00801e6b <close_all>:

void
close_all(void)
{
  801e6b:	55                   	push   %ebp
  801e6c:	89 e5                	mov    %esp,%ebp
  801e6e:	53                   	push   %ebx
  801e6f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801e72:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801e77:	83 ec 0c             	sub    $0xc,%esp
  801e7a:	53                   	push   %ebx
  801e7b:	e8 c0 ff ff ff       	call   801e40 <close>
	for (i = 0; i < MAXFD; i++)
  801e80:	83 c3 01             	add    $0x1,%ebx
  801e83:	83 c4 10             	add    $0x10,%esp
  801e86:	83 fb 20             	cmp    $0x20,%ebx
  801e89:	75 ec                	jne    801e77 <close_all+0xc>
}
  801e8b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e8e:	c9                   	leave  
  801e8f:	c3                   	ret    

00801e90 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801e90:	55                   	push   %ebp
  801e91:	89 e5                	mov    %esp,%ebp
  801e93:	57                   	push   %edi
  801e94:	56                   	push   %esi
  801e95:	53                   	push   %ebx
  801e96:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801e99:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801e9c:	50                   	push   %eax
  801e9d:	ff 75 08             	pushl  0x8(%ebp)
  801ea0:	e8 66 fe ff ff       	call   801d0b <fd_lookup>
  801ea5:	89 c3                	mov    %eax,%ebx
  801ea7:	83 c4 08             	add    $0x8,%esp
  801eaa:	85 c0                	test   %eax,%eax
  801eac:	0f 88 81 00 00 00    	js     801f33 <dup+0xa3>
		return r;
	close(newfdnum);
  801eb2:	83 ec 0c             	sub    $0xc,%esp
  801eb5:	ff 75 0c             	pushl  0xc(%ebp)
  801eb8:	e8 83 ff ff ff       	call   801e40 <close>

	newfd = INDEX2FD(newfdnum);
  801ebd:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ec0:	c1 e6 0c             	shl    $0xc,%esi
  801ec3:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801ec9:	83 c4 04             	add    $0x4,%esp
  801ecc:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ecf:	e8 d1 fd ff ff       	call   801ca5 <fd2data>
  801ed4:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801ed6:	89 34 24             	mov    %esi,(%esp)
  801ed9:	e8 c7 fd ff ff       	call   801ca5 <fd2data>
  801ede:	83 c4 10             	add    $0x10,%esp
  801ee1:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801ee3:	89 d8                	mov    %ebx,%eax
  801ee5:	c1 e8 16             	shr    $0x16,%eax
  801ee8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801eef:	a8 01                	test   $0x1,%al
  801ef1:	74 11                	je     801f04 <dup+0x74>
  801ef3:	89 d8                	mov    %ebx,%eax
  801ef5:	c1 e8 0c             	shr    $0xc,%eax
  801ef8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801eff:	f6 c2 01             	test   $0x1,%dl
  801f02:	75 39                	jne    801f3d <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801f04:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801f07:	89 d0                	mov    %edx,%eax
  801f09:	c1 e8 0c             	shr    $0xc,%eax
  801f0c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801f13:	83 ec 0c             	sub    $0xc,%esp
  801f16:	25 07 0e 00 00       	and    $0xe07,%eax
  801f1b:	50                   	push   %eax
  801f1c:	56                   	push   %esi
  801f1d:	6a 00                	push   $0x0
  801f1f:	52                   	push   %edx
  801f20:	6a 00                	push   $0x0
  801f22:	e8 7a f7 ff ff       	call   8016a1 <sys_page_map>
  801f27:	89 c3                	mov    %eax,%ebx
  801f29:	83 c4 20             	add    $0x20,%esp
  801f2c:	85 c0                	test   %eax,%eax
  801f2e:	78 31                	js     801f61 <dup+0xd1>
		goto err;

	return newfdnum;
  801f30:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801f33:	89 d8                	mov    %ebx,%eax
  801f35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f38:	5b                   	pop    %ebx
  801f39:	5e                   	pop    %esi
  801f3a:	5f                   	pop    %edi
  801f3b:	5d                   	pop    %ebp
  801f3c:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801f3d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801f44:	83 ec 0c             	sub    $0xc,%esp
  801f47:	25 07 0e 00 00       	and    $0xe07,%eax
  801f4c:	50                   	push   %eax
  801f4d:	57                   	push   %edi
  801f4e:	6a 00                	push   $0x0
  801f50:	53                   	push   %ebx
  801f51:	6a 00                	push   $0x0
  801f53:	e8 49 f7 ff ff       	call   8016a1 <sys_page_map>
  801f58:	89 c3                	mov    %eax,%ebx
  801f5a:	83 c4 20             	add    $0x20,%esp
  801f5d:	85 c0                	test   %eax,%eax
  801f5f:	79 a3                	jns    801f04 <dup+0x74>
	sys_page_unmap(0, newfd);
  801f61:	83 ec 08             	sub    $0x8,%esp
  801f64:	56                   	push   %esi
  801f65:	6a 00                	push   $0x0
  801f67:	e8 77 f7 ff ff       	call   8016e3 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801f6c:	83 c4 08             	add    $0x8,%esp
  801f6f:	57                   	push   %edi
  801f70:	6a 00                	push   $0x0
  801f72:	e8 6c f7 ff ff       	call   8016e3 <sys_page_unmap>
	return r;
  801f77:	83 c4 10             	add    $0x10,%esp
  801f7a:	eb b7                	jmp    801f33 <dup+0xa3>

00801f7c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801f7c:	55                   	push   %ebp
  801f7d:	89 e5                	mov    %esp,%ebp
  801f7f:	53                   	push   %ebx
  801f80:	83 ec 14             	sub    $0x14,%esp
  801f83:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801f86:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f89:	50                   	push   %eax
  801f8a:	53                   	push   %ebx
  801f8b:	e8 7b fd ff ff       	call   801d0b <fd_lookup>
  801f90:	83 c4 08             	add    $0x8,%esp
  801f93:	85 c0                	test   %eax,%eax
  801f95:	78 3f                	js     801fd6 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f97:	83 ec 08             	sub    $0x8,%esp
  801f9a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f9d:	50                   	push   %eax
  801f9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fa1:	ff 30                	pushl  (%eax)
  801fa3:	e8 b9 fd ff ff       	call   801d61 <dev_lookup>
  801fa8:	83 c4 10             	add    $0x10,%esp
  801fab:	85 c0                	test   %eax,%eax
  801fad:	78 27                	js     801fd6 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801faf:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801fb2:	8b 42 08             	mov    0x8(%edx),%eax
  801fb5:	83 e0 03             	and    $0x3,%eax
  801fb8:	83 f8 01             	cmp    $0x1,%eax
  801fbb:	74 1e                	je     801fdb <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801fbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fc0:	8b 40 08             	mov    0x8(%eax),%eax
  801fc3:	85 c0                	test   %eax,%eax
  801fc5:	74 35                	je     801ffc <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801fc7:	83 ec 04             	sub    $0x4,%esp
  801fca:	ff 75 10             	pushl  0x10(%ebp)
  801fcd:	ff 75 0c             	pushl  0xc(%ebp)
  801fd0:	52                   	push   %edx
  801fd1:	ff d0                	call   *%eax
  801fd3:	83 c4 10             	add    $0x10,%esp
}
  801fd6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fd9:	c9                   	leave  
  801fda:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801fdb:	a1 24 54 80 00       	mov    0x805424,%eax
  801fe0:	8b 40 48             	mov    0x48(%eax),%eax
  801fe3:	83 ec 04             	sub    $0x4,%esp
  801fe6:	53                   	push   %ebx
  801fe7:	50                   	push   %eax
  801fe8:	68 51 39 80 00       	push   $0x803951
  801fed:	e8 64 eb ff ff       	call   800b56 <cprintf>
		return -E_INVAL;
  801ff2:	83 c4 10             	add    $0x10,%esp
  801ff5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801ffa:	eb da                	jmp    801fd6 <read+0x5a>
		return -E_NOT_SUPP;
  801ffc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802001:	eb d3                	jmp    801fd6 <read+0x5a>

00802003 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802003:	55                   	push   %ebp
  802004:	89 e5                	mov    %esp,%ebp
  802006:	57                   	push   %edi
  802007:	56                   	push   %esi
  802008:	53                   	push   %ebx
  802009:	83 ec 0c             	sub    $0xc,%esp
  80200c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80200f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802012:	bb 00 00 00 00       	mov    $0x0,%ebx
  802017:	39 f3                	cmp    %esi,%ebx
  802019:	73 25                	jae    802040 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80201b:	83 ec 04             	sub    $0x4,%esp
  80201e:	89 f0                	mov    %esi,%eax
  802020:	29 d8                	sub    %ebx,%eax
  802022:	50                   	push   %eax
  802023:	89 d8                	mov    %ebx,%eax
  802025:	03 45 0c             	add    0xc(%ebp),%eax
  802028:	50                   	push   %eax
  802029:	57                   	push   %edi
  80202a:	e8 4d ff ff ff       	call   801f7c <read>
		if (m < 0)
  80202f:	83 c4 10             	add    $0x10,%esp
  802032:	85 c0                	test   %eax,%eax
  802034:	78 08                	js     80203e <readn+0x3b>
			return m;
		if (m == 0)
  802036:	85 c0                	test   %eax,%eax
  802038:	74 06                	je     802040 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  80203a:	01 c3                	add    %eax,%ebx
  80203c:	eb d9                	jmp    802017 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80203e:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  802040:	89 d8                	mov    %ebx,%eax
  802042:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802045:	5b                   	pop    %ebx
  802046:	5e                   	pop    %esi
  802047:	5f                   	pop    %edi
  802048:	5d                   	pop    %ebp
  802049:	c3                   	ret    

0080204a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80204a:	55                   	push   %ebp
  80204b:	89 e5                	mov    %esp,%ebp
  80204d:	53                   	push   %ebx
  80204e:	83 ec 14             	sub    $0x14,%esp
  802051:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802054:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802057:	50                   	push   %eax
  802058:	53                   	push   %ebx
  802059:	e8 ad fc ff ff       	call   801d0b <fd_lookup>
  80205e:	83 c4 08             	add    $0x8,%esp
  802061:	85 c0                	test   %eax,%eax
  802063:	78 3a                	js     80209f <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802065:	83 ec 08             	sub    $0x8,%esp
  802068:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80206b:	50                   	push   %eax
  80206c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80206f:	ff 30                	pushl  (%eax)
  802071:	e8 eb fc ff ff       	call   801d61 <dev_lookup>
  802076:	83 c4 10             	add    $0x10,%esp
  802079:	85 c0                	test   %eax,%eax
  80207b:	78 22                	js     80209f <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80207d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802080:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802084:	74 1e                	je     8020a4 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802086:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802089:	8b 52 0c             	mov    0xc(%edx),%edx
  80208c:	85 d2                	test   %edx,%edx
  80208e:	74 35                	je     8020c5 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802090:	83 ec 04             	sub    $0x4,%esp
  802093:	ff 75 10             	pushl  0x10(%ebp)
  802096:	ff 75 0c             	pushl  0xc(%ebp)
  802099:	50                   	push   %eax
  80209a:	ff d2                	call   *%edx
  80209c:	83 c4 10             	add    $0x10,%esp
}
  80209f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020a2:	c9                   	leave  
  8020a3:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8020a4:	a1 24 54 80 00       	mov    0x805424,%eax
  8020a9:	8b 40 48             	mov    0x48(%eax),%eax
  8020ac:	83 ec 04             	sub    $0x4,%esp
  8020af:	53                   	push   %ebx
  8020b0:	50                   	push   %eax
  8020b1:	68 6d 39 80 00       	push   $0x80396d
  8020b6:	e8 9b ea ff ff       	call   800b56 <cprintf>
		return -E_INVAL;
  8020bb:	83 c4 10             	add    $0x10,%esp
  8020be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8020c3:	eb da                	jmp    80209f <write+0x55>
		return -E_NOT_SUPP;
  8020c5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8020ca:	eb d3                	jmp    80209f <write+0x55>

008020cc <seek>:

int
seek(int fdnum, off_t offset)
{
  8020cc:	55                   	push   %ebp
  8020cd:	89 e5                	mov    %esp,%ebp
  8020cf:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020d2:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8020d5:	50                   	push   %eax
  8020d6:	ff 75 08             	pushl  0x8(%ebp)
  8020d9:	e8 2d fc ff ff       	call   801d0b <fd_lookup>
  8020de:	83 c4 08             	add    $0x8,%esp
  8020e1:	85 c0                	test   %eax,%eax
  8020e3:	78 0e                	js     8020f3 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8020e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8020eb:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8020ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020f3:	c9                   	leave  
  8020f4:	c3                   	ret    

008020f5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8020f5:	55                   	push   %ebp
  8020f6:	89 e5                	mov    %esp,%ebp
  8020f8:	53                   	push   %ebx
  8020f9:	83 ec 14             	sub    $0x14,%esp
  8020fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8020ff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802102:	50                   	push   %eax
  802103:	53                   	push   %ebx
  802104:	e8 02 fc ff ff       	call   801d0b <fd_lookup>
  802109:	83 c4 08             	add    $0x8,%esp
  80210c:	85 c0                	test   %eax,%eax
  80210e:	78 37                	js     802147 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802110:	83 ec 08             	sub    $0x8,%esp
  802113:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802116:	50                   	push   %eax
  802117:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80211a:	ff 30                	pushl  (%eax)
  80211c:	e8 40 fc ff ff       	call   801d61 <dev_lookup>
  802121:	83 c4 10             	add    $0x10,%esp
  802124:	85 c0                	test   %eax,%eax
  802126:	78 1f                	js     802147 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802128:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80212b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80212f:	74 1b                	je     80214c <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  802131:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802134:	8b 52 18             	mov    0x18(%edx),%edx
  802137:	85 d2                	test   %edx,%edx
  802139:	74 32                	je     80216d <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80213b:	83 ec 08             	sub    $0x8,%esp
  80213e:	ff 75 0c             	pushl  0xc(%ebp)
  802141:	50                   	push   %eax
  802142:	ff d2                	call   *%edx
  802144:	83 c4 10             	add    $0x10,%esp
}
  802147:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80214a:	c9                   	leave  
  80214b:	c3                   	ret    
			thisenv->env_id, fdnum);
  80214c:	a1 24 54 80 00       	mov    0x805424,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802151:	8b 40 48             	mov    0x48(%eax),%eax
  802154:	83 ec 04             	sub    $0x4,%esp
  802157:	53                   	push   %ebx
  802158:	50                   	push   %eax
  802159:	68 30 39 80 00       	push   $0x803930
  80215e:	e8 f3 e9 ff ff       	call   800b56 <cprintf>
		return -E_INVAL;
  802163:	83 c4 10             	add    $0x10,%esp
  802166:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80216b:	eb da                	jmp    802147 <ftruncate+0x52>
		return -E_NOT_SUPP;
  80216d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802172:	eb d3                	jmp    802147 <ftruncate+0x52>

00802174 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802174:	55                   	push   %ebp
  802175:	89 e5                	mov    %esp,%ebp
  802177:	53                   	push   %ebx
  802178:	83 ec 14             	sub    $0x14,%esp
  80217b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80217e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802181:	50                   	push   %eax
  802182:	ff 75 08             	pushl  0x8(%ebp)
  802185:	e8 81 fb ff ff       	call   801d0b <fd_lookup>
  80218a:	83 c4 08             	add    $0x8,%esp
  80218d:	85 c0                	test   %eax,%eax
  80218f:	78 4b                	js     8021dc <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802191:	83 ec 08             	sub    $0x8,%esp
  802194:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802197:	50                   	push   %eax
  802198:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80219b:	ff 30                	pushl  (%eax)
  80219d:	e8 bf fb ff ff       	call   801d61 <dev_lookup>
  8021a2:	83 c4 10             	add    $0x10,%esp
  8021a5:	85 c0                	test   %eax,%eax
  8021a7:	78 33                	js     8021dc <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  8021a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021ac:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8021b0:	74 2f                	je     8021e1 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8021b2:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8021b5:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8021bc:	00 00 00 
	stat->st_isdir = 0;
  8021bf:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8021c6:	00 00 00 
	stat->st_dev = dev;
  8021c9:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8021cf:	83 ec 08             	sub    $0x8,%esp
  8021d2:	53                   	push   %ebx
  8021d3:	ff 75 f0             	pushl  -0x10(%ebp)
  8021d6:	ff 50 14             	call   *0x14(%eax)
  8021d9:	83 c4 10             	add    $0x10,%esp
}
  8021dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8021df:	c9                   	leave  
  8021e0:	c3                   	ret    
		return -E_NOT_SUPP;
  8021e1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8021e6:	eb f4                	jmp    8021dc <fstat+0x68>

008021e8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8021e8:	55                   	push   %ebp
  8021e9:	89 e5                	mov    %esp,%ebp
  8021eb:	56                   	push   %esi
  8021ec:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8021ed:	83 ec 08             	sub    $0x8,%esp
  8021f0:	6a 00                	push   $0x0
  8021f2:	ff 75 08             	pushl  0x8(%ebp)
  8021f5:	e8 da 01 00 00       	call   8023d4 <open>
  8021fa:	89 c3                	mov    %eax,%ebx
  8021fc:	83 c4 10             	add    $0x10,%esp
  8021ff:	85 c0                	test   %eax,%eax
  802201:	78 1b                	js     80221e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802203:	83 ec 08             	sub    $0x8,%esp
  802206:	ff 75 0c             	pushl  0xc(%ebp)
  802209:	50                   	push   %eax
  80220a:	e8 65 ff ff ff       	call   802174 <fstat>
  80220f:	89 c6                	mov    %eax,%esi
	close(fd);
  802211:	89 1c 24             	mov    %ebx,(%esp)
  802214:	e8 27 fc ff ff       	call   801e40 <close>
	return r;
  802219:	83 c4 10             	add    $0x10,%esp
  80221c:	89 f3                	mov    %esi,%ebx
}
  80221e:	89 d8                	mov    %ebx,%eax
  802220:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802223:	5b                   	pop    %ebx
  802224:	5e                   	pop    %esi
  802225:	5d                   	pop    %ebp
  802226:	c3                   	ret    

00802227 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802227:	55                   	push   %ebp
  802228:	89 e5                	mov    %esp,%ebp
  80222a:	56                   	push   %esi
  80222b:	53                   	push   %ebx
  80222c:	89 c6                	mov    %eax,%esi
  80222e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  802230:	83 3d 20 54 80 00 00 	cmpl   $0x0,0x805420
  802237:	74 27                	je     802260 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802239:	6a 07                	push   $0x7
  80223b:	68 00 60 80 00       	push   $0x806000
  802240:	56                   	push   %esi
  802241:	ff 35 20 54 80 00    	pushl  0x805420
  802247:	e8 be 0d 00 00       	call   80300a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80224c:	83 c4 0c             	add    $0xc,%esp
  80224f:	6a 00                	push   $0x0
  802251:	53                   	push   %ebx
  802252:	6a 00                	push   $0x0
  802254:	e8 4a 0d 00 00       	call   802fa3 <ipc_recv>
}
  802259:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80225c:	5b                   	pop    %ebx
  80225d:	5e                   	pop    %esi
  80225e:	5d                   	pop    %ebp
  80225f:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802260:	83 ec 0c             	sub    $0xc,%esp
  802263:	6a 01                	push   $0x1
  802265:	e8 f4 0d 00 00       	call   80305e <ipc_find_env>
  80226a:	a3 20 54 80 00       	mov    %eax,0x805420
  80226f:	83 c4 10             	add    $0x10,%esp
  802272:	eb c5                	jmp    802239 <fsipc+0x12>

00802274 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802274:	55                   	push   %ebp
  802275:	89 e5                	mov    %esp,%ebp
  802277:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80227a:	8b 45 08             	mov    0x8(%ebp),%eax
  80227d:	8b 40 0c             	mov    0xc(%eax),%eax
  802280:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  802285:	8b 45 0c             	mov    0xc(%ebp),%eax
  802288:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80228d:	ba 00 00 00 00       	mov    $0x0,%edx
  802292:	b8 02 00 00 00       	mov    $0x2,%eax
  802297:	e8 8b ff ff ff       	call   802227 <fsipc>
}
  80229c:	c9                   	leave  
  80229d:	c3                   	ret    

0080229e <devfile_flush>:
{
  80229e:	55                   	push   %ebp
  80229f:	89 e5                	mov    %esp,%ebp
  8022a1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8022a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8022a7:	8b 40 0c             	mov    0xc(%eax),%eax
  8022aa:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  8022af:	ba 00 00 00 00       	mov    $0x0,%edx
  8022b4:	b8 06 00 00 00       	mov    $0x6,%eax
  8022b9:	e8 69 ff ff ff       	call   802227 <fsipc>
}
  8022be:	c9                   	leave  
  8022bf:	c3                   	ret    

008022c0 <devfile_stat>:
{
  8022c0:	55                   	push   %ebp
  8022c1:	89 e5                	mov    %esp,%ebp
  8022c3:	53                   	push   %ebx
  8022c4:	83 ec 04             	sub    $0x4,%esp
  8022c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8022ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8022cd:	8b 40 0c             	mov    0xc(%eax),%eax
  8022d0:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8022d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8022da:	b8 05 00 00 00       	mov    $0x5,%eax
  8022df:	e8 43 ff ff ff       	call   802227 <fsipc>
  8022e4:	85 c0                	test   %eax,%eax
  8022e6:	78 2c                	js     802314 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8022e8:	83 ec 08             	sub    $0x8,%esp
  8022eb:	68 00 60 80 00       	push   $0x806000
  8022f0:	53                   	push   %ebx
  8022f1:	e8 6f ef ff ff       	call   801265 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8022f6:	a1 80 60 80 00       	mov    0x806080,%eax
  8022fb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802301:	a1 84 60 80 00       	mov    0x806084,%eax
  802306:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80230c:	83 c4 10             	add    $0x10,%esp
  80230f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802314:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802317:	c9                   	leave  
  802318:	c3                   	ret    

00802319 <devfile_write>:
{
  802319:	55                   	push   %ebp
  80231a:	89 e5                	mov    %esp,%ebp
  80231c:	83 ec 0c             	sub    $0xc,%esp
  80231f:	8b 45 10             	mov    0x10(%ebp),%eax
    	fsipcbuf.write.req_fileid = fd->fd_file.id;
  802322:	8b 55 08             	mov    0x8(%ebp),%edx
  802325:	8b 52 0c             	mov    0xc(%edx),%edx
  802328:	89 15 00 60 80 00    	mov    %edx,0x806000
    	fsipcbuf.write.req_n = n;
  80232e:	a3 04 60 80 00       	mov    %eax,0x806004
    	memmove(fsipcbuf.write.req_buf, buf, n);
  802333:	50                   	push   %eax
  802334:	ff 75 0c             	pushl  0xc(%ebp)
  802337:	68 08 60 80 00       	push   $0x806008
  80233c:	e8 b2 f0 ff ff       	call   8013f3 <memmove>
    	return fsipc(FSREQ_WRITE, NULL);
  802341:	ba 00 00 00 00       	mov    $0x0,%edx
  802346:	b8 04 00 00 00       	mov    $0x4,%eax
  80234b:	e8 d7 fe ff ff       	call   802227 <fsipc>
}
  802350:	c9                   	leave  
  802351:	c3                   	ret    

00802352 <devfile_read>:
{
  802352:	55                   	push   %ebp
  802353:	89 e5                	mov    %esp,%ebp
  802355:	56                   	push   %esi
  802356:	53                   	push   %ebx
  802357:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80235a:	8b 45 08             	mov    0x8(%ebp),%eax
  80235d:	8b 40 0c             	mov    0xc(%eax),%eax
  802360:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  802365:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80236b:	ba 00 00 00 00       	mov    $0x0,%edx
  802370:	b8 03 00 00 00       	mov    $0x3,%eax
  802375:	e8 ad fe ff ff       	call   802227 <fsipc>
  80237a:	89 c3                	mov    %eax,%ebx
  80237c:	85 c0                	test   %eax,%eax
  80237e:	78 1f                	js     80239f <devfile_read+0x4d>
	assert(r <= n);
  802380:	39 f0                	cmp    %esi,%eax
  802382:	77 24                	ja     8023a8 <devfile_read+0x56>
	assert(r <= PGSIZE);
  802384:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802389:	7f 33                	jg     8023be <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80238b:	83 ec 04             	sub    $0x4,%esp
  80238e:	50                   	push   %eax
  80238f:	68 00 60 80 00       	push   $0x806000
  802394:	ff 75 0c             	pushl  0xc(%ebp)
  802397:	e8 57 f0 ff ff       	call   8013f3 <memmove>
	return r;
  80239c:	83 c4 10             	add    $0x10,%esp
}
  80239f:	89 d8                	mov    %ebx,%eax
  8023a1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023a4:	5b                   	pop    %ebx
  8023a5:	5e                   	pop    %esi
  8023a6:	5d                   	pop    %ebp
  8023a7:	c3                   	ret    
	assert(r <= n);
  8023a8:	68 9c 39 80 00       	push   $0x80399c
  8023ad:	68 51 34 80 00       	push   $0x803451
  8023b2:	6a 7c                	push   $0x7c
  8023b4:	68 a3 39 80 00       	push   $0x8039a3
  8023b9:	e8 bd e6 ff ff       	call   800a7b <_panic>
	assert(r <= PGSIZE);
  8023be:	68 ae 39 80 00       	push   $0x8039ae
  8023c3:	68 51 34 80 00       	push   $0x803451
  8023c8:	6a 7d                	push   $0x7d
  8023ca:	68 a3 39 80 00       	push   $0x8039a3
  8023cf:	e8 a7 e6 ff ff       	call   800a7b <_panic>

008023d4 <open>:
{
  8023d4:	55                   	push   %ebp
  8023d5:	89 e5                	mov    %esp,%ebp
  8023d7:	56                   	push   %esi
  8023d8:	53                   	push   %ebx
  8023d9:	83 ec 1c             	sub    $0x1c,%esp
  8023dc:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8023df:	56                   	push   %esi
  8023e0:	e8 49 ee ff ff       	call   80122e <strlen>
  8023e5:	83 c4 10             	add    $0x10,%esp
  8023e8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8023ed:	7f 6c                	jg     80245b <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8023ef:	83 ec 0c             	sub    $0xc,%esp
  8023f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023f5:	50                   	push   %eax
  8023f6:	e8 c1 f8 ff ff       	call   801cbc <fd_alloc>
  8023fb:	89 c3                	mov    %eax,%ebx
  8023fd:	83 c4 10             	add    $0x10,%esp
  802400:	85 c0                	test   %eax,%eax
  802402:	78 3c                	js     802440 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  802404:	83 ec 08             	sub    $0x8,%esp
  802407:	56                   	push   %esi
  802408:	68 00 60 80 00       	push   $0x806000
  80240d:	e8 53 ee ff ff       	call   801265 <strcpy>
	fsipcbuf.open.req_omode = mode;
  802412:	8b 45 0c             	mov    0xc(%ebp),%eax
  802415:	a3 00 64 80 00       	mov    %eax,0x806400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80241a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80241d:	b8 01 00 00 00       	mov    $0x1,%eax
  802422:	e8 00 fe ff ff       	call   802227 <fsipc>
  802427:	89 c3                	mov    %eax,%ebx
  802429:	83 c4 10             	add    $0x10,%esp
  80242c:	85 c0                	test   %eax,%eax
  80242e:	78 19                	js     802449 <open+0x75>
	return fd2num(fd);
  802430:	83 ec 0c             	sub    $0xc,%esp
  802433:	ff 75 f4             	pushl  -0xc(%ebp)
  802436:	e8 5a f8 ff ff       	call   801c95 <fd2num>
  80243b:	89 c3                	mov    %eax,%ebx
  80243d:	83 c4 10             	add    $0x10,%esp
}
  802440:	89 d8                	mov    %ebx,%eax
  802442:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802445:	5b                   	pop    %ebx
  802446:	5e                   	pop    %esi
  802447:	5d                   	pop    %ebp
  802448:	c3                   	ret    
		fd_close(fd, 0);
  802449:	83 ec 08             	sub    $0x8,%esp
  80244c:	6a 00                	push   $0x0
  80244e:	ff 75 f4             	pushl  -0xc(%ebp)
  802451:	e8 61 f9 ff ff       	call   801db7 <fd_close>
		return r;
  802456:	83 c4 10             	add    $0x10,%esp
  802459:	eb e5                	jmp    802440 <open+0x6c>
		return -E_BAD_PATH;
  80245b:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  802460:	eb de                	jmp    802440 <open+0x6c>

00802462 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  802462:	55                   	push   %ebp
  802463:	89 e5                	mov    %esp,%ebp
  802465:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  802468:	ba 00 00 00 00       	mov    $0x0,%edx
  80246d:	b8 08 00 00 00       	mov    $0x8,%eax
  802472:	e8 b0 fd ff ff       	call   802227 <fsipc>
}
  802477:	c9                   	leave  
  802478:	c3                   	ret    

00802479 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  802479:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80247d:	7e 38                	jle    8024b7 <writebuf+0x3e>
{
  80247f:	55                   	push   %ebp
  802480:	89 e5                	mov    %esp,%ebp
  802482:	53                   	push   %ebx
  802483:	83 ec 08             	sub    $0x8,%esp
  802486:	89 c3                	mov    %eax,%ebx
		ssize_t result = write(b->fd, b->buf, b->idx);
  802488:	ff 70 04             	pushl  0x4(%eax)
  80248b:	8d 40 10             	lea    0x10(%eax),%eax
  80248e:	50                   	push   %eax
  80248f:	ff 33                	pushl  (%ebx)
  802491:	e8 b4 fb ff ff       	call   80204a <write>
		if (result > 0)
  802496:	83 c4 10             	add    $0x10,%esp
  802499:	85 c0                	test   %eax,%eax
  80249b:	7e 03                	jle    8024a0 <writebuf+0x27>
			b->result += result;
  80249d:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8024a0:	39 43 04             	cmp    %eax,0x4(%ebx)
  8024a3:	74 0d                	je     8024b2 <writebuf+0x39>
			b->error = (result < 0 ? result : 0);
  8024a5:	85 c0                	test   %eax,%eax
  8024a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8024ac:	0f 4f c2             	cmovg  %edx,%eax
  8024af:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8024b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8024b5:	c9                   	leave  
  8024b6:	c3                   	ret    
  8024b7:	f3 c3                	repz ret 

008024b9 <putch>:

static void
putch(int ch, void *thunk)
{
  8024b9:	55                   	push   %ebp
  8024ba:	89 e5                	mov    %esp,%ebp
  8024bc:	53                   	push   %ebx
  8024bd:	83 ec 04             	sub    $0x4,%esp
  8024c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8024c3:	8b 53 04             	mov    0x4(%ebx),%edx
  8024c6:	8d 42 01             	lea    0x1(%edx),%eax
  8024c9:	89 43 04             	mov    %eax,0x4(%ebx)
  8024cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8024cf:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8024d3:	3d 00 01 00 00       	cmp    $0x100,%eax
  8024d8:	74 06                	je     8024e0 <putch+0x27>
		writebuf(b);
		b->idx = 0;
	}
}
  8024da:	83 c4 04             	add    $0x4,%esp
  8024dd:	5b                   	pop    %ebx
  8024de:	5d                   	pop    %ebp
  8024df:	c3                   	ret    
		writebuf(b);
  8024e0:	89 d8                	mov    %ebx,%eax
  8024e2:	e8 92 ff ff ff       	call   802479 <writebuf>
		b->idx = 0;
  8024e7:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
}
  8024ee:	eb ea                	jmp    8024da <putch+0x21>

008024f0 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8024f0:	55                   	push   %ebp
  8024f1:	89 e5                	mov    %esp,%ebp
  8024f3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8024f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8024fc:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  802502:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  802509:	00 00 00 
	b.result = 0;
  80250c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  802513:	00 00 00 
	b.error = 1;
  802516:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  80251d:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  802520:	ff 75 10             	pushl  0x10(%ebp)
  802523:	ff 75 0c             	pushl  0xc(%ebp)
  802526:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80252c:	50                   	push   %eax
  80252d:	68 b9 24 80 00       	push   $0x8024b9
  802532:	e8 1c e7 ff ff       	call   800c53 <vprintfmt>
	if (b.idx > 0)
  802537:	83 c4 10             	add    $0x10,%esp
  80253a:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  802541:	7f 11                	jg     802554 <vfprintf+0x64>
		writebuf(&b);

	return (b.result ? b.result : b.error);
  802543:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  802549:	85 c0                	test   %eax,%eax
  80254b:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  802552:	c9                   	leave  
  802553:	c3                   	ret    
		writebuf(&b);
  802554:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80255a:	e8 1a ff ff ff       	call   802479 <writebuf>
  80255f:	eb e2                	jmp    802543 <vfprintf+0x53>

00802561 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  802561:	55                   	push   %ebp
  802562:	89 e5                	mov    %esp,%ebp
  802564:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  802567:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  80256a:	50                   	push   %eax
  80256b:	ff 75 0c             	pushl  0xc(%ebp)
  80256e:	ff 75 08             	pushl  0x8(%ebp)
  802571:	e8 7a ff ff ff       	call   8024f0 <vfprintf>
	va_end(ap);

	return cnt;
}
  802576:	c9                   	leave  
  802577:	c3                   	ret    

00802578 <printf>:

int
printf(const char *fmt, ...)
{
  802578:	55                   	push   %ebp
  802579:	89 e5                	mov    %esp,%ebp
  80257b:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80257e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  802581:	50                   	push   %eax
  802582:	ff 75 08             	pushl  0x8(%ebp)
  802585:	6a 01                	push   $0x1
  802587:	e8 64 ff ff ff       	call   8024f0 <vfprintf>
	va_end(ap);

	return cnt;
}
  80258c:	c9                   	leave  
  80258d:	c3                   	ret    

0080258e <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  80258e:	55                   	push   %ebp
  80258f:	89 e5                	mov    %esp,%ebp
  802591:	57                   	push   %edi
  802592:	56                   	push   %esi
  802593:	53                   	push   %ebx
  802594:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  80259a:	6a 00                	push   $0x0
  80259c:	ff 75 08             	pushl  0x8(%ebp)
  80259f:	e8 30 fe ff ff       	call   8023d4 <open>
  8025a4:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  8025aa:	83 c4 10             	add    $0x10,%esp
  8025ad:	85 c0                	test   %eax,%eax
  8025af:	0f 88 40 03 00 00    	js     8028f5 <spawn+0x367>
  8025b5:	89 c7                	mov    %eax,%edi
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8025b7:	83 ec 04             	sub    $0x4,%esp
  8025ba:	68 00 02 00 00       	push   $0x200
  8025bf:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8025c5:	50                   	push   %eax
  8025c6:	57                   	push   %edi
  8025c7:	e8 37 fa ff ff       	call   802003 <readn>
  8025cc:	83 c4 10             	add    $0x10,%esp
  8025cf:	3d 00 02 00 00       	cmp    $0x200,%eax
  8025d4:	75 5d                	jne    802633 <spawn+0xa5>
	    || elf->e_magic != ELF_MAGIC) {
  8025d6:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8025dd:	45 4c 46 
  8025e0:	75 51                	jne    802633 <spawn+0xa5>
  8025e2:	b8 07 00 00 00       	mov    $0x7,%eax
  8025e7:	cd 30                	int    $0x30
  8025e9:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8025ef:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8025f5:	85 c0                	test   %eax,%eax
  8025f7:	0f 88 a5 04 00 00    	js     802aa2 <spawn+0x514>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8025fd:	25 ff 03 00 00       	and    $0x3ff,%eax
  802602:	6b f0 7c             	imul   $0x7c,%eax,%esi
  802605:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  80260b:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  802611:	b9 11 00 00 00       	mov    $0x11,%ecx
  802616:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  802618:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  80261e:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802624:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  802629:	be 00 00 00 00       	mov    $0x0,%esi
  80262e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802631:	eb 4b                	jmp    80267e <spawn+0xf0>
		close(fd);
  802633:	83 ec 0c             	sub    $0xc,%esp
  802636:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  80263c:	e8 ff f7 ff ff       	call   801e40 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  802641:	83 c4 0c             	add    $0xc,%esp
  802644:	68 7f 45 4c 46       	push   $0x464c457f
  802649:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  80264f:	68 ba 39 80 00       	push   $0x8039ba
  802654:	e8 fd e4 ff ff       	call   800b56 <cprintf>
		return -E_NOT_EXEC;
  802659:	83 c4 10             	add    $0x10,%esp
  80265c:	c7 85 90 fd ff ff f2 	movl   $0xfffffff2,-0x270(%ebp)
  802663:	ff ff ff 
  802666:	e9 8a 02 00 00       	jmp    8028f5 <spawn+0x367>
		string_size += strlen(argv[argc]) + 1;
  80266b:	83 ec 0c             	sub    $0xc,%esp
  80266e:	50                   	push   %eax
  80266f:	e8 ba eb ff ff       	call   80122e <strlen>
  802674:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  802678:	83 c3 01             	add    $0x1,%ebx
  80267b:	83 c4 10             	add    $0x10,%esp
  80267e:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  802685:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  802688:	85 c0                	test   %eax,%eax
  80268a:	75 df                	jne    80266b <spawn+0xdd>
  80268c:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  802692:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  802698:	bf 00 10 40 00       	mov    $0x401000,%edi
  80269d:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  80269f:	89 fa                	mov    %edi,%edx
  8026a1:	83 e2 fc             	and    $0xfffffffc,%edx
  8026a4:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8026ab:	29 c2                	sub    %eax,%edx
  8026ad:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8026b3:	8d 42 f8             	lea    -0x8(%edx),%eax
  8026b6:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8026bb:	0f 86 f2 03 00 00    	jbe    802ab3 <spawn+0x525>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8026c1:	83 ec 04             	sub    $0x4,%esp
  8026c4:	6a 07                	push   $0x7
  8026c6:	68 00 00 40 00       	push   $0x400000
  8026cb:	6a 00                	push   $0x0
  8026cd:	e8 8c ef ff ff       	call   80165e <sys_page_alloc>
  8026d2:	83 c4 10             	add    $0x10,%esp
  8026d5:	85 c0                	test   %eax,%eax
  8026d7:	0f 88 db 03 00 00    	js     802ab8 <spawn+0x52a>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  8026dd:	be 00 00 00 00       	mov    $0x0,%esi
  8026e2:	89 9d 8c fd ff ff    	mov    %ebx,-0x274(%ebp)
  8026e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8026eb:	eb 30                	jmp    80271d <spawn+0x18f>
		argv_store[i] = UTEMP2USTACK(string_store);
  8026ed:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8026f3:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  8026f9:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  8026fc:	83 ec 08             	sub    $0x8,%esp
  8026ff:	ff 34 b3             	pushl  (%ebx,%esi,4)
  802702:	57                   	push   %edi
  802703:	e8 5d eb ff ff       	call   801265 <strcpy>
		string_store += strlen(argv[i]) + 1;
  802708:	83 c4 04             	add    $0x4,%esp
  80270b:	ff 34 b3             	pushl  (%ebx,%esi,4)
  80270e:	e8 1b eb ff ff       	call   80122e <strlen>
  802713:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  802717:	83 c6 01             	add    $0x1,%esi
  80271a:	83 c4 10             	add    $0x10,%esp
  80271d:	39 b5 8c fd ff ff    	cmp    %esi,-0x274(%ebp)
  802723:	7f c8                	jg     8026ed <spawn+0x15f>
	}
	argv_store[argc] = 0;
  802725:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  80272b:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  802731:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  802738:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  80273e:	0f 85 8c 00 00 00    	jne    8027d0 <spawn+0x242>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  802744:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  80274a:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  802750:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  802753:	89 f8                	mov    %edi,%eax
  802755:	8b bd 88 fd ff ff    	mov    -0x278(%ebp),%edi
  80275b:	89 78 f8             	mov    %edi,-0x8(%eax)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  80275e:	2d 08 30 80 11       	sub    $0x11803008,%eax
  802763:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  802769:	83 ec 0c             	sub    $0xc,%esp
  80276c:	6a 07                	push   $0x7
  80276e:	68 00 d0 bf ee       	push   $0xeebfd000
  802773:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802779:	68 00 00 40 00       	push   $0x400000
  80277e:	6a 00                	push   $0x0
  802780:	e8 1c ef ff ff       	call   8016a1 <sys_page_map>
  802785:	89 c3                	mov    %eax,%ebx
  802787:	83 c4 20             	add    $0x20,%esp
  80278a:	85 c0                	test   %eax,%eax
  80278c:	0f 88 46 03 00 00    	js     802ad8 <spawn+0x54a>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  802792:	83 ec 08             	sub    $0x8,%esp
  802795:	68 00 00 40 00       	push   $0x400000
  80279a:	6a 00                	push   $0x0
  80279c:	e8 42 ef ff ff       	call   8016e3 <sys_page_unmap>
  8027a1:	89 c3                	mov    %eax,%ebx
  8027a3:	83 c4 10             	add    $0x10,%esp
  8027a6:	85 c0                	test   %eax,%eax
  8027a8:	0f 88 2a 03 00 00    	js     802ad8 <spawn+0x54a>
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8027ae:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  8027b4:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  8027bb:	89 85 78 fd ff ff    	mov    %eax,-0x288(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8027c1:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  8027c8:	00 00 00 
  8027cb:	e9 56 01 00 00       	jmp    802926 <spawn+0x398>
	assert(string_store == (char*)UTEMP + PGSIZE);
  8027d0:	68 30 3a 80 00       	push   $0x803a30
  8027d5:	68 51 34 80 00       	push   $0x803451
  8027da:	68 f2 00 00 00       	push   $0xf2
  8027df:	68 d4 39 80 00       	push   $0x8039d4
  8027e4:	e8 92 e2 ff ff       	call   800a7b <_panic>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8027e9:	83 ec 04             	sub    $0x4,%esp
  8027ec:	6a 07                	push   $0x7
  8027ee:	68 00 00 40 00       	push   $0x400000
  8027f3:	6a 00                	push   $0x0
  8027f5:	e8 64 ee ff ff       	call   80165e <sys_page_alloc>
  8027fa:	83 c4 10             	add    $0x10,%esp
  8027fd:	85 c0                	test   %eax,%eax
  8027ff:	0f 88 be 02 00 00    	js     802ac3 <spawn+0x535>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802805:	83 ec 08             	sub    $0x8,%esp
  802808:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  80280e:	01 f0                	add    %esi,%eax
  802810:	50                   	push   %eax
  802811:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  802817:	e8 b0 f8 ff ff       	call   8020cc <seek>
  80281c:	83 c4 10             	add    $0x10,%esp
  80281f:	85 c0                	test   %eax,%eax
  802821:	0f 88 a3 02 00 00    	js     802aca <spawn+0x53c>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802827:	83 ec 04             	sub    $0x4,%esp
  80282a:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802830:	29 f0                	sub    %esi,%eax
  802832:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802837:	b9 00 10 00 00       	mov    $0x1000,%ecx
  80283c:	0f 47 c1             	cmova  %ecx,%eax
  80283f:	50                   	push   %eax
  802840:	68 00 00 40 00       	push   $0x400000
  802845:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  80284b:	e8 b3 f7 ff ff       	call   802003 <readn>
  802850:	83 c4 10             	add    $0x10,%esp
  802853:	85 c0                	test   %eax,%eax
  802855:	0f 88 76 02 00 00    	js     802ad1 <spawn+0x543>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  80285b:	83 ec 0c             	sub    $0xc,%esp
  80285e:	57                   	push   %edi
  80285f:	03 b5 88 fd ff ff    	add    -0x278(%ebp),%esi
  802865:	56                   	push   %esi
  802866:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  80286c:	68 00 00 40 00       	push   $0x400000
  802871:	6a 00                	push   $0x0
  802873:	e8 29 ee ff ff       	call   8016a1 <sys_page_map>
  802878:	83 c4 20             	add    $0x20,%esp
  80287b:	85 c0                	test   %eax,%eax
  80287d:	0f 88 80 00 00 00    	js     802903 <spawn+0x375>
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
  802883:	83 ec 08             	sub    $0x8,%esp
  802886:	68 00 00 40 00       	push   $0x400000
  80288b:	6a 00                	push   $0x0
  80288d:	e8 51 ee ff ff       	call   8016e3 <sys_page_unmap>
  802892:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < memsz; i += PGSIZE) {
  802895:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80289b:	89 de                	mov    %ebx,%esi
  80289d:	39 9d 8c fd ff ff    	cmp    %ebx,-0x274(%ebp)
  8028a3:	76 73                	jbe    802918 <spawn+0x38a>
		if (i >= filesz) {
  8028a5:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  8028ab:	0f 87 38 ff ff ff    	ja     8027e9 <spawn+0x25b>
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  8028b1:	83 ec 04             	sub    $0x4,%esp
  8028b4:	57                   	push   %edi
  8028b5:	03 b5 88 fd ff ff    	add    -0x278(%ebp),%esi
  8028bb:	56                   	push   %esi
  8028bc:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8028c2:	e8 97 ed ff ff       	call   80165e <sys_page_alloc>
  8028c7:	83 c4 10             	add    $0x10,%esp
  8028ca:	85 c0                	test   %eax,%eax
  8028cc:	79 c7                	jns    802895 <spawn+0x307>
  8028ce:	89 c7                	mov    %eax,%edi
	sys_env_destroy(child);
  8028d0:	83 ec 0c             	sub    $0xc,%esp
  8028d3:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8028d9:	e8 01 ed ff ff       	call   8015df <sys_env_destroy>
	close(fd);
  8028de:	83 c4 04             	add    $0x4,%esp
  8028e1:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  8028e7:	e8 54 f5 ff ff       	call   801e40 <close>
	return r;
  8028ec:	83 c4 10             	add    $0x10,%esp
  8028ef:	89 bd 90 fd ff ff    	mov    %edi,-0x270(%ebp)
}
  8028f5:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  8028fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8028fe:	5b                   	pop    %ebx
  8028ff:	5e                   	pop    %esi
  802900:	5f                   	pop    %edi
  802901:	5d                   	pop    %ebp
  802902:	c3                   	ret    
				panic("spawn: sys_page_map data: %e", r);
  802903:	50                   	push   %eax
  802904:	68 e0 39 80 00       	push   $0x8039e0
  802909:	68 25 01 00 00       	push   $0x125
  80290e:	68 d4 39 80 00       	push   $0x8039d4
  802913:	e8 63 e1 ff ff       	call   800a7b <_panic>
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802918:	83 85 7c fd ff ff 01 	addl   $0x1,-0x284(%ebp)
  80291f:	83 85 78 fd ff ff 20 	addl   $0x20,-0x288(%ebp)
  802926:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  80292d:	3b 85 7c fd ff ff    	cmp    -0x284(%ebp),%eax
  802933:	7e 71                	jle    8029a6 <spawn+0x418>
		if (ph->p_type != ELF_PROG_LOAD)
  802935:	8b 8d 78 fd ff ff    	mov    -0x288(%ebp),%ecx
  80293b:	83 39 01             	cmpl   $0x1,(%ecx)
  80293e:	75 d8                	jne    802918 <spawn+0x38a>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  802940:	8b 41 18             	mov    0x18(%ecx),%eax
  802943:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  802946:	83 f8 01             	cmp    $0x1,%eax
  802949:	19 ff                	sbb    %edi,%edi
  80294b:	83 e7 fe             	and    $0xfffffffe,%edi
  80294e:	83 c7 07             	add    $0x7,%edi
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  802951:	8b 71 04             	mov    0x4(%ecx),%esi
  802954:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  80295a:	8b 59 10             	mov    0x10(%ecx),%ebx
  80295d:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  802963:	8b 41 14             	mov    0x14(%ecx),%eax
  802966:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  80296c:	8b 51 08             	mov    0x8(%ecx),%edx
  80296f:	89 95 88 fd ff ff    	mov    %edx,-0x278(%ebp)
	if ((i = PGOFF(va))) {
  802975:	89 d0                	mov    %edx,%eax
  802977:	25 ff 0f 00 00       	and    $0xfff,%eax
  80297c:	74 1e                	je     80299c <spawn+0x40e>
		va -= i;
  80297e:	29 c2                	sub    %eax,%edx
  802980:	89 95 88 fd ff ff    	mov    %edx,-0x278(%ebp)
		memsz += i;
  802986:	01 85 8c fd ff ff    	add    %eax,-0x274(%ebp)
		filesz += i;
  80298c:	01 c3                	add    %eax,%ebx
  80298e:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
		fileoffset -= i;
  802994:	29 c6                	sub    %eax,%esi
  802996:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
	for (i = 0; i < memsz; i += PGSIZE) {
  80299c:	bb 00 00 00 00       	mov    $0x0,%ebx
  8029a1:	e9 f5 fe ff ff       	jmp    80289b <spawn+0x30d>
	close(fd);
  8029a6:	83 ec 0c             	sub    $0xc,%esp
  8029a9:	ff b5 90 fd ff ff    	pushl  -0x270(%ebp)
  8029af:	e8 8c f4 ff ff       	call   801e40 <close>
  8029b4:	83 c4 10             	add    $0x10,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
    	uintptr_t addr;
    	for (addr = 0; addr < UTOP; addr += PGSIZE) {
  8029b7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8029bc:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
  8029c2:	eb 0e                	jmp    8029d2 <spawn+0x444>
  8029c4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8029ca:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  8029d0:	74 58                	je     802a2a <spawn+0x49c>
        	if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U) && (uvpt[PGNUM(addr)] & PTE_SHARE)) {
  8029d2:	89 d8                	mov    %ebx,%eax
  8029d4:	c1 e8 16             	shr    $0x16,%eax
  8029d7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8029de:	a8 01                	test   $0x1,%al
  8029e0:	74 e2                	je     8029c4 <spawn+0x436>
  8029e2:	89 d8                	mov    %ebx,%eax
  8029e4:	c1 e8 0c             	shr    $0xc,%eax
  8029e7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8029ee:	f6 c2 01             	test   $0x1,%dl
  8029f1:	74 d1                	je     8029c4 <spawn+0x436>
  8029f3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8029fa:	f6 c2 04             	test   $0x4,%dl
  8029fd:	74 c5                	je     8029c4 <spawn+0x436>
  8029ff:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802a06:	f6 c6 04             	test   $0x4,%dh
  802a09:	74 b9                	je     8029c4 <spawn+0x436>
            		sys_page_map(0, (void*)addr, child, (void*)addr, (uvpt[PGNUM(addr)] & PTE_SYSCALL));
  802a0b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802a12:	83 ec 0c             	sub    $0xc,%esp
  802a15:	25 07 0e 00 00       	and    $0xe07,%eax
  802a1a:	50                   	push   %eax
  802a1b:	53                   	push   %ebx
  802a1c:	56                   	push   %esi
  802a1d:	53                   	push   %ebx
  802a1e:	6a 00                	push   $0x0
  802a20:	e8 7c ec ff ff       	call   8016a1 <sys_page_map>
  802a25:	83 c4 20             	add    $0x20,%esp
  802a28:	eb 9a                	jmp    8029c4 <spawn+0x436>
	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  802a2a:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  802a31:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802a34:	83 ec 08             	sub    $0x8,%esp
  802a37:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802a3d:	50                   	push   %eax
  802a3e:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802a44:	e8 1e ed ff ff       	call   801767 <sys_env_set_trapframe>
  802a49:	83 c4 10             	add    $0x10,%esp
  802a4c:	85 c0                	test   %eax,%eax
  802a4e:	78 28                	js     802a78 <spawn+0x4ea>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802a50:	83 ec 08             	sub    $0x8,%esp
  802a53:	6a 02                	push   $0x2
  802a55:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  802a5b:	e8 c5 ec ff ff       	call   801725 <sys_env_set_status>
  802a60:	83 c4 10             	add    $0x10,%esp
  802a63:	85 c0                	test   %eax,%eax
  802a65:	78 26                	js     802a8d <spawn+0x4ff>
	return child;
  802a67:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802a6d:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  802a73:	e9 7d fe ff ff       	jmp    8028f5 <spawn+0x367>
		panic("sys_env_set_trapframe: %e", r);
  802a78:	50                   	push   %eax
  802a79:	68 fd 39 80 00       	push   $0x8039fd
  802a7e:	68 86 00 00 00       	push   $0x86
  802a83:	68 d4 39 80 00       	push   $0x8039d4
  802a88:	e8 ee df ff ff       	call   800a7b <_panic>
		panic("sys_env_set_status: %e", r);
  802a8d:	50                   	push   %eax
  802a8e:	68 17 3a 80 00       	push   $0x803a17
  802a93:	68 89 00 00 00       	push   $0x89
  802a98:	68 d4 39 80 00       	push   $0x8039d4
  802a9d:	e8 d9 df ff ff       	call   800a7b <_panic>
		return r;
  802aa2:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802aa8:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  802aae:	e9 42 fe ff ff       	jmp    8028f5 <spawn+0x367>
		return -E_NO_MEM;
  802ab3:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return r;
  802ab8:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
  802abe:	e9 32 fe ff ff       	jmp    8028f5 <spawn+0x367>
  802ac3:	89 c7                	mov    %eax,%edi
  802ac5:	e9 06 fe ff ff       	jmp    8028d0 <spawn+0x342>
  802aca:	89 c7                	mov    %eax,%edi
  802acc:	e9 ff fd ff ff       	jmp    8028d0 <spawn+0x342>
  802ad1:	89 c7                	mov    %eax,%edi
  802ad3:	e9 f8 fd ff ff       	jmp    8028d0 <spawn+0x342>
	sys_page_unmap(0, UTEMP);
  802ad8:	83 ec 08             	sub    $0x8,%esp
  802adb:	68 00 00 40 00       	push   $0x400000
  802ae0:	6a 00                	push   $0x0
  802ae2:	e8 fc eb ff ff       	call   8016e3 <sys_page_unmap>
  802ae7:	83 c4 10             	add    $0x10,%esp
  802aea:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  802af0:	e9 00 fe ff ff       	jmp    8028f5 <spawn+0x367>

00802af5 <spawnl>:
{
  802af5:	55                   	push   %ebp
  802af6:	89 e5                	mov    %esp,%ebp
  802af8:	57                   	push   %edi
  802af9:	56                   	push   %esi
  802afa:	53                   	push   %ebx
  802afb:	83 ec 0c             	sub    $0xc,%esp
	va_start(vl, arg0);
  802afe:	8d 55 10             	lea    0x10(%ebp),%edx
	int argc=0;
  802b01:	b8 00 00 00 00       	mov    $0x0,%eax
	while(va_arg(vl, void *) != NULL)
  802b06:	eb 05                	jmp    802b0d <spawnl+0x18>
		argc++;
  802b08:	83 c0 01             	add    $0x1,%eax
	while(va_arg(vl, void *) != NULL)
  802b0b:	89 ca                	mov    %ecx,%edx
  802b0d:	8d 4a 04             	lea    0x4(%edx),%ecx
  802b10:	83 3a 00             	cmpl   $0x0,(%edx)
  802b13:	75 f3                	jne    802b08 <spawnl+0x13>
	const char *argv[argc+2];
  802b15:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  802b1c:	83 e2 f0             	and    $0xfffffff0,%edx
  802b1f:	29 d4                	sub    %edx,%esp
  802b21:	8d 54 24 03          	lea    0x3(%esp),%edx
  802b25:	c1 ea 02             	shr    $0x2,%edx
  802b28:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  802b2f:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802b31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802b34:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  802b3b:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  802b42:	00 
	va_start(vl, arg0);
  802b43:	8d 4d 10             	lea    0x10(%ebp),%ecx
  802b46:	89 c2                	mov    %eax,%edx
	for(i=0;i<argc;i++)
  802b48:	b8 00 00 00 00       	mov    $0x0,%eax
  802b4d:	eb 0b                	jmp    802b5a <spawnl+0x65>
		argv[i+1] = va_arg(vl, const char *);
  802b4f:	83 c0 01             	add    $0x1,%eax
  802b52:	8b 39                	mov    (%ecx),%edi
  802b54:	89 3c 83             	mov    %edi,(%ebx,%eax,4)
  802b57:	8d 49 04             	lea    0x4(%ecx),%ecx
	for(i=0;i<argc;i++)
  802b5a:	39 d0                	cmp    %edx,%eax
  802b5c:	75 f1                	jne    802b4f <spawnl+0x5a>
	return spawn(prog, argv);
  802b5e:	83 ec 08             	sub    $0x8,%esp
  802b61:	56                   	push   %esi
  802b62:	ff 75 08             	pushl  0x8(%ebp)
  802b65:	e8 24 fa ff ff       	call   80258e <spawn>
}
  802b6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802b6d:	5b                   	pop    %ebx
  802b6e:	5e                   	pop    %esi
  802b6f:	5f                   	pop    %edi
  802b70:	5d                   	pop    %ebp
  802b71:	c3                   	ret    

00802b72 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802b72:	55                   	push   %ebp
  802b73:	89 e5                	mov    %esp,%ebp
  802b75:	56                   	push   %esi
  802b76:	53                   	push   %ebx
  802b77:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802b7a:	83 ec 0c             	sub    $0xc,%esp
  802b7d:	ff 75 08             	pushl  0x8(%ebp)
  802b80:	e8 20 f1 ff ff       	call   801ca5 <fd2data>
  802b85:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802b87:	83 c4 08             	add    $0x8,%esp
  802b8a:	68 56 3a 80 00       	push   $0x803a56
  802b8f:	53                   	push   %ebx
  802b90:	e8 d0 e6 ff ff       	call   801265 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802b95:	8b 46 04             	mov    0x4(%esi),%eax
  802b98:	2b 06                	sub    (%esi),%eax
  802b9a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802ba0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802ba7:	00 00 00 
	stat->st_dev = &devpipe;
  802baa:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  802bb1:	40 80 00 
	return 0;
}
  802bb4:	b8 00 00 00 00       	mov    $0x0,%eax
  802bb9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802bbc:	5b                   	pop    %ebx
  802bbd:	5e                   	pop    %esi
  802bbe:	5d                   	pop    %ebp
  802bbf:	c3                   	ret    

00802bc0 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802bc0:	55                   	push   %ebp
  802bc1:	89 e5                	mov    %esp,%ebp
  802bc3:	53                   	push   %ebx
  802bc4:	83 ec 0c             	sub    $0xc,%esp
  802bc7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802bca:	53                   	push   %ebx
  802bcb:	6a 00                	push   $0x0
  802bcd:	e8 11 eb ff ff       	call   8016e3 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802bd2:	89 1c 24             	mov    %ebx,(%esp)
  802bd5:	e8 cb f0 ff ff       	call   801ca5 <fd2data>
  802bda:	83 c4 08             	add    $0x8,%esp
  802bdd:	50                   	push   %eax
  802bde:	6a 00                	push   $0x0
  802be0:	e8 fe ea ff ff       	call   8016e3 <sys_page_unmap>
}
  802be5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802be8:	c9                   	leave  
  802be9:	c3                   	ret    

00802bea <_pipeisclosed>:
{
  802bea:	55                   	push   %ebp
  802beb:	89 e5                	mov    %esp,%ebp
  802bed:	57                   	push   %edi
  802bee:	56                   	push   %esi
  802bef:	53                   	push   %ebx
  802bf0:	83 ec 1c             	sub    $0x1c,%esp
  802bf3:	89 c7                	mov    %eax,%edi
  802bf5:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  802bf7:	a1 24 54 80 00       	mov    0x805424,%eax
  802bfc:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802bff:	83 ec 0c             	sub    $0xc,%esp
  802c02:	57                   	push   %edi
  802c03:	e8 8f 04 00 00       	call   803097 <pageref>
  802c08:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  802c0b:	89 34 24             	mov    %esi,(%esp)
  802c0e:	e8 84 04 00 00       	call   803097 <pageref>
		nn = thisenv->env_runs;
  802c13:	8b 15 24 54 80 00    	mov    0x805424,%edx
  802c19:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802c1c:	83 c4 10             	add    $0x10,%esp
  802c1f:	39 cb                	cmp    %ecx,%ebx
  802c21:	74 1b                	je     802c3e <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  802c23:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802c26:	75 cf                	jne    802bf7 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802c28:	8b 42 58             	mov    0x58(%edx),%eax
  802c2b:	6a 01                	push   $0x1
  802c2d:	50                   	push   %eax
  802c2e:	53                   	push   %ebx
  802c2f:	68 5d 3a 80 00       	push   $0x803a5d
  802c34:	e8 1d df ff ff       	call   800b56 <cprintf>
  802c39:	83 c4 10             	add    $0x10,%esp
  802c3c:	eb b9                	jmp    802bf7 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  802c3e:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802c41:	0f 94 c0             	sete   %al
  802c44:	0f b6 c0             	movzbl %al,%eax
}
  802c47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802c4a:	5b                   	pop    %ebx
  802c4b:	5e                   	pop    %esi
  802c4c:	5f                   	pop    %edi
  802c4d:	5d                   	pop    %ebp
  802c4e:	c3                   	ret    

00802c4f <devpipe_write>:
{
  802c4f:	55                   	push   %ebp
  802c50:	89 e5                	mov    %esp,%ebp
  802c52:	57                   	push   %edi
  802c53:	56                   	push   %esi
  802c54:	53                   	push   %ebx
  802c55:	83 ec 28             	sub    $0x28,%esp
  802c58:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  802c5b:	56                   	push   %esi
  802c5c:	e8 44 f0 ff ff       	call   801ca5 <fd2data>
  802c61:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802c63:	83 c4 10             	add    $0x10,%esp
  802c66:	bf 00 00 00 00       	mov    $0x0,%edi
  802c6b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802c6e:	74 4f                	je     802cbf <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802c70:	8b 43 04             	mov    0x4(%ebx),%eax
  802c73:	8b 0b                	mov    (%ebx),%ecx
  802c75:	8d 51 20             	lea    0x20(%ecx),%edx
  802c78:	39 d0                	cmp    %edx,%eax
  802c7a:	72 14                	jb     802c90 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  802c7c:	89 da                	mov    %ebx,%edx
  802c7e:	89 f0                	mov    %esi,%eax
  802c80:	e8 65 ff ff ff       	call   802bea <_pipeisclosed>
  802c85:	85 c0                	test   %eax,%eax
  802c87:	75 3a                	jne    802cc3 <devpipe_write+0x74>
			sys_yield();
  802c89:	e8 b1 e9 ff ff       	call   80163f <sys_yield>
  802c8e:	eb e0                	jmp    802c70 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802c90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802c93:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802c97:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802c9a:	89 c2                	mov    %eax,%edx
  802c9c:	c1 fa 1f             	sar    $0x1f,%edx
  802c9f:	89 d1                	mov    %edx,%ecx
  802ca1:	c1 e9 1b             	shr    $0x1b,%ecx
  802ca4:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802ca7:	83 e2 1f             	and    $0x1f,%edx
  802caa:	29 ca                	sub    %ecx,%edx
  802cac:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802cb0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802cb4:	83 c0 01             	add    $0x1,%eax
  802cb7:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  802cba:	83 c7 01             	add    $0x1,%edi
  802cbd:	eb ac                	jmp    802c6b <devpipe_write+0x1c>
	return i;
  802cbf:	89 f8                	mov    %edi,%eax
  802cc1:	eb 05                	jmp    802cc8 <devpipe_write+0x79>
				return 0;
  802cc3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802cc8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802ccb:	5b                   	pop    %ebx
  802ccc:	5e                   	pop    %esi
  802ccd:	5f                   	pop    %edi
  802cce:	5d                   	pop    %ebp
  802ccf:	c3                   	ret    

00802cd0 <devpipe_read>:
{
  802cd0:	55                   	push   %ebp
  802cd1:	89 e5                	mov    %esp,%ebp
  802cd3:	57                   	push   %edi
  802cd4:	56                   	push   %esi
  802cd5:	53                   	push   %ebx
  802cd6:	83 ec 18             	sub    $0x18,%esp
  802cd9:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  802cdc:	57                   	push   %edi
  802cdd:	e8 c3 ef ff ff       	call   801ca5 <fd2data>
  802ce2:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802ce4:	83 c4 10             	add    $0x10,%esp
  802ce7:	be 00 00 00 00       	mov    $0x0,%esi
  802cec:	3b 75 10             	cmp    0x10(%ebp),%esi
  802cef:	74 47                	je     802d38 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  802cf1:	8b 03                	mov    (%ebx),%eax
  802cf3:	3b 43 04             	cmp    0x4(%ebx),%eax
  802cf6:	75 22                	jne    802d1a <devpipe_read+0x4a>
			if (i > 0)
  802cf8:	85 f6                	test   %esi,%esi
  802cfa:	75 14                	jne    802d10 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  802cfc:	89 da                	mov    %ebx,%edx
  802cfe:	89 f8                	mov    %edi,%eax
  802d00:	e8 e5 fe ff ff       	call   802bea <_pipeisclosed>
  802d05:	85 c0                	test   %eax,%eax
  802d07:	75 33                	jne    802d3c <devpipe_read+0x6c>
			sys_yield();
  802d09:	e8 31 e9 ff ff       	call   80163f <sys_yield>
  802d0e:	eb e1                	jmp    802cf1 <devpipe_read+0x21>
				return i;
  802d10:	89 f0                	mov    %esi,%eax
}
  802d12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802d15:	5b                   	pop    %ebx
  802d16:	5e                   	pop    %esi
  802d17:	5f                   	pop    %edi
  802d18:	5d                   	pop    %ebp
  802d19:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802d1a:	99                   	cltd   
  802d1b:	c1 ea 1b             	shr    $0x1b,%edx
  802d1e:	01 d0                	add    %edx,%eax
  802d20:	83 e0 1f             	and    $0x1f,%eax
  802d23:	29 d0                	sub    %edx,%eax
  802d25:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802d2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802d2d:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  802d30:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  802d33:	83 c6 01             	add    $0x1,%esi
  802d36:	eb b4                	jmp    802cec <devpipe_read+0x1c>
	return i;
  802d38:	89 f0                	mov    %esi,%eax
  802d3a:	eb d6                	jmp    802d12 <devpipe_read+0x42>
				return 0;
  802d3c:	b8 00 00 00 00       	mov    $0x0,%eax
  802d41:	eb cf                	jmp    802d12 <devpipe_read+0x42>

00802d43 <pipe>:
{
  802d43:	55                   	push   %ebp
  802d44:	89 e5                	mov    %esp,%ebp
  802d46:	56                   	push   %esi
  802d47:	53                   	push   %ebx
  802d48:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  802d4b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d4e:	50                   	push   %eax
  802d4f:	e8 68 ef ff ff       	call   801cbc <fd_alloc>
  802d54:	89 c3                	mov    %eax,%ebx
  802d56:	83 c4 10             	add    $0x10,%esp
  802d59:	85 c0                	test   %eax,%eax
  802d5b:	78 5b                	js     802db8 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d5d:	83 ec 04             	sub    $0x4,%esp
  802d60:	68 07 04 00 00       	push   $0x407
  802d65:	ff 75 f4             	pushl  -0xc(%ebp)
  802d68:	6a 00                	push   $0x0
  802d6a:	e8 ef e8 ff ff       	call   80165e <sys_page_alloc>
  802d6f:	89 c3                	mov    %eax,%ebx
  802d71:	83 c4 10             	add    $0x10,%esp
  802d74:	85 c0                	test   %eax,%eax
  802d76:	78 40                	js     802db8 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  802d78:	83 ec 0c             	sub    $0xc,%esp
  802d7b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802d7e:	50                   	push   %eax
  802d7f:	e8 38 ef ff ff       	call   801cbc <fd_alloc>
  802d84:	89 c3                	mov    %eax,%ebx
  802d86:	83 c4 10             	add    $0x10,%esp
  802d89:	85 c0                	test   %eax,%eax
  802d8b:	78 1b                	js     802da8 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d8d:	83 ec 04             	sub    $0x4,%esp
  802d90:	68 07 04 00 00       	push   $0x407
  802d95:	ff 75 f0             	pushl  -0x10(%ebp)
  802d98:	6a 00                	push   $0x0
  802d9a:	e8 bf e8 ff ff       	call   80165e <sys_page_alloc>
  802d9f:	89 c3                	mov    %eax,%ebx
  802da1:	83 c4 10             	add    $0x10,%esp
  802da4:	85 c0                	test   %eax,%eax
  802da6:	79 19                	jns    802dc1 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  802da8:	83 ec 08             	sub    $0x8,%esp
  802dab:	ff 75 f4             	pushl  -0xc(%ebp)
  802dae:	6a 00                	push   $0x0
  802db0:	e8 2e e9 ff ff       	call   8016e3 <sys_page_unmap>
  802db5:	83 c4 10             	add    $0x10,%esp
}
  802db8:	89 d8                	mov    %ebx,%eax
  802dba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802dbd:	5b                   	pop    %ebx
  802dbe:	5e                   	pop    %esi
  802dbf:	5d                   	pop    %ebp
  802dc0:	c3                   	ret    
	va = fd2data(fd0);
  802dc1:	83 ec 0c             	sub    $0xc,%esp
  802dc4:	ff 75 f4             	pushl  -0xc(%ebp)
  802dc7:	e8 d9 ee ff ff       	call   801ca5 <fd2data>
  802dcc:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802dce:	83 c4 0c             	add    $0xc,%esp
  802dd1:	68 07 04 00 00       	push   $0x407
  802dd6:	50                   	push   %eax
  802dd7:	6a 00                	push   $0x0
  802dd9:	e8 80 e8 ff ff       	call   80165e <sys_page_alloc>
  802dde:	89 c3                	mov    %eax,%ebx
  802de0:	83 c4 10             	add    $0x10,%esp
  802de3:	85 c0                	test   %eax,%eax
  802de5:	0f 88 8c 00 00 00    	js     802e77 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802deb:	83 ec 0c             	sub    $0xc,%esp
  802dee:	ff 75 f0             	pushl  -0x10(%ebp)
  802df1:	e8 af ee ff ff       	call   801ca5 <fd2data>
  802df6:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802dfd:	50                   	push   %eax
  802dfe:	6a 00                	push   $0x0
  802e00:	56                   	push   %esi
  802e01:	6a 00                	push   $0x0
  802e03:	e8 99 e8 ff ff       	call   8016a1 <sys_page_map>
  802e08:	89 c3                	mov    %eax,%ebx
  802e0a:	83 c4 20             	add    $0x20,%esp
  802e0d:	85 c0                	test   %eax,%eax
  802e0f:	78 58                	js     802e69 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  802e11:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e14:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802e1a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802e1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e1f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  802e26:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802e29:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802e2f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802e31:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802e34:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  802e3b:	83 ec 0c             	sub    $0xc,%esp
  802e3e:	ff 75 f4             	pushl  -0xc(%ebp)
  802e41:	e8 4f ee ff ff       	call   801c95 <fd2num>
  802e46:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802e49:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802e4b:	83 c4 04             	add    $0x4,%esp
  802e4e:	ff 75 f0             	pushl  -0x10(%ebp)
  802e51:	e8 3f ee ff ff       	call   801c95 <fd2num>
  802e56:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802e59:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802e5c:	83 c4 10             	add    $0x10,%esp
  802e5f:	bb 00 00 00 00       	mov    $0x0,%ebx
  802e64:	e9 4f ff ff ff       	jmp    802db8 <pipe+0x75>
	sys_page_unmap(0, va);
  802e69:	83 ec 08             	sub    $0x8,%esp
  802e6c:	56                   	push   %esi
  802e6d:	6a 00                	push   $0x0
  802e6f:	e8 6f e8 ff ff       	call   8016e3 <sys_page_unmap>
  802e74:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  802e77:	83 ec 08             	sub    $0x8,%esp
  802e7a:	ff 75 f0             	pushl  -0x10(%ebp)
  802e7d:	6a 00                	push   $0x0
  802e7f:	e8 5f e8 ff ff       	call   8016e3 <sys_page_unmap>
  802e84:	83 c4 10             	add    $0x10,%esp
  802e87:	e9 1c ff ff ff       	jmp    802da8 <pipe+0x65>

00802e8c <pipeisclosed>:
{
  802e8c:	55                   	push   %ebp
  802e8d:	89 e5                	mov    %esp,%ebp
  802e8f:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802e92:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802e95:	50                   	push   %eax
  802e96:	ff 75 08             	pushl  0x8(%ebp)
  802e99:	e8 6d ee ff ff       	call   801d0b <fd_lookup>
  802e9e:	83 c4 10             	add    $0x10,%esp
  802ea1:	85 c0                	test   %eax,%eax
  802ea3:	78 18                	js     802ebd <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  802ea5:	83 ec 0c             	sub    $0xc,%esp
  802ea8:	ff 75 f4             	pushl  -0xc(%ebp)
  802eab:	e8 f5 ed ff ff       	call   801ca5 <fd2data>
	return _pipeisclosed(fd, p);
  802eb0:	89 c2                	mov    %eax,%edx
  802eb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802eb5:	e8 30 fd ff ff       	call   802bea <_pipeisclosed>
  802eba:	83 c4 10             	add    $0x10,%esp
}
  802ebd:	c9                   	leave  
  802ebe:	c3                   	ret    

00802ebf <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802ebf:	55                   	push   %ebp
  802ec0:	89 e5                	mov    %esp,%ebp
  802ec2:	56                   	push   %esi
  802ec3:	53                   	push   %ebx
  802ec4:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802ec7:	85 f6                	test   %esi,%esi
  802ec9:	74 13                	je     802ede <wait+0x1f>
	e = &envs[ENVX(envid)];
  802ecb:	89 f3                	mov    %esi,%ebx
  802ecd:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802ed3:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802ed6:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802edc:	eb 1b                	jmp    802ef9 <wait+0x3a>
	assert(envid != 0);
  802ede:	68 75 3a 80 00       	push   $0x803a75
  802ee3:	68 51 34 80 00       	push   $0x803451
  802ee8:	6a 09                	push   $0x9
  802eea:	68 80 3a 80 00       	push   $0x803a80
  802eef:	e8 87 db ff ff       	call   800a7b <_panic>
		sys_yield();
  802ef4:	e8 46 e7 ff ff       	call   80163f <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802ef9:	8b 43 48             	mov    0x48(%ebx),%eax
  802efc:	39 f0                	cmp    %esi,%eax
  802efe:	75 07                	jne    802f07 <wait+0x48>
  802f00:	8b 43 54             	mov    0x54(%ebx),%eax
  802f03:	85 c0                	test   %eax,%eax
  802f05:	75 ed                	jne    802ef4 <wait+0x35>
}
  802f07:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802f0a:	5b                   	pop    %ebx
  802f0b:	5e                   	pop    %esi
  802f0c:	5d                   	pop    %ebp
  802f0d:	c3                   	ret    

00802f0e <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802f0e:	55                   	push   %ebp
  802f0f:	89 e5                	mov    %esp,%ebp
  802f11:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802f14:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802f1b:	74 20                	je     802f3d <set_pgfault_handler+0x2f>
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
			panic("set_pgfault_handler:sys_page_alloc failed");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802f1d:	8b 45 08             	mov    0x8(%ebp),%eax
  802f20:	a3 00 70 80 00       	mov    %eax,0x807000
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  802f25:	83 ec 08             	sub    $0x8,%esp
  802f28:	68 7d 2f 80 00       	push   $0x802f7d
  802f2d:	6a 00                	push   $0x0
  802f2f:	e8 75 e8 ff ff       	call   8017a9 <sys_env_set_pgfault_upcall>
  802f34:	83 c4 10             	add    $0x10,%esp
  802f37:	85 c0                	test   %eax,%eax
  802f39:	78 2e                	js     802f69 <set_pgfault_handler+0x5b>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
}
  802f3b:	c9                   	leave  
  802f3c:	c3                   	ret    
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  802f3d:	83 ec 04             	sub    $0x4,%esp
  802f40:	6a 07                	push   $0x7
  802f42:	68 00 f0 bf ee       	push   $0xeebff000
  802f47:	6a 00                	push   $0x0
  802f49:	e8 10 e7 ff ff       	call   80165e <sys_page_alloc>
  802f4e:	83 c4 10             	add    $0x10,%esp
  802f51:	85 c0                	test   %eax,%eax
  802f53:	79 c8                	jns    802f1d <set_pgfault_handler+0xf>
			panic("set_pgfault_handler:sys_page_alloc failed");
  802f55:	83 ec 04             	sub    $0x4,%esp
  802f58:	68 8c 3a 80 00       	push   $0x803a8c
  802f5d:	6a 21                	push   $0x21
  802f5f:	68 f0 3a 80 00       	push   $0x803af0
  802f64:	e8 12 db ff ff       	call   800a7b <_panic>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  802f69:	83 ec 04             	sub    $0x4,%esp
  802f6c:	68 b8 3a 80 00       	push   $0x803ab8
  802f71:	6a 27                	push   $0x27
  802f73:	68 f0 3a 80 00       	push   $0x803af0
  802f78:	e8 fe da ff ff       	call   800a7b <_panic>

00802f7d <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802f7d:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802f7e:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802f83:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802f85:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %eax
  802f88:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  802f8c:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  802f8f:	89 44 24 30          	mov    %eax,0x30(%esp)
	movl 40(%esp), %ebx
  802f93:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  802f97:	89 18                	mov    %ebx,(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  802f99:	83 c4 08             	add    $0x8,%esp
	popal
  802f9c:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  802f9d:	83 c4 04             	add    $0x4,%esp
	popfl
  802fa0:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802fa1:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802fa2:	c3                   	ret    

00802fa3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802fa3:	55                   	push   %ebp
  802fa4:	89 e5                	mov    %esp,%ebp
  802fa6:	56                   	push   %esi
  802fa7:	53                   	push   %ebx
  802fa8:	8b 75 08             	mov    0x8(%ebp),%esi
  802fab:	8b 45 0c             	mov    0xc(%ebp),%eax
  802fae:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  802fb1:	85 f6                	test   %esi,%esi
  802fb3:	74 06                	je     802fbb <ipc_recv+0x18>
  802fb5:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  802fbb:	85 db                	test   %ebx,%ebx
  802fbd:	74 06                	je     802fc5 <ipc_recv+0x22>
  802fbf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  802fc5:	85 c0                	test   %eax,%eax
  802fc7:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  802fcc:	0f 44 c2             	cmove  %edx,%eax
	int ret = sys_ipc_recv(pg);
  802fcf:	83 ec 0c             	sub    $0xc,%esp
  802fd2:	50                   	push   %eax
  802fd3:	e8 36 e8 ff ff       	call   80180e <sys_ipc_recv>
	if (ret) return ret;
  802fd8:	83 c4 10             	add    $0x10,%esp
  802fdb:	85 c0                	test   %eax,%eax
  802fdd:	75 24                	jne    803003 <ipc_recv+0x60>
	if (from_env_store)
  802fdf:	85 f6                	test   %esi,%esi
  802fe1:	74 0a                	je     802fed <ipc_recv+0x4a>
		*from_env_store = thisenv->env_ipc_from;
  802fe3:	a1 24 54 80 00       	mov    0x805424,%eax
  802fe8:	8b 40 74             	mov    0x74(%eax),%eax
  802feb:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  802fed:	85 db                	test   %ebx,%ebx
  802fef:	74 0a                	je     802ffb <ipc_recv+0x58>
		*perm_store = thisenv->env_ipc_perm;
  802ff1:	a1 24 54 80 00       	mov    0x805424,%eax
  802ff6:	8b 40 78             	mov    0x78(%eax),%eax
  802ff9:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  802ffb:	a1 24 54 80 00       	mov    0x805424,%eax
  803000:	8b 40 70             	mov    0x70(%eax),%eax
}
  803003:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803006:	5b                   	pop    %ebx
  803007:	5e                   	pop    %esi
  803008:	5d                   	pop    %ebp
  803009:	c3                   	ret    

0080300a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80300a:	55                   	push   %ebp
  80300b:	89 e5                	mov    %esp,%ebp
  80300d:	57                   	push   %edi
  80300e:	56                   	push   %esi
  80300f:	53                   	push   %ebx
  803010:	83 ec 0c             	sub    $0xc,%esp
  803013:	8b 7d 08             	mov    0x8(%ebp),%edi
  803016:	8b 75 0c             	mov    0xc(%ebp),%esi
  803019:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  80301c:	85 db                	test   %ebx,%ebx
  80301e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  803023:	0f 44 d8             	cmove  %eax,%ebx
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  803026:	ff 75 14             	pushl  0x14(%ebp)
  803029:	53                   	push   %ebx
  80302a:	56                   	push   %esi
  80302b:	57                   	push   %edi
  80302c:	e8 ba e7 ff ff       	call   8017eb <sys_ipc_try_send>
  803031:	83 c4 10             	add    $0x10,%esp
  803034:	85 c0                	test   %eax,%eax
  803036:	74 1e                	je     803056 <ipc_send+0x4c>
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  803038:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80303b:	75 07                	jne    803044 <ipc_send+0x3a>
		sys_yield();
  80303d:	e8 fd e5 ff ff       	call   80163f <sys_yield>
  803042:	eb e2                	jmp    803026 <ipc_send+0x1c>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  803044:	50                   	push   %eax
  803045:	68 fe 3a 80 00       	push   $0x803afe
  80304a:	6a 36                	push   $0x36
  80304c:	68 15 3b 80 00       	push   $0x803b15
  803051:	e8 25 da ff ff       	call   800a7b <_panic>
	}
}
  803056:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803059:	5b                   	pop    %ebx
  80305a:	5e                   	pop    %esi
  80305b:	5f                   	pop    %edi
  80305c:	5d                   	pop    %ebp
  80305d:	c3                   	ret    

0080305e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80305e:	55                   	push   %ebp
  80305f:	89 e5                	mov    %esp,%ebp
  803061:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  803064:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  803069:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80306c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  803072:	8b 52 50             	mov    0x50(%edx),%edx
  803075:	39 ca                	cmp    %ecx,%edx
  803077:	74 11                	je     80308a <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  803079:	83 c0 01             	add    $0x1,%eax
  80307c:	3d 00 04 00 00       	cmp    $0x400,%eax
  803081:	75 e6                	jne    803069 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  803083:	b8 00 00 00 00       	mov    $0x0,%eax
  803088:	eb 0b                	jmp    803095 <ipc_find_env+0x37>
			return envs[i].env_id;
  80308a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80308d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  803092:	8b 40 48             	mov    0x48(%eax),%eax
}
  803095:	5d                   	pop    %ebp
  803096:	c3                   	ret    

00803097 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  803097:	55                   	push   %ebp
  803098:	89 e5                	mov    %esp,%ebp
  80309a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80309d:	89 d0                	mov    %edx,%eax
  80309f:	c1 e8 16             	shr    $0x16,%eax
  8030a2:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8030a9:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  8030ae:	f6 c1 01             	test   $0x1,%cl
  8030b1:	74 1d                	je     8030d0 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  8030b3:	c1 ea 0c             	shr    $0xc,%edx
  8030b6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8030bd:	f6 c2 01             	test   $0x1,%dl
  8030c0:	74 0e                	je     8030d0 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8030c2:	c1 ea 0c             	shr    $0xc,%edx
  8030c5:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8030cc:	ef 
  8030cd:	0f b7 c0             	movzwl %ax,%eax
}
  8030d0:	5d                   	pop    %ebp
  8030d1:	c3                   	ret    
  8030d2:	66 90                	xchg   %ax,%ax
  8030d4:	66 90                	xchg   %ax,%ax
  8030d6:	66 90                	xchg   %ax,%ax
  8030d8:	66 90                	xchg   %ax,%ax
  8030da:	66 90                	xchg   %ax,%ax
  8030dc:	66 90                	xchg   %ax,%ax
  8030de:	66 90                	xchg   %ax,%ax

008030e0 <__udivdi3>:
  8030e0:	55                   	push   %ebp
  8030e1:	57                   	push   %edi
  8030e2:	56                   	push   %esi
  8030e3:	53                   	push   %ebx
  8030e4:	83 ec 1c             	sub    $0x1c,%esp
  8030e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8030eb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8030ef:	8b 74 24 34          	mov    0x34(%esp),%esi
  8030f3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8030f7:	85 d2                	test   %edx,%edx
  8030f9:	75 35                	jne    803130 <__udivdi3+0x50>
  8030fb:	39 f3                	cmp    %esi,%ebx
  8030fd:	0f 87 bd 00 00 00    	ja     8031c0 <__udivdi3+0xe0>
  803103:	85 db                	test   %ebx,%ebx
  803105:	89 d9                	mov    %ebx,%ecx
  803107:	75 0b                	jne    803114 <__udivdi3+0x34>
  803109:	b8 01 00 00 00       	mov    $0x1,%eax
  80310e:	31 d2                	xor    %edx,%edx
  803110:	f7 f3                	div    %ebx
  803112:	89 c1                	mov    %eax,%ecx
  803114:	31 d2                	xor    %edx,%edx
  803116:	89 f0                	mov    %esi,%eax
  803118:	f7 f1                	div    %ecx
  80311a:	89 c6                	mov    %eax,%esi
  80311c:	89 e8                	mov    %ebp,%eax
  80311e:	89 f7                	mov    %esi,%edi
  803120:	f7 f1                	div    %ecx
  803122:	89 fa                	mov    %edi,%edx
  803124:	83 c4 1c             	add    $0x1c,%esp
  803127:	5b                   	pop    %ebx
  803128:	5e                   	pop    %esi
  803129:	5f                   	pop    %edi
  80312a:	5d                   	pop    %ebp
  80312b:	c3                   	ret    
  80312c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803130:	39 f2                	cmp    %esi,%edx
  803132:	77 7c                	ja     8031b0 <__udivdi3+0xd0>
  803134:	0f bd fa             	bsr    %edx,%edi
  803137:	83 f7 1f             	xor    $0x1f,%edi
  80313a:	0f 84 98 00 00 00    	je     8031d8 <__udivdi3+0xf8>
  803140:	89 f9                	mov    %edi,%ecx
  803142:	b8 20 00 00 00       	mov    $0x20,%eax
  803147:	29 f8                	sub    %edi,%eax
  803149:	d3 e2                	shl    %cl,%edx
  80314b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80314f:	89 c1                	mov    %eax,%ecx
  803151:	89 da                	mov    %ebx,%edx
  803153:	d3 ea                	shr    %cl,%edx
  803155:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  803159:	09 d1                	or     %edx,%ecx
  80315b:	89 f2                	mov    %esi,%edx
  80315d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803161:	89 f9                	mov    %edi,%ecx
  803163:	d3 e3                	shl    %cl,%ebx
  803165:	89 c1                	mov    %eax,%ecx
  803167:	d3 ea                	shr    %cl,%edx
  803169:	89 f9                	mov    %edi,%ecx
  80316b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80316f:	d3 e6                	shl    %cl,%esi
  803171:	89 eb                	mov    %ebp,%ebx
  803173:	89 c1                	mov    %eax,%ecx
  803175:	d3 eb                	shr    %cl,%ebx
  803177:	09 de                	or     %ebx,%esi
  803179:	89 f0                	mov    %esi,%eax
  80317b:	f7 74 24 08          	divl   0x8(%esp)
  80317f:	89 d6                	mov    %edx,%esi
  803181:	89 c3                	mov    %eax,%ebx
  803183:	f7 64 24 0c          	mull   0xc(%esp)
  803187:	39 d6                	cmp    %edx,%esi
  803189:	72 0c                	jb     803197 <__udivdi3+0xb7>
  80318b:	89 f9                	mov    %edi,%ecx
  80318d:	d3 e5                	shl    %cl,%ebp
  80318f:	39 c5                	cmp    %eax,%ebp
  803191:	73 5d                	jae    8031f0 <__udivdi3+0x110>
  803193:	39 d6                	cmp    %edx,%esi
  803195:	75 59                	jne    8031f0 <__udivdi3+0x110>
  803197:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80319a:	31 ff                	xor    %edi,%edi
  80319c:	89 fa                	mov    %edi,%edx
  80319e:	83 c4 1c             	add    $0x1c,%esp
  8031a1:	5b                   	pop    %ebx
  8031a2:	5e                   	pop    %esi
  8031a3:	5f                   	pop    %edi
  8031a4:	5d                   	pop    %ebp
  8031a5:	c3                   	ret    
  8031a6:	8d 76 00             	lea    0x0(%esi),%esi
  8031a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8031b0:	31 ff                	xor    %edi,%edi
  8031b2:	31 c0                	xor    %eax,%eax
  8031b4:	89 fa                	mov    %edi,%edx
  8031b6:	83 c4 1c             	add    $0x1c,%esp
  8031b9:	5b                   	pop    %ebx
  8031ba:	5e                   	pop    %esi
  8031bb:	5f                   	pop    %edi
  8031bc:	5d                   	pop    %ebp
  8031bd:	c3                   	ret    
  8031be:	66 90                	xchg   %ax,%ax
  8031c0:	31 ff                	xor    %edi,%edi
  8031c2:	89 e8                	mov    %ebp,%eax
  8031c4:	89 f2                	mov    %esi,%edx
  8031c6:	f7 f3                	div    %ebx
  8031c8:	89 fa                	mov    %edi,%edx
  8031ca:	83 c4 1c             	add    $0x1c,%esp
  8031cd:	5b                   	pop    %ebx
  8031ce:	5e                   	pop    %esi
  8031cf:	5f                   	pop    %edi
  8031d0:	5d                   	pop    %ebp
  8031d1:	c3                   	ret    
  8031d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8031d8:	39 f2                	cmp    %esi,%edx
  8031da:	72 06                	jb     8031e2 <__udivdi3+0x102>
  8031dc:	31 c0                	xor    %eax,%eax
  8031de:	39 eb                	cmp    %ebp,%ebx
  8031e0:	77 d2                	ja     8031b4 <__udivdi3+0xd4>
  8031e2:	b8 01 00 00 00       	mov    $0x1,%eax
  8031e7:	eb cb                	jmp    8031b4 <__udivdi3+0xd4>
  8031e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8031f0:	89 d8                	mov    %ebx,%eax
  8031f2:	31 ff                	xor    %edi,%edi
  8031f4:	eb be                	jmp    8031b4 <__udivdi3+0xd4>
  8031f6:	66 90                	xchg   %ax,%ax
  8031f8:	66 90                	xchg   %ax,%ax
  8031fa:	66 90                	xchg   %ax,%ax
  8031fc:	66 90                	xchg   %ax,%ax
  8031fe:	66 90                	xchg   %ax,%ax

00803200 <__umoddi3>:
  803200:	55                   	push   %ebp
  803201:	57                   	push   %edi
  803202:	56                   	push   %esi
  803203:	53                   	push   %ebx
  803204:	83 ec 1c             	sub    $0x1c,%esp
  803207:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80320b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80320f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  803213:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803217:	85 ed                	test   %ebp,%ebp
  803219:	89 f0                	mov    %esi,%eax
  80321b:	89 da                	mov    %ebx,%edx
  80321d:	75 19                	jne    803238 <__umoddi3+0x38>
  80321f:	39 df                	cmp    %ebx,%edi
  803221:	0f 86 b1 00 00 00    	jbe    8032d8 <__umoddi3+0xd8>
  803227:	f7 f7                	div    %edi
  803229:	89 d0                	mov    %edx,%eax
  80322b:	31 d2                	xor    %edx,%edx
  80322d:	83 c4 1c             	add    $0x1c,%esp
  803230:	5b                   	pop    %ebx
  803231:	5e                   	pop    %esi
  803232:	5f                   	pop    %edi
  803233:	5d                   	pop    %ebp
  803234:	c3                   	ret    
  803235:	8d 76 00             	lea    0x0(%esi),%esi
  803238:	39 dd                	cmp    %ebx,%ebp
  80323a:	77 f1                	ja     80322d <__umoddi3+0x2d>
  80323c:	0f bd cd             	bsr    %ebp,%ecx
  80323f:	83 f1 1f             	xor    $0x1f,%ecx
  803242:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  803246:	0f 84 b4 00 00 00    	je     803300 <__umoddi3+0x100>
  80324c:	b8 20 00 00 00       	mov    $0x20,%eax
  803251:	89 c2                	mov    %eax,%edx
  803253:	8b 44 24 04          	mov    0x4(%esp),%eax
  803257:	29 c2                	sub    %eax,%edx
  803259:	89 c1                	mov    %eax,%ecx
  80325b:	89 f8                	mov    %edi,%eax
  80325d:	d3 e5                	shl    %cl,%ebp
  80325f:	89 d1                	mov    %edx,%ecx
  803261:	89 54 24 0c          	mov    %edx,0xc(%esp)
  803265:	d3 e8                	shr    %cl,%eax
  803267:	09 c5                	or     %eax,%ebp
  803269:	8b 44 24 04          	mov    0x4(%esp),%eax
  80326d:	89 c1                	mov    %eax,%ecx
  80326f:	d3 e7                	shl    %cl,%edi
  803271:	89 d1                	mov    %edx,%ecx
  803273:	89 7c 24 08          	mov    %edi,0x8(%esp)
  803277:	89 df                	mov    %ebx,%edi
  803279:	d3 ef                	shr    %cl,%edi
  80327b:	89 c1                	mov    %eax,%ecx
  80327d:	89 f0                	mov    %esi,%eax
  80327f:	d3 e3                	shl    %cl,%ebx
  803281:	89 d1                	mov    %edx,%ecx
  803283:	89 fa                	mov    %edi,%edx
  803285:	d3 e8                	shr    %cl,%eax
  803287:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80328c:	09 d8                	or     %ebx,%eax
  80328e:	f7 f5                	div    %ebp
  803290:	d3 e6                	shl    %cl,%esi
  803292:	89 d1                	mov    %edx,%ecx
  803294:	f7 64 24 08          	mull   0x8(%esp)
  803298:	39 d1                	cmp    %edx,%ecx
  80329a:	89 c3                	mov    %eax,%ebx
  80329c:	89 d7                	mov    %edx,%edi
  80329e:	72 06                	jb     8032a6 <__umoddi3+0xa6>
  8032a0:	75 0e                	jne    8032b0 <__umoddi3+0xb0>
  8032a2:	39 c6                	cmp    %eax,%esi
  8032a4:	73 0a                	jae    8032b0 <__umoddi3+0xb0>
  8032a6:	2b 44 24 08          	sub    0x8(%esp),%eax
  8032aa:	19 ea                	sbb    %ebp,%edx
  8032ac:	89 d7                	mov    %edx,%edi
  8032ae:	89 c3                	mov    %eax,%ebx
  8032b0:	89 ca                	mov    %ecx,%edx
  8032b2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8032b7:	29 de                	sub    %ebx,%esi
  8032b9:	19 fa                	sbb    %edi,%edx
  8032bb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  8032bf:	89 d0                	mov    %edx,%eax
  8032c1:	d3 e0                	shl    %cl,%eax
  8032c3:	89 d9                	mov    %ebx,%ecx
  8032c5:	d3 ee                	shr    %cl,%esi
  8032c7:	d3 ea                	shr    %cl,%edx
  8032c9:	09 f0                	or     %esi,%eax
  8032cb:	83 c4 1c             	add    $0x1c,%esp
  8032ce:	5b                   	pop    %ebx
  8032cf:	5e                   	pop    %esi
  8032d0:	5f                   	pop    %edi
  8032d1:	5d                   	pop    %ebp
  8032d2:	c3                   	ret    
  8032d3:	90                   	nop
  8032d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8032d8:	85 ff                	test   %edi,%edi
  8032da:	89 f9                	mov    %edi,%ecx
  8032dc:	75 0b                	jne    8032e9 <__umoddi3+0xe9>
  8032de:	b8 01 00 00 00       	mov    $0x1,%eax
  8032e3:	31 d2                	xor    %edx,%edx
  8032e5:	f7 f7                	div    %edi
  8032e7:	89 c1                	mov    %eax,%ecx
  8032e9:	89 d8                	mov    %ebx,%eax
  8032eb:	31 d2                	xor    %edx,%edx
  8032ed:	f7 f1                	div    %ecx
  8032ef:	89 f0                	mov    %esi,%eax
  8032f1:	f7 f1                	div    %ecx
  8032f3:	e9 31 ff ff ff       	jmp    803229 <__umoddi3+0x29>
  8032f8:	90                   	nop
  8032f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803300:	39 dd                	cmp    %ebx,%ebp
  803302:	72 08                	jb     80330c <__umoddi3+0x10c>
  803304:	39 f7                	cmp    %esi,%edi
  803306:	0f 87 21 ff ff ff    	ja     80322d <__umoddi3+0x2d>
  80330c:	89 da                	mov    %ebx,%edx
  80330e:	89 f0                	mov    %esi,%eax
  803310:	29 f8                	sub    %edi,%eax
  803312:	19 ea                	sbb    %ebp,%edx
  803314:	e9 14 ff ff ff       	jmp    80322d <__umoddi3+0x2d>
