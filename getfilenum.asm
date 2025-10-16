
user/_getfilenum:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <openFive>:
int fd2=0;
int fd3=0;
int fd4=0;
int fd5=0;
void openFive()
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
fd1 = open("gfilenumtest1", O_CREATE|O_WRONLY);
   8:	20100593          	li	a1,513
   c:	00001517          	auipc	a0,0x1
  10:	a0450513          	addi	a0,a0,-1532 # a10 <malloc+0xfe>
  14:	462000ef          	jal	476 <open>
  18:	00002797          	auipc	a5,0x2
  1c:	fea7ac23          	sw	a0,-8(a5) # 2010 <fd1>
fd2 = open("gfilenumtest2", O_CREATE|O_WRONLY);
  20:	20100593          	li	a1,513
  24:	00001517          	auipc	a0,0x1
  28:	9fc50513          	addi	a0,a0,-1540 # a20 <malloc+0x10e>
  2c:	44a000ef          	jal	476 <open>
  30:	00002797          	auipc	a5,0x2
  34:	fca7ae23          	sw	a0,-36(a5) # 200c <fd2>
fd3 = open("gfilenumtest3", O_CREATE|O_WRONLY);
  38:	20100593          	li	a1,513
  3c:	00001517          	auipc	a0,0x1
  40:	9f450513          	addi	a0,a0,-1548 # a30 <malloc+0x11e>
  44:	432000ef          	jal	476 <open>
  48:	00002797          	auipc	a5,0x2
  4c:	fca7a023          	sw	a0,-64(a5) # 2008 <fd3>
fd4 = open("gfilenumtest4", O_CREATE|O_WRONLY);
  50:	20100593          	li	a1,513
  54:	00001517          	auipc	a0,0x1
  58:	9ec50513          	addi	a0,a0,-1556 # a40 <malloc+0x12e>
  5c:	41a000ef          	jal	476 <open>
  60:	00002797          	auipc	a5,0x2
  64:	faa7a223          	sw	a0,-92(a5) # 2004 <fd4>
fd5 = open("gfilenumtest5", O_CREATE|O_WRONLY);
  68:	20100593          	li	a1,513
  6c:	00001517          	auipc	a0,0x1
  70:	9e450513          	addi	a0,a0,-1564 # a50 <malloc+0x13e>
  74:	402000ef          	jal	476 <open>
  78:	00002797          	auipc	a5,0x2
  7c:	f8a7a423          	sw	a0,-120(a5) # 2000 <fd5>
}
  80:	60a2                	ld	ra,8(sp)
  82:	6402                	ld	s0,0(sp)
  84:	0141                	addi	sp,sp,16
  86:	8082                	ret

0000000000000088 <main>:
int
main(int argc, char **argv)
{
  88:	1101                	addi	sp,sp,-32
  8a:	ec06                	sd	ra,24(sp)
  8c:	e822                	sd	s0,16(sp)
  8e:	e426                	sd	s1,8(sp)
  90:	e04a                	sd	s2,0(sp)
  92:	1000                	addi	s0,sp,32
int pid = getpid();
  94:	422000ef          	jal	4b6 <getpid>
  98:	84aa                	mv	s1,a0
printf("files open for %d\n:",pid);
  9a:	85aa                	mv	a1,a0
  9c:	00001517          	auipc	a0,0x1
  a0:	9c450513          	addi	a0,a0,-1596 # a60 <malloc+0x14e>
  a4:	7ba000ef          	jal	85e <printf>
printf("before opening any additional: %d (should be 3)\n",getfilenum(pid));
  a8:	8526                	mv	a0,s1
  aa:	37c000ef          	jal	426 <getfilenum>
  ae:	85aa                	mv	a1,a0
  b0:	00001517          	auipc	a0,0x1
  b4:	9c850513          	addi	a0,a0,-1592 # a78 <malloc+0x166>
  b8:	7a6000ef          	jal	85e <printf>
openFive();
  bc:	f45ff0ef          	jal	0 <openFive>
printf("opened 5: %d (should be 8)\n",getfilenum(pid));
  c0:	8526                	mv	a0,s1
  c2:	364000ef          	jal	426 <getfilenum>
  c6:	85aa                	mv	a1,a0
  c8:	00001517          	auipc	a0,0x1
  cc:	9e850513          	addi	a0,a0,-1560 # ab0 <malloc+0x19e>
  d0:	78e000ef          	jal	85e <printf>
close(fd3);
  d4:	00002517          	auipc	a0,0x2
  d8:	f3452503          	lw	a0,-204(a0) # 2008 <fd3>
  dc:	382000ef          	jal	45e <close>
printf("closed 1: %d (should be 7)\n",getfilenum(pid));
  e0:	8526                	mv	a0,s1
  e2:	344000ef          	jal	426 <getfilenum>
  e6:	85aa                	mv	a1,a0
  e8:	00001517          	auipc	a0,0x1
  ec:	9e850513          	addi	a0,a0,-1560 # ad0 <malloc+0x1be>
  f0:	76e000ef          	jal	85e <printf>
close(fd1);
  f4:	00002517          	auipc	a0,0x2
  f8:	f1c52503          	lw	a0,-228(a0) # 2010 <fd1>
  fc:	362000ef          	jal	45e <close>
printf("closed another: %d (should be 6)\n",getfilenum(pid));
 100:	8526                	mv	a0,s1
 102:	324000ef          	jal	426 <getfilenum>
 106:	85aa                	mv	a1,a0
 108:	00001517          	auipc	a0,0x1
 10c:	9e850513          	addi	a0,a0,-1560 # af0 <malloc+0x1de>
 110:	74e000ef          	jal	85e <printf>
close(fd5);
 114:	00002917          	auipc	s2,0x2
 118:	eec90913          	addi	s2,s2,-276 # 2000 <fd5>
 11c:	00092503          	lw	a0,0(s2)
 120:	33e000ef          	jal	45e <close>
printf("closed another: %d (should be 5)\n",getfilenum(pid));
 124:	8526                	mv	a0,s1
 126:	300000ef          	jal	426 <getfilenum>
 12a:	85aa                	mv	a1,a0
 12c:	00001517          	auipc	a0,0x1
 130:	9ec50513          	addi	a0,a0,-1556 # b18 <malloc+0x206>
 134:	72a000ef          	jal	85e <printf>
fd5 = open("gfilenmumtest6", O_CREATE|O_WRONLY);
 138:	20100593          	li	a1,513
 13c:	00001517          	auipc	a0,0x1
 140:	a0450513          	addi	a0,a0,-1532 # b40 <malloc+0x22e>
 144:	332000ef          	jal	476 <open>
 148:	00a92023          	sw	a0,0(s2)
printf("opened 1: %d (should be 6)\n",getfilenum(pid));
 14c:	8526                	mv	a0,s1
 14e:	2d8000ef          	jal	426 <getfilenum>
 152:	85aa                	mv	a1,a0
 154:	00001517          	auipc	a0,0x1
 158:	9fc50513          	addi	a0,a0,-1540 # b50 <malloc+0x23e>
 15c:	702000ef          	jal	85e <printf>
close(fd5);
 160:	00092503          	lw	a0,0(s2)
 164:	2fa000ef          	jal	45e <close>
close(fd2);
 168:	00002517          	auipc	a0,0x2
 16c:	ea452503          	lw	a0,-348(a0) # 200c <fd2>
 170:	2ee000ef          	jal	45e <close>
close(fd4);
 174:	00002517          	auipc	a0,0x2
 178:	e9052503          	lw	a0,-368(a0) # 2004 <fd4>
 17c:	2e2000ef          	jal	45e <close>
printf("closed all: %d (should be 3)\n",getfilenum(pid));
 180:	8526                	mv	a0,s1
 182:	2a4000ef          	jal	426 <getfilenum>
 186:	85aa                	mv	a1,a0
 188:	00001517          	auipc	a0,0x1
 18c:	9e850513          	addi	a0,a0,-1560 # b70 <malloc+0x25e>
 190:	6ce000ef          	jal	85e <printf>
exit(0);
 194:	4501                	li	a0,0
 196:	2a0000ef          	jal	436 <exit>

000000000000019a <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 19a:	1141                	addi	sp,sp,-16
 19c:	e406                	sd	ra,8(sp)
 19e:	e022                	sd	s0,0(sp)
 1a0:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 1a2:	ee7ff0ef          	jal	88 <main>
  exit(r);
 1a6:	290000ef          	jal	436 <exit>

00000000000001aa <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 1aa:	1141                	addi	sp,sp,-16
 1ac:	e422                	sd	s0,8(sp)
 1ae:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1b0:	87aa                	mv	a5,a0
 1b2:	0585                	addi	a1,a1,1
 1b4:	0785                	addi	a5,a5,1
 1b6:	fff5c703          	lbu	a4,-1(a1)
 1ba:	fee78fa3          	sb	a4,-1(a5)
 1be:	fb75                	bnez	a4,1b2 <strcpy+0x8>
    ;
  return os;
}
 1c0:	6422                	ld	s0,8(sp)
 1c2:	0141                	addi	sp,sp,16
 1c4:	8082                	ret

