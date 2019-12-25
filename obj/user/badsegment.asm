
obj/user/badsegment.debug：     文件格式 elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800036:	66 b8 28 00          	mov    $0x28,%ax
  80003a:	8e d8                	mov    %eax,%ds
}
  80003c:	5d                   	pop    %ebp
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	56                   	push   %esi
  800042:	53                   	push   %ebx
  800043:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800046:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800049:	e8 ce 00 00 00       	call   80011c <sys_getenvid>
	thisenv = envs + ENVX(envid); 
  80004e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800053:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800056:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005b:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800060:	85 db                	test   %ebx,%ebx
  800062:	7e 07                	jle    80006b <libmain+0x2d>
		binaryname = argv[0];
  800064:	8b 06                	mov    (%esi),%eax
  800066:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80006b:	83 ec 08             	sub    $0x8,%esp
  80006e:	56                   	push   %esi
  80006f:	53                   	push   %ebx
  800070:	e8 be ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800075:	e8 0a 00 00 00       	call   800084 <exit>
}
  80007a:	83 c4 10             	add    $0x10,%esp
  80007d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800080:	5b                   	pop    %ebx
  800081:	5e                   	pop    %esi
  800082:	5d                   	pop    %ebp
  800083:	c3                   	ret    

00800084 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800084:	55                   	push   %ebp
  800085:	89 e5                	mov    %esp,%ebp
  800087:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80008a:	e8 92 04 00 00       	call   800521 <close_all>
	sys_env_destroy(0);
  80008f:	83 ec 0c             	sub    $0xc,%esp
  800092:	6a 00                	push   $0x0
  800094:	e8 42 00 00 00       	call   8000db <sys_env_destroy>
}
  800099:	83 c4 10             	add    $0x10,%esp
  80009c:	c9                   	leave  
  80009d:	c3                   	ret    

0080009e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009e:	55                   	push   %ebp
  80009f:	89 e5                	mov    %esp,%ebp
  8000a1:	57                   	push   %edi
  8000a2:	56                   	push   %esi
  8000a3:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000af:	89 c3                	mov    %eax,%ebx
  8000b1:	89 c7                	mov    %eax,%edi
  8000b3:	89 c6                	mov    %eax,%esi
  8000b5:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b7:	5b                   	pop    %ebx
  8000b8:	5e                   	pop    %esi
  8000b9:	5f                   	pop    %edi
  8000ba:	5d                   	pop    %ebp
  8000bb:	c3                   	ret    

008000bc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	57                   	push   %edi
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000cc:	89 d1                	mov    %edx,%ecx
  8000ce:	89 d3                	mov    %edx,%ebx
  8000d0:	89 d7                	mov    %edx,%edi
  8000d2:	89 d6                	mov    %edx,%esi
  8000d4:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d6:	5b                   	pop    %ebx
  8000d7:	5e                   	pop    %esi
  8000d8:	5f                   	pop    %edi
  8000d9:	5d                   	pop    %ebp
  8000da:	c3                   	ret    

008000db <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	57                   	push   %edi
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
  8000e1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000e4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ec:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f1:	89 cb                	mov    %ecx,%ebx
  8000f3:	89 cf                	mov    %ecx,%edi
  8000f5:	89 ce                	mov    %ecx,%esi
  8000f7:	cd 30                	int    $0x30
	if(check && ret > 0)
  8000f9:	85 c0                	test   %eax,%eax
  8000fb:	7f 08                	jg     800105 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8000fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800100:	5b                   	pop    %ebx
  800101:	5e                   	pop    %esi
  800102:	5f                   	pop    %edi
  800103:	5d                   	pop    %ebp
  800104:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800105:	83 ec 0c             	sub    $0xc,%esp
  800108:	50                   	push   %eax
  800109:	6a 03                	push   $0x3
  80010b:	68 aa 1d 80 00       	push   $0x801daa
  800110:	6a 23                	push   $0x23
  800112:	68 c7 1d 80 00       	push   $0x801dc7
  800117:	e8 dd 0e 00 00       	call   800ff9 <_panic>

0080011c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	57                   	push   %edi
  800120:	56                   	push   %esi
  800121:	53                   	push   %ebx
	asm volatile("int %1\n"
  800122:	ba 00 00 00 00       	mov    $0x0,%edx
  800127:	b8 02 00 00 00       	mov    $0x2,%eax
  80012c:	89 d1                	mov    %edx,%ecx
  80012e:	89 d3                	mov    %edx,%ebx
  800130:	89 d7                	mov    %edx,%edi
  800132:	89 d6                	mov    %edx,%esi
  800134:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800136:	5b                   	pop    %ebx
  800137:	5e                   	pop    %esi
  800138:	5f                   	pop    %edi
  800139:	5d                   	pop    %ebp
  80013a:	c3                   	ret    

0080013b <sys_yield>:

void
sys_yield(void)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	57                   	push   %edi
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
	asm volatile("int %1\n"
  800141:	ba 00 00 00 00       	mov    $0x0,%edx
  800146:	b8 0b 00 00 00       	mov    $0xb,%eax
  80014b:	89 d1                	mov    %edx,%ecx
  80014d:	89 d3                	mov    %edx,%ebx
  80014f:	89 d7                	mov    %edx,%edi
  800151:	89 d6                	mov    %edx,%esi
  800153:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5f                   	pop    %edi
  800158:	5d                   	pop    %ebp
  800159:	c3                   	ret    

0080015a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015a:	55                   	push   %ebp
  80015b:	89 e5                	mov    %esp,%ebp
  80015d:	57                   	push   %edi
  80015e:	56                   	push   %esi
  80015f:	53                   	push   %ebx
  800160:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800163:	be 00 00 00 00       	mov    $0x0,%esi
  800168:	8b 55 08             	mov    0x8(%ebp),%edx
  80016b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80016e:	b8 04 00 00 00       	mov    $0x4,%eax
  800173:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800176:	89 f7                	mov    %esi,%edi
  800178:	cd 30                	int    $0x30
	if(check && ret > 0)
  80017a:	85 c0                	test   %eax,%eax
  80017c:	7f 08                	jg     800186 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80017e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800181:	5b                   	pop    %ebx
  800182:	5e                   	pop    %esi
  800183:	5f                   	pop    %edi
  800184:	5d                   	pop    %ebp
  800185:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800186:	83 ec 0c             	sub    $0xc,%esp
  800189:	50                   	push   %eax
  80018a:	6a 04                	push   $0x4
  80018c:	68 aa 1d 80 00       	push   $0x801daa
  800191:	6a 23                	push   $0x23
  800193:	68 c7 1d 80 00       	push   $0x801dc7
  800198:	e8 5c 0e 00 00       	call   800ff9 <_panic>

0080019d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	57                   	push   %edi
  8001a1:	56                   	push   %esi
  8001a2:	53                   	push   %ebx
  8001a3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ac:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ba:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001bc:	85 c0                	test   %eax,%eax
  8001be:	7f 08                	jg     8001c8 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c3:	5b                   	pop    %ebx
  8001c4:	5e                   	pop    %esi
  8001c5:	5f                   	pop    %edi
  8001c6:	5d                   	pop    %ebp
  8001c7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c8:	83 ec 0c             	sub    $0xc,%esp
  8001cb:	50                   	push   %eax
  8001cc:	6a 05                	push   $0x5
  8001ce:	68 aa 1d 80 00       	push   $0x801daa
  8001d3:	6a 23                	push   $0x23
  8001d5:	68 c7 1d 80 00       	push   $0x801dc7
  8001da:	e8 1a 0e 00 00       	call   800ff9 <_panic>

008001df <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	57                   	push   %edi
  8001e3:	56                   	push   %esi
  8001e4:	53                   	push   %ebx
  8001e5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f3:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f8:	89 df                	mov    %ebx,%edi
  8001fa:	89 de                	mov    %ebx,%esi
  8001fc:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001fe:	85 c0                	test   %eax,%eax
  800200:	7f 08                	jg     80020a <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800202:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800205:	5b                   	pop    %ebx
  800206:	5e                   	pop    %esi
  800207:	5f                   	pop    %edi
  800208:	5d                   	pop    %ebp
  800209:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80020a:	83 ec 0c             	sub    $0xc,%esp
  80020d:	50                   	push   %eax
  80020e:	6a 06                	push   $0x6
  800210:	68 aa 1d 80 00       	push   $0x801daa
  800215:	6a 23                	push   $0x23
  800217:	68 c7 1d 80 00       	push   $0x801dc7
  80021c:	e8 d8 0d 00 00       	call   800ff9 <_panic>

00800221 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	57                   	push   %edi
  800225:	56                   	push   %esi
  800226:	53                   	push   %ebx
  800227:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80022a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022f:	8b 55 08             	mov    0x8(%ebp),%edx
  800232:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800235:	b8 08 00 00 00       	mov    $0x8,%eax
  80023a:	89 df                	mov    %ebx,%edi
  80023c:	89 de                	mov    %ebx,%esi
  80023e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800240:	85 c0                	test   %eax,%eax
  800242:	7f 08                	jg     80024c <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800244:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800247:	5b                   	pop    %ebx
  800248:	5e                   	pop    %esi
  800249:	5f                   	pop    %edi
  80024a:	5d                   	pop    %ebp
  80024b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80024c:	83 ec 0c             	sub    $0xc,%esp
  80024f:	50                   	push   %eax
  800250:	6a 08                	push   $0x8
  800252:	68 aa 1d 80 00       	push   $0x801daa
  800257:	6a 23                	push   $0x23
  800259:	68 c7 1d 80 00       	push   $0x801dc7
  80025e:	e8 96 0d 00 00       	call   800ff9 <_panic>

00800263 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	57                   	push   %edi
  800267:	56                   	push   %esi
  800268:	53                   	push   %ebx
  800269:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80026c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800271:	8b 55 08             	mov    0x8(%ebp),%edx
  800274:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800277:	b8 09 00 00 00       	mov    $0x9,%eax
  80027c:	89 df                	mov    %ebx,%edi
  80027e:	89 de                	mov    %ebx,%esi
  800280:	cd 30                	int    $0x30
	if(check && ret > 0)
  800282:	85 c0                	test   %eax,%eax
  800284:	7f 08                	jg     80028e <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800286:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800289:	5b                   	pop    %ebx
  80028a:	5e                   	pop    %esi
  80028b:	5f                   	pop    %edi
  80028c:	5d                   	pop    %ebp
  80028d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80028e:	83 ec 0c             	sub    $0xc,%esp
  800291:	50                   	push   %eax
  800292:	6a 09                	push   $0x9
  800294:	68 aa 1d 80 00       	push   $0x801daa
  800299:	6a 23                	push   $0x23
  80029b:	68 c7 1d 80 00       	push   $0x801dc7
  8002a0:	e8 54 0d 00 00       	call   800ff9 <_panic>

008002a5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	57                   	push   %edi
  8002a9:	56                   	push   %esi
  8002aa:	53                   	push   %ebx
  8002ab:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002ae:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002be:	89 df                	mov    %ebx,%edi
  8002c0:	89 de                	mov    %ebx,%esi
  8002c2:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002c4:	85 c0                	test   %eax,%eax
  8002c6:	7f 08                	jg     8002d0 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002cb:	5b                   	pop    %ebx
  8002cc:	5e                   	pop    %esi
  8002cd:	5f                   	pop    %edi
  8002ce:	5d                   	pop    %ebp
  8002cf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d0:	83 ec 0c             	sub    $0xc,%esp
  8002d3:	50                   	push   %eax
  8002d4:	6a 0a                	push   $0xa
  8002d6:	68 aa 1d 80 00       	push   $0x801daa
  8002db:	6a 23                	push   $0x23
  8002dd:	68 c7 1d 80 00       	push   $0x801dc7
  8002e2:	e8 12 0d 00 00       	call   800ff9 <_panic>

008002e7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
  8002ea:	57                   	push   %edi
  8002eb:	56                   	push   %esi
  8002ec:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f3:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f8:	be 00 00 00 00       	mov    $0x0,%esi
  8002fd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800300:	8b 7d 14             	mov    0x14(%ebp),%edi
  800303:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800305:	5b                   	pop    %ebx
  800306:	5e                   	pop    %esi
  800307:	5f                   	pop    %edi
  800308:	5d                   	pop    %ebp
  800309:	c3                   	ret    

0080030a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	57                   	push   %edi
  80030e:	56                   	push   %esi
  80030f:	53                   	push   %ebx
  800310:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800313:	b9 00 00 00 00       	mov    $0x0,%ecx
  800318:	8b 55 08             	mov    0x8(%ebp),%edx
  80031b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800320:	89 cb                	mov    %ecx,%ebx
  800322:	89 cf                	mov    %ecx,%edi
  800324:	89 ce                	mov    %ecx,%esi
  800326:	cd 30                	int    $0x30
	if(check && ret > 0)
  800328:	85 c0                	test   %eax,%eax
  80032a:	7f 08                	jg     800334 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80032c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80032f:	5b                   	pop    %ebx
  800330:	5e                   	pop    %esi
  800331:	5f                   	pop    %edi
  800332:	5d                   	pop    %ebp
  800333:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800334:	83 ec 0c             	sub    $0xc,%esp
  800337:	50                   	push   %eax
  800338:	6a 0d                	push   $0xd
  80033a:	68 aa 1d 80 00       	push   $0x801daa
  80033f:	6a 23                	push   $0x23
  800341:	68 c7 1d 80 00       	push   $0x801dc7
  800346:	e8 ae 0c 00 00       	call   800ff9 <_panic>

0080034b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80034b:	55                   	push   %ebp
  80034c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80034e:	8b 45 08             	mov    0x8(%ebp),%eax
  800351:	05 00 00 00 30       	add    $0x30000000,%eax
  800356:	c1 e8 0c             	shr    $0xc,%eax
}
  800359:	5d                   	pop    %ebp
  80035a:	c3                   	ret    

0080035b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80035e:	8b 45 08             	mov    0x8(%ebp),%eax
  800361:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800366:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80036b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800370:	5d                   	pop    %ebp
  800371:	c3                   	ret    

00800372 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800372:	55                   	push   %ebp
  800373:	89 e5                	mov    %esp,%ebp
  800375:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800378:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80037d:	89 c2                	mov    %eax,%edx
  80037f:	c1 ea 16             	shr    $0x16,%edx
  800382:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800389:	f6 c2 01             	test   $0x1,%dl
  80038c:	74 2a                	je     8003b8 <fd_alloc+0x46>
  80038e:	89 c2                	mov    %eax,%edx
  800390:	c1 ea 0c             	shr    $0xc,%edx
  800393:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80039a:	f6 c2 01             	test   $0x1,%dl
  80039d:	74 19                	je     8003b8 <fd_alloc+0x46>
  80039f:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8003a4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003a9:	75 d2                	jne    80037d <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003ab:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003b1:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8003b6:	eb 07                	jmp    8003bf <fd_alloc+0x4d>
			*fd_store = fd;
  8003b8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003bf:	5d                   	pop    %ebp
  8003c0:	c3                   	ret    

008003c1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003c1:	55                   	push   %ebp
  8003c2:	89 e5                	mov    %esp,%ebp
  8003c4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003c7:	83 f8 1f             	cmp    $0x1f,%eax
  8003ca:	77 36                	ja     800402 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003cc:	c1 e0 0c             	shl    $0xc,%eax
  8003cf:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003d4:	89 c2                	mov    %eax,%edx
  8003d6:	c1 ea 16             	shr    $0x16,%edx
  8003d9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003e0:	f6 c2 01             	test   $0x1,%dl
  8003e3:	74 24                	je     800409 <fd_lookup+0x48>
  8003e5:	89 c2                	mov    %eax,%edx
  8003e7:	c1 ea 0c             	shr    $0xc,%edx
  8003ea:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003f1:	f6 c2 01             	test   $0x1,%dl
  8003f4:	74 1a                	je     800410 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f9:	89 02                	mov    %eax,(%edx)
	return 0;
  8003fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800400:	5d                   	pop    %ebp
  800401:	c3                   	ret    
		return -E_INVAL;
  800402:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800407:	eb f7                	jmp    800400 <fd_lookup+0x3f>
		return -E_INVAL;
  800409:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80040e:	eb f0                	jmp    800400 <fd_lookup+0x3f>
  800410:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800415:	eb e9                	jmp    800400 <fd_lookup+0x3f>

00800417 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800417:	55                   	push   %ebp
  800418:	89 e5                	mov    %esp,%ebp
  80041a:	83 ec 08             	sub    $0x8,%esp
  80041d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800420:	ba 54 1e 80 00       	mov    $0x801e54,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800425:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  80042a:	39 08                	cmp    %ecx,(%eax)
  80042c:	74 33                	je     800461 <dev_lookup+0x4a>
  80042e:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800431:	8b 02                	mov    (%edx),%eax
  800433:	85 c0                	test   %eax,%eax
  800435:	75 f3                	jne    80042a <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800437:	a1 04 40 80 00       	mov    0x804004,%eax
  80043c:	8b 40 48             	mov    0x48(%eax),%eax
  80043f:	83 ec 04             	sub    $0x4,%esp
  800442:	51                   	push   %ecx
  800443:	50                   	push   %eax
  800444:	68 d8 1d 80 00       	push   $0x801dd8
  800449:	e8 86 0c 00 00       	call   8010d4 <cprintf>
	*dev = 0;
  80044e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800451:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800457:	83 c4 10             	add    $0x10,%esp
  80045a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80045f:	c9                   	leave  
  800460:	c3                   	ret    
			*dev = devtab[i];
  800461:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800464:	89 01                	mov    %eax,(%ecx)
			return 0;
  800466:	b8 00 00 00 00       	mov    $0x0,%eax
  80046b:	eb f2                	jmp    80045f <dev_lookup+0x48>

0080046d <fd_close>:
{
  80046d:	55                   	push   %ebp
  80046e:	89 e5                	mov    %esp,%ebp
  800470:	57                   	push   %edi
  800471:	56                   	push   %esi
  800472:	53                   	push   %ebx
  800473:	83 ec 1c             	sub    $0x1c,%esp
  800476:	8b 75 08             	mov    0x8(%ebp),%esi
  800479:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80047c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80047f:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800480:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800486:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800489:	50                   	push   %eax
  80048a:	e8 32 ff ff ff       	call   8003c1 <fd_lookup>
  80048f:	89 c3                	mov    %eax,%ebx
  800491:	83 c4 08             	add    $0x8,%esp
  800494:	85 c0                	test   %eax,%eax
  800496:	78 05                	js     80049d <fd_close+0x30>
	    || fd != fd2)
  800498:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80049b:	74 16                	je     8004b3 <fd_close+0x46>
		return (must_exist ? r : 0);
  80049d:	89 f8                	mov    %edi,%eax
  80049f:	84 c0                	test   %al,%al
  8004a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a6:	0f 44 d8             	cmove  %eax,%ebx
}
  8004a9:	89 d8                	mov    %ebx,%eax
  8004ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004ae:	5b                   	pop    %ebx
  8004af:	5e                   	pop    %esi
  8004b0:	5f                   	pop    %edi
  8004b1:	5d                   	pop    %ebp
  8004b2:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004b3:	83 ec 08             	sub    $0x8,%esp
  8004b6:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8004b9:	50                   	push   %eax
  8004ba:	ff 36                	pushl  (%esi)
  8004bc:	e8 56 ff ff ff       	call   800417 <dev_lookup>
  8004c1:	89 c3                	mov    %eax,%ebx
  8004c3:	83 c4 10             	add    $0x10,%esp
  8004c6:	85 c0                	test   %eax,%eax
  8004c8:	78 15                	js     8004df <fd_close+0x72>
		if (dev->dev_close)
  8004ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004cd:	8b 40 10             	mov    0x10(%eax),%eax
  8004d0:	85 c0                	test   %eax,%eax
  8004d2:	74 1b                	je     8004ef <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  8004d4:	83 ec 0c             	sub    $0xc,%esp
  8004d7:	56                   	push   %esi
  8004d8:	ff d0                	call   *%eax
  8004da:	89 c3                	mov    %eax,%ebx
  8004dc:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8004df:	83 ec 08             	sub    $0x8,%esp
  8004e2:	56                   	push   %esi
  8004e3:	6a 00                	push   $0x0
  8004e5:	e8 f5 fc ff ff       	call   8001df <sys_page_unmap>
	return r;
  8004ea:	83 c4 10             	add    $0x10,%esp
  8004ed:	eb ba                	jmp    8004a9 <fd_close+0x3c>
			r = 0;
  8004ef:	bb 00 00 00 00       	mov    $0x0,%ebx
  8004f4:	eb e9                	jmp    8004df <fd_close+0x72>

