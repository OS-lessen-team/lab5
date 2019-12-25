
obj/user/echo.debug：     文件格式 elf32-i386


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
  80002c:	e8 b3 00 00 00       	call   8000e4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80003f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i, nflag;

	nflag = 0;
  800042:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  800049:	83 ff 01             	cmp    $0x1,%edi
  80004c:	7f 07                	jg     800055 <umain+0x22>
		nflag = 1;
		argc--;
		argv++;
	}
	for (i = 1; i < argc; i++) {
  80004e:	bb 01 00 00 00       	mov    $0x1,%ebx
  800053:	eb 4c                	jmp    8000a1 <umain+0x6e>
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  800055:	83 ec 08             	sub    $0x8,%esp
  800058:	68 60 1e 80 00       	push   $0x801e60
  80005d:	ff 76 04             	pushl  0x4(%esi)
  800060:	e8 bc 01 00 00       	call   800221 <strcmp>
  800065:	83 c4 10             	add    $0x10,%esp
	nflag = 0;
  800068:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  80006f:	85 c0                	test   %eax,%eax
  800071:	75 db                	jne    80004e <umain+0x1b>
		argc--;
  800073:	83 ef 01             	sub    $0x1,%edi
		argv++;
  800076:	83 c6 04             	add    $0x4,%esi
		nflag = 1;
  800079:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
  800080:	eb cc                	jmp    80004e <umain+0x1b>
		if (i > 1)
			write(1, " ", 1);
		write(1, argv[i], strlen(argv[i]));
  800082:	83 ec 0c             	sub    $0xc,%esp
  800085:	ff 34 9e             	pushl  (%esi,%ebx,4)
  800088:	e8 b7 00 00 00       	call   800144 <strlen>
  80008d:	83 c4 0c             	add    $0xc,%esp
  800090:	50                   	push   %eax
  800091:	ff 34 9e             	pushl  (%esi,%ebx,4)
  800094:	6a 01                	push   $0x1
  800096:	e8 7f 0a 00 00       	call   800b1a <write>
	for (i = 1; i < argc; i++) {
  80009b:	83 c3 01             	add    $0x1,%ebx
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	39 df                	cmp    %ebx,%edi
  8000a3:	7e 1b                	jle    8000c0 <umain+0x8d>
		if (i > 1)
  8000a5:	83 fb 01             	cmp    $0x1,%ebx
  8000a8:	7e d8                	jle    800082 <umain+0x4f>
			write(1, " ", 1);
  8000aa:	83 ec 04             	sub    $0x4,%esp
  8000ad:	6a 01                	push   $0x1
  8000af:	68 63 1e 80 00       	push   $0x801e63
  8000b4:	6a 01                	push   $0x1
  8000b6:	e8 5f 0a 00 00       	call   800b1a <write>
  8000bb:	83 c4 10             	add    $0x10,%esp
  8000be:	eb c2                	jmp    800082 <umain+0x4f>
	}
	if (!nflag)
  8000c0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000c4:	74 08                	je     8000ce <umain+0x9b>
		write(1, "\n", 1);
}
  8000c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000c9:	5b                   	pop    %ebx
  8000ca:	5e                   	pop    %esi
  8000cb:	5f                   	pop    %edi
  8000cc:	5d                   	pop    %ebp
  8000cd:	c3                   	ret    
		write(1, "\n", 1);
  8000ce:	83 ec 04             	sub    $0x4,%esp
  8000d1:	6a 01                	push   $0x1
  8000d3:	68 73 1f 80 00       	push   $0x801f73
  8000d8:	6a 01                	push   $0x1
  8000da:	e8 3b 0a 00 00       	call   800b1a <write>
  8000df:	83 c4 10             	add    $0x10,%esp
}
  8000e2:	eb e2                	jmp    8000c6 <umain+0x93>

008000e4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
  8000e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000ec:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  8000ef:	e8 42 04 00 00       	call   800536 <sys_getenvid>
	thisenv = envs + ENVX(envid); 
  8000f4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000fc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800101:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800106:	85 db                	test   %ebx,%ebx
  800108:	7e 07                	jle    800111 <libmain+0x2d>
		binaryname = argv[0];
  80010a:	8b 06                	mov    (%esi),%eax
  80010c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800111:	83 ec 08             	sub    $0x8,%esp
  800114:	56                   	push   %esi
  800115:	53                   	push   %ebx
  800116:	e8 18 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80011b:	e8 0a 00 00 00       	call   80012a <exit>
}
  800120:	83 c4 10             	add    $0x10,%esp
  800123:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800126:	5b                   	pop    %ebx
  800127:	5e                   	pop    %esi
  800128:	5d                   	pop    %ebp
  800129:	c3                   	ret    

0080012a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800130:	e8 06 08 00 00       	call   80093b <close_all>
	sys_env_destroy(0);
  800135:	83 ec 0c             	sub    $0xc,%esp
  800138:	6a 00                	push   $0x0
  80013a:	e8 b6 03 00 00       	call   8004f5 <sys_env_destroy>
}
  80013f:	83 c4 10             	add    $0x10,%esp
  800142:	c9                   	leave  
  800143:	c3                   	ret    

00800144 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80014a:	b8 00 00 00 00       	mov    $0x0,%eax
  80014f:	eb 03                	jmp    800154 <strlen+0x10>
		n++;
  800151:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800154:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800158:	75 f7                	jne    800151 <strlen+0xd>
	return n;
}
  80015a:	5d                   	pop    %ebp
  80015b:	c3                   	ret    

0080015c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800162:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800165:	b8 00 00 00 00       	mov    $0x0,%eax
  80016a:	eb 03                	jmp    80016f <strnlen+0x13>
		n++;
  80016c:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80016f:	39 d0                	cmp    %edx,%eax
  800171:	74 06                	je     800179 <strnlen+0x1d>
  800173:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800177:	75 f3                	jne    80016c <strnlen+0x10>
	return n;
}
  800179:	5d                   	pop    %ebp
  80017a:	c3                   	ret    

0080017b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80017b:	55                   	push   %ebp
  80017c:	89 e5                	mov    %esp,%ebp
  80017e:	53                   	push   %ebx
  80017f:	8b 45 08             	mov    0x8(%ebp),%eax
  800182:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800185:	89 c2                	mov    %eax,%edx
  800187:	83 c1 01             	add    $0x1,%ecx
  80018a:	83 c2 01             	add    $0x1,%edx
  80018d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800191:	88 5a ff             	mov    %bl,-0x1(%edx)
  800194:	84 db                	test   %bl,%bl
  800196:	75 ef                	jne    800187 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800198:	5b                   	pop    %ebx
  800199:	5d                   	pop    %ebp
  80019a:	c3                   	ret    

0080019b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80019b:	55                   	push   %ebp
  80019c:	89 e5                	mov    %esp,%ebp
  80019e:	53                   	push   %ebx
  80019f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8001a2:	53                   	push   %ebx
  8001a3:	e8 9c ff ff ff       	call   800144 <strlen>
  8001a8:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8001ab:	ff 75 0c             	pushl  0xc(%ebp)
  8001ae:	01 d8                	add    %ebx,%eax
  8001b0:	50                   	push   %eax
  8001b1:	e8 c5 ff ff ff       	call   80017b <strcpy>
	return dst;
}
  8001b6:	89 d8                	mov    %ebx,%eax
  8001b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001bb:	c9                   	leave  
  8001bc:	c3                   	ret    

008001bd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8001bd:	55                   	push   %ebp
  8001be:	89 e5                	mov    %esp,%ebp
  8001c0:	56                   	push   %esi
  8001c1:	53                   	push   %ebx
  8001c2:	8b 75 08             	mov    0x8(%ebp),%esi
  8001c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c8:	89 f3                	mov    %esi,%ebx
  8001ca:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8001cd:	89 f2                	mov    %esi,%edx
  8001cf:	eb 0f                	jmp    8001e0 <strncpy+0x23>
		*dst++ = *src;
  8001d1:	83 c2 01             	add    $0x1,%edx
  8001d4:	0f b6 01             	movzbl (%ecx),%eax
  8001d7:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8001da:	80 39 01             	cmpb   $0x1,(%ecx)
  8001dd:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8001e0:	39 da                	cmp    %ebx,%edx
  8001e2:	75 ed                	jne    8001d1 <strncpy+0x14>
	}
	return ret;
}
  8001e4:	89 f0                	mov    %esi,%eax
  8001e6:	5b                   	pop    %ebx
  8001e7:	5e                   	pop    %esi
  8001e8:	5d                   	pop    %ebp
  8001e9:	c3                   	ret    

008001ea <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8001ea:	55                   	push   %ebp
  8001eb:	89 e5                	mov    %esp,%ebp
  8001ed:	56                   	push   %esi
  8001ee:	53                   	push   %ebx
  8001ef:	8b 75 08             	mov    0x8(%ebp),%esi
  8001f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001f5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001f8:	89 f0                	mov    %esi,%eax
  8001fa:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8001fe:	85 c9                	test   %ecx,%ecx
  800200:	75 0b                	jne    80020d <strlcpy+0x23>
  800202:	eb 17                	jmp    80021b <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800204:	83 c2 01             	add    $0x1,%edx
  800207:	83 c0 01             	add    $0x1,%eax
  80020a:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  80020d:	39 d8                	cmp    %ebx,%eax
  80020f:	74 07                	je     800218 <strlcpy+0x2e>
  800211:	0f b6 0a             	movzbl (%edx),%ecx
  800214:	84 c9                	test   %cl,%cl
  800216:	75 ec                	jne    800204 <strlcpy+0x1a>
		*dst = '\0';
  800218:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80021b:	29 f0                	sub    %esi,%eax
}
  80021d:	5b                   	pop    %ebx
  80021e:	5e                   	pop    %esi
  80021f:	5d                   	pop    %ebp
  800220:	c3                   	ret    

00800221 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800227:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80022a:	eb 06                	jmp    800232 <strcmp+0x11>
		p++, q++;
  80022c:	83 c1 01             	add    $0x1,%ecx
  80022f:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800232:	0f b6 01             	movzbl (%ecx),%eax
  800235:	84 c0                	test   %al,%al
  800237:	74 04                	je     80023d <strcmp+0x1c>
  800239:	3a 02                	cmp    (%edx),%al
  80023b:	74 ef                	je     80022c <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80023d:	0f b6 c0             	movzbl %al,%eax
  800240:	0f b6 12             	movzbl (%edx),%edx
  800243:	29 d0                	sub    %edx,%eax
}
  800245:	5d                   	pop    %ebp
  800246:	c3                   	ret    

00800247 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800247:	55                   	push   %ebp
  800248:	89 e5                	mov    %esp,%ebp
  80024a:	53                   	push   %ebx
  80024b:	8b 45 08             	mov    0x8(%ebp),%eax
  80024e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800251:	89 c3                	mov    %eax,%ebx
  800253:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800256:	eb 06                	jmp    80025e <strncmp+0x17>
		n--, p++, q++;
  800258:	83 c0 01             	add    $0x1,%eax
  80025b:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80025e:	39 d8                	cmp    %ebx,%eax
  800260:	74 16                	je     800278 <strncmp+0x31>
  800262:	0f b6 08             	movzbl (%eax),%ecx
  800265:	84 c9                	test   %cl,%cl
  800267:	74 04                	je     80026d <strncmp+0x26>
  800269:	3a 0a                	cmp    (%edx),%cl
  80026b:	74 eb                	je     800258 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80026d:	0f b6 00             	movzbl (%eax),%eax
  800270:	0f b6 12             	movzbl (%edx),%edx
  800273:	29 d0                	sub    %edx,%eax
}
  800275:	5b                   	pop    %ebx
  800276:	5d                   	pop    %ebp
  800277:	c3                   	ret    
		return 0;
  800278:	b8 00 00 00 00       	mov    $0x0,%eax
  80027d:	eb f6                	jmp    800275 <strncmp+0x2e>

0080027f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80027f:	55                   	push   %ebp
  800280:	89 e5                	mov    %esp,%ebp
  800282:	8b 45 08             	mov    0x8(%ebp),%eax
  800285:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800289:	0f b6 10             	movzbl (%eax),%edx
  80028c:	84 d2                	test   %dl,%dl
  80028e:	74 09                	je     800299 <strchr+0x1a>
		if (*s == c)
  800290:	38 ca                	cmp    %cl,%dl
  800292:	74 0a                	je     80029e <strchr+0x1f>
	for (; *s; s++)
  800294:	83 c0 01             	add    $0x1,%eax
  800297:	eb f0                	jmp    800289 <strchr+0xa>
			return (char *) s;
	return 0;
  800299:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80029e:	5d                   	pop    %ebp
  80029f:	c3                   	ret    

008002a0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8002aa:	eb 03                	jmp    8002af <strfind+0xf>
  8002ac:	83 c0 01             	add    $0x1,%eax
  8002af:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8002b2:	38 ca                	cmp    %cl,%dl
  8002b4:	74 04                	je     8002ba <strfind+0x1a>
  8002b6:	84 d2                	test   %dl,%dl
  8002b8:	75 f2                	jne    8002ac <strfind+0xc>
			break;
	return (char *) s;
}
  8002ba:	5d                   	pop    %ebp
  8002bb:	c3                   	ret    

008002bc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	57                   	push   %edi
  8002c0:	56                   	push   %esi
  8002c1:	53                   	push   %ebx
  8002c2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8002c5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8002c8:	85 c9                	test   %ecx,%ecx
  8002ca:	74 13                	je     8002df <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8002cc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8002d2:	75 05                	jne    8002d9 <memset+0x1d>
  8002d4:	f6 c1 03             	test   $0x3,%cl
  8002d7:	74 0d                	je     8002e6 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8002d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002dc:	fc                   	cld    
  8002dd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8002df:	89 f8                	mov    %edi,%eax
  8002e1:	5b                   	pop    %ebx
  8002e2:	5e                   	pop    %esi
  8002e3:	5f                   	pop    %edi
  8002e4:	5d                   	pop    %ebp
  8002e5:	c3                   	ret    
		c &= 0xFF;
  8002e6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8002ea:	89 d3                	mov    %edx,%ebx
  8002ec:	c1 e3 08             	shl    $0x8,%ebx
  8002ef:	89 d0                	mov    %edx,%eax
  8002f1:	c1 e0 18             	shl    $0x18,%eax
  8002f4:	89 d6                	mov    %edx,%esi
  8002f6:	c1 e6 10             	shl    $0x10,%esi
  8002f9:	09 f0                	or     %esi,%eax
  8002fb:	09 c2                	or     %eax,%edx
  8002fd:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  8002ff:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800302:	89 d0                	mov    %edx,%eax
  800304:	fc                   	cld    
  800305:	f3 ab                	rep stos %eax,%es:(%edi)
  800307:	eb d6                	jmp    8002df <memset+0x23>

00800309 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800309:	55                   	push   %ebp
  80030a:	89 e5                	mov    %esp,%ebp
  80030c:	57                   	push   %edi
  80030d:	56                   	push   %esi
  80030e:	8b 45 08             	mov    0x8(%ebp),%eax
  800311:	8b 75 0c             	mov    0xc(%ebp),%esi
  800314:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800317:	39 c6                	cmp    %eax,%esi
  800319:	73 35                	jae    800350 <memmove+0x47>
  80031b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80031e:	39 c2                	cmp    %eax,%edx
  800320:	76 2e                	jbe    800350 <memmove+0x47>
		s += n;
		d += n;
  800322:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800325:	89 d6                	mov    %edx,%esi
  800327:	09 fe                	or     %edi,%esi
  800329:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80032f:	74 0c                	je     80033d <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800331:	83 ef 01             	sub    $0x1,%edi
  800334:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800337:	fd                   	std    
  800338:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80033a:	fc                   	cld    
  80033b:	eb 21                	jmp    80035e <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80033d:	f6 c1 03             	test   $0x3,%cl
  800340:	75 ef                	jne    800331 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800342:	83 ef 04             	sub    $0x4,%edi
  800345:	8d 72 fc             	lea    -0x4(%edx),%esi
  800348:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80034b:	fd                   	std    
  80034c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80034e:	eb ea                	jmp    80033a <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800350:	89 f2                	mov    %esi,%edx
  800352:	09 c2                	or     %eax,%edx
  800354:	f6 c2 03             	test   $0x3,%dl
  800357:	74 09                	je     800362 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800359:	89 c7                	mov    %eax,%edi
  80035b:	fc                   	cld    
  80035c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80035e:	5e                   	pop    %esi
  80035f:	5f                   	pop    %edi
  800360:	5d                   	pop    %ebp
  800361:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800362:	f6 c1 03             	test   $0x3,%cl
  800365:	75 f2                	jne    800359 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800367:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80036a:	89 c7                	mov    %eax,%edi
  80036c:	fc                   	cld    
  80036d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80036f:	eb ed                	jmp    80035e <memmove+0x55>

00800371 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800374:	ff 75 10             	pushl  0x10(%ebp)
  800377:	ff 75 0c             	pushl  0xc(%ebp)
  80037a:	ff 75 08             	pushl  0x8(%ebp)
  80037d:	e8 87 ff ff ff       	call   800309 <memmove>
}
  800382:	c9                   	leave  
  800383:	c3                   	ret    

00800384 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	56                   	push   %esi
  800388:	53                   	push   %ebx
  800389:	8b 45 08             	mov    0x8(%ebp),%eax
  80038c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80038f:	89 c6                	mov    %eax,%esi
  800391:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800394:	39 f0                	cmp    %esi,%eax
  800396:	74 1c                	je     8003b4 <memcmp+0x30>
		if (*s1 != *s2)
  800398:	0f b6 08             	movzbl (%eax),%ecx
  80039b:	0f b6 1a             	movzbl (%edx),%ebx
  80039e:	38 d9                	cmp    %bl,%cl
  8003a0:	75 08                	jne    8003aa <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8003a2:	83 c0 01             	add    $0x1,%eax
  8003a5:	83 c2 01             	add    $0x1,%edx
  8003a8:	eb ea                	jmp    800394 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8003aa:	0f b6 c1             	movzbl %cl,%eax
  8003ad:	0f b6 db             	movzbl %bl,%ebx
  8003b0:	29 d8                	sub    %ebx,%eax
  8003b2:	eb 05                	jmp    8003b9 <memcmp+0x35>
	}

	return 0;
  8003b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003b9:	5b                   	pop    %ebx
  8003ba:	5e                   	pop    %esi
  8003bb:	5d                   	pop    %ebp
  8003bc:	c3                   	ret    

