
obj/user/testfile.debug：     文件格式 elf32-i386


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
  80002c:	e8 54 06 00 00       	call   800685 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <xopen>:

#define FVA ((struct Fd*)0xCCCCC000)

static int
xopen(const char *path, int mode)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	89 d3                	mov    %edx,%ebx
	extern union Fsipc fsipcbuf;
	envid_t fsenv;
	
	strcpy(fsipcbuf.open.req_path, path);
  80003c:	50                   	push   %eax
  80003d:	68 00 50 80 00       	push   $0x805000
  800042:	e8 98 0d 00 00       	call   800ddf <strcpy>
	fsipcbuf.open.req_omode = mode;
  800047:	89 1d 00 54 80 00    	mov    %ebx,0x805400

	fsenv = ipc_find_env(ENV_TYPE_FS);
  80004d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800054:	e8 2b 14 00 00       	call   801484 <ipc_find_env>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800059:	6a 07                	push   $0x7
  80005b:	68 00 50 80 00       	push   $0x805000
  800060:	6a 01                	push   $0x1
  800062:	50                   	push   %eax
  800063:	e8 c8 13 00 00       	call   801430 <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  800068:	83 c4 1c             	add    $0x1c,%esp
  80006b:	6a 00                	push   $0x0
  80006d:	68 00 c0 cc cc       	push   $0xccccc000
  800072:	6a 00                	push   $0x0
  800074:	e8 50 13 00 00       	call   8013c9 <ipc_recv>
}
  800079:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80007c:	c9                   	leave  
  80007d:	c3                   	ret    

0080007e <umain>:

void
umain(int argc, char **argv)
{
  80007e:	55                   	push   %ebp
  80007f:	89 e5                	mov    %esp,%ebp
  800081:	57                   	push   %edi
  800082:	56                   	push   %esi
  800083:	53                   	push   %ebx
  800084:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	struct Fd fdcopy;
	struct Stat st;
	char buf[512];

	// We open files manually first, to avoid the FD layer
	if ((r = xopen("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  80008a:	ba 00 00 00 00       	mov    $0x0,%edx
  80008f:	b8 00 24 80 00       	mov    $0x802400,%eax
  800094:	e8 9a ff ff ff       	call   800033 <xopen>
  800099:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80009c:	74 08                	je     8000a6 <umain+0x28>
  80009e:	85 c0                	test   %eax,%eax
  8000a0:	0f 88 e9 03 00 00    	js     80048f <umain+0x411>
		panic("serve_open /not-found: %e", r);
	else if (r >= 0)
  8000a6:	85 c0                	test   %eax,%eax
  8000a8:	0f 89 f3 03 00 00    	jns    8004a1 <umain+0x423>
		panic("serve_open /not-found succeeded!");

	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  8000ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8000b3:	b8 35 24 80 00       	mov    $0x802435,%eax
  8000b8:	e8 76 ff ff ff       	call   800033 <xopen>
  8000bd:	85 c0                	test   %eax,%eax
  8000bf:	0f 88 f0 03 00 00    	js     8004b5 <umain+0x437>
		panic("serve_open /newmotd: %e", r);
	if (FVA->fd_dev_id != 'f' || FVA->fd_offset != 0 || FVA->fd_omode != O_RDONLY)
  8000c5:	83 3d 00 c0 cc cc 66 	cmpl   $0x66,0xccccc000
  8000cc:	0f 85 f5 03 00 00    	jne    8004c7 <umain+0x449>
  8000d2:	83 3d 04 c0 cc cc 00 	cmpl   $0x0,0xccccc004
  8000d9:	0f 85 e8 03 00 00    	jne    8004c7 <umain+0x449>
  8000df:	83 3d 08 c0 cc cc 00 	cmpl   $0x0,0xccccc008
  8000e6:	0f 85 db 03 00 00    	jne    8004c7 <umain+0x449>
		panic("serve_open did not fill struct Fd correctly\n");
	cprintf("serve_open is good\n");
  8000ec:	83 ec 0c             	sub    $0xc,%esp
  8000ef:	68 56 24 80 00       	push   $0x802456
  8000f4:	e8 c7 06 00 00       	call   8007c0 <cprintf>

	if ((r = devfile.dev_stat(FVA, &st)) < 0)
  8000f9:	83 c4 08             	add    $0x8,%esp
  8000fc:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  800102:	50                   	push   %eax
  800103:	68 00 c0 cc cc       	push   $0xccccc000
  800108:	ff 15 1c 30 80 00    	call   *0x80301c
  80010e:	83 c4 10             	add    $0x10,%esp
  800111:	85 c0                	test   %eax,%eax
  800113:	0f 88 c2 03 00 00    	js     8004db <umain+0x45d>
		panic("file_stat: %e", r);
	if (strlen(msg) != st.st_size)
  800119:	83 ec 0c             	sub    $0xc,%esp
  80011c:	ff 35 00 30 80 00    	pushl  0x803000
  800122:	e8 81 0c 00 00       	call   800da8 <strlen>
  800127:	83 c4 10             	add    $0x10,%esp
  80012a:	3b 45 cc             	cmp    -0x34(%ebp),%eax
  80012d:	0f 85 ba 03 00 00    	jne    8004ed <umain+0x46f>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
	cprintf("file_stat is good\n");
  800133:	83 ec 0c             	sub    $0xc,%esp
  800136:	68 78 24 80 00       	push   $0x802478
  80013b:	e8 80 06 00 00       	call   8007c0 <cprintf>

	memset(buf, 0, sizeof buf);
  800140:	83 c4 0c             	add    $0xc,%esp
  800143:	68 00 02 00 00       	push   $0x200
  800148:	6a 00                	push   $0x0
  80014a:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  800150:	53                   	push   %ebx
  800151:	e8 ca 0d 00 00       	call   800f20 <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  800156:	83 c4 0c             	add    $0xc,%esp
  800159:	68 00 02 00 00       	push   $0x200
  80015e:	53                   	push   %ebx
  80015f:	68 00 c0 cc cc       	push   $0xccccc000
  800164:	ff 15 10 30 80 00    	call   *0x803010
  80016a:	83 c4 10             	add    $0x10,%esp
  80016d:	85 c0                	test   %eax,%eax
  80016f:	0f 88 9d 03 00 00    	js     800512 <umain+0x494>
		panic("file_read: %e", r);
	if (strcmp(buf, msg) != 0)
  800175:	83 ec 08             	sub    $0x8,%esp
  800178:	ff 35 00 30 80 00    	pushl  0x803000
  80017e:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  800184:	50                   	push   %eax
  800185:	e8 fb 0c 00 00       	call   800e85 <strcmp>
  80018a:	83 c4 10             	add    $0x10,%esp
  80018d:	85 c0                	test   %eax,%eax
  80018f:	0f 85 8f 03 00 00    	jne    800524 <umain+0x4a6>
		panic("file_read returned wrong data");
	cprintf("file_read is good\n");
  800195:	83 ec 0c             	sub    $0xc,%esp
  800198:	68 b7 24 80 00       	push   $0x8024b7
  80019d:	e8 1e 06 00 00       	call   8007c0 <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  8001a2:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  8001a9:	ff 15 18 30 80 00    	call   *0x803018
  8001af:	83 c4 10             	add    $0x10,%esp
  8001b2:	85 c0                	test   %eax,%eax
  8001b4:	0f 88 7e 03 00 00    	js     800538 <umain+0x4ba>
		panic("file_close: %e", r);
	cprintf("file_close is good\n");
  8001ba:	83 ec 0c             	sub    $0xc,%esp
  8001bd:	68 d9 24 80 00       	push   $0x8024d9
  8001c2:	e8 f9 05 00 00       	call   8007c0 <cprintf>

	// We're about to unmap the FD, but still need a way to get
	// the stale filenum to serve_read, so we make a local copy.
	// The file server won't think it's stale until we unmap the
	// FD page.
	fdcopy = *FVA;
  8001c7:	a1 00 c0 cc cc       	mov    0xccccc000,%eax
  8001cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001cf:	a1 04 c0 cc cc       	mov    0xccccc004,%eax
  8001d4:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001d7:	a1 08 c0 cc cc       	mov    0xccccc008,%eax
  8001dc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001df:	a1 0c c0 cc cc       	mov    0xccccc00c,%eax
  8001e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	sys_page_unmap(0, FVA);
  8001e7:	83 c4 08             	add    $0x8,%esp
  8001ea:	68 00 c0 cc cc       	push   $0xccccc000
  8001ef:	6a 00                	push   $0x0
  8001f1:	e8 67 10 00 00       	call   80125d <sys_page_unmap>

	if ((r = devfile.dev_read(&fdcopy, buf, sizeof buf)) != -E_INVAL)
  8001f6:	83 c4 0c             	add    $0xc,%esp
  8001f9:	68 00 02 00 00       	push   $0x200
  8001fe:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  800204:	50                   	push   %eax
  800205:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800208:	50                   	push   %eax
  800209:	ff 15 10 30 80 00    	call   *0x803010
  80020f:	83 c4 10             	add    $0x10,%esp
  800212:	83 f8 fd             	cmp    $0xfffffffd,%eax
  800215:	0f 85 2f 03 00 00    	jne    80054a <umain+0x4cc>
		panic("serve_read does not handle stale fileids correctly: %e", r);
	cprintf("stale fileid is good\n");
  80021b:	83 ec 0c             	sub    $0xc,%esp
  80021e:	68 ed 24 80 00       	push   $0x8024ed
  800223:	e8 98 05 00 00       	call   8007c0 <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  800228:	ba 02 01 00 00       	mov    $0x102,%edx
  80022d:	b8 03 25 80 00       	mov    $0x802503,%eax
  800232:	e8 fc fd ff ff       	call   800033 <xopen>
  800237:	83 c4 10             	add    $0x10,%esp
  80023a:	85 c0                	test   %eax,%eax
  80023c:	0f 88 1a 03 00 00    	js     80055c <umain+0x4de>
		panic("serve_open /new-file: %e", r);

	if ((r = devfile.dev_write(FVA, msg, strlen(msg))) != strlen(msg))
  800242:	8b 1d 14 30 80 00    	mov    0x803014,%ebx
  800248:	83 ec 0c             	sub    $0xc,%esp
  80024b:	ff 35 00 30 80 00    	pushl  0x803000
  800251:	e8 52 0b 00 00       	call   800da8 <strlen>
  800256:	83 c4 0c             	add    $0xc,%esp
  800259:	50                   	push   %eax
  80025a:	ff 35 00 30 80 00    	pushl  0x803000
  800260:	68 00 c0 cc cc       	push   $0xccccc000
  800265:	ff d3                	call   *%ebx
  800267:	89 c3                	mov    %eax,%ebx
  800269:	83 c4 04             	add    $0x4,%esp
  80026c:	ff 35 00 30 80 00    	pushl  0x803000
  800272:	e8 31 0b 00 00       	call   800da8 <strlen>
  800277:	83 c4 10             	add    $0x10,%esp
  80027a:	39 d8                	cmp    %ebx,%eax
  80027c:	0f 85 ec 02 00 00    	jne    80056e <umain+0x4f0>
		panic("file_write: %e", r);
	cprintf("file_write is good\n");
  800282:	83 ec 0c             	sub    $0xc,%esp
  800285:	68 35 25 80 00       	push   $0x802535
  80028a:	e8 31 05 00 00       	call   8007c0 <cprintf>

	FVA->fd_offset = 0;
  80028f:	c7 05 04 c0 cc cc 00 	movl   $0x0,0xccccc004
  800296:	00 00 00 
	memset(buf, 0, sizeof buf);
  800299:	83 c4 0c             	add    $0xc,%esp
  80029c:	68 00 02 00 00       	push   $0x200
  8002a1:	6a 00                	push   $0x0
  8002a3:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  8002a9:	53                   	push   %ebx
  8002aa:	e8 71 0c 00 00       	call   800f20 <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  8002af:	83 c4 0c             	add    $0xc,%esp
  8002b2:	68 00 02 00 00       	push   $0x200
  8002b7:	53                   	push   %ebx
  8002b8:	68 00 c0 cc cc       	push   $0xccccc000
  8002bd:	ff 15 10 30 80 00    	call   *0x803010
  8002c3:	89 c3                	mov    %eax,%ebx
  8002c5:	83 c4 10             	add    $0x10,%esp
  8002c8:	85 c0                	test   %eax,%eax
  8002ca:	0f 88 b0 02 00 00    	js     800580 <umain+0x502>
		panic("file_read after file_write: %e", r);
	if (r != strlen(msg))
  8002d0:	83 ec 0c             	sub    $0xc,%esp
  8002d3:	ff 35 00 30 80 00    	pushl  0x803000
  8002d9:	e8 ca 0a 00 00       	call   800da8 <strlen>
  8002de:	83 c4 10             	add    $0x10,%esp
  8002e1:	39 d8                	cmp    %ebx,%eax
  8002e3:	0f 85 a9 02 00 00    	jne    800592 <umain+0x514>
		panic("file_read after file_write returned wrong length: %d", r);
	if (strcmp(buf, msg) != 0)
  8002e9:	83 ec 08             	sub    $0x8,%esp
  8002ec:	ff 35 00 30 80 00    	pushl  0x803000
  8002f2:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8002f8:	50                   	push   %eax
  8002f9:	e8 87 0b 00 00       	call   800e85 <strcmp>
  8002fe:	83 c4 10             	add    $0x10,%esp
  800301:	85 c0                	test   %eax,%eax
  800303:	0f 85 9b 02 00 00    	jne    8005a4 <umain+0x526>
		panic("file_read after file_write returned wrong data");
	cprintf("file_read after file_write is good\n");
  800309:	83 ec 0c             	sub    $0xc,%esp
  80030c:	68 fc 26 80 00       	push   $0x8026fc
  800311:	e8 aa 04 00 00       	call   8007c0 <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  800316:	83 c4 08             	add    $0x8,%esp
  800319:	6a 00                	push   $0x0
  80031b:	68 00 24 80 00       	push   $0x802400
  800320:	e8 d7 18 00 00       	call   801bfc <open>
  800325:	83 c4 10             	add    $0x10,%esp
  800328:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80032b:	74 08                	je     800335 <umain+0x2b7>
  80032d:	85 c0                	test   %eax,%eax
  80032f:	0f 88 83 02 00 00    	js     8005b8 <umain+0x53a>
		panic("open /not-found: %e", r);
	else if (r >= 0)
  800335:	85 c0                	test   %eax,%eax
  800337:	0f 89 8d 02 00 00    	jns    8005ca <umain+0x54c>
		panic("open /not-found succeeded!");

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  80033d:	83 ec 08             	sub    $0x8,%esp
  800340:	6a 00                	push   $0x0
  800342:	68 35 24 80 00       	push   $0x802435
  800347:	e8 b0 18 00 00       	call   801bfc <open>
  80034c:	83 c4 10             	add    $0x10,%esp
  80034f:	85 c0                	test   %eax,%eax
  800351:	0f 88 87 02 00 00    	js     8005de <umain+0x560>
		panic("open /newmotd: %e", r);
	fd = (struct Fd*) (0xD0000000 + r*PGSIZE);
  800357:	c1 e0 0c             	shl    $0xc,%eax
	if (fd->fd_dev_id != 'f' || fd->fd_offset != 0 || fd->fd_omode != O_RDONLY)
  80035a:	83 b8 00 00 00 d0 66 	cmpl   $0x66,-0x30000000(%eax)
  800361:	0f 85 89 02 00 00    	jne    8005f0 <umain+0x572>
  800367:	83 b8 04 00 00 d0 00 	cmpl   $0x0,-0x2ffffffc(%eax)
  80036e:	0f 85 7c 02 00 00    	jne    8005f0 <umain+0x572>
  800374:	8b 98 08 00 00 d0    	mov    -0x2ffffff8(%eax),%ebx
  80037a:	85 db                	test   %ebx,%ebx
  80037c:	0f 85 6e 02 00 00    	jne    8005f0 <umain+0x572>
		panic("open did not fill struct Fd correctly\n");
	cprintf("open is good\n");
  800382:	83 ec 0c             	sub    $0xc,%esp
  800385:	68 5c 24 80 00       	push   $0x80245c
  80038a:	e8 31 04 00 00       	call   8007c0 <cprintf>

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
  80038f:	83 c4 08             	add    $0x8,%esp
  800392:	68 01 01 00 00       	push   $0x101
  800397:	68 64 25 80 00       	push   $0x802564
  80039c:	e8 5b 18 00 00       	call   801bfc <open>
  8003a1:	89 c7                	mov    %eax,%edi
  8003a3:	83 c4 10             	add    $0x10,%esp
  8003a6:	85 c0                	test   %eax,%eax
  8003a8:	0f 88 56 02 00 00    	js     800604 <umain+0x586>
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
  8003ae:	83 ec 04             	sub    $0x4,%esp
  8003b1:	68 00 02 00 00       	push   $0x200
  8003b6:	6a 00                	push   $0x0
  8003b8:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8003be:	50                   	push   %eax
  8003bf:	e8 5c 0b 00 00       	call   800f20 <memset>
  8003c4:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8003c7:	89 de                	mov    %ebx,%esi
		*(int*)buf = i;
  8003c9:	89 b5 4c fd ff ff    	mov    %esi,-0x2b4(%ebp)
		if ((r = write(f, buf, sizeof(buf))) < 0)
  8003cf:	83 ec 04             	sub    $0x4,%esp
  8003d2:	68 00 02 00 00       	push   $0x200
  8003d7:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8003dd:	50                   	push   %eax
  8003de:	57                   	push   %edi
  8003df:	e8 8e 14 00 00       	call   801872 <write>
  8003e4:	83 c4 10             	add    $0x10,%esp
  8003e7:	85 c0                	test   %eax,%eax
  8003e9:	0f 88 27 02 00 00    	js     800616 <umain+0x598>
  8003ef:	81 c6 00 02 00 00    	add    $0x200,%esi
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8003f5:	81 fe 00 e0 01 00    	cmp    $0x1e000,%esi
  8003fb:	75 cc                	jne    8003c9 <umain+0x34b>
			panic("write /big@%d: %e", i, r);
	}
	close(f);
  8003fd:	83 ec 0c             	sub    $0xc,%esp
  800400:	57                   	push   %edi
  800401:	e8 62 12 00 00       	call   801668 <close>

	if ((f = open("/big", O_RDONLY)) < 0)
  800406:	83 c4 08             	add    $0x8,%esp
  800409:	6a 00                	push   $0x0
  80040b:	68 64 25 80 00       	push   $0x802564
  800410:	e8 e7 17 00 00       	call   801bfc <open>
  800415:	89 c6                	mov    %eax,%esi
  800417:	83 c4 10             	add    $0x10,%esp
  80041a:	85 c0                	test   %eax,%eax
  80041c:	0f 88 0a 02 00 00    	js     80062c <umain+0x5ae>
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  800422:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
		*(int*)buf = i;
  800428:	89 9d 4c fd ff ff    	mov    %ebx,-0x2b4(%ebp)
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  80042e:	83 ec 04             	sub    $0x4,%esp
  800431:	68 00 02 00 00       	push   $0x200
  800436:	57                   	push   %edi
  800437:	56                   	push   %esi
  800438:	e8 ee 13 00 00       	call   80182b <readn>
  80043d:	83 c4 10             	add    $0x10,%esp
  800440:	85 c0                	test   %eax,%eax
  800442:	0f 88 f6 01 00 00    	js     80063e <umain+0x5c0>
			panic("read /big@%d: %e", i, r);
		if (r != sizeof(buf))
  800448:	3d 00 02 00 00       	cmp    $0x200,%eax
  80044d:	0f 85 01 02 00 00    	jne    800654 <umain+0x5d6>
			panic("read /big from %d returned %d < %d bytes",
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
  800453:	8b 85 4c fd ff ff    	mov    -0x2b4(%ebp),%eax
  800459:	39 d8                	cmp    %ebx,%eax
  80045b:	0f 85 0e 02 00 00    	jne    80066f <umain+0x5f1>
  800461:	81 c3 00 02 00 00    	add    $0x200,%ebx
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  800467:	81 fb 00 e0 01 00    	cmp    $0x1e000,%ebx
  80046d:	75 b9                	jne    800428 <umain+0x3aa>
			panic("read /big from %d returned bad data %d",
			      i, *(int*)buf);
	}
	close(f);
  80046f:	83 ec 0c             	sub    $0xc,%esp
  800472:	56                   	push   %esi
  800473:	e8 f0 11 00 00       	call   801668 <close>
	cprintf("large file is good\n");
  800478:	c7 04 24 a9 25 80 00 	movl   $0x8025a9,(%esp)
  80047f:	e8 3c 03 00 00       	call   8007c0 <cprintf>
}
  800484:	83 c4 10             	add    $0x10,%esp
  800487:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80048a:	5b                   	pop    %ebx
  80048b:	5e                   	pop    %esi
  80048c:	5f                   	pop    %edi
  80048d:	5d                   	pop    %ebp
  80048e:	c3                   	ret    
		panic("serve_open /not-found: %e", r);
  80048f:	50                   	push   %eax
  800490:	68 0b 24 80 00       	push   $0x80240b
  800495:	6a 20                	push   $0x20
  800497:	68 25 24 80 00       	push   $0x802425
  80049c:	e8 44 02 00 00       	call   8006e5 <_panic>
		panic("serve_open /not-found succeeded!");
  8004a1:	83 ec 04             	sub    $0x4,%esp
  8004a4:	68 c0 25 80 00       	push   $0x8025c0
  8004a9:	6a 22                	push   $0x22
  8004ab:	68 25 24 80 00       	push   $0x802425
  8004b0:	e8 30 02 00 00       	call   8006e5 <_panic>
		panic("serve_open /newmotd: %e", r);
  8004b5:	50                   	push   %eax
  8004b6:	68 3e 24 80 00       	push   $0x80243e
  8004bb:	6a 25                	push   $0x25
  8004bd:	68 25 24 80 00       	push   $0x802425
  8004c2:	e8 1e 02 00 00       	call   8006e5 <_panic>
		panic("serve_open did not fill struct Fd correctly\n");
  8004c7:	83 ec 04             	sub    $0x4,%esp
  8004ca:	68 e4 25 80 00       	push   $0x8025e4
  8004cf:	6a 27                	push   $0x27
  8004d1:	68 25 24 80 00       	push   $0x802425
  8004d6:	e8 0a 02 00 00       	call   8006e5 <_panic>
		panic("file_stat: %e", r);
  8004db:	50                   	push   %eax
  8004dc:	68 6a 24 80 00       	push   $0x80246a
  8004e1:	6a 2b                	push   $0x2b
  8004e3:	68 25 24 80 00       	push   $0x802425
  8004e8:	e8 f8 01 00 00       	call   8006e5 <_panic>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
  8004ed:	83 ec 0c             	sub    $0xc,%esp
  8004f0:	ff 35 00 30 80 00    	pushl  0x803000
  8004f6:	e8 ad 08 00 00       	call   800da8 <strlen>
  8004fb:	89 04 24             	mov    %eax,(%esp)
  8004fe:	ff 75 cc             	pushl  -0x34(%ebp)
  800501:	68 14 26 80 00       	push   $0x802614
  800506:	6a 2d                	push   $0x2d
  800508:	68 25 24 80 00       	push   $0x802425
  80050d:	e8 d3 01 00 00       	call   8006e5 <_panic>
		panic("file_read: %e", r);
  800512:	50                   	push   %eax
  800513:	68 8b 24 80 00       	push   $0x80248b
  800518:	6a 32                	push   $0x32
  80051a:	68 25 24 80 00       	push   $0x802425
  80051f:	e8 c1 01 00 00       	call   8006e5 <_panic>
		panic("file_read returned wrong data");
  800524:	83 ec 04             	sub    $0x4,%esp
  800527:	68 99 24 80 00       	push   $0x802499
  80052c:	6a 34                	push   $0x34
  80052e:	68 25 24 80 00       	push   $0x802425
  800533:	e8 ad 01 00 00       	call   8006e5 <_panic>
		panic("file_close: %e", r);
  800538:	50                   	push   %eax
  800539:	68 ca 24 80 00       	push   $0x8024ca
  80053e:	6a 38                	push   $0x38
  800540:	68 25 24 80 00       	push   $0x802425
  800545:	e8 9b 01 00 00       	call   8006e5 <_panic>
		panic("serve_read does not handle stale fileids correctly: %e", r);
  80054a:	50                   	push   %eax
  80054b:	68 3c 26 80 00       	push   $0x80263c
  800550:	6a 43                	push   $0x43
  800552:	68 25 24 80 00       	push   $0x802425
  800557:	e8 89 01 00 00       	call   8006e5 <_panic>
		panic("serve_open /new-file: %e", r);
  80055c:	50                   	push   %eax
  80055d:	68 0d 25 80 00       	push   $0x80250d
  800562:	6a 48                	push   $0x48
  800564:	68 25 24 80 00       	push   $0x802425
  800569:	e8 77 01 00 00       	call   8006e5 <_panic>
		panic("file_write: %e", r);
  80056e:	53                   	push   %ebx
  80056f:	68 26 25 80 00       	push   $0x802526
  800574:	6a 4b                	push   $0x4b
  800576:	68 25 24 80 00       	push   $0x802425
  80057b:	e8 65 01 00 00       	call   8006e5 <_panic>
		panic("file_read after file_write: %e", r);
  800580:	50                   	push   %eax
  800581:	68 74 26 80 00       	push   $0x802674
  800586:	6a 51                	push   $0x51
  800588:	68 25 24 80 00       	push   $0x802425
  80058d:	e8 53 01 00 00       	call   8006e5 <_panic>
		panic("file_read after file_write returned wrong length: %d", r);
  800592:	53                   	push   %ebx
  800593:	68 94 26 80 00       	push   $0x802694
  800598:	6a 53                	push   $0x53
  80059a:	68 25 24 80 00       	push   $0x802425
  80059f:	e8 41 01 00 00       	call   8006e5 <_panic>
		panic("file_read after file_write returned wrong data");
  8005a4:	83 ec 04             	sub    $0x4,%esp
  8005a7:	68 cc 26 80 00       	push   $0x8026cc
  8005ac:	6a 55                	push   $0x55
  8005ae:	68 25 24 80 00       	push   $0x802425
  8005b3:	e8 2d 01 00 00       	call   8006e5 <_panic>
		panic("open /not-found: %e", r);
  8005b8:	50                   	push   %eax
  8005b9:	68 11 24 80 00       	push   $0x802411
  8005be:	6a 5a                	push   $0x5a
  8005c0:	68 25 24 80 00       	push   $0x802425
  8005c5:	e8 1b 01 00 00       	call   8006e5 <_panic>
		panic("open /not-found succeeded!");
  8005ca:	83 ec 04             	sub    $0x4,%esp
  8005cd:	68 49 25 80 00       	push   $0x802549
  8005d2:	6a 5c                	push   $0x5c
  8005d4:	68 25 24 80 00       	push   $0x802425
  8005d9:	e8 07 01 00 00       	call   8006e5 <_panic>
		panic("open /newmotd: %e", r);
  8005de:	50                   	push   %eax
  8005df:	68 44 24 80 00       	push   $0x802444
  8005e4:	6a 5f                	push   $0x5f
  8005e6:	68 25 24 80 00       	push   $0x802425
  8005eb:	e8 f5 00 00 00       	call   8006e5 <_panic>
		panic("open did not fill struct Fd correctly\n");
  8005f0:	83 ec 04             	sub    $0x4,%esp
  8005f3:	68 20 27 80 00       	push   $0x802720
  8005f8:	6a 62                	push   $0x62
  8005fa:	68 25 24 80 00       	push   $0x802425
  8005ff:	e8 e1 00 00 00       	call   8006e5 <_panic>
		panic("creat /big: %e", f);
  800604:	50                   	push   %eax
  800605:	68 69 25 80 00       	push   $0x802569
  80060a:	6a 67                	push   $0x67
  80060c:	68 25 24 80 00       	push   $0x802425
  800611:	e8 cf 00 00 00       	call   8006e5 <_panic>
			panic("write /big@%d: %e", i, r);
  800616:	83 ec 0c             	sub    $0xc,%esp
  800619:	50                   	push   %eax
  80061a:	56                   	push   %esi
  80061b:	68 78 25 80 00       	push   $0x802578
  800620:	6a 6c                	push   $0x6c
  800622:	68 25 24 80 00       	push   $0x802425
  800627:	e8 b9 00 00 00       	call   8006e5 <_panic>
		panic("open /big: %e", f);
  80062c:	50                   	push   %eax
  80062d:	68 8a 25 80 00       	push   $0x80258a
  800632:	6a 71                	push   $0x71
  800634:	68 25 24 80 00       	push   $0x802425
  800639:	e8 a7 00 00 00       	call   8006e5 <_panic>
			panic("read /big@%d: %e", i, r);
  80063e:	83 ec 0c             	sub    $0xc,%esp
  800641:	50                   	push   %eax
  800642:	53                   	push   %ebx
  800643:	68 98 25 80 00       	push   $0x802598
  800648:	6a 75                	push   $0x75
  80064a:	68 25 24 80 00       	push   $0x802425
  80064f:	e8 91 00 00 00       	call   8006e5 <_panic>
			panic("read /big from %d returned %d < %d bytes",
  800654:	83 ec 08             	sub    $0x8,%esp
  800657:	68 00 02 00 00       	push   $0x200
  80065c:	50                   	push   %eax
  80065d:	53                   	push   %ebx
  80065e:	68 48 27 80 00       	push   $0x802748
  800663:	6a 78                	push   $0x78
  800665:	68 25 24 80 00       	push   $0x802425
  80066a:	e8 76 00 00 00       	call   8006e5 <_panic>
			panic("read /big from %d returned bad data %d",
  80066f:	83 ec 0c             	sub    $0xc,%esp
  800672:	50                   	push   %eax
  800673:	53                   	push   %ebx
  800674:	68 74 27 80 00       	push   $0x802774
  800679:	6a 7b                	push   $0x7b
  80067b:	68 25 24 80 00       	push   $0x802425
  800680:	e8 60 00 00 00       	call   8006e5 <_panic>

00800685 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800685:	55                   	push   %ebp
  800686:	89 e5                	mov    %esp,%ebp
  800688:	56                   	push   %esi
  800689:	53                   	push   %ebx
  80068a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80068d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800690:	e8 05 0b 00 00       	call   80119a <sys_getenvid>
	thisenv = envs + ENVX(envid); 
  800695:	25 ff 03 00 00       	and    $0x3ff,%eax
  80069a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80069d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8006a2:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8006a7:	85 db                	test   %ebx,%ebx
  8006a9:	7e 07                	jle    8006b2 <libmain+0x2d>
		binaryname = argv[0];
  8006ab:	8b 06                	mov    (%esi),%eax
  8006ad:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8006b2:	83 ec 08             	sub    $0x8,%esp
  8006b5:	56                   	push   %esi
  8006b6:	53                   	push   %ebx
  8006b7:	e8 c2 f9 ff ff       	call   80007e <umain>

	// exit gracefully
	exit();
  8006bc:	e8 0a 00 00 00       	call   8006cb <exit>
}
  8006c1:	83 c4 10             	add    $0x10,%esp
  8006c4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8006c7:	5b                   	pop    %ebx
  8006c8:	5e                   	pop    %esi
  8006c9:	5d                   	pop    %ebp
  8006ca:	c3                   	ret    

008006cb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8006cb:	55                   	push   %ebp
  8006cc:	89 e5                	mov    %esp,%ebp
  8006ce:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8006d1:	e8 bd 0f 00 00       	call   801693 <close_all>
	sys_env_destroy(0);
  8006d6:	83 ec 0c             	sub    $0xc,%esp
  8006d9:	6a 00                	push   $0x0
  8006db:	e8 79 0a 00 00       	call   801159 <sys_env_destroy>
}
  8006e0:	83 c4 10             	add    $0x10,%esp
  8006e3:	c9                   	leave  
  8006e4:	c3                   	ret    

008006e5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8006e5:	55                   	push   %ebp
  8006e6:	89 e5                	mov    %esp,%ebp
  8006e8:	56                   	push   %esi
  8006e9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8006ea:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8006ed:	8b 35 04 30 80 00    	mov    0x803004,%esi
  8006f3:	e8 a2 0a 00 00       	call   80119a <sys_getenvid>
  8006f8:	83 ec 0c             	sub    $0xc,%esp
  8006fb:	ff 75 0c             	pushl  0xc(%ebp)
  8006fe:	ff 75 08             	pushl  0x8(%ebp)
  800701:	56                   	push   %esi
  800702:	50                   	push   %eax
  800703:	68 cc 27 80 00       	push   $0x8027cc
  800708:	e8 b3 00 00 00       	call   8007c0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80070d:	83 c4 18             	add    $0x18,%esp
  800710:	53                   	push   %ebx
  800711:	ff 75 10             	pushl  0x10(%ebp)
  800714:	e8 56 00 00 00       	call   80076f <vcprintf>
	cprintf("\n");
  800719:	c7 04 24 27 2c 80 00 	movl   $0x802c27,(%esp)
  800720:	e8 9b 00 00 00       	call   8007c0 <cprintf>
  800725:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800728:	cc                   	int3   
  800729:	eb fd                	jmp    800728 <_panic+0x43>

0080072b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80072b:	55                   	push   %ebp
  80072c:	89 e5                	mov    %esp,%ebp
  80072e:	53                   	push   %ebx
  80072f:	83 ec 04             	sub    $0x4,%esp
  800732:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800735:	8b 13                	mov    (%ebx),%edx
  800737:	8d 42 01             	lea    0x1(%edx),%eax
  80073a:	89 03                	mov    %eax,(%ebx)
  80073c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80073f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800743:	3d ff 00 00 00       	cmp    $0xff,%eax
  800748:	74 09                	je     800753 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80074a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80074e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800751:	c9                   	leave  
  800752:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800753:	83 ec 08             	sub    $0x8,%esp
  800756:	68 ff 00 00 00       	push   $0xff
  80075b:	8d 43 08             	lea    0x8(%ebx),%eax
  80075e:	50                   	push   %eax
  80075f:	e8 b8 09 00 00       	call   80111c <sys_cputs>
		b->idx = 0;
  800764:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80076a:	83 c4 10             	add    $0x10,%esp
  80076d:	eb db                	jmp    80074a <putch+0x1f>

0080076f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80076f:	55                   	push   %ebp
  800770:	89 e5                	mov    %esp,%ebp
  800772:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800778:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80077f:	00 00 00 
	b.cnt = 0;
  800782:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800789:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80078c:	ff 75 0c             	pushl  0xc(%ebp)
  80078f:	ff 75 08             	pushl  0x8(%ebp)
  800792:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800798:	50                   	push   %eax
  800799:	68 2b 07 80 00       	push   $0x80072b
  80079e:	e8 1a 01 00 00       	call   8008bd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8007a3:	83 c4 08             	add    $0x8,%esp
  8007a6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8007ac:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8007b2:	50                   	push   %eax
  8007b3:	e8 64 09 00 00       	call   80111c <sys_cputs>

	return b.cnt;
}
  8007b8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8007be:	c9                   	leave  
  8007bf:	c3                   	ret    

008007c0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8007c6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8007c9:	50                   	push   %eax
  8007ca:	ff 75 08             	pushl  0x8(%ebp)
  8007cd:	e8 9d ff ff ff       	call   80076f <vcprintf>
	va_end(ap);

	return cnt;
}
  8007d2:	c9                   	leave  
  8007d3:	c3                   	ret    

