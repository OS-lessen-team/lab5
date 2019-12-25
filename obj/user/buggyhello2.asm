
obj/user/buggyhello2.debug：     文件格式 elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  800039:	68 00 00 10 00       	push   $0x100000
  80003e:	ff 35 00 30 80 00    	pushl  0x803000
  800044:	e8 65 00 00 00       	call   8000ae <sys_cputs>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800059:	e8 ce 00 00 00       	call   80012c <sys_getenvid>
	thisenv = envs + ENVX(envid); 
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x2d>
		binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	e8 ae ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800085:	e8 0a 00 00 00       	call   800094 <exit>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80009a:	e8 92 04 00 00       	call   800531 <close_all>
	sys_env_destroy(0);
  80009f:	83 ec 0c             	sub    $0xc,%esp
  8000a2:	6a 00                	push   $0x0
  8000a4:	e8 42 00 00 00       	call   8000eb <sys_env_destroy>
}
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    

008000ae <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ae:	55                   	push   %ebp
  8000af:	89 e5                	mov    %esp,%ebp
  8000b1:	57                   	push   %edi
  8000b2:	56                   	push   %esi
  8000b3:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bf:	89 c3                	mov    %eax,%ebx
  8000c1:	89 c7                	mov    %eax,%edi
  8000c3:	89 c6                	mov    %eax,%esi
  8000c5:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c7:	5b                   	pop    %ebx
  8000c8:	5e                   	pop    %esi
  8000c9:	5f                   	pop    %edi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    

008000cc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	57                   	push   %edi
  8000d0:	56                   	push   %esi
  8000d1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000dc:	89 d1                	mov    %edx,%ecx
  8000de:	89 d3                	mov    %edx,%ebx
  8000e0:	89 d7                	mov    %edx,%edi
  8000e2:	89 d6                	mov    %edx,%esi
  8000e4:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fc:	b8 03 00 00 00       	mov    $0x3,%eax
  800101:	89 cb                	mov    %ecx,%ebx
  800103:	89 cf                	mov    %ecx,%edi
  800105:	89 ce                	mov    %ecx,%esi
  800107:	cd 30                	int    $0x30
	if(check && ret > 0)
  800109:	85 c0                	test   %eax,%eax
  80010b:	7f 08                	jg     800115 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800110:	5b                   	pop    %ebx
  800111:	5e                   	pop    %esi
  800112:	5f                   	pop    %edi
  800113:	5d                   	pop    %ebp
  800114:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800115:	83 ec 0c             	sub    $0xc,%esp
  800118:	50                   	push   %eax
  800119:	6a 03                	push   $0x3
  80011b:	68 d8 1d 80 00       	push   $0x801dd8
  800120:	6a 23                	push   $0x23
  800122:	68 f5 1d 80 00       	push   $0x801df5
  800127:	e8 dd 0e 00 00       	call   801009 <_panic>

0080012c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	57                   	push   %edi
  800130:	56                   	push   %esi
  800131:	53                   	push   %ebx
	asm volatile("int %1\n"
  800132:	ba 00 00 00 00       	mov    $0x0,%edx
  800137:	b8 02 00 00 00       	mov    $0x2,%eax
  80013c:	89 d1                	mov    %edx,%ecx
  80013e:	89 d3                	mov    %edx,%ebx
  800140:	89 d7                	mov    %edx,%edi
  800142:	89 d6                	mov    %edx,%esi
  800144:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800146:	5b                   	pop    %ebx
  800147:	5e                   	pop    %esi
  800148:	5f                   	pop    %edi
  800149:	5d                   	pop    %ebp
  80014a:	c3                   	ret    

0080014b <sys_yield>:

void
sys_yield(void)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	57                   	push   %edi
  80014f:	56                   	push   %esi
  800150:	53                   	push   %ebx
	asm volatile("int %1\n"
  800151:	ba 00 00 00 00       	mov    $0x0,%edx
  800156:	b8 0b 00 00 00       	mov    $0xb,%eax
  80015b:	89 d1                	mov    %edx,%ecx
  80015d:	89 d3                	mov    %edx,%ebx
  80015f:	89 d7                	mov    %edx,%edi
  800161:	89 d6                	mov    %edx,%esi
  800163:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800165:	5b                   	pop    %ebx
  800166:	5e                   	pop    %esi
  800167:	5f                   	pop    %edi
  800168:	5d                   	pop    %ebp
  800169:	c3                   	ret    

0080016a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80016a:	55                   	push   %ebp
  80016b:	89 e5                	mov    %esp,%ebp
  80016d:	57                   	push   %edi
  80016e:	56                   	push   %esi
  80016f:	53                   	push   %ebx
  800170:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800173:	be 00 00 00 00       	mov    $0x0,%esi
  800178:	8b 55 08             	mov    0x8(%ebp),%edx
  80017b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017e:	b8 04 00 00 00       	mov    $0x4,%eax
  800183:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800186:	89 f7                	mov    %esi,%edi
  800188:	cd 30                	int    $0x30
	if(check && ret > 0)
  80018a:	85 c0                	test   %eax,%eax
  80018c:	7f 08                	jg     800196 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80018e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800191:	5b                   	pop    %ebx
  800192:	5e                   	pop    %esi
  800193:	5f                   	pop    %edi
  800194:	5d                   	pop    %ebp
  800195:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800196:	83 ec 0c             	sub    $0xc,%esp
  800199:	50                   	push   %eax
  80019a:	6a 04                	push   $0x4
  80019c:	68 d8 1d 80 00       	push   $0x801dd8
  8001a1:	6a 23                	push   $0x23
  8001a3:	68 f5 1d 80 00       	push   $0x801df5
  8001a8:	e8 5c 0e 00 00       	call   801009 <_panic>

008001ad <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ad:	55                   	push   %ebp
  8001ae:	89 e5                	mov    %esp,%ebp
  8001b0:	57                   	push   %edi
  8001b1:	56                   	push   %esi
  8001b2:	53                   	push   %ebx
  8001b3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001bc:	b8 05 00 00 00       	mov    $0x5,%eax
  8001c1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ca:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001cc:	85 c0                	test   %eax,%eax
  8001ce:	7f 08                	jg     8001d8 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d3:	5b                   	pop    %ebx
  8001d4:	5e                   	pop    %esi
  8001d5:	5f                   	pop    %edi
  8001d6:	5d                   	pop    %ebp
  8001d7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d8:	83 ec 0c             	sub    $0xc,%esp
  8001db:	50                   	push   %eax
  8001dc:	6a 05                	push   $0x5
  8001de:	68 d8 1d 80 00       	push   $0x801dd8
  8001e3:	6a 23                	push   $0x23
  8001e5:	68 f5 1d 80 00       	push   $0x801df5
  8001ea:	e8 1a 0e 00 00       	call   801009 <_panic>

008001ef <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ef:	55                   	push   %ebp
  8001f0:	89 e5                	mov    %esp,%ebp
  8001f2:	57                   	push   %edi
  8001f3:	56                   	push   %esi
  8001f4:	53                   	push   %ebx
  8001f5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001fd:	8b 55 08             	mov    0x8(%ebp),%edx
  800200:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800203:	b8 06 00 00 00       	mov    $0x6,%eax
  800208:	89 df                	mov    %ebx,%edi
  80020a:	89 de                	mov    %ebx,%esi
  80020c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80020e:	85 c0                	test   %eax,%eax
  800210:	7f 08                	jg     80021a <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800212:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800215:	5b                   	pop    %ebx
  800216:	5e                   	pop    %esi
  800217:	5f                   	pop    %edi
  800218:	5d                   	pop    %ebp
  800219:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80021a:	83 ec 0c             	sub    $0xc,%esp
  80021d:	50                   	push   %eax
  80021e:	6a 06                	push   $0x6
  800220:	68 d8 1d 80 00       	push   $0x801dd8
  800225:	6a 23                	push   $0x23
  800227:	68 f5 1d 80 00       	push   $0x801df5
  80022c:	e8 d8 0d 00 00       	call   801009 <_panic>

00800231 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	57                   	push   %edi
  800235:	56                   	push   %esi
  800236:	53                   	push   %ebx
  800237:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80023a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023f:	8b 55 08             	mov    0x8(%ebp),%edx
  800242:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800245:	b8 08 00 00 00       	mov    $0x8,%eax
  80024a:	89 df                	mov    %ebx,%edi
  80024c:	89 de                	mov    %ebx,%esi
  80024e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800250:	85 c0                	test   %eax,%eax
  800252:	7f 08                	jg     80025c <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800254:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800257:	5b                   	pop    %ebx
  800258:	5e                   	pop    %esi
  800259:	5f                   	pop    %edi
  80025a:	5d                   	pop    %ebp
  80025b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80025c:	83 ec 0c             	sub    $0xc,%esp
  80025f:	50                   	push   %eax
  800260:	6a 08                	push   $0x8
  800262:	68 d8 1d 80 00       	push   $0x801dd8
  800267:	6a 23                	push   $0x23
  800269:	68 f5 1d 80 00       	push   $0x801df5
  80026e:	e8 96 0d 00 00       	call   801009 <_panic>

00800273 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	57                   	push   %edi
  800277:	56                   	push   %esi
  800278:	53                   	push   %ebx
  800279:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80027c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800281:	8b 55 08             	mov    0x8(%ebp),%edx
  800284:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800287:	b8 09 00 00 00       	mov    $0x9,%eax
  80028c:	89 df                	mov    %ebx,%edi
  80028e:	89 de                	mov    %ebx,%esi
  800290:	cd 30                	int    $0x30
	if(check && ret > 0)
  800292:	85 c0                	test   %eax,%eax
  800294:	7f 08                	jg     80029e <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800296:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800299:	5b                   	pop    %ebx
  80029a:	5e                   	pop    %esi
  80029b:	5f                   	pop    %edi
  80029c:	5d                   	pop    %ebp
  80029d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80029e:	83 ec 0c             	sub    $0xc,%esp
  8002a1:	50                   	push   %eax
  8002a2:	6a 09                	push   $0x9
  8002a4:	68 d8 1d 80 00       	push   $0x801dd8
  8002a9:	6a 23                	push   $0x23
  8002ab:	68 f5 1d 80 00       	push   $0x801df5
  8002b0:	e8 54 0d 00 00       	call   801009 <_panic>

008002b5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b5:	55                   	push   %ebp
  8002b6:	89 e5                	mov    %esp,%ebp
  8002b8:	57                   	push   %edi
  8002b9:	56                   	push   %esi
  8002ba:	53                   	push   %ebx
  8002bb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002be:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002ce:	89 df                	mov    %ebx,%edi
  8002d0:	89 de                	mov    %ebx,%esi
  8002d2:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002d4:	85 c0                	test   %eax,%eax
  8002d6:	7f 08                	jg     8002e0 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002db:	5b                   	pop    %ebx
  8002dc:	5e                   	pop    %esi
  8002dd:	5f                   	pop    %edi
  8002de:	5d                   	pop    %ebp
  8002df:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e0:	83 ec 0c             	sub    $0xc,%esp
  8002e3:	50                   	push   %eax
  8002e4:	6a 0a                	push   $0xa
  8002e6:	68 d8 1d 80 00       	push   $0x801dd8
  8002eb:	6a 23                	push   $0x23
  8002ed:	68 f5 1d 80 00       	push   $0x801df5
  8002f2:	e8 12 0d 00 00       	call   801009 <_panic>

008002f7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f7:	55                   	push   %ebp
  8002f8:	89 e5                	mov    %esp,%ebp
  8002fa:	57                   	push   %edi
  8002fb:	56                   	push   %esi
  8002fc:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002fd:	8b 55 08             	mov    0x8(%ebp),%edx
  800300:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800303:	b8 0c 00 00 00       	mov    $0xc,%eax
  800308:	be 00 00 00 00       	mov    $0x0,%esi
  80030d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800310:	8b 7d 14             	mov    0x14(%ebp),%edi
  800313:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800315:	5b                   	pop    %ebx
  800316:	5e                   	pop    %esi
  800317:	5f                   	pop    %edi
  800318:	5d                   	pop    %ebp
  800319:	c3                   	ret    

0080031a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	57                   	push   %edi
  80031e:	56                   	push   %esi
  80031f:	53                   	push   %ebx
  800320:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800323:	b9 00 00 00 00       	mov    $0x0,%ecx
  800328:	8b 55 08             	mov    0x8(%ebp),%edx
  80032b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800330:	89 cb                	mov    %ecx,%ebx
  800332:	89 cf                	mov    %ecx,%edi
  800334:	89 ce                	mov    %ecx,%esi
  800336:	cd 30                	int    $0x30
	if(check && ret > 0)
  800338:	85 c0                	test   %eax,%eax
  80033a:	7f 08                	jg     800344 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80033c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80033f:	5b                   	pop    %ebx
  800340:	5e                   	pop    %esi
  800341:	5f                   	pop    %edi
  800342:	5d                   	pop    %ebp
  800343:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800344:	83 ec 0c             	sub    $0xc,%esp
  800347:	50                   	push   %eax
  800348:	6a 0d                	push   $0xd
  80034a:	68 d8 1d 80 00       	push   $0x801dd8
  80034f:	6a 23                	push   $0x23
  800351:	68 f5 1d 80 00       	push   $0x801df5
  800356:	e8 ae 0c 00 00       	call   801009 <_panic>

0080035b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80035e:	8b 45 08             	mov    0x8(%ebp),%eax
  800361:	05 00 00 00 30       	add    $0x30000000,%eax
  800366:	c1 e8 0c             	shr    $0xc,%eax
}
  800369:	5d                   	pop    %ebp
  80036a:	c3                   	ret    

0080036b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80036b:	55                   	push   %ebp
  80036c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80036e:	8b 45 08             	mov    0x8(%ebp),%eax
  800371:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800376:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80037b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800380:	5d                   	pop    %ebp
  800381:	c3                   	ret    

00800382 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800382:	55                   	push   %ebp
  800383:	89 e5                	mov    %esp,%ebp
  800385:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800388:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80038d:	89 c2                	mov    %eax,%edx
  80038f:	c1 ea 16             	shr    $0x16,%edx
  800392:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800399:	f6 c2 01             	test   $0x1,%dl
  80039c:	74 2a                	je     8003c8 <fd_alloc+0x46>
  80039e:	89 c2                	mov    %eax,%edx
  8003a0:	c1 ea 0c             	shr    $0xc,%edx
  8003a3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003aa:	f6 c2 01             	test   $0x1,%dl
  8003ad:	74 19                	je     8003c8 <fd_alloc+0x46>
  8003af:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8003b4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003b9:	75 d2                	jne    80038d <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003bb:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003c1:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8003c6:	eb 07                	jmp    8003cf <fd_alloc+0x4d>
			*fd_store = fd;
  8003c8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003cf:	5d                   	pop    %ebp
  8003d0:	c3                   	ret    

008003d1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003d1:	55                   	push   %ebp
  8003d2:	89 e5                	mov    %esp,%ebp
  8003d4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003d7:	83 f8 1f             	cmp    $0x1f,%eax
  8003da:	77 36                	ja     800412 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003dc:	c1 e0 0c             	shl    $0xc,%eax
  8003df:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003e4:	89 c2                	mov    %eax,%edx
  8003e6:	c1 ea 16             	shr    $0x16,%edx
  8003e9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003f0:	f6 c2 01             	test   $0x1,%dl
  8003f3:	74 24                	je     800419 <fd_lookup+0x48>
  8003f5:	89 c2                	mov    %eax,%edx
  8003f7:	c1 ea 0c             	shr    $0xc,%edx
  8003fa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800401:	f6 c2 01             	test   $0x1,%dl
  800404:	74 1a                	je     800420 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800406:	8b 55 0c             	mov    0xc(%ebp),%edx
  800409:	89 02                	mov    %eax,(%edx)
	return 0;
  80040b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800410:	5d                   	pop    %ebp
  800411:	c3                   	ret    
		return -E_INVAL;
  800412:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800417:	eb f7                	jmp    800410 <fd_lookup+0x3f>
		return -E_INVAL;
  800419:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80041e:	eb f0                	jmp    800410 <fd_lookup+0x3f>
  800420:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800425:	eb e9                	jmp    800410 <fd_lookup+0x3f>

00800427 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800427:	55                   	push   %ebp
  800428:	89 e5                	mov    %esp,%ebp
  80042a:	83 ec 08             	sub    $0x8,%esp
  80042d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800430:	ba 80 1e 80 00       	mov    $0x801e80,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800435:	b8 08 30 80 00       	mov    $0x803008,%eax
		if (devtab[i]->dev_id == dev_id) {
  80043a:	39 08                	cmp    %ecx,(%eax)
  80043c:	74 33                	je     800471 <dev_lookup+0x4a>
  80043e:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800441:	8b 02                	mov    (%edx),%eax
  800443:	85 c0                	test   %eax,%eax
  800445:	75 f3                	jne    80043a <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800447:	a1 04 40 80 00       	mov    0x804004,%eax
  80044c:	8b 40 48             	mov    0x48(%eax),%eax
  80044f:	83 ec 04             	sub    $0x4,%esp
  800452:	51                   	push   %ecx
  800453:	50                   	push   %eax
  800454:	68 04 1e 80 00       	push   $0x801e04
  800459:	e8 86 0c 00 00       	call   8010e4 <cprintf>
	*dev = 0;
  80045e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800461:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800467:	83 c4 10             	add    $0x10,%esp
  80046a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80046f:	c9                   	leave  
  800470:	c3                   	ret    
			*dev = devtab[i];
  800471:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800474:	89 01                	mov    %eax,(%ecx)
			return 0;
  800476:	b8 00 00 00 00       	mov    $0x0,%eax
  80047b:	eb f2                	jmp    80046f <dev_lookup+0x48>

0080047d <fd_close>:
{
  80047d:	55                   	push   %ebp
  80047e:	89 e5                	mov    %esp,%ebp
  800480:	57                   	push   %edi
  800481:	56                   	push   %esi
  800482:	53                   	push   %ebx
  800483:	83 ec 1c             	sub    $0x1c,%esp
  800486:	8b 75 08             	mov    0x8(%ebp),%esi
  800489:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80048c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80048f:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800490:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800496:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800499:	50                   	push   %eax
  80049a:	e8 32 ff ff ff       	call   8003d1 <fd_lookup>
  80049f:	89 c3                	mov    %eax,%ebx
  8004a1:	83 c4 08             	add    $0x8,%esp
  8004a4:	85 c0                	test   %eax,%eax
  8004a6:	78 05                	js     8004ad <fd_close+0x30>
	    || fd != fd2)
  8004a8:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8004ab:	74 16                	je     8004c3 <fd_close+0x46>
		return (must_exist ? r : 0);
  8004ad:	89 f8                	mov    %edi,%eax
  8004af:	84 c0                	test   %al,%al
  8004b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b6:	0f 44 d8             	cmove  %eax,%ebx
}
  8004b9:	89 d8                	mov    %ebx,%eax
  8004bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004be:	5b                   	pop    %ebx
  8004bf:	5e                   	pop    %esi
  8004c0:	5f                   	pop    %edi
  8004c1:	5d                   	pop    %ebp
  8004c2:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004c3:	83 ec 08             	sub    $0x8,%esp
  8004c6:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8004c9:	50                   	push   %eax
  8004ca:	ff 36                	pushl  (%esi)
  8004cc:	e8 56 ff ff ff       	call   800427 <dev_lookup>
  8004d1:	89 c3                	mov    %eax,%ebx
  8004d3:	83 c4 10             	add    $0x10,%esp
  8004d6:	85 c0                	test   %eax,%eax
  8004d8:	78 15                	js     8004ef <fd_close+0x72>
		if (dev->dev_close)
  8004da:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004dd:	8b 40 10             	mov    0x10(%eax),%eax
  8004e0:	85 c0                	test   %eax,%eax
  8004e2:	74 1b                	je     8004ff <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  8004e4:	83 ec 0c             	sub    $0xc,%esp
  8004e7:	56                   	push   %esi
  8004e8:	ff d0                	call   *%eax
  8004ea:	89 c3                	mov    %eax,%ebx
  8004ec:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8004ef:	83 ec 08             	sub    $0x8,%esp
  8004f2:	56                   	push   %esi
  8004f3:	6a 00                	push   $0x0
  8004f5:	e8 f5 fc ff ff       	call   8001ef <sys_page_unmap>
	return r;
  8004fa:	83 c4 10             	add    $0x10,%esp
  8004fd:	eb ba                	jmp    8004b9 <fd_close+0x3c>
			r = 0;
  8004ff:	bb 00 00 00 00       	mov    $0x0,%ebx
  800504:	eb e9                	jmp    8004ef <fd_close+0x72>

00800506 <close>:

int
close(int fdnum)
{
  800506:	55                   	push   %ebp
  800507:	89 e5                	mov    %esp,%ebp
  800509:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80050c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80050f:	50                   	push   %eax
  800510:	ff 75 08             	pushl  0x8(%ebp)
  800513:	e8 b9 fe ff ff       	call   8003d1 <fd_lookup>
  800518:	83 c4 08             	add    $0x8,%esp
  80051b:	85 c0                	test   %eax,%eax
  80051d:	78 10                	js     80052f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80051f:	83 ec 08             	sub    $0x8,%esp
  800522:	6a 01                	push   $0x1
  800524:	ff 75 f4             	pushl  -0xc(%ebp)
  800527:	e8 51 ff ff ff       	call   80047d <fd_close>
  80052c:	83 c4 10             	add    $0x10,%esp
}
  80052f:	c9                   	leave  
  800530:	c3                   	ret    

00800531 <close_all>:

void
close_all(void)
{
  800531:	55                   	push   %ebp
  800532:	89 e5                	mov    %esp,%ebp
  800534:	53                   	push   %ebx
  800535:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800538:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80053d:	83 ec 0c             	sub    $0xc,%esp
  800540:	53                   	push   %ebx
  800541:	e8 c0 ff ff ff       	call   800506 <close>
	for (i = 0; i < MAXFD; i++)
  800546:	83 c3 01             	add    $0x1,%ebx
  800549:	83 c4 10             	add    $0x10,%esp
  80054c:	83 fb 20             	cmp    $0x20,%ebx
  80054f:	75 ec                	jne    80053d <close_all+0xc>
}
  800551:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800554:	c9                   	leave  
  800555:	c3                   	ret    

00800556 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800556:	55                   	push   %ebp
  800557:	89 e5                	mov    %esp,%ebp
  800559:	57                   	push   %edi
  80055a:	56                   	push   %esi
  80055b:	53                   	push   %ebx
  80055c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80055f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800562:	50                   	push   %eax
  800563:	ff 75 08             	pushl  0x8(%ebp)
  800566:	e8 66 fe ff ff       	call   8003d1 <fd_lookup>
  80056b:	89 c3                	mov    %eax,%ebx
  80056d:	83 c4 08             	add    $0x8,%esp
  800570:	85 c0                	test   %eax,%eax
  800572:	0f 88 81 00 00 00    	js     8005f9 <dup+0xa3>
		return r;
	close(newfdnum);
  800578:	83 ec 0c             	sub    $0xc,%esp
  80057b:	ff 75 0c             	pushl  0xc(%ebp)
  80057e:	e8 83 ff ff ff       	call   800506 <close>

	newfd = INDEX2FD(newfdnum);
  800583:	8b 75 0c             	mov    0xc(%ebp),%esi
  800586:	c1 e6 0c             	shl    $0xc,%esi
  800589:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80058f:	83 c4 04             	add    $0x4,%esp
  800592:	ff 75 e4             	pushl  -0x1c(%ebp)
  800595:	e8 d1 fd ff ff       	call   80036b <fd2data>
  80059a:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80059c:	89 34 24             	mov    %esi,(%esp)
  80059f:	e8 c7 fd ff ff       	call   80036b <fd2data>
  8005a4:	83 c4 10             	add    $0x10,%esp
  8005a7:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005a9:	89 d8                	mov    %ebx,%eax
  8005ab:	c1 e8 16             	shr    $0x16,%eax
  8005ae:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005b5:	a8 01                	test   $0x1,%al
  8005b7:	74 11                	je     8005ca <dup+0x74>
  8005b9:	89 d8                	mov    %ebx,%eax
  8005bb:	c1 e8 0c             	shr    $0xc,%eax
  8005be:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005c5:	f6 c2 01             	test   $0x1,%dl
  8005c8:	75 39                	jne    800603 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005ca:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005cd:	89 d0                	mov    %edx,%eax
  8005cf:	c1 e8 0c             	shr    $0xc,%eax
  8005d2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005d9:	83 ec 0c             	sub    $0xc,%esp
  8005dc:	25 07 0e 00 00       	and    $0xe07,%eax
  8005e1:	50                   	push   %eax
  8005e2:	56                   	push   %esi
  8005e3:	6a 00                	push   $0x0
  8005e5:	52                   	push   %edx
  8005e6:	6a 00                	push   $0x0
  8005e8:	e8 c0 fb ff ff       	call   8001ad <sys_page_map>
  8005ed:	89 c3                	mov    %eax,%ebx
  8005ef:	83 c4 20             	add    $0x20,%esp
  8005f2:	85 c0                	test   %eax,%eax
  8005f4:	78 31                	js     800627 <dup+0xd1>
		goto err;

	return newfdnum;
  8005f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005f9:	89 d8                	mov    %ebx,%eax
  8005fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005fe:	5b                   	pop    %ebx
  8005ff:	5e                   	pop    %esi
  800600:	5f                   	pop    %edi
  800601:	5d                   	pop    %ebp
  800602:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800603:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80060a:	83 ec 0c             	sub    $0xc,%esp
  80060d:	25 07 0e 00 00       	and    $0xe07,%eax
  800612:	50                   	push   %eax
  800613:	57                   	push   %edi
  800614:	6a 00                	push   $0x0
  800616:	53                   	push   %ebx
  800617:	6a 00                	push   $0x0
  800619:	e8 8f fb ff ff       	call   8001ad <sys_page_map>
  80061e:	89 c3                	mov    %eax,%ebx
  800620:	83 c4 20             	add    $0x20,%esp
  800623:	85 c0                	test   %eax,%eax
  800625:	79 a3                	jns    8005ca <dup+0x74>
	sys_page_unmap(0, newfd);
  800627:	83 ec 08             	sub    $0x8,%esp
  80062a:	56                   	push   %esi
  80062b:	6a 00                	push   $0x0
  80062d:	e8 bd fb ff ff       	call   8001ef <sys_page_unmap>
	sys_page_unmap(0, nva);
  800632:	83 c4 08             	add    $0x8,%esp
  800635:	57                   	push   %edi
  800636:	6a 00                	push   $0x0
  800638:	e8 b2 fb ff ff       	call   8001ef <sys_page_unmap>
	return r;
  80063d:	83 c4 10             	add    $0x10,%esp
  800640:	eb b7                	jmp    8005f9 <dup+0xa3>

00800642 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800642:	55                   	push   %ebp
  800643:	89 e5                	mov    %esp,%ebp
  800645:	53                   	push   %ebx
  800646:	83 ec 14             	sub    $0x14,%esp
  800649:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80064c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80064f:	50                   	push   %eax
  800650:	53                   	push   %ebx
  800651:	e8 7b fd ff ff       	call   8003d1 <fd_lookup>
  800656:	83 c4 08             	add    $0x8,%esp
  800659:	85 c0                	test   %eax,%eax
  80065b:	78 3f                	js     80069c <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80065d:	83 ec 08             	sub    $0x8,%esp
  800660:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800663:	50                   	push   %eax
  800664:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800667:	ff 30                	pushl  (%eax)
  800669:	e8 b9 fd ff ff       	call   800427 <dev_lookup>
  80066e:	83 c4 10             	add    $0x10,%esp
  800671:	85 c0                	test   %eax,%eax
  800673:	78 27                	js     80069c <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800675:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800678:	8b 42 08             	mov    0x8(%edx),%eax
  80067b:	83 e0 03             	and    $0x3,%eax
  80067e:	83 f8 01             	cmp    $0x1,%eax
  800681:	74 1e                	je     8006a1 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  800683:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800686:	8b 40 08             	mov    0x8(%eax),%eax
  800689:	85 c0                	test   %eax,%eax
  80068b:	74 35                	je     8006c2 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80068d:	83 ec 04             	sub    $0x4,%esp
  800690:	ff 75 10             	pushl  0x10(%ebp)
  800693:	ff 75 0c             	pushl  0xc(%ebp)
  800696:	52                   	push   %edx
  800697:	ff d0                	call   *%eax
  800699:	83 c4 10             	add    $0x10,%esp
}
  80069c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80069f:	c9                   	leave  
  8006a0:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006a1:	a1 04 40 80 00       	mov    0x804004,%eax
  8006a6:	8b 40 48             	mov    0x48(%eax),%eax
  8006a9:	83 ec 04             	sub    $0x4,%esp
  8006ac:	53                   	push   %ebx
  8006ad:	50                   	push   %eax
  8006ae:	68 45 1e 80 00       	push   $0x801e45
  8006b3:	e8 2c 0a 00 00       	call   8010e4 <cprintf>
		return -E_INVAL;
  8006b8:	83 c4 10             	add    $0x10,%esp
  8006bb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006c0:	eb da                	jmp    80069c <read+0x5a>
		return -E_NOT_SUPP;
  8006c2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8006c7:	eb d3                	jmp    80069c <read+0x5a>

