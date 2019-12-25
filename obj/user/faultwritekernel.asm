
obj/user/faultwritekernel.debug：     文件格式 elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	*(unsigned*)0xf0100000 = 0;
  800036:	c7 05 00 00 10 f0 00 	movl   $0x0,0xf0100000
  80003d:	00 00 00 
}
  800040:	5d                   	pop    %ebp
  800041:	c3                   	ret    

00800042 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	56                   	push   %esi
  800046:	53                   	push   %ebx
  800047:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  80004d:	e8 ce 00 00 00       	call   800120 <sys_getenvid>
	thisenv = envs + ENVX(envid); 
  800052:	25 ff 03 00 00       	and    $0x3ff,%eax
  800057:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005f:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800064:	85 db                	test   %ebx,%ebx
  800066:	7e 07                	jle    80006f <libmain+0x2d>
		binaryname = argv[0];
  800068:	8b 06                	mov    (%esi),%eax
  80006a:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80006f:	83 ec 08             	sub    $0x8,%esp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	e8 ba ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800079:	e8 0a 00 00 00       	call   800088 <exit>
}
  80007e:	83 c4 10             	add    $0x10,%esp
  800081:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800084:	5b                   	pop    %ebx
  800085:	5e                   	pop    %esi
  800086:	5d                   	pop    %ebp
  800087:	c3                   	ret    

00800088 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80008e:	e8 92 04 00 00       	call   800525 <close_all>
	sys_env_destroy(0);
  800093:	83 ec 0c             	sub    $0xc,%esp
  800096:	6a 00                	push   $0x0
  800098:	e8 42 00 00 00       	call   8000df <sys_env_destroy>
}
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	c9                   	leave  
  8000a1:	c3                   	ret    

008000a2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a2:	55                   	push   %ebp
  8000a3:	89 e5                	mov    %esp,%ebp
  8000a5:	57                   	push   %edi
  8000a6:	56                   	push   %esi
  8000a7:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b3:	89 c3                	mov    %eax,%ebx
  8000b5:	89 c7                	mov    %eax,%edi
  8000b7:	89 c6                	mov    %eax,%esi
  8000b9:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bb:	5b                   	pop    %ebx
  8000bc:	5e                   	pop    %esi
  8000bd:	5f                   	pop    %edi
  8000be:	5d                   	pop    %ebp
  8000bf:	c3                   	ret    

008000c0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	57                   	push   %edi
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d0:	89 d1                	mov    %edx,%ecx
  8000d2:	89 d3                	mov    %edx,%ebx
  8000d4:	89 d7                	mov    %edx,%edi
  8000d6:	89 d6                	mov    %edx,%esi
  8000d8:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000da:	5b                   	pop    %ebx
  8000db:	5e                   	pop    %esi
  8000dc:	5f                   	pop    %edi
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    

008000df <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	57                   	push   %edi
  8000e3:	56                   	push   %esi
  8000e4:	53                   	push   %ebx
  8000e5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f0:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f5:	89 cb                	mov    %ecx,%ebx
  8000f7:	89 cf                	mov    %ecx,%edi
  8000f9:	89 ce                	mov    %ecx,%esi
  8000fb:	cd 30                	int    $0x30
	if(check && ret > 0)
  8000fd:	85 c0                	test   %eax,%eax
  8000ff:	7f 08                	jg     800109 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800101:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800104:	5b                   	pop    %ebx
  800105:	5e                   	pop    %esi
  800106:	5f                   	pop    %edi
  800107:	5d                   	pop    %ebp
  800108:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800109:	83 ec 0c             	sub    $0xc,%esp
  80010c:	50                   	push   %eax
  80010d:	6a 03                	push   $0x3
  80010f:	68 ca 1d 80 00       	push   $0x801dca
  800114:	6a 23                	push   $0x23
  800116:	68 e7 1d 80 00       	push   $0x801de7
  80011b:	e8 dd 0e 00 00       	call   800ffd <_panic>

00800120 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	57                   	push   %edi
  800124:	56                   	push   %esi
  800125:	53                   	push   %ebx
	asm volatile("int %1\n"
  800126:	ba 00 00 00 00       	mov    $0x0,%edx
  80012b:	b8 02 00 00 00       	mov    $0x2,%eax
  800130:	89 d1                	mov    %edx,%ecx
  800132:	89 d3                	mov    %edx,%ebx
  800134:	89 d7                	mov    %edx,%edi
  800136:	89 d6                	mov    %edx,%esi
  800138:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5f                   	pop    %edi
  80013d:	5d                   	pop    %ebp
  80013e:	c3                   	ret    

0080013f <sys_yield>:

void
sys_yield(void)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	57                   	push   %edi
  800143:	56                   	push   %esi
  800144:	53                   	push   %ebx
	asm volatile("int %1\n"
  800145:	ba 00 00 00 00       	mov    $0x0,%edx
  80014a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80014f:	89 d1                	mov    %edx,%ecx
  800151:	89 d3                	mov    %edx,%ebx
  800153:	89 d7                	mov    %edx,%edi
  800155:	89 d6                	mov    %edx,%esi
  800157:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800159:	5b                   	pop    %ebx
  80015a:	5e                   	pop    %esi
  80015b:	5f                   	pop    %edi
  80015c:	5d                   	pop    %ebp
  80015d:	c3                   	ret    

0080015e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015e:	55                   	push   %ebp
  80015f:	89 e5                	mov    %esp,%ebp
  800161:	57                   	push   %edi
  800162:	56                   	push   %esi
  800163:	53                   	push   %ebx
  800164:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800167:	be 00 00 00 00       	mov    $0x0,%esi
  80016c:	8b 55 08             	mov    0x8(%ebp),%edx
  80016f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800172:	b8 04 00 00 00       	mov    $0x4,%eax
  800177:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017a:	89 f7                	mov    %esi,%edi
  80017c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80017e:	85 c0                	test   %eax,%eax
  800180:	7f 08                	jg     80018a <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800182:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800185:	5b                   	pop    %ebx
  800186:	5e                   	pop    %esi
  800187:	5f                   	pop    %edi
  800188:	5d                   	pop    %ebp
  800189:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80018a:	83 ec 0c             	sub    $0xc,%esp
  80018d:	50                   	push   %eax
  80018e:	6a 04                	push   $0x4
  800190:	68 ca 1d 80 00       	push   $0x801dca
  800195:	6a 23                	push   $0x23
  800197:	68 e7 1d 80 00       	push   $0x801de7
  80019c:	e8 5c 0e 00 00       	call   800ffd <_panic>

008001a1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	57                   	push   %edi
  8001a5:	56                   	push   %esi
  8001a6:	53                   	push   %ebx
  8001a7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b0:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001bb:	8b 75 18             	mov    0x18(%ebp),%esi
  8001be:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001c0:	85 c0                	test   %eax,%eax
  8001c2:	7f 08                	jg     8001cc <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c7:	5b                   	pop    %ebx
  8001c8:	5e                   	pop    %esi
  8001c9:	5f                   	pop    %edi
  8001ca:	5d                   	pop    %ebp
  8001cb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001cc:	83 ec 0c             	sub    $0xc,%esp
  8001cf:	50                   	push   %eax
  8001d0:	6a 05                	push   $0x5
  8001d2:	68 ca 1d 80 00       	push   $0x801dca
  8001d7:	6a 23                	push   $0x23
  8001d9:	68 e7 1d 80 00       	push   $0x801de7
  8001de:	e8 1a 0e 00 00       	call   800ffd <_panic>

008001e3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	57                   	push   %edi
  8001e7:	56                   	push   %esi
  8001e8:	53                   	push   %ebx
  8001e9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001ec:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f7:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fc:	89 df                	mov    %ebx,%edi
  8001fe:	89 de                	mov    %ebx,%esi
  800200:	cd 30                	int    $0x30
	if(check && ret > 0)
  800202:	85 c0                	test   %eax,%eax
  800204:	7f 08                	jg     80020e <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800206:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800209:	5b                   	pop    %ebx
  80020a:	5e                   	pop    %esi
  80020b:	5f                   	pop    %edi
  80020c:	5d                   	pop    %ebp
  80020d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80020e:	83 ec 0c             	sub    $0xc,%esp
  800211:	50                   	push   %eax
  800212:	6a 06                	push   $0x6
  800214:	68 ca 1d 80 00       	push   $0x801dca
  800219:	6a 23                	push   $0x23
  80021b:	68 e7 1d 80 00       	push   $0x801de7
  800220:	e8 d8 0d 00 00       	call   800ffd <_panic>

00800225 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800225:	55                   	push   %ebp
  800226:	89 e5                	mov    %esp,%ebp
  800228:	57                   	push   %edi
  800229:	56                   	push   %esi
  80022a:	53                   	push   %ebx
  80022b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80022e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800233:	8b 55 08             	mov    0x8(%ebp),%edx
  800236:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800239:	b8 08 00 00 00       	mov    $0x8,%eax
  80023e:	89 df                	mov    %ebx,%edi
  800240:	89 de                	mov    %ebx,%esi
  800242:	cd 30                	int    $0x30
	if(check && ret > 0)
  800244:	85 c0                	test   %eax,%eax
  800246:	7f 08                	jg     800250 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800248:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024b:	5b                   	pop    %ebx
  80024c:	5e                   	pop    %esi
  80024d:	5f                   	pop    %edi
  80024e:	5d                   	pop    %ebp
  80024f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800250:	83 ec 0c             	sub    $0xc,%esp
  800253:	50                   	push   %eax
  800254:	6a 08                	push   $0x8
  800256:	68 ca 1d 80 00       	push   $0x801dca
  80025b:	6a 23                	push   $0x23
  80025d:	68 e7 1d 80 00       	push   $0x801de7
  800262:	e8 96 0d 00 00       	call   800ffd <_panic>

00800267 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800267:	55                   	push   %ebp
  800268:	89 e5                	mov    %esp,%ebp
  80026a:	57                   	push   %edi
  80026b:	56                   	push   %esi
  80026c:	53                   	push   %ebx
  80026d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800270:	bb 00 00 00 00       	mov    $0x0,%ebx
  800275:	8b 55 08             	mov    0x8(%ebp),%edx
  800278:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027b:	b8 09 00 00 00       	mov    $0x9,%eax
  800280:	89 df                	mov    %ebx,%edi
  800282:	89 de                	mov    %ebx,%esi
  800284:	cd 30                	int    $0x30
	if(check && ret > 0)
  800286:	85 c0                	test   %eax,%eax
  800288:	7f 08                	jg     800292 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80028a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80028d:	5b                   	pop    %ebx
  80028e:	5e                   	pop    %esi
  80028f:	5f                   	pop    %edi
  800290:	5d                   	pop    %ebp
  800291:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800292:	83 ec 0c             	sub    $0xc,%esp
  800295:	50                   	push   %eax
  800296:	6a 09                	push   $0x9
  800298:	68 ca 1d 80 00       	push   $0x801dca
  80029d:	6a 23                	push   $0x23
  80029f:	68 e7 1d 80 00       	push   $0x801de7
  8002a4:	e8 54 0d 00 00       	call   800ffd <_panic>

008002a9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	57                   	push   %edi
  8002ad:	56                   	push   %esi
  8002ae:	53                   	push   %ebx
  8002af:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002b2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c2:	89 df                	mov    %ebx,%edi
  8002c4:	89 de                	mov    %ebx,%esi
  8002c6:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002c8:	85 c0                	test   %eax,%eax
  8002ca:	7f 08                	jg     8002d4 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002cf:	5b                   	pop    %ebx
  8002d0:	5e                   	pop    %esi
  8002d1:	5f                   	pop    %edi
  8002d2:	5d                   	pop    %ebp
  8002d3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d4:	83 ec 0c             	sub    $0xc,%esp
  8002d7:	50                   	push   %eax
  8002d8:	6a 0a                	push   $0xa
  8002da:	68 ca 1d 80 00       	push   $0x801dca
  8002df:	6a 23                	push   $0x23
  8002e1:	68 e7 1d 80 00       	push   $0x801de7
  8002e6:	e8 12 0d 00 00       	call   800ffd <_panic>

008002eb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	57                   	push   %edi
  8002ef:	56                   	push   %esi
  8002f0:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f7:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002fc:	be 00 00 00 00       	mov    $0x0,%esi
  800301:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800304:	8b 7d 14             	mov    0x14(%ebp),%edi
  800307:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800309:	5b                   	pop    %ebx
  80030a:	5e                   	pop    %esi
  80030b:	5f                   	pop    %edi
  80030c:	5d                   	pop    %ebp
  80030d:	c3                   	ret    

0080030e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	57                   	push   %edi
  800312:	56                   	push   %esi
  800313:	53                   	push   %ebx
  800314:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800317:	b9 00 00 00 00       	mov    $0x0,%ecx
  80031c:	8b 55 08             	mov    0x8(%ebp),%edx
  80031f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800324:	89 cb                	mov    %ecx,%ebx
  800326:	89 cf                	mov    %ecx,%edi
  800328:	89 ce                	mov    %ecx,%esi
  80032a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80032c:	85 c0                	test   %eax,%eax
  80032e:	7f 08                	jg     800338 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800330:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800333:	5b                   	pop    %ebx
  800334:	5e                   	pop    %esi
  800335:	5f                   	pop    %edi
  800336:	5d                   	pop    %ebp
  800337:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800338:	83 ec 0c             	sub    $0xc,%esp
  80033b:	50                   	push   %eax
  80033c:	6a 0d                	push   $0xd
  80033e:	68 ca 1d 80 00       	push   $0x801dca
  800343:	6a 23                	push   $0x23
  800345:	68 e7 1d 80 00       	push   $0x801de7
  80034a:	e8 ae 0c 00 00       	call   800ffd <_panic>

0080034f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800352:	8b 45 08             	mov    0x8(%ebp),%eax
  800355:	05 00 00 00 30       	add    $0x30000000,%eax
  80035a:	c1 e8 0c             	shr    $0xc,%eax
}
  80035d:	5d                   	pop    %ebp
  80035e:	c3                   	ret    

0080035f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80035f:	55                   	push   %ebp
  800360:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800362:	8b 45 08             	mov    0x8(%ebp),%eax
  800365:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80036a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80036f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800374:	5d                   	pop    %ebp
  800375:	c3                   	ret    

00800376 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800376:	55                   	push   %ebp
  800377:	89 e5                	mov    %esp,%ebp
  800379:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80037c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800381:	89 c2                	mov    %eax,%edx
  800383:	c1 ea 16             	shr    $0x16,%edx
  800386:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80038d:	f6 c2 01             	test   $0x1,%dl
  800390:	74 2a                	je     8003bc <fd_alloc+0x46>
  800392:	89 c2                	mov    %eax,%edx
  800394:	c1 ea 0c             	shr    $0xc,%edx
  800397:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80039e:	f6 c2 01             	test   $0x1,%dl
  8003a1:	74 19                	je     8003bc <fd_alloc+0x46>
  8003a3:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8003a8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003ad:	75 d2                	jne    800381 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003af:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003b5:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8003ba:	eb 07                	jmp    8003c3 <fd_alloc+0x4d>
			*fd_store = fd;
  8003bc:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003be:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003c3:	5d                   	pop    %ebp
  8003c4:	c3                   	ret    

008003c5 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003c5:	55                   	push   %ebp
  8003c6:	89 e5                	mov    %esp,%ebp
  8003c8:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003cb:	83 f8 1f             	cmp    $0x1f,%eax
  8003ce:	77 36                	ja     800406 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003d0:	c1 e0 0c             	shl    $0xc,%eax
  8003d3:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003d8:	89 c2                	mov    %eax,%edx
  8003da:	c1 ea 16             	shr    $0x16,%edx
  8003dd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003e4:	f6 c2 01             	test   $0x1,%dl
  8003e7:	74 24                	je     80040d <fd_lookup+0x48>
  8003e9:	89 c2                	mov    %eax,%edx
  8003eb:	c1 ea 0c             	shr    $0xc,%edx
  8003ee:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003f5:	f6 c2 01             	test   $0x1,%dl
  8003f8:	74 1a                	je     800414 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003fd:	89 02                	mov    %eax,(%edx)
	return 0;
  8003ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800404:	5d                   	pop    %ebp
  800405:	c3                   	ret    
		return -E_INVAL;
  800406:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80040b:	eb f7                	jmp    800404 <fd_lookup+0x3f>
		return -E_INVAL;
  80040d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800412:	eb f0                	jmp    800404 <fd_lookup+0x3f>
  800414:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800419:	eb e9                	jmp    800404 <fd_lookup+0x3f>

0080041b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80041b:	55                   	push   %ebp
  80041c:	89 e5                	mov    %esp,%ebp
  80041e:	83 ec 08             	sub    $0x8,%esp
  800421:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800424:	ba 74 1e 80 00       	mov    $0x801e74,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800429:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  80042e:	39 08                	cmp    %ecx,(%eax)
  800430:	74 33                	je     800465 <dev_lookup+0x4a>
  800432:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800435:	8b 02                	mov    (%edx),%eax
  800437:	85 c0                	test   %eax,%eax
  800439:	75 f3                	jne    80042e <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80043b:	a1 04 40 80 00       	mov    0x804004,%eax
  800440:	8b 40 48             	mov    0x48(%eax),%eax
  800443:	83 ec 04             	sub    $0x4,%esp
  800446:	51                   	push   %ecx
  800447:	50                   	push   %eax
  800448:	68 f8 1d 80 00       	push   $0x801df8
  80044d:	e8 86 0c 00 00       	call   8010d8 <cprintf>
	*dev = 0;
  800452:	8b 45 0c             	mov    0xc(%ebp),%eax
  800455:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80045b:	83 c4 10             	add    $0x10,%esp
  80045e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800463:	c9                   	leave  
  800464:	c3                   	ret    
			*dev = devtab[i];
  800465:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800468:	89 01                	mov    %eax,(%ecx)
			return 0;
  80046a:	b8 00 00 00 00       	mov    $0x0,%eax
  80046f:	eb f2                	jmp    800463 <dev_lookup+0x48>

00800471 <fd_close>:
{
  800471:	55                   	push   %ebp
  800472:	89 e5                	mov    %esp,%ebp
  800474:	57                   	push   %edi
  800475:	56                   	push   %esi
  800476:	53                   	push   %ebx
  800477:	83 ec 1c             	sub    $0x1c,%esp
  80047a:	8b 75 08             	mov    0x8(%ebp),%esi
  80047d:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800480:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800483:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800484:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80048a:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80048d:	50                   	push   %eax
  80048e:	e8 32 ff ff ff       	call   8003c5 <fd_lookup>
  800493:	89 c3                	mov    %eax,%ebx
  800495:	83 c4 08             	add    $0x8,%esp
  800498:	85 c0                	test   %eax,%eax
  80049a:	78 05                	js     8004a1 <fd_close+0x30>
	    || fd != fd2)
  80049c:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80049f:	74 16                	je     8004b7 <fd_close+0x46>
		return (must_exist ? r : 0);
  8004a1:	89 f8                	mov    %edi,%eax
  8004a3:	84 c0                	test   %al,%al
  8004a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8004aa:	0f 44 d8             	cmove  %eax,%ebx
}
  8004ad:	89 d8                	mov    %ebx,%eax
  8004af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004b2:	5b                   	pop    %ebx
  8004b3:	5e                   	pop    %esi
  8004b4:	5f                   	pop    %edi
  8004b5:	5d                   	pop    %ebp
  8004b6:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004b7:	83 ec 08             	sub    $0x8,%esp
  8004ba:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8004bd:	50                   	push   %eax
  8004be:	ff 36                	pushl  (%esi)
  8004c0:	e8 56 ff ff ff       	call   80041b <dev_lookup>
  8004c5:	89 c3                	mov    %eax,%ebx
  8004c7:	83 c4 10             	add    $0x10,%esp
  8004ca:	85 c0                	test   %eax,%eax
  8004cc:	78 15                	js     8004e3 <fd_close+0x72>
		if (dev->dev_close)
  8004ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004d1:	8b 40 10             	mov    0x10(%eax),%eax
  8004d4:	85 c0                	test   %eax,%eax
  8004d6:	74 1b                	je     8004f3 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  8004d8:	83 ec 0c             	sub    $0xc,%esp
  8004db:	56                   	push   %esi
  8004dc:	ff d0                	call   *%eax
  8004de:	89 c3                	mov    %eax,%ebx
  8004e0:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8004e3:	83 ec 08             	sub    $0x8,%esp
  8004e6:	56                   	push   %esi
  8004e7:	6a 00                	push   $0x0
  8004e9:	e8 f5 fc ff ff       	call   8001e3 <sys_page_unmap>
	return r;
  8004ee:	83 c4 10             	add    $0x10,%esp
  8004f1:	eb ba                	jmp    8004ad <fd_close+0x3c>
			r = 0;
  8004f3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8004f8:	eb e9                	jmp    8004e3 <fd_close+0x72>

