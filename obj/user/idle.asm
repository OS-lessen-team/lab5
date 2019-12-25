
obj/user/idle.debug：     文件格式 elf32-i386


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
  80002c:	e8 19 00 00 00       	call   80004a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/x86.h>
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 08             	sub    $0x8,%esp
	binaryname = "idle";
  800039:	c7 05 00 30 80 00 c0 	movl   $0x801dc0,0x803000
  800040:	1d 80 00 
	// Instead of busy-waiting like this,
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	while (1) {
		sys_yield();
  800043:	e8 ff 00 00 00       	call   800147 <sys_yield>
  800048:	eb f9                	jmp    800043 <umain+0x10>

0080004a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004a:	55                   	push   %ebp
  80004b:	89 e5                	mov    %esp,%ebp
  80004d:	56                   	push   %esi
  80004e:	53                   	push   %ebx
  80004f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800052:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800055:	e8 ce 00 00 00       	call   800128 <sys_getenvid>
	thisenv = envs + ENVX(envid); 
  80005a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800062:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800067:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006c:	85 db                	test   %ebx,%ebx
  80006e:	7e 07                	jle    800077 <libmain+0x2d>
		binaryname = argv[0];
  800070:	8b 06                	mov    (%esi),%eax
  800072:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800077:	83 ec 08             	sub    $0x8,%esp
  80007a:	56                   	push   %esi
  80007b:	53                   	push   %ebx
  80007c:	e8 b2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800081:	e8 0a 00 00 00       	call   800090 <exit>
}
  800086:	83 c4 10             	add    $0x10,%esp
  800089:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008c:	5b                   	pop    %ebx
  80008d:	5e                   	pop    %esi
  80008e:	5d                   	pop    %ebp
  80008f:	c3                   	ret    

00800090 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800096:	e8 92 04 00 00       	call   80052d <close_all>
	sys_env_destroy(0);
  80009b:	83 ec 0c             	sub    $0xc,%esp
  80009e:	6a 00                	push   $0x0
  8000a0:	e8 42 00 00 00       	call   8000e7 <sys_env_destroy>
}
  8000a5:	83 c4 10             	add    $0x10,%esp
  8000a8:	c9                   	leave  
  8000a9:	c3                   	ret    

008000aa <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000aa:	55                   	push   %ebp
  8000ab:	89 e5                	mov    %esp,%ebp
  8000ad:	57                   	push   %edi
  8000ae:	56                   	push   %esi
  8000af:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bb:	89 c3                	mov    %eax,%ebx
  8000bd:	89 c7                	mov    %eax,%edi
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c3:	5b                   	pop    %ebx
  8000c4:	5e                   	pop    %esi
  8000c5:	5f                   	pop    %edi
  8000c6:	5d                   	pop    %ebp
  8000c7:	c3                   	ret    

008000c8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	57                   	push   %edi
  8000cc:	56                   	push   %esi
  8000cd:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d8:	89 d1                	mov    %edx,%ecx
  8000da:	89 d3                	mov    %edx,%ebx
  8000dc:	89 d7                	mov    %edx,%edi
  8000de:	89 d6                	mov    %edx,%esi
  8000e0:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e2:	5b                   	pop    %ebx
  8000e3:	5e                   	pop    %esi
  8000e4:	5f                   	pop    %edi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	57                   	push   %edi
  8000eb:	56                   	push   %esi
  8000ec:	53                   	push   %ebx
  8000ed:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f8:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fd:	89 cb                	mov    %ecx,%ebx
  8000ff:	89 cf                	mov    %ecx,%edi
  800101:	89 ce                	mov    %ecx,%esi
  800103:	cd 30                	int    $0x30
	if(check && ret > 0)
  800105:	85 c0                	test   %eax,%eax
  800107:	7f 08                	jg     800111 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800109:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010c:	5b                   	pop    %ebx
  80010d:	5e                   	pop    %esi
  80010e:	5f                   	pop    %edi
  80010f:	5d                   	pop    %ebp
  800110:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800111:	83 ec 0c             	sub    $0xc,%esp
  800114:	50                   	push   %eax
  800115:	6a 03                	push   $0x3
  800117:	68 cf 1d 80 00       	push   $0x801dcf
  80011c:	6a 23                	push   $0x23
  80011e:	68 ec 1d 80 00       	push   $0x801dec
  800123:	e8 dd 0e 00 00       	call   801005 <_panic>

00800128 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	57                   	push   %edi
  80012c:	56                   	push   %esi
  80012d:	53                   	push   %ebx
	asm volatile("int %1\n"
  80012e:	ba 00 00 00 00       	mov    $0x0,%edx
  800133:	b8 02 00 00 00       	mov    $0x2,%eax
  800138:	89 d1                	mov    %edx,%ecx
  80013a:	89 d3                	mov    %edx,%ebx
  80013c:	89 d7                	mov    %edx,%edi
  80013e:	89 d6                	mov    %edx,%esi
  800140:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800142:	5b                   	pop    %ebx
  800143:	5e                   	pop    %esi
  800144:	5f                   	pop    %edi
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    

00800147 <sys_yield>:

void
sys_yield(void)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	57                   	push   %edi
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
	asm volatile("int %1\n"
  80014d:	ba 00 00 00 00       	mov    $0x0,%edx
  800152:	b8 0b 00 00 00       	mov    $0xb,%eax
  800157:	89 d1                	mov    %edx,%ecx
  800159:	89 d3                	mov    %edx,%ebx
  80015b:	89 d7                	mov    %edx,%edi
  80015d:	89 d6                	mov    %edx,%esi
  80015f:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800161:	5b                   	pop    %ebx
  800162:	5e                   	pop    %esi
  800163:	5f                   	pop    %edi
  800164:	5d                   	pop    %ebp
  800165:	c3                   	ret    

00800166 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800166:	55                   	push   %ebp
  800167:	89 e5                	mov    %esp,%ebp
  800169:	57                   	push   %edi
  80016a:	56                   	push   %esi
  80016b:	53                   	push   %ebx
  80016c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80016f:	be 00 00 00 00       	mov    $0x0,%esi
  800174:	8b 55 08             	mov    0x8(%ebp),%edx
  800177:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017a:	b8 04 00 00 00       	mov    $0x4,%eax
  80017f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800182:	89 f7                	mov    %esi,%edi
  800184:	cd 30                	int    $0x30
	if(check && ret > 0)
  800186:	85 c0                	test   %eax,%eax
  800188:	7f 08                	jg     800192 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80018a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80018d:	5b                   	pop    %ebx
  80018e:	5e                   	pop    %esi
  80018f:	5f                   	pop    %edi
  800190:	5d                   	pop    %ebp
  800191:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800192:	83 ec 0c             	sub    $0xc,%esp
  800195:	50                   	push   %eax
  800196:	6a 04                	push   $0x4
  800198:	68 cf 1d 80 00       	push   $0x801dcf
  80019d:	6a 23                	push   $0x23
  80019f:	68 ec 1d 80 00       	push   $0x801dec
  8001a4:	e8 5c 0e 00 00       	call   801005 <_panic>

008001a9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a9:	55                   	push   %ebp
  8001aa:	89 e5                	mov    %esp,%ebp
  8001ac:	57                   	push   %edi
  8001ad:	56                   	push   %esi
  8001ae:	53                   	push   %ebx
  8001af:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b8:	b8 05 00 00 00       	mov    $0x5,%eax
  8001bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c6:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001c8:	85 c0                	test   %eax,%eax
  8001ca:	7f 08                	jg     8001d4 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001cf:	5b                   	pop    %ebx
  8001d0:	5e                   	pop    %esi
  8001d1:	5f                   	pop    %edi
  8001d2:	5d                   	pop    %ebp
  8001d3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d4:	83 ec 0c             	sub    $0xc,%esp
  8001d7:	50                   	push   %eax
  8001d8:	6a 05                	push   $0x5
  8001da:	68 cf 1d 80 00       	push   $0x801dcf
  8001df:	6a 23                	push   $0x23
  8001e1:	68 ec 1d 80 00       	push   $0x801dec
  8001e6:	e8 1a 0e 00 00       	call   801005 <_panic>

008001eb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001eb:	55                   	push   %ebp
  8001ec:	89 e5                	mov    %esp,%ebp
  8001ee:	57                   	push   %edi
  8001ef:	56                   	push   %esi
  8001f0:	53                   	push   %ebx
  8001f1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001f4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ff:	b8 06 00 00 00       	mov    $0x6,%eax
  800204:	89 df                	mov    %ebx,%edi
  800206:	89 de                	mov    %ebx,%esi
  800208:	cd 30                	int    $0x30
	if(check && ret > 0)
  80020a:	85 c0                	test   %eax,%eax
  80020c:	7f 08                	jg     800216 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80020e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800211:	5b                   	pop    %ebx
  800212:	5e                   	pop    %esi
  800213:	5f                   	pop    %edi
  800214:	5d                   	pop    %ebp
  800215:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800216:	83 ec 0c             	sub    $0xc,%esp
  800219:	50                   	push   %eax
  80021a:	6a 06                	push   $0x6
  80021c:	68 cf 1d 80 00       	push   $0x801dcf
  800221:	6a 23                	push   $0x23
  800223:	68 ec 1d 80 00       	push   $0x801dec
  800228:	e8 d8 0d 00 00       	call   801005 <_panic>

0080022d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022d:	55                   	push   %ebp
  80022e:	89 e5                	mov    %esp,%ebp
  800230:	57                   	push   %edi
  800231:	56                   	push   %esi
  800232:	53                   	push   %ebx
  800233:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800236:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023b:	8b 55 08             	mov    0x8(%ebp),%edx
  80023e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800241:	b8 08 00 00 00       	mov    $0x8,%eax
  800246:	89 df                	mov    %ebx,%edi
  800248:	89 de                	mov    %ebx,%esi
  80024a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80024c:	85 c0                	test   %eax,%eax
  80024e:	7f 08                	jg     800258 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800250:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800253:	5b                   	pop    %ebx
  800254:	5e                   	pop    %esi
  800255:	5f                   	pop    %edi
  800256:	5d                   	pop    %ebp
  800257:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800258:	83 ec 0c             	sub    $0xc,%esp
  80025b:	50                   	push   %eax
  80025c:	6a 08                	push   $0x8
  80025e:	68 cf 1d 80 00       	push   $0x801dcf
  800263:	6a 23                	push   $0x23
  800265:	68 ec 1d 80 00       	push   $0x801dec
  80026a:	e8 96 0d 00 00       	call   801005 <_panic>

0080026f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
  800272:	57                   	push   %edi
  800273:	56                   	push   %esi
  800274:	53                   	push   %ebx
  800275:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800278:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027d:	8b 55 08             	mov    0x8(%ebp),%edx
  800280:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800283:	b8 09 00 00 00       	mov    $0x9,%eax
  800288:	89 df                	mov    %ebx,%edi
  80028a:	89 de                	mov    %ebx,%esi
  80028c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80028e:	85 c0                	test   %eax,%eax
  800290:	7f 08                	jg     80029a <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800292:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800295:	5b                   	pop    %ebx
  800296:	5e                   	pop    %esi
  800297:	5f                   	pop    %edi
  800298:	5d                   	pop    %ebp
  800299:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80029a:	83 ec 0c             	sub    $0xc,%esp
  80029d:	50                   	push   %eax
  80029e:	6a 09                	push   $0x9
  8002a0:	68 cf 1d 80 00       	push   $0x801dcf
  8002a5:	6a 23                	push   $0x23
  8002a7:	68 ec 1d 80 00       	push   $0x801dec
  8002ac:	e8 54 0d 00 00       	call   801005 <_panic>

008002b1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	57                   	push   %edi
  8002b5:	56                   	push   %esi
  8002b6:	53                   	push   %ebx
  8002b7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002ba:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002ca:	89 df                	mov    %ebx,%edi
  8002cc:	89 de                	mov    %ebx,%esi
  8002ce:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002d0:	85 c0                	test   %eax,%eax
  8002d2:	7f 08                	jg     8002dc <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d7:	5b                   	pop    %ebx
  8002d8:	5e                   	pop    %esi
  8002d9:	5f                   	pop    %edi
  8002da:	5d                   	pop    %ebp
  8002db:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002dc:	83 ec 0c             	sub    $0xc,%esp
  8002df:	50                   	push   %eax
  8002e0:	6a 0a                	push   $0xa
  8002e2:	68 cf 1d 80 00       	push   $0x801dcf
  8002e7:	6a 23                	push   $0x23
  8002e9:	68 ec 1d 80 00       	push   $0x801dec
  8002ee:	e8 12 0d 00 00       	call   801005 <_panic>

008002f3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
  8002f6:	57                   	push   %edi
  8002f7:	56                   	push   %esi
  8002f8:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ff:	b8 0c 00 00 00       	mov    $0xc,%eax
  800304:	be 00 00 00 00       	mov    $0x0,%esi
  800309:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80030c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80030f:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800311:	5b                   	pop    %ebx
  800312:	5e                   	pop    %esi
  800313:	5f                   	pop    %edi
  800314:	5d                   	pop    %ebp
  800315:	c3                   	ret    

00800316 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800316:	55                   	push   %ebp
  800317:	89 e5                	mov    %esp,%ebp
  800319:	57                   	push   %edi
  80031a:	56                   	push   %esi
  80031b:	53                   	push   %ebx
  80031c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80031f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800324:	8b 55 08             	mov    0x8(%ebp),%edx
  800327:	b8 0d 00 00 00       	mov    $0xd,%eax
  80032c:	89 cb                	mov    %ecx,%ebx
  80032e:	89 cf                	mov    %ecx,%edi
  800330:	89 ce                	mov    %ecx,%esi
  800332:	cd 30                	int    $0x30
	if(check && ret > 0)
  800334:	85 c0                	test   %eax,%eax
  800336:	7f 08                	jg     800340 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800338:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80033b:	5b                   	pop    %ebx
  80033c:	5e                   	pop    %esi
  80033d:	5f                   	pop    %edi
  80033e:	5d                   	pop    %ebp
  80033f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800340:	83 ec 0c             	sub    $0xc,%esp
  800343:	50                   	push   %eax
  800344:	6a 0d                	push   $0xd
  800346:	68 cf 1d 80 00       	push   $0x801dcf
  80034b:	6a 23                	push   $0x23
  80034d:	68 ec 1d 80 00       	push   $0x801dec
  800352:	e8 ae 0c 00 00       	call   801005 <_panic>

00800357 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80035a:	8b 45 08             	mov    0x8(%ebp),%eax
  80035d:	05 00 00 00 30       	add    $0x30000000,%eax
  800362:	c1 e8 0c             	shr    $0xc,%eax
}
  800365:	5d                   	pop    %ebp
  800366:	c3                   	ret    

00800367 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800367:	55                   	push   %ebp
  800368:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80036a:	8b 45 08             	mov    0x8(%ebp),%eax
  80036d:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800372:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800377:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80037c:	5d                   	pop    %ebp
  80037d:	c3                   	ret    

0080037e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80037e:	55                   	push   %ebp
  80037f:	89 e5                	mov    %esp,%ebp
  800381:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800384:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800389:	89 c2                	mov    %eax,%edx
  80038b:	c1 ea 16             	shr    $0x16,%edx
  80038e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800395:	f6 c2 01             	test   $0x1,%dl
  800398:	74 2a                	je     8003c4 <fd_alloc+0x46>
  80039a:	89 c2                	mov    %eax,%edx
  80039c:	c1 ea 0c             	shr    $0xc,%edx
  80039f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003a6:	f6 c2 01             	test   $0x1,%dl
  8003a9:	74 19                	je     8003c4 <fd_alloc+0x46>
  8003ab:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8003b0:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003b5:	75 d2                	jne    800389 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003b7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003bd:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8003c2:	eb 07                	jmp    8003cb <fd_alloc+0x4d>
			*fd_store = fd;
  8003c4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003cb:	5d                   	pop    %ebp
  8003cc:	c3                   	ret    

008003cd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003cd:	55                   	push   %ebp
  8003ce:	89 e5                	mov    %esp,%ebp
  8003d0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003d3:	83 f8 1f             	cmp    $0x1f,%eax
  8003d6:	77 36                	ja     80040e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003d8:	c1 e0 0c             	shl    $0xc,%eax
  8003db:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003e0:	89 c2                	mov    %eax,%edx
  8003e2:	c1 ea 16             	shr    $0x16,%edx
  8003e5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003ec:	f6 c2 01             	test   $0x1,%dl
  8003ef:	74 24                	je     800415 <fd_lookup+0x48>
  8003f1:	89 c2                	mov    %eax,%edx
  8003f3:	c1 ea 0c             	shr    $0xc,%edx
  8003f6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003fd:	f6 c2 01             	test   $0x1,%dl
  800400:	74 1a                	je     80041c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800402:	8b 55 0c             	mov    0xc(%ebp),%edx
  800405:	89 02                	mov    %eax,(%edx)
	return 0;
  800407:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80040c:	5d                   	pop    %ebp
  80040d:	c3                   	ret    
		return -E_INVAL;
  80040e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800413:	eb f7                	jmp    80040c <fd_lookup+0x3f>
		return -E_INVAL;
  800415:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80041a:	eb f0                	jmp    80040c <fd_lookup+0x3f>
  80041c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800421:	eb e9                	jmp    80040c <fd_lookup+0x3f>

00800423 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800423:	55                   	push   %ebp
  800424:	89 e5                	mov    %esp,%ebp
  800426:	83 ec 08             	sub    $0x8,%esp
  800429:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80042c:	ba 78 1e 80 00       	mov    $0x801e78,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800431:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800436:	39 08                	cmp    %ecx,(%eax)
  800438:	74 33                	je     80046d <dev_lookup+0x4a>
  80043a:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  80043d:	8b 02                	mov    (%edx),%eax
  80043f:	85 c0                	test   %eax,%eax
  800441:	75 f3                	jne    800436 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800443:	a1 04 40 80 00       	mov    0x804004,%eax
  800448:	8b 40 48             	mov    0x48(%eax),%eax
  80044b:	83 ec 04             	sub    $0x4,%esp
  80044e:	51                   	push   %ecx
  80044f:	50                   	push   %eax
  800450:	68 fc 1d 80 00       	push   $0x801dfc
  800455:	e8 86 0c 00 00       	call   8010e0 <cprintf>
	*dev = 0;
  80045a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80045d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800463:	83 c4 10             	add    $0x10,%esp
  800466:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80046b:	c9                   	leave  
  80046c:	c3                   	ret    
			*dev = devtab[i];
  80046d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800470:	89 01                	mov    %eax,(%ecx)
			return 0;
  800472:	b8 00 00 00 00       	mov    $0x0,%eax
  800477:	eb f2                	jmp    80046b <dev_lookup+0x48>

00800479 <fd_close>:
{
  800479:	55                   	push   %ebp
  80047a:	89 e5                	mov    %esp,%ebp
  80047c:	57                   	push   %edi
  80047d:	56                   	push   %esi
  80047e:	53                   	push   %ebx
  80047f:	83 ec 1c             	sub    $0x1c,%esp
  800482:	8b 75 08             	mov    0x8(%ebp),%esi
  800485:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800488:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80048b:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80048c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800492:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800495:	50                   	push   %eax
  800496:	e8 32 ff ff ff       	call   8003cd <fd_lookup>
  80049b:	89 c3                	mov    %eax,%ebx
  80049d:	83 c4 08             	add    $0x8,%esp
  8004a0:	85 c0                	test   %eax,%eax
  8004a2:	78 05                	js     8004a9 <fd_close+0x30>
	    || fd != fd2)
  8004a4:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8004a7:	74 16                	je     8004bf <fd_close+0x46>
		return (must_exist ? r : 0);
  8004a9:	89 f8                	mov    %edi,%eax
  8004ab:	84 c0                	test   %al,%al
  8004ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b2:	0f 44 d8             	cmove  %eax,%ebx
}
  8004b5:	89 d8                	mov    %ebx,%eax
  8004b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004ba:	5b                   	pop    %ebx
  8004bb:	5e                   	pop    %esi
  8004bc:	5f                   	pop    %edi
  8004bd:	5d                   	pop    %ebp
  8004be:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004bf:	83 ec 08             	sub    $0x8,%esp
  8004c2:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8004c5:	50                   	push   %eax
  8004c6:	ff 36                	pushl  (%esi)
  8004c8:	e8 56 ff ff ff       	call   800423 <dev_lookup>
  8004cd:	89 c3                	mov    %eax,%ebx
  8004cf:	83 c4 10             	add    $0x10,%esp
  8004d2:	85 c0                	test   %eax,%eax
  8004d4:	78 15                	js     8004eb <fd_close+0x72>
		if (dev->dev_close)
  8004d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004d9:	8b 40 10             	mov    0x10(%eax),%eax
  8004dc:	85 c0                	test   %eax,%eax
  8004de:	74 1b                	je     8004fb <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  8004e0:	83 ec 0c             	sub    $0xc,%esp
  8004e3:	56                   	push   %esi
  8004e4:	ff d0                	call   *%eax
  8004e6:	89 c3                	mov    %eax,%ebx
  8004e8:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8004eb:	83 ec 08             	sub    $0x8,%esp
  8004ee:	56                   	push   %esi
  8004ef:	6a 00                	push   $0x0
  8004f1:	e8 f5 fc ff ff       	call   8001eb <sys_page_unmap>
	return r;
  8004f6:	83 c4 10             	add    $0x10,%esp
  8004f9:	eb ba                	jmp    8004b5 <fd_close+0x3c>
			r = 0;
  8004fb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800500:	eb e9                	jmp    8004eb <fd_close+0x72>