008006c9 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006c9:	55                   	push   %ebp
  8006ca:	89 e5                	mov    %esp,%ebp
  8006cc:	57                   	push   %edi
  8006cd:	56                   	push   %esi
  8006ce:	53                   	push   %ebx
  8006cf:	83 ec 0c             	sub    $0xc,%esp
  8006d2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006d5:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006d8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006dd:	39 f3                	cmp    %esi,%ebx
  8006df:	73 25                	jae    800706 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006e1:	83 ec 04             	sub    $0x4,%esp
  8006e4:	89 f0                	mov    %esi,%eax
  8006e6:	29 d8                	sub    %ebx,%eax
  8006e8:	50                   	push   %eax
  8006e9:	89 d8                	mov    %ebx,%eax
  8006eb:	03 45 0c             	add    0xc(%ebp),%eax
  8006ee:	50                   	push   %eax
  8006ef:	57                   	push   %edi
  8006f0:	e8 4d ff ff ff       	call   800642 <read>
		if (m < 0)
  8006f5:	83 c4 10             	add    $0x10,%esp
  8006f8:	85 c0                	test   %eax,%eax
  8006fa:	78 08                	js     800704 <readn+0x3b>
			return m;
		if (m == 0)
  8006fc:	85 c0                	test   %eax,%eax
  8006fe:	74 06                	je     800706 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  800700:	01 c3                	add    %eax,%ebx
  800702:	eb d9                	jmp    8006dd <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800704:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  800706:	89 d8                	mov    %ebx,%eax
  800708:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80070b:	5b                   	pop    %ebx
  80070c:	5e                   	pop    %esi
  80070d:	5f                   	pop    %edi
  80070e:	5d                   	pop    %ebp
  80070f:	c3                   	ret    

00800710 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800710:	55                   	push   %ebp
  800711:	89 e5                	mov    %esp,%ebp
  800713:	53                   	push   %ebx
  800714:	83 ec 14             	sub    $0x14,%esp
  800717:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80071a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80071d:	50                   	push   %eax
  80071e:	53                   	push   %ebx
  80071f:	e8 ad fc ff ff       	call   8003d1 <fd_lookup>
  800724:	83 c4 08             	add    $0x8,%esp
  800727:	85 c0                	test   %eax,%eax
  800729:	78 3a                	js     800765 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80072b:	83 ec 08             	sub    $0x8,%esp
  80072e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800731:	50                   	push   %eax
  800732:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800735:	ff 30                	pushl  (%eax)
  800737:	e8 eb fc ff ff       	call   800427 <dev_lookup>
  80073c:	83 c4 10             	add    $0x10,%esp
  80073f:	85 c0                	test   %eax,%eax
  800741:	78 22                	js     800765 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800743:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800746:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80074a:	74 1e                	je     80076a <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80074c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80074f:	8b 52 0c             	mov    0xc(%edx),%edx
  800752:	85 d2                	test   %edx,%edx
  800754:	74 35                	je     80078b <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800756:	83 ec 04             	sub    $0x4,%esp
  800759:	ff 75 10             	pushl  0x10(%ebp)
  80075c:	ff 75 0c             	pushl  0xc(%ebp)
  80075f:	50                   	push   %eax
  800760:	ff d2                	call   *%edx
  800762:	83 c4 10             	add    $0x10,%esp
}
  800765:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800768:	c9                   	leave  
  800769:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80076a:	a1 04 40 80 00       	mov    0x804004,%eax
  80076f:	8b 40 48             	mov    0x48(%eax),%eax
  800772:	83 ec 04             	sub    $0x4,%esp
  800775:	53                   	push   %ebx
  800776:	50                   	push   %eax
  800777:	68 61 1e 80 00       	push   $0x801e61
  80077c:	e8 63 09 00 00       	call   8010e4 <cprintf>
		return -E_INVAL;
  800781:	83 c4 10             	add    $0x10,%esp
  800784:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800789:	eb da                	jmp    800765 <write+0x55>
		return -E_NOT_SUPP;
  80078b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800790:	eb d3                	jmp    800765 <write+0x55>

00800792 <seek>:

int
seek(int fdnum, off_t offset)
{
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
  800795:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800798:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80079b:	50                   	push   %eax
  80079c:	ff 75 08             	pushl  0x8(%ebp)
  80079f:	e8 2d fc ff ff       	call   8003d1 <fd_lookup>
  8007a4:	83 c4 08             	add    $0x8,%esp
  8007a7:	85 c0                	test   %eax,%eax
  8007a9:	78 0e                	js     8007b9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007b1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007b9:	c9                   	leave  
  8007ba:	c3                   	ret    

008007bb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007bb:	55                   	push   %ebp
  8007bc:	89 e5                	mov    %esp,%ebp
  8007be:	53                   	push   %ebx
  8007bf:	83 ec 14             	sub    $0x14,%esp
  8007c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007c5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007c8:	50                   	push   %eax
  8007c9:	53                   	push   %ebx
  8007ca:	e8 02 fc ff ff       	call   8003d1 <fd_lookup>
  8007cf:	83 c4 08             	add    $0x8,%esp
  8007d2:	85 c0                	test   %eax,%eax
  8007d4:	78 37                	js     80080d <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007d6:	83 ec 08             	sub    $0x8,%esp
  8007d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007dc:	50                   	push   %eax
  8007dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e0:	ff 30                	pushl  (%eax)
  8007e2:	e8 40 fc ff ff       	call   800427 <dev_lookup>
  8007e7:	83 c4 10             	add    $0x10,%esp
  8007ea:	85 c0                	test   %eax,%eax
  8007ec:	78 1f                	js     80080d <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007f1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007f5:	74 1b                	je     800812 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8007f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007fa:	8b 52 18             	mov    0x18(%edx),%edx
  8007fd:	85 d2                	test   %edx,%edx
  8007ff:	74 32                	je     800833 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800801:	83 ec 08             	sub    $0x8,%esp
  800804:	ff 75 0c             	pushl  0xc(%ebp)
  800807:	50                   	push   %eax
  800808:	ff d2                	call   *%edx
  80080a:	83 c4 10             	add    $0x10,%esp
}
  80080d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800810:	c9                   	leave  
  800811:	c3                   	ret    
			thisenv->env_id, fdnum);
  800812:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800817:	8b 40 48             	mov    0x48(%eax),%eax
  80081a:	83 ec 04             	sub    $0x4,%esp
  80081d:	53                   	push   %ebx
  80081e:	50                   	push   %eax
  80081f:	68 24 1e 80 00       	push   $0x801e24
  800824:	e8 bb 08 00 00       	call   8010e4 <cprintf>
		return -E_INVAL;
  800829:	83 c4 10             	add    $0x10,%esp
  80082c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800831:	eb da                	jmp    80080d <ftruncate+0x52>
		return -E_NOT_SUPP;
  800833:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800838:	eb d3                	jmp    80080d <ftruncate+0x52>

