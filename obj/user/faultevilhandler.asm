
obj/user/faultevilhandler.debug：     文件格式 elf32-i386


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
  80002c:	e8 34 00 00 00       	call   800065 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  800039:	6a 07                	push   $0x7
  80003b:	68 00 f0 bf ee       	push   $0xeebff000
  800040:	6a 00                	push   $0x0
  800042:	e8 3a 01 00 00       	call   800181 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xF0100020);
  800047:	83 c4 08             	add    $0x8,%esp
  80004a:	68 20 00 10 f0       	push   $0xf0100020
  80004f:	6a 00                	push   $0x0
  800051:	e8 76 02 00 00       	call   8002cc <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800056:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80005d:	00 00 00 
}
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	c9                   	leave  
  800064:	c3                   	ret    

00800065 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800065:	55                   	push   %ebp
  800066:	89 e5                	mov    %esp,%ebp
  800068:	56                   	push   %esi
  800069:	53                   	push   %ebx
  80006a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80006d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800070:	e8 ce 00 00 00       	call   800143 <sys_getenvid>
	thisenv = envs + ENVX(envid); 
  800075:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80007d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800082:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800087:	85 db                	test   %ebx,%ebx
  800089:	7e 07                	jle    800092 <libmain+0x2d>
		binaryname = argv[0];
  80008b:	8b 06                	mov    (%esi),%eax
  80008d:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800092:	83 ec 08             	sub    $0x8,%esp
  800095:	56                   	push   %esi
  800096:	53                   	push   %ebx
  800097:	e8 97 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009c:	e8 0a 00 00 00       	call   8000ab <exit>
}
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a7:	5b                   	pop    %ebx
  8000a8:	5e                   	pop    %esi
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    

008000ab <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000b1:	e8 92 04 00 00       	call   800548 <close_all>
	sys_env_destroy(0);
  8000b6:	83 ec 0c             	sub    $0xc,%esp
  8000b9:	6a 00                	push   $0x0
  8000bb:	e8 42 00 00 00       	call   800102 <sys_env_destroy>
}
  8000c0:	83 c4 10             	add    $0x10,%esp
  8000c3:	c9                   	leave  
  8000c4:	c3                   	ret    

008000c5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c5:	55                   	push   %ebp
  8000c6:	89 e5                	mov    %esp,%ebp
  8000c8:	57                   	push   %edi
  8000c9:	56                   	push   %esi
  8000ca:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d6:	89 c3                	mov    %eax,%ebx
  8000d8:	89 c7                	mov    %eax,%edi
  8000da:	89 c6                	mov    %eax,%esi
  8000dc:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000de:	5b                   	pop    %ebx
  8000df:	5e                   	pop    %esi
  8000e0:	5f                   	pop    %edi
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    

008000e3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	57                   	push   %edi
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f3:	89 d1                	mov    %edx,%ecx
  8000f5:	89 d3                	mov    %edx,%ebx
  8000f7:	89 d7                	mov    %edx,%edi
  8000f9:	89 d6                	mov    %edx,%esi
  8000fb:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fd:	5b                   	pop    %ebx
  8000fe:	5e                   	pop    %esi
  8000ff:	5f                   	pop    %edi
  800100:	5d                   	pop    %ebp
  800101:	c3                   	ret    

00800102 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	57                   	push   %edi
  800106:	56                   	push   %esi
  800107:	53                   	push   %ebx
  800108:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80010b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800110:	8b 55 08             	mov    0x8(%ebp),%edx
  800113:	b8 03 00 00 00       	mov    $0x3,%eax
  800118:	89 cb                	mov    %ecx,%ebx
  80011a:	89 cf                	mov    %ecx,%edi
  80011c:	89 ce                	mov    %ecx,%esi
  80011e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800120:	85 c0                	test   %eax,%eax
  800122:	7f 08                	jg     80012c <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800124:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800127:	5b                   	pop    %ebx
  800128:	5e                   	pop    %esi
  800129:	5f                   	pop    %edi
  80012a:	5d                   	pop    %ebp
  80012b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80012c:	83 ec 0c             	sub    $0xc,%esp
  80012f:	50                   	push   %eax
  800130:	6a 03                	push   $0x3
  800132:	68 ea 1d 80 00       	push   $0x801dea
  800137:	6a 23                	push   $0x23
  800139:	68 07 1e 80 00       	push   $0x801e07
  80013e:	e8 dd 0e 00 00       	call   801020 <_panic>

00800143 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	57                   	push   %edi
  800147:	56                   	push   %esi
  800148:	53                   	push   %ebx
	asm volatile("int %1\n"
  800149:	ba 00 00 00 00       	mov    $0x0,%edx
  80014e:	b8 02 00 00 00       	mov    $0x2,%eax
  800153:	89 d1                	mov    %edx,%ecx
  800155:	89 d3                	mov    %edx,%ebx
  800157:	89 d7                	mov    %edx,%edi
  800159:	89 d6                	mov    %edx,%esi
  80015b:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <sys_yield>:

void
sys_yield(void)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	57                   	push   %edi
  800166:	56                   	push   %esi
  800167:	53                   	push   %ebx
	asm volatile("int %1\n"
  800168:	ba 00 00 00 00       	mov    $0x0,%edx
  80016d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800172:	89 d1                	mov    %edx,%ecx
  800174:	89 d3                	mov    %edx,%ebx
  800176:	89 d7                	mov    %edx,%edi
  800178:	89 d6                	mov    %edx,%esi
  80017a:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80017c:	5b                   	pop    %ebx
  80017d:	5e                   	pop    %esi
  80017e:	5f                   	pop    %edi
  80017f:	5d                   	pop    %ebp
  800180:	c3                   	ret    

00800181 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800181:	55                   	push   %ebp
  800182:	89 e5                	mov    %esp,%ebp
  800184:	57                   	push   %edi
  800185:	56                   	push   %esi
  800186:	53                   	push   %ebx
  800187:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80018a:	be 00 00 00 00       	mov    $0x0,%esi
  80018f:	8b 55 08             	mov    0x8(%ebp),%edx
  800192:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800195:	b8 04 00 00 00       	mov    $0x4,%eax
  80019a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80019d:	89 f7                	mov    %esi,%edi
  80019f:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001a1:	85 c0                	test   %eax,%eax
  8001a3:	7f 08                	jg     8001ad <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a8:	5b                   	pop    %ebx
  8001a9:	5e                   	pop    %esi
  8001aa:	5f                   	pop    %edi
  8001ab:	5d                   	pop    %ebp
  8001ac:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ad:	83 ec 0c             	sub    $0xc,%esp
  8001b0:	50                   	push   %eax
  8001b1:	6a 04                	push   $0x4
  8001b3:	68 ea 1d 80 00       	push   $0x801dea
  8001b8:	6a 23                	push   $0x23
  8001ba:	68 07 1e 80 00       	push   $0x801e07
  8001bf:	e8 5c 0e 00 00       	call   801020 <_panic>

008001c4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	57                   	push   %edi
  8001c8:	56                   	push   %esi
  8001c9:	53                   	push   %ebx
  8001ca:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d3:	b8 05 00 00 00       	mov    $0x5,%eax
  8001d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001db:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001de:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e1:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001e3:	85 c0                	test   %eax,%eax
  8001e5:	7f 08                	jg     8001ef <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ea:	5b                   	pop    %ebx
  8001eb:	5e                   	pop    %esi
  8001ec:	5f                   	pop    %edi
  8001ed:	5d                   	pop    %ebp
  8001ee:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ef:	83 ec 0c             	sub    $0xc,%esp
  8001f2:	50                   	push   %eax
  8001f3:	6a 05                	push   $0x5
  8001f5:	68 ea 1d 80 00       	push   $0x801dea
  8001fa:	6a 23                	push   $0x23
  8001fc:	68 07 1e 80 00       	push   $0x801e07
  800201:	e8 1a 0e 00 00       	call   801020 <_panic>

00800206 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800206:	55                   	push   %ebp
  800207:	89 e5                	mov    %esp,%ebp
  800209:	57                   	push   %edi
  80020a:	56                   	push   %esi
  80020b:	53                   	push   %ebx
  80020c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80020f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800214:	8b 55 08             	mov    0x8(%ebp),%edx
  800217:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80021a:	b8 06 00 00 00       	mov    $0x6,%eax
  80021f:	89 df                	mov    %ebx,%edi
  800221:	89 de                	mov    %ebx,%esi
  800223:	cd 30                	int    $0x30
	if(check && ret > 0)
  800225:	85 c0                	test   %eax,%eax
  800227:	7f 08                	jg     800231 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800229:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022c:	5b                   	pop    %ebx
  80022d:	5e                   	pop    %esi
  80022e:	5f                   	pop    %edi
  80022f:	5d                   	pop    %ebp
  800230:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800231:	83 ec 0c             	sub    $0xc,%esp
  800234:	50                   	push   %eax
  800235:	6a 06                	push   $0x6
  800237:	68 ea 1d 80 00       	push   $0x801dea
  80023c:	6a 23                	push   $0x23
  80023e:	68 07 1e 80 00       	push   $0x801e07
  800243:	e8 d8 0d 00 00       	call   801020 <_panic>

00800248 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	57                   	push   %edi
  80024c:	56                   	push   %esi
  80024d:	53                   	push   %ebx
  80024e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800251:	bb 00 00 00 00       	mov    $0x0,%ebx
  800256:	8b 55 08             	mov    0x8(%ebp),%edx
  800259:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80025c:	b8 08 00 00 00       	mov    $0x8,%eax
  800261:	89 df                	mov    %ebx,%edi
  800263:	89 de                	mov    %ebx,%esi
  800265:	cd 30                	int    $0x30
	if(check && ret > 0)
  800267:	85 c0                	test   %eax,%eax
  800269:	7f 08                	jg     800273 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80026b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026e:	5b                   	pop    %ebx
  80026f:	5e                   	pop    %esi
  800270:	5f                   	pop    %edi
  800271:	5d                   	pop    %ebp
  800272:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800273:	83 ec 0c             	sub    $0xc,%esp
  800276:	50                   	push   %eax
  800277:	6a 08                	push   $0x8
  800279:	68 ea 1d 80 00       	push   $0x801dea
  80027e:	6a 23                	push   $0x23
  800280:	68 07 1e 80 00       	push   $0x801e07
  800285:	e8 96 0d 00 00       	call   801020 <_panic>

0080028a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	57                   	push   %edi
  80028e:	56                   	push   %esi
  80028f:	53                   	push   %ebx
  800290:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800293:	bb 00 00 00 00       	mov    $0x0,%ebx
  800298:	8b 55 08             	mov    0x8(%ebp),%edx
  80029b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80029e:	b8 09 00 00 00       	mov    $0x9,%eax
  8002a3:	89 df                	mov    %ebx,%edi
  8002a5:	89 de                	mov    %ebx,%esi
  8002a7:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002a9:	85 c0                	test   %eax,%eax
  8002ab:	7f 08                	jg     8002b5 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b0:	5b                   	pop    %ebx
  8002b1:	5e                   	pop    %esi
  8002b2:	5f                   	pop    %edi
  8002b3:	5d                   	pop    %ebp
  8002b4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002b5:	83 ec 0c             	sub    $0xc,%esp
  8002b8:	50                   	push   %eax
  8002b9:	6a 09                	push   $0x9
  8002bb:	68 ea 1d 80 00       	push   $0x801dea
  8002c0:	6a 23                	push   $0x23
  8002c2:	68 07 1e 80 00       	push   $0x801e07
  8002c7:	e8 54 0d 00 00       	call   801020 <_panic>

008002cc <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	57                   	push   %edi
  8002d0:	56                   	push   %esi
  8002d1:	53                   	push   %ebx
  8002d2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002da:	8b 55 08             	mov    0x8(%ebp),%edx
  8002dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002e5:	89 df                	mov    %ebx,%edi
  8002e7:	89 de                	mov    %ebx,%esi
  8002e9:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002eb:	85 c0                	test   %eax,%eax
  8002ed:	7f 08                	jg     8002f7 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f2:	5b                   	pop    %ebx
  8002f3:	5e                   	pop    %esi
  8002f4:	5f                   	pop    %edi
  8002f5:	5d                   	pop    %ebp
  8002f6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f7:	83 ec 0c             	sub    $0xc,%esp
  8002fa:	50                   	push   %eax
  8002fb:	6a 0a                	push   $0xa
  8002fd:	68 ea 1d 80 00       	push   $0x801dea
  800302:	6a 23                	push   $0x23
  800304:	68 07 1e 80 00       	push   $0x801e07
  800309:	e8 12 0d 00 00       	call   801020 <_panic>

0080030e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	57                   	push   %edi
  800312:	56                   	push   %esi
  800313:	53                   	push   %ebx
	asm volatile("int %1\n"
  800314:	8b 55 08             	mov    0x8(%ebp),%edx
  800317:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80031a:	b8 0c 00 00 00       	mov    $0xc,%eax
  80031f:	be 00 00 00 00       	mov    $0x0,%esi
  800324:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800327:	8b 7d 14             	mov    0x14(%ebp),%edi
  80032a:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80032c:	5b                   	pop    %ebx
  80032d:	5e                   	pop    %esi
  80032e:	5f                   	pop    %edi
  80032f:	5d                   	pop    %ebp
  800330:	c3                   	ret    

00800331 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	57                   	push   %edi
  800335:	56                   	push   %esi
  800336:	53                   	push   %ebx
  800337:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80033a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033f:	8b 55 08             	mov    0x8(%ebp),%edx
  800342:	b8 0d 00 00 00       	mov    $0xd,%eax
  800347:	89 cb                	mov    %ecx,%ebx
  800349:	89 cf                	mov    %ecx,%edi
  80034b:	89 ce                	mov    %ecx,%esi
  80034d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80034f:	85 c0                	test   %eax,%eax
  800351:	7f 08                	jg     80035b <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800353:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800356:	5b                   	pop    %ebx
  800357:	5e                   	pop    %esi
  800358:	5f                   	pop    %edi
  800359:	5d                   	pop    %ebp
  80035a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80035b:	83 ec 0c             	sub    $0xc,%esp
  80035e:	50                   	push   %eax
  80035f:	6a 0d                	push   $0xd
  800361:	68 ea 1d 80 00       	push   $0x801dea
  800366:	6a 23                	push   $0x23
  800368:	68 07 1e 80 00       	push   $0x801e07
  80036d:	e8 ae 0c 00 00       	call   801020 <_panic>

00800372 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800372:	55                   	push   %ebp
  800373:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800375:	8b 45 08             	mov    0x8(%ebp),%eax
  800378:	05 00 00 00 30       	add    $0x30000000,%eax
  80037d:	c1 e8 0c             	shr    $0xc,%eax
}
  800380:	5d                   	pop    %ebp
  800381:	c3                   	ret    

00800382 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800382:	55                   	push   %ebp
  800383:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800385:	8b 45 08             	mov    0x8(%ebp),%eax
  800388:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80038d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800392:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800397:	5d                   	pop    %ebp
  800398:	c3                   	ret    

00800399 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800399:	55                   	push   %ebp
  80039a:	89 e5                	mov    %esp,%ebp
  80039c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80039f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003a4:	89 c2                	mov    %eax,%edx
  8003a6:	c1 ea 16             	shr    $0x16,%edx
  8003a9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003b0:	f6 c2 01             	test   $0x1,%dl
  8003b3:	74 2a                	je     8003df <fd_alloc+0x46>
  8003b5:	89 c2                	mov    %eax,%edx
  8003b7:	c1 ea 0c             	shr    $0xc,%edx
  8003ba:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003c1:	f6 c2 01             	test   $0x1,%dl
  8003c4:	74 19                	je     8003df <fd_alloc+0x46>
  8003c6:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8003cb:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003d0:	75 d2                	jne    8003a4 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003d2:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003d8:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8003dd:	eb 07                	jmp    8003e6 <fd_alloc+0x4d>
			*fd_store = fd;
  8003df:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003e6:	5d                   	pop    %ebp
  8003e7:	c3                   	ret    

008003e8 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003e8:	55                   	push   %ebp
  8003e9:	89 e5                	mov    %esp,%ebp
  8003eb:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003ee:	83 f8 1f             	cmp    $0x1f,%eax
  8003f1:	77 36                	ja     800429 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003f3:	c1 e0 0c             	shl    $0xc,%eax
  8003f6:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003fb:	89 c2                	mov    %eax,%edx
  8003fd:	c1 ea 16             	shr    $0x16,%edx
  800400:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800407:	f6 c2 01             	test   $0x1,%dl
  80040a:	74 24                	je     800430 <fd_lookup+0x48>
  80040c:	89 c2                	mov    %eax,%edx
  80040e:	c1 ea 0c             	shr    $0xc,%edx
  800411:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800418:	f6 c2 01             	test   $0x1,%dl
  80041b:	74 1a                	je     800437 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80041d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800420:	89 02                	mov    %eax,(%edx)
	return 0;
  800422:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800427:	5d                   	pop    %ebp
  800428:	c3                   	ret    
		return -E_INVAL;
  800429:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80042e:	eb f7                	jmp    800427 <fd_lookup+0x3f>
		return -E_INVAL;
  800430:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800435:	eb f0                	jmp    800427 <fd_lookup+0x3f>
  800437:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80043c:	eb e9                	jmp    800427 <fd_lookup+0x3f>

0080043e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80043e:	55                   	push   %ebp
  80043f:	89 e5                	mov    %esp,%ebp
  800441:	83 ec 08             	sub    $0x8,%esp
  800444:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800447:	ba 94 1e 80 00       	mov    $0x801e94,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80044c:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800451:	39 08                	cmp    %ecx,(%eax)
  800453:	74 33                	je     800488 <dev_lookup+0x4a>
  800455:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800458:	8b 02                	mov    (%edx),%eax
  80045a:	85 c0                	test   %eax,%eax
  80045c:	75 f3                	jne    800451 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80045e:	a1 04 40 80 00       	mov    0x804004,%eax
  800463:	8b 40 48             	mov    0x48(%eax),%eax
  800466:	83 ec 04             	sub    $0x4,%esp
  800469:	51                   	push   %ecx
  80046a:	50                   	push   %eax
  80046b:	68 18 1e 80 00       	push   $0x801e18
  800470:	e8 86 0c 00 00       	call   8010fb <cprintf>
	*dev = 0;
  800475:	8b 45 0c             	mov    0xc(%ebp),%eax
  800478:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80047e:	83 c4 10             	add    $0x10,%esp
  800481:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800486:	c9                   	leave  
  800487:	c3                   	ret    
			*dev = devtab[i];
  800488:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80048b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80048d:	b8 00 00 00 00       	mov    $0x0,%eax
  800492:	eb f2                	jmp    800486 <dev_lookup+0x48>

00800494 <fd_close>:
{
  800494:	55                   	push   %ebp
  800495:	89 e5                	mov    %esp,%ebp
  800497:	57                   	push   %edi
  800498:	56                   	push   %esi
  800499:	53                   	push   %ebx
  80049a:	83 ec 1c             	sub    $0x1c,%esp
  80049d:	8b 75 08             	mov    0x8(%ebp),%esi
  8004a0:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004a3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8004a6:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8004a7:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004ad:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004b0:	50                   	push   %eax
  8004b1:	e8 32 ff ff ff       	call   8003e8 <fd_lookup>
  8004b6:	89 c3                	mov    %eax,%ebx
  8004b8:	83 c4 08             	add    $0x8,%esp
  8004bb:	85 c0                	test   %eax,%eax
  8004bd:	78 05                	js     8004c4 <fd_close+0x30>
	    || fd != fd2)
  8004bf:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8004c2:	74 16                	je     8004da <fd_close+0x46>
		return (must_exist ? r : 0);
  8004c4:	89 f8                	mov    %edi,%eax
  8004c6:	84 c0                	test   %al,%al
  8004c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004cd:	0f 44 d8             	cmove  %eax,%ebx
}
  8004d0:	89 d8                	mov    %ebx,%eax
  8004d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004d5:	5b                   	pop    %ebx
  8004d6:	5e                   	pop    %esi
  8004d7:	5f                   	pop    %edi
  8004d8:	5d                   	pop    %ebp
  8004d9:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004da:	83 ec 08             	sub    $0x8,%esp
  8004dd:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8004e0:	50                   	push   %eax
  8004e1:	ff 36                	pushl  (%esi)
  8004e3:	e8 56 ff ff ff       	call   80043e <dev_lookup>
  8004e8:	89 c3                	mov    %eax,%ebx
  8004ea:	83 c4 10             	add    $0x10,%esp
  8004ed:	85 c0                	test   %eax,%eax
  8004ef:	78 15                	js     800506 <fd_close+0x72>
		if (dev->dev_close)
  8004f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004f4:	8b 40 10             	mov    0x10(%eax),%eax
  8004f7:	85 c0                	test   %eax,%eax
  8004f9:	74 1b                	je     800516 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  8004fb:	83 ec 0c             	sub    $0xc,%esp
  8004fe:	56                   	push   %esi
  8004ff:	ff d0                	call   *%eax
  800501:	89 c3                	mov    %eax,%ebx
  800503:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800506:	83 ec 08             	sub    $0x8,%esp
  800509:	56                   	push   %esi
  80050a:	6a 00                	push   $0x0
  80050c:	e8 f5 fc ff ff       	call   800206 <sys_page_unmap>
	return r;
  800511:	83 c4 10             	add    $0x10,%esp
  800514:	eb ba                	jmp    8004d0 <fd_close+0x3c>
			r = 0;
  800516:	bb 00 00 00 00       	mov    $0x0,%ebx
  80051b:	eb e9                	jmp    800506 <fd_close+0x72>

0080051d <close>:

int
close(int fdnum)
{
  80051d:	55                   	push   %ebp
  80051e:	89 e5                	mov    %esp,%ebp
  800520:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800523:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800526:	50                   	push   %eax
  800527:	ff 75 08             	pushl  0x8(%ebp)
  80052a:	e8 b9 fe ff ff       	call   8003e8 <fd_lookup>
  80052f:	83 c4 08             	add    $0x8,%esp
  800532:	85 c0                	test   %eax,%eax
  800534:	78 10                	js     800546 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800536:	83 ec 08             	sub    $0x8,%esp
  800539:	6a 01                	push   $0x1
  80053b:	ff 75 f4             	pushl  -0xc(%ebp)
  80053e:	e8 51 ff ff ff       	call   800494 <fd_close>
  800543:	83 c4 10             	add    $0x10,%esp
}
  800546:	c9                   	leave  
  800547:	c3                   	ret    

00800548 <close_all>:

void
close_all(void)
{
  800548:	55                   	push   %ebp
  800549:	89 e5                	mov    %esp,%ebp
  80054b:	53                   	push   %ebx
  80054c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80054f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800554:	83 ec 0c             	sub    $0xc,%esp
  800557:	53                   	push   %ebx
  800558:	e8 c0 ff ff ff       	call   80051d <close>
	for (i = 0; i < MAXFD; i++)
  80055d:	83 c3 01             	add    $0x1,%ebx
  800560:	83 c4 10             	add    $0x10,%esp
  800563:	83 fb 20             	cmp    $0x20,%ebx
  800566:	75 ec                	jne    800554 <close_all+0xc>
}
  800568:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80056b:	c9                   	leave  
  80056c:	c3                   	ret    

0080056d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80056d:	55                   	push   %ebp
  80056e:	89 e5                	mov    %esp,%ebp
  800570:	57                   	push   %edi
  800571:	56                   	push   %esi
  800572:	53                   	push   %ebx
  800573:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800576:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800579:	50                   	push   %eax
  80057a:	ff 75 08             	pushl  0x8(%ebp)
  80057d:	e8 66 fe ff ff       	call   8003e8 <fd_lookup>
  800582:	89 c3                	mov    %eax,%ebx
  800584:	83 c4 08             	add    $0x8,%esp
  800587:	85 c0                	test   %eax,%eax
  800589:	0f 88 81 00 00 00    	js     800610 <dup+0xa3>
		return r;
	close(newfdnum);
  80058f:	83 ec 0c             	sub    $0xc,%esp
  800592:	ff 75 0c             	pushl  0xc(%ebp)
  800595:	e8 83 ff ff ff       	call   80051d <close>

	newfd = INDEX2FD(newfdnum);
  80059a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80059d:	c1 e6 0c             	shl    $0xc,%esi
  8005a0:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8005a6:	83 c4 04             	add    $0x4,%esp
  8005a9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005ac:	e8 d1 fd ff ff       	call   800382 <fd2data>
  8005b1:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8005b3:	89 34 24             	mov    %esi,(%esp)
  8005b6:	e8 c7 fd ff ff       	call   800382 <fd2data>
  8005bb:	83 c4 10             	add    $0x10,%esp
  8005be:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005c0:	89 d8                	mov    %ebx,%eax
  8005c2:	c1 e8 16             	shr    $0x16,%eax
  8005c5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005cc:	a8 01                	test   $0x1,%al
  8005ce:	74 11                	je     8005e1 <dup+0x74>
  8005d0:	89 d8                	mov    %ebx,%eax
  8005d2:	c1 e8 0c             	shr    $0xc,%eax
  8005d5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005dc:	f6 c2 01             	test   $0x1,%dl
  8005df:	75 39                	jne    80061a <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005e1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005e4:	89 d0                	mov    %edx,%eax
  8005e6:	c1 e8 0c             	shr    $0xc,%eax
  8005e9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005f0:	83 ec 0c             	sub    $0xc,%esp
  8005f3:	25 07 0e 00 00       	and    $0xe07,%eax
  8005f8:	50                   	push   %eax
  8005f9:	56                   	push   %esi
  8005fa:	6a 00                	push   $0x0
  8005fc:	52                   	push   %edx
  8005fd:	6a 00                	push   $0x0
  8005ff:	e8 c0 fb ff ff       	call   8001c4 <sys_page_map>
  800604:	89 c3                	mov    %eax,%ebx
  800606:	83 c4 20             	add    $0x20,%esp
  800609:	85 c0                	test   %eax,%eax
  80060b:	78 31                	js     80063e <dup+0xd1>
		goto err;

	return newfdnum;
  80060d:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800610:	89 d8                	mov    %ebx,%eax
  800612:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800615:	5b                   	pop    %ebx
  800616:	5e                   	pop    %esi
  800617:	5f                   	pop    %edi
  800618:	5d                   	pop    %ebp
  800619:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80061a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800621:	83 ec 0c             	sub    $0xc,%esp
  800624:	25 07 0e 00 00       	and    $0xe07,%eax
  800629:	50                   	push   %eax
  80062a:	57                   	push   %edi
  80062b:	6a 00                	push   $0x0
  80062d:	53                   	push   %ebx
  80062e:	6a 00                	push   $0x0
  800630:	e8 8f fb ff ff       	call   8001c4 <sys_page_map>
  800635:	89 c3                	mov    %eax,%ebx
  800637:	83 c4 20             	add    $0x20,%esp
  80063a:	85 c0                	test   %eax,%eax
  80063c:	79 a3                	jns    8005e1 <dup+0x74>
	sys_page_unmap(0, newfd);
  80063e:	83 ec 08             	sub    $0x8,%esp
  800641:	56                   	push   %esi
  800642:	6a 00                	push   $0x0
  800644:	e8 bd fb ff ff       	call   800206 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800649:	83 c4 08             	add    $0x8,%esp
  80064c:	57                   	push   %edi
  80064d:	6a 00                	push   $0x0
  80064f:	e8 b2 fb ff ff       	call   800206 <sys_page_unmap>
	return r;
  800654:	83 c4 10             	add    $0x10,%esp
  800657:	eb b7                	jmp    800610 <dup+0xa3>

00800659 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800659:	55                   	push   %ebp
  80065a:	89 e5                	mov    %esp,%ebp
  80065c:	53                   	push   %ebx
  80065d:	83 ec 14             	sub    $0x14,%esp
  800660:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800663:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800666:	50                   	push   %eax
  800667:	53                   	push   %ebx
  800668:	e8 7b fd ff ff       	call   8003e8 <fd_lookup>
  80066d:	83 c4 08             	add    $0x8,%esp
  800670:	85 c0                	test   %eax,%eax
  800672:	78 3f                	js     8006b3 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800674:	83 ec 08             	sub    $0x8,%esp
  800677:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80067a:	50                   	push   %eax
  80067b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80067e:	ff 30                	pushl  (%eax)
  800680:	e8 b9 fd ff ff       	call   80043e <dev_lookup>
  800685:	83 c4 10             	add    $0x10,%esp
  800688:	85 c0                	test   %eax,%eax
  80068a:	78 27                	js     8006b3 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80068c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80068f:	8b 42 08             	mov    0x8(%edx),%eax
  800692:	83 e0 03             	and    $0x3,%eax
  800695:	83 f8 01             	cmp    $0x1,%eax
  800698:	74 1e                	je     8006b8 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80069a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80069d:	8b 40 08             	mov    0x8(%eax),%eax
  8006a0:	85 c0                	test   %eax,%eax
  8006a2:	74 35                	je     8006d9 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006a4:	83 ec 04             	sub    $0x4,%esp
  8006a7:	ff 75 10             	pushl  0x10(%ebp)
  8006aa:	ff 75 0c             	pushl  0xc(%ebp)
  8006ad:	52                   	push   %edx
  8006ae:	ff d0                	call   *%eax
  8006b0:	83 c4 10             	add    $0x10,%esp
}
  8006b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006b6:	c9                   	leave  
  8006b7:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006b8:	a1 04 40 80 00       	mov    0x804004,%eax
  8006bd:	8b 40 48             	mov    0x48(%eax),%eax
  8006c0:	83 ec 04             	sub    $0x4,%esp
  8006c3:	53                   	push   %ebx
  8006c4:	50                   	push   %eax
  8006c5:	68 59 1e 80 00       	push   $0x801e59
  8006ca:	e8 2c 0a 00 00       	call   8010fb <cprintf>
		return -E_INVAL;
  8006cf:	83 c4 10             	add    $0x10,%esp
  8006d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006d7:	eb da                	jmp    8006b3 <read+0x5a>
		return -E_NOT_SUPP;
  8006d9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8006de:	eb d3                	jmp    8006b3 <read+0x5a>

