
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	19813103          	ld	sp,408(sp) # 8000a198 <_GLOBAL_OFFSET_TABLE_+0x8>
        li a0, 1024*4
    80000008:	6505                	lui	a0,0x1
        csrr a1, mhartid
    8000000a:	f14025f3          	csrr	a1,mhartid
        addi a1, a1, 1
    8000000e:	0585                	addi	a1,a1,1
        mul a0, a0, a1
    80000010:	02b50533          	mul	a0,a0,a1
        add sp, sp, a0
    80000014:	912a                	add	sp,sp,a0
        # jump to start() in start.c
        call start
    80000016:	04a000ef          	jal	80000060 <start>

000000008000001a <spin>:
spin:
        j spin
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000022:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000026:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002a:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    8000002e:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000032:	577d                	li	a4,-1
    80000034:	177e                	slli	a4,a4,0x3f
    80000036:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80000038:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003c:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000040:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000044:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    80000048:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004c:	000f4737          	lui	a4,0xf4
    80000050:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000054:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000056:	14d79073          	csrw	stimecmp,a5
}
    8000005a:	6422                	ld	s0,8(sp)
    8000005c:	0141                	addi	sp,sp,16
    8000005e:	8082                	ret

0000000080000060 <start>:
{
    80000060:	1141                	addi	sp,sp,-16
    80000062:	e406                	sd	ra,8(sp)
    80000064:	e022                	sd	s0,0(sp)
    80000066:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000006c:	7779                	lui	a4,0xffffe
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdb317>
    80000072:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000074:	6705                	lui	a4,0x1
    80000076:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    8000007c:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000080:	00001797          	auipc	a5,0x1
    80000084:	dbc78793          	addi	a5,a5,-580 # 80000e3c <main>
    80000088:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    8000008c:	4781                	li	a5,0
    8000008e:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000092:	67c1                	lui	a5,0x10
    80000094:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80000096:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009a:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    8000009e:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    800000a2:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r" (x));
    800000a6:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000aa:	57fd                	li	a5,-1
    800000ac:	83a9                	srli	a5,a5,0xa
    800000ae:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b2:	47bd                	li	a5,15
    800000b4:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000b8:	f65ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000bc:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c4:	30200073          	mret
}
    800000c8:	60a2                	ld	ra,8(sp)
    800000ca:	6402                	ld	s0,0(sp)
    800000cc:	0141                	addi	sp,sp,16
    800000ce:	8082                	ret

00000000800000d0 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d0:	7119                	addi	sp,sp,-128
    800000d2:	fc86                	sd	ra,120(sp)
    800000d4:	f8a2                	sd	s0,112(sp)
    800000d6:	f4a6                	sd	s1,104(sp)
    800000d8:	0100                	addi	s0,sp,128
  char buf[32];
  int i = 0;

  while(i < n){
    800000da:	06c05a63          	blez	a2,8000014e <consolewrite+0x7e>
    800000de:	f0ca                	sd	s2,96(sp)
    800000e0:	ecce                	sd	s3,88(sp)
    800000e2:	e8d2                	sd	s4,80(sp)
    800000e4:	e4d6                	sd	s5,72(sp)
    800000e6:	e0da                	sd	s6,64(sp)
    800000e8:	fc5e                	sd	s7,56(sp)
    800000ea:	f862                	sd	s8,48(sp)
    800000ec:	f466                	sd	s9,40(sp)
    800000ee:	8aaa                	mv	s5,a0
    800000f0:	8b2e                	mv	s6,a1
    800000f2:	8a32                	mv	s4,a2
  int i = 0;
    800000f4:	4481                	li	s1,0
    int nn = sizeof(buf);
    if(nn > n - i)
    800000f6:	02000c13          	li	s8,32
    800000fa:	02000c93          	li	s9,32
      nn = n - i;
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    800000fe:	5bfd                	li	s7,-1
    80000100:	a035                	j	8000012c <consolewrite+0x5c>
    if(nn > n - i)
    80000102:	0009099b          	sext.w	s3,s2
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    80000106:	86ce                	mv	a3,s3
    80000108:	01648633          	add	a2,s1,s6
    8000010c:	85d6                	mv	a1,s5
    8000010e:	f8040513          	addi	a0,s0,-128
    80000112:	15a020ef          	jal	8000226c <either_copyin>
    80000116:	03750e63          	beq	a0,s7,80000152 <consolewrite+0x82>
      break;
    uartwrite(buf, nn);
    8000011a:	85ce                	mv	a1,s3
    8000011c:	f8040513          	addi	a0,s0,-128
    80000120:	778000ef          	jal	80000898 <uartwrite>
    i += nn;
    80000124:	009904bb          	addw	s1,s2,s1
  while(i < n){
    80000128:	0144da63          	bge	s1,s4,8000013c <consolewrite+0x6c>
    if(nn > n - i)
    8000012c:	409a093b          	subw	s2,s4,s1
    80000130:	0009079b          	sext.w	a5,s2
    80000134:	fcfc57e3          	bge	s8,a5,80000102 <consolewrite+0x32>
    80000138:	8966                	mv	s2,s9
    8000013a:	b7e1                	j	80000102 <consolewrite+0x32>
    8000013c:	7906                	ld	s2,96(sp)
    8000013e:	69e6                	ld	s3,88(sp)
    80000140:	6a46                	ld	s4,80(sp)
    80000142:	6aa6                	ld	s5,72(sp)
    80000144:	6b06                	ld	s6,64(sp)
    80000146:	7be2                	ld	s7,56(sp)
    80000148:	7c42                	ld	s8,48(sp)
    8000014a:	7ca2                	ld	s9,40(sp)
    8000014c:	a819                	j	80000162 <consolewrite+0x92>
  int i = 0;
    8000014e:	4481                	li	s1,0
    80000150:	a809                	j	80000162 <consolewrite+0x92>
    80000152:	7906                	ld	s2,96(sp)
    80000154:	69e6                	ld	s3,88(sp)
    80000156:	6a46                	ld	s4,80(sp)
    80000158:	6aa6                	ld	s5,72(sp)
    8000015a:	6b06                	ld	s6,64(sp)
    8000015c:	7be2                	ld	s7,56(sp)
    8000015e:	7c42                	ld	s8,48(sp)
    80000160:	7ca2                	ld	s9,40(sp)
  }

  return i;
}
    80000162:	8526                	mv	a0,s1
    80000164:	70e6                	ld	ra,120(sp)
    80000166:	7446                	ld	s0,112(sp)
    80000168:	74a6                	ld	s1,104(sp)
    8000016a:	6109                	addi	sp,sp,128
    8000016c:	8082                	ret

000000008000016e <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000016e:	711d                	addi	sp,sp,-96
    80000170:	ec86                	sd	ra,88(sp)
    80000172:	e8a2                	sd	s0,80(sp)
    80000174:	e4a6                	sd	s1,72(sp)
    80000176:	e0ca                	sd	s2,64(sp)
    80000178:	fc4e                	sd	s3,56(sp)
    8000017a:	f852                	sd	s4,48(sp)
    8000017c:	f456                	sd	s5,40(sp)
    8000017e:	f05a                	sd	s6,32(sp)
    80000180:	1080                	addi	s0,sp,96
    80000182:	8aaa                	mv	s5,a0
    80000184:	8a2e                	mv	s4,a1
    80000186:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000188:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018c:	00012517          	auipc	a0,0x12
    80000190:	05450513          	addi	a0,a0,84 # 800121e0 <cons>
    80000194:	23b000ef          	jal	80000bce <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000198:	00012497          	auipc	s1,0x12
    8000019c:	04848493          	addi	s1,s1,72 # 800121e0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a0:	00012917          	auipc	s2,0x12
    800001a4:	0d890913          	addi	s2,s2,216 # 80012278 <cons+0x98>
  while(n > 0){
    800001a8:	0b305d63          	blez	s3,80000262 <consoleread+0xf4>
    while(cons.r == cons.w){
    800001ac:	0984a783          	lw	a5,152(s1)
    800001b0:	09c4a703          	lw	a4,156(s1)
    800001b4:	0af71263          	bne	a4,a5,80000258 <consoleread+0xea>
      if(killed(myproc())){
    800001b8:	716010ef          	jal	800018ce <myproc>
    800001bc:	743010ef          	jal	800020fe <killed>
    800001c0:	e12d                	bnez	a0,80000222 <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    800001c2:	85a6                	mv	a1,s1
    800001c4:	854a                	mv	a0,s2
    800001c6:	501010ef          	jal	80001ec6 <sleep>
    while(cons.r == cons.w){
    800001ca:	0984a783          	lw	a5,152(s1)
    800001ce:	09c4a703          	lw	a4,156(s1)
    800001d2:	fef703e3          	beq	a4,a5,800001b8 <consoleread+0x4a>
    800001d6:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001d8:	00012717          	auipc	a4,0x12
    800001dc:	00870713          	addi	a4,a4,8 # 800121e0 <cons>
    800001e0:	0017869b          	addiw	a3,a5,1
    800001e4:	08d72c23          	sw	a3,152(a4)
    800001e8:	07f7f693          	andi	a3,a5,127
    800001ec:	9736                	add	a4,a4,a3
    800001ee:	01874703          	lbu	a4,24(a4)
    800001f2:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800001f6:	4691                	li	a3,4
    800001f8:	04db8663          	beq	s7,a3,80000244 <consoleread+0xd6>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    800001fc:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000200:	4685                	li	a3,1
    80000202:	faf40613          	addi	a2,s0,-81
    80000206:	85d2                	mv	a1,s4
    80000208:	8556                	mv	a0,s5
    8000020a:	018020ef          	jal	80002222 <either_copyout>
    8000020e:	57fd                	li	a5,-1
    80000210:	04f50863          	beq	a0,a5,80000260 <consoleread+0xf2>
      break;

    dst++;
    80000214:	0a05                	addi	s4,s4,1
    --n;
    80000216:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    80000218:	47a9                	li	a5,10
    8000021a:	04fb8d63          	beq	s7,a5,80000274 <consoleread+0x106>
    8000021e:	6be2                	ld	s7,24(sp)
    80000220:	b761                	j	800001a8 <consoleread+0x3a>
        release(&cons.lock);
    80000222:	00012517          	auipc	a0,0x12
    80000226:	fbe50513          	addi	a0,a0,-66 # 800121e0 <cons>
    8000022a:	23d000ef          	jal	80000c66 <release>
        return -1;
    8000022e:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000230:	60e6                	ld	ra,88(sp)
    80000232:	6446                	ld	s0,80(sp)
    80000234:	64a6                	ld	s1,72(sp)
    80000236:	6906                	ld	s2,64(sp)
    80000238:	79e2                	ld	s3,56(sp)
    8000023a:	7a42                	ld	s4,48(sp)
    8000023c:	7aa2                	ld	s5,40(sp)
    8000023e:	7b02                	ld	s6,32(sp)
    80000240:	6125                	addi	sp,sp,96
    80000242:	8082                	ret
      if(n < target){
    80000244:	0009871b          	sext.w	a4,s3
    80000248:	01677a63          	bgeu	a4,s6,8000025c <consoleread+0xee>
        cons.r--;
    8000024c:	00012717          	auipc	a4,0x12
    80000250:	02f72623          	sw	a5,44(a4) # 80012278 <cons+0x98>
    80000254:	6be2                	ld	s7,24(sp)
    80000256:	a031                	j	80000262 <consoleread+0xf4>
    80000258:	ec5e                	sd	s7,24(sp)
    8000025a:	bfbd                	j	800001d8 <consoleread+0x6a>
    8000025c:	6be2                	ld	s7,24(sp)
    8000025e:	a011                	j	80000262 <consoleread+0xf4>
    80000260:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80000262:	00012517          	auipc	a0,0x12
    80000266:	f7e50513          	addi	a0,a0,-130 # 800121e0 <cons>
    8000026a:	1fd000ef          	jal	80000c66 <release>
  return target - n;
    8000026e:	413b053b          	subw	a0,s6,s3
    80000272:	bf7d                	j	80000230 <consoleread+0xc2>
    80000274:	6be2                	ld	s7,24(sp)
    80000276:	b7f5                	j	80000262 <consoleread+0xf4>

0000000080000278 <consputc>:
{
    80000278:	1141                	addi	sp,sp,-16
    8000027a:	e406                	sd	ra,8(sp)
    8000027c:	e022                	sd	s0,0(sp)
    8000027e:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000280:	10000793          	li	a5,256
    80000284:	00f50863          	beq	a0,a5,80000294 <consputc+0x1c>
    uartputc_sync(c);
    80000288:	6a4000ef          	jal	8000092c <uartputc_sync>
}
    8000028c:	60a2                	ld	ra,8(sp)
    8000028e:	6402                	ld	s0,0(sp)
    80000290:	0141                	addi	sp,sp,16
    80000292:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000294:	4521                	li	a0,8
    80000296:	696000ef          	jal	8000092c <uartputc_sync>
    8000029a:	02000513          	li	a0,32
    8000029e:	68e000ef          	jal	8000092c <uartputc_sync>
    800002a2:	4521                	li	a0,8
    800002a4:	688000ef          	jal	8000092c <uartputc_sync>
    800002a8:	b7d5                	j	8000028c <consputc+0x14>

00000000800002aa <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002aa:	1101                	addi	sp,sp,-32
    800002ac:	ec06                	sd	ra,24(sp)
    800002ae:	e822                	sd	s0,16(sp)
    800002b0:	e426                	sd	s1,8(sp)
    800002b2:	1000                	addi	s0,sp,32
    800002b4:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002b6:	00012517          	auipc	a0,0x12
    800002ba:	f2a50513          	addi	a0,a0,-214 # 800121e0 <cons>
    800002be:	111000ef          	jal	80000bce <acquire>

  switch(c){
    800002c2:	47d5                	li	a5,21
    800002c4:	08f48f63          	beq	s1,a5,80000362 <consoleintr+0xb8>
    800002c8:	0297c563          	blt	a5,s1,800002f2 <consoleintr+0x48>
    800002cc:	47a1                	li	a5,8
    800002ce:	0ef48463          	beq	s1,a5,800003b6 <consoleintr+0x10c>
    800002d2:	47c1                	li	a5,16
    800002d4:	10f49563          	bne	s1,a5,800003de <consoleintr+0x134>
  case C('P'):  // Print process list.
    procdump();
    800002d8:	7df010ef          	jal	800022b6 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002dc:	00012517          	auipc	a0,0x12
    800002e0:	f0450513          	addi	a0,a0,-252 # 800121e0 <cons>
    800002e4:	183000ef          	jal	80000c66 <release>
}
    800002e8:	60e2                	ld	ra,24(sp)
    800002ea:	6442                	ld	s0,16(sp)
    800002ec:	64a2                	ld	s1,8(sp)
    800002ee:	6105                	addi	sp,sp,32
    800002f0:	8082                	ret
  switch(c){
    800002f2:	07f00793          	li	a5,127
    800002f6:	0cf48063          	beq	s1,a5,800003b6 <consoleintr+0x10c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002fa:	00012717          	auipc	a4,0x12
    800002fe:	ee670713          	addi	a4,a4,-282 # 800121e0 <cons>
    80000302:	0a072783          	lw	a5,160(a4)
    80000306:	09872703          	lw	a4,152(a4)
    8000030a:	9f99                	subw	a5,a5,a4
    8000030c:	07f00713          	li	a4,127
    80000310:	fcf766e3          	bltu	a4,a5,800002dc <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    80000314:	47b5                	li	a5,13
    80000316:	0cf48763          	beq	s1,a5,800003e4 <consoleintr+0x13a>
      consputc(c);
    8000031a:	8526                	mv	a0,s1
    8000031c:	f5dff0ef          	jal	80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000320:	00012797          	auipc	a5,0x12
    80000324:	ec078793          	addi	a5,a5,-320 # 800121e0 <cons>
    80000328:	0a07a683          	lw	a3,160(a5)
    8000032c:	0016871b          	addiw	a4,a3,1
    80000330:	0007061b          	sext.w	a2,a4
    80000334:	0ae7a023          	sw	a4,160(a5)
    80000338:	07f6f693          	andi	a3,a3,127
    8000033c:	97b6                	add	a5,a5,a3
    8000033e:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000342:	47a9                	li	a5,10
    80000344:	0cf48563          	beq	s1,a5,8000040e <consoleintr+0x164>
    80000348:	4791                	li	a5,4
    8000034a:	0cf48263          	beq	s1,a5,8000040e <consoleintr+0x164>
    8000034e:	00012797          	auipc	a5,0x12
    80000352:	f2a7a783          	lw	a5,-214(a5) # 80012278 <cons+0x98>
    80000356:	9f1d                	subw	a4,a4,a5
    80000358:	08000793          	li	a5,128
    8000035c:	f8f710e3          	bne	a4,a5,800002dc <consoleintr+0x32>
    80000360:	a07d                	j	8000040e <consoleintr+0x164>
    80000362:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80000364:	00012717          	auipc	a4,0x12
    80000368:	e7c70713          	addi	a4,a4,-388 # 800121e0 <cons>
    8000036c:	0a072783          	lw	a5,160(a4)
    80000370:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000374:	00012497          	auipc	s1,0x12
    80000378:	e6c48493          	addi	s1,s1,-404 # 800121e0 <cons>
    while(cons.e != cons.w &&
    8000037c:	4929                	li	s2,10
    8000037e:	02f70863          	beq	a4,a5,800003ae <consoleintr+0x104>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000382:	37fd                	addiw	a5,a5,-1
    80000384:	07f7f713          	andi	a4,a5,127
    80000388:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    8000038a:	01874703          	lbu	a4,24(a4)
    8000038e:	03270263          	beq	a4,s2,800003b2 <consoleintr+0x108>
      cons.e--;
    80000392:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80000396:	10000513          	li	a0,256
    8000039a:	edfff0ef          	jal	80000278 <consputc>
    while(cons.e != cons.w &&
    8000039e:	0a04a783          	lw	a5,160(s1)
    800003a2:	09c4a703          	lw	a4,156(s1)
    800003a6:	fcf71ee3          	bne	a4,a5,80000382 <consoleintr+0xd8>
    800003aa:	6902                	ld	s2,0(sp)
    800003ac:	bf05                	j	800002dc <consoleintr+0x32>
    800003ae:	6902                	ld	s2,0(sp)
    800003b0:	b735                	j	800002dc <consoleintr+0x32>
    800003b2:	6902                	ld	s2,0(sp)
    800003b4:	b725                	j	800002dc <consoleintr+0x32>
    if(cons.e != cons.w){
    800003b6:	00012717          	auipc	a4,0x12
    800003ba:	e2a70713          	addi	a4,a4,-470 # 800121e0 <cons>
    800003be:	0a072783          	lw	a5,160(a4)
    800003c2:	09c72703          	lw	a4,156(a4)
    800003c6:	f0f70be3          	beq	a4,a5,800002dc <consoleintr+0x32>
      cons.e--;
    800003ca:	37fd                	addiw	a5,a5,-1
    800003cc:	00012717          	auipc	a4,0x12
    800003d0:	eaf72a23          	sw	a5,-332(a4) # 80012280 <cons+0xa0>
      consputc(BACKSPACE);
    800003d4:	10000513          	li	a0,256
    800003d8:	ea1ff0ef          	jal	80000278 <consputc>
    800003dc:	b701                	j	800002dc <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003de:	ee048fe3          	beqz	s1,800002dc <consoleintr+0x32>
    800003e2:	bf21                	j	800002fa <consoleintr+0x50>
      consputc(c);
    800003e4:	4529                	li	a0,10
    800003e6:	e93ff0ef          	jal	80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003ea:	00012797          	auipc	a5,0x12
    800003ee:	df678793          	addi	a5,a5,-522 # 800121e0 <cons>
    800003f2:	0a07a703          	lw	a4,160(a5)
    800003f6:	0017069b          	addiw	a3,a4,1
    800003fa:	0006861b          	sext.w	a2,a3
    800003fe:	0ad7a023          	sw	a3,160(a5)
    80000402:	07f77713          	andi	a4,a4,127
    80000406:	97ba                	add	a5,a5,a4
    80000408:	4729                	li	a4,10
    8000040a:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000040e:	00012797          	auipc	a5,0x12
    80000412:	e6c7a723          	sw	a2,-402(a5) # 8001227c <cons+0x9c>
        wakeup(&cons.r);
    80000416:	00012517          	auipc	a0,0x12
    8000041a:	e6250513          	addi	a0,a0,-414 # 80012278 <cons+0x98>
    8000041e:	2f5010ef          	jal	80001f12 <wakeup>
    80000422:	bd6d                	j	800002dc <consoleintr+0x32>

0000000080000424 <consoleinit>:

void
consoleinit(void)
{
    80000424:	1141                	addi	sp,sp,-16
    80000426:	e406                	sd	ra,8(sp)
    80000428:	e022                	sd	s0,0(sp)
    8000042a:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000042c:	00007597          	auipc	a1,0x7
    80000430:	bd458593          	addi	a1,a1,-1068 # 80007000 <etext>
    80000434:	00012517          	auipc	a0,0x12
    80000438:	dac50513          	addi	a0,a0,-596 # 800121e0 <cons>
    8000043c:	712000ef          	jal	80000b4e <initlock>

  uartinit();
    80000440:	400000ef          	jal	80000840 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000444:	00022797          	auipc	a5,0x22
    80000448:	f0c78793          	addi	a5,a5,-244 # 80022350 <devsw>
    8000044c:	00000717          	auipc	a4,0x0
    80000450:	d2270713          	addi	a4,a4,-734 # 8000016e <consoleread>
    80000454:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000456:	00000717          	auipc	a4,0x0
    8000045a:	c7a70713          	addi	a4,a4,-902 # 800000d0 <consolewrite>
    8000045e:	ef98                	sd	a4,24(a5)
}
    80000460:	60a2                	ld	ra,8(sp)
    80000462:	6402                	ld	s0,0(sp)
    80000464:	0141                	addi	sp,sp,16
    80000466:	8082                	ret

0000000080000468 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000468:	7139                	addi	sp,sp,-64
    8000046a:	fc06                	sd	ra,56(sp)
    8000046c:	f822                	sd	s0,48(sp)
    8000046e:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80000470:	c219                	beqz	a2,80000476 <printint+0xe>
    80000472:	08054063          	bltz	a0,800004f2 <printint+0x8a>
    x = -xx;
  else
    x = xx;
    80000476:	4881                	li	a7,0
    80000478:	fc840693          	addi	a3,s0,-56

  i = 0;
    8000047c:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    8000047e:	00007617          	auipc	a2,0x7
    80000482:	29260613          	addi	a2,a2,658 # 80007710 <digits>
    80000486:	883e                	mv	a6,a5
    80000488:	2785                	addiw	a5,a5,1
    8000048a:	02b57733          	remu	a4,a0,a1
    8000048e:	9732                	add	a4,a4,a2
    80000490:	00074703          	lbu	a4,0(a4)
    80000494:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    80000498:	872a                	mv	a4,a0
    8000049a:	02b55533          	divu	a0,a0,a1
    8000049e:	0685                	addi	a3,a3,1
    800004a0:	feb773e3          	bgeu	a4,a1,80000486 <printint+0x1e>

  if(sign)
    800004a4:	00088a63          	beqz	a7,800004b8 <printint+0x50>
    buf[i++] = '-';
    800004a8:	1781                	addi	a5,a5,-32
    800004aa:	97a2                	add	a5,a5,s0
    800004ac:	02d00713          	li	a4,45
    800004b0:	fee78423          	sb	a4,-24(a5)
    800004b4:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    800004b8:	02f05963          	blez	a5,800004ea <printint+0x82>
    800004bc:	f426                	sd	s1,40(sp)
    800004be:	f04a                	sd	s2,32(sp)
    800004c0:	fc840713          	addi	a4,s0,-56
    800004c4:	00f704b3          	add	s1,a4,a5
    800004c8:	fff70913          	addi	s2,a4,-1
    800004cc:	993e                	add	s2,s2,a5
    800004ce:	37fd                	addiw	a5,a5,-1
    800004d0:	1782                	slli	a5,a5,0x20
    800004d2:	9381                	srli	a5,a5,0x20
    800004d4:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800004d8:	fff4c503          	lbu	a0,-1(s1)
    800004dc:	d9dff0ef          	jal	80000278 <consputc>
  while(--i >= 0)
    800004e0:	14fd                	addi	s1,s1,-1
    800004e2:	ff249be3          	bne	s1,s2,800004d8 <printint+0x70>
    800004e6:	74a2                	ld	s1,40(sp)
    800004e8:	7902                	ld	s2,32(sp)
}
    800004ea:	70e2                	ld	ra,56(sp)
    800004ec:	7442                	ld	s0,48(sp)
    800004ee:	6121                	addi	sp,sp,64
    800004f0:	8082                	ret
    x = -xx;
    800004f2:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004f6:	4885                	li	a7,1
    x = -xx;
    800004f8:	b741                	j	80000478 <printint+0x10>

00000000800004fa <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004fa:	7131                	addi	sp,sp,-192
    800004fc:	fc86                	sd	ra,120(sp)
    800004fe:	f8a2                	sd	s0,112(sp)
    80000500:	e8d2                	sd	s4,80(sp)
    80000502:	0100                	addi	s0,sp,128
    80000504:	8a2a                	mv	s4,a0
    80000506:	e40c                	sd	a1,8(s0)
    80000508:	e810                	sd	a2,16(s0)
    8000050a:	ec14                	sd	a3,24(s0)
    8000050c:	f018                	sd	a4,32(s0)
    8000050e:	f41c                	sd	a5,40(s0)
    80000510:	03043823          	sd	a6,48(s0)
    80000514:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2;
  char *s;

  if(panicking == 0)
    80000518:	0000a797          	auipc	a5,0xa
    8000051c:	c9c7a783          	lw	a5,-868(a5) # 8000a1b4 <panicking>
    80000520:	c3a1                	beqz	a5,80000560 <printf+0x66>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80000522:	00840793          	addi	a5,s0,8
    80000526:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000052a:	000a4503          	lbu	a0,0(s4)
    8000052e:	28050763          	beqz	a0,800007bc <printf+0x2c2>
    80000532:	f4a6                	sd	s1,104(sp)
    80000534:	f0ca                	sd	s2,96(sp)
    80000536:	ecce                	sd	s3,88(sp)
    80000538:	e4d6                	sd	s5,72(sp)
    8000053a:	e0da                	sd	s6,64(sp)
    8000053c:	f862                	sd	s8,48(sp)
    8000053e:	f466                	sd	s9,40(sp)
    80000540:	f06a                	sd	s10,32(sp)
    80000542:	ec6e                	sd	s11,24(sp)
    80000544:	4981                	li	s3,0
    if(cx != '%'){
    80000546:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    8000054a:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    8000054e:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    80000552:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80000556:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    8000055a:	07000d93          	li	s11,112
    8000055e:	a01d                	j	80000584 <printf+0x8a>
    acquire(&pr.lock);
    80000560:	00012517          	auipc	a0,0x12
    80000564:	d2850513          	addi	a0,a0,-728 # 80012288 <pr>
    80000568:	666000ef          	jal	80000bce <acquire>
    8000056c:	bf5d                	j	80000522 <printf+0x28>
      consputc(cx);
    8000056e:	d0bff0ef          	jal	80000278 <consputc>
      continue;
    80000572:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000574:	0014899b          	addiw	s3,s1,1
    80000578:	013a07b3          	add	a5,s4,s3
    8000057c:	0007c503          	lbu	a0,0(a5)
    80000580:	20050b63          	beqz	a0,80000796 <printf+0x29c>
    if(cx != '%'){
    80000584:	ff5515e3          	bne	a0,s5,8000056e <printf+0x74>
    i++;
    80000588:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    8000058c:	009a07b3          	add	a5,s4,s1
    80000590:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    80000594:	20090b63          	beqz	s2,800007aa <printf+0x2b0>
    80000598:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    8000059c:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    8000059e:	c789                	beqz	a5,800005a8 <printf+0xae>
    800005a0:	009a0733          	add	a4,s4,s1
    800005a4:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    800005a8:	03690963          	beq	s2,s6,800005da <printf+0xe0>
    } else if(c0 == 'l' && c1 == 'd'){
    800005ac:	05890363          	beq	s2,s8,800005f2 <printf+0xf8>
    } else if(c0 == 'u'){
    800005b0:	0d990663          	beq	s2,s9,8000067c <printf+0x182>
    } else if(c0 == 'x'){
    800005b4:	11a90d63          	beq	s2,s10,800006ce <printf+0x1d4>
    } else if(c0 == 'p'){
    800005b8:	15b90663          	beq	s2,s11,80000704 <printf+0x20a>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 'c'){
    800005bc:	06300793          	li	a5,99
    800005c0:	18f90563          	beq	s2,a5,8000074a <printf+0x250>
      consputc(va_arg(ap, uint));
    } else if(c0 == 's'){
    800005c4:	07300793          	li	a5,115
    800005c8:	18f90b63          	beq	s2,a5,8000075e <printf+0x264>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    800005cc:	03591b63          	bne	s2,s5,80000602 <printf+0x108>
      consputc('%');
    800005d0:	02500513          	li	a0,37
    800005d4:	ca5ff0ef          	jal	80000278 <consputc>
    800005d8:	bf71                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, int), 10, 1);
    800005da:	f8843783          	ld	a5,-120(s0)
    800005de:	00878713          	addi	a4,a5,8
    800005e2:	f8e43423          	sd	a4,-120(s0)
    800005e6:	4605                	li	a2,1
    800005e8:	45a9                	li	a1,10
    800005ea:	4388                	lw	a0,0(a5)
    800005ec:	e7dff0ef          	jal	80000468 <printint>
    800005f0:	b751                	j	80000574 <printf+0x7a>
    } else if(c0 == 'l' && c1 == 'd'){
    800005f2:	01678f63          	beq	a5,s6,80000610 <printf+0x116>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800005f6:	03878b63          	beq	a5,s8,8000062c <printf+0x132>
    } else if(c0 == 'l' && c1 == 'u'){
    800005fa:	09978e63          	beq	a5,s9,80000696 <printf+0x19c>
    } else if(c0 == 'l' && c1 == 'x'){
    800005fe:	0fa78563          	beq	a5,s10,800006e8 <printf+0x1ee>
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    80000602:	8556                	mv	a0,s5
    80000604:	c75ff0ef          	jal	80000278 <consputc>
      consputc(c0);
    80000608:	854a                	mv	a0,s2
    8000060a:	c6fff0ef          	jal	80000278 <consputc>
    8000060e:	b79d                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    80000610:	f8843783          	ld	a5,-120(s0)
    80000614:	00878713          	addi	a4,a5,8
    80000618:	f8e43423          	sd	a4,-120(s0)
    8000061c:	4605                	li	a2,1
    8000061e:	45a9                	li	a1,10
    80000620:	6388                	ld	a0,0(a5)
    80000622:	e47ff0ef          	jal	80000468 <printint>
      i += 1;
    80000626:	0029849b          	addiw	s1,s3,2
    8000062a:	b7a9                	j	80000574 <printf+0x7a>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    8000062c:	06400793          	li	a5,100
    80000630:	02f68863          	beq	a3,a5,80000660 <printf+0x166>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80000634:	07500793          	li	a5,117
    80000638:	06f68d63          	beq	a3,a5,800006b2 <printf+0x1b8>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    8000063c:	07800793          	li	a5,120
    80000640:	fcf691e3          	bne	a3,a5,80000602 <printf+0x108>
      printint(va_arg(ap, uint64), 16, 0);
    80000644:	f8843783          	ld	a5,-120(s0)
    80000648:	00878713          	addi	a4,a5,8
    8000064c:	f8e43423          	sd	a4,-120(s0)
    80000650:	4601                	li	a2,0
    80000652:	45c1                	li	a1,16
    80000654:	6388                	ld	a0,0(a5)
    80000656:	e13ff0ef          	jal	80000468 <printint>
      i += 2;
    8000065a:	0039849b          	addiw	s1,s3,3
    8000065e:	bf19                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    80000660:	f8843783          	ld	a5,-120(s0)
    80000664:	00878713          	addi	a4,a5,8
    80000668:	f8e43423          	sd	a4,-120(s0)
    8000066c:	4605                	li	a2,1
    8000066e:	45a9                	li	a1,10
    80000670:	6388                	ld	a0,0(a5)
    80000672:	df7ff0ef          	jal	80000468 <printint>
      i += 2;
    80000676:	0039849b          	addiw	s1,s3,3
    8000067a:	bded                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint32), 10, 0);
    8000067c:	f8843783          	ld	a5,-120(s0)
    80000680:	00878713          	addi	a4,a5,8
    80000684:	f8e43423          	sd	a4,-120(s0)
    80000688:	4601                	li	a2,0
    8000068a:	45a9                	li	a1,10
    8000068c:	0007e503          	lwu	a0,0(a5)
    80000690:	dd9ff0ef          	jal	80000468 <printint>
    80000694:	b5c5                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    80000696:	f8843783          	ld	a5,-120(s0)
    8000069a:	00878713          	addi	a4,a5,8
    8000069e:	f8e43423          	sd	a4,-120(s0)
    800006a2:	4601                	li	a2,0
    800006a4:	45a9                	li	a1,10
    800006a6:	6388                	ld	a0,0(a5)
    800006a8:	dc1ff0ef          	jal	80000468 <printint>
      i += 1;
    800006ac:	0029849b          	addiw	s1,s3,2
    800006b0:	b5d1                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    800006b2:	f8843783          	ld	a5,-120(s0)
    800006b6:	00878713          	addi	a4,a5,8
    800006ba:	f8e43423          	sd	a4,-120(s0)
    800006be:	4601                	li	a2,0
    800006c0:	45a9                	li	a1,10
    800006c2:	6388                	ld	a0,0(a5)
    800006c4:	da5ff0ef          	jal	80000468 <printint>
      i += 2;
    800006c8:	0039849b          	addiw	s1,s3,3
    800006cc:	b565                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint32), 16, 0);
    800006ce:	f8843783          	ld	a5,-120(s0)
    800006d2:	00878713          	addi	a4,a5,8
    800006d6:	f8e43423          	sd	a4,-120(s0)
    800006da:	4601                	li	a2,0
    800006dc:	45c1                	li	a1,16
    800006de:	0007e503          	lwu	a0,0(a5)
    800006e2:	d87ff0ef          	jal	80000468 <printint>
    800006e6:	b579                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 16, 0);
    800006e8:	f8843783          	ld	a5,-120(s0)
    800006ec:	00878713          	addi	a4,a5,8
    800006f0:	f8e43423          	sd	a4,-120(s0)
    800006f4:	4601                	li	a2,0
    800006f6:	45c1                	li	a1,16
    800006f8:	6388                	ld	a0,0(a5)
    800006fa:	d6fff0ef          	jal	80000468 <printint>
      i += 1;
    800006fe:	0029849b          	addiw	s1,s3,2
    80000702:	bd8d                	j	80000574 <printf+0x7a>
    80000704:	fc5e                	sd	s7,56(sp)
      printptr(va_arg(ap, uint64));
    80000706:	f8843783          	ld	a5,-120(s0)
    8000070a:	00878713          	addi	a4,a5,8
    8000070e:	f8e43423          	sd	a4,-120(s0)
    80000712:	0007b983          	ld	s3,0(a5)
  consputc('0');
    80000716:	03000513          	li	a0,48
    8000071a:	b5fff0ef          	jal	80000278 <consputc>
  consputc('x');
    8000071e:	07800513          	li	a0,120
    80000722:	b57ff0ef          	jal	80000278 <consputc>
    80000726:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000728:	00007b97          	auipc	s7,0x7
    8000072c:	fe8b8b93          	addi	s7,s7,-24 # 80007710 <digits>
    80000730:	03c9d793          	srli	a5,s3,0x3c
    80000734:	97de                	add	a5,a5,s7
    80000736:	0007c503          	lbu	a0,0(a5)
    8000073a:	b3fff0ef          	jal	80000278 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000073e:	0992                	slli	s3,s3,0x4
    80000740:	397d                	addiw	s2,s2,-1
    80000742:	fe0917e3          	bnez	s2,80000730 <printf+0x236>
    80000746:	7be2                	ld	s7,56(sp)
    80000748:	b535                	j	80000574 <printf+0x7a>
      consputc(va_arg(ap, uint));
    8000074a:	f8843783          	ld	a5,-120(s0)
    8000074e:	00878713          	addi	a4,a5,8
    80000752:	f8e43423          	sd	a4,-120(s0)
    80000756:	4388                	lw	a0,0(a5)
    80000758:	b21ff0ef          	jal	80000278 <consputc>
    8000075c:	bd21                	j	80000574 <printf+0x7a>
      if((s = va_arg(ap, char*)) == 0)
    8000075e:	f8843783          	ld	a5,-120(s0)
    80000762:	00878713          	addi	a4,a5,8
    80000766:	f8e43423          	sd	a4,-120(s0)
    8000076a:	0007b903          	ld	s2,0(a5)
    8000076e:	00090d63          	beqz	s2,80000788 <printf+0x28e>
      for(; *s; s++)
    80000772:	00094503          	lbu	a0,0(s2)
    80000776:	de050fe3          	beqz	a0,80000574 <printf+0x7a>
        consputc(*s);
    8000077a:	affff0ef          	jal	80000278 <consputc>
      for(; *s; s++)
    8000077e:	0905                	addi	s2,s2,1
    80000780:	00094503          	lbu	a0,0(s2)
    80000784:	f97d                	bnez	a0,8000077a <printf+0x280>
    80000786:	b3fd                	j	80000574 <printf+0x7a>
        s = "(null)";
    80000788:	00007917          	auipc	s2,0x7
    8000078c:	88090913          	addi	s2,s2,-1920 # 80007008 <etext+0x8>
      for(; *s; s++)
    80000790:	02800513          	li	a0,40
    80000794:	b7dd                	j	8000077a <printf+0x280>
    80000796:	74a6                	ld	s1,104(sp)
    80000798:	7906                	ld	s2,96(sp)
    8000079a:	69e6                	ld	s3,88(sp)
    8000079c:	6aa6                	ld	s5,72(sp)
    8000079e:	6b06                	ld	s6,64(sp)
    800007a0:	7c42                	ld	s8,48(sp)
    800007a2:	7ca2                	ld	s9,40(sp)
    800007a4:	7d02                	ld	s10,32(sp)
    800007a6:	6de2                	ld	s11,24(sp)
    800007a8:	a811                	j	800007bc <printf+0x2c2>
    800007aa:	74a6                	ld	s1,104(sp)
    800007ac:	7906                	ld	s2,96(sp)
    800007ae:	69e6                	ld	s3,88(sp)
    800007b0:	6aa6                	ld	s5,72(sp)
    800007b2:	6b06                	ld	s6,64(sp)
    800007b4:	7c42                	ld	s8,48(sp)
    800007b6:	7ca2                	ld	s9,40(sp)
    800007b8:	7d02                	ld	s10,32(sp)
    800007ba:	6de2                	ld	s11,24(sp)
    }

  }
  va_end(ap);

  if(panicking == 0)
    800007bc:	0000a797          	auipc	a5,0xa
    800007c0:	9f87a783          	lw	a5,-1544(a5) # 8000a1b4 <panicking>
    800007c4:	c799                	beqz	a5,800007d2 <printf+0x2d8>
    release(&pr.lock);

  return 0;
}
    800007c6:	4501                	li	a0,0
    800007c8:	70e6                	ld	ra,120(sp)
    800007ca:	7446                	ld	s0,112(sp)
    800007cc:	6a46                	ld	s4,80(sp)
    800007ce:	6129                	addi	sp,sp,192
    800007d0:	8082                	ret
    release(&pr.lock);
    800007d2:	00012517          	auipc	a0,0x12
    800007d6:	ab650513          	addi	a0,a0,-1354 # 80012288 <pr>
    800007da:	48c000ef          	jal	80000c66 <release>
  return 0;
    800007de:	b7e5                	j	800007c6 <printf+0x2cc>

00000000800007e0 <panic>:

void
panic(char *s)
{
    800007e0:	1101                	addi	sp,sp,-32
    800007e2:	ec06                	sd	ra,24(sp)
    800007e4:	e822                	sd	s0,16(sp)
    800007e6:	e426                	sd	s1,8(sp)
    800007e8:	e04a                	sd	s2,0(sp)
    800007ea:	1000                	addi	s0,sp,32
    800007ec:	84aa                	mv	s1,a0
  panicking = 1;
    800007ee:	4905                	li	s2,1
    800007f0:	0000a797          	auipc	a5,0xa
    800007f4:	9d27a223          	sw	s2,-1596(a5) # 8000a1b4 <panicking>
  printf("panic: ");
    800007f8:	00007517          	auipc	a0,0x7
    800007fc:	82050513          	addi	a0,a0,-2016 # 80007018 <etext+0x18>
    80000800:	cfbff0ef          	jal	800004fa <printf>
  printf("%s\n", s);
    80000804:	85a6                	mv	a1,s1
    80000806:	00007517          	auipc	a0,0x7
    8000080a:	81a50513          	addi	a0,a0,-2022 # 80007020 <etext+0x20>
    8000080e:	cedff0ef          	jal	800004fa <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000812:	0000a797          	auipc	a5,0xa
    80000816:	9927af23          	sw	s2,-1634(a5) # 8000a1b0 <panicked>
  for(;;)
    8000081a:	a001                	j	8000081a <panic+0x3a>

000000008000081c <printfinit>:
    ;
}

void
printfinit(void)
{
    8000081c:	1141                	addi	sp,sp,-16
    8000081e:	e406                	sd	ra,8(sp)
    80000820:	e022                	sd	s0,0(sp)
    80000822:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    80000824:	00007597          	auipc	a1,0x7
    80000828:	80458593          	addi	a1,a1,-2044 # 80007028 <etext+0x28>
    8000082c:	00012517          	auipc	a0,0x12
    80000830:	a5c50513          	addi	a0,a0,-1444 # 80012288 <pr>
    80000834:	31a000ef          	jal	80000b4e <initlock>
}
    80000838:	60a2                	ld	ra,8(sp)
    8000083a:	6402                	ld	s0,0(sp)
    8000083c:	0141                	addi	sp,sp,16
    8000083e:	8082                	ret

0000000080000840 <uartinit>:
extern volatile int panicking; // from printf.c
extern volatile int panicked; // from printf.c

void
uartinit(void)
{
    80000840:	1141                	addi	sp,sp,-16
    80000842:	e406                	sd	ra,8(sp)
    80000844:	e022                	sd	s0,0(sp)
    80000846:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000848:	100007b7          	lui	a5,0x10000
    8000084c:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000850:	10000737          	lui	a4,0x10000
    80000854:	f8000693          	li	a3,-128
    80000858:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    8000085c:	468d                	li	a3,3
    8000085e:	10000637          	lui	a2,0x10000
    80000862:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000866:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    8000086a:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000086e:	10000737          	lui	a4,0x10000
    80000872:	461d                	li	a2,7
    80000874:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000878:	00d780a3          	sb	a3,1(a5)

  initlock(&tx_lock, "uart");
    8000087c:	00006597          	auipc	a1,0x6
    80000880:	7b458593          	addi	a1,a1,1972 # 80007030 <etext+0x30>
    80000884:	00012517          	auipc	a0,0x12
    80000888:	a1c50513          	addi	a0,a0,-1508 # 800122a0 <tx_lock>
    8000088c:	2c2000ef          	jal	80000b4e <initlock>
}
    80000890:	60a2                	ld	ra,8(sp)
    80000892:	6402                	ld	s0,0(sp)
    80000894:	0141                	addi	sp,sp,16
    80000896:	8082                	ret

0000000080000898 <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    80000898:	715d                	addi	sp,sp,-80
    8000089a:	e486                	sd	ra,72(sp)
    8000089c:	e0a2                	sd	s0,64(sp)
    8000089e:	fc26                	sd	s1,56(sp)
    800008a0:	ec56                	sd	s5,24(sp)
    800008a2:	0880                	addi	s0,sp,80
    800008a4:	8aaa                	mv	s5,a0
    800008a6:	84ae                	mv	s1,a1
  acquire(&tx_lock);
    800008a8:	00012517          	auipc	a0,0x12
    800008ac:	9f850513          	addi	a0,a0,-1544 # 800122a0 <tx_lock>
    800008b0:	31e000ef          	jal	80000bce <acquire>

  int i = 0;
  while(i < n){ 
    800008b4:	06905063          	blez	s1,80000914 <uartwrite+0x7c>
    800008b8:	f84a                	sd	s2,48(sp)
    800008ba:	f44e                	sd	s3,40(sp)
    800008bc:	f052                	sd	s4,32(sp)
    800008be:	e85a                	sd	s6,16(sp)
    800008c0:	e45e                	sd	s7,8(sp)
    800008c2:	8a56                	mv	s4,s5
    800008c4:	9aa6                	add	s5,s5,s1
    while(tx_busy != 0){
    800008c6:	0000a497          	auipc	s1,0xa
    800008ca:	8f648493          	addi	s1,s1,-1802 # 8000a1bc <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    800008ce:	00012997          	auipc	s3,0x12
    800008d2:	9d298993          	addi	s3,s3,-1582 # 800122a0 <tx_lock>
    800008d6:	0000a917          	auipc	s2,0xa
    800008da:	8e290913          	addi	s2,s2,-1822 # 8000a1b8 <tx_chan>
    }   
      
    WriteReg(THR, buf[i]);
    800008de:	10000bb7          	lui	s7,0x10000
    i += 1;
    tx_busy = 1;
    800008e2:	4b05                	li	s6,1
    800008e4:	a005                	j	80000904 <uartwrite+0x6c>
      sleep(&tx_chan, &tx_lock);
    800008e6:	85ce                	mv	a1,s3
    800008e8:	854a                	mv	a0,s2
    800008ea:	5dc010ef          	jal	80001ec6 <sleep>
    while(tx_busy != 0){
    800008ee:	409c                	lw	a5,0(s1)
    800008f0:	fbfd                	bnez	a5,800008e6 <uartwrite+0x4e>
    WriteReg(THR, buf[i]);
    800008f2:	000a4783          	lbu	a5,0(s4)
    800008f6:	00fb8023          	sb	a5,0(s7) # 10000000 <_entry-0x70000000>
    tx_busy = 1;
    800008fa:	0164a023          	sw	s6,0(s1)
  while(i < n){ 
    800008fe:	0a05                	addi	s4,s4,1
    80000900:	015a0563          	beq	s4,s5,8000090a <uartwrite+0x72>
    while(tx_busy != 0){
    80000904:	409c                	lw	a5,0(s1)
    80000906:	f3e5                	bnez	a5,800008e6 <uartwrite+0x4e>
    80000908:	b7ed                	j	800008f2 <uartwrite+0x5a>
    8000090a:	7942                	ld	s2,48(sp)
    8000090c:	79a2                	ld	s3,40(sp)
    8000090e:	7a02                	ld	s4,32(sp)
    80000910:	6b42                	ld	s6,16(sp)
    80000912:	6ba2                	ld	s7,8(sp)
  }

  release(&tx_lock);
    80000914:	00012517          	auipc	a0,0x12
    80000918:	98c50513          	addi	a0,a0,-1652 # 800122a0 <tx_lock>
    8000091c:	34a000ef          	jal	80000c66 <release>
}
    80000920:	60a6                	ld	ra,72(sp)
    80000922:	6406                	ld	s0,64(sp)
    80000924:	74e2                	ld	s1,56(sp)
    80000926:	6ae2                	ld	s5,24(sp)
    80000928:	6161                	addi	sp,sp,80
    8000092a:	8082                	ret

000000008000092c <uartputc_sync>:
// interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000092c:	1101                	addi	sp,sp,-32
    8000092e:	ec06                	sd	ra,24(sp)
    80000930:	e822                	sd	s0,16(sp)
    80000932:	e426                	sd	s1,8(sp)
    80000934:	1000                	addi	s0,sp,32
    80000936:	84aa                	mv	s1,a0
  if(panicking == 0)
    80000938:	0000a797          	auipc	a5,0xa
    8000093c:	87c7a783          	lw	a5,-1924(a5) # 8000a1b4 <panicking>
    80000940:	cf95                	beqz	a5,8000097c <uartputc_sync+0x50>
    push_off();

  if(panicked){
    80000942:	0000a797          	auipc	a5,0xa
    80000946:	86e7a783          	lw	a5,-1938(a5) # 8000a1b0 <panicked>
    8000094a:	ef85                	bnez	a5,80000982 <uartputc_sync+0x56>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000094c:	10000737          	lui	a4,0x10000
    80000950:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000952:	00074783          	lbu	a5,0(a4)
    80000956:	0207f793          	andi	a5,a5,32
    8000095a:	dfe5                	beqz	a5,80000952 <uartputc_sync+0x26>
    ;
  WriteReg(THR, c);
    8000095c:	0ff4f513          	zext.b	a0,s1
    80000960:	100007b7          	lui	a5,0x10000
    80000964:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if(panicking == 0)
    80000968:	0000a797          	auipc	a5,0xa
    8000096c:	84c7a783          	lw	a5,-1972(a5) # 8000a1b4 <panicking>
    80000970:	cb91                	beqz	a5,80000984 <uartputc_sync+0x58>
    pop_off();
}
    80000972:	60e2                	ld	ra,24(sp)
    80000974:	6442                	ld	s0,16(sp)
    80000976:	64a2                	ld	s1,8(sp)
    80000978:	6105                	addi	sp,sp,32
    8000097a:	8082                	ret
    push_off();
    8000097c:	212000ef          	jal	80000b8e <push_off>
    80000980:	b7c9                	j	80000942 <uartputc_sync+0x16>
    for(;;)
    80000982:	a001                	j	80000982 <uartputc_sync+0x56>
    pop_off();
    80000984:	28e000ef          	jal	80000c12 <pop_off>
}
    80000988:	b7ed                	j	80000972 <uartputc_sync+0x46>

000000008000098a <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    8000098a:	1141                	addi	sp,sp,-16
    8000098c:	e422                	sd	s0,8(sp)
    8000098e:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & LSR_RX_READY){
    80000990:	100007b7          	lui	a5,0x10000
    80000994:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    80000996:	0007c783          	lbu	a5,0(a5)
    8000099a:	8b85                	andi	a5,a5,1
    8000099c:	cb81                	beqz	a5,800009ac <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    8000099e:	100007b7          	lui	a5,0x10000
    800009a2:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009a6:	6422                	ld	s0,8(sp)
    800009a8:	0141                	addi	sp,sp,16
    800009aa:	8082                	ret
    return -1;
    800009ac:	557d                	li	a0,-1
    800009ae:	bfe5                	j	800009a6 <uartgetc+0x1c>

00000000800009b0 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009b0:	1101                	addi	sp,sp,-32
    800009b2:	ec06                	sd	ra,24(sp)
    800009b4:	e822                	sd	s0,16(sp)
    800009b6:	e426                	sd	s1,8(sp)
    800009b8:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    800009ba:	100007b7          	lui	a5,0x10000
    800009be:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    800009c0:	0007c783          	lbu	a5,0(a5)

  acquire(&tx_lock);
    800009c4:	00012517          	auipc	a0,0x12
    800009c8:	8dc50513          	addi	a0,a0,-1828 # 800122a0 <tx_lock>
    800009cc:	202000ef          	jal	80000bce <acquire>
  if(ReadReg(LSR) & LSR_TX_IDLE){
    800009d0:	100007b7          	lui	a5,0x10000
    800009d4:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009d6:	0007c783          	lbu	a5,0(a5)
    800009da:	0207f793          	andi	a5,a5,32
    800009de:	eb89                	bnez	a5,800009f0 <uartintr+0x40>
    // UART finished transmitting; wake up sending thread.
    tx_busy = 0;
    wakeup(&tx_chan);
  }
  release(&tx_lock);
    800009e0:	00012517          	auipc	a0,0x12
    800009e4:	8c050513          	addi	a0,a0,-1856 # 800122a0 <tx_lock>
    800009e8:	27e000ef          	jal	80000c66 <release>

  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009ec:	54fd                	li	s1,-1
    800009ee:	a831                	j	80000a0a <uartintr+0x5a>
    tx_busy = 0;
    800009f0:	00009797          	auipc	a5,0x9
    800009f4:	7c07a623          	sw	zero,1996(a5) # 8000a1bc <tx_busy>
    wakeup(&tx_chan);
    800009f8:	00009517          	auipc	a0,0x9
    800009fc:	7c050513          	addi	a0,a0,1984 # 8000a1b8 <tx_chan>
    80000a00:	512010ef          	jal	80001f12 <wakeup>
    80000a04:	bff1                	j	800009e0 <uartintr+0x30>
      break;
    consoleintr(c);
    80000a06:	8a5ff0ef          	jal	800002aa <consoleintr>
    int c = uartgetc();
    80000a0a:	f81ff0ef          	jal	8000098a <uartgetc>
    if(c == -1)
    80000a0e:	fe951ce3          	bne	a0,s1,80000a06 <uartintr+0x56>
  }
}
    80000a12:	60e2                	ld	ra,24(sp)
    80000a14:	6442                	ld	s0,16(sp)
    80000a16:	64a2                	ld	s1,8(sp)
    80000a18:	6105                	addi	sp,sp,32
    80000a1a:	8082                	ret

0000000080000a1c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a1c:	1101                	addi	sp,sp,-32
    80000a1e:	ec06                	sd	ra,24(sp)
    80000a20:	e822                	sd	s0,16(sp)
    80000a22:	e426                	sd	s1,8(sp)
    80000a24:	e04a                	sd	s2,0(sp)
    80000a26:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a28:	03451793          	slli	a5,a0,0x34
    80000a2c:	e7a9                	bnez	a5,80000a76 <kfree+0x5a>
    80000a2e:	84aa                	mv	s1,a0
    80000a30:	00023797          	auipc	a5,0x23
    80000a34:	ab878793          	addi	a5,a5,-1352 # 800234e8 <end>
    80000a38:	02f56f63          	bltu	a0,a5,80000a76 <kfree+0x5a>
    80000a3c:	47c5                	li	a5,17
    80000a3e:	07ee                	slli	a5,a5,0x1b
    80000a40:	02f57b63          	bgeu	a0,a5,80000a76 <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a44:	6605                	lui	a2,0x1
    80000a46:	4585                	li	a1,1
    80000a48:	25a000ef          	jal	80000ca2 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a4c:	00012917          	auipc	s2,0x12
    80000a50:	86c90913          	addi	s2,s2,-1940 # 800122b8 <kmem>
    80000a54:	854a                	mv	a0,s2
    80000a56:	178000ef          	jal	80000bce <acquire>
  r->next = kmem.freelist;
    80000a5a:	01893783          	ld	a5,24(s2)
    80000a5e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a60:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a64:	854a                	mv	a0,s2
    80000a66:	200000ef          	jal	80000c66 <release>
}
    80000a6a:	60e2                	ld	ra,24(sp)
    80000a6c:	6442                	ld	s0,16(sp)
    80000a6e:	64a2                	ld	s1,8(sp)
    80000a70:	6902                	ld	s2,0(sp)
    80000a72:	6105                	addi	sp,sp,32
    80000a74:	8082                	ret
    panic("kfree");
    80000a76:	00006517          	auipc	a0,0x6
    80000a7a:	5c250513          	addi	a0,a0,1474 # 80007038 <etext+0x38>
    80000a7e:	d63ff0ef          	jal	800007e0 <panic>

0000000080000a82 <freerange>:
{
    80000a82:	7179                	addi	sp,sp,-48
    80000a84:	f406                	sd	ra,40(sp)
    80000a86:	f022                	sd	s0,32(sp)
    80000a88:	ec26                	sd	s1,24(sp)
    80000a8a:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a8c:	6785                	lui	a5,0x1
    80000a8e:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a92:	00e504b3          	add	s1,a0,a4
    80000a96:	777d                	lui	a4,0xfffff
    80000a98:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a9a:	94be                	add	s1,s1,a5
    80000a9c:	0295e263          	bltu	a1,s1,80000ac0 <freerange+0x3e>
    80000aa0:	e84a                	sd	s2,16(sp)
    80000aa2:	e44e                	sd	s3,8(sp)
    80000aa4:	e052                	sd	s4,0(sp)
    80000aa6:	892e                	mv	s2,a1
    kfree(p);
    80000aa8:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000aaa:	6985                	lui	s3,0x1
    kfree(p);
    80000aac:	01448533          	add	a0,s1,s4
    80000ab0:	f6dff0ef          	jal	80000a1c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ab4:	94ce                	add	s1,s1,s3
    80000ab6:	fe997be3          	bgeu	s2,s1,80000aac <freerange+0x2a>
    80000aba:	6942                	ld	s2,16(sp)
    80000abc:	69a2                	ld	s3,8(sp)
    80000abe:	6a02                	ld	s4,0(sp)
}
    80000ac0:	70a2                	ld	ra,40(sp)
    80000ac2:	7402                	ld	s0,32(sp)
    80000ac4:	64e2                	ld	s1,24(sp)
    80000ac6:	6145                	addi	sp,sp,48
    80000ac8:	8082                	ret

0000000080000aca <kinit>:
{
    80000aca:	1141                	addi	sp,sp,-16
    80000acc:	e406                	sd	ra,8(sp)
    80000ace:	e022                	sd	s0,0(sp)
    80000ad0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ad2:	00006597          	auipc	a1,0x6
    80000ad6:	56e58593          	addi	a1,a1,1390 # 80007040 <etext+0x40>
    80000ada:	00011517          	auipc	a0,0x11
    80000ade:	7de50513          	addi	a0,a0,2014 # 800122b8 <kmem>
    80000ae2:	06c000ef          	jal	80000b4e <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ae6:	45c5                	li	a1,17
    80000ae8:	05ee                	slli	a1,a1,0x1b
    80000aea:	00023517          	auipc	a0,0x23
    80000aee:	9fe50513          	addi	a0,a0,-1538 # 800234e8 <end>
    80000af2:	f91ff0ef          	jal	80000a82 <freerange>
}
    80000af6:	60a2                	ld	ra,8(sp)
    80000af8:	6402                	ld	s0,0(sp)
    80000afa:	0141                	addi	sp,sp,16
    80000afc:	8082                	ret

0000000080000afe <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000afe:	1101                	addi	sp,sp,-32
    80000b00:	ec06                	sd	ra,24(sp)
    80000b02:	e822                	sd	s0,16(sp)
    80000b04:	e426                	sd	s1,8(sp)
    80000b06:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b08:	00011497          	auipc	s1,0x11
    80000b0c:	7b048493          	addi	s1,s1,1968 # 800122b8 <kmem>
    80000b10:	8526                	mv	a0,s1
    80000b12:	0bc000ef          	jal	80000bce <acquire>
  r = kmem.freelist;
    80000b16:	6c84                	ld	s1,24(s1)
  if(r)
    80000b18:	c485                	beqz	s1,80000b40 <kalloc+0x42>
    kmem.freelist = r->next;
    80000b1a:	609c                	ld	a5,0(s1)
    80000b1c:	00011517          	auipc	a0,0x11
    80000b20:	79c50513          	addi	a0,a0,1948 # 800122b8 <kmem>
    80000b24:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b26:	140000ef          	jal	80000c66 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b2a:	6605                	lui	a2,0x1
    80000b2c:	4595                	li	a1,5
    80000b2e:	8526                	mv	a0,s1
    80000b30:	172000ef          	jal	80000ca2 <memset>
  return (void*)r;
}
    80000b34:	8526                	mv	a0,s1
    80000b36:	60e2                	ld	ra,24(sp)
    80000b38:	6442                	ld	s0,16(sp)
    80000b3a:	64a2                	ld	s1,8(sp)
    80000b3c:	6105                	addi	sp,sp,32
    80000b3e:	8082                	ret
  release(&kmem.lock);
    80000b40:	00011517          	auipc	a0,0x11
    80000b44:	77850513          	addi	a0,a0,1912 # 800122b8 <kmem>
    80000b48:	11e000ef          	jal	80000c66 <release>
  if(r)
    80000b4c:	b7e5                	j	80000b34 <kalloc+0x36>

0000000080000b4e <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b4e:	1141                	addi	sp,sp,-16
    80000b50:	e422                	sd	s0,8(sp)
    80000b52:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b54:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b56:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b5a:	00053823          	sd	zero,16(a0)
}
    80000b5e:	6422                	ld	s0,8(sp)
    80000b60:	0141                	addi	sp,sp,16
    80000b62:	8082                	ret

0000000080000b64 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b64:	411c                	lw	a5,0(a0)
    80000b66:	e399                	bnez	a5,80000b6c <holding+0x8>
    80000b68:	4501                	li	a0,0
  return r;
}
    80000b6a:	8082                	ret
{
    80000b6c:	1101                	addi	sp,sp,-32
    80000b6e:	ec06                	sd	ra,24(sp)
    80000b70:	e822                	sd	s0,16(sp)
    80000b72:	e426                	sd	s1,8(sp)
    80000b74:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b76:	6904                	ld	s1,16(a0)
    80000b78:	53b000ef          	jal	800018b2 <mycpu>
    80000b7c:	40a48533          	sub	a0,s1,a0
    80000b80:	00153513          	seqz	a0,a0
}
    80000b84:	60e2                	ld	ra,24(sp)
    80000b86:	6442                	ld	s0,16(sp)
    80000b88:	64a2                	ld	s1,8(sp)
    80000b8a:	6105                	addi	sp,sp,32
    80000b8c:	8082                	ret

0000000080000b8e <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b8e:	1101                	addi	sp,sp,-32
    80000b90:	ec06                	sd	ra,24(sp)
    80000b92:	e822                	sd	s0,16(sp)
    80000b94:	e426                	sd	s1,8(sp)
    80000b96:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b98:	100024f3          	csrr	s1,sstatus
    80000b9c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000ba0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000ba2:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if(mycpu()->noff == 0)
    80000ba6:	50d000ef          	jal	800018b2 <mycpu>
    80000baa:	5d3c                	lw	a5,120(a0)
    80000bac:	cb99                	beqz	a5,80000bc2 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bae:	505000ef          	jal	800018b2 <mycpu>
    80000bb2:	5d3c                	lw	a5,120(a0)
    80000bb4:	2785                	addiw	a5,a5,1
    80000bb6:	dd3c                	sw	a5,120(a0)
}
    80000bb8:	60e2                	ld	ra,24(sp)
    80000bba:	6442                	ld	s0,16(sp)
    80000bbc:	64a2                	ld	s1,8(sp)
    80000bbe:	6105                	addi	sp,sp,32
    80000bc0:	8082                	ret
    mycpu()->intena = old;
    80000bc2:	4f1000ef          	jal	800018b2 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bc6:	8085                	srli	s1,s1,0x1
    80000bc8:	8885                	andi	s1,s1,1
    80000bca:	dd64                	sw	s1,124(a0)
    80000bcc:	b7cd                	j	80000bae <push_off+0x20>

0000000080000bce <acquire>:
{
    80000bce:	1101                	addi	sp,sp,-32
    80000bd0:	ec06                	sd	ra,24(sp)
    80000bd2:	e822                	sd	s0,16(sp)
    80000bd4:	e426                	sd	s1,8(sp)
    80000bd6:	1000                	addi	s0,sp,32
    80000bd8:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bda:	fb5ff0ef          	jal	80000b8e <push_off>
  if(holding(lk))
    80000bde:	8526                	mv	a0,s1
    80000be0:	f85ff0ef          	jal	80000b64 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000be4:	4705                	li	a4,1
  if(holding(lk))
    80000be6:	e105                	bnez	a0,80000c06 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000be8:	87ba                	mv	a5,a4
    80000bea:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bee:	2781                	sext.w	a5,a5
    80000bf0:	ffe5                	bnez	a5,80000be8 <acquire+0x1a>
  __sync_synchronize();
    80000bf2:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000bf6:	4bd000ef          	jal	800018b2 <mycpu>
    80000bfa:	e888                	sd	a0,16(s1)
}
    80000bfc:	60e2                	ld	ra,24(sp)
    80000bfe:	6442                	ld	s0,16(sp)
    80000c00:	64a2                	ld	s1,8(sp)
    80000c02:	6105                	addi	sp,sp,32
    80000c04:	8082                	ret
    panic("acquire");
    80000c06:	00006517          	auipc	a0,0x6
    80000c0a:	44250513          	addi	a0,a0,1090 # 80007048 <etext+0x48>
    80000c0e:	bd3ff0ef          	jal	800007e0 <panic>

0000000080000c12 <pop_off>:

void
pop_off(void)
{
    80000c12:	1141                	addi	sp,sp,-16
    80000c14:	e406                	sd	ra,8(sp)
    80000c16:	e022                	sd	s0,0(sp)
    80000c18:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c1a:	499000ef          	jal	800018b2 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c1e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c22:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c24:	e78d                	bnez	a5,80000c4e <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c26:	5d3c                	lw	a5,120(a0)
    80000c28:	02f05963          	blez	a5,80000c5a <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80000c2c:	37fd                	addiw	a5,a5,-1
    80000c2e:	0007871b          	sext.w	a4,a5
    80000c32:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c34:	eb09                	bnez	a4,80000c46 <pop_off+0x34>
    80000c36:	5d7c                	lw	a5,124(a0)
    80000c38:	c799                	beqz	a5,80000c46 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c3a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c3e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c42:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c46:	60a2                	ld	ra,8(sp)
    80000c48:	6402                	ld	s0,0(sp)
    80000c4a:	0141                	addi	sp,sp,16
    80000c4c:	8082                	ret
    panic("pop_off - interruptible");
    80000c4e:	00006517          	auipc	a0,0x6
    80000c52:	40250513          	addi	a0,a0,1026 # 80007050 <etext+0x50>
    80000c56:	b8bff0ef          	jal	800007e0 <panic>
    panic("pop_off");
    80000c5a:	00006517          	auipc	a0,0x6
    80000c5e:	40e50513          	addi	a0,a0,1038 # 80007068 <etext+0x68>
    80000c62:	b7fff0ef          	jal	800007e0 <panic>

0000000080000c66 <release>:
{
    80000c66:	1101                	addi	sp,sp,-32
    80000c68:	ec06                	sd	ra,24(sp)
    80000c6a:	e822                	sd	s0,16(sp)
    80000c6c:	e426                	sd	s1,8(sp)
    80000c6e:	1000                	addi	s0,sp,32
    80000c70:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c72:	ef3ff0ef          	jal	80000b64 <holding>
    80000c76:	c105                	beqz	a0,80000c96 <release+0x30>
  lk->cpu = 0;
    80000c78:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000c7c:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80000c80:	0310000f          	fence	rw,w
    80000c84:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000c88:	f8bff0ef          	jal	80000c12 <pop_off>
}
    80000c8c:	60e2                	ld	ra,24(sp)
    80000c8e:	6442                	ld	s0,16(sp)
    80000c90:	64a2                	ld	s1,8(sp)
    80000c92:	6105                	addi	sp,sp,32
    80000c94:	8082                	ret
    panic("release");
    80000c96:	00006517          	auipc	a0,0x6
    80000c9a:	3da50513          	addi	a0,a0,986 # 80007070 <etext+0x70>
    80000c9e:	b43ff0ef          	jal	800007e0 <panic>

0000000080000ca2 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000ca2:	1141                	addi	sp,sp,-16
    80000ca4:	e422                	sd	s0,8(sp)
    80000ca6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000ca8:	ca19                	beqz	a2,80000cbe <memset+0x1c>
    80000caa:	87aa                	mv	a5,a0
    80000cac:	1602                	slli	a2,a2,0x20
    80000cae:	9201                	srli	a2,a2,0x20
    80000cb0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cb4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cb8:	0785                	addi	a5,a5,1
    80000cba:	fee79de3          	bne	a5,a4,80000cb4 <memset+0x12>
  }
  return dst;
}
    80000cbe:	6422                	ld	s0,8(sp)
    80000cc0:	0141                	addi	sp,sp,16
    80000cc2:	8082                	ret

0000000080000cc4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cc4:	1141                	addi	sp,sp,-16
    80000cc6:	e422                	sd	s0,8(sp)
    80000cc8:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cca:	ca05                	beqz	a2,80000cfa <memcmp+0x36>
    80000ccc:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000cd0:	1682                	slli	a3,a3,0x20
    80000cd2:	9281                	srli	a3,a3,0x20
    80000cd4:	0685                	addi	a3,a3,1
    80000cd6:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000cd8:	00054783          	lbu	a5,0(a0)
    80000cdc:	0005c703          	lbu	a4,0(a1)
    80000ce0:	00e79863          	bne	a5,a4,80000cf0 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000ce4:	0505                	addi	a0,a0,1
    80000ce6:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000ce8:	fed518e3          	bne	a0,a3,80000cd8 <memcmp+0x14>
  }

  return 0;
    80000cec:	4501                	li	a0,0
    80000cee:	a019                	j	80000cf4 <memcmp+0x30>
      return *s1 - *s2;
    80000cf0:	40e7853b          	subw	a0,a5,a4
}
    80000cf4:	6422                	ld	s0,8(sp)
    80000cf6:	0141                	addi	sp,sp,16
    80000cf8:	8082                	ret
  return 0;
    80000cfa:	4501                	li	a0,0
    80000cfc:	bfe5                	j	80000cf4 <memcmp+0x30>

0000000080000cfe <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000cfe:	1141                	addi	sp,sp,-16
    80000d00:	e422                	sd	s0,8(sp)
    80000d02:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d04:	c205                	beqz	a2,80000d24 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d06:	02a5e263          	bltu	a1,a0,80000d2a <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d0a:	1602                	slli	a2,a2,0x20
    80000d0c:	9201                	srli	a2,a2,0x20
    80000d0e:	00c587b3          	add	a5,a1,a2
{
    80000d12:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d14:	0585                	addi	a1,a1,1
    80000d16:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdbb19>
    80000d18:	fff5c683          	lbu	a3,-1(a1)
    80000d1c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d20:	feb79ae3          	bne	a5,a1,80000d14 <memmove+0x16>

  return dst;
}
    80000d24:	6422                	ld	s0,8(sp)
    80000d26:	0141                	addi	sp,sp,16
    80000d28:	8082                	ret
  if(s < d && s + n > d){
    80000d2a:	02061693          	slli	a3,a2,0x20
    80000d2e:	9281                	srli	a3,a3,0x20
    80000d30:	00d58733          	add	a4,a1,a3
    80000d34:	fce57be3          	bgeu	a0,a4,80000d0a <memmove+0xc>
    d += n;
    80000d38:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d3a:	fff6079b          	addiw	a5,a2,-1
    80000d3e:	1782                	slli	a5,a5,0x20
    80000d40:	9381                	srli	a5,a5,0x20
    80000d42:	fff7c793          	not	a5,a5
    80000d46:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d48:	177d                	addi	a4,a4,-1
    80000d4a:	16fd                	addi	a3,a3,-1
    80000d4c:	00074603          	lbu	a2,0(a4)
    80000d50:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d54:	fef71ae3          	bne	a4,a5,80000d48 <memmove+0x4a>
    80000d58:	b7f1                	j	80000d24 <memmove+0x26>

0000000080000d5a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d5a:	1141                	addi	sp,sp,-16
    80000d5c:	e406                	sd	ra,8(sp)
    80000d5e:	e022                	sd	s0,0(sp)
    80000d60:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d62:	f9dff0ef          	jal	80000cfe <memmove>
}
    80000d66:	60a2                	ld	ra,8(sp)
    80000d68:	6402                	ld	s0,0(sp)
    80000d6a:	0141                	addi	sp,sp,16
    80000d6c:	8082                	ret

0000000080000d6e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d6e:	1141                	addi	sp,sp,-16
    80000d70:	e422                	sd	s0,8(sp)
    80000d72:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000d74:	ce11                	beqz	a2,80000d90 <strncmp+0x22>
    80000d76:	00054783          	lbu	a5,0(a0)
    80000d7a:	cf89                	beqz	a5,80000d94 <strncmp+0x26>
    80000d7c:	0005c703          	lbu	a4,0(a1)
    80000d80:	00f71a63          	bne	a4,a5,80000d94 <strncmp+0x26>
    n--, p++, q++;
    80000d84:	367d                	addiw	a2,a2,-1
    80000d86:	0505                	addi	a0,a0,1
    80000d88:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000d8a:	f675                	bnez	a2,80000d76 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000d8c:	4501                	li	a0,0
    80000d8e:	a801                	j	80000d9e <strncmp+0x30>
    80000d90:	4501                	li	a0,0
    80000d92:	a031                	j	80000d9e <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000d94:	00054503          	lbu	a0,0(a0)
    80000d98:	0005c783          	lbu	a5,0(a1)
    80000d9c:	9d1d                	subw	a0,a0,a5
}
    80000d9e:	6422                	ld	s0,8(sp)
    80000da0:	0141                	addi	sp,sp,16
    80000da2:	8082                	ret

0000000080000da4 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000da4:	1141                	addi	sp,sp,-16
    80000da6:	e422                	sd	s0,8(sp)
    80000da8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000daa:	87aa                	mv	a5,a0
    80000dac:	86b2                	mv	a3,a2
    80000dae:	367d                	addiw	a2,a2,-1
    80000db0:	02d05563          	blez	a3,80000dda <strncpy+0x36>
    80000db4:	0785                	addi	a5,a5,1
    80000db6:	0005c703          	lbu	a4,0(a1)
    80000dba:	fee78fa3          	sb	a4,-1(a5)
    80000dbe:	0585                	addi	a1,a1,1
    80000dc0:	f775                	bnez	a4,80000dac <strncpy+0x8>
    ;
  while(n-- > 0)
    80000dc2:	873e                	mv	a4,a5
    80000dc4:	9fb5                	addw	a5,a5,a3
    80000dc6:	37fd                	addiw	a5,a5,-1
    80000dc8:	00c05963          	blez	a2,80000dda <strncpy+0x36>
    *s++ = 0;
    80000dcc:	0705                	addi	a4,a4,1
    80000dce:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000dd2:	40e786bb          	subw	a3,a5,a4
    80000dd6:	fed04be3          	bgtz	a3,80000dcc <strncpy+0x28>
  return os;
}
    80000dda:	6422                	ld	s0,8(sp)
    80000ddc:	0141                	addi	sp,sp,16
    80000dde:	8082                	ret

0000000080000de0 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000de0:	1141                	addi	sp,sp,-16
    80000de2:	e422                	sd	s0,8(sp)
    80000de4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000de6:	02c05363          	blez	a2,80000e0c <safestrcpy+0x2c>
    80000dea:	fff6069b          	addiw	a3,a2,-1
    80000dee:	1682                	slli	a3,a3,0x20
    80000df0:	9281                	srli	a3,a3,0x20
    80000df2:	96ae                	add	a3,a3,a1
    80000df4:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000df6:	00d58963          	beq	a1,a3,80000e08 <safestrcpy+0x28>
    80000dfa:	0585                	addi	a1,a1,1
    80000dfc:	0785                	addi	a5,a5,1
    80000dfe:	fff5c703          	lbu	a4,-1(a1)
    80000e02:	fee78fa3          	sb	a4,-1(a5)
    80000e06:	fb65                	bnez	a4,80000df6 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e08:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e0c:	6422                	ld	s0,8(sp)
    80000e0e:	0141                	addi	sp,sp,16
    80000e10:	8082                	ret

0000000080000e12 <strlen>:

int
strlen(const char *s)
{
    80000e12:	1141                	addi	sp,sp,-16
    80000e14:	e422                	sd	s0,8(sp)
    80000e16:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e18:	00054783          	lbu	a5,0(a0)
    80000e1c:	cf91                	beqz	a5,80000e38 <strlen+0x26>
    80000e1e:	0505                	addi	a0,a0,1
    80000e20:	87aa                	mv	a5,a0
    80000e22:	86be                	mv	a3,a5
    80000e24:	0785                	addi	a5,a5,1
    80000e26:	fff7c703          	lbu	a4,-1(a5)
    80000e2a:	ff65                	bnez	a4,80000e22 <strlen+0x10>
    80000e2c:	40a6853b          	subw	a0,a3,a0
    80000e30:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000e32:	6422                	ld	s0,8(sp)
    80000e34:	0141                	addi	sp,sp,16
    80000e36:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e38:	4501                	li	a0,0
    80000e3a:	bfe5                	j	80000e32 <strlen+0x20>

0000000080000e3c <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e3c:	1141                	addi	sp,sp,-16
    80000e3e:	e406                	sd	ra,8(sp)
    80000e40:	e022                	sd	s0,0(sp)
    80000e42:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e44:	25f000ef          	jal	800018a2 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e48:	00009717          	auipc	a4,0x9
    80000e4c:	37870713          	addi	a4,a4,888 # 8000a1c0 <started>
  if(cpuid() == 0){
    80000e50:	c51d                	beqz	a0,80000e7e <main+0x42>
    while(started == 0)
    80000e52:	431c                	lw	a5,0(a4)
    80000e54:	2781                	sext.w	a5,a5
    80000e56:	dff5                	beqz	a5,80000e52 <main+0x16>
      ;
    __sync_synchronize();
    80000e58:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80000e5c:	247000ef          	jal	800018a2 <cpuid>
    80000e60:	85aa                	mv	a1,a0
    80000e62:	00006517          	auipc	a0,0x6
    80000e66:	23650513          	addi	a0,a0,566 # 80007098 <etext+0x98>
    80000e6a:	e90ff0ef          	jal	800004fa <printf>
    kvminithart();    // turn on paging
    80000e6e:	080000ef          	jal	80000eee <kvminithart>
    trapinithart();   // install kernel trap vector
    80000e72:	576010ef          	jal	800023e8 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e76:	582040ef          	jal	800053f8 <plicinithart>
  }

  scheduler();        
    80000e7a:	6b5000ef          	jal	80001d2e <scheduler>
    consoleinit();
    80000e7e:	da6ff0ef          	jal	80000424 <consoleinit>
    printfinit();
    80000e82:	99bff0ef          	jal	8000081c <printfinit>
    printf("\n");
    80000e86:	00006517          	auipc	a0,0x6
    80000e8a:	1f250513          	addi	a0,a0,498 # 80007078 <etext+0x78>
    80000e8e:	e6cff0ef          	jal	800004fa <printf>
    printf("xv6 kernel is booting\n");
    80000e92:	00006517          	auipc	a0,0x6
    80000e96:	1ee50513          	addi	a0,a0,494 # 80007080 <etext+0x80>
    80000e9a:	e60ff0ef          	jal	800004fa <printf>
    printf("\n");
    80000e9e:	00006517          	auipc	a0,0x6
    80000ea2:	1da50513          	addi	a0,a0,474 # 80007078 <etext+0x78>
    80000ea6:	e54ff0ef          	jal	800004fa <printf>
    kinit();         // physical page allocator
    80000eaa:	c21ff0ef          	jal	80000aca <kinit>
    kvminit();       // create kernel page table
    80000eae:	2ca000ef          	jal	80001178 <kvminit>
    kvminithart();   // turn on paging
    80000eb2:	03c000ef          	jal	80000eee <kvminithart>
    procinit();      // process table
    80000eb6:	137000ef          	jal	800017ec <procinit>
    trapinit();      // trap vectors
    80000eba:	50a010ef          	jal	800023c4 <trapinit>
    trapinithart();  // install kernel trap vector
    80000ebe:	52a010ef          	jal	800023e8 <trapinithart>
    plicinit();      // set up interrupt controller
    80000ec2:	51c040ef          	jal	800053de <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000ec6:	532040ef          	jal	800053f8 <plicinithart>
    binit();         // buffer cache
    80000eca:	3fd010ef          	jal	80002ac6 <binit>
    iinit();         // inode table
    80000ece:	182020ef          	jal	80003050 <iinit>
    fileinit();      // file table
    80000ed2:	074030ef          	jal	80003f46 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000ed6:	612040ef          	jal	800054e8 <virtio_disk_init>
    userinit();      // first user process
    80000eda:	4bb000ef          	jal	80001b94 <userinit>
    __sync_synchronize();
    80000ede:	0330000f          	fence	rw,rw
    started = 1;
    80000ee2:	4785                	li	a5,1
    80000ee4:	00009717          	auipc	a4,0x9
    80000ee8:	2cf72e23          	sw	a5,732(a4) # 8000a1c0 <started>
    80000eec:	b779                	j	80000e7a <main+0x3e>

0000000080000eee <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000eee:	1141                	addi	sp,sp,-16
    80000ef0:	e422                	sd	s0,8(sp)
    80000ef2:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000ef4:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000ef8:	00009797          	auipc	a5,0x9
    80000efc:	2d07b783          	ld	a5,720(a5) # 8000a1c8 <kernel_pagetable>
    80000f00:	83b1                	srli	a5,a5,0xc
    80000f02:	577d                	li	a4,-1
    80000f04:	177e                	slli	a4,a4,0x3f
    80000f06:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f08:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000f0c:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f10:	6422                	ld	s0,8(sp)
    80000f12:	0141                	addi	sp,sp,16
    80000f14:	8082                	ret

0000000080000f16 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f16:	7139                	addi	sp,sp,-64
    80000f18:	fc06                	sd	ra,56(sp)
    80000f1a:	f822                	sd	s0,48(sp)
    80000f1c:	f426                	sd	s1,40(sp)
    80000f1e:	f04a                	sd	s2,32(sp)
    80000f20:	ec4e                	sd	s3,24(sp)
    80000f22:	e852                	sd	s4,16(sp)
    80000f24:	e456                	sd	s5,8(sp)
    80000f26:	e05a                	sd	s6,0(sp)
    80000f28:	0080                	addi	s0,sp,64
    80000f2a:	84aa                	mv	s1,a0
    80000f2c:	89ae                	mv	s3,a1
    80000f2e:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000f30:	57fd                	li	a5,-1
    80000f32:	83e9                	srli	a5,a5,0x1a
    80000f34:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000f36:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000f38:	02b7fc63          	bgeu	a5,a1,80000f70 <walk+0x5a>
    panic("walk");
    80000f3c:	00006517          	auipc	a0,0x6
    80000f40:	17450513          	addi	a0,a0,372 # 800070b0 <etext+0xb0>
    80000f44:	89dff0ef          	jal	800007e0 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000f48:	060a8263          	beqz	s5,80000fac <walk+0x96>
    80000f4c:	bb3ff0ef          	jal	80000afe <kalloc>
    80000f50:	84aa                	mv	s1,a0
    80000f52:	c139                	beqz	a0,80000f98 <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000f54:	6605                	lui	a2,0x1
    80000f56:	4581                	li	a1,0
    80000f58:	d4bff0ef          	jal	80000ca2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000f5c:	00c4d793          	srli	a5,s1,0xc
    80000f60:	07aa                	slli	a5,a5,0xa
    80000f62:	0017e793          	ori	a5,a5,1
    80000f66:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000f6a:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdbb0f>
    80000f6c:	036a0063          	beq	s4,s6,80000f8c <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80000f70:	0149d933          	srl	s2,s3,s4
    80000f74:	1ff97913          	andi	s2,s2,511
    80000f78:	090e                	slli	s2,s2,0x3
    80000f7a:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000f7c:	00093483          	ld	s1,0(s2)
    80000f80:	0014f793          	andi	a5,s1,1
    80000f84:	d3f1                	beqz	a5,80000f48 <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000f86:	80a9                	srli	s1,s1,0xa
    80000f88:	04b2                	slli	s1,s1,0xc
    80000f8a:	b7c5                	j	80000f6a <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80000f8c:	00c9d513          	srli	a0,s3,0xc
    80000f90:	1ff57513          	andi	a0,a0,511
    80000f94:	050e                	slli	a0,a0,0x3
    80000f96:	9526                	add	a0,a0,s1
}
    80000f98:	70e2                	ld	ra,56(sp)
    80000f9a:	7442                	ld	s0,48(sp)
    80000f9c:	74a2                	ld	s1,40(sp)
    80000f9e:	7902                	ld	s2,32(sp)
    80000fa0:	69e2                	ld	s3,24(sp)
    80000fa2:	6a42                	ld	s4,16(sp)
    80000fa4:	6aa2                	ld	s5,8(sp)
    80000fa6:	6b02                	ld	s6,0(sp)
    80000fa8:	6121                	addi	sp,sp,64
    80000faa:	8082                	ret
        return 0;
    80000fac:	4501                	li	a0,0
    80000fae:	b7ed                	j	80000f98 <walk+0x82>

0000000080000fb0 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80000fb0:	57fd                	li	a5,-1
    80000fb2:	83e9                	srli	a5,a5,0x1a
    80000fb4:	00b7f463          	bgeu	a5,a1,80000fbc <walkaddr+0xc>
    return 0;
    80000fb8:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000fba:	8082                	ret
{
    80000fbc:	1141                	addi	sp,sp,-16
    80000fbe:	e406                	sd	ra,8(sp)
    80000fc0:	e022                	sd	s0,0(sp)
    80000fc2:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000fc4:	4601                	li	a2,0
    80000fc6:	f51ff0ef          	jal	80000f16 <walk>
  if(pte == 0)
    80000fca:	c105                	beqz	a0,80000fea <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    80000fcc:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000fce:	0117f693          	andi	a3,a5,17
    80000fd2:	4745                	li	a4,17
    return 0;
    80000fd4:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000fd6:	00e68663          	beq	a3,a4,80000fe2 <walkaddr+0x32>
}
    80000fda:	60a2                	ld	ra,8(sp)
    80000fdc:	6402                	ld	s0,0(sp)
    80000fde:	0141                	addi	sp,sp,16
    80000fe0:	8082                	ret
  pa = PTE2PA(*pte);
    80000fe2:	83a9                	srli	a5,a5,0xa
    80000fe4:	00c79513          	slli	a0,a5,0xc
  return pa;
    80000fe8:	bfcd                	j	80000fda <walkaddr+0x2a>
    return 0;
    80000fea:	4501                	li	a0,0
    80000fec:	b7fd                	j	80000fda <walkaddr+0x2a>

0000000080000fee <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80000fee:	715d                	addi	sp,sp,-80
    80000ff0:	e486                	sd	ra,72(sp)
    80000ff2:	e0a2                	sd	s0,64(sp)
    80000ff4:	fc26                	sd	s1,56(sp)
    80000ff6:	f84a                	sd	s2,48(sp)
    80000ff8:	f44e                	sd	s3,40(sp)
    80000ffa:	f052                	sd	s4,32(sp)
    80000ffc:	ec56                	sd	s5,24(sp)
    80000ffe:	e85a                	sd	s6,16(sp)
    80001000:	e45e                	sd	s7,8(sp)
    80001002:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001004:	03459793          	slli	a5,a1,0x34
    80001008:	e7a9                	bnez	a5,80001052 <mappages+0x64>
    8000100a:	8aaa                	mv	s5,a0
    8000100c:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    8000100e:	03461793          	slli	a5,a2,0x34
    80001012:	e7b1                	bnez	a5,8000105e <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    80001014:	ca39                	beqz	a2,8000106a <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    80001016:	77fd                	lui	a5,0xfffff
    80001018:	963e                	add	a2,a2,a5
    8000101a:	00b609b3          	add	s3,a2,a1
  a = va;
    8000101e:	892e                	mv	s2,a1
    80001020:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001024:	6b85                	lui	s7,0x1
    80001026:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    8000102a:	4605                	li	a2,1
    8000102c:	85ca                	mv	a1,s2
    8000102e:	8556                	mv	a0,s5
    80001030:	ee7ff0ef          	jal	80000f16 <walk>
    80001034:	c539                	beqz	a0,80001082 <mappages+0x94>
    if(*pte & PTE_V)
    80001036:	611c                	ld	a5,0(a0)
    80001038:	8b85                	andi	a5,a5,1
    8000103a:	ef95                	bnez	a5,80001076 <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000103c:	80b1                	srli	s1,s1,0xc
    8000103e:	04aa                	slli	s1,s1,0xa
    80001040:	0164e4b3          	or	s1,s1,s6
    80001044:	0014e493          	ori	s1,s1,1
    80001048:	e104                	sd	s1,0(a0)
    if(a == last)
    8000104a:	05390863          	beq	s2,s3,8000109a <mappages+0xac>
    a += PGSIZE;
    8000104e:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001050:	bfd9                	j	80001026 <mappages+0x38>
    panic("mappages: va not aligned");
    80001052:	00006517          	auipc	a0,0x6
    80001056:	06650513          	addi	a0,a0,102 # 800070b8 <etext+0xb8>
    8000105a:	f86ff0ef          	jal	800007e0 <panic>
    panic("mappages: size not aligned");
    8000105e:	00006517          	auipc	a0,0x6
    80001062:	07a50513          	addi	a0,a0,122 # 800070d8 <etext+0xd8>
    80001066:	f7aff0ef          	jal	800007e0 <panic>
    panic("mappages: size");
    8000106a:	00006517          	auipc	a0,0x6
    8000106e:	08e50513          	addi	a0,a0,142 # 800070f8 <etext+0xf8>
    80001072:	f6eff0ef          	jal	800007e0 <panic>
      panic("mappages: remap");
    80001076:	00006517          	auipc	a0,0x6
    8000107a:	09250513          	addi	a0,a0,146 # 80007108 <etext+0x108>
    8000107e:	f62ff0ef          	jal	800007e0 <panic>
      return -1;
    80001082:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001084:	60a6                	ld	ra,72(sp)
    80001086:	6406                	ld	s0,64(sp)
    80001088:	74e2                	ld	s1,56(sp)
    8000108a:	7942                	ld	s2,48(sp)
    8000108c:	79a2                	ld	s3,40(sp)
    8000108e:	7a02                	ld	s4,32(sp)
    80001090:	6ae2                	ld	s5,24(sp)
    80001092:	6b42                	ld	s6,16(sp)
    80001094:	6ba2                	ld	s7,8(sp)
    80001096:	6161                	addi	sp,sp,80
    80001098:	8082                	ret
  return 0;
    8000109a:	4501                	li	a0,0
    8000109c:	b7e5                	j	80001084 <mappages+0x96>

000000008000109e <kvmmap>:
{
    8000109e:	1141                	addi	sp,sp,-16
    800010a0:	e406                	sd	ra,8(sp)
    800010a2:	e022                	sd	s0,0(sp)
    800010a4:	0800                	addi	s0,sp,16
    800010a6:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800010a8:	86b2                	mv	a3,a2
    800010aa:	863e                	mv	a2,a5
    800010ac:	f43ff0ef          	jal	80000fee <mappages>
    800010b0:	e509                	bnez	a0,800010ba <kvmmap+0x1c>
}
    800010b2:	60a2                	ld	ra,8(sp)
    800010b4:	6402                	ld	s0,0(sp)
    800010b6:	0141                	addi	sp,sp,16
    800010b8:	8082                	ret
    panic("kvmmap");
    800010ba:	00006517          	auipc	a0,0x6
    800010be:	05e50513          	addi	a0,a0,94 # 80007118 <etext+0x118>
    800010c2:	f1eff0ef          	jal	800007e0 <panic>

00000000800010c6 <kvmmake>:
{
    800010c6:	1101                	addi	sp,sp,-32
    800010c8:	ec06                	sd	ra,24(sp)
    800010ca:	e822                	sd	s0,16(sp)
    800010cc:	e426                	sd	s1,8(sp)
    800010ce:	e04a                	sd	s2,0(sp)
    800010d0:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800010d2:	a2dff0ef          	jal	80000afe <kalloc>
    800010d6:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800010d8:	6605                	lui	a2,0x1
    800010da:	4581                	li	a1,0
    800010dc:	bc7ff0ef          	jal	80000ca2 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800010e0:	4719                	li	a4,6
    800010e2:	6685                	lui	a3,0x1
    800010e4:	10000637          	lui	a2,0x10000
    800010e8:	100005b7          	lui	a1,0x10000
    800010ec:	8526                	mv	a0,s1
    800010ee:	fb1ff0ef          	jal	8000109e <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800010f2:	4719                	li	a4,6
    800010f4:	6685                	lui	a3,0x1
    800010f6:	10001637          	lui	a2,0x10001
    800010fa:	100015b7          	lui	a1,0x10001
    800010fe:	8526                	mv	a0,s1
    80001100:	f9fff0ef          	jal	8000109e <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    80001104:	4719                	li	a4,6
    80001106:	040006b7          	lui	a3,0x4000
    8000110a:	0c000637          	lui	a2,0xc000
    8000110e:	0c0005b7          	lui	a1,0xc000
    80001112:	8526                	mv	a0,s1
    80001114:	f8bff0ef          	jal	8000109e <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001118:	00006917          	auipc	s2,0x6
    8000111c:	ee890913          	addi	s2,s2,-280 # 80007000 <etext>
    80001120:	4729                	li	a4,10
    80001122:	80006697          	auipc	a3,0x80006
    80001126:	ede68693          	addi	a3,a3,-290 # 7000 <_entry-0x7fff9000>
    8000112a:	4605                	li	a2,1
    8000112c:	067e                	slli	a2,a2,0x1f
    8000112e:	85b2                	mv	a1,a2
    80001130:	8526                	mv	a0,s1
    80001132:	f6dff0ef          	jal	8000109e <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001136:	46c5                	li	a3,17
    80001138:	06ee                	slli	a3,a3,0x1b
    8000113a:	4719                	li	a4,6
    8000113c:	412686b3          	sub	a3,a3,s2
    80001140:	864a                	mv	a2,s2
    80001142:	85ca                	mv	a1,s2
    80001144:	8526                	mv	a0,s1
    80001146:	f59ff0ef          	jal	8000109e <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000114a:	4729                	li	a4,10
    8000114c:	6685                	lui	a3,0x1
    8000114e:	00005617          	auipc	a2,0x5
    80001152:	eb260613          	addi	a2,a2,-334 # 80006000 <_trampoline>
    80001156:	040005b7          	lui	a1,0x4000
    8000115a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000115c:	05b2                	slli	a1,a1,0xc
    8000115e:	8526                	mv	a0,s1
    80001160:	f3fff0ef          	jal	8000109e <kvmmap>
  proc_mapstacks(kpgtbl);
    80001164:	8526                	mv	a0,s1
    80001166:	5ee000ef          	jal	80001754 <proc_mapstacks>
}
    8000116a:	8526                	mv	a0,s1
    8000116c:	60e2                	ld	ra,24(sp)
    8000116e:	6442                	ld	s0,16(sp)
    80001170:	64a2                	ld	s1,8(sp)
    80001172:	6902                	ld	s2,0(sp)
    80001174:	6105                	addi	sp,sp,32
    80001176:	8082                	ret

0000000080001178 <kvminit>:
{
    80001178:	1141                	addi	sp,sp,-16
    8000117a:	e406                	sd	ra,8(sp)
    8000117c:	e022                	sd	s0,0(sp)
    8000117e:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001180:	f47ff0ef          	jal	800010c6 <kvmmake>
    80001184:	00009797          	auipc	a5,0x9
    80001188:	04a7b223          	sd	a0,68(a5) # 8000a1c8 <kernel_pagetable>
}
    8000118c:	60a2                	ld	ra,8(sp)
    8000118e:	6402                	ld	s0,0(sp)
    80001190:	0141                	addi	sp,sp,16
    80001192:	8082                	ret

0000000080001194 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001194:	1101                	addi	sp,sp,-32
    80001196:	ec06                	sd	ra,24(sp)
    80001198:	e822                	sd	s0,16(sp)
    8000119a:	e426                	sd	s1,8(sp)
    8000119c:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000119e:	961ff0ef          	jal	80000afe <kalloc>
    800011a2:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800011a4:	c509                	beqz	a0,800011ae <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800011a6:	6605                	lui	a2,0x1
    800011a8:	4581                	li	a1,0
    800011aa:	af9ff0ef          	jal	80000ca2 <memset>
  return pagetable;
}
    800011ae:	8526                	mv	a0,s1
    800011b0:	60e2                	ld	ra,24(sp)
    800011b2:	6442                	ld	s0,16(sp)
    800011b4:	64a2                	ld	s1,8(sp)
    800011b6:	6105                	addi	sp,sp,32
    800011b8:	8082                	ret

00000000800011ba <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800011ba:	7139                	addi	sp,sp,-64
    800011bc:	fc06                	sd	ra,56(sp)
    800011be:	f822                	sd	s0,48(sp)
    800011c0:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800011c2:	03459793          	slli	a5,a1,0x34
    800011c6:	e38d                	bnez	a5,800011e8 <uvmunmap+0x2e>
    800011c8:	f04a                	sd	s2,32(sp)
    800011ca:	ec4e                	sd	s3,24(sp)
    800011cc:	e852                	sd	s4,16(sp)
    800011ce:	e456                	sd	s5,8(sp)
    800011d0:	e05a                	sd	s6,0(sp)
    800011d2:	8a2a                	mv	s4,a0
    800011d4:	892e                	mv	s2,a1
    800011d6:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800011d8:	0632                	slli	a2,a2,0xc
    800011da:	00b609b3          	add	s3,a2,a1
    800011de:	6b05                	lui	s6,0x1
    800011e0:	0535f963          	bgeu	a1,s3,80001232 <uvmunmap+0x78>
    800011e4:	f426                	sd	s1,40(sp)
    800011e6:	a015                	j	8000120a <uvmunmap+0x50>
    800011e8:	f426                	sd	s1,40(sp)
    800011ea:	f04a                	sd	s2,32(sp)
    800011ec:	ec4e                	sd	s3,24(sp)
    800011ee:	e852                	sd	s4,16(sp)
    800011f0:	e456                	sd	s5,8(sp)
    800011f2:	e05a                	sd	s6,0(sp)
    panic("uvmunmap: not aligned");
    800011f4:	00006517          	auipc	a0,0x6
    800011f8:	f2c50513          	addi	a0,a0,-212 # 80007120 <etext+0x120>
    800011fc:	de4ff0ef          	jal	800007e0 <panic>
      continue;
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    80001200:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001204:	995a                	add	s2,s2,s6
    80001206:	03397563          	bgeu	s2,s3,80001230 <uvmunmap+0x76>
    if((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    8000120a:	4601                	li	a2,0
    8000120c:	85ca                	mv	a1,s2
    8000120e:	8552                	mv	a0,s4
    80001210:	d07ff0ef          	jal	80000f16 <walk>
    80001214:	84aa                	mv	s1,a0
    80001216:	d57d                	beqz	a0,80001204 <uvmunmap+0x4a>
    if((*pte & PTE_V) == 0)  // has physical page been allocated?
    80001218:	611c                	ld	a5,0(a0)
    8000121a:	0017f713          	andi	a4,a5,1
    8000121e:	d37d                	beqz	a4,80001204 <uvmunmap+0x4a>
    if(do_free){
    80001220:	fe0a80e3          	beqz	s5,80001200 <uvmunmap+0x46>
      uint64 pa = PTE2PA(*pte);
    80001224:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    80001226:	00c79513          	slli	a0,a5,0xc
    8000122a:	ff2ff0ef          	jal	80000a1c <kfree>
    8000122e:	bfc9                	j	80001200 <uvmunmap+0x46>
    80001230:	74a2                	ld	s1,40(sp)
    80001232:	7902                	ld	s2,32(sp)
    80001234:	69e2                	ld	s3,24(sp)
    80001236:	6a42                	ld	s4,16(sp)
    80001238:	6aa2                	ld	s5,8(sp)
    8000123a:	6b02                	ld	s6,0(sp)
  }
}
    8000123c:	70e2                	ld	ra,56(sp)
    8000123e:	7442                	ld	s0,48(sp)
    80001240:	6121                	addi	sp,sp,64
    80001242:	8082                	ret

0000000080001244 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001244:	1101                	addi	sp,sp,-32
    80001246:	ec06                	sd	ra,24(sp)
    80001248:	e822                	sd	s0,16(sp)
    8000124a:	e426                	sd	s1,8(sp)
    8000124c:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000124e:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001250:	00b67d63          	bgeu	a2,a1,8000126a <uvmdealloc+0x26>
    80001254:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001256:	6785                	lui	a5,0x1
    80001258:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000125a:	00f60733          	add	a4,a2,a5
    8000125e:	76fd                	lui	a3,0xfffff
    80001260:	8f75                	and	a4,a4,a3
    80001262:	97ae                	add	a5,a5,a1
    80001264:	8ff5                	and	a5,a5,a3
    80001266:	00f76863          	bltu	a4,a5,80001276 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000126a:	8526                	mv	a0,s1
    8000126c:	60e2                	ld	ra,24(sp)
    8000126e:	6442                	ld	s0,16(sp)
    80001270:	64a2                	ld	s1,8(sp)
    80001272:	6105                	addi	sp,sp,32
    80001274:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001276:	8f99                	sub	a5,a5,a4
    80001278:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000127a:	4685                	li	a3,1
    8000127c:	0007861b          	sext.w	a2,a5
    80001280:	85ba                	mv	a1,a4
    80001282:	f39ff0ef          	jal	800011ba <uvmunmap>
    80001286:	b7d5                	j	8000126a <uvmdealloc+0x26>

0000000080001288 <uvmalloc>:
  if(newsz < oldsz)
    80001288:	08b66f63          	bltu	a2,a1,80001326 <uvmalloc+0x9e>
{
    8000128c:	7139                	addi	sp,sp,-64
    8000128e:	fc06                	sd	ra,56(sp)
    80001290:	f822                	sd	s0,48(sp)
    80001292:	ec4e                	sd	s3,24(sp)
    80001294:	e852                	sd	s4,16(sp)
    80001296:	e456                	sd	s5,8(sp)
    80001298:	0080                	addi	s0,sp,64
    8000129a:	8aaa                	mv	s5,a0
    8000129c:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000129e:	6785                	lui	a5,0x1
    800012a0:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800012a2:	95be                	add	a1,a1,a5
    800012a4:	77fd                	lui	a5,0xfffff
    800012a6:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    800012aa:	08c9f063          	bgeu	s3,a2,8000132a <uvmalloc+0xa2>
    800012ae:	f426                	sd	s1,40(sp)
    800012b0:	f04a                	sd	s2,32(sp)
    800012b2:	e05a                	sd	s6,0(sp)
    800012b4:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800012b6:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    800012ba:	845ff0ef          	jal	80000afe <kalloc>
    800012be:	84aa                	mv	s1,a0
    if(mem == 0){
    800012c0:	c515                	beqz	a0,800012ec <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    800012c2:	6605                	lui	a2,0x1
    800012c4:	4581                	li	a1,0
    800012c6:	9ddff0ef          	jal	80000ca2 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800012ca:	875a                	mv	a4,s6
    800012cc:	86a6                	mv	a3,s1
    800012ce:	6605                	lui	a2,0x1
    800012d0:	85ca                	mv	a1,s2
    800012d2:	8556                	mv	a0,s5
    800012d4:	d1bff0ef          	jal	80000fee <mappages>
    800012d8:	e915                	bnez	a0,8000130c <uvmalloc+0x84>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800012da:	6785                	lui	a5,0x1
    800012dc:	993e                	add	s2,s2,a5
    800012de:	fd496ee3          	bltu	s2,s4,800012ba <uvmalloc+0x32>
  return newsz;
    800012e2:	8552                	mv	a0,s4
    800012e4:	74a2                	ld	s1,40(sp)
    800012e6:	7902                	ld	s2,32(sp)
    800012e8:	6b02                	ld	s6,0(sp)
    800012ea:	a811                	j	800012fe <uvmalloc+0x76>
      uvmdealloc(pagetable, a, oldsz);
    800012ec:	864e                	mv	a2,s3
    800012ee:	85ca                	mv	a1,s2
    800012f0:	8556                	mv	a0,s5
    800012f2:	f53ff0ef          	jal	80001244 <uvmdealloc>
      return 0;
    800012f6:	4501                	li	a0,0
    800012f8:	74a2                	ld	s1,40(sp)
    800012fa:	7902                	ld	s2,32(sp)
    800012fc:	6b02                	ld	s6,0(sp)
}
    800012fe:	70e2                	ld	ra,56(sp)
    80001300:	7442                	ld	s0,48(sp)
    80001302:	69e2                	ld	s3,24(sp)
    80001304:	6a42                	ld	s4,16(sp)
    80001306:	6aa2                	ld	s5,8(sp)
    80001308:	6121                	addi	sp,sp,64
    8000130a:	8082                	ret
      kfree(mem);
    8000130c:	8526                	mv	a0,s1
    8000130e:	f0eff0ef          	jal	80000a1c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001312:	864e                	mv	a2,s3
    80001314:	85ca                	mv	a1,s2
    80001316:	8556                	mv	a0,s5
    80001318:	f2dff0ef          	jal	80001244 <uvmdealloc>
      return 0;
    8000131c:	4501                	li	a0,0
    8000131e:	74a2                	ld	s1,40(sp)
    80001320:	7902                	ld	s2,32(sp)
    80001322:	6b02                	ld	s6,0(sp)
    80001324:	bfe9                	j	800012fe <uvmalloc+0x76>
    return oldsz;
    80001326:	852e                	mv	a0,a1
}
    80001328:	8082                	ret
  return newsz;
    8000132a:	8532                	mv	a0,a2
    8000132c:	bfc9                	j	800012fe <uvmalloc+0x76>

000000008000132e <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    8000132e:	7179                	addi	sp,sp,-48
    80001330:	f406                	sd	ra,40(sp)
    80001332:	f022                	sd	s0,32(sp)
    80001334:	ec26                	sd	s1,24(sp)
    80001336:	e84a                	sd	s2,16(sp)
    80001338:	e44e                	sd	s3,8(sp)
    8000133a:	e052                	sd	s4,0(sp)
    8000133c:	1800                	addi	s0,sp,48
    8000133e:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001340:	84aa                	mv	s1,a0
    80001342:	6905                	lui	s2,0x1
    80001344:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001346:	4985                	li	s3,1
    80001348:	a819                	j	8000135e <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000134a:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    8000134c:	00c79513          	slli	a0,a5,0xc
    80001350:	fdfff0ef          	jal	8000132e <freewalk>
      pagetable[i] = 0;
    80001354:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001358:	04a1                	addi	s1,s1,8
    8000135a:	01248f63          	beq	s1,s2,80001378 <freewalk+0x4a>
    pte_t pte = pagetable[i];
    8000135e:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001360:	00f7f713          	andi	a4,a5,15
    80001364:	ff3703e3          	beq	a4,s3,8000134a <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001368:	8b85                	andi	a5,a5,1
    8000136a:	d7fd                	beqz	a5,80001358 <freewalk+0x2a>
      panic("freewalk: leaf");
    8000136c:	00006517          	auipc	a0,0x6
    80001370:	dcc50513          	addi	a0,a0,-564 # 80007138 <etext+0x138>
    80001374:	c6cff0ef          	jal	800007e0 <panic>
    }
  }
  kfree((void*)pagetable);
    80001378:	8552                	mv	a0,s4
    8000137a:	ea2ff0ef          	jal	80000a1c <kfree>
}
    8000137e:	70a2                	ld	ra,40(sp)
    80001380:	7402                	ld	s0,32(sp)
    80001382:	64e2                	ld	s1,24(sp)
    80001384:	6942                	ld	s2,16(sp)
    80001386:	69a2                	ld	s3,8(sp)
    80001388:	6a02                	ld	s4,0(sp)
    8000138a:	6145                	addi	sp,sp,48
    8000138c:	8082                	ret

000000008000138e <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000138e:	1101                	addi	sp,sp,-32
    80001390:	ec06                	sd	ra,24(sp)
    80001392:	e822                	sd	s0,16(sp)
    80001394:	e426                	sd	s1,8(sp)
    80001396:	1000                	addi	s0,sp,32
    80001398:	84aa                	mv	s1,a0
  if(sz > 0)
    8000139a:	e989                	bnez	a1,800013ac <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000139c:	8526                	mv	a0,s1
    8000139e:	f91ff0ef          	jal	8000132e <freewalk>
}
    800013a2:	60e2                	ld	ra,24(sp)
    800013a4:	6442                	ld	s0,16(sp)
    800013a6:	64a2                	ld	s1,8(sp)
    800013a8:	6105                	addi	sp,sp,32
    800013aa:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800013ac:	6785                	lui	a5,0x1
    800013ae:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013b0:	95be                	add	a1,a1,a5
    800013b2:	4685                	li	a3,1
    800013b4:	00c5d613          	srli	a2,a1,0xc
    800013b8:	4581                	li	a1,0
    800013ba:	e01ff0ef          	jal	800011ba <uvmunmap>
    800013be:	bff9                	j	8000139c <uvmfree+0xe>

00000000800013c0 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800013c0:	ce49                	beqz	a2,8000145a <uvmcopy+0x9a>
{
    800013c2:	715d                	addi	sp,sp,-80
    800013c4:	e486                	sd	ra,72(sp)
    800013c6:	e0a2                	sd	s0,64(sp)
    800013c8:	fc26                	sd	s1,56(sp)
    800013ca:	f84a                	sd	s2,48(sp)
    800013cc:	f44e                	sd	s3,40(sp)
    800013ce:	f052                	sd	s4,32(sp)
    800013d0:	ec56                	sd	s5,24(sp)
    800013d2:	e85a                	sd	s6,16(sp)
    800013d4:	e45e                	sd	s7,8(sp)
    800013d6:	0880                	addi	s0,sp,80
    800013d8:	8aaa                	mv	s5,a0
    800013da:	8b2e                	mv	s6,a1
    800013dc:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800013de:	4481                	li	s1,0
    800013e0:	a029                	j	800013ea <uvmcopy+0x2a>
    800013e2:	6785                	lui	a5,0x1
    800013e4:	94be                	add	s1,s1,a5
    800013e6:	0544fe63          	bgeu	s1,s4,80001442 <uvmcopy+0x82>
    if((pte = walk(old, i, 0)) == 0)
    800013ea:	4601                	li	a2,0
    800013ec:	85a6                	mv	a1,s1
    800013ee:	8556                	mv	a0,s5
    800013f0:	b27ff0ef          	jal	80000f16 <walk>
    800013f4:	d57d                	beqz	a0,800013e2 <uvmcopy+0x22>
      continue;   // page table entry hasn't been allocated
    if((*pte & PTE_V) == 0)
    800013f6:	6118                	ld	a4,0(a0)
    800013f8:	00177793          	andi	a5,a4,1
    800013fc:	d3fd                	beqz	a5,800013e2 <uvmcopy+0x22>
      continue;   // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    800013fe:	00a75593          	srli	a1,a4,0xa
    80001402:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001406:	3ff77913          	andi	s2,a4,1023
    if((mem = kalloc()) == 0)
    8000140a:	ef4ff0ef          	jal	80000afe <kalloc>
    8000140e:	89aa                	mv	s3,a0
    80001410:	c105                	beqz	a0,80001430 <uvmcopy+0x70>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001412:	6605                	lui	a2,0x1
    80001414:	85de                	mv	a1,s7
    80001416:	8e9ff0ef          	jal	80000cfe <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000141a:	874a                	mv	a4,s2
    8000141c:	86ce                	mv	a3,s3
    8000141e:	6605                	lui	a2,0x1
    80001420:	85a6                	mv	a1,s1
    80001422:	855a                	mv	a0,s6
    80001424:	bcbff0ef          	jal	80000fee <mappages>
    80001428:	dd4d                	beqz	a0,800013e2 <uvmcopy+0x22>
      kfree(mem);
    8000142a:	854e                	mv	a0,s3
    8000142c:	df0ff0ef          	jal	80000a1c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001430:	4685                	li	a3,1
    80001432:	00c4d613          	srli	a2,s1,0xc
    80001436:	4581                	li	a1,0
    80001438:	855a                	mv	a0,s6
    8000143a:	d81ff0ef          	jal	800011ba <uvmunmap>
  return -1;
    8000143e:	557d                	li	a0,-1
    80001440:	a011                	j	80001444 <uvmcopy+0x84>
  return 0;
    80001442:	4501                	li	a0,0
}
    80001444:	60a6                	ld	ra,72(sp)
    80001446:	6406                	ld	s0,64(sp)
    80001448:	74e2                	ld	s1,56(sp)
    8000144a:	7942                	ld	s2,48(sp)
    8000144c:	79a2                	ld	s3,40(sp)
    8000144e:	7a02                	ld	s4,32(sp)
    80001450:	6ae2                	ld	s5,24(sp)
    80001452:	6b42                	ld	s6,16(sp)
    80001454:	6ba2                	ld	s7,8(sp)
    80001456:	6161                	addi	sp,sp,80
    80001458:	8082                	ret
  return 0;
    8000145a:	4501                	li	a0,0
}
    8000145c:	8082                	ret

000000008000145e <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000145e:	1141                	addi	sp,sp,-16
    80001460:	e406                	sd	ra,8(sp)
    80001462:	e022                	sd	s0,0(sp)
    80001464:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001466:	4601                	li	a2,0
    80001468:	aafff0ef          	jal	80000f16 <walk>
  if(pte == 0)
    8000146c:	c901                	beqz	a0,8000147c <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000146e:	611c                	ld	a5,0(a0)
    80001470:	9bbd                	andi	a5,a5,-17
    80001472:	e11c                	sd	a5,0(a0)
}
    80001474:	60a2                	ld	ra,8(sp)
    80001476:	6402                	ld	s0,0(sp)
    80001478:	0141                	addi	sp,sp,16
    8000147a:	8082                	ret
    panic("uvmclear");
    8000147c:	00006517          	auipc	a0,0x6
    80001480:	ccc50513          	addi	a0,a0,-820 # 80007148 <etext+0x148>
    80001484:	b5cff0ef          	jal	800007e0 <panic>

0000000080001488 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001488:	c6dd                	beqz	a3,80001536 <copyinstr+0xae>
{
    8000148a:	715d                	addi	sp,sp,-80
    8000148c:	e486                	sd	ra,72(sp)
    8000148e:	e0a2                	sd	s0,64(sp)
    80001490:	fc26                	sd	s1,56(sp)
    80001492:	f84a                	sd	s2,48(sp)
    80001494:	f44e                	sd	s3,40(sp)
    80001496:	f052                	sd	s4,32(sp)
    80001498:	ec56                	sd	s5,24(sp)
    8000149a:	e85a                	sd	s6,16(sp)
    8000149c:	e45e                	sd	s7,8(sp)
    8000149e:	0880                	addi	s0,sp,80
    800014a0:	8a2a                	mv	s4,a0
    800014a2:	8b2e                	mv	s6,a1
    800014a4:	8bb2                	mv	s7,a2
    800014a6:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    800014a8:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800014aa:	6985                	lui	s3,0x1
    800014ac:	a825                	j	800014e4 <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800014ae:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800014b2:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800014b4:	37fd                	addiw	a5,a5,-1
    800014b6:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800014ba:	60a6                	ld	ra,72(sp)
    800014bc:	6406                	ld	s0,64(sp)
    800014be:	74e2                	ld	s1,56(sp)
    800014c0:	7942                	ld	s2,48(sp)
    800014c2:	79a2                	ld	s3,40(sp)
    800014c4:	7a02                	ld	s4,32(sp)
    800014c6:	6ae2                	ld	s5,24(sp)
    800014c8:	6b42                	ld	s6,16(sp)
    800014ca:	6ba2                	ld	s7,8(sp)
    800014cc:	6161                	addi	sp,sp,80
    800014ce:	8082                	ret
    800014d0:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    800014d4:	9742                	add	a4,a4,a6
      --max;
    800014d6:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    800014da:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    800014de:	04e58463          	beq	a1,a4,80001526 <copyinstr+0x9e>
{
    800014e2:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    800014e4:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800014e8:	85a6                	mv	a1,s1
    800014ea:	8552                	mv	a0,s4
    800014ec:	ac5ff0ef          	jal	80000fb0 <walkaddr>
    if(pa0 == 0)
    800014f0:	cd0d                	beqz	a0,8000152a <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800014f2:	417486b3          	sub	a3,s1,s7
    800014f6:	96ce                	add	a3,a3,s3
    if(n > max)
    800014f8:	00d97363          	bgeu	s2,a3,800014fe <copyinstr+0x76>
    800014fc:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    800014fe:	955e                	add	a0,a0,s7
    80001500:	8d05                	sub	a0,a0,s1
    while(n > 0){
    80001502:	c695                	beqz	a3,8000152e <copyinstr+0xa6>
    80001504:	87da                	mv	a5,s6
    80001506:	885a                	mv	a6,s6
      if(*p == '\0'){
    80001508:	41650633          	sub	a2,a0,s6
    while(n > 0){
    8000150c:	96da                	add	a3,a3,s6
    8000150e:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001510:	00f60733          	add	a4,a2,a5
    80001514:	00074703          	lbu	a4,0(a4)
    80001518:	db59                	beqz	a4,800014ae <copyinstr+0x26>
        *dst = *p;
    8000151a:	00e78023          	sb	a4,0(a5)
      dst++;
    8000151e:	0785                	addi	a5,a5,1
    while(n > 0){
    80001520:	fed797e3          	bne	a5,a3,8000150e <copyinstr+0x86>
    80001524:	b775                	j	800014d0 <copyinstr+0x48>
    80001526:	4781                	li	a5,0
    80001528:	b771                	j	800014b4 <copyinstr+0x2c>
      return -1;
    8000152a:	557d                	li	a0,-1
    8000152c:	b779                	j	800014ba <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    8000152e:	6b85                	lui	s7,0x1
    80001530:	9ba6                	add	s7,s7,s1
    80001532:	87da                	mv	a5,s6
    80001534:	b77d                	j	800014e2 <copyinstr+0x5a>
  int got_null = 0;
    80001536:	4781                	li	a5,0
  if(got_null){
    80001538:	37fd                	addiw	a5,a5,-1
    8000153a:	0007851b          	sext.w	a0,a5
}
    8000153e:	8082                	ret

0000000080001540 <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    80001540:	1141                	addi	sp,sp,-16
    80001542:	e406                	sd	ra,8(sp)
    80001544:	e022                	sd	s0,0(sp)
    80001546:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    80001548:	4601                	li	a2,0
    8000154a:	9cdff0ef          	jal	80000f16 <walk>
  if (pte == 0) {
    8000154e:	c519                	beqz	a0,8000155c <ismapped+0x1c>
    return 0;
  }
  if (*pte & PTE_V){
    80001550:	6108                	ld	a0,0(a0)
    80001552:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    80001554:	60a2                	ld	ra,8(sp)
    80001556:	6402                	ld	s0,0(sp)
    80001558:	0141                	addi	sp,sp,16
    8000155a:	8082                	ret
    return 0;
    8000155c:	4501                	li	a0,0
    8000155e:	bfdd                	j	80001554 <ismapped+0x14>

0000000080001560 <vmfault>:
{
    80001560:	7179                	addi	sp,sp,-48
    80001562:	f406                	sd	ra,40(sp)
    80001564:	f022                	sd	s0,32(sp)
    80001566:	ec26                	sd	s1,24(sp)
    80001568:	e44e                	sd	s3,8(sp)
    8000156a:	1800                	addi	s0,sp,48
    8000156c:	89aa                	mv	s3,a0
    8000156e:	84ae                	mv	s1,a1
  struct proc *p = myproc();
    80001570:	35e000ef          	jal	800018ce <myproc>
  if (va >= p->sz)
    80001574:	653c                	ld	a5,72(a0)
    80001576:	00f4ea63          	bltu	s1,a5,8000158a <vmfault+0x2a>
    return 0;
    8000157a:	4981                	li	s3,0
}
    8000157c:	854e                	mv	a0,s3
    8000157e:	70a2                	ld	ra,40(sp)
    80001580:	7402                	ld	s0,32(sp)
    80001582:	64e2                	ld	s1,24(sp)
    80001584:	69a2                	ld	s3,8(sp)
    80001586:	6145                	addi	sp,sp,48
    80001588:	8082                	ret
    8000158a:	e84a                	sd	s2,16(sp)
    8000158c:	892a                	mv	s2,a0
  va = PGROUNDDOWN(va);
    8000158e:	77fd                	lui	a5,0xfffff
    80001590:	8cfd                	and	s1,s1,a5
  if(ismapped(pagetable, va)) {
    80001592:	85a6                	mv	a1,s1
    80001594:	854e                	mv	a0,s3
    80001596:	fabff0ef          	jal	80001540 <ismapped>
    return 0;
    8000159a:	4981                	li	s3,0
  if(ismapped(pagetable, va)) {
    8000159c:	c119                	beqz	a0,800015a2 <vmfault+0x42>
    8000159e:	6942                	ld	s2,16(sp)
    800015a0:	bff1                	j	8000157c <vmfault+0x1c>
    800015a2:	e052                	sd	s4,0(sp)
  mem = (uint64) kalloc();
    800015a4:	d5aff0ef          	jal	80000afe <kalloc>
    800015a8:	8a2a                	mv	s4,a0
  if(mem == 0)
    800015aa:	c90d                	beqz	a0,800015dc <vmfault+0x7c>
  mem = (uint64) kalloc();
    800015ac:	89aa                	mv	s3,a0
  memset((void *) mem, 0, PGSIZE);
    800015ae:	6605                	lui	a2,0x1
    800015b0:	4581                	li	a1,0
    800015b2:	ef0ff0ef          	jal	80000ca2 <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    800015b6:	4759                	li	a4,22
    800015b8:	86d2                	mv	a3,s4
    800015ba:	6605                	lui	a2,0x1
    800015bc:	85a6                	mv	a1,s1
    800015be:	05093503          	ld	a0,80(s2)
    800015c2:	a2dff0ef          	jal	80000fee <mappages>
    800015c6:	e501                	bnez	a0,800015ce <vmfault+0x6e>
    800015c8:	6942                	ld	s2,16(sp)
    800015ca:	6a02                	ld	s4,0(sp)
    800015cc:	bf45                	j	8000157c <vmfault+0x1c>
    kfree((void *)mem);
    800015ce:	8552                	mv	a0,s4
    800015d0:	c4cff0ef          	jal	80000a1c <kfree>
    return 0;
    800015d4:	4981                	li	s3,0
    800015d6:	6942                	ld	s2,16(sp)
    800015d8:	6a02                	ld	s4,0(sp)
    800015da:	b74d                	j	8000157c <vmfault+0x1c>
    800015dc:	6942                	ld	s2,16(sp)
    800015de:	6a02                	ld	s4,0(sp)
    800015e0:	bf71                	j	8000157c <vmfault+0x1c>

00000000800015e2 <copyout>:
  while(len > 0){
    800015e2:	c2cd                	beqz	a3,80001684 <copyout+0xa2>
{
    800015e4:	711d                	addi	sp,sp,-96
    800015e6:	ec86                	sd	ra,88(sp)
    800015e8:	e8a2                	sd	s0,80(sp)
    800015ea:	e4a6                	sd	s1,72(sp)
    800015ec:	f852                	sd	s4,48(sp)
    800015ee:	f05a                	sd	s6,32(sp)
    800015f0:	ec5e                	sd	s7,24(sp)
    800015f2:	e862                	sd	s8,16(sp)
    800015f4:	1080                	addi	s0,sp,96
    800015f6:	8c2a                	mv	s8,a0
    800015f8:	8b2e                	mv	s6,a1
    800015fa:	8bb2                	mv	s7,a2
    800015fc:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(dstva);
    800015fe:	74fd                	lui	s1,0xfffff
    80001600:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    80001602:	57fd                	li	a5,-1
    80001604:	83e9                	srli	a5,a5,0x1a
    80001606:	0897e163          	bltu	a5,s1,80001688 <copyout+0xa6>
    8000160a:	e0ca                	sd	s2,64(sp)
    8000160c:	fc4e                	sd	s3,56(sp)
    8000160e:	f456                	sd	s5,40(sp)
    80001610:	e466                	sd	s9,8(sp)
    80001612:	e06a                	sd	s10,0(sp)
    80001614:	6d05                	lui	s10,0x1
    80001616:	8cbe                	mv	s9,a5
    80001618:	a015                	j	8000163c <copyout+0x5a>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000161a:	409b0533          	sub	a0,s6,s1
    8000161e:	0009861b          	sext.w	a2,s3
    80001622:	85de                	mv	a1,s7
    80001624:	954a                	add	a0,a0,s2
    80001626:	ed8ff0ef          	jal	80000cfe <memmove>
    len -= n;
    8000162a:	413a0a33          	sub	s4,s4,s3
    src += n;
    8000162e:	9bce                	add	s7,s7,s3
  while(len > 0){
    80001630:	040a0363          	beqz	s4,80001676 <copyout+0x94>
    if(va0 >= MAXVA)
    80001634:	055cec63          	bltu	s9,s5,8000168c <copyout+0xaa>
    80001638:	84d6                	mv	s1,s5
    8000163a:	8b56                	mv	s6,s5
    pa0 = walkaddr(pagetable, va0);
    8000163c:	85a6                	mv	a1,s1
    8000163e:	8562                	mv	a0,s8
    80001640:	971ff0ef          	jal	80000fb0 <walkaddr>
    80001644:	892a                	mv	s2,a0
    if(pa0 == 0) {
    80001646:	e901                	bnez	a0,80001656 <copyout+0x74>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001648:	4601                	li	a2,0
    8000164a:	85a6                	mv	a1,s1
    8000164c:	8562                	mv	a0,s8
    8000164e:	f13ff0ef          	jal	80001560 <vmfault>
    80001652:	892a                	mv	s2,a0
    80001654:	c139                	beqz	a0,8000169a <copyout+0xb8>
    pte = walk(pagetable, va0, 0);
    80001656:	4601                	li	a2,0
    80001658:	85a6                	mv	a1,s1
    8000165a:	8562                	mv	a0,s8
    8000165c:	8bbff0ef          	jal	80000f16 <walk>
    if((*pte & PTE_W) == 0)
    80001660:	611c                	ld	a5,0(a0)
    80001662:	8b91                	andi	a5,a5,4
    80001664:	c3b1                	beqz	a5,800016a8 <copyout+0xc6>
    n = PGSIZE - (dstva - va0);
    80001666:	01a48ab3          	add	s5,s1,s10
    8000166a:	416a89b3          	sub	s3,s5,s6
    if(n > len)
    8000166e:	fb3a76e3          	bgeu	s4,s3,8000161a <copyout+0x38>
    80001672:	89d2                	mv	s3,s4
    80001674:	b75d                	j	8000161a <copyout+0x38>
  return 0;
    80001676:	4501                	li	a0,0
    80001678:	6906                	ld	s2,64(sp)
    8000167a:	79e2                	ld	s3,56(sp)
    8000167c:	7aa2                	ld	s5,40(sp)
    8000167e:	6ca2                	ld	s9,8(sp)
    80001680:	6d02                	ld	s10,0(sp)
    80001682:	a80d                	j	800016b4 <copyout+0xd2>
    80001684:	4501                	li	a0,0
}
    80001686:	8082                	ret
      return -1;
    80001688:	557d                	li	a0,-1
    8000168a:	a02d                	j	800016b4 <copyout+0xd2>
    8000168c:	557d                	li	a0,-1
    8000168e:	6906                	ld	s2,64(sp)
    80001690:	79e2                	ld	s3,56(sp)
    80001692:	7aa2                	ld	s5,40(sp)
    80001694:	6ca2                	ld	s9,8(sp)
    80001696:	6d02                	ld	s10,0(sp)
    80001698:	a831                	j	800016b4 <copyout+0xd2>
        return -1;
    8000169a:	557d                	li	a0,-1
    8000169c:	6906                	ld	s2,64(sp)
    8000169e:	79e2                	ld	s3,56(sp)
    800016a0:	7aa2                	ld	s5,40(sp)
    800016a2:	6ca2                	ld	s9,8(sp)
    800016a4:	6d02                	ld	s10,0(sp)
    800016a6:	a039                	j	800016b4 <copyout+0xd2>
      return -1;
    800016a8:	557d                	li	a0,-1
    800016aa:	6906                	ld	s2,64(sp)
    800016ac:	79e2                	ld	s3,56(sp)
    800016ae:	7aa2                	ld	s5,40(sp)
    800016b0:	6ca2                	ld	s9,8(sp)
    800016b2:	6d02                	ld	s10,0(sp)
}
    800016b4:	60e6                	ld	ra,88(sp)
    800016b6:	6446                	ld	s0,80(sp)
    800016b8:	64a6                	ld	s1,72(sp)
    800016ba:	7a42                	ld	s4,48(sp)
    800016bc:	7b02                	ld	s6,32(sp)
    800016be:	6be2                	ld	s7,24(sp)
    800016c0:	6c42                	ld	s8,16(sp)
    800016c2:	6125                	addi	sp,sp,96
    800016c4:	8082                	ret

00000000800016c6 <copyin>:
  while(len > 0){
    800016c6:	c6c9                	beqz	a3,80001750 <copyin+0x8a>
{
    800016c8:	715d                	addi	sp,sp,-80
    800016ca:	e486                	sd	ra,72(sp)
    800016cc:	e0a2                	sd	s0,64(sp)
    800016ce:	fc26                	sd	s1,56(sp)
    800016d0:	f84a                	sd	s2,48(sp)
    800016d2:	f44e                	sd	s3,40(sp)
    800016d4:	f052                	sd	s4,32(sp)
    800016d6:	ec56                	sd	s5,24(sp)
    800016d8:	e85a                	sd	s6,16(sp)
    800016da:	e45e                	sd	s7,8(sp)
    800016dc:	e062                	sd	s8,0(sp)
    800016de:	0880                	addi	s0,sp,80
    800016e0:	8baa                	mv	s7,a0
    800016e2:	8aae                	mv	s5,a1
    800016e4:	8932                	mv	s2,a2
    800016e6:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    800016e8:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    800016ea:	6b05                	lui	s6,0x1
    800016ec:	a035                	j	80001718 <copyin+0x52>
    800016ee:	412984b3          	sub	s1,s3,s2
    800016f2:	94da                	add	s1,s1,s6
    if(n > len)
    800016f4:	009a7363          	bgeu	s4,s1,800016fa <copyin+0x34>
    800016f8:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800016fa:	413905b3          	sub	a1,s2,s3
    800016fe:	0004861b          	sext.w	a2,s1
    80001702:	95aa                	add	a1,a1,a0
    80001704:	8556                	mv	a0,s5
    80001706:	df8ff0ef          	jal	80000cfe <memmove>
    len -= n;
    8000170a:	409a0a33          	sub	s4,s4,s1
    dst += n;
    8000170e:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    80001710:	01698933          	add	s2,s3,s6
  while(len > 0){
    80001714:	020a0163          	beqz	s4,80001736 <copyin+0x70>
    va0 = PGROUNDDOWN(srcva);
    80001718:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    8000171c:	85ce                	mv	a1,s3
    8000171e:	855e                	mv	a0,s7
    80001720:	891ff0ef          	jal	80000fb0 <walkaddr>
    if(pa0 == 0) {
    80001724:	f569                	bnez	a0,800016ee <copyin+0x28>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001726:	4601                	li	a2,0
    80001728:	85ce                	mv	a1,s3
    8000172a:	855e                	mv	a0,s7
    8000172c:	e35ff0ef          	jal	80001560 <vmfault>
    80001730:	fd5d                	bnez	a0,800016ee <copyin+0x28>
        return -1;
    80001732:	557d                	li	a0,-1
    80001734:	a011                	j	80001738 <copyin+0x72>
  return 0;
    80001736:	4501                	li	a0,0
}
    80001738:	60a6                	ld	ra,72(sp)
    8000173a:	6406                	ld	s0,64(sp)
    8000173c:	74e2                	ld	s1,56(sp)
    8000173e:	7942                	ld	s2,48(sp)
    80001740:	79a2                	ld	s3,40(sp)
    80001742:	7a02                	ld	s4,32(sp)
    80001744:	6ae2                	ld	s5,24(sp)
    80001746:	6b42                	ld	s6,16(sp)
    80001748:	6ba2                	ld	s7,8(sp)
    8000174a:	6c02                	ld	s8,0(sp)
    8000174c:	6161                	addi	sp,sp,80
    8000174e:	8082                	ret
  return 0;
    80001750:	4501                	li	a0,0
}
    80001752:	8082                	ret

0000000080001754 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001754:	7139                	addi	sp,sp,-64
    80001756:	fc06                	sd	ra,56(sp)
    80001758:	f822                	sd	s0,48(sp)
    8000175a:	f426                	sd	s1,40(sp)
    8000175c:	f04a                	sd	s2,32(sp)
    8000175e:	ec4e                	sd	s3,24(sp)
    80001760:	e852                	sd	s4,16(sp)
    80001762:	e456                	sd	s5,8(sp)
    80001764:	e05a                	sd	s6,0(sp)
    80001766:	0080                	addi	s0,sp,64
    80001768:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    8000176a:	00011497          	auipc	s1,0x11
    8000176e:	f9e48493          	addi	s1,s1,-98 # 80012708 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001772:	8b26                	mv	s6,s1
    80001774:	04fa5937          	lui	s2,0x4fa5
    80001778:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    8000177c:	0932                	slli	s2,s2,0xc
    8000177e:	fa590913          	addi	s2,s2,-91
    80001782:	0932                	slli	s2,s2,0xc
    80001784:	fa590913          	addi	s2,s2,-91
    80001788:	0932                	slli	s2,s2,0xc
    8000178a:	fa590913          	addi	s2,s2,-91
    8000178e:	040009b7          	lui	s3,0x4000
    80001792:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001794:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001796:	00017a97          	auipc	s5,0x17
    8000179a:	972a8a93          	addi	s5,s5,-1678 # 80018108 <tickslock>
    char *pa = kalloc();
    8000179e:	b60ff0ef          	jal	80000afe <kalloc>
    800017a2:	862a                	mv	a2,a0
    if(pa == 0)
    800017a4:	cd15                	beqz	a0,800017e0 <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int) (p - proc));
    800017a6:	416485b3          	sub	a1,s1,s6
    800017aa:	858d                	srai	a1,a1,0x3
    800017ac:	032585b3          	mul	a1,a1,s2
    800017b0:	2585                	addiw	a1,a1,1
    800017b2:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017b6:	4719                	li	a4,6
    800017b8:	6685                	lui	a3,0x1
    800017ba:	40b985b3          	sub	a1,s3,a1
    800017be:	8552                	mv	a0,s4
    800017c0:	8dfff0ef          	jal	8000109e <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800017c4:	16848493          	addi	s1,s1,360
    800017c8:	fd549be3          	bne	s1,s5,8000179e <proc_mapstacks+0x4a>
  }
}
    800017cc:	70e2                	ld	ra,56(sp)
    800017ce:	7442                	ld	s0,48(sp)
    800017d0:	74a2                	ld	s1,40(sp)
    800017d2:	7902                	ld	s2,32(sp)
    800017d4:	69e2                	ld	s3,24(sp)
    800017d6:	6a42                	ld	s4,16(sp)
    800017d8:	6aa2                	ld	s5,8(sp)
    800017da:	6b02                	ld	s6,0(sp)
    800017dc:	6121                	addi	sp,sp,64
    800017de:	8082                	ret
      panic("kalloc");
    800017e0:	00006517          	auipc	a0,0x6
    800017e4:	97850513          	addi	a0,a0,-1672 # 80007158 <etext+0x158>
    800017e8:	ff9fe0ef          	jal	800007e0 <panic>

00000000800017ec <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800017ec:	7139                	addi	sp,sp,-64
    800017ee:	fc06                	sd	ra,56(sp)
    800017f0:	f822                	sd	s0,48(sp)
    800017f2:	f426                	sd	s1,40(sp)
    800017f4:	f04a                	sd	s2,32(sp)
    800017f6:	ec4e                	sd	s3,24(sp)
    800017f8:	e852                	sd	s4,16(sp)
    800017fa:	e456                	sd	s5,8(sp)
    800017fc:	e05a                	sd	s6,0(sp)
    800017fe:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001800:	00006597          	auipc	a1,0x6
    80001804:	96058593          	addi	a1,a1,-1696 # 80007160 <etext+0x160>
    80001808:	00011517          	auipc	a0,0x11
    8000180c:	ad050513          	addi	a0,a0,-1328 # 800122d8 <pid_lock>
    80001810:	b3eff0ef          	jal	80000b4e <initlock>
  initlock(&wait_lock, "wait_lock");
    80001814:	00006597          	auipc	a1,0x6
    80001818:	95458593          	addi	a1,a1,-1708 # 80007168 <etext+0x168>
    8000181c:	00011517          	auipc	a0,0x11
    80001820:	ad450513          	addi	a0,a0,-1324 # 800122f0 <wait_lock>
    80001824:	b2aff0ef          	jal	80000b4e <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001828:	00011497          	auipc	s1,0x11
    8000182c:	ee048493          	addi	s1,s1,-288 # 80012708 <proc>
      initlock(&p->lock, "proc");
    80001830:	00006b17          	auipc	s6,0x6
    80001834:	948b0b13          	addi	s6,s6,-1720 # 80007178 <etext+0x178>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001838:	8aa6                	mv	s5,s1
    8000183a:	04fa5937          	lui	s2,0x4fa5
    8000183e:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80001842:	0932                	slli	s2,s2,0xc
    80001844:	fa590913          	addi	s2,s2,-91
    80001848:	0932                	slli	s2,s2,0xc
    8000184a:	fa590913          	addi	s2,s2,-91
    8000184e:	0932                	slli	s2,s2,0xc
    80001850:	fa590913          	addi	s2,s2,-91
    80001854:	040009b7          	lui	s3,0x4000
    80001858:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000185a:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000185c:	00017a17          	auipc	s4,0x17
    80001860:	8aca0a13          	addi	s4,s4,-1876 # 80018108 <tickslock>
      initlock(&p->lock, "proc");
    80001864:	85da                	mv	a1,s6
    80001866:	8526                	mv	a0,s1
    80001868:	ae6ff0ef          	jal	80000b4e <initlock>
      p->state = UNUSED;
    8000186c:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001870:	415487b3          	sub	a5,s1,s5
    80001874:	878d                	srai	a5,a5,0x3
    80001876:	032787b3          	mul	a5,a5,s2
    8000187a:	2785                	addiw	a5,a5,1 # fffffffffffff001 <end+0xffffffff7ffdbb19>
    8000187c:	00d7979b          	slliw	a5,a5,0xd
    80001880:	40f987b3          	sub	a5,s3,a5
    80001884:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001886:	16848493          	addi	s1,s1,360
    8000188a:	fd449de3          	bne	s1,s4,80001864 <procinit+0x78>
  }
}
    8000188e:	70e2                	ld	ra,56(sp)
    80001890:	7442                	ld	s0,48(sp)
    80001892:	74a2                	ld	s1,40(sp)
    80001894:	7902                	ld	s2,32(sp)
    80001896:	69e2                	ld	s3,24(sp)
    80001898:	6a42                	ld	s4,16(sp)
    8000189a:	6aa2                	ld	s5,8(sp)
    8000189c:	6b02                	ld	s6,0(sp)
    8000189e:	6121                	addi	sp,sp,64
    800018a0:	8082                	ret

00000000800018a2 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800018a2:	1141                	addi	sp,sp,-16
    800018a4:	e422                	sd	s0,8(sp)
    800018a6:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800018a8:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800018aa:	2501                	sext.w	a0,a0
    800018ac:	6422                	ld	s0,8(sp)
    800018ae:	0141                	addi	sp,sp,16
    800018b0:	8082                	ret

00000000800018b2 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800018b2:	1141                	addi	sp,sp,-16
    800018b4:	e422                	sd	s0,8(sp)
    800018b6:	0800                	addi	s0,sp,16
    800018b8:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800018ba:	2781                	sext.w	a5,a5
    800018bc:	079e                	slli	a5,a5,0x7
  return c;
}
    800018be:	00011517          	auipc	a0,0x11
    800018c2:	a4a50513          	addi	a0,a0,-1462 # 80012308 <cpus>
    800018c6:	953e                	add	a0,a0,a5
    800018c8:	6422                	ld	s0,8(sp)
    800018ca:	0141                	addi	sp,sp,16
    800018cc:	8082                	ret

00000000800018ce <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800018ce:	1101                	addi	sp,sp,-32
    800018d0:	ec06                	sd	ra,24(sp)
    800018d2:	e822                	sd	s0,16(sp)
    800018d4:	e426                	sd	s1,8(sp)
    800018d6:	1000                	addi	s0,sp,32
  push_off();
    800018d8:	ab6ff0ef          	jal	80000b8e <push_off>
    800018dc:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800018de:	2781                	sext.w	a5,a5
    800018e0:	079e                	slli	a5,a5,0x7
    800018e2:	00011717          	auipc	a4,0x11
    800018e6:	9f670713          	addi	a4,a4,-1546 # 800122d8 <pid_lock>
    800018ea:	97ba                	add	a5,a5,a4
    800018ec:	7b84                	ld	s1,48(a5)
  pop_off();
    800018ee:	b24ff0ef          	jal	80000c12 <pop_off>
  return p;
}
    800018f2:	8526                	mv	a0,s1
    800018f4:	60e2                	ld	ra,24(sp)
    800018f6:	6442                	ld	s0,16(sp)
    800018f8:	64a2                	ld	s1,8(sp)
    800018fa:	6105                	addi	sp,sp,32
    800018fc:	8082                	ret

00000000800018fe <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800018fe:	7179                	addi	sp,sp,-48
    80001900:	f406                	sd	ra,40(sp)
    80001902:	f022                	sd	s0,32(sp)
    80001904:	ec26                	sd	s1,24(sp)
    80001906:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001908:	fc7ff0ef          	jal	800018ce <myproc>
    8000190c:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    8000190e:	b58ff0ef          	jal	80000c66 <release>

  if (first) {
    80001912:	00009797          	auipc	a5,0x9
    80001916:	86e7a783          	lw	a5,-1938(a5) # 8000a180 <first.1>
    8000191a:	cf8d                	beqz	a5,80001954 <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    8000191c:	4505                	li	a0,1
    8000191e:	3ef010ef          	jal	8000350c <fsinit>

    first = 0;
    80001922:	00009797          	auipc	a5,0x9
    80001926:	8407af23          	sw	zero,-1954(a5) # 8000a180 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    8000192a:	0330000f          	fence	rw,rw

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    8000192e:	00006517          	auipc	a0,0x6
    80001932:	85250513          	addi	a0,a0,-1966 # 80007180 <etext+0x180>
    80001936:	fca43823          	sd	a0,-48(s0)
    8000193a:	fc043c23          	sd	zero,-40(s0)
    8000193e:	fd040593          	addi	a1,s0,-48
    80001942:	4cb020ef          	jal	8000460c <kexec>
    80001946:	6cbc                	ld	a5,88(s1)
    80001948:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    8000194a:	6cbc                	ld	a5,88(s1)
    8000194c:	7bb8                	ld	a4,112(a5)
    8000194e:	57fd                	li	a5,-1
    80001950:	02f70d63          	beq	a4,a5,8000198a <forkret+0x8c>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001954:	2ad000ef          	jal	80002400 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001958:	68a8                	ld	a0,80(s1)
    8000195a:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    8000195c:	04000737          	lui	a4,0x4000
    80001960:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001962:	0732                	slli	a4,a4,0xc
    80001964:	00004797          	auipc	a5,0x4
    80001968:	73878793          	addi	a5,a5,1848 # 8000609c <userret>
    8000196c:	00004697          	auipc	a3,0x4
    80001970:	69468693          	addi	a3,a3,1684 # 80006000 <_trampoline>
    80001974:	8f95                	sub	a5,a5,a3
    80001976:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001978:	577d                	li	a4,-1
    8000197a:	177e                	slli	a4,a4,0x3f
    8000197c:	8d59                	or	a0,a0,a4
    8000197e:	9782                	jalr	a5
}
    80001980:	70a2                	ld	ra,40(sp)
    80001982:	7402                	ld	s0,32(sp)
    80001984:	64e2                	ld	s1,24(sp)
    80001986:	6145                	addi	sp,sp,48
    80001988:	8082                	ret
      panic("exec");
    8000198a:	00005517          	auipc	a0,0x5
    8000198e:	7fe50513          	addi	a0,a0,2046 # 80007188 <etext+0x188>
    80001992:	e4ffe0ef          	jal	800007e0 <panic>

0000000080001996 <allocpid>:
{
    80001996:	1101                	addi	sp,sp,-32
    80001998:	ec06                	sd	ra,24(sp)
    8000199a:	e822                	sd	s0,16(sp)
    8000199c:	e426                	sd	s1,8(sp)
    8000199e:	e04a                	sd	s2,0(sp)
    800019a0:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    800019a2:	00011917          	auipc	s2,0x11
    800019a6:	93690913          	addi	s2,s2,-1738 # 800122d8 <pid_lock>
    800019aa:	854a                	mv	a0,s2
    800019ac:	a22ff0ef          	jal	80000bce <acquire>
  pid = nextpid;
    800019b0:	00008797          	auipc	a5,0x8
    800019b4:	7d478793          	addi	a5,a5,2004 # 8000a184 <nextpid>
    800019b8:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    800019ba:	0014871b          	addiw	a4,s1,1
    800019be:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    800019c0:	854a                	mv	a0,s2
    800019c2:	aa4ff0ef          	jal	80000c66 <release>
}
    800019c6:	8526                	mv	a0,s1
    800019c8:	60e2                	ld	ra,24(sp)
    800019ca:	6442                	ld	s0,16(sp)
    800019cc:	64a2                	ld	s1,8(sp)
    800019ce:	6902                	ld	s2,0(sp)
    800019d0:	6105                	addi	sp,sp,32
    800019d2:	8082                	ret

00000000800019d4 <proc_pagetable>:
{
    800019d4:	1101                	addi	sp,sp,-32
    800019d6:	ec06                	sd	ra,24(sp)
    800019d8:	e822                	sd	s0,16(sp)
    800019da:	e426                	sd	s1,8(sp)
    800019dc:	e04a                	sd	s2,0(sp)
    800019de:	1000                	addi	s0,sp,32
    800019e0:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    800019e2:	fb2ff0ef          	jal	80001194 <uvmcreate>
    800019e6:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800019e8:	cd05                	beqz	a0,80001a20 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    800019ea:	4729                	li	a4,10
    800019ec:	00004697          	auipc	a3,0x4
    800019f0:	61468693          	addi	a3,a3,1556 # 80006000 <_trampoline>
    800019f4:	6605                	lui	a2,0x1
    800019f6:	040005b7          	lui	a1,0x4000
    800019fa:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800019fc:	05b2                	slli	a1,a1,0xc
    800019fe:	df0ff0ef          	jal	80000fee <mappages>
    80001a02:	02054663          	bltz	a0,80001a2e <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001a06:	4719                	li	a4,6
    80001a08:	05893683          	ld	a3,88(s2)
    80001a0c:	6605                	lui	a2,0x1
    80001a0e:	020005b7          	lui	a1,0x2000
    80001a12:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a14:	05b6                	slli	a1,a1,0xd
    80001a16:	8526                	mv	a0,s1
    80001a18:	dd6ff0ef          	jal	80000fee <mappages>
    80001a1c:	00054f63          	bltz	a0,80001a3a <proc_pagetable+0x66>
}
    80001a20:	8526                	mv	a0,s1
    80001a22:	60e2                	ld	ra,24(sp)
    80001a24:	6442                	ld	s0,16(sp)
    80001a26:	64a2                	ld	s1,8(sp)
    80001a28:	6902                	ld	s2,0(sp)
    80001a2a:	6105                	addi	sp,sp,32
    80001a2c:	8082                	ret
    uvmfree(pagetable, 0);
    80001a2e:	4581                	li	a1,0
    80001a30:	8526                	mv	a0,s1
    80001a32:	95dff0ef          	jal	8000138e <uvmfree>
    return 0;
    80001a36:	4481                	li	s1,0
    80001a38:	b7e5                	j	80001a20 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a3a:	4681                	li	a3,0
    80001a3c:	4605                	li	a2,1
    80001a3e:	040005b7          	lui	a1,0x4000
    80001a42:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a44:	05b2                	slli	a1,a1,0xc
    80001a46:	8526                	mv	a0,s1
    80001a48:	f72ff0ef          	jal	800011ba <uvmunmap>
    uvmfree(pagetable, 0);
    80001a4c:	4581                	li	a1,0
    80001a4e:	8526                	mv	a0,s1
    80001a50:	93fff0ef          	jal	8000138e <uvmfree>
    return 0;
    80001a54:	4481                	li	s1,0
    80001a56:	b7e9                	j	80001a20 <proc_pagetable+0x4c>

0000000080001a58 <proc_freepagetable>:
{
    80001a58:	1101                	addi	sp,sp,-32
    80001a5a:	ec06                	sd	ra,24(sp)
    80001a5c:	e822                	sd	s0,16(sp)
    80001a5e:	e426                	sd	s1,8(sp)
    80001a60:	e04a                	sd	s2,0(sp)
    80001a62:	1000                	addi	s0,sp,32
    80001a64:	84aa                	mv	s1,a0
    80001a66:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a68:	4681                	li	a3,0
    80001a6a:	4605                	li	a2,1
    80001a6c:	040005b7          	lui	a1,0x4000
    80001a70:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a72:	05b2                	slli	a1,a1,0xc
    80001a74:	f46ff0ef          	jal	800011ba <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001a78:	4681                	li	a3,0
    80001a7a:	4605                	li	a2,1
    80001a7c:	020005b7          	lui	a1,0x2000
    80001a80:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a82:	05b6                	slli	a1,a1,0xd
    80001a84:	8526                	mv	a0,s1
    80001a86:	f34ff0ef          	jal	800011ba <uvmunmap>
  uvmfree(pagetable, sz);
    80001a8a:	85ca                	mv	a1,s2
    80001a8c:	8526                	mv	a0,s1
    80001a8e:	901ff0ef          	jal	8000138e <uvmfree>
}
    80001a92:	60e2                	ld	ra,24(sp)
    80001a94:	6442                	ld	s0,16(sp)
    80001a96:	64a2                	ld	s1,8(sp)
    80001a98:	6902                	ld	s2,0(sp)
    80001a9a:	6105                	addi	sp,sp,32
    80001a9c:	8082                	ret

0000000080001a9e <freeproc>:
{
    80001a9e:	1101                	addi	sp,sp,-32
    80001aa0:	ec06                	sd	ra,24(sp)
    80001aa2:	e822                	sd	s0,16(sp)
    80001aa4:	e426                	sd	s1,8(sp)
    80001aa6:	1000                	addi	s0,sp,32
    80001aa8:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001aaa:	6d28                	ld	a0,88(a0)
    80001aac:	c119                	beqz	a0,80001ab2 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001aae:	f6ffe0ef          	jal	80000a1c <kfree>
  p->trapframe = 0;
    80001ab2:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001ab6:	68a8                	ld	a0,80(s1)
    80001ab8:	c501                	beqz	a0,80001ac0 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001aba:	64ac                	ld	a1,72(s1)
    80001abc:	f9dff0ef          	jal	80001a58 <proc_freepagetable>
  p->pagetable = 0;
    80001ac0:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001ac4:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001ac8:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001acc:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001ad0:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001ad4:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001ad8:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001adc:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001ae0:	0004ac23          	sw	zero,24(s1)
}
    80001ae4:	60e2                	ld	ra,24(sp)
    80001ae6:	6442                	ld	s0,16(sp)
    80001ae8:	64a2                	ld	s1,8(sp)
    80001aea:	6105                	addi	sp,sp,32
    80001aec:	8082                	ret

0000000080001aee <allocproc>:
{
    80001aee:	1101                	addi	sp,sp,-32
    80001af0:	ec06                	sd	ra,24(sp)
    80001af2:	e822                	sd	s0,16(sp)
    80001af4:	e426                	sd	s1,8(sp)
    80001af6:	e04a                	sd	s2,0(sp)
    80001af8:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001afa:	00011497          	auipc	s1,0x11
    80001afe:	c0e48493          	addi	s1,s1,-1010 # 80012708 <proc>
    80001b02:	00016917          	auipc	s2,0x16
    80001b06:	60690913          	addi	s2,s2,1542 # 80018108 <tickslock>
    acquire(&p->lock);
    80001b0a:	8526                	mv	a0,s1
    80001b0c:	8c2ff0ef          	jal	80000bce <acquire>
    if(p->state == UNUSED) {
    80001b10:	4c9c                	lw	a5,24(s1)
    80001b12:	cb91                	beqz	a5,80001b26 <allocproc+0x38>
      release(&p->lock);
    80001b14:	8526                	mv	a0,s1
    80001b16:	950ff0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b1a:	16848493          	addi	s1,s1,360
    80001b1e:	ff2496e3          	bne	s1,s2,80001b0a <allocproc+0x1c>
  return 0;
    80001b22:	4481                	li	s1,0
    80001b24:	a089                	j	80001b66 <allocproc+0x78>
  p->pid = allocpid();
    80001b26:	e71ff0ef          	jal	80001996 <allocpid>
    80001b2a:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001b2c:	4785                	li	a5,1
    80001b2e:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001b30:	fcffe0ef          	jal	80000afe <kalloc>
    80001b34:	892a                	mv	s2,a0
    80001b36:	eca8                	sd	a0,88(s1)
    80001b38:	cd15                	beqz	a0,80001b74 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001b3a:	8526                	mv	a0,s1
    80001b3c:	e99ff0ef          	jal	800019d4 <proc_pagetable>
    80001b40:	892a                	mv	s2,a0
    80001b42:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001b44:	c121                	beqz	a0,80001b84 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001b46:	07000613          	li	a2,112
    80001b4a:	4581                	li	a1,0
    80001b4c:	06048513          	addi	a0,s1,96
    80001b50:	952ff0ef          	jal	80000ca2 <memset>
  p->context.ra = (uint64)forkret;
    80001b54:	00000797          	auipc	a5,0x0
    80001b58:	daa78793          	addi	a5,a5,-598 # 800018fe <forkret>
    80001b5c:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001b5e:	60bc                	ld	a5,64(s1)
    80001b60:	6705                	lui	a4,0x1
    80001b62:	97ba                	add	a5,a5,a4
    80001b64:	f4bc                	sd	a5,104(s1)
}
    80001b66:	8526                	mv	a0,s1
    80001b68:	60e2                	ld	ra,24(sp)
    80001b6a:	6442                	ld	s0,16(sp)
    80001b6c:	64a2                	ld	s1,8(sp)
    80001b6e:	6902                	ld	s2,0(sp)
    80001b70:	6105                	addi	sp,sp,32
    80001b72:	8082                	ret
    freeproc(p);
    80001b74:	8526                	mv	a0,s1
    80001b76:	f29ff0ef          	jal	80001a9e <freeproc>
    release(&p->lock);
    80001b7a:	8526                	mv	a0,s1
    80001b7c:	8eaff0ef          	jal	80000c66 <release>
    return 0;
    80001b80:	84ca                	mv	s1,s2
    80001b82:	b7d5                	j	80001b66 <allocproc+0x78>
    freeproc(p);
    80001b84:	8526                	mv	a0,s1
    80001b86:	f19ff0ef          	jal	80001a9e <freeproc>
    release(&p->lock);
    80001b8a:	8526                	mv	a0,s1
    80001b8c:	8daff0ef          	jal	80000c66 <release>
    return 0;
    80001b90:	84ca                	mv	s1,s2
    80001b92:	bfd1                	j	80001b66 <allocproc+0x78>

0000000080001b94 <userinit>:
{
    80001b94:	1101                	addi	sp,sp,-32
    80001b96:	ec06                	sd	ra,24(sp)
    80001b98:	e822                	sd	s0,16(sp)
    80001b9a:	e426                	sd	s1,8(sp)
    80001b9c:	1000                	addi	s0,sp,32
  p = allocproc();
    80001b9e:	f51ff0ef          	jal	80001aee <allocproc>
    80001ba2:	84aa                	mv	s1,a0
  initproc = p;
    80001ba4:	00008797          	auipc	a5,0x8
    80001ba8:	62a7b623          	sd	a0,1580(a5) # 8000a1d0 <initproc>
  p->cwd = namei("/");
    80001bac:	00005517          	auipc	a0,0x5
    80001bb0:	5e450513          	addi	a0,a0,1508 # 80007190 <etext+0x190>
    80001bb4:	67b010ef          	jal	80003a2e <namei>
    80001bb8:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001bbc:	478d                	li	a5,3
    80001bbe:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001bc0:	8526                	mv	a0,s1
    80001bc2:	8a4ff0ef          	jal	80000c66 <release>
}
    80001bc6:	60e2                	ld	ra,24(sp)
    80001bc8:	6442                	ld	s0,16(sp)
    80001bca:	64a2                	ld	s1,8(sp)
    80001bcc:	6105                	addi	sp,sp,32
    80001bce:	8082                	ret

0000000080001bd0 <growproc>:
{
    80001bd0:	1101                	addi	sp,sp,-32
    80001bd2:	ec06                	sd	ra,24(sp)
    80001bd4:	e822                	sd	s0,16(sp)
    80001bd6:	e426                	sd	s1,8(sp)
    80001bd8:	e04a                	sd	s2,0(sp)
    80001bda:	1000                	addi	s0,sp,32
    80001bdc:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001bde:	cf1ff0ef          	jal	800018ce <myproc>
    80001be2:	84aa                	mv	s1,a0
  sz = p->sz;
    80001be4:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001be6:	01204c63          	bgtz	s2,80001bfe <growproc+0x2e>
  } else if(n < 0){
    80001bea:	02094463          	bltz	s2,80001c12 <growproc+0x42>
  p->sz = sz;
    80001bee:	e4ac                	sd	a1,72(s1)
  return 0;
    80001bf0:	4501                	li	a0,0
}
    80001bf2:	60e2                	ld	ra,24(sp)
    80001bf4:	6442                	ld	s0,16(sp)
    80001bf6:	64a2                	ld	s1,8(sp)
    80001bf8:	6902                	ld	s2,0(sp)
    80001bfa:	6105                	addi	sp,sp,32
    80001bfc:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001bfe:	4691                	li	a3,4
    80001c00:	00b90633          	add	a2,s2,a1
    80001c04:	6928                	ld	a0,80(a0)
    80001c06:	e82ff0ef          	jal	80001288 <uvmalloc>
    80001c0a:	85aa                	mv	a1,a0
    80001c0c:	f16d                	bnez	a0,80001bee <growproc+0x1e>
      return -1;
    80001c0e:	557d                	li	a0,-1
    80001c10:	b7cd                	j	80001bf2 <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001c12:	00b90633          	add	a2,s2,a1
    80001c16:	6928                	ld	a0,80(a0)
    80001c18:	e2cff0ef          	jal	80001244 <uvmdealloc>
    80001c1c:	85aa                	mv	a1,a0
    80001c1e:	bfc1                	j	80001bee <growproc+0x1e>

0000000080001c20 <kfork>:
{
    80001c20:	7139                	addi	sp,sp,-64
    80001c22:	fc06                	sd	ra,56(sp)
    80001c24:	f822                	sd	s0,48(sp)
    80001c26:	f04a                	sd	s2,32(sp)
    80001c28:	e456                	sd	s5,8(sp)
    80001c2a:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001c2c:	ca3ff0ef          	jal	800018ce <myproc>
    80001c30:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001c32:	ebdff0ef          	jal	80001aee <allocproc>
    80001c36:	0e050a63          	beqz	a0,80001d2a <kfork+0x10a>
    80001c3a:	e852                	sd	s4,16(sp)
    80001c3c:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001c3e:	048ab603          	ld	a2,72(s5)
    80001c42:	692c                	ld	a1,80(a0)
    80001c44:	050ab503          	ld	a0,80(s5)
    80001c48:	f78ff0ef          	jal	800013c0 <uvmcopy>
    80001c4c:	04054a63          	bltz	a0,80001ca0 <kfork+0x80>
    80001c50:	f426                	sd	s1,40(sp)
    80001c52:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001c54:	048ab783          	ld	a5,72(s5)
    80001c58:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001c5c:	058ab683          	ld	a3,88(s5)
    80001c60:	87b6                	mv	a5,a3
    80001c62:	058a3703          	ld	a4,88(s4)
    80001c66:	12068693          	addi	a3,a3,288
    80001c6a:	0007b803          	ld	a6,0(a5)
    80001c6e:	6788                	ld	a0,8(a5)
    80001c70:	6b8c                	ld	a1,16(a5)
    80001c72:	6f90                	ld	a2,24(a5)
    80001c74:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80001c78:	e708                	sd	a0,8(a4)
    80001c7a:	eb0c                	sd	a1,16(a4)
    80001c7c:	ef10                	sd	a2,24(a4)
    80001c7e:	02078793          	addi	a5,a5,32
    80001c82:	02070713          	addi	a4,a4,32
    80001c86:	fed792e3          	bne	a5,a3,80001c6a <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001c8a:	058a3783          	ld	a5,88(s4)
    80001c8e:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001c92:	0d0a8493          	addi	s1,s5,208
    80001c96:	0d0a0913          	addi	s2,s4,208
    80001c9a:	150a8993          	addi	s3,s5,336
    80001c9e:	a831                	j	80001cba <kfork+0x9a>
    freeproc(np);
    80001ca0:	8552                	mv	a0,s4
    80001ca2:	dfdff0ef          	jal	80001a9e <freeproc>
    release(&np->lock);
    80001ca6:	8552                	mv	a0,s4
    80001ca8:	fbffe0ef          	jal	80000c66 <release>
    return -1;
    80001cac:	597d                	li	s2,-1
    80001cae:	6a42                	ld	s4,16(sp)
    80001cb0:	a0b5                	j	80001d1c <kfork+0xfc>
  for(i = 0; i < NOFILE; i++)
    80001cb2:	04a1                	addi	s1,s1,8
    80001cb4:	0921                	addi	s2,s2,8
    80001cb6:	01348963          	beq	s1,s3,80001cc8 <kfork+0xa8>
    if(p->ofile[i])
    80001cba:	6088                	ld	a0,0(s1)
    80001cbc:	d97d                	beqz	a0,80001cb2 <kfork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80001cbe:	30a020ef          	jal	80003fc8 <filedup>
    80001cc2:	00a93023          	sd	a0,0(s2)
    80001cc6:	b7f5                	j	80001cb2 <kfork+0x92>
  np->cwd = idup(p->cwd);
    80001cc8:	150ab503          	ld	a0,336(s5)
    80001ccc:	516010ef          	jal	800031e2 <idup>
    80001cd0:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001cd4:	4641                	li	a2,16
    80001cd6:	158a8593          	addi	a1,s5,344
    80001cda:	158a0513          	addi	a0,s4,344
    80001cde:	902ff0ef          	jal	80000de0 <safestrcpy>
  pid = np->pid;
    80001ce2:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001ce6:	8552                	mv	a0,s4
    80001ce8:	f7ffe0ef          	jal	80000c66 <release>
  acquire(&wait_lock);
    80001cec:	00010497          	auipc	s1,0x10
    80001cf0:	60448493          	addi	s1,s1,1540 # 800122f0 <wait_lock>
    80001cf4:	8526                	mv	a0,s1
    80001cf6:	ed9fe0ef          	jal	80000bce <acquire>
  np->parent = p;
    80001cfa:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001cfe:	8526                	mv	a0,s1
    80001d00:	f67fe0ef          	jal	80000c66 <release>
  acquire(&np->lock);
    80001d04:	8552                	mv	a0,s4
    80001d06:	ec9fe0ef          	jal	80000bce <acquire>
  np->state = RUNNABLE;
    80001d0a:	478d                	li	a5,3
    80001d0c:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001d10:	8552                	mv	a0,s4
    80001d12:	f55fe0ef          	jal	80000c66 <release>
  return pid;
    80001d16:	74a2                	ld	s1,40(sp)
    80001d18:	69e2                	ld	s3,24(sp)
    80001d1a:	6a42                	ld	s4,16(sp)
}
    80001d1c:	854a                	mv	a0,s2
    80001d1e:	70e2                	ld	ra,56(sp)
    80001d20:	7442                	ld	s0,48(sp)
    80001d22:	7902                	ld	s2,32(sp)
    80001d24:	6aa2                	ld	s5,8(sp)
    80001d26:	6121                	addi	sp,sp,64
    80001d28:	8082                	ret
    return -1;
    80001d2a:	597d                	li	s2,-1
    80001d2c:	bfc5                	j	80001d1c <kfork+0xfc>

0000000080001d2e <scheduler>:
{
    80001d2e:	715d                	addi	sp,sp,-80
    80001d30:	e486                	sd	ra,72(sp)
    80001d32:	e0a2                	sd	s0,64(sp)
    80001d34:	fc26                	sd	s1,56(sp)
    80001d36:	f84a                	sd	s2,48(sp)
    80001d38:	f44e                	sd	s3,40(sp)
    80001d3a:	f052                	sd	s4,32(sp)
    80001d3c:	ec56                	sd	s5,24(sp)
    80001d3e:	e85a                	sd	s6,16(sp)
    80001d40:	e45e                	sd	s7,8(sp)
    80001d42:	e062                	sd	s8,0(sp)
    80001d44:	0880                	addi	s0,sp,80
    80001d46:	8792                	mv	a5,tp
  int id = r_tp();
    80001d48:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001d4a:	00779b13          	slli	s6,a5,0x7
    80001d4e:	00010717          	auipc	a4,0x10
    80001d52:	58a70713          	addi	a4,a4,1418 # 800122d8 <pid_lock>
    80001d56:	975a                	add	a4,a4,s6
    80001d58:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001d5c:	00010717          	auipc	a4,0x10
    80001d60:	5b470713          	addi	a4,a4,1460 # 80012310 <cpus+0x8>
    80001d64:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001d66:	4c11                	li	s8,4
        c->proc = p;
    80001d68:	079e                	slli	a5,a5,0x7
    80001d6a:	00010a17          	auipc	s4,0x10
    80001d6e:	56ea0a13          	addi	s4,s4,1390 # 800122d8 <pid_lock>
    80001d72:	9a3e                	add	s4,s4,a5
        found = 1;
    80001d74:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d76:	00016997          	auipc	s3,0x16
    80001d7a:	39298993          	addi	s3,s3,914 # 80018108 <tickslock>
    80001d7e:	a83d                	j	80001dbc <scheduler+0x8e>
      release(&p->lock);
    80001d80:	8526                	mv	a0,s1
    80001d82:	ee5fe0ef          	jal	80000c66 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d86:	16848493          	addi	s1,s1,360
    80001d8a:	03348563          	beq	s1,s3,80001db4 <scheduler+0x86>
      acquire(&p->lock);
    80001d8e:	8526                	mv	a0,s1
    80001d90:	e3ffe0ef          	jal	80000bce <acquire>
      if(p->state == RUNNABLE) {
    80001d94:	4c9c                	lw	a5,24(s1)
    80001d96:	ff2795e3          	bne	a5,s2,80001d80 <scheduler+0x52>
        p->state = RUNNING;
    80001d9a:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001d9e:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001da2:	06048593          	addi	a1,s1,96
    80001da6:	855a                	mv	a0,s6
    80001da8:	5b2000ef          	jal	8000235a <swtch>
        c->proc = 0;
    80001dac:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001db0:	8ade                	mv	s5,s7
    80001db2:	b7f9                	j	80001d80 <scheduler+0x52>
    if(found == 0) {
    80001db4:	000a9463          	bnez	s5,80001dbc <scheduler+0x8e>
      asm volatile("wfi");
    80001db8:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001dbc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001dc0:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001dc4:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001dc8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001dcc:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001dce:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001dd2:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001dd4:	00011497          	auipc	s1,0x11
    80001dd8:	93448493          	addi	s1,s1,-1740 # 80012708 <proc>
      if(p->state == RUNNABLE) {
    80001ddc:	490d                	li	s2,3
    80001dde:	bf45                	j	80001d8e <scheduler+0x60>

0000000080001de0 <sched>:
{
    80001de0:	7179                	addi	sp,sp,-48
    80001de2:	f406                	sd	ra,40(sp)
    80001de4:	f022                	sd	s0,32(sp)
    80001de6:	ec26                	sd	s1,24(sp)
    80001de8:	e84a                	sd	s2,16(sp)
    80001dea:	e44e                	sd	s3,8(sp)
    80001dec:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001dee:	ae1ff0ef          	jal	800018ce <myproc>
    80001df2:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001df4:	d71fe0ef          	jal	80000b64 <holding>
    80001df8:	c92d                	beqz	a0,80001e6a <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001dfa:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001dfc:	2781                	sext.w	a5,a5
    80001dfe:	079e                	slli	a5,a5,0x7
    80001e00:	00010717          	auipc	a4,0x10
    80001e04:	4d870713          	addi	a4,a4,1240 # 800122d8 <pid_lock>
    80001e08:	97ba                	add	a5,a5,a4
    80001e0a:	0a87a703          	lw	a4,168(a5)
    80001e0e:	4785                	li	a5,1
    80001e10:	06f71363          	bne	a4,a5,80001e76 <sched+0x96>
  if(p->state == RUNNING)
    80001e14:	4c98                	lw	a4,24(s1)
    80001e16:	4791                	li	a5,4
    80001e18:	06f70563          	beq	a4,a5,80001e82 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e1c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e20:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001e22:	e7b5                	bnez	a5,80001e8e <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e24:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001e26:	00010917          	auipc	s2,0x10
    80001e2a:	4b290913          	addi	s2,s2,1202 # 800122d8 <pid_lock>
    80001e2e:	2781                	sext.w	a5,a5
    80001e30:	079e                	slli	a5,a5,0x7
    80001e32:	97ca                	add	a5,a5,s2
    80001e34:	0ac7a983          	lw	s3,172(a5)
    80001e38:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001e3a:	2781                	sext.w	a5,a5
    80001e3c:	079e                	slli	a5,a5,0x7
    80001e3e:	00010597          	auipc	a1,0x10
    80001e42:	4d258593          	addi	a1,a1,1234 # 80012310 <cpus+0x8>
    80001e46:	95be                	add	a1,a1,a5
    80001e48:	06048513          	addi	a0,s1,96
    80001e4c:	50e000ef          	jal	8000235a <swtch>
    80001e50:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001e52:	2781                	sext.w	a5,a5
    80001e54:	079e                	slli	a5,a5,0x7
    80001e56:	993e                	add	s2,s2,a5
    80001e58:	0b392623          	sw	s3,172(s2)
}
    80001e5c:	70a2                	ld	ra,40(sp)
    80001e5e:	7402                	ld	s0,32(sp)
    80001e60:	64e2                	ld	s1,24(sp)
    80001e62:	6942                	ld	s2,16(sp)
    80001e64:	69a2                	ld	s3,8(sp)
    80001e66:	6145                	addi	sp,sp,48
    80001e68:	8082                	ret
    panic("sched p->lock");
    80001e6a:	00005517          	auipc	a0,0x5
    80001e6e:	32e50513          	addi	a0,a0,814 # 80007198 <etext+0x198>
    80001e72:	96ffe0ef          	jal	800007e0 <panic>
    panic("sched locks");
    80001e76:	00005517          	auipc	a0,0x5
    80001e7a:	33250513          	addi	a0,a0,818 # 800071a8 <etext+0x1a8>
    80001e7e:	963fe0ef          	jal	800007e0 <panic>
    panic("sched RUNNING");
    80001e82:	00005517          	auipc	a0,0x5
    80001e86:	33650513          	addi	a0,a0,822 # 800071b8 <etext+0x1b8>
    80001e8a:	957fe0ef          	jal	800007e0 <panic>
    panic("sched interruptible");
    80001e8e:	00005517          	auipc	a0,0x5
    80001e92:	33a50513          	addi	a0,a0,826 # 800071c8 <etext+0x1c8>
    80001e96:	94bfe0ef          	jal	800007e0 <panic>

0000000080001e9a <yield>:
{
    80001e9a:	1101                	addi	sp,sp,-32
    80001e9c:	ec06                	sd	ra,24(sp)
    80001e9e:	e822                	sd	s0,16(sp)
    80001ea0:	e426                	sd	s1,8(sp)
    80001ea2:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001ea4:	a2bff0ef          	jal	800018ce <myproc>
    80001ea8:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001eaa:	d25fe0ef          	jal	80000bce <acquire>
  p->state = RUNNABLE;
    80001eae:	478d                	li	a5,3
    80001eb0:	cc9c                	sw	a5,24(s1)
  sched();
    80001eb2:	f2fff0ef          	jal	80001de0 <sched>
  release(&p->lock);
    80001eb6:	8526                	mv	a0,s1
    80001eb8:	daffe0ef          	jal	80000c66 <release>
}
    80001ebc:	60e2                	ld	ra,24(sp)
    80001ebe:	6442                	ld	s0,16(sp)
    80001ec0:	64a2                	ld	s1,8(sp)
    80001ec2:	6105                	addi	sp,sp,32
    80001ec4:	8082                	ret

0000000080001ec6 <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001ec6:	7179                	addi	sp,sp,-48
    80001ec8:	f406                	sd	ra,40(sp)
    80001eca:	f022                	sd	s0,32(sp)
    80001ecc:	ec26                	sd	s1,24(sp)
    80001ece:	e84a                	sd	s2,16(sp)
    80001ed0:	e44e                	sd	s3,8(sp)
    80001ed2:	1800                	addi	s0,sp,48
    80001ed4:	89aa                	mv	s3,a0
    80001ed6:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001ed8:	9f7ff0ef          	jal	800018ce <myproc>
    80001edc:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001ede:	cf1fe0ef          	jal	80000bce <acquire>
  release(lk);
    80001ee2:	854a                	mv	a0,s2
    80001ee4:	d83fe0ef          	jal	80000c66 <release>

  // Go to sleep.
  p->chan = chan;
    80001ee8:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001eec:	4789                	li	a5,2
    80001eee:	cc9c                	sw	a5,24(s1)

  sched();
    80001ef0:	ef1ff0ef          	jal	80001de0 <sched>

  // Tidy up.
  p->chan = 0;
    80001ef4:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001ef8:	8526                	mv	a0,s1
    80001efa:	d6dfe0ef          	jal	80000c66 <release>
  acquire(lk);
    80001efe:	854a                	mv	a0,s2
    80001f00:	ccffe0ef          	jal	80000bce <acquire>
}
    80001f04:	70a2                	ld	ra,40(sp)
    80001f06:	7402                	ld	s0,32(sp)
    80001f08:	64e2                	ld	s1,24(sp)
    80001f0a:	6942                	ld	s2,16(sp)
    80001f0c:	69a2                	ld	s3,8(sp)
    80001f0e:	6145                	addi	sp,sp,48
    80001f10:	8082                	ret

0000000080001f12 <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    80001f12:	7139                	addi	sp,sp,-64
    80001f14:	fc06                	sd	ra,56(sp)
    80001f16:	f822                	sd	s0,48(sp)
    80001f18:	f426                	sd	s1,40(sp)
    80001f1a:	f04a                	sd	s2,32(sp)
    80001f1c:	ec4e                	sd	s3,24(sp)
    80001f1e:	e852                	sd	s4,16(sp)
    80001f20:	e456                	sd	s5,8(sp)
    80001f22:	0080                	addi	s0,sp,64
    80001f24:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001f26:	00010497          	auipc	s1,0x10
    80001f2a:	7e248493          	addi	s1,s1,2018 # 80012708 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001f2e:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001f30:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f32:	00016917          	auipc	s2,0x16
    80001f36:	1d690913          	addi	s2,s2,470 # 80018108 <tickslock>
    80001f3a:	a801                	j	80001f4a <wakeup+0x38>
      }
      release(&p->lock);
    80001f3c:	8526                	mv	a0,s1
    80001f3e:	d29fe0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f42:	16848493          	addi	s1,s1,360
    80001f46:	03248263          	beq	s1,s2,80001f6a <wakeup+0x58>
    if(p != myproc()){
    80001f4a:	985ff0ef          	jal	800018ce <myproc>
    80001f4e:	fea48ae3          	beq	s1,a0,80001f42 <wakeup+0x30>
      acquire(&p->lock);
    80001f52:	8526                	mv	a0,s1
    80001f54:	c7bfe0ef          	jal	80000bce <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001f58:	4c9c                	lw	a5,24(s1)
    80001f5a:	ff3791e3          	bne	a5,s3,80001f3c <wakeup+0x2a>
    80001f5e:	709c                	ld	a5,32(s1)
    80001f60:	fd479ee3          	bne	a5,s4,80001f3c <wakeup+0x2a>
        p->state = RUNNABLE;
    80001f64:	0154ac23          	sw	s5,24(s1)
    80001f68:	bfd1                	j	80001f3c <wakeup+0x2a>
    }
  }
}
    80001f6a:	70e2                	ld	ra,56(sp)
    80001f6c:	7442                	ld	s0,48(sp)
    80001f6e:	74a2                	ld	s1,40(sp)
    80001f70:	7902                	ld	s2,32(sp)
    80001f72:	69e2                	ld	s3,24(sp)
    80001f74:	6a42                	ld	s4,16(sp)
    80001f76:	6aa2                	ld	s5,8(sp)
    80001f78:	6121                	addi	sp,sp,64
    80001f7a:	8082                	ret

0000000080001f7c <reparent>:
{
    80001f7c:	7179                	addi	sp,sp,-48
    80001f7e:	f406                	sd	ra,40(sp)
    80001f80:	f022                	sd	s0,32(sp)
    80001f82:	ec26                	sd	s1,24(sp)
    80001f84:	e84a                	sd	s2,16(sp)
    80001f86:	e44e                	sd	s3,8(sp)
    80001f88:	e052                	sd	s4,0(sp)
    80001f8a:	1800                	addi	s0,sp,48
    80001f8c:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f8e:	00010497          	auipc	s1,0x10
    80001f92:	77a48493          	addi	s1,s1,1914 # 80012708 <proc>
      pp->parent = initproc;
    80001f96:	00008a17          	auipc	s4,0x8
    80001f9a:	23aa0a13          	addi	s4,s4,570 # 8000a1d0 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f9e:	00016997          	auipc	s3,0x16
    80001fa2:	16a98993          	addi	s3,s3,362 # 80018108 <tickslock>
    80001fa6:	a029                	j	80001fb0 <reparent+0x34>
    80001fa8:	16848493          	addi	s1,s1,360
    80001fac:	01348b63          	beq	s1,s3,80001fc2 <reparent+0x46>
    if(pp->parent == p){
    80001fb0:	7c9c                	ld	a5,56(s1)
    80001fb2:	ff279be3          	bne	a5,s2,80001fa8 <reparent+0x2c>
      pp->parent = initproc;
    80001fb6:	000a3503          	ld	a0,0(s4)
    80001fba:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80001fbc:	f57ff0ef          	jal	80001f12 <wakeup>
    80001fc0:	b7e5                	j	80001fa8 <reparent+0x2c>
}
    80001fc2:	70a2                	ld	ra,40(sp)
    80001fc4:	7402                	ld	s0,32(sp)
    80001fc6:	64e2                	ld	s1,24(sp)
    80001fc8:	6942                	ld	s2,16(sp)
    80001fca:	69a2                	ld	s3,8(sp)
    80001fcc:	6a02                	ld	s4,0(sp)
    80001fce:	6145                	addi	sp,sp,48
    80001fd0:	8082                	ret

0000000080001fd2 <kexit>:
{
    80001fd2:	7179                	addi	sp,sp,-48
    80001fd4:	f406                	sd	ra,40(sp)
    80001fd6:	f022                	sd	s0,32(sp)
    80001fd8:	ec26                	sd	s1,24(sp)
    80001fda:	e84a                	sd	s2,16(sp)
    80001fdc:	e44e                	sd	s3,8(sp)
    80001fde:	e052                	sd	s4,0(sp)
    80001fe0:	1800                	addi	s0,sp,48
    80001fe2:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80001fe4:	8ebff0ef          	jal	800018ce <myproc>
    80001fe8:	89aa                	mv	s3,a0
  if(p == initproc)
    80001fea:	00008797          	auipc	a5,0x8
    80001fee:	1e67b783          	ld	a5,486(a5) # 8000a1d0 <initproc>
    80001ff2:	0d050493          	addi	s1,a0,208
    80001ff6:	15050913          	addi	s2,a0,336
    80001ffa:	00a79f63          	bne	a5,a0,80002018 <kexit+0x46>
    panic("init exiting");
    80001ffe:	00005517          	auipc	a0,0x5
    80002002:	1e250513          	addi	a0,a0,482 # 800071e0 <etext+0x1e0>
    80002006:	fdafe0ef          	jal	800007e0 <panic>
      fileclose(f);
    8000200a:	004020ef          	jal	8000400e <fileclose>
      p->ofile[fd] = 0;
    8000200e:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002012:	04a1                	addi	s1,s1,8
    80002014:	01248563          	beq	s1,s2,8000201e <kexit+0x4c>
    if(p->ofile[fd]){
    80002018:	6088                	ld	a0,0(s1)
    8000201a:	f965                	bnez	a0,8000200a <kexit+0x38>
    8000201c:	bfdd                	j	80002012 <kexit+0x40>
  begin_op();
    8000201e:	3e5010ef          	jal	80003c02 <begin_op>
  iput(p->cwd);
    80002022:	1509b503          	ld	a0,336(s3)
    80002026:	374010ef          	jal	8000339a <iput>
  end_op();
    8000202a:	443010ef          	jal	80003c6c <end_op>
  p->cwd = 0;
    8000202e:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002032:	00010497          	auipc	s1,0x10
    80002036:	2be48493          	addi	s1,s1,702 # 800122f0 <wait_lock>
    8000203a:	8526                	mv	a0,s1
    8000203c:	b93fe0ef          	jal	80000bce <acquire>
  reparent(p);
    80002040:	854e                	mv	a0,s3
    80002042:	f3bff0ef          	jal	80001f7c <reparent>
  wakeup(p->parent);
    80002046:	0389b503          	ld	a0,56(s3)
    8000204a:	ec9ff0ef          	jal	80001f12 <wakeup>
  acquire(&p->lock);
    8000204e:	854e                	mv	a0,s3
    80002050:	b7ffe0ef          	jal	80000bce <acquire>
  p->xstate = status;
    80002054:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002058:	4795                	li	a5,5
    8000205a:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000205e:	8526                	mv	a0,s1
    80002060:	c07fe0ef          	jal	80000c66 <release>
  sched();
    80002064:	d7dff0ef          	jal	80001de0 <sched>
  panic("zombie exit");
    80002068:	00005517          	auipc	a0,0x5
    8000206c:	18850513          	addi	a0,a0,392 # 800071f0 <etext+0x1f0>
    80002070:	f70fe0ef          	jal	800007e0 <panic>

0000000080002074 <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    80002074:	7179                	addi	sp,sp,-48
    80002076:	f406                	sd	ra,40(sp)
    80002078:	f022                	sd	s0,32(sp)
    8000207a:	ec26                	sd	s1,24(sp)
    8000207c:	e84a                	sd	s2,16(sp)
    8000207e:	e44e                	sd	s3,8(sp)
    80002080:	1800                	addi	s0,sp,48
    80002082:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002084:	00010497          	auipc	s1,0x10
    80002088:	68448493          	addi	s1,s1,1668 # 80012708 <proc>
    8000208c:	00016997          	auipc	s3,0x16
    80002090:	07c98993          	addi	s3,s3,124 # 80018108 <tickslock>
    acquire(&p->lock);
    80002094:	8526                	mv	a0,s1
    80002096:	b39fe0ef          	jal	80000bce <acquire>
    if(p->pid == pid){
    8000209a:	589c                	lw	a5,48(s1)
    8000209c:	01278b63          	beq	a5,s2,800020b2 <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800020a0:	8526                	mv	a0,s1
    800020a2:	bc5fe0ef          	jal	80000c66 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800020a6:	16848493          	addi	s1,s1,360
    800020aa:	ff3495e3          	bne	s1,s3,80002094 <kkill+0x20>
  }
  return -1;
    800020ae:	557d                	li	a0,-1
    800020b0:	a819                	j	800020c6 <kkill+0x52>
      p->killed = 1;
    800020b2:	4785                	li	a5,1
    800020b4:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800020b6:	4c98                	lw	a4,24(s1)
    800020b8:	4789                	li	a5,2
    800020ba:	00f70d63          	beq	a4,a5,800020d4 <kkill+0x60>
      release(&p->lock);
    800020be:	8526                	mv	a0,s1
    800020c0:	ba7fe0ef          	jal	80000c66 <release>
      return 0;
    800020c4:	4501                	li	a0,0
}
    800020c6:	70a2                	ld	ra,40(sp)
    800020c8:	7402                	ld	s0,32(sp)
    800020ca:	64e2                	ld	s1,24(sp)
    800020cc:	6942                	ld	s2,16(sp)
    800020ce:	69a2                	ld	s3,8(sp)
    800020d0:	6145                	addi	sp,sp,48
    800020d2:	8082                	ret
        p->state = RUNNABLE;
    800020d4:	478d                	li	a5,3
    800020d6:	cc9c                	sw	a5,24(s1)
    800020d8:	b7dd                	j	800020be <kkill+0x4a>

00000000800020da <setkilled>:

void
setkilled(struct proc *p)
{
    800020da:	1101                	addi	sp,sp,-32
    800020dc:	ec06                	sd	ra,24(sp)
    800020de:	e822                	sd	s0,16(sp)
    800020e0:	e426                	sd	s1,8(sp)
    800020e2:	1000                	addi	s0,sp,32
    800020e4:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020e6:	ae9fe0ef          	jal	80000bce <acquire>
  p->killed = 1;
    800020ea:	4785                	li	a5,1
    800020ec:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800020ee:	8526                	mv	a0,s1
    800020f0:	b77fe0ef          	jal	80000c66 <release>
}
    800020f4:	60e2                	ld	ra,24(sp)
    800020f6:	6442                	ld	s0,16(sp)
    800020f8:	64a2                	ld	s1,8(sp)
    800020fa:	6105                	addi	sp,sp,32
    800020fc:	8082                	ret

00000000800020fe <killed>:

int
killed(struct proc *p)
{
    800020fe:	1101                	addi	sp,sp,-32
    80002100:	ec06                	sd	ra,24(sp)
    80002102:	e822                	sd	s0,16(sp)
    80002104:	e426                	sd	s1,8(sp)
    80002106:	e04a                	sd	s2,0(sp)
    80002108:	1000                	addi	s0,sp,32
    8000210a:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    8000210c:	ac3fe0ef          	jal	80000bce <acquire>
  k = p->killed;
    80002110:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002114:	8526                	mv	a0,s1
    80002116:	b51fe0ef          	jal	80000c66 <release>
  return k;
}
    8000211a:	854a                	mv	a0,s2
    8000211c:	60e2                	ld	ra,24(sp)
    8000211e:	6442                	ld	s0,16(sp)
    80002120:	64a2                	ld	s1,8(sp)
    80002122:	6902                	ld	s2,0(sp)
    80002124:	6105                	addi	sp,sp,32
    80002126:	8082                	ret

0000000080002128 <kwait>:
{
    80002128:	715d                	addi	sp,sp,-80
    8000212a:	e486                	sd	ra,72(sp)
    8000212c:	e0a2                	sd	s0,64(sp)
    8000212e:	fc26                	sd	s1,56(sp)
    80002130:	f84a                	sd	s2,48(sp)
    80002132:	f44e                	sd	s3,40(sp)
    80002134:	f052                	sd	s4,32(sp)
    80002136:	ec56                	sd	s5,24(sp)
    80002138:	e85a                	sd	s6,16(sp)
    8000213a:	e45e                	sd	s7,8(sp)
    8000213c:	e062                	sd	s8,0(sp)
    8000213e:	0880                	addi	s0,sp,80
    80002140:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002142:	f8cff0ef          	jal	800018ce <myproc>
    80002146:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002148:	00010517          	auipc	a0,0x10
    8000214c:	1a850513          	addi	a0,a0,424 # 800122f0 <wait_lock>
    80002150:	a7ffe0ef          	jal	80000bce <acquire>
    havekids = 0;
    80002154:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002156:	4a15                	li	s4,5
        havekids = 1;
    80002158:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000215a:	00016997          	auipc	s3,0x16
    8000215e:	fae98993          	addi	s3,s3,-82 # 80018108 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002162:	00010c17          	auipc	s8,0x10
    80002166:	18ec0c13          	addi	s8,s8,398 # 800122f0 <wait_lock>
    8000216a:	a871                	j	80002206 <kwait+0xde>
          pid = pp->pid;
    8000216c:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002170:	000b0c63          	beqz	s6,80002188 <kwait+0x60>
    80002174:	4691                	li	a3,4
    80002176:	02c48613          	addi	a2,s1,44
    8000217a:	85da                	mv	a1,s6
    8000217c:	05093503          	ld	a0,80(s2)
    80002180:	c62ff0ef          	jal	800015e2 <copyout>
    80002184:	02054b63          	bltz	a0,800021ba <kwait+0x92>
          freeproc(pp);
    80002188:	8526                	mv	a0,s1
    8000218a:	915ff0ef          	jal	80001a9e <freeproc>
          release(&pp->lock);
    8000218e:	8526                	mv	a0,s1
    80002190:	ad7fe0ef          	jal	80000c66 <release>
          release(&wait_lock);
    80002194:	00010517          	auipc	a0,0x10
    80002198:	15c50513          	addi	a0,a0,348 # 800122f0 <wait_lock>
    8000219c:	acbfe0ef          	jal	80000c66 <release>
}
    800021a0:	854e                	mv	a0,s3
    800021a2:	60a6                	ld	ra,72(sp)
    800021a4:	6406                	ld	s0,64(sp)
    800021a6:	74e2                	ld	s1,56(sp)
    800021a8:	7942                	ld	s2,48(sp)
    800021aa:	79a2                	ld	s3,40(sp)
    800021ac:	7a02                	ld	s4,32(sp)
    800021ae:	6ae2                	ld	s5,24(sp)
    800021b0:	6b42                	ld	s6,16(sp)
    800021b2:	6ba2                	ld	s7,8(sp)
    800021b4:	6c02                	ld	s8,0(sp)
    800021b6:	6161                	addi	sp,sp,80
    800021b8:	8082                	ret
            release(&pp->lock);
    800021ba:	8526                	mv	a0,s1
    800021bc:	aabfe0ef          	jal	80000c66 <release>
            release(&wait_lock);
    800021c0:	00010517          	auipc	a0,0x10
    800021c4:	13050513          	addi	a0,a0,304 # 800122f0 <wait_lock>
    800021c8:	a9ffe0ef          	jal	80000c66 <release>
            return -1;
    800021cc:	59fd                	li	s3,-1
    800021ce:	bfc9                	j	800021a0 <kwait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800021d0:	16848493          	addi	s1,s1,360
    800021d4:	03348063          	beq	s1,s3,800021f4 <kwait+0xcc>
      if(pp->parent == p){
    800021d8:	7c9c                	ld	a5,56(s1)
    800021da:	ff279be3          	bne	a5,s2,800021d0 <kwait+0xa8>
        acquire(&pp->lock);
    800021de:	8526                	mv	a0,s1
    800021e0:	9effe0ef          	jal	80000bce <acquire>
        if(pp->state == ZOMBIE){
    800021e4:	4c9c                	lw	a5,24(s1)
    800021e6:	f94783e3          	beq	a5,s4,8000216c <kwait+0x44>
        release(&pp->lock);
    800021ea:	8526                	mv	a0,s1
    800021ec:	a7bfe0ef          	jal	80000c66 <release>
        havekids = 1;
    800021f0:	8756                	mv	a4,s5
    800021f2:	bff9                	j	800021d0 <kwait+0xa8>
    if(!havekids || killed(p)){
    800021f4:	cf19                	beqz	a4,80002212 <kwait+0xea>
    800021f6:	854a                	mv	a0,s2
    800021f8:	f07ff0ef          	jal	800020fe <killed>
    800021fc:	e919                	bnez	a0,80002212 <kwait+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800021fe:	85e2                	mv	a1,s8
    80002200:	854a                	mv	a0,s2
    80002202:	cc5ff0ef          	jal	80001ec6 <sleep>
    havekids = 0;
    80002206:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002208:	00010497          	auipc	s1,0x10
    8000220c:	50048493          	addi	s1,s1,1280 # 80012708 <proc>
    80002210:	b7e1                	j	800021d8 <kwait+0xb0>
      release(&wait_lock);
    80002212:	00010517          	auipc	a0,0x10
    80002216:	0de50513          	addi	a0,a0,222 # 800122f0 <wait_lock>
    8000221a:	a4dfe0ef          	jal	80000c66 <release>
      return -1;
    8000221e:	59fd                	li	s3,-1
    80002220:	b741                	j	800021a0 <kwait+0x78>

0000000080002222 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002222:	7179                	addi	sp,sp,-48
    80002224:	f406                	sd	ra,40(sp)
    80002226:	f022                	sd	s0,32(sp)
    80002228:	ec26                	sd	s1,24(sp)
    8000222a:	e84a                	sd	s2,16(sp)
    8000222c:	e44e                	sd	s3,8(sp)
    8000222e:	e052                	sd	s4,0(sp)
    80002230:	1800                	addi	s0,sp,48
    80002232:	84aa                	mv	s1,a0
    80002234:	892e                	mv	s2,a1
    80002236:	89b2                	mv	s3,a2
    80002238:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000223a:	e94ff0ef          	jal	800018ce <myproc>
  if(user_dst){
    8000223e:	cc99                	beqz	s1,8000225c <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80002240:	86d2                	mv	a3,s4
    80002242:	864e                	mv	a2,s3
    80002244:	85ca                	mv	a1,s2
    80002246:	6928                	ld	a0,80(a0)
    80002248:	b9aff0ef          	jal	800015e2 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000224c:	70a2                	ld	ra,40(sp)
    8000224e:	7402                	ld	s0,32(sp)
    80002250:	64e2                	ld	s1,24(sp)
    80002252:	6942                	ld	s2,16(sp)
    80002254:	69a2                	ld	s3,8(sp)
    80002256:	6a02                	ld	s4,0(sp)
    80002258:	6145                	addi	sp,sp,48
    8000225a:	8082                	ret
    memmove((char *)dst, src, len);
    8000225c:	000a061b          	sext.w	a2,s4
    80002260:	85ce                	mv	a1,s3
    80002262:	854a                	mv	a0,s2
    80002264:	a9bfe0ef          	jal	80000cfe <memmove>
    return 0;
    80002268:	8526                	mv	a0,s1
    8000226a:	b7cd                	j	8000224c <either_copyout+0x2a>

000000008000226c <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000226c:	7179                	addi	sp,sp,-48
    8000226e:	f406                	sd	ra,40(sp)
    80002270:	f022                	sd	s0,32(sp)
    80002272:	ec26                	sd	s1,24(sp)
    80002274:	e84a                	sd	s2,16(sp)
    80002276:	e44e                	sd	s3,8(sp)
    80002278:	e052                	sd	s4,0(sp)
    8000227a:	1800                	addi	s0,sp,48
    8000227c:	892a                	mv	s2,a0
    8000227e:	84ae                	mv	s1,a1
    80002280:	89b2                	mv	s3,a2
    80002282:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002284:	e4aff0ef          	jal	800018ce <myproc>
  if(user_src){
    80002288:	cc99                	beqz	s1,800022a6 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    8000228a:	86d2                	mv	a3,s4
    8000228c:	864e                	mv	a2,s3
    8000228e:	85ca                	mv	a1,s2
    80002290:	6928                	ld	a0,80(a0)
    80002292:	c34ff0ef          	jal	800016c6 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002296:	70a2                	ld	ra,40(sp)
    80002298:	7402                	ld	s0,32(sp)
    8000229a:	64e2                	ld	s1,24(sp)
    8000229c:	6942                	ld	s2,16(sp)
    8000229e:	69a2                	ld	s3,8(sp)
    800022a0:	6a02                	ld	s4,0(sp)
    800022a2:	6145                	addi	sp,sp,48
    800022a4:	8082                	ret
    memmove(dst, (char*)src, len);
    800022a6:	000a061b          	sext.w	a2,s4
    800022aa:	85ce                	mv	a1,s3
    800022ac:	854a                	mv	a0,s2
    800022ae:	a51fe0ef          	jal	80000cfe <memmove>
    return 0;
    800022b2:	8526                	mv	a0,s1
    800022b4:	b7cd                	j	80002296 <either_copyin+0x2a>

00000000800022b6 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800022b6:	715d                	addi	sp,sp,-80
    800022b8:	e486                	sd	ra,72(sp)
    800022ba:	e0a2                	sd	s0,64(sp)
    800022bc:	fc26                	sd	s1,56(sp)
    800022be:	f84a                	sd	s2,48(sp)
    800022c0:	f44e                	sd	s3,40(sp)
    800022c2:	f052                	sd	s4,32(sp)
    800022c4:	ec56                	sd	s5,24(sp)
    800022c6:	e85a                	sd	s6,16(sp)
    800022c8:	e45e                	sd	s7,8(sp)
    800022ca:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800022cc:	00005517          	auipc	a0,0x5
    800022d0:	dac50513          	addi	a0,a0,-596 # 80007078 <etext+0x78>
    800022d4:	a26fe0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800022d8:	00010497          	auipc	s1,0x10
    800022dc:	58848493          	addi	s1,s1,1416 # 80012860 <proc+0x158>
    800022e0:	00016917          	auipc	s2,0x16
    800022e4:	f8090913          	addi	s2,s2,-128 # 80018260 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800022e8:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800022ea:	00005997          	auipc	s3,0x5
    800022ee:	f1698993          	addi	s3,s3,-234 # 80007200 <etext+0x200>
    printf("%d %s %s", p->pid, state, p->name);
    800022f2:	00005a97          	auipc	s5,0x5
    800022f6:	f16a8a93          	addi	s5,s5,-234 # 80007208 <etext+0x208>
    printf("\n");
    800022fa:	00005a17          	auipc	s4,0x5
    800022fe:	d7ea0a13          	addi	s4,s4,-642 # 80007078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002302:	00005b97          	auipc	s7,0x5
    80002306:	426b8b93          	addi	s7,s7,1062 # 80007728 <states.0>
    8000230a:	a829                	j	80002324 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    8000230c:	ed86a583          	lw	a1,-296(a3)
    80002310:	8556                	mv	a0,s5
    80002312:	9e8fe0ef          	jal	800004fa <printf>
    printf("\n");
    80002316:	8552                	mv	a0,s4
    80002318:	9e2fe0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000231c:	16848493          	addi	s1,s1,360
    80002320:	03248263          	beq	s1,s2,80002344 <procdump+0x8e>
    if(p->state == UNUSED)
    80002324:	86a6                	mv	a3,s1
    80002326:	ec04a783          	lw	a5,-320(s1)
    8000232a:	dbed                	beqz	a5,8000231c <procdump+0x66>
      state = "???";
    8000232c:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000232e:	fcfb6fe3          	bltu	s6,a5,8000230c <procdump+0x56>
    80002332:	02079713          	slli	a4,a5,0x20
    80002336:	01d75793          	srli	a5,a4,0x1d
    8000233a:	97de                	add	a5,a5,s7
    8000233c:	6390                	ld	a2,0(a5)
    8000233e:	f679                	bnez	a2,8000230c <procdump+0x56>
      state = "???";
    80002340:	864e                	mv	a2,s3
    80002342:	b7e9                	j	8000230c <procdump+0x56>
  }
}
    80002344:	60a6                	ld	ra,72(sp)
    80002346:	6406                	ld	s0,64(sp)
    80002348:	74e2                	ld	s1,56(sp)
    8000234a:	7942                	ld	s2,48(sp)
    8000234c:	79a2                	ld	s3,40(sp)
    8000234e:	7a02                	ld	s4,32(sp)
    80002350:	6ae2                	ld	s5,24(sp)
    80002352:	6b42                	ld	s6,16(sp)
    80002354:	6ba2                	ld	s7,8(sp)
    80002356:	6161                	addi	sp,sp,80
    80002358:	8082                	ret

000000008000235a <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    8000235a:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    8000235e:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    80002362:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    80002364:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    80002366:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    8000236a:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    8000236e:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    80002372:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    80002376:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    8000237a:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    8000237e:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    80002382:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002386:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    8000238a:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    8000238e:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    80002392:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    80002396:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    80002398:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    8000239a:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    8000239e:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    800023a2:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    800023a6:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    800023aa:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    800023ae:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    800023b2:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    800023b6:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    800023ba:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    800023be:	0685bd83          	ld	s11,104(a1)
        
        ret
    800023c2:	8082                	ret

00000000800023c4 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800023c4:	1141                	addi	sp,sp,-16
    800023c6:	e406                	sd	ra,8(sp)
    800023c8:	e022                	sd	s0,0(sp)
    800023ca:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800023cc:	00005597          	auipc	a1,0x5
    800023d0:	e7c58593          	addi	a1,a1,-388 # 80007248 <etext+0x248>
    800023d4:	00016517          	auipc	a0,0x16
    800023d8:	d3450513          	addi	a0,a0,-716 # 80018108 <tickslock>
    800023dc:	f72fe0ef          	jal	80000b4e <initlock>
}
    800023e0:	60a2                	ld	ra,8(sp)
    800023e2:	6402                	ld	s0,0(sp)
    800023e4:	0141                	addi	sp,sp,16
    800023e6:	8082                	ret

00000000800023e8 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800023e8:	1141                	addi	sp,sp,-16
    800023ea:	e422                	sd	s0,8(sp)
    800023ec:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800023ee:	00003797          	auipc	a5,0x3
    800023f2:	f9278793          	addi	a5,a5,-110 # 80005380 <kernelvec>
    800023f6:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800023fa:	6422                	ld	s0,8(sp)
    800023fc:	0141                	addi	sp,sp,16
    800023fe:	8082                	ret

0000000080002400 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80002400:	1141                	addi	sp,sp,-16
    80002402:	e406                	sd	ra,8(sp)
    80002404:	e022                	sd	s0,0(sp)
    80002406:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002408:	cc6ff0ef          	jal	800018ce <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000240c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002410:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002412:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002416:	04000737          	lui	a4,0x4000
    8000241a:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    8000241c:	0732                	slli	a4,a4,0xc
    8000241e:	00004797          	auipc	a5,0x4
    80002422:	be278793          	addi	a5,a5,-1054 # 80006000 <_trampoline>
    80002426:	00004697          	auipc	a3,0x4
    8000242a:	bda68693          	addi	a3,a3,-1062 # 80006000 <_trampoline>
    8000242e:	8f95                	sub	a5,a5,a3
    80002430:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002432:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002436:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002438:	18002773          	csrr	a4,satp
    8000243c:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000243e:	6d38                	ld	a4,88(a0)
    80002440:	613c                	ld	a5,64(a0)
    80002442:	6685                	lui	a3,0x1
    80002444:	97b6                	add	a5,a5,a3
    80002446:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002448:	6d3c                	ld	a5,88(a0)
    8000244a:	00000717          	auipc	a4,0x0
    8000244e:	0f870713          	addi	a4,a4,248 # 80002542 <usertrap>
    80002452:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002454:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002456:	8712                	mv	a4,tp
    80002458:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000245a:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000245e:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002462:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002466:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000246a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000246c:	6f9c                	ld	a5,24(a5)
    8000246e:	14179073          	csrw	sepc,a5
}
    80002472:	60a2                	ld	ra,8(sp)
    80002474:	6402                	ld	s0,0(sp)
    80002476:	0141                	addi	sp,sp,16
    80002478:	8082                	ret

000000008000247a <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000247a:	1101                	addi	sp,sp,-32
    8000247c:	ec06                	sd	ra,24(sp)
    8000247e:	e822                	sd	s0,16(sp)
    80002480:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80002482:	c20ff0ef          	jal	800018a2 <cpuid>
    80002486:	cd11                	beqz	a0,800024a2 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002488:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    8000248c:	000f4737          	lui	a4,0xf4
    80002490:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002494:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80002496:	14d79073          	csrw	stimecmp,a5
}
    8000249a:	60e2                	ld	ra,24(sp)
    8000249c:	6442                	ld	s0,16(sp)
    8000249e:	6105                	addi	sp,sp,32
    800024a0:	8082                	ret
    800024a2:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    800024a4:	00016497          	auipc	s1,0x16
    800024a8:	c6448493          	addi	s1,s1,-924 # 80018108 <tickslock>
    800024ac:	8526                	mv	a0,s1
    800024ae:	f20fe0ef          	jal	80000bce <acquire>
    ticks++;
    800024b2:	00008517          	auipc	a0,0x8
    800024b6:	d2650513          	addi	a0,a0,-730 # 8000a1d8 <ticks>
    800024ba:	411c                	lw	a5,0(a0)
    800024bc:	2785                	addiw	a5,a5,1
    800024be:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    800024c0:	a53ff0ef          	jal	80001f12 <wakeup>
    release(&tickslock);
    800024c4:	8526                	mv	a0,s1
    800024c6:	fa0fe0ef          	jal	80000c66 <release>
    800024ca:	64a2                	ld	s1,8(sp)
    800024cc:	bf75                	j	80002488 <clockintr+0xe>

00000000800024ce <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800024ce:	1101                	addi	sp,sp,-32
    800024d0:	ec06                	sd	ra,24(sp)
    800024d2:	e822                	sd	s0,16(sp)
    800024d4:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800024d6:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    800024da:	57fd                	li	a5,-1
    800024dc:	17fe                	slli	a5,a5,0x3f
    800024de:	07a5                	addi	a5,a5,9
    800024e0:	00f70c63          	beq	a4,a5,800024f8 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    800024e4:	57fd                	li	a5,-1
    800024e6:	17fe                	slli	a5,a5,0x3f
    800024e8:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    800024ea:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    800024ec:	04f70763          	beq	a4,a5,8000253a <devintr+0x6c>
  }
}
    800024f0:	60e2                	ld	ra,24(sp)
    800024f2:	6442                	ld	s0,16(sp)
    800024f4:	6105                	addi	sp,sp,32
    800024f6:	8082                	ret
    800024f8:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    800024fa:	733020ef          	jal	8000542c <plic_claim>
    800024fe:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002500:	47a9                	li	a5,10
    80002502:	00f50963          	beq	a0,a5,80002514 <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    80002506:	4785                	li	a5,1
    80002508:	00f50963          	beq	a0,a5,8000251a <devintr+0x4c>
    return 1;
    8000250c:	4505                	li	a0,1
    } else if(irq){
    8000250e:	e889                	bnez	s1,80002520 <devintr+0x52>
    80002510:	64a2                	ld	s1,8(sp)
    80002512:	bff9                	j	800024f0 <devintr+0x22>
      uartintr();
    80002514:	c9cfe0ef          	jal	800009b0 <uartintr>
    if(irq)
    80002518:	a819                	j	8000252e <devintr+0x60>
      virtio_disk_intr();
    8000251a:	3d8030ef          	jal	800058f2 <virtio_disk_intr>
    if(irq)
    8000251e:	a801                	j	8000252e <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    80002520:	85a6                	mv	a1,s1
    80002522:	00005517          	auipc	a0,0x5
    80002526:	d2e50513          	addi	a0,a0,-722 # 80007250 <etext+0x250>
    8000252a:	fd1fd0ef          	jal	800004fa <printf>
      plic_complete(irq);
    8000252e:	8526                	mv	a0,s1
    80002530:	71d020ef          	jal	8000544c <plic_complete>
    return 1;
    80002534:	4505                	li	a0,1
    80002536:	64a2                	ld	s1,8(sp)
    80002538:	bf65                	j	800024f0 <devintr+0x22>
    clockintr();
    8000253a:	f41ff0ef          	jal	8000247a <clockintr>
    return 2;
    8000253e:	4509                	li	a0,2
    80002540:	bf45                	j	800024f0 <devintr+0x22>

0000000080002542 <usertrap>:
{
    80002542:	1101                	addi	sp,sp,-32
    80002544:	ec06                	sd	ra,24(sp)
    80002546:	e822                	sd	s0,16(sp)
    80002548:	e426                	sd	s1,8(sp)
    8000254a:	e04a                	sd	s2,0(sp)
    8000254c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000254e:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002552:	1007f793          	andi	a5,a5,256
    80002556:	eba5                	bnez	a5,800025c6 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002558:	00003797          	auipc	a5,0x3
    8000255c:	e2878793          	addi	a5,a5,-472 # 80005380 <kernelvec>
    80002560:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002564:	b6aff0ef          	jal	800018ce <myproc>
    80002568:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000256a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000256c:	14102773          	csrr	a4,sepc
    80002570:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002572:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002576:	47a1                	li	a5,8
    80002578:	04f70d63          	beq	a4,a5,800025d2 <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    8000257c:	f53ff0ef          	jal	800024ce <devintr>
    80002580:	892a                	mv	s2,a0
    80002582:	e945                	bnez	a0,80002632 <usertrap+0xf0>
    80002584:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002588:	47bd                	li	a5,15
    8000258a:	08f70863          	beq	a4,a5,8000261a <usertrap+0xd8>
    8000258e:	14202773          	csrr	a4,scause
    80002592:	47b5                	li	a5,13
    80002594:	08f70363          	beq	a4,a5,8000261a <usertrap+0xd8>
    80002598:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    8000259c:	5890                	lw	a2,48(s1)
    8000259e:	00005517          	auipc	a0,0x5
    800025a2:	cf250513          	addi	a0,a0,-782 # 80007290 <etext+0x290>
    800025a6:	f55fd0ef          	jal	800004fa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800025aa:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800025ae:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    800025b2:	00005517          	auipc	a0,0x5
    800025b6:	d0e50513          	addi	a0,a0,-754 # 800072c0 <etext+0x2c0>
    800025ba:	f41fd0ef          	jal	800004fa <printf>
    setkilled(p);
    800025be:	8526                	mv	a0,s1
    800025c0:	b1bff0ef          	jal	800020da <setkilled>
    800025c4:	a035                	j	800025f0 <usertrap+0xae>
    panic("usertrap: not from user mode");
    800025c6:	00005517          	auipc	a0,0x5
    800025ca:	caa50513          	addi	a0,a0,-854 # 80007270 <etext+0x270>
    800025ce:	a12fe0ef          	jal	800007e0 <panic>
    if(killed(p))
    800025d2:	b2dff0ef          	jal	800020fe <killed>
    800025d6:	ed15                	bnez	a0,80002612 <usertrap+0xd0>
    p->trapframe->epc += 4;
    800025d8:	6cb8                	ld	a4,88(s1)
    800025da:	6f1c                	ld	a5,24(a4)
    800025dc:	0791                	addi	a5,a5,4
    800025de:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800025e0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800025e4:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800025e8:	10079073          	csrw	sstatus,a5
    syscall();
    800025ec:	246000ef          	jal	80002832 <syscall>
  if(killed(p))
    800025f0:	8526                	mv	a0,s1
    800025f2:	b0dff0ef          	jal	800020fe <killed>
    800025f6:	e139                	bnez	a0,8000263c <usertrap+0xfa>
  prepare_return();
    800025f8:	e09ff0ef          	jal	80002400 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800025fc:	68a8                	ld	a0,80(s1)
    800025fe:	8131                	srli	a0,a0,0xc
    80002600:	57fd                	li	a5,-1
    80002602:	17fe                	slli	a5,a5,0x3f
    80002604:	8d5d                	or	a0,a0,a5
}
    80002606:	60e2                	ld	ra,24(sp)
    80002608:	6442                	ld	s0,16(sp)
    8000260a:	64a2                	ld	s1,8(sp)
    8000260c:	6902                	ld	s2,0(sp)
    8000260e:	6105                	addi	sp,sp,32
    80002610:	8082                	ret
      kexit(-1);
    80002612:	557d                	li	a0,-1
    80002614:	9bfff0ef          	jal	80001fd2 <kexit>
    80002618:	b7c1                	j	800025d8 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000261a:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000261e:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    80002622:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    80002624:	00163613          	seqz	a2,a2
    80002628:	68a8                	ld	a0,80(s1)
    8000262a:	f37fe0ef          	jal	80001560 <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    8000262e:	f169                	bnez	a0,800025f0 <usertrap+0xae>
    80002630:	b7a5                	j	80002598 <usertrap+0x56>
  if(killed(p))
    80002632:	8526                	mv	a0,s1
    80002634:	acbff0ef          	jal	800020fe <killed>
    80002638:	c511                	beqz	a0,80002644 <usertrap+0x102>
    8000263a:	a011                	j	8000263e <usertrap+0xfc>
    8000263c:	4901                	li	s2,0
    kexit(-1);
    8000263e:	557d                	li	a0,-1
    80002640:	993ff0ef          	jal	80001fd2 <kexit>
  if(which_dev == 2)
    80002644:	4789                	li	a5,2
    80002646:	faf919e3          	bne	s2,a5,800025f8 <usertrap+0xb6>
    yield();
    8000264a:	851ff0ef          	jal	80001e9a <yield>
    8000264e:	b76d                	j	800025f8 <usertrap+0xb6>

0000000080002650 <kerneltrap>:
{
    80002650:	7179                	addi	sp,sp,-48
    80002652:	f406                	sd	ra,40(sp)
    80002654:	f022                	sd	s0,32(sp)
    80002656:	ec26                	sd	s1,24(sp)
    80002658:	e84a                	sd	s2,16(sp)
    8000265a:	e44e                	sd	s3,8(sp)
    8000265c:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000265e:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002662:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002666:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    8000266a:	1004f793          	andi	a5,s1,256
    8000266e:	c795                	beqz	a5,8000269a <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002670:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002674:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002676:	eb85                	bnez	a5,800026a6 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80002678:	e57ff0ef          	jal	800024ce <devintr>
    8000267c:	c91d                	beqz	a0,800026b2 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    8000267e:	4789                	li	a5,2
    80002680:	04f50a63          	beq	a0,a5,800026d4 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002684:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002688:	10049073          	csrw	sstatus,s1
}
    8000268c:	70a2                	ld	ra,40(sp)
    8000268e:	7402                	ld	s0,32(sp)
    80002690:	64e2                	ld	s1,24(sp)
    80002692:	6942                	ld	s2,16(sp)
    80002694:	69a2                	ld	s3,8(sp)
    80002696:	6145                	addi	sp,sp,48
    80002698:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    8000269a:	00005517          	auipc	a0,0x5
    8000269e:	c4e50513          	addi	a0,a0,-946 # 800072e8 <etext+0x2e8>
    800026a2:	93efe0ef          	jal	800007e0 <panic>
    panic("kerneltrap: interrupts enabled");
    800026a6:	00005517          	auipc	a0,0x5
    800026aa:	c6a50513          	addi	a0,a0,-918 # 80007310 <etext+0x310>
    800026ae:	932fe0ef          	jal	800007e0 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800026b2:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800026b6:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    800026ba:	85ce                	mv	a1,s3
    800026bc:	00005517          	auipc	a0,0x5
    800026c0:	c7450513          	addi	a0,a0,-908 # 80007330 <etext+0x330>
    800026c4:	e37fd0ef          	jal	800004fa <printf>
    panic("kerneltrap");
    800026c8:	00005517          	auipc	a0,0x5
    800026cc:	c9050513          	addi	a0,a0,-880 # 80007358 <etext+0x358>
    800026d0:	910fe0ef          	jal	800007e0 <panic>
  if(which_dev == 2 && myproc() != 0)
    800026d4:	9faff0ef          	jal	800018ce <myproc>
    800026d8:	d555                	beqz	a0,80002684 <kerneltrap+0x34>
    yield();
    800026da:	fc0ff0ef          	jal	80001e9a <yield>
    800026de:	b75d                	j	80002684 <kerneltrap+0x34>

00000000800026e0 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800026e0:	1101                	addi	sp,sp,-32
    800026e2:	ec06                	sd	ra,24(sp)
    800026e4:	e822                	sd	s0,16(sp)
    800026e6:	e426                	sd	s1,8(sp)
    800026e8:	1000                	addi	s0,sp,32
    800026ea:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800026ec:	9e2ff0ef          	jal	800018ce <myproc>
  switch (n) {
    800026f0:	4795                	li	a5,5
    800026f2:	0497e163          	bltu	a5,s1,80002734 <argraw+0x54>
    800026f6:	048a                	slli	s1,s1,0x2
    800026f8:	00005717          	auipc	a4,0x5
    800026fc:	06070713          	addi	a4,a4,96 # 80007758 <states.0+0x30>
    80002700:	94ba                	add	s1,s1,a4
    80002702:	409c                	lw	a5,0(s1)
    80002704:	97ba                	add	a5,a5,a4
    80002706:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002708:	6d3c                	ld	a5,88(a0)
    8000270a:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    8000270c:	60e2                	ld	ra,24(sp)
    8000270e:	6442                	ld	s0,16(sp)
    80002710:	64a2                	ld	s1,8(sp)
    80002712:	6105                	addi	sp,sp,32
    80002714:	8082                	ret
    return p->trapframe->a1;
    80002716:	6d3c                	ld	a5,88(a0)
    80002718:	7fa8                	ld	a0,120(a5)
    8000271a:	bfcd                	j	8000270c <argraw+0x2c>
    return p->trapframe->a2;
    8000271c:	6d3c                	ld	a5,88(a0)
    8000271e:	63c8                	ld	a0,128(a5)
    80002720:	b7f5                	j	8000270c <argraw+0x2c>
    return p->trapframe->a3;
    80002722:	6d3c                	ld	a5,88(a0)
    80002724:	67c8                	ld	a0,136(a5)
    80002726:	b7dd                	j	8000270c <argraw+0x2c>
    return p->trapframe->a4;
    80002728:	6d3c                	ld	a5,88(a0)
    8000272a:	6bc8                	ld	a0,144(a5)
    8000272c:	b7c5                	j	8000270c <argraw+0x2c>
    return p->trapframe->a5;
    8000272e:	6d3c                	ld	a5,88(a0)
    80002730:	6fc8                	ld	a0,152(a5)
    80002732:	bfe9                	j	8000270c <argraw+0x2c>
  panic("argraw");
    80002734:	00005517          	auipc	a0,0x5
    80002738:	c3450513          	addi	a0,a0,-972 # 80007368 <etext+0x368>
    8000273c:	8a4fe0ef          	jal	800007e0 <panic>

0000000080002740 <fetchaddr>:
{
    80002740:	1101                	addi	sp,sp,-32
    80002742:	ec06                	sd	ra,24(sp)
    80002744:	e822                	sd	s0,16(sp)
    80002746:	e426                	sd	s1,8(sp)
    80002748:	e04a                	sd	s2,0(sp)
    8000274a:	1000                	addi	s0,sp,32
    8000274c:	84aa                	mv	s1,a0
    8000274e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002750:	97eff0ef          	jal	800018ce <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002754:	653c                	ld	a5,72(a0)
    80002756:	02f4f663          	bgeu	s1,a5,80002782 <fetchaddr+0x42>
    8000275a:	00848713          	addi	a4,s1,8
    8000275e:	02e7e463          	bltu	a5,a4,80002786 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002762:	46a1                	li	a3,8
    80002764:	8626                	mv	a2,s1
    80002766:	85ca                	mv	a1,s2
    80002768:	6928                	ld	a0,80(a0)
    8000276a:	f5dfe0ef          	jal	800016c6 <copyin>
    8000276e:	00a03533          	snez	a0,a0
    80002772:	40a00533          	neg	a0,a0
}
    80002776:	60e2                	ld	ra,24(sp)
    80002778:	6442                	ld	s0,16(sp)
    8000277a:	64a2                	ld	s1,8(sp)
    8000277c:	6902                	ld	s2,0(sp)
    8000277e:	6105                	addi	sp,sp,32
    80002780:	8082                	ret
    return -1;
    80002782:	557d                	li	a0,-1
    80002784:	bfcd                	j	80002776 <fetchaddr+0x36>
    80002786:	557d                	li	a0,-1
    80002788:	b7fd                	j	80002776 <fetchaddr+0x36>

000000008000278a <fetchstr>:
{
    8000278a:	7179                	addi	sp,sp,-48
    8000278c:	f406                	sd	ra,40(sp)
    8000278e:	f022                	sd	s0,32(sp)
    80002790:	ec26                	sd	s1,24(sp)
    80002792:	e84a                	sd	s2,16(sp)
    80002794:	e44e                	sd	s3,8(sp)
    80002796:	1800                	addi	s0,sp,48
    80002798:	892a                	mv	s2,a0
    8000279a:	84ae                	mv	s1,a1
    8000279c:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    8000279e:	930ff0ef          	jal	800018ce <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    800027a2:	86ce                	mv	a3,s3
    800027a4:	864a                	mv	a2,s2
    800027a6:	85a6                	mv	a1,s1
    800027a8:	6928                	ld	a0,80(a0)
    800027aa:	cdffe0ef          	jal	80001488 <copyinstr>
    800027ae:	00054c63          	bltz	a0,800027c6 <fetchstr+0x3c>
  return strlen(buf);
    800027b2:	8526                	mv	a0,s1
    800027b4:	e5efe0ef          	jal	80000e12 <strlen>
}
    800027b8:	70a2                	ld	ra,40(sp)
    800027ba:	7402                	ld	s0,32(sp)
    800027bc:	64e2                	ld	s1,24(sp)
    800027be:	6942                	ld	s2,16(sp)
    800027c0:	69a2                	ld	s3,8(sp)
    800027c2:	6145                	addi	sp,sp,48
    800027c4:	8082                	ret
    return -1;
    800027c6:	557d                	li	a0,-1
    800027c8:	bfc5                	j	800027b8 <fetchstr+0x2e>

00000000800027ca <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    800027ca:	1101                	addi	sp,sp,-32
    800027cc:	ec06                	sd	ra,24(sp)
    800027ce:	e822                	sd	s0,16(sp)
    800027d0:	e426                	sd	s1,8(sp)
    800027d2:	1000                	addi	s0,sp,32
    800027d4:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800027d6:	f0bff0ef          	jal	800026e0 <argraw>
    800027da:	c088                	sw	a0,0(s1)
}
    800027dc:	60e2                	ld	ra,24(sp)
    800027de:	6442                	ld	s0,16(sp)
    800027e0:	64a2                	ld	s1,8(sp)
    800027e2:	6105                	addi	sp,sp,32
    800027e4:	8082                	ret

00000000800027e6 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    800027e6:	1101                	addi	sp,sp,-32
    800027e8:	ec06                	sd	ra,24(sp)
    800027ea:	e822                	sd	s0,16(sp)
    800027ec:	e426                	sd	s1,8(sp)
    800027ee:	1000                	addi	s0,sp,32
    800027f0:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800027f2:	eefff0ef          	jal	800026e0 <argraw>
    800027f6:	e088                	sd	a0,0(s1)
}
    800027f8:	60e2                	ld	ra,24(sp)
    800027fa:	6442                	ld	s0,16(sp)
    800027fc:	64a2                	ld	s1,8(sp)
    800027fe:	6105                	addi	sp,sp,32
    80002800:	8082                	ret

0000000080002802 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002802:	7179                	addi	sp,sp,-48
    80002804:	f406                	sd	ra,40(sp)
    80002806:	f022                	sd	s0,32(sp)
    80002808:	ec26                	sd	s1,24(sp)
    8000280a:	e84a                	sd	s2,16(sp)
    8000280c:	1800                	addi	s0,sp,48
    8000280e:	84ae                	mv	s1,a1
    80002810:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002812:	fd840593          	addi	a1,s0,-40
    80002816:	fd1ff0ef          	jal	800027e6 <argaddr>
  return fetchstr(addr, buf, max);
    8000281a:	864a                	mv	a2,s2
    8000281c:	85a6                	mv	a1,s1
    8000281e:	fd843503          	ld	a0,-40(s0)
    80002822:	f69ff0ef          	jal	8000278a <fetchstr>
}
    80002826:	70a2                	ld	ra,40(sp)
    80002828:	7402                	ld	s0,32(sp)
    8000282a:	64e2                	ld	s1,24(sp)
    8000282c:	6942                	ld	s2,16(sp)
    8000282e:	6145                	addi	sp,sp,48
    80002830:	8082                	ret

0000000080002832 <syscall>:
[SYS_getfilenum] sys_getfilenum, //adding filenum to dispatch table
};

void
syscall(void)
{
    80002832:	1101                	addi	sp,sp,-32
    80002834:	ec06                	sd	ra,24(sp)
    80002836:	e822                	sd	s0,16(sp)
    80002838:	e426                	sd	s1,8(sp)
    8000283a:	e04a                	sd	s2,0(sp)
    8000283c:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    8000283e:	890ff0ef          	jal	800018ce <myproc>
    80002842:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002844:	05853903          	ld	s2,88(a0)
    80002848:	0a893783          	ld	a5,168(s2)
    8000284c:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002850:	37fd                	addiw	a5,a5,-1
    80002852:	4759                	li	a4,22
    80002854:	00f76f63          	bltu	a4,a5,80002872 <syscall+0x40>
    80002858:	00369713          	slli	a4,a3,0x3
    8000285c:	00005797          	auipc	a5,0x5
    80002860:	f1478793          	addi	a5,a5,-236 # 80007770 <syscalls>
    80002864:	97ba                	add	a5,a5,a4
    80002866:	639c                	ld	a5,0(a5)
    80002868:	c789                	beqz	a5,80002872 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    8000286a:	9782                	jalr	a5
    8000286c:	06a93823          	sd	a0,112(s2)
    80002870:	a829                	j	8000288a <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002872:	15848613          	addi	a2,s1,344
    80002876:	588c                	lw	a1,48(s1)
    80002878:	00005517          	auipc	a0,0x5
    8000287c:	af850513          	addi	a0,a0,-1288 # 80007370 <etext+0x370>
    80002880:	c7bfd0ef          	jal	800004fa <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002884:	6cbc                	ld	a5,88(s1)
    80002886:	577d                	li	a4,-1
    80002888:	fbb8                	sd	a4,112(a5)
  }
}
    8000288a:	60e2                	ld	ra,24(sp)
    8000288c:	6442                	ld	s0,16(sp)
    8000288e:	64a2                	ld	s1,8(sp)
    80002890:	6902                	ld	s2,0(sp)
    80002892:	6105                	addi	sp,sp,32
    80002894:	8082                	ret

0000000080002896 <sys_getfilenum>:
#include "proc.h"
#include "vm.h"

uint64
sys_getfilenum(void)
{
    80002896:	1101                	addi	sp,sp,-32
    80002898:	ec06                	sd	ra,24(sp)
    8000289a:	e822                	sd	s0,16(sp)
    8000289c:	1000                	addi	s0,sp,32
    int pid;
    argint(0, &pid);
    8000289e:	fec40593          	addi	a1,s0,-20
    800028a2:	4501                	li	a0,0
    800028a4:	f27ff0ef          	jal	800027ca <argint>

    struct proc *p;
    extern struct proc proc[NPROC];

    for (p = proc; p < &proc[NPROC]; p++) {
        if (p->pid == pid) {
    800028a8:	fec42683          	lw	a3,-20(s0)
    for (p = proc; p < &proc[NPROC]; p++) {
    800028ac:	00010797          	auipc	a5,0x10
    800028b0:	e5c78793          	addi	a5,a5,-420 # 80012708 <proc>
    800028b4:	00016617          	auipc	a2,0x16
    800028b8:	85460613          	addi	a2,a2,-1964 # 80018108 <tickslock>
        if (p->pid == pid) {
    800028bc:	5b98                	lw	a4,48(a5)
    800028be:	00d70b63          	beq	a4,a3,800028d4 <sys_getfilenum+0x3e>
    for (p = proc; p < &proc[NPROC]; p++) {
    800028c2:	16878793          	addi	a5,a5,360
    800028c6:	fec79be3          	bne	a5,a2,800028bc <sys_getfilenum+0x26>
                    count++;
            }
            return count;
        }
    }
    return -1;
    800028ca:	557d                	li	a0,-1
}
    800028cc:	60e2                	ld	ra,24(sp)
    800028ce:	6442                	ld	s0,16(sp)
    800028d0:	6105                	addi	sp,sp,32
    800028d2:	8082                	ret
    800028d4:	0d078713          	addi	a4,a5,208
    800028d8:	15078793          	addi	a5,a5,336
            int count = 0;
    800028dc:	4501                	li	a0,0
    800028de:	a029                	j	800028e8 <sys_getfilenum+0x52>
                    count++;
    800028e0:	2505                	addiw	a0,a0,1
            for (int i = 0; i < NOFILE; i++) {
    800028e2:	0721                	addi	a4,a4,8
    800028e4:	fef704e3          	beq	a4,a5,800028cc <sys_getfilenum+0x36>
                if (p->ofile[i])
    800028e8:	6314                	ld	a3,0(a4)
    800028ea:	fafd                	bnez	a3,800028e0 <sys_getfilenum+0x4a>
    800028ec:	bfdd                	j	800028e2 <sys_getfilenum+0x4c>

00000000800028ee <sys_exit>:


uint64
sys_exit(void)
{
    800028ee:	1101                	addi	sp,sp,-32
    800028f0:	ec06                	sd	ra,24(sp)
    800028f2:	e822                	sd	s0,16(sp)
    800028f4:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800028f6:	fec40593          	addi	a1,s0,-20
    800028fa:	4501                	li	a0,0
    800028fc:	ecfff0ef          	jal	800027ca <argint>
  kexit(n);
    80002900:	fec42503          	lw	a0,-20(s0)
    80002904:	eceff0ef          	jal	80001fd2 <kexit>
  return 0;  // not reached
}
    80002908:	4501                	li	a0,0
    8000290a:	60e2                	ld	ra,24(sp)
    8000290c:	6442                	ld	s0,16(sp)
    8000290e:	6105                	addi	sp,sp,32
    80002910:	8082                	ret

0000000080002912 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002912:	1141                	addi	sp,sp,-16
    80002914:	e406                	sd	ra,8(sp)
    80002916:	e022                	sd	s0,0(sp)
    80002918:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000291a:	fb5fe0ef          	jal	800018ce <myproc>
}
    8000291e:	5908                	lw	a0,48(a0)
    80002920:	60a2                	ld	ra,8(sp)
    80002922:	6402                	ld	s0,0(sp)
    80002924:	0141                	addi	sp,sp,16
    80002926:	8082                	ret

0000000080002928 <sys_fork>:

uint64
sys_fork(void)
{
    80002928:	1141                	addi	sp,sp,-16
    8000292a:	e406                	sd	ra,8(sp)
    8000292c:	e022                	sd	s0,0(sp)
    8000292e:	0800                	addi	s0,sp,16
  return kfork();
    80002930:	af0ff0ef          	jal	80001c20 <kfork>
}
    80002934:	60a2                	ld	ra,8(sp)
    80002936:	6402                	ld	s0,0(sp)
    80002938:	0141                	addi	sp,sp,16
    8000293a:	8082                	ret

000000008000293c <sys_wait>:

uint64
sys_wait(void)
{
    8000293c:	1101                	addi	sp,sp,-32
    8000293e:	ec06                	sd	ra,24(sp)
    80002940:	e822                	sd	s0,16(sp)
    80002942:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002944:	fe840593          	addi	a1,s0,-24
    80002948:	4501                	li	a0,0
    8000294a:	e9dff0ef          	jal	800027e6 <argaddr>
  return kwait(p);
    8000294e:	fe843503          	ld	a0,-24(s0)
    80002952:	fd6ff0ef          	jal	80002128 <kwait>
}
    80002956:	60e2                	ld	ra,24(sp)
    80002958:	6442                	ld	s0,16(sp)
    8000295a:	6105                	addi	sp,sp,32
    8000295c:	8082                	ret

000000008000295e <sys_sbrk>:

uint64
sys_sbrk(void)
{
    8000295e:	7179                	addi	sp,sp,-48
    80002960:	f406                	sd	ra,40(sp)
    80002962:	f022                	sd	s0,32(sp)
    80002964:	ec26                	sd	s1,24(sp)
    80002966:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002968:	fd840593          	addi	a1,s0,-40
    8000296c:	4501                	li	a0,0
    8000296e:	e5dff0ef          	jal	800027ca <argint>
  argint(1, &t);
    80002972:	fdc40593          	addi	a1,s0,-36
    80002976:	4505                	li	a0,1
    80002978:	e53ff0ef          	jal	800027ca <argint>
  addr = myproc()->sz;
    8000297c:	f53fe0ef          	jal	800018ce <myproc>
    80002980:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    80002982:	fdc42703          	lw	a4,-36(s0)
    80002986:	4785                	li	a5,1
    80002988:	02f70163          	beq	a4,a5,800029aa <sys_sbrk+0x4c>
    8000298c:	fd842783          	lw	a5,-40(s0)
    80002990:	0007cd63          	bltz	a5,800029aa <sys_sbrk+0x4c>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80002994:	97a6                	add	a5,a5,s1
    80002996:	0297e863          	bltu	a5,s1,800029c6 <sys_sbrk+0x68>
      return -1;
    myproc()->sz += n;
    8000299a:	f35fe0ef          	jal	800018ce <myproc>
    8000299e:	fd842703          	lw	a4,-40(s0)
    800029a2:	653c                	ld	a5,72(a0)
    800029a4:	97ba                	add	a5,a5,a4
    800029a6:	e53c                	sd	a5,72(a0)
    800029a8:	a039                	j	800029b6 <sys_sbrk+0x58>
    if(growproc(n) < 0) {
    800029aa:	fd842503          	lw	a0,-40(s0)
    800029ae:	a22ff0ef          	jal	80001bd0 <growproc>
    800029b2:	00054863          	bltz	a0,800029c2 <sys_sbrk+0x64>
  }
  return addr;
}
    800029b6:	8526                	mv	a0,s1
    800029b8:	70a2                	ld	ra,40(sp)
    800029ba:	7402                	ld	s0,32(sp)
    800029bc:	64e2                	ld	s1,24(sp)
    800029be:	6145                	addi	sp,sp,48
    800029c0:	8082                	ret
      return -1;
    800029c2:	54fd                	li	s1,-1
    800029c4:	bfcd                	j	800029b6 <sys_sbrk+0x58>
      return -1;
    800029c6:	54fd                	li	s1,-1
    800029c8:	b7fd                	j	800029b6 <sys_sbrk+0x58>

00000000800029ca <sys_pause>:

uint64
sys_pause(void)
{
    800029ca:	7139                	addi	sp,sp,-64
    800029cc:	fc06                	sd	ra,56(sp)
    800029ce:	f822                	sd	s0,48(sp)
    800029d0:	f04a                	sd	s2,32(sp)
    800029d2:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    800029d4:	fcc40593          	addi	a1,s0,-52
    800029d8:	4501                	li	a0,0
    800029da:	df1ff0ef          	jal	800027ca <argint>
  if(n < 0)
    800029de:	fcc42783          	lw	a5,-52(s0)
    800029e2:	0607c763          	bltz	a5,80002a50 <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    800029e6:	00015517          	auipc	a0,0x15
    800029ea:	72250513          	addi	a0,a0,1826 # 80018108 <tickslock>
    800029ee:	9e0fe0ef          	jal	80000bce <acquire>
  ticks0 = ticks;
    800029f2:	00007917          	auipc	s2,0x7
    800029f6:	7e692903          	lw	s2,2022(s2) # 8000a1d8 <ticks>
  while(ticks - ticks0 < n){
    800029fa:	fcc42783          	lw	a5,-52(s0)
    800029fe:	cf8d                	beqz	a5,80002a38 <sys_pause+0x6e>
    80002a00:	f426                	sd	s1,40(sp)
    80002a02:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002a04:	00015997          	auipc	s3,0x15
    80002a08:	70498993          	addi	s3,s3,1796 # 80018108 <tickslock>
    80002a0c:	00007497          	auipc	s1,0x7
    80002a10:	7cc48493          	addi	s1,s1,1996 # 8000a1d8 <ticks>
    if(killed(myproc())){
    80002a14:	ebbfe0ef          	jal	800018ce <myproc>
    80002a18:	ee6ff0ef          	jal	800020fe <killed>
    80002a1c:	ed0d                	bnez	a0,80002a56 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002a1e:	85ce                	mv	a1,s3
    80002a20:	8526                	mv	a0,s1
    80002a22:	ca4ff0ef          	jal	80001ec6 <sleep>
  while(ticks - ticks0 < n){
    80002a26:	409c                	lw	a5,0(s1)
    80002a28:	412787bb          	subw	a5,a5,s2
    80002a2c:	fcc42703          	lw	a4,-52(s0)
    80002a30:	fee7e2e3          	bltu	a5,a4,80002a14 <sys_pause+0x4a>
    80002a34:	74a2                	ld	s1,40(sp)
    80002a36:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002a38:	00015517          	auipc	a0,0x15
    80002a3c:	6d050513          	addi	a0,a0,1744 # 80018108 <tickslock>
    80002a40:	a26fe0ef          	jal	80000c66 <release>
  return 0;
    80002a44:	4501                	li	a0,0
}
    80002a46:	70e2                	ld	ra,56(sp)
    80002a48:	7442                	ld	s0,48(sp)
    80002a4a:	7902                	ld	s2,32(sp)
    80002a4c:	6121                	addi	sp,sp,64
    80002a4e:	8082                	ret
    n = 0;
    80002a50:	fc042623          	sw	zero,-52(s0)
    80002a54:	bf49                	j	800029e6 <sys_pause+0x1c>
      release(&tickslock);
    80002a56:	00015517          	auipc	a0,0x15
    80002a5a:	6b250513          	addi	a0,a0,1714 # 80018108 <tickslock>
    80002a5e:	a08fe0ef          	jal	80000c66 <release>
      return -1;
    80002a62:	557d                	li	a0,-1
    80002a64:	74a2                	ld	s1,40(sp)
    80002a66:	69e2                	ld	s3,24(sp)
    80002a68:	bff9                	j	80002a46 <sys_pause+0x7c>

0000000080002a6a <sys_kill>:

uint64
sys_kill(void)
{
    80002a6a:	1101                	addi	sp,sp,-32
    80002a6c:	ec06                	sd	ra,24(sp)
    80002a6e:	e822                	sd	s0,16(sp)
    80002a70:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002a72:	fec40593          	addi	a1,s0,-20
    80002a76:	4501                	li	a0,0
    80002a78:	d53ff0ef          	jal	800027ca <argint>
  return kkill(pid);
    80002a7c:	fec42503          	lw	a0,-20(s0)
    80002a80:	df4ff0ef          	jal	80002074 <kkill>
}
    80002a84:	60e2                	ld	ra,24(sp)
    80002a86:	6442                	ld	s0,16(sp)
    80002a88:	6105                	addi	sp,sp,32
    80002a8a:	8082                	ret

0000000080002a8c <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002a8c:	1101                	addi	sp,sp,-32
    80002a8e:	ec06                	sd	ra,24(sp)
    80002a90:	e822                	sd	s0,16(sp)
    80002a92:	e426                	sd	s1,8(sp)
    80002a94:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002a96:	00015517          	auipc	a0,0x15
    80002a9a:	67250513          	addi	a0,a0,1650 # 80018108 <tickslock>
    80002a9e:	930fe0ef          	jal	80000bce <acquire>
  xticks = ticks;
    80002aa2:	00007497          	auipc	s1,0x7
    80002aa6:	7364a483          	lw	s1,1846(s1) # 8000a1d8 <ticks>
  release(&tickslock);
    80002aaa:	00015517          	auipc	a0,0x15
    80002aae:	65e50513          	addi	a0,a0,1630 # 80018108 <tickslock>
    80002ab2:	9b4fe0ef          	jal	80000c66 <release>
  return xticks;
}
    80002ab6:	02049513          	slli	a0,s1,0x20
    80002aba:	9101                	srli	a0,a0,0x20
    80002abc:	60e2                	ld	ra,24(sp)
    80002abe:	6442                	ld	s0,16(sp)
    80002ac0:	64a2                	ld	s1,8(sp)
    80002ac2:	6105                	addi	sp,sp,32
    80002ac4:	8082                	ret

0000000080002ac6 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002ac6:	7179                	addi	sp,sp,-48
    80002ac8:	f406                	sd	ra,40(sp)
    80002aca:	f022                	sd	s0,32(sp)
    80002acc:	ec26                	sd	s1,24(sp)
    80002ace:	e84a                	sd	s2,16(sp)
    80002ad0:	e44e                	sd	s3,8(sp)
    80002ad2:	e052                	sd	s4,0(sp)
    80002ad4:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002ad6:	00005597          	auipc	a1,0x5
    80002ada:	8ba58593          	addi	a1,a1,-1862 # 80007390 <etext+0x390>
    80002ade:	00015517          	auipc	a0,0x15
    80002ae2:	64250513          	addi	a0,a0,1602 # 80018120 <bcache>
    80002ae6:	868fe0ef          	jal	80000b4e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002aea:	0001d797          	auipc	a5,0x1d
    80002aee:	63678793          	addi	a5,a5,1590 # 80020120 <bcache+0x8000>
    80002af2:	0001e717          	auipc	a4,0x1e
    80002af6:	89670713          	addi	a4,a4,-1898 # 80020388 <bcache+0x8268>
    80002afa:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002afe:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002b02:	00015497          	auipc	s1,0x15
    80002b06:	63648493          	addi	s1,s1,1590 # 80018138 <bcache+0x18>
    b->next = bcache.head.next;
    80002b0a:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002b0c:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002b0e:	00005a17          	auipc	s4,0x5
    80002b12:	88aa0a13          	addi	s4,s4,-1910 # 80007398 <etext+0x398>
    b->next = bcache.head.next;
    80002b16:	2b893783          	ld	a5,696(s2)
    80002b1a:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002b1c:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002b20:	85d2                	mv	a1,s4
    80002b22:	01048513          	addi	a0,s1,16
    80002b26:	322010ef          	jal	80003e48 <initsleeplock>
    bcache.head.next->prev = b;
    80002b2a:	2b893783          	ld	a5,696(s2)
    80002b2e:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002b30:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002b34:	45848493          	addi	s1,s1,1112
    80002b38:	fd349fe3          	bne	s1,s3,80002b16 <binit+0x50>
  }
}
    80002b3c:	70a2                	ld	ra,40(sp)
    80002b3e:	7402                	ld	s0,32(sp)
    80002b40:	64e2                	ld	s1,24(sp)
    80002b42:	6942                	ld	s2,16(sp)
    80002b44:	69a2                	ld	s3,8(sp)
    80002b46:	6a02                	ld	s4,0(sp)
    80002b48:	6145                	addi	sp,sp,48
    80002b4a:	8082                	ret

0000000080002b4c <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002b4c:	7179                	addi	sp,sp,-48
    80002b4e:	f406                	sd	ra,40(sp)
    80002b50:	f022                	sd	s0,32(sp)
    80002b52:	ec26                	sd	s1,24(sp)
    80002b54:	e84a                	sd	s2,16(sp)
    80002b56:	e44e                	sd	s3,8(sp)
    80002b58:	1800                	addi	s0,sp,48
    80002b5a:	892a                	mv	s2,a0
    80002b5c:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002b5e:	00015517          	auipc	a0,0x15
    80002b62:	5c250513          	addi	a0,a0,1474 # 80018120 <bcache>
    80002b66:	868fe0ef          	jal	80000bce <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002b6a:	0001e497          	auipc	s1,0x1e
    80002b6e:	86e4b483          	ld	s1,-1938(s1) # 800203d8 <bcache+0x82b8>
    80002b72:	0001e797          	auipc	a5,0x1e
    80002b76:	81678793          	addi	a5,a5,-2026 # 80020388 <bcache+0x8268>
    80002b7a:	02f48b63          	beq	s1,a5,80002bb0 <bread+0x64>
    80002b7e:	873e                	mv	a4,a5
    80002b80:	a021                	j	80002b88 <bread+0x3c>
    80002b82:	68a4                	ld	s1,80(s1)
    80002b84:	02e48663          	beq	s1,a4,80002bb0 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002b88:	449c                	lw	a5,8(s1)
    80002b8a:	ff279ce3          	bne	a5,s2,80002b82 <bread+0x36>
    80002b8e:	44dc                	lw	a5,12(s1)
    80002b90:	ff3799e3          	bne	a5,s3,80002b82 <bread+0x36>
      b->refcnt++;
    80002b94:	40bc                	lw	a5,64(s1)
    80002b96:	2785                	addiw	a5,a5,1
    80002b98:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002b9a:	00015517          	auipc	a0,0x15
    80002b9e:	58650513          	addi	a0,a0,1414 # 80018120 <bcache>
    80002ba2:	8c4fe0ef          	jal	80000c66 <release>
      acquiresleep(&b->lock);
    80002ba6:	01048513          	addi	a0,s1,16
    80002baa:	2d4010ef          	jal	80003e7e <acquiresleep>
      return b;
    80002bae:	a889                	j	80002c00 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002bb0:	0001e497          	auipc	s1,0x1e
    80002bb4:	8204b483          	ld	s1,-2016(s1) # 800203d0 <bcache+0x82b0>
    80002bb8:	0001d797          	auipc	a5,0x1d
    80002bbc:	7d078793          	addi	a5,a5,2000 # 80020388 <bcache+0x8268>
    80002bc0:	00f48863          	beq	s1,a5,80002bd0 <bread+0x84>
    80002bc4:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002bc6:	40bc                	lw	a5,64(s1)
    80002bc8:	cb91                	beqz	a5,80002bdc <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002bca:	64a4                	ld	s1,72(s1)
    80002bcc:	fee49de3          	bne	s1,a4,80002bc6 <bread+0x7a>
  panic("bget: no buffers");
    80002bd0:	00004517          	auipc	a0,0x4
    80002bd4:	7d050513          	addi	a0,a0,2000 # 800073a0 <etext+0x3a0>
    80002bd8:	c09fd0ef          	jal	800007e0 <panic>
      b->dev = dev;
    80002bdc:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002be0:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002be4:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002be8:	4785                	li	a5,1
    80002bea:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002bec:	00015517          	auipc	a0,0x15
    80002bf0:	53450513          	addi	a0,a0,1332 # 80018120 <bcache>
    80002bf4:	872fe0ef          	jal	80000c66 <release>
      acquiresleep(&b->lock);
    80002bf8:	01048513          	addi	a0,s1,16
    80002bfc:	282010ef          	jal	80003e7e <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002c00:	409c                	lw	a5,0(s1)
    80002c02:	cb89                	beqz	a5,80002c14 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002c04:	8526                	mv	a0,s1
    80002c06:	70a2                	ld	ra,40(sp)
    80002c08:	7402                	ld	s0,32(sp)
    80002c0a:	64e2                	ld	s1,24(sp)
    80002c0c:	6942                	ld	s2,16(sp)
    80002c0e:	69a2                	ld	s3,8(sp)
    80002c10:	6145                	addi	sp,sp,48
    80002c12:	8082                	ret
    virtio_disk_rw(b, 0);
    80002c14:	4581                	li	a1,0
    80002c16:	8526                	mv	a0,s1
    80002c18:	2c9020ef          	jal	800056e0 <virtio_disk_rw>
    b->valid = 1;
    80002c1c:	4785                	li	a5,1
    80002c1e:	c09c                	sw	a5,0(s1)
  return b;
    80002c20:	b7d5                	j	80002c04 <bread+0xb8>

0000000080002c22 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002c22:	1101                	addi	sp,sp,-32
    80002c24:	ec06                	sd	ra,24(sp)
    80002c26:	e822                	sd	s0,16(sp)
    80002c28:	e426                	sd	s1,8(sp)
    80002c2a:	1000                	addi	s0,sp,32
    80002c2c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002c2e:	0541                	addi	a0,a0,16
    80002c30:	2cc010ef          	jal	80003efc <holdingsleep>
    80002c34:	c911                	beqz	a0,80002c48 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002c36:	4585                	li	a1,1
    80002c38:	8526                	mv	a0,s1
    80002c3a:	2a7020ef          	jal	800056e0 <virtio_disk_rw>
}
    80002c3e:	60e2                	ld	ra,24(sp)
    80002c40:	6442                	ld	s0,16(sp)
    80002c42:	64a2                	ld	s1,8(sp)
    80002c44:	6105                	addi	sp,sp,32
    80002c46:	8082                	ret
    panic("bwrite");
    80002c48:	00004517          	auipc	a0,0x4
    80002c4c:	77050513          	addi	a0,a0,1904 # 800073b8 <etext+0x3b8>
    80002c50:	b91fd0ef          	jal	800007e0 <panic>

0000000080002c54 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002c54:	1101                	addi	sp,sp,-32
    80002c56:	ec06                	sd	ra,24(sp)
    80002c58:	e822                	sd	s0,16(sp)
    80002c5a:	e426                	sd	s1,8(sp)
    80002c5c:	e04a                	sd	s2,0(sp)
    80002c5e:	1000                	addi	s0,sp,32
    80002c60:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002c62:	01050913          	addi	s2,a0,16
    80002c66:	854a                	mv	a0,s2
    80002c68:	294010ef          	jal	80003efc <holdingsleep>
    80002c6c:	c135                	beqz	a0,80002cd0 <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    80002c6e:	854a                	mv	a0,s2
    80002c70:	254010ef          	jal	80003ec4 <releasesleep>

  acquire(&bcache.lock);
    80002c74:	00015517          	auipc	a0,0x15
    80002c78:	4ac50513          	addi	a0,a0,1196 # 80018120 <bcache>
    80002c7c:	f53fd0ef          	jal	80000bce <acquire>
  b->refcnt--;
    80002c80:	40bc                	lw	a5,64(s1)
    80002c82:	37fd                	addiw	a5,a5,-1
    80002c84:	0007871b          	sext.w	a4,a5
    80002c88:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002c8a:	e71d                	bnez	a4,80002cb8 <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002c8c:	68b8                	ld	a4,80(s1)
    80002c8e:	64bc                	ld	a5,72(s1)
    80002c90:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002c92:	68b8                	ld	a4,80(s1)
    80002c94:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002c96:	0001d797          	auipc	a5,0x1d
    80002c9a:	48a78793          	addi	a5,a5,1162 # 80020120 <bcache+0x8000>
    80002c9e:	2b87b703          	ld	a4,696(a5)
    80002ca2:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002ca4:	0001d717          	auipc	a4,0x1d
    80002ca8:	6e470713          	addi	a4,a4,1764 # 80020388 <bcache+0x8268>
    80002cac:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002cae:	2b87b703          	ld	a4,696(a5)
    80002cb2:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002cb4:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002cb8:	00015517          	auipc	a0,0x15
    80002cbc:	46850513          	addi	a0,a0,1128 # 80018120 <bcache>
    80002cc0:	fa7fd0ef          	jal	80000c66 <release>
}
    80002cc4:	60e2                	ld	ra,24(sp)
    80002cc6:	6442                	ld	s0,16(sp)
    80002cc8:	64a2                	ld	s1,8(sp)
    80002cca:	6902                	ld	s2,0(sp)
    80002ccc:	6105                	addi	sp,sp,32
    80002cce:	8082                	ret
    panic("brelse");
    80002cd0:	00004517          	auipc	a0,0x4
    80002cd4:	6f050513          	addi	a0,a0,1776 # 800073c0 <etext+0x3c0>
    80002cd8:	b09fd0ef          	jal	800007e0 <panic>

0000000080002cdc <bpin>:

void
bpin(struct buf *b) {
    80002cdc:	1101                	addi	sp,sp,-32
    80002cde:	ec06                	sd	ra,24(sp)
    80002ce0:	e822                	sd	s0,16(sp)
    80002ce2:	e426                	sd	s1,8(sp)
    80002ce4:	1000                	addi	s0,sp,32
    80002ce6:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002ce8:	00015517          	auipc	a0,0x15
    80002cec:	43850513          	addi	a0,a0,1080 # 80018120 <bcache>
    80002cf0:	edffd0ef          	jal	80000bce <acquire>
  b->refcnt++;
    80002cf4:	40bc                	lw	a5,64(s1)
    80002cf6:	2785                	addiw	a5,a5,1
    80002cf8:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002cfa:	00015517          	auipc	a0,0x15
    80002cfe:	42650513          	addi	a0,a0,1062 # 80018120 <bcache>
    80002d02:	f65fd0ef          	jal	80000c66 <release>
}
    80002d06:	60e2                	ld	ra,24(sp)
    80002d08:	6442                	ld	s0,16(sp)
    80002d0a:	64a2                	ld	s1,8(sp)
    80002d0c:	6105                	addi	sp,sp,32
    80002d0e:	8082                	ret

0000000080002d10 <bunpin>:

void
bunpin(struct buf *b) {
    80002d10:	1101                	addi	sp,sp,-32
    80002d12:	ec06                	sd	ra,24(sp)
    80002d14:	e822                	sd	s0,16(sp)
    80002d16:	e426                	sd	s1,8(sp)
    80002d18:	1000                	addi	s0,sp,32
    80002d1a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002d1c:	00015517          	auipc	a0,0x15
    80002d20:	40450513          	addi	a0,a0,1028 # 80018120 <bcache>
    80002d24:	eabfd0ef          	jal	80000bce <acquire>
  b->refcnt--;
    80002d28:	40bc                	lw	a5,64(s1)
    80002d2a:	37fd                	addiw	a5,a5,-1
    80002d2c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002d2e:	00015517          	auipc	a0,0x15
    80002d32:	3f250513          	addi	a0,a0,1010 # 80018120 <bcache>
    80002d36:	f31fd0ef          	jal	80000c66 <release>
}
    80002d3a:	60e2                	ld	ra,24(sp)
    80002d3c:	6442                	ld	s0,16(sp)
    80002d3e:	64a2                	ld	s1,8(sp)
    80002d40:	6105                	addi	sp,sp,32
    80002d42:	8082                	ret

0000000080002d44 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002d44:	1101                	addi	sp,sp,-32
    80002d46:	ec06                	sd	ra,24(sp)
    80002d48:	e822                	sd	s0,16(sp)
    80002d4a:	e426                	sd	s1,8(sp)
    80002d4c:	e04a                	sd	s2,0(sp)
    80002d4e:	1000                	addi	s0,sp,32
    80002d50:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002d52:	00d5d59b          	srliw	a1,a1,0xd
    80002d56:	0001e797          	auipc	a5,0x1e
    80002d5a:	aa67a783          	lw	a5,-1370(a5) # 800207fc <sb+0x1c>
    80002d5e:	9dbd                	addw	a1,a1,a5
    80002d60:	dedff0ef          	jal	80002b4c <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002d64:	0074f713          	andi	a4,s1,7
    80002d68:	4785                	li	a5,1
    80002d6a:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002d6e:	14ce                	slli	s1,s1,0x33
    80002d70:	90d9                	srli	s1,s1,0x36
    80002d72:	00950733          	add	a4,a0,s1
    80002d76:	05874703          	lbu	a4,88(a4)
    80002d7a:	00e7f6b3          	and	a3,a5,a4
    80002d7e:	c29d                	beqz	a3,80002da4 <bfree+0x60>
    80002d80:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002d82:	94aa                	add	s1,s1,a0
    80002d84:	fff7c793          	not	a5,a5
    80002d88:	8f7d                	and	a4,a4,a5
    80002d8a:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002d8e:	7f9000ef          	jal	80003d86 <log_write>
  brelse(bp);
    80002d92:	854a                	mv	a0,s2
    80002d94:	ec1ff0ef          	jal	80002c54 <brelse>
}
    80002d98:	60e2                	ld	ra,24(sp)
    80002d9a:	6442                	ld	s0,16(sp)
    80002d9c:	64a2                	ld	s1,8(sp)
    80002d9e:	6902                	ld	s2,0(sp)
    80002da0:	6105                	addi	sp,sp,32
    80002da2:	8082                	ret
    panic("freeing free block");
    80002da4:	00004517          	auipc	a0,0x4
    80002da8:	62450513          	addi	a0,a0,1572 # 800073c8 <etext+0x3c8>
    80002dac:	a35fd0ef          	jal	800007e0 <panic>

0000000080002db0 <balloc>:
{
    80002db0:	711d                	addi	sp,sp,-96
    80002db2:	ec86                	sd	ra,88(sp)
    80002db4:	e8a2                	sd	s0,80(sp)
    80002db6:	e4a6                	sd	s1,72(sp)
    80002db8:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002dba:	0001e797          	auipc	a5,0x1e
    80002dbe:	a2a7a783          	lw	a5,-1494(a5) # 800207e4 <sb+0x4>
    80002dc2:	0e078f63          	beqz	a5,80002ec0 <balloc+0x110>
    80002dc6:	e0ca                	sd	s2,64(sp)
    80002dc8:	fc4e                	sd	s3,56(sp)
    80002dca:	f852                	sd	s4,48(sp)
    80002dcc:	f456                	sd	s5,40(sp)
    80002dce:	f05a                	sd	s6,32(sp)
    80002dd0:	ec5e                	sd	s7,24(sp)
    80002dd2:	e862                	sd	s8,16(sp)
    80002dd4:	e466                	sd	s9,8(sp)
    80002dd6:	8baa                	mv	s7,a0
    80002dd8:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002dda:	0001eb17          	auipc	s6,0x1e
    80002dde:	a06b0b13          	addi	s6,s6,-1530 # 800207e0 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002de2:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002de4:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002de6:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002de8:	6c89                	lui	s9,0x2
    80002dea:	a0b5                	j	80002e56 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002dec:	97ca                	add	a5,a5,s2
    80002dee:	8e55                	or	a2,a2,a3
    80002df0:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002df4:	854a                	mv	a0,s2
    80002df6:	791000ef          	jal	80003d86 <log_write>
        brelse(bp);
    80002dfa:	854a                	mv	a0,s2
    80002dfc:	e59ff0ef          	jal	80002c54 <brelse>
  bp = bread(dev, bno);
    80002e00:	85a6                	mv	a1,s1
    80002e02:	855e                	mv	a0,s7
    80002e04:	d49ff0ef          	jal	80002b4c <bread>
    80002e08:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002e0a:	40000613          	li	a2,1024
    80002e0e:	4581                	li	a1,0
    80002e10:	05850513          	addi	a0,a0,88
    80002e14:	e8ffd0ef          	jal	80000ca2 <memset>
  log_write(bp);
    80002e18:	854a                	mv	a0,s2
    80002e1a:	76d000ef          	jal	80003d86 <log_write>
  brelse(bp);
    80002e1e:	854a                	mv	a0,s2
    80002e20:	e35ff0ef          	jal	80002c54 <brelse>
}
    80002e24:	6906                	ld	s2,64(sp)
    80002e26:	79e2                	ld	s3,56(sp)
    80002e28:	7a42                	ld	s4,48(sp)
    80002e2a:	7aa2                	ld	s5,40(sp)
    80002e2c:	7b02                	ld	s6,32(sp)
    80002e2e:	6be2                	ld	s7,24(sp)
    80002e30:	6c42                	ld	s8,16(sp)
    80002e32:	6ca2                	ld	s9,8(sp)
}
    80002e34:	8526                	mv	a0,s1
    80002e36:	60e6                	ld	ra,88(sp)
    80002e38:	6446                	ld	s0,80(sp)
    80002e3a:	64a6                	ld	s1,72(sp)
    80002e3c:	6125                	addi	sp,sp,96
    80002e3e:	8082                	ret
    brelse(bp);
    80002e40:	854a                	mv	a0,s2
    80002e42:	e13ff0ef          	jal	80002c54 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002e46:	015c87bb          	addw	a5,s9,s5
    80002e4a:	00078a9b          	sext.w	s5,a5
    80002e4e:	004b2703          	lw	a4,4(s6)
    80002e52:	04eaff63          	bgeu	s5,a4,80002eb0 <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    80002e56:	41fad79b          	sraiw	a5,s5,0x1f
    80002e5a:	0137d79b          	srliw	a5,a5,0x13
    80002e5e:	015787bb          	addw	a5,a5,s5
    80002e62:	40d7d79b          	sraiw	a5,a5,0xd
    80002e66:	01cb2583          	lw	a1,28(s6)
    80002e6a:	9dbd                	addw	a1,a1,a5
    80002e6c:	855e                	mv	a0,s7
    80002e6e:	cdfff0ef          	jal	80002b4c <bread>
    80002e72:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002e74:	004b2503          	lw	a0,4(s6)
    80002e78:	000a849b          	sext.w	s1,s5
    80002e7c:	8762                	mv	a4,s8
    80002e7e:	fca4f1e3          	bgeu	s1,a0,80002e40 <balloc+0x90>
      m = 1 << (bi % 8);
    80002e82:	00777693          	andi	a3,a4,7
    80002e86:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002e8a:	41f7579b          	sraiw	a5,a4,0x1f
    80002e8e:	01d7d79b          	srliw	a5,a5,0x1d
    80002e92:	9fb9                	addw	a5,a5,a4
    80002e94:	4037d79b          	sraiw	a5,a5,0x3
    80002e98:	00f90633          	add	a2,s2,a5
    80002e9c:	05864603          	lbu	a2,88(a2)
    80002ea0:	00c6f5b3          	and	a1,a3,a2
    80002ea4:	d5a1                	beqz	a1,80002dec <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002ea6:	2705                	addiw	a4,a4,1
    80002ea8:	2485                	addiw	s1,s1,1
    80002eaa:	fd471ae3          	bne	a4,s4,80002e7e <balloc+0xce>
    80002eae:	bf49                	j	80002e40 <balloc+0x90>
    80002eb0:	6906                	ld	s2,64(sp)
    80002eb2:	79e2                	ld	s3,56(sp)
    80002eb4:	7a42                	ld	s4,48(sp)
    80002eb6:	7aa2                	ld	s5,40(sp)
    80002eb8:	7b02                	ld	s6,32(sp)
    80002eba:	6be2                	ld	s7,24(sp)
    80002ebc:	6c42                	ld	s8,16(sp)
    80002ebe:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    80002ec0:	00004517          	auipc	a0,0x4
    80002ec4:	52050513          	addi	a0,a0,1312 # 800073e0 <etext+0x3e0>
    80002ec8:	e32fd0ef          	jal	800004fa <printf>
  return 0;
    80002ecc:	4481                	li	s1,0
    80002ece:	b79d                	j	80002e34 <balloc+0x84>

0000000080002ed0 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002ed0:	7179                	addi	sp,sp,-48
    80002ed2:	f406                	sd	ra,40(sp)
    80002ed4:	f022                	sd	s0,32(sp)
    80002ed6:	ec26                	sd	s1,24(sp)
    80002ed8:	e84a                	sd	s2,16(sp)
    80002eda:	e44e                	sd	s3,8(sp)
    80002edc:	1800                	addi	s0,sp,48
    80002ede:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002ee0:	47ad                	li	a5,11
    80002ee2:	02b7e663          	bltu	a5,a1,80002f0e <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    80002ee6:	02059793          	slli	a5,a1,0x20
    80002eea:	01e7d593          	srli	a1,a5,0x1e
    80002eee:	00b504b3          	add	s1,a0,a1
    80002ef2:	0504a903          	lw	s2,80(s1)
    80002ef6:	06091a63          	bnez	s2,80002f6a <bmap+0x9a>
      addr = balloc(ip->dev);
    80002efa:	4108                	lw	a0,0(a0)
    80002efc:	eb5ff0ef          	jal	80002db0 <balloc>
    80002f00:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002f04:	06090363          	beqz	s2,80002f6a <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    80002f08:	0524a823          	sw	s2,80(s1)
    80002f0c:	a8b9                	j	80002f6a <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002f0e:	ff45849b          	addiw	s1,a1,-12
    80002f12:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80002f16:	0ff00793          	li	a5,255
    80002f1a:	06e7ee63          	bltu	a5,a4,80002f96 <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80002f1e:	08052903          	lw	s2,128(a0)
    80002f22:	00091d63          	bnez	s2,80002f3c <bmap+0x6c>
      addr = balloc(ip->dev);
    80002f26:	4108                	lw	a0,0(a0)
    80002f28:	e89ff0ef          	jal	80002db0 <balloc>
    80002f2c:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002f30:	02090d63          	beqz	s2,80002f6a <bmap+0x9a>
    80002f34:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002f36:	0929a023          	sw	s2,128(s3)
    80002f3a:	a011                	j	80002f3e <bmap+0x6e>
    80002f3c:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80002f3e:	85ca                	mv	a1,s2
    80002f40:	0009a503          	lw	a0,0(s3)
    80002f44:	c09ff0ef          	jal	80002b4c <bread>
    80002f48:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80002f4a:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80002f4e:	02049713          	slli	a4,s1,0x20
    80002f52:	01e75593          	srli	a1,a4,0x1e
    80002f56:	00b784b3          	add	s1,a5,a1
    80002f5a:	0004a903          	lw	s2,0(s1)
    80002f5e:	00090e63          	beqz	s2,80002f7a <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002f62:	8552                	mv	a0,s4
    80002f64:	cf1ff0ef          	jal	80002c54 <brelse>
    return addr;
    80002f68:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80002f6a:	854a                	mv	a0,s2
    80002f6c:	70a2                	ld	ra,40(sp)
    80002f6e:	7402                	ld	s0,32(sp)
    80002f70:	64e2                	ld	s1,24(sp)
    80002f72:	6942                	ld	s2,16(sp)
    80002f74:	69a2                	ld	s3,8(sp)
    80002f76:	6145                	addi	sp,sp,48
    80002f78:	8082                	ret
      addr = balloc(ip->dev);
    80002f7a:	0009a503          	lw	a0,0(s3)
    80002f7e:	e33ff0ef          	jal	80002db0 <balloc>
    80002f82:	0005091b          	sext.w	s2,a0
      if(addr){
    80002f86:	fc090ee3          	beqz	s2,80002f62 <bmap+0x92>
        a[bn] = addr;
    80002f8a:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80002f8e:	8552                	mv	a0,s4
    80002f90:	5f7000ef          	jal	80003d86 <log_write>
    80002f94:	b7f9                	j	80002f62 <bmap+0x92>
    80002f96:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80002f98:	00004517          	auipc	a0,0x4
    80002f9c:	46050513          	addi	a0,a0,1120 # 800073f8 <etext+0x3f8>
    80002fa0:	841fd0ef          	jal	800007e0 <panic>

0000000080002fa4 <iget>:
{
    80002fa4:	7179                	addi	sp,sp,-48
    80002fa6:	f406                	sd	ra,40(sp)
    80002fa8:	f022                	sd	s0,32(sp)
    80002faa:	ec26                	sd	s1,24(sp)
    80002fac:	e84a                	sd	s2,16(sp)
    80002fae:	e44e                	sd	s3,8(sp)
    80002fb0:	e052                	sd	s4,0(sp)
    80002fb2:	1800                	addi	s0,sp,48
    80002fb4:	89aa                	mv	s3,a0
    80002fb6:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80002fb8:	0001e517          	auipc	a0,0x1e
    80002fbc:	84850513          	addi	a0,a0,-1976 # 80020800 <itable>
    80002fc0:	c0ffd0ef          	jal	80000bce <acquire>
  empty = 0;
    80002fc4:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002fc6:	0001e497          	auipc	s1,0x1e
    80002fca:	85248493          	addi	s1,s1,-1966 # 80020818 <itable+0x18>
    80002fce:	0001f697          	auipc	a3,0x1f
    80002fd2:	2da68693          	addi	a3,a3,730 # 800222a8 <log>
    80002fd6:	a039                	j	80002fe4 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002fd8:	02090963          	beqz	s2,8000300a <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002fdc:	08848493          	addi	s1,s1,136
    80002fe0:	02d48863          	beq	s1,a3,80003010 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80002fe4:	449c                	lw	a5,8(s1)
    80002fe6:	fef059e3          	blez	a5,80002fd8 <iget+0x34>
    80002fea:	4098                	lw	a4,0(s1)
    80002fec:	ff3716e3          	bne	a4,s3,80002fd8 <iget+0x34>
    80002ff0:	40d8                	lw	a4,4(s1)
    80002ff2:	ff4713e3          	bne	a4,s4,80002fd8 <iget+0x34>
      ip->ref++;
    80002ff6:	2785                	addiw	a5,a5,1
    80002ff8:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80002ffa:	0001e517          	auipc	a0,0x1e
    80002ffe:	80650513          	addi	a0,a0,-2042 # 80020800 <itable>
    80003002:	c65fd0ef          	jal	80000c66 <release>
      return ip;
    80003006:	8926                	mv	s2,s1
    80003008:	a02d                	j	80003032 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000300a:	fbe9                	bnez	a5,80002fdc <iget+0x38>
      empty = ip;
    8000300c:	8926                	mv	s2,s1
    8000300e:	b7f9                	j	80002fdc <iget+0x38>
  if(empty == 0)
    80003010:	02090a63          	beqz	s2,80003044 <iget+0xa0>
  ip->dev = dev;
    80003014:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003018:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000301c:	4785                	li	a5,1
    8000301e:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003022:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003026:	0001d517          	auipc	a0,0x1d
    8000302a:	7da50513          	addi	a0,a0,2010 # 80020800 <itable>
    8000302e:	c39fd0ef          	jal	80000c66 <release>
}
    80003032:	854a                	mv	a0,s2
    80003034:	70a2                	ld	ra,40(sp)
    80003036:	7402                	ld	s0,32(sp)
    80003038:	64e2                	ld	s1,24(sp)
    8000303a:	6942                	ld	s2,16(sp)
    8000303c:	69a2                	ld	s3,8(sp)
    8000303e:	6a02                	ld	s4,0(sp)
    80003040:	6145                	addi	sp,sp,48
    80003042:	8082                	ret
    panic("iget: no inodes");
    80003044:	00004517          	auipc	a0,0x4
    80003048:	3cc50513          	addi	a0,a0,972 # 80007410 <etext+0x410>
    8000304c:	f94fd0ef          	jal	800007e0 <panic>

0000000080003050 <iinit>:
{
    80003050:	7179                	addi	sp,sp,-48
    80003052:	f406                	sd	ra,40(sp)
    80003054:	f022                	sd	s0,32(sp)
    80003056:	ec26                	sd	s1,24(sp)
    80003058:	e84a                	sd	s2,16(sp)
    8000305a:	e44e                	sd	s3,8(sp)
    8000305c:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000305e:	00004597          	auipc	a1,0x4
    80003062:	3c258593          	addi	a1,a1,962 # 80007420 <etext+0x420>
    80003066:	0001d517          	auipc	a0,0x1d
    8000306a:	79a50513          	addi	a0,a0,1946 # 80020800 <itable>
    8000306e:	ae1fd0ef          	jal	80000b4e <initlock>
  for(i = 0; i < NINODE; i++) {
    80003072:	0001d497          	auipc	s1,0x1d
    80003076:	7b648493          	addi	s1,s1,1974 # 80020828 <itable+0x28>
    8000307a:	0001f997          	auipc	s3,0x1f
    8000307e:	23e98993          	addi	s3,s3,574 # 800222b8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003082:	00004917          	auipc	s2,0x4
    80003086:	3a690913          	addi	s2,s2,934 # 80007428 <etext+0x428>
    8000308a:	85ca                	mv	a1,s2
    8000308c:	8526                	mv	a0,s1
    8000308e:	5bb000ef          	jal	80003e48 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003092:	08848493          	addi	s1,s1,136
    80003096:	ff349ae3          	bne	s1,s3,8000308a <iinit+0x3a>
}
    8000309a:	70a2                	ld	ra,40(sp)
    8000309c:	7402                	ld	s0,32(sp)
    8000309e:	64e2                	ld	s1,24(sp)
    800030a0:	6942                	ld	s2,16(sp)
    800030a2:	69a2                	ld	s3,8(sp)
    800030a4:	6145                	addi	sp,sp,48
    800030a6:	8082                	ret

00000000800030a8 <ialloc>:
{
    800030a8:	7139                	addi	sp,sp,-64
    800030aa:	fc06                	sd	ra,56(sp)
    800030ac:	f822                	sd	s0,48(sp)
    800030ae:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800030b0:	0001d717          	auipc	a4,0x1d
    800030b4:	73c72703          	lw	a4,1852(a4) # 800207ec <sb+0xc>
    800030b8:	4785                	li	a5,1
    800030ba:	06e7f063          	bgeu	a5,a4,8000311a <ialloc+0x72>
    800030be:	f426                	sd	s1,40(sp)
    800030c0:	f04a                	sd	s2,32(sp)
    800030c2:	ec4e                	sd	s3,24(sp)
    800030c4:	e852                	sd	s4,16(sp)
    800030c6:	e456                	sd	s5,8(sp)
    800030c8:	e05a                	sd	s6,0(sp)
    800030ca:	8aaa                	mv	s5,a0
    800030cc:	8b2e                	mv	s6,a1
    800030ce:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    800030d0:	0001da17          	auipc	s4,0x1d
    800030d4:	710a0a13          	addi	s4,s4,1808 # 800207e0 <sb>
    800030d8:	00495593          	srli	a1,s2,0x4
    800030dc:	018a2783          	lw	a5,24(s4)
    800030e0:	9dbd                	addw	a1,a1,a5
    800030e2:	8556                	mv	a0,s5
    800030e4:	a69ff0ef          	jal	80002b4c <bread>
    800030e8:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800030ea:	05850993          	addi	s3,a0,88
    800030ee:	00f97793          	andi	a5,s2,15
    800030f2:	079a                	slli	a5,a5,0x6
    800030f4:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800030f6:	00099783          	lh	a5,0(s3)
    800030fa:	cb9d                	beqz	a5,80003130 <ialloc+0x88>
    brelse(bp);
    800030fc:	b59ff0ef          	jal	80002c54 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003100:	0905                	addi	s2,s2,1
    80003102:	00ca2703          	lw	a4,12(s4)
    80003106:	0009079b          	sext.w	a5,s2
    8000310a:	fce7e7e3          	bltu	a5,a4,800030d8 <ialloc+0x30>
    8000310e:	74a2                	ld	s1,40(sp)
    80003110:	7902                	ld	s2,32(sp)
    80003112:	69e2                	ld	s3,24(sp)
    80003114:	6a42                	ld	s4,16(sp)
    80003116:	6aa2                	ld	s5,8(sp)
    80003118:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    8000311a:	00004517          	auipc	a0,0x4
    8000311e:	31650513          	addi	a0,a0,790 # 80007430 <etext+0x430>
    80003122:	bd8fd0ef          	jal	800004fa <printf>
  return 0;
    80003126:	4501                	li	a0,0
}
    80003128:	70e2                	ld	ra,56(sp)
    8000312a:	7442                	ld	s0,48(sp)
    8000312c:	6121                	addi	sp,sp,64
    8000312e:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003130:	04000613          	li	a2,64
    80003134:	4581                	li	a1,0
    80003136:	854e                	mv	a0,s3
    80003138:	b6bfd0ef          	jal	80000ca2 <memset>
      dip->type = type;
    8000313c:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003140:	8526                	mv	a0,s1
    80003142:	445000ef          	jal	80003d86 <log_write>
      brelse(bp);
    80003146:	8526                	mv	a0,s1
    80003148:	b0dff0ef          	jal	80002c54 <brelse>
      return iget(dev, inum);
    8000314c:	0009059b          	sext.w	a1,s2
    80003150:	8556                	mv	a0,s5
    80003152:	e53ff0ef          	jal	80002fa4 <iget>
    80003156:	74a2                	ld	s1,40(sp)
    80003158:	7902                	ld	s2,32(sp)
    8000315a:	69e2                	ld	s3,24(sp)
    8000315c:	6a42                	ld	s4,16(sp)
    8000315e:	6aa2                	ld	s5,8(sp)
    80003160:	6b02                	ld	s6,0(sp)
    80003162:	b7d9                	j	80003128 <ialloc+0x80>

0000000080003164 <iupdate>:
{
    80003164:	1101                	addi	sp,sp,-32
    80003166:	ec06                	sd	ra,24(sp)
    80003168:	e822                	sd	s0,16(sp)
    8000316a:	e426                	sd	s1,8(sp)
    8000316c:	e04a                	sd	s2,0(sp)
    8000316e:	1000                	addi	s0,sp,32
    80003170:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003172:	415c                	lw	a5,4(a0)
    80003174:	0047d79b          	srliw	a5,a5,0x4
    80003178:	0001d597          	auipc	a1,0x1d
    8000317c:	6805a583          	lw	a1,1664(a1) # 800207f8 <sb+0x18>
    80003180:	9dbd                	addw	a1,a1,a5
    80003182:	4108                	lw	a0,0(a0)
    80003184:	9c9ff0ef          	jal	80002b4c <bread>
    80003188:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000318a:	05850793          	addi	a5,a0,88
    8000318e:	40d8                	lw	a4,4(s1)
    80003190:	8b3d                	andi	a4,a4,15
    80003192:	071a                	slli	a4,a4,0x6
    80003194:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003196:	04449703          	lh	a4,68(s1)
    8000319a:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    8000319e:	04649703          	lh	a4,70(s1)
    800031a2:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800031a6:	04849703          	lh	a4,72(s1)
    800031aa:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800031ae:	04a49703          	lh	a4,74(s1)
    800031b2:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800031b6:	44f8                	lw	a4,76(s1)
    800031b8:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800031ba:	03400613          	li	a2,52
    800031be:	05048593          	addi	a1,s1,80
    800031c2:	00c78513          	addi	a0,a5,12
    800031c6:	b39fd0ef          	jal	80000cfe <memmove>
  log_write(bp);
    800031ca:	854a                	mv	a0,s2
    800031cc:	3bb000ef          	jal	80003d86 <log_write>
  brelse(bp);
    800031d0:	854a                	mv	a0,s2
    800031d2:	a83ff0ef          	jal	80002c54 <brelse>
}
    800031d6:	60e2                	ld	ra,24(sp)
    800031d8:	6442                	ld	s0,16(sp)
    800031da:	64a2                	ld	s1,8(sp)
    800031dc:	6902                	ld	s2,0(sp)
    800031de:	6105                	addi	sp,sp,32
    800031e0:	8082                	ret

00000000800031e2 <idup>:
{
    800031e2:	1101                	addi	sp,sp,-32
    800031e4:	ec06                	sd	ra,24(sp)
    800031e6:	e822                	sd	s0,16(sp)
    800031e8:	e426                	sd	s1,8(sp)
    800031ea:	1000                	addi	s0,sp,32
    800031ec:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800031ee:	0001d517          	auipc	a0,0x1d
    800031f2:	61250513          	addi	a0,a0,1554 # 80020800 <itable>
    800031f6:	9d9fd0ef          	jal	80000bce <acquire>
  ip->ref++;
    800031fa:	449c                	lw	a5,8(s1)
    800031fc:	2785                	addiw	a5,a5,1
    800031fe:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003200:	0001d517          	auipc	a0,0x1d
    80003204:	60050513          	addi	a0,a0,1536 # 80020800 <itable>
    80003208:	a5ffd0ef          	jal	80000c66 <release>
}
    8000320c:	8526                	mv	a0,s1
    8000320e:	60e2                	ld	ra,24(sp)
    80003210:	6442                	ld	s0,16(sp)
    80003212:	64a2                	ld	s1,8(sp)
    80003214:	6105                	addi	sp,sp,32
    80003216:	8082                	ret

0000000080003218 <ilock>:
{
    80003218:	1101                	addi	sp,sp,-32
    8000321a:	ec06                	sd	ra,24(sp)
    8000321c:	e822                	sd	s0,16(sp)
    8000321e:	e426                	sd	s1,8(sp)
    80003220:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003222:	cd19                	beqz	a0,80003240 <ilock+0x28>
    80003224:	84aa                	mv	s1,a0
    80003226:	451c                	lw	a5,8(a0)
    80003228:	00f05c63          	blez	a5,80003240 <ilock+0x28>
  acquiresleep(&ip->lock);
    8000322c:	0541                	addi	a0,a0,16
    8000322e:	451000ef          	jal	80003e7e <acquiresleep>
  if(ip->valid == 0){
    80003232:	40bc                	lw	a5,64(s1)
    80003234:	cf89                	beqz	a5,8000324e <ilock+0x36>
}
    80003236:	60e2                	ld	ra,24(sp)
    80003238:	6442                	ld	s0,16(sp)
    8000323a:	64a2                	ld	s1,8(sp)
    8000323c:	6105                	addi	sp,sp,32
    8000323e:	8082                	ret
    80003240:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003242:	00004517          	auipc	a0,0x4
    80003246:	20650513          	addi	a0,a0,518 # 80007448 <etext+0x448>
    8000324a:	d96fd0ef          	jal	800007e0 <panic>
    8000324e:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003250:	40dc                	lw	a5,4(s1)
    80003252:	0047d79b          	srliw	a5,a5,0x4
    80003256:	0001d597          	auipc	a1,0x1d
    8000325a:	5a25a583          	lw	a1,1442(a1) # 800207f8 <sb+0x18>
    8000325e:	9dbd                	addw	a1,a1,a5
    80003260:	4088                	lw	a0,0(s1)
    80003262:	8ebff0ef          	jal	80002b4c <bread>
    80003266:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003268:	05850593          	addi	a1,a0,88
    8000326c:	40dc                	lw	a5,4(s1)
    8000326e:	8bbd                	andi	a5,a5,15
    80003270:	079a                	slli	a5,a5,0x6
    80003272:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003274:	00059783          	lh	a5,0(a1)
    80003278:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000327c:	00259783          	lh	a5,2(a1)
    80003280:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003284:	00459783          	lh	a5,4(a1)
    80003288:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000328c:	00659783          	lh	a5,6(a1)
    80003290:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003294:	459c                	lw	a5,8(a1)
    80003296:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003298:	03400613          	li	a2,52
    8000329c:	05b1                	addi	a1,a1,12
    8000329e:	05048513          	addi	a0,s1,80
    800032a2:	a5dfd0ef          	jal	80000cfe <memmove>
    brelse(bp);
    800032a6:	854a                	mv	a0,s2
    800032a8:	9adff0ef          	jal	80002c54 <brelse>
    ip->valid = 1;
    800032ac:	4785                	li	a5,1
    800032ae:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800032b0:	04449783          	lh	a5,68(s1)
    800032b4:	c399                	beqz	a5,800032ba <ilock+0xa2>
    800032b6:	6902                	ld	s2,0(sp)
    800032b8:	bfbd                	j	80003236 <ilock+0x1e>
      panic("ilock: no type");
    800032ba:	00004517          	auipc	a0,0x4
    800032be:	19650513          	addi	a0,a0,406 # 80007450 <etext+0x450>
    800032c2:	d1efd0ef          	jal	800007e0 <panic>

00000000800032c6 <iunlock>:
{
    800032c6:	1101                	addi	sp,sp,-32
    800032c8:	ec06                	sd	ra,24(sp)
    800032ca:	e822                	sd	s0,16(sp)
    800032cc:	e426                	sd	s1,8(sp)
    800032ce:	e04a                	sd	s2,0(sp)
    800032d0:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800032d2:	c505                	beqz	a0,800032fa <iunlock+0x34>
    800032d4:	84aa                	mv	s1,a0
    800032d6:	01050913          	addi	s2,a0,16
    800032da:	854a                	mv	a0,s2
    800032dc:	421000ef          	jal	80003efc <holdingsleep>
    800032e0:	cd09                	beqz	a0,800032fa <iunlock+0x34>
    800032e2:	449c                	lw	a5,8(s1)
    800032e4:	00f05b63          	blez	a5,800032fa <iunlock+0x34>
  releasesleep(&ip->lock);
    800032e8:	854a                	mv	a0,s2
    800032ea:	3db000ef          	jal	80003ec4 <releasesleep>
}
    800032ee:	60e2                	ld	ra,24(sp)
    800032f0:	6442                	ld	s0,16(sp)
    800032f2:	64a2                	ld	s1,8(sp)
    800032f4:	6902                	ld	s2,0(sp)
    800032f6:	6105                	addi	sp,sp,32
    800032f8:	8082                	ret
    panic("iunlock");
    800032fa:	00004517          	auipc	a0,0x4
    800032fe:	16650513          	addi	a0,a0,358 # 80007460 <etext+0x460>
    80003302:	cdefd0ef          	jal	800007e0 <panic>

0000000080003306 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003306:	7179                	addi	sp,sp,-48
    80003308:	f406                	sd	ra,40(sp)
    8000330a:	f022                	sd	s0,32(sp)
    8000330c:	ec26                	sd	s1,24(sp)
    8000330e:	e84a                	sd	s2,16(sp)
    80003310:	e44e                	sd	s3,8(sp)
    80003312:	1800                	addi	s0,sp,48
    80003314:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003316:	05050493          	addi	s1,a0,80
    8000331a:	08050913          	addi	s2,a0,128
    8000331e:	a021                	j	80003326 <itrunc+0x20>
    80003320:	0491                	addi	s1,s1,4
    80003322:	01248b63          	beq	s1,s2,80003338 <itrunc+0x32>
    if(ip->addrs[i]){
    80003326:	408c                	lw	a1,0(s1)
    80003328:	dde5                	beqz	a1,80003320 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    8000332a:	0009a503          	lw	a0,0(s3)
    8000332e:	a17ff0ef          	jal	80002d44 <bfree>
      ip->addrs[i] = 0;
    80003332:	0004a023          	sw	zero,0(s1)
    80003336:	b7ed                	j	80003320 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003338:	0809a583          	lw	a1,128(s3)
    8000333c:	ed89                	bnez	a1,80003356 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000333e:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003342:	854e                	mv	a0,s3
    80003344:	e21ff0ef          	jal	80003164 <iupdate>
}
    80003348:	70a2                	ld	ra,40(sp)
    8000334a:	7402                	ld	s0,32(sp)
    8000334c:	64e2                	ld	s1,24(sp)
    8000334e:	6942                	ld	s2,16(sp)
    80003350:	69a2                	ld	s3,8(sp)
    80003352:	6145                	addi	sp,sp,48
    80003354:	8082                	ret
    80003356:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003358:	0009a503          	lw	a0,0(s3)
    8000335c:	ff0ff0ef          	jal	80002b4c <bread>
    80003360:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003362:	05850493          	addi	s1,a0,88
    80003366:	45850913          	addi	s2,a0,1112
    8000336a:	a021                	j	80003372 <itrunc+0x6c>
    8000336c:	0491                	addi	s1,s1,4
    8000336e:	01248963          	beq	s1,s2,80003380 <itrunc+0x7a>
      if(a[j])
    80003372:	408c                	lw	a1,0(s1)
    80003374:	dde5                	beqz	a1,8000336c <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80003376:	0009a503          	lw	a0,0(s3)
    8000337a:	9cbff0ef          	jal	80002d44 <bfree>
    8000337e:	b7fd                	j	8000336c <itrunc+0x66>
    brelse(bp);
    80003380:	8552                	mv	a0,s4
    80003382:	8d3ff0ef          	jal	80002c54 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003386:	0809a583          	lw	a1,128(s3)
    8000338a:	0009a503          	lw	a0,0(s3)
    8000338e:	9b7ff0ef          	jal	80002d44 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003392:	0809a023          	sw	zero,128(s3)
    80003396:	6a02                	ld	s4,0(sp)
    80003398:	b75d                	j	8000333e <itrunc+0x38>

000000008000339a <iput>:
{
    8000339a:	1101                	addi	sp,sp,-32
    8000339c:	ec06                	sd	ra,24(sp)
    8000339e:	e822                	sd	s0,16(sp)
    800033a0:	e426                	sd	s1,8(sp)
    800033a2:	1000                	addi	s0,sp,32
    800033a4:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800033a6:	0001d517          	auipc	a0,0x1d
    800033aa:	45a50513          	addi	a0,a0,1114 # 80020800 <itable>
    800033ae:	821fd0ef          	jal	80000bce <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800033b2:	4498                	lw	a4,8(s1)
    800033b4:	4785                	li	a5,1
    800033b6:	02f70063          	beq	a4,a5,800033d6 <iput+0x3c>
  ip->ref--;
    800033ba:	449c                	lw	a5,8(s1)
    800033bc:	37fd                	addiw	a5,a5,-1
    800033be:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800033c0:	0001d517          	auipc	a0,0x1d
    800033c4:	44050513          	addi	a0,a0,1088 # 80020800 <itable>
    800033c8:	89ffd0ef          	jal	80000c66 <release>
}
    800033cc:	60e2                	ld	ra,24(sp)
    800033ce:	6442                	ld	s0,16(sp)
    800033d0:	64a2                	ld	s1,8(sp)
    800033d2:	6105                	addi	sp,sp,32
    800033d4:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800033d6:	40bc                	lw	a5,64(s1)
    800033d8:	d3ed                	beqz	a5,800033ba <iput+0x20>
    800033da:	04a49783          	lh	a5,74(s1)
    800033de:	fff1                	bnez	a5,800033ba <iput+0x20>
    800033e0:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    800033e2:	01048913          	addi	s2,s1,16
    800033e6:	854a                	mv	a0,s2
    800033e8:	297000ef          	jal	80003e7e <acquiresleep>
    release(&itable.lock);
    800033ec:	0001d517          	auipc	a0,0x1d
    800033f0:	41450513          	addi	a0,a0,1044 # 80020800 <itable>
    800033f4:	873fd0ef          	jal	80000c66 <release>
    itrunc(ip);
    800033f8:	8526                	mv	a0,s1
    800033fa:	f0dff0ef          	jal	80003306 <itrunc>
    ip->type = 0;
    800033fe:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003402:	8526                	mv	a0,s1
    80003404:	d61ff0ef          	jal	80003164 <iupdate>
    ip->valid = 0;
    80003408:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000340c:	854a                	mv	a0,s2
    8000340e:	2b7000ef          	jal	80003ec4 <releasesleep>
    acquire(&itable.lock);
    80003412:	0001d517          	auipc	a0,0x1d
    80003416:	3ee50513          	addi	a0,a0,1006 # 80020800 <itable>
    8000341a:	fb4fd0ef          	jal	80000bce <acquire>
    8000341e:	6902                	ld	s2,0(sp)
    80003420:	bf69                	j	800033ba <iput+0x20>

0000000080003422 <iunlockput>:
{
    80003422:	1101                	addi	sp,sp,-32
    80003424:	ec06                	sd	ra,24(sp)
    80003426:	e822                	sd	s0,16(sp)
    80003428:	e426                	sd	s1,8(sp)
    8000342a:	1000                	addi	s0,sp,32
    8000342c:	84aa                	mv	s1,a0
  iunlock(ip);
    8000342e:	e99ff0ef          	jal	800032c6 <iunlock>
  iput(ip);
    80003432:	8526                	mv	a0,s1
    80003434:	f67ff0ef          	jal	8000339a <iput>
}
    80003438:	60e2                	ld	ra,24(sp)
    8000343a:	6442                	ld	s0,16(sp)
    8000343c:	64a2                	ld	s1,8(sp)
    8000343e:	6105                	addi	sp,sp,32
    80003440:	8082                	ret

0000000080003442 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003442:	0001d717          	auipc	a4,0x1d
    80003446:	3aa72703          	lw	a4,938(a4) # 800207ec <sb+0xc>
    8000344a:	4785                	li	a5,1
    8000344c:	0ae7ff63          	bgeu	a5,a4,8000350a <ireclaim+0xc8>
{
    80003450:	7139                	addi	sp,sp,-64
    80003452:	fc06                	sd	ra,56(sp)
    80003454:	f822                	sd	s0,48(sp)
    80003456:	f426                	sd	s1,40(sp)
    80003458:	f04a                	sd	s2,32(sp)
    8000345a:	ec4e                	sd	s3,24(sp)
    8000345c:	e852                	sd	s4,16(sp)
    8000345e:	e456                	sd	s5,8(sp)
    80003460:	e05a                	sd	s6,0(sp)
    80003462:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003464:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003466:	00050a1b          	sext.w	s4,a0
    8000346a:	0001da97          	auipc	s5,0x1d
    8000346e:	376a8a93          	addi	s5,s5,886 # 800207e0 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    80003472:	00004b17          	auipc	s6,0x4
    80003476:	ff6b0b13          	addi	s6,s6,-10 # 80007468 <etext+0x468>
    8000347a:	a099                	j	800034c0 <ireclaim+0x7e>
    8000347c:	85ce                	mv	a1,s3
    8000347e:	855a                	mv	a0,s6
    80003480:	87afd0ef          	jal	800004fa <printf>
      ip = iget(dev, inum);
    80003484:	85ce                	mv	a1,s3
    80003486:	8552                	mv	a0,s4
    80003488:	b1dff0ef          	jal	80002fa4 <iget>
    8000348c:	89aa                	mv	s3,a0
    brelse(bp);
    8000348e:	854a                	mv	a0,s2
    80003490:	fc4ff0ef          	jal	80002c54 <brelse>
    if (ip) {
    80003494:	00098f63          	beqz	s3,800034b2 <ireclaim+0x70>
      begin_op();
    80003498:	76a000ef          	jal	80003c02 <begin_op>
      ilock(ip);
    8000349c:	854e                	mv	a0,s3
    8000349e:	d7bff0ef          	jal	80003218 <ilock>
      iunlock(ip);
    800034a2:	854e                	mv	a0,s3
    800034a4:	e23ff0ef          	jal	800032c6 <iunlock>
      iput(ip);
    800034a8:	854e                	mv	a0,s3
    800034aa:	ef1ff0ef          	jal	8000339a <iput>
      end_op();
    800034ae:	7be000ef          	jal	80003c6c <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800034b2:	0485                	addi	s1,s1,1
    800034b4:	00caa703          	lw	a4,12(s5)
    800034b8:	0004879b          	sext.w	a5,s1
    800034bc:	02e7fd63          	bgeu	a5,a4,800034f6 <ireclaim+0xb4>
    800034c0:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800034c4:	0044d593          	srli	a1,s1,0x4
    800034c8:	018aa783          	lw	a5,24(s5)
    800034cc:	9dbd                	addw	a1,a1,a5
    800034ce:	8552                	mv	a0,s4
    800034d0:	e7cff0ef          	jal	80002b4c <bread>
    800034d4:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    800034d6:	05850793          	addi	a5,a0,88
    800034da:	00f9f713          	andi	a4,s3,15
    800034de:	071a                	slli	a4,a4,0x6
    800034e0:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    800034e2:	00079703          	lh	a4,0(a5)
    800034e6:	c701                	beqz	a4,800034ee <ireclaim+0xac>
    800034e8:	00679783          	lh	a5,6(a5)
    800034ec:	dbc1                	beqz	a5,8000347c <ireclaim+0x3a>
    brelse(bp);
    800034ee:	854a                	mv	a0,s2
    800034f0:	f64ff0ef          	jal	80002c54 <brelse>
    if (ip) {
    800034f4:	bf7d                	j	800034b2 <ireclaim+0x70>
}
    800034f6:	70e2                	ld	ra,56(sp)
    800034f8:	7442                	ld	s0,48(sp)
    800034fa:	74a2                	ld	s1,40(sp)
    800034fc:	7902                	ld	s2,32(sp)
    800034fe:	69e2                	ld	s3,24(sp)
    80003500:	6a42                	ld	s4,16(sp)
    80003502:	6aa2                	ld	s5,8(sp)
    80003504:	6b02                	ld	s6,0(sp)
    80003506:	6121                	addi	sp,sp,64
    80003508:	8082                	ret
    8000350a:	8082                	ret

000000008000350c <fsinit>:
fsinit(int dev) {
    8000350c:	7179                	addi	sp,sp,-48
    8000350e:	f406                	sd	ra,40(sp)
    80003510:	f022                	sd	s0,32(sp)
    80003512:	ec26                	sd	s1,24(sp)
    80003514:	e84a                	sd	s2,16(sp)
    80003516:	e44e                	sd	s3,8(sp)
    80003518:	1800                	addi	s0,sp,48
    8000351a:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    8000351c:	4585                	li	a1,1
    8000351e:	e2eff0ef          	jal	80002b4c <bread>
    80003522:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003524:	0001d997          	auipc	s3,0x1d
    80003528:	2bc98993          	addi	s3,s3,700 # 800207e0 <sb>
    8000352c:	02000613          	li	a2,32
    80003530:	05850593          	addi	a1,a0,88
    80003534:	854e                	mv	a0,s3
    80003536:	fc8fd0ef          	jal	80000cfe <memmove>
  brelse(bp);
    8000353a:	854a                	mv	a0,s2
    8000353c:	f18ff0ef          	jal	80002c54 <brelse>
  if(sb.magic != FSMAGIC)
    80003540:	0009a703          	lw	a4,0(s3)
    80003544:	102037b7          	lui	a5,0x10203
    80003548:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000354c:	02f71363          	bne	a4,a5,80003572 <fsinit+0x66>
  initlog(dev, &sb);
    80003550:	0001d597          	auipc	a1,0x1d
    80003554:	29058593          	addi	a1,a1,656 # 800207e0 <sb>
    80003558:	8526                	mv	a0,s1
    8000355a:	62a000ef          	jal	80003b84 <initlog>
  ireclaim(dev);
    8000355e:	8526                	mv	a0,s1
    80003560:	ee3ff0ef          	jal	80003442 <ireclaim>
}
    80003564:	70a2                	ld	ra,40(sp)
    80003566:	7402                	ld	s0,32(sp)
    80003568:	64e2                	ld	s1,24(sp)
    8000356a:	6942                	ld	s2,16(sp)
    8000356c:	69a2                	ld	s3,8(sp)
    8000356e:	6145                	addi	sp,sp,48
    80003570:	8082                	ret
    panic("invalid file system");
    80003572:	00004517          	auipc	a0,0x4
    80003576:	f1650513          	addi	a0,a0,-234 # 80007488 <etext+0x488>
    8000357a:	a66fd0ef          	jal	800007e0 <panic>

000000008000357e <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000357e:	1141                	addi	sp,sp,-16
    80003580:	e422                	sd	s0,8(sp)
    80003582:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003584:	411c                	lw	a5,0(a0)
    80003586:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003588:	415c                	lw	a5,4(a0)
    8000358a:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000358c:	04451783          	lh	a5,68(a0)
    80003590:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003594:	04a51783          	lh	a5,74(a0)
    80003598:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000359c:	04c56783          	lwu	a5,76(a0)
    800035a0:	e99c                	sd	a5,16(a1)
}
    800035a2:	6422                	ld	s0,8(sp)
    800035a4:	0141                	addi	sp,sp,16
    800035a6:	8082                	ret

00000000800035a8 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800035a8:	457c                	lw	a5,76(a0)
    800035aa:	0ed7eb63          	bltu	a5,a3,800036a0 <readi+0xf8>
{
    800035ae:	7159                	addi	sp,sp,-112
    800035b0:	f486                	sd	ra,104(sp)
    800035b2:	f0a2                	sd	s0,96(sp)
    800035b4:	eca6                	sd	s1,88(sp)
    800035b6:	e0d2                	sd	s4,64(sp)
    800035b8:	fc56                	sd	s5,56(sp)
    800035ba:	f85a                	sd	s6,48(sp)
    800035bc:	f45e                	sd	s7,40(sp)
    800035be:	1880                	addi	s0,sp,112
    800035c0:	8b2a                	mv	s6,a0
    800035c2:	8bae                	mv	s7,a1
    800035c4:	8a32                	mv	s4,a2
    800035c6:	84b6                	mv	s1,a3
    800035c8:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    800035ca:	9f35                	addw	a4,a4,a3
    return 0;
    800035cc:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800035ce:	0cd76063          	bltu	a4,a3,8000368e <readi+0xe6>
    800035d2:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    800035d4:	00e7f463          	bgeu	a5,a4,800035dc <readi+0x34>
    n = ip->size - off;
    800035d8:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800035dc:	080a8f63          	beqz	s5,8000367a <readi+0xd2>
    800035e0:	e8ca                	sd	s2,80(sp)
    800035e2:	f062                	sd	s8,32(sp)
    800035e4:	ec66                	sd	s9,24(sp)
    800035e6:	e86a                	sd	s10,16(sp)
    800035e8:	e46e                	sd	s11,8(sp)
    800035ea:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800035ec:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800035f0:	5c7d                	li	s8,-1
    800035f2:	a80d                	j	80003624 <readi+0x7c>
    800035f4:	020d1d93          	slli	s11,s10,0x20
    800035f8:	020ddd93          	srli	s11,s11,0x20
    800035fc:	05890613          	addi	a2,s2,88
    80003600:	86ee                	mv	a3,s11
    80003602:	963a                	add	a2,a2,a4
    80003604:	85d2                	mv	a1,s4
    80003606:	855e                	mv	a0,s7
    80003608:	c1bfe0ef          	jal	80002222 <either_copyout>
    8000360c:	05850763          	beq	a0,s8,8000365a <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003610:	854a                	mv	a0,s2
    80003612:	e42ff0ef          	jal	80002c54 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003616:	013d09bb          	addw	s3,s10,s3
    8000361a:	009d04bb          	addw	s1,s10,s1
    8000361e:	9a6e                	add	s4,s4,s11
    80003620:	0559f763          	bgeu	s3,s5,8000366e <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    80003624:	00a4d59b          	srliw	a1,s1,0xa
    80003628:	855a                	mv	a0,s6
    8000362a:	8a7ff0ef          	jal	80002ed0 <bmap>
    8000362e:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003632:	c5b1                	beqz	a1,8000367e <readi+0xd6>
    bp = bread(ip->dev, addr);
    80003634:	000b2503          	lw	a0,0(s6)
    80003638:	d14ff0ef          	jal	80002b4c <bread>
    8000363c:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000363e:	3ff4f713          	andi	a4,s1,1023
    80003642:	40ec87bb          	subw	a5,s9,a4
    80003646:	413a86bb          	subw	a3,s5,s3
    8000364a:	8d3e                	mv	s10,a5
    8000364c:	2781                	sext.w	a5,a5
    8000364e:	0006861b          	sext.w	a2,a3
    80003652:	faf671e3          	bgeu	a2,a5,800035f4 <readi+0x4c>
    80003656:	8d36                	mv	s10,a3
    80003658:	bf71                	j	800035f4 <readi+0x4c>
      brelse(bp);
    8000365a:	854a                	mv	a0,s2
    8000365c:	df8ff0ef          	jal	80002c54 <brelse>
      tot = -1;
    80003660:	59fd                	li	s3,-1
      break;
    80003662:	6946                	ld	s2,80(sp)
    80003664:	7c02                	ld	s8,32(sp)
    80003666:	6ce2                	ld	s9,24(sp)
    80003668:	6d42                	ld	s10,16(sp)
    8000366a:	6da2                	ld	s11,8(sp)
    8000366c:	a831                	j	80003688 <readi+0xe0>
    8000366e:	6946                	ld	s2,80(sp)
    80003670:	7c02                	ld	s8,32(sp)
    80003672:	6ce2                	ld	s9,24(sp)
    80003674:	6d42                	ld	s10,16(sp)
    80003676:	6da2                	ld	s11,8(sp)
    80003678:	a801                	j	80003688 <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000367a:	89d6                	mv	s3,s5
    8000367c:	a031                	j	80003688 <readi+0xe0>
    8000367e:	6946                	ld	s2,80(sp)
    80003680:	7c02                	ld	s8,32(sp)
    80003682:	6ce2                	ld	s9,24(sp)
    80003684:	6d42                	ld	s10,16(sp)
    80003686:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003688:	0009851b          	sext.w	a0,s3
    8000368c:	69a6                	ld	s3,72(sp)
}
    8000368e:	70a6                	ld	ra,104(sp)
    80003690:	7406                	ld	s0,96(sp)
    80003692:	64e6                	ld	s1,88(sp)
    80003694:	6a06                	ld	s4,64(sp)
    80003696:	7ae2                	ld	s5,56(sp)
    80003698:	7b42                	ld	s6,48(sp)
    8000369a:	7ba2                	ld	s7,40(sp)
    8000369c:	6165                	addi	sp,sp,112
    8000369e:	8082                	ret
    return 0;
    800036a0:	4501                	li	a0,0
}
    800036a2:	8082                	ret

00000000800036a4 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800036a4:	457c                	lw	a5,76(a0)
    800036a6:	10d7e063          	bltu	a5,a3,800037a6 <writei+0x102>
{
    800036aa:	7159                	addi	sp,sp,-112
    800036ac:	f486                	sd	ra,104(sp)
    800036ae:	f0a2                	sd	s0,96(sp)
    800036b0:	e8ca                	sd	s2,80(sp)
    800036b2:	e0d2                	sd	s4,64(sp)
    800036b4:	fc56                	sd	s5,56(sp)
    800036b6:	f85a                	sd	s6,48(sp)
    800036b8:	f45e                	sd	s7,40(sp)
    800036ba:	1880                	addi	s0,sp,112
    800036bc:	8aaa                	mv	s5,a0
    800036be:	8bae                	mv	s7,a1
    800036c0:	8a32                	mv	s4,a2
    800036c2:	8936                	mv	s2,a3
    800036c4:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800036c6:	00e687bb          	addw	a5,a3,a4
    800036ca:	0ed7e063          	bltu	a5,a3,800037aa <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800036ce:	00043737          	lui	a4,0x43
    800036d2:	0cf76e63          	bltu	a4,a5,800037ae <writei+0x10a>
    800036d6:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800036d8:	0a0b0f63          	beqz	s6,80003796 <writei+0xf2>
    800036dc:	eca6                	sd	s1,88(sp)
    800036de:	f062                	sd	s8,32(sp)
    800036e0:	ec66                	sd	s9,24(sp)
    800036e2:	e86a                	sd	s10,16(sp)
    800036e4:	e46e                	sd	s11,8(sp)
    800036e6:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800036e8:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800036ec:	5c7d                	li	s8,-1
    800036ee:	a825                	j	80003726 <writei+0x82>
    800036f0:	020d1d93          	slli	s11,s10,0x20
    800036f4:	020ddd93          	srli	s11,s11,0x20
    800036f8:	05848513          	addi	a0,s1,88
    800036fc:	86ee                	mv	a3,s11
    800036fe:	8652                	mv	a2,s4
    80003700:	85de                	mv	a1,s7
    80003702:	953a                	add	a0,a0,a4
    80003704:	b69fe0ef          	jal	8000226c <either_copyin>
    80003708:	05850a63          	beq	a0,s8,8000375c <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000370c:	8526                	mv	a0,s1
    8000370e:	678000ef          	jal	80003d86 <log_write>
    brelse(bp);
    80003712:	8526                	mv	a0,s1
    80003714:	d40ff0ef          	jal	80002c54 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003718:	013d09bb          	addw	s3,s10,s3
    8000371c:	012d093b          	addw	s2,s10,s2
    80003720:	9a6e                	add	s4,s4,s11
    80003722:	0569f063          	bgeu	s3,s6,80003762 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80003726:	00a9559b          	srliw	a1,s2,0xa
    8000372a:	8556                	mv	a0,s5
    8000372c:	fa4ff0ef          	jal	80002ed0 <bmap>
    80003730:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003734:	c59d                	beqz	a1,80003762 <writei+0xbe>
    bp = bread(ip->dev, addr);
    80003736:	000aa503          	lw	a0,0(s5)
    8000373a:	c12ff0ef          	jal	80002b4c <bread>
    8000373e:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003740:	3ff97713          	andi	a4,s2,1023
    80003744:	40ec87bb          	subw	a5,s9,a4
    80003748:	413b06bb          	subw	a3,s6,s3
    8000374c:	8d3e                	mv	s10,a5
    8000374e:	2781                	sext.w	a5,a5
    80003750:	0006861b          	sext.w	a2,a3
    80003754:	f8f67ee3          	bgeu	a2,a5,800036f0 <writei+0x4c>
    80003758:	8d36                	mv	s10,a3
    8000375a:	bf59                	j	800036f0 <writei+0x4c>
      brelse(bp);
    8000375c:	8526                	mv	a0,s1
    8000375e:	cf6ff0ef          	jal	80002c54 <brelse>
  }

  if(off > ip->size)
    80003762:	04caa783          	lw	a5,76(s5)
    80003766:	0327fa63          	bgeu	a5,s2,8000379a <writei+0xf6>
    ip->size = off;
    8000376a:	052aa623          	sw	s2,76(s5)
    8000376e:	64e6                	ld	s1,88(sp)
    80003770:	7c02                	ld	s8,32(sp)
    80003772:	6ce2                	ld	s9,24(sp)
    80003774:	6d42                	ld	s10,16(sp)
    80003776:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003778:	8556                	mv	a0,s5
    8000377a:	9ebff0ef          	jal	80003164 <iupdate>

  return tot;
    8000377e:	0009851b          	sext.w	a0,s3
    80003782:	69a6                	ld	s3,72(sp)
}
    80003784:	70a6                	ld	ra,104(sp)
    80003786:	7406                	ld	s0,96(sp)
    80003788:	6946                	ld	s2,80(sp)
    8000378a:	6a06                	ld	s4,64(sp)
    8000378c:	7ae2                	ld	s5,56(sp)
    8000378e:	7b42                	ld	s6,48(sp)
    80003790:	7ba2                	ld	s7,40(sp)
    80003792:	6165                	addi	sp,sp,112
    80003794:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003796:	89da                	mv	s3,s6
    80003798:	b7c5                	j	80003778 <writei+0xd4>
    8000379a:	64e6                	ld	s1,88(sp)
    8000379c:	7c02                	ld	s8,32(sp)
    8000379e:	6ce2                	ld	s9,24(sp)
    800037a0:	6d42                	ld	s10,16(sp)
    800037a2:	6da2                	ld	s11,8(sp)
    800037a4:	bfd1                	j	80003778 <writei+0xd4>
    return -1;
    800037a6:	557d                	li	a0,-1
}
    800037a8:	8082                	ret
    return -1;
    800037aa:	557d                	li	a0,-1
    800037ac:	bfe1                	j	80003784 <writei+0xe0>
    return -1;
    800037ae:	557d                	li	a0,-1
    800037b0:	bfd1                	j	80003784 <writei+0xe0>

00000000800037b2 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800037b2:	1141                	addi	sp,sp,-16
    800037b4:	e406                	sd	ra,8(sp)
    800037b6:	e022                	sd	s0,0(sp)
    800037b8:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800037ba:	4639                	li	a2,14
    800037bc:	db2fd0ef          	jal	80000d6e <strncmp>
}
    800037c0:	60a2                	ld	ra,8(sp)
    800037c2:	6402                	ld	s0,0(sp)
    800037c4:	0141                	addi	sp,sp,16
    800037c6:	8082                	ret

00000000800037c8 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800037c8:	7139                	addi	sp,sp,-64
    800037ca:	fc06                	sd	ra,56(sp)
    800037cc:	f822                	sd	s0,48(sp)
    800037ce:	f426                	sd	s1,40(sp)
    800037d0:	f04a                	sd	s2,32(sp)
    800037d2:	ec4e                	sd	s3,24(sp)
    800037d4:	e852                	sd	s4,16(sp)
    800037d6:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800037d8:	04451703          	lh	a4,68(a0)
    800037dc:	4785                	li	a5,1
    800037de:	00f71a63          	bne	a4,a5,800037f2 <dirlookup+0x2a>
    800037e2:	892a                	mv	s2,a0
    800037e4:	89ae                	mv	s3,a1
    800037e6:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800037e8:	457c                	lw	a5,76(a0)
    800037ea:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800037ec:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800037ee:	e39d                	bnez	a5,80003814 <dirlookup+0x4c>
    800037f0:	a095                	j	80003854 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    800037f2:	00004517          	auipc	a0,0x4
    800037f6:	cae50513          	addi	a0,a0,-850 # 800074a0 <etext+0x4a0>
    800037fa:	fe7fc0ef          	jal	800007e0 <panic>
      panic("dirlookup read");
    800037fe:	00004517          	auipc	a0,0x4
    80003802:	cba50513          	addi	a0,a0,-838 # 800074b8 <etext+0x4b8>
    80003806:	fdbfc0ef          	jal	800007e0 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000380a:	24c1                	addiw	s1,s1,16
    8000380c:	04c92783          	lw	a5,76(s2)
    80003810:	04f4f163          	bgeu	s1,a5,80003852 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003814:	4741                	li	a4,16
    80003816:	86a6                	mv	a3,s1
    80003818:	fc040613          	addi	a2,s0,-64
    8000381c:	4581                	li	a1,0
    8000381e:	854a                	mv	a0,s2
    80003820:	d89ff0ef          	jal	800035a8 <readi>
    80003824:	47c1                	li	a5,16
    80003826:	fcf51ce3          	bne	a0,a5,800037fe <dirlookup+0x36>
    if(de.inum == 0)
    8000382a:	fc045783          	lhu	a5,-64(s0)
    8000382e:	dff1                	beqz	a5,8000380a <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80003830:	fc240593          	addi	a1,s0,-62
    80003834:	854e                	mv	a0,s3
    80003836:	f7dff0ef          	jal	800037b2 <namecmp>
    8000383a:	f961                	bnez	a0,8000380a <dirlookup+0x42>
      if(poff)
    8000383c:	000a0463          	beqz	s4,80003844 <dirlookup+0x7c>
        *poff = off;
    80003840:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003844:	fc045583          	lhu	a1,-64(s0)
    80003848:	00092503          	lw	a0,0(s2)
    8000384c:	f58ff0ef          	jal	80002fa4 <iget>
    80003850:	a011                	j	80003854 <dirlookup+0x8c>
  return 0;
    80003852:	4501                	li	a0,0
}
    80003854:	70e2                	ld	ra,56(sp)
    80003856:	7442                	ld	s0,48(sp)
    80003858:	74a2                	ld	s1,40(sp)
    8000385a:	7902                	ld	s2,32(sp)
    8000385c:	69e2                	ld	s3,24(sp)
    8000385e:	6a42                	ld	s4,16(sp)
    80003860:	6121                	addi	sp,sp,64
    80003862:	8082                	ret

0000000080003864 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003864:	711d                	addi	sp,sp,-96
    80003866:	ec86                	sd	ra,88(sp)
    80003868:	e8a2                	sd	s0,80(sp)
    8000386a:	e4a6                	sd	s1,72(sp)
    8000386c:	e0ca                	sd	s2,64(sp)
    8000386e:	fc4e                	sd	s3,56(sp)
    80003870:	f852                	sd	s4,48(sp)
    80003872:	f456                	sd	s5,40(sp)
    80003874:	f05a                	sd	s6,32(sp)
    80003876:	ec5e                	sd	s7,24(sp)
    80003878:	e862                	sd	s8,16(sp)
    8000387a:	e466                	sd	s9,8(sp)
    8000387c:	1080                	addi	s0,sp,96
    8000387e:	84aa                	mv	s1,a0
    80003880:	8b2e                	mv	s6,a1
    80003882:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003884:	00054703          	lbu	a4,0(a0)
    80003888:	02f00793          	li	a5,47
    8000388c:	00f70e63          	beq	a4,a5,800038a8 <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003890:	83efe0ef          	jal	800018ce <myproc>
    80003894:	15053503          	ld	a0,336(a0)
    80003898:	94bff0ef          	jal	800031e2 <idup>
    8000389c:	8a2a                	mv	s4,a0
  while(*path == '/')
    8000389e:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    800038a2:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800038a4:	4b85                	li	s7,1
    800038a6:	a871                	j	80003942 <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    800038a8:	4585                	li	a1,1
    800038aa:	4505                	li	a0,1
    800038ac:	ef8ff0ef          	jal	80002fa4 <iget>
    800038b0:	8a2a                	mv	s4,a0
    800038b2:	b7f5                	j	8000389e <namex+0x3a>
      iunlockput(ip);
    800038b4:	8552                	mv	a0,s4
    800038b6:	b6dff0ef          	jal	80003422 <iunlockput>
      return 0;
    800038ba:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800038bc:	8552                	mv	a0,s4
    800038be:	60e6                	ld	ra,88(sp)
    800038c0:	6446                	ld	s0,80(sp)
    800038c2:	64a6                	ld	s1,72(sp)
    800038c4:	6906                	ld	s2,64(sp)
    800038c6:	79e2                	ld	s3,56(sp)
    800038c8:	7a42                	ld	s4,48(sp)
    800038ca:	7aa2                	ld	s5,40(sp)
    800038cc:	7b02                	ld	s6,32(sp)
    800038ce:	6be2                	ld	s7,24(sp)
    800038d0:	6c42                	ld	s8,16(sp)
    800038d2:	6ca2                	ld	s9,8(sp)
    800038d4:	6125                	addi	sp,sp,96
    800038d6:	8082                	ret
      iunlock(ip);
    800038d8:	8552                	mv	a0,s4
    800038da:	9edff0ef          	jal	800032c6 <iunlock>
      return ip;
    800038de:	bff9                	j	800038bc <namex+0x58>
      iunlockput(ip);
    800038e0:	8552                	mv	a0,s4
    800038e2:	b41ff0ef          	jal	80003422 <iunlockput>
      return 0;
    800038e6:	8a4e                	mv	s4,s3
    800038e8:	bfd1                	j	800038bc <namex+0x58>
  len = path - s;
    800038ea:	40998633          	sub	a2,s3,s1
    800038ee:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    800038f2:	099c5063          	bge	s8,s9,80003972 <namex+0x10e>
    memmove(name, s, DIRSIZ);
    800038f6:	4639                	li	a2,14
    800038f8:	85a6                	mv	a1,s1
    800038fa:	8556                	mv	a0,s5
    800038fc:	c02fd0ef          	jal	80000cfe <memmove>
    80003900:	84ce                	mv	s1,s3
  while(*path == '/')
    80003902:	0004c783          	lbu	a5,0(s1)
    80003906:	01279763          	bne	a5,s2,80003914 <namex+0xb0>
    path++;
    8000390a:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000390c:	0004c783          	lbu	a5,0(s1)
    80003910:	ff278de3          	beq	a5,s2,8000390a <namex+0xa6>
    ilock(ip);
    80003914:	8552                	mv	a0,s4
    80003916:	903ff0ef          	jal	80003218 <ilock>
    if(ip->type != T_DIR){
    8000391a:	044a1783          	lh	a5,68(s4)
    8000391e:	f9779be3          	bne	a5,s7,800038b4 <namex+0x50>
    if(nameiparent && *path == '\0'){
    80003922:	000b0563          	beqz	s6,8000392c <namex+0xc8>
    80003926:	0004c783          	lbu	a5,0(s1)
    8000392a:	d7dd                	beqz	a5,800038d8 <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000392c:	4601                	li	a2,0
    8000392e:	85d6                	mv	a1,s5
    80003930:	8552                	mv	a0,s4
    80003932:	e97ff0ef          	jal	800037c8 <dirlookup>
    80003936:	89aa                	mv	s3,a0
    80003938:	d545                	beqz	a0,800038e0 <namex+0x7c>
    iunlockput(ip);
    8000393a:	8552                	mv	a0,s4
    8000393c:	ae7ff0ef          	jal	80003422 <iunlockput>
    ip = next;
    80003940:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003942:	0004c783          	lbu	a5,0(s1)
    80003946:	01279763          	bne	a5,s2,80003954 <namex+0xf0>
    path++;
    8000394a:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000394c:	0004c783          	lbu	a5,0(s1)
    80003950:	ff278de3          	beq	a5,s2,8000394a <namex+0xe6>
  if(*path == 0)
    80003954:	cb8d                	beqz	a5,80003986 <namex+0x122>
  while(*path != '/' && *path != 0)
    80003956:	0004c783          	lbu	a5,0(s1)
    8000395a:	89a6                	mv	s3,s1
  len = path - s;
    8000395c:	4c81                	li	s9,0
    8000395e:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003960:	01278963          	beq	a5,s2,80003972 <namex+0x10e>
    80003964:	d3d9                	beqz	a5,800038ea <namex+0x86>
    path++;
    80003966:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003968:	0009c783          	lbu	a5,0(s3)
    8000396c:	ff279ce3          	bne	a5,s2,80003964 <namex+0x100>
    80003970:	bfad                	j	800038ea <namex+0x86>
    memmove(name, s, len);
    80003972:	2601                	sext.w	a2,a2
    80003974:	85a6                	mv	a1,s1
    80003976:	8556                	mv	a0,s5
    80003978:	b86fd0ef          	jal	80000cfe <memmove>
    name[len] = 0;
    8000397c:	9cd6                	add	s9,s9,s5
    8000397e:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003982:	84ce                	mv	s1,s3
    80003984:	bfbd                	j	80003902 <namex+0x9e>
  if(nameiparent){
    80003986:	f20b0be3          	beqz	s6,800038bc <namex+0x58>
    iput(ip);
    8000398a:	8552                	mv	a0,s4
    8000398c:	a0fff0ef          	jal	8000339a <iput>
    return 0;
    80003990:	4a01                	li	s4,0
    80003992:	b72d                	j	800038bc <namex+0x58>

0000000080003994 <dirlink>:
{
    80003994:	7139                	addi	sp,sp,-64
    80003996:	fc06                	sd	ra,56(sp)
    80003998:	f822                	sd	s0,48(sp)
    8000399a:	f04a                	sd	s2,32(sp)
    8000399c:	ec4e                	sd	s3,24(sp)
    8000399e:	e852                	sd	s4,16(sp)
    800039a0:	0080                	addi	s0,sp,64
    800039a2:	892a                	mv	s2,a0
    800039a4:	8a2e                	mv	s4,a1
    800039a6:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800039a8:	4601                	li	a2,0
    800039aa:	e1fff0ef          	jal	800037c8 <dirlookup>
    800039ae:	e535                	bnez	a0,80003a1a <dirlink+0x86>
    800039b0:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    800039b2:	04c92483          	lw	s1,76(s2)
    800039b6:	c48d                	beqz	s1,800039e0 <dirlink+0x4c>
    800039b8:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800039ba:	4741                	li	a4,16
    800039bc:	86a6                	mv	a3,s1
    800039be:	fc040613          	addi	a2,s0,-64
    800039c2:	4581                	li	a1,0
    800039c4:	854a                	mv	a0,s2
    800039c6:	be3ff0ef          	jal	800035a8 <readi>
    800039ca:	47c1                	li	a5,16
    800039cc:	04f51b63          	bne	a0,a5,80003a22 <dirlink+0x8e>
    if(de.inum == 0)
    800039d0:	fc045783          	lhu	a5,-64(s0)
    800039d4:	c791                	beqz	a5,800039e0 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800039d6:	24c1                	addiw	s1,s1,16
    800039d8:	04c92783          	lw	a5,76(s2)
    800039dc:	fcf4efe3          	bltu	s1,a5,800039ba <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    800039e0:	4639                	li	a2,14
    800039e2:	85d2                	mv	a1,s4
    800039e4:	fc240513          	addi	a0,s0,-62
    800039e8:	bbcfd0ef          	jal	80000da4 <strncpy>
  de.inum = inum;
    800039ec:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800039f0:	4741                	li	a4,16
    800039f2:	86a6                	mv	a3,s1
    800039f4:	fc040613          	addi	a2,s0,-64
    800039f8:	4581                	li	a1,0
    800039fa:	854a                	mv	a0,s2
    800039fc:	ca9ff0ef          	jal	800036a4 <writei>
    80003a00:	1541                	addi	a0,a0,-16
    80003a02:	00a03533          	snez	a0,a0
    80003a06:	40a00533          	neg	a0,a0
    80003a0a:	74a2                	ld	s1,40(sp)
}
    80003a0c:	70e2                	ld	ra,56(sp)
    80003a0e:	7442                	ld	s0,48(sp)
    80003a10:	7902                	ld	s2,32(sp)
    80003a12:	69e2                	ld	s3,24(sp)
    80003a14:	6a42                	ld	s4,16(sp)
    80003a16:	6121                	addi	sp,sp,64
    80003a18:	8082                	ret
    iput(ip);
    80003a1a:	981ff0ef          	jal	8000339a <iput>
    return -1;
    80003a1e:	557d                	li	a0,-1
    80003a20:	b7f5                	j	80003a0c <dirlink+0x78>
      panic("dirlink read");
    80003a22:	00004517          	auipc	a0,0x4
    80003a26:	aa650513          	addi	a0,a0,-1370 # 800074c8 <etext+0x4c8>
    80003a2a:	db7fc0ef          	jal	800007e0 <panic>

0000000080003a2e <namei>:

struct inode*
namei(char *path)
{
    80003a2e:	1101                	addi	sp,sp,-32
    80003a30:	ec06                	sd	ra,24(sp)
    80003a32:	e822                	sd	s0,16(sp)
    80003a34:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003a36:	fe040613          	addi	a2,s0,-32
    80003a3a:	4581                	li	a1,0
    80003a3c:	e29ff0ef          	jal	80003864 <namex>
}
    80003a40:	60e2                	ld	ra,24(sp)
    80003a42:	6442                	ld	s0,16(sp)
    80003a44:	6105                	addi	sp,sp,32
    80003a46:	8082                	ret

0000000080003a48 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003a48:	1141                	addi	sp,sp,-16
    80003a4a:	e406                	sd	ra,8(sp)
    80003a4c:	e022                	sd	s0,0(sp)
    80003a4e:	0800                	addi	s0,sp,16
    80003a50:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003a52:	4585                	li	a1,1
    80003a54:	e11ff0ef          	jal	80003864 <namex>
}
    80003a58:	60a2                	ld	ra,8(sp)
    80003a5a:	6402                	ld	s0,0(sp)
    80003a5c:	0141                	addi	sp,sp,16
    80003a5e:	8082                	ret

0000000080003a60 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003a60:	1101                	addi	sp,sp,-32
    80003a62:	ec06                	sd	ra,24(sp)
    80003a64:	e822                	sd	s0,16(sp)
    80003a66:	e426                	sd	s1,8(sp)
    80003a68:	e04a                	sd	s2,0(sp)
    80003a6a:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003a6c:	0001f917          	auipc	s2,0x1f
    80003a70:	83c90913          	addi	s2,s2,-1988 # 800222a8 <log>
    80003a74:	01892583          	lw	a1,24(s2)
    80003a78:	02492503          	lw	a0,36(s2)
    80003a7c:	8d0ff0ef          	jal	80002b4c <bread>
    80003a80:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003a82:	02892603          	lw	a2,40(s2)
    80003a86:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003a88:	00c05f63          	blez	a2,80003aa6 <write_head+0x46>
    80003a8c:	0001f717          	auipc	a4,0x1f
    80003a90:	84870713          	addi	a4,a4,-1976 # 800222d4 <log+0x2c>
    80003a94:	87aa                	mv	a5,a0
    80003a96:	060a                	slli	a2,a2,0x2
    80003a98:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003a9a:	4314                	lw	a3,0(a4)
    80003a9c:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003a9e:	0711                	addi	a4,a4,4
    80003aa0:	0791                	addi	a5,a5,4
    80003aa2:	fec79ce3          	bne	a5,a2,80003a9a <write_head+0x3a>
  }
  bwrite(buf);
    80003aa6:	8526                	mv	a0,s1
    80003aa8:	97aff0ef          	jal	80002c22 <bwrite>
  brelse(buf);
    80003aac:	8526                	mv	a0,s1
    80003aae:	9a6ff0ef          	jal	80002c54 <brelse>
}
    80003ab2:	60e2                	ld	ra,24(sp)
    80003ab4:	6442                	ld	s0,16(sp)
    80003ab6:	64a2                	ld	s1,8(sp)
    80003ab8:	6902                	ld	s2,0(sp)
    80003aba:	6105                	addi	sp,sp,32
    80003abc:	8082                	ret

0000000080003abe <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003abe:	0001f797          	auipc	a5,0x1f
    80003ac2:	8127a783          	lw	a5,-2030(a5) # 800222d0 <log+0x28>
    80003ac6:	0af05e63          	blez	a5,80003b82 <install_trans+0xc4>
{
    80003aca:	715d                	addi	sp,sp,-80
    80003acc:	e486                	sd	ra,72(sp)
    80003ace:	e0a2                	sd	s0,64(sp)
    80003ad0:	fc26                	sd	s1,56(sp)
    80003ad2:	f84a                	sd	s2,48(sp)
    80003ad4:	f44e                	sd	s3,40(sp)
    80003ad6:	f052                	sd	s4,32(sp)
    80003ad8:	ec56                	sd	s5,24(sp)
    80003ada:	e85a                	sd	s6,16(sp)
    80003adc:	e45e                	sd	s7,8(sp)
    80003ade:	0880                	addi	s0,sp,80
    80003ae0:	8b2a                	mv	s6,a0
    80003ae2:	0001ea97          	auipc	s5,0x1e
    80003ae6:	7f2a8a93          	addi	s5,s5,2034 # 800222d4 <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003aea:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003aec:	00004b97          	auipc	s7,0x4
    80003af0:	9ecb8b93          	addi	s7,s7,-1556 # 800074d8 <etext+0x4d8>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003af4:	0001ea17          	auipc	s4,0x1e
    80003af8:	7b4a0a13          	addi	s4,s4,1972 # 800222a8 <log>
    80003afc:	a025                	j	80003b24 <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003afe:	000aa603          	lw	a2,0(s5)
    80003b02:	85ce                	mv	a1,s3
    80003b04:	855e                	mv	a0,s7
    80003b06:	9f5fc0ef          	jal	800004fa <printf>
    80003b0a:	a839                	j	80003b28 <install_trans+0x6a>
    brelse(lbuf);
    80003b0c:	854a                	mv	a0,s2
    80003b0e:	946ff0ef          	jal	80002c54 <brelse>
    brelse(dbuf);
    80003b12:	8526                	mv	a0,s1
    80003b14:	940ff0ef          	jal	80002c54 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003b18:	2985                	addiw	s3,s3,1
    80003b1a:	0a91                	addi	s5,s5,4
    80003b1c:	028a2783          	lw	a5,40(s4)
    80003b20:	04f9d663          	bge	s3,a5,80003b6c <install_trans+0xae>
    if(recovering) {
    80003b24:	fc0b1de3          	bnez	s6,80003afe <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003b28:	018a2583          	lw	a1,24(s4)
    80003b2c:	013585bb          	addw	a1,a1,s3
    80003b30:	2585                	addiw	a1,a1,1
    80003b32:	024a2503          	lw	a0,36(s4)
    80003b36:	816ff0ef          	jal	80002b4c <bread>
    80003b3a:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003b3c:	000aa583          	lw	a1,0(s5)
    80003b40:	024a2503          	lw	a0,36(s4)
    80003b44:	808ff0ef          	jal	80002b4c <bread>
    80003b48:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003b4a:	40000613          	li	a2,1024
    80003b4e:	05890593          	addi	a1,s2,88
    80003b52:	05850513          	addi	a0,a0,88
    80003b56:	9a8fd0ef          	jal	80000cfe <memmove>
    bwrite(dbuf);  // write dst to disk
    80003b5a:	8526                	mv	a0,s1
    80003b5c:	8c6ff0ef          	jal	80002c22 <bwrite>
    if(recovering == 0)
    80003b60:	fa0b16e3          	bnez	s6,80003b0c <install_trans+0x4e>
      bunpin(dbuf);
    80003b64:	8526                	mv	a0,s1
    80003b66:	9aaff0ef          	jal	80002d10 <bunpin>
    80003b6a:	b74d                	j	80003b0c <install_trans+0x4e>
}
    80003b6c:	60a6                	ld	ra,72(sp)
    80003b6e:	6406                	ld	s0,64(sp)
    80003b70:	74e2                	ld	s1,56(sp)
    80003b72:	7942                	ld	s2,48(sp)
    80003b74:	79a2                	ld	s3,40(sp)
    80003b76:	7a02                	ld	s4,32(sp)
    80003b78:	6ae2                	ld	s5,24(sp)
    80003b7a:	6b42                	ld	s6,16(sp)
    80003b7c:	6ba2                	ld	s7,8(sp)
    80003b7e:	6161                	addi	sp,sp,80
    80003b80:	8082                	ret
    80003b82:	8082                	ret

0000000080003b84 <initlog>:
{
    80003b84:	7179                	addi	sp,sp,-48
    80003b86:	f406                	sd	ra,40(sp)
    80003b88:	f022                	sd	s0,32(sp)
    80003b8a:	ec26                	sd	s1,24(sp)
    80003b8c:	e84a                	sd	s2,16(sp)
    80003b8e:	e44e                	sd	s3,8(sp)
    80003b90:	1800                	addi	s0,sp,48
    80003b92:	892a                	mv	s2,a0
    80003b94:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003b96:	0001e497          	auipc	s1,0x1e
    80003b9a:	71248493          	addi	s1,s1,1810 # 800222a8 <log>
    80003b9e:	00004597          	auipc	a1,0x4
    80003ba2:	95a58593          	addi	a1,a1,-1702 # 800074f8 <etext+0x4f8>
    80003ba6:	8526                	mv	a0,s1
    80003ba8:	fa7fc0ef          	jal	80000b4e <initlock>
  log.start = sb->logstart;
    80003bac:	0149a583          	lw	a1,20(s3)
    80003bb0:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80003bb2:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003bb6:	854a                	mv	a0,s2
    80003bb8:	f95fe0ef          	jal	80002b4c <bread>
  log.lh.n = lh->n;
    80003bbc:	4d30                	lw	a2,88(a0)
    80003bbe:	d490                	sw	a2,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003bc0:	00c05f63          	blez	a2,80003bde <initlog+0x5a>
    80003bc4:	87aa                	mv	a5,a0
    80003bc6:	0001e717          	auipc	a4,0x1e
    80003bca:	70e70713          	addi	a4,a4,1806 # 800222d4 <log+0x2c>
    80003bce:	060a                	slli	a2,a2,0x2
    80003bd0:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003bd2:	4ff4                	lw	a3,92(a5)
    80003bd4:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003bd6:	0791                	addi	a5,a5,4
    80003bd8:	0711                	addi	a4,a4,4
    80003bda:	fec79ce3          	bne	a5,a2,80003bd2 <initlog+0x4e>
  brelse(buf);
    80003bde:	876ff0ef          	jal	80002c54 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003be2:	4505                	li	a0,1
    80003be4:	edbff0ef          	jal	80003abe <install_trans>
  log.lh.n = 0;
    80003be8:	0001e797          	auipc	a5,0x1e
    80003bec:	6e07a423          	sw	zero,1768(a5) # 800222d0 <log+0x28>
  write_head(); // clear the log
    80003bf0:	e71ff0ef          	jal	80003a60 <write_head>
}
    80003bf4:	70a2                	ld	ra,40(sp)
    80003bf6:	7402                	ld	s0,32(sp)
    80003bf8:	64e2                	ld	s1,24(sp)
    80003bfa:	6942                	ld	s2,16(sp)
    80003bfc:	69a2                	ld	s3,8(sp)
    80003bfe:	6145                	addi	sp,sp,48
    80003c00:	8082                	ret

0000000080003c02 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003c02:	1101                	addi	sp,sp,-32
    80003c04:	ec06                	sd	ra,24(sp)
    80003c06:	e822                	sd	s0,16(sp)
    80003c08:	e426                	sd	s1,8(sp)
    80003c0a:	e04a                	sd	s2,0(sp)
    80003c0c:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003c0e:	0001e517          	auipc	a0,0x1e
    80003c12:	69a50513          	addi	a0,a0,1690 # 800222a8 <log>
    80003c16:	fb9fc0ef          	jal	80000bce <acquire>
  while(1){
    if(log.committing){
    80003c1a:	0001e497          	auipc	s1,0x1e
    80003c1e:	68e48493          	addi	s1,s1,1678 # 800222a8 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003c22:	4979                	li	s2,30
    80003c24:	a029                	j	80003c2e <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003c26:	85a6                	mv	a1,s1
    80003c28:	8526                	mv	a0,s1
    80003c2a:	a9cfe0ef          	jal	80001ec6 <sleep>
    if(log.committing){
    80003c2e:	509c                	lw	a5,32(s1)
    80003c30:	fbfd                	bnez	a5,80003c26 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003c32:	4cd8                	lw	a4,28(s1)
    80003c34:	2705                	addiw	a4,a4,1
    80003c36:	0027179b          	slliw	a5,a4,0x2
    80003c3a:	9fb9                	addw	a5,a5,a4
    80003c3c:	0017979b          	slliw	a5,a5,0x1
    80003c40:	5494                	lw	a3,40(s1)
    80003c42:	9fb5                	addw	a5,a5,a3
    80003c44:	00f95763          	bge	s2,a5,80003c52 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003c48:	85a6                	mv	a1,s1
    80003c4a:	8526                	mv	a0,s1
    80003c4c:	a7afe0ef          	jal	80001ec6 <sleep>
    80003c50:	bff9                	j	80003c2e <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003c52:	0001e517          	auipc	a0,0x1e
    80003c56:	65650513          	addi	a0,a0,1622 # 800222a8 <log>
    80003c5a:	cd58                	sw	a4,28(a0)
      release(&log.lock);
    80003c5c:	80afd0ef          	jal	80000c66 <release>
      break;
    }
  }
}
    80003c60:	60e2                	ld	ra,24(sp)
    80003c62:	6442                	ld	s0,16(sp)
    80003c64:	64a2                	ld	s1,8(sp)
    80003c66:	6902                	ld	s2,0(sp)
    80003c68:	6105                	addi	sp,sp,32
    80003c6a:	8082                	ret

0000000080003c6c <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003c6c:	7139                	addi	sp,sp,-64
    80003c6e:	fc06                	sd	ra,56(sp)
    80003c70:	f822                	sd	s0,48(sp)
    80003c72:	f426                	sd	s1,40(sp)
    80003c74:	f04a                	sd	s2,32(sp)
    80003c76:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003c78:	0001e497          	auipc	s1,0x1e
    80003c7c:	63048493          	addi	s1,s1,1584 # 800222a8 <log>
    80003c80:	8526                	mv	a0,s1
    80003c82:	f4dfc0ef          	jal	80000bce <acquire>
  log.outstanding -= 1;
    80003c86:	4cdc                	lw	a5,28(s1)
    80003c88:	37fd                	addiw	a5,a5,-1
    80003c8a:	0007891b          	sext.w	s2,a5
    80003c8e:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80003c90:	509c                	lw	a5,32(s1)
    80003c92:	ef9d                	bnez	a5,80003cd0 <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    80003c94:	04091763          	bnez	s2,80003ce2 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003c98:	0001e497          	auipc	s1,0x1e
    80003c9c:	61048493          	addi	s1,s1,1552 # 800222a8 <log>
    80003ca0:	4785                	li	a5,1
    80003ca2:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003ca4:	8526                	mv	a0,s1
    80003ca6:	fc1fc0ef          	jal	80000c66 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003caa:	549c                	lw	a5,40(s1)
    80003cac:	04f04b63          	bgtz	a5,80003d02 <end_op+0x96>
    acquire(&log.lock);
    80003cb0:	0001e497          	auipc	s1,0x1e
    80003cb4:	5f848493          	addi	s1,s1,1528 # 800222a8 <log>
    80003cb8:	8526                	mv	a0,s1
    80003cba:	f15fc0ef          	jal	80000bce <acquire>
    log.committing = 0;
    80003cbe:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    80003cc2:	8526                	mv	a0,s1
    80003cc4:	a4efe0ef          	jal	80001f12 <wakeup>
    release(&log.lock);
    80003cc8:	8526                	mv	a0,s1
    80003cca:	f9dfc0ef          	jal	80000c66 <release>
}
    80003cce:	a025                	j	80003cf6 <end_op+0x8a>
    80003cd0:	ec4e                	sd	s3,24(sp)
    80003cd2:	e852                	sd	s4,16(sp)
    80003cd4:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003cd6:	00004517          	auipc	a0,0x4
    80003cda:	82a50513          	addi	a0,a0,-2006 # 80007500 <etext+0x500>
    80003cde:	b03fc0ef          	jal	800007e0 <panic>
    wakeup(&log);
    80003ce2:	0001e497          	auipc	s1,0x1e
    80003ce6:	5c648493          	addi	s1,s1,1478 # 800222a8 <log>
    80003cea:	8526                	mv	a0,s1
    80003cec:	a26fe0ef          	jal	80001f12 <wakeup>
  release(&log.lock);
    80003cf0:	8526                	mv	a0,s1
    80003cf2:	f75fc0ef          	jal	80000c66 <release>
}
    80003cf6:	70e2                	ld	ra,56(sp)
    80003cf8:	7442                	ld	s0,48(sp)
    80003cfa:	74a2                	ld	s1,40(sp)
    80003cfc:	7902                	ld	s2,32(sp)
    80003cfe:	6121                	addi	sp,sp,64
    80003d00:	8082                	ret
    80003d02:	ec4e                	sd	s3,24(sp)
    80003d04:	e852                	sd	s4,16(sp)
    80003d06:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d08:	0001ea97          	auipc	s5,0x1e
    80003d0c:	5cca8a93          	addi	s5,s5,1484 # 800222d4 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003d10:	0001ea17          	auipc	s4,0x1e
    80003d14:	598a0a13          	addi	s4,s4,1432 # 800222a8 <log>
    80003d18:	018a2583          	lw	a1,24(s4)
    80003d1c:	012585bb          	addw	a1,a1,s2
    80003d20:	2585                	addiw	a1,a1,1
    80003d22:	024a2503          	lw	a0,36(s4)
    80003d26:	e27fe0ef          	jal	80002b4c <bread>
    80003d2a:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003d2c:	000aa583          	lw	a1,0(s5)
    80003d30:	024a2503          	lw	a0,36(s4)
    80003d34:	e19fe0ef          	jal	80002b4c <bread>
    80003d38:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003d3a:	40000613          	li	a2,1024
    80003d3e:	05850593          	addi	a1,a0,88
    80003d42:	05848513          	addi	a0,s1,88
    80003d46:	fb9fc0ef          	jal	80000cfe <memmove>
    bwrite(to);  // write the log
    80003d4a:	8526                	mv	a0,s1
    80003d4c:	ed7fe0ef          	jal	80002c22 <bwrite>
    brelse(from);
    80003d50:	854e                	mv	a0,s3
    80003d52:	f03fe0ef          	jal	80002c54 <brelse>
    brelse(to);
    80003d56:	8526                	mv	a0,s1
    80003d58:	efdfe0ef          	jal	80002c54 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d5c:	2905                	addiw	s2,s2,1
    80003d5e:	0a91                	addi	s5,s5,4
    80003d60:	028a2783          	lw	a5,40(s4)
    80003d64:	faf94ae3          	blt	s2,a5,80003d18 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003d68:	cf9ff0ef          	jal	80003a60 <write_head>
    install_trans(0); // Now install writes to home locations
    80003d6c:	4501                	li	a0,0
    80003d6e:	d51ff0ef          	jal	80003abe <install_trans>
    log.lh.n = 0;
    80003d72:	0001e797          	auipc	a5,0x1e
    80003d76:	5407af23          	sw	zero,1374(a5) # 800222d0 <log+0x28>
    write_head();    // Erase the transaction from the log
    80003d7a:	ce7ff0ef          	jal	80003a60 <write_head>
    80003d7e:	69e2                	ld	s3,24(sp)
    80003d80:	6a42                	ld	s4,16(sp)
    80003d82:	6aa2                	ld	s5,8(sp)
    80003d84:	b735                	j	80003cb0 <end_op+0x44>

0000000080003d86 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003d86:	1101                	addi	sp,sp,-32
    80003d88:	ec06                	sd	ra,24(sp)
    80003d8a:	e822                	sd	s0,16(sp)
    80003d8c:	e426                	sd	s1,8(sp)
    80003d8e:	e04a                	sd	s2,0(sp)
    80003d90:	1000                	addi	s0,sp,32
    80003d92:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003d94:	0001e917          	auipc	s2,0x1e
    80003d98:	51490913          	addi	s2,s2,1300 # 800222a8 <log>
    80003d9c:	854a                	mv	a0,s2
    80003d9e:	e31fc0ef          	jal	80000bce <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003da2:	02892603          	lw	a2,40(s2)
    80003da6:	47f5                	li	a5,29
    80003da8:	04c7cc63          	blt	a5,a2,80003e00 <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003dac:	0001e797          	auipc	a5,0x1e
    80003db0:	5187a783          	lw	a5,1304(a5) # 800222c4 <log+0x1c>
    80003db4:	04f05c63          	blez	a5,80003e0c <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003db8:	4781                	li	a5,0
    80003dba:	04c05f63          	blez	a2,80003e18 <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003dbe:	44cc                	lw	a1,12(s1)
    80003dc0:	0001e717          	auipc	a4,0x1e
    80003dc4:	51470713          	addi	a4,a4,1300 # 800222d4 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80003dc8:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003dca:	4314                	lw	a3,0(a4)
    80003dcc:	04b68663          	beq	a3,a1,80003e18 <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    80003dd0:	2785                	addiw	a5,a5,1
    80003dd2:	0711                	addi	a4,a4,4
    80003dd4:	fef61be3          	bne	a2,a5,80003dca <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003dd8:	0621                	addi	a2,a2,8
    80003dda:	060a                	slli	a2,a2,0x2
    80003ddc:	0001e797          	auipc	a5,0x1e
    80003de0:	4cc78793          	addi	a5,a5,1228 # 800222a8 <log>
    80003de4:	97b2                	add	a5,a5,a2
    80003de6:	44d8                	lw	a4,12(s1)
    80003de8:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003dea:	8526                	mv	a0,s1
    80003dec:	ef1fe0ef          	jal	80002cdc <bpin>
    log.lh.n++;
    80003df0:	0001e717          	auipc	a4,0x1e
    80003df4:	4b870713          	addi	a4,a4,1208 # 800222a8 <log>
    80003df8:	571c                	lw	a5,40(a4)
    80003dfa:	2785                	addiw	a5,a5,1
    80003dfc:	d71c                	sw	a5,40(a4)
    80003dfe:	a80d                	j	80003e30 <log_write+0xaa>
    panic("too big a transaction");
    80003e00:	00003517          	auipc	a0,0x3
    80003e04:	71050513          	addi	a0,a0,1808 # 80007510 <etext+0x510>
    80003e08:	9d9fc0ef          	jal	800007e0 <panic>
    panic("log_write outside of trans");
    80003e0c:	00003517          	auipc	a0,0x3
    80003e10:	71c50513          	addi	a0,a0,1820 # 80007528 <etext+0x528>
    80003e14:	9cdfc0ef          	jal	800007e0 <panic>
  log.lh.block[i] = b->blockno;
    80003e18:	00878693          	addi	a3,a5,8
    80003e1c:	068a                	slli	a3,a3,0x2
    80003e1e:	0001e717          	auipc	a4,0x1e
    80003e22:	48a70713          	addi	a4,a4,1162 # 800222a8 <log>
    80003e26:	9736                	add	a4,a4,a3
    80003e28:	44d4                	lw	a3,12(s1)
    80003e2a:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003e2c:	faf60fe3          	beq	a2,a5,80003dea <log_write+0x64>
  }
  release(&log.lock);
    80003e30:	0001e517          	auipc	a0,0x1e
    80003e34:	47850513          	addi	a0,a0,1144 # 800222a8 <log>
    80003e38:	e2ffc0ef          	jal	80000c66 <release>
}
    80003e3c:	60e2                	ld	ra,24(sp)
    80003e3e:	6442                	ld	s0,16(sp)
    80003e40:	64a2                	ld	s1,8(sp)
    80003e42:	6902                	ld	s2,0(sp)
    80003e44:	6105                	addi	sp,sp,32
    80003e46:	8082                	ret

0000000080003e48 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003e48:	1101                	addi	sp,sp,-32
    80003e4a:	ec06                	sd	ra,24(sp)
    80003e4c:	e822                	sd	s0,16(sp)
    80003e4e:	e426                	sd	s1,8(sp)
    80003e50:	e04a                	sd	s2,0(sp)
    80003e52:	1000                	addi	s0,sp,32
    80003e54:	84aa                	mv	s1,a0
    80003e56:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003e58:	00003597          	auipc	a1,0x3
    80003e5c:	6f058593          	addi	a1,a1,1776 # 80007548 <etext+0x548>
    80003e60:	0521                	addi	a0,a0,8
    80003e62:	cedfc0ef          	jal	80000b4e <initlock>
  lk->name = name;
    80003e66:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003e6a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003e6e:	0204a423          	sw	zero,40(s1)
}
    80003e72:	60e2                	ld	ra,24(sp)
    80003e74:	6442                	ld	s0,16(sp)
    80003e76:	64a2                	ld	s1,8(sp)
    80003e78:	6902                	ld	s2,0(sp)
    80003e7a:	6105                	addi	sp,sp,32
    80003e7c:	8082                	ret

0000000080003e7e <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003e7e:	1101                	addi	sp,sp,-32
    80003e80:	ec06                	sd	ra,24(sp)
    80003e82:	e822                	sd	s0,16(sp)
    80003e84:	e426                	sd	s1,8(sp)
    80003e86:	e04a                	sd	s2,0(sp)
    80003e88:	1000                	addi	s0,sp,32
    80003e8a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003e8c:	00850913          	addi	s2,a0,8
    80003e90:	854a                	mv	a0,s2
    80003e92:	d3dfc0ef          	jal	80000bce <acquire>
  while (lk->locked) {
    80003e96:	409c                	lw	a5,0(s1)
    80003e98:	c799                	beqz	a5,80003ea6 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003e9a:	85ca                	mv	a1,s2
    80003e9c:	8526                	mv	a0,s1
    80003e9e:	828fe0ef          	jal	80001ec6 <sleep>
  while (lk->locked) {
    80003ea2:	409c                	lw	a5,0(s1)
    80003ea4:	fbfd                	bnez	a5,80003e9a <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003ea6:	4785                	li	a5,1
    80003ea8:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003eaa:	a25fd0ef          	jal	800018ce <myproc>
    80003eae:	591c                	lw	a5,48(a0)
    80003eb0:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003eb2:	854a                	mv	a0,s2
    80003eb4:	db3fc0ef          	jal	80000c66 <release>
}
    80003eb8:	60e2                	ld	ra,24(sp)
    80003eba:	6442                	ld	s0,16(sp)
    80003ebc:	64a2                	ld	s1,8(sp)
    80003ebe:	6902                	ld	s2,0(sp)
    80003ec0:	6105                	addi	sp,sp,32
    80003ec2:	8082                	ret

0000000080003ec4 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003ec4:	1101                	addi	sp,sp,-32
    80003ec6:	ec06                	sd	ra,24(sp)
    80003ec8:	e822                	sd	s0,16(sp)
    80003eca:	e426                	sd	s1,8(sp)
    80003ecc:	e04a                	sd	s2,0(sp)
    80003ece:	1000                	addi	s0,sp,32
    80003ed0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003ed2:	00850913          	addi	s2,a0,8
    80003ed6:	854a                	mv	a0,s2
    80003ed8:	cf7fc0ef          	jal	80000bce <acquire>
  lk->locked = 0;
    80003edc:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003ee0:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003ee4:	8526                	mv	a0,s1
    80003ee6:	82cfe0ef          	jal	80001f12 <wakeup>
  release(&lk->lk);
    80003eea:	854a                	mv	a0,s2
    80003eec:	d7bfc0ef          	jal	80000c66 <release>
}
    80003ef0:	60e2                	ld	ra,24(sp)
    80003ef2:	6442                	ld	s0,16(sp)
    80003ef4:	64a2                	ld	s1,8(sp)
    80003ef6:	6902                	ld	s2,0(sp)
    80003ef8:	6105                	addi	sp,sp,32
    80003efa:	8082                	ret

0000000080003efc <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003efc:	7179                	addi	sp,sp,-48
    80003efe:	f406                	sd	ra,40(sp)
    80003f00:	f022                	sd	s0,32(sp)
    80003f02:	ec26                	sd	s1,24(sp)
    80003f04:	e84a                	sd	s2,16(sp)
    80003f06:	1800                	addi	s0,sp,48
    80003f08:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003f0a:	00850913          	addi	s2,a0,8
    80003f0e:	854a                	mv	a0,s2
    80003f10:	cbffc0ef          	jal	80000bce <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003f14:	409c                	lw	a5,0(s1)
    80003f16:	ef81                	bnez	a5,80003f2e <holdingsleep+0x32>
    80003f18:	4481                	li	s1,0
  release(&lk->lk);
    80003f1a:	854a                	mv	a0,s2
    80003f1c:	d4bfc0ef          	jal	80000c66 <release>
  return r;
}
    80003f20:	8526                	mv	a0,s1
    80003f22:	70a2                	ld	ra,40(sp)
    80003f24:	7402                	ld	s0,32(sp)
    80003f26:	64e2                	ld	s1,24(sp)
    80003f28:	6942                	ld	s2,16(sp)
    80003f2a:	6145                	addi	sp,sp,48
    80003f2c:	8082                	ret
    80003f2e:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80003f30:	0284a983          	lw	s3,40(s1)
    80003f34:	99bfd0ef          	jal	800018ce <myproc>
    80003f38:	5904                	lw	s1,48(a0)
    80003f3a:	413484b3          	sub	s1,s1,s3
    80003f3e:	0014b493          	seqz	s1,s1
    80003f42:	69a2                	ld	s3,8(sp)
    80003f44:	bfd9                	j	80003f1a <holdingsleep+0x1e>

0000000080003f46 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80003f46:	1141                	addi	sp,sp,-16
    80003f48:	e406                	sd	ra,8(sp)
    80003f4a:	e022                	sd	s0,0(sp)
    80003f4c:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80003f4e:	00003597          	auipc	a1,0x3
    80003f52:	60a58593          	addi	a1,a1,1546 # 80007558 <etext+0x558>
    80003f56:	0001e517          	auipc	a0,0x1e
    80003f5a:	49a50513          	addi	a0,a0,1178 # 800223f0 <ftable>
    80003f5e:	bf1fc0ef          	jal	80000b4e <initlock>
}
    80003f62:	60a2                	ld	ra,8(sp)
    80003f64:	6402                	ld	s0,0(sp)
    80003f66:	0141                	addi	sp,sp,16
    80003f68:	8082                	ret

0000000080003f6a <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80003f6a:	1101                	addi	sp,sp,-32
    80003f6c:	ec06                	sd	ra,24(sp)
    80003f6e:	e822                	sd	s0,16(sp)
    80003f70:	e426                	sd	s1,8(sp)
    80003f72:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80003f74:	0001e517          	auipc	a0,0x1e
    80003f78:	47c50513          	addi	a0,a0,1148 # 800223f0 <ftable>
    80003f7c:	c53fc0ef          	jal	80000bce <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003f80:	0001e497          	auipc	s1,0x1e
    80003f84:	48848493          	addi	s1,s1,1160 # 80022408 <ftable+0x18>
    80003f88:	0001f717          	auipc	a4,0x1f
    80003f8c:	42070713          	addi	a4,a4,1056 # 800233a8 <disk>
    if(f->ref == 0){
    80003f90:	40dc                	lw	a5,4(s1)
    80003f92:	cf89                	beqz	a5,80003fac <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003f94:	02848493          	addi	s1,s1,40
    80003f98:	fee49ce3          	bne	s1,a4,80003f90 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80003f9c:	0001e517          	auipc	a0,0x1e
    80003fa0:	45450513          	addi	a0,a0,1108 # 800223f0 <ftable>
    80003fa4:	cc3fc0ef          	jal	80000c66 <release>
  return 0;
    80003fa8:	4481                	li	s1,0
    80003faa:	a809                	j	80003fbc <filealloc+0x52>
      f->ref = 1;
    80003fac:	4785                	li	a5,1
    80003fae:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80003fb0:	0001e517          	auipc	a0,0x1e
    80003fb4:	44050513          	addi	a0,a0,1088 # 800223f0 <ftable>
    80003fb8:	caffc0ef          	jal	80000c66 <release>
}
    80003fbc:	8526                	mv	a0,s1
    80003fbe:	60e2                	ld	ra,24(sp)
    80003fc0:	6442                	ld	s0,16(sp)
    80003fc2:	64a2                	ld	s1,8(sp)
    80003fc4:	6105                	addi	sp,sp,32
    80003fc6:	8082                	ret

0000000080003fc8 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003fc8:	1101                	addi	sp,sp,-32
    80003fca:	ec06                	sd	ra,24(sp)
    80003fcc:	e822                	sd	s0,16(sp)
    80003fce:	e426                	sd	s1,8(sp)
    80003fd0:	1000                	addi	s0,sp,32
    80003fd2:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003fd4:	0001e517          	auipc	a0,0x1e
    80003fd8:	41c50513          	addi	a0,a0,1052 # 800223f0 <ftable>
    80003fdc:	bf3fc0ef          	jal	80000bce <acquire>
  if(f->ref < 1)
    80003fe0:	40dc                	lw	a5,4(s1)
    80003fe2:	02f05063          	blez	a5,80004002 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80003fe6:	2785                	addiw	a5,a5,1
    80003fe8:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003fea:	0001e517          	auipc	a0,0x1e
    80003fee:	40650513          	addi	a0,a0,1030 # 800223f0 <ftable>
    80003ff2:	c75fc0ef          	jal	80000c66 <release>
  return f;
}
    80003ff6:	8526                	mv	a0,s1
    80003ff8:	60e2                	ld	ra,24(sp)
    80003ffa:	6442                	ld	s0,16(sp)
    80003ffc:	64a2                	ld	s1,8(sp)
    80003ffe:	6105                	addi	sp,sp,32
    80004000:	8082                	ret
    panic("filedup");
    80004002:	00003517          	auipc	a0,0x3
    80004006:	55e50513          	addi	a0,a0,1374 # 80007560 <etext+0x560>
    8000400a:	fd6fc0ef          	jal	800007e0 <panic>

000000008000400e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000400e:	7139                	addi	sp,sp,-64
    80004010:	fc06                	sd	ra,56(sp)
    80004012:	f822                	sd	s0,48(sp)
    80004014:	f426                	sd	s1,40(sp)
    80004016:	0080                	addi	s0,sp,64
    80004018:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000401a:	0001e517          	auipc	a0,0x1e
    8000401e:	3d650513          	addi	a0,a0,982 # 800223f0 <ftable>
    80004022:	badfc0ef          	jal	80000bce <acquire>
  if(f->ref < 1)
    80004026:	40dc                	lw	a5,4(s1)
    80004028:	04f05a63          	blez	a5,8000407c <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    8000402c:	37fd                	addiw	a5,a5,-1
    8000402e:	0007871b          	sext.w	a4,a5
    80004032:	c0dc                	sw	a5,4(s1)
    80004034:	04e04e63          	bgtz	a4,80004090 <fileclose+0x82>
    80004038:	f04a                	sd	s2,32(sp)
    8000403a:	ec4e                	sd	s3,24(sp)
    8000403c:	e852                	sd	s4,16(sp)
    8000403e:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004040:	0004a903          	lw	s2,0(s1)
    80004044:	0094ca83          	lbu	s5,9(s1)
    80004048:	0104ba03          	ld	s4,16(s1)
    8000404c:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004050:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004054:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004058:	0001e517          	auipc	a0,0x1e
    8000405c:	39850513          	addi	a0,a0,920 # 800223f0 <ftable>
    80004060:	c07fc0ef          	jal	80000c66 <release>

  if(ff.type == FD_PIPE){
    80004064:	4785                	li	a5,1
    80004066:	04f90063          	beq	s2,a5,800040a6 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000406a:	3979                	addiw	s2,s2,-2
    8000406c:	4785                	li	a5,1
    8000406e:	0527f563          	bgeu	a5,s2,800040b8 <fileclose+0xaa>
    80004072:	7902                	ld	s2,32(sp)
    80004074:	69e2                	ld	s3,24(sp)
    80004076:	6a42                	ld	s4,16(sp)
    80004078:	6aa2                	ld	s5,8(sp)
    8000407a:	a00d                	j	8000409c <fileclose+0x8e>
    8000407c:	f04a                	sd	s2,32(sp)
    8000407e:	ec4e                	sd	s3,24(sp)
    80004080:	e852                	sd	s4,16(sp)
    80004082:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004084:	00003517          	auipc	a0,0x3
    80004088:	4e450513          	addi	a0,a0,1252 # 80007568 <etext+0x568>
    8000408c:	f54fc0ef          	jal	800007e0 <panic>
    release(&ftable.lock);
    80004090:	0001e517          	auipc	a0,0x1e
    80004094:	36050513          	addi	a0,a0,864 # 800223f0 <ftable>
    80004098:	bcffc0ef          	jal	80000c66 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    8000409c:	70e2                	ld	ra,56(sp)
    8000409e:	7442                	ld	s0,48(sp)
    800040a0:	74a2                	ld	s1,40(sp)
    800040a2:	6121                	addi	sp,sp,64
    800040a4:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800040a6:	85d6                	mv	a1,s5
    800040a8:	8552                	mv	a0,s4
    800040aa:	336000ef          	jal	800043e0 <pipeclose>
    800040ae:	7902                	ld	s2,32(sp)
    800040b0:	69e2                	ld	s3,24(sp)
    800040b2:	6a42                	ld	s4,16(sp)
    800040b4:	6aa2                	ld	s5,8(sp)
    800040b6:	b7dd                	j	8000409c <fileclose+0x8e>
    begin_op();
    800040b8:	b4bff0ef          	jal	80003c02 <begin_op>
    iput(ff.ip);
    800040bc:	854e                	mv	a0,s3
    800040be:	adcff0ef          	jal	8000339a <iput>
    end_op();
    800040c2:	babff0ef          	jal	80003c6c <end_op>
    800040c6:	7902                	ld	s2,32(sp)
    800040c8:	69e2                	ld	s3,24(sp)
    800040ca:	6a42                	ld	s4,16(sp)
    800040cc:	6aa2                	ld	s5,8(sp)
    800040ce:	b7f9                	j	8000409c <fileclose+0x8e>

00000000800040d0 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800040d0:	715d                	addi	sp,sp,-80
    800040d2:	e486                	sd	ra,72(sp)
    800040d4:	e0a2                	sd	s0,64(sp)
    800040d6:	fc26                	sd	s1,56(sp)
    800040d8:	f44e                	sd	s3,40(sp)
    800040da:	0880                	addi	s0,sp,80
    800040dc:	84aa                	mv	s1,a0
    800040de:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800040e0:	feefd0ef          	jal	800018ce <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800040e4:	409c                	lw	a5,0(s1)
    800040e6:	37f9                	addiw	a5,a5,-2
    800040e8:	4705                	li	a4,1
    800040ea:	04f76063          	bltu	a4,a5,8000412a <filestat+0x5a>
    800040ee:	f84a                	sd	s2,48(sp)
    800040f0:	892a                	mv	s2,a0
    ilock(f->ip);
    800040f2:	6c88                	ld	a0,24(s1)
    800040f4:	924ff0ef          	jal	80003218 <ilock>
    stati(f->ip, &st);
    800040f8:	fb840593          	addi	a1,s0,-72
    800040fc:	6c88                	ld	a0,24(s1)
    800040fe:	c80ff0ef          	jal	8000357e <stati>
    iunlock(f->ip);
    80004102:	6c88                	ld	a0,24(s1)
    80004104:	9c2ff0ef          	jal	800032c6 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004108:	46e1                	li	a3,24
    8000410a:	fb840613          	addi	a2,s0,-72
    8000410e:	85ce                	mv	a1,s3
    80004110:	05093503          	ld	a0,80(s2)
    80004114:	ccefd0ef          	jal	800015e2 <copyout>
    80004118:	41f5551b          	sraiw	a0,a0,0x1f
    8000411c:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    8000411e:	60a6                	ld	ra,72(sp)
    80004120:	6406                	ld	s0,64(sp)
    80004122:	74e2                	ld	s1,56(sp)
    80004124:	79a2                	ld	s3,40(sp)
    80004126:	6161                	addi	sp,sp,80
    80004128:	8082                	ret
  return -1;
    8000412a:	557d                	li	a0,-1
    8000412c:	bfcd                	j	8000411e <filestat+0x4e>

000000008000412e <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000412e:	7179                	addi	sp,sp,-48
    80004130:	f406                	sd	ra,40(sp)
    80004132:	f022                	sd	s0,32(sp)
    80004134:	e84a                	sd	s2,16(sp)
    80004136:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004138:	00854783          	lbu	a5,8(a0)
    8000413c:	cfd1                	beqz	a5,800041d8 <fileread+0xaa>
    8000413e:	ec26                	sd	s1,24(sp)
    80004140:	e44e                	sd	s3,8(sp)
    80004142:	84aa                	mv	s1,a0
    80004144:	89ae                	mv	s3,a1
    80004146:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004148:	411c                	lw	a5,0(a0)
    8000414a:	4705                	li	a4,1
    8000414c:	04e78363          	beq	a5,a4,80004192 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004150:	470d                	li	a4,3
    80004152:	04e78763          	beq	a5,a4,800041a0 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004156:	4709                	li	a4,2
    80004158:	06e79a63          	bne	a5,a4,800041cc <fileread+0x9e>
    ilock(f->ip);
    8000415c:	6d08                	ld	a0,24(a0)
    8000415e:	8baff0ef          	jal	80003218 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004162:	874a                	mv	a4,s2
    80004164:	5094                	lw	a3,32(s1)
    80004166:	864e                	mv	a2,s3
    80004168:	4585                	li	a1,1
    8000416a:	6c88                	ld	a0,24(s1)
    8000416c:	c3cff0ef          	jal	800035a8 <readi>
    80004170:	892a                	mv	s2,a0
    80004172:	00a05563          	blez	a0,8000417c <fileread+0x4e>
      f->off += r;
    80004176:	509c                	lw	a5,32(s1)
    80004178:	9fa9                	addw	a5,a5,a0
    8000417a:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000417c:	6c88                	ld	a0,24(s1)
    8000417e:	948ff0ef          	jal	800032c6 <iunlock>
    80004182:	64e2                	ld	s1,24(sp)
    80004184:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004186:	854a                	mv	a0,s2
    80004188:	70a2                	ld	ra,40(sp)
    8000418a:	7402                	ld	s0,32(sp)
    8000418c:	6942                	ld	s2,16(sp)
    8000418e:	6145                	addi	sp,sp,48
    80004190:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004192:	6908                	ld	a0,16(a0)
    80004194:	388000ef          	jal	8000451c <piperead>
    80004198:	892a                	mv	s2,a0
    8000419a:	64e2                	ld	s1,24(sp)
    8000419c:	69a2                	ld	s3,8(sp)
    8000419e:	b7e5                	j	80004186 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800041a0:	02451783          	lh	a5,36(a0)
    800041a4:	03079693          	slli	a3,a5,0x30
    800041a8:	92c1                	srli	a3,a3,0x30
    800041aa:	4725                	li	a4,9
    800041ac:	02d76863          	bltu	a4,a3,800041dc <fileread+0xae>
    800041b0:	0792                	slli	a5,a5,0x4
    800041b2:	0001e717          	auipc	a4,0x1e
    800041b6:	19e70713          	addi	a4,a4,414 # 80022350 <devsw>
    800041ba:	97ba                	add	a5,a5,a4
    800041bc:	639c                	ld	a5,0(a5)
    800041be:	c39d                	beqz	a5,800041e4 <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    800041c0:	4505                	li	a0,1
    800041c2:	9782                	jalr	a5
    800041c4:	892a                	mv	s2,a0
    800041c6:	64e2                	ld	s1,24(sp)
    800041c8:	69a2                	ld	s3,8(sp)
    800041ca:	bf75                	j	80004186 <fileread+0x58>
    panic("fileread");
    800041cc:	00003517          	auipc	a0,0x3
    800041d0:	3ac50513          	addi	a0,a0,940 # 80007578 <etext+0x578>
    800041d4:	e0cfc0ef          	jal	800007e0 <panic>
    return -1;
    800041d8:	597d                	li	s2,-1
    800041da:	b775                	j	80004186 <fileread+0x58>
      return -1;
    800041dc:	597d                	li	s2,-1
    800041de:	64e2                	ld	s1,24(sp)
    800041e0:	69a2                	ld	s3,8(sp)
    800041e2:	b755                	j	80004186 <fileread+0x58>
    800041e4:	597d                	li	s2,-1
    800041e6:	64e2                	ld	s1,24(sp)
    800041e8:	69a2                	ld	s3,8(sp)
    800041ea:	bf71                	j	80004186 <fileread+0x58>

00000000800041ec <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800041ec:	00954783          	lbu	a5,9(a0)
    800041f0:	10078b63          	beqz	a5,80004306 <filewrite+0x11a>
{
    800041f4:	715d                	addi	sp,sp,-80
    800041f6:	e486                	sd	ra,72(sp)
    800041f8:	e0a2                	sd	s0,64(sp)
    800041fa:	f84a                	sd	s2,48(sp)
    800041fc:	f052                	sd	s4,32(sp)
    800041fe:	e85a                	sd	s6,16(sp)
    80004200:	0880                	addi	s0,sp,80
    80004202:	892a                	mv	s2,a0
    80004204:	8b2e                	mv	s6,a1
    80004206:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004208:	411c                	lw	a5,0(a0)
    8000420a:	4705                	li	a4,1
    8000420c:	02e78763          	beq	a5,a4,8000423a <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004210:	470d                	li	a4,3
    80004212:	02e78863          	beq	a5,a4,80004242 <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004216:	4709                	li	a4,2
    80004218:	0ce79c63          	bne	a5,a4,800042f0 <filewrite+0x104>
    8000421c:	f44e                	sd	s3,40(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000421e:	0ac05863          	blez	a2,800042ce <filewrite+0xe2>
    80004222:	fc26                	sd	s1,56(sp)
    80004224:	ec56                	sd	s5,24(sp)
    80004226:	e45e                	sd	s7,8(sp)
    80004228:	e062                	sd	s8,0(sp)
    int i = 0;
    8000422a:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    8000422c:	6b85                	lui	s7,0x1
    8000422e:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004232:	6c05                	lui	s8,0x1
    80004234:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004238:	a8b5                	j	800042b4 <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    8000423a:	6908                	ld	a0,16(a0)
    8000423c:	1fc000ef          	jal	80004438 <pipewrite>
    80004240:	a04d                	j	800042e2 <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004242:	02451783          	lh	a5,36(a0)
    80004246:	03079693          	slli	a3,a5,0x30
    8000424a:	92c1                	srli	a3,a3,0x30
    8000424c:	4725                	li	a4,9
    8000424e:	0ad76e63          	bltu	a4,a3,8000430a <filewrite+0x11e>
    80004252:	0792                	slli	a5,a5,0x4
    80004254:	0001e717          	auipc	a4,0x1e
    80004258:	0fc70713          	addi	a4,a4,252 # 80022350 <devsw>
    8000425c:	97ba                	add	a5,a5,a4
    8000425e:	679c                	ld	a5,8(a5)
    80004260:	c7dd                	beqz	a5,8000430e <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    80004262:	4505                	li	a0,1
    80004264:	9782                	jalr	a5
    80004266:	a8b5                	j	800042e2 <filewrite+0xf6>
      if(n1 > max)
    80004268:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    8000426c:	997ff0ef          	jal	80003c02 <begin_op>
      ilock(f->ip);
    80004270:	01893503          	ld	a0,24(s2)
    80004274:	fa5fe0ef          	jal	80003218 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004278:	8756                	mv	a4,s5
    8000427a:	02092683          	lw	a3,32(s2)
    8000427e:	01698633          	add	a2,s3,s6
    80004282:	4585                	li	a1,1
    80004284:	01893503          	ld	a0,24(s2)
    80004288:	c1cff0ef          	jal	800036a4 <writei>
    8000428c:	84aa                	mv	s1,a0
    8000428e:	00a05763          	blez	a0,8000429c <filewrite+0xb0>
        f->off += r;
    80004292:	02092783          	lw	a5,32(s2)
    80004296:	9fa9                	addw	a5,a5,a0
    80004298:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000429c:	01893503          	ld	a0,24(s2)
    800042a0:	826ff0ef          	jal	800032c6 <iunlock>
      end_op();
    800042a4:	9c9ff0ef          	jal	80003c6c <end_op>

      if(r != n1){
    800042a8:	029a9563          	bne	s5,s1,800042d2 <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    800042ac:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800042b0:	0149da63          	bge	s3,s4,800042c4 <filewrite+0xd8>
      int n1 = n - i;
    800042b4:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    800042b8:	0004879b          	sext.w	a5,s1
    800042bc:	fafbd6e3          	bge	s7,a5,80004268 <filewrite+0x7c>
    800042c0:	84e2                	mv	s1,s8
    800042c2:	b75d                	j	80004268 <filewrite+0x7c>
    800042c4:	74e2                	ld	s1,56(sp)
    800042c6:	6ae2                	ld	s5,24(sp)
    800042c8:	6ba2                	ld	s7,8(sp)
    800042ca:	6c02                	ld	s8,0(sp)
    800042cc:	a039                	j	800042da <filewrite+0xee>
    int i = 0;
    800042ce:	4981                	li	s3,0
    800042d0:	a029                	j	800042da <filewrite+0xee>
    800042d2:	74e2                	ld	s1,56(sp)
    800042d4:	6ae2                	ld	s5,24(sp)
    800042d6:	6ba2                	ld	s7,8(sp)
    800042d8:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    800042da:	033a1c63          	bne	s4,s3,80004312 <filewrite+0x126>
    800042de:	8552                	mv	a0,s4
    800042e0:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    800042e2:	60a6                	ld	ra,72(sp)
    800042e4:	6406                	ld	s0,64(sp)
    800042e6:	7942                	ld	s2,48(sp)
    800042e8:	7a02                	ld	s4,32(sp)
    800042ea:	6b42                	ld	s6,16(sp)
    800042ec:	6161                	addi	sp,sp,80
    800042ee:	8082                	ret
    800042f0:	fc26                	sd	s1,56(sp)
    800042f2:	f44e                	sd	s3,40(sp)
    800042f4:	ec56                	sd	s5,24(sp)
    800042f6:	e45e                	sd	s7,8(sp)
    800042f8:	e062                	sd	s8,0(sp)
    panic("filewrite");
    800042fa:	00003517          	auipc	a0,0x3
    800042fe:	28e50513          	addi	a0,a0,654 # 80007588 <etext+0x588>
    80004302:	cdefc0ef          	jal	800007e0 <panic>
    return -1;
    80004306:	557d                	li	a0,-1
}
    80004308:	8082                	ret
      return -1;
    8000430a:	557d                	li	a0,-1
    8000430c:	bfd9                	j	800042e2 <filewrite+0xf6>
    8000430e:	557d                	li	a0,-1
    80004310:	bfc9                	j	800042e2 <filewrite+0xf6>
    ret = (i == n ? n : -1);
    80004312:	557d                	li	a0,-1
    80004314:	79a2                	ld	s3,40(sp)
    80004316:	b7f1                	j	800042e2 <filewrite+0xf6>

0000000080004318 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004318:	7179                	addi	sp,sp,-48
    8000431a:	f406                	sd	ra,40(sp)
    8000431c:	f022                	sd	s0,32(sp)
    8000431e:	ec26                	sd	s1,24(sp)
    80004320:	e052                	sd	s4,0(sp)
    80004322:	1800                	addi	s0,sp,48
    80004324:	84aa                	mv	s1,a0
    80004326:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004328:	0005b023          	sd	zero,0(a1)
    8000432c:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004330:	c3bff0ef          	jal	80003f6a <filealloc>
    80004334:	e088                	sd	a0,0(s1)
    80004336:	c549                	beqz	a0,800043c0 <pipealloc+0xa8>
    80004338:	c33ff0ef          	jal	80003f6a <filealloc>
    8000433c:	00aa3023          	sd	a0,0(s4)
    80004340:	cd25                	beqz	a0,800043b8 <pipealloc+0xa0>
    80004342:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004344:	fbafc0ef          	jal	80000afe <kalloc>
    80004348:	892a                	mv	s2,a0
    8000434a:	c12d                	beqz	a0,800043ac <pipealloc+0x94>
    8000434c:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    8000434e:	4985                	li	s3,1
    80004350:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004354:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004358:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000435c:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004360:	00003597          	auipc	a1,0x3
    80004364:	23858593          	addi	a1,a1,568 # 80007598 <etext+0x598>
    80004368:	fe6fc0ef          	jal	80000b4e <initlock>
  (*f0)->type = FD_PIPE;
    8000436c:	609c                	ld	a5,0(s1)
    8000436e:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004372:	609c                	ld	a5,0(s1)
    80004374:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004378:	609c                	ld	a5,0(s1)
    8000437a:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000437e:	609c                	ld	a5,0(s1)
    80004380:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004384:	000a3783          	ld	a5,0(s4)
    80004388:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000438c:	000a3783          	ld	a5,0(s4)
    80004390:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004394:	000a3783          	ld	a5,0(s4)
    80004398:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000439c:	000a3783          	ld	a5,0(s4)
    800043a0:	0127b823          	sd	s2,16(a5)
  return 0;
    800043a4:	4501                	li	a0,0
    800043a6:	6942                	ld	s2,16(sp)
    800043a8:	69a2                	ld	s3,8(sp)
    800043aa:	a01d                	j	800043d0 <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800043ac:	6088                	ld	a0,0(s1)
    800043ae:	c119                	beqz	a0,800043b4 <pipealloc+0x9c>
    800043b0:	6942                	ld	s2,16(sp)
    800043b2:	a029                	j	800043bc <pipealloc+0xa4>
    800043b4:	6942                	ld	s2,16(sp)
    800043b6:	a029                	j	800043c0 <pipealloc+0xa8>
    800043b8:	6088                	ld	a0,0(s1)
    800043ba:	c10d                	beqz	a0,800043dc <pipealloc+0xc4>
    fileclose(*f0);
    800043bc:	c53ff0ef          	jal	8000400e <fileclose>
  if(*f1)
    800043c0:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800043c4:	557d                	li	a0,-1
  if(*f1)
    800043c6:	c789                	beqz	a5,800043d0 <pipealloc+0xb8>
    fileclose(*f1);
    800043c8:	853e                	mv	a0,a5
    800043ca:	c45ff0ef          	jal	8000400e <fileclose>
  return -1;
    800043ce:	557d                	li	a0,-1
}
    800043d0:	70a2                	ld	ra,40(sp)
    800043d2:	7402                	ld	s0,32(sp)
    800043d4:	64e2                	ld	s1,24(sp)
    800043d6:	6a02                	ld	s4,0(sp)
    800043d8:	6145                	addi	sp,sp,48
    800043da:	8082                	ret
  return -1;
    800043dc:	557d                	li	a0,-1
    800043de:	bfcd                	j	800043d0 <pipealloc+0xb8>

00000000800043e0 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800043e0:	1101                	addi	sp,sp,-32
    800043e2:	ec06                	sd	ra,24(sp)
    800043e4:	e822                	sd	s0,16(sp)
    800043e6:	e426                	sd	s1,8(sp)
    800043e8:	e04a                	sd	s2,0(sp)
    800043ea:	1000                	addi	s0,sp,32
    800043ec:	84aa                	mv	s1,a0
    800043ee:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800043f0:	fdefc0ef          	jal	80000bce <acquire>
  if(writable){
    800043f4:	02090763          	beqz	s2,80004422 <pipeclose+0x42>
    pi->writeopen = 0;
    800043f8:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800043fc:	21848513          	addi	a0,s1,536
    80004400:	b13fd0ef          	jal	80001f12 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004404:	2204b783          	ld	a5,544(s1)
    80004408:	e785                	bnez	a5,80004430 <pipeclose+0x50>
    release(&pi->lock);
    8000440a:	8526                	mv	a0,s1
    8000440c:	85bfc0ef          	jal	80000c66 <release>
    kfree((char*)pi);
    80004410:	8526                	mv	a0,s1
    80004412:	e0afc0ef          	jal	80000a1c <kfree>
  } else
    release(&pi->lock);
}
    80004416:	60e2                	ld	ra,24(sp)
    80004418:	6442                	ld	s0,16(sp)
    8000441a:	64a2                	ld	s1,8(sp)
    8000441c:	6902                	ld	s2,0(sp)
    8000441e:	6105                	addi	sp,sp,32
    80004420:	8082                	ret
    pi->readopen = 0;
    80004422:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004426:	21c48513          	addi	a0,s1,540
    8000442a:	ae9fd0ef          	jal	80001f12 <wakeup>
    8000442e:	bfd9                	j	80004404 <pipeclose+0x24>
    release(&pi->lock);
    80004430:	8526                	mv	a0,s1
    80004432:	835fc0ef          	jal	80000c66 <release>
}
    80004436:	b7c5                	j	80004416 <pipeclose+0x36>

0000000080004438 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004438:	711d                	addi	sp,sp,-96
    8000443a:	ec86                	sd	ra,88(sp)
    8000443c:	e8a2                	sd	s0,80(sp)
    8000443e:	e4a6                	sd	s1,72(sp)
    80004440:	e0ca                	sd	s2,64(sp)
    80004442:	fc4e                	sd	s3,56(sp)
    80004444:	f852                	sd	s4,48(sp)
    80004446:	f456                	sd	s5,40(sp)
    80004448:	1080                	addi	s0,sp,96
    8000444a:	84aa                	mv	s1,a0
    8000444c:	8aae                	mv	s5,a1
    8000444e:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004450:	c7efd0ef          	jal	800018ce <myproc>
    80004454:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004456:	8526                	mv	a0,s1
    80004458:	f76fc0ef          	jal	80000bce <acquire>
  while(i < n){
    8000445c:	0b405a63          	blez	s4,80004510 <pipewrite+0xd8>
    80004460:	f05a                	sd	s6,32(sp)
    80004462:	ec5e                	sd	s7,24(sp)
    80004464:	e862                	sd	s8,16(sp)
  int i = 0;
    80004466:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004468:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000446a:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000446e:	21c48b93          	addi	s7,s1,540
    80004472:	a81d                	j	800044a8 <pipewrite+0x70>
      release(&pi->lock);
    80004474:	8526                	mv	a0,s1
    80004476:	ff0fc0ef          	jal	80000c66 <release>
      return -1;
    8000447a:	597d                	li	s2,-1
    8000447c:	7b02                	ld	s6,32(sp)
    8000447e:	6be2                	ld	s7,24(sp)
    80004480:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004482:	854a                	mv	a0,s2
    80004484:	60e6                	ld	ra,88(sp)
    80004486:	6446                	ld	s0,80(sp)
    80004488:	64a6                	ld	s1,72(sp)
    8000448a:	6906                	ld	s2,64(sp)
    8000448c:	79e2                	ld	s3,56(sp)
    8000448e:	7a42                	ld	s4,48(sp)
    80004490:	7aa2                	ld	s5,40(sp)
    80004492:	6125                	addi	sp,sp,96
    80004494:	8082                	ret
      wakeup(&pi->nread);
    80004496:	8562                	mv	a0,s8
    80004498:	a7bfd0ef          	jal	80001f12 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000449c:	85a6                	mv	a1,s1
    8000449e:	855e                	mv	a0,s7
    800044a0:	a27fd0ef          	jal	80001ec6 <sleep>
  while(i < n){
    800044a4:	05495b63          	bge	s2,s4,800044fa <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    800044a8:	2204a783          	lw	a5,544(s1)
    800044ac:	d7e1                	beqz	a5,80004474 <pipewrite+0x3c>
    800044ae:	854e                	mv	a0,s3
    800044b0:	c4ffd0ef          	jal	800020fe <killed>
    800044b4:	f161                	bnez	a0,80004474 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800044b6:	2184a783          	lw	a5,536(s1)
    800044ba:	21c4a703          	lw	a4,540(s1)
    800044be:	2007879b          	addiw	a5,a5,512
    800044c2:	fcf70ae3          	beq	a4,a5,80004496 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800044c6:	4685                	li	a3,1
    800044c8:	01590633          	add	a2,s2,s5
    800044cc:	faf40593          	addi	a1,s0,-81
    800044d0:	0509b503          	ld	a0,80(s3)
    800044d4:	9f2fd0ef          	jal	800016c6 <copyin>
    800044d8:	03650e63          	beq	a0,s6,80004514 <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800044dc:	21c4a783          	lw	a5,540(s1)
    800044e0:	0017871b          	addiw	a4,a5,1
    800044e4:	20e4ae23          	sw	a4,540(s1)
    800044e8:	1ff7f793          	andi	a5,a5,511
    800044ec:	97a6                	add	a5,a5,s1
    800044ee:	faf44703          	lbu	a4,-81(s0)
    800044f2:	00e78c23          	sb	a4,24(a5)
      i++;
    800044f6:	2905                	addiw	s2,s2,1
    800044f8:	b775                	j	800044a4 <pipewrite+0x6c>
    800044fa:	7b02                	ld	s6,32(sp)
    800044fc:	6be2                	ld	s7,24(sp)
    800044fe:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    80004500:	21848513          	addi	a0,s1,536
    80004504:	a0ffd0ef          	jal	80001f12 <wakeup>
  release(&pi->lock);
    80004508:	8526                	mv	a0,s1
    8000450a:	f5cfc0ef          	jal	80000c66 <release>
  return i;
    8000450e:	bf95                	j	80004482 <pipewrite+0x4a>
  int i = 0;
    80004510:	4901                	li	s2,0
    80004512:	b7fd                	j	80004500 <pipewrite+0xc8>
    80004514:	7b02                	ld	s6,32(sp)
    80004516:	6be2                	ld	s7,24(sp)
    80004518:	6c42                	ld	s8,16(sp)
    8000451a:	b7dd                	j	80004500 <pipewrite+0xc8>

000000008000451c <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000451c:	715d                	addi	sp,sp,-80
    8000451e:	e486                	sd	ra,72(sp)
    80004520:	e0a2                	sd	s0,64(sp)
    80004522:	fc26                	sd	s1,56(sp)
    80004524:	f84a                	sd	s2,48(sp)
    80004526:	f44e                	sd	s3,40(sp)
    80004528:	f052                	sd	s4,32(sp)
    8000452a:	ec56                	sd	s5,24(sp)
    8000452c:	0880                	addi	s0,sp,80
    8000452e:	84aa                	mv	s1,a0
    80004530:	892e                	mv	s2,a1
    80004532:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004534:	b9afd0ef          	jal	800018ce <myproc>
    80004538:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    8000453a:	8526                	mv	a0,s1
    8000453c:	e92fc0ef          	jal	80000bce <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004540:	2184a703          	lw	a4,536(s1)
    80004544:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004548:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000454c:	02f71563          	bne	a4,a5,80004576 <piperead+0x5a>
    80004550:	2244a783          	lw	a5,548(s1)
    80004554:	cb85                	beqz	a5,80004584 <piperead+0x68>
    if(killed(pr)){
    80004556:	8552                	mv	a0,s4
    80004558:	ba7fd0ef          	jal	800020fe <killed>
    8000455c:	ed19                	bnez	a0,8000457a <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000455e:	85a6                	mv	a1,s1
    80004560:	854e                	mv	a0,s3
    80004562:	965fd0ef          	jal	80001ec6 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004566:	2184a703          	lw	a4,536(s1)
    8000456a:	21c4a783          	lw	a5,540(s1)
    8000456e:	fef701e3          	beq	a4,a5,80004550 <piperead+0x34>
    80004572:	e85a                	sd	s6,16(sp)
    80004574:	a809                	j	80004586 <piperead+0x6a>
    80004576:	e85a                	sd	s6,16(sp)
    80004578:	a039                	j	80004586 <piperead+0x6a>
      release(&pi->lock);
    8000457a:	8526                	mv	a0,s1
    8000457c:	eeafc0ef          	jal	80000c66 <release>
      return -1;
    80004580:	59fd                	li	s3,-1
    80004582:	a8b1                	j	800045de <piperead+0xc2>
    80004584:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004586:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004588:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000458a:	05505263          	blez	s5,800045ce <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    8000458e:	2184a783          	lw	a5,536(s1)
    80004592:	21c4a703          	lw	a4,540(s1)
    80004596:	02f70c63          	beq	a4,a5,800045ce <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    8000459a:	0017871b          	addiw	a4,a5,1
    8000459e:	20e4ac23          	sw	a4,536(s1)
    800045a2:	1ff7f793          	andi	a5,a5,511
    800045a6:	97a6                	add	a5,a5,s1
    800045a8:	0187c783          	lbu	a5,24(a5)
    800045ac:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800045b0:	4685                	li	a3,1
    800045b2:	fbf40613          	addi	a2,s0,-65
    800045b6:	85ca                	mv	a1,s2
    800045b8:	050a3503          	ld	a0,80(s4)
    800045bc:	826fd0ef          	jal	800015e2 <copyout>
    800045c0:	01650763          	beq	a0,s6,800045ce <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800045c4:	2985                	addiw	s3,s3,1
    800045c6:	0905                	addi	s2,s2,1
    800045c8:	fd3a93e3          	bne	s5,s3,8000458e <piperead+0x72>
    800045cc:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800045ce:	21c48513          	addi	a0,s1,540
    800045d2:	941fd0ef          	jal	80001f12 <wakeup>
  release(&pi->lock);
    800045d6:	8526                	mv	a0,s1
    800045d8:	e8efc0ef          	jal	80000c66 <release>
    800045dc:	6b42                	ld	s6,16(sp)
  return i;
}
    800045de:	854e                	mv	a0,s3
    800045e0:	60a6                	ld	ra,72(sp)
    800045e2:	6406                	ld	s0,64(sp)
    800045e4:	74e2                	ld	s1,56(sp)
    800045e6:	7942                	ld	s2,48(sp)
    800045e8:	79a2                	ld	s3,40(sp)
    800045ea:	7a02                	ld	s4,32(sp)
    800045ec:	6ae2                	ld	s5,24(sp)
    800045ee:	6161                	addi	sp,sp,80
    800045f0:	8082                	ret

00000000800045f2 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    800045f2:	1141                	addi	sp,sp,-16
    800045f4:	e422                	sd	s0,8(sp)
    800045f6:	0800                	addi	s0,sp,16
    800045f8:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800045fa:	8905                	andi	a0,a0,1
    800045fc:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    800045fe:	8b89                	andi	a5,a5,2
    80004600:	c399                	beqz	a5,80004606 <flags2perm+0x14>
      perm |= PTE_W;
    80004602:	00456513          	ori	a0,a0,4
    return perm;
}
    80004606:	6422                	ld	s0,8(sp)
    80004608:	0141                	addi	sp,sp,16
    8000460a:	8082                	ret

000000008000460c <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    8000460c:	df010113          	addi	sp,sp,-528
    80004610:	20113423          	sd	ra,520(sp)
    80004614:	20813023          	sd	s0,512(sp)
    80004618:	ffa6                	sd	s1,504(sp)
    8000461a:	fbca                	sd	s2,496(sp)
    8000461c:	0c00                	addi	s0,sp,528
    8000461e:	892a                	mv	s2,a0
    80004620:	dea43c23          	sd	a0,-520(s0)
    80004624:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004628:	aa6fd0ef          	jal	800018ce <myproc>
    8000462c:	84aa                	mv	s1,a0

  begin_op();
    8000462e:	dd4ff0ef          	jal	80003c02 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    80004632:	854a                	mv	a0,s2
    80004634:	bfaff0ef          	jal	80003a2e <namei>
    80004638:	c931                	beqz	a0,8000468c <kexec+0x80>
    8000463a:	f3d2                	sd	s4,480(sp)
    8000463c:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000463e:	bdbfe0ef          	jal	80003218 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004642:	04000713          	li	a4,64
    80004646:	4681                	li	a3,0
    80004648:	e5040613          	addi	a2,s0,-432
    8000464c:	4581                	li	a1,0
    8000464e:	8552                	mv	a0,s4
    80004650:	f59fe0ef          	jal	800035a8 <readi>
    80004654:	04000793          	li	a5,64
    80004658:	00f51a63          	bne	a0,a5,8000466c <kexec+0x60>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    8000465c:	e5042703          	lw	a4,-432(s0)
    80004660:	464c47b7          	lui	a5,0x464c4
    80004664:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004668:	02f70663          	beq	a4,a5,80004694 <kexec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000466c:	8552                	mv	a0,s4
    8000466e:	db5fe0ef          	jal	80003422 <iunlockput>
    end_op();
    80004672:	dfaff0ef          	jal	80003c6c <end_op>
  }
  return -1;
    80004676:	557d                	li	a0,-1
    80004678:	7a1e                	ld	s4,480(sp)
}
    8000467a:	20813083          	ld	ra,520(sp)
    8000467e:	20013403          	ld	s0,512(sp)
    80004682:	74fe                	ld	s1,504(sp)
    80004684:	795e                	ld	s2,496(sp)
    80004686:	21010113          	addi	sp,sp,528
    8000468a:	8082                	ret
    end_op();
    8000468c:	de0ff0ef          	jal	80003c6c <end_op>
    return -1;
    80004690:	557d                	li	a0,-1
    80004692:	b7e5                	j	8000467a <kexec+0x6e>
    80004694:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004696:	8526                	mv	a0,s1
    80004698:	b3cfd0ef          	jal	800019d4 <proc_pagetable>
    8000469c:	8b2a                	mv	s6,a0
    8000469e:	2c050b63          	beqz	a0,80004974 <kexec+0x368>
    800046a2:	f7ce                	sd	s3,488(sp)
    800046a4:	efd6                	sd	s5,472(sp)
    800046a6:	e7de                	sd	s7,456(sp)
    800046a8:	e3e2                	sd	s8,448(sp)
    800046aa:	ff66                	sd	s9,440(sp)
    800046ac:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800046ae:	e7042d03          	lw	s10,-400(s0)
    800046b2:	e8845783          	lhu	a5,-376(s0)
    800046b6:	12078963          	beqz	a5,800047e8 <kexec+0x1dc>
    800046ba:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800046bc:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800046be:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    800046c0:	6c85                	lui	s9,0x1
    800046c2:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800046c6:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    800046ca:	6a85                	lui	s5,0x1
    800046cc:	a085                	j	8000472c <kexec+0x120>
      panic("loadseg: address should exist");
    800046ce:	00003517          	auipc	a0,0x3
    800046d2:	ed250513          	addi	a0,a0,-302 # 800075a0 <etext+0x5a0>
    800046d6:	90afc0ef          	jal	800007e0 <panic>
    if(sz - i < PGSIZE)
    800046da:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800046dc:	8726                	mv	a4,s1
    800046de:	012c06bb          	addw	a3,s8,s2
    800046e2:	4581                	li	a1,0
    800046e4:	8552                	mv	a0,s4
    800046e6:	ec3fe0ef          	jal	800035a8 <readi>
    800046ea:	2501                	sext.w	a0,a0
    800046ec:	24a49a63          	bne	s1,a0,80004940 <kexec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    800046f0:	012a893b          	addw	s2,s5,s2
    800046f4:	03397363          	bgeu	s2,s3,8000471a <kexec+0x10e>
    pa = walkaddr(pagetable, va + i);
    800046f8:	02091593          	slli	a1,s2,0x20
    800046fc:	9181                	srli	a1,a1,0x20
    800046fe:	95de                	add	a1,a1,s7
    80004700:	855a                	mv	a0,s6
    80004702:	8affc0ef          	jal	80000fb0 <walkaddr>
    80004706:	862a                	mv	a2,a0
    if(pa == 0)
    80004708:	d179                	beqz	a0,800046ce <kexec+0xc2>
    if(sz - i < PGSIZE)
    8000470a:	412984bb          	subw	s1,s3,s2
    8000470e:	0004879b          	sext.w	a5,s1
    80004712:	fcfcf4e3          	bgeu	s9,a5,800046da <kexec+0xce>
    80004716:	84d6                	mv	s1,s5
    80004718:	b7c9                	j	800046da <kexec+0xce>
    sz = sz1;
    8000471a:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000471e:	2d85                	addiw	s11,s11,1
    80004720:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    80004724:	e8845783          	lhu	a5,-376(s0)
    80004728:	08fdd063          	bge	s11,a5,800047a8 <kexec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000472c:	2d01                	sext.w	s10,s10
    8000472e:	03800713          	li	a4,56
    80004732:	86ea                	mv	a3,s10
    80004734:	e1840613          	addi	a2,s0,-488
    80004738:	4581                	li	a1,0
    8000473a:	8552                	mv	a0,s4
    8000473c:	e6dfe0ef          	jal	800035a8 <readi>
    80004740:	03800793          	li	a5,56
    80004744:	1cf51663          	bne	a0,a5,80004910 <kexec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    80004748:	e1842783          	lw	a5,-488(s0)
    8000474c:	4705                	li	a4,1
    8000474e:	fce798e3          	bne	a5,a4,8000471e <kexec+0x112>
    if(ph.memsz < ph.filesz)
    80004752:	e4043483          	ld	s1,-448(s0)
    80004756:	e3843783          	ld	a5,-456(s0)
    8000475a:	1af4ef63          	bltu	s1,a5,80004918 <kexec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000475e:	e2843783          	ld	a5,-472(s0)
    80004762:	94be                	add	s1,s1,a5
    80004764:	1af4ee63          	bltu	s1,a5,80004920 <kexec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    80004768:	df043703          	ld	a4,-528(s0)
    8000476c:	8ff9                	and	a5,a5,a4
    8000476e:	1a079d63          	bnez	a5,80004928 <kexec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004772:	e1c42503          	lw	a0,-484(s0)
    80004776:	e7dff0ef          	jal	800045f2 <flags2perm>
    8000477a:	86aa                	mv	a3,a0
    8000477c:	8626                	mv	a2,s1
    8000477e:	85ca                	mv	a1,s2
    80004780:	855a                	mv	a0,s6
    80004782:	b07fc0ef          	jal	80001288 <uvmalloc>
    80004786:	e0a43423          	sd	a0,-504(s0)
    8000478a:	1a050363          	beqz	a0,80004930 <kexec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000478e:	e2843b83          	ld	s7,-472(s0)
    80004792:	e2042c03          	lw	s8,-480(s0)
    80004796:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000479a:	00098463          	beqz	s3,800047a2 <kexec+0x196>
    8000479e:	4901                	li	s2,0
    800047a0:	bfa1                	j	800046f8 <kexec+0xec>
    sz = sz1;
    800047a2:	e0843903          	ld	s2,-504(s0)
    800047a6:	bfa5                	j	8000471e <kexec+0x112>
    800047a8:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    800047aa:	8552                	mv	a0,s4
    800047ac:	c77fe0ef          	jal	80003422 <iunlockput>
  end_op();
    800047b0:	cbcff0ef          	jal	80003c6c <end_op>
  p = myproc();
    800047b4:	91afd0ef          	jal	800018ce <myproc>
    800047b8:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800047ba:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    800047be:	6985                	lui	s3,0x1
    800047c0:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    800047c2:	99ca                	add	s3,s3,s2
    800047c4:	77fd                	lui	a5,0xfffff
    800047c6:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    800047ca:	4691                	li	a3,4
    800047cc:	6609                	lui	a2,0x2
    800047ce:	964e                	add	a2,a2,s3
    800047d0:	85ce                	mv	a1,s3
    800047d2:	855a                	mv	a0,s6
    800047d4:	ab5fc0ef          	jal	80001288 <uvmalloc>
    800047d8:	892a                	mv	s2,a0
    800047da:	e0a43423          	sd	a0,-504(s0)
    800047de:	e519                	bnez	a0,800047ec <kexec+0x1e0>
  if(pagetable)
    800047e0:	e1343423          	sd	s3,-504(s0)
    800047e4:	4a01                	li	s4,0
    800047e6:	aab1                	j	80004942 <kexec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800047e8:	4901                	li	s2,0
    800047ea:	b7c1                	j	800047aa <kexec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    800047ec:	75f9                	lui	a1,0xffffe
    800047ee:	95aa                	add	a1,a1,a0
    800047f0:	855a                	mv	a0,s6
    800047f2:	c6dfc0ef          	jal	8000145e <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    800047f6:	7bfd                	lui	s7,0xfffff
    800047f8:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    800047fa:	e0043783          	ld	a5,-512(s0)
    800047fe:	6388                	ld	a0,0(a5)
    80004800:	cd39                	beqz	a0,8000485e <kexec+0x252>
    80004802:	e9040993          	addi	s3,s0,-368
    80004806:	f9040c13          	addi	s8,s0,-112
    8000480a:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    8000480c:	e06fc0ef          	jal	80000e12 <strlen>
    80004810:	0015079b          	addiw	a5,a0,1
    80004814:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004818:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    8000481c:	11796e63          	bltu	s2,s7,80004938 <kexec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004820:	e0043d03          	ld	s10,-512(s0)
    80004824:	000d3a03          	ld	s4,0(s10)
    80004828:	8552                	mv	a0,s4
    8000482a:	de8fc0ef          	jal	80000e12 <strlen>
    8000482e:	0015069b          	addiw	a3,a0,1
    80004832:	8652                	mv	a2,s4
    80004834:	85ca                	mv	a1,s2
    80004836:	855a                	mv	a0,s6
    80004838:	dabfc0ef          	jal	800015e2 <copyout>
    8000483c:	10054063          	bltz	a0,8000493c <kexec+0x330>
    ustack[argc] = sp;
    80004840:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004844:	0485                	addi	s1,s1,1
    80004846:	008d0793          	addi	a5,s10,8
    8000484a:	e0f43023          	sd	a5,-512(s0)
    8000484e:	008d3503          	ld	a0,8(s10)
    80004852:	c909                	beqz	a0,80004864 <kexec+0x258>
    if(argc >= MAXARG)
    80004854:	09a1                	addi	s3,s3,8
    80004856:	fb899be3          	bne	s3,s8,8000480c <kexec+0x200>
  ip = 0;
    8000485a:	4a01                	li	s4,0
    8000485c:	a0dd                	j	80004942 <kexec+0x336>
  sp = sz;
    8000485e:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80004862:	4481                	li	s1,0
  ustack[argc] = 0;
    80004864:	00349793          	slli	a5,s1,0x3
    80004868:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdbaa8>
    8000486c:	97a2                	add	a5,a5,s0
    8000486e:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004872:	00148693          	addi	a3,s1,1
    80004876:	068e                	slli	a3,a3,0x3
    80004878:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000487c:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004880:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80004884:	f5796ee3          	bltu	s2,s7,800047e0 <kexec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004888:	e9040613          	addi	a2,s0,-368
    8000488c:	85ca                	mv	a1,s2
    8000488e:	855a                	mv	a0,s6
    80004890:	d53fc0ef          	jal	800015e2 <copyout>
    80004894:	0e054263          	bltz	a0,80004978 <kexec+0x36c>
  p->trapframe->a1 = sp;
    80004898:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    8000489c:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800048a0:	df843783          	ld	a5,-520(s0)
    800048a4:	0007c703          	lbu	a4,0(a5)
    800048a8:	cf11                	beqz	a4,800048c4 <kexec+0x2b8>
    800048aa:	0785                	addi	a5,a5,1
    if(*s == '/')
    800048ac:	02f00693          	li	a3,47
    800048b0:	a039                	j	800048be <kexec+0x2b2>
      last = s+1;
    800048b2:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    800048b6:	0785                	addi	a5,a5,1
    800048b8:	fff7c703          	lbu	a4,-1(a5)
    800048bc:	c701                	beqz	a4,800048c4 <kexec+0x2b8>
    if(*s == '/')
    800048be:	fed71ce3          	bne	a4,a3,800048b6 <kexec+0x2aa>
    800048c2:	bfc5                	j	800048b2 <kexec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    800048c4:	4641                	li	a2,16
    800048c6:	df843583          	ld	a1,-520(s0)
    800048ca:	158a8513          	addi	a0,s5,344
    800048ce:	d12fc0ef          	jal	80000de0 <safestrcpy>
  oldpagetable = p->pagetable;
    800048d2:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800048d6:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    800048da:	e0843783          	ld	a5,-504(s0)
    800048de:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    800048e2:	058ab783          	ld	a5,88(s5)
    800048e6:	e6843703          	ld	a4,-408(s0)
    800048ea:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800048ec:	058ab783          	ld	a5,88(s5)
    800048f0:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800048f4:	85e6                	mv	a1,s9
    800048f6:	962fd0ef          	jal	80001a58 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800048fa:	0004851b          	sext.w	a0,s1
    800048fe:	79be                	ld	s3,488(sp)
    80004900:	7a1e                	ld	s4,480(sp)
    80004902:	6afe                	ld	s5,472(sp)
    80004904:	6b5e                	ld	s6,464(sp)
    80004906:	6bbe                	ld	s7,456(sp)
    80004908:	6c1e                	ld	s8,448(sp)
    8000490a:	7cfa                	ld	s9,440(sp)
    8000490c:	7d5a                	ld	s10,432(sp)
    8000490e:	b3b5                	j	8000467a <kexec+0x6e>
    80004910:	e1243423          	sd	s2,-504(s0)
    80004914:	7dba                	ld	s11,424(sp)
    80004916:	a035                	j	80004942 <kexec+0x336>
    80004918:	e1243423          	sd	s2,-504(s0)
    8000491c:	7dba                	ld	s11,424(sp)
    8000491e:	a015                	j	80004942 <kexec+0x336>
    80004920:	e1243423          	sd	s2,-504(s0)
    80004924:	7dba                	ld	s11,424(sp)
    80004926:	a831                	j	80004942 <kexec+0x336>
    80004928:	e1243423          	sd	s2,-504(s0)
    8000492c:	7dba                	ld	s11,424(sp)
    8000492e:	a811                	j	80004942 <kexec+0x336>
    80004930:	e1243423          	sd	s2,-504(s0)
    80004934:	7dba                	ld	s11,424(sp)
    80004936:	a031                	j	80004942 <kexec+0x336>
  ip = 0;
    80004938:	4a01                	li	s4,0
    8000493a:	a021                	j	80004942 <kexec+0x336>
    8000493c:	4a01                	li	s4,0
  if(pagetable)
    8000493e:	a011                	j	80004942 <kexec+0x336>
    80004940:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80004942:	e0843583          	ld	a1,-504(s0)
    80004946:	855a                	mv	a0,s6
    80004948:	910fd0ef          	jal	80001a58 <proc_freepagetable>
  return -1;
    8000494c:	557d                	li	a0,-1
  if(ip){
    8000494e:	000a1b63          	bnez	s4,80004964 <kexec+0x358>
    80004952:	79be                	ld	s3,488(sp)
    80004954:	7a1e                	ld	s4,480(sp)
    80004956:	6afe                	ld	s5,472(sp)
    80004958:	6b5e                	ld	s6,464(sp)
    8000495a:	6bbe                	ld	s7,456(sp)
    8000495c:	6c1e                	ld	s8,448(sp)
    8000495e:	7cfa                	ld	s9,440(sp)
    80004960:	7d5a                	ld	s10,432(sp)
    80004962:	bb21                	j	8000467a <kexec+0x6e>
    80004964:	79be                	ld	s3,488(sp)
    80004966:	6afe                	ld	s5,472(sp)
    80004968:	6b5e                	ld	s6,464(sp)
    8000496a:	6bbe                	ld	s7,456(sp)
    8000496c:	6c1e                	ld	s8,448(sp)
    8000496e:	7cfa                	ld	s9,440(sp)
    80004970:	7d5a                	ld	s10,432(sp)
    80004972:	b9ed                	j	8000466c <kexec+0x60>
    80004974:	6b5e                	ld	s6,464(sp)
    80004976:	b9dd                	j	8000466c <kexec+0x60>
  sz = sz1;
    80004978:	e0843983          	ld	s3,-504(s0)
    8000497c:	b595                	j	800047e0 <kexec+0x1d4>

000000008000497e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000497e:	7179                	addi	sp,sp,-48
    80004980:	f406                	sd	ra,40(sp)
    80004982:	f022                	sd	s0,32(sp)
    80004984:	ec26                	sd	s1,24(sp)
    80004986:	e84a                	sd	s2,16(sp)
    80004988:	1800                	addi	s0,sp,48
    8000498a:	892e                	mv	s2,a1
    8000498c:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    8000498e:	fdc40593          	addi	a1,s0,-36
    80004992:	e39fd0ef          	jal	800027ca <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004996:	fdc42703          	lw	a4,-36(s0)
    8000499a:	47bd                	li	a5,15
    8000499c:	02e7e963          	bltu	a5,a4,800049ce <argfd+0x50>
    800049a0:	f2ffc0ef          	jal	800018ce <myproc>
    800049a4:	fdc42703          	lw	a4,-36(s0)
    800049a8:	01a70793          	addi	a5,a4,26
    800049ac:	078e                	slli	a5,a5,0x3
    800049ae:	953e                	add	a0,a0,a5
    800049b0:	611c                	ld	a5,0(a0)
    800049b2:	c385                	beqz	a5,800049d2 <argfd+0x54>
    return -1;
  if(pfd)
    800049b4:	00090463          	beqz	s2,800049bc <argfd+0x3e>
    *pfd = fd;
    800049b8:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800049bc:	4501                	li	a0,0
  if(pf)
    800049be:	c091                	beqz	s1,800049c2 <argfd+0x44>
    *pf = f;
    800049c0:	e09c                	sd	a5,0(s1)
}
    800049c2:	70a2                	ld	ra,40(sp)
    800049c4:	7402                	ld	s0,32(sp)
    800049c6:	64e2                	ld	s1,24(sp)
    800049c8:	6942                	ld	s2,16(sp)
    800049ca:	6145                	addi	sp,sp,48
    800049cc:	8082                	ret
    return -1;
    800049ce:	557d                	li	a0,-1
    800049d0:	bfcd                	j	800049c2 <argfd+0x44>
    800049d2:	557d                	li	a0,-1
    800049d4:	b7fd                	j	800049c2 <argfd+0x44>

00000000800049d6 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800049d6:	1101                	addi	sp,sp,-32
    800049d8:	ec06                	sd	ra,24(sp)
    800049da:	e822                	sd	s0,16(sp)
    800049dc:	e426                	sd	s1,8(sp)
    800049de:	1000                	addi	s0,sp,32
    800049e0:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800049e2:	eedfc0ef          	jal	800018ce <myproc>
    800049e6:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800049e8:	0d050793          	addi	a5,a0,208
    800049ec:	4501                	li	a0,0
    800049ee:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800049f0:	6398                	ld	a4,0(a5)
    800049f2:	cb19                	beqz	a4,80004a08 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    800049f4:	2505                	addiw	a0,a0,1
    800049f6:	07a1                	addi	a5,a5,8
    800049f8:	fed51ce3          	bne	a0,a3,800049f0 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800049fc:	557d                	li	a0,-1
}
    800049fe:	60e2                	ld	ra,24(sp)
    80004a00:	6442                	ld	s0,16(sp)
    80004a02:	64a2                	ld	s1,8(sp)
    80004a04:	6105                	addi	sp,sp,32
    80004a06:	8082                	ret
      p->ofile[fd] = f;
    80004a08:	01a50793          	addi	a5,a0,26
    80004a0c:	078e                	slli	a5,a5,0x3
    80004a0e:	963e                	add	a2,a2,a5
    80004a10:	e204                	sd	s1,0(a2)
      return fd;
    80004a12:	b7f5                	j	800049fe <fdalloc+0x28>

0000000080004a14 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004a14:	715d                	addi	sp,sp,-80
    80004a16:	e486                	sd	ra,72(sp)
    80004a18:	e0a2                	sd	s0,64(sp)
    80004a1a:	fc26                	sd	s1,56(sp)
    80004a1c:	f84a                	sd	s2,48(sp)
    80004a1e:	f44e                	sd	s3,40(sp)
    80004a20:	ec56                	sd	s5,24(sp)
    80004a22:	e85a                	sd	s6,16(sp)
    80004a24:	0880                	addi	s0,sp,80
    80004a26:	8b2e                	mv	s6,a1
    80004a28:	89b2                	mv	s3,a2
    80004a2a:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004a2c:	fb040593          	addi	a1,s0,-80
    80004a30:	818ff0ef          	jal	80003a48 <nameiparent>
    80004a34:	84aa                	mv	s1,a0
    80004a36:	10050a63          	beqz	a0,80004b4a <create+0x136>
    return 0;

  ilock(dp);
    80004a3a:	fdefe0ef          	jal	80003218 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004a3e:	4601                	li	a2,0
    80004a40:	fb040593          	addi	a1,s0,-80
    80004a44:	8526                	mv	a0,s1
    80004a46:	d83fe0ef          	jal	800037c8 <dirlookup>
    80004a4a:	8aaa                	mv	s5,a0
    80004a4c:	c129                	beqz	a0,80004a8e <create+0x7a>
    iunlockput(dp);
    80004a4e:	8526                	mv	a0,s1
    80004a50:	9d3fe0ef          	jal	80003422 <iunlockput>
    ilock(ip);
    80004a54:	8556                	mv	a0,s5
    80004a56:	fc2fe0ef          	jal	80003218 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004a5a:	4789                	li	a5,2
    80004a5c:	02fb1463          	bne	s6,a5,80004a84 <create+0x70>
    80004a60:	044ad783          	lhu	a5,68(s5)
    80004a64:	37f9                	addiw	a5,a5,-2
    80004a66:	17c2                	slli	a5,a5,0x30
    80004a68:	93c1                	srli	a5,a5,0x30
    80004a6a:	4705                	li	a4,1
    80004a6c:	00f76c63          	bltu	a4,a5,80004a84 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004a70:	8556                	mv	a0,s5
    80004a72:	60a6                	ld	ra,72(sp)
    80004a74:	6406                	ld	s0,64(sp)
    80004a76:	74e2                	ld	s1,56(sp)
    80004a78:	7942                	ld	s2,48(sp)
    80004a7a:	79a2                	ld	s3,40(sp)
    80004a7c:	6ae2                	ld	s5,24(sp)
    80004a7e:	6b42                	ld	s6,16(sp)
    80004a80:	6161                	addi	sp,sp,80
    80004a82:	8082                	ret
    iunlockput(ip);
    80004a84:	8556                	mv	a0,s5
    80004a86:	99dfe0ef          	jal	80003422 <iunlockput>
    return 0;
    80004a8a:	4a81                	li	s5,0
    80004a8c:	b7d5                	j	80004a70 <create+0x5c>
    80004a8e:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80004a90:	85da                	mv	a1,s6
    80004a92:	4088                	lw	a0,0(s1)
    80004a94:	e14fe0ef          	jal	800030a8 <ialloc>
    80004a98:	8a2a                	mv	s4,a0
    80004a9a:	cd15                	beqz	a0,80004ad6 <create+0xc2>
  ilock(ip);
    80004a9c:	f7cfe0ef          	jal	80003218 <ilock>
  ip->major = major;
    80004aa0:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004aa4:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004aa8:	4905                	li	s2,1
    80004aaa:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004aae:	8552                	mv	a0,s4
    80004ab0:	eb4fe0ef          	jal	80003164 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004ab4:	032b0763          	beq	s6,s2,80004ae2 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004ab8:	004a2603          	lw	a2,4(s4)
    80004abc:	fb040593          	addi	a1,s0,-80
    80004ac0:	8526                	mv	a0,s1
    80004ac2:	ed3fe0ef          	jal	80003994 <dirlink>
    80004ac6:	06054563          	bltz	a0,80004b30 <create+0x11c>
  iunlockput(dp);
    80004aca:	8526                	mv	a0,s1
    80004acc:	957fe0ef          	jal	80003422 <iunlockput>
  return ip;
    80004ad0:	8ad2                	mv	s5,s4
    80004ad2:	7a02                	ld	s4,32(sp)
    80004ad4:	bf71                	j	80004a70 <create+0x5c>
    iunlockput(dp);
    80004ad6:	8526                	mv	a0,s1
    80004ad8:	94bfe0ef          	jal	80003422 <iunlockput>
    return 0;
    80004adc:	8ad2                	mv	s5,s4
    80004ade:	7a02                	ld	s4,32(sp)
    80004ae0:	bf41                	j	80004a70 <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004ae2:	004a2603          	lw	a2,4(s4)
    80004ae6:	00003597          	auipc	a1,0x3
    80004aea:	ada58593          	addi	a1,a1,-1318 # 800075c0 <etext+0x5c0>
    80004aee:	8552                	mv	a0,s4
    80004af0:	ea5fe0ef          	jal	80003994 <dirlink>
    80004af4:	02054e63          	bltz	a0,80004b30 <create+0x11c>
    80004af8:	40d0                	lw	a2,4(s1)
    80004afa:	00003597          	auipc	a1,0x3
    80004afe:	ace58593          	addi	a1,a1,-1330 # 800075c8 <etext+0x5c8>
    80004b02:	8552                	mv	a0,s4
    80004b04:	e91fe0ef          	jal	80003994 <dirlink>
    80004b08:	02054463          	bltz	a0,80004b30 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004b0c:	004a2603          	lw	a2,4(s4)
    80004b10:	fb040593          	addi	a1,s0,-80
    80004b14:	8526                	mv	a0,s1
    80004b16:	e7ffe0ef          	jal	80003994 <dirlink>
    80004b1a:	00054b63          	bltz	a0,80004b30 <create+0x11c>
    dp->nlink++;  // for ".."
    80004b1e:	04a4d783          	lhu	a5,74(s1)
    80004b22:	2785                	addiw	a5,a5,1
    80004b24:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004b28:	8526                	mv	a0,s1
    80004b2a:	e3afe0ef          	jal	80003164 <iupdate>
    80004b2e:	bf71                	j	80004aca <create+0xb6>
  ip->nlink = 0;
    80004b30:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004b34:	8552                	mv	a0,s4
    80004b36:	e2efe0ef          	jal	80003164 <iupdate>
  iunlockput(ip);
    80004b3a:	8552                	mv	a0,s4
    80004b3c:	8e7fe0ef          	jal	80003422 <iunlockput>
  iunlockput(dp);
    80004b40:	8526                	mv	a0,s1
    80004b42:	8e1fe0ef          	jal	80003422 <iunlockput>
  return 0;
    80004b46:	7a02                	ld	s4,32(sp)
    80004b48:	b725                	j	80004a70 <create+0x5c>
    return 0;
    80004b4a:	8aaa                	mv	s5,a0
    80004b4c:	b715                	j	80004a70 <create+0x5c>

0000000080004b4e <sys_dup>:
{
    80004b4e:	7179                	addi	sp,sp,-48
    80004b50:	f406                	sd	ra,40(sp)
    80004b52:	f022                	sd	s0,32(sp)
    80004b54:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004b56:	fd840613          	addi	a2,s0,-40
    80004b5a:	4581                	li	a1,0
    80004b5c:	4501                	li	a0,0
    80004b5e:	e21ff0ef          	jal	8000497e <argfd>
    return -1;
    80004b62:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004b64:	02054363          	bltz	a0,80004b8a <sys_dup+0x3c>
    80004b68:	ec26                	sd	s1,24(sp)
    80004b6a:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004b6c:	fd843903          	ld	s2,-40(s0)
    80004b70:	854a                	mv	a0,s2
    80004b72:	e65ff0ef          	jal	800049d6 <fdalloc>
    80004b76:	84aa                	mv	s1,a0
    return -1;
    80004b78:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004b7a:	00054d63          	bltz	a0,80004b94 <sys_dup+0x46>
  filedup(f);
    80004b7e:	854a                	mv	a0,s2
    80004b80:	c48ff0ef          	jal	80003fc8 <filedup>
  return fd;
    80004b84:	87a6                	mv	a5,s1
    80004b86:	64e2                	ld	s1,24(sp)
    80004b88:	6942                	ld	s2,16(sp)
}
    80004b8a:	853e                	mv	a0,a5
    80004b8c:	70a2                	ld	ra,40(sp)
    80004b8e:	7402                	ld	s0,32(sp)
    80004b90:	6145                	addi	sp,sp,48
    80004b92:	8082                	ret
    80004b94:	64e2                	ld	s1,24(sp)
    80004b96:	6942                	ld	s2,16(sp)
    80004b98:	bfcd                	j	80004b8a <sys_dup+0x3c>

0000000080004b9a <sys_read>:
{
    80004b9a:	7179                	addi	sp,sp,-48
    80004b9c:	f406                	sd	ra,40(sp)
    80004b9e:	f022                	sd	s0,32(sp)
    80004ba0:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004ba2:	fd840593          	addi	a1,s0,-40
    80004ba6:	4505                	li	a0,1
    80004ba8:	c3ffd0ef          	jal	800027e6 <argaddr>
  argint(2, &n);
    80004bac:	fe440593          	addi	a1,s0,-28
    80004bb0:	4509                	li	a0,2
    80004bb2:	c19fd0ef          	jal	800027ca <argint>
  if(argfd(0, 0, &f) < 0)
    80004bb6:	fe840613          	addi	a2,s0,-24
    80004bba:	4581                	li	a1,0
    80004bbc:	4501                	li	a0,0
    80004bbe:	dc1ff0ef          	jal	8000497e <argfd>
    80004bc2:	87aa                	mv	a5,a0
    return -1;
    80004bc4:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004bc6:	0007ca63          	bltz	a5,80004bda <sys_read+0x40>
  return fileread(f, p, n);
    80004bca:	fe442603          	lw	a2,-28(s0)
    80004bce:	fd843583          	ld	a1,-40(s0)
    80004bd2:	fe843503          	ld	a0,-24(s0)
    80004bd6:	d58ff0ef          	jal	8000412e <fileread>
}
    80004bda:	70a2                	ld	ra,40(sp)
    80004bdc:	7402                	ld	s0,32(sp)
    80004bde:	6145                	addi	sp,sp,48
    80004be0:	8082                	ret

0000000080004be2 <sys_write>:
{
    80004be2:	7179                	addi	sp,sp,-48
    80004be4:	f406                	sd	ra,40(sp)
    80004be6:	f022                	sd	s0,32(sp)
    80004be8:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004bea:	fd840593          	addi	a1,s0,-40
    80004bee:	4505                	li	a0,1
    80004bf0:	bf7fd0ef          	jal	800027e6 <argaddr>
  argint(2, &n);
    80004bf4:	fe440593          	addi	a1,s0,-28
    80004bf8:	4509                	li	a0,2
    80004bfa:	bd1fd0ef          	jal	800027ca <argint>
  if(argfd(0, 0, &f) < 0)
    80004bfe:	fe840613          	addi	a2,s0,-24
    80004c02:	4581                	li	a1,0
    80004c04:	4501                	li	a0,0
    80004c06:	d79ff0ef          	jal	8000497e <argfd>
    80004c0a:	87aa                	mv	a5,a0
    return -1;
    80004c0c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004c0e:	0007ca63          	bltz	a5,80004c22 <sys_write+0x40>
  return filewrite(f, p, n);
    80004c12:	fe442603          	lw	a2,-28(s0)
    80004c16:	fd843583          	ld	a1,-40(s0)
    80004c1a:	fe843503          	ld	a0,-24(s0)
    80004c1e:	dceff0ef          	jal	800041ec <filewrite>
}
    80004c22:	70a2                	ld	ra,40(sp)
    80004c24:	7402                	ld	s0,32(sp)
    80004c26:	6145                	addi	sp,sp,48
    80004c28:	8082                	ret

0000000080004c2a <sys_close>:
{
    80004c2a:	1101                	addi	sp,sp,-32
    80004c2c:	ec06                	sd	ra,24(sp)
    80004c2e:	e822                	sd	s0,16(sp)
    80004c30:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004c32:	fe040613          	addi	a2,s0,-32
    80004c36:	fec40593          	addi	a1,s0,-20
    80004c3a:	4501                	li	a0,0
    80004c3c:	d43ff0ef          	jal	8000497e <argfd>
    return -1;
    80004c40:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004c42:	02054063          	bltz	a0,80004c62 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004c46:	c89fc0ef          	jal	800018ce <myproc>
    80004c4a:	fec42783          	lw	a5,-20(s0)
    80004c4e:	07e9                	addi	a5,a5,26
    80004c50:	078e                	slli	a5,a5,0x3
    80004c52:	953e                	add	a0,a0,a5
    80004c54:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004c58:	fe043503          	ld	a0,-32(s0)
    80004c5c:	bb2ff0ef          	jal	8000400e <fileclose>
  return 0;
    80004c60:	4781                	li	a5,0
}
    80004c62:	853e                	mv	a0,a5
    80004c64:	60e2                	ld	ra,24(sp)
    80004c66:	6442                	ld	s0,16(sp)
    80004c68:	6105                	addi	sp,sp,32
    80004c6a:	8082                	ret

0000000080004c6c <sys_fstat>:
{
    80004c6c:	1101                	addi	sp,sp,-32
    80004c6e:	ec06                	sd	ra,24(sp)
    80004c70:	e822                	sd	s0,16(sp)
    80004c72:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004c74:	fe040593          	addi	a1,s0,-32
    80004c78:	4505                	li	a0,1
    80004c7a:	b6dfd0ef          	jal	800027e6 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004c7e:	fe840613          	addi	a2,s0,-24
    80004c82:	4581                	li	a1,0
    80004c84:	4501                	li	a0,0
    80004c86:	cf9ff0ef          	jal	8000497e <argfd>
    80004c8a:	87aa                	mv	a5,a0
    return -1;
    80004c8c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004c8e:	0007c863          	bltz	a5,80004c9e <sys_fstat+0x32>
  return filestat(f, st);
    80004c92:	fe043583          	ld	a1,-32(s0)
    80004c96:	fe843503          	ld	a0,-24(s0)
    80004c9a:	c36ff0ef          	jal	800040d0 <filestat>
}
    80004c9e:	60e2                	ld	ra,24(sp)
    80004ca0:	6442                	ld	s0,16(sp)
    80004ca2:	6105                	addi	sp,sp,32
    80004ca4:	8082                	ret

0000000080004ca6 <sys_link>:
{
    80004ca6:	7169                	addi	sp,sp,-304
    80004ca8:	f606                	sd	ra,296(sp)
    80004caa:	f222                	sd	s0,288(sp)
    80004cac:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004cae:	08000613          	li	a2,128
    80004cb2:	ed040593          	addi	a1,s0,-304
    80004cb6:	4501                	li	a0,0
    80004cb8:	b4bfd0ef          	jal	80002802 <argstr>
    return -1;
    80004cbc:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004cbe:	0c054e63          	bltz	a0,80004d9a <sys_link+0xf4>
    80004cc2:	08000613          	li	a2,128
    80004cc6:	f5040593          	addi	a1,s0,-176
    80004cca:	4505                	li	a0,1
    80004ccc:	b37fd0ef          	jal	80002802 <argstr>
    return -1;
    80004cd0:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004cd2:	0c054463          	bltz	a0,80004d9a <sys_link+0xf4>
    80004cd6:	ee26                	sd	s1,280(sp)
  begin_op();
    80004cd8:	f2bfe0ef          	jal	80003c02 <begin_op>
  if((ip = namei(old)) == 0){
    80004cdc:	ed040513          	addi	a0,s0,-304
    80004ce0:	d4ffe0ef          	jal	80003a2e <namei>
    80004ce4:	84aa                	mv	s1,a0
    80004ce6:	c53d                	beqz	a0,80004d54 <sys_link+0xae>
  ilock(ip);
    80004ce8:	d30fe0ef          	jal	80003218 <ilock>
  if(ip->type == T_DIR){
    80004cec:	04449703          	lh	a4,68(s1)
    80004cf0:	4785                	li	a5,1
    80004cf2:	06f70663          	beq	a4,a5,80004d5e <sys_link+0xb8>
    80004cf6:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004cf8:	04a4d783          	lhu	a5,74(s1)
    80004cfc:	2785                	addiw	a5,a5,1
    80004cfe:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004d02:	8526                	mv	a0,s1
    80004d04:	c60fe0ef          	jal	80003164 <iupdate>
  iunlock(ip);
    80004d08:	8526                	mv	a0,s1
    80004d0a:	dbcfe0ef          	jal	800032c6 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004d0e:	fd040593          	addi	a1,s0,-48
    80004d12:	f5040513          	addi	a0,s0,-176
    80004d16:	d33fe0ef          	jal	80003a48 <nameiparent>
    80004d1a:	892a                	mv	s2,a0
    80004d1c:	cd21                	beqz	a0,80004d74 <sys_link+0xce>
  ilock(dp);
    80004d1e:	cfafe0ef          	jal	80003218 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004d22:	00092703          	lw	a4,0(s2)
    80004d26:	409c                	lw	a5,0(s1)
    80004d28:	04f71363          	bne	a4,a5,80004d6e <sys_link+0xc8>
    80004d2c:	40d0                	lw	a2,4(s1)
    80004d2e:	fd040593          	addi	a1,s0,-48
    80004d32:	854a                	mv	a0,s2
    80004d34:	c61fe0ef          	jal	80003994 <dirlink>
    80004d38:	02054b63          	bltz	a0,80004d6e <sys_link+0xc8>
  iunlockput(dp);
    80004d3c:	854a                	mv	a0,s2
    80004d3e:	ee4fe0ef          	jal	80003422 <iunlockput>
  iput(ip);
    80004d42:	8526                	mv	a0,s1
    80004d44:	e56fe0ef          	jal	8000339a <iput>
  end_op();
    80004d48:	f25fe0ef          	jal	80003c6c <end_op>
  return 0;
    80004d4c:	4781                	li	a5,0
    80004d4e:	64f2                	ld	s1,280(sp)
    80004d50:	6952                	ld	s2,272(sp)
    80004d52:	a0a1                	j	80004d9a <sys_link+0xf4>
    end_op();
    80004d54:	f19fe0ef          	jal	80003c6c <end_op>
    return -1;
    80004d58:	57fd                	li	a5,-1
    80004d5a:	64f2                	ld	s1,280(sp)
    80004d5c:	a83d                	j	80004d9a <sys_link+0xf4>
    iunlockput(ip);
    80004d5e:	8526                	mv	a0,s1
    80004d60:	ec2fe0ef          	jal	80003422 <iunlockput>
    end_op();
    80004d64:	f09fe0ef          	jal	80003c6c <end_op>
    return -1;
    80004d68:	57fd                	li	a5,-1
    80004d6a:	64f2                	ld	s1,280(sp)
    80004d6c:	a03d                	j	80004d9a <sys_link+0xf4>
    iunlockput(dp);
    80004d6e:	854a                	mv	a0,s2
    80004d70:	eb2fe0ef          	jal	80003422 <iunlockput>
  ilock(ip);
    80004d74:	8526                	mv	a0,s1
    80004d76:	ca2fe0ef          	jal	80003218 <ilock>
  ip->nlink--;
    80004d7a:	04a4d783          	lhu	a5,74(s1)
    80004d7e:	37fd                	addiw	a5,a5,-1
    80004d80:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004d84:	8526                	mv	a0,s1
    80004d86:	bdefe0ef          	jal	80003164 <iupdate>
  iunlockput(ip);
    80004d8a:	8526                	mv	a0,s1
    80004d8c:	e96fe0ef          	jal	80003422 <iunlockput>
  end_op();
    80004d90:	eddfe0ef          	jal	80003c6c <end_op>
  return -1;
    80004d94:	57fd                	li	a5,-1
    80004d96:	64f2                	ld	s1,280(sp)
    80004d98:	6952                	ld	s2,272(sp)
}
    80004d9a:	853e                	mv	a0,a5
    80004d9c:	70b2                	ld	ra,296(sp)
    80004d9e:	7412                	ld	s0,288(sp)
    80004da0:	6155                	addi	sp,sp,304
    80004da2:	8082                	ret

0000000080004da4 <sys_unlink>:
{
    80004da4:	7151                	addi	sp,sp,-240
    80004da6:	f586                	sd	ra,232(sp)
    80004da8:	f1a2                	sd	s0,224(sp)
    80004daa:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004dac:	08000613          	li	a2,128
    80004db0:	f3040593          	addi	a1,s0,-208
    80004db4:	4501                	li	a0,0
    80004db6:	a4dfd0ef          	jal	80002802 <argstr>
    80004dba:	16054063          	bltz	a0,80004f1a <sys_unlink+0x176>
    80004dbe:	eda6                	sd	s1,216(sp)
  begin_op();
    80004dc0:	e43fe0ef          	jal	80003c02 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004dc4:	fb040593          	addi	a1,s0,-80
    80004dc8:	f3040513          	addi	a0,s0,-208
    80004dcc:	c7dfe0ef          	jal	80003a48 <nameiparent>
    80004dd0:	84aa                	mv	s1,a0
    80004dd2:	c945                	beqz	a0,80004e82 <sys_unlink+0xde>
  ilock(dp);
    80004dd4:	c44fe0ef          	jal	80003218 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004dd8:	00002597          	auipc	a1,0x2
    80004ddc:	7e858593          	addi	a1,a1,2024 # 800075c0 <etext+0x5c0>
    80004de0:	fb040513          	addi	a0,s0,-80
    80004de4:	9cffe0ef          	jal	800037b2 <namecmp>
    80004de8:	10050e63          	beqz	a0,80004f04 <sys_unlink+0x160>
    80004dec:	00002597          	auipc	a1,0x2
    80004df0:	7dc58593          	addi	a1,a1,2012 # 800075c8 <etext+0x5c8>
    80004df4:	fb040513          	addi	a0,s0,-80
    80004df8:	9bbfe0ef          	jal	800037b2 <namecmp>
    80004dfc:	10050463          	beqz	a0,80004f04 <sys_unlink+0x160>
    80004e00:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004e02:	f2c40613          	addi	a2,s0,-212
    80004e06:	fb040593          	addi	a1,s0,-80
    80004e0a:	8526                	mv	a0,s1
    80004e0c:	9bdfe0ef          	jal	800037c8 <dirlookup>
    80004e10:	892a                	mv	s2,a0
    80004e12:	0e050863          	beqz	a0,80004f02 <sys_unlink+0x15e>
  ilock(ip);
    80004e16:	c02fe0ef          	jal	80003218 <ilock>
  if(ip->nlink < 1)
    80004e1a:	04a91783          	lh	a5,74(s2)
    80004e1e:	06f05763          	blez	a5,80004e8c <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004e22:	04491703          	lh	a4,68(s2)
    80004e26:	4785                	li	a5,1
    80004e28:	06f70963          	beq	a4,a5,80004e9a <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80004e2c:	4641                	li	a2,16
    80004e2e:	4581                	li	a1,0
    80004e30:	fc040513          	addi	a0,s0,-64
    80004e34:	e6ffb0ef          	jal	80000ca2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004e38:	4741                	li	a4,16
    80004e3a:	f2c42683          	lw	a3,-212(s0)
    80004e3e:	fc040613          	addi	a2,s0,-64
    80004e42:	4581                	li	a1,0
    80004e44:	8526                	mv	a0,s1
    80004e46:	85ffe0ef          	jal	800036a4 <writei>
    80004e4a:	47c1                	li	a5,16
    80004e4c:	08f51b63          	bne	a0,a5,80004ee2 <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    80004e50:	04491703          	lh	a4,68(s2)
    80004e54:	4785                	li	a5,1
    80004e56:	08f70d63          	beq	a4,a5,80004ef0 <sys_unlink+0x14c>
  iunlockput(dp);
    80004e5a:	8526                	mv	a0,s1
    80004e5c:	dc6fe0ef          	jal	80003422 <iunlockput>
  ip->nlink--;
    80004e60:	04a95783          	lhu	a5,74(s2)
    80004e64:	37fd                	addiw	a5,a5,-1
    80004e66:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004e6a:	854a                	mv	a0,s2
    80004e6c:	af8fe0ef          	jal	80003164 <iupdate>
  iunlockput(ip);
    80004e70:	854a                	mv	a0,s2
    80004e72:	db0fe0ef          	jal	80003422 <iunlockput>
  end_op();
    80004e76:	df7fe0ef          	jal	80003c6c <end_op>
  return 0;
    80004e7a:	4501                	li	a0,0
    80004e7c:	64ee                	ld	s1,216(sp)
    80004e7e:	694e                	ld	s2,208(sp)
    80004e80:	a849                	j	80004f12 <sys_unlink+0x16e>
    end_op();
    80004e82:	debfe0ef          	jal	80003c6c <end_op>
    return -1;
    80004e86:	557d                	li	a0,-1
    80004e88:	64ee                	ld	s1,216(sp)
    80004e8a:	a061                	j	80004f12 <sys_unlink+0x16e>
    80004e8c:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80004e8e:	00002517          	auipc	a0,0x2
    80004e92:	74250513          	addi	a0,a0,1858 # 800075d0 <etext+0x5d0>
    80004e96:	94bfb0ef          	jal	800007e0 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004e9a:	04c92703          	lw	a4,76(s2)
    80004e9e:	02000793          	li	a5,32
    80004ea2:	f8e7f5e3          	bgeu	a5,a4,80004e2c <sys_unlink+0x88>
    80004ea6:	e5ce                	sd	s3,200(sp)
    80004ea8:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004eac:	4741                	li	a4,16
    80004eae:	86ce                	mv	a3,s3
    80004eb0:	f1840613          	addi	a2,s0,-232
    80004eb4:	4581                	li	a1,0
    80004eb6:	854a                	mv	a0,s2
    80004eb8:	ef0fe0ef          	jal	800035a8 <readi>
    80004ebc:	47c1                	li	a5,16
    80004ebe:	00f51c63          	bne	a0,a5,80004ed6 <sys_unlink+0x132>
    if(de.inum != 0)
    80004ec2:	f1845783          	lhu	a5,-232(s0)
    80004ec6:	efa1                	bnez	a5,80004f1e <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004ec8:	29c1                	addiw	s3,s3,16
    80004eca:	04c92783          	lw	a5,76(s2)
    80004ece:	fcf9efe3          	bltu	s3,a5,80004eac <sys_unlink+0x108>
    80004ed2:	69ae                	ld	s3,200(sp)
    80004ed4:	bfa1                	j	80004e2c <sys_unlink+0x88>
      panic("isdirempty: readi");
    80004ed6:	00002517          	auipc	a0,0x2
    80004eda:	71250513          	addi	a0,a0,1810 # 800075e8 <etext+0x5e8>
    80004ede:	903fb0ef          	jal	800007e0 <panic>
    80004ee2:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80004ee4:	00002517          	auipc	a0,0x2
    80004ee8:	71c50513          	addi	a0,a0,1820 # 80007600 <etext+0x600>
    80004eec:	8f5fb0ef          	jal	800007e0 <panic>
    dp->nlink--;
    80004ef0:	04a4d783          	lhu	a5,74(s1)
    80004ef4:	37fd                	addiw	a5,a5,-1
    80004ef6:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004efa:	8526                	mv	a0,s1
    80004efc:	a68fe0ef          	jal	80003164 <iupdate>
    80004f00:	bfa9                	j	80004e5a <sys_unlink+0xb6>
    80004f02:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80004f04:	8526                	mv	a0,s1
    80004f06:	d1cfe0ef          	jal	80003422 <iunlockput>
  end_op();
    80004f0a:	d63fe0ef          	jal	80003c6c <end_op>
  return -1;
    80004f0e:	557d                	li	a0,-1
    80004f10:	64ee                	ld	s1,216(sp)
}
    80004f12:	70ae                	ld	ra,232(sp)
    80004f14:	740e                	ld	s0,224(sp)
    80004f16:	616d                	addi	sp,sp,240
    80004f18:	8082                	ret
    return -1;
    80004f1a:	557d                	li	a0,-1
    80004f1c:	bfdd                	j	80004f12 <sys_unlink+0x16e>
    iunlockput(ip);
    80004f1e:	854a                	mv	a0,s2
    80004f20:	d02fe0ef          	jal	80003422 <iunlockput>
    goto bad;
    80004f24:	694e                	ld	s2,208(sp)
    80004f26:	69ae                	ld	s3,200(sp)
    80004f28:	bff1                	j	80004f04 <sys_unlink+0x160>

0000000080004f2a <sys_open>:

uint64
sys_open(void)
{
    80004f2a:	7131                	addi	sp,sp,-192
    80004f2c:	fd06                	sd	ra,184(sp)
    80004f2e:	f922                	sd	s0,176(sp)
    80004f30:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80004f32:	f4c40593          	addi	a1,s0,-180
    80004f36:	4505                	li	a0,1
    80004f38:	893fd0ef          	jal	800027ca <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004f3c:	08000613          	li	a2,128
    80004f40:	f5040593          	addi	a1,s0,-176
    80004f44:	4501                	li	a0,0
    80004f46:	8bdfd0ef          	jal	80002802 <argstr>
    80004f4a:	87aa                	mv	a5,a0
    return -1;
    80004f4c:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004f4e:	0a07c263          	bltz	a5,80004ff2 <sys_open+0xc8>
    80004f52:	f526                	sd	s1,168(sp)

  begin_op();
    80004f54:	caffe0ef          	jal	80003c02 <begin_op>

  if(omode & O_CREATE){
    80004f58:	f4c42783          	lw	a5,-180(s0)
    80004f5c:	2007f793          	andi	a5,a5,512
    80004f60:	c3d5                	beqz	a5,80005004 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80004f62:	4681                	li	a3,0
    80004f64:	4601                	li	a2,0
    80004f66:	4589                	li	a1,2
    80004f68:	f5040513          	addi	a0,s0,-176
    80004f6c:	aa9ff0ef          	jal	80004a14 <create>
    80004f70:	84aa                	mv	s1,a0
    if(ip == 0){
    80004f72:	c541                	beqz	a0,80004ffa <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004f74:	04449703          	lh	a4,68(s1)
    80004f78:	478d                	li	a5,3
    80004f7a:	00f71763          	bne	a4,a5,80004f88 <sys_open+0x5e>
    80004f7e:	0464d703          	lhu	a4,70(s1)
    80004f82:	47a5                	li	a5,9
    80004f84:	0ae7ed63          	bltu	a5,a4,8000503e <sys_open+0x114>
    80004f88:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004f8a:	fe1fe0ef          	jal	80003f6a <filealloc>
    80004f8e:	892a                	mv	s2,a0
    80004f90:	c179                	beqz	a0,80005056 <sys_open+0x12c>
    80004f92:	ed4e                	sd	s3,152(sp)
    80004f94:	a43ff0ef          	jal	800049d6 <fdalloc>
    80004f98:	89aa                	mv	s3,a0
    80004f9a:	0a054a63          	bltz	a0,8000504e <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004f9e:	04449703          	lh	a4,68(s1)
    80004fa2:	478d                	li	a5,3
    80004fa4:	0cf70263          	beq	a4,a5,80005068 <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004fa8:	4789                	li	a5,2
    80004faa:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80004fae:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80004fb2:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80004fb6:	f4c42783          	lw	a5,-180(s0)
    80004fba:	0017c713          	xori	a4,a5,1
    80004fbe:	8b05                	andi	a4,a4,1
    80004fc0:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004fc4:	0037f713          	andi	a4,a5,3
    80004fc8:	00e03733          	snez	a4,a4
    80004fcc:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80004fd0:	4007f793          	andi	a5,a5,1024
    80004fd4:	c791                	beqz	a5,80004fe0 <sys_open+0xb6>
    80004fd6:	04449703          	lh	a4,68(s1)
    80004fda:	4789                	li	a5,2
    80004fdc:	08f70d63          	beq	a4,a5,80005076 <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    80004fe0:	8526                	mv	a0,s1
    80004fe2:	ae4fe0ef          	jal	800032c6 <iunlock>
  end_op();
    80004fe6:	c87fe0ef          	jal	80003c6c <end_op>

  return fd;
    80004fea:	854e                	mv	a0,s3
    80004fec:	74aa                	ld	s1,168(sp)
    80004fee:	790a                	ld	s2,160(sp)
    80004ff0:	69ea                	ld	s3,152(sp)
}
    80004ff2:	70ea                	ld	ra,184(sp)
    80004ff4:	744a                	ld	s0,176(sp)
    80004ff6:	6129                	addi	sp,sp,192
    80004ff8:	8082                	ret
      end_op();
    80004ffa:	c73fe0ef          	jal	80003c6c <end_op>
      return -1;
    80004ffe:	557d                	li	a0,-1
    80005000:	74aa                	ld	s1,168(sp)
    80005002:	bfc5                	j	80004ff2 <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    80005004:	f5040513          	addi	a0,s0,-176
    80005008:	a27fe0ef          	jal	80003a2e <namei>
    8000500c:	84aa                	mv	s1,a0
    8000500e:	c11d                	beqz	a0,80005034 <sys_open+0x10a>
    ilock(ip);
    80005010:	a08fe0ef          	jal	80003218 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005014:	04449703          	lh	a4,68(s1)
    80005018:	4785                	li	a5,1
    8000501a:	f4f71de3          	bne	a4,a5,80004f74 <sys_open+0x4a>
    8000501e:	f4c42783          	lw	a5,-180(s0)
    80005022:	d3bd                	beqz	a5,80004f88 <sys_open+0x5e>
      iunlockput(ip);
    80005024:	8526                	mv	a0,s1
    80005026:	bfcfe0ef          	jal	80003422 <iunlockput>
      end_op();
    8000502a:	c43fe0ef          	jal	80003c6c <end_op>
      return -1;
    8000502e:	557d                	li	a0,-1
    80005030:	74aa                	ld	s1,168(sp)
    80005032:	b7c1                	j	80004ff2 <sys_open+0xc8>
      end_op();
    80005034:	c39fe0ef          	jal	80003c6c <end_op>
      return -1;
    80005038:	557d                	li	a0,-1
    8000503a:	74aa                	ld	s1,168(sp)
    8000503c:	bf5d                	j	80004ff2 <sys_open+0xc8>
    iunlockput(ip);
    8000503e:	8526                	mv	a0,s1
    80005040:	be2fe0ef          	jal	80003422 <iunlockput>
    end_op();
    80005044:	c29fe0ef          	jal	80003c6c <end_op>
    return -1;
    80005048:	557d                	li	a0,-1
    8000504a:	74aa                	ld	s1,168(sp)
    8000504c:	b75d                	j	80004ff2 <sys_open+0xc8>
      fileclose(f);
    8000504e:	854a                	mv	a0,s2
    80005050:	fbffe0ef          	jal	8000400e <fileclose>
    80005054:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005056:	8526                	mv	a0,s1
    80005058:	bcafe0ef          	jal	80003422 <iunlockput>
    end_op();
    8000505c:	c11fe0ef          	jal	80003c6c <end_op>
    return -1;
    80005060:	557d                	li	a0,-1
    80005062:	74aa                	ld	s1,168(sp)
    80005064:	790a                	ld	s2,160(sp)
    80005066:	b771                	j	80004ff2 <sys_open+0xc8>
    f->type = FD_DEVICE;
    80005068:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    8000506c:	04649783          	lh	a5,70(s1)
    80005070:	02f91223          	sh	a5,36(s2)
    80005074:	bf3d                	j	80004fb2 <sys_open+0x88>
    itrunc(ip);
    80005076:	8526                	mv	a0,s1
    80005078:	a8efe0ef          	jal	80003306 <itrunc>
    8000507c:	b795                	j	80004fe0 <sys_open+0xb6>

000000008000507e <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000507e:	7175                	addi	sp,sp,-144
    80005080:	e506                	sd	ra,136(sp)
    80005082:	e122                	sd	s0,128(sp)
    80005084:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005086:	b7dfe0ef          	jal	80003c02 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000508a:	08000613          	li	a2,128
    8000508e:	f7040593          	addi	a1,s0,-144
    80005092:	4501                	li	a0,0
    80005094:	f6efd0ef          	jal	80002802 <argstr>
    80005098:	02054363          	bltz	a0,800050be <sys_mkdir+0x40>
    8000509c:	4681                	li	a3,0
    8000509e:	4601                	li	a2,0
    800050a0:	4585                	li	a1,1
    800050a2:	f7040513          	addi	a0,s0,-144
    800050a6:	96fff0ef          	jal	80004a14 <create>
    800050aa:	c911                	beqz	a0,800050be <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800050ac:	b76fe0ef          	jal	80003422 <iunlockput>
  end_op();
    800050b0:	bbdfe0ef          	jal	80003c6c <end_op>
  return 0;
    800050b4:	4501                	li	a0,0
}
    800050b6:	60aa                	ld	ra,136(sp)
    800050b8:	640a                	ld	s0,128(sp)
    800050ba:	6149                	addi	sp,sp,144
    800050bc:	8082                	ret
    end_op();
    800050be:	baffe0ef          	jal	80003c6c <end_op>
    return -1;
    800050c2:	557d                	li	a0,-1
    800050c4:	bfcd                	j	800050b6 <sys_mkdir+0x38>

00000000800050c6 <sys_mknod>:

uint64
sys_mknod(void)
{
    800050c6:	7135                	addi	sp,sp,-160
    800050c8:	ed06                	sd	ra,152(sp)
    800050ca:	e922                	sd	s0,144(sp)
    800050cc:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800050ce:	b35fe0ef          	jal	80003c02 <begin_op>
  argint(1, &major);
    800050d2:	f6c40593          	addi	a1,s0,-148
    800050d6:	4505                	li	a0,1
    800050d8:	ef2fd0ef          	jal	800027ca <argint>
  argint(2, &minor);
    800050dc:	f6840593          	addi	a1,s0,-152
    800050e0:	4509                	li	a0,2
    800050e2:	ee8fd0ef          	jal	800027ca <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800050e6:	08000613          	li	a2,128
    800050ea:	f7040593          	addi	a1,s0,-144
    800050ee:	4501                	li	a0,0
    800050f0:	f12fd0ef          	jal	80002802 <argstr>
    800050f4:	02054563          	bltz	a0,8000511e <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800050f8:	f6841683          	lh	a3,-152(s0)
    800050fc:	f6c41603          	lh	a2,-148(s0)
    80005100:	458d                	li	a1,3
    80005102:	f7040513          	addi	a0,s0,-144
    80005106:	90fff0ef          	jal	80004a14 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000510a:	c911                	beqz	a0,8000511e <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000510c:	b16fe0ef          	jal	80003422 <iunlockput>
  end_op();
    80005110:	b5dfe0ef          	jal	80003c6c <end_op>
  return 0;
    80005114:	4501                	li	a0,0
}
    80005116:	60ea                	ld	ra,152(sp)
    80005118:	644a                	ld	s0,144(sp)
    8000511a:	610d                	addi	sp,sp,160
    8000511c:	8082                	ret
    end_op();
    8000511e:	b4ffe0ef          	jal	80003c6c <end_op>
    return -1;
    80005122:	557d                	li	a0,-1
    80005124:	bfcd                	j	80005116 <sys_mknod+0x50>

0000000080005126 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005126:	7135                	addi	sp,sp,-160
    80005128:	ed06                	sd	ra,152(sp)
    8000512a:	e922                	sd	s0,144(sp)
    8000512c:	e14a                	sd	s2,128(sp)
    8000512e:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005130:	f9efc0ef          	jal	800018ce <myproc>
    80005134:	892a                	mv	s2,a0
  
  begin_op();
    80005136:	acdfe0ef          	jal	80003c02 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000513a:	08000613          	li	a2,128
    8000513e:	f6040593          	addi	a1,s0,-160
    80005142:	4501                	li	a0,0
    80005144:	ebefd0ef          	jal	80002802 <argstr>
    80005148:	04054363          	bltz	a0,8000518e <sys_chdir+0x68>
    8000514c:	e526                	sd	s1,136(sp)
    8000514e:	f6040513          	addi	a0,s0,-160
    80005152:	8ddfe0ef          	jal	80003a2e <namei>
    80005156:	84aa                	mv	s1,a0
    80005158:	c915                	beqz	a0,8000518c <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    8000515a:	8befe0ef          	jal	80003218 <ilock>
  if(ip->type != T_DIR){
    8000515e:	04449703          	lh	a4,68(s1)
    80005162:	4785                	li	a5,1
    80005164:	02f71963          	bne	a4,a5,80005196 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005168:	8526                	mv	a0,s1
    8000516a:	95cfe0ef          	jal	800032c6 <iunlock>
  iput(p->cwd);
    8000516e:	15093503          	ld	a0,336(s2)
    80005172:	a28fe0ef          	jal	8000339a <iput>
  end_op();
    80005176:	af7fe0ef          	jal	80003c6c <end_op>
  p->cwd = ip;
    8000517a:	14993823          	sd	s1,336(s2)
  return 0;
    8000517e:	4501                	li	a0,0
    80005180:	64aa                	ld	s1,136(sp)
}
    80005182:	60ea                	ld	ra,152(sp)
    80005184:	644a                	ld	s0,144(sp)
    80005186:	690a                	ld	s2,128(sp)
    80005188:	610d                	addi	sp,sp,160
    8000518a:	8082                	ret
    8000518c:	64aa                	ld	s1,136(sp)
    end_op();
    8000518e:	adffe0ef          	jal	80003c6c <end_op>
    return -1;
    80005192:	557d                	li	a0,-1
    80005194:	b7fd                	j	80005182 <sys_chdir+0x5c>
    iunlockput(ip);
    80005196:	8526                	mv	a0,s1
    80005198:	a8afe0ef          	jal	80003422 <iunlockput>
    end_op();
    8000519c:	ad1fe0ef          	jal	80003c6c <end_op>
    return -1;
    800051a0:	557d                	li	a0,-1
    800051a2:	64aa                	ld	s1,136(sp)
    800051a4:	bff9                	j	80005182 <sys_chdir+0x5c>

00000000800051a6 <sys_exec>:

uint64
sys_exec(void)
{
    800051a6:	7121                	addi	sp,sp,-448
    800051a8:	ff06                	sd	ra,440(sp)
    800051aa:	fb22                	sd	s0,432(sp)
    800051ac:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800051ae:	e4840593          	addi	a1,s0,-440
    800051b2:	4505                	li	a0,1
    800051b4:	e32fd0ef          	jal	800027e6 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800051b8:	08000613          	li	a2,128
    800051bc:	f5040593          	addi	a1,s0,-176
    800051c0:	4501                	li	a0,0
    800051c2:	e40fd0ef          	jal	80002802 <argstr>
    800051c6:	87aa                	mv	a5,a0
    return -1;
    800051c8:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800051ca:	0c07c463          	bltz	a5,80005292 <sys_exec+0xec>
    800051ce:	f726                	sd	s1,424(sp)
    800051d0:	f34a                	sd	s2,416(sp)
    800051d2:	ef4e                	sd	s3,408(sp)
    800051d4:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    800051d6:	10000613          	li	a2,256
    800051da:	4581                	li	a1,0
    800051dc:	e5040513          	addi	a0,s0,-432
    800051e0:	ac3fb0ef          	jal	80000ca2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800051e4:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    800051e8:	89a6                	mv	s3,s1
    800051ea:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800051ec:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800051f0:	00391513          	slli	a0,s2,0x3
    800051f4:	e4040593          	addi	a1,s0,-448
    800051f8:	e4843783          	ld	a5,-440(s0)
    800051fc:	953e                	add	a0,a0,a5
    800051fe:	d42fd0ef          	jal	80002740 <fetchaddr>
    80005202:	02054663          	bltz	a0,8000522e <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    80005206:	e4043783          	ld	a5,-448(s0)
    8000520a:	c3a9                	beqz	a5,8000524c <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    8000520c:	8f3fb0ef          	jal	80000afe <kalloc>
    80005210:	85aa                	mv	a1,a0
    80005212:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005216:	cd01                	beqz	a0,8000522e <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005218:	6605                	lui	a2,0x1
    8000521a:	e4043503          	ld	a0,-448(s0)
    8000521e:	d6cfd0ef          	jal	8000278a <fetchstr>
    80005222:	00054663          	bltz	a0,8000522e <sys_exec+0x88>
    if(i >= NELEM(argv)){
    80005226:	0905                	addi	s2,s2,1
    80005228:	09a1                	addi	s3,s3,8
    8000522a:	fd4913e3          	bne	s2,s4,800051f0 <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000522e:	f5040913          	addi	s2,s0,-176
    80005232:	6088                	ld	a0,0(s1)
    80005234:	c931                	beqz	a0,80005288 <sys_exec+0xe2>
    kfree(argv[i]);
    80005236:	fe6fb0ef          	jal	80000a1c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000523a:	04a1                	addi	s1,s1,8
    8000523c:	ff249be3          	bne	s1,s2,80005232 <sys_exec+0x8c>
  return -1;
    80005240:	557d                	li	a0,-1
    80005242:	74ba                	ld	s1,424(sp)
    80005244:	791a                	ld	s2,416(sp)
    80005246:	69fa                	ld	s3,408(sp)
    80005248:	6a5a                	ld	s4,400(sp)
    8000524a:	a0a1                	j	80005292 <sys_exec+0xec>
      argv[i] = 0;
    8000524c:	0009079b          	sext.w	a5,s2
    80005250:	078e                	slli	a5,a5,0x3
    80005252:	fd078793          	addi	a5,a5,-48
    80005256:	97a2                	add	a5,a5,s0
    80005258:	e807b023          	sd	zero,-384(a5)
  int ret = kexec(path, argv);
    8000525c:	e5040593          	addi	a1,s0,-432
    80005260:	f5040513          	addi	a0,s0,-176
    80005264:	ba8ff0ef          	jal	8000460c <kexec>
    80005268:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000526a:	f5040993          	addi	s3,s0,-176
    8000526e:	6088                	ld	a0,0(s1)
    80005270:	c511                	beqz	a0,8000527c <sys_exec+0xd6>
    kfree(argv[i]);
    80005272:	faafb0ef          	jal	80000a1c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005276:	04a1                	addi	s1,s1,8
    80005278:	ff349be3          	bne	s1,s3,8000526e <sys_exec+0xc8>
  return ret;
    8000527c:	854a                	mv	a0,s2
    8000527e:	74ba                	ld	s1,424(sp)
    80005280:	791a                	ld	s2,416(sp)
    80005282:	69fa                	ld	s3,408(sp)
    80005284:	6a5a                	ld	s4,400(sp)
    80005286:	a031                	j	80005292 <sys_exec+0xec>
  return -1;
    80005288:	557d                	li	a0,-1
    8000528a:	74ba                	ld	s1,424(sp)
    8000528c:	791a                	ld	s2,416(sp)
    8000528e:	69fa                	ld	s3,408(sp)
    80005290:	6a5a                	ld	s4,400(sp)
}
    80005292:	70fa                	ld	ra,440(sp)
    80005294:	745a                	ld	s0,432(sp)
    80005296:	6139                	addi	sp,sp,448
    80005298:	8082                	ret

000000008000529a <sys_pipe>:

uint64
sys_pipe(void)
{
    8000529a:	7139                	addi	sp,sp,-64
    8000529c:	fc06                	sd	ra,56(sp)
    8000529e:	f822                	sd	s0,48(sp)
    800052a0:	f426                	sd	s1,40(sp)
    800052a2:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800052a4:	e2afc0ef          	jal	800018ce <myproc>
    800052a8:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800052aa:	fd840593          	addi	a1,s0,-40
    800052ae:	4501                	li	a0,0
    800052b0:	d36fd0ef          	jal	800027e6 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800052b4:	fc840593          	addi	a1,s0,-56
    800052b8:	fd040513          	addi	a0,s0,-48
    800052bc:	85cff0ef          	jal	80004318 <pipealloc>
    return -1;
    800052c0:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800052c2:	0a054463          	bltz	a0,8000536a <sys_pipe+0xd0>
  fd0 = -1;
    800052c6:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800052ca:	fd043503          	ld	a0,-48(s0)
    800052ce:	f08ff0ef          	jal	800049d6 <fdalloc>
    800052d2:	fca42223          	sw	a0,-60(s0)
    800052d6:	08054163          	bltz	a0,80005358 <sys_pipe+0xbe>
    800052da:	fc843503          	ld	a0,-56(s0)
    800052de:	ef8ff0ef          	jal	800049d6 <fdalloc>
    800052e2:	fca42023          	sw	a0,-64(s0)
    800052e6:	06054063          	bltz	a0,80005346 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800052ea:	4691                	li	a3,4
    800052ec:	fc440613          	addi	a2,s0,-60
    800052f0:	fd843583          	ld	a1,-40(s0)
    800052f4:	68a8                	ld	a0,80(s1)
    800052f6:	aecfc0ef          	jal	800015e2 <copyout>
    800052fa:	00054e63          	bltz	a0,80005316 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800052fe:	4691                	li	a3,4
    80005300:	fc040613          	addi	a2,s0,-64
    80005304:	fd843583          	ld	a1,-40(s0)
    80005308:	0591                	addi	a1,a1,4
    8000530a:	68a8                	ld	a0,80(s1)
    8000530c:	ad6fc0ef          	jal	800015e2 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005310:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005312:	04055c63          	bgez	a0,8000536a <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80005316:	fc442783          	lw	a5,-60(s0)
    8000531a:	07e9                	addi	a5,a5,26
    8000531c:	078e                	slli	a5,a5,0x3
    8000531e:	97a6                	add	a5,a5,s1
    80005320:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005324:	fc042783          	lw	a5,-64(s0)
    80005328:	07e9                	addi	a5,a5,26
    8000532a:	078e                	slli	a5,a5,0x3
    8000532c:	94be                	add	s1,s1,a5
    8000532e:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005332:	fd043503          	ld	a0,-48(s0)
    80005336:	cd9fe0ef          	jal	8000400e <fileclose>
    fileclose(wf);
    8000533a:	fc843503          	ld	a0,-56(s0)
    8000533e:	cd1fe0ef          	jal	8000400e <fileclose>
    return -1;
    80005342:	57fd                	li	a5,-1
    80005344:	a01d                	j	8000536a <sys_pipe+0xd0>
    if(fd0 >= 0)
    80005346:	fc442783          	lw	a5,-60(s0)
    8000534a:	0007c763          	bltz	a5,80005358 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    8000534e:	07e9                	addi	a5,a5,26
    80005350:	078e                	slli	a5,a5,0x3
    80005352:	97a6                	add	a5,a5,s1
    80005354:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005358:	fd043503          	ld	a0,-48(s0)
    8000535c:	cb3fe0ef          	jal	8000400e <fileclose>
    fileclose(wf);
    80005360:	fc843503          	ld	a0,-56(s0)
    80005364:	cabfe0ef          	jal	8000400e <fileclose>
    return -1;
    80005368:	57fd                	li	a5,-1
}
    8000536a:	853e                	mv	a0,a5
    8000536c:	70e2                	ld	ra,56(sp)
    8000536e:	7442                	ld	s0,48(sp)
    80005370:	74a2                	ld	s1,40(sp)
    80005372:	6121                	addi	sp,sp,64
    80005374:	8082                	ret
	...

0000000080005380 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005380:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005382:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005384:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005386:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005388:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    8000538a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000538c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000538e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005390:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005392:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005394:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005396:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005398:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    8000539a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000539c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000539e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    800053a0:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    800053a2:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    800053a4:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    800053a6:	aaafd0ef          	jal	80002650 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    800053aa:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    800053ac:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    800053ae:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    800053b0:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    800053b2:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    800053b4:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    800053b6:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    800053b8:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    800053ba:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    800053bc:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    800053be:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    800053c0:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    800053c2:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    800053c4:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    800053c6:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    800053c8:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    800053ca:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    800053cc:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    800053ce:	10200073          	sret
	...

00000000800053de <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800053de:	1141                	addi	sp,sp,-16
    800053e0:	e422                	sd	s0,8(sp)
    800053e2:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800053e4:	0c0007b7          	lui	a5,0xc000
    800053e8:	4705                	li	a4,1
    800053ea:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800053ec:	0c0007b7          	lui	a5,0xc000
    800053f0:	c3d8                	sw	a4,4(a5)
}
    800053f2:	6422                	ld	s0,8(sp)
    800053f4:	0141                	addi	sp,sp,16
    800053f6:	8082                	ret

00000000800053f8 <plicinithart>:

void
plicinithart(void)
{
    800053f8:	1141                	addi	sp,sp,-16
    800053fa:	e406                	sd	ra,8(sp)
    800053fc:	e022                	sd	s0,0(sp)
    800053fe:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005400:	ca2fc0ef          	jal	800018a2 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005404:	0085171b          	slliw	a4,a0,0x8
    80005408:	0c0027b7          	lui	a5,0xc002
    8000540c:	97ba                	add	a5,a5,a4
    8000540e:	40200713          	li	a4,1026
    80005412:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005416:	00d5151b          	slliw	a0,a0,0xd
    8000541a:	0c2017b7          	lui	a5,0xc201
    8000541e:	97aa                	add	a5,a5,a0
    80005420:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005424:	60a2                	ld	ra,8(sp)
    80005426:	6402                	ld	s0,0(sp)
    80005428:	0141                	addi	sp,sp,16
    8000542a:	8082                	ret

000000008000542c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000542c:	1141                	addi	sp,sp,-16
    8000542e:	e406                	sd	ra,8(sp)
    80005430:	e022                	sd	s0,0(sp)
    80005432:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005434:	c6efc0ef          	jal	800018a2 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005438:	00d5151b          	slliw	a0,a0,0xd
    8000543c:	0c2017b7          	lui	a5,0xc201
    80005440:	97aa                	add	a5,a5,a0
  return irq;
}
    80005442:	43c8                	lw	a0,4(a5)
    80005444:	60a2                	ld	ra,8(sp)
    80005446:	6402                	ld	s0,0(sp)
    80005448:	0141                	addi	sp,sp,16
    8000544a:	8082                	ret

000000008000544c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000544c:	1101                	addi	sp,sp,-32
    8000544e:	ec06                	sd	ra,24(sp)
    80005450:	e822                	sd	s0,16(sp)
    80005452:	e426                	sd	s1,8(sp)
    80005454:	1000                	addi	s0,sp,32
    80005456:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005458:	c4afc0ef          	jal	800018a2 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000545c:	00d5151b          	slliw	a0,a0,0xd
    80005460:	0c2017b7          	lui	a5,0xc201
    80005464:	97aa                	add	a5,a5,a0
    80005466:	c3c4                	sw	s1,4(a5)
}
    80005468:	60e2                	ld	ra,24(sp)
    8000546a:	6442                	ld	s0,16(sp)
    8000546c:	64a2                	ld	s1,8(sp)
    8000546e:	6105                	addi	sp,sp,32
    80005470:	8082                	ret

0000000080005472 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005472:	1141                	addi	sp,sp,-16
    80005474:	e406                	sd	ra,8(sp)
    80005476:	e022                	sd	s0,0(sp)
    80005478:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000547a:	479d                	li	a5,7
    8000547c:	04a7ca63          	blt	a5,a0,800054d0 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005480:	0001e797          	auipc	a5,0x1e
    80005484:	f2878793          	addi	a5,a5,-216 # 800233a8 <disk>
    80005488:	97aa                	add	a5,a5,a0
    8000548a:	0187c783          	lbu	a5,24(a5)
    8000548e:	e7b9                	bnez	a5,800054dc <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005490:	00451693          	slli	a3,a0,0x4
    80005494:	0001e797          	auipc	a5,0x1e
    80005498:	f1478793          	addi	a5,a5,-236 # 800233a8 <disk>
    8000549c:	6398                	ld	a4,0(a5)
    8000549e:	9736                	add	a4,a4,a3
    800054a0:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    800054a4:	6398                	ld	a4,0(a5)
    800054a6:	9736                	add	a4,a4,a3
    800054a8:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800054ac:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800054b0:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800054b4:	97aa                	add	a5,a5,a0
    800054b6:	4705                	li	a4,1
    800054b8:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800054bc:	0001e517          	auipc	a0,0x1e
    800054c0:	f0450513          	addi	a0,a0,-252 # 800233c0 <disk+0x18>
    800054c4:	a4ffc0ef          	jal	80001f12 <wakeup>
}
    800054c8:	60a2                	ld	ra,8(sp)
    800054ca:	6402                	ld	s0,0(sp)
    800054cc:	0141                	addi	sp,sp,16
    800054ce:	8082                	ret
    panic("free_desc 1");
    800054d0:	00002517          	auipc	a0,0x2
    800054d4:	14050513          	addi	a0,a0,320 # 80007610 <etext+0x610>
    800054d8:	b08fb0ef          	jal	800007e0 <panic>
    panic("free_desc 2");
    800054dc:	00002517          	auipc	a0,0x2
    800054e0:	14450513          	addi	a0,a0,324 # 80007620 <etext+0x620>
    800054e4:	afcfb0ef          	jal	800007e0 <panic>

00000000800054e8 <virtio_disk_init>:
{
    800054e8:	1101                	addi	sp,sp,-32
    800054ea:	ec06                	sd	ra,24(sp)
    800054ec:	e822                	sd	s0,16(sp)
    800054ee:	e426                	sd	s1,8(sp)
    800054f0:	e04a                	sd	s2,0(sp)
    800054f2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800054f4:	00002597          	auipc	a1,0x2
    800054f8:	13c58593          	addi	a1,a1,316 # 80007630 <etext+0x630>
    800054fc:	0001e517          	auipc	a0,0x1e
    80005500:	fd450513          	addi	a0,a0,-44 # 800234d0 <disk+0x128>
    80005504:	e4afb0ef          	jal	80000b4e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005508:	100017b7          	lui	a5,0x10001
    8000550c:	4398                	lw	a4,0(a5)
    8000550e:	2701                	sext.w	a4,a4
    80005510:	747277b7          	lui	a5,0x74727
    80005514:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005518:	18f71063          	bne	a4,a5,80005698 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000551c:	100017b7          	lui	a5,0x10001
    80005520:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80005522:	439c                	lw	a5,0(a5)
    80005524:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005526:	4709                	li	a4,2
    80005528:	16e79863          	bne	a5,a4,80005698 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000552c:	100017b7          	lui	a5,0x10001
    80005530:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80005532:	439c                	lw	a5,0(a5)
    80005534:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005536:	16e79163          	bne	a5,a4,80005698 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000553a:	100017b7          	lui	a5,0x10001
    8000553e:	47d8                	lw	a4,12(a5)
    80005540:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005542:	554d47b7          	lui	a5,0x554d4
    80005546:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000554a:	14f71763          	bne	a4,a5,80005698 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000554e:	100017b7          	lui	a5,0x10001
    80005552:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005556:	4705                	li	a4,1
    80005558:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000555a:	470d                	li	a4,3
    8000555c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000555e:	10001737          	lui	a4,0x10001
    80005562:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005564:	c7ffe737          	lui	a4,0xc7ffe
    80005568:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdb277>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000556c:	8ef9                	and	a3,a3,a4
    8000556e:	10001737          	lui	a4,0x10001
    80005572:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005574:	472d                	li	a4,11
    80005576:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005578:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    8000557c:	439c                	lw	a5,0(a5)
    8000557e:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005582:	8ba1                	andi	a5,a5,8
    80005584:	12078063          	beqz	a5,800056a4 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005588:	100017b7          	lui	a5,0x10001
    8000558c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005590:	100017b7          	lui	a5,0x10001
    80005594:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80005598:	439c                	lw	a5,0(a5)
    8000559a:	2781                	sext.w	a5,a5
    8000559c:	10079a63          	bnez	a5,800056b0 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800055a0:	100017b7          	lui	a5,0x10001
    800055a4:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    800055a8:	439c                	lw	a5,0(a5)
    800055aa:	2781                	sext.w	a5,a5
  if(max == 0)
    800055ac:	10078863          	beqz	a5,800056bc <virtio_disk_init+0x1d4>
  if(max < NUM)
    800055b0:	471d                	li	a4,7
    800055b2:	10f77b63          	bgeu	a4,a5,800056c8 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    800055b6:	d48fb0ef          	jal	80000afe <kalloc>
    800055ba:	0001e497          	auipc	s1,0x1e
    800055be:	dee48493          	addi	s1,s1,-530 # 800233a8 <disk>
    800055c2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800055c4:	d3afb0ef          	jal	80000afe <kalloc>
    800055c8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800055ca:	d34fb0ef          	jal	80000afe <kalloc>
    800055ce:	87aa                	mv	a5,a0
    800055d0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800055d2:	6088                	ld	a0,0(s1)
    800055d4:	10050063          	beqz	a0,800056d4 <virtio_disk_init+0x1ec>
    800055d8:	0001e717          	auipc	a4,0x1e
    800055dc:	dd873703          	ld	a4,-552(a4) # 800233b0 <disk+0x8>
    800055e0:	0e070a63          	beqz	a4,800056d4 <virtio_disk_init+0x1ec>
    800055e4:	0e078863          	beqz	a5,800056d4 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    800055e8:	6605                	lui	a2,0x1
    800055ea:	4581                	li	a1,0
    800055ec:	eb6fb0ef          	jal	80000ca2 <memset>
  memset(disk.avail, 0, PGSIZE);
    800055f0:	0001e497          	auipc	s1,0x1e
    800055f4:	db848493          	addi	s1,s1,-584 # 800233a8 <disk>
    800055f8:	6605                	lui	a2,0x1
    800055fa:	4581                	li	a1,0
    800055fc:	6488                	ld	a0,8(s1)
    800055fe:	ea4fb0ef          	jal	80000ca2 <memset>
  memset(disk.used, 0, PGSIZE);
    80005602:	6605                	lui	a2,0x1
    80005604:	4581                	li	a1,0
    80005606:	6888                	ld	a0,16(s1)
    80005608:	e9afb0ef          	jal	80000ca2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000560c:	100017b7          	lui	a5,0x10001
    80005610:	4721                	li	a4,8
    80005612:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005614:	4098                	lw	a4,0(s1)
    80005616:	100017b7          	lui	a5,0x10001
    8000561a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    8000561e:	40d8                	lw	a4,4(s1)
    80005620:	100017b7          	lui	a5,0x10001
    80005624:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005628:	649c                	ld	a5,8(s1)
    8000562a:	0007869b          	sext.w	a3,a5
    8000562e:	10001737          	lui	a4,0x10001
    80005632:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005636:	9781                	srai	a5,a5,0x20
    80005638:	10001737          	lui	a4,0x10001
    8000563c:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005640:	689c                	ld	a5,16(s1)
    80005642:	0007869b          	sext.w	a3,a5
    80005646:	10001737          	lui	a4,0x10001
    8000564a:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000564e:	9781                	srai	a5,a5,0x20
    80005650:	10001737          	lui	a4,0x10001
    80005654:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005658:	10001737          	lui	a4,0x10001
    8000565c:	4785                	li	a5,1
    8000565e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005660:	00f48c23          	sb	a5,24(s1)
    80005664:	00f48ca3          	sb	a5,25(s1)
    80005668:	00f48d23          	sb	a5,26(s1)
    8000566c:	00f48da3          	sb	a5,27(s1)
    80005670:	00f48e23          	sb	a5,28(s1)
    80005674:	00f48ea3          	sb	a5,29(s1)
    80005678:	00f48f23          	sb	a5,30(s1)
    8000567c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005680:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005684:	100017b7          	lui	a5,0x10001
    80005688:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    8000568c:	60e2                	ld	ra,24(sp)
    8000568e:	6442                	ld	s0,16(sp)
    80005690:	64a2                	ld	s1,8(sp)
    80005692:	6902                	ld	s2,0(sp)
    80005694:	6105                	addi	sp,sp,32
    80005696:	8082                	ret
    panic("could not find virtio disk");
    80005698:	00002517          	auipc	a0,0x2
    8000569c:	fa850513          	addi	a0,a0,-88 # 80007640 <etext+0x640>
    800056a0:	940fb0ef          	jal	800007e0 <panic>
    panic("virtio disk FEATURES_OK unset");
    800056a4:	00002517          	auipc	a0,0x2
    800056a8:	fbc50513          	addi	a0,a0,-68 # 80007660 <etext+0x660>
    800056ac:	934fb0ef          	jal	800007e0 <panic>
    panic("virtio disk should not be ready");
    800056b0:	00002517          	auipc	a0,0x2
    800056b4:	fd050513          	addi	a0,a0,-48 # 80007680 <etext+0x680>
    800056b8:	928fb0ef          	jal	800007e0 <panic>
    panic("virtio disk has no queue 0");
    800056bc:	00002517          	auipc	a0,0x2
    800056c0:	fe450513          	addi	a0,a0,-28 # 800076a0 <etext+0x6a0>
    800056c4:	91cfb0ef          	jal	800007e0 <panic>
    panic("virtio disk max queue too short");
    800056c8:	00002517          	auipc	a0,0x2
    800056cc:	ff850513          	addi	a0,a0,-8 # 800076c0 <etext+0x6c0>
    800056d0:	910fb0ef          	jal	800007e0 <panic>
    panic("virtio disk kalloc");
    800056d4:	00002517          	auipc	a0,0x2
    800056d8:	00c50513          	addi	a0,a0,12 # 800076e0 <etext+0x6e0>
    800056dc:	904fb0ef          	jal	800007e0 <panic>

00000000800056e0 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800056e0:	7159                	addi	sp,sp,-112
    800056e2:	f486                	sd	ra,104(sp)
    800056e4:	f0a2                	sd	s0,96(sp)
    800056e6:	eca6                	sd	s1,88(sp)
    800056e8:	e8ca                	sd	s2,80(sp)
    800056ea:	e4ce                	sd	s3,72(sp)
    800056ec:	e0d2                	sd	s4,64(sp)
    800056ee:	fc56                	sd	s5,56(sp)
    800056f0:	f85a                	sd	s6,48(sp)
    800056f2:	f45e                	sd	s7,40(sp)
    800056f4:	f062                	sd	s8,32(sp)
    800056f6:	ec66                	sd	s9,24(sp)
    800056f8:	1880                	addi	s0,sp,112
    800056fa:	8a2a                	mv	s4,a0
    800056fc:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800056fe:	00c52c83          	lw	s9,12(a0)
    80005702:	001c9c9b          	slliw	s9,s9,0x1
    80005706:	1c82                	slli	s9,s9,0x20
    80005708:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    8000570c:	0001e517          	auipc	a0,0x1e
    80005710:	dc450513          	addi	a0,a0,-572 # 800234d0 <disk+0x128>
    80005714:	cbafb0ef          	jal	80000bce <acquire>
  for(int i = 0; i < 3; i++){
    80005718:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    8000571a:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000571c:	0001eb17          	auipc	s6,0x1e
    80005720:	c8cb0b13          	addi	s6,s6,-884 # 800233a8 <disk>
  for(int i = 0; i < 3; i++){
    80005724:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005726:	0001ec17          	auipc	s8,0x1e
    8000572a:	daac0c13          	addi	s8,s8,-598 # 800234d0 <disk+0x128>
    8000572e:	a8b9                	j	8000578c <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80005730:	00fb0733          	add	a4,s6,a5
    80005734:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80005738:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    8000573a:	0207c563          	bltz	a5,80005764 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    8000573e:	2905                	addiw	s2,s2,1
    80005740:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005742:	05590963          	beq	s2,s5,80005794 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    80005746:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005748:	0001e717          	auipc	a4,0x1e
    8000574c:	c6070713          	addi	a4,a4,-928 # 800233a8 <disk>
    80005750:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005752:	01874683          	lbu	a3,24(a4)
    80005756:	fee9                	bnez	a3,80005730 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80005758:	2785                	addiw	a5,a5,1
    8000575a:	0705                	addi	a4,a4,1
    8000575c:	fe979be3          	bne	a5,s1,80005752 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80005760:	57fd                	li	a5,-1
    80005762:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005764:	01205d63          	blez	s2,8000577e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005768:	f9042503          	lw	a0,-112(s0)
    8000576c:	d07ff0ef          	jal	80005472 <free_desc>
      for(int j = 0; j < i; j++)
    80005770:	4785                	li	a5,1
    80005772:	0127d663          	bge	a5,s2,8000577e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005776:	f9442503          	lw	a0,-108(s0)
    8000577a:	cf9ff0ef          	jal	80005472 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000577e:	85e2                	mv	a1,s8
    80005780:	0001e517          	auipc	a0,0x1e
    80005784:	c4050513          	addi	a0,a0,-960 # 800233c0 <disk+0x18>
    80005788:	f3efc0ef          	jal	80001ec6 <sleep>
  for(int i = 0; i < 3; i++){
    8000578c:	f9040613          	addi	a2,s0,-112
    80005790:	894e                	mv	s2,s3
    80005792:	bf55                	j	80005746 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005794:	f9042503          	lw	a0,-112(s0)
    80005798:	00451693          	slli	a3,a0,0x4

  if(write)
    8000579c:	0001e797          	auipc	a5,0x1e
    800057a0:	c0c78793          	addi	a5,a5,-1012 # 800233a8 <disk>
    800057a4:	00a50713          	addi	a4,a0,10
    800057a8:	0712                	slli	a4,a4,0x4
    800057aa:	973e                	add	a4,a4,a5
    800057ac:	01703633          	snez	a2,s7
    800057b0:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800057b2:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800057b6:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800057ba:	6398                	ld	a4,0(a5)
    800057bc:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800057be:	0a868613          	addi	a2,a3,168
    800057c2:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800057c4:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800057c6:	6390                	ld	a2,0(a5)
    800057c8:	00d605b3          	add	a1,a2,a3
    800057cc:	4741                	li	a4,16
    800057ce:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800057d0:	4805                	li	a6,1
    800057d2:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    800057d6:	f9442703          	lw	a4,-108(s0)
    800057da:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800057de:	0712                	slli	a4,a4,0x4
    800057e0:	963a                	add	a2,a2,a4
    800057e2:	058a0593          	addi	a1,s4,88
    800057e6:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800057e8:	0007b883          	ld	a7,0(a5)
    800057ec:	9746                	add	a4,a4,a7
    800057ee:	40000613          	li	a2,1024
    800057f2:	c710                	sw	a2,8(a4)
  if(write)
    800057f4:	001bb613          	seqz	a2,s7
    800057f8:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800057fc:	00166613          	ori	a2,a2,1
    80005800:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005804:	f9842583          	lw	a1,-104(s0)
    80005808:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000580c:	00250613          	addi	a2,a0,2
    80005810:	0612                	slli	a2,a2,0x4
    80005812:	963e                	add	a2,a2,a5
    80005814:	577d                	li	a4,-1
    80005816:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000581a:	0592                	slli	a1,a1,0x4
    8000581c:	98ae                	add	a7,a7,a1
    8000581e:	03068713          	addi	a4,a3,48
    80005822:	973e                	add	a4,a4,a5
    80005824:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005828:	6398                	ld	a4,0(a5)
    8000582a:	972e                	add	a4,a4,a1
    8000582c:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005830:	4689                	li	a3,2
    80005832:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005836:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000583a:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    8000583e:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005842:	6794                	ld	a3,8(a5)
    80005844:	0026d703          	lhu	a4,2(a3)
    80005848:	8b1d                	andi	a4,a4,7
    8000584a:	0706                	slli	a4,a4,0x1
    8000584c:	96ba                	add	a3,a3,a4
    8000584e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005852:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005856:	6798                	ld	a4,8(a5)
    80005858:	00275783          	lhu	a5,2(a4)
    8000585c:	2785                	addiw	a5,a5,1
    8000585e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005862:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005866:	100017b7          	lui	a5,0x10001
    8000586a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000586e:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80005872:	0001e917          	auipc	s2,0x1e
    80005876:	c5e90913          	addi	s2,s2,-930 # 800234d0 <disk+0x128>
  while(b->disk == 1) {
    8000587a:	4485                	li	s1,1
    8000587c:	01079a63          	bne	a5,a6,80005890 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005880:	85ca                	mv	a1,s2
    80005882:	8552                	mv	a0,s4
    80005884:	e42fc0ef          	jal	80001ec6 <sleep>
  while(b->disk == 1) {
    80005888:	004a2783          	lw	a5,4(s4)
    8000588c:	fe978ae3          	beq	a5,s1,80005880 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005890:	f9042903          	lw	s2,-112(s0)
    80005894:	00290713          	addi	a4,s2,2
    80005898:	0712                	slli	a4,a4,0x4
    8000589a:	0001e797          	auipc	a5,0x1e
    8000589e:	b0e78793          	addi	a5,a5,-1266 # 800233a8 <disk>
    800058a2:	97ba                	add	a5,a5,a4
    800058a4:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800058a8:	0001e997          	auipc	s3,0x1e
    800058ac:	b0098993          	addi	s3,s3,-1280 # 800233a8 <disk>
    800058b0:	00491713          	slli	a4,s2,0x4
    800058b4:	0009b783          	ld	a5,0(s3)
    800058b8:	97ba                	add	a5,a5,a4
    800058ba:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800058be:	854a                	mv	a0,s2
    800058c0:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800058c4:	bafff0ef          	jal	80005472 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800058c8:	8885                	andi	s1,s1,1
    800058ca:	f0fd                	bnez	s1,800058b0 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800058cc:	0001e517          	auipc	a0,0x1e
    800058d0:	c0450513          	addi	a0,a0,-1020 # 800234d0 <disk+0x128>
    800058d4:	b92fb0ef          	jal	80000c66 <release>
}
    800058d8:	70a6                	ld	ra,104(sp)
    800058da:	7406                	ld	s0,96(sp)
    800058dc:	64e6                	ld	s1,88(sp)
    800058de:	6946                	ld	s2,80(sp)
    800058e0:	69a6                	ld	s3,72(sp)
    800058e2:	6a06                	ld	s4,64(sp)
    800058e4:	7ae2                	ld	s5,56(sp)
    800058e6:	7b42                	ld	s6,48(sp)
    800058e8:	7ba2                	ld	s7,40(sp)
    800058ea:	7c02                	ld	s8,32(sp)
    800058ec:	6ce2                	ld	s9,24(sp)
    800058ee:	6165                	addi	sp,sp,112
    800058f0:	8082                	ret

00000000800058f2 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800058f2:	1101                	addi	sp,sp,-32
    800058f4:	ec06                	sd	ra,24(sp)
    800058f6:	e822                	sd	s0,16(sp)
    800058f8:	e426                	sd	s1,8(sp)
    800058fa:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800058fc:	0001e497          	auipc	s1,0x1e
    80005900:	aac48493          	addi	s1,s1,-1364 # 800233a8 <disk>
    80005904:	0001e517          	auipc	a0,0x1e
    80005908:	bcc50513          	addi	a0,a0,-1076 # 800234d0 <disk+0x128>
    8000590c:	ac2fb0ef          	jal	80000bce <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005910:	100017b7          	lui	a5,0x10001
    80005914:	53b8                	lw	a4,96(a5)
    80005916:	8b0d                	andi	a4,a4,3
    80005918:	100017b7          	lui	a5,0x10001
    8000591c:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    8000591e:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005922:	689c                	ld	a5,16(s1)
    80005924:	0204d703          	lhu	a4,32(s1)
    80005928:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    8000592c:	04f70663          	beq	a4,a5,80005978 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80005930:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005934:	6898                	ld	a4,16(s1)
    80005936:	0204d783          	lhu	a5,32(s1)
    8000593a:	8b9d                	andi	a5,a5,7
    8000593c:	078e                	slli	a5,a5,0x3
    8000593e:	97ba                	add	a5,a5,a4
    80005940:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005942:	00278713          	addi	a4,a5,2
    80005946:	0712                	slli	a4,a4,0x4
    80005948:	9726                	add	a4,a4,s1
    8000594a:	01074703          	lbu	a4,16(a4)
    8000594e:	e321                	bnez	a4,8000598e <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005950:	0789                	addi	a5,a5,2
    80005952:	0792                	slli	a5,a5,0x4
    80005954:	97a6                	add	a5,a5,s1
    80005956:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005958:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000595c:	db6fc0ef          	jal	80001f12 <wakeup>

    disk.used_idx += 1;
    80005960:	0204d783          	lhu	a5,32(s1)
    80005964:	2785                	addiw	a5,a5,1
    80005966:	17c2                	slli	a5,a5,0x30
    80005968:	93c1                	srli	a5,a5,0x30
    8000596a:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    8000596e:	6898                	ld	a4,16(s1)
    80005970:	00275703          	lhu	a4,2(a4)
    80005974:	faf71ee3          	bne	a4,a5,80005930 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005978:	0001e517          	auipc	a0,0x1e
    8000597c:	b5850513          	addi	a0,a0,-1192 # 800234d0 <disk+0x128>
    80005980:	ae6fb0ef          	jal	80000c66 <release>
}
    80005984:	60e2                	ld	ra,24(sp)
    80005986:	6442                	ld	s0,16(sp)
    80005988:	64a2                	ld	s1,8(sp)
    8000598a:	6105                	addi	sp,sp,32
    8000598c:	8082                	ret
      panic("virtio_disk_intr status");
    8000598e:	00002517          	auipc	a0,0x2
    80005992:	d6a50513          	addi	a0,a0,-662 # 800076f8 <etext+0x6f8>
    80005996:	e4bfa0ef          	jal	800007e0 <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	9282                	jalr	t0

000000008000609c <userret>:
    8000609c:	12000073          	sfence.vma
    800060a0:	18051073          	csrw	satp,a0
    800060a4:	12000073          	sfence.vma
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060ae:	0536                	slli	a0,a0,0xd
    800060b0:	02853083          	ld	ra,40(a0)
    800060b4:	03053103          	ld	sp,48(a0)
    800060b8:	03853183          	ld	gp,56(a0)
    800060bc:	04053203          	ld	tp,64(a0)
    800060c0:	04853283          	ld	t0,72(a0)
    800060c4:	05053303          	ld	t1,80(a0)
    800060c8:	05853383          	ld	t2,88(a0)
    800060cc:	7120                	ld	s0,96(a0)
    800060ce:	7524                	ld	s1,104(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
    800060d2:	6150                	ld	a2,128(a0)
    800060d4:	6554                	ld	a3,136(a0)
    800060d6:	6958                	ld	a4,144(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
    800060da:	0a053803          	ld	a6,160(a0)
    800060de:	0a853883          	ld	a7,168(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
    80006112:	11053f03          	ld	t5,272(a0)
    80006116:	11853f83          	ld	t6,280(a0)
    8000611a:	7928                	ld	a0,112(a0)
    8000611c:	10200073          	sret
	...