0080083a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	53                   	push   %ebx
  80083e:	83 ec 14             	sub    $0x14,%esp
  800841:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800844:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800847:	50                   	push   %eax
  800848:	ff 75 08             	pushl  0x8(%ebp)
  80084b:	e8 81 fb ff ff       	call   8003d1 <fd_lookup>
  800850:	83 c4 08             	add    $0x8,%esp
  800853:	85 c0                	test   %eax,%eax
  800855:	78 4b                	js     8008a2 <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800857:	83 ec 08             	sub    $0x8,%esp
  80085a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80085d:	50                   	push   %eax
  80085e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800861:	ff 30                	pushl  (%eax)
  800863:	e8 bf fb ff ff       	call   800427 <dev_lookup>
  800868:	83 c4 10             	add    $0x10,%esp
  80086b:	85 c0                	test   %eax,%eax
  80086d:	78 33                	js     8008a2 <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  80086f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800872:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800876:	74 2f                	je     8008a7 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800878:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80087b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800882:	00 00 00 
	stat->st_isdir = 0;
  800885:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80088c:	00 00 00 
	stat->st_dev = dev;
  80088f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800895:	83 ec 08             	sub    $0x8,%esp
  800898:	53                   	push   %ebx
  800899:	ff 75 f0             	pushl  -0x10(%ebp)
  80089c:	ff 50 14             	call   *0x14(%eax)
  80089f:	83 c4 10             	add    $0x10,%esp
}
  8008a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008a5:	c9                   	leave  
  8008a6:	c3                   	ret    
		return -E_NOT_SUPP;
  8008a7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8008ac:	eb f4                	jmp    8008a2 <fstat+0x68>

008008ae <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008ae:	55                   	push   %ebp
  8008af:	89 e5                	mov    %esp,%ebp
  8008b1:	56                   	push   %esi
  8008b2:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008b3:	83 ec 08             	sub    $0x8,%esp
  8008b6:	6a 00                	push   $0x0
  8008b8:	ff 75 08             	pushl  0x8(%ebp)
  8008bb:	e8 da 01 00 00       	call   800a9a <open>
  8008c0:	89 c3                	mov    %eax,%ebx
  8008c2:	83 c4 10             	add    $0x10,%esp
  8008c5:	85 c0                	test   %eax,%eax
  8008c7:	78 1b                	js     8008e4 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008c9:	83 ec 08             	sub    $0x8,%esp
  8008cc:	ff 75 0c             	pushl  0xc(%ebp)
  8008cf:	50                   	push   %eax
  8008d0:	e8 65 ff ff ff       	call   80083a <fstat>
  8008d5:	89 c6                	mov    %eax,%esi
	close(fd);
  8008d7:	89 1c 24             	mov    %ebx,(%esp)
  8008da:	e8 27 fc ff ff       	call   800506 <close>
	return r;
  8008df:	83 c4 10             	add    $0x10,%esp
  8008e2:	89 f3                	mov    %esi,%ebx
}
  8008e4:	89 d8                	mov    %ebx,%eax
  8008e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008e9:	5b                   	pop    %ebx
  8008ea:	5e                   	pop    %esi
  8008eb:	5d                   	pop    %ebp
  8008ec:	c3                   	ret    

008008ed <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008ed:	55                   	push   %ebp
  8008ee:	89 e5                	mov    %esp,%ebp
  8008f0:	56                   	push   %esi
  8008f1:	53                   	push   %ebx
  8008f2:	89 c6                	mov    %eax,%esi
  8008f4:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008f6:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8008fd:	74 27                	je     800926 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008ff:	6a 07                	push   $0x7
  800901:	68 00 50 80 00       	push   $0x805000
  800906:	56                   	push   %esi
  800907:	ff 35 00 40 80 00    	pushl  0x804000
  80090d:	e8 95 11 00 00       	call   801aa7 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800912:	83 c4 0c             	add    $0xc,%esp
  800915:	6a 00                	push   $0x0
  800917:	53                   	push   %ebx
  800918:	6a 00                	push   $0x0
  80091a:	e8 21 11 00 00       	call   801a40 <ipc_recv>
}
  80091f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800922:	5b                   	pop    %ebx
  800923:	5e                   	pop    %esi
  800924:	5d                   	pop    %ebp
  800925:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800926:	83 ec 0c             	sub    $0xc,%esp
  800929:	6a 01                	push   $0x1
  80092b:	e8 cb 11 00 00       	call   801afb <ipc_find_env>
  800930:	a3 00 40 80 00       	mov    %eax,0x804000
  800935:	83 c4 10             	add    $0x10,%esp
  800938:	eb c5                	jmp    8008ff <fsipc+0x12>

0080093a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800940:	8b 45 08             	mov    0x8(%ebp),%eax
  800943:	8b 40 0c             	mov    0xc(%eax),%eax
  800946:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80094b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80094e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800953:	ba 00 00 00 00       	mov    $0x0,%edx
  800958:	b8 02 00 00 00       	mov    $0x2,%eax
  80095d:	e8 8b ff ff ff       	call   8008ed <fsipc>
}
  800962:	c9                   	leave  
  800963:	c3                   	ret    

00800964 <devfile_flush>:
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80096a:	8b 45 08             	mov    0x8(%ebp),%eax
  80096d:	8b 40 0c             	mov    0xc(%eax),%eax
  800970:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800975:	ba 00 00 00 00       	mov    $0x0,%edx
  80097a:	b8 06 00 00 00       	mov    $0x6,%eax
  80097f:	e8 69 ff ff ff       	call   8008ed <fsipc>
}
  800984:	c9                   	leave  
  800985:	c3                   	ret    

00800986 <devfile_stat>:
{
  800986:	55                   	push   %ebp
  800987:	89 e5                	mov    %esp,%ebp
  800989:	53                   	push   %ebx
  80098a:	83 ec 04             	sub    $0x4,%esp
  80098d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800990:	8b 45 08             	mov    0x8(%ebp),%eax
  800993:	8b 40 0c             	mov    0xc(%eax),%eax
  800996:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80099b:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a0:	b8 05 00 00 00       	mov    $0x5,%eax
  8009a5:	e8 43 ff ff ff       	call   8008ed <fsipc>
  8009aa:	85 c0                	test   %eax,%eax
  8009ac:	78 2c                	js     8009da <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009ae:	83 ec 08             	sub    $0x8,%esp
  8009b1:	68 00 50 80 00       	push   $0x805000
  8009b6:	53                   	push   %ebx
  8009b7:	e8 47 0d 00 00       	call   801703 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009bc:	a1 80 50 80 00       	mov    0x805080,%eax
  8009c1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009c7:	a1 84 50 80 00       	mov    0x805084,%eax
  8009cc:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009d2:	83 c4 10             	add    $0x10,%esp
  8009d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009dd:	c9                   	leave  
  8009de:	c3                   	ret    

008009df <devfile_write>:
{
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	83 ec 0c             	sub    $0xc,%esp
  8009e5:	8b 45 10             	mov    0x10(%ebp),%eax
    	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8009eb:	8b 52 0c             	mov    0xc(%edx),%edx
  8009ee:	89 15 00 50 80 00    	mov    %edx,0x805000
    	fsipcbuf.write.req_n = n;
  8009f4:	a3 04 50 80 00       	mov    %eax,0x805004
    	memmove(fsipcbuf.write.req_buf, buf, n);
  8009f9:	50                   	push   %eax
  8009fa:	ff 75 0c             	pushl  0xc(%ebp)
  8009fd:	68 08 50 80 00       	push   $0x805008
  800a02:	e8 8a 0e 00 00       	call   801891 <memmove>
    	return fsipc(FSREQ_WRITE, NULL);
  800a07:	ba 00 00 00 00       	mov    $0x0,%edx
  800a0c:	b8 04 00 00 00       	mov    $0x4,%eax
  800a11:	e8 d7 fe ff ff       	call   8008ed <fsipc>
}
  800a16:	c9                   	leave  
  800a17:	c3                   	ret    

00800a18 <devfile_read>:
{
  800a18:	55                   	push   %ebp
  800a19:	89 e5                	mov    %esp,%ebp
  800a1b:	56                   	push   %esi
  800a1c:	53                   	push   %ebx
  800a1d:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a20:	8b 45 08             	mov    0x8(%ebp),%eax
  800a23:	8b 40 0c             	mov    0xc(%eax),%eax
  800a26:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a2b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a31:	ba 00 00 00 00       	mov    $0x0,%edx
  800a36:	b8 03 00 00 00       	mov    $0x3,%eax
  800a3b:	e8 ad fe ff ff       	call   8008ed <fsipc>
  800a40:	89 c3                	mov    %eax,%ebx
  800a42:	85 c0                	test   %eax,%eax
  800a44:	78 1f                	js     800a65 <devfile_read+0x4d>
	assert(r <= n);
  800a46:	39 f0                	cmp    %esi,%eax
  800a48:	77 24                	ja     800a6e <devfile_read+0x56>
	assert(r <= PGSIZE);
  800a4a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a4f:	7f 33                	jg     800a84 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a51:	83 ec 04             	sub    $0x4,%esp
  800a54:	50                   	push   %eax
  800a55:	68 00 50 80 00       	push   $0x805000
  800a5a:	ff 75 0c             	pushl  0xc(%ebp)
  800a5d:	e8 2f 0e 00 00       	call   801891 <memmove>
	return r;
  800a62:	83 c4 10             	add    $0x10,%esp
}
  800a65:	89 d8                	mov    %ebx,%eax
  800a67:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a6a:	5b                   	pop    %ebx
  800a6b:	5e                   	pop    %esi
  800a6c:	5d                   	pop    %ebp
  800a6d:	c3                   	ret    
	assert(r <= n);
  800a6e:	68 90 1e 80 00       	push   $0x801e90
  800a73:	68 97 1e 80 00       	push   $0x801e97
  800a78:	6a 7c                	push   $0x7c
  800a7a:	68 ac 1e 80 00       	push   $0x801eac
  800a7f:	e8 85 05 00 00       	call   801009 <_panic>
	assert(r <= PGSIZE);
  800a84:	68 b7 1e 80 00       	push   $0x801eb7
  800a89:	68 97 1e 80 00       	push   $0x801e97
  800a8e:	6a 7d                	push   $0x7d
  800a90:	68 ac 1e 80 00       	push   $0x801eac
  800a95:	e8 6f 05 00 00       	call   801009 <_panic>

00800a9a <open>:
{
  800a9a:	55                   	push   %ebp
  800a9b:	89 e5                	mov    %esp,%ebp
  800a9d:	56                   	push   %esi
  800a9e:	53                   	push   %ebx
  800a9f:	83 ec 1c             	sub    $0x1c,%esp
  800aa2:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800aa5:	56                   	push   %esi
  800aa6:	e8 21 0c 00 00       	call   8016cc <strlen>
  800aab:	83 c4 10             	add    $0x10,%esp
  800aae:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ab3:	7f 6c                	jg     800b21 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  800ab5:	83 ec 0c             	sub    $0xc,%esp
  800ab8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800abb:	50                   	push   %eax
  800abc:	e8 c1 f8 ff ff       	call   800382 <fd_alloc>
  800ac1:	89 c3                	mov    %eax,%ebx
  800ac3:	83 c4 10             	add    $0x10,%esp
  800ac6:	85 c0                	test   %eax,%eax
  800ac8:	78 3c                	js     800b06 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  800aca:	83 ec 08             	sub    $0x8,%esp
  800acd:	56                   	push   %esi
  800ace:	68 00 50 80 00       	push   $0x805000
  800ad3:	e8 2b 0c 00 00       	call   801703 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ad8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800adb:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800ae0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ae3:	b8 01 00 00 00       	mov    $0x1,%eax
  800ae8:	e8 00 fe ff ff       	call   8008ed <fsipc>
  800aed:	89 c3                	mov    %eax,%ebx
  800aef:	83 c4 10             	add    $0x10,%esp
  800af2:	85 c0                	test   %eax,%eax
  800af4:	78 19                	js     800b0f <open+0x75>
	return fd2num(fd);
  800af6:	83 ec 0c             	sub    $0xc,%esp
  800af9:	ff 75 f4             	pushl  -0xc(%ebp)
  800afc:	e8 5a f8 ff ff       	call   80035b <fd2num>
  800b01:	89 c3                	mov    %eax,%ebx
  800b03:	83 c4 10             	add    $0x10,%esp
}
  800b06:	89 d8                	mov    %ebx,%eax
  800b08:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b0b:	5b                   	pop    %ebx
  800b0c:	5e                   	pop    %esi
  800b0d:	5d                   	pop    %ebp
  800b0e:	c3                   	ret    
		fd_close(fd, 0);
  800b0f:	83 ec 08             	sub    $0x8,%esp
  800b12:	6a 00                	push   $0x0
  800b14:	ff 75 f4             	pushl  -0xc(%ebp)
  800b17:	e8 61 f9 ff ff       	call   80047d <fd_close>
		return r;
  800b1c:	83 c4 10             	add    $0x10,%esp
  800b1f:	eb e5                	jmp    800b06 <open+0x6c>
		return -E_BAD_PATH;
  800b21:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b26:	eb de                	jmp    800b06 <open+0x6c>

00800b28 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b28:	55                   	push   %ebp
  800b29:	89 e5                	mov    %esp,%ebp
  800b2b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b2e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b33:	b8 08 00 00 00       	mov    $0x8,%eax
  800b38:	e8 b0 fd ff ff       	call   8008ed <fsipc>
}
  800b3d:	c9                   	leave  
  800b3e:	c3                   	ret    

00800b3f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b3f:	55                   	push   %ebp
  800b40:	89 e5                	mov    %esp,%ebp
  800b42:	56                   	push   %esi
  800b43:	53                   	push   %ebx
  800b44:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b47:	83 ec 0c             	sub    $0xc,%esp
  800b4a:	ff 75 08             	pushl  0x8(%ebp)
  800b4d:	e8 19 f8 ff ff       	call   80036b <fd2data>
  800b52:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b54:	83 c4 08             	add    $0x8,%esp
  800b57:	68 c3 1e 80 00       	push   $0x801ec3
  800b5c:	53                   	push   %ebx
  800b5d:	e8 a1 0b 00 00       	call   801703 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b62:	8b 46 04             	mov    0x4(%esi),%eax
  800b65:	2b 06                	sub    (%esi),%eax
  800b67:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b6d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b74:	00 00 00 
	stat->st_dev = &devpipe;
  800b77:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  800b7e:	30 80 00 
	return 0;
}
  800b81:	b8 00 00 00 00       	mov    $0x0,%eax
  800b86:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b89:	5b                   	pop    %ebx
  800b8a:	5e                   	pop    %esi
  800b8b:	5d                   	pop    %ebp
  800b8c:	c3                   	ret    

00800b8d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	53                   	push   %ebx
  800b91:	83 ec 0c             	sub    $0xc,%esp
  800b94:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b97:	53                   	push   %ebx
  800b98:	6a 00                	push   $0x0
  800b9a:	e8 50 f6 ff ff       	call   8001ef <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b9f:	89 1c 24             	mov    %ebx,(%esp)
  800ba2:	e8 c4 f7 ff ff       	call   80036b <fd2data>
  800ba7:	83 c4 08             	add    $0x8,%esp
  800baa:	50                   	push   %eax
  800bab:	6a 00                	push   $0x0
  800bad:	e8 3d f6 ff ff       	call   8001ef <sys_page_unmap>
}
  800bb2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bb5:	c9                   	leave  
  800bb6:	c3                   	ret    

00800bb7 <_pipeisclosed>:
{
  800bb7:	55                   	push   %ebp
  800bb8:	89 e5                	mov    %esp,%ebp
  800bba:	57                   	push   %edi
  800bbb:	56                   	push   %esi
  800bbc:	53                   	push   %ebx
  800bbd:	83 ec 1c             	sub    $0x1c,%esp
  800bc0:	89 c7                	mov    %eax,%edi
  800bc2:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800bc4:	a1 04 40 80 00       	mov    0x804004,%eax
  800bc9:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800bcc:	83 ec 0c             	sub    $0xc,%esp
  800bcf:	57                   	push   %edi
  800bd0:	e8 5f 0f 00 00       	call   801b34 <pageref>
  800bd5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800bd8:	89 34 24             	mov    %esi,(%esp)
  800bdb:	e8 54 0f 00 00       	call   801b34 <pageref>
		nn = thisenv->env_runs;
  800be0:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800be6:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800be9:	83 c4 10             	add    $0x10,%esp
  800bec:	39 cb                	cmp    %ecx,%ebx
  800bee:	74 1b                	je     800c0b <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800bf0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800bf3:	75 cf                	jne    800bc4 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800bf5:	8b 42 58             	mov    0x58(%edx),%eax
  800bf8:	6a 01                	push   $0x1
  800bfa:	50                   	push   %eax
  800bfb:	53                   	push   %ebx
  800bfc:	68 ca 1e 80 00       	push   $0x801eca
  800c01:	e8 de 04 00 00       	call   8010e4 <cprintf>
  800c06:	83 c4 10             	add    $0x10,%esp
  800c09:	eb b9                	jmp    800bc4 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800c0b:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c0e:	0f 94 c0             	sete   %al
  800c11:	0f b6 c0             	movzbl %al,%eax
}
  800c14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c17:	5b                   	pop    %ebx
  800c18:	5e                   	pop    %esi
  800c19:	5f                   	pop    %edi
  800c1a:	5d                   	pop    %ebp
  800c1b:	c3                   	ret    