008006e0 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006e0:	55                   	push   %ebp
  8006e1:	89 e5                	mov    %esp,%ebp
  8006e3:	57                   	push   %edi
  8006e4:	56                   	push   %esi
  8006e5:	53                   	push   %ebx
  8006e6:	83 ec 0c             	sub    $0xc,%esp
  8006e9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006ec:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006ef:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006f4:	39 f3                	cmp    %esi,%ebx
  8006f6:	73 25                	jae    80071d <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006f8:	83 ec 04             	sub    $0x4,%esp
  8006fb:	89 f0                	mov    %esi,%eax
  8006fd:	29 d8                	sub    %ebx,%eax
  8006ff:	50                   	push   %eax
  800700:	89 d8                	mov    %ebx,%eax
  800702:	03 45 0c             	add    0xc(%ebp),%eax
  800705:	50                   	push   %eax
  800706:	57                   	push   %edi
  800707:	e8 4d ff ff ff       	call   800659 <read>
		if (m < 0)
  80070c:	83 c4 10             	add    $0x10,%esp
  80070f:	85 c0                	test   %eax,%eax
  800711:	78 08                	js     80071b <readn+0x3b>
			return m;
		if (m == 0)
  800713:	85 c0                	test   %eax,%eax
  800715:	74 06                	je     80071d <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  800717:	01 c3                	add    %eax,%ebx
  800719:	eb d9                	jmp    8006f4 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80071b:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80071d:	89 d8                	mov    %ebx,%eax
  80071f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800722:	5b                   	pop    %ebx
  800723:	5e                   	pop    %esi
  800724:	5f                   	pop    %edi
  800725:	5d                   	pop    %ebp
  800726:	c3                   	ret    

00800727 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800727:	55                   	push   %ebp
  800728:	89 e5                	mov    %esp,%ebp
  80072a:	53                   	push   %ebx
  80072b:	83 ec 14             	sub    $0x14,%esp
  80072e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800731:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800734:	50                   	push   %eax
  800735:	53                   	push   %ebx
  800736:	e8 ad fc ff ff       	call   8003e8 <fd_lookup>
  80073b:	83 c4 08             	add    $0x8,%esp
  80073e:	85 c0                	test   %eax,%eax
  800740:	78 3a                	js     80077c <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800742:	83 ec 08             	sub    $0x8,%esp
  800745:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800748:	50                   	push   %eax
  800749:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80074c:	ff 30                	pushl  (%eax)
  80074e:	e8 eb fc ff ff       	call   80043e <dev_lookup>
  800753:	83 c4 10             	add    $0x10,%esp
  800756:	85 c0                	test   %eax,%eax
  800758:	78 22                	js     80077c <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80075a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80075d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800761:	74 1e                	je     800781 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800763:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800766:	8b 52 0c             	mov    0xc(%edx),%edx
  800769:	85 d2                	test   %edx,%edx
  80076b:	74 35                	je     8007a2 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80076d:	83 ec 04             	sub    $0x4,%esp
  800770:	ff 75 10             	pushl  0x10(%ebp)
  800773:	ff 75 0c             	pushl  0xc(%ebp)
  800776:	50                   	push   %eax
  800777:	ff d2                	call   *%edx
  800779:	83 c4 10             	add    $0x10,%esp
}
  80077c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80077f:	c9                   	leave  
  800780:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800781:	a1 04 40 80 00       	mov    0x804004,%eax
  800786:	8b 40 48             	mov    0x48(%eax),%eax
  800789:	83 ec 04             	sub    $0x4,%esp
  80078c:	53                   	push   %ebx
  80078d:	50                   	push   %eax
  80078e:	68 75 1e 80 00       	push   $0x801e75
  800793:	e8 63 09 00 00       	call   8010fb <cprintf>
		return -E_INVAL;
  800798:	83 c4 10             	add    $0x10,%esp
  80079b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007a0:	eb da                	jmp    80077c <write+0x55>
		return -E_NOT_SUPP;
  8007a2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8007a7:	eb d3                	jmp    80077c <write+0x55>

008007a9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007a9:	55                   	push   %ebp
  8007aa:	89 e5                	mov    %esp,%ebp
  8007ac:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007af:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007b2:	50                   	push   %eax
  8007b3:	ff 75 08             	pushl  0x8(%ebp)
  8007b6:	e8 2d fc ff ff       	call   8003e8 <fd_lookup>
  8007bb:	83 c4 08             	add    $0x8,%esp
  8007be:	85 c0                	test   %eax,%eax
  8007c0:	78 0e                	js     8007d0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007c8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007d0:	c9                   	leave  
  8007d1:	c3                   	ret    