00000000000001c6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1c6:	1141                	addi	sp,sp,-16
 1c8:	e422                	sd	s0,8(sp)
 1ca:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1cc:	00054783          	lbu	a5,0(a0)
 1d0:	cb91                	beqz	a5,1e4 <strcmp+0x1e>
 1d2:	0005c703          	lbu	a4,0(a1)
 1d6:	00f71763          	bne	a4,a5,1e4 <strcmp+0x1e>
    p++, q++;
 1da:	0505                	addi	a0,a0,1
 1dc:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1de:	00054783          	lbu	a5,0(a0)
 1e2:	fbe5                	bnez	a5,1d2 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1e4:	0005c503          	lbu	a0,0(a1)
}
 1e8:	40a7853b          	subw	a0,a5,a0
 1ec:	6422                	ld	s0,8(sp)
 1ee:	0141                	addi	sp,sp,16
 1f0:	8082                	ret

00000000000001f2 <strlen>:

uint
strlen(const char *s)
{
 1f2:	1141                	addi	sp,sp,-16
 1f4:	e422                	sd	s0,8(sp)
 1f6:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1f8:	00054783          	lbu	a5,0(a0)
 1fc:	cf91                	beqz	a5,218 <strlen+0x26>
 1fe:	0505                	addi	a0,a0,1
 200:	87aa                	mv	a5,a0
 202:	86be                	mv	a3,a5
 204:	0785                	addi	a5,a5,1
 206:	fff7c703          	lbu	a4,-1(a5)
 20a:	ff65                	bnez	a4,202 <strlen+0x10>
 20c:	40a6853b          	subw	a0,a3,a0
 210:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 212:	6422                	ld	s0,8(sp)
 214:	0141                	addi	sp,sp,16
 216:	8082                	ret
  for(n = 0; s[n]; n++)
 218:	4501                	li	a0,0
 21a:	bfe5                	j	212 <strlen+0x20>

000000000000021c <memset>:

void*
memset(void *dst, int c, uint n)
{
 21c:	1141                	addi	sp,sp,-16
 21e:	e422                	sd	s0,8(sp)
 220:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 222:	ca19                	beqz	a2,238 <memset+0x1c>
 224:	87aa                	mv	a5,a0
 226:	1602                	slli	a2,a2,0x20
 228:	9201                	srli	a2,a2,0x20
 22a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 22e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 232:	0785                	addi	a5,a5,1
 234:	fee79de3          	bne	a5,a4,22e <memset+0x12>
  }
  return dst;
}
 238:	6422                	ld	s0,8(sp)
 23a:	0141                	addi	sp,sp,16
 23c:	8082                	ret

000000000000023e <strchr>:

char*
strchr(const char *s, char c)
{
 23e:	1141                	addi	sp,sp,-16
 240:	e422                	sd	s0,8(sp)
 242:	0800                	addi	s0,sp,16
  for(; *s; s++)
 244:	00054783          	lbu	a5,0(a0)
 248:	cb99                	beqz	a5,25e <strchr+0x20>
    if(*s == c)
 24a:	00f58763          	beq	a1,a5,258 <strchr+0x1a>
  for(; *s; s++)
 24e:	0505                	addi	a0,a0,1
 250:	00054783          	lbu	a5,0(a0)
 254:	fbfd                	bnez	a5,24a <strchr+0xc>
      return (char*)s;
  return 0;
 256:	4501                	li	a0,0
}
 258:	6422                	ld	s0,8(sp)
 25a:	0141                	addi	sp,sp,16
 25c:	8082                	ret
  return 0;
 25e:	4501                	li	a0,0
 260:	bfe5                	j	258 <strchr+0x1a>

