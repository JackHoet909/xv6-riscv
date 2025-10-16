
user/_grind:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <do_rand>:
#include "kernel/riscv.h"

// from FreeBSD.
int
do_rand(unsigned long *ctx)
{
       0:	1141                	addi	sp,sp,-16
       2:	e422                	sd	s0,8(sp)
       4:	0800                	addi	s0,sp,16
 * October 1988, p. 1195.
 */
    long hi, lo, x;

    /* Transform to [1, 0x7ffffffe] range. */
    x = (*ctx % 0x7ffffffe) + 1;
       6:	611c                	ld	a5,0(a0)
       8:	80000737          	lui	a4,0x80000
       c:	ffe74713          	xori	a4,a4,-2
      10:	02e7f7b3          	remu	a5,a5,a4
      14:	0785                	addi	a5,a5,1
    hi = x / 127773;
    lo = x % 127773;
      16:	66fd                	lui	a3,0x1f
      18:	31d68693          	addi	a3,a3,797 # 1f31d <base+0x1cf15>
      1c:	02d7e733          	rem	a4,a5,a3
    x = 16807 * lo - 2836 * hi;
      20:	6611                	lui	a2,0x4
      22:	1a760613          	addi	a2,a2,423 # 41a7 <base+0x1d9f>
      26:	02c70733          	mul	a4,a4,a2
    hi = x / 127773;
      2a:	02d7c7b3          	div	a5,a5,a3
    x = 16807 * lo - 2836 * hi;
      2e:	76fd                	lui	a3,0xfffff
      30:	4ec68693          	addi	a3,a3,1260 # fffffffffffff4ec <base+0xffffffffffffd0e4>
      34:	02d787b3          	mul	a5,a5,a3
      38:	97ba                	add	a5,a5,a4
    if (x < 0)
      3a:	0007c963          	bltz	a5,4c <do_rand+0x4c>
        x += 0x7fffffff;
    /* Transform to [0, 0x7ffffffd] range. */
    x--;
      3e:	17fd                	addi	a5,a5,-1
    *ctx = x;
      40:	e11c                	sd	a5,0(a0)
    return (x);
}
      42:	0007851b          	sext.w	a0,a5
      46:	6422                	ld	s0,8(sp)
      48:	0141                	addi	sp,sp,16
      4a:	8082                	ret
        x += 0x7fffffff;
      4c:	80000737          	lui	a4,0x80000
      50:	fff74713          	not	a4,a4
      54:	97ba                	add	a5,a5,a4
      56:	b7e5                	j	3e <do_rand+0x3e>

0000000000000058 <rand>:

unsigned long rand_next = 1;

int
rand(void)
{
      58:	1141                	addi	sp,sp,-16
      5a:	e406                	sd	ra,8(sp)
      5c:	e022                	sd	s0,0(sp)
      5e:	0800                	addi	s0,sp,16
    return (do_rand(&rand_next));
      60:	00002517          	auipc	a0,0x2
      64:	fa050513          	addi	a0,a0,-96 # 2000 <rand_next>
      68:	f99ff0ef          	jal	0 <do_rand>
}
      6c:	60a2                	ld	ra,8(sp)
      6e:	6402                	ld	s0,0(sp)
      70:	0141                	addi	sp,sp,16
      72:	8082                	ret

0000000000000074 <go>:

