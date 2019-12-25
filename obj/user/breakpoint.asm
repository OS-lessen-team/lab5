
obj/user/breakpoint.debug：     文件格式 elf32-i386


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
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $3");
  800036:	cc                   	int3   
}
  800037:	5d                   	pop    %ebp
  800038:	c3                   	ret    

00800039 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	56                   	push   %esi
  80003d:	53                   	push   %ebx
  80003e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800041:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800044:	e8 ce 00 00 00       	call   800117 <sys_getenvid>
	thisenv = envs + ENVX(envid); 
  800049:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800051:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800056:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005b:	85 db                	test   %ebx,%ebx
  80005d:	7e 07                	jle    800066 <libmain+0x2d>
		binaryname = argv[0];
  80005f:	8b 06                	mov    (%esi),%eax
  800061:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800066:	83 ec 08             	sub    $0x8,%esp
  800069:	56                   	push   %esi
  80006a:	53                   	push   %ebx
  80006b:	e8 c3 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800070:	e8 0a 00 00 00       	call   80007f <exit>
}
  800075:	83 c4 10             	add    $0x10,%esp
  800078:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007b:	5b                   	pop    %ebx
  80007c:	5e                   	pop    %esi
  80007d:	5d                   	pop    %ebp
  80007e:	c3                   	ret    

0080007f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80007f:	55                   	push   %ebp
  800080:	89 e5                	mov    %esp,%ebp
  800082:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800085:	e8 92 04 00 00       	call   80051c <close_all>
	sys_env_destroy(0);
  80008a:	83 ec 0c             	sub    $0xc,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	e8 42 00 00 00       	call   8000d6 <sys_env_destroy>
}
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	c9                   	leave  
  800098:	c3                   	ret    

00800099 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800099:	55                   	push   %ebp
  80009a:	89 e5                	mov    %esp,%ebp
  80009c:	57                   	push   %edi
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80009f:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000aa:	89 c3                	mov    %eax,%ebx
  8000ac:	89 c7                	mov    %eax,%edi
  8000ae:	89 c6                	mov    %eax,%esi
  8000b0:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b2:	5b                   	pop    %ebx
  8000b3:	5e                   	pop    %esi
  8000b4:	5f                   	pop    %edi
  8000b5:	5d                   	pop    %ebp
  8000b6:	c3                   	ret    

008000b7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b7:	55                   	push   %ebp
  8000b8:	89 e5                	mov    %esp,%ebp
  8000ba:	57                   	push   %edi
  8000bb:	56                   	push   %esi
  8000bc:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c7:	89 d1                	mov    %edx,%ecx
  8000c9:	89 d3                	mov    %edx,%ebx
  8000cb:	89 d7                	mov    %edx,%edi
  8000cd:	89 d6                	mov    %edx,%esi
  8000cf:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d1:	5b                   	pop    %ebx
  8000d2:	5e                   	pop    %esi
  8000d3:	5f                   	pop    %edi
  8000d4:	5d                   	pop    %ebp
  8000d5:	c3                   	ret    

008000d6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	57                   	push   %edi
  8000da:	56                   	push   %esi
  8000db:	53                   	push   %ebx
  8000dc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e7:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ec:	89 cb                	mov    %ecx,%ebx
  8000ee:	89 cf                	mov    %ecx,%edi
  8000f0:	89 ce                	mov    %ecx,%esi
  8000f2:	cd 30                	int    $0x30
	if(check && ret > 0)
  8000f4:	85 c0                	test   %eax,%eax
  8000f6:	7f 08                	jg     800100 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8000f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000fb:	5b                   	pop    %ebx
  8000fc:	5e                   	pop    %esi
  8000fd:	5f                   	pop    %edi
  8000fe:	5d                   	pop    %ebp
  8000ff:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800100:	83 ec 0c             	sub    $0xc,%esp
  800103:	50                   	push   %eax
  800104:	6a 03                	push   $0x3
  800106:	68 aa 1d 80 00       	push   $0x801daa
  80010b:	6a 23                	push   $0x23
  80010d:	68 c7 1d 80 00       	push   $0x801dc7
  800112:	e8 dd 0e 00 00       	call   800ff4 <_panic>

00800117 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800117:	55                   	push   %ebp
  800118:	89 e5                	mov    %esp,%ebp
  80011a:	57                   	push   %edi
  80011b:	56                   	push   %esi
  80011c:	53                   	push   %ebx
	asm volatile("int %1\n"
  80011d:	ba 00 00 00 00       	mov    $0x0,%edx
  800122:	b8 02 00 00 00       	mov    $0x2,%eax
  800127:	89 d1                	mov    %edx,%ecx
  800129:	89 d3                	mov    %edx,%ebx
  80012b:	89 d7                	mov    %edx,%edi
  80012d:	89 d6                	mov    %edx,%esi
  80012f:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800131:	5b                   	pop    %ebx
  800132:	5e                   	pop    %esi
  800133:	5f                   	pop    %edi
  800134:	5d                   	pop    %ebp
  800135:	c3                   	ret    

00800136 <sys_yield>:

void
sys_yield(void)
{
  800136:	55                   	push   %ebp
  800137:	89 e5                	mov    %esp,%ebp
  800139:	57                   	push   %edi
  80013a:	56                   	push   %esi
  80013b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80013c:	ba 00 00 00 00       	mov    $0x0,%edx
  800141:	b8 0b 00 00 00       	mov    $0xb,%eax
  800146:	89 d1                	mov    %edx,%ecx
  800148:	89 d3                	mov    %edx,%ebx
  80014a:	89 d7                	mov    %edx,%edi
  80014c:	89 d6                	mov    %edx,%esi
  80014e:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800150:	5b                   	pop    %ebx
  800151:	5e                   	pop    %esi
  800152:	5f                   	pop    %edi
  800153:	5d                   	pop    %ebp
  800154:	c3                   	ret    

00800155 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	57                   	push   %edi
  800159:	56                   	push   %esi
  80015a:	53                   	push   %ebx
  80015b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80015e:	be 00 00 00 00       	mov    $0x0,%esi
  800163:	8b 55 08             	mov    0x8(%ebp),%edx
  800166:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800169:	b8 04 00 00 00       	mov    $0x4,%eax
  80016e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800171:	89 f7                	mov    %esi,%edi
  800173:	cd 30                	int    $0x30
	if(check && ret > 0)
  800175:	85 c0                	test   %eax,%eax
  800177:	7f 08                	jg     800181 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800179:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80017c:	5b                   	pop    %ebx
  80017d:	5e                   	pop    %esi
  80017e:	5f                   	pop    %edi
  80017f:	5d                   	pop    %ebp
  800180:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800181:	83 ec 0c             	sub    $0xc,%esp
  800184:	50                   	push   %eax
  800185:	6a 04                	push   $0x4
  800187:	68 aa 1d 80 00       	push   $0x801daa
  80018c:	6a 23                	push   $0x23
  80018e:	68 c7 1d 80 00       	push   $0x801dc7
  800193:	e8 5c 0e 00 00       	call   800ff4 <_panic>

00800198 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	57                   	push   %edi
  80019c:	56                   	push   %esi
  80019d:	53                   	push   %ebx
  80019e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a7:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001af:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b2:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b5:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001b7:	85 c0                	test   %eax,%eax
  8001b9:	7f 08                	jg     8001c3 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001be:	5b                   	pop    %ebx
  8001bf:	5e                   	pop    %esi
  8001c0:	5f                   	pop    %edi
  8001c1:	5d                   	pop    %ebp
  8001c2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c3:	83 ec 0c             	sub    $0xc,%esp
  8001c6:	50                   	push   %eax
  8001c7:	6a 05                	push   $0x5
  8001c9:	68 aa 1d 80 00       	push   $0x801daa
  8001ce:	6a 23                	push   $0x23
  8001d0:	68 c7 1d 80 00       	push   $0x801dc7
  8001d5:	e8 1a 0e 00 00       	call   800ff4 <_panic>

008001da <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001da:	55                   	push   %ebp
  8001db:	89 e5                	mov    %esp,%ebp
  8001dd:	57                   	push   %edi
  8001de:	56                   	push   %esi
  8001df:	53                   	push   %ebx
  8001e0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ee:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f3:	89 df                	mov    %ebx,%edi
  8001f5:	89 de                	mov    %ebx,%esi
  8001f7:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001f9:	85 c0                	test   %eax,%eax
  8001fb:	7f 08                	jg     800205 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8001fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800200:	5b                   	pop    %ebx
  800201:	5e                   	pop    %esi
  800202:	5f                   	pop    %edi
  800203:	5d                   	pop    %ebp
  800204:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800205:	83 ec 0c             	sub    $0xc,%esp
  800208:	50                   	push   %eax
  800209:	6a 06                	push   $0x6
  80020b:	68 aa 1d 80 00       	push   $0x801daa
  800210:	6a 23                	push   $0x23
  800212:	68 c7 1d 80 00       	push   $0x801dc7
  800217:	e8 d8 0d 00 00       	call   800ff4 <_panic>

0080021c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	57                   	push   %edi
  800220:	56                   	push   %esi
  800221:	53                   	push   %ebx
  800222:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800225:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022a:	8b 55 08             	mov    0x8(%ebp),%edx
  80022d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800230:	b8 08 00 00 00       	mov    $0x8,%eax
  800235:	89 df                	mov    %ebx,%edi
  800237:	89 de                	mov    %ebx,%esi
  800239:	cd 30                	int    $0x30
	if(check && ret > 0)
  80023b:	85 c0                	test   %eax,%eax
  80023d:	7f 08                	jg     800247 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80023f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800242:	5b                   	pop    %ebx
  800243:	5e                   	pop    %esi
  800244:	5f                   	pop    %edi
  800245:	5d                   	pop    %ebp
  800246:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800247:	83 ec 0c             	sub    $0xc,%esp
  80024a:	50                   	push   %eax
  80024b:	6a 08                	push   $0x8
  80024d:	68 aa 1d 80 00       	push   $0x801daa
  800252:	6a 23                	push   $0x23
  800254:	68 c7 1d 80 00       	push   $0x801dc7
  800259:	e8 96 0d 00 00       	call   800ff4 <_panic>

0080025e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
  800261:	57                   	push   %edi
  800262:	56                   	push   %esi
  800263:	53                   	push   %ebx
  800264:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800267:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026c:	8b 55 08             	mov    0x8(%ebp),%edx
  80026f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800272:	b8 09 00 00 00       	mov    $0x9,%eax
  800277:	89 df                	mov    %ebx,%edi
  800279:	89 de                	mov    %ebx,%esi
  80027b:	cd 30                	int    $0x30
	if(check && ret > 0)
  80027d:	85 c0                	test   %eax,%eax
  80027f:	7f 08                	jg     800289 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800281:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800284:	5b                   	pop    %ebx
  800285:	5e                   	pop    %esi
  800286:	5f                   	pop    %edi
  800287:	5d                   	pop    %ebp
  800288:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800289:	83 ec 0c             	sub    $0xc,%esp
  80028c:	50                   	push   %eax
  80028d:	6a 09                	push   $0x9
  80028f:	68 aa 1d 80 00       	push   $0x801daa
  800294:	6a 23                	push   $0x23
  800296:	68 c7 1d 80 00       	push   $0x801dc7
  80029b:	e8 54 0d 00 00       	call   800ff4 <_panic>

008002a0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	57                   	push   %edi
  8002a4:	56                   	push   %esi
  8002a5:	53                   	push   %ebx
  8002a6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b9:	89 df                	mov    %ebx,%edi
  8002bb:	89 de                	mov    %ebx,%esi
  8002bd:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002bf:	85 c0                	test   %eax,%eax
  8002c1:	7f 08                	jg     8002cb <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c6:	5b                   	pop    %ebx
  8002c7:	5e                   	pop    %esi
  8002c8:	5f                   	pop    %edi
  8002c9:	5d                   	pop    %ebp
  8002ca:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002cb:	83 ec 0c             	sub    $0xc,%esp
  8002ce:	50                   	push   %eax
  8002cf:	6a 0a                	push   $0xa
  8002d1:	68 aa 1d 80 00       	push   $0x801daa
  8002d6:	6a 23                	push   $0x23
  8002d8:	68 c7 1d 80 00       	push   $0x801dc7
  8002dd:	e8 12 0d 00 00       	call   800ff4 <_panic>

008002e2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e2:	55                   	push   %ebp
  8002e3:	89 e5                	mov    %esp,%ebp
  8002e5:	57                   	push   %edi
  8002e6:	56                   	push   %esi
  8002e7:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8002eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ee:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f3:	be 00 00 00 00       	mov    $0x0,%esi
  8002f8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002fb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002fe:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800300:	5b                   	pop    %ebx
  800301:	5e                   	pop    %esi
  800302:	5f                   	pop    %edi
  800303:	5d                   	pop    %ebp
  800304:	c3                   	ret    

00800305 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	57                   	push   %edi
  800309:	56                   	push   %esi
  80030a:	53                   	push   %ebx
  80030b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80030e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800313:	8b 55 08             	mov    0x8(%ebp),%edx
  800316:	b8 0d 00 00 00       	mov    $0xd,%eax
  80031b:	89 cb                	mov    %ecx,%ebx
  80031d:	89 cf                	mov    %ecx,%edi
  80031f:	89 ce                	mov    %ecx,%esi
  800321:	cd 30                	int    $0x30
	if(check && ret > 0)
  800323:	85 c0                	test   %eax,%eax
  800325:	7f 08                	jg     80032f <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800327:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80032a:	5b                   	pop    %ebx
  80032b:	5e                   	pop    %esi
  80032c:	5f                   	pop    %edi
  80032d:	5d                   	pop    %ebp
  80032e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80032f:	83 ec 0c             	sub    $0xc,%esp
  800332:	50                   	push   %eax
  800333:	6a 0d                	push   $0xd
  800335:	68 aa 1d 80 00       	push   $0x801daa
  80033a:	6a 23                	push   $0x23
  80033c:	68 c7 1d 80 00       	push   $0x801dc7
  800341:	e8 ae 0c 00 00       	call   800ff4 <_panic>

00800346 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800346:	55                   	push   %ebp
  800347:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800349:	8b 45 08             	mov    0x8(%ebp),%eax
  80034c:	05 00 00 00 30       	add    $0x30000000,%eax
  800351:	c1 e8 0c             	shr    $0xc,%eax
}
  800354:	5d                   	pop    %ebp
  800355:	c3                   	ret    

00800356 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800356:	55                   	push   %ebp
  800357:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800359:	8b 45 08             	mov    0x8(%ebp),%eax
  80035c:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800361:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800366:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80036b:	5d                   	pop    %ebp
  80036c:	c3                   	ret    

0080036d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80036d:	55                   	push   %ebp
  80036e:	89 e5                	mov    %esp,%ebp
  800370:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800373:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800378:	89 c2                	mov    %eax,%edx
  80037a:	c1 ea 16             	shr    $0x16,%edx
  80037d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800384:	f6 c2 01             	test   $0x1,%dl
  800387:	74 2a                	je     8003b3 <fd_alloc+0x46>
  800389:	89 c2                	mov    %eax,%edx
  80038b:	c1 ea 0c             	shr    $0xc,%edx
  80038e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800395:	f6 c2 01             	test   $0x1,%dl
  800398:	74 19                	je     8003b3 <fd_alloc+0x46>
  80039a:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80039f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003a4:	75 d2                	jne    800378 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003a6:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003ac:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8003b1:	eb 07                	jmp    8003ba <fd_alloc+0x4d>
			*fd_store = fd;
  8003b3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003ba:	5d                   	pop    %ebp
  8003bb:	c3                   	ret    

008003bc <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003bc:	55                   	push   %ebp
  8003bd:	89 e5                	mov    %esp,%ebp
  8003bf:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003c2:	83 f8 1f             	cmp    $0x1f,%eax
  8003c5:	77 36                	ja     8003fd <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003c7:	c1 e0 0c             	shl    $0xc,%eax
  8003ca:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003cf:	89 c2                	mov    %eax,%edx
  8003d1:	c1 ea 16             	shr    $0x16,%edx
  8003d4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003db:	f6 c2 01             	test   $0x1,%dl
  8003de:	74 24                	je     800404 <fd_lookup+0x48>
  8003e0:	89 c2                	mov    %eax,%edx
  8003e2:	c1 ea 0c             	shr    $0xc,%edx
  8003e5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003ec:	f6 c2 01             	test   $0x1,%dl
  8003ef:	74 1a                	je     80040b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f4:	89 02                	mov    %eax,(%edx)
	return 0;
  8003f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003fb:	5d                   	pop    %ebp
  8003fc:	c3                   	ret    
		return -E_INVAL;
  8003fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800402:	eb f7                	jmp    8003fb <fd_lookup+0x3f>
		return -E_INVAL;
  800404:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800409:	eb f0                	jmp    8003fb <fd_lookup+0x3f>
  80040b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800410:	eb e9                	jmp    8003fb <fd_lookup+0x3f>

00800412 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800412:	55                   	push   %ebp
  800413:	89 e5                	mov    %esp,%ebp
  800415:	83 ec 08             	sub    $0x8,%esp
  800418:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80041b:	ba 54 1e 80 00       	mov    $0x801e54,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800420:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800425:	39 08                	cmp    %ecx,(%eax)
  800427:	74 33                	je     80045c <dev_lookup+0x4a>
  800429:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  80042c:	8b 02                	mov    (%edx),%eax
  80042e:	85 c0                	test   %eax,%eax
  800430:	75 f3                	jne    800425 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800432:	a1 04 40 80 00       	mov    0x804004,%eax
  800437:	8b 40 48             	mov    0x48(%eax),%eax
  80043a:	83 ec 04             	sub    $0x4,%esp
  80043d:	51                   	push   %ecx
  80043e:	50                   	push   %eax
  80043f:	68 d8 1d 80 00       	push   $0x801dd8
  800444:	e8 86 0c 00 00       	call   8010cf <cprintf>
	*dev = 0;
  800449:	8b 45 0c             	mov    0xc(%ebp),%eax
  80044c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800452:	83 c4 10             	add    $0x10,%esp
  800455:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80045a:	c9                   	leave  
  80045b:	c3                   	ret    
			*dev = devtab[i];
  80045c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80045f:	89 01                	mov    %eax,(%ecx)
			return 0;
  800461:	b8 00 00 00 00       	mov    $0x0,%eax
  800466:	eb f2                	jmp    80045a <dev_lookup+0x48>

00800468 <fd_close>:
{
  800468:	55                   	push   %ebp
  800469:	89 e5                	mov    %esp,%ebp
  80046b:	57                   	push   %edi
  80046c:	56                   	push   %esi
  80046d:	53                   	push   %ebx
  80046e:	83 ec 1c             	sub    $0x1c,%esp
  800471:	8b 75 08             	mov    0x8(%ebp),%esi
  800474:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800477:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80047a:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80047b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800481:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800484:	50                   	push   %eax
  800485:	e8 32 ff ff ff       	call   8003bc <fd_lookup>
  80048a:	89 c3                	mov    %eax,%ebx
  80048c:	83 c4 08             	add    $0x8,%esp
  80048f:	85 c0                	test   %eax,%eax
  800491:	78 05                	js     800498 <fd_close+0x30>
	    || fd != fd2)
  800493:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800496:	74 16                	je     8004ae <fd_close+0x46>
		return (must_exist ? r : 0);
  800498:	89 f8                	mov    %edi,%eax
  80049a:	84 c0                	test   %al,%al
  80049c:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a1:	0f 44 d8             	cmove  %eax,%ebx
}
  8004a4:	89 d8                	mov    %ebx,%eax
  8004a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004a9:	5b                   	pop    %ebx
  8004aa:	5e                   	pop    %esi
  8004ab:	5f                   	pop    %edi
  8004ac:	5d                   	pop    %ebp
  8004ad:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004ae:	83 ec 08             	sub    $0x8,%esp
  8004b1:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8004b4:	50                   	push   %eax
  8004b5:	ff 36                	pushl  (%esi)
  8004b7:	e8 56 ff ff ff       	call   800412 <dev_lookup>
  8004bc:	89 c3                	mov    %eax,%ebx
  8004be:	83 c4 10             	add    $0x10,%esp
  8004c1:	85 c0                	test   %eax,%eax
  8004c3:	78 15                	js     8004da <fd_close+0x72>
		if (dev->dev_close)
  8004c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004c8:	8b 40 10             	mov    0x10(%eax),%eax
  8004cb:	85 c0                	test   %eax,%eax
  8004cd:	74 1b                	je     8004ea <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  8004cf:	83 ec 0c             	sub    $0xc,%esp
  8004d2:	56                   	push   %esi
  8004d3:	ff d0                	call   *%eax
  8004d5:	89 c3                	mov    %eax,%ebx
  8004d7:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8004da:	83 ec 08             	sub    $0x8,%esp
  8004dd:	56                   	push   %esi
  8004de:	6a 00                	push   $0x0
  8004e0:	e8 f5 fc ff ff       	call   8001da <sys_page_unmap>
	return r;
  8004e5:	83 c4 10             	add    $0x10,%esp
  8004e8:	eb ba                	jmp    8004a4 <fd_close+0x3c>
			r = 0;
  8004ea:	bb 00 00 00 00       	mov    $0x0,%ebx
  8004ef:	eb e9                	jmp    8004da <fd_close+0x72>

