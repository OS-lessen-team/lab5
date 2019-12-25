
obj/user/faultnostack.debug：     文件格式 elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  800039:	68 61 03 80 00       	push   $0x800361
  80003e:	6a 00                	push   $0x0
  800040:	e8 76 02 00 00       	call   8002bb <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800045:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80004c:	00 00 00 
}
  80004f:	83 c4 10             	add    $0x10,%esp
  800052:	c9                   	leave  
  800053:	c3                   	ret    

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  80005f:	e8 ce 00 00 00       	call   800132 <sys_getenvid>
	thisenv = envs + ENVX(envid); 
  800064:	25 ff 03 00 00       	and    $0x3ff,%eax
  800069:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800071:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 db                	test   %ebx,%ebx
  800078:	7e 07                	jle    800081 <libmain+0x2d>
		binaryname = argv[0];
  80007a:	8b 06                	mov    (%esi),%eax
  80007c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800081:	83 ec 08             	sub    $0x8,%esp
  800084:	56                   	push   %esi
  800085:	53                   	push   %ebx
  800086:	e8 a8 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008b:	e8 0a 00 00 00       	call   80009a <exit>
}
  800090:	83 c4 10             	add    $0x10,%esp
  800093:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800096:	5b                   	pop    %ebx
  800097:	5e                   	pop    %esi
  800098:	5d                   	pop    %ebp
  800099:	c3                   	ret    

0080009a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000a0:	e8 b8 04 00 00       	call   80055d <close_all>
	sys_env_destroy(0);
  8000a5:	83 ec 0c             	sub    $0xc,%esp
  8000a8:	6a 00                	push   $0x0
  8000aa:	e8 42 00 00 00       	call   8000f1 <sys_env_destroy>
}
  8000af:	83 c4 10             	add    $0x10,%esp
  8000b2:	c9                   	leave  
  8000b3:	c3                   	ret    

008000b4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	57                   	push   %edi
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8000bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c5:	89 c3                	mov    %eax,%ebx
  8000c7:	89 c7                	mov    %eax,%edi
  8000c9:	89 c6                	mov    %eax,%esi
  8000cb:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5f                   	pop    %edi
  8000d0:	5d                   	pop    %ebp
  8000d1:	c3                   	ret    

008000d2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d2:	55                   	push   %ebp
  8000d3:	89 e5                	mov    %esp,%ebp
  8000d5:	57                   	push   %edi
  8000d6:	56                   	push   %esi
  8000d7:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e2:	89 d1                	mov    %edx,%ecx
  8000e4:	89 d3                	mov    %edx,%ebx
  8000e6:	89 d7                	mov    %edx,%edi
  8000e8:	89 d6                	mov    %edx,%esi
  8000ea:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ec:	5b                   	pop    %ebx
  8000ed:	5e                   	pop    %esi
  8000ee:	5f                   	pop    %edi
  8000ef:	5d                   	pop    %ebp
  8000f0:	c3                   	ret    

008000f1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f1:	55                   	push   %ebp
  8000f2:	89 e5                	mov    %esp,%ebp
  8000f4:	57                   	push   %edi
  8000f5:	56                   	push   %esi
  8000f6:	53                   	push   %ebx
  8000f7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ff:	8b 55 08             	mov    0x8(%ebp),%edx
  800102:	b8 03 00 00 00       	mov    $0x3,%eax
  800107:	89 cb                	mov    %ecx,%ebx
  800109:	89 cf                	mov    %ecx,%edi
  80010b:	89 ce                	mov    %ecx,%esi
  80010d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80010f:	85 c0                	test   %eax,%eax
  800111:	7f 08                	jg     80011b <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800113:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800116:	5b                   	pop    %ebx
  800117:	5e                   	pop    %esi
  800118:	5f                   	pop    %edi
  800119:	5d                   	pop    %ebp
  80011a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80011b:	83 ec 0c             	sub    $0xc,%esp
  80011e:	50                   	push   %eax
  80011f:	6a 03                	push   $0x3
  800121:	68 6a 1e 80 00       	push   $0x801e6a
  800126:	6a 23                	push   $0x23
  800128:	68 87 1e 80 00       	push   $0x801e87
  80012d:	e8 03 0f 00 00       	call   801035 <_panic>