00800c1c <devpipe_write>:
{
  800c1c:	55                   	push   %ebp
  800c1d:	89 e5                	mov    %esp,%ebp
  800c1f:	57                   	push   %edi
  800c20:	56                   	push   %esi
  800c21:	53                   	push   %ebx
  800c22:	83 ec 28             	sub    $0x28,%esp
  800c25:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800c28:	56                   	push   %esi
  800c29:	e8 3d f7 ff ff       	call   80036b <fd2data>
  800c2e:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c30:	83 c4 10             	add    $0x10,%esp
  800c33:	bf 00 00 00 00       	mov    $0x0,%edi
  800c38:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c3b:	74 4f                	je     800c8c <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c3d:	8b 43 04             	mov    0x4(%ebx),%eax
  800c40:	8b 0b                	mov    (%ebx),%ecx
  800c42:	8d 51 20             	lea    0x20(%ecx),%edx
  800c45:	39 d0                	cmp    %edx,%eax
  800c47:	72 14                	jb     800c5d <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  800c49:	89 da                	mov    %ebx,%edx
  800c4b:	89 f0                	mov    %esi,%eax
  800c4d:	e8 65 ff ff ff       	call   800bb7 <_pipeisclosed>
  800c52:	85 c0                	test   %eax,%eax
  800c54:	75 3a                	jne    800c90 <devpipe_write+0x74>
			sys_yield();
  800c56:	e8 f0 f4 ff ff       	call   80014b <sys_yield>
  800c5b:	eb e0                	jmp    800c3d <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c60:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c64:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c67:	89 c2                	mov    %eax,%edx
  800c69:	c1 fa 1f             	sar    $0x1f,%edx
  800c6c:	89 d1                	mov    %edx,%ecx
  800c6e:	c1 e9 1b             	shr    $0x1b,%ecx
  800c71:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c74:	83 e2 1f             	and    $0x1f,%edx
  800c77:	29 ca                	sub    %ecx,%edx
  800c79:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c7d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c81:	83 c0 01             	add    $0x1,%eax
  800c84:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800c87:	83 c7 01             	add    $0x1,%edi
  800c8a:	eb ac                	jmp    800c38 <devpipe_write+0x1c>
	return i;
  800c8c:	89 f8                	mov    %edi,%eax
  800c8e:	eb 05                	jmp    800c95 <devpipe_write+0x79>
				return 0;
  800c90:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c98:	5b                   	pop    %ebx
  800c99:	5e                   	pop    %esi
  800c9a:	5f                   	pop    %edi
  800c9b:	5d                   	pop    %ebp
  800c9c:	c3                   	ret    

00800c9d <devpipe_read>:
{
  800c9d:	55                   	push   %ebp
  800c9e:	89 e5                	mov    %esp,%ebp
  800ca0:	57                   	push   %edi
  800ca1:	56                   	push   %esi
  800ca2:	53                   	push   %ebx
  800ca3:	83 ec 18             	sub    $0x18,%esp
  800ca6:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800ca9:	57                   	push   %edi
  800caa:	e8 bc f6 ff ff       	call   80036b <fd2data>
  800caf:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800cb1:	83 c4 10             	add    $0x10,%esp
  800cb4:	be 00 00 00 00       	mov    $0x0,%esi
  800cb9:	3b 75 10             	cmp    0x10(%ebp),%esi
  800cbc:	74 47                	je     800d05 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  800cbe:	8b 03                	mov    (%ebx),%eax
  800cc0:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cc3:	75 22                	jne    800ce7 <devpipe_read+0x4a>
			if (i > 0)
  800cc5:	85 f6                	test   %esi,%esi
  800cc7:	75 14                	jne    800cdd <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  800cc9:	89 da                	mov    %ebx,%edx
  800ccb:	89 f8                	mov    %edi,%eax
  800ccd:	e8 e5 fe ff ff       	call   800bb7 <_pipeisclosed>
  800cd2:	85 c0                	test   %eax,%eax
  800cd4:	75 33                	jne    800d09 <devpipe_read+0x6c>
			sys_yield();
  800cd6:	e8 70 f4 ff ff       	call   80014b <sys_yield>
  800cdb:	eb e1                	jmp    800cbe <devpipe_read+0x21>
				return i;
  800cdd:	89 f0                	mov    %esi,%eax
}
  800cdf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce2:	5b                   	pop    %ebx
  800ce3:	5e                   	pop    %esi
  800ce4:	5f                   	pop    %edi
  800ce5:	5d                   	pop    %ebp
  800ce6:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800ce7:	99                   	cltd   
  800ce8:	c1 ea 1b             	shr    $0x1b,%edx
  800ceb:	01 d0                	add    %edx,%eax
  800ced:	83 e0 1f             	and    $0x1f,%eax
  800cf0:	29 d0                	sub    %edx,%eax
  800cf2:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800cf7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfa:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800cfd:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800d00:	83 c6 01             	add    $0x1,%esi
  800d03:	eb b4                	jmp    800cb9 <devpipe_read+0x1c>
	return i;
  800d05:	89 f0                	mov    %esi,%eax
  800d07:	eb d6                	jmp    800cdf <devpipe_read+0x42>
				return 0;
  800d09:	b8 00 00 00 00       	mov    $0x0,%eax
  800d0e:	eb cf                	jmp    800cdf <devpipe_read+0x42>

00800d10 <pipe>:
{
  800d10:	55                   	push   %ebp
  800d11:	89 e5                	mov    %esp,%ebp
  800d13:	56                   	push   %esi
  800d14:	53                   	push   %ebx
  800d15:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800d18:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d1b:	50                   	push   %eax
  800d1c:	e8 61 f6 ff ff       	call   800382 <fd_alloc>
  800d21:	89 c3                	mov    %eax,%ebx
  800d23:	83 c4 10             	add    $0x10,%esp
  800d26:	85 c0                	test   %eax,%eax
  800d28:	78 5b                	js     800d85 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d2a:	83 ec 04             	sub    $0x4,%esp
  800d2d:	68 07 04 00 00       	push   $0x407
  800d32:	ff 75 f4             	pushl  -0xc(%ebp)
  800d35:	6a 00                	push   $0x0
  800d37:	e8 2e f4 ff ff       	call   80016a <sys_page_alloc>
  800d3c:	89 c3                	mov    %eax,%ebx
  800d3e:	83 c4 10             	add    $0x10,%esp
  800d41:	85 c0                	test   %eax,%eax
  800d43:	78 40                	js     800d85 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  800d45:	83 ec 0c             	sub    $0xc,%esp
  800d48:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d4b:	50                   	push   %eax
  800d4c:	e8 31 f6 ff ff       	call   800382 <fd_alloc>
  800d51:	89 c3                	mov    %eax,%ebx
  800d53:	83 c4 10             	add    $0x10,%esp
  800d56:	85 c0                	test   %eax,%eax
  800d58:	78 1b                	js     800d75 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d5a:	83 ec 04             	sub    $0x4,%esp
  800d5d:	68 07 04 00 00       	push   $0x407
  800d62:	ff 75 f0             	pushl  -0x10(%ebp)
  800d65:	6a 00                	push   $0x0
  800d67:	e8 fe f3 ff ff       	call   80016a <sys_page_alloc>
  800d6c:	89 c3                	mov    %eax,%ebx
  800d6e:	83 c4 10             	add    $0x10,%esp
  800d71:	85 c0                	test   %eax,%eax
  800d73:	79 19                	jns    800d8e <pipe+0x7e>
	sys_page_unmap(0, fd0);
  800d75:	83 ec 08             	sub    $0x8,%esp
  800d78:	ff 75 f4             	pushl  -0xc(%ebp)
  800d7b:	6a 00                	push   $0x0
  800d7d:	e8 6d f4 ff ff       	call   8001ef <sys_page_unmap>
  800d82:	83 c4 10             	add    $0x10,%esp
}
  800d85:	89 d8                	mov    %ebx,%eax
  800d87:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d8a:	5b                   	pop    %ebx
  800d8b:	5e                   	pop    %esi
  800d8c:	5d                   	pop    %ebp
  800d8d:	c3                   	ret    
	va = fd2data(fd0);
  800d8e:	83 ec 0c             	sub    $0xc,%esp
  800d91:	ff 75 f4             	pushl  -0xc(%ebp)
  800d94:	e8 d2 f5 ff ff       	call   80036b <fd2data>
  800d99:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d9b:	83 c4 0c             	add    $0xc,%esp
  800d9e:	68 07 04 00 00       	push   $0x407
  800da3:	50                   	push   %eax
  800da4:	6a 00                	push   $0x0
  800da6:	e8 bf f3 ff ff       	call   80016a <sys_page_alloc>
  800dab:	89 c3                	mov    %eax,%ebx
  800dad:	83 c4 10             	add    $0x10,%esp
  800db0:	85 c0                	test   %eax,%eax
  800db2:	0f 88 8c 00 00 00    	js     800e44 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800db8:	83 ec 0c             	sub    $0xc,%esp
  800dbb:	ff 75 f0             	pushl  -0x10(%ebp)
  800dbe:	e8 a8 f5 ff ff       	call   80036b <fd2data>
  800dc3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dca:	50                   	push   %eax
  800dcb:	6a 00                	push   $0x0
  800dcd:	56                   	push   %esi
  800dce:	6a 00                	push   $0x0
  800dd0:	e8 d8 f3 ff ff       	call   8001ad <sys_page_map>
  800dd5:	89 c3                	mov    %eax,%ebx
  800dd7:	83 c4 20             	add    $0x20,%esp
  800dda:	85 c0                	test   %eax,%eax
  800ddc:	78 58                	js     800e36 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  800dde:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800de1:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800de7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800de9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dec:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  800df3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800df6:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800dfc:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800dfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e01:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800e08:	83 ec 0c             	sub    $0xc,%esp
  800e0b:	ff 75 f4             	pushl  -0xc(%ebp)
  800e0e:	e8 48 f5 ff ff       	call   80035b <fd2num>
  800e13:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e16:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e18:	83 c4 04             	add    $0x4,%esp
  800e1b:	ff 75 f0             	pushl  -0x10(%ebp)
  800e1e:	e8 38 f5 ff ff       	call   80035b <fd2num>
  800e23:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e26:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e29:	83 c4 10             	add    $0x10,%esp
  800e2c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e31:	e9 4f ff ff ff       	jmp    800d85 <pipe+0x75>
	sys_page_unmap(0, va);
  800e36:	83 ec 08             	sub    $0x8,%esp
  800e39:	56                   	push   %esi
  800e3a:	6a 00                	push   $0x0
  800e3c:	e8 ae f3 ff ff       	call   8001ef <sys_page_unmap>
  800e41:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800e44:	83 ec 08             	sub    $0x8,%esp
  800e47:	ff 75 f0             	pushl  -0x10(%ebp)
  800e4a:	6a 00                	push   $0x0
  800e4c:	e8 9e f3 ff ff       	call   8001ef <sys_page_unmap>
  800e51:	83 c4 10             	add    $0x10,%esp
  800e54:	e9 1c ff ff ff       	jmp    800d75 <pipe+0x65>

00800e59 <pipeisclosed>:
{
  800e59:	55                   	push   %ebp
  800e5a:	89 e5                	mov    %esp,%ebp
  800e5c:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e5f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e62:	50                   	push   %eax
  800e63:	ff 75 08             	pushl  0x8(%ebp)
  800e66:	e8 66 f5 ff ff       	call   8003d1 <fd_lookup>
  800e6b:	83 c4 10             	add    $0x10,%esp
  800e6e:	85 c0                	test   %eax,%eax
  800e70:	78 18                	js     800e8a <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  800e72:	83 ec 0c             	sub    $0xc,%esp
  800e75:	ff 75 f4             	pushl  -0xc(%ebp)
  800e78:	e8 ee f4 ff ff       	call   80036b <fd2data>
	return _pipeisclosed(fd, p);
  800e7d:	89 c2                	mov    %eax,%edx
  800e7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e82:	e8 30 fd ff ff       	call   800bb7 <_pipeisclosed>
  800e87:	83 c4 10             	add    $0x10,%esp
}
  800e8a:	c9                   	leave  
  800e8b:	c3                   	ret    

00800e8c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e8c:	55                   	push   %ebp
  800e8d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e94:	5d                   	pop    %ebp
  800e95:	c3                   	ret    

00800e96 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e96:	55                   	push   %ebp
  800e97:	89 e5                	mov    %esp,%ebp
  800e99:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e9c:	68 e2 1e 80 00       	push   $0x801ee2
  800ea1:	ff 75 0c             	pushl  0xc(%ebp)
  800ea4:	e8 5a 08 00 00       	call   801703 <strcpy>
	return 0;
}
  800ea9:	b8 00 00 00 00       	mov    $0x0,%eax
  800eae:	c9                   	leave  
  800eaf:	c3                   	ret    

00800eb0 <devcons_write>:
{
  800eb0:	55                   	push   %ebp
  800eb1:	89 e5                	mov    %esp,%ebp
  800eb3:	57                   	push   %edi
  800eb4:	56                   	push   %esi
  800eb5:	53                   	push   %ebx
  800eb6:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800ebc:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800ec1:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800ec7:	eb 2f                	jmp    800ef8 <devcons_write+0x48>
		m = n - tot;
  800ec9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ecc:	29 f3                	sub    %esi,%ebx
  800ece:	83 fb 7f             	cmp    $0x7f,%ebx
  800ed1:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800ed6:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800ed9:	83 ec 04             	sub    $0x4,%esp
  800edc:	53                   	push   %ebx
  800edd:	89 f0                	mov    %esi,%eax
  800edf:	03 45 0c             	add    0xc(%ebp),%eax
  800ee2:	50                   	push   %eax
  800ee3:	57                   	push   %edi
  800ee4:	e8 a8 09 00 00       	call   801891 <memmove>
		sys_cputs(buf, m);
  800ee9:	83 c4 08             	add    $0x8,%esp
  800eec:	53                   	push   %ebx
  800eed:	57                   	push   %edi
  800eee:	e8 bb f1 ff ff       	call   8000ae <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800ef3:	01 de                	add    %ebx,%esi
  800ef5:	83 c4 10             	add    $0x10,%esp
  800ef8:	3b 75 10             	cmp    0x10(%ebp),%esi
  800efb:	72 cc                	jb     800ec9 <devcons_write+0x19>
}
  800efd:	89 f0                	mov    %esi,%eax
  800eff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f02:	5b                   	pop    %ebx
  800f03:	5e                   	pop    %esi
  800f04:	5f                   	pop    %edi
  800f05:	5d                   	pop    %ebp
  800f06:	c3                   	ret    

00800f07 <devcons_read>:
{
  800f07:	55                   	push   %ebp
  800f08:	89 e5                	mov    %esp,%ebp
  800f0a:	83 ec 08             	sub    $0x8,%esp
  800f0d:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800f12:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f16:	75 07                	jne    800f1f <devcons_read+0x18>
}
  800f18:	c9                   	leave  
  800f19:	c3                   	ret    
		sys_yield();
  800f1a:	e8 2c f2 ff ff       	call   80014b <sys_yield>
	while ((c = sys_cgetc()) == 0)
  800f1f:	e8 a8 f1 ff ff       	call   8000cc <sys_cgetc>
  800f24:	85 c0                	test   %eax,%eax
  800f26:	74 f2                	je     800f1a <devcons_read+0x13>
	if (c < 0)
  800f28:	85 c0                	test   %eax,%eax
  800f2a:	78 ec                	js     800f18 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  800f2c:	83 f8 04             	cmp    $0x4,%eax
  800f2f:	74 0c                	je     800f3d <devcons_read+0x36>
	*(char*)vbuf = c;
  800f31:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f34:	88 02                	mov    %al,(%edx)
	return 1;
  800f36:	b8 01 00 00 00       	mov    $0x1,%eax
  800f3b:	eb db                	jmp    800f18 <devcons_read+0x11>
		return 0;
  800f3d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f42:	eb d4                	jmp    800f18 <devcons_read+0x11>

00800f44 <cputchar>:
{
  800f44:	55                   	push   %ebp
  800f45:	89 e5                	mov    %esp,%ebp
  800f47:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f4d:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800f50:	6a 01                	push   $0x1
  800f52:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f55:	50                   	push   %eax
  800f56:	e8 53 f1 ff ff       	call   8000ae <sys_cputs>
}
  800f5b:	83 c4 10             	add    $0x10,%esp
  800f5e:	c9                   	leave  
  800f5f:	c3                   	ret    