008004f1 <close>:

int
close(int fdnum)
{
  8004f1:	55                   	push   %ebp
  8004f2:	89 e5                	mov    %esp,%ebp
  8004f4:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004fa:	50                   	push   %eax
  8004fb:	ff 75 08             	pushl  0x8(%ebp)
  8004fe:	e8 b9 fe ff ff       	call   8003bc <fd_lookup>
  800503:	83 c4 08             	add    $0x8,%esp
  800506:	85 c0                	test   %eax,%eax
  800508:	78 10                	js     80051a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80050a:	83 ec 08             	sub    $0x8,%esp
  80050d:	6a 01                	push   $0x1
  80050f:	ff 75 f4             	pushl  -0xc(%ebp)
  800512:	e8 51 ff ff ff       	call   800468 <fd_close>
  800517:	83 c4 10             	add    $0x10,%esp
}
  80051a:	c9                   	leave  
  80051b:	c3                   	ret    

0080051c <close_all>:

void
close_all(void)
{
  80051c:	55                   	push   %ebp
  80051d:	89 e5                	mov    %esp,%ebp
  80051f:	53                   	push   %ebx
  800520:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800523:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800528:	83 ec 0c             	sub    $0xc,%esp
  80052b:	53                   	push   %ebx
  80052c:	e8 c0 ff ff ff       	call   8004f1 <close>
	for (i = 0; i < MAXFD; i++)
  800531:	83 c3 01             	add    $0x1,%ebx
  800534:	83 c4 10             	add    $0x10,%esp
  800537:	83 fb 20             	cmp    $0x20,%ebx
  80053a:	75 ec                	jne    800528 <close_all+0xc>
}
  80053c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80053f:	c9                   	leave  
  800540:	c3                   	ret    

00800541 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800541:	55                   	push   %ebp
  800542:	89 e5                	mov    %esp,%ebp
  800544:	57                   	push   %edi
  800545:	56                   	push   %esi
  800546:	53                   	push   %ebx
  800547:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80054a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80054d:	50                   	push   %eax
  80054e:	ff 75 08             	pushl  0x8(%ebp)
  800551:	e8 66 fe ff ff       	call   8003bc <fd_lookup>
  800556:	89 c3                	mov    %eax,%ebx
  800558:	83 c4 08             	add    $0x8,%esp
  80055b:	85 c0                	test   %eax,%eax
  80055d:	0f 88 81 00 00 00    	js     8005e4 <dup+0xa3>
		return r;
	close(newfdnum);
  800563:	83 ec 0c             	sub    $0xc,%esp
  800566:	ff 75 0c             	pushl  0xc(%ebp)
  800569:	e8 83 ff ff ff       	call   8004f1 <close>

	newfd = INDEX2FD(newfdnum);
  80056e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800571:	c1 e6 0c             	shl    $0xc,%esi
  800574:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80057a:	83 c4 04             	add    $0x4,%esp
  80057d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800580:	e8 d1 fd ff ff       	call   800356 <fd2data>
  800585:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800587:	89 34 24             	mov    %esi,(%esp)
  80058a:	e8 c7 fd ff ff       	call   800356 <fd2data>
  80058f:	83 c4 10             	add    $0x10,%esp
  800592:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800594:	89 d8                	mov    %ebx,%eax
  800596:	c1 e8 16             	shr    $0x16,%eax
  800599:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005a0:	a8 01                	test   $0x1,%al
  8005a2:	74 11                	je     8005b5 <dup+0x74>
  8005a4:	89 d8                	mov    %ebx,%eax
  8005a6:	c1 e8 0c             	shr    $0xc,%eax
  8005a9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005b0:	f6 c2 01             	test   $0x1,%dl
  8005b3:	75 39                	jne    8005ee <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005b5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005b8:	89 d0                	mov    %edx,%eax
  8005ba:	c1 e8 0c             	shr    $0xc,%eax
  8005bd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005c4:	83 ec 0c             	sub    $0xc,%esp
  8005c7:	25 07 0e 00 00       	and    $0xe07,%eax
  8005cc:	50                   	push   %eax
  8005cd:	56                   	push   %esi
  8005ce:	6a 00                	push   $0x0
  8005d0:	52                   	push   %edx
  8005d1:	6a 00                	push   $0x0
  8005d3:	e8 c0 fb ff ff       	call   800198 <sys_page_map>
  8005d8:	89 c3                	mov    %eax,%ebx
  8005da:	83 c4 20             	add    $0x20,%esp
  8005dd:	85 c0                	test   %eax,%eax
  8005df:	78 31                	js     800612 <dup+0xd1>
		goto err;

	return newfdnum;
  8005e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005e4:	89 d8                	mov    %ebx,%eax
  8005e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005e9:	5b                   	pop    %ebx
  8005ea:	5e                   	pop    %esi
  8005eb:	5f                   	pop    %edi
  8005ec:	5d                   	pop    %ebp
  8005ed:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005ee:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005f5:	83 ec 0c             	sub    $0xc,%esp
  8005f8:	25 07 0e 00 00       	and    $0xe07,%eax
  8005fd:	50                   	push   %eax
  8005fe:	57                   	push   %edi
  8005ff:	6a 00                	push   $0x0
  800601:	53                   	push   %ebx
  800602:	6a 00                	push   $0x0
  800604:	e8 8f fb ff ff       	call   800198 <sys_page_map>
  800609:	89 c3                	mov    %eax,%ebx
  80060b:	83 c4 20             	add    $0x20,%esp
  80060e:	85 c0                	test   %eax,%eax
  800610:	79 a3                	jns    8005b5 <dup+0x74>
	sys_page_unmap(0, newfd);
  800612:	83 ec 08             	sub    $0x8,%esp
  800615:	56                   	push   %esi
  800616:	6a 00                	push   $0x0
  800618:	e8 bd fb ff ff       	call   8001da <sys_page_unmap>
	sys_page_unmap(0, nva);
  80061d:	83 c4 08             	add    $0x8,%esp
  800620:	57                   	push   %edi
  800621:	6a 00                	push   $0x0
  800623:	e8 b2 fb ff ff       	call   8001da <sys_page_unmap>
	return r;
  800628:	83 c4 10             	add    $0x10,%esp
  80062b:	eb b7                	jmp    8005e4 <dup+0xa3>

0080062d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80062d:	55                   	push   %ebp
  80062e:	89 e5                	mov    %esp,%ebp
  800630:	53                   	push   %ebx
  800631:	83 ec 14             	sub    $0x14,%esp
  800634:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800637:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80063a:	50                   	push   %eax
  80063b:	53                   	push   %ebx
  80063c:	e8 7b fd ff ff       	call   8003bc <fd_lookup>
  800641:	83 c4 08             	add    $0x8,%esp
  800644:	85 c0                	test   %eax,%eax
  800646:	78 3f                	js     800687 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800648:	83 ec 08             	sub    $0x8,%esp
  80064b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80064e:	50                   	push   %eax
  80064f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800652:	ff 30                	pushl  (%eax)
  800654:	e8 b9 fd ff ff       	call   800412 <dev_lookup>
  800659:	83 c4 10             	add    $0x10,%esp
  80065c:	85 c0                	test   %eax,%eax
  80065e:	78 27                	js     800687 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800660:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800663:	8b 42 08             	mov    0x8(%edx),%eax
  800666:	83 e0 03             	and    $0x3,%eax
  800669:	83 f8 01             	cmp    $0x1,%eax
  80066c:	74 1e                	je     80068c <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80066e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800671:	8b 40 08             	mov    0x8(%eax),%eax
  800674:	85 c0                	test   %eax,%eax
  800676:	74 35                	je     8006ad <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800678:	83 ec 04             	sub    $0x4,%esp
  80067b:	ff 75 10             	pushl  0x10(%ebp)
  80067e:	ff 75 0c             	pushl  0xc(%ebp)
  800681:	52                   	push   %edx
  800682:	ff d0                	call   *%eax
  800684:	83 c4 10             	add    $0x10,%esp
}
  800687:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80068a:	c9                   	leave  
  80068b:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80068c:	a1 04 40 80 00       	mov    0x804004,%eax
  800691:	8b 40 48             	mov    0x48(%eax),%eax
  800694:	83 ec 04             	sub    $0x4,%esp
  800697:	53                   	push   %ebx
  800698:	50                   	push   %eax
  800699:	68 19 1e 80 00       	push   $0x801e19
  80069e:	e8 2c 0a 00 00       	call   8010cf <cprintf>
		return -E_INVAL;
  8006a3:	83 c4 10             	add    $0x10,%esp
  8006a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006ab:	eb da                	jmp    800687 <read+0x5a>
		return -E_NOT_SUPP;
  8006ad:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8006b2:	eb d3                	jmp    800687 <read+0x5a>

008006b4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006b4:	55                   	push   %ebp
  8006b5:	89 e5                	mov    %esp,%ebp
  8006b7:	57                   	push   %edi
  8006b8:	56                   	push   %esi
  8006b9:	53                   	push   %ebx
  8006ba:	83 ec 0c             	sub    $0xc,%esp
  8006bd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006c3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006c8:	39 f3                	cmp    %esi,%ebx
  8006ca:	73 25                	jae    8006f1 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006cc:	83 ec 04             	sub    $0x4,%esp
  8006cf:	89 f0                	mov    %esi,%eax
  8006d1:	29 d8                	sub    %ebx,%eax
  8006d3:	50                   	push   %eax
  8006d4:	89 d8                	mov    %ebx,%eax
  8006d6:	03 45 0c             	add    0xc(%ebp),%eax
  8006d9:	50                   	push   %eax
  8006da:	57                   	push   %edi
  8006db:	e8 4d ff ff ff       	call   80062d <read>
		if (m < 0)
  8006e0:	83 c4 10             	add    $0x10,%esp
  8006e3:	85 c0                	test   %eax,%eax
  8006e5:	78 08                	js     8006ef <readn+0x3b>
			return m;
		if (m == 0)
  8006e7:	85 c0                	test   %eax,%eax
  8006e9:	74 06                	je     8006f1 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  8006eb:	01 c3                	add    %eax,%ebx
  8006ed:	eb d9                	jmp    8006c8 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006ef:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8006f1:	89 d8                	mov    %ebx,%eax
  8006f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f6:	5b                   	pop    %ebx
  8006f7:	5e                   	pop    %esi
  8006f8:	5f                   	pop    %edi
  8006f9:	5d                   	pop    %ebp
  8006fa:	c3                   	ret    