008004fa <close>:

int
close(int fdnum)
{
  8004fa:	55                   	push   %ebp
  8004fb:	89 e5                	mov    %esp,%ebp
  8004fd:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800500:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800503:	50                   	push   %eax
  800504:	ff 75 08             	pushl  0x8(%ebp)
  800507:	e8 b9 fe ff ff       	call   8003c5 <fd_lookup>
  80050c:	83 c4 08             	add    $0x8,%esp
  80050f:	85 c0                	test   %eax,%eax
  800511:	78 10                	js     800523 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800513:	83 ec 08             	sub    $0x8,%esp
  800516:	6a 01                	push   $0x1
  800518:	ff 75 f4             	pushl  -0xc(%ebp)
  80051b:	e8 51 ff ff ff       	call   800471 <fd_close>
  800520:	83 c4 10             	add    $0x10,%esp
}
  800523:	c9                   	leave  
  800524:	c3                   	ret    

00800525 <close_all>:

void
close_all(void)
{
  800525:	55                   	push   %ebp
  800526:	89 e5                	mov    %esp,%ebp
  800528:	53                   	push   %ebx
  800529:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80052c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800531:	83 ec 0c             	sub    $0xc,%esp
  800534:	53                   	push   %ebx
  800535:	e8 c0 ff ff ff       	call   8004fa <close>
	for (i = 0; i < MAXFD; i++)
  80053a:	83 c3 01             	add    $0x1,%ebx
  80053d:	83 c4 10             	add    $0x10,%esp
  800540:	83 fb 20             	cmp    $0x20,%ebx
  800543:	75 ec                	jne    800531 <close_all+0xc>
}
  800545:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800548:	c9                   	leave  
  800549:	c3                   	ret    

0080054a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80054a:	55                   	push   %ebp
  80054b:	89 e5                	mov    %esp,%ebp
  80054d:	57                   	push   %edi
  80054e:	56                   	push   %esi
  80054f:	53                   	push   %ebx
  800550:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800553:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800556:	50                   	push   %eax
  800557:	ff 75 08             	pushl  0x8(%ebp)
  80055a:	e8 66 fe ff ff       	call   8003c5 <fd_lookup>
  80055f:	89 c3                	mov    %eax,%ebx
  800561:	83 c4 08             	add    $0x8,%esp
  800564:	85 c0                	test   %eax,%eax
  800566:	0f 88 81 00 00 00    	js     8005ed <dup+0xa3>
		return r;
	close(newfdnum);
  80056c:	83 ec 0c             	sub    $0xc,%esp
  80056f:	ff 75 0c             	pushl  0xc(%ebp)
  800572:	e8 83 ff ff ff       	call   8004fa <close>

	newfd = INDEX2FD(newfdnum);
  800577:	8b 75 0c             	mov    0xc(%ebp),%esi
  80057a:	c1 e6 0c             	shl    $0xc,%esi
  80057d:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800583:	83 c4 04             	add    $0x4,%esp
  800586:	ff 75 e4             	pushl  -0x1c(%ebp)
  800589:	e8 d1 fd ff ff       	call   80035f <fd2data>
  80058e:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800590:	89 34 24             	mov    %esi,(%esp)
  800593:	e8 c7 fd ff ff       	call   80035f <fd2data>
  800598:	83 c4 10             	add    $0x10,%esp
  80059b:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80059d:	89 d8                	mov    %ebx,%eax
  80059f:	c1 e8 16             	shr    $0x16,%eax
  8005a2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005a9:	a8 01                	test   $0x1,%al
  8005ab:	74 11                	je     8005be <dup+0x74>
  8005ad:	89 d8                	mov    %ebx,%eax
  8005af:	c1 e8 0c             	shr    $0xc,%eax
  8005b2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005b9:	f6 c2 01             	test   $0x1,%dl
  8005bc:	75 39                	jne    8005f7 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005be:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005c1:	89 d0                	mov    %edx,%eax
  8005c3:	c1 e8 0c             	shr    $0xc,%eax
  8005c6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005cd:	83 ec 0c             	sub    $0xc,%esp
  8005d0:	25 07 0e 00 00       	and    $0xe07,%eax
  8005d5:	50                   	push   %eax
  8005d6:	56                   	push   %esi
  8005d7:	6a 00                	push   $0x0
  8005d9:	52                   	push   %edx
  8005da:	6a 00                	push   $0x0
  8005dc:	e8 c0 fb ff ff       	call   8001a1 <sys_page_map>
  8005e1:	89 c3                	mov    %eax,%ebx
  8005e3:	83 c4 20             	add    $0x20,%esp
  8005e6:	85 c0                	test   %eax,%eax
  8005e8:	78 31                	js     80061b <dup+0xd1>
		goto err;

	return newfdnum;
  8005ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005ed:	89 d8                	mov    %ebx,%eax
  8005ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005f2:	5b                   	pop    %ebx
  8005f3:	5e                   	pop    %esi
  8005f4:	5f                   	pop    %edi
  8005f5:	5d                   	pop    %ebp
  8005f6:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005f7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005fe:	83 ec 0c             	sub    $0xc,%esp
  800601:	25 07 0e 00 00       	and    $0xe07,%eax
  800606:	50                   	push   %eax
  800607:	57                   	push   %edi
  800608:	6a 00                	push   $0x0
  80060a:	53                   	push   %ebx
  80060b:	6a 00                	push   $0x0
  80060d:	e8 8f fb ff ff       	call   8001a1 <sys_page_map>
  800612:	89 c3                	mov    %eax,%ebx
  800614:	83 c4 20             	add    $0x20,%esp
  800617:	85 c0                	test   %eax,%eax
  800619:	79 a3                	jns    8005be <dup+0x74>
	sys_page_unmap(0, newfd);
  80061b:	83 ec 08             	sub    $0x8,%esp
  80061e:	56                   	push   %esi
  80061f:	6a 00                	push   $0x0
  800621:	e8 bd fb ff ff       	call   8001e3 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800626:	83 c4 08             	add    $0x8,%esp
  800629:	57                   	push   %edi
  80062a:	6a 00                	push   $0x0
  80062c:	e8 b2 fb ff ff       	call   8001e3 <sys_page_unmap>
	return r;
  800631:	83 c4 10             	add    $0x10,%esp
  800634:	eb b7                	jmp    8005ed <dup+0xa3>

00800636 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800636:	55                   	push   %ebp
  800637:	89 e5                	mov    %esp,%ebp
  800639:	53                   	push   %ebx
  80063a:	83 ec 14             	sub    $0x14,%esp
  80063d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800640:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800643:	50                   	push   %eax
  800644:	53                   	push   %ebx
  800645:	e8 7b fd ff ff       	call   8003c5 <fd_lookup>
  80064a:	83 c4 08             	add    $0x8,%esp
  80064d:	85 c0                	test   %eax,%eax
  80064f:	78 3f                	js     800690 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800651:	83 ec 08             	sub    $0x8,%esp
  800654:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800657:	50                   	push   %eax
  800658:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80065b:	ff 30                	pushl  (%eax)
  80065d:	e8 b9 fd ff ff       	call   80041b <dev_lookup>
  800662:	83 c4 10             	add    $0x10,%esp
  800665:	85 c0                	test   %eax,%eax
  800667:	78 27                	js     800690 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800669:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80066c:	8b 42 08             	mov    0x8(%edx),%eax
  80066f:	83 e0 03             	and    $0x3,%eax
  800672:	83 f8 01             	cmp    $0x1,%eax
  800675:	74 1e                	je     800695 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  800677:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80067a:	8b 40 08             	mov    0x8(%eax),%eax
  80067d:	85 c0                	test   %eax,%eax
  80067f:	74 35                	je     8006b6 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800681:	83 ec 04             	sub    $0x4,%esp
  800684:	ff 75 10             	pushl  0x10(%ebp)
  800687:	ff 75 0c             	pushl  0xc(%ebp)
  80068a:	52                   	push   %edx
  80068b:	ff d0                	call   *%eax
  80068d:	83 c4 10             	add    $0x10,%esp
}
  800690:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800693:	c9                   	leave  
  800694:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800695:	a1 04 40 80 00       	mov    0x804004,%eax
  80069a:	8b 40 48             	mov    0x48(%eax),%eax
  80069d:	83 ec 04             	sub    $0x4,%esp
  8006a0:	53                   	push   %ebx
  8006a1:	50                   	push   %eax
  8006a2:	68 39 1e 80 00       	push   $0x801e39
  8006a7:	e8 2c 0a 00 00       	call   8010d8 <cprintf>
		return -E_INVAL;
  8006ac:	83 c4 10             	add    $0x10,%esp
  8006af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006b4:	eb da                	jmp    800690 <read+0x5a>
		return -E_NOT_SUPP;
  8006b6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8006bb:	eb d3                	jmp    800690 <read+0x5a>

008006bd <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006bd:	55                   	push   %ebp
  8006be:	89 e5                	mov    %esp,%ebp
  8006c0:	57                   	push   %edi
  8006c1:	56                   	push   %esi
  8006c2:	53                   	push   %ebx
  8006c3:	83 ec 0c             	sub    $0xc,%esp
  8006c6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c9:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006cc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d1:	39 f3                	cmp    %esi,%ebx
  8006d3:	73 25                	jae    8006fa <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006d5:	83 ec 04             	sub    $0x4,%esp
  8006d8:	89 f0                	mov    %esi,%eax
  8006da:	29 d8                	sub    %ebx,%eax
  8006dc:	50                   	push   %eax
  8006dd:	89 d8                	mov    %ebx,%eax
  8006df:	03 45 0c             	add    0xc(%ebp),%eax
  8006e2:	50                   	push   %eax
  8006e3:	57                   	push   %edi
  8006e4:	e8 4d ff ff ff       	call   800636 <read>
		if (m < 0)
  8006e9:	83 c4 10             	add    $0x10,%esp
  8006ec:	85 c0                	test   %eax,%eax
  8006ee:	78 08                	js     8006f8 <readn+0x3b>
			return m;
		if (m == 0)
  8006f0:	85 c0                	test   %eax,%eax
  8006f2:	74 06                	je     8006fa <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  8006f4:	01 c3                	add    %eax,%ebx
  8006f6:	eb d9                	jmp    8006d1 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006f8:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8006fa:	89 d8                	mov    %ebx,%eax
  8006fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ff:	5b                   	pop    %ebx
  800700:	5e                   	pop    %esi
  800701:	5f                   	pop    %edi
  800702:	5d                   	pop    %ebp
  800703:	c3                   	ret    