void
go(int which_child)
{
      74:	7159                	addi	sp,sp,-112
      76:	f486                	sd	ra,104(sp)
      78:	f0a2                	sd	s0,96(sp)
      7a:	eca6                	sd	s1,88(sp)
      7c:	fc56                	sd	s5,56(sp)
      7e:	1880                	addi	s0,sp,112
      80:	84aa                	mv	s1,a0
  int fd = -1;
  static char buf[999];
  char *break0 = sbrk(0);
      82:	4501                	li	a0,0
      84:	2bb000ef          	jal	b3e <sbrk>
      88:	8aaa                	mv	s5,a0
  uint64 iters = 0;

  mkdir("grindir");
      8a:	00001517          	auipc	a0,0x1
      8e:	0c650513          	addi	a0,a0,198 # 1150 <malloc+0xfa>
      92:	351000ef          	jal	be2 <mkdir>
  if(chdir("grindir") != 0){
      96:	00001517          	auipc	a0,0x1
      9a:	0ba50513          	addi	a0,a0,186 # 1150 <malloc+0xfa>
      9e:	34d000ef          	jal	bea <chdir>
      a2:	cd11                	beqz	a0,be <go+0x4a>
      a4:	e8ca                	sd	s2,80(sp)
      a6:	e4ce                	sd	s3,72(sp)
      a8:	e0d2                	sd	s4,64(sp)
      aa:	f85a                	sd	s6,48(sp)
    printf("grind: chdir grindir failed\n");
      ac:	00001517          	auipc	a0,0x1
      b0:	0ac50513          	addi	a0,a0,172 # 1158 <malloc+0x102>
      b4:	6ef000ef          	jal	fa2 <printf>
    exit(1);
      b8:	4505                	li	a0,1
      ba:	2c1000ef          	jal	b7a <exit>
      be:	e8ca                	sd	s2,80(sp)
      c0:	e4ce                	sd	s3,72(sp)
      c2:	e0d2                	sd	s4,64(sp)
      c4:	f85a                	sd	s6,48(sp)
  }
  chdir("/");
      c6:	00001517          	auipc	a0,0x1
      ca:	0ba50513          	addi	a0,a0,186 # 1180 <malloc+0x12a>
      ce:	31d000ef          	jal	bea <chdir>
      d2:	00001997          	auipc	s3,0x1
      d6:	0be98993          	addi	s3,s3,190 # 1190 <malloc+0x13a>
      da:	c489                	beqz	s1,e4 <go+0x70>
      dc:	00001997          	auipc	s3,0x1
      e0:	0ac98993          	addi	s3,s3,172 # 1188 <malloc+0x132>
  uint64 iters = 0;
      e4:	4481                	li	s1,0
  int fd = -1;
      e6:	5a7d                	li	s4,-1
      e8:	00001917          	auipc	s2,0x1
      ec:	37890913          	addi	s2,s2,888 # 1460 <malloc+0x40a>
      f0:	a819                	j	106 <go+0x92>
    iters++;
    if((iters % 500) == 0)
      write(1, which_child?"B":"A", 1);
    int what = rand() % 23;
    if(what == 1){
      close(open("grindir/../a", O_CREATE|O_RDWR));
      f2:	20200593          	li	a1,514
      f6:	00001517          	auipc	a0,0x1
      fa:	0a250513          	addi	a0,a0,162 # 1198 <malloc+0x142>
      fe:	2bd000ef          	jal	bba <open>
     102:	2a1000ef          	jal	ba2 <close>
    iters++;
     106:	0485                	addi	s1,s1,1
    if((iters % 500) == 0)
     108:	1f400793          	li	a5,500
     10c:	02f4f7b3          	remu	a5,s1,a5
     110:	e791                	bnez	a5,11c <go+0xa8>
      write(1, which_child?"B":"A", 1);
     112:	4605                	li	a2,1
     114:	85ce                	mv	a1,s3
     116:	4505                	li	a0,1
     118:	283000ef          	jal	b9a <write>
    int what = rand() % 23;
     11c:	f3dff0ef          	jal	58 <rand>
     120:	47dd                	li	a5,23
     122:	02f5653b          	remw	a0,a0,a5
     126:	0005071b          	sext.w	a4,a0
     12a:	47d9                	li	a5,22
     12c:	fce7ede3          	bltu	a5,a4,106 <go+0x92>
     130:	02051793          	slli	a5,a0,0x20
     134:	01e7d513          	srli	a0,a5,0x1e
     138:	954a                	add	a0,a0,s2
     13a:	411c                	lw	a5,0(a0)
     13c:	97ca                	add	a5,a5,s2
     13e:	8782                	jr	a5
    } else if(what == 2){
      close(open("grindir/../grindir/../b", O_CREATE|O_RDWR));
     140:	20200593          	li	a1,514
     144:	00001517          	auipc	a0,0x1
     148:	06450513          	addi	a0,a0,100 # 11a8 <malloc+0x152>
     14c:	26f000ef          	jal	bba <open>
     150:	253000ef          	jal	ba2 <close>
     154:	bf4d                	j	106 <go+0x92>
    } else if(what == 3){
      unlink("grindir/../a");
     156:	00001517          	auipc	a0,0x1
     15a:	04250513          	addi	a0,a0,66 # 1198 <malloc+0x142>
     15e:	26d000ef          	jal	bca <unlink>
     162:	b755                	j	106 <go+0x92>
    } else if(what == 4){
      if(chdir("grindir") != 0){
     164:	00001517          	auipc	a0,0x1
     168:	fec50513          	addi	a0,a0,-20 # 1150 <malloc+0xfa>
     16c:	27f000ef          	jal	bea <chdir>
     170:	ed11                	bnez	a0,18c <go+0x118>
        printf("grind: chdir grindir failed\n");
        exit(1);
      }
      unlink("../b");
     172:	00001517          	auipc	a0,0x1
     176:	04e50513          	addi	a0,a0,78 # 11c0 <malloc+0x16a>
     17a:	251000ef          	jal	bca <unlink>
      chdir("/");
     17e:	00001517          	auipc	a0,0x1
     182:	00250513          	addi	a0,a0,2 # 1180 <malloc+0x12a>
     186:	265000ef          	jal	bea <chdir>
     18a:	bfb5                	j	106 <go+0x92>
        printf("grind: chdir grindir failed\n");
     18c:	00001517          	auipc	a0,0x1
     190:	fcc50513          	addi	a0,a0,-52 # 1158 <malloc+0x102>
     194:	60f000ef          	jal	fa2 <printf>
        exit(1);
     198:	4505                	li	a0,1
     19a:	1e1000ef          	jal	b7a <exit>
    } else if(what == 5){
      close(fd);
     19e:	8552                	mv	a0,s4
     1a0:	203000ef          	jal	ba2 <close>
      fd = open("/grindir/../a", O_CREATE|O_RDWR);
     1a4:	20200593          	li	a1,514
     1a8:	00001517          	auipc	a0,0x1
     1ac:	02050513          	addi	a0,a0,32 # 11c8 <malloc+0x172>
     1b0:	20b000ef          	jal	bba <open>
     1b4:	8a2a                	mv	s4,a0
     1b6:	bf81                	j	106 <go+0x92>
    } else if(what == 6){
      close(fd);
     1b8:	8552                	mv	a0,s4
     1ba:	1e9000ef          	jal	ba2 <close>
      fd = open("/./grindir/./../b", O_CREATE|O_RDWR);
     1be:	20200593          	li	a1,514
     1c2:	00001517          	auipc	a0,0x1
     1c6:	01650513          	addi	a0,a0,22 # 11d8 <malloc+0x182>
     1ca:	1f1000ef          	jal	bba <open>
     1ce:	8a2a                	mv	s4,a0
     1d0:	bf1d                	j	106 <go+0x92>
    } else if(what == 7){
      write(fd, buf, sizeof(buf));
     1d2:	3e700613          	li	a2,999
     1d6:	00002597          	auipc	a1,0x2
     1da:	e4a58593          	addi	a1,a1,-438 # 2020 <buf.0>
     1de:	8552                	mv	a0,s4
     1e0:	1bb000ef          	jal	b9a <write>
     1e4:	b70d                	j	106 <go+0x92>
    } else if(what == 8){
      read(fd, buf, sizeof(buf));
     1e6:	3e700613          	li	a2,999
     1ea:	00002597          	auipc	a1,0x2
     1ee:	e3658593          	addi	a1,a1,-458 # 2020 <buf.0>
     1f2:	8552                	mv	a0,s4
     1f4:	19f000ef          	jal	b92 <read>
     1f8:	b739                	j	106 <go+0x92>
    } else if(what == 9){
      mkdir("grindir/../a");
     1fa:	00001517          	auipc	a0,0x1
     1fe:	f9e50513          	addi	a0,a0,-98 # 1198 <malloc+0x142>
     202:	1e1000ef          	jal	be2 <mkdir>
      close(open("a/../a/./a", O_CREATE|O_RDWR));
     206:	20200593          	li	a1,514
     20a:	00001517          	auipc	a0,0x1
     20e:	fe650513          	addi	a0,a0,-26 # 11f0 <malloc+0x19a>
     212:	1a9000ef          	jal	bba <open>
     216:	18d000ef          	jal	ba2 <close>
      unlink("a/a");
     21a:	00001517          	auipc	a0,0x1
     21e:	fe650513          	addi	a0,a0,-26 # 1200 <malloc+0x1aa>
     222:	1a9000ef          	jal	bca <unlink>
     226:	b5c5                	j	106 <go+0x92>
    } else if(what == 10){
      mkdir("/../b");
     228:	00001517          	auipc	a0,0x1
     22c:	fe050513          	addi	a0,a0,-32 # 1208 <malloc+0x1b2>
     230:	1b3000ef          	jal	be2 <mkdir>
      close(open("grindir/../b/b", O_CREATE|O_RDWR));
     234:	20200593          	li	a1,514
     238:	00001517          	auipc	a0,0x1
     23c:	fd850513          	addi	a0,a0,-40 # 1210 <malloc+0x1ba>
     240:	17b000ef          	jal	bba <open>
     244:	15f000ef          	jal	ba2 <close>
      unlink("b/b");
     248:	00001517          	auipc	a0,0x1
     24c:	fd850513          	addi	a0,a0,-40 # 1220 <malloc+0x1ca>
     250:	17b000ef          	jal	bca <unlink>
     254:	bd4d                	j	106 <go+0x92>
    } else if(what == 11){
      unlink("b");
     256:	00001517          	auipc	a0,0x1
     25a:	fd250513          	addi	a0,a0,-46 # 1228 <malloc+0x1d2>
     25e:	16d000ef          	jal	bca <unlink>
      link("../grindir/./../a", "../b");
     262:	00001597          	auipc	a1,0x1
     266:	f5e58593          	addi	a1,a1,-162 # 11c0 <malloc+0x16a>
     26a:	00001517          	auipc	a0,0x1
     26e:	fc650513          	addi	a0,a0,-58 # 1230 <malloc+0x1da>
     272:	169000ef          	jal	bda <link>
     276:	bd41                	j	106 <go+0x92>
    } else if(what == 12){
      unlink("../grindir/../a");
     278:	00001517          	auipc	a0,0x1
     27c:	fd050513          	addi	a0,a0,-48 # 1248 <malloc+0x1f2>
     280:	14b000ef          	jal	bca <unlink>
      link(".././b", "/grindir/../a");
     284:	00001597          	auipc	a1,0x1
     288:	f4458593          	addi	a1,a1,-188 # 11c8 <malloc+0x172>
     28c:	00001517          	auipc	a0,0x1
     290:	fcc50513          	addi	a0,a0,-52 # 1258 <malloc+0x202>
     294:	147000ef          	jal	bda <link>
     298:	b5bd                	j	106 <go+0x92>
    } else if(what == 13){
      int pid = fork();
     29a:	0d9000ef          	jal	b72 <fork>
      if(pid == 0){
     29e:	c519                	beqz	a0,2ac <go+0x238>
        exit(0);
      } else if(pid < 0){
     2a0:	00054863          	bltz	a0,2b0 <go+0x23c>
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
     2a4:	4501                	li	a0,0
     2a6:	0dd000ef          	jal	b82 <wait>
     2aa:	bdb1                	j	106 <go+0x92>
        exit(0);
     2ac:	0cf000ef          	jal	b7a <exit>
        printf("grind: fork failed\n");
     2b0:	00001517          	auipc	a0,0x1
     2b4:	fb050513          	addi	a0,a0,-80 # 1260 <malloc+0x20a>
     2b8:	4eb000ef          	jal	fa2 <printf>
        exit(1);
     2bc:	4505                	li	a0,1
     2be:	0bd000ef          	jal	b7a <exit>
    } else if(what == 14){
      int pid = fork();
     2c2:	0b1000ef          	jal	b72 <fork>
      if(pid == 0){
     2c6:	c519                	beqz	a0,2d4 <go+0x260>
        fork();
        fork();
        exit(0);
      } else if(pid < 0){
     2c8:	00054d63          	bltz	a0,2e2 <go+0x26e>
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
     2cc:	4501                	li	a0,0
     2ce:	0b5000ef          	jal	b82 <wait>
     2d2:	bd15                	j	106 <go+0x92>
        fork();
     2d4:	09f000ef          	jal	b72 <fork>
        fork();
     2d8:	09b000ef          	jal	b72 <fork>
        exit(0);
     2dc:	4501                	li	a0,0
     2de:	09d000ef          	jal	b7a <exit>
        printf("grind: fork failed\n");
     2e2:	00001517          	auipc	a0,0x1
     2e6:	f7e50513          	addi	a0,a0,-130 # 1260 <malloc+0x20a>
     2ea:	4b9000ef          	jal	fa2 <printf>
        exit(1);
     2ee:	4505                	li	a0,1
     2f0:	08b000ef          	jal	b7a <exit>
    } else if(what == 15){
      sbrk(6011);
     2f4:	6505                	lui	a0,0x1
     2f6:	77b50513          	addi	a0,a0,1915 # 177b <digits+0x2bb>
     2fa:	045000ef          	jal	b3e <sbrk>
     2fe:	b521                	j	106 <go+0x92>
    } else if(what == 16){
      if(sbrk(0) > break0)
     300:	4501                	li	a0,0
     302:	03d000ef          	jal	b3e <sbrk>
     306:	e0aaf0e3          	bgeu	s5,a0,106 <go+0x92>
        sbrk(-(sbrk(0) - break0));
     30a:	4501                	li	a0,0
     30c:	033000ef          	jal	b3e <sbrk>
     310:	40aa853b          	subw	a0,s5,a0
     314:	02b000ef          	jal	b3e <sbrk>
     318:	b3fd                	j	106 <go+0x92>
    } else if(what == 17){
      int pid = fork();
     31a:	059000ef          	jal	b72 <fork>
     31e:	8b2a                	mv	s6,a0
      if(pid == 0){
     320:	c10d                	beqz	a0,342 <go+0x2ce>
        close(open("a", O_CREATE|O_RDWR));
        exit(0);
      } else if(pid < 0){
     322:	02054d63          	bltz	a0,35c <go+0x2e8>
        printf("grind: fork failed\n");
        exit(1);
      }
      if(chdir("../grindir/..") != 0){
     326:	00001517          	auipc	a0,0x1
     32a:	f5a50513          	addi	a0,a0,-166 # 1280 <malloc+0x22a>
     32e:	0bd000ef          	jal	bea <chdir>
     332:	ed15                	bnez	a0,36e <go+0x2fa>
        printf("grind: chdir failed\n");
        exit(1);
      }
      kill(pid);
     334:	855a                	mv	a0,s6
     336:	075000ef          	jal	baa <kill>
      wait(0);
     33a:	4501                	li	a0,0
     33c:	047000ef          	jal	b82 <wait>
     340:	b3d9                	j	106 <go+0x92>
        close(open("a", O_CREATE|O_RDWR));
     342:	20200593          	li	a1,514
     346:	00001517          	auipc	a0,0x1
     34a:	f3250513          	addi	a0,a0,-206 # 1278 <malloc+0x222>
     34e:	06d000ef          	jal	bba <open>
     352:	051000ef          	jal	ba2 <close>
        exit(0);
     356:	4501                	li	a0,0
     358:	023000ef          	jal	b7a <exit>
        printf("grind: fork failed\n");
     35c:	00001517          	auipc	a0,0x1
     360:	f0450513          	addi	a0,a0,-252 # 1260 <malloc+0x20a>
     364:	43f000ef          	jal	fa2 <printf>
        exit(1);
     368:	4505                	li	a0,1
     36a:	011000ef          	jal	b7a <exit>
        printf("grind: chdir failed\n");
     36e:	00001517          	auipc	a0,0x1
     372:	f2250513          	addi	a0,a0,-222 # 1290 <malloc+0x23a>
     376:	42d000ef          	jal	fa2 <printf>
        exit(1);
     37a:	4505                	li	a0,1
     37c:	7fe000ef          	jal	b7a <exit>
    } else if(what == 18){
      int pid = fork();
     380:	7f2000ef          	jal	b72 <fork>
      if(pid == 0){
     384:	c519                	beqz	a0,392 <go+0x31e>
        kill(getpid());
        exit(0);
      } else if(pid < 0){
     386:	00054d63          	bltz	a0,3a0 <go+0x32c>
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
     38a:	4501                	li	a0,0
     38c:	7f6000ef          	jal	b82 <wait>
     390:	bb9d                	j	106 <go+0x92>
        kill(getpid());
     392:	069000ef          	jal	bfa <getpid>
     396:	015000ef          	jal	baa <kill>
        exit(0);
     39a:	4501                	li	a0,0
     39c:	7de000ef          	jal	b7a <exit>
        printf("grind: fork failed\n");
     3a0:	00001517          	auipc	a0,0x1
     3a4:	ec050513          	addi	a0,a0,-320 # 1260 <malloc+0x20a>
     3a8:	3fb000ef          	jal	fa2 <printf>
        exit(1);
     3ac:	4505                	li	a0,1
     3ae:	7cc000ef          	jal	b7a <exit>
    } else if(what == 19){
      int fds[2];
      if(pipe(fds) < 0){
     3b2:	fa840513          	addi	a0,s0,-88
     3b6:	7d4000ef          	jal	b8a <pipe>
     3ba:	02054363          	bltz	a0,3e0 <go+0x36c>
        printf("grind: pipe failed\n");
        exit(1);
      }
      int pid = fork();
     3be:	7b4000ef          	jal	b72 <fork>
      if(pid == 0){
     3c2:	c905                	beqz	a0,3f2 <go+0x37e>
          printf("grind: pipe write failed\n");
        char c;
        if(read(fds[0], &c, 1) != 1)
          printf("grind: pipe read failed\n");
        exit(0);
      } else if(pid < 0){
     3c4:	08054263          	bltz	a0,448 <go+0x3d4>
        printf("grind: fork failed\n");
        exit(1);
      }
      close(fds[0]);
     3c8:	fa842503          	lw	a0,-88(s0)
     3cc:	7d6000ef          	jal	ba2 <close>
      close(fds[1]);
     3d0:	fac42503          	lw	a0,-84(s0)
     3d4:	7ce000ef          	jal	ba2 <close>
      wait(0);
     3d8:	4501                	li	a0,0
     3da:	7a8000ef          	jal	b82 <wait>
     3de:	b325                	j	106 <go+0x92>
        printf("grind: pipe failed\n");
     3e0:	00001517          	auipc	a0,0x1
     3e4:	ec850513          	addi	a0,a0,-312 # 12a8 <malloc+0x252>
     3e8:	3bb000ef          	jal	fa2 <printf>
        exit(1);
     3ec:	4505                	li	a0,1
     3ee:	78c000ef          	jal	b7a <exit>
        fork();
     3f2:	780000ef          	jal	b72 <fork>
        fork();
     3f6:	77c000ef          	jal	b72 <fork>
        if(write(fds[1], "x", 1) != 1)
     3fa:	4605                	li	a2,1
     3fc:	00001597          	auipc	a1,0x1
     400:	ec458593          	addi	a1,a1,-316 # 12c0 <malloc+0x26a>
     404:	fac42503          	lw	a0,-84(s0)
     408:	792000ef          	jal	b9a <write>
     40c:	4785                	li	a5,1
     40e:	00f51f63          	bne	a0,a5,42c <go+0x3b8>
        if(read(fds[0], &c, 1) != 1)
     412:	4605                	li	a2,1
     414:	fa040593          	addi	a1,s0,-96
     418:	fa842503          	lw	a0,-88(s0)
     41c:	776000ef          	jal	b92 <read>
     420:	4785                	li	a5,1
     422:	00f51c63          	bne	a0,a5,43a <go+0x3c6>
        exit(0);
     426:	4501                	li	a0,0
     428:	752000ef          	jal	b7a <exit>
          printf("grind: pipe write failed\n");
     42c:	00001517          	auipc	a0,0x1
     430:	e9c50513          	addi	a0,a0,-356 # 12c8 <malloc+0x272>
     434:	36f000ef          	jal	fa2 <printf>
     438:	bfe9                	j	412 <go+0x39e>
          printf("grind: pipe read failed\n");
     43a:	00001517          	auipc	a0,0x1
     43e:	eae50513          	addi	a0,a0,-338 # 12e8 <malloc+0x292>
     442:	361000ef          	jal	fa2 <printf>
     446:	b7c5                	j	426 <go+0x3b2>
        printf("grind: fork failed\n");
     448:	00001517          	auipc	a0,0x1
     44c:	e1850513          	addi	a0,a0,-488 # 1260 <malloc+0x20a>
     450:	353000ef          	jal	fa2 <printf>
        exit(1);
     454:	4505                	li	a0,1
     456:	724000ef          	jal	b7a <exit>
    } else if(what == 20){
      int pid = fork();
     45a:	718000ef          	jal	b72 <fork>
      if(pid == 0){
     45e:	c519                	beqz	a0,46c <go+0x3f8>
        chdir("a");
        unlink("../a");
        fd = open("x", O_CREATE|O_RDWR);
        unlink("x");
        exit(0);
      } else if(pid < 0){
     460:	04054f63          	bltz	a0,4be <go+0x44a>
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
     464:	4501                	li	a0,0
     466:	71c000ef          	jal	b82 <wait>
     46a:	b971                	j	106 <go+0x92>
        unlink("a");
     46c:	00001517          	auipc	a0,0x1
     470:	e0c50513          	addi	a0,a0,-500 # 1278 <malloc+0x222>
     474:	756000ef          	jal	bca <unlink>
        mkdir("a");
     478:	00001517          	auipc	a0,0x1
     47c:	e0050513          	addi	a0,a0,-512 # 1278 <malloc+0x222>
     480:	762000ef          	jal	be2 <mkdir>
        chdir("a");
     484:	00001517          	auipc	a0,0x1
     488:	df450513          	addi	a0,a0,-524 # 1278 <malloc+0x222>
     48c:	75e000ef          	jal	bea <chdir>
        unlink("../a");
     490:	00001517          	auipc	a0,0x1
     494:	e7850513          	addi	a0,a0,-392 # 1308 <malloc+0x2b2>
     498:	732000ef          	jal	bca <unlink>
        fd = open("x", O_CREATE|O_RDWR);
     49c:	20200593          	li	a1,514
     4a0:	00001517          	auipc	a0,0x1
     4a4:	e2050513          	addi	a0,a0,-480 # 12c0 <malloc+0x26a>
     4a8:	712000ef          	jal	bba <open>
        unlink("x");
     4ac:	00001517          	auipc	a0,0x1
     4b0:	e1450513          	addi	a0,a0,-492 # 12c0 <malloc+0x26a>
     4b4:	716000ef          	jal	bca <unlink>
        exit(0);
     4b8:	4501                	li	a0,0
     4ba:	6c0000ef          	jal	b7a <exit>
        printf("grind: fork failed\n");
     4be:	00001517          	auipc	a0,0x1
     4c2:	da250513          	addi	a0,a0,-606 # 1260 <malloc+0x20a>
     4c6:	2dd000ef          	jal	fa2 <printf>
        exit(1);
     4ca:	4505                	li	a0,1
     4cc:	6ae000ef          	jal	b7a <exit>
    } else if(what == 21){
      unlink("c");
     4d0:	00001517          	auipc	a0,0x1
     4d4:	e4050513          	addi	a0,a0,-448 # 1310 <malloc+0x2ba>
     4d8:	6f2000ef          	jal	bca <unlink>
      // should always succeed. check that there are free i-nodes,
      // file descriptors, blocks.
      int fd1 = open("c", O_CREATE|O_RDWR);
     4dc:	20200593          	li	a1,514
     4e0:	00001517          	auipc	a0,0x1
     4e4:	e3050513          	addi	a0,a0,-464 # 1310 <malloc+0x2ba>
     4e8:	6d2000ef          	jal	bba <open>
     4ec:	8b2a                	mv	s6,a0
      if(fd1 < 0){
     4ee:	04054763          	bltz	a0,53c <go+0x4c8>
        printf("grind: create c failed\n");
        exit(1);
      }
      if(write(fd1, "x", 1) != 1){
     4f2:	4605                	li	a2,1
     4f4:	00001597          	auipc	a1,0x1
     4f8:	dcc58593          	addi	a1,a1,-564 # 12c0 <malloc+0x26a>
     4fc:	69e000ef          	jal	b9a <write>
     500:	4785                	li	a5,1
     502:	04f51663          	bne	a0,a5,54e <go+0x4da>
        printf("grind: write c failed\n");
        exit(1);
      }
      struct stat st;
      if(fstat(fd1, &st) != 0){
     506:	fa840593          	addi	a1,s0,-88
     50a:	855a                	mv	a0,s6
     50c:	6c6000ef          	jal	bd2 <fstat>
     510:	e921                	bnez	a0,560 <go+0x4ec>
        printf("grind: fstat failed\n");
        exit(1);
      }
      if(st.size != 1){
     512:	fb843583          	ld	a1,-72(s0)
     516:	4785                	li	a5,1
     518:	04f59d63          	bne	a1,a5,572 <go+0x4fe>
        printf("grind: fstat reports wrong size %d\n", (int)st.size);
        exit(1);
      }
      if(st.ino > 200){
     51c:	fac42583          	lw	a1,-84(s0)
     520:	0c800793          	li	a5,200
     524:	06b7e163          	bltu	a5,a1,586 <go+0x512>
        printf("grind: fstat reports crazy i-number %d\n", st.ino);
        exit(1);
      }
      close(fd1);
     528:	855a                	mv	a0,s6
     52a:	678000ef          	jal	ba2 <close>
      unlink("c");
     52e:	00001517          	auipc	a0,0x1
     532:	de250513          	addi	a0,a0,-542 # 1310 <malloc+0x2ba>
     536:	694000ef          	jal	bca <unlink>
     53a:	b6f1                	j	106 <go+0x92>
        printf("grind: create c failed\n");
     53c:	00001517          	auipc	a0,0x1
     540:	ddc50513          	addi	a0,a0,-548 # 1318 <malloc+0x2c2>
     544:	25f000ef          	jal	fa2 <printf>
        exit(1);
     548:	4505                	li	a0,1
     54a:	630000ef          	jal	b7a <exit>
        printf("grind: write c failed\n");
     54e:	00001517          	auipc	a0,0x1
     552:	de250513          	addi	a0,a0,-542 # 1330 <malloc+0x2da>
     556:	24d000ef          	jal	fa2 <printf>
        exit(1);
     55a:	4505                	li	a0,1
     55c:	61e000ef          	jal	b7a <exit>
        printf("grind: fstat failed\n");
     560:	00001517          	auipc	a0,0x1
     564:	de850513          	addi	a0,a0,-536 # 1348 <malloc+0x2f2>
     568:	23b000ef          	jal	fa2 <printf>
        exit(1);
     56c:	4505                	li	a0,1
     56e:	60c000ef          	jal	b7a <exit>
        printf("grind: fstat reports wrong size %d\n", (int)st.size);
     572:	2581                	sext.w	a1,a1
     574:	00001517          	auipc	a0,0x1
     578:	dec50513          	addi	a0,a0,-532 # 1360 <malloc+0x30a>
     57c:	227000ef          	jal	fa2 <printf>
        exit(1);
     580:	4505                	li	a0,1
     582:	5f8000ef          	jal	b7a <exit>
        printf("grind: fstat reports crazy i-number %d\n", st.ino);
     586:	00001517          	auipc	a0,0x1
     58a:	e0250513          	addi	a0,a0,-510 # 1388 <malloc+0x332>
     58e:	215000ef          	jal	fa2 <printf>
        exit(1);
     592:	4505                	li	a0,1
     594:	5e6000ef          	jal	b7a <exit>
    } else if(what == 22){
      // echo hi | cat
      int aa[2], bb[2];
      if(pipe(aa) < 0){
     598:	f9840513          	addi	a0,s0,-104
     59c:	5ee000ef          	jal	b8a <pipe>
     5a0:	0c054263          	bltz	a0,664 <go+0x5f0>
        fprintf(2, "grind: pipe failed\n");
        exit(1);
      }
      if(pipe(bb) < 0){
     5a4:	fa040513          	addi	a0,s0,-96
     5a8:	5e2000ef          	jal	b8a <pipe>
     5ac:	0c054663          	bltz	a0,678 <go+0x604>
        fprintf(2, "grind: pipe failed\n");
        exit(1);
      }
      int pid1 = fork();
     5b0:	5c2000ef          	jal	b72 <fork>
      if(pid1 == 0){
     5b4:	0c050c63          	beqz	a0,68c <go+0x618>
        close(aa[1]);
        char *args[3] = { "echo", "hi", 0 };
        exec("grindir/../echo", args);
        fprintf(2, "grind: echo: not found\n");
        exit(2);
      } else if(pid1 < 0){
     5b8:	14054e63          	bltz	a0,714 <go+0x6a0>
        fprintf(2, "grind: fork failed\n");
        exit(3);
      }
      int pid2 = fork();
     5bc:	5b6000ef          	jal	b72 <fork>
      if(pid2 == 0){
     5c0:	16050463          	beqz	a0,728 <go+0x6b4>
        close(bb[1]);
        char *args[2] = { "cat", 0 };
        exec("/cat", args);
        fprintf(2, "grind: cat: not found\n");
        exit(6);
      } else if(pid2 < 0){
     5c4:	20054263          	bltz	a0,7c8 <go+0x754>
        fprintf(2, "grind: fork failed\n");
        exit(7);
      }
      close(aa[0]);
     5c8:	f9842503          	lw	a0,-104(s0)
     5cc:	5d6000ef          	jal	ba2 <close>
      close(aa[1]);
     5d0:	f9c42503          	lw	a0,-100(s0)
     5d4:	5ce000ef          	jal	ba2 <close>
      close(bb[1]);
     5d8:	fa442503          	lw	a0,-92(s0)
     5dc:	5c6000ef          	jal	ba2 <close>
      char buf[4] = { 0, 0, 0, 0 };
     5e0:	f8042823          	sw	zero,-112(s0)
      read(bb[0], buf+0, 1);
     5e4:	4605                	li	a2,1
     5e6:	f9040593          	addi	a1,s0,-112
     5ea:	fa042503          	lw	a0,-96(s0)
     5ee:	5a4000ef          	jal	b92 <read>
      read(bb[0], buf+1, 1);
     5f2:	4605                	li	a2,1
     5f4:	f9140593          	addi	a1,s0,-111
     5f8:	fa042503          	lw	a0,-96(s0)
     5fc:	596000ef          	jal	b92 <read>
      read(bb[0], buf+2, 1);
     600:	4605                	li	a2,1
     602:	f9240593          	addi	a1,s0,-110
     606:	fa042503          	lw	a0,-96(s0)
     60a:	588000ef          	jal	b92 <read>
      close(bb[0]);
     60e:	fa042503          	lw	a0,-96(s0)
     612:	590000ef          	jal	ba2 <close>
      int st1, st2;
      wait(&st1);
     616:	f9440513          	addi	a0,s0,-108
     61a:	568000ef          	jal	b82 <wait>
      wait(&st2);
     61e:	fa840513          	addi	a0,s0,-88
     622:	560000ef          	jal	b82 <wait>
      if(st1 != 0 || st2 != 0 || strcmp(buf, "hi\n") != 0){
     626:	f9442783          	lw	a5,-108(s0)
     62a:	fa842703          	lw	a4,-88(s0)
     62e:	8fd9                	or	a5,a5,a4
     630:	eb99                	bnez	a5,646 <go+0x5d2>
     632:	00001597          	auipc	a1,0x1
     636:	df658593          	addi	a1,a1,-522 # 1428 <malloc+0x3d2>
     63a:	f9040513          	addi	a0,s0,-112
     63e:	2cc000ef          	jal	90a <strcmp>
     642:	ac0502e3          	beqz	a0,106 <go+0x92>
        printf("grind: exec pipeline failed %d %d \"%s\"\n", st1, st2, buf);
     646:	f9040693          	addi	a3,s0,-112
     64a:	fa842603          	lw	a2,-88(s0)
     64e:	f9442583          	lw	a1,-108(s0)
     652:	00001517          	auipc	a0,0x1
     656:	dde50513          	addi	a0,a0,-546 # 1430 <malloc+0x3da>
     65a:	149000ef          	jal	fa2 <printf>
        exit(1);
     65e:	4505                	li	a0,1
     660:	51a000ef          	jal	b7a <exit>
        fprintf(2, "grind: pipe failed\n");
     664:	00001597          	auipc	a1,0x1
     668:	c4458593          	addi	a1,a1,-956 # 12a8 <malloc+0x252>
     66c:	4509                	li	a0,2
     66e:	10b000ef          	jal	f78 <fprintf>
        exit(1);
     672:	4505                	li	a0,1
     674:	506000ef          	jal	b7a <exit>
        fprintf(2, "grind: pipe failed\n");
     678:	00001597          	auipc	a1,0x1
     67c:	c3058593          	addi	a1,a1,-976 # 12a8 <malloc+0x252>
     680:	4509                	li	a0,2
     682:	0f7000ef          	jal	f78 <fprintf>
        exit(1);
     686:	4505                	li	a0,1
     688:	4f2000ef          	jal	b7a <exit>
        close(bb[0]);
     68c:	fa042503          	lw	a0,-96(s0)
     690:	512000ef          	jal	ba2 <close>
        close(bb[1]);
     694:	fa442503          	lw	a0,-92(s0)
     698:	50a000ef          	jal	ba2 <close>
        close(aa[0]);
     69c:	f9842503          	lw	a0,-104(s0)
     6a0:	502000ef          	jal	ba2 <close>
        close(1);
     6a4:	4505                	li	a0,1
     6a6:	4fc000ef          	jal	ba2 <close>
        if(dup(aa[1]) != 1){
     6aa:	f9c42503          	lw	a0,-100(s0)
     6ae:	544000ef          	jal	bf2 <dup>
     6b2:	4785                	li	a5,1
     6b4:	00f50c63          	beq	a0,a5,6cc <go+0x658>
          fprintf(2, "grind: dup failed\n");
     6b8:	00001597          	auipc	a1,0x1
     6bc:	cf858593          	addi	a1,a1,-776 # 13b0 <malloc+0x35a>
     6c0:	4509                	li	a0,2
     6c2:	0b7000ef          	jal	f78 <fprintf>
          exit(1);
     6c6:	4505                	li	a0,1
     6c8:	4b2000ef          	jal	b7a <exit>
        close(aa[1]);
     6cc:	f9c42503          	lw	a0,-100(s0)
     6d0:	4d2000ef          	jal	ba2 <close>
        char *args[3] = { "echo", "hi", 0 };
     6d4:	00001797          	auipc	a5,0x1
     6d8:	cf478793          	addi	a5,a5,-780 # 13c8 <malloc+0x372>
     6dc:	faf43423          	sd	a5,-88(s0)
     6e0:	00001797          	auipc	a5,0x1
     6e4:	cf078793          	addi	a5,a5,-784 # 13d0 <malloc+0x37a>
     6e8:	faf43823          	sd	a5,-80(s0)
     6ec:	fa043c23          	sd	zero,-72(s0)
        exec("grindir/../echo", args);
     6f0:	fa840593          	addi	a1,s0,-88
     6f4:	00001517          	auipc	a0,0x1
     6f8:	ce450513          	addi	a0,a0,-796 # 13d8 <malloc+0x382>
     6fc:	4b6000ef          	jal	bb2 <exec>
        fprintf(2, "grind: echo: not found\n");
     700:	00001597          	auipc	a1,0x1
     704:	ce858593          	addi	a1,a1,-792 # 13e8 <malloc+0x392>
     708:	4509                	li	a0,2
     70a:	06f000ef          	jal	f78 <fprintf>
        exit(2);
     70e:	4509                	li	a0,2
     710:	46a000ef          	jal	b7a <exit>
        fprintf(2, "grind: fork failed\n");
     714:	00001597          	auipc	a1,0x1
     718:	b4c58593          	addi	a1,a1,-1204 # 1260 <malloc+0x20a>
     71c:	4509                	li	a0,2
     71e:	05b000ef          	jal	f78 <fprintf>
        exit(3);
     722:	450d                	li	a0,3
     724:	456000ef          	jal	b7a <exit>
        close(aa[1]);
     728:	f9c42503          	lw	a0,-100(s0)
     72c:	476000ef          	jal	ba2 <close>
        close(bb[0]);
     730:	fa042503          	lw	a0,-96(s0)
     734:	46e000ef          	jal	ba2 <close>
        close(0);
     738:	4501                	li	a0,0
     73a:	468000ef          	jal	ba2 <close>
        if(dup(aa[0]) != 0){
     73e:	f9842503          	lw	a0,-104(s0)
     742:	4b0000ef          	jal	bf2 <dup>
     746:	c919                	beqz	a0,75c <go+0x6e8>
          fprintf(2, "grind: dup failed\n");
     748:	00001597          	auipc	a1,0x1
     74c:	c6858593          	addi	a1,a1,-920 # 13b0 <malloc+0x35a>
     750:	4509                	li	a0,2
     752:	027000ef          	jal	f78 <fprintf>
          exit(4);
     756:	4511                	li	a0,4
     758:	422000ef          	jal	b7a <exit>
        close(aa[0]);
     75c:	f9842503          	lw	a0,-104(s0)
     760:	442000ef          	jal	ba2 <close>
        close(1);
     764:	4505                	li	a0,1
     766:	43c000ef          	jal	ba2 <close>
        if(dup(bb[1]) != 1){
     76a:	fa442503          	lw	a0,-92(s0)
     76e:	484000ef          	jal	bf2 <dup>
     772:	4785                	li	a5,1
     774:	00f50c63          	beq	a0,a5,78c <go+0x718>
          fprintf(2, "grind: dup failed\n");
     778:	00001597          	auipc	a1,0x1
     77c:	c3858593          	addi	a1,a1,-968 # 13b0 <malloc+0x35a>
     780:	4509                	li	a0,2
     782:	7f6000ef          	jal	f78 <fprintf>
          exit(5);
     786:	4515                	li	a0,5
     788:	3f2000ef          	jal	b7a <exit>
        close(bb[1]);
     78c:	fa442503          	lw	a0,-92(s0)
     790:	412000ef          	jal	ba2 <close>
        char *args[2] = { "cat", 0 };
     794:	00001797          	auipc	a5,0x1
     798:	c6c78793          	addi	a5,a5,-916 # 1400 <malloc+0x3aa>
     79c:	faf43423          	sd	a5,-88(s0)
     7a0:	fa043823          	sd	zero,-80(s0)
        exec("/cat", args);
     7a4:	fa840593          	addi	a1,s0,-88
     7a8:	00001517          	auipc	a0,0x1
     7ac:	c6050513          	addi	a0,a0,-928 # 1408 <malloc+0x3b2>
     7b0:	402000ef          	jal	bb2 <exec>
        fprintf(2, "grind: cat: not found\n");
     7b4:	00001597          	auipc	a1,0x1
     7b8:	c5c58593          	addi	a1,a1,-932 # 1410 <malloc+0x3ba>
     7bc:	4509                	li	a0,2
     7be:	7ba000ef          	jal	f78 <fprintf>
        exit(6);
     7c2:	4519                	li	a0,6
     7c4:	3b6000ef          	jal	b7a <exit>
        fprintf(2, "grind: fork failed\n");
     7c8:	00001597          	auipc	a1,0x1
     7cc:	a9858593          	addi	a1,a1,-1384 # 1260 <malloc+0x20a>
     7d0:	4509                	li	a0,2
     7d2:	7a6000ef          	jal	f78 <fprintf>
        exit(7);
     7d6:	451d                	li	a0,7
     7d8:	3a2000ef          	jal	b7a <exit>

00000000000007dc <iter>:
  }
}

void
iter()
{
     7dc:	7179                	addi	sp,sp,-48
     7de:	f406                	sd	ra,40(sp)
     7e0:	f022                	sd	s0,32(sp)
     7e2:	1800                	addi	s0,sp,48
  unlink("a");
     7e4:	00001517          	auipc	a0,0x1
     7e8:	a9450513          	addi	a0,a0,-1388 # 1278 <malloc+0x222>
     7ec:	3de000ef          	jal	bca <unlink>
  unlink("b");
     7f0:	00001517          	auipc	a0,0x1
     7f4:	a3850513          	addi	a0,a0,-1480 # 1228 <malloc+0x1d2>
     7f8:	3d2000ef          	jal	bca <unlink>
  
  int pid1 = fork();
     7fc:	376000ef          	jal	b72 <fork>
  if(pid1 < 0){
     800:	02054163          	bltz	a0,822 <iter+0x46>
     804:	ec26                	sd	s1,24(sp)
     806:	84aa                	mv	s1,a0
    printf("grind: fork failed\n");
    exit(1);
  }
  if(pid1 == 0){
     808:	e905                	bnez	a0,838 <iter+0x5c>
     80a:	e84a                	sd	s2,16(sp)
    rand_next ^= 31;
     80c:	00001717          	auipc	a4,0x1
     810:	7f470713          	addi	a4,a4,2036 # 2000 <rand_next>
     814:	631c                	ld	a5,0(a4)
     816:	01f7c793          	xori	a5,a5,31
     81a:	e31c                	sd	a5,0(a4)
    go(0);
     81c:	4501                	li	a0,0
     81e:	857ff0ef          	jal	74 <go>
     822:	ec26                	sd	s1,24(sp)
     824:	e84a                	sd	s2,16(sp)
    printf("grind: fork failed\n");
     826:	00001517          	auipc	a0,0x1
     82a:	a3a50513          	addi	a0,a0,-1478 # 1260 <malloc+0x20a>
     82e:	774000ef          	jal	fa2 <printf>
    exit(1);
     832:	4505                	li	a0,1
     834:	346000ef          	jal	b7a <exit>
     838:	e84a                	sd	s2,16(sp)
    exit(0);
  }

  int pid2 = fork();
     83a:	338000ef          	jal	b72 <fork>
     83e:	892a                	mv	s2,a0
  if(pid2 < 0){
     840:	02054063          	bltz	a0,860 <iter+0x84>
    printf("grind: fork failed\n");
    exit(1);
  }
  if(pid2 == 0){
     844:	e51d                	bnez	a0,872 <iter+0x96>
    rand_next ^= 7177;
     846:	00001697          	auipc	a3,0x1
     84a:	7ba68693          	addi	a3,a3,1978 # 2000 <rand_next>
     84e:	629c                	ld	a5,0(a3)
     850:	6709                	lui	a4,0x2
     852:	c0970713          	addi	a4,a4,-1015 # 1c09 <digits+0x749>
     856:	8fb9                	xor	a5,a5,a4
     858:	e29c                	sd	a5,0(a3)
    go(1);
     85a:	4505                	li	a0,1
     85c:	819ff0ef          	jal	74 <go>
    printf("grind: fork failed\n");
     860:	00001517          	auipc	a0,0x1
     864:	a0050513          	addi	a0,a0,-1536 # 1260 <malloc+0x20a>
     868:	73a000ef          	jal	fa2 <printf>
    exit(1);
     86c:	4505                	li	a0,1
     86e:	30c000ef          	jal	b7a <exit>
    exit(0);
  }

  int st1 = -1;
     872:	57fd                	li	a5,-1
     874:	fcf42e23          	sw	a5,-36(s0)
  wait(&st1);
     878:	fdc40513          	addi	a0,s0,-36
     87c:	306000ef          	jal	b82 <wait>
  if(st1 != 0){
     880:	fdc42783          	lw	a5,-36(s0)
     884:	eb99                	bnez	a5,89a <iter+0xbe>
    kill(pid1);
    kill(pid2);
  }
  int st2 = -1;
     886:	57fd                	li	a5,-1
     888:	fcf42c23          	sw	a5,-40(s0)
  wait(&st2);
     88c:	fd840513          	addi	a0,s0,-40
     890:	2f2000ef          	jal	b82 <wait>

  exit(0);
     894:	4501                	li	a0,0
     896:	2e4000ef          	jal	b7a <exit>
    kill(pid1);
     89a:	8526                	mv	a0,s1
     89c:	30e000ef          	jal	baa <kill>
    kill(pid2);
     8a0:	854a                	mv	a0,s2
     8a2:	308000ef          	jal	baa <kill>
     8a6:	b7c5                	j	886 <iter+0xaa>

00000000000008a8 <main>:
}

int
main()
{
     8a8:	1101                	addi	sp,sp,-32
     8aa:	ec06                	sd	ra,24(sp)
     8ac:	e822                	sd	s0,16(sp)
     8ae:	e426                	sd	s1,8(sp)
     8b0:	1000                	addi	s0,sp,32
    }
    if(pid > 0){
      wait(0);
    }
    pause(20);
    rand_next += 1;
     8b2:	00001497          	auipc	s1,0x1
     8b6:	74e48493          	addi	s1,s1,1870 # 2000 <rand_next>
     8ba:	a809                	j	8cc <main+0x24>
      iter();
     8bc:	f21ff0ef          	jal	7dc <iter>
    pause(20);
     8c0:	4551                	li	a0,20
     8c2:	348000ef          	jal	c0a <pause>
    rand_next += 1;
     8c6:	609c                	ld	a5,0(s1)
     8c8:	0785                	addi	a5,a5,1
     8ca:	e09c                	sd	a5,0(s1)
    int pid = fork();
     8cc:	2a6000ef          	jal	b72 <fork>
    if(pid == 0){
     8d0:	d575                	beqz	a0,8bc <main+0x14>
    if(pid > 0){
     8d2:	fea057e3          	blez	a0,8c0 <main+0x18>
      wait(0);
     8d6:	4501                	li	a0,0
     8d8:	2aa000ef          	jal	b82 <wait>
     8dc:	b7d5                	j	8c0 <main+0x18>

00000000000008de <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
     8de:	1141                	addi	sp,sp,-16
     8e0:	e406                	sd	ra,8(sp)
     8e2:	e022                	sd	s0,0(sp)
     8e4:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
     8e6:	fc3ff0ef          	jal	8a8 <main>
  exit(r);
     8ea:	290000ef          	jal	b7a <exit>

00000000000008ee <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
     8ee:	1141                	addi	sp,sp,-16
     8f0:	e422                	sd	s0,8(sp)
     8f2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     8f4:	87aa                	mv	a5,a0
     8f6:	0585                	addi	a1,a1,1
     8f8:	0785                	addi	a5,a5,1
     8fa:	fff5c703          	lbu	a4,-1(a1)
     8fe:	fee78fa3          	sb	a4,-1(a5)
     902:	fb75                	bnez	a4,8f6 <strcpy+0x8>
    ;
  return os;
}
     904:	6422                	ld	s0,8(sp)
     906:	0141                	addi	sp,sp,16
     908:	8082                	ret

000000000000090a <strcmp>:

int
strcmp(const char *p, const char *q)
{
     90a:	1141                	addi	sp,sp,-16
     90c:	e422                	sd	s0,8(sp)
     90e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     910:	00054783          	lbu	a5,0(a0)
     914:	cb91                	beqz	a5,928 <strcmp+0x1e>
     916:	0005c703          	lbu	a4,0(a1)
     91a:	00f71763          	bne	a4,a5,928 <strcmp+0x1e>
    p++, q++;
     91e:	0505                	addi	a0,a0,1
     920:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     922:	00054783          	lbu	a5,0(a0)
     926:	fbe5                	bnez	a5,916 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     928:	0005c503          	lbu	a0,0(a1)
}
     92c:	40a7853b          	subw	a0,a5,a0
     930:	6422                	ld	s0,8(sp)
     932:	0141                	addi	sp,sp,16
     934:	8082                	ret

0000000000000936 <strlen>:

uint
strlen(const char *s)
{
     936:	1141                	addi	sp,sp,-16
     938:	e422                	sd	s0,8(sp)
     93a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     93c:	00054783          	lbu	a5,0(a0)
     940:	cf91                	beqz	a5,95c <strlen+0x26>
     942:	0505                	addi	a0,a0,1
     944:	87aa                	mv	a5,a0
     946:	86be                	mv	a3,a5
     948:	0785                	addi	a5,a5,1
     94a:	fff7c703          	lbu	a4,-1(a5)
     94e:	ff65                	bnez	a4,946 <strlen+0x10>
     950:	40a6853b          	subw	a0,a3,a0
     954:	2505                	addiw	a0,a0,1
    ;
  return n;
}
     956:	6422                	ld	s0,8(sp)
     958:	0141                	addi	sp,sp,16
     95a:	8082                	ret
  for(n = 0; s[n]; n++)
     95c:	4501                	li	a0,0
     95e:	bfe5                	j	956 <strlen+0x20>

0000000000000960 <memset>:

void*
memset(void *dst, int c, uint n)
{
     960:	1141                	addi	sp,sp,-16
     962:	e422                	sd	s0,8(sp)
     964:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     966:	ca19                	beqz	a2,97c <memset+0x1c>
     968:	87aa                	mv	a5,a0
     96a:	1602                	slli	a2,a2,0x20
     96c:	9201                	srli	a2,a2,0x20
     96e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     972:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     976:	0785                	addi	a5,a5,1
     978:	fee79de3          	bne	a5,a4,972 <memset+0x12>
  }
  return dst;
}
     97c:	6422                	ld	s0,8(sp)
     97e:	0141                	addi	sp,sp,16
     980:	8082                	ret

0000000000000982 <strchr>:

char*
strchr(const char *s, char c)
{
     982:	1141                	addi	sp,sp,-16
     984:	e422                	sd	s0,8(sp)
     986:	0800                	addi	s0,sp,16
  for(; *s; s++)
     988:	00054783          	lbu	a5,0(a0)
     98c:	cb99                	beqz	a5,9a2 <strchr+0x20>
    if(*s == c)
     98e:	00f58763          	beq	a1,a5,99c <strchr+0x1a>
  for(; *s; s++)
     992:	0505                	addi	a0,a0,1
     994:	00054783          	lbu	a5,0(a0)
     998:	fbfd                	bnez	a5,98e <strchr+0xc>
      return (char*)s;
  return 0;
     99a:	4501                	li	a0,0
}
     99c:	6422                	ld	s0,8(sp)
     99e:	0141                	addi	sp,sp,16
     9a0:	8082                	ret
  return 0;
     9a2:	4501                	li	a0,0
     9a4:	bfe5                	j	99c <strchr+0x1a>

00000000000009a6 <gets>:

char*
gets(char *buf, int max)
{
     9a6:	711d                	addi	sp,sp,-96
     9a8:	ec86                	sd	ra,88(sp)
     9aa:	e8a2                	sd	s0,80(sp)
     9ac:	e4a6                	sd	s1,72(sp)
     9ae:	e0ca                	sd	s2,64(sp)
     9b0:	fc4e                	sd	s3,56(sp)
     9b2:	f852                	sd	s4,48(sp)
     9b4:	f456                	sd	s5,40(sp)
     9b6:	f05a                	sd	s6,32(sp)
     9b8:	ec5e                	sd	s7,24(sp)
     9ba:	1080                	addi	s0,sp,96
     9bc:	8baa                	mv	s7,a0
     9be:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     9c0:	892a                	mv	s2,a0
     9c2:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     9c4:	4aa9                	li	s5,10
     9c6:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     9c8:	89a6                	mv	s3,s1
     9ca:	2485                	addiw	s1,s1,1
     9cc:	0344d663          	bge	s1,s4,9f8 <gets+0x52>
    cc = read(0, &c, 1);
     9d0:	4605                	li	a2,1
     9d2:	faf40593          	addi	a1,s0,-81
     9d6:	4501                	li	a0,0
     9d8:	1ba000ef          	jal	b92 <read>
    if(cc < 1)
     9dc:	00a05e63          	blez	a0,9f8 <gets+0x52>
    buf[i++] = c;
     9e0:	faf44783          	lbu	a5,-81(s0)
     9e4:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     9e8:	01578763          	beq	a5,s5,9f6 <gets+0x50>
     9ec:	0905                	addi	s2,s2,1
     9ee:	fd679de3          	bne	a5,s6,9c8 <gets+0x22>
    buf[i++] = c;
     9f2:	89a6                	mv	s3,s1
     9f4:	a011                	j	9f8 <gets+0x52>
     9f6:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     9f8:	99de                	add	s3,s3,s7
     9fa:	00098023          	sb	zero,0(s3)
  return buf;
}
     9fe:	855e                	mv	a0,s7
     a00:	60e6                	ld	ra,88(sp)
     a02:	6446                	ld	s0,80(sp)
     a04:	64a6                	ld	s1,72(sp)
     a06:	6906                	ld	s2,64(sp)
     a08:	79e2                	ld	s3,56(sp)
     a0a:	7a42                	ld	s4,48(sp)
     a0c:	7aa2                	ld	s5,40(sp)
     a0e:	7b02                	ld	s6,32(sp)
     a10:	6be2                	ld	s7,24(sp)
     a12:	6125                	addi	sp,sp,96
     a14:	8082                	ret

0000000000000a16 <stat>:

int
stat(const char *n, struct stat *st)
{
     a16:	1101                	addi	sp,sp,-32
     a18:	ec06                	sd	ra,24(sp)
     a1a:	e822                	sd	s0,16(sp)
     a1c:	e04a                	sd	s2,0(sp)
     a1e:	1000                	addi	s0,sp,32
     a20:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     a22:	4581                	li	a1,0
     a24:	196000ef          	jal	bba <open>
  if(fd < 0)
     a28:	02054263          	bltz	a0,a4c <stat+0x36>
     a2c:	e426                	sd	s1,8(sp)
     a2e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     a30:	85ca                	mv	a1,s2
     a32:	1a0000ef          	jal	bd2 <fstat>
     a36:	892a                	mv	s2,a0
  close(fd);
     a38:	8526                	mv	a0,s1
     a3a:	168000ef          	jal	ba2 <close>
  return r;
     a3e:	64a2                	ld	s1,8(sp)
}
     a40:	854a                	mv	a0,s2
     a42:	60e2                	ld	ra,24(sp)
     a44:	6442                	ld	s0,16(sp)
     a46:	6902                	ld	s2,0(sp)
     a48:	6105                	addi	sp,sp,32
     a4a:	8082                	ret
    return -1;
     a4c:	597d                	li	s2,-1
     a4e:	bfcd                	j	a40 <stat+0x2a>

0000000000000a50 <atoi>:

int
atoi(const char *s)
{
     a50:	1141                	addi	sp,sp,-16
     a52:	e422                	sd	s0,8(sp)
     a54:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     a56:	00054683          	lbu	a3,0(a0)
     a5a:	fd06879b          	addiw	a5,a3,-48
     a5e:	0ff7f793          	zext.b	a5,a5
     a62:	4625                	li	a2,9
     a64:	02f66863          	bltu	a2,a5,a94 <atoi+0x44>
     a68:	872a                	mv	a4,a0
  n = 0;
     a6a:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
     a6c:	0705                	addi	a4,a4,1
     a6e:	0025179b          	slliw	a5,a0,0x2
     a72:	9fa9                	addw	a5,a5,a0
     a74:	0017979b          	slliw	a5,a5,0x1
     a78:	9fb5                	addw	a5,a5,a3
     a7a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     a7e:	00074683          	lbu	a3,0(a4)
     a82:	fd06879b          	addiw	a5,a3,-48
     a86:	0ff7f793          	zext.b	a5,a5
     a8a:	fef671e3          	bgeu	a2,a5,a6c <atoi+0x1c>
  return n;
}
     a8e:	6422                	ld	s0,8(sp)
     a90:	0141                	addi	sp,sp,16
     a92:	8082                	ret
  n = 0;
     a94:	4501                	li	a0,0
     a96:	bfe5                	j	a8e <atoi+0x3e>

0000000000000a98 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     a98:	1141                	addi	sp,sp,-16
     a9a:	e422                	sd	s0,8(sp)
     a9c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     a9e:	02b57463          	bgeu	a0,a1,ac6 <memmove+0x2e>
    while(n-- > 0)
     aa2:	00c05f63          	blez	a2,ac0 <memmove+0x28>
     aa6:	1602                	slli	a2,a2,0x20
     aa8:	9201                	srli	a2,a2,0x20
     aaa:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     aae:	872a                	mv	a4,a0
      *dst++ = *src++;
     ab0:	0585                	addi	a1,a1,1
     ab2:	0705                	addi	a4,a4,1
     ab4:	fff5c683          	lbu	a3,-1(a1)
     ab8:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     abc:	fef71ae3          	bne	a4,a5,ab0 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     ac0:	6422                	ld	s0,8(sp)
     ac2:	0141                	addi	sp,sp,16
     ac4:	8082                	ret
    dst += n;
     ac6:	00c50733          	add	a4,a0,a2
    src += n;
     aca:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     acc:	fec05ae3          	blez	a2,ac0 <memmove+0x28>
     ad0:	fff6079b          	addiw	a5,a2,-1
     ad4:	1782                	slli	a5,a5,0x20
     ad6:	9381                	srli	a5,a5,0x20
     ad8:	fff7c793          	not	a5,a5
     adc:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     ade:	15fd                	addi	a1,a1,-1
     ae0:	177d                	addi	a4,a4,-1
     ae2:	0005c683          	lbu	a3,0(a1)
     ae6:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     aea:	fee79ae3          	bne	a5,a4,ade <memmove+0x46>
     aee:	bfc9                	j	ac0 <memmove+0x28>

0000000000000af0 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     af0:	1141                	addi	sp,sp,-16
     af2:	e422                	sd	s0,8(sp)
     af4:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     af6:	ca05                	beqz	a2,b26 <memcmp+0x36>
     af8:	fff6069b          	addiw	a3,a2,-1
     afc:	1682                	slli	a3,a3,0x20
     afe:	9281                	srli	a3,a3,0x20
     b00:	0685                	addi	a3,a3,1
     b02:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     b04:	00054783          	lbu	a5,0(a0)
     b08:	0005c703          	lbu	a4,0(a1)
     b0c:	00e79863          	bne	a5,a4,b1c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     b10:	0505                	addi	a0,a0,1
    p2++;
     b12:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     b14:	fed518e3          	bne	a0,a3,b04 <memcmp+0x14>
  }
  return 0;
     b18:	4501                	li	a0,0
     b1a:	a019                	j	b20 <memcmp+0x30>
      return *p1 - *p2;
     b1c:	40e7853b          	subw	a0,a5,a4
}
     b20:	6422                	ld	s0,8(sp)
     b22:	0141                	addi	sp,sp,16
     b24:	8082                	ret
  return 0;
     b26:	4501                	li	a0,0
     b28:	bfe5                	j	b20 <memcmp+0x30>

0000000000000b2a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     b2a:	1141                	addi	sp,sp,-16
     b2c:	e406                	sd	ra,8(sp)
     b2e:	e022                	sd	s0,0(sp)
     b30:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     b32:	f67ff0ef          	jal	a98 <memmove>
}
     b36:	60a2                	ld	ra,8(sp)
     b38:	6402                	ld	s0,0(sp)
     b3a:	0141                	addi	sp,sp,16
     b3c:	8082                	ret

0000000000000b3e <sbrk>:

char *
sbrk(int n) {
     b3e:	1141                	addi	sp,sp,-16
     b40:	e406                	sd	ra,8(sp)
     b42:	e022                	sd	s0,0(sp)
     b44:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
     b46:	4585                	li	a1,1
     b48:	0ba000ef          	jal	c02 <sys_sbrk>
}
     b4c:	60a2                	ld	ra,8(sp)
     b4e:	6402                	ld	s0,0(sp)
     b50:	0141                	addi	sp,sp,16
     b52:	8082                	ret

0000000000000b54 <sbrklazy>:

char *
sbrklazy(int n) {
     b54:	1141                	addi	sp,sp,-16
     b56:	e406                	sd	ra,8(sp)
     b58:	e022                	sd	s0,0(sp)
     b5a:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
     b5c:	4589                	li	a1,2
     b5e:	0a4000ef          	jal	c02 <sys_sbrk>
}
     b62:	60a2                	ld	ra,8(sp)
     b64:	6402                	ld	s0,0(sp)
     b66:	0141                	addi	sp,sp,16
     b68:	8082                	ret

0000000000000b6a <getfilenum>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global getfilenum
getfilenum:
 li a7, SYS_getfilenum
     b6a:	48dd                	li	a7,23
 ecall
     b6c:	00000073          	ecall
 ret
     b70:	8082                	ret

0000000000000b72 <fork>:
.global fork
fork:
 li a7, SYS_fork
     b72:	4885                	li	a7,1
 ecall
     b74:	00000073          	ecall
 ret
     b78:	8082                	ret

0000000000000b7a <exit>:
.global exit
exit:
 li a7, SYS_exit
     b7a:	4889                	li	a7,2
 ecall
     b7c:	00000073          	ecall
 ret
     b80:	8082                	ret

0000000000000b82 <wait>:
.global wait
wait:
 li a7, SYS_wait
     b82:	488d                	li	a7,3
 ecall
     b84:	00000073          	ecall
 ret
     b88:	8082                	ret

0000000000000b8a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     b8a:	4891                	li	a7,4
 ecall
     b8c:	00000073          	ecall
 ret
     b90:	8082                	ret

0000000000000b92 <read>:
.global read
read:
 li a7, SYS_read
     b92:	4895                	li	a7,5
 ecall
     b94:	00000073          	ecall
 ret
     b98:	8082                	ret

0000000000000b9a <write>:
.global write
write:
 li a7, SYS_write
     b9a:	48c1                	li	a7,16
 ecall
     b9c:	00000073          	ecall
 ret
     ba0:	8082                	ret

0000000000000ba2 <close>:
.global close
close:
 li a7, SYS_close
     ba2:	48d5                	li	a7,21
 ecall
     ba4:	00000073          	ecall
 ret
     ba8:	8082                	ret

0000000000000baa <kill>:
.global kill
kill:
 li a7, SYS_kill
     baa:	4899                	li	a7,6
 ecall
     bac:	00000073          	ecall
 ret
     bb0:	8082                	ret

0000000000000bb2 <exec>:
.global exec
exec:
 li a7, SYS_exec
     bb2:	489d                	li	a7,7
 ecall
     bb4:	00000073          	ecall
 ret
     bb8:	8082                	ret

0000000000000bba <open>:
.global open
open:
 li a7, SYS_open
     bba:	48bd                	li	a7,15
 ecall
     bbc:	00000073          	ecall
 ret
     bc0:	8082                	ret

0000000000000bc2 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     bc2:	48c5                	li	a7,17
 ecall
     bc4:	00000073          	ecall
 ret
     bc8:	8082                	ret

0000000000000bca <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     bca:	48c9                	li	a7,18
 ecall
     bcc:	00000073          	ecall
 ret
     bd0:	8082                	ret

0000000000000bd2 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     bd2:	48a1                	li	a7,8
 ecall
     bd4:	00000073          	ecall
 ret
     bd8:	8082                	ret

0000000000000bda <link>:
.global link
link:
 li a7, SYS_link
     bda:	48cd                	li	a7,19
 ecall
     bdc:	00000073          	ecall
 ret
     be0:	8082                	ret

0000000000000be2 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     be2:	48d1                	li	a7,20
 ecall
     be4:	00000073          	ecall
 ret
     be8:	8082                	ret

0000000000000bea <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     bea:	48a5                	li	a7,9
 ecall
     bec:	00000073          	ecall
 ret
     bf0:	8082                	ret

0000000000000bf2 <dup>:
.global dup
dup:
 li a7, SYS_dup
     bf2:	48a9                	li	a7,10
 ecall
     bf4:	00000073          	ecall
 ret
     bf8:	8082                	ret

0000000000000bfa <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     bfa:	48ad                	li	a7,11
 ecall
     bfc:	00000073          	ecall
 ret
     c00:	8082                	ret

0000000000000c02 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
     c02:	48b1                	li	a7,12
 ecall
     c04:	00000073          	ecall
 ret
     c08:	8082                	ret

0000000000000c0a <pause>:
.global pause
pause:
 li a7, SYS_pause
     c0a:	48b5                	li	a7,13
 ecall
     c0c:	00000073          	ecall
 ret
     c10:	8082                	ret

0000000000000c12 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     c12:	48b9                	li	a7,14
 ecall
     c14:	00000073          	ecall
 ret
     c18:	8082                	ret

0000000000000c1a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     c1a:	1101                	addi	sp,sp,-32
     c1c:	ec06                	sd	ra,24(sp)
     c1e:	e822                	sd	s0,16(sp)
     c20:	1000                	addi	s0,sp,32
     c22:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     c26:	4605                	li	a2,1
     c28:	fef40593          	addi	a1,s0,-17
     c2c:	f6fff0ef          	jal	b9a <write>
}
     c30:	60e2                	ld	ra,24(sp)
     c32:	6442                	ld	s0,16(sp)
     c34:	6105                	addi	sp,sp,32
     c36:	8082                	ret

0000000000000c38 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
     c38:	715d                	addi	sp,sp,-80
     c3a:	e486                	sd	ra,72(sp)
     c3c:	e0a2                	sd	s0,64(sp)
     c3e:	f84a                	sd	s2,48(sp)
     c40:	0880                	addi	s0,sp,80
     c42:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
     c44:	c299                	beqz	a3,c4a <printint+0x12>
     c46:	0805c363          	bltz	a1,ccc <printint+0x94>
  neg = 0;
     c4a:	4881                	li	a7,0
     c4c:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
     c50:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
     c52:	00001517          	auipc	a0,0x1
     c56:	86e50513          	addi	a0,a0,-1938 # 14c0 <digits>
     c5a:	883e                	mv	a6,a5
     c5c:	2785                	addiw	a5,a5,1
     c5e:	02c5f733          	remu	a4,a1,a2
     c62:	972a                	add	a4,a4,a0
     c64:	00074703          	lbu	a4,0(a4)
     c68:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
     c6c:	872e                	mv	a4,a1
     c6e:	02c5d5b3          	divu	a1,a1,a2
     c72:	0685                	addi	a3,a3,1
     c74:	fec773e3          	bgeu	a4,a2,c5a <printint+0x22>
  if(neg)
     c78:	00088b63          	beqz	a7,c8e <printint+0x56>
    buf[i++] = '-';
     c7c:	fd078793          	addi	a5,a5,-48
     c80:	97a2                	add	a5,a5,s0
     c82:	02d00713          	li	a4,45
     c86:	fee78423          	sb	a4,-24(a5)
     c8a:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
     c8e:	02f05a63          	blez	a5,cc2 <printint+0x8a>
     c92:	fc26                	sd	s1,56(sp)
     c94:	f44e                	sd	s3,40(sp)
     c96:	fb840713          	addi	a4,s0,-72
     c9a:	00f704b3          	add	s1,a4,a5
     c9e:	fff70993          	addi	s3,a4,-1
     ca2:	99be                	add	s3,s3,a5
     ca4:	37fd                	addiw	a5,a5,-1
     ca6:	1782                	slli	a5,a5,0x20
     ca8:	9381                	srli	a5,a5,0x20
     caa:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
     cae:	fff4c583          	lbu	a1,-1(s1)
     cb2:	854a                	mv	a0,s2
     cb4:	f67ff0ef          	jal	c1a <putc>
  while(--i >= 0)
     cb8:	14fd                	addi	s1,s1,-1
     cba:	ff349ae3          	bne	s1,s3,cae <printint+0x76>
     cbe:	74e2                	ld	s1,56(sp)
     cc0:	79a2                	ld	s3,40(sp)
}
     cc2:	60a6                	ld	ra,72(sp)
     cc4:	6406                	ld	s0,64(sp)
     cc6:	7942                	ld	s2,48(sp)
     cc8:	6161                	addi	sp,sp,80
     cca:	8082                	ret
    x = -xx;
     ccc:	40b005b3          	neg	a1,a1
    neg = 1;
     cd0:	4885                	li	a7,1
    x = -xx;
     cd2:	bfad                	j	c4c <printint+0x14>

0000000000000cd4 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
     cd4:	711d                	addi	sp,sp,-96
     cd6:	ec86                	sd	ra,88(sp)
     cd8:	e8a2                	sd	s0,80(sp)
     cda:	e0ca                	sd	s2,64(sp)
     cdc:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
     cde:	0005c903          	lbu	s2,0(a1)
     ce2:	28090663          	beqz	s2,f6e <vprintf+0x29a>
     ce6:	e4a6                	sd	s1,72(sp)
     ce8:	fc4e                	sd	s3,56(sp)
     cea:	f852                	sd	s4,48(sp)
     cec:	f456                	sd	s5,40(sp)
     cee:	f05a                	sd	s6,32(sp)
     cf0:	ec5e                	sd	s7,24(sp)
     cf2:	e862                	sd	s8,16(sp)
     cf4:	e466                	sd	s9,8(sp)
     cf6:	8b2a                	mv	s6,a0
     cf8:	8a2e                	mv	s4,a1
     cfa:	8bb2                	mv	s7,a2
  state = 0;
     cfc:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
     cfe:	4481                	li	s1,0
     d00:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
     d02:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
     d06:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
     d0a:	06c00c93          	li	s9,108
     d0e:	a005                	j	d2e <vprintf+0x5a>
        putc(fd, c0);
     d10:	85ca                	mv	a1,s2
     d12:	855a                	mv	a0,s6
     d14:	f07ff0ef          	jal	c1a <putc>
     d18:	a019                	j	d1e <vprintf+0x4a>
    } else if(state == '%'){
     d1a:	03598263          	beq	s3,s5,d3e <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
     d1e:	2485                	addiw	s1,s1,1
     d20:	8726                	mv	a4,s1
     d22:	009a07b3          	add	a5,s4,s1
     d26:	0007c903          	lbu	s2,0(a5)
     d2a:	22090a63          	beqz	s2,f5e <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
     d2e:	0009079b          	sext.w	a5,s2
    if(state == 0){
     d32:	fe0994e3          	bnez	s3,d1a <vprintf+0x46>
      if(c0 == '%'){
     d36:	fd579de3          	bne	a5,s5,d10 <vprintf+0x3c>
        state = '%';
     d3a:	89be                	mv	s3,a5
     d3c:	b7cd                	j	d1e <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
     d3e:	00ea06b3          	add	a3,s4,a4
     d42:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
     d46:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
     d48:	c681                	beqz	a3,d50 <vprintf+0x7c>
     d4a:	9752                	add	a4,a4,s4
     d4c:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
     d50:	05878363          	beq	a5,s8,d96 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
     d54:	05978d63          	beq	a5,s9,dae <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
     d58:	07500713          	li	a4,117
     d5c:	0ee78763          	beq	a5,a4,e4a <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
     d60:	07800713          	li	a4,120
     d64:	12e78963          	beq	a5,a4,e96 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
     d68:	07000713          	li	a4,112
     d6c:	14e78e63          	beq	a5,a4,ec8 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
     d70:	06300713          	li	a4,99
     d74:	18e78e63          	beq	a5,a4,f10 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
     d78:	07300713          	li	a4,115
     d7c:	1ae78463          	beq	a5,a4,f24 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
     d80:	02500713          	li	a4,37
     d84:	04e79563          	bne	a5,a4,dce <vprintf+0xfa>
        putc(fd, '%');
     d88:	02500593          	li	a1,37
     d8c:	855a                	mv	a0,s6
     d8e:	e8dff0ef          	jal	c1a <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
     d92:	4981                	li	s3,0
     d94:	b769                	j	d1e <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
     d96:	008b8913          	addi	s2,s7,8
     d9a:	4685                	li	a3,1
     d9c:	4629                	li	a2,10
     d9e:	000ba583          	lw	a1,0(s7)
     da2:	855a                	mv	a0,s6
     da4:	e95ff0ef          	jal	c38 <printint>
     da8:	8bca                	mv	s7,s2
      state = 0;
     daa:	4981                	li	s3,0
     dac:	bf8d                	j	d1e <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
     dae:	06400793          	li	a5,100
     db2:	02f68963          	beq	a3,a5,de4 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
     db6:	06c00793          	li	a5,108
     dba:	04f68263          	beq	a3,a5,dfe <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
     dbe:	07500793          	li	a5,117
     dc2:	0af68063          	beq	a3,a5,e62 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
     dc6:	07800793          	li	a5,120
     dca:	0ef68263          	beq	a3,a5,eae <vprintf+0x1da>
        putc(fd, '%');
     dce:	02500593          	li	a1,37
     dd2:	855a                	mv	a0,s6
     dd4:	e47ff0ef          	jal	c1a <putc>
        putc(fd, c0);
     dd8:	85ca                	mv	a1,s2
     dda:	855a                	mv	a0,s6
     ddc:	e3fff0ef          	jal	c1a <putc>
      state = 0;
     de0:	4981                	li	s3,0
     de2:	bf35                	j	d1e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
     de4:	008b8913          	addi	s2,s7,8
     de8:	4685                	li	a3,1
     dea:	4629                	li	a2,10
     dec:	000bb583          	ld	a1,0(s7)
     df0:	855a                	mv	a0,s6
     df2:	e47ff0ef          	jal	c38 <printint>
        i += 1;
     df6:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
     df8:	8bca                	mv	s7,s2
      state = 0;
     dfa:	4981                	li	s3,0
        i += 1;
     dfc:	b70d                	j	d1e <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
     dfe:	06400793          	li	a5,100
     e02:	02f60763          	beq	a2,a5,e30 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
     e06:	07500793          	li	a5,117
     e0a:	06f60963          	beq	a2,a5,e7c <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
     e0e:	07800793          	li	a5,120
     e12:	faf61ee3          	bne	a2,a5,dce <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
     e16:	008b8913          	addi	s2,s7,8
     e1a:	4681                	li	a3,0
     e1c:	4641                	li	a2,16
     e1e:	000bb583          	ld	a1,0(s7)
     e22:	855a                	mv	a0,s6
     e24:	e15ff0ef          	jal	c38 <printint>
        i += 2;
     e28:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
     e2a:	8bca                	mv	s7,s2
      state = 0;
     e2c:	4981                	li	s3,0
        i += 2;
     e2e:	bdc5                	j	d1e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
     e30:	008b8913          	addi	s2,s7,8
     e34:	4685                	li	a3,1
     e36:	4629                	li	a2,10
     e38:	000bb583          	ld	a1,0(s7)
     e3c:	855a                	mv	a0,s6
     e3e:	dfbff0ef          	jal	c38 <printint>
        i += 2;
     e42:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
     e44:	8bca                	mv	s7,s2
      state = 0;
     e46:	4981                	li	s3,0
        i += 2;
     e48:	bdd9                	j	d1e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
     e4a:	008b8913          	addi	s2,s7,8
     e4e:	4681                	li	a3,0
     e50:	4629                	li	a2,10
     e52:	000be583          	lwu	a1,0(s7)
     e56:	855a                	mv	a0,s6
     e58:	de1ff0ef          	jal	c38 <printint>
     e5c:	8bca                	mv	s7,s2
      state = 0;
     e5e:	4981                	li	s3,0
     e60:	bd7d                	j	d1e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
     e62:	008b8913          	addi	s2,s7,8
     e66:	4681                	li	a3,0
     e68:	4629                	li	a2,10
     e6a:	000bb583          	ld	a1,0(s7)
     e6e:	855a                	mv	a0,s6
     e70:	dc9ff0ef          	jal	c38 <printint>
        i += 1;
     e74:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
     e76:	8bca                	mv	s7,s2
      state = 0;
     e78:	4981                	li	s3,0
        i += 1;
     e7a:	b555                	j	d1e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
     e7c:	008b8913          	addi	s2,s7,8
     e80:	4681                	li	a3,0
     e82:	4629                	li	a2,10
     e84:	000bb583          	ld	a1,0(s7)
     e88:	855a                	mv	a0,s6
     e8a:	dafff0ef          	jal	c38 <printint>
        i += 2;
     e8e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
     e90:	8bca                	mv	s7,s2
      state = 0;
     e92:	4981                	li	s3,0
        i += 2;
     e94:	b569                	j	d1e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
     e96:	008b8913          	addi	s2,s7,8
     e9a:	4681                	li	a3,0
     e9c:	4641                	li	a2,16
     e9e:	000be583          	lwu	a1,0(s7)
     ea2:	855a                	mv	a0,s6
     ea4:	d95ff0ef          	jal	c38 <printint>
     ea8:	8bca                	mv	s7,s2
      state = 0;
     eaa:	4981                	li	s3,0
     eac:	bd8d                	j	d1e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
     eae:	008b8913          	addi	s2,s7,8
     eb2:	4681                	li	a3,0
     eb4:	4641                	li	a2,16
     eb6:	000bb583          	ld	a1,0(s7)
     eba:	855a                	mv	a0,s6
     ebc:	d7dff0ef          	jal	c38 <printint>
        i += 1;
     ec0:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
     ec2:	8bca                	mv	s7,s2
      state = 0;
     ec4:	4981                	li	s3,0
        i += 1;
     ec6:	bda1                	j	d1e <vprintf+0x4a>
     ec8:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
     eca:	008b8d13          	addi	s10,s7,8
     ece:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
     ed2:	03000593          	li	a1,48
     ed6:	855a                	mv	a0,s6
     ed8:	d43ff0ef          	jal	c1a <putc>
  putc(fd, 'x');
     edc:	07800593          	li	a1,120
     ee0:	855a                	mv	a0,s6
     ee2:	d39ff0ef          	jal	c1a <putc>
     ee6:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
     ee8:	00000b97          	auipc	s7,0x0
     eec:	5d8b8b93          	addi	s7,s7,1496 # 14c0 <digits>
     ef0:	03c9d793          	srli	a5,s3,0x3c
     ef4:	97de                	add	a5,a5,s7
     ef6:	0007c583          	lbu	a1,0(a5)
     efa:	855a                	mv	a0,s6
     efc:	d1fff0ef          	jal	c1a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
     f00:	0992                	slli	s3,s3,0x4
     f02:	397d                	addiw	s2,s2,-1
     f04:	fe0916e3          	bnez	s2,ef0 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
     f08:	8bea                	mv	s7,s10
      state = 0;
     f0a:	4981                	li	s3,0
     f0c:	6d02                	ld	s10,0(sp)
     f0e:	bd01                	j	d1e <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
     f10:	008b8913          	addi	s2,s7,8
     f14:	000bc583          	lbu	a1,0(s7)
     f18:	855a                	mv	a0,s6
     f1a:	d01ff0ef          	jal	c1a <putc>
     f1e:	8bca                	mv	s7,s2
      state = 0;
     f20:	4981                	li	s3,0
     f22:	bbf5                	j	d1e <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
     f24:	008b8993          	addi	s3,s7,8
     f28:	000bb903          	ld	s2,0(s7)
     f2c:	00090f63          	beqz	s2,f4a <vprintf+0x276>
        for(; *s; s++)
     f30:	00094583          	lbu	a1,0(s2)
     f34:	c195                	beqz	a1,f58 <vprintf+0x284>
          putc(fd, *s);
     f36:	855a                	mv	a0,s6
     f38:	ce3ff0ef          	jal	c1a <putc>
        for(; *s; s++)
     f3c:	0905                	addi	s2,s2,1
     f3e:	00094583          	lbu	a1,0(s2)
     f42:	f9f5                	bnez	a1,f36 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
     f44:	8bce                	mv	s7,s3
      state = 0;
     f46:	4981                	li	s3,0
     f48:	bbd9                	j	d1e <vprintf+0x4a>
          s = "(null)";
     f4a:	00000917          	auipc	s2,0x0
     f4e:	50e90913          	addi	s2,s2,1294 # 1458 <malloc+0x402>
        for(; *s; s++)
     f52:	02800593          	li	a1,40
     f56:	b7c5                	j	f36 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
     f58:	8bce                	mv	s7,s3
      state = 0;
     f5a:	4981                	li	s3,0
     f5c:	b3c9                	j	d1e <vprintf+0x4a>
     f5e:	64a6                	ld	s1,72(sp)
     f60:	79e2                	ld	s3,56(sp)
     f62:	7a42                	ld	s4,48(sp)
     f64:	7aa2                	ld	s5,40(sp)
     f66:	7b02                	ld	s6,32(sp)
     f68:	6be2                	ld	s7,24(sp)
     f6a:	6c42                	ld	s8,16(sp)
     f6c:	6ca2                	ld	s9,8(sp)
    }
  }
}
     f6e:	60e6                	ld	ra,88(sp)
     f70:	6446                	ld	s0,80(sp)
     f72:	6906                	ld	s2,64(sp)
     f74:	6125                	addi	sp,sp,96
     f76:	8082                	ret

0000000000000f78 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
     f78:	715d                	addi	sp,sp,-80
     f7a:	ec06                	sd	ra,24(sp)
     f7c:	e822                	sd	s0,16(sp)
     f7e:	1000                	addi	s0,sp,32
     f80:	e010                	sd	a2,0(s0)
     f82:	e414                	sd	a3,8(s0)
     f84:	e818                	sd	a4,16(s0)
     f86:	ec1c                	sd	a5,24(s0)
     f88:	03043023          	sd	a6,32(s0)
     f8c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
     f90:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
     f94:	8622                	mv	a2,s0
     f96:	d3fff0ef          	jal	cd4 <vprintf>
}
     f9a:	60e2                	ld	ra,24(sp)
     f9c:	6442                	ld	s0,16(sp)
     f9e:	6161                	addi	sp,sp,80
     fa0:	8082                	ret

0000000000000fa2 <printf>:

void
printf(const char *fmt, ...)
{
     fa2:	711d                	addi	sp,sp,-96
     fa4:	ec06                	sd	ra,24(sp)
     fa6:	e822                	sd	s0,16(sp)
     fa8:	1000                	addi	s0,sp,32
     faa:	e40c                	sd	a1,8(s0)
     fac:	e810                	sd	a2,16(s0)
     fae:	ec14                	sd	a3,24(s0)
     fb0:	f018                	sd	a4,32(s0)
     fb2:	f41c                	sd	a5,40(s0)
     fb4:	03043823          	sd	a6,48(s0)
     fb8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
     fbc:	00840613          	addi	a2,s0,8
     fc0:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
     fc4:	85aa                	mv	a1,a0
     fc6:	4505                	li	a0,1
     fc8:	d0dff0ef          	jal	cd4 <vprintf>
}
     fcc:	60e2                	ld	ra,24(sp)
     fce:	6442                	ld	s0,16(sp)
     fd0:	6125                	addi	sp,sp,96
     fd2:	8082                	ret

0000000000000fd4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
     fd4:	1141                	addi	sp,sp,-16
     fd6:	e422                	sd	s0,8(sp)
     fd8:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
     fda:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
     fde:	00001797          	auipc	a5,0x1
     fe2:	0327b783          	ld	a5,50(a5) # 2010 <freep>
     fe6:	a02d                	j	1010 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
     fe8:	4618                	lw	a4,8(a2)
     fea:	9f2d                	addw	a4,a4,a1
     fec:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
     ff0:	6398                	ld	a4,0(a5)
     ff2:	6310                	ld	a2,0(a4)
     ff4:	a83d                	j	1032 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
     ff6:	ff852703          	lw	a4,-8(a0)
     ffa:	9f31                	addw	a4,a4,a2
     ffc:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
     ffe:	ff053683          	ld	a3,-16(a0)
    1002:	a091                	j	1046 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1004:	6398                	ld	a4,0(a5)
    1006:	00e7e463          	bltu	a5,a4,100e <free+0x3a>
    100a:	00e6ea63          	bltu	a3,a4,101e <free+0x4a>
{
    100e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1010:	fed7fae3          	bgeu	a5,a3,1004 <free+0x30>
    1014:	6398                	ld	a4,0(a5)
    1016:	00e6e463          	bltu	a3,a4,101e <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    101a:	fee7eae3          	bltu	a5,a4,100e <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
    101e:	ff852583          	lw	a1,-8(a0)
    1022:	6390                	ld	a2,0(a5)
    1024:	02059813          	slli	a6,a1,0x20
    1028:	01c85713          	srli	a4,a6,0x1c
    102c:	9736                	add	a4,a4,a3
    102e:	fae60de3          	beq	a2,a4,fe8 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
    1032:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    1036:	4790                	lw	a2,8(a5)
    1038:	02061593          	slli	a1,a2,0x20
    103c:	01c5d713          	srli	a4,a1,0x1c
    1040:	973e                	add	a4,a4,a5
    1042:	fae68ae3          	beq	a3,a4,ff6 <free+0x22>
    p->s.ptr = bp->s.ptr;
    1046:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
    1048:	00001717          	auipc	a4,0x1
    104c:	fcf73423          	sd	a5,-56(a4) # 2010 <freep>
}
    1050:	6422                	ld	s0,8(sp)
    1052:	0141                	addi	sp,sp,16
    1054:	8082                	ret

0000000000001056 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    1056:	7139                	addi	sp,sp,-64
    1058:	fc06                	sd	ra,56(sp)
    105a:	f822                	sd	s0,48(sp)
    105c:	f426                	sd	s1,40(sp)
    105e:	ec4e                	sd	s3,24(sp)
    1060:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1062:	02051493          	slli	s1,a0,0x20
    1066:	9081                	srli	s1,s1,0x20
    1068:	04bd                	addi	s1,s1,15
    106a:	8091                	srli	s1,s1,0x4
    106c:	0014899b          	addiw	s3,s1,1
    1070:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    1072:	00001517          	auipc	a0,0x1
    1076:	f9e53503          	ld	a0,-98(a0) # 2010 <freep>
    107a:	c915                	beqz	a0,10ae <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    107c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    107e:	4798                	lw	a4,8(a5)
    1080:	08977a63          	bgeu	a4,s1,1114 <malloc+0xbe>
    1084:	f04a                	sd	s2,32(sp)
    1086:	e852                	sd	s4,16(sp)
    1088:	e456                	sd	s5,8(sp)
    108a:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
    108c:	8a4e                	mv	s4,s3
    108e:	0009871b          	sext.w	a4,s3
    1092:	6685                	lui	a3,0x1
    1094:	00d77363          	bgeu	a4,a3,109a <malloc+0x44>
    1098:	6a05                	lui	s4,0x1
    109a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    109e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    10a2:	00001917          	auipc	s2,0x1
    10a6:	f6e90913          	addi	s2,s2,-146 # 2010 <freep>
  if(p == SBRK_ERROR)
    10aa:	5afd                	li	s5,-1
    10ac:	a081                	j	10ec <malloc+0x96>
    10ae:	f04a                	sd	s2,32(sp)
    10b0:	e852                	sd	s4,16(sp)
    10b2:	e456                	sd	s5,8(sp)
    10b4:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
    10b6:	00001797          	auipc	a5,0x1
    10ba:	35278793          	addi	a5,a5,850 # 2408 <base>
    10be:	00001717          	auipc	a4,0x1
    10c2:	f4f73923          	sd	a5,-174(a4) # 2010 <freep>
    10c6:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    10c8:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    10cc:	b7c1                	j	108c <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
    10ce:	6398                	ld	a4,0(a5)
    10d0:	e118                	sd	a4,0(a0)
    10d2:	a8a9                	j	112c <malloc+0xd6>
  hp->s.size = nu;
    10d4:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    10d8:	0541                	addi	a0,a0,16
    10da:	efbff0ef          	jal	fd4 <free>
  return freep;
    10de:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    10e2:	c12d                	beqz	a0,1144 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    10e4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    10e6:	4798                	lw	a4,8(a5)
    10e8:	02977263          	bgeu	a4,s1,110c <malloc+0xb6>
    if(p == freep)
    10ec:	00093703          	ld	a4,0(s2)
    10f0:	853e                	mv	a0,a5
    10f2:	fef719e3          	bne	a4,a5,10e4 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
    10f6:	8552                	mv	a0,s4
    10f8:	a47ff0ef          	jal	b3e <sbrk>
  if(p == SBRK_ERROR)
    10fc:	fd551ce3          	bne	a0,s5,10d4 <malloc+0x7e>
        return 0;
    1100:	4501                	li	a0,0
    1102:	7902                	ld	s2,32(sp)
    1104:	6a42                	ld	s4,16(sp)
    1106:	6aa2                	ld	s5,8(sp)
    1108:	6b02                	ld	s6,0(sp)
    110a:	a03d                	j	1138 <malloc+0xe2>
    110c:	7902                	ld	s2,32(sp)
    110e:	6a42                	ld	s4,16(sp)
    1110:	6aa2                	ld	s5,8(sp)
    1112:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
    1114:	fae48de3          	beq	s1,a4,10ce <malloc+0x78>
        p->s.size -= nunits;
    1118:	4137073b          	subw	a4,a4,s3
    111c:	c798                	sw	a4,8(a5)
        p += p->s.size;
    111e:	02071693          	slli	a3,a4,0x20
    1122:	01c6d713          	srli	a4,a3,0x1c
    1126:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    1128:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    112c:	00001717          	auipc	a4,0x1
    1130:	eea73223          	sd	a0,-284(a4) # 2010 <freep>
      return (void*)(p + 1);
    1134:	01078513          	addi	a0,a5,16
  }
}
    1138:	70e2                	ld	ra,56(sp)
    113a:	7442                	ld	s0,48(sp)
    113c:	74a2                	ld	s1,40(sp)
    113e:	69e2                	ld	s3,24(sp)
    1140:	6121                	addi	sp,sp,64
    1142:	8082                	ret
    1144:	7902                	ld	s2,32(sp)
    1146:	6a42                	ld	s4,16(sp)
    1148:	6aa2                	ld	s5,8(sp)
    114a:	6b02                	ld	s6,0(sp)
    114c:	b7f5                	j	1138 <malloc+0xe2>