008006fb <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006fb:	55                   	push   %ebp
  8006fc:	89 e5                	mov    %esp,%ebp
  8006fe:	53                   	push   %ebx
  8006ff:	83 ec 14             	sub    $0x14,%esp
  800702:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800705:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800708:	50                   	push   %eax
  800709:	53                   	push   %ebx
  80070a:	e8 ad fc ff ff       	call   8003bc <fd_lookup>
  80070f:	83 c4 08             	add    $0x8,%esp
  800712:	85 c0                	test   %eax,%eax
  800714:	78 3a                	js     800750 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800716:	83 ec 08             	sub    $0x8,%esp
  800719:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80071c:	50                   	push   %eax
  80071d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800720:	ff 30                	pushl  (%eax)
  800722:	e8 eb fc ff ff       	call   800412 <dev_lookup>
  800727:	83 c4 10             	add    $0x10,%esp
  80072a:	85 c0                	test   %eax,%eax
  80072c:	78 22                	js     800750 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80072e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800731:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800735:	74 1e                	je     800755 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800737:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80073a:	8b 52 0c             	mov    0xc(%edx),%edx
  80073d:	85 d2                	test   %edx,%edx
  80073f:	74 35                	je     800776 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800741:	83 ec 04             	sub    $0x4,%esp
  800744:	ff 75 10             	pushl  0x10(%ebp)
  800747:	ff 75 0c             	pushl  0xc(%ebp)
  80074a:	50                   	push   %eax
  80074b:	ff d2                	call   *%edx
  80074d:	83 c4 10             	add    $0x10,%esp
}
  800750:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800753:	c9                   	leave  
  800754:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800755:	a1 04 40 80 00       	mov    0x804004,%eax
  80075a:	8b 40 48             	mov    0x48(%eax),%eax
  80075d:	83 ec 04             	sub    $0x4,%esp
  800760:	53                   	push   %ebx
  800761:	50                   	push   %eax
  800762:	68 35 1e 80 00       	push   $0x801e35
  800767:	e8 63 09 00 00       	call   8010cf <cprintf>
		return -E_INVAL;
  80076c:	83 c4 10             	add    $0x10,%esp
  80076f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800774:	eb da                	jmp    800750 <write+0x55>
		return -E_NOT_SUPP;
  800776:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80077b:	eb d3                	jmp    800750 <write+0x55>

0080077d <seek>:

int
seek(int fdnum, off_t offset)
{
  80077d:	55                   	push   %ebp
  80077e:	89 e5                	mov    %esp,%ebp
  800780:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800783:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800786:	50                   	push   %eax
  800787:	ff 75 08             	pushl  0x8(%ebp)
  80078a:	e8 2d fc ff ff       	call   8003bc <fd_lookup>
  80078f:	83 c4 08             	add    $0x8,%esp
  800792:	85 c0                	test   %eax,%eax
  800794:	78 0e                	js     8007a4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800796:	8b 55 0c             	mov    0xc(%ebp),%edx
  800799:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80079c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80079f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007a4:	c9                   	leave  
  8007a5:	c3                   	ret    

008007a6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007a6:	55                   	push   %ebp
  8007a7:	89 e5                	mov    %esp,%ebp
  8007a9:	53                   	push   %ebx
  8007aa:	83 ec 14             	sub    $0x14,%esp
  8007ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007b0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007b3:	50                   	push   %eax
  8007b4:	53                   	push   %ebx
  8007b5:	e8 02 fc ff ff       	call   8003bc <fd_lookup>
  8007ba:	83 c4 08             	add    $0x8,%esp
  8007bd:	85 c0                	test   %eax,%eax
  8007bf:	78 37                	js     8007f8 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007c1:	83 ec 08             	sub    $0x8,%esp
  8007c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007c7:	50                   	push   %eax
  8007c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007cb:	ff 30                	pushl  (%eax)
  8007cd:	e8 40 fc ff ff       	call   800412 <dev_lookup>
  8007d2:	83 c4 10             	add    $0x10,%esp
  8007d5:	85 c0                	test   %eax,%eax
  8007d7:	78 1f                	js     8007f8 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007dc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007e0:	74 1b                	je     8007fd <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8007e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007e5:	8b 52 18             	mov    0x18(%edx),%edx
  8007e8:	85 d2                	test   %edx,%edx
  8007ea:	74 32                	je     80081e <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8007ec:	83 ec 08             	sub    $0x8,%esp
  8007ef:	ff 75 0c             	pushl  0xc(%ebp)
  8007f2:	50                   	push   %eax
  8007f3:	ff d2                	call   *%edx
  8007f5:	83 c4 10             	add    $0x10,%esp
}
  8007f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007fb:	c9                   	leave  
  8007fc:	c3                   	ret    
			thisenv->env_id, fdnum);
  8007fd:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800802:	8b 40 48             	mov    0x48(%eax),%eax
  800805:	83 ec 04             	sub    $0x4,%esp
  800808:	53                   	push   %ebx
  800809:	50                   	push   %eax
  80080a:	68 f8 1d 80 00       	push   $0x801df8
  80080f:	e8 bb 08 00 00       	call   8010cf <cprintf>
		return -E_INVAL;
  800814:	83 c4 10             	add    $0x10,%esp
  800817:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80081c:	eb da                	jmp    8007f8 <ftruncate+0x52>
		return -E_NOT_SUPP;
  80081e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800823:	eb d3                	jmp    8007f8 <ftruncate+0x52>

00800825 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800825:	55                   	push   %ebp
  800826:	89 e5                	mov    %esp,%ebp
  800828:	53                   	push   %ebx
  800829:	83 ec 14             	sub    $0x14,%esp
  80082c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80082f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800832:	50                   	push   %eax
  800833:	ff 75 08             	pushl  0x8(%ebp)
  800836:	e8 81 fb ff ff       	call   8003bc <fd_lookup>
  80083b:	83 c4 08             	add    $0x8,%esp
  80083e:	85 c0                	test   %eax,%eax
  800840:	78 4b                	js     80088d <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800842:	83 ec 08             	sub    $0x8,%esp
  800845:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800848:	50                   	push   %eax
  800849:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80084c:	ff 30                	pushl  (%eax)
  80084e:	e8 bf fb ff ff       	call   800412 <dev_lookup>
  800853:	83 c4 10             	add    $0x10,%esp
  800856:	85 c0                	test   %eax,%eax
  800858:	78 33                	js     80088d <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  80085a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80085d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800861:	74 2f                	je     800892 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800863:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800866:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80086d:	00 00 00 
	stat->st_isdir = 0;
  800870:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800877:	00 00 00 
	stat->st_dev = dev;
  80087a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800880:	83 ec 08             	sub    $0x8,%esp
  800883:	53                   	push   %ebx
  800884:	ff 75 f0             	pushl  -0x10(%ebp)
  800887:	ff 50 14             	call   *0x14(%eax)
  80088a:	83 c4 10             	add    $0x10,%esp
}
  80088d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800890:	c9                   	leave  
  800891:	c3                   	ret    
		return -E_NOT_SUPP;
  800892:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800897:	eb f4                	jmp    80088d <fstat+0x68>

00800899 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800899:	55                   	push   %ebp
  80089a:	89 e5                	mov    %esp,%ebp
  80089c:	56                   	push   %esi
  80089d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80089e:	83 ec 08             	sub    $0x8,%esp
  8008a1:	6a 00                	push   $0x0
  8008a3:	ff 75 08             	pushl  0x8(%ebp)
  8008a6:	e8 da 01 00 00       	call   800a85 <open>
  8008ab:	89 c3                	mov    %eax,%ebx
  8008ad:	83 c4 10             	add    $0x10,%esp
  8008b0:	85 c0                	test   %eax,%eax
  8008b2:	78 1b                	js     8008cf <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008b4:	83 ec 08             	sub    $0x8,%esp
  8008b7:	ff 75 0c             	pushl  0xc(%ebp)
  8008ba:	50                   	push   %eax
  8008bb:	e8 65 ff ff ff       	call   800825 <fstat>
  8008c0:	89 c6                	mov    %eax,%esi
	close(fd);
  8008c2:	89 1c 24             	mov    %ebx,(%esp)
  8008c5:	e8 27 fc ff ff       	call   8004f1 <close>
	return r;
  8008ca:	83 c4 10             	add    $0x10,%esp
  8008cd:	89 f3                	mov    %esi,%ebx
}
  8008cf:	89 d8                	mov    %ebx,%eax
  8008d1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008d4:	5b                   	pop    %ebx
  8008d5:	5e                   	pop    %esi
  8008d6:	5d                   	pop    %ebp
  8008d7:	c3                   	ret    

008008d8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	56                   	push   %esi
  8008dc:	53                   	push   %ebx
  8008dd:	89 c6                	mov    %eax,%esi
  8008df:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008e1:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8008e8:	74 27                	je     800911 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008ea:	6a 07                	push   $0x7
  8008ec:	68 00 50 80 00       	push   $0x805000
  8008f1:	56                   	push   %esi
  8008f2:	ff 35 00 40 80 00    	pushl  0x804000
  8008f8:	e8 95 11 00 00       	call   801a92 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8008fd:	83 c4 0c             	add    $0xc,%esp
  800900:	6a 00                	push   $0x0
  800902:	53                   	push   %ebx
  800903:	6a 00                	push   $0x0
  800905:	e8 21 11 00 00       	call   801a2b <ipc_recv>
}
  80090a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80090d:	5b                   	pop    %ebx
  80090e:	5e                   	pop    %esi
  80090f:	5d                   	pop    %ebp
  800910:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800911:	83 ec 0c             	sub    $0xc,%esp
  800914:	6a 01                	push   $0x1
  800916:	e8 cb 11 00 00       	call   801ae6 <ipc_find_env>
  80091b:	a3 00 40 80 00       	mov    %eax,0x804000
  800920:	83 c4 10             	add    $0x10,%esp
  800923:	eb c5                	jmp    8008ea <fsipc+0x12>

00800925 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800925:	55                   	push   %ebp
  800926:	89 e5                	mov    %esp,%ebp
  800928:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80092b:	8b 45 08             	mov    0x8(%ebp),%eax
  80092e:	8b 40 0c             	mov    0xc(%eax),%eax
  800931:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800936:	8b 45 0c             	mov    0xc(%ebp),%eax
  800939:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80093e:	ba 00 00 00 00       	mov    $0x0,%edx
  800943:	b8 02 00 00 00       	mov    $0x2,%eax
  800948:	e8 8b ff ff ff       	call   8008d8 <fsipc>
}
  80094d:	c9                   	leave  
  80094e:	c3                   	ret    

0080094f <devfile_flush>:
{
  80094f:	55                   	push   %ebp
  800950:	89 e5                	mov    %esp,%ebp
  800952:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800955:	8b 45 08             	mov    0x8(%ebp),%eax
  800958:	8b 40 0c             	mov    0xc(%eax),%eax
  80095b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800960:	ba 00 00 00 00       	mov    $0x0,%edx
  800965:	b8 06 00 00 00       	mov    $0x6,%eax
  80096a:	e8 69 ff ff ff       	call   8008d8 <fsipc>
}
  80096f:	c9                   	leave  
  800970:	c3                   	ret    

00800971 <devfile_stat>:
{
  800971:	55                   	push   %ebp
  800972:	89 e5                	mov    %esp,%ebp
  800974:	53                   	push   %ebx
  800975:	83 ec 04             	sub    $0x4,%esp
  800978:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80097b:	8b 45 08             	mov    0x8(%ebp),%eax
  80097e:	8b 40 0c             	mov    0xc(%eax),%eax
  800981:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800986:	ba 00 00 00 00       	mov    $0x0,%edx
  80098b:	b8 05 00 00 00       	mov    $0x5,%eax
  800990:	e8 43 ff ff ff       	call   8008d8 <fsipc>
  800995:	85 c0                	test   %eax,%eax
  800997:	78 2c                	js     8009c5 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800999:	83 ec 08             	sub    $0x8,%esp
  80099c:	68 00 50 80 00       	push   $0x805000
  8009a1:	53                   	push   %ebx
  8009a2:	e8 47 0d 00 00       	call   8016ee <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009a7:	a1 80 50 80 00       	mov    0x805080,%eax
  8009ac:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009b2:	a1 84 50 80 00       	mov    0x805084,%eax
  8009b7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009bd:	83 c4 10             	add    $0x10,%esp
  8009c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009c8:	c9                   	leave  
  8009c9:	c3                   	ret    

008009ca <devfile_write>:
{
  8009ca:	55                   	push   %ebp
  8009cb:	89 e5                	mov    %esp,%ebp
  8009cd:	83 ec 0c             	sub    $0xc,%esp
  8009d0:	8b 45 10             	mov    0x10(%ebp),%eax
    	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8009d6:	8b 52 0c             	mov    0xc(%edx),%edx
  8009d9:	89 15 00 50 80 00    	mov    %edx,0x805000
    	fsipcbuf.write.req_n = n;
  8009df:	a3 04 50 80 00       	mov    %eax,0x805004
    	memmove(fsipcbuf.write.req_buf, buf, n);
  8009e4:	50                   	push   %eax
  8009e5:	ff 75 0c             	pushl  0xc(%ebp)
  8009e8:	68 08 50 80 00       	push   $0x805008
  8009ed:	e8 8a 0e 00 00       	call   80187c <memmove>
    	return fsipc(FSREQ_WRITE, NULL);
  8009f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009f7:	b8 04 00 00 00       	mov    $0x4,%eax
  8009fc:	e8 d7 fe ff ff       	call   8008d8 <fsipc>
}
  800a01:	c9                   	leave  
  800a02:	c3                   	ret    

00800a03 <devfile_read>:
{
  800a03:	55                   	push   %ebp
  800a04:	89 e5                	mov    %esp,%ebp
  800a06:	56                   	push   %esi
  800a07:	53                   	push   %ebx
  800a08:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0e:	8b 40 0c             	mov    0xc(%eax),%eax
  800a11:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a16:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a1c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a21:	b8 03 00 00 00       	mov    $0x3,%eax
  800a26:	e8 ad fe ff ff       	call   8008d8 <fsipc>
  800a2b:	89 c3                	mov    %eax,%ebx
  800a2d:	85 c0                	test   %eax,%eax
  800a2f:	78 1f                	js     800a50 <devfile_read+0x4d>
	assert(r <= n);
  800a31:	39 f0                	cmp    %esi,%eax
  800a33:	77 24                	ja     800a59 <devfile_read+0x56>
	assert(r <= PGSIZE);
  800a35:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a3a:	7f 33                	jg     800a6f <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a3c:	83 ec 04             	sub    $0x4,%esp
  800a3f:	50                   	push   %eax
  800a40:	68 00 50 80 00       	push   $0x805000
  800a45:	ff 75 0c             	pushl  0xc(%ebp)
  800a48:	e8 2f 0e 00 00       	call   80187c <memmove>
	return r;
  800a4d:	83 c4 10             	add    $0x10,%esp
}
  800a50:	89 d8                	mov    %ebx,%eax
  800a52:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a55:	5b                   	pop    %ebx
  800a56:	5e                   	pop    %esi
  800a57:	5d                   	pop    %ebp
  800a58:	c3                   	ret    
	assert(r <= n);
  800a59:	68 64 1e 80 00       	push   $0x801e64
  800a5e:	68 6b 1e 80 00       	push   $0x801e6b
  800a63:	6a 7c                	push   $0x7c
  800a65:	68 80 1e 80 00       	push   $0x801e80
  800a6a:	e8 85 05 00 00       	call   800ff4 <_panic>
	assert(r <= PGSIZE);
  800a6f:	68 8b 1e 80 00       	push   $0x801e8b
  800a74:	68 6b 1e 80 00       	push   $0x801e6b
  800a79:	6a 7d                	push   $0x7d
  800a7b:	68 80 1e 80 00       	push   $0x801e80
  800a80:	e8 6f 05 00 00       	call   800ff4 <_panic>

00800a85 <open>:
{
  800a85:	55                   	push   %ebp
  800a86:	89 e5                	mov    %esp,%ebp
  800a88:	56                   	push   %esi
  800a89:	53                   	push   %ebx
  800a8a:	83 ec 1c             	sub    $0x1c,%esp
  800a8d:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800a90:	56                   	push   %esi
  800a91:	e8 21 0c 00 00       	call   8016b7 <strlen>
  800a96:	83 c4 10             	add    $0x10,%esp
  800a99:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800a9e:	7f 6c                	jg     800b0c <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  800aa0:	83 ec 0c             	sub    $0xc,%esp
  800aa3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800aa6:	50                   	push   %eax
  800aa7:	e8 c1 f8 ff ff       	call   80036d <fd_alloc>
  800aac:	89 c3                	mov    %eax,%ebx
  800aae:	83 c4 10             	add    $0x10,%esp
  800ab1:	85 c0                	test   %eax,%eax
  800ab3:	78 3c                	js     800af1 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  800ab5:	83 ec 08             	sub    $0x8,%esp
  800ab8:	56                   	push   %esi
  800ab9:	68 00 50 80 00       	push   $0x805000
  800abe:	e8 2b 0c 00 00       	call   8016ee <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ac3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac6:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800acb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ace:	b8 01 00 00 00       	mov    $0x1,%eax
  800ad3:	e8 00 fe ff ff       	call   8008d8 <fsipc>
  800ad8:	89 c3                	mov    %eax,%ebx
  800ada:	83 c4 10             	add    $0x10,%esp
  800add:	85 c0                	test   %eax,%eax
  800adf:	78 19                	js     800afa <open+0x75>
	return fd2num(fd);
  800ae1:	83 ec 0c             	sub    $0xc,%esp
  800ae4:	ff 75 f4             	pushl  -0xc(%ebp)
  800ae7:	e8 5a f8 ff ff       	call   800346 <fd2num>
  800aec:	89 c3                	mov    %eax,%ebx
  800aee:	83 c4 10             	add    $0x10,%esp
}
  800af1:	89 d8                	mov    %ebx,%eax
  800af3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800af6:	5b                   	pop    %ebx
  800af7:	5e                   	pop    %esi
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    
		fd_close(fd, 0);
  800afa:	83 ec 08             	sub    $0x8,%esp
  800afd:	6a 00                	push   $0x0
  800aff:	ff 75 f4             	pushl  -0xc(%ebp)
  800b02:	e8 61 f9 ff ff       	call   800468 <fd_close>
		return r;
  800b07:	83 c4 10             	add    $0x10,%esp
  800b0a:	eb e5                	jmp    800af1 <open+0x6c>
		return -E_BAD_PATH;
  800b0c:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b11:	eb de                	jmp    800af1 <open+0x6c>

00800b13 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b13:	55                   	push   %ebp
  800b14:	89 e5                	mov    %esp,%ebp
  800b16:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b19:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1e:	b8 08 00 00 00       	mov    $0x8,%eax
  800b23:	e8 b0 fd ff ff       	call   8008d8 <fsipc>
}
  800b28:	c9                   	leave  
  800b29:	c3                   	ret    