00800704 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800704:	55                   	push   %ebp
  800705:	89 e5                	mov    %esp,%ebp
  800707:	53                   	push   %ebx
  800708:	83 ec 14             	sub    $0x14,%esp
  80070b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80070e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800711:	50                   	push   %eax
  800712:	53                   	push   %ebx
  800713:	e8 ad fc ff ff       	call   8003c5 <fd_lookup>
  800718:	83 c4 08             	add    $0x8,%esp
  80071b:	85 c0                	test   %eax,%eax
  80071d:	78 3a                	js     800759 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80071f:	83 ec 08             	sub    $0x8,%esp
  800722:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800725:	50                   	push   %eax
  800726:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800729:	ff 30                	pushl  (%eax)
  80072b:	e8 eb fc ff ff       	call   80041b <dev_lookup>
  800730:	83 c4 10             	add    $0x10,%esp
  800733:	85 c0                	test   %eax,%eax
  800735:	78 22                	js     800759 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800737:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80073a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80073e:	74 1e                	je     80075e <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800740:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800743:	8b 52 0c             	mov    0xc(%edx),%edx
  800746:	85 d2                	test   %edx,%edx
  800748:	74 35                	je     80077f <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80074a:	83 ec 04             	sub    $0x4,%esp
  80074d:	ff 75 10             	pushl  0x10(%ebp)
  800750:	ff 75 0c             	pushl  0xc(%ebp)
  800753:	50                   	push   %eax
  800754:	ff d2                	call   *%edx
  800756:	83 c4 10             	add    $0x10,%esp
}
  800759:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80075c:	c9                   	leave  
  80075d:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80075e:	a1 04 40 80 00       	mov    0x804004,%eax
  800763:	8b 40 48             	mov    0x48(%eax),%eax
  800766:	83 ec 04             	sub    $0x4,%esp
  800769:	53                   	push   %ebx
  80076a:	50                   	push   %eax
  80076b:	68 55 1e 80 00       	push   $0x801e55
  800770:	e8 63 09 00 00       	call   8010d8 <cprintf>
		return -E_INVAL;
  800775:	83 c4 10             	add    $0x10,%esp
  800778:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80077d:	eb da                	jmp    800759 <write+0x55>
		return -E_NOT_SUPP;
  80077f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800784:	eb d3                	jmp    800759 <write+0x55>

00800786 <seek>:

int
seek(int fdnum, off_t offset)
{
  800786:	55                   	push   %ebp
  800787:	89 e5                	mov    %esp,%ebp
  800789:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80078c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80078f:	50                   	push   %eax
  800790:	ff 75 08             	pushl  0x8(%ebp)
  800793:	e8 2d fc ff ff       	call   8003c5 <fd_lookup>
  800798:	83 c4 08             	add    $0x8,%esp
  80079b:	85 c0                	test   %eax,%eax
  80079d:	78 0e                	js     8007ad <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80079f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007a5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007ad:	c9                   	leave  
  8007ae:	c3                   	ret    

008007af <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007af:	55                   	push   %ebp
  8007b0:	89 e5                	mov    %esp,%ebp
  8007b2:	53                   	push   %ebx
  8007b3:	83 ec 14             	sub    $0x14,%esp
  8007b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007b9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007bc:	50                   	push   %eax
  8007bd:	53                   	push   %ebx
  8007be:	e8 02 fc ff ff       	call   8003c5 <fd_lookup>
  8007c3:	83 c4 08             	add    $0x8,%esp
  8007c6:	85 c0                	test   %eax,%eax
  8007c8:	78 37                	js     800801 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007ca:	83 ec 08             	sub    $0x8,%esp
  8007cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d0:	50                   	push   %eax
  8007d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007d4:	ff 30                	pushl  (%eax)
  8007d6:	e8 40 fc ff ff       	call   80041b <dev_lookup>
  8007db:	83 c4 10             	add    $0x10,%esp
  8007de:	85 c0                	test   %eax,%eax
  8007e0:	78 1f                	js     800801 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007e9:	74 1b                	je     800806 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8007eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007ee:	8b 52 18             	mov    0x18(%edx),%edx
  8007f1:	85 d2                	test   %edx,%edx
  8007f3:	74 32                	je     800827 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8007f5:	83 ec 08             	sub    $0x8,%esp
  8007f8:	ff 75 0c             	pushl  0xc(%ebp)
  8007fb:	50                   	push   %eax
  8007fc:	ff d2                	call   *%edx
  8007fe:	83 c4 10             	add    $0x10,%esp
}
  800801:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800804:	c9                   	leave  
  800805:	c3                   	ret    
			thisenv->env_id, fdnum);
  800806:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80080b:	8b 40 48             	mov    0x48(%eax),%eax
  80080e:	83 ec 04             	sub    $0x4,%esp
  800811:	53                   	push   %ebx
  800812:	50                   	push   %eax
  800813:	68 18 1e 80 00       	push   $0x801e18
  800818:	e8 bb 08 00 00       	call   8010d8 <cprintf>
		return -E_INVAL;
  80081d:	83 c4 10             	add    $0x10,%esp
  800820:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800825:	eb da                	jmp    800801 <ftruncate+0x52>
		return -E_NOT_SUPP;
  800827:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80082c:	eb d3                	jmp    800801 <ftruncate+0x52>

0080082e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80082e:	55                   	push   %ebp
  80082f:	89 e5                	mov    %esp,%ebp
  800831:	53                   	push   %ebx
  800832:	83 ec 14             	sub    $0x14,%esp
  800835:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800838:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80083b:	50                   	push   %eax
  80083c:	ff 75 08             	pushl  0x8(%ebp)
  80083f:	e8 81 fb ff ff       	call   8003c5 <fd_lookup>
  800844:	83 c4 08             	add    $0x8,%esp
  800847:	85 c0                	test   %eax,%eax
  800849:	78 4b                	js     800896 <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80084b:	83 ec 08             	sub    $0x8,%esp
  80084e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800851:	50                   	push   %eax
  800852:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800855:	ff 30                	pushl  (%eax)
  800857:	e8 bf fb ff ff       	call   80041b <dev_lookup>
  80085c:	83 c4 10             	add    $0x10,%esp
  80085f:	85 c0                	test   %eax,%eax
  800861:	78 33                	js     800896 <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  800863:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800866:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80086a:	74 2f                	je     80089b <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80086c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80086f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800876:	00 00 00 
	stat->st_isdir = 0;
  800879:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800880:	00 00 00 
	stat->st_dev = dev;
  800883:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800889:	83 ec 08             	sub    $0x8,%esp
  80088c:	53                   	push   %ebx
  80088d:	ff 75 f0             	pushl  -0x10(%ebp)
  800890:	ff 50 14             	call   *0x14(%eax)
  800893:	83 c4 10             	add    $0x10,%esp
}
  800896:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800899:	c9                   	leave  
  80089a:	c3                   	ret    
		return -E_NOT_SUPP;
  80089b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8008a0:	eb f4                	jmp    800896 <fstat+0x68>

008008a2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	56                   	push   %esi
  8008a6:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008a7:	83 ec 08             	sub    $0x8,%esp
  8008aa:	6a 00                	push   $0x0
  8008ac:	ff 75 08             	pushl  0x8(%ebp)
  8008af:	e8 da 01 00 00       	call   800a8e <open>
  8008b4:	89 c3                	mov    %eax,%ebx
  8008b6:	83 c4 10             	add    $0x10,%esp
  8008b9:	85 c0                	test   %eax,%eax
  8008bb:	78 1b                	js     8008d8 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008bd:	83 ec 08             	sub    $0x8,%esp
  8008c0:	ff 75 0c             	pushl  0xc(%ebp)
  8008c3:	50                   	push   %eax
  8008c4:	e8 65 ff ff ff       	call   80082e <fstat>
  8008c9:	89 c6                	mov    %eax,%esi
	close(fd);
  8008cb:	89 1c 24             	mov    %ebx,(%esp)
  8008ce:	e8 27 fc ff ff       	call   8004fa <close>
	return r;
  8008d3:	83 c4 10             	add    $0x10,%esp
  8008d6:	89 f3                	mov    %esi,%ebx
}
  8008d8:	89 d8                	mov    %ebx,%eax
  8008da:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008dd:	5b                   	pop    %ebx
  8008de:	5e                   	pop    %esi
  8008df:	5d                   	pop    %ebp
  8008e0:	c3                   	ret    

008008e1 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
  8008e4:	56                   	push   %esi
  8008e5:	53                   	push   %ebx
  8008e6:	89 c6                	mov    %eax,%esi
  8008e8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008ea:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8008f1:	74 27                	je     80091a <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008f3:	6a 07                	push   $0x7
  8008f5:	68 00 50 80 00       	push   $0x805000
  8008fa:	56                   	push   %esi
  8008fb:	ff 35 00 40 80 00    	pushl  0x804000
  800901:	e8 95 11 00 00       	call   801a9b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800906:	83 c4 0c             	add    $0xc,%esp
  800909:	6a 00                	push   $0x0
  80090b:	53                   	push   %ebx
  80090c:	6a 00                	push   $0x0
  80090e:	e8 21 11 00 00       	call   801a34 <ipc_recv>
}
  800913:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800916:	5b                   	pop    %ebx
  800917:	5e                   	pop    %esi
  800918:	5d                   	pop    %ebp
  800919:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80091a:	83 ec 0c             	sub    $0xc,%esp
  80091d:	6a 01                	push   $0x1
  80091f:	e8 cb 11 00 00       	call   801aef <ipc_find_env>
  800924:	a3 00 40 80 00       	mov    %eax,0x804000
  800929:	83 c4 10             	add    $0x10,%esp
  80092c:	eb c5                	jmp    8008f3 <fsipc+0x12>

0080092e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80092e:	55                   	push   %ebp
  80092f:	89 e5                	mov    %esp,%ebp
  800931:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800934:	8b 45 08             	mov    0x8(%ebp),%eax
  800937:	8b 40 0c             	mov    0xc(%eax),%eax
  80093a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80093f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800942:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800947:	ba 00 00 00 00       	mov    $0x0,%edx
  80094c:	b8 02 00 00 00       	mov    $0x2,%eax
  800951:	e8 8b ff ff ff       	call   8008e1 <fsipc>
}
  800956:	c9                   	leave  
  800957:	c3                   	ret    

00800958 <devfile_flush>:
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80095e:	8b 45 08             	mov    0x8(%ebp),%eax
  800961:	8b 40 0c             	mov    0xc(%eax),%eax
  800964:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800969:	ba 00 00 00 00       	mov    $0x0,%edx
  80096e:	b8 06 00 00 00       	mov    $0x6,%eax
  800973:	e8 69 ff ff ff       	call   8008e1 <fsipc>
}
  800978:	c9                   	leave  
  800979:	c3                   	ret    

0080097a <devfile_stat>:
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	53                   	push   %ebx
  80097e:	83 ec 04             	sub    $0x4,%esp
  800981:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800984:	8b 45 08             	mov    0x8(%ebp),%eax
  800987:	8b 40 0c             	mov    0xc(%eax),%eax
  80098a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80098f:	ba 00 00 00 00       	mov    $0x0,%edx
  800994:	b8 05 00 00 00       	mov    $0x5,%eax
  800999:	e8 43 ff ff ff       	call   8008e1 <fsipc>
  80099e:	85 c0                	test   %eax,%eax
  8009a0:	78 2c                	js     8009ce <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009a2:	83 ec 08             	sub    $0x8,%esp
  8009a5:	68 00 50 80 00       	push   $0x805000
  8009aa:	53                   	push   %ebx
  8009ab:	e8 47 0d 00 00       	call   8016f7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009b0:	a1 80 50 80 00       	mov    0x805080,%eax
  8009b5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009bb:	a1 84 50 80 00       	mov    0x805084,%eax
  8009c0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009c6:	83 c4 10             	add    $0x10,%esp
  8009c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009d1:	c9                   	leave  
  8009d2:	c3                   	ret    

008009d3 <devfile_write>:
{
  8009d3:	55                   	push   %ebp
  8009d4:	89 e5                	mov    %esp,%ebp
  8009d6:	83 ec 0c             	sub    $0xc,%esp
  8009d9:	8b 45 10             	mov    0x10(%ebp),%eax
    	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8009df:	8b 52 0c             	mov    0xc(%edx),%edx
  8009e2:	89 15 00 50 80 00    	mov    %edx,0x805000
    	fsipcbuf.write.req_n = n;
  8009e8:	a3 04 50 80 00       	mov    %eax,0x805004
    	memmove(fsipcbuf.write.req_buf, buf, n);
  8009ed:	50                   	push   %eax
  8009ee:	ff 75 0c             	pushl  0xc(%ebp)
  8009f1:	68 08 50 80 00       	push   $0x805008
  8009f6:	e8 8a 0e 00 00       	call   801885 <memmove>
    	return fsipc(FSREQ_WRITE, NULL);
  8009fb:	ba 00 00 00 00       	mov    $0x0,%edx
  800a00:	b8 04 00 00 00       	mov    $0x4,%eax
  800a05:	e8 d7 fe ff ff       	call   8008e1 <fsipc>
}
  800a0a:	c9                   	leave  
  800a0b:	c3                   	ret    

00800a0c <devfile_read>:
{
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	56                   	push   %esi
  800a10:	53                   	push   %ebx
  800a11:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a14:	8b 45 08             	mov    0x8(%ebp),%eax
  800a17:	8b 40 0c             	mov    0xc(%eax),%eax
  800a1a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a1f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a25:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2a:	b8 03 00 00 00       	mov    $0x3,%eax
  800a2f:	e8 ad fe ff ff       	call   8008e1 <fsipc>
  800a34:	89 c3                	mov    %eax,%ebx
  800a36:	85 c0                	test   %eax,%eax
  800a38:	78 1f                	js     800a59 <devfile_read+0x4d>
	assert(r <= n);
  800a3a:	39 f0                	cmp    %esi,%eax
  800a3c:	77 24                	ja     800a62 <devfile_read+0x56>
	assert(r <= PGSIZE);
  800a3e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a43:	7f 33                	jg     800a78 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a45:	83 ec 04             	sub    $0x4,%esp
  800a48:	50                   	push   %eax
  800a49:	68 00 50 80 00       	push   $0x805000
  800a4e:	ff 75 0c             	pushl  0xc(%ebp)
  800a51:	e8 2f 0e 00 00       	call   801885 <memmove>
	return r;
  800a56:	83 c4 10             	add    $0x10,%esp
}
  800a59:	89 d8                	mov    %ebx,%eax
  800a5b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a5e:	5b                   	pop    %ebx
  800a5f:	5e                   	pop    %esi
  800a60:	5d                   	pop    %ebp
  800a61:	c3                   	ret    
	assert(r <= n);
  800a62:	68 84 1e 80 00       	push   $0x801e84
  800a67:	68 8b 1e 80 00       	push   $0x801e8b
  800a6c:	6a 7c                	push   $0x7c
  800a6e:	68 a0 1e 80 00       	push   $0x801ea0
  800a73:	e8 85 05 00 00       	call   800ffd <_panic>
	assert(r <= PGSIZE);
  800a78:	68 ab 1e 80 00       	push   $0x801eab
  800a7d:	68 8b 1e 80 00       	push   $0x801e8b
  800a82:	6a 7d                	push   $0x7d
  800a84:	68 a0 1e 80 00       	push   $0x801ea0
  800a89:	e8 6f 05 00 00       	call   800ffd <_panic>