008007d2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	53                   	push   %ebx
  8007d6:	83 ec 14             	sub    $0x14,%esp
  8007d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007df:	50                   	push   %eax
  8007e0:	53                   	push   %ebx
  8007e1:	e8 02 fc ff ff       	call   8003e8 <fd_lookup>
  8007e6:	83 c4 08             	add    $0x8,%esp
  8007e9:	85 c0                	test   %eax,%eax
  8007eb:	78 37                	js     800824 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007ed:	83 ec 08             	sub    $0x8,%esp
  8007f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007f3:	50                   	push   %eax
  8007f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007f7:	ff 30                	pushl  (%eax)
  8007f9:	e8 40 fc ff ff       	call   80043e <dev_lookup>
  8007fe:	83 c4 10             	add    $0x10,%esp
  800801:	85 c0                	test   %eax,%eax
  800803:	78 1f                	js     800824 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800805:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800808:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80080c:	74 1b                	je     800829 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80080e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800811:	8b 52 18             	mov    0x18(%edx),%edx
  800814:	85 d2                	test   %edx,%edx
  800816:	74 32                	je     80084a <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800818:	83 ec 08             	sub    $0x8,%esp
  80081b:	ff 75 0c             	pushl  0xc(%ebp)
  80081e:	50                   	push   %eax
  80081f:	ff d2                	call   *%edx
  800821:	83 c4 10             	add    $0x10,%esp
}
  800824:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800827:	c9                   	leave  
  800828:	c3                   	ret    
			thisenv->env_id, fdnum);
  800829:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80082e:	8b 40 48             	mov    0x48(%eax),%eax
  800831:	83 ec 04             	sub    $0x4,%esp
  800834:	53                   	push   %ebx
  800835:	50                   	push   %eax
  800836:	68 38 1e 80 00       	push   $0x801e38
  80083b:	e8 bb 08 00 00       	call   8010fb <cprintf>
		return -E_INVAL;
  800840:	83 c4 10             	add    $0x10,%esp
  800843:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800848:	eb da                	jmp    800824 <ftruncate+0x52>
		return -E_NOT_SUPP;
  80084a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80084f:	eb d3                	jmp    800824 <ftruncate+0x52>

00800851 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	53                   	push   %ebx
  800855:	83 ec 14             	sub    $0x14,%esp
  800858:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80085b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80085e:	50                   	push   %eax
  80085f:	ff 75 08             	pushl  0x8(%ebp)
  800862:	e8 81 fb ff ff       	call   8003e8 <fd_lookup>
  800867:	83 c4 08             	add    $0x8,%esp
  80086a:	85 c0                	test   %eax,%eax
  80086c:	78 4b                	js     8008b9 <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80086e:	83 ec 08             	sub    $0x8,%esp
  800871:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800874:	50                   	push   %eax
  800875:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800878:	ff 30                	pushl  (%eax)
  80087a:	e8 bf fb ff ff       	call   80043e <dev_lookup>
  80087f:	83 c4 10             	add    $0x10,%esp
  800882:	85 c0                	test   %eax,%eax
  800884:	78 33                	js     8008b9 <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  800886:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800889:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80088d:	74 2f                	je     8008be <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80088f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800892:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800899:	00 00 00 
	stat->st_isdir = 0;
  80089c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008a3:	00 00 00 
	stat->st_dev = dev;
  8008a6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008ac:	83 ec 08             	sub    $0x8,%esp
  8008af:	53                   	push   %ebx
  8008b0:	ff 75 f0             	pushl  -0x10(%ebp)
  8008b3:	ff 50 14             	call   *0x14(%eax)
  8008b6:	83 c4 10             	add    $0x10,%esp
}
  8008b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008bc:	c9                   	leave  
  8008bd:	c3                   	ret    
		return -E_NOT_SUPP;
  8008be:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8008c3:	eb f4                	jmp    8008b9 <fstat+0x68>

008008c5 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008c5:	55                   	push   %ebp
  8008c6:	89 e5                	mov    %esp,%ebp
  8008c8:	56                   	push   %esi
  8008c9:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008ca:	83 ec 08             	sub    $0x8,%esp
  8008cd:	6a 00                	push   $0x0
  8008cf:	ff 75 08             	pushl  0x8(%ebp)
  8008d2:	e8 da 01 00 00       	call   800ab1 <open>
  8008d7:	89 c3                	mov    %eax,%ebx
  8008d9:	83 c4 10             	add    $0x10,%esp
  8008dc:	85 c0                	test   %eax,%eax
  8008de:	78 1b                	js     8008fb <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008e0:	83 ec 08             	sub    $0x8,%esp
  8008e3:	ff 75 0c             	pushl  0xc(%ebp)
  8008e6:	50                   	push   %eax
  8008e7:	e8 65 ff ff ff       	call   800851 <fstat>
  8008ec:	89 c6                	mov    %eax,%esi
	close(fd);
  8008ee:	89 1c 24             	mov    %ebx,(%esp)
  8008f1:	e8 27 fc ff ff       	call   80051d <close>
	return r;
  8008f6:	83 c4 10             	add    $0x10,%esp
  8008f9:	89 f3                	mov    %esi,%ebx
}
  8008fb:	89 d8                	mov    %ebx,%eax
  8008fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800900:	5b                   	pop    %ebx
  800901:	5e                   	pop    %esi
  800902:	5d                   	pop    %ebp
  800903:	c3                   	ret    

00800904 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	56                   	push   %esi
  800908:	53                   	push   %ebx
  800909:	89 c6                	mov    %eax,%esi
  80090b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80090d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800914:	74 27                	je     80093d <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800916:	6a 07                	push   $0x7
  800918:	68 00 50 80 00       	push   $0x805000
  80091d:	56                   	push   %esi
  80091e:	ff 35 00 40 80 00    	pushl  0x804000
  800924:	e8 95 11 00 00       	call   801abe <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800929:	83 c4 0c             	add    $0xc,%esp
  80092c:	6a 00                	push   $0x0
  80092e:	53                   	push   %ebx
  80092f:	6a 00                	push   $0x0
  800931:	e8 21 11 00 00       	call   801a57 <ipc_recv>
}
  800936:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800939:	5b                   	pop    %ebx
  80093a:	5e                   	pop    %esi
  80093b:	5d                   	pop    %ebp
  80093c:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80093d:	83 ec 0c             	sub    $0xc,%esp
  800940:	6a 01                	push   $0x1
  800942:	e8 cb 11 00 00       	call   801b12 <ipc_find_env>
  800947:	a3 00 40 80 00       	mov    %eax,0x804000
  80094c:	83 c4 10             	add    $0x10,%esp
  80094f:	eb c5                	jmp    800916 <fsipc+0x12>

00800951 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
  800954:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800957:	8b 45 08             	mov    0x8(%ebp),%eax
  80095a:	8b 40 0c             	mov    0xc(%eax),%eax
  80095d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800962:	8b 45 0c             	mov    0xc(%ebp),%eax
  800965:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80096a:	ba 00 00 00 00       	mov    $0x0,%edx
  80096f:	b8 02 00 00 00       	mov    $0x2,%eax
  800974:	e8 8b ff ff ff       	call   800904 <fsipc>
}
  800979:	c9                   	leave  
  80097a:	c3                   	ret    

0080097b <devfile_flush>:
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
  800984:	8b 40 0c             	mov    0xc(%eax),%eax
  800987:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80098c:	ba 00 00 00 00       	mov    $0x0,%edx
  800991:	b8 06 00 00 00       	mov    $0x6,%eax
  800996:	e8 69 ff ff ff       	call   800904 <fsipc>
}
  80099b:	c9                   	leave  
  80099c:	c3                   	ret    

0080099d <devfile_stat>:
{
  80099d:	55                   	push   %ebp
  80099e:	89 e5                	mov    %esp,%ebp
  8009a0:	53                   	push   %ebx
  8009a1:	83 ec 04             	sub    $0x4,%esp
  8009a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8009ad:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b7:	b8 05 00 00 00       	mov    $0x5,%eax
  8009bc:	e8 43 ff ff ff       	call   800904 <fsipc>
  8009c1:	85 c0                	test   %eax,%eax
  8009c3:	78 2c                	js     8009f1 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009c5:	83 ec 08             	sub    $0x8,%esp
  8009c8:	68 00 50 80 00       	push   $0x805000
  8009cd:	53                   	push   %ebx
  8009ce:	e8 47 0d 00 00       	call   80171a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009d3:	a1 80 50 80 00       	mov    0x805080,%eax
  8009d8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009de:	a1 84 50 80 00       	mov    0x805084,%eax
  8009e3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009e9:	83 c4 10             	add    $0x10,%esp
  8009ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f4:	c9                   	leave  
  8009f5:	c3                   	ret    

008009f6 <devfile_write>:
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	83 ec 0c             	sub    $0xc,%esp
  8009fc:	8b 45 10             	mov    0x10(%ebp),%eax
    	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009ff:	8b 55 08             	mov    0x8(%ebp),%edx
  800a02:	8b 52 0c             	mov    0xc(%edx),%edx
  800a05:	89 15 00 50 80 00    	mov    %edx,0x805000
    	fsipcbuf.write.req_n = n;
  800a0b:	a3 04 50 80 00       	mov    %eax,0x805004
    	memmove(fsipcbuf.write.req_buf, buf, n);
  800a10:	50                   	push   %eax
  800a11:	ff 75 0c             	pushl  0xc(%ebp)
  800a14:	68 08 50 80 00       	push   $0x805008
  800a19:	e8 8a 0e 00 00       	call   8018a8 <memmove>
    	return fsipc(FSREQ_WRITE, NULL);
  800a1e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a23:	b8 04 00 00 00       	mov    $0x4,%eax
  800a28:	e8 d7 fe ff ff       	call   800904 <fsipc>
}
  800a2d:	c9                   	leave  
  800a2e:	c3                   	ret    

00800a2f <devfile_read>:
{
  800a2f:	55                   	push   %ebp
  800a30:	89 e5                	mov    %esp,%ebp
  800a32:	56                   	push   %esi
  800a33:	53                   	push   %ebx
  800a34:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a37:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3a:	8b 40 0c             	mov    0xc(%eax),%eax
  800a3d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a42:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a48:	ba 00 00 00 00       	mov    $0x0,%edx
  800a4d:	b8 03 00 00 00       	mov    $0x3,%eax
  800a52:	e8 ad fe ff ff       	call   800904 <fsipc>
  800a57:	89 c3                	mov    %eax,%ebx
  800a59:	85 c0                	test   %eax,%eax
  800a5b:	78 1f                	js     800a7c <devfile_read+0x4d>
	assert(r <= n);
  800a5d:	39 f0                	cmp    %esi,%eax
  800a5f:	77 24                	ja     800a85 <devfile_read+0x56>
	assert(r <= PGSIZE);
  800a61:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a66:	7f 33                	jg     800a9b <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a68:	83 ec 04             	sub    $0x4,%esp
  800a6b:	50                   	push   %eax
  800a6c:	68 00 50 80 00       	push   $0x805000
  800a71:	ff 75 0c             	pushl  0xc(%ebp)
  800a74:	e8 2f 0e 00 00       	call   8018a8 <memmove>
	return r;
  800a79:	83 c4 10             	add    $0x10,%esp
}
  800a7c:	89 d8                	mov    %ebx,%eax
  800a7e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a81:	5b                   	pop    %ebx
  800a82:	5e                   	pop    %esi
  800a83:	5d                   	pop    %ebp
  800a84:	c3                   	ret    
	assert(r <= n);
  800a85:	68 a4 1e 80 00       	push   $0x801ea4
  800a8a:	68 ab 1e 80 00       	push   $0x801eab
  800a8f:	6a 7c                	push   $0x7c
  800a91:	68 c0 1e 80 00       	push   $0x801ec0
  800a96:	e8 85 05 00 00       	call   801020 <_panic>
	assert(r <= PGSIZE);
  800a9b:	68 cb 1e 80 00       	push   $0x801ecb
  800aa0:	68 ab 1e 80 00       	push   $0x801eab
  800aa5:	6a 7d                	push   $0x7d
  800aa7:	68 c0 1e 80 00       	push   $0x801ec0
  800aac:	e8 6f 05 00 00       	call   801020 <_panic>

00800ab1 <open>:
{
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
  800ab4:	56                   	push   %esi
  800ab5:	53                   	push   %ebx
  800ab6:	83 ec 1c             	sub    $0x1c,%esp
  800ab9:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800abc:	56                   	push   %esi
  800abd:	e8 21 0c 00 00       	call   8016e3 <strlen>
  800ac2:	83 c4 10             	add    $0x10,%esp
  800ac5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800aca:	7f 6c                	jg     800b38 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  800acc:	83 ec 0c             	sub    $0xc,%esp
  800acf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ad2:	50                   	push   %eax
  800ad3:	e8 c1 f8 ff ff       	call   800399 <fd_alloc>
  800ad8:	89 c3                	mov    %eax,%ebx
  800ada:	83 c4 10             	add    $0x10,%esp
  800add:	85 c0                	test   %eax,%eax
  800adf:	78 3c                	js     800b1d <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  800ae1:	83 ec 08             	sub    $0x8,%esp
  800ae4:	56                   	push   %esi
  800ae5:	68 00 50 80 00       	push   $0x805000
  800aea:	e8 2b 0c 00 00       	call   80171a <strcpy>
	fsipcbuf.open.req_omode = mode;
  800aef:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af2:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800af7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800afa:	b8 01 00 00 00       	mov    $0x1,%eax
  800aff:	e8 00 fe ff ff       	call   800904 <fsipc>
  800b04:	89 c3                	mov    %eax,%ebx
  800b06:	83 c4 10             	add    $0x10,%esp
  800b09:	85 c0                	test   %eax,%eax
  800b0b:	78 19                	js     800b26 <open+0x75>
	return fd2num(fd);
  800b0d:	83 ec 0c             	sub    $0xc,%esp
  800b10:	ff 75 f4             	pushl  -0xc(%ebp)
  800b13:	e8 5a f8 ff ff       	call   800372 <fd2num>
  800b18:	89 c3                	mov    %eax,%ebx
  800b1a:	83 c4 10             	add    $0x10,%esp
}
  800b1d:	89 d8                	mov    %ebx,%eax
  800b1f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b22:	5b                   	pop    %ebx
  800b23:	5e                   	pop    %esi
  800b24:	5d                   	pop    %ebp
  800b25:	c3                   	ret    
		fd_close(fd, 0);
  800b26:	83 ec 08             	sub    $0x8,%esp
  800b29:	6a 00                	push   $0x0
  800b2b:	ff 75 f4             	pushl  -0xc(%ebp)
  800b2e:	e8 61 f9 ff ff       	call   800494 <fd_close>
		return r;
  800b33:	83 c4 10             	add    $0x10,%esp
  800b36:	eb e5                	jmp    800b1d <open+0x6c>
		return -E_BAD_PATH;
  800b38:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b3d:	eb de                	jmp    800b1d <open+0x6c>

00800b3f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b3f:	55                   	push   %ebp
  800b40:	89 e5                	mov    %esp,%ebp
  800b42:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b45:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4a:	b8 08 00 00 00       	mov    $0x8,%eax
  800b4f:	e8 b0 fd ff ff       	call   800904 <fsipc>
}
  800b54:	c9                   	leave  
  800b55:	c3                   	ret    

00800b56 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	56                   	push   %esi
  800b5a:	53                   	push   %ebx
  800b5b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b5e:	83 ec 0c             	sub    $0xc,%esp
  800b61:	ff 75 08             	pushl  0x8(%ebp)
  800b64:	e8 19 f8 ff ff       	call   800382 <fd2data>
  800b69:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b6b:	83 c4 08             	add    $0x8,%esp
  800b6e:	68 d7 1e 80 00       	push   $0x801ed7
  800b73:	53                   	push   %ebx
  800b74:	e8 a1 0b 00 00       	call   80171a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b79:	8b 46 04             	mov    0x4(%esi),%eax
  800b7c:	2b 06                	sub    (%esi),%eax
  800b7e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b84:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b8b:	00 00 00 
	stat->st_dev = &devpipe;
  800b8e:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b95:	30 80 00 
	return 0;
}
  800b98:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ba0:	5b                   	pop    %ebx
  800ba1:	5e                   	pop    %esi
  800ba2:	5d                   	pop    %ebp
  800ba3:	c3                   	ret    

00800ba4 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	53                   	push   %ebx
  800ba8:	83 ec 0c             	sub    $0xc,%esp
  800bab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bae:	53                   	push   %ebx
  800baf:	6a 00                	push   $0x0
  800bb1:	e8 50 f6 ff ff       	call   800206 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bb6:	89 1c 24             	mov    %ebx,(%esp)
  800bb9:	e8 c4 f7 ff ff       	call   800382 <fd2data>
  800bbe:	83 c4 08             	add    $0x8,%esp
  800bc1:	50                   	push   %eax
  800bc2:	6a 00                	push   $0x0
  800bc4:	e8 3d f6 ff ff       	call   800206 <sys_page_unmap>
}
  800bc9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bcc:	c9                   	leave  
  800bcd:	c3                   	ret    

00800bce <_pipeisclosed>:
{
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	57                   	push   %edi
  800bd2:	56                   	push   %esi
  800bd3:	53                   	push   %ebx
  800bd4:	83 ec 1c             	sub    $0x1c,%esp
  800bd7:	89 c7                	mov    %eax,%edi
  800bd9:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800bdb:	a1 04 40 80 00       	mov    0x804004,%eax
  800be0:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800be3:	83 ec 0c             	sub    $0xc,%esp
  800be6:	57                   	push   %edi
  800be7:	e8 5f 0f 00 00       	call   801b4b <pageref>
  800bec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800bef:	89 34 24             	mov    %esi,(%esp)
  800bf2:	e8 54 0f 00 00       	call   801b4b <pageref>
		nn = thisenv->env_runs;
  800bf7:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800bfd:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c00:	83 c4 10             	add    $0x10,%esp
  800c03:	39 cb                	cmp    %ecx,%ebx
  800c05:	74 1b                	je     800c22 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800c07:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c0a:	75 cf                	jne    800bdb <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c0c:	8b 42 58             	mov    0x58(%edx),%eax
  800c0f:	6a 01                	push   $0x1
  800c11:	50                   	push   %eax
  800c12:	53                   	push   %ebx
  800c13:	68 de 1e 80 00       	push   $0x801ede
  800c18:	e8 de 04 00 00       	call   8010fb <cprintf>
  800c1d:	83 c4 10             	add    $0x10,%esp
  800c20:	eb b9                	jmp    800bdb <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800c22:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c25:	0f 94 c0             	sete   %al
  800c28:	0f b6 c0             	movzbl %al,%eax
}
  800c2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2e:	5b                   	pop    %ebx
  800c2f:	5e                   	pop    %esi
  800c30:	5f                   	pop    %edi
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    