00800502 <close>:

int
close(int fdnum)
{
  800502:	55                   	push   %ebp
  800503:	89 e5                	mov    %esp,%ebp
  800505:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800508:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80050b:	50                   	push   %eax
  80050c:	ff 75 08             	pushl  0x8(%ebp)
  80050f:	e8 b9 fe ff ff       	call   8003cd <fd_lookup>
  800514:	83 c4 08             	add    $0x8,%esp
  800517:	85 c0                	test   %eax,%eax
  800519:	78 10                	js     80052b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80051b:	83 ec 08             	sub    $0x8,%esp
  80051e:	6a 01                	push   $0x1
  800520:	ff 75 f4             	pushl  -0xc(%ebp)
  800523:	e8 51 ff ff ff       	call   800479 <fd_close>
  800528:	83 c4 10             	add    $0x10,%esp
}
  80052b:	c9                   	leave  
  80052c:	c3                   	ret    

0080052d <close_all>:

void
close_all(void)
{
  80052d:	55                   	push   %ebp
  80052e:	89 e5                	mov    %esp,%ebp
  800530:	53                   	push   %ebx
  800531:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800534:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800539:	83 ec 0c             	sub    $0xc,%esp
  80053c:	53                   	push   %ebx
  80053d:	e8 c0 ff ff ff       	call   800502 <close>
	for (i = 0; i < MAXFD; i++)
  800542:	83 c3 01             	add    $0x1,%ebx
  800545:	83 c4 10             	add    $0x10,%esp
  800548:	83 fb 20             	cmp    $0x20,%ebx
  80054b:	75 ec                	jne    800539 <close_all+0xc>
}
  80054d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800550:	c9                   	leave  
  800551:	c3                   	ret    

00800552 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800552:	55                   	push   %ebp
  800553:	89 e5                	mov    %esp,%ebp
  800555:	57                   	push   %edi
  800556:	56                   	push   %esi
  800557:	53                   	push   %ebx
  800558:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80055b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80055e:	50                   	push   %eax
  80055f:	ff 75 08             	pushl  0x8(%ebp)
  800562:	e8 66 fe ff ff       	call   8003cd <fd_lookup>
  800567:	89 c3                	mov    %eax,%ebx
  800569:	83 c4 08             	add    $0x8,%esp
  80056c:	85 c0                	test   %eax,%eax
  80056e:	0f 88 81 00 00 00    	js     8005f5 <dup+0xa3>
		return r;
	close(newfdnum);
  800574:	83 ec 0c             	sub    $0xc,%esp
  800577:	ff 75 0c             	pushl  0xc(%ebp)
  80057a:	e8 83 ff ff ff       	call   800502 <close>

	newfd = INDEX2FD(newfdnum);
  80057f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800582:	c1 e6 0c             	shl    $0xc,%esi
  800585:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80058b:	83 c4 04             	add    $0x4,%esp
  80058e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800591:	e8 d1 fd ff ff       	call   800367 <fd2data>
  800596:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800598:	89 34 24             	mov    %esi,(%esp)
  80059b:	e8 c7 fd ff ff       	call   800367 <fd2data>
  8005a0:	83 c4 10             	add    $0x10,%esp
  8005a3:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005a5:	89 d8                	mov    %ebx,%eax
  8005a7:	c1 e8 16             	shr    $0x16,%eax
  8005aa:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005b1:	a8 01                	test   $0x1,%al
  8005b3:	74 11                	je     8005c6 <dup+0x74>
  8005b5:	89 d8                	mov    %ebx,%eax
  8005b7:	c1 e8 0c             	shr    $0xc,%eax
  8005ba:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005c1:	f6 c2 01             	test   $0x1,%dl
  8005c4:	75 39                	jne    8005ff <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005c6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005c9:	89 d0                	mov    %edx,%eax
  8005cb:	c1 e8 0c             	shr    $0xc,%eax
  8005ce:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005d5:	83 ec 0c             	sub    $0xc,%esp
  8005d8:	25 07 0e 00 00       	and    $0xe07,%eax
  8005dd:	50                   	push   %eax
  8005de:	56                   	push   %esi
  8005df:	6a 00                	push   $0x0
  8005e1:	52                   	push   %edx
  8005e2:	6a 00                	push   $0x0
  8005e4:	e8 c0 fb ff ff       	call   8001a9 <sys_page_map>
  8005e9:	89 c3                	mov    %eax,%ebx
  8005eb:	83 c4 20             	add    $0x20,%esp
  8005ee:	85 c0                	test   %eax,%eax
  8005f0:	78 31                	js     800623 <dup+0xd1>
		goto err;

	return newfdnum;
  8005f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005f5:	89 d8                	mov    %ebx,%eax
  8005f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005fa:	5b                   	pop    %ebx
  8005fb:	5e                   	pop    %esi
  8005fc:	5f                   	pop    %edi
  8005fd:	5d                   	pop    %ebp
  8005fe:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005ff:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800606:	83 ec 0c             	sub    $0xc,%esp
  800609:	25 07 0e 00 00       	and    $0xe07,%eax
  80060e:	50                   	push   %eax
  80060f:	57                   	push   %edi
  800610:	6a 00                	push   $0x0
  800612:	53                   	push   %ebx
  800613:	6a 00                	push   $0x0
  800615:	e8 8f fb ff ff       	call   8001a9 <sys_page_map>
  80061a:	89 c3                	mov    %eax,%ebx
  80061c:	83 c4 20             	add    $0x20,%esp
  80061f:	85 c0                	test   %eax,%eax
  800621:	79 a3                	jns    8005c6 <dup+0x74>
	sys_page_unmap(0, newfd);
  800623:	83 ec 08             	sub    $0x8,%esp
  800626:	56                   	push   %esi
  800627:	6a 00                	push   $0x0
  800629:	e8 bd fb ff ff       	call   8001eb <sys_page_unmap>
	sys_page_unmap(0, nva);
  80062e:	83 c4 08             	add    $0x8,%esp
  800631:	57                   	push   %edi
  800632:	6a 00                	push   $0x0
  800634:	e8 b2 fb ff ff       	call   8001eb <sys_page_unmap>
	return r;
  800639:	83 c4 10             	add    $0x10,%esp
  80063c:	eb b7                	jmp    8005f5 <dup+0xa3>

0080063e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80063e:	55                   	push   %ebp
  80063f:	89 e5                	mov    %esp,%ebp
  800641:	53                   	push   %ebx
  800642:	83 ec 14             	sub    $0x14,%esp
  800645:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800648:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80064b:	50                   	push   %eax
  80064c:	53                   	push   %ebx
  80064d:	e8 7b fd ff ff       	call   8003cd <fd_lookup>
  800652:	83 c4 08             	add    $0x8,%esp
  800655:	85 c0                	test   %eax,%eax
  800657:	78 3f                	js     800698 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800659:	83 ec 08             	sub    $0x8,%esp
  80065c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80065f:	50                   	push   %eax
  800660:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800663:	ff 30                	pushl  (%eax)
  800665:	e8 b9 fd ff ff       	call   800423 <dev_lookup>
  80066a:	83 c4 10             	add    $0x10,%esp
  80066d:	85 c0                	test   %eax,%eax
  80066f:	78 27                	js     800698 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800671:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800674:	8b 42 08             	mov    0x8(%edx),%eax
  800677:	83 e0 03             	and    $0x3,%eax
  80067a:	83 f8 01             	cmp    $0x1,%eax
  80067d:	74 1e                	je     80069d <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80067f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800682:	8b 40 08             	mov    0x8(%eax),%eax
  800685:	85 c0                	test   %eax,%eax
  800687:	74 35                	je     8006be <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800689:	83 ec 04             	sub    $0x4,%esp
  80068c:	ff 75 10             	pushl  0x10(%ebp)
  80068f:	ff 75 0c             	pushl  0xc(%ebp)
  800692:	52                   	push   %edx
  800693:	ff d0                	call   *%eax
  800695:	83 c4 10             	add    $0x10,%esp
}
  800698:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80069b:	c9                   	leave  
  80069c:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80069d:	a1 04 40 80 00       	mov    0x804004,%eax
  8006a2:	8b 40 48             	mov    0x48(%eax),%eax
  8006a5:	83 ec 04             	sub    $0x4,%esp
  8006a8:	53                   	push   %ebx
  8006a9:	50                   	push   %eax
  8006aa:	68 3d 1e 80 00       	push   $0x801e3d
  8006af:	e8 2c 0a 00 00       	call   8010e0 <cprintf>
		return -E_INVAL;
  8006b4:	83 c4 10             	add    $0x10,%esp
  8006b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006bc:	eb da                	jmp    800698 <read+0x5a>
		return -E_NOT_SUPP;
  8006be:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8006c3:	eb d3                	jmp    800698 <read+0x5a>

008006c5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006c5:	55                   	push   %ebp
  8006c6:	89 e5                	mov    %esp,%ebp
  8006c8:	57                   	push   %edi
  8006c9:	56                   	push   %esi
  8006ca:	53                   	push   %ebx
  8006cb:	83 ec 0c             	sub    $0xc,%esp
  8006ce:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006d1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006d4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d9:	39 f3                	cmp    %esi,%ebx
  8006db:	73 25                	jae    800702 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006dd:	83 ec 04             	sub    $0x4,%esp
  8006e0:	89 f0                	mov    %esi,%eax
  8006e2:	29 d8                	sub    %ebx,%eax
  8006e4:	50                   	push   %eax
  8006e5:	89 d8                	mov    %ebx,%eax
  8006e7:	03 45 0c             	add    0xc(%ebp),%eax
  8006ea:	50                   	push   %eax
  8006eb:	57                   	push   %edi
  8006ec:	e8 4d ff ff ff       	call   80063e <read>
		if (m < 0)
  8006f1:	83 c4 10             	add    $0x10,%esp
  8006f4:	85 c0                	test   %eax,%eax
  8006f6:	78 08                	js     800700 <readn+0x3b>
			return m;
		if (m == 0)
  8006f8:	85 c0                	test   %eax,%eax
  8006fa:	74 06                	je     800702 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  8006fc:	01 c3                	add    %eax,%ebx
  8006fe:	eb d9                	jmp    8006d9 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800700:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  800702:	89 d8                	mov    %ebx,%eax
  800704:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800707:	5b                   	pop    %ebx
  800708:	5e                   	pop    %esi
  800709:	5f                   	pop    %edi
  80070a:	5d                   	pop    %ebp
  80070b:	c3                   	ret    