00800132 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800132:	55                   	push   %ebp
  800133:	89 e5                	mov    %esp,%ebp
  800135:	57                   	push   %edi
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
	asm volatile("int %1\n"
  800138:	ba 00 00 00 00       	mov    $0x0,%edx
  80013d:	b8 02 00 00 00       	mov    $0x2,%eax
  800142:	89 d1                	mov    %edx,%ecx
  800144:	89 d3                	mov    %edx,%ebx
  800146:	89 d7                	mov    %edx,%edi
  800148:	89 d6                	mov    %edx,%esi
  80014a:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80014c:	5b                   	pop    %ebx
  80014d:	5e                   	pop    %esi
  80014e:	5f                   	pop    %edi
  80014f:	5d                   	pop    %ebp
  800150:	c3                   	ret    

00800151 <sys_yield>:

void
sys_yield(void)
{
  800151:	55                   	push   %ebp
  800152:	89 e5                	mov    %esp,%ebp
  800154:	57                   	push   %edi
  800155:	56                   	push   %esi
  800156:	53                   	push   %ebx
	asm volatile("int %1\n"
  800157:	ba 00 00 00 00       	mov    $0x0,%edx
  80015c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800161:	89 d1                	mov    %edx,%ecx
  800163:	89 d3                	mov    %edx,%ebx
  800165:	89 d7                	mov    %edx,%edi
  800167:	89 d6                	mov    %edx,%esi
  800169:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80016b:	5b                   	pop    %ebx
  80016c:	5e                   	pop    %esi
  80016d:	5f                   	pop    %edi
  80016e:	5d                   	pop    %ebp
  80016f:	c3                   	ret    

00800170 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	57                   	push   %edi
  800174:	56                   	push   %esi
  800175:	53                   	push   %ebx
  800176:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800179:	be 00 00 00 00       	mov    $0x0,%esi
  80017e:	8b 55 08             	mov    0x8(%ebp),%edx
  800181:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800184:	b8 04 00 00 00       	mov    $0x4,%eax
  800189:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80018c:	89 f7                	mov    %esi,%edi
  80018e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800190:	85 c0                	test   %eax,%eax
  800192:	7f 08                	jg     80019c <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800194:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800197:	5b                   	pop    %ebx
  800198:	5e                   	pop    %esi
  800199:	5f                   	pop    %edi
  80019a:	5d                   	pop    %ebp
  80019b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80019c:	83 ec 0c             	sub    $0xc,%esp
  80019f:	50                   	push   %eax
  8001a0:	6a 04                	push   $0x4
  8001a2:	68 6a 1e 80 00       	push   $0x801e6a
  8001a7:	6a 23                	push   $0x23
  8001a9:	68 87 1e 80 00       	push   $0x801e87
  8001ae:	e8 82 0e 00 00       	call   801035 <_panic>

008001b3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001b3:	55                   	push   %ebp
  8001b4:	89 e5                	mov    %esp,%ebp
  8001b6:	57                   	push   %edi
  8001b7:	56                   	push   %esi
  8001b8:	53                   	push   %ebx
  8001b9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ca:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001cd:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d0:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001d2:	85 c0                	test   %eax,%eax
  8001d4:	7f 08                	jg     8001de <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d9:	5b                   	pop    %ebx
  8001da:	5e                   	pop    %esi
  8001db:	5f                   	pop    %edi
  8001dc:	5d                   	pop    %ebp
  8001dd:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001de:	83 ec 0c             	sub    $0xc,%esp
  8001e1:	50                   	push   %eax
  8001e2:	6a 05                	push   $0x5
  8001e4:	68 6a 1e 80 00       	push   $0x801e6a
  8001e9:	6a 23                	push   $0x23
  8001eb:	68 87 1e 80 00       	push   $0x801e87
  8001f0:	e8 40 0e 00 00       	call   801035 <_panic>

008001f5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001f5:	55                   	push   %ebp
  8001f6:	89 e5                	mov    %esp,%ebp
  8001f8:	57                   	push   %edi
  8001f9:	56                   	push   %esi
  8001fa:	53                   	push   %ebx
  8001fb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800203:	8b 55 08             	mov    0x8(%ebp),%edx
  800206:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800209:	b8 06 00 00 00       	mov    $0x6,%eax
  80020e:	89 df                	mov    %ebx,%edi
  800210:	89 de                	mov    %ebx,%esi
  800212:	cd 30                	int    $0x30
	if(check && ret > 0)
  800214:	85 c0                	test   %eax,%eax
  800216:	7f 08                	jg     800220 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800218:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021b:	5b                   	pop    %ebx
  80021c:	5e                   	pop    %esi
  80021d:	5f                   	pop    %edi
  80021e:	5d                   	pop    %ebp
  80021f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800220:	83 ec 0c             	sub    $0xc,%esp
  800223:	50                   	push   %eax
  800224:	6a 06                	push   $0x6
  800226:	68 6a 1e 80 00       	push   $0x801e6a
  80022b:	6a 23                	push   $0x23
  80022d:	68 87 1e 80 00       	push   $0x801e87
  800232:	e8 fe 0d 00 00       	call   801035 <_panic>

00800237 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800237:	55                   	push   %ebp
  800238:	89 e5                	mov    %esp,%ebp
  80023a:	57                   	push   %edi
  80023b:	56                   	push   %esi
  80023c:	53                   	push   %ebx
  80023d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800240:	bb 00 00 00 00       	mov    $0x0,%ebx
  800245:	8b 55 08             	mov    0x8(%ebp),%edx
  800248:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80024b:	b8 08 00 00 00       	mov    $0x8,%eax
  800250:	89 df                	mov    %ebx,%edi
  800252:	89 de                	mov    %ebx,%esi
  800254:	cd 30                	int    $0x30
	if(check && ret > 0)
  800256:	85 c0                	test   %eax,%eax
  800258:	7f 08                	jg     800262 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80025a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025d:	5b                   	pop    %ebx
  80025e:	5e                   	pop    %esi
  80025f:	5f                   	pop    %edi
  800260:	5d                   	pop    %ebp
  800261:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800262:	83 ec 0c             	sub    $0xc,%esp
  800265:	50                   	push   %eax
  800266:	6a 08                	push   $0x8
  800268:	68 6a 1e 80 00       	push   $0x801e6a
  80026d:	6a 23                	push   $0x23
  80026f:	68 87 1e 80 00       	push   $0x801e87
  800274:	e8 bc 0d 00 00       	call   801035 <_panic>

00800279 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800279:	55                   	push   %ebp
  80027a:	89 e5                	mov    %esp,%ebp
  80027c:	57                   	push   %edi
  80027d:	56                   	push   %esi
  80027e:	53                   	push   %ebx
  80027f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800282:	bb 00 00 00 00       	mov    $0x0,%ebx
  800287:	8b 55 08             	mov    0x8(%ebp),%edx
  80028a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80028d:	b8 09 00 00 00       	mov    $0x9,%eax
  800292:	89 df                	mov    %ebx,%edi
  800294:	89 de                	mov    %ebx,%esi
  800296:	cd 30                	int    $0x30
	if(check && ret > 0)
  800298:	85 c0                	test   %eax,%eax
  80029a:	7f 08                	jg     8002a4 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80029c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029f:	5b                   	pop    %ebx
  8002a0:	5e                   	pop    %esi
  8002a1:	5f                   	pop    %edi
  8002a2:	5d                   	pop    %ebp
  8002a3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002a4:	83 ec 0c             	sub    $0xc,%esp
  8002a7:	50                   	push   %eax
  8002a8:	6a 09                	push   $0x9
  8002aa:	68 6a 1e 80 00       	push   $0x801e6a
  8002af:	6a 23                	push   $0x23
  8002b1:	68 87 1e 80 00       	push   $0x801e87
  8002b6:	e8 7a 0d 00 00       	call   801035 <_panic>

008002bb <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002bb:	55                   	push   %ebp
  8002bc:	89 e5                	mov    %esp,%ebp
  8002be:	57                   	push   %edi
  8002bf:	56                   	push   %esi
  8002c0:	53                   	push   %ebx
  8002c1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002cf:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002d4:	89 df                	mov    %ebx,%edi
  8002d6:	89 de                	mov    %ebx,%esi
  8002d8:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002da:	85 c0                	test   %eax,%eax
  8002dc:	7f 08                	jg     8002e6 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e1:	5b                   	pop    %ebx
  8002e2:	5e                   	pop    %esi
  8002e3:	5f                   	pop    %edi
  8002e4:	5d                   	pop    %ebp
  8002e5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e6:	83 ec 0c             	sub    $0xc,%esp
  8002e9:	50                   	push   %eax
  8002ea:	6a 0a                	push   $0xa
  8002ec:	68 6a 1e 80 00       	push   $0x801e6a
  8002f1:	6a 23                	push   $0x23
  8002f3:	68 87 1e 80 00       	push   $0x801e87
  8002f8:	e8 38 0d 00 00       	call   801035 <_panic>

008002fd <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	57                   	push   %edi
  800301:	56                   	push   %esi
  800302:	53                   	push   %ebx
	asm volatile("int %1\n"
  800303:	8b 55 08             	mov    0x8(%ebp),%edx
  800306:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800309:	b8 0c 00 00 00       	mov    $0xc,%eax
  80030e:	be 00 00 00 00       	mov    $0x0,%esi
  800313:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800316:	8b 7d 14             	mov    0x14(%ebp),%edi
  800319:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80031b:	5b                   	pop    %ebx
  80031c:	5e                   	pop    %esi
  80031d:	5f                   	pop    %edi
  80031e:	5d                   	pop    %ebp
  80031f:	c3                   	ret    

00800320 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	57                   	push   %edi
  800324:	56                   	push   %esi
  800325:	53                   	push   %ebx
  800326:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800329:	b9 00 00 00 00       	mov    $0x0,%ecx
  80032e:	8b 55 08             	mov    0x8(%ebp),%edx
  800331:	b8 0d 00 00 00       	mov    $0xd,%eax
  800336:	89 cb                	mov    %ecx,%ebx
  800338:	89 cf                	mov    %ecx,%edi
  80033a:	89 ce                	mov    %ecx,%esi
  80033c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80033e:	85 c0                	test   %eax,%eax
  800340:	7f 08                	jg     80034a <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800342:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800345:	5b                   	pop    %ebx
  800346:	5e                   	pop    %esi
  800347:	5f                   	pop    %edi
  800348:	5d                   	pop    %ebp
  800349:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80034a:	83 ec 0c             	sub    $0xc,%esp
  80034d:	50                   	push   %eax
  80034e:	6a 0d                	push   $0xd
  800350:	68 6a 1e 80 00       	push   $0x801e6a
  800355:	6a 23                	push   $0x23
  800357:	68 87 1e 80 00       	push   $0x801e87
  80035c:	e8 d4 0c 00 00       	call   801035 <_panic>

00800361 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800361:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800362:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  800367:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800369:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %eax
  80036c:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  800370:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  800373:	89 44 24 30          	mov    %eax,0x30(%esp)
	movl 40(%esp), %ebx
  800377:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  80037b:	89 18                	mov    %ebx,(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  80037d:	83 c4 08             	add    $0x8,%esp
	popal
  800380:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  800381:	83 c4 04             	add    $0x4,%esp
	popfl
  800384:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800385:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800386:	c3                   	ret    

00800387 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800387:	55                   	push   %ebp
  800388:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80038a:	8b 45 08             	mov    0x8(%ebp),%eax
  80038d:	05 00 00 00 30       	add    $0x30000000,%eax
  800392:	c1 e8 0c             	shr    $0xc,%eax
}
  800395:	5d                   	pop    %ebp
  800396:	c3                   	ret    

00800397 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800397:	55                   	push   %ebp
  800398:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80039a:	8b 45 08             	mov    0x8(%ebp),%eax
  80039d:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8003a2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003a7:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003ac:	5d                   	pop    %ebp
  8003ad:	c3                   	ret    

008003ae <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003ae:	55                   	push   %ebp
  8003af:	89 e5                	mov    %esp,%ebp
  8003b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003b4:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003b9:	89 c2                	mov    %eax,%edx
  8003bb:	c1 ea 16             	shr    $0x16,%edx
  8003be:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003c5:	f6 c2 01             	test   $0x1,%dl
  8003c8:	74 2a                	je     8003f4 <fd_alloc+0x46>
  8003ca:	89 c2                	mov    %eax,%edx
  8003cc:	c1 ea 0c             	shr    $0xc,%edx
  8003cf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003d6:	f6 c2 01             	test   $0x1,%dl
  8003d9:	74 19                	je     8003f4 <fd_alloc+0x46>
  8003db:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8003e0:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003e5:	75 d2                	jne    8003b9 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003e7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003ed:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8003f2:	eb 07                	jmp    8003fb <fd_alloc+0x4d>
			*fd_store = fd;
  8003f4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003fb:	5d                   	pop    %ebp
  8003fc:	c3                   	ret    

008003fd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003fd:	55                   	push   %ebp
  8003fe:	89 e5                	mov    %esp,%ebp
  800400:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800403:	83 f8 1f             	cmp    $0x1f,%eax
  800406:	77 36                	ja     80043e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800408:	c1 e0 0c             	shl    $0xc,%eax
  80040b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800410:	89 c2                	mov    %eax,%edx
  800412:	c1 ea 16             	shr    $0x16,%edx
  800415:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80041c:	f6 c2 01             	test   $0x1,%dl
  80041f:	74 24                	je     800445 <fd_lookup+0x48>
  800421:	89 c2                	mov    %eax,%edx
  800423:	c1 ea 0c             	shr    $0xc,%edx
  800426:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80042d:	f6 c2 01             	test   $0x1,%dl
  800430:	74 1a                	je     80044c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800432:	8b 55 0c             	mov    0xc(%ebp),%edx
  800435:	89 02                	mov    %eax,(%edx)
	return 0;
  800437:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80043c:	5d                   	pop    %ebp
  80043d:	c3                   	ret    
		return -E_INVAL;
  80043e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800443:	eb f7                	jmp    80043c <fd_lookup+0x3f>
		return -E_INVAL;
  800445:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80044a:	eb f0                	jmp    80043c <fd_lookup+0x3f>
  80044c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800451:	eb e9                	jmp    80043c <fd_lookup+0x3f>

00800453 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800453:	55                   	push   %ebp
  800454:	89 e5                	mov    %esp,%ebp
  800456:	83 ec 08             	sub    $0x8,%esp
  800459:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80045c:	ba 14 1f 80 00       	mov    $0x801f14,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800461:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800466:	39 08                	cmp    %ecx,(%eax)
  800468:	74 33                	je     80049d <dev_lookup+0x4a>
  80046a:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  80046d:	8b 02                	mov    (%edx),%eax
  80046f:	85 c0                	test   %eax,%eax
  800471:	75 f3                	jne    800466 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800473:	a1 04 40 80 00       	mov    0x804004,%eax
  800478:	8b 40 48             	mov    0x48(%eax),%eax
  80047b:	83 ec 04             	sub    $0x4,%esp
  80047e:	51                   	push   %ecx
  80047f:	50                   	push   %eax
  800480:	68 98 1e 80 00       	push   $0x801e98
  800485:	e8 86 0c 00 00       	call   801110 <cprintf>
	*dev = 0;
  80048a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80048d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800493:	83 c4 10             	add    $0x10,%esp
  800496:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80049b:	c9                   	leave  
  80049c:	c3                   	ret    
			*dev = devtab[i];
  80049d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004a0:	89 01                	mov    %eax,(%ecx)
			return 0;
  8004a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a7:	eb f2                	jmp    80049b <dev_lookup+0x48>

008004a9 <fd_close>:
{
  8004a9:	55                   	push   %ebp
  8004aa:	89 e5                	mov    %esp,%ebp
  8004ac:	57                   	push   %edi
  8004ad:	56                   	push   %esi
  8004ae:	53                   	push   %ebx
  8004af:	83 ec 1c             	sub    $0x1c,%esp
  8004b2:	8b 75 08             	mov    0x8(%ebp),%esi
  8004b5:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004b8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8004bb:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8004bc:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004c2:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004c5:	50                   	push   %eax
  8004c6:	e8 32 ff ff ff       	call   8003fd <fd_lookup>
  8004cb:	89 c3                	mov    %eax,%ebx
  8004cd:	83 c4 08             	add    $0x8,%esp
  8004d0:	85 c0                	test   %eax,%eax
  8004d2:	78 05                	js     8004d9 <fd_close+0x30>
	    || fd != fd2)
  8004d4:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8004d7:	74 16                	je     8004ef <fd_close+0x46>
		return (must_exist ? r : 0);
  8004d9:	89 f8                	mov    %edi,%eax
  8004db:	84 c0                	test   %al,%al
  8004dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e2:	0f 44 d8             	cmove  %eax,%ebx
}
  8004e5:	89 d8                	mov    %ebx,%eax
  8004e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004ea:	5b                   	pop    %ebx
  8004eb:	5e                   	pop    %esi
  8004ec:	5f                   	pop    %edi
  8004ed:	5d                   	pop    %ebp
  8004ee:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004ef:	83 ec 08             	sub    $0x8,%esp
  8004f2:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8004f5:	50                   	push   %eax
  8004f6:	ff 36                	pushl  (%esi)
  8004f8:	e8 56 ff ff ff       	call   800453 <dev_lookup>
  8004fd:	89 c3                	mov    %eax,%ebx
  8004ff:	83 c4 10             	add    $0x10,%esp
  800502:	85 c0                	test   %eax,%eax
  800504:	78 15                	js     80051b <fd_close+0x72>
		if (dev->dev_close)
  800506:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800509:	8b 40 10             	mov    0x10(%eax),%eax
  80050c:	85 c0                	test   %eax,%eax
  80050e:	74 1b                	je     80052b <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  800510:	83 ec 0c             	sub    $0xc,%esp
  800513:	56                   	push   %esi
  800514:	ff d0                	call   *%eax
  800516:	89 c3                	mov    %eax,%ebx
  800518:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80051b:	83 ec 08             	sub    $0x8,%esp
  80051e:	56                   	push   %esi
  80051f:	6a 00                	push   $0x0
  800521:	e8 cf fc ff ff       	call   8001f5 <sys_page_unmap>
	return r;
  800526:	83 c4 10             	add    $0x10,%esp
  800529:	eb ba                	jmp    8004e5 <fd_close+0x3c>
			r = 0;
  80052b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800530:	eb e9                	jmp    80051b <fd_close+0x72>

00800532 <close>:

int
close(int fdnum)
{
  800532:	55                   	push   %ebp
  800533:	89 e5                	mov    %esp,%ebp
  800535:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800538:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80053b:	50                   	push   %eax
  80053c:	ff 75 08             	pushl  0x8(%ebp)
  80053f:	e8 b9 fe ff ff       	call   8003fd <fd_lookup>
  800544:	83 c4 08             	add    $0x8,%esp
  800547:	85 c0                	test   %eax,%eax
  800549:	78 10                	js     80055b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80054b:	83 ec 08             	sub    $0x8,%esp
  80054e:	6a 01                	push   $0x1
  800550:	ff 75 f4             	pushl  -0xc(%ebp)
  800553:	e8 51 ff ff ff       	call   8004a9 <fd_close>
  800558:	83 c4 10             	add    $0x10,%esp
}
  80055b:	c9                   	leave  
  80055c:	c3                   	ret    

0080055d <close_all>:

void
close_all(void)
{
  80055d:	55                   	push   %ebp
  80055e:	89 e5                	mov    %esp,%ebp
  800560:	53                   	push   %ebx
  800561:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800564:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800569:	83 ec 0c             	sub    $0xc,%esp
  80056c:	53                   	push   %ebx
  80056d:	e8 c0 ff ff ff       	call   800532 <close>
	for (i = 0; i < MAXFD; i++)
  800572:	83 c3 01             	add    $0x1,%ebx
  800575:	83 c4 10             	add    $0x10,%esp
  800578:	83 fb 20             	cmp    $0x20,%ebx
  80057b:	75 ec                	jne    800569 <close_all+0xc>
}
  80057d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800580:	c9                   	leave  
  800581:	c3                   	ret    

00800582 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800582:	55                   	push   %ebp
  800583:	89 e5                	mov    %esp,%ebp
  800585:	57                   	push   %edi
  800586:	56                   	push   %esi
  800587:	53                   	push   %ebx
  800588:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80058b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80058e:	50                   	push   %eax
  80058f:	ff 75 08             	pushl  0x8(%ebp)
  800592:	e8 66 fe ff ff       	call   8003fd <fd_lookup>
  800597:	89 c3                	mov    %eax,%ebx
  800599:	83 c4 08             	add    $0x8,%esp
  80059c:	85 c0                	test   %eax,%eax
  80059e:	0f 88 81 00 00 00    	js     800625 <dup+0xa3>
		return r;
	close(newfdnum);
  8005a4:	83 ec 0c             	sub    $0xc,%esp
  8005a7:	ff 75 0c             	pushl  0xc(%ebp)
  8005aa:	e8 83 ff ff ff       	call   800532 <close>

	newfd = INDEX2FD(newfdnum);
  8005af:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005b2:	c1 e6 0c             	shl    $0xc,%esi
  8005b5:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8005bb:	83 c4 04             	add    $0x4,%esp
  8005be:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005c1:	e8 d1 fd ff ff       	call   800397 <fd2data>
  8005c6:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8005c8:	89 34 24             	mov    %esi,(%esp)
  8005cb:	e8 c7 fd ff ff       	call   800397 <fd2data>
  8005d0:	83 c4 10             	add    $0x10,%esp
  8005d3:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005d5:	89 d8                	mov    %ebx,%eax
  8005d7:	c1 e8 16             	shr    $0x16,%eax
  8005da:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005e1:	a8 01                	test   $0x1,%al
  8005e3:	74 11                	je     8005f6 <dup+0x74>
  8005e5:	89 d8                	mov    %ebx,%eax
  8005e7:	c1 e8 0c             	shr    $0xc,%eax
  8005ea:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005f1:	f6 c2 01             	test   $0x1,%dl
  8005f4:	75 39                	jne    80062f <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005f6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005f9:	89 d0                	mov    %edx,%eax
  8005fb:	c1 e8 0c             	shr    $0xc,%eax
  8005fe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800605:	83 ec 0c             	sub    $0xc,%esp
  800608:	25 07 0e 00 00       	and    $0xe07,%eax
  80060d:	50                   	push   %eax
  80060e:	56                   	push   %esi
  80060f:	6a 00                	push   $0x0
  800611:	52                   	push   %edx
  800612:	6a 00                	push   $0x0
  800614:	e8 9a fb ff ff       	call   8001b3 <sys_page_map>
  800619:	89 c3                	mov    %eax,%ebx
  80061b:	83 c4 20             	add    $0x20,%esp
  80061e:	85 c0                	test   %eax,%eax
  800620:	78 31                	js     800653 <dup+0xd1>
		goto err;

	return newfdnum;
  800622:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800625:	89 d8                	mov    %ebx,%eax
  800627:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80062a:	5b                   	pop    %ebx
  80062b:	5e                   	pop    %esi
  80062c:	5f                   	pop    %edi
  80062d:	5d                   	pop    %ebp
  80062e:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80062f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800636:	83 ec 0c             	sub    $0xc,%esp
  800639:	25 07 0e 00 00       	and    $0xe07,%eax
  80063e:	50                   	push   %eax
  80063f:	57                   	push   %edi
  800640:	6a 00                	push   $0x0
  800642:	53                   	push   %ebx
  800643:	6a 00                	push   $0x0
  800645:	e8 69 fb ff ff       	call   8001b3 <sys_page_map>
  80064a:	89 c3                	mov    %eax,%ebx
  80064c:	83 c4 20             	add    $0x20,%esp
  80064f:	85 c0                	test   %eax,%eax
  800651:	79 a3                	jns    8005f6 <dup+0x74>
	sys_page_unmap(0, newfd);
  800653:	83 ec 08             	sub    $0x8,%esp
  800656:	56                   	push   %esi
  800657:	6a 00                	push   $0x0
  800659:	e8 97 fb ff ff       	call   8001f5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80065e:	83 c4 08             	add    $0x8,%esp
  800661:	57                   	push   %edi
  800662:	6a 00                	push   $0x0
  800664:	e8 8c fb ff ff       	call   8001f5 <sys_page_unmap>
	return r;
  800669:	83 c4 10             	add    $0x10,%esp
  80066c:	eb b7                	jmp    800625 <dup+0xa3>

0080066e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80066e:	55                   	push   %ebp
  80066f:	89 e5                	mov    %esp,%ebp
  800671:	53                   	push   %ebx
  800672:	83 ec 14             	sub    $0x14,%esp
  800675:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800678:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80067b:	50                   	push   %eax
  80067c:	53                   	push   %ebx
  80067d:	e8 7b fd ff ff       	call   8003fd <fd_lookup>
  800682:	83 c4 08             	add    $0x8,%esp
  800685:	85 c0                	test   %eax,%eax
  800687:	78 3f                	js     8006c8 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800689:	83 ec 08             	sub    $0x8,%esp
  80068c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80068f:	50                   	push   %eax
  800690:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800693:	ff 30                	pushl  (%eax)
  800695:	e8 b9 fd ff ff       	call   800453 <dev_lookup>
  80069a:	83 c4 10             	add    $0x10,%esp
  80069d:	85 c0                	test   %eax,%eax
  80069f:	78 27                	js     8006c8 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006a1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006a4:	8b 42 08             	mov    0x8(%edx),%eax
  8006a7:	83 e0 03             	and    $0x3,%eax
  8006aa:	83 f8 01             	cmp    $0x1,%eax
  8006ad:	74 1e                	je     8006cd <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8006af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b2:	8b 40 08             	mov    0x8(%eax),%eax
  8006b5:	85 c0                	test   %eax,%eax
  8006b7:	74 35                	je     8006ee <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006b9:	83 ec 04             	sub    $0x4,%esp
  8006bc:	ff 75 10             	pushl  0x10(%ebp)
  8006bf:	ff 75 0c             	pushl  0xc(%ebp)
  8006c2:	52                   	push   %edx
  8006c3:	ff d0                	call   *%eax
  8006c5:	83 c4 10             	add    $0x10,%esp
}
  8006c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006cb:	c9                   	leave  
  8006cc:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006cd:	a1 04 40 80 00       	mov    0x804004,%eax
  8006d2:	8b 40 48             	mov    0x48(%eax),%eax
  8006d5:	83 ec 04             	sub    $0x4,%esp
  8006d8:	53                   	push   %ebx
  8006d9:	50                   	push   %eax
  8006da:	68 d9 1e 80 00       	push   $0x801ed9
  8006df:	e8 2c 0a 00 00       	call   801110 <cprintf>
		return -E_INVAL;
  8006e4:	83 c4 10             	add    $0x10,%esp
  8006e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006ec:	eb da                	jmp    8006c8 <read+0x5a>
		return -E_NOT_SUPP;
  8006ee:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8006f3:	eb d3                	jmp    8006c8 <read+0x5a>

008006f5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006f5:	55                   	push   %ebp
  8006f6:	89 e5                	mov    %esp,%ebp
  8006f8:	57                   	push   %edi
  8006f9:	56                   	push   %esi
  8006fa:	53                   	push   %ebx
  8006fb:	83 ec 0c             	sub    $0xc,%esp
  8006fe:	8b 7d 08             	mov    0x8(%ebp),%edi
  800701:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800704:	bb 00 00 00 00       	mov    $0x0,%ebx
  800709:	39 f3                	cmp    %esi,%ebx
  80070b:	73 25                	jae    800732 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80070d:	83 ec 04             	sub    $0x4,%esp
  800710:	89 f0                	mov    %esi,%eax
  800712:	29 d8                	sub    %ebx,%eax
  800714:	50                   	push   %eax
  800715:	89 d8                	mov    %ebx,%eax
  800717:	03 45 0c             	add    0xc(%ebp),%eax
  80071a:	50                   	push   %eax
  80071b:	57                   	push   %edi
  80071c:	e8 4d ff ff ff       	call   80066e <read>
		if (m < 0)
  800721:	83 c4 10             	add    $0x10,%esp
  800724:	85 c0                	test   %eax,%eax
  800726:	78 08                	js     800730 <readn+0x3b>
			return m;
		if (m == 0)
  800728:	85 c0                	test   %eax,%eax
  80072a:	74 06                	je     800732 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  80072c:	01 c3                	add    %eax,%ebx
  80072e:	eb d9                	jmp    800709 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800730:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  800732:	89 d8                	mov    %ebx,%eax
  800734:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800737:	5b                   	pop    %ebx
  800738:	5e                   	pop    %esi
  800739:	5f                   	pop    %edi
  80073a:	5d                   	pop    %ebp
  80073b:	c3                   	ret    

0080073c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80073c:	55                   	push   %ebp
  80073d:	89 e5                	mov    %esp,%ebp
  80073f:	53                   	push   %ebx
  800740:	83 ec 14             	sub    $0x14,%esp
  800743:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800746:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800749:	50                   	push   %eax
  80074a:	53                   	push   %ebx
  80074b:	e8 ad fc ff ff       	call   8003fd <fd_lookup>
  800750:	83 c4 08             	add    $0x8,%esp
  800753:	85 c0                	test   %eax,%eax
  800755:	78 3a                	js     800791 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800757:	83 ec 08             	sub    $0x8,%esp
  80075a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80075d:	50                   	push   %eax
  80075e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800761:	ff 30                	pushl  (%eax)
  800763:	e8 eb fc ff ff       	call   800453 <dev_lookup>
  800768:	83 c4 10             	add    $0x10,%esp
  80076b:	85 c0                	test   %eax,%eax
  80076d:	78 22                	js     800791 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80076f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800772:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800776:	74 1e                	je     800796 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800778:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80077b:	8b 52 0c             	mov    0xc(%edx),%edx
  80077e:	85 d2                	test   %edx,%edx
  800780:	74 35                	je     8007b7 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800782:	83 ec 04             	sub    $0x4,%esp
  800785:	ff 75 10             	pushl  0x10(%ebp)
  800788:	ff 75 0c             	pushl  0xc(%ebp)
  80078b:	50                   	push   %eax
  80078c:	ff d2                	call   *%edx
  80078e:	83 c4 10             	add    $0x10,%esp
}
  800791:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800794:	c9                   	leave  
  800795:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800796:	a1 04 40 80 00       	mov    0x804004,%eax
  80079b:	8b 40 48             	mov    0x48(%eax),%eax
  80079e:	83 ec 04             	sub    $0x4,%esp
  8007a1:	53                   	push   %ebx
  8007a2:	50                   	push   %eax
  8007a3:	68 f5 1e 80 00       	push   $0x801ef5
  8007a8:	e8 63 09 00 00       	call   801110 <cprintf>
		return -E_INVAL;
  8007ad:	83 c4 10             	add    $0x10,%esp
  8007b0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007b5:	eb da                	jmp    800791 <write+0x55>
		return -E_NOT_SUPP;
  8007b7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8007bc:	eb d3                	jmp    800791 <write+0x55>

008007be <seek>:

int
seek(int fdnum, off_t offset)
{
  8007be:	55                   	push   %ebp
  8007bf:	89 e5                	mov    %esp,%ebp
  8007c1:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007c4:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007c7:	50                   	push   %eax
  8007c8:	ff 75 08             	pushl  0x8(%ebp)
  8007cb:	e8 2d fc ff ff       	call   8003fd <fd_lookup>
  8007d0:	83 c4 08             	add    $0x8,%esp
  8007d3:	85 c0                	test   %eax,%eax
  8007d5:	78 0e                	js     8007e5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007da:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007dd:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007e5:	c9                   	leave  
  8007e6:	c3                   	ret    

008007e7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007e7:	55                   	push   %ebp
  8007e8:	89 e5                	mov    %esp,%ebp
  8007ea:	53                   	push   %ebx
  8007eb:	83 ec 14             	sub    $0x14,%esp
  8007ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007f1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007f4:	50                   	push   %eax
  8007f5:	53                   	push   %ebx
  8007f6:	e8 02 fc ff ff       	call   8003fd <fd_lookup>
  8007fb:	83 c4 08             	add    $0x8,%esp
  8007fe:	85 c0                	test   %eax,%eax
  800800:	78 37                	js     800839 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800802:	83 ec 08             	sub    $0x8,%esp
  800805:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800808:	50                   	push   %eax
  800809:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80080c:	ff 30                	pushl  (%eax)
  80080e:	e8 40 fc ff ff       	call   800453 <dev_lookup>
  800813:	83 c4 10             	add    $0x10,%esp
  800816:	85 c0                	test   %eax,%eax
  800818:	78 1f                	js     800839 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80081a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80081d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800821:	74 1b                	je     80083e <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  800823:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800826:	8b 52 18             	mov    0x18(%edx),%edx
  800829:	85 d2                	test   %edx,%edx
  80082b:	74 32                	je     80085f <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80082d:	83 ec 08             	sub    $0x8,%esp
  800830:	ff 75 0c             	pushl  0xc(%ebp)
  800833:	50                   	push   %eax
  800834:	ff d2                	call   *%edx
  800836:	83 c4 10             	add    $0x10,%esp
}
  800839:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80083c:	c9                   	leave  
  80083d:	c3                   	ret    
			thisenv->env_id, fdnum);
  80083e:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800843:	8b 40 48             	mov    0x48(%eax),%eax
  800846:	83 ec 04             	sub    $0x4,%esp
  800849:	53                   	push   %ebx
  80084a:	50                   	push   %eax
  80084b:	68 b8 1e 80 00       	push   $0x801eb8
  800850:	e8 bb 08 00 00       	call   801110 <cprintf>
		return -E_INVAL;
  800855:	83 c4 10             	add    $0x10,%esp
  800858:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80085d:	eb da                	jmp    800839 <ftruncate+0x52>
		return -E_NOT_SUPP;
  80085f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800864:	eb d3                	jmp    800839 <ftruncate+0x52>