008004f6 <close>:

int
close(int fdnum)
{
  8004f6:	55                   	push   %ebp
  8004f7:	89 e5                	mov    %esp,%ebp
  8004f9:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004ff:	50                   	push   %eax
  800500:	ff 75 08             	pushl  0x8(%ebp)
  800503:	e8 b9 fe ff ff       	call   8003c1 <fd_lookup>
  800508:	83 c4 08             	add    $0x8,%esp
  80050b:	85 c0                	test   %eax,%eax
  80050d:	78 10                	js     80051f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80050f:	83 ec 08             	sub    $0x8,%esp
  800512:	6a 01                	push   $0x1
  800514:	ff 75 f4             	pushl  -0xc(%ebp)
  800517:	e8 51 ff ff ff       	call   80046d <fd_close>
  80051c:	83 c4 10             	add    $0x10,%esp
}
  80051f:	c9                   	leave  
  800520:	c3                   	ret    

00800521 <close_all>:

void
close_all(void)
{
  800521:	55                   	push   %ebp
  800522:	89 e5                	mov    %esp,%ebp
  800524:	53                   	push   %ebx
  800525:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800528:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80052d:	83 ec 0c             	sub    $0xc,%esp
  800530:	53                   	push   %ebx
  800531:	e8 c0 ff ff ff       	call   8004f6 <close>
	for (i = 0; i < MAXFD; i++)
  800536:	83 c3 01             	add    $0x1,%ebx
  800539:	83 c4 10             	add    $0x10,%esp
  80053c:	83 fb 20             	cmp    $0x20,%ebx
  80053f:	75 ec                	jne    80052d <close_all+0xc>
}
  800541:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800544:	c9                   	leave  
  800545:	c3                   	ret    

00800546 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800546:	55                   	push   %ebp
  800547:	89 e5                	mov    %esp,%ebp
  800549:	57                   	push   %edi
  80054a:	56                   	push   %esi
  80054b:	53                   	push   %ebx
  80054c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80054f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800552:	50                   	push   %eax
  800553:	ff 75 08             	pushl  0x8(%ebp)
  800556:	e8 66 fe ff ff       	call   8003c1 <fd_lookup>
  80055b:	89 c3                	mov    %eax,%ebx
  80055d:	83 c4 08             	add    $0x8,%esp
  800560:	85 c0                	test   %eax,%eax
  800562:	0f 88 81 00 00 00    	js     8005e9 <dup+0xa3>
		return r;
	close(newfdnum);
  800568:	83 ec 0c             	sub    $0xc,%esp
  80056b:	ff 75 0c             	pushl  0xc(%ebp)
  80056e:	e8 83 ff ff ff       	call   8004f6 <close>

	newfd = INDEX2FD(newfdnum);
  800573:	8b 75 0c             	mov    0xc(%ebp),%esi
  800576:	c1 e6 0c             	shl    $0xc,%esi
  800579:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80057f:	83 c4 04             	add    $0x4,%esp
  800582:	ff 75 e4             	pushl  -0x1c(%ebp)
  800585:	e8 d1 fd ff ff       	call   80035b <fd2data>
  80058a:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80058c:	89 34 24             	mov    %esi,(%esp)
  80058f:	e8 c7 fd ff ff       	call   80035b <fd2data>
  800594:	83 c4 10             	add    $0x10,%esp
  800597:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800599:	89 d8                	mov    %ebx,%eax
  80059b:	c1 e8 16             	shr    $0x16,%eax
  80059e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005a5:	a8 01                	test   $0x1,%al
  8005a7:	74 11                	je     8005ba <dup+0x74>
  8005a9:	89 d8                	mov    %ebx,%eax
  8005ab:	c1 e8 0c             	shr    $0xc,%eax
  8005ae:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005b5:	f6 c2 01             	test   $0x1,%dl
  8005b8:	75 39                	jne    8005f3 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005ba:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005bd:	89 d0                	mov    %edx,%eax
  8005bf:	c1 e8 0c             	shr    $0xc,%eax
  8005c2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005c9:	83 ec 0c             	sub    $0xc,%esp
  8005cc:	25 07 0e 00 00       	and    $0xe07,%eax
  8005d1:	50                   	push   %eax
  8005d2:	56                   	push   %esi
  8005d3:	6a 00                	push   $0x0
  8005d5:	52                   	push   %edx
  8005d6:	6a 00                	push   $0x0
  8005d8:	e8 c0 fb ff ff       	call   80019d <sys_page_map>
  8005dd:	89 c3                	mov    %eax,%ebx
  8005df:	83 c4 20             	add    $0x20,%esp
  8005e2:	85 c0                	test   %eax,%eax
  8005e4:	78 31                	js     800617 <dup+0xd1>
		goto err;

	return newfdnum;
  8005e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005e9:	89 d8                	mov    %ebx,%eax
  8005eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005ee:	5b                   	pop    %ebx
  8005ef:	5e                   	pop    %esi
  8005f0:	5f                   	pop    %edi
  8005f1:	5d                   	pop    %ebp
  8005f2:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005f3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005fa:	83 ec 0c             	sub    $0xc,%esp
  8005fd:	25 07 0e 00 00       	and    $0xe07,%eax
  800602:	50                   	push   %eax
  800603:	57                   	push   %edi
  800604:	6a 00                	push   $0x0
  800606:	53                   	push   %ebx
  800607:	6a 00                	push   $0x0
  800609:	e8 8f fb ff ff       	call   80019d <sys_page_map>
  80060e:	89 c3                	mov    %eax,%ebx
  800610:	83 c4 20             	add    $0x20,%esp
  800613:	85 c0                	test   %eax,%eax
  800615:	79 a3                	jns    8005ba <dup+0x74>
	sys_page_unmap(0, newfd);
  800617:	83 ec 08             	sub    $0x8,%esp
  80061a:	56                   	push   %esi
  80061b:	6a 00                	push   $0x0
  80061d:	e8 bd fb ff ff       	call   8001df <sys_page_unmap>
	sys_page_unmap(0, nva);
  800622:	83 c4 08             	add    $0x8,%esp
  800625:	57                   	push   %edi
  800626:	6a 00                	push   $0x0
  800628:	e8 b2 fb ff ff       	call   8001df <sys_page_unmap>
	return r;
  80062d:	83 c4 10             	add    $0x10,%esp
  800630:	eb b7                	jmp    8005e9 <dup+0xa3>

00800632 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800632:	55                   	push   %ebp
  800633:	89 e5                	mov    %esp,%ebp
  800635:	53                   	push   %ebx
  800636:	83 ec 14             	sub    $0x14,%esp
  800639:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80063c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80063f:	50                   	push   %eax
  800640:	53                   	push   %ebx
  800641:	e8 7b fd ff ff       	call   8003c1 <fd_lookup>
  800646:	83 c4 08             	add    $0x8,%esp
  800649:	85 c0                	test   %eax,%eax
  80064b:	78 3f                	js     80068c <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80064d:	83 ec 08             	sub    $0x8,%esp
  800650:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800653:	50                   	push   %eax
  800654:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800657:	ff 30                	pushl  (%eax)
  800659:	e8 b9 fd ff ff       	call   800417 <dev_lookup>
  80065e:	83 c4 10             	add    $0x10,%esp
  800661:	85 c0                	test   %eax,%eax
  800663:	78 27                	js     80068c <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800665:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800668:	8b 42 08             	mov    0x8(%edx),%eax
  80066b:	83 e0 03             	and    $0x3,%eax
  80066e:	83 f8 01             	cmp    $0x1,%eax
  800671:	74 1e                	je     800691 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  800673:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800676:	8b 40 08             	mov    0x8(%eax),%eax
  800679:	85 c0                	test   %eax,%eax
  80067b:	74 35                	je     8006b2 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80067d:	83 ec 04             	sub    $0x4,%esp
  800680:	ff 75 10             	pushl  0x10(%ebp)
  800683:	ff 75 0c             	pushl  0xc(%ebp)
  800686:	52                   	push   %edx
  800687:	ff d0                	call   *%eax
  800689:	83 c4 10             	add    $0x10,%esp
}
  80068c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80068f:	c9                   	leave  
  800690:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800691:	a1 04 40 80 00       	mov    0x804004,%eax
  800696:	8b 40 48             	mov    0x48(%eax),%eax
  800699:	83 ec 04             	sub    $0x4,%esp
  80069c:	53                   	push   %ebx
  80069d:	50                   	push   %eax
  80069e:	68 19 1e 80 00       	push   $0x801e19
  8006a3:	e8 2c 0a 00 00       	call   8010d4 <cprintf>
		return -E_INVAL;
  8006a8:	83 c4 10             	add    $0x10,%esp
  8006ab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006b0:	eb da                	jmp    80068c <read+0x5a>
		return -E_NOT_SUPP;
  8006b2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8006b7:	eb d3                	jmp    80068c <read+0x5a>

008006b9 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006b9:	55                   	push   %ebp
  8006ba:	89 e5                	mov    %esp,%ebp
  8006bc:	57                   	push   %edi
  8006bd:	56                   	push   %esi
  8006be:	53                   	push   %ebx
  8006bf:	83 ec 0c             	sub    $0xc,%esp
  8006c2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c5:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006c8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006cd:	39 f3                	cmp    %esi,%ebx
  8006cf:	73 25                	jae    8006f6 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006d1:	83 ec 04             	sub    $0x4,%esp
  8006d4:	89 f0                	mov    %esi,%eax
  8006d6:	29 d8                	sub    %ebx,%eax
  8006d8:	50                   	push   %eax
  8006d9:	89 d8                	mov    %ebx,%eax
  8006db:	03 45 0c             	add    0xc(%ebp),%eax
  8006de:	50                   	push   %eax
  8006df:	57                   	push   %edi
  8006e0:	e8 4d ff ff ff       	call   800632 <read>
		if (m < 0)
  8006e5:	83 c4 10             	add    $0x10,%esp
  8006e8:	85 c0                	test   %eax,%eax
  8006ea:	78 08                	js     8006f4 <readn+0x3b>
			return m;
		if (m == 0)
  8006ec:	85 c0                	test   %eax,%eax
  8006ee:	74 06                	je     8006f6 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  8006f0:	01 c3                	add    %eax,%ebx
  8006f2:	eb d9                	jmp    8006cd <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006f4:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8006f6:	89 d8                	mov    %ebx,%eax
  8006f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006fb:	5b                   	pop    %ebx
  8006fc:	5e                   	pop    %esi
  8006fd:	5f                   	pop    %edi
  8006fe:	5d                   	pop    %ebp
  8006ff:	c3                   	ret    

00800700 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800700:	55                   	push   %ebp
  800701:	89 e5                	mov    %esp,%ebp
  800703:	53                   	push   %ebx
  800704:	83 ec 14             	sub    $0x14,%esp
  800707:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80070a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80070d:	50                   	push   %eax
  80070e:	53                   	push   %ebx
  80070f:	e8 ad fc ff ff       	call   8003c1 <fd_lookup>
  800714:	83 c4 08             	add    $0x8,%esp
  800717:	85 c0                	test   %eax,%eax
  800719:	78 3a                	js     800755 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80071b:	83 ec 08             	sub    $0x8,%esp
  80071e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800721:	50                   	push   %eax
  800722:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800725:	ff 30                	pushl  (%eax)
  800727:	e8 eb fc ff ff       	call   800417 <dev_lookup>
  80072c:	83 c4 10             	add    $0x10,%esp
  80072f:	85 c0                	test   %eax,%eax
  800731:	78 22                	js     800755 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800733:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800736:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80073a:	74 1e                	je     80075a <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80073c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80073f:	8b 52 0c             	mov    0xc(%edx),%edx
  800742:	85 d2                	test   %edx,%edx
  800744:	74 35                	je     80077b <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800746:	83 ec 04             	sub    $0x4,%esp
  800749:	ff 75 10             	pushl  0x10(%ebp)
  80074c:	ff 75 0c             	pushl  0xc(%ebp)
  80074f:	50                   	push   %eax
  800750:	ff d2                	call   *%edx
  800752:	83 c4 10             	add    $0x10,%esp
}
  800755:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800758:	c9                   	leave  
  800759:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80075a:	a1 04 40 80 00       	mov    0x804004,%eax
  80075f:	8b 40 48             	mov    0x48(%eax),%eax
  800762:	83 ec 04             	sub    $0x4,%esp
  800765:	53                   	push   %ebx
  800766:	50                   	push   %eax
  800767:	68 35 1e 80 00       	push   $0x801e35
  80076c:	e8 63 09 00 00       	call   8010d4 <cprintf>
		return -E_INVAL;
  800771:	83 c4 10             	add    $0x10,%esp
  800774:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800779:	eb da                	jmp    800755 <write+0x55>
		return -E_NOT_SUPP;
  80077b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800780:	eb d3                	jmp    800755 <write+0x55>

00800782 <seek>:

int
seek(int fdnum, off_t offset)
{
  800782:	55                   	push   %ebp
  800783:	89 e5                	mov    %esp,%ebp
  800785:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800788:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80078b:	50                   	push   %eax
  80078c:	ff 75 08             	pushl  0x8(%ebp)
  80078f:	e8 2d fc ff ff       	call   8003c1 <fd_lookup>
  800794:	83 c4 08             	add    $0x8,%esp
  800797:	85 c0                	test   %eax,%eax
  800799:	78 0e                	js     8007a9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80079b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80079e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007a1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007a9:	c9                   	leave  
  8007aa:	c3                   	ret    

008007ab <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007ab:	55                   	push   %ebp
  8007ac:	89 e5                	mov    %esp,%ebp
  8007ae:	53                   	push   %ebx
  8007af:	83 ec 14             	sub    $0x14,%esp
  8007b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007b5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007b8:	50                   	push   %eax
  8007b9:	53                   	push   %ebx
  8007ba:	e8 02 fc ff ff       	call   8003c1 <fd_lookup>
  8007bf:	83 c4 08             	add    $0x8,%esp
  8007c2:	85 c0                	test   %eax,%eax
  8007c4:	78 37                	js     8007fd <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007c6:	83 ec 08             	sub    $0x8,%esp
  8007c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007cc:	50                   	push   %eax
  8007cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007d0:	ff 30                	pushl  (%eax)
  8007d2:	e8 40 fc ff ff       	call   800417 <dev_lookup>
  8007d7:	83 c4 10             	add    $0x10,%esp
  8007da:	85 c0                	test   %eax,%eax
  8007dc:	78 1f                	js     8007fd <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007e5:	74 1b                	je     800802 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8007e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007ea:	8b 52 18             	mov    0x18(%edx),%edx
  8007ed:	85 d2                	test   %edx,%edx
  8007ef:	74 32                	je     800823 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8007f1:	83 ec 08             	sub    $0x8,%esp
  8007f4:	ff 75 0c             	pushl  0xc(%ebp)
  8007f7:	50                   	push   %eax
  8007f8:	ff d2                	call   *%edx
  8007fa:	83 c4 10             	add    $0x10,%esp
}
  8007fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800800:	c9                   	leave  
  800801:	c3                   	ret    
			thisenv->env_id, fdnum);
  800802:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800807:	8b 40 48             	mov    0x48(%eax),%eax
  80080a:	83 ec 04             	sub    $0x4,%esp
  80080d:	53                   	push   %ebx
  80080e:	50                   	push   %eax
  80080f:	68 f8 1d 80 00       	push   $0x801df8
  800814:	e8 bb 08 00 00       	call   8010d4 <cprintf>
		return -E_INVAL;
  800819:	83 c4 10             	add    $0x10,%esp
  80081c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800821:	eb da                	jmp    8007fd <ftruncate+0x52>
		return -E_NOT_SUPP;
  800823:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800828:	eb d3                	jmp    8007fd <ftruncate+0x52>