00800f60 <getchar>:
{
  800f60:	55                   	push   %ebp
  800f61:	89 e5                	mov    %esp,%ebp
  800f63:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800f66:	6a 01                	push   $0x1
  800f68:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f6b:	50                   	push   %eax
  800f6c:	6a 00                	push   $0x0
  800f6e:	e8 cf f6 ff ff       	call   800642 <read>
	if (r < 0)
  800f73:	83 c4 10             	add    $0x10,%esp
  800f76:	85 c0                	test   %eax,%eax
  800f78:	78 08                	js     800f82 <getchar+0x22>
	if (r < 1)
  800f7a:	85 c0                	test   %eax,%eax
  800f7c:	7e 06                	jle    800f84 <getchar+0x24>
	return c;
  800f7e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800f82:	c9                   	leave  
  800f83:	c3                   	ret    
		return -E_EOF;
  800f84:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800f89:	eb f7                	jmp    800f82 <getchar+0x22>

00800f8b <iscons>:
{
  800f8b:	55                   	push   %ebp
  800f8c:	89 e5                	mov    %esp,%ebp
  800f8e:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f91:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f94:	50                   	push   %eax
  800f95:	ff 75 08             	pushl  0x8(%ebp)
  800f98:	e8 34 f4 ff ff       	call   8003d1 <fd_lookup>
  800f9d:	83 c4 10             	add    $0x10,%esp
  800fa0:	85 c0                	test   %eax,%eax
  800fa2:	78 11                	js     800fb5 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  800fa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fa7:	8b 15 40 30 80 00    	mov    0x803040,%edx
  800fad:	39 10                	cmp    %edx,(%eax)
  800faf:	0f 94 c0             	sete   %al
  800fb2:	0f b6 c0             	movzbl %al,%eax
}
  800fb5:	c9                   	leave  
  800fb6:	c3                   	ret    

00800fb7 <opencons>:
{
  800fb7:	55                   	push   %ebp
  800fb8:	89 e5                	mov    %esp,%ebp
  800fba:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800fbd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fc0:	50                   	push   %eax
  800fc1:	e8 bc f3 ff ff       	call   800382 <fd_alloc>
  800fc6:	83 c4 10             	add    $0x10,%esp
  800fc9:	85 c0                	test   %eax,%eax
  800fcb:	78 3a                	js     801007 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fcd:	83 ec 04             	sub    $0x4,%esp
  800fd0:	68 07 04 00 00       	push   $0x407
  800fd5:	ff 75 f4             	pushl  -0xc(%ebp)
  800fd8:	6a 00                	push   $0x0
  800fda:	e8 8b f1 ff ff       	call   80016a <sys_page_alloc>
  800fdf:	83 c4 10             	add    $0x10,%esp
  800fe2:	85 c0                	test   %eax,%eax
  800fe4:	78 21                	js     801007 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  800fe6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fe9:	8b 15 40 30 80 00    	mov    0x803040,%edx
  800fef:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800ff1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ff4:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800ffb:	83 ec 0c             	sub    $0xc,%esp
  800ffe:	50                   	push   %eax
  800fff:	e8 57 f3 ff ff       	call   80035b <fd2num>
  801004:	83 c4 10             	add    $0x10,%esp
}
  801007:	c9                   	leave  
  801008:	c3                   	ret    

00801009 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801009:	55                   	push   %ebp
  80100a:	89 e5                	mov    %esp,%ebp
  80100c:	56                   	push   %esi
  80100d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80100e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801011:	8b 35 04 30 80 00    	mov    0x803004,%esi
  801017:	e8 10 f1 ff ff       	call   80012c <sys_getenvid>
  80101c:	83 ec 0c             	sub    $0xc,%esp
  80101f:	ff 75 0c             	pushl  0xc(%ebp)
  801022:	ff 75 08             	pushl  0x8(%ebp)
  801025:	56                   	push   %esi
  801026:	50                   	push   %eax
  801027:	68 f0 1e 80 00       	push   $0x801ef0
  80102c:	e8 b3 00 00 00       	call   8010e4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801031:	83 c4 18             	add    $0x18,%esp
  801034:	53                   	push   %ebx
  801035:	ff 75 10             	pushl  0x10(%ebp)
  801038:	e8 56 00 00 00       	call   801093 <vcprintf>
	cprintf("\n");
  80103d:	c7 04 24 db 1e 80 00 	movl   $0x801edb,(%esp)
  801044:	e8 9b 00 00 00       	call   8010e4 <cprintf>
  801049:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80104c:	cc                   	int3   
  80104d:	eb fd                	jmp    80104c <_panic+0x43>

0080104f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80104f:	55                   	push   %ebp
  801050:	89 e5                	mov    %esp,%ebp
  801052:	53                   	push   %ebx
  801053:	83 ec 04             	sub    $0x4,%esp
  801056:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801059:	8b 13                	mov    (%ebx),%edx
  80105b:	8d 42 01             	lea    0x1(%edx),%eax
  80105e:	89 03                	mov    %eax,(%ebx)
  801060:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801063:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801067:	3d ff 00 00 00       	cmp    $0xff,%eax
  80106c:	74 09                	je     801077 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80106e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801072:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801075:	c9                   	leave  
  801076:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801077:	83 ec 08             	sub    $0x8,%esp
  80107a:	68 ff 00 00 00       	push   $0xff
  80107f:	8d 43 08             	lea    0x8(%ebx),%eax
  801082:	50                   	push   %eax
  801083:	e8 26 f0 ff ff       	call   8000ae <sys_cputs>
		b->idx = 0;
  801088:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80108e:	83 c4 10             	add    $0x10,%esp
  801091:	eb db                	jmp    80106e <putch+0x1f>

00801093 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801093:	55                   	push   %ebp
  801094:	89 e5                	mov    %esp,%ebp
  801096:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80109c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010a3:	00 00 00 
	b.cnt = 0;
  8010a6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010ad:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010b0:	ff 75 0c             	pushl  0xc(%ebp)
  8010b3:	ff 75 08             	pushl  0x8(%ebp)
  8010b6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010bc:	50                   	push   %eax
  8010bd:	68 4f 10 80 00       	push   $0x80104f
  8010c2:	e8 1a 01 00 00       	call   8011e1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010c7:	83 c4 08             	add    $0x8,%esp
  8010ca:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010d0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010d6:	50                   	push   %eax
  8010d7:	e8 d2 ef ff ff       	call   8000ae <sys_cputs>

	return b.cnt;
}
  8010dc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010e2:	c9                   	leave  
  8010e3:	c3                   	ret    

008010e4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010e4:	55                   	push   %ebp
  8010e5:	89 e5                	mov    %esp,%ebp
  8010e7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010ea:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010ed:	50                   	push   %eax
  8010ee:	ff 75 08             	pushl  0x8(%ebp)
  8010f1:	e8 9d ff ff ff       	call   801093 <vcprintf>
	va_end(ap);

	return cnt;
}
  8010f6:	c9                   	leave  
  8010f7:	c3                   	ret    

008010f8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010f8:	55                   	push   %ebp
  8010f9:	89 e5                	mov    %esp,%ebp
  8010fb:	57                   	push   %edi
  8010fc:	56                   	push   %esi
  8010fd:	53                   	push   %ebx
  8010fe:	83 ec 1c             	sub    $0x1c,%esp
  801101:	89 c7                	mov    %eax,%edi
  801103:	89 d6                	mov    %edx,%esi
  801105:	8b 45 08             	mov    0x8(%ebp),%eax
  801108:	8b 55 0c             	mov    0xc(%ebp),%edx
  80110b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80110e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801111:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801114:	bb 00 00 00 00       	mov    $0x0,%ebx
  801119:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80111c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80111f:	39 d3                	cmp    %edx,%ebx
  801121:	72 05                	jb     801128 <printnum+0x30>
  801123:	39 45 10             	cmp    %eax,0x10(%ebp)
  801126:	77 7a                	ja     8011a2 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801128:	83 ec 0c             	sub    $0xc,%esp
  80112b:	ff 75 18             	pushl  0x18(%ebp)
  80112e:	8b 45 14             	mov    0x14(%ebp),%eax
  801131:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801134:	53                   	push   %ebx
  801135:	ff 75 10             	pushl  0x10(%ebp)
  801138:	83 ec 08             	sub    $0x8,%esp
  80113b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80113e:	ff 75 e0             	pushl  -0x20(%ebp)
  801141:	ff 75 dc             	pushl  -0x24(%ebp)
  801144:	ff 75 d8             	pushl  -0x28(%ebp)
  801147:	e8 24 0a 00 00       	call   801b70 <__udivdi3>
  80114c:	83 c4 18             	add    $0x18,%esp
  80114f:	52                   	push   %edx
  801150:	50                   	push   %eax
  801151:	89 f2                	mov    %esi,%edx
  801153:	89 f8                	mov    %edi,%eax
  801155:	e8 9e ff ff ff       	call   8010f8 <printnum>
  80115a:	83 c4 20             	add    $0x20,%esp
  80115d:	eb 13                	jmp    801172 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80115f:	83 ec 08             	sub    $0x8,%esp
  801162:	56                   	push   %esi
  801163:	ff 75 18             	pushl  0x18(%ebp)
  801166:	ff d7                	call   *%edi
  801168:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80116b:	83 eb 01             	sub    $0x1,%ebx
  80116e:	85 db                	test   %ebx,%ebx
  801170:	7f ed                	jg     80115f <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801172:	83 ec 08             	sub    $0x8,%esp
  801175:	56                   	push   %esi
  801176:	83 ec 04             	sub    $0x4,%esp
  801179:	ff 75 e4             	pushl  -0x1c(%ebp)
  80117c:	ff 75 e0             	pushl  -0x20(%ebp)
  80117f:	ff 75 dc             	pushl  -0x24(%ebp)
  801182:	ff 75 d8             	pushl  -0x28(%ebp)
  801185:	e8 06 0b 00 00       	call   801c90 <__umoddi3>
  80118a:	83 c4 14             	add    $0x14,%esp
  80118d:	0f be 80 13 1f 80 00 	movsbl 0x801f13(%eax),%eax
  801194:	50                   	push   %eax
  801195:	ff d7                	call   *%edi
}
  801197:	83 c4 10             	add    $0x10,%esp
  80119a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80119d:	5b                   	pop    %ebx
  80119e:	5e                   	pop    %esi
  80119f:	5f                   	pop    %edi
  8011a0:	5d                   	pop    %ebp
  8011a1:	c3                   	ret    
  8011a2:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8011a5:	eb c4                	jmp    80116b <printnum+0x73>

008011a7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011a7:	55                   	push   %ebp
  8011a8:	89 e5                	mov    %esp,%ebp
  8011aa:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011ad:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011b1:	8b 10                	mov    (%eax),%edx
  8011b3:	3b 50 04             	cmp    0x4(%eax),%edx
  8011b6:	73 0a                	jae    8011c2 <sprintputch+0x1b>
		*b->buf++ = ch;
  8011b8:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011bb:	89 08                	mov    %ecx,(%eax)
  8011bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c0:	88 02                	mov    %al,(%edx)
}
  8011c2:	5d                   	pop    %ebp
  8011c3:	c3                   	ret    

008011c4 <printfmt>:
{
  8011c4:	55                   	push   %ebp
  8011c5:	89 e5                	mov    %esp,%ebp
  8011c7:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8011ca:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011cd:	50                   	push   %eax
  8011ce:	ff 75 10             	pushl  0x10(%ebp)
  8011d1:	ff 75 0c             	pushl  0xc(%ebp)
  8011d4:	ff 75 08             	pushl  0x8(%ebp)
  8011d7:	e8 05 00 00 00       	call   8011e1 <vprintfmt>
}
  8011dc:	83 c4 10             	add    $0x10,%esp
  8011df:	c9                   	leave  
  8011e0:	c3                   	ret    

