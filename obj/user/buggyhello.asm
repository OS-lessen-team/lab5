
obj/user/buggyhello.debug：     文件格式 elf32-i386


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
  80002c:	e8 16 00 00 00       	call   800047 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs((char*)1, 1);
  800039:	6a 01                	push   $0x1
  80003b:	6a 01                	push   $0x1
  80003d:	e8 65 00 00 00       	call   8000a7 <sys_cputs>
}
  800042:	83 c4 10             	add    $0x10,%esp
  800045:	c9                   	leave  
  800046:	c3                   	ret    

00800047 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800047:	55                   	push   %ebp
  800048:	89 e5                	mov    %esp,%ebp
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800052:	e8 ce 00 00 00       	call   800125 <sys_getenvid>
	thisenv = envs + ENVX(envid); 
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800064:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800069:	85 db                	test   %ebx,%ebx
  80006b:	7e 07                	jle    800074 <libmain+0x2d>
		binaryname = argv[0];
  80006d:	8b 06                	mov    (%esi),%eax
  80006f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800074:	83 ec 08             	sub    $0x8,%esp
  800077:	56                   	push   %esi
  800078:	53                   	push   %ebx
  800079:	e8 b5 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007e:	e8 0a 00 00 00       	call   80008d <exit>
}
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800089:	5b                   	pop    %ebx
  80008a:	5e                   	pop    %esi
  80008b:	5d                   	pop    %ebp
  80008c:	c3                   	ret    

0080008d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008d:	55                   	push   %ebp
  80008e:	89 e5                	mov    %esp,%ebp
  800090:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800093:	e8 92 04 00 00       	call   80052a <close_all>
	sys_env_destroy(0);
  800098:	83 ec 0c             	sub    $0xc,%esp
  80009b:	6a 00                	push   $0x0
  80009d:	e8 42 00 00 00       	call   8000e4 <sys_env_destroy>
}
  8000a2:	83 c4 10             	add    $0x10,%esp
  8000a5:	c9                   	leave  
  8000a6:	c3                   	ret    

008000a7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a7:	55                   	push   %ebp
  8000a8:	89 e5                	mov    %esp,%ebp
  8000aa:	57                   	push   %edi
  8000ab:	56                   	push   %esi
  8000ac:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b8:	89 c3                	mov    %eax,%ebx
  8000ba:	89 c7                	mov    %eax,%edi
  8000bc:	89 c6                	mov    %eax,%esi
  8000be:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c0:	5b                   	pop    %ebx
  8000c1:	5e                   	pop    %esi
  8000c2:	5f                   	pop    %edi
  8000c3:	5d                   	pop    %ebp
  8000c4:	c3                   	ret    

008000c5 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c5:	55                   	push   %ebp
  8000c6:	89 e5                	mov    %esp,%ebp
  8000c8:	57                   	push   %edi
  8000c9:	56                   	push   %esi
  8000ca:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d5:	89 d1                	mov    %edx,%ecx
  8000d7:	89 d3                	mov    %edx,%ebx
  8000d9:	89 d7                	mov    %edx,%edi
  8000db:	89 d6                	mov    %edx,%esi
  8000dd:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000df:	5b                   	pop    %ebx
  8000e0:	5e                   	pop    %esi
  8000e1:	5f                   	pop    %edi
  8000e2:	5d                   	pop    %ebp
  8000e3:	c3                   	ret    

008000e4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	57                   	push   %edi
  8000e8:	56                   	push   %esi
  8000e9:	53                   	push   %ebx
  8000ea:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f5:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fa:	89 cb                	mov    %ecx,%ebx
  8000fc:	89 cf                	mov    %ecx,%edi
  8000fe:	89 ce                	mov    %ecx,%esi
  800100:	cd 30                	int    $0x30
	if(check && ret > 0)
  800102:	85 c0                	test   %eax,%eax
  800104:	7f 08                	jg     80010e <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800106:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800109:	5b                   	pop    %ebx
  80010a:	5e                   	pop    %esi
  80010b:	5f                   	pop    %edi
  80010c:	5d                   	pop    %ebp
  80010d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80010e:	83 ec 0c             	sub    $0xc,%esp
  800111:	50                   	push   %eax
  800112:	6a 03                	push   $0x3
  800114:	68 ca 1d 80 00       	push   $0x801dca
  800119:	6a 23                	push   $0x23
  80011b:	68 e7 1d 80 00       	push   $0x801de7
  800120:	e8 dd 0e 00 00       	call   801002 <_panic>

00800125 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	57                   	push   %edi
  800129:	56                   	push   %esi
  80012a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80012b:	ba 00 00 00 00       	mov    $0x0,%edx
  800130:	b8 02 00 00 00       	mov    $0x2,%eax
  800135:	89 d1                	mov    %edx,%ecx
  800137:	89 d3                	mov    %edx,%ebx
  800139:	89 d7                	mov    %edx,%edi
  80013b:	89 d6                	mov    %edx,%esi
  80013d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013f:	5b                   	pop    %ebx
  800140:	5e                   	pop    %esi
  800141:	5f                   	pop    %edi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <sys_yield>:

void
sys_yield(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	57                   	push   %edi
  800148:	56                   	push   %esi
  800149:	53                   	push   %ebx
	asm volatile("int %1\n"
  80014a:	ba 00 00 00 00       	mov    $0x0,%edx
  80014f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800154:	89 d1                	mov    %edx,%ecx
  800156:	89 d3                	mov    %edx,%ebx
  800158:	89 d7                	mov    %edx,%edi
  80015a:	89 d6                	mov    %edx,%esi
  80015c:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80015e:	5b                   	pop    %ebx
  80015f:	5e                   	pop    %esi
  800160:	5f                   	pop    %edi
  800161:	5d                   	pop    %ebp
  800162:	c3                   	ret    

00800163 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	57                   	push   %edi
  800167:	56                   	push   %esi
  800168:	53                   	push   %ebx
  800169:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80016c:	be 00 00 00 00       	mov    $0x0,%esi
  800171:	8b 55 08             	mov    0x8(%ebp),%edx
  800174:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800177:	b8 04 00 00 00       	mov    $0x4,%eax
  80017c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017f:	89 f7                	mov    %esi,%edi
  800181:	cd 30                	int    $0x30
	if(check && ret > 0)
  800183:	85 c0                	test   %eax,%eax
  800185:	7f 08                	jg     80018f <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800187:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80018a:	5b                   	pop    %ebx
  80018b:	5e                   	pop    %esi
  80018c:	5f                   	pop    %edi
  80018d:	5d                   	pop    %ebp
  80018e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80018f:	83 ec 0c             	sub    $0xc,%esp
  800192:	50                   	push   %eax
  800193:	6a 04                	push   $0x4
  800195:	68 ca 1d 80 00       	push   $0x801dca
  80019a:	6a 23                	push   $0x23
  80019c:	68 e7 1d 80 00       	push   $0x801de7
  8001a1:	e8 5c 0e 00 00       	call   801002 <_panic>

008001a6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	57                   	push   %edi
  8001aa:	56                   	push   %esi
  8001ab:	53                   	push   %ebx
  8001ac:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001af:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b5:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001bd:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c0:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c3:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001c5:	85 c0                	test   %eax,%eax
  8001c7:	7f 08                	jg     8001d1 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001cc:	5b                   	pop    %ebx
  8001cd:	5e                   	pop    %esi
  8001ce:	5f                   	pop    %edi
  8001cf:	5d                   	pop    %ebp
  8001d0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d1:	83 ec 0c             	sub    $0xc,%esp
  8001d4:	50                   	push   %eax
  8001d5:	6a 05                	push   $0x5
  8001d7:	68 ca 1d 80 00       	push   $0x801dca
  8001dc:	6a 23                	push   $0x23
  8001de:	68 e7 1d 80 00       	push   $0x801de7
  8001e3:	e8 1a 0e 00 00       	call   801002 <_panic>

008001e8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	57                   	push   %edi
  8001ec:	56                   	push   %esi
  8001ed:	53                   	push   %ebx
  8001ee:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fc:	b8 06 00 00 00       	mov    $0x6,%eax
  800201:	89 df                	mov    %ebx,%edi
  800203:	89 de                	mov    %ebx,%esi
  800205:	cd 30                	int    $0x30
	if(check && ret > 0)
  800207:	85 c0                	test   %eax,%eax
  800209:	7f 08                	jg     800213 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80020b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020e:	5b                   	pop    %ebx
  80020f:	5e                   	pop    %esi
  800210:	5f                   	pop    %edi
  800211:	5d                   	pop    %ebp
  800212:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800213:	83 ec 0c             	sub    $0xc,%esp
  800216:	50                   	push   %eax
  800217:	6a 06                	push   $0x6
  800219:	68 ca 1d 80 00       	push   $0x801dca
  80021e:	6a 23                	push   $0x23
  800220:	68 e7 1d 80 00       	push   $0x801de7
  800225:	e8 d8 0d 00 00       	call   801002 <_panic>

0080022a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	57                   	push   %edi
  80022e:	56                   	push   %esi
  80022f:	53                   	push   %ebx
  800230:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800233:	bb 00 00 00 00       	mov    $0x0,%ebx
  800238:	8b 55 08             	mov    0x8(%ebp),%edx
  80023b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023e:	b8 08 00 00 00       	mov    $0x8,%eax
  800243:	89 df                	mov    %ebx,%edi
  800245:	89 de                	mov    %ebx,%esi
  800247:	cd 30                	int    $0x30
	if(check && ret > 0)
  800249:	85 c0                	test   %eax,%eax
  80024b:	7f 08                	jg     800255 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80024d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800250:	5b                   	pop    %ebx
  800251:	5e                   	pop    %esi
  800252:	5f                   	pop    %edi
  800253:	5d                   	pop    %ebp
  800254:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800255:	83 ec 0c             	sub    $0xc,%esp
  800258:	50                   	push   %eax
  800259:	6a 08                	push   $0x8
  80025b:	68 ca 1d 80 00       	push   $0x801dca
  800260:	6a 23                	push   $0x23
  800262:	68 e7 1d 80 00       	push   $0x801de7
  800267:	e8 96 0d 00 00       	call   801002 <_panic>

0080026c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	57                   	push   %edi
  800270:	56                   	push   %esi
  800271:	53                   	push   %ebx
  800272:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800275:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027a:	8b 55 08             	mov    0x8(%ebp),%edx
  80027d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800280:	b8 09 00 00 00       	mov    $0x9,%eax
  800285:	89 df                	mov    %ebx,%edi
  800287:	89 de                	mov    %ebx,%esi
  800289:	cd 30                	int    $0x30
	if(check && ret > 0)
  80028b:	85 c0                	test   %eax,%eax
  80028d:	7f 08                	jg     800297 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80028f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800292:	5b                   	pop    %ebx
  800293:	5e                   	pop    %esi
  800294:	5f                   	pop    %edi
  800295:	5d                   	pop    %ebp
  800296:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800297:	83 ec 0c             	sub    $0xc,%esp
  80029a:	50                   	push   %eax
  80029b:	6a 09                	push   $0x9
  80029d:	68 ca 1d 80 00       	push   $0x801dca
  8002a2:	6a 23                	push   $0x23
  8002a4:	68 e7 1d 80 00       	push   $0x801de7
  8002a9:	e8 54 0d 00 00       	call   801002 <_panic>

008002ae <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	57                   	push   %edi
  8002b2:	56                   	push   %esi
  8002b3:	53                   	push   %ebx
  8002b4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002b7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8002bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c7:	89 df                	mov    %ebx,%edi
  8002c9:	89 de                	mov    %ebx,%esi
  8002cb:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002cd:	85 c0                	test   %eax,%eax
  8002cf:	7f 08                	jg     8002d9 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d4:	5b                   	pop    %ebx
  8002d5:	5e                   	pop    %esi
  8002d6:	5f                   	pop    %edi
  8002d7:	5d                   	pop    %ebp
  8002d8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d9:	83 ec 0c             	sub    $0xc,%esp
  8002dc:	50                   	push   %eax
  8002dd:	6a 0a                	push   $0xa
  8002df:	68 ca 1d 80 00       	push   $0x801dca
  8002e4:	6a 23                	push   $0x23
  8002e6:	68 e7 1d 80 00       	push   $0x801de7
  8002eb:	e8 12 0d 00 00       	call   801002 <_panic>

008002f0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	57                   	push   %edi
  8002f4:	56                   	push   %esi
  8002f5:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002fc:	b8 0c 00 00 00       	mov    $0xc,%eax
  800301:	be 00 00 00 00       	mov    $0x0,%esi
  800306:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800309:	8b 7d 14             	mov    0x14(%ebp),%edi
  80030c:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80030e:	5b                   	pop    %ebx
  80030f:	5e                   	pop    %esi
  800310:	5f                   	pop    %edi
  800311:	5d                   	pop    %ebp
  800312:	c3                   	ret    

00800313 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
  800316:	57                   	push   %edi
  800317:	56                   	push   %esi
  800318:	53                   	push   %ebx
  800319:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80031c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800321:	8b 55 08             	mov    0x8(%ebp),%edx
  800324:	b8 0d 00 00 00       	mov    $0xd,%eax
  800329:	89 cb                	mov    %ecx,%ebx
  80032b:	89 cf                	mov    %ecx,%edi
  80032d:	89 ce                	mov    %ecx,%esi
  80032f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800331:	85 c0                	test   %eax,%eax
  800333:	7f 08                	jg     80033d <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800335:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800338:	5b                   	pop    %ebx
  800339:	5e                   	pop    %esi
  80033a:	5f                   	pop    %edi
  80033b:	5d                   	pop    %ebp
  80033c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80033d:	83 ec 0c             	sub    $0xc,%esp
  800340:	50                   	push   %eax
  800341:	6a 0d                	push   $0xd
  800343:	68 ca 1d 80 00       	push   $0x801dca
  800348:	6a 23                	push   $0x23
  80034a:	68 e7 1d 80 00       	push   $0x801de7
  80034f:	e8 ae 0c 00 00       	call   801002 <_panic>

00800354 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800357:	8b 45 08             	mov    0x8(%ebp),%eax
  80035a:	05 00 00 00 30       	add    $0x30000000,%eax
  80035f:	c1 e8 0c             	shr    $0xc,%eax
}
  800362:	5d                   	pop    %ebp
  800363:	c3                   	ret    

00800364 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800364:	55                   	push   %ebp
  800365:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800367:	8b 45 08             	mov    0x8(%ebp),%eax
  80036a:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80036f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800374:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800379:	5d                   	pop    %ebp
  80037a:	c3                   	ret    

0080037b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80037b:	55                   	push   %ebp
  80037c:	89 e5                	mov    %esp,%ebp
  80037e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800381:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800386:	89 c2                	mov    %eax,%edx
  800388:	c1 ea 16             	shr    $0x16,%edx
  80038b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800392:	f6 c2 01             	test   $0x1,%dl
  800395:	74 2a                	je     8003c1 <fd_alloc+0x46>
  800397:	89 c2                	mov    %eax,%edx
  800399:	c1 ea 0c             	shr    $0xc,%edx
  80039c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003a3:	f6 c2 01             	test   $0x1,%dl
  8003a6:	74 19                	je     8003c1 <fd_alloc+0x46>
  8003a8:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8003ad:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003b2:	75 d2                	jne    800386 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003b4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003ba:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8003bf:	eb 07                	jmp    8003c8 <fd_alloc+0x4d>
			*fd_store = fd;
  8003c1:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003c8:	5d                   	pop    %ebp
  8003c9:	c3                   	ret    

008003ca <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003d0:	83 f8 1f             	cmp    $0x1f,%eax
  8003d3:	77 36                	ja     80040b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003d5:	c1 e0 0c             	shl    $0xc,%eax
  8003d8:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003dd:	89 c2                	mov    %eax,%edx
  8003df:	c1 ea 16             	shr    $0x16,%edx
  8003e2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003e9:	f6 c2 01             	test   $0x1,%dl
  8003ec:	74 24                	je     800412 <fd_lookup+0x48>
  8003ee:	89 c2                	mov    %eax,%edx
  8003f0:	c1 ea 0c             	shr    $0xc,%edx
  8003f3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003fa:	f6 c2 01             	test   $0x1,%dl
  8003fd:	74 1a                	je     800419 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800402:	89 02                	mov    %eax,(%edx)
	return 0;
  800404:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800409:	5d                   	pop    %ebp
  80040a:	c3                   	ret    
		return -E_INVAL;
  80040b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800410:	eb f7                	jmp    800409 <fd_lookup+0x3f>
		return -E_INVAL;
  800412:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800417:	eb f0                	jmp    800409 <fd_lookup+0x3f>
  800419:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80041e:	eb e9                	jmp    800409 <fd_lookup+0x3f>

00800420 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800420:	55                   	push   %ebp
  800421:	89 e5                	mov    %esp,%ebp
  800423:	83 ec 08             	sub    $0x8,%esp
  800426:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800429:	ba 74 1e 80 00       	mov    $0x801e74,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80042e:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800433:	39 08                	cmp    %ecx,(%eax)
  800435:	74 33                	je     80046a <dev_lookup+0x4a>
  800437:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  80043a:	8b 02                	mov    (%edx),%eax
  80043c:	85 c0                	test   %eax,%eax
  80043e:	75 f3                	jne    800433 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800440:	a1 04 40 80 00       	mov    0x804004,%eax
  800445:	8b 40 48             	mov    0x48(%eax),%eax
  800448:	83 ec 04             	sub    $0x4,%esp
  80044b:	51                   	push   %ecx
  80044c:	50                   	push   %eax
  80044d:	68 f8 1d 80 00       	push   $0x801df8
  800452:	e8 86 0c 00 00       	call   8010dd <cprintf>
	*dev = 0;
  800457:	8b 45 0c             	mov    0xc(%ebp),%eax
  80045a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800460:	83 c4 10             	add    $0x10,%esp
  800463:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800468:	c9                   	leave  
  800469:	c3                   	ret    
			*dev = devtab[i];
  80046a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80046d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80046f:	b8 00 00 00 00       	mov    $0x0,%eax
  800474:	eb f2                	jmp    800468 <dev_lookup+0x48>

00800476 <fd_close>:
{
  800476:	55                   	push   %ebp
  800477:	89 e5                	mov    %esp,%ebp
  800479:	57                   	push   %edi
  80047a:	56                   	push   %esi
  80047b:	53                   	push   %ebx
  80047c:	83 ec 1c             	sub    $0x1c,%esp
  80047f:	8b 75 08             	mov    0x8(%ebp),%esi
  800482:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800485:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800488:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800489:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80048f:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800492:	50                   	push   %eax
  800493:	e8 32 ff ff ff       	call   8003ca <fd_lookup>
  800498:	89 c3                	mov    %eax,%ebx
  80049a:	83 c4 08             	add    $0x8,%esp
  80049d:	85 c0                	test   %eax,%eax
  80049f:	78 05                	js     8004a6 <fd_close+0x30>
	    || fd != fd2)
  8004a1:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8004a4:	74 16                	je     8004bc <fd_close+0x46>
		return (must_exist ? r : 0);
  8004a6:	89 f8                	mov    %edi,%eax
  8004a8:	84 c0                	test   %al,%al
  8004aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8004af:	0f 44 d8             	cmove  %eax,%ebx
}
  8004b2:	89 d8                	mov    %ebx,%eax
  8004b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004b7:	5b                   	pop    %ebx
  8004b8:	5e                   	pop    %esi
  8004b9:	5f                   	pop    %edi
  8004ba:	5d                   	pop    %ebp
  8004bb:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004bc:	83 ec 08             	sub    $0x8,%esp
  8004bf:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8004c2:	50                   	push   %eax
  8004c3:	ff 36                	pushl  (%esi)
  8004c5:	e8 56 ff ff ff       	call   800420 <dev_lookup>
  8004ca:	89 c3                	mov    %eax,%ebx
  8004cc:	83 c4 10             	add    $0x10,%esp
  8004cf:	85 c0                	test   %eax,%eax
  8004d1:	78 15                	js     8004e8 <fd_close+0x72>
		if (dev->dev_close)
  8004d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004d6:	8b 40 10             	mov    0x10(%eax),%eax
  8004d9:	85 c0                	test   %eax,%eax
  8004db:	74 1b                	je     8004f8 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  8004dd:	83 ec 0c             	sub    $0xc,%esp
  8004e0:	56                   	push   %esi
  8004e1:	ff d0                	call   *%eax
  8004e3:	89 c3                	mov    %eax,%ebx
  8004e5:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8004e8:	83 ec 08             	sub    $0x8,%esp
  8004eb:	56                   	push   %esi
  8004ec:	6a 00                	push   $0x0
  8004ee:	e8 f5 fc ff ff       	call   8001e8 <sys_page_unmap>
	return r;
  8004f3:	83 c4 10             	add    $0x10,%esp
  8004f6:	eb ba                	jmp    8004b2 <fd_close+0x3c>
			r = 0;
  8004f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8004fd:	eb e9                	jmp    8004e8 <fd_close+0x72>