008003bd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8003bd:	55                   	push   %ebp
  8003be:	89 e5                	mov    %esp,%ebp
  8003c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8003c6:	89 c2                	mov    %eax,%edx
  8003c8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8003cb:	39 d0                	cmp    %edx,%eax
  8003cd:	73 09                	jae    8003d8 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8003cf:	38 08                	cmp    %cl,(%eax)
  8003d1:	74 05                	je     8003d8 <memfind+0x1b>
	for (; s < ends; s++)
  8003d3:	83 c0 01             	add    $0x1,%eax
  8003d6:	eb f3                	jmp    8003cb <memfind+0xe>
			break;
	return (void *) s;
}
  8003d8:	5d                   	pop    %ebp
  8003d9:	c3                   	ret    

008003da <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8003da:	55                   	push   %ebp
  8003db:	89 e5                	mov    %esp,%ebp
  8003dd:	57                   	push   %edi
  8003de:	56                   	push   %esi
  8003df:	53                   	push   %ebx
  8003e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003e3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8003e6:	eb 03                	jmp    8003eb <strtol+0x11>
		s++;
  8003e8:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  8003eb:	0f b6 01             	movzbl (%ecx),%eax
  8003ee:	3c 20                	cmp    $0x20,%al
  8003f0:	74 f6                	je     8003e8 <strtol+0xe>
  8003f2:	3c 09                	cmp    $0x9,%al
  8003f4:	74 f2                	je     8003e8 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8003f6:	3c 2b                	cmp    $0x2b,%al
  8003f8:	74 2e                	je     800428 <strtol+0x4e>
	int neg = 0;
  8003fa:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8003ff:	3c 2d                	cmp    $0x2d,%al
  800401:	74 2f                	je     800432 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800403:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800409:	75 05                	jne    800410 <strtol+0x36>
  80040b:	80 39 30             	cmpb   $0x30,(%ecx)
  80040e:	74 2c                	je     80043c <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800410:	85 db                	test   %ebx,%ebx
  800412:	75 0a                	jne    80041e <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800414:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800419:	80 39 30             	cmpb   $0x30,(%ecx)
  80041c:	74 28                	je     800446 <strtol+0x6c>
		base = 10;
  80041e:	b8 00 00 00 00       	mov    $0x0,%eax
  800423:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800426:	eb 50                	jmp    800478 <strtol+0x9e>
		s++;
  800428:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  80042b:	bf 00 00 00 00       	mov    $0x0,%edi
  800430:	eb d1                	jmp    800403 <strtol+0x29>
		s++, neg = 1;
  800432:	83 c1 01             	add    $0x1,%ecx
  800435:	bf 01 00 00 00       	mov    $0x1,%edi
  80043a:	eb c7                	jmp    800403 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80043c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800440:	74 0e                	je     800450 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800442:	85 db                	test   %ebx,%ebx
  800444:	75 d8                	jne    80041e <strtol+0x44>
		s++, base = 8;
  800446:	83 c1 01             	add    $0x1,%ecx
  800449:	bb 08 00 00 00       	mov    $0x8,%ebx
  80044e:	eb ce                	jmp    80041e <strtol+0x44>
		s += 2, base = 16;
  800450:	83 c1 02             	add    $0x2,%ecx
  800453:	bb 10 00 00 00       	mov    $0x10,%ebx
  800458:	eb c4                	jmp    80041e <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  80045a:	8d 72 9f             	lea    -0x61(%edx),%esi
  80045d:	89 f3                	mov    %esi,%ebx
  80045f:	80 fb 19             	cmp    $0x19,%bl
  800462:	77 29                	ja     80048d <strtol+0xb3>
			dig = *s - 'a' + 10;
  800464:	0f be d2             	movsbl %dl,%edx
  800467:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  80046a:	3b 55 10             	cmp    0x10(%ebp),%edx
  80046d:	7d 30                	jge    80049f <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  80046f:	83 c1 01             	add    $0x1,%ecx
  800472:	0f af 45 10          	imul   0x10(%ebp),%eax
  800476:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800478:	0f b6 11             	movzbl (%ecx),%edx
  80047b:	8d 72 d0             	lea    -0x30(%edx),%esi
  80047e:	89 f3                	mov    %esi,%ebx
  800480:	80 fb 09             	cmp    $0x9,%bl
  800483:	77 d5                	ja     80045a <strtol+0x80>
			dig = *s - '0';
  800485:	0f be d2             	movsbl %dl,%edx
  800488:	83 ea 30             	sub    $0x30,%edx
  80048b:	eb dd                	jmp    80046a <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  80048d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800490:	89 f3                	mov    %esi,%ebx
  800492:	80 fb 19             	cmp    $0x19,%bl
  800495:	77 08                	ja     80049f <strtol+0xc5>
			dig = *s - 'A' + 10;
  800497:	0f be d2             	movsbl %dl,%edx
  80049a:	83 ea 37             	sub    $0x37,%edx
  80049d:	eb cb                	jmp    80046a <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  80049f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8004a3:	74 05                	je     8004aa <strtol+0xd0>
		*endptr = (char *) s;
  8004a5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004a8:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  8004aa:	89 c2                	mov    %eax,%edx
  8004ac:	f7 da                	neg    %edx
  8004ae:	85 ff                	test   %edi,%edi
  8004b0:	0f 45 c2             	cmovne %edx,%eax
}
  8004b3:	5b                   	pop    %ebx
  8004b4:	5e                   	pop    %esi
  8004b5:	5f                   	pop    %edi
  8004b6:	5d                   	pop    %ebp
  8004b7:	c3                   	ret    