00800c33 <devpipe_write>:
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	57                   	push   %edi
  800c37:	56                   	push   %esi
  800c38:	53                   	push   %ebx
  800c39:	83 ec 28             	sub    $0x28,%esp
  800c3c:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800c3f:	56                   	push   %esi
  800c40:	e8 3d f7 ff ff       	call   800382 <fd2data>
  800c45:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c47:	83 c4 10             	add    $0x10,%esp
  800c4a:	bf 00 00 00 00       	mov    $0x0,%edi
  800c4f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c52:	74 4f                	je     800ca3 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c54:	8b 43 04             	mov    0x4(%ebx),%eax
  800c57:	8b 0b                	mov    (%ebx),%ecx
  800c59:	8d 51 20             	lea    0x20(%ecx),%edx
  800c5c:	39 d0                	cmp    %edx,%eax
  800c5e:	72 14                	jb     800c74 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  800c60:	89 da                	mov    %ebx,%edx
  800c62:	89 f0                	mov    %esi,%eax
  800c64:	e8 65 ff ff ff       	call   800bce <_pipeisclosed>
  800c69:	85 c0                	test   %eax,%eax
  800c6b:	75 3a                	jne    800ca7 <devpipe_write+0x74>
			sys_yield();
  800c6d:	e8 f0 f4 ff ff       	call   800162 <sys_yield>
  800c72:	eb e0                	jmp    800c54 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c77:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c7b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c7e:	89 c2                	mov    %eax,%edx
  800c80:	c1 fa 1f             	sar    $0x1f,%edx
  800c83:	89 d1                	mov    %edx,%ecx
  800c85:	c1 e9 1b             	shr    $0x1b,%ecx
  800c88:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c8b:	83 e2 1f             	and    $0x1f,%edx
  800c8e:	29 ca                	sub    %ecx,%edx
  800c90:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c94:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c98:	83 c0 01             	add    $0x1,%eax
  800c9b:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800c9e:	83 c7 01             	add    $0x1,%edi
  800ca1:	eb ac                	jmp    800c4f <devpipe_write+0x1c>
	return i;
  800ca3:	89 f8                	mov    %edi,%eax
  800ca5:	eb 05                	jmp    800cac <devpipe_write+0x79>
				return 0;
  800ca7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800caf:	5b                   	pop    %ebx
  800cb0:	5e                   	pop    %esi
  800cb1:	5f                   	pop    %edi
  800cb2:	5d                   	pop    %ebp
  800cb3:	c3                   	ret    

00800cb4 <devpipe_read>:
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	57                   	push   %edi
  800cb8:	56                   	push   %esi
  800cb9:	53                   	push   %ebx
  800cba:	83 ec 18             	sub    $0x18,%esp
  800cbd:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800cc0:	57                   	push   %edi
  800cc1:	e8 bc f6 ff ff       	call   800382 <fd2data>
  800cc6:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800cc8:	83 c4 10             	add    $0x10,%esp
  800ccb:	be 00 00 00 00       	mov    $0x0,%esi
  800cd0:	3b 75 10             	cmp    0x10(%ebp),%esi
  800cd3:	74 47                	je     800d1c <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  800cd5:	8b 03                	mov    (%ebx),%eax
  800cd7:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cda:	75 22                	jne    800cfe <devpipe_read+0x4a>
			if (i > 0)
  800cdc:	85 f6                	test   %esi,%esi
  800cde:	75 14                	jne    800cf4 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  800ce0:	89 da                	mov    %ebx,%edx
  800ce2:	89 f8                	mov    %edi,%eax
  800ce4:	e8 e5 fe ff ff       	call   800bce <_pipeisclosed>
  800ce9:	85 c0                	test   %eax,%eax
  800ceb:	75 33                	jne    800d20 <devpipe_read+0x6c>
			sys_yield();
  800ced:	e8 70 f4 ff ff       	call   800162 <sys_yield>
  800cf2:	eb e1                	jmp    800cd5 <devpipe_read+0x21>
				return i;
  800cf4:	89 f0                	mov    %esi,%eax
}
  800cf6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf9:	5b                   	pop    %ebx
  800cfa:	5e                   	pop    %esi
  800cfb:	5f                   	pop    %edi
  800cfc:	5d                   	pop    %ebp
  800cfd:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cfe:	99                   	cltd   
  800cff:	c1 ea 1b             	shr    $0x1b,%edx
  800d02:	01 d0                	add    %edx,%eax
  800d04:	83 e0 1f             	and    $0x1f,%eax
  800d07:	29 d0                	sub    %edx,%eax
  800d09:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800d0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d11:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800d14:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800d17:	83 c6 01             	add    $0x1,%esi
  800d1a:	eb b4                	jmp    800cd0 <devpipe_read+0x1c>
	return i;
  800d1c:	89 f0                	mov    %esi,%eax
  800d1e:	eb d6                	jmp    800cf6 <devpipe_read+0x42>
				return 0;
  800d20:	b8 00 00 00 00       	mov    $0x0,%eax
  800d25:	eb cf                	jmp    800cf6 <devpipe_read+0x42>

00800d27 <pipe>:
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	56                   	push   %esi
  800d2b:	53                   	push   %ebx
  800d2c:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800d2f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d32:	50                   	push   %eax
  800d33:	e8 61 f6 ff ff       	call   800399 <fd_alloc>
  800d38:	89 c3                	mov    %eax,%ebx
  800d3a:	83 c4 10             	add    $0x10,%esp
  800d3d:	85 c0                	test   %eax,%eax
  800d3f:	78 5b                	js     800d9c <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d41:	83 ec 04             	sub    $0x4,%esp
  800d44:	68 07 04 00 00       	push   $0x407
  800d49:	ff 75 f4             	pushl  -0xc(%ebp)
  800d4c:	6a 00                	push   $0x0
  800d4e:	e8 2e f4 ff ff       	call   800181 <sys_page_alloc>
  800d53:	89 c3                	mov    %eax,%ebx
  800d55:	83 c4 10             	add    $0x10,%esp
  800d58:	85 c0                	test   %eax,%eax
  800d5a:	78 40                	js     800d9c <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  800d5c:	83 ec 0c             	sub    $0xc,%esp
  800d5f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d62:	50                   	push   %eax
  800d63:	e8 31 f6 ff ff       	call   800399 <fd_alloc>
  800d68:	89 c3                	mov    %eax,%ebx
  800d6a:	83 c4 10             	add    $0x10,%esp
  800d6d:	85 c0                	test   %eax,%eax
  800d6f:	78 1b                	js     800d8c <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d71:	83 ec 04             	sub    $0x4,%esp
  800d74:	68 07 04 00 00       	push   $0x407
  800d79:	ff 75 f0             	pushl  -0x10(%ebp)
  800d7c:	6a 00                	push   $0x0
  800d7e:	e8 fe f3 ff ff       	call   800181 <sys_page_alloc>
  800d83:	89 c3                	mov    %eax,%ebx
  800d85:	83 c4 10             	add    $0x10,%esp
  800d88:	85 c0                	test   %eax,%eax
  800d8a:	79 19                	jns    800da5 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  800d8c:	83 ec 08             	sub    $0x8,%esp
  800d8f:	ff 75 f4             	pushl  -0xc(%ebp)
  800d92:	6a 00                	push   $0x0
  800d94:	e8 6d f4 ff ff       	call   800206 <sys_page_unmap>
  800d99:	83 c4 10             	add    $0x10,%esp
}
  800d9c:	89 d8                	mov    %ebx,%eax
  800d9e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800da1:	5b                   	pop    %ebx
  800da2:	5e                   	pop    %esi
  800da3:	5d                   	pop    %ebp
  800da4:	c3                   	ret    
	va = fd2data(fd0);
  800da5:	83 ec 0c             	sub    $0xc,%esp
  800da8:	ff 75 f4             	pushl  -0xc(%ebp)
  800dab:	e8 d2 f5 ff ff       	call   800382 <fd2data>
  800db0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800db2:	83 c4 0c             	add    $0xc,%esp
  800db5:	68 07 04 00 00       	push   $0x407
  800dba:	50                   	push   %eax
  800dbb:	6a 00                	push   $0x0
  800dbd:	e8 bf f3 ff ff       	call   800181 <sys_page_alloc>
  800dc2:	89 c3                	mov    %eax,%ebx
  800dc4:	83 c4 10             	add    $0x10,%esp
  800dc7:	85 c0                	test   %eax,%eax
  800dc9:	0f 88 8c 00 00 00    	js     800e5b <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dcf:	83 ec 0c             	sub    $0xc,%esp
  800dd2:	ff 75 f0             	pushl  -0x10(%ebp)
  800dd5:	e8 a8 f5 ff ff       	call   800382 <fd2data>
  800dda:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800de1:	50                   	push   %eax
  800de2:	6a 00                	push   $0x0
  800de4:	56                   	push   %esi
  800de5:	6a 00                	push   $0x0
  800de7:	e8 d8 f3 ff ff       	call   8001c4 <sys_page_map>
  800dec:	89 c3                	mov    %eax,%ebx
  800dee:	83 c4 20             	add    $0x20,%esp
  800df1:	85 c0                	test   %eax,%eax
  800df3:	78 58                	js     800e4d <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  800df5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800df8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800dfe:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e00:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e03:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  800e0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e0d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e13:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e15:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e18:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800e1f:	83 ec 0c             	sub    $0xc,%esp
  800e22:	ff 75 f4             	pushl  -0xc(%ebp)
  800e25:	e8 48 f5 ff ff       	call   800372 <fd2num>
  800e2a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e2d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e2f:	83 c4 04             	add    $0x4,%esp
  800e32:	ff 75 f0             	pushl  -0x10(%ebp)
  800e35:	e8 38 f5 ff ff       	call   800372 <fd2num>
  800e3a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e3d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e40:	83 c4 10             	add    $0x10,%esp
  800e43:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e48:	e9 4f ff ff ff       	jmp    800d9c <pipe+0x75>
	sys_page_unmap(0, va);
  800e4d:	83 ec 08             	sub    $0x8,%esp
  800e50:	56                   	push   %esi
  800e51:	6a 00                	push   $0x0
  800e53:	e8 ae f3 ff ff       	call   800206 <sys_page_unmap>
  800e58:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800e5b:	83 ec 08             	sub    $0x8,%esp
  800e5e:	ff 75 f0             	pushl  -0x10(%ebp)
  800e61:	6a 00                	push   $0x0
  800e63:	e8 9e f3 ff ff       	call   800206 <sys_page_unmap>
  800e68:	83 c4 10             	add    $0x10,%esp
  800e6b:	e9 1c ff ff ff       	jmp    800d8c <pipe+0x65>

00800e70 <pipeisclosed>:
{
  800e70:	55                   	push   %ebp
  800e71:	89 e5                	mov    %esp,%ebp
  800e73:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e76:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e79:	50                   	push   %eax
  800e7a:	ff 75 08             	pushl  0x8(%ebp)
  800e7d:	e8 66 f5 ff ff       	call   8003e8 <fd_lookup>
  800e82:	83 c4 10             	add    $0x10,%esp
  800e85:	85 c0                	test   %eax,%eax
  800e87:	78 18                	js     800ea1 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  800e89:	83 ec 0c             	sub    $0xc,%esp
  800e8c:	ff 75 f4             	pushl  -0xc(%ebp)
  800e8f:	e8 ee f4 ff ff       	call   800382 <fd2data>
	return _pipeisclosed(fd, p);
  800e94:	89 c2                	mov    %eax,%edx
  800e96:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e99:	e8 30 fd ff ff       	call   800bce <_pipeisclosed>
  800e9e:	83 c4 10             	add    $0x10,%esp
}
  800ea1:	c9                   	leave  
  800ea2:	c3                   	ret    

00800ea3 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ea3:	55                   	push   %ebp
  800ea4:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ea6:	b8 00 00 00 00       	mov    $0x0,%eax
  800eab:	5d                   	pop    %ebp
  800eac:	c3                   	ret    

00800ead <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ead:	55                   	push   %ebp
  800eae:	89 e5                	mov    %esp,%ebp
  800eb0:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800eb3:	68 f6 1e 80 00       	push   $0x801ef6
  800eb8:	ff 75 0c             	pushl  0xc(%ebp)
  800ebb:	e8 5a 08 00 00       	call   80171a <strcpy>
	return 0;
}
  800ec0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec5:	c9                   	leave  
  800ec6:	c3                   	ret    

00800ec7 <devcons_write>:
{
  800ec7:	55                   	push   %ebp
  800ec8:	89 e5                	mov    %esp,%ebp
  800eca:	57                   	push   %edi
  800ecb:	56                   	push   %esi
  800ecc:	53                   	push   %ebx
  800ecd:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800ed3:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800ed8:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800ede:	eb 2f                	jmp    800f0f <devcons_write+0x48>
		m = n - tot;
  800ee0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ee3:	29 f3                	sub    %esi,%ebx
  800ee5:	83 fb 7f             	cmp    $0x7f,%ebx
  800ee8:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800eed:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800ef0:	83 ec 04             	sub    $0x4,%esp
  800ef3:	53                   	push   %ebx
  800ef4:	89 f0                	mov    %esi,%eax
  800ef6:	03 45 0c             	add    0xc(%ebp),%eax
  800ef9:	50                   	push   %eax
  800efa:	57                   	push   %edi
  800efb:	e8 a8 09 00 00       	call   8018a8 <memmove>
		sys_cputs(buf, m);
  800f00:	83 c4 08             	add    $0x8,%esp
  800f03:	53                   	push   %ebx
  800f04:	57                   	push   %edi
  800f05:	e8 bb f1 ff ff       	call   8000c5 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800f0a:	01 de                	add    %ebx,%esi
  800f0c:	83 c4 10             	add    $0x10,%esp
  800f0f:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f12:	72 cc                	jb     800ee0 <devcons_write+0x19>
}
  800f14:	89 f0                	mov    %esi,%eax
  800f16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f19:	5b                   	pop    %ebx
  800f1a:	5e                   	pop    %esi
  800f1b:	5f                   	pop    %edi
  800f1c:	5d                   	pop    %ebp
  800f1d:	c3                   	ret    

00800f1e <devcons_read>:
{
  800f1e:	55                   	push   %ebp
  800f1f:	89 e5                	mov    %esp,%ebp
  800f21:	83 ec 08             	sub    $0x8,%esp
  800f24:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800f29:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f2d:	75 07                	jne    800f36 <devcons_read+0x18>
}
  800f2f:	c9                   	leave  
  800f30:	c3                   	ret    
		sys_yield();
  800f31:	e8 2c f2 ff ff       	call   800162 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  800f36:	e8 a8 f1 ff ff       	call   8000e3 <sys_cgetc>
  800f3b:	85 c0                	test   %eax,%eax
  800f3d:	74 f2                	je     800f31 <devcons_read+0x13>
	if (c < 0)
  800f3f:	85 c0                	test   %eax,%eax
  800f41:	78 ec                	js     800f2f <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  800f43:	83 f8 04             	cmp    $0x4,%eax
  800f46:	74 0c                	je     800f54 <devcons_read+0x36>
	*(char*)vbuf = c;
  800f48:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f4b:	88 02                	mov    %al,(%edx)
	return 1;
  800f4d:	b8 01 00 00 00       	mov    $0x1,%eax
  800f52:	eb db                	jmp    800f2f <devcons_read+0x11>
		return 0;
  800f54:	b8 00 00 00 00       	mov    $0x0,%eax
  800f59:	eb d4                	jmp    800f2f <devcons_read+0x11>

00800f5b <cputchar>:
{
  800f5b:	55                   	push   %ebp
  800f5c:	89 e5                	mov    %esp,%ebp
  800f5e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f61:	8b 45 08             	mov    0x8(%ebp),%eax
  800f64:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800f67:	6a 01                	push   $0x1
  800f69:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f6c:	50                   	push   %eax
  800f6d:	e8 53 f1 ff ff       	call   8000c5 <sys_cputs>
}
  800f72:	83 c4 10             	add    $0x10,%esp
  800f75:	c9                   	leave  
  800f76:	c3                   	ret    