008004ff <close>:

int
close(int fdnum)
{
  8004ff:	55                   	push   %ebp
  800500:	89 e5                	mov    %esp,%ebp
  800502:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800505:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800508:	50                   	push   %eax
  800509:	ff 75 08             	pushl  0x8(%ebp)
  80050c:	e8 b9 fe ff ff       	call   8003ca <fd_lookup>
  800511:	83 c4 08             	add    $0x8,%esp
  800514:	85 c0                	test   %eax,%eax
  800516:	78 10                	js     800528 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800518:	83 ec 08             	sub    $0x8,%esp
  80051b:	6a 01                	push   $0x1
  80051d:	ff 75 f4             	pushl  -0xc(%ebp)
  800520:	e8 51 ff ff ff       	call   800476 <fd_close>
  800525:	83 c4 10             	add    $0x10,%esp
}
  800528:	c9                   	leave  
  800529:	c3                   	ret    

0080052a <close_all>:

void
close_all(void)
{
  80052a:	55                   	push   %ebp
  80052b:	89 e5                	mov    %esp,%ebp
  80052d:	53                   	push   %ebx
  80052e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800531:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800536:	83 ec 0c             	sub    $0xc,%esp
  800539:	53                   	push   %ebx
  80053a:	e8 c0 ff ff ff       	call   8004ff <close>
	for (i = 0; i < MAXFD; i++)
  80053f:	83 c3 01             	add    $0x1,%ebx
  800542:	83 c4 10             	add    $0x10,%esp
  800545:	83 fb 20             	cmp    $0x20,%ebx
  800548:	75 ec                	jne    800536 <close_all+0xc>
}
  80054a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80054d:	c9                   	leave  
  80054e:	c3                   	ret    

0080054f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80054f:	55                   	push   %ebp
  800550:	89 e5                	mov    %esp,%ebp
  800552:	57                   	push   %edi
  800553:	56                   	push   %esi
  800554:	53                   	push   %ebx
  800555:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800558:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80055b:	50                   	push   %eax
  80055c:	ff 75 08             	pushl  0x8(%ebp)
  80055f:	e8 66 fe ff ff       	call   8003ca <fd_lookup>
  800564:	89 c3                	mov    %eax,%ebx
  800566:	83 c4 08             	add    $0x8,%esp
  800569:	85 c0                	test   %eax,%eax
  80056b:	0f 88 81 00 00 00    	js     8005f2 <dup+0xa3>
		return r;
	close(newfdnum);
  800571:	83 ec 0c             	sub    $0xc,%esp
  800574:	ff 75 0c             	pushl  0xc(%ebp)
  800577:	e8 83 ff ff ff       	call   8004ff <close>

	newfd = INDEX2FD(newfdnum);
  80057c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80057f:	c1 e6 0c             	shl    $0xc,%esi
  800582:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800588:	83 c4 04             	add    $0x4,%esp
  80058b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80058e:	e8 d1 fd ff ff       	call   800364 <fd2data>
  800593:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800595:	89 34 24             	mov    %esi,(%esp)
  800598:	e8 c7 fd ff ff       	call   800364 <fd2data>
  80059d:	83 c4 10             	add    $0x10,%esp
  8005a0:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005a2:	89 d8                	mov    %ebx,%eax
  8005a4:	c1 e8 16             	shr    $0x16,%eax
  8005a7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005ae:	a8 01                	test   $0x1,%al
  8005b0:	74 11                	je     8005c3 <dup+0x74>
  8005b2:	89 d8                	mov    %ebx,%eax
  8005b4:	c1 e8 0c             	shr    $0xc,%eax
  8005b7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005be:	f6 c2 01             	test   $0x1,%dl
  8005c1:	75 39                	jne    8005fc <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005c3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005c6:	89 d0                	mov    %edx,%eax
  8005c8:	c1 e8 0c             	shr    $0xc,%eax
  8005cb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005d2:	83 ec 0c             	sub    $0xc,%esp
  8005d5:	25 07 0e 00 00       	and    $0xe07,%eax
  8005da:	50                   	push   %eax
  8005db:	56                   	push   %esi
  8005dc:	6a 00                	push   $0x0
  8005de:	52                   	push   %edx
  8005df:	6a 00                	push   $0x0
  8005e1:	e8 c0 fb ff ff       	call   8001a6 <sys_page_map>
  8005e6:	89 c3                	mov    %eax,%ebx
  8005e8:	83 c4 20             	add    $0x20,%esp
  8005eb:	85 c0                	test   %eax,%eax
  8005ed:	78 31                	js     800620 <dup+0xd1>
		goto err;

	return newfdnum;
  8005ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005f2:	89 d8                	mov    %ebx,%eax
  8005f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005f7:	5b                   	pop    %ebx
  8005f8:	5e                   	pop    %esi
  8005f9:	5f                   	pop    %edi
  8005fa:	5d                   	pop    %ebp
  8005fb:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005fc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800603:	83 ec 0c             	sub    $0xc,%esp
  800606:	25 07 0e 00 00       	and    $0xe07,%eax
  80060b:	50                   	push   %eax
  80060c:	57                   	push   %edi
  80060d:	6a 00                	push   $0x0
  80060f:	53                   	push   %ebx
  800610:	6a 00                	push   $0x0
  800612:	e8 8f fb ff ff       	call   8001a6 <sys_page_map>
  800617:	89 c3                	mov    %eax,%ebx
  800619:	83 c4 20             	add    $0x20,%esp
  80061c:	85 c0                	test   %eax,%eax
  80061e:	79 a3                	jns    8005c3 <dup+0x74>
	sys_page_unmap(0, newfd);
  800620:	83 ec 08             	sub    $0x8,%esp
  800623:	56                   	push   %esi
  800624:	6a 00                	push   $0x0
  800626:	e8 bd fb ff ff       	call   8001e8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80062b:	83 c4 08             	add    $0x8,%esp
  80062e:	57                   	push   %edi
  80062f:	6a 00                	push   $0x0
  800631:	e8 b2 fb ff ff       	call   8001e8 <sys_page_unmap>
	return r;
  800636:	83 c4 10             	add    $0x10,%esp
  800639:	eb b7                	jmp    8005f2 <dup+0xa3>

0080063b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80063b:	55                   	push   %ebp
  80063c:	89 e5                	mov    %esp,%ebp
  80063e:	53                   	push   %ebx
  80063f:	83 ec 14             	sub    $0x14,%esp
  800642:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800645:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800648:	50                   	push   %eax
  800649:	53                   	push   %ebx
  80064a:	e8 7b fd ff ff       	call   8003ca <fd_lookup>
  80064f:	83 c4 08             	add    $0x8,%esp
  800652:	85 c0                	test   %eax,%eax
  800654:	78 3f                	js     800695 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800656:	83 ec 08             	sub    $0x8,%esp
  800659:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80065c:	50                   	push   %eax
  80065d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800660:	ff 30                	pushl  (%eax)
  800662:	e8 b9 fd ff ff       	call   800420 <dev_lookup>
  800667:	83 c4 10             	add    $0x10,%esp
  80066a:	85 c0                	test   %eax,%eax
  80066c:	78 27                	js     800695 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80066e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800671:	8b 42 08             	mov    0x8(%edx),%eax
  800674:	83 e0 03             	and    $0x3,%eax
  800677:	83 f8 01             	cmp    $0x1,%eax
  80067a:	74 1e                	je     80069a <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80067c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80067f:	8b 40 08             	mov    0x8(%eax),%eax
  800682:	85 c0                	test   %eax,%eax
  800684:	74 35                	je     8006bb <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800686:	83 ec 04             	sub    $0x4,%esp
  800689:	ff 75 10             	pushl  0x10(%ebp)
  80068c:	ff 75 0c             	pushl  0xc(%ebp)
  80068f:	52                   	push   %edx
  800690:	ff d0                	call   *%eax
  800692:	83 c4 10             	add    $0x10,%esp
}
  800695:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800698:	c9                   	leave  
  800699:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80069a:	a1 04 40 80 00       	mov    0x804004,%eax
  80069f:	8b 40 48             	mov    0x48(%eax),%eax
  8006a2:	83 ec 04             	sub    $0x4,%esp
  8006a5:	53                   	push   %ebx
  8006a6:	50                   	push   %eax
  8006a7:	68 39 1e 80 00       	push   $0x801e39
  8006ac:	e8 2c 0a 00 00       	call   8010dd <cprintf>
		return -E_INVAL;
  8006b1:	83 c4 10             	add    $0x10,%esp
  8006b4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006b9:	eb da                	jmp    800695 <read+0x5a>
		return -E_NOT_SUPP;
  8006bb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8006c0:	eb d3                	jmp    800695 <read+0x5a>

008006c2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006c2:	55                   	push   %ebp
  8006c3:	89 e5                	mov    %esp,%ebp
  8006c5:	57                   	push   %edi
  8006c6:	56                   	push   %esi
  8006c7:	53                   	push   %ebx
  8006c8:	83 ec 0c             	sub    $0xc,%esp
  8006cb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006ce:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006d1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d6:	39 f3                	cmp    %esi,%ebx
  8006d8:	73 25                	jae    8006ff <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006da:	83 ec 04             	sub    $0x4,%esp
  8006dd:	89 f0                	mov    %esi,%eax
  8006df:	29 d8                	sub    %ebx,%eax
  8006e1:	50                   	push   %eax
  8006e2:	89 d8                	mov    %ebx,%eax
  8006e4:	03 45 0c             	add    0xc(%ebp),%eax
  8006e7:	50                   	push   %eax
  8006e8:	57                   	push   %edi
  8006e9:	e8 4d ff ff ff       	call   80063b <read>
		if (m < 0)
  8006ee:	83 c4 10             	add    $0x10,%esp
  8006f1:	85 c0                	test   %eax,%eax
  8006f3:	78 08                	js     8006fd <readn+0x3b>
			return m;
		if (m == 0)
  8006f5:	85 c0                	test   %eax,%eax
  8006f7:	74 06                	je     8006ff <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  8006f9:	01 c3                	add    %eax,%ebx
  8006fb:	eb d9                	jmp    8006d6 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006fd:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8006ff:	89 d8                	mov    %ebx,%eax
  800701:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800704:	5b                   	pop    %ebx
  800705:	5e                   	pop    %esi
  800706:	5f                   	pop    %edi
  800707:	5d                   	pop    %ebp
  800708:	c3                   	ret    