0000000000000262 <gets>:

char*
gets(char *buf, int max)
{
 262:	711d                	addi	sp,sp,-96
 264:	ec86                	sd	ra,88(sp)
 266:	e8a2                	sd	s0,80(sp)
 268:	e4a6                	sd	s1,72(sp)
 26a:	e0ca                	sd	s2,64(sp)
 26c:	fc4e                	sd	s3,56(sp)
 26e:	f852                	sd	s4,48(sp)
 270:	f456                	sd	s5,40(sp)
 272:	f05a                	sd	s6,32(sp)
 274:	ec5e                	sd	s7,24(sp)
 276:	1080                	addi	s0,sp,96
 278:	8baa                	mv	s7,a0
 27a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 27c:	892a                	mv	s2,a0
 27e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 280:	4aa9                	li	s5,10
 282:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 284:	89a6                	mv	s3,s1
 286:	2485                	addiw	s1,s1,1
 288:	0344d663          	bge	s1,s4,2b4 <gets+0x52>
    cc = read(0, &c, 1);
 28c:	4605                	li	a2,1
 28e:	faf40593          	addi	a1,s0,-81
 292:	4501                	li	a0,0
 294:	1ba000ef          	jal	44e <read>
    if(cc < 1)
 298:	00a05e63          	blez	a0,2b4 <gets+0x52>
    buf[i++] = c;
 29c:	faf44783          	lbu	a5,-81(s0)
 2a0:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2a4:	01578763          	beq	a5,s5,2b2 <gets+0x50>
 2a8:	0905                	addi	s2,s2,1
 2aa:	fd679de3          	bne	a5,s6,284 <gets+0x22>
    buf[i++] = c;
 2ae:	89a6                	mv	s3,s1
 2b0:	a011                	j	2b4 <gets+0x52>
 2b2:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2b4:	99de                	add	s3,s3,s7
 2b6:	00098023          	sb	zero,0(s3)
  return buf;
}
 2ba:	855e                	mv	a0,s7
 2bc:	60e6                	ld	ra,88(sp)
 2be:	6446                	ld	s0,80(sp)
 2c0:	64a6                	ld	s1,72(sp)
 2c2:	6906                	ld	s2,64(sp)
 2c4:	79e2                	ld	s3,56(sp)
 2c6:	7a42                	ld	s4,48(sp)
 2c8:	7aa2                	ld	s5,40(sp)
 2ca:	7b02                	ld	s6,32(sp)
 2cc:	6be2                	ld	s7,24(sp)
 2ce:	6125                	addi	sp,sp,96
 2d0:	8082                	ret

00000000000002d2 <stat>:

int
stat(const char *n, struct stat *st)
{
 2d2:	1101                	addi	sp,sp,-32
 2d4:	ec06                	sd	ra,24(sp)
 2d6:	e822                	sd	s0,16(sp)
 2d8:	e04a                	sd	s2,0(sp)
 2da:	1000                	addi	s0,sp,32
 2dc:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2de:	4581                	li	a1,0
 2e0:	196000ef          	jal	476 <open>
  if(fd < 0)
 2e4:	02054263          	bltz	a0,308 <stat+0x36>
 2e8:	e426                	sd	s1,8(sp)
 2ea:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2ec:	85ca                	mv	a1,s2
 2ee:	1a0000ef          	jal	48e <fstat>
 2f2:	892a                	mv	s2,a0
  close(fd);
 2f4:	8526                	mv	a0,s1
 2f6:	168000ef          	jal	45e <close>
  return r;
 2fa:	64a2                	ld	s1,8(sp)
}
 2fc:	854a                	mv	a0,s2
 2fe:	60e2                	ld	ra,24(sp)
 300:	6442                	ld	s0,16(sp)
 302:	6902                	ld	s2,0(sp)
 304:	6105                	addi	sp,sp,32
 306:	8082                	ret
    return -1;
 308:	597d                	li	s2,-1
 30a:	bfcd                	j	2fc <stat+0x2a>

000000000000030c <atoi>:

int
atoi(const char *s)
{
 30c:	1141                	addi	sp,sp,-16
 30e:	e422                	sd	s0,8(sp)
 310:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 312:	00054683          	lbu	a3,0(a0)
 316:	fd06879b          	addiw	a5,a3,-48
 31a:	0ff7f793          	zext.b	a5,a5
 31e:	4625                	li	a2,9
 320:	02f66863          	bltu	a2,a5,350 <atoi+0x44>
 324:	872a                	mv	a4,a0
  n = 0;
 326:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 328:	0705                	addi	a4,a4,1
 32a:	0025179b          	slliw	a5,a0,0x2
 32e:	9fa9                	addw	a5,a5,a0
 330:	0017979b          	slliw	a5,a5,0x1
 334:	9fb5                	addw	a5,a5,a3
 336:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 33a:	00074683          	lbu	a3,0(a4)
 33e:	fd06879b          	addiw	a5,a3,-48
 342:	0ff7f793          	zext.b	a5,a5
 346:	fef671e3          	bgeu	a2,a5,328 <atoi+0x1c>
  return n;
}
 34a:	6422                	ld	s0,8(sp)
 34c:	0141                	addi	sp,sp,16
 34e:	8082                	ret
  n = 0;
 350:	4501                	li	a0,0
 352:	bfe5                	j	34a <atoi+0x3e>