00800b2a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b2a:	55                   	push   %ebp
  800b2b:	89 e5                	mov    %esp,%ebp
  800b2d:	56                   	push   %esi
  800b2e:	53                   	push   %ebx
  800b2f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b32:	83 ec 0c             	sub    $0xc,%esp
  800b35:	ff 75 08             	pushl  0x8(%ebp)
  800b38:	e8 19 f8 ff ff       	call   800356 <fd2data>
  800b3d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b3f:	83 c4 08             	add    $0x8,%esp
  800b42:	68 97 1e 80 00       	push   $0x801e97
  800b47:	53                   	push   %ebx
  800b48:	e8 a1 0b 00 00       	call   8016ee <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b4d:	8b 46 04             	mov    0x4(%esi),%eax
  800b50:	2b 06                	sub    (%esi),%eax
  800b52:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b58:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b5f:	00 00 00 
	stat->st_dev = &devpipe;
  800b62:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b69:	30 80 00 
	return 0;
}
  800b6c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b71:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b74:	5b                   	pop    %ebx
  800b75:	5e                   	pop    %esi
  800b76:	5d                   	pop    %ebp
  800b77:	c3                   	ret    

00800b78 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b78:	55                   	push   %ebp
  800b79:	89 e5                	mov    %esp,%ebp
  800b7b:	53                   	push   %ebx
  800b7c:	83 ec 0c             	sub    $0xc,%esp
  800b7f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b82:	53                   	push   %ebx
  800b83:	6a 00                	push   $0x0
  800b85:	e8 50 f6 ff ff       	call   8001da <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b8a:	89 1c 24             	mov    %ebx,(%esp)
  800b8d:	e8 c4 f7 ff ff       	call   800356 <fd2data>
  800b92:	83 c4 08             	add    $0x8,%esp
  800b95:	50                   	push   %eax
  800b96:	6a 00                	push   $0x0
  800b98:	e8 3d f6 ff ff       	call   8001da <sys_page_unmap>
}
  800b9d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ba0:	c9                   	leave  
  800ba1:	c3                   	ret    

00800ba2 <_pipeisclosed>:
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	57                   	push   %edi
  800ba6:	56                   	push   %esi
  800ba7:	53                   	push   %ebx
  800ba8:	83 ec 1c             	sub    $0x1c,%esp
  800bab:	89 c7                	mov    %eax,%edi
  800bad:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800baf:	a1 04 40 80 00       	mov    0x804004,%eax
  800bb4:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800bb7:	83 ec 0c             	sub    $0xc,%esp
  800bba:	57                   	push   %edi
  800bbb:	e8 5f 0f 00 00       	call   801b1f <pageref>
  800bc0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800bc3:	89 34 24             	mov    %esi,(%esp)
  800bc6:	e8 54 0f 00 00       	call   801b1f <pageref>
		nn = thisenv->env_runs;
  800bcb:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800bd1:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800bd4:	83 c4 10             	add    $0x10,%esp
  800bd7:	39 cb                	cmp    %ecx,%ebx
  800bd9:	74 1b                	je     800bf6 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800bdb:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800bde:	75 cf                	jne    800baf <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800be0:	8b 42 58             	mov    0x58(%edx),%eax
  800be3:	6a 01                	push   $0x1
  800be5:	50                   	push   %eax
  800be6:	53                   	push   %ebx
  800be7:	68 9e 1e 80 00       	push   $0x801e9e
  800bec:	e8 de 04 00 00       	call   8010cf <cprintf>
  800bf1:	83 c4 10             	add    $0x10,%esp
  800bf4:	eb b9                	jmp    800baf <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800bf6:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800bf9:	0f 94 c0             	sete   %al
  800bfc:	0f b6 c0             	movzbl %al,%eax
}
  800bff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c02:	5b                   	pop    %ebx
  800c03:	5e                   	pop    %esi
  800c04:	5f                   	pop    %edi
  800c05:	5d                   	pop    %ebp
  800c06:	c3                   	ret    

00800c07 <devpipe_write>:
{
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	57                   	push   %edi
  800c0b:	56                   	push   %esi
  800c0c:	53                   	push   %ebx
  800c0d:	83 ec 28             	sub    $0x28,%esp
  800c10:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800c13:	56                   	push   %esi
  800c14:	e8 3d f7 ff ff       	call   800356 <fd2data>
  800c19:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c1b:	83 c4 10             	add    $0x10,%esp
  800c1e:	bf 00 00 00 00       	mov    $0x0,%edi
  800c23:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c26:	74 4f                	je     800c77 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c28:	8b 43 04             	mov    0x4(%ebx),%eax
  800c2b:	8b 0b                	mov    (%ebx),%ecx
  800c2d:	8d 51 20             	lea    0x20(%ecx),%edx
  800c30:	39 d0                	cmp    %edx,%eax
  800c32:	72 14                	jb     800c48 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  800c34:	89 da                	mov    %ebx,%edx
  800c36:	89 f0                	mov    %esi,%eax
  800c38:	e8 65 ff ff ff       	call   800ba2 <_pipeisclosed>
  800c3d:	85 c0                	test   %eax,%eax
  800c3f:	75 3a                	jne    800c7b <devpipe_write+0x74>
			sys_yield();
  800c41:	e8 f0 f4 ff ff       	call   800136 <sys_yield>
  800c46:	eb e0                	jmp    800c28 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c4f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c52:	89 c2                	mov    %eax,%edx
  800c54:	c1 fa 1f             	sar    $0x1f,%edx
  800c57:	89 d1                	mov    %edx,%ecx
  800c59:	c1 e9 1b             	shr    $0x1b,%ecx
  800c5c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c5f:	83 e2 1f             	and    $0x1f,%edx
  800c62:	29 ca                	sub    %ecx,%edx
  800c64:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c68:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c6c:	83 c0 01             	add    $0x1,%eax
  800c6f:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800c72:	83 c7 01             	add    $0x1,%edi
  800c75:	eb ac                	jmp    800c23 <devpipe_write+0x1c>
	return i;
  800c77:	89 f8                	mov    %edi,%eax
  800c79:	eb 05                	jmp    800c80 <devpipe_write+0x79>
				return 0;
  800c7b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c83:	5b                   	pop    %ebx
  800c84:	5e                   	pop    %esi
  800c85:	5f                   	pop    %edi
  800c86:	5d                   	pop    %ebp
  800c87:	c3                   	ret    

00800c88 <devpipe_read>:
{
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	57                   	push   %edi
  800c8c:	56                   	push   %esi
  800c8d:	53                   	push   %ebx
  800c8e:	83 ec 18             	sub    $0x18,%esp
  800c91:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800c94:	57                   	push   %edi
  800c95:	e8 bc f6 ff ff       	call   800356 <fd2data>
  800c9a:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c9c:	83 c4 10             	add    $0x10,%esp
  800c9f:	be 00 00 00 00       	mov    $0x0,%esi
  800ca4:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ca7:	74 47                	je     800cf0 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  800ca9:	8b 03                	mov    (%ebx),%eax
  800cab:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cae:	75 22                	jne    800cd2 <devpipe_read+0x4a>
			if (i > 0)
  800cb0:	85 f6                	test   %esi,%esi
  800cb2:	75 14                	jne    800cc8 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  800cb4:	89 da                	mov    %ebx,%edx
  800cb6:	89 f8                	mov    %edi,%eax
  800cb8:	e8 e5 fe ff ff       	call   800ba2 <_pipeisclosed>
  800cbd:	85 c0                	test   %eax,%eax
  800cbf:	75 33                	jne    800cf4 <devpipe_read+0x6c>
			sys_yield();
  800cc1:	e8 70 f4 ff ff       	call   800136 <sys_yield>
  800cc6:	eb e1                	jmp    800ca9 <devpipe_read+0x21>
				return i;
  800cc8:	89 f0                	mov    %esi,%eax
}
  800cca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ccd:	5b                   	pop    %ebx
  800cce:	5e                   	pop    %esi
  800ccf:	5f                   	pop    %edi
  800cd0:	5d                   	pop    %ebp
  800cd1:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cd2:	99                   	cltd   
  800cd3:	c1 ea 1b             	shr    $0x1b,%edx
  800cd6:	01 d0                	add    %edx,%eax
  800cd8:	83 e0 1f             	and    $0x1f,%eax
  800cdb:	29 d0                	sub    %edx,%eax
  800cdd:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800ce2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce5:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800ce8:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800ceb:	83 c6 01             	add    $0x1,%esi
  800cee:	eb b4                	jmp    800ca4 <devpipe_read+0x1c>
	return i;
  800cf0:	89 f0                	mov    %esi,%eax
  800cf2:	eb d6                	jmp    800cca <devpipe_read+0x42>
				return 0;
  800cf4:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf9:	eb cf                	jmp    800cca <devpipe_read+0x42>

00800cfb <pipe>:
{
  800cfb:	55                   	push   %ebp
  800cfc:	89 e5                	mov    %esp,%ebp
  800cfe:	56                   	push   %esi
  800cff:	53                   	push   %ebx
  800d00:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800d03:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d06:	50                   	push   %eax
  800d07:	e8 61 f6 ff ff       	call   80036d <fd_alloc>
  800d0c:	89 c3                	mov    %eax,%ebx
  800d0e:	83 c4 10             	add    $0x10,%esp
  800d11:	85 c0                	test   %eax,%eax
  800d13:	78 5b                	js     800d70 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d15:	83 ec 04             	sub    $0x4,%esp
  800d18:	68 07 04 00 00       	push   $0x407
  800d1d:	ff 75 f4             	pushl  -0xc(%ebp)
  800d20:	6a 00                	push   $0x0
  800d22:	e8 2e f4 ff ff       	call   800155 <sys_page_alloc>
  800d27:	89 c3                	mov    %eax,%ebx
  800d29:	83 c4 10             	add    $0x10,%esp
  800d2c:	85 c0                	test   %eax,%eax
  800d2e:	78 40                	js     800d70 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  800d30:	83 ec 0c             	sub    $0xc,%esp
  800d33:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d36:	50                   	push   %eax
  800d37:	e8 31 f6 ff ff       	call   80036d <fd_alloc>
  800d3c:	89 c3                	mov    %eax,%ebx
  800d3e:	83 c4 10             	add    $0x10,%esp
  800d41:	85 c0                	test   %eax,%eax
  800d43:	78 1b                	js     800d60 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d45:	83 ec 04             	sub    $0x4,%esp
  800d48:	68 07 04 00 00       	push   $0x407
  800d4d:	ff 75 f0             	pushl  -0x10(%ebp)
  800d50:	6a 00                	push   $0x0
  800d52:	e8 fe f3 ff ff       	call   800155 <sys_page_alloc>
  800d57:	89 c3                	mov    %eax,%ebx
  800d59:	83 c4 10             	add    $0x10,%esp
  800d5c:	85 c0                	test   %eax,%eax
  800d5e:	79 19                	jns    800d79 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  800d60:	83 ec 08             	sub    $0x8,%esp
  800d63:	ff 75 f4             	pushl  -0xc(%ebp)
  800d66:	6a 00                	push   $0x0
  800d68:	e8 6d f4 ff ff       	call   8001da <sys_page_unmap>
  800d6d:	83 c4 10             	add    $0x10,%esp
}
  800d70:	89 d8                	mov    %ebx,%eax
  800d72:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d75:	5b                   	pop    %ebx
  800d76:	5e                   	pop    %esi
  800d77:	5d                   	pop    %ebp
  800d78:	c3                   	ret    
	va = fd2data(fd0);
  800d79:	83 ec 0c             	sub    $0xc,%esp
  800d7c:	ff 75 f4             	pushl  -0xc(%ebp)
  800d7f:	e8 d2 f5 ff ff       	call   800356 <fd2data>
  800d84:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d86:	83 c4 0c             	add    $0xc,%esp
  800d89:	68 07 04 00 00       	push   $0x407
  800d8e:	50                   	push   %eax
  800d8f:	6a 00                	push   $0x0
  800d91:	e8 bf f3 ff ff       	call   800155 <sys_page_alloc>
  800d96:	89 c3                	mov    %eax,%ebx
  800d98:	83 c4 10             	add    $0x10,%esp
  800d9b:	85 c0                	test   %eax,%eax
  800d9d:	0f 88 8c 00 00 00    	js     800e2f <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800da3:	83 ec 0c             	sub    $0xc,%esp
  800da6:	ff 75 f0             	pushl  -0x10(%ebp)
  800da9:	e8 a8 f5 ff ff       	call   800356 <fd2data>
  800dae:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800db5:	50                   	push   %eax
  800db6:	6a 00                	push   $0x0
  800db8:	56                   	push   %esi
  800db9:	6a 00                	push   $0x0
  800dbb:	e8 d8 f3 ff ff       	call   800198 <sys_page_map>
  800dc0:	89 c3                	mov    %eax,%ebx
  800dc2:	83 c4 20             	add    $0x20,%esp
  800dc5:	85 c0                	test   %eax,%eax
  800dc7:	78 58                	js     800e21 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  800dc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dcc:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800dd2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800dd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dd7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  800dde:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800de1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800de7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800de9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dec:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800df3:	83 ec 0c             	sub    $0xc,%esp
  800df6:	ff 75 f4             	pushl  -0xc(%ebp)
  800df9:	e8 48 f5 ff ff       	call   800346 <fd2num>
  800dfe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e01:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e03:	83 c4 04             	add    $0x4,%esp
  800e06:	ff 75 f0             	pushl  -0x10(%ebp)
  800e09:	e8 38 f5 ff ff       	call   800346 <fd2num>
  800e0e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e11:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e14:	83 c4 10             	add    $0x10,%esp
  800e17:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e1c:	e9 4f ff ff ff       	jmp    800d70 <pipe+0x75>
	sys_page_unmap(0, va);
  800e21:	83 ec 08             	sub    $0x8,%esp
  800e24:	56                   	push   %esi
  800e25:	6a 00                	push   $0x0
  800e27:	e8 ae f3 ff ff       	call   8001da <sys_page_unmap>
  800e2c:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800e2f:	83 ec 08             	sub    $0x8,%esp
  800e32:	ff 75 f0             	pushl  -0x10(%ebp)
  800e35:	6a 00                	push   $0x0
  800e37:	e8 9e f3 ff ff       	call   8001da <sys_page_unmap>
  800e3c:	83 c4 10             	add    $0x10,%esp
  800e3f:	e9 1c ff ff ff       	jmp    800d60 <pipe+0x65>

00800e44 <pipeisclosed>:
{
  800e44:	55                   	push   %ebp
  800e45:	89 e5                	mov    %esp,%ebp
  800e47:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e4a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e4d:	50                   	push   %eax
  800e4e:	ff 75 08             	pushl  0x8(%ebp)
  800e51:	e8 66 f5 ff ff       	call   8003bc <fd_lookup>
  800e56:	83 c4 10             	add    $0x10,%esp
  800e59:	85 c0                	test   %eax,%eax
  800e5b:	78 18                	js     800e75 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  800e5d:	83 ec 0c             	sub    $0xc,%esp
  800e60:	ff 75 f4             	pushl  -0xc(%ebp)
  800e63:	e8 ee f4 ff ff       	call   800356 <fd2data>
	return _pipeisclosed(fd, p);
  800e68:	89 c2                	mov    %eax,%edx
  800e6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e6d:	e8 30 fd ff ff       	call   800ba2 <_pipeisclosed>
  800e72:	83 c4 10             	add    $0x10,%esp
}
  800e75:	c9                   	leave  
  800e76:	c3                   	ret    

00800e77 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e77:	55                   	push   %ebp
  800e78:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e7a:	b8 00 00 00 00       	mov    $0x0,%eax
  800e7f:	5d                   	pop    %ebp
  800e80:	c3                   	ret    

00800e81 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e81:	55                   	push   %ebp
  800e82:	89 e5                	mov    %esp,%ebp
  800e84:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e87:	68 b6 1e 80 00       	push   $0x801eb6
  800e8c:	ff 75 0c             	pushl  0xc(%ebp)
  800e8f:	e8 5a 08 00 00       	call   8016ee <strcpy>
	return 0;
}
  800e94:	b8 00 00 00 00       	mov    $0x0,%eax
  800e99:	c9                   	leave  
  800e9a:	c3                   	ret    