0080082a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	53                   	push   %ebx
  80082e:	83 ec 14             	sub    $0x14,%esp
  800831:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800834:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800837:	50                   	push   %eax
  800838:	ff 75 08             	pushl  0x8(%ebp)
  80083b:	e8 81 fb ff ff       	call   8003c1 <fd_lookup>
  800840:	83 c4 08             	add    $0x8,%esp
  800843:	85 c0                	test   %eax,%eax
  800845:	78 4b                	js     800892 <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800847:	83 ec 08             	sub    $0x8,%esp
  80084a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80084d:	50                   	push   %eax
  80084e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800851:	ff 30                	pushl  (%eax)
  800853:	e8 bf fb ff ff       	call   800417 <dev_lookup>
  800858:	83 c4 10             	add    $0x10,%esp
  80085b:	85 c0                	test   %eax,%eax
  80085d:	78 33                	js     800892 <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  80085f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800862:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800866:	74 2f                	je     800897 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800868:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80086b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800872:	00 00 00 
	stat->st_isdir = 0;
  800875:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80087c:	00 00 00 
	stat->st_dev = dev;
  80087f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800885:	83 ec 08             	sub    $0x8,%esp
  800888:	53                   	push   %ebx
  800889:	ff 75 f0             	pushl  -0x10(%ebp)
  80088c:	ff 50 14             	call   *0x14(%eax)
  80088f:	83 c4 10             	add    $0x10,%esp
}
  800892:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800895:	c9                   	leave  
  800896:	c3                   	ret    
		return -E_NOT_SUPP;
  800897:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80089c:	eb f4                	jmp    800892 <fstat+0x68>

0080089e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80089e:	55                   	push   %ebp
  80089f:	89 e5                	mov    %esp,%ebp
  8008a1:	56                   	push   %esi
  8008a2:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008a3:	83 ec 08             	sub    $0x8,%esp
  8008a6:	6a 00                	push   $0x0
  8008a8:	ff 75 08             	pushl  0x8(%ebp)
  8008ab:	e8 da 01 00 00       	call   800a8a <open>
  8008b0:	89 c3                	mov    %eax,%ebx
  8008b2:	83 c4 10             	add    $0x10,%esp
  8008b5:	85 c0                	test   %eax,%eax
  8008b7:	78 1b                	js     8008d4 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008b9:	83 ec 08             	sub    $0x8,%esp
  8008bc:	ff 75 0c             	pushl  0xc(%ebp)
  8008bf:	50                   	push   %eax
  8008c0:	e8 65 ff ff ff       	call   80082a <fstat>
  8008c5:	89 c6                	mov    %eax,%esi
	close(fd);
  8008c7:	89 1c 24             	mov    %ebx,(%esp)
  8008ca:	e8 27 fc ff ff       	call   8004f6 <close>
	return r;
  8008cf:	83 c4 10             	add    $0x10,%esp
  8008d2:	89 f3                	mov    %esi,%ebx
}
  8008d4:	89 d8                	mov    %ebx,%eax
  8008d6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008d9:	5b                   	pop    %ebx
  8008da:	5e                   	pop    %esi
  8008db:	5d                   	pop    %ebp
  8008dc:	c3                   	ret    

008008dd <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008dd:	55                   	push   %ebp
  8008de:	89 e5                	mov    %esp,%ebp
  8008e0:	56                   	push   %esi
  8008e1:	53                   	push   %ebx
  8008e2:	89 c6                	mov    %eax,%esi
  8008e4:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008e6:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8008ed:	74 27                	je     800916 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008ef:	6a 07                	push   $0x7
  8008f1:	68 00 50 80 00       	push   $0x805000
  8008f6:	56                   	push   %esi
  8008f7:	ff 35 00 40 80 00    	pushl  0x804000
  8008fd:	e8 95 11 00 00       	call   801a97 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800902:	83 c4 0c             	add    $0xc,%esp
  800905:	6a 00                	push   $0x0
  800907:	53                   	push   %ebx
  800908:	6a 00                	push   $0x0
  80090a:	e8 21 11 00 00       	call   801a30 <ipc_recv>
}
  80090f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800912:	5b                   	pop    %ebx
  800913:	5e                   	pop    %esi
  800914:	5d                   	pop    %ebp
  800915:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800916:	83 ec 0c             	sub    $0xc,%esp
  800919:	6a 01                	push   $0x1
  80091b:	e8 cb 11 00 00       	call   801aeb <ipc_find_env>
  800920:	a3 00 40 80 00       	mov    %eax,0x804000
  800925:	83 c4 10             	add    $0x10,%esp
  800928:	eb c5                	jmp    8008ef <fsipc+0x12>

0080092a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800930:	8b 45 08             	mov    0x8(%ebp),%eax
  800933:	8b 40 0c             	mov    0xc(%eax),%eax
  800936:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80093b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800943:	ba 00 00 00 00       	mov    $0x0,%edx
  800948:	b8 02 00 00 00       	mov    $0x2,%eax
  80094d:	e8 8b ff ff ff       	call   8008dd <fsipc>
}
  800952:	c9                   	leave  
  800953:	c3                   	ret    

00800954 <devfile_flush>:
{
  800954:	55                   	push   %ebp
  800955:	89 e5                	mov    %esp,%ebp
  800957:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80095a:	8b 45 08             	mov    0x8(%ebp),%eax
  80095d:	8b 40 0c             	mov    0xc(%eax),%eax
  800960:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800965:	ba 00 00 00 00       	mov    $0x0,%edx
  80096a:	b8 06 00 00 00       	mov    $0x6,%eax
  80096f:	e8 69 ff ff ff       	call   8008dd <fsipc>
}
  800974:	c9                   	leave  
  800975:	c3                   	ret    

00800976 <devfile_stat>:
{
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	53                   	push   %ebx
  80097a:	83 ec 04             	sub    $0x4,%esp
  80097d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800980:	8b 45 08             	mov    0x8(%ebp),%eax
  800983:	8b 40 0c             	mov    0xc(%eax),%eax
  800986:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80098b:	ba 00 00 00 00       	mov    $0x0,%edx
  800990:	b8 05 00 00 00       	mov    $0x5,%eax
  800995:	e8 43 ff ff ff       	call   8008dd <fsipc>
  80099a:	85 c0                	test   %eax,%eax
  80099c:	78 2c                	js     8009ca <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80099e:	83 ec 08             	sub    $0x8,%esp
  8009a1:	68 00 50 80 00       	push   $0x805000
  8009a6:	53                   	push   %ebx
  8009a7:	e8 47 0d 00 00       	call   8016f3 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009ac:	a1 80 50 80 00       	mov    0x805080,%eax
  8009b1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009b7:	a1 84 50 80 00       	mov    0x805084,%eax
  8009bc:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009c2:	83 c4 10             	add    $0x10,%esp
  8009c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009cd:	c9                   	leave  
  8009ce:	c3                   	ret    

008009cf <devfile_write>:
{
  8009cf:	55                   	push   %ebp
  8009d0:	89 e5                	mov    %esp,%ebp
  8009d2:	83 ec 0c             	sub    $0xc,%esp
  8009d5:	8b 45 10             	mov    0x10(%ebp),%eax
    	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8009db:	8b 52 0c             	mov    0xc(%edx),%edx
  8009de:	89 15 00 50 80 00    	mov    %edx,0x805000
    	fsipcbuf.write.req_n = n;
  8009e4:	a3 04 50 80 00       	mov    %eax,0x805004
    	memmove(fsipcbuf.write.req_buf, buf, n);
  8009e9:	50                   	push   %eax
  8009ea:	ff 75 0c             	pushl  0xc(%ebp)
  8009ed:	68 08 50 80 00       	push   $0x805008
  8009f2:	e8 8a 0e 00 00       	call   801881 <memmove>
    	return fsipc(FSREQ_WRITE, NULL);
  8009f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8009fc:	b8 04 00 00 00       	mov    $0x4,%eax
  800a01:	e8 d7 fe ff ff       	call   8008dd <fsipc>
}
  800a06:	c9                   	leave  
  800a07:	c3                   	ret    

00800a08 <devfile_read>:
{
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	56                   	push   %esi
  800a0c:	53                   	push   %ebx
  800a0d:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a10:	8b 45 08             	mov    0x8(%ebp),%eax
  800a13:	8b 40 0c             	mov    0xc(%eax),%eax
  800a16:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a1b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a21:	ba 00 00 00 00       	mov    $0x0,%edx
  800a26:	b8 03 00 00 00       	mov    $0x3,%eax
  800a2b:	e8 ad fe ff ff       	call   8008dd <fsipc>
  800a30:	89 c3                	mov    %eax,%ebx
  800a32:	85 c0                	test   %eax,%eax
  800a34:	78 1f                	js     800a55 <devfile_read+0x4d>
	assert(r <= n);
  800a36:	39 f0                	cmp    %esi,%eax
  800a38:	77 24                	ja     800a5e <devfile_read+0x56>
	assert(r <= PGSIZE);
  800a3a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a3f:	7f 33                	jg     800a74 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a41:	83 ec 04             	sub    $0x4,%esp
  800a44:	50                   	push   %eax
  800a45:	68 00 50 80 00       	push   $0x805000
  800a4a:	ff 75 0c             	pushl  0xc(%ebp)
  800a4d:	e8 2f 0e 00 00       	call   801881 <memmove>
	return r;
  800a52:	83 c4 10             	add    $0x10,%esp
}
  800a55:	89 d8                	mov    %ebx,%eax
  800a57:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a5a:	5b                   	pop    %ebx
  800a5b:	5e                   	pop    %esi
  800a5c:	5d                   	pop    %ebp
  800a5d:	c3                   	ret    
	assert(r <= n);
  800a5e:	68 64 1e 80 00       	push   $0x801e64
  800a63:	68 6b 1e 80 00       	push   $0x801e6b
  800a68:	6a 7c                	push   $0x7c
  800a6a:	68 80 1e 80 00       	push   $0x801e80
  800a6f:	e8 85 05 00 00       	call   800ff9 <_panic>
	assert(r <= PGSIZE);
  800a74:	68 8b 1e 80 00       	push   $0x801e8b
  800a79:	68 6b 1e 80 00       	push   $0x801e6b
  800a7e:	6a 7d                	push   $0x7d
  800a80:	68 80 1e 80 00       	push   $0x801e80
  800a85:	e8 6f 05 00 00       	call   800ff9 <_panic>

00800a8a <open>:
{
  800a8a:	55                   	push   %ebp
  800a8b:	89 e5                	mov    %esp,%ebp
  800a8d:	56                   	push   %esi
  800a8e:	53                   	push   %ebx
  800a8f:	83 ec 1c             	sub    $0x1c,%esp
  800a92:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800a95:	56                   	push   %esi
  800a96:	e8 21 0c 00 00       	call   8016bc <strlen>
  800a9b:	83 c4 10             	add    $0x10,%esp
  800a9e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800aa3:	7f 6c                	jg     800b11 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  800aa5:	83 ec 0c             	sub    $0xc,%esp
  800aa8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800aab:	50                   	push   %eax
  800aac:	e8 c1 f8 ff ff       	call   800372 <fd_alloc>
  800ab1:	89 c3                	mov    %eax,%ebx
  800ab3:	83 c4 10             	add    $0x10,%esp
  800ab6:	85 c0                	test   %eax,%eax
  800ab8:	78 3c                	js     800af6 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  800aba:	83 ec 08             	sub    $0x8,%esp
  800abd:	56                   	push   %esi
  800abe:	68 00 50 80 00       	push   $0x805000
  800ac3:	e8 2b 0c 00 00       	call   8016f3 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ac8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800acb:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800ad0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ad3:	b8 01 00 00 00       	mov    $0x1,%eax
  800ad8:	e8 00 fe ff ff       	call   8008dd <fsipc>
  800add:	89 c3                	mov    %eax,%ebx
  800adf:	83 c4 10             	add    $0x10,%esp
  800ae2:	85 c0                	test   %eax,%eax
  800ae4:	78 19                	js     800aff <open+0x75>
	return fd2num(fd);
  800ae6:	83 ec 0c             	sub    $0xc,%esp
  800ae9:	ff 75 f4             	pushl  -0xc(%ebp)
  800aec:	e8 5a f8 ff ff       	call   80034b <fd2num>
  800af1:	89 c3                	mov    %eax,%ebx
  800af3:	83 c4 10             	add    $0x10,%esp
}
  800af6:	89 d8                	mov    %ebx,%eax
  800af8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800afb:	5b                   	pop    %ebx
  800afc:	5e                   	pop    %esi
  800afd:	5d                   	pop    %ebp
  800afe:	c3                   	ret    
		fd_close(fd, 0);
  800aff:	83 ec 08             	sub    $0x8,%esp
  800b02:	6a 00                	push   $0x0
  800b04:	ff 75 f4             	pushl  -0xc(%ebp)
  800b07:	e8 61 f9 ff ff       	call   80046d <fd_close>
		return r;
  800b0c:	83 c4 10             	add    $0x10,%esp
  800b0f:	eb e5                	jmp    800af6 <open+0x6c>
		return -E_BAD_PATH;
  800b11:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b16:	eb de                	jmp    800af6 <open+0x6c>

00800b18 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b1e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b23:	b8 08 00 00 00       	mov    $0x8,%eax
  800b28:	e8 b0 fd ff ff       	call   8008dd <fsipc>
}
  800b2d:	c9                   	leave  
  800b2e:	c3                   	ret    

00800b2f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	56                   	push   %esi
  800b33:	53                   	push   %ebx
  800b34:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b37:	83 ec 0c             	sub    $0xc,%esp
  800b3a:	ff 75 08             	pushl  0x8(%ebp)
  800b3d:	e8 19 f8 ff ff       	call   80035b <fd2data>
  800b42:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b44:	83 c4 08             	add    $0x8,%esp
  800b47:	68 97 1e 80 00       	push   $0x801e97
  800b4c:	53                   	push   %ebx
  800b4d:	e8 a1 0b 00 00       	call   8016f3 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b52:	8b 46 04             	mov    0x4(%esi),%eax
  800b55:	2b 06                	sub    (%esi),%eax
  800b57:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b5d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b64:	00 00 00 
	stat->st_dev = &devpipe;
  800b67:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b6e:	30 80 00 
	return 0;
}
  800b71:	b8 00 00 00 00       	mov    $0x0,%eax
  800b76:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b79:	5b                   	pop    %ebx
  800b7a:	5e                   	pop    %esi
  800b7b:	5d                   	pop    %ebp
  800b7c:	c3                   	ret    

00800b7d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	53                   	push   %ebx
  800b81:	83 ec 0c             	sub    $0xc,%esp
  800b84:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b87:	53                   	push   %ebx
  800b88:	6a 00                	push   $0x0
  800b8a:	e8 50 f6 ff ff       	call   8001df <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b8f:	89 1c 24             	mov    %ebx,(%esp)
  800b92:	e8 c4 f7 ff ff       	call   80035b <fd2data>
  800b97:	83 c4 08             	add    $0x8,%esp
  800b9a:	50                   	push   %eax
  800b9b:	6a 00                	push   $0x0
  800b9d:	e8 3d f6 ff ff       	call   8001df <sys_page_unmap>
}
  800ba2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ba5:	c9                   	leave  
  800ba6:	c3                   	ret    

00800ba7 <_pipeisclosed>:
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
  800baa:	57                   	push   %edi
  800bab:	56                   	push   %esi
  800bac:	53                   	push   %ebx
  800bad:	83 ec 1c             	sub    $0x1c,%esp
  800bb0:	89 c7                	mov    %eax,%edi
  800bb2:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800bb4:	a1 04 40 80 00       	mov    0x804004,%eax
  800bb9:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800bbc:	83 ec 0c             	sub    $0xc,%esp
  800bbf:	57                   	push   %edi
  800bc0:	e8 5f 0f 00 00       	call   801b24 <pageref>
  800bc5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800bc8:	89 34 24             	mov    %esi,(%esp)
  800bcb:	e8 54 0f 00 00       	call   801b24 <pageref>
		nn = thisenv->env_runs;
  800bd0:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800bd6:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800bd9:	83 c4 10             	add    $0x10,%esp
  800bdc:	39 cb                	cmp    %ecx,%ebx
  800bde:	74 1b                	je     800bfb <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800be0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800be3:	75 cf                	jne    800bb4 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800be5:	8b 42 58             	mov    0x58(%edx),%eax
  800be8:	6a 01                	push   $0x1
  800bea:	50                   	push   %eax
  800beb:	53                   	push   %ebx
  800bec:	68 9e 1e 80 00       	push   $0x801e9e
  800bf1:	e8 de 04 00 00       	call   8010d4 <cprintf>
  800bf6:	83 c4 10             	add    $0x10,%esp
  800bf9:	eb b9                	jmp    800bb4 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800bfb:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800bfe:	0f 94 c0             	sete   %al
  800c01:	0f b6 c0             	movzbl %al,%eax
}
  800c04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c07:	5b                   	pop    %ebx
  800c08:	5e                   	pop    %esi
  800c09:	5f                   	pop    %edi
  800c0a:	5d                   	pop    %ebp
  800c0b:	c3                   	ret    