0000000000000354 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 354:	1141                	addi	sp,sp,-16
 356:	e422                	sd	s0,8(sp)
 358:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 35a:	02b57463          	bgeu	a0,a1,382 <memmove+0x2e>
    while(n-- > 0)
 35e:	00c05f63          	blez	a2,37c <memmove+0x28>
 362:	1602                	slli	a2,a2,0x20
 364:	9201                	srli	a2,a2,0x20
 366:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 36a:	872a                	mv	a4,a0
      *dst++ = *src++;
 36c:	0585                	addi	a1,a1,1
 36e:	0705                	addi	a4,a4,1
 370:	fff5c683          	lbu	a3,-1(a1)
 374:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 378:	fef71ae3          	bne	a4,a5,36c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 37c:	6422                	ld	s0,8(sp)
 37e:	0141                	addi	sp,sp,16
 380:	8082                	ret
    dst += n;
 382:	00c50733          	add	a4,a0,a2
    src += n;
 386:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 388:	fec05ae3          	blez	a2,37c <memmove+0x28>
 38c:	fff6079b          	addiw	a5,a2,-1
 390:	1782                	slli	a5,a5,0x20
 392:	9381                	srli	a5,a5,0x20
 394:	fff7c793          	not	a5,a5
 398:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 39a:	15fd                	addi	a1,a1,-1
 39c:	177d                	addi	a4,a4,-1
 39e:	0005c683          	lbu	a3,0(a1)
 3a2:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3a6:	fee79ae3          	bne	a5,a4,39a <memmove+0x46>
 3aa:	bfc9                	j	37c <memmove+0x28>

00000000000003ac <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3ac:	1141                	addi	sp,sp,-16
 3ae:	e422                	sd	s0,8(sp)
 3b0:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3b2:	ca05                	beqz	a2,3e2 <memcmp+0x36>
 3b4:	fff6069b          	addiw	a3,a2,-1
 3b8:	1682                	slli	a3,a3,0x20
 3ba:	9281                	srli	a3,a3,0x20
 3bc:	0685                	addi	a3,a3,1
 3be:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3c0:	00054783          	lbu	a5,0(a0)
 3c4:	0005c703          	lbu	a4,0(a1)
 3c8:	00e79863          	bne	a5,a4,3d8 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3cc:	0505                	addi	a0,a0,1
    p2++;
 3ce:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3d0:	fed518e3          	bne	a0,a3,3c0 <memcmp+0x14>
  }
  return 0;
 3d4:	4501                	li	a0,0
 3d6:	a019                	j	3dc <memcmp+0x30>
      return *p1 - *p2;
 3d8:	40e7853b          	subw	a0,a5,a4
}
 3dc:	6422                	ld	s0,8(sp)
 3de:	0141                	addi	sp,sp,16
 3e0:	8082                	ret
  return 0;
 3e2:	4501                	li	a0,0
 3e4:	bfe5                	j	3dc <memcmp+0x30>

00000000000003e6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3e6:	1141                	addi	sp,sp,-16
 3e8:	e406                	sd	ra,8(sp)
 3ea:	e022                	sd	s0,0(sp)
 3ec:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3ee:	f67ff0ef          	jal	354 <memmove>
}
 3f2:	60a2                	ld	ra,8(sp)
 3f4:	6402                	ld	s0,0(sp)
 3f6:	0141                	addi	sp,sp,16
 3f8:	8082                	ret

00000000000003fa <sbrk>:

char *
sbrk(int n) {
 3fa:	1141                	addi	sp,sp,-16
 3fc:	e406                	sd	ra,8(sp)
 3fe:	e022                	sd	s0,0(sp)
 400:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 402:	4585                	li	a1,1
 404:	0ba000ef          	jal	4be <sys_sbrk>
}
 408:	60a2                	ld	ra,8(sp)
 40a:	6402                	ld	s0,0(sp)
 40c:	0141                	addi	sp,sp,16
 40e:	8082                	ret

0000000000000410 <sbrklazy>:

char *
sbrklazy(int n) {
 410:	1141                	addi	sp,sp,-16
 412:	e406                	sd	ra,8(sp)
 414:	e022                	sd	s0,0(sp)
 416:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 418:	4589                	li	a1,2
 41a:	0a4000ef          	jal	4be <sys_sbrk>
}
 41e:	60a2                	ld	ra,8(sp)
 420:	6402                	ld	s0,0(sp)
 422:	0141                	addi	sp,sp,16
 424:	8082                	ret

0000000000000426 <getfilenum>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global getfilenum
getfilenum:
 li a7, SYS_getfilenum
 426:	48dd                	li	a7,23
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <fork>:
.global fork
fork:
 li a7, SYS_fork
 42e:	4885                	li	a7,1
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <exit>:
.global exit
exit:
 li a7, SYS_exit
 436:	4889                	li	a7,2
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <wait>:
.global wait
wait:
 li a7, SYS_wait
 43e:	488d                	li	a7,3
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 446:	4891                	li	a7,4
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <read>:
.global read
read:
 li a7, SYS_read
 44e:	4895                	li	a7,5
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <write>:
.global write
write:
 li a7, SYS_write
 456:	48c1                	li	a7,16
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <close>:
.global close
close:
 li a7, SYS_close
 45e:	48d5                	li	a7,21
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <kill>:
.global kill
kill:
 li a7, SYS_kill
 466:	4899                	li	a7,6
 ecall
 468:	00000073          	ecall
 ret
 46c:	8082                	ret

000000000000046e <exec>:
.global exec
exec:
 li a7, SYS_exec
 46e:	489d                	li	a7,7
 ecall
 470:	00000073          	ecall
 ret
 474:	8082                	ret

0000000000000476 <open>:
.global open
open:
 li a7, SYS_open
 476:	48bd                	li	a7,15
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 47e:	48c5                	li	a7,17
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 486:	48c9                	li	a7,18
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 48e:	48a1                	li	a7,8
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <link>:
.global link
link:
 li a7, SYS_link
 496:	48cd                	li	a7,19
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 49e:	48d1                	li	a7,20
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4a6:	48a5                	li	a7,9
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <dup>:
.global dup
dup:
 li a7, SYS_dup
 4ae:	48a9                	li	a7,10
 ecall
 4b0:	00000073          	ecall
 ret
 4b4:	8082                	ret

00000000000004b6 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4b6:	48ad                	li	a7,11
 ecall
 4b8:	00000073          	ecall
 ret
 4bc:	8082                	ret

00000000000004be <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 4be:	48b1                	li	a7,12
 ecall
 4c0:	00000073          	ecall
 ret
 4c4:	8082                	ret

00000000000004c6 <pause>:
.global pause
pause:
 li a7, SYS_pause
 4c6:	48b5                	li	a7,13
 ecall
 4c8:	00000073          	ecall
 ret
 4cc:	8082                	ret

00000000000004ce <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4ce:	48b9                	li	a7,14
 ecall
 4d0:	00000073          	ecall
 ret
 4d4:	8082                	ret