00800866 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800866:	55                   	push   %ebp
  800867:	89 e5                	mov    %esp,%ebp
  800869:	53                   	push   %ebx
  80086a:	83 ec 14             	sub    $0x14,%esp
  80086d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800870:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800873:	50                   	push   %eax
  800874:	ff 75 08             	pushl  0x8(%ebp)
  800877:	e8 81 fb ff ff       	call   8003fd <fd_lookup>
  80087c:	83 c4 08             	add    $0x8,%esp
  80087f:	85 c0                	test   %eax,%eax
  800881:	78 4b                	js     8008ce <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800883:	83 ec 08             	sub    $0x8,%esp
  800886:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800889:	50                   	push   %eax
  80088a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80088d:	ff 30                	pushl  (%eax)
  80088f:	e8 bf fb ff ff       	call   800453 <dev_lookup>
  800894:	83 c4 10             	add    $0x10,%esp
  800897:	85 c0                	test   %eax,%eax
  800899:	78 33                	js     8008ce <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  80089b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80089e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008a2:	74 2f                	je     8008d3 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008a4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008a7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008ae:	00 00 00 
	stat->st_isdir = 0;
  8008b1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008b8:	00 00 00 
	stat->st_dev = dev;
  8008bb:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008c1:	83 ec 08             	sub    $0x8,%esp
  8008c4:	53                   	push   %ebx
  8008c5:	ff 75 f0             	pushl  -0x10(%ebp)
  8008c8:	ff 50 14             	call   *0x14(%eax)
  8008cb:	83 c4 10             	add    $0x10,%esp
}
  8008ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008d1:	c9                   	leave  
  8008d2:	c3                   	ret    
		return -E_NOT_SUPP;
  8008d3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8008d8:	eb f4                	jmp    8008ce <fstat+0x68>

008008da <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008da:	55                   	push   %ebp
  8008db:	89 e5                	mov    %esp,%ebp
  8008dd:	56                   	push   %esi
  8008de:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008df:	83 ec 08             	sub    $0x8,%esp
  8008e2:	6a 00                	push   $0x0
  8008e4:	ff 75 08             	pushl  0x8(%ebp)
  8008e7:	e8 da 01 00 00       	call   800ac6 <open>
  8008ec:	89 c3                	mov    %eax,%ebx
  8008ee:	83 c4 10             	add    $0x10,%esp
  8008f1:	85 c0                	test   %eax,%eax
  8008f3:	78 1b                	js     800910 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008f5:	83 ec 08             	sub    $0x8,%esp
  8008f8:	ff 75 0c             	pushl  0xc(%ebp)
  8008fb:	50                   	push   %eax
  8008fc:	e8 65 ff ff ff       	call   800866 <fstat>
  800901:	89 c6                	mov    %eax,%esi
	close(fd);
  800903:	89 1c 24             	mov    %ebx,(%esp)
  800906:	e8 27 fc ff ff       	call   800532 <close>
	return r;
  80090b:	83 c4 10             	add    $0x10,%esp
  80090e:	89 f3                	mov    %esi,%ebx
}
  800910:	89 d8                	mov    %ebx,%eax
  800912:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800915:	5b                   	pop    %ebx
  800916:	5e                   	pop    %esi
  800917:	5d                   	pop    %ebp
  800918:	c3                   	ret    

00800919 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800919:	55                   	push   %ebp
  80091a:	89 e5                	mov    %esp,%ebp
  80091c:	56                   	push   %esi
  80091d:	53                   	push   %ebx
  80091e:	89 c6                	mov    %eax,%esi
  800920:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800922:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800929:	74 27                	je     800952 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80092b:	6a 07                	push   $0x7
  80092d:	68 00 50 80 00       	push   $0x805000
  800932:	56                   	push   %esi
  800933:	ff 35 00 40 80 00    	pushl  0x804000
  800939:	e8 04 12 00 00       	call   801b42 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80093e:	83 c4 0c             	add    $0xc,%esp
  800941:	6a 00                	push   $0x0
  800943:	53                   	push   %ebx
  800944:	6a 00                	push   $0x0
  800946:	e8 90 11 00 00       	call   801adb <ipc_recv>
}
  80094b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80094e:	5b                   	pop    %ebx
  80094f:	5e                   	pop    %esi
  800950:	5d                   	pop    %ebp
  800951:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800952:	83 ec 0c             	sub    $0xc,%esp
  800955:	6a 01                	push   $0x1
  800957:	e8 3a 12 00 00       	call   801b96 <ipc_find_env>
  80095c:	a3 00 40 80 00       	mov    %eax,0x804000
  800961:	83 c4 10             	add    $0x10,%esp
  800964:	eb c5                	jmp    80092b <fsipc+0x12>

00800966 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800966:	55                   	push   %ebp
  800967:	89 e5                	mov    %esp,%ebp
  800969:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80096c:	8b 45 08             	mov    0x8(%ebp),%eax
  80096f:	8b 40 0c             	mov    0xc(%eax),%eax
  800972:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800977:	8b 45 0c             	mov    0xc(%ebp),%eax
  80097a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80097f:	ba 00 00 00 00       	mov    $0x0,%edx
  800984:	b8 02 00 00 00       	mov    $0x2,%eax
  800989:	e8 8b ff ff ff       	call   800919 <fsipc>
}
  80098e:	c9                   	leave  
  80098f:	c3                   	ret    

00800990 <devfile_flush>:
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800996:	8b 45 08             	mov    0x8(%ebp),%eax
  800999:	8b 40 0c             	mov    0xc(%eax),%eax
  80099c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a6:	b8 06 00 00 00       	mov    $0x6,%eax
  8009ab:	e8 69 ff ff ff       	call   800919 <fsipc>
}
  8009b0:	c9                   	leave  
  8009b1:	c3                   	ret    

008009b2 <devfile_stat>:
{
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	53                   	push   %ebx
  8009b6:	83 ec 04             	sub    $0x4,%esp
  8009b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bf:	8b 40 0c             	mov    0xc(%eax),%eax
  8009c2:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8009cc:	b8 05 00 00 00       	mov    $0x5,%eax
  8009d1:	e8 43 ff ff ff       	call   800919 <fsipc>
  8009d6:	85 c0                	test   %eax,%eax
  8009d8:	78 2c                	js     800a06 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009da:	83 ec 08             	sub    $0x8,%esp
  8009dd:	68 00 50 80 00       	push   $0x805000
  8009e2:	53                   	push   %ebx
  8009e3:	e8 47 0d 00 00       	call   80172f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009e8:	a1 80 50 80 00       	mov    0x805080,%eax
  8009ed:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009f3:	a1 84 50 80 00       	mov    0x805084,%eax
  8009f8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009fe:	83 c4 10             	add    $0x10,%esp
  800a01:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a06:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a09:	c9                   	leave  
  800a0a:	c3                   	ret    

00800a0b <devfile_write>:
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	83 ec 0c             	sub    $0xc,%esp
  800a11:	8b 45 10             	mov    0x10(%ebp),%eax
    	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a14:	8b 55 08             	mov    0x8(%ebp),%edx
  800a17:	8b 52 0c             	mov    0xc(%edx),%edx
  800a1a:	89 15 00 50 80 00    	mov    %edx,0x805000
    	fsipcbuf.write.req_n = n;
  800a20:	a3 04 50 80 00       	mov    %eax,0x805004
    	memmove(fsipcbuf.write.req_buf, buf, n);
  800a25:	50                   	push   %eax
  800a26:	ff 75 0c             	pushl  0xc(%ebp)
  800a29:	68 08 50 80 00       	push   $0x805008
  800a2e:	e8 8a 0e 00 00       	call   8018bd <memmove>
    	return fsipc(FSREQ_WRITE, NULL);
  800a33:	ba 00 00 00 00       	mov    $0x0,%edx
  800a38:	b8 04 00 00 00       	mov    $0x4,%eax
  800a3d:	e8 d7 fe ff ff       	call   800919 <fsipc>
}
  800a42:	c9                   	leave  
  800a43:	c3                   	ret    

00800a44 <devfile_read>:
{
  800a44:	55                   	push   %ebp
  800a45:	89 e5                	mov    %esp,%ebp
  800a47:	56                   	push   %esi
  800a48:	53                   	push   %ebx
  800a49:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4f:	8b 40 0c             	mov    0xc(%eax),%eax
  800a52:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a57:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a5d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a62:	b8 03 00 00 00       	mov    $0x3,%eax
  800a67:	e8 ad fe ff ff       	call   800919 <fsipc>
  800a6c:	89 c3                	mov    %eax,%ebx
  800a6e:	85 c0                	test   %eax,%eax
  800a70:	78 1f                	js     800a91 <devfile_read+0x4d>
	assert(r <= n);
  800a72:	39 f0                	cmp    %esi,%eax
  800a74:	77 24                	ja     800a9a <devfile_read+0x56>
	assert(r <= PGSIZE);
  800a76:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a7b:	7f 33                	jg     800ab0 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a7d:	83 ec 04             	sub    $0x4,%esp
  800a80:	50                   	push   %eax
  800a81:	68 00 50 80 00       	push   $0x805000
  800a86:	ff 75 0c             	pushl  0xc(%ebp)
  800a89:	e8 2f 0e 00 00       	call   8018bd <memmove>
	return r;
  800a8e:	83 c4 10             	add    $0x10,%esp
}
  800a91:	89 d8                	mov    %ebx,%eax
  800a93:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a96:	5b                   	pop    %ebx
  800a97:	5e                   	pop    %esi
  800a98:	5d                   	pop    %ebp
  800a99:	c3                   	ret    
	assert(r <= n);
  800a9a:	68 24 1f 80 00       	push   $0x801f24
  800a9f:	68 2b 1f 80 00       	push   $0x801f2b
  800aa4:	6a 7c                	push   $0x7c
  800aa6:	68 40 1f 80 00       	push   $0x801f40
  800aab:	e8 85 05 00 00       	call   801035 <_panic>
	assert(r <= PGSIZE);
  800ab0:	68 4b 1f 80 00       	push   $0x801f4b
  800ab5:	68 2b 1f 80 00       	push   $0x801f2b
  800aba:	6a 7d                	push   $0x7d
  800abc:	68 40 1f 80 00       	push   $0x801f40
  800ac1:	e8 6f 05 00 00       	call   801035 <_panic>