00800c0c <devpipe_write>:
{
  800c0c:	55                   	push   %ebp
  800c0d:	89 e5                	mov    %esp,%ebp
  800c0f:	57                   	push   %edi
  800c10:	56                   	push   %esi
  800c11:	53                   	push   %ebx
  800c12:	83 ec 28             	sub    $0x28,%esp
  800c15:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800c18:	56                   	push   %esi
  800c19:	e8 3d f7 ff ff       	call   80035b <fd2data>
  800c1e:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c20:	83 c4 10             	add    $0x10,%esp
  800c23:	bf 00 00 00 00       	mov    $0x0,%edi
  800c28:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c2b:	74 4f                	je     800c7c <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c2d:	8b 43 04             	mov    0x4(%ebx),%eax
  800c30:	8b 0b                	mov    (%ebx),%ecx
  800c32:	8d 51 20             	lea    0x20(%ecx),%edx
  800c35:	39 d0                	cmp    %edx,%eax
  800c37:	72 14                	jb     800c4d <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  800c39:	89 da                	mov    %ebx,%edx
  800c3b:	89 f0                	mov    %esi,%eax
  800c3d:	e8 65 ff ff ff       	call   800ba7 <_pipeisclosed>
  800c42:	85 c0                	test   %eax,%eax
  800c44:	75 3a                	jne    800c80 <devpipe_write+0x74>
			sys_yield();
  800c46:	e8 f0 f4 ff ff       	call   80013b <sys_yield>
  800c4b:	eb e0                	jmp    800c2d <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c50:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c54:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c57:	89 c2                	mov    %eax,%edx
  800c59:	c1 fa 1f             	sar    $0x1f,%edx
  800c5c:	89 d1                	mov    %edx,%ecx
  800c5e:	c1 e9 1b             	shr    $0x1b,%ecx
  800c61:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c64:	83 e2 1f             	and    $0x1f,%edx
  800c67:	29 ca                	sub    %ecx,%edx
  800c69:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c6d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c71:	83 c0 01             	add    $0x1,%eax
  800c74:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800c77:	83 c7 01             	add    $0x1,%edi
  800c7a:	eb ac                	jmp    800c28 <devpipe_write+0x1c>
	return i;
  800c7c:	89 f8                	mov    %edi,%eax
  800c7e:	eb 05                	jmp    800c85 <devpipe_write+0x79>
				return 0;
  800c80:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c88:	5b                   	pop    %ebx
  800c89:	5e                   	pop    %esi
  800c8a:	5f                   	pop    %edi
  800c8b:	5d                   	pop    %ebp
  800c8c:	c3                   	ret    

00800c8d <devpipe_read>:
{
  800c8d:	55                   	push   %ebp
  800c8e:	89 e5                	mov    %esp,%ebp
  800c90:	57                   	push   %edi
  800c91:	56                   	push   %esi
  800c92:	53                   	push   %ebx
  800c93:	83 ec 18             	sub    $0x18,%esp
  800c96:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800c99:	57                   	push   %edi
  800c9a:	e8 bc f6 ff ff       	call   80035b <fd2data>
  800c9f:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800ca1:	83 c4 10             	add    $0x10,%esp
  800ca4:	be 00 00 00 00       	mov    $0x0,%esi
  800ca9:	3b 75 10             	cmp    0x10(%ebp),%esi
  800cac:	74 47                	je     800cf5 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  800cae:	8b 03                	mov    (%ebx),%eax
  800cb0:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cb3:	75 22                	jne    800cd7 <devpipe_read+0x4a>
			if (i > 0)
  800cb5:	85 f6                	test   %esi,%esi
  800cb7:	75 14                	jne    800ccd <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  800cb9:	89 da                	mov    %ebx,%edx
  800cbb:	89 f8                	mov    %edi,%eax
  800cbd:	e8 e5 fe ff ff       	call   800ba7 <_pipeisclosed>
  800cc2:	85 c0                	test   %eax,%eax
  800cc4:	75 33                	jne    800cf9 <devpipe_read+0x6c>
			sys_yield();
  800cc6:	e8 70 f4 ff ff       	call   80013b <sys_yield>
  800ccb:	eb e1                	jmp    800cae <devpipe_read+0x21>
				return i;
  800ccd:	89 f0                	mov    %esi,%eax
}
  800ccf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd2:	5b                   	pop    %ebx
  800cd3:	5e                   	pop    %esi
  800cd4:	5f                   	pop    %edi
  800cd5:	5d                   	pop    %ebp
  800cd6:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cd7:	99                   	cltd   
  800cd8:	c1 ea 1b             	shr    $0x1b,%edx
  800cdb:	01 d0                	add    %edx,%eax
  800cdd:	83 e0 1f             	and    $0x1f,%eax
  800ce0:	29 d0                	sub    %edx,%eax
  800ce2:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800ce7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cea:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800ced:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800cf0:	83 c6 01             	add    $0x1,%esi
  800cf3:	eb b4                	jmp    800ca9 <devpipe_read+0x1c>
	return i;
  800cf5:	89 f0                	mov    %esi,%eax
  800cf7:	eb d6                	jmp    800ccf <devpipe_read+0x42>
				return 0;
  800cf9:	b8 00 00 00 00       	mov    $0x0,%eax
  800cfe:	eb cf                	jmp    800ccf <devpipe_read+0x42>

00800d00 <pipe>:
{
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
  800d03:	56                   	push   %esi
  800d04:	53                   	push   %ebx
  800d05:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800d08:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d0b:	50                   	push   %eax
  800d0c:	e8 61 f6 ff ff       	call   800372 <fd_alloc>
  800d11:	89 c3                	mov    %eax,%ebx
  800d13:	83 c4 10             	add    $0x10,%esp
  800d16:	85 c0                	test   %eax,%eax
  800d18:	78 5b                	js     800d75 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d1a:	83 ec 04             	sub    $0x4,%esp
  800d1d:	68 07 04 00 00       	push   $0x407
  800d22:	ff 75 f4             	pushl  -0xc(%ebp)
  800d25:	6a 00                	push   $0x0
  800d27:	e8 2e f4 ff ff       	call   80015a <sys_page_alloc>
  800d2c:	89 c3                	mov    %eax,%ebx
  800d2e:	83 c4 10             	add    $0x10,%esp
  800d31:	85 c0                	test   %eax,%eax
  800d33:	78 40                	js     800d75 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  800d35:	83 ec 0c             	sub    $0xc,%esp
  800d38:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d3b:	50                   	push   %eax
  800d3c:	e8 31 f6 ff ff       	call   800372 <fd_alloc>
  800d41:	89 c3                	mov    %eax,%ebx
  800d43:	83 c4 10             	add    $0x10,%esp
  800d46:	85 c0                	test   %eax,%eax
  800d48:	78 1b                	js     800d65 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d4a:	83 ec 04             	sub    $0x4,%esp
  800d4d:	68 07 04 00 00       	push   $0x407
  800d52:	ff 75 f0             	pushl  -0x10(%ebp)
  800d55:	6a 00                	push   $0x0
  800d57:	e8 fe f3 ff ff       	call   80015a <sys_page_alloc>
  800d5c:	89 c3                	mov    %eax,%ebx
  800d5e:	83 c4 10             	add    $0x10,%esp
  800d61:	85 c0                	test   %eax,%eax
  800d63:	79 19                	jns    800d7e <pipe+0x7e>
	sys_page_unmap(0, fd0);
  800d65:	83 ec 08             	sub    $0x8,%esp
  800d68:	ff 75 f4             	pushl  -0xc(%ebp)
  800d6b:	6a 00                	push   $0x0
  800d6d:	e8 6d f4 ff ff       	call   8001df <sys_page_unmap>
  800d72:	83 c4 10             	add    $0x10,%esp
}
  800d75:	89 d8                	mov    %ebx,%eax
  800d77:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d7a:	5b                   	pop    %ebx
  800d7b:	5e                   	pop    %esi
  800d7c:	5d                   	pop    %ebp
  800d7d:	c3                   	ret    
	va = fd2data(fd0);
  800d7e:	83 ec 0c             	sub    $0xc,%esp
  800d81:	ff 75 f4             	pushl  -0xc(%ebp)
  800d84:	e8 d2 f5 ff ff       	call   80035b <fd2data>
  800d89:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d8b:	83 c4 0c             	add    $0xc,%esp
  800d8e:	68 07 04 00 00       	push   $0x407
  800d93:	50                   	push   %eax
  800d94:	6a 00                	push   $0x0
  800d96:	e8 bf f3 ff ff       	call   80015a <sys_page_alloc>
  800d9b:	89 c3                	mov    %eax,%ebx
  800d9d:	83 c4 10             	add    $0x10,%esp
  800da0:	85 c0                	test   %eax,%eax
  800da2:	0f 88 8c 00 00 00    	js     800e34 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800da8:	83 ec 0c             	sub    $0xc,%esp
  800dab:	ff 75 f0             	pushl  -0x10(%ebp)
  800dae:	e8 a8 f5 ff ff       	call   80035b <fd2data>
  800db3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dba:	50                   	push   %eax
  800dbb:	6a 00                	push   $0x0
  800dbd:	56                   	push   %esi
  800dbe:	6a 00                	push   $0x0
  800dc0:	e8 d8 f3 ff ff       	call   80019d <sys_page_map>
  800dc5:	89 c3                	mov    %eax,%ebx
  800dc7:	83 c4 20             	add    $0x20,%esp
  800dca:	85 c0                	test   %eax,%eax
  800dcc:	78 58                	js     800e26 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  800dce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dd1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800dd7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800dd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ddc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  800de3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800de6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800dec:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800dee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800df1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800df8:	83 ec 0c             	sub    $0xc,%esp
  800dfb:	ff 75 f4             	pushl  -0xc(%ebp)
  800dfe:	e8 48 f5 ff ff       	call   80034b <fd2num>
  800e03:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e06:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e08:	83 c4 04             	add    $0x4,%esp
  800e0b:	ff 75 f0             	pushl  -0x10(%ebp)
  800e0e:	e8 38 f5 ff ff       	call   80034b <fd2num>
  800e13:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e16:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e19:	83 c4 10             	add    $0x10,%esp
  800e1c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e21:	e9 4f ff ff ff       	jmp    800d75 <pipe+0x75>
	sys_page_unmap(0, va);
  800e26:	83 ec 08             	sub    $0x8,%esp
  800e29:	56                   	push   %esi
  800e2a:	6a 00                	push   $0x0
  800e2c:	e8 ae f3 ff ff       	call   8001df <sys_page_unmap>
  800e31:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800e34:	83 ec 08             	sub    $0x8,%esp
  800e37:	ff 75 f0             	pushl  -0x10(%ebp)
  800e3a:	6a 00                	push   $0x0
  800e3c:	e8 9e f3 ff ff       	call   8001df <sys_page_unmap>
  800e41:	83 c4 10             	add    $0x10,%esp
  800e44:	e9 1c ff ff ff       	jmp    800d65 <pipe+0x65>

00800e49 <pipeisclosed>:
{
  800e49:	55                   	push   %ebp
  800e4a:	89 e5                	mov    %esp,%ebp
  800e4c:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e4f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e52:	50                   	push   %eax
  800e53:	ff 75 08             	pushl  0x8(%ebp)
  800e56:	e8 66 f5 ff ff       	call   8003c1 <fd_lookup>
  800e5b:	83 c4 10             	add    $0x10,%esp
  800e5e:	85 c0                	test   %eax,%eax
  800e60:	78 18                	js     800e7a <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  800e62:	83 ec 0c             	sub    $0xc,%esp
  800e65:	ff 75 f4             	pushl  -0xc(%ebp)
  800e68:	e8 ee f4 ff ff       	call   80035b <fd2data>
	return _pipeisclosed(fd, p);
  800e6d:	89 c2                	mov    %eax,%edx
  800e6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e72:	e8 30 fd ff ff       	call   800ba7 <_pipeisclosed>
  800e77:	83 c4 10             	add    $0x10,%esp
}
  800e7a:	c9                   	leave  
  800e7b:	c3                   	ret    

00800e7c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e7c:	55                   	push   %ebp
  800e7d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e7f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e84:	5d                   	pop    %ebp
  800e85:	c3                   	ret    

00800e86 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e86:	55                   	push   %ebp
  800e87:	89 e5                	mov    %esp,%ebp
  800e89:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e8c:	68 b6 1e 80 00       	push   $0x801eb6
  800e91:	ff 75 0c             	pushl  0xc(%ebp)
  800e94:	e8 5a 08 00 00       	call   8016f3 <strcpy>
	return 0;
}
  800e99:	b8 00 00 00 00       	mov    $0x0,%eax
  800e9e:	c9                   	leave  
  800e9f:	c3                   	ret    

00800ea0 <devcons_write>:
{
  800ea0:	55                   	push   %ebp
  800ea1:	89 e5                	mov    %esp,%ebp
  800ea3:	57                   	push   %edi
  800ea4:	56                   	push   %esi
  800ea5:	53                   	push   %ebx
  800ea6:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800eac:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800eb1:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800eb7:	eb 2f                	jmp    800ee8 <devcons_write+0x48>
		m = n - tot;
  800eb9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ebc:	29 f3                	sub    %esi,%ebx
  800ebe:	83 fb 7f             	cmp    $0x7f,%ebx
  800ec1:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800ec6:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800ec9:	83 ec 04             	sub    $0x4,%esp
  800ecc:	53                   	push   %ebx
  800ecd:	89 f0                	mov    %esi,%eax
  800ecf:	03 45 0c             	add    0xc(%ebp),%eax
  800ed2:	50                   	push   %eax
  800ed3:	57                   	push   %edi
  800ed4:	e8 a8 09 00 00       	call   801881 <memmove>
		sys_cputs(buf, m);
  800ed9:	83 c4 08             	add    $0x8,%esp
  800edc:	53                   	push   %ebx
  800edd:	57                   	push   %edi
  800ede:	e8 bb f1 ff ff       	call   80009e <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800ee3:	01 de                	add    %ebx,%esi
  800ee5:	83 c4 10             	add    $0x10,%esp
  800ee8:	3b 75 10             	cmp    0x10(%ebp),%esi
  800eeb:	72 cc                	jb     800eb9 <devcons_write+0x19>
}
  800eed:	89 f0                	mov    %esi,%eax
  800eef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ef2:	5b                   	pop    %ebx
  800ef3:	5e                   	pop    %esi
  800ef4:	5f                   	pop    %edi
  800ef5:	5d                   	pop    %ebp
  800ef6:	c3                   	ret    

00800ef7 <devcons_read>:
{
  800ef7:	55                   	push   %ebp
  800ef8:	89 e5                	mov    %esp,%ebp
  800efa:	83 ec 08             	sub    $0x8,%esp
  800efd:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800f02:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f06:	75 07                	jne    800f0f <devcons_read+0x18>
}
  800f08:	c9                   	leave  
  800f09:	c3                   	ret    
		sys_yield();
  800f0a:	e8 2c f2 ff ff       	call   80013b <sys_yield>
	while ((c = sys_cgetc()) == 0)
  800f0f:	e8 a8 f1 ff ff       	call   8000bc <sys_cgetc>
  800f14:	85 c0                	test   %eax,%eax
  800f16:	74 f2                	je     800f0a <devcons_read+0x13>
	if (c < 0)
  800f18:	85 c0                	test   %eax,%eax
  800f1a:	78 ec                	js     800f08 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  800f1c:	83 f8 04             	cmp    $0x4,%eax
  800f1f:	74 0c                	je     800f2d <devcons_read+0x36>
	*(char*)vbuf = c;
  800f21:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f24:	88 02                	mov    %al,(%edx)
	return 1;
  800f26:	b8 01 00 00 00       	mov    $0x1,%eax
  800f2b:	eb db                	jmp    800f08 <devcons_read+0x11>
		return 0;
  800f2d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f32:	eb d4                	jmp    800f08 <devcons_read+0x11>

00800f34 <cputchar>:
{
  800f34:	55                   	push   %ebp
  800f35:	89 e5                	mov    %esp,%ebp
  800f37:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f3d:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800f40:	6a 01                	push   $0x1
  800f42:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f45:	50                   	push   %eax
  800f46:	e8 53 f1 ff ff       	call   80009e <sys_cputs>
}
  800f4b:	83 c4 10             	add    $0x10,%esp
  800f4e:	c9                   	leave  
  800f4f:	c3                   	ret    