0080070c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80070c:	55                   	push   %ebp
  80070d:	89 e5                	mov    %esp,%ebp
  80070f:	53                   	push   %ebx
  800710:	83 ec 14             	sub    $0x14,%esp
  800713:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800716:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800719:	50                   	push   %eax
  80071a:	53                   	push   %ebx
  80071b:	e8 ad fc ff ff       	call   8003cd <fd_lookup>
  800720:	83 c4 08             	add    $0x8,%esp
  800723:	85 c0                	test   %eax,%eax
  800725:	78 3a                	js     800761 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800727:	83 ec 08             	sub    $0x8,%esp
  80072a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80072d:	50                   	push   %eax
  80072e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800731:	ff 30                	pushl  (%eax)
  800733:	e8 eb fc ff ff       	call   800423 <dev_lookup>
  800738:	83 c4 10             	add    $0x10,%esp
  80073b:	85 c0                	test   %eax,%eax
  80073d:	78 22                	js     800761 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80073f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800742:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800746:	74 1e                	je     800766 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800748:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80074b:	8b 52 0c             	mov    0xc(%edx),%edx
  80074e:	85 d2                	test   %edx,%edx
  800750:	74 35                	je     800787 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800752:	83 ec 04             	sub    $0x4,%esp
  800755:	ff 75 10             	pushl  0x10(%ebp)
  800758:	ff 75 0c             	pushl  0xc(%ebp)
  80075b:	50                   	push   %eax
  80075c:	ff d2                	call   *%edx
  80075e:	83 c4 10             	add    $0x10,%esp
}
  800761:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800764:	c9                   	leave  
  800765:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800766:	a1 04 40 80 00       	mov    0x804004,%eax
  80076b:	8b 40 48             	mov    0x48(%eax),%eax
  80076e:	83 ec 04             	sub    $0x4,%esp
  800771:	53                   	push   %ebx
  800772:	50                   	push   %eax
  800773:	68 59 1e 80 00       	push   $0x801e59
  800778:	e8 63 09 00 00       	call   8010e0 <cprintf>
		return -E_INVAL;
  80077d:	83 c4 10             	add    $0x10,%esp
  800780:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800785:	eb da                	jmp    800761 <write+0x55>
		return -E_NOT_SUPP;
  800787:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80078c:	eb d3                	jmp    800761 <write+0x55>

0080078e <seek>:

int
seek(int fdnum, off_t offset)
{
  80078e:	55                   	push   %ebp
  80078f:	89 e5                	mov    %esp,%ebp
  800791:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800794:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800797:	50                   	push   %eax
  800798:	ff 75 08             	pushl  0x8(%ebp)
  80079b:	e8 2d fc ff ff       	call   8003cd <fd_lookup>
  8007a0:	83 c4 08             	add    $0x8,%esp
  8007a3:	85 c0                	test   %eax,%eax
  8007a5:	78 0e                	js     8007b5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007ad:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007b0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007b5:	c9                   	leave  
  8007b6:	c3                   	ret    

008007b7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	53                   	push   %ebx
  8007bb:	83 ec 14             	sub    $0x14,%esp
  8007be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007c4:	50                   	push   %eax
  8007c5:	53                   	push   %ebx
  8007c6:	e8 02 fc ff ff       	call   8003cd <fd_lookup>
  8007cb:	83 c4 08             	add    $0x8,%esp
  8007ce:	85 c0                	test   %eax,%eax
  8007d0:	78 37                	js     800809 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007d2:	83 ec 08             	sub    $0x8,%esp
  8007d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d8:	50                   	push   %eax
  8007d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007dc:	ff 30                	pushl  (%eax)
  8007de:	e8 40 fc ff ff       	call   800423 <dev_lookup>
  8007e3:	83 c4 10             	add    $0x10,%esp
  8007e6:	85 c0                	test   %eax,%eax
  8007e8:	78 1f                	js     800809 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ed:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007f1:	74 1b                	je     80080e <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8007f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007f6:	8b 52 18             	mov    0x18(%edx),%edx
  8007f9:	85 d2                	test   %edx,%edx
  8007fb:	74 32                	je     80082f <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8007fd:	83 ec 08             	sub    $0x8,%esp
  800800:	ff 75 0c             	pushl  0xc(%ebp)
  800803:	50                   	push   %eax
  800804:	ff d2                	call   *%edx
  800806:	83 c4 10             	add    $0x10,%esp
}
  800809:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80080c:	c9                   	leave  
  80080d:	c3                   	ret    
			thisenv->env_id, fdnum);
  80080e:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800813:	8b 40 48             	mov    0x48(%eax),%eax
  800816:	83 ec 04             	sub    $0x4,%esp
  800819:	53                   	push   %ebx
  80081a:	50                   	push   %eax
  80081b:	68 1c 1e 80 00       	push   $0x801e1c
  800820:	e8 bb 08 00 00       	call   8010e0 <cprintf>
		return -E_INVAL;
  800825:	83 c4 10             	add    $0x10,%esp
  800828:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80082d:	eb da                	jmp    800809 <ftruncate+0x52>
		return -E_NOT_SUPP;
  80082f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800834:	eb d3                	jmp    800809 <ftruncate+0x52>

00800836 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800836:	55                   	push   %ebp
  800837:	89 e5                	mov    %esp,%ebp
  800839:	53                   	push   %ebx
  80083a:	83 ec 14             	sub    $0x14,%esp
  80083d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800840:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800843:	50                   	push   %eax
  800844:	ff 75 08             	pushl  0x8(%ebp)
  800847:	e8 81 fb ff ff       	call   8003cd <fd_lookup>
  80084c:	83 c4 08             	add    $0x8,%esp
  80084f:	85 c0                	test   %eax,%eax
  800851:	78 4b                	js     80089e <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800853:	83 ec 08             	sub    $0x8,%esp
  800856:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800859:	50                   	push   %eax
  80085a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80085d:	ff 30                	pushl  (%eax)
  80085f:	e8 bf fb ff ff       	call   800423 <dev_lookup>
  800864:	83 c4 10             	add    $0x10,%esp
  800867:	85 c0                	test   %eax,%eax
  800869:	78 33                	js     80089e <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  80086b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80086e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800872:	74 2f                	je     8008a3 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800874:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800877:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80087e:	00 00 00 
	stat->st_isdir = 0;
  800881:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800888:	00 00 00 
	stat->st_dev = dev;
  80088b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800891:	83 ec 08             	sub    $0x8,%esp
  800894:	53                   	push   %ebx
  800895:	ff 75 f0             	pushl  -0x10(%ebp)
  800898:	ff 50 14             	call   *0x14(%eax)
  80089b:	83 c4 10             	add    $0x10,%esp
}
  80089e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008a1:	c9                   	leave  
  8008a2:	c3                   	ret    
		return -E_NOT_SUPP;
  8008a3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8008a8:	eb f4                	jmp    80089e <fstat+0x68>

008008aa <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	56                   	push   %esi
  8008ae:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008af:	83 ec 08             	sub    $0x8,%esp
  8008b2:	6a 00                	push   $0x0
  8008b4:	ff 75 08             	pushl  0x8(%ebp)
  8008b7:	e8 da 01 00 00       	call   800a96 <open>
  8008bc:	89 c3                	mov    %eax,%ebx
  8008be:	83 c4 10             	add    $0x10,%esp
  8008c1:	85 c0                	test   %eax,%eax
  8008c3:	78 1b                	js     8008e0 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008c5:	83 ec 08             	sub    $0x8,%esp
  8008c8:	ff 75 0c             	pushl  0xc(%ebp)
  8008cb:	50                   	push   %eax
  8008cc:	e8 65 ff ff ff       	call   800836 <fstat>
  8008d1:	89 c6                	mov    %eax,%esi
	close(fd);
  8008d3:	89 1c 24             	mov    %ebx,(%esp)
  8008d6:	e8 27 fc ff ff       	call   800502 <close>
	return r;
  8008db:	83 c4 10             	add    $0x10,%esp
  8008de:	89 f3                	mov    %esi,%ebx
}
  8008e0:	89 d8                	mov    %ebx,%eax
  8008e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008e5:	5b                   	pop    %ebx
  8008e6:	5e                   	pop    %esi
  8008e7:	5d                   	pop    %ebp
  8008e8:	c3                   	ret    

008008e9 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008e9:	55                   	push   %ebp
  8008ea:	89 e5                	mov    %esp,%ebp
  8008ec:	56                   	push   %esi
  8008ed:	53                   	push   %ebx
  8008ee:	89 c6                	mov    %eax,%esi
  8008f0:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008f2:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8008f9:	74 27                	je     800922 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008fb:	6a 07                	push   $0x7
  8008fd:	68 00 50 80 00       	push   $0x805000
  800902:	56                   	push   %esi
  800903:	ff 35 00 40 80 00    	pushl  0x804000
  800909:	e8 95 11 00 00       	call   801aa3 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80090e:	83 c4 0c             	add    $0xc,%esp
  800911:	6a 00                	push   $0x0
  800913:	53                   	push   %ebx
  800914:	6a 00                	push   $0x0
  800916:	e8 21 11 00 00       	call   801a3c <ipc_recv>
}
  80091b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80091e:	5b                   	pop    %ebx
  80091f:	5e                   	pop    %esi
  800920:	5d                   	pop    %ebp
  800921:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800922:	83 ec 0c             	sub    $0xc,%esp
  800925:	6a 01                	push   $0x1
  800927:	e8 cb 11 00 00       	call   801af7 <ipc_find_env>
  80092c:	a3 00 40 80 00       	mov    %eax,0x804000
  800931:	83 c4 10             	add    $0x10,%esp
  800934:	eb c5                	jmp    8008fb <fsipc+0x12>

00800936 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80093c:	8b 45 08             	mov    0x8(%ebp),%eax
  80093f:	8b 40 0c             	mov    0xc(%eax),%eax
  800942:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800947:	8b 45 0c             	mov    0xc(%ebp),%eax
  80094a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80094f:	ba 00 00 00 00       	mov    $0x0,%edx
  800954:	b8 02 00 00 00       	mov    $0x2,%eax
  800959:	e8 8b ff ff ff       	call   8008e9 <fsipc>
}
  80095e:	c9                   	leave  
  80095f:	c3                   	ret    

00800960 <devfile_flush>:
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800966:	8b 45 08             	mov    0x8(%ebp),%eax
  800969:	8b 40 0c             	mov    0xc(%eax),%eax
  80096c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800971:	ba 00 00 00 00       	mov    $0x0,%edx
  800976:	b8 06 00 00 00       	mov    $0x6,%eax
  80097b:	e8 69 ff ff ff       	call   8008e9 <fsipc>
}
  800980:	c9                   	leave  
  800981:	c3                   	ret    

00800982 <devfile_stat>:
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	53                   	push   %ebx
  800986:	83 ec 04             	sub    $0x4,%esp
  800989:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80098c:	8b 45 08             	mov    0x8(%ebp),%eax
  80098f:	8b 40 0c             	mov    0xc(%eax),%eax
  800992:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800997:	ba 00 00 00 00       	mov    $0x0,%edx
  80099c:	b8 05 00 00 00       	mov    $0x5,%eax
  8009a1:	e8 43 ff ff ff       	call   8008e9 <fsipc>
  8009a6:	85 c0                	test   %eax,%eax
  8009a8:	78 2c                	js     8009d6 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009aa:	83 ec 08             	sub    $0x8,%esp
  8009ad:	68 00 50 80 00       	push   $0x805000
  8009b2:	53                   	push   %ebx
  8009b3:	e8 47 0d 00 00       	call   8016ff <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009b8:	a1 80 50 80 00       	mov    0x805080,%eax
  8009bd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009c3:	a1 84 50 80 00       	mov    0x805084,%eax
  8009c8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009ce:	83 c4 10             	add    $0x10,%esp
  8009d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009d9:	c9                   	leave  
  8009da:	c3                   	ret    

008009db <devfile_write>:
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	83 ec 0c             	sub    $0xc,%esp
  8009e1:	8b 45 10             	mov    0x10(%ebp),%eax
    	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8009e7:	8b 52 0c             	mov    0xc(%edx),%edx
  8009ea:	89 15 00 50 80 00    	mov    %edx,0x805000
    	fsipcbuf.write.req_n = n;
  8009f0:	a3 04 50 80 00       	mov    %eax,0x805004
    	memmove(fsipcbuf.write.req_buf, buf, n);
  8009f5:	50                   	push   %eax
  8009f6:	ff 75 0c             	pushl  0xc(%ebp)
  8009f9:	68 08 50 80 00       	push   $0x805008
  8009fe:	e8 8a 0e 00 00       	call   80188d <memmove>
    	return fsipc(FSREQ_WRITE, NULL);
  800a03:	ba 00 00 00 00       	mov    $0x0,%edx
  800a08:	b8 04 00 00 00       	mov    $0x4,%eax
  800a0d:	e8 d7 fe ff ff       	call   8008e9 <fsipc>
}
  800a12:	c9                   	leave  
  800a13:	c3                   	ret    

00800a14 <devfile_read>:
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	56                   	push   %esi
  800a18:	53                   	push   %ebx
  800a19:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1f:	8b 40 0c             	mov    0xc(%eax),%eax
  800a22:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a27:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a2d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a32:	b8 03 00 00 00       	mov    $0x3,%eax
  800a37:	e8 ad fe ff ff       	call   8008e9 <fsipc>
  800a3c:	89 c3                	mov    %eax,%ebx
  800a3e:	85 c0                	test   %eax,%eax
  800a40:	78 1f                	js     800a61 <devfile_read+0x4d>
	assert(r <= n);
  800a42:	39 f0                	cmp    %esi,%eax
  800a44:	77 24                	ja     800a6a <devfile_read+0x56>
	assert(r <= PGSIZE);
  800a46:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a4b:	7f 33                	jg     800a80 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a4d:	83 ec 04             	sub    $0x4,%esp
  800a50:	50                   	push   %eax
  800a51:	68 00 50 80 00       	push   $0x805000
  800a56:	ff 75 0c             	pushl  0xc(%ebp)
  800a59:	e8 2f 0e 00 00       	call   80188d <memmove>
	return r;
  800a5e:	83 c4 10             	add    $0x10,%esp
}
  800a61:	89 d8                	mov    %ebx,%eax
  800a63:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a66:	5b                   	pop    %ebx
  800a67:	5e                   	pop    %esi
  800a68:	5d                   	pop    %ebp
  800a69:	c3                   	ret    
	assert(r <= n);
  800a6a:	68 88 1e 80 00       	push   $0x801e88
  800a6f:	68 8f 1e 80 00       	push   $0x801e8f
  800a74:	6a 7c                	push   $0x7c
  800a76:	68 a4 1e 80 00       	push   $0x801ea4
  800a7b:	e8 85 05 00 00       	call   801005 <_panic>
	assert(r <= PGSIZE);
  800a80:	68 af 1e 80 00       	push   $0x801eaf
  800a85:	68 8f 1e 80 00       	push   $0x801e8f
  800a8a:	6a 7d                	push   $0x7d
  800a8c:	68 a4 1e 80 00       	push   $0x801ea4
  800a91:	e8 6f 05 00 00       	call   801005 <_panic>