00800f77 <getchar>:
{
  800f77:	55                   	push   %ebp
  800f78:	89 e5                	mov    %esp,%ebp
  800f7a:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800f7d:	6a 01                	push   $0x1
  800f7f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f82:	50                   	push   %eax
  800f83:	6a 00                	push   $0x0
  800f85:	e8 cf f6 ff ff       	call   800659 <read>
	if (r < 0)
  800f8a:	83 c4 10             	add    $0x10,%esp
  800f8d:	85 c0                	test   %eax,%eax
  800f8f:	78 08                	js     800f99 <getchar+0x22>
	if (r < 1)
  800f91:	85 c0                	test   %eax,%eax
  800f93:	7e 06                	jle    800f9b <getchar+0x24>
	return c;
  800f95:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800f99:	c9                   	leave  
  800f9a:	c3                   	ret    
		return -E_EOF;
  800f9b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800fa0:	eb f7                	jmp    800f99 <getchar+0x22>

00800fa2 <iscons>:
{
  800fa2:	55                   	push   %ebp
  800fa3:	89 e5                	mov    %esp,%ebp
  800fa5:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fa8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fab:	50                   	push   %eax
  800fac:	ff 75 08             	pushl  0x8(%ebp)
  800faf:	e8 34 f4 ff ff       	call   8003e8 <fd_lookup>
  800fb4:	83 c4 10             	add    $0x10,%esp
  800fb7:	85 c0                	test   %eax,%eax
  800fb9:	78 11                	js     800fcc <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  800fbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fbe:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fc4:	39 10                	cmp    %edx,(%eax)
  800fc6:	0f 94 c0             	sete   %al
  800fc9:	0f b6 c0             	movzbl %al,%eax
}
  800fcc:	c9                   	leave  
  800fcd:	c3                   	ret    

00800fce <opencons>:
{
  800fce:	55                   	push   %ebp
  800fcf:	89 e5                	mov    %esp,%ebp
  800fd1:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800fd4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fd7:	50                   	push   %eax
  800fd8:	e8 bc f3 ff ff       	call   800399 <fd_alloc>
  800fdd:	83 c4 10             	add    $0x10,%esp
  800fe0:	85 c0                	test   %eax,%eax
  800fe2:	78 3a                	js     80101e <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fe4:	83 ec 04             	sub    $0x4,%esp
  800fe7:	68 07 04 00 00       	push   $0x407
  800fec:	ff 75 f4             	pushl  -0xc(%ebp)
  800fef:	6a 00                	push   $0x0
  800ff1:	e8 8b f1 ff ff       	call   800181 <sys_page_alloc>
  800ff6:	83 c4 10             	add    $0x10,%esp
  800ff9:	85 c0                	test   %eax,%eax
  800ffb:	78 21                	js     80101e <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  800ffd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801000:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801006:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801008:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80100b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801012:	83 ec 0c             	sub    $0xc,%esp
  801015:	50                   	push   %eax
  801016:	e8 57 f3 ff ff       	call   800372 <fd2num>
  80101b:	83 c4 10             	add    $0x10,%esp
}
  80101e:	c9                   	leave  
  80101f:	c3                   	ret    

00801020 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801020:	55                   	push   %ebp
  801021:	89 e5                	mov    %esp,%ebp
  801023:	56                   	push   %esi
  801024:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801025:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801028:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80102e:	e8 10 f1 ff ff       	call   800143 <sys_getenvid>
  801033:	83 ec 0c             	sub    $0xc,%esp
  801036:	ff 75 0c             	pushl  0xc(%ebp)
  801039:	ff 75 08             	pushl  0x8(%ebp)
  80103c:	56                   	push   %esi
  80103d:	50                   	push   %eax
  80103e:	68 04 1f 80 00       	push   $0x801f04
  801043:	e8 b3 00 00 00       	call   8010fb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801048:	83 c4 18             	add    $0x18,%esp
  80104b:	53                   	push   %ebx
  80104c:	ff 75 10             	pushl  0x10(%ebp)
  80104f:	e8 56 00 00 00       	call   8010aa <vcprintf>
	cprintf("\n");
  801054:	c7 04 24 ef 1e 80 00 	movl   $0x801eef,(%esp)
  80105b:	e8 9b 00 00 00       	call   8010fb <cprintf>
  801060:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801063:	cc                   	int3   
  801064:	eb fd                	jmp    801063 <_panic+0x43>

00801066 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801066:	55                   	push   %ebp
  801067:	89 e5                	mov    %esp,%ebp
  801069:	53                   	push   %ebx
  80106a:	83 ec 04             	sub    $0x4,%esp
  80106d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801070:	8b 13                	mov    (%ebx),%edx
  801072:	8d 42 01             	lea    0x1(%edx),%eax
  801075:	89 03                	mov    %eax,(%ebx)
  801077:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80107a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80107e:	3d ff 00 00 00       	cmp    $0xff,%eax
  801083:	74 09                	je     80108e <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801085:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801089:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80108c:	c9                   	leave  
  80108d:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80108e:	83 ec 08             	sub    $0x8,%esp
  801091:	68 ff 00 00 00       	push   $0xff
  801096:	8d 43 08             	lea    0x8(%ebx),%eax
  801099:	50                   	push   %eax
  80109a:	e8 26 f0 ff ff       	call   8000c5 <sys_cputs>
		b->idx = 0;
  80109f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010a5:	83 c4 10             	add    $0x10,%esp
  8010a8:	eb db                	jmp    801085 <putch+0x1f>

008010aa <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010aa:	55                   	push   %ebp
  8010ab:	89 e5                	mov    %esp,%ebp
  8010ad:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010b3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010ba:	00 00 00 
	b.cnt = 0;
  8010bd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010c4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010c7:	ff 75 0c             	pushl  0xc(%ebp)
  8010ca:	ff 75 08             	pushl  0x8(%ebp)
  8010cd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010d3:	50                   	push   %eax
  8010d4:	68 66 10 80 00       	push   $0x801066
  8010d9:	e8 1a 01 00 00       	call   8011f8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010de:	83 c4 08             	add    $0x8,%esp
  8010e1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010e7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010ed:	50                   	push   %eax
  8010ee:	e8 d2 ef ff ff       	call   8000c5 <sys_cputs>

	return b.cnt;
}
  8010f3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010f9:	c9                   	leave  
  8010fa:	c3                   	ret    

008010fb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010fb:	55                   	push   %ebp
  8010fc:	89 e5                	mov    %esp,%ebp
  8010fe:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801101:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801104:	50                   	push   %eax
  801105:	ff 75 08             	pushl  0x8(%ebp)
  801108:	e8 9d ff ff ff       	call   8010aa <vcprintf>
	va_end(ap);

	return cnt;
}
  80110d:	c9                   	leave  
  80110e:	c3                   	ret    

0080110f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80110f:	55                   	push   %ebp
  801110:	89 e5                	mov    %esp,%ebp
  801112:	57                   	push   %edi
  801113:	56                   	push   %esi
  801114:	53                   	push   %ebx
  801115:	83 ec 1c             	sub    $0x1c,%esp
  801118:	89 c7                	mov    %eax,%edi
  80111a:	89 d6                	mov    %edx,%esi
  80111c:	8b 45 08             	mov    0x8(%ebp),%eax
  80111f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801122:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801125:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801128:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80112b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801130:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801133:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801136:	39 d3                	cmp    %edx,%ebx
  801138:	72 05                	jb     80113f <printnum+0x30>
  80113a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80113d:	77 7a                	ja     8011b9 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80113f:	83 ec 0c             	sub    $0xc,%esp
  801142:	ff 75 18             	pushl  0x18(%ebp)
  801145:	8b 45 14             	mov    0x14(%ebp),%eax
  801148:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80114b:	53                   	push   %ebx
  80114c:	ff 75 10             	pushl  0x10(%ebp)
  80114f:	83 ec 08             	sub    $0x8,%esp
  801152:	ff 75 e4             	pushl  -0x1c(%ebp)
  801155:	ff 75 e0             	pushl  -0x20(%ebp)
  801158:	ff 75 dc             	pushl  -0x24(%ebp)
  80115b:	ff 75 d8             	pushl  -0x28(%ebp)
  80115e:	e8 2d 0a 00 00       	call   801b90 <__udivdi3>
  801163:	83 c4 18             	add    $0x18,%esp
  801166:	52                   	push   %edx
  801167:	50                   	push   %eax
  801168:	89 f2                	mov    %esi,%edx
  80116a:	89 f8                	mov    %edi,%eax
  80116c:	e8 9e ff ff ff       	call   80110f <printnum>
  801171:	83 c4 20             	add    $0x20,%esp
  801174:	eb 13                	jmp    801189 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801176:	83 ec 08             	sub    $0x8,%esp
  801179:	56                   	push   %esi
  80117a:	ff 75 18             	pushl  0x18(%ebp)
  80117d:	ff d7                	call   *%edi
  80117f:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801182:	83 eb 01             	sub    $0x1,%ebx
  801185:	85 db                	test   %ebx,%ebx
  801187:	7f ed                	jg     801176 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801189:	83 ec 08             	sub    $0x8,%esp
  80118c:	56                   	push   %esi
  80118d:	83 ec 04             	sub    $0x4,%esp
  801190:	ff 75 e4             	pushl  -0x1c(%ebp)
  801193:	ff 75 e0             	pushl  -0x20(%ebp)
  801196:	ff 75 dc             	pushl  -0x24(%ebp)
  801199:	ff 75 d8             	pushl  -0x28(%ebp)
  80119c:	e8 0f 0b 00 00       	call   801cb0 <__umoddi3>
  8011a1:	83 c4 14             	add    $0x14,%esp
  8011a4:	0f be 80 27 1f 80 00 	movsbl 0x801f27(%eax),%eax
  8011ab:	50                   	push   %eax
  8011ac:	ff d7                	call   *%edi
}
  8011ae:	83 c4 10             	add    $0x10,%esp
  8011b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b4:	5b                   	pop    %ebx
  8011b5:	5e                   	pop    %esi
  8011b6:	5f                   	pop    %edi
  8011b7:	5d                   	pop    %ebp
  8011b8:	c3                   	ret    
  8011b9:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8011bc:	eb c4                	jmp    801182 <printnum+0x73>

008011be <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011be:	55                   	push   %ebp
  8011bf:	89 e5                	mov    %esp,%ebp
  8011c1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011c4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011c8:	8b 10                	mov    (%eax),%edx
  8011ca:	3b 50 04             	cmp    0x4(%eax),%edx
  8011cd:	73 0a                	jae    8011d9 <sprintputch+0x1b>
		*b->buf++ = ch;
  8011cf:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011d2:	89 08                	mov    %ecx,(%eax)
  8011d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d7:	88 02                	mov    %al,(%edx)
}
  8011d9:	5d                   	pop    %ebp
  8011da:	c3                   	ret    

008011db <printfmt>:
{
  8011db:	55                   	push   %ebp
  8011dc:	89 e5                	mov    %esp,%ebp
  8011de:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8011e1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011e4:	50                   	push   %eax
  8011e5:	ff 75 10             	pushl  0x10(%ebp)
  8011e8:	ff 75 0c             	pushl  0xc(%ebp)
  8011eb:	ff 75 08             	pushl  0x8(%ebp)
  8011ee:	e8 05 00 00 00       	call   8011f8 <vprintfmt>
}
  8011f3:	83 c4 10             	add    $0x10,%esp
  8011f6:	c9                   	leave  
  8011f7:	c3                   	ret    