00800709 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800709:	55                   	push   %ebp
  80070a:	89 e5                	mov    %esp,%ebp
  80070c:	53                   	push   %ebx
  80070d:	83 ec 14             	sub    $0x14,%esp
  800710:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800713:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800716:	50                   	push   %eax
  800717:	53                   	push   %ebx
  800718:	e8 ad fc ff ff       	call   8003ca <fd_lookup>
  80071d:	83 c4 08             	add    $0x8,%esp
  800720:	85 c0                	test   %eax,%eax
  800722:	78 3a                	js     80075e <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800724:	83 ec 08             	sub    $0x8,%esp
  800727:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80072a:	50                   	push   %eax
  80072b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80072e:	ff 30                	pushl  (%eax)
  800730:	e8 eb fc ff ff       	call   800420 <dev_lookup>
  800735:	83 c4 10             	add    $0x10,%esp
  800738:	85 c0                	test   %eax,%eax
  80073a:	78 22                	js     80075e <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80073c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80073f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800743:	74 1e                	je     800763 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800745:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800748:	8b 52 0c             	mov    0xc(%edx),%edx
  80074b:	85 d2                	test   %edx,%edx
  80074d:	74 35                	je     800784 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80074f:	83 ec 04             	sub    $0x4,%esp
  800752:	ff 75 10             	pushl  0x10(%ebp)
  800755:	ff 75 0c             	pushl  0xc(%ebp)
  800758:	50                   	push   %eax
  800759:	ff d2                	call   *%edx
  80075b:	83 c4 10             	add    $0x10,%esp
}
  80075e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800761:	c9                   	leave  
  800762:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800763:	a1 04 40 80 00       	mov    0x804004,%eax
  800768:	8b 40 48             	mov    0x48(%eax),%eax
  80076b:	83 ec 04             	sub    $0x4,%esp
  80076e:	53                   	push   %ebx
  80076f:	50                   	push   %eax
  800770:	68 55 1e 80 00       	push   $0x801e55
  800775:	e8 63 09 00 00       	call   8010dd <cprintf>
		return -E_INVAL;
  80077a:	83 c4 10             	add    $0x10,%esp
  80077d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800782:	eb da                	jmp    80075e <write+0x55>
		return -E_NOT_SUPP;
  800784:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800789:	eb d3                	jmp    80075e <write+0x55>

0080078b <seek>:

int
seek(int fdnum, off_t offset)
{
  80078b:	55                   	push   %ebp
  80078c:	89 e5                	mov    %esp,%ebp
  80078e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800791:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800794:	50                   	push   %eax
  800795:	ff 75 08             	pushl  0x8(%ebp)
  800798:	e8 2d fc ff ff       	call   8003ca <fd_lookup>
  80079d:	83 c4 08             	add    $0x8,%esp
  8007a0:	85 c0                	test   %eax,%eax
  8007a2:	78 0e                	js     8007b2 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007aa:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007b2:	c9                   	leave  
  8007b3:	c3                   	ret    

008007b4 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	53                   	push   %ebx
  8007b8:	83 ec 14             	sub    $0x14,%esp
  8007bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007be:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007c1:	50                   	push   %eax
  8007c2:	53                   	push   %ebx
  8007c3:	e8 02 fc ff ff       	call   8003ca <fd_lookup>
  8007c8:	83 c4 08             	add    $0x8,%esp
  8007cb:	85 c0                	test   %eax,%eax
  8007cd:	78 37                	js     800806 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007cf:	83 ec 08             	sub    $0x8,%esp
  8007d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d5:	50                   	push   %eax
  8007d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007d9:	ff 30                	pushl  (%eax)
  8007db:	e8 40 fc ff ff       	call   800420 <dev_lookup>
  8007e0:	83 c4 10             	add    $0x10,%esp
  8007e3:	85 c0                	test   %eax,%eax
  8007e5:	78 1f                	js     800806 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ea:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007ee:	74 1b                	je     80080b <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8007f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007f3:	8b 52 18             	mov    0x18(%edx),%edx
  8007f6:	85 d2                	test   %edx,%edx
  8007f8:	74 32                	je     80082c <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8007fa:	83 ec 08             	sub    $0x8,%esp
  8007fd:	ff 75 0c             	pushl  0xc(%ebp)
  800800:	50                   	push   %eax
  800801:	ff d2                	call   *%edx
  800803:	83 c4 10             	add    $0x10,%esp
}
  800806:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800809:	c9                   	leave  
  80080a:	c3                   	ret    
			thisenv->env_id, fdnum);
  80080b:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800810:	8b 40 48             	mov    0x48(%eax),%eax
  800813:	83 ec 04             	sub    $0x4,%esp
  800816:	53                   	push   %ebx
  800817:	50                   	push   %eax
  800818:	68 18 1e 80 00       	push   $0x801e18
  80081d:	e8 bb 08 00 00       	call   8010dd <cprintf>
		return -E_INVAL;
  800822:	83 c4 10             	add    $0x10,%esp
  800825:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80082a:	eb da                	jmp    800806 <ftruncate+0x52>
		return -E_NOT_SUPP;
  80082c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800831:	eb d3                	jmp    800806 <ftruncate+0x52>

00800833 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800833:	55                   	push   %ebp
  800834:	89 e5                	mov    %esp,%ebp
  800836:	53                   	push   %ebx
  800837:	83 ec 14             	sub    $0x14,%esp
  80083a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80083d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800840:	50                   	push   %eax
  800841:	ff 75 08             	pushl  0x8(%ebp)
  800844:	e8 81 fb ff ff       	call   8003ca <fd_lookup>
  800849:	83 c4 08             	add    $0x8,%esp
  80084c:	85 c0                	test   %eax,%eax
  80084e:	78 4b                	js     80089b <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800850:	83 ec 08             	sub    $0x8,%esp
  800853:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800856:	50                   	push   %eax
  800857:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80085a:	ff 30                	pushl  (%eax)
  80085c:	e8 bf fb ff ff       	call   800420 <dev_lookup>
  800861:	83 c4 10             	add    $0x10,%esp
  800864:	85 c0                	test   %eax,%eax
  800866:	78 33                	js     80089b <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  800868:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80086b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80086f:	74 2f                	je     8008a0 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800871:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800874:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80087b:	00 00 00 
	stat->st_isdir = 0;
  80087e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800885:	00 00 00 
	stat->st_dev = dev;
  800888:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80088e:	83 ec 08             	sub    $0x8,%esp
  800891:	53                   	push   %ebx
  800892:	ff 75 f0             	pushl  -0x10(%ebp)
  800895:	ff 50 14             	call   *0x14(%eax)
  800898:	83 c4 10             	add    $0x10,%esp
}
  80089b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80089e:	c9                   	leave  
  80089f:	c3                   	ret    
		return -E_NOT_SUPP;
  8008a0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8008a5:	eb f4                	jmp    80089b <fstat+0x68>

008008a7 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008a7:	55                   	push   %ebp
  8008a8:	89 e5                	mov    %esp,%ebp
  8008aa:	56                   	push   %esi
  8008ab:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008ac:	83 ec 08             	sub    $0x8,%esp
  8008af:	6a 00                	push   $0x0
  8008b1:	ff 75 08             	pushl  0x8(%ebp)
  8008b4:	e8 da 01 00 00       	call   800a93 <open>
  8008b9:	89 c3                	mov    %eax,%ebx
  8008bb:	83 c4 10             	add    $0x10,%esp
  8008be:	85 c0                	test   %eax,%eax
  8008c0:	78 1b                	js     8008dd <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008c2:	83 ec 08             	sub    $0x8,%esp
  8008c5:	ff 75 0c             	pushl  0xc(%ebp)
  8008c8:	50                   	push   %eax
  8008c9:	e8 65 ff ff ff       	call   800833 <fstat>
  8008ce:	89 c6                	mov    %eax,%esi
	close(fd);
  8008d0:	89 1c 24             	mov    %ebx,(%esp)
  8008d3:	e8 27 fc ff ff       	call   8004ff <close>
	return r;
  8008d8:	83 c4 10             	add    $0x10,%esp
  8008db:	89 f3                	mov    %esi,%ebx
}
  8008dd:	89 d8                	mov    %ebx,%eax
  8008df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008e2:	5b                   	pop    %ebx
  8008e3:	5e                   	pop    %esi
  8008e4:	5d                   	pop    %ebp
  8008e5:	c3                   	ret    

008008e6 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008e6:	55                   	push   %ebp
  8008e7:	89 e5                	mov    %esp,%ebp
  8008e9:	56                   	push   %esi
  8008ea:	53                   	push   %ebx
  8008eb:	89 c6                	mov    %eax,%esi
  8008ed:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008ef:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8008f6:	74 27                	je     80091f <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008f8:	6a 07                	push   $0x7
  8008fa:	68 00 50 80 00       	push   $0x805000
  8008ff:	56                   	push   %esi
  800900:	ff 35 00 40 80 00    	pushl  0x804000
  800906:	e8 95 11 00 00       	call   801aa0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80090b:	83 c4 0c             	add    $0xc,%esp
  80090e:	6a 00                	push   $0x0
  800910:	53                   	push   %ebx
  800911:	6a 00                	push   $0x0
  800913:	e8 21 11 00 00       	call   801a39 <ipc_recv>
}
  800918:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80091b:	5b                   	pop    %ebx
  80091c:	5e                   	pop    %esi
  80091d:	5d                   	pop    %ebp
  80091e:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80091f:	83 ec 0c             	sub    $0xc,%esp
  800922:	6a 01                	push   $0x1
  800924:	e8 cb 11 00 00       	call   801af4 <ipc_find_env>
  800929:	a3 00 40 80 00       	mov    %eax,0x804000
  80092e:	83 c4 10             	add    $0x10,%esp
  800931:	eb c5                	jmp    8008f8 <fsipc+0x12>

00800933 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800933:	55                   	push   %ebp
  800934:	89 e5                	mov    %esp,%ebp
  800936:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800939:	8b 45 08             	mov    0x8(%ebp),%eax
  80093c:	8b 40 0c             	mov    0xc(%eax),%eax
  80093f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800944:	8b 45 0c             	mov    0xc(%ebp),%eax
  800947:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80094c:	ba 00 00 00 00       	mov    $0x0,%edx
  800951:	b8 02 00 00 00       	mov    $0x2,%eax
  800956:	e8 8b ff ff ff       	call   8008e6 <fsipc>
}
  80095b:	c9                   	leave  
  80095c:	c3                   	ret    

0080095d <devfile_flush>:
{
  80095d:	55                   	push   %ebp
  80095e:	89 e5                	mov    %esp,%ebp
  800960:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800963:	8b 45 08             	mov    0x8(%ebp),%eax
  800966:	8b 40 0c             	mov    0xc(%eax),%eax
  800969:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80096e:	ba 00 00 00 00       	mov    $0x0,%edx
  800973:	b8 06 00 00 00       	mov    $0x6,%eax
  800978:	e8 69 ff ff ff       	call   8008e6 <fsipc>
}
  80097d:	c9                   	leave  
  80097e:	c3                   	ret    

0080097f <devfile_stat>:
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	53                   	push   %ebx
  800983:	83 ec 04             	sub    $0x4,%esp
  800986:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800989:	8b 45 08             	mov    0x8(%ebp),%eax
  80098c:	8b 40 0c             	mov    0xc(%eax),%eax
  80098f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800994:	ba 00 00 00 00       	mov    $0x0,%edx
  800999:	b8 05 00 00 00       	mov    $0x5,%eax
  80099e:	e8 43 ff ff ff       	call   8008e6 <fsipc>
  8009a3:	85 c0                	test   %eax,%eax
  8009a5:	78 2c                	js     8009d3 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009a7:	83 ec 08             	sub    $0x8,%esp
  8009aa:	68 00 50 80 00       	push   $0x805000
  8009af:	53                   	push   %ebx
  8009b0:	e8 47 0d 00 00       	call   8016fc <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009b5:	a1 80 50 80 00       	mov    0x805080,%eax
  8009ba:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009c0:	a1 84 50 80 00       	mov    0x805084,%eax
  8009c5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009cb:	83 c4 10             	add    $0x10,%esp
  8009ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009d6:	c9                   	leave  
  8009d7:	c3                   	ret    

008009d8 <devfile_write>:
{
  8009d8:	55                   	push   %ebp
  8009d9:	89 e5                	mov    %esp,%ebp
  8009db:	83 ec 0c             	sub    $0xc,%esp
  8009de:	8b 45 10             	mov    0x10(%ebp),%eax
    	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8009e4:	8b 52 0c             	mov    0xc(%edx),%edx
  8009e7:	89 15 00 50 80 00    	mov    %edx,0x805000
    	fsipcbuf.write.req_n = n;
  8009ed:	a3 04 50 80 00       	mov    %eax,0x805004
    	memmove(fsipcbuf.write.req_buf, buf, n);
  8009f2:	50                   	push   %eax
  8009f3:	ff 75 0c             	pushl  0xc(%ebp)
  8009f6:	68 08 50 80 00       	push   $0x805008
  8009fb:	e8 8a 0e 00 00       	call   80188a <memmove>
    	return fsipc(FSREQ_WRITE, NULL);
  800a00:	ba 00 00 00 00       	mov    $0x0,%edx
  800a05:	b8 04 00 00 00       	mov    $0x4,%eax
  800a0a:	e8 d7 fe ff ff       	call   8008e6 <fsipc>
}
  800a0f:	c9                   	leave  
  800a10:	c3                   	ret    

00800a11 <devfile_read>:
{
  800a11:	55                   	push   %ebp
  800a12:	89 e5                	mov    %esp,%ebp
  800a14:	56                   	push   %esi
  800a15:	53                   	push   %ebx
  800a16:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a19:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1c:	8b 40 0c             	mov    0xc(%eax),%eax
  800a1f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a24:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a2a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2f:	b8 03 00 00 00       	mov    $0x3,%eax
  800a34:	e8 ad fe ff ff       	call   8008e6 <fsipc>
  800a39:	89 c3                	mov    %eax,%ebx
  800a3b:	85 c0                	test   %eax,%eax
  800a3d:	78 1f                	js     800a5e <devfile_read+0x4d>
	assert(r <= n);
  800a3f:	39 f0                	cmp    %esi,%eax
  800a41:	77 24                	ja     800a67 <devfile_read+0x56>
	assert(r <= PGSIZE);
  800a43:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a48:	7f 33                	jg     800a7d <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a4a:	83 ec 04             	sub    $0x4,%esp
  800a4d:	50                   	push   %eax
  800a4e:	68 00 50 80 00       	push   $0x805000
  800a53:	ff 75 0c             	pushl  0xc(%ebp)
  800a56:	e8 2f 0e 00 00       	call   80188a <memmove>
	return r;
  800a5b:	83 c4 10             	add    $0x10,%esp
}
  800a5e:	89 d8                	mov    %ebx,%eax
  800a60:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a63:	5b                   	pop    %ebx
  800a64:	5e                   	pop    %esi
  800a65:	5d                   	pop    %ebp
  800a66:	c3                   	ret    
	assert(r <= n);
  800a67:	68 84 1e 80 00       	push   $0x801e84
  800a6c:	68 8b 1e 80 00       	push   $0x801e8b
  800a71:	6a 7c                	push   $0x7c
  800a73:	68 a0 1e 80 00       	push   $0x801ea0
  800a78:	e8 85 05 00 00       	call   801002 <_panic>
	assert(r <= PGSIZE);
  800a7d:	68 ab 1e 80 00       	push   $0x801eab
  800a82:	68 8b 1e 80 00       	push   $0x801e8b
  800a87:	6a 7d                	push   $0x7d
  800a89:	68 a0 1e 80 00       	push   $0x801ea0
  800a8e:	e8 6f 05 00 00       	call   801002 <_panic>