00800a96 <open>:
{
  800a96:	55                   	push   %ebp
  800a97:	89 e5                	mov    %esp,%ebp
  800a99:	56                   	push   %esi
  800a9a:	53                   	push   %ebx
  800a9b:	83 ec 1c             	sub    $0x1c,%esp
  800a9e:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800aa1:	56                   	push   %esi
  800aa2:	e8 21 0c 00 00       	call   8016c8 <strlen>
  800aa7:	83 c4 10             	add    $0x10,%esp
  800aaa:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800aaf:	7f 6c                	jg     800b1d <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  800ab1:	83 ec 0c             	sub    $0xc,%esp
  800ab4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ab7:	50                   	push   %eax
  800ab8:	e8 c1 f8 ff ff       	call   80037e <fd_alloc>
  800abd:	89 c3                	mov    %eax,%ebx
  800abf:	83 c4 10             	add    $0x10,%esp
  800ac2:	85 c0                	test   %eax,%eax
  800ac4:	78 3c                	js     800b02 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  800ac6:	83 ec 08             	sub    $0x8,%esp
  800ac9:	56                   	push   %esi
  800aca:	68 00 50 80 00       	push   $0x805000
  800acf:	e8 2b 0c 00 00       	call   8016ff <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ad4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad7:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800adc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800adf:	b8 01 00 00 00       	mov    $0x1,%eax
  800ae4:	e8 00 fe ff ff       	call   8008e9 <fsipc>
  800ae9:	89 c3                	mov    %eax,%ebx
  800aeb:	83 c4 10             	add    $0x10,%esp
  800aee:	85 c0                	test   %eax,%eax
  800af0:	78 19                	js     800b0b <open+0x75>
	return fd2num(fd);
  800af2:	83 ec 0c             	sub    $0xc,%esp
  800af5:	ff 75 f4             	pushl  -0xc(%ebp)
  800af8:	e8 5a f8 ff ff       	call   800357 <fd2num>
  800afd:	89 c3                	mov    %eax,%ebx
  800aff:	83 c4 10             	add    $0x10,%esp
}
  800b02:	89 d8                	mov    %ebx,%eax
  800b04:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b07:	5b                   	pop    %ebx
  800b08:	5e                   	pop    %esi
  800b09:	5d                   	pop    %ebp
  800b0a:	c3                   	ret    
		fd_close(fd, 0);
  800b0b:	83 ec 08             	sub    $0x8,%esp
  800b0e:	6a 00                	push   $0x0
  800b10:	ff 75 f4             	pushl  -0xc(%ebp)
  800b13:	e8 61 f9 ff ff       	call   800479 <fd_close>
		return r;
  800b18:	83 c4 10             	add    $0x10,%esp
  800b1b:	eb e5                	jmp    800b02 <open+0x6c>
		return -E_BAD_PATH;
  800b1d:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b22:	eb de                	jmp    800b02 <open+0x6c>

00800b24 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2f:	b8 08 00 00 00       	mov    $0x8,%eax
  800b34:	e8 b0 fd ff ff       	call   8008e9 <fsipc>
}
  800b39:	c9                   	leave  
  800b3a:	c3                   	ret    

00800b3b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	56                   	push   %esi
  800b3f:	53                   	push   %ebx
  800b40:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b43:	83 ec 0c             	sub    $0xc,%esp
  800b46:	ff 75 08             	pushl  0x8(%ebp)
  800b49:	e8 19 f8 ff ff       	call   800367 <fd2data>
  800b4e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b50:	83 c4 08             	add    $0x8,%esp
  800b53:	68 bb 1e 80 00       	push   $0x801ebb
  800b58:	53                   	push   %ebx
  800b59:	e8 a1 0b 00 00       	call   8016ff <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b5e:	8b 46 04             	mov    0x4(%esi),%eax
  800b61:	2b 06                	sub    (%esi),%eax
  800b63:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b69:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b70:	00 00 00 
	stat->st_dev = &devpipe;
  800b73:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b7a:	30 80 00 
	return 0;
}
  800b7d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b82:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b85:	5b                   	pop    %ebx
  800b86:	5e                   	pop    %esi
  800b87:	5d                   	pop    %ebp
  800b88:	c3                   	ret    

00800b89 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b89:	55                   	push   %ebp
  800b8a:	89 e5                	mov    %esp,%ebp
  800b8c:	53                   	push   %ebx
  800b8d:	83 ec 0c             	sub    $0xc,%esp
  800b90:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b93:	53                   	push   %ebx
  800b94:	6a 00                	push   $0x0
  800b96:	e8 50 f6 ff ff       	call   8001eb <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b9b:	89 1c 24             	mov    %ebx,(%esp)
  800b9e:	e8 c4 f7 ff ff       	call   800367 <fd2data>
  800ba3:	83 c4 08             	add    $0x8,%esp
  800ba6:	50                   	push   %eax
  800ba7:	6a 00                	push   $0x0
  800ba9:	e8 3d f6 ff ff       	call   8001eb <sys_page_unmap>
}
  800bae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bb1:	c9                   	leave  
  800bb2:	c3                   	ret    

00800bb3 <_pipeisclosed>:
{
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	57                   	push   %edi
  800bb7:	56                   	push   %esi
  800bb8:	53                   	push   %ebx
  800bb9:	83 ec 1c             	sub    $0x1c,%esp
  800bbc:	89 c7                	mov    %eax,%edi
  800bbe:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800bc0:	a1 04 40 80 00       	mov    0x804004,%eax
  800bc5:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800bc8:	83 ec 0c             	sub    $0xc,%esp
  800bcb:	57                   	push   %edi
  800bcc:	e8 5f 0f 00 00       	call   801b30 <pageref>
  800bd1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800bd4:	89 34 24             	mov    %esi,(%esp)
  800bd7:	e8 54 0f 00 00       	call   801b30 <pageref>
		nn = thisenv->env_runs;
  800bdc:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800be2:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800be5:	83 c4 10             	add    $0x10,%esp
  800be8:	39 cb                	cmp    %ecx,%ebx
  800bea:	74 1b                	je     800c07 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800bec:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800bef:	75 cf                	jne    800bc0 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800bf1:	8b 42 58             	mov    0x58(%edx),%eax
  800bf4:	6a 01                	push   $0x1
  800bf6:	50                   	push   %eax
  800bf7:	53                   	push   %ebx
  800bf8:	68 c2 1e 80 00       	push   $0x801ec2
  800bfd:	e8 de 04 00 00       	call   8010e0 <cprintf>
  800c02:	83 c4 10             	add    $0x10,%esp
  800c05:	eb b9                	jmp    800bc0 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800c07:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c0a:	0f 94 c0             	sete   %al
  800c0d:	0f b6 c0             	movzbl %al,%eax
}
  800c10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c13:	5b                   	pop    %ebx
  800c14:	5e                   	pop    %esi
  800c15:	5f                   	pop    %edi
  800c16:	5d                   	pop    %ebp
  800c17:	c3                   	ret    

00800c18 <devpipe_write>:
{
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
  800c1b:	57                   	push   %edi
  800c1c:	56                   	push   %esi
  800c1d:	53                   	push   %ebx
  800c1e:	83 ec 28             	sub    $0x28,%esp
  800c21:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800c24:	56                   	push   %esi
  800c25:	e8 3d f7 ff ff       	call   800367 <fd2data>
  800c2a:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c2c:	83 c4 10             	add    $0x10,%esp
  800c2f:	bf 00 00 00 00       	mov    $0x0,%edi
  800c34:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c37:	74 4f                	je     800c88 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c39:	8b 43 04             	mov    0x4(%ebx),%eax
  800c3c:	8b 0b                	mov    (%ebx),%ecx
  800c3e:	8d 51 20             	lea    0x20(%ecx),%edx
  800c41:	39 d0                	cmp    %edx,%eax
  800c43:	72 14                	jb     800c59 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  800c45:	89 da                	mov    %ebx,%edx
  800c47:	89 f0                	mov    %esi,%eax
  800c49:	e8 65 ff ff ff       	call   800bb3 <_pipeisclosed>
  800c4e:	85 c0                	test   %eax,%eax
  800c50:	75 3a                	jne    800c8c <devpipe_write+0x74>
			sys_yield();
  800c52:	e8 f0 f4 ff ff       	call   800147 <sys_yield>
  800c57:	eb e0                	jmp    800c39 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c60:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c63:	89 c2                	mov    %eax,%edx
  800c65:	c1 fa 1f             	sar    $0x1f,%edx
  800c68:	89 d1                	mov    %edx,%ecx
  800c6a:	c1 e9 1b             	shr    $0x1b,%ecx
  800c6d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c70:	83 e2 1f             	and    $0x1f,%edx
  800c73:	29 ca                	sub    %ecx,%edx
  800c75:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c79:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c7d:	83 c0 01             	add    $0x1,%eax
  800c80:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800c83:	83 c7 01             	add    $0x1,%edi
  800c86:	eb ac                	jmp    800c34 <devpipe_write+0x1c>
	return i;
  800c88:	89 f8                	mov    %edi,%eax
  800c8a:	eb 05                	jmp    800c91 <devpipe_write+0x79>
				return 0;
  800c8c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c94:	5b                   	pop    %ebx
  800c95:	5e                   	pop    %esi
  800c96:	5f                   	pop    %edi
  800c97:	5d                   	pop    %ebp
  800c98:	c3                   	ret    

00800c99 <devpipe_read>:
{
  800c99:	55                   	push   %ebp
  800c9a:	89 e5                	mov    %esp,%ebp
  800c9c:	57                   	push   %edi
  800c9d:	56                   	push   %esi
  800c9e:	53                   	push   %ebx
  800c9f:	83 ec 18             	sub    $0x18,%esp
  800ca2:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800ca5:	57                   	push   %edi
  800ca6:	e8 bc f6 ff ff       	call   800367 <fd2data>
  800cab:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800cad:	83 c4 10             	add    $0x10,%esp
  800cb0:	be 00 00 00 00       	mov    $0x0,%esi
  800cb5:	3b 75 10             	cmp    0x10(%ebp),%esi
  800cb8:	74 47                	je     800d01 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  800cba:	8b 03                	mov    (%ebx),%eax
  800cbc:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cbf:	75 22                	jne    800ce3 <devpipe_read+0x4a>
			if (i > 0)
  800cc1:	85 f6                	test   %esi,%esi
  800cc3:	75 14                	jne    800cd9 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  800cc5:	89 da                	mov    %ebx,%edx
  800cc7:	89 f8                	mov    %edi,%eax
  800cc9:	e8 e5 fe ff ff       	call   800bb3 <_pipeisclosed>
  800cce:	85 c0                	test   %eax,%eax
  800cd0:	75 33                	jne    800d05 <devpipe_read+0x6c>
			sys_yield();
  800cd2:	e8 70 f4 ff ff       	call   800147 <sys_yield>
  800cd7:	eb e1                	jmp    800cba <devpipe_read+0x21>
				return i;
  800cd9:	89 f0                	mov    %esi,%eax
}
  800cdb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cde:	5b                   	pop    %ebx
  800cdf:	5e                   	pop    %esi
  800ce0:	5f                   	pop    %edi
  800ce1:	5d                   	pop    %ebp
  800ce2:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800ce3:	99                   	cltd   
  800ce4:	c1 ea 1b             	shr    $0x1b,%edx
  800ce7:	01 d0                	add    %edx,%eax
  800ce9:	83 e0 1f             	and    $0x1f,%eax
  800cec:	29 d0                	sub    %edx,%eax
  800cee:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800cf3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf6:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800cf9:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800cfc:	83 c6 01             	add    $0x1,%esi
  800cff:	eb b4                	jmp    800cb5 <devpipe_read+0x1c>
	return i;
  800d01:	89 f0                	mov    %esi,%eax
  800d03:	eb d6                	jmp    800cdb <devpipe_read+0x42>
				return 0;
  800d05:	b8 00 00 00 00       	mov    $0x0,%eax
  800d0a:	eb cf                	jmp    800cdb <devpipe_read+0x42>

00800d0c <pipe>:
{
  800d0c:	55                   	push   %ebp
  800d0d:	89 e5                	mov    %esp,%ebp
  800d0f:	56                   	push   %esi
  800d10:	53                   	push   %ebx
  800d11:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800d14:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d17:	50                   	push   %eax
  800d18:	e8 61 f6 ff ff       	call   80037e <fd_alloc>
  800d1d:	89 c3                	mov    %eax,%ebx
  800d1f:	83 c4 10             	add    $0x10,%esp
  800d22:	85 c0                	test   %eax,%eax
  800d24:	78 5b                	js     800d81 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d26:	83 ec 04             	sub    $0x4,%esp
  800d29:	68 07 04 00 00       	push   $0x407
  800d2e:	ff 75 f4             	pushl  -0xc(%ebp)
  800d31:	6a 00                	push   $0x0
  800d33:	e8 2e f4 ff ff       	call   800166 <sys_page_alloc>
  800d38:	89 c3                	mov    %eax,%ebx
  800d3a:	83 c4 10             	add    $0x10,%esp
  800d3d:	85 c0                	test   %eax,%eax
  800d3f:	78 40                	js     800d81 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  800d41:	83 ec 0c             	sub    $0xc,%esp
  800d44:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d47:	50                   	push   %eax
  800d48:	e8 31 f6 ff ff       	call   80037e <fd_alloc>
  800d4d:	89 c3                	mov    %eax,%ebx
  800d4f:	83 c4 10             	add    $0x10,%esp
  800d52:	85 c0                	test   %eax,%eax
  800d54:	78 1b                	js     800d71 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d56:	83 ec 04             	sub    $0x4,%esp
  800d59:	68 07 04 00 00       	push   $0x407
  800d5e:	ff 75 f0             	pushl  -0x10(%ebp)
  800d61:	6a 00                	push   $0x0
  800d63:	e8 fe f3 ff ff       	call   800166 <sys_page_alloc>
  800d68:	89 c3                	mov    %eax,%ebx
  800d6a:	83 c4 10             	add    $0x10,%esp
  800d6d:	85 c0                	test   %eax,%eax
  800d6f:	79 19                	jns    800d8a <pipe+0x7e>
	sys_page_unmap(0, fd0);
  800d71:	83 ec 08             	sub    $0x8,%esp
  800d74:	ff 75 f4             	pushl  -0xc(%ebp)
  800d77:	6a 00                	push   $0x0
  800d79:	e8 6d f4 ff ff       	call   8001eb <sys_page_unmap>
  800d7e:	83 c4 10             	add    $0x10,%esp
}
  800d81:	89 d8                	mov    %ebx,%eax
  800d83:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d86:	5b                   	pop    %ebx
  800d87:	5e                   	pop    %esi
  800d88:	5d                   	pop    %ebp
  800d89:	c3                   	ret    
	va = fd2data(fd0);
  800d8a:	83 ec 0c             	sub    $0xc,%esp
  800d8d:	ff 75 f4             	pushl  -0xc(%ebp)
  800d90:	e8 d2 f5 ff ff       	call   800367 <fd2data>
  800d95:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d97:	83 c4 0c             	add    $0xc,%esp
  800d9a:	68 07 04 00 00       	push   $0x407
  800d9f:	50                   	push   %eax
  800da0:	6a 00                	push   $0x0
  800da2:	e8 bf f3 ff ff       	call   800166 <sys_page_alloc>
  800da7:	89 c3                	mov    %eax,%ebx
  800da9:	83 c4 10             	add    $0x10,%esp
  800dac:	85 c0                	test   %eax,%eax
  800dae:	0f 88 8c 00 00 00    	js     800e40 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800db4:	83 ec 0c             	sub    $0xc,%esp
  800db7:	ff 75 f0             	pushl  -0x10(%ebp)
  800dba:	e8 a8 f5 ff ff       	call   800367 <fd2data>
  800dbf:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dc6:	50                   	push   %eax
  800dc7:	6a 00                	push   $0x0
  800dc9:	56                   	push   %esi
  800dca:	6a 00                	push   $0x0
  800dcc:	e8 d8 f3 ff ff       	call   8001a9 <sys_page_map>
  800dd1:	89 c3                	mov    %eax,%ebx
  800dd3:	83 c4 20             	add    $0x20,%esp
  800dd6:	85 c0                	test   %eax,%eax
  800dd8:	78 58                	js     800e32 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  800dda:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ddd:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800de3:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800de5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800de8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  800def:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800df2:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800df8:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800dfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dfd:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800e04:	83 ec 0c             	sub    $0xc,%esp
  800e07:	ff 75 f4             	pushl  -0xc(%ebp)
  800e0a:	e8 48 f5 ff ff       	call   800357 <fd2num>
  800e0f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e12:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e14:	83 c4 04             	add    $0x4,%esp
  800e17:	ff 75 f0             	pushl  -0x10(%ebp)
  800e1a:	e8 38 f5 ff ff       	call   800357 <fd2num>
  800e1f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e22:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e25:	83 c4 10             	add    $0x10,%esp
  800e28:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e2d:	e9 4f ff ff ff       	jmp    800d81 <pipe+0x75>
	sys_page_unmap(0, va);
  800e32:	83 ec 08             	sub    $0x8,%esp
  800e35:	56                   	push   %esi
  800e36:	6a 00                	push   $0x0
  800e38:	e8 ae f3 ff ff       	call   8001eb <sys_page_unmap>
  800e3d:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800e40:	83 ec 08             	sub    $0x8,%esp
  800e43:	ff 75 f0             	pushl  -0x10(%ebp)
  800e46:	6a 00                	push   $0x0
  800e48:	e8 9e f3 ff ff       	call   8001eb <sys_page_unmap>
  800e4d:	83 c4 10             	add    $0x10,%esp
  800e50:	e9 1c ff ff ff       	jmp    800d71 <pipe+0x65>

00800e55 <pipeisclosed>:
{
  800e55:	55                   	push   %ebp
  800e56:	89 e5                	mov    %esp,%ebp
  800e58:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e5b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e5e:	50                   	push   %eax
  800e5f:	ff 75 08             	pushl  0x8(%ebp)
  800e62:	e8 66 f5 ff ff       	call   8003cd <fd_lookup>
  800e67:	83 c4 10             	add    $0x10,%esp
  800e6a:	85 c0                	test   %eax,%eax
  800e6c:	78 18                	js     800e86 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  800e6e:	83 ec 0c             	sub    $0xc,%esp
  800e71:	ff 75 f4             	pushl  -0xc(%ebp)
  800e74:	e8 ee f4 ff ff       	call   800367 <fd2data>
	return _pipeisclosed(fd, p);
  800e79:	89 c2                	mov    %eax,%edx
  800e7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e7e:	e8 30 fd ff ff       	call   800bb3 <_pipeisclosed>
  800e83:	83 c4 10             	add    $0x10,%esp
}
  800e86:	c9                   	leave  
  800e87:	c3                   	ret    

00800e88 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e88:	55                   	push   %ebp
  800e89:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e8b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e90:	5d                   	pop    %ebp
  800e91:	c3                   	ret    

00800e92 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e92:	55                   	push   %ebp
  800e93:	89 e5                	mov    %esp,%ebp
  800e95:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e98:	68 da 1e 80 00       	push   $0x801eda
  800e9d:	ff 75 0c             	pushl  0xc(%ebp)
  800ea0:	e8 5a 08 00 00       	call   8016ff <strcpy>
	return 0;
}
  800ea5:	b8 00 00 00 00       	mov    $0x0,%eax
  800eaa:	c9                   	leave  
  800eab:	c3                   	ret    