008011f8 <vprintfmt>:
{
  8011f8:	55                   	push   %ebp
  8011f9:	89 e5                	mov    %esp,%ebp
  8011fb:	57                   	push   %edi
  8011fc:	56                   	push   %esi
  8011fd:	53                   	push   %ebx
  8011fe:	83 ec 2c             	sub    $0x2c,%esp
  801201:	8b 75 08             	mov    0x8(%ebp),%esi
  801204:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801207:	8b 7d 10             	mov    0x10(%ebp),%edi
  80120a:	e9 c1 03 00 00       	jmp    8015d0 <vprintfmt+0x3d8>
		padc = ' ';
  80120f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  801213:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  80121a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  801221:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  801228:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80122d:	8d 47 01             	lea    0x1(%edi),%eax
  801230:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801233:	0f b6 17             	movzbl (%edi),%edx
  801236:	8d 42 dd             	lea    -0x23(%edx),%eax
  801239:	3c 55                	cmp    $0x55,%al
  80123b:	0f 87 12 04 00 00    	ja     801653 <vprintfmt+0x45b>
  801241:	0f b6 c0             	movzbl %al,%eax
  801244:	ff 24 85 60 20 80 00 	jmp    *0x802060(,%eax,4)
  80124b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80124e:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  801252:	eb d9                	jmp    80122d <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  801254:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  801257:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80125b:	eb d0                	jmp    80122d <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80125d:	0f b6 d2             	movzbl %dl,%edx
  801260:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801263:	b8 00 00 00 00       	mov    $0x0,%eax
  801268:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80126b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80126e:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801272:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801275:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801278:	83 f9 09             	cmp    $0x9,%ecx
  80127b:	77 55                	ja     8012d2 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  80127d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801280:	eb e9                	jmp    80126b <vprintfmt+0x73>
			precision = va_arg(ap, int);
  801282:	8b 45 14             	mov    0x14(%ebp),%eax
  801285:	8b 00                	mov    (%eax),%eax
  801287:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80128a:	8b 45 14             	mov    0x14(%ebp),%eax
  80128d:	8d 40 04             	lea    0x4(%eax),%eax
  801290:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801293:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801296:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80129a:	79 91                	jns    80122d <vprintfmt+0x35>
				width = precision, precision = -1;
  80129c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80129f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8012a2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012a9:	eb 82                	jmp    80122d <vprintfmt+0x35>
  8012ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012ae:	85 c0                	test   %eax,%eax
  8012b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8012b5:	0f 49 d0             	cmovns %eax,%edx
  8012b8:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8012bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012be:	e9 6a ff ff ff       	jmp    80122d <vprintfmt+0x35>
  8012c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8012c6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012cd:	e9 5b ff ff ff       	jmp    80122d <vprintfmt+0x35>
  8012d2:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8012d5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012d8:	eb bc                	jmp    801296 <vprintfmt+0x9e>
			lflag++;
  8012da:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8012e0:	e9 48 ff ff ff       	jmp    80122d <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8012e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8012e8:	8d 78 04             	lea    0x4(%eax),%edi
  8012eb:	83 ec 08             	sub    $0x8,%esp
  8012ee:	53                   	push   %ebx
  8012ef:	ff 30                	pushl  (%eax)
  8012f1:	ff d6                	call   *%esi
			break;
  8012f3:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8012f6:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8012f9:	e9 cf 02 00 00       	jmp    8015cd <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8012fe:	8b 45 14             	mov    0x14(%ebp),%eax
  801301:	8d 78 04             	lea    0x4(%eax),%edi
  801304:	8b 00                	mov    (%eax),%eax
  801306:	99                   	cltd   
  801307:	31 d0                	xor    %edx,%eax
  801309:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80130b:	83 f8 0f             	cmp    $0xf,%eax
  80130e:	7f 23                	jg     801333 <vprintfmt+0x13b>
  801310:	8b 14 85 c0 21 80 00 	mov    0x8021c0(,%eax,4),%edx
  801317:	85 d2                	test   %edx,%edx
  801319:	74 18                	je     801333 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  80131b:	52                   	push   %edx
  80131c:	68 bd 1e 80 00       	push   $0x801ebd
  801321:	53                   	push   %ebx
  801322:	56                   	push   %esi
  801323:	e8 b3 fe ff ff       	call   8011db <printfmt>
  801328:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80132b:	89 7d 14             	mov    %edi,0x14(%ebp)
  80132e:	e9 9a 02 00 00       	jmp    8015cd <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  801333:	50                   	push   %eax
  801334:	68 3f 1f 80 00       	push   $0x801f3f
  801339:	53                   	push   %ebx
  80133a:	56                   	push   %esi
  80133b:	e8 9b fe ff ff       	call   8011db <printfmt>
  801340:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801343:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  801346:	e9 82 02 00 00       	jmp    8015cd <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  80134b:	8b 45 14             	mov    0x14(%ebp),%eax
  80134e:	83 c0 04             	add    $0x4,%eax
  801351:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801354:	8b 45 14             	mov    0x14(%ebp),%eax
  801357:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801359:	85 ff                	test   %edi,%edi
  80135b:	b8 38 1f 80 00       	mov    $0x801f38,%eax
  801360:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801363:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801367:	0f 8e bd 00 00 00    	jle    80142a <vprintfmt+0x232>
  80136d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801371:	75 0e                	jne    801381 <vprintfmt+0x189>
  801373:	89 75 08             	mov    %esi,0x8(%ebp)
  801376:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801379:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80137c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80137f:	eb 6d                	jmp    8013ee <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  801381:	83 ec 08             	sub    $0x8,%esp
  801384:	ff 75 d0             	pushl  -0x30(%ebp)
  801387:	57                   	push   %edi
  801388:	e8 6e 03 00 00       	call   8016fb <strnlen>
  80138d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801390:	29 c1                	sub    %eax,%ecx
  801392:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  801395:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801398:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80139c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80139f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8013a2:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8013a4:	eb 0f                	jmp    8013b5 <vprintfmt+0x1bd>
					putch(padc, putdat);
  8013a6:	83 ec 08             	sub    $0x8,%esp
  8013a9:	53                   	push   %ebx
  8013aa:	ff 75 e0             	pushl  -0x20(%ebp)
  8013ad:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8013af:	83 ef 01             	sub    $0x1,%edi
  8013b2:	83 c4 10             	add    $0x10,%esp
  8013b5:	85 ff                	test   %edi,%edi
  8013b7:	7f ed                	jg     8013a6 <vprintfmt+0x1ae>
  8013b9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8013bc:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8013bf:	85 c9                	test   %ecx,%ecx
  8013c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8013c6:	0f 49 c1             	cmovns %ecx,%eax
  8013c9:	29 c1                	sub    %eax,%ecx
  8013cb:	89 75 08             	mov    %esi,0x8(%ebp)
  8013ce:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8013d1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8013d4:	89 cb                	mov    %ecx,%ebx
  8013d6:	eb 16                	jmp    8013ee <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8013d8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8013dc:	75 31                	jne    80140f <vprintfmt+0x217>
					putch(ch, putdat);
  8013de:	83 ec 08             	sub    $0x8,%esp
  8013e1:	ff 75 0c             	pushl  0xc(%ebp)
  8013e4:	50                   	push   %eax
  8013e5:	ff 55 08             	call   *0x8(%ebp)
  8013e8:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8013eb:	83 eb 01             	sub    $0x1,%ebx
  8013ee:	83 c7 01             	add    $0x1,%edi
  8013f1:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8013f5:	0f be c2             	movsbl %dl,%eax
  8013f8:	85 c0                	test   %eax,%eax
  8013fa:	74 59                	je     801455 <vprintfmt+0x25d>
  8013fc:	85 f6                	test   %esi,%esi
  8013fe:	78 d8                	js     8013d8 <vprintfmt+0x1e0>
  801400:	83 ee 01             	sub    $0x1,%esi
  801403:	79 d3                	jns    8013d8 <vprintfmt+0x1e0>
  801405:	89 df                	mov    %ebx,%edi
  801407:	8b 75 08             	mov    0x8(%ebp),%esi
  80140a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80140d:	eb 37                	jmp    801446 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  80140f:	0f be d2             	movsbl %dl,%edx
  801412:	83 ea 20             	sub    $0x20,%edx
  801415:	83 fa 5e             	cmp    $0x5e,%edx
  801418:	76 c4                	jbe    8013de <vprintfmt+0x1e6>
					putch('?', putdat);
  80141a:	83 ec 08             	sub    $0x8,%esp
  80141d:	ff 75 0c             	pushl  0xc(%ebp)
  801420:	6a 3f                	push   $0x3f
  801422:	ff 55 08             	call   *0x8(%ebp)
  801425:	83 c4 10             	add    $0x10,%esp
  801428:	eb c1                	jmp    8013eb <vprintfmt+0x1f3>
  80142a:	89 75 08             	mov    %esi,0x8(%ebp)
  80142d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801430:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801433:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801436:	eb b6                	jmp    8013ee <vprintfmt+0x1f6>
				putch(' ', putdat);
  801438:	83 ec 08             	sub    $0x8,%esp
  80143b:	53                   	push   %ebx
  80143c:	6a 20                	push   $0x20
  80143e:	ff d6                	call   *%esi
			for (; width > 0; width--)
  801440:	83 ef 01             	sub    $0x1,%edi
  801443:	83 c4 10             	add    $0x10,%esp
  801446:	85 ff                	test   %edi,%edi
  801448:	7f ee                	jg     801438 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  80144a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80144d:	89 45 14             	mov    %eax,0x14(%ebp)
  801450:	e9 78 01 00 00       	jmp    8015cd <vprintfmt+0x3d5>
  801455:	89 df                	mov    %ebx,%edi
  801457:	8b 75 08             	mov    0x8(%ebp),%esi
  80145a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80145d:	eb e7                	jmp    801446 <vprintfmt+0x24e>
	if (lflag >= 2)
  80145f:	83 f9 01             	cmp    $0x1,%ecx
  801462:	7e 3f                	jle    8014a3 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  801464:	8b 45 14             	mov    0x14(%ebp),%eax
  801467:	8b 50 04             	mov    0x4(%eax),%edx
  80146a:	8b 00                	mov    (%eax),%eax
  80146c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80146f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801472:	8b 45 14             	mov    0x14(%ebp),%eax
  801475:	8d 40 08             	lea    0x8(%eax),%eax
  801478:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80147b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80147f:	79 5c                	jns    8014dd <vprintfmt+0x2e5>
				putch('-', putdat);
  801481:	83 ec 08             	sub    $0x8,%esp
  801484:	53                   	push   %ebx
  801485:	6a 2d                	push   $0x2d
  801487:	ff d6                	call   *%esi
				num = -(long long) num;
  801489:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80148c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80148f:	f7 da                	neg    %edx
  801491:	83 d1 00             	adc    $0x0,%ecx
  801494:	f7 d9                	neg    %ecx
  801496:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801499:	b8 0a 00 00 00       	mov    $0xa,%eax
  80149e:	e9 10 01 00 00       	jmp    8015b3 <vprintfmt+0x3bb>
	else if (lflag)
  8014a3:	85 c9                	test   %ecx,%ecx
  8014a5:	75 1b                	jne    8014c2 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8014a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8014aa:	8b 00                	mov    (%eax),%eax
  8014ac:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014af:	89 c1                	mov    %eax,%ecx
  8014b1:	c1 f9 1f             	sar    $0x1f,%ecx
  8014b4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ba:	8d 40 04             	lea    0x4(%eax),%eax
  8014bd:	89 45 14             	mov    %eax,0x14(%ebp)
  8014c0:	eb b9                	jmp    80147b <vprintfmt+0x283>
		return va_arg(*ap, long);
  8014c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8014c5:	8b 00                	mov    (%eax),%eax
  8014c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014ca:	89 c1                	mov    %eax,%ecx
  8014cc:	c1 f9 1f             	sar    $0x1f,%ecx
  8014cf:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8014d5:	8d 40 04             	lea    0x4(%eax),%eax
  8014d8:	89 45 14             	mov    %eax,0x14(%ebp)
  8014db:	eb 9e                	jmp    80147b <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8014dd:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014e0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8014e3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014e8:	e9 c6 00 00 00       	jmp    8015b3 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8014ed:	83 f9 01             	cmp    $0x1,%ecx
  8014f0:	7e 18                	jle    80150a <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8014f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f5:	8b 10                	mov    (%eax),%edx
  8014f7:	8b 48 04             	mov    0x4(%eax),%ecx
  8014fa:	8d 40 08             	lea    0x8(%eax),%eax
  8014fd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801500:	b8 0a 00 00 00       	mov    $0xa,%eax
  801505:	e9 a9 00 00 00       	jmp    8015b3 <vprintfmt+0x3bb>
	else if (lflag)
  80150a:	85 c9                	test   %ecx,%ecx
  80150c:	75 1a                	jne    801528 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  80150e:	8b 45 14             	mov    0x14(%ebp),%eax
  801511:	8b 10                	mov    (%eax),%edx
  801513:	b9 00 00 00 00       	mov    $0x0,%ecx
  801518:	8d 40 04             	lea    0x4(%eax),%eax
  80151b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80151e:	b8 0a 00 00 00       	mov    $0xa,%eax
  801523:	e9 8b 00 00 00       	jmp    8015b3 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  801528:	8b 45 14             	mov    0x14(%ebp),%eax
  80152b:	8b 10                	mov    (%eax),%edx
  80152d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801532:	8d 40 04             	lea    0x4(%eax),%eax
  801535:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801538:	b8 0a 00 00 00       	mov    $0xa,%eax
  80153d:	eb 74                	jmp    8015b3 <vprintfmt+0x3bb>
	if (lflag >= 2)
  80153f:	83 f9 01             	cmp    $0x1,%ecx
  801542:	7e 15                	jle    801559 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  801544:	8b 45 14             	mov    0x14(%ebp),%eax
  801547:	8b 10                	mov    (%eax),%edx
  801549:	8b 48 04             	mov    0x4(%eax),%ecx
  80154c:	8d 40 08             	lea    0x8(%eax),%eax
  80154f:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801552:	b8 08 00 00 00       	mov    $0x8,%eax
  801557:	eb 5a                	jmp    8015b3 <vprintfmt+0x3bb>
	else if (lflag)
  801559:	85 c9                	test   %ecx,%ecx
  80155b:	75 17                	jne    801574 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  80155d:	8b 45 14             	mov    0x14(%ebp),%eax
  801560:	8b 10                	mov    (%eax),%edx
  801562:	b9 00 00 00 00       	mov    $0x0,%ecx
  801567:	8d 40 04             	lea    0x4(%eax),%eax
  80156a:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80156d:	b8 08 00 00 00       	mov    $0x8,%eax
  801572:	eb 3f                	jmp    8015b3 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  801574:	8b 45 14             	mov    0x14(%ebp),%eax
  801577:	8b 10                	mov    (%eax),%edx
  801579:	b9 00 00 00 00       	mov    $0x0,%ecx
  80157e:	8d 40 04             	lea    0x4(%eax),%eax
  801581:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801584:	b8 08 00 00 00       	mov    $0x8,%eax
  801589:	eb 28                	jmp    8015b3 <vprintfmt+0x3bb>
			putch('0', putdat);
  80158b:	83 ec 08             	sub    $0x8,%esp
  80158e:	53                   	push   %ebx
  80158f:	6a 30                	push   $0x30
  801591:	ff d6                	call   *%esi
			putch('x', putdat);
  801593:	83 c4 08             	add    $0x8,%esp
  801596:	53                   	push   %ebx
  801597:	6a 78                	push   $0x78
  801599:	ff d6                	call   *%esi
			num = (unsigned long long)
  80159b:	8b 45 14             	mov    0x14(%ebp),%eax
  80159e:	8b 10                	mov    (%eax),%edx
  8015a0:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8015a5:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8015a8:	8d 40 04             	lea    0x4(%eax),%eax
  8015ab:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015ae:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8015b3:	83 ec 0c             	sub    $0xc,%esp
  8015b6:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015ba:	57                   	push   %edi
  8015bb:	ff 75 e0             	pushl  -0x20(%ebp)
  8015be:	50                   	push   %eax
  8015bf:	51                   	push   %ecx
  8015c0:	52                   	push   %edx
  8015c1:	89 da                	mov    %ebx,%edx
  8015c3:	89 f0                	mov    %esi,%eax
  8015c5:	e8 45 fb ff ff       	call   80110f <printnum>
			break;
  8015ca:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8015cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8015d0:	83 c7 01             	add    $0x1,%edi
  8015d3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8015d7:	83 f8 25             	cmp    $0x25,%eax
  8015da:	0f 84 2f fc ff ff    	je     80120f <vprintfmt+0x17>
			if (ch == '\0')
  8015e0:	85 c0                	test   %eax,%eax
  8015e2:	0f 84 8b 00 00 00    	je     801673 <vprintfmt+0x47b>
			putch(ch, putdat);
  8015e8:	83 ec 08             	sub    $0x8,%esp
  8015eb:	53                   	push   %ebx
  8015ec:	50                   	push   %eax
  8015ed:	ff d6                	call   *%esi
  8015ef:	83 c4 10             	add    $0x10,%esp
  8015f2:	eb dc                	jmp    8015d0 <vprintfmt+0x3d8>
	if (lflag >= 2)
  8015f4:	83 f9 01             	cmp    $0x1,%ecx
  8015f7:	7e 15                	jle    80160e <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  8015f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8015fc:	8b 10                	mov    (%eax),%edx
  8015fe:	8b 48 04             	mov    0x4(%eax),%ecx
  801601:	8d 40 08             	lea    0x8(%eax),%eax
  801604:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801607:	b8 10 00 00 00       	mov    $0x10,%eax
  80160c:	eb a5                	jmp    8015b3 <vprintfmt+0x3bb>
	else if (lflag)
  80160e:	85 c9                	test   %ecx,%ecx
  801610:	75 17                	jne    801629 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  801612:	8b 45 14             	mov    0x14(%ebp),%eax
  801615:	8b 10                	mov    (%eax),%edx
  801617:	b9 00 00 00 00       	mov    $0x0,%ecx
  80161c:	8d 40 04             	lea    0x4(%eax),%eax
  80161f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801622:	b8 10 00 00 00       	mov    $0x10,%eax
  801627:	eb 8a                	jmp    8015b3 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  801629:	8b 45 14             	mov    0x14(%ebp),%eax
  80162c:	8b 10                	mov    (%eax),%edx
  80162e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801633:	8d 40 04             	lea    0x4(%eax),%eax
  801636:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801639:	b8 10 00 00 00       	mov    $0x10,%eax
  80163e:	e9 70 ff ff ff       	jmp    8015b3 <vprintfmt+0x3bb>
			putch(ch, putdat);
  801643:	83 ec 08             	sub    $0x8,%esp
  801646:	53                   	push   %ebx
  801647:	6a 25                	push   $0x25
  801649:	ff d6                	call   *%esi
			break;
  80164b:	83 c4 10             	add    $0x10,%esp
  80164e:	e9 7a ff ff ff       	jmp    8015cd <vprintfmt+0x3d5>
			putch('%', putdat);
  801653:	83 ec 08             	sub    $0x8,%esp
  801656:	53                   	push   %ebx
  801657:	6a 25                	push   $0x25
  801659:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80165b:	83 c4 10             	add    $0x10,%esp
  80165e:	89 f8                	mov    %edi,%eax
  801660:	eb 03                	jmp    801665 <vprintfmt+0x46d>
  801662:	83 e8 01             	sub    $0x1,%eax
  801665:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801669:	75 f7                	jne    801662 <vprintfmt+0x46a>
  80166b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80166e:	e9 5a ff ff ff       	jmp    8015cd <vprintfmt+0x3d5>
}
  801673:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801676:	5b                   	pop    %ebx
  801677:	5e                   	pop    %esi
  801678:	5f                   	pop    %edi
  801679:	5d                   	pop    %ebp
  80167a:	c3                   	ret    

0080167b <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80167b:	55                   	push   %ebp
  80167c:	89 e5                	mov    %esp,%ebp
  80167e:	83 ec 18             	sub    $0x18,%esp
  801681:	8b 45 08             	mov    0x8(%ebp),%eax
  801684:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801687:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80168a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80168e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801691:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801698:	85 c0                	test   %eax,%eax
  80169a:	74 26                	je     8016c2 <vsnprintf+0x47>
  80169c:	85 d2                	test   %edx,%edx
  80169e:	7e 22                	jle    8016c2 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8016a0:	ff 75 14             	pushl  0x14(%ebp)
  8016a3:	ff 75 10             	pushl  0x10(%ebp)
  8016a6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8016a9:	50                   	push   %eax
  8016aa:	68 be 11 80 00       	push   $0x8011be
  8016af:	e8 44 fb ff ff       	call   8011f8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8016b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016b7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8016ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016bd:	83 c4 10             	add    $0x10,%esp
}
  8016c0:	c9                   	leave  
  8016c1:	c3                   	ret    
		return -E_INVAL;
  8016c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016c7:	eb f7                	jmp    8016c0 <vsnprintf+0x45>

008016c9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016c9:	55                   	push   %ebp
  8016ca:	89 e5                	mov    %esp,%ebp
  8016cc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016cf:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016d2:	50                   	push   %eax
  8016d3:	ff 75 10             	pushl  0x10(%ebp)
  8016d6:	ff 75 0c             	pushl  0xc(%ebp)
  8016d9:	ff 75 08             	pushl  0x8(%ebp)
  8016dc:	e8 9a ff ff ff       	call   80167b <vsnprintf>
	va_end(ap);

	return rc;
}
  8016e1:	c9                   	leave  
  8016e2:	c3                   	ret    

008016e3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016e3:	55                   	push   %ebp
  8016e4:	89 e5                	mov    %esp,%ebp
  8016e6:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8016ee:	eb 03                	jmp    8016f3 <strlen+0x10>
		n++;
  8016f0:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8016f3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016f7:	75 f7                	jne    8016f0 <strlen+0xd>
	return n;
}
  8016f9:	5d                   	pop    %ebp
  8016fa:	c3                   	ret    

008016fb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016fb:	55                   	push   %ebp
  8016fc:	89 e5                	mov    %esp,%ebp
  8016fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801701:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801704:	b8 00 00 00 00       	mov    $0x0,%eax
  801709:	eb 03                	jmp    80170e <strnlen+0x13>
		n++;
  80170b:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80170e:	39 d0                	cmp    %edx,%eax
  801710:	74 06                	je     801718 <strnlen+0x1d>
  801712:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801716:	75 f3                	jne    80170b <strnlen+0x10>
	return n;
}
  801718:	5d                   	pop    %ebp
  801719:	c3                   	ret    

0080171a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80171a:	55                   	push   %ebp
  80171b:	89 e5                	mov    %esp,%ebp
  80171d:	53                   	push   %ebx
  80171e:	8b 45 08             	mov    0x8(%ebp),%eax
  801721:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801724:	89 c2                	mov    %eax,%edx
  801726:	83 c1 01             	add    $0x1,%ecx
  801729:	83 c2 01             	add    $0x1,%edx
  80172c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801730:	88 5a ff             	mov    %bl,-0x1(%edx)
  801733:	84 db                	test   %bl,%bl
  801735:	75 ef                	jne    801726 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801737:	5b                   	pop    %ebx
  801738:	5d                   	pop    %ebp
  801739:	c3                   	ret    

0080173a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80173a:	55                   	push   %ebp
  80173b:	89 e5                	mov    %esp,%ebp
  80173d:	53                   	push   %ebx
  80173e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801741:	53                   	push   %ebx
  801742:	e8 9c ff ff ff       	call   8016e3 <strlen>
  801747:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80174a:	ff 75 0c             	pushl  0xc(%ebp)
  80174d:	01 d8                	add    %ebx,%eax
  80174f:	50                   	push   %eax
  801750:	e8 c5 ff ff ff       	call   80171a <strcpy>
	return dst;
}
  801755:	89 d8                	mov    %ebx,%eax
  801757:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80175a:	c9                   	leave  
  80175b:	c3                   	ret    

0080175c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80175c:	55                   	push   %ebp
  80175d:	89 e5                	mov    %esp,%ebp
  80175f:	56                   	push   %esi
  801760:	53                   	push   %ebx
  801761:	8b 75 08             	mov    0x8(%ebp),%esi
  801764:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801767:	89 f3                	mov    %esi,%ebx
  801769:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80176c:	89 f2                	mov    %esi,%edx
  80176e:	eb 0f                	jmp    80177f <strncpy+0x23>
		*dst++ = *src;
  801770:	83 c2 01             	add    $0x1,%edx
  801773:	0f b6 01             	movzbl (%ecx),%eax
  801776:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801779:	80 39 01             	cmpb   $0x1,(%ecx)
  80177c:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80177f:	39 da                	cmp    %ebx,%edx
  801781:	75 ed                	jne    801770 <strncpy+0x14>
	}
	return ret;
}
  801783:	89 f0                	mov    %esi,%eax
  801785:	5b                   	pop    %ebx
  801786:	5e                   	pop    %esi
  801787:	5d                   	pop    %ebp
  801788:	c3                   	ret    