008007d4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8007d4:	55                   	push   %ebp
  8007d5:	89 e5                	mov    %esp,%ebp
  8007d7:	57                   	push   %edi
  8007d8:	56                   	push   %esi
  8007d9:	53                   	push   %ebx
  8007da:	83 ec 1c             	sub    $0x1c,%esp
  8007dd:	89 c7                	mov    %eax,%edi
  8007df:	89 d6                	mov    %edx,%esi
  8007e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ea:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8007ed:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8007f0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007f5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8007f8:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8007fb:	39 d3                	cmp    %edx,%ebx
  8007fd:	72 05                	jb     800804 <printnum+0x30>
  8007ff:	39 45 10             	cmp    %eax,0x10(%ebp)
  800802:	77 7a                	ja     80087e <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800804:	83 ec 0c             	sub    $0xc,%esp
  800807:	ff 75 18             	pushl  0x18(%ebp)
  80080a:	8b 45 14             	mov    0x14(%ebp),%eax
  80080d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800810:	53                   	push   %ebx
  800811:	ff 75 10             	pushl  0x10(%ebp)
  800814:	83 ec 08             	sub    $0x8,%esp
  800817:	ff 75 e4             	pushl  -0x1c(%ebp)
  80081a:	ff 75 e0             	pushl  -0x20(%ebp)
  80081d:	ff 75 dc             	pushl  -0x24(%ebp)
  800820:	ff 75 d8             	pushl  -0x28(%ebp)
  800823:	e8 88 19 00 00       	call   8021b0 <__udivdi3>
  800828:	83 c4 18             	add    $0x18,%esp
  80082b:	52                   	push   %edx
  80082c:	50                   	push   %eax
  80082d:	89 f2                	mov    %esi,%edx
  80082f:	89 f8                	mov    %edi,%eax
  800831:	e8 9e ff ff ff       	call   8007d4 <printnum>
  800836:	83 c4 20             	add    $0x20,%esp
  800839:	eb 13                	jmp    80084e <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80083b:	83 ec 08             	sub    $0x8,%esp
  80083e:	56                   	push   %esi
  80083f:	ff 75 18             	pushl  0x18(%ebp)
  800842:	ff d7                	call   *%edi
  800844:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800847:	83 eb 01             	sub    $0x1,%ebx
  80084a:	85 db                	test   %ebx,%ebx
  80084c:	7f ed                	jg     80083b <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80084e:	83 ec 08             	sub    $0x8,%esp
  800851:	56                   	push   %esi
  800852:	83 ec 04             	sub    $0x4,%esp
  800855:	ff 75 e4             	pushl  -0x1c(%ebp)
  800858:	ff 75 e0             	pushl  -0x20(%ebp)
  80085b:	ff 75 dc             	pushl  -0x24(%ebp)
  80085e:	ff 75 d8             	pushl  -0x28(%ebp)
  800861:	e8 6a 1a 00 00       	call   8022d0 <__umoddi3>
  800866:	83 c4 14             	add    $0x14,%esp
  800869:	0f be 80 ef 27 80 00 	movsbl 0x8027ef(%eax),%eax
  800870:	50                   	push   %eax
  800871:	ff d7                	call   *%edi
}
  800873:	83 c4 10             	add    $0x10,%esp
  800876:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800879:	5b                   	pop    %ebx
  80087a:	5e                   	pop    %esi
  80087b:	5f                   	pop    %edi
  80087c:	5d                   	pop    %ebp
  80087d:	c3                   	ret    
  80087e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800881:	eb c4                	jmp    800847 <printnum+0x73>

00800883 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800883:	55                   	push   %ebp
  800884:	89 e5                	mov    %esp,%ebp
  800886:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800889:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80088d:	8b 10                	mov    (%eax),%edx
  80088f:	3b 50 04             	cmp    0x4(%eax),%edx
  800892:	73 0a                	jae    80089e <sprintputch+0x1b>
		*b->buf++ = ch;
  800894:	8d 4a 01             	lea    0x1(%edx),%ecx
  800897:	89 08                	mov    %ecx,(%eax)
  800899:	8b 45 08             	mov    0x8(%ebp),%eax
  80089c:	88 02                	mov    %al,(%edx)
}
  80089e:	5d                   	pop    %ebp
  80089f:	c3                   	ret    

008008a0 <printfmt>:
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8008a6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8008a9:	50                   	push   %eax
  8008aa:	ff 75 10             	pushl  0x10(%ebp)
  8008ad:	ff 75 0c             	pushl  0xc(%ebp)
  8008b0:	ff 75 08             	pushl  0x8(%ebp)
  8008b3:	e8 05 00 00 00       	call   8008bd <vprintfmt>
}
  8008b8:	83 c4 10             	add    $0x10,%esp
  8008bb:	c9                   	leave  
  8008bc:	c3                   	ret    