00800a8e <open>:
{
  800a8e:	55                   	push   %ebp
  800a8f:	89 e5                	mov    %esp,%ebp
  800a91:	56                   	push   %esi
  800a92:	53                   	push   %ebx
  800a93:	83 ec 1c             	sub    $0x1c,%esp
  800a96:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800a99:	56                   	push   %esi
  800a9a:	e8 21 0c 00 00       	call   8016c0 <strlen>
  800a9f:	83 c4 10             	add    $0x10,%esp
  800aa2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800aa7:	7f 6c                	jg     800b15 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  800aa9:	83 ec 0c             	sub    $0xc,%esp
  800aac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800aaf:	50                   	push   %eax
  800ab0:	e8 c1 f8 ff ff       	call   800376 <fd_alloc>
  800ab5:	89 c3                	mov    %eax,%ebx
  800ab7:	83 c4 10             	add    $0x10,%esp
  800aba:	85 c0                	test   %eax,%eax
  800abc:	78 3c                	js     800afa <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  800abe:	83 ec 08             	sub    $0x8,%esp
  800ac1:	56                   	push   %esi
  800ac2:	68 00 50 80 00       	push   $0x805000
  800ac7:	e8 2b 0c 00 00       	call   8016f7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800acc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800acf:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800ad4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ad7:	b8 01 00 00 00       	mov    $0x1,%eax
  800adc:	e8 00 fe ff ff       	call   8008e1 <fsipc>
  800ae1:	89 c3                	mov    %eax,%ebx
  800ae3:	83 c4 10             	add    $0x10,%esp
  800ae6:	85 c0                	test   %eax,%eax
  800ae8:	78 19                	js     800b03 <open+0x75>
	return fd2num(fd);
  800aea:	83 ec 0c             	sub    $0xc,%esp
  800aed:	ff 75 f4             	pushl  -0xc(%ebp)
  800af0:	e8 5a f8 ff ff       	call   80034f <fd2num>
  800af5:	89 c3                	mov    %eax,%ebx
  800af7:	83 c4 10             	add    $0x10,%esp
}
  800afa:	89 d8                	mov    %ebx,%eax
  800afc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800aff:	5b                   	pop    %ebx
  800b00:	5e                   	pop    %esi
  800b01:	5d                   	pop    %ebp
  800b02:	c3                   	ret    
		fd_close(fd, 0);
  800b03:	83 ec 08             	sub    $0x8,%esp
  800b06:	6a 00                	push   $0x0
  800b08:	ff 75 f4             	pushl  -0xc(%ebp)
  800b0b:	e8 61 f9 ff ff       	call   800471 <fd_close>
		return r;
  800b10:	83 c4 10             	add    $0x10,%esp
  800b13:	eb e5                	jmp    800afa <open+0x6c>
		return -E_BAD_PATH;
  800b15:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b1a:	eb de                	jmp    800afa <open+0x6c>

00800b1c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b22:	ba 00 00 00 00       	mov    $0x0,%edx
  800b27:	b8 08 00 00 00       	mov    $0x8,%eax
  800b2c:	e8 b0 fd ff ff       	call   8008e1 <fsipc>
}
  800b31:	c9                   	leave  
  800b32:	c3                   	ret    

00800b33 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b33:	55                   	push   %ebp
  800b34:	89 e5                	mov    %esp,%ebp
  800b36:	56                   	push   %esi
  800b37:	53                   	push   %ebx
  800b38:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b3b:	83 ec 0c             	sub    $0xc,%esp
  800b3e:	ff 75 08             	pushl  0x8(%ebp)
  800b41:	e8 19 f8 ff ff       	call   80035f <fd2data>
  800b46:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b48:	83 c4 08             	add    $0x8,%esp
  800b4b:	68 b7 1e 80 00       	push   $0x801eb7
  800b50:	53                   	push   %ebx
  800b51:	e8 a1 0b 00 00       	call   8016f7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b56:	8b 46 04             	mov    0x4(%esi),%eax
  800b59:	2b 06                	sub    (%esi),%eax
  800b5b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b61:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b68:	00 00 00 
	stat->st_dev = &devpipe;
  800b6b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b72:	30 80 00 
	return 0;
}
  800b75:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b7d:	5b                   	pop    %ebx
  800b7e:	5e                   	pop    %esi
  800b7f:	5d                   	pop    %ebp
  800b80:	c3                   	ret    

00800b81 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	53                   	push   %ebx
  800b85:	83 ec 0c             	sub    $0xc,%esp
  800b88:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b8b:	53                   	push   %ebx
  800b8c:	6a 00                	push   $0x0
  800b8e:	e8 50 f6 ff ff       	call   8001e3 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b93:	89 1c 24             	mov    %ebx,(%esp)
  800b96:	e8 c4 f7 ff ff       	call   80035f <fd2data>
  800b9b:	83 c4 08             	add    $0x8,%esp
  800b9e:	50                   	push   %eax
  800b9f:	6a 00                	push   $0x0
  800ba1:	e8 3d f6 ff ff       	call   8001e3 <sys_page_unmap>
}
  800ba6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ba9:	c9                   	leave  
  800baa:	c3                   	ret    

00800bab <_pipeisclosed>:
{
  800bab:	55                   	push   %ebp
  800bac:	89 e5                	mov    %esp,%ebp
  800bae:	57                   	push   %edi
  800baf:	56                   	push   %esi
  800bb0:	53                   	push   %ebx
  800bb1:	83 ec 1c             	sub    $0x1c,%esp
  800bb4:	89 c7                	mov    %eax,%edi
  800bb6:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800bb8:	a1 04 40 80 00       	mov    0x804004,%eax
  800bbd:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800bc0:	83 ec 0c             	sub    $0xc,%esp
  800bc3:	57                   	push   %edi
  800bc4:	e8 5f 0f 00 00       	call   801b28 <pageref>
  800bc9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800bcc:	89 34 24             	mov    %esi,(%esp)
  800bcf:	e8 54 0f 00 00       	call   801b28 <pageref>
		nn = thisenv->env_runs;
  800bd4:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800bda:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800bdd:	83 c4 10             	add    $0x10,%esp
  800be0:	39 cb                	cmp    %ecx,%ebx
  800be2:	74 1b                	je     800bff <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800be4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800be7:	75 cf                	jne    800bb8 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800be9:	8b 42 58             	mov    0x58(%edx),%eax
  800bec:	6a 01                	push   $0x1
  800bee:	50                   	push   %eax
  800bef:	53                   	push   %ebx
  800bf0:	68 be 1e 80 00       	push   $0x801ebe
  800bf5:	e8 de 04 00 00       	call   8010d8 <cprintf>
  800bfa:	83 c4 10             	add    $0x10,%esp
  800bfd:	eb b9                	jmp    800bb8 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800bff:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c02:	0f 94 c0             	sete   %al
  800c05:	0f b6 c0             	movzbl %al,%eax
}
  800c08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0b:	5b                   	pop    %ebx
  800c0c:	5e                   	pop    %esi
  800c0d:	5f                   	pop    %edi
  800c0e:	5d                   	pop    %ebp
  800c0f:	c3                   	ret    

00800c10 <devpipe_write>:
{
  800c10:	55                   	push   %ebp
  800c11:	89 e5                	mov    %esp,%ebp
  800c13:	57                   	push   %edi
  800c14:	56                   	push   %esi
  800c15:	53                   	push   %ebx
  800c16:	83 ec 28             	sub    $0x28,%esp
  800c19:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800c1c:	56                   	push   %esi
  800c1d:	e8 3d f7 ff ff       	call   80035f <fd2data>
  800c22:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c24:	83 c4 10             	add    $0x10,%esp
  800c27:	bf 00 00 00 00       	mov    $0x0,%edi
  800c2c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c2f:	74 4f                	je     800c80 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c31:	8b 43 04             	mov    0x4(%ebx),%eax
  800c34:	8b 0b                	mov    (%ebx),%ecx
  800c36:	8d 51 20             	lea    0x20(%ecx),%edx
  800c39:	39 d0                	cmp    %edx,%eax
  800c3b:	72 14                	jb     800c51 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  800c3d:	89 da                	mov    %ebx,%edx
  800c3f:	89 f0                	mov    %esi,%eax
  800c41:	e8 65 ff ff ff       	call   800bab <_pipeisclosed>
  800c46:	85 c0                	test   %eax,%eax
  800c48:	75 3a                	jne    800c84 <devpipe_write+0x74>
			sys_yield();
  800c4a:	e8 f0 f4 ff ff       	call   80013f <sys_yield>
  800c4f:	eb e0                	jmp    800c31 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c54:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c58:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c5b:	89 c2                	mov    %eax,%edx
  800c5d:	c1 fa 1f             	sar    $0x1f,%edx
  800c60:	89 d1                	mov    %edx,%ecx
  800c62:	c1 e9 1b             	shr    $0x1b,%ecx
  800c65:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c68:	83 e2 1f             	and    $0x1f,%edx
  800c6b:	29 ca                	sub    %ecx,%edx
  800c6d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c71:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c75:	83 c0 01             	add    $0x1,%eax
  800c78:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800c7b:	83 c7 01             	add    $0x1,%edi
  800c7e:	eb ac                	jmp    800c2c <devpipe_write+0x1c>
	return i;
  800c80:	89 f8                	mov    %edi,%eax
  800c82:	eb 05                	jmp    800c89 <devpipe_write+0x79>
				return 0;
  800c84:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8c:	5b                   	pop    %ebx
  800c8d:	5e                   	pop    %esi
  800c8e:	5f                   	pop    %edi
  800c8f:	5d                   	pop    %ebp
  800c90:	c3                   	ret    

00800c91 <devpipe_read>:
{
  800c91:	55                   	push   %ebp
  800c92:	89 e5                	mov    %esp,%ebp
  800c94:	57                   	push   %edi
  800c95:	56                   	push   %esi
  800c96:	53                   	push   %ebx
  800c97:	83 ec 18             	sub    $0x18,%esp
  800c9a:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800c9d:	57                   	push   %edi
  800c9e:	e8 bc f6 ff ff       	call   80035f <fd2data>
  800ca3:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800ca5:	83 c4 10             	add    $0x10,%esp
  800ca8:	be 00 00 00 00       	mov    $0x0,%esi
  800cad:	3b 75 10             	cmp    0x10(%ebp),%esi
  800cb0:	74 47                	je     800cf9 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  800cb2:	8b 03                	mov    (%ebx),%eax
  800cb4:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cb7:	75 22                	jne    800cdb <devpipe_read+0x4a>
			if (i > 0)
  800cb9:	85 f6                	test   %esi,%esi
  800cbb:	75 14                	jne    800cd1 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  800cbd:	89 da                	mov    %ebx,%edx
  800cbf:	89 f8                	mov    %edi,%eax
  800cc1:	e8 e5 fe ff ff       	call   800bab <_pipeisclosed>
  800cc6:	85 c0                	test   %eax,%eax
  800cc8:	75 33                	jne    800cfd <devpipe_read+0x6c>
			sys_yield();
  800cca:	e8 70 f4 ff ff       	call   80013f <sys_yield>
  800ccf:	eb e1                	jmp    800cb2 <devpipe_read+0x21>
				return i;
  800cd1:	89 f0                	mov    %esi,%eax
}
  800cd3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd6:	5b                   	pop    %ebx
  800cd7:	5e                   	pop    %esi
  800cd8:	5f                   	pop    %edi
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cdb:	99                   	cltd   
  800cdc:	c1 ea 1b             	shr    $0x1b,%edx
  800cdf:	01 d0                	add    %edx,%eax
  800ce1:	83 e0 1f             	and    $0x1f,%eax
  800ce4:	29 d0                	sub    %edx,%eax
  800ce6:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800ceb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cee:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800cf1:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800cf4:	83 c6 01             	add    $0x1,%esi
  800cf7:	eb b4                	jmp    800cad <devpipe_read+0x1c>
	return i;
  800cf9:	89 f0                	mov    %esi,%eax
  800cfb:	eb d6                	jmp    800cd3 <devpipe_read+0x42>
				return 0;
  800cfd:	b8 00 00 00 00       	mov    $0x0,%eax
  800d02:	eb cf                	jmp    800cd3 <devpipe_read+0x42>

00800d04 <pipe>:
{
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	56                   	push   %esi
  800d08:	53                   	push   %ebx
  800d09:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800d0c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d0f:	50                   	push   %eax
  800d10:	e8 61 f6 ff ff       	call   800376 <fd_alloc>
  800d15:	89 c3                	mov    %eax,%ebx
  800d17:	83 c4 10             	add    $0x10,%esp
  800d1a:	85 c0                	test   %eax,%eax
  800d1c:	78 5b                	js     800d79 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d1e:	83 ec 04             	sub    $0x4,%esp
  800d21:	68 07 04 00 00       	push   $0x407
  800d26:	ff 75 f4             	pushl  -0xc(%ebp)
  800d29:	6a 00                	push   $0x0
  800d2b:	e8 2e f4 ff ff       	call   80015e <sys_page_alloc>
  800d30:	89 c3                	mov    %eax,%ebx
  800d32:	83 c4 10             	add    $0x10,%esp
  800d35:	85 c0                	test   %eax,%eax
  800d37:	78 40                	js     800d79 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  800d39:	83 ec 0c             	sub    $0xc,%esp
  800d3c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d3f:	50                   	push   %eax
  800d40:	e8 31 f6 ff ff       	call   800376 <fd_alloc>
  800d45:	89 c3                	mov    %eax,%ebx
  800d47:	83 c4 10             	add    $0x10,%esp
  800d4a:	85 c0                	test   %eax,%eax
  800d4c:	78 1b                	js     800d69 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d4e:	83 ec 04             	sub    $0x4,%esp
  800d51:	68 07 04 00 00       	push   $0x407
  800d56:	ff 75 f0             	pushl  -0x10(%ebp)
  800d59:	6a 00                	push   $0x0
  800d5b:	e8 fe f3 ff ff       	call   80015e <sys_page_alloc>
  800d60:	89 c3                	mov    %eax,%ebx
  800d62:	83 c4 10             	add    $0x10,%esp
  800d65:	85 c0                	test   %eax,%eax
  800d67:	79 19                	jns    800d82 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  800d69:	83 ec 08             	sub    $0x8,%esp
  800d6c:	ff 75 f4             	pushl  -0xc(%ebp)
  800d6f:	6a 00                	push   $0x0
  800d71:	e8 6d f4 ff ff       	call   8001e3 <sys_page_unmap>
  800d76:	83 c4 10             	add    $0x10,%esp
}
  800d79:	89 d8                	mov    %ebx,%eax
  800d7b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d7e:	5b                   	pop    %ebx
  800d7f:	5e                   	pop    %esi
  800d80:	5d                   	pop    %ebp
  800d81:	c3                   	ret    
	va = fd2data(fd0);
  800d82:	83 ec 0c             	sub    $0xc,%esp
  800d85:	ff 75 f4             	pushl  -0xc(%ebp)
  800d88:	e8 d2 f5 ff ff       	call   80035f <fd2data>
  800d8d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d8f:	83 c4 0c             	add    $0xc,%esp
  800d92:	68 07 04 00 00       	push   $0x407
  800d97:	50                   	push   %eax
  800d98:	6a 00                	push   $0x0
  800d9a:	e8 bf f3 ff ff       	call   80015e <sys_page_alloc>
  800d9f:	89 c3                	mov    %eax,%ebx
  800da1:	83 c4 10             	add    $0x10,%esp
  800da4:	85 c0                	test   %eax,%eax
  800da6:	0f 88 8c 00 00 00    	js     800e38 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dac:	83 ec 0c             	sub    $0xc,%esp
  800daf:	ff 75 f0             	pushl  -0x10(%ebp)
  800db2:	e8 a8 f5 ff ff       	call   80035f <fd2data>
  800db7:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dbe:	50                   	push   %eax
  800dbf:	6a 00                	push   $0x0
  800dc1:	56                   	push   %esi
  800dc2:	6a 00                	push   $0x0
  800dc4:	e8 d8 f3 ff ff       	call   8001a1 <sys_page_map>
  800dc9:	89 c3                	mov    %eax,%ebx
  800dcb:	83 c4 20             	add    $0x20,%esp
  800dce:	85 c0                	test   %eax,%eax
  800dd0:	78 58                	js     800e2a <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  800dd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dd5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800ddb:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800ddd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800de0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  800de7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dea:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800df0:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800df2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800df5:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800dfc:	83 ec 0c             	sub    $0xc,%esp
  800dff:	ff 75 f4             	pushl  -0xc(%ebp)
  800e02:	e8 48 f5 ff ff       	call   80034f <fd2num>
  800e07:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e0a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e0c:	83 c4 04             	add    $0x4,%esp
  800e0f:	ff 75 f0             	pushl  -0x10(%ebp)
  800e12:	e8 38 f5 ff ff       	call   80034f <fd2num>
  800e17:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e1a:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e1d:	83 c4 10             	add    $0x10,%esp
  800e20:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e25:	e9 4f ff ff ff       	jmp    800d79 <pipe+0x75>
	sys_page_unmap(0, va);
  800e2a:	83 ec 08             	sub    $0x8,%esp
  800e2d:	56                   	push   %esi
  800e2e:	6a 00                	push   $0x0
  800e30:	e8 ae f3 ff ff       	call   8001e3 <sys_page_unmap>
  800e35:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800e38:	83 ec 08             	sub    $0x8,%esp
  800e3b:	ff 75 f0             	pushl  -0x10(%ebp)
  800e3e:	6a 00                	push   $0x0
  800e40:	e8 9e f3 ff ff       	call   8001e3 <sys_page_unmap>
  800e45:	83 c4 10             	add    $0x10,%esp
  800e48:	e9 1c ff ff ff       	jmp    800d69 <pipe+0x65>

00800e4d <pipeisclosed>:
{
  800e4d:	55                   	push   %ebp
  800e4e:	89 e5                	mov    %esp,%ebp
  800e50:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e53:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e56:	50                   	push   %eax
  800e57:	ff 75 08             	pushl  0x8(%ebp)
  800e5a:	e8 66 f5 ff ff       	call   8003c5 <fd_lookup>
  800e5f:	83 c4 10             	add    $0x10,%esp
  800e62:	85 c0                	test   %eax,%eax
  800e64:	78 18                	js     800e7e <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  800e66:	83 ec 0c             	sub    $0xc,%esp
  800e69:	ff 75 f4             	pushl  -0xc(%ebp)
  800e6c:	e8 ee f4 ff ff       	call   80035f <fd2data>
	return _pipeisclosed(fd, p);
  800e71:	89 c2                	mov    %eax,%edx
  800e73:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e76:	e8 30 fd ff ff       	call   800bab <_pipeisclosed>
  800e7b:	83 c4 10             	add    $0x10,%esp
}
  800e7e:	c9                   	leave  
  800e7f:	c3                   	ret    

00800e80 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e80:	55                   	push   %ebp
  800e81:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e83:	b8 00 00 00 00       	mov    $0x0,%eax
  800e88:	5d                   	pop    %ebp
  800e89:	c3                   	ret    

00800e8a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e8a:	55                   	push   %ebp
  800e8b:	89 e5                	mov    %esp,%ebp
  800e8d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e90:	68 d6 1e 80 00       	push   $0x801ed6
  800e95:	ff 75 0c             	pushl  0xc(%ebp)
  800e98:	e8 5a 08 00 00       	call   8016f7 <strcpy>
	return 0;
}
  800e9d:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea2:	c9                   	leave  
  800ea3:	c3                   	ret    

