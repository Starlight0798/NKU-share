
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	01e31313          	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000c:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc0200010:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200014:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200018:	03f31313          	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc020001c:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc0200020:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200024:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200028:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
    jr t0
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:
void grade_backtrace(void);


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	00006517          	auipc	a0,0x6
ffffffffc020003a:	fe250513          	addi	a0,a0,-30 # ffffffffc0206018 <edata>
ffffffffc020003e:	00006617          	auipc	a2,0x6
ffffffffc0200042:	43a60613          	addi	a2,a2,1082 # ffffffffc0206478 <end>
int kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
int kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	363010ef          	jal	ra,ffffffffc0201bb0 <memset>
    cons_init();  // init the console
ffffffffc0200052:	404000ef          	jal	ra,ffffffffc0200456 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200056:	00002517          	auipc	a0,0x2
ffffffffc020005a:	b7250513          	addi	a0,a0,-1166 # ffffffffc0201bc8 <etext+0x6>
ffffffffc020005e:	096000ef          	jal	ra,ffffffffc02000f4 <cputs>

    print_kerninfo();
ffffffffc0200062:	0e2000ef          	jal	ra,ffffffffc0200144 <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200066:	40a000ef          	jal	ra,ffffffffc0200470 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020006a:	402010ef          	jal	ra,ffffffffc020146c <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006e:	402000ef          	jal	ra,ffffffffc0200470 <idt_init>
        
    __asm__ volatile (
ffffffffc0200072:	30200073          	mret
ffffffffc0200076:	9002                	ebreak
    	"mret\n"
    	"ebreak\n"
    );

    clock_init();   // init clock interrupt
ffffffffc0200078:	39a000ef          	jal	ra,ffffffffc0200412 <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc020007c:	3e8000ef          	jal	ra,ffffffffc0200464 <intr_enable>



    /* do nothing */
    while (1)
        ;
ffffffffc0200080:	a001                	j	ffffffffc0200080 <kern_init+0x4a>

ffffffffc0200082 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200082:	1141                	addi	sp,sp,-16
ffffffffc0200084:	e022                	sd	s0,0(sp)
ffffffffc0200086:	e406                	sd	ra,8(sp)
ffffffffc0200088:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020008a:	3ce000ef          	jal	ra,ffffffffc0200458 <cons_putc>
    (*cnt) ++;
ffffffffc020008e:	401c                	lw	a5,0(s0)
}
ffffffffc0200090:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200092:	2785                	addiw	a5,a5,1
ffffffffc0200094:	c01c                	sw	a5,0(s0)
}
ffffffffc0200096:	6402                	ld	s0,0(sp)
ffffffffc0200098:	0141                	addi	sp,sp,16
ffffffffc020009a:	8082                	ret

ffffffffc020009c <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020009c:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020009e:	86ae                	mv	a3,a1
ffffffffc02000a0:	862a                	mv	a2,a0
ffffffffc02000a2:	006c                	addi	a1,sp,12
ffffffffc02000a4:	00000517          	auipc	a0,0x0
ffffffffc02000a8:	fde50513          	addi	a0,a0,-34 # ffffffffc0200082 <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000ac:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000ae:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000b0:	5d6010ef          	jal	ra,ffffffffc0201686 <vprintfmt>
    return cnt;
}
ffffffffc02000b4:	60e2                	ld	ra,24(sp)
ffffffffc02000b6:	4532                	lw	a0,12(sp)
ffffffffc02000b8:	6105                	addi	sp,sp,32
ffffffffc02000ba:	8082                	ret

ffffffffc02000bc <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000bc:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000be:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000c2:	f42e                	sd	a1,40(sp)
ffffffffc02000c4:	f832                	sd	a2,48(sp)
ffffffffc02000c6:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c8:	862a                	mv	a2,a0
ffffffffc02000ca:	004c                	addi	a1,sp,4
ffffffffc02000cc:	00000517          	auipc	a0,0x0
ffffffffc02000d0:	fb650513          	addi	a0,a0,-74 # ffffffffc0200082 <cputch>
ffffffffc02000d4:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000d6:	ec06                	sd	ra,24(sp)
ffffffffc02000d8:	e0ba                	sd	a4,64(sp)
ffffffffc02000da:	e4be                	sd	a5,72(sp)
ffffffffc02000dc:	e8c2                	sd	a6,80(sp)
ffffffffc02000de:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000e0:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000e2:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000e4:	5a2010ef          	jal	ra,ffffffffc0201686 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e8:	60e2                	ld	ra,24(sp)
ffffffffc02000ea:	4512                	lw	a0,4(sp)
ffffffffc02000ec:	6125                	addi	sp,sp,96
ffffffffc02000ee:	8082                	ret

ffffffffc02000f0 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000f0:	3680006f          	j	ffffffffc0200458 <cons_putc>

ffffffffc02000f4 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000f4:	1101                	addi	sp,sp,-32
ffffffffc02000f6:	e822                	sd	s0,16(sp)
ffffffffc02000f8:	ec06                	sd	ra,24(sp)
ffffffffc02000fa:	e426                	sd	s1,8(sp)
ffffffffc02000fc:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000fe:	00054503          	lbu	a0,0(a0)
ffffffffc0200102:	c51d                	beqz	a0,ffffffffc0200130 <cputs+0x3c>
ffffffffc0200104:	0405                	addi	s0,s0,1
ffffffffc0200106:	4485                	li	s1,1
ffffffffc0200108:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc020010a:	34e000ef          	jal	ra,ffffffffc0200458 <cons_putc>
    (*cnt) ++;
ffffffffc020010e:	008487bb          	addw	a5,s1,s0
    while ((c = *str ++) != '\0') {
ffffffffc0200112:	0405                	addi	s0,s0,1
ffffffffc0200114:	fff44503          	lbu	a0,-1(s0)
ffffffffc0200118:	f96d                	bnez	a0,ffffffffc020010a <cputs+0x16>
ffffffffc020011a:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc020011e:	4529                	li	a0,10
ffffffffc0200120:	338000ef          	jal	ra,ffffffffc0200458 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc0200124:	8522                	mv	a0,s0
ffffffffc0200126:	60e2                	ld	ra,24(sp)
ffffffffc0200128:	6442                	ld	s0,16(sp)
ffffffffc020012a:	64a2                	ld	s1,8(sp)
ffffffffc020012c:	6105                	addi	sp,sp,32
ffffffffc020012e:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200130:	4405                	li	s0,1
ffffffffc0200132:	b7f5                	j	ffffffffc020011e <cputs+0x2a>

ffffffffc0200134 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200134:	1141                	addi	sp,sp,-16
ffffffffc0200136:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200138:	328000ef          	jal	ra,ffffffffc0200460 <cons_getc>
ffffffffc020013c:	dd75                	beqz	a0,ffffffffc0200138 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc020013e:	60a2                	ld	ra,8(sp)
ffffffffc0200140:	0141                	addi	sp,sp,16
ffffffffc0200142:	8082                	ret

ffffffffc0200144 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200144:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200146:	00002517          	auipc	a0,0x2
ffffffffc020014a:	ad250513          	addi	a0,a0,-1326 # ffffffffc0201c18 <etext+0x56>
void print_kerninfo(void) {
ffffffffc020014e:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200150:	f6dff0ef          	jal	ra,ffffffffc02000bc <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc0200154:	00000597          	auipc	a1,0x0
ffffffffc0200158:	ee258593          	addi	a1,a1,-286 # ffffffffc0200036 <kern_init>
ffffffffc020015c:	00002517          	auipc	a0,0x2
ffffffffc0200160:	adc50513          	addi	a0,a0,-1316 # ffffffffc0201c38 <etext+0x76>
ffffffffc0200164:	f59ff0ef          	jal	ra,ffffffffc02000bc <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc0200168:	00002597          	auipc	a1,0x2
ffffffffc020016c:	a5a58593          	addi	a1,a1,-1446 # ffffffffc0201bc2 <etext>
ffffffffc0200170:	00002517          	auipc	a0,0x2
ffffffffc0200174:	ae850513          	addi	a0,a0,-1304 # ffffffffc0201c58 <etext+0x96>
ffffffffc0200178:	f45ff0ef          	jal	ra,ffffffffc02000bc <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc020017c:	00006597          	auipc	a1,0x6
ffffffffc0200180:	e9c58593          	addi	a1,a1,-356 # ffffffffc0206018 <edata>
ffffffffc0200184:	00002517          	auipc	a0,0x2
ffffffffc0200188:	af450513          	addi	a0,a0,-1292 # ffffffffc0201c78 <etext+0xb6>
ffffffffc020018c:	f31ff0ef          	jal	ra,ffffffffc02000bc <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200190:	00006597          	auipc	a1,0x6
ffffffffc0200194:	2e858593          	addi	a1,a1,744 # ffffffffc0206478 <end>
ffffffffc0200198:	00002517          	auipc	a0,0x2
ffffffffc020019c:	b0050513          	addi	a0,a0,-1280 # ffffffffc0201c98 <etext+0xd6>
ffffffffc02001a0:	f1dff0ef          	jal	ra,ffffffffc02000bc <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc02001a4:	00006597          	auipc	a1,0x6
ffffffffc02001a8:	6d358593          	addi	a1,a1,1747 # ffffffffc0206877 <end+0x3ff>
ffffffffc02001ac:	00000797          	auipc	a5,0x0
ffffffffc02001b0:	e8a78793          	addi	a5,a5,-374 # ffffffffc0200036 <kern_init>
ffffffffc02001b4:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b8:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001bc:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001be:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001c2:	95be                	add	a1,a1,a5
ffffffffc02001c4:	85a9                	srai	a1,a1,0xa
ffffffffc02001c6:	00002517          	auipc	a0,0x2
ffffffffc02001ca:	af250513          	addi	a0,a0,-1294 # ffffffffc0201cb8 <etext+0xf6>
}
ffffffffc02001ce:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001d0:	eedff06f          	j	ffffffffc02000bc <cprintf>

ffffffffc02001d4 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001d4:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001d6:	00002617          	auipc	a2,0x2
ffffffffc02001da:	a1260613          	addi	a2,a2,-1518 # ffffffffc0201be8 <etext+0x26>
ffffffffc02001de:	04e00593          	li	a1,78
ffffffffc02001e2:	00002517          	auipc	a0,0x2
ffffffffc02001e6:	a1e50513          	addi	a0,a0,-1506 # ffffffffc0201c00 <etext+0x3e>
void print_stackframe(void) {
ffffffffc02001ea:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001ec:	1c6000ef          	jal	ra,ffffffffc02003b2 <__panic>

ffffffffc02001f0 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001f0:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001f2:	00002617          	auipc	a2,0x2
ffffffffc02001f6:	bd660613          	addi	a2,a2,-1066 # ffffffffc0201dc8 <commands+0xe0>
ffffffffc02001fa:	00002597          	auipc	a1,0x2
ffffffffc02001fe:	bee58593          	addi	a1,a1,-1042 # ffffffffc0201de8 <commands+0x100>
ffffffffc0200202:	00002517          	auipc	a0,0x2
ffffffffc0200206:	bee50513          	addi	a0,a0,-1042 # ffffffffc0201df0 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc020020a:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020020c:	eb1ff0ef          	jal	ra,ffffffffc02000bc <cprintf>
ffffffffc0200210:	00002617          	auipc	a2,0x2
ffffffffc0200214:	bf060613          	addi	a2,a2,-1040 # ffffffffc0201e00 <commands+0x118>
ffffffffc0200218:	00002597          	auipc	a1,0x2
ffffffffc020021c:	c1058593          	addi	a1,a1,-1008 # ffffffffc0201e28 <commands+0x140>
ffffffffc0200220:	00002517          	auipc	a0,0x2
ffffffffc0200224:	bd050513          	addi	a0,a0,-1072 # ffffffffc0201df0 <commands+0x108>
ffffffffc0200228:	e95ff0ef          	jal	ra,ffffffffc02000bc <cprintf>
ffffffffc020022c:	00002617          	auipc	a2,0x2
ffffffffc0200230:	c0c60613          	addi	a2,a2,-1012 # ffffffffc0201e38 <commands+0x150>
ffffffffc0200234:	00002597          	auipc	a1,0x2
ffffffffc0200238:	c2458593          	addi	a1,a1,-988 # ffffffffc0201e58 <commands+0x170>
ffffffffc020023c:	00002517          	auipc	a0,0x2
ffffffffc0200240:	bb450513          	addi	a0,a0,-1100 # ffffffffc0201df0 <commands+0x108>
ffffffffc0200244:	e79ff0ef          	jal	ra,ffffffffc02000bc <cprintf>
    }
    return 0;
}
ffffffffc0200248:	60a2                	ld	ra,8(sp)
ffffffffc020024a:	4501                	li	a0,0
ffffffffc020024c:	0141                	addi	sp,sp,16
ffffffffc020024e:	8082                	ret

ffffffffc0200250 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200250:	1141                	addi	sp,sp,-16
ffffffffc0200252:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200254:	ef1ff0ef          	jal	ra,ffffffffc0200144 <print_kerninfo>
    return 0;
}
ffffffffc0200258:	60a2                	ld	ra,8(sp)
ffffffffc020025a:	4501                	li	a0,0
ffffffffc020025c:	0141                	addi	sp,sp,16
ffffffffc020025e:	8082                	ret

ffffffffc0200260 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200260:	1141                	addi	sp,sp,-16
ffffffffc0200262:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200264:	f71ff0ef          	jal	ra,ffffffffc02001d4 <print_stackframe>
    return 0;
}
ffffffffc0200268:	60a2                	ld	ra,8(sp)
ffffffffc020026a:	4501                	li	a0,0
ffffffffc020026c:	0141                	addi	sp,sp,16
ffffffffc020026e:	8082                	ret

ffffffffc0200270 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200270:	7115                	addi	sp,sp,-224
ffffffffc0200272:	e962                	sd	s8,144(sp)
ffffffffc0200274:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200276:	00002517          	auipc	a0,0x2
ffffffffc020027a:	aba50513          	addi	a0,a0,-1350 # ffffffffc0201d30 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc020027e:	ed86                	sd	ra,216(sp)
ffffffffc0200280:	e9a2                	sd	s0,208(sp)
ffffffffc0200282:	e5a6                	sd	s1,200(sp)
ffffffffc0200284:	e1ca                	sd	s2,192(sp)
ffffffffc0200286:	fd4e                	sd	s3,184(sp)
ffffffffc0200288:	f952                	sd	s4,176(sp)
ffffffffc020028a:	f556                	sd	s5,168(sp)
ffffffffc020028c:	f15a                	sd	s6,160(sp)
ffffffffc020028e:	ed5e                	sd	s7,152(sp)
ffffffffc0200290:	e566                	sd	s9,136(sp)
ffffffffc0200292:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200294:	e29ff0ef          	jal	ra,ffffffffc02000bc <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200298:	00002517          	auipc	a0,0x2
ffffffffc020029c:	ac050513          	addi	a0,a0,-1344 # ffffffffc0201d58 <commands+0x70>
ffffffffc02002a0:	e1dff0ef          	jal	ra,ffffffffc02000bc <cprintf>
    if (tf != NULL) {
ffffffffc02002a4:	000c0563          	beqz	s8,ffffffffc02002ae <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002a8:	8562                	mv	a0,s8
ffffffffc02002aa:	3a6000ef          	jal	ra,ffffffffc0200650 <print_trapframe>
ffffffffc02002ae:	00002c97          	auipc	s9,0x2
ffffffffc02002b2:	a3ac8c93          	addi	s9,s9,-1478 # ffffffffc0201ce8 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002b6:	00002997          	auipc	s3,0x2
ffffffffc02002ba:	aca98993          	addi	s3,s3,-1334 # ffffffffc0201d80 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002be:	00002917          	auipc	s2,0x2
ffffffffc02002c2:	aca90913          	addi	s2,s2,-1334 # ffffffffc0201d88 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc02002c6:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002c8:	00002b17          	auipc	s6,0x2
ffffffffc02002cc:	ac8b0b13          	addi	s6,s6,-1336 # ffffffffc0201d90 <commands+0xa8>
    if (argc == 0) {
ffffffffc02002d0:	00002a97          	auipc	s5,0x2
ffffffffc02002d4:	b18a8a93          	addi	s5,s5,-1256 # ffffffffc0201de8 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002d8:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002da:	854e                	mv	a0,s3
ffffffffc02002dc:	736010ef          	jal	ra,ffffffffc0201a12 <readline>
ffffffffc02002e0:	842a                	mv	s0,a0
ffffffffc02002e2:	dd65                	beqz	a0,ffffffffc02002da <kmonitor+0x6a>
ffffffffc02002e4:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002e8:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002ea:	c999                	beqz	a1,ffffffffc0200300 <kmonitor+0x90>
ffffffffc02002ec:	854a                	mv	a0,s2
ffffffffc02002ee:	0a5010ef          	jal	ra,ffffffffc0201b92 <strchr>
ffffffffc02002f2:	c925                	beqz	a0,ffffffffc0200362 <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc02002f4:	00144583          	lbu	a1,1(s0)
ffffffffc02002f8:	00040023          	sb	zero,0(s0)
ffffffffc02002fc:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002fe:	f5fd                	bnez	a1,ffffffffc02002ec <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc0200300:	dce9                	beqz	s1,ffffffffc02002da <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200302:	6582                	ld	a1,0(sp)
ffffffffc0200304:	00002d17          	auipc	s10,0x2
ffffffffc0200308:	9e4d0d13          	addi	s10,s10,-1564 # ffffffffc0201ce8 <commands>
    if (argc == 0) {
ffffffffc020030c:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020030e:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200310:	0d61                	addi	s10,s10,24
ffffffffc0200312:	057010ef          	jal	ra,ffffffffc0201b68 <strcmp>
ffffffffc0200316:	c919                	beqz	a0,ffffffffc020032c <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200318:	2405                	addiw	s0,s0,1
ffffffffc020031a:	09740463          	beq	s0,s7,ffffffffc02003a2 <kmonitor+0x132>
ffffffffc020031e:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200322:	6582                	ld	a1,0(sp)
ffffffffc0200324:	0d61                	addi	s10,s10,24
ffffffffc0200326:	043010ef          	jal	ra,ffffffffc0201b68 <strcmp>
ffffffffc020032a:	f57d                	bnez	a0,ffffffffc0200318 <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020032c:	00141793          	slli	a5,s0,0x1
ffffffffc0200330:	97a2                	add	a5,a5,s0
ffffffffc0200332:	078e                	slli	a5,a5,0x3
ffffffffc0200334:	97e6                	add	a5,a5,s9
ffffffffc0200336:	6b9c                	ld	a5,16(a5)
ffffffffc0200338:	8662                	mv	a2,s8
ffffffffc020033a:	002c                	addi	a1,sp,8
ffffffffc020033c:	fff4851b          	addiw	a0,s1,-1
ffffffffc0200340:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200342:	f8055ce3          	bgez	a0,ffffffffc02002da <kmonitor+0x6a>
}
ffffffffc0200346:	60ee                	ld	ra,216(sp)
ffffffffc0200348:	644e                	ld	s0,208(sp)
ffffffffc020034a:	64ae                	ld	s1,200(sp)
ffffffffc020034c:	690e                	ld	s2,192(sp)
ffffffffc020034e:	79ea                	ld	s3,184(sp)
ffffffffc0200350:	7a4a                	ld	s4,176(sp)
ffffffffc0200352:	7aaa                	ld	s5,168(sp)
ffffffffc0200354:	7b0a                	ld	s6,160(sp)
ffffffffc0200356:	6bea                	ld	s7,152(sp)
ffffffffc0200358:	6c4a                	ld	s8,144(sp)
ffffffffc020035a:	6caa                	ld	s9,136(sp)
ffffffffc020035c:	6d0a                	ld	s10,128(sp)
ffffffffc020035e:	612d                	addi	sp,sp,224
ffffffffc0200360:	8082                	ret
        if (*buf == '\0') {
ffffffffc0200362:	00044783          	lbu	a5,0(s0)
ffffffffc0200366:	dfc9                	beqz	a5,ffffffffc0200300 <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc0200368:	03448863          	beq	s1,s4,ffffffffc0200398 <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc020036c:	00349793          	slli	a5,s1,0x3
ffffffffc0200370:	0118                	addi	a4,sp,128
ffffffffc0200372:	97ba                	add	a5,a5,a4
ffffffffc0200374:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200378:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020037c:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020037e:	e591                	bnez	a1,ffffffffc020038a <kmonitor+0x11a>
ffffffffc0200380:	b749                	j	ffffffffc0200302 <kmonitor+0x92>
            buf ++;
ffffffffc0200382:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200384:	00044583          	lbu	a1,0(s0)
ffffffffc0200388:	ddad                	beqz	a1,ffffffffc0200302 <kmonitor+0x92>
ffffffffc020038a:	854a                	mv	a0,s2
ffffffffc020038c:	007010ef          	jal	ra,ffffffffc0201b92 <strchr>
ffffffffc0200390:	d96d                	beqz	a0,ffffffffc0200382 <kmonitor+0x112>
ffffffffc0200392:	00044583          	lbu	a1,0(s0)
ffffffffc0200396:	bf91                	j	ffffffffc02002ea <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200398:	45c1                	li	a1,16
ffffffffc020039a:	855a                	mv	a0,s6
ffffffffc020039c:	d21ff0ef          	jal	ra,ffffffffc02000bc <cprintf>
ffffffffc02003a0:	b7f1                	j	ffffffffc020036c <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02003a2:	6582                	ld	a1,0(sp)
ffffffffc02003a4:	00002517          	auipc	a0,0x2
ffffffffc02003a8:	a0c50513          	addi	a0,a0,-1524 # ffffffffc0201db0 <commands+0xc8>
ffffffffc02003ac:	d11ff0ef          	jal	ra,ffffffffc02000bc <cprintf>
    return 0;
ffffffffc02003b0:	b72d                	j	ffffffffc02002da <kmonitor+0x6a>

ffffffffc02003b2 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003b2:	00006317          	auipc	t1,0x6
ffffffffc02003b6:	06630313          	addi	t1,t1,102 # ffffffffc0206418 <is_panic>
ffffffffc02003ba:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003be:	715d                	addi	sp,sp,-80
ffffffffc02003c0:	ec06                	sd	ra,24(sp)
ffffffffc02003c2:	e822                	sd	s0,16(sp)
ffffffffc02003c4:	f436                	sd	a3,40(sp)
ffffffffc02003c6:	f83a                	sd	a4,48(sp)
ffffffffc02003c8:	fc3e                	sd	a5,56(sp)
ffffffffc02003ca:	e0c2                	sd	a6,64(sp)
ffffffffc02003cc:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003ce:	02031c63          	bnez	t1,ffffffffc0200406 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003d2:	4785                	li	a5,1
ffffffffc02003d4:	8432                	mv	s0,a2
ffffffffc02003d6:	00006717          	auipc	a4,0x6
ffffffffc02003da:	04f72123          	sw	a5,66(a4) # ffffffffc0206418 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003de:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc02003e0:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e2:	85aa                	mv	a1,a0
ffffffffc02003e4:	00002517          	auipc	a0,0x2
ffffffffc02003e8:	a8450513          	addi	a0,a0,-1404 # ffffffffc0201e68 <commands+0x180>
    va_start(ap, fmt);
ffffffffc02003ec:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003ee:	ccfff0ef          	jal	ra,ffffffffc02000bc <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003f2:	65a2                	ld	a1,8(sp)
ffffffffc02003f4:	8522                	mv	a0,s0
ffffffffc02003f6:	ca7ff0ef          	jal	ra,ffffffffc020009c <vcprintf>
    cprintf("\n");
ffffffffc02003fa:	00002517          	auipc	a0,0x2
ffffffffc02003fe:	8e650513          	addi	a0,a0,-1818 # ffffffffc0201ce0 <etext+0x11e>
ffffffffc0200402:	cbbff0ef          	jal	ra,ffffffffc02000bc <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200406:	064000ef          	jal	ra,ffffffffc020046a <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc020040a:	4501                	li	a0,0
ffffffffc020040c:	e65ff0ef          	jal	ra,ffffffffc0200270 <kmonitor>
ffffffffc0200410:	bfed                	j	ffffffffc020040a <__panic+0x58>

ffffffffc0200412 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc0200412:	1141                	addi	sp,sp,-16
ffffffffc0200414:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc0200416:	02000793          	li	a5,32
ffffffffc020041a:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020041e:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200422:	67e1                	lui	a5,0x18
ffffffffc0200424:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc0200428:	953e                	add	a0,a0,a5
ffffffffc020042a:	6c2010ef          	jal	ra,ffffffffc0201aec <sbi_set_timer>
}
ffffffffc020042e:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200430:	00006797          	auipc	a5,0x6
ffffffffc0200434:	0007b423          	sd	zero,8(a5) # ffffffffc0206438 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200438:	00002517          	auipc	a0,0x2
ffffffffc020043c:	a5050513          	addi	a0,a0,-1456 # ffffffffc0201e88 <commands+0x1a0>
}
ffffffffc0200440:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc0200442:	c7bff06f          	j	ffffffffc02000bc <cprintf>

ffffffffc0200446 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200446:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020044a:	67e1                	lui	a5,0x18
ffffffffc020044c:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc0200450:	953e                	add	a0,a0,a5
ffffffffc0200452:	69a0106f          	j	ffffffffc0201aec <sbi_set_timer>

ffffffffc0200456 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200456:	8082                	ret

ffffffffc0200458 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc0200458:	0ff57513          	andi	a0,a0,255
ffffffffc020045c:	6740106f          	j	ffffffffc0201ad0 <sbi_console_putchar>

ffffffffc0200460 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200460:	6a80106f          	j	ffffffffc0201b08 <sbi_console_getchar>

ffffffffc0200464 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200464:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200468:	8082                	ret

ffffffffc020046a <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc020046a:	100177f3          	csrrci	a5,sstatus,2
ffffffffc020046e:	8082                	ret

ffffffffc0200470 <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200470:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200474:	00000797          	auipc	a5,0x0
ffffffffc0200478:	3b478793          	addi	a5,a5,948 # ffffffffc0200828 <__alltraps>
ffffffffc020047c:	10579073          	csrw	stvec,a5
}
ffffffffc0200480:	8082                	ret