00000000000004d6 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4d6:	1101                	addi	sp,sp,-32
 4d8:	ec06                	sd	ra,24(sp)
 4da:	e822                	sd	s0,16(sp)
 4dc:	1000                	addi	s0,sp,32
 4de:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4e2:	4605                	li	a2,1
 4e4:	fef40593          	addi	a1,s0,-17
 4e8:	f6fff0ef          	jal	456 <write>
}
 4ec:	60e2                	ld	ra,24(sp)
 4ee:	6442                	ld	s0,16(sp)
 4f0:	6105                	addi	sp,sp,32
 4f2:	8082                	ret

00000000000004f4 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 4f4:	715d                	addi	sp,sp,-80
 4f6:	e486                	sd	ra,72(sp)
 4f8:	e0a2                	sd	s0,64(sp)
 4fa:	f84a                	sd	s2,48(sp)
 4fc:	0880                	addi	s0,sp,80
 4fe:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 500:	c299                	beqz	a3,506 <printint+0x12>
 502:	0805c363          	bltz	a1,588 <printint+0x94>
  neg = 0;
 506:	4881                	li	a7,0
 508:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 50c:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 50e:	00000517          	auipc	a0,0x0
 512:	68a50513          	addi	a0,a0,1674 # b98 <digits>
 516:	883e                	mv	a6,a5
 518:	2785                	addiw	a5,a5,1
 51a:	02c5f733          	remu	a4,a1,a2
 51e:	972a                	add	a4,a4,a0
 520:	00074703          	lbu	a4,0(a4)
 524:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 528:	872e                	mv	a4,a1
 52a:	02c5d5b3          	divu	a1,a1,a2
 52e:	0685                	addi	a3,a3,1
 530:	fec773e3          	bgeu	a4,a2,516 <printint+0x22>
  if(neg)
 534:	00088b63          	beqz	a7,54a <printint+0x56>
    buf[i++] = '-';
 538:	fd078793          	addi	a5,a5,-48
 53c:	97a2                	add	a5,a5,s0
 53e:	02d00713          	li	a4,45
 542:	fee78423          	sb	a4,-24(a5)
 546:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 54a:	02f05a63          	blez	a5,57e <printint+0x8a>
 54e:	fc26                	sd	s1,56(sp)
 550:	f44e                	sd	s3,40(sp)
 552:	fb840713          	addi	a4,s0,-72
 556:	00f704b3          	add	s1,a4,a5
 55a:	fff70993          	addi	s3,a4,-1
 55e:	99be                	add	s3,s3,a5
 560:	37fd                	addiw	a5,a5,-1
 562:	1782                	slli	a5,a5,0x20
 564:	9381                	srli	a5,a5,0x20
 566:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 56a:	fff4c583          	lbu	a1,-1(s1)
 56e:	854a                	mv	a0,s2
 570:	f67ff0ef          	jal	4d6 <putc>
  while(--i >= 0)
 574:	14fd                	addi	s1,s1,-1
 576:	ff349ae3          	bne	s1,s3,56a <printint+0x76>
 57a:	74e2                	ld	s1,56(sp)
 57c:	79a2                	ld	s3,40(sp)
}
 57e:	60a6                	ld	ra,72(sp)
 580:	6406                	ld	s0,64(sp)
 582:	7942                	ld	s2,48(sp)
 584:	6161                	addi	sp,sp,80
 586:	8082                	ret
    x = -xx;
 588:	40b005b3          	neg	a1,a1
    neg = 1;
 58c:	4885                	li	a7,1
    x = -xx;
 58e:	bfad                	j	508 <printint+0x14>