00800ea4 <devcons_write>:
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	57                   	push   %edi
  800ea8:	56                   	push   %esi
  800ea9:	53                   	push   %ebx
  800eaa:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800eb0:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800eb5:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800ebb:	eb 2f                	jmp    800eec <devcons_write+0x48>
		m = n - tot;
  800ebd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ec0:	29 f3                	sub    %esi,%ebx
  800ec2:	83 fb 7f             	cmp    $0x7f,%ebx
  800ec5:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800eca:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800ecd:	83 ec 04             	sub    $0x4,%esp
  800ed0:	53                   	push   %ebx
  800ed1:	89 f0                	mov    %esi,%eax
  800ed3:	03 45 0c             	add    0xc(%ebp),%eax
  800ed6:	50                   	push   %eax
  800ed7:	57                   	push   %edi
  800ed8:	e8 a8 09 00 00       	call   801885 <memmove>
		sys_cputs(buf, m);
  800edd:	83 c4 08             	add    $0x8,%esp
  800ee0:	53                   	push   %ebx
  800ee1:	57                   	push   %edi
  800ee2:	e8 bb f1 ff ff       	call   8000a2 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800ee7:	01 de                	add    %ebx,%esi
  800ee9:	83 c4 10             	add    $0x10,%esp
  800eec:	3b 75 10             	cmp    0x10(%ebp),%esi
  800eef:	72 cc                	jb     800ebd <devcons_write+0x19>
}
  800ef1:	89 f0                	mov    %esi,%eax
  800ef3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ef6:	5b                   	pop    %ebx
  800ef7:	5e                   	pop    %esi
  800ef8:	5f                   	pop    %edi
  800ef9:	5d                   	pop    %ebp
  800efa:	c3                   	ret    

00800efb <devcons_read>:
{
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
  800efe:	83 ec 08             	sub    $0x8,%esp
  800f01:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800f06:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f0a:	75 07                	jne    800f13 <devcons_read+0x18>
}
  800f0c:	c9                   	leave  
  800f0d:	c3                   	ret    
		sys_yield();
  800f0e:	e8 2c f2 ff ff       	call   80013f <sys_yield>
	while ((c = sys_cgetc()) == 0)
  800f13:	e8 a8 f1 ff ff       	call   8000c0 <sys_cgetc>
  800f18:	85 c0                	test   %eax,%eax
  800f1a:	74 f2                	je     800f0e <devcons_read+0x13>
	if (c < 0)
  800f1c:	85 c0                	test   %eax,%eax
  800f1e:	78 ec                	js     800f0c <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  800f20:	83 f8 04             	cmp    $0x4,%eax
  800f23:	74 0c                	je     800f31 <devcons_read+0x36>
	*(char*)vbuf = c;
  800f25:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f28:	88 02                	mov    %al,(%edx)
	return 1;
  800f2a:	b8 01 00 00 00       	mov    $0x1,%eax
  800f2f:	eb db                	jmp    800f0c <devcons_read+0x11>
		return 0;
  800f31:	b8 00 00 00 00       	mov    $0x0,%eax
  800f36:	eb d4                	jmp    800f0c <devcons_read+0x11>

00800f38 <cputchar>:
{
  800f38:	55                   	push   %ebp
  800f39:	89 e5                	mov    %esp,%ebp
  800f3b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f41:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800f44:	6a 01                	push   $0x1
  800f46:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f49:	50                   	push   %eax
  800f4a:	e8 53 f1 ff ff       	call   8000a2 <sys_cputs>
}
  800f4f:	83 c4 10             	add    $0x10,%esp
  800f52:	c9                   	leave  
  800f53:	c3                   	ret    

00800f54 <getchar>:
{
  800f54:	55                   	push   %ebp
  800f55:	89 e5                	mov    %esp,%ebp
  800f57:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800f5a:	6a 01                	push   $0x1
  800f5c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f5f:	50                   	push   %eax
  800f60:	6a 00                	push   $0x0
  800f62:	e8 cf f6 ff ff       	call   800636 <read>
	if (r < 0)
  800f67:	83 c4 10             	add    $0x10,%esp
  800f6a:	85 c0                	test   %eax,%eax
  800f6c:	78 08                	js     800f76 <getchar+0x22>
	if (r < 1)
  800f6e:	85 c0                	test   %eax,%eax
  800f70:	7e 06                	jle    800f78 <getchar+0x24>
	return c;
  800f72:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800f76:	c9                   	leave  
  800f77:	c3                   	ret    
		return -E_EOF;
  800f78:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800f7d:	eb f7                	jmp    800f76 <getchar+0x22>

00800f7f <iscons>:
{
  800f7f:	55                   	push   %ebp
  800f80:	89 e5                	mov    %esp,%ebp
  800f82:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f85:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f88:	50                   	push   %eax
  800f89:	ff 75 08             	pushl  0x8(%ebp)
  800f8c:	e8 34 f4 ff ff       	call   8003c5 <fd_lookup>
  800f91:	83 c4 10             	add    $0x10,%esp
  800f94:	85 c0                	test   %eax,%eax
  800f96:	78 11                	js     800fa9 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  800f98:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f9b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fa1:	39 10                	cmp    %edx,(%eax)
  800fa3:	0f 94 c0             	sete   %al
  800fa6:	0f b6 c0             	movzbl %al,%eax
}
  800fa9:	c9                   	leave  
  800faa:	c3                   	ret    

00800fab <opencons>:
{
  800fab:	55                   	push   %ebp
  800fac:	89 e5                	mov    %esp,%ebp
  800fae:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800fb1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fb4:	50                   	push   %eax
  800fb5:	e8 bc f3 ff ff       	call   800376 <fd_alloc>
  800fba:	83 c4 10             	add    $0x10,%esp
  800fbd:	85 c0                	test   %eax,%eax
  800fbf:	78 3a                	js     800ffb <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fc1:	83 ec 04             	sub    $0x4,%esp
  800fc4:	68 07 04 00 00       	push   $0x407
  800fc9:	ff 75 f4             	pushl  -0xc(%ebp)
  800fcc:	6a 00                	push   $0x0
  800fce:	e8 8b f1 ff ff       	call   80015e <sys_page_alloc>
  800fd3:	83 c4 10             	add    $0x10,%esp
  800fd6:	85 c0                	test   %eax,%eax
  800fd8:	78 21                	js     800ffb <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  800fda:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fdd:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fe3:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800fe5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fe8:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800fef:	83 ec 0c             	sub    $0xc,%esp
  800ff2:	50                   	push   %eax
  800ff3:	e8 57 f3 ff ff       	call   80034f <fd2num>
  800ff8:	83 c4 10             	add    $0x10,%esp
}
  800ffb:	c9                   	leave  
  800ffc:	c3                   	ret    

00800ffd <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800ffd:	55                   	push   %ebp
  800ffe:	89 e5                	mov    %esp,%ebp
  801000:	56                   	push   %esi
  801001:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801002:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801005:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80100b:	e8 10 f1 ff ff       	call   800120 <sys_getenvid>
  801010:	83 ec 0c             	sub    $0xc,%esp
  801013:	ff 75 0c             	pushl  0xc(%ebp)
  801016:	ff 75 08             	pushl  0x8(%ebp)
  801019:	56                   	push   %esi
  80101a:	50                   	push   %eax
  80101b:	68 e4 1e 80 00       	push   $0x801ee4
  801020:	e8 b3 00 00 00       	call   8010d8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801025:	83 c4 18             	add    $0x18,%esp
  801028:	53                   	push   %ebx
  801029:	ff 75 10             	pushl  0x10(%ebp)
  80102c:	e8 56 00 00 00       	call   801087 <vcprintf>
	cprintf("\n");
  801031:	c7 04 24 cf 1e 80 00 	movl   $0x801ecf,(%esp)
  801038:	e8 9b 00 00 00       	call   8010d8 <cprintf>
  80103d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801040:	cc                   	int3   
  801041:	eb fd                	jmp    801040 <_panic+0x43>

00801043 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801043:	55                   	push   %ebp
  801044:	89 e5                	mov    %esp,%ebp
  801046:	53                   	push   %ebx
  801047:	83 ec 04             	sub    $0x4,%esp
  80104a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80104d:	8b 13                	mov    (%ebx),%edx
  80104f:	8d 42 01             	lea    0x1(%edx),%eax
  801052:	89 03                	mov    %eax,(%ebx)
  801054:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801057:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80105b:	3d ff 00 00 00       	cmp    $0xff,%eax
  801060:	74 09                	je     80106b <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801062:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801066:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801069:	c9                   	leave  
  80106a:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80106b:	83 ec 08             	sub    $0x8,%esp
  80106e:	68 ff 00 00 00       	push   $0xff
  801073:	8d 43 08             	lea    0x8(%ebx),%eax
  801076:	50                   	push   %eax
  801077:	e8 26 f0 ff ff       	call   8000a2 <sys_cputs>
		b->idx = 0;
  80107c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801082:	83 c4 10             	add    $0x10,%esp
  801085:	eb db                	jmp    801062 <putch+0x1f>

00801087 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801087:	55                   	push   %ebp
  801088:	89 e5                	mov    %esp,%ebp
  80108a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801090:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801097:	00 00 00 
	b.cnt = 0;
  80109a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010a1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010a4:	ff 75 0c             	pushl  0xc(%ebp)
  8010a7:	ff 75 08             	pushl  0x8(%ebp)
  8010aa:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010b0:	50                   	push   %eax
  8010b1:	68 43 10 80 00       	push   $0x801043
  8010b6:	e8 1a 01 00 00       	call   8011d5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010bb:	83 c4 08             	add    $0x8,%esp
  8010be:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010c4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010ca:	50                   	push   %eax
  8010cb:	e8 d2 ef ff ff       	call   8000a2 <sys_cputs>

	return b.cnt;
}
  8010d0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010d6:	c9                   	leave  
  8010d7:	c3                   	ret    

008010d8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010d8:	55                   	push   %ebp
  8010d9:	89 e5                	mov    %esp,%ebp
  8010db:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010de:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010e1:	50                   	push   %eax
  8010e2:	ff 75 08             	pushl  0x8(%ebp)
  8010e5:	e8 9d ff ff ff       	call   801087 <vcprintf>
	va_end(ap);

	return cnt;
}
  8010ea:	c9                   	leave  
  8010eb:	c3                   	ret    

008010ec <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010ec:	55                   	push   %ebp
  8010ed:	89 e5                	mov    %esp,%ebp
  8010ef:	57                   	push   %edi
  8010f0:	56                   	push   %esi
  8010f1:	53                   	push   %ebx
  8010f2:	83 ec 1c             	sub    $0x1c,%esp
  8010f5:	89 c7                	mov    %eax,%edi
  8010f7:	89 d6                	mov    %edx,%esi
  8010f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8010fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801102:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801105:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801108:	bb 00 00 00 00       	mov    $0x0,%ebx
  80110d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801110:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801113:	39 d3                	cmp    %edx,%ebx
  801115:	72 05                	jb     80111c <printnum+0x30>
  801117:	39 45 10             	cmp    %eax,0x10(%ebp)
  80111a:	77 7a                	ja     801196 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80111c:	83 ec 0c             	sub    $0xc,%esp
  80111f:	ff 75 18             	pushl  0x18(%ebp)
  801122:	8b 45 14             	mov    0x14(%ebp),%eax
  801125:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801128:	53                   	push   %ebx
  801129:	ff 75 10             	pushl  0x10(%ebp)
  80112c:	83 ec 08             	sub    $0x8,%esp
  80112f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801132:	ff 75 e0             	pushl  -0x20(%ebp)
  801135:	ff 75 dc             	pushl  -0x24(%ebp)
  801138:	ff 75 d8             	pushl  -0x28(%ebp)
  80113b:	e8 30 0a 00 00       	call   801b70 <__udivdi3>
  801140:	83 c4 18             	add    $0x18,%esp
  801143:	52                   	push   %edx
  801144:	50                   	push   %eax
  801145:	89 f2                	mov    %esi,%edx
  801147:	89 f8                	mov    %edi,%eax
  801149:	e8 9e ff ff ff       	call   8010ec <printnum>
  80114e:	83 c4 20             	add    $0x20,%esp
  801151:	eb 13                	jmp    801166 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801153:	83 ec 08             	sub    $0x8,%esp
  801156:	56                   	push   %esi
  801157:	ff 75 18             	pushl  0x18(%ebp)
  80115a:	ff d7                	call   *%edi
  80115c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80115f:	83 eb 01             	sub    $0x1,%ebx
  801162:	85 db                	test   %ebx,%ebx
  801164:	7f ed                	jg     801153 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801166:	83 ec 08             	sub    $0x8,%esp
  801169:	56                   	push   %esi
  80116a:	83 ec 04             	sub    $0x4,%esp
  80116d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801170:	ff 75 e0             	pushl  -0x20(%ebp)
  801173:	ff 75 dc             	pushl  -0x24(%ebp)
  801176:	ff 75 d8             	pushl  -0x28(%ebp)
  801179:	e8 12 0b 00 00       	call   801c90 <__umoddi3>
  80117e:	83 c4 14             	add    $0x14,%esp
  801181:	0f be 80 07 1f 80 00 	movsbl 0x801f07(%eax),%eax
  801188:	50                   	push   %eax
  801189:	ff d7                	call   *%edi
}
  80118b:	83 c4 10             	add    $0x10,%esp
  80118e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801191:	5b                   	pop    %ebx
  801192:	5e                   	pop    %esi
  801193:	5f                   	pop    %edi
  801194:	5d                   	pop    %ebp
  801195:	c3                   	ret    
  801196:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801199:	eb c4                	jmp    80115f <printnum+0x73>