00800ac6 <open>:
{
  800ac6:	55                   	push   %ebp
  800ac7:	89 e5                	mov    %esp,%ebp
  800ac9:	56                   	push   %esi
  800aca:	53                   	push   %ebx
  800acb:	83 ec 1c             	sub    $0x1c,%esp
  800ace:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800ad1:	56                   	push   %esi
  800ad2:	e8 21 0c 00 00       	call   8016f8 <strlen>
  800ad7:	83 c4 10             	add    $0x10,%esp
  800ada:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800adf:	7f 6c                	jg     800b4d <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  800ae1:	83 ec 0c             	sub    $0xc,%esp
  800ae4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ae7:	50                   	push   %eax
  800ae8:	e8 c1 f8 ff ff       	call   8003ae <fd_alloc>
  800aed:	89 c3                	mov    %eax,%ebx
  800aef:	83 c4 10             	add    $0x10,%esp
  800af2:	85 c0                	test   %eax,%eax
  800af4:	78 3c                	js     800b32 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  800af6:	83 ec 08             	sub    $0x8,%esp
  800af9:	56                   	push   %esi
  800afa:	68 00 50 80 00       	push   $0x805000
  800aff:	e8 2b 0c 00 00       	call   80172f <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b04:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b07:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b0c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b0f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b14:	e8 00 fe ff ff       	call   800919 <fsipc>
  800b19:	89 c3                	mov    %eax,%ebx
  800b1b:	83 c4 10             	add    $0x10,%esp
  800b1e:	85 c0                	test   %eax,%eax
  800b20:	78 19                	js     800b3b <open+0x75>
	return fd2num(fd);
  800b22:	83 ec 0c             	sub    $0xc,%esp
  800b25:	ff 75 f4             	pushl  -0xc(%ebp)
  800b28:	e8 5a f8 ff ff       	call   800387 <fd2num>
  800b2d:	89 c3                	mov    %eax,%ebx
  800b2f:	83 c4 10             	add    $0x10,%esp
}
  800b32:	89 d8                	mov    %ebx,%eax
  800b34:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b37:	5b                   	pop    %ebx
  800b38:	5e                   	pop    %esi
  800b39:	5d                   	pop    %ebp
  800b3a:	c3                   	ret    
		fd_close(fd, 0);
  800b3b:	83 ec 08             	sub    $0x8,%esp
  800b3e:	6a 00                	push   $0x0
  800b40:	ff 75 f4             	pushl  -0xc(%ebp)
  800b43:	e8 61 f9 ff ff       	call   8004a9 <fd_close>
		return r;
  800b48:	83 c4 10             	add    $0x10,%esp
  800b4b:	eb e5                	jmp    800b32 <open+0x6c>
		return -E_BAD_PATH;
  800b4d:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b52:	eb de                	jmp    800b32 <open+0x6c>

00800b54 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b54:	55                   	push   %ebp
  800b55:	89 e5                	mov    %esp,%ebp
  800b57:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b5a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5f:	b8 08 00 00 00       	mov    $0x8,%eax
  800b64:	e8 b0 fd ff ff       	call   800919 <fsipc>
}
  800b69:	c9                   	leave  
  800b6a:	c3                   	ret    

00800b6b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b6b:	55                   	push   %ebp
  800b6c:	89 e5                	mov    %esp,%ebp
  800b6e:	56                   	push   %esi
  800b6f:	53                   	push   %ebx
  800b70:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b73:	83 ec 0c             	sub    $0xc,%esp
  800b76:	ff 75 08             	pushl  0x8(%ebp)
  800b79:	e8 19 f8 ff ff       	call   800397 <fd2data>
  800b7e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b80:	83 c4 08             	add    $0x8,%esp
  800b83:	68 57 1f 80 00       	push   $0x801f57
  800b88:	53                   	push   %ebx
  800b89:	e8 a1 0b 00 00       	call   80172f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b8e:	8b 46 04             	mov    0x4(%esi),%eax
  800b91:	2b 06                	sub    (%esi),%eax
  800b93:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b99:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800ba0:	00 00 00 
	stat->st_dev = &devpipe;
  800ba3:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800baa:	30 80 00 
	return 0;
}
  800bad:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bb5:	5b                   	pop    %ebx
  800bb6:	5e                   	pop    %esi
  800bb7:	5d                   	pop    %ebp
  800bb8:	c3                   	ret    

00800bb9 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bb9:	55                   	push   %ebp
  800bba:	89 e5                	mov    %esp,%ebp
  800bbc:	53                   	push   %ebx
  800bbd:	83 ec 0c             	sub    $0xc,%esp
  800bc0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bc3:	53                   	push   %ebx
  800bc4:	6a 00                	push   $0x0
  800bc6:	e8 2a f6 ff ff       	call   8001f5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bcb:	89 1c 24             	mov    %ebx,(%esp)
  800bce:	e8 c4 f7 ff ff       	call   800397 <fd2data>
  800bd3:	83 c4 08             	add    $0x8,%esp
  800bd6:	50                   	push   %eax
  800bd7:	6a 00                	push   $0x0
  800bd9:	e8 17 f6 ff ff       	call   8001f5 <sys_page_unmap>
}
  800bde:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800be1:	c9                   	leave  
  800be2:	c3                   	ret    

00800be3 <_pipeisclosed>:
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	57                   	push   %edi
  800be7:	56                   	push   %esi
  800be8:	53                   	push   %ebx
  800be9:	83 ec 1c             	sub    $0x1c,%esp
  800bec:	89 c7                	mov    %eax,%edi
  800bee:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800bf0:	a1 04 40 80 00       	mov    0x804004,%eax
  800bf5:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800bf8:	83 ec 0c             	sub    $0xc,%esp
  800bfb:	57                   	push   %edi
  800bfc:	e8 ce 0f 00 00       	call   801bcf <pageref>
  800c01:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c04:	89 34 24             	mov    %esi,(%esp)
  800c07:	e8 c3 0f 00 00       	call   801bcf <pageref>
		nn = thisenv->env_runs;
  800c0c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c12:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c15:	83 c4 10             	add    $0x10,%esp
  800c18:	39 cb                	cmp    %ecx,%ebx
  800c1a:	74 1b                	je     800c37 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800c1c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c1f:	75 cf                	jne    800bf0 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c21:	8b 42 58             	mov    0x58(%edx),%eax
  800c24:	6a 01                	push   $0x1
  800c26:	50                   	push   %eax
  800c27:	53                   	push   %ebx
  800c28:	68 5e 1f 80 00       	push   $0x801f5e
  800c2d:	e8 de 04 00 00       	call   801110 <cprintf>
  800c32:	83 c4 10             	add    $0x10,%esp
  800c35:	eb b9                	jmp    800bf0 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800c37:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c3a:	0f 94 c0             	sete   %al
  800c3d:	0f b6 c0             	movzbl %al,%eax
}
  800c40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c43:	5b                   	pop    %ebx
  800c44:	5e                   	pop    %esi
  800c45:	5f                   	pop    %edi
  800c46:	5d                   	pop    %ebp
  800c47:	c3                   	ret    

00800c48 <devpipe_write>:
{
  800c48:	55                   	push   %ebp
  800c49:	89 e5                	mov    %esp,%ebp
  800c4b:	57                   	push   %edi
  800c4c:	56                   	push   %esi
  800c4d:	53                   	push   %ebx
  800c4e:	83 ec 28             	sub    $0x28,%esp
  800c51:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800c54:	56                   	push   %esi
  800c55:	e8 3d f7 ff ff       	call   800397 <fd2data>
  800c5a:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c5c:	83 c4 10             	add    $0x10,%esp
  800c5f:	bf 00 00 00 00       	mov    $0x0,%edi
  800c64:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c67:	74 4f                	je     800cb8 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c69:	8b 43 04             	mov    0x4(%ebx),%eax
  800c6c:	8b 0b                	mov    (%ebx),%ecx
  800c6e:	8d 51 20             	lea    0x20(%ecx),%edx
  800c71:	39 d0                	cmp    %edx,%eax
  800c73:	72 14                	jb     800c89 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  800c75:	89 da                	mov    %ebx,%edx
  800c77:	89 f0                	mov    %esi,%eax
  800c79:	e8 65 ff ff ff       	call   800be3 <_pipeisclosed>
  800c7e:	85 c0                	test   %eax,%eax
  800c80:	75 3a                	jne    800cbc <devpipe_write+0x74>
			sys_yield();
  800c82:	e8 ca f4 ff ff       	call   800151 <sys_yield>
  800c87:	eb e0                	jmp    800c69 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c90:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c93:	89 c2                	mov    %eax,%edx
  800c95:	c1 fa 1f             	sar    $0x1f,%edx
  800c98:	89 d1                	mov    %edx,%ecx
  800c9a:	c1 e9 1b             	shr    $0x1b,%ecx
  800c9d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800ca0:	83 e2 1f             	and    $0x1f,%edx
  800ca3:	29 ca                	sub    %ecx,%edx
  800ca5:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800ca9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cad:	83 c0 01             	add    $0x1,%eax
  800cb0:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800cb3:	83 c7 01             	add    $0x1,%edi
  800cb6:	eb ac                	jmp    800c64 <devpipe_write+0x1c>
	return i;
  800cb8:	89 f8                	mov    %edi,%eax
  800cba:	eb 05                	jmp    800cc1 <devpipe_write+0x79>
				return 0;
  800cbc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc4:	5b                   	pop    %ebx
  800cc5:	5e                   	pop    %esi
  800cc6:	5f                   	pop    %edi
  800cc7:	5d                   	pop    %ebp
  800cc8:	c3                   	ret    

00800cc9 <devpipe_read>:
{
  800cc9:	55                   	push   %ebp
  800cca:	89 e5                	mov    %esp,%ebp
  800ccc:	57                   	push   %edi
  800ccd:	56                   	push   %esi
  800cce:	53                   	push   %ebx
  800ccf:	83 ec 18             	sub    $0x18,%esp
  800cd2:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800cd5:	57                   	push   %edi
  800cd6:	e8 bc f6 ff ff       	call   800397 <fd2data>
  800cdb:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800cdd:	83 c4 10             	add    $0x10,%esp
  800ce0:	be 00 00 00 00       	mov    $0x0,%esi
  800ce5:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ce8:	74 47                	je     800d31 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  800cea:	8b 03                	mov    (%ebx),%eax
  800cec:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cef:	75 22                	jne    800d13 <devpipe_read+0x4a>
			if (i > 0)
  800cf1:	85 f6                	test   %esi,%esi
  800cf3:	75 14                	jne    800d09 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  800cf5:	89 da                	mov    %ebx,%edx
  800cf7:	89 f8                	mov    %edi,%eax
  800cf9:	e8 e5 fe ff ff       	call   800be3 <_pipeisclosed>
  800cfe:	85 c0                	test   %eax,%eax
  800d00:	75 33                	jne    800d35 <devpipe_read+0x6c>
			sys_yield();
  800d02:	e8 4a f4 ff ff       	call   800151 <sys_yield>
  800d07:	eb e1                	jmp    800cea <devpipe_read+0x21>
				return i;
  800d09:	89 f0                	mov    %esi,%eax
}
  800d0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0e:	5b                   	pop    %ebx
  800d0f:	5e                   	pop    %esi
  800d10:	5f                   	pop    %edi
  800d11:	5d                   	pop    %ebp
  800d12:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d13:	99                   	cltd   
  800d14:	c1 ea 1b             	shr    $0x1b,%edx
  800d17:	01 d0                	add    %edx,%eax
  800d19:	83 e0 1f             	and    $0x1f,%eax
  800d1c:	29 d0                	sub    %edx,%eax
  800d1e:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800d23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d26:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800d29:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800d2c:	83 c6 01             	add    $0x1,%esi
  800d2f:	eb b4                	jmp    800ce5 <devpipe_read+0x1c>
	return i;
  800d31:	89 f0                	mov    %esi,%eax
  800d33:	eb d6                	jmp    800d0b <devpipe_read+0x42>
				return 0;
  800d35:	b8 00 00 00 00       	mov    $0x0,%eax
  800d3a:	eb cf                	jmp    800d0b <devpipe_read+0x42>

00800d3c <pipe>:
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	56                   	push   %esi
  800d40:	53                   	push   %ebx
  800d41:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800d44:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d47:	50                   	push   %eax
  800d48:	e8 61 f6 ff ff       	call   8003ae <fd_alloc>
  800d4d:	89 c3                	mov    %eax,%ebx
  800d4f:	83 c4 10             	add    $0x10,%esp
  800d52:	85 c0                	test   %eax,%eax
  800d54:	78 5b                	js     800db1 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d56:	83 ec 04             	sub    $0x4,%esp
  800d59:	68 07 04 00 00       	push   $0x407
  800d5e:	ff 75 f4             	pushl  -0xc(%ebp)
  800d61:	6a 00                	push   $0x0
  800d63:	e8 08 f4 ff ff       	call   800170 <sys_page_alloc>
  800d68:	89 c3                	mov    %eax,%ebx
  800d6a:	83 c4 10             	add    $0x10,%esp
  800d6d:	85 c0                	test   %eax,%eax
  800d6f:	78 40                	js     800db1 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  800d71:	83 ec 0c             	sub    $0xc,%esp
  800d74:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d77:	50                   	push   %eax
  800d78:	e8 31 f6 ff ff       	call   8003ae <fd_alloc>
  800d7d:	89 c3                	mov    %eax,%ebx
  800d7f:	83 c4 10             	add    $0x10,%esp
  800d82:	85 c0                	test   %eax,%eax
  800d84:	78 1b                	js     800da1 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d86:	83 ec 04             	sub    $0x4,%esp
  800d89:	68 07 04 00 00       	push   $0x407
  800d8e:	ff 75 f0             	pushl  -0x10(%ebp)
  800d91:	6a 00                	push   $0x0
  800d93:	e8 d8 f3 ff ff       	call   800170 <sys_page_alloc>
  800d98:	89 c3                	mov    %eax,%ebx
  800d9a:	83 c4 10             	add    $0x10,%esp
  800d9d:	85 c0                	test   %eax,%eax
  800d9f:	79 19                	jns    800dba <pipe+0x7e>
	sys_page_unmap(0, fd0);
  800da1:	83 ec 08             	sub    $0x8,%esp
  800da4:	ff 75 f4             	pushl  -0xc(%ebp)
  800da7:	6a 00                	push   $0x0
  800da9:	e8 47 f4 ff ff       	call   8001f5 <sys_page_unmap>
  800dae:	83 c4 10             	add    $0x10,%esp
}
  800db1:	89 d8                	mov    %ebx,%eax
  800db3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800db6:	5b                   	pop    %ebx
  800db7:	5e                   	pop    %esi
  800db8:	5d                   	pop    %ebp
  800db9:	c3                   	ret    
	va = fd2data(fd0);
  800dba:	83 ec 0c             	sub    $0xc,%esp
  800dbd:	ff 75 f4             	pushl  -0xc(%ebp)
  800dc0:	e8 d2 f5 ff ff       	call   800397 <fd2data>
  800dc5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dc7:	83 c4 0c             	add    $0xc,%esp
  800dca:	68 07 04 00 00       	push   $0x407
  800dcf:	50                   	push   %eax
  800dd0:	6a 00                	push   $0x0
  800dd2:	e8 99 f3 ff ff       	call   800170 <sys_page_alloc>
  800dd7:	89 c3                	mov    %eax,%ebx
  800dd9:	83 c4 10             	add    $0x10,%esp
  800ddc:	85 c0                	test   %eax,%eax
  800dde:	0f 88 8c 00 00 00    	js     800e70 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800de4:	83 ec 0c             	sub    $0xc,%esp
  800de7:	ff 75 f0             	pushl  -0x10(%ebp)
  800dea:	e8 a8 f5 ff ff       	call   800397 <fd2data>
  800def:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800df6:	50                   	push   %eax
  800df7:	6a 00                	push   $0x0
  800df9:	56                   	push   %esi
  800dfa:	6a 00                	push   $0x0
  800dfc:	e8 b2 f3 ff ff       	call   8001b3 <sys_page_map>
  800e01:	89 c3                	mov    %eax,%ebx
  800e03:	83 c4 20             	add    $0x20,%esp
  800e06:	85 c0                	test   %eax,%eax
  800e08:	78 58                	js     800e62 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  800e0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e0d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e13:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e15:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e18:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  800e1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e22:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e28:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e2d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800e34:	83 ec 0c             	sub    $0xc,%esp
  800e37:	ff 75 f4             	pushl  -0xc(%ebp)
  800e3a:	e8 48 f5 ff ff       	call   800387 <fd2num>
  800e3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e42:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e44:	83 c4 04             	add    $0x4,%esp
  800e47:	ff 75 f0             	pushl  -0x10(%ebp)
  800e4a:	e8 38 f5 ff ff       	call   800387 <fd2num>
  800e4f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e52:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e55:	83 c4 10             	add    $0x10,%esp
  800e58:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e5d:	e9 4f ff ff ff       	jmp    800db1 <pipe+0x75>
	sys_page_unmap(0, va);
  800e62:	83 ec 08             	sub    $0x8,%esp
  800e65:	56                   	push   %esi
  800e66:	6a 00                	push   $0x0
  800e68:	e8 88 f3 ff ff       	call   8001f5 <sys_page_unmap>
  800e6d:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800e70:	83 ec 08             	sub    $0x8,%esp
  800e73:	ff 75 f0             	pushl  -0x10(%ebp)
  800e76:	6a 00                	push   $0x0
  800e78:	e8 78 f3 ff ff       	call   8001f5 <sys_page_unmap>
  800e7d:	83 c4 10             	add    $0x10,%esp
  800e80:	e9 1c ff ff ff       	jmp    800da1 <pipe+0x65>

