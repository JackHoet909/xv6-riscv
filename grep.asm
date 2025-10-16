
user/_grep:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <matchstar>:
  return 0;
}

// matchstar: search for c*re at beginning of text
int matchstar(int c, char *re, char *text)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	e052                	sd	s4,0(sp)
   e:	1800                	addi	s0,sp,48
  10:	892a                	mv	s2,a0
  12:	89ae                	mv	s3,a1
  14:	84b2                	mv	s1,a2
  do{  // a * matches zero or more instances
    if(matchhere(re, text))
      return 1;
  }while(*text!='\0' && (*text++==c || c=='.'));
  16:	02e00a13          	li	s4,46
    if(matchhere(re, text))
  1a:	85a6                	mv	a1,s1
  1c:	854e                	mv	a0,s3
  1e:	02c000ef          	jal	4a <matchhere>
  22:	e919                	bnez	a0,38 <matchstar+0x38>
  }while(*text!='\0' && (*text++==c || c=='.'));
  24:	0004c783          	lbu	a5,0(s1)
  28:	cb89                	beqz	a5,3a <matchstar+0x3a>
  2a:	0485                	addi	s1,s1,1
  2c:	2781                	sext.w	a5,a5
  2e:	ff2786e3          	beq	a5,s2,1a <matchstar+0x1a>
  32:	ff4904e3          	beq	s2,s4,1a <matchstar+0x1a>
  36:	a011                	j	3a <matchstar+0x3a>
      return 1;
  38:	4505                	li	a0,1
  return 0;
}
  3a:	70a2                	ld	ra,40(sp)
  3c:	7402                	ld	s0,32(sp)
  3e:	64e2                	ld	s1,24(sp)
  40:	6942                	ld	s2,16(sp)
  42:	69a2                	ld	s3,8(sp)
  44:	6a02                	ld	s4,0(sp)
  46:	6145                	addi	sp,sp,48
  48:	8082                	ret

000000000000004a <matchhere>:
  if(re[0] == '\0')
  4a:	00054703          	lbu	a4,0(a0)
  4e:	c73d                	beqz	a4,bc <matchhere+0x72>
{
  50:	1141                	addi	sp,sp,-16
  52:	e406                	sd	ra,8(sp)
  54:	e022                	sd	s0,0(sp)
  56:	0800                	addi	s0,sp,16
  58:	87aa                	mv	a5,a0
  if(re[1] == '*')
  5a:	00154683          	lbu	a3,1(a0)
  5e:	02a00613          	li	a2,42
  62:	02c68563          	beq	a3,a2,8c <matchhere+0x42>
  if(re[0] == '$' && re[1] == '\0')
  66:	02400613          	li	a2,36
  6a:	02c70863          	beq	a4,a2,9a <matchhere+0x50>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  6e:	0005c683          	lbu	a3,0(a1)
  return 0;
  72:	4501                	li	a0,0
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  74:	ca81                	beqz	a3,84 <matchhere+0x3a>
  76:	02e00613          	li	a2,46
  7a:	02c70b63          	beq	a4,a2,b0 <matchhere+0x66>
  return 0;
  7e:	4501                	li	a0,0
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  80:	02d70863          	beq	a4,a3,b0 <matchhere+0x66>
}
  84:	60a2                	ld	ra,8(sp)
  86:	6402                	ld	s0,0(sp)
  88:	0141                	addi	sp,sp,16
  8a:	8082                	ret
    return matchstar(re[0], re+2, text);
  8c:	862e                	mv	a2,a1
  8e:	00250593          	addi	a1,a0,2
  92:	853a                	mv	a0,a4
  94:	f6dff0ef          	jal	0 <matchstar>
  98:	b7f5                	j	84 <matchhere+0x3a>
  if(re[0] == '$' && re[1] == '\0')
  9a:	c691                	beqz	a3,a6 <matchhere+0x5c>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  9c:	0005c683          	lbu	a3,0(a1)
  a0:	fef9                	bnez	a3,7e <matchhere+0x34>
  return 0;
  a2:	4501                	li	a0,0
  a4:	b7c5                	j	84 <matchhere+0x3a>
    return *text == '\0';
  a6:	0005c503          	lbu	a0,0(a1)
  aa:	00153513          	seqz	a0,a0
  ae:	bfd9                	j	84 <matchhere+0x3a>
    return matchhere(re+1, text+1);
  b0:	0585                	addi	a1,a1,1
  b2:	00178513          	addi	a0,a5,1
  b6:	f95ff0ef          	jal	4a <matchhere>
  ba:	b7e9                	j	84 <matchhere+0x3a>
    return 1;
  bc:	4505                	li	a0,1
}
  be:	8082                	ret

00000000000000c0 <match>:
{
  c0:	1101                	addi	sp,sp,-32
  c2:	ec06                	sd	ra,24(sp)
  c4:	e822                	sd	s0,16(sp)
  c6:	e426                	sd	s1,8(sp)
  c8:	e04a                	sd	s2,0(sp)
  ca:	1000                	addi	s0,sp,32
  cc:	892a                	mv	s2,a0
  ce:	84ae                	mv	s1,a1
  if(re[0] == '^')
  d0:	00054703          	lbu	a4,0(a0)
  d4:	05e00793          	li	a5,94
  d8:	00f70c63          	beq	a4,a5,f0 <match+0x30>
    if(matchhere(re, text))
  dc:	85a6                	mv	a1,s1
  de:	854a                	mv	a0,s2
  e0:	f6bff0ef          	jal	4a <matchhere>
  e4:	e911                	bnez	a0,f8 <match+0x38>
  }while(*text++ != '\0');
  e6:	0485                	addi	s1,s1,1
  e8:	fff4c783          	lbu	a5,-1(s1)
  ec:	fbe5                	bnez	a5,dc <match+0x1c>
  ee:	a031                	j	fa <match+0x3a>
    return matchhere(re+1, text);
  f0:	0505                	addi	a0,a0,1
  f2:	f59ff0ef          	jal	4a <matchhere>
  f6:	a011                	j	fa <match+0x3a>
      return 1;
  f8:	4505                	li	a0,1
}
  fa:	60e2                	ld	ra,24(sp)
  fc:	6442                	ld	s0,16(sp)
  fe:	64a2                	ld	s1,8(sp)
 100:	6902                	ld	s2,0(sp)
 102:	6105                	addi	sp,sp,32
 104:	8082                	ret