0080119b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80119b:	55                   	push   %ebp
  80119c:	89 e5                	mov    %esp,%ebp
  80119e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011a1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011a5:	8b 10                	mov    (%eax),%edx
  8011a7:	3b 50 04             	cmp    0x4(%eax),%edx
  8011aa:	73 0a                	jae    8011b6 <sprintputch+0x1b>
		*b->buf++ = ch;
  8011ac:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011af:	89 08                	mov    %ecx,(%eax)
  8011b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b4:	88 02                	mov    %al,(%edx)
}
  8011b6:	5d                   	pop    %ebp
  8011b7:	c3                   	ret    

008011b8 <printfmt>:
{
  8011b8:	55                   	push   %ebp
  8011b9:	89 e5                	mov    %esp,%ebp
  8011bb:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8011be:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011c1:	50                   	push   %eax
  8011c2:	ff 75 10             	pushl  0x10(%ebp)
  8011c5:	ff 75 0c             	pushl  0xc(%ebp)
  8011c8:	ff 75 08             	pushl  0x8(%ebp)
  8011cb:	e8 05 00 00 00       	call   8011d5 <vprintfmt>
}
  8011d0:	83 c4 10             	add    $0x10,%esp
  8011d3:	c9                   	leave  
  8011d4:	c3                   	ret    

008011d5 <vprintfmt>:
{
  8011d5:	55                   	push   %ebp
  8011d6:	89 e5                	mov    %esp,%ebp
  8011d8:	57                   	push   %edi
  8011d9:	56                   	push   %esi
  8011da:	53                   	push   %ebx
  8011db:	83 ec 2c             	sub    $0x2c,%esp
  8011de:	8b 75 08             	mov    0x8(%ebp),%esi
  8011e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8011e4:	8b 7d 10             	mov    0x10(%ebp),%edi
  8011e7:	e9 c1 03 00 00       	jmp    8015ad <vprintfmt+0x3d8>
		padc = ' ';
  8011ec:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8011f0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8011f7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8011fe:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  801205:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80120a:	8d 47 01             	lea    0x1(%edi),%eax
  80120d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801210:	0f b6 17             	movzbl (%edi),%edx
  801213:	8d 42 dd             	lea    -0x23(%edx),%eax
  801216:	3c 55                	cmp    $0x55,%al
  801218:	0f 87 12 04 00 00    	ja     801630 <vprintfmt+0x45b>
  80121e:	0f b6 c0             	movzbl %al,%eax
  801221:	ff 24 85 40 20 80 00 	jmp    *0x802040(,%eax,4)
  801228:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80122b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80122f:	eb d9                	jmp    80120a <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  801231:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  801234:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801238:	eb d0                	jmp    80120a <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80123a:	0f b6 d2             	movzbl %dl,%edx
  80123d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801240:	b8 00 00 00 00       	mov    $0x0,%eax
  801245:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801248:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80124b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80124f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801252:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801255:	83 f9 09             	cmp    $0x9,%ecx
  801258:	77 55                	ja     8012af <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  80125a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80125d:	eb e9                	jmp    801248 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  80125f:	8b 45 14             	mov    0x14(%ebp),%eax
  801262:	8b 00                	mov    (%eax),%eax
  801264:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801267:	8b 45 14             	mov    0x14(%ebp),%eax
  80126a:	8d 40 04             	lea    0x4(%eax),%eax
  80126d:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801270:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801273:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801277:	79 91                	jns    80120a <vprintfmt+0x35>
				width = precision, precision = -1;
  801279:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80127c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80127f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801286:	eb 82                	jmp    80120a <vprintfmt+0x35>
  801288:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80128b:	85 c0                	test   %eax,%eax
  80128d:	ba 00 00 00 00       	mov    $0x0,%edx
  801292:	0f 49 d0             	cmovns %eax,%edx
  801295:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801298:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80129b:	e9 6a ff ff ff       	jmp    80120a <vprintfmt+0x35>
  8012a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8012a3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012aa:	e9 5b ff ff ff       	jmp    80120a <vprintfmt+0x35>
  8012af:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8012b2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012b5:	eb bc                	jmp    801273 <vprintfmt+0x9e>
			lflag++;
  8012b7:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8012bd:	e9 48 ff ff ff       	jmp    80120a <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8012c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8012c5:	8d 78 04             	lea    0x4(%eax),%edi
  8012c8:	83 ec 08             	sub    $0x8,%esp
  8012cb:	53                   	push   %ebx
  8012cc:	ff 30                	pushl  (%eax)
  8012ce:	ff d6                	call   *%esi
			break;
  8012d0:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8012d3:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8012d6:	e9 cf 02 00 00       	jmp    8015aa <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8012db:	8b 45 14             	mov    0x14(%ebp),%eax
  8012de:	8d 78 04             	lea    0x4(%eax),%edi
  8012e1:	8b 00                	mov    (%eax),%eax
  8012e3:	99                   	cltd   
  8012e4:	31 d0                	xor    %edx,%eax
  8012e6:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8012e8:	83 f8 0f             	cmp    $0xf,%eax
  8012eb:	7f 23                	jg     801310 <vprintfmt+0x13b>
  8012ed:	8b 14 85 a0 21 80 00 	mov    0x8021a0(,%eax,4),%edx
  8012f4:	85 d2                	test   %edx,%edx
  8012f6:	74 18                	je     801310 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8012f8:	52                   	push   %edx
  8012f9:	68 9d 1e 80 00       	push   $0x801e9d
  8012fe:	53                   	push   %ebx
  8012ff:	56                   	push   %esi
  801300:	e8 b3 fe ff ff       	call   8011b8 <printfmt>
  801305:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801308:	89 7d 14             	mov    %edi,0x14(%ebp)
  80130b:	e9 9a 02 00 00       	jmp    8015aa <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  801310:	50                   	push   %eax
  801311:	68 1f 1f 80 00       	push   $0x801f1f
  801316:	53                   	push   %ebx
  801317:	56                   	push   %esi
  801318:	e8 9b fe ff ff       	call   8011b8 <printfmt>
  80131d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801320:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  801323:	e9 82 02 00 00       	jmp    8015aa <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  801328:	8b 45 14             	mov    0x14(%ebp),%eax
  80132b:	83 c0 04             	add    $0x4,%eax
  80132e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801331:	8b 45 14             	mov    0x14(%ebp),%eax
  801334:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801336:	85 ff                	test   %edi,%edi
  801338:	b8 18 1f 80 00       	mov    $0x801f18,%eax
  80133d:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801340:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801344:	0f 8e bd 00 00 00    	jle    801407 <vprintfmt+0x232>
  80134a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80134e:	75 0e                	jne    80135e <vprintfmt+0x189>
  801350:	89 75 08             	mov    %esi,0x8(%ebp)
  801353:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801356:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801359:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80135c:	eb 6d                	jmp    8013cb <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  80135e:	83 ec 08             	sub    $0x8,%esp
  801361:	ff 75 d0             	pushl  -0x30(%ebp)
  801364:	57                   	push   %edi
  801365:	e8 6e 03 00 00       	call   8016d8 <strnlen>
  80136a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80136d:	29 c1                	sub    %eax,%ecx
  80136f:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  801372:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801375:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801379:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80137c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80137f:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  801381:	eb 0f                	jmp    801392 <vprintfmt+0x1bd>
					putch(padc, putdat);
  801383:	83 ec 08             	sub    $0x8,%esp
  801386:	53                   	push   %ebx
  801387:	ff 75 e0             	pushl  -0x20(%ebp)
  80138a:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80138c:	83 ef 01             	sub    $0x1,%edi
  80138f:	83 c4 10             	add    $0x10,%esp
  801392:	85 ff                	test   %edi,%edi
  801394:	7f ed                	jg     801383 <vprintfmt+0x1ae>
  801396:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801399:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80139c:	85 c9                	test   %ecx,%ecx
  80139e:	b8 00 00 00 00       	mov    $0x0,%eax
  8013a3:	0f 49 c1             	cmovns %ecx,%eax
  8013a6:	29 c1                	sub    %eax,%ecx
  8013a8:	89 75 08             	mov    %esi,0x8(%ebp)
  8013ab:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8013ae:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8013b1:	89 cb                	mov    %ecx,%ebx
  8013b3:	eb 16                	jmp    8013cb <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8013b5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8013b9:	75 31                	jne    8013ec <vprintfmt+0x217>
					putch(ch, putdat);
  8013bb:	83 ec 08             	sub    $0x8,%esp
  8013be:	ff 75 0c             	pushl  0xc(%ebp)
  8013c1:	50                   	push   %eax
  8013c2:	ff 55 08             	call   *0x8(%ebp)
  8013c5:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8013c8:	83 eb 01             	sub    $0x1,%ebx
  8013cb:	83 c7 01             	add    $0x1,%edi
  8013ce:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8013d2:	0f be c2             	movsbl %dl,%eax
  8013d5:	85 c0                	test   %eax,%eax
  8013d7:	74 59                	je     801432 <vprintfmt+0x25d>
  8013d9:	85 f6                	test   %esi,%esi
  8013db:	78 d8                	js     8013b5 <vprintfmt+0x1e0>
  8013dd:	83 ee 01             	sub    $0x1,%esi
  8013e0:	79 d3                	jns    8013b5 <vprintfmt+0x1e0>
  8013e2:	89 df                	mov    %ebx,%edi
  8013e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8013e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8013ea:	eb 37                	jmp    801423 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8013ec:	0f be d2             	movsbl %dl,%edx
  8013ef:	83 ea 20             	sub    $0x20,%edx
  8013f2:	83 fa 5e             	cmp    $0x5e,%edx
  8013f5:	76 c4                	jbe    8013bb <vprintfmt+0x1e6>
					putch('?', putdat);
  8013f7:	83 ec 08             	sub    $0x8,%esp
  8013fa:	ff 75 0c             	pushl  0xc(%ebp)
  8013fd:	6a 3f                	push   $0x3f
  8013ff:	ff 55 08             	call   *0x8(%ebp)
  801402:	83 c4 10             	add    $0x10,%esp
  801405:	eb c1                	jmp    8013c8 <vprintfmt+0x1f3>
  801407:	89 75 08             	mov    %esi,0x8(%ebp)
  80140a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80140d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801410:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801413:	eb b6                	jmp    8013cb <vprintfmt+0x1f6>
				putch(' ', putdat);
  801415:	83 ec 08             	sub    $0x8,%esp
  801418:	53                   	push   %ebx
  801419:	6a 20                	push   $0x20
  80141b:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80141d:	83 ef 01             	sub    $0x1,%edi
  801420:	83 c4 10             	add    $0x10,%esp
  801423:	85 ff                	test   %edi,%edi
  801425:	7f ee                	jg     801415 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  801427:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80142a:	89 45 14             	mov    %eax,0x14(%ebp)
  80142d:	e9 78 01 00 00       	jmp    8015aa <vprintfmt+0x3d5>
  801432:	89 df                	mov    %ebx,%edi
  801434:	8b 75 08             	mov    0x8(%ebp),%esi
  801437:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80143a:	eb e7                	jmp    801423 <vprintfmt+0x24e>
	if (lflag >= 2)
  80143c:	83 f9 01             	cmp    $0x1,%ecx
  80143f:	7e 3f                	jle    801480 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  801441:	8b 45 14             	mov    0x14(%ebp),%eax
  801444:	8b 50 04             	mov    0x4(%eax),%edx
  801447:	8b 00                	mov    (%eax),%eax
  801449:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80144c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80144f:	8b 45 14             	mov    0x14(%ebp),%eax
  801452:	8d 40 08             	lea    0x8(%eax),%eax
  801455:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  801458:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80145c:	79 5c                	jns    8014ba <vprintfmt+0x2e5>
				putch('-', putdat);
  80145e:	83 ec 08             	sub    $0x8,%esp
  801461:	53                   	push   %ebx
  801462:	6a 2d                	push   $0x2d
  801464:	ff d6                	call   *%esi
				num = -(long long) num;
  801466:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801469:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80146c:	f7 da                	neg    %edx
  80146e:	83 d1 00             	adc    $0x0,%ecx
  801471:	f7 d9                	neg    %ecx
  801473:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801476:	b8 0a 00 00 00       	mov    $0xa,%eax
  80147b:	e9 10 01 00 00       	jmp    801590 <vprintfmt+0x3bb>
	else if (lflag)
  801480:	85 c9                	test   %ecx,%ecx
  801482:	75 1b                	jne    80149f <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  801484:	8b 45 14             	mov    0x14(%ebp),%eax
  801487:	8b 00                	mov    (%eax),%eax
  801489:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80148c:	89 c1                	mov    %eax,%ecx
  80148e:	c1 f9 1f             	sar    $0x1f,%ecx
  801491:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801494:	8b 45 14             	mov    0x14(%ebp),%eax
  801497:	8d 40 04             	lea    0x4(%eax),%eax
  80149a:	89 45 14             	mov    %eax,0x14(%ebp)
  80149d:	eb b9                	jmp    801458 <vprintfmt+0x283>
		return va_arg(*ap, long);
  80149f:	8b 45 14             	mov    0x14(%ebp),%eax
  8014a2:	8b 00                	mov    (%eax),%eax
  8014a4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014a7:	89 c1                	mov    %eax,%ecx
  8014a9:	c1 f9 1f             	sar    $0x1f,%ecx
  8014ac:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014af:	8b 45 14             	mov    0x14(%ebp),%eax
  8014b2:	8d 40 04             	lea    0x4(%eax),%eax
  8014b5:	89 45 14             	mov    %eax,0x14(%ebp)
  8014b8:	eb 9e                	jmp    801458 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8014ba:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014bd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8014c0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014c5:	e9 c6 00 00 00       	jmp    801590 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8014ca:	83 f9 01             	cmp    $0x1,%ecx
  8014cd:	7e 18                	jle    8014e7 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8014cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8014d2:	8b 10                	mov    (%eax),%edx
  8014d4:	8b 48 04             	mov    0x4(%eax),%ecx
  8014d7:	8d 40 08             	lea    0x8(%eax),%eax
  8014da:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8014dd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014e2:	e9 a9 00 00 00       	jmp    801590 <vprintfmt+0x3bb>
	else if (lflag)
  8014e7:	85 c9                	test   %ecx,%ecx
  8014e9:	75 1a                	jne    801505 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  8014eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ee:	8b 10                	mov    (%eax),%edx
  8014f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014f5:	8d 40 04             	lea    0x4(%eax),%eax
  8014f8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8014fb:	b8 0a 00 00 00       	mov    $0xa,%eax
  801500:	e9 8b 00 00 00       	jmp    801590 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  801505:	8b 45 14             	mov    0x14(%ebp),%eax
  801508:	8b 10                	mov    (%eax),%edx
  80150a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80150f:	8d 40 04             	lea    0x4(%eax),%eax
  801512:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801515:	b8 0a 00 00 00       	mov    $0xa,%eax
  80151a:	eb 74                	jmp    801590 <vprintfmt+0x3bb>
	if (lflag >= 2)
  80151c:	83 f9 01             	cmp    $0x1,%ecx
  80151f:	7e 15                	jle    801536 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  801521:	8b 45 14             	mov    0x14(%ebp),%eax
  801524:	8b 10                	mov    (%eax),%edx
  801526:	8b 48 04             	mov    0x4(%eax),%ecx
  801529:	8d 40 08             	lea    0x8(%eax),%eax
  80152c:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80152f:	b8 08 00 00 00       	mov    $0x8,%eax
  801534:	eb 5a                	jmp    801590 <vprintfmt+0x3bb>
	else if (lflag)
  801536:	85 c9                	test   %ecx,%ecx
  801538:	75 17                	jne    801551 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  80153a:	8b 45 14             	mov    0x14(%ebp),%eax
  80153d:	8b 10                	mov    (%eax),%edx
  80153f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801544:	8d 40 04             	lea    0x4(%eax),%eax
  801547:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80154a:	b8 08 00 00 00       	mov    $0x8,%eax
  80154f:	eb 3f                	jmp    801590 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  801551:	8b 45 14             	mov    0x14(%ebp),%eax
  801554:	8b 10                	mov    (%eax),%edx
  801556:	b9 00 00 00 00       	mov    $0x0,%ecx
  80155b:	8d 40 04             	lea    0x4(%eax),%eax
  80155e:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801561:	b8 08 00 00 00       	mov    $0x8,%eax
  801566:	eb 28                	jmp    801590 <vprintfmt+0x3bb>
			putch('0', putdat);
  801568:	83 ec 08             	sub    $0x8,%esp
  80156b:	53                   	push   %ebx
  80156c:	6a 30                	push   $0x30
  80156e:	ff d6                	call   *%esi
			putch('x', putdat);
  801570:	83 c4 08             	add    $0x8,%esp
  801573:	53                   	push   %ebx
  801574:	6a 78                	push   $0x78
  801576:	ff d6                	call   *%esi
			num = (unsigned long long)
  801578:	8b 45 14             	mov    0x14(%ebp),%eax
  80157b:	8b 10                	mov    (%eax),%edx
  80157d:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801582:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801585:	8d 40 04             	lea    0x4(%eax),%eax
  801588:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80158b:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  801590:	83 ec 0c             	sub    $0xc,%esp
  801593:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801597:	57                   	push   %edi
  801598:	ff 75 e0             	pushl  -0x20(%ebp)
  80159b:	50                   	push   %eax
  80159c:	51                   	push   %ecx
  80159d:	52                   	push   %edx
  80159e:	89 da                	mov    %ebx,%edx
  8015a0:	89 f0                	mov    %esi,%eax
  8015a2:	e8 45 fb ff ff       	call   8010ec <printnum>
			break;
  8015a7:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8015aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8015ad:	83 c7 01             	add    $0x1,%edi
  8015b0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8015b4:	83 f8 25             	cmp    $0x25,%eax
  8015b7:	0f 84 2f fc ff ff    	je     8011ec <vprintfmt+0x17>
			if (ch == '\0')
  8015bd:	85 c0                	test   %eax,%eax
  8015bf:	0f 84 8b 00 00 00    	je     801650 <vprintfmt+0x47b>
			putch(ch, putdat);
  8015c5:	83 ec 08             	sub    $0x8,%esp
  8015c8:	53                   	push   %ebx
  8015c9:	50                   	push   %eax
  8015ca:	ff d6                	call   *%esi
  8015cc:	83 c4 10             	add    $0x10,%esp
  8015cf:	eb dc                	jmp    8015ad <vprintfmt+0x3d8>
	if (lflag >= 2)
  8015d1:	83 f9 01             	cmp    $0x1,%ecx
  8015d4:	7e 15                	jle    8015eb <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  8015d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8015d9:	8b 10                	mov    (%eax),%edx
  8015db:	8b 48 04             	mov    0x4(%eax),%ecx
  8015de:	8d 40 08             	lea    0x8(%eax),%eax
  8015e1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015e4:	b8 10 00 00 00       	mov    $0x10,%eax
  8015e9:	eb a5                	jmp    801590 <vprintfmt+0x3bb>
	else if (lflag)
  8015eb:	85 c9                	test   %ecx,%ecx
  8015ed:	75 17                	jne    801606 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  8015ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8015f2:	8b 10                	mov    (%eax),%edx
  8015f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015f9:	8d 40 04             	lea    0x4(%eax),%eax
  8015fc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015ff:	b8 10 00 00 00       	mov    $0x10,%eax
  801604:	eb 8a                	jmp    801590 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  801606:	8b 45 14             	mov    0x14(%ebp),%eax
  801609:	8b 10                	mov    (%eax),%edx
  80160b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801610:	8d 40 04             	lea    0x4(%eax),%eax
  801613:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801616:	b8 10 00 00 00       	mov    $0x10,%eax
  80161b:	e9 70 ff ff ff       	jmp    801590 <vprintfmt+0x3bb>
			putch(ch, putdat);
  801620:	83 ec 08             	sub    $0x8,%esp
  801623:	53                   	push   %ebx
  801624:	6a 25                	push   $0x25
  801626:	ff d6                	call   *%esi
			break;
  801628:	83 c4 10             	add    $0x10,%esp
  80162b:	e9 7a ff ff ff       	jmp    8015aa <vprintfmt+0x3d5>
			putch('%', putdat);
  801630:	83 ec 08             	sub    $0x8,%esp
  801633:	53                   	push   %ebx
  801634:	6a 25                	push   $0x25
  801636:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801638:	83 c4 10             	add    $0x10,%esp
  80163b:	89 f8                	mov    %edi,%eax
  80163d:	eb 03                	jmp    801642 <vprintfmt+0x46d>
  80163f:	83 e8 01             	sub    $0x1,%eax
  801642:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801646:	75 f7                	jne    80163f <vprintfmt+0x46a>
  801648:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80164b:	e9 5a ff ff ff       	jmp    8015aa <vprintfmt+0x3d5>
}
  801650:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801653:	5b                   	pop    %ebx
  801654:	5e                   	pop    %esi
  801655:	5f                   	pop    %edi
  801656:	5d                   	pop    %ebp
  801657:	c3                   	ret    