00800e9b <devcons_write>:
{
  800e9b:	55                   	push   %ebp
  800e9c:	89 e5                	mov    %esp,%ebp
  800e9e:	57                   	push   %edi
  800e9f:	56                   	push   %esi
  800ea0:	53                   	push   %ebx
  800ea1:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800ea7:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800eac:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800eb2:	eb 2f                	jmp    800ee3 <devcons_write+0x48>
		m = n - tot;
  800eb4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eb7:	29 f3                	sub    %esi,%ebx
  800eb9:	83 fb 7f             	cmp    $0x7f,%ebx
  800ebc:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800ec1:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800ec4:	83 ec 04             	sub    $0x4,%esp
  800ec7:	53                   	push   %ebx
  800ec8:	89 f0                	mov    %esi,%eax
  800eca:	03 45 0c             	add    0xc(%ebp),%eax
  800ecd:	50                   	push   %eax
  800ece:	57                   	push   %edi
  800ecf:	e8 a8 09 00 00       	call   80187c <memmove>
		sys_cputs(buf, m);
  800ed4:	83 c4 08             	add    $0x8,%esp
  800ed7:	53                   	push   %ebx
  800ed8:	57                   	push   %edi
  800ed9:	e8 bb f1 ff ff       	call   800099 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800ede:	01 de                	add    %ebx,%esi
  800ee0:	83 c4 10             	add    $0x10,%esp
  800ee3:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ee6:	72 cc                	jb     800eb4 <devcons_write+0x19>
}
  800ee8:	89 f0                	mov    %esi,%eax
  800eea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eed:	5b                   	pop    %ebx
  800eee:	5e                   	pop    %esi
  800eef:	5f                   	pop    %edi
  800ef0:	5d                   	pop    %ebp
  800ef1:	c3                   	ret    

00800ef2 <devcons_read>:
{
  800ef2:	55                   	push   %ebp
  800ef3:	89 e5                	mov    %esp,%ebp
  800ef5:	83 ec 08             	sub    $0x8,%esp
  800ef8:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800efd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f01:	75 07                	jne    800f0a <devcons_read+0x18>
}
  800f03:	c9                   	leave  
  800f04:	c3                   	ret    
		sys_yield();
  800f05:	e8 2c f2 ff ff       	call   800136 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  800f0a:	e8 a8 f1 ff ff       	call   8000b7 <sys_cgetc>
  800f0f:	85 c0                	test   %eax,%eax
  800f11:	74 f2                	je     800f05 <devcons_read+0x13>
	if (c < 0)
  800f13:	85 c0                	test   %eax,%eax
  800f15:	78 ec                	js     800f03 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  800f17:	83 f8 04             	cmp    $0x4,%eax
  800f1a:	74 0c                	je     800f28 <devcons_read+0x36>
	*(char*)vbuf = c;
  800f1c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f1f:	88 02                	mov    %al,(%edx)
	return 1;
  800f21:	b8 01 00 00 00       	mov    $0x1,%eax
  800f26:	eb db                	jmp    800f03 <devcons_read+0x11>
		return 0;
  800f28:	b8 00 00 00 00       	mov    $0x0,%eax
  800f2d:	eb d4                	jmp    800f03 <devcons_read+0x11>

00800f2f <cputchar>:
{
  800f2f:	55                   	push   %ebp
  800f30:	89 e5                	mov    %esp,%ebp
  800f32:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f35:	8b 45 08             	mov    0x8(%ebp),%eax
  800f38:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800f3b:	6a 01                	push   $0x1
  800f3d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f40:	50                   	push   %eax
  800f41:	e8 53 f1 ff ff       	call   800099 <sys_cputs>
}
  800f46:	83 c4 10             	add    $0x10,%esp
  800f49:	c9                   	leave  
  800f4a:	c3                   	ret    

00800f4b <getchar>:
{
  800f4b:	55                   	push   %ebp
  800f4c:	89 e5                	mov    %esp,%ebp
  800f4e:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800f51:	6a 01                	push   $0x1
  800f53:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f56:	50                   	push   %eax
  800f57:	6a 00                	push   $0x0
  800f59:	e8 cf f6 ff ff       	call   80062d <read>
	if (r < 0)
  800f5e:	83 c4 10             	add    $0x10,%esp
  800f61:	85 c0                	test   %eax,%eax
  800f63:	78 08                	js     800f6d <getchar+0x22>
	if (r < 1)
  800f65:	85 c0                	test   %eax,%eax
  800f67:	7e 06                	jle    800f6f <getchar+0x24>
	return c;
  800f69:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800f6d:	c9                   	leave  
  800f6e:	c3                   	ret    
		return -E_EOF;
  800f6f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800f74:	eb f7                	jmp    800f6d <getchar+0x22>

00800f76 <iscons>:
{
  800f76:	55                   	push   %ebp
  800f77:	89 e5                	mov    %esp,%ebp
  800f79:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f7c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f7f:	50                   	push   %eax
  800f80:	ff 75 08             	pushl  0x8(%ebp)
  800f83:	e8 34 f4 ff ff       	call   8003bc <fd_lookup>
  800f88:	83 c4 10             	add    $0x10,%esp
  800f8b:	85 c0                	test   %eax,%eax
  800f8d:	78 11                	js     800fa0 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  800f8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f92:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800f98:	39 10                	cmp    %edx,(%eax)
  800f9a:	0f 94 c0             	sete   %al
  800f9d:	0f b6 c0             	movzbl %al,%eax
}
  800fa0:	c9                   	leave  
  800fa1:	c3                   	ret    

00800fa2 <opencons>:
{
  800fa2:	55                   	push   %ebp
  800fa3:	89 e5                	mov    %esp,%ebp
  800fa5:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800fa8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fab:	50                   	push   %eax
  800fac:	e8 bc f3 ff ff       	call   80036d <fd_alloc>
  800fb1:	83 c4 10             	add    $0x10,%esp
  800fb4:	85 c0                	test   %eax,%eax
  800fb6:	78 3a                	js     800ff2 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fb8:	83 ec 04             	sub    $0x4,%esp
  800fbb:	68 07 04 00 00       	push   $0x407
  800fc0:	ff 75 f4             	pushl  -0xc(%ebp)
  800fc3:	6a 00                	push   $0x0
  800fc5:	e8 8b f1 ff ff       	call   800155 <sys_page_alloc>
  800fca:	83 c4 10             	add    $0x10,%esp
  800fcd:	85 c0                	test   %eax,%eax
  800fcf:	78 21                	js     800ff2 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  800fd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fd4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fda:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800fdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fdf:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800fe6:	83 ec 0c             	sub    $0xc,%esp
  800fe9:	50                   	push   %eax
  800fea:	e8 57 f3 ff ff       	call   800346 <fd2num>
  800fef:	83 c4 10             	add    $0x10,%esp
}
  800ff2:	c9                   	leave  
  800ff3:	c3                   	ret    

00800ff4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800ff4:	55                   	push   %ebp
  800ff5:	89 e5                	mov    %esp,%ebp
  800ff7:	56                   	push   %esi
  800ff8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800ff9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800ffc:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801002:	e8 10 f1 ff ff       	call   800117 <sys_getenvid>
  801007:	83 ec 0c             	sub    $0xc,%esp
  80100a:	ff 75 0c             	pushl  0xc(%ebp)
  80100d:	ff 75 08             	pushl  0x8(%ebp)
  801010:	56                   	push   %esi
  801011:	50                   	push   %eax
  801012:	68 c4 1e 80 00       	push   $0x801ec4
  801017:	e8 b3 00 00 00       	call   8010cf <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80101c:	83 c4 18             	add    $0x18,%esp
  80101f:	53                   	push   %ebx
  801020:	ff 75 10             	pushl  0x10(%ebp)
  801023:	e8 56 00 00 00       	call   80107e <vcprintf>
	cprintf("\n");
  801028:	c7 04 24 af 1e 80 00 	movl   $0x801eaf,(%esp)
  80102f:	e8 9b 00 00 00       	call   8010cf <cprintf>
  801034:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801037:	cc                   	int3   
  801038:	eb fd                	jmp    801037 <_panic+0x43>

0080103a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80103a:	55                   	push   %ebp
  80103b:	89 e5                	mov    %esp,%ebp
  80103d:	53                   	push   %ebx
  80103e:	83 ec 04             	sub    $0x4,%esp
  801041:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801044:	8b 13                	mov    (%ebx),%edx
  801046:	8d 42 01             	lea    0x1(%edx),%eax
  801049:	89 03                	mov    %eax,(%ebx)
  80104b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80104e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801052:	3d ff 00 00 00       	cmp    $0xff,%eax
  801057:	74 09                	je     801062 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801059:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80105d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801060:	c9                   	leave  
  801061:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801062:	83 ec 08             	sub    $0x8,%esp
  801065:	68 ff 00 00 00       	push   $0xff
  80106a:	8d 43 08             	lea    0x8(%ebx),%eax
  80106d:	50                   	push   %eax
  80106e:	e8 26 f0 ff ff       	call   800099 <sys_cputs>
		b->idx = 0;
  801073:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801079:	83 c4 10             	add    $0x10,%esp
  80107c:	eb db                	jmp    801059 <putch+0x1f>

0080107e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80107e:	55                   	push   %ebp
  80107f:	89 e5                	mov    %esp,%ebp
  801081:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801087:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80108e:	00 00 00 
	b.cnt = 0;
  801091:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801098:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80109b:	ff 75 0c             	pushl  0xc(%ebp)
  80109e:	ff 75 08             	pushl  0x8(%ebp)
  8010a1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010a7:	50                   	push   %eax
  8010a8:	68 3a 10 80 00       	push   $0x80103a
  8010ad:	e8 1a 01 00 00       	call   8011cc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010b2:	83 c4 08             	add    $0x8,%esp
  8010b5:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010bb:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010c1:	50                   	push   %eax
  8010c2:	e8 d2 ef ff ff       	call   800099 <sys_cputs>

	return b.cnt;
}
  8010c7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010cd:	c9                   	leave  
  8010ce:	c3                   	ret    

008010cf <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010cf:	55                   	push   %ebp
  8010d0:	89 e5                	mov    %esp,%ebp
  8010d2:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010d5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010d8:	50                   	push   %eax
  8010d9:	ff 75 08             	pushl  0x8(%ebp)
  8010dc:	e8 9d ff ff ff       	call   80107e <vcprintf>
	va_end(ap);

	return cnt;
}
  8010e1:	c9                   	leave  
  8010e2:	c3                   	ret    

008010e3 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010e3:	55                   	push   %ebp
  8010e4:	89 e5                	mov    %esp,%ebp
  8010e6:	57                   	push   %edi
  8010e7:	56                   	push   %esi
  8010e8:	53                   	push   %ebx
  8010e9:	83 ec 1c             	sub    $0x1c,%esp
  8010ec:	89 c7                	mov    %eax,%edi
  8010ee:	89 d6                	mov    %edx,%esi
  8010f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8010f9:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8010fc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8010ff:	bb 00 00 00 00       	mov    $0x0,%ebx
  801104:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801107:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80110a:	39 d3                	cmp    %edx,%ebx
  80110c:	72 05                	jb     801113 <printnum+0x30>
  80110e:	39 45 10             	cmp    %eax,0x10(%ebp)
  801111:	77 7a                	ja     80118d <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801113:	83 ec 0c             	sub    $0xc,%esp
  801116:	ff 75 18             	pushl  0x18(%ebp)
  801119:	8b 45 14             	mov    0x14(%ebp),%eax
  80111c:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80111f:	53                   	push   %ebx
  801120:	ff 75 10             	pushl  0x10(%ebp)
  801123:	83 ec 08             	sub    $0x8,%esp
  801126:	ff 75 e4             	pushl  -0x1c(%ebp)
  801129:	ff 75 e0             	pushl  -0x20(%ebp)
  80112c:	ff 75 dc             	pushl  -0x24(%ebp)
  80112f:	ff 75 d8             	pushl  -0x28(%ebp)
  801132:	e8 29 0a 00 00       	call   801b60 <__udivdi3>
  801137:	83 c4 18             	add    $0x18,%esp
  80113a:	52                   	push   %edx
  80113b:	50                   	push   %eax
  80113c:	89 f2                	mov    %esi,%edx
  80113e:	89 f8                	mov    %edi,%eax
  801140:	e8 9e ff ff ff       	call   8010e3 <printnum>
  801145:	83 c4 20             	add    $0x20,%esp
  801148:	eb 13                	jmp    80115d <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80114a:	83 ec 08             	sub    $0x8,%esp
  80114d:	56                   	push   %esi
  80114e:	ff 75 18             	pushl  0x18(%ebp)
  801151:	ff d7                	call   *%edi
  801153:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801156:	83 eb 01             	sub    $0x1,%ebx
  801159:	85 db                	test   %ebx,%ebx
  80115b:	7f ed                	jg     80114a <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80115d:	83 ec 08             	sub    $0x8,%esp
  801160:	56                   	push   %esi
  801161:	83 ec 04             	sub    $0x4,%esp
  801164:	ff 75 e4             	pushl  -0x1c(%ebp)
  801167:	ff 75 e0             	pushl  -0x20(%ebp)
  80116a:	ff 75 dc             	pushl  -0x24(%ebp)
  80116d:	ff 75 d8             	pushl  -0x28(%ebp)
  801170:	e8 0b 0b 00 00       	call   801c80 <__umoddi3>
  801175:	83 c4 14             	add    $0x14,%esp
  801178:	0f be 80 e7 1e 80 00 	movsbl 0x801ee7(%eax),%eax
  80117f:	50                   	push   %eax
  801180:	ff d7                	call   *%edi
}
  801182:	83 c4 10             	add    $0x10,%esp
  801185:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801188:	5b                   	pop    %ebx
  801189:	5e                   	pop    %esi
  80118a:	5f                   	pop    %edi
  80118b:	5d                   	pop    %ebp
  80118c:	c3                   	ret    
  80118d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801190:	eb c4                	jmp    801156 <printnum+0x73>