00800eac <devcons_write>:
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	57                   	push   %edi
  800eb0:	56                   	push   %esi
  800eb1:	53                   	push   %ebx
  800eb2:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800eb8:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800ebd:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800ec3:	eb 2f                	jmp    800ef4 <devcons_write+0x48>
		m = n - tot;
  800ec5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ec8:	29 f3                	sub    %esi,%ebx
  800eca:	83 fb 7f             	cmp    $0x7f,%ebx
  800ecd:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800ed2:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800ed5:	83 ec 04             	sub    $0x4,%esp
  800ed8:	53                   	push   %ebx
  800ed9:	89 f0                	mov    %esi,%eax
  800edb:	03 45 0c             	add    0xc(%ebp),%eax
  800ede:	50                   	push   %eax
  800edf:	57                   	push   %edi
  800ee0:	e8 a8 09 00 00       	call   80188d <memmove>
		sys_cputs(buf, m);
  800ee5:	83 c4 08             	add    $0x8,%esp
  800ee8:	53                   	push   %ebx
  800ee9:	57                   	push   %edi
  800eea:	e8 bb f1 ff ff       	call   8000aa <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800eef:	01 de                	add    %ebx,%esi
  800ef1:	83 c4 10             	add    $0x10,%esp
  800ef4:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ef7:	72 cc                	jb     800ec5 <devcons_write+0x19>
}
  800ef9:	89 f0                	mov    %esi,%eax
  800efb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800efe:	5b                   	pop    %ebx
  800eff:	5e                   	pop    %esi
  800f00:	5f                   	pop    %edi
  800f01:	5d                   	pop    %ebp
  800f02:	c3                   	ret    

00800f03 <devcons_read>:
{
  800f03:	55                   	push   %ebp
  800f04:	89 e5                	mov    %esp,%ebp
  800f06:	83 ec 08             	sub    $0x8,%esp
  800f09:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800f0e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f12:	75 07                	jne    800f1b <devcons_read+0x18>
}
  800f14:	c9                   	leave  
  800f15:	c3                   	ret    
		sys_yield();
  800f16:	e8 2c f2 ff ff       	call   800147 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  800f1b:	e8 a8 f1 ff ff       	call   8000c8 <sys_cgetc>
  800f20:	85 c0                	test   %eax,%eax
  800f22:	74 f2                	je     800f16 <devcons_read+0x13>
	if (c < 0)
  800f24:	85 c0                	test   %eax,%eax
  800f26:	78 ec                	js     800f14 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  800f28:	83 f8 04             	cmp    $0x4,%eax
  800f2b:	74 0c                	je     800f39 <devcons_read+0x36>
	*(char*)vbuf = c;
  800f2d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f30:	88 02                	mov    %al,(%edx)
	return 1;
  800f32:	b8 01 00 00 00       	mov    $0x1,%eax
  800f37:	eb db                	jmp    800f14 <devcons_read+0x11>
		return 0;
  800f39:	b8 00 00 00 00       	mov    $0x0,%eax
  800f3e:	eb d4                	jmp    800f14 <devcons_read+0x11>

00800f40 <cputchar>:
{
  800f40:	55                   	push   %ebp
  800f41:	89 e5                	mov    %esp,%ebp
  800f43:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f46:	8b 45 08             	mov    0x8(%ebp),%eax
  800f49:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800f4c:	6a 01                	push   $0x1
  800f4e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f51:	50                   	push   %eax
  800f52:	e8 53 f1 ff ff       	call   8000aa <sys_cputs>
}
  800f57:	83 c4 10             	add    $0x10,%esp
  800f5a:	c9                   	leave  
  800f5b:	c3                   	ret    

00800f5c <getchar>:
{
  800f5c:	55                   	push   %ebp
  800f5d:	89 e5                	mov    %esp,%ebp
  800f5f:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800f62:	6a 01                	push   $0x1
  800f64:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f67:	50                   	push   %eax
  800f68:	6a 00                	push   $0x0
  800f6a:	e8 cf f6 ff ff       	call   80063e <read>
	if (r < 0)
  800f6f:	83 c4 10             	add    $0x10,%esp
  800f72:	85 c0                	test   %eax,%eax
  800f74:	78 08                	js     800f7e <getchar+0x22>
	if (r < 1)
  800f76:	85 c0                	test   %eax,%eax
  800f78:	7e 06                	jle    800f80 <getchar+0x24>
	return c;
  800f7a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800f7e:	c9                   	leave  
  800f7f:	c3                   	ret    
		return -E_EOF;
  800f80:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800f85:	eb f7                	jmp    800f7e <getchar+0x22>

00800f87 <iscons>:
{
  800f87:	55                   	push   %ebp
  800f88:	89 e5                	mov    %esp,%ebp
  800f8a:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f8d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f90:	50                   	push   %eax
  800f91:	ff 75 08             	pushl  0x8(%ebp)
  800f94:	e8 34 f4 ff ff       	call   8003cd <fd_lookup>
  800f99:	83 c4 10             	add    $0x10,%esp
  800f9c:	85 c0                	test   %eax,%eax
  800f9e:	78 11                	js     800fb1 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  800fa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fa3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fa9:	39 10                	cmp    %edx,(%eax)
  800fab:	0f 94 c0             	sete   %al
  800fae:	0f b6 c0             	movzbl %al,%eax
}
  800fb1:	c9                   	leave  
  800fb2:	c3                   	ret    

00800fb3 <opencons>:
{
  800fb3:	55                   	push   %ebp
  800fb4:	89 e5                	mov    %esp,%ebp
  800fb6:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800fb9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fbc:	50                   	push   %eax
  800fbd:	e8 bc f3 ff ff       	call   80037e <fd_alloc>
  800fc2:	83 c4 10             	add    $0x10,%esp
  800fc5:	85 c0                	test   %eax,%eax
  800fc7:	78 3a                	js     801003 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fc9:	83 ec 04             	sub    $0x4,%esp
  800fcc:	68 07 04 00 00       	push   $0x407
  800fd1:	ff 75 f4             	pushl  -0xc(%ebp)
  800fd4:	6a 00                	push   $0x0
  800fd6:	e8 8b f1 ff ff       	call   800166 <sys_page_alloc>
  800fdb:	83 c4 10             	add    $0x10,%esp
  800fde:	85 c0                	test   %eax,%eax
  800fe0:	78 21                	js     801003 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  800fe2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fe5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800feb:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800fed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ff0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800ff7:	83 ec 0c             	sub    $0xc,%esp
  800ffa:	50                   	push   %eax
  800ffb:	e8 57 f3 ff ff       	call   800357 <fd2num>
  801000:	83 c4 10             	add    $0x10,%esp
}
  801003:	c9                   	leave  
  801004:	c3                   	ret    

00801005 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801005:	55                   	push   %ebp
  801006:	89 e5                	mov    %esp,%ebp
  801008:	56                   	push   %esi
  801009:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80100a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80100d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801013:	e8 10 f1 ff ff       	call   800128 <sys_getenvid>
  801018:	83 ec 0c             	sub    $0xc,%esp
  80101b:	ff 75 0c             	pushl  0xc(%ebp)
  80101e:	ff 75 08             	pushl  0x8(%ebp)
  801021:	56                   	push   %esi
  801022:	50                   	push   %eax
  801023:	68 e8 1e 80 00       	push   $0x801ee8
  801028:	e8 b3 00 00 00       	call   8010e0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80102d:	83 c4 18             	add    $0x18,%esp
  801030:	53                   	push   %ebx
  801031:	ff 75 10             	pushl  0x10(%ebp)
  801034:	e8 56 00 00 00       	call   80108f <vcprintf>
	cprintf("\n");
  801039:	c7 04 24 d3 1e 80 00 	movl   $0x801ed3,(%esp)
  801040:	e8 9b 00 00 00       	call   8010e0 <cprintf>
  801045:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801048:	cc                   	int3   
  801049:	eb fd                	jmp    801048 <_panic+0x43>

0080104b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80104b:	55                   	push   %ebp
  80104c:	89 e5                	mov    %esp,%ebp
  80104e:	53                   	push   %ebx
  80104f:	83 ec 04             	sub    $0x4,%esp
  801052:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801055:	8b 13                	mov    (%ebx),%edx
  801057:	8d 42 01             	lea    0x1(%edx),%eax
  80105a:	89 03                	mov    %eax,(%ebx)
  80105c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80105f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801063:	3d ff 00 00 00       	cmp    $0xff,%eax
  801068:	74 09                	je     801073 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80106a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80106e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801071:	c9                   	leave  
  801072:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801073:	83 ec 08             	sub    $0x8,%esp
  801076:	68 ff 00 00 00       	push   $0xff
  80107b:	8d 43 08             	lea    0x8(%ebx),%eax
  80107e:	50                   	push   %eax
  80107f:	e8 26 f0 ff ff       	call   8000aa <sys_cputs>
		b->idx = 0;
  801084:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80108a:	83 c4 10             	add    $0x10,%esp
  80108d:	eb db                	jmp    80106a <putch+0x1f>

0080108f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80108f:	55                   	push   %ebp
  801090:	89 e5                	mov    %esp,%ebp
  801092:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801098:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80109f:	00 00 00 
	b.cnt = 0;
  8010a2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010a9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010ac:	ff 75 0c             	pushl  0xc(%ebp)
  8010af:	ff 75 08             	pushl  0x8(%ebp)
  8010b2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010b8:	50                   	push   %eax
  8010b9:	68 4b 10 80 00       	push   $0x80104b
  8010be:	e8 1a 01 00 00       	call   8011dd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010c3:	83 c4 08             	add    $0x8,%esp
  8010c6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010cc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010d2:	50                   	push   %eax
  8010d3:	e8 d2 ef ff ff       	call   8000aa <sys_cputs>

	return b.cnt;
}
  8010d8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010de:	c9                   	leave  
  8010df:	c3                   	ret    

008010e0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010e0:	55                   	push   %ebp
  8010e1:	89 e5                	mov    %esp,%ebp
  8010e3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010e6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010e9:	50                   	push   %eax
  8010ea:	ff 75 08             	pushl  0x8(%ebp)
  8010ed:	e8 9d ff ff ff       	call   80108f <vcprintf>
	va_end(ap);

	return cnt;
}
  8010f2:	c9                   	leave  
  8010f3:	c3                   	ret    

008010f4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010f4:	55                   	push   %ebp
  8010f5:	89 e5                	mov    %esp,%ebp
  8010f7:	57                   	push   %edi
  8010f8:	56                   	push   %esi
  8010f9:	53                   	push   %ebx
  8010fa:	83 ec 1c             	sub    $0x1c,%esp
  8010fd:	89 c7                	mov    %eax,%edi
  8010ff:	89 d6                	mov    %edx,%esi
  801101:	8b 45 08             	mov    0x8(%ebp),%eax
  801104:	8b 55 0c             	mov    0xc(%ebp),%edx
  801107:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80110a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80110d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801110:	bb 00 00 00 00       	mov    $0x0,%ebx
  801115:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801118:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80111b:	39 d3                	cmp    %edx,%ebx
  80111d:	72 05                	jb     801124 <printnum+0x30>
  80111f:	39 45 10             	cmp    %eax,0x10(%ebp)
  801122:	77 7a                	ja     80119e <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801124:	83 ec 0c             	sub    $0xc,%esp
  801127:	ff 75 18             	pushl  0x18(%ebp)
  80112a:	8b 45 14             	mov    0x14(%ebp),%eax
  80112d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801130:	53                   	push   %ebx
  801131:	ff 75 10             	pushl  0x10(%ebp)
  801134:	83 ec 08             	sub    $0x8,%esp
  801137:	ff 75 e4             	pushl  -0x1c(%ebp)
  80113a:	ff 75 e0             	pushl  -0x20(%ebp)
  80113d:	ff 75 dc             	pushl  -0x24(%ebp)
  801140:	ff 75 d8             	pushl  -0x28(%ebp)
  801143:	e8 28 0a 00 00       	call   801b70 <__udivdi3>
  801148:	83 c4 18             	add    $0x18,%esp
  80114b:	52                   	push   %edx
  80114c:	50                   	push   %eax
  80114d:	89 f2                	mov    %esi,%edx
  80114f:	89 f8                	mov    %edi,%eax
  801151:	e8 9e ff ff ff       	call   8010f4 <printnum>
  801156:	83 c4 20             	add    $0x20,%esp
  801159:	eb 13                	jmp    80116e <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80115b:	83 ec 08             	sub    $0x8,%esp
  80115e:	56                   	push   %esi
  80115f:	ff 75 18             	pushl  0x18(%ebp)
  801162:	ff d7                	call   *%edi
  801164:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801167:	83 eb 01             	sub    $0x1,%ebx
  80116a:	85 db                	test   %ebx,%ebx
  80116c:	7f ed                	jg     80115b <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80116e:	83 ec 08             	sub    $0x8,%esp
  801171:	56                   	push   %esi
  801172:	83 ec 04             	sub    $0x4,%esp
  801175:	ff 75 e4             	pushl  -0x1c(%ebp)
  801178:	ff 75 e0             	pushl  -0x20(%ebp)
  80117b:	ff 75 dc             	pushl  -0x24(%ebp)
  80117e:	ff 75 d8             	pushl  -0x28(%ebp)
  801181:	e8 0a 0b 00 00       	call   801c90 <__umoddi3>
  801186:	83 c4 14             	add    $0x14,%esp
  801189:	0f be 80 0b 1f 80 00 	movsbl 0x801f0b(%eax),%eax
  801190:	50                   	push   %eax
  801191:	ff d7                	call   *%edi
}
  801193:	83 c4 10             	add    $0x10,%esp
  801196:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801199:	5b                   	pop    %ebx
  80119a:	5e                   	pop    %esi
  80119b:	5f                   	pop    %edi
  80119c:	5d                   	pop    %ebp
  80119d:	c3                   	ret    
  80119e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8011a1:	eb c4                	jmp    801167 <printnum+0x73>