008004b8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8004b8:	55                   	push   %ebp
  8004b9:	89 e5                	mov    %esp,%ebp
  8004bb:	57                   	push   %edi
  8004bc:	56                   	push   %esi
  8004bd:	53                   	push   %ebx
	asm volatile("int %1\n"
  8004be:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8004c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004c9:	89 c3                	mov    %eax,%ebx
  8004cb:	89 c7                	mov    %eax,%edi
  8004cd:	89 c6                	mov    %eax,%esi
  8004cf:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8004d1:	5b                   	pop    %ebx
  8004d2:	5e                   	pop    %esi
  8004d3:	5f                   	pop    %edi
  8004d4:	5d                   	pop    %ebp
  8004d5:	c3                   	ret    

008004d6 <sys_cgetc>:

int
sys_cgetc(void)
{
  8004d6:	55                   	push   %ebp
  8004d7:	89 e5                	mov    %esp,%ebp
  8004d9:	57                   	push   %edi
  8004da:	56                   	push   %esi
  8004db:	53                   	push   %ebx
	asm volatile("int %1\n"
  8004dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8004e6:	89 d1                	mov    %edx,%ecx
  8004e8:	89 d3                	mov    %edx,%ebx
  8004ea:	89 d7                	mov    %edx,%edi
  8004ec:	89 d6                	mov    %edx,%esi
  8004ee:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8004f0:	5b                   	pop    %ebx
  8004f1:	5e                   	pop    %esi
  8004f2:	5f                   	pop    %edi
  8004f3:	5d                   	pop    %ebp
  8004f4:	c3                   	ret    

008004f5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8004f5:	55                   	push   %ebp
  8004f6:	89 e5                	mov    %esp,%ebp
  8004f8:	57                   	push   %edi
  8004f9:	56                   	push   %esi
  8004fa:	53                   	push   %ebx
  8004fb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8004fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800503:	8b 55 08             	mov    0x8(%ebp),%edx
  800506:	b8 03 00 00 00       	mov    $0x3,%eax
  80050b:	89 cb                	mov    %ecx,%ebx
  80050d:	89 cf                	mov    %ecx,%edi
  80050f:	89 ce                	mov    %ecx,%esi
  800511:	cd 30                	int    $0x30
	if(check && ret > 0)
  800513:	85 c0                	test   %eax,%eax
  800515:	7f 08                	jg     80051f <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800517:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80051a:	5b                   	pop    %ebx
  80051b:	5e                   	pop    %esi
  80051c:	5f                   	pop    %edi
  80051d:	5d                   	pop    %ebp
  80051e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80051f:	83 ec 0c             	sub    $0xc,%esp
  800522:	50                   	push   %eax
  800523:	6a 03                	push   $0x3
  800525:	68 6f 1e 80 00       	push   $0x801e6f
  80052a:	6a 23                	push   $0x23
  80052c:	68 8c 1e 80 00       	push   $0x801e8c
  800531:	e8 dd 0e 00 00       	call   801413 <_panic>

00800536 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800536:	55                   	push   %ebp
  800537:	89 e5                	mov    %esp,%ebp
  800539:	57                   	push   %edi
  80053a:	56                   	push   %esi
  80053b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80053c:	ba 00 00 00 00       	mov    $0x0,%edx
  800541:	b8 02 00 00 00       	mov    $0x2,%eax
  800546:	89 d1                	mov    %edx,%ecx
  800548:	89 d3                	mov    %edx,%ebx
  80054a:	89 d7                	mov    %edx,%edi
  80054c:	89 d6                	mov    %edx,%esi
  80054e:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800550:	5b                   	pop    %ebx
  800551:	5e                   	pop    %esi
  800552:	5f                   	pop    %edi
  800553:	5d                   	pop    %ebp
  800554:	c3                   	ret    

00800555 <sys_yield>:

void
sys_yield(void)
{
  800555:	55                   	push   %ebp
  800556:	89 e5                	mov    %esp,%ebp
  800558:	57                   	push   %edi
  800559:	56                   	push   %esi
  80055a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80055b:	ba 00 00 00 00       	mov    $0x0,%edx
  800560:	b8 0b 00 00 00       	mov    $0xb,%eax
  800565:	89 d1                	mov    %edx,%ecx
  800567:	89 d3                	mov    %edx,%ebx
  800569:	89 d7                	mov    %edx,%edi
  80056b:	89 d6                	mov    %edx,%esi
  80056d:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80056f:	5b                   	pop    %ebx
  800570:	5e                   	pop    %esi
  800571:	5f                   	pop    %edi
  800572:	5d                   	pop    %ebp
  800573:	c3                   	ret    

00800574 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800574:	55                   	push   %ebp
  800575:	89 e5                	mov    %esp,%ebp
  800577:	57                   	push   %edi
  800578:	56                   	push   %esi
  800579:	53                   	push   %ebx
  80057a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80057d:	be 00 00 00 00       	mov    $0x0,%esi
  800582:	8b 55 08             	mov    0x8(%ebp),%edx
  800585:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800588:	b8 04 00 00 00       	mov    $0x4,%eax
  80058d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800590:	89 f7                	mov    %esi,%edi
  800592:	cd 30                	int    $0x30
	if(check && ret > 0)
  800594:	85 c0                	test   %eax,%eax
  800596:	7f 08                	jg     8005a0 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800598:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80059b:	5b                   	pop    %ebx
  80059c:	5e                   	pop    %esi
  80059d:	5f                   	pop    %edi
  80059e:	5d                   	pop    %ebp
  80059f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8005a0:	83 ec 0c             	sub    $0xc,%esp
  8005a3:	50                   	push   %eax
  8005a4:	6a 04                	push   $0x4
  8005a6:	68 6f 1e 80 00       	push   $0x801e6f
  8005ab:	6a 23                	push   $0x23
  8005ad:	68 8c 1e 80 00       	push   $0x801e8c
  8005b2:	e8 5c 0e 00 00       	call   801413 <_panic>

008005b7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8005b7:	55                   	push   %ebp
  8005b8:	89 e5                	mov    %esp,%ebp
  8005ba:	57                   	push   %edi
  8005bb:	56                   	push   %esi
  8005bc:	53                   	push   %ebx
  8005bd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8005c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8005c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005c6:	b8 05 00 00 00       	mov    $0x5,%eax
  8005cb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005ce:	8b 7d 14             	mov    0x14(%ebp),%edi
  8005d1:	8b 75 18             	mov    0x18(%ebp),%esi
  8005d4:	cd 30                	int    $0x30
	if(check && ret > 0)
  8005d6:	85 c0                	test   %eax,%eax
  8005d8:	7f 08                	jg     8005e2 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8005da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005dd:	5b                   	pop    %ebx
  8005de:	5e                   	pop    %esi
  8005df:	5f                   	pop    %edi
  8005e0:	5d                   	pop    %ebp
  8005e1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8005e2:	83 ec 0c             	sub    $0xc,%esp
  8005e5:	50                   	push   %eax
  8005e6:	6a 05                	push   $0x5
  8005e8:	68 6f 1e 80 00       	push   $0x801e6f
  8005ed:	6a 23                	push   $0x23
  8005ef:	68 8c 1e 80 00       	push   $0x801e8c
  8005f4:	e8 1a 0e 00 00       	call   801413 <_panic>

008005f9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8005f9:	55                   	push   %ebp
  8005fa:	89 e5                	mov    %esp,%ebp
  8005fc:	57                   	push   %edi
  8005fd:	56                   	push   %esi
  8005fe:	53                   	push   %ebx
  8005ff:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800602:	bb 00 00 00 00       	mov    $0x0,%ebx
  800607:	8b 55 08             	mov    0x8(%ebp),%edx
  80060a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80060d:	b8 06 00 00 00       	mov    $0x6,%eax
  800612:	89 df                	mov    %ebx,%edi
  800614:	89 de                	mov    %ebx,%esi
  800616:	cd 30                	int    $0x30
	if(check && ret > 0)
  800618:	85 c0                	test   %eax,%eax
  80061a:	7f 08                	jg     800624 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80061c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80061f:	5b                   	pop    %ebx
  800620:	5e                   	pop    %esi
  800621:	5f                   	pop    %edi
  800622:	5d                   	pop    %ebp
  800623:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800624:	83 ec 0c             	sub    $0xc,%esp
  800627:	50                   	push   %eax
  800628:	6a 06                	push   $0x6
  80062a:	68 6f 1e 80 00       	push   $0x801e6f
  80062f:	6a 23                	push   $0x23
  800631:	68 8c 1e 80 00       	push   $0x801e8c
  800636:	e8 d8 0d 00 00       	call   801413 <_panic>

0080063b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80063b:	55                   	push   %ebp
  80063c:	89 e5                	mov    %esp,%ebp
  80063e:	57                   	push   %edi
  80063f:	56                   	push   %esi
  800640:	53                   	push   %ebx
  800641:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800644:	bb 00 00 00 00       	mov    $0x0,%ebx
  800649:	8b 55 08             	mov    0x8(%ebp),%edx
  80064c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80064f:	b8 08 00 00 00       	mov    $0x8,%eax
  800654:	89 df                	mov    %ebx,%edi
  800656:	89 de                	mov    %ebx,%esi
  800658:	cd 30                	int    $0x30
	if(check && ret > 0)
  80065a:	85 c0                	test   %eax,%eax
  80065c:	7f 08                	jg     800666 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80065e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800661:	5b                   	pop    %ebx
  800662:	5e                   	pop    %esi
  800663:	5f                   	pop    %edi
  800664:	5d                   	pop    %ebp
  800665:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800666:	83 ec 0c             	sub    $0xc,%esp
  800669:	50                   	push   %eax
  80066a:	6a 08                	push   $0x8
  80066c:	68 6f 1e 80 00       	push   $0x801e6f
  800671:	6a 23                	push   $0x23
  800673:	68 8c 1e 80 00       	push   $0x801e8c
  800678:	e8 96 0d 00 00       	call   801413 <_panic>

0080067d <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80067d:	55                   	push   %ebp
  80067e:	89 e5                	mov    %esp,%ebp
  800680:	57                   	push   %edi
  800681:	56                   	push   %esi
  800682:	53                   	push   %ebx
  800683:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800686:	bb 00 00 00 00       	mov    $0x0,%ebx
  80068b:	8b 55 08             	mov    0x8(%ebp),%edx
  80068e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800691:	b8 09 00 00 00       	mov    $0x9,%eax
  800696:	89 df                	mov    %ebx,%edi
  800698:	89 de                	mov    %ebx,%esi
  80069a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80069c:	85 c0                	test   %eax,%eax
  80069e:	7f 08                	jg     8006a8 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8006a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006a3:	5b                   	pop    %ebx
  8006a4:	5e                   	pop    %esi
  8006a5:	5f                   	pop    %edi
  8006a6:	5d                   	pop    %ebp
  8006a7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8006a8:	83 ec 0c             	sub    $0xc,%esp
  8006ab:	50                   	push   %eax
  8006ac:	6a 09                	push   $0x9
  8006ae:	68 6f 1e 80 00       	push   $0x801e6f
  8006b3:	6a 23                	push   $0x23
  8006b5:	68 8c 1e 80 00       	push   $0x801e8c
  8006ba:	e8 54 0d 00 00       	call   801413 <_panic>

008006bf <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8006bf:	55                   	push   %ebp
  8006c0:	89 e5                	mov    %esp,%ebp
  8006c2:	57                   	push   %edi
  8006c3:	56                   	push   %esi
  8006c4:	53                   	push   %ebx
  8006c5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8006c8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8006d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006d3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006d8:	89 df                	mov    %ebx,%edi
  8006da:	89 de                	mov    %ebx,%esi
  8006dc:	cd 30                	int    $0x30
	if(check && ret > 0)
  8006de:	85 c0                	test   %eax,%eax
  8006e0:	7f 08                	jg     8006ea <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8006e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006e5:	5b                   	pop    %ebx
  8006e6:	5e                   	pop    %esi
  8006e7:	5f                   	pop    %edi
  8006e8:	5d                   	pop    %ebp
  8006e9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8006ea:	83 ec 0c             	sub    $0xc,%esp
  8006ed:	50                   	push   %eax
  8006ee:	6a 0a                	push   $0xa
  8006f0:	68 6f 1e 80 00       	push   $0x801e6f
  8006f5:	6a 23                	push   $0x23
  8006f7:	68 8c 1e 80 00       	push   $0x801e8c
  8006fc:	e8 12 0d 00 00       	call   801413 <_panic>

00800701 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800701:	55                   	push   %ebp
  800702:	89 e5                	mov    %esp,%ebp
  800704:	57                   	push   %edi
  800705:	56                   	push   %esi
  800706:	53                   	push   %ebx
	asm volatile("int %1\n"
  800707:	8b 55 08             	mov    0x8(%ebp),%edx
  80070a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80070d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800712:	be 00 00 00 00       	mov    $0x0,%esi
  800717:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80071a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80071d:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80071f:	5b                   	pop    %ebx
  800720:	5e                   	pop    %esi
  800721:	5f                   	pop    %edi
  800722:	5d                   	pop    %ebp
  800723:	c3                   	ret    

00800724 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800724:	55                   	push   %ebp
  800725:	89 e5                	mov    %esp,%ebp
  800727:	57                   	push   %edi
  800728:	56                   	push   %esi
  800729:	53                   	push   %ebx
  80072a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80072d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800732:	8b 55 08             	mov    0x8(%ebp),%edx
  800735:	b8 0d 00 00 00       	mov    $0xd,%eax
  80073a:	89 cb                	mov    %ecx,%ebx
  80073c:	89 cf                	mov    %ecx,%edi
  80073e:	89 ce                	mov    %ecx,%esi
  800740:	cd 30                	int    $0x30
	if(check && ret > 0)
  800742:	85 c0                	test   %eax,%eax
  800744:	7f 08                	jg     80074e <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800746:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800749:	5b                   	pop    %ebx
  80074a:	5e                   	pop    %esi
  80074b:	5f                   	pop    %edi
  80074c:	5d                   	pop    %ebp
  80074d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80074e:	83 ec 0c             	sub    $0xc,%esp
  800751:	50                   	push   %eax
  800752:	6a 0d                	push   $0xd
  800754:	68 6f 1e 80 00       	push   $0x801e6f
  800759:	6a 23                	push   $0x23
  80075b:	68 8c 1e 80 00       	push   $0x801e8c
  800760:	e8 ae 0c 00 00       	call   801413 <_panic>

00800765 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800765:	55                   	push   %ebp
  800766:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800768:	8b 45 08             	mov    0x8(%ebp),%eax
  80076b:	05 00 00 00 30       	add    $0x30000000,%eax
  800770:	c1 e8 0c             	shr    $0xc,%eax
}
  800773:	5d                   	pop    %ebp
  800774:	c3                   	ret    

00800775 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800775:	55                   	push   %ebp
  800776:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800778:	8b 45 08             	mov    0x8(%ebp),%eax
  80077b:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800780:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800785:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80078a:	5d                   	pop    %ebp
  80078b:	c3                   	ret    

0080078c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80078c:	55                   	push   %ebp
  80078d:	89 e5                	mov    %esp,%ebp
  80078f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800792:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800797:	89 c2                	mov    %eax,%edx
  800799:	c1 ea 16             	shr    $0x16,%edx
  80079c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8007a3:	f6 c2 01             	test   $0x1,%dl
  8007a6:	74 2a                	je     8007d2 <fd_alloc+0x46>
  8007a8:	89 c2                	mov    %eax,%edx
  8007aa:	c1 ea 0c             	shr    $0xc,%edx
  8007ad:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8007b4:	f6 c2 01             	test   $0x1,%dl
  8007b7:	74 19                	je     8007d2 <fd_alloc+0x46>
  8007b9:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8007be:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8007c3:	75 d2                	jne    800797 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8007c5:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8007cb:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8007d0:	eb 07                	jmp    8007d9 <fd_alloc+0x4d>
			*fd_store = fd;
  8007d2:	89 01                	mov    %eax,(%ecx)
			return 0;
  8007d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007d9:	5d                   	pop    %ebp
  8007da:	c3                   	ret    

008007db <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8007db:	55                   	push   %ebp
  8007dc:	89 e5                	mov    %esp,%ebp
  8007de:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8007e1:	83 f8 1f             	cmp    $0x1f,%eax
  8007e4:	77 36                	ja     80081c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8007e6:	c1 e0 0c             	shl    $0xc,%eax
  8007e9:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8007ee:	89 c2                	mov    %eax,%edx
  8007f0:	c1 ea 16             	shr    $0x16,%edx
  8007f3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8007fa:	f6 c2 01             	test   $0x1,%dl
  8007fd:	74 24                	je     800823 <fd_lookup+0x48>
  8007ff:	89 c2                	mov    %eax,%edx
  800801:	c1 ea 0c             	shr    $0xc,%edx
  800804:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80080b:	f6 c2 01             	test   $0x1,%dl
  80080e:	74 1a                	je     80082a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800810:	8b 55 0c             	mov    0xc(%ebp),%edx
  800813:	89 02                	mov    %eax,(%edx)
	return 0;
  800815:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80081a:	5d                   	pop    %ebp
  80081b:	c3                   	ret    
		return -E_INVAL;
  80081c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800821:	eb f7                	jmp    80081a <fd_lookup+0x3f>
		return -E_INVAL;
  800823:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800828:	eb f0                	jmp    80081a <fd_lookup+0x3f>
  80082a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80082f:	eb e9                	jmp    80081a <fd_lookup+0x3f>

00800831 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800831:	55                   	push   %ebp
  800832:	89 e5                	mov    %esp,%ebp
  800834:	83 ec 08             	sub    $0x8,%esp
  800837:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80083a:	ba 18 1f 80 00       	mov    $0x801f18,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80083f:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800844:	39 08                	cmp    %ecx,(%eax)
  800846:	74 33                	je     80087b <dev_lookup+0x4a>
  800848:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  80084b:	8b 02                	mov    (%edx),%eax
  80084d:	85 c0                	test   %eax,%eax
  80084f:	75 f3                	jne    800844 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800851:	a1 04 40 80 00       	mov    0x804004,%eax
  800856:	8b 40 48             	mov    0x48(%eax),%eax
  800859:	83 ec 04             	sub    $0x4,%esp
  80085c:	51                   	push   %ecx
  80085d:	50                   	push   %eax
  80085e:	68 9c 1e 80 00       	push   $0x801e9c
  800863:	e8 86 0c 00 00       	call   8014ee <cprintf>
	*dev = 0;
  800868:	8b 45 0c             	mov    0xc(%ebp),%eax
  80086b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800871:	83 c4 10             	add    $0x10,%esp
  800874:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800879:	c9                   	leave  
  80087a:	c3                   	ret    
			*dev = devtab[i];
  80087b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80087e:	89 01                	mov    %eax,(%ecx)
			return 0;
  800880:	b8 00 00 00 00       	mov    $0x0,%eax
  800885:	eb f2                	jmp    800879 <dev_lookup+0x48>

00800887 <fd_close>:
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	57                   	push   %edi
  80088b:	56                   	push   %esi
  80088c:	53                   	push   %ebx
  80088d:	83 ec 1c             	sub    $0x1c,%esp
  800890:	8b 75 08             	mov    0x8(%ebp),%esi
  800893:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800896:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800899:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80089a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8008a0:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8008a3:	50                   	push   %eax
  8008a4:	e8 32 ff ff ff       	call   8007db <fd_lookup>
  8008a9:	89 c3                	mov    %eax,%ebx
  8008ab:	83 c4 08             	add    $0x8,%esp
  8008ae:	85 c0                	test   %eax,%eax
  8008b0:	78 05                	js     8008b7 <fd_close+0x30>
	    || fd != fd2)
  8008b2:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8008b5:	74 16                	je     8008cd <fd_close+0x46>
		return (must_exist ? r : 0);
  8008b7:	89 f8                	mov    %edi,%eax
  8008b9:	84 c0                	test   %al,%al
  8008bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c0:	0f 44 d8             	cmove  %eax,%ebx
}
  8008c3:	89 d8                	mov    %ebx,%eax
  8008c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008c8:	5b                   	pop    %ebx
  8008c9:	5e                   	pop    %esi
  8008ca:	5f                   	pop    %edi
  8008cb:	5d                   	pop    %ebp
  8008cc:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8008cd:	83 ec 08             	sub    $0x8,%esp
  8008d0:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8008d3:	50                   	push   %eax
  8008d4:	ff 36                	pushl  (%esi)
  8008d6:	e8 56 ff ff ff       	call   800831 <dev_lookup>
  8008db:	89 c3                	mov    %eax,%ebx
  8008dd:	83 c4 10             	add    $0x10,%esp
  8008e0:	85 c0                	test   %eax,%eax
  8008e2:	78 15                	js     8008f9 <fd_close+0x72>
		if (dev->dev_close)
  8008e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008e7:	8b 40 10             	mov    0x10(%eax),%eax
  8008ea:	85 c0                	test   %eax,%eax
  8008ec:	74 1b                	je     800909 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  8008ee:	83 ec 0c             	sub    $0xc,%esp
  8008f1:	56                   	push   %esi
  8008f2:	ff d0                	call   *%eax
  8008f4:	89 c3                	mov    %eax,%ebx
  8008f6:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8008f9:	83 ec 08             	sub    $0x8,%esp
  8008fc:	56                   	push   %esi
  8008fd:	6a 00                	push   $0x0
  8008ff:	e8 f5 fc ff ff       	call   8005f9 <sys_page_unmap>
	return r;
  800904:	83 c4 10             	add    $0x10,%esp
  800907:	eb ba                	jmp    8008c3 <fd_close+0x3c>
			r = 0;
  800909:	bb 00 00 00 00       	mov    $0x0,%ebx
  80090e:	eb e9                	jmp    8008f9 <fd_close+0x72>

00800910 <close>:

int
close(int fdnum)
{
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800916:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800919:	50                   	push   %eax
  80091a:	ff 75 08             	pushl  0x8(%ebp)
  80091d:	e8 b9 fe ff ff       	call   8007db <fd_lookup>
  800922:	83 c4 08             	add    $0x8,%esp
  800925:	85 c0                	test   %eax,%eax
  800927:	78 10                	js     800939 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800929:	83 ec 08             	sub    $0x8,%esp
  80092c:	6a 01                	push   $0x1
  80092e:	ff 75 f4             	pushl  -0xc(%ebp)
  800931:	e8 51 ff ff ff       	call   800887 <fd_close>
  800936:	83 c4 10             	add    $0x10,%esp
}
  800939:	c9                   	leave  
  80093a:	c3                   	ret    

0080093b <close_all>:

void
close_all(void)
{
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	53                   	push   %ebx
  80093f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800942:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800947:	83 ec 0c             	sub    $0xc,%esp
  80094a:	53                   	push   %ebx
  80094b:	e8 c0 ff ff ff       	call   800910 <close>
	for (i = 0; i < MAXFD; i++)
  800950:	83 c3 01             	add    $0x1,%ebx
  800953:	83 c4 10             	add    $0x10,%esp
  800956:	83 fb 20             	cmp    $0x20,%ebx
  800959:	75 ec                	jne    800947 <close_all+0xc>
}
  80095b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80095e:	c9                   	leave  
  80095f:	c3                   	ret    

00800960 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	57                   	push   %edi
  800964:	56                   	push   %esi
  800965:	53                   	push   %ebx
  800966:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800969:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80096c:	50                   	push   %eax
  80096d:	ff 75 08             	pushl  0x8(%ebp)
  800970:	e8 66 fe ff ff       	call   8007db <fd_lookup>
  800975:	89 c3                	mov    %eax,%ebx
  800977:	83 c4 08             	add    $0x8,%esp
  80097a:	85 c0                	test   %eax,%eax
  80097c:	0f 88 81 00 00 00    	js     800a03 <dup+0xa3>
		return r;
	close(newfdnum);
  800982:	83 ec 0c             	sub    $0xc,%esp
  800985:	ff 75 0c             	pushl  0xc(%ebp)
  800988:	e8 83 ff ff ff       	call   800910 <close>

	newfd = INDEX2FD(newfdnum);
  80098d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800990:	c1 e6 0c             	shl    $0xc,%esi
  800993:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800999:	83 c4 04             	add    $0x4,%esp
  80099c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80099f:	e8 d1 fd ff ff       	call   800775 <fd2data>
  8009a4:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8009a6:	89 34 24             	mov    %esi,(%esp)
  8009a9:	e8 c7 fd ff ff       	call   800775 <fd2data>
  8009ae:	83 c4 10             	add    $0x10,%esp
  8009b1:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8009b3:	89 d8                	mov    %ebx,%eax
  8009b5:	c1 e8 16             	shr    $0x16,%eax
  8009b8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8009bf:	a8 01                	test   $0x1,%al
  8009c1:	74 11                	je     8009d4 <dup+0x74>
  8009c3:	89 d8                	mov    %ebx,%eax
  8009c5:	c1 e8 0c             	shr    $0xc,%eax
  8009c8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8009cf:	f6 c2 01             	test   $0x1,%dl
  8009d2:	75 39                	jne    800a0d <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8009d4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009d7:	89 d0                	mov    %edx,%eax
  8009d9:	c1 e8 0c             	shr    $0xc,%eax
  8009dc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8009e3:	83 ec 0c             	sub    $0xc,%esp
  8009e6:	25 07 0e 00 00       	and    $0xe07,%eax
  8009eb:	50                   	push   %eax
  8009ec:	56                   	push   %esi
  8009ed:	6a 00                	push   $0x0
  8009ef:	52                   	push   %edx
  8009f0:	6a 00                	push   $0x0
  8009f2:	e8 c0 fb ff ff       	call   8005b7 <sys_page_map>
  8009f7:	89 c3                	mov    %eax,%ebx
  8009f9:	83 c4 20             	add    $0x20,%esp
  8009fc:	85 c0                	test   %eax,%eax
  8009fe:	78 31                	js     800a31 <dup+0xd1>
		goto err;

	return newfdnum;
  800a00:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800a03:	89 d8                	mov    %ebx,%eax
  800a05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a08:	5b                   	pop    %ebx
  800a09:	5e                   	pop    %esi
  800a0a:	5f                   	pop    %edi
  800a0b:	5d                   	pop    %ebp
  800a0c:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800a0d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800a14:	83 ec 0c             	sub    $0xc,%esp
  800a17:	25 07 0e 00 00       	and    $0xe07,%eax
  800a1c:	50                   	push   %eax
  800a1d:	57                   	push   %edi
  800a1e:	6a 00                	push   $0x0
  800a20:	53                   	push   %ebx
  800a21:	6a 00                	push   $0x0
  800a23:	e8 8f fb ff ff       	call   8005b7 <sys_page_map>
  800a28:	89 c3                	mov    %eax,%ebx
  800a2a:	83 c4 20             	add    $0x20,%esp
  800a2d:	85 c0                	test   %eax,%eax
  800a2f:	79 a3                	jns    8009d4 <dup+0x74>
	sys_page_unmap(0, newfd);
  800a31:	83 ec 08             	sub    $0x8,%esp
  800a34:	56                   	push   %esi
  800a35:	6a 00                	push   $0x0
  800a37:	e8 bd fb ff ff       	call   8005f9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800a3c:	83 c4 08             	add    $0x8,%esp
  800a3f:	57                   	push   %edi
  800a40:	6a 00                	push   $0x0
  800a42:	e8 b2 fb ff ff       	call   8005f9 <sys_page_unmap>
	return r;
  800a47:	83 c4 10             	add    $0x10,%esp
  800a4a:	eb b7                	jmp    800a03 <dup+0xa3>

00800a4c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800a4c:	55                   	push   %ebp
  800a4d:	89 e5                	mov    %esp,%ebp
  800a4f:	53                   	push   %ebx
  800a50:	83 ec 14             	sub    $0x14,%esp
  800a53:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a56:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a59:	50                   	push   %eax
  800a5a:	53                   	push   %ebx
  800a5b:	e8 7b fd ff ff       	call   8007db <fd_lookup>
  800a60:	83 c4 08             	add    $0x8,%esp
  800a63:	85 c0                	test   %eax,%eax
  800a65:	78 3f                	js     800aa6 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a67:	83 ec 08             	sub    $0x8,%esp
  800a6a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a6d:	50                   	push   %eax
  800a6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a71:	ff 30                	pushl  (%eax)
  800a73:	e8 b9 fd ff ff       	call   800831 <dev_lookup>
  800a78:	83 c4 10             	add    $0x10,%esp
  800a7b:	85 c0                	test   %eax,%eax
  800a7d:	78 27                	js     800aa6 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800a7f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800a82:	8b 42 08             	mov    0x8(%edx),%eax
  800a85:	83 e0 03             	and    $0x3,%eax
  800a88:	83 f8 01             	cmp    $0x1,%eax
  800a8b:	74 1e                	je     800aab <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  800a8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a90:	8b 40 08             	mov    0x8(%eax),%eax
  800a93:	85 c0                	test   %eax,%eax
  800a95:	74 35                	je     800acc <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800a97:	83 ec 04             	sub    $0x4,%esp
  800a9a:	ff 75 10             	pushl  0x10(%ebp)
  800a9d:	ff 75 0c             	pushl  0xc(%ebp)
  800aa0:	52                   	push   %edx
  800aa1:	ff d0                	call   *%eax
  800aa3:	83 c4 10             	add    $0x10,%esp
}
  800aa6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800aa9:	c9                   	leave  
  800aaa:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800aab:	a1 04 40 80 00       	mov    0x804004,%eax
  800ab0:	8b 40 48             	mov    0x48(%eax),%eax
  800ab3:	83 ec 04             	sub    $0x4,%esp
  800ab6:	53                   	push   %ebx
  800ab7:	50                   	push   %eax
  800ab8:	68 dd 1e 80 00       	push   $0x801edd
  800abd:	e8 2c 0a 00 00       	call   8014ee <cprintf>
		return -E_INVAL;
  800ac2:	83 c4 10             	add    $0x10,%esp
  800ac5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800aca:	eb da                	jmp    800aa6 <read+0x5a>
		return -E_NOT_SUPP;
  800acc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800ad1:	eb d3                	jmp    800aa6 <read+0x5a>

00800ad3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800ad3:	55                   	push   %ebp
  800ad4:	89 e5                	mov    %esp,%ebp
  800ad6:	57                   	push   %edi
  800ad7:	56                   	push   %esi
  800ad8:	53                   	push   %ebx
  800ad9:	83 ec 0c             	sub    $0xc,%esp
  800adc:	8b 7d 08             	mov    0x8(%ebp),%edi
  800adf:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800ae2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ae7:	39 f3                	cmp    %esi,%ebx
  800ae9:	73 25                	jae    800b10 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800aeb:	83 ec 04             	sub    $0x4,%esp
  800aee:	89 f0                	mov    %esi,%eax
  800af0:	29 d8                	sub    %ebx,%eax
  800af2:	50                   	push   %eax
  800af3:	89 d8                	mov    %ebx,%eax
  800af5:	03 45 0c             	add    0xc(%ebp),%eax
  800af8:	50                   	push   %eax
  800af9:	57                   	push   %edi
  800afa:	e8 4d ff ff ff       	call   800a4c <read>
		if (m < 0)
  800aff:	83 c4 10             	add    $0x10,%esp
  800b02:	85 c0                	test   %eax,%eax
  800b04:	78 08                	js     800b0e <readn+0x3b>
			return m;
		if (m == 0)
  800b06:	85 c0                	test   %eax,%eax
  800b08:	74 06                	je     800b10 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  800b0a:	01 c3                	add    %eax,%ebx
  800b0c:	eb d9                	jmp    800ae7 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800b0e:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  800b10:	89 d8                	mov    %ebx,%eax
  800b12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b15:	5b                   	pop    %ebx
  800b16:	5e                   	pop    %esi
  800b17:	5f                   	pop    %edi
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    

00800b1a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	53                   	push   %ebx
  800b1e:	83 ec 14             	sub    $0x14,%esp
  800b21:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b24:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b27:	50                   	push   %eax
  800b28:	53                   	push   %ebx
  800b29:	e8 ad fc ff ff       	call   8007db <fd_lookup>
  800b2e:	83 c4 08             	add    $0x8,%esp
  800b31:	85 c0                	test   %eax,%eax
  800b33:	78 3a                	js     800b6f <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b35:	83 ec 08             	sub    $0x8,%esp
  800b38:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b3b:	50                   	push   %eax
  800b3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b3f:	ff 30                	pushl  (%eax)
  800b41:	e8 eb fc ff ff       	call   800831 <dev_lookup>
  800b46:	83 c4 10             	add    $0x10,%esp
  800b49:	85 c0                	test   %eax,%eax
  800b4b:	78 22                	js     800b6f <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800b4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b50:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800b54:	74 1e                	je     800b74 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800b56:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b59:	8b 52 0c             	mov    0xc(%edx),%edx
  800b5c:	85 d2                	test   %edx,%edx
  800b5e:	74 35                	je     800b95 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800b60:	83 ec 04             	sub    $0x4,%esp
  800b63:	ff 75 10             	pushl  0x10(%ebp)
  800b66:	ff 75 0c             	pushl  0xc(%ebp)
  800b69:	50                   	push   %eax
  800b6a:	ff d2                	call   *%edx
  800b6c:	83 c4 10             	add    $0x10,%esp
}
  800b6f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b72:	c9                   	leave  
  800b73:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800b74:	a1 04 40 80 00       	mov    0x804004,%eax
  800b79:	8b 40 48             	mov    0x48(%eax),%eax
  800b7c:	83 ec 04             	sub    $0x4,%esp
  800b7f:	53                   	push   %ebx
  800b80:	50                   	push   %eax
  800b81:	68 f9 1e 80 00       	push   $0x801ef9
  800b86:	e8 63 09 00 00       	call   8014ee <cprintf>
		return -E_INVAL;
  800b8b:	83 c4 10             	add    $0x10,%esp
  800b8e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b93:	eb da                	jmp    800b6f <write+0x55>
		return -E_NOT_SUPP;
  800b95:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800b9a:	eb d3                	jmp    800b6f <write+0x55>