0000000000000590 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 590:	711d                	addi	sp,sp,-96
 592:	ec86                	sd	ra,88(sp)
 594:	e8a2                	sd	s0,80(sp)
 596:	e0ca                	sd	s2,64(sp)
 598:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 59a:	0005c903          	lbu	s2,0(a1)
 59e:	28090663          	beqz	s2,82a <vprintf+0x29a>
 5a2:	e4a6                	sd	s1,72(sp)
 5a4:	fc4e                	sd	s3,56(sp)
 5a6:	f852                	sd	s4,48(sp)
 5a8:	f456                	sd	s5,40(sp)
 5aa:	f05a                	sd	s6,32(sp)
 5ac:	ec5e                	sd	s7,24(sp)
 5ae:	e862                	sd	s8,16(sp)
 5b0:	e466                	sd	s9,8(sp)
 5b2:	8b2a                	mv	s6,a0
 5b4:	8a2e                	mv	s4,a1
 5b6:	8bb2                	mv	s7,a2
  state = 0;
 5b8:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 5ba:	4481                	li	s1,0
 5bc:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 5be:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 5c2:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 5c6:	06c00c93          	li	s9,108
 5ca:	a005                	j	5ea <vprintf+0x5a>
        putc(fd, c0);
 5cc:	85ca                	mv	a1,s2
 5ce:	855a                	mv	a0,s6
 5d0:	f07ff0ef          	jal	4d6 <putc>
 5d4:	a019                	j	5da <vprintf+0x4a>
    } else if(state == '%'){
 5d6:	03598263          	beq	s3,s5,5fa <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 5da:	2485                	addiw	s1,s1,1
 5dc:	8726                	mv	a4,s1
 5de:	009a07b3          	add	a5,s4,s1
 5e2:	0007c903          	lbu	s2,0(a5)
 5e6:	22090a63          	beqz	s2,81a <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 5ea:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5ee:	fe0994e3          	bnez	s3,5d6 <vprintf+0x46>
      if(c0 == '%'){
 5f2:	fd579de3          	bne	a5,s5,5cc <vprintf+0x3c>
        state = '%';
 5f6:	89be                	mv	s3,a5
 5f8:	b7cd                	j	5da <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 5fa:	00ea06b3          	add	a3,s4,a4
 5fe:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 602:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 604:	c681                	beqz	a3,60c <vprintf+0x7c>
 606:	9752                	add	a4,a4,s4
 608:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 60c:	05878363          	beq	a5,s8,652 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 610:	05978d63          	beq	a5,s9,66a <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 614:	07500713          	li	a4,117
 618:	0ee78763          	beq	a5,a4,706 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 61c:	07800713          	li	a4,120
 620:	12e78963          	beq	a5,a4,752 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 624:	07000713          	li	a4,112
 628:	14e78e63          	beq	a5,a4,784 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 62c:	06300713          	li	a4,99
 630:	18e78e63          	beq	a5,a4,7cc <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 634:	07300713          	li	a4,115
 638:	1ae78463          	beq	a5,a4,7e0 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 63c:	02500713          	li	a4,37
 640:	04e79563          	bne	a5,a4,68a <vprintf+0xfa>
        putc(fd, '%');
 644:	02500593          	li	a1,37
 648:	855a                	mv	a0,s6
 64a:	e8dff0ef          	jal	4d6 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 64e:	4981                	li	s3,0
 650:	b769                	j	5da <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 652:	008b8913          	addi	s2,s7,8
 656:	4685                	li	a3,1
 658:	4629                	li	a2,10
 65a:	000ba583          	lw	a1,0(s7)
 65e:	855a                	mv	a0,s6
 660:	e95ff0ef          	jal	4f4 <printint>
 664:	8bca                	mv	s7,s2
      state = 0;
 666:	4981                	li	s3,0
 668:	bf8d                	j	5da <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 66a:	06400793          	li	a5,100
 66e:	02f68963          	beq	a3,a5,6a0 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 672:	06c00793          	li	a5,108
 676:	04f68263          	beq	a3,a5,6ba <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 67a:	07500793          	li	a5,117
 67e:	0af68063          	beq	a3,a5,71e <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 682:	07800793          	li	a5,120
 686:	0ef68263          	beq	a3,a5,76a <vprintf+0x1da>
        putc(fd, '%');
 68a:	02500593          	li	a1,37
 68e:	855a                	mv	a0,s6
 690:	e47ff0ef          	jal	4d6 <putc>
        putc(fd, c0);
 694:	85ca                	mv	a1,s2
 696:	855a                	mv	a0,s6
 698:	e3fff0ef          	jal	4d6 <putc>
      state = 0;
 69c:	4981                	li	s3,0
 69e:	bf35                	j	5da <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6a0:	008b8913          	addi	s2,s7,8
 6a4:	4685                	li	a3,1
 6a6:	4629                	li	a2,10
 6a8:	000bb583          	ld	a1,0(s7)
 6ac:	855a                	mv	a0,s6
 6ae:	e47ff0ef          	jal	4f4 <printint>
        i += 1;
 6b2:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 6b4:	8bca                	mv	s7,s2
      state = 0;
 6b6:	4981                	li	s3,0
        i += 1;
 6b8:	b70d                	j	5da <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6ba:	06400793          	li	a5,100
 6be:	02f60763          	beq	a2,a5,6ec <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 6c2:	07500793          	li	a5,117
 6c6:	06f60963          	beq	a2,a5,738 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 6ca:	07800793          	li	a5,120
 6ce:	faf61ee3          	bne	a2,a5,68a <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6d2:	008b8913          	addi	s2,s7,8
 6d6:	4681                	li	a3,0
 6d8:	4641                	li	a2,16
 6da:	000bb583          	ld	a1,0(s7)
 6de:	855a                	mv	a0,s6
 6e0:	e15ff0ef          	jal	4f4 <printint>
        i += 2;
 6e4:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6e6:	8bca                	mv	s7,s2
      state = 0;
 6e8:	4981                	li	s3,0
        i += 2;
 6ea:	bdc5                	j	5da <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6ec:	008b8913          	addi	s2,s7,8
 6f0:	4685                	li	a3,1
 6f2:	4629                	li	a2,10
 6f4:	000bb583          	ld	a1,0(s7)
 6f8:	855a                	mv	a0,s6
 6fa:	dfbff0ef          	jal	4f4 <printint>
        i += 2;
 6fe:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 700:	8bca                	mv	s7,s2
      state = 0;
 702:	4981                	li	s3,0
        i += 2;
 704:	bdd9                	j	5da <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 706:	008b8913          	addi	s2,s7,8
 70a:	4681                	li	a3,0
 70c:	4629                	li	a2,10
 70e:	000be583          	lwu	a1,0(s7)
 712:	855a                	mv	a0,s6
 714:	de1ff0ef          	jal	4f4 <printint>
 718:	8bca                	mv	s7,s2
      state = 0;
 71a:	4981                	li	s3,0
 71c:	bd7d                	j	5da <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 71e:	008b8913          	addi	s2,s7,8
 722:	4681                	li	a3,0
 724:	4629                	li	a2,10
 726:	000bb583          	ld	a1,0(s7)
 72a:	855a                	mv	a0,s6
 72c:	dc9ff0ef          	jal	4f4 <printint>
        i += 1;
 730:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 732:	8bca                	mv	s7,s2
      state = 0;
 734:	4981                	li	s3,0
        i += 1;
 736:	b555                	j	5da <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 738:	008b8913          	addi	s2,s7,8
 73c:	4681                	li	a3,0
 73e:	4629                	li	a2,10
 740:	000bb583          	ld	a1,0(s7)
 744:	855a                	mv	a0,s6
 746:	dafff0ef          	jal	4f4 <printint>
        i += 2;
 74a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 74c:	8bca                	mv	s7,s2
      state = 0;
 74e:	4981                	li	s3,0
        i += 2;
 750:	b569                	j	5da <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 752:	008b8913          	addi	s2,s7,8
 756:	4681                	li	a3,0
 758:	4641                	li	a2,16
 75a:	000be583          	lwu	a1,0(s7)
 75e:	855a                	mv	a0,s6
 760:	d95ff0ef          	jal	4f4 <printint>
 764:	8bca                	mv	s7,s2
      state = 0;
 766:	4981                	li	s3,0
 768:	bd8d                	j	5da <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 76a:	008b8913          	addi	s2,s7,8
 76e:	4681                	li	a3,0
 770:	4641                	li	a2,16
 772:	000bb583          	ld	a1,0(s7)
 776:	855a                	mv	a0,s6
 778:	d7dff0ef          	jal	4f4 <printint>
        i += 1;
 77c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 77e:	8bca                	mv	s7,s2
      state = 0;
 780:	4981                	li	s3,0
        i += 1;
 782:	bda1                	j	5da <vprintf+0x4a>
 784:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 786:	008b8d13          	addi	s10,s7,8
 78a:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 78e:	03000593          	li	a1,48
 792:	855a                	mv	a0,s6
 794:	d43ff0ef          	jal	4d6 <putc>
  putc(fd, 'x');
 798:	07800593          	li	a1,120
 79c:	855a                	mv	a0,s6
 79e:	d39ff0ef          	jal	4d6 <putc>
 7a2:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7a4:	00000b97          	auipc	s7,0x0
 7a8:	3f4b8b93          	addi	s7,s7,1012 # b98 <digits>
 7ac:	03c9d793          	srli	a5,s3,0x3c
 7b0:	97de                	add	a5,a5,s7
 7b2:	0007c583          	lbu	a1,0(a5)
 7b6:	855a                	mv	a0,s6
 7b8:	d1fff0ef          	jal	4d6 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7bc:	0992                	slli	s3,s3,0x4
 7be:	397d                	addiw	s2,s2,-1
 7c0:	fe0916e3          	bnez	s2,7ac <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 7c4:	8bea                	mv	s7,s10
      state = 0;
 7c6:	4981                	li	s3,0
 7c8:	6d02                	ld	s10,0(sp)
 7ca:	bd01                	j	5da <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 7cc:	008b8913          	addi	s2,s7,8
 7d0:	000bc583          	lbu	a1,0(s7)
 7d4:	855a                	mv	a0,s6
 7d6:	d01ff0ef          	jal	4d6 <putc>
 7da:	8bca                	mv	s7,s2
      state = 0;
 7dc:	4981                	li	s3,0
 7de:	bbf5                	j	5da <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 7e0:	008b8993          	addi	s3,s7,8
 7e4:	000bb903          	ld	s2,0(s7)
 7e8:	00090f63          	beqz	s2,806 <vprintf+0x276>
        for(; *s; s++)
 7ec:	00094583          	lbu	a1,0(s2)
 7f0:	c195                	beqz	a1,814 <vprintf+0x284>
          putc(fd, *s);
 7f2:	855a                	mv	a0,s6
 7f4:	ce3ff0ef          	jal	4d6 <putc>
        for(; *s; s++)
 7f8:	0905                	addi	s2,s2,1
 7fa:	00094583          	lbu	a1,0(s2)
 7fe:	f9f5                	bnez	a1,7f2 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 800:	8bce                	mv	s7,s3
      state = 0;
 802:	4981                	li	s3,0
 804:	bbd9                	j	5da <vprintf+0x4a>
          s = "(null)";
 806:	00000917          	auipc	s2,0x0
 80a:	38a90913          	addi	s2,s2,906 # b90 <malloc+0x27e>
        for(; *s; s++)
 80e:	02800593          	li	a1,40
 812:	b7c5                	j	7f2 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 814:	8bce                	mv	s7,s3
      state = 0;
 816:	4981                	li	s3,0
 818:	b3c9                	j	5da <vprintf+0x4a>
 81a:	64a6                	ld	s1,72(sp)
 81c:	79e2                	ld	s3,56(sp)
 81e:	7a42                	ld	s4,48(sp)
 820:	7aa2                	ld	s5,40(sp)
 822:	7b02                	ld	s6,32(sp)
 824:	6be2                	ld	s7,24(sp)
 826:	6c42                	ld	s8,16(sp)
 828:	6ca2                	ld	s9,8(sp)
    }
  }
}
 82a:	60e6                	ld	ra,88(sp)
 82c:	6446                	ld	s0,80(sp)
 82e:	6906                	ld	s2,64(sp)
 830:	6125                	addi	sp,sp,96
 832:	8082                	ret