008008bd <vprintfmt>:
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	57                   	push   %edi
  8008c1:	56                   	push   %esi
  8008c2:	53                   	push   %ebx
  8008c3:	83 ec 2c             	sub    $0x2c,%esp
  8008c6:	8b 75 08             	mov    0x8(%ebp),%esi
  8008c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008cc:	8b 7d 10             	mov    0x10(%ebp),%edi
  8008cf:	e9 c1 03 00 00       	jmp    800c95 <vprintfmt+0x3d8>
		padc = ' ';
  8008d4:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8008d8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8008df:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8008e6:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8008ed:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8008f2:	8d 47 01             	lea    0x1(%edi),%eax
  8008f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008f8:	0f b6 17             	movzbl (%edi),%edx
  8008fb:	8d 42 dd             	lea    -0x23(%edx),%eax
  8008fe:	3c 55                	cmp    $0x55,%al
  800900:	0f 87 12 04 00 00    	ja     800d18 <vprintfmt+0x45b>
  800906:	0f b6 c0             	movzbl %al,%eax
  800909:	ff 24 85 40 29 80 00 	jmp    *0x802940(,%eax,4)
  800910:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800913:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800917:	eb d9                	jmp    8008f2 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800919:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80091c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800920:	eb d0                	jmp    8008f2 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800922:	0f b6 d2             	movzbl %dl,%edx
  800925:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800928:	b8 00 00 00 00       	mov    $0x0,%eax
  80092d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800930:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800933:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800937:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80093a:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80093d:	83 f9 09             	cmp    $0x9,%ecx
  800940:	77 55                	ja     800997 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800942:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800945:	eb e9                	jmp    800930 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  800947:	8b 45 14             	mov    0x14(%ebp),%eax
  80094a:	8b 00                	mov    (%eax),%eax
  80094c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80094f:	8b 45 14             	mov    0x14(%ebp),%eax
  800952:	8d 40 04             	lea    0x4(%eax),%eax
  800955:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800958:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80095b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80095f:	79 91                	jns    8008f2 <vprintfmt+0x35>
				width = precision, precision = -1;
  800961:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800964:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800967:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80096e:	eb 82                	jmp    8008f2 <vprintfmt+0x35>
  800970:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800973:	85 c0                	test   %eax,%eax
  800975:	ba 00 00 00 00       	mov    $0x0,%edx
  80097a:	0f 49 d0             	cmovns %eax,%edx
  80097d:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800980:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800983:	e9 6a ff ff ff       	jmp    8008f2 <vprintfmt+0x35>
  800988:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80098b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800992:	e9 5b ff ff ff       	jmp    8008f2 <vprintfmt+0x35>
  800997:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80099a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80099d:	eb bc                	jmp    80095b <vprintfmt+0x9e>
			lflag++;
  80099f:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8009a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8009a5:	e9 48 ff ff ff       	jmp    8008f2 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8009aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8009ad:	8d 78 04             	lea    0x4(%eax),%edi
  8009b0:	83 ec 08             	sub    $0x8,%esp
  8009b3:	53                   	push   %ebx
  8009b4:	ff 30                	pushl  (%eax)
  8009b6:	ff d6                	call   *%esi
			break;
  8009b8:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8009bb:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8009be:	e9 cf 02 00 00       	jmp    800c92 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8009c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c6:	8d 78 04             	lea    0x4(%eax),%edi
  8009c9:	8b 00                	mov    (%eax),%eax
  8009cb:	99                   	cltd   
  8009cc:	31 d0                	xor    %edx,%eax
  8009ce:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8009d0:	83 f8 0f             	cmp    $0xf,%eax
  8009d3:	7f 23                	jg     8009f8 <vprintfmt+0x13b>
  8009d5:	8b 14 85 a0 2a 80 00 	mov    0x802aa0(,%eax,4),%edx
  8009dc:	85 d2                	test   %edx,%edx
  8009de:	74 18                	je     8009f8 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8009e0:	52                   	push   %edx
  8009e1:	68 f5 2b 80 00       	push   $0x802bf5
  8009e6:	53                   	push   %ebx
  8009e7:	56                   	push   %esi
  8009e8:	e8 b3 fe ff ff       	call   8008a0 <printfmt>
  8009ed:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8009f0:	89 7d 14             	mov    %edi,0x14(%ebp)
  8009f3:	e9 9a 02 00 00       	jmp    800c92 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  8009f8:	50                   	push   %eax
  8009f9:	68 07 28 80 00       	push   $0x802807
  8009fe:	53                   	push   %ebx
  8009ff:	56                   	push   %esi
  800a00:	e8 9b fe ff ff       	call   8008a0 <printfmt>
  800a05:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800a08:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800a0b:	e9 82 02 00 00       	jmp    800c92 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  800a10:	8b 45 14             	mov    0x14(%ebp),%eax
  800a13:	83 c0 04             	add    $0x4,%eax
  800a16:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800a19:	8b 45 14             	mov    0x14(%ebp),%eax
  800a1c:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800a1e:	85 ff                	test   %edi,%edi
  800a20:	b8 00 28 80 00       	mov    $0x802800,%eax
  800a25:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800a28:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800a2c:	0f 8e bd 00 00 00    	jle    800aef <vprintfmt+0x232>
  800a32:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800a36:	75 0e                	jne    800a46 <vprintfmt+0x189>
  800a38:	89 75 08             	mov    %esi,0x8(%ebp)
  800a3b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a3e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a41:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a44:	eb 6d                	jmp    800ab3 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  800a46:	83 ec 08             	sub    $0x8,%esp
  800a49:	ff 75 d0             	pushl  -0x30(%ebp)
  800a4c:	57                   	push   %edi
  800a4d:	e8 6e 03 00 00       	call   800dc0 <strnlen>
  800a52:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800a55:	29 c1                	sub    %eax,%ecx
  800a57:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800a5a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800a5d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800a61:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a64:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800a67:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800a69:	eb 0f                	jmp    800a7a <vprintfmt+0x1bd>
					putch(padc, putdat);
  800a6b:	83 ec 08             	sub    $0x8,%esp
  800a6e:	53                   	push   %ebx
  800a6f:	ff 75 e0             	pushl  -0x20(%ebp)
  800a72:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800a74:	83 ef 01             	sub    $0x1,%edi
  800a77:	83 c4 10             	add    $0x10,%esp
  800a7a:	85 ff                	test   %edi,%edi
  800a7c:	7f ed                	jg     800a6b <vprintfmt+0x1ae>
  800a7e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800a81:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800a84:	85 c9                	test   %ecx,%ecx
  800a86:	b8 00 00 00 00       	mov    $0x0,%eax
  800a8b:	0f 49 c1             	cmovns %ecx,%eax
  800a8e:	29 c1                	sub    %eax,%ecx
  800a90:	89 75 08             	mov    %esi,0x8(%ebp)
  800a93:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a96:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a99:	89 cb                	mov    %ecx,%ebx
  800a9b:	eb 16                	jmp    800ab3 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  800a9d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800aa1:	75 31                	jne    800ad4 <vprintfmt+0x217>
					putch(ch, putdat);
  800aa3:	83 ec 08             	sub    $0x8,%esp
  800aa6:	ff 75 0c             	pushl  0xc(%ebp)
  800aa9:	50                   	push   %eax
  800aaa:	ff 55 08             	call   *0x8(%ebp)
  800aad:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ab0:	83 eb 01             	sub    $0x1,%ebx
  800ab3:	83 c7 01             	add    $0x1,%edi
  800ab6:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800aba:	0f be c2             	movsbl %dl,%eax
  800abd:	85 c0                	test   %eax,%eax
  800abf:	74 59                	je     800b1a <vprintfmt+0x25d>
  800ac1:	85 f6                	test   %esi,%esi
  800ac3:	78 d8                	js     800a9d <vprintfmt+0x1e0>
  800ac5:	83 ee 01             	sub    $0x1,%esi
  800ac8:	79 d3                	jns    800a9d <vprintfmt+0x1e0>
  800aca:	89 df                	mov    %ebx,%edi
  800acc:	8b 75 08             	mov    0x8(%ebp),%esi
  800acf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ad2:	eb 37                	jmp    800b0b <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  800ad4:	0f be d2             	movsbl %dl,%edx
  800ad7:	83 ea 20             	sub    $0x20,%edx
  800ada:	83 fa 5e             	cmp    $0x5e,%edx
  800add:	76 c4                	jbe    800aa3 <vprintfmt+0x1e6>
					putch('?', putdat);
  800adf:	83 ec 08             	sub    $0x8,%esp
  800ae2:	ff 75 0c             	pushl  0xc(%ebp)
  800ae5:	6a 3f                	push   $0x3f
  800ae7:	ff 55 08             	call   *0x8(%ebp)
  800aea:	83 c4 10             	add    $0x10,%esp
  800aed:	eb c1                	jmp    800ab0 <vprintfmt+0x1f3>
  800aef:	89 75 08             	mov    %esi,0x8(%ebp)
  800af2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800af5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800af8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800afb:	eb b6                	jmp    800ab3 <vprintfmt+0x1f6>
				putch(' ', putdat);
  800afd:	83 ec 08             	sub    $0x8,%esp
  800b00:	53                   	push   %ebx
  800b01:	6a 20                	push   $0x20
  800b03:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800b05:	83 ef 01             	sub    $0x1,%edi
  800b08:	83 c4 10             	add    $0x10,%esp
  800b0b:	85 ff                	test   %edi,%edi
  800b0d:	7f ee                	jg     800afd <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800b0f:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800b12:	89 45 14             	mov    %eax,0x14(%ebp)
  800b15:	e9 78 01 00 00       	jmp    800c92 <vprintfmt+0x3d5>
  800b1a:	89 df                	mov    %ebx,%edi
  800b1c:	8b 75 08             	mov    0x8(%ebp),%esi
  800b1f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b22:	eb e7                	jmp    800b0b <vprintfmt+0x24e>
	if (lflag >= 2)
  800b24:	83 f9 01             	cmp    $0x1,%ecx
  800b27:	7e 3f                	jle    800b68 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800b29:	8b 45 14             	mov    0x14(%ebp),%eax
  800b2c:	8b 50 04             	mov    0x4(%eax),%edx
  800b2f:	8b 00                	mov    (%eax),%eax
  800b31:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b34:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b37:	8b 45 14             	mov    0x14(%ebp),%eax
  800b3a:	8d 40 08             	lea    0x8(%eax),%eax
  800b3d:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800b40:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800b44:	79 5c                	jns    800ba2 <vprintfmt+0x2e5>
				putch('-', putdat);
  800b46:	83 ec 08             	sub    $0x8,%esp
  800b49:	53                   	push   %ebx
  800b4a:	6a 2d                	push   $0x2d
  800b4c:	ff d6                	call   *%esi
				num = -(long long) num;
  800b4e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800b51:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800b54:	f7 da                	neg    %edx
  800b56:	83 d1 00             	adc    $0x0,%ecx
  800b59:	f7 d9                	neg    %ecx
  800b5b:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800b5e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b63:	e9 10 01 00 00       	jmp    800c78 <vprintfmt+0x3bb>
	else if (lflag)
  800b68:	85 c9                	test   %ecx,%ecx
  800b6a:	75 1b                	jne    800b87 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800b6c:	8b 45 14             	mov    0x14(%ebp),%eax
  800b6f:	8b 00                	mov    (%eax),%eax
  800b71:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b74:	89 c1                	mov    %eax,%ecx
  800b76:	c1 f9 1f             	sar    $0x1f,%ecx
  800b79:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800b7c:	8b 45 14             	mov    0x14(%ebp),%eax
  800b7f:	8d 40 04             	lea    0x4(%eax),%eax
  800b82:	89 45 14             	mov    %eax,0x14(%ebp)
  800b85:	eb b9                	jmp    800b40 <vprintfmt+0x283>
		return va_arg(*ap, long);
  800b87:	8b 45 14             	mov    0x14(%ebp),%eax
  800b8a:	8b 00                	mov    (%eax),%eax
  800b8c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b8f:	89 c1                	mov    %eax,%ecx
  800b91:	c1 f9 1f             	sar    $0x1f,%ecx
  800b94:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800b97:	8b 45 14             	mov    0x14(%ebp),%eax
  800b9a:	8d 40 04             	lea    0x4(%eax),%eax
  800b9d:	89 45 14             	mov    %eax,0x14(%ebp)
  800ba0:	eb 9e                	jmp    800b40 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  800ba2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800ba5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800ba8:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bad:	e9 c6 00 00 00       	jmp    800c78 <vprintfmt+0x3bb>
	if (lflag >= 2)
  800bb2:	83 f9 01             	cmp    $0x1,%ecx
  800bb5:	7e 18                	jle    800bcf <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  800bb7:	8b 45 14             	mov    0x14(%ebp),%eax
  800bba:	8b 10                	mov    (%eax),%edx
  800bbc:	8b 48 04             	mov    0x4(%eax),%ecx
  800bbf:	8d 40 08             	lea    0x8(%eax),%eax
  800bc2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800bc5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bca:	e9 a9 00 00 00       	jmp    800c78 <vprintfmt+0x3bb>
	else if (lflag)
  800bcf:	85 c9                	test   %ecx,%ecx
  800bd1:	75 1a                	jne    800bed <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  800bd3:	8b 45 14             	mov    0x14(%ebp),%eax
  800bd6:	8b 10                	mov    (%eax),%edx
  800bd8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bdd:	8d 40 04             	lea    0x4(%eax),%eax
  800be0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800be3:	b8 0a 00 00 00       	mov    $0xa,%eax
  800be8:	e9 8b 00 00 00       	jmp    800c78 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800bed:	8b 45 14             	mov    0x14(%ebp),%eax
  800bf0:	8b 10                	mov    (%eax),%edx
  800bf2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bf7:	8d 40 04             	lea    0x4(%eax),%eax
  800bfa:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800bfd:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c02:	eb 74                	jmp    800c78 <vprintfmt+0x3bb>
	if (lflag >= 2)
  800c04:	83 f9 01             	cmp    $0x1,%ecx
  800c07:	7e 15                	jle    800c1e <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  800c09:	8b 45 14             	mov    0x14(%ebp),%eax
  800c0c:	8b 10                	mov    (%eax),%edx
  800c0e:	8b 48 04             	mov    0x4(%eax),%ecx
  800c11:	8d 40 08             	lea    0x8(%eax),%eax
  800c14:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800c17:	b8 08 00 00 00       	mov    $0x8,%eax
  800c1c:	eb 5a                	jmp    800c78 <vprintfmt+0x3bb>
	else if (lflag)
  800c1e:	85 c9                	test   %ecx,%ecx
  800c20:	75 17                	jne    800c39 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  800c22:	8b 45 14             	mov    0x14(%ebp),%eax
  800c25:	8b 10                	mov    (%eax),%edx
  800c27:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c2c:	8d 40 04             	lea    0x4(%eax),%eax
  800c2f:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800c32:	b8 08 00 00 00       	mov    $0x8,%eax
  800c37:	eb 3f                	jmp    800c78 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800c39:	8b 45 14             	mov    0x14(%ebp),%eax
  800c3c:	8b 10                	mov    (%eax),%edx
  800c3e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c43:	8d 40 04             	lea    0x4(%eax),%eax
  800c46:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800c49:	b8 08 00 00 00       	mov    $0x8,%eax
  800c4e:	eb 28                	jmp    800c78 <vprintfmt+0x3bb>
			putch('0', putdat);
  800c50:	83 ec 08             	sub    $0x8,%esp
  800c53:	53                   	push   %ebx
  800c54:	6a 30                	push   $0x30
  800c56:	ff d6                	call   *%esi
			putch('x', putdat);
  800c58:	83 c4 08             	add    $0x8,%esp
  800c5b:	53                   	push   %ebx
  800c5c:	6a 78                	push   $0x78
  800c5e:	ff d6                	call   *%esi
			num = (unsigned long long)
  800c60:	8b 45 14             	mov    0x14(%ebp),%eax
  800c63:	8b 10                	mov    (%eax),%edx
  800c65:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800c6a:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800c6d:	8d 40 04             	lea    0x4(%eax),%eax
  800c70:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800c73:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800c78:	83 ec 0c             	sub    $0xc,%esp
  800c7b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800c7f:	57                   	push   %edi
  800c80:	ff 75 e0             	pushl  -0x20(%ebp)
  800c83:	50                   	push   %eax
  800c84:	51                   	push   %ecx
  800c85:	52                   	push   %edx
  800c86:	89 da                	mov    %ebx,%edx
  800c88:	89 f0                	mov    %esi,%eax
  800c8a:	e8 45 fb ff ff       	call   8007d4 <printnum>
			break;
  800c8f:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800c92:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800c95:	83 c7 01             	add    $0x1,%edi
  800c98:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800c9c:	83 f8 25             	cmp    $0x25,%eax
  800c9f:	0f 84 2f fc ff ff    	je     8008d4 <vprintfmt+0x17>
			if (ch == '\0')
  800ca5:	85 c0                	test   %eax,%eax
  800ca7:	0f 84 8b 00 00 00    	je     800d38 <vprintfmt+0x47b>
			putch(ch, putdat);
  800cad:	83 ec 08             	sub    $0x8,%esp
  800cb0:	53                   	push   %ebx
  800cb1:	50                   	push   %eax
  800cb2:	ff d6                	call   *%esi
  800cb4:	83 c4 10             	add    $0x10,%esp
  800cb7:	eb dc                	jmp    800c95 <vprintfmt+0x3d8>
	if (lflag >= 2)
  800cb9:	83 f9 01             	cmp    $0x1,%ecx
  800cbc:	7e 15                	jle    800cd3 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  800cbe:	8b 45 14             	mov    0x14(%ebp),%eax
  800cc1:	8b 10                	mov    (%eax),%edx
  800cc3:	8b 48 04             	mov    0x4(%eax),%ecx
  800cc6:	8d 40 08             	lea    0x8(%eax),%eax
  800cc9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800ccc:	b8 10 00 00 00       	mov    $0x10,%eax
  800cd1:	eb a5                	jmp    800c78 <vprintfmt+0x3bb>
	else if (lflag)
  800cd3:	85 c9                	test   %ecx,%ecx
  800cd5:	75 17                	jne    800cee <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  800cd7:	8b 45 14             	mov    0x14(%ebp),%eax
  800cda:	8b 10                	mov    (%eax),%edx
  800cdc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ce1:	8d 40 04             	lea    0x4(%eax),%eax
  800ce4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800ce7:	b8 10 00 00 00       	mov    $0x10,%eax
  800cec:	eb 8a                	jmp    800c78 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800cee:	8b 45 14             	mov    0x14(%ebp),%eax
  800cf1:	8b 10                	mov    (%eax),%edx
  800cf3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cf8:	8d 40 04             	lea    0x4(%eax),%eax
  800cfb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800cfe:	b8 10 00 00 00       	mov    $0x10,%eax
  800d03:	e9 70 ff ff ff       	jmp    800c78 <vprintfmt+0x3bb>
			putch(ch, putdat);
  800d08:	83 ec 08             	sub    $0x8,%esp
  800d0b:	53                   	push   %ebx
  800d0c:	6a 25                	push   $0x25
  800d0e:	ff d6                	call   *%esi
			break;
  800d10:	83 c4 10             	add    $0x10,%esp
  800d13:	e9 7a ff ff ff       	jmp    800c92 <vprintfmt+0x3d5>
			putch('%', putdat);
  800d18:	83 ec 08             	sub    $0x8,%esp
  800d1b:	53                   	push   %ebx
  800d1c:	6a 25                	push   $0x25
  800d1e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800d20:	83 c4 10             	add    $0x10,%esp
  800d23:	89 f8                	mov    %edi,%eax
  800d25:	eb 03                	jmp    800d2a <vprintfmt+0x46d>
  800d27:	83 e8 01             	sub    $0x1,%eax
  800d2a:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800d2e:	75 f7                	jne    800d27 <vprintfmt+0x46a>
  800d30:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800d33:	e9 5a ff ff ff       	jmp    800c92 <vprintfmt+0x3d5>
}
  800d38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3b:	5b                   	pop    %ebx
  800d3c:	5e                   	pop    %esi
  800d3d:	5f                   	pop    %edi
  800d3e:	5d                   	pop    %ebp
  800d3f:	c3                   	ret    

00800d40 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	83 ec 18             	sub    $0x18,%esp
  800d46:	8b 45 08             	mov    0x8(%ebp),%eax
  800d49:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800d4c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800d4f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800d53:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800d56:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800d5d:	85 c0                	test   %eax,%eax
  800d5f:	74 26                	je     800d87 <vsnprintf+0x47>
  800d61:	85 d2                	test   %edx,%edx
  800d63:	7e 22                	jle    800d87 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800d65:	ff 75 14             	pushl  0x14(%ebp)
  800d68:	ff 75 10             	pushl  0x10(%ebp)
  800d6b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800d6e:	50                   	push   %eax
  800d6f:	68 83 08 80 00       	push   $0x800883
  800d74:	e8 44 fb ff ff       	call   8008bd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800d79:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d7c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800d7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d82:	83 c4 10             	add    $0x10,%esp
}
  800d85:	c9                   	leave  
  800d86:	c3                   	ret    
		return -E_INVAL;
  800d87:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800d8c:	eb f7                	jmp    800d85 <vsnprintf+0x45>

00800d8e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800d8e:	55                   	push   %ebp
  800d8f:	89 e5                	mov    %esp,%ebp
  800d91:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800d94:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800d97:	50                   	push   %eax
  800d98:	ff 75 10             	pushl  0x10(%ebp)
  800d9b:	ff 75 0c             	pushl  0xc(%ebp)
  800d9e:	ff 75 08             	pushl  0x8(%ebp)
  800da1:	e8 9a ff ff ff       	call   800d40 <vsnprintf>
	va_end(ap);

	return rc;
}
  800da6:	c9                   	leave  
  800da7:	c3                   	ret    

00800da8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800da8:	55                   	push   %ebp
  800da9:	89 e5                	mov    %esp,%ebp
  800dab:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800dae:	b8 00 00 00 00       	mov    $0x0,%eax
  800db3:	eb 03                	jmp    800db8 <strlen+0x10>
		n++;
  800db5:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800db8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800dbc:	75 f7                	jne    800db5 <strlen+0xd>
	return n;
}
  800dbe:	5d                   	pop    %ebp
  800dbf:	c3                   	ret    

00800dc0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dc6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800dc9:	b8 00 00 00 00       	mov    $0x0,%eax
  800dce:	eb 03                	jmp    800dd3 <strnlen+0x13>
		n++;
  800dd0:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800dd3:	39 d0                	cmp    %edx,%eax
  800dd5:	74 06                	je     800ddd <strnlen+0x1d>
  800dd7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800ddb:	75 f3                	jne    800dd0 <strnlen+0x10>
	return n;
}
  800ddd:	5d                   	pop    %ebp
  800dde:	c3                   	ret    

00800ddf <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800ddf:	55                   	push   %ebp
  800de0:	89 e5                	mov    %esp,%ebp
  800de2:	53                   	push   %ebx
  800de3:	8b 45 08             	mov    0x8(%ebp),%eax
  800de6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800de9:	89 c2                	mov    %eax,%edx
  800deb:	83 c1 01             	add    $0x1,%ecx
  800dee:	83 c2 01             	add    $0x1,%edx
  800df1:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800df5:	88 5a ff             	mov    %bl,-0x1(%edx)
  800df8:	84 db                	test   %bl,%bl
  800dfa:	75 ef                	jne    800deb <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800dfc:	5b                   	pop    %ebx
  800dfd:	5d                   	pop    %ebp
  800dfe:	c3                   	ret    

00800dff <strcat>:

char *
strcat(char *dst, const char *src)
{
  800dff:	55                   	push   %ebp
  800e00:	89 e5                	mov    %esp,%ebp
  800e02:	53                   	push   %ebx
  800e03:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800e06:	53                   	push   %ebx
  800e07:	e8 9c ff ff ff       	call   800da8 <strlen>
  800e0c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800e0f:	ff 75 0c             	pushl  0xc(%ebp)
  800e12:	01 d8                	add    %ebx,%eax
  800e14:	50                   	push   %eax
  800e15:	e8 c5 ff ff ff       	call   800ddf <strcpy>
	return dst;
}
  800e1a:	89 d8                	mov    %ebx,%eax
  800e1c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e1f:	c9                   	leave  
  800e20:	c3                   	ret    

00800e21 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800e21:	55                   	push   %ebp
  800e22:	89 e5                	mov    %esp,%ebp
  800e24:	56                   	push   %esi
  800e25:	53                   	push   %ebx
  800e26:	8b 75 08             	mov    0x8(%ebp),%esi
  800e29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2c:	89 f3                	mov    %esi,%ebx
  800e2e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800e31:	89 f2                	mov    %esi,%edx
  800e33:	eb 0f                	jmp    800e44 <strncpy+0x23>
		*dst++ = *src;
  800e35:	83 c2 01             	add    $0x1,%edx
  800e38:	0f b6 01             	movzbl (%ecx),%eax
  800e3b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800e3e:	80 39 01             	cmpb   $0x1,(%ecx)
  800e41:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800e44:	39 da                	cmp    %ebx,%edx
  800e46:	75 ed                	jne    800e35 <strncpy+0x14>
	}
	return ret;
}
  800e48:	89 f0                	mov    %esi,%eax
  800e4a:	5b                   	pop    %ebx
  800e4b:	5e                   	pop    %esi
  800e4c:	5d                   	pop    %ebp
  800e4d:	c3                   	ret    

00800e4e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800e4e:	55                   	push   %ebp
  800e4f:	89 e5                	mov    %esp,%ebp
  800e51:	56                   	push   %esi
  800e52:	53                   	push   %ebx
  800e53:	8b 75 08             	mov    0x8(%ebp),%esi
  800e56:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e59:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800e5c:	89 f0                	mov    %esi,%eax
  800e5e:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800e62:	85 c9                	test   %ecx,%ecx
  800e64:	75 0b                	jne    800e71 <strlcpy+0x23>
  800e66:	eb 17                	jmp    800e7f <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800e68:	83 c2 01             	add    $0x1,%edx
  800e6b:	83 c0 01             	add    $0x1,%eax
  800e6e:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800e71:	39 d8                	cmp    %ebx,%eax
  800e73:	74 07                	je     800e7c <strlcpy+0x2e>
  800e75:	0f b6 0a             	movzbl (%edx),%ecx
  800e78:	84 c9                	test   %cl,%cl
  800e7a:	75 ec                	jne    800e68 <strlcpy+0x1a>
		*dst = '\0';
  800e7c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800e7f:	29 f0                	sub    %esi,%eax
}
  800e81:	5b                   	pop    %ebx
  800e82:	5e                   	pop    %esi
  800e83:	5d                   	pop    %ebp
  800e84:	c3                   	ret    