00800b9c <seek>:

int
seek(int fdnum, off_t offset)
{
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
  800b9f:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ba2:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800ba5:	50                   	push   %eax
  800ba6:	ff 75 08             	pushl  0x8(%ebp)
  800ba9:	e8 2d fc ff ff       	call   8007db <fd_lookup>
  800bae:	83 c4 08             	add    $0x8,%esp
  800bb1:	85 c0                	test   %eax,%eax
  800bb3:	78 0e                	js     800bc3 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800bb5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bb8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800bbb:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800bbe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bc3:	c9                   	leave  
  800bc4:	c3                   	ret    

00800bc5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	53                   	push   %ebx
  800bc9:	83 ec 14             	sub    $0x14,%esp
  800bcc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800bcf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800bd2:	50                   	push   %eax
  800bd3:	53                   	push   %ebx
  800bd4:	e8 02 fc ff ff       	call   8007db <fd_lookup>
  800bd9:	83 c4 08             	add    $0x8,%esp
  800bdc:	85 c0                	test   %eax,%eax
  800bde:	78 37                	js     800c17 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800be0:	83 ec 08             	sub    $0x8,%esp
  800be3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800be6:	50                   	push   %eax
  800be7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bea:	ff 30                	pushl  (%eax)
  800bec:	e8 40 fc ff ff       	call   800831 <dev_lookup>
  800bf1:	83 c4 10             	add    $0x10,%esp
  800bf4:	85 c0                	test   %eax,%eax
  800bf6:	78 1f                	js     800c17 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800bf8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bfb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800bff:	74 1b                	je     800c1c <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  800c01:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c04:	8b 52 18             	mov    0x18(%edx),%edx
  800c07:	85 d2                	test   %edx,%edx
  800c09:	74 32                	je     800c3d <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800c0b:	83 ec 08             	sub    $0x8,%esp
  800c0e:	ff 75 0c             	pushl  0xc(%ebp)
  800c11:	50                   	push   %eax
  800c12:	ff d2                	call   *%edx
  800c14:	83 c4 10             	add    $0x10,%esp
}
  800c17:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c1a:	c9                   	leave  
  800c1b:	c3                   	ret    
			thisenv->env_id, fdnum);
  800c1c:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800c21:	8b 40 48             	mov    0x48(%eax),%eax
  800c24:	83 ec 04             	sub    $0x4,%esp
  800c27:	53                   	push   %ebx
  800c28:	50                   	push   %eax
  800c29:	68 bc 1e 80 00       	push   $0x801ebc
  800c2e:	e8 bb 08 00 00       	call   8014ee <cprintf>
		return -E_INVAL;
  800c33:	83 c4 10             	add    $0x10,%esp
  800c36:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c3b:	eb da                	jmp    800c17 <ftruncate+0x52>
		return -E_NOT_SUPP;
  800c3d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800c42:	eb d3                	jmp    800c17 <ftruncate+0x52>

00800c44 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	53                   	push   %ebx
  800c48:	83 ec 14             	sub    $0x14,%esp
  800c4b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800c4e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c51:	50                   	push   %eax
  800c52:	ff 75 08             	pushl  0x8(%ebp)
  800c55:	e8 81 fb ff ff       	call   8007db <fd_lookup>
  800c5a:	83 c4 08             	add    $0x8,%esp
  800c5d:	85 c0                	test   %eax,%eax
  800c5f:	78 4b                	js     800cac <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c61:	83 ec 08             	sub    $0x8,%esp
  800c64:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c67:	50                   	push   %eax
  800c68:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c6b:	ff 30                	pushl  (%eax)
  800c6d:	e8 bf fb ff ff       	call   800831 <dev_lookup>
  800c72:	83 c4 10             	add    $0x10,%esp
  800c75:	85 c0                	test   %eax,%eax
  800c77:	78 33                	js     800cac <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  800c79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c7c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800c80:	74 2f                	je     800cb1 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800c82:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800c85:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800c8c:	00 00 00 
	stat->st_isdir = 0;
  800c8f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800c96:	00 00 00 
	stat->st_dev = dev;
  800c99:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800c9f:	83 ec 08             	sub    $0x8,%esp
  800ca2:	53                   	push   %ebx
  800ca3:	ff 75 f0             	pushl  -0x10(%ebp)
  800ca6:	ff 50 14             	call   *0x14(%eax)
  800ca9:	83 c4 10             	add    $0x10,%esp
}
  800cac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800caf:	c9                   	leave  
  800cb0:	c3                   	ret    
		return -E_NOT_SUPP;
  800cb1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800cb6:	eb f4                	jmp    800cac <fstat+0x68>

00800cb8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800cb8:	55                   	push   %ebp
  800cb9:	89 e5                	mov    %esp,%ebp
  800cbb:	56                   	push   %esi
  800cbc:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800cbd:	83 ec 08             	sub    $0x8,%esp
  800cc0:	6a 00                	push   $0x0
  800cc2:	ff 75 08             	pushl  0x8(%ebp)
  800cc5:	e8 da 01 00 00       	call   800ea4 <open>
  800cca:	89 c3                	mov    %eax,%ebx
  800ccc:	83 c4 10             	add    $0x10,%esp
  800ccf:	85 c0                	test   %eax,%eax
  800cd1:	78 1b                	js     800cee <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800cd3:	83 ec 08             	sub    $0x8,%esp
  800cd6:	ff 75 0c             	pushl  0xc(%ebp)
  800cd9:	50                   	push   %eax
  800cda:	e8 65 ff ff ff       	call   800c44 <fstat>
  800cdf:	89 c6                	mov    %eax,%esi
	close(fd);
  800ce1:	89 1c 24             	mov    %ebx,(%esp)
  800ce4:	e8 27 fc ff ff       	call   800910 <close>
	return r;
  800ce9:	83 c4 10             	add    $0x10,%esp
  800cec:	89 f3                	mov    %esi,%ebx
}
  800cee:	89 d8                	mov    %ebx,%eax
  800cf0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cf3:	5b                   	pop    %ebx
  800cf4:	5e                   	pop    %esi
  800cf5:	5d                   	pop    %ebp
  800cf6:	c3                   	ret    

00800cf7 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800cf7:	55                   	push   %ebp
  800cf8:	89 e5                	mov    %esp,%ebp
  800cfa:	56                   	push   %esi
  800cfb:	53                   	push   %ebx
  800cfc:	89 c6                	mov    %eax,%esi
  800cfe:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800d00:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800d07:	74 27                	je     800d30 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800d09:	6a 07                	push   $0x7
  800d0b:	68 00 50 80 00       	push   $0x805000
  800d10:	56                   	push   %esi
  800d11:	ff 35 00 40 80 00    	pushl  0x804000
  800d17:	e8 21 0e 00 00       	call   801b3d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800d1c:	83 c4 0c             	add    $0xc,%esp
  800d1f:	6a 00                	push   $0x0
  800d21:	53                   	push   %ebx
  800d22:	6a 00                	push   $0x0
  800d24:	e8 ad 0d 00 00       	call   801ad6 <ipc_recv>
}
  800d29:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d2c:	5b                   	pop    %ebx
  800d2d:	5e                   	pop    %esi
  800d2e:	5d                   	pop    %ebp
  800d2f:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800d30:	83 ec 0c             	sub    $0xc,%esp
  800d33:	6a 01                	push   $0x1
  800d35:	e8 57 0e 00 00       	call   801b91 <ipc_find_env>
  800d3a:	a3 00 40 80 00       	mov    %eax,0x804000
  800d3f:	83 c4 10             	add    $0x10,%esp
  800d42:	eb c5                	jmp    800d09 <fsipc+0x12>

00800d44 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800d44:	55                   	push   %ebp
  800d45:	89 e5                	mov    %esp,%ebp
  800d47:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800d4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4d:	8b 40 0c             	mov    0xc(%eax),%eax
  800d50:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800d55:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d58:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800d5d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d62:	b8 02 00 00 00       	mov    $0x2,%eax
  800d67:	e8 8b ff ff ff       	call   800cf7 <fsipc>
}
  800d6c:	c9                   	leave  
  800d6d:	c3                   	ret    

00800d6e <devfile_flush>:
{
  800d6e:	55                   	push   %ebp
  800d6f:	89 e5                	mov    %esp,%ebp
  800d71:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800d74:	8b 45 08             	mov    0x8(%ebp),%eax
  800d77:	8b 40 0c             	mov    0xc(%eax),%eax
  800d7a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800d7f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d84:	b8 06 00 00 00       	mov    $0x6,%eax
  800d89:	e8 69 ff ff ff       	call   800cf7 <fsipc>
}
  800d8e:	c9                   	leave  
  800d8f:	c3                   	ret    

00800d90 <devfile_stat>:
{
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	53                   	push   %ebx
  800d94:	83 ec 04             	sub    $0x4,%esp
  800d97:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800d9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9d:	8b 40 0c             	mov    0xc(%eax),%eax
  800da0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800da5:	ba 00 00 00 00       	mov    $0x0,%edx
  800daa:	b8 05 00 00 00       	mov    $0x5,%eax
  800daf:	e8 43 ff ff ff       	call   800cf7 <fsipc>
  800db4:	85 c0                	test   %eax,%eax
  800db6:	78 2c                	js     800de4 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800db8:	83 ec 08             	sub    $0x8,%esp
  800dbb:	68 00 50 80 00       	push   $0x805000
  800dc0:	53                   	push   %ebx
  800dc1:	e8 b5 f3 ff ff       	call   80017b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800dc6:	a1 80 50 80 00       	mov    0x805080,%eax
  800dcb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800dd1:	a1 84 50 80 00       	mov    0x805084,%eax
  800dd6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800ddc:	83 c4 10             	add    $0x10,%esp
  800ddf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800de4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800de7:	c9                   	leave  
  800de8:	c3                   	ret    

00800de9 <devfile_write>:
{
  800de9:	55                   	push   %ebp
  800dea:	89 e5                	mov    %esp,%ebp
  800dec:	83 ec 0c             	sub    $0xc,%esp
  800def:	8b 45 10             	mov    0x10(%ebp),%eax
    	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800df2:	8b 55 08             	mov    0x8(%ebp),%edx
  800df5:	8b 52 0c             	mov    0xc(%edx),%edx
  800df8:	89 15 00 50 80 00    	mov    %edx,0x805000
    	fsipcbuf.write.req_n = n;
  800dfe:	a3 04 50 80 00       	mov    %eax,0x805004
    	memmove(fsipcbuf.write.req_buf, buf, n);
  800e03:	50                   	push   %eax
  800e04:	ff 75 0c             	pushl  0xc(%ebp)
  800e07:	68 08 50 80 00       	push   $0x805008
  800e0c:	e8 f8 f4 ff ff       	call   800309 <memmove>
    	return fsipc(FSREQ_WRITE, NULL);
  800e11:	ba 00 00 00 00       	mov    $0x0,%edx
  800e16:	b8 04 00 00 00       	mov    $0x4,%eax
  800e1b:	e8 d7 fe ff ff       	call   800cf7 <fsipc>
}
  800e20:	c9                   	leave  
  800e21:	c3                   	ret    

00800e22 <devfile_read>:
{
  800e22:	55                   	push   %ebp
  800e23:	89 e5                	mov    %esp,%ebp
  800e25:	56                   	push   %esi
  800e26:	53                   	push   %ebx
  800e27:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800e2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2d:	8b 40 0c             	mov    0xc(%eax),%eax
  800e30:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800e35:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800e3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e40:	b8 03 00 00 00       	mov    $0x3,%eax
  800e45:	e8 ad fe ff ff       	call   800cf7 <fsipc>
  800e4a:	89 c3                	mov    %eax,%ebx
  800e4c:	85 c0                	test   %eax,%eax
  800e4e:	78 1f                	js     800e6f <devfile_read+0x4d>
	assert(r <= n);
  800e50:	39 f0                	cmp    %esi,%eax
  800e52:	77 24                	ja     800e78 <devfile_read+0x56>
	assert(r <= PGSIZE);
  800e54:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800e59:	7f 33                	jg     800e8e <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800e5b:	83 ec 04             	sub    $0x4,%esp
  800e5e:	50                   	push   %eax
  800e5f:	68 00 50 80 00       	push   $0x805000
  800e64:	ff 75 0c             	pushl  0xc(%ebp)
  800e67:	e8 9d f4 ff ff       	call   800309 <memmove>
	return r;
  800e6c:	83 c4 10             	add    $0x10,%esp
}
  800e6f:	89 d8                	mov    %ebx,%eax
  800e71:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e74:	5b                   	pop    %ebx
  800e75:	5e                   	pop    %esi
  800e76:	5d                   	pop    %ebp
  800e77:	c3                   	ret    
	assert(r <= n);
  800e78:	68 28 1f 80 00       	push   $0x801f28
  800e7d:	68 2f 1f 80 00       	push   $0x801f2f
  800e82:	6a 7c                	push   $0x7c
  800e84:	68 44 1f 80 00       	push   $0x801f44
  800e89:	e8 85 05 00 00       	call   801413 <_panic>
	assert(r <= PGSIZE);
  800e8e:	68 4f 1f 80 00       	push   $0x801f4f
  800e93:	68 2f 1f 80 00       	push   $0x801f2f
  800e98:	6a 7d                	push   $0x7d
  800e9a:	68 44 1f 80 00       	push   $0x801f44
  800e9f:	e8 6f 05 00 00       	call   801413 <_panic>

00800ea4 <open>:
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	56                   	push   %esi
  800ea8:	53                   	push   %ebx
  800ea9:	83 ec 1c             	sub    $0x1c,%esp
  800eac:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800eaf:	56                   	push   %esi
  800eb0:	e8 8f f2 ff ff       	call   800144 <strlen>
  800eb5:	83 c4 10             	add    $0x10,%esp
  800eb8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ebd:	7f 6c                	jg     800f2b <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  800ebf:	83 ec 0c             	sub    $0xc,%esp
  800ec2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ec5:	50                   	push   %eax
  800ec6:	e8 c1 f8 ff ff       	call   80078c <fd_alloc>
  800ecb:	89 c3                	mov    %eax,%ebx
  800ecd:	83 c4 10             	add    $0x10,%esp
  800ed0:	85 c0                	test   %eax,%eax
  800ed2:	78 3c                	js     800f10 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  800ed4:	83 ec 08             	sub    $0x8,%esp
  800ed7:	56                   	push   %esi
  800ed8:	68 00 50 80 00       	push   $0x805000
  800edd:	e8 99 f2 ff ff       	call   80017b <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ee2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ee5:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800eea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800eed:	b8 01 00 00 00       	mov    $0x1,%eax
  800ef2:	e8 00 fe ff ff       	call   800cf7 <fsipc>
  800ef7:	89 c3                	mov    %eax,%ebx
  800ef9:	83 c4 10             	add    $0x10,%esp
  800efc:	85 c0                	test   %eax,%eax
  800efe:	78 19                	js     800f19 <open+0x75>
	return fd2num(fd);
  800f00:	83 ec 0c             	sub    $0xc,%esp
  800f03:	ff 75 f4             	pushl  -0xc(%ebp)
  800f06:	e8 5a f8 ff ff       	call   800765 <fd2num>
  800f0b:	89 c3                	mov    %eax,%ebx
  800f0d:	83 c4 10             	add    $0x10,%esp
}
  800f10:	89 d8                	mov    %ebx,%eax
  800f12:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f15:	5b                   	pop    %ebx
  800f16:	5e                   	pop    %esi
  800f17:	5d                   	pop    %ebp
  800f18:	c3                   	ret    
		fd_close(fd, 0);
  800f19:	83 ec 08             	sub    $0x8,%esp
  800f1c:	6a 00                	push   $0x0
  800f1e:	ff 75 f4             	pushl  -0xc(%ebp)
  800f21:	e8 61 f9 ff ff       	call   800887 <fd_close>
		return r;
  800f26:	83 c4 10             	add    $0x10,%esp
  800f29:	eb e5                	jmp    800f10 <open+0x6c>
		return -E_BAD_PATH;
  800f2b:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800f30:	eb de                	jmp    800f10 <open+0x6c>