00800a93 <open>:
{
  800a93:	55                   	push   %ebp
  800a94:	89 e5                	mov    %esp,%ebp
  800a96:	56                   	push   %esi
  800a97:	53                   	push   %ebx
  800a98:	83 ec 1c             	sub    $0x1c,%esp
  800a9b:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800a9e:	56                   	push   %esi
  800a9f:	e8 21 0c 00 00       	call   8016c5 <strlen>
  800aa4:	83 c4 10             	add    $0x10,%esp
  800aa7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800aac:	7f 6c                	jg     800b1a <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  800aae:	83 ec 0c             	sub    $0xc,%esp
  800ab1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ab4:	50                   	push   %eax
  800ab5:	e8 c1 f8 ff ff       	call   80037b <fd_alloc>
  800aba:	89 c3                	mov    %eax,%ebx
  800abc:	83 c4 10             	add    $0x10,%esp
  800abf:	85 c0                	test   %eax,%eax
  800ac1:	78 3c                	js     800aff <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  800ac3:	83 ec 08             	sub    $0x8,%esp
  800ac6:	56                   	push   %esi
  800ac7:	68 00 50 80 00       	push   $0x805000
  800acc:	e8 2b 0c 00 00       	call   8016fc <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ad1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad4:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800ad9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800adc:	b8 01 00 00 00       	mov    $0x1,%eax
  800ae1:	e8 00 fe ff ff       	call   8008e6 <fsipc>
  800ae6:	89 c3                	mov    %eax,%ebx
  800ae8:	83 c4 10             	add    $0x10,%esp
  800aeb:	85 c0                	test   %eax,%eax
  800aed:	78 19                	js     800b08 <open+0x75>
	return fd2num(fd);
  800aef:	83 ec 0c             	sub    $0xc,%esp
  800af2:	ff 75 f4             	pushl  -0xc(%ebp)
  800af5:	e8 5a f8 ff ff       	call   800354 <fd2num>
  800afa:	89 c3                	mov    %eax,%ebx
  800afc:	83 c4 10             	add    $0x10,%esp
}
  800aff:	89 d8                	mov    %ebx,%eax
  800b01:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b04:	5b                   	pop    %ebx
  800b05:	5e                   	pop    %esi
  800b06:	5d                   	pop    %ebp
  800b07:	c3                   	ret    
		fd_close(fd, 0);
  800b08:	83 ec 08             	sub    $0x8,%esp
  800b0b:	6a 00                	push   $0x0
  800b0d:	ff 75 f4             	pushl  -0xc(%ebp)
  800b10:	e8 61 f9 ff ff       	call   800476 <fd_close>
		return r;
  800b15:	83 c4 10             	add    $0x10,%esp
  800b18:	eb e5                	jmp    800aff <open+0x6c>
		return -E_BAD_PATH;
  800b1a:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b1f:	eb de                	jmp    800aff <open+0x6c>

00800b21 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b27:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2c:	b8 08 00 00 00       	mov    $0x8,%eax
  800b31:	e8 b0 fd ff ff       	call   8008e6 <fsipc>
}
  800b36:	c9                   	leave  
  800b37:	c3                   	ret    

00800b38 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	56                   	push   %esi
  800b3c:	53                   	push   %ebx
  800b3d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b40:	83 ec 0c             	sub    $0xc,%esp
  800b43:	ff 75 08             	pushl  0x8(%ebp)
  800b46:	e8 19 f8 ff ff       	call   800364 <fd2data>
  800b4b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b4d:	83 c4 08             	add    $0x8,%esp
  800b50:	68 b7 1e 80 00       	push   $0x801eb7
  800b55:	53                   	push   %ebx
  800b56:	e8 a1 0b 00 00       	call   8016fc <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b5b:	8b 46 04             	mov    0x4(%esi),%eax
  800b5e:	2b 06                	sub    (%esi),%eax
  800b60:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b66:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b6d:	00 00 00 
	stat->st_dev = &devpipe;
  800b70:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b77:	30 80 00 
	return 0;
}
  800b7a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b82:	5b                   	pop    %ebx
  800b83:	5e                   	pop    %esi
  800b84:	5d                   	pop    %ebp
  800b85:	c3                   	ret    

00800b86 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	53                   	push   %ebx
  800b8a:	83 ec 0c             	sub    $0xc,%esp
  800b8d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b90:	53                   	push   %ebx
  800b91:	6a 00                	push   $0x0
  800b93:	e8 50 f6 ff ff       	call   8001e8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b98:	89 1c 24             	mov    %ebx,(%esp)
  800b9b:	e8 c4 f7 ff ff       	call   800364 <fd2data>
  800ba0:	83 c4 08             	add    $0x8,%esp
  800ba3:	50                   	push   %eax
  800ba4:	6a 00                	push   $0x0
  800ba6:	e8 3d f6 ff ff       	call   8001e8 <sys_page_unmap>
}
  800bab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bae:	c9                   	leave  
  800baf:	c3                   	ret    

00800bb0 <_pipeisclosed>:
{
  800bb0:	55                   	push   %ebp
  800bb1:	89 e5                	mov    %esp,%ebp
  800bb3:	57                   	push   %edi
  800bb4:	56                   	push   %esi
  800bb5:	53                   	push   %ebx
  800bb6:	83 ec 1c             	sub    $0x1c,%esp
  800bb9:	89 c7                	mov    %eax,%edi
  800bbb:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800bbd:	a1 04 40 80 00       	mov    0x804004,%eax
  800bc2:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800bc5:	83 ec 0c             	sub    $0xc,%esp
  800bc8:	57                   	push   %edi
  800bc9:	e8 5f 0f 00 00       	call   801b2d <pageref>
  800bce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800bd1:	89 34 24             	mov    %esi,(%esp)
  800bd4:	e8 54 0f 00 00       	call   801b2d <pageref>
		nn = thisenv->env_runs;
  800bd9:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800bdf:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800be2:	83 c4 10             	add    $0x10,%esp
  800be5:	39 cb                	cmp    %ecx,%ebx
  800be7:	74 1b                	je     800c04 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800be9:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800bec:	75 cf                	jne    800bbd <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800bee:	8b 42 58             	mov    0x58(%edx),%eax
  800bf1:	6a 01                	push   $0x1
  800bf3:	50                   	push   %eax
  800bf4:	53                   	push   %ebx
  800bf5:	68 be 1e 80 00       	push   $0x801ebe
  800bfa:	e8 de 04 00 00       	call   8010dd <cprintf>
  800bff:	83 c4 10             	add    $0x10,%esp
  800c02:	eb b9                	jmp    800bbd <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800c04:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c07:	0f 94 c0             	sete   %al
  800c0a:	0f b6 c0             	movzbl %al,%eax
}
  800c0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c10:	5b                   	pop    %ebx
  800c11:	5e                   	pop    %esi
  800c12:	5f                   	pop    %edi
  800c13:	5d                   	pop    %ebp
  800c14:	c3                   	ret    

00800c15 <devpipe_write>:
{
  800c15:	55                   	push   %ebp
  800c16:	89 e5                	mov    %esp,%ebp
  800c18:	57                   	push   %edi
  800c19:	56                   	push   %esi
  800c1a:	53                   	push   %ebx
  800c1b:	83 ec 28             	sub    $0x28,%esp
  800c1e:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800c21:	56                   	push   %esi
  800c22:	e8 3d f7 ff ff       	call   800364 <fd2data>
  800c27:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c29:	83 c4 10             	add    $0x10,%esp
  800c2c:	bf 00 00 00 00       	mov    $0x0,%edi
  800c31:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c34:	74 4f                	je     800c85 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c36:	8b 43 04             	mov    0x4(%ebx),%eax
  800c39:	8b 0b                	mov    (%ebx),%ecx
  800c3b:	8d 51 20             	lea    0x20(%ecx),%edx
  800c3e:	39 d0                	cmp    %edx,%eax
  800c40:	72 14                	jb     800c56 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  800c42:	89 da                	mov    %ebx,%edx
  800c44:	89 f0                	mov    %esi,%eax
  800c46:	e8 65 ff ff ff       	call   800bb0 <_pipeisclosed>
  800c4b:	85 c0                	test   %eax,%eax
  800c4d:	75 3a                	jne    800c89 <devpipe_write+0x74>
			sys_yield();
  800c4f:	e8 f0 f4 ff ff       	call   800144 <sys_yield>
  800c54:	eb e0                	jmp    800c36 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c59:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c5d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c60:	89 c2                	mov    %eax,%edx
  800c62:	c1 fa 1f             	sar    $0x1f,%edx
  800c65:	89 d1                	mov    %edx,%ecx
  800c67:	c1 e9 1b             	shr    $0x1b,%ecx
  800c6a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c6d:	83 e2 1f             	and    $0x1f,%edx
  800c70:	29 ca                	sub    %ecx,%edx
  800c72:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c76:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c7a:	83 c0 01             	add    $0x1,%eax
  800c7d:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800c80:	83 c7 01             	add    $0x1,%edi
  800c83:	eb ac                	jmp    800c31 <devpipe_write+0x1c>
	return i;
  800c85:	89 f8                	mov    %edi,%eax
  800c87:	eb 05                	jmp    800c8e <devpipe_write+0x79>
				return 0;
  800c89:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c91:	5b                   	pop    %ebx
  800c92:	5e                   	pop    %esi
  800c93:	5f                   	pop    %edi
  800c94:	5d                   	pop    %ebp
  800c95:	c3                   	ret    

00800c96 <devpipe_read>:
{
  800c96:	55                   	push   %ebp
  800c97:	89 e5                	mov    %esp,%ebp
  800c99:	57                   	push   %edi
  800c9a:	56                   	push   %esi
  800c9b:	53                   	push   %ebx
  800c9c:	83 ec 18             	sub    $0x18,%esp
  800c9f:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800ca2:	57                   	push   %edi
  800ca3:	e8 bc f6 ff ff       	call   800364 <fd2data>
  800ca8:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800caa:	83 c4 10             	add    $0x10,%esp
  800cad:	be 00 00 00 00       	mov    $0x0,%esi
  800cb2:	3b 75 10             	cmp    0x10(%ebp),%esi
  800cb5:	74 47                	je     800cfe <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  800cb7:	8b 03                	mov    (%ebx),%eax
  800cb9:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cbc:	75 22                	jne    800ce0 <devpipe_read+0x4a>
			if (i > 0)
  800cbe:	85 f6                	test   %esi,%esi
  800cc0:	75 14                	jne    800cd6 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  800cc2:	89 da                	mov    %ebx,%edx
  800cc4:	89 f8                	mov    %edi,%eax
  800cc6:	e8 e5 fe ff ff       	call   800bb0 <_pipeisclosed>
  800ccb:	85 c0                	test   %eax,%eax
  800ccd:	75 33                	jne    800d02 <devpipe_read+0x6c>
			sys_yield();
  800ccf:	e8 70 f4 ff ff       	call   800144 <sys_yield>
  800cd4:	eb e1                	jmp    800cb7 <devpipe_read+0x21>
				return i;
  800cd6:	89 f0                	mov    %esi,%eax
}
  800cd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdb:	5b                   	pop    %ebx
  800cdc:	5e                   	pop    %esi
  800cdd:	5f                   	pop    %edi
  800cde:	5d                   	pop    %ebp
  800cdf:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800ce0:	99                   	cltd   
  800ce1:	c1 ea 1b             	shr    $0x1b,%edx
  800ce4:	01 d0                	add    %edx,%eax
  800ce6:	83 e0 1f             	and    $0x1f,%eax
  800ce9:	29 d0                	sub    %edx,%eax
  800ceb:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800cf0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf3:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800cf6:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800cf9:	83 c6 01             	add    $0x1,%esi
  800cfc:	eb b4                	jmp    800cb2 <devpipe_read+0x1c>
	return i;
  800cfe:	89 f0                	mov    %esi,%eax
  800d00:	eb d6                	jmp    800cd8 <devpipe_read+0x42>
				return 0;
  800d02:	b8 00 00 00 00       	mov    $0x0,%eax
  800d07:	eb cf                	jmp    800cd8 <devpipe_read+0x42>

00800d09 <pipe>:
{
  800d09:	55                   	push   %ebp
  800d0a:	89 e5                	mov    %esp,%ebp
  800d0c:	56                   	push   %esi
  800d0d:	53                   	push   %ebx
  800d0e:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800d11:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d14:	50                   	push   %eax
  800d15:	e8 61 f6 ff ff       	call   80037b <fd_alloc>
  800d1a:	89 c3                	mov    %eax,%ebx
  800d1c:	83 c4 10             	add    $0x10,%esp
  800d1f:	85 c0                	test   %eax,%eax
  800d21:	78 5b                	js     800d7e <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d23:	83 ec 04             	sub    $0x4,%esp
  800d26:	68 07 04 00 00       	push   $0x407
  800d2b:	ff 75 f4             	pushl  -0xc(%ebp)
  800d2e:	6a 00                	push   $0x0
  800d30:	e8 2e f4 ff ff       	call   800163 <sys_page_alloc>
  800d35:	89 c3                	mov    %eax,%ebx
  800d37:	83 c4 10             	add    $0x10,%esp
  800d3a:	85 c0                	test   %eax,%eax
  800d3c:	78 40                	js     800d7e <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  800d3e:	83 ec 0c             	sub    $0xc,%esp
  800d41:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d44:	50                   	push   %eax
  800d45:	e8 31 f6 ff ff       	call   80037b <fd_alloc>
  800d4a:	89 c3                	mov    %eax,%ebx
  800d4c:	83 c4 10             	add    $0x10,%esp
  800d4f:	85 c0                	test   %eax,%eax
  800d51:	78 1b                	js     800d6e <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d53:	83 ec 04             	sub    $0x4,%esp
  800d56:	68 07 04 00 00       	push   $0x407
  800d5b:	ff 75 f0             	pushl  -0x10(%ebp)
  800d5e:	6a 00                	push   $0x0
  800d60:	e8 fe f3 ff ff       	call   800163 <sys_page_alloc>
  800d65:	89 c3                	mov    %eax,%ebx
  800d67:	83 c4 10             	add    $0x10,%esp
  800d6a:	85 c0                	test   %eax,%eax
  800d6c:	79 19                	jns    800d87 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  800d6e:	83 ec 08             	sub    $0x8,%esp
  800d71:	ff 75 f4             	pushl  -0xc(%ebp)
  800d74:	6a 00                	push   $0x0
  800d76:	e8 6d f4 ff ff       	call   8001e8 <sys_page_unmap>
  800d7b:	83 c4 10             	add    $0x10,%esp
}
  800d7e:	89 d8                	mov    %ebx,%eax
  800d80:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d83:	5b                   	pop    %ebx
  800d84:	5e                   	pop    %esi
  800d85:	5d                   	pop    %ebp
  800d86:	c3                   	ret    
	va = fd2data(fd0);
  800d87:	83 ec 0c             	sub    $0xc,%esp
  800d8a:	ff 75 f4             	pushl  -0xc(%ebp)
  800d8d:	e8 d2 f5 ff ff       	call   800364 <fd2data>
  800d92:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d94:	83 c4 0c             	add    $0xc,%esp
  800d97:	68 07 04 00 00       	push   $0x407
  800d9c:	50                   	push   %eax
  800d9d:	6a 00                	push   $0x0
  800d9f:	e8 bf f3 ff ff       	call   800163 <sys_page_alloc>
  800da4:	89 c3                	mov    %eax,%ebx
  800da6:	83 c4 10             	add    $0x10,%esp
  800da9:	85 c0                	test   %eax,%eax
  800dab:	0f 88 8c 00 00 00    	js     800e3d <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800db1:	83 ec 0c             	sub    $0xc,%esp
  800db4:	ff 75 f0             	pushl  -0x10(%ebp)
  800db7:	e8 a8 f5 ff ff       	call   800364 <fd2data>
  800dbc:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dc3:	50                   	push   %eax
  800dc4:	6a 00                	push   $0x0
  800dc6:	56                   	push   %esi
  800dc7:	6a 00                	push   $0x0
  800dc9:	e8 d8 f3 ff ff       	call   8001a6 <sys_page_map>
  800dce:	89 c3                	mov    %eax,%ebx
  800dd0:	83 c4 20             	add    $0x20,%esp
  800dd3:	85 c0                	test   %eax,%eax
  800dd5:	78 58                	js     800e2f <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  800dd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dda:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800de0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800de2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800de5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  800dec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800def:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800df5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800df7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dfa:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800e01:	83 ec 0c             	sub    $0xc,%esp
  800e04:	ff 75 f4             	pushl  -0xc(%ebp)
  800e07:	e8 48 f5 ff ff       	call   800354 <fd2num>
  800e0c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e0f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e11:	83 c4 04             	add    $0x4,%esp
  800e14:	ff 75 f0             	pushl  -0x10(%ebp)
  800e17:	e8 38 f5 ff ff       	call   800354 <fd2num>
  800e1c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e1f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e22:	83 c4 10             	add    $0x10,%esp
  800e25:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e2a:	e9 4f ff ff ff       	jmp    800d7e <pipe+0x75>
	sys_page_unmap(0, va);
  800e2f:	83 ec 08             	sub    $0x8,%esp
  800e32:	56                   	push   %esi
  800e33:	6a 00                	push   $0x0
  800e35:	e8 ae f3 ff ff       	call   8001e8 <sys_page_unmap>
  800e3a:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800e3d:	83 ec 08             	sub    $0x8,%esp
  800e40:	ff 75 f0             	pushl  -0x10(%ebp)
  800e43:	6a 00                	push   $0x0
  800e45:	e8 9e f3 ff ff       	call   8001e8 <sys_page_unmap>
  800e4a:	83 c4 10             	add    $0x10,%esp
  800e4d:	e9 1c ff ff ff       	jmp    800d6e <pipe+0x65>

00800e52 <pipeisclosed>:
{
  800e52:	55                   	push   %ebp
  800e53:	89 e5                	mov    %esp,%ebp
  800e55:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e58:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e5b:	50                   	push   %eax
  800e5c:	ff 75 08             	pushl  0x8(%ebp)
  800e5f:	e8 66 f5 ff ff       	call   8003ca <fd_lookup>
  800e64:	83 c4 10             	add    $0x10,%esp
  800e67:	85 c0                	test   %eax,%eax
  800e69:	78 18                	js     800e83 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  800e6b:	83 ec 0c             	sub    $0xc,%esp
  800e6e:	ff 75 f4             	pushl  -0xc(%ebp)
  800e71:	e8 ee f4 ff ff       	call   800364 <fd2data>
	return _pipeisclosed(fd, p);
  800e76:	89 c2                	mov    %eax,%edx
  800e78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e7b:	e8 30 fd ff ff       	call   800bb0 <_pipeisclosed>
  800e80:	83 c4 10             	add    $0x10,%esp
}
  800e83:	c9                   	leave  
  800e84:	c3                   	ret    

00800e85 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e85:	55                   	push   %ebp
  800e86:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e88:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8d:	5d                   	pop    %ebp
  800e8e:	c3                   	ret    

00800e8f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e8f:	55                   	push   %ebp
  800e90:	89 e5                	mov    %esp,%ebp
  800e92:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e95:	68 d6 1e 80 00       	push   $0x801ed6
  800e9a:	ff 75 0c             	pushl  0xc(%ebp)
  800e9d:	e8 5a 08 00 00       	call   8016fc <strcpy>
	return 0;
}
  800ea2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea7:	c9                   	leave  
  800ea8:	c3                   	ret    