00800e85 <pipeisclosed>:
{
  800e85:	55                   	push   %ebp
  800e86:	89 e5                	mov    %esp,%ebp
  800e88:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e8b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e8e:	50                   	push   %eax
  800e8f:	ff 75 08             	pushl  0x8(%ebp)
  800e92:	e8 66 f5 ff ff       	call   8003fd <fd_lookup>
  800e97:	83 c4 10             	add    $0x10,%esp
  800e9a:	85 c0                	test   %eax,%eax
  800e9c:	78 18                	js     800eb6 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  800e9e:	83 ec 0c             	sub    $0xc,%esp
  800ea1:	ff 75 f4             	pushl  -0xc(%ebp)
  800ea4:	e8 ee f4 ff ff       	call   800397 <fd2data>
	return _pipeisclosed(fd, p);
  800ea9:	89 c2                	mov    %eax,%edx
  800eab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eae:	e8 30 fd ff ff       	call   800be3 <_pipeisclosed>
  800eb3:	83 c4 10             	add    $0x10,%esp
}
  800eb6:	c9                   	leave  
  800eb7:	c3                   	ret    

00800eb8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800eb8:	55                   	push   %ebp
  800eb9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ebb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec0:	5d                   	pop    %ebp
  800ec1:	c3                   	ret    

00800ec2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ec2:	55                   	push   %ebp
  800ec3:	89 e5                	mov    %esp,%ebp
  800ec5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ec8:	68 76 1f 80 00       	push   $0x801f76
  800ecd:	ff 75 0c             	pushl  0xc(%ebp)
  800ed0:	e8 5a 08 00 00       	call   80172f <strcpy>
	return 0;
}
  800ed5:	b8 00 00 00 00       	mov    $0x0,%eax
  800eda:	c9                   	leave  
  800edb:	c3                   	ret    

00800edc <devcons_write>:
{
  800edc:	55                   	push   %ebp
  800edd:	89 e5                	mov    %esp,%ebp
  800edf:	57                   	push   %edi
  800ee0:	56                   	push   %esi
  800ee1:	53                   	push   %ebx
  800ee2:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800ee8:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800eed:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800ef3:	eb 2f                	jmp    800f24 <devcons_write+0x48>
		m = n - tot;
  800ef5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ef8:	29 f3                	sub    %esi,%ebx
  800efa:	83 fb 7f             	cmp    $0x7f,%ebx
  800efd:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800f02:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800f05:	83 ec 04             	sub    $0x4,%esp
  800f08:	53                   	push   %ebx
  800f09:	89 f0                	mov    %esi,%eax
  800f0b:	03 45 0c             	add    0xc(%ebp),%eax
  800f0e:	50                   	push   %eax
  800f0f:	57                   	push   %edi
  800f10:	e8 a8 09 00 00       	call   8018bd <memmove>
		sys_cputs(buf, m);
  800f15:	83 c4 08             	add    $0x8,%esp
  800f18:	53                   	push   %ebx
  800f19:	57                   	push   %edi
  800f1a:	e8 95 f1 ff ff       	call   8000b4 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800f1f:	01 de                	add    %ebx,%esi
  800f21:	83 c4 10             	add    $0x10,%esp
  800f24:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f27:	72 cc                	jb     800ef5 <devcons_write+0x19>
}
  800f29:	89 f0                	mov    %esi,%eax
  800f2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f2e:	5b                   	pop    %ebx
  800f2f:	5e                   	pop    %esi
  800f30:	5f                   	pop    %edi
  800f31:	5d                   	pop    %ebp
  800f32:	c3                   	ret    

00800f33 <devcons_read>:
{
  800f33:	55                   	push   %ebp
  800f34:	89 e5                	mov    %esp,%ebp
  800f36:	83 ec 08             	sub    $0x8,%esp
  800f39:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800f3e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f42:	75 07                	jne    800f4b <devcons_read+0x18>
}
  800f44:	c9                   	leave  
  800f45:	c3                   	ret    
		sys_yield();
  800f46:	e8 06 f2 ff ff       	call   800151 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  800f4b:	e8 82 f1 ff ff       	call   8000d2 <sys_cgetc>
  800f50:	85 c0                	test   %eax,%eax
  800f52:	74 f2                	je     800f46 <devcons_read+0x13>
	if (c < 0)
  800f54:	85 c0                	test   %eax,%eax
  800f56:	78 ec                	js     800f44 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  800f58:	83 f8 04             	cmp    $0x4,%eax
  800f5b:	74 0c                	je     800f69 <devcons_read+0x36>
	*(char*)vbuf = c;
  800f5d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f60:	88 02                	mov    %al,(%edx)
	return 1;
  800f62:	b8 01 00 00 00       	mov    $0x1,%eax
  800f67:	eb db                	jmp    800f44 <devcons_read+0x11>
		return 0;
  800f69:	b8 00 00 00 00       	mov    $0x0,%eax
  800f6e:	eb d4                	jmp    800f44 <devcons_read+0x11>

00800f70 <cputchar>:
{
  800f70:	55                   	push   %ebp
  800f71:	89 e5                	mov    %esp,%ebp
  800f73:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f76:	8b 45 08             	mov    0x8(%ebp),%eax
  800f79:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800f7c:	6a 01                	push   $0x1
  800f7e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f81:	50                   	push   %eax
  800f82:	e8 2d f1 ff ff       	call   8000b4 <sys_cputs>
}
  800f87:	83 c4 10             	add    $0x10,%esp
  800f8a:	c9                   	leave  
  800f8b:	c3                   	ret    

00800f8c <getchar>:
{
  800f8c:	55                   	push   %ebp
  800f8d:	89 e5                	mov    %esp,%ebp
  800f8f:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800f92:	6a 01                	push   $0x1
  800f94:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f97:	50                   	push   %eax
  800f98:	6a 00                	push   $0x0
  800f9a:	e8 cf f6 ff ff       	call   80066e <read>
	if (r < 0)
  800f9f:	83 c4 10             	add    $0x10,%esp
  800fa2:	85 c0                	test   %eax,%eax
  800fa4:	78 08                	js     800fae <getchar+0x22>
	if (r < 1)
  800fa6:	85 c0                	test   %eax,%eax
  800fa8:	7e 06                	jle    800fb0 <getchar+0x24>
	return c;
  800faa:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800fae:	c9                   	leave  
  800faf:	c3                   	ret    
		return -E_EOF;
  800fb0:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800fb5:	eb f7                	jmp    800fae <getchar+0x22>

00800fb7 <iscons>:
{
  800fb7:	55                   	push   %ebp
  800fb8:	89 e5                	mov    %esp,%ebp
  800fba:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fbd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fc0:	50                   	push   %eax
  800fc1:	ff 75 08             	pushl  0x8(%ebp)
  800fc4:	e8 34 f4 ff ff       	call   8003fd <fd_lookup>
  800fc9:	83 c4 10             	add    $0x10,%esp
  800fcc:	85 c0                	test   %eax,%eax
  800fce:	78 11                	js     800fe1 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  800fd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fd3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fd9:	39 10                	cmp    %edx,(%eax)
  800fdb:	0f 94 c0             	sete   %al
  800fde:	0f b6 c0             	movzbl %al,%eax
}
  800fe1:	c9                   	leave  
  800fe2:	c3                   	ret    

00800fe3 <opencons>:
{
  800fe3:	55                   	push   %ebp
  800fe4:	89 e5                	mov    %esp,%ebp
  800fe6:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800fe9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fec:	50                   	push   %eax
  800fed:	e8 bc f3 ff ff       	call   8003ae <fd_alloc>
  800ff2:	83 c4 10             	add    $0x10,%esp
  800ff5:	85 c0                	test   %eax,%eax
  800ff7:	78 3a                	js     801033 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800ff9:	83 ec 04             	sub    $0x4,%esp
  800ffc:	68 07 04 00 00       	push   $0x407
  801001:	ff 75 f4             	pushl  -0xc(%ebp)
  801004:	6a 00                	push   $0x0
  801006:	e8 65 f1 ff ff       	call   800170 <sys_page_alloc>
  80100b:	83 c4 10             	add    $0x10,%esp
  80100e:	85 c0                	test   %eax,%eax
  801010:	78 21                	js     801033 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801012:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801015:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80101b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80101d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801020:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801027:	83 ec 0c             	sub    $0xc,%esp
  80102a:	50                   	push   %eax
  80102b:	e8 57 f3 ff ff       	call   800387 <fd2num>
  801030:	83 c4 10             	add    $0x10,%esp
}
  801033:	c9                   	leave  
  801034:	c3                   	ret    

00801035 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801035:	55                   	push   %ebp
  801036:	89 e5                	mov    %esp,%ebp
  801038:	56                   	push   %esi
  801039:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80103a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80103d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801043:	e8 ea f0 ff ff       	call   800132 <sys_getenvid>
  801048:	83 ec 0c             	sub    $0xc,%esp
  80104b:	ff 75 0c             	pushl  0xc(%ebp)
  80104e:	ff 75 08             	pushl  0x8(%ebp)
  801051:	56                   	push   %esi
  801052:	50                   	push   %eax
  801053:	68 84 1f 80 00       	push   $0x801f84
  801058:	e8 b3 00 00 00       	call   801110 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80105d:	83 c4 18             	add    $0x18,%esp
  801060:	53                   	push   %ebx
  801061:	ff 75 10             	pushl  0x10(%ebp)
  801064:	e8 56 00 00 00       	call   8010bf <vcprintf>
	cprintf("\n");
  801069:	c7 04 24 6f 1f 80 00 	movl   $0x801f6f,(%esp)
  801070:	e8 9b 00 00 00       	call   801110 <cprintf>
  801075:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801078:	cc                   	int3   
  801079:	eb fd                	jmp    801078 <_panic+0x43>

0080107b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80107b:	55                   	push   %ebp
  80107c:	89 e5                	mov    %esp,%ebp
  80107e:	53                   	push   %ebx
  80107f:	83 ec 04             	sub    $0x4,%esp
  801082:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801085:	8b 13                	mov    (%ebx),%edx
  801087:	8d 42 01             	lea    0x1(%edx),%eax
  80108a:	89 03                	mov    %eax,(%ebx)
  80108c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80108f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801093:	3d ff 00 00 00       	cmp    $0xff,%eax
  801098:	74 09                	je     8010a3 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80109a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80109e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010a1:	c9                   	leave  
  8010a2:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8010a3:	83 ec 08             	sub    $0x8,%esp
  8010a6:	68 ff 00 00 00       	push   $0xff
  8010ab:	8d 43 08             	lea    0x8(%ebx),%eax
  8010ae:	50                   	push   %eax
  8010af:	e8 00 f0 ff ff       	call   8000b4 <sys_cputs>
		b->idx = 0;
  8010b4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010ba:	83 c4 10             	add    $0x10,%esp
  8010bd:	eb db                	jmp    80109a <putch+0x1f>

008010bf <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010bf:	55                   	push   %ebp
  8010c0:	89 e5                	mov    %esp,%ebp
  8010c2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010c8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010cf:	00 00 00 
	b.cnt = 0;
  8010d2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010d9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010dc:	ff 75 0c             	pushl  0xc(%ebp)
  8010df:	ff 75 08             	pushl  0x8(%ebp)
  8010e2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010e8:	50                   	push   %eax
  8010e9:	68 7b 10 80 00       	push   $0x80107b
  8010ee:	e8 1a 01 00 00       	call   80120d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010f3:	83 c4 08             	add    $0x8,%esp
  8010f6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010fc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801102:	50                   	push   %eax
  801103:	e8 ac ef ff ff       	call   8000b4 <sys_cputs>

	return b.cnt;
}
  801108:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80110e:	c9                   	leave  
  80110f:	c3                   	ret    

00801110 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801110:	55                   	push   %ebp
  801111:	89 e5                	mov    %esp,%ebp
  801113:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801116:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801119:	50                   	push   %eax
  80111a:	ff 75 08             	pushl  0x8(%ebp)
  80111d:	e8 9d ff ff ff       	call   8010bf <vcprintf>
	va_end(ap);

	return cnt;
}
  801122:	c9                   	leave  
  801123:	c3                   	ret    

00801124 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801124:	55                   	push   %ebp
  801125:	89 e5                	mov    %esp,%ebp
  801127:	57                   	push   %edi
  801128:	56                   	push   %esi
  801129:	53                   	push   %ebx
  80112a:	83 ec 1c             	sub    $0x1c,%esp
  80112d:	89 c7                	mov    %eax,%edi
  80112f:	89 d6                	mov    %edx,%esi
  801131:	8b 45 08             	mov    0x8(%ebp),%eax
  801134:	8b 55 0c             	mov    0xc(%ebp),%edx
  801137:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80113a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80113d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801140:	bb 00 00 00 00       	mov    $0x0,%ebx
  801145:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801148:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80114b:	39 d3                	cmp    %edx,%ebx
  80114d:	72 05                	jb     801154 <printnum+0x30>
  80114f:	39 45 10             	cmp    %eax,0x10(%ebp)
  801152:	77 7a                	ja     8011ce <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801154:	83 ec 0c             	sub    $0xc,%esp
  801157:	ff 75 18             	pushl  0x18(%ebp)
  80115a:	8b 45 14             	mov    0x14(%ebp),%eax
  80115d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801160:	53                   	push   %ebx
  801161:	ff 75 10             	pushl  0x10(%ebp)
  801164:	83 ec 08             	sub    $0x8,%esp
  801167:	ff 75 e4             	pushl  -0x1c(%ebp)
  80116a:	ff 75 e0             	pushl  -0x20(%ebp)
  80116d:	ff 75 dc             	pushl  -0x24(%ebp)
  801170:	ff 75 d8             	pushl  -0x28(%ebp)
  801173:	e8 98 0a 00 00       	call   801c10 <__udivdi3>
  801178:	83 c4 18             	add    $0x18,%esp
  80117b:	52                   	push   %edx
  80117c:	50                   	push   %eax
  80117d:	89 f2                	mov    %esi,%edx
  80117f:	89 f8                	mov    %edi,%eax
  801181:	e8 9e ff ff ff       	call   801124 <printnum>
  801186:	83 c4 20             	add    $0x20,%esp
  801189:	eb 13                	jmp    80119e <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80118b:	83 ec 08             	sub    $0x8,%esp
  80118e:	56                   	push   %esi
  80118f:	ff 75 18             	pushl  0x18(%ebp)
  801192:	ff d7                	call   *%edi
  801194:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801197:	83 eb 01             	sub    $0x1,%ebx
  80119a:	85 db                	test   %ebx,%ebx
  80119c:	7f ed                	jg     80118b <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80119e:	83 ec 08             	sub    $0x8,%esp
  8011a1:	56                   	push   %esi
  8011a2:	83 ec 04             	sub    $0x4,%esp
  8011a5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011a8:	ff 75 e0             	pushl  -0x20(%ebp)
  8011ab:	ff 75 dc             	pushl  -0x24(%ebp)
  8011ae:	ff 75 d8             	pushl  -0x28(%ebp)
  8011b1:	e8 7a 0b 00 00       	call   801d30 <__umoddi3>
  8011b6:	83 c4 14             	add    $0x14,%esp
  8011b9:	0f be 80 a7 1f 80 00 	movsbl 0x801fa7(%eax),%eax
  8011c0:	50                   	push   %eax
  8011c1:	ff d7                	call   *%edi
}
  8011c3:	83 c4 10             	add    $0x10,%esp
  8011c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011c9:	5b                   	pop    %ebx
  8011ca:	5e                   	pop    %esi
  8011cb:	5f                   	pop    %edi
  8011cc:	5d                   	pop    %ebp
  8011cd:	c3                   	ret    
  8011ce:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8011d1:	eb c4                	jmp    801197 <printnum+0x73>

008011d3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011d3:	55                   	push   %ebp
  8011d4:	89 e5                	mov    %esp,%ebp
  8011d6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011d9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011dd:	8b 10                	mov    (%eax),%edx
  8011df:	3b 50 04             	cmp    0x4(%eax),%edx
  8011e2:	73 0a                	jae    8011ee <sprintputch+0x1b>
		*b->buf++ = ch;
  8011e4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011e7:	89 08                	mov    %ecx,(%eax)
  8011e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ec:	88 02                	mov    %al,(%edx)
}
  8011ee:	5d                   	pop    %ebp
  8011ef:	c3                   	ret    