00800f32 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800f32:	55                   	push   %ebp
  800f33:	89 e5                	mov    %esp,%ebp
  800f35:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800f38:	ba 00 00 00 00       	mov    $0x0,%edx
  800f3d:	b8 08 00 00 00       	mov    $0x8,%eax
  800f42:	e8 b0 fd ff ff       	call   800cf7 <fsipc>
}
  800f47:	c9                   	leave  
  800f48:	c3                   	ret    

00800f49 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800f49:	55                   	push   %ebp
  800f4a:	89 e5                	mov    %esp,%ebp
  800f4c:	56                   	push   %esi
  800f4d:	53                   	push   %ebx
  800f4e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800f51:	83 ec 0c             	sub    $0xc,%esp
  800f54:	ff 75 08             	pushl  0x8(%ebp)
  800f57:	e8 19 f8 ff ff       	call   800775 <fd2data>
  800f5c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800f5e:	83 c4 08             	add    $0x8,%esp
  800f61:	68 5b 1f 80 00       	push   $0x801f5b
  800f66:	53                   	push   %ebx
  800f67:	e8 0f f2 ff ff       	call   80017b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800f6c:	8b 46 04             	mov    0x4(%esi),%eax
  800f6f:	2b 06                	sub    (%esi),%eax
  800f71:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800f77:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800f7e:	00 00 00 
	stat->st_dev = &devpipe;
  800f81:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800f88:	30 80 00 
	return 0;
}
  800f8b:	b8 00 00 00 00       	mov    $0x0,%eax
  800f90:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f93:	5b                   	pop    %ebx
  800f94:	5e                   	pop    %esi
  800f95:	5d                   	pop    %ebp
  800f96:	c3                   	ret    

00800f97 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800f97:	55                   	push   %ebp
  800f98:	89 e5                	mov    %esp,%ebp
  800f9a:	53                   	push   %ebx
  800f9b:	83 ec 0c             	sub    $0xc,%esp
  800f9e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800fa1:	53                   	push   %ebx
  800fa2:	6a 00                	push   $0x0
  800fa4:	e8 50 f6 ff ff       	call   8005f9 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800fa9:	89 1c 24             	mov    %ebx,(%esp)
  800fac:	e8 c4 f7 ff ff       	call   800775 <fd2data>
  800fb1:	83 c4 08             	add    $0x8,%esp
  800fb4:	50                   	push   %eax
  800fb5:	6a 00                	push   $0x0
  800fb7:	e8 3d f6 ff ff       	call   8005f9 <sys_page_unmap>
}
  800fbc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fbf:	c9                   	leave  
  800fc0:	c3                   	ret    

00800fc1 <_pipeisclosed>:
{
  800fc1:	55                   	push   %ebp
  800fc2:	89 e5                	mov    %esp,%ebp
  800fc4:	57                   	push   %edi
  800fc5:	56                   	push   %esi
  800fc6:	53                   	push   %ebx
  800fc7:	83 ec 1c             	sub    $0x1c,%esp
  800fca:	89 c7                	mov    %eax,%edi
  800fcc:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800fce:	a1 04 40 80 00       	mov    0x804004,%eax
  800fd3:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800fd6:	83 ec 0c             	sub    $0xc,%esp
  800fd9:	57                   	push   %edi
  800fda:	e8 eb 0b 00 00       	call   801bca <pageref>
  800fdf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800fe2:	89 34 24             	mov    %esi,(%esp)
  800fe5:	e8 e0 0b 00 00       	call   801bca <pageref>
		nn = thisenv->env_runs;
  800fea:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800ff0:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800ff3:	83 c4 10             	add    $0x10,%esp
  800ff6:	39 cb                	cmp    %ecx,%ebx
  800ff8:	74 1b                	je     801015 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800ffa:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800ffd:	75 cf                	jne    800fce <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800fff:	8b 42 58             	mov    0x58(%edx),%eax
  801002:	6a 01                	push   $0x1
  801004:	50                   	push   %eax
  801005:	53                   	push   %ebx
  801006:	68 62 1f 80 00       	push   $0x801f62
  80100b:	e8 de 04 00 00       	call   8014ee <cprintf>
  801010:	83 c4 10             	add    $0x10,%esp
  801013:	eb b9                	jmp    800fce <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801015:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801018:	0f 94 c0             	sete   %al
  80101b:	0f b6 c0             	movzbl %al,%eax
}
  80101e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801021:	5b                   	pop    %ebx
  801022:	5e                   	pop    %esi
  801023:	5f                   	pop    %edi
  801024:	5d                   	pop    %ebp
  801025:	c3                   	ret    

00801026 <devpipe_write>:
{
  801026:	55                   	push   %ebp
  801027:	89 e5                	mov    %esp,%ebp
  801029:	57                   	push   %edi
  80102a:	56                   	push   %esi
  80102b:	53                   	push   %ebx
  80102c:	83 ec 28             	sub    $0x28,%esp
  80102f:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801032:	56                   	push   %esi
  801033:	e8 3d f7 ff ff       	call   800775 <fd2data>
  801038:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80103a:	83 c4 10             	add    $0x10,%esp
  80103d:	bf 00 00 00 00       	mov    $0x0,%edi
  801042:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801045:	74 4f                	je     801096 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801047:	8b 43 04             	mov    0x4(%ebx),%eax
  80104a:	8b 0b                	mov    (%ebx),%ecx
  80104c:	8d 51 20             	lea    0x20(%ecx),%edx
  80104f:	39 d0                	cmp    %edx,%eax
  801051:	72 14                	jb     801067 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801053:	89 da                	mov    %ebx,%edx
  801055:	89 f0                	mov    %esi,%eax
  801057:	e8 65 ff ff ff       	call   800fc1 <_pipeisclosed>
  80105c:	85 c0                	test   %eax,%eax
  80105e:	75 3a                	jne    80109a <devpipe_write+0x74>
			sys_yield();
  801060:	e8 f0 f4 ff ff       	call   800555 <sys_yield>
  801065:	eb e0                	jmp    801047 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801067:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80106a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80106e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801071:	89 c2                	mov    %eax,%edx
  801073:	c1 fa 1f             	sar    $0x1f,%edx
  801076:	89 d1                	mov    %edx,%ecx
  801078:	c1 e9 1b             	shr    $0x1b,%ecx
  80107b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80107e:	83 e2 1f             	and    $0x1f,%edx
  801081:	29 ca                	sub    %ecx,%edx
  801083:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801087:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80108b:	83 c0 01             	add    $0x1,%eax
  80108e:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801091:	83 c7 01             	add    $0x1,%edi
  801094:	eb ac                	jmp    801042 <devpipe_write+0x1c>
	return i;
  801096:	89 f8                	mov    %edi,%eax
  801098:	eb 05                	jmp    80109f <devpipe_write+0x79>
				return 0;
  80109a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80109f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010a2:	5b                   	pop    %ebx
  8010a3:	5e                   	pop    %esi
  8010a4:	5f                   	pop    %edi
  8010a5:	5d                   	pop    %ebp
  8010a6:	c3                   	ret    

008010a7 <devpipe_read>:
{
  8010a7:	55                   	push   %ebp
  8010a8:	89 e5                	mov    %esp,%ebp
  8010aa:	57                   	push   %edi
  8010ab:	56                   	push   %esi
  8010ac:	53                   	push   %ebx
  8010ad:	83 ec 18             	sub    $0x18,%esp
  8010b0:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8010b3:	57                   	push   %edi
  8010b4:	e8 bc f6 ff ff       	call   800775 <fd2data>
  8010b9:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8010bb:	83 c4 10             	add    $0x10,%esp
  8010be:	be 00 00 00 00       	mov    $0x0,%esi
  8010c3:	3b 75 10             	cmp    0x10(%ebp),%esi
  8010c6:	74 47                	je     80110f <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  8010c8:	8b 03                	mov    (%ebx),%eax
  8010ca:	3b 43 04             	cmp    0x4(%ebx),%eax
  8010cd:	75 22                	jne    8010f1 <devpipe_read+0x4a>
			if (i > 0)
  8010cf:	85 f6                	test   %esi,%esi
  8010d1:	75 14                	jne    8010e7 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  8010d3:	89 da                	mov    %ebx,%edx
  8010d5:	89 f8                	mov    %edi,%eax
  8010d7:	e8 e5 fe ff ff       	call   800fc1 <_pipeisclosed>
  8010dc:	85 c0                	test   %eax,%eax
  8010de:	75 33                	jne    801113 <devpipe_read+0x6c>
			sys_yield();
  8010e0:	e8 70 f4 ff ff       	call   800555 <sys_yield>
  8010e5:	eb e1                	jmp    8010c8 <devpipe_read+0x21>
				return i;
  8010e7:	89 f0                	mov    %esi,%eax
}
  8010e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ec:	5b                   	pop    %ebx
  8010ed:	5e                   	pop    %esi
  8010ee:	5f                   	pop    %edi
  8010ef:	5d                   	pop    %ebp
  8010f0:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8010f1:	99                   	cltd   
  8010f2:	c1 ea 1b             	shr    $0x1b,%edx
  8010f5:	01 d0                	add    %edx,%eax
  8010f7:	83 e0 1f             	and    $0x1f,%eax
  8010fa:	29 d0                	sub    %edx,%eax
  8010fc:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801101:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801104:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801107:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  80110a:	83 c6 01             	add    $0x1,%esi
  80110d:	eb b4                	jmp    8010c3 <devpipe_read+0x1c>
	return i;
  80110f:	89 f0                	mov    %esi,%eax
  801111:	eb d6                	jmp    8010e9 <devpipe_read+0x42>
				return 0;
  801113:	b8 00 00 00 00       	mov    $0x0,%eax
  801118:	eb cf                	jmp    8010e9 <devpipe_read+0x42>

0080111a <pipe>:
{
  80111a:	55                   	push   %ebp
  80111b:	89 e5                	mov    %esp,%ebp
  80111d:	56                   	push   %esi
  80111e:	53                   	push   %ebx
  80111f:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801122:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801125:	50                   	push   %eax
  801126:	e8 61 f6 ff ff       	call   80078c <fd_alloc>
  80112b:	89 c3                	mov    %eax,%ebx
  80112d:	83 c4 10             	add    $0x10,%esp
  801130:	85 c0                	test   %eax,%eax
  801132:	78 5b                	js     80118f <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801134:	83 ec 04             	sub    $0x4,%esp
  801137:	68 07 04 00 00       	push   $0x407
  80113c:	ff 75 f4             	pushl  -0xc(%ebp)
  80113f:	6a 00                	push   $0x0
  801141:	e8 2e f4 ff ff       	call   800574 <sys_page_alloc>
  801146:	89 c3                	mov    %eax,%ebx
  801148:	83 c4 10             	add    $0x10,%esp
  80114b:	85 c0                	test   %eax,%eax
  80114d:	78 40                	js     80118f <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  80114f:	83 ec 0c             	sub    $0xc,%esp
  801152:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801155:	50                   	push   %eax
  801156:	e8 31 f6 ff ff       	call   80078c <fd_alloc>
  80115b:	89 c3                	mov    %eax,%ebx
  80115d:	83 c4 10             	add    $0x10,%esp
  801160:	85 c0                	test   %eax,%eax
  801162:	78 1b                	js     80117f <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801164:	83 ec 04             	sub    $0x4,%esp
  801167:	68 07 04 00 00       	push   $0x407
  80116c:	ff 75 f0             	pushl  -0x10(%ebp)
  80116f:	6a 00                	push   $0x0
  801171:	e8 fe f3 ff ff       	call   800574 <sys_page_alloc>
  801176:	89 c3                	mov    %eax,%ebx
  801178:	83 c4 10             	add    $0x10,%esp
  80117b:	85 c0                	test   %eax,%eax
  80117d:	79 19                	jns    801198 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  80117f:	83 ec 08             	sub    $0x8,%esp
  801182:	ff 75 f4             	pushl  -0xc(%ebp)
  801185:	6a 00                	push   $0x0
  801187:	e8 6d f4 ff ff       	call   8005f9 <sys_page_unmap>
  80118c:	83 c4 10             	add    $0x10,%esp
}
  80118f:	89 d8                	mov    %ebx,%eax
  801191:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801194:	5b                   	pop    %ebx
  801195:	5e                   	pop    %esi
  801196:	5d                   	pop    %ebp
  801197:	c3                   	ret    
	va = fd2data(fd0);
  801198:	83 ec 0c             	sub    $0xc,%esp
  80119b:	ff 75 f4             	pushl  -0xc(%ebp)
  80119e:	e8 d2 f5 ff ff       	call   800775 <fd2data>
  8011a3:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011a5:	83 c4 0c             	add    $0xc,%esp
  8011a8:	68 07 04 00 00       	push   $0x407
  8011ad:	50                   	push   %eax
  8011ae:	6a 00                	push   $0x0
  8011b0:	e8 bf f3 ff ff       	call   800574 <sys_page_alloc>
  8011b5:	89 c3                	mov    %eax,%ebx
  8011b7:	83 c4 10             	add    $0x10,%esp
  8011ba:	85 c0                	test   %eax,%eax
  8011bc:	0f 88 8c 00 00 00    	js     80124e <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011c2:	83 ec 0c             	sub    $0xc,%esp
  8011c5:	ff 75 f0             	pushl  -0x10(%ebp)
  8011c8:	e8 a8 f5 ff ff       	call   800775 <fd2data>
  8011cd:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8011d4:	50                   	push   %eax
  8011d5:	6a 00                	push   $0x0
  8011d7:	56                   	push   %esi
  8011d8:	6a 00                	push   $0x0
  8011da:	e8 d8 f3 ff ff       	call   8005b7 <sys_page_map>
  8011df:	89 c3                	mov    %eax,%ebx
  8011e1:	83 c4 20             	add    $0x20,%esp
  8011e4:	85 c0                	test   %eax,%eax
  8011e6:	78 58                	js     801240 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  8011e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011eb:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8011f1:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8011f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011f6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  8011fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801200:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801206:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801208:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80120b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801212:	83 ec 0c             	sub    $0xc,%esp
  801215:	ff 75 f4             	pushl  -0xc(%ebp)
  801218:	e8 48 f5 ff ff       	call   800765 <fd2num>
  80121d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801220:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801222:	83 c4 04             	add    $0x4,%esp
  801225:	ff 75 f0             	pushl  -0x10(%ebp)
  801228:	e8 38 f5 ff ff       	call   800765 <fd2num>
  80122d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801230:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801233:	83 c4 10             	add    $0x10,%esp
  801236:	bb 00 00 00 00       	mov    $0x0,%ebx
  80123b:	e9 4f ff ff ff       	jmp    80118f <pipe+0x75>
	sys_page_unmap(0, va);
  801240:	83 ec 08             	sub    $0x8,%esp
  801243:	56                   	push   %esi
  801244:	6a 00                	push   $0x0
  801246:	e8 ae f3 ff ff       	call   8005f9 <sys_page_unmap>
  80124b:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  80124e:	83 ec 08             	sub    $0x8,%esp
  801251:	ff 75 f0             	pushl  -0x10(%ebp)
  801254:	6a 00                	push   $0x0
  801256:	e8 9e f3 ff ff       	call   8005f9 <sys_page_unmap>
  80125b:	83 c4 10             	add    $0x10,%esp
  80125e:	e9 1c ff ff ff       	jmp    80117f <pipe+0x65>

00801263 <pipeisclosed>:
{
  801263:	55                   	push   %ebp
  801264:	89 e5                	mov    %esp,%ebp
  801266:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801269:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80126c:	50                   	push   %eax
  80126d:	ff 75 08             	pushl  0x8(%ebp)
  801270:	e8 66 f5 ff ff       	call   8007db <fd_lookup>
  801275:	83 c4 10             	add    $0x10,%esp
  801278:	85 c0                	test   %eax,%eax
  80127a:	78 18                	js     801294 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  80127c:	83 ec 0c             	sub    $0xc,%esp
  80127f:	ff 75 f4             	pushl  -0xc(%ebp)
  801282:	e8 ee f4 ff ff       	call   800775 <fd2data>
	return _pipeisclosed(fd, p);
  801287:	89 c2                	mov    %eax,%edx
  801289:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80128c:	e8 30 fd ff ff       	call   800fc1 <_pipeisclosed>
  801291:	83 c4 10             	add    $0x10,%esp
}
  801294:	c9                   	leave  
  801295:	c3                   	ret    

00801296 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801296:	55                   	push   %ebp
  801297:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801299:	b8 00 00 00 00       	mov    $0x0,%eax
  80129e:	5d                   	pop    %ebp
  80129f:	c3                   	ret    

008012a0 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8012a0:	55                   	push   %ebp
  8012a1:	89 e5                	mov    %esp,%ebp
  8012a3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8012a6:	68 7a 1f 80 00       	push   $0x801f7a
  8012ab:	ff 75 0c             	pushl  0xc(%ebp)
  8012ae:	e8 c8 ee ff ff       	call   80017b <strcpy>
	return 0;
}
  8012b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8012b8:	c9                   	leave  
  8012b9:	c3                   	ret    