00800e85 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e85:	55                   	push   %ebp
  800e86:	89 e5                	mov    %esp,%ebp
  800e88:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e8b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800e8e:	eb 06                	jmp    800e96 <strcmp+0x11>
		p++, q++;
  800e90:	83 c1 01             	add    $0x1,%ecx
  800e93:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800e96:	0f b6 01             	movzbl (%ecx),%eax
  800e99:	84 c0                	test   %al,%al
  800e9b:	74 04                	je     800ea1 <strcmp+0x1c>
  800e9d:	3a 02                	cmp    (%edx),%al
  800e9f:	74 ef                	je     800e90 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ea1:	0f b6 c0             	movzbl %al,%eax
  800ea4:	0f b6 12             	movzbl (%edx),%edx
  800ea7:	29 d0                	sub    %edx,%eax
}
  800ea9:	5d                   	pop    %ebp
  800eaa:	c3                   	ret    

00800eab <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800eab:	55                   	push   %ebp
  800eac:	89 e5                	mov    %esp,%ebp
  800eae:	53                   	push   %ebx
  800eaf:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eb5:	89 c3                	mov    %eax,%ebx
  800eb7:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800eba:	eb 06                	jmp    800ec2 <strncmp+0x17>
		n--, p++, q++;
  800ebc:	83 c0 01             	add    $0x1,%eax
  800ebf:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800ec2:	39 d8                	cmp    %ebx,%eax
  800ec4:	74 16                	je     800edc <strncmp+0x31>
  800ec6:	0f b6 08             	movzbl (%eax),%ecx
  800ec9:	84 c9                	test   %cl,%cl
  800ecb:	74 04                	je     800ed1 <strncmp+0x26>
  800ecd:	3a 0a                	cmp    (%edx),%cl
  800ecf:	74 eb                	je     800ebc <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ed1:	0f b6 00             	movzbl (%eax),%eax
  800ed4:	0f b6 12             	movzbl (%edx),%edx
  800ed7:	29 d0                	sub    %edx,%eax
}
  800ed9:	5b                   	pop    %ebx
  800eda:	5d                   	pop    %ebp
  800edb:	c3                   	ret    
		return 0;
  800edc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee1:	eb f6                	jmp    800ed9 <strncmp+0x2e>

00800ee3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ee3:	55                   	push   %ebp
  800ee4:	89 e5                	mov    %esp,%ebp
  800ee6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800eed:	0f b6 10             	movzbl (%eax),%edx
  800ef0:	84 d2                	test   %dl,%dl
  800ef2:	74 09                	je     800efd <strchr+0x1a>
		if (*s == c)
  800ef4:	38 ca                	cmp    %cl,%dl
  800ef6:	74 0a                	je     800f02 <strchr+0x1f>
	for (; *s; s++)
  800ef8:	83 c0 01             	add    $0x1,%eax
  800efb:	eb f0                	jmp    800eed <strchr+0xa>
			return (char *) s;
	return 0;
  800efd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f02:	5d                   	pop    %ebp
  800f03:	c3                   	ret    

00800f04 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800f04:	55                   	push   %ebp
  800f05:	89 e5                	mov    %esp,%ebp
  800f07:	8b 45 08             	mov    0x8(%ebp),%eax
  800f0a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800f0e:	eb 03                	jmp    800f13 <strfind+0xf>
  800f10:	83 c0 01             	add    $0x1,%eax
  800f13:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800f16:	38 ca                	cmp    %cl,%dl
  800f18:	74 04                	je     800f1e <strfind+0x1a>
  800f1a:	84 d2                	test   %dl,%dl
  800f1c:	75 f2                	jne    800f10 <strfind+0xc>
			break;
	return (char *) s;
}
  800f1e:	5d                   	pop    %ebp
  800f1f:	c3                   	ret    

00800f20 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800f20:	55                   	push   %ebp
  800f21:	89 e5                	mov    %esp,%ebp
  800f23:	57                   	push   %edi
  800f24:	56                   	push   %esi
  800f25:	53                   	push   %ebx
  800f26:	8b 7d 08             	mov    0x8(%ebp),%edi
  800f29:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800f2c:	85 c9                	test   %ecx,%ecx
  800f2e:	74 13                	je     800f43 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800f30:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f36:	75 05                	jne    800f3d <memset+0x1d>
  800f38:	f6 c1 03             	test   $0x3,%cl
  800f3b:	74 0d                	je     800f4a <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f40:	fc                   	cld    
  800f41:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800f43:	89 f8                	mov    %edi,%eax
  800f45:	5b                   	pop    %ebx
  800f46:	5e                   	pop    %esi
  800f47:	5f                   	pop    %edi
  800f48:	5d                   	pop    %ebp
  800f49:	c3                   	ret    
		c &= 0xFF;
  800f4a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800f4e:	89 d3                	mov    %edx,%ebx
  800f50:	c1 e3 08             	shl    $0x8,%ebx
  800f53:	89 d0                	mov    %edx,%eax
  800f55:	c1 e0 18             	shl    $0x18,%eax
  800f58:	89 d6                	mov    %edx,%esi
  800f5a:	c1 e6 10             	shl    $0x10,%esi
  800f5d:	09 f0                	or     %esi,%eax
  800f5f:	09 c2                	or     %eax,%edx
  800f61:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800f63:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800f66:	89 d0                	mov    %edx,%eax
  800f68:	fc                   	cld    
  800f69:	f3 ab                	rep stos %eax,%es:(%edi)
  800f6b:	eb d6                	jmp    800f43 <memset+0x23>

00800f6d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800f6d:	55                   	push   %ebp
  800f6e:	89 e5                	mov    %esp,%ebp
  800f70:	57                   	push   %edi
  800f71:	56                   	push   %esi
  800f72:	8b 45 08             	mov    0x8(%ebp),%eax
  800f75:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f78:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f7b:	39 c6                	cmp    %eax,%esi
  800f7d:	73 35                	jae    800fb4 <memmove+0x47>
  800f7f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f82:	39 c2                	cmp    %eax,%edx
  800f84:	76 2e                	jbe    800fb4 <memmove+0x47>
		s += n;
		d += n;
  800f86:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f89:	89 d6                	mov    %edx,%esi
  800f8b:	09 fe                	or     %edi,%esi
  800f8d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f93:	74 0c                	je     800fa1 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f95:	83 ef 01             	sub    $0x1,%edi
  800f98:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800f9b:	fd                   	std    
  800f9c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f9e:	fc                   	cld    
  800f9f:	eb 21                	jmp    800fc2 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fa1:	f6 c1 03             	test   $0x3,%cl
  800fa4:	75 ef                	jne    800f95 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800fa6:	83 ef 04             	sub    $0x4,%edi
  800fa9:	8d 72 fc             	lea    -0x4(%edx),%esi
  800fac:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800faf:	fd                   	std    
  800fb0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fb2:	eb ea                	jmp    800f9e <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fb4:	89 f2                	mov    %esi,%edx
  800fb6:	09 c2                	or     %eax,%edx
  800fb8:	f6 c2 03             	test   $0x3,%dl
  800fbb:	74 09                	je     800fc6 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800fbd:	89 c7                	mov    %eax,%edi
  800fbf:	fc                   	cld    
  800fc0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800fc2:	5e                   	pop    %esi
  800fc3:	5f                   	pop    %edi
  800fc4:	5d                   	pop    %ebp
  800fc5:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fc6:	f6 c1 03             	test   $0x3,%cl
  800fc9:	75 f2                	jne    800fbd <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800fcb:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800fce:	89 c7                	mov    %eax,%edi
  800fd0:	fc                   	cld    
  800fd1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800fd3:	eb ed                	jmp    800fc2 <memmove+0x55>

00800fd5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800fd5:	55                   	push   %ebp
  800fd6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800fd8:	ff 75 10             	pushl  0x10(%ebp)
  800fdb:	ff 75 0c             	pushl  0xc(%ebp)
  800fde:	ff 75 08             	pushl  0x8(%ebp)
  800fe1:	e8 87 ff ff ff       	call   800f6d <memmove>
}
  800fe6:	c9                   	leave  
  800fe7:	c3                   	ret    

00800fe8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800fe8:	55                   	push   %ebp
  800fe9:	89 e5                	mov    %esp,%ebp
  800feb:	56                   	push   %esi
  800fec:	53                   	push   %ebx
  800fed:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ff3:	89 c6                	mov    %eax,%esi
  800ff5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ff8:	39 f0                	cmp    %esi,%eax
  800ffa:	74 1c                	je     801018 <memcmp+0x30>
		if (*s1 != *s2)
  800ffc:	0f b6 08             	movzbl (%eax),%ecx
  800fff:	0f b6 1a             	movzbl (%edx),%ebx
  801002:	38 d9                	cmp    %bl,%cl
  801004:	75 08                	jne    80100e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801006:	83 c0 01             	add    $0x1,%eax
  801009:	83 c2 01             	add    $0x1,%edx
  80100c:	eb ea                	jmp    800ff8 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  80100e:	0f b6 c1             	movzbl %cl,%eax
  801011:	0f b6 db             	movzbl %bl,%ebx
  801014:	29 d8                	sub    %ebx,%eax
  801016:	eb 05                	jmp    80101d <memcmp+0x35>
	}

	return 0;
  801018:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80101d:	5b                   	pop    %ebx
  80101e:	5e                   	pop    %esi
  80101f:	5d                   	pop    %ebp
  801020:	c3                   	ret    

00801021 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801021:	55                   	push   %ebp
  801022:	89 e5                	mov    %esp,%ebp
  801024:	8b 45 08             	mov    0x8(%ebp),%eax
  801027:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80102a:	89 c2                	mov    %eax,%edx
  80102c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80102f:	39 d0                	cmp    %edx,%eax
  801031:	73 09                	jae    80103c <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  801033:	38 08                	cmp    %cl,(%eax)
  801035:	74 05                	je     80103c <memfind+0x1b>
	for (; s < ends; s++)
  801037:	83 c0 01             	add    $0x1,%eax
  80103a:	eb f3                	jmp    80102f <memfind+0xe>
			break;
	return (void *) s;
}
  80103c:	5d                   	pop    %ebp
  80103d:	c3                   	ret    

0080103e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80103e:	55                   	push   %ebp
  80103f:	89 e5                	mov    %esp,%ebp
  801041:	57                   	push   %edi
  801042:	56                   	push   %esi
  801043:	53                   	push   %ebx
  801044:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801047:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80104a:	eb 03                	jmp    80104f <strtol+0x11>
		s++;
  80104c:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  80104f:	0f b6 01             	movzbl (%ecx),%eax
  801052:	3c 20                	cmp    $0x20,%al
  801054:	74 f6                	je     80104c <strtol+0xe>
  801056:	3c 09                	cmp    $0x9,%al
  801058:	74 f2                	je     80104c <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  80105a:	3c 2b                	cmp    $0x2b,%al
  80105c:	74 2e                	je     80108c <strtol+0x4e>
	int neg = 0;
  80105e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801063:	3c 2d                	cmp    $0x2d,%al
  801065:	74 2f                	je     801096 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801067:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80106d:	75 05                	jne    801074 <strtol+0x36>
  80106f:	80 39 30             	cmpb   $0x30,(%ecx)
  801072:	74 2c                	je     8010a0 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801074:	85 db                	test   %ebx,%ebx
  801076:	75 0a                	jne    801082 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801078:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  80107d:	80 39 30             	cmpb   $0x30,(%ecx)
  801080:	74 28                	je     8010aa <strtol+0x6c>
		base = 10;
  801082:	b8 00 00 00 00       	mov    $0x0,%eax
  801087:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80108a:	eb 50                	jmp    8010dc <strtol+0x9e>
		s++;
  80108c:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  80108f:	bf 00 00 00 00       	mov    $0x0,%edi
  801094:	eb d1                	jmp    801067 <strtol+0x29>
		s++, neg = 1;
  801096:	83 c1 01             	add    $0x1,%ecx
  801099:	bf 01 00 00 00       	mov    $0x1,%edi
  80109e:	eb c7                	jmp    801067 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010a0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8010a4:	74 0e                	je     8010b4 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8010a6:	85 db                	test   %ebx,%ebx
  8010a8:	75 d8                	jne    801082 <strtol+0x44>
		s++, base = 8;
  8010aa:	83 c1 01             	add    $0x1,%ecx
  8010ad:	bb 08 00 00 00       	mov    $0x8,%ebx
  8010b2:	eb ce                	jmp    801082 <strtol+0x44>
		s += 2, base = 16;
  8010b4:	83 c1 02             	add    $0x2,%ecx
  8010b7:	bb 10 00 00 00       	mov    $0x10,%ebx
  8010bc:	eb c4                	jmp    801082 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  8010be:	8d 72 9f             	lea    -0x61(%edx),%esi
  8010c1:	89 f3                	mov    %esi,%ebx
  8010c3:	80 fb 19             	cmp    $0x19,%bl
  8010c6:	77 29                	ja     8010f1 <strtol+0xb3>
			dig = *s - 'a' + 10;
  8010c8:	0f be d2             	movsbl %dl,%edx
  8010cb:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8010ce:	3b 55 10             	cmp    0x10(%ebp),%edx
  8010d1:	7d 30                	jge    801103 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  8010d3:	83 c1 01             	add    $0x1,%ecx
  8010d6:	0f af 45 10          	imul   0x10(%ebp),%eax
  8010da:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  8010dc:	0f b6 11             	movzbl (%ecx),%edx
  8010df:	8d 72 d0             	lea    -0x30(%edx),%esi
  8010e2:	89 f3                	mov    %esi,%ebx
  8010e4:	80 fb 09             	cmp    $0x9,%bl
  8010e7:	77 d5                	ja     8010be <strtol+0x80>
			dig = *s - '0';
  8010e9:	0f be d2             	movsbl %dl,%edx
  8010ec:	83 ea 30             	sub    $0x30,%edx
  8010ef:	eb dd                	jmp    8010ce <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  8010f1:	8d 72 bf             	lea    -0x41(%edx),%esi
  8010f4:	89 f3                	mov    %esi,%ebx
  8010f6:	80 fb 19             	cmp    $0x19,%bl
  8010f9:	77 08                	ja     801103 <strtol+0xc5>
			dig = *s - 'A' + 10;
  8010fb:	0f be d2             	movsbl %dl,%edx
  8010fe:	83 ea 37             	sub    $0x37,%edx
  801101:	eb cb                	jmp    8010ce <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  801103:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801107:	74 05                	je     80110e <strtol+0xd0>
		*endptr = (char *) s;
  801109:	8b 75 0c             	mov    0xc(%ebp),%esi
  80110c:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  80110e:	89 c2                	mov    %eax,%edx
  801110:	f7 da                	neg    %edx
  801112:	85 ff                	test   %edi,%edi
  801114:	0f 45 c2             	cmovne %edx,%eax
}
  801117:	5b                   	pop    %ebx
  801118:	5e                   	pop    %esi
  801119:	5f                   	pop    %edi
  80111a:	5d                   	pop    %ebp
  80111b:	c3                   	ret    