00801789 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801789:	55                   	push   %ebp
  80178a:	89 e5                	mov    %esp,%ebp
  80178c:	56                   	push   %esi
  80178d:	53                   	push   %ebx
  80178e:	8b 75 08             	mov    0x8(%ebp),%esi
  801791:	8b 55 0c             	mov    0xc(%ebp),%edx
  801794:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801797:	89 f0                	mov    %esi,%eax
  801799:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80179d:	85 c9                	test   %ecx,%ecx
  80179f:	75 0b                	jne    8017ac <strlcpy+0x23>
  8017a1:	eb 17                	jmp    8017ba <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8017a3:	83 c2 01             	add    $0x1,%edx
  8017a6:	83 c0 01             	add    $0x1,%eax
  8017a9:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8017ac:	39 d8                	cmp    %ebx,%eax
  8017ae:	74 07                	je     8017b7 <strlcpy+0x2e>
  8017b0:	0f b6 0a             	movzbl (%edx),%ecx
  8017b3:	84 c9                	test   %cl,%cl
  8017b5:	75 ec                	jne    8017a3 <strlcpy+0x1a>
		*dst = '\0';
  8017b7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8017ba:	29 f0                	sub    %esi,%eax
}
  8017bc:	5b                   	pop    %ebx
  8017bd:	5e                   	pop    %esi
  8017be:	5d                   	pop    %ebp
  8017bf:	c3                   	ret    

008017c0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017c0:	55                   	push   %ebp
  8017c1:	89 e5                	mov    %esp,%ebp
  8017c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017c6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017c9:	eb 06                	jmp    8017d1 <strcmp+0x11>
		p++, q++;
  8017cb:	83 c1 01             	add    $0x1,%ecx
  8017ce:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8017d1:	0f b6 01             	movzbl (%ecx),%eax
  8017d4:	84 c0                	test   %al,%al
  8017d6:	74 04                	je     8017dc <strcmp+0x1c>
  8017d8:	3a 02                	cmp    (%edx),%al
  8017da:	74 ef                	je     8017cb <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017dc:	0f b6 c0             	movzbl %al,%eax
  8017df:	0f b6 12             	movzbl (%edx),%edx
  8017e2:	29 d0                	sub    %edx,%eax
}
  8017e4:	5d                   	pop    %ebp
  8017e5:	c3                   	ret    

008017e6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017e6:	55                   	push   %ebp
  8017e7:	89 e5                	mov    %esp,%ebp
  8017e9:	53                   	push   %ebx
  8017ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017f0:	89 c3                	mov    %eax,%ebx
  8017f2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017f5:	eb 06                	jmp    8017fd <strncmp+0x17>
		n--, p++, q++;
  8017f7:	83 c0 01             	add    $0x1,%eax
  8017fa:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8017fd:	39 d8                	cmp    %ebx,%eax
  8017ff:	74 16                	je     801817 <strncmp+0x31>
  801801:	0f b6 08             	movzbl (%eax),%ecx
  801804:	84 c9                	test   %cl,%cl
  801806:	74 04                	je     80180c <strncmp+0x26>
  801808:	3a 0a                	cmp    (%edx),%cl
  80180a:	74 eb                	je     8017f7 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80180c:	0f b6 00             	movzbl (%eax),%eax
  80180f:	0f b6 12             	movzbl (%edx),%edx
  801812:	29 d0                	sub    %edx,%eax
}
  801814:	5b                   	pop    %ebx
  801815:	5d                   	pop    %ebp
  801816:	c3                   	ret    
		return 0;
  801817:	b8 00 00 00 00       	mov    $0x0,%eax
  80181c:	eb f6                	jmp    801814 <strncmp+0x2e>

0080181e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80181e:	55                   	push   %ebp
  80181f:	89 e5                	mov    %esp,%ebp
  801821:	8b 45 08             	mov    0x8(%ebp),%eax
  801824:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801828:	0f b6 10             	movzbl (%eax),%edx
  80182b:	84 d2                	test   %dl,%dl
  80182d:	74 09                	je     801838 <strchr+0x1a>
		if (*s == c)
  80182f:	38 ca                	cmp    %cl,%dl
  801831:	74 0a                	je     80183d <strchr+0x1f>
	for (; *s; s++)
  801833:	83 c0 01             	add    $0x1,%eax
  801836:	eb f0                	jmp    801828 <strchr+0xa>
			return (char *) s;
	return 0;
  801838:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80183d:	5d                   	pop    %ebp
  80183e:	c3                   	ret    

0080183f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80183f:	55                   	push   %ebp
  801840:	89 e5                	mov    %esp,%ebp
  801842:	8b 45 08             	mov    0x8(%ebp),%eax
  801845:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801849:	eb 03                	jmp    80184e <strfind+0xf>
  80184b:	83 c0 01             	add    $0x1,%eax
  80184e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801851:	38 ca                	cmp    %cl,%dl
  801853:	74 04                	je     801859 <strfind+0x1a>
  801855:	84 d2                	test   %dl,%dl
  801857:	75 f2                	jne    80184b <strfind+0xc>
			break;
	return (char *) s;
}
  801859:	5d                   	pop    %ebp
  80185a:	c3                   	ret    

0080185b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80185b:	55                   	push   %ebp
  80185c:	89 e5                	mov    %esp,%ebp
  80185e:	57                   	push   %edi
  80185f:	56                   	push   %esi
  801860:	53                   	push   %ebx
  801861:	8b 7d 08             	mov    0x8(%ebp),%edi
  801864:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801867:	85 c9                	test   %ecx,%ecx
  801869:	74 13                	je     80187e <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80186b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801871:	75 05                	jne    801878 <memset+0x1d>
  801873:	f6 c1 03             	test   $0x3,%cl
  801876:	74 0d                	je     801885 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801878:	8b 45 0c             	mov    0xc(%ebp),%eax
  80187b:	fc                   	cld    
  80187c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80187e:	89 f8                	mov    %edi,%eax
  801880:	5b                   	pop    %ebx
  801881:	5e                   	pop    %esi
  801882:	5f                   	pop    %edi
  801883:	5d                   	pop    %ebp
  801884:	c3                   	ret    
		c &= 0xFF;
  801885:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801889:	89 d3                	mov    %edx,%ebx
  80188b:	c1 e3 08             	shl    $0x8,%ebx
  80188e:	89 d0                	mov    %edx,%eax
  801890:	c1 e0 18             	shl    $0x18,%eax
  801893:	89 d6                	mov    %edx,%esi
  801895:	c1 e6 10             	shl    $0x10,%esi
  801898:	09 f0                	or     %esi,%eax
  80189a:	09 c2                	or     %eax,%edx
  80189c:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  80189e:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8018a1:	89 d0                	mov    %edx,%eax
  8018a3:	fc                   	cld    
  8018a4:	f3 ab                	rep stos %eax,%es:(%edi)
  8018a6:	eb d6                	jmp    80187e <memset+0x23>

008018a8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8018a8:	55                   	push   %ebp
  8018a9:	89 e5                	mov    %esp,%ebp
  8018ab:	57                   	push   %edi
  8018ac:	56                   	push   %esi
  8018ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018b3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018b6:	39 c6                	cmp    %eax,%esi
  8018b8:	73 35                	jae    8018ef <memmove+0x47>
  8018ba:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018bd:	39 c2                	cmp    %eax,%edx
  8018bf:	76 2e                	jbe    8018ef <memmove+0x47>
		s += n;
		d += n;
  8018c1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018c4:	89 d6                	mov    %edx,%esi
  8018c6:	09 fe                	or     %edi,%esi
  8018c8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018ce:	74 0c                	je     8018dc <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8018d0:	83 ef 01             	sub    $0x1,%edi
  8018d3:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8018d6:	fd                   	std    
  8018d7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018d9:	fc                   	cld    
  8018da:	eb 21                	jmp    8018fd <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018dc:	f6 c1 03             	test   $0x3,%cl
  8018df:	75 ef                	jne    8018d0 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8018e1:	83 ef 04             	sub    $0x4,%edi
  8018e4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018e7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8018ea:	fd                   	std    
  8018eb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018ed:	eb ea                	jmp    8018d9 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018ef:	89 f2                	mov    %esi,%edx
  8018f1:	09 c2                	or     %eax,%edx
  8018f3:	f6 c2 03             	test   $0x3,%dl
  8018f6:	74 09                	je     801901 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018f8:	89 c7                	mov    %eax,%edi
  8018fa:	fc                   	cld    
  8018fb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018fd:	5e                   	pop    %esi
  8018fe:	5f                   	pop    %edi
  8018ff:	5d                   	pop    %ebp
  801900:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801901:	f6 c1 03             	test   $0x3,%cl
  801904:	75 f2                	jne    8018f8 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801906:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801909:	89 c7                	mov    %eax,%edi
  80190b:	fc                   	cld    
  80190c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80190e:	eb ed                	jmp    8018fd <memmove+0x55>

00801910 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801910:	55                   	push   %ebp
  801911:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801913:	ff 75 10             	pushl  0x10(%ebp)
  801916:	ff 75 0c             	pushl  0xc(%ebp)
  801919:	ff 75 08             	pushl  0x8(%ebp)
  80191c:	e8 87 ff ff ff       	call   8018a8 <memmove>
}
  801921:	c9                   	leave  
  801922:	c3                   	ret    

00801923 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801923:	55                   	push   %ebp
  801924:	89 e5                	mov    %esp,%ebp
  801926:	56                   	push   %esi
  801927:	53                   	push   %ebx
  801928:	8b 45 08             	mov    0x8(%ebp),%eax
  80192b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80192e:	89 c6                	mov    %eax,%esi
  801930:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801933:	39 f0                	cmp    %esi,%eax
  801935:	74 1c                	je     801953 <memcmp+0x30>
		if (*s1 != *s2)
  801937:	0f b6 08             	movzbl (%eax),%ecx
  80193a:	0f b6 1a             	movzbl (%edx),%ebx
  80193d:	38 d9                	cmp    %bl,%cl
  80193f:	75 08                	jne    801949 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801941:	83 c0 01             	add    $0x1,%eax
  801944:	83 c2 01             	add    $0x1,%edx
  801947:	eb ea                	jmp    801933 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  801949:	0f b6 c1             	movzbl %cl,%eax
  80194c:	0f b6 db             	movzbl %bl,%ebx
  80194f:	29 d8                	sub    %ebx,%eax
  801951:	eb 05                	jmp    801958 <memcmp+0x35>
	}

	return 0;
  801953:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801958:	5b                   	pop    %ebx
  801959:	5e                   	pop    %esi
  80195a:	5d                   	pop    %ebp
  80195b:	c3                   	ret    

0080195c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80195c:	55                   	push   %ebp
  80195d:	89 e5                	mov    %esp,%ebp
  80195f:	8b 45 08             	mov    0x8(%ebp),%eax
  801962:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801965:	89 c2                	mov    %eax,%edx
  801967:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80196a:	39 d0                	cmp    %edx,%eax
  80196c:	73 09                	jae    801977 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80196e:	38 08                	cmp    %cl,(%eax)
  801970:	74 05                	je     801977 <memfind+0x1b>
	for (; s < ends; s++)
  801972:	83 c0 01             	add    $0x1,%eax
  801975:	eb f3                	jmp    80196a <memfind+0xe>
			break;
	return (void *) s;
}
  801977:	5d                   	pop    %ebp
  801978:	c3                   	ret    

00801979 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801979:	55                   	push   %ebp
  80197a:	89 e5                	mov    %esp,%ebp
  80197c:	57                   	push   %edi
  80197d:	56                   	push   %esi
  80197e:	53                   	push   %ebx
  80197f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801982:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801985:	eb 03                	jmp    80198a <strtol+0x11>
		s++;
  801987:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  80198a:	0f b6 01             	movzbl (%ecx),%eax
  80198d:	3c 20                	cmp    $0x20,%al
  80198f:	74 f6                	je     801987 <strtol+0xe>
  801991:	3c 09                	cmp    $0x9,%al
  801993:	74 f2                	je     801987 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  801995:	3c 2b                	cmp    $0x2b,%al
  801997:	74 2e                	je     8019c7 <strtol+0x4e>
	int neg = 0;
  801999:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  80199e:	3c 2d                	cmp    $0x2d,%al
  8019a0:	74 2f                	je     8019d1 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019a2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8019a8:	75 05                	jne    8019af <strtol+0x36>
  8019aa:	80 39 30             	cmpb   $0x30,(%ecx)
  8019ad:	74 2c                	je     8019db <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019af:	85 db                	test   %ebx,%ebx
  8019b1:	75 0a                	jne    8019bd <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019b3:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  8019b8:	80 39 30             	cmpb   $0x30,(%ecx)
  8019bb:	74 28                	je     8019e5 <strtol+0x6c>
		base = 10;
  8019bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c2:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8019c5:	eb 50                	jmp    801a17 <strtol+0x9e>
		s++;
  8019c7:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  8019ca:	bf 00 00 00 00       	mov    $0x0,%edi
  8019cf:	eb d1                	jmp    8019a2 <strtol+0x29>
		s++, neg = 1;
  8019d1:	83 c1 01             	add    $0x1,%ecx
  8019d4:	bf 01 00 00 00       	mov    $0x1,%edi
  8019d9:	eb c7                	jmp    8019a2 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019db:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019df:	74 0e                	je     8019ef <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8019e1:	85 db                	test   %ebx,%ebx
  8019e3:	75 d8                	jne    8019bd <strtol+0x44>
		s++, base = 8;
  8019e5:	83 c1 01             	add    $0x1,%ecx
  8019e8:	bb 08 00 00 00       	mov    $0x8,%ebx
  8019ed:	eb ce                	jmp    8019bd <strtol+0x44>
		s += 2, base = 16;
  8019ef:	83 c1 02             	add    $0x2,%ecx
  8019f2:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019f7:	eb c4                	jmp    8019bd <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  8019f9:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019fc:	89 f3                	mov    %esi,%ebx
  8019fe:	80 fb 19             	cmp    $0x19,%bl
  801a01:	77 29                	ja     801a2c <strtol+0xb3>
			dig = *s - 'a' + 10;
  801a03:	0f be d2             	movsbl %dl,%edx
  801a06:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801a09:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a0c:	7d 30                	jge    801a3e <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801a0e:	83 c1 01             	add    $0x1,%ecx
  801a11:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a15:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801a17:	0f b6 11             	movzbl (%ecx),%edx
  801a1a:	8d 72 d0             	lea    -0x30(%edx),%esi
  801a1d:	89 f3                	mov    %esi,%ebx
  801a1f:	80 fb 09             	cmp    $0x9,%bl
  801a22:	77 d5                	ja     8019f9 <strtol+0x80>
			dig = *s - '0';
  801a24:	0f be d2             	movsbl %dl,%edx
  801a27:	83 ea 30             	sub    $0x30,%edx
  801a2a:	eb dd                	jmp    801a09 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  801a2c:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a2f:	89 f3                	mov    %esi,%ebx
  801a31:	80 fb 19             	cmp    $0x19,%bl
  801a34:	77 08                	ja     801a3e <strtol+0xc5>
			dig = *s - 'A' + 10;
  801a36:	0f be d2             	movsbl %dl,%edx
  801a39:	83 ea 37             	sub    $0x37,%edx
  801a3c:	eb cb                	jmp    801a09 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  801a3e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a42:	74 05                	je     801a49 <strtol+0xd0>
		*endptr = (char *) s;
  801a44:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a47:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801a49:	89 c2                	mov    %eax,%edx
  801a4b:	f7 da                	neg    %edx
  801a4d:	85 ff                	test   %edi,%edi
  801a4f:	0f 45 c2             	cmovne %edx,%eax
}
  801a52:	5b                   	pop    %ebx
  801a53:	5e                   	pop    %esi
  801a54:	5f                   	pop    %edi
  801a55:	5d                   	pop    %ebp
  801a56:	c3                   	ret    

00801a57 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a57:	55                   	push   %ebp
  801a58:	89 e5                	mov    %esp,%ebp
  801a5a:	56                   	push   %esi
  801a5b:	53                   	push   %ebx
  801a5c:	8b 75 08             	mov    0x8(%ebp),%esi
  801a5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a62:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  801a65:	85 f6                	test   %esi,%esi
  801a67:	74 06                	je     801a6f <ipc_recv+0x18>
  801a69:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801a6f:	85 db                	test   %ebx,%ebx
  801a71:	74 06                	je     801a79 <ipc_recv+0x22>
  801a73:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801a79:	85 c0                	test   %eax,%eax
  801a7b:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801a80:	0f 44 c2             	cmove  %edx,%eax
	int ret = sys_ipc_recv(pg);
  801a83:	83 ec 0c             	sub    $0xc,%esp
  801a86:	50                   	push   %eax
  801a87:	e8 a5 e8 ff ff       	call   800331 <sys_ipc_recv>
	if (ret) return ret;
  801a8c:	83 c4 10             	add    $0x10,%esp
  801a8f:	85 c0                	test   %eax,%eax
  801a91:	75 24                	jne    801ab7 <ipc_recv+0x60>
	if (from_env_store)
  801a93:	85 f6                	test   %esi,%esi
  801a95:	74 0a                	je     801aa1 <ipc_recv+0x4a>
		*from_env_store = thisenv->env_ipc_from;
  801a97:	a1 04 40 80 00       	mov    0x804004,%eax
  801a9c:	8b 40 74             	mov    0x74(%eax),%eax
  801a9f:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801aa1:	85 db                	test   %ebx,%ebx
  801aa3:	74 0a                	je     801aaf <ipc_recv+0x58>
		*perm_store = thisenv->env_ipc_perm;
  801aa5:	a1 04 40 80 00       	mov    0x804004,%eax
  801aaa:	8b 40 78             	mov    0x78(%eax),%eax
  801aad:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801aaf:	a1 04 40 80 00       	mov    0x804004,%eax
  801ab4:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ab7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aba:	5b                   	pop    %ebx
  801abb:	5e                   	pop    %esi
  801abc:	5d                   	pop    %ebp
  801abd:	c3                   	ret    