ffffffffc0200482 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200482:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200484:	1141                	addi	sp,sp,-16
ffffffffc0200486:	e022                	sd	s0,0(sp)
ffffffffc0200488:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020048a:	00002517          	auipc	a0,0x2
ffffffffc020048e:	bae50513          	addi	a0,a0,-1106 # ffffffffc0202038 <commands+0x350>
void print_regs(struct pushregs *gpr) {
ffffffffc0200492:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200494:	c29ff0ef          	jal	ra,ffffffffc02000bc <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200498:	640c                	ld	a1,8(s0)
ffffffffc020049a:	00002517          	auipc	a0,0x2
ffffffffc020049e:	bb650513          	addi	a0,a0,-1098 # ffffffffc0202050 <commands+0x368>
ffffffffc02004a2:	c1bff0ef          	jal	ra,ffffffffc02000bc <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02004a6:	680c                	ld	a1,16(s0)
ffffffffc02004a8:	00002517          	auipc	a0,0x2
ffffffffc02004ac:	bc050513          	addi	a0,a0,-1088 # ffffffffc0202068 <commands+0x380>
ffffffffc02004b0:	c0dff0ef          	jal	ra,ffffffffc02000bc <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004b4:	6c0c                	ld	a1,24(s0)
ffffffffc02004b6:	00002517          	auipc	a0,0x2
ffffffffc02004ba:	bca50513          	addi	a0,a0,-1078 # ffffffffc0202080 <commands+0x398>
ffffffffc02004be:	bffff0ef          	jal	ra,ffffffffc02000bc <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004c2:	700c                	ld	a1,32(s0)
ffffffffc02004c4:	00002517          	auipc	a0,0x2
ffffffffc02004c8:	bd450513          	addi	a0,a0,-1068 # ffffffffc0202098 <commands+0x3b0>
ffffffffc02004cc:	bf1ff0ef          	jal	ra,ffffffffc02000bc <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004d0:	740c                	ld	a1,40(s0)
ffffffffc02004d2:	00002517          	auipc	a0,0x2
ffffffffc02004d6:	bde50513          	addi	a0,a0,-1058 # ffffffffc02020b0 <commands+0x3c8>
ffffffffc02004da:	be3ff0ef          	jal	ra,ffffffffc02000bc <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004de:	780c                	ld	a1,48(s0)
ffffffffc02004e0:	00002517          	auipc	a0,0x2
ffffffffc02004e4:	be850513          	addi	a0,a0,-1048 # ffffffffc02020c8 <commands+0x3e0>
ffffffffc02004e8:	bd5ff0ef          	jal	ra,ffffffffc02000bc <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004ec:	7c0c                	ld	a1,56(s0)
ffffffffc02004ee:	00002517          	auipc	a0,0x2
ffffffffc02004f2:	bf250513          	addi	a0,a0,-1038 # ffffffffc02020e0 <commands+0x3f8>
ffffffffc02004f6:	bc7ff0ef          	jal	ra,ffffffffc02000bc <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004fa:	602c                	ld	a1,64(s0)
ffffffffc02004fc:	00002517          	auipc	a0,0x2
ffffffffc0200500:	bfc50513          	addi	a0,a0,-1028 # ffffffffc02020f8 <commands+0x410>
ffffffffc0200504:	bb9ff0ef          	jal	ra,ffffffffc02000bc <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200508:	642c                	ld	a1,72(s0)
ffffffffc020050a:	00002517          	auipc	a0,0x2
ffffffffc020050e:	c0650513          	addi	a0,a0,-1018 # ffffffffc0202110 <commands+0x428>
ffffffffc0200512:	babff0ef          	jal	ra,ffffffffc02000bc <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200516:	682c                	ld	a1,80(s0)
ffffffffc0200518:	00002517          	auipc	a0,0x2
ffffffffc020051c:	c1050513          	addi	a0,a0,-1008 # ffffffffc0202128 <commands+0x440>
ffffffffc0200520:	b9dff0ef          	jal	ra,ffffffffc02000bc <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200524:	6c2c                	ld	a1,88(s0)
ffffffffc0200526:	00002517          	auipc	a0,0x2
ffffffffc020052a:	c1a50513          	addi	a0,a0,-998 # ffffffffc0202140 <commands+0x458>
ffffffffc020052e:	b8fff0ef          	jal	ra,ffffffffc02000bc <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200532:	702c                	ld	a1,96(s0)
ffffffffc0200534:	00002517          	auipc	a0,0x2
ffffffffc0200538:	c2450513          	addi	a0,a0,-988 # ffffffffc0202158 <commands+0x470>
ffffffffc020053c:	b81ff0ef          	jal	ra,ffffffffc02000bc <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200540:	742c                	ld	a1,104(s0)
ffffffffc0200542:	00002517          	auipc	a0,0x2
ffffffffc0200546:	c2e50513          	addi	a0,a0,-978 # ffffffffc0202170 <commands+0x488>
ffffffffc020054a:	b73ff0ef          	jal	ra,ffffffffc02000bc <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020054e:	782c                	ld	a1,112(s0)
ffffffffc0200550:	00002517          	auipc	a0,0x2
ffffffffc0200554:	c3850513          	addi	a0,a0,-968 # ffffffffc0202188 <commands+0x4a0>
ffffffffc0200558:	b65ff0ef          	jal	ra,ffffffffc02000bc <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020055c:	7c2c                	ld	a1,120(s0)
ffffffffc020055e:	00002517          	auipc	a0,0x2
ffffffffc0200562:	c4250513          	addi	a0,a0,-958 # ffffffffc02021a0 <commands+0x4b8>
ffffffffc0200566:	b57ff0ef          	jal	ra,ffffffffc02000bc <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020056a:	604c                	ld	a1,128(s0)
ffffffffc020056c:	00002517          	auipc	a0,0x2
ffffffffc0200570:	c4c50513          	addi	a0,a0,-948 # ffffffffc02021b8 <commands+0x4d0>
ffffffffc0200574:	b49ff0ef          	jal	ra,ffffffffc02000bc <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200578:	644c                	ld	a1,136(s0)
ffffffffc020057a:	00002517          	auipc	a0,0x2
ffffffffc020057e:	c5650513          	addi	a0,a0,-938 # ffffffffc02021d0 <commands+0x4e8>
ffffffffc0200582:	b3bff0ef          	jal	ra,ffffffffc02000bc <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200586:	684c                	ld	a1,144(s0)
ffffffffc0200588:	00002517          	auipc	a0,0x2
ffffffffc020058c:	c6050513          	addi	a0,a0,-928 # ffffffffc02021e8 <commands+0x500>
ffffffffc0200590:	b2dff0ef          	jal	ra,ffffffffc02000bc <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200594:	6c4c                	ld	a1,152(s0)
ffffffffc0200596:	00002517          	auipc	a0,0x2
ffffffffc020059a:	c6a50513          	addi	a0,a0,-918 # ffffffffc0202200 <commands+0x518>
ffffffffc020059e:	b1fff0ef          	jal	ra,ffffffffc02000bc <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc02005a2:	704c                	ld	a1,160(s0)
ffffffffc02005a4:	00002517          	auipc	a0,0x2
ffffffffc02005a8:	c7450513          	addi	a0,a0,-908 # ffffffffc0202218 <commands+0x530>
ffffffffc02005ac:	b11ff0ef          	jal	ra,ffffffffc02000bc <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005b0:	744c                	ld	a1,168(s0)
ffffffffc02005b2:	00002517          	auipc	a0,0x2
ffffffffc02005b6:	c7e50513          	addi	a0,a0,-898 # ffffffffc0202230 <commands+0x548>
ffffffffc02005ba:	b03ff0ef          	jal	ra,ffffffffc02000bc <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005be:	784c                	ld	a1,176(s0)
ffffffffc02005c0:	00002517          	auipc	a0,0x2
ffffffffc02005c4:	c8850513          	addi	a0,a0,-888 # ffffffffc0202248 <commands+0x560>
ffffffffc02005c8:	af5ff0ef          	jal	ra,ffffffffc02000bc <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005cc:	7c4c                	ld	a1,184(s0)
ffffffffc02005ce:	00002517          	auipc	a0,0x2
ffffffffc02005d2:	c9250513          	addi	a0,a0,-878 # ffffffffc0202260 <commands+0x578>
ffffffffc02005d6:	ae7ff0ef          	jal	ra,ffffffffc02000bc <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005da:	606c                	ld	a1,192(s0)
ffffffffc02005dc:	00002517          	auipc	a0,0x2
ffffffffc02005e0:	c9c50513          	addi	a0,a0,-868 # ffffffffc0202278 <commands+0x590>
ffffffffc02005e4:	ad9ff0ef          	jal	ra,ffffffffc02000bc <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005e8:	646c                	ld	a1,200(s0)
ffffffffc02005ea:	00002517          	auipc	a0,0x2
ffffffffc02005ee:	ca650513          	addi	a0,a0,-858 # ffffffffc0202290 <commands+0x5a8>
ffffffffc02005f2:	acbff0ef          	jal	ra,ffffffffc02000bc <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005f6:	686c                	ld	a1,208(s0)
ffffffffc02005f8:	00002517          	auipc	a0,0x2
ffffffffc02005fc:	cb050513          	addi	a0,a0,-848 # ffffffffc02022a8 <commands+0x5c0>
ffffffffc0200600:	abdff0ef          	jal	ra,ffffffffc02000bc <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200604:	6c6c                	ld	a1,216(s0)
ffffffffc0200606:	00002517          	auipc	a0,0x2
ffffffffc020060a:	cba50513          	addi	a0,a0,-838 # ffffffffc02022c0 <commands+0x5d8>
ffffffffc020060e:	aafff0ef          	jal	ra,ffffffffc02000bc <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200612:	706c                	ld	a1,224(s0)
ffffffffc0200614:	00002517          	auipc	a0,0x2
ffffffffc0200618:	cc450513          	addi	a0,a0,-828 # ffffffffc02022d8 <commands+0x5f0>
ffffffffc020061c:	aa1ff0ef          	jal	ra,ffffffffc02000bc <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200620:	746c                	ld	a1,232(s0)
ffffffffc0200622:	00002517          	auipc	a0,0x2
ffffffffc0200626:	cce50513          	addi	a0,a0,-818 # ffffffffc02022f0 <commands+0x608>
ffffffffc020062a:	a93ff0ef          	jal	ra,ffffffffc02000bc <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc020062e:	786c                	ld	a1,240(s0)
ffffffffc0200630:	00002517          	auipc	a0,0x2
ffffffffc0200634:	cd850513          	addi	a0,a0,-808 # ffffffffc0202308 <commands+0x620>
ffffffffc0200638:	a85ff0ef          	jal	ra,ffffffffc02000bc <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020063c:	7c6c                	ld	a1,248(s0)
}
ffffffffc020063e:	6402                	ld	s0,0(sp)
ffffffffc0200640:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200642:	00002517          	auipc	a0,0x2
ffffffffc0200646:	cde50513          	addi	a0,a0,-802 # ffffffffc0202320 <commands+0x638>
}
ffffffffc020064a:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020064c:	a71ff06f          	j	ffffffffc02000bc <cprintf>

ffffffffc0200650 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200650:	1141                	addi	sp,sp,-16
ffffffffc0200652:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200654:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200656:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200658:	00002517          	auipc	a0,0x2
ffffffffc020065c:	ce050513          	addi	a0,a0,-800 # ffffffffc0202338 <commands+0x650>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200660:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200662:	a5bff0ef          	jal	ra,ffffffffc02000bc <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200666:	8522                	mv	a0,s0
ffffffffc0200668:	e1bff0ef          	jal	ra,ffffffffc0200482 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020066c:	10043583          	ld	a1,256(s0)
ffffffffc0200670:	00002517          	auipc	a0,0x2
ffffffffc0200674:	ce050513          	addi	a0,a0,-800 # ffffffffc0202350 <commands+0x668>
ffffffffc0200678:	a45ff0ef          	jal	ra,ffffffffc02000bc <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020067c:	10843583          	ld	a1,264(s0)
ffffffffc0200680:	00002517          	auipc	a0,0x2
ffffffffc0200684:	ce850513          	addi	a0,a0,-792 # ffffffffc0202368 <commands+0x680>
ffffffffc0200688:	a35ff0ef          	jal	ra,ffffffffc02000bc <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020068c:	11043583          	ld	a1,272(s0)
ffffffffc0200690:	00002517          	auipc	a0,0x2
ffffffffc0200694:	cf050513          	addi	a0,a0,-784 # ffffffffc0202380 <commands+0x698>
ffffffffc0200698:	a25ff0ef          	jal	ra,ffffffffc02000bc <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020069c:	11843583          	ld	a1,280(s0)
}
ffffffffc02006a0:	6402                	ld	s0,0(sp)
ffffffffc02006a2:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a4:	00002517          	auipc	a0,0x2
ffffffffc02006a8:	cf450513          	addi	a0,a0,-780 # ffffffffc0202398 <commands+0x6b0>
}
ffffffffc02006ac:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006ae:	a0fff06f          	j	ffffffffc02000bc <cprintf>

ffffffffc02006b2 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006b2:	11853783          	ld	a5,280(a0)
ffffffffc02006b6:	577d                	li	a4,-1
ffffffffc02006b8:	8305                	srli	a4,a4,0x1
ffffffffc02006ba:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02006bc:	472d                	li	a4,11
ffffffffc02006be:	08f76563          	bltu	a4,a5,ffffffffc0200748 <interrupt_handler+0x96>
ffffffffc02006c2:	00001717          	auipc	a4,0x1
ffffffffc02006c6:	7e270713          	addi	a4,a4,2018 # ffffffffc0201ea4 <commands+0x1bc>
ffffffffc02006ca:	078a                	slli	a5,a5,0x2
ffffffffc02006cc:	97ba                	add	a5,a5,a4
ffffffffc02006ce:	439c                	lw	a5,0(a5)
ffffffffc02006d0:	97ba                	add	a5,a5,a4
ffffffffc02006d2:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006d4:	00002517          	auipc	a0,0x2
ffffffffc02006d8:	8fc50513          	addi	a0,a0,-1796 # ffffffffc0201fd0 <commands+0x2e8>
ffffffffc02006dc:	9e1ff06f          	j	ffffffffc02000bc <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006e0:	00002517          	auipc	a0,0x2
ffffffffc02006e4:	8d050513          	addi	a0,a0,-1840 # ffffffffc0201fb0 <commands+0x2c8>
ffffffffc02006e8:	9d5ff06f          	j	ffffffffc02000bc <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006ec:	00002517          	auipc	a0,0x2
ffffffffc02006f0:	88450513          	addi	a0,a0,-1916 # ffffffffc0201f70 <commands+0x288>
ffffffffc02006f4:	9c9ff06f          	j	ffffffffc02000bc <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006f8:	00002517          	auipc	a0,0x2
ffffffffc02006fc:	8f850513          	addi	a0,a0,-1800 # ffffffffc0201ff0 <commands+0x308>
ffffffffc0200700:	9bdff06f          	j	ffffffffc02000bc <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200704:	1141                	addi	sp,sp,-16
ffffffffc0200706:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc0200708:	d3fff0ef          	jal	ra,ffffffffc0200446 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc020070c:	00006797          	auipc	a5,0x6
ffffffffc0200710:	d2c78793          	addi	a5,a5,-724 # ffffffffc0206438 <ticks>
ffffffffc0200714:	639c                	ld	a5,0(a5)
ffffffffc0200716:	06400713          	li	a4,100
ffffffffc020071a:	0785                	addi	a5,a5,1
ffffffffc020071c:	02e7f733          	remu	a4,a5,a4
ffffffffc0200720:	00006697          	auipc	a3,0x6
ffffffffc0200724:	d0f6bc23          	sd	a5,-744(a3) # ffffffffc0206438 <ticks>
ffffffffc0200728:	c315                	beqz	a4,ffffffffc020074c <interrupt_handler+0x9a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020072a:	60a2                	ld	ra,8(sp)
ffffffffc020072c:	0141                	addi	sp,sp,16
ffffffffc020072e:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200730:	00002517          	auipc	a0,0x2
ffffffffc0200734:	8e850513          	addi	a0,a0,-1816 # ffffffffc0202018 <commands+0x330>
ffffffffc0200738:	985ff06f          	j	ffffffffc02000bc <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc020073c:	00002517          	auipc	a0,0x2
ffffffffc0200740:	85450513          	addi	a0,a0,-1964 # ffffffffc0201f90 <commands+0x2a8>
ffffffffc0200744:	979ff06f          	j	ffffffffc02000bc <cprintf>
            print_trapframe(tf);
ffffffffc0200748:	f09ff06f          	j	ffffffffc0200650 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020074c:	06400593          	li	a1,100
ffffffffc0200750:	00002517          	auipc	a0,0x2
ffffffffc0200754:	8b850513          	addi	a0,a0,-1864 # ffffffffc0202008 <commands+0x320>
ffffffffc0200758:	965ff0ef          	jal	ra,ffffffffc02000bc <cprintf>
                PRINT_NUM++;