00800ea9 <devcons_write>:
{
  800ea9:	55                   	push   %ebp
  800eaa:	89 e5                	mov    %esp,%ebp
  800eac:	57                   	push   %edi
  800ead:	56                   	push   %esi
  800eae:	53                   	push   %ebx
  800eaf:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800eb5:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800eba:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800ec0:	eb 2f                	jmp    800ef1 <devcons_write+0x48>
		m = n - tot;
  800ec2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ec5:	29 f3                	sub    %esi,%ebx
  800ec7:	83 fb 7f             	cmp    $0x7f,%ebx
  800eca:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800ecf:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800ed2:	83 ec 04             	sub    $0x4,%esp
  800ed5:	53                   	push   %ebx
  800ed6:	89 f0                	mov    %esi,%eax
  800ed8:	03 45 0c             	add    0xc(%ebp),%eax
  800edb:	50                   	push   %eax
  800edc:	57                   	push   %edi
  800edd:	e8 a8 09 00 00       	call   80188a <memmove>
		sys_cputs(buf, m);
  800ee2:	83 c4 08             	add    $0x8,%esp
  800ee5:	53                   	push   %ebx
  800ee6:	57                   	push   %edi
  800ee7:	e8 bb f1 ff ff       	call   8000a7 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800eec:	01 de                	add    %ebx,%esi
  800eee:	83 c4 10             	add    $0x10,%esp
  800ef1:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ef4:	72 cc                	jb     800ec2 <devcons_write+0x19>
}
  800ef6:	89 f0                	mov    %esi,%eax
  800ef8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800efb:	5b                   	pop    %ebx
  800efc:	5e                   	pop    %esi
  800efd:	5f                   	pop    %edi
  800efe:	5d                   	pop    %ebp
  800eff:	c3                   	ret    

00800f00 <devcons_read>:
{
  800f00:	55                   	push   %ebp
  800f01:	89 e5                	mov    %esp,%ebp
  800f03:	83 ec 08             	sub    $0x8,%esp
  800f06:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800f0b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f0f:	75 07                	jne    800f18 <devcons_read+0x18>
}
  800f11:	c9                   	leave  
  800f12:	c3                   	ret    
		sys_yield();
  800f13:	e8 2c f2 ff ff       	call   800144 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  800f18:	e8 a8 f1 ff ff       	call   8000c5 <sys_cgetc>
  800f1d:	85 c0                	test   %eax,%eax
  800f1f:	74 f2                	je     800f13 <devcons_read+0x13>
	if (c < 0)
  800f21:	85 c0                	test   %eax,%eax
  800f23:	78 ec                	js     800f11 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  800f25:	83 f8 04             	cmp    $0x4,%eax
  800f28:	74 0c                	je     800f36 <devcons_read+0x36>
	*(char*)vbuf = c;
  800f2a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f2d:	88 02                	mov    %al,(%edx)
	return 1;
  800f2f:	b8 01 00 00 00       	mov    $0x1,%eax
  800f34:	eb db                	jmp    800f11 <devcons_read+0x11>
		return 0;
  800f36:	b8 00 00 00 00       	mov    $0x0,%eax
  800f3b:	eb d4                	jmp    800f11 <devcons_read+0x11>

00800f3d <cputchar>:
{
  800f3d:	55                   	push   %ebp
  800f3e:	89 e5                	mov    %esp,%ebp
  800f40:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f43:	8b 45 08             	mov    0x8(%ebp),%eax
  800f46:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800f49:	6a 01                	push   $0x1
  800f4b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f4e:	50                   	push   %eax
  800f4f:	e8 53 f1 ff ff       	call   8000a7 <sys_cputs>
}
  800f54:	83 c4 10             	add    $0x10,%esp
  800f57:	c9                   	leave  
  800f58:	c3                   	ret    

00800f59 <getchar>:
{
  800f59:	55                   	push   %ebp
  800f5a:	89 e5                	mov    %esp,%ebp
  800f5c:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800f5f:	6a 01                	push   $0x1
  800f61:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f64:	50                   	push   %eax
  800f65:	6a 00                	push   $0x0
  800f67:	e8 cf f6 ff ff       	call   80063b <read>
	if (r < 0)
  800f6c:	83 c4 10             	add    $0x10,%esp
  800f6f:	85 c0                	test   %eax,%eax
  800f71:	78 08                	js     800f7b <getchar+0x22>
	if (r < 1)
  800f73:	85 c0                	test   %eax,%eax
  800f75:	7e 06                	jle    800f7d <getchar+0x24>
	return c;
  800f77:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800f7b:	c9                   	leave  
  800f7c:	c3                   	ret    
		return -E_EOF;
  800f7d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800f82:	eb f7                	jmp    800f7b <getchar+0x22>

00800f84 <iscons>:
{
  800f84:	55                   	push   %ebp
  800f85:	89 e5                	mov    %esp,%ebp
  800f87:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f8a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f8d:	50                   	push   %eax
  800f8e:	ff 75 08             	pushl  0x8(%ebp)
  800f91:	e8 34 f4 ff ff       	call   8003ca <fd_lookup>
  800f96:	83 c4 10             	add    $0x10,%esp
  800f99:	85 c0                	test   %eax,%eax
  800f9b:	78 11                	js     800fae <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  800f9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fa0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fa6:	39 10                	cmp    %edx,(%eax)
  800fa8:	0f 94 c0             	sete   %al
  800fab:	0f b6 c0             	movzbl %al,%eax
}
  800fae:	c9                   	leave  
  800faf:	c3                   	ret    

00800fb0 <opencons>:
{
  800fb0:	55                   	push   %ebp
  800fb1:	89 e5                	mov    %esp,%ebp
  800fb3:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800fb6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fb9:	50                   	push   %eax
  800fba:	e8 bc f3 ff ff       	call   80037b <fd_alloc>
  800fbf:	83 c4 10             	add    $0x10,%esp
  800fc2:	85 c0                	test   %eax,%eax
  800fc4:	78 3a                	js     801000 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fc6:	83 ec 04             	sub    $0x4,%esp
  800fc9:	68 07 04 00 00       	push   $0x407
  800fce:	ff 75 f4             	pushl  -0xc(%ebp)
  800fd1:	6a 00                	push   $0x0
  800fd3:	e8 8b f1 ff ff       	call   800163 <sys_page_alloc>
  800fd8:	83 c4 10             	add    $0x10,%esp
  800fdb:	85 c0                	test   %eax,%eax
  800fdd:	78 21                	js     801000 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  800fdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fe2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fe8:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800fea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fed:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800ff4:	83 ec 0c             	sub    $0xc,%esp
  800ff7:	50                   	push   %eax
  800ff8:	e8 57 f3 ff ff       	call   800354 <fd2num>
  800ffd:	83 c4 10             	add    $0x10,%esp
}
  801000:	c9                   	leave  
  801001:	c3                   	ret    

00801002 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801002:	55                   	push   %ebp
  801003:	89 e5                	mov    %esp,%ebp
  801005:	56                   	push   %esi
  801006:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801007:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80100a:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801010:	e8 10 f1 ff ff       	call   800125 <sys_getenvid>
  801015:	83 ec 0c             	sub    $0xc,%esp
  801018:	ff 75 0c             	pushl  0xc(%ebp)
  80101b:	ff 75 08             	pushl  0x8(%ebp)
  80101e:	56                   	push   %esi
  80101f:	50                   	push   %eax
  801020:	68 e4 1e 80 00       	push   $0x801ee4
  801025:	e8 b3 00 00 00       	call   8010dd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80102a:	83 c4 18             	add    $0x18,%esp
  80102d:	53                   	push   %ebx
  80102e:	ff 75 10             	pushl  0x10(%ebp)
  801031:	e8 56 00 00 00       	call   80108c <vcprintf>
	cprintf("\n");
  801036:	c7 04 24 cf 1e 80 00 	movl   $0x801ecf,(%esp)
  80103d:	e8 9b 00 00 00       	call   8010dd <cprintf>
  801042:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801045:	cc                   	int3   
  801046:	eb fd                	jmp    801045 <_panic+0x43>

00801048 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801048:	55                   	push   %ebp
  801049:	89 e5                	mov    %esp,%ebp
  80104b:	53                   	push   %ebx
  80104c:	83 ec 04             	sub    $0x4,%esp
  80104f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801052:	8b 13                	mov    (%ebx),%edx
  801054:	8d 42 01             	lea    0x1(%edx),%eax
  801057:	89 03                	mov    %eax,(%ebx)
  801059:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80105c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801060:	3d ff 00 00 00       	cmp    $0xff,%eax
  801065:	74 09                	je     801070 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801067:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80106b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80106e:	c9                   	leave  
  80106f:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801070:	83 ec 08             	sub    $0x8,%esp
  801073:	68 ff 00 00 00       	push   $0xff
  801078:	8d 43 08             	lea    0x8(%ebx),%eax
  80107b:	50                   	push   %eax
  80107c:	e8 26 f0 ff ff       	call   8000a7 <sys_cputs>
		b->idx = 0;
  801081:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801087:	83 c4 10             	add    $0x10,%esp
  80108a:	eb db                	jmp    801067 <putch+0x1f>

0080108c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80108c:	55                   	push   %ebp
  80108d:	89 e5                	mov    %esp,%ebp
  80108f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801095:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80109c:	00 00 00 
	b.cnt = 0;
  80109f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010a6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010a9:	ff 75 0c             	pushl  0xc(%ebp)
  8010ac:	ff 75 08             	pushl  0x8(%ebp)
  8010af:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010b5:	50                   	push   %eax
  8010b6:	68 48 10 80 00       	push   $0x801048
  8010bb:	e8 1a 01 00 00       	call   8011da <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010c0:	83 c4 08             	add    $0x8,%esp
  8010c3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010c9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010cf:	50                   	push   %eax
  8010d0:	e8 d2 ef ff ff       	call   8000a7 <sys_cputs>

	return b.cnt;
}
  8010d5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010db:	c9                   	leave  
  8010dc:	c3                   	ret    

008010dd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010dd:	55                   	push   %ebp
  8010de:	89 e5                	mov    %esp,%ebp
  8010e0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010e3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010e6:	50                   	push   %eax
  8010e7:	ff 75 08             	pushl  0x8(%ebp)
  8010ea:	e8 9d ff ff ff       	call   80108c <vcprintf>
	va_end(ap);

	return cnt;
}
  8010ef:	c9                   	leave  
  8010f0:	c3                   	ret    

008010f1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010f1:	55                   	push   %ebp
  8010f2:	89 e5                	mov    %esp,%ebp
  8010f4:	57                   	push   %edi
  8010f5:	56                   	push   %esi
  8010f6:	53                   	push   %ebx
  8010f7:	83 ec 1c             	sub    $0x1c,%esp
  8010fa:	89 c7                	mov    %eax,%edi
  8010fc:	89 d6                	mov    %edx,%esi
  8010fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801101:	8b 55 0c             	mov    0xc(%ebp),%edx
  801104:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801107:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80110a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80110d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801112:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801115:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801118:	39 d3                	cmp    %edx,%ebx
  80111a:	72 05                	jb     801121 <printnum+0x30>
  80111c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80111f:	77 7a                	ja     80119b <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801121:	83 ec 0c             	sub    $0xc,%esp
  801124:	ff 75 18             	pushl  0x18(%ebp)
  801127:	8b 45 14             	mov    0x14(%ebp),%eax
  80112a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80112d:	53                   	push   %ebx
  80112e:	ff 75 10             	pushl  0x10(%ebp)
  801131:	83 ec 08             	sub    $0x8,%esp
  801134:	ff 75 e4             	pushl  -0x1c(%ebp)
  801137:	ff 75 e0             	pushl  -0x20(%ebp)
  80113a:	ff 75 dc             	pushl  -0x24(%ebp)
  80113d:	ff 75 d8             	pushl  -0x28(%ebp)
  801140:	e8 2b 0a 00 00       	call   801b70 <__udivdi3>
  801145:	83 c4 18             	add    $0x18,%esp
  801148:	52                   	push   %edx
  801149:	50                   	push   %eax
  80114a:	89 f2                	mov    %esi,%edx
  80114c:	89 f8                	mov    %edi,%eax
  80114e:	e8 9e ff ff ff       	call   8010f1 <printnum>
  801153:	83 c4 20             	add    $0x20,%esp
  801156:	eb 13                	jmp    80116b <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801158:	83 ec 08             	sub    $0x8,%esp
  80115b:	56                   	push   %esi
  80115c:	ff 75 18             	pushl  0x18(%ebp)
  80115f:	ff d7                	call   *%edi
  801161:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801164:	83 eb 01             	sub    $0x1,%ebx
  801167:	85 db                	test   %ebx,%ebx
  801169:	7f ed                	jg     801158 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80116b:	83 ec 08             	sub    $0x8,%esp
  80116e:	56                   	push   %esi
  80116f:	83 ec 04             	sub    $0x4,%esp
  801172:	ff 75 e4             	pushl  -0x1c(%ebp)
  801175:	ff 75 e0             	pushl  -0x20(%ebp)
  801178:	ff 75 dc             	pushl  -0x24(%ebp)
  80117b:	ff 75 d8             	pushl  -0x28(%ebp)
  80117e:	e8 0d 0b 00 00       	call   801c90 <__umoddi3>
  801183:	83 c4 14             	add    $0x14,%esp
  801186:	0f be 80 07 1f 80 00 	movsbl 0x801f07(%eax),%eax
  80118d:	50                   	push   %eax
  80118e:	ff d7                	call   *%edi
}
  801190:	83 c4 10             	add    $0x10,%esp
  801193:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801196:	5b                   	pop    %ebx
  801197:	5e                   	pop    %esi
  801198:	5f                   	pop    %edi
  801199:	5d                   	pop    %ebp
  80119a:	c3                   	ret    
  80119b:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80119e:	eb c4                	jmp    801164 <printnum+0x73>

