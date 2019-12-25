
obj/user/softint.debug：     文件格式 elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $14");	// page fault
  800036:	cd 0e                	int    $0xe
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	56                   	push   %esi
  80003e:	53                   	push   %ebx
  80003f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800042:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800045:	e8 ce 00 00 00       	call   800118 <sys_getenvid>
	thisenv = envs + ENVX(envid); 
  80004a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800052:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800057:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005c:	85 db                	test   %ebx,%ebx
  80005e:	7e 07                	jle    800067 <libmain+0x2d>
		binaryname = argv[0];
  800060:	8b 06                	mov    (%esi),%eax
  800062:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800067:	83 ec 08             	sub    $0x8,%esp
  80006a:	56                   	push   %esi
  80006b:	53                   	push   %ebx
  80006c:	e8 c2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800071:	e8 0a 00 00 00       	call   800080 <exit>
}
  800076:	83 c4 10             	add    $0x10,%esp
  800079:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007c:	5b                   	pop    %ebx
  80007d:	5e                   	pop    %esi
  80007e:	5d                   	pop    %ebp
  80007f:	c3                   	ret    

00800080 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800086:	e8 92 04 00 00       	call   80051d <close_all>
	sys_env_destroy(0);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	6a 00                	push   $0x0
  800090:	e8 42 00 00 00       	call   8000d7 <sys_env_destroy>
}
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	57                   	push   %edi
  80009e:	56                   	push   %esi
  80009f:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ab:	89 c3                	mov    %eax,%ebx
  8000ad:	89 c7                	mov    %eax,%edi
  8000af:	89 c6                	mov    %eax,%esi
  8000b1:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b3:	5b                   	pop    %ebx
  8000b4:	5e                   	pop    %esi
  8000b5:	5f                   	pop    %edi
  8000b6:	5d                   	pop    %ebp
  8000b7:	c3                   	ret    

008000b8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	57                   	push   %edi
  8000bc:	56                   	push   %esi
  8000bd:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000be:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c8:	89 d1                	mov    %edx,%ecx
  8000ca:	89 d3                	mov    %edx,%ebx
  8000cc:	89 d7                	mov    %edx,%edi
  8000ce:	89 d6                	mov    %edx,%esi
  8000d0:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d2:	5b                   	pop    %ebx
  8000d3:	5e                   	pop    %esi
  8000d4:	5f                   	pop    %edi
  8000d5:	5d                   	pop    %ebp
  8000d6:	c3                   	ret    

008000d7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d7:	55                   	push   %ebp
  8000d8:	89 e5                	mov    %esp,%ebp
  8000da:	57                   	push   %edi
  8000db:	56                   	push   %esi
  8000dc:	53                   	push   %ebx
  8000dd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000e0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e8:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ed:	89 cb                	mov    %ecx,%ebx
  8000ef:	89 cf                	mov    %ecx,%edi
  8000f1:	89 ce                	mov    %ecx,%esi
  8000f3:	cd 30                	int    $0x30
	if(check && ret > 0)
  8000f5:	85 c0                	test   %eax,%eax
  8000f7:	7f 08                	jg     800101 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8000f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000fc:	5b                   	pop    %ebx
  8000fd:	5e                   	pop    %esi
  8000fe:	5f                   	pop    %edi
  8000ff:	5d                   	pop    %ebp
  800100:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800101:	83 ec 0c             	sub    $0xc,%esp
  800104:	50                   	push   %eax
  800105:	6a 03                	push   $0x3
  800107:	68 aa 1d 80 00       	push   $0x801daa
  80010c:	6a 23                	push   $0x23
  80010e:	68 c7 1d 80 00       	push   $0x801dc7
  800113:	e8 dd 0e 00 00       	call   800ff5 <_panic>