008011f0 <printfmt>:
{
  8011f0:	55                   	push   %ebp
  8011f1:	89 e5                	mov    %esp,%ebp
  8011f3:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8011f6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011f9:	50                   	push   %eax
  8011fa:	ff 75 10             	pushl  0x10(%ebp)
  8011fd:	ff 75 0c             	pushl  0xc(%ebp)
  801200:	ff 75 08             	pushl  0x8(%ebp)
  801203:	e8 05 00 00 00       	call   80120d <vprintfmt>
}
  801208:	83 c4 10             	add    $0x10,%esp
  80120b:	c9                   	leave  
  80120c:	c3                   	ret    

0080120d <vprintfmt>:
{
  80120d:	55                   	push   %ebp
  80120e:	89 e5                	mov    %esp,%ebp
  801210:	57                   	push   %edi
  801211:	56                   	push   %esi
  801212:	53                   	push   %ebx
  801213:	83 ec 2c             	sub    $0x2c,%esp
  801216:	8b 75 08             	mov    0x8(%ebp),%esi
  801219:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80121c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80121f:	e9 c1 03 00 00       	jmp    8015e5 <vprintfmt+0x3d8>
		padc = ' ';
  801224:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  801228:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  80122f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  801236:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80123d:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801242:	8d 47 01             	lea    0x1(%edi),%eax
  801245:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801248:	0f b6 17             	movzbl (%edi),%edx
  80124b:	8d 42 dd             	lea    -0x23(%edx),%eax
  80124e:	3c 55                	cmp    $0x55,%al
  801250:	0f 87 12 04 00 00    	ja     801668 <vprintfmt+0x45b>
  801256:	0f b6 c0             	movzbl %al,%eax
  801259:	ff 24 85 e0 20 80 00 	jmp    *0x8020e0(,%eax,4)
  801260:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801263:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  801267:	eb d9                	jmp    801242 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  801269:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80126c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801270:	eb d0                	jmp    801242 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  801272:	0f b6 d2             	movzbl %dl,%edx
  801275:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801278:	b8 00 00 00 00       	mov    $0x0,%eax
  80127d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801280:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801283:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801287:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80128a:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80128d:	83 f9 09             	cmp    $0x9,%ecx
  801290:	77 55                	ja     8012e7 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  801292:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801295:	eb e9                	jmp    801280 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  801297:	8b 45 14             	mov    0x14(%ebp),%eax
  80129a:	8b 00                	mov    (%eax),%eax
  80129c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80129f:	8b 45 14             	mov    0x14(%ebp),%eax
  8012a2:	8d 40 04             	lea    0x4(%eax),%eax
  8012a5:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8012a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8012ab:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8012af:	79 91                	jns    801242 <vprintfmt+0x35>
				width = precision, precision = -1;
  8012b1:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8012b4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8012b7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012be:	eb 82                	jmp    801242 <vprintfmt+0x35>
  8012c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012c3:	85 c0                	test   %eax,%eax
  8012c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8012ca:	0f 49 d0             	cmovns %eax,%edx
  8012cd:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8012d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012d3:	e9 6a ff ff ff       	jmp    801242 <vprintfmt+0x35>
  8012d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8012db:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012e2:	e9 5b ff ff ff       	jmp    801242 <vprintfmt+0x35>
  8012e7:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8012ea:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012ed:	eb bc                	jmp    8012ab <vprintfmt+0x9e>
			lflag++;
  8012ef:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8012f5:	e9 48 ff ff ff       	jmp    801242 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8012fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8012fd:	8d 78 04             	lea    0x4(%eax),%edi
  801300:	83 ec 08             	sub    $0x8,%esp
  801303:	53                   	push   %ebx
  801304:	ff 30                	pushl  (%eax)
  801306:	ff d6                	call   *%esi
			break;
  801308:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80130b:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80130e:	e9 cf 02 00 00       	jmp    8015e2 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  801313:	8b 45 14             	mov    0x14(%ebp),%eax
  801316:	8d 78 04             	lea    0x4(%eax),%edi
  801319:	8b 00                	mov    (%eax),%eax
  80131b:	99                   	cltd   
  80131c:	31 d0                	xor    %edx,%eax
  80131e:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801320:	83 f8 0f             	cmp    $0xf,%eax
  801323:	7f 23                	jg     801348 <vprintfmt+0x13b>
  801325:	8b 14 85 40 22 80 00 	mov    0x802240(,%eax,4),%edx
  80132c:	85 d2                	test   %edx,%edx
  80132e:	74 18                	je     801348 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  801330:	52                   	push   %edx
  801331:	68 3d 1f 80 00       	push   $0x801f3d
  801336:	53                   	push   %ebx
  801337:	56                   	push   %esi
  801338:	e8 b3 fe ff ff       	call   8011f0 <printfmt>
  80133d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801340:	89 7d 14             	mov    %edi,0x14(%ebp)
  801343:	e9 9a 02 00 00       	jmp    8015e2 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  801348:	50                   	push   %eax
  801349:	68 bf 1f 80 00       	push   $0x801fbf
  80134e:	53                   	push   %ebx
  80134f:	56                   	push   %esi
  801350:	e8 9b fe ff ff       	call   8011f0 <printfmt>
  801355:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801358:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80135b:	e9 82 02 00 00       	jmp    8015e2 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  801360:	8b 45 14             	mov    0x14(%ebp),%eax
  801363:	83 c0 04             	add    $0x4,%eax
  801366:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801369:	8b 45 14             	mov    0x14(%ebp),%eax
  80136c:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80136e:	85 ff                	test   %edi,%edi
  801370:	b8 b8 1f 80 00       	mov    $0x801fb8,%eax
  801375:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801378:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80137c:	0f 8e bd 00 00 00    	jle    80143f <vprintfmt+0x232>
  801382:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801386:	75 0e                	jne    801396 <vprintfmt+0x189>
  801388:	89 75 08             	mov    %esi,0x8(%ebp)
  80138b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80138e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801391:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801394:	eb 6d                	jmp    801403 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  801396:	83 ec 08             	sub    $0x8,%esp
  801399:	ff 75 d0             	pushl  -0x30(%ebp)
  80139c:	57                   	push   %edi
  80139d:	e8 6e 03 00 00       	call   801710 <strnlen>
  8013a2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013a5:	29 c1                	sub    %eax,%ecx
  8013a7:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8013aa:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013ad:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8013b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013b4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8013b7:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8013b9:	eb 0f                	jmp    8013ca <vprintfmt+0x1bd>
					putch(padc, putdat);
  8013bb:	83 ec 08             	sub    $0x8,%esp
  8013be:	53                   	push   %ebx
  8013bf:	ff 75 e0             	pushl  -0x20(%ebp)
  8013c2:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8013c4:	83 ef 01             	sub    $0x1,%edi
  8013c7:	83 c4 10             	add    $0x10,%esp
  8013ca:	85 ff                	test   %edi,%edi
  8013cc:	7f ed                	jg     8013bb <vprintfmt+0x1ae>
  8013ce:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8013d1:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8013d4:	85 c9                	test   %ecx,%ecx
  8013d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8013db:	0f 49 c1             	cmovns %ecx,%eax
  8013de:	29 c1                	sub    %eax,%ecx
  8013e0:	89 75 08             	mov    %esi,0x8(%ebp)
  8013e3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8013e6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8013e9:	89 cb                	mov    %ecx,%ebx
  8013eb:	eb 16                	jmp    801403 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8013ed:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8013f1:	75 31                	jne    801424 <vprintfmt+0x217>
					putch(ch, putdat);
  8013f3:	83 ec 08             	sub    $0x8,%esp
  8013f6:	ff 75 0c             	pushl  0xc(%ebp)
  8013f9:	50                   	push   %eax
  8013fa:	ff 55 08             	call   *0x8(%ebp)
  8013fd:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801400:	83 eb 01             	sub    $0x1,%ebx
  801403:	83 c7 01             	add    $0x1,%edi
  801406:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  80140a:	0f be c2             	movsbl %dl,%eax
  80140d:	85 c0                	test   %eax,%eax
  80140f:	74 59                	je     80146a <vprintfmt+0x25d>
  801411:	85 f6                	test   %esi,%esi
  801413:	78 d8                	js     8013ed <vprintfmt+0x1e0>
  801415:	83 ee 01             	sub    $0x1,%esi
  801418:	79 d3                	jns    8013ed <vprintfmt+0x1e0>
  80141a:	89 df                	mov    %ebx,%edi
  80141c:	8b 75 08             	mov    0x8(%ebp),%esi
  80141f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801422:	eb 37                	jmp    80145b <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  801424:	0f be d2             	movsbl %dl,%edx
  801427:	83 ea 20             	sub    $0x20,%edx
  80142a:	83 fa 5e             	cmp    $0x5e,%edx
  80142d:	76 c4                	jbe    8013f3 <vprintfmt+0x1e6>
					putch('?', putdat);
  80142f:	83 ec 08             	sub    $0x8,%esp
  801432:	ff 75 0c             	pushl  0xc(%ebp)
  801435:	6a 3f                	push   $0x3f
  801437:	ff 55 08             	call   *0x8(%ebp)
  80143a:	83 c4 10             	add    $0x10,%esp
  80143d:	eb c1                	jmp    801400 <vprintfmt+0x1f3>
  80143f:	89 75 08             	mov    %esi,0x8(%ebp)
  801442:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801445:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801448:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80144b:	eb b6                	jmp    801403 <vprintfmt+0x1f6>
				putch(' ', putdat);
  80144d:	83 ec 08             	sub    $0x8,%esp
  801450:	53                   	push   %ebx
  801451:	6a 20                	push   $0x20
  801453:	ff d6                	call   *%esi
			for (; width > 0; width--)
  801455:	83 ef 01             	sub    $0x1,%edi
  801458:	83 c4 10             	add    $0x10,%esp
  80145b:	85 ff                	test   %edi,%edi
  80145d:	7f ee                	jg     80144d <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  80145f:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801462:	89 45 14             	mov    %eax,0x14(%ebp)
  801465:	e9 78 01 00 00       	jmp    8015e2 <vprintfmt+0x3d5>
  80146a:	89 df                	mov    %ebx,%edi
  80146c:	8b 75 08             	mov    0x8(%ebp),%esi
  80146f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801472:	eb e7                	jmp    80145b <vprintfmt+0x24e>
	if (lflag >= 2)
  801474:	83 f9 01             	cmp    $0x1,%ecx
  801477:	7e 3f                	jle    8014b8 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  801479:	8b 45 14             	mov    0x14(%ebp),%eax
  80147c:	8b 50 04             	mov    0x4(%eax),%edx
  80147f:	8b 00                	mov    (%eax),%eax
  801481:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801484:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801487:	8b 45 14             	mov    0x14(%ebp),%eax
  80148a:	8d 40 08             	lea    0x8(%eax),%eax
  80148d:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  801490:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801494:	79 5c                	jns    8014f2 <vprintfmt+0x2e5>
				putch('-', putdat);
  801496:	83 ec 08             	sub    $0x8,%esp
  801499:	53                   	push   %ebx
  80149a:	6a 2d                	push   $0x2d
  80149c:	ff d6                	call   *%esi
				num = -(long long) num;
  80149e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014a1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8014a4:	f7 da                	neg    %edx
  8014a6:	83 d1 00             	adc    $0x0,%ecx
  8014a9:	f7 d9                	neg    %ecx
  8014ab:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8014ae:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014b3:	e9 10 01 00 00       	jmp    8015c8 <vprintfmt+0x3bb>
	else if (lflag)
  8014b8:	85 c9                	test   %ecx,%ecx
  8014ba:	75 1b                	jne    8014d7 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8014bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8014bf:	8b 00                	mov    (%eax),%eax
  8014c1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014c4:	89 c1                	mov    %eax,%ecx
  8014c6:	c1 f9 1f             	sar    $0x1f,%ecx
  8014c9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8014cf:	8d 40 04             	lea    0x4(%eax),%eax
  8014d2:	89 45 14             	mov    %eax,0x14(%ebp)
  8014d5:	eb b9                	jmp    801490 <vprintfmt+0x283>
		return va_arg(*ap, long);
  8014d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8014da:	8b 00                	mov    (%eax),%eax
  8014dc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014df:	89 c1                	mov    %eax,%ecx
  8014e1:	c1 f9 1f             	sar    $0x1f,%ecx
  8014e4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ea:	8d 40 04             	lea    0x4(%eax),%eax
  8014ed:	89 45 14             	mov    %eax,0x14(%ebp)
  8014f0:	eb 9e                	jmp    801490 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8014f2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014f5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8014f8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014fd:	e9 c6 00 00 00       	jmp    8015c8 <vprintfmt+0x3bb>
	if (lflag >= 2)
  801502:	83 f9 01             	cmp    $0x1,%ecx
  801505:	7e 18                	jle    80151f <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  801507:	8b 45 14             	mov    0x14(%ebp),%eax
  80150a:	8b 10                	mov    (%eax),%edx
  80150c:	8b 48 04             	mov    0x4(%eax),%ecx
  80150f:	8d 40 08             	lea    0x8(%eax),%eax
  801512:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801515:	b8 0a 00 00 00       	mov    $0xa,%eax
  80151a:	e9 a9 00 00 00       	jmp    8015c8 <vprintfmt+0x3bb>
	else if (lflag)
  80151f:	85 c9                	test   %ecx,%ecx
  801521:	75 1a                	jne    80153d <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  801523:	8b 45 14             	mov    0x14(%ebp),%eax
  801526:	8b 10                	mov    (%eax),%edx
  801528:	b9 00 00 00 00       	mov    $0x0,%ecx
  80152d:	8d 40 04             	lea    0x4(%eax),%eax
  801530:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801533:	b8 0a 00 00 00       	mov    $0xa,%eax
  801538:	e9 8b 00 00 00       	jmp    8015c8 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80153d:	8b 45 14             	mov    0x14(%ebp),%eax
  801540:	8b 10                	mov    (%eax),%edx
  801542:	b9 00 00 00 00       	mov    $0x0,%ecx
  801547:	8d 40 04             	lea    0x4(%eax),%eax
  80154a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80154d:	b8 0a 00 00 00       	mov    $0xa,%eax
  801552:	eb 74                	jmp    8015c8 <vprintfmt+0x3bb>
	if (lflag >= 2)
  801554:	83 f9 01             	cmp    $0x1,%ecx
  801557:	7e 15                	jle    80156e <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  801559:	8b 45 14             	mov    0x14(%ebp),%eax
  80155c:	8b 10                	mov    (%eax),%edx
  80155e:	8b 48 04             	mov    0x4(%eax),%ecx
  801561:	8d 40 08             	lea    0x8(%eax),%eax
  801564:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801567:	b8 08 00 00 00       	mov    $0x8,%eax
  80156c:	eb 5a                	jmp    8015c8 <vprintfmt+0x3bb>
	else if (lflag)
  80156e:	85 c9                	test   %ecx,%ecx
  801570:	75 17                	jne    801589 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  801572:	8b 45 14             	mov    0x14(%ebp),%eax
  801575:	8b 10                	mov    (%eax),%edx
  801577:	b9 00 00 00 00       	mov    $0x0,%ecx
  80157c:	8d 40 04             	lea    0x4(%eax),%eax
  80157f:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801582:	b8 08 00 00 00       	mov    $0x8,%eax
  801587:	eb 3f                	jmp    8015c8 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  801589:	8b 45 14             	mov    0x14(%ebp),%eax
  80158c:	8b 10                	mov    (%eax),%edx
  80158e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801593:	8d 40 04             	lea    0x4(%eax),%eax
  801596:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801599:	b8 08 00 00 00       	mov    $0x8,%eax
  80159e:	eb 28                	jmp    8015c8 <vprintfmt+0x3bb>
			putch('0', putdat);
  8015a0:	83 ec 08             	sub    $0x8,%esp
  8015a3:	53                   	push   %ebx
  8015a4:	6a 30                	push   $0x30
  8015a6:	ff d6                	call   *%esi
			putch('x', putdat);
  8015a8:	83 c4 08             	add    $0x8,%esp
  8015ab:	53                   	push   %ebx
  8015ac:	6a 78                	push   $0x78
  8015ae:	ff d6                	call   *%esi
			num = (unsigned long long)
  8015b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8015b3:	8b 10                	mov    (%eax),%edx
  8015b5:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8015ba:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8015bd:	8d 40 04             	lea    0x4(%eax),%eax
  8015c0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015c3:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8015c8:	83 ec 0c             	sub    $0xc,%esp
  8015cb:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015cf:	57                   	push   %edi
  8015d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8015d3:	50                   	push   %eax
  8015d4:	51                   	push   %ecx
  8015d5:	52                   	push   %edx
  8015d6:	89 da                	mov    %ebx,%edx
  8015d8:	89 f0                	mov    %esi,%eax
  8015da:	e8 45 fb ff ff       	call   801124 <printnum>
			break;
  8015df:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8015e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8015e5:	83 c7 01             	add    $0x1,%edi
  8015e8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8015ec:	83 f8 25             	cmp    $0x25,%eax
  8015ef:	0f 84 2f fc ff ff    	je     801224 <vprintfmt+0x17>
			if (ch == '\0')
  8015f5:	85 c0                	test   %eax,%eax
  8015f7:	0f 84 8b 00 00 00    	je     801688 <vprintfmt+0x47b>
			putch(ch, putdat);
  8015fd:	83 ec 08             	sub    $0x8,%esp
  801600:	53                   	push   %ebx
  801601:	50                   	push   %eax
  801602:	ff d6                	call   *%esi
  801604:	83 c4 10             	add    $0x10,%esp
  801607:	eb dc                	jmp    8015e5 <vprintfmt+0x3d8>
	if (lflag >= 2)
  801609:	83 f9 01             	cmp    $0x1,%ecx
  80160c:	7e 15                	jle    801623 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  80160e:	8b 45 14             	mov    0x14(%ebp),%eax
  801611:	8b 10                	mov    (%eax),%edx
  801613:	8b 48 04             	mov    0x4(%eax),%ecx
  801616:	8d 40 08             	lea    0x8(%eax),%eax
  801619:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80161c:	b8 10 00 00 00       	mov    $0x10,%eax
  801621:	eb a5                	jmp    8015c8 <vprintfmt+0x3bb>
	else if (lflag)
  801623:	85 c9                	test   %ecx,%ecx
  801625:	75 17                	jne    80163e <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  801627:	8b 45 14             	mov    0x14(%ebp),%eax
  80162a:	8b 10                	mov    (%eax),%edx
  80162c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801631:	8d 40 04             	lea    0x4(%eax),%eax
  801634:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801637:	b8 10 00 00 00       	mov    $0x10,%eax
  80163c:	eb 8a                	jmp    8015c8 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80163e:	8b 45 14             	mov    0x14(%ebp),%eax
  801641:	8b 10                	mov    (%eax),%edx
  801643:	b9 00 00 00 00       	mov    $0x0,%ecx
  801648:	8d 40 04             	lea    0x4(%eax),%eax
  80164b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80164e:	b8 10 00 00 00       	mov    $0x10,%eax
  801653:	e9 70 ff ff ff       	jmp    8015c8 <vprintfmt+0x3bb>
			putch(ch, putdat);
  801658:	83 ec 08             	sub    $0x8,%esp
  80165b:	53                   	push   %ebx
  80165c:	6a 25                	push   $0x25
  80165e:	ff d6                	call   *%esi
			break;
  801660:	83 c4 10             	add    $0x10,%esp
  801663:	e9 7a ff ff ff       	jmp    8015e2 <vprintfmt+0x3d5>
			putch('%', putdat);
  801668:	83 ec 08             	sub    $0x8,%esp
  80166b:	53                   	push   %ebx
  80166c:	6a 25                	push   $0x25
  80166e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801670:	83 c4 10             	add    $0x10,%esp
  801673:	89 f8                	mov    %edi,%eax
  801675:	eb 03                	jmp    80167a <vprintfmt+0x46d>
  801677:	83 e8 01             	sub    $0x1,%eax
  80167a:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80167e:	75 f7                	jne    801677 <vprintfmt+0x46a>
  801680:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801683:	e9 5a ff ff ff       	jmp    8015e2 <vprintfmt+0x3d5>
}
  801688:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80168b:	5b                   	pop    %ebx
  80168c:	5e                   	pop    %esi
  80168d:	5f                   	pop    %edi
  80168e:	5d                   	pop    %ebp
  80168f:	c3                   	ret    