0000000000000106 <grep>:
{
 106:	715d                	addi	sp,sp,-80
 108:	e486                	sd	ra,72(sp)
 10a:	e0a2                	sd	s0,64(sp)
 10c:	fc26                	sd	s1,56(sp)
 10e:	f84a                	sd	s2,48(sp)
 110:	f44e                	sd	s3,40(sp)
 112:	f052                	sd	s4,32(sp)
 114:	ec56                	sd	s5,24(sp)
 116:	e85a                	sd	s6,16(sp)
 118:	e45e                	sd	s7,8(sp)
 11a:	e062                	sd	s8,0(sp)
 11c:	0880                	addi	s0,sp,80
 11e:	89aa                	mv	s3,a0
 120:	8b2e                	mv	s6,a1
  m = 0;
 122:	4a01                	li	s4,0
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
 124:	3ff00b93          	li	s7,1023
 128:	00002a97          	auipc	s5,0x2
 12c:	ee8a8a93          	addi	s5,s5,-280 # 2010 <buf>
 130:	a835                	j	16c <grep+0x66>
      p = q+1;
 132:	00148913          	addi	s2,s1,1
    while((q = strchr(p, '\n')) != 0){
 136:	45a9                	li	a1,10
 138:	854a                	mv	a0,s2
 13a:	1c4000ef          	jal	2fe <strchr>
 13e:	84aa                	mv	s1,a0
 140:	c505                	beqz	a0,168 <grep+0x62>
      *q = 0;
 142:	00048023          	sb	zero,0(s1)
      if(match(pattern, p)){
 146:	85ca                	mv	a1,s2
 148:	854e                	mv	a0,s3
 14a:	f77ff0ef          	jal	c0 <match>
 14e:	d175                	beqz	a0,132 <grep+0x2c>
        *q = '\n';
 150:	47a9                	li	a5,10
 152:	00f48023          	sb	a5,0(s1)
        write(1, p, q+1 - p);
 156:	00148613          	addi	a2,s1,1
 15a:	4126063b          	subw	a2,a2,s2
 15e:	85ca                	mv	a1,s2
 160:	4505                	li	a0,1
 162:	3b4000ef          	jal	516 <write>
 166:	b7f1                	j	132 <grep+0x2c>
    if(m > 0){
 168:	03404563          	bgtz	s4,192 <grep+0x8c>
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
 16c:	414b863b          	subw	a2,s7,s4
 170:	014a85b3          	add	a1,s5,s4
 174:	855a                	mv	a0,s6
 176:	398000ef          	jal	50e <read>
 17a:	02a05963          	blez	a0,1ac <grep+0xa6>
    m += n;
 17e:	00aa0c3b          	addw	s8,s4,a0
 182:	000c0a1b          	sext.w	s4,s8
    buf[m] = '\0';
 186:	014a87b3          	add	a5,s5,s4
 18a:	00078023          	sb	zero,0(a5)
    p = buf;
 18e:	8956                	mv	s2,s5
    while((q = strchr(p, '\n')) != 0){
 190:	b75d                	j	136 <grep+0x30>
      m -= p - buf;
 192:	00002517          	auipc	a0,0x2
 196:	e7e50513          	addi	a0,a0,-386 # 2010 <buf>
 19a:	40a90a33          	sub	s4,s2,a0
 19e:	414c0a3b          	subw	s4,s8,s4
      memmove(buf, p, m);
 1a2:	8652                	mv	a2,s4
 1a4:	85ca                	mv	a1,s2
 1a6:	26e000ef          	jal	414 <memmove>
 1aa:	b7c9                	j	16c <grep+0x66>
}
 1ac:	60a6                	ld	ra,72(sp)
 1ae:	6406                	ld	s0,64(sp)
 1b0:	74e2                	ld	s1,56(sp)
 1b2:	7942                	ld	s2,48(sp)
 1b4:	79a2                	ld	s3,40(sp)
 1b6:	7a02                	ld	s4,32(sp)
 1b8:	6ae2                	ld	s5,24(sp)
 1ba:	6b42                	ld	s6,16(sp)
 1bc:	6ba2                	ld	s7,8(sp)
 1be:	6c02                	ld	s8,0(sp)
 1c0:	6161                	addi	sp,sp,80
 1c2:	8082                	ret

00000000000001c4 <main>:
{
 1c4:	7179                	addi	sp,sp,-48
 1c6:	f406                	sd	ra,40(sp)
 1c8:	f022                	sd	s0,32(sp)
 1ca:	ec26                	sd	s1,24(sp)
 1cc:	e84a                	sd	s2,16(sp)
 1ce:	e44e                	sd	s3,8(sp)
 1d0:	e052                	sd	s4,0(sp)
 1d2:	1800                	addi	s0,sp,48
  if(argc <= 1){
 1d4:	4785                	li	a5,1
 1d6:	04a7d663          	bge	a5,a0,222 <main+0x5e>
  pattern = argv[1];
 1da:	0085ba03          	ld	s4,8(a1)
  if(argc <= 2){
 1de:	4789                	li	a5,2
 1e0:	04a7db63          	bge	a5,a0,236 <main+0x72>
 1e4:	01058913          	addi	s2,a1,16
 1e8:	ffd5099b          	addiw	s3,a0,-3
 1ec:	02099793          	slli	a5,s3,0x20
 1f0:	01d7d993          	srli	s3,a5,0x1d
 1f4:	05e1                	addi	a1,a1,24
 1f6:	99ae                	add	s3,s3,a1
    if((fd = open(argv[i], O_RDONLY)) < 0){
 1f8:	4581                	li	a1,0
 1fa:	00093503          	ld	a0,0(s2)
 1fe:	338000ef          	jal	536 <open>
 202:	84aa                	mv	s1,a0
 204:	04054063          	bltz	a0,244 <main+0x80>
    grep(pattern, fd);
 208:	85aa                	mv	a1,a0
 20a:	8552                	mv	a0,s4
 20c:	efbff0ef          	jal	106 <grep>
    close(fd);
 210:	8526                	mv	a0,s1
 212:	30c000ef          	jal	51e <close>
  for(i = 2; i < argc; i++){
 216:	0921                	addi	s2,s2,8
 218:	ff3910e3          	bne	s2,s3,1f8 <main+0x34>
  exit(0);
 21c:	4501                	li	a0,0
 21e:	2d8000ef          	jal	4f6 <exit>
    fprintf(2, "usage: grep pattern [file ...]\n");
 222:	00001597          	auipc	a1,0x1
 226:	8ae58593          	addi	a1,a1,-1874 # ad0 <malloc+0xfe>
 22a:	4509                	li	a0,2
 22c:	6c8000ef          	jal	8f4 <fprintf>
    exit(1);
 230:	4505                	li	a0,1
 232:	2c4000ef          	jal	4f6 <exit>
    grep(pattern, 0);
 236:	4581                	li	a1,0
 238:	8552                	mv	a0,s4
 23a:	ecdff0ef          	jal	106 <grep>
    exit(0);
 23e:	4501                	li	a0,0
 240:	2b6000ef          	jal	4f6 <exit>
      printf("grep: cannot open %s\n", argv[i]);
 244:	00093583          	ld	a1,0(s2)
 248:	00001517          	auipc	a0,0x1
 24c:	8a850513          	addi	a0,a0,-1880 # af0 <malloc+0x11e>
 250:	6ce000ef          	jal	91e <printf>
      exit(1);
 254:	4505                	li	a0,1
 256:	2a0000ef          	jal	4f6 <exit>

000000000000025a <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 25a:	1141                	addi	sp,sp,-16
 25c:	e406                	sd	ra,8(sp)
 25e:	e022                	sd	s0,0(sp)
 260:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 262:	f63ff0ef          	jal	1c4 <main>
  exit(r);
 266:	290000ef          	jal	4f6 <exit>

000000000000026a <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 26a:	1141                	addi	sp,sp,-16
 26c:	e422                	sd	s0,8(sp)
 26e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 270:	87aa                	mv	a5,a0
 272:	0585                	addi	a1,a1,1
 274:	0785                	addi	a5,a5,1
 276:	fff5c703          	lbu	a4,-1(a1)
 27a:	fee78fa3          	sb	a4,-1(a5)
 27e:	fb75                	bnez	a4,272 <strcpy+0x8>
    ;
  return os;
}
 280:	6422                	ld	s0,8(sp)
 282:	0141                	addi	sp,sp,16
 284:	8082                	ret

0000000000000286 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 286:	1141                	addi	sp,sp,-16
 288:	e422                	sd	s0,8(sp)
 28a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 28c:	00054783          	lbu	a5,0(a0)
 290:	cb91                	beqz	a5,2a4 <strcmp+0x1e>
 292:	0005c703          	lbu	a4,0(a1)
 296:	00f71763          	bne	a4,a5,2a4 <strcmp+0x1e>
    p++, q++;
 29a:	0505                	addi	a0,a0,1
 29c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 29e:	00054783          	lbu	a5,0(a0)
 2a2:	fbe5                	bnez	a5,292 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 2a4:	0005c503          	lbu	a0,0(a1)
}
 2a8:	40a7853b          	subw	a0,a5,a0
 2ac:	6422                	ld	s0,8(sp)
 2ae:	0141                	addi	sp,sp,16
 2b0:	8082                	ret

00000000000002b2 <strlen>:

uint
strlen(const char *s)
{
 2b2:	1141                	addi	sp,sp,-16
 2b4:	e422                	sd	s0,8(sp)
 2b6:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 2b8:	00054783          	lbu	a5,0(a0)
 2bc:	cf91                	beqz	a5,2d8 <strlen+0x26>
 2be:	0505                	addi	a0,a0,1
 2c0:	87aa                	mv	a5,a0
 2c2:	86be                	mv	a3,a5
 2c4:	0785                	addi	a5,a5,1
 2c6:	fff7c703          	lbu	a4,-1(a5)
 2ca:	ff65                	bnez	a4,2c2 <strlen+0x10>
 2cc:	40a6853b          	subw	a0,a3,a0
 2d0:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 2d2:	6422                	ld	s0,8(sp)
 2d4:	0141                	addi	sp,sp,16
 2d6:	8082                	ret
  for(n = 0; s[n]; n++)
 2d8:	4501                	li	a0,0
 2da:	bfe5                	j	2d2 <strlen+0x20>

00000000000002dc <memset>:

void*
memset(void *dst, int c, uint n)
{
 2dc:	1141                	addi	sp,sp,-16
 2de:	e422                	sd	s0,8(sp)
 2e0:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2e2:	ca19                	beqz	a2,2f8 <memset+0x1c>
 2e4:	87aa                	mv	a5,a0
 2e6:	1602                	slli	a2,a2,0x20
 2e8:	9201                	srli	a2,a2,0x20
 2ea:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 2ee:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 2f2:	0785                	addi	a5,a5,1
 2f4:	fee79de3          	bne	a5,a4,2ee <memset+0x12>
  }
  return dst;
}
 2f8:	6422                	ld	s0,8(sp)
 2fa:	0141                	addi	sp,sp,16
 2fc:	8082                	ret

00000000000002fe <strchr>:

char*
strchr(const char *s, char c)
{
 2fe:	1141                	addi	sp,sp,-16
 300:	e422                	sd	s0,8(sp)
 302:	0800                	addi	s0,sp,16
  for(; *s; s++)
 304:	00054783          	lbu	a5,0(a0)
 308:	cb99                	beqz	a5,31e <strchr+0x20>
    if(*s == c)
 30a:	00f58763          	beq	a1,a5,318 <strchr+0x1a>
  for(; *s; s++)
 30e:	0505                	addi	a0,a0,1
 310:	00054783          	lbu	a5,0(a0)
 314:	fbfd                	bnez	a5,30a <strchr+0xc>
      return (char*)s;
  return 0;
 316:	4501                	li	a0,0
}
 318:	6422                	ld	s0,8(sp)
 31a:	0141                	addi	sp,sp,16
 31c:	8082                	ret
  return 0;
 31e:	4501                	li	a0,0
 320:	bfe5                	j	318 <strchr+0x1a>

0000000000000322 <gets>:

char*
gets(char *buf, int max)
{
 322:	711d                	addi	sp,sp,-96
 324:	ec86                	sd	ra,88(sp)
 326:	e8a2                	sd	s0,80(sp)
 328:	e4a6                	sd	s1,72(sp)
 32a:	e0ca                	sd	s2,64(sp)
 32c:	fc4e                	sd	s3,56(sp)
 32e:	f852                	sd	s4,48(sp)
 330:	f456                	sd	s5,40(sp)
 332:	f05a                	sd	s6,32(sp)
 334:	ec5e                	sd	s7,24(sp)
 336:	1080                	addi	s0,sp,96
 338:	8baa                	mv	s7,a0
 33a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 33c:	892a                	mv	s2,a0
 33e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 340:	4aa9                	li	s5,10
 342:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 344:	89a6                	mv	s3,s1
 346:	2485                	addiw	s1,s1,1
 348:	0344d663          	bge	s1,s4,374 <gets+0x52>
    cc = read(0, &c, 1);
 34c:	4605                	li	a2,1
 34e:	faf40593          	addi	a1,s0,-81
 352:	4501                	li	a0,0
 354:	1ba000ef          	jal	50e <read>
    if(cc < 1)
 358:	00a05e63          	blez	a0,374 <gets+0x52>
    buf[i++] = c;
 35c:	faf44783          	lbu	a5,-81(s0)
 360:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 364:	01578763          	beq	a5,s5,372 <gets+0x50>
 368:	0905                	addi	s2,s2,1
 36a:	fd679de3          	bne	a5,s6,344 <gets+0x22>
    buf[i++] = c;
 36e:	89a6                	mv	s3,s1
 370:	a011                	j	374 <gets+0x52>
 372:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 374:	99de                	add	s3,s3,s7
 376:	00098023          	sb	zero,0(s3)
  return buf;
}
 37a:	855e                	mv	a0,s7
 37c:	60e6                	ld	ra,88(sp)
 37e:	6446                	ld	s0,80(sp)
 380:	64a6                	ld	s1,72(sp)
 382:	6906                	ld	s2,64(sp)
 384:	79e2                	ld	s3,56(sp)
 386:	7a42                	ld	s4,48(sp)
 388:	7aa2                	ld	s5,40(sp)
 38a:	7b02                	ld	s6,32(sp)
 38c:	6be2                	ld	s7,24(sp)
 38e:	6125                	addi	sp,sp,96
 390:	8082                	ret

0000000000000392 <stat>:

int
stat(const char *n, struct stat *st)
{
 392:	1101                	addi	sp,sp,-32
 394:	ec06                	sd	ra,24(sp)
 396:	e822                	sd	s0,16(sp)
 398:	e04a                	sd	s2,0(sp)
 39a:	1000                	addi	s0,sp,32
 39c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 39e:	4581                	li	a1,0
 3a0:	196000ef          	jal	536 <open>
  if(fd < 0)
 3a4:	02054263          	bltz	a0,3c8 <stat+0x36>
 3a8:	e426                	sd	s1,8(sp)
 3aa:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3ac:	85ca                	mv	a1,s2
 3ae:	1a0000ef          	jal	54e <fstat>
 3b2:	892a                	mv	s2,a0
  close(fd);
 3b4:	8526                	mv	a0,s1
 3b6:	168000ef          	jal	51e <close>
  return r;
 3ba:	64a2                	ld	s1,8(sp)
}
 3bc:	854a                	mv	a0,s2
 3be:	60e2                	ld	ra,24(sp)
 3c0:	6442                	ld	s0,16(sp)
 3c2:	6902                	ld	s2,0(sp)
 3c4:	6105                	addi	sp,sp,32
 3c6:	8082                	ret
    return -1;
 3c8:	597d                	li	s2,-1
 3ca:	bfcd                	j	3bc <stat+0x2a>

00000000000003cc <atoi>:

int
atoi(const char *s)
{
 3cc:	1141                	addi	sp,sp,-16
 3ce:	e422                	sd	s0,8(sp)
 3d0:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3d2:	00054683          	lbu	a3,0(a0)
 3d6:	fd06879b          	addiw	a5,a3,-48
 3da:	0ff7f793          	zext.b	a5,a5
 3de:	4625                	li	a2,9
 3e0:	02f66863          	bltu	a2,a5,410 <atoi+0x44>
 3e4:	872a                	mv	a4,a0
  n = 0;
 3e6:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 3e8:	0705                	addi	a4,a4,1
 3ea:	0025179b          	slliw	a5,a0,0x2
 3ee:	9fa9                	addw	a5,a5,a0
 3f0:	0017979b          	slliw	a5,a5,0x1
 3f4:	9fb5                	addw	a5,a5,a3
 3f6:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3fa:	00074683          	lbu	a3,0(a4)
 3fe:	fd06879b          	addiw	a5,a3,-48
 402:	0ff7f793          	zext.b	a5,a5
 406:	fef671e3          	bgeu	a2,a5,3e8 <atoi+0x1c>
  return n;
}
 40a:	6422                	ld	s0,8(sp)
 40c:	0141                	addi	sp,sp,16
 40e:	8082                	ret
  n = 0;
 410:	4501                	li	a0,0
 412:	bfe5                	j	40a <atoi+0x3e>

0000000000000414 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 414:	1141                	addi	sp,sp,-16
 416:	e422                	sd	s0,8(sp)
 418:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 41a:	02b57463          	bgeu	a0,a1,442 <memmove+0x2e>
    while(n-- > 0)
 41e:	00c05f63          	blez	a2,43c <memmove+0x28>
 422:	1602                	slli	a2,a2,0x20
 424:	9201                	srli	a2,a2,0x20
 426:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 42a:	872a                	mv	a4,a0
      *dst++ = *src++;
 42c:	0585                	addi	a1,a1,1
 42e:	0705                	addi	a4,a4,1
 430:	fff5c683          	lbu	a3,-1(a1)
 434:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 438:	fef71ae3          	bne	a4,a5,42c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 43c:	6422                	ld	s0,8(sp)
 43e:	0141                	addi	sp,sp,16
 440:	8082                	ret
    dst += n;
 442:	00c50733          	add	a4,a0,a2
    src += n;
 446:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 448:	fec05ae3          	blez	a2,43c <memmove+0x28>
 44c:	fff6079b          	addiw	a5,a2,-1
 450:	1782                	slli	a5,a5,0x20
 452:	9381                	srli	a5,a5,0x20
 454:	fff7c793          	not	a5,a5
 458:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 45a:	15fd                	addi	a1,a1,-1
 45c:	177d                	addi	a4,a4,-1
 45e:	0005c683          	lbu	a3,0(a1)
 462:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 466:	fee79ae3          	bne	a5,a4,45a <memmove+0x46>
 46a:	bfc9                	j	43c <memmove+0x28>

000000000000046c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 46c:	1141                	addi	sp,sp,-16
 46e:	e422                	sd	s0,8(sp)
 470:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 472:	ca05                	beqz	a2,4a2 <memcmp+0x36>
 474:	fff6069b          	addiw	a3,a2,-1
 478:	1682                	slli	a3,a3,0x20
 47a:	9281                	srli	a3,a3,0x20
 47c:	0685                	addi	a3,a3,1
 47e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 480:	00054783          	lbu	a5,0(a0)
 484:	0005c703          	lbu	a4,0(a1)
 488:	00e79863          	bne	a5,a4,498 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 48c:	0505                	addi	a0,a0,1
    p2++;
 48e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 490:	fed518e3          	bne	a0,a3,480 <memcmp+0x14>
  }
  return 0;
 494:	4501                	li	a0,0
 496:	a019                	j	49c <memcmp+0x30>
      return *p1 - *p2;
 498:	40e7853b          	subw	a0,a5,a4
}
 49c:	6422                	ld	s0,8(sp)
 49e:	0141                	addi	sp,sp,16
 4a0:	8082                	ret
  return 0;
 4a2:	4501                	li	a0,0
 4a4:	bfe5                	j	49c <memcmp+0x30>

00000000000004a6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4a6:	1141                	addi	sp,sp,-16
 4a8:	e406                	sd	ra,8(sp)
 4aa:	e022                	sd	s0,0(sp)
 4ac:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4ae:	f67ff0ef          	jal	414 <memmove>
}
 4b2:	60a2                	ld	ra,8(sp)
 4b4:	6402                	ld	s0,0(sp)
 4b6:	0141                	addi	sp,sp,16
 4b8:	8082                	ret

00000000000004ba <sbrk>:

char *
sbrk(int n) {
 4ba:	1141                	addi	sp,sp,-16
 4bc:	e406                	sd	ra,8(sp)
 4be:	e022                	sd	s0,0(sp)
 4c0:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 4c2:	4585                	li	a1,1
 4c4:	0ba000ef          	jal	57e <sys_sbrk>
}
 4c8:	60a2                	ld	ra,8(sp)
 4ca:	6402                	ld	s0,0(sp)
 4cc:	0141                	addi	sp,sp,16
 4ce:	8082                	ret

00000000000004d0 <sbrklazy>:

char *
sbrklazy(int n) {
 4d0:	1141                	addi	sp,sp,-16
 4d2:	e406                	sd	ra,8(sp)
 4d4:	e022                	sd	s0,0(sp)
 4d6:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 4d8:	4589                	li	a1,2
 4da:	0a4000ef          	jal	57e <sys_sbrk>
}
 4de:	60a2                	ld	ra,8(sp)
 4e0:	6402                	ld	s0,0(sp)
 4e2:	0141                	addi	sp,sp,16
 4e4:	8082                	ret

00000000000004e6 <getfilenum>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global getfilenum
getfilenum:
 li a7, SYS_getfilenum
 4e6:	48dd                	li	a7,23
 ecall
 4e8:	00000073          	ecall
 ret
 4ec:	8082                	ret

00000000000004ee <fork>:
.global fork
fork:
 li a7, SYS_fork
 4ee:	4885                	li	a7,1
 ecall
 4f0:	00000073          	ecall
 ret
 4f4:	8082                	ret

00000000000004f6 <exit>:
.global exit
exit:
 li a7, SYS_exit
 4f6:	4889                	li	a7,2
 ecall
 4f8:	00000073          	ecall
 ret
 4fc:	8082                	ret

00000000000004fe <wait>:
.global wait
wait:
 li a7, SYS_wait
 4fe:	488d                	li	a7,3
 ecall
 500:	00000073          	ecall
 ret
 504:	8082                	ret

0000000000000506 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 506:	4891                	li	a7,4
 ecall
 508:	00000073          	ecall
 ret
 50c:	8082                	ret

000000000000050e <read>:
.global read
read:
 li a7, SYS_read
 50e:	4895                	li	a7,5
 ecall
 510:	00000073          	ecall
 ret
 514:	8082                	ret

0000000000000516 <write>:
.global write
write:
 li a7, SYS_write
 516:	48c1                	li	a7,16
 ecall
 518:	00000073          	ecall
 ret
 51c:	8082                	ret

000000000000051e <close>:
.global close
close:
 li a7, SYS_close
 51e:	48d5                	li	a7,21
 ecall
 520:	00000073          	ecall
 ret
 524:	8082                	ret

0000000000000526 <kill>:
.global kill
kill:
 li a7, SYS_kill
 526:	4899                	li	a7,6
 ecall
 528:	00000073          	ecall
 ret
 52c:	8082                	ret

000000000000052e <exec>:
.global exec
exec:
 li a7, SYS_exec
 52e:	489d                	li	a7,7
 ecall
 530:	00000073          	ecall
 ret
 534:	8082                	ret

0000000000000536 <open>:
.global open
open:
 li a7, SYS_open
 536:	48bd                	li	a7,15
 ecall
 538:	00000073          	ecall
 ret
 53c:	8082                	ret

000000000000053e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 53e:	48c5                	li	a7,17
 ecall
 540:	00000073          	ecall
 ret
 544:	8082                	ret

0000000000000546 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 546:	48c9                	li	a7,18
 ecall
 548:	00000073          	ecall
 ret
 54c:	8082                	ret

000000000000054e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 54e:	48a1                	li	a7,8
 ecall
 550:	00000073          	ecall
 ret
 554:	8082                	ret

0000000000000556 <link>:
.global link
link:
 li a7, SYS_link
 556:	48cd                	li	a7,19
 ecall
 558:	00000073          	ecall
 ret
 55c:	8082                	ret

000000000000055e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 55e:	48d1                	li	a7,20
 ecall
 560:	00000073          	ecall
 ret
 564:	8082                	ret

0000000000000566 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 566:	48a5                	li	a7,9
 ecall
 568:	00000073          	ecall
 ret
 56c:	8082                	ret

000000000000056e <dup>:
.global dup
dup:
 li a7, SYS_dup
 56e:	48a9                	li	a7,10
 ecall
 570:	00000073          	ecall
 ret
 574:	8082                	ret

0000000000000576 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 576:	48ad                	li	a7,11
 ecall
 578:	00000073          	ecall
 ret
 57c:	8082                	ret

000000000000057e <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 57e:	48b1                	li	a7,12
 ecall
 580:	00000073          	ecall
 ret
 584:	8082                	ret

0000000000000586 <pause>:
.global pause
pause:
 li a7, SYS_pause
 586:	48b5                	li	a7,13
 ecall
 588:	00000073          	ecall
 ret
 58c:	8082                	ret

000000000000058e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 58e:	48b9                	li	a7,14
 ecall
 590:	00000073          	ecall
 ret
 594:	8082                	ret

0000000000000596 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 596:	1101                	addi	sp,sp,-32
 598:	ec06                	sd	ra,24(sp)
 59a:	e822                	sd	s0,16(sp)
 59c:	1000                	addi	s0,sp,32
 59e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 5a2:	4605                	li	a2,1
 5a4:	fef40593          	addi	a1,s0,-17
 5a8:	f6fff0ef          	jal	516 <write>
}
 5ac:	60e2                	ld	ra,24(sp)
 5ae:	6442                	ld	s0,16(sp)
 5b0:	6105                	addi	sp,sp,32
 5b2:	8082                	ret

00000000000005b4 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 5b4:	715d                	addi	sp,sp,-80
 5b6:	e486                	sd	ra,72(sp)
 5b8:	e0a2                	sd	s0,64(sp)
 5ba:	f84a                	sd	s2,48(sp)
 5bc:	0880                	addi	s0,sp,80
 5be:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 5c0:	c299                	beqz	a3,5c6 <printint+0x12>
 5c2:	0805c363          	bltz	a1,648 <printint+0x94>
  neg = 0;
 5c6:	4881                	li	a7,0
 5c8:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 5cc:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 5ce:	00000517          	auipc	a0,0x0
 5d2:	54250513          	addi	a0,a0,1346 # b10 <digits>
 5d6:	883e                	mv	a6,a5
 5d8:	2785                	addiw	a5,a5,1
 5da:	02c5f733          	remu	a4,a1,a2
 5de:	972a                	add	a4,a4,a0
 5e0:	00074703          	lbu	a4,0(a4)
 5e4:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 5e8:	872e                	mv	a4,a1
 5ea:	02c5d5b3          	divu	a1,a1,a2
 5ee:	0685                	addi	a3,a3,1
 5f0:	fec773e3          	bgeu	a4,a2,5d6 <printint+0x22>
  if(neg)
 5f4:	00088b63          	beqz	a7,60a <printint+0x56>
    buf[i++] = '-';
 5f8:	fd078793          	addi	a5,a5,-48
 5fc:	97a2                	add	a5,a5,s0
 5fe:	02d00713          	li	a4,45
 602:	fee78423          	sb	a4,-24(a5)
 606:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 60a:	02f05a63          	blez	a5,63e <printint+0x8a>
 60e:	fc26                	sd	s1,56(sp)
 610:	f44e                	sd	s3,40(sp)
 612:	fb840713          	addi	a4,s0,-72
 616:	00f704b3          	add	s1,a4,a5
 61a:	fff70993          	addi	s3,a4,-1
 61e:	99be                	add	s3,s3,a5
 620:	37fd                	addiw	a5,a5,-1
 622:	1782                	slli	a5,a5,0x20
 624:	9381                	srli	a5,a5,0x20
 626:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 62a:	fff4c583          	lbu	a1,-1(s1)
 62e:	854a                	mv	a0,s2
 630:	f67ff0ef          	jal	596 <putc>
  while(--i >= 0)
 634:	14fd                	addi	s1,s1,-1
 636:	ff349ae3          	bne	s1,s3,62a <printint+0x76>
 63a:	74e2                	ld	s1,56(sp)
 63c:	79a2                	ld	s3,40(sp)
}
 63e:	60a6                	ld	ra,72(sp)
 640:	6406                	ld	s0,64(sp)
 642:	7942                	ld	s2,48(sp)
 644:	6161                	addi	sp,sp,80
 646:	8082                	ret
    x = -xx;
 648:	40b005b3          	neg	a1,a1
    neg = 1;
 64c:	4885                	li	a7,1
    x = -xx;
 64e:	bfad                	j	5c8 <printint+0x14>

0000000000000650 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 650:	711d                	addi	sp,sp,-96
 652:	ec86                	sd	ra,88(sp)
 654:	e8a2                	sd	s0,80(sp)
 656:	e0ca                	sd	s2,64(sp)
 658:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 65a:	0005c903          	lbu	s2,0(a1)
 65e:	28090663          	beqz	s2,8ea <vprintf+0x29a>
 662:	e4a6                	sd	s1,72(sp)
 664:	fc4e                	sd	s3,56(sp)
 666:	f852                	sd	s4,48(sp)
 668:	f456                	sd	s5,40(sp)
 66a:	f05a                	sd	s6,32(sp)
 66c:	ec5e                	sd	s7,24(sp)
 66e:	e862                	sd	s8,16(sp)
 670:	e466                	sd	s9,8(sp)
 672:	8b2a                	mv	s6,a0
 674:	8a2e                	mv	s4,a1
 676:	8bb2                	mv	s7,a2
  state = 0;
 678:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 67a:	4481                	li	s1,0
 67c:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 67e:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 682:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 686:	06c00c93          	li	s9,108
 68a:	a005                	j	6aa <vprintf+0x5a>
        putc(fd, c0);
 68c:	85ca                	mv	a1,s2
 68e:	855a                	mv	a0,s6
 690:	f07ff0ef          	jal	596 <putc>
 694:	a019                	j	69a <vprintf+0x4a>
    } else if(state == '%'){
 696:	03598263          	beq	s3,s5,6ba <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 69a:	2485                	addiw	s1,s1,1
 69c:	8726                	mv	a4,s1
 69e:	009a07b3          	add	a5,s4,s1
 6a2:	0007c903          	lbu	s2,0(a5)
 6a6:	22090a63          	beqz	s2,8da <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 6aa:	0009079b          	sext.w	a5,s2
    if(state == 0){
 6ae:	fe0994e3          	bnez	s3,696 <vprintf+0x46>
      if(c0 == '%'){
 6b2:	fd579de3          	bne	a5,s5,68c <vprintf+0x3c>
        state = '%';
 6b6:	89be                	mv	s3,a5
 6b8:	b7cd                	j	69a <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 6ba:	00ea06b3          	add	a3,s4,a4
 6be:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 6c2:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 6c4:	c681                	beqz	a3,6cc <vprintf+0x7c>
 6c6:	9752                	add	a4,a4,s4
 6c8:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 6cc:	05878363          	beq	a5,s8,712 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 6d0:	05978d63          	beq	a5,s9,72a <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 6d4:	07500713          	li	a4,117
 6d8:	0ee78763          	beq	a5,a4,7c6 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 6dc:	07800713          	li	a4,120
 6e0:	12e78963          	beq	a5,a4,812 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 6e4:	07000713          	li	a4,112
 6e8:	14e78e63          	beq	a5,a4,844 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 6ec:	06300713          	li	a4,99
 6f0:	18e78e63          	beq	a5,a4,88c <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 6f4:	07300713          	li	a4,115
 6f8:	1ae78463          	beq	a5,a4,8a0 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 6fc:	02500713          	li	a4,37
 700:	04e79563          	bne	a5,a4,74a <vprintf+0xfa>
        putc(fd, '%');
 704:	02500593          	li	a1,37
 708:	855a                	mv	a0,s6
 70a:	e8dff0ef          	jal	596 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 70e:	4981                	li	s3,0
 710:	b769                	j	69a <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 712:	008b8913          	addi	s2,s7,8
 716:	4685                	li	a3,1
 718:	4629                	li	a2,10
 71a:	000ba583          	lw	a1,0(s7)
 71e:	855a                	mv	a0,s6
 720:	e95ff0ef          	jal	5b4 <printint>
 724:	8bca                	mv	s7,s2
      state = 0;
 726:	4981                	li	s3,0
 728:	bf8d                	j	69a <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 72a:	06400793          	li	a5,100
 72e:	02f68963          	beq	a3,a5,760 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 732:	06c00793          	li	a5,108
 736:	04f68263          	beq	a3,a5,77a <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 73a:	07500793          	li	a5,117
 73e:	0af68063          	beq	a3,a5,7de <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 742:	07800793          	li	a5,120
 746:	0ef68263          	beq	a3,a5,82a <vprintf+0x1da>
        putc(fd, '%');
 74a:	02500593          	li	a1,37
 74e:	855a                	mv	a0,s6
 750:	e47ff0ef          	jal	596 <putc>
        putc(fd, c0);
 754:	85ca                	mv	a1,s2
 756:	855a                	mv	a0,s6
 758:	e3fff0ef          	jal	596 <putc>
      state = 0;
 75c:	4981                	li	s3,0
 75e:	bf35                	j	69a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 760:	008b8913          	addi	s2,s7,8
 764:	4685                	li	a3,1
 766:	4629                	li	a2,10
 768:	000bb583          	ld	a1,0(s7)
 76c:	855a                	mv	a0,s6
 76e:	e47ff0ef          	jal	5b4 <printint>
        i += 1;
 772:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 774:	8bca                	mv	s7,s2
      state = 0;
 776:	4981                	li	s3,0
        i += 1;
 778:	b70d                	j	69a <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 77a:	06400793          	li	a5,100
 77e:	02f60763          	beq	a2,a5,7ac <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 782:	07500793          	li	a5,117
 786:	06f60963          	beq	a2,a5,7f8 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 78a:	07800793          	li	a5,120
 78e:	faf61ee3          	bne	a2,a5,74a <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 792:	008b8913          	addi	s2,s7,8
 796:	4681                	li	a3,0
 798:	4641                	li	a2,16
 79a:	000bb583          	ld	a1,0(s7)
 79e:	855a                	mv	a0,s6
 7a0:	e15ff0ef          	jal	5b4 <printint>
        i += 2;
 7a4:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 7a6:	8bca                	mv	s7,s2
      state = 0;
 7a8:	4981                	li	s3,0
        i += 2;
 7aa:	bdc5                	j	69a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 7ac:	008b8913          	addi	s2,s7,8
 7b0:	4685                	li	a3,1
 7b2:	4629                	li	a2,10
 7b4:	000bb583          	ld	a1,0(s7)
 7b8:	855a                	mv	a0,s6
 7ba:	dfbff0ef          	jal	5b4 <printint>
        i += 2;
 7be:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 7c0:	8bca                	mv	s7,s2
      state = 0;
 7c2:	4981                	li	s3,0
        i += 2;
 7c4:	bdd9                	j	69a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 7c6:	008b8913          	addi	s2,s7,8
 7ca:	4681                	li	a3,0
 7cc:	4629                	li	a2,10
 7ce:	000be583          	lwu	a1,0(s7)
 7d2:	855a                	mv	a0,s6
 7d4:	de1ff0ef          	jal	5b4 <printint>
 7d8:	8bca                	mv	s7,s2
      state = 0;
 7da:	4981                	li	s3,0
 7dc:	bd7d                	j	69a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7de:	008b8913          	addi	s2,s7,8
 7e2:	4681                	li	a3,0
 7e4:	4629                	li	a2,10
 7e6:	000bb583          	ld	a1,0(s7)
 7ea:	855a                	mv	a0,s6
 7ec:	dc9ff0ef          	jal	5b4 <printint>
        i += 1;
 7f0:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 7f2:	8bca                	mv	s7,s2
      state = 0;
 7f4:	4981                	li	s3,0
        i += 1;
 7f6:	b555                	j	69a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7f8:	008b8913          	addi	s2,s7,8
 7fc:	4681                	li	a3,0
 7fe:	4629                	li	a2,10
 800:	000bb583          	ld	a1,0(s7)
 804:	855a                	mv	a0,s6
 806:	dafff0ef          	jal	5b4 <printint>
        i += 2;
 80a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 80c:	8bca                	mv	s7,s2
      state = 0;
 80e:	4981                	li	s3,0
        i += 2;
 810:	b569                	j	69a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 812:	008b8913          	addi	s2,s7,8
 816:	4681                	li	a3,0
 818:	4641                	li	a2,16
 81a:	000be583          	lwu	a1,0(s7)
 81e:	855a                	mv	a0,s6
 820:	d95ff0ef          	jal	5b4 <printint>
 824:	8bca                	mv	s7,s2
      state = 0;
 826:	4981                	li	s3,0
 828:	bd8d                	j	69a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 82a:	008b8913          	addi	s2,s7,8
 82e:	4681                	li	a3,0
 830:	4641                	li	a2,16
 832:	000bb583          	ld	a1,0(s7)
 836:	855a                	mv	a0,s6
 838:	d7dff0ef          	jal	5b4 <printint>
        i += 1;
 83c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 83e:	8bca                	mv	s7,s2
      state = 0;
 840:	4981                	li	s3,0
        i += 1;
 842:	bda1                	j	69a <vprintf+0x4a>
 844:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 846:	008b8d13          	addi	s10,s7,8
 84a:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 84e:	03000593          	li	a1,48
 852:	855a                	mv	a0,s6
 854:	d43ff0ef          	jal	596 <putc>
  putc(fd, 'x');
 858:	07800593          	li	a1,120
 85c:	855a                	mv	a0,s6
 85e:	d39ff0ef          	jal	596 <putc>
 862:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 864:	00000b97          	auipc	s7,0x0
 868:	2acb8b93          	addi	s7,s7,684 # b10 <digits>
 86c:	03c9d793          	srli	a5,s3,0x3c
 870:	97de                	add	a5,a5,s7
 872:	0007c583          	lbu	a1,0(a5)
 876:	855a                	mv	a0,s6
 878:	d1fff0ef          	jal	596 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 87c:	0992                	slli	s3,s3,0x4
 87e:	397d                	addiw	s2,s2,-1
 880:	fe0916e3          	bnez	s2,86c <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 884:	8bea                	mv	s7,s10
      state = 0;
 886:	4981                	li	s3,0
 888:	6d02                	ld	s10,0(sp)
 88a:	bd01                	j	69a <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 88c:	008b8913          	addi	s2,s7,8
 890:	000bc583          	lbu	a1,0(s7)
 894:	855a                	mv	a0,s6
 896:	d01ff0ef          	jal	596 <putc>
 89a:	8bca                	mv	s7,s2
      state = 0;
 89c:	4981                	li	s3,0
 89e:	bbf5                	j	69a <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 8a0:	008b8993          	addi	s3,s7,8
 8a4:	000bb903          	ld	s2,0(s7)
 8a8:	00090f63          	beqz	s2,8c6 <vprintf+0x276>
        for(; *s; s++)
 8ac:	00094583          	lbu	a1,0(s2)
 8b0:	c195                	beqz	a1,8d4 <vprintf+0x284>
          putc(fd, *s);
 8b2:	855a                	mv	a0,s6
 8b4:	ce3ff0ef          	jal	596 <putc>
        for(; *s; s++)
 8b8:	0905                	addi	s2,s2,1
 8ba:	00094583          	lbu	a1,0(s2)
 8be:	f9f5                	bnez	a1,8b2 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 8c0:	8bce                	mv	s7,s3
      state = 0;
 8c2:	4981                	li	s3,0
 8c4:	bbd9                	j	69a <vprintf+0x4a>
          s = "(null)";
 8c6:	00000917          	auipc	s2,0x0
 8ca:	24290913          	addi	s2,s2,578 # b08 <malloc+0x136>
        for(; *s; s++)
 8ce:	02800593          	li	a1,40
 8d2:	b7c5                	j	8b2 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 8d4:	8bce                	mv	s7,s3
      state = 0;
 8d6:	4981                	li	s3,0
 8d8:	b3c9                	j	69a <vprintf+0x4a>
 8da:	64a6                	ld	s1,72(sp)
 8dc:	79e2                	ld	s3,56(sp)
 8de:	7a42                	ld	s4,48(sp)
 8e0:	7aa2                	ld	s5,40(sp)
 8e2:	7b02                	ld	s6,32(sp)
 8e4:	6be2                	ld	s7,24(sp)
 8e6:	6c42                	ld	s8,16(sp)
 8e8:	6ca2                	ld	s9,8(sp)
    }
  }
}
 8ea:	60e6                	ld	ra,88(sp)
 8ec:	6446                	ld	s0,80(sp)
 8ee:	6906                	ld	s2,64(sp)
 8f0:	6125                	addi	sp,sp,96
 8f2:	8082                	ret

00000000000008f4 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 8f4:	715d                	addi	sp,sp,-80
 8f6:	ec06                	sd	ra,24(sp)
 8f8:	e822                	sd	s0,16(sp)
 8fa:	1000                	addi	s0,sp,32
 8fc:	e010                	sd	a2,0(s0)
 8fe:	e414                	sd	a3,8(s0)
 900:	e818                	sd	a4,16(s0)
 902:	ec1c                	sd	a5,24(s0)
 904:	03043023          	sd	a6,32(s0)
 908:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 90c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 910:	8622                	mv	a2,s0
 912:	d3fff0ef          	jal	650 <vprintf>
}
 916:	60e2                	ld	ra,24(sp)
 918:	6442                	ld	s0,16(sp)
 91a:	6161                	addi	sp,sp,80
 91c:	8082                	ret