008012ba <devcons_write>:
{
  8012ba:	55                   	push   %ebp
  8012bb:	89 e5                	mov    %esp,%ebp
  8012bd:	57                   	push   %edi
  8012be:	56                   	push   %esi
  8012bf:	53                   	push   %ebx
  8012c0:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8012c6:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8012cb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8012d1:	eb 2f                	jmp    801302 <devcons_write+0x48>
		m = n - tot;
  8012d3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012d6:	29 f3                	sub    %esi,%ebx
  8012d8:	83 fb 7f             	cmp    $0x7f,%ebx
  8012db:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8012e0:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8012e3:	83 ec 04             	sub    $0x4,%esp
  8012e6:	53                   	push   %ebx
  8012e7:	89 f0                	mov    %esi,%eax
  8012e9:	03 45 0c             	add    0xc(%ebp),%eax
  8012ec:	50                   	push   %eax
  8012ed:	57                   	push   %edi
  8012ee:	e8 16 f0 ff ff       	call   800309 <memmove>
		sys_cputs(buf, m);
  8012f3:	83 c4 08             	add    $0x8,%esp
  8012f6:	53                   	push   %ebx
  8012f7:	57                   	push   %edi
  8012f8:	e8 bb f1 ff ff       	call   8004b8 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8012fd:	01 de                	add    %ebx,%esi
  8012ff:	83 c4 10             	add    $0x10,%esp
  801302:	3b 75 10             	cmp    0x10(%ebp),%esi
  801305:	72 cc                	jb     8012d3 <devcons_write+0x19>
}
  801307:	89 f0                	mov    %esi,%eax
  801309:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80130c:	5b                   	pop    %ebx
  80130d:	5e                   	pop    %esi
  80130e:	5f                   	pop    %edi
  80130f:	5d                   	pop    %ebp
  801310:	c3                   	ret    

00801311 <devcons_read>:
{
  801311:	55                   	push   %ebp
  801312:	89 e5                	mov    %esp,%ebp
  801314:	83 ec 08             	sub    $0x8,%esp
  801317:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  80131c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801320:	75 07                	jne    801329 <devcons_read+0x18>
}
  801322:	c9                   	leave  
  801323:	c3                   	ret    
		sys_yield();
  801324:	e8 2c f2 ff ff       	call   800555 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801329:	e8 a8 f1 ff ff       	call   8004d6 <sys_cgetc>
  80132e:	85 c0                	test   %eax,%eax
  801330:	74 f2                	je     801324 <devcons_read+0x13>
	if (c < 0)
  801332:	85 c0                	test   %eax,%eax
  801334:	78 ec                	js     801322 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  801336:	83 f8 04             	cmp    $0x4,%eax
  801339:	74 0c                	je     801347 <devcons_read+0x36>
	*(char*)vbuf = c;
  80133b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80133e:	88 02                	mov    %al,(%edx)
	return 1;
  801340:	b8 01 00 00 00       	mov    $0x1,%eax
  801345:	eb db                	jmp    801322 <devcons_read+0x11>
		return 0;
  801347:	b8 00 00 00 00       	mov    $0x0,%eax
  80134c:	eb d4                	jmp    801322 <devcons_read+0x11>

0080134e <cputchar>:
{
  80134e:	55                   	push   %ebp
  80134f:	89 e5                	mov    %esp,%ebp
  801351:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801354:	8b 45 08             	mov    0x8(%ebp),%eax
  801357:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80135a:	6a 01                	push   $0x1
  80135c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80135f:	50                   	push   %eax
  801360:	e8 53 f1 ff ff       	call   8004b8 <sys_cputs>
}
  801365:	83 c4 10             	add    $0x10,%esp
  801368:	c9                   	leave  
  801369:	c3                   	ret    

0080136a <getchar>:
{
  80136a:	55                   	push   %ebp
  80136b:	89 e5                	mov    %esp,%ebp
  80136d:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801370:	6a 01                	push   $0x1
  801372:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801375:	50                   	push   %eax
  801376:	6a 00                	push   $0x0
  801378:	e8 cf f6 ff ff       	call   800a4c <read>
	if (r < 0)
  80137d:	83 c4 10             	add    $0x10,%esp
  801380:	85 c0                	test   %eax,%eax
  801382:	78 08                	js     80138c <getchar+0x22>
	if (r < 1)
  801384:	85 c0                	test   %eax,%eax
  801386:	7e 06                	jle    80138e <getchar+0x24>
	return c;
  801388:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80138c:	c9                   	leave  
  80138d:	c3                   	ret    
		return -E_EOF;
  80138e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801393:	eb f7                	jmp    80138c <getchar+0x22>

00801395 <iscons>:
{
  801395:	55                   	push   %ebp
  801396:	89 e5                	mov    %esp,%ebp
  801398:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80139b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80139e:	50                   	push   %eax
  80139f:	ff 75 08             	pushl  0x8(%ebp)
  8013a2:	e8 34 f4 ff ff       	call   8007db <fd_lookup>
  8013a7:	83 c4 10             	add    $0x10,%esp
  8013aa:	85 c0                	test   %eax,%eax
  8013ac:	78 11                	js     8013bf <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  8013ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013b1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8013b7:	39 10                	cmp    %edx,(%eax)
  8013b9:	0f 94 c0             	sete   %al
  8013bc:	0f b6 c0             	movzbl %al,%eax
}
  8013bf:	c9                   	leave  
  8013c0:	c3                   	ret    

008013c1 <opencons>:
{
  8013c1:	55                   	push   %ebp
  8013c2:	89 e5                	mov    %esp,%ebp
  8013c4:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8013c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ca:	50                   	push   %eax
  8013cb:	e8 bc f3 ff ff       	call   80078c <fd_alloc>
  8013d0:	83 c4 10             	add    $0x10,%esp
  8013d3:	85 c0                	test   %eax,%eax
  8013d5:	78 3a                	js     801411 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8013d7:	83 ec 04             	sub    $0x4,%esp
  8013da:	68 07 04 00 00       	push   $0x407
  8013df:	ff 75 f4             	pushl  -0xc(%ebp)
  8013e2:	6a 00                	push   $0x0
  8013e4:	e8 8b f1 ff ff       	call   800574 <sys_page_alloc>
  8013e9:	83 c4 10             	add    $0x10,%esp
  8013ec:	85 c0                	test   %eax,%eax
  8013ee:	78 21                	js     801411 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8013f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013f3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8013f9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8013fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013fe:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801405:	83 ec 0c             	sub    $0xc,%esp
  801408:	50                   	push   %eax
  801409:	e8 57 f3 ff ff       	call   800765 <fd2num>
  80140e:	83 c4 10             	add    $0x10,%esp
}
  801411:	c9                   	leave  
  801412:	c3                   	ret    

00801413 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801413:	55                   	push   %ebp
  801414:	89 e5                	mov    %esp,%ebp
  801416:	56                   	push   %esi
  801417:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801418:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80141b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801421:	e8 10 f1 ff ff       	call   800536 <sys_getenvid>
  801426:	83 ec 0c             	sub    $0xc,%esp
  801429:	ff 75 0c             	pushl  0xc(%ebp)
  80142c:	ff 75 08             	pushl  0x8(%ebp)
  80142f:	56                   	push   %esi
  801430:	50                   	push   %eax
  801431:	68 88 1f 80 00       	push   $0x801f88
  801436:	e8 b3 00 00 00       	call   8014ee <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80143b:	83 c4 18             	add    $0x18,%esp
  80143e:	53                   	push   %ebx
  80143f:	ff 75 10             	pushl  0x10(%ebp)
  801442:	e8 56 00 00 00       	call   80149d <vcprintf>
	cprintf("\n");
  801447:	c7 04 24 73 1f 80 00 	movl   $0x801f73,(%esp)
  80144e:	e8 9b 00 00 00       	call   8014ee <cprintf>
  801453:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801456:	cc                   	int3   
  801457:	eb fd                	jmp    801456 <_panic+0x43>

00801459 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801459:	55                   	push   %ebp
  80145a:	89 e5                	mov    %esp,%ebp
  80145c:	53                   	push   %ebx
  80145d:	83 ec 04             	sub    $0x4,%esp
  801460:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801463:	8b 13                	mov    (%ebx),%edx
  801465:	8d 42 01             	lea    0x1(%edx),%eax
  801468:	89 03                	mov    %eax,(%ebx)
  80146a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80146d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801471:	3d ff 00 00 00       	cmp    $0xff,%eax
  801476:	74 09                	je     801481 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801478:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80147c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80147f:	c9                   	leave  
  801480:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801481:	83 ec 08             	sub    $0x8,%esp
  801484:	68 ff 00 00 00       	push   $0xff
  801489:	8d 43 08             	lea    0x8(%ebx),%eax
  80148c:	50                   	push   %eax
  80148d:	e8 26 f0 ff ff       	call   8004b8 <sys_cputs>
		b->idx = 0;
  801492:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801498:	83 c4 10             	add    $0x10,%esp
  80149b:	eb db                	jmp    801478 <putch+0x1f>

0080149d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80149d:	55                   	push   %ebp
  80149e:	89 e5                	mov    %esp,%ebp
  8014a0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8014a6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8014ad:	00 00 00 
	b.cnt = 0;
  8014b0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8014b7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8014ba:	ff 75 0c             	pushl  0xc(%ebp)
  8014bd:	ff 75 08             	pushl  0x8(%ebp)
  8014c0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8014c6:	50                   	push   %eax
  8014c7:	68 59 14 80 00       	push   $0x801459
  8014cc:	e8 1a 01 00 00       	call   8015eb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8014d1:	83 c4 08             	add    $0x8,%esp
  8014d4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8014da:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8014e0:	50                   	push   %eax
  8014e1:	e8 d2 ef ff ff       	call   8004b8 <sys_cputs>

	return b.cnt;
}
  8014e6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8014ec:	c9                   	leave  
  8014ed:	c3                   	ret    

008014ee <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8014ee:	55                   	push   %ebp
  8014ef:	89 e5                	mov    %esp,%ebp
  8014f1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8014f4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8014f7:	50                   	push   %eax
  8014f8:	ff 75 08             	pushl  0x8(%ebp)
  8014fb:	e8 9d ff ff ff       	call   80149d <vcprintf>
	va_end(ap);

	return cnt;
}
  801500:	c9                   	leave  
  801501:	c3                   	ret    

00801502 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801502:	55                   	push   %ebp
  801503:	89 e5                	mov    %esp,%ebp
  801505:	57                   	push   %edi
  801506:	56                   	push   %esi
  801507:	53                   	push   %ebx
  801508:	83 ec 1c             	sub    $0x1c,%esp
  80150b:	89 c7                	mov    %eax,%edi
  80150d:	89 d6                	mov    %edx,%esi
  80150f:	8b 45 08             	mov    0x8(%ebp),%eax
  801512:	8b 55 0c             	mov    0xc(%ebp),%edx
  801515:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801518:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80151b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80151e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801523:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801526:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801529:	39 d3                	cmp    %edx,%ebx
  80152b:	72 05                	jb     801532 <printnum+0x30>
  80152d:	39 45 10             	cmp    %eax,0x10(%ebp)
  801530:	77 7a                	ja     8015ac <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801532:	83 ec 0c             	sub    $0xc,%esp
  801535:	ff 75 18             	pushl  0x18(%ebp)
  801538:	8b 45 14             	mov    0x14(%ebp),%eax
  80153b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80153e:	53                   	push   %ebx
  80153f:	ff 75 10             	pushl  0x10(%ebp)
  801542:	83 ec 08             	sub    $0x8,%esp
  801545:	ff 75 e4             	pushl  -0x1c(%ebp)
  801548:	ff 75 e0             	pushl  -0x20(%ebp)
  80154b:	ff 75 dc             	pushl  -0x24(%ebp)
  80154e:	ff 75 d8             	pushl  -0x28(%ebp)
  801551:	e8 ba 06 00 00       	call   801c10 <__udivdi3>
  801556:	83 c4 18             	add    $0x18,%esp
  801559:	52                   	push   %edx
  80155a:	50                   	push   %eax
  80155b:	89 f2                	mov    %esi,%edx
  80155d:	89 f8                	mov    %edi,%eax
  80155f:	e8 9e ff ff ff       	call   801502 <printnum>
  801564:	83 c4 20             	add    $0x20,%esp
  801567:	eb 13                	jmp    80157c <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801569:	83 ec 08             	sub    $0x8,%esp
  80156c:	56                   	push   %esi
  80156d:	ff 75 18             	pushl  0x18(%ebp)
  801570:	ff d7                	call   *%edi
  801572:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801575:	83 eb 01             	sub    $0x1,%ebx
  801578:	85 db                	test   %ebx,%ebx
  80157a:	7f ed                	jg     801569 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80157c:	83 ec 08             	sub    $0x8,%esp
  80157f:	56                   	push   %esi
  801580:	83 ec 04             	sub    $0x4,%esp
  801583:	ff 75 e4             	pushl  -0x1c(%ebp)
  801586:	ff 75 e0             	pushl  -0x20(%ebp)
  801589:	ff 75 dc             	pushl  -0x24(%ebp)
  80158c:	ff 75 d8             	pushl  -0x28(%ebp)
  80158f:	e8 9c 07 00 00       	call   801d30 <__umoddi3>
  801594:	83 c4 14             	add    $0x14,%esp
  801597:	0f be 80 ab 1f 80 00 	movsbl 0x801fab(%eax),%eax
  80159e:	50                   	push   %eax
  80159f:	ff d7                	call   *%edi
}
  8015a1:	83 c4 10             	add    $0x10,%esp
  8015a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015a7:	5b                   	pop    %ebx
  8015a8:	5e                   	pop    %esi
  8015a9:	5f                   	pop    %edi
  8015aa:	5d                   	pop    %ebp
  8015ab:	c3                   	ret    
  8015ac:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8015af:	eb c4                	jmp    801575 <printnum+0x73>

008015b1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8015b1:	55                   	push   %ebp
  8015b2:	89 e5                	mov    %esp,%ebp
  8015b4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8015b7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8015bb:	8b 10                	mov    (%eax),%edx
  8015bd:	3b 50 04             	cmp    0x4(%eax),%edx
  8015c0:	73 0a                	jae    8015cc <sprintputch+0x1b>
		*b->buf++ = ch;
  8015c2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8015c5:	89 08                	mov    %ecx,(%eax)
  8015c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ca:	88 02                	mov    %al,(%edx)
}
  8015cc:	5d                   	pop    %ebp
  8015cd:	c3                   	ret    

008015ce <printfmt>:
{
  8015ce:	55                   	push   %ebp
  8015cf:	89 e5                	mov    %esp,%ebp
  8015d1:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8015d4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8015d7:	50                   	push   %eax
  8015d8:	ff 75 10             	pushl  0x10(%ebp)
  8015db:	ff 75 0c             	pushl  0xc(%ebp)
  8015de:	ff 75 08             	pushl  0x8(%ebp)
  8015e1:	e8 05 00 00 00       	call   8015eb <vprintfmt>
}
  8015e6:	83 c4 10             	add    $0x10,%esp
  8015e9:	c9                   	leave  
  8015ea:	c3                   	ret    