008011e1 <vprintfmt>:
{
  8011e1:	55                   	push   %ebp
  8011e2:	89 e5                	mov    %esp,%ebp
  8011e4:	57                   	push   %edi
  8011e5:	56                   	push   %esi
  8011e6:	53                   	push   %ebx
  8011e7:	83 ec 2c             	sub    $0x2c,%esp
  8011ea:	8b 75 08             	mov    0x8(%ebp),%esi
  8011ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8011f0:	8b 7d 10             	mov    0x10(%ebp),%edi
  8011f3:	e9 c1 03 00 00       	jmp    8015b9 <vprintfmt+0x3d8>
		padc = ' ';
  8011f8:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8011fc:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  801203:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  80120a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  801211:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801216:	8d 47 01             	lea    0x1(%edi),%eax
  801219:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80121c:	0f b6 17             	movzbl (%edi),%edx
  80121f:	8d 42 dd             	lea    -0x23(%edx),%eax
  801222:	3c 55                	cmp    $0x55,%al
  801224:	0f 87 12 04 00 00    	ja     80163c <vprintfmt+0x45b>
  80122a:	0f b6 c0             	movzbl %al,%eax
  80122d:	ff 24 85 60 20 80 00 	jmp    *0x802060(,%eax,4)
  801234:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801237:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80123b:	eb d9                	jmp    801216 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80123d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  801240:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801244:	eb d0                	jmp    801216 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  801246:	0f b6 d2             	movzbl %dl,%edx
  801249:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80124c:	b8 00 00 00 00       	mov    $0x0,%eax
  801251:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801254:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801257:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80125b:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80125e:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801261:	83 f9 09             	cmp    $0x9,%ecx
  801264:	77 55                	ja     8012bb <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  801266:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801269:	eb e9                	jmp    801254 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  80126b:	8b 45 14             	mov    0x14(%ebp),%eax
  80126e:	8b 00                	mov    (%eax),%eax
  801270:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801273:	8b 45 14             	mov    0x14(%ebp),%eax
  801276:	8d 40 04             	lea    0x4(%eax),%eax
  801279:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80127c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80127f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801283:	79 91                	jns    801216 <vprintfmt+0x35>
				width = precision, precision = -1;
  801285:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801288:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80128b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801292:	eb 82                	jmp    801216 <vprintfmt+0x35>
  801294:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801297:	85 c0                	test   %eax,%eax
  801299:	ba 00 00 00 00       	mov    $0x0,%edx
  80129e:	0f 49 d0             	cmovns %eax,%edx
  8012a1:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8012a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012a7:	e9 6a ff ff ff       	jmp    801216 <vprintfmt+0x35>
  8012ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8012af:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012b6:	e9 5b ff ff ff       	jmp    801216 <vprintfmt+0x35>
  8012bb:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8012be:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012c1:	eb bc                	jmp    80127f <vprintfmt+0x9e>
			lflag++;
  8012c3:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8012c9:	e9 48 ff ff ff       	jmp    801216 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8012ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8012d1:	8d 78 04             	lea    0x4(%eax),%edi
  8012d4:	83 ec 08             	sub    $0x8,%esp
  8012d7:	53                   	push   %ebx
  8012d8:	ff 30                	pushl  (%eax)
  8012da:	ff d6                	call   *%esi
			break;
  8012dc:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8012df:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8012e2:	e9 cf 02 00 00       	jmp    8015b6 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8012e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8012ea:	8d 78 04             	lea    0x4(%eax),%edi
  8012ed:	8b 00                	mov    (%eax),%eax
  8012ef:	99                   	cltd   
  8012f0:	31 d0                	xor    %edx,%eax
  8012f2:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8012f4:	83 f8 0f             	cmp    $0xf,%eax
  8012f7:	7f 23                	jg     80131c <vprintfmt+0x13b>
  8012f9:	8b 14 85 c0 21 80 00 	mov    0x8021c0(,%eax,4),%edx
  801300:	85 d2                	test   %edx,%edx
  801302:	74 18                	je     80131c <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  801304:	52                   	push   %edx
  801305:	68 a9 1e 80 00       	push   $0x801ea9
  80130a:	53                   	push   %ebx
  80130b:	56                   	push   %esi
  80130c:	e8 b3 fe ff ff       	call   8011c4 <printfmt>
  801311:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801314:	89 7d 14             	mov    %edi,0x14(%ebp)
  801317:	e9 9a 02 00 00       	jmp    8015b6 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  80131c:	50                   	push   %eax
  80131d:	68 2b 1f 80 00       	push   $0x801f2b
  801322:	53                   	push   %ebx
  801323:	56                   	push   %esi
  801324:	e8 9b fe ff ff       	call   8011c4 <printfmt>
  801329:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80132c:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80132f:	e9 82 02 00 00       	jmp    8015b6 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  801334:	8b 45 14             	mov    0x14(%ebp),%eax
  801337:	83 c0 04             	add    $0x4,%eax
  80133a:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80133d:	8b 45 14             	mov    0x14(%ebp),%eax
  801340:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801342:	85 ff                	test   %edi,%edi
  801344:	b8 24 1f 80 00       	mov    $0x801f24,%eax
  801349:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80134c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801350:	0f 8e bd 00 00 00    	jle    801413 <vprintfmt+0x232>
  801356:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80135a:	75 0e                	jne    80136a <vprintfmt+0x189>
  80135c:	89 75 08             	mov    %esi,0x8(%ebp)
  80135f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801362:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801365:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801368:	eb 6d                	jmp    8013d7 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  80136a:	83 ec 08             	sub    $0x8,%esp
  80136d:	ff 75 d0             	pushl  -0x30(%ebp)
  801370:	57                   	push   %edi
  801371:	e8 6e 03 00 00       	call   8016e4 <strnlen>
  801376:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801379:	29 c1                	sub    %eax,%ecx
  80137b:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80137e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801381:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801385:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801388:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80138b:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  80138d:	eb 0f                	jmp    80139e <vprintfmt+0x1bd>
					putch(padc, putdat);
  80138f:	83 ec 08             	sub    $0x8,%esp
  801392:	53                   	push   %ebx
  801393:	ff 75 e0             	pushl  -0x20(%ebp)
  801396:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  801398:	83 ef 01             	sub    $0x1,%edi
  80139b:	83 c4 10             	add    $0x10,%esp
  80139e:	85 ff                	test   %edi,%edi
  8013a0:	7f ed                	jg     80138f <vprintfmt+0x1ae>
  8013a2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8013a5:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8013a8:	85 c9                	test   %ecx,%ecx
  8013aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8013af:	0f 49 c1             	cmovns %ecx,%eax
  8013b2:	29 c1                	sub    %eax,%ecx
  8013b4:	89 75 08             	mov    %esi,0x8(%ebp)
  8013b7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8013ba:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8013bd:	89 cb                	mov    %ecx,%ebx
  8013bf:	eb 16                	jmp    8013d7 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8013c1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8013c5:	75 31                	jne    8013f8 <vprintfmt+0x217>
					putch(ch, putdat);
  8013c7:	83 ec 08             	sub    $0x8,%esp
  8013ca:	ff 75 0c             	pushl  0xc(%ebp)
  8013cd:	50                   	push   %eax
  8013ce:	ff 55 08             	call   *0x8(%ebp)
  8013d1:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8013d4:	83 eb 01             	sub    $0x1,%ebx
  8013d7:	83 c7 01             	add    $0x1,%edi
  8013da:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8013de:	0f be c2             	movsbl %dl,%eax
  8013e1:	85 c0                	test   %eax,%eax
  8013e3:	74 59                	je     80143e <vprintfmt+0x25d>
  8013e5:	85 f6                	test   %esi,%esi
  8013e7:	78 d8                	js     8013c1 <vprintfmt+0x1e0>
  8013e9:	83 ee 01             	sub    $0x1,%esi
  8013ec:	79 d3                	jns    8013c1 <vprintfmt+0x1e0>
  8013ee:	89 df                	mov    %ebx,%edi
  8013f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8013f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8013f6:	eb 37                	jmp    80142f <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8013f8:	0f be d2             	movsbl %dl,%edx
  8013fb:	83 ea 20             	sub    $0x20,%edx
  8013fe:	83 fa 5e             	cmp    $0x5e,%edx
  801401:	76 c4                	jbe    8013c7 <vprintfmt+0x1e6>
					putch('?', putdat);
  801403:	83 ec 08             	sub    $0x8,%esp
  801406:	ff 75 0c             	pushl  0xc(%ebp)
  801409:	6a 3f                	push   $0x3f
  80140b:	ff 55 08             	call   *0x8(%ebp)
  80140e:	83 c4 10             	add    $0x10,%esp
  801411:	eb c1                	jmp    8013d4 <vprintfmt+0x1f3>
  801413:	89 75 08             	mov    %esi,0x8(%ebp)
  801416:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801419:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80141c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80141f:	eb b6                	jmp    8013d7 <vprintfmt+0x1f6>
				putch(' ', putdat);
  801421:	83 ec 08             	sub    $0x8,%esp
  801424:	53                   	push   %ebx
  801425:	6a 20                	push   $0x20
  801427:	ff d6                	call   *%esi
			for (; width > 0; width--)
  801429:	83 ef 01             	sub    $0x1,%edi
  80142c:	83 c4 10             	add    $0x10,%esp
  80142f:	85 ff                	test   %edi,%edi
  801431:	7f ee                	jg     801421 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  801433:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801436:	89 45 14             	mov    %eax,0x14(%ebp)
  801439:	e9 78 01 00 00       	jmp    8015b6 <vprintfmt+0x3d5>
  80143e:	89 df                	mov    %ebx,%edi
  801440:	8b 75 08             	mov    0x8(%ebp),%esi
  801443:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801446:	eb e7                	jmp    80142f <vprintfmt+0x24e>
	if (lflag >= 2)
  801448:	83 f9 01             	cmp    $0x1,%ecx
  80144b:	7e 3f                	jle    80148c <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  80144d:	8b 45 14             	mov    0x14(%ebp),%eax
  801450:	8b 50 04             	mov    0x4(%eax),%edx
  801453:	8b 00                	mov    (%eax),%eax
  801455:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801458:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80145b:	8b 45 14             	mov    0x14(%ebp),%eax
  80145e:	8d 40 08             	lea    0x8(%eax),%eax
  801461:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  801464:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801468:	79 5c                	jns    8014c6 <vprintfmt+0x2e5>
				putch('-', putdat);
  80146a:	83 ec 08             	sub    $0x8,%esp
  80146d:	53                   	push   %ebx
  80146e:	6a 2d                	push   $0x2d
  801470:	ff d6                	call   *%esi
				num = -(long long) num;
  801472:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801475:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801478:	f7 da                	neg    %edx
  80147a:	83 d1 00             	adc    $0x0,%ecx
  80147d:	f7 d9                	neg    %ecx
  80147f:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801482:	b8 0a 00 00 00       	mov    $0xa,%eax
  801487:	e9 10 01 00 00       	jmp    80159c <vprintfmt+0x3bb>
	else if (lflag)
  80148c:	85 c9                	test   %ecx,%ecx
  80148e:	75 1b                	jne    8014ab <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  801490:	8b 45 14             	mov    0x14(%ebp),%eax
  801493:	8b 00                	mov    (%eax),%eax
  801495:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801498:	89 c1                	mov    %eax,%ecx
  80149a:	c1 f9 1f             	sar    $0x1f,%ecx
  80149d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8014a3:	8d 40 04             	lea    0x4(%eax),%eax
  8014a6:	89 45 14             	mov    %eax,0x14(%ebp)
  8014a9:	eb b9                	jmp    801464 <vprintfmt+0x283>
		return va_arg(*ap, long);
  8014ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ae:	8b 00                	mov    (%eax),%eax
  8014b0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014b3:	89 c1                	mov    %eax,%ecx
  8014b5:	c1 f9 1f             	sar    $0x1f,%ecx
  8014b8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8014be:	8d 40 04             	lea    0x4(%eax),%eax
  8014c1:	89 45 14             	mov    %eax,0x14(%ebp)
  8014c4:	eb 9e                	jmp    801464 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8014c6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014c9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8014cc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014d1:	e9 c6 00 00 00       	jmp    80159c <vprintfmt+0x3bb>
	if (lflag >= 2)
  8014d6:	83 f9 01             	cmp    $0x1,%ecx
  8014d9:	7e 18                	jle    8014f3 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8014db:	8b 45 14             	mov    0x14(%ebp),%eax
  8014de:	8b 10                	mov    (%eax),%edx
  8014e0:	8b 48 04             	mov    0x4(%eax),%ecx
  8014e3:	8d 40 08             	lea    0x8(%eax),%eax
  8014e6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8014e9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014ee:	e9 a9 00 00 00       	jmp    80159c <vprintfmt+0x3bb>
	else if (lflag)
  8014f3:	85 c9                	test   %ecx,%ecx
  8014f5:	75 1a                	jne    801511 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  8014f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8014fa:	8b 10                	mov    (%eax),%edx
  8014fc:	b9 00 00 00 00       	mov    $0x0,%ecx
  801501:	8d 40 04             	lea    0x4(%eax),%eax
  801504:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801507:	b8 0a 00 00 00       	mov    $0xa,%eax
  80150c:	e9 8b 00 00 00       	jmp    80159c <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  801511:	8b 45 14             	mov    0x14(%ebp),%eax
  801514:	8b 10                	mov    (%eax),%edx
  801516:	b9 00 00 00 00       	mov    $0x0,%ecx
  80151b:	8d 40 04             	lea    0x4(%eax),%eax
  80151e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801521:	b8 0a 00 00 00       	mov    $0xa,%eax
  801526:	eb 74                	jmp    80159c <vprintfmt+0x3bb>
	if (lflag >= 2)
  801528:	83 f9 01             	cmp    $0x1,%ecx
  80152b:	7e 15                	jle    801542 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  80152d:	8b 45 14             	mov    0x14(%ebp),%eax
  801530:	8b 10                	mov    (%eax),%edx
  801532:	8b 48 04             	mov    0x4(%eax),%ecx
  801535:	8d 40 08             	lea    0x8(%eax),%eax
  801538:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80153b:	b8 08 00 00 00       	mov    $0x8,%eax
  801540:	eb 5a                	jmp    80159c <vprintfmt+0x3bb>
	else if (lflag)
  801542:	85 c9                	test   %ecx,%ecx
  801544:	75 17                	jne    80155d <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  801546:	8b 45 14             	mov    0x14(%ebp),%eax
  801549:	8b 10                	mov    (%eax),%edx
  80154b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801550:	8d 40 04             	lea    0x4(%eax),%eax
  801553:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801556:	b8 08 00 00 00       	mov    $0x8,%eax
  80155b:	eb 3f                	jmp    80159c <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80155d:	8b 45 14             	mov    0x14(%ebp),%eax
  801560:	8b 10                	mov    (%eax),%edx
  801562:	b9 00 00 00 00       	mov    $0x0,%ecx
  801567:	8d 40 04             	lea    0x4(%eax),%eax
  80156a:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80156d:	b8 08 00 00 00       	mov    $0x8,%eax
  801572:	eb 28                	jmp    80159c <vprintfmt+0x3bb>
			putch('0', putdat);
  801574:	83 ec 08             	sub    $0x8,%esp
  801577:	53                   	push   %ebx
  801578:	6a 30                	push   $0x30
  80157a:	ff d6                	call   *%esi
			putch('x', putdat);
  80157c:	83 c4 08             	add    $0x8,%esp
  80157f:	53                   	push   %ebx
  801580:	6a 78                	push   $0x78
  801582:	ff d6                	call   *%esi
			num = (unsigned long long)
  801584:	8b 45 14             	mov    0x14(%ebp),%eax
  801587:	8b 10                	mov    (%eax),%edx
  801589:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80158e:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801591:	8d 40 04             	lea    0x4(%eax),%eax
  801594:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801597:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80159c:	83 ec 0c             	sub    $0xc,%esp
  80159f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015a3:	57                   	push   %edi
  8015a4:	ff 75 e0             	pushl  -0x20(%ebp)
  8015a7:	50                   	push   %eax
  8015a8:	51                   	push   %ecx
  8015a9:	52                   	push   %edx
  8015aa:	89 da                	mov    %ebx,%edx
  8015ac:	89 f0                	mov    %esi,%eax
  8015ae:	e8 45 fb ff ff       	call   8010f8 <printnum>
			break;
  8015b3:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8015b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8015b9:	83 c7 01             	add    $0x1,%edi
  8015bc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8015c0:	83 f8 25             	cmp    $0x25,%eax
  8015c3:	0f 84 2f fc ff ff    	je     8011f8 <vprintfmt+0x17>
			if (ch == '\0')
  8015c9:	85 c0                	test   %eax,%eax
  8015cb:	0f 84 8b 00 00 00    	je     80165c <vprintfmt+0x47b>
			putch(ch, putdat);
  8015d1:	83 ec 08             	sub    $0x8,%esp
  8015d4:	53                   	push   %ebx
  8015d5:	50                   	push   %eax
  8015d6:	ff d6                	call   *%esi
  8015d8:	83 c4 10             	add    $0x10,%esp
  8015db:	eb dc                	jmp    8015b9 <vprintfmt+0x3d8>
	if (lflag >= 2)
  8015dd:	83 f9 01             	cmp    $0x1,%ecx
  8015e0:	7e 15                	jle    8015f7 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  8015e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8015e5:	8b 10                	mov    (%eax),%edx
  8015e7:	8b 48 04             	mov    0x4(%eax),%ecx
  8015ea:	8d 40 08             	lea    0x8(%eax),%eax
  8015ed:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015f0:	b8 10 00 00 00       	mov    $0x10,%eax
  8015f5:	eb a5                	jmp    80159c <vprintfmt+0x3bb>
	else if (lflag)
  8015f7:	85 c9                	test   %ecx,%ecx
  8015f9:	75 17                	jne    801612 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  8015fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8015fe:	8b 10                	mov    (%eax),%edx
  801600:	b9 00 00 00 00       	mov    $0x0,%ecx
  801605:	8d 40 04             	lea    0x4(%eax),%eax
  801608:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80160b:	b8 10 00 00 00       	mov    $0x10,%eax
  801610:	eb 8a                	jmp    80159c <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  801612:	8b 45 14             	mov    0x14(%ebp),%eax
  801615:	8b 10                	mov    (%eax),%edx
  801617:	b9 00 00 00 00       	mov    $0x0,%ecx
  80161c:	8d 40 04             	lea    0x4(%eax),%eax
  80161f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801622:	b8 10 00 00 00       	mov    $0x10,%eax
  801627:	e9 70 ff ff ff       	jmp    80159c <vprintfmt+0x3bb>
			putch(ch, putdat);
  80162c:	83 ec 08             	sub    $0x8,%esp
  80162f:	53                   	push   %ebx
  801630:	6a 25                	push   $0x25
  801632:	ff d6                	call   *%esi
			break;
  801634:	83 c4 10             	add    $0x10,%esp
  801637:	e9 7a ff ff ff       	jmp    8015b6 <vprintfmt+0x3d5>
			putch('%', putdat);
  80163c:	83 ec 08             	sub    $0x8,%esp
  80163f:	53                   	push   %ebx
  801640:	6a 25                	push   $0x25
  801642:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801644:	83 c4 10             	add    $0x10,%esp
  801647:	89 f8                	mov    %edi,%eax
  801649:	eb 03                	jmp    80164e <vprintfmt+0x46d>
  80164b:	83 e8 01             	sub    $0x1,%eax
  80164e:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801652:	75 f7                	jne    80164b <vprintfmt+0x46a>
  801654:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801657:	e9 5a ff ff ff       	jmp    8015b6 <vprintfmt+0x3d5>
}
  80165c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80165f:	5b                   	pop    %ebx
  801660:	5e                   	pop    %esi
  801661:	5f                   	pop    %edi
  801662:	5d                   	pop    %ebp
  801663:	c3                   	ret    

00801664 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801664:	55                   	push   %ebp
  801665:	89 e5                	mov    %esp,%ebp
  801667:	83 ec 18             	sub    $0x18,%esp
  80166a:	8b 45 08             	mov    0x8(%ebp),%eax
  80166d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801670:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801673:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801677:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80167a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801681:	85 c0                	test   %eax,%eax
  801683:	74 26                	je     8016ab <vsnprintf+0x47>
  801685:	85 d2                	test   %edx,%edx
  801687:	7e 22                	jle    8016ab <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801689:	ff 75 14             	pushl  0x14(%ebp)
  80168c:	ff 75 10             	pushl  0x10(%ebp)
  80168f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801692:	50                   	push   %eax
  801693:	68 a7 11 80 00       	push   $0x8011a7
  801698:	e8 44 fb ff ff       	call   8011e1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80169d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016a0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8016a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016a6:	83 c4 10             	add    $0x10,%esp
}
  8016a9:	c9                   	leave  
  8016aa:	c3                   	ret    
		return -E_INVAL;
  8016ab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016b0:	eb f7                	jmp    8016a9 <vsnprintf+0x45>

008016b2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016b2:	55                   	push   %ebp
  8016b3:	89 e5                	mov    %esp,%ebp
  8016b5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016b8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016bb:	50                   	push   %eax
  8016bc:	ff 75 10             	pushl  0x10(%ebp)
  8016bf:	ff 75 0c             	pushl  0xc(%ebp)
  8016c2:	ff 75 08             	pushl  0x8(%ebp)
  8016c5:	e8 9a ff ff ff       	call   801664 <vsnprintf>
	va_end(ap);

	return rc;
}
  8016ca:	c9                   	leave  
  8016cb:	c3                   	ret    

008016cc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016cc:	55                   	push   %ebp
  8016cd:	89 e5                	mov    %esp,%ebp
  8016cf:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8016d7:	eb 03                	jmp    8016dc <strlen+0x10>
		n++;
  8016d9:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8016dc:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016e0:	75 f7                	jne    8016d9 <strlen+0xd>
	return n;
}
  8016e2:	5d                   	pop    %ebp
  8016e3:	c3                   	ret    

008016e4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016e4:	55                   	push   %ebp
  8016e5:	89 e5                	mov    %esp,%ebp
  8016e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016ea:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8016f2:	eb 03                	jmp    8016f7 <strnlen+0x13>
		n++;
  8016f4:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016f7:	39 d0                	cmp    %edx,%eax
  8016f9:	74 06                	je     801701 <strnlen+0x1d>
  8016fb:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8016ff:	75 f3                	jne    8016f4 <strnlen+0x10>
	return n;
}
  801701:	5d                   	pop    %ebp
  801702:	c3                   	ret    

00801703 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801703:	55                   	push   %ebp
  801704:	89 e5                	mov    %esp,%ebp
  801706:	53                   	push   %ebx
  801707:	8b 45 08             	mov    0x8(%ebp),%eax
  80170a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80170d:	89 c2                	mov    %eax,%edx
  80170f:	83 c1 01             	add    $0x1,%ecx
  801712:	83 c2 01             	add    $0x1,%edx
  801715:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801719:	88 5a ff             	mov    %bl,-0x1(%edx)
  80171c:	84 db                	test   %bl,%bl
  80171e:	75 ef                	jne    80170f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801720:	5b                   	pop    %ebx
  801721:	5d                   	pop    %ebp
  801722:	c3                   	ret    

00801723 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801723:	55                   	push   %ebp
  801724:	89 e5                	mov    %esp,%ebp
  801726:	53                   	push   %ebx
  801727:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80172a:	53                   	push   %ebx
  80172b:	e8 9c ff ff ff       	call   8016cc <strlen>
  801730:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801733:	ff 75 0c             	pushl  0xc(%ebp)
  801736:	01 d8                	add    %ebx,%eax
  801738:	50                   	push   %eax
  801739:	e8 c5 ff ff ff       	call   801703 <strcpy>
	return dst;
}
  80173e:	89 d8                	mov    %ebx,%eax
  801740:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801743:	c9                   	leave  
  801744:	c3                   	ret    

00801745 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801745:	55                   	push   %ebp
  801746:	89 e5                	mov    %esp,%ebp
  801748:	56                   	push   %esi
  801749:	53                   	push   %ebx
  80174a:	8b 75 08             	mov    0x8(%ebp),%esi
  80174d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801750:	89 f3                	mov    %esi,%ebx
  801752:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801755:	89 f2                	mov    %esi,%edx
  801757:	eb 0f                	jmp    801768 <strncpy+0x23>
		*dst++ = *src;
  801759:	83 c2 01             	add    $0x1,%edx
  80175c:	0f b6 01             	movzbl (%ecx),%eax
  80175f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801762:	80 39 01             	cmpb   $0x1,(%ecx)
  801765:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  801768:	39 da                	cmp    %ebx,%edx
  80176a:	75 ed                	jne    801759 <strncpy+0x14>
	}
	return ret;
}
  80176c:	89 f0                	mov    %esi,%eax
  80176e:	5b                   	pop    %ebx
  80176f:	5e                   	pop    %esi
  801770:	5d                   	pop    %ebp
  801771:	c3                   	ret    