00800f50 <getchar>:
{
  800f50:	55                   	push   %ebp
  800f51:	89 e5                	mov    %esp,%ebp
  800f53:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800f56:	6a 01                	push   $0x1
  800f58:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f5b:	50                   	push   %eax
  800f5c:	6a 00                	push   $0x0
  800f5e:	e8 cf f6 ff ff       	call   800632 <read>
	if (r < 0)
  800f63:	83 c4 10             	add    $0x10,%esp
  800f66:	85 c0                	test   %eax,%eax
  800f68:	78 08                	js     800f72 <getchar+0x22>
	if (r < 1)
  800f6a:	85 c0                	test   %eax,%eax
  800f6c:	7e 06                	jle    800f74 <getchar+0x24>
	return c;
  800f6e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800f72:	c9                   	leave  
  800f73:	c3                   	ret    
		return -E_EOF;
  800f74:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800f79:	eb f7                	jmp    800f72 <getchar+0x22>

00800f7b <iscons>:
{
  800f7b:	55                   	push   %ebp
  800f7c:	89 e5                	mov    %esp,%ebp
  800f7e:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f81:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f84:	50                   	push   %eax
  800f85:	ff 75 08             	pushl  0x8(%ebp)
  800f88:	e8 34 f4 ff ff       	call   8003c1 <fd_lookup>
  800f8d:	83 c4 10             	add    $0x10,%esp
  800f90:	85 c0                	test   %eax,%eax
  800f92:	78 11                	js     800fa5 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  800f94:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f97:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800f9d:	39 10                	cmp    %edx,(%eax)
  800f9f:	0f 94 c0             	sete   %al
  800fa2:	0f b6 c0             	movzbl %al,%eax
}
  800fa5:	c9                   	leave  
  800fa6:	c3                   	ret    

00800fa7 <opencons>:
{
  800fa7:	55                   	push   %ebp
  800fa8:	89 e5                	mov    %esp,%ebp
  800faa:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800fad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fb0:	50                   	push   %eax
  800fb1:	e8 bc f3 ff ff       	call   800372 <fd_alloc>
  800fb6:	83 c4 10             	add    $0x10,%esp
  800fb9:	85 c0                	test   %eax,%eax
  800fbb:	78 3a                	js     800ff7 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fbd:	83 ec 04             	sub    $0x4,%esp
  800fc0:	68 07 04 00 00       	push   $0x407
  800fc5:	ff 75 f4             	pushl  -0xc(%ebp)
  800fc8:	6a 00                	push   $0x0
  800fca:	e8 8b f1 ff ff       	call   80015a <sys_page_alloc>
  800fcf:	83 c4 10             	add    $0x10,%esp
  800fd2:	85 c0                	test   %eax,%eax
  800fd4:	78 21                	js     800ff7 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  800fd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fd9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fdf:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800fe1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fe4:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800feb:	83 ec 0c             	sub    $0xc,%esp
  800fee:	50                   	push   %eax
  800fef:	e8 57 f3 ff ff       	call   80034b <fd2num>
  800ff4:	83 c4 10             	add    $0x10,%esp
}
  800ff7:	c9                   	leave  
  800ff8:	c3                   	ret    

00800ff9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800ff9:	55                   	push   %ebp
  800ffa:	89 e5                	mov    %esp,%ebp
  800ffc:	56                   	push   %esi
  800ffd:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800ffe:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801001:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801007:	e8 10 f1 ff ff       	call   80011c <sys_getenvid>
  80100c:	83 ec 0c             	sub    $0xc,%esp
  80100f:	ff 75 0c             	pushl  0xc(%ebp)
  801012:	ff 75 08             	pushl  0x8(%ebp)
  801015:	56                   	push   %esi
  801016:	50                   	push   %eax
  801017:	68 c4 1e 80 00       	push   $0x801ec4
  80101c:	e8 b3 00 00 00       	call   8010d4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801021:	83 c4 18             	add    $0x18,%esp
  801024:	53                   	push   %ebx
  801025:	ff 75 10             	pushl  0x10(%ebp)
  801028:	e8 56 00 00 00       	call   801083 <vcprintf>
	cprintf("\n");
  80102d:	c7 04 24 af 1e 80 00 	movl   $0x801eaf,(%esp)
  801034:	e8 9b 00 00 00       	call   8010d4 <cprintf>
  801039:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80103c:	cc                   	int3   
  80103d:	eb fd                	jmp    80103c <_panic+0x43>

0080103f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80103f:	55                   	push   %ebp
  801040:	89 e5                	mov    %esp,%ebp
  801042:	53                   	push   %ebx
  801043:	83 ec 04             	sub    $0x4,%esp
  801046:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801049:	8b 13                	mov    (%ebx),%edx
  80104b:	8d 42 01             	lea    0x1(%edx),%eax
  80104e:	89 03                	mov    %eax,(%ebx)
  801050:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801053:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801057:	3d ff 00 00 00       	cmp    $0xff,%eax
  80105c:	74 09                	je     801067 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80105e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801062:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801065:	c9                   	leave  
  801066:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801067:	83 ec 08             	sub    $0x8,%esp
  80106a:	68 ff 00 00 00       	push   $0xff
  80106f:	8d 43 08             	lea    0x8(%ebx),%eax
  801072:	50                   	push   %eax
  801073:	e8 26 f0 ff ff       	call   80009e <sys_cputs>
		b->idx = 0;
  801078:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80107e:	83 c4 10             	add    $0x10,%esp
  801081:	eb db                	jmp    80105e <putch+0x1f>

00801083 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801083:	55                   	push   %ebp
  801084:	89 e5                	mov    %esp,%ebp
  801086:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80108c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801093:	00 00 00 
	b.cnt = 0;
  801096:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80109d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010a0:	ff 75 0c             	pushl  0xc(%ebp)
  8010a3:	ff 75 08             	pushl  0x8(%ebp)
  8010a6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010ac:	50                   	push   %eax
  8010ad:	68 3f 10 80 00       	push   $0x80103f
  8010b2:	e8 1a 01 00 00       	call   8011d1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010b7:	83 c4 08             	add    $0x8,%esp
  8010ba:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010c0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010c6:	50                   	push   %eax
  8010c7:	e8 d2 ef ff ff       	call   80009e <sys_cputs>

	return b.cnt;
}
  8010cc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010d2:	c9                   	leave  
  8010d3:	c3                   	ret    

008010d4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010d4:	55                   	push   %ebp
  8010d5:	89 e5                	mov    %esp,%ebp
  8010d7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010da:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010dd:	50                   	push   %eax
  8010de:	ff 75 08             	pushl  0x8(%ebp)
  8010e1:	e8 9d ff ff ff       	call   801083 <vcprintf>
	va_end(ap);

	return cnt;
}
  8010e6:	c9                   	leave  
  8010e7:	c3                   	ret    

008010e8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010e8:	55                   	push   %ebp
  8010e9:	89 e5                	mov    %esp,%ebp
  8010eb:	57                   	push   %edi
  8010ec:	56                   	push   %esi
  8010ed:	53                   	push   %ebx
  8010ee:	83 ec 1c             	sub    $0x1c,%esp
  8010f1:	89 c7                	mov    %eax,%edi
  8010f3:	89 d6                	mov    %edx,%esi
  8010f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010fb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8010fe:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801101:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801104:	bb 00 00 00 00       	mov    $0x0,%ebx
  801109:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80110c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80110f:	39 d3                	cmp    %edx,%ebx
  801111:	72 05                	jb     801118 <printnum+0x30>
  801113:	39 45 10             	cmp    %eax,0x10(%ebp)
  801116:	77 7a                	ja     801192 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801118:	83 ec 0c             	sub    $0xc,%esp
  80111b:	ff 75 18             	pushl  0x18(%ebp)
  80111e:	8b 45 14             	mov    0x14(%ebp),%eax
  801121:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801124:	53                   	push   %ebx
  801125:	ff 75 10             	pushl  0x10(%ebp)
  801128:	83 ec 08             	sub    $0x8,%esp
  80112b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80112e:	ff 75 e0             	pushl  -0x20(%ebp)
  801131:	ff 75 dc             	pushl  -0x24(%ebp)
  801134:	ff 75 d8             	pushl  -0x28(%ebp)
  801137:	e8 24 0a 00 00       	call   801b60 <__udivdi3>
  80113c:	83 c4 18             	add    $0x18,%esp
  80113f:	52                   	push   %edx
  801140:	50                   	push   %eax
  801141:	89 f2                	mov    %esi,%edx
  801143:	89 f8                	mov    %edi,%eax
  801145:	e8 9e ff ff ff       	call   8010e8 <printnum>
  80114a:	83 c4 20             	add    $0x20,%esp
  80114d:	eb 13                	jmp    801162 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80114f:	83 ec 08             	sub    $0x8,%esp
  801152:	56                   	push   %esi
  801153:	ff 75 18             	pushl  0x18(%ebp)
  801156:	ff d7                	call   *%edi
  801158:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80115b:	83 eb 01             	sub    $0x1,%ebx
  80115e:	85 db                	test   %ebx,%ebx
  801160:	7f ed                	jg     80114f <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801162:	83 ec 08             	sub    $0x8,%esp
  801165:	56                   	push   %esi
  801166:	83 ec 04             	sub    $0x4,%esp
  801169:	ff 75 e4             	pushl  -0x1c(%ebp)
  80116c:	ff 75 e0             	pushl  -0x20(%ebp)
  80116f:	ff 75 dc             	pushl  -0x24(%ebp)
  801172:	ff 75 d8             	pushl  -0x28(%ebp)
  801175:	e8 06 0b 00 00       	call   801c80 <__umoddi3>
  80117a:	83 c4 14             	add    $0x14,%esp
  80117d:	0f be 80 e7 1e 80 00 	movsbl 0x801ee7(%eax),%eax
  801184:	50                   	push   %eax
  801185:	ff d7                	call   *%edi
}
  801187:	83 c4 10             	add    $0x10,%esp
  80118a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80118d:	5b                   	pop    %ebx
  80118e:	5e                   	pop    %esi
  80118f:	5f                   	pop    %edi
  801190:	5d                   	pop    %ebp
  801191:	c3                   	ret    
  801192:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801195:	eb c4                	jmp    80115b <printnum+0x73>

00801197 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801197:	55                   	push   %ebp
  801198:	89 e5                	mov    %esp,%ebp
  80119a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80119d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011a1:	8b 10                	mov    (%eax),%edx
  8011a3:	3b 50 04             	cmp    0x4(%eax),%edx
  8011a6:	73 0a                	jae    8011b2 <sprintputch+0x1b>
		*b->buf++ = ch;
  8011a8:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011ab:	89 08                	mov    %ecx,(%eax)
  8011ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b0:	88 02                	mov    %al,(%edx)
}
  8011b2:	5d                   	pop    %ebp
  8011b3:	c3                   	ret    

008011b4 <printfmt>:
{
  8011b4:	55                   	push   %ebp
  8011b5:	89 e5                	mov    %esp,%ebp
  8011b7:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8011ba:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011bd:	50                   	push   %eax
  8011be:	ff 75 10             	pushl  0x10(%ebp)
  8011c1:	ff 75 0c             	pushl  0xc(%ebp)
  8011c4:	ff 75 08             	pushl  0x8(%ebp)
  8011c7:	e8 05 00 00 00       	call   8011d1 <vprintfmt>
}
  8011cc:	83 c4 10             	add    $0x10,%esp
  8011cf:	c9                   	leave  
  8011d0:	c3                   	ret    