0080111c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80111c:	55                   	push   %ebp
  80111d:	89 e5                	mov    %esp,%ebp
  80111f:	57                   	push   %edi
  801120:	56                   	push   %esi
  801121:	53                   	push   %ebx
	asm volatile("int %1\n"
  801122:	b8 00 00 00 00       	mov    $0x0,%eax
  801127:	8b 55 08             	mov    0x8(%ebp),%edx
  80112a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80112d:	89 c3                	mov    %eax,%ebx
  80112f:	89 c7                	mov    %eax,%edi
  801131:	89 c6                	mov    %eax,%esi
  801133:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801135:	5b                   	pop    %ebx
  801136:	5e                   	pop    %esi
  801137:	5f                   	pop    %edi
  801138:	5d                   	pop    %ebp
  801139:	c3                   	ret    

0080113a <sys_cgetc>:

int
sys_cgetc(void)
{
  80113a:	55                   	push   %ebp
  80113b:	89 e5                	mov    %esp,%ebp
  80113d:	57                   	push   %edi
  80113e:	56                   	push   %esi
  80113f:	53                   	push   %ebx
	asm volatile("int %1\n"
  801140:	ba 00 00 00 00       	mov    $0x0,%edx
  801145:	b8 01 00 00 00       	mov    $0x1,%eax
  80114a:	89 d1                	mov    %edx,%ecx
  80114c:	89 d3                	mov    %edx,%ebx
  80114e:	89 d7                	mov    %edx,%edi
  801150:	89 d6                	mov    %edx,%esi
  801152:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801154:	5b                   	pop    %ebx
  801155:	5e                   	pop    %esi
  801156:	5f                   	pop    %edi
  801157:	5d                   	pop    %ebp
  801158:	c3                   	ret    

00801159 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801159:	55                   	push   %ebp
  80115a:	89 e5                	mov    %esp,%ebp
  80115c:	57                   	push   %edi
  80115d:	56                   	push   %esi
  80115e:	53                   	push   %ebx
  80115f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801162:	b9 00 00 00 00       	mov    $0x0,%ecx
  801167:	8b 55 08             	mov    0x8(%ebp),%edx
  80116a:	b8 03 00 00 00       	mov    $0x3,%eax
  80116f:	89 cb                	mov    %ecx,%ebx
  801171:	89 cf                	mov    %ecx,%edi
  801173:	89 ce                	mov    %ecx,%esi
  801175:	cd 30                	int    $0x30
	if(check && ret > 0)
  801177:	85 c0                	test   %eax,%eax
  801179:	7f 08                	jg     801183 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80117b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80117e:	5b                   	pop    %ebx
  80117f:	5e                   	pop    %esi
  801180:	5f                   	pop    %edi
  801181:	5d                   	pop    %ebp
  801182:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801183:	83 ec 0c             	sub    $0xc,%esp
  801186:	50                   	push   %eax
  801187:	6a 03                	push   $0x3
  801189:	68 ff 2a 80 00       	push   $0x802aff
  80118e:	6a 23                	push   $0x23
  801190:	68 1c 2b 80 00       	push   $0x802b1c
  801195:	e8 4b f5 ff ff       	call   8006e5 <_panic>

0080119a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80119a:	55                   	push   %ebp
  80119b:	89 e5                	mov    %esp,%ebp
  80119d:	57                   	push   %edi
  80119e:	56                   	push   %esi
  80119f:	53                   	push   %ebx
	asm volatile("int %1\n"
  8011a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8011a5:	b8 02 00 00 00       	mov    $0x2,%eax
  8011aa:	89 d1                	mov    %edx,%ecx
  8011ac:	89 d3                	mov    %edx,%ebx
  8011ae:	89 d7                	mov    %edx,%edi
  8011b0:	89 d6                	mov    %edx,%esi
  8011b2:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8011b4:	5b                   	pop    %ebx
  8011b5:	5e                   	pop    %esi
  8011b6:	5f                   	pop    %edi
  8011b7:	5d                   	pop    %ebp
  8011b8:	c3                   	ret    

008011b9 <sys_yield>:

void
sys_yield(void)
{
  8011b9:	55                   	push   %ebp
  8011ba:	89 e5                	mov    %esp,%ebp
  8011bc:	57                   	push   %edi
  8011bd:	56                   	push   %esi
  8011be:	53                   	push   %ebx
	asm volatile("int %1\n"
  8011bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8011c4:	b8 0b 00 00 00       	mov    $0xb,%eax
  8011c9:	89 d1                	mov    %edx,%ecx
  8011cb:	89 d3                	mov    %edx,%ebx
  8011cd:	89 d7                	mov    %edx,%edi
  8011cf:	89 d6                	mov    %edx,%esi
  8011d1:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8011d3:	5b                   	pop    %ebx
  8011d4:	5e                   	pop    %esi
  8011d5:	5f                   	pop    %edi
  8011d6:	5d                   	pop    %ebp
  8011d7:	c3                   	ret    

008011d8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8011d8:	55                   	push   %ebp
  8011d9:	89 e5                	mov    %esp,%ebp
  8011db:	57                   	push   %edi
  8011dc:	56                   	push   %esi
  8011dd:	53                   	push   %ebx
  8011de:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8011e1:	be 00 00 00 00       	mov    $0x0,%esi
  8011e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8011e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ec:	b8 04 00 00 00       	mov    $0x4,%eax
  8011f1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011f4:	89 f7                	mov    %esi,%edi
  8011f6:	cd 30                	int    $0x30
	if(check && ret > 0)
  8011f8:	85 c0                	test   %eax,%eax
  8011fa:	7f 08                	jg     801204 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8011fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ff:	5b                   	pop    %ebx
  801200:	5e                   	pop    %esi
  801201:	5f                   	pop    %edi
  801202:	5d                   	pop    %ebp
  801203:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801204:	83 ec 0c             	sub    $0xc,%esp
  801207:	50                   	push   %eax
  801208:	6a 04                	push   $0x4
  80120a:	68 ff 2a 80 00       	push   $0x802aff
  80120f:	6a 23                	push   $0x23
  801211:	68 1c 2b 80 00       	push   $0x802b1c
  801216:	e8 ca f4 ff ff       	call   8006e5 <_panic>

0080121b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80121b:	55                   	push   %ebp
  80121c:	89 e5                	mov    %esp,%ebp
  80121e:	57                   	push   %edi
  80121f:	56                   	push   %esi
  801220:	53                   	push   %ebx
  801221:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801224:	8b 55 08             	mov    0x8(%ebp),%edx
  801227:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80122a:	b8 05 00 00 00       	mov    $0x5,%eax
  80122f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801232:	8b 7d 14             	mov    0x14(%ebp),%edi
  801235:	8b 75 18             	mov    0x18(%ebp),%esi
  801238:	cd 30                	int    $0x30
	if(check && ret > 0)
  80123a:	85 c0                	test   %eax,%eax
  80123c:	7f 08                	jg     801246 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80123e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801241:	5b                   	pop    %ebx
  801242:	5e                   	pop    %esi
  801243:	5f                   	pop    %edi
  801244:	5d                   	pop    %ebp
  801245:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801246:	83 ec 0c             	sub    $0xc,%esp
  801249:	50                   	push   %eax
  80124a:	6a 05                	push   $0x5
  80124c:	68 ff 2a 80 00       	push   $0x802aff
  801251:	6a 23                	push   $0x23
  801253:	68 1c 2b 80 00       	push   $0x802b1c
  801258:	e8 88 f4 ff ff       	call   8006e5 <_panic>

0080125d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80125d:	55                   	push   %ebp
  80125e:	89 e5                	mov    %esp,%ebp
  801260:	57                   	push   %edi
  801261:	56                   	push   %esi
  801262:	53                   	push   %ebx
  801263:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801266:	bb 00 00 00 00       	mov    $0x0,%ebx
  80126b:	8b 55 08             	mov    0x8(%ebp),%edx
  80126e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801271:	b8 06 00 00 00       	mov    $0x6,%eax
  801276:	89 df                	mov    %ebx,%edi
  801278:	89 de                	mov    %ebx,%esi
  80127a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80127c:	85 c0                	test   %eax,%eax
  80127e:	7f 08                	jg     801288 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801280:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801283:	5b                   	pop    %ebx
  801284:	5e                   	pop    %esi
  801285:	5f                   	pop    %edi
  801286:	5d                   	pop    %ebp
  801287:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801288:	83 ec 0c             	sub    $0xc,%esp
  80128b:	50                   	push   %eax
  80128c:	6a 06                	push   $0x6
  80128e:	68 ff 2a 80 00       	push   $0x802aff
  801293:	6a 23                	push   $0x23
  801295:	68 1c 2b 80 00       	push   $0x802b1c
  80129a:	e8 46 f4 ff ff       	call   8006e5 <_panic>

0080129f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80129f:	55                   	push   %ebp
  8012a0:	89 e5                	mov    %esp,%ebp
  8012a2:	57                   	push   %edi
  8012a3:	56                   	push   %esi
  8012a4:	53                   	push   %ebx
  8012a5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8012a8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8012b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012b3:	b8 08 00 00 00       	mov    $0x8,%eax
  8012b8:	89 df                	mov    %ebx,%edi
  8012ba:	89 de                	mov    %ebx,%esi
  8012bc:	cd 30                	int    $0x30
	if(check && ret > 0)
  8012be:	85 c0                	test   %eax,%eax
  8012c0:	7f 08                	jg     8012ca <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8012c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012c5:	5b                   	pop    %ebx
  8012c6:	5e                   	pop    %esi
  8012c7:	5f                   	pop    %edi
  8012c8:	5d                   	pop    %ebp
  8012c9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8012ca:	83 ec 0c             	sub    $0xc,%esp
  8012cd:	50                   	push   %eax
  8012ce:	6a 08                	push   $0x8
  8012d0:	68 ff 2a 80 00       	push   $0x802aff
  8012d5:	6a 23                	push   $0x23
  8012d7:	68 1c 2b 80 00       	push   $0x802b1c
  8012dc:	e8 04 f4 ff ff       	call   8006e5 <_panic>

008012e1 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8012e1:	55                   	push   %ebp
  8012e2:	89 e5                	mov    %esp,%ebp
  8012e4:	57                   	push   %edi
  8012e5:	56                   	push   %esi
  8012e6:	53                   	push   %ebx
  8012e7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8012ea:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8012f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012f5:	b8 09 00 00 00       	mov    $0x9,%eax
  8012fa:	89 df                	mov    %ebx,%edi
  8012fc:	89 de                	mov    %ebx,%esi
  8012fe:	cd 30                	int    $0x30
	if(check && ret > 0)
  801300:	85 c0                	test   %eax,%eax
  801302:	7f 08                	jg     80130c <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801304:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801307:	5b                   	pop    %ebx
  801308:	5e                   	pop    %esi
  801309:	5f                   	pop    %edi
  80130a:	5d                   	pop    %ebp
  80130b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80130c:	83 ec 0c             	sub    $0xc,%esp
  80130f:	50                   	push   %eax
  801310:	6a 09                	push   $0x9
  801312:	68 ff 2a 80 00       	push   $0x802aff
  801317:	6a 23                	push   $0x23
  801319:	68 1c 2b 80 00       	push   $0x802b1c
  80131e:	e8 c2 f3 ff ff       	call   8006e5 <_panic>

00801323 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801323:	55                   	push   %ebp
  801324:	89 e5                	mov    %esp,%ebp
  801326:	57                   	push   %edi
  801327:	56                   	push   %esi
  801328:	53                   	push   %ebx
  801329:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80132c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801331:	8b 55 08             	mov    0x8(%ebp),%edx
  801334:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801337:	b8 0a 00 00 00       	mov    $0xa,%eax
  80133c:	89 df                	mov    %ebx,%edi
  80133e:	89 de                	mov    %ebx,%esi
  801340:	cd 30                	int    $0x30
	if(check && ret > 0)
  801342:	85 c0                	test   %eax,%eax
  801344:	7f 08                	jg     80134e <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801346:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801349:	5b                   	pop    %ebx
  80134a:	5e                   	pop    %esi
  80134b:	5f                   	pop    %edi
  80134c:	5d                   	pop    %ebp
  80134d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80134e:	83 ec 0c             	sub    $0xc,%esp
  801351:	50                   	push   %eax
  801352:	6a 0a                	push   $0xa
  801354:	68 ff 2a 80 00       	push   $0x802aff
  801359:	6a 23                	push   $0x23
  80135b:	68 1c 2b 80 00       	push   $0x802b1c
  801360:	e8 80 f3 ff ff       	call   8006e5 <_panic>

00801365 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801365:	55                   	push   %ebp
  801366:	89 e5                	mov    %esp,%ebp
  801368:	57                   	push   %edi
  801369:	56                   	push   %esi
  80136a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80136b:	8b 55 08             	mov    0x8(%ebp),%edx
  80136e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801371:	b8 0c 00 00 00       	mov    $0xc,%eax
  801376:	be 00 00 00 00       	mov    $0x0,%esi
  80137b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80137e:	8b 7d 14             	mov    0x14(%ebp),%edi
  801381:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801383:	5b                   	pop    %ebx
  801384:	5e                   	pop    %esi
  801385:	5f                   	pop    %edi
  801386:	5d                   	pop    %ebp
  801387:	c3                   	ret    

00801388 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801388:	55                   	push   %ebp
  801389:	89 e5                	mov    %esp,%ebp
  80138b:	57                   	push   %edi
  80138c:	56                   	push   %esi
  80138d:	53                   	push   %ebx
  80138e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801391:	b9 00 00 00 00       	mov    $0x0,%ecx
  801396:	8b 55 08             	mov    0x8(%ebp),%edx
  801399:	b8 0d 00 00 00       	mov    $0xd,%eax
  80139e:	89 cb                	mov    %ecx,%ebx
  8013a0:	89 cf                	mov    %ecx,%edi
  8013a2:	89 ce                	mov    %ecx,%esi
  8013a4:	cd 30                	int    $0x30
	if(check && ret > 0)
  8013a6:	85 c0                	test   %eax,%eax
  8013a8:	7f 08                	jg     8013b2 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8013aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013ad:	5b                   	pop    %ebx
  8013ae:	5e                   	pop    %esi
  8013af:	5f                   	pop    %edi
  8013b0:	5d                   	pop    %ebp
  8013b1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8013b2:	83 ec 0c             	sub    $0xc,%esp
  8013b5:	50                   	push   %eax
  8013b6:	6a 0d                	push   $0xd
  8013b8:	68 ff 2a 80 00       	push   $0x802aff
  8013bd:	6a 23                	push   $0x23
  8013bf:	68 1c 2b 80 00       	push   $0x802b1c
  8013c4:	e8 1c f3 ff ff       	call   8006e5 <_panic>

008013c9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8013c9:	55                   	push   %ebp
  8013ca:	89 e5                	mov    %esp,%ebp
  8013cc:	56                   	push   %esi
  8013cd:	53                   	push   %ebx
  8013ce:	8b 75 08             	mov    0x8(%ebp),%esi
  8013d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013d4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (from_env_store) *from_env_store = 0;
  8013d7:	85 f6                	test   %esi,%esi
  8013d9:	74 06                	je     8013e1 <ipc_recv+0x18>
  8013db:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  8013e1:	85 db                	test   %ebx,%ebx
  8013e3:	74 06                	je     8013eb <ipc_recv+0x22>
  8013e5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  8013eb:	85 c0                	test   %eax,%eax
  8013ed:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  8013f2:	0f 44 c2             	cmove  %edx,%eax
	int ret = sys_ipc_recv(pg);
  8013f5:	83 ec 0c             	sub    $0xc,%esp
  8013f8:	50                   	push   %eax
  8013f9:	e8 8a ff ff ff       	call   801388 <sys_ipc_recv>
	if (ret) return ret;
  8013fe:	83 c4 10             	add    $0x10,%esp
  801401:	85 c0                	test   %eax,%eax
  801403:	75 24                	jne    801429 <ipc_recv+0x60>
	if (from_env_store)
  801405:	85 f6                	test   %esi,%esi
  801407:	74 0a                	je     801413 <ipc_recv+0x4a>
		*from_env_store = thisenv->env_ipc_from;
  801409:	a1 04 40 80 00       	mov    0x804004,%eax
  80140e:	8b 40 74             	mov    0x74(%eax),%eax
  801411:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801413:	85 db                	test   %ebx,%ebx
  801415:	74 0a                	je     801421 <ipc_recv+0x58>
		*perm_store = thisenv->env_ipc_perm;
  801417:	a1 04 40 80 00       	mov    0x804004,%eax
  80141c:	8b 40 78             	mov    0x78(%eax),%eax
  80141f:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801421:	a1 04 40 80 00       	mov    0x804004,%eax
  801426:	8b 40 70             	mov    0x70(%eax),%eax
}
  801429:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80142c:	5b                   	pop    %ebx
  80142d:	5e                   	pop    %esi
  80142e:	5d                   	pop    %ebp
  80142f:	c3                   	ret    

00801430 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801430:	55                   	push   %ebp
  801431:	89 e5                	mov    %esp,%ebp
  801433:	57                   	push   %edi
  801434:	56                   	push   %esi
  801435:	53                   	push   %ebx
  801436:	83 ec 0c             	sub    $0xc,%esp
  801439:	8b 7d 08             	mov    0x8(%ebp),%edi
  80143c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80143f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (!pg) pg = (void*)-1;
  801442:	85 db                	test   %ebx,%ebx
  801444:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801449:	0f 44 d8             	cmove  %eax,%ebx
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  80144c:	ff 75 14             	pushl  0x14(%ebp)
  80144f:	53                   	push   %ebx
  801450:	56                   	push   %esi
  801451:	57                   	push   %edi
  801452:	e8 0e ff ff ff       	call   801365 <sys_ipc_try_send>
  801457:	83 c4 10             	add    $0x10,%esp
  80145a:	85 c0                	test   %eax,%eax
  80145c:	74 1e                	je     80147c <ipc_send+0x4c>
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  80145e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801461:	75 07                	jne    80146a <ipc_send+0x3a>
		sys_yield();
  801463:	e8 51 fd ff ff       	call   8011b9 <sys_yield>
  801468:	eb e2                	jmp    80144c <ipc_send+0x1c>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %e", ret);
  80146a:	50                   	push   %eax
  80146b:	68 2a 2b 80 00       	push   $0x802b2a
  801470:	6a 36                	push   $0x36
  801472:	68 41 2b 80 00       	push   $0x802b41
  801477:	e8 69 f2 ff ff       	call   8006e5 <_panic>
	}
}
  80147c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80147f:	5b                   	pop    %ebx
  801480:	5e                   	pop    %esi
  801481:	5f                   	pop    %edi
  801482:	5d                   	pop    %ebp
  801483:	c3                   	ret    

00801484 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801484:	55                   	push   %ebp
  801485:	89 e5                	mov    %esp,%ebp
  801487:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80148a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80148f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801492:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801498:	8b 52 50             	mov    0x50(%edx),%edx
  80149b:	39 ca                	cmp    %ecx,%edx
  80149d:	74 11                	je     8014b0 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  80149f:	83 c0 01             	add    $0x1,%eax
  8014a2:	3d 00 04 00 00       	cmp    $0x400,%eax
  8014a7:	75 e6                	jne    80148f <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8014a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8014ae:	eb 0b                	jmp    8014bb <ipc_find_env+0x37>
			return envs[i].env_id;
  8014b0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8014b3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8014b8:	8b 40 48             	mov    0x48(%eax),%eax
}
  8014bb:	5d                   	pop    %ebp
  8014bc:	c3                   	ret    

008014bd <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8014bd:	55                   	push   %ebp
  8014be:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c3:	05 00 00 00 30       	add    $0x30000000,%eax
  8014c8:	c1 e8 0c             	shr    $0xc,%eax
}
  8014cb:	5d                   	pop    %ebp
  8014cc:	c3                   	ret    

008014cd <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8014cd:	55                   	push   %ebp
  8014ce:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d3:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8014d8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8014dd:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8014e2:	5d                   	pop    %ebp
  8014e3:	c3                   	ret    

008014e4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8014e4:	55                   	push   %ebp
  8014e5:	89 e5                	mov    %esp,%ebp
  8014e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014ea:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8014ef:	89 c2                	mov    %eax,%edx
  8014f1:	c1 ea 16             	shr    $0x16,%edx
  8014f4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014fb:	f6 c2 01             	test   $0x1,%dl
  8014fe:	74 2a                	je     80152a <fd_alloc+0x46>
  801500:	89 c2                	mov    %eax,%edx
  801502:	c1 ea 0c             	shr    $0xc,%edx
  801505:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80150c:	f6 c2 01             	test   $0x1,%dl
  80150f:	74 19                	je     80152a <fd_alloc+0x46>
  801511:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801516:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80151b:	75 d2                	jne    8014ef <fd_alloc+0xb>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80151d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801523:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801528:	eb 07                	jmp    801531 <fd_alloc+0x4d>
			*fd_store = fd;
  80152a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80152c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801531:	5d                   	pop    %ebp
  801532:	c3                   	ret    

00801533 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801533:	55                   	push   %ebp
  801534:	89 e5                	mov    %esp,%ebp
  801536:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801539:	83 f8 1f             	cmp    $0x1f,%eax
  80153c:	77 36                	ja     801574 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80153e:	c1 e0 0c             	shl    $0xc,%eax
  801541:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801546:	89 c2                	mov    %eax,%edx
  801548:	c1 ea 16             	shr    $0x16,%edx
  80154b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801552:	f6 c2 01             	test   $0x1,%dl
  801555:	74 24                	je     80157b <fd_lookup+0x48>
  801557:	89 c2                	mov    %eax,%edx
  801559:	c1 ea 0c             	shr    $0xc,%edx
  80155c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801563:	f6 c2 01             	test   $0x1,%dl
  801566:	74 1a                	je     801582 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801568:	8b 55 0c             	mov    0xc(%ebp),%edx
  80156b:	89 02                	mov    %eax,(%edx)
	return 0;
  80156d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801572:	5d                   	pop    %ebp
  801573:	c3                   	ret    
		return -E_INVAL;
  801574:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801579:	eb f7                	jmp    801572 <fd_lookup+0x3f>
		return -E_INVAL;
  80157b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801580:	eb f0                	jmp    801572 <fd_lookup+0x3f>
  801582:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801587:	eb e9                	jmp    801572 <fd_lookup+0x3f>

00801589 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801589:	55                   	push   %ebp
  80158a:	89 e5                	mov    %esp,%ebp
  80158c:	83 ec 08             	sub    $0x8,%esp
  80158f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801592:	ba cc 2b 80 00       	mov    $0x802bcc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801597:	b8 08 30 80 00       	mov    $0x803008,%eax
		if (devtab[i]->dev_id == dev_id) {
  80159c:	39 08                	cmp    %ecx,(%eax)
  80159e:	74 33                	je     8015d3 <dev_lookup+0x4a>
  8015a0:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  8015a3:	8b 02                	mov    (%edx),%eax
  8015a5:	85 c0                	test   %eax,%eax
  8015a7:	75 f3                	jne    80159c <dev_lookup+0x13>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8015a9:	a1 04 40 80 00       	mov    0x804004,%eax
  8015ae:	8b 40 48             	mov    0x48(%eax),%eax
  8015b1:	83 ec 04             	sub    $0x4,%esp
  8015b4:	51                   	push   %ecx
  8015b5:	50                   	push   %eax
  8015b6:	68 4c 2b 80 00       	push   $0x802b4c
  8015bb:	e8 00 f2 ff ff       	call   8007c0 <cprintf>
	*dev = 0;
  8015c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015c3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8015c9:	83 c4 10             	add    $0x10,%esp
  8015cc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8015d1:	c9                   	leave  
  8015d2:	c3                   	ret    
			*dev = devtab[i];
  8015d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015d6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8015d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8015dd:	eb f2                	jmp    8015d1 <dev_lookup+0x48>

008015df <fd_close>:
{
  8015df:	55                   	push   %ebp
  8015e0:	89 e5                	mov    %esp,%ebp
  8015e2:	57                   	push   %edi
  8015e3:	56                   	push   %esi
  8015e4:	53                   	push   %ebx
  8015e5:	83 ec 1c             	sub    $0x1c,%esp
  8015e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8015eb:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015ee:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015f1:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8015f2:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8015f8:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015fb:	50                   	push   %eax
  8015fc:	e8 32 ff ff ff       	call   801533 <fd_lookup>
  801601:	89 c3                	mov    %eax,%ebx
  801603:	83 c4 08             	add    $0x8,%esp
  801606:	85 c0                	test   %eax,%eax
  801608:	78 05                	js     80160f <fd_close+0x30>
	    || fd != fd2)
  80160a:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80160d:	74 16                	je     801625 <fd_close+0x46>
		return (must_exist ? r : 0);
  80160f:	89 f8                	mov    %edi,%eax
  801611:	84 c0                	test   %al,%al
  801613:	b8 00 00 00 00       	mov    $0x0,%eax
  801618:	0f 44 d8             	cmove  %eax,%ebx
}
  80161b:	89 d8                	mov    %ebx,%eax
  80161d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801620:	5b                   	pop    %ebx
  801621:	5e                   	pop    %esi
  801622:	5f                   	pop    %edi
  801623:	5d                   	pop    %ebp
  801624:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801625:	83 ec 08             	sub    $0x8,%esp
  801628:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80162b:	50                   	push   %eax
  80162c:	ff 36                	pushl  (%esi)
  80162e:	e8 56 ff ff ff       	call   801589 <dev_lookup>
  801633:	89 c3                	mov    %eax,%ebx
  801635:	83 c4 10             	add    $0x10,%esp
  801638:	85 c0                	test   %eax,%eax
  80163a:	78 15                	js     801651 <fd_close+0x72>
		if (dev->dev_close)
  80163c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80163f:	8b 40 10             	mov    0x10(%eax),%eax
  801642:	85 c0                	test   %eax,%eax
  801644:	74 1b                	je     801661 <fd_close+0x82>
			r = (*dev->dev_close)(fd);
  801646:	83 ec 0c             	sub    $0xc,%esp
  801649:	56                   	push   %esi
  80164a:	ff d0                	call   *%eax
  80164c:	89 c3                	mov    %eax,%ebx
  80164e:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801651:	83 ec 08             	sub    $0x8,%esp
  801654:	56                   	push   %esi
  801655:	6a 00                	push   $0x0
  801657:	e8 01 fc ff ff       	call   80125d <sys_page_unmap>
	return r;
  80165c:	83 c4 10             	add    $0x10,%esp
  80165f:	eb ba                	jmp    80161b <fd_close+0x3c>
			r = 0;
  801661:	bb 00 00 00 00       	mov    $0x0,%ebx
  801666:	eb e9                	jmp    801651 <fd_close+0x72>

00801668 <close>:

int
close(int fdnum)
{
  801668:	55                   	push   %ebp
  801669:	89 e5                	mov    %esp,%ebp
  80166b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80166e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801671:	50                   	push   %eax
  801672:	ff 75 08             	pushl  0x8(%ebp)
  801675:	e8 b9 fe ff ff       	call   801533 <fd_lookup>
  80167a:	83 c4 08             	add    $0x8,%esp
  80167d:	85 c0                	test   %eax,%eax
  80167f:	78 10                	js     801691 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801681:	83 ec 08             	sub    $0x8,%esp
  801684:	6a 01                	push   $0x1
  801686:	ff 75 f4             	pushl  -0xc(%ebp)
  801689:	e8 51 ff ff ff       	call   8015df <fd_close>
  80168e:	83 c4 10             	add    $0x10,%esp
}
  801691:	c9                   	leave  
  801692:	c3                   	ret    

00801693 <close_all>:

void
close_all(void)
{
  801693:	55                   	push   %ebp
  801694:	89 e5                	mov    %esp,%ebp
  801696:	53                   	push   %ebx
  801697:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80169a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80169f:	83 ec 0c             	sub    $0xc,%esp
  8016a2:	53                   	push   %ebx
  8016a3:	e8 c0 ff ff ff       	call   801668 <close>
	for (i = 0; i < MAXFD; i++)
  8016a8:	83 c3 01             	add    $0x1,%ebx
  8016ab:	83 c4 10             	add    $0x10,%esp
  8016ae:	83 fb 20             	cmp    $0x20,%ebx
  8016b1:	75 ec                	jne    80169f <close_all+0xc>
}
  8016b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016b6:	c9                   	leave  
  8016b7:	c3                   	ret    

008016b8 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8016b8:	55                   	push   %ebp
  8016b9:	89 e5                	mov    %esp,%ebp
  8016bb:	57                   	push   %edi
  8016bc:	56                   	push   %esi
  8016bd:	53                   	push   %ebx
  8016be:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8016c1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016c4:	50                   	push   %eax
  8016c5:	ff 75 08             	pushl  0x8(%ebp)
  8016c8:	e8 66 fe ff ff       	call   801533 <fd_lookup>
  8016cd:	89 c3                	mov    %eax,%ebx
  8016cf:	83 c4 08             	add    $0x8,%esp
  8016d2:	85 c0                	test   %eax,%eax
  8016d4:	0f 88 81 00 00 00    	js     80175b <dup+0xa3>
		return r;
	close(newfdnum);
  8016da:	83 ec 0c             	sub    $0xc,%esp
  8016dd:	ff 75 0c             	pushl  0xc(%ebp)
  8016e0:	e8 83 ff ff ff       	call   801668 <close>

	newfd = INDEX2FD(newfdnum);
  8016e5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8016e8:	c1 e6 0c             	shl    $0xc,%esi
  8016eb:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8016f1:	83 c4 04             	add    $0x4,%esp
  8016f4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016f7:	e8 d1 fd ff ff       	call   8014cd <fd2data>
  8016fc:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8016fe:	89 34 24             	mov    %esi,(%esp)
  801701:	e8 c7 fd ff ff       	call   8014cd <fd2data>
  801706:	83 c4 10             	add    $0x10,%esp
  801709:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80170b:	89 d8                	mov    %ebx,%eax
  80170d:	c1 e8 16             	shr    $0x16,%eax
  801710:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801717:	a8 01                	test   $0x1,%al
  801719:	74 11                	je     80172c <dup+0x74>
  80171b:	89 d8                	mov    %ebx,%eax
  80171d:	c1 e8 0c             	shr    $0xc,%eax
  801720:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801727:	f6 c2 01             	test   $0x1,%dl
  80172a:	75 39                	jne    801765 <dup+0xad>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80172c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80172f:	89 d0                	mov    %edx,%eax
  801731:	c1 e8 0c             	shr    $0xc,%eax
  801734:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80173b:	83 ec 0c             	sub    $0xc,%esp
  80173e:	25 07 0e 00 00       	and    $0xe07,%eax
  801743:	50                   	push   %eax
  801744:	56                   	push   %esi
  801745:	6a 00                	push   $0x0
  801747:	52                   	push   %edx
  801748:	6a 00                	push   $0x0
  80174a:	e8 cc fa ff ff       	call   80121b <sys_page_map>
  80174f:	89 c3                	mov    %eax,%ebx
  801751:	83 c4 20             	add    $0x20,%esp
  801754:	85 c0                	test   %eax,%eax
  801756:	78 31                	js     801789 <dup+0xd1>
		goto err;

	return newfdnum;
  801758:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80175b:	89 d8                	mov    %ebx,%eax
  80175d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801760:	5b                   	pop    %ebx
  801761:	5e                   	pop    %esi
  801762:	5f                   	pop    %edi
  801763:	5d                   	pop    %ebp
  801764:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801765:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80176c:	83 ec 0c             	sub    $0xc,%esp
  80176f:	25 07 0e 00 00       	and    $0xe07,%eax
  801774:	50                   	push   %eax
  801775:	57                   	push   %edi
  801776:	6a 00                	push   $0x0
  801778:	53                   	push   %ebx
  801779:	6a 00                	push   $0x0
  80177b:	e8 9b fa ff ff       	call   80121b <sys_page_map>
  801780:	89 c3                	mov    %eax,%ebx
  801782:	83 c4 20             	add    $0x20,%esp
  801785:	85 c0                	test   %eax,%eax
  801787:	79 a3                	jns    80172c <dup+0x74>
	sys_page_unmap(0, newfd);
  801789:	83 ec 08             	sub    $0x8,%esp
  80178c:	56                   	push   %esi
  80178d:	6a 00                	push   $0x0
  80178f:	e8 c9 fa ff ff       	call   80125d <sys_page_unmap>
	sys_page_unmap(0, nva);
  801794:	83 c4 08             	add    $0x8,%esp
  801797:	57                   	push   %edi
  801798:	6a 00                	push   $0x0
  80179a:	e8 be fa ff ff       	call   80125d <sys_page_unmap>
	return r;
  80179f:	83 c4 10             	add    $0x10,%esp
  8017a2:	eb b7                	jmp    80175b <dup+0xa3>

008017a4 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8017a4:	55                   	push   %ebp
  8017a5:	89 e5                	mov    %esp,%ebp
  8017a7:	53                   	push   %ebx
  8017a8:	83 ec 14             	sub    $0x14,%esp
  8017ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017ae:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017b1:	50                   	push   %eax
  8017b2:	53                   	push   %ebx
  8017b3:	e8 7b fd ff ff       	call   801533 <fd_lookup>
  8017b8:	83 c4 08             	add    $0x8,%esp
  8017bb:	85 c0                	test   %eax,%eax
  8017bd:	78 3f                	js     8017fe <read+0x5a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017bf:	83 ec 08             	sub    $0x8,%esp
  8017c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017c5:	50                   	push   %eax
  8017c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017c9:	ff 30                	pushl  (%eax)
  8017cb:	e8 b9 fd ff ff       	call   801589 <dev_lookup>
  8017d0:	83 c4 10             	add    $0x10,%esp
  8017d3:	85 c0                	test   %eax,%eax
  8017d5:	78 27                	js     8017fe <read+0x5a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8017d7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017da:	8b 42 08             	mov    0x8(%edx),%eax
  8017dd:	83 e0 03             	and    $0x3,%eax
  8017e0:	83 f8 01             	cmp    $0x1,%eax
  8017e3:	74 1e                	je     801803 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8017e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017e8:	8b 40 08             	mov    0x8(%eax),%eax
  8017eb:	85 c0                	test   %eax,%eax
  8017ed:	74 35                	je     801824 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8017ef:	83 ec 04             	sub    $0x4,%esp
  8017f2:	ff 75 10             	pushl  0x10(%ebp)
  8017f5:	ff 75 0c             	pushl  0xc(%ebp)
  8017f8:	52                   	push   %edx
  8017f9:	ff d0                	call   *%eax
  8017fb:	83 c4 10             	add    $0x10,%esp
}
  8017fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801801:	c9                   	leave  
  801802:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801803:	a1 04 40 80 00       	mov    0x804004,%eax
  801808:	8b 40 48             	mov    0x48(%eax),%eax
  80180b:	83 ec 04             	sub    $0x4,%esp
  80180e:	53                   	push   %ebx
  80180f:	50                   	push   %eax
  801810:	68 90 2b 80 00       	push   $0x802b90
  801815:	e8 a6 ef ff ff       	call   8007c0 <cprintf>
		return -E_INVAL;
  80181a:	83 c4 10             	add    $0x10,%esp
  80181d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801822:	eb da                	jmp    8017fe <read+0x5a>
		return -E_NOT_SUPP;
  801824:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801829:	eb d3                	jmp    8017fe <read+0x5a>