008011a0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011a0:	55                   	push   %ebp
  8011a1:	89 e5                	mov    %esp,%ebp
  8011a3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011a6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011aa:	8b 10                	mov    (%eax),%edx
  8011ac:	3b 50 04             	cmp    0x4(%eax),%edx
  8011af:	73 0a                	jae    8011bb <sprintputch+0x1b>
		*b->buf++ = ch;
  8011b1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011b4:	89 08                	mov    %ecx,(%eax)
  8011b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b9:	88 02                	mov    %al,(%edx)
}
  8011bb:	5d                   	pop    %ebp
  8011bc:	c3                   	ret    

008011bd <printfmt>:
{
  8011bd:	55                   	push   %ebp
  8011be:	89 e5                	mov    %esp,%ebp
  8011c0:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8011c3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011c6:	50                   	push   %eax
  8011c7:	ff 75 10             	pushl  0x10(%ebp)
  8011ca:	ff 75 0c             	pushl  0xc(%ebp)
  8011cd:	ff 75 08             	pushl  0x8(%ebp)
  8011d0:	e8 05 00 00 00       	call   8011da <vprintfmt>
}
  8011d5:	83 c4 10             	add    $0x10,%esp
  8011d8:	c9                   	leave  
  8011d9:	c3                   	ret    

008011da <vprintfmt>:
{
  8011da:	55                   	push   %ebp
  8011db:	89 e5                	mov    %esp,%ebp
  8011dd:	57                   	push   %edi
  8011de:	56                   	push   %esi
  8011df:	53                   	push   %ebx
  8011e0:	83 ec 2c             	sub    $0x2c,%esp
  8011e3:	8b 75 08             	mov    0x8(%ebp),%esi
  8011e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8011e9:	8b 7d 10             	mov    0x10(%ebp),%edi
  8011ec:	e9 c1 03 00 00       	jmp    8015b2 <vprintfmt+0x3d8>
		padc = ' ';
  8011f1:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8011f5:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8011fc:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  801203:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80120a:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80120f:	8d 47 01             	lea    0x1(%edi),%eax
  801212:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801215:	0f b6 17             	movzbl (%edi),%edx
  801218:	8d 42 dd             	lea    -0x23(%edx),%eax
  80121b:	3c 55                	cmp    $0x55,%al
  80121d:	0f 87 12 04 00 00    	ja     801635 <vprintfmt+0x45b>
  801223:	0f b6 c0             	movzbl %al,%eax
  801226:	ff 24 85 40 20 80 00 	jmp    *0x802040(,%eax,4)
  80122d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801230:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  801234:	eb d9                	jmp    80120f <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  801236:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  801239:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80123d:	eb d0                	jmp    80120f <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80123f:	0f b6 d2             	movzbl %dl,%edx
  801242:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801245:	b8 00 00 00 00       	mov    $0x0,%eax
  80124a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80124d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801250:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801254:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801257:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80125a:	83 f9 09             	cmp    $0x9,%ecx
  80125d:	77 55                	ja     8012b4 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  80125f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801262:	eb e9                	jmp    80124d <vprintfmt+0x73>
			precision = va_arg(ap, int);
  801264:	8b 45 14             	mov    0x14(%ebp),%eax
  801267:	8b 00                	mov    (%eax),%eax
  801269:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80126c:	8b 45 14             	mov    0x14(%ebp),%eax
  80126f:	8d 40 04             	lea    0x4(%eax),%eax
  801272:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801275:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801278:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80127c:	79 91                	jns    80120f <vprintfmt+0x35>
				width = precision, precision = -1;
  80127e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801281:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801284:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80128b:	eb 82                	jmp    80120f <vprintfmt+0x35>
  80128d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801290:	85 c0                	test   %eax,%eax
  801292:	ba 00 00 00 00       	mov    $0x0,%edx
  801297:	0f 49 d0             	cmovns %eax,%edx
  80129a:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80129d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012a0:	e9 6a ff ff ff       	jmp    80120f <vprintfmt+0x35>
  8012a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8012a8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012af:	e9 5b ff ff ff       	jmp    80120f <vprintfmt+0x35>
  8012b4:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8012b7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012ba:	eb bc                	jmp    801278 <vprintfmt+0x9e>
			lflag++;
  8012bc:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8012c2:	e9 48 ff ff ff       	jmp    80120f <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8012c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8012ca:	8d 78 04             	lea    0x4(%eax),%edi
  8012cd:	83 ec 08             	sub    $0x8,%esp
  8012d0:	53                   	push   %ebx
  8012d1:	ff 30                	pushl  (%eax)
  8012d3:	ff d6                	call   *%esi
			break;
  8012d5:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8012d8:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8012db:	e9 cf 02 00 00       	jmp    8015af <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8012e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8012e3:	8d 78 04             	lea    0x4(%eax),%edi
  8012e6:	8b 00                	mov    (%eax),%eax
  8012e8:	99                   	cltd   
  8012e9:	31 d0                	xor    %edx,%eax
  8012eb:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8012ed:	83 f8 0f             	cmp    $0xf,%eax
  8012f0:	7f 23                	jg     801315 <vprintfmt+0x13b>
  8012f2:	8b 14 85 a0 21 80 00 	mov    0x8021a0(,%eax,4),%edx
  8012f9:	85 d2                	test   %edx,%edx
  8012fb:	74 18                	je     801315 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8012fd:	52                   	push   %edx
  8012fe:	68 9d 1e 80 00       	push   $0x801e9d
  801303:	53                   	push   %ebx
  801304:	56                   	push   %esi
  801305:	e8 b3 fe ff ff       	call   8011bd <printfmt>
  80130a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80130d:	89 7d 14             	mov    %edi,0x14(%ebp)
  801310:	e9 9a 02 00 00       	jmp    8015af <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  801315:	50                   	push   %eax
  801316:	68 1f 1f 80 00       	push   $0x801f1f
  80131b:	53                   	push   %ebx
  80131c:	56                   	push   %esi
  80131d:	e8 9b fe ff ff       	call   8011bd <printfmt>
  801322:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801325:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  801328:	e9 82 02 00 00       	jmp    8015af <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  80132d:	8b 45 14             	mov    0x14(%ebp),%eax
  801330:	83 c0 04             	add    $0x4,%eax
  801333:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801336:	8b 45 14             	mov    0x14(%ebp),%eax
  801339:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80133b:	85 ff                	test   %edi,%edi
  80133d:	b8 18 1f 80 00       	mov    $0x801f18,%eax
  801342:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801345:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801349:	0f 8e bd 00 00 00    	jle    80140c <vprintfmt+0x232>
  80134f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801353:	75 0e                	jne    801363 <vprintfmt+0x189>
  801355:	89 75 08             	mov    %esi,0x8(%ebp)
  801358:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80135b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80135e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801361:	eb 6d                	jmp    8013d0 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  801363:	83 ec 08             	sub    $0x8,%esp
  801366:	ff 75 d0             	pushl  -0x30(%ebp)
  801369:	57                   	push   %edi
  80136a:	e8 6e 03 00 00       	call   8016dd <strnlen>
  80136f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801372:	29 c1                	sub    %eax,%ecx
  801374:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  801377:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80137a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80137e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801381:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801384:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  801386:	eb 0f                	jmp    801397 <vprintfmt+0x1bd>
					putch(padc, putdat);
  801388:	83 ec 08             	sub    $0x8,%esp
  80138b:	53                   	push   %ebx
  80138c:	ff 75 e0             	pushl  -0x20(%ebp)
  80138f:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  801391:	83 ef 01             	sub    $0x1,%edi
  801394:	83 c4 10             	add    $0x10,%esp
  801397:	85 ff                	test   %edi,%edi
  801399:	7f ed                	jg     801388 <vprintfmt+0x1ae>
  80139b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80139e:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8013a1:	85 c9                	test   %ecx,%ecx
  8013a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8013a8:	0f 49 c1             	cmovns %ecx,%eax
  8013ab:	29 c1                	sub    %eax,%ecx
  8013ad:	89 75 08             	mov    %esi,0x8(%ebp)
  8013b0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8013b3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8013b6:	89 cb                	mov    %ecx,%ebx
  8013b8:	eb 16                	jmp    8013d0 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8013ba:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8013be:	75 31                	jne    8013f1 <vprintfmt+0x217>
					putch(ch, putdat);
  8013c0:	83 ec 08             	sub    $0x8,%esp
  8013c3:	ff 75 0c             	pushl  0xc(%ebp)
  8013c6:	50                   	push   %eax
  8013c7:	ff 55 08             	call   *0x8(%ebp)
  8013ca:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8013cd:	83 eb 01             	sub    $0x1,%ebx
  8013d0:	83 c7 01             	add    $0x1,%edi
  8013d3:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8013d7:	0f be c2             	movsbl %dl,%eax
  8013da:	85 c0                	test   %eax,%eax
  8013dc:	74 59                	je     801437 <vprintfmt+0x25d>
  8013de:	85 f6                	test   %esi,%esi
  8013e0:	78 d8                	js     8013ba <vprintfmt+0x1e0>
  8013e2:	83 ee 01             	sub    $0x1,%esi
  8013e5:	79 d3                	jns    8013ba <vprintfmt+0x1e0>
  8013e7:	89 df                	mov    %ebx,%edi
  8013e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8013ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8013ef:	eb 37                	jmp    801428 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8013f1:	0f be d2             	movsbl %dl,%edx
  8013f4:	83 ea 20             	sub    $0x20,%edx
  8013f7:	83 fa 5e             	cmp    $0x5e,%edx
  8013fa:	76 c4                	jbe    8013c0 <vprintfmt+0x1e6>
					putch('?', putdat);
  8013fc:	83 ec 08             	sub    $0x8,%esp
  8013ff:	ff 75 0c             	pushl  0xc(%ebp)
  801402:	6a 3f                	push   $0x3f
  801404:	ff 55 08             	call   *0x8(%ebp)
  801407:	83 c4 10             	add    $0x10,%esp
  80140a:	eb c1                	jmp    8013cd <vprintfmt+0x1f3>
  80140c:	89 75 08             	mov    %esi,0x8(%ebp)
  80140f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801412:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801415:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801418:	eb b6                	jmp    8013d0 <vprintfmt+0x1f6>
				putch(' ', putdat);
  80141a:	83 ec 08             	sub    $0x8,%esp
  80141d:	53                   	push   %ebx
  80141e:	6a 20                	push   $0x20
  801420:	ff d6                	call   *%esi
			for (; width > 0; width--)
  801422:	83 ef 01             	sub    $0x1,%edi
  801425:	83 c4 10             	add    $0x10,%esp
  801428:	85 ff                	test   %edi,%edi
  80142a:	7f ee                	jg     80141a <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  80142c:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80142f:	89 45 14             	mov    %eax,0x14(%ebp)
  801432:	e9 78 01 00 00       	jmp    8015af <vprintfmt+0x3d5>
  801437:	89 df                	mov    %ebx,%edi
  801439:	8b 75 08             	mov    0x8(%ebp),%esi
  80143c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80143f:	eb e7                	jmp    801428 <vprintfmt+0x24e>
	if (lflag >= 2)
  801441:	83 f9 01             	cmp    $0x1,%ecx
  801444:	7e 3f                	jle    801485 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  801446:	8b 45 14             	mov    0x14(%ebp),%eax
  801449:	8b 50 04             	mov    0x4(%eax),%edx
  80144c:	8b 00                	mov    (%eax),%eax
  80144e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801451:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801454:	8b 45 14             	mov    0x14(%ebp),%eax
  801457:	8d 40 08             	lea    0x8(%eax),%eax
  80145a:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80145d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801461:	79 5c                	jns    8014bf <vprintfmt+0x2e5>
				putch('-', putdat);
  801463:	83 ec 08             	sub    $0x8,%esp
  801466:	53                   	push   %ebx
  801467:	6a 2d                	push   $0x2d
  801469:	ff d6                	call   *%esi
				num = -(long long) num;
  80146b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80146e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801471:	f7 da                	neg    %edx
  801473:	83 d1 00             	adc    $0x0,%ecx
  801476:	f7 d9                	neg    %ecx
  801478:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80147b:	b8 0a 00 00 00       	mov    $0xa,%eax
  801480:	e9 10 01 00 00       	jmp    801595 <vprintfmt+0x3bb>
	else if (lflag)
  801485:	85 c9                	test   %ecx,%ecx
  801487:	75 1b                	jne    8014a4 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  801489:	8b 45 14             	mov    0x14(%ebp),%eax
  80148c:	8b 00                	mov    (%eax),%eax
  80148e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801491:	89 c1                	mov    %eax,%ecx
  801493:	c1 f9 1f             	sar    $0x1f,%ecx
  801496:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801499:	8b 45 14             	mov    0x14(%ebp),%eax
  80149c:	8d 40 04             	lea    0x4(%eax),%eax
  80149f:	89 45 14             	mov    %eax,0x14(%ebp)
  8014a2:	eb b9                	jmp    80145d <vprintfmt+0x283>
		return va_arg(*ap, long);
  8014a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8014a7:	8b 00                	mov    (%eax),%eax
  8014a9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014ac:	89 c1                	mov    %eax,%ecx
  8014ae:	c1 f9 1f             	sar    $0x1f,%ecx
  8014b1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8014b7:	8d 40 04             	lea    0x4(%eax),%eax
  8014ba:	89 45 14             	mov    %eax,0x14(%ebp)
  8014bd:	eb 9e                	jmp    80145d <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8014bf:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014c2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8014c5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014ca:	e9 c6 00 00 00       	jmp    801595 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8014cf:	83 f9 01             	cmp    $0x1,%ecx
  8014d2:	7e 18                	jle    8014ec <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8014d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8014d7:	8b 10                	mov    (%eax),%edx
  8014d9:	8b 48 04             	mov    0x4(%eax),%ecx
  8014dc:	8d 40 08             	lea    0x8(%eax),%eax
  8014df:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8014e2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014e7:	e9 a9 00 00 00       	jmp    801595 <vprintfmt+0x3bb>
	else if (lflag)
  8014ec:	85 c9                	test   %ecx,%ecx
  8014ee:	75 1a                	jne    80150a <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  8014f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f3:	8b 10                	mov    (%eax),%edx
  8014f5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014fa:	8d 40 04             	lea    0x4(%eax),%eax
  8014fd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801500:	b8 0a 00 00 00       	mov    $0xa,%eax
  801505:	e9 8b 00 00 00       	jmp    801595 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80150a:	8b 45 14             	mov    0x14(%ebp),%eax
  80150d:	8b 10                	mov    (%eax),%edx
  80150f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801514:	8d 40 04             	lea    0x4(%eax),%eax
  801517:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80151a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80151f:	eb 74                	jmp    801595 <vprintfmt+0x3bb>
	if (lflag >= 2)
  801521:	83 f9 01             	cmp    $0x1,%ecx
  801524:	7e 15                	jle    80153b <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  801526:	8b 45 14             	mov    0x14(%ebp),%eax
  801529:	8b 10                	mov    (%eax),%edx
  80152b:	8b 48 04             	mov    0x4(%eax),%ecx
  80152e:	8d 40 08             	lea    0x8(%eax),%eax
  801531:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801534:	b8 08 00 00 00       	mov    $0x8,%eax
  801539:	eb 5a                	jmp    801595 <vprintfmt+0x3bb>
	else if (lflag)
  80153b:	85 c9                	test   %ecx,%ecx
  80153d:	75 17                	jne    801556 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  80153f:	8b 45 14             	mov    0x14(%ebp),%eax
  801542:	8b 10                	mov    (%eax),%edx
  801544:	b9 00 00 00 00       	mov    $0x0,%ecx
  801549:	8d 40 04             	lea    0x4(%eax),%eax
  80154c:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80154f:	b8 08 00 00 00       	mov    $0x8,%eax
  801554:	eb 3f                	jmp    801595 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  801556:	8b 45 14             	mov    0x14(%ebp),%eax
  801559:	8b 10                	mov    (%eax),%edx
  80155b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801560:	8d 40 04             	lea    0x4(%eax),%eax
  801563:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801566:	b8 08 00 00 00       	mov    $0x8,%eax
  80156b:	eb 28                	jmp    801595 <vprintfmt+0x3bb>
			putch('0', putdat);
  80156d:	83 ec 08             	sub    $0x8,%esp
  801570:	53                   	push   %ebx
  801571:	6a 30                	push   $0x30
  801573:	ff d6                	call   *%esi
			putch('x', putdat);
  801575:	83 c4 08             	add    $0x8,%esp
  801578:	53                   	push   %ebx
  801579:	6a 78                	push   $0x78
  80157b:	ff d6                	call   *%esi
			num = (unsigned long long)
  80157d:	8b 45 14             	mov    0x14(%ebp),%eax
  801580:	8b 10                	mov    (%eax),%edx
  801582:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801587:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80158a:	8d 40 04             	lea    0x4(%eax),%eax
  80158d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801590:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  801595:	83 ec 0c             	sub    $0xc,%esp
  801598:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80159c:	57                   	push   %edi
  80159d:	ff 75 e0             	pushl  -0x20(%ebp)
  8015a0:	50                   	push   %eax
  8015a1:	51                   	push   %ecx
  8015a2:	52                   	push   %edx
  8015a3:	89 da                	mov    %ebx,%edx
  8015a5:	89 f0                	mov    %esi,%eax
  8015a7:	e8 45 fb ff ff       	call   8010f1 <printnum>
			break;
  8015ac:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8015af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8015b2:	83 c7 01             	add    $0x1,%edi
  8015b5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8015b9:	83 f8 25             	cmp    $0x25,%eax
  8015bc:	0f 84 2f fc ff ff    	je     8011f1 <vprintfmt+0x17>
			if (ch == '\0')
  8015c2:	85 c0                	test   %eax,%eax
  8015c4:	0f 84 8b 00 00 00    	je     801655 <vprintfmt+0x47b>
			putch(ch, putdat);
  8015ca:	83 ec 08             	sub    $0x8,%esp
  8015cd:	53                   	push   %ebx
  8015ce:	50                   	push   %eax
  8015cf:	ff d6                	call   *%esi
  8015d1:	83 c4 10             	add    $0x10,%esp
  8015d4:	eb dc                	jmp    8015b2 <vprintfmt+0x3d8>
	if (lflag >= 2)
  8015d6:	83 f9 01             	cmp    $0x1,%ecx
  8015d9:	7e 15                	jle    8015f0 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  8015db:	8b 45 14             	mov    0x14(%ebp),%eax
  8015de:	8b 10                	mov    (%eax),%edx
  8015e0:	8b 48 04             	mov    0x4(%eax),%ecx
  8015e3:	8d 40 08             	lea    0x8(%eax),%eax
  8015e6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015e9:	b8 10 00 00 00       	mov    $0x10,%eax
  8015ee:	eb a5                	jmp    801595 <vprintfmt+0x3bb>
	else if (lflag)
  8015f0:	85 c9                	test   %ecx,%ecx
  8015f2:	75 17                	jne    80160b <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  8015f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8015f7:	8b 10                	mov    (%eax),%edx
  8015f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015fe:	8d 40 04             	lea    0x4(%eax),%eax
  801601:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801604:	b8 10 00 00 00       	mov    $0x10,%eax
  801609:	eb 8a                	jmp    801595 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80160b:	8b 45 14             	mov    0x14(%ebp),%eax
  80160e:	8b 10                	mov    (%eax),%edx
  801610:	b9 00 00 00 00       	mov    $0x0,%ecx
  801615:	8d 40 04             	lea    0x4(%eax),%eax
  801618:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80161b:	b8 10 00 00 00       	mov    $0x10,%eax
  801620:	e9 70 ff ff ff       	jmp    801595 <vprintfmt+0x3bb>
			putch(ch, putdat);
  801625:	83 ec 08             	sub    $0x8,%esp
  801628:	53                   	push   %ebx
  801629:	6a 25                	push   $0x25
  80162b:	ff d6                	call   *%esi
			break;
  80162d:	83 c4 10             	add    $0x10,%esp
  801630:	e9 7a ff ff ff       	jmp    8015af <vprintfmt+0x3d5>
			putch('%', putdat);
  801635:	83 ec 08             	sub    $0x8,%esp
  801638:	53                   	push   %ebx
  801639:	6a 25                	push   $0x25
  80163b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80163d:	83 c4 10             	add    $0x10,%esp
  801640:	89 f8                	mov    %edi,%eax
  801642:	eb 03                	jmp    801647 <vprintfmt+0x46d>
  801644:	83 e8 01             	sub    $0x1,%eax
  801647:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80164b:	75 f7                	jne    801644 <vprintfmt+0x46a>
  80164d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801650:	e9 5a ff ff ff       	jmp    8015af <vprintfmt+0x3d5>
}
  801655:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801658:	5b                   	pop    %ebx
  801659:	5e                   	pop    %esi
  80165a:	5f                   	pop    %edi
  80165b:	5d                   	pop    %ebp
  80165c:	c3                   	ret    