0000000000000834 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 834:	715d                	addi	sp,sp,-80
 836:	ec06                	sd	ra,24(sp)
 838:	e822                	sd	s0,16(sp)
 83a:	1000                	addi	s0,sp,32
 83c:	e010                	sd	a2,0(s0)
 83e:	e414                	sd	a3,8(s0)
 840:	e818                	sd	a4,16(s0)
 842:	ec1c                	sd	a5,24(s0)
 844:	03043023          	sd	a6,32(s0)
 848:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 84c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 850:	8622                	mv	a2,s0
 852:	d3fff0ef          	jal	590 <vprintf>
}
 856:	60e2                	ld	ra,24(sp)
 858:	6442                	ld	s0,16(sp)
 85a:	6161                	addi	sp,sp,80
 85c:	8082                	ret

000000000000085e <printf>:

void
printf(const char *fmt, ...)
{
 85e:	711d                	addi	sp,sp,-96
 860:	ec06                	sd	ra,24(sp)
 862:	e822                	sd	s0,16(sp)
 864:	1000                	addi	s0,sp,32
 866:	e40c                	sd	a1,8(s0)
 868:	e810                	sd	a2,16(s0)
 86a:	ec14                	sd	a3,24(s0)
 86c:	f018                	sd	a4,32(s0)
 86e:	f41c                	sd	a5,40(s0)
 870:	03043823          	sd	a6,48(s0)
 874:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 878:	00840613          	addi	a2,s0,8
 87c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 880:	85aa                	mv	a1,a0
 882:	4505                	li	a0,1
 884:	d0dff0ef          	jal	590 <vprintf>
}
 888:	60e2                	ld	ra,24(sp)
 88a:	6442                	ld	s0,16(sp)
 88c:	6125                	addi	sp,sp,96
 88e:	8082                	ret