008011d1 <vprintfmt>:
{
  8011d1:	55                   	push   %ebp
  8011d2:	89 e5                	mov    %esp,%ebp
  8011d4:	57                   	push   %edi
  8011d5:	56                   	push   %esi
  8011d6:	53                   	push   %ebx
  8011d7:	83 ec 2c             	sub    $0x2c,%esp
  8011da:	8b 75 08             	mov    0x8(%ebp),%esi
  8011dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8011e0:	8b 7d 10             	mov    0x10(%ebp),%edi
  8011e3:	e9 c1 03 00 00       	jmp    8015a9 <vprintfmt+0x3d8>
		padc = ' ';
  8011e8:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8011ec:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8011f3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8011fa:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  801201:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801206:	8d 47 01             	lea    0x1(%edi),%eax
  801209:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80120c:	0f b6 17             	movzbl (%edi),%edx
  80120f:	8d 42 dd             	lea    -0x23(%edx),%eax
  801212:	3c 55                	cmp    $0x55,%al
  801214:	0f 87 12 04 00 00    	ja     80162c <vprintfmt+0x45b>
  80121a:	0f b6 c0             	movzbl %al,%eax
  80121d:	ff 24 85 20 20 80 00 	jmp    *0x802020(,%eax,4)
  801224:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801227:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80122b:	eb d9                	jmp    801206 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80122d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  801230:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801234:	eb d0                	jmp    801206 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  801236:	0f b6 d2             	movzbl %dl,%edx
  801239:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80123c:	b8 00 00 00 00       	mov    $0x0,%eax
  801241:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801244:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801247:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80124b:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80124e:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801251:	83 f9 09             	cmp    $0x9,%ecx
  801254:	77 55                	ja     8012ab <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  801256:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801259:	eb e9                	jmp    801244 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  80125b:	8b 45 14             	mov    0x14(%ebp),%eax
  80125e:	8b 00                	mov    (%eax),%eax
  801260:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801263:	8b 45 14             	mov    0x14(%ebp),%eax
  801266:	8d 40 04             	lea    0x4(%eax),%eax
  801269:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80126c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80126f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801273:	79 91                	jns    801206 <vprintfmt+0x35>
				width = precision, precision = -1;
  801275:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801278:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80127b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801282:	eb 82                	jmp    801206 <vprintfmt+0x35>
  801284:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801287:	85 c0                	test   %eax,%eax
  801289:	ba 00 00 00 00       	mov    $0x0,%edx
  80128e:	0f 49 d0             	cmovns %eax,%edx
  801291:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801294:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801297:	e9 6a ff ff ff       	jmp    801206 <vprintfmt+0x35>
  80129c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80129f:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012a6:	e9 5b ff ff ff       	jmp    801206 <vprintfmt+0x35>
  8012ab:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8012ae:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012b1:	eb bc                	jmp    80126f <vprintfmt+0x9e>
			lflag++;
  8012b3:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8012b9:	e9 48 ff ff ff       	jmp    801206 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8012be:	8b 45 14             	mov    0x14(%ebp),%eax
  8012c1:	8d 78 04             	lea    0x4(%eax),%edi
  8012c4:	83 ec 08             	sub    $0x8,%esp
  8012c7:	53                   	push   %ebx
  8012c8:	ff 30                	pushl  (%eax)
  8012ca:	ff d6                	call   *%esi
			break;
  8012cc:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8012cf:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8012d2:	e9 cf 02 00 00       	jmp    8015a6 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8012d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8012da:	8d 78 04             	lea    0x4(%eax),%edi
  8012dd:	8b 00                	mov    (%eax),%eax
  8012df:	99                   	cltd   
  8012e0:	31 d0                	xor    %edx,%eax
  8012e2:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8012e4:	83 f8 0f             	cmp    $0xf,%eax
  8012e7:	7f 23                	jg     80130c <vprintfmt+0x13b>
  8012e9:	8b 14 85 80 21 80 00 	mov    0x802180(,%eax,4),%edx
  8012f0:	85 d2                	test   %edx,%edx
  8012f2:	74 18                	je     80130c <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8012f4:	52                   	push   %edx
  8012f5:	68 7d 1e 80 00       	push   $0x801e7d
  8012fa:	53                   	push   %ebx
  8012fb:	56                   	push   %esi
  8012fc:	e8 b3 fe ff ff       	call   8011b4 <printfmt>
  801301:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801304:	89 7d 14             	mov    %edi,0x14(%ebp)
  801307:	e9 9a 02 00 00       	jmp    8015a6 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  80130c:	50                   	push   %eax
  80130d:	68 ff 1e 80 00       	push   $0x801eff
  801312:	53                   	push   %ebx
  801313:	56                   	push   %esi
  801314:	e8 9b fe ff ff       	call   8011b4 <printfmt>
  801319:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80131c:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80131f:	e9 82 02 00 00       	jmp    8015a6 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  801324:	8b 45 14             	mov    0x14(%ebp),%eax
  801327:	83 c0 04             	add    $0x4,%eax
  80132a:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80132d:	8b 45 14             	mov    0x14(%ebp),%eax
  801330:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801332:	85 ff                	test   %edi,%edi
  801334:	b8 f8 1e 80 00       	mov    $0x801ef8,%eax
  801339:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80133c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801340:	0f 8e bd 00 00 00    	jle    801403 <vprintfmt+0x232>
  801346:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80134a:	75 0e                	jne    80135a <vprintfmt+0x189>
  80134c:	89 75 08             	mov    %esi,0x8(%ebp)
  80134f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801352:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801355:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801358:	eb 6d                	jmp    8013c7 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  80135a:	83 ec 08             	sub    $0x8,%esp
  80135d:	ff 75 d0             	pushl  -0x30(%ebp)
  801360:	57                   	push   %edi
  801361:	e8 6e 03 00 00       	call   8016d4 <strnlen>
  801366:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801369:	29 c1                	sub    %eax,%ecx
  80136b:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80136e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801371:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801375:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801378:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80137b:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  80137d:	eb 0f                	jmp    80138e <vprintfmt+0x1bd>
					putch(padc, putdat);
  80137f:	83 ec 08             	sub    $0x8,%esp
  801382:	53                   	push   %ebx
  801383:	ff 75 e0             	pushl  -0x20(%ebp)
  801386:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  801388:	83 ef 01             	sub    $0x1,%edi
  80138b:	83 c4 10             	add    $0x10,%esp
  80138e:	85 ff                	test   %edi,%edi
  801390:	7f ed                	jg     80137f <vprintfmt+0x1ae>
  801392:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801395:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  801398:	85 c9                	test   %ecx,%ecx
  80139a:	b8 00 00 00 00       	mov    $0x0,%eax
  80139f:	0f 49 c1             	cmovns %ecx,%eax
  8013a2:	29 c1                	sub    %eax,%ecx
  8013a4:	89 75 08             	mov    %esi,0x8(%ebp)
  8013a7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8013aa:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8013ad:	89 cb                	mov    %ecx,%ebx
  8013af:	eb 16                	jmp    8013c7 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8013b1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8013b5:	75 31                	jne    8013e8 <vprintfmt+0x217>
					putch(ch, putdat);
  8013b7:	83 ec 08             	sub    $0x8,%esp
  8013ba:	ff 75 0c             	pushl  0xc(%ebp)
  8013bd:	50                   	push   %eax
  8013be:	ff 55 08             	call   *0x8(%ebp)
  8013c1:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8013c4:	83 eb 01             	sub    $0x1,%ebx
  8013c7:	83 c7 01             	add    $0x1,%edi
  8013ca:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8013ce:	0f be c2             	movsbl %dl,%eax
  8013d1:	85 c0                	test   %eax,%eax
  8013d3:	74 59                	je     80142e <vprintfmt+0x25d>
  8013d5:	85 f6                	test   %esi,%esi
  8013d7:	78 d8                	js     8013b1 <vprintfmt+0x1e0>
  8013d9:	83 ee 01             	sub    $0x1,%esi
  8013dc:	79 d3                	jns    8013b1 <vprintfmt+0x1e0>
  8013de:	89 df                	mov    %ebx,%edi
  8013e0:	8b 75 08             	mov    0x8(%ebp),%esi
  8013e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8013e6:	eb 37                	jmp    80141f <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8013e8:	0f be d2             	movsbl %dl,%edx
  8013eb:	83 ea 20             	sub    $0x20,%edx
  8013ee:	83 fa 5e             	cmp    $0x5e,%edx
  8013f1:	76 c4                	jbe    8013b7 <vprintfmt+0x1e6>
					putch('?', putdat);
  8013f3:	83 ec 08             	sub    $0x8,%esp
  8013f6:	ff 75 0c             	pushl  0xc(%ebp)
  8013f9:	6a 3f                	push   $0x3f
  8013fb:	ff 55 08             	call   *0x8(%ebp)
  8013fe:	83 c4 10             	add    $0x10,%esp
  801401:	eb c1                	jmp    8013c4 <vprintfmt+0x1f3>
  801403:	89 75 08             	mov    %esi,0x8(%ebp)
  801406:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801409:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80140c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80140f:	eb b6                	jmp    8013c7 <vprintfmt+0x1f6>
				putch(' ', putdat);
  801411:	83 ec 08             	sub    $0x8,%esp
  801414:	53                   	push   %ebx
  801415:	6a 20                	push   $0x20
  801417:	ff d6                	call   *%esi
			for (; width > 0; width--)
  801419:	83 ef 01             	sub    $0x1,%edi
  80141c:	83 c4 10             	add    $0x10,%esp
  80141f:	85 ff                	test   %edi,%edi
  801421:	7f ee                	jg     801411 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  801423:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801426:	89 45 14             	mov    %eax,0x14(%ebp)
  801429:	e9 78 01 00 00       	jmp    8015a6 <vprintfmt+0x3d5>
  80142e:	89 df                	mov    %ebx,%edi
  801430:	8b 75 08             	mov    0x8(%ebp),%esi
  801433:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801436:	eb e7                	jmp    80141f <vprintfmt+0x24e>
	if (lflag >= 2)
  801438:	83 f9 01             	cmp    $0x1,%ecx
  80143b:	7e 3f                	jle    80147c <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  80143d:	8b 45 14             	mov    0x14(%ebp),%eax
  801440:	8b 50 04             	mov    0x4(%eax),%edx
  801443:	8b 00                	mov    (%eax),%eax
  801445:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801448:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80144b:	8b 45 14             	mov    0x14(%ebp),%eax
  80144e:	8d 40 08             	lea    0x8(%eax),%eax
  801451:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  801454:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801458:	79 5c                	jns    8014b6 <vprintfmt+0x2e5>
				putch('-', putdat);
  80145a:	83 ec 08             	sub    $0x8,%esp
  80145d:	53                   	push   %ebx
  80145e:	6a 2d                	push   $0x2d
  801460:	ff d6                	call   *%esi
				num = -(long long) num;
  801462:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801465:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801468:	f7 da                	neg    %edx
  80146a:	83 d1 00             	adc    $0x0,%ecx
  80146d:	f7 d9                	neg    %ecx
  80146f:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801472:	b8 0a 00 00 00       	mov    $0xa,%eax
  801477:	e9 10 01 00 00       	jmp    80158c <vprintfmt+0x3bb>
	else if (lflag)
  80147c:	85 c9                	test   %ecx,%ecx
  80147e:	75 1b                	jne    80149b <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  801480:	8b 45 14             	mov    0x14(%ebp),%eax
  801483:	8b 00                	mov    (%eax),%eax
  801485:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801488:	89 c1                	mov    %eax,%ecx
  80148a:	c1 f9 1f             	sar    $0x1f,%ecx
  80148d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801490:	8b 45 14             	mov    0x14(%ebp),%eax
  801493:	8d 40 04             	lea    0x4(%eax),%eax
  801496:	89 45 14             	mov    %eax,0x14(%ebp)
  801499:	eb b9                	jmp    801454 <vprintfmt+0x283>
		return va_arg(*ap, long);
  80149b:	8b 45 14             	mov    0x14(%ebp),%eax
  80149e:	8b 00                	mov    (%eax),%eax
  8014a0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014a3:	89 c1                	mov    %eax,%ecx
  8014a5:	c1 f9 1f             	sar    $0x1f,%ecx
  8014a8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ae:	8d 40 04             	lea    0x4(%eax),%eax
  8014b1:	89 45 14             	mov    %eax,0x14(%ebp)
  8014b4:	eb 9e                	jmp    801454 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8014b6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014b9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8014bc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014c1:	e9 c6 00 00 00       	jmp    80158c <vprintfmt+0x3bb>
	if (lflag >= 2)
  8014c6:	83 f9 01             	cmp    $0x1,%ecx
  8014c9:	7e 18                	jle    8014e3 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8014cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ce:	8b 10                	mov    (%eax),%edx
  8014d0:	8b 48 04             	mov    0x4(%eax),%ecx
  8014d3:	8d 40 08             	lea    0x8(%eax),%eax
  8014d6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8014d9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014de:	e9 a9 00 00 00       	jmp    80158c <vprintfmt+0x3bb>
	else if (lflag)
  8014e3:	85 c9                	test   %ecx,%ecx
  8014e5:	75 1a                	jne    801501 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  8014e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ea:	8b 10                	mov    (%eax),%edx
  8014ec:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014f1:	8d 40 04             	lea    0x4(%eax),%eax
  8014f4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8014f7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014fc:	e9 8b 00 00 00       	jmp    80158c <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  801501:	8b 45 14             	mov    0x14(%ebp),%eax
  801504:	8b 10                	mov    (%eax),%edx
  801506:	b9 00 00 00 00       	mov    $0x0,%ecx
  80150b:	8d 40 04             	lea    0x4(%eax),%eax
  80150e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801511:	b8 0a 00 00 00       	mov    $0xa,%eax
  801516:	eb 74                	jmp    80158c <vprintfmt+0x3bb>
	if (lflag >= 2)
  801518:	83 f9 01             	cmp    $0x1,%ecx
  80151b:	7e 15                	jle    801532 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  80151d:	8b 45 14             	mov    0x14(%ebp),%eax
  801520:	8b 10                	mov    (%eax),%edx
  801522:	8b 48 04             	mov    0x4(%eax),%ecx
  801525:	8d 40 08             	lea    0x8(%eax),%eax
  801528:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80152b:	b8 08 00 00 00       	mov    $0x8,%eax
  801530:	eb 5a                	jmp    80158c <vprintfmt+0x3bb>
	else if (lflag)
  801532:	85 c9                	test   %ecx,%ecx
  801534:	75 17                	jne    80154d <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  801536:	8b 45 14             	mov    0x14(%ebp),%eax
  801539:	8b 10                	mov    (%eax),%edx
  80153b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801540:	8d 40 04             	lea    0x4(%eax),%eax
  801543:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801546:	b8 08 00 00 00       	mov    $0x8,%eax
  80154b:	eb 3f                	jmp    80158c <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80154d:	8b 45 14             	mov    0x14(%ebp),%eax
  801550:	8b 10                	mov    (%eax),%edx
  801552:	b9 00 00 00 00       	mov    $0x0,%ecx
  801557:	8d 40 04             	lea    0x4(%eax),%eax
  80155a:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80155d:	b8 08 00 00 00       	mov    $0x8,%eax
  801562:	eb 28                	jmp    80158c <vprintfmt+0x3bb>
			putch('0', putdat);
  801564:	83 ec 08             	sub    $0x8,%esp
  801567:	53                   	push   %ebx
  801568:	6a 30                	push   $0x30
  80156a:	ff d6                	call   *%esi
			putch('x', putdat);
  80156c:	83 c4 08             	add    $0x8,%esp
  80156f:	53                   	push   %ebx
  801570:	6a 78                	push   $0x78
  801572:	ff d6                	call   *%esi
			num = (unsigned long long)
  801574:	8b 45 14             	mov    0x14(%ebp),%eax
  801577:	8b 10                	mov    (%eax),%edx
  801579:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80157e:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801581:	8d 40 04             	lea    0x4(%eax),%eax
  801584:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801587:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80158c:	83 ec 0c             	sub    $0xc,%esp
  80158f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801593:	57                   	push   %edi
  801594:	ff 75 e0             	pushl  -0x20(%ebp)
  801597:	50                   	push   %eax
  801598:	51                   	push   %ecx
  801599:	52                   	push   %edx
  80159a:	89 da                	mov    %ebx,%edx
  80159c:	89 f0                	mov    %esi,%eax
  80159e:	e8 45 fb ff ff       	call   8010e8 <printnum>
			break;
  8015a3:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8015a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8015a9:	83 c7 01             	add    $0x1,%edi
  8015ac:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8015b0:	83 f8 25             	cmp    $0x25,%eax
  8015b3:	0f 84 2f fc ff ff    	je     8011e8 <vprintfmt+0x17>
			if (ch == '\0')
  8015b9:	85 c0                	test   %eax,%eax
  8015bb:	0f 84 8b 00 00 00    	je     80164c <vprintfmt+0x47b>
			putch(ch, putdat);
  8015c1:	83 ec 08             	sub    $0x8,%esp
  8015c4:	53                   	push   %ebx
  8015c5:	50                   	push   %eax
  8015c6:	ff d6                	call   *%esi
  8015c8:	83 c4 10             	add    $0x10,%esp
  8015cb:	eb dc                	jmp    8015a9 <vprintfmt+0x3d8>
	if (lflag >= 2)
  8015cd:	83 f9 01             	cmp    $0x1,%ecx
  8015d0:	7e 15                	jle    8015e7 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  8015d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8015d5:	8b 10                	mov    (%eax),%edx
  8015d7:	8b 48 04             	mov    0x4(%eax),%ecx
  8015da:	8d 40 08             	lea    0x8(%eax),%eax
  8015dd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015e0:	b8 10 00 00 00       	mov    $0x10,%eax
  8015e5:	eb a5                	jmp    80158c <vprintfmt+0x3bb>
	else if (lflag)
  8015e7:	85 c9                	test   %ecx,%ecx
  8015e9:	75 17                	jne    801602 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  8015eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8015ee:	8b 10                	mov    (%eax),%edx
  8015f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015f5:	8d 40 04             	lea    0x4(%eax),%eax
  8015f8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015fb:	b8 10 00 00 00       	mov    $0x10,%eax
  801600:	eb 8a                	jmp    80158c <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  801602:	8b 45 14             	mov    0x14(%ebp),%eax
  801605:	8b 10                	mov    (%eax),%edx
  801607:	b9 00 00 00 00       	mov    $0x0,%ecx
  80160c:	8d 40 04             	lea    0x4(%eax),%eax
  80160f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801612:	b8 10 00 00 00       	mov    $0x10,%eax
  801617:	e9 70 ff ff ff       	jmp    80158c <vprintfmt+0x3bb>
			putch(ch, putdat);
  80161c:	83 ec 08             	sub    $0x8,%esp
  80161f:	53                   	push   %ebx
  801620:	6a 25                	push   $0x25
  801622:	ff d6                	call   *%esi
			break;
  801624:	83 c4 10             	add    $0x10,%esp
  801627:	e9 7a ff ff ff       	jmp    8015a6 <vprintfmt+0x3d5>
			putch('%', putdat);
  80162c:	83 ec 08             	sub    $0x8,%esp
  80162f:	53                   	push   %ebx
  801630:	6a 25                	push   $0x25
  801632:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801634:	83 c4 10             	add    $0x10,%esp
  801637:	89 f8                	mov    %edi,%eax
  801639:	eb 03                	jmp    80163e <vprintfmt+0x46d>
  80163b:	83 e8 01             	sub    $0x1,%eax
  80163e:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801642:	75 f7                	jne    80163b <vprintfmt+0x46a>
  801644:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801647:	e9 5a ff ff ff       	jmp    8015a6 <vprintfmt+0x3d5>
}
  80164c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80164f:	5b                   	pop    %ebx
  801650:	5e                   	pop    %esi
  801651:	5f                   	pop    %edi
  801652:	5d                   	pop    %ebp
  801653:	c3                   	ret    

00801654 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801654:	55                   	push   %ebp
  801655:	89 e5                	mov    %esp,%ebp
  801657:	83 ec 18             	sub    $0x18,%esp
  80165a:	8b 45 08             	mov    0x8(%ebp),%eax
  80165d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801660:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801663:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801667:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80166a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801671:	85 c0                	test   %eax,%eax
  801673:	74 26                	je     80169b <vsnprintf+0x47>
  801675:	85 d2                	test   %edx,%edx
  801677:	7e 22                	jle    80169b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801679:	ff 75 14             	pushl  0x14(%ebp)
  80167c:	ff 75 10             	pushl  0x10(%ebp)
  80167f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801682:	50                   	push   %eax
  801683:	68 97 11 80 00       	push   $0x801197
  801688:	e8 44 fb ff ff       	call   8011d1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80168d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801690:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801693:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801696:	83 c4 10             	add    $0x10,%esp
}
  801699:	c9                   	leave  
  80169a:	c3                   	ret    
		return -E_INVAL;
  80169b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016a0:	eb f7                	jmp    801699 <vsnprintf+0x45>

008016a2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016a2:	55                   	push   %ebp
  8016a3:	89 e5                	mov    %esp,%ebp
  8016a5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016a8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016ab:	50                   	push   %eax
  8016ac:	ff 75 10             	pushl  0x10(%ebp)
  8016af:	ff 75 0c             	pushl  0xc(%ebp)
  8016b2:	ff 75 08             	pushl  0x8(%ebp)
  8016b5:	e8 9a ff ff ff       	call   801654 <vsnprintf>
	va_end(ap);

	return rc;
}
  8016ba:	c9                   	leave  
  8016bb:	c3                   	ret    

008016bc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016bc:	55                   	push   %ebp
  8016bd:	89 e5                	mov    %esp,%ebp
  8016bf:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8016c7:	eb 03                	jmp    8016cc <strlen+0x10>
		n++;
  8016c9:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8016cc:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016d0:	75 f7                	jne    8016c9 <strlen+0xd>
	return n;
}
  8016d2:	5d                   	pop    %ebp
  8016d3:	c3                   	ret    

008016d4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016d4:	55                   	push   %ebp
  8016d5:	89 e5                	mov    %esp,%ebp
  8016d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016da:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8016e2:	eb 03                	jmp    8016e7 <strnlen+0x13>
		n++;
  8016e4:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016e7:	39 d0                	cmp    %edx,%eax
  8016e9:	74 06                	je     8016f1 <strnlen+0x1d>
  8016eb:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8016ef:	75 f3                	jne    8016e4 <strnlen+0x10>
	return n;
}
  8016f1:	5d                   	pop    %ebp
  8016f2:	c3                   	ret    

008016f3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016f3:	55                   	push   %ebp
  8016f4:	89 e5                	mov    %esp,%ebp
  8016f6:	53                   	push   %ebx
  8016f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8016fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016fd:	89 c2                	mov    %eax,%edx
  8016ff:	83 c1 01             	add    $0x1,%ecx
  801702:	83 c2 01             	add    $0x1,%edx
  801705:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801709:	88 5a ff             	mov    %bl,-0x1(%edx)
  80170c:	84 db                	test   %bl,%bl
  80170e:	75 ef                	jne    8016ff <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801710:	5b                   	pop    %ebx
  801711:	5d                   	pop    %ebp
  801712:	c3                   	ret    

00801713 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801713:	55                   	push   %ebp
  801714:	89 e5                	mov    %esp,%ebp
  801716:	53                   	push   %ebx
  801717:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80171a:	53                   	push   %ebx
  80171b:	e8 9c ff ff ff       	call   8016bc <strlen>
  801720:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801723:	ff 75 0c             	pushl  0xc(%ebp)
  801726:	01 d8                	add    %ebx,%eax
  801728:	50                   	push   %eax
  801729:	e8 c5 ff ff ff       	call   8016f3 <strcpy>
	return dst;
}
  80172e:	89 d8                	mov    %ebx,%eax
  801730:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801733:	c9                   	leave  
  801734:	c3                   	ret    

00801735 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801735:	55                   	push   %ebp
  801736:	89 e5                	mov    %esp,%ebp
  801738:	56                   	push   %esi
  801739:	53                   	push   %ebx
  80173a:	8b 75 08             	mov    0x8(%ebp),%esi
  80173d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801740:	89 f3                	mov    %esi,%ebx
  801742:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801745:	89 f2                	mov    %esi,%edx
  801747:	eb 0f                	jmp    801758 <strncpy+0x23>
		*dst++ = *src;
  801749:	83 c2 01             	add    $0x1,%edx
  80174c:	0f b6 01             	movzbl (%ecx),%eax
  80174f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801752:	80 39 01             	cmpb   $0x1,(%ecx)
  801755:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  801758:	39 da                	cmp    %ebx,%edx
  80175a:	75 ed                	jne    801749 <strncpy+0x14>
	}
	return ret;
}
  80175c:	89 f0                	mov    %esi,%eax
  80175e:	5b                   	pop    %ebx
  80175f:	5e                   	pop    %esi
  801760:	5d                   	pop    %ebp
  801761:	c3                   	ret    