ffffffffc020075c:	00006797          	auipc	a5,0x6
ffffffffc0200760:	cc078793          	addi	a5,a5,-832 # ffffffffc020641c <PRINT_NUM>
ffffffffc0200764:	439c                	lw	a5,0(a5)
            	if(PRINT_NUM == 10){
ffffffffc0200766:	4729                	li	a4,10
                PRINT_NUM++;
ffffffffc0200768:	0017869b          	addiw	a3,a5,1
ffffffffc020076c:	00006617          	auipc	a2,0x6
ffffffffc0200770:	cad62823          	sw	a3,-848(a2) # ffffffffc020641c <PRINT_NUM>
            	if(PRINT_NUM == 10){
ffffffffc0200774:	fae69be3          	bne	a3,a4,ffffffffc020072a <interrupt_handler+0x78>
}
ffffffffc0200778:	60a2                	ld	ra,8(sp)
ffffffffc020077a:	0141                	addi	sp,sp,16
            	   sbi_shutdown();
ffffffffc020077c:	3aa0106f          	j	ffffffffc0201b26 <sbi_shutdown>

ffffffffc0200780 <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
ffffffffc0200780:	11853783          	ld	a5,280(a0)
ffffffffc0200784:	472d                	li	a4,11
ffffffffc0200786:	02f76863          	bltu	a4,a5,ffffffffc02007b6 <exception_handler+0x36>
ffffffffc020078a:	4705                	li	a4,1
ffffffffc020078c:	00f71733          	sll	a4,a4,a5
ffffffffc0200790:	6785                	lui	a5,0x1
ffffffffc0200792:	17cd                	addi	a5,a5,-13
ffffffffc0200794:	8ff9                	and	a5,a5,a4
ffffffffc0200796:	ef99                	bnez	a5,ffffffffc02007b4 <exception_handler+0x34>
void exception_handler(struct trapframe *tf) {
ffffffffc0200798:	1141                	addi	sp,sp,-16
ffffffffc020079a:	e022                	sd	s0,0(sp)
ffffffffc020079c:	e406                	sd	ra,8(sp)
ffffffffc020079e:	00877793          	andi	a5,a4,8
ffffffffc02007a2:	842a                	mv	s0,a0
ffffffffc02007a4:	e3b1                	bnez	a5,ffffffffc02007e8 <exception_handler+0x68>
ffffffffc02007a6:	8b11                	andi	a4,a4,4
ffffffffc02007a8:	eb09                	bnez	a4,ffffffffc02007ba <exception_handler+0x3a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc02007aa:	6402                	ld	s0,0(sp)
ffffffffc02007ac:	60a2                	ld	ra,8(sp)
ffffffffc02007ae:	0141                	addi	sp,sp,16
            print_trapframe(tf);
ffffffffc02007b0:	ea1ff06f          	j	ffffffffc0200650 <print_trapframe>
ffffffffc02007b4:	8082                	ret
ffffffffc02007b6:	e9bff06f          	j	ffffffffc0200650 <print_trapframe>
            cprintf("Exception type:Illegal instruction \n");
ffffffffc02007ba:	00001517          	auipc	a0,0x1
ffffffffc02007be:	71e50513          	addi	a0,a0,1822 # ffffffffc0201ed8 <commands+0x1f0>
ffffffffc02007c2:	8fbff0ef          	jal	ra,ffffffffc02000bc <cprintf>
            cprintf("Illegal instruction exception at 0x%016llx\n", tf->epc);//采用0x%016llx格式化字符串，用于打印16位十六进制数，这个位置是异常指令的地址,以tf->epc作为参数。
ffffffffc02007c6:	10843583          	ld	a1,264(s0)
ffffffffc02007ca:	00001517          	auipc	a0,0x1
ffffffffc02007ce:	73650513          	addi	a0,a0,1846 # ffffffffc0201f00 <commands+0x218>
ffffffffc02007d2:	8ebff0ef          	jal	ra,ffffffffc02000bc <cprintf>
            tf->epc += 4;//指令长度都为4个字节
ffffffffc02007d6:	10843783          	ld	a5,264(s0)
}
ffffffffc02007da:	60a2                	ld	ra,8(sp)
            tf->epc += 4;//指令长度都为4个字节
ffffffffc02007dc:	0791                	addi	a5,a5,4
ffffffffc02007de:	10f43423          	sd	a5,264(s0)
}
ffffffffc02007e2:	6402                	ld	s0,0(sp)
ffffffffc02007e4:	0141                	addi	sp,sp,16
ffffffffc02007e6:	8082                	ret
            cprintf("Exception type: breakpoint \n");
ffffffffc02007e8:	00001517          	auipc	a0,0x1
ffffffffc02007ec:	74850513          	addi	a0,a0,1864 # ffffffffc0201f30 <commands+0x248>
ffffffffc02007f0:	8cdff0ef          	jal	ra,ffffffffc02000bc <cprintf>
            cprintf("ebreak caught at 0x%016llx\n", tf->epc);
ffffffffc02007f4:	10843583          	ld	a1,264(s0)
ffffffffc02007f8:	00001517          	auipc	a0,0x1
ffffffffc02007fc:	75850513          	addi	a0,a0,1880 # ffffffffc0201f50 <commands+0x268>
ffffffffc0200800:	8bdff0ef          	jal	ra,ffffffffc02000bc <cprintf>
            tf->epc += 2;//ebreak指令长度为2个字节，为了4字节对齐
ffffffffc0200804:	10843783          	ld	a5,264(s0)
}
ffffffffc0200808:	60a2                	ld	ra,8(sp)
            tf->epc += 2;//ebreak指令长度为2个字节，为了4字节对齐
ffffffffc020080a:	0789                	addi	a5,a5,2
ffffffffc020080c:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200810:	6402                	ld	s0,0(sp)
ffffffffc0200812:	0141                	addi	sp,sp,16
ffffffffc0200814:	8082                	ret

ffffffffc0200816 <trap>:

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200816:	11853783          	ld	a5,280(a0)
ffffffffc020081a:	0007c463          	bltz	a5,ffffffffc0200822 <trap+0xc>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc020081e:	f63ff06f          	j	ffffffffc0200780 <exception_handler>
        interrupt_handler(tf);
ffffffffc0200822:	e91ff06f          	j	ffffffffc02006b2 <interrupt_handler>
	...

ffffffffc0200828 <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc0200828:	14011073          	csrw	sscratch,sp
ffffffffc020082c:	712d                	addi	sp,sp,-288
ffffffffc020082e:	e002                	sd	zero,0(sp)
ffffffffc0200830:	e406                	sd	ra,8(sp)
ffffffffc0200832:	ec0e                	sd	gp,24(sp)
ffffffffc0200834:	f012                	sd	tp,32(sp)
ffffffffc0200836:	f416                	sd	t0,40(sp)
ffffffffc0200838:	f81a                	sd	t1,48(sp)
ffffffffc020083a:	fc1e                	sd	t2,56(sp)
ffffffffc020083c:	e0a2                	sd	s0,64(sp)
ffffffffc020083e:	e4a6                	sd	s1,72(sp)
ffffffffc0200840:	e8aa                	sd	a0,80(sp)
ffffffffc0200842:	ecae                	sd	a1,88(sp)
ffffffffc0200844:	f0b2                	sd	a2,96(sp)
ffffffffc0200846:	f4b6                	sd	a3,104(sp)
ffffffffc0200848:	f8ba                	sd	a4,112(sp)
ffffffffc020084a:	fcbe                	sd	a5,120(sp)
ffffffffc020084c:	e142                	sd	a6,128(sp)
ffffffffc020084e:	e546                	sd	a7,136(sp)
ffffffffc0200850:	e94a                	sd	s2,144(sp)
ffffffffc0200852:	ed4e                	sd	s3,152(sp)
ffffffffc0200854:	f152                	sd	s4,160(sp)
ffffffffc0200856:	f556                	sd	s5,168(sp)
ffffffffc0200858:	f95a                	sd	s6,176(sp)
ffffffffc020085a:	fd5e                	sd	s7,184(sp)
ffffffffc020085c:	e1e2                	sd	s8,192(sp)
ffffffffc020085e:	e5e6                	sd	s9,200(sp)
ffffffffc0200860:	e9ea                	sd	s10,208(sp)
ffffffffc0200862:	edee                	sd	s11,216(sp)
ffffffffc0200864:	f1f2                	sd	t3,224(sp)
ffffffffc0200866:	f5f6                	sd	t4,232(sp)
ffffffffc0200868:	f9fa                	sd	t5,240(sp)
ffffffffc020086a:	fdfe                	sd	t6,248(sp)
ffffffffc020086c:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200870:	100024f3          	csrr	s1,sstatus
ffffffffc0200874:	14102973          	csrr	s2,sepc
ffffffffc0200878:	143029f3          	csrr	s3,stval
ffffffffc020087c:	14202a73          	csrr	s4,scause
ffffffffc0200880:	e822                	sd	s0,16(sp)
ffffffffc0200882:	e226                	sd	s1,256(sp)
ffffffffc0200884:	e64a                	sd	s2,264(sp)
ffffffffc0200886:	ea4e                	sd	s3,272(sp)
ffffffffc0200888:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc020088a:	850a                	mv	a0,sp
    jal trap
ffffffffc020088c:	f8bff0ef          	jal	ra,ffffffffc0200816 <trap>

ffffffffc0200890 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200890:	6492                	ld	s1,256(sp)
ffffffffc0200892:	6932                	ld	s2,264(sp)
ffffffffc0200894:	10049073          	csrw	sstatus,s1
ffffffffc0200898:	14191073          	csrw	sepc,s2
ffffffffc020089c:	60a2                	ld	ra,8(sp)
ffffffffc020089e:	61e2                	ld	gp,24(sp)
ffffffffc02008a0:	7202                	ld	tp,32(sp)
ffffffffc02008a2:	72a2                	ld	t0,40(sp)
ffffffffc02008a4:	7342                	ld	t1,48(sp)
ffffffffc02008a6:	73e2                	ld	t2,56(sp)
ffffffffc02008a8:	6406                	ld	s0,64(sp)
ffffffffc02008aa:	64a6                	ld	s1,72(sp)
ffffffffc02008ac:	6546                	ld	a0,80(sp)
ffffffffc02008ae:	65e6                	ld	a1,88(sp)
ffffffffc02008b0:	7606                	ld	a2,96(sp)
ffffffffc02008b2:	76a6                	ld	a3,104(sp)
ffffffffc02008b4:	7746                	ld	a4,112(sp)
ffffffffc02008b6:	77e6                	ld	a5,120(sp)
ffffffffc02008b8:	680a                	ld	a6,128(sp)
ffffffffc02008ba:	68aa                	ld	a7,136(sp)
ffffffffc02008bc:	694a                	ld	s2,144(sp)
ffffffffc02008be:	69ea                	ld	s3,152(sp)
ffffffffc02008c0:	7a0a                	ld	s4,160(sp)
ffffffffc02008c2:	7aaa                	ld	s5,168(sp)
ffffffffc02008c4:	7b4a                	ld	s6,176(sp)
ffffffffc02008c6:	7bea                	ld	s7,184(sp)
ffffffffc02008c8:	6c0e                	ld	s8,192(sp)
ffffffffc02008ca:	6cae                	ld	s9,200(sp)
ffffffffc02008cc:	6d4e                	ld	s10,208(sp)
ffffffffc02008ce:	6dee                	ld	s11,216(sp)
ffffffffc02008d0:	7e0e                	ld	t3,224(sp)
ffffffffc02008d2:	7eae                	ld	t4,232(sp)
ffffffffc02008d4:	7f4e                	ld	t5,240(sp)
ffffffffc02008d6:	7fee                	ld	t6,248(sp)
ffffffffc02008d8:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc02008da:	10200073          	sret

ffffffffc02008de <best_fit_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc02008de:	00006797          	auipc	a5,0x6
ffffffffc02008e2:	b6278793          	addi	a5,a5,-1182 # ffffffffc0206440 <free_area>
ffffffffc02008e6:	e79c                	sd	a5,8(a5)
ffffffffc02008e8:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
best_fit_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc02008ea:	0007a823          	sw	zero,16(a5)
}
ffffffffc02008ee:	8082                	ret

ffffffffc02008f0 <best_fit_nr_free_pages>:
}

static size_t
best_fit_nr_free_pages(void) {
    return nr_free;
}
ffffffffc02008f0:	00006517          	auipc	a0,0x6
ffffffffc02008f4:	b6056503          	lwu	a0,-1184(a0) # ffffffffc0206450 <free_area+0x10>
ffffffffc02008f8:	8082                	ret

ffffffffc02008fa <best_fit_alloc_pages>:
    assert(n > 0);