008015eb <vprintfmt>:
{
  8015eb:	55                   	push   %ebp
  8015ec:	89 e5                	mov    %esp,%ebp
  8015ee:	57                   	push   %edi
  8015ef:	56                   	push   %esi
  8015f0:	53                   	push   %ebx
  8015f1:	83 ec 2c             	sub    $0x2c,%esp
  8015f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8015f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8015fa:	8b 7d 10             	mov    0x10(%ebp),%edi
  8015fd:	e9 c1 03 00 00       	jmp    8019c3 <vprintfmt+0x3d8>
		padc = ' ';
  801602:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  801606:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  80160d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  801614:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80161b:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801620:	8d 47 01             	lea    0x1(%edi),%eax
  801623:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801626:	0f b6 17             	movzbl (%edi),%edx
  801629:	8d 42 dd             	lea    -0x23(%edx),%eax
  80162c:	3c 55                	cmp    $0x55,%al
  80162e:	0f 87 12 04 00 00    	ja     801a46 <vprintfmt+0x45b>
  801634:	0f b6 c0             	movzbl %al,%eax
  801637:	ff 24 85 e0 20 80 00 	jmp    *0x8020e0(,%eax,4)
  80163e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801641:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  801645:	eb d9                	jmp    801620 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  801647:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80164a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80164e:	eb d0                	jmp    801620 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  801650:	0f b6 d2             	movzbl %dl,%edx
  801653:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801656:	b8 00 00 00 00       	mov    $0x0,%eax
  80165b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80165e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801661:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801665:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801668:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80166b:	83 f9 09             	cmp    $0x9,%ecx
  80166e:	77 55                	ja     8016c5 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  801670:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801673:	eb e9                	jmp    80165e <vprintfmt+0x73>
			precision = va_arg(ap, int);
  801675:	8b 45 14             	mov    0x14(%ebp),%eax
  801678:	8b 00                	mov    (%eax),%eax
  80167a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80167d:	8b 45 14             	mov    0x14(%ebp),%eax
  801680:	8d 40 04             	lea    0x4(%eax),%eax
  801683:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801686:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801689:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80168d:	79 91                	jns    801620 <vprintfmt+0x35>
				width = precision, precision = -1;
  80168f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801692:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801695:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80169c:	eb 82                	jmp    801620 <vprintfmt+0x35>
  80169e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8016a1:	85 c0                	test   %eax,%eax
  8016a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a8:	0f 49 d0             	cmovns %eax,%edx
  8016ab:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8016ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8016b1:	e9 6a ff ff ff       	jmp    801620 <vprintfmt+0x35>
  8016b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8016b9:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8016c0:	e9 5b ff ff ff       	jmp    801620 <vprintfmt+0x35>
  8016c5:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8016c8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8016cb:	eb bc                	jmp    801689 <vprintfmt+0x9e>
			lflag++;
  8016cd:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8016d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8016d3:	e9 48 ff ff ff       	jmp    801620 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8016d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8016db:	8d 78 04             	lea    0x4(%eax),%edi
  8016de:	83 ec 08             	sub    $0x8,%esp
  8016e1:	53                   	push   %ebx
  8016e2:	ff 30                	pushl  (%eax)
  8016e4:	ff d6                	call   *%esi
			break;
  8016e6:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8016e9:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8016ec:	e9 cf 02 00 00       	jmp    8019c0 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8016f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8016f4:	8d 78 04             	lea    0x4(%eax),%edi
  8016f7:	8b 00                	mov    (%eax),%eax
  8016f9:	99                   	cltd   
  8016fa:	31 d0                	xor    %edx,%eax
  8016fc:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8016fe:	83 f8 0f             	cmp    $0xf,%eax
  801701:	7f 23                	jg     801726 <vprintfmt+0x13b>
  801703:	8b 14 85 40 22 80 00 	mov    0x802240(,%eax,4),%edx
  80170a:	85 d2                	test   %edx,%edx
  80170c:	74 18                	je     801726 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  80170e:	52                   	push   %edx
  80170f:	68 41 1f 80 00       	push   $0x801f41
  801714:	53                   	push   %ebx
  801715:	56                   	push   %esi
  801716:	e8 b3 fe ff ff       	call   8015ce <printfmt>
  80171b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80171e:	89 7d 14             	mov    %edi,0x14(%ebp)
  801721:	e9 9a 02 00 00       	jmp    8019c0 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  801726:	50                   	push   %eax
  801727:	68 c3 1f 80 00       	push   $0x801fc3
  80172c:	53                   	push   %ebx
  80172d:	56                   	push   %esi
  80172e:	e8 9b fe ff ff       	call   8015ce <printfmt>
  801733:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801736:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  801739:	e9 82 02 00 00       	jmp    8019c0 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  80173e:	8b 45 14             	mov    0x14(%ebp),%eax
  801741:	83 c0 04             	add    $0x4,%eax
  801744:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801747:	8b 45 14             	mov    0x14(%ebp),%eax
  80174a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80174c:	85 ff                	test   %edi,%edi
  80174e:	b8 bc 1f 80 00       	mov    $0x801fbc,%eax
  801753:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801756:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80175a:	0f 8e bd 00 00 00    	jle    80181d <vprintfmt+0x232>
  801760:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801764:	75 0e                	jne    801774 <vprintfmt+0x189>
  801766:	89 75 08             	mov    %esi,0x8(%ebp)
  801769:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80176c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80176f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801772:	eb 6d                	jmp    8017e1 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  801774:	83 ec 08             	sub    $0x8,%esp
  801777:	ff 75 d0             	pushl  -0x30(%ebp)
  80177a:	57                   	push   %edi
  80177b:	e8 dc e9 ff ff       	call   80015c <strnlen>
  801780:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801783:	29 c1                	sub    %eax,%ecx
  801785:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  801788:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80178b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80178f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801792:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801795:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  801797:	eb 0f                	jmp    8017a8 <vprintfmt+0x1bd>
					putch(padc, putdat);
  801799:	83 ec 08             	sub    $0x8,%esp
  80179c:	53                   	push   %ebx
  80179d:	ff 75 e0             	pushl  -0x20(%ebp)
  8017a0:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8017a2:	83 ef 01             	sub    $0x1,%edi
  8017a5:	83 c4 10             	add    $0x10,%esp
  8017a8:	85 ff                	test   %edi,%edi
  8017aa:	7f ed                	jg     801799 <vprintfmt+0x1ae>
  8017ac:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8017af:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8017b2:	85 c9                	test   %ecx,%ecx
  8017b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8017b9:	0f 49 c1             	cmovns %ecx,%eax
  8017bc:	29 c1                	sub    %eax,%ecx
  8017be:	89 75 08             	mov    %esi,0x8(%ebp)
  8017c1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8017c4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8017c7:	89 cb                	mov    %ecx,%ebx
  8017c9:	eb 16                	jmp    8017e1 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8017cb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8017cf:	75 31                	jne    801802 <vprintfmt+0x217>
					putch(ch, putdat);
  8017d1:	83 ec 08             	sub    $0x8,%esp
  8017d4:	ff 75 0c             	pushl  0xc(%ebp)
  8017d7:	50                   	push   %eax
  8017d8:	ff 55 08             	call   *0x8(%ebp)
  8017db:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8017de:	83 eb 01             	sub    $0x1,%ebx
  8017e1:	83 c7 01             	add    $0x1,%edi
  8017e4:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8017e8:	0f be c2             	movsbl %dl,%eax
  8017eb:	85 c0                	test   %eax,%eax
  8017ed:	74 59                	je     801848 <vprintfmt+0x25d>
  8017ef:	85 f6                	test   %esi,%esi
  8017f1:	78 d8                	js     8017cb <vprintfmt+0x1e0>
  8017f3:	83 ee 01             	sub    $0x1,%esi
  8017f6:	79 d3                	jns    8017cb <vprintfmt+0x1e0>
  8017f8:	89 df                	mov    %ebx,%edi
  8017fa:	8b 75 08             	mov    0x8(%ebp),%esi
  8017fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801800:	eb 37                	jmp    801839 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  801802:	0f be d2             	movsbl %dl,%edx
  801805:	83 ea 20             	sub    $0x20,%edx
  801808:	83 fa 5e             	cmp    $0x5e,%edx
  80180b:	76 c4                	jbe    8017d1 <vprintfmt+0x1e6>
					putch('?', putdat);
  80180d:	83 ec 08             	sub    $0x8,%esp
  801810:	ff 75 0c             	pushl  0xc(%ebp)
  801813:	6a 3f                	push   $0x3f
  801815:	ff 55 08             	call   *0x8(%ebp)
  801818:	83 c4 10             	add    $0x10,%esp
  80181b:	eb c1                	jmp    8017de <vprintfmt+0x1f3>
  80181d:	89 75 08             	mov    %esi,0x8(%ebp)
  801820:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801823:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801826:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801829:	eb b6                	jmp    8017e1 <vprintfmt+0x1f6>
				putch(' ', putdat);
  80182b:	83 ec 08             	sub    $0x8,%esp
  80182e:	53                   	push   %ebx
  80182f:	6a 20                	push   $0x20
  801831:	ff d6                	call   *%esi
			for (; width > 0; width--)
  801833:	83 ef 01             	sub    $0x1,%edi
  801836:	83 c4 10             	add    $0x10,%esp
  801839:	85 ff                	test   %edi,%edi
  80183b:	7f ee                	jg     80182b <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  80183d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801840:	89 45 14             	mov    %eax,0x14(%ebp)
  801843:	e9 78 01 00 00       	jmp    8019c0 <vprintfmt+0x3d5>
  801848:	89 df                	mov    %ebx,%edi
  80184a:	8b 75 08             	mov    0x8(%ebp),%esi
  80184d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801850:	eb e7                	jmp    801839 <vprintfmt+0x24e>
	if (lflag >= 2)
  801852:	83 f9 01             	cmp    $0x1,%ecx
  801855:	7e 3f                	jle    801896 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  801857:	8b 45 14             	mov    0x14(%ebp),%eax
  80185a:	8b 50 04             	mov    0x4(%eax),%edx
  80185d:	8b 00                	mov    (%eax),%eax
  80185f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801862:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801865:	8b 45 14             	mov    0x14(%ebp),%eax
  801868:	8d 40 08             	lea    0x8(%eax),%eax
  80186b:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80186e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801872:	79 5c                	jns    8018d0 <vprintfmt+0x2e5>
				putch('-', putdat);
  801874:	83 ec 08             	sub    $0x8,%esp
  801877:	53                   	push   %ebx
  801878:	6a 2d                	push   $0x2d
  80187a:	ff d6                	call   *%esi
				num = -(long long) num;
  80187c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80187f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801882:	f7 da                	neg    %edx
  801884:	83 d1 00             	adc    $0x0,%ecx
  801887:	f7 d9                	neg    %ecx
  801889:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80188c:	b8 0a 00 00 00       	mov    $0xa,%eax
  801891:	e9 10 01 00 00       	jmp    8019a6 <vprintfmt+0x3bb>
	else if (lflag)
  801896:	85 c9                	test   %ecx,%ecx
  801898:	75 1b                	jne    8018b5 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  80189a:	8b 45 14             	mov    0x14(%ebp),%eax
  80189d:	8b 00                	mov    (%eax),%eax
  80189f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8018a2:	89 c1                	mov    %eax,%ecx
  8018a4:	c1 f9 1f             	sar    $0x1f,%ecx
  8018a7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8018aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8018ad:	8d 40 04             	lea    0x4(%eax),%eax
  8018b0:	89 45 14             	mov    %eax,0x14(%ebp)
  8018b3:	eb b9                	jmp    80186e <vprintfmt+0x283>
		return va_arg(*ap, long);
  8018b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8018b8:	8b 00                	mov    (%eax),%eax
  8018ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8018bd:	89 c1                	mov    %eax,%ecx
  8018bf:	c1 f9 1f             	sar    $0x1f,%ecx
  8018c2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8018c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8018c8:	8d 40 04             	lea    0x4(%eax),%eax
  8018cb:	89 45 14             	mov    %eax,0x14(%ebp)
  8018ce:	eb 9e                	jmp    80186e <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8018d0:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8018d3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8018d6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8018db:	e9 c6 00 00 00       	jmp    8019a6 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8018e0:	83 f9 01             	cmp    $0x1,%ecx
  8018e3:	7e 18                	jle    8018fd <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8018e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8018e8:	8b 10                	mov    (%eax),%edx
  8018ea:	8b 48 04             	mov    0x4(%eax),%ecx
  8018ed:	8d 40 08             	lea    0x8(%eax),%eax
  8018f0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8018f3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8018f8:	e9 a9 00 00 00       	jmp    8019a6 <vprintfmt+0x3bb>
	else if (lflag)
  8018fd:	85 c9                	test   %ecx,%ecx
  8018ff:	75 1a                	jne    80191b <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  801901:	8b 45 14             	mov    0x14(%ebp),%eax
  801904:	8b 10                	mov    (%eax),%edx
  801906:	b9 00 00 00 00       	mov    $0x0,%ecx
  80190b:	8d 40 04             	lea    0x4(%eax),%eax
  80190e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801911:	b8 0a 00 00 00       	mov    $0xa,%eax
  801916:	e9 8b 00 00 00       	jmp    8019a6 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80191b:	8b 45 14             	mov    0x14(%ebp),%eax
  80191e:	8b 10                	mov    (%eax),%edx
  801920:	b9 00 00 00 00       	mov    $0x0,%ecx
  801925:	8d 40 04             	lea    0x4(%eax),%eax
  801928:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80192b:	b8 0a 00 00 00       	mov    $0xa,%eax
  801930:	eb 74                	jmp    8019a6 <vprintfmt+0x3bb>
	if (lflag >= 2)
  801932:	83 f9 01             	cmp    $0x1,%ecx
  801935:	7e 15                	jle    80194c <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  801937:	8b 45 14             	mov    0x14(%ebp),%eax
  80193a:	8b 10                	mov    (%eax),%edx
  80193c:	8b 48 04             	mov    0x4(%eax),%ecx
  80193f:	8d 40 08             	lea    0x8(%eax),%eax
  801942:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801945:	b8 08 00 00 00       	mov    $0x8,%eax
  80194a:	eb 5a                	jmp    8019a6 <vprintfmt+0x3bb>
	else if (lflag)
  80194c:	85 c9                	test   %ecx,%ecx
  80194e:	75 17                	jne    801967 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  801950:	8b 45 14             	mov    0x14(%ebp),%eax
  801953:	8b 10                	mov    (%eax),%edx
  801955:	b9 00 00 00 00       	mov    $0x0,%ecx
  80195a:	8d 40 04             	lea    0x4(%eax),%eax
  80195d:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801960:	b8 08 00 00 00       	mov    $0x8,%eax
  801965:	eb 3f                	jmp    8019a6 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  801967:	8b 45 14             	mov    0x14(%ebp),%eax
  80196a:	8b 10                	mov    (%eax),%edx
  80196c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801971:	8d 40 04             	lea    0x4(%eax),%eax
  801974:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801977:	b8 08 00 00 00       	mov    $0x8,%eax
  80197c:	eb 28                	jmp    8019a6 <vprintfmt+0x3bb>
			putch('0', putdat);
  80197e:	83 ec 08             	sub    $0x8,%esp
  801981:	53                   	push   %ebx
  801982:	6a 30                	push   $0x30
  801984:	ff d6                	call   *%esi
			putch('x', putdat);
  801986:	83 c4 08             	add    $0x8,%esp
  801989:	53                   	push   %ebx
  80198a:	6a 78                	push   $0x78
  80198c:	ff d6                	call   *%esi
			num = (unsigned long long)
  80198e:	8b 45 14             	mov    0x14(%ebp),%eax
  801991:	8b 10                	mov    (%eax),%edx
  801993:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801998:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80199b:	8d 40 04             	lea    0x4(%eax),%eax
  80199e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8019a1:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8019a6:	83 ec 0c             	sub    $0xc,%esp
  8019a9:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8019ad:	57                   	push   %edi
  8019ae:	ff 75 e0             	pushl  -0x20(%ebp)
  8019b1:	50                   	push   %eax
  8019b2:	51                   	push   %ecx
  8019b3:	52                   	push   %edx
  8019b4:	89 da                	mov    %ebx,%edx
  8019b6:	89 f0                	mov    %esi,%eax
  8019b8:	e8 45 fb ff ff       	call   801502 <printnum>
			break;
  8019bd:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8019c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8019c3:	83 c7 01             	add    $0x1,%edi
  8019c6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8019ca:	83 f8 25             	cmp    $0x25,%eax
  8019cd:	0f 84 2f fc ff ff    	je     801602 <vprintfmt+0x17>
			if (ch == '\0')
  8019d3:	85 c0                	test   %eax,%eax
  8019d5:	0f 84 8b 00 00 00    	je     801a66 <vprintfmt+0x47b>
			putch(ch, putdat);
  8019db:	83 ec 08             	sub    $0x8,%esp
  8019de:	53                   	push   %ebx
  8019df:	50                   	push   %eax
  8019e0:	ff d6                	call   *%esi
  8019e2:	83 c4 10             	add    $0x10,%esp
  8019e5:	eb dc                	jmp    8019c3 <vprintfmt+0x3d8>
	if (lflag >= 2)
  8019e7:	83 f9 01             	cmp    $0x1,%ecx
  8019ea:	7e 15                	jle    801a01 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  8019ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8019ef:	8b 10                	mov    (%eax),%edx
  8019f1:	8b 48 04             	mov    0x4(%eax),%ecx
  8019f4:	8d 40 08             	lea    0x8(%eax),%eax
  8019f7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8019fa:	b8 10 00 00 00       	mov    $0x10,%eax
  8019ff:	eb a5                	jmp    8019a6 <vprintfmt+0x3bb>
	else if (lflag)
  801a01:	85 c9                	test   %ecx,%ecx
  801a03:	75 17                	jne    801a1c <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  801a05:	8b 45 14             	mov    0x14(%ebp),%eax
  801a08:	8b 10                	mov    (%eax),%edx
  801a0a:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a0f:	8d 40 04             	lea    0x4(%eax),%eax
  801a12:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a15:	b8 10 00 00 00       	mov    $0x10,%eax
  801a1a:	eb 8a                	jmp    8019a6 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  801a1c:	8b 45 14             	mov    0x14(%ebp),%eax
  801a1f:	8b 10                	mov    (%eax),%edx
  801a21:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a26:	8d 40 04             	lea    0x4(%eax),%eax
  801a29:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a2c:	b8 10 00 00 00       	mov    $0x10,%eax
  801a31:	e9 70 ff ff ff       	jmp    8019a6 <vprintfmt+0x3bb>
			putch(ch, putdat);
  801a36:	83 ec 08             	sub    $0x8,%esp
  801a39:	53                   	push   %ebx
  801a3a:	6a 25                	push   $0x25
  801a3c:	ff d6                	call   *%esi
			break;
  801a3e:	83 c4 10             	add    $0x10,%esp
  801a41:	e9 7a ff ff ff       	jmp    8019c0 <vprintfmt+0x3d5>
			putch('%', putdat);
  801a46:	83 ec 08             	sub    $0x8,%esp
  801a49:	53                   	push   %ebx
  801a4a:	6a 25                	push   $0x25
  801a4c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a4e:	83 c4 10             	add    $0x10,%esp
  801a51:	89 f8                	mov    %edi,%eax
  801a53:	eb 03                	jmp    801a58 <vprintfmt+0x46d>
  801a55:	83 e8 01             	sub    $0x1,%eax
  801a58:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801a5c:	75 f7                	jne    801a55 <vprintfmt+0x46a>
  801a5e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801a61:	e9 5a ff ff ff       	jmp    8019c0 <vprintfmt+0x3d5>
}
  801a66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a69:	5b                   	pop    %ebx
  801a6a:	5e                   	pop    %esi
  801a6b:	5f                   	pop    %edi
  801a6c:	5d                   	pop    %ebp
  801a6d:	c3                   	ret    

00801a6e <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801a6e:	55                   	push   %ebp
  801a6f:	89 e5                	mov    %esp,%ebp
  801a71:	83 ec 18             	sub    $0x18,%esp
  801a74:	8b 45 08             	mov    0x8(%ebp),%eax
  801a77:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801a7a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801a7d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801a81:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801a84:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801a8b:	85 c0                	test   %eax,%eax
  801a8d:	74 26                	je     801ab5 <vsnprintf+0x47>
  801a8f:	85 d2                	test   %edx,%edx
  801a91:	7e 22                	jle    801ab5 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801a93:	ff 75 14             	pushl  0x14(%ebp)
  801a96:	ff 75 10             	pushl  0x10(%ebp)
  801a99:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801a9c:	50                   	push   %eax
  801a9d:	68 b1 15 80 00       	push   $0x8015b1
  801aa2:	e8 44 fb ff ff       	call   8015eb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801aa7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801aaa:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ab0:	83 c4 10             	add    $0x10,%esp
}
  801ab3:	c9                   	leave  
  801ab4:	c3                   	ret    
		return -E_INVAL;
  801ab5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801aba:	eb f7                	jmp    801ab3 <vsnprintf+0x45>

00801abc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801abc:	55                   	push   %ebp
  801abd:	89 e5                	mov    %esp,%ebp
  801abf:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801ac2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801ac5:	50                   	push   %eax
  801ac6:	ff 75 10             	pushl  0x10(%ebp)
  801ac9:	ff 75 0c             	pushl  0xc(%ebp)
  801acc:	ff 75 08             	pushl  0x8(%ebp)
  801acf:	e8 9a ff ff ff       	call   801a6e <vsnprintf>
	va_end(ap);

	return rc;
}
  801ad4:	c9                   	leave  
  801ad5:	c3                   	ret    