00801772 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801772:	55                   	push   %ebp
  801773:	89 e5                	mov    %esp,%ebp
  801775:	56                   	push   %esi
  801776:	53                   	push   %ebx
  801777:	8b 75 08             	mov    0x8(%ebp),%esi
  80177a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80177d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801780:	89 f0                	mov    %esi,%eax
  801782:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801786:	85 c9                	test   %ecx,%ecx
  801788:	75 0b                	jne    801795 <strlcpy+0x23>
  80178a:	eb 17                	jmp    8017a3 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80178c:	83 c2 01             	add    $0x1,%edx
  80178f:	83 c0 01             	add    $0x1,%eax
  801792:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  801795:	39 d8                	cmp    %ebx,%eax
  801797:	74 07                	je     8017a0 <strlcpy+0x2e>
  801799:	0f b6 0a             	movzbl (%edx),%ecx
  80179c:	84 c9                	test   %cl,%cl
  80179e:	75 ec                	jne    80178c <strlcpy+0x1a>
		*dst = '\0';
  8017a0:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8017a3:	29 f0                	sub    %esi,%eax
}
  8017a5:	5b                   	pop    %ebx
  8017a6:	5e                   	pop    %esi
  8017a7:	5d                   	pop    %ebp
  8017a8:	c3                   	ret    

008017a9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017a9:	55                   	push   %ebp
  8017aa:	89 e5                	mov    %esp,%ebp
  8017ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017af:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017b2:	eb 06                	jmp    8017ba <strcmp+0x11>
		p++, q++;
  8017b4:	83 c1 01             	add    $0x1,%ecx
  8017b7:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8017ba:	0f b6 01             	movzbl (%ecx),%eax
  8017bd:	84 c0                	test   %al,%al
  8017bf:	74 04                	je     8017c5 <strcmp+0x1c>
  8017c1:	3a 02                	cmp    (%edx),%al
  8017c3:	74 ef                	je     8017b4 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017c5:	0f b6 c0             	movzbl %al,%eax
  8017c8:	0f b6 12             	movzbl (%edx),%edx
  8017cb:	29 d0                	sub    %edx,%eax
}
  8017cd:	5d                   	pop    %ebp
  8017ce:	c3                   	ret    

008017cf <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017cf:	55                   	push   %ebp
  8017d0:	89 e5                	mov    %esp,%ebp
  8017d2:	53                   	push   %ebx
  8017d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017d9:	89 c3                	mov    %eax,%ebx
  8017db:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017de:	eb 06                	jmp    8017e6 <strncmp+0x17>
		n--, p++, q++;
  8017e0:	83 c0 01             	add    $0x1,%eax
  8017e3:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8017e6:	39 d8                	cmp    %ebx,%eax
  8017e8:	74 16                	je     801800 <strncmp+0x31>
  8017ea:	0f b6 08             	movzbl (%eax),%ecx
  8017ed:	84 c9                	test   %cl,%cl
  8017ef:	74 04                	je     8017f5 <strncmp+0x26>
  8017f1:	3a 0a                	cmp    (%edx),%cl
  8017f3:	74 eb                	je     8017e0 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017f5:	0f b6 00             	movzbl (%eax),%eax
  8017f8:	0f b6 12             	movzbl (%edx),%edx
  8017fb:	29 d0                	sub    %edx,%eax
}
  8017fd:	5b                   	pop    %ebx
  8017fe:	5d                   	pop    %ebp
  8017ff:	c3                   	ret    
		return 0;
  801800:	b8 00 00 00 00       	mov    $0x0,%eax
  801805:	eb f6                	jmp    8017fd <strncmp+0x2e>

00801807 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801807:	55                   	push   %ebp
  801808:	89 e5                	mov    %esp,%ebp
  80180a:	8b 45 08             	mov    0x8(%ebp),%eax
  80180d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801811:	0f b6 10             	movzbl (%eax),%edx
  801814:	84 d2                	test   %dl,%dl
  801816:	74 09                	je     801821 <strchr+0x1a>
		if (*s == c)
  801818:	38 ca                	cmp    %cl,%dl
  80181a:	74 0a                	je     801826 <strchr+0x1f>
	for (; *s; s++)
  80181c:	83 c0 01             	add    $0x1,%eax
  80181f:	eb f0                	jmp    801811 <strchr+0xa>
			return (char *) s;
	return 0;
  801821:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801826:	5d                   	pop    %ebp
  801827:	c3                   	ret    

00801828 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801828:	55                   	push   %ebp
  801829:	89 e5                	mov    %esp,%ebp
  80182b:	8b 45 08             	mov    0x8(%ebp),%eax
  80182e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801832:	eb 03                	jmp    801837 <strfind+0xf>
  801834:	83 c0 01             	add    $0x1,%eax
  801837:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80183a:	38 ca                	cmp    %cl,%dl
  80183c:	74 04                	je     801842 <strfind+0x1a>
  80183e:	84 d2                	test   %dl,%dl
  801840:	75 f2                	jne    801834 <strfind+0xc>
			break;
	return (char *) s;
}
  801842:	5d                   	pop    %ebp
  801843:	c3                   	ret    

00801844 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801844:	55                   	push   %ebp
  801845:	89 e5                	mov    %esp,%ebp
  801847:	57                   	push   %edi
  801848:	56                   	push   %esi
  801849:	53                   	push   %ebx
  80184a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80184d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801850:	85 c9                	test   %ecx,%ecx
  801852:	74 13                	je     801867 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801854:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80185a:	75 05                	jne    801861 <memset+0x1d>
  80185c:	f6 c1 03             	test   $0x3,%cl
  80185f:	74 0d                	je     80186e <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801861:	8b 45 0c             	mov    0xc(%ebp),%eax
  801864:	fc                   	cld    
  801865:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801867:	89 f8                	mov    %edi,%eax
  801869:	5b                   	pop    %ebx
  80186a:	5e                   	pop    %esi
  80186b:	5f                   	pop    %edi
  80186c:	5d                   	pop    %ebp
  80186d:	c3                   	ret    
		c &= 0xFF;
  80186e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801872:	89 d3                	mov    %edx,%ebx
  801874:	c1 e3 08             	shl    $0x8,%ebx
  801877:	89 d0                	mov    %edx,%eax
  801879:	c1 e0 18             	shl    $0x18,%eax
  80187c:	89 d6                	mov    %edx,%esi
  80187e:	c1 e6 10             	shl    $0x10,%esi
  801881:	09 f0                	or     %esi,%eax
  801883:	09 c2                	or     %eax,%edx
  801885:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  801887:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80188a:	89 d0                	mov    %edx,%eax
  80188c:	fc                   	cld    
  80188d:	f3 ab                	rep stos %eax,%es:(%edi)
  80188f:	eb d6                	jmp    801867 <memset+0x23>

00801891 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801891:	55                   	push   %ebp
  801892:	89 e5                	mov    %esp,%ebp
  801894:	57                   	push   %edi
  801895:	56                   	push   %esi
  801896:	8b 45 08             	mov    0x8(%ebp),%eax
  801899:	8b 75 0c             	mov    0xc(%ebp),%esi
  80189c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80189f:	39 c6                	cmp    %eax,%esi
  8018a1:	73 35                	jae    8018d8 <memmove+0x47>
  8018a3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018a6:	39 c2                	cmp    %eax,%edx
  8018a8:	76 2e                	jbe    8018d8 <memmove+0x47>
		s += n;
		d += n;
  8018aa:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018ad:	89 d6                	mov    %edx,%esi
  8018af:	09 fe                	or     %edi,%esi
  8018b1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018b7:	74 0c                	je     8018c5 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8018b9:	83 ef 01             	sub    $0x1,%edi
  8018bc:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8018bf:	fd                   	std    
  8018c0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018c2:	fc                   	cld    
  8018c3:	eb 21                	jmp    8018e6 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018c5:	f6 c1 03             	test   $0x3,%cl
  8018c8:	75 ef                	jne    8018b9 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8018ca:	83 ef 04             	sub    $0x4,%edi
  8018cd:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018d0:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8018d3:	fd                   	std    
  8018d4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018d6:	eb ea                	jmp    8018c2 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018d8:	89 f2                	mov    %esi,%edx
  8018da:	09 c2                	or     %eax,%edx
  8018dc:	f6 c2 03             	test   $0x3,%dl
  8018df:	74 09                	je     8018ea <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018e1:	89 c7                	mov    %eax,%edi
  8018e3:	fc                   	cld    
  8018e4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018e6:	5e                   	pop    %esi
  8018e7:	5f                   	pop    %edi
  8018e8:	5d                   	pop    %ebp
  8018e9:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018ea:	f6 c1 03             	test   $0x3,%cl
  8018ed:	75 f2                	jne    8018e1 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8018ef:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8018f2:	89 c7                	mov    %eax,%edi
  8018f4:	fc                   	cld    
  8018f5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018f7:	eb ed                	jmp    8018e6 <memmove+0x55>

008018f9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018f9:	55                   	push   %ebp
  8018fa:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018fc:	ff 75 10             	pushl  0x10(%ebp)
  8018ff:	ff 75 0c             	pushl  0xc(%ebp)
  801902:	ff 75 08             	pushl  0x8(%ebp)
  801905:	e8 87 ff ff ff       	call   801891 <memmove>
}
  80190a:	c9                   	leave  
  80190b:	c3                   	ret    

0080190c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80190c:	55                   	push   %ebp
  80190d:	89 e5                	mov    %esp,%ebp
  80190f:	56                   	push   %esi
  801910:	53                   	push   %ebx
  801911:	8b 45 08             	mov    0x8(%ebp),%eax
  801914:	8b 55 0c             	mov    0xc(%ebp),%edx
  801917:	89 c6                	mov    %eax,%esi
  801919:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80191c:	39 f0                	cmp    %esi,%eax
  80191e:	74 1c                	je     80193c <memcmp+0x30>
		if (*s1 != *s2)
  801920:	0f b6 08             	movzbl (%eax),%ecx
  801923:	0f b6 1a             	movzbl (%edx),%ebx
  801926:	38 d9                	cmp    %bl,%cl
  801928:	75 08                	jne    801932 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  80192a:	83 c0 01             	add    $0x1,%eax
  80192d:	83 c2 01             	add    $0x1,%edx
  801930:	eb ea                	jmp    80191c <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  801932:	0f b6 c1             	movzbl %cl,%eax
  801935:	0f b6 db             	movzbl %bl,%ebx
  801938:	29 d8                	sub    %ebx,%eax
  80193a:	eb 05                	jmp    801941 <memcmp+0x35>
	}

	return 0;
  80193c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801941:	5b                   	pop    %ebx
  801942:	5e                   	pop    %esi
  801943:	5d                   	pop    %ebp
  801944:	c3                   	ret    

00801945 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801945:	55                   	push   %ebp
  801946:	89 e5                	mov    %esp,%ebp
  801948:	8b 45 08             	mov    0x8(%ebp),%eax
  80194b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80194e:	89 c2                	mov    %eax,%edx
  801950:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801953:	39 d0                	cmp    %edx,%eax
  801955:	73 09                	jae    801960 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  801957:	38 08                	cmp    %cl,(%eax)
  801959:	74 05                	je     801960 <memfind+0x1b>
	for (; s < ends; s++)
  80195b:	83 c0 01             	add    $0x1,%eax
  80195e:	eb f3                	jmp    801953 <memfind+0xe>
			break;
	return (void *) s;
}
  801960:	5d                   	pop    %ebp
  801961:	c3                   	ret    

00801962 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801962:	55                   	push   %ebp
  801963:	89 e5                	mov    %esp,%ebp
  801965:	57                   	push   %edi
  801966:	56                   	push   %esi
  801967:	53                   	push   %ebx
  801968:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80196b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80196e:	eb 03                	jmp    801973 <strtol+0x11>
		s++;
  801970:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801973:	0f b6 01             	movzbl (%ecx),%eax
  801976:	3c 20                	cmp    $0x20,%al
  801978:	74 f6                	je     801970 <strtol+0xe>
  80197a:	3c 09                	cmp    $0x9,%al
  80197c:	74 f2                	je     801970 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  80197e:	3c 2b                	cmp    $0x2b,%al
  801980:	74 2e                	je     8019b0 <strtol+0x4e>
	int neg = 0;
  801982:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801987:	3c 2d                	cmp    $0x2d,%al
  801989:	74 2f                	je     8019ba <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80198b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801991:	75 05                	jne    801998 <strtol+0x36>
  801993:	80 39 30             	cmpb   $0x30,(%ecx)
  801996:	74 2c                	je     8019c4 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801998:	85 db                	test   %ebx,%ebx
  80199a:	75 0a                	jne    8019a6 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80199c:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  8019a1:	80 39 30             	cmpb   $0x30,(%ecx)
  8019a4:	74 28                	je     8019ce <strtol+0x6c>
		base = 10;
  8019a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8019ab:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8019ae:	eb 50                	jmp    801a00 <strtol+0x9e>
		s++;
  8019b0:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  8019b3:	bf 00 00 00 00       	mov    $0x0,%edi
  8019b8:	eb d1                	jmp    80198b <strtol+0x29>
		s++, neg = 1;
  8019ba:	83 c1 01             	add    $0x1,%ecx
  8019bd:	bf 01 00 00 00       	mov    $0x1,%edi
  8019c2:	eb c7                	jmp    80198b <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019c4:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019c8:	74 0e                	je     8019d8 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8019ca:	85 db                	test   %ebx,%ebx
  8019cc:	75 d8                	jne    8019a6 <strtol+0x44>
		s++, base = 8;
  8019ce:	83 c1 01             	add    $0x1,%ecx
  8019d1:	bb 08 00 00 00       	mov    $0x8,%ebx
  8019d6:	eb ce                	jmp    8019a6 <strtol+0x44>
		s += 2, base = 16;
  8019d8:	83 c1 02             	add    $0x2,%ecx
  8019db:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019e0:	eb c4                	jmp    8019a6 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  8019e2:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019e5:	89 f3                	mov    %esi,%ebx
  8019e7:	80 fb 19             	cmp    $0x19,%bl
  8019ea:	77 29                	ja     801a15 <strtol+0xb3>
			dig = *s - 'a' + 10;
  8019ec:	0f be d2             	movsbl %dl,%edx
  8019ef:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8019f2:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019f5:	7d 30                	jge    801a27 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  8019f7:	83 c1 01             	add    $0x1,%ecx
  8019fa:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019fe:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801a00:	0f b6 11             	movzbl (%ecx),%edx
  801a03:	8d 72 d0             	lea    -0x30(%edx),%esi
  801a06:	89 f3                	mov    %esi,%ebx
  801a08:	80 fb 09             	cmp    $0x9,%bl
  801a0b:	77 d5                	ja     8019e2 <strtol+0x80>
			dig = *s - '0';
  801a0d:	0f be d2             	movsbl %dl,%edx
  801a10:	83 ea 30             	sub    $0x30,%edx
  801a13:	eb dd                	jmp    8019f2 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  801a15:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a18:	89 f3                	mov    %esi,%ebx
  801a1a:	80 fb 19             	cmp    $0x19,%bl
  801a1d:	77 08                	ja     801a27 <strtol+0xc5>
			dig = *s - 'A' + 10;
  801a1f:	0f be d2             	movsbl %dl,%edx
  801a22:	83 ea 37             	sub    $0x37,%edx
  801a25:	eb cb                	jmp    8019f2 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  801a27:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a2b:	74 05                	je     801a32 <strtol+0xd0>
		*endptr = (char *) s;
  801a2d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a30:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801a32:	89 c2                	mov    %eax,%edx
  801a34:	f7 da                	neg    %edx
  801a36:	85 ff                	test   %edi,%edi
  801a38:	0f 45 c2             	cmovne %edx,%eax
}
  801a3b:	5b                   	pop    %ebx
  801a3c:	5e                   	pop    %esi
  801a3d:	5f                   	pop    %edi
  801a3e:	5d                   	pop    %ebp
  801a3f:	c3                   	ret    

00801a40 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a40:	55                   	push   %ebp
  801a41:	89 e5                	mov    %esp,%ebp
  801a43:	56                   	push   %esi
  801a44:	53                   	push   %ebx
  801a45:	8b 75 08             	mov    0x8(%ebp),%esi
  801a48:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  801a4e:	85 f6                	test   %esi,%esi
  801a50:	74 06                	je     801a58 <ipc_recv+0x18>
  801a52:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801a58:	85 db                	test   %ebx,%ebx
  801a5a:	74 06                	je     801a62 <ipc_recv+0x22>
  801a5c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801a62:	85 c0                	test   %eax,%eax
  801a64:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801a69:	0f 44 c2             	cmove  %edx,%eax
	int ret = sys_ipc_recv(pg);
  801a6c:	83 ec 0c             	sub    $0xc,%esp
  801a6f:	50                   	push   %eax
  801a70:	e8 a5 e8 ff ff       	call   80031a <sys_ipc_recv>
	if (ret) return ret;
  801a75:	83 c4 10             	add    $0x10,%esp
  801a78:	85 c0                	test   %eax,%eax
  801a7a:	75 24                	jne    801aa0 <ipc_recv+0x60>
	if (from_env_store)
  801a7c:	85 f6                	test   %esi,%esi
  801a7e:	74 0a                	je     801a8a <ipc_recv+0x4a>
		*from_env_store = thisenv->env_ipc_from;
  801a80:	a1 04 40 80 00       	mov    0x804004,%eax
  801a85:	8b 40 74             	mov    0x74(%eax),%eax
  801a88:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801a8a:	85 db                	test   %ebx,%ebx
  801a8c:	74 0a                	je     801a98 <ipc_recv+0x58>
		*perm_store = thisenv->env_ipc_perm;
  801a8e:	a1 04 40 80 00       	mov    0x804004,%eax
  801a93:	8b 40 78             	mov    0x78(%eax),%eax
  801a96:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801a98:	a1 04 40 80 00       	mov    0x804004,%eax
  801a9d:	8b 40 70             	mov    0x70(%eax),%eax
}
  801aa0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aa3:	5b                   	pop    %ebx
  801aa4:	5e                   	pop    %esi
  801aa5:	5d                   	pop    %ebp
  801aa6:	c3                   	ret    