008011a3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011a3:	55                   	push   %ebp
  8011a4:	89 e5                	mov    %esp,%ebp
  8011a6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011a9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011ad:	8b 10                	mov    (%eax),%edx
  8011af:	3b 50 04             	cmp    0x4(%eax),%edx
  8011b2:	73 0a                	jae    8011be <sprintputch+0x1b>
		*b->buf++ = ch;
  8011b4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011b7:	89 08                	mov    %ecx,(%eax)
  8011b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8011bc:	88 02                	mov    %al,(%edx)
}
  8011be:	5d                   	pop    %ebp
  8011bf:	c3                   	ret    

008011c0 <printfmt>:
{
  8011c0:	55                   	push   %ebp
  8011c1:	89 e5                	mov    %esp,%ebp
  8011c3:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8011c6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011c9:	50                   	push   %eax
  8011ca:	ff 75 10             	pushl  0x10(%ebp)
  8011cd:	ff 75 0c             	pushl  0xc(%ebp)
  8011d0:	ff 75 08             	pushl  0x8(%ebp)
  8011d3:	e8 05 00 00 00       	call   8011dd <vprintfmt>
}
  8011d8:	83 c4 10             	add    $0x10,%esp
  8011db:	c9                   	leave  
  8011dc:	c3                   	ret    

008011dd <vprintfmt>:
{
  8011dd:	55                   	push   %ebp
  8011de:	89 e5                	mov    %esp,%ebp
  8011e0:	57                   	push   %edi
  8011e1:	56                   	push   %esi
  8011e2:	53                   	push   %ebx
  8011e3:	83 ec 2c             	sub    $0x2c,%esp
  8011e6:	8b 75 08             	mov    0x8(%ebp),%esi
  8011e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8011ec:	8b 7d 10             	mov    0x10(%ebp),%edi
  8011ef:	e9 c1 03 00 00       	jmp    8015b5 <vprintfmt+0x3d8>
		padc = ' ';
  8011f4:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8011f8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8011ff:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  801206:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80120d:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801212:	8d 47 01             	lea    0x1(%edi),%eax
  801215:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801218:	0f b6 17             	movzbl (%edi),%edx
  80121b:	8d 42 dd             	lea    -0x23(%edx),%eax
  80121e:	3c 55                	cmp    $0x55,%al
  801220:	0f 87 12 04 00 00    	ja     801638 <vprintfmt+0x45b>
  801226:	0f b6 c0             	movzbl %al,%eax
  801229:	ff 24 85 40 20 80 00 	jmp    *0x802040(,%eax,4)
  801230:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801233:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  801237:	eb d9                	jmp    801212 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  801239:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80123c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801240:	eb d0                	jmp    801212 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  801242:	0f b6 d2             	movzbl %dl,%edx
  801245:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801248:	b8 00 00 00 00       	mov    $0x0,%eax
  80124d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801250:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801253:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801257:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80125a:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80125d:	83 f9 09             	cmp    $0x9,%ecx
  801260:	77 55                	ja     8012b7 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  801262:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801265:	eb e9                	jmp    801250 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  801267:	8b 45 14             	mov    0x14(%ebp),%eax
  80126a:	8b 00                	mov    (%eax),%eax
  80126c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80126f:	8b 45 14             	mov    0x14(%ebp),%eax
  801272:	8d 40 04             	lea    0x4(%eax),%eax
  801275:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801278:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80127b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80127f:	79 91                	jns    801212 <vprintfmt+0x35>
				width = precision, precision = -1;
  801281:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801284:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801287:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80128e:	eb 82                	jmp    801212 <vprintfmt+0x35>
  801290:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801293:	85 c0                	test   %eax,%eax
  801295:	ba 00 00 00 00       	mov    $0x0,%edx
  80129a:	0f 49 d0             	cmovns %eax,%edx
  80129d:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8012a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012a3:	e9 6a ff ff ff       	jmp    801212 <vprintfmt+0x35>
  8012a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8012ab:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012b2:	e9 5b ff ff ff       	jmp    801212 <vprintfmt+0x35>
  8012b7:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8012ba:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012bd:	eb bc                	jmp    80127b <vprintfmt+0x9e>
			lflag++;
  8012bf:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8012c5:	e9 48 ff ff ff       	jmp    801212 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8012ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8012cd:	8d 78 04             	lea    0x4(%eax),%edi
  8012d0:	83 ec 08             	sub    $0x8,%esp
  8012d3:	53                   	push   %ebx
  8012d4:	ff 30                	pushl  (%eax)
  8012d6:	ff d6                	call   *%esi
			break;
  8012d8:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8012db:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8012de:	e9 cf 02 00 00       	jmp    8015b2 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8012e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8012e6:	8d 78 04             	lea    0x4(%eax),%edi
  8012e9:	8b 00                	mov    (%eax),%eax
  8012eb:	99                   	cltd   
  8012ec:	31 d0                	xor    %edx,%eax
  8012ee:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8012f0:	83 f8 0f             	cmp    $0xf,%eax
  8012f3:	7f 23                	jg     801318 <vprintfmt+0x13b>
  8012f5:	8b 14 85 a0 21 80 00 	mov    0x8021a0(,%eax,4),%edx
  8012fc:	85 d2                	test   %edx,%edx
  8012fe:	74 18                	je     801318 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  801300:	52                   	push   %edx
  801301:	68 a1 1e 80 00       	push   $0x801ea1
  801306:	53                   	push   %ebx
  801307:	56                   	push   %esi
  801308:	e8 b3 fe ff ff       	call   8011c0 <printfmt>
  80130d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801310:	89 7d 14             	mov    %edi,0x14(%ebp)
  801313:	e9 9a 02 00 00       	jmp    8015b2 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  801318:	50                   	push   %eax
  801319:	68 23 1f 80 00       	push   $0x801f23
  80131e:	53                   	push   %ebx
  80131f:	56                   	push   %esi
  801320:	e8 9b fe ff ff       	call   8011c0 <printfmt>
  801325:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801328:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80132b:	e9 82 02 00 00       	jmp    8015b2 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  801330:	8b 45 14             	mov    0x14(%ebp),%eax
  801333:	83 c0 04             	add    $0x4,%eax
  801336:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801339:	8b 45 14             	mov    0x14(%ebp),%eax
  80133c:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80133e:	85 ff                	test   %edi,%edi
  801340:	b8 1c 1f 80 00       	mov    $0x801f1c,%eax
  801345:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801348:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80134c:	0f 8e bd 00 00 00    	jle    80140f <vprintfmt+0x232>
  801352:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801356:	75 0e                	jne    801366 <vprintfmt+0x189>
  801358:	89 75 08             	mov    %esi,0x8(%ebp)
  80135b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80135e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801361:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801364:	eb 6d                	jmp    8013d3 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  801366:	83 ec 08             	sub    $0x8,%esp
  801369:	ff 75 d0             	pushl  -0x30(%ebp)
  80136c:	57                   	push   %edi
  80136d:	e8 6e 03 00 00       	call   8016e0 <strnlen>
  801372:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801375:	29 c1                	sub    %eax,%ecx
  801377:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80137a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80137d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801381:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801384:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801387:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  801389:	eb 0f                	jmp    80139a <vprintfmt+0x1bd>
					putch(padc, putdat);
  80138b:	83 ec 08             	sub    $0x8,%esp
  80138e:	53                   	push   %ebx
  80138f:	ff 75 e0             	pushl  -0x20(%ebp)
  801392:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  801394:	83 ef 01             	sub    $0x1,%edi
  801397:	83 c4 10             	add    $0x10,%esp
  80139a:	85 ff                	test   %edi,%edi
  80139c:	7f ed                	jg     80138b <vprintfmt+0x1ae>
  80139e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8013a1:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8013a4:	85 c9                	test   %ecx,%ecx
  8013a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8013ab:	0f 49 c1             	cmovns %ecx,%eax
  8013ae:	29 c1                	sub    %eax,%ecx
  8013b0:	89 75 08             	mov    %esi,0x8(%ebp)
  8013b3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8013b6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8013b9:	89 cb                	mov    %ecx,%ebx
  8013bb:	eb 16                	jmp    8013d3 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8013bd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8013c1:	75 31                	jne    8013f4 <vprintfmt+0x217>
					putch(ch, putdat);
  8013c3:	83 ec 08             	sub    $0x8,%esp
  8013c6:	ff 75 0c             	pushl  0xc(%ebp)
  8013c9:	50                   	push   %eax
  8013ca:	ff 55 08             	call   *0x8(%ebp)
  8013cd:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8013d0:	83 eb 01             	sub    $0x1,%ebx
  8013d3:	83 c7 01             	add    $0x1,%edi
  8013d6:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8013da:	0f be c2             	movsbl %dl,%eax
  8013dd:	85 c0                	test   %eax,%eax
  8013df:	74 59                	je     80143a <vprintfmt+0x25d>
  8013e1:	85 f6                	test   %esi,%esi
  8013e3:	78 d8                	js     8013bd <vprintfmt+0x1e0>
  8013e5:	83 ee 01             	sub    $0x1,%esi
  8013e8:	79 d3                	jns    8013bd <vprintfmt+0x1e0>
  8013ea:	89 df                	mov    %ebx,%edi
  8013ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8013ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8013f2:	eb 37                	jmp    80142b <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8013f4:	0f be d2             	movsbl %dl,%edx
  8013f7:	83 ea 20             	sub    $0x20,%edx
  8013fa:	83 fa 5e             	cmp    $0x5e,%edx
  8013fd:	76 c4                	jbe    8013c3 <vprintfmt+0x1e6>
					putch('?', putdat);
  8013ff:	83 ec 08             	sub    $0x8,%esp
  801402:	ff 75 0c             	pushl  0xc(%ebp)
  801405:	6a 3f                	push   $0x3f
  801407:	ff 55 08             	call   *0x8(%ebp)
  80140a:	83 c4 10             	add    $0x10,%esp
  80140d:	eb c1                	jmp    8013d0 <vprintfmt+0x1f3>
  80140f:	89 75 08             	mov    %esi,0x8(%ebp)
  801412:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801415:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801418:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80141b:	eb b6                	jmp    8013d3 <vprintfmt+0x1f6>
				putch(' ', putdat);
  80141d:	83 ec 08             	sub    $0x8,%esp
  801420:	53                   	push   %ebx
  801421:	6a 20                	push   $0x20
  801423:	ff d6                	call   *%esi
			for (; width > 0; width--)
  801425:	83 ef 01             	sub    $0x1,%edi
  801428:	83 c4 10             	add    $0x10,%esp
  80142b:	85 ff                	test   %edi,%edi
  80142d:	7f ee                	jg     80141d <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  80142f:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801432:	89 45 14             	mov    %eax,0x14(%ebp)
  801435:	e9 78 01 00 00       	jmp    8015b2 <vprintfmt+0x3d5>
  80143a:	89 df                	mov    %ebx,%edi
  80143c:	8b 75 08             	mov    0x8(%ebp),%esi
  80143f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801442:	eb e7                	jmp    80142b <vprintfmt+0x24e>
	if (lflag >= 2)
  801444:	83 f9 01             	cmp    $0x1,%ecx
  801447:	7e 3f                	jle    801488 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  801449:	8b 45 14             	mov    0x14(%ebp),%eax
  80144c:	8b 50 04             	mov    0x4(%eax),%edx
  80144f:	8b 00                	mov    (%eax),%eax
  801451:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801454:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801457:	8b 45 14             	mov    0x14(%ebp),%eax
  80145a:	8d 40 08             	lea    0x8(%eax),%eax
  80145d:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  801460:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801464:	79 5c                	jns    8014c2 <vprintfmt+0x2e5>
				putch('-', putdat);
  801466:	83 ec 08             	sub    $0x8,%esp
  801469:	53                   	push   %ebx
  80146a:	6a 2d                	push   $0x2d
  80146c:	ff d6                	call   *%esi
				num = -(long long) num;
  80146e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801471:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801474:	f7 da                	neg    %edx
  801476:	83 d1 00             	adc    $0x0,%ecx
  801479:	f7 d9                	neg    %ecx
  80147b:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80147e:	b8 0a 00 00 00       	mov    $0xa,%eax
  801483:	e9 10 01 00 00       	jmp    801598 <vprintfmt+0x3bb>
	else if (lflag)
  801488:	85 c9                	test   %ecx,%ecx
  80148a:	75 1b                	jne    8014a7 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  80148c:	8b 45 14             	mov    0x14(%ebp),%eax
  80148f:	8b 00                	mov    (%eax),%eax
  801491:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801494:	89 c1                	mov    %eax,%ecx
  801496:	c1 f9 1f             	sar    $0x1f,%ecx
  801499:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80149c:	8b 45 14             	mov    0x14(%ebp),%eax
  80149f:	8d 40 04             	lea    0x4(%eax),%eax
  8014a2:	89 45 14             	mov    %eax,0x14(%ebp)
  8014a5:	eb b9                	jmp    801460 <vprintfmt+0x283>
		return va_arg(*ap, long);
  8014a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8014aa:	8b 00                	mov    (%eax),%eax
  8014ac:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014af:	89 c1                	mov    %eax,%ecx
  8014b1:	c1 f9 1f             	sar    $0x1f,%ecx
  8014b4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ba:	8d 40 04             	lea    0x4(%eax),%eax
  8014bd:	89 45 14             	mov    %eax,0x14(%ebp)
  8014c0:	eb 9e                	jmp    801460 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8014c2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014c5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8014c8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014cd:	e9 c6 00 00 00       	jmp    801598 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8014d2:	83 f9 01             	cmp    $0x1,%ecx
  8014d5:	7e 18                	jle    8014ef <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8014d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8014da:	8b 10                	mov    (%eax),%edx
  8014dc:	8b 48 04             	mov    0x4(%eax),%ecx
  8014df:	8d 40 08             	lea    0x8(%eax),%eax
  8014e2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8014e5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014ea:	e9 a9 00 00 00       	jmp    801598 <vprintfmt+0x3bb>
	else if (lflag)
  8014ef:	85 c9                	test   %ecx,%ecx
  8014f1:	75 1a                	jne    80150d <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  8014f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f6:	8b 10                	mov    (%eax),%edx
  8014f8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014fd:	8d 40 04             	lea    0x4(%eax),%eax
  801500:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801503:	b8 0a 00 00 00       	mov    $0xa,%eax
  801508:	e9 8b 00 00 00       	jmp    801598 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80150d:	8b 45 14             	mov    0x14(%ebp),%eax
  801510:	8b 10                	mov    (%eax),%edx
  801512:	b9 00 00 00 00       	mov    $0x0,%ecx
  801517:	8d 40 04             	lea    0x4(%eax),%eax
  80151a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80151d:	b8 0a 00 00 00       	mov    $0xa,%eax
  801522:	eb 74                	jmp    801598 <vprintfmt+0x3bb>
	if (lflag >= 2)
  801524:	83 f9 01             	cmp    $0x1,%ecx
  801527:	7e 15                	jle    80153e <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  801529:	8b 45 14             	mov    0x14(%ebp),%eax
  80152c:	8b 10                	mov    (%eax),%edx
  80152e:	8b 48 04             	mov    0x4(%eax),%ecx
  801531:	8d 40 08             	lea    0x8(%eax),%eax
  801534:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801537:	b8 08 00 00 00       	mov    $0x8,%eax
  80153c:	eb 5a                	jmp    801598 <vprintfmt+0x3bb>
	else if (lflag)
  80153e:	85 c9                	test   %ecx,%ecx
  801540:	75 17                	jne    801559 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  801542:	8b 45 14             	mov    0x14(%ebp),%eax
  801545:	8b 10                	mov    (%eax),%edx
  801547:	b9 00 00 00 00       	mov    $0x0,%ecx
  80154c:	8d 40 04             	lea    0x4(%eax),%eax
  80154f:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801552:	b8 08 00 00 00       	mov    $0x8,%eax
  801557:	eb 3f                	jmp    801598 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  801559:	8b 45 14             	mov    0x14(%ebp),%eax
  80155c:	8b 10                	mov    (%eax),%edx
  80155e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801563:	8d 40 04             	lea    0x4(%eax),%eax
  801566:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801569:	b8 08 00 00 00       	mov    $0x8,%eax
  80156e:	eb 28                	jmp    801598 <vprintfmt+0x3bb>
			putch('0', putdat);
  801570:	83 ec 08             	sub    $0x8,%esp
  801573:	53                   	push   %ebx
  801574:	6a 30                	push   $0x30
  801576:	ff d6                	call   *%esi
			putch('x', putdat);
  801578:	83 c4 08             	add    $0x8,%esp
  80157b:	53                   	push   %ebx
  80157c:	6a 78                	push   $0x78
  80157e:	ff d6                	call   *%esi
			num = (unsigned long long)
  801580:	8b 45 14             	mov    0x14(%ebp),%eax
  801583:	8b 10                	mov    (%eax),%edx
  801585:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80158a:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80158d:	8d 40 04             	lea    0x4(%eax),%eax
  801590:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801593:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  801598:	83 ec 0c             	sub    $0xc,%esp
  80159b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80159f:	57                   	push   %edi
  8015a0:	ff 75 e0             	pushl  -0x20(%ebp)
  8015a3:	50                   	push   %eax
  8015a4:	51                   	push   %ecx
  8015a5:	52                   	push   %edx
  8015a6:	89 da                	mov    %ebx,%edx
  8015a8:	89 f0                	mov    %esi,%eax
  8015aa:	e8 45 fb ff ff       	call   8010f4 <printnum>
			break;
  8015af:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8015b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8015b5:	83 c7 01             	add    $0x1,%edi
  8015b8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8015bc:	83 f8 25             	cmp    $0x25,%eax
  8015bf:	0f 84 2f fc ff ff    	je     8011f4 <vprintfmt+0x17>
			if (ch == '\0')
  8015c5:	85 c0                	test   %eax,%eax
  8015c7:	0f 84 8b 00 00 00    	je     801658 <vprintfmt+0x47b>
			putch(ch, putdat);
  8015cd:	83 ec 08             	sub    $0x8,%esp
  8015d0:	53                   	push   %ebx
  8015d1:	50                   	push   %eax
  8015d2:	ff d6                	call   *%esi
  8015d4:	83 c4 10             	add    $0x10,%esp
  8015d7:	eb dc                	jmp    8015b5 <vprintfmt+0x3d8>
	if (lflag >= 2)
  8015d9:	83 f9 01             	cmp    $0x1,%ecx
  8015dc:	7e 15                	jle    8015f3 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  8015de:	8b 45 14             	mov    0x14(%ebp),%eax
  8015e1:	8b 10                	mov    (%eax),%edx
  8015e3:	8b 48 04             	mov    0x4(%eax),%ecx
  8015e6:	8d 40 08             	lea    0x8(%eax),%eax
  8015e9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015ec:	b8 10 00 00 00       	mov    $0x10,%eax
  8015f1:	eb a5                	jmp    801598 <vprintfmt+0x3bb>
	else if (lflag)
  8015f3:	85 c9                	test   %ecx,%ecx
  8015f5:	75 17                	jne    80160e <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  8015f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8015fa:	8b 10                	mov    (%eax),%edx
  8015fc:	b9 00 00 00 00       	mov    $0x0,%ecx
  801601:	8d 40 04             	lea    0x4(%eax),%eax
  801604:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801607:	b8 10 00 00 00       	mov    $0x10,%eax
  80160c:	eb 8a                	jmp    801598 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80160e:	8b 45 14             	mov    0x14(%ebp),%eax
  801611:	8b 10                	mov    (%eax),%edx
  801613:	b9 00 00 00 00       	mov    $0x0,%ecx
  801618:	8d 40 04             	lea    0x4(%eax),%eax
  80161b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80161e:	b8 10 00 00 00       	mov    $0x10,%eax
  801623:	e9 70 ff ff ff       	jmp    801598 <vprintfmt+0x3bb>
			putch(ch, putdat);
  801628:	83 ec 08             	sub    $0x8,%esp
  80162b:	53                   	push   %ebx
  80162c:	6a 25                	push   $0x25
  80162e:	ff d6                	call   *%esi
			break;
  801630:	83 c4 10             	add    $0x10,%esp
  801633:	e9 7a ff ff ff       	jmp    8015b2 <vprintfmt+0x3d5>
			putch('%', putdat);
  801638:	83 ec 08             	sub    $0x8,%esp
  80163b:	53                   	push   %ebx
  80163c:	6a 25                	push   $0x25
  80163e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801640:	83 c4 10             	add    $0x10,%esp
  801643:	89 f8                	mov    %edi,%eax
  801645:	eb 03                	jmp    80164a <vprintfmt+0x46d>
  801647:	83 e8 01             	sub    $0x1,%eax
  80164a:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80164e:	75 f7                	jne    801647 <vprintfmt+0x46a>
  801650:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801653:	e9 5a ff ff ff       	jmp    8015b2 <vprintfmt+0x3d5>
}
  801658:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80165b:	5b                   	pop    %ebx
  80165c:	5e                   	pop    %esi
  80165d:	5f                   	pop    %edi
  80165e:	5d                   	pop    %ebp
  80165f:	c3                   	ret    