00800118 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	57                   	push   %edi
  80011c:	56                   	push   %esi
  80011d:	53                   	push   %ebx
	asm volatile("int %1\n"
  80011e:	ba 00 00 00 00       	mov    $0x0,%edx
  800123:	b8 02 00 00 00       	mov    $0x2,%eax
  800128:	89 d1                	mov    %edx,%ecx
  80012a:	89 d3                	mov    %edx,%ebx
  80012c:	89 d7                	mov    %edx,%edi
  80012e:	89 d6                	mov    %edx,%esi
  800130:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800132:	5b                   	pop    %ebx
  800133:	5e                   	pop    %esi
  800134:	5f                   	pop    %edi
  800135:	5d                   	pop    %ebp
  800136:	c3                   	ret    

00800137 <sys_yield>:

void
sys_yield(void)
{
  800137:	55                   	push   %ebp
  800138:	89 e5                	mov    %esp,%ebp
  80013a:	57                   	push   %edi
  80013b:	56                   	push   %esi
  80013c:	53                   	push   %ebx
	asm volatile("int %1\n"
  80013d:	ba 00 00 00 00       	mov    $0x0,%edx
  800142:	b8 0b 00 00 00       	mov    $0xb,%eax
  800147:	89 d1                	mov    %edx,%ecx
  800149:	89 d3                	mov    %edx,%ebx
  80014b:	89 d7                	mov    %edx,%edi
  80014d:	89 d6                	mov    %edx,%esi
  80014f:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800151:	5b                   	pop    %ebx
  800152:	5e                   	pop    %esi
  800153:	5f                   	pop    %edi
  800154:	5d                   	pop    %ebp
  800155:	c3                   	ret    

00800156 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	57                   	push   %edi
  80015a:	56                   	push   %esi
  80015b:	53                   	push   %ebx
  80015c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80015f:	be 00 00 00 00       	mov    $0x0,%esi
  800164:	8b 55 08             	mov    0x8(%ebp),%edx
  800167:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80016a:	b8 04 00 00 00       	mov    $0x4,%eax
  80016f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800172:	89 f7                	mov    %esi,%edi
  800174:	cd 30                	int    $0x30
	if(check && ret > 0)
  800176:	85 c0                	test   %eax,%eax
  800178:	7f 08                	jg     800182 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80017a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80017d:	5b                   	pop    %ebx
  80017e:	5e                   	pop    %esi
  80017f:	5f                   	pop    %edi
  800180:	5d                   	pop    %ebp
  800181:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800182:	83 ec 0c             	sub    $0xc,%esp
  800185:	50                   	push   %eax
  800186:	6a 04                	push   $0x4
  800188:	68 aa 1d 80 00       	push   $0x801daa
  80018d:	6a 23                	push   $0x23
  80018f:	68 c7 1d 80 00       	push   $0x801dc7
  800194:	e8 5c 0e 00 00       	call   800ff5 <_panic>

00800199 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	57                   	push   %edi
  80019d:	56                   	push   %esi
  80019e:	53                   	push   %ebx
  80019f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a8:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b6:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001b8:	85 c0                	test   %eax,%eax
  8001ba:	7f 08                	jg     8001c4 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001bf:	5b                   	pop    %ebx
  8001c0:	5e                   	pop    %esi
  8001c1:	5f                   	pop    %edi
  8001c2:	5d                   	pop    %ebp
  8001c3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c4:	83 ec 0c             	sub    $0xc,%esp
  8001c7:	50                   	push   %eax
  8001c8:	6a 05                	push   $0x5
  8001ca:	68 aa 1d 80 00       	push   $0x801daa
  8001cf:	6a 23                	push   $0x23
  8001d1:	68 c7 1d 80 00       	push   $0x801dc7
  8001d6:	e8 1a 0e 00 00       	call   800ff5 <_panic>

008001db <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	57                   	push   %edi
  8001df:	56                   	push   %esi
  8001e0:	53                   	push   %ebx
  8001e1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ef:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f4:	89 df                	mov    %ebx,%edi
  8001f6:	89 de                	mov    %ebx,%esi
  8001f8:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001fa:	85 c0                	test   %eax,%eax
  8001fc:	7f 08                	jg     800206 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8001fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800201:	5b                   	pop    %ebx
  800202:	5e                   	pop    %esi
  800203:	5f                   	pop    %edi
  800204:	5d                   	pop    %ebp
  800205:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800206:	83 ec 0c             	sub    $0xc,%esp
  800209:	50                   	push   %eax
  80020a:	6a 06                	push   $0x6
  80020c:	68 aa 1d 80 00       	push   $0x801daa
  800211:	6a 23                	push   $0x23
  800213:	68 c7 1d 80 00       	push   $0x801dc7
  800218:	e8 d8 0d 00 00       	call   800ff5 <_panic>

0080021d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80021d:	55                   	push   %ebp
  80021e:	89 e5                	mov    %esp,%ebp
  800220:	57                   	push   %edi
  800221:	56                   	push   %esi
  800222:	53                   	push   %ebx
  800223:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800226:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022b:	8b 55 08             	mov    0x8(%ebp),%edx
  80022e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800231:	b8 08 00 00 00       	mov    $0x8,%eax
  800236:	89 df                	mov    %ebx,%edi
  800238:	89 de                	mov    %ebx,%esi
  80023a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80023c:	85 c0                	test   %eax,%eax
  80023e:	7f 08                	jg     800248 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800240:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800243:	5b                   	pop    %ebx
  800244:	5e                   	pop    %esi
  800245:	5f                   	pop    %edi
  800246:	5d                   	pop    %ebp
  800247:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800248:	83 ec 0c             	sub    $0xc,%esp
  80024b:	50                   	push   %eax
  80024c:	6a 08                	push   $0x8
  80024e:	68 aa 1d 80 00       	push   $0x801daa
  800253:	6a 23                	push   $0x23
  800255:	68 c7 1d 80 00       	push   $0x801dc7
  80025a:	e8 96 0d 00 00       	call   800ff5 <_panic>

0080025f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  800262:	57                   	push   %edi
  800263:	56                   	push   %esi
  800264:	53                   	push   %ebx
  800265:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800268:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026d:	8b 55 08             	mov    0x8(%ebp),%edx
  800270:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800273:	b8 09 00 00 00       	mov    $0x9,%eax
  800278:	89 df                	mov    %ebx,%edi
  80027a:	89 de                	mov    %ebx,%esi
  80027c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80027e:	85 c0                	test   %eax,%eax
  800280:	7f 08                	jg     80028a <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800282:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800285:	5b                   	pop    %ebx
  800286:	5e                   	pop    %esi
  800287:	5f                   	pop    %edi
  800288:	5d                   	pop    %ebp
  800289:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80028a:	83 ec 0c             	sub    $0xc,%esp
  80028d:	50                   	push   %eax
  80028e:	6a 09                	push   $0x9
  800290:	68 aa 1d 80 00       	push   $0x801daa
  800295:	6a 23                	push   $0x23
  800297:	68 c7 1d 80 00       	push   $0x801dc7
  80029c:	e8 54 0d 00 00       	call   800ff5 <_panic>

008002a1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a1:	55                   	push   %ebp
  8002a2:	89 e5                	mov    %esp,%ebp
  8002a4:	57                   	push   %edi
  8002a5:	56                   	push   %esi
  8002a6:	53                   	push   %ebx
  8002a7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002aa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002af:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002ba:	89 df                	mov    %ebx,%edi
  8002bc:	89 de                	mov    %ebx,%esi
  8002be:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002c0:	85 c0                	test   %eax,%eax
  8002c2:	7f 08                	jg     8002cc <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c7:	5b                   	pop    %ebx
  8002c8:	5e                   	pop    %esi
  8002c9:	5f                   	pop    %edi
  8002ca:	5d                   	pop    %ebp
  8002cb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002cc:	83 ec 0c             	sub    $0xc,%esp
  8002cf:	50                   	push   %eax
  8002d0:	6a 0a                	push   $0xa
  8002d2:	68 aa 1d 80 00       	push   $0x801daa
  8002d7:	6a 23                	push   $0x23
  8002d9:	68 c7 1d 80 00       	push   $0x801dc7
  8002de:	e8 12 0d 00 00       	call   800ff5 <_panic>

008002e3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e3:	55                   	push   %ebp
  8002e4:	89 e5                	mov    %esp,%ebp
  8002e6:	57                   	push   %edi
  8002e7:	56                   	push   %esi
  8002e8:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ef:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f4:	be 00 00 00 00       	mov    $0x0,%esi
  8002f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002fc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002ff:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800301:	5b                   	pop    %ebx
  800302:	5e                   	pop    %esi
  800303:	5f                   	pop    %edi
  800304:	5d                   	pop    %ebp
  800305:	c3                   	ret    

00800306 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800306:	55                   	push   %ebp
  800307:	89 e5                	mov    %esp,%ebp
  800309:	57                   	push   %edi
  80030a:	56                   	push   %esi
  80030b:	53                   	push   %ebx
  80030c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80030f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800314:	8b 55 08             	mov    0x8(%ebp),%edx
  800317:	b8 0d 00 00 00       	mov    $0xd,%eax
  80031c:	89 cb                	mov    %ecx,%ebx
  80031e:	89 cf                	mov    %ecx,%edi
  800320:	89 ce                	mov    %ecx,%esi
  800322:	cd 30                	int    $0x30
	if(check && ret > 0)
  800324:	85 c0                	test   %eax,%eax
  800326:	7f 08                	jg     800330 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800328:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80032b:	5b                   	pop    %ebx
  80032c:	5e                   	pop    %esi
  80032d:	5f                   	pop    %edi
  80032e:	5d                   	pop    %ebp
  80032f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800330:	83 ec 0c             	sub    $0xc,%esp
  800333:	50                   	push   %eax
  800334:	6a 0d                	push   $0xd
  800336:	68 aa 1d 80 00       	push   $0x801daa
  80033b:	6a 23                	push   $0x23
  80033d:	68 c7 1d 80 00       	push   $0x801dc7
  800342:	e8 ae 0c 00 00       	call   800ff5 <_panic>

00800347 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800347:	55                   	push   %ebp
  800348:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80034a:	8b 45 08             	mov    0x8(%ebp),%eax
  80034d:	05 00 00 00 30       	add    $0x30000000,%eax
  800352:	c1 e8 0c             	shr    $0xc,%eax
}
  800355:	5d                   	pop    %ebp
  800356:	c3                   	ret    

00800357 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80035a:	8b 45 08             	mov    0x8(%ebp),%eax
  80035d:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800362:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800367:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80036c:	5d                   	pop    %ebp
  80036d:	c3                   	ret    

0080036e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80036e:	55                   	push   %ebp
  80036f:	89 e5                	mov    %esp,%ebp
  800371:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800374:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800379:	89 c2                	mov    %eax,%edx
  80037b:	c1 ea 16             	shr    $0x16,%edx
  80037e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800385:	f6 c2 01             	test   $0x1,%dl
  800388:	74 2a                	je     8003b4 <fd_alloc+0x46>
  80038a:	89 c2                	mov    %eax,%edx
  80038c:	c1 ea 0c             	shr    $0xc,%edx
  80038f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800396:	f6 c2 01             	test   $0x1,%dl
  800399:	74 19                	je     8003b4 <fd_alloc+0x46>
  80039b:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8003a0:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003a5:	75 d2                	jne    800379 <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003a7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003ad:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8003b2:	eb 07                	jmp    8003bb <fd_alloc+0x4d>
			*fd_store = fd;
  8003b4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003bb:	5d                   	pop    %ebp
  8003bc:	c3                   	ret    

008003bd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003bd:	55                   	push   %ebp
  8003be:	89 e5                	mov    %esp,%ebp
  8003c0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003c3:	83 f8 1f             	cmp    $0x1f,%eax
  8003c6:	77 36                	ja     8003fe <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003c8:	c1 e0 0c             	shl    $0xc,%eax
  8003cb:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003d0:	89 c2                	mov    %eax,%edx
  8003d2:	c1 ea 16             	shr    $0x16,%edx
  8003d5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003dc:	f6 c2 01             	test   $0x1,%dl
  8003df:	74 24                	je     800405 <fd_lookup+0x48>
  8003e1:	89 c2                	mov    %eax,%edx
  8003e3:	c1 ea 0c             	shr    $0xc,%edx
  8003e6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003ed:	f6 c2 01             	test   $0x1,%dl
  8003f0:	74 1a                	je     80040c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f5:	89 02                	mov    %eax,(%edx)
	return 0;
  8003f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003fc:	5d                   	pop    %ebp
  8003fd:	c3                   	ret    
		return -E_INVAL;
  8003fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800403:	eb f7                	jmp    8003fc <fd_lookup+0x3f>
		return -E_INVAL;
  800405:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80040a:	eb f0                	jmp    8003fc <fd_lookup+0x3f>
  80040c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800411:	eb e9                	jmp    8003fc <fd_lookup+0x3f>

00800413 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800413:	55                   	push   %ebp
  800414:	89 e5                	mov    %esp,%ebp
  800416:	83 ec 08             	sub    $0x8,%esp
  800419:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80041c:	ba 54 1e 80 00       	mov    $0x801e54,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800421:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800426:	39 08                	cmp    %ecx,(%eax)
  800428:	74 33                	je     80045d <dev_lookup+0x4a>
  80042a:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  80042d:	8b 02                	mov    (%edx),%eax
  80042f:	85 c0                	test   %eax,%eax
  800431:	75 f3                	jne    800426 <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800433:	a1 04 40 80 00       	mov    0x804004,%eax
  800438:	8b 40 48             	mov    0x48(%eax),%eax
  80043b:	83 ec 04             	sub    $0x4,%esp
  80043e:	51                   	push   %ecx
  80043f:	50                   	push   %eax
  800440:	68 d8 1d 80 00       	push   $0x801dd8
  800445:	e8 86 0c 00 00       	call   8010d0 <cprintf>
	*dev = 0;
  80044a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80044d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800453:	83 c4 10             	add    $0x10,%esp
  800456:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80045b:	c9                   	leave  
  80045c:	c3                   	ret    
			*dev = devtab[i];
  80045d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800460:	89 01                	mov    %eax,(%ecx)
			return 0;
  800462:	b8 00 00 00 00       	mov    $0x0,%eax
  800467:	eb f2                	jmp    80045b <dev_lookup+0x48>

00800469 <fd_close>:
{
  800469:	55                   	push   %ebp
  80046a:	89 e5                	mov    %esp,%ebp
  80046c:	57                   	push   %edi
  80046d:	56                   	push   %esi
  80046e:	53                   	push   %ebx
  80046f:	83 ec 1c             	sub    $0x1c,%esp
  800472:	8b 75 08             	mov    0x8(%ebp),%esi
  800475:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800478:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80047b:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80047c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800482:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800485:	50                   	push   %eax
  800486:	e8 32 ff ff ff       	call   8003bd <fd_lookup>
  80048b:	89 c3                	mov    %eax,%ebx
  80048d:	83 c4 08             	add    $0x8,%esp
  800490:	85 c0                	test   %eax,%eax
  800492:	78 05                	js     800499 <fd_close+0x30>
	    || fd != fd2)
  800494:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800497:	74 16                	je     8004af <fd_close+0x46>
		return (must_exist ? r : 0);
  800499:	89 f8                	mov    %edi,%eax
  80049b:	84 c0                	test   %al,%al
  80049d:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a2:	0f 44 d8             	cmove  %eax,%ebx
}
  8004a5:	89 d8                	mov    %ebx,%eax
  8004a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004aa:	5b                   	pop    %ebx
  8004ab:	5e                   	pop    %esi
  8004ac:	5f                   	pop    %edi
  8004ad:	5d                   	pop    %ebp
  8004ae:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004af:	83 ec 08             	sub    $0x8,%esp
  8004b2:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8004b5:	50                   	push   %eax
  8004b6:	ff 36                	pushl  (%esi)
  8004b8:	e8 56 ff ff ff       	call   800413 <dev_lookup>
  8004bd:	89 c3                	mov    %eax,%ebx
  8004bf:	83 c4 10             	add    $0x10,%esp
  8004c2:	85 c0                	test   %eax,%eax
  8004c4:	78 15                	js     8004db <fd_close+0x72>
		if (dev->dev_close)
  8004c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004c9:	8b 40 10             	mov    0x10(%eax),%eax
  8004cc:	85 c0                	test   %eax,%eax
  8004ce:	74 1b                	je     8004eb <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  8004d0:	83 ec 0c             	sub    $0xc,%esp
  8004d3:	56                   	push   %esi
  8004d4:	ff d0                	call   *%eax
  8004d6:	89 c3                	mov    %eax,%ebx
  8004d8:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8004db:	83 ec 08             	sub    $0x8,%esp
  8004de:	56                   	push   %esi
  8004df:	6a 00                	push   $0x0
  8004e1:	e8 f5 fc ff ff       	call   8001db <sys_page_unmap>
	return r;
  8004e6:	83 c4 10             	add    $0x10,%esp
  8004e9:	eb ba                	jmp    8004a5 <fd_close+0x3c>
			r = 0;
  8004eb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8004f0:	eb e9                	jmp    8004db <fd_close+0x72>

008004f2 <close>:

int
close(int fdnum)
{
  8004f2:	55                   	push   %ebp
  8004f3:	89 e5                	mov    %esp,%ebp
  8004f5:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004fb:	50                   	push   %eax
  8004fc:	ff 75 08             	pushl  0x8(%ebp)
  8004ff:	e8 b9 fe ff ff       	call   8003bd <fd_lookup>
  800504:	83 c4 08             	add    $0x8,%esp
  800507:	85 c0                	test   %eax,%eax
  800509:	78 10                	js     80051b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80050b:	83 ec 08             	sub    $0x8,%esp
  80050e:	6a 01                	push   $0x1
  800510:	ff 75 f4             	pushl  -0xc(%ebp)
  800513:	e8 51 ff ff ff       	call   800469 <fd_close>
  800518:	83 c4 10             	add    $0x10,%esp
}
  80051b:	c9                   	leave  
  80051c:	c3                   	ret    

0080051d <close_all>:

void
close_all(void)
{
  80051d:	55                   	push   %ebp
  80051e:	89 e5                	mov    %esp,%ebp
  800520:	53                   	push   %ebx
  800521:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800524:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800529:	83 ec 0c             	sub    $0xc,%esp
  80052c:	53                   	push   %ebx
  80052d:	e8 c0 ff ff ff       	call   8004f2 <close>
	for (i = 0; i < MAXFD; i++)
  800532:	83 c3 01             	add    $0x1,%ebx
  800535:	83 c4 10             	add    $0x10,%esp
  800538:	83 fb 20             	cmp    $0x20,%ebx
  80053b:	75 ec                	jne    800529 <close_all+0xc>
}
  80053d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800540:	c9                   	leave  
  800541:	c3                   	ret    

00800542 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800542:	55                   	push   %ebp
  800543:	89 e5                	mov    %esp,%ebp
  800545:	57                   	push   %edi
  800546:	56                   	push   %esi
  800547:	53                   	push   %ebx
  800548:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80054b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80054e:	50                   	push   %eax
  80054f:	ff 75 08             	pushl  0x8(%ebp)
  800552:	e8 66 fe ff ff       	call   8003bd <fd_lookup>
  800557:	89 c3                	mov    %eax,%ebx
  800559:	83 c4 08             	add    $0x8,%esp
  80055c:	85 c0                	test   %eax,%eax
  80055e:	0f 88 81 00 00 00    	js     8005e5 <dup+0xa3>
		return r;
	close(newfdnum);
  800564:	83 ec 0c             	sub    $0xc,%esp
  800567:	ff 75 0c             	pushl  0xc(%ebp)
  80056a:	e8 83 ff ff ff       	call   8004f2 <close>

	newfd = INDEX2FD(newfdnum);
  80056f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800572:	c1 e6 0c             	shl    $0xc,%esi
  800575:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80057b:	83 c4 04             	add    $0x4,%esp
  80057e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800581:	e8 d1 fd ff ff       	call   800357 <fd2data>
  800586:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800588:	89 34 24             	mov    %esi,(%esp)
  80058b:	e8 c7 fd ff ff       	call   800357 <fd2data>
  800590:	83 c4 10             	add    $0x10,%esp
  800593:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800595:	89 d8                	mov    %ebx,%eax
  800597:	c1 e8 16             	shr    $0x16,%eax
  80059a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005a1:	a8 01                	test   $0x1,%al
  8005a3:	74 11                	je     8005b6 <dup+0x74>
  8005a5:	89 d8                	mov    %ebx,%eax
  8005a7:	c1 e8 0c             	shr    $0xc,%eax
  8005aa:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005b1:	f6 c2 01             	test   $0x1,%dl
  8005b4:	75 39                	jne    8005ef <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005b6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005b9:	89 d0                	mov    %edx,%eax
  8005bb:	c1 e8 0c             	shr    $0xc,%eax
  8005be:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005c5:	83 ec 0c             	sub    $0xc,%esp
  8005c8:	25 07 0e 00 00       	and    $0xe07,%eax
  8005cd:	50                   	push   %eax
  8005ce:	56                   	push   %esi
  8005cf:	6a 00                	push   $0x0
  8005d1:	52                   	push   %edx
  8005d2:	6a 00                	push   $0x0
  8005d4:	e8 c0 fb ff ff       	call   800199 <sys_page_map>
  8005d9:	89 c3                	mov    %eax,%ebx
  8005db:	83 c4 20             	add    $0x20,%esp
  8005de:	85 c0                	test   %eax,%eax
  8005e0:	78 31                	js     800613 <dup+0xd1>
		goto err;

	return newfdnum;
  8005e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005e5:	89 d8                	mov    %ebx,%eax
  8005e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005ea:	5b                   	pop    %ebx
  8005eb:	5e                   	pop    %esi
  8005ec:	5f                   	pop    %edi
  8005ed:	5d                   	pop    %ebp
  8005ee:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005ef:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005f6:	83 ec 0c             	sub    $0xc,%esp
  8005f9:	25 07 0e 00 00       	and    $0xe07,%eax
  8005fe:	50                   	push   %eax
  8005ff:	57                   	push   %edi
  800600:	6a 00                	push   $0x0
  800602:	53                   	push   %ebx
  800603:	6a 00                	push   $0x0
  800605:	e8 8f fb ff ff       	call   800199 <sys_page_map>
  80060a:	89 c3                	mov    %eax,%ebx
  80060c:	83 c4 20             	add    $0x20,%esp
  80060f:	85 c0                	test   %eax,%eax
  800611:	79 a3                	jns    8005b6 <dup+0x74>
	sys_page_unmap(0, newfd);
  800613:	83 ec 08             	sub    $0x8,%esp
  800616:	56                   	push   %esi
  800617:	6a 00                	push   $0x0
  800619:	e8 bd fb ff ff       	call   8001db <sys_page_unmap>
	sys_page_unmap(0, nva);
  80061e:	83 c4 08             	add    $0x8,%esp
  800621:	57                   	push   %edi
  800622:	6a 00                	push   $0x0
  800624:	e8 b2 fb ff ff       	call   8001db <sys_page_unmap>
	return r;
  800629:	83 c4 10             	add    $0x10,%esp
  80062c:	eb b7                	jmp    8005e5 <dup+0xa3>

0080062e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80062e:	55                   	push   %ebp
  80062f:	89 e5                	mov    %esp,%ebp
  800631:	53                   	push   %ebx
  800632:	83 ec 14             	sub    $0x14,%esp
  800635:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800638:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80063b:	50                   	push   %eax
  80063c:	53                   	push   %ebx
  80063d:	e8 7b fd ff ff       	call   8003bd <fd_lookup>
  800642:	83 c4 08             	add    $0x8,%esp
  800645:	85 c0                	test   %eax,%eax
  800647:	78 3f                	js     800688 <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800649:	83 ec 08             	sub    $0x8,%esp
  80064c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80064f:	50                   	push   %eax
  800650:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800653:	ff 30                	pushl  (%eax)
  800655:	e8 b9 fd ff ff       	call   800413 <dev_lookup>
  80065a:	83 c4 10             	add    $0x10,%esp
  80065d:	85 c0                	test   %eax,%eax
  80065f:	78 27                	js     800688 <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800661:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800664:	8b 42 08             	mov    0x8(%edx),%eax
  800667:	83 e0 03             	and    $0x3,%eax
  80066a:	83 f8 01             	cmp    $0x1,%eax
  80066d:	74 1e                	je     80068d <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80066f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800672:	8b 40 08             	mov    0x8(%eax),%eax
  800675:	85 c0                	test   %eax,%eax
  800677:	74 35                	je     8006ae <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800679:	83 ec 04             	sub    $0x4,%esp
  80067c:	ff 75 10             	pushl  0x10(%ebp)
  80067f:	ff 75 0c             	pushl  0xc(%ebp)
  800682:	52                   	push   %edx
  800683:	ff d0                	call   *%eax
  800685:	83 c4 10             	add    $0x10,%esp
}
  800688:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80068b:	c9                   	leave  
  80068c:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80068d:	a1 04 40 80 00       	mov    0x804004,%eax
  800692:	8b 40 48             	mov    0x48(%eax),%eax
  800695:	83 ec 04             	sub    $0x4,%esp
  800698:	53                   	push   %ebx
  800699:	50                   	push   %eax
  80069a:	68 19 1e 80 00       	push   $0x801e19
  80069f:	e8 2c 0a 00 00       	call   8010d0 <cprintf>
		return -E_INVAL;
  8006a4:	83 c4 10             	add    $0x10,%esp
  8006a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006ac:	eb da                	jmp    800688 <read+0x5a>
		return -E_NOT_SUPP;
  8006ae:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8006b3:	eb d3                	jmp    800688 <read+0x5a>

008006b5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006b5:	55                   	push   %ebp
  8006b6:	89 e5                	mov    %esp,%ebp
  8006b8:	57                   	push   %edi
  8006b9:	56                   	push   %esi
  8006ba:	53                   	push   %ebx
  8006bb:	83 ec 0c             	sub    $0xc,%esp
  8006be:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006c9:	39 f3                	cmp    %esi,%ebx
  8006cb:	73 25                	jae    8006f2 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006cd:	83 ec 04             	sub    $0x4,%esp
  8006d0:	89 f0                	mov    %esi,%eax
  8006d2:	29 d8                	sub    %ebx,%eax
  8006d4:	50                   	push   %eax
  8006d5:	89 d8                	mov    %ebx,%eax
  8006d7:	03 45 0c             	add    0xc(%ebp),%eax
  8006da:	50                   	push   %eax
  8006db:	57                   	push   %edi
  8006dc:	e8 4d ff ff ff       	call   80062e <read>
		if (m < 0)
  8006e1:	83 c4 10             	add    $0x10,%esp
  8006e4:	85 c0                	test   %eax,%eax
  8006e6:	78 08                	js     8006f0 <readn+0x3b>
			return m;
		if (m == 0)
  8006e8:	85 c0                	test   %eax,%eax
  8006ea:	74 06                	je     8006f2 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  8006ec:	01 c3                	add    %eax,%ebx
  8006ee:	eb d9                	jmp    8006c9 <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006f0:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8006f2:	89 d8                	mov    %ebx,%eax
  8006f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f7:	5b                   	pop    %ebx
  8006f8:	5e                   	pop    %esi
  8006f9:	5f                   	pop    %edi
  8006fa:	5d                   	pop    %ebp
  8006fb:	c3                   	ret    