00801192 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801192:	55                   	push   %ebp
  801193:	89 e5                	mov    %esp,%ebp
  801195:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801198:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80119c:	8b 10                	mov    (%eax),%edx
  80119e:	3b 50 04             	cmp    0x4(%eax),%edx
  8011a1:	73 0a                	jae    8011ad <sprintputch+0x1b>
		*b->buf++ = ch;
  8011a3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011a6:	89 08                	mov    %ecx,(%eax)
  8011a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ab:	88 02                	mov    %al,(%edx)
}
  8011ad:	5d                   	pop    %ebp
  8011ae:	c3                   	ret    

008011af <printfmt>:
{
  8011af:	55                   	push   %ebp
  8011b0:	89 e5                	mov    %esp,%ebp
  8011b2:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8011b5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011b8:	50                   	push   %eax
  8011b9:	ff 75 10             	pushl  0x10(%ebp)
  8011bc:	ff 75 0c             	pushl  0xc(%ebp)
  8011bf:	ff 75 08             	pushl  0x8(%ebp)
  8011c2:	e8 05 00 00 00       	call   8011cc <vprintfmt>
}
  8011c7:	83 c4 10             	add    $0x10,%esp
  8011ca:	c9                   	leave  
  8011cb:	c3                   	ret    

008011cc <vprintfmt>:
{
  8011cc:	55                   	push   %ebp
  8011cd:	89 e5                	mov    %esp,%ebp
  8011cf:	57                   	push   %edi
  8011d0:	56                   	push   %esi
  8011d1:	53                   	push   %ebx
  8011d2:	83 ec 2c             	sub    $0x2c,%esp
  8011d5:	8b 75 08             	mov    0x8(%ebp),%esi
  8011d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8011db:	8b 7d 10             	mov    0x10(%ebp),%edi
  8011de:	e9 c1 03 00 00       	jmp    8015a4 <vprintfmt+0x3d8>
		padc = ' ';
  8011e3:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8011e7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8011ee:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8011f5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8011fc:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801201:	8d 47 01             	lea    0x1(%edi),%eax
  801204:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801207:	0f b6 17             	movzbl (%edi),%edx
  80120a:	8d 42 dd             	lea    -0x23(%edx),%eax
  80120d:	3c 55                	cmp    $0x55,%al
  80120f:	0f 87 12 04 00 00    	ja     801627 <vprintfmt+0x45b>
  801215:	0f b6 c0             	movzbl %al,%eax
  801218:	ff 24 85 20 20 80 00 	jmp    *0x802020(,%eax,4)
  80121f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801222:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  801226:	eb d9                	jmp    801201 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  801228:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80122b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80122f:	eb d0                	jmp    801201 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  801231:	0f b6 d2             	movzbl %dl,%edx
  801234:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801237:	b8 00 00 00 00       	mov    $0x0,%eax
  80123c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80123f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801242:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801246:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801249:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80124c:	83 f9 09             	cmp    $0x9,%ecx
  80124f:	77 55                	ja     8012a6 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  801251:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801254:	eb e9                	jmp    80123f <vprintfmt+0x73>
			precision = va_arg(ap, int);
  801256:	8b 45 14             	mov    0x14(%ebp),%eax
  801259:	8b 00                	mov    (%eax),%eax
  80125b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80125e:	8b 45 14             	mov    0x14(%ebp),%eax
  801261:	8d 40 04             	lea    0x4(%eax),%eax
  801264:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801267:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80126a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80126e:	79 91                	jns    801201 <vprintfmt+0x35>
				width = precision, precision = -1;
  801270:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801273:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801276:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80127d:	eb 82                	jmp    801201 <vprintfmt+0x35>
  80127f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801282:	85 c0                	test   %eax,%eax
  801284:	ba 00 00 00 00       	mov    $0x0,%edx
  801289:	0f 49 d0             	cmovns %eax,%edx
  80128c:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80128f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801292:	e9 6a ff ff ff       	jmp    801201 <vprintfmt+0x35>
  801297:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80129a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012a1:	e9 5b ff ff ff       	jmp    801201 <vprintfmt+0x35>
  8012a6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8012a9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012ac:	eb bc                	jmp    80126a <vprintfmt+0x9e>
			lflag++;
  8012ae:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8012b4:	e9 48 ff ff ff       	jmp    801201 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8012b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8012bc:	8d 78 04             	lea    0x4(%eax),%edi
  8012bf:	83 ec 08             	sub    $0x8,%esp
  8012c2:	53                   	push   %ebx
  8012c3:	ff 30                	pushl  (%eax)
  8012c5:	ff d6                	call   *%esi
			break;
  8012c7:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8012ca:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8012cd:	e9 cf 02 00 00       	jmp    8015a1 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8012d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8012d5:	8d 78 04             	lea    0x4(%eax),%edi
  8012d8:	8b 00                	mov    (%eax),%eax
  8012da:	99                   	cltd   
  8012db:	31 d0                	xor    %edx,%eax
  8012dd:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8012df:	83 f8 0f             	cmp    $0xf,%eax
  8012e2:	7f 23                	jg     801307 <vprintfmt+0x13b>
  8012e4:	8b 14 85 80 21 80 00 	mov    0x802180(,%eax,4),%edx
  8012eb:	85 d2                	test   %edx,%edx
  8012ed:	74 18                	je     801307 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8012ef:	52                   	push   %edx
  8012f0:	68 7d 1e 80 00       	push   $0x801e7d
  8012f5:	53                   	push   %ebx
  8012f6:	56                   	push   %esi
  8012f7:	e8 b3 fe ff ff       	call   8011af <printfmt>
  8012fc:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8012ff:	89 7d 14             	mov    %edi,0x14(%ebp)
  801302:	e9 9a 02 00 00       	jmp    8015a1 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  801307:	50                   	push   %eax
  801308:	68 ff 1e 80 00       	push   $0x801eff
  80130d:	53                   	push   %ebx
  80130e:	56                   	push   %esi
  80130f:	e8 9b fe ff ff       	call   8011af <printfmt>
  801314:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801317:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80131a:	e9 82 02 00 00       	jmp    8015a1 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  80131f:	8b 45 14             	mov    0x14(%ebp),%eax
  801322:	83 c0 04             	add    $0x4,%eax
  801325:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801328:	8b 45 14             	mov    0x14(%ebp),%eax
  80132b:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80132d:	85 ff                	test   %edi,%edi
  80132f:	b8 f8 1e 80 00       	mov    $0x801ef8,%eax
  801334:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801337:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80133b:	0f 8e bd 00 00 00    	jle    8013fe <vprintfmt+0x232>
  801341:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801345:	75 0e                	jne    801355 <vprintfmt+0x189>
  801347:	89 75 08             	mov    %esi,0x8(%ebp)
  80134a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80134d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801350:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801353:	eb 6d                	jmp    8013c2 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  801355:	83 ec 08             	sub    $0x8,%esp
  801358:	ff 75 d0             	pushl  -0x30(%ebp)
  80135b:	57                   	push   %edi
  80135c:	e8 6e 03 00 00       	call   8016cf <strnlen>
  801361:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801364:	29 c1                	sub    %eax,%ecx
  801366:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  801369:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80136c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801370:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801373:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801376:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  801378:	eb 0f                	jmp    801389 <vprintfmt+0x1bd>
					putch(padc, putdat);
  80137a:	83 ec 08             	sub    $0x8,%esp
  80137d:	53                   	push   %ebx
  80137e:	ff 75 e0             	pushl  -0x20(%ebp)
  801381:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  801383:	83 ef 01             	sub    $0x1,%edi
  801386:	83 c4 10             	add    $0x10,%esp
  801389:	85 ff                	test   %edi,%edi
  80138b:	7f ed                	jg     80137a <vprintfmt+0x1ae>
  80138d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801390:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  801393:	85 c9                	test   %ecx,%ecx
  801395:	b8 00 00 00 00       	mov    $0x0,%eax
  80139a:	0f 49 c1             	cmovns %ecx,%eax
  80139d:	29 c1                	sub    %eax,%ecx
  80139f:	89 75 08             	mov    %esi,0x8(%ebp)
  8013a2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8013a5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8013a8:	89 cb                	mov    %ecx,%ebx
  8013aa:	eb 16                	jmp    8013c2 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8013ac:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8013b0:	75 31                	jne    8013e3 <vprintfmt+0x217>
					putch(ch, putdat);
  8013b2:	83 ec 08             	sub    $0x8,%esp
  8013b5:	ff 75 0c             	pushl  0xc(%ebp)
  8013b8:	50                   	push   %eax
  8013b9:	ff 55 08             	call   *0x8(%ebp)
  8013bc:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8013bf:	83 eb 01             	sub    $0x1,%ebx
  8013c2:	83 c7 01             	add    $0x1,%edi
  8013c5:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8013c9:	0f be c2             	movsbl %dl,%eax
  8013cc:	85 c0                	test   %eax,%eax
  8013ce:	74 59                	je     801429 <vprintfmt+0x25d>
  8013d0:	85 f6                	test   %esi,%esi
  8013d2:	78 d8                	js     8013ac <vprintfmt+0x1e0>
  8013d4:	83 ee 01             	sub    $0x1,%esi
  8013d7:	79 d3                	jns    8013ac <vprintfmt+0x1e0>
  8013d9:	89 df                	mov    %ebx,%edi
  8013db:	8b 75 08             	mov    0x8(%ebp),%esi
  8013de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8013e1:	eb 37                	jmp    80141a <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8013e3:	0f be d2             	movsbl %dl,%edx
  8013e6:	83 ea 20             	sub    $0x20,%edx
  8013e9:	83 fa 5e             	cmp    $0x5e,%edx
  8013ec:	76 c4                	jbe    8013b2 <vprintfmt+0x1e6>
					putch('?', putdat);
  8013ee:	83 ec 08             	sub    $0x8,%esp
  8013f1:	ff 75 0c             	pushl  0xc(%ebp)
  8013f4:	6a 3f                	push   $0x3f
  8013f6:	ff 55 08             	call   *0x8(%ebp)
  8013f9:	83 c4 10             	add    $0x10,%esp
  8013fc:	eb c1                	jmp    8013bf <vprintfmt+0x1f3>
  8013fe:	89 75 08             	mov    %esi,0x8(%ebp)
  801401:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801404:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801407:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80140a:	eb b6                	jmp    8013c2 <vprintfmt+0x1f6>
				putch(' ', putdat);
  80140c:	83 ec 08             	sub    $0x8,%esp
  80140f:	53                   	push   %ebx
  801410:	6a 20                	push   $0x20
  801412:	ff d6                	call   *%esi
			for (; width > 0; width--)
  801414:	83 ef 01             	sub    $0x1,%edi
  801417:	83 c4 10             	add    $0x10,%esp
  80141a:	85 ff                	test   %edi,%edi
  80141c:	7f ee                	jg     80140c <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  80141e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801421:	89 45 14             	mov    %eax,0x14(%ebp)
  801424:	e9 78 01 00 00       	jmp    8015a1 <vprintfmt+0x3d5>
  801429:	89 df                	mov    %ebx,%edi
  80142b:	8b 75 08             	mov    0x8(%ebp),%esi
  80142e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801431:	eb e7                	jmp    80141a <vprintfmt+0x24e>
	if (lflag >= 2)
  801433:	83 f9 01             	cmp    $0x1,%ecx
  801436:	7e 3f                	jle    801477 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  801438:	8b 45 14             	mov    0x14(%ebp),%eax
  80143b:	8b 50 04             	mov    0x4(%eax),%edx
  80143e:	8b 00                	mov    (%eax),%eax
  801440:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801443:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801446:	8b 45 14             	mov    0x14(%ebp),%eax
  801449:	8d 40 08             	lea    0x8(%eax),%eax
  80144c:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80144f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801453:	79 5c                	jns    8014b1 <vprintfmt+0x2e5>
				putch('-', putdat);
  801455:	83 ec 08             	sub    $0x8,%esp
  801458:	53                   	push   %ebx
  801459:	6a 2d                	push   $0x2d
  80145b:	ff d6                	call   *%esi
				num = -(long long) num;
  80145d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801460:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801463:	f7 da                	neg    %edx
  801465:	83 d1 00             	adc    $0x0,%ecx
  801468:	f7 d9                	neg    %ecx
  80146a:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80146d:	b8 0a 00 00 00       	mov    $0xa,%eax
  801472:	e9 10 01 00 00       	jmp    801587 <vprintfmt+0x3bb>
	else if (lflag)
  801477:	85 c9                	test   %ecx,%ecx
  801479:	75 1b                	jne    801496 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  80147b:	8b 45 14             	mov    0x14(%ebp),%eax
  80147e:	8b 00                	mov    (%eax),%eax
  801480:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801483:	89 c1                	mov    %eax,%ecx
  801485:	c1 f9 1f             	sar    $0x1f,%ecx
  801488:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80148b:	8b 45 14             	mov    0x14(%ebp),%eax
  80148e:	8d 40 04             	lea    0x4(%eax),%eax
  801491:	89 45 14             	mov    %eax,0x14(%ebp)
  801494:	eb b9                	jmp    80144f <vprintfmt+0x283>
		return va_arg(*ap, long);
  801496:	8b 45 14             	mov    0x14(%ebp),%eax
  801499:	8b 00                	mov    (%eax),%eax
  80149b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80149e:	89 c1                	mov    %eax,%ecx
  8014a0:	c1 f9 1f             	sar    $0x1f,%ecx
  8014a3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8014a9:	8d 40 04             	lea    0x4(%eax),%eax
  8014ac:	89 45 14             	mov    %eax,0x14(%ebp)
  8014af:	eb 9e                	jmp    80144f <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8014b1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014b4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8014b7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014bc:	e9 c6 00 00 00       	jmp    801587 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8014c1:	83 f9 01             	cmp    $0x1,%ecx
  8014c4:	7e 18                	jle    8014de <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8014c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8014c9:	8b 10                	mov    (%eax),%edx
  8014cb:	8b 48 04             	mov    0x4(%eax),%ecx
  8014ce:	8d 40 08             	lea    0x8(%eax),%eax
  8014d1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8014d4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014d9:	e9 a9 00 00 00       	jmp    801587 <vprintfmt+0x3bb>
	else if (lflag)
  8014de:	85 c9                	test   %ecx,%ecx
  8014e0:	75 1a                	jne    8014fc <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  8014e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e5:	8b 10                	mov    (%eax),%edx
  8014e7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014ec:	8d 40 04             	lea    0x4(%eax),%eax
  8014ef:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8014f2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014f7:	e9 8b 00 00 00       	jmp    801587 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8014fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ff:	8b 10                	mov    (%eax),%edx
  801501:	b9 00 00 00 00       	mov    $0x0,%ecx
  801506:	8d 40 04             	lea    0x4(%eax),%eax
  801509:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80150c:	b8 0a 00 00 00       	mov    $0xa,%eax
  801511:	eb 74                	jmp    801587 <vprintfmt+0x3bb>
	if (lflag >= 2)
  801513:	83 f9 01             	cmp    $0x1,%ecx
  801516:	7e 15                	jle    80152d <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  801518:	8b 45 14             	mov    0x14(%ebp),%eax
  80151b:	8b 10                	mov    (%eax),%edx
  80151d:	8b 48 04             	mov    0x4(%eax),%ecx
  801520:	8d 40 08             	lea    0x8(%eax),%eax
  801523:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801526:	b8 08 00 00 00       	mov    $0x8,%eax
  80152b:	eb 5a                	jmp    801587 <vprintfmt+0x3bb>
	else if (lflag)
  80152d:	85 c9                	test   %ecx,%ecx
  80152f:	75 17                	jne    801548 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  801531:	8b 45 14             	mov    0x14(%ebp),%eax
  801534:	8b 10                	mov    (%eax),%edx
  801536:	b9 00 00 00 00       	mov    $0x0,%ecx
  80153b:	8d 40 04             	lea    0x4(%eax),%eax
  80153e:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801541:	b8 08 00 00 00       	mov    $0x8,%eax
  801546:	eb 3f                	jmp    801587 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  801548:	8b 45 14             	mov    0x14(%ebp),%eax
  80154b:	8b 10                	mov    (%eax),%edx
  80154d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801552:	8d 40 04             	lea    0x4(%eax),%eax
  801555:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801558:	b8 08 00 00 00       	mov    $0x8,%eax
  80155d:	eb 28                	jmp    801587 <vprintfmt+0x3bb>
			putch('0', putdat);
  80155f:	83 ec 08             	sub    $0x8,%esp
  801562:	53                   	push   %ebx
  801563:	6a 30                	push   $0x30
  801565:	ff d6                	call   *%esi
			putch('x', putdat);
  801567:	83 c4 08             	add    $0x8,%esp
  80156a:	53                   	push   %ebx
  80156b:	6a 78                	push   $0x78
  80156d:	ff d6                	call   *%esi
			num = (unsigned long long)
  80156f:	8b 45 14             	mov    0x14(%ebp),%eax
  801572:	8b 10                	mov    (%eax),%edx
  801574:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801579:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80157c:	8d 40 04             	lea    0x4(%eax),%eax
  80157f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801582:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  801587:	83 ec 0c             	sub    $0xc,%esp
  80158a:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80158e:	57                   	push   %edi
  80158f:	ff 75 e0             	pushl  -0x20(%ebp)
  801592:	50                   	push   %eax
  801593:	51                   	push   %ecx
  801594:	52                   	push   %edx
  801595:	89 da                	mov    %ebx,%edx
  801597:	89 f0                	mov    %esi,%eax
  801599:	e8 45 fb ff ff       	call   8010e3 <printnum>
			break;
  80159e:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8015a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8015a4:	83 c7 01             	add    $0x1,%edi
  8015a7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8015ab:	83 f8 25             	cmp    $0x25,%eax
  8015ae:	0f 84 2f fc ff ff    	je     8011e3 <vprintfmt+0x17>
			if (ch == '\0')
  8015b4:	85 c0                	test   %eax,%eax
  8015b6:	0f 84 8b 00 00 00    	je     801647 <vprintfmt+0x47b>
			putch(ch, putdat);
  8015bc:	83 ec 08             	sub    $0x8,%esp
  8015bf:	53                   	push   %ebx
  8015c0:	50                   	push   %eax
  8015c1:	ff d6                	call   *%esi
  8015c3:	83 c4 10             	add    $0x10,%esp
  8015c6:	eb dc                	jmp    8015a4 <vprintfmt+0x3d8>
	if (lflag >= 2)
  8015c8:	83 f9 01             	cmp    $0x1,%ecx
  8015cb:	7e 15                	jle    8015e2 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  8015cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8015d0:	8b 10                	mov    (%eax),%edx
  8015d2:	8b 48 04             	mov    0x4(%eax),%ecx
  8015d5:	8d 40 08             	lea    0x8(%eax),%eax
  8015d8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015db:	b8 10 00 00 00       	mov    $0x10,%eax
  8015e0:	eb a5                	jmp    801587 <vprintfmt+0x3bb>
	else if (lflag)
  8015e2:	85 c9                	test   %ecx,%ecx
  8015e4:	75 17                	jne    8015fd <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  8015e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8015e9:	8b 10                	mov    (%eax),%edx
  8015eb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015f0:	8d 40 04             	lea    0x4(%eax),%eax
  8015f3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015f6:	b8 10 00 00 00       	mov    $0x10,%eax
  8015fb:	eb 8a                	jmp    801587 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8015fd:	8b 45 14             	mov    0x14(%ebp),%eax
  801600:	8b 10                	mov    (%eax),%edx
  801602:	b9 00 00 00 00       	mov    $0x0,%ecx
  801607:	8d 40 04             	lea    0x4(%eax),%eax
  80160a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80160d:	b8 10 00 00 00       	mov    $0x10,%eax
  801612:	e9 70 ff ff ff       	jmp    801587 <vprintfmt+0x3bb>
			putch(ch, putdat);
  801617:	83 ec 08             	sub    $0x8,%esp
  80161a:	53                   	push   %ebx
  80161b:	6a 25                	push   $0x25
  80161d:	ff d6                	call   *%esi
			break;
  80161f:	83 c4 10             	add    $0x10,%esp
  801622:	e9 7a ff ff ff       	jmp    8015a1 <vprintfmt+0x3d5>
			putch('%', putdat);
  801627:	83 ec 08             	sub    $0x8,%esp
  80162a:	53                   	push   %ebx
  80162b:	6a 25                	push   $0x25
  80162d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80162f:	83 c4 10             	add    $0x10,%esp
  801632:	89 f8                	mov    %edi,%eax
  801634:	eb 03                	jmp    801639 <vprintfmt+0x46d>
  801636:	83 e8 01             	sub    $0x1,%eax
  801639:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80163d:	75 f7                	jne    801636 <vprintfmt+0x46a>
  80163f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801642:	e9 5a ff ff ff       	jmp    8015a1 <vprintfmt+0x3d5>
}
  801647:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80164a:	5b                   	pop    %ebx
  80164b:	5e                   	pop    %esi
  80164c:	5f                   	pop    %edi
  80164d:	5d                   	pop    %ebp
  80164e:	c3                   	ret    