0080182b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80182b:	55                   	push   %ebp
  80182c:	89 e5                	mov    %esp,%ebp
  80182e:	57                   	push   %edi
  80182f:	56                   	push   %esi
  801830:	53                   	push   %ebx
  801831:	83 ec 0c             	sub    $0xc,%esp
  801834:	8b 7d 08             	mov    0x8(%ebp),%edi
  801837:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80183a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80183f:	39 f3                	cmp    %esi,%ebx
  801841:	73 25                	jae    801868 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801843:	83 ec 04             	sub    $0x4,%esp
  801846:	89 f0                	mov    %esi,%eax
  801848:	29 d8                	sub    %ebx,%eax
  80184a:	50                   	push   %eax
  80184b:	89 d8                	mov    %ebx,%eax
  80184d:	03 45 0c             	add    0xc(%ebp),%eax
  801850:	50                   	push   %eax
  801851:	57                   	push   %edi
  801852:	e8 4d ff ff ff       	call   8017a4 <read>
		if (m < 0)
  801857:	83 c4 10             	add    $0x10,%esp
  80185a:	85 c0                	test   %eax,%eax
  80185c:	78 08                	js     801866 <readn+0x3b>
			return m;
		if (m == 0)
  80185e:	85 c0                	test   %eax,%eax
  801860:	74 06                	je     801868 <readn+0x3d>
	for (tot = 0; tot < n; tot += m) {
  801862:	01 c3                	add    %eax,%ebx
  801864:	eb d9                	jmp    80183f <readn+0x14>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801866:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801868:	89 d8                	mov    %ebx,%eax
  80186a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80186d:	5b                   	pop    %ebx
  80186e:	5e                   	pop    %esi
  80186f:	5f                   	pop    %edi
  801870:	5d                   	pop    %ebp
  801871:	c3                   	ret    

00801872 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801872:	55                   	push   %ebp
  801873:	89 e5                	mov    %esp,%ebp
  801875:	53                   	push   %ebx
  801876:	83 ec 14             	sub    $0x14,%esp
  801879:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80187c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80187f:	50                   	push   %eax
  801880:	53                   	push   %ebx
  801881:	e8 ad fc ff ff       	call   801533 <fd_lookup>
  801886:	83 c4 08             	add    $0x8,%esp
  801889:	85 c0                	test   %eax,%eax
  80188b:	78 3a                	js     8018c7 <write+0x55>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80188d:	83 ec 08             	sub    $0x8,%esp
  801890:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801893:	50                   	push   %eax
  801894:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801897:	ff 30                	pushl  (%eax)
  801899:	e8 eb fc ff ff       	call   801589 <dev_lookup>
  80189e:	83 c4 10             	add    $0x10,%esp
  8018a1:	85 c0                	test   %eax,%eax
  8018a3:	78 22                	js     8018c7 <write+0x55>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018a8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018ac:	74 1e                	je     8018cc <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8018ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018b1:	8b 52 0c             	mov    0xc(%edx),%edx
  8018b4:	85 d2                	test   %edx,%edx
  8018b6:	74 35                	je     8018ed <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8018b8:	83 ec 04             	sub    $0x4,%esp
  8018bb:	ff 75 10             	pushl  0x10(%ebp)
  8018be:	ff 75 0c             	pushl  0xc(%ebp)
  8018c1:	50                   	push   %eax
  8018c2:	ff d2                	call   *%edx
  8018c4:	83 c4 10             	add    $0x10,%esp
}
  8018c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018ca:	c9                   	leave  
  8018cb:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8018cc:	a1 04 40 80 00       	mov    0x804004,%eax
  8018d1:	8b 40 48             	mov    0x48(%eax),%eax
  8018d4:	83 ec 04             	sub    $0x4,%esp
  8018d7:	53                   	push   %ebx
  8018d8:	50                   	push   %eax
  8018d9:	68 ac 2b 80 00       	push   $0x802bac
  8018de:	e8 dd ee ff ff       	call   8007c0 <cprintf>
		return -E_INVAL;
  8018e3:	83 c4 10             	add    $0x10,%esp
  8018e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018eb:	eb da                	jmp    8018c7 <write+0x55>
		return -E_NOT_SUPP;
  8018ed:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018f2:	eb d3                	jmp    8018c7 <write+0x55>

008018f4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8018f4:	55                   	push   %ebp
  8018f5:	89 e5                	mov    %esp,%ebp
  8018f7:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018fa:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8018fd:	50                   	push   %eax
  8018fe:	ff 75 08             	pushl  0x8(%ebp)
  801901:	e8 2d fc ff ff       	call   801533 <fd_lookup>
  801906:	83 c4 08             	add    $0x8,%esp
  801909:	85 c0                	test   %eax,%eax
  80190b:	78 0e                	js     80191b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80190d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801910:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801913:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801916:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80191b:	c9                   	leave  
  80191c:	c3                   	ret    

0080191d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80191d:	55                   	push   %ebp
  80191e:	89 e5                	mov    %esp,%ebp
  801920:	53                   	push   %ebx
  801921:	83 ec 14             	sub    $0x14,%esp
  801924:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801927:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80192a:	50                   	push   %eax
  80192b:	53                   	push   %ebx
  80192c:	e8 02 fc ff ff       	call   801533 <fd_lookup>
  801931:	83 c4 08             	add    $0x8,%esp
  801934:	85 c0                	test   %eax,%eax
  801936:	78 37                	js     80196f <ftruncate+0x52>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801938:	83 ec 08             	sub    $0x8,%esp
  80193b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80193e:	50                   	push   %eax
  80193f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801942:	ff 30                	pushl  (%eax)
  801944:	e8 40 fc ff ff       	call   801589 <dev_lookup>
  801949:	83 c4 10             	add    $0x10,%esp
  80194c:	85 c0                	test   %eax,%eax
  80194e:	78 1f                	js     80196f <ftruncate+0x52>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801950:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801953:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801957:	74 1b                	je     801974 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801959:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80195c:	8b 52 18             	mov    0x18(%edx),%edx
  80195f:	85 d2                	test   %edx,%edx
  801961:	74 32                	je     801995 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801963:	83 ec 08             	sub    $0x8,%esp
  801966:	ff 75 0c             	pushl  0xc(%ebp)
  801969:	50                   	push   %eax
  80196a:	ff d2                	call   *%edx
  80196c:	83 c4 10             	add    $0x10,%esp
}
  80196f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801972:	c9                   	leave  
  801973:	c3                   	ret    
			thisenv->env_id, fdnum);
  801974:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801979:	8b 40 48             	mov    0x48(%eax),%eax
  80197c:	83 ec 04             	sub    $0x4,%esp
  80197f:	53                   	push   %ebx
  801980:	50                   	push   %eax
  801981:	68 6c 2b 80 00       	push   $0x802b6c
  801986:	e8 35 ee ff ff       	call   8007c0 <cprintf>
		return -E_INVAL;
  80198b:	83 c4 10             	add    $0x10,%esp
  80198e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801993:	eb da                	jmp    80196f <ftruncate+0x52>
		return -E_NOT_SUPP;
  801995:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80199a:	eb d3                	jmp    80196f <ftruncate+0x52>

0080199c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80199c:	55                   	push   %ebp
  80199d:	89 e5                	mov    %esp,%ebp
  80199f:	53                   	push   %ebx
  8019a0:	83 ec 14             	sub    $0x14,%esp
  8019a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019a9:	50                   	push   %eax
  8019aa:	ff 75 08             	pushl  0x8(%ebp)
  8019ad:	e8 81 fb ff ff       	call   801533 <fd_lookup>
  8019b2:	83 c4 08             	add    $0x8,%esp
  8019b5:	85 c0                	test   %eax,%eax
  8019b7:	78 4b                	js     801a04 <fstat+0x68>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019b9:	83 ec 08             	sub    $0x8,%esp
  8019bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019bf:	50                   	push   %eax
  8019c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019c3:	ff 30                	pushl  (%eax)
  8019c5:	e8 bf fb ff ff       	call   801589 <dev_lookup>
  8019ca:	83 c4 10             	add    $0x10,%esp
  8019cd:	85 c0                	test   %eax,%eax
  8019cf:	78 33                	js     801a04 <fstat+0x68>
		return r;
	if (!dev->dev_stat)
  8019d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019d4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8019d8:	74 2f                	je     801a09 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8019da:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8019dd:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8019e4:	00 00 00 
	stat->st_isdir = 0;
  8019e7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019ee:	00 00 00 
	stat->st_dev = dev;
  8019f1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8019f7:	83 ec 08             	sub    $0x8,%esp
  8019fa:	53                   	push   %ebx
  8019fb:	ff 75 f0             	pushl  -0x10(%ebp)
  8019fe:	ff 50 14             	call   *0x14(%eax)
  801a01:	83 c4 10             	add    $0x10,%esp
}
  801a04:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a07:	c9                   	leave  
  801a08:	c3                   	ret    
		return -E_NOT_SUPP;
  801a09:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a0e:	eb f4                	jmp    801a04 <fstat+0x68>

00801a10 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a10:	55                   	push   %ebp
  801a11:	89 e5                	mov    %esp,%ebp
  801a13:	56                   	push   %esi
  801a14:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a15:	83 ec 08             	sub    $0x8,%esp
  801a18:	6a 00                	push   $0x0
  801a1a:	ff 75 08             	pushl  0x8(%ebp)
  801a1d:	e8 da 01 00 00       	call   801bfc <open>
  801a22:	89 c3                	mov    %eax,%ebx
  801a24:	83 c4 10             	add    $0x10,%esp
  801a27:	85 c0                	test   %eax,%eax
  801a29:	78 1b                	js     801a46 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801a2b:	83 ec 08             	sub    $0x8,%esp
  801a2e:	ff 75 0c             	pushl  0xc(%ebp)
  801a31:	50                   	push   %eax
  801a32:	e8 65 ff ff ff       	call   80199c <fstat>
  801a37:	89 c6                	mov    %eax,%esi
	close(fd);
  801a39:	89 1c 24             	mov    %ebx,(%esp)
  801a3c:	e8 27 fc ff ff       	call   801668 <close>
	return r;
  801a41:	83 c4 10             	add    $0x10,%esp
  801a44:	89 f3                	mov    %esi,%ebx
}
  801a46:	89 d8                	mov    %ebx,%eax
  801a48:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a4b:	5b                   	pop    %ebx
  801a4c:	5e                   	pop    %esi
  801a4d:	5d                   	pop    %ebp
  801a4e:	c3                   	ret    

00801a4f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a4f:	55                   	push   %ebp
  801a50:	89 e5                	mov    %esp,%ebp
  801a52:	56                   	push   %esi
  801a53:	53                   	push   %ebx
  801a54:	89 c6                	mov    %eax,%esi
  801a56:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801a58:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801a5f:	74 27                	je     801a88 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a61:	6a 07                	push   $0x7
  801a63:	68 00 50 80 00       	push   $0x805000
  801a68:	56                   	push   %esi
  801a69:	ff 35 00 40 80 00    	pushl  0x804000
  801a6f:	e8 bc f9 ff ff       	call   801430 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a74:	83 c4 0c             	add    $0xc,%esp
  801a77:	6a 00                	push   $0x0
  801a79:	53                   	push   %ebx
  801a7a:	6a 00                	push   $0x0
  801a7c:	e8 48 f9 ff ff       	call   8013c9 <ipc_recv>
}
  801a81:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a84:	5b                   	pop    %ebx
  801a85:	5e                   	pop    %esi
  801a86:	5d                   	pop    %ebp
  801a87:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a88:	83 ec 0c             	sub    $0xc,%esp
  801a8b:	6a 01                	push   $0x1
  801a8d:	e8 f2 f9 ff ff       	call   801484 <ipc_find_env>
  801a92:	a3 00 40 80 00       	mov    %eax,0x804000
  801a97:	83 c4 10             	add    $0x10,%esp
  801a9a:	eb c5                	jmp    801a61 <fsipc+0x12>

00801a9c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a9c:	55                   	push   %ebp
  801a9d:	89 e5                	mov    %esp,%ebp
  801a9f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801aa2:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa5:	8b 40 0c             	mov    0xc(%eax),%eax
  801aa8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801aad:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ab0:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801ab5:	ba 00 00 00 00       	mov    $0x0,%edx
  801aba:	b8 02 00 00 00       	mov    $0x2,%eax
  801abf:	e8 8b ff ff ff       	call   801a4f <fsipc>
}
  801ac4:	c9                   	leave  
  801ac5:	c3                   	ret    

00801ac6 <devfile_flush>:
{
  801ac6:	55                   	push   %ebp
  801ac7:	89 e5                	mov    %esp,%ebp
  801ac9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801acc:	8b 45 08             	mov    0x8(%ebp),%eax
  801acf:	8b 40 0c             	mov    0xc(%eax),%eax
  801ad2:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801ad7:	ba 00 00 00 00       	mov    $0x0,%edx
  801adc:	b8 06 00 00 00       	mov    $0x6,%eax
  801ae1:	e8 69 ff ff ff       	call   801a4f <fsipc>
}
  801ae6:	c9                   	leave  
  801ae7:	c3                   	ret    