008006fc <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006fc:	55                   	push   %ebp
  8006fd:	89 e5                	mov    %esp,%ebp
  8006ff:	53                   	push   %ebx
  800700:	83 ec 14             	sub    $0x14,%esp
  800703:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800706:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800709:	50                   	push   %eax
  80070a:	53                   	push   %ebx
  80070b:	e8 ad fc ff ff       	call   8003bd <fd_lookup>
  800710:	83 c4 08             	add    $0x8,%esp
  800713:	85 c0                	test   %eax,%eax
  800715:	78 3a                	js     800751 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800717:	83 ec 08             	sub    $0x8,%esp
  80071a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80071d:	50                   	push   %eax
  80071e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800721:	ff 30                	pushl  (%eax)
  800723:	e8 eb fc ff ff       	call   800413 <dev_lookup>
  800728:	83 c4 10             	add    $0x10,%esp
  80072b:	85 c0                	test   %eax,%eax
  80072d:	78 22                	js     800751 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80072f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800732:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800736:	74 1e                	je     800756 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800738:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80073b:	8b 52 0c             	mov    0xc(%edx),%edx
  80073e:	85 d2                	test   %edx,%edx
  800740:	74 35                	je     800777 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800742:	83 ec 04             	sub    $0x4,%esp
  800745:	ff 75 10             	pushl  0x10(%ebp)
  800748:	ff 75 0c             	pushl  0xc(%ebp)
  80074b:	50                   	push   %eax
  80074c:	ff d2                	call   *%edx
  80074e:	83 c4 10             	add    $0x10,%esp
}
  800751:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800754:	c9                   	leave  
  800755:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800756:	a1 04 40 80 00       	mov    0x804004,%eax
  80075b:	8b 40 48             	mov    0x48(%eax),%eax
  80075e:	83 ec 04             	sub    $0x4,%esp
  800761:	53                   	push   %ebx
  800762:	50                   	push   %eax
  800763:	68 35 1e 80 00       	push   $0x801e35
  800768:	e8 63 09 00 00       	call   8010d0 <cprintf>
		return -E_INVAL;
  80076d:	83 c4 10             	add    $0x10,%esp
  800770:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800775:	eb da                	jmp    800751 <write+0x55>
		return -E_NOT_SUPP;
  800777:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80077c:	eb d3                	jmp    800751 <write+0x55>

0080077e <seek>:

int
seek(int fdnum, off_t offset)
{
  80077e:	55                   	push   %ebp
  80077f:	89 e5                	mov    %esp,%ebp
  800781:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800784:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800787:	50                   	push   %eax
  800788:	ff 75 08             	pushl  0x8(%ebp)
  80078b:	e8 2d fc ff ff       	call   8003bd <fd_lookup>
  800790:	83 c4 08             	add    $0x8,%esp
  800793:	85 c0                	test   %eax,%eax
  800795:	78 0e                	js     8007a5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800797:	8b 55 0c             	mov    0xc(%ebp),%edx
  80079a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80079d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007a5:	c9                   	leave  
  8007a6:	c3                   	ret    

008007a7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	53                   	push   %ebx
  8007ab:	83 ec 14             	sub    $0x14,%esp
  8007ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007b1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007b4:	50                   	push   %eax
  8007b5:	53                   	push   %ebx
  8007b6:	e8 02 fc ff ff       	call   8003bd <fd_lookup>
  8007bb:	83 c4 08             	add    $0x8,%esp
  8007be:	85 c0                	test   %eax,%eax
  8007c0:	78 37                	js     8007f9 <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007c2:	83 ec 08             	sub    $0x8,%esp
  8007c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007c8:	50                   	push   %eax
  8007c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007cc:	ff 30                	pushl  (%eax)
  8007ce:	e8 40 fc ff ff       	call   800413 <dev_lookup>
  8007d3:	83 c4 10             	add    $0x10,%esp
  8007d6:	85 c0                	test   %eax,%eax
  8007d8:	78 1f                	js     8007f9 <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007dd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007e1:	74 1b                	je     8007fe <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8007e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007e6:	8b 52 18             	mov    0x18(%edx),%edx
  8007e9:	85 d2                	test   %edx,%edx
  8007eb:	74 32                	je     80081f <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8007ed:	83 ec 08             	sub    $0x8,%esp
  8007f0:	ff 75 0c             	pushl  0xc(%ebp)
  8007f3:	50                   	push   %eax
  8007f4:	ff d2                	call   *%edx
  8007f6:	83 c4 10             	add    $0x10,%esp
}
  8007f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007fc:	c9                   	leave  
  8007fd:	c3                   	ret    
			thisenv->env_id, fdnum);
  8007fe:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800803:	8b 40 48             	mov    0x48(%eax),%eax
  800806:	83 ec 04             	sub    $0x4,%esp
  800809:	53                   	push   %ebx
  80080a:	50                   	push   %eax
  80080b:	68 f8 1d 80 00       	push   $0x801df8
  800810:	e8 bb 08 00 00       	call   8010d0 <cprintf>
		return -E_INVAL;
  800815:	83 c4 10             	add    $0x10,%esp
  800818:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80081d:	eb da                	jmp    8007f9 <ftruncate+0x52>
		return -E_NOT_SUPP;
  80081f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800824:	eb d3                	jmp    8007f9 <ftruncate+0x52>

00800826 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800826:	55                   	push   %ebp
  800827:	89 e5                	mov    %esp,%ebp
  800829:	53                   	push   %ebx
  80082a:	83 ec 14             	sub    $0x14,%esp
  80082d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800830:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800833:	50                   	push   %eax
  800834:	ff 75 08             	pushl  0x8(%ebp)
  800837:	e8 81 fb ff ff       	call   8003bd <fd_lookup>
  80083c:	83 c4 08             	add    $0x8,%esp
  80083f:	85 c0                	test   %eax,%eax
  800841:	78 4b                	js     80088e <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800843:	83 ec 08             	sub    $0x8,%esp
  800846:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800849:	50                   	push   %eax
  80084a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80084d:	ff 30                	pushl  (%eax)
  80084f:	e8 bf fb ff ff       	call   800413 <dev_lookup>
  800854:	83 c4 10             	add    $0x10,%esp
  800857:	85 c0                	test   %eax,%eax
  800859:	78 33                	js     80088e <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  80085b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80085e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800862:	74 2f                	je     800893 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800864:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800867:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80086e:	00 00 00 
	stat->st_isdir = 0;
  800871:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800878:	00 00 00 
	stat->st_dev = dev;
  80087b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800881:	83 ec 08             	sub    $0x8,%esp
  800884:	53                   	push   %ebx
  800885:	ff 75 f0             	pushl  -0x10(%ebp)
  800888:	ff 50 14             	call   *0x14(%eax)
  80088b:	83 c4 10             	add    $0x10,%esp
}
  80088e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800891:	c9                   	leave  
  800892:	c3                   	ret    
		return -E_NOT_SUPP;
  800893:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800898:	eb f4                	jmp    80088e <fstat+0x68>

0080089a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	56                   	push   %esi
  80089e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80089f:	83 ec 08             	sub    $0x8,%esp
  8008a2:	6a 00                	push   $0x0
  8008a4:	ff 75 08             	pushl  0x8(%ebp)
  8008a7:	e8 da 01 00 00       	call   800a86 <open>
  8008ac:	89 c3                	mov    %eax,%ebx
  8008ae:	83 c4 10             	add    $0x10,%esp
  8008b1:	85 c0                	test   %eax,%eax
  8008b3:	78 1b                	js     8008d0 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008b5:	83 ec 08             	sub    $0x8,%esp
  8008b8:	ff 75 0c             	pushl  0xc(%ebp)
  8008bb:	50                   	push   %eax
  8008bc:	e8 65 ff ff ff       	call   800826 <fstat>
  8008c1:	89 c6                	mov    %eax,%esi
	close(fd);
  8008c3:	89 1c 24             	mov    %ebx,(%esp)
  8008c6:	e8 27 fc ff ff       	call   8004f2 <close>
	return r;
  8008cb:	83 c4 10             	add    $0x10,%esp
  8008ce:	89 f3                	mov    %esi,%ebx
}
  8008d0:	89 d8                	mov    %ebx,%eax
  8008d2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008d5:	5b                   	pop    %ebx
  8008d6:	5e                   	pop    %esi
  8008d7:	5d                   	pop    %ebp
  8008d8:	c3                   	ret    

008008d9 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008d9:	55                   	push   %ebp
  8008da:	89 e5                	mov    %esp,%ebp
  8008dc:	56                   	push   %esi
  8008dd:	53                   	push   %ebx
  8008de:	89 c6                	mov    %eax,%esi
  8008e0:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008e2:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8008e9:	74 27                	je     800912 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008eb:	6a 07                	push   $0x7
  8008ed:	68 00 50 80 00       	push   $0x805000
  8008f2:	56                   	push   %esi
  8008f3:	ff 35 00 40 80 00    	pushl  0x804000
  8008f9:	e8 95 11 00 00       	call   801a93 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8008fe:	83 c4 0c             	add    $0xc,%esp
  800901:	6a 00                	push   $0x0
  800903:	53                   	push   %ebx
  800904:	6a 00                	push   $0x0
  800906:	e8 21 11 00 00       	call   801a2c <ipc_recv>
}
  80090b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80090e:	5b                   	pop    %ebx
  80090f:	5e                   	pop    %esi
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800912:	83 ec 0c             	sub    $0xc,%esp
  800915:	6a 01                	push   $0x1
  800917:	e8 cb 11 00 00       	call   801ae7 <ipc_find_env>
  80091c:	a3 00 40 80 00       	mov    %eax,0x804000
  800921:	83 c4 10             	add    $0x10,%esp
  800924:	eb c5                	jmp    8008eb <fsipc+0x12>

00800926 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80092c:	8b 45 08             	mov    0x8(%ebp),%eax
  80092f:	8b 40 0c             	mov    0xc(%eax),%eax
  800932:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800937:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80093f:	ba 00 00 00 00       	mov    $0x0,%edx
  800944:	b8 02 00 00 00       	mov    $0x2,%eax
  800949:	e8 8b ff ff ff       	call   8008d9 <fsipc>
}
  80094e:	c9                   	leave  
  80094f:	c3                   	ret    

00800950 <devfile_flush>:
{
  800950:	55                   	push   %ebp
  800951:	89 e5                	mov    %esp,%ebp
  800953:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800956:	8b 45 08             	mov    0x8(%ebp),%eax
  800959:	8b 40 0c             	mov    0xc(%eax),%eax
  80095c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800961:	ba 00 00 00 00       	mov    $0x0,%edx
  800966:	b8 06 00 00 00       	mov    $0x6,%eax
  80096b:	e8 69 ff ff ff       	call   8008d9 <fsipc>
}
  800970:	c9                   	leave  
  800971:	c3                   	ret    

00800972 <devfile_stat>:
{
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
  800975:	53                   	push   %ebx
  800976:	83 ec 04             	sub    $0x4,%esp
  800979:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80097c:	8b 45 08             	mov    0x8(%ebp),%eax
  80097f:	8b 40 0c             	mov    0xc(%eax),%eax
  800982:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800987:	ba 00 00 00 00       	mov    $0x0,%edx
  80098c:	b8 05 00 00 00       	mov    $0x5,%eax
  800991:	e8 43 ff ff ff       	call   8008d9 <fsipc>
  800996:	85 c0                	test   %eax,%eax
  800998:	78 2c                	js     8009c6 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80099a:	83 ec 08             	sub    $0x8,%esp
  80099d:	68 00 50 80 00       	push   $0x805000
  8009a2:	53                   	push   %ebx
  8009a3:	e8 47 0d 00 00       	call   8016ef <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009a8:	a1 80 50 80 00       	mov    0x805080,%eax
  8009ad:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009b3:	a1 84 50 80 00       	mov    0x805084,%eax
  8009b8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009be:	83 c4 10             	add    $0x10,%esp
  8009c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009c9:	c9                   	leave  
  8009ca:	c3                   	ret    

008009cb <devfile_write>:
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	83 ec 0c             	sub    $0xc,%esp
  8009d1:	8b 45 10             	mov    0x10(%ebp),%eax
    	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8009d7:	8b 52 0c             	mov    0xc(%edx),%edx
  8009da:	89 15 00 50 80 00    	mov    %edx,0x805000
    	fsipcbuf.write.req_n = n;
  8009e0:	a3 04 50 80 00       	mov    %eax,0x805004
    	memmove(fsipcbuf.write.req_buf, buf, n);
  8009e5:	50                   	push   %eax
  8009e6:	ff 75 0c             	pushl  0xc(%ebp)
  8009e9:	68 08 50 80 00       	push   $0x805008
  8009ee:	e8 8a 0e 00 00       	call   80187d <memmove>
    	return fsipc(FSREQ_WRITE, NULL);
  8009f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8009f8:	b8 04 00 00 00       	mov    $0x4,%eax
  8009fd:	e8 d7 fe ff ff       	call   8008d9 <fsipc>
}
  800a02:	c9                   	leave  
  800a03:	c3                   	ret    

00800a04 <devfile_read>:
{
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	56                   	push   %esi
  800a08:	53                   	push   %ebx
  800a09:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0f:	8b 40 0c             	mov    0xc(%eax),%eax
  800a12:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a17:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a1d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a22:	b8 03 00 00 00       	mov    $0x3,%eax
  800a27:	e8 ad fe ff ff       	call   8008d9 <fsipc>
  800a2c:	89 c3                	mov    %eax,%ebx
  800a2e:	85 c0                	test   %eax,%eax
  800a30:	78 1f                	js     800a51 <devfile_read+0x4d>
	assert(r <= n);
  800a32:	39 f0                	cmp    %esi,%eax
  800a34:	77 24                	ja     800a5a <devfile_read+0x56>
	assert(r <= PGSIZE);
  800a36:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a3b:	7f 33                	jg     800a70 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a3d:	83 ec 04             	sub    $0x4,%esp
  800a40:	50                   	push   %eax
  800a41:	68 00 50 80 00       	push   $0x805000
  800a46:	ff 75 0c             	pushl  0xc(%ebp)
  800a49:	e8 2f 0e 00 00       	call   80187d <memmove>
	return r;
  800a4e:	83 c4 10             	add    $0x10,%esp
}
  800a51:	89 d8                	mov    %ebx,%eax
  800a53:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a56:	5b                   	pop    %ebx
  800a57:	5e                   	pop    %esi
  800a58:	5d                   	pop    %ebp
  800a59:	c3                   	ret    
	assert(r <= n);
  800a5a:	68 64 1e 80 00       	push   $0x801e64
  800a5f:	68 6b 1e 80 00       	push   $0x801e6b
  800a64:	6a 7c                	push   $0x7c
  800a66:	68 80 1e 80 00       	push   $0x801e80
  800a6b:	e8 85 05 00 00       	call   800ff5 <_panic>
	assert(r <= PGSIZE);
  800a70:	68 8b 1e 80 00       	push   $0x801e8b
  800a75:	68 6b 1e 80 00       	push   $0x801e6b
  800a7a:	6a 7d                	push   $0x7d
  800a7c:	68 80 1e 80 00       	push   $0x801e80
  800a81:	e8 6f 05 00 00       	call   800ff5 <_panic>

00800a86 <open>:
{
  800a86:	55                   	push   %ebp
  800a87:	89 e5                	mov    %esp,%ebp
  800a89:	56                   	push   %esi
  800a8a:	53                   	push   %ebx
  800a8b:	83 ec 1c             	sub    $0x1c,%esp
  800a8e:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800a91:	56                   	push   %esi
  800a92:	e8 21 0c 00 00       	call   8016b8 <strlen>
  800a97:	83 c4 10             	add    $0x10,%esp
  800a9a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800a9f:	7f 6c                	jg     800b0d <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  800aa1:	83 ec 0c             	sub    $0xc,%esp
  800aa4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800aa7:	50                   	push   %eax
  800aa8:	e8 c1 f8 ff ff       	call   80036e <fd_alloc>
  800aad:	89 c3                	mov    %eax,%ebx
  800aaf:	83 c4 10             	add    $0x10,%esp
  800ab2:	85 c0                	test   %eax,%eax
  800ab4:	78 3c                	js     800af2 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  800ab6:	83 ec 08             	sub    $0x8,%esp
  800ab9:	56                   	push   %esi
  800aba:	68 00 50 80 00       	push   $0x805000
  800abf:	e8 2b 0c 00 00       	call   8016ef <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ac4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac7:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800acc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800acf:	b8 01 00 00 00       	mov    $0x1,%eax
  800ad4:	e8 00 fe ff ff       	call   8008d9 <fsipc>
  800ad9:	89 c3                	mov    %eax,%ebx
  800adb:	83 c4 10             	add    $0x10,%esp
  800ade:	85 c0                	test   %eax,%eax
  800ae0:	78 19                	js     800afb <open+0x75>
	return fd2num(fd);
  800ae2:	83 ec 0c             	sub    $0xc,%esp
  800ae5:	ff 75 f4             	pushl  -0xc(%ebp)
  800ae8:	e8 5a f8 ff ff       	call   800347 <fd2num>
  800aed:	89 c3                	mov    %eax,%ebx
  800aef:	83 c4 10             	add    $0x10,%esp
}
  800af2:	89 d8                	mov    %ebx,%eax
  800af4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800af7:	5b                   	pop    %ebx
  800af8:	5e                   	pop    %esi
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    
		fd_close(fd, 0);
  800afb:	83 ec 08             	sub    $0x8,%esp
  800afe:	6a 00                	push   $0x0
  800b00:	ff 75 f4             	pushl  -0xc(%ebp)
  800b03:	e8 61 f9 ff ff       	call   800469 <fd_close>
		return r;
  800b08:	83 c4 10             	add    $0x10,%esp
  800b0b:	eb e5                	jmp    800af2 <open+0x6c>
		return -E_BAD_PATH;
  800b0d:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b12:	eb de                	jmp    800af2 <open+0x6c>