00801762 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801762:	55                   	push   %ebp
  801763:	89 e5                	mov    %esp,%ebp
  801765:	56                   	push   %esi
  801766:	53                   	push   %ebx
  801767:	8b 75 08             	mov    0x8(%ebp),%esi
  80176a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80176d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801770:	89 f0                	mov    %esi,%eax
  801772:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801776:	85 c9                	test   %ecx,%ecx
  801778:	75 0b                	jne    801785 <strlcpy+0x23>
  80177a:	eb 17                	jmp    801793 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80177c:	83 c2 01             	add    $0x1,%edx
  80177f:	83 c0 01             	add    $0x1,%eax
  801782:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  801785:	39 d8                	cmp    %ebx,%eax
  801787:	74 07                	je     801790 <strlcpy+0x2e>
  801789:	0f b6 0a             	movzbl (%edx),%ecx
  80178c:	84 c9                	test   %cl,%cl
  80178e:	75 ec                	jne    80177c <strlcpy+0x1a>
		*dst = '\0';
  801790:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801793:	29 f0                	sub    %esi,%eax
}
  801795:	5b                   	pop    %ebx
  801796:	5e                   	pop    %esi
  801797:	5d                   	pop    %ebp
  801798:	c3                   	ret    

00801799 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801799:	55                   	push   %ebp
  80179a:	89 e5                	mov    %esp,%ebp
  80179c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80179f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017a2:	eb 06                	jmp    8017aa <strcmp+0x11>
		p++, q++;
  8017a4:	83 c1 01             	add    $0x1,%ecx
  8017a7:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8017aa:	0f b6 01             	movzbl (%ecx),%eax
  8017ad:	84 c0                	test   %al,%al
  8017af:	74 04                	je     8017b5 <strcmp+0x1c>
  8017b1:	3a 02                	cmp    (%edx),%al
  8017b3:	74 ef                	je     8017a4 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017b5:	0f b6 c0             	movzbl %al,%eax
  8017b8:	0f b6 12             	movzbl (%edx),%edx
  8017bb:	29 d0                	sub    %edx,%eax
}
  8017bd:	5d                   	pop    %ebp
  8017be:	c3                   	ret    

008017bf <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017bf:	55                   	push   %ebp
  8017c0:	89 e5                	mov    %esp,%ebp
  8017c2:	53                   	push   %ebx
  8017c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017c9:	89 c3                	mov    %eax,%ebx
  8017cb:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017ce:	eb 06                	jmp    8017d6 <strncmp+0x17>
		n--, p++, q++;
  8017d0:	83 c0 01             	add    $0x1,%eax
  8017d3:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8017d6:	39 d8                	cmp    %ebx,%eax
  8017d8:	74 16                	je     8017f0 <strncmp+0x31>
  8017da:	0f b6 08             	movzbl (%eax),%ecx
  8017dd:	84 c9                	test   %cl,%cl
  8017df:	74 04                	je     8017e5 <strncmp+0x26>
  8017e1:	3a 0a                	cmp    (%edx),%cl
  8017e3:	74 eb                	je     8017d0 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017e5:	0f b6 00             	movzbl (%eax),%eax
  8017e8:	0f b6 12             	movzbl (%edx),%edx
  8017eb:	29 d0                	sub    %edx,%eax
}
  8017ed:	5b                   	pop    %ebx
  8017ee:	5d                   	pop    %ebp
  8017ef:	c3                   	ret    
		return 0;
  8017f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8017f5:	eb f6                	jmp    8017ed <strncmp+0x2e>

008017f7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017f7:	55                   	push   %ebp
  8017f8:	89 e5                	mov    %esp,%ebp
  8017fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801801:	0f b6 10             	movzbl (%eax),%edx
  801804:	84 d2                	test   %dl,%dl
  801806:	74 09                	je     801811 <strchr+0x1a>
		if (*s == c)
  801808:	38 ca                	cmp    %cl,%dl
  80180a:	74 0a                	je     801816 <strchr+0x1f>
	for (; *s; s++)
  80180c:	83 c0 01             	add    $0x1,%eax
  80180f:	eb f0                	jmp    801801 <strchr+0xa>
			return (char *) s;
	return 0;
  801811:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801816:	5d                   	pop    %ebp
  801817:	c3                   	ret    

00801818 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801818:	55                   	push   %ebp
  801819:	89 e5                	mov    %esp,%ebp
  80181b:	8b 45 08             	mov    0x8(%ebp),%eax
  80181e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801822:	eb 03                	jmp    801827 <strfind+0xf>
  801824:	83 c0 01             	add    $0x1,%eax
  801827:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80182a:	38 ca                	cmp    %cl,%dl
  80182c:	74 04                	je     801832 <strfind+0x1a>
  80182e:	84 d2                	test   %dl,%dl
  801830:	75 f2                	jne    801824 <strfind+0xc>
			break;
	return (char *) s;
}
  801832:	5d                   	pop    %ebp
  801833:	c3                   	ret    

00801834 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801834:	55                   	push   %ebp
  801835:	89 e5                	mov    %esp,%ebp
  801837:	57                   	push   %edi
  801838:	56                   	push   %esi
  801839:	53                   	push   %ebx
  80183a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80183d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801840:	85 c9                	test   %ecx,%ecx
  801842:	74 13                	je     801857 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801844:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80184a:	75 05                	jne    801851 <memset+0x1d>
  80184c:	f6 c1 03             	test   $0x3,%cl
  80184f:	74 0d                	je     80185e <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801851:	8b 45 0c             	mov    0xc(%ebp),%eax
  801854:	fc                   	cld    
  801855:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801857:	89 f8                	mov    %edi,%eax
  801859:	5b                   	pop    %ebx
  80185a:	5e                   	pop    %esi
  80185b:	5f                   	pop    %edi
  80185c:	5d                   	pop    %ebp
  80185d:	c3                   	ret    
		c &= 0xFF;
  80185e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801862:	89 d3                	mov    %edx,%ebx
  801864:	c1 e3 08             	shl    $0x8,%ebx
  801867:	89 d0                	mov    %edx,%eax
  801869:	c1 e0 18             	shl    $0x18,%eax
  80186c:	89 d6                	mov    %edx,%esi
  80186e:	c1 e6 10             	shl    $0x10,%esi
  801871:	09 f0                	or     %esi,%eax
  801873:	09 c2                	or     %eax,%edx
  801875:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  801877:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80187a:	89 d0                	mov    %edx,%eax
  80187c:	fc                   	cld    
  80187d:	f3 ab                	rep stos %eax,%es:(%edi)
  80187f:	eb d6                	jmp    801857 <memset+0x23>

00801881 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801881:	55                   	push   %ebp
  801882:	89 e5                	mov    %esp,%ebp
  801884:	57                   	push   %edi
  801885:	56                   	push   %esi
  801886:	8b 45 08             	mov    0x8(%ebp),%eax
  801889:	8b 75 0c             	mov    0xc(%ebp),%esi
  80188c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80188f:	39 c6                	cmp    %eax,%esi
  801891:	73 35                	jae    8018c8 <memmove+0x47>
  801893:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801896:	39 c2                	cmp    %eax,%edx
  801898:	76 2e                	jbe    8018c8 <memmove+0x47>
		s += n;
		d += n;
  80189a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80189d:	89 d6                	mov    %edx,%esi
  80189f:	09 fe                	or     %edi,%esi
  8018a1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018a7:	74 0c                	je     8018b5 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8018a9:	83 ef 01             	sub    $0x1,%edi
  8018ac:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8018af:	fd                   	std    
  8018b0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018b2:	fc                   	cld    
  8018b3:	eb 21                	jmp    8018d6 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018b5:	f6 c1 03             	test   $0x3,%cl
  8018b8:	75 ef                	jne    8018a9 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8018ba:	83 ef 04             	sub    $0x4,%edi
  8018bd:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018c0:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8018c3:	fd                   	std    
  8018c4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018c6:	eb ea                	jmp    8018b2 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018c8:	89 f2                	mov    %esi,%edx
  8018ca:	09 c2                	or     %eax,%edx
  8018cc:	f6 c2 03             	test   $0x3,%dl
  8018cf:	74 09                	je     8018da <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018d1:	89 c7                	mov    %eax,%edi
  8018d3:	fc                   	cld    
  8018d4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018d6:	5e                   	pop    %esi
  8018d7:	5f                   	pop    %edi
  8018d8:	5d                   	pop    %ebp
  8018d9:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018da:	f6 c1 03             	test   $0x3,%cl
  8018dd:	75 f2                	jne    8018d1 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8018df:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8018e2:	89 c7                	mov    %eax,%edi
  8018e4:	fc                   	cld    
  8018e5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018e7:	eb ed                	jmp    8018d6 <memmove+0x55>

008018e9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018e9:	55                   	push   %ebp
  8018ea:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018ec:	ff 75 10             	pushl  0x10(%ebp)
  8018ef:	ff 75 0c             	pushl  0xc(%ebp)
  8018f2:	ff 75 08             	pushl  0x8(%ebp)
  8018f5:	e8 87 ff ff ff       	call   801881 <memmove>
}
  8018fa:	c9                   	leave  
  8018fb:	c3                   	ret    

008018fc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018fc:	55                   	push   %ebp
  8018fd:	89 e5                	mov    %esp,%ebp
  8018ff:	56                   	push   %esi
  801900:	53                   	push   %ebx
  801901:	8b 45 08             	mov    0x8(%ebp),%eax
  801904:	8b 55 0c             	mov    0xc(%ebp),%edx
  801907:	89 c6                	mov    %eax,%esi
  801909:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80190c:	39 f0                	cmp    %esi,%eax
  80190e:	74 1c                	je     80192c <memcmp+0x30>
		if (*s1 != *s2)
  801910:	0f b6 08             	movzbl (%eax),%ecx
  801913:	0f b6 1a             	movzbl (%edx),%ebx
  801916:	38 d9                	cmp    %bl,%cl
  801918:	75 08                	jne    801922 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  80191a:	83 c0 01             	add    $0x1,%eax
  80191d:	83 c2 01             	add    $0x1,%edx
  801920:	eb ea                	jmp    80190c <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  801922:	0f b6 c1             	movzbl %cl,%eax
  801925:	0f b6 db             	movzbl %bl,%ebx
  801928:	29 d8                	sub    %ebx,%eax
  80192a:	eb 05                	jmp    801931 <memcmp+0x35>
	}

	return 0;
  80192c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801931:	5b                   	pop    %ebx
  801932:	5e                   	pop    %esi
  801933:	5d                   	pop    %ebp
  801934:	c3                   	ret    

00801935 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801935:	55                   	push   %ebp
  801936:	89 e5                	mov    %esp,%ebp
  801938:	8b 45 08             	mov    0x8(%ebp),%eax
  80193b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80193e:	89 c2                	mov    %eax,%edx
  801940:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801943:	39 d0                	cmp    %edx,%eax
  801945:	73 09                	jae    801950 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  801947:	38 08                	cmp    %cl,(%eax)
  801949:	74 05                	je     801950 <memfind+0x1b>
	for (; s < ends; s++)
  80194b:	83 c0 01             	add    $0x1,%eax
  80194e:	eb f3                	jmp    801943 <memfind+0xe>
			break;
	return (void *) s;
}
  801950:	5d                   	pop    %ebp
  801951:	c3                   	ret    

00801952 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801952:	55                   	push   %ebp
  801953:	89 e5                	mov    %esp,%ebp
  801955:	57                   	push   %edi
  801956:	56                   	push   %esi
  801957:	53                   	push   %ebx
  801958:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80195b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80195e:	eb 03                	jmp    801963 <strtol+0x11>
		s++;
  801960:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801963:	0f b6 01             	movzbl (%ecx),%eax
  801966:	3c 20                	cmp    $0x20,%al
  801968:	74 f6                	je     801960 <strtol+0xe>
  80196a:	3c 09                	cmp    $0x9,%al
  80196c:	74 f2                	je     801960 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  80196e:	3c 2b                	cmp    $0x2b,%al
  801970:	74 2e                	je     8019a0 <strtol+0x4e>
	int neg = 0;
  801972:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801977:	3c 2d                	cmp    $0x2d,%al
  801979:	74 2f                	je     8019aa <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80197b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801981:	75 05                	jne    801988 <strtol+0x36>
  801983:	80 39 30             	cmpb   $0x30,(%ecx)
  801986:	74 2c                	je     8019b4 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801988:	85 db                	test   %ebx,%ebx
  80198a:	75 0a                	jne    801996 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80198c:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  801991:	80 39 30             	cmpb   $0x30,(%ecx)
  801994:	74 28                	je     8019be <strtol+0x6c>
		base = 10;
  801996:	b8 00 00 00 00       	mov    $0x0,%eax
  80199b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80199e:	eb 50                	jmp    8019f0 <strtol+0x9e>
		s++;
  8019a0:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  8019a3:	bf 00 00 00 00       	mov    $0x0,%edi
  8019a8:	eb d1                	jmp    80197b <strtol+0x29>
		s++, neg = 1;
  8019aa:	83 c1 01             	add    $0x1,%ecx
  8019ad:	bf 01 00 00 00       	mov    $0x1,%edi
  8019b2:	eb c7                	jmp    80197b <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019b4:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019b8:	74 0e                	je     8019c8 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8019ba:	85 db                	test   %ebx,%ebx
  8019bc:	75 d8                	jne    801996 <strtol+0x44>
		s++, base = 8;
  8019be:	83 c1 01             	add    $0x1,%ecx
  8019c1:	bb 08 00 00 00       	mov    $0x8,%ebx
  8019c6:	eb ce                	jmp    801996 <strtol+0x44>
		s += 2, base = 16;
  8019c8:	83 c1 02             	add    $0x2,%ecx
  8019cb:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019d0:	eb c4                	jmp    801996 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  8019d2:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019d5:	89 f3                	mov    %esi,%ebx
  8019d7:	80 fb 19             	cmp    $0x19,%bl
  8019da:	77 29                	ja     801a05 <strtol+0xb3>
			dig = *s - 'a' + 10;
  8019dc:	0f be d2             	movsbl %dl,%edx
  8019df:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8019e2:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019e5:	7d 30                	jge    801a17 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  8019e7:	83 c1 01             	add    $0x1,%ecx
  8019ea:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019ee:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  8019f0:	0f b6 11             	movzbl (%ecx),%edx
  8019f3:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019f6:	89 f3                	mov    %esi,%ebx
  8019f8:	80 fb 09             	cmp    $0x9,%bl
  8019fb:	77 d5                	ja     8019d2 <strtol+0x80>
			dig = *s - '0';
  8019fd:	0f be d2             	movsbl %dl,%edx
  801a00:	83 ea 30             	sub    $0x30,%edx
  801a03:	eb dd                	jmp    8019e2 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  801a05:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a08:	89 f3                	mov    %esi,%ebx
  801a0a:	80 fb 19             	cmp    $0x19,%bl
  801a0d:	77 08                	ja     801a17 <strtol+0xc5>
			dig = *s - 'A' + 10;
  801a0f:	0f be d2             	movsbl %dl,%edx
  801a12:	83 ea 37             	sub    $0x37,%edx
  801a15:	eb cb                	jmp    8019e2 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  801a17:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a1b:	74 05                	je     801a22 <strtol+0xd0>
		*endptr = (char *) s;
  801a1d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a20:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801a22:	89 c2                	mov    %eax,%edx
  801a24:	f7 da                	neg    %edx
  801a26:	85 ff                	test   %edi,%edi
  801a28:	0f 45 c2             	cmovne %edx,%eax
}
  801a2b:	5b                   	pop    %ebx
  801a2c:	5e                   	pop    %esi
  801a2d:	5f                   	pop    %edi
  801a2e:	5d                   	pop    %ebp
  801a2f:	c3                   	ret    

00801a30 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a30:	55                   	push   %ebp
  801a31:	89 e5                	mov    %esp,%ebp
  801a33:	56                   	push   %esi
  801a34:	53                   	push   %ebx
  801a35:	8b 75 08             	mov    0x8(%ebp),%esi
  801a38:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a3b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  801a3e:	85 f6                	test   %esi,%esi
  801a40:	74 06                	je     801a48 <ipc_recv+0x18>
  801a42:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801a48:	85 db                	test   %ebx,%ebx
  801a4a:	74 06                	je     801a52 <ipc_recv+0x22>
  801a4c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801a52:	85 c0                	test   %eax,%eax
  801a54:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801a59:	0f 44 c2             	cmove  %edx,%eax
	int ret = sys_ipc_recv(pg);
  801a5c:	83 ec 0c             	sub    $0xc,%esp
  801a5f:	50                   	push   %eax
  801a60:	e8 a5 e8 ff ff       	call   80030a <sys_ipc_recv>
	if (ret) return ret;
  801a65:	83 c4 10             	add    $0x10,%esp
  801a68:	85 c0                	test   %eax,%eax
  801a6a:	75 24                	jne    801a90 <ipc_recv+0x60>
	if (from_env_store)
  801a6c:	85 f6                	test   %esi,%esi
  801a6e:	74 0a                	je     801a7a <ipc_recv+0x4a>
		*from_env_store = thisenv->env_ipc_from;
  801a70:	a1 04 40 80 00       	mov    0x804004,%eax
  801a75:	8b 40 74             	mov    0x74(%eax),%eax
  801a78:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801a7a:	85 db                	test   %ebx,%ebx
  801a7c:	74 0a                	je     801a88 <ipc_recv+0x58>
		*perm_store = thisenv->env_ipc_perm;
  801a7e:	a1 04 40 80 00       	mov    0x804004,%eax
  801a83:	8b 40 78             	mov    0x78(%eax),%eax
  801a86:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801a88:	a1 04 40 80 00       	mov    0x804004,%eax
  801a8d:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a90:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a93:	5b                   	pop    %ebx
  801a94:	5e                   	pop    %esi
  801a95:	5d                   	pop    %ebp
  801a96:	c3                   	ret    