00801658 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801658:	55                   	push   %ebp
  801659:	89 e5                	mov    %esp,%ebp
  80165b:	83 ec 18             	sub    $0x18,%esp
  80165e:	8b 45 08             	mov    0x8(%ebp),%eax
  801661:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801664:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801667:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80166b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80166e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801675:	85 c0                	test   %eax,%eax
  801677:	74 26                	je     80169f <vsnprintf+0x47>
  801679:	85 d2                	test   %edx,%edx
  80167b:	7e 22                	jle    80169f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80167d:	ff 75 14             	pushl  0x14(%ebp)
  801680:	ff 75 10             	pushl  0x10(%ebp)
  801683:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801686:	50                   	push   %eax
  801687:	68 9b 11 80 00       	push   $0x80119b
  80168c:	e8 44 fb ff ff       	call   8011d5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801691:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801694:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801697:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80169a:	83 c4 10             	add    $0x10,%esp
}
  80169d:	c9                   	leave  
  80169e:	c3                   	ret    
		return -E_INVAL;
  80169f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016a4:	eb f7                	jmp    80169d <vsnprintf+0x45>

008016a6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016a6:	55                   	push   %ebp
  8016a7:	89 e5                	mov    %esp,%ebp
  8016a9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016ac:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016af:	50                   	push   %eax
  8016b0:	ff 75 10             	pushl  0x10(%ebp)
  8016b3:	ff 75 0c             	pushl  0xc(%ebp)
  8016b6:	ff 75 08             	pushl  0x8(%ebp)
  8016b9:	e8 9a ff ff ff       	call   801658 <vsnprintf>
	va_end(ap);

	return rc;
}
  8016be:	c9                   	leave  
  8016bf:	c3                   	ret    

008016c0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016c0:	55                   	push   %ebp
  8016c1:	89 e5                	mov    %esp,%ebp
  8016c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8016cb:	eb 03                	jmp    8016d0 <strlen+0x10>
		n++;
  8016cd:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8016d0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016d4:	75 f7                	jne    8016cd <strlen+0xd>
	return n;
}
  8016d6:	5d                   	pop    %ebp
  8016d7:	c3                   	ret    

008016d8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016d8:	55                   	push   %ebp
  8016d9:	89 e5                	mov    %esp,%ebp
  8016db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016de:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8016e6:	eb 03                	jmp    8016eb <strnlen+0x13>
		n++;
  8016e8:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016eb:	39 d0                	cmp    %edx,%eax
  8016ed:	74 06                	je     8016f5 <strnlen+0x1d>
  8016ef:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8016f3:	75 f3                	jne    8016e8 <strnlen+0x10>
	return n;
}
  8016f5:	5d                   	pop    %ebp
  8016f6:	c3                   	ret    

008016f7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016f7:	55                   	push   %ebp
  8016f8:	89 e5                	mov    %esp,%ebp
  8016fa:	53                   	push   %ebx
  8016fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8016fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801701:	89 c2                	mov    %eax,%edx
  801703:	83 c1 01             	add    $0x1,%ecx
  801706:	83 c2 01             	add    $0x1,%edx
  801709:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80170d:	88 5a ff             	mov    %bl,-0x1(%edx)
  801710:	84 db                	test   %bl,%bl
  801712:	75 ef                	jne    801703 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801714:	5b                   	pop    %ebx
  801715:	5d                   	pop    %ebp
  801716:	c3                   	ret    

00801717 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801717:	55                   	push   %ebp
  801718:	89 e5                	mov    %esp,%ebp
  80171a:	53                   	push   %ebx
  80171b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80171e:	53                   	push   %ebx
  80171f:	e8 9c ff ff ff       	call   8016c0 <strlen>
  801724:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801727:	ff 75 0c             	pushl  0xc(%ebp)
  80172a:	01 d8                	add    %ebx,%eax
  80172c:	50                   	push   %eax
  80172d:	e8 c5 ff ff ff       	call   8016f7 <strcpy>
	return dst;
}
  801732:	89 d8                	mov    %ebx,%eax
  801734:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801737:	c9                   	leave  
  801738:	c3                   	ret    

00801739 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801739:	55                   	push   %ebp
  80173a:	89 e5                	mov    %esp,%ebp
  80173c:	56                   	push   %esi
  80173d:	53                   	push   %ebx
  80173e:	8b 75 08             	mov    0x8(%ebp),%esi
  801741:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801744:	89 f3                	mov    %esi,%ebx
  801746:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801749:	89 f2                	mov    %esi,%edx
  80174b:	eb 0f                	jmp    80175c <strncpy+0x23>
		*dst++ = *src;
  80174d:	83 c2 01             	add    $0x1,%edx
  801750:	0f b6 01             	movzbl (%ecx),%eax
  801753:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801756:	80 39 01             	cmpb   $0x1,(%ecx)
  801759:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80175c:	39 da                	cmp    %ebx,%edx
  80175e:	75 ed                	jne    80174d <strncpy+0x14>
	}
	return ret;
}
  801760:	89 f0                	mov    %esi,%eax
  801762:	5b                   	pop    %ebx
  801763:	5e                   	pop    %esi
  801764:	5d                   	pop    %ebp
  801765:	c3                   	ret    

00801766 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801766:	55                   	push   %ebp
  801767:	89 e5                	mov    %esp,%ebp
  801769:	56                   	push   %esi
  80176a:	53                   	push   %ebx
  80176b:	8b 75 08             	mov    0x8(%ebp),%esi
  80176e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801771:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801774:	89 f0                	mov    %esi,%eax
  801776:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80177a:	85 c9                	test   %ecx,%ecx
  80177c:	75 0b                	jne    801789 <strlcpy+0x23>
  80177e:	eb 17                	jmp    801797 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801780:	83 c2 01             	add    $0x1,%edx
  801783:	83 c0 01             	add    $0x1,%eax
  801786:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  801789:	39 d8                	cmp    %ebx,%eax
  80178b:	74 07                	je     801794 <strlcpy+0x2e>
  80178d:	0f b6 0a             	movzbl (%edx),%ecx
  801790:	84 c9                	test   %cl,%cl
  801792:	75 ec                	jne    801780 <strlcpy+0x1a>
		*dst = '\0';
  801794:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801797:	29 f0                	sub    %esi,%eax
}
  801799:	5b                   	pop    %ebx
  80179a:	5e                   	pop    %esi
  80179b:	5d                   	pop    %ebp
  80179c:	c3                   	ret    

0080179d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80179d:	55                   	push   %ebp
  80179e:	89 e5                	mov    %esp,%ebp
  8017a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017a3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017a6:	eb 06                	jmp    8017ae <strcmp+0x11>
		p++, q++;
  8017a8:	83 c1 01             	add    $0x1,%ecx
  8017ab:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8017ae:	0f b6 01             	movzbl (%ecx),%eax
  8017b1:	84 c0                	test   %al,%al
  8017b3:	74 04                	je     8017b9 <strcmp+0x1c>
  8017b5:	3a 02                	cmp    (%edx),%al
  8017b7:	74 ef                	je     8017a8 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017b9:	0f b6 c0             	movzbl %al,%eax
  8017bc:	0f b6 12             	movzbl (%edx),%edx
  8017bf:	29 d0                	sub    %edx,%eax
}
  8017c1:	5d                   	pop    %ebp
  8017c2:	c3                   	ret    

008017c3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017c3:	55                   	push   %ebp
  8017c4:	89 e5                	mov    %esp,%ebp
  8017c6:	53                   	push   %ebx
  8017c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017cd:	89 c3                	mov    %eax,%ebx
  8017cf:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017d2:	eb 06                	jmp    8017da <strncmp+0x17>
		n--, p++, q++;
  8017d4:	83 c0 01             	add    $0x1,%eax
  8017d7:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8017da:	39 d8                	cmp    %ebx,%eax
  8017dc:	74 16                	je     8017f4 <strncmp+0x31>
  8017de:	0f b6 08             	movzbl (%eax),%ecx
  8017e1:	84 c9                	test   %cl,%cl
  8017e3:	74 04                	je     8017e9 <strncmp+0x26>
  8017e5:	3a 0a                	cmp    (%edx),%cl
  8017e7:	74 eb                	je     8017d4 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017e9:	0f b6 00             	movzbl (%eax),%eax
  8017ec:	0f b6 12             	movzbl (%edx),%edx
  8017ef:	29 d0                	sub    %edx,%eax
}
  8017f1:	5b                   	pop    %ebx
  8017f2:	5d                   	pop    %ebp
  8017f3:	c3                   	ret    
		return 0;
  8017f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8017f9:	eb f6                	jmp    8017f1 <strncmp+0x2e>

008017fb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017fb:	55                   	push   %ebp
  8017fc:	89 e5                	mov    %esp,%ebp
  8017fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801801:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801805:	0f b6 10             	movzbl (%eax),%edx
  801808:	84 d2                	test   %dl,%dl
  80180a:	74 09                	je     801815 <strchr+0x1a>
		if (*s == c)
  80180c:	38 ca                	cmp    %cl,%dl
  80180e:	74 0a                	je     80181a <strchr+0x1f>
	for (; *s; s++)
  801810:	83 c0 01             	add    $0x1,%eax
  801813:	eb f0                	jmp    801805 <strchr+0xa>
			return (char *) s;
	return 0;
  801815:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80181a:	5d                   	pop    %ebp
  80181b:	c3                   	ret    

0080181c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80181c:	55                   	push   %ebp
  80181d:	89 e5                	mov    %esp,%ebp
  80181f:	8b 45 08             	mov    0x8(%ebp),%eax
  801822:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801826:	eb 03                	jmp    80182b <strfind+0xf>
  801828:	83 c0 01             	add    $0x1,%eax
  80182b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80182e:	38 ca                	cmp    %cl,%dl
  801830:	74 04                	je     801836 <strfind+0x1a>
  801832:	84 d2                	test   %dl,%dl
  801834:	75 f2                	jne    801828 <strfind+0xc>
			break;
	return (char *) s;
}
  801836:	5d                   	pop    %ebp
  801837:	c3                   	ret    