00800b14 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b1a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1f:	b8 08 00 00 00       	mov    $0x8,%eax
  800b24:	e8 b0 fd ff ff       	call   8008d9 <fsipc>
}
  800b29:	c9                   	leave  
  800b2a:	c3                   	ret    

00800b2b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b2b:	55                   	push   %ebp
  800b2c:	89 e5                	mov    %esp,%ebp
  800b2e:	56                   	push   %esi
  800b2f:	53                   	push   %ebx
  800b30:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b33:	83 ec 0c             	sub    $0xc,%esp
  800b36:	ff 75 08             	pushl  0x8(%ebp)
  800b39:	e8 19 f8 ff ff       	call   800357 <fd2data>
  800b3e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b40:	83 c4 08             	add    $0x8,%esp
  800b43:	68 97 1e 80 00       	push   $0x801e97
  800b48:	53                   	push   %ebx
  800b49:	e8 a1 0b 00 00       	call   8016ef <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b4e:	8b 46 04             	mov    0x4(%esi),%eax
  800b51:	2b 06                	sub    (%esi),%eax
  800b53:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b59:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b60:	00 00 00 
	stat->st_dev = &devpipe;
  800b63:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b6a:	30 80 00 
	return 0;
}
  800b6d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b72:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b75:	5b                   	pop    %ebx
  800b76:	5e                   	pop    %esi
  800b77:	5d                   	pop    %ebp
  800b78:	c3                   	ret    

00800b79 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b79:	55                   	push   %ebp
  800b7a:	89 e5                	mov    %esp,%ebp
  800b7c:	53                   	push   %ebx
  800b7d:	83 ec 0c             	sub    $0xc,%esp
  800b80:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b83:	53                   	push   %ebx
  800b84:	6a 00                	push   $0x0
  800b86:	e8 50 f6 ff ff       	call   8001db <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b8b:	89 1c 24             	mov    %ebx,(%esp)
  800b8e:	e8 c4 f7 ff ff       	call   800357 <fd2data>
  800b93:	83 c4 08             	add    $0x8,%esp
  800b96:	50                   	push   %eax
  800b97:	6a 00                	push   $0x0
  800b99:	e8 3d f6 ff ff       	call   8001db <sys_page_unmap>
}
  800b9e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ba1:	c9                   	leave  
  800ba2:	c3                   	ret    

00800ba3 <_pipeisclosed>:
{
  800ba3:	55                   	push   %ebp
  800ba4:	89 e5                	mov    %esp,%ebp
  800ba6:	57                   	push   %edi
  800ba7:	56                   	push   %esi
  800ba8:	53                   	push   %ebx
  800ba9:	83 ec 1c             	sub    $0x1c,%esp
  800bac:	89 c7                	mov    %eax,%edi
  800bae:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800bb0:	a1 04 40 80 00       	mov    0x804004,%eax
  800bb5:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800bb8:	83 ec 0c             	sub    $0xc,%esp
  800bbb:	57                   	push   %edi
  800bbc:	e8 5f 0f 00 00       	call   801b20 <pageref>
  800bc1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800bc4:	89 34 24             	mov    %esi,(%esp)
  800bc7:	e8 54 0f 00 00       	call   801b20 <pageref>
		nn = thisenv->env_runs;
  800bcc:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800bd2:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800bd5:	83 c4 10             	add    $0x10,%esp
  800bd8:	39 cb                	cmp    %ecx,%ebx
  800bda:	74 1b                	je     800bf7 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800bdc:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800bdf:	75 cf                	jne    800bb0 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800be1:	8b 42 58             	mov    0x58(%edx),%eax
  800be4:	6a 01                	push   $0x1
  800be6:	50                   	push   %eax
  800be7:	53                   	push   %ebx
  800be8:	68 9e 1e 80 00       	push   $0x801e9e
  800bed:	e8 de 04 00 00       	call   8010d0 <cprintf>
  800bf2:	83 c4 10             	add    $0x10,%esp
  800bf5:	eb b9                	jmp    800bb0 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800bf7:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800bfa:	0f 94 c0             	sete   %al
  800bfd:	0f b6 c0             	movzbl %al,%eax
}
  800c00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c03:	5b                   	pop    %ebx
  800c04:	5e                   	pop    %esi
  800c05:	5f                   	pop    %edi
  800c06:	5d                   	pop    %ebp
  800c07:	c3                   	ret    

00800c08 <devpipe_write>:
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	57                   	push   %edi
  800c0c:	56                   	push   %esi
  800c0d:	53                   	push   %ebx
  800c0e:	83 ec 28             	sub    $0x28,%esp
  800c11:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800c14:	56                   	push   %esi
  800c15:	e8 3d f7 ff ff       	call   800357 <fd2data>
  800c1a:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c1c:	83 c4 10             	add    $0x10,%esp
  800c1f:	bf 00 00 00 00       	mov    $0x0,%edi
  800c24:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c27:	74 4f                	je     800c78 <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c29:	8b 43 04             	mov    0x4(%ebx),%eax
  800c2c:	8b 0b                	mov    (%ebx),%ecx
  800c2e:	8d 51 20             	lea    0x20(%ecx),%edx
  800c31:	39 d0                	cmp    %edx,%eax
  800c33:	72 14                	jb     800c49 <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  800c35:	89 da                	mov    %ebx,%edx
  800c37:	89 f0                	mov    %esi,%eax
  800c39:	e8 65 ff ff ff       	call   800ba3 <_pipeisclosed>
  800c3e:	85 c0                	test   %eax,%eax
  800c40:	75 3a                	jne    800c7c <devpipe_write+0x74>
			sys_yield();
  800c42:	e8 f0 f4 ff ff       	call   800137 <sys_yield>
  800c47:	eb e0                	jmp    800c29 <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c50:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c53:	89 c2                	mov    %eax,%edx
  800c55:	c1 fa 1f             	sar    $0x1f,%edx
  800c58:	89 d1                	mov    %edx,%ecx
  800c5a:	c1 e9 1b             	shr    $0x1b,%ecx
  800c5d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c60:	83 e2 1f             	and    $0x1f,%edx
  800c63:	29 ca                	sub    %ecx,%edx
  800c65:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c69:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c6d:	83 c0 01             	add    $0x1,%eax
  800c70:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800c73:	83 c7 01             	add    $0x1,%edi
  800c76:	eb ac                	jmp    800c24 <devpipe_write+0x1c>
	return i;
  800c78:	89 f8                	mov    %edi,%eax
  800c7a:	eb 05                	jmp    800c81 <devpipe_write+0x79>
				return 0;
  800c7c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c84:	5b                   	pop    %ebx
  800c85:	5e                   	pop    %esi
  800c86:	5f                   	pop    %edi
  800c87:	5d                   	pop    %ebp
  800c88:	c3                   	ret    

00800c89 <devpipe_read>:
{
  800c89:	55                   	push   %ebp
  800c8a:	89 e5                	mov    %esp,%ebp
  800c8c:	57                   	push   %edi
  800c8d:	56                   	push   %esi
  800c8e:	53                   	push   %ebx
  800c8f:	83 ec 18             	sub    $0x18,%esp
  800c92:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800c95:	57                   	push   %edi
  800c96:	e8 bc f6 ff ff       	call   800357 <fd2data>
  800c9b:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c9d:	83 c4 10             	add    $0x10,%esp
  800ca0:	be 00 00 00 00       	mov    $0x0,%esi
  800ca5:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ca8:	74 47                	je     800cf1 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  800caa:	8b 03                	mov    (%ebx),%eax
  800cac:	3b 43 04             	cmp    0x4(%ebx),%eax
  800caf:	75 22                	jne    800cd3 <devpipe_read+0x4a>
			if (i > 0)
  800cb1:	85 f6                	test   %esi,%esi
  800cb3:	75 14                	jne    800cc9 <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  800cb5:	89 da                	mov    %ebx,%edx
  800cb7:	89 f8                	mov    %edi,%eax
  800cb9:	e8 e5 fe ff ff       	call   800ba3 <_pipeisclosed>
  800cbe:	85 c0                	test   %eax,%eax
  800cc0:	75 33                	jne    800cf5 <devpipe_read+0x6c>
			sys_yield();
  800cc2:	e8 70 f4 ff ff       	call   800137 <sys_yield>
  800cc7:	eb e1                	jmp    800caa <devpipe_read+0x21>
				return i;
  800cc9:	89 f0                	mov    %esi,%eax
}
  800ccb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cce:	5b                   	pop    %ebx
  800ccf:	5e                   	pop    %esi
  800cd0:	5f                   	pop    %edi
  800cd1:	5d                   	pop    %ebp
  800cd2:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cd3:	99                   	cltd   
  800cd4:	c1 ea 1b             	shr    $0x1b,%edx
  800cd7:	01 d0                	add    %edx,%eax
  800cd9:	83 e0 1f             	and    $0x1f,%eax
  800cdc:	29 d0                	sub    %edx,%eax
  800cde:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800ce3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce6:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800ce9:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800cec:	83 c6 01             	add    $0x1,%esi
  800cef:	eb b4                	jmp    800ca5 <devpipe_read+0x1c>
	return i;
  800cf1:	89 f0                	mov    %esi,%eax
  800cf3:	eb d6                	jmp    800ccb <devpipe_read+0x42>
				return 0;
  800cf5:	b8 00 00 00 00       	mov    $0x0,%eax
  800cfa:	eb cf                	jmp    800ccb <devpipe_read+0x42>

00800cfc <pipe>:
{
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
  800cff:	56                   	push   %esi
  800d00:	53                   	push   %ebx
  800d01:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800d04:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d07:	50                   	push   %eax
  800d08:	e8 61 f6 ff ff       	call   80036e <fd_alloc>
  800d0d:	89 c3                	mov    %eax,%ebx
  800d0f:	83 c4 10             	add    $0x10,%esp
  800d12:	85 c0                	test   %eax,%eax
  800d14:	78 5b                	js     800d71 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d16:	83 ec 04             	sub    $0x4,%esp
  800d19:	68 07 04 00 00       	push   $0x407
  800d1e:	ff 75 f4             	pushl  -0xc(%ebp)
  800d21:	6a 00                	push   $0x0
  800d23:	e8 2e f4 ff ff       	call   800156 <sys_page_alloc>
  800d28:	89 c3                	mov    %eax,%ebx
  800d2a:	83 c4 10             	add    $0x10,%esp
  800d2d:	85 c0                	test   %eax,%eax
  800d2f:	78 40                	js     800d71 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  800d31:	83 ec 0c             	sub    $0xc,%esp
  800d34:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d37:	50                   	push   %eax
  800d38:	e8 31 f6 ff ff       	call   80036e <fd_alloc>
  800d3d:	89 c3                	mov    %eax,%ebx
  800d3f:	83 c4 10             	add    $0x10,%esp
  800d42:	85 c0                	test   %eax,%eax
  800d44:	78 1b                	js     800d61 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d46:	83 ec 04             	sub    $0x4,%esp
  800d49:	68 07 04 00 00       	push   $0x407
  800d4e:	ff 75 f0             	pushl  -0x10(%ebp)
  800d51:	6a 00                	push   $0x0
  800d53:	e8 fe f3 ff ff       	call   800156 <sys_page_alloc>
  800d58:	89 c3                	mov    %eax,%ebx
  800d5a:	83 c4 10             	add    $0x10,%esp
  800d5d:	85 c0                	test   %eax,%eax
  800d5f:	79 19                	jns    800d7a <pipe+0x7e>
	sys_page_unmap(0, fd0);
  800d61:	83 ec 08             	sub    $0x8,%esp
  800d64:	ff 75 f4             	pushl  -0xc(%ebp)
  800d67:	6a 00                	push   $0x0
  800d69:	e8 6d f4 ff ff       	call   8001db <sys_page_unmap>
  800d6e:	83 c4 10             	add    $0x10,%esp
}
  800d71:	89 d8                	mov    %ebx,%eax
  800d73:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d76:	5b                   	pop    %ebx
  800d77:	5e                   	pop    %esi
  800d78:	5d                   	pop    %ebp
  800d79:	c3                   	ret    
	va = fd2data(fd0);
  800d7a:	83 ec 0c             	sub    $0xc,%esp
  800d7d:	ff 75 f4             	pushl  -0xc(%ebp)
  800d80:	e8 d2 f5 ff ff       	call   800357 <fd2data>
  800d85:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d87:	83 c4 0c             	add    $0xc,%esp
  800d8a:	68 07 04 00 00       	push   $0x407
  800d8f:	50                   	push   %eax
  800d90:	6a 00                	push   $0x0
  800d92:	e8 bf f3 ff ff       	call   800156 <sys_page_alloc>
  800d97:	89 c3                	mov    %eax,%ebx
  800d99:	83 c4 10             	add    $0x10,%esp
  800d9c:	85 c0                	test   %eax,%eax
  800d9e:	0f 88 8c 00 00 00    	js     800e30 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800da4:	83 ec 0c             	sub    $0xc,%esp
  800da7:	ff 75 f0             	pushl  -0x10(%ebp)
  800daa:	e8 a8 f5 ff ff       	call   800357 <fd2data>
  800daf:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800db6:	50                   	push   %eax
  800db7:	6a 00                	push   $0x0
  800db9:	56                   	push   %esi
  800dba:	6a 00                	push   $0x0
  800dbc:	e8 d8 f3 ff ff       	call   800199 <sys_page_map>
  800dc1:	89 c3                	mov    %eax,%ebx
  800dc3:	83 c4 20             	add    $0x20,%esp
  800dc6:	85 c0                	test   %eax,%eax
  800dc8:	78 58                	js     800e22 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  800dca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dcd:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800dd3:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800dd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dd8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  800ddf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800de2:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800de8:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800dea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ded:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800df4:	83 ec 0c             	sub    $0xc,%esp
  800df7:	ff 75 f4             	pushl  -0xc(%ebp)
  800dfa:	e8 48 f5 ff ff       	call   800347 <fd2num>
  800dff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e02:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e04:	83 c4 04             	add    $0x4,%esp
  800e07:	ff 75 f0             	pushl  -0x10(%ebp)
  800e0a:	e8 38 f5 ff ff       	call   800347 <fd2num>
  800e0f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e12:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e15:	83 c4 10             	add    $0x10,%esp
  800e18:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e1d:	e9 4f ff ff ff       	jmp    800d71 <pipe+0x75>
	sys_page_unmap(0, va);
  800e22:	83 ec 08             	sub    $0x8,%esp
  800e25:	56                   	push   %esi
  800e26:	6a 00                	push   $0x0
  800e28:	e8 ae f3 ff ff       	call   8001db <sys_page_unmap>
  800e2d:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800e30:	83 ec 08             	sub    $0x8,%esp
  800e33:	ff 75 f0             	pushl  -0x10(%ebp)
  800e36:	6a 00                	push   $0x0
  800e38:	e8 9e f3 ff ff       	call   8001db <sys_page_unmap>
  800e3d:	83 c4 10             	add    $0x10,%esp
  800e40:	e9 1c ff ff ff       	jmp    800d61 <pipe+0x65>