00801ad6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ad6:	55                   	push   %ebp
  801ad7:	89 e5                	mov    %esp,%ebp
  801ad9:	56                   	push   %esi
  801ada:	53                   	push   %ebx
  801adb:	8b 75 08             	mov    0x8(%ebp),%esi
  801ade:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ae1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  801ae4:	85 f6                	test   %esi,%esi
  801ae6:	74 06                	je     801aee <ipc_recv+0x18>
  801ae8:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801aee:	85 db                	test   %ebx,%ebx
  801af0:	74 06                	je     801af8 <ipc_recv+0x22>
  801af2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801af8:	85 c0                	test   %eax,%eax
  801afa:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801aff:	0f 44 c2             	cmove  %edx,%eax
	int ret = sys_ipc_recv(pg);
  801b02:	83 ec 0c             	sub    $0xc,%esp
  801b05:	50                   	push   %eax
  801b06:	e8 19 ec ff ff       	call   800724 <sys_ipc_recv>
	if (ret) return ret;
  801b0b:	83 c4 10             	add    $0x10,%esp
  801b0e:	85 c0                	test   %eax,%eax
  801b10:	75 24                	jne    801b36 <ipc_recv+0x60>
	if (from_env_store)
  801b12:	85 f6                	test   %esi,%esi
  801b14:	74 0a                	je     801b20 <ipc_recv+0x4a>
		*from_env_store = thisenv->env_ipc_from;
  801b16:	a1 04 40 80 00       	mov    0x804004,%eax
  801b1b:	8b 40 74             	mov    0x74(%eax),%eax
  801b1e:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801b20:	85 db                	test   %ebx,%ebx
  801b22:	74 0a                	je     801b2e <ipc_recv+0x58>
		*perm_store = thisenv->env_ipc_perm;
  801b24:	a1 04 40 80 00       	mov    0x804004,%eax
  801b29:	8b 40 78             	mov    0x78(%eax),%eax
  801b2c:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801b2e:	a1 04 40 80 00       	mov    0x804004,%eax
  801b33:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b36:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b39:	5b                   	pop    %ebx
  801b3a:	5e                   	pop    %esi
  801b3b:	5d                   	pop    %ebp
  801b3c:	c3                   	ret    

00801b3d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b3d:	55                   	push   %ebp
  801b3e:	89 e5                	mov    %esp,%ebp
  801b40:	57                   	push   %edi
  801b41:	56                   	push   %esi
  801b42:	53                   	push   %ebx
  801b43:	83 ec 0c             	sub    $0xc,%esp
  801b46:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b49:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  801b4f:	85 db                	test   %ebx,%ebx
  801b51:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801b56:	0f 44 d8             	cmove  %eax,%ebx
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801b59:	ff 75 14             	pushl  0x14(%ebp)
  801b5c:	53                   	push   %ebx
  801b5d:	56                   	push   %esi
  801b5e:	57                   	push   %edi
  801b5f:	e8 9d eb ff ff       	call   800701 <sys_ipc_try_send>
  801b64:	83 c4 10             	add    $0x10,%esp
  801b67:	85 c0                	test   %eax,%eax
  801b69:	74 1e                	je     801b89 <ipc_send+0x4c>
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801b6b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b6e:	75 07                	jne    801b77 <ipc_send+0x3a>
		sys_yield();
  801b70:	e8 e0 e9 ff ff       	call   800555 <sys_yield>
  801b75:	eb e2                	jmp    801b59 <ipc_send+0x1c>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801b77:	50                   	push   %eax
  801b78:	68 a0 22 80 00       	push   $0x8022a0
  801b7d:	6a 36                	push   $0x36
  801b7f:	68 b7 22 80 00       	push   $0x8022b7
  801b84:	e8 8a f8 ff ff       	call   801413 <_panic>
	}
}
  801b89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b8c:	5b                   	pop    %ebx
  801b8d:	5e                   	pop    %esi
  801b8e:	5f                   	pop    %edi
  801b8f:	5d                   	pop    %ebp
  801b90:	c3                   	ret    

00801b91 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b91:	55                   	push   %ebp
  801b92:	89 e5                	mov    %esp,%ebp
  801b94:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b97:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b9c:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b9f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ba5:	8b 52 50             	mov    0x50(%edx),%edx
  801ba8:	39 ca                	cmp    %ecx,%edx
  801baa:	74 11                	je     801bbd <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801bac:	83 c0 01             	add    $0x1,%eax
  801baf:	3d 00 04 00 00       	cmp    $0x400,%eax
  801bb4:	75 e6                	jne    801b9c <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801bb6:	b8 00 00 00 00       	mov    $0x0,%eax
  801bbb:	eb 0b                	jmp    801bc8 <ipc_find_env+0x37>
			return envs[i].env_id;
  801bbd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801bc0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801bc5:	8b 40 48             	mov    0x48(%eax),%eax
}
  801bc8:	5d                   	pop    %ebp
  801bc9:	c3                   	ret    

00801bca <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801bca:	55                   	push   %ebp
  801bcb:	89 e5                	mov    %esp,%ebp
  801bcd:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bd0:	89 d0                	mov    %edx,%eax
  801bd2:	c1 e8 16             	shr    $0x16,%eax
  801bd5:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801bdc:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801be1:	f6 c1 01             	test   $0x1,%cl
  801be4:	74 1d                	je     801c03 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801be6:	c1 ea 0c             	shr    $0xc,%edx
  801be9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801bf0:	f6 c2 01             	test   $0x1,%dl
  801bf3:	74 0e                	je     801c03 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bf5:	c1 ea 0c             	shr    $0xc,%edx
  801bf8:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801bff:	ef 
  801c00:	0f b7 c0             	movzwl %ax,%eax
}
  801c03:	5d                   	pop    %ebp
  801c04:	c3                   	ret    
  801c05:	66 90                	xchg   %ax,%ax
  801c07:	66 90                	xchg   %ax,%ax
  801c09:	66 90                	xchg   %ax,%ax
  801c0b:	66 90                	xchg   %ax,%ax
  801c0d:	66 90                	xchg   %ax,%ax
  801c0f:	90                   	nop

00801c10 <__udivdi3>:
  801c10:	55                   	push   %ebp
  801c11:	57                   	push   %edi
  801c12:	56                   	push   %esi
  801c13:	53                   	push   %ebx
  801c14:	83 ec 1c             	sub    $0x1c,%esp
  801c17:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c1b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801c1f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c23:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801c27:	85 d2                	test   %edx,%edx
  801c29:	75 35                	jne    801c60 <__udivdi3+0x50>
  801c2b:	39 f3                	cmp    %esi,%ebx
  801c2d:	0f 87 bd 00 00 00    	ja     801cf0 <__udivdi3+0xe0>
  801c33:	85 db                	test   %ebx,%ebx
  801c35:	89 d9                	mov    %ebx,%ecx
  801c37:	75 0b                	jne    801c44 <__udivdi3+0x34>
  801c39:	b8 01 00 00 00       	mov    $0x1,%eax
  801c3e:	31 d2                	xor    %edx,%edx
  801c40:	f7 f3                	div    %ebx
  801c42:	89 c1                	mov    %eax,%ecx
  801c44:	31 d2                	xor    %edx,%edx
  801c46:	89 f0                	mov    %esi,%eax
  801c48:	f7 f1                	div    %ecx
  801c4a:	89 c6                	mov    %eax,%esi
  801c4c:	89 e8                	mov    %ebp,%eax
  801c4e:	89 f7                	mov    %esi,%edi
  801c50:	f7 f1                	div    %ecx
  801c52:	89 fa                	mov    %edi,%edx
  801c54:	83 c4 1c             	add    $0x1c,%esp
  801c57:	5b                   	pop    %ebx
  801c58:	5e                   	pop    %esi
  801c59:	5f                   	pop    %edi
  801c5a:	5d                   	pop    %ebp
  801c5b:	c3                   	ret    
  801c5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c60:	39 f2                	cmp    %esi,%edx
  801c62:	77 7c                	ja     801ce0 <__udivdi3+0xd0>
  801c64:	0f bd fa             	bsr    %edx,%edi
  801c67:	83 f7 1f             	xor    $0x1f,%edi
  801c6a:	0f 84 98 00 00 00    	je     801d08 <__udivdi3+0xf8>
  801c70:	89 f9                	mov    %edi,%ecx
  801c72:	b8 20 00 00 00       	mov    $0x20,%eax
  801c77:	29 f8                	sub    %edi,%eax
  801c79:	d3 e2                	shl    %cl,%edx
  801c7b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c7f:	89 c1                	mov    %eax,%ecx
  801c81:	89 da                	mov    %ebx,%edx
  801c83:	d3 ea                	shr    %cl,%edx
  801c85:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801c89:	09 d1                	or     %edx,%ecx
  801c8b:	89 f2                	mov    %esi,%edx
  801c8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c91:	89 f9                	mov    %edi,%ecx
  801c93:	d3 e3                	shl    %cl,%ebx
  801c95:	89 c1                	mov    %eax,%ecx
  801c97:	d3 ea                	shr    %cl,%edx
  801c99:	89 f9                	mov    %edi,%ecx
  801c9b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c9f:	d3 e6                	shl    %cl,%esi
  801ca1:	89 eb                	mov    %ebp,%ebx
  801ca3:	89 c1                	mov    %eax,%ecx
  801ca5:	d3 eb                	shr    %cl,%ebx
  801ca7:	09 de                	or     %ebx,%esi
  801ca9:	89 f0                	mov    %esi,%eax
  801cab:	f7 74 24 08          	divl   0x8(%esp)
  801caf:	89 d6                	mov    %edx,%esi
  801cb1:	89 c3                	mov    %eax,%ebx
  801cb3:	f7 64 24 0c          	mull   0xc(%esp)
  801cb7:	39 d6                	cmp    %edx,%esi
  801cb9:	72 0c                	jb     801cc7 <__udivdi3+0xb7>
  801cbb:	89 f9                	mov    %edi,%ecx
  801cbd:	d3 e5                	shl    %cl,%ebp
  801cbf:	39 c5                	cmp    %eax,%ebp
  801cc1:	73 5d                	jae    801d20 <__udivdi3+0x110>
  801cc3:	39 d6                	cmp    %edx,%esi
  801cc5:	75 59                	jne    801d20 <__udivdi3+0x110>
  801cc7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801cca:	31 ff                	xor    %edi,%edi
  801ccc:	89 fa                	mov    %edi,%edx
  801cce:	83 c4 1c             	add    $0x1c,%esp
  801cd1:	5b                   	pop    %ebx
  801cd2:	5e                   	pop    %esi
  801cd3:	5f                   	pop    %edi
  801cd4:	5d                   	pop    %ebp
  801cd5:	c3                   	ret    
  801cd6:	8d 76 00             	lea    0x0(%esi),%esi
  801cd9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801ce0:	31 ff                	xor    %edi,%edi
  801ce2:	31 c0                	xor    %eax,%eax
  801ce4:	89 fa                	mov    %edi,%edx
  801ce6:	83 c4 1c             	add    $0x1c,%esp
  801ce9:	5b                   	pop    %ebx
  801cea:	5e                   	pop    %esi
  801ceb:	5f                   	pop    %edi
  801cec:	5d                   	pop    %ebp
  801ced:	c3                   	ret    
  801cee:	66 90                	xchg   %ax,%ax
  801cf0:	31 ff                	xor    %edi,%edi
  801cf2:	89 e8                	mov    %ebp,%eax
  801cf4:	89 f2                	mov    %esi,%edx
  801cf6:	f7 f3                	div    %ebx
  801cf8:	89 fa                	mov    %edi,%edx
  801cfa:	83 c4 1c             	add    $0x1c,%esp
  801cfd:	5b                   	pop    %ebx
  801cfe:	5e                   	pop    %esi
  801cff:	5f                   	pop    %edi
  801d00:	5d                   	pop    %ebp
  801d01:	c3                   	ret    
  801d02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d08:	39 f2                	cmp    %esi,%edx
  801d0a:	72 06                	jb     801d12 <__udivdi3+0x102>
  801d0c:	31 c0                	xor    %eax,%eax
  801d0e:	39 eb                	cmp    %ebp,%ebx
  801d10:	77 d2                	ja     801ce4 <__udivdi3+0xd4>
  801d12:	b8 01 00 00 00       	mov    $0x1,%eax
  801d17:	eb cb                	jmp    801ce4 <__udivdi3+0xd4>
  801d19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d20:	89 d8                	mov    %ebx,%eax
  801d22:	31 ff                	xor    %edi,%edi
  801d24:	eb be                	jmp    801ce4 <__udivdi3+0xd4>
  801d26:	66 90                	xchg   %ax,%ax
  801d28:	66 90                	xchg   %ax,%ax
  801d2a:	66 90                	xchg   %ax,%ax
  801d2c:	66 90                	xchg   %ax,%ax
  801d2e:	66 90                	xchg   %ax,%ax

00801d30 <__umoddi3>:
  801d30:	55                   	push   %ebp
  801d31:	57                   	push   %edi
  801d32:	56                   	push   %esi
  801d33:	53                   	push   %ebx
  801d34:	83 ec 1c             	sub    $0x1c,%esp
  801d37:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801d3b:	8b 74 24 30          	mov    0x30(%esp),%esi
  801d3f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801d43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d47:	85 ed                	test   %ebp,%ebp
  801d49:	89 f0                	mov    %esi,%eax
  801d4b:	89 da                	mov    %ebx,%edx
  801d4d:	75 19                	jne    801d68 <__umoddi3+0x38>
  801d4f:	39 df                	cmp    %ebx,%edi
  801d51:	0f 86 b1 00 00 00    	jbe    801e08 <__umoddi3+0xd8>
  801d57:	f7 f7                	div    %edi
  801d59:	89 d0                	mov    %edx,%eax
  801d5b:	31 d2                	xor    %edx,%edx
  801d5d:	83 c4 1c             	add    $0x1c,%esp
  801d60:	5b                   	pop    %ebx
  801d61:	5e                   	pop    %esi
  801d62:	5f                   	pop    %edi
  801d63:	5d                   	pop    %ebp
  801d64:	c3                   	ret    
  801d65:	8d 76 00             	lea    0x0(%esi),%esi
  801d68:	39 dd                	cmp    %ebx,%ebp
  801d6a:	77 f1                	ja     801d5d <__umoddi3+0x2d>
  801d6c:	0f bd cd             	bsr    %ebp,%ecx
  801d6f:	83 f1 1f             	xor    $0x1f,%ecx
  801d72:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801d76:	0f 84 b4 00 00 00    	je     801e30 <__umoddi3+0x100>
  801d7c:	b8 20 00 00 00       	mov    $0x20,%eax
  801d81:	89 c2                	mov    %eax,%edx
  801d83:	8b 44 24 04          	mov    0x4(%esp),%eax
  801d87:	29 c2                	sub    %eax,%edx
  801d89:	89 c1                	mov    %eax,%ecx
  801d8b:	89 f8                	mov    %edi,%eax
  801d8d:	d3 e5                	shl    %cl,%ebp
  801d8f:	89 d1                	mov    %edx,%ecx
  801d91:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801d95:	d3 e8                	shr    %cl,%eax
  801d97:	09 c5                	or     %eax,%ebp
  801d99:	8b 44 24 04          	mov    0x4(%esp),%eax
  801d9d:	89 c1                	mov    %eax,%ecx
  801d9f:	d3 e7                	shl    %cl,%edi
  801da1:	89 d1                	mov    %edx,%ecx
  801da3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801da7:	89 df                	mov    %ebx,%edi
  801da9:	d3 ef                	shr    %cl,%edi
  801dab:	89 c1                	mov    %eax,%ecx
  801dad:	89 f0                	mov    %esi,%eax
  801daf:	d3 e3                	shl    %cl,%ebx
  801db1:	89 d1                	mov    %edx,%ecx
  801db3:	89 fa                	mov    %edi,%edx
  801db5:	d3 e8                	shr    %cl,%eax
  801db7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801dbc:	09 d8                	or     %ebx,%eax
  801dbe:	f7 f5                	div    %ebp
  801dc0:	d3 e6                	shl    %cl,%esi
  801dc2:	89 d1                	mov    %edx,%ecx
  801dc4:	f7 64 24 08          	mull   0x8(%esp)
  801dc8:	39 d1                	cmp    %edx,%ecx
  801dca:	89 c3                	mov    %eax,%ebx
  801dcc:	89 d7                	mov    %edx,%edi
  801dce:	72 06                	jb     801dd6 <__umoddi3+0xa6>
  801dd0:	75 0e                	jne    801de0 <__umoddi3+0xb0>
  801dd2:	39 c6                	cmp    %eax,%esi
  801dd4:	73 0a                	jae    801de0 <__umoddi3+0xb0>
  801dd6:	2b 44 24 08          	sub    0x8(%esp),%eax
  801dda:	19 ea                	sbb    %ebp,%edx
  801ddc:	89 d7                	mov    %edx,%edi
  801dde:	89 c3                	mov    %eax,%ebx
  801de0:	89 ca                	mov    %ecx,%edx
  801de2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801de7:	29 de                	sub    %ebx,%esi
  801de9:	19 fa                	sbb    %edi,%edx
  801deb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  801def:	89 d0                	mov    %edx,%eax
  801df1:	d3 e0                	shl    %cl,%eax
  801df3:	89 d9                	mov    %ebx,%ecx
  801df5:	d3 ee                	shr    %cl,%esi
  801df7:	d3 ea                	shr    %cl,%edx
  801df9:	09 f0                	or     %esi,%eax
  801dfb:	83 c4 1c             	add    $0x1c,%esp
  801dfe:	5b                   	pop    %ebx
  801dff:	5e                   	pop    %esi
  801e00:	5f                   	pop    %edi
  801e01:	5d                   	pop    %ebp
  801e02:	c3                   	ret    
  801e03:	90                   	nop
  801e04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e08:	85 ff                	test   %edi,%edi
  801e0a:	89 f9                	mov    %edi,%ecx
  801e0c:	75 0b                	jne    801e19 <__umoddi3+0xe9>
  801e0e:	b8 01 00 00 00       	mov    $0x1,%eax
  801e13:	31 d2                	xor    %edx,%edx
  801e15:	f7 f7                	div    %edi
  801e17:	89 c1                	mov    %eax,%ecx
  801e19:	89 d8                	mov    %ebx,%eax
  801e1b:	31 d2                	xor    %edx,%edx
  801e1d:	f7 f1                	div    %ecx
  801e1f:	89 f0                	mov    %esi,%eax
  801e21:	f7 f1                	div    %ecx
  801e23:	e9 31 ff ff ff       	jmp    801d59 <__umoddi3+0x29>
  801e28:	90                   	nop
  801e29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e30:	39 dd                	cmp    %ebx,%ebp
  801e32:	72 08                	jb     801e3c <__umoddi3+0x10c>
  801e34:	39 f7                	cmp    %esi,%edi
  801e36:	0f 87 21 ff ff ff    	ja     801d5d <__umoddi3+0x2d>
  801e3c:	89 da                	mov    %ebx,%edx
  801e3e:	89 f0                	mov    %esi,%eax
  801e40:	29 f8                	sub    %edi,%eax
  801e42:	19 ea                	sbb    %ebp,%edx
  801e44:	e9 14 ff ff ff       	jmp    801d5d <__umoddi3+0x2d>