0080164f <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80164f:	55                   	push   %ebp
  801650:	89 e5                	mov    %esp,%ebp
  801652:	83 ec 18             	sub    $0x18,%esp
  801655:	8b 45 08             	mov    0x8(%ebp),%eax
  801658:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80165b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80165e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801662:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801665:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80166c:	85 c0                	test   %eax,%eax
  80166e:	74 26                	je     801696 <vsnprintf+0x47>
  801670:	85 d2                	test   %edx,%edx
  801672:	7e 22                	jle    801696 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801674:	ff 75 14             	pushl  0x14(%ebp)
  801677:	ff 75 10             	pushl  0x10(%ebp)
  80167a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80167d:	50                   	push   %eax
  80167e:	68 92 11 80 00       	push   $0x801192
  801683:	e8 44 fb ff ff       	call   8011cc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801688:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80168b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80168e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801691:	83 c4 10             	add    $0x10,%esp
}
  801694:	c9                   	leave  
  801695:	c3                   	ret    
		return -E_INVAL;
  801696:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80169b:	eb f7                	jmp    801694 <vsnprintf+0x45>

0080169d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80169d:	55                   	push   %ebp
  80169e:	89 e5                	mov    %esp,%ebp
  8016a0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016a3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016a6:	50                   	push   %eax
  8016a7:	ff 75 10             	pushl  0x10(%ebp)
  8016aa:	ff 75 0c             	pushl  0xc(%ebp)
  8016ad:	ff 75 08             	pushl  0x8(%ebp)
  8016b0:	e8 9a ff ff ff       	call   80164f <vsnprintf>
	va_end(ap);

	return rc;
}
  8016b5:	c9                   	leave  
  8016b6:	c3                   	ret    

008016b7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016b7:	55                   	push   %ebp
  8016b8:	89 e5                	mov    %esp,%ebp
  8016ba:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8016c2:	eb 03                	jmp    8016c7 <strlen+0x10>
		n++;
  8016c4:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8016c7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016cb:	75 f7                	jne    8016c4 <strlen+0xd>
	return n;
}
  8016cd:	5d                   	pop    %ebp
  8016ce:	c3                   	ret    

008016cf <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016cf:	55                   	push   %ebp
  8016d0:	89 e5                	mov    %esp,%ebp
  8016d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016d5:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8016dd:	eb 03                	jmp    8016e2 <strnlen+0x13>
		n++;
  8016df:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016e2:	39 d0                	cmp    %edx,%eax
  8016e4:	74 06                	je     8016ec <strnlen+0x1d>
  8016e6:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8016ea:	75 f3                	jne    8016df <strnlen+0x10>
	return n;
}
  8016ec:	5d                   	pop    %ebp
  8016ed:	c3                   	ret    

008016ee <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016ee:	55                   	push   %ebp
  8016ef:	89 e5                	mov    %esp,%ebp
  8016f1:	53                   	push   %ebx
  8016f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016f8:	89 c2                	mov    %eax,%edx
  8016fa:	83 c1 01             	add    $0x1,%ecx
  8016fd:	83 c2 01             	add    $0x1,%edx
  801700:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801704:	88 5a ff             	mov    %bl,-0x1(%edx)
  801707:	84 db                	test   %bl,%bl
  801709:	75 ef                	jne    8016fa <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80170b:	5b                   	pop    %ebx
  80170c:	5d                   	pop    %ebp
  80170d:	c3                   	ret    

0080170e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80170e:	55                   	push   %ebp
  80170f:	89 e5                	mov    %esp,%ebp
  801711:	53                   	push   %ebx
  801712:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801715:	53                   	push   %ebx
  801716:	e8 9c ff ff ff       	call   8016b7 <strlen>
  80171b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80171e:	ff 75 0c             	pushl  0xc(%ebp)
  801721:	01 d8                	add    %ebx,%eax
  801723:	50                   	push   %eax
  801724:	e8 c5 ff ff ff       	call   8016ee <strcpy>
	return dst;
}
  801729:	89 d8                	mov    %ebx,%eax
  80172b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80172e:	c9                   	leave  
  80172f:	c3                   	ret    

00801730 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801730:	55                   	push   %ebp
  801731:	89 e5                	mov    %esp,%ebp
  801733:	56                   	push   %esi
  801734:	53                   	push   %ebx
  801735:	8b 75 08             	mov    0x8(%ebp),%esi
  801738:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80173b:	89 f3                	mov    %esi,%ebx
  80173d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801740:	89 f2                	mov    %esi,%edx
  801742:	eb 0f                	jmp    801753 <strncpy+0x23>
		*dst++ = *src;
  801744:	83 c2 01             	add    $0x1,%edx
  801747:	0f b6 01             	movzbl (%ecx),%eax
  80174a:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80174d:	80 39 01             	cmpb   $0x1,(%ecx)
  801750:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  801753:	39 da                	cmp    %ebx,%edx
  801755:	75 ed                	jne    801744 <strncpy+0x14>
	}
	return ret;
}
  801757:	89 f0                	mov    %esi,%eax
  801759:	5b                   	pop    %ebx
  80175a:	5e                   	pop    %esi
  80175b:	5d                   	pop    %ebp
  80175c:	c3                   	ret    

0080175d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80175d:	55                   	push   %ebp
  80175e:	89 e5                	mov    %esp,%ebp
  801760:	56                   	push   %esi
  801761:	53                   	push   %ebx
  801762:	8b 75 08             	mov    0x8(%ebp),%esi
  801765:	8b 55 0c             	mov    0xc(%ebp),%edx
  801768:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80176b:	89 f0                	mov    %esi,%eax
  80176d:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801771:	85 c9                	test   %ecx,%ecx
  801773:	75 0b                	jne    801780 <strlcpy+0x23>
  801775:	eb 17                	jmp    80178e <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801777:	83 c2 01             	add    $0x1,%edx
  80177a:	83 c0 01             	add    $0x1,%eax
  80177d:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  801780:	39 d8                	cmp    %ebx,%eax
  801782:	74 07                	je     80178b <strlcpy+0x2e>
  801784:	0f b6 0a             	movzbl (%edx),%ecx
  801787:	84 c9                	test   %cl,%cl
  801789:	75 ec                	jne    801777 <strlcpy+0x1a>
		*dst = '\0';
  80178b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80178e:	29 f0                	sub    %esi,%eax
}
  801790:	5b                   	pop    %ebx
  801791:	5e                   	pop    %esi
  801792:	5d                   	pop    %ebp
  801793:	c3                   	ret    

00801794 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801794:	55                   	push   %ebp
  801795:	89 e5                	mov    %esp,%ebp
  801797:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80179a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80179d:	eb 06                	jmp    8017a5 <strcmp+0x11>
		p++, q++;
  80179f:	83 c1 01             	add    $0x1,%ecx
  8017a2:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8017a5:	0f b6 01             	movzbl (%ecx),%eax
  8017a8:	84 c0                	test   %al,%al
  8017aa:	74 04                	je     8017b0 <strcmp+0x1c>
  8017ac:	3a 02                	cmp    (%edx),%al
  8017ae:	74 ef                	je     80179f <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017b0:	0f b6 c0             	movzbl %al,%eax
  8017b3:	0f b6 12             	movzbl (%edx),%edx
  8017b6:	29 d0                	sub    %edx,%eax
}
  8017b8:	5d                   	pop    %ebp
  8017b9:	c3                   	ret    

008017ba <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017ba:	55                   	push   %ebp
  8017bb:	89 e5                	mov    %esp,%ebp
  8017bd:	53                   	push   %ebx
  8017be:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017c4:	89 c3                	mov    %eax,%ebx
  8017c6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017c9:	eb 06                	jmp    8017d1 <strncmp+0x17>
		n--, p++, q++;
  8017cb:	83 c0 01             	add    $0x1,%eax
  8017ce:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8017d1:	39 d8                	cmp    %ebx,%eax
  8017d3:	74 16                	je     8017eb <strncmp+0x31>
  8017d5:	0f b6 08             	movzbl (%eax),%ecx
  8017d8:	84 c9                	test   %cl,%cl
  8017da:	74 04                	je     8017e0 <strncmp+0x26>
  8017dc:	3a 0a                	cmp    (%edx),%cl
  8017de:	74 eb                	je     8017cb <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017e0:	0f b6 00             	movzbl (%eax),%eax
  8017e3:	0f b6 12             	movzbl (%edx),%edx
  8017e6:	29 d0                	sub    %edx,%eax
}
  8017e8:	5b                   	pop    %ebx
  8017e9:	5d                   	pop    %ebp
  8017ea:	c3                   	ret    
		return 0;
  8017eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8017f0:	eb f6                	jmp    8017e8 <strncmp+0x2e>

008017f2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017f2:	55                   	push   %ebp
  8017f3:	89 e5                	mov    %esp,%ebp
  8017f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017fc:	0f b6 10             	movzbl (%eax),%edx
  8017ff:	84 d2                	test   %dl,%dl
  801801:	74 09                	je     80180c <strchr+0x1a>
		if (*s == c)
  801803:	38 ca                	cmp    %cl,%dl
  801805:	74 0a                	je     801811 <strchr+0x1f>
	for (; *s; s++)
  801807:	83 c0 01             	add    $0x1,%eax
  80180a:	eb f0                	jmp    8017fc <strchr+0xa>
			return (char *) s;
	return 0;
  80180c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801811:	5d                   	pop    %ebp
  801812:	c3                   	ret    

00801813 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801813:	55                   	push   %ebp
  801814:	89 e5                	mov    %esp,%ebp
  801816:	8b 45 08             	mov    0x8(%ebp),%eax
  801819:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80181d:	eb 03                	jmp    801822 <strfind+0xf>
  80181f:	83 c0 01             	add    $0x1,%eax
  801822:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801825:	38 ca                	cmp    %cl,%dl
  801827:	74 04                	je     80182d <strfind+0x1a>
  801829:	84 d2                	test   %dl,%dl
  80182b:	75 f2                	jne    80181f <strfind+0xc>
			break;
	return (char *) s;
}
  80182d:	5d                   	pop    %ebp
  80182e:	c3                   	ret    