ffffffffc02008fa:	c15d                	beqz	a0,ffffffffc02009a0 <best_fit_alloc_pages+0xa6>
    if (n > nr_free) {
ffffffffc02008fc:	00006617          	auipc	a2,0x6
ffffffffc0200900:	b4460613          	addi	a2,a2,-1212 # ffffffffc0206440 <free_area>
ffffffffc0200904:	01062803          	lw	a6,16(a2)
ffffffffc0200908:	86aa                	mv	a3,a0
ffffffffc020090a:	02081793          	slli	a5,a6,0x20
ffffffffc020090e:	9381                	srli	a5,a5,0x20
ffffffffc0200910:	08a7e663          	bltu	a5,a0,ffffffffc020099c <best_fit_alloc_pages+0xa2>
    size_t min_size = nr_free + 1;
ffffffffc0200914:	0018059b          	addiw	a1,a6,1
ffffffffc0200918:	1582                	slli	a1,a1,0x20
ffffffffc020091a:	9181                	srli	a1,a1,0x20
    list_entry_t *le = &free_list;
ffffffffc020091c:	87b2                	mv	a5,a2
    struct Page *page = NULL;
ffffffffc020091e:	4501                	li	a0,0
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200920:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200922:	00c78e63          	beq	a5,a2,ffffffffc020093e <best_fit_alloc_pages+0x44>
        if (p->property >= n && p->property < min_size) {
ffffffffc0200926:	ff87e703          	lwu	a4,-8(a5)
ffffffffc020092a:	fed76be3          	bltu	a4,a3,ffffffffc0200920 <best_fit_alloc_pages+0x26>
ffffffffc020092e:	feb779e3          	bleu	a1,a4,ffffffffc0200920 <best_fit_alloc_pages+0x26>
        struct Page *p = le2page(le, page_link);
ffffffffc0200932:	fe878513          	addi	a0,a5,-24
ffffffffc0200936:	679c                	ld	a5,8(a5)
ffffffffc0200938:	85ba                	mv	a1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc020093a:	fec796e3          	bne	a5,a2,ffffffffc0200926 <best_fit_alloc_pages+0x2c>
    if (page != NULL) {
ffffffffc020093e:	c125                	beqz	a0,ffffffffc020099e <best_fit_alloc_pages+0xa4>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200940:	7118                	ld	a4,32(a0)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
ffffffffc0200942:	6d10                	ld	a2,24(a0)
        if (page->property > n) {
ffffffffc0200944:	490c                	lw	a1,16(a0)
ffffffffc0200946:	0006889b          	sext.w	a7,a3
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc020094a:	e618                	sd	a4,8(a2)
    next->prev = prev;
ffffffffc020094c:	e310                	sd	a2,0(a4)
ffffffffc020094e:	02059713          	slli	a4,a1,0x20
ffffffffc0200952:	9301                	srli	a4,a4,0x20
ffffffffc0200954:	02e6f863          	bleu	a4,a3,ffffffffc0200984 <best_fit_alloc_pages+0x8a>
            struct Page *p = page + n;
ffffffffc0200958:	00269713          	slli	a4,a3,0x2
ffffffffc020095c:	9736                	add	a4,a4,a3
ffffffffc020095e:	070e                	slli	a4,a4,0x3
ffffffffc0200960:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc0200962:	411585bb          	subw	a1,a1,a7
ffffffffc0200966:	cb0c                	sw	a1,16(a4)
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200968:	4689                	li	a3,2
ffffffffc020096a:	00870593          	addi	a1,a4,8
ffffffffc020096e:	40d5b02f          	amoor.d	zero,a3,(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200972:	6614                	ld	a3,8(a2)
            list_add(prev, &(p->page_link));
ffffffffc0200974:	01870593          	addi	a1,a4,24
    prev->next = next->prev = elm;
ffffffffc0200978:	0107a803          	lw	a6,16(a5)
ffffffffc020097c:	e28c                	sd	a1,0(a3)
ffffffffc020097e:	e60c                	sd	a1,8(a2)
    elm->next = next;
ffffffffc0200980:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc0200982:	ef10                	sd	a2,24(a4)
        nr_free -= n;
ffffffffc0200984:	4118083b          	subw	a6,a6,a7
ffffffffc0200988:	00006797          	auipc	a5,0x6
ffffffffc020098c:	ad07a423          	sw	a6,-1336(a5) # ffffffffc0206450 <free_area+0x10>
 * clear_bit - Atomically clears a bit in memory
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void clear_bit(int nr, volatile void *addr) {
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200990:	57f5                	li	a5,-3
ffffffffc0200992:	00850713          	addi	a4,a0,8
ffffffffc0200996:	60f7302f          	amoand.d	zero,a5,(a4)
ffffffffc020099a:	8082                	ret
        return NULL;
ffffffffc020099c:	4501                	li	a0,0
}
ffffffffc020099e:	8082                	ret
best_fit_alloc_pages(size_t n) {
ffffffffc02009a0:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02009a2:	00002697          	auipc	a3,0x2
ffffffffc02009a6:	a0e68693          	addi	a3,a3,-1522 # ffffffffc02023b0 <commands+0x6c8>
ffffffffc02009aa:	00002617          	auipc	a2,0x2
ffffffffc02009ae:	a0e60613          	addi	a2,a2,-1522 # ffffffffc02023b8 <commands+0x6d0>
ffffffffc02009b2:	06e00593          	li	a1,110
ffffffffc02009b6:	00002517          	auipc	a0,0x2
ffffffffc02009ba:	a1a50513          	addi	a0,a0,-1510 # ffffffffc02023d0 <commands+0x6e8>
best_fit_alloc_pages(size_t n) {
ffffffffc02009be:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02009c0:	9f3ff0ef          	jal	ra,ffffffffc02003b2 <__panic>

ffffffffc02009c4 <best_fit_check>:
}

// LAB2: below code is used to check the best fit allocation algorithm 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
best_fit_check(void) {
ffffffffc02009c4:	715d                	addi	sp,sp,-80
ffffffffc02009c6:	f84a                	sd	s2,48(sp)
    return listelm->next;
ffffffffc02009c8:	00006917          	auipc	s2,0x6
ffffffffc02009cc:	a7890913          	addi	s2,s2,-1416 # ffffffffc0206440 <free_area>
ffffffffc02009d0:	00893783          	ld	a5,8(s2)
ffffffffc02009d4:	e486                	sd	ra,72(sp)
ffffffffc02009d6:	e0a2                	sd	s0,64(sp)
ffffffffc02009d8:	fc26                	sd	s1,56(sp)
ffffffffc02009da:	f44e                	sd	s3,40(sp)
ffffffffc02009dc:	f052                	sd	s4,32(sp)
ffffffffc02009de:	ec56                	sd	s5,24(sp)
ffffffffc02009e0:	e85a                	sd	s6,16(sp)
ffffffffc02009e2:	e45e                	sd	s7,8(sp)
ffffffffc02009e4:	e062                	sd	s8,0(sp)
    int score = 0 ,sumscore = 6;
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc02009e6:	2d278363          	beq	a5,s2,ffffffffc0200cac <best_fit_check+0x2e8>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02009ea:	ff07b703          	ld	a4,-16(a5)
ffffffffc02009ee:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc02009f0:	8b05                	andi	a4,a4,1
ffffffffc02009f2:	2c070163          	beqz	a4,ffffffffc0200cb4 <best_fit_check+0x2f0>
    int count = 0, total = 0;
ffffffffc02009f6:	4401                	li	s0,0
ffffffffc02009f8:	4481                	li	s1,0
ffffffffc02009fa:	a031                	j	ffffffffc0200a06 <best_fit_check+0x42>
ffffffffc02009fc:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0200a00:	8b09                	andi	a4,a4,2
ffffffffc0200a02:	2a070963          	beqz	a4,ffffffffc0200cb4 <best_fit_check+0x2f0>
        count ++, total += p->property;
ffffffffc0200a06:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200a0a:	679c                	ld	a5,8(a5)
ffffffffc0200a0c:	2485                	addiw	s1,s1,1
ffffffffc0200a0e:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200a10:	ff2796e3          	bne	a5,s2,ffffffffc02009fc <best_fit_check+0x38>
ffffffffc0200a14:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0200a16:	217000ef          	jal	ra,ffffffffc020142c <nr_free_pages>
ffffffffc0200a1a:	37351d63          	bne	a0,s3,ffffffffc0200d94 <best_fit_check+0x3d0>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200a1e:	4505                	li	a0,1
ffffffffc0200a20:	183000ef          	jal	ra,ffffffffc02013a2 <alloc_pages>
ffffffffc0200a24:	8a2a                	mv	s4,a0
ffffffffc0200a26:	3a050763          	beqz	a0,ffffffffc0200dd4 <best_fit_check+0x410>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200a2a:	4505                	li	a0,1
ffffffffc0200a2c:	177000ef          	jal	ra,ffffffffc02013a2 <alloc_pages>
ffffffffc0200a30:	89aa                	mv	s3,a0
ffffffffc0200a32:	38050163          	beqz	a0,ffffffffc0200db4 <best_fit_check+0x3f0>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200a36:	4505                	li	a0,1
ffffffffc0200a38:	16b000ef          	jal	ra,ffffffffc02013a2 <alloc_pages>
ffffffffc0200a3c:	8aaa                	mv	s5,a0
ffffffffc0200a3e:	30050b63          	beqz	a0,ffffffffc0200d54 <best_fit_check+0x390>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200a42:	293a0963          	beq	s4,s3,ffffffffc0200cd4 <best_fit_check+0x310>
ffffffffc0200a46:	28aa0763          	beq	s4,a0,ffffffffc0200cd4 <best_fit_check+0x310>
ffffffffc0200a4a:	28a98563          	beq	s3,a0,ffffffffc0200cd4 <best_fit_check+0x310>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200a4e:	000a2783          	lw	a5,0(s4)
ffffffffc0200a52:	2a079163          	bnez	a5,ffffffffc0200cf4 <best_fit_check+0x330>
ffffffffc0200a56:	0009a783          	lw	a5,0(s3)
ffffffffc0200a5a:	28079d63          	bnez	a5,ffffffffc0200cf4 <best_fit_check+0x330>
ffffffffc0200a5e:	411c                	lw	a5,0(a0)
ffffffffc0200a60:	28079a63          	bnez	a5,ffffffffc0200cf4 <best_fit_check+0x330>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200a64:	00006797          	auipc	a5,0x6
ffffffffc0200a68:	a0c78793          	addi	a5,a5,-1524 # ffffffffc0206470 <pages>
ffffffffc0200a6c:	639c                	ld	a5,0(a5)
ffffffffc0200a6e:	00002717          	auipc	a4,0x2
ffffffffc0200a72:	97a70713          	addi	a4,a4,-1670 # ffffffffc02023e8 <commands+0x700>
ffffffffc0200a76:	630c                	ld	a1,0(a4)
ffffffffc0200a78:	40fa0733          	sub	a4,s4,a5
ffffffffc0200a7c:	870d                	srai	a4,a4,0x3
ffffffffc0200a7e:	02b70733          	mul	a4,a4,a1
ffffffffc0200a82:	00002697          	auipc	a3,0x2
ffffffffc0200a86:	02668693          	addi	a3,a3,38 # ffffffffc0202aa8 <nbase>
ffffffffc0200a8a:	6290                	ld	a2,0(a3)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200a8c:	00006697          	auipc	a3,0x6
ffffffffc0200a90:	99468693          	addi	a3,a3,-1644 # ffffffffc0206420 <npage>
ffffffffc0200a94:	6294                	ld	a3,0(a3)
ffffffffc0200a96:	06b2                	slli	a3,a3,0xc
ffffffffc0200a98:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200a9a:	0732                	slli	a4,a4,0xc
ffffffffc0200a9c:	26d77c63          	bleu	a3,a4,ffffffffc0200d14 <best_fit_check+0x350>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200aa0:	40f98733          	sub	a4,s3,a5
ffffffffc0200aa4:	870d                	srai	a4,a4,0x3
ffffffffc0200aa6:	02b70733          	mul	a4,a4,a1
ffffffffc0200aaa:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200aac:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200aae:	42d77363          	bleu	a3,a4,ffffffffc0200ed4 <best_fit_check+0x510>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200ab2:	40f507b3          	sub	a5,a0,a5
ffffffffc0200ab6:	878d                	srai	a5,a5,0x3
ffffffffc0200ab8:	02b787b3          	mul	a5,a5,a1
ffffffffc0200abc:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200abe:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200ac0:	3ed7fa63          	bleu	a3,a5,ffffffffc0200eb4 <best_fit_check+0x4f0>
    assert(alloc_page() == NULL);
ffffffffc0200ac4:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200ac6:	00093c03          	ld	s8,0(s2)
ffffffffc0200aca:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200ace:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200ad2:	00006797          	auipc	a5,0x6
ffffffffc0200ad6:	9727bb23          	sd	s2,-1674(a5) # ffffffffc0206448 <free_area+0x8>
ffffffffc0200ada:	00006797          	auipc	a5,0x6
ffffffffc0200ade:	9727b323          	sd	s2,-1690(a5) # ffffffffc0206440 <free_area>
    nr_free = 0;
ffffffffc0200ae2:	00006797          	auipc	a5,0x6
ffffffffc0200ae6:	9607a723          	sw	zero,-1682(a5) # ffffffffc0206450 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200aea:	0b9000ef          	jal	ra,ffffffffc02013a2 <alloc_pages>
ffffffffc0200aee:	3a051363          	bnez	a0,ffffffffc0200e94 <best_fit_check+0x4d0>
    free_page(p0);
ffffffffc0200af2:	4585                	li	a1,1
ffffffffc0200af4:	8552                	mv	a0,s4
ffffffffc0200af6:	0f1000ef          	jal	ra,ffffffffc02013e6 <free_pages>
    free_page(p1);
ffffffffc0200afa:	4585                	li	a1,1
ffffffffc0200afc:	854e                	mv	a0,s3
ffffffffc0200afe:	0e9000ef          	jal	ra,ffffffffc02013e6 <free_pages>
    free_page(p2);
ffffffffc0200b02:	4585                	li	a1,1
ffffffffc0200b04:	8556                	mv	a0,s5
ffffffffc0200b06:	0e1000ef          	jal	ra,ffffffffc02013e6 <free_pages>
    assert(nr_free == 3);
ffffffffc0200b0a:	01092703          	lw	a4,16(s2)
ffffffffc0200b0e:	478d                	li	a5,3
ffffffffc0200b10:	36f71263          	bne	a4,a5,ffffffffc0200e74 <best_fit_check+0x4b0>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200b14:	4505                	li	a0,1
ffffffffc0200b16:	08d000ef          	jal	ra,ffffffffc02013a2 <alloc_pages>
ffffffffc0200b1a:	89aa                	mv	s3,a0
ffffffffc0200b1c:	32050c63          	beqz	a0,ffffffffc0200e54 <best_fit_check+0x490>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200b20:	4505                	li	a0,1
ffffffffc0200b22:	081000ef          	jal	ra,ffffffffc02013a2 <alloc_pages>
ffffffffc0200b26:	8aaa                	mv	s5,a0
ffffffffc0200b28:	30050663          	beqz	a0,ffffffffc0200e34 <best_fit_check+0x470>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200b2c:	4505                	li	a0,1
ffffffffc0200b2e:	075000ef          	jal	ra,ffffffffc02013a2 <alloc_pages>
ffffffffc0200b32:	8a2a                	mv	s4,a0
ffffffffc0200b34:	2e050063          	beqz	a0,ffffffffc0200e14 <best_fit_check+0x450>
    assert(alloc_page() == NULL);
ffffffffc0200b38:	4505                	li	a0,1
ffffffffc0200b3a:	069000ef          	jal	ra,ffffffffc02013a2 <alloc_pages>
ffffffffc0200b3e:	2a051b63          	bnez	a0,ffffffffc0200df4 <best_fit_check+0x430>
    free_page(p0);
ffffffffc0200b42:	4585                	li	a1,1
ffffffffc0200b44:	854e                	mv	a0,s3
ffffffffc0200b46:	0a1000ef          	jal	ra,ffffffffc02013e6 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200b4a:	00893783          	ld	a5,8(s2)
ffffffffc0200b4e:	1f278363          	beq	a5,s2,ffffffffc0200d34 <best_fit_check+0x370>
    assert((p = alloc_page()) == p0);
ffffffffc0200b52:	4505                	li	a0,1
ffffffffc0200b54:	04f000ef          	jal	ra,ffffffffc02013a2 <alloc_pages>
ffffffffc0200b58:	54a99e63          	bne	s3,a0,ffffffffc02010b4 <best_fit_check+0x6f0>
    assert(alloc_page() == NULL);
ffffffffc0200b5c:	4505                	li	a0,1
ffffffffc0200b5e:	045000ef          	jal	ra,ffffffffc02013a2 <alloc_pages>
ffffffffc0200b62:	52051963          	bnez	a0,ffffffffc0201094 <best_fit_check+0x6d0>
    assert(nr_free == 0);
ffffffffc0200b66:	01092783          	lw	a5,16(s2)
ffffffffc0200b6a:	50079563          	bnez	a5,ffffffffc0201074 <best_fit_check+0x6b0>
    free_page(p);
ffffffffc0200b6e:	854e                	mv	a0,s3
ffffffffc0200b70:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200b72:	00006797          	auipc	a5,0x6
ffffffffc0200b76:	8d87b723          	sd	s8,-1842(a5) # ffffffffc0206440 <free_area>
ffffffffc0200b7a:	00006797          	auipc	a5,0x6
ffffffffc0200b7e:	8d77b723          	sd	s7,-1842(a5) # ffffffffc0206448 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0200b82:	00006797          	auipc	a5,0x6
ffffffffc0200b86:	8d67a723          	sw	s6,-1842(a5) # ffffffffc0206450 <free_area+0x10>
    free_page(p);
ffffffffc0200b8a:	05d000ef          	jal	ra,ffffffffc02013e6 <free_pages>
    free_page(p1);
ffffffffc0200b8e:	4585                	li	a1,1
ffffffffc0200b90:	8556                	mv	a0,s5
ffffffffc0200b92:	055000ef          	jal	ra,ffffffffc02013e6 <free_pages>
    free_page(p2);
ffffffffc0200b96:	4585                	li	a1,1
ffffffffc0200b98:	8552                	mv	a0,s4
ffffffffc0200b9a:	04d000ef          	jal	ra,ffffffffc02013e6 <free_pages>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200b9e:	4515                	li	a0,5
ffffffffc0200ba0:	003000ef          	jal	ra,ffffffffc02013a2 <alloc_pages>
ffffffffc0200ba4:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200ba6:	4a050763          	beqz	a0,ffffffffc0201054 <best_fit_check+0x690>
ffffffffc0200baa:	651c                	ld	a5,8(a0)
ffffffffc0200bac:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200bae:	8b85                	andi	a5,a5,1
ffffffffc0200bb0:	48079263          	bnez	a5,ffffffffc0201034 <best_fit_check+0x670>
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200bb4:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200bb6:	00093b03          	ld	s6,0(s2)
ffffffffc0200bba:	00893a83          	ld	s5,8(s2)
ffffffffc0200bbe:	00006797          	auipc	a5,0x6
ffffffffc0200bc2:	8927b123          	sd	s2,-1918(a5) # ffffffffc0206440 <free_area>
ffffffffc0200bc6:	00006797          	auipc	a5,0x6
ffffffffc0200bca:	8927b123          	sd	s2,-1918(a5) # ffffffffc0206448 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0200bce:	7d4000ef          	jal	ra,ffffffffc02013a2 <alloc_pages>
ffffffffc0200bd2:	44051163          	bnez	a0,ffffffffc0201014 <best_fit_check+0x650>
    #endif
    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    // * - - * -
    free_pages(p0 + 1, 2);
ffffffffc0200bd6:	4589                	li	a1,2
ffffffffc0200bd8:	02898513          	addi	a0,s3,40
    unsigned int nr_free_store = nr_free;
ffffffffc0200bdc:	01092b83          	lw	s7,16(s2)
    free_pages(p0 + 4, 1);
ffffffffc0200be0:	0a098c13          	addi	s8,s3,160
    nr_free = 0;
ffffffffc0200be4:	00006797          	auipc	a5,0x6
ffffffffc0200be8:	8607a623          	sw	zero,-1940(a5) # ffffffffc0206450 <free_area+0x10>
    free_pages(p0 + 1, 2);
ffffffffc0200bec:	7fa000ef          	jal	ra,ffffffffc02013e6 <free_pages>
    free_pages(p0 + 4, 1);
ffffffffc0200bf0:	8562                	mv	a0,s8
ffffffffc0200bf2:	4585                	li	a1,1
ffffffffc0200bf4:	7f2000ef          	jal	ra,ffffffffc02013e6 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200bf8:	4511                	li	a0,4
ffffffffc0200bfa:	7a8000ef          	jal	ra,ffffffffc02013a2 <alloc_pages>
ffffffffc0200bfe:	3e051b63          	bnez	a0,ffffffffc0200ff4 <best_fit_check+0x630>
ffffffffc0200c02:	0309b783          	ld	a5,48(s3)
ffffffffc0200c06:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200c08:	8b85                	andi	a5,a5,1
ffffffffc0200c0a:	3c078563          	beqz	a5,ffffffffc0200fd4 <best_fit_check+0x610>
ffffffffc0200c0e:	0389a703          	lw	a4,56(s3)
ffffffffc0200c12:	4789                	li	a5,2
ffffffffc0200c14:	3cf71063          	bne	a4,a5,ffffffffc0200fd4 <best_fit_check+0x610>
    // * - - * *
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200c18:	4505                	li	a0,1
ffffffffc0200c1a:	788000ef          	jal	ra,ffffffffc02013a2 <alloc_pages>
ffffffffc0200c1e:	8a2a                	mv	s4,a0
ffffffffc0200c20:	38050a63          	beqz	a0,ffffffffc0200fb4 <best_fit_check+0x5f0>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200c24:	4509                	li	a0,2
ffffffffc0200c26:	77c000ef          	jal	ra,ffffffffc02013a2 <alloc_pages>
ffffffffc0200c2a:	36050563          	beqz	a0,ffffffffc0200f94 <best_fit_check+0x5d0>
    assert(p0 + 4 == p1);
ffffffffc0200c2e:	354c1363          	bne	s8,s4,ffffffffc0200f74 <best_fit_check+0x5b0>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    p2 = p0 + 1;
    free_pages(p0, 5);
ffffffffc0200c32:	854e                	mv	a0,s3
ffffffffc0200c34:	4595                	li	a1,5
ffffffffc0200c36:	7b0000ef          	jal	ra,ffffffffc02013e6 <free_pages>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200c3a:	4515                	li	a0,5
ffffffffc0200c3c:	766000ef          	jal	ra,ffffffffc02013a2 <alloc_pages>
ffffffffc0200c40:	89aa                	mv	s3,a0
ffffffffc0200c42:	30050963          	beqz	a0,ffffffffc0200f54 <best_fit_check+0x590>
    assert(alloc_page() == NULL);
ffffffffc0200c46:	4505                	li	a0,1
ffffffffc0200c48:	75a000ef          	jal	ra,ffffffffc02013a2 <alloc_pages>
ffffffffc0200c4c:	2e051463          	bnez	a0,ffffffffc0200f34 <best_fit_check+0x570>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    assert(nr_free == 0);
ffffffffc0200c50:	01092783          	lw	a5,16(s2)
ffffffffc0200c54:	2c079063          	bnez	a5,ffffffffc0200f14 <best_fit_check+0x550>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200c58:	4595                	li	a1,5
ffffffffc0200c5a:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200c5c:	00005797          	auipc	a5,0x5
ffffffffc0200c60:	7f77aa23          	sw	s7,2036(a5) # ffffffffc0206450 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0200c64:	00005797          	auipc	a5,0x5
ffffffffc0200c68:	7d67be23          	sd	s6,2012(a5) # ffffffffc0206440 <free_area>
ffffffffc0200c6c:	00005797          	auipc	a5,0x5
ffffffffc0200c70:	7d57be23          	sd	s5,2012(a5) # ffffffffc0206448 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0200c74:	772000ef          	jal	ra,ffffffffc02013e6 <free_pages>
    return listelm->next;
ffffffffc0200c78:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200c7c:	01278963          	beq	a5,s2,ffffffffc0200c8e <best_fit_check+0x2ca>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200c80:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200c84:	679c                	ld	a5,8(a5)
ffffffffc0200c86:	34fd                	addiw	s1,s1,-1
ffffffffc0200c88:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200c8a:	ff279be3          	bne	a5,s2,ffffffffc0200c80 <best_fit_check+0x2bc>
    }
    assert(count == 0);
ffffffffc0200c8e:	26049363          	bnez	s1,ffffffffc0200ef4 <best_fit_check+0x530>
    assert(total == 0);
ffffffffc0200c92:	e06d                	bnez	s0,ffffffffc0200d74 <best_fit_check+0x3b0>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
}
ffffffffc0200c94:	60a6                	ld	ra,72(sp)
ffffffffc0200c96:	6406                	ld	s0,64(sp)
ffffffffc0200c98:	74e2                	ld	s1,56(sp)
ffffffffc0200c9a:	7942                	ld	s2,48(sp)
ffffffffc0200c9c:	79a2                	ld	s3,40(sp)
ffffffffc0200c9e:	7a02                	ld	s4,32(sp)
ffffffffc0200ca0:	6ae2                	ld	s5,24(sp)
ffffffffc0200ca2:	6b42                	ld	s6,16(sp)
ffffffffc0200ca4:	6ba2                	ld	s7,8(sp)
ffffffffc0200ca6:	6c02                	ld	s8,0(sp)
ffffffffc0200ca8:	6161                	addi	sp,sp,80
ffffffffc0200caa:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200cac:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200cae:	4401                	li	s0,0
ffffffffc0200cb0:	4481                	li	s1,0
ffffffffc0200cb2:	b395                	j	ffffffffc0200a16 <best_fit_check+0x52>
        assert(PageProperty(p));
ffffffffc0200cb4:	00001697          	auipc	a3,0x1
ffffffffc0200cb8:	73c68693          	addi	a3,a3,1852 # ffffffffc02023f0 <commands+0x708>
ffffffffc0200cbc:	00001617          	auipc	a2,0x1
ffffffffc0200cc0:	6fc60613          	addi	a2,a2,1788 # ffffffffc02023b8 <commands+0x6d0>
ffffffffc0200cc4:	11400593          	li	a1,276
ffffffffc0200cc8:	00001517          	auipc	a0,0x1
ffffffffc0200ccc:	70850513          	addi	a0,a0,1800 # ffffffffc02023d0 <commands+0x6e8>
ffffffffc0200cd0:	ee2ff0ef          	jal	ra,ffffffffc02003b2 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200cd4:	00001697          	auipc	a3,0x1
ffffffffc0200cd8:	7ac68693          	addi	a3,a3,1964 # ffffffffc0202480 <commands+0x798>
ffffffffc0200cdc:	00001617          	auipc	a2,0x1
ffffffffc0200ce0:	6dc60613          	addi	a2,a2,1756 # ffffffffc02023b8 <commands+0x6d0>
ffffffffc0200ce4:	0e000593          	li	a1,224
ffffffffc0200ce8:	00001517          	auipc	a0,0x1
ffffffffc0200cec:	6e850513          	addi	a0,a0,1768 # ffffffffc02023d0 <commands+0x6e8>
ffffffffc0200cf0:	ec2ff0ef          	jal	ra,ffffffffc02003b2 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200cf4:	00001697          	auipc	a3,0x1
ffffffffc0200cf8:	7b468693          	addi	a3,a3,1972 # ffffffffc02024a8 <commands+0x7c0>
ffffffffc0200cfc:	00001617          	auipc	a2,0x1
ffffffffc0200d00:	6bc60613          	addi	a2,a2,1724 # ffffffffc02023b8 <commands+0x6d0>
ffffffffc0200d04:	0e100593          	li	a1,225
ffffffffc0200d08:	00001517          	auipc	a0,0x1
ffffffffc0200d0c:	6c850513          	addi	a0,a0,1736 # ffffffffc02023d0 <commands+0x6e8>
ffffffffc0200d10:	ea2ff0ef          	jal	ra,ffffffffc02003b2 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200d14:	00001697          	auipc	a3,0x1
ffffffffc0200d18:	7d468693          	addi	a3,a3,2004 # ffffffffc02024e8 <commands+0x800>
ffffffffc0200d1c:	00001617          	auipc	a2,0x1
ffffffffc0200d20:	69c60613          	addi	a2,a2,1692 # ffffffffc02023b8 <commands+0x6d0>
ffffffffc0200d24:	0e300593          	li	a1,227
ffffffffc0200d28:	00001517          	auipc	a0,0x1
ffffffffc0200d2c:	6a850513          	addi	a0,a0,1704 # ffffffffc02023d0 <commands+0x6e8>
ffffffffc0200d30:	e82ff0ef          	jal	ra,ffffffffc02003b2 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200d34:	00002697          	auipc	a3,0x2
ffffffffc0200d38:	83c68693          	addi	a3,a3,-1988 # ffffffffc0202570 <commands+0x888>
ffffffffc0200d3c:	00001617          	auipc	a2,0x1
ffffffffc0200d40:	67c60613          	addi	a2,a2,1660 # ffffffffc02023b8 <commands+0x6d0>
ffffffffc0200d44:	0fc00593          	li	a1,252
ffffffffc0200d48:	00001517          	auipc	a0,0x1
ffffffffc0200d4c:	68850513          	addi	a0,a0,1672 # ffffffffc02023d0 <commands+0x6e8>
ffffffffc0200d50:	e62ff0ef          	jal	ra,ffffffffc02003b2 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200d54:	00001697          	auipc	a3,0x1
ffffffffc0200d58:	70c68693          	addi	a3,a3,1804 # ffffffffc0202460 <commands+0x778>
ffffffffc0200d5c:	00001617          	auipc	a2,0x1
ffffffffc0200d60:	65c60613          	addi	a2,a2,1628 # ffffffffc02023b8 <commands+0x6d0>
ffffffffc0200d64:	0de00593          	li	a1,222
ffffffffc0200d68:	00001517          	auipc	a0,0x1
ffffffffc0200d6c:	66850513          	addi	a0,a0,1640 # ffffffffc02023d0 <commands+0x6e8>
ffffffffc0200d70:	e42ff0ef          	jal	ra,ffffffffc02003b2 <__panic>
    assert(total == 0);
ffffffffc0200d74:	00002697          	auipc	a3,0x2
ffffffffc0200d78:	92c68693          	addi	a3,a3,-1748 # ffffffffc02026a0 <commands+0x9b8>
ffffffffc0200d7c:	00001617          	auipc	a2,0x1
ffffffffc0200d80:	63c60613          	addi	a2,a2,1596 # ffffffffc02023b8 <commands+0x6d0>
ffffffffc0200d84:	15600593          	li	a1,342
ffffffffc0200d88:	00001517          	auipc	a0,0x1
ffffffffc0200d8c:	64850513          	addi	a0,a0,1608 # ffffffffc02023d0 <commands+0x6e8>
ffffffffc0200d90:	e22ff0ef          	jal	ra,ffffffffc02003b2 <__panic>
    assert(total == nr_free_pages());
ffffffffc0200d94:	00001697          	auipc	a3,0x1
ffffffffc0200d98:	66c68693          	addi	a3,a3,1644 # ffffffffc0202400 <commands+0x718>
ffffffffc0200d9c:	00001617          	auipc	a2,0x1
ffffffffc0200da0:	61c60613          	addi	a2,a2,1564 # ffffffffc02023b8 <commands+0x6d0>
ffffffffc0200da4:	11700593          	li	a1,279
ffffffffc0200da8:	00001517          	auipc	a0,0x1
ffffffffc0200dac:	62850513          	addi	a0,a0,1576 # ffffffffc02023d0 <commands+0x6e8>
ffffffffc0200db0:	e02ff0ef          	jal	ra,ffffffffc02003b2 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200db4:	00001697          	auipc	a3,0x1
ffffffffc0200db8:	68c68693          	addi	a3,a3,1676 # ffffffffc0202440 <commands+0x758>
ffffffffc0200dbc:	00001617          	auipc	a2,0x1
ffffffffc0200dc0:	5fc60613          	addi	a2,a2,1532 # ffffffffc02023b8 <commands+0x6d0>
ffffffffc0200dc4:	0dd00593          	li	a1,221
ffffffffc0200dc8:	00001517          	auipc	a0,0x1
ffffffffc0200dcc:	60850513          	addi	a0,a0,1544 # ffffffffc02023d0 <commands+0x6e8>
ffffffffc0200dd0:	de2ff0ef          	jal	ra,ffffffffc02003b2 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200dd4:	00001697          	auipc	a3,0x1
ffffffffc0200dd8:	64c68693          	addi	a3,a3,1612 # ffffffffc0202420 <commands+0x738>
ffffffffc0200ddc:	00001617          	auipc	a2,0x1
ffffffffc0200de0:	5dc60613          	addi	a2,a2,1500 # ffffffffc02023b8 <commands+0x6d0>
ffffffffc0200de4:	0dc00593          	li	a1,220
ffffffffc0200de8:	00001517          	auipc	a0,0x1
ffffffffc0200dec:	5e850513          	addi	a0,a0,1512 # ffffffffc02023d0 <commands+0x6e8>
ffffffffc0200df0:	dc2ff0ef          	jal	ra,ffffffffc02003b2 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200df4:	00001697          	auipc	a3,0x1
ffffffffc0200df8:	75468693          	addi	a3,a3,1876 # ffffffffc0202548 <commands+0x860>
ffffffffc0200dfc:	00001617          	auipc	a2,0x1
ffffffffc0200e00:	5bc60613          	addi	a2,a2,1468 # ffffffffc02023b8 <commands+0x6d0>
ffffffffc0200e04:	0f900593          	li	a1,249
ffffffffc0200e08:	00001517          	auipc	a0,0x1
ffffffffc0200e0c:	5c850513          	addi	a0,a0,1480 # ffffffffc02023d0 <commands+0x6e8>
ffffffffc0200e10:	da2ff0ef          	jal	ra,ffffffffc02003b2 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200e14:	00001697          	auipc	a3,0x1
ffffffffc0200e18:	64c68693          	addi	a3,a3,1612 # ffffffffc0202460 <commands+0x778>
ffffffffc0200e1c:	00001617          	auipc	a2,0x1
ffffffffc0200e20:	59c60613          	addi	a2,a2,1436 # ffffffffc02023b8 <commands+0x6d0>
ffffffffc0200e24:	0f700593          	li	a1,247
ffffffffc0200e28:	00001517          	auipc	a0,0x1
ffffffffc0200e2c:	5a850513          	addi	a0,a0,1448 # ffffffffc02023d0 <commands+0x6e8>
ffffffffc0200e30:	d82ff0ef          	jal	ra,ffffffffc02003b2 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200e34:	00001697          	auipc	a3,0x1
ffffffffc0200e38:	60c68693          	addi	a3,a3,1548 # ffffffffc0202440 <commands+0x758>
ffffffffc0200e3c:	00001617          	auipc	a2,0x1
ffffffffc0200e40:	57c60613          	addi	a2,a2,1404 # ffffffffc02023b8 <commands+0x6d0>
ffffffffc0200e44:	0f600593          	li	a1,246
ffffffffc0200e48:	00001517          	auipc	a0,0x1
ffffffffc0200e4c:	58850513          	addi	a0,a0,1416 # ffffffffc02023d0 <commands+0x6e8>
ffffffffc0200e50:	d62ff0ef          	jal	ra,ffffffffc02003b2 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200e54:	00001697          	auipc	a3,0x1
ffffffffc0200e58:	5cc68693          	addi	a3,a3,1484 # ffffffffc0202420 <commands+0x738>
ffffffffc0200e5c:	00001617          	auipc	a2,0x1
ffffffffc0200e60:	55c60613          	addi	a2,a2,1372 # ffffffffc02023b8 <commands+0x6d0>
ffffffffc0200e64:	0f500593          	li	a1,245
ffffffffc0200e68:	00001517          	auipc	a0,0x1
ffffffffc0200e6c:	56850513          	addi	a0,a0,1384 # ffffffffc02023d0 <commands+0x6e8>
ffffffffc0200e70:	d42ff0ef          	jal	ra,ffffffffc02003b2 <__panic>
    assert(nr_free == 3);
ffffffffc0200e74:	00001697          	auipc	a3,0x1
ffffffffc0200e78:	6ec68693          	addi	a3,a3,1772 # ffffffffc0202560 <commands+0x878>
ffffffffc0200e7c:	00001617          	auipc	a2,0x1
ffffffffc0200e80:	53c60613          	addi	a2,a2,1340 # ffffffffc02023b8 <commands+0x6d0>
ffffffffc0200e84:	0f300593          	li	a1,243
ffffffffc0200e88:	00001517          	auipc	a0,0x1
ffffffffc0200e8c:	54850513          	addi	a0,a0,1352 # ffffffffc02023d0 <commands+0x6e8>
ffffffffc0200e90:	d22ff0ef          	jal	ra,ffffffffc02003b2 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200e94:	00001697          	auipc	a3,0x1
ffffffffc0200e98:	6b468693          	addi	a3,a3,1716 # ffffffffc0202548 <commands+0x860>
ffffffffc0200e9c:	00001617          	auipc	a2,0x1
ffffffffc0200ea0:	51c60613          	addi	a2,a2,1308 # ffffffffc02023b8 <commands+0x6d0>
ffffffffc0200ea4:	0ee00593          	li	a1,238
ffffffffc0200ea8:	00001517          	auipc	a0,0x1
ffffffffc0200eac:	52850513          	addi	a0,a0,1320 # ffffffffc02023d0 <commands+0x6e8>
ffffffffc0200eb0:	d02ff0ef          	jal	ra,ffffffffc02003b2 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200eb4:	00001697          	auipc	a3,0x1
ffffffffc0200eb8:	67468693          	addi	a3,a3,1652 # ffffffffc0202528 <commands+0x840>
ffffffffc0200ebc:	00001617          	auipc	a2,0x1
ffffffffc0200ec0:	4fc60613          	addi	a2,a2,1276 # ffffffffc02023b8 <commands+0x6d0>
ffffffffc0200ec4:	0e500593          	li	a1,229
ffffffffc0200ec8:	00001517          	auipc	a0,0x1
ffffffffc0200ecc:	50850513          	addi	a0,a0,1288 # ffffffffc02023d0 <commands+0x6e8>
ffffffffc0200ed0:	ce2ff0ef          	jal	ra,ffffffffc02003b2 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200ed4:	00001697          	auipc	a3,0x1
ffffffffc0200ed8:	63468693          	addi	a3,a3,1588 # ffffffffc0202508 <commands+0x820>
ffffffffc0200edc:	00001617          	auipc	a2,0x1
ffffffffc0200ee0:	4dc60613          	addi	a2,a2,1244 # ffffffffc02023b8 <commands+0x6d0>
ffffffffc0200ee4:	0e400593          	li	a1,228
ffffffffc0200ee8:	00001517          	auipc	a0,0x1
ffffffffc0200eec:	4e850513          	addi	a0,a0,1256 # ffffffffc02023d0 <commands+0x6e8>
ffffffffc0200ef0:	cc2ff0ef          	jal	ra,ffffffffc02003b2 <__panic>
    assert(count == 0);
ffffffffc0200ef4:	00001697          	auipc	a3,0x1
ffffffffc0200ef8:	79c68693          	addi	a3,a3,1948 # ffffffffc0202690 <commands+0x9a8>
ffffffffc0200efc:	00001617          	auipc	a2,0x1
ffffffffc0200f00:	4bc60613          	addi	a2,a2,1212 # ffffffffc02023b8 <commands+0x6d0>
ffffffffc0200f04:	15500593          	li	a1,341
ffffffffc0200f08:	00001517          	auipc	a0,0x1
ffffffffc0200f0c:	4c850513          	addi	a0,a0,1224 # ffffffffc02023d0 <commands+0x6e8>
ffffffffc0200f10:	ca2ff0ef          	jal	ra,ffffffffc02003b2 <__panic>
    assert(nr_free == 0);
ffffffffc0200f14:	00001697          	auipc	a3,0x1
ffffffffc0200f18:	69468693          	addi	a3,a3,1684 # ffffffffc02025a8 <commands+0x8c0>
ffffffffc0200f1c:	00001617          	auipc	a2,0x1
ffffffffc0200f20:	49c60613          	addi	a2,a2,1180 # ffffffffc02023b8 <commands+0x6d0>
ffffffffc0200f24:	14a00593          	li	a1,330
ffffffffc0200f28:	00001517          	auipc	a0,0x1
ffffffffc0200f2c:	4a850513          	addi	a0,a0,1192 # ffffffffc02023d0 <commands+0x6e8>
ffffffffc0200f30:	c82ff0ef          	jal	ra,ffffffffc02003b2 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f34:	00001697          	auipc	a3,0x1
ffffffffc0200f38:	61468693          	addi	a3,a3,1556 # ffffffffc0202548 <commands+0x860>
ffffffffc0200f3c:	00001617          	auipc	a2,0x1
ffffffffc0200f40:	47c60613          	addi	a2,a2,1148 # ffffffffc02023b8 <commands+0x6d0>
ffffffffc0200f44:	14400593          	li	a1,324
ffffffffc0200f48:	00001517          	auipc	a0,0x1
ffffffffc0200f4c:	48850513          	addi	a0,a0,1160 # ffffffffc02023d0 <commands+0x6e8>
ffffffffc0200f50:	c62ff0ef          	jal	ra,ffffffffc02003b2 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200f54:	00001697          	auipc	a3,0x1
ffffffffc0200f58:	71c68693          	addi	a3,a3,1820 # ffffffffc0202670 <commands+0x988>
ffffffffc0200f5c:	00001617          	auipc	a2,0x1
ffffffffc0200f60:	45c60613          	addi	a2,a2,1116 # ffffffffc02023b8 <commands+0x6d0>
ffffffffc0200f64:	14300593          	li	a1,323
ffffffffc0200f68:	00001517          	auipc	a0,0x1
ffffffffc0200f6c:	46850513          	addi	a0,a0,1128 # ffffffffc02023d0 <commands+0x6e8>
ffffffffc0200f70:	c42ff0ef          	jal	ra,ffffffffc02003b2 <__panic>
    assert(p0 + 4 == p1);
ffffffffc0200f74:	00001697          	auipc	a3,0x1
ffffffffc0200f78:	6ec68693          	addi	a3,a3,1772 # ffffffffc0202660 <commands+0x978>
ffffffffc0200f7c:	00001617          	auipc	a2,0x1
ffffffffc0200f80:	43c60613          	addi	a2,a2,1084 # ffffffffc02023b8 <commands+0x6d0>
ffffffffc0200f84:	13b00593          	li	a1,315
ffffffffc0200f88:	00001517          	auipc	a0,0x1
ffffffffc0200f8c:	44850513          	addi	a0,a0,1096 # ffffffffc02023d0 <commands+0x6e8>
ffffffffc0200f90:	c22ff0ef          	jal	ra,ffffffffc02003b2 <__panic>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200f94:	00001697          	auipc	a3,0x1
ffffffffc0200f98:	6b468693          	addi	a3,a3,1716 # ffffffffc0202648 <commands+0x960>
ffffffffc0200f9c:	00001617          	auipc	a2,0x1
ffffffffc0200fa0:	41c60613          	addi	a2,a2,1052 # ffffffffc02023b8 <commands+0x6d0>
ffffffffc0200fa4:	13a00593          	li	a1,314
ffffffffc0200fa8:	00001517          	auipc	a0,0x1
ffffffffc0200fac:	42850513          	addi	a0,a0,1064 # ffffffffc02023d0 <commands+0x6e8>
ffffffffc0200fb0:	c02ff0ef          	jal	ra,ffffffffc02003b2 <__panic>
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200fb4:	00001697          	auipc	a3,0x1
ffffffffc0200fb8:	67468693          	addi	a3,a3,1652 # ffffffffc0202628 <commands+0x940>
ffffffffc0200fbc:	00001617          	auipc	a2,0x1
ffffffffc0200fc0:	3fc60613          	addi	a2,a2,1020 # ffffffffc02023b8 <commands+0x6d0>
ffffffffc0200fc4:	13900593          	li	a1,313
ffffffffc0200fc8:	00001517          	auipc	a0,0x1
ffffffffc0200fcc:	40850513          	addi	a0,a0,1032 # ffffffffc02023d0 <commands+0x6e8>
ffffffffc0200fd0:	be2ff0ef          	jal	ra,ffffffffc02003b2 <__panic>
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200fd4:	00001697          	auipc	a3,0x1
ffffffffc0200fd8:	62468693          	addi	a3,a3,1572 # ffffffffc02025f8 <commands+0x910>
ffffffffc0200fdc:	00001617          	auipc	a2,0x1
ffffffffc0200fe0:	3dc60613          	addi	a2,a2,988 # ffffffffc02023b8 <commands+0x6d0>
ffffffffc0200fe4:	13700593          	li	a1,311
ffffffffc0200fe8:	00001517          	auipc	a0,0x1
ffffffffc0200fec:	3e850513          	addi	a0,a0,1000 # ffffffffc02023d0 <commands+0x6e8>
ffffffffc0200ff0:	bc2ff0ef          	jal	ra,ffffffffc02003b2 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0200ff4:	00001697          	auipc	a3,0x1
ffffffffc0200ff8:	5ec68693          	addi	a3,a3,1516 # ffffffffc02025e0 <commands+0x8f8>
ffffffffc0200ffc:	00001617          	auipc	a2,0x1
ffffffffc0201000:	3bc60613          	addi	a2,a2,956 # ffffffffc02023b8 <commands+0x6d0>
ffffffffc0201004:	13600593          	li	a1,310
ffffffffc0201008:	00001517          	auipc	a0,0x1
ffffffffc020100c:	3c850513          	addi	a0,a0,968 # ffffffffc02023d0 <commands+0x6e8>
ffffffffc0201010:	ba2ff0ef          	jal	ra,ffffffffc02003b2 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201014:	00001697          	auipc	a3,0x1
ffffffffc0201018:	53468693          	addi	a3,a3,1332 # ffffffffc0202548 <commands+0x860>
ffffffffc020101c:	00001617          	auipc	a2,0x1
ffffffffc0201020:	39c60613          	addi	a2,a2,924 # ffffffffc02023b8 <commands+0x6d0>
ffffffffc0201024:	12a00593          	li	a1,298
ffffffffc0201028:	00001517          	auipc	a0,0x1
ffffffffc020102c:	3a850513          	addi	a0,a0,936 # ffffffffc02023d0 <commands+0x6e8>
ffffffffc0201030:	b82ff0ef          	jal	ra,ffffffffc02003b2 <__panic>
    assert(!PageProperty(p0));
ffffffffc0201034:	00001697          	auipc	a3,0x1
ffffffffc0201038:	59468693          	addi	a3,a3,1428 # ffffffffc02025c8 <commands+0x8e0>
ffffffffc020103c:	00001617          	auipc	a2,0x1
ffffffffc0201040:	37c60613          	addi	a2,a2,892 # ffffffffc02023b8 <commands+0x6d0>
ffffffffc0201044:	12100593          	li	a1,289
ffffffffc0201048:	00001517          	auipc	a0,0x1
ffffffffc020104c:	38850513          	addi	a0,a0,904 # ffffffffc02023d0 <commands+0x6e8>
ffffffffc0201050:	b62ff0ef          	jal	ra,ffffffffc02003b2 <__panic>
    assert(p0 != NULL);
ffffffffc0201054:	00001697          	auipc	a3,0x1
ffffffffc0201058:	56468693          	addi	a3,a3,1380 # ffffffffc02025b8 <commands+0x8d0>
ffffffffc020105c:	00001617          	auipc	a2,0x1
ffffffffc0201060:	35c60613          	addi	a2,a2,860 # ffffffffc02023b8 <commands+0x6d0>
ffffffffc0201064:	12000593          	li	a1,288
ffffffffc0201068:	00001517          	auipc	a0,0x1
ffffffffc020106c:	36850513          	addi	a0,a0,872 # ffffffffc02023d0 <commands+0x6e8>
ffffffffc0201070:	b42ff0ef          	jal	ra,ffffffffc02003b2 <__panic>
    assert(nr_free == 0);
ffffffffc0201074:	00001697          	auipc	a3,0x1
ffffffffc0201078:	53468693          	addi	a3,a3,1332 # ffffffffc02025a8 <commands+0x8c0>
ffffffffc020107c:	00001617          	auipc	a2,0x1
ffffffffc0201080:	33c60613          	addi	a2,a2,828 # ffffffffc02023b8 <commands+0x6d0>
ffffffffc0201084:	10200593          	li	a1,258
ffffffffc0201088:	00001517          	auipc	a0,0x1
ffffffffc020108c:	34850513          	addi	a0,a0,840 # ffffffffc02023d0 <commands+0x6e8>
ffffffffc0201090:	b22ff0ef          	jal	ra,ffffffffc02003b2 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201094:	00001697          	auipc	a3,0x1
ffffffffc0201098:	4b468693          	addi	a3,a3,1204 # ffffffffc0202548 <commands+0x860>
ffffffffc020109c:	00001617          	auipc	a2,0x1
ffffffffc02010a0:	31c60613          	addi	a2,a2,796 # ffffffffc02023b8 <commands+0x6d0>
ffffffffc02010a4:	10000593          	li	a1,256
ffffffffc02010a8:	00001517          	auipc	a0,0x1
ffffffffc02010ac:	32850513          	addi	a0,a0,808 # ffffffffc02023d0 <commands+0x6e8>
ffffffffc02010b0:	b02ff0ef          	jal	ra,ffffffffc02003b2 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc02010b4:	00001697          	auipc	a3,0x1
ffffffffc02010b8:	4d468693          	addi	a3,a3,1236 # ffffffffc0202588 <commands+0x8a0>
ffffffffc02010bc:	00001617          	auipc	a2,0x1
ffffffffc02010c0:	2fc60613          	addi	a2,a2,764 # ffffffffc02023b8 <commands+0x6d0>
ffffffffc02010c4:	0ff00593          	li	a1,255
ffffffffc02010c8:	00001517          	auipc	a0,0x1
ffffffffc02010cc:	30850513          	addi	a0,a0,776 # ffffffffc02023d0 <commands+0x6e8>
ffffffffc02010d0:	ae2ff0ef          	jal	ra,ffffffffc02003b2 <__panic>

ffffffffc02010d4 <best_fit_free_pages>:
best_fit_free_pages(struct Page *base, size_t n) {
ffffffffc02010d4:	1141                	addi	sp,sp,-16
ffffffffc02010d6:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02010d8:	1a058063          	beqz	a1,ffffffffc0201278 <best_fit_free_pages+0x1a4>
    for (; p != base + n; p ++) {
ffffffffc02010dc:	00259693          	slli	a3,a1,0x2
ffffffffc02010e0:	96ae                	add	a3,a3,a1
ffffffffc02010e2:	068e                	slli	a3,a3,0x3
ffffffffc02010e4:	96aa                	add	a3,a3,a0
ffffffffc02010e6:	02d50d63          	beq	a0,a3,ffffffffc0201120 <best_fit_free_pages+0x4c>
ffffffffc02010ea:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02010ec:	8b85                	andi	a5,a5,1
ffffffffc02010ee:	16079563          	bnez	a5,ffffffffc0201258 <best_fit_free_pages+0x184>
ffffffffc02010f2:	651c                	ld	a5,8(a0)
ffffffffc02010f4:	8385                	srli	a5,a5,0x1
ffffffffc02010f6:	8b85                	andi	a5,a5,1
ffffffffc02010f8:	16079063          	bnez	a5,ffffffffc0201258 <best_fit_free_pages+0x184>
ffffffffc02010fc:	87aa                	mv	a5,a0
ffffffffc02010fe:	a809                	j	ffffffffc0201110 <best_fit_free_pages+0x3c>
ffffffffc0201100:	6798                	ld	a4,8(a5)
ffffffffc0201102:	8b05                	andi	a4,a4,1
ffffffffc0201104:	14071a63          	bnez	a4,ffffffffc0201258 <best_fit_free_pages+0x184>
ffffffffc0201108:	6798                	ld	a4,8(a5)
ffffffffc020110a:	8b09                	andi	a4,a4,2
ffffffffc020110c:	14071663          	bnez	a4,ffffffffc0201258 <best_fit_free_pages+0x184>
        p->flags = 0;
ffffffffc0201110:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201114:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201118:	02878793          	addi	a5,a5,40
ffffffffc020111c:	fed792e3          	bne	a5,a3,ffffffffc0201100 <best_fit_free_pages+0x2c>
    base->property = n;
ffffffffc0201120:	2581                	sext.w	a1,a1
ffffffffc0201122:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0201124:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201128:	4789                	li	a5,2
ffffffffc020112a:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc020112e:	00005697          	auipc	a3,0x5
ffffffffc0201132:	31268693          	addi	a3,a3,786 # ffffffffc0206440 <free_area>
ffffffffc0201136:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201138:	669c                	ld	a5,8(a3)
ffffffffc020113a:	9db9                	addw	a1,a1,a4
ffffffffc020113c:	00005717          	auipc	a4,0x5
ffffffffc0201140:	30b72a23          	sw	a1,788(a4) # ffffffffc0206450 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0201144:	0ed78163          	beq	a5,a3,ffffffffc0201226 <best_fit_free_pages+0x152>
            struct Page* page = le2page(le, page_link);
ffffffffc0201148:	fe878713          	addi	a4,a5,-24
ffffffffc020114c:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020114e:	4801                	li	a6,0
ffffffffc0201150:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0201154:	00e56a63          	bltu	a0,a4,ffffffffc0201168 <best_fit_free_pages+0x94>
    return listelm->next;
ffffffffc0201158:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020115a:	06d70563          	beq	a4,a3,ffffffffc02011c4 <best_fit_free_pages+0xf0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc020115e:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201160:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201164:	fee57ae3          	bleu	a4,a0,ffffffffc0201158 <best_fit_free_pages+0x84>
ffffffffc0201168:	00080663          	beqz	a6,ffffffffc0201174 <best_fit_free_pages+0xa0>
ffffffffc020116c:	00005817          	auipc	a6,0x5
ffffffffc0201170:	2cb83a23          	sd	a1,724(a6) # ffffffffc0206440 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201174:	638c                	ld	a1,0(a5)
    prev->next = next->prev = elm;
ffffffffc0201176:	e390                	sd	a2,0(a5)
ffffffffc0201178:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc020117a:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020117c:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc020117e:	08d58663          	beq	a1,a3,ffffffffc020120a <best_fit_free_pages+0x136>
        if ((unsigned int)(base - p) == p->property){
ffffffffc0201182:	00001617          	auipc	a2,0x1
ffffffffc0201186:	26660613          	addi	a2,a2,614 # ffffffffc02023e8 <commands+0x700>
ffffffffc020118a:	6210                	ld	a2,0(a2)
        p = le2page(le, page_link);
ffffffffc020118c:	fe858713          	addi	a4,a1,-24
        if ((unsigned int)(base - p) == p->property){
ffffffffc0201190:	40e507b3          	sub	a5,a0,a4
ffffffffc0201194:	878d                	srai	a5,a5,0x3
ffffffffc0201196:	02c787bb          	mulw	a5,a5,a2
ffffffffc020119a:	ff85a603          	lw	a2,-8(a1)
ffffffffc020119e:	06c79163          	bne	a5,a2,ffffffffc0201200 <best_fit_free_pages+0x12c>
            p->property += base->property;
ffffffffc02011a2:	4910                	lw	a2,16(a0)
ffffffffc02011a4:	9fb1                	addw	a5,a5,a2
ffffffffc02011a6:	fef5ac23          	sw	a5,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02011aa:	57f5                	li	a5,-3
ffffffffc02011ac:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02011b0:	01853803          	ld	a6,24(a0)
ffffffffc02011b4:	7110                	ld	a2,32(a0)
            base = p;
ffffffffc02011b6:	853a                	mv	a0,a4
    prev->next = next;
ffffffffc02011b8:	00c83423          	sd	a2,8(a6)
    next->prev = prev;
ffffffffc02011bc:	659c                	ld	a5,8(a1)
ffffffffc02011be:	01063023          	sd	a6,0(a2)
ffffffffc02011c2:	a081                	j	ffffffffc0201202 <best_fit_free_pages+0x12e>
    prev->next = next->prev = elm;
ffffffffc02011c4:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02011c6:	f114                	sd	a3,32(a0)
ffffffffc02011c8:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02011ca:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc02011cc:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02011ce:	00d70563          	beq	a4,a3,ffffffffc02011d8 <best_fit_free_pages+0x104>
ffffffffc02011d2:	4805                	li	a6,1
ffffffffc02011d4:	87ba                	mv	a5,a4
ffffffffc02011d6:	b769                	j	ffffffffc0201160 <best_fit_free_pages+0x8c>
ffffffffc02011d8:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc02011da:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc02011dc:	02d78363          	beq	a5,a3,ffffffffc0201202 <best_fit_free_pages+0x12e>
        if ((unsigned int)(base - p) == p->property){
ffffffffc02011e0:	00001617          	auipc	a2,0x1
ffffffffc02011e4:	20860613          	addi	a2,a2,520 # ffffffffc02023e8 <commands+0x700>
ffffffffc02011e8:	6210                	ld	a2,0(a2)
        p = le2page(le, page_link);
ffffffffc02011ea:	fe858713          	addi	a4,a1,-24
        if ((unsigned int)(base - p) == p->property){
ffffffffc02011ee:	40e507b3          	sub	a5,a0,a4
ffffffffc02011f2:	878d                	srai	a5,a5,0x3
ffffffffc02011f4:	02c787bb          	mulw	a5,a5,a2
ffffffffc02011f8:	ff85a603          	lw	a2,-8(a1)
ffffffffc02011fc:	fac783e3          	beq	a5,a2,ffffffffc02011a2 <best_fit_free_pages+0xce>
ffffffffc0201200:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0201202:	fe878713          	addi	a4,a5,-24
ffffffffc0201206:	00d78d63          	beq	a5,a3,ffffffffc0201220 <best_fit_free_pages+0x14c>
        if (base + base->property == p) {
ffffffffc020120a:	490c                	lw	a1,16(a0)
ffffffffc020120c:	02059613          	slli	a2,a1,0x20
ffffffffc0201210:	9201                	srli	a2,a2,0x20
ffffffffc0201212:	00261693          	slli	a3,a2,0x2
ffffffffc0201216:	96b2                	add	a3,a3,a2
ffffffffc0201218:	068e                	slli	a3,a3,0x3
ffffffffc020121a:	96aa                	add	a3,a3,a0
ffffffffc020121c:	00d70e63          	beq	a4,a3,ffffffffc0201238 <best_fit_free_pages+0x164>
}
ffffffffc0201220:	60a2                	ld	ra,8(sp)
ffffffffc0201222:	0141                	addi	sp,sp,16
ffffffffc0201224:	8082                	ret
ffffffffc0201226:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201228:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc020122c:	e398                	sd	a4,0(a5)
ffffffffc020122e:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201230:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201232:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201234:	0141                	addi	sp,sp,16
ffffffffc0201236:	8082                	ret
            base->property += p->property;
ffffffffc0201238:	ff87a703          	lw	a4,-8(a5)
ffffffffc020123c:	ff078693          	addi	a3,a5,-16
ffffffffc0201240:	9db9                	addw	a1,a1,a4
ffffffffc0201242:	c90c                	sw	a1,16(a0)
ffffffffc0201244:	5775                	li	a4,-3
ffffffffc0201246:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020124a:	6398                	ld	a4,0(a5)
ffffffffc020124c:	679c                	ld	a5,8(a5)
}
ffffffffc020124e:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201250:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201252:	e398                	sd	a4,0(a5)
ffffffffc0201254:	0141                	addi	sp,sp,16
ffffffffc0201256:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201258:	00001697          	auipc	a3,0x1
ffffffffc020125c:	45868693          	addi	a3,a3,1112 # ffffffffc02026b0 <commands+0x9c8>
ffffffffc0201260:	00001617          	auipc	a2,0x1
ffffffffc0201264:	15860613          	addi	a2,a2,344 # ffffffffc02023b8 <commands+0x6d0>
ffffffffc0201268:	09800593          	li	a1,152
ffffffffc020126c:	00001517          	auipc	a0,0x1
ffffffffc0201270:	16450513          	addi	a0,a0,356 # ffffffffc02023d0 <commands+0x6e8>
ffffffffc0201274:	93eff0ef          	jal	ra,ffffffffc02003b2 <__panic>
    assert(n > 0);
ffffffffc0201278:	00001697          	auipc	a3,0x1
ffffffffc020127c:	13868693          	addi	a3,a3,312 # ffffffffc02023b0 <commands+0x6c8>
ffffffffc0201280:	00001617          	auipc	a2,0x1
ffffffffc0201284:	13860613          	addi	a2,a2,312 # ffffffffc02023b8 <commands+0x6d0>
ffffffffc0201288:	09500593          	li	a1,149
ffffffffc020128c:	00001517          	auipc	a0,0x1
ffffffffc0201290:	14450513          	addi	a0,a0,324 # ffffffffc02023d0 <commands+0x6e8>
ffffffffc0201294:	91eff0ef          	jal	ra,ffffffffc02003b2 <__panic>

ffffffffc0201298 <best_fit_init_memmap>:
best_fit_init_memmap(struct Page *base, size_t n) {
ffffffffc0201298:	1141                	addi	sp,sp,-16
ffffffffc020129a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020129c:	c1fd                	beqz	a1,ffffffffc0201382 <best_fit_init_memmap+0xea>
    for (; p != base + n; p ++) {
ffffffffc020129e:	00259693          	slli	a3,a1,0x2
ffffffffc02012a2:	96ae                	add	a3,a3,a1
ffffffffc02012a4:	068e                	slli	a3,a3,0x3
ffffffffc02012a6:	96aa                	add	a3,a3,a0
ffffffffc02012a8:	02d50463          	beq	a0,a3,ffffffffc02012d0 <best_fit_init_memmap+0x38>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02012ac:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc02012ae:	87aa                	mv	a5,a0
ffffffffc02012b0:	8b05                	andi	a4,a4,1
ffffffffc02012b2:	e709                	bnez	a4,ffffffffc02012bc <best_fit_init_memmap+0x24>
ffffffffc02012b4:	a07d                	j	ffffffffc0201362 <best_fit_init_memmap+0xca>
ffffffffc02012b6:	6798                	ld	a4,8(a5)
ffffffffc02012b8:	8b05                	andi	a4,a4,1
ffffffffc02012ba:	c745                	beqz	a4,ffffffffc0201362 <best_fit_init_memmap+0xca>
        p->flags = p->property = 0;
ffffffffc02012bc:	0007a823          	sw	zero,16(a5)
ffffffffc02012c0:	0007b423          	sd	zero,8(a5)
ffffffffc02012c4:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02012c8:	02878793          	addi	a5,a5,40
ffffffffc02012cc:	fed795e3          	bne	a5,a3,ffffffffc02012b6 <best_fit_init_memmap+0x1e>
    base->property = n;
ffffffffc02012d0:	2581                	sext.w	a1,a1
ffffffffc02012d2:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02012d4:	4789                	li	a5,2
ffffffffc02012d6:	00850713          	addi	a4,a0,8
ffffffffc02012da:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02012de:	00005697          	auipc	a3,0x5
ffffffffc02012e2:	16268693          	addi	a3,a3,354 # ffffffffc0206440 <free_area>
ffffffffc02012e6:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02012e8:	669c                	ld	a5,8(a3)
ffffffffc02012ea:	9db9                	addw	a1,a1,a4
ffffffffc02012ec:	00005717          	auipc	a4,0x5
ffffffffc02012f0:	16b72223          	sw	a1,356(a4) # ffffffffc0206450 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02012f4:	04d78a63          	beq	a5,a3,ffffffffc0201348 <best_fit_init_memmap+0xb0>
            struct Page* page = le2page(le, page_link);
ffffffffc02012f8:	fe878713          	addi	a4,a5,-24
ffffffffc02012fc:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02012fe:	4801                	li	a6,0
ffffffffc0201300:	01850613          	addi	a2,a0,24
            if (base < page){
ffffffffc0201304:	00e56a63          	bltu	a0,a4,ffffffffc0201318 <best_fit_init_memmap+0x80>
    return listelm->next;
ffffffffc0201308:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list){
ffffffffc020130a:	02d70563          	beq	a4,a3,ffffffffc0201334 <best_fit_init_memmap+0x9c>
        while ((le = list_next(le)) != &free_list) {
ffffffffc020130e:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201310:	fe878713          	addi	a4,a5,-24
            if (base < page){
ffffffffc0201314:	fee57ae3          	bleu	a4,a0,ffffffffc0201308 <best_fit_init_memmap+0x70>
ffffffffc0201318:	00080663          	beqz	a6,ffffffffc0201324 <best_fit_init_memmap+0x8c>
ffffffffc020131c:	00005717          	auipc	a4,0x5
ffffffffc0201320:	12b73223          	sd	a1,292(a4) # ffffffffc0206440 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201324:	6398                	ld	a4,0(a5)
}
ffffffffc0201326:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201328:	e390                	sd	a2,0(a5)
ffffffffc020132a:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020132c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020132e:	ed18                	sd	a4,24(a0)
ffffffffc0201330:	0141                	addi	sp,sp,16
ffffffffc0201332:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201334:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201336:	f114                	sd	a3,32(a0)
ffffffffc0201338:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020133a:	ed1c                	sd	a5,24(a0)
                list_add_after(le, &(base->page_link));
ffffffffc020133c:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc020133e:	00d70e63          	beq	a4,a3,ffffffffc020135a <best_fit_init_memmap+0xc2>
ffffffffc0201342:	4805                	li	a6,1
ffffffffc0201344:	87ba                	mv	a5,a4
ffffffffc0201346:	b7e9                	j	ffffffffc0201310 <best_fit_init_memmap+0x78>
}
ffffffffc0201348:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc020134a:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc020134e:	e398                	sd	a4,0(a5)
ffffffffc0201350:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201352:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201354:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201356:	0141                	addi	sp,sp,16
ffffffffc0201358:	8082                	ret
ffffffffc020135a:	60a2                	ld	ra,8(sp)
ffffffffc020135c:	e290                	sd	a2,0(a3)
ffffffffc020135e:	0141                	addi	sp,sp,16
ffffffffc0201360:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201362:	00001697          	auipc	a3,0x1
ffffffffc0201366:	37668693          	addi	a3,a3,886 # ffffffffc02026d8 <commands+0x9f0>
ffffffffc020136a:	00001617          	auipc	a2,0x1
ffffffffc020136e:	04e60613          	addi	a2,a2,78 # ffffffffc02023b8 <commands+0x6d0>
ffffffffc0201372:	04a00593          	li	a1,74
ffffffffc0201376:	00001517          	auipc	a0,0x1
ffffffffc020137a:	05a50513          	addi	a0,a0,90 # ffffffffc02023d0 <commands+0x6e8>
ffffffffc020137e:	834ff0ef          	jal	ra,ffffffffc02003b2 <__panic>
    assert(n > 0);
ffffffffc0201382:	00001697          	auipc	a3,0x1
ffffffffc0201386:	02e68693          	addi	a3,a3,46 # ffffffffc02023b0 <commands+0x6c8>
ffffffffc020138a:	00001617          	auipc	a2,0x1
ffffffffc020138e:	02e60613          	addi	a2,a2,46 # ffffffffc02023b8 <commands+0x6d0>
ffffffffc0201392:	04700593          	li	a1,71
ffffffffc0201396:	00001517          	auipc	a0,0x1
ffffffffc020139a:	03a50513          	addi	a0,a0,58 # ffffffffc02023d0 <commands+0x6e8>
ffffffffc020139e:	814ff0ef          	jal	ra,ffffffffc02003b2 <__panic>

ffffffffc02013a2 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02013a2:	100027f3          	csrr	a5,sstatus
ffffffffc02013a6:	8b89                	andi	a5,a5,2
ffffffffc02013a8:	eb89                	bnez	a5,ffffffffc02013ba <alloc_pages+0x18>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc02013aa:	00005797          	auipc	a5,0x5
ffffffffc02013ae:	0b678793          	addi	a5,a5,182 # ffffffffc0206460 <pmm_manager>
ffffffffc02013b2:	639c                	ld	a5,0(a5)
ffffffffc02013b4:	0187b303          	ld	t1,24(a5)
ffffffffc02013b8:	8302                	jr	t1
struct Page *alloc_pages(size_t n) {
ffffffffc02013ba:	1141                	addi	sp,sp,-16
ffffffffc02013bc:	e406                	sd	ra,8(sp)
ffffffffc02013be:	e022                	sd	s0,0(sp)
ffffffffc02013c0:	842a                	mv	s0,a0
        intr_disable();
ffffffffc02013c2:	8a8ff0ef          	jal	ra,ffffffffc020046a <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02013c6:	00005797          	auipc	a5,0x5
ffffffffc02013ca:	09a78793          	addi	a5,a5,154 # ffffffffc0206460 <pmm_manager>
ffffffffc02013ce:	639c                	ld	a5,0(a5)
ffffffffc02013d0:	8522                	mv	a0,s0
ffffffffc02013d2:	6f9c                	ld	a5,24(a5)
ffffffffc02013d4:	9782                	jalr	a5
ffffffffc02013d6:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc02013d8:	88cff0ef          	jal	ra,ffffffffc0200464 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc02013dc:	8522                	mv	a0,s0
ffffffffc02013de:	60a2                	ld	ra,8(sp)
ffffffffc02013e0:	6402                	ld	s0,0(sp)
ffffffffc02013e2:	0141                	addi	sp,sp,16
ffffffffc02013e4:	8082                	ret

ffffffffc02013e6 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02013e6:	100027f3          	csrr	a5,sstatus
ffffffffc02013ea:	8b89                	andi	a5,a5,2
ffffffffc02013ec:	eb89                	bnez	a5,ffffffffc02013fe <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc02013ee:	00005797          	auipc	a5,0x5
ffffffffc02013f2:	07278793          	addi	a5,a5,114 # ffffffffc0206460 <pmm_manager>
ffffffffc02013f6:	639c                	ld	a5,0(a5)
ffffffffc02013f8:	0207b303          	ld	t1,32(a5)
ffffffffc02013fc:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc02013fe:	1101                	addi	sp,sp,-32
ffffffffc0201400:	ec06                	sd	ra,24(sp)
ffffffffc0201402:	e822                	sd	s0,16(sp)
ffffffffc0201404:	e426                	sd	s1,8(sp)
ffffffffc0201406:	842a                	mv	s0,a0
ffffffffc0201408:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc020140a:	860ff0ef          	jal	ra,ffffffffc020046a <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020140e:	00005797          	auipc	a5,0x5
ffffffffc0201412:	05278793          	addi	a5,a5,82 # ffffffffc0206460 <pmm_manager>
ffffffffc0201416:	639c                	ld	a5,0(a5)
ffffffffc0201418:	85a6                	mv	a1,s1
ffffffffc020141a:	8522                	mv	a0,s0
ffffffffc020141c:	739c                	ld	a5,32(a5)
ffffffffc020141e:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201420:	6442                	ld	s0,16(sp)
ffffffffc0201422:	60e2                	ld	ra,24(sp)
ffffffffc0201424:	64a2                	ld	s1,8(sp)
ffffffffc0201426:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201428:	83cff06f          	j	ffffffffc0200464 <intr_enable>

ffffffffc020142c <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020142c:	100027f3          	csrr	a5,sstatus
ffffffffc0201430:	8b89                	andi	a5,a5,2
ffffffffc0201432:	eb89                	bnez	a5,ffffffffc0201444 <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201434:	00005797          	auipc	a5,0x5
ffffffffc0201438:	02c78793          	addi	a5,a5,44 # ffffffffc0206460 <pmm_manager>
ffffffffc020143c:	639c                	ld	a5,0(a5)
ffffffffc020143e:	0287b303          	ld	t1,40(a5)
ffffffffc0201442:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0201444:	1141                	addi	sp,sp,-16
ffffffffc0201446:	e406                	sd	ra,8(sp)
ffffffffc0201448:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc020144a:	820ff0ef          	jal	ra,ffffffffc020046a <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc020144e:	00005797          	auipc	a5,0x5
ffffffffc0201452:	01278793          	addi	a5,a5,18 # ffffffffc0206460 <pmm_manager>
ffffffffc0201456:	639c                	ld	a5,0(a5)
ffffffffc0201458:	779c                	ld	a5,40(a5)
ffffffffc020145a:	9782                	jalr	a5
ffffffffc020145c:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020145e:	806ff0ef          	jal	ra,ffffffffc0200464 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201462:	8522                	mv	a0,s0
ffffffffc0201464:	60a2                	ld	ra,8(sp)
ffffffffc0201466:	6402                	ld	s0,0(sp)
ffffffffc0201468:	0141                	addi	sp,sp,16
ffffffffc020146a:	8082                	ret

ffffffffc020146c <pmm_init>:
    pmm_manager = &best_fit_pmm_manager;
ffffffffc020146c:	00001797          	auipc	a5,0x1
ffffffffc0201470:	27c78793          	addi	a5,a5,636 # ffffffffc02026e8 <best_fit_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201474:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0201476:	1101                	addi	sp,sp,-32
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201478:	00001517          	auipc	a0,0x1
ffffffffc020147c:	2c050513          	addi	a0,a0,704 # ffffffffc0202738 <best_fit_pmm_manager+0x50>
void pmm_init(void) {
ffffffffc0201480:	ec06                	sd	ra,24(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc0201482:	00005717          	auipc	a4,0x5
ffffffffc0201486:	fcf73f23          	sd	a5,-34(a4) # ffffffffc0206460 <pmm_manager>
void pmm_init(void) {
ffffffffc020148a:	e822                	sd	s0,16(sp)
ffffffffc020148c:	e426                	sd	s1,8(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc020148e:	00005417          	auipc	s0,0x5
ffffffffc0201492:	fd240413          	addi	s0,s0,-46 # ffffffffc0206460 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201496:	c27fe0ef          	jal	ra,ffffffffc02000bc <cprintf>
    pmm_manager->init();
ffffffffc020149a:	601c                	ld	a5,0(s0)
ffffffffc020149c:	679c                	ld	a5,8(a5)
ffffffffc020149e:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02014a0:	57f5                	li	a5,-3
ffffffffc02014a2:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02014a4:	00001517          	auipc	a0,0x1
ffffffffc02014a8:	2ac50513          	addi	a0,a0,684 # ffffffffc0202750 <best_fit_pmm_manager+0x68>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02014ac:	00005717          	auipc	a4,0x5
ffffffffc02014b0:	faf73e23          	sd	a5,-68(a4) # ffffffffc0206468 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc02014b4:	c09fe0ef          	jal	ra,ffffffffc02000bc <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc02014b8:	46c5                	li	a3,17
ffffffffc02014ba:	06ee                	slli	a3,a3,0x1b
ffffffffc02014bc:	40100613          	li	a2,1025
ffffffffc02014c0:	16fd                	addi	a3,a3,-1
ffffffffc02014c2:	0656                	slli	a2,a2,0x15
ffffffffc02014c4:	07e005b7          	lui	a1,0x7e00
ffffffffc02014c8:	00001517          	auipc	a0,0x1
ffffffffc02014cc:	2a050513          	addi	a0,a0,672 # ffffffffc0202768 <best_fit_pmm_manager+0x80>
ffffffffc02014d0:	bedfe0ef          	jal	ra,ffffffffc02000bc <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02014d4:	777d                	lui	a4,0xfffff
ffffffffc02014d6:	00006797          	auipc	a5,0x6
ffffffffc02014da:	fa178793          	addi	a5,a5,-95 # ffffffffc0207477 <end+0xfff>
ffffffffc02014de:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02014e0:	00088737          	lui	a4,0x88
ffffffffc02014e4:	00005697          	auipc	a3,0x5
ffffffffc02014e8:	f2e6be23          	sd	a4,-196(a3) # ffffffffc0206420 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02014ec:	4601                	li	a2,0
ffffffffc02014ee:	00005717          	auipc	a4,0x5
ffffffffc02014f2:	f8f73123          	sd	a5,-126(a4) # ffffffffc0206470 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02014f6:	4681                	li	a3,0
ffffffffc02014f8:	00005897          	auipc	a7,0x5
ffffffffc02014fc:	f2888893          	addi	a7,a7,-216 # ffffffffc0206420 <npage>
ffffffffc0201500:	00005597          	auipc	a1,0x5
ffffffffc0201504:	f7058593          	addi	a1,a1,-144 # ffffffffc0206470 <pages>
ffffffffc0201508:	4805                	li	a6,1
ffffffffc020150a:	fff80537          	lui	a0,0xfff80
ffffffffc020150e:	a011                	j	ffffffffc0201512 <pmm_init+0xa6>
ffffffffc0201510:	619c                	ld	a5,0(a1)
        SetPageReserved(pages + i);
ffffffffc0201512:	97b2                	add	a5,a5,a2
ffffffffc0201514:	07a1                	addi	a5,a5,8
ffffffffc0201516:	4107b02f          	amoor.d	zero,a6,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020151a:	0008b703          	ld	a4,0(a7)
ffffffffc020151e:	0685                	addi	a3,a3,1
ffffffffc0201520:	02860613          	addi	a2,a2,40
ffffffffc0201524:	00a707b3          	add	a5,a4,a0
ffffffffc0201528:	fef6e4e3          	bltu	a3,a5,ffffffffc0201510 <pmm_init+0xa4>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020152c:	6190                	ld	a2,0(a1)
ffffffffc020152e:	00271793          	slli	a5,a4,0x2
ffffffffc0201532:	97ba                	add	a5,a5,a4
ffffffffc0201534:	fec006b7          	lui	a3,0xfec00
ffffffffc0201538:	078e                	slli	a5,a5,0x3
ffffffffc020153a:	96b2                	add	a3,a3,a2
ffffffffc020153c:	96be                	add	a3,a3,a5
ffffffffc020153e:	c02007b7          	lui	a5,0xc0200
ffffffffc0201542:	08f6e863          	bltu	a3,a5,ffffffffc02015d2 <pmm_init+0x166>
ffffffffc0201546:	00005497          	auipc	s1,0x5
ffffffffc020154a:	f2248493          	addi	s1,s1,-222 # ffffffffc0206468 <va_pa_offset>
ffffffffc020154e:	609c                	ld	a5,0(s1)
    if (freemem < mem_end) {
ffffffffc0201550:	45c5                	li	a1,17
ffffffffc0201552:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201554:	8e9d                	sub	a3,a3,a5
    if (freemem < mem_end) {
ffffffffc0201556:	04b6e963          	bltu	a3,a1,ffffffffc02015a8 <pmm_init+0x13c>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc020155a:	601c                	ld	a5,0(s0)
ffffffffc020155c:	7b9c                	ld	a5,48(a5)
ffffffffc020155e:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201560:	00001517          	auipc	a0,0x1
ffffffffc0201564:	2a050513          	addi	a0,a0,672 # ffffffffc0202800 <best_fit_pmm_manager+0x118>
ffffffffc0201568:	b55fe0ef          	jal	ra,ffffffffc02000bc <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc020156c:	00004697          	auipc	a3,0x4
ffffffffc0201570:	a9468693          	addi	a3,a3,-1388 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0201574:	00005797          	auipc	a5,0x5
ffffffffc0201578:	ead7ba23          	sd	a3,-332(a5) # ffffffffc0206428 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc020157c:	c02007b7          	lui	a5,0xc0200
ffffffffc0201580:	06f6e563          	bltu	a3,a5,ffffffffc02015ea <pmm_init+0x17e>
ffffffffc0201584:	609c                	ld	a5,0(s1)
}
ffffffffc0201586:	6442                	ld	s0,16(sp)
ffffffffc0201588:	60e2                	ld	ra,24(sp)
ffffffffc020158a:	64a2                	ld	s1,8(sp)
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020158c:	85b6                	mv	a1,a3
    satp_physical = PADDR(satp_virtual);
ffffffffc020158e:	8e9d                	sub	a3,a3,a5
ffffffffc0201590:	00005797          	auipc	a5,0x5
ffffffffc0201594:	ecd7b423          	sd	a3,-312(a5) # ffffffffc0206458 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201598:	00001517          	auipc	a0,0x1
ffffffffc020159c:	28850513          	addi	a0,a0,648 # ffffffffc0202820 <best_fit_pmm_manager+0x138>
ffffffffc02015a0:	8636                	mv	a2,a3
}
ffffffffc02015a2:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02015a4:	b19fe06f          	j	ffffffffc02000bc <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02015a8:	6785                	lui	a5,0x1
ffffffffc02015aa:	17fd                	addi	a5,a5,-1
ffffffffc02015ac:	96be                	add	a3,a3,a5
ffffffffc02015ae:	77fd                	lui	a5,0xfffff
ffffffffc02015b0:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02015b2:	00c6d793          	srli	a5,a3,0xc
ffffffffc02015b6:	04e7f663          	bleu	a4,a5,ffffffffc0201602 <pmm_init+0x196>
    pmm_manager->init_memmap(base, n);
ffffffffc02015ba:	6018                	ld	a4,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc02015bc:	97aa                	add	a5,a5,a0
ffffffffc02015be:	00279513          	slli	a0,a5,0x2
ffffffffc02015c2:	953e                	add	a0,a0,a5
ffffffffc02015c4:	6b1c                	ld	a5,16(a4)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02015c6:	8d95                	sub	a1,a1,a3
ffffffffc02015c8:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02015ca:	81b1                	srli	a1,a1,0xc
ffffffffc02015cc:	9532                	add	a0,a0,a2
ffffffffc02015ce:	9782                	jalr	a5
ffffffffc02015d0:	b769                	j	ffffffffc020155a <pmm_init+0xee>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02015d2:	00001617          	auipc	a2,0x1
ffffffffc02015d6:	1c660613          	addi	a2,a2,454 # ffffffffc0202798 <best_fit_pmm_manager+0xb0>
ffffffffc02015da:	06e00593          	li	a1,110
ffffffffc02015de:	00001517          	auipc	a0,0x1
ffffffffc02015e2:	1e250513          	addi	a0,a0,482 # ffffffffc02027c0 <best_fit_pmm_manager+0xd8>
ffffffffc02015e6:	dcdfe0ef          	jal	ra,ffffffffc02003b2 <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc02015ea:	00001617          	auipc	a2,0x1
ffffffffc02015ee:	1ae60613          	addi	a2,a2,430 # ffffffffc0202798 <best_fit_pmm_manager+0xb0>
ffffffffc02015f2:	08900593          	li	a1,137
ffffffffc02015f6:	00001517          	auipc	a0,0x1
ffffffffc02015fa:	1ca50513          	addi	a0,a0,458 # ffffffffc02027c0 <best_fit_pmm_manager+0xd8>
ffffffffc02015fe:	db5fe0ef          	jal	ra,ffffffffc02003b2 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201602:	00001617          	auipc	a2,0x1
ffffffffc0201606:	1ce60613          	addi	a2,a2,462 # ffffffffc02027d0 <best_fit_pmm_manager+0xe8>
ffffffffc020160a:	06b00593          	li	a1,107
ffffffffc020160e:	00001517          	auipc	a0,0x1
ffffffffc0201612:	1e250513          	addi	a0,a0,482 # ffffffffc02027f0 <best_fit_pmm_manager+0x108>
ffffffffc0201616:	d9dfe0ef          	jal	ra,ffffffffc02003b2 <__panic>

ffffffffc020161a <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc020161a:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020161e:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201620:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201624:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201626:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020162a:	f022                	sd	s0,32(sp)
ffffffffc020162c:	ec26                	sd	s1,24(sp)
ffffffffc020162e:	e84a                	sd	s2,16(sp)
ffffffffc0201630:	f406                	sd	ra,40(sp)
ffffffffc0201632:	e44e                	sd	s3,8(sp)
ffffffffc0201634:	84aa                	mv	s1,a0
ffffffffc0201636:	892e                	mv	s2,a1
ffffffffc0201638:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc020163c:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc020163e:	03067e63          	bleu	a6,a2,ffffffffc020167a <printnum+0x60>
ffffffffc0201642:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0201644:	00805763          	blez	s0,ffffffffc0201652 <printnum+0x38>
ffffffffc0201648:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020164a:	85ca                	mv	a1,s2
ffffffffc020164c:	854e                	mv	a0,s3
ffffffffc020164e:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201650:	fc65                	bnez	s0,ffffffffc0201648 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201652:	1a02                	slli	s4,s4,0x20
ffffffffc0201654:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201658:	00001797          	auipc	a5,0x1
ffffffffc020165c:	39878793          	addi	a5,a5,920 # ffffffffc02029f0 <error_string+0x38>
ffffffffc0201660:	9a3e                	add	s4,s4,a5
}
ffffffffc0201662:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201664:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0201668:	70a2                	ld	ra,40(sp)
ffffffffc020166a:	69a2                	ld	s3,8(sp)
ffffffffc020166c:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020166e:	85ca                	mv	a1,s2
ffffffffc0201670:	8326                	mv	t1,s1
}
ffffffffc0201672:	6942                	ld	s2,16(sp)
ffffffffc0201674:	64e2                	ld	s1,24(sp)
ffffffffc0201676:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201678:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc020167a:	03065633          	divu	a2,a2,a6
ffffffffc020167e:	8722                	mv	a4,s0
ffffffffc0201680:	f9bff0ef          	jal	ra,ffffffffc020161a <printnum>
ffffffffc0201684:	b7f9                	j	ffffffffc0201652 <printnum+0x38>

ffffffffc0201686 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0201686:	7119                	addi	sp,sp,-128
ffffffffc0201688:	f4a6                	sd	s1,104(sp)
ffffffffc020168a:	f0ca                	sd	s2,96(sp)
ffffffffc020168c:	e8d2                	sd	s4,80(sp)
ffffffffc020168e:	e4d6                	sd	s5,72(sp)
ffffffffc0201690:	e0da                	sd	s6,64(sp)
ffffffffc0201692:	fc5e                	sd	s7,56(sp)
ffffffffc0201694:	f862                	sd	s8,48(sp)
ffffffffc0201696:	f06a                	sd	s10,32(sp)
ffffffffc0201698:	fc86                	sd	ra,120(sp)
ffffffffc020169a:	f8a2                	sd	s0,112(sp)
ffffffffc020169c:	ecce                	sd	s3,88(sp)
ffffffffc020169e:	f466                	sd	s9,40(sp)
ffffffffc02016a0:	ec6e                	sd	s11,24(sp)
ffffffffc02016a2:	892a                	mv	s2,a0
ffffffffc02016a4:	84ae                	mv	s1,a1
ffffffffc02016a6:	8d32                	mv	s10,a2
ffffffffc02016a8:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02016aa:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016ac:	00001a17          	auipc	s4,0x1
ffffffffc02016b0:	1b4a0a13          	addi	s4,s4,436 # ffffffffc0202860 <best_fit_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02016b4:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02016b8:	00001c17          	auipc	s8,0x1
ffffffffc02016bc:	300c0c13          	addi	s8,s8,768 # ffffffffc02029b8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02016c0:	000d4503          	lbu	a0,0(s10)
ffffffffc02016c4:	02500793          	li	a5,37
ffffffffc02016c8:	001d0413          	addi	s0,s10,1
ffffffffc02016cc:	00f50e63          	beq	a0,a5,ffffffffc02016e8 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc02016d0:	c521                	beqz	a0,ffffffffc0201718 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02016d2:	02500993          	li	s3,37
ffffffffc02016d6:	a011                	j	ffffffffc02016da <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc02016d8:	c121                	beqz	a0,ffffffffc0201718 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc02016da:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02016dc:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02016de:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02016e0:	fff44503          	lbu	a0,-1(s0)
ffffffffc02016e4:	ff351ae3          	bne	a0,s3,ffffffffc02016d8 <vprintfmt+0x52>
ffffffffc02016e8:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02016ec:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02016f0:	4981                	li	s3,0
ffffffffc02016f2:	4801                	li	a6,0
        width = precision = -1;
ffffffffc02016f4:	5cfd                	li	s9,-1
ffffffffc02016f6:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016f8:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc02016fc:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016fe:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0201702:	0ff6f693          	andi	a3,a3,255
ffffffffc0201706:	00140d13          	addi	s10,s0,1
ffffffffc020170a:	20d5e563          	bltu	a1,a3,ffffffffc0201914 <vprintfmt+0x28e>
ffffffffc020170e:	068a                	slli	a3,a3,0x2
ffffffffc0201710:	96d2                	add	a3,a3,s4
ffffffffc0201712:	4294                	lw	a3,0(a3)
ffffffffc0201714:	96d2                	add	a3,a3,s4
ffffffffc0201716:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201718:	70e6                	ld	ra,120(sp)
ffffffffc020171a:	7446                	ld	s0,112(sp)
ffffffffc020171c:	74a6                	ld	s1,104(sp)
ffffffffc020171e:	7906                	ld	s2,96(sp)
ffffffffc0201720:	69e6                	ld	s3,88(sp)
ffffffffc0201722:	6a46                	ld	s4,80(sp)
ffffffffc0201724:	6aa6                	ld	s5,72(sp)
ffffffffc0201726:	6b06                	ld	s6,64(sp)
ffffffffc0201728:	7be2                	ld	s7,56(sp)
ffffffffc020172a:	7c42                	ld	s8,48(sp)
ffffffffc020172c:	7ca2                	ld	s9,40(sp)
ffffffffc020172e:	7d02                	ld	s10,32(sp)
ffffffffc0201730:	6de2                	ld	s11,24(sp)
ffffffffc0201732:	6109                	addi	sp,sp,128
ffffffffc0201734:	8082                	ret
    if (lflag >= 2) {
ffffffffc0201736:	4705                	li	a4,1
ffffffffc0201738:	008a8593          	addi	a1,s5,8
ffffffffc020173c:	01074463          	blt	a4,a6,ffffffffc0201744 <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0201740:	26080363          	beqz	a6,ffffffffc02019a6 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc0201744:	000ab603          	ld	a2,0(s5)
ffffffffc0201748:	46c1                	li	a3,16
ffffffffc020174a:	8aae                	mv	s5,a1
ffffffffc020174c:	a06d                	j	ffffffffc02017f6 <vprintfmt+0x170>
            goto reswitch;
ffffffffc020174e:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201752:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201754:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201756:	b765                	j	ffffffffc02016fe <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0201758:	000aa503          	lw	a0,0(s5)
ffffffffc020175c:	85a6                	mv	a1,s1
ffffffffc020175e:	0aa1                	addi	s5,s5,8
ffffffffc0201760:	9902                	jalr	s2
            break;
ffffffffc0201762:	bfb9                	j	ffffffffc02016c0 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201764:	4705                	li	a4,1
ffffffffc0201766:	008a8993          	addi	s3,s5,8
ffffffffc020176a:	01074463          	blt	a4,a6,ffffffffc0201772 <vprintfmt+0xec>
    else if (lflag) {
ffffffffc020176e:	22080463          	beqz	a6,ffffffffc0201996 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc0201772:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0201776:	24044463          	bltz	s0,ffffffffc02019be <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc020177a:	8622                	mv	a2,s0
ffffffffc020177c:	8ace                	mv	s5,s3
ffffffffc020177e:	46a9                	li	a3,10
ffffffffc0201780:	a89d                	j	ffffffffc02017f6 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc0201782:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201786:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0201788:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc020178a:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc020178e:	8fb5                	xor	a5,a5,a3
ffffffffc0201790:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201794:	1ad74363          	blt	a4,a3,ffffffffc020193a <vprintfmt+0x2b4>
ffffffffc0201798:	00369793          	slli	a5,a3,0x3
ffffffffc020179c:	97e2                	add	a5,a5,s8
ffffffffc020179e:	639c                	ld	a5,0(a5)
ffffffffc02017a0:	18078d63          	beqz	a5,ffffffffc020193a <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc02017a4:	86be                	mv	a3,a5
ffffffffc02017a6:	00001617          	auipc	a2,0x1
ffffffffc02017aa:	2fa60613          	addi	a2,a2,762 # ffffffffc0202aa0 <error_string+0xe8>
ffffffffc02017ae:	85a6                	mv	a1,s1
ffffffffc02017b0:	854a                	mv	a0,s2
ffffffffc02017b2:	240000ef          	jal	ra,ffffffffc02019f2 <printfmt>
ffffffffc02017b6:	b729                	j	ffffffffc02016c0 <vprintfmt+0x3a>
            lflag ++;
ffffffffc02017b8:	00144603          	lbu	a2,1(s0)
ffffffffc02017bc:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02017be:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02017c0:	bf3d                	j	ffffffffc02016fe <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc02017c2:	4705                	li	a4,1
ffffffffc02017c4:	008a8593          	addi	a1,s5,8
ffffffffc02017c8:	01074463          	blt	a4,a6,ffffffffc02017d0 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc02017cc:	1e080263          	beqz	a6,ffffffffc02019b0 <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc02017d0:	000ab603          	ld	a2,0(s5)
ffffffffc02017d4:	46a1                	li	a3,8
ffffffffc02017d6:	8aae                	mv	s5,a1
ffffffffc02017d8:	a839                	j	ffffffffc02017f6 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc02017da:	03000513          	li	a0,48
ffffffffc02017de:	85a6                	mv	a1,s1
ffffffffc02017e0:	e03e                	sd	a5,0(sp)
ffffffffc02017e2:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02017e4:	85a6                	mv	a1,s1
ffffffffc02017e6:	07800513          	li	a0,120
ffffffffc02017ea:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02017ec:	0aa1                	addi	s5,s5,8
ffffffffc02017ee:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc02017f2:	6782                	ld	a5,0(sp)
ffffffffc02017f4:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02017f6:	876e                	mv	a4,s11
ffffffffc02017f8:	85a6                	mv	a1,s1
ffffffffc02017fa:	854a                	mv	a0,s2
ffffffffc02017fc:	e1fff0ef          	jal	ra,ffffffffc020161a <printnum>
            break;
ffffffffc0201800:	b5c1                	j	ffffffffc02016c0 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201802:	000ab603          	ld	a2,0(s5)
ffffffffc0201806:	0aa1                	addi	s5,s5,8
ffffffffc0201808:	1c060663          	beqz	a2,ffffffffc02019d4 <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc020180c:	00160413          	addi	s0,a2,1
ffffffffc0201810:	17b05c63          	blez	s11,ffffffffc0201988 <vprintfmt+0x302>
ffffffffc0201814:	02d00593          	li	a1,45
ffffffffc0201818:	14b79263          	bne	a5,a1,ffffffffc020195c <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020181c:	00064783          	lbu	a5,0(a2)
ffffffffc0201820:	0007851b          	sext.w	a0,a5
ffffffffc0201824:	c905                	beqz	a0,ffffffffc0201854 <vprintfmt+0x1ce>
ffffffffc0201826:	000cc563          	bltz	s9,ffffffffc0201830 <vprintfmt+0x1aa>
ffffffffc020182a:	3cfd                	addiw	s9,s9,-1
ffffffffc020182c:	036c8263          	beq	s9,s6,ffffffffc0201850 <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0201830:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201832:	18098463          	beqz	s3,ffffffffc02019ba <vprintfmt+0x334>
ffffffffc0201836:	3781                	addiw	a5,a5,-32
ffffffffc0201838:	18fbf163          	bleu	a5,s7,ffffffffc02019ba <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc020183c:	03f00513          	li	a0,63
ffffffffc0201840:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201842:	0405                	addi	s0,s0,1
ffffffffc0201844:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201848:	3dfd                	addiw	s11,s11,-1
ffffffffc020184a:	0007851b          	sext.w	a0,a5
ffffffffc020184e:	fd61                	bnez	a0,ffffffffc0201826 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0201850:	e7b058e3          	blez	s11,ffffffffc02016c0 <vprintfmt+0x3a>
ffffffffc0201854:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201856:	85a6                	mv	a1,s1
ffffffffc0201858:	02000513          	li	a0,32
ffffffffc020185c:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020185e:	e60d81e3          	beqz	s11,ffffffffc02016c0 <vprintfmt+0x3a>
ffffffffc0201862:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201864:	85a6                	mv	a1,s1
ffffffffc0201866:	02000513          	li	a0,32
ffffffffc020186a:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020186c:	fe0d94e3          	bnez	s11,ffffffffc0201854 <vprintfmt+0x1ce>
ffffffffc0201870:	bd81                	j	ffffffffc02016c0 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201872:	4705                	li	a4,1
ffffffffc0201874:	008a8593          	addi	a1,s5,8
ffffffffc0201878:	01074463          	blt	a4,a6,ffffffffc0201880 <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc020187c:	12080063          	beqz	a6,ffffffffc020199c <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc0201880:	000ab603          	ld	a2,0(s5)
ffffffffc0201884:	46a9                	li	a3,10
ffffffffc0201886:	8aae                	mv	s5,a1
ffffffffc0201888:	b7bd                	j	ffffffffc02017f6 <vprintfmt+0x170>
ffffffffc020188a:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc020188e:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201892:	846a                	mv	s0,s10
ffffffffc0201894:	b5ad                	j	ffffffffc02016fe <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0201896:	85a6                	mv	a1,s1
ffffffffc0201898:	02500513          	li	a0,37
ffffffffc020189c:	9902                	jalr	s2
            break;
ffffffffc020189e:	b50d                	j	ffffffffc02016c0 <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc02018a0:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc02018a4:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02018a8:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02018aa:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc02018ac:	e40dd9e3          	bgez	s11,ffffffffc02016fe <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc02018b0:	8de6                	mv	s11,s9
ffffffffc02018b2:	5cfd                	li	s9,-1
ffffffffc02018b4:	b5a9                	j	ffffffffc02016fe <vprintfmt+0x78>
            goto reswitch;
ffffffffc02018b6:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc02018ba:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02018be:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02018c0:	bd3d                	j	ffffffffc02016fe <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc02018c2:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc02018c6:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02018ca:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02018cc:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02018d0:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02018d4:	fcd56ce3          	bltu	a0,a3,ffffffffc02018ac <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc02018d8:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02018da:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc02018de:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02018e2:	0196873b          	addw	a4,a3,s9
ffffffffc02018e6:	0017171b          	slliw	a4,a4,0x1
ffffffffc02018ea:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc02018ee:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc02018f2:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc02018f6:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02018fa:	fcd57fe3          	bleu	a3,a0,ffffffffc02018d8 <vprintfmt+0x252>
ffffffffc02018fe:	b77d                	j	ffffffffc02018ac <vprintfmt+0x226>
            if (width < 0)
ffffffffc0201900:	fffdc693          	not	a3,s11
ffffffffc0201904:	96fd                	srai	a3,a3,0x3f
ffffffffc0201906:	00ddfdb3          	and	s11,s11,a3
ffffffffc020190a:	00144603          	lbu	a2,1(s0)
ffffffffc020190e:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201910:	846a                	mv	s0,s10
ffffffffc0201912:	b3f5                	j	ffffffffc02016fe <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc0201914:	85a6                	mv	a1,s1
ffffffffc0201916:	02500513          	li	a0,37
ffffffffc020191a:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020191c:	fff44703          	lbu	a4,-1(s0)
ffffffffc0201920:	02500793          	li	a5,37
ffffffffc0201924:	8d22                	mv	s10,s0
ffffffffc0201926:	d8f70de3          	beq	a4,a5,ffffffffc02016c0 <vprintfmt+0x3a>
ffffffffc020192a:	02500713          	li	a4,37
ffffffffc020192e:	1d7d                	addi	s10,s10,-1
ffffffffc0201930:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0201934:	fee79de3          	bne	a5,a4,ffffffffc020192e <vprintfmt+0x2a8>
ffffffffc0201938:	b361                	j	ffffffffc02016c0 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020193a:	00001617          	auipc	a2,0x1
ffffffffc020193e:	15660613          	addi	a2,a2,342 # ffffffffc0202a90 <error_string+0xd8>
ffffffffc0201942:	85a6                	mv	a1,s1
ffffffffc0201944:	854a                	mv	a0,s2
ffffffffc0201946:	0ac000ef          	jal	ra,ffffffffc02019f2 <printfmt>
ffffffffc020194a:	bb9d                	j	ffffffffc02016c0 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020194c:	00001617          	auipc	a2,0x1
ffffffffc0201950:	13c60613          	addi	a2,a2,316 # ffffffffc0202a88 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc0201954:	00001417          	auipc	s0,0x1
ffffffffc0201958:	13540413          	addi	s0,s0,309 # ffffffffc0202a89 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020195c:	8532                	mv	a0,a2
ffffffffc020195e:	85e6                	mv	a1,s9
ffffffffc0201960:	e032                	sd	a2,0(sp)
ffffffffc0201962:	e43e                	sd	a5,8(sp)
ffffffffc0201964:	1de000ef          	jal	ra,ffffffffc0201b42 <strnlen>
ffffffffc0201968:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020196c:	6602                	ld	a2,0(sp)
ffffffffc020196e:	01b05d63          	blez	s11,ffffffffc0201988 <vprintfmt+0x302>
ffffffffc0201972:	67a2                	ld	a5,8(sp)
ffffffffc0201974:	2781                	sext.w	a5,a5
ffffffffc0201976:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0201978:	6522                	ld	a0,8(sp)
ffffffffc020197a:	85a6                	mv	a1,s1
ffffffffc020197c:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020197e:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201980:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201982:	6602                	ld	a2,0(sp)
ffffffffc0201984:	fe0d9ae3          	bnez	s11,ffffffffc0201978 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201988:	00064783          	lbu	a5,0(a2)
ffffffffc020198c:	0007851b          	sext.w	a0,a5
ffffffffc0201990:	e8051be3          	bnez	a0,ffffffffc0201826 <vprintfmt+0x1a0>
ffffffffc0201994:	b335                	j	ffffffffc02016c0 <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc0201996:	000aa403          	lw	s0,0(s5)
ffffffffc020199a:	bbf1                	j	ffffffffc0201776 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc020199c:	000ae603          	lwu	a2,0(s5)
ffffffffc02019a0:	46a9                	li	a3,10
ffffffffc02019a2:	8aae                	mv	s5,a1
ffffffffc02019a4:	bd89                	j	ffffffffc02017f6 <vprintfmt+0x170>
ffffffffc02019a6:	000ae603          	lwu	a2,0(s5)
ffffffffc02019aa:	46c1                	li	a3,16
ffffffffc02019ac:	8aae                	mv	s5,a1
ffffffffc02019ae:	b5a1                	j	ffffffffc02017f6 <vprintfmt+0x170>
ffffffffc02019b0:	000ae603          	lwu	a2,0(s5)
ffffffffc02019b4:	46a1                	li	a3,8
ffffffffc02019b6:	8aae                	mv	s5,a1
ffffffffc02019b8:	bd3d                	j	ffffffffc02017f6 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc02019ba:	9902                	jalr	s2
ffffffffc02019bc:	b559                	j	ffffffffc0201842 <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc02019be:	85a6                	mv	a1,s1
ffffffffc02019c0:	02d00513          	li	a0,45
ffffffffc02019c4:	e03e                	sd	a5,0(sp)
ffffffffc02019c6:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02019c8:	8ace                	mv	s5,s3
ffffffffc02019ca:	40800633          	neg	a2,s0
ffffffffc02019ce:	46a9                	li	a3,10
ffffffffc02019d0:	6782                	ld	a5,0(sp)
ffffffffc02019d2:	b515                	j	ffffffffc02017f6 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc02019d4:	01b05663          	blez	s11,ffffffffc02019e0 <vprintfmt+0x35a>
ffffffffc02019d8:	02d00693          	li	a3,45
ffffffffc02019dc:	f6d798e3          	bne	a5,a3,ffffffffc020194c <vprintfmt+0x2c6>
ffffffffc02019e0:	00001417          	auipc	s0,0x1
ffffffffc02019e4:	0a940413          	addi	s0,s0,169 # ffffffffc0202a89 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02019e8:	02800513          	li	a0,40
ffffffffc02019ec:	02800793          	li	a5,40
ffffffffc02019f0:	bd1d                	j	ffffffffc0201826 <vprintfmt+0x1a0>

ffffffffc02019f2 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02019f2:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02019f4:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02019f8:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02019fa:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02019fc:	ec06                	sd	ra,24(sp)
ffffffffc02019fe:	f83a                	sd	a4,48(sp)
ffffffffc0201a00:	fc3e                	sd	a5,56(sp)
ffffffffc0201a02:	e0c2                	sd	a6,64(sp)
ffffffffc0201a04:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201a06:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201a08:	c7fff0ef          	jal	ra,ffffffffc0201686 <vprintfmt>
}
ffffffffc0201a0c:	60e2                	ld	ra,24(sp)
ffffffffc0201a0e:	6161                	addi	sp,sp,80
ffffffffc0201a10:	8082                	ret

ffffffffc0201a12 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201a12:	715d                	addi	sp,sp,-80
ffffffffc0201a14:	e486                	sd	ra,72(sp)
ffffffffc0201a16:	e0a2                	sd	s0,64(sp)
ffffffffc0201a18:	fc26                	sd	s1,56(sp)
ffffffffc0201a1a:	f84a                	sd	s2,48(sp)
ffffffffc0201a1c:	f44e                	sd	s3,40(sp)
ffffffffc0201a1e:	f052                	sd	s4,32(sp)
ffffffffc0201a20:	ec56                	sd	s5,24(sp)
ffffffffc0201a22:	e85a                	sd	s6,16(sp)
ffffffffc0201a24:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc0201a26:	c901                	beqz	a0,ffffffffc0201a36 <readline+0x24>
        cprintf("%s", prompt);
ffffffffc0201a28:	85aa                	mv	a1,a0
ffffffffc0201a2a:	00001517          	auipc	a0,0x1
ffffffffc0201a2e:	07650513          	addi	a0,a0,118 # ffffffffc0202aa0 <error_string+0xe8>
ffffffffc0201a32:	e8afe0ef          	jal	ra,ffffffffc02000bc <cprintf>
readline(const char *prompt) {
ffffffffc0201a36:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201a38:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201a3a:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201a3c:	4aa9                	li	s5,10
ffffffffc0201a3e:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201a40:	00004b97          	auipc	s7,0x4
ffffffffc0201a44:	5d8b8b93          	addi	s7,s7,1496 # ffffffffc0206018 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201a48:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201a4c:	ee8fe0ef          	jal	ra,ffffffffc0200134 <getchar>
ffffffffc0201a50:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201a52:	00054b63          	bltz	a0,ffffffffc0201a68 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201a56:	00a95b63          	ble	a0,s2,ffffffffc0201a6c <readline+0x5a>
ffffffffc0201a5a:	029a5463          	ble	s1,s4,ffffffffc0201a82 <readline+0x70>
        c = getchar();
ffffffffc0201a5e:	ed6fe0ef          	jal	ra,ffffffffc0200134 <getchar>
ffffffffc0201a62:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201a64:	fe0559e3          	bgez	a0,ffffffffc0201a56 <readline+0x44>
            return NULL;
ffffffffc0201a68:	4501                	li	a0,0
ffffffffc0201a6a:	a099                	j	ffffffffc0201ab0 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc0201a6c:	03341463          	bne	s0,s3,ffffffffc0201a94 <readline+0x82>
ffffffffc0201a70:	e8b9                	bnez	s1,ffffffffc0201ac6 <readline+0xb4>
        c = getchar();
ffffffffc0201a72:	ec2fe0ef          	jal	ra,ffffffffc0200134 <getchar>
ffffffffc0201a76:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201a78:	fe0548e3          	bltz	a0,ffffffffc0201a68 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201a7c:	fea958e3          	ble	a0,s2,ffffffffc0201a6c <readline+0x5a>
ffffffffc0201a80:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201a82:	8522                	mv	a0,s0
ffffffffc0201a84:	e6cfe0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            buf[i ++] = c;
ffffffffc0201a88:	009b87b3          	add	a5,s7,s1
ffffffffc0201a8c:	00878023          	sb	s0,0(a5)
ffffffffc0201a90:	2485                	addiw	s1,s1,1
ffffffffc0201a92:	bf6d                	j	ffffffffc0201a4c <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc0201a94:	01540463          	beq	s0,s5,ffffffffc0201a9c <readline+0x8a>
ffffffffc0201a98:	fb641ae3          	bne	s0,s6,ffffffffc0201a4c <readline+0x3a>
            cputchar(c);
ffffffffc0201a9c:	8522                	mv	a0,s0
ffffffffc0201a9e:	e52fe0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            buf[i] = '\0';
ffffffffc0201aa2:	00004517          	auipc	a0,0x4
ffffffffc0201aa6:	57650513          	addi	a0,a0,1398 # ffffffffc0206018 <edata>
ffffffffc0201aaa:	94aa                	add	s1,s1,a0
ffffffffc0201aac:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201ab0:	60a6                	ld	ra,72(sp)
ffffffffc0201ab2:	6406                	ld	s0,64(sp)
ffffffffc0201ab4:	74e2                	ld	s1,56(sp)
ffffffffc0201ab6:	7942                	ld	s2,48(sp)
ffffffffc0201ab8:	79a2                	ld	s3,40(sp)
ffffffffc0201aba:	7a02                	ld	s4,32(sp)
ffffffffc0201abc:	6ae2                	ld	s5,24(sp)
ffffffffc0201abe:	6b42                	ld	s6,16(sp)
ffffffffc0201ac0:	6ba2                	ld	s7,8(sp)
ffffffffc0201ac2:	6161                	addi	sp,sp,80
ffffffffc0201ac4:	8082                	ret
            cputchar(c);
ffffffffc0201ac6:	4521                	li	a0,8
ffffffffc0201ac8:	e28fe0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            i --;
ffffffffc0201acc:	34fd                	addiw	s1,s1,-1
ffffffffc0201ace:	bfbd                	j	ffffffffc0201a4c <readline+0x3a>

ffffffffc0201ad0 <sbi_console_putchar>:
    );
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
ffffffffc0201ad0:	00004797          	auipc	a5,0x4
ffffffffc0201ad4:	53878793          	addi	a5,a5,1336 # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
    __asm__ volatile (
ffffffffc0201ad8:	6398                	ld	a4,0(a5)
ffffffffc0201ada:	4781                	li	a5,0
ffffffffc0201adc:	88ba                	mv	a7,a4
ffffffffc0201ade:	852a                	mv	a0,a0
ffffffffc0201ae0:	85be                	mv	a1,a5
ffffffffc0201ae2:	863e                	mv	a2,a5
ffffffffc0201ae4:	00000073          	ecall
ffffffffc0201ae8:	87aa                	mv	a5,a0
}
ffffffffc0201aea:	8082                	ret

ffffffffc0201aec <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
ffffffffc0201aec:	00005797          	auipc	a5,0x5
ffffffffc0201af0:	94478793          	addi	a5,a5,-1724 # ffffffffc0206430 <SBI_SET_TIMER>
    __asm__ volatile (
ffffffffc0201af4:	6398                	ld	a4,0(a5)
ffffffffc0201af6:	4781                	li	a5,0
ffffffffc0201af8:	88ba                	mv	a7,a4
ffffffffc0201afa:	852a                	mv	a0,a0
ffffffffc0201afc:	85be                	mv	a1,a5
ffffffffc0201afe:	863e                	mv	a2,a5
ffffffffc0201b00:	00000073          	ecall
ffffffffc0201b04:	87aa                	mv	a5,a0
}
ffffffffc0201b06:	8082                	ret

ffffffffc0201b08 <sbi_console_getchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201b08:	00004797          	auipc	a5,0x4
ffffffffc0201b0c:	4f878793          	addi	a5,a5,1272 # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
    __asm__ volatile (
ffffffffc0201b10:	639c                	ld	a5,0(a5)
ffffffffc0201b12:	4501                	li	a0,0
ffffffffc0201b14:	88be                	mv	a7,a5
ffffffffc0201b16:	852a                	mv	a0,a0
ffffffffc0201b18:	85aa                	mv	a1,a0
ffffffffc0201b1a:	862a                	mv	a2,a0
ffffffffc0201b1c:	00000073          	ecall
ffffffffc0201b20:	852a                	mv	a0,a0
}
ffffffffc0201b22:	2501                	sext.w	a0,a0
ffffffffc0201b24:	8082                	ret

ffffffffc0201b26 <sbi_shutdown>:


void sbi_shutdown(void){
    sbi_call(SBI_SHUTDOWN,0,0,0);
ffffffffc0201b26:	00004797          	auipc	a5,0x4
ffffffffc0201b2a:	4ea78793          	addi	a5,a5,1258 # ffffffffc0206010 <SBI_SHUTDOWN>
    __asm__ volatile (
ffffffffc0201b2e:	6398                	ld	a4,0(a5)
ffffffffc0201b30:	4781                	li	a5,0
ffffffffc0201b32:	88ba                	mv	a7,a4
ffffffffc0201b34:	853e                	mv	a0,a5
ffffffffc0201b36:	85be                	mv	a1,a5
ffffffffc0201b38:	863e                	mv	a2,a5
ffffffffc0201b3a:	00000073          	ecall
ffffffffc0201b3e:	87aa                	mv	a5,a0
ffffffffc0201b40:	8082                	ret

ffffffffc0201b42 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201b42:	c185                	beqz	a1,ffffffffc0201b62 <strnlen+0x20>
ffffffffc0201b44:	00054783          	lbu	a5,0(a0)
ffffffffc0201b48:	cf89                	beqz	a5,ffffffffc0201b62 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0201b4a:	4781                	li	a5,0
ffffffffc0201b4c:	a021                	j	ffffffffc0201b54 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201b4e:	00074703          	lbu	a4,0(a4)
ffffffffc0201b52:	c711                	beqz	a4,ffffffffc0201b5e <strnlen+0x1c>
        cnt ++;
ffffffffc0201b54:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201b56:	00f50733          	add	a4,a0,a5
ffffffffc0201b5a:	fef59ae3          	bne	a1,a5,ffffffffc0201b4e <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0201b5e:	853e                	mv	a0,a5
ffffffffc0201b60:	8082                	ret
    size_t cnt = 0;
ffffffffc0201b62:	4781                	li	a5,0
}
ffffffffc0201b64:	853e                	mv	a0,a5
ffffffffc0201b66:	8082                	ret

ffffffffc0201b68 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201b68:	00054783          	lbu	a5,0(a0)
ffffffffc0201b6c:	0005c703          	lbu	a4,0(a1)
ffffffffc0201b70:	cb91                	beqz	a5,ffffffffc0201b84 <strcmp+0x1c>
ffffffffc0201b72:	00e79c63          	bne	a5,a4,ffffffffc0201b8a <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0201b76:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201b78:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0201b7c:	0585                	addi	a1,a1,1
ffffffffc0201b7e:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201b82:	fbe5                	bnez	a5,ffffffffc0201b72 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201b84:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201b86:	9d19                	subw	a0,a0,a4
ffffffffc0201b88:	8082                	ret
ffffffffc0201b8a:	0007851b          	sext.w	a0,a5
ffffffffc0201b8e:	9d19                	subw	a0,a0,a4
ffffffffc0201b90:	8082                	ret

ffffffffc0201b92 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201b92:	00054783          	lbu	a5,0(a0)
ffffffffc0201b96:	cb91                	beqz	a5,ffffffffc0201baa <strchr+0x18>
        if (*s == c) {
ffffffffc0201b98:	00b79563          	bne	a5,a1,ffffffffc0201ba2 <strchr+0x10>
ffffffffc0201b9c:	a809                	j	ffffffffc0201bae <strchr+0x1c>
ffffffffc0201b9e:	00b78763          	beq	a5,a1,ffffffffc0201bac <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0201ba2:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201ba4:	00054783          	lbu	a5,0(a0)
ffffffffc0201ba8:	fbfd                	bnez	a5,ffffffffc0201b9e <strchr+0xc>
    }
    return NULL;
ffffffffc0201baa:	4501                	li	a0,0
}
ffffffffc0201bac:	8082                	ret
ffffffffc0201bae:	8082                	ret

ffffffffc0201bb0 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201bb0:	ca01                	beqz	a2,ffffffffc0201bc0 <memset+0x10>
ffffffffc0201bb2:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201bb4:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201bb6:	0785                	addi	a5,a5,1
ffffffffc0201bb8:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201bbc:	fec79de3          	bne	a5,a2,ffffffffc0201bb6 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201bc0:	8082                	ret