00800e45 <pipeisclosed>:
{
  800e45:	55                   	push   %ebp
  800e46:	89 e5                	mov    %esp,%ebp
  800e48:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e4b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e4e:	50                   	push   %eax
  800e4f:	ff 75 08             	pushl  0x8(%ebp)
  800e52:	e8 66 f5 ff ff       	call   8003bd <fd_lookup>
  800e57:	83 c4 10             	add    $0x10,%esp
  800e5a:	85 c0                	test   %eax,%eax
  800e5c:	78 18                	js     800e76 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  800e5e:	83 ec 0c             	sub    $0xc,%esp
  800e61:	ff 75 f4             	pushl  -0xc(%ebp)
  800e64:	e8 ee f4 ff ff       	call   800357 <fd2data>
	return _pipeisclosed(fd, p);
  800e69:	89 c2                	mov    %eax,%edx
  800e6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e6e:	e8 30 fd ff ff       	call   800ba3 <_pipeisclosed>
  800e73:	83 c4 10             	add    $0x10,%esp
}
  800e76:	c9                   	leave  
  800e77:	c3                   	ret    

00800e78 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800e78:	55                   	push   %ebp
  800e79:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800e7b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e80:	5d                   	pop    %ebp
  800e81:	c3                   	ret    

00800e82 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e82:	55                   	push   %ebp
  800e83:	89 e5                	mov    %esp,%ebp
  800e85:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e88:	68 b6 1e 80 00       	push   $0x801eb6
  800e8d:	ff 75 0c             	pushl  0xc(%ebp)
  800e90:	e8 5a 08 00 00       	call   8016ef <strcpy>
	return 0;
}
  800e95:	b8 00 00 00 00       	mov    $0x0,%eax
  800e9a:	c9                   	leave  
  800e9b:	c3                   	ret    

00800e9c <devcons_write>:
{
  800e9c:	55                   	push   %ebp
  800e9d:	89 e5                	mov    %esp,%ebp
  800e9f:	57                   	push   %edi
  800ea0:	56                   	push   %esi
  800ea1:	53                   	push   %ebx
  800ea2:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800ea8:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800ead:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800eb3:	eb 2f                	jmp    800ee4 <devcons_write+0x48>
		m = n - tot;
  800eb5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eb8:	29 f3                	sub    %esi,%ebx
  800eba:	83 fb 7f             	cmp    $0x7f,%ebx
  800ebd:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800ec2:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800ec5:	83 ec 04             	sub    $0x4,%esp
  800ec8:	53                   	push   %ebx
  800ec9:	89 f0                	mov    %esi,%eax
  800ecb:	03 45 0c             	add    0xc(%ebp),%eax
  800ece:	50                   	push   %eax
  800ecf:	57                   	push   %edi
  800ed0:	e8 a8 09 00 00       	call   80187d <memmove>
		sys_cputs(buf, m);
  800ed5:	83 c4 08             	add    $0x8,%esp
  800ed8:	53                   	push   %ebx
  800ed9:	57                   	push   %edi
  800eda:	e8 bb f1 ff ff       	call   80009a <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800edf:	01 de                	add    %ebx,%esi
  800ee1:	83 c4 10             	add    $0x10,%esp
  800ee4:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ee7:	72 cc                	jb     800eb5 <devcons_write+0x19>
}
  800ee9:	89 f0                	mov    %esi,%eax
  800eeb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eee:	5b                   	pop    %ebx
  800eef:	5e                   	pop    %esi
  800ef0:	5f                   	pop    %edi
  800ef1:	5d                   	pop    %ebp
  800ef2:	c3                   	ret    

00800ef3 <devcons_read>:
{
  800ef3:	55                   	push   %ebp
  800ef4:	89 e5                	mov    %esp,%ebp
  800ef6:	83 ec 08             	sub    $0x8,%esp
  800ef9:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800efe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f02:	75 07                	jne    800f0b <devcons_read+0x18>
}
  800f04:	c9                   	leave  
  800f05:	c3                   	ret    
		sys_yield();
  800f06:	e8 2c f2 ff ff       	call   800137 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  800f0b:	e8 a8 f1 ff ff       	call   8000b8 <sys_cgetc>
  800f10:	85 c0                	test   %eax,%eax
  800f12:	74 f2                	je     800f06 <devcons_read+0x13>
	if (c < 0)
  800f14:	85 c0                	test   %eax,%eax
  800f16:	78 ec                	js     800f04 <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  800f18:	83 f8 04             	cmp    $0x4,%eax
  800f1b:	74 0c                	je     800f29 <devcons_read+0x36>
	*(char*)vbuf = c;
  800f1d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f20:	88 02                	mov    %al,(%edx)
	return 1;
  800f22:	b8 01 00 00 00       	mov    $0x1,%eax
  800f27:	eb db                	jmp    800f04 <devcons_read+0x11>
		return 0;
  800f29:	b8 00 00 00 00       	mov    $0x0,%eax
  800f2e:	eb d4                	jmp    800f04 <devcons_read+0x11>

00800f30 <cputchar>:
{
  800f30:	55                   	push   %ebp
  800f31:	89 e5                	mov    %esp,%ebp
  800f33:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f36:	8b 45 08             	mov    0x8(%ebp),%eax
  800f39:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800f3c:	6a 01                	push   $0x1
  800f3e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f41:	50                   	push   %eax
  800f42:	e8 53 f1 ff ff       	call   80009a <sys_cputs>
}
  800f47:	83 c4 10             	add    $0x10,%esp
  800f4a:	c9                   	leave  
  800f4b:	c3                   	ret    

00800f4c <getchar>:
{
  800f4c:	55                   	push   %ebp
  800f4d:	89 e5                	mov    %esp,%ebp
  800f4f:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800f52:	6a 01                	push   $0x1
  800f54:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f57:	50                   	push   %eax
  800f58:	6a 00                	push   $0x0
  800f5a:	e8 cf f6 ff ff       	call   80062e <read>
	if (r < 0)
  800f5f:	83 c4 10             	add    $0x10,%esp
  800f62:	85 c0                	test   %eax,%eax
  800f64:	78 08                	js     800f6e <getchar+0x22>
	if (r < 1)
  800f66:	85 c0                	test   %eax,%eax
  800f68:	7e 06                	jle    800f70 <getchar+0x24>
	return c;
  800f6a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800f6e:	c9                   	leave  
  800f6f:	c3                   	ret    
		return -E_EOF;
  800f70:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800f75:	eb f7                	jmp    800f6e <getchar+0x22>

00800f77 <iscons>:
{
  800f77:	55                   	push   %ebp
  800f78:	89 e5                	mov    %esp,%ebp
  800f7a:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f7d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f80:	50                   	push   %eax
  800f81:	ff 75 08             	pushl  0x8(%ebp)
  800f84:	e8 34 f4 ff ff       	call   8003bd <fd_lookup>
  800f89:	83 c4 10             	add    $0x10,%esp
  800f8c:	85 c0                	test   %eax,%eax
  800f8e:	78 11                	js     800fa1 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  800f90:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f93:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800f99:	39 10                	cmp    %edx,(%eax)
  800f9b:	0f 94 c0             	sete   %al
  800f9e:	0f b6 c0             	movzbl %al,%eax
}
  800fa1:	c9                   	leave  
  800fa2:	c3                   	ret    

00800fa3 <opencons>:
{
  800fa3:	55                   	push   %ebp
  800fa4:	89 e5                	mov    %esp,%ebp
  800fa6:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800fa9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fac:	50                   	push   %eax
  800fad:	e8 bc f3 ff ff       	call   80036e <fd_alloc>
  800fb2:	83 c4 10             	add    $0x10,%esp
  800fb5:	85 c0                	test   %eax,%eax
  800fb7:	78 3a                	js     800ff3 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fb9:	83 ec 04             	sub    $0x4,%esp
  800fbc:	68 07 04 00 00       	push   $0x407
  800fc1:	ff 75 f4             	pushl  -0xc(%ebp)
  800fc4:	6a 00                	push   $0x0
  800fc6:	e8 8b f1 ff ff       	call   800156 <sys_page_alloc>
  800fcb:	83 c4 10             	add    $0x10,%esp
  800fce:	85 c0                	test   %eax,%eax
  800fd0:	78 21                	js     800ff3 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  800fd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fd5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fdb:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800fdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fe0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800fe7:	83 ec 0c             	sub    $0xc,%esp
  800fea:	50                   	push   %eax
  800feb:	e8 57 f3 ff ff       	call   800347 <fd2num>
  800ff0:	83 c4 10             	add    $0x10,%esp
}
  800ff3:	c9                   	leave  
  800ff4:	c3                   	ret    

00800ff5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800ff5:	55                   	push   %ebp
  800ff6:	89 e5                	mov    %esp,%ebp
  800ff8:	56                   	push   %esi
  800ff9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800ffa:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800ffd:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801003:	e8 10 f1 ff ff       	call   800118 <sys_getenvid>
  801008:	83 ec 0c             	sub    $0xc,%esp
  80100b:	ff 75 0c             	pushl  0xc(%ebp)
  80100e:	ff 75 08             	pushl  0x8(%ebp)
  801011:	56                   	push   %esi
  801012:	50                   	push   %eax
  801013:	68 c4 1e 80 00       	push   $0x801ec4
  801018:	e8 b3 00 00 00       	call   8010d0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80101d:	83 c4 18             	add    $0x18,%esp
  801020:	53                   	push   %ebx
  801021:	ff 75 10             	pushl  0x10(%ebp)
  801024:	e8 56 00 00 00       	call   80107f <vcprintf>
	cprintf("\n");
  801029:	c7 04 24 af 1e 80 00 	movl   $0x801eaf,(%esp)
  801030:	e8 9b 00 00 00       	call   8010d0 <cprintf>
  801035:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801038:	cc                   	int3   
  801039:	eb fd                	jmp    801038 <_panic+0x43>

0080103b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80103b:	55                   	push   %ebp
  80103c:	89 e5                	mov    %esp,%ebp
  80103e:	53                   	push   %ebx
  80103f:	83 ec 04             	sub    $0x4,%esp
  801042:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801045:	8b 13                	mov    (%ebx),%edx
  801047:	8d 42 01             	lea    0x1(%edx),%eax
  80104a:	89 03                	mov    %eax,(%ebx)
  80104c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80104f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801053:	3d ff 00 00 00       	cmp    $0xff,%eax
  801058:	74 09                	je     801063 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80105a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80105e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801061:	c9                   	leave  
  801062:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801063:	83 ec 08             	sub    $0x8,%esp
  801066:	68 ff 00 00 00       	push   $0xff
  80106b:	8d 43 08             	lea    0x8(%ebx),%eax
  80106e:	50                   	push   %eax
  80106f:	e8 26 f0 ff ff       	call   80009a <sys_cputs>
		b->idx = 0;
  801074:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80107a:	83 c4 10             	add    $0x10,%esp
  80107d:	eb db                	jmp    80105a <putch+0x1f>

0080107f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80107f:	55                   	push   %ebp
  801080:	89 e5                	mov    %esp,%ebp
  801082:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801088:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80108f:	00 00 00 
	b.cnt = 0;
  801092:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801099:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80109c:	ff 75 0c             	pushl  0xc(%ebp)
  80109f:	ff 75 08             	pushl  0x8(%ebp)
  8010a2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010a8:	50                   	push   %eax
  8010a9:	68 3b 10 80 00       	push   $0x80103b
  8010ae:	e8 1a 01 00 00       	call   8011cd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010b3:	83 c4 08             	add    $0x8,%esp
  8010b6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010bc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010c2:	50                   	push   %eax
  8010c3:	e8 d2 ef ff ff       	call   80009a <sys_cputs>

	return b.cnt;
}
  8010c8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010ce:	c9                   	leave  
  8010cf:	c3                   	ret    

008010d0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010d0:	55                   	push   %ebp
  8010d1:	89 e5                	mov    %esp,%ebp
  8010d3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010d6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010d9:	50                   	push   %eax
  8010da:	ff 75 08             	pushl  0x8(%ebp)
  8010dd:	e8 9d ff ff ff       	call   80107f <vcprintf>
	va_end(ap);

	return cnt;
}
  8010e2:	c9                   	leave  
  8010e3:	c3                   	ret    

008010e4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010e4:	55                   	push   %ebp
  8010e5:	89 e5                	mov    %esp,%ebp
  8010e7:	57                   	push   %edi
  8010e8:	56                   	push   %esi
  8010e9:	53                   	push   %ebx
  8010ea:	83 ec 1c             	sub    $0x1c,%esp
  8010ed:	89 c7                	mov    %eax,%edi
  8010ef:	89 d6                	mov    %edx,%esi
  8010f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8010fa:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8010fd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801100:	bb 00 00 00 00       	mov    $0x0,%ebx
  801105:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801108:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80110b:	39 d3                	cmp    %edx,%ebx
  80110d:	72 05                	jb     801114 <printnum+0x30>
  80110f:	39 45 10             	cmp    %eax,0x10(%ebp)
  801112:	77 7a                	ja     80118e <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801114:	83 ec 0c             	sub    $0xc,%esp
  801117:	ff 75 18             	pushl  0x18(%ebp)
  80111a:	8b 45 14             	mov    0x14(%ebp),%eax
  80111d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801120:	53                   	push   %ebx
  801121:	ff 75 10             	pushl  0x10(%ebp)
  801124:	83 ec 08             	sub    $0x8,%esp
  801127:	ff 75 e4             	pushl  -0x1c(%ebp)
  80112a:	ff 75 e0             	pushl  -0x20(%ebp)
  80112d:	ff 75 dc             	pushl  -0x24(%ebp)
  801130:	ff 75 d8             	pushl  -0x28(%ebp)
  801133:	e8 28 0a 00 00       	call   801b60 <__udivdi3>
  801138:	83 c4 18             	add    $0x18,%esp
  80113b:	52                   	push   %edx
  80113c:	50                   	push   %eax
  80113d:	89 f2                	mov    %esi,%edx
  80113f:	89 f8                	mov    %edi,%eax
  801141:	e8 9e ff ff ff       	call   8010e4 <printnum>
  801146:	83 c4 20             	add    $0x20,%esp
  801149:	eb 13                	jmp    80115e <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80114b:	83 ec 08             	sub    $0x8,%esp
  80114e:	56                   	push   %esi
  80114f:	ff 75 18             	pushl  0x18(%ebp)
  801152:	ff d7                	call   *%edi
  801154:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801157:	83 eb 01             	sub    $0x1,%ebx
  80115a:	85 db                	test   %ebx,%ebx
  80115c:	7f ed                	jg     80114b <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80115e:	83 ec 08             	sub    $0x8,%esp
  801161:	56                   	push   %esi
  801162:	83 ec 04             	sub    $0x4,%esp
  801165:	ff 75 e4             	pushl  -0x1c(%ebp)
  801168:	ff 75 e0             	pushl  -0x20(%ebp)
  80116b:	ff 75 dc             	pushl  -0x24(%ebp)
  80116e:	ff 75 d8             	pushl  -0x28(%ebp)
  801171:	e8 0a 0b 00 00       	call   801c80 <__umoddi3>
  801176:	83 c4 14             	add    $0x14,%esp
  801179:	0f be 80 e7 1e 80 00 	movsbl 0x801ee7(%eax),%eax
  801180:	50                   	push   %eax
  801181:	ff d7                	call   *%edi
}
  801183:	83 c4 10             	add    $0x10,%esp
  801186:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801189:	5b                   	pop    %ebx
  80118a:	5e                   	pop    %esi
  80118b:	5f                   	pop    %edi
  80118c:	5d                   	pop    %ebp
  80118d:	c3                   	ret    
  80118e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801191:	eb c4                	jmp    801157 <printnum+0x73>