000000000000091e <printf>:

void
printf(const char *fmt, ...)
{
 91e:	711d                	addi	sp,sp,-96
 920:	ec06                	sd	ra,24(sp)
 922:	e822                	sd	s0,16(sp)
 924:	1000                	addi	s0,sp,32
 926:	e40c                	sd	a1,8(s0)
 928:	e810                	sd	a2,16(s0)
 92a:	ec14                	sd	a3,24(s0)
 92c:	f018                	sd	a4,32(s0)
 92e:	f41c                	sd	a5,40(s0)
 930:	03043823          	sd	a6,48(s0)
 934:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 938:	00840613          	addi	a2,s0,8
 93c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 940:	85aa                	mv	a1,a0
 942:	4505                	li	a0,1
 944:	d0dff0ef          	jal	650 <vprintf>
}
 948:	60e2                	ld	ra,24(sp)
 94a:	6442                	ld	s0,16(sp)
 94c:	6125                	addi	sp,sp,96
 94e:	8082                	ret

0000000000000950 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 950:	1141                	addi	sp,sp,-16
 952:	e422                	sd	s0,8(sp)
 954:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 956:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 95a:	00001797          	auipc	a5,0x1
 95e:	6a67b783          	ld	a5,1702(a5) # 2000 <freep>
 962:	a02d                	j	98c <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 964:	4618                	lw	a4,8(a2)
 966:	9f2d                	addw	a4,a4,a1
 968:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 96c:	6398                	ld	a4,0(a5)
 96e:	6310                	ld	a2,0(a4)
 970:	a83d                	j	9ae <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 972:	ff852703          	lw	a4,-8(a0)
 976:	9f31                	addw	a4,a4,a2
 978:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 97a:	ff053683          	ld	a3,-16(a0)
 97e:	a091                	j	9c2 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 980:	6398                	ld	a4,0(a5)
 982:	00e7e463          	bltu	a5,a4,98a <free+0x3a>
 986:	00e6ea63          	bltu	a3,a4,99a <free+0x4a>
{
 98a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 98c:	fed7fae3          	bgeu	a5,a3,980 <free+0x30>
 990:	6398                	ld	a4,0(a5)
 992:	00e6e463          	bltu	a3,a4,99a <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 996:	fee7eae3          	bltu	a5,a4,98a <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 99a:	ff852583          	lw	a1,-8(a0)
 99e:	6390                	ld	a2,0(a5)
 9a0:	02059813          	slli	a6,a1,0x20
 9a4:	01c85713          	srli	a4,a6,0x1c
 9a8:	9736                	add	a4,a4,a3
 9aa:	fae60de3          	beq	a2,a4,964 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 9ae:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 9b2:	4790                	lw	a2,8(a5)
 9b4:	02061593          	slli	a1,a2,0x20
 9b8:	01c5d713          	srli	a4,a1,0x1c
 9bc:	973e                	add	a4,a4,a5
 9be:	fae68ae3          	beq	a3,a4,972 <free+0x22>
    p->s.ptr = bp->s.ptr;
 9c2:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 9c4:	00001717          	auipc	a4,0x1
 9c8:	62f73e23          	sd	a5,1596(a4) # 2000 <freep>
}
 9cc:	6422                	ld	s0,8(sp)
 9ce:	0141                	addi	sp,sp,16
 9d0:	8082                	ret