00801660 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801660:	55                   	push   %ebp
  801661:	89 e5                	mov    %esp,%ebp
  801663:	83 ec 18             	sub    $0x18,%esp
  801666:	8b 45 08             	mov    0x8(%ebp),%eax
  801669:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80166c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80166f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801673:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801676:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80167d:	85 c0                	test   %eax,%eax
  80167f:	74 26                	je     8016a7 <vsnprintf+0x47>
  801681:	85 d2                	test   %edx,%edx
  801683:	7e 22                	jle    8016a7 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801685:	ff 75 14             	pushl  0x14(%ebp)
  801688:	ff 75 10             	pushl  0x10(%ebp)
  80168b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80168e:	50                   	push   %eax
  80168f:	68 a3 11 80 00       	push   $0x8011a3
  801694:	e8 44 fb ff ff       	call   8011dd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801699:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80169c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80169f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016a2:	83 c4 10             	add    $0x10,%esp
}
  8016a5:	c9                   	leave  
  8016a6:	c3                   	ret    
		return -E_INVAL;
  8016a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016ac:	eb f7                	jmp    8016a5 <vsnprintf+0x45>

008016ae <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016ae:	55                   	push   %ebp
  8016af:	89 e5                	mov    %esp,%ebp
  8016b1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016b4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016b7:	50                   	push   %eax
  8016b8:	ff 75 10             	pushl  0x10(%ebp)
  8016bb:	ff 75 0c             	pushl  0xc(%ebp)
  8016be:	ff 75 08             	pushl  0x8(%ebp)
  8016c1:	e8 9a ff ff ff       	call   801660 <vsnprintf>
	va_end(ap);

	return rc;
}
  8016c6:	c9                   	leave  
  8016c7:	c3                   	ret    

008016c8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016c8:	55                   	push   %ebp
  8016c9:	89 e5                	mov    %esp,%ebp
  8016cb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8016d3:	eb 03                	jmp    8016d8 <strlen+0x10>
		n++;
  8016d5:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8016d8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016dc:	75 f7                	jne    8016d5 <strlen+0xd>
	return n;
}
  8016de:	5d                   	pop    %ebp
  8016df:	c3                   	ret    

008016e0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016e0:	55                   	push   %ebp
  8016e1:	89 e5                	mov    %esp,%ebp
  8016e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016e6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8016ee:	eb 03                	jmp    8016f3 <strnlen+0x13>
		n++;
  8016f0:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016f3:	39 d0                	cmp    %edx,%eax
  8016f5:	74 06                	je     8016fd <strnlen+0x1d>
  8016f7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8016fb:	75 f3                	jne    8016f0 <strnlen+0x10>
	return n;
}
  8016fd:	5d                   	pop    %ebp
  8016fe:	c3                   	ret    

008016ff <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016ff:	55                   	push   %ebp
  801700:	89 e5                	mov    %esp,%ebp
  801702:	53                   	push   %ebx
  801703:	8b 45 08             	mov    0x8(%ebp),%eax
  801706:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801709:	89 c2                	mov    %eax,%edx
  80170b:	83 c1 01             	add    $0x1,%ecx
  80170e:	83 c2 01             	add    $0x1,%edx
  801711:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801715:	88 5a ff             	mov    %bl,-0x1(%edx)
  801718:	84 db                	test   %bl,%bl
  80171a:	75 ef                	jne    80170b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80171c:	5b                   	pop    %ebx
  80171d:	5d                   	pop    %ebp
  80171e:	c3                   	ret    

0080171f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80171f:	55                   	push   %ebp
  801720:	89 e5                	mov    %esp,%ebp
  801722:	53                   	push   %ebx
  801723:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801726:	53                   	push   %ebx
  801727:	e8 9c ff ff ff       	call   8016c8 <strlen>
  80172c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80172f:	ff 75 0c             	pushl  0xc(%ebp)
  801732:	01 d8                	add    %ebx,%eax
  801734:	50                   	push   %eax
  801735:	e8 c5 ff ff ff       	call   8016ff <strcpy>
	return dst;
}
  80173a:	89 d8                	mov    %ebx,%eax
  80173c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80173f:	c9                   	leave  
  801740:	c3                   	ret    

00801741 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801741:	55                   	push   %ebp
  801742:	89 e5                	mov    %esp,%ebp
  801744:	56                   	push   %esi
  801745:	53                   	push   %ebx
  801746:	8b 75 08             	mov    0x8(%ebp),%esi
  801749:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80174c:	89 f3                	mov    %esi,%ebx
  80174e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801751:	89 f2                	mov    %esi,%edx
  801753:	eb 0f                	jmp    801764 <strncpy+0x23>
		*dst++ = *src;
  801755:	83 c2 01             	add    $0x1,%edx
  801758:	0f b6 01             	movzbl (%ecx),%eax
  80175b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80175e:	80 39 01             	cmpb   $0x1,(%ecx)
  801761:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  801764:	39 da                	cmp    %ebx,%edx
  801766:	75 ed                	jne    801755 <strncpy+0x14>
	}
	return ret;
}
  801768:	89 f0                	mov    %esi,%eax
  80176a:	5b                   	pop    %ebx
  80176b:	5e                   	pop    %esi
  80176c:	5d                   	pop    %ebp
  80176d:	c3                   	ret    

0080176e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80176e:	55                   	push   %ebp
  80176f:	89 e5                	mov    %esp,%ebp
  801771:	56                   	push   %esi
  801772:	53                   	push   %ebx
  801773:	8b 75 08             	mov    0x8(%ebp),%esi
  801776:	8b 55 0c             	mov    0xc(%ebp),%edx
  801779:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80177c:	89 f0                	mov    %esi,%eax
  80177e:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801782:	85 c9                	test   %ecx,%ecx
  801784:	75 0b                	jne    801791 <strlcpy+0x23>
  801786:	eb 17                	jmp    80179f <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801788:	83 c2 01             	add    $0x1,%edx
  80178b:	83 c0 01             	add    $0x1,%eax
  80178e:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  801791:	39 d8                	cmp    %ebx,%eax
  801793:	74 07                	je     80179c <strlcpy+0x2e>
  801795:	0f b6 0a             	movzbl (%edx),%ecx
  801798:	84 c9                	test   %cl,%cl
  80179a:	75 ec                	jne    801788 <strlcpy+0x1a>
		*dst = '\0';
  80179c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80179f:	29 f0                	sub    %esi,%eax
}
  8017a1:	5b                   	pop    %ebx
  8017a2:	5e                   	pop    %esi
  8017a3:	5d                   	pop    %ebp
  8017a4:	c3                   	ret    

008017a5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017a5:	55                   	push   %ebp
  8017a6:	89 e5                	mov    %esp,%ebp
  8017a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017ab:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017ae:	eb 06                	jmp    8017b6 <strcmp+0x11>
		p++, q++;
  8017b0:	83 c1 01             	add    $0x1,%ecx
  8017b3:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8017b6:	0f b6 01             	movzbl (%ecx),%eax
  8017b9:	84 c0                	test   %al,%al
  8017bb:	74 04                	je     8017c1 <strcmp+0x1c>
  8017bd:	3a 02                	cmp    (%edx),%al
  8017bf:	74 ef                	je     8017b0 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017c1:	0f b6 c0             	movzbl %al,%eax
  8017c4:	0f b6 12             	movzbl (%edx),%edx
  8017c7:	29 d0                	sub    %edx,%eax
}
  8017c9:	5d                   	pop    %ebp
  8017ca:	c3                   	ret    

008017cb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017cb:	55                   	push   %ebp
  8017cc:	89 e5                	mov    %esp,%ebp
  8017ce:	53                   	push   %ebx
  8017cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017d5:	89 c3                	mov    %eax,%ebx
  8017d7:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017da:	eb 06                	jmp    8017e2 <strncmp+0x17>
		n--, p++, q++;
  8017dc:	83 c0 01             	add    $0x1,%eax
  8017df:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8017e2:	39 d8                	cmp    %ebx,%eax
  8017e4:	74 16                	je     8017fc <strncmp+0x31>
  8017e6:	0f b6 08             	movzbl (%eax),%ecx
  8017e9:	84 c9                	test   %cl,%cl
  8017eb:	74 04                	je     8017f1 <strncmp+0x26>
  8017ed:	3a 0a                	cmp    (%edx),%cl
  8017ef:	74 eb                	je     8017dc <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017f1:	0f b6 00             	movzbl (%eax),%eax
  8017f4:	0f b6 12             	movzbl (%edx),%edx
  8017f7:	29 d0                	sub    %edx,%eax
}
  8017f9:	5b                   	pop    %ebx
  8017fa:	5d                   	pop    %ebp
  8017fb:	c3                   	ret    
		return 0;
  8017fc:	b8 00 00 00 00       	mov    $0x0,%eax
  801801:	eb f6                	jmp    8017f9 <strncmp+0x2e>

00801803 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801803:	55                   	push   %ebp
  801804:	89 e5                	mov    %esp,%ebp
  801806:	8b 45 08             	mov    0x8(%ebp),%eax
  801809:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80180d:	0f b6 10             	movzbl (%eax),%edx
  801810:	84 d2                	test   %dl,%dl
  801812:	74 09                	je     80181d <strchr+0x1a>
		if (*s == c)
  801814:	38 ca                	cmp    %cl,%dl
  801816:	74 0a                	je     801822 <strchr+0x1f>
	for (; *s; s++)
  801818:	83 c0 01             	add    $0x1,%eax
  80181b:	eb f0                	jmp    80180d <strchr+0xa>
			return (char *) s;
	return 0;
  80181d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801822:	5d                   	pop    %ebp
  801823:	c3                   	ret    

00801824 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801824:	55                   	push   %ebp
  801825:	89 e5                	mov    %esp,%ebp
  801827:	8b 45 08             	mov    0x8(%ebp),%eax
  80182a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80182e:	eb 03                	jmp    801833 <strfind+0xf>
  801830:	83 c0 01             	add    $0x1,%eax
  801833:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801836:	38 ca                	cmp    %cl,%dl
  801838:	74 04                	je     80183e <strfind+0x1a>
  80183a:	84 d2                	test   %dl,%dl
  80183c:	75 f2                	jne    801830 <strfind+0xc>
			break;
	return (char *) s;
}
  80183e:	5d                   	pop    %ebp
  80183f:	c3                   	ret    