00801ae8 <devfile_stat>:
{
  801ae8:	55                   	push   %ebp
  801ae9:	89 e5                	mov    %esp,%ebp
  801aeb:	53                   	push   %ebx
  801aec:	83 ec 04             	sub    $0x4,%esp
  801aef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801af2:	8b 45 08             	mov    0x8(%ebp),%eax
  801af5:	8b 40 0c             	mov    0xc(%eax),%eax
  801af8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801afd:	ba 00 00 00 00       	mov    $0x0,%edx
  801b02:	b8 05 00 00 00       	mov    $0x5,%eax
  801b07:	e8 43 ff ff ff       	call   801a4f <fsipc>
  801b0c:	85 c0                	test   %eax,%eax
  801b0e:	78 2c                	js     801b3c <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b10:	83 ec 08             	sub    $0x8,%esp
  801b13:	68 00 50 80 00       	push   $0x805000
  801b18:	53                   	push   %ebx
  801b19:	e8 c1 f2 ff ff       	call   800ddf <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b1e:	a1 80 50 80 00       	mov    0x805080,%eax
  801b23:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b29:	a1 84 50 80 00       	mov    0x805084,%eax
  801b2e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b34:	83 c4 10             	add    $0x10,%esp
  801b37:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b3c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b3f:	c9                   	leave  
  801b40:	c3                   	ret    

00801b41 <devfile_write>:
{
  801b41:	55                   	push   %ebp
  801b42:	89 e5                	mov    %esp,%ebp
  801b44:	83 ec 0c             	sub    $0xc,%esp
  801b47:	8b 45 10             	mov    0x10(%ebp),%eax
    	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801b4a:	8b 55 08             	mov    0x8(%ebp),%edx
  801b4d:	8b 52 0c             	mov    0xc(%edx),%edx
  801b50:	89 15 00 50 80 00    	mov    %edx,0x805000
    	fsipcbuf.write.req_n = n;
  801b56:	a3 04 50 80 00       	mov    %eax,0x805004
    	memmove(fsipcbuf.write.req_buf, buf, n);
  801b5b:	50                   	push   %eax
  801b5c:	ff 75 0c             	pushl  0xc(%ebp)
  801b5f:	68 08 50 80 00       	push   $0x805008
  801b64:	e8 04 f4 ff ff       	call   800f6d <memmove>
    	return fsipc(FSREQ_WRITE, NULL);
  801b69:	ba 00 00 00 00       	mov    $0x0,%edx
  801b6e:	b8 04 00 00 00       	mov    $0x4,%eax
  801b73:	e8 d7 fe ff ff       	call   801a4f <fsipc>
}
  801b78:	c9                   	leave  
  801b79:	c3                   	ret    

00801b7a <devfile_read>:
{
  801b7a:	55                   	push   %ebp
  801b7b:	89 e5                	mov    %esp,%ebp
  801b7d:	56                   	push   %esi
  801b7e:	53                   	push   %ebx
  801b7f:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b82:	8b 45 08             	mov    0x8(%ebp),%eax
  801b85:	8b 40 0c             	mov    0xc(%eax),%eax
  801b88:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b8d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b93:	ba 00 00 00 00       	mov    $0x0,%edx
  801b98:	b8 03 00 00 00       	mov    $0x3,%eax
  801b9d:	e8 ad fe ff ff       	call   801a4f <fsipc>
  801ba2:	89 c3                	mov    %eax,%ebx
  801ba4:	85 c0                	test   %eax,%eax
  801ba6:	78 1f                	js     801bc7 <devfile_read+0x4d>
	assert(r <= n);
  801ba8:	39 f0                	cmp    %esi,%eax
  801baa:	77 24                	ja     801bd0 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801bac:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801bb1:	7f 33                	jg     801be6 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801bb3:	83 ec 04             	sub    $0x4,%esp
  801bb6:	50                   	push   %eax
  801bb7:	68 00 50 80 00       	push   $0x805000
  801bbc:	ff 75 0c             	pushl  0xc(%ebp)
  801bbf:	e8 a9 f3 ff ff       	call   800f6d <memmove>
	return r;
  801bc4:	83 c4 10             	add    $0x10,%esp
}
  801bc7:	89 d8                	mov    %ebx,%eax
  801bc9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bcc:	5b                   	pop    %ebx
  801bcd:	5e                   	pop    %esi
  801bce:	5d                   	pop    %ebp
  801bcf:	c3                   	ret    
	assert(r <= n);
  801bd0:	68 dc 2b 80 00       	push   $0x802bdc
  801bd5:	68 e3 2b 80 00       	push   $0x802be3
  801bda:	6a 7c                	push   $0x7c
  801bdc:	68 f8 2b 80 00       	push   $0x802bf8
  801be1:	e8 ff ea ff ff       	call   8006e5 <_panic>
	assert(r <= PGSIZE);
  801be6:	68 03 2c 80 00       	push   $0x802c03
  801beb:	68 e3 2b 80 00       	push   $0x802be3
  801bf0:	6a 7d                	push   $0x7d
  801bf2:	68 f8 2b 80 00       	push   $0x802bf8
  801bf7:	e8 e9 ea ff ff       	call   8006e5 <_panic>

00801bfc <open>:
{
  801bfc:	55                   	push   %ebp
  801bfd:	89 e5                	mov    %esp,%ebp
  801bff:	56                   	push   %esi
  801c00:	53                   	push   %ebx
  801c01:	83 ec 1c             	sub    $0x1c,%esp
  801c04:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801c07:	56                   	push   %esi
  801c08:	e8 9b f1 ff ff       	call   800da8 <strlen>
  801c0d:	83 c4 10             	add    $0x10,%esp
  801c10:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c15:	7f 6c                	jg     801c83 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801c17:	83 ec 0c             	sub    $0xc,%esp
  801c1a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c1d:	50                   	push   %eax
  801c1e:	e8 c1 f8 ff ff       	call   8014e4 <fd_alloc>
  801c23:	89 c3                	mov    %eax,%ebx
  801c25:	83 c4 10             	add    $0x10,%esp
  801c28:	85 c0                	test   %eax,%eax
  801c2a:	78 3c                	js     801c68 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801c2c:	83 ec 08             	sub    $0x8,%esp
  801c2f:	56                   	push   %esi
  801c30:	68 00 50 80 00       	push   $0x805000
  801c35:	e8 a5 f1 ff ff       	call   800ddf <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c3d:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c42:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c45:	b8 01 00 00 00       	mov    $0x1,%eax
  801c4a:	e8 00 fe ff ff       	call   801a4f <fsipc>
  801c4f:	89 c3                	mov    %eax,%ebx
  801c51:	83 c4 10             	add    $0x10,%esp
  801c54:	85 c0                	test   %eax,%eax
  801c56:	78 19                	js     801c71 <open+0x75>
	return fd2num(fd);
  801c58:	83 ec 0c             	sub    $0xc,%esp
  801c5b:	ff 75 f4             	pushl  -0xc(%ebp)
  801c5e:	e8 5a f8 ff ff       	call   8014bd <fd2num>
  801c63:	89 c3                	mov    %eax,%ebx
  801c65:	83 c4 10             	add    $0x10,%esp
}
  801c68:	89 d8                	mov    %ebx,%eax
  801c6a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c6d:	5b                   	pop    %ebx
  801c6e:	5e                   	pop    %esi
  801c6f:	5d                   	pop    %ebp
  801c70:	c3                   	ret    
		fd_close(fd, 0);
  801c71:	83 ec 08             	sub    $0x8,%esp
  801c74:	6a 00                	push   $0x0
  801c76:	ff 75 f4             	pushl  -0xc(%ebp)
  801c79:	e8 61 f9 ff ff       	call   8015df <fd_close>
		return r;
  801c7e:	83 c4 10             	add    $0x10,%esp
  801c81:	eb e5                	jmp    801c68 <open+0x6c>
		return -E_BAD_PATH;
  801c83:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801c88:	eb de                	jmp    801c68 <open+0x6c>

00801c8a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c8a:	55                   	push   %ebp
  801c8b:	89 e5                	mov    %esp,%ebp
  801c8d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c90:	ba 00 00 00 00       	mov    $0x0,%edx
  801c95:	b8 08 00 00 00       	mov    $0x8,%eax
  801c9a:	e8 b0 fd ff ff       	call   801a4f <fsipc>
}
  801c9f:	c9                   	leave  
  801ca0:	c3                   	ret    

00801ca1 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ca1:	55                   	push   %ebp
  801ca2:	89 e5                	mov    %esp,%ebp
  801ca4:	56                   	push   %esi
  801ca5:	53                   	push   %ebx
  801ca6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ca9:	83 ec 0c             	sub    $0xc,%esp
  801cac:	ff 75 08             	pushl  0x8(%ebp)
  801caf:	e8 19 f8 ff ff       	call   8014cd <fd2data>
  801cb4:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801cb6:	83 c4 08             	add    $0x8,%esp
  801cb9:	68 0f 2c 80 00       	push   $0x802c0f
  801cbe:	53                   	push   %ebx
  801cbf:	e8 1b f1 ff ff       	call   800ddf <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801cc4:	8b 46 04             	mov    0x4(%esi),%eax
  801cc7:	2b 06                	sub    (%esi),%eax
  801cc9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ccf:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801cd6:	00 00 00 
	stat->st_dev = &devpipe;
  801cd9:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801ce0:	30 80 00 
	return 0;
}
  801ce3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ce8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ceb:	5b                   	pop    %ebx
  801cec:	5e                   	pop    %esi
  801ced:	5d                   	pop    %ebp
  801cee:	c3                   	ret    

00801cef <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801cef:	55                   	push   %ebp
  801cf0:	89 e5                	mov    %esp,%ebp
  801cf2:	53                   	push   %ebx
  801cf3:	83 ec 0c             	sub    $0xc,%esp
  801cf6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801cf9:	53                   	push   %ebx
  801cfa:	6a 00                	push   $0x0
  801cfc:	e8 5c f5 ff ff       	call   80125d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d01:	89 1c 24             	mov    %ebx,(%esp)
  801d04:	e8 c4 f7 ff ff       	call   8014cd <fd2data>
  801d09:	83 c4 08             	add    $0x8,%esp
  801d0c:	50                   	push   %eax
  801d0d:	6a 00                	push   $0x0
  801d0f:	e8 49 f5 ff ff       	call   80125d <sys_page_unmap>
}
  801d14:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d17:	c9                   	leave  
  801d18:	c3                   	ret    

00801d19 <_pipeisclosed>:
{
  801d19:	55                   	push   %ebp
  801d1a:	89 e5                	mov    %esp,%ebp
  801d1c:	57                   	push   %edi
  801d1d:	56                   	push   %esi
  801d1e:	53                   	push   %ebx
  801d1f:	83 ec 1c             	sub    $0x1c,%esp
  801d22:	89 c7                	mov    %eax,%edi
  801d24:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801d26:	a1 04 40 80 00       	mov    0x804004,%eax
  801d2b:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801d2e:	83 ec 0c             	sub    $0xc,%esp
  801d31:	57                   	push   %edi
  801d32:	e8 34 04 00 00       	call   80216b <pageref>
  801d37:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801d3a:	89 34 24             	mov    %esi,(%esp)
  801d3d:	e8 29 04 00 00       	call   80216b <pageref>
		nn = thisenv->env_runs;
  801d42:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801d48:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801d4b:	83 c4 10             	add    $0x10,%esp
  801d4e:	39 cb                	cmp    %ecx,%ebx
  801d50:	74 1b                	je     801d6d <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801d52:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801d55:	75 cf                	jne    801d26 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d57:	8b 42 58             	mov    0x58(%edx),%eax
  801d5a:	6a 01                	push   $0x1
  801d5c:	50                   	push   %eax
  801d5d:	53                   	push   %ebx
  801d5e:	68 16 2c 80 00       	push   $0x802c16
  801d63:	e8 58 ea ff ff       	call   8007c0 <cprintf>
  801d68:	83 c4 10             	add    $0x10,%esp
  801d6b:	eb b9                	jmp    801d26 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801d6d:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801d70:	0f 94 c0             	sete   %al
  801d73:	0f b6 c0             	movzbl %al,%eax
}
  801d76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d79:	5b                   	pop    %ebx
  801d7a:	5e                   	pop    %esi
  801d7b:	5f                   	pop    %edi
  801d7c:	5d                   	pop    %ebp
  801d7d:	c3                   	ret    