0080165d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80165d:	55                   	push   %ebp
  80165e:	89 e5                	mov    %esp,%ebp
  801660:	83 ec 18             	sub    $0x18,%esp
  801663:	8b 45 08             	mov    0x8(%ebp),%eax
  801666:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801669:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80166c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801670:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801673:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80167a:	85 c0                	test   %eax,%eax
  80167c:	74 26                	je     8016a4 <vsnprintf+0x47>
  80167e:	85 d2                	test   %edx,%edx
  801680:	7e 22                	jle    8016a4 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801682:	ff 75 14             	pushl  0x14(%ebp)
  801685:	ff 75 10             	pushl  0x10(%ebp)
  801688:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80168b:	50                   	push   %eax
  80168c:	68 a0 11 80 00       	push   $0x8011a0
  801691:	e8 44 fb ff ff       	call   8011da <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801696:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801699:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80169c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80169f:	83 c4 10             	add    $0x10,%esp
}
  8016a2:	c9                   	leave  
  8016a3:	c3                   	ret    
		return -E_INVAL;
  8016a4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016a9:	eb f7                	jmp    8016a2 <vsnprintf+0x45>

008016ab <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016ab:	55                   	push   %ebp
  8016ac:	89 e5                	mov    %esp,%ebp
  8016ae:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016b1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016b4:	50                   	push   %eax
  8016b5:	ff 75 10             	pushl  0x10(%ebp)
  8016b8:	ff 75 0c             	pushl  0xc(%ebp)
  8016bb:	ff 75 08             	pushl  0x8(%ebp)
  8016be:	e8 9a ff ff ff       	call   80165d <vsnprintf>
	va_end(ap);

	return rc;
}
  8016c3:	c9                   	leave  
  8016c4:	c3                   	ret    

008016c5 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016c5:	55                   	push   %ebp
  8016c6:	89 e5                	mov    %esp,%ebp
  8016c8:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8016d0:	eb 03                	jmp    8016d5 <strlen+0x10>
		n++;
  8016d2:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8016d5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016d9:	75 f7                	jne    8016d2 <strlen+0xd>
	return n;
}
  8016db:	5d                   	pop    %ebp
  8016dc:	c3                   	ret    

008016dd <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016dd:	55                   	push   %ebp
  8016de:	89 e5                	mov    %esp,%ebp
  8016e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016e3:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8016eb:	eb 03                	jmp    8016f0 <strnlen+0x13>
		n++;
  8016ed:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016f0:	39 d0                	cmp    %edx,%eax
  8016f2:	74 06                	je     8016fa <strnlen+0x1d>
  8016f4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8016f8:	75 f3                	jne    8016ed <strnlen+0x10>
	return n;
}
  8016fa:	5d                   	pop    %ebp
  8016fb:	c3                   	ret    

008016fc <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016fc:	55                   	push   %ebp
  8016fd:	89 e5                	mov    %esp,%ebp
  8016ff:	53                   	push   %ebx
  801700:	8b 45 08             	mov    0x8(%ebp),%eax
  801703:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801706:	89 c2                	mov    %eax,%edx
  801708:	83 c1 01             	add    $0x1,%ecx
  80170b:	83 c2 01             	add    $0x1,%edx
  80170e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801712:	88 5a ff             	mov    %bl,-0x1(%edx)
  801715:	84 db                	test   %bl,%bl
  801717:	75 ef                	jne    801708 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801719:	5b                   	pop    %ebx
  80171a:	5d                   	pop    %ebp
  80171b:	c3                   	ret    

0080171c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80171c:	55                   	push   %ebp
  80171d:	89 e5                	mov    %esp,%ebp
  80171f:	53                   	push   %ebx
  801720:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801723:	53                   	push   %ebx
  801724:	e8 9c ff ff ff       	call   8016c5 <strlen>
  801729:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80172c:	ff 75 0c             	pushl  0xc(%ebp)
  80172f:	01 d8                	add    %ebx,%eax
  801731:	50                   	push   %eax
  801732:	e8 c5 ff ff ff       	call   8016fc <strcpy>
	return dst;
}
  801737:	89 d8                	mov    %ebx,%eax
  801739:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80173c:	c9                   	leave  
  80173d:	c3                   	ret    

0080173e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80173e:	55                   	push   %ebp
  80173f:	89 e5                	mov    %esp,%ebp
  801741:	56                   	push   %esi
  801742:	53                   	push   %ebx
  801743:	8b 75 08             	mov    0x8(%ebp),%esi
  801746:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801749:	89 f3                	mov    %esi,%ebx
  80174b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80174e:	89 f2                	mov    %esi,%edx
  801750:	eb 0f                	jmp    801761 <strncpy+0x23>
		*dst++ = *src;
  801752:	83 c2 01             	add    $0x1,%edx
  801755:	0f b6 01             	movzbl (%ecx),%eax
  801758:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80175b:	80 39 01             	cmpb   $0x1,(%ecx)
  80175e:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  801761:	39 da                	cmp    %ebx,%edx
  801763:	75 ed                	jne    801752 <strncpy+0x14>
	}
	return ret;
}
  801765:	89 f0                	mov    %esi,%eax
  801767:	5b                   	pop    %ebx
  801768:	5e                   	pop    %esi
  801769:	5d                   	pop    %ebp
  80176a:	c3                   	ret    

0080176b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80176b:	55                   	push   %ebp
  80176c:	89 e5                	mov    %esp,%ebp
  80176e:	56                   	push   %esi
  80176f:	53                   	push   %ebx
  801770:	8b 75 08             	mov    0x8(%ebp),%esi
  801773:	8b 55 0c             	mov    0xc(%ebp),%edx
  801776:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801779:	89 f0                	mov    %esi,%eax
  80177b:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80177f:	85 c9                	test   %ecx,%ecx
  801781:	75 0b                	jne    80178e <strlcpy+0x23>
  801783:	eb 17                	jmp    80179c <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801785:	83 c2 01             	add    $0x1,%edx
  801788:	83 c0 01             	add    $0x1,%eax
  80178b:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  80178e:	39 d8                	cmp    %ebx,%eax
  801790:	74 07                	je     801799 <strlcpy+0x2e>
  801792:	0f b6 0a             	movzbl (%edx),%ecx
  801795:	84 c9                	test   %cl,%cl
  801797:	75 ec                	jne    801785 <strlcpy+0x1a>
		*dst = '\0';
  801799:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80179c:	29 f0                	sub    %esi,%eax
}
  80179e:	5b                   	pop    %ebx
  80179f:	5e                   	pop    %esi
  8017a0:	5d                   	pop    %ebp
  8017a1:	c3                   	ret    

008017a2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017a2:	55                   	push   %ebp
  8017a3:	89 e5                	mov    %esp,%ebp
  8017a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017a8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017ab:	eb 06                	jmp    8017b3 <strcmp+0x11>
		p++, q++;
  8017ad:	83 c1 01             	add    $0x1,%ecx
  8017b0:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8017b3:	0f b6 01             	movzbl (%ecx),%eax
  8017b6:	84 c0                	test   %al,%al
  8017b8:	74 04                	je     8017be <strcmp+0x1c>
  8017ba:	3a 02                	cmp    (%edx),%al
  8017bc:	74 ef                	je     8017ad <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017be:	0f b6 c0             	movzbl %al,%eax
  8017c1:	0f b6 12             	movzbl (%edx),%edx
  8017c4:	29 d0                	sub    %edx,%eax
}
  8017c6:	5d                   	pop    %ebp
  8017c7:	c3                   	ret    

008017c8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017c8:	55                   	push   %ebp
  8017c9:	89 e5                	mov    %esp,%ebp
  8017cb:	53                   	push   %ebx
  8017cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017d2:	89 c3                	mov    %eax,%ebx
  8017d4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017d7:	eb 06                	jmp    8017df <strncmp+0x17>
		n--, p++, q++;
  8017d9:	83 c0 01             	add    $0x1,%eax
  8017dc:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8017df:	39 d8                	cmp    %ebx,%eax
  8017e1:	74 16                	je     8017f9 <strncmp+0x31>
  8017e3:	0f b6 08             	movzbl (%eax),%ecx
  8017e6:	84 c9                	test   %cl,%cl
  8017e8:	74 04                	je     8017ee <strncmp+0x26>
  8017ea:	3a 0a                	cmp    (%edx),%cl
  8017ec:	74 eb                	je     8017d9 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017ee:	0f b6 00             	movzbl (%eax),%eax
  8017f1:	0f b6 12             	movzbl (%edx),%edx
  8017f4:	29 d0                	sub    %edx,%eax
}
  8017f6:	5b                   	pop    %ebx
  8017f7:	5d                   	pop    %ebp
  8017f8:	c3                   	ret    
		return 0;
  8017f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8017fe:	eb f6                	jmp    8017f6 <strncmp+0x2e>

00801800 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801800:	55                   	push   %ebp
  801801:	89 e5                	mov    %esp,%ebp
  801803:	8b 45 08             	mov    0x8(%ebp),%eax
  801806:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80180a:	0f b6 10             	movzbl (%eax),%edx
  80180d:	84 d2                	test   %dl,%dl
  80180f:	74 09                	je     80181a <strchr+0x1a>
		if (*s == c)
  801811:	38 ca                	cmp    %cl,%dl
  801813:	74 0a                	je     80181f <strchr+0x1f>
	for (; *s; s++)
  801815:	83 c0 01             	add    $0x1,%eax
  801818:	eb f0                	jmp    80180a <strchr+0xa>
			return (char *) s;
	return 0;
  80181a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80181f:	5d                   	pop    %ebp
  801820:	c3                   	ret    

00801821 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801821:	55                   	push   %ebp
  801822:	89 e5                	mov    %esp,%ebp
  801824:	8b 45 08             	mov    0x8(%ebp),%eax
  801827:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80182b:	eb 03                	jmp    801830 <strfind+0xf>
  80182d:	83 c0 01             	add    $0x1,%eax
  801830:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801833:	38 ca                	cmp    %cl,%dl
  801835:	74 04                	je     80183b <strfind+0x1a>
  801837:	84 d2                	test   %dl,%dl
  801839:	75 f2                	jne    80182d <strfind+0xc>
			break;
	return (char *) s;
}
  80183b:	5d                   	pop    %ebp
  80183c:	c3                   	ret    