00801193 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801193:	55                   	push   %ebp
  801194:	89 e5                	mov    %esp,%ebp
  801196:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801199:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80119d:	8b 10                	mov    (%eax),%edx
  80119f:	3b 50 04             	cmp    0x4(%eax),%edx
  8011a2:	73 0a                	jae    8011ae <sprintputch+0x1b>
		*b->buf++ = ch;
  8011a4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011a7:	89 08                	mov    %ecx,(%eax)
  8011a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ac:	88 02                	mov    %al,(%edx)
}
  8011ae:	5d                   	pop    %ebp
  8011af:	c3                   	ret    

008011b0 <printfmt>:
{
  8011b0:	55                   	push   %ebp
  8011b1:	89 e5                	mov    %esp,%ebp
  8011b3:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8011b6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011b9:	50                   	push   %eax
  8011ba:	ff 75 10             	pushl  0x10(%ebp)
  8011bd:	ff 75 0c             	pushl  0xc(%ebp)
  8011c0:	ff 75 08             	pushl  0x8(%ebp)
  8011c3:	e8 05 00 00 00       	call   8011cd <vprintfmt>
}
  8011c8:	83 c4 10             	add    $0x10,%esp
  8011cb:	c9                   	leave  
  8011cc:	c3                   	ret    

008011cd <vprintfmt>:
{
  8011cd:	55                   	push   %ebp
  8011ce:	89 e5                	mov    %esp,%ebp
  8011d0:	57                   	push   %edi
  8011d1:	56                   	push   %esi
  8011d2:	53                   	push   %ebx
  8011d3:	83 ec 2c             	sub    $0x2c,%esp
  8011d6:	8b 75 08             	mov    0x8(%ebp),%esi
  8011d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8011dc:	8b 7d 10             	mov    0x10(%ebp),%edi
  8011df:	e9 c1 03 00 00       	jmp    8015a5 <vprintfmt+0x3d8>
		padc = ' ';
  8011e4:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8011e8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8011ef:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8011f6:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8011fd:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801202:	8d 47 01             	lea    0x1(%edi),%eax
  801205:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801208:	0f b6 17             	movzbl (%edi),%edx
  80120b:	8d 42 dd             	lea    -0x23(%edx),%eax
  80120e:	3c 55                	cmp    $0x55,%al
  801210:	0f 87 12 04 00 00    	ja     801628 <vprintfmt+0x45b>
  801216:	0f b6 c0             	movzbl %al,%eax
  801219:	ff 24 85 20 20 80 00 	jmp    *0x802020(,%eax,4)
  801220:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801223:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  801227:	eb d9                	jmp    801202 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  801229:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80122c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801230:	eb d0                	jmp    801202 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  801232:	0f b6 d2             	movzbl %dl,%edx
  801235:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801238:	b8 00 00 00 00       	mov    $0x0,%eax
  80123d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801240:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801243:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801247:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80124a:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80124d:	83 f9 09             	cmp    $0x9,%ecx
  801250:	77 55                	ja     8012a7 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  801252:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801255:	eb e9                	jmp    801240 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  801257:	8b 45 14             	mov    0x14(%ebp),%eax
  80125a:	8b 00                	mov    (%eax),%eax
  80125c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80125f:	8b 45 14             	mov    0x14(%ebp),%eax
  801262:	8d 40 04             	lea    0x4(%eax),%eax
  801265:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801268:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80126b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80126f:	79 91                	jns    801202 <vprintfmt+0x35>
				width = precision, precision = -1;
  801271:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801274:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801277:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80127e:	eb 82                	jmp    801202 <vprintfmt+0x35>
  801280:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801283:	85 c0                	test   %eax,%eax
  801285:	ba 00 00 00 00       	mov    $0x0,%edx
  80128a:	0f 49 d0             	cmovns %eax,%edx
  80128d:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801290:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801293:	e9 6a ff ff ff       	jmp    801202 <vprintfmt+0x35>
  801298:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80129b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012a2:	e9 5b ff ff ff       	jmp    801202 <vprintfmt+0x35>
  8012a7:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8012aa:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012ad:	eb bc                	jmp    80126b <vprintfmt+0x9e>
			lflag++;
  8012af:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8012b5:	e9 48 ff ff ff       	jmp    801202 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8012ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8012bd:	8d 78 04             	lea    0x4(%eax),%edi
  8012c0:	83 ec 08             	sub    $0x8,%esp
  8012c3:	53                   	push   %ebx
  8012c4:	ff 30                	pushl  (%eax)
  8012c6:	ff d6                	call   *%esi
			break;
  8012c8:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8012cb:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8012ce:	e9 cf 02 00 00       	jmp    8015a2 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8012d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8012d6:	8d 78 04             	lea    0x4(%eax),%edi
  8012d9:	8b 00                	mov    (%eax),%eax
  8012db:	99                   	cltd   
  8012dc:	31 d0                	xor    %edx,%eax
  8012de:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8012e0:	83 f8 0f             	cmp    $0xf,%eax
  8012e3:	7f 23                	jg     801308 <vprintfmt+0x13b>
  8012e5:	8b 14 85 80 21 80 00 	mov    0x802180(,%eax,4),%edx
  8012ec:	85 d2                	test   %edx,%edx
  8012ee:	74 18                	je     801308 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8012f0:	52                   	push   %edx
  8012f1:	68 7d 1e 80 00       	push   $0x801e7d
  8012f6:	53                   	push   %ebx
  8012f7:	56                   	push   %esi
  8012f8:	e8 b3 fe ff ff       	call   8011b0 <printfmt>
  8012fd:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801300:	89 7d 14             	mov    %edi,0x14(%ebp)
  801303:	e9 9a 02 00 00       	jmp    8015a2 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  801308:	50                   	push   %eax
  801309:	68 ff 1e 80 00       	push   $0x801eff
  80130e:	53                   	push   %ebx
  80130f:	56                   	push   %esi
  801310:	e8 9b fe ff ff       	call   8011b0 <printfmt>
  801315:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801318:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80131b:	e9 82 02 00 00       	jmp    8015a2 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  801320:	8b 45 14             	mov    0x14(%ebp),%eax
  801323:	83 c0 04             	add    $0x4,%eax
  801326:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801329:	8b 45 14             	mov    0x14(%ebp),%eax
  80132c:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80132e:	85 ff                	test   %edi,%edi
  801330:	b8 f8 1e 80 00       	mov    $0x801ef8,%eax
  801335:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801338:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80133c:	0f 8e bd 00 00 00    	jle    8013ff <vprintfmt+0x232>
  801342:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801346:	75 0e                	jne    801356 <vprintfmt+0x189>
  801348:	89 75 08             	mov    %esi,0x8(%ebp)
  80134b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80134e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801351:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801354:	eb 6d                	jmp    8013c3 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  801356:	83 ec 08             	sub    $0x8,%esp
  801359:	ff 75 d0             	pushl  -0x30(%ebp)
  80135c:	57                   	push   %edi
  80135d:	e8 6e 03 00 00       	call   8016d0 <strnlen>
  801362:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801365:	29 c1                	sub    %eax,%ecx
  801367:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80136a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80136d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801371:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801374:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801377:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  801379:	eb 0f                	jmp    80138a <vprintfmt+0x1bd>
					putch(padc, putdat);
  80137b:	83 ec 08             	sub    $0x8,%esp
  80137e:	53                   	push   %ebx
  80137f:	ff 75 e0             	pushl  -0x20(%ebp)
  801382:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  801384:	83 ef 01             	sub    $0x1,%edi
  801387:	83 c4 10             	add    $0x10,%esp
  80138a:	85 ff                	test   %edi,%edi
  80138c:	7f ed                	jg     80137b <vprintfmt+0x1ae>
  80138e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801391:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  801394:	85 c9                	test   %ecx,%ecx
  801396:	b8 00 00 00 00       	mov    $0x0,%eax
  80139b:	0f 49 c1             	cmovns %ecx,%eax
  80139e:	29 c1                	sub    %eax,%ecx
  8013a0:	89 75 08             	mov    %esi,0x8(%ebp)
  8013a3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8013a6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8013a9:	89 cb                	mov    %ecx,%ebx
  8013ab:	eb 16                	jmp    8013c3 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8013ad:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8013b1:	75 31                	jne    8013e4 <vprintfmt+0x217>
					putch(ch, putdat);
  8013b3:	83 ec 08             	sub    $0x8,%esp
  8013b6:	ff 75 0c             	pushl  0xc(%ebp)
  8013b9:	50                   	push   %eax
  8013ba:	ff 55 08             	call   *0x8(%ebp)
  8013bd:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8013c0:	83 eb 01             	sub    $0x1,%ebx
  8013c3:	83 c7 01             	add    $0x1,%edi
  8013c6:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8013ca:	0f be c2             	movsbl %dl,%eax
  8013cd:	85 c0                	test   %eax,%eax
  8013cf:	74 59                	je     80142a <vprintfmt+0x25d>
  8013d1:	85 f6                	test   %esi,%esi
  8013d3:	78 d8                	js     8013ad <vprintfmt+0x1e0>
  8013d5:	83 ee 01             	sub    $0x1,%esi
  8013d8:	79 d3                	jns    8013ad <vprintfmt+0x1e0>
  8013da:	89 df                	mov    %ebx,%edi
  8013dc:	8b 75 08             	mov    0x8(%ebp),%esi
  8013df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8013e2:	eb 37                	jmp    80141b <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8013e4:	0f be d2             	movsbl %dl,%edx
  8013e7:	83 ea 20             	sub    $0x20,%edx
  8013ea:	83 fa 5e             	cmp    $0x5e,%edx
  8013ed:	76 c4                	jbe    8013b3 <vprintfmt+0x1e6>
					putch('?', putdat);
  8013ef:	83 ec 08             	sub    $0x8,%esp
  8013f2:	ff 75 0c             	pushl  0xc(%ebp)
  8013f5:	6a 3f                	push   $0x3f
  8013f7:	ff 55 08             	call   *0x8(%ebp)
  8013fa:	83 c4 10             	add    $0x10,%esp
  8013fd:	eb c1                	jmp    8013c0 <vprintfmt+0x1f3>
  8013ff:	89 75 08             	mov    %esi,0x8(%ebp)
  801402:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801405:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801408:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80140b:	eb b6                	jmp    8013c3 <vprintfmt+0x1f6>
				putch(' ', putdat);
  80140d:	83 ec 08             	sub    $0x8,%esp
  801410:	53                   	push   %ebx
  801411:	6a 20                	push   $0x20
  801413:	ff d6                	call   *%esi
			for (; width > 0; width--)
  801415:	83 ef 01             	sub    $0x1,%edi
  801418:	83 c4 10             	add    $0x10,%esp
  80141b:	85 ff                	test   %edi,%edi
  80141d:	7f ee                	jg     80140d <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  80141f:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801422:	89 45 14             	mov    %eax,0x14(%ebp)
  801425:	e9 78 01 00 00       	jmp    8015a2 <vprintfmt+0x3d5>
  80142a:	89 df                	mov    %ebx,%edi
  80142c:	8b 75 08             	mov    0x8(%ebp),%esi
  80142f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801432:	eb e7                	jmp    80141b <vprintfmt+0x24e>
	if (lflag >= 2)
  801434:	83 f9 01             	cmp    $0x1,%ecx
  801437:	7e 3f                	jle    801478 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  801439:	8b 45 14             	mov    0x14(%ebp),%eax
  80143c:	8b 50 04             	mov    0x4(%eax),%edx
  80143f:	8b 00                	mov    (%eax),%eax
  801441:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801444:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801447:	8b 45 14             	mov    0x14(%ebp),%eax
  80144a:	8d 40 08             	lea    0x8(%eax),%eax
  80144d:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  801450:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801454:	79 5c                	jns    8014b2 <vprintfmt+0x2e5>
				putch('-', putdat);
  801456:	83 ec 08             	sub    $0x8,%esp
  801459:	53                   	push   %ebx
  80145a:	6a 2d                	push   $0x2d
  80145c:	ff d6                	call   *%esi
				num = -(long long) num;
  80145e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801461:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801464:	f7 da                	neg    %edx
  801466:	83 d1 00             	adc    $0x0,%ecx
  801469:	f7 d9                	neg    %ecx
  80146b:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80146e:	b8 0a 00 00 00       	mov    $0xa,%eax
  801473:	e9 10 01 00 00       	jmp    801588 <vprintfmt+0x3bb>
	else if (lflag)
  801478:	85 c9                	test   %ecx,%ecx
  80147a:	75 1b                	jne    801497 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  80147c:	8b 45 14             	mov    0x14(%ebp),%eax
  80147f:	8b 00                	mov    (%eax),%eax
  801481:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801484:	89 c1                	mov    %eax,%ecx
  801486:	c1 f9 1f             	sar    $0x1f,%ecx
  801489:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80148c:	8b 45 14             	mov    0x14(%ebp),%eax
  80148f:	8d 40 04             	lea    0x4(%eax),%eax
  801492:	89 45 14             	mov    %eax,0x14(%ebp)
  801495:	eb b9                	jmp    801450 <vprintfmt+0x283>
		return va_arg(*ap, long);
  801497:	8b 45 14             	mov    0x14(%ebp),%eax
  80149a:	8b 00                	mov    (%eax),%eax
  80149c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80149f:	89 c1                	mov    %eax,%ecx
  8014a1:	c1 f9 1f             	sar    $0x1f,%ecx
  8014a4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8014aa:	8d 40 04             	lea    0x4(%eax),%eax
  8014ad:	89 45 14             	mov    %eax,0x14(%ebp)
  8014b0:	eb 9e                	jmp    801450 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8014b2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014b5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8014b8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014bd:	e9 c6 00 00 00       	jmp    801588 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8014c2:	83 f9 01             	cmp    $0x1,%ecx
  8014c5:	7e 18                	jle    8014df <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8014c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ca:	8b 10                	mov    (%eax),%edx
  8014cc:	8b 48 04             	mov    0x4(%eax),%ecx
  8014cf:	8d 40 08             	lea    0x8(%eax),%eax
  8014d2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8014d5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014da:	e9 a9 00 00 00       	jmp    801588 <vprintfmt+0x3bb>
	else if (lflag)
  8014df:	85 c9                	test   %ecx,%ecx
  8014e1:	75 1a                	jne    8014fd <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  8014e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e6:	8b 10                	mov    (%eax),%edx
  8014e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014ed:	8d 40 04             	lea    0x4(%eax),%eax
  8014f0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8014f3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014f8:	e9 8b 00 00 00       	jmp    801588 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8014fd:	8b 45 14             	mov    0x14(%ebp),%eax
  801500:	8b 10                	mov    (%eax),%edx
  801502:	b9 00 00 00 00       	mov    $0x0,%ecx
  801507:	8d 40 04             	lea    0x4(%eax),%eax
  80150a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80150d:	b8 0a 00 00 00       	mov    $0xa,%eax
  801512:	eb 74                	jmp    801588 <vprintfmt+0x3bb>
	if (lflag >= 2)
  801514:	83 f9 01             	cmp    $0x1,%ecx
  801517:	7e 15                	jle    80152e <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  801519:	8b 45 14             	mov    0x14(%ebp),%eax
  80151c:	8b 10                	mov    (%eax),%edx
  80151e:	8b 48 04             	mov    0x4(%eax),%ecx
  801521:	8d 40 08             	lea    0x8(%eax),%eax
  801524:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801527:	b8 08 00 00 00       	mov    $0x8,%eax
  80152c:	eb 5a                	jmp    801588 <vprintfmt+0x3bb>
	else if (lflag)
  80152e:	85 c9                	test   %ecx,%ecx
  801530:	75 17                	jne    801549 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  801532:	8b 45 14             	mov    0x14(%ebp),%eax
  801535:	8b 10                	mov    (%eax),%edx
  801537:	b9 00 00 00 00       	mov    $0x0,%ecx
  80153c:	8d 40 04             	lea    0x4(%eax),%eax
  80153f:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801542:	b8 08 00 00 00       	mov    $0x8,%eax
  801547:	eb 3f                	jmp    801588 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  801549:	8b 45 14             	mov    0x14(%ebp),%eax
  80154c:	8b 10                	mov    (%eax),%edx
  80154e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801553:	8d 40 04             	lea    0x4(%eax),%eax
  801556:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801559:	b8 08 00 00 00       	mov    $0x8,%eax
  80155e:	eb 28                	jmp    801588 <vprintfmt+0x3bb>
			putch('0', putdat);
  801560:	83 ec 08             	sub    $0x8,%esp
  801563:	53                   	push   %ebx
  801564:	6a 30                	push   $0x30
  801566:	ff d6                	call   *%esi
			putch('x', putdat);
  801568:	83 c4 08             	add    $0x8,%esp
  80156b:	53                   	push   %ebx
  80156c:	6a 78                	push   $0x78
  80156e:	ff d6                	call   *%esi
			num = (unsigned long long)
  801570:	8b 45 14             	mov    0x14(%ebp),%eax
  801573:	8b 10                	mov    (%eax),%edx
  801575:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80157a:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80157d:	8d 40 04             	lea    0x4(%eax),%eax
  801580:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801583:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  801588:	83 ec 0c             	sub    $0xc,%esp
  80158b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80158f:	57                   	push   %edi
  801590:	ff 75 e0             	pushl  -0x20(%ebp)
  801593:	50                   	push   %eax
  801594:	51                   	push   %ecx
  801595:	52                   	push   %edx
  801596:	89 da                	mov    %ebx,%edx
  801598:	89 f0                	mov    %esi,%eax
  80159a:	e8 45 fb ff ff       	call   8010e4 <printnum>
			break;
  80159f:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8015a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8015a5:	83 c7 01             	add    $0x1,%edi
  8015a8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8015ac:	83 f8 25             	cmp    $0x25,%eax
  8015af:	0f 84 2f fc ff ff    	je     8011e4 <vprintfmt+0x17>
			if (ch == '\0')
  8015b5:	85 c0                	test   %eax,%eax
  8015b7:	0f 84 8b 00 00 00    	je     801648 <vprintfmt+0x47b>
			putch(ch, putdat);
  8015bd:	83 ec 08             	sub    $0x8,%esp
  8015c0:	53                   	push   %ebx
  8015c1:	50                   	push   %eax
  8015c2:	ff d6                	call   *%esi
  8015c4:	83 c4 10             	add    $0x10,%esp
  8015c7:	eb dc                	jmp    8015a5 <vprintfmt+0x3d8>
	if (lflag >= 2)
  8015c9:	83 f9 01             	cmp    $0x1,%ecx
  8015cc:	7e 15                	jle    8015e3 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  8015ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8015d1:	8b 10                	mov    (%eax),%edx
  8015d3:	8b 48 04             	mov    0x4(%eax),%ecx
  8015d6:	8d 40 08             	lea    0x8(%eax),%eax
  8015d9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015dc:	b8 10 00 00 00       	mov    $0x10,%eax
  8015e1:	eb a5                	jmp    801588 <vprintfmt+0x3bb>
	else if (lflag)
  8015e3:	85 c9                	test   %ecx,%ecx
  8015e5:	75 17                	jne    8015fe <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  8015e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8015ea:	8b 10                	mov    (%eax),%edx
  8015ec:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015f1:	8d 40 04             	lea    0x4(%eax),%eax
  8015f4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015f7:	b8 10 00 00 00       	mov    $0x10,%eax
  8015fc:	eb 8a                	jmp    801588 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8015fe:	8b 45 14             	mov    0x14(%ebp),%eax
  801601:	8b 10                	mov    (%eax),%edx
  801603:	b9 00 00 00 00       	mov    $0x0,%ecx
  801608:	8d 40 04             	lea    0x4(%eax),%eax
  80160b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80160e:	b8 10 00 00 00       	mov    $0x10,%eax
  801613:	e9 70 ff ff ff       	jmp    801588 <vprintfmt+0x3bb>
			putch(ch, putdat);
  801618:	83 ec 08             	sub    $0x8,%esp
  80161b:	53                   	push   %ebx
  80161c:	6a 25                	push   $0x25
  80161e:	ff d6                	call   *%esi
			break;
  801620:	83 c4 10             	add    $0x10,%esp
  801623:	e9 7a ff ff ff       	jmp    8015a2 <vprintfmt+0x3d5>
			putch('%', putdat);
  801628:	83 ec 08             	sub    $0x8,%esp
  80162b:	53                   	push   %ebx
  80162c:	6a 25                	push   $0x25
  80162e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801630:	83 c4 10             	add    $0x10,%esp
  801633:	89 f8                	mov    %edi,%eax
  801635:	eb 03                	jmp    80163a <vprintfmt+0x46d>
  801637:	83 e8 01             	sub    $0x1,%eax
  80163a:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80163e:	75 f7                	jne    801637 <vprintfmt+0x46a>
  801640:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801643:	e9 5a ff ff ff       	jmp    8015a2 <vprintfmt+0x3d5>
}
  801648:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80164b:	5b                   	pop    %ebx
  80164c:	5e                   	pop    %esi
  80164d:	5f                   	pop    %edi
  80164e:	5d                   	pop    %ebp
  80164f:	c3                   	ret    