00801a97 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a97:	55                   	push   %ebp
  801a98:	89 e5                	mov    %esp,%ebp
  801a9a:	57                   	push   %edi
  801a9b:	56                   	push   %esi
  801a9c:	53                   	push   %ebx
  801a9d:	83 ec 0c             	sub    $0xc,%esp
  801aa0:	8b 7d 08             	mov    0x8(%ebp),%edi
  801aa3:	8b 75 0c             	mov    0xc(%ebp),%esi
  801aa6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  801aa9:	85 db                	test   %ebx,%ebx
  801aab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801ab0:	0f 44 d8             	cmove  %eax,%ebx
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801ab3:	ff 75 14             	pushl  0x14(%ebp)
  801ab6:	53                   	push   %ebx
  801ab7:	56                   	push   %esi
  801ab8:	57                   	push   %edi
  801ab9:	e8 29 e8 ff ff       	call   8002e7 <sys_ipc_try_send>
  801abe:	83 c4 10             	add    $0x10,%esp
  801ac1:	85 c0                	test   %eax,%eax
  801ac3:	74 1e                	je     801ae3 <ipc_send+0x4c>
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801ac5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ac8:	75 07                	jne    801ad1 <ipc_send+0x3a>
		sys_yield();
  801aca:	e8 6c e6 ff ff       	call   80013b <sys_yield>
  801acf:	eb e2                	jmp    801ab3 <ipc_send+0x1c>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801ad1:	50                   	push   %eax
  801ad2:	68 e0 21 80 00       	push   $0x8021e0
  801ad7:	6a 36                	push   $0x36
  801ad9:	68 f7 21 80 00       	push   $0x8021f7
  801ade:	e8 16 f5 ff ff       	call   800ff9 <_panic>
	}
}
  801ae3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae6:	5b                   	pop    %ebx
  801ae7:	5e                   	pop    %esi
  801ae8:	5f                   	pop    %edi
  801ae9:	5d                   	pop    %ebp
  801aea:	c3                   	ret    

00801aeb <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801aeb:	55                   	push   %ebp
  801aec:	89 e5                	mov    %esp,%ebp
  801aee:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801af1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801af6:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801af9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801aff:	8b 52 50             	mov    0x50(%edx),%edx
  801b02:	39 ca                	cmp    %ecx,%edx
  801b04:	74 11                	je     801b17 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801b06:	83 c0 01             	add    $0x1,%eax
  801b09:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b0e:	75 e6                	jne    801af6 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801b10:	b8 00 00 00 00       	mov    $0x0,%eax
  801b15:	eb 0b                	jmp    801b22 <ipc_find_env+0x37>
			return envs[i].env_id;
  801b17:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b1a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b1f:	8b 40 48             	mov    0x48(%eax),%eax
}
  801b22:	5d                   	pop    %ebp
  801b23:	c3                   	ret    

00801b24 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b24:	55                   	push   %ebp
  801b25:	89 e5                	mov    %esp,%ebp
  801b27:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b2a:	89 d0                	mov    %edx,%eax
  801b2c:	c1 e8 16             	shr    $0x16,%eax
  801b2f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b36:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801b3b:	f6 c1 01             	test   $0x1,%cl
  801b3e:	74 1d                	je     801b5d <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801b40:	c1 ea 0c             	shr    $0xc,%edx
  801b43:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b4a:	f6 c2 01             	test   $0x1,%dl
  801b4d:	74 0e                	je     801b5d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b4f:	c1 ea 0c             	shr    $0xc,%edx
  801b52:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b59:	ef 
  801b5a:	0f b7 c0             	movzwl %ax,%eax
}
  801b5d:	5d                   	pop    %ebp
  801b5e:	c3                   	ret    
  801b5f:	90                   	nop

00801b60 <__udivdi3>:
  801b60:	55                   	push   %ebp
  801b61:	57                   	push   %edi
  801b62:	56                   	push   %esi
  801b63:	53                   	push   %ebx
  801b64:	83 ec 1c             	sub    $0x1c,%esp
  801b67:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801b6b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801b6f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801b73:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801b77:	85 d2                	test   %edx,%edx
  801b79:	75 35                	jne    801bb0 <__udivdi3+0x50>
  801b7b:	39 f3                	cmp    %esi,%ebx
  801b7d:	0f 87 bd 00 00 00    	ja     801c40 <__udivdi3+0xe0>
  801b83:	85 db                	test   %ebx,%ebx
  801b85:	89 d9                	mov    %ebx,%ecx
  801b87:	75 0b                	jne    801b94 <__udivdi3+0x34>
  801b89:	b8 01 00 00 00       	mov    $0x1,%eax
  801b8e:	31 d2                	xor    %edx,%edx
  801b90:	f7 f3                	div    %ebx
  801b92:	89 c1                	mov    %eax,%ecx
  801b94:	31 d2                	xor    %edx,%edx
  801b96:	89 f0                	mov    %esi,%eax
  801b98:	f7 f1                	div    %ecx
  801b9a:	89 c6                	mov    %eax,%esi
  801b9c:	89 e8                	mov    %ebp,%eax
  801b9e:	89 f7                	mov    %esi,%edi
  801ba0:	f7 f1                	div    %ecx
  801ba2:	89 fa                	mov    %edi,%edx
  801ba4:	83 c4 1c             	add    $0x1c,%esp
  801ba7:	5b                   	pop    %ebx
  801ba8:	5e                   	pop    %esi
  801ba9:	5f                   	pop    %edi
  801baa:	5d                   	pop    %ebp
  801bab:	c3                   	ret    
  801bac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801bb0:	39 f2                	cmp    %esi,%edx
  801bb2:	77 7c                	ja     801c30 <__udivdi3+0xd0>
  801bb4:	0f bd fa             	bsr    %edx,%edi
  801bb7:	83 f7 1f             	xor    $0x1f,%edi
  801bba:	0f 84 98 00 00 00    	je     801c58 <__udivdi3+0xf8>
  801bc0:	89 f9                	mov    %edi,%ecx
  801bc2:	b8 20 00 00 00       	mov    $0x20,%eax
  801bc7:	29 f8                	sub    %edi,%eax
  801bc9:	d3 e2                	shl    %cl,%edx
  801bcb:	89 54 24 08          	mov    %edx,0x8(%esp)
  801bcf:	89 c1                	mov    %eax,%ecx
  801bd1:	89 da                	mov    %ebx,%edx
  801bd3:	d3 ea                	shr    %cl,%edx
  801bd5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801bd9:	09 d1                	or     %edx,%ecx
  801bdb:	89 f2                	mov    %esi,%edx
  801bdd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801be1:	89 f9                	mov    %edi,%ecx
  801be3:	d3 e3                	shl    %cl,%ebx
  801be5:	89 c1                	mov    %eax,%ecx
  801be7:	d3 ea                	shr    %cl,%edx
  801be9:	89 f9                	mov    %edi,%ecx
  801beb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801bef:	d3 e6                	shl    %cl,%esi
  801bf1:	89 eb                	mov    %ebp,%ebx
  801bf3:	89 c1                	mov    %eax,%ecx
  801bf5:	d3 eb                	shr    %cl,%ebx
  801bf7:	09 de                	or     %ebx,%esi
  801bf9:	89 f0                	mov    %esi,%eax
  801bfb:	f7 74 24 08          	divl   0x8(%esp)
  801bff:	89 d6                	mov    %edx,%esi
  801c01:	89 c3                	mov    %eax,%ebx
  801c03:	f7 64 24 0c          	mull   0xc(%esp)
  801c07:	39 d6                	cmp    %edx,%esi
  801c09:	72 0c                	jb     801c17 <__udivdi3+0xb7>
  801c0b:	89 f9                	mov    %edi,%ecx
  801c0d:	d3 e5                	shl    %cl,%ebp
  801c0f:	39 c5                	cmp    %eax,%ebp
  801c11:	73 5d                	jae    801c70 <__udivdi3+0x110>
  801c13:	39 d6                	cmp    %edx,%esi
  801c15:	75 59                	jne    801c70 <__udivdi3+0x110>
  801c17:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801c1a:	31 ff                	xor    %edi,%edi
  801c1c:	89 fa                	mov    %edi,%edx
  801c1e:	83 c4 1c             	add    $0x1c,%esp
  801c21:	5b                   	pop    %ebx
  801c22:	5e                   	pop    %esi
  801c23:	5f                   	pop    %edi
  801c24:	5d                   	pop    %ebp
  801c25:	c3                   	ret    
  801c26:	8d 76 00             	lea    0x0(%esi),%esi
  801c29:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801c30:	31 ff                	xor    %edi,%edi
  801c32:	31 c0                	xor    %eax,%eax
  801c34:	89 fa                	mov    %edi,%edx
  801c36:	83 c4 1c             	add    $0x1c,%esp
  801c39:	5b                   	pop    %ebx
  801c3a:	5e                   	pop    %esi
  801c3b:	5f                   	pop    %edi
  801c3c:	5d                   	pop    %ebp
  801c3d:	c3                   	ret    
  801c3e:	66 90                	xchg   %ax,%ax
  801c40:	31 ff                	xor    %edi,%edi
  801c42:	89 e8                	mov    %ebp,%eax
  801c44:	89 f2                	mov    %esi,%edx
  801c46:	f7 f3                	div    %ebx
  801c48:	89 fa                	mov    %edi,%edx
  801c4a:	83 c4 1c             	add    $0x1c,%esp
  801c4d:	5b                   	pop    %ebx
  801c4e:	5e                   	pop    %esi
  801c4f:	5f                   	pop    %edi
  801c50:	5d                   	pop    %ebp
  801c51:	c3                   	ret    
  801c52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c58:	39 f2                	cmp    %esi,%edx
  801c5a:	72 06                	jb     801c62 <__udivdi3+0x102>
  801c5c:	31 c0                	xor    %eax,%eax
  801c5e:	39 eb                	cmp    %ebp,%ebx
  801c60:	77 d2                	ja     801c34 <__udivdi3+0xd4>
  801c62:	b8 01 00 00 00       	mov    $0x1,%eax
  801c67:	eb cb                	jmp    801c34 <__udivdi3+0xd4>
  801c69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c70:	89 d8                	mov    %ebx,%eax
  801c72:	31 ff                	xor    %edi,%edi
  801c74:	eb be                	jmp    801c34 <__udivdi3+0xd4>
  801c76:	66 90                	xchg   %ax,%ax
  801c78:	66 90                	xchg   %ax,%ax
  801c7a:	66 90                	xchg   %ax,%ax
  801c7c:	66 90                	xchg   %ax,%ax
  801c7e:	66 90                	xchg   %ax,%ax

00801c80 <__umoddi3>:
  801c80:	55                   	push   %ebp
  801c81:	57                   	push   %edi
  801c82:	56                   	push   %esi
  801c83:	53                   	push   %ebx
  801c84:	83 ec 1c             	sub    $0x1c,%esp
  801c87:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801c8b:	8b 74 24 30          	mov    0x30(%esp),%esi
  801c8f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801c93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c97:	85 ed                	test   %ebp,%ebp
  801c99:	89 f0                	mov    %esi,%eax
  801c9b:	89 da                	mov    %ebx,%edx
  801c9d:	75 19                	jne    801cb8 <__umoddi3+0x38>
  801c9f:	39 df                	cmp    %ebx,%edi
  801ca1:	0f 86 b1 00 00 00    	jbe    801d58 <__umoddi3+0xd8>
  801ca7:	f7 f7                	div    %edi
  801ca9:	89 d0                	mov    %edx,%eax
  801cab:	31 d2                	xor    %edx,%edx
  801cad:	83 c4 1c             	add    $0x1c,%esp
  801cb0:	5b                   	pop    %ebx
  801cb1:	5e                   	pop    %esi
  801cb2:	5f                   	pop    %edi
  801cb3:	5d                   	pop    %ebp
  801cb4:	c3                   	ret    
  801cb5:	8d 76 00             	lea    0x0(%esi),%esi
  801cb8:	39 dd                	cmp    %ebx,%ebp
  801cba:	77 f1                	ja     801cad <__umoddi3+0x2d>
  801cbc:	0f bd cd             	bsr    %ebp,%ecx
  801cbf:	83 f1 1f             	xor    $0x1f,%ecx
  801cc2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801cc6:	0f 84 b4 00 00 00    	je     801d80 <__umoddi3+0x100>
  801ccc:	b8 20 00 00 00       	mov    $0x20,%eax
  801cd1:	89 c2                	mov    %eax,%edx
  801cd3:	8b 44 24 04          	mov    0x4(%esp),%eax
  801cd7:	29 c2                	sub    %eax,%edx
  801cd9:	89 c1                	mov    %eax,%ecx
  801cdb:	89 f8                	mov    %edi,%eax
  801cdd:	d3 e5                	shl    %cl,%ebp
  801cdf:	89 d1                	mov    %edx,%ecx
  801ce1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801ce5:	d3 e8                	shr    %cl,%eax
  801ce7:	09 c5                	or     %eax,%ebp
  801ce9:	8b 44 24 04          	mov    0x4(%esp),%eax
  801ced:	89 c1                	mov    %eax,%ecx
  801cef:	d3 e7                	shl    %cl,%edi
  801cf1:	89 d1                	mov    %edx,%ecx
  801cf3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801cf7:	89 df                	mov    %ebx,%edi
  801cf9:	d3 ef                	shr    %cl,%edi
  801cfb:	89 c1                	mov    %eax,%ecx
  801cfd:	89 f0                	mov    %esi,%eax
  801cff:	d3 e3                	shl    %cl,%ebx
  801d01:	89 d1                	mov    %edx,%ecx
  801d03:	89 fa                	mov    %edi,%edx
  801d05:	d3 e8                	shr    %cl,%eax
  801d07:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801d0c:	09 d8                	or     %ebx,%eax
  801d0e:	f7 f5                	div    %ebp
  801d10:	d3 e6                	shl    %cl,%esi
  801d12:	89 d1                	mov    %edx,%ecx
  801d14:	f7 64 24 08          	mull   0x8(%esp)
  801d18:	39 d1                	cmp    %edx,%ecx
  801d1a:	89 c3                	mov    %eax,%ebx
  801d1c:	89 d7                	mov    %edx,%edi
  801d1e:	72 06                	jb     801d26 <__umoddi3+0xa6>
  801d20:	75 0e                	jne    801d30 <__umoddi3+0xb0>
  801d22:	39 c6                	cmp    %eax,%esi
  801d24:	73 0a                	jae    801d30 <__umoddi3+0xb0>
  801d26:	2b 44 24 08          	sub    0x8(%esp),%eax
  801d2a:	19 ea                	sbb    %ebp,%edx
  801d2c:	89 d7                	mov    %edx,%edi
  801d2e:	89 c3                	mov    %eax,%ebx
  801d30:	89 ca                	mov    %ecx,%edx
  801d32:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801d37:	29 de                	sub    %ebx,%esi
  801d39:	19 fa                	sbb    %edi,%edx
  801d3b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  801d3f:	89 d0                	mov    %edx,%eax
  801d41:	d3 e0                	shl    %cl,%eax
  801d43:	89 d9                	mov    %ebx,%ecx
  801d45:	d3 ee                	shr    %cl,%esi
  801d47:	d3 ea                	shr    %cl,%edx
  801d49:	09 f0                	or     %esi,%eax
  801d4b:	83 c4 1c             	add    $0x1c,%esp
  801d4e:	5b                   	pop    %ebx
  801d4f:	5e                   	pop    %esi
  801d50:	5f                   	pop    %edi
  801d51:	5d                   	pop    %ebp
  801d52:	c3                   	ret    
  801d53:	90                   	nop
  801d54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d58:	85 ff                	test   %edi,%edi
  801d5a:	89 f9                	mov    %edi,%ecx
  801d5c:	75 0b                	jne    801d69 <__umoddi3+0xe9>
  801d5e:	b8 01 00 00 00       	mov    $0x1,%eax
  801d63:	31 d2                	xor    %edx,%edx
  801d65:	f7 f7                	div    %edi
  801d67:	89 c1                	mov    %eax,%ecx
  801d69:	89 d8                	mov    %ebx,%eax
  801d6b:	31 d2                	xor    %edx,%edx
  801d6d:	f7 f1                	div    %ecx
  801d6f:	89 f0                	mov    %esi,%eax
  801d71:	f7 f1                	div    %ecx
  801d73:	e9 31 ff ff ff       	jmp    801ca9 <__umoddi3+0x29>
  801d78:	90                   	nop
  801d79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d80:	39 dd                	cmp    %ebx,%ebp
  801d82:	72 08                	jb     801d8c <__umoddi3+0x10c>
  801d84:	39 f7                	cmp    %esi,%edi
  801d86:	0f 87 21 ff ff ff    	ja     801cad <__umoddi3+0x2d>
  801d8c:	89 da                	mov    %ebx,%edx
  801d8e:	89 f0                	mov    %esi,%eax
  801d90:	29 f8                	sub    %edi,%eax
  801d92:	19 ea                	sbb    %ebp,%edx
  801d94:	e9 14 ff ff ff       	jmp    801cad <__umoddi3+0x2d>