00801840 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801840:	55                   	push   %ebp
  801841:	89 e5                	mov    %esp,%ebp
  801843:	57                   	push   %edi
  801844:	56                   	push   %esi
  801845:	53                   	push   %ebx
  801846:	8b 7d 08             	mov    0x8(%ebp),%edi
  801849:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80184c:	85 c9                	test   %ecx,%ecx
  80184e:	74 13                	je     801863 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801850:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801856:	75 05                	jne    80185d <memset+0x1d>
  801858:	f6 c1 03             	test   $0x3,%cl
  80185b:	74 0d                	je     80186a <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80185d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801860:	fc                   	cld    
  801861:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801863:	89 f8                	mov    %edi,%eax
  801865:	5b                   	pop    %ebx
  801866:	5e                   	pop    %esi
  801867:	5f                   	pop    %edi
  801868:	5d                   	pop    %ebp
  801869:	c3                   	ret    
		c &= 0xFF;
  80186a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80186e:	89 d3                	mov    %edx,%ebx
  801870:	c1 e3 08             	shl    $0x8,%ebx
  801873:	89 d0                	mov    %edx,%eax
  801875:	c1 e0 18             	shl    $0x18,%eax
  801878:	89 d6                	mov    %edx,%esi
  80187a:	c1 e6 10             	shl    $0x10,%esi
  80187d:	09 f0                	or     %esi,%eax
  80187f:	09 c2                	or     %eax,%edx
  801881:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  801883:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801886:	89 d0                	mov    %edx,%eax
  801888:	fc                   	cld    
  801889:	f3 ab                	rep stos %eax,%es:(%edi)
  80188b:	eb d6                	jmp    801863 <memset+0x23>

0080188d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80188d:	55                   	push   %ebp
  80188e:	89 e5                	mov    %esp,%ebp
  801890:	57                   	push   %edi
  801891:	56                   	push   %esi
  801892:	8b 45 08             	mov    0x8(%ebp),%eax
  801895:	8b 75 0c             	mov    0xc(%ebp),%esi
  801898:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80189b:	39 c6                	cmp    %eax,%esi
  80189d:	73 35                	jae    8018d4 <memmove+0x47>
  80189f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018a2:	39 c2                	cmp    %eax,%edx
  8018a4:	76 2e                	jbe    8018d4 <memmove+0x47>
		s += n;
		d += n;
  8018a6:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018a9:	89 d6                	mov    %edx,%esi
  8018ab:	09 fe                	or     %edi,%esi
  8018ad:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018b3:	74 0c                	je     8018c1 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8018b5:	83 ef 01             	sub    $0x1,%edi
  8018b8:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8018bb:	fd                   	std    
  8018bc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018be:	fc                   	cld    
  8018bf:	eb 21                	jmp    8018e2 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018c1:	f6 c1 03             	test   $0x3,%cl
  8018c4:	75 ef                	jne    8018b5 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8018c6:	83 ef 04             	sub    $0x4,%edi
  8018c9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018cc:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8018cf:	fd                   	std    
  8018d0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018d2:	eb ea                	jmp    8018be <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018d4:	89 f2                	mov    %esi,%edx
  8018d6:	09 c2                	or     %eax,%edx
  8018d8:	f6 c2 03             	test   $0x3,%dl
  8018db:	74 09                	je     8018e6 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018dd:	89 c7                	mov    %eax,%edi
  8018df:	fc                   	cld    
  8018e0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018e2:	5e                   	pop    %esi
  8018e3:	5f                   	pop    %edi
  8018e4:	5d                   	pop    %ebp
  8018e5:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018e6:	f6 c1 03             	test   $0x3,%cl
  8018e9:	75 f2                	jne    8018dd <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8018eb:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8018ee:	89 c7                	mov    %eax,%edi
  8018f0:	fc                   	cld    
  8018f1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018f3:	eb ed                	jmp    8018e2 <memmove+0x55>

008018f5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018f5:	55                   	push   %ebp
  8018f6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018f8:	ff 75 10             	pushl  0x10(%ebp)
  8018fb:	ff 75 0c             	pushl  0xc(%ebp)
  8018fe:	ff 75 08             	pushl  0x8(%ebp)
  801901:	e8 87 ff ff ff       	call   80188d <memmove>
}
  801906:	c9                   	leave  
  801907:	c3                   	ret    

00801908 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801908:	55                   	push   %ebp
  801909:	89 e5                	mov    %esp,%ebp
  80190b:	56                   	push   %esi
  80190c:	53                   	push   %ebx
  80190d:	8b 45 08             	mov    0x8(%ebp),%eax
  801910:	8b 55 0c             	mov    0xc(%ebp),%edx
  801913:	89 c6                	mov    %eax,%esi
  801915:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801918:	39 f0                	cmp    %esi,%eax
  80191a:	74 1c                	je     801938 <memcmp+0x30>
		if (*s1 != *s2)
  80191c:	0f b6 08             	movzbl (%eax),%ecx
  80191f:	0f b6 1a             	movzbl (%edx),%ebx
  801922:	38 d9                	cmp    %bl,%cl
  801924:	75 08                	jne    80192e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801926:	83 c0 01             	add    $0x1,%eax
  801929:	83 c2 01             	add    $0x1,%edx
  80192c:	eb ea                	jmp    801918 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  80192e:	0f b6 c1             	movzbl %cl,%eax
  801931:	0f b6 db             	movzbl %bl,%ebx
  801934:	29 d8                	sub    %ebx,%eax
  801936:	eb 05                	jmp    80193d <memcmp+0x35>
	}

	return 0;
  801938:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80193d:	5b                   	pop    %ebx
  80193e:	5e                   	pop    %esi
  80193f:	5d                   	pop    %ebp
  801940:	c3                   	ret    

00801941 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801941:	55                   	push   %ebp
  801942:	89 e5                	mov    %esp,%ebp
  801944:	8b 45 08             	mov    0x8(%ebp),%eax
  801947:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80194a:	89 c2                	mov    %eax,%edx
  80194c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80194f:	39 d0                	cmp    %edx,%eax
  801951:	73 09                	jae    80195c <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  801953:	38 08                	cmp    %cl,(%eax)
  801955:	74 05                	je     80195c <memfind+0x1b>
	for (; s < ends; s++)
  801957:	83 c0 01             	add    $0x1,%eax
  80195a:	eb f3                	jmp    80194f <memfind+0xe>
			break;
	return (void *) s;
}
  80195c:	5d                   	pop    %ebp
  80195d:	c3                   	ret    

0080195e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80195e:	55                   	push   %ebp
  80195f:	89 e5                	mov    %esp,%ebp
  801961:	57                   	push   %edi
  801962:	56                   	push   %esi
  801963:	53                   	push   %ebx
  801964:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801967:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80196a:	eb 03                	jmp    80196f <strtol+0x11>
		s++;
  80196c:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  80196f:	0f b6 01             	movzbl (%ecx),%eax
  801972:	3c 20                	cmp    $0x20,%al
  801974:	74 f6                	je     80196c <strtol+0xe>
  801976:	3c 09                	cmp    $0x9,%al
  801978:	74 f2                	je     80196c <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  80197a:	3c 2b                	cmp    $0x2b,%al
  80197c:	74 2e                	je     8019ac <strtol+0x4e>
	int neg = 0;
  80197e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801983:	3c 2d                	cmp    $0x2d,%al
  801985:	74 2f                	je     8019b6 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801987:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80198d:	75 05                	jne    801994 <strtol+0x36>
  80198f:	80 39 30             	cmpb   $0x30,(%ecx)
  801992:	74 2c                	je     8019c0 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801994:	85 db                	test   %ebx,%ebx
  801996:	75 0a                	jne    8019a2 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801998:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  80199d:	80 39 30             	cmpb   $0x30,(%ecx)
  8019a0:	74 28                	je     8019ca <strtol+0x6c>
		base = 10;
  8019a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8019a7:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8019aa:	eb 50                	jmp    8019fc <strtol+0x9e>
		s++;
  8019ac:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  8019af:	bf 00 00 00 00       	mov    $0x0,%edi
  8019b4:	eb d1                	jmp    801987 <strtol+0x29>
		s++, neg = 1;
  8019b6:	83 c1 01             	add    $0x1,%ecx
  8019b9:	bf 01 00 00 00       	mov    $0x1,%edi
  8019be:	eb c7                	jmp    801987 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019c0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019c4:	74 0e                	je     8019d4 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8019c6:	85 db                	test   %ebx,%ebx
  8019c8:	75 d8                	jne    8019a2 <strtol+0x44>
		s++, base = 8;
  8019ca:	83 c1 01             	add    $0x1,%ecx
  8019cd:	bb 08 00 00 00       	mov    $0x8,%ebx
  8019d2:	eb ce                	jmp    8019a2 <strtol+0x44>
		s += 2, base = 16;
  8019d4:	83 c1 02             	add    $0x2,%ecx
  8019d7:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019dc:	eb c4                	jmp    8019a2 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  8019de:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019e1:	89 f3                	mov    %esi,%ebx
  8019e3:	80 fb 19             	cmp    $0x19,%bl
  8019e6:	77 29                	ja     801a11 <strtol+0xb3>
			dig = *s - 'a' + 10;
  8019e8:	0f be d2             	movsbl %dl,%edx
  8019eb:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8019ee:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019f1:	7d 30                	jge    801a23 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  8019f3:	83 c1 01             	add    $0x1,%ecx
  8019f6:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019fa:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  8019fc:	0f b6 11             	movzbl (%ecx),%edx
  8019ff:	8d 72 d0             	lea    -0x30(%edx),%esi
  801a02:	89 f3                	mov    %esi,%ebx
  801a04:	80 fb 09             	cmp    $0x9,%bl
  801a07:	77 d5                	ja     8019de <strtol+0x80>
			dig = *s - '0';
  801a09:	0f be d2             	movsbl %dl,%edx
  801a0c:	83 ea 30             	sub    $0x30,%edx
  801a0f:	eb dd                	jmp    8019ee <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  801a11:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a14:	89 f3                	mov    %esi,%ebx
  801a16:	80 fb 19             	cmp    $0x19,%bl
  801a19:	77 08                	ja     801a23 <strtol+0xc5>
			dig = *s - 'A' + 10;
  801a1b:	0f be d2             	movsbl %dl,%edx
  801a1e:	83 ea 37             	sub    $0x37,%edx
  801a21:	eb cb                	jmp    8019ee <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  801a23:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a27:	74 05                	je     801a2e <strtol+0xd0>
		*endptr = (char *) s;
  801a29:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a2c:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801a2e:	89 c2                	mov    %eax,%edx
  801a30:	f7 da                	neg    %edx
  801a32:	85 ff                	test   %edi,%edi
  801a34:	0f 45 c2             	cmovne %edx,%eax
}
  801a37:	5b                   	pop    %ebx
  801a38:	5e                   	pop    %esi
  801a39:	5f                   	pop    %edi
  801a3a:	5d                   	pop    %ebp
  801a3b:	c3                   	ret    

00801a3c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a3c:	55                   	push   %ebp
  801a3d:	89 e5                	mov    %esp,%ebp
  801a3f:	56                   	push   %esi
  801a40:	53                   	push   %ebx
  801a41:	8b 75 08             	mov    0x8(%ebp),%esi
  801a44:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a47:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  801a4a:	85 f6                	test   %esi,%esi
  801a4c:	74 06                	je     801a54 <ipc_recv+0x18>
  801a4e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801a54:	85 db                	test   %ebx,%ebx
  801a56:	74 06                	je     801a5e <ipc_recv+0x22>
  801a58:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801a5e:	85 c0                	test   %eax,%eax
  801a60:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801a65:	0f 44 c2             	cmove  %edx,%eax
	int ret = sys_ipc_recv(pg);
  801a68:	83 ec 0c             	sub    $0xc,%esp
  801a6b:	50                   	push   %eax
  801a6c:	e8 a5 e8 ff ff       	call   800316 <sys_ipc_recv>
	if (ret) return ret;
  801a71:	83 c4 10             	add    $0x10,%esp
  801a74:	85 c0                	test   %eax,%eax
  801a76:	75 24                	jne    801a9c <ipc_recv+0x60>
	if (from_env_store)
  801a78:	85 f6                	test   %esi,%esi
  801a7a:	74 0a                	je     801a86 <ipc_recv+0x4a>
		*from_env_store = thisenv->env_ipc_from;
  801a7c:	a1 04 40 80 00       	mov    0x804004,%eax
  801a81:	8b 40 74             	mov    0x74(%eax),%eax
  801a84:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801a86:	85 db                	test   %ebx,%ebx
  801a88:	74 0a                	je     801a94 <ipc_recv+0x58>
		*perm_store = thisenv->env_ipc_perm;
  801a8a:	a1 04 40 80 00       	mov    0x804004,%eax
  801a8f:	8b 40 78             	mov    0x78(%eax),%eax
  801a92:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801a94:	a1 04 40 80 00       	mov    0x804004,%eax
  801a99:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a9c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a9f:	5b                   	pop    %ebx
  801aa0:	5e                   	pop    %esi
  801aa1:	5d                   	pop    %ebp
  801aa2:	c3                   	ret    

00801aa3 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801aa3:	55                   	push   %ebp
  801aa4:	89 e5                	mov    %esp,%ebp
  801aa6:	57                   	push   %edi
  801aa7:	56                   	push   %esi
  801aa8:	53                   	push   %ebx
  801aa9:	83 ec 0c             	sub    $0xc,%esp
  801aac:	8b 7d 08             	mov    0x8(%ebp),%edi
  801aaf:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ab2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  801ab5:	85 db                	test   %ebx,%ebx
  801ab7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801abc:	0f 44 d8             	cmove  %eax,%ebx
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801abf:	ff 75 14             	pushl  0x14(%ebp)
  801ac2:	53                   	push   %ebx
  801ac3:	56                   	push   %esi
  801ac4:	57                   	push   %edi
  801ac5:	e8 29 e8 ff ff       	call   8002f3 <sys_ipc_try_send>
  801aca:	83 c4 10             	add    $0x10,%esp
  801acd:	85 c0                	test   %eax,%eax
  801acf:	74 1e                	je     801aef <ipc_send+0x4c>
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801ad1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ad4:	75 07                	jne    801add <ipc_send+0x3a>
		sys_yield();
  801ad6:	e8 6c e6 ff ff       	call   800147 <sys_yield>
  801adb:	eb e2                	jmp    801abf <ipc_send+0x1c>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801add:	50                   	push   %eax
  801ade:	68 00 22 80 00       	push   $0x802200
  801ae3:	6a 36                	push   $0x36
  801ae5:	68 17 22 80 00       	push   $0x802217
  801aea:	e8 16 f5 ff ff       	call   801005 <_panic>
	}
}
  801aef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801af2:	5b                   	pop    %ebx
  801af3:	5e                   	pop    %esi
  801af4:	5f                   	pop    %edi
  801af5:	5d                   	pop    %ebp
  801af6:	c3                   	ret    

00801af7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801af7:	55                   	push   %ebp
  801af8:	89 e5                	mov    %esp,%ebp
  801afa:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801afd:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b02:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b05:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b0b:	8b 52 50             	mov    0x50(%edx),%edx
  801b0e:	39 ca                	cmp    %ecx,%edx
  801b10:	74 11                	je     801b23 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801b12:	83 c0 01             	add    $0x1,%eax
  801b15:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b1a:	75 e6                	jne    801b02 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801b1c:	b8 00 00 00 00       	mov    $0x0,%eax
  801b21:	eb 0b                	jmp    801b2e <ipc_find_env+0x37>
			return envs[i].env_id;
  801b23:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b26:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b2b:	8b 40 48             	mov    0x48(%eax),%eax
}
  801b2e:	5d                   	pop    %ebp
  801b2f:	c3                   	ret    

00801b30 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b30:	55                   	push   %ebp
  801b31:	89 e5                	mov    %esp,%ebp
  801b33:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b36:	89 d0                	mov    %edx,%eax
  801b38:	c1 e8 16             	shr    $0x16,%eax
  801b3b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b42:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801b47:	f6 c1 01             	test   $0x1,%cl
  801b4a:	74 1d                	je     801b69 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801b4c:	c1 ea 0c             	shr    $0xc,%edx
  801b4f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b56:	f6 c2 01             	test   $0x1,%dl
  801b59:	74 0e                	je     801b69 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b5b:	c1 ea 0c             	shr    $0xc,%edx
  801b5e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b65:	ef 
  801b66:	0f b7 c0             	movzwl %ax,%eax
}
  801b69:	5d                   	pop    %ebp
  801b6a:	c3                   	ret    
  801b6b:	66 90                	xchg   %ax,%ax
  801b6d:	66 90                	xchg   %ax,%ax
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