00801838 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801838:	55                   	push   %ebp
  801839:	89 e5                	mov    %esp,%ebp
  80183b:	57                   	push   %edi
  80183c:	56                   	push   %esi
  80183d:	53                   	push   %ebx
  80183e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801841:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801844:	85 c9                	test   %ecx,%ecx
  801846:	74 13                	je     80185b <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801848:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80184e:	75 05                	jne    801855 <memset+0x1d>
  801850:	f6 c1 03             	test   $0x3,%cl
  801853:	74 0d                	je     801862 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801855:	8b 45 0c             	mov    0xc(%ebp),%eax
  801858:	fc                   	cld    
  801859:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80185b:	89 f8                	mov    %edi,%eax
  80185d:	5b                   	pop    %ebx
  80185e:	5e                   	pop    %esi
  80185f:	5f                   	pop    %edi
  801860:	5d                   	pop    %ebp
  801861:	c3                   	ret    
		c &= 0xFF;
  801862:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801866:	89 d3                	mov    %edx,%ebx
  801868:	c1 e3 08             	shl    $0x8,%ebx
  80186b:	89 d0                	mov    %edx,%eax
  80186d:	c1 e0 18             	shl    $0x18,%eax
  801870:	89 d6                	mov    %edx,%esi
  801872:	c1 e6 10             	shl    $0x10,%esi
  801875:	09 f0                	or     %esi,%eax
  801877:	09 c2                	or     %eax,%edx
  801879:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  80187b:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80187e:	89 d0                	mov    %edx,%eax
  801880:	fc                   	cld    
  801881:	f3 ab                	rep stos %eax,%es:(%edi)
  801883:	eb d6                	jmp    80185b <memset+0x23>

00801885 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801885:	55                   	push   %ebp
  801886:	89 e5                	mov    %esp,%ebp
  801888:	57                   	push   %edi
  801889:	56                   	push   %esi
  80188a:	8b 45 08             	mov    0x8(%ebp),%eax
  80188d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801890:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801893:	39 c6                	cmp    %eax,%esi
  801895:	73 35                	jae    8018cc <memmove+0x47>
  801897:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80189a:	39 c2                	cmp    %eax,%edx
  80189c:	76 2e                	jbe    8018cc <memmove+0x47>
		s += n;
		d += n;
  80189e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018a1:	89 d6                	mov    %edx,%esi
  8018a3:	09 fe                	or     %edi,%esi
  8018a5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018ab:	74 0c                	je     8018b9 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8018ad:	83 ef 01             	sub    $0x1,%edi
  8018b0:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8018b3:	fd                   	std    
  8018b4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018b6:	fc                   	cld    
  8018b7:	eb 21                	jmp    8018da <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018b9:	f6 c1 03             	test   $0x3,%cl
  8018bc:	75 ef                	jne    8018ad <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8018be:	83 ef 04             	sub    $0x4,%edi
  8018c1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018c4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8018c7:	fd                   	std    
  8018c8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018ca:	eb ea                	jmp    8018b6 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018cc:	89 f2                	mov    %esi,%edx
  8018ce:	09 c2                	or     %eax,%edx
  8018d0:	f6 c2 03             	test   $0x3,%dl
  8018d3:	74 09                	je     8018de <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018d5:	89 c7                	mov    %eax,%edi
  8018d7:	fc                   	cld    
  8018d8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018da:	5e                   	pop    %esi
  8018db:	5f                   	pop    %edi
  8018dc:	5d                   	pop    %ebp
  8018dd:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018de:	f6 c1 03             	test   $0x3,%cl
  8018e1:	75 f2                	jne    8018d5 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8018e3:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8018e6:	89 c7                	mov    %eax,%edi
  8018e8:	fc                   	cld    
  8018e9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018eb:	eb ed                	jmp    8018da <memmove+0x55>

008018ed <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018ed:	55                   	push   %ebp
  8018ee:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018f0:	ff 75 10             	pushl  0x10(%ebp)
  8018f3:	ff 75 0c             	pushl  0xc(%ebp)
  8018f6:	ff 75 08             	pushl  0x8(%ebp)
  8018f9:	e8 87 ff ff ff       	call   801885 <memmove>
}
  8018fe:	c9                   	leave  
  8018ff:	c3                   	ret    

00801900 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801900:	55                   	push   %ebp
  801901:	89 e5                	mov    %esp,%ebp
  801903:	56                   	push   %esi
  801904:	53                   	push   %ebx
  801905:	8b 45 08             	mov    0x8(%ebp),%eax
  801908:	8b 55 0c             	mov    0xc(%ebp),%edx
  80190b:	89 c6                	mov    %eax,%esi
  80190d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801910:	39 f0                	cmp    %esi,%eax
  801912:	74 1c                	je     801930 <memcmp+0x30>
		if (*s1 != *s2)
  801914:	0f b6 08             	movzbl (%eax),%ecx
  801917:	0f b6 1a             	movzbl (%edx),%ebx
  80191a:	38 d9                	cmp    %bl,%cl
  80191c:	75 08                	jne    801926 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  80191e:	83 c0 01             	add    $0x1,%eax
  801921:	83 c2 01             	add    $0x1,%edx
  801924:	eb ea                	jmp    801910 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  801926:	0f b6 c1             	movzbl %cl,%eax
  801929:	0f b6 db             	movzbl %bl,%ebx
  80192c:	29 d8                	sub    %ebx,%eax
  80192e:	eb 05                	jmp    801935 <memcmp+0x35>
	}

	return 0;
  801930:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801935:	5b                   	pop    %ebx
  801936:	5e                   	pop    %esi
  801937:	5d                   	pop    %ebp
  801938:	c3                   	ret    

00801939 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801939:	55                   	push   %ebp
  80193a:	89 e5                	mov    %esp,%ebp
  80193c:	8b 45 08             	mov    0x8(%ebp),%eax
  80193f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801942:	89 c2                	mov    %eax,%edx
  801944:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801947:	39 d0                	cmp    %edx,%eax
  801949:	73 09                	jae    801954 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80194b:	38 08                	cmp    %cl,(%eax)
  80194d:	74 05                	je     801954 <memfind+0x1b>
	for (; s < ends; s++)
  80194f:	83 c0 01             	add    $0x1,%eax
  801952:	eb f3                	jmp    801947 <memfind+0xe>
			break;
	return (void *) s;
}
  801954:	5d                   	pop    %ebp
  801955:	c3                   	ret    

00801956 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801956:	55                   	push   %ebp
  801957:	89 e5                	mov    %esp,%ebp
  801959:	57                   	push   %edi
  80195a:	56                   	push   %esi
  80195b:	53                   	push   %ebx
  80195c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80195f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801962:	eb 03                	jmp    801967 <strtol+0x11>
		s++;
  801964:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801967:	0f b6 01             	movzbl (%ecx),%eax
  80196a:	3c 20                	cmp    $0x20,%al
  80196c:	74 f6                	je     801964 <strtol+0xe>
  80196e:	3c 09                	cmp    $0x9,%al
  801970:	74 f2                	je     801964 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  801972:	3c 2b                	cmp    $0x2b,%al
  801974:	74 2e                	je     8019a4 <strtol+0x4e>
	int neg = 0;
  801976:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  80197b:	3c 2d                	cmp    $0x2d,%al
  80197d:	74 2f                	je     8019ae <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80197f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801985:	75 05                	jne    80198c <strtol+0x36>
  801987:	80 39 30             	cmpb   $0x30,(%ecx)
  80198a:	74 2c                	je     8019b8 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80198c:	85 db                	test   %ebx,%ebx
  80198e:	75 0a                	jne    80199a <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801990:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  801995:	80 39 30             	cmpb   $0x30,(%ecx)
  801998:	74 28                	je     8019c2 <strtol+0x6c>
		base = 10;
  80199a:	b8 00 00 00 00       	mov    $0x0,%eax
  80199f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8019a2:	eb 50                	jmp    8019f4 <strtol+0x9e>
		s++;
  8019a4:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  8019a7:	bf 00 00 00 00       	mov    $0x0,%edi
  8019ac:	eb d1                	jmp    80197f <strtol+0x29>
		s++, neg = 1;
  8019ae:	83 c1 01             	add    $0x1,%ecx
  8019b1:	bf 01 00 00 00       	mov    $0x1,%edi
  8019b6:	eb c7                	jmp    80197f <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019b8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019bc:	74 0e                	je     8019cc <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8019be:	85 db                	test   %ebx,%ebx
  8019c0:	75 d8                	jne    80199a <strtol+0x44>
		s++, base = 8;
  8019c2:	83 c1 01             	add    $0x1,%ecx
  8019c5:	bb 08 00 00 00       	mov    $0x8,%ebx
  8019ca:	eb ce                	jmp    80199a <strtol+0x44>
		s += 2, base = 16;
  8019cc:	83 c1 02             	add    $0x2,%ecx
  8019cf:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019d4:	eb c4                	jmp    80199a <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  8019d6:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019d9:	89 f3                	mov    %esi,%ebx
  8019db:	80 fb 19             	cmp    $0x19,%bl
  8019de:	77 29                	ja     801a09 <strtol+0xb3>
			dig = *s - 'a' + 10;
  8019e0:	0f be d2             	movsbl %dl,%edx
  8019e3:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8019e6:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019e9:	7d 30                	jge    801a1b <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  8019eb:	83 c1 01             	add    $0x1,%ecx
  8019ee:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019f2:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  8019f4:	0f b6 11             	movzbl (%ecx),%edx
  8019f7:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019fa:	89 f3                	mov    %esi,%ebx
  8019fc:	80 fb 09             	cmp    $0x9,%bl
  8019ff:	77 d5                	ja     8019d6 <strtol+0x80>
			dig = *s - '0';
  801a01:	0f be d2             	movsbl %dl,%edx
  801a04:	83 ea 30             	sub    $0x30,%edx
  801a07:	eb dd                	jmp    8019e6 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  801a09:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a0c:	89 f3                	mov    %esi,%ebx
  801a0e:	80 fb 19             	cmp    $0x19,%bl
  801a11:	77 08                	ja     801a1b <strtol+0xc5>
			dig = *s - 'A' + 10;
  801a13:	0f be d2             	movsbl %dl,%edx
  801a16:	83 ea 37             	sub    $0x37,%edx
  801a19:	eb cb                	jmp    8019e6 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  801a1b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a1f:	74 05                	je     801a26 <strtol+0xd0>
		*endptr = (char *) s;
  801a21:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a24:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801a26:	89 c2                	mov    %eax,%edx
  801a28:	f7 da                	neg    %edx
  801a2a:	85 ff                	test   %edi,%edi
  801a2c:	0f 45 c2             	cmovne %edx,%eax
}
  801a2f:	5b                   	pop    %ebx
  801a30:	5e                   	pop    %esi
  801a31:	5f                   	pop    %edi
  801a32:	5d                   	pop    %ebp
  801a33:	c3                   	ret    

00801a34 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a34:	55                   	push   %ebp
  801a35:	89 e5                	mov    %esp,%ebp
  801a37:	56                   	push   %esi
  801a38:	53                   	push   %ebx
  801a39:	8b 75 08             	mov    0x8(%ebp),%esi
  801a3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  801a42:	85 f6                	test   %esi,%esi
  801a44:	74 06                	je     801a4c <ipc_recv+0x18>
  801a46:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801a4c:	85 db                	test   %ebx,%ebx
  801a4e:	74 06                	je     801a56 <ipc_recv+0x22>
  801a50:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801a56:	85 c0                	test   %eax,%eax
  801a58:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801a5d:	0f 44 c2             	cmove  %edx,%eax
	int ret = sys_ipc_recv(pg);
  801a60:	83 ec 0c             	sub    $0xc,%esp
  801a63:	50                   	push   %eax
  801a64:	e8 a5 e8 ff ff       	call   80030e <sys_ipc_recv>
	if (ret) return ret;
  801a69:	83 c4 10             	add    $0x10,%esp
  801a6c:	85 c0                	test   %eax,%eax
  801a6e:	75 24                	jne    801a94 <ipc_recv+0x60>
	if (from_env_store)
  801a70:	85 f6                	test   %esi,%esi
  801a72:	74 0a                	je     801a7e <ipc_recv+0x4a>
		*from_env_store = thisenv->env_ipc_from;
  801a74:	a1 04 40 80 00       	mov    0x804004,%eax
  801a79:	8b 40 74             	mov    0x74(%eax),%eax
  801a7c:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801a7e:	85 db                	test   %ebx,%ebx
  801a80:	74 0a                	je     801a8c <ipc_recv+0x58>
		*perm_store = thisenv->env_ipc_perm;
  801a82:	a1 04 40 80 00       	mov    0x804004,%eax
  801a87:	8b 40 78             	mov    0x78(%eax),%eax
  801a8a:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801a8c:	a1 04 40 80 00       	mov    0x804004,%eax
  801a91:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a94:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a97:	5b                   	pop    %ebx
  801a98:	5e                   	pop    %esi
  801a99:	5d                   	pop    %ebp
  801a9a:	c3                   	ret    

00801a9b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a9b:	55                   	push   %ebp
  801a9c:	89 e5                	mov    %esp,%ebp
  801a9e:	57                   	push   %edi
  801a9f:	56                   	push   %esi
  801aa0:	53                   	push   %ebx
  801aa1:	83 ec 0c             	sub    $0xc,%esp
  801aa4:	8b 7d 08             	mov    0x8(%ebp),%edi
  801aa7:	8b 75 0c             	mov    0xc(%ebp),%esi
  801aaa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  801aad:	85 db                	test   %ebx,%ebx
  801aaf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801ab4:	0f 44 d8             	cmove  %eax,%ebx
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801ab7:	ff 75 14             	pushl  0x14(%ebp)
  801aba:	53                   	push   %ebx
  801abb:	56                   	push   %esi
  801abc:	57                   	push   %edi
  801abd:	e8 29 e8 ff ff       	call   8002eb <sys_ipc_try_send>
  801ac2:	83 c4 10             	add    $0x10,%esp
  801ac5:	85 c0                	test   %eax,%eax
  801ac7:	74 1e                	je     801ae7 <ipc_send+0x4c>
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801ac9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801acc:	75 07                	jne    801ad5 <ipc_send+0x3a>
		sys_yield();
  801ace:	e8 6c e6 ff ff       	call   80013f <sys_yield>
  801ad3:	eb e2                	jmp    801ab7 <ipc_send+0x1c>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801ad5:	50                   	push   %eax
  801ad6:	68 00 22 80 00       	push   $0x802200
  801adb:	6a 36                	push   $0x36
  801add:	68 17 22 80 00       	push   $0x802217
  801ae2:	e8 16 f5 ff ff       	call   800ffd <_panic>
	}
}
  801ae7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aea:	5b                   	pop    %ebx
  801aeb:	5e                   	pop    %esi
  801aec:	5f                   	pop    %edi
  801aed:	5d                   	pop    %ebp
  801aee:	c3                   	ret    

00801aef <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801aef:	55                   	push   %ebp
  801af0:	89 e5                	mov    %esp,%ebp
  801af2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801af5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801afa:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801afd:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b03:	8b 52 50             	mov    0x50(%edx),%edx
  801b06:	39 ca                	cmp    %ecx,%edx
  801b08:	74 11                	je     801b1b <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801b0a:	83 c0 01             	add    $0x1,%eax
  801b0d:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b12:	75 e6                	jne    801afa <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801b14:	b8 00 00 00 00       	mov    $0x0,%eax
  801b19:	eb 0b                	jmp    801b26 <ipc_find_env+0x37>
			return envs[i].env_id;
  801b1b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b1e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b23:	8b 40 48             	mov    0x48(%eax),%eax
}
  801b26:	5d                   	pop    %ebp
  801b27:	c3                   	ret    

00801b28 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b28:	55                   	push   %ebp
  801b29:	89 e5                	mov    %esp,%ebp
  801b2b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b2e:	89 d0                	mov    %edx,%eax
  801b30:	c1 e8 16             	shr    $0x16,%eax
  801b33:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b3a:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801b3f:	f6 c1 01             	test   $0x1,%cl
  801b42:	74 1d                	je     801b61 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801b44:	c1 ea 0c             	shr    $0xc,%edx
  801b47:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b4e:	f6 c2 01             	test   $0x1,%dl
  801b51:	74 0e                	je     801b61 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b53:	c1 ea 0c             	shr    $0xc,%edx
  801b56:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b5d:	ef 
  801b5e:	0f b7 c0             	movzwl %ax,%eax
}
  801b61:	5d                   	pop    %ebp
  801b62:	c3                   	ret    
  801b63:	66 90                	xchg   %ax,%ax
  801b65:	66 90                	xchg   %ax,%ax
  801b67:	66 90                	xchg   %ax,%ax
  801b69:	66 90                	xchg   %ax,%ax
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