00801aa7 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801aa7:	55                   	push   %ebp
  801aa8:	89 e5                	mov    %esp,%ebp
  801aaa:	57                   	push   %edi
  801aab:	56                   	push   %esi
  801aac:	53                   	push   %ebx
  801aad:	83 ec 0c             	sub    $0xc,%esp
  801ab0:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ab3:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ab6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  801ab9:	85 db                	test   %ebx,%ebx
  801abb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801ac0:	0f 44 d8             	cmove  %eax,%ebx
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801ac3:	ff 75 14             	pushl  0x14(%ebp)
  801ac6:	53                   	push   %ebx
  801ac7:	56                   	push   %esi
  801ac8:	57                   	push   %edi
  801ac9:	e8 29 e8 ff ff       	call   8002f7 <sys_ipc_try_send>
  801ace:	83 c4 10             	add    $0x10,%esp
  801ad1:	85 c0                	test   %eax,%eax
  801ad3:	74 1e                	je     801af3 <ipc_send+0x4c>
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801ad5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ad8:	75 07                	jne    801ae1 <ipc_send+0x3a>
		sys_yield();
  801ada:	e8 6c e6 ff ff       	call   80014b <sys_yield>
  801adf:	eb e2                	jmp    801ac3 <ipc_send+0x1c>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801ae1:	50                   	push   %eax
  801ae2:	68 20 22 80 00       	push   $0x802220
  801ae7:	6a 36                	push   $0x36
  801ae9:	68 37 22 80 00       	push   $0x802237
  801aee:	e8 16 f5 ff ff       	call   801009 <_panic>
	}
}
  801af3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801af6:	5b                   	pop    %ebx
  801af7:	5e                   	pop    %esi
  801af8:	5f                   	pop    %edi
  801af9:	5d                   	pop    %ebp
  801afa:	c3                   	ret    

00801afb <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801afb:	55                   	push   %ebp
  801afc:	89 e5                	mov    %esp,%ebp
  801afe:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b01:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b06:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b09:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b0f:	8b 52 50             	mov    0x50(%edx),%edx
  801b12:	39 ca                	cmp    %ecx,%edx
  801b14:	74 11                	je     801b27 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801b16:	83 c0 01             	add    $0x1,%eax
  801b19:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b1e:	75 e6                	jne    801b06 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801b20:	b8 00 00 00 00       	mov    $0x0,%eax
  801b25:	eb 0b                	jmp    801b32 <ipc_find_env+0x37>
			return envs[i].env_id;
  801b27:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b2a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b2f:	8b 40 48             	mov    0x48(%eax),%eax
}
  801b32:	5d                   	pop    %ebp
  801b33:	c3                   	ret    

00801b34 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b34:	55                   	push   %ebp
  801b35:	89 e5                	mov    %esp,%ebp
  801b37:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b3a:	89 d0                	mov    %edx,%eax
  801b3c:	c1 e8 16             	shr    $0x16,%eax
  801b3f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b46:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801b4b:	f6 c1 01             	test   $0x1,%cl
  801b4e:	74 1d                	je     801b6d <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801b50:	c1 ea 0c             	shr    $0xc,%edx
  801b53:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b5a:	f6 c2 01             	test   $0x1,%dl
  801b5d:	74 0e                	je     801b6d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b5f:	c1 ea 0c             	shr    $0xc,%edx
  801b62:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b69:	ef 
  801b6a:	0f b7 c0             	movzwl %ax,%eax
}
  801b6d:	5d                   	pop    %ebp
  801b6e:	c3                   	ret    
  801b6f:	90                   	nop

00801b70 <__udivdi3>:
  801b70:	55                   	push   %ebp
  801b71:	57                   	push   %edi
  801b72:	56                   	push   %esi
  801b73:	53                   	push   %ebx
  801b74:	83 ec 1c             	sub    $0x1c,%esp
  801b77:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801b7b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801b7f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801b83:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801b87:	85 d2                	test   %edx,%edx
  801b89:	75 35                	jne    801bc0 <__udivdi3+0x50>
  801b8b:	39 f3                	cmp    %esi,%ebx
  801b8d:	0f 87 bd 00 00 00    	ja     801c50 <__udivdi3+0xe0>
  801b93:	85 db                	test   %ebx,%ebx
  801b95:	89 d9                	mov    %ebx,%ecx
  801b97:	75 0b                	jne    801ba4 <__udivdi3+0x34>
  801b99:	b8 01 00 00 00       	mov    $0x1,%eax
  801b9e:	31 d2                	xor    %edx,%edx
  801ba0:	f7 f3                	div    %ebx
  801ba2:	89 c1                	mov    %eax,%ecx
  801ba4:	31 d2                	xor    %edx,%edx
  801ba6:	89 f0                	mov    %esi,%eax
  801ba8:	f7 f1                	div    %ecx
  801baa:	89 c6                	mov    %eax,%esi
  801bac:	89 e8                	mov    %ebp,%eax
  801bae:	89 f7                	mov    %esi,%edi
  801bb0:	f7 f1                	div    %ecx
  801bb2:	89 fa                	mov    %edi,%edx
  801bb4:	83 c4 1c             	add    $0x1c,%esp
  801bb7:	5b                   	pop    %ebx
  801bb8:	5e                   	pop    %esi
  801bb9:	5f                   	pop    %edi
  801bba:	5d                   	pop    %ebp
  801bbb:	c3                   	ret    
  801bbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801bc0:	39 f2                	cmp    %esi,%edx
  801bc2:	77 7c                	ja     801c40 <__udivdi3+0xd0>
  801bc4:	0f bd fa             	bsr    %edx,%edi
  801bc7:	83 f7 1f             	xor    $0x1f,%edi
  801bca:	0f 84 98 00 00 00    	je     801c68 <__udivdi3+0xf8>
  801bd0:	89 f9                	mov    %edi,%ecx
  801bd2:	b8 20 00 00 00       	mov    $0x20,%eax
  801bd7:	29 f8                	sub    %edi,%eax
  801bd9:	d3 e2                	shl    %cl,%edx
  801bdb:	89 54 24 08          	mov    %edx,0x8(%esp)
  801bdf:	89 c1                	mov    %eax,%ecx
  801be1:	89 da                	mov    %ebx,%edx
  801be3:	d3 ea                	shr    %cl,%edx
  801be5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801be9:	09 d1                	or     %edx,%ecx
  801beb:	89 f2                	mov    %esi,%edx
  801bed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801bf1:	89 f9                	mov    %edi,%ecx
  801bf3:	d3 e3                	shl    %cl,%ebx
  801bf5:	89 c1                	mov    %eax,%ecx
  801bf7:	d3 ea                	shr    %cl,%edx
  801bf9:	89 f9                	mov    %edi,%ecx
  801bfb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801bff:	d3 e6                	shl    %cl,%esi
  801c01:	89 eb                	mov    %ebp,%ebx
  801c03:	89 c1                	mov    %eax,%ecx
  801c05:	d3 eb                	shr    %cl,%ebx
  801c07:	09 de                	or     %ebx,%esi
  801c09:	89 f0                	mov    %esi,%eax
  801c0b:	f7 74 24 08          	divl   0x8(%esp)
  801c0f:	89 d6                	mov    %edx,%esi
  801c11:	89 c3                	mov    %eax,%ebx
  801c13:	f7 64 24 0c          	mull   0xc(%esp)
  801c17:	39 d6                	cmp    %edx,%esi
  801c19:	72 0c                	jb     801c27 <__udivdi3+0xb7>
  801c1b:	89 f9                	mov    %edi,%ecx
  801c1d:	d3 e5                	shl    %cl,%ebp
  801c1f:	39 c5                	cmp    %eax,%ebp
  801c21:	73 5d                	jae    801c80 <__udivdi3+0x110>
  801c23:	39 d6                	cmp    %edx,%esi
  801c25:	75 59                	jne    801c80 <__udivdi3+0x110>
  801c27:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801c2a:	31 ff                	xor    %edi,%edi
  801c2c:	89 fa                	mov    %edi,%edx
  801c2e:	83 c4 1c             	add    $0x1c,%esp
  801c31:	5b                   	pop    %ebx
  801c32:	5e                   	pop    %esi
  801c33:	5f                   	pop    %edi
  801c34:	5d                   	pop    %ebp
  801c35:	c3                   	ret    
  801c36:	8d 76 00             	lea    0x0(%esi),%esi
  801c39:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801c40:	31 ff                	xor    %edi,%edi
  801c42:	31 c0                	xor    %eax,%eax
  801c44:	89 fa                	mov    %edi,%edx
  801c46:	83 c4 1c             	add    $0x1c,%esp
  801c49:	5b                   	pop    %ebx
  801c4a:	5e                   	pop    %esi
  801c4b:	5f                   	pop    %edi
  801c4c:	5d                   	pop    %ebp
  801c4d:	c3                   	ret    
  801c4e:	66 90                	xchg   %ax,%ax
  801c50:	31 ff                	xor    %edi,%edi
  801c52:	89 e8                	mov    %ebp,%eax
  801c54:	89 f2                	mov    %esi,%edx
  801c56:	f7 f3                	div    %ebx
  801c58:	89 fa                	mov    %edi,%edx
  801c5a:	83 c4 1c             	add    $0x1c,%esp
  801c5d:	5b                   	pop    %ebx
  801c5e:	5e                   	pop    %esi
  801c5f:	5f                   	pop    %edi
  801c60:	5d                   	pop    %ebp
  801c61:	c3                   	ret    
  801c62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c68:	39 f2                	cmp    %esi,%edx
  801c6a:	72 06                	jb     801c72 <__udivdi3+0x102>
  801c6c:	31 c0                	xor    %eax,%eax
  801c6e:	39 eb                	cmp    %ebp,%ebx
  801c70:	77 d2                	ja     801c44 <__udivdi3+0xd4>
  801c72:	b8 01 00 00 00       	mov    $0x1,%eax
  801c77:	eb cb                	jmp    801c44 <__udivdi3+0xd4>
  801c79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c80:	89 d8                	mov    %ebx,%eax
  801c82:	31 ff                	xor    %edi,%edi
  801c84:	eb be                	jmp    801c44 <__udivdi3+0xd4>
  801c86:	66 90                	xchg   %ax,%ax
  801c88:	66 90                	xchg   %ax,%ax
  801c8a:	66 90                	xchg   %ax,%ax
  801c8c:	66 90                	xchg   %ax,%ax
  801c8e:	66 90                	xchg   %ax,%ax

00801c90 <__umoddi3>:
  801c90:	55                   	push   %ebp
  801c91:	57                   	push   %edi
  801c92:	56                   	push   %esi
  801c93:	53                   	push   %ebx
  801c94:	83 ec 1c             	sub    $0x1c,%esp
  801c97:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801c9b:	8b 74 24 30          	mov    0x30(%esp),%esi
  801c9f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801ca3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ca7:	85 ed                	test   %ebp,%ebp
  801ca9:	89 f0                	mov    %esi,%eax
  801cab:	89 da                	mov    %ebx,%edx
  801cad:	75 19                	jne    801cc8 <__umoddi3+0x38>
  801caf:	39 df                	cmp    %ebx,%edi
  801cb1:	0f 86 b1 00 00 00    	jbe    801d68 <__umoddi3+0xd8>
  801cb7:	f7 f7                	div    %edi
  801cb9:	89 d0                	mov    %edx,%eax
  801cbb:	31 d2                	xor    %edx,%edx
  801cbd:	83 c4 1c             	add    $0x1c,%esp
  801cc0:	5b                   	pop    %ebx
  801cc1:	5e                   	pop    %esi
  801cc2:	5f                   	pop    %edi
  801cc3:	5d                   	pop    %ebp
  801cc4:	c3                   	ret    
  801cc5:	8d 76 00             	lea    0x0(%esi),%esi
  801cc8:	39 dd                	cmp    %ebx,%ebp
  801cca:	77 f1                	ja     801cbd <__umoddi3+0x2d>
  801ccc:	0f bd cd             	bsr    %ebp,%ecx
  801ccf:	83 f1 1f             	xor    $0x1f,%ecx
  801cd2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801cd6:	0f 84 b4 00 00 00    	je     801d90 <__umoddi3+0x100>
  801cdc:	b8 20 00 00 00       	mov    $0x20,%eax
  801ce1:	89 c2                	mov    %eax,%edx
  801ce3:	8b 44 24 04          	mov    0x4(%esp),%eax
  801ce7:	29 c2                	sub    %eax,%edx
  801ce9:	89 c1                	mov    %eax,%ecx
  801ceb:	89 f8                	mov    %edi,%eax
  801ced:	d3 e5                	shl    %cl,%ebp
  801cef:	89 d1                	mov    %edx,%ecx
  801cf1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801cf5:	d3 e8                	shr    %cl,%eax
  801cf7:	09 c5                	or     %eax,%ebp
  801cf9:	8b 44 24 04          	mov    0x4(%esp),%eax
  801cfd:	89 c1                	mov    %eax,%ecx
  801cff:	d3 e7                	shl    %cl,%edi
  801d01:	89 d1                	mov    %edx,%ecx
  801d03:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801d07:	89 df                	mov    %ebx,%edi
  801d09:	d3 ef                	shr    %cl,%edi
  801d0b:	89 c1                	mov    %eax,%ecx
  801d0d:	89 f0                	mov    %esi,%eax
  801d0f:	d3 e3                	shl    %cl,%ebx
  801d11:	89 d1                	mov    %edx,%ecx
  801d13:	89 fa                	mov    %edi,%edx
  801d15:	d3 e8                	shr    %cl,%eax
  801d17:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801d1c:	09 d8                	or     %ebx,%eax
  801d1e:	f7 f5                	div    %ebp
  801d20:	d3 e6                	shl    %cl,%esi
  801d22:	89 d1                	mov    %edx,%ecx
  801d24:	f7 64 24 08          	mull   0x8(%esp)
  801d28:	39 d1                	cmp    %edx,%ecx
  801d2a:	89 c3                	mov    %eax,%ebx
  801d2c:	89 d7                	mov    %edx,%edi
  801d2e:	72 06                	jb     801d36 <__umoddi3+0xa6>
  801d30:	75 0e                	jne    801d40 <__umoddi3+0xb0>
  801d32:	39 c6                	cmp    %eax,%esi
  801d34:	73 0a                	jae    801d40 <__umoddi3+0xb0>
  801d36:	2b 44 24 08          	sub    0x8(%esp),%eax
  801d3a:	19 ea                	sbb    %ebp,%edx
  801d3c:	89 d7                	mov    %edx,%edi
  801d3e:	89 c3                	mov    %eax,%ebx
  801d40:	89 ca                	mov    %ecx,%edx
  801d42:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801d47:	29 de                	sub    %ebx,%esi
  801d49:	19 fa                	sbb    %edi,%edx
  801d4b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  801d4f:	89 d0                	mov    %edx,%eax
  801d51:	d3 e0                	shl    %cl,%eax
  801d53:	89 d9                	mov    %ebx,%ecx
  801d55:	d3 ee                	shr    %cl,%esi
  801d57:	d3 ea                	shr    %cl,%edx
  801d59:	09 f0                	or     %esi,%eax
  801d5b:	83 c4 1c             	add    $0x1c,%esp
  801d5e:	5b                   	pop    %ebx
  801d5f:	5e                   	pop    %esi
  801d60:	5f                   	pop    %edi
  801d61:	5d                   	pop    %ebp
  801d62:	c3                   	ret    
  801d63:	90                   	nop
  801d64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d68:	85 ff                	test   %edi,%edi
  801d6a:	89 f9                	mov    %edi,%ecx
  801d6c:	75 0b                	jne    801d79 <__umoddi3+0xe9>
  801d6e:	b8 01 00 00 00       	mov    $0x1,%eax
  801d73:	31 d2                	xor    %edx,%edx
  801d75:	f7 f7                	div    %edi
  801d77:	89 c1                	mov    %eax,%ecx
  801d79:	89 d8                	mov    %ebx,%eax
  801d7b:	31 d2                	xor    %edx,%edx
  801d7d:	f7 f1                	div    %ecx
  801d7f:	89 f0                	mov    %esi,%eax
  801d81:	f7 f1                	div    %ecx
  801d83:	e9 31 ff ff ff       	jmp    801cb9 <__umoddi3+0x29>
  801d88:	90                   	nop
  801d89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d90:	39 dd                	cmp    %ebx,%ebp
  801d92:	72 08                	jb     801d9c <__umoddi3+0x10c>
  801d94:	39 f7                	cmp    %esi,%edi
  801d96:	0f 87 21 ff ff ff    	ja     801cbd <__umoddi3+0x2d>
  801d9c:	89 da                	mov    %ebx,%edx
  801d9e:	89 f0                	mov    %esi,%eax
  801da0:	29 f8                	sub    %edi,%eax
  801da2:	19 ea                	sbb    %ebp,%edx
  801da4:	e9 14 ff ff ff       	jmp    801cbd <__umoddi3+0x2d>