00801d7e <devpipe_write>:
{
  801d7e:	55                   	push   %ebp
  801d7f:	89 e5                	mov    %esp,%ebp
  801d81:	57                   	push   %edi
  801d82:	56                   	push   %esi
  801d83:	53                   	push   %ebx
  801d84:	83 ec 28             	sub    $0x28,%esp
  801d87:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801d8a:	56                   	push   %esi
  801d8b:	e8 3d f7 ff ff       	call   8014cd <fd2data>
  801d90:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801d92:	83 c4 10             	add    $0x10,%esp
  801d95:	bf 00 00 00 00       	mov    $0x0,%edi
  801d9a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d9d:	74 4f                	je     801dee <devpipe_write+0x70>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d9f:	8b 43 04             	mov    0x4(%ebx),%eax
  801da2:	8b 0b                	mov    (%ebx),%ecx
  801da4:	8d 51 20             	lea    0x20(%ecx),%edx
  801da7:	39 d0                	cmp    %edx,%eax
  801da9:	72 14                	jb     801dbf <devpipe_write+0x41>
			if (_pipeisclosed(fd, p))
  801dab:	89 da                	mov    %ebx,%edx
  801dad:	89 f0                	mov    %esi,%eax
  801daf:	e8 65 ff ff ff       	call   801d19 <_pipeisclosed>
  801db4:	85 c0                	test   %eax,%eax
  801db6:	75 3a                	jne    801df2 <devpipe_write+0x74>
			sys_yield();
  801db8:	e8 fc f3 ff ff       	call   8011b9 <sys_yield>
  801dbd:	eb e0                	jmp    801d9f <devpipe_write+0x21>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801dbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801dc2:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801dc6:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801dc9:	89 c2                	mov    %eax,%edx
  801dcb:	c1 fa 1f             	sar    $0x1f,%edx
  801dce:	89 d1                	mov    %edx,%ecx
  801dd0:	c1 e9 1b             	shr    $0x1b,%ecx
  801dd3:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801dd6:	83 e2 1f             	and    $0x1f,%edx
  801dd9:	29 ca                	sub    %ecx,%edx
  801ddb:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ddf:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801de3:	83 c0 01             	add    $0x1,%eax
  801de6:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801de9:	83 c7 01             	add    $0x1,%edi
  801dec:	eb ac                	jmp    801d9a <devpipe_write+0x1c>
	return i;
  801dee:	89 f8                	mov    %edi,%eax
  801df0:	eb 05                	jmp    801df7 <devpipe_write+0x79>
				return 0;
  801df2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801df7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dfa:	5b                   	pop    %ebx
  801dfb:	5e                   	pop    %esi
  801dfc:	5f                   	pop    %edi
  801dfd:	5d                   	pop    %ebp
  801dfe:	c3                   	ret    

00801dff <devpipe_read>:
{
  801dff:	55                   	push   %ebp
  801e00:	89 e5                	mov    %esp,%ebp
  801e02:	57                   	push   %edi
  801e03:	56                   	push   %esi
  801e04:	53                   	push   %ebx
  801e05:	83 ec 18             	sub    $0x18,%esp
  801e08:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801e0b:	57                   	push   %edi
  801e0c:	e8 bc f6 ff ff       	call   8014cd <fd2data>
  801e11:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801e13:	83 c4 10             	add    $0x10,%esp
  801e16:	be 00 00 00 00       	mov    $0x0,%esi
  801e1b:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e1e:	74 47                	je     801e67 <devpipe_read+0x68>
		while (p->p_rpos == p->p_wpos) {
  801e20:	8b 03                	mov    (%ebx),%eax
  801e22:	3b 43 04             	cmp    0x4(%ebx),%eax
  801e25:	75 22                	jne    801e49 <devpipe_read+0x4a>
			if (i > 0)
  801e27:	85 f6                	test   %esi,%esi
  801e29:	75 14                	jne    801e3f <devpipe_read+0x40>
			if (_pipeisclosed(fd, p))
  801e2b:	89 da                	mov    %ebx,%edx
  801e2d:	89 f8                	mov    %edi,%eax
  801e2f:	e8 e5 fe ff ff       	call   801d19 <_pipeisclosed>
  801e34:	85 c0                	test   %eax,%eax
  801e36:	75 33                	jne    801e6b <devpipe_read+0x6c>
			sys_yield();
  801e38:	e8 7c f3 ff ff       	call   8011b9 <sys_yield>
  801e3d:	eb e1                	jmp    801e20 <devpipe_read+0x21>
				return i;
  801e3f:	89 f0                	mov    %esi,%eax
}
  801e41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e44:	5b                   	pop    %ebx
  801e45:	5e                   	pop    %esi
  801e46:	5f                   	pop    %edi
  801e47:	5d                   	pop    %ebp
  801e48:	c3                   	ret    
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e49:	99                   	cltd   
  801e4a:	c1 ea 1b             	shr    $0x1b,%edx
  801e4d:	01 d0                	add    %edx,%eax
  801e4f:	83 e0 1f             	and    $0x1f,%eax
  801e52:	29 d0                	sub    %edx,%eax
  801e54:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801e59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e5c:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801e5f:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801e62:	83 c6 01             	add    $0x1,%esi
  801e65:	eb b4                	jmp    801e1b <devpipe_read+0x1c>
	return i;
  801e67:	89 f0                	mov    %esi,%eax
  801e69:	eb d6                	jmp    801e41 <devpipe_read+0x42>
				return 0;
  801e6b:	b8 00 00 00 00       	mov    $0x0,%eax
  801e70:	eb cf                	jmp    801e41 <devpipe_read+0x42>

00801e72 <pipe>:
{
  801e72:	55                   	push   %ebp
  801e73:	89 e5                	mov    %esp,%ebp
  801e75:	56                   	push   %esi
  801e76:	53                   	push   %ebx
  801e77:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801e7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e7d:	50                   	push   %eax
  801e7e:	e8 61 f6 ff ff       	call   8014e4 <fd_alloc>
  801e83:	89 c3                	mov    %eax,%ebx
  801e85:	83 c4 10             	add    $0x10,%esp
  801e88:	85 c0                	test   %eax,%eax
  801e8a:	78 5b                	js     801ee7 <pipe+0x75>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e8c:	83 ec 04             	sub    $0x4,%esp
  801e8f:	68 07 04 00 00       	push   $0x407
  801e94:	ff 75 f4             	pushl  -0xc(%ebp)
  801e97:	6a 00                	push   $0x0
  801e99:	e8 3a f3 ff ff       	call   8011d8 <sys_page_alloc>
  801e9e:	89 c3                	mov    %eax,%ebx
  801ea0:	83 c4 10             	add    $0x10,%esp
  801ea3:	85 c0                	test   %eax,%eax
  801ea5:	78 40                	js     801ee7 <pipe+0x75>
	if ((r = fd_alloc(&fd1)) < 0
  801ea7:	83 ec 0c             	sub    $0xc,%esp
  801eaa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ead:	50                   	push   %eax
  801eae:	e8 31 f6 ff ff       	call   8014e4 <fd_alloc>
  801eb3:	89 c3                	mov    %eax,%ebx
  801eb5:	83 c4 10             	add    $0x10,%esp
  801eb8:	85 c0                	test   %eax,%eax
  801eba:	78 1b                	js     801ed7 <pipe+0x65>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ebc:	83 ec 04             	sub    $0x4,%esp
  801ebf:	68 07 04 00 00       	push   $0x407
  801ec4:	ff 75 f0             	pushl  -0x10(%ebp)
  801ec7:	6a 00                	push   $0x0
  801ec9:	e8 0a f3 ff ff       	call   8011d8 <sys_page_alloc>
  801ece:	89 c3                	mov    %eax,%ebx
  801ed0:	83 c4 10             	add    $0x10,%esp
  801ed3:	85 c0                	test   %eax,%eax
  801ed5:	79 19                	jns    801ef0 <pipe+0x7e>
	sys_page_unmap(0, fd0);
  801ed7:	83 ec 08             	sub    $0x8,%esp
  801eda:	ff 75 f4             	pushl  -0xc(%ebp)
  801edd:	6a 00                	push   $0x0
  801edf:	e8 79 f3 ff ff       	call   80125d <sys_page_unmap>
  801ee4:	83 c4 10             	add    $0x10,%esp
}
  801ee7:	89 d8                	mov    %ebx,%eax
  801ee9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eec:	5b                   	pop    %ebx
  801eed:	5e                   	pop    %esi
  801eee:	5d                   	pop    %ebp
  801eef:	c3                   	ret    
	va = fd2data(fd0);
  801ef0:	83 ec 0c             	sub    $0xc,%esp
  801ef3:	ff 75 f4             	pushl  -0xc(%ebp)
  801ef6:	e8 d2 f5 ff ff       	call   8014cd <fd2data>
  801efb:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801efd:	83 c4 0c             	add    $0xc,%esp
  801f00:	68 07 04 00 00       	push   $0x407
  801f05:	50                   	push   %eax
  801f06:	6a 00                	push   $0x0
  801f08:	e8 cb f2 ff ff       	call   8011d8 <sys_page_alloc>
  801f0d:	89 c3                	mov    %eax,%ebx
  801f0f:	83 c4 10             	add    $0x10,%esp
  801f12:	85 c0                	test   %eax,%eax
  801f14:	0f 88 8c 00 00 00    	js     801fa6 <pipe+0x134>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f1a:	83 ec 0c             	sub    $0xc,%esp
  801f1d:	ff 75 f0             	pushl  -0x10(%ebp)
  801f20:	e8 a8 f5 ff ff       	call   8014cd <fd2data>
  801f25:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801f2c:	50                   	push   %eax
  801f2d:	6a 00                	push   $0x0
  801f2f:	56                   	push   %esi
  801f30:	6a 00                	push   $0x0
  801f32:	e8 e4 f2 ff ff       	call   80121b <sys_page_map>
  801f37:	89 c3                	mov    %eax,%ebx
  801f39:	83 c4 20             	add    $0x20,%esp
  801f3c:	85 c0                	test   %eax,%eax
  801f3e:	78 58                	js     801f98 <pipe+0x126>
	fd0->fd_dev_id = devpipe.dev_id;
  801f40:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f43:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801f49:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f4e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
	fd1->fd_dev_id = devpipe.dev_id;
  801f55:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f58:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801f5e:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f60:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f63:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801f6a:	83 ec 0c             	sub    $0xc,%esp
  801f6d:	ff 75 f4             	pushl  -0xc(%ebp)
  801f70:	e8 48 f5 ff ff       	call   8014bd <fd2num>
  801f75:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f78:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f7a:	83 c4 04             	add    $0x4,%esp
  801f7d:	ff 75 f0             	pushl  -0x10(%ebp)
  801f80:	e8 38 f5 ff ff       	call   8014bd <fd2num>
  801f85:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f88:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f8b:	83 c4 10             	add    $0x10,%esp
  801f8e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f93:	e9 4f ff ff ff       	jmp    801ee7 <pipe+0x75>
	sys_page_unmap(0, va);
  801f98:	83 ec 08             	sub    $0x8,%esp
  801f9b:	56                   	push   %esi
  801f9c:	6a 00                	push   $0x0
  801f9e:	e8 ba f2 ff ff       	call   80125d <sys_page_unmap>
  801fa3:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801fa6:	83 ec 08             	sub    $0x8,%esp
  801fa9:	ff 75 f0             	pushl  -0x10(%ebp)
  801fac:	6a 00                	push   $0x0
  801fae:	e8 aa f2 ff ff       	call   80125d <sys_page_unmap>
  801fb3:	83 c4 10             	add    $0x10,%esp
  801fb6:	e9 1c ff ff ff       	jmp    801ed7 <pipe+0x65>

00801fbb <pipeisclosed>:
{
  801fbb:	55                   	push   %ebp
  801fbc:	89 e5                	mov    %esp,%ebp
  801fbe:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fc1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fc4:	50                   	push   %eax
  801fc5:	ff 75 08             	pushl  0x8(%ebp)
  801fc8:	e8 66 f5 ff ff       	call   801533 <fd_lookup>
  801fcd:	83 c4 10             	add    $0x10,%esp
  801fd0:	85 c0                	test   %eax,%eax
  801fd2:	78 18                	js     801fec <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801fd4:	83 ec 0c             	sub    $0xc,%esp
  801fd7:	ff 75 f4             	pushl  -0xc(%ebp)
  801fda:	e8 ee f4 ff ff       	call   8014cd <fd2data>
	return _pipeisclosed(fd, p);
  801fdf:	89 c2                	mov    %eax,%edx
  801fe1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fe4:	e8 30 fd ff ff       	call   801d19 <_pipeisclosed>
  801fe9:	83 c4 10             	add    $0x10,%esp
}
  801fec:	c9                   	leave  
  801fed:	c3                   	ret    

00801fee <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801fee:	55                   	push   %ebp
  801fef:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ff1:	b8 00 00 00 00       	mov    $0x0,%eax
  801ff6:	5d                   	pop    %ebp
  801ff7:	c3                   	ret    

00801ff8 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ff8:	55                   	push   %ebp
  801ff9:	89 e5                	mov    %esp,%ebp
  801ffb:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ffe:	68 2e 2c 80 00       	push   $0x802c2e
  802003:	ff 75 0c             	pushl  0xc(%ebp)
  802006:	e8 d4 ed ff ff       	call   800ddf <strcpy>
	return 0;
}
  80200b:	b8 00 00 00 00       	mov    $0x0,%eax
  802010:	c9                   	leave  
  802011:	c3                   	ret    

00802012 <devcons_write>:
{
  802012:	55                   	push   %ebp
  802013:	89 e5                	mov    %esp,%ebp
  802015:	57                   	push   %edi
  802016:	56                   	push   %esi
  802017:	53                   	push   %ebx
  802018:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  80201e:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802023:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  802029:	eb 2f                	jmp    80205a <devcons_write+0x48>
		m = n - tot;
  80202b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80202e:	29 f3                	sub    %esi,%ebx
  802030:	83 fb 7f             	cmp    $0x7f,%ebx
  802033:	b8 7f 00 00 00       	mov    $0x7f,%eax
  802038:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80203b:	83 ec 04             	sub    $0x4,%esp
  80203e:	53                   	push   %ebx
  80203f:	89 f0                	mov    %esi,%eax
  802041:	03 45 0c             	add    0xc(%ebp),%eax
  802044:	50                   	push   %eax
  802045:	57                   	push   %edi
  802046:	e8 22 ef ff ff       	call   800f6d <memmove>
		sys_cputs(buf, m);
  80204b:	83 c4 08             	add    $0x8,%esp
  80204e:	53                   	push   %ebx
  80204f:	57                   	push   %edi
  802050:	e8 c7 f0 ff ff       	call   80111c <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  802055:	01 de                	add    %ebx,%esi
  802057:	83 c4 10             	add    $0x10,%esp
  80205a:	3b 75 10             	cmp    0x10(%ebp),%esi
  80205d:	72 cc                	jb     80202b <devcons_write+0x19>
}
  80205f:	89 f0                	mov    %esi,%eax
  802061:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802064:	5b                   	pop    %ebx
  802065:	5e                   	pop    %esi
  802066:	5f                   	pop    %edi
  802067:	5d                   	pop    %ebp
  802068:	c3                   	ret    

00802069 <devcons_read>:
{
  802069:	55                   	push   %ebp
  80206a:	89 e5                	mov    %esp,%ebp
  80206c:	83 ec 08             	sub    $0x8,%esp
  80206f:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  802074:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802078:	75 07                	jne    802081 <devcons_read+0x18>
}
  80207a:	c9                   	leave  
  80207b:	c3                   	ret    
		sys_yield();
  80207c:	e8 38 f1 ff ff       	call   8011b9 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  802081:	e8 b4 f0 ff ff       	call   80113a <sys_cgetc>
  802086:	85 c0                	test   %eax,%eax
  802088:	74 f2                	je     80207c <devcons_read+0x13>
	if (c < 0)
  80208a:	85 c0                	test   %eax,%eax
  80208c:	78 ec                	js     80207a <devcons_read+0x11>
	if (c == 0x04)	// ctl-d is eof
  80208e:	83 f8 04             	cmp    $0x4,%eax
  802091:	74 0c                	je     80209f <devcons_read+0x36>
	*(char*)vbuf = c;
  802093:	8b 55 0c             	mov    0xc(%ebp),%edx
  802096:	88 02                	mov    %al,(%edx)
	return 1;
  802098:	b8 01 00 00 00       	mov    $0x1,%eax
  80209d:	eb db                	jmp    80207a <devcons_read+0x11>
		return 0;
  80209f:	b8 00 00 00 00       	mov    $0x0,%eax
  8020a4:	eb d4                	jmp    80207a <devcons_read+0x11>

008020a6 <cputchar>:
{
  8020a6:	55                   	push   %ebp
  8020a7:	89 e5                	mov    %esp,%ebp
  8020a9:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8020ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8020af:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8020b2:	6a 01                	push   $0x1
  8020b4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020b7:	50                   	push   %eax
  8020b8:	e8 5f f0 ff ff       	call   80111c <sys_cputs>
}
  8020bd:	83 c4 10             	add    $0x10,%esp
  8020c0:	c9                   	leave  
  8020c1:	c3                   	ret    

008020c2 <getchar>:
{
  8020c2:	55                   	push   %ebp
  8020c3:	89 e5                	mov    %esp,%ebp
  8020c5:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  8020c8:	6a 01                	push   $0x1
  8020ca:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020cd:	50                   	push   %eax
  8020ce:	6a 00                	push   $0x0
  8020d0:	e8 cf f6 ff ff       	call   8017a4 <read>
	if (r < 0)
  8020d5:	83 c4 10             	add    $0x10,%esp
  8020d8:	85 c0                	test   %eax,%eax
  8020da:	78 08                	js     8020e4 <getchar+0x22>
	if (r < 1)
  8020dc:	85 c0                	test   %eax,%eax
  8020de:	7e 06                	jle    8020e6 <getchar+0x24>
	return c;
  8020e0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  8020e4:	c9                   	leave  
  8020e5:	c3                   	ret    
		return -E_EOF;
  8020e6:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  8020eb:	eb f7                	jmp    8020e4 <getchar+0x22>

008020ed <iscons>:
{
  8020ed:	55                   	push   %ebp
  8020ee:	89 e5                	mov    %esp,%ebp
  8020f0:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020f6:	50                   	push   %eax
  8020f7:	ff 75 08             	pushl  0x8(%ebp)
  8020fa:	e8 34 f4 ff ff       	call   801533 <fd_lookup>
  8020ff:	83 c4 10             	add    $0x10,%esp
  802102:	85 c0                	test   %eax,%eax
  802104:	78 11                	js     802117 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  802106:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802109:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80210f:	39 10                	cmp    %edx,(%eax)
  802111:	0f 94 c0             	sete   %al
  802114:	0f b6 c0             	movzbl %al,%eax
}
  802117:	c9                   	leave  
  802118:	c3                   	ret    

00802119 <opencons>:
{
  802119:	55                   	push   %ebp
  80211a:	89 e5                	mov    %esp,%ebp
  80211c:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80211f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802122:	50                   	push   %eax
  802123:	e8 bc f3 ff ff       	call   8014e4 <fd_alloc>
  802128:	83 c4 10             	add    $0x10,%esp
  80212b:	85 c0                	test   %eax,%eax
  80212d:	78 3a                	js     802169 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80212f:	83 ec 04             	sub    $0x4,%esp
  802132:	68 07 04 00 00       	push   $0x407
  802137:	ff 75 f4             	pushl  -0xc(%ebp)
  80213a:	6a 00                	push   $0x0
  80213c:	e8 97 f0 ff ff       	call   8011d8 <sys_page_alloc>
  802141:	83 c4 10             	add    $0x10,%esp
  802144:	85 c0                	test   %eax,%eax
  802146:	78 21                	js     802169 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  802148:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80214b:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802151:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802153:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802156:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80215d:	83 ec 0c             	sub    $0xc,%esp
  802160:	50                   	push   %eax
  802161:	e8 57 f3 ff ff       	call   8014bd <fd2num>
  802166:	83 c4 10             	add    $0x10,%esp
}
  802169:	c9                   	leave  
  80216a:	c3                   	ret    

0080216b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80216b:	55                   	push   %ebp
  80216c:	89 e5                	mov    %esp,%ebp
  80216e:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802171:	89 d0                	mov    %edx,%eax
  802173:	c1 e8 16             	shr    $0x16,%eax
  802176:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80217d:	b8 00 00 00 00       	mov    $0x0,%eax
	if (!(uvpd[PDX(v)] & PTE_P))
  802182:	f6 c1 01             	test   $0x1,%cl
  802185:	74 1d                	je     8021a4 <pageref+0x39>
	pte = uvpt[PGNUM(v)];
  802187:	c1 ea 0c             	shr    $0xc,%edx
  80218a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802191:	f6 c2 01             	test   $0x1,%dl
  802194:	74 0e                	je     8021a4 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802196:	c1 ea 0c             	shr    $0xc,%edx
  802199:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8021a0:	ef 
  8021a1:	0f b7 c0             	movzwl %ax,%eax
}
  8021a4:	5d                   	pop    %ebp
  8021a5:	c3                   	ret    
  8021a6:	66 90                	xchg   %ax,%ax
  8021a8:	66 90                	xchg   %ax,%ax
  8021aa:	66 90                	xchg   %ax,%ax
  8021ac:	66 90                	xchg   %ax,%ax
  8021ae:	66 90                	xchg   %ax,%ax

008021b0 <__udivdi3>:
  8021b0:	55                   	push   %ebp
  8021b1:	57                   	push   %edi
  8021b2:	56                   	push   %esi
  8021b3:	53                   	push   %ebx
  8021b4:	83 ec 1c             	sub    $0x1c,%esp
  8021b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021bb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8021bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021c3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8021c7:	85 d2                	test   %edx,%edx
  8021c9:	75 35                	jne    802200 <__udivdi3+0x50>
  8021cb:	39 f3                	cmp    %esi,%ebx
  8021cd:	0f 87 bd 00 00 00    	ja     802290 <__udivdi3+0xe0>
  8021d3:	85 db                	test   %ebx,%ebx
  8021d5:	89 d9                	mov    %ebx,%ecx
  8021d7:	75 0b                	jne    8021e4 <__udivdi3+0x34>
  8021d9:	b8 01 00 00 00       	mov    $0x1,%eax
  8021de:	31 d2                	xor    %edx,%edx
  8021e0:	f7 f3                	div    %ebx
  8021e2:	89 c1                	mov    %eax,%ecx
  8021e4:	31 d2                	xor    %edx,%edx
  8021e6:	89 f0                	mov    %esi,%eax
  8021e8:	f7 f1                	div    %ecx
  8021ea:	89 c6                	mov    %eax,%esi
  8021ec:	89 e8                	mov    %ebp,%eax
  8021ee:	89 f7                	mov    %esi,%edi
  8021f0:	f7 f1                	div    %ecx
  8021f2:	89 fa                	mov    %edi,%edx
  8021f4:	83 c4 1c             	add    $0x1c,%esp
  8021f7:	5b                   	pop    %ebx
  8021f8:	5e                   	pop    %esi
  8021f9:	5f                   	pop    %edi
  8021fa:	5d                   	pop    %ebp
  8021fb:	c3                   	ret    
  8021fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802200:	39 f2                	cmp    %esi,%edx
  802202:	77 7c                	ja     802280 <__udivdi3+0xd0>
  802204:	0f bd fa             	bsr    %edx,%edi
  802207:	83 f7 1f             	xor    $0x1f,%edi
  80220a:	0f 84 98 00 00 00    	je     8022a8 <__udivdi3+0xf8>
  802210:	89 f9                	mov    %edi,%ecx
  802212:	b8 20 00 00 00       	mov    $0x20,%eax
  802217:	29 f8                	sub    %edi,%eax
  802219:	d3 e2                	shl    %cl,%edx
  80221b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80221f:	89 c1                	mov    %eax,%ecx
  802221:	89 da                	mov    %ebx,%edx
  802223:	d3 ea                	shr    %cl,%edx
  802225:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802229:	09 d1                	or     %edx,%ecx
  80222b:	89 f2                	mov    %esi,%edx
  80222d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802231:	89 f9                	mov    %edi,%ecx
  802233:	d3 e3                	shl    %cl,%ebx
  802235:	89 c1                	mov    %eax,%ecx
  802237:	d3 ea                	shr    %cl,%edx
  802239:	89 f9                	mov    %edi,%ecx
  80223b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80223f:	d3 e6                	shl    %cl,%esi
  802241:	89 eb                	mov    %ebp,%ebx
  802243:	89 c1                	mov    %eax,%ecx
  802245:	d3 eb                	shr    %cl,%ebx
  802247:	09 de                	or     %ebx,%esi
  802249:	89 f0                	mov    %esi,%eax
  80224b:	f7 74 24 08          	divl   0x8(%esp)
  80224f:	89 d6                	mov    %edx,%esi
  802251:	89 c3                	mov    %eax,%ebx
  802253:	f7 64 24 0c          	mull   0xc(%esp)
  802257:	39 d6                	cmp    %edx,%esi
  802259:	72 0c                	jb     802267 <__udivdi3+0xb7>
  80225b:	89 f9                	mov    %edi,%ecx
  80225d:	d3 e5                	shl    %cl,%ebp
  80225f:	39 c5                	cmp    %eax,%ebp
  802261:	73 5d                	jae    8022c0 <__udivdi3+0x110>
  802263:	39 d6                	cmp    %edx,%esi
  802265:	75 59                	jne    8022c0 <__udivdi3+0x110>
  802267:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80226a:	31 ff                	xor    %edi,%edi
  80226c:	89 fa                	mov    %edi,%edx
  80226e:	83 c4 1c             	add    $0x1c,%esp
  802271:	5b                   	pop    %ebx
  802272:	5e                   	pop    %esi
  802273:	5f                   	pop    %edi
  802274:	5d                   	pop    %ebp
  802275:	c3                   	ret    
  802276:	8d 76 00             	lea    0x0(%esi),%esi
  802279:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802280:	31 ff                	xor    %edi,%edi
  802282:	31 c0                	xor    %eax,%eax
  802284:	89 fa                	mov    %edi,%edx
  802286:	83 c4 1c             	add    $0x1c,%esp
  802289:	5b                   	pop    %ebx
  80228a:	5e                   	pop    %esi
  80228b:	5f                   	pop    %edi
  80228c:	5d                   	pop    %ebp
  80228d:	c3                   	ret    
  80228e:	66 90                	xchg   %ax,%ax
  802290:	31 ff                	xor    %edi,%edi
  802292:	89 e8                	mov    %ebp,%eax
  802294:	89 f2                	mov    %esi,%edx
  802296:	f7 f3                	div    %ebx
  802298:	89 fa                	mov    %edi,%edx
  80229a:	83 c4 1c             	add    $0x1c,%esp
  80229d:	5b                   	pop    %ebx
  80229e:	5e                   	pop    %esi
  80229f:	5f                   	pop    %edi
  8022a0:	5d                   	pop    %ebp
  8022a1:	c3                   	ret    
  8022a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022a8:	39 f2                	cmp    %esi,%edx
  8022aa:	72 06                	jb     8022b2 <__udivdi3+0x102>
  8022ac:	31 c0                	xor    %eax,%eax
  8022ae:	39 eb                	cmp    %ebp,%ebx
  8022b0:	77 d2                	ja     802284 <__udivdi3+0xd4>
  8022b2:	b8 01 00 00 00       	mov    $0x1,%eax
  8022b7:	eb cb                	jmp    802284 <__udivdi3+0xd4>
  8022b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022c0:	89 d8                	mov    %ebx,%eax
  8022c2:	31 ff                	xor    %edi,%edi
  8022c4:	eb be                	jmp    802284 <__udivdi3+0xd4>
  8022c6:	66 90                	xchg   %ax,%ax
  8022c8:	66 90                	xchg   %ax,%ax
  8022ca:	66 90                	xchg   %ax,%ax
  8022cc:	66 90                	xchg   %ax,%ax
  8022ce:	66 90                	xchg   %ax,%ax

008022d0 <__umoddi3>:
  8022d0:	55                   	push   %ebp
  8022d1:	57                   	push   %edi
  8022d2:	56                   	push   %esi
  8022d3:	53                   	push   %ebx
  8022d4:	83 ec 1c             	sub    $0x1c,%esp
  8022d7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8022db:	8b 74 24 30          	mov    0x30(%esp),%esi
  8022df:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8022e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022e7:	85 ed                	test   %ebp,%ebp
  8022e9:	89 f0                	mov    %esi,%eax
  8022eb:	89 da                	mov    %ebx,%edx
  8022ed:	75 19                	jne    802308 <__umoddi3+0x38>
  8022ef:	39 df                	cmp    %ebx,%edi
  8022f1:	0f 86 b1 00 00 00    	jbe    8023a8 <__umoddi3+0xd8>
  8022f7:	f7 f7                	div    %edi
  8022f9:	89 d0                	mov    %edx,%eax
  8022fb:	31 d2                	xor    %edx,%edx
  8022fd:	83 c4 1c             	add    $0x1c,%esp
  802300:	5b                   	pop    %ebx
  802301:	5e                   	pop    %esi
  802302:	5f                   	pop    %edi
  802303:	5d                   	pop    %ebp
  802304:	c3                   	ret    
  802305:	8d 76 00             	lea    0x0(%esi),%esi
  802308:	39 dd                	cmp    %ebx,%ebp
  80230a:	77 f1                	ja     8022fd <__umoddi3+0x2d>
  80230c:	0f bd cd             	bsr    %ebp,%ecx
  80230f:	83 f1 1f             	xor    $0x1f,%ecx
  802312:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802316:	0f 84 b4 00 00 00    	je     8023d0 <__umoddi3+0x100>
  80231c:	b8 20 00 00 00       	mov    $0x20,%eax
  802321:	89 c2                	mov    %eax,%edx
  802323:	8b 44 24 04          	mov    0x4(%esp),%eax
  802327:	29 c2                	sub    %eax,%edx
  802329:	89 c1                	mov    %eax,%ecx
  80232b:	89 f8                	mov    %edi,%eax
  80232d:	d3 e5                	shl    %cl,%ebp
  80232f:	89 d1                	mov    %edx,%ecx
  802331:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802335:	d3 e8                	shr    %cl,%eax
  802337:	09 c5                	or     %eax,%ebp
  802339:	8b 44 24 04          	mov    0x4(%esp),%eax
  80233d:	89 c1                	mov    %eax,%ecx
  80233f:	d3 e7                	shl    %cl,%edi
  802341:	89 d1                	mov    %edx,%ecx
  802343:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802347:	89 df                	mov    %ebx,%edi
  802349:	d3 ef                	shr    %cl,%edi
  80234b:	89 c1                	mov    %eax,%ecx
  80234d:	89 f0                	mov    %esi,%eax
  80234f:	d3 e3                	shl    %cl,%ebx
  802351:	89 d1                	mov    %edx,%ecx
  802353:	89 fa                	mov    %edi,%edx
  802355:	d3 e8                	shr    %cl,%eax
  802357:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80235c:	09 d8                	or     %ebx,%eax
  80235e:	f7 f5                	div    %ebp
  802360:	d3 e6                	shl    %cl,%esi
  802362:	89 d1                	mov    %edx,%ecx
  802364:	f7 64 24 08          	mull   0x8(%esp)
  802368:	39 d1                	cmp    %edx,%ecx
  80236a:	89 c3                	mov    %eax,%ebx
  80236c:	89 d7                	mov    %edx,%edi
  80236e:	72 06                	jb     802376 <__umoddi3+0xa6>
  802370:	75 0e                	jne    802380 <__umoddi3+0xb0>
  802372:	39 c6                	cmp    %eax,%esi
  802374:	73 0a                	jae    802380 <__umoddi3+0xb0>
  802376:	2b 44 24 08          	sub    0x8(%esp),%eax
  80237a:	19 ea                	sbb    %ebp,%edx
  80237c:	89 d7                	mov    %edx,%edi
  80237e:	89 c3                	mov    %eax,%ebx
  802380:	89 ca                	mov    %ecx,%edx
  802382:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  802387:	29 de                	sub    %ebx,%esi
  802389:	19 fa                	sbb    %edi,%edx
  80238b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80238f:	89 d0                	mov    %edx,%eax
  802391:	d3 e0                	shl    %cl,%eax
  802393:	89 d9                	mov    %ebx,%ecx
  802395:	d3 ee                	shr    %cl,%esi
  802397:	d3 ea                	shr    %cl,%edx
  802399:	09 f0                	or     %esi,%eax
  80239b:	83 c4 1c             	add    $0x1c,%esp
  80239e:	5b                   	pop    %ebx
  80239f:	5e                   	pop    %esi
  8023a0:	5f                   	pop    %edi
  8023a1:	5d                   	pop    %ebp
  8023a2:	c3                   	ret    
  8023a3:	90                   	nop
  8023a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023a8:	85 ff                	test   %edi,%edi
  8023aa:	89 f9                	mov    %edi,%ecx
  8023ac:	75 0b                	jne    8023b9 <__umoddi3+0xe9>
  8023ae:	b8 01 00 00 00       	mov    $0x1,%eax
  8023b3:	31 d2                	xor    %edx,%edx
  8023b5:	f7 f7                	div    %edi
  8023b7:	89 c1                	mov    %eax,%ecx
  8023b9:	89 d8                	mov    %ebx,%eax
  8023bb:	31 d2                	xor    %edx,%edx
  8023bd:	f7 f1                	div    %ecx
  8023bf:	89 f0                	mov    %esi,%eax
  8023c1:	f7 f1                	div    %ecx
  8023c3:	e9 31 ff ff ff       	jmp    8022f9 <__umoddi3+0x29>
  8023c8:	90                   	nop
  8023c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023d0:	39 dd                	cmp    %ebx,%ebp
  8023d2:	72 08                	jb     8023dc <__umoddi3+0x10c>
  8023d4:	39 f7                	cmp    %esi,%edi
  8023d6:	0f 87 21 ff ff ff    	ja     8022fd <__umoddi3+0x2d>
  8023dc:	89 da                	mov    %ebx,%edx
  8023de:	89 f0                	mov    %esi,%eax
  8023e0:	29 f8                	sub    %edi,%eax
  8023e2:	19 ea                	sbb    %ebp,%edx
  8023e4:	e9 14 ff ff ff       	jmp    8022fd <__umoddi3+0x2d>