00801690 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801690:	55                   	push   %ebp
  801691:	89 e5                	mov    %esp,%ebp
  801693:	83 ec 18             	sub    $0x18,%esp
  801696:	8b 45 08             	mov    0x8(%ebp),%eax
  801699:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80169c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80169f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8016a3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8016a6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8016ad:	85 c0                	test   %eax,%eax
  8016af:	74 26                	je     8016d7 <vsnprintf+0x47>
  8016b1:	85 d2                	test   %edx,%edx
  8016b3:	7e 22                	jle    8016d7 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8016b5:	ff 75 14             	pushl  0x14(%ebp)
  8016b8:	ff 75 10             	pushl  0x10(%ebp)
  8016bb:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8016be:	50                   	push   %eax
  8016bf:	68 d3 11 80 00       	push   $0x8011d3
  8016c4:	e8 44 fb ff ff       	call   80120d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8016c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016cc:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8016cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016d2:	83 c4 10             	add    $0x10,%esp
}
  8016d5:	c9                   	leave  
  8016d6:	c3                   	ret    
		return -E_INVAL;
  8016d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016dc:	eb f7                	jmp    8016d5 <vsnprintf+0x45>

008016de <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016de:	55                   	push   %ebp
  8016df:	89 e5                	mov    %esp,%ebp
  8016e1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016e4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016e7:	50                   	push   %eax
  8016e8:	ff 75 10             	pushl  0x10(%ebp)
  8016eb:	ff 75 0c             	pushl  0xc(%ebp)
  8016ee:	ff 75 08             	pushl  0x8(%ebp)
  8016f1:	e8 9a ff ff ff       	call   801690 <vsnprintf>
	va_end(ap);

	return rc;
}
  8016f6:	c9                   	leave  
  8016f7:	c3                   	ret    

008016f8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016f8:	55                   	push   %ebp
  8016f9:	89 e5                	mov    %esp,%ebp
  8016fb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016fe:	b8 00 00 00 00       	mov    $0x0,%eax
  801703:	eb 03                	jmp    801708 <strlen+0x10>
		n++;
  801705:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  801708:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80170c:	75 f7                	jne    801705 <strlen+0xd>
	return n;
}
  80170e:	5d                   	pop    %ebp
  80170f:	c3                   	ret    

00801710 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801710:	55                   	push   %ebp
  801711:	89 e5                	mov    %esp,%ebp
  801713:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801716:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801719:	b8 00 00 00 00       	mov    $0x0,%eax
  80171e:	eb 03                	jmp    801723 <strnlen+0x13>
		n++;
  801720:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801723:	39 d0                	cmp    %edx,%eax
  801725:	74 06                	je     80172d <strnlen+0x1d>
  801727:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80172b:	75 f3                	jne    801720 <strnlen+0x10>
	return n;
}
  80172d:	5d                   	pop    %ebp
  80172e:	c3                   	ret    

0080172f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80172f:	55                   	push   %ebp
  801730:	89 e5                	mov    %esp,%ebp
  801732:	53                   	push   %ebx
  801733:	8b 45 08             	mov    0x8(%ebp),%eax
  801736:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801739:	89 c2                	mov    %eax,%edx
  80173b:	83 c1 01             	add    $0x1,%ecx
  80173e:	83 c2 01             	add    $0x1,%edx
  801741:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801745:	88 5a ff             	mov    %bl,-0x1(%edx)
  801748:	84 db                	test   %bl,%bl
  80174a:	75 ef                	jne    80173b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80174c:	5b                   	pop    %ebx
  80174d:	5d                   	pop    %ebp
  80174e:	c3                   	ret    

0080174f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80174f:	55                   	push   %ebp
  801750:	89 e5                	mov    %esp,%ebp
  801752:	53                   	push   %ebx
  801753:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801756:	53                   	push   %ebx
  801757:	e8 9c ff ff ff       	call   8016f8 <strlen>
  80175c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80175f:	ff 75 0c             	pushl  0xc(%ebp)
  801762:	01 d8                	add    %ebx,%eax
  801764:	50                   	push   %eax
  801765:	e8 c5 ff ff ff       	call   80172f <strcpy>
	return dst;
}
  80176a:	89 d8                	mov    %ebx,%eax
  80176c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80176f:	c9                   	leave  
  801770:	c3                   	ret    

00801771 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801771:	55                   	push   %ebp
  801772:	89 e5                	mov    %esp,%ebp
  801774:	56                   	push   %esi
  801775:	53                   	push   %ebx
  801776:	8b 75 08             	mov    0x8(%ebp),%esi
  801779:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80177c:	89 f3                	mov    %esi,%ebx
  80177e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801781:	89 f2                	mov    %esi,%edx
  801783:	eb 0f                	jmp    801794 <strncpy+0x23>
		*dst++ = *src;
  801785:	83 c2 01             	add    $0x1,%edx
  801788:	0f b6 01             	movzbl (%ecx),%eax
  80178b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80178e:	80 39 01             	cmpb   $0x1,(%ecx)
  801791:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  801794:	39 da                	cmp    %ebx,%edx
  801796:	75 ed                	jne    801785 <strncpy+0x14>
	}
	return ret;
}
  801798:	89 f0                	mov    %esi,%eax
  80179a:	5b                   	pop    %ebx
  80179b:	5e                   	pop    %esi
  80179c:	5d                   	pop    %ebp
  80179d:	c3                   	ret    

0080179e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80179e:	55                   	push   %ebp
  80179f:	89 e5                	mov    %esp,%ebp
  8017a1:	56                   	push   %esi
  8017a2:	53                   	push   %ebx
  8017a3:	8b 75 08             	mov    0x8(%ebp),%esi
  8017a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017a9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8017ac:	89 f0                	mov    %esi,%eax
  8017ae:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8017b2:	85 c9                	test   %ecx,%ecx
  8017b4:	75 0b                	jne    8017c1 <strlcpy+0x23>
  8017b6:	eb 17                	jmp    8017cf <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8017b8:	83 c2 01             	add    $0x1,%edx
  8017bb:	83 c0 01             	add    $0x1,%eax
  8017be:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8017c1:	39 d8                	cmp    %ebx,%eax
  8017c3:	74 07                	je     8017cc <strlcpy+0x2e>
  8017c5:	0f b6 0a             	movzbl (%edx),%ecx
  8017c8:	84 c9                	test   %cl,%cl
  8017ca:	75 ec                	jne    8017b8 <strlcpy+0x1a>
		*dst = '\0';
  8017cc:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8017cf:	29 f0                	sub    %esi,%eax
}
  8017d1:	5b                   	pop    %ebx
  8017d2:	5e                   	pop    %esi
  8017d3:	5d                   	pop    %ebp
  8017d4:	c3                   	ret    

008017d5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017d5:	55                   	push   %ebp
  8017d6:	89 e5                	mov    %esp,%ebp
  8017d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017db:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017de:	eb 06                	jmp    8017e6 <strcmp+0x11>
		p++, q++;
  8017e0:	83 c1 01             	add    $0x1,%ecx
  8017e3:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8017e6:	0f b6 01             	movzbl (%ecx),%eax
  8017e9:	84 c0                	test   %al,%al
  8017eb:	74 04                	je     8017f1 <strcmp+0x1c>
  8017ed:	3a 02                	cmp    (%edx),%al
  8017ef:	74 ef                	je     8017e0 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017f1:	0f b6 c0             	movzbl %al,%eax
  8017f4:	0f b6 12             	movzbl (%edx),%edx
  8017f7:	29 d0                	sub    %edx,%eax
}
  8017f9:	5d                   	pop    %ebp
  8017fa:	c3                   	ret    

008017fb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017fb:	55                   	push   %ebp
  8017fc:	89 e5                	mov    %esp,%ebp
  8017fe:	53                   	push   %ebx
  8017ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801802:	8b 55 0c             	mov    0xc(%ebp),%edx
  801805:	89 c3                	mov    %eax,%ebx
  801807:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80180a:	eb 06                	jmp    801812 <strncmp+0x17>
		n--, p++, q++;
  80180c:	83 c0 01             	add    $0x1,%eax
  80180f:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  801812:	39 d8                	cmp    %ebx,%eax
  801814:	74 16                	je     80182c <strncmp+0x31>
  801816:	0f b6 08             	movzbl (%eax),%ecx
  801819:	84 c9                	test   %cl,%cl
  80181b:	74 04                	je     801821 <strncmp+0x26>
  80181d:	3a 0a                	cmp    (%edx),%cl
  80181f:	74 eb                	je     80180c <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801821:	0f b6 00             	movzbl (%eax),%eax
  801824:	0f b6 12             	movzbl (%edx),%edx
  801827:	29 d0                	sub    %edx,%eax
}
  801829:	5b                   	pop    %ebx
  80182a:	5d                   	pop    %ebp
  80182b:	c3                   	ret    
		return 0;
  80182c:	b8 00 00 00 00       	mov    $0x0,%eax
  801831:	eb f6                	jmp    801829 <strncmp+0x2e>

00801833 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801833:	55                   	push   %ebp
  801834:	89 e5                	mov    %esp,%ebp
  801836:	8b 45 08             	mov    0x8(%ebp),%eax
  801839:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80183d:	0f b6 10             	movzbl (%eax),%edx
  801840:	84 d2                	test   %dl,%dl
  801842:	74 09                	je     80184d <strchr+0x1a>
		if (*s == c)
  801844:	38 ca                	cmp    %cl,%dl
  801846:	74 0a                	je     801852 <strchr+0x1f>
	for (; *s; s++)
  801848:	83 c0 01             	add    $0x1,%eax
  80184b:	eb f0                	jmp    80183d <strchr+0xa>
			return (char *) s;
	return 0;
  80184d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801852:	5d                   	pop    %ebp
  801853:	c3                   	ret    

00801854 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801854:	55                   	push   %ebp
  801855:	89 e5                	mov    %esp,%ebp
  801857:	8b 45 08             	mov    0x8(%ebp),%eax
  80185a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80185e:	eb 03                	jmp    801863 <strfind+0xf>
  801860:	83 c0 01             	add    $0x1,%eax
  801863:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801866:	38 ca                	cmp    %cl,%dl
  801868:	74 04                	je     80186e <strfind+0x1a>
  80186a:	84 d2                	test   %dl,%dl
  80186c:	75 f2                	jne    801860 <strfind+0xc>
			break;
	return (char *) s;
}
  80186e:	5d                   	pop    %ebp
  80186f:	c3                   	ret    

00801870 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801870:	55                   	push   %ebp
  801871:	89 e5                	mov    %esp,%ebp
  801873:	57                   	push   %edi
  801874:	56                   	push   %esi
  801875:	53                   	push   %ebx
  801876:	8b 7d 08             	mov    0x8(%ebp),%edi
  801879:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80187c:	85 c9                	test   %ecx,%ecx
  80187e:	74 13                	je     801893 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801880:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801886:	75 05                	jne    80188d <memset+0x1d>
  801888:	f6 c1 03             	test   $0x3,%cl
  80188b:	74 0d                	je     80189a <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80188d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801890:	fc                   	cld    
  801891:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801893:	89 f8                	mov    %edi,%eax
  801895:	5b                   	pop    %ebx
  801896:	5e                   	pop    %esi
  801897:	5f                   	pop    %edi
  801898:	5d                   	pop    %ebp
  801899:	c3                   	ret    
		c &= 0xFF;
  80189a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80189e:	89 d3                	mov    %edx,%ebx
  8018a0:	c1 e3 08             	shl    $0x8,%ebx
  8018a3:	89 d0                	mov    %edx,%eax
  8018a5:	c1 e0 18             	shl    $0x18,%eax
  8018a8:	89 d6                	mov    %edx,%esi
  8018aa:	c1 e6 10             	shl    $0x10,%esi
  8018ad:	09 f0                	or     %esi,%eax
  8018af:	09 c2                	or     %eax,%edx
  8018b1:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  8018b3:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8018b6:	89 d0                	mov    %edx,%eax
  8018b8:	fc                   	cld    
  8018b9:	f3 ab                	rep stos %eax,%es:(%edi)
  8018bb:	eb d6                	jmp    801893 <memset+0x23>