00801650 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801650:	55                   	push   %ebp
  801651:	89 e5                	mov    %esp,%ebp
  801653:	83 ec 18             	sub    $0x18,%esp
  801656:	8b 45 08             	mov    0x8(%ebp),%eax
  801659:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80165c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80165f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801663:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801666:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80166d:	85 c0                	test   %eax,%eax
  80166f:	74 26                	je     801697 <vsnprintf+0x47>
  801671:	85 d2                	test   %edx,%edx
  801673:	7e 22                	jle    801697 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801675:	ff 75 14             	pushl  0x14(%ebp)
  801678:	ff 75 10             	pushl  0x10(%ebp)
  80167b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80167e:	50                   	push   %eax
  80167f:	68 93 11 80 00       	push   $0x801193
  801684:	e8 44 fb ff ff       	call   8011cd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801689:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80168c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80168f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801692:	83 c4 10             	add    $0x10,%esp
}
  801695:	c9                   	leave  
  801696:	c3                   	ret    
		return -E_INVAL;
  801697:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80169c:	eb f7                	jmp    801695 <vsnprintf+0x45>

0080169e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80169e:	55                   	push   %ebp
  80169f:	89 e5                	mov    %esp,%ebp
  8016a1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016a4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016a7:	50                   	push   %eax
  8016a8:	ff 75 10             	pushl  0x10(%ebp)
  8016ab:	ff 75 0c             	pushl  0xc(%ebp)
  8016ae:	ff 75 08             	pushl  0x8(%ebp)
  8016b1:	e8 9a ff ff ff       	call   801650 <vsnprintf>
	va_end(ap);

	return rc;
}
  8016b6:	c9                   	leave  
  8016b7:	c3                   	ret    

008016b8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016b8:	55                   	push   %ebp
  8016b9:	89 e5                	mov    %esp,%ebp
  8016bb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016be:	b8 00 00 00 00       	mov    $0x0,%eax
  8016c3:	eb 03                	jmp    8016c8 <strlen+0x10>
		n++;
  8016c5:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8016c8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016cc:	75 f7                	jne    8016c5 <strlen+0xd>
	return n;
}
  8016ce:	5d                   	pop    %ebp
  8016cf:	c3                   	ret    

008016d0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016d0:	55                   	push   %ebp
  8016d1:	89 e5                	mov    %esp,%ebp
  8016d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016d6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8016de:	eb 03                	jmp    8016e3 <strnlen+0x13>
		n++;
  8016e0:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016e3:	39 d0                	cmp    %edx,%eax
  8016e5:	74 06                	je     8016ed <strnlen+0x1d>
  8016e7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8016eb:	75 f3                	jne    8016e0 <strnlen+0x10>
	return n;
}
  8016ed:	5d                   	pop    %ebp
  8016ee:	c3                   	ret    

008016ef <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016ef:	55                   	push   %ebp
  8016f0:	89 e5                	mov    %esp,%ebp
  8016f2:	53                   	push   %ebx
  8016f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016f9:	89 c2                	mov    %eax,%edx
  8016fb:	83 c1 01             	add    $0x1,%ecx
  8016fe:	83 c2 01             	add    $0x1,%edx
  801701:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801705:	88 5a ff             	mov    %bl,-0x1(%edx)
  801708:	84 db                	test   %bl,%bl
  80170a:	75 ef                	jne    8016fb <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80170c:	5b                   	pop    %ebx
  80170d:	5d                   	pop    %ebp
  80170e:	c3                   	ret    

0080170f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80170f:	55                   	push   %ebp
  801710:	89 e5                	mov    %esp,%ebp
  801712:	53                   	push   %ebx
  801713:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801716:	53                   	push   %ebx
  801717:	e8 9c ff ff ff       	call   8016b8 <strlen>
  80171c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80171f:	ff 75 0c             	pushl  0xc(%ebp)
  801722:	01 d8                	add    %ebx,%eax
  801724:	50                   	push   %eax
  801725:	e8 c5 ff ff ff       	call   8016ef <strcpy>
	return dst;
}
  80172a:	89 d8                	mov    %ebx,%eax
  80172c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80172f:	c9                   	leave  
  801730:	c3                   	ret    

00801731 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801731:	55                   	push   %ebp
  801732:	89 e5                	mov    %esp,%ebp
  801734:	56                   	push   %esi
  801735:	53                   	push   %ebx
  801736:	8b 75 08             	mov    0x8(%ebp),%esi
  801739:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80173c:	89 f3                	mov    %esi,%ebx
  80173e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801741:	89 f2                	mov    %esi,%edx
  801743:	eb 0f                	jmp    801754 <strncpy+0x23>
		*dst++ = *src;
  801745:	83 c2 01             	add    $0x1,%edx
  801748:	0f b6 01             	movzbl (%ecx),%eax
  80174b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80174e:	80 39 01             	cmpb   $0x1,(%ecx)
  801751:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  801754:	39 da                	cmp    %ebx,%edx
  801756:	75 ed                	jne    801745 <strncpy+0x14>
	}
	return ret;
}
  801758:	89 f0                	mov    %esi,%eax
  80175a:	5b                   	pop    %ebx
  80175b:	5e                   	pop    %esi
  80175c:	5d                   	pop    %ebp
  80175d:	c3                   	ret    

0080175e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80175e:	55                   	push   %ebp
  80175f:	89 e5                	mov    %esp,%ebp
  801761:	56                   	push   %esi
  801762:	53                   	push   %ebx
  801763:	8b 75 08             	mov    0x8(%ebp),%esi
  801766:	8b 55 0c             	mov    0xc(%ebp),%edx
  801769:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80176c:	89 f0                	mov    %esi,%eax
  80176e:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801772:	85 c9                	test   %ecx,%ecx
  801774:	75 0b                	jne    801781 <strlcpy+0x23>
  801776:	eb 17                	jmp    80178f <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801778:	83 c2 01             	add    $0x1,%edx
  80177b:	83 c0 01             	add    $0x1,%eax
  80177e:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  801781:	39 d8                	cmp    %ebx,%eax
  801783:	74 07                	je     80178c <strlcpy+0x2e>
  801785:	0f b6 0a             	movzbl (%edx),%ecx
  801788:	84 c9                	test   %cl,%cl
  80178a:	75 ec                	jne    801778 <strlcpy+0x1a>
		*dst = '\0';
  80178c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80178f:	29 f0                	sub    %esi,%eax
}
  801791:	5b                   	pop    %ebx
  801792:	5e                   	pop    %esi
  801793:	5d                   	pop    %ebp
  801794:	c3                   	ret    

00801795 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801795:	55                   	push   %ebp
  801796:	89 e5                	mov    %esp,%ebp
  801798:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80179b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80179e:	eb 06                	jmp    8017a6 <strcmp+0x11>
		p++, q++;
  8017a0:	83 c1 01             	add    $0x1,%ecx
  8017a3:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8017a6:	0f b6 01             	movzbl (%ecx),%eax
  8017a9:	84 c0                	test   %al,%al
  8017ab:	74 04                	je     8017b1 <strcmp+0x1c>
  8017ad:	3a 02                	cmp    (%edx),%al
  8017af:	74 ef                	je     8017a0 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017b1:	0f b6 c0             	movzbl %al,%eax
  8017b4:	0f b6 12             	movzbl (%edx),%edx
  8017b7:	29 d0                	sub    %edx,%eax
}
  8017b9:	5d                   	pop    %ebp
  8017ba:	c3                   	ret    

008017bb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017bb:	55                   	push   %ebp
  8017bc:	89 e5                	mov    %esp,%ebp
  8017be:	53                   	push   %ebx
  8017bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017c5:	89 c3                	mov    %eax,%ebx
  8017c7:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017ca:	eb 06                	jmp    8017d2 <strncmp+0x17>
		n--, p++, q++;
  8017cc:	83 c0 01             	add    $0x1,%eax
  8017cf:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8017d2:	39 d8                	cmp    %ebx,%eax
  8017d4:	74 16                	je     8017ec <strncmp+0x31>
  8017d6:	0f b6 08             	movzbl (%eax),%ecx
  8017d9:	84 c9                	test   %cl,%cl
  8017db:	74 04                	je     8017e1 <strncmp+0x26>
  8017dd:	3a 0a                	cmp    (%edx),%cl
  8017df:	74 eb                	je     8017cc <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017e1:	0f b6 00             	movzbl (%eax),%eax
  8017e4:	0f b6 12             	movzbl (%edx),%edx
  8017e7:	29 d0                	sub    %edx,%eax
}
  8017e9:	5b                   	pop    %ebx
  8017ea:	5d                   	pop    %ebp
  8017eb:	c3                   	ret    
		return 0;
  8017ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8017f1:	eb f6                	jmp    8017e9 <strncmp+0x2e>

008017f3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017f3:	55                   	push   %ebp
  8017f4:	89 e5                	mov    %esp,%ebp
  8017f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017fd:	0f b6 10             	movzbl (%eax),%edx
  801800:	84 d2                	test   %dl,%dl
  801802:	74 09                	je     80180d <strchr+0x1a>
		if (*s == c)
  801804:	38 ca                	cmp    %cl,%dl
  801806:	74 0a                	je     801812 <strchr+0x1f>
	for (; *s; s++)
  801808:	83 c0 01             	add    $0x1,%eax
  80180b:	eb f0                	jmp    8017fd <strchr+0xa>
			return (char *) s;
	return 0;
  80180d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801812:	5d                   	pop    %ebp
  801813:	c3                   	ret    

00801814 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801814:	55                   	push   %ebp
  801815:	89 e5                	mov    %esp,%ebp
  801817:	8b 45 08             	mov    0x8(%ebp),%eax
  80181a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80181e:	eb 03                	jmp    801823 <strfind+0xf>
  801820:	83 c0 01             	add    $0x1,%eax
  801823:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801826:	38 ca                	cmp    %cl,%dl
  801828:	74 04                	je     80182e <strfind+0x1a>
  80182a:	84 d2                	test   %dl,%dl
  80182c:	75 f2                	jne    801820 <strfind+0xc>
			break;
	return (char *) s;
}
  80182e:	5d                   	pop    %ebp
  80182f:	c3                   	ret    