00000000000009d2 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 9d2:	7139                	addi	sp,sp,-64
 9d4:	fc06                	sd	ra,56(sp)
 9d6:	f822                	sd	s0,48(sp)
 9d8:	f426                	sd	s1,40(sp)
 9da:	ec4e                	sd	s3,24(sp)
 9dc:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9de:	02051493          	slli	s1,a0,0x20
 9e2:	9081                	srli	s1,s1,0x20
 9e4:	04bd                	addi	s1,s1,15
 9e6:	8091                	srli	s1,s1,0x4
 9e8:	0014899b          	addiw	s3,s1,1
 9ec:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 9ee:	00001517          	auipc	a0,0x1
 9f2:	61253503          	ld	a0,1554(a0) # 2000 <freep>
 9f6:	c915                	beqz	a0,a2a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9f8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9fa:	4798                	lw	a4,8(a5)
 9fc:	08977a63          	bgeu	a4,s1,a90 <malloc+0xbe>
 a00:	f04a                	sd	s2,32(sp)
 a02:	e852                	sd	s4,16(sp)
 a04:	e456                	sd	s5,8(sp)
 a06:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 a08:	8a4e                	mv	s4,s3
 a0a:	0009871b          	sext.w	a4,s3
 a0e:	6685                	lui	a3,0x1
 a10:	00d77363          	bgeu	a4,a3,a16 <malloc+0x44>
 a14:	6a05                	lui	s4,0x1
 a16:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a1a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a1e:	00001917          	auipc	s2,0x1
 a22:	5e290913          	addi	s2,s2,1506 # 2000 <freep>
  if(p == SBRK_ERROR)
 a26:	5afd                	li	s5,-1
 a28:	a081                	j	a68 <malloc+0x96>
 a2a:	f04a                	sd	s2,32(sp)
 a2c:	e852                	sd	s4,16(sp)
 a2e:	e456                	sd	s5,8(sp)
 a30:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 a32:	00002797          	auipc	a5,0x2
 a36:	9de78793          	addi	a5,a5,-1570 # 2410 <base>
 a3a:	00001717          	auipc	a4,0x1
 a3e:	5cf73323          	sd	a5,1478(a4) # 2000 <freep>
 a42:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a44:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a48:	b7c1                	j	a08 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 a4a:	6398                	ld	a4,0(a5)
 a4c:	e118                	sd	a4,0(a0)
 a4e:	a8a9                	j	aa8 <malloc+0xd6>
  hp->s.size = nu;
 a50:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a54:	0541                	addi	a0,a0,16
 a56:	efbff0ef          	jal	950 <free>
  return freep;
 a5a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a5e:	c12d                	beqz	a0,ac0 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a60:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a62:	4798                	lw	a4,8(a5)
 a64:	02977263          	bgeu	a4,s1,a88 <malloc+0xb6>
    if(p == freep)
 a68:	00093703          	ld	a4,0(s2)
 a6c:	853e                	mv	a0,a5
 a6e:	fef719e3          	bne	a4,a5,a60 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 a72:	8552                	mv	a0,s4
 a74:	a47ff0ef          	jal	4ba <sbrk>
  if(p == SBRK_ERROR)
 a78:	fd551ce3          	bne	a0,s5,a50 <malloc+0x7e>
        return 0;
 a7c:	4501                	li	a0,0
 a7e:	7902                	ld	s2,32(sp)
 a80:	6a42                	ld	s4,16(sp)
 a82:	6aa2                	ld	s5,8(sp)
 a84:	6b02                	ld	s6,0(sp)
 a86:	a03d                	j	ab4 <malloc+0xe2>
 a88:	7902                	ld	s2,32(sp)
 a8a:	6a42                	ld	s4,16(sp)
 a8c:	6aa2                	ld	s5,8(sp)
 a8e:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 a90:	fae48de3          	beq	s1,a4,a4a <malloc+0x78>
        p->s.size -= nunits;
 a94:	4137073b          	subw	a4,a4,s3
 a98:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a9a:	02071693          	slli	a3,a4,0x20
 a9e:	01c6d713          	srli	a4,a3,0x1c
 aa2:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 aa4:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 aa8:	00001717          	auipc	a4,0x1
 aac:	54a73c23          	sd	a0,1368(a4) # 2000 <freep>
      return (void*)(p + 1);
 ab0:	01078513          	addi	a0,a5,16
  }
}
 ab4:	70e2                	ld	ra,56(sp)
 ab6:	7442                	ld	s0,48(sp)
 ab8:	74a2                	ld	s1,40(sp)
 aba:	69e2                	ld	s3,24(sp)
 abc:	6121                	addi	sp,sp,64
 abe:	8082                	ret
 ac0:	7902                	ld	s2,32(sp)
 ac2:	6a42                	ld	s4,16(sp)
 ac4:	6aa2                	ld	s5,8(sp)
 ac6:	6b02                	ld	s6,0(sp)
 ac8:	b7f5                	j	ab4 <malloc+0xe2>