0080183d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80183d:	55                   	push   %ebp
  80183e:	89 e5                	mov    %esp,%ebp
  801840:	57                   	push   %edi
  801841:	56                   	push   %esi
  801842:	53                   	push   %ebx
  801843:	8b 7d 08             	mov    0x8(%ebp),%edi
  801846:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801849:	85 c9                	test   %ecx,%ecx
  80184b:	74 13                	je     801860 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80184d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801853:	75 05                	jne    80185a <memset+0x1d>
  801855:	f6 c1 03             	test   $0x3,%cl
  801858:	74 0d                	je     801867 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80185a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80185d:	fc                   	cld    
  80185e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801860:	89 f8                	mov    %edi,%eax
  801862:	5b                   	pop    %ebx
  801863:	5e                   	pop    %esi
  801864:	5f                   	pop    %edi
  801865:	5d                   	pop    %ebp
  801866:	c3                   	ret    
		c &= 0xFF;
  801867:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80186b:	89 d3                	mov    %edx,%ebx
  80186d:	c1 e3 08             	shl    $0x8,%ebx
  801870:	89 d0                	mov    %edx,%eax
  801872:	c1 e0 18             	shl    $0x18,%eax
  801875:	89 d6                	mov    %edx,%esi
  801877:	c1 e6 10             	shl    $0x10,%esi
  80187a:	09 f0                	or     %esi,%eax
  80187c:	09 c2                	or     %eax,%edx
  80187e:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  801880:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801883:	89 d0                	mov    %edx,%eax
  801885:	fc                   	cld    
  801886:	f3 ab                	rep stos %eax,%es:(%edi)
  801888:	eb d6                	jmp    801860 <memset+0x23>

0080188a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80188a:	55                   	push   %ebp
  80188b:	89 e5                	mov    %esp,%ebp
  80188d:	57                   	push   %edi
  80188e:	56                   	push   %esi
  80188f:	8b 45 08             	mov    0x8(%ebp),%eax
  801892:	8b 75 0c             	mov    0xc(%ebp),%esi
  801895:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801898:	39 c6                	cmp    %eax,%esi
  80189a:	73 35                	jae    8018d1 <memmove+0x47>
  80189c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80189f:	39 c2                	cmp    %eax,%edx
  8018a1:	76 2e                	jbe    8018d1 <memmove+0x47>
		s += n;
		d += n;
  8018a3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018a6:	89 d6                	mov    %edx,%esi
  8018a8:	09 fe                	or     %edi,%esi
  8018aa:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018b0:	74 0c                	je     8018be <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8018b2:	83 ef 01             	sub    $0x1,%edi
  8018b5:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8018b8:	fd                   	std    
  8018b9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018bb:	fc                   	cld    
  8018bc:	eb 21                	jmp    8018df <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018be:	f6 c1 03             	test   $0x3,%cl
  8018c1:	75 ef                	jne    8018b2 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8018c3:	83 ef 04             	sub    $0x4,%edi
  8018c6:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018c9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8018cc:	fd                   	std    
  8018cd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018cf:	eb ea                	jmp    8018bb <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018d1:	89 f2                	mov    %esi,%edx
  8018d3:	09 c2                	or     %eax,%edx
  8018d5:	f6 c2 03             	test   $0x3,%dl
  8018d8:	74 09                	je     8018e3 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018da:	89 c7                	mov    %eax,%edi
  8018dc:	fc                   	cld    
  8018dd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018df:	5e                   	pop    %esi
  8018e0:	5f                   	pop    %edi
  8018e1:	5d                   	pop    %ebp
  8018e2:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018e3:	f6 c1 03             	test   $0x3,%cl
  8018e6:	75 f2                	jne    8018da <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8018e8:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8018eb:	89 c7                	mov    %eax,%edi
  8018ed:	fc                   	cld    
  8018ee:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018f0:	eb ed                	jmp    8018df <memmove+0x55>

008018f2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018f2:	55                   	push   %ebp
  8018f3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018f5:	ff 75 10             	pushl  0x10(%ebp)
  8018f8:	ff 75 0c             	pushl  0xc(%ebp)
  8018fb:	ff 75 08             	pushl  0x8(%ebp)
  8018fe:	e8 87 ff ff ff       	call   80188a <memmove>
}
  801903:	c9                   	leave  
  801904:	c3                   	ret    

00801905 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801905:	55                   	push   %ebp
  801906:	89 e5                	mov    %esp,%ebp
  801908:	56                   	push   %esi
  801909:	53                   	push   %ebx
  80190a:	8b 45 08             	mov    0x8(%ebp),%eax
  80190d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801910:	89 c6                	mov    %eax,%esi
  801912:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801915:	39 f0                	cmp    %esi,%eax
  801917:	74 1c                	je     801935 <memcmp+0x30>
		if (*s1 != *s2)
  801919:	0f b6 08             	movzbl (%eax),%ecx
  80191c:	0f b6 1a             	movzbl (%edx),%ebx
  80191f:	38 d9                	cmp    %bl,%cl
  801921:	75 08                	jne    80192b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801923:	83 c0 01             	add    $0x1,%eax
  801926:	83 c2 01             	add    $0x1,%edx
  801929:	eb ea                	jmp    801915 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  80192b:	0f b6 c1             	movzbl %cl,%eax
  80192e:	0f b6 db             	movzbl %bl,%ebx
  801931:	29 d8                	sub    %ebx,%eax
  801933:	eb 05                	jmp    80193a <memcmp+0x35>
	}

	return 0;
  801935:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80193a:	5b                   	pop    %ebx
  80193b:	5e                   	pop    %esi
  80193c:	5d                   	pop    %ebp
  80193d:	c3                   	ret    

0080193e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80193e:	55                   	push   %ebp
  80193f:	89 e5                	mov    %esp,%ebp
  801941:	8b 45 08             	mov    0x8(%ebp),%eax
  801944:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801947:	89 c2                	mov    %eax,%edx
  801949:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80194c:	39 d0                	cmp    %edx,%eax
  80194e:	73 09                	jae    801959 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  801950:	38 08                	cmp    %cl,(%eax)
  801952:	74 05                	je     801959 <memfind+0x1b>
	for (; s < ends; s++)
  801954:	83 c0 01             	add    $0x1,%eax
  801957:	eb f3                	jmp    80194c <memfind+0xe>
			break;
	return (void *) s;
}
  801959:	5d                   	pop    %ebp
  80195a:	c3                   	ret    

0080195b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80195b:	55                   	push   %ebp
  80195c:	89 e5                	mov    %esp,%ebp
  80195e:	57                   	push   %edi
  80195f:	56                   	push   %esi
  801960:	53                   	push   %ebx
  801961:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801964:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801967:	eb 03                	jmp    80196c <strtol+0x11>
		s++;
  801969:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  80196c:	0f b6 01             	movzbl (%ecx),%eax
  80196f:	3c 20                	cmp    $0x20,%al
  801971:	74 f6                	je     801969 <strtol+0xe>
  801973:	3c 09                	cmp    $0x9,%al
  801975:	74 f2                	je     801969 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  801977:	3c 2b                	cmp    $0x2b,%al
  801979:	74 2e                	je     8019a9 <strtol+0x4e>
	int neg = 0;
  80197b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801980:	3c 2d                	cmp    $0x2d,%al
  801982:	74 2f                	je     8019b3 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801984:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80198a:	75 05                	jne    801991 <strtol+0x36>
  80198c:	80 39 30             	cmpb   $0x30,(%ecx)
  80198f:	74 2c                	je     8019bd <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801991:	85 db                	test   %ebx,%ebx
  801993:	75 0a                	jne    80199f <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801995:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  80199a:	80 39 30             	cmpb   $0x30,(%ecx)
  80199d:	74 28                	je     8019c7 <strtol+0x6c>
		base = 10;
  80199f:	b8 00 00 00 00       	mov    $0x0,%eax
  8019a4:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8019a7:	eb 50                	jmp    8019f9 <strtol+0x9e>
		s++;
  8019a9:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  8019ac:	bf 00 00 00 00       	mov    $0x0,%edi
  8019b1:	eb d1                	jmp    801984 <strtol+0x29>
		s++, neg = 1;
  8019b3:	83 c1 01             	add    $0x1,%ecx
  8019b6:	bf 01 00 00 00       	mov    $0x1,%edi
  8019bb:	eb c7                	jmp    801984 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019bd:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019c1:	74 0e                	je     8019d1 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8019c3:	85 db                	test   %ebx,%ebx
  8019c5:	75 d8                	jne    80199f <strtol+0x44>
		s++, base = 8;
  8019c7:	83 c1 01             	add    $0x1,%ecx
  8019ca:	bb 08 00 00 00       	mov    $0x8,%ebx
  8019cf:	eb ce                	jmp    80199f <strtol+0x44>
		s += 2, base = 16;
  8019d1:	83 c1 02             	add    $0x2,%ecx
  8019d4:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019d9:	eb c4                	jmp    80199f <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  8019db:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019de:	89 f3                	mov    %esi,%ebx
  8019e0:	80 fb 19             	cmp    $0x19,%bl
  8019e3:	77 29                	ja     801a0e <strtol+0xb3>
			dig = *s - 'a' + 10;
  8019e5:	0f be d2             	movsbl %dl,%edx
  8019e8:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8019eb:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019ee:	7d 30                	jge    801a20 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  8019f0:	83 c1 01             	add    $0x1,%ecx
  8019f3:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019f7:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  8019f9:	0f b6 11             	movzbl (%ecx),%edx
  8019fc:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019ff:	89 f3                	mov    %esi,%ebx
  801a01:	80 fb 09             	cmp    $0x9,%bl
  801a04:	77 d5                	ja     8019db <strtol+0x80>
			dig = *s - '0';
  801a06:	0f be d2             	movsbl %dl,%edx
  801a09:	83 ea 30             	sub    $0x30,%edx
  801a0c:	eb dd                	jmp    8019eb <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  801a0e:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a11:	89 f3                	mov    %esi,%ebx
  801a13:	80 fb 19             	cmp    $0x19,%bl
  801a16:	77 08                	ja     801a20 <strtol+0xc5>
			dig = *s - 'A' + 10;
  801a18:	0f be d2             	movsbl %dl,%edx
  801a1b:	83 ea 37             	sub    $0x37,%edx
  801a1e:	eb cb                	jmp    8019eb <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  801a20:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a24:	74 05                	je     801a2b <strtol+0xd0>
		*endptr = (char *) s;
  801a26:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a29:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801a2b:	89 c2                	mov    %eax,%edx
  801a2d:	f7 da                	neg    %edx
  801a2f:	85 ff                	test   %edi,%edi
  801a31:	0f 45 c2             	cmovne %edx,%eax
}
  801a34:	5b                   	pop    %ebx
  801a35:	5e                   	pop    %esi
  801a36:	5f                   	pop    %edi
  801a37:	5d                   	pop    %ebp
  801a38:	c3                   	ret    

00801a39 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a39:	55                   	push   %ebp
  801a3a:	89 e5                	mov    %esp,%ebp
  801a3c:	56                   	push   %esi
  801a3d:	53                   	push   %ebx
  801a3e:	8b 75 08             	mov    0x8(%ebp),%esi
  801a41:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a44:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  801a47:	85 f6                	test   %esi,%esi
  801a49:	74 06                	je     801a51 <ipc_recv+0x18>
  801a4b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801a51:	85 db                	test   %ebx,%ebx
  801a53:	74 06                	je     801a5b <ipc_recv+0x22>
  801a55:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801a5b:	85 c0                	test   %eax,%eax
  801a5d:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801a62:	0f 44 c2             	cmove  %edx,%eax
	int ret = sys_ipc_recv(pg);
  801a65:	83 ec 0c             	sub    $0xc,%esp
  801a68:	50                   	push   %eax
  801a69:	e8 a5 e8 ff ff       	call   800313 <sys_ipc_recv>
	if (ret) return ret;
  801a6e:	83 c4 10             	add    $0x10,%esp
  801a71:	85 c0                	test   %eax,%eax
  801a73:	75 24                	jne    801a99 <ipc_recv+0x60>
	if (from_env_store)
  801a75:	85 f6                	test   %esi,%esi
  801a77:	74 0a                	je     801a83 <ipc_recv+0x4a>
		*from_env_store = thisenv->env_ipc_from;
  801a79:	a1 04 40 80 00       	mov    0x804004,%eax
  801a7e:	8b 40 74             	mov    0x74(%eax),%eax
  801a81:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801a83:	85 db                	test   %ebx,%ebx
  801a85:	74 0a                	je     801a91 <ipc_recv+0x58>
		*perm_store = thisenv->env_ipc_perm;
  801a87:	a1 04 40 80 00       	mov    0x804004,%eax
  801a8c:	8b 40 78             	mov    0x78(%eax),%eax
  801a8f:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801a91:	a1 04 40 80 00       	mov    0x804004,%eax
  801a96:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a99:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a9c:	5b                   	pop    %ebx
  801a9d:	5e                   	pop    %esi
  801a9e:	5d                   	pop    %ebp
  801a9f:	c3                   	ret    

00801aa0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801aa0:	55                   	push   %ebp
  801aa1:	89 e5                	mov    %esp,%ebp
  801aa3:	57                   	push   %edi
  801aa4:	56                   	push   %esi
  801aa5:	53                   	push   %ebx
  801aa6:	83 ec 0c             	sub    $0xc,%esp
  801aa9:	8b 7d 08             	mov    0x8(%ebp),%edi
  801aac:	8b 75 0c             	mov    0xc(%ebp),%esi
  801aaf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  801ab2:	85 db                	test   %ebx,%ebx
  801ab4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801ab9:	0f 44 d8             	cmove  %eax,%ebx
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801abc:	ff 75 14             	pushl  0x14(%ebp)
  801abf:	53                   	push   %ebx
  801ac0:	56                   	push   %esi
  801ac1:	57                   	push   %edi
  801ac2:	e8 29 e8 ff ff       	call   8002f0 <sys_ipc_try_send>
  801ac7:	83 c4 10             	add    $0x10,%esp
  801aca:	85 c0                	test   %eax,%eax
  801acc:	74 1e                	je     801aec <ipc_send+0x4c>
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801ace:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ad1:	75 07                	jne    801ada <ipc_send+0x3a>
		sys_yield();
  801ad3:	e8 6c e6 ff ff       	call   800144 <sys_yield>
  801ad8:	eb e2                	jmp    801abc <ipc_send+0x1c>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801ada:	50                   	push   %eax
  801adb:	68 00 22 80 00       	push   $0x802200
  801ae0:	6a 36                	push   $0x36
  801ae2:	68 17 22 80 00       	push   $0x802217
  801ae7:	e8 16 f5 ff ff       	call   801002 <_panic>
	}
}
  801aec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aef:	5b                   	pop    %ebx
  801af0:	5e                   	pop    %esi
  801af1:	5f                   	pop    %edi
  801af2:	5d                   	pop    %ebp
  801af3:	c3                   	ret    

00801af4 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801af4:	55                   	push   %ebp
  801af5:	89 e5                	mov    %esp,%ebp
  801af7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801afa:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801aff:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b02:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b08:	8b 52 50             	mov    0x50(%edx),%edx
  801b0b:	39 ca                	cmp    %ecx,%edx
  801b0d:	74 11                	je     801b20 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801b0f:	83 c0 01             	add    $0x1,%eax
  801b12:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b17:	75 e6                	jne    801aff <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801b19:	b8 00 00 00 00       	mov    $0x0,%eax
  801b1e:	eb 0b                	jmp    801b2b <ipc_find_env+0x37>
			return envs[i].env_id;
  801b20:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b23:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b28:	8b 40 48             	mov    0x48(%eax),%eax
}
  801b2b:	5d                   	pop    %ebp
  801b2c:	c3                   	ret    

00801b2d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b2d:	55                   	push   %ebp
  801b2e:	89 e5                	mov    %esp,%ebp
  801b30:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b33:	89 d0                	mov    %edx,%eax
  801b35:	c1 e8 16             	shr    $0x16,%eax
  801b38:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b3f:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801b44:	f6 c1 01             	test   $0x1,%cl
  801b47:	74 1d                	je     801b66 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801b49:	c1 ea 0c             	shr    $0xc,%edx
  801b4c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b53:	f6 c2 01             	test   $0x1,%dl
  801b56:	74 0e                	je     801b66 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b58:	c1 ea 0c             	shr    $0xc,%edx
  801b5b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b62:	ef 
  801b63:	0f b7 c0             	movzwl %ax,%eax
}
  801b66:	5d                   	pop    %ebp
  801b67:	c3                   	ret    
  801b68:	66 90                	xchg   %ax,%ax
  801b6a:	66 90                	xchg   %ax,%ax
  801b6c:	66 90                	xchg   %ax,%ax
  801b6e:	66 90                	xchg   %ax,%ax

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