0000000000000890 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 890:	1141                	addi	sp,sp,-16
 892:	e422                	sd	s0,8(sp)
 894:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 896:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 89a:	00001797          	auipc	a5,0x1
 89e:	77e7b783          	ld	a5,1918(a5) # 2018 <freep>
 8a2:	a02d                	j	8cc <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 8a4:	4618                	lw	a4,8(a2)
 8a6:	9f2d                	addw	a4,a4,a1
 8a8:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8ac:	6398                	ld	a4,0(a5)
 8ae:	6310                	ld	a2,0(a4)
 8b0:	a83d                	j	8ee <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 8b2:	ff852703          	lw	a4,-8(a0)
 8b6:	9f31                	addw	a4,a4,a2
 8b8:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 8ba:	ff053683          	ld	a3,-16(a0)
 8be:	a091                	j	902 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8c0:	6398                	ld	a4,0(a5)
 8c2:	00e7e463          	bltu	a5,a4,8ca <free+0x3a>
 8c6:	00e6ea63          	bltu	a3,a4,8da <free+0x4a>
{
 8ca:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8cc:	fed7fae3          	bgeu	a5,a3,8c0 <free+0x30>
 8d0:	6398                	ld	a4,0(a5)
 8d2:	00e6e463          	bltu	a3,a4,8da <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8d6:	fee7eae3          	bltu	a5,a4,8ca <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 8da:	ff852583          	lw	a1,-8(a0)
 8de:	6390                	ld	a2,0(a5)
 8e0:	02059813          	slli	a6,a1,0x20
 8e4:	01c85713          	srli	a4,a6,0x1c
 8e8:	9736                	add	a4,a4,a3
 8ea:	fae60de3          	beq	a2,a4,8a4 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 8ee:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8f2:	4790                	lw	a2,8(a5)
 8f4:	02061593          	slli	a1,a2,0x20
 8f8:	01c5d713          	srli	a4,a1,0x1c
 8fc:	973e                	add	a4,a4,a5
 8fe:	fae68ae3          	beq	a3,a4,8b2 <free+0x22>
    p->s.ptr = bp->s.ptr;
 902:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 904:	00001717          	auipc	a4,0x1
 908:	70f73a23          	sd	a5,1812(a4) # 2018 <freep>
}
 90c:	6422                	ld	s0,8(sp)
 90e:	0141                	addi	sp,sp,16
 910:	8082                	ret

0000000000000912 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 912:	7139                	addi	sp,sp,-64
 914:	fc06                	sd	ra,56(sp)
 916:	f822                	sd	s0,48(sp)
 918:	f426                	sd	s1,40(sp)
 91a:	ec4e                	sd	s3,24(sp)
 91c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 91e:	02051493          	slli	s1,a0,0x20
 922:	9081                	srli	s1,s1,0x20
 924:	04bd                	addi	s1,s1,15
 926:	8091                	srli	s1,s1,0x4
 928:	0014899b          	addiw	s3,s1,1
 92c:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 92e:	00001517          	auipc	a0,0x1
 932:	6ea53503          	ld	a0,1770(a0) # 2018 <freep>
 936:	c915                	beqz	a0,96a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 938:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 93a:	4798                	lw	a4,8(a5)
 93c:	08977a63          	bgeu	a4,s1,9d0 <malloc+0xbe>
 940:	f04a                	sd	s2,32(sp)
 942:	e852                	sd	s4,16(sp)
 944:	e456                	sd	s5,8(sp)
 946:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 948:	8a4e                	mv	s4,s3
 94a:	0009871b          	sext.w	a4,s3
 94e:	6685                	lui	a3,0x1
 950:	00d77363          	bgeu	a4,a3,956 <malloc+0x44>
 954:	6a05                	lui	s4,0x1
 956:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 95a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 95e:	00001917          	auipc	s2,0x1
 962:	6ba90913          	addi	s2,s2,1722 # 2018 <freep>
  if(p == SBRK_ERROR)
 966:	5afd                	li	s5,-1
 968:	a081                	j	9a8 <malloc+0x96>
 96a:	f04a                	sd	s2,32(sp)
 96c:	e852                	sd	s4,16(sp)
 96e:	e456                	sd	s5,8(sp)
 970:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 972:	00001797          	auipc	a5,0x1
 976:	6ae78793          	addi	a5,a5,1710 # 2020 <base>
 97a:	00001717          	auipc	a4,0x1
 97e:	68f73f23          	sd	a5,1694(a4) # 2018 <freep>
 982:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 984:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 988:	b7c1                	j	948 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 98a:	6398                	ld	a4,0(a5)
 98c:	e118                	sd	a4,0(a0)
 98e:	a8a9                	j	9e8 <malloc+0xd6>
  hp->s.size = nu;
 990:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 994:	0541                	addi	a0,a0,16
 996:	efbff0ef          	jal	890 <free>
  return freep;
 99a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 99e:	c12d                	beqz	a0,a00 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9a0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9a2:	4798                	lw	a4,8(a5)
 9a4:	02977263          	bgeu	a4,s1,9c8 <malloc+0xb6>
    if(p == freep)
 9a8:	00093703          	ld	a4,0(s2)
 9ac:	853e                	mv	a0,a5
 9ae:	fef719e3          	bne	a4,a5,9a0 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 9b2:	8552                	mv	a0,s4
 9b4:	a47ff0ef          	jal	3fa <sbrk>
  if(p == SBRK_ERROR)
 9b8:	fd551ce3          	bne	a0,s5,990 <malloc+0x7e>
        return 0;
 9bc:	4501                	li	a0,0
 9be:	7902                	ld	s2,32(sp)
 9c0:	6a42                	ld	s4,16(sp)
 9c2:	6aa2                	ld	s5,8(sp)
 9c4:	6b02                	ld	s6,0(sp)
 9c6:	a03d                	j	9f4 <malloc+0xe2>
 9c8:	7902                	ld	s2,32(sp)
 9ca:	6a42                	ld	s4,16(sp)
 9cc:	6aa2                	ld	s5,8(sp)
 9ce:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 9d0:	fae48de3          	beq	s1,a4,98a <malloc+0x78>
        p->s.size -= nunits;
 9d4:	4137073b          	subw	a4,a4,s3
 9d8:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9da:	02071693          	slli	a3,a4,0x20
 9de:	01c6d713          	srli	a4,a3,0x1c
 9e2:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9e4:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9e8:	00001717          	auipc	a4,0x1
 9ec:	62a73823          	sd	a0,1584(a4) # 2018 <freep>
      return (void*)(p + 1);
 9f0:	01078513          	addi	a0,a5,16
  }
}
 9f4:	70e2                	ld	ra,56(sp)
 9f6:	7442                	ld	s0,48(sp)
 9f8:	74a2                	ld	s1,40(sp)
 9fa:	69e2                	ld	s3,24(sp)
 9fc:	6121                	addi	sp,sp,64
 9fe:	8082                	ret
 a00:	7902                	ld	s2,32(sp)
 a02:	6a42                	ld	s4,16(sp)
 a04:	6aa2                	ld	s5,8(sp)
 a06:	6b02                	ld	s6,0(sp)
 a08:	b7f5                	j	9f4 <malloc+0xe2>