008018bd <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8018bd:	55                   	push   %ebp
  8018be:	89 e5                	mov    %esp,%ebp
  8018c0:	57                   	push   %edi
  8018c1:	56                   	push   %esi
  8018c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018c8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018cb:	39 c6                	cmp    %eax,%esi
  8018cd:	73 35                	jae    801904 <memmove+0x47>
  8018cf:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018d2:	39 c2                	cmp    %eax,%edx
  8018d4:	76 2e                	jbe    801904 <memmove+0x47>
		s += n;
		d += n;
  8018d6:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018d9:	89 d6                	mov    %edx,%esi
  8018db:	09 fe                	or     %edi,%esi
  8018dd:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018e3:	74 0c                	je     8018f1 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8018e5:	83 ef 01             	sub    $0x1,%edi
  8018e8:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8018eb:	fd                   	std    
  8018ec:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018ee:	fc                   	cld    
  8018ef:	eb 21                	jmp    801912 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018f1:	f6 c1 03             	test   $0x3,%cl
  8018f4:	75 ef                	jne    8018e5 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8018f6:	83 ef 04             	sub    $0x4,%edi
  8018f9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018fc:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8018ff:	fd                   	std    
  801900:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801902:	eb ea                	jmp    8018ee <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801904:	89 f2                	mov    %esi,%edx
  801906:	09 c2                	or     %eax,%edx
  801908:	f6 c2 03             	test   $0x3,%dl
  80190b:	74 09                	je     801916 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80190d:	89 c7                	mov    %eax,%edi
  80190f:	fc                   	cld    
  801910:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801912:	5e                   	pop    %esi
  801913:	5f                   	pop    %edi
  801914:	5d                   	pop    %ebp
  801915:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801916:	f6 c1 03             	test   $0x3,%cl
  801919:	75 f2                	jne    80190d <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80191b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80191e:	89 c7                	mov    %eax,%edi
  801920:	fc                   	cld    
  801921:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801923:	eb ed                	jmp    801912 <memmove+0x55>

00801925 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801925:	55                   	push   %ebp
  801926:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801928:	ff 75 10             	pushl  0x10(%ebp)
  80192b:	ff 75 0c             	pushl  0xc(%ebp)
  80192e:	ff 75 08             	pushl  0x8(%ebp)
  801931:	e8 87 ff ff ff       	call   8018bd <memmove>
}
  801936:	c9                   	leave  
  801937:	c3                   	ret    

00801938 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801938:	55                   	push   %ebp
  801939:	89 e5                	mov    %esp,%ebp
  80193b:	56                   	push   %esi
  80193c:	53                   	push   %ebx
  80193d:	8b 45 08             	mov    0x8(%ebp),%eax
  801940:	8b 55 0c             	mov    0xc(%ebp),%edx
  801943:	89 c6                	mov    %eax,%esi
  801945:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801948:	39 f0                	cmp    %esi,%eax
  80194a:	74 1c                	je     801968 <memcmp+0x30>
		if (*s1 != *s2)
  80194c:	0f b6 08             	movzbl (%eax),%ecx
  80194f:	0f b6 1a             	movzbl (%edx),%ebx
  801952:	38 d9                	cmp    %bl,%cl
  801954:	75 08                	jne    80195e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801956:	83 c0 01             	add    $0x1,%eax
  801959:	83 c2 01             	add    $0x1,%edx
  80195c:	eb ea                	jmp    801948 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  80195e:	0f b6 c1             	movzbl %cl,%eax
  801961:	0f b6 db             	movzbl %bl,%ebx
  801964:	29 d8                	sub    %ebx,%eax
  801966:	eb 05                	jmp    80196d <memcmp+0x35>
	}

	return 0;
  801968:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80196d:	5b                   	pop    %ebx
  80196e:	5e                   	pop    %esi
  80196f:	5d                   	pop    %ebp
  801970:	c3                   	ret    

00801971 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801971:	55                   	push   %ebp
  801972:	89 e5                	mov    %esp,%ebp
  801974:	8b 45 08             	mov    0x8(%ebp),%eax
  801977:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80197a:	89 c2                	mov    %eax,%edx
  80197c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80197f:	39 d0                	cmp    %edx,%eax
  801981:	73 09                	jae    80198c <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  801983:	38 08                	cmp    %cl,(%eax)
  801985:	74 05                	je     80198c <memfind+0x1b>
	for (; s < ends; s++)
  801987:	83 c0 01             	add    $0x1,%eax
  80198a:	eb f3                	jmp    80197f <memfind+0xe>
			break;
	return (void *) s;
}
  80198c:	5d                   	pop    %ebp
  80198d:	c3                   	ret    

0080198e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80198e:	55                   	push   %ebp
  80198f:	89 e5                	mov    %esp,%ebp
  801991:	57                   	push   %edi
  801992:	56                   	push   %esi
  801993:	53                   	push   %ebx
  801994:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801997:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80199a:	eb 03                	jmp    80199f <strtol+0x11>
		s++;
  80199c:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  80199f:	0f b6 01             	movzbl (%ecx),%eax
  8019a2:	3c 20                	cmp    $0x20,%al
  8019a4:	74 f6                	je     80199c <strtol+0xe>
  8019a6:	3c 09                	cmp    $0x9,%al
  8019a8:	74 f2                	je     80199c <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8019aa:	3c 2b                	cmp    $0x2b,%al
  8019ac:	74 2e                	je     8019dc <strtol+0x4e>
	int neg = 0;
  8019ae:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8019b3:	3c 2d                	cmp    $0x2d,%al
  8019b5:	74 2f                	je     8019e6 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019b7:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8019bd:	75 05                	jne    8019c4 <strtol+0x36>
  8019bf:	80 39 30             	cmpb   $0x30,(%ecx)
  8019c2:	74 2c                	je     8019f0 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019c4:	85 db                	test   %ebx,%ebx
  8019c6:	75 0a                	jne    8019d2 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019c8:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  8019cd:	80 39 30             	cmpb   $0x30,(%ecx)
  8019d0:	74 28                	je     8019fa <strtol+0x6c>
		base = 10;
  8019d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8019d7:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8019da:	eb 50                	jmp    801a2c <strtol+0x9e>
		s++;
  8019dc:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  8019df:	bf 00 00 00 00       	mov    $0x0,%edi
  8019e4:	eb d1                	jmp    8019b7 <strtol+0x29>
		s++, neg = 1;
  8019e6:	83 c1 01             	add    $0x1,%ecx
  8019e9:	bf 01 00 00 00       	mov    $0x1,%edi
  8019ee:	eb c7                	jmp    8019b7 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019f0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019f4:	74 0e                	je     801a04 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8019f6:	85 db                	test   %ebx,%ebx
  8019f8:	75 d8                	jne    8019d2 <strtol+0x44>
		s++, base = 8;
  8019fa:	83 c1 01             	add    $0x1,%ecx
  8019fd:	bb 08 00 00 00       	mov    $0x8,%ebx
  801a02:	eb ce                	jmp    8019d2 <strtol+0x44>
		s += 2, base = 16;
  801a04:	83 c1 02             	add    $0x2,%ecx
  801a07:	bb 10 00 00 00       	mov    $0x10,%ebx
  801a0c:	eb c4                	jmp    8019d2 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  801a0e:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a11:	89 f3                	mov    %esi,%ebx
  801a13:	80 fb 19             	cmp    $0x19,%bl
  801a16:	77 29                	ja     801a41 <strtol+0xb3>
			dig = *s - 'a' + 10;
  801a18:	0f be d2             	movsbl %dl,%edx
  801a1b:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801a1e:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a21:	7d 30                	jge    801a53 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801a23:	83 c1 01             	add    $0x1,%ecx
  801a26:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a2a:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801a2c:	0f b6 11             	movzbl (%ecx),%edx
  801a2f:	8d 72 d0             	lea    -0x30(%edx),%esi
  801a32:	89 f3                	mov    %esi,%ebx
  801a34:	80 fb 09             	cmp    $0x9,%bl
  801a37:	77 d5                	ja     801a0e <strtol+0x80>
			dig = *s - '0';
  801a39:	0f be d2             	movsbl %dl,%edx
  801a3c:	83 ea 30             	sub    $0x30,%edx
  801a3f:	eb dd                	jmp    801a1e <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  801a41:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a44:	89 f3                	mov    %esi,%ebx
  801a46:	80 fb 19             	cmp    $0x19,%bl
  801a49:	77 08                	ja     801a53 <strtol+0xc5>
			dig = *s - 'A' + 10;
  801a4b:	0f be d2             	movsbl %dl,%edx
  801a4e:	83 ea 37             	sub    $0x37,%edx
  801a51:	eb cb                	jmp    801a1e <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  801a53:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a57:	74 05                	je     801a5e <strtol+0xd0>
		*endptr = (char *) s;
  801a59:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a5c:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801a5e:	89 c2                	mov    %eax,%edx
  801a60:	f7 da                	neg    %edx
  801a62:	85 ff                	test   %edi,%edi
  801a64:	0f 45 c2             	cmovne %edx,%eax
}
  801a67:	5b                   	pop    %ebx
  801a68:	5e                   	pop    %esi
  801a69:	5f                   	pop    %edi
  801a6a:	5d                   	pop    %ebp
  801a6b:	c3                   	ret    

00801a6c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801a6c:	55                   	push   %ebp
  801a6d:	89 e5                	mov    %esp,%ebp
  801a6f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801a72:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801a79:	74 20                	je     801a9b <set_pgfault_handler+0x2f>
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
			panic("set_pgfault_handler:sys_page_alloc failed");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801a7b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a7e:	a3 00 60 80 00       	mov    %eax,0x806000
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801a83:	83 ec 08             	sub    $0x8,%esp
  801a86:	68 61 03 80 00       	push   $0x800361
  801a8b:	6a 00                	push   $0x0
  801a8d:	e8 29 e8 ff ff       	call   8002bb <sys_env_set_pgfault_upcall>
  801a92:	83 c4 10             	add    $0x10,%esp
  801a95:	85 c0                	test   %eax,%eax
  801a97:	78 2e                	js     801ac7 <set_pgfault_handler+0x5b>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
}
  801a99:	c9                   	leave  
  801a9a:	c3                   	ret    
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  801a9b:	83 ec 04             	sub    $0x4,%esp
  801a9e:	6a 07                	push   $0x7
  801aa0:	68 00 f0 bf ee       	push   $0xeebff000
  801aa5:	6a 00                	push   $0x0
  801aa7:	e8 c4 e6 ff ff       	call   800170 <sys_page_alloc>
  801aac:	83 c4 10             	add    $0x10,%esp
  801aaf:	85 c0                	test   %eax,%eax
  801ab1:	79 c8                	jns    801a7b <set_pgfault_handler+0xf>
			panic("set_pgfault_handler:sys_page_alloc failed");
  801ab3:	83 ec 04             	sub    $0x4,%esp
  801ab6:	68 a0 22 80 00       	push   $0x8022a0
  801abb:	6a 21                	push   $0x21
  801abd:	68 04 23 80 00       	push   $0x802304
  801ac2:	e8 6e f5 ff ff       	call   801035 <_panic>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  801ac7:	83 ec 04             	sub    $0x4,%esp
  801aca:	68 cc 22 80 00       	push   $0x8022cc
  801acf:	6a 27                	push   $0x27
  801ad1:	68 04 23 80 00       	push   $0x802304
  801ad6:	e8 5a f5 ff ff       	call   801035 <_panic>

00801adb <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801adb:	55                   	push   %ebp
  801adc:	89 e5                	mov    %esp,%ebp
  801ade:	56                   	push   %esi
  801adf:	53                   	push   %ebx
  801ae0:	8b 75 08             	mov    0x8(%ebp),%esi
  801ae3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ae6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  801ae9:	85 f6                	test   %esi,%esi
  801aeb:	74 06                	je     801af3 <ipc_recv+0x18>
  801aed:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801af3:	85 db                	test   %ebx,%ebx
  801af5:	74 06                	je     801afd <ipc_recv+0x22>
  801af7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801afd:	85 c0                	test   %eax,%eax
  801aff:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801b04:	0f 44 c2             	cmove  %edx,%eax
	int ret = sys_ipc_recv(pg);
  801b07:	83 ec 0c             	sub    $0xc,%esp
  801b0a:	50                   	push   %eax
  801b0b:	e8 10 e8 ff ff       	call   800320 <sys_ipc_recv>
	if (ret) return ret;
  801b10:	83 c4 10             	add    $0x10,%esp
  801b13:	85 c0                	test   %eax,%eax
  801b15:	75 24                	jne    801b3b <ipc_recv+0x60>
	if (from_env_store)
  801b17:	85 f6                	test   %esi,%esi
  801b19:	74 0a                	je     801b25 <ipc_recv+0x4a>
		*from_env_store = thisenv->env_ipc_from;
  801b1b:	a1 04 40 80 00       	mov    0x804004,%eax
  801b20:	8b 40 74             	mov    0x74(%eax),%eax
  801b23:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801b25:	85 db                	test   %ebx,%ebx
  801b27:	74 0a                	je     801b33 <ipc_recv+0x58>
		*perm_store = thisenv->env_ipc_perm;
  801b29:	a1 04 40 80 00       	mov    0x804004,%eax
  801b2e:	8b 40 78             	mov    0x78(%eax),%eax
  801b31:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801b33:	a1 04 40 80 00       	mov    0x804004,%eax
  801b38:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b3b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b3e:	5b                   	pop    %ebx
  801b3f:	5e                   	pop    %esi
  801b40:	5d                   	pop    %ebp
  801b41:	c3                   	ret    

00801b42 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b42:	55                   	push   %ebp
  801b43:	89 e5                	mov    %esp,%ebp
  801b45:	57                   	push   %edi
  801b46:	56                   	push   %esi
  801b47:	53                   	push   %ebx
  801b48:	83 ec 0c             	sub    $0xc,%esp
  801b4b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b4e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b51:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  801b54:	85 db                	test   %ebx,%ebx
  801b56:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801b5b:	0f 44 d8             	cmove  %eax,%ebx
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801b5e:	ff 75 14             	pushl  0x14(%ebp)
  801b61:	53                   	push   %ebx
  801b62:	56                   	push   %esi
  801b63:	57                   	push   %edi
  801b64:	e8 94 e7 ff ff       	call   8002fd <sys_ipc_try_send>
  801b69:	83 c4 10             	add    $0x10,%esp
  801b6c:	85 c0                	test   %eax,%eax
  801b6e:	74 1e                	je     801b8e <ipc_send+0x4c>
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801b70:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b73:	75 07                	jne    801b7c <ipc_send+0x3a>
		sys_yield();
  801b75:	e8 d7 e5 ff ff       	call   800151 <sys_yield>
  801b7a:	eb e2                	jmp    801b5e <ipc_send+0x1c>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801b7c:	50                   	push   %eax
  801b7d:	68 12 23 80 00       	push   $0x802312
  801b82:	6a 36                	push   $0x36
  801b84:	68 29 23 80 00       	push   $0x802329
  801b89:	e8 a7 f4 ff ff       	call   801035 <_panic>
	}
}
  801b8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b91:	5b                   	pop    %ebx
  801b92:	5e                   	pop    %esi
  801b93:	5f                   	pop    %edi
  801b94:	5d                   	pop    %ebp
  801b95:	c3                   	ret    

00801b96 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b96:	55                   	push   %ebp
  801b97:	89 e5                	mov    %esp,%ebp
  801b99:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b9c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ba1:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ba4:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801baa:	8b 52 50             	mov    0x50(%edx),%edx
  801bad:	39 ca                	cmp    %ecx,%edx
  801baf:	74 11                	je     801bc2 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801bb1:	83 c0 01             	add    $0x1,%eax
  801bb4:	3d 00 04 00 00       	cmp    $0x400,%eax
  801bb9:	75 e6                	jne    801ba1 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801bbb:	b8 00 00 00 00       	mov    $0x0,%eax
  801bc0:	eb 0b                	jmp    801bcd <ipc_find_env+0x37>
			return envs[i].env_id;
  801bc2:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801bc5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801bca:	8b 40 48             	mov    0x48(%eax),%eax
}
  801bcd:	5d                   	pop    %ebp
  801bce:	c3                   	ret    

00801bcf <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801bcf:	55                   	push   %ebp
  801bd0:	89 e5                	mov    %esp,%ebp
  801bd2:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bd5:	89 d0                	mov    %edx,%eax
  801bd7:	c1 e8 16             	shr    $0x16,%eax
  801bda:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801be1:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801be6:	f6 c1 01             	test   $0x1,%cl
  801be9:	74 1d                	je     801c08 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801beb:	c1 ea 0c             	shr    $0xc,%edx
  801bee:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801bf5:	f6 c2 01             	test   $0x1,%dl
  801bf8:	74 0e                	je     801c08 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bfa:	c1 ea 0c             	shr    $0xc,%edx
  801bfd:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c04:	ef 
  801c05:	0f b7 c0             	movzwl %ax,%eax
}
  801c08:	5d                   	pop    %ebp
  801c09:	c3                   	ret    
  801c0a:	66 90                	xchg   %ax,%ax
  801c0c:	66 90                	xchg   %ax,%ax
  801c0e:	66 90                	xchg   %ax,%ax

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