00801830 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801830:	55                   	push   %ebp
  801831:	89 e5                	mov    %esp,%ebp
  801833:	57                   	push   %edi
  801834:	56                   	push   %esi
  801835:	53                   	push   %ebx
  801836:	8b 7d 08             	mov    0x8(%ebp),%edi
  801839:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80183c:	85 c9                	test   %ecx,%ecx
  80183e:	74 13                	je     801853 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801840:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801846:	75 05                	jne    80184d <memset+0x1d>
  801848:	f6 c1 03             	test   $0x3,%cl
  80184b:	74 0d                	je     80185a <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80184d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801850:	fc                   	cld    
  801851:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801853:	89 f8                	mov    %edi,%eax
  801855:	5b                   	pop    %ebx
  801856:	5e                   	pop    %esi
  801857:	5f                   	pop    %edi
  801858:	5d                   	pop    %ebp
  801859:	c3                   	ret    
		c &= 0xFF;
  80185a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80185e:	89 d3                	mov    %edx,%ebx
  801860:	c1 e3 08             	shl    $0x8,%ebx
  801863:	89 d0                	mov    %edx,%eax
  801865:	c1 e0 18             	shl    $0x18,%eax
  801868:	89 d6                	mov    %edx,%esi
  80186a:	c1 e6 10             	shl    $0x10,%esi
  80186d:	09 f0                	or     %esi,%eax
  80186f:	09 c2                	or     %eax,%edx
  801871:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  801873:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801876:	89 d0                	mov    %edx,%eax
  801878:	fc                   	cld    
  801879:	f3 ab                	rep stos %eax,%es:(%edi)
  80187b:	eb d6                	jmp    801853 <memset+0x23>

0080187d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80187d:	55                   	push   %ebp
  80187e:	89 e5                	mov    %esp,%ebp
  801880:	57                   	push   %edi
  801881:	56                   	push   %esi
  801882:	8b 45 08             	mov    0x8(%ebp),%eax
  801885:	8b 75 0c             	mov    0xc(%ebp),%esi
  801888:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80188b:	39 c6                	cmp    %eax,%esi
  80188d:	73 35                	jae    8018c4 <memmove+0x47>
  80188f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801892:	39 c2                	cmp    %eax,%edx
  801894:	76 2e                	jbe    8018c4 <memmove+0x47>
		s += n;
		d += n;
  801896:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801899:	89 d6                	mov    %edx,%esi
  80189b:	09 fe                	or     %edi,%esi
  80189d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018a3:	74 0c                	je     8018b1 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8018a5:	83 ef 01             	sub    $0x1,%edi
  8018a8:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8018ab:	fd                   	std    
  8018ac:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018ae:	fc                   	cld    
  8018af:	eb 21                	jmp    8018d2 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018b1:	f6 c1 03             	test   $0x3,%cl
  8018b4:	75 ef                	jne    8018a5 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8018b6:	83 ef 04             	sub    $0x4,%edi
  8018b9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018bc:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8018bf:	fd                   	std    
  8018c0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018c2:	eb ea                	jmp    8018ae <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018c4:	89 f2                	mov    %esi,%edx
  8018c6:	09 c2                	or     %eax,%edx
  8018c8:	f6 c2 03             	test   $0x3,%dl
  8018cb:	74 09                	je     8018d6 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018cd:	89 c7                	mov    %eax,%edi
  8018cf:	fc                   	cld    
  8018d0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018d2:	5e                   	pop    %esi
  8018d3:	5f                   	pop    %edi
  8018d4:	5d                   	pop    %ebp
  8018d5:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018d6:	f6 c1 03             	test   $0x3,%cl
  8018d9:	75 f2                	jne    8018cd <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8018db:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8018de:	89 c7                	mov    %eax,%edi
  8018e0:	fc                   	cld    
  8018e1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018e3:	eb ed                	jmp    8018d2 <memmove+0x55>

008018e5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018e5:	55                   	push   %ebp
  8018e6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018e8:	ff 75 10             	pushl  0x10(%ebp)
  8018eb:	ff 75 0c             	pushl  0xc(%ebp)
  8018ee:	ff 75 08             	pushl  0x8(%ebp)
  8018f1:	e8 87 ff ff ff       	call   80187d <memmove>
}
  8018f6:	c9                   	leave  
  8018f7:	c3                   	ret    

008018f8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018f8:	55                   	push   %ebp
  8018f9:	89 e5                	mov    %esp,%ebp
  8018fb:	56                   	push   %esi
  8018fc:	53                   	push   %ebx
  8018fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801900:	8b 55 0c             	mov    0xc(%ebp),%edx
  801903:	89 c6                	mov    %eax,%esi
  801905:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801908:	39 f0                	cmp    %esi,%eax
  80190a:	74 1c                	je     801928 <memcmp+0x30>
		if (*s1 != *s2)
  80190c:	0f b6 08             	movzbl (%eax),%ecx
  80190f:	0f b6 1a             	movzbl (%edx),%ebx
  801912:	38 d9                	cmp    %bl,%cl
  801914:	75 08                	jne    80191e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801916:	83 c0 01             	add    $0x1,%eax
  801919:	83 c2 01             	add    $0x1,%edx
  80191c:	eb ea                	jmp    801908 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  80191e:	0f b6 c1             	movzbl %cl,%eax
  801921:	0f b6 db             	movzbl %bl,%ebx
  801924:	29 d8                	sub    %ebx,%eax
  801926:	eb 05                	jmp    80192d <memcmp+0x35>
	}

	return 0;
  801928:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80192d:	5b                   	pop    %ebx
  80192e:	5e                   	pop    %esi
  80192f:	5d                   	pop    %ebp
  801930:	c3                   	ret    

00801931 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801931:	55                   	push   %ebp
  801932:	89 e5                	mov    %esp,%ebp
  801934:	8b 45 08             	mov    0x8(%ebp),%eax
  801937:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80193a:	89 c2                	mov    %eax,%edx
  80193c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80193f:	39 d0                	cmp    %edx,%eax
  801941:	73 09                	jae    80194c <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  801943:	38 08                	cmp    %cl,(%eax)
  801945:	74 05                	je     80194c <memfind+0x1b>
	for (; s < ends; s++)
  801947:	83 c0 01             	add    $0x1,%eax
  80194a:	eb f3                	jmp    80193f <memfind+0xe>
			break;
	return (void *) s;
}
  80194c:	5d                   	pop    %ebp
  80194d:	c3                   	ret    

0080194e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80194e:	55                   	push   %ebp
  80194f:	89 e5                	mov    %esp,%ebp
  801951:	57                   	push   %edi
  801952:	56                   	push   %esi
  801953:	53                   	push   %ebx
  801954:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801957:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80195a:	eb 03                	jmp    80195f <strtol+0x11>
		s++;
  80195c:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  80195f:	0f b6 01             	movzbl (%ecx),%eax
  801962:	3c 20                	cmp    $0x20,%al
  801964:	74 f6                	je     80195c <strtol+0xe>
  801966:	3c 09                	cmp    $0x9,%al
  801968:	74 f2                	je     80195c <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  80196a:	3c 2b                	cmp    $0x2b,%al
  80196c:	74 2e                	je     80199c <strtol+0x4e>
	int neg = 0;
  80196e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801973:	3c 2d                	cmp    $0x2d,%al
  801975:	74 2f                	je     8019a6 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801977:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80197d:	75 05                	jne    801984 <strtol+0x36>
  80197f:	80 39 30             	cmpb   $0x30,(%ecx)
  801982:	74 2c                	je     8019b0 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801984:	85 db                	test   %ebx,%ebx
  801986:	75 0a                	jne    801992 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801988:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  80198d:	80 39 30             	cmpb   $0x30,(%ecx)
  801990:	74 28                	je     8019ba <strtol+0x6c>
		base = 10;
  801992:	b8 00 00 00 00       	mov    $0x0,%eax
  801997:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80199a:	eb 50                	jmp    8019ec <strtol+0x9e>
		s++;
  80199c:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  80199f:	bf 00 00 00 00       	mov    $0x0,%edi
  8019a4:	eb d1                	jmp    801977 <strtol+0x29>
		s++, neg = 1;
  8019a6:	83 c1 01             	add    $0x1,%ecx
  8019a9:	bf 01 00 00 00       	mov    $0x1,%edi
  8019ae:	eb c7                	jmp    801977 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019b0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019b4:	74 0e                	je     8019c4 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8019b6:	85 db                	test   %ebx,%ebx
  8019b8:	75 d8                	jne    801992 <strtol+0x44>
		s++, base = 8;
  8019ba:	83 c1 01             	add    $0x1,%ecx
  8019bd:	bb 08 00 00 00       	mov    $0x8,%ebx
  8019c2:	eb ce                	jmp    801992 <strtol+0x44>
		s += 2, base = 16;
  8019c4:	83 c1 02             	add    $0x2,%ecx
  8019c7:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019cc:	eb c4                	jmp    801992 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  8019ce:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019d1:	89 f3                	mov    %esi,%ebx
  8019d3:	80 fb 19             	cmp    $0x19,%bl
  8019d6:	77 29                	ja     801a01 <strtol+0xb3>
			dig = *s - 'a' + 10;
  8019d8:	0f be d2             	movsbl %dl,%edx
  8019db:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8019de:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019e1:	7d 30                	jge    801a13 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  8019e3:	83 c1 01             	add    $0x1,%ecx
  8019e6:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019ea:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  8019ec:	0f b6 11             	movzbl (%ecx),%edx
  8019ef:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019f2:	89 f3                	mov    %esi,%ebx
  8019f4:	80 fb 09             	cmp    $0x9,%bl
  8019f7:	77 d5                	ja     8019ce <strtol+0x80>
			dig = *s - '0';
  8019f9:	0f be d2             	movsbl %dl,%edx
  8019fc:	83 ea 30             	sub    $0x30,%edx
  8019ff:	eb dd                	jmp    8019de <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  801a01:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a04:	89 f3                	mov    %esi,%ebx
  801a06:	80 fb 19             	cmp    $0x19,%bl
  801a09:	77 08                	ja     801a13 <strtol+0xc5>
			dig = *s - 'A' + 10;
  801a0b:	0f be d2             	movsbl %dl,%edx
  801a0e:	83 ea 37             	sub    $0x37,%edx
  801a11:	eb cb                	jmp    8019de <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  801a13:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a17:	74 05                	je     801a1e <strtol+0xd0>
		*endptr = (char *) s;
  801a19:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a1c:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801a1e:	89 c2                	mov    %eax,%edx
  801a20:	f7 da                	neg    %edx
  801a22:	85 ff                	test   %edi,%edi
  801a24:	0f 45 c2             	cmovne %edx,%eax
}
  801a27:	5b                   	pop    %ebx
  801a28:	5e                   	pop    %esi
  801a29:	5f                   	pop    %edi
  801a2a:	5d                   	pop    %ebp
  801a2b:	c3                   	ret    

00801a2c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a2c:	55                   	push   %ebp
  801a2d:	89 e5                	mov    %esp,%ebp
  801a2f:	56                   	push   %esi
  801a30:	53                   	push   %ebx
  801a31:	8b 75 08             	mov    0x8(%ebp),%esi
  801a34:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a37:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  801a3a:	85 f6                	test   %esi,%esi
  801a3c:	74 06                	je     801a44 <ipc_recv+0x18>
  801a3e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801a44:	85 db                	test   %ebx,%ebx
  801a46:	74 06                	je     801a4e <ipc_recv+0x22>
  801a48:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801a4e:	85 c0                	test   %eax,%eax
  801a50:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801a55:	0f 44 c2             	cmove  %edx,%eax
	int ret = sys_ipc_recv(pg);
  801a58:	83 ec 0c             	sub    $0xc,%esp
  801a5b:	50                   	push   %eax
  801a5c:	e8 a5 e8 ff ff       	call   800306 <sys_ipc_recv>
	if (ret) return ret;
  801a61:	83 c4 10             	add    $0x10,%esp
  801a64:	85 c0                	test   %eax,%eax
  801a66:	75 24                	jne    801a8c <ipc_recv+0x60>
	if (from_env_store)
  801a68:	85 f6                	test   %esi,%esi
  801a6a:	74 0a                	je     801a76 <ipc_recv+0x4a>
		*from_env_store = thisenv->env_ipc_from;
  801a6c:	a1 04 40 80 00       	mov    0x804004,%eax
  801a71:	8b 40 74             	mov    0x74(%eax),%eax
  801a74:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801a76:	85 db                	test   %ebx,%ebx
  801a78:	74 0a                	je     801a84 <ipc_recv+0x58>
		*perm_store = thisenv->env_ipc_perm;
  801a7a:	a1 04 40 80 00       	mov    0x804004,%eax
  801a7f:	8b 40 78             	mov    0x78(%eax),%eax
  801a82:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801a84:	a1 04 40 80 00       	mov    0x804004,%eax
  801a89:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a8c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a8f:	5b                   	pop    %ebx
  801a90:	5e                   	pop    %esi
  801a91:	5d                   	pop    %ebp
  801a92:	c3                   	ret    

00801a93 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a93:	55                   	push   %ebp
  801a94:	89 e5                	mov    %esp,%ebp
  801a96:	57                   	push   %edi
  801a97:	56                   	push   %esi
  801a98:	53                   	push   %ebx
  801a99:	83 ec 0c             	sub    $0xc,%esp
  801a9c:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a9f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801aa2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  801aa5:	85 db                	test   %ebx,%ebx
  801aa7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801aac:	0f 44 d8             	cmove  %eax,%ebx
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801aaf:	ff 75 14             	pushl  0x14(%ebp)
  801ab2:	53                   	push   %ebx
  801ab3:	56                   	push   %esi
  801ab4:	57                   	push   %edi
  801ab5:	e8 29 e8 ff ff       	call   8002e3 <sys_ipc_try_send>
  801aba:	83 c4 10             	add    $0x10,%esp
  801abd:	85 c0                	test   %eax,%eax
  801abf:	74 1e                	je     801adf <ipc_send+0x4c>
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801ac1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ac4:	75 07                	jne    801acd <ipc_send+0x3a>
		sys_yield();
  801ac6:	e8 6c e6 ff ff       	call   800137 <sys_yield>
  801acb:	eb e2                	jmp    801aaf <ipc_send+0x1c>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  801acd:	50                   	push   %eax
  801ace:	68 e0 21 80 00       	push   $0x8021e0
  801ad3:	6a 36                	push   $0x36
  801ad5:	68 f7 21 80 00       	push   $0x8021f7
  801ada:	e8 16 f5 ff ff       	call   800ff5 <_panic>
	}
}
  801adf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae2:	5b                   	pop    %ebx
  801ae3:	5e                   	pop    %esi
  801ae4:	5f                   	pop    %edi
  801ae5:	5d                   	pop    %ebp
  801ae6:	c3                   	ret    

00801ae7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ae7:	55                   	push   %ebp
  801ae8:	89 e5                	mov    %esp,%ebp
  801aea:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801aed:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801af2:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801af5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801afb:	8b 52 50             	mov    0x50(%edx),%edx
  801afe:	39 ca                	cmp    %ecx,%edx
  801b00:	74 11                	je     801b13 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801b02:	83 c0 01             	add    $0x1,%eax
  801b05:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b0a:	75 e6                	jne    801af2 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801b0c:	b8 00 00 00 00       	mov    $0x0,%eax
  801b11:	eb 0b                	jmp    801b1e <ipc_find_env+0x37>
			return envs[i].env_id;
  801b13:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b16:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b1b:	8b 40 48             	mov    0x48(%eax),%eax
}
  801b1e:	5d                   	pop    %ebp
  801b1f:	c3                   	ret    

00801b20 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b20:	55                   	push   %ebp
  801b21:	89 e5                	mov    %esp,%ebp
  801b23:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b26:	89 d0                	mov    %edx,%eax
  801b28:	c1 e8 16             	shr    $0x16,%eax
  801b2b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b32:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  801b37:	f6 c1 01             	test   $0x1,%cl
  801b3a:	74 1d                	je     801b59 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  801b3c:	c1 ea 0c             	shr    $0xc,%edx
  801b3f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b46:	f6 c2 01             	test   $0x1,%dl
  801b49:	74 0e                	je     801b59 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b4b:	c1 ea 0c             	shr    $0xc,%edx
  801b4e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b55:	ef 
  801b56:	0f b7 c0             	movzwl %ax,%eax
}
  801b59:	5d                   	pop    %ebp
  801b5a:	c3                   	ret    
  801b5b:	66 90                	xchg   %ax,%ax
  801b5d:	66 90                	xchg   %ax,%ax
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