0080182f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80182f:	55                   	push   %ebp
  801830:	89 e5                	mov    %esp,%ebp
  801832:	57                   	push   %edi
  801833:	56                   	push   %esi
  801834:	53                   	push   %ebx
  801835:	8b 7d 08             	mov    0x8(%ebp),%edi
  801838:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80183b:	85 c9                	test   %ecx,%ecx
  80183d:	74 13                	je     801852 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80183f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801845:	75 05                	jne    80184c <memset+0x1d>
  801847:	f6 c1 03             	test   $0x3,%cl
  80184a:	74 0d                	je     801859 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80184c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80184f:	fc                   	cld    
  801850:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801852:	89 f8                	mov    %edi,%eax
  801854:	5b                   	pop    %ebx
  801855:	5e                   	pop    %esi
  801856:	5f                   	pop    %edi
  801857:	5d                   	pop    %ebp
  801858:	c3                   	ret    
		c &= 0xFF;
  801859:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80185d:	89 d3                	mov    %edx,%ebx
  80185f:	c1 e3 08             	shl    $0x8,%ebx
  801862:	89 d0                	mov    %edx,%eax
  801864:	c1 e0 18             	shl    $0x18,%eax
  801867:	89 d6                	mov    %edx,%esi
  801869:	c1 e6 10             	shl    $0x10,%esi
  80186c:	09 f0                	or     %esi,%eax
  80186e:	09 c2                	or     %eax,%edx
  801870:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  801872:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801875:	89 d0                	mov    %edx,%eax
  801877:	fc                   	cld    
  801878:	f3 ab                	rep stos %eax,%es:(%edi)
  80187a:	eb d6                	jmp    801852 <memset+0x23>

0080187c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80187c:	55                   	push   %ebp
  80187d:	89 e5                	mov    %esp,%ebp
  80187f:	57                   	push   %edi
  801880:	56                   	push   %esi
  801881:	8b 45 08             	mov    0x8(%ebp),%eax
  801884:	8b 75 0c             	mov    0xc(%ebp),%esi
  801887:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80188a:	39 c6                	cmp    %eax,%esi
  80188c:	73 35                	jae    8018c3 <memmove+0x47>
  80188e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801891:	39 c2                	cmp    %eax,%edx
  801893:	76 2e                	jbe    8018c3 <memmove+0x47>
		s += n;
		d += n;
  801895:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801898:	89 d6                	mov    %edx,%esi
  80189a:	09 fe                	or     %edi,%esi
  80189c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018a2:	74 0c                	je     8018b0 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8018a4:	83 ef 01             	sub    $0x1,%edi
  8018a7:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8018aa:	fd                   	std    
  8018ab:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018ad:	fc                   	cld    
  8018ae:	eb 21                	jmp    8018d1 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018b0:	f6 c1 03             	test   $0x3,%cl
  8018b3:	75 ef                	jne    8018a4 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8018b5:	83 ef 04             	sub    $0x4,%edi
  8018b8:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018bb:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8018be:	fd                   	std    
  8018bf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018c1:	eb ea                	jmp    8018ad <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018c3:	89 f2                	mov    %esi,%edx
  8018c5:	09 c2                	or     %eax,%edx
  8018c7:	f6 c2 03             	test   $0x3,%dl
  8018ca:	74 09                	je     8018d5 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018cc:	89 c7                	mov    %eax,%edi
  8018ce:	fc                   	cld    
  8018cf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018d1:	5e                   	pop    %esi
  8018d2:	5f                   	pop    %edi
  8018d3:	5d                   	pop    %ebp
  8018d4:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018d5:	f6 c1 03             	test   $0x3,%cl
  8018d8:	75 f2                	jne    8018cc <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8018da:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8018dd:	89 c7                	mov    %eax,%edi
  8018df:	fc                   	cld    
  8018e0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018e2:	eb ed                	jmp    8018d1 <memmove+0x55>

008018e4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018e4:	55                   	push   %ebp
  8018e5:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018e7:	ff 75 10             	pushl  0x10(%ebp)
  8018ea:	ff 75 0c             	pushl  0xc(%ebp)
  8018ed:	ff 75 08             	pushl  0x8(%ebp)
  8018f0:	e8 87 ff ff ff       	call   80187c <memmove>
}
  8018f5:	c9                   	leave  
  8018f6:	c3                   	ret    

008018f7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018f7:	55                   	push   %ebp
  8018f8:	89 e5                	mov    %esp,%ebp
  8018fa:	56                   	push   %esi
  8018fb:	53                   	push   %ebx
  8018fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  801902:	89 c6                	mov    %eax,%esi
  801904:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801907:	39 f0                	cmp    %esi,%eax
  801909:	74 1c                	je     801927 <memcmp+0x30>
		if (*s1 != *s2)
  80190b:	0f b6 08             	movzbl (%eax),%ecx
  80190e:	0f b6 1a             	movzbl (%edx),%ebx
  801911:	38 d9                	cmp    %bl,%cl
  801913:	75 08                	jne    80191d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801915:	83 c0 01             	add    $0x1,%eax
  801918:	83 c2 01             	add    $0x1,%edx
  80191b:	eb ea                	jmp    801907 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  80191d:	0f b6 c1             	movzbl %cl,%eax
  801920:	0f b6 db             	movzbl %bl,%ebx
  801923:	29 d8                	sub    %ebx,%eax
  801925:	eb 05                	jmp    80192c <memcmp+0x35>
	}

	return 0;
  801927:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80192c:	5b                   	pop    %ebx
  80192d:	5e                   	pop    %esi
  80192e:	5d                   	pop    %ebp
  80192f:	c3                   	ret    

00801930 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801930:	55                   	push   %ebp
  801931:	89 e5                	mov    %esp,%ebp
  801933:	8b 45 08             	mov    0x8(%ebp),%eax
  801936:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801939:	89 c2                	mov    %eax,%edx
  80193b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80193e:	39 d0                	cmp    %edx,%eax
  801940:	73 09                	jae    80194b <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  801942:	38 08                	cmp    %cl,(%eax)
  801944:	74 05                	je     80194b <memfind+0x1b>
	for (; s < ends; s++)
  801946:	83 c0 01             	add    $0x1,%eax
  801949:	eb f3                	jmp    80193e <memfind+0xe>
			break;
	return (void *) s;
}
  80194b:	5d                   	pop    %ebp
  80194c:	c3                   	ret    

0080194d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80194d:	55                   	push   %ebp
  80194e:	89 e5                	mov    %esp,%ebp
  801950:	57                   	push   %edi
  801951:	56                   	push   %esi
  801952:	53                   	push   %ebx
  801953:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801956:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801959:	eb 03                	jmp    80195e <strtol+0x11>
		s++;
  80195b:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  80195e:	0f b6 01             	movzbl (%ecx),%eax
  801961:	3c 20                	cmp    $0x20,%al
  801963:	74 f6                	je     80195b <strtol+0xe>
  801965:	3c 09                	cmp    $0x9,%al
  801967:	74 f2                	je     80195b <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  801969:	3c 2b                	cmp    $0x2b,%al
  80196b:	74 2e                	je     80199b <strtol+0x4e>
	int neg = 0;
  80196d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801972:	3c 2d                	cmp    $0x2d,%al
  801974:	74 2f                	je     8019a5 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801976:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80197c:	75 05                	jne    801983 <strtol+0x36>
  80197e:	80 39 30             	cmpb   $0x30,(%ecx)
  801981:	74 2c                	je     8019af <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801983:	85 db                	test   %ebx,%ebx
  801985:	75 0a                	jne    801991 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801987:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  80198c:	80 39 30             	cmpb   $0x30,(%ecx)
  80198f:	74 28                	je     8019b9 <strtol+0x6c>
		base = 10;
  801991:	b8 00 00 00 00       	mov    $0x0,%eax
  801996:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801999:	eb 50                	jmp    8019eb <strtol+0x9e>
		s++;
  80199b:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  80199e:	bf 00 00 00 00       	mov    $0x0,%edi
  8019a3:	eb d1                	jmp    801976 <strtol+0x29>
		s++, neg = 1;
  8019a5:	83 c1 01             	add    $0x1,%ecx
  8019a8:	bf 01 00 00 00       	mov    $0x1,%edi
  8019ad:	eb c7                	jmp    801976 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019af:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019b3:	74 0e                	je     8019c3 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8019b5:	85 db                	test   %ebx,%ebx
  8019b7:	75 d8                	jne    801991 <strtol+0x44>
		s++, base = 8;
  8019b9:	83 c1 01             	add    $0x1,%ecx
  8019bc:	bb 08 00 00 00       	mov    $0x8,%ebx
  8019c1:	eb ce                	jmp    801991 <strtol+0x44>
		s += 2, base = 16;
  8019c3:	83 c1 02             	add    $0x2,%ecx
  8019c6:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019cb:	eb c4                	jmp    801991 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  8019cd:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019d0:	89 f3                	mov    %esi,%ebx
  8019d2:	80 fb 19             	cmp    $0x19,%bl
  8019d5:	77 29                	ja     801a00 <strtol+0xb3>
			dig = *s - 'a' + 10;
  8019d7:	0f be d2             	movsbl %dl,%edx
  8019da:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8019dd:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019e0:	7d 30                	jge    801a12 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  8019e2:	83 c1 01             	add    $0x1,%ecx
  8019e5:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019e9:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  8019eb:	0f b6 11             	movzbl (%ecx),%edx
  8019ee:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019f1:	89 f3                	mov    %esi,%ebx
  8019f3:	80 fb 09             	cmp    $0x9,%bl
  8019f6:	77 d5                	ja     8019cd <strtol+0x80>
			dig = *s - '0';
  8019f8:	0f be d2             	movsbl %dl,%edx
  8019fb:	83 ea 30             	sub    $0x30,%edx
  8019fe:	eb dd                	jmp    8019dd <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  801a00:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a03:	89 f3                	mov    %esi,%ebx
  801a05:	80 fb 19             	cmp    $0x19,%bl
  801a08:	77 08                	ja     801a12 <strtol+0xc5>
			dig = *s - 'A' + 10;
  801a0a:	0f be d2             	movsbl %dl,%edx
  801a0d:	83 ea 37             	sub    $0x37,%edx
  801a10:	eb cb                	jmp    8019dd <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  801a12:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a16:	74 05                	je     801a1d <strtol+0xd0>
		*endptr = (char *) s;
  801a18:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a1b:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801a1d:	89 c2                	mov    %eax,%edx
  801a1f:	f7 da                	neg    %edx
  801a21:	85 ff                	test   %edi,%edi
  801a23:	0f 45 c2             	cmovne %edx,%eax
}
  801a26:	5b                   	pop    %ebx
  801a27:	5e                   	pop    %esi
  801a28:	5f                   	pop    %edi
  801a29:	5d                   	pop    %ebp
  801a2a:	c3                   	ret    

00801a2b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a2b:	55                   	push   %ebp
  801a2c:	89 e5                	mov    %esp,%ebp
  801a2e:	56                   	push   %esi
  801a2f:	53                   	push   %ebx
  801a30:	8b 75 08             	mov    0x8(%ebp),%esi
  801a33:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a36:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  801a39:	85 f6                	test   %esi,%esi
  801a3b:	74 06                	je     801a43 <ipc_recv+0x18>
  801a3d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801a43:	85 db                	test   %ebx,%ebx
  801a45:	74 06                	je     801a4d <ipc_recv+0x22>
  801a47:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801a4d:	85 c0                	test   %eax,%eax
  801a4f:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801a54:	0f 44 c2             	cmove  %edx,%eax
	int ret = sys_ipc_recv(pg);
  801a57:	83 ec 0c             	sub    $0xc,%esp
  801a5a:	50                   	push   %eax
  801a5b:	e8 a5 e8 ff ff       	call   800305 <sys_ipc_recv>
	if (ret) return ret;
  801a60:	83 c4 10             	add    $0x10,%esp
  801a63:	85 c0                	test   %eax,%eax
  801a65:	75 24                	jne    801a8b <ipc_recv+0x60>
	if (from_env_store)
  801a67:	85 f6                	test   %esi,%esi
  801a69:	74 0a                	je     801a75 <ipc_recv+0x4a>
		*from_env_store = thisenv->env_ipc_from;
  801a6b:	a1 04 40 80 00       	mov    0x804004,%eax
  801a70:	8b 40 74             	mov    0x74(%eax),%eax
  801a73:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801a75:	85 db                	test   %ebx,%ebx
  801a77:	74 0a                	je     801a83 <ipc_recv+0x58>
		*perm_store = thisenv->env_ipc_perm;
  801a79:	a1 04 40 80 00       	mov    0x804004,%eax
  801a7e:	8b 40 78             	mov    0x78(%eax),%eax
  801a81:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801a83:	a1 04 40 80 00       	mov    0x804004,%eax
  801a88:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a8b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a8e:	5b                   	pop    %ebx
  801a8f:	5e                   	pop    %esi
  801a90:	5d                   	pop    %ebp
  801a91:	c3                   	ret    

00801a92 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a92:	55                   	push   %ebp
  801a93:	89 e5                	mov    %esp,%ebp
  801a95:	57                   	push   %edi
  801a96:	56                   	push   %esi
  801a97:	53                   	push   %ebx
  801a98:	83 ec 0c             	sub    $0xc,%esp
  801a9b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a9e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801aa1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  801aa4:	85 db                	test   %ebx,%ebx
  801aa6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801aab:	0f 44 d8             	cmove  %eax,%ebx
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801aae:	ff 75 14             	pushl  0x14(%ebp)
  801ab1:	53                   	push   %ebx
  801ab2:	56                   	push   %esi
  801ab3:	57                   	push   %edi
  801ab4:	e8 29 e8 ff ff       	call   8002e2 <sys_ipc_try_send>
  801ab9:	83 c4 10             	add    $0x10,%esp
  801abc:	85 c0                	test   %eax,%eax
  801abe:	74 1e                	je     801ade <ipc_send+0x4c>
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801ac0:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ac3:	75 07                	jne    801acc <ipc_send+0x3a>
		sys_yield();
  801ac5:	e8 6c e6 ff ff       	call   800136 <sys_yield>
  801aca:	eb e2                	jmp    801aae <ipc_send+0x1c>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801acc:	50                   	push   %eax
  801acd:	68 e0 21 80 00       	push   $0x8021e0
  801ad2:	6a 36                	push   $0x36
  801ad4:	68 f7 21 80 00       	push   $0x8021f7
  801ad9:	e8 16 f5 ff ff       	call   800ff4 <_panic>
	}
}
  801ade:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae1:	5b                   	pop    %ebx
  801ae2:	5e                   	pop    %esi
  801ae3:	5f                   	pop    %edi
  801ae4:	5d                   	pop    %ebp
  801ae5:	c3                   	ret    

00801ae6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ae6:	55                   	push   %ebp
  801ae7:	89 e5                	mov    %esp,%ebp
  801ae9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801aec:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801af1:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801af4:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801afa:	8b 52 50             	mov    0x50(%edx),%edx
  801afd:	39 ca                	cmp    %ecx,%edx
  801aff:	74 11                	je     801b12 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801b01:	83 c0 01             	add    $0x1,%eax
  801b04:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b09:	75 e6                	jne    801af1 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801b0b:	b8 00 00 00 00       	mov    $0x0,%eax
  801b10:	eb 0b                	jmp    801b1d <ipc_find_env+0x37>
			return envs[i].env_id;
  801b12:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b15:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b1a:	8b 40 48             	mov    0x48(%eax),%eax
}
  801b1d:	5d                   	pop    %ebp
  801b1e:	c3                   	ret    

00801b1f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b1f:	55                   	push   %ebp
  801b20:	89 e5                	mov    %esp,%ebp
  801b22:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b25:	89 d0                	mov    %edx,%eax
  801b27:	c1 e8 16             	shr    $0x16,%eax
  801b2a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b31:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801b36:	f6 c1 01             	test   $0x1,%cl
  801b39:	74 1d                	je     801b58 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801b3b:	c1 ea 0c             	shr    $0xc,%edx
  801b3e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b45:	f6 c2 01             	test   $0x1,%dl
  801b48:	74 0e                	je     801b58 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b4a:	c1 ea 0c             	shr    $0xc,%edx
  801b4d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b54:	ef 
  801b55:	0f b7 c0             	movzwl %ax,%eax
}
  801b58:	5d                   	pop    %ebp
  801b59:	c3                   	ret    
  801b5a:	66 90                	xchg   %ax,%ax
  801b5c:	66 90                	xchg   %ax,%ax
  801b5e:	66 90                	xchg   %ax,%ax

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