00801abe <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801abe:	55                   	push   %ebp
  801abf:	89 e5                	mov    %esp,%ebp
  801ac1:	57                   	push   %edi
  801ac2:	56                   	push   %esi
  801ac3:	53                   	push   %ebx
  801ac4:	83 ec 0c             	sub    $0xc,%esp
  801ac7:	8b 7d 08             	mov    0x8(%ebp),%edi
  801aca:	8b 75 0c             	mov    0xc(%ebp),%esi
  801acd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  801ad0:	85 db                	test   %ebx,%ebx
  801ad2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801ad7:	0f 44 d8             	cmove  %eax,%ebx
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801ada:	ff 75 14             	pushl  0x14(%ebp)
  801add:	53                   	push   %ebx
  801ade:	56                   	push   %esi
  801adf:	57                   	push   %edi
  801ae0:	e8 29 e8 ff ff       	call   80030e <sys_ipc_try_send>
  801ae5:	83 c4 10             	add    $0x10,%esp
  801ae8:	85 c0                	test   %eax,%eax
  801aea:	74 1e                	je     801b0a <ipc_send+0x4c>
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801aec:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801aef:	75 07                	jne    801af8 <ipc_send+0x3a>
		sys_yield();
  801af1:	e8 6c e6 ff ff       	call   800162 <sys_yield>
  801af6:	eb e2                	jmp    801ada <ipc_send+0x1c>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801af8:	50                   	push   %eax
  801af9:	68 20 22 80 00       	push   $0x802220
  801afe:	6a 36                	push   $0x36
  801b00:	68 37 22 80 00       	push   $0x802237
  801b05:	e8 16 f5 ff ff       	call   801020 <_panic>
	}
}
  801b0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b0d:	5b                   	pop    %ebx
  801b0e:	5e                   	pop    %esi
  801b0f:	5f                   	pop    %edi
  801b10:	5d                   	pop    %ebp
  801b11:	c3                   	ret    

00801b12 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b12:	55                   	push   %ebp
  801b13:	89 e5                	mov    %esp,%ebp
  801b15:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b18:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b1d:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b20:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b26:	8b 52 50             	mov    0x50(%edx),%edx
  801b29:	39 ca                	cmp    %ecx,%edx
  801b2b:	74 11                	je     801b3e <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801b2d:	83 c0 01             	add    $0x1,%eax
  801b30:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b35:	75 e6                	jne    801b1d <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801b37:	b8 00 00 00 00       	mov    $0x0,%eax
  801b3c:	eb 0b                	jmp    801b49 <ipc_find_env+0x37>
			return envs[i].env_id;
  801b3e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b41:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b46:	8b 40 48             	mov    0x48(%eax),%eax
}
  801b49:	5d                   	pop    %ebp
  801b4a:	c3                   	ret    

00801b4b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b4b:	55                   	push   %ebp
  801b4c:	89 e5                	mov    %esp,%ebp
  801b4e:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b51:	89 d0                	mov    %edx,%eax
  801b53:	c1 e8 16             	shr    $0x16,%eax
  801b56:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b5d:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801b62:	f6 c1 01             	test   $0x1,%cl
  801b65:	74 1d                	je     801b84 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801b67:	c1 ea 0c             	shr    $0xc,%edx
  801b6a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b71:	f6 c2 01             	test   $0x1,%dl
  801b74:	74 0e                	je     801b84 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b76:	c1 ea 0c             	shr    $0xc,%edx
  801b79:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b80:	ef 
  801b81:	0f b7 c0             	movzwl %ax,%eax
}
  801b84:	5d                   	pop    %ebp
  801b85:	c3                   	ret    
  801b86:	66 90                	xchg   %ax,%ax
  801b88:	66 90                	xchg   %ax,%ax
  801b8a:	66 90                	xchg   %ax,%ax
  801b8c:	66 90                	xchg   %ax,%ax
  801b8e:	66 90                	xchg   %ax,%ax

00801b90 <__udivdi3>:
  801b90:	55                   	push   %ebp
  801b91:	57                   	push   %edi
  801b92:	56                   	push   %esi
  801b93:	53                   	push   %ebx
  801b94:	83 ec 1c             	sub    $0x1c,%esp
  801b97:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801b9b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801b9f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801ba3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801ba7:	85 d2                	test   %edx,%edx
  801ba9:	75 35                	jne    801be0 <__udivdi3+0x50>
  801bab:	39 f3                	cmp    %esi,%ebx
  801bad:	0f 87 bd 00 00 00    	ja     801c70 <__udivdi3+0xe0>
  801bb3:	85 db                	test   %ebx,%ebx
  801bb5:	89 d9                	mov    %ebx,%ecx
  801bb7:	75 0b                	jne    801bc4 <__udivdi3+0x34>
  801bb9:	b8 01 00 00 00       	mov    $0x1,%eax
  801bbe:	31 d2                	xor    %edx,%edx
  801bc0:	f7 f3                	div    %ebx
  801bc2:	89 c1                	mov    %eax,%ecx
  801bc4:	31 d2                	xor    %edx,%edx
  801bc6:	89 f0                	mov    %esi,%eax
  801bc8:	f7 f1                	div    %ecx
  801bca:	89 c6                	mov    %eax,%esi
  801bcc:	89 e8                	mov    %ebp,%eax
  801bce:	89 f7                	mov    %esi,%edi
  801bd0:	f7 f1                	div    %ecx
  801bd2:	89 fa                	mov    %edi,%edx
  801bd4:	83 c4 1c             	add    $0x1c,%esp
  801bd7:	5b                   	pop    %ebx
  801bd8:	5e                   	pop    %esi
  801bd9:	5f                   	pop    %edi
  801bda:	5d                   	pop    %ebp
  801bdb:	c3                   	ret    
  801bdc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801be0:	39 f2                	cmp    %esi,%edx
  801be2:	77 7c                	ja     801c60 <__udivdi3+0xd0>
  801be4:	0f bd fa             	bsr    %edx,%edi
  801be7:	83 f7 1f             	xor    $0x1f,%edi
  801bea:	0f 84 98 00 00 00    	je     801c88 <__udivdi3+0xf8>
  801bf0:	89 f9                	mov    %edi,%ecx
  801bf2:	b8 20 00 00 00       	mov    $0x20,%eax
  801bf7:	29 f8                	sub    %edi,%eax
  801bf9:	d3 e2                	shl    %cl,%edx
  801bfb:	89 54 24 08          	mov    %edx,0x8(%esp)
  801bff:	89 c1                	mov    %eax,%ecx
  801c01:	89 da                	mov    %ebx,%edx
  801c03:	d3 ea                	shr    %cl,%edx
  801c05:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801c09:	09 d1                	or     %edx,%ecx
  801c0b:	89 f2                	mov    %esi,%edx
  801c0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c11:	89 f9                	mov    %edi,%ecx
  801c13:	d3 e3                	shl    %cl,%ebx
  801c15:	89 c1                	mov    %eax,%ecx
  801c17:	d3 ea                	shr    %cl,%edx
  801c19:	89 f9                	mov    %edi,%ecx
  801c1b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c1f:	d3 e6                	shl    %cl,%esi
  801c21:	89 eb                	mov    %ebp,%ebx
  801c23:	89 c1                	mov    %eax,%ecx
  801c25:	d3 eb                	shr    %cl,%ebx
  801c27:	09 de                	or     %ebx,%esi
  801c29:	89 f0                	mov    %esi,%eax
  801c2b:	f7 74 24 08          	divl   0x8(%esp)
  801c2f:	89 d6                	mov    %edx,%esi
  801c31:	89 c3                	mov    %eax,%ebx
  801c33:	f7 64 24 0c          	mull   0xc(%esp)
  801c37:	39 d6                	cmp    %edx,%esi
  801c39:	72 0c                	jb     801c47 <__udivdi3+0xb7>
  801c3b:	89 f9                	mov    %edi,%ecx
  801c3d:	d3 e5                	shl    %cl,%ebp
  801c3f:	39 c5                	cmp    %eax,%ebp
  801c41:	73 5d                	jae    801ca0 <__udivdi3+0x110>
  801c43:	39 d6                	cmp    %edx,%esi
  801c45:	75 59                	jne    801ca0 <__udivdi3+0x110>
  801c47:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801c4a:	31 ff                	xor    %edi,%edi
  801c4c:	89 fa                	mov    %edi,%edx
  801c4e:	83 c4 1c             	add    $0x1c,%esp
  801c51:	5b                   	pop    %ebx
  801c52:	5e                   	pop    %esi
  801c53:	5f                   	pop    %edi
  801c54:	5d                   	pop    %ebp
  801c55:	c3                   	ret    
  801c56:	8d 76 00             	lea    0x0(%esi),%esi
  801c59:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801c60:	31 ff                	xor    %edi,%edi
  801c62:	31 c0                	xor    %eax,%eax
  801c64:	89 fa                	mov    %edi,%edx
  801c66:	83 c4 1c             	add    $0x1c,%esp
  801c69:	5b                   	pop    %ebx
  801c6a:	5e                   	pop    %esi
  801c6b:	5f                   	pop    %edi
  801c6c:	5d                   	pop    %ebp
  801c6d:	c3                   	ret    
  801c6e:	66 90                	xchg   %ax,%ax
  801c70:	31 ff                	xor    %edi,%edi
  801c72:	89 e8                	mov    %ebp,%eax
  801c74:	89 f2                	mov    %esi,%edx
  801c76:	f7 f3                	div    %ebx
  801c78:	89 fa                	mov    %edi,%edx
  801c7a:	83 c4 1c             	add    $0x1c,%esp
  801c7d:	5b                   	pop    %ebx
  801c7e:	5e                   	pop    %esi
  801c7f:	5f                   	pop    %edi
  801c80:	5d                   	pop    %ebp
  801c81:	c3                   	ret    
  801c82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c88:	39 f2                	cmp    %esi,%edx
  801c8a:	72 06                	jb     801c92 <__udivdi3+0x102>
  801c8c:	31 c0                	xor    %eax,%eax
  801c8e:	39 eb                	cmp    %ebp,%ebx
  801c90:	77 d2                	ja     801c64 <__udivdi3+0xd4>
  801c92:	b8 01 00 00 00       	mov    $0x1,%eax
  801c97:	eb cb                	jmp    801c64 <__udivdi3+0xd4>
  801c99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ca0:	89 d8                	mov    %ebx,%eax
  801ca2:	31 ff                	xor    %edi,%edi
  801ca4:	eb be                	jmp    801c64 <__udivdi3+0xd4>
  801ca6:	66 90                	xchg   %ax,%ax
  801ca8:	66 90                	xchg   %ax,%ax
  801caa:	66 90                	xchg   %ax,%ax
  801cac:	66 90                	xchg   %ax,%ax
  801cae:	66 90                	xchg   %ax,%ax

00801cb0 <__umoddi3>:
  801cb0:	55                   	push   %ebp
  801cb1:	57                   	push   %edi
  801cb2:	56                   	push   %esi
  801cb3:	53                   	push   %ebx
  801cb4:	83 ec 1c             	sub    $0x1c,%esp
  801cb7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801cbb:	8b 74 24 30          	mov    0x30(%esp),%esi
  801cbf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801cc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cc7:	85 ed                	test   %ebp,%ebp
  801cc9:	89 f0                	mov    %esi,%eax
  801ccb:	89 da                	mov    %ebx,%edx
  801ccd:	75 19                	jne    801ce8 <__umoddi3+0x38>
  801ccf:	39 df                	cmp    %ebx,%edi
  801cd1:	0f 86 b1 00 00 00    	jbe    801d88 <__umoddi3+0xd8>
  801cd7:	f7 f7                	div    %edi
  801cd9:	89 d0                	mov    %edx,%eax
  801cdb:	31 d2                	xor    %edx,%edx
  801cdd:	83 c4 1c             	add    $0x1c,%esp
  801ce0:	5b                   	pop    %ebx
  801ce1:	5e                   	pop    %esi
  801ce2:	5f                   	pop    %edi
  801ce3:	5d                   	pop    %ebp
  801ce4:	c3                   	ret    
  801ce5:	8d 76 00             	lea    0x0(%esi),%esi
  801ce8:	39 dd                	cmp    %ebx,%ebp
  801cea:	77 f1                	ja     801cdd <__umoddi3+0x2d>
  801cec:	0f bd cd             	bsr    %ebp,%ecx
  801cef:	83 f1 1f             	xor    $0x1f,%ecx
  801cf2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801cf6:	0f 84 b4 00 00 00    	je     801db0 <__umoddi3+0x100>
  801cfc:	b8 20 00 00 00       	mov    $0x20,%eax
  801d01:	89 c2                	mov    %eax,%edx
  801d03:	8b 44 24 04          	mov    0x4(%esp),%eax
  801d07:	29 c2                	sub    %eax,%edx
  801d09:	89 c1                	mov    %eax,%ecx
  801d0b:	89 f8                	mov    %edi,%eax
  801d0d:	d3 e5                	shl    %cl,%ebp
  801d0f:	89 d1                	mov    %edx,%ecx
  801d11:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801d15:	d3 e8                	shr    %cl,%eax
  801d17:	09 c5                	or     %eax,%ebp
  801d19:	8b 44 24 04          	mov    0x4(%esp),%eax
  801d1d:	89 c1                	mov    %eax,%ecx
  801d1f:	d3 e7                	shl    %cl,%edi
  801d21:	89 d1                	mov    %edx,%ecx
  801d23:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801d27:	89 df                	mov    %ebx,%edi
  801d29:	d3 ef                	shr    %cl,%edi
  801d2b:	89 c1                	mov    %eax,%ecx
  801d2d:	89 f0                	mov    %esi,%eax
  801d2f:	d3 e3                	shl    %cl,%ebx
  801d31:	89 d1                	mov    %edx,%ecx
  801d33:	89 fa                	mov    %edi,%edx
  801d35:	d3 e8                	shr    %cl,%eax
  801d37:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801d3c:	09 d8                	or     %ebx,%eax
  801d3e:	f7 f5                	div    %ebp
  801d40:	d3 e6                	shl    %cl,%esi
  801d42:	89 d1                	mov    %edx,%ecx
  801d44:	f7 64 24 08          	mull   0x8(%esp)
  801d48:	39 d1                	cmp    %edx,%ecx
  801d4a:	89 c3                	mov    %eax,%ebx
  801d4c:	89 d7                	mov    %edx,%edi
  801d4e:	72 06                	jb     801d56 <__umoddi3+0xa6>
  801d50:	75 0e                	jne    801d60 <__umoddi3+0xb0>
  801d52:	39 c6                	cmp    %eax,%esi
  801d54:	73 0a                	jae    801d60 <__umoddi3+0xb0>
  801d56:	2b 44 24 08          	sub    0x8(%esp),%eax
  801d5a:	19 ea                	sbb    %ebp,%edx
  801d5c:	89 d7                	mov    %edx,%edi
  801d5e:	89 c3                	mov    %eax,%ebx
  801d60:	89 ca                	mov    %ecx,%edx
  801d62:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801d67:	29 de                	sub    %ebx,%esi
  801d69:	19 fa                	sbb    %edi,%edx
  801d6b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  801d6f:	89 d0                	mov    %edx,%eax
  801d71:	d3 e0                	shl    %cl,%eax
  801d73:	89 d9                	mov    %ebx,%ecx
  801d75:	d3 ee                	shr    %cl,%esi
  801d77:	d3 ea                	shr    %cl,%edx
  801d79:	09 f0                	or     %esi,%eax
  801d7b:	83 c4 1c             	add    $0x1c,%esp
  801d7e:	5b                   	pop    %ebx
  801d7f:	5e                   	pop    %esi
  801d80:	5f                   	pop    %edi
  801d81:	5d                   	pop    %ebp
  801d82:	c3                   	ret    
  801d83:	90                   	nop
  801d84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d88:	85 ff                	test   %edi,%edi
  801d8a:	89 f9                	mov    %edi,%ecx
  801d8c:	75 0b                	jne    801d99 <__umoddi3+0xe9>
  801d8e:	b8 01 00 00 00       	mov    $0x1,%eax
  801d93:	31 d2                	xor    %edx,%edx
  801d95:	f7 f7                	div    %edi
  801d97:	89 c1                	mov    %eax,%ecx
  801d99:	89 d8                	mov    %ebx,%eax
  801d9b:	31 d2                	xor    %edx,%edx
  801d9d:	f7 f1                	div    %ecx
  801d9f:	89 f0                	mov    %esi,%eax
  801da1:	f7 f1                	div    %ecx
  801da3:	e9 31 ff ff ff       	jmp    801cd9 <__umoddi3+0x29>
  801da8:	90                   	nop
  801da9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801db0:	39 dd                	cmp    %ebx,%ebp
  801db2:	72 08                	jb     801dbc <__umoddi3+0x10c>
  801db4:	39 f7                	cmp    %esi,%edi
  801db6:	0f 87 21 ff ff ff    	ja     801cdd <__umoddi3+0x2d>
  801dbc:	89 da                	mov    %ebx,%edx
  801dbe:	89 f0                	mov    %esi,%eax
  801dc0:	29 f8                	sub    %edi,%eax
  801dc2:	19 ea                	sbb    %ebp,%edx
  801dc4:	e9 14 ff ff ff       	jmp    801cdd <__umoddi3+0x2d>
