
bin/kernel:     file format elf64-littleriscv


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
ffffffffc0200008:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000a:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc020000e:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200012:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200016:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200018:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc020001c:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200020:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200024:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:
void grade_backtrace(void);


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	00006517          	auipc	a0,0x6
ffffffffc0200036:	fde50513          	addi	a0,a0,-34 # ffffffffc0206010 <free_area>
ffffffffc020003a:	00006617          	auipc	a2,0x6
ffffffffc020003e:	43660613          	addi	a2,a2,1078 # ffffffffc0206470 <end>
int kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
int kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	155010ef          	jal	ra,ffffffffc020199e <memset>
    cons_init();  // init the console
ffffffffc020004e:	3fc000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00002517          	auipc	a0,0x2
ffffffffc0200056:	95e50513          	addi	a0,a0,-1698 # ffffffffc02019b0 <etext>
ffffffffc020005a:	090000ef          	jal	ra,ffffffffc02000ea <cputs>

    print_kerninfo();
ffffffffc020005e:	0dc000ef          	jal	ra,ffffffffc020013a <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	402000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	262010ef          	jal	ra,ffffffffc02012c8 <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006a:	3fa000ef          	jal	ra,ffffffffc0200464 <idt_init>

    clock_init();   // init clock interrupt
ffffffffc020006e:	39a000ef          	jal	ra,ffffffffc0200408 <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200072:	3e6000ef          	jal	ra,ffffffffc0200458 <intr_enable>



    /* do nothing */
    while (1)
ffffffffc0200076:	a001                	j	ffffffffc0200076 <kern_init+0x44>

ffffffffc0200078 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200078:	1141                	addi	sp,sp,-16
ffffffffc020007a:	e022                	sd	s0,0(sp)
ffffffffc020007c:	e406                	sd	ra,8(sp)
ffffffffc020007e:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200080:	3cc000ef          	jal	ra,ffffffffc020044c <cons_putc>
    (*cnt) ++;
ffffffffc0200084:	401c                	lw	a5,0(s0)
}
ffffffffc0200086:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200088:	2785                	addiw	a5,a5,1
ffffffffc020008a:	c01c                	sw	a5,0(s0)
}
ffffffffc020008c:	6402                	ld	s0,0(sp)
ffffffffc020008e:	0141                	addi	sp,sp,16
ffffffffc0200090:	8082                	ret

ffffffffc0200092 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200092:	1101                	addi	sp,sp,-32
ffffffffc0200094:	862a                	mv	a2,a0
ffffffffc0200096:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200098:	00000517          	auipc	a0,0x0
ffffffffc020009c:	fe050513          	addi	a0,a0,-32 # ffffffffc0200078 <cputch>
ffffffffc02000a0:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a2:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a4:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a6:	422010ef          	jal	ra,ffffffffc02014c8 <vprintfmt>
    return cnt;
}
ffffffffc02000aa:	60e2                	ld	ra,24(sp)
ffffffffc02000ac:	4532                	lw	a0,12(sp)
ffffffffc02000ae:	6105                	addi	sp,sp,32
ffffffffc02000b0:	8082                	ret

ffffffffc02000b2 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000b2:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b4:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000b8:	8e2a                	mv	t3,a0
ffffffffc02000ba:	f42e                	sd	a1,40(sp)
ffffffffc02000bc:	f832                	sd	a2,48(sp)
ffffffffc02000be:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c0:	00000517          	auipc	a0,0x0
ffffffffc02000c4:	fb850513          	addi	a0,a0,-72 # ffffffffc0200078 <cputch>
ffffffffc02000c8:	004c                	addi	a1,sp,4
ffffffffc02000ca:	869a                	mv	a3,t1
ffffffffc02000cc:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000ce:	ec06                	sd	ra,24(sp)
ffffffffc02000d0:	e0ba                	sd	a4,64(sp)
ffffffffc02000d2:	e4be                	sd	a5,72(sp)
ffffffffc02000d4:	e8c2                	sd	a6,80(sp)
ffffffffc02000d6:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000d8:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000da:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000dc:	3ec010ef          	jal	ra,ffffffffc02014c8 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e0:	60e2                	ld	ra,24(sp)
ffffffffc02000e2:	4512                	lw	a0,4(sp)
ffffffffc02000e4:	6125                	addi	sp,sp,96
ffffffffc02000e6:	8082                	ret

ffffffffc02000e8 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000e8:	a695                	j	ffffffffc020044c <cons_putc>

ffffffffc02000ea <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000ea:	1101                	addi	sp,sp,-32
ffffffffc02000ec:	e822                	sd	s0,16(sp)
ffffffffc02000ee:	ec06                	sd	ra,24(sp)
ffffffffc02000f0:	e426                	sd	s1,8(sp)
ffffffffc02000f2:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f4:	00054503          	lbu	a0,0(a0)
ffffffffc02000f8:	c51d                	beqz	a0,ffffffffc0200126 <cputs+0x3c>
ffffffffc02000fa:	0405                	addi	s0,s0,1
ffffffffc02000fc:	4485                	li	s1,1
ffffffffc02000fe:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200100:	34c000ef          	jal	ra,ffffffffc020044c <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc0200104:	00044503          	lbu	a0,0(s0)
ffffffffc0200108:	008487bb          	addw	a5,s1,s0
ffffffffc020010c:	0405                	addi	s0,s0,1
ffffffffc020010e:	f96d                	bnez	a0,ffffffffc0200100 <cputs+0x16>
    (*cnt) ++;
ffffffffc0200110:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200114:	4529                	li	a0,10
ffffffffc0200116:	336000ef          	jal	ra,ffffffffc020044c <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011a:	60e2                	ld	ra,24(sp)
ffffffffc020011c:	8522                	mv	a0,s0
ffffffffc020011e:	6442                	ld	s0,16(sp)
ffffffffc0200120:	64a2                	ld	s1,8(sp)
ffffffffc0200122:	6105                	addi	sp,sp,32
ffffffffc0200124:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200126:	4405                	li	s0,1
ffffffffc0200128:	b7f5                	j	ffffffffc0200114 <cputs+0x2a>

ffffffffc020012a <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020012a:	1141                	addi	sp,sp,-16
ffffffffc020012c:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020012e:	326000ef          	jal	ra,ffffffffc0200454 <cons_getc>
ffffffffc0200132:	dd75                	beqz	a0,ffffffffc020012e <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200134:	60a2                	ld	ra,8(sp)
ffffffffc0200136:	0141                	addi	sp,sp,16
ffffffffc0200138:	8082                	ret

ffffffffc020013a <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020013a:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc020013c:	00002517          	auipc	a0,0x2
ffffffffc0200140:	89450513          	addi	a0,a0,-1900 # ffffffffc02019d0 <etext+0x20>
void print_kerninfo(void) {
ffffffffc0200144:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200146:	f6dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014a:	00000597          	auipc	a1,0x0
ffffffffc020014e:	ee858593          	addi	a1,a1,-280 # ffffffffc0200032 <kern_init>
ffffffffc0200152:	00002517          	auipc	a0,0x2
ffffffffc0200156:	89e50513          	addi	a0,a0,-1890 # ffffffffc02019f0 <etext+0x40>
ffffffffc020015a:	f59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020015e:	00002597          	auipc	a1,0x2
ffffffffc0200162:	85258593          	addi	a1,a1,-1966 # ffffffffc02019b0 <etext>
ffffffffc0200166:	00002517          	auipc	a0,0x2
ffffffffc020016a:	8aa50513          	addi	a0,a0,-1878 # ffffffffc0201a10 <etext+0x60>
ffffffffc020016e:	f45ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200172:	00006597          	auipc	a1,0x6
ffffffffc0200176:	e9e58593          	addi	a1,a1,-354 # ffffffffc0206010 <free_area>
ffffffffc020017a:	00002517          	auipc	a0,0x2
ffffffffc020017e:	8b650513          	addi	a0,a0,-1866 # ffffffffc0201a30 <etext+0x80>
ffffffffc0200182:	f31ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200186:	00006597          	auipc	a1,0x6
ffffffffc020018a:	2ea58593          	addi	a1,a1,746 # ffffffffc0206470 <end>
ffffffffc020018e:	00002517          	auipc	a0,0x2
ffffffffc0200192:	8c250513          	addi	a0,a0,-1854 # ffffffffc0201a50 <etext+0xa0>
ffffffffc0200196:	f1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019a:	00006597          	auipc	a1,0x6
ffffffffc020019e:	6d558593          	addi	a1,a1,1749 # ffffffffc020686f <end+0x3ff>
ffffffffc02001a2:	00000797          	auipc	a5,0x0
ffffffffc02001a6:	e9078793          	addi	a5,a5,-368 # ffffffffc0200032 <kern_init>
ffffffffc02001aa:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001ae:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001b2:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b4:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001b8:	95be                	add	a1,a1,a5
ffffffffc02001ba:	85a9                	srai	a1,a1,0xa
ffffffffc02001bc:	00002517          	auipc	a0,0x2
ffffffffc02001c0:	8b450513          	addi	a0,a0,-1868 # ffffffffc0201a70 <etext+0xc0>
}
ffffffffc02001c4:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001c6:	b5f5                	j	ffffffffc02000b2 <cprintf>

ffffffffc02001c8 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001c8:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001ca:	00002617          	auipc	a2,0x2
ffffffffc02001ce:	8d660613          	addi	a2,a2,-1834 # ffffffffc0201aa0 <etext+0xf0>
ffffffffc02001d2:	04e00593          	li	a1,78
ffffffffc02001d6:	00002517          	auipc	a0,0x2
ffffffffc02001da:	8e250513          	addi	a0,a0,-1822 # ffffffffc0201ab8 <etext+0x108>
void print_stackframe(void) {
ffffffffc02001de:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001e0:	1cc000ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02001e4 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001e4:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001e6:	00002617          	auipc	a2,0x2
ffffffffc02001ea:	8ea60613          	addi	a2,a2,-1814 # ffffffffc0201ad0 <etext+0x120>
ffffffffc02001ee:	00002597          	auipc	a1,0x2
ffffffffc02001f2:	90258593          	addi	a1,a1,-1790 # ffffffffc0201af0 <etext+0x140>
ffffffffc02001f6:	00002517          	auipc	a0,0x2
ffffffffc02001fa:	90250513          	addi	a0,a0,-1790 # ffffffffc0201af8 <etext+0x148>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001fe:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200200:	eb3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200204:	00002617          	auipc	a2,0x2
ffffffffc0200208:	90460613          	addi	a2,a2,-1788 # ffffffffc0201b08 <etext+0x158>
ffffffffc020020c:	00002597          	auipc	a1,0x2
ffffffffc0200210:	92458593          	addi	a1,a1,-1756 # ffffffffc0201b30 <etext+0x180>
ffffffffc0200214:	00002517          	auipc	a0,0x2
ffffffffc0200218:	8e450513          	addi	a0,a0,-1820 # ffffffffc0201af8 <etext+0x148>
ffffffffc020021c:	e97ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200220:	00002617          	auipc	a2,0x2
ffffffffc0200224:	92060613          	addi	a2,a2,-1760 # ffffffffc0201b40 <etext+0x190>
ffffffffc0200228:	00002597          	auipc	a1,0x2
ffffffffc020022c:	93858593          	addi	a1,a1,-1736 # ffffffffc0201b60 <etext+0x1b0>
ffffffffc0200230:	00002517          	auipc	a0,0x2
ffffffffc0200234:	8c850513          	addi	a0,a0,-1848 # ffffffffc0201af8 <etext+0x148>
ffffffffc0200238:	e7bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    }
    return 0;
}
ffffffffc020023c:	60a2                	ld	ra,8(sp)
ffffffffc020023e:	4501                	li	a0,0
ffffffffc0200240:	0141                	addi	sp,sp,16
ffffffffc0200242:	8082                	ret

ffffffffc0200244 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200244:	1141                	addi	sp,sp,-16
ffffffffc0200246:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200248:	ef3ff0ef          	jal	ra,ffffffffc020013a <print_kerninfo>
    return 0;
}
ffffffffc020024c:	60a2                	ld	ra,8(sp)
ffffffffc020024e:	4501                	li	a0,0
ffffffffc0200250:	0141                	addi	sp,sp,16
ffffffffc0200252:	8082                	ret

ffffffffc0200254 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200254:	1141                	addi	sp,sp,-16
ffffffffc0200256:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200258:	f71ff0ef          	jal	ra,ffffffffc02001c8 <print_stackframe>
    return 0;
}
ffffffffc020025c:	60a2                	ld	ra,8(sp)
ffffffffc020025e:	4501                	li	a0,0
ffffffffc0200260:	0141                	addi	sp,sp,16
ffffffffc0200262:	8082                	ret

ffffffffc0200264 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200264:	7115                	addi	sp,sp,-224
ffffffffc0200266:	ed5e                	sd	s7,152(sp)
ffffffffc0200268:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020026a:	00002517          	auipc	a0,0x2
ffffffffc020026e:	90650513          	addi	a0,a0,-1786 # ffffffffc0201b70 <etext+0x1c0>
kmonitor(struct trapframe *tf) {
ffffffffc0200272:	ed86                	sd	ra,216(sp)
ffffffffc0200274:	e9a2                	sd	s0,208(sp)
ffffffffc0200276:	e5a6                	sd	s1,200(sp)
ffffffffc0200278:	e1ca                	sd	s2,192(sp)
ffffffffc020027a:	fd4e                	sd	s3,184(sp)
ffffffffc020027c:	f952                	sd	s4,176(sp)
ffffffffc020027e:	f556                	sd	s5,168(sp)
ffffffffc0200280:	f15a                	sd	s6,160(sp)
ffffffffc0200282:	e962                	sd	s8,144(sp)
ffffffffc0200284:	e566                	sd	s9,136(sp)
ffffffffc0200286:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200288:	e2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020028c:	00002517          	auipc	a0,0x2
ffffffffc0200290:	90c50513          	addi	a0,a0,-1780 # ffffffffc0201b98 <etext+0x1e8>
ffffffffc0200294:	e1fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    if (tf != NULL) {
ffffffffc0200298:	000b8563          	beqz	s7,ffffffffc02002a2 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020029c:	855e                	mv	a0,s7
ffffffffc020029e:	3a4000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002a2:	00002c17          	auipc	s8,0x2
ffffffffc02002a6:	966c0c13          	addi	s8,s8,-1690 # ffffffffc0201c08 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002aa:	00002917          	auipc	s2,0x2
ffffffffc02002ae:	91690913          	addi	s2,s2,-1770 # ffffffffc0201bc0 <etext+0x210>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b2:	00002497          	auipc	s1,0x2
ffffffffc02002b6:	91648493          	addi	s1,s1,-1770 # ffffffffc0201bc8 <etext+0x218>
        if (argc == MAXARGS - 1) {
ffffffffc02002ba:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002bc:	00002b17          	auipc	s6,0x2
ffffffffc02002c0:	914b0b13          	addi	s6,s6,-1772 # ffffffffc0201bd0 <etext+0x220>
        argv[argc ++] = buf;
ffffffffc02002c4:	00002a17          	auipc	s4,0x2
ffffffffc02002c8:	82ca0a13          	addi	s4,s4,-2004 # ffffffffc0201af0 <etext+0x140>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002cc:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002ce:	854a                	mv	a0,s2
ffffffffc02002d0:	57a010ef          	jal	ra,ffffffffc020184a <readline>
ffffffffc02002d4:	842a                	mv	s0,a0
ffffffffc02002d6:	dd65                	beqz	a0,ffffffffc02002ce <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002d8:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002dc:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002de:	e1bd                	bnez	a1,ffffffffc0200344 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc02002e0:	fe0c87e3          	beqz	s9,ffffffffc02002ce <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002e4:	6582                	ld	a1,0(sp)
ffffffffc02002e6:	00002d17          	auipc	s10,0x2
ffffffffc02002ea:	922d0d13          	addi	s10,s10,-1758 # ffffffffc0201c08 <commands>
        argv[argc ++] = buf;
ffffffffc02002ee:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f0:	4401                	li	s0,0
ffffffffc02002f2:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002f4:	676010ef          	jal	ra,ffffffffc020196a <strcmp>
ffffffffc02002f8:	c919                	beqz	a0,ffffffffc020030e <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002fa:	2405                	addiw	s0,s0,1
ffffffffc02002fc:	0b540063          	beq	s0,s5,ffffffffc020039c <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200300:	000d3503          	ld	a0,0(s10)
ffffffffc0200304:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200306:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200308:	662010ef          	jal	ra,ffffffffc020196a <strcmp>
ffffffffc020030c:	f57d                	bnez	a0,ffffffffc02002fa <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020030e:	00141793          	slli	a5,s0,0x1
ffffffffc0200312:	97a2                	add	a5,a5,s0
ffffffffc0200314:	078e                	slli	a5,a5,0x3
ffffffffc0200316:	97e2                	add	a5,a5,s8
ffffffffc0200318:	6b9c                	ld	a5,16(a5)
ffffffffc020031a:	865e                	mv	a2,s7
ffffffffc020031c:	002c                	addi	a1,sp,8
ffffffffc020031e:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200322:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200324:	fa0555e3          	bgez	a0,ffffffffc02002ce <kmonitor+0x6a>
}
ffffffffc0200328:	60ee                	ld	ra,216(sp)
ffffffffc020032a:	644e                	ld	s0,208(sp)
ffffffffc020032c:	64ae                	ld	s1,200(sp)
ffffffffc020032e:	690e                	ld	s2,192(sp)
ffffffffc0200330:	79ea                	ld	s3,184(sp)
ffffffffc0200332:	7a4a                	ld	s4,176(sp)
ffffffffc0200334:	7aaa                	ld	s5,168(sp)
ffffffffc0200336:	7b0a                	ld	s6,160(sp)
ffffffffc0200338:	6bea                	ld	s7,152(sp)
ffffffffc020033a:	6c4a                	ld	s8,144(sp)
ffffffffc020033c:	6caa                	ld	s9,136(sp)
ffffffffc020033e:	6d0a                	ld	s10,128(sp)
ffffffffc0200340:	612d                	addi	sp,sp,224
ffffffffc0200342:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200344:	8526                	mv	a0,s1
ffffffffc0200346:	642010ef          	jal	ra,ffffffffc0201988 <strchr>
ffffffffc020034a:	c901                	beqz	a0,ffffffffc020035a <kmonitor+0xf6>
ffffffffc020034c:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200350:	00040023          	sb	zero,0(s0)
ffffffffc0200354:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200356:	d5c9                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200358:	b7f5                	j	ffffffffc0200344 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc020035a:	00044783          	lbu	a5,0(s0)
ffffffffc020035e:	d3c9                	beqz	a5,ffffffffc02002e0 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc0200360:	033c8963          	beq	s9,s3,ffffffffc0200392 <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc0200364:	003c9793          	slli	a5,s9,0x3
ffffffffc0200368:	0118                	addi	a4,sp,128
ffffffffc020036a:	97ba                	add	a5,a5,a4
ffffffffc020036c:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200370:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200374:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200376:	e591                	bnez	a1,ffffffffc0200382 <kmonitor+0x11e>
ffffffffc0200378:	b7b5                	j	ffffffffc02002e4 <kmonitor+0x80>
ffffffffc020037a:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc020037e:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200380:	d1a5                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200382:	8526                	mv	a0,s1
ffffffffc0200384:	604010ef          	jal	ra,ffffffffc0201988 <strchr>
ffffffffc0200388:	d96d                	beqz	a0,ffffffffc020037a <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020038a:	00044583          	lbu	a1,0(s0)
ffffffffc020038e:	d9a9                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200390:	bf55                	j	ffffffffc0200344 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200392:	45c1                	li	a1,16
ffffffffc0200394:	855a                	mv	a0,s6
ffffffffc0200396:	d1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020039a:	b7e9                	j	ffffffffc0200364 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020039c:	6582                	ld	a1,0(sp)
ffffffffc020039e:	00002517          	auipc	a0,0x2
ffffffffc02003a2:	85250513          	addi	a0,a0,-1966 # ffffffffc0201bf0 <etext+0x240>
ffffffffc02003a6:	d0dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    return 0;
ffffffffc02003aa:	b715                	j	ffffffffc02002ce <kmonitor+0x6a>

ffffffffc02003ac <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003ac:	00006317          	auipc	t1,0x6
ffffffffc02003b0:	07c30313          	addi	t1,t1,124 # ffffffffc0206428 <is_panic>
ffffffffc02003b4:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003b8:	715d                	addi	sp,sp,-80
ffffffffc02003ba:	ec06                	sd	ra,24(sp)
ffffffffc02003bc:	e822                	sd	s0,16(sp)
ffffffffc02003be:	f436                	sd	a3,40(sp)
ffffffffc02003c0:	f83a                	sd	a4,48(sp)
ffffffffc02003c2:	fc3e                	sd	a5,56(sp)
ffffffffc02003c4:	e0c2                	sd	a6,64(sp)
ffffffffc02003c6:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003c8:	020e1a63          	bnez	t3,ffffffffc02003fc <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003cc:	4785                	li	a5,1
ffffffffc02003ce:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc02003d2:	8432                	mv	s0,a2
ffffffffc02003d4:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003d6:	862e                	mv	a2,a1
ffffffffc02003d8:	85aa                	mv	a1,a0
ffffffffc02003da:	00002517          	auipc	a0,0x2
ffffffffc02003de:	87650513          	addi	a0,a0,-1930 # ffffffffc0201c50 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02003e2:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e4:	ccfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003e8:	65a2                	ld	a1,8(sp)
ffffffffc02003ea:	8522                	mv	a0,s0
ffffffffc02003ec:	ca7ff0ef          	jal	ra,ffffffffc0200092 <vcprintf>
    cprintf("\n");
ffffffffc02003f0:	00001517          	auipc	a0,0x1
ffffffffc02003f4:	6a850513          	addi	a0,a0,1704 # ffffffffc0201a98 <etext+0xe8>
ffffffffc02003f8:	cbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003fc:	062000ef          	jal	ra,ffffffffc020045e <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200400:	4501                	li	a0,0
ffffffffc0200402:	e63ff0ef          	jal	ra,ffffffffc0200264 <kmonitor>
    while (1) {
ffffffffc0200406:	bfed                	j	ffffffffc0200400 <__panic+0x54>

ffffffffc0200408 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc0200408:	1141                	addi	sp,sp,-16
ffffffffc020040a:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc020040c:	02000793          	li	a5,32
ffffffffc0200410:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200414:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200418:	67e1                	lui	a5,0x18
ffffffffc020041a:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc020041e:	953e                	add	a0,a0,a5
ffffffffc0200420:	4f8010ef          	jal	ra,ffffffffc0201918 <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00006797          	auipc	a5,0x6
ffffffffc020042a:	0007b523          	sd	zero,10(a5) # ffffffffc0206430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00002517          	auipc	a0,0x2
ffffffffc0200432:	84250513          	addi	a0,a0,-1982 # ffffffffc0201c70 <commands+0x68>
}
ffffffffc0200436:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc0200438:	b9ad                	j	ffffffffc02000b2 <cprintf>

ffffffffc020043a <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020043a:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020043e:	67e1                	lui	a5,0x18
ffffffffc0200440:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200444:	953e                	add	a0,a0,a5
ffffffffc0200446:	4d20106f          	j	ffffffffc0201918 <sbi_set_timer>

ffffffffc020044a <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc020044a:	8082                	ret

ffffffffc020044c <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc020044c:	0ff57513          	zext.b	a0,a0
ffffffffc0200450:	4ae0106f          	j	ffffffffc02018fe <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	4de0106f          	j	ffffffffc0201932 <sbi_console_getchar>

ffffffffc0200458 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200458:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020045c:	8082                	ret

ffffffffc020045e <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045e:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200464:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200468:	00000797          	auipc	a5,0x0
ffffffffc020046c:	2e478793          	addi	a5,a5,740 # ffffffffc020074c <__alltraps>
ffffffffc0200470:	10579073          	csrw	stvec,a5
}
ffffffffc0200474:	8082                	ret

ffffffffc0200476 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200476:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200478:	1141                	addi	sp,sp,-16
ffffffffc020047a:	e022                	sd	s0,0(sp)
ffffffffc020047c:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047e:	00002517          	auipc	a0,0x2
ffffffffc0200482:	81250513          	addi	a0,a0,-2030 # ffffffffc0201c90 <commands+0x88>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00002517          	auipc	a0,0x2
ffffffffc0200492:	81a50513          	addi	a0,a0,-2022 # ffffffffc0201ca8 <commands+0xa0>
ffffffffc0200496:	c1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00002517          	auipc	a0,0x2
ffffffffc02004a0:	82450513          	addi	a0,a0,-2012 # ffffffffc0201cc0 <commands+0xb8>
ffffffffc02004a4:	c0fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00002517          	auipc	a0,0x2
ffffffffc02004ae:	82e50513          	addi	a0,a0,-2002 # ffffffffc0201cd8 <commands+0xd0>
ffffffffc02004b2:	c01ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00002517          	auipc	a0,0x2
ffffffffc02004bc:	83850513          	addi	a0,a0,-1992 # ffffffffc0201cf0 <commands+0xe8>
ffffffffc02004c0:	bf3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00002517          	auipc	a0,0x2
ffffffffc02004ca:	84250513          	addi	a0,a0,-1982 # ffffffffc0201d08 <commands+0x100>
ffffffffc02004ce:	be5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00002517          	auipc	a0,0x2
ffffffffc02004d8:	84c50513          	addi	a0,a0,-1972 # ffffffffc0201d20 <commands+0x118>
ffffffffc02004dc:	bd7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00002517          	auipc	a0,0x2
ffffffffc02004e6:	85650513          	addi	a0,a0,-1962 # ffffffffc0201d38 <commands+0x130>
ffffffffc02004ea:	bc9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00002517          	auipc	a0,0x2
ffffffffc02004f4:	86050513          	addi	a0,a0,-1952 # ffffffffc0201d50 <commands+0x148>
ffffffffc02004f8:	bbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00002517          	auipc	a0,0x2
ffffffffc0200502:	86a50513          	addi	a0,a0,-1942 # ffffffffc0201d68 <commands+0x160>
ffffffffc0200506:	badff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00002517          	auipc	a0,0x2
ffffffffc0200510:	87450513          	addi	a0,a0,-1932 # ffffffffc0201d80 <commands+0x178>
ffffffffc0200514:	b9fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00002517          	auipc	a0,0x2
ffffffffc020051e:	87e50513          	addi	a0,a0,-1922 # ffffffffc0201d98 <commands+0x190>
ffffffffc0200522:	b91ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00002517          	auipc	a0,0x2
ffffffffc020052c:	88850513          	addi	a0,a0,-1912 # ffffffffc0201db0 <commands+0x1a8>
ffffffffc0200530:	b83ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00002517          	auipc	a0,0x2
ffffffffc020053a:	89250513          	addi	a0,a0,-1902 # ffffffffc0201dc8 <commands+0x1c0>
ffffffffc020053e:	b75ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00002517          	auipc	a0,0x2
ffffffffc0200548:	89c50513          	addi	a0,a0,-1892 # ffffffffc0201de0 <commands+0x1d8>
ffffffffc020054c:	b67ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00002517          	auipc	a0,0x2
ffffffffc0200556:	8a650513          	addi	a0,a0,-1882 # ffffffffc0201df8 <commands+0x1f0>
ffffffffc020055a:	b59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00002517          	auipc	a0,0x2
ffffffffc0200564:	8b050513          	addi	a0,a0,-1872 # ffffffffc0201e10 <commands+0x208>
ffffffffc0200568:	b4bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00002517          	auipc	a0,0x2
ffffffffc0200572:	8ba50513          	addi	a0,a0,-1862 # ffffffffc0201e28 <commands+0x220>
ffffffffc0200576:	b3dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00002517          	auipc	a0,0x2
ffffffffc0200580:	8c450513          	addi	a0,a0,-1852 # ffffffffc0201e40 <commands+0x238>
ffffffffc0200584:	b2fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00002517          	auipc	a0,0x2
ffffffffc020058e:	8ce50513          	addi	a0,a0,-1842 # ffffffffc0201e58 <commands+0x250>
ffffffffc0200592:	b21ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00002517          	auipc	a0,0x2
ffffffffc020059c:	8d850513          	addi	a0,a0,-1832 # ffffffffc0201e70 <commands+0x268>
ffffffffc02005a0:	b13ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00002517          	auipc	a0,0x2
ffffffffc02005aa:	8e250513          	addi	a0,a0,-1822 # ffffffffc0201e88 <commands+0x280>
ffffffffc02005ae:	b05ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00002517          	auipc	a0,0x2
ffffffffc02005b8:	8ec50513          	addi	a0,a0,-1812 # ffffffffc0201ea0 <commands+0x298>
ffffffffc02005bc:	af7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00002517          	auipc	a0,0x2
ffffffffc02005c6:	8f650513          	addi	a0,a0,-1802 # ffffffffc0201eb8 <commands+0x2b0>
ffffffffc02005ca:	ae9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00002517          	auipc	a0,0x2
ffffffffc02005d4:	90050513          	addi	a0,a0,-1792 # ffffffffc0201ed0 <commands+0x2c8>
ffffffffc02005d8:	adbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00002517          	auipc	a0,0x2
ffffffffc02005e2:	90a50513          	addi	a0,a0,-1782 # ffffffffc0201ee8 <commands+0x2e0>
ffffffffc02005e6:	acdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00002517          	auipc	a0,0x2
ffffffffc02005f0:	91450513          	addi	a0,a0,-1772 # ffffffffc0201f00 <commands+0x2f8>
ffffffffc02005f4:	abfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00002517          	auipc	a0,0x2
ffffffffc02005fe:	91e50513          	addi	a0,a0,-1762 # ffffffffc0201f18 <commands+0x310>
ffffffffc0200602:	ab1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00002517          	auipc	a0,0x2
ffffffffc020060c:	92850513          	addi	a0,a0,-1752 # ffffffffc0201f30 <commands+0x328>
ffffffffc0200610:	aa3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00002517          	auipc	a0,0x2
ffffffffc020061a:	93250513          	addi	a0,a0,-1742 # ffffffffc0201f48 <commands+0x340>
ffffffffc020061e:	a95ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00002517          	auipc	a0,0x2
ffffffffc0200628:	93c50513          	addi	a0,a0,-1732 # ffffffffc0201f60 <commands+0x358>
ffffffffc020062c:	a87ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00002517          	auipc	a0,0x2
ffffffffc020063a:	94250513          	addi	a0,a0,-1726 # ffffffffc0201f78 <commands+0x370>
}
ffffffffc020063e:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200640:	bc8d                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200642 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200642:	1141                	addi	sp,sp,-16
ffffffffc0200644:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200646:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200648:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020064a:	00002517          	auipc	a0,0x2
ffffffffc020064e:	94650513          	addi	a0,a0,-1722 # ffffffffc0201f90 <commands+0x388>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200652:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200654:	a5fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200658:	8522                	mv	a0,s0
ffffffffc020065a:	e1dff0ef          	jal	ra,ffffffffc0200476 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020065e:	10043583          	ld	a1,256(s0)
ffffffffc0200662:	00002517          	auipc	a0,0x2
ffffffffc0200666:	94650513          	addi	a0,a0,-1722 # ffffffffc0201fa8 <commands+0x3a0>
ffffffffc020066a:	a49ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00002517          	auipc	a0,0x2
ffffffffc0200676:	94e50513          	addi	a0,a0,-1714 # ffffffffc0201fc0 <commands+0x3b8>
ffffffffc020067a:	a39ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00002517          	auipc	a0,0x2
ffffffffc0200686:	95650513          	addi	a0,a0,-1706 # ffffffffc0201fd8 <commands+0x3d0>
ffffffffc020068a:	a29ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00002517          	auipc	a0,0x2
ffffffffc020069a:	95a50513          	addi	a0,a0,-1702 # ffffffffc0201ff0 <commands+0x3e8>
}
ffffffffc020069e:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a0:	bc09                	j	ffffffffc02000b2 <cprintf>

ffffffffc02006a2 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006a2:	11853783          	ld	a5,280(a0)
ffffffffc02006a6:	472d                	li	a4,11
ffffffffc02006a8:	0786                	slli	a5,a5,0x1
ffffffffc02006aa:	8385                	srli	a5,a5,0x1
ffffffffc02006ac:	06f76c63          	bltu	a4,a5,ffffffffc0200724 <interrupt_handler+0x82>
ffffffffc02006b0:	00002717          	auipc	a4,0x2
ffffffffc02006b4:	a2070713          	addi	a4,a4,-1504 # ffffffffc02020d0 <commands+0x4c8>
ffffffffc02006b8:	078a                	slli	a5,a5,0x2
ffffffffc02006ba:	97ba                	add	a5,a5,a4
ffffffffc02006bc:	439c                	lw	a5,0(a5)
ffffffffc02006be:	97ba                	add	a5,a5,a4
ffffffffc02006c0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006c2:	00002517          	auipc	a0,0x2
ffffffffc02006c6:	9a650513          	addi	a0,a0,-1626 # ffffffffc0202068 <commands+0x460>
ffffffffc02006ca:	b2e5                	j	ffffffffc02000b2 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00002517          	auipc	a0,0x2
ffffffffc02006d0:	97c50513          	addi	a0,a0,-1668 # ffffffffc0202048 <commands+0x440>
ffffffffc02006d4:	baf9                	j	ffffffffc02000b2 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00002517          	auipc	a0,0x2
ffffffffc02006da:	93250513          	addi	a0,a0,-1742 # ffffffffc0202008 <commands+0x400>
ffffffffc02006de:	bad1                	j	ffffffffc02000b2 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00002517          	auipc	a0,0x2
ffffffffc02006e4:	9a850513          	addi	a0,a0,-1624 # ffffffffc0202088 <commands+0x480>
ffffffffc02006e8:	b2e9                	j	ffffffffc02000b2 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006ea:	1141                	addi	sp,sp,-16
ffffffffc02006ec:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02006ee:	d4dff0ef          	jal	ra,ffffffffc020043a <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc02006f2:	00006697          	auipc	a3,0x6
ffffffffc02006f6:	d3e68693          	addi	a3,a3,-706 # ffffffffc0206430 <ticks>
ffffffffc02006fa:	629c                	ld	a5,0(a3)
ffffffffc02006fc:	06400713          	li	a4,100
ffffffffc0200700:	0785                	addi	a5,a5,1
ffffffffc0200702:	02e7f733          	remu	a4,a5,a4
ffffffffc0200706:	e29c                	sd	a5,0(a3)
ffffffffc0200708:	cf19                	beqz	a4,ffffffffc0200726 <interrupt_handler+0x84>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020070a:	60a2                	ld	ra,8(sp)
ffffffffc020070c:	0141                	addi	sp,sp,16
ffffffffc020070e:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200710:	00002517          	auipc	a0,0x2
ffffffffc0200714:	9a050513          	addi	a0,a0,-1632 # ffffffffc02020b0 <commands+0x4a8>
ffffffffc0200718:	ba69                	j	ffffffffc02000b2 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc020071a:	00002517          	auipc	a0,0x2
ffffffffc020071e:	90e50513          	addi	a0,a0,-1778 # ffffffffc0202028 <commands+0x420>
ffffffffc0200722:	ba41                	j	ffffffffc02000b2 <cprintf>
            print_trapframe(tf);
ffffffffc0200724:	bf39                	j	ffffffffc0200642 <print_trapframe>
}
ffffffffc0200726:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200728:	06400593          	li	a1,100
ffffffffc020072c:	00002517          	auipc	a0,0x2
ffffffffc0200730:	97450513          	addi	a0,a0,-1676 # ffffffffc02020a0 <commands+0x498>
}
ffffffffc0200734:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200736:	bab5                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200738 <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200738:	11853783          	ld	a5,280(a0)
ffffffffc020073c:	0007c763          	bltz	a5,ffffffffc020074a <trap+0x12>
    switch (tf->cause) {
ffffffffc0200740:	472d                	li	a4,11
ffffffffc0200742:	00f76363          	bltu	a4,a5,ffffffffc0200748 <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc0200746:	8082                	ret
            print_trapframe(tf);
ffffffffc0200748:	bded                	j	ffffffffc0200642 <print_trapframe>
        interrupt_handler(tf);
ffffffffc020074a:	bfa1                	j	ffffffffc02006a2 <interrupt_handler>

ffffffffc020074c <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc020074c:	14011073          	csrw	sscratch,sp
ffffffffc0200750:	712d                	addi	sp,sp,-288
ffffffffc0200752:	e002                	sd	zero,0(sp)
ffffffffc0200754:	e406                	sd	ra,8(sp)
ffffffffc0200756:	ec0e                	sd	gp,24(sp)
ffffffffc0200758:	f012                	sd	tp,32(sp)
ffffffffc020075a:	f416                	sd	t0,40(sp)
ffffffffc020075c:	f81a                	sd	t1,48(sp)
ffffffffc020075e:	fc1e                	sd	t2,56(sp)
ffffffffc0200760:	e0a2                	sd	s0,64(sp)
ffffffffc0200762:	e4a6                	sd	s1,72(sp)
ffffffffc0200764:	e8aa                	sd	a0,80(sp)
ffffffffc0200766:	ecae                	sd	a1,88(sp)
ffffffffc0200768:	f0b2                	sd	a2,96(sp)
ffffffffc020076a:	f4b6                	sd	a3,104(sp)
ffffffffc020076c:	f8ba                	sd	a4,112(sp)
ffffffffc020076e:	fcbe                	sd	a5,120(sp)
ffffffffc0200770:	e142                	sd	a6,128(sp)
ffffffffc0200772:	e546                	sd	a7,136(sp)
ffffffffc0200774:	e94a                	sd	s2,144(sp)
ffffffffc0200776:	ed4e                	sd	s3,152(sp)
ffffffffc0200778:	f152                	sd	s4,160(sp)
ffffffffc020077a:	f556                	sd	s5,168(sp)
ffffffffc020077c:	f95a                	sd	s6,176(sp)
ffffffffc020077e:	fd5e                	sd	s7,184(sp)
ffffffffc0200780:	e1e2                	sd	s8,192(sp)
ffffffffc0200782:	e5e6                	sd	s9,200(sp)
ffffffffc0200784:	e9ea                	sd	s10,208(sp)
ffffffffc0200786:	edee                	sd	s11,216(sp)
ffffffffc0200788:	f1f2                	sd	t3,224(sp)
ffffffffc020078a:	f5f6                	sd	t4,232(sp)
ffffffffc020078c:	f9fa                	sd	t5,240(sp)
ffffffffc020078e:	fdfe                	sd	t6,248(sp)
ffffffffc0200790:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200794:	100024f3          	csrr	s1,sstatus
ffffffffc0200798:	14102973          	csrr	s2,sepc
ffffffffc020079c:	143029f3          	csrr	s3,stval
ffffffffc02007a0:	14202a73          	csrr	s4,scause
ffffffffc02007a4:	e822                	sd	s0,16(sp)
ffffffffc02007a6:	e226                	sd	s1,256(sp)
ffffffffc02007a8:	e64a                	sd	s2,264(sp)
ffffffffc02007aa:	ea4e                	sd	s3,272(sp)
ffffffffc02007ac:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02007ae:	850a                	mv	a0,sp
    jal trap
ffffffffc02007b0:	f89ff0ef          	jal	ra,ffffffffc0200738 <trap>

ffffffffc02007b4 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02007b4:	6492                	ld	s1,256(sp)
ffffffffc02007b6:	6932                	ld	s2,264(sp)
ffffffffc02007b8:	10049073          	csrw	sstatus,s1
ffffffffc02007bc:	14191073          	csrw	sepc,s2
ffffffffc02007c0:	60a2                	ld	ra,8(sp)
ffffffffc02007c2:	61e2                	ld	gp,24(sp)
ffffffffc02007c4:	7202                	ld	tp,32(sp)
ffffffffc02007c6:	72a2                	ld	t0,40(sp)
ffffffffc02007c8:	7342                	ld	t1,48(sp)
ffffffffc02007ca:	73e2                	ld	t2,56(sp)
ffffffffc02007cc:	6406                	ld	s0,64(sp)
ffffffffc02007ce:	64a6                	ld	s1,72(sp)
ffffffffc02007d0:	6546                	ld	a0,80(sp)
ffffffffc02007d2:	65e6                	ld	a1,88(sp)
ffffffffc02007d4:	7606                	ld	a2,96(sp)
ffffffffc02007d6:	76a6                	ld	a3,104(sp)
ffffffffc02007d8:	7746                	ld	a4,112(sp)
ffffffffc02007da:	77e6                	ld	a5,120(sp)
ffffffffc02007dc:	680a                	ld	a6,128(sp)
ffffffffc02007de:	68aa                	ld	a7,136(sp)
ffffffffc02007e0:	694a                	ld	s2,144(sp)
ffffffffc02007e2:	69ea                	ld	s3,152(sp)
ffffffffc02007e4:	7a0a                	ld	s4,160(sp)
ffffffffc02007e6:	7aaa                	ld	s5,168(sp)
ffffffffc02007e8:	7b4a                	ld	s6,176(sp)
ffffffffc02007ea:	7bea                	ld	s7,184(sp)
ffffffffc02007ec:	6c0e                	ld	s8,192(sp)
ffffffffc02007ee:	6cae                	ld	s9,200(sp)
ffffffffc02007f0:	6d4e                	ld	s10,208(sp)
ffffffffc02007f2:	6dee                	ld	s11,216(sp)
ffffffffc02007f4:	7e0e                	ld	t3,224(sp)
ffffffffc02007f6:	7eae                	ld	t4,232(sp)
ffffffffc02007f8:	7f4e                	ld	t5,240(sp)
ffffffffc02007fa:	7fee                	ld	t6,248(sp)
ffffffffc02007fc:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc02007fe:	10200073          	sret

ffffffffc0200802 <best_fit_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200802:	00006797          	auipc	a5,0x6
ffffffffc0200806:	80e78793          	addi	a5,a5,-2034 # ffffffffc0206010 <free_area>
ffffffffc020080a:	e79c                	sd	a5,8(a5)
ffffffffc020080c:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
best_fit_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc020080e:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200812:	8082                	ret

ffffffffc0200814 <best_fit_nr_free_pages>:
}

static size_t
best_fit_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200814:	00006517          	auipc	a0,0x6
ffffffffc0200818:	80c56503          	lwu	a0,-2036(a0) # ffffffffc0206020 <free_area+0x10>
ffffffffc020081c:	8082                	ret

ffffffffc020081e <best_fit_check>:
}

// LAB2: below code is used to check the best fit allocation algorithm 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
best_fit_check(void) {
ffffffffc020081e:	715d                	addi	sp,sp,-80
ffffffffc0200820:	e0a2                	sd	s0,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200822:	00005417          	auipc	s0,0x5
ffffffffc0200826:	7ee40413          	addi	s0,s0,2030 # ffffffffc0206010 <free_area>
ffffffffc020082a:	641c                	ld	a5,8(s0)
ffffffffc020082c:	e486                	sd	ra,72(sp)
ffffffffc020082e:	fc26                	sd	s1,56(sp)
ffffffffc0200830:	f84a                	sd	s2,48(sp)
ffffffffc0200832:	f44e                	sd	s3,40(sp)
ffffffffc0200834:	f052                	sd	s4,32(sp)
ffffffffc0200836:	ec56                	sd	s5,24(sp)
ffffffffc0200838:	e85a                	sd	s6,16(sp)
ffffffffc020083a:	e45e                	sd	s7,8(sp)
ffffffffc020083c:	e062                	sd	s8,0(sp)
    int score = 0 ,sumscore = 6;
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc020083e:	26878b63          	beq	a5,s0,ffffffffc0200ab4 <best_fit_check+0x296>
    int count = 0, total = 0;
ffffffffc0200842:	4481                	li	s1,0
ffffffffc0200844:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200846:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc020084a:	8b09                	andi	a4,a4,2
ffffffffc020084c:	26070863          	beqz	a4,ffffffffc0200abc <best_fit_check+0x29e>
        count ++, total += p->property;
ffffffffc0200850:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200854:	679c                	ld	a5,8(a5)
ffffffffc0200856:	2905                	addiw	s2,s2,1
ffffffffc0200858:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc020085a:	fe8796e3          	bne	a5,s0,ffffffffc0200846 <best_fit_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc020085e:	89a6                	mv	s3,s1
ffffffffc0200860:	22f000ef          	jal	ra,ffffffffc020128e <nr_free_pages>
ffffffffc0200864:	33351c63          	bne	a0,s3,ffffffffc0200b9c <best_fit_check+0x37e>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200868:	4505                	li	a0,1
ffffffffc020086a:	1a7000ef          	jal	ra,ffffffffc0201210 <alloc_pages>
ffffffffc020086e:	8a2a                	mv	s4,a0
ffffffffc0200870:	36050663          	beqz	a0,ffffffffc0200bdc <best_fit_check+0x3be>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200874:	4505                	li	a0,1
ffffffffc0200876:	19b000ef          	jal	ra,ffffffffc0201210 <alloc_pages>
ffffffffc020087a:	89aa                	mv	s3,a0
ffffffffc020087c:	34050063          	beqz	a0,ffffffffc0200bbc <best_fit_check+0x39e>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200880:	4505                	li	a0,1
ffffffffc0200882:	18f000ef          	jal	ra,ffffffffc0201210 <alloc_pages>
ffffffffc0200886:	8aaa                	mv	s5,a0
ffffffffc0200888:	2c050a63          	beqz	a0,ffffffffc0200b5c <best_fit_check+0x33e>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc020088c:	253a0863          	beq	s4,s3,ffffffffc0200adc <best_fit_check+0x2be>
ffffffffc0200890:	24aa0663          	beq	s4,a0,ffffffffc0200adc <best_fit_check+0x2be>
ffffffffc0200894:	24a98463          	beq	s3,a0,ffffffffc0200adc <best_fit_check+0x2be>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200898:	000a2783          	lw	a5,0(s4)
ffffffffc020089c:	26079063          	bnez	a5,ffffffffc0200afc <best_fit_check+0x2de>
ffffffffc02008a0:	0009a783          	lw	a5,0(s3)
ffffffffc02008a4:	24079c63          	bnez	a5,ffffffffc0200afc <best_fit_check+0x2de>
ffffffffc02008a8:	411c                	lw	a5,0(a0)
ffffffffc02008aa:	24079963          	bnez	a5,ffffffffc0200afc <best_fit_check+0x2de>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02008ae:	00006797          	auipc	a5,0x6
ffffffffc02008b2:	b927b783          	ld	a5,-1134(a5) # ffffffffc0206440 <pages>
ffffffffc02008b6:	40fa0733          	sub	a4,s4,a5
ffffffffc02008ba:	870d                	srai	a4,a4,0x3
ffffffffc02008bc:	00002597          	auipc	a1,0x2
ffffffffc02008c0:	f345b583          	ld	a1,-204(a1) # ffffffffc02027f0 <error_string+0x38>
ffffffffc02008c4:	02b70733          	mul	a4,a4,a1
ffffffffc02008c8:	00002617          	auipc	a2,0x2
ffffffffc02008cc:	f3063603          	ld	a2,-208(a2) # ffffffffc02027f8 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02008d0:	00006697          	auipc	a3,0x6
ffffffffc02008d4:	b686b683          	ld	a3,-1176(a3) # ffffffffc0206438 <npage>
ffffffffc02008d8:	06b2                	slli	a3,a3,0xc
ffffffffc02008da:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc02008dc:	0732                	slli	a4,a4,0xc
ffffffffc02008de:	22d77f63          	bgeu	a4,a3,ffffffffc0200b1c <best_fit_check+0x2fe>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02008e2:	40f98733          	sub	a4,s3,a5
ffffffffc02008e6:	870d                	srai	a4,a4,0x3
ffffffffc02008e8:	02b70733          	mul	a4,a4,a1
ffffffffc02008ec:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02008ee:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02008f0:	3ed77663          	bgeu	a4,a3,ffffffffc0200cdc <best_fit_check+0x4be>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02008f4:	40f507b3          	sub	a5,a0,a5
ffffffffc02008f8:	878d                	srai	a5,a5,0x3
ffffffffc02008fa:	02b787b3          	mul	a5,a5,a1
ffffffffc02008fe:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200900:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200902:	3ad7fd63          	bgeu	a5,a3,ffffffffc0200cbc <best_fit_check+0x49e>
    assert(alloc_page() == NULL);
ffffffffc0200906:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200908:	00043c03          	ld	s8,0(s0)
ffffffffc020090c:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0200910:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0200914:	e400                	sd	s0,8(s0)
ffffffffc0200916:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0200918:	00005797          	auipc	a5,0x5
ffffffffc020091c:	7007a423          	sw	zero,1800(a5) # ffffffffc0206020 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200920:	0f1000ef          	jal	ra,ffffffffc0201210 <alloc_pages>
ffffffffc0200924:	36051c63          	bnez	a0,ffffffffc0200c9c <best_fit_check+0x47e>
    free_page(p0);
ffffffffc0200928:	4585                	li	a1,1
ffffffffc020092a:	8552                	mv	a0,s4
ffffffffc020092c:	123000ef          	jal	ra,ffffffffc020124e <free_pages>
    free_page(p1);
ffffffffc0200930:	4585                	li	a1,1
ffffffffc0200932:	854e                	mv	a0,s3
ffffffffc0200934:	11b000ef          	jal	ra,ffffffffc020124e <free_pages>
    free_page(p2);
ffffffffc0200938:	4585                	li	a1,1
ffffffffc020093a:	8556                	mv	a0,s5
ffffffffc020093c:	113000ef          	jal	ra,ffffffffc020124e <free_pages>
    assert(nr_free == 3);
ffffffffc0200940:	4818                	lw	a4,16(s0)
ffffffffc0200942:	478d                	li	a5,3
ffffffffc0200944:	32f71c63          	bne	a4,a5,ffffffffc0200c7c <best_fit_check+0x45e>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200948:	4505                	li	a0,1
ffffffffc020094a:	0c7000ef          	jal	ra,ffffffffc0201210 <alloc_pages>
ffffffffc020094e:	89aa                	mv	s3,a0
ffffffffc0200950:	30050663          	beqz	a0,ffffffffc0200c5c <best_fit_check+0x43e>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200954:	4505                	li	a0,1
ffffffffc0200956:	0bb000ef          	jal	ra,ffffffffc0201210 <alloc_pages>
ffffffffc020095a:	8aaa                	mv	s5,a0
ffffffffc020095c:	2e050063          	beqz	a0,ffffffffc0200c3c <best_fit_check+0x41e>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200960:	4505                	li	a0,1
ffffffffc0200962:	0af000ef          	jal	ra,ffffffffc0201210 <alloc_pages>
ffffffffc0200966:	8a2a                	mv	s4,a0
ffffffffc0200968:	2a050a63          	beqz	a0,ffffffffc0200c1c <best_fit_check+0x3fe>
    assert(alloc_page() == NULL);
ffffffffc020096c:	4505                	li	a0,1
ffffffffc020096e:	0a3000ef          	jal	ra,ffffffffc0201210 <alloc_pages>
ffffffffc0200972:	28051563          	bnez	a0,ffffffffc0200bfc <best_fit_check+0x3de>
    free_page(p0);
ffffffffc0200976:	4585                	li	a1,1
ffffffffc0200978:	854e                	mv	a0,s3
ffffffffc020097a:	0d5000ef          	jal	ra,ffffffffc020124e <free_pages>
    assert(!list_empty(&free_list));
ffffffffc020097e:	641c                	ld	a5,8(s0)
ffffffffc0200980:	1a878e63          	beq	a5,s0,ffffffffc0200b3c <best_fit_check+0x31e>
    assert((p = alloc_page()) == p0);
ffffffffc0200984:	4505                	li	a0,1
ffffffffc0200986:	08b000ef          	jal	ra,ffffffffc0201210 <alloc_pages>
ffffffffc020098a:	52a99963          	bne	s3,a0,ffffffffc0200ebc <best_fit_check+0x69e>
    assert(alloc_page() == NULL);
ffffffffc020098e:	4505                	li	a0,1
ffffffffc0200990:	081000ef          	jal	ra,ffffffffc0201210 <alloc_pages>
ffffffffc0200994:	50051463          	bnez	a0,ffffffffc0200e9c <best_fit_check+0x67e>
    assert(nr_free == 0);
ffffffffc0200998:	481c                	lw	a5,16(s0)
ffffffffc020099a:	4e079163          	bnez	a5,ffffffffc0200e7c <best_fit_check+0x65e>
    free_page(p);
ffffffffc020099e:	854e                	mv	a0,s3
ffffffffc02009a0:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc02009a2:	01843023          	sd	s8,0(s0)
ffffffffc02009a6:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc02009aa:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc02009ae:	0a1000ef          	jal	ra,ffffffffc020124e <free_pages>
    free_page(p1);
ffffffffc02009b2:	4585                	li	a1,1
ffffffffc02009b4:	8556                	mv	a0,s5
ffffffffc02009b6:	099000ef          	jal	ra,ffffffffc020124e <free_pages>
    free_page(p2);
ffffffffc02009ba:	4585                	li	a1,1
ffffffffc02009bc:	8552                	mv	a0,s4
ffffffffc02009be:	091000ef          	jal	ra,ffffffffc020124e <free_pages>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc02009c2:	4515                	li	a0,5
ffffffffc02009c4:	04d000ef          	jal	ra,ffffffffc0201210 <alloc_pages>
ffffffffc02009c8:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc02009ca:	48050963          	beqz	a0,ffffffffc0200e5c <best_fit_check+0x63e>
ffffffffc02009ce:	651c                	ld	a5,8(a0)
ffffffffc02009d0:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc02009d2:	8b85                	andi	a5,a5,1
ffffffffc02009d4:	46079463          	bnez	a5,ffffffffc0200e3c <best_fit_check+0x61e>
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc02009d8:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02009da:	00043a83          	ld	s5,0(s0)
ffffffffc02009de:	00843a03          	ld	s4,8(s0)
ffffffffc02009e2:	e000                	sd	s0,0(s0)
ffffffffc02009e4:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc02009e6:	02b000ef          	jal	ra,ffffffffc0201210 <alloc_pages>
ffffffffc02009ea:	42051963          	bnez	a0,ffffffffc0200e1c <best_fit_check+0x5fe>
    #endif
    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    // * - - * -
    free_pages(p0 + 1, 2);
ffffffffc02009ee:	4589                	li	a1,2
ffffffffc02009f0:	02898513          	addi	a0,s3,40
    unsigned int nr_free_store = nr_free;
ffffffffc02009f4:	01042b03          	lw	s6,16(s0)
    free_pages(p0 + 4, 1);
ffffffffc02009f8:	0a098c13          	addi	s8,s3,160
    nr_free = 0;
ffffffffc02009fc:	00005797          	auipc	a5,0x5
ffffffffc0200a00:	6207a223          	sw	zero,1572(a5) # ffffffffc0206020 <free_area+0x10>
    free_pages(p0 + 1, 2);
ffffffffc0200a04:	04b000ef          	jal	ra,ffffffffc020124e <free_pages>
    free_pages(p0 + 4, 1);
ffffffffc0200a08:	8562                	mv	a0,s8
ffffffffc0200a0a:	4585                	li	a1,1
ffffffffc0200a0c:	043000ef          	jal	ra,ffffffffc020124e <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200a10:	4511                	li	a0,4
ffffffffc0200a12:	7fe000ef          	jal	ra,ffffffffc0201210 <alloc_pages>
ffffffffc0200a16:	3e051363          	bnez	a0,ffffffffc0200dfc <best_fit_check+0x5de>
ffffffffc0200a1a:	0309b783          	ld	a5,48(s3)
ffffffffc0200a1e:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200a20:	8b85                	andi	a5,a5,1
ffffffffc0200a22:	3a078d63          	beqz	a5,ffffffffc0200ddc <best_fit_check+0x5be>
ffffffffc0200a26:	0389a703          	lw	a4,56(s3)
ffffffffc0200a2a:	4789                	li	a5,2
ffffffffc0200a2c:	3af71863          	bne	a4,a5,ffffffffc0200ddc <best_fit_check+0x5be>
    // * - - * *
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200a30:	4505                	li	a0,1
ffffffffc0200a32:	7de000ef          	jal	ra,ffffffffc0201210 <alloc_pages>
ffffffffc0200a36:	8baa                	mv	s7,a0
ffffffffc0200a38:	38050263          	beqz	a0,ffffffffc0200dbc <best_fit_check+0x59e>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200a3c:	4509                	li	a0,2
ffffffffc0200a3e:	7d2000ef          	jal	ra,ffffffffc0201210 <alloc_pages>
ffffffffc0200a42:	34050d63          	beqz	a0,ffffffffc0200d9c <best_fit_check+0x57e>
    assert(p0 + 4 == p1);
ffffffffc0200a46:	337c1b63          	bne	s8,s7,ffffffffc0200d7c <best_fit_check+0x55e>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    p2 = p0 + 1;
    free_pages(p0, 5);
ffffffffc0200a4a:	854e                	mv	a0,s3
ffffffffc0200a4c:	4595                	li	a1,5
ffffffffc0200a4e:	001000ef          	jal	ra,ffffffffc020124e <free_pages>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200a52:	4515                	li	a0,5
ffffffffc0200a54:	7bc000ef          	jal	ra,ffffffffc0201210 <alloc_pages>
ffffffffc0200a58:	89aa                	mv	s3,a0
ffffffffc0200a5a:	30050163          	beqz	a0,ffffffffc0200d5c <best_fit_check+0x53e>
    assert(alloc_page() == NULL);
ffffffffc0200a5e:	4505                	li	a0,1
ffffffffc0200a60:	7b0000ef          	jal	ra,ffffffffc0201210 <alloc_pages>
ffffffffc0200a64:	2c051c63          	bnez	a0,ffffffffc0200d3c <best_fit_check+0x51e>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    assert(nr_free == 0);
ffffffffc0200a68:	481c                	lw	a5,16(s0)
ffffffffc0200a6a:	2a079963          	bnez	a5,ffffffffc0200d1c <best_fit_check+0x4fe>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200a6e:	4595                	li	a1,5
ffffffffc0200a70:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200a72:	01642823          	sw	s6,16(s0)
    free_list = free_list_store;
ffffffffc0200a76:	01543023          	sd	s5,0(s0)
ffffffffc0200a7a:	01443423          	sd	s4,8(s0)
    free_pages(p0, 5);
ffffffffc0200a7e:	7d0000ef          	jal	ra,ffffffffc020124e <free_pages>
    return listelm->next;
ffffffffc0200a82:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200a84:	00878963          	beq	a5,s0,ffffffffc0200a96 <best_fit_check+0x278>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200a88:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200a8c:	679c                	ld	a5,8(a5)
ffffffffc0200a8e:	397d                	addiw	s2,s2,-1
ffffffffc0200a90:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200a92:	fe879be3          	bne	a5,s0,ffffffffc0200a88 <best_fit_check+0x26a>
    }
    assert(count == 0);
ffffffffc0200a96:	26091363          	bnez	s2,ffffffffc0200cfc <best_fit_check+0x4de>
    assert(total == 0);
ffffffffc0200a9a:	e0ed                	bnez	s1,ffffffffc0200b7c <best_fit_check+0x35e>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
}
ffffffffc0200a9c:	60a6                	ld	ra,72(sp)
ffffffffc0200a9e:	6406                	ld	s0,64(sp)
ffffffffc0200aa0:	74e2                	ld	s1,56(sp)
ffffffffc0200aa2:	7942                	ld	s2,48(sp)
ffffffffc0200aa4:	79a2                	ld	s3,40(sp)
ffffffffc0200aa6:	7a02                	ld	s4,32(sp)
ffffffffc0200aa8:	6ae2                	ld	s5,24(sp)
ffffffffc0200aaa:	6b42                	ld	s6,16(sp)
ffffffffc0200aac:	6ba2                	ld	s7,8(sp)
ffffffffc0200aae:	6c02                	ld	s8,0(sp)
ffffffffc0200ab0:	6161                	addi	sp,sp,80
ffffffffc0200ab2:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200ab4:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200ab6:	4481                	li	s1,0
ffffffffc0200ab8:	4901                	li	s2,0
ffffffffc0200aba:	b35d                	j	ffffffffc0200860 <best_fit_check+0x42>
        assert(PageProperty(p));
ffffffffc0200abc:	00001697          	auipc	a3,0x1
ffffffffc0200ac0:	64468693          	addi	a3,a3,1604 # ffffffffc0202100 <commands+0x4f8>
ffffffffc0200ac4:	00001617          	auipc	a2,0x1
ffffffffc0200ac8:	64c60613          	addi	a2,a2,1612 # ffffffffc0202110 <commands+0x508>
ffffffffc0200acc:	10a00593          	li	a1,266
ffffffffc0200ad0:	00001517          	auipc	a0,0x1
ffffffffc0200ad4:	65850513          	addi	a0,a0,1624 # ffffffffc0202128 <commands+0x520>
ffffffffc0200ad8:	8d5ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200adc:	00001697          	auipc	a3,0x1
ffffffffc0200ae0:	6e468693          	addi	a3,a3,1764 # ffffffffc02021c0 <commands+0x5b8>
ffffffffc0200ae4:	00001617          	auipc	a2,0x1
ffffffffc0200ae8:	62c60613          	addi	a2,a2,1580 # ffffffffc0202110 <commands+0x508>
ffffffffc0200aec:	0d600593          	li	a1,214
ffffffffc0200af0:	00001517          	auipc	a0,0x1
ffffffffc0200af4:	63850513          	addi	a0,a0,1592 # ffffffffc0202128 <commands+0x520>
ffffffffc0200af8:	8b5ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200afc:	00001697          	auipc	a3,0x1
ffffffffc0200b00:	6ec68693          	addi	a3,a3,1772 # ffffffffc02021e8 <commands+0x5e0>
ffffffffc0200b04:	00001617          	auipc	a2,0x1
ffffffffc0200b08:	60c60613          	addi	a2,a2,1548 # ffffffffc0202110 <commands+0x508>
ffffffffc0200b0c:	0d700593          	li	a1,215
ffffffffc0200b10:	00001517          	auipc	a0,0x1
ffffffffc0200b14:	61850513          	addi	a0,a0,1560 # ffffffffc0202128 <commands+0x520>
ffffffffc0200b18:	895ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200b1c:	00001697          	auipc	a3,0x1
ffffffffc0200b20:	70c68693          	addi	a3,a3,1804 # ffffffffc0202228 <commands+0x620>
ffffffffc0200b24:	00001617          	auipc	a2,0x1
ffffffffc0200b28:	5ec60613          	addi	a2,a2,1516 # ffffffffc0202110 <commands+0x508>
ffffffffc0200b2c:	0d900593          	li	a1,217
ffffffffc0200b30:	00001517          	auipc	a0,0x1
ffffffffc0200b34:	5f850513          	addi	a0,a0,1528 # ffffffffc0202128 <commands+0x520>
ffffffffc0200b38:	875ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200b3c:	00001697          	auipc	a3,0x1
ffffffffc0200b40:	77468693          	addi	a3,a3,1908 # ffffffffc02022b0 <commands+0x6a8>
ffffffffc0200b44:	00001617          	auipc	a2,0x1
ffffffffc0200b48:	5cc60613          	addi	a2,a2,1484 # ffffffffc0202110 <commands+0x508>
ffffffffc0200b4c:	0f200593          	li	a1,242
ffffffffc0200b50:	00001517          	auipc	a0,0x1
ffffffffc0200b54:	5d850513          	addi	a0,a0,1496 # ffffffffc0202128 <commands+0x520>
ffffffffc0200b58:	855ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200b5c:	00001697          	auipc	a3,0x1
ffffffffc0200b60:	64468693          	addi	a3,a3,1604 # ffffffffc02021a0 <commands+0x598>
ffffffffc0200b64:	00001617          	auipc	a2,0x1
ffffffffc0200b68:	5ac60613          	addi	a2,a2,1452 # ffffffffc0202110 <commands+0x508>
ffffffffc0200b6c:	0d400593          	li	a1,212
ffffffffc0200b70:	00001517          	auipc	a0,0x1
ffffffffc0200b74:	5b850513          	addi	a0,a0,1464 # ffffffffc0202128 <commands+0x520>
ffffffffc0200b78:	835ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(total == 0);
ffffffffc0200b7c:	00002697          	auipc	a3,0x2
ffffffffc0200b80:	86468693          	addi	a3,a3,-1948 # ffffffffc02023e0 <commands+0x7d8>
ffffffffc0200b84:	00001617          	auipc	a2,0x1
ffffffffc0200b88:	58c60613          	addi	a2,a2,1420 # ffffffffc0202110 <commands+0x508>
ffffffffc0200b8c:	14c00593          	li	a1,332
ffffffffc0200b90:	00001517          	auipc	a0,0x1
ffffffffc0200b94:	59850513          	addi	a0,a0,1432 # ffffffffc0202128 <commands+0x520>
ffffffffc0200b98:	815ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(total == nr_free_pages());
ffffffffc0200b9c:	00001697          	auipc	a3,0x1
ffffffffc0200ba0:	5a468693          	addi	a3,a3,1444 # ffffffffc0202140 <commands+0x538>
ffffffffc0200ba4:	00001617          	auipc	a2,0x1
ffffffffc0200ba8:	56c60613          	addi	a2,a2,1388 # ffffffffc0202110 <commands+0x508>
ffffffffc0200bac:	10d00593          	li	a1,269
ffffffffc0200bb0:	00001517          	auipc	a0,0x1
ffffffffc0200bb4:	57850513          	addi	a0,a0,1400 # ffffffffc0202128 <commands+0x520>
ffffffffc0200bb8:	ff4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200bbc:	00001697          	auipc	a3,0x1
ffffffffc0200bc0:	5c468693          	addi	a3,a3,1476 # ffffffffc0202180 <commands+0x578>
ffffffffc0200bc4:	00001617          	auipc	a2,0x1
ffffffffc0200bc8:	54c60613          	addi	a2,a2,1356 # ffffffffc0202110 <commands+0x508>
ffffffffc0200bcc:	0d300593          	li	a1,211
ffffffffc0200bd0:	00001517          	auipc	a0,0x1
ffffffffc0200bd4:	55850513          	addi	a0,a0,1368 # ffffffffc0202128 <commands+0x520>
ffffffffc0200bd8:	fd4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200bdc:	00001697          	auipc	a3,0x1
ffffffffc0200be0:	58468693          	addi	a3,a3,1412 # ffffffffc0202160 <commands+0x558>
ffffffffc0200be4:	00001617          	auipc	a2,0x1
ffffffffc0200be8:	52c60613          	addi	a2,a2,1324 # ffffffffc0202110 <commands+0x508>
ffffffffc0200bec:	0d200593          	li	a1,210
ffffffffc0200bf0:	00001517          	auipc	a0,0x1
ffffffffc0200bf4:	53850513          	addi	a0,a0,1336 # ffffffffc0202128 <commands+0x520>
ffffffffc0200bf8:	fb4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200bfc:	00001697          	auipc	a3,0x1
ffffffffc0200c00:	68c68693          	addi	a3,a3,1676 # ffffffffc0202288 <commands+0x680>
ffffffffc0200c04:	00001617          	auipc	a2,0x1
ffffffffc0200c08:	50c60613          	addi	a2,a2,1292 # ffffffffc0202110 <commands+0x508>
ffffffffc0200c0c:	0ef00593          	li	a1,239
ffffffffc0200c10:	00001517          	auipc	a0,0x1
ffffffffc0200c14:	51850513          	addi	a0,a0,1304 # ffffffffc0202128 <commands+0x520>
ffffffffc0200c18:	f94ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c1c:	00001697          	auipc	a3,0x1
ffffffffc0200c20:	58468693          	addi	a3,a3,1412 # ffffffffc02021a0 <commands+0x598>
ffffffffc0200c24:	00001617          	auipc	a2,0x1
ffffffffc0200c28:	4ec60613          	addi	a2,a2,1260 # ffffffffc0202110 <commands+0x508>
ffffffffc0200c2c:	0ed00593          	li	a1,237
ffffffffc0200c30:	00001517          	auipc	a0,0x1
ffffffffc0200c34:	4f850513          	addi	a0,a0,1272 # ffffffffc0202128 <commands+0x520>
ffffffffc0200c38:	f74ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c3c:	00001697          	auipc	a3,0x1
ffffffffc0200c40:	54468693          	addi	a3,a3,1348 # ffffffffc0202180 <commands+0x578>
ffffffffc0200c44:	00001617          	auipc	a2,0x1
ffffffffc0200c48:	4cc60613          	addi	a2,a2,1228 # ffffffffc0202110 <commands+0x508>
ffffffffc0200c4c:	0ec00593          	li	a1,236
ffffffffc0200c50:	00001517          	auipc	a0,0x1
ffffffffc0200c54:	4d850513          	addi	a0,a0,1240 # ffffffffc0202128 <commands+0x520>
ffffffffc0200c58:	f54ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200c5c:	00001697          	auipc	a3,0x1
ffffffffc0200c60:	50468693          	addi	a3,a3,1284 # ffffffffc0202160 <commands+0x558>
ffffffffc0200c64:	00001617          	auipc	a2,0x1
ffffffffc0200c68:	4ac60613          	addi	a2,a2,1196 # ffffffffc0202110 <commands+0x508>
ffffffffc0200c6c:	0eb00593          	li	a1,235
ffffffffc0200c70:	00001517          	auipc	a0,0x1
ffffffffc0200c74:	4b850513          	addi	a0,a0,1208 # ffffffffc0202128 <commands+0x520>
ffffffffc0200c78:	f34ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 3);
ffffffffc0200c7c:	00001697          	auipc	a3,0x1
ffffffffc0200c80:	62468693          	addi	a3,a3,1572 # ffffffffc02022a0 <commands+0x698>
ffffffffc0200c84:	00001617          	auipc	a2,0x1
ffffffffc0200c88:	48c60613          	addi	a2,a2,1164 # ffffffffc0202110 <commands+0x508>
ffffffffc0200c8c:	0e900593          	li	a1,233
ffffffffc0200c90:	00001517          	auipc	a0,0x1
ffffffffc0200c94:	49850513          	addi	a0,a0,1176 # ffffffffc0202128 <commands+0x520>
ffffffffc0200c98:	f14ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200c9c:	00001697          	auipc	a3,0x1
ffffffffc0200ca0:	5ec68693          	addi	a3,a3,1516 # ffffffffc0202288 <commands+0x680>
ffffffffc0200ca4:	00001617          	auipc	a2,0x1
ffffffffc0200ca8:	46c60613          	addi	a2,a2,1132 # ffffffffc0202110 <commands+0x508>
ffffffffc0200cac:	0e400593          	li	a1,228
ffffffffc0200cb0:	00001517          	auipc	a0,0x1
ffffffffc0200cb4:	47850513          	addi	a0,a0,1144 # ffffffffc0202128 <commands+0x520>
ffffffffc0200cb8:	ef4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200cbc:	00001697          	auipc	a3,0x1
ffffffffc0200cc0:	5ac68693          	addi	a3,a3,1452 # ffffffffc0202268 <commands+0x660>
ffffffffc0200cc4:	00001617          	auipc	a2,0x1
ffffffffc0200cc8:	44c60613          	addi	a2,a2,1100 # ffffffffc0202110 <commands+0x508>
ffffffffc0200ccc:	0db00593          	li	a1,219
ffffffffc0200cd0:	00001517          	auipc	a0,0x1
ffffffffc0200cd4:	45850513          	addi	a0,a0,1112 # ffffffffc0202128 <commands+0x520>
ffffffffc0200cd8:	ed4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200cdc:	00001697          	auipc	a3,0x1
ffffffffc0200ce0:	56c68693          	addi	a3,a3,1388 # ffffffffc0202248 <commands+0x640>
ffffffffc0200ce4:	00001617          	auipc	a2,0x1
ffffffffc0200ce8:	42c60613          	addi	a2,a2,1068 # ffffffffc0202110 <commands+0x508>
ffffffffc0200cec:	0da00593          	li	a1,218
ffffffffc0200cf0:	00001517          	auipc	a0,0x1
ffffffffc0200cf4:	43850513          	addi	a0,a0,1080 # ffffffffc0202128 <commands+0x520>
ffffffffc0200cf8:	eb4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(count == 0);
ffffffffc0200cfc:	00001697          	auipc	a3,0x1
ffffffffc0200d00:	6d468693          	addi	a3,a3,1748 # ffffffffc02023d0 <commands+0x7c8>
ffffffffc0200d04:	00001617          	auipc	a2,0x1
ffffffffc0200d08:	40c60613          	addi	a2,a2,1036 # ffffffffc0202110 <commands+0x508>
ffffffffc0200d0c:	14b00593          	li	a1,331
ffffffffc0200d10:	00001517          	auipc	a0,0x1
ffffffffc0200d14:	41850513          	addi	a0,a0,1048 # ffffffffc0202128 <commands+0x520>
ffffffffc0200d18:	e94ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 0);
ffffffffc0200d1c:	00001697          	auipc	a3,0x1
ffffffffc0200d20:	5cc68693          	addi	a3,a3,1484 # ffffffffc02022e8 <commands+0x6e0>
ffffffffc0200d24:	00001617          	auipc	a2,0x1
ffffffffc0200d28:	3ec60613          	addi	a2,a2,1004 # ffffffffc0202110 <commands+0x508>
ffffffffc0200d2c:	14000593          	li	a1,320
ffffffffc0200d30:	00001517          	auipc	a0,0x1
ffffffffc0200d34:	3f850513          	addi	a0,a0,1016 # ffffffffc0202128 <commands+0x520>
ffffffffc0200d38:	e74ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200d3c:	00001697          	auipc	a3,0x1
ffffffffc0200d40:	54c68693          	addi	a3,a3,1356 # ffffffffc0202288 <commands+0x680>
ffffffffc0200d44:	00001617          	auipc	a2,0x1
ffffffffc0200d48:	3cc60613          	addi	a2,a2,972 # ffffffffc0202110 <commands+0x508>
ffffffffc0200d4c:	13a00593          	li	a1,314
ffffffffc0200d50:	00001517          	auipc	a0,0x1
ffffffffc0200d54:	3d850513          	addi	a0,a0,984 # ffffffffc0202128 <commands+0x520>
ffffffffc0200d58:	e54ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200d5c:	00001697          	auipc	a3,0x1
ffffffffc0200d60:	65468693          	addi	a3,a3,1620 # ffffffffc02023b0 <commands+0x7a8>
ffffffffc0200d64:	00001617          	auipc	a2,0x1
ffffffffc0200d68:	3ac60613          	addi	a2,a2,940 # ffffffffc0202110 <commands+0x508>
ffffffffc0200d6c:	13900593          	li	a1,313
ffffffffc0200d70:	00001517          	auipc	a0,0x1
ffffffffc0200d74:	3b850513          	addi	a0,a0,952 # ffffffffc0202128 <commands+0x520>
ffffffffc0200d78:	e34ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 + 4 == p1);
ffffffffc0200d7c:	00001697          	auipc	a3,0x1
ffffffffc0200d80:	62468693          	addi	a3,a3,1572 # ffffffffc02023a0 <commands+0x798>
ffffffffc0200d84:	00001617          	auipc	a2,0x1
ffffffffc0200d88:	38c60613          	addi	a2,a2,908 # ffffffffc0202110 <commands+0x508>
ffffffffc0200d8c:	13100593          	li	a1,305
ffffffffc0200d90:	00001517          	auipc	a0,0x1
ffffffffc0200d94:	39850513          	addi	a0,a0,920 # ffffffffc0202128 <commands+0x520>
ffffffffc0200d98:	e14ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200d9c:	00001697          	auipc	a3,0x1
ffffffffc0200da0:	5ec68693          	addi	a3,a3,1516 # ffffffffc0202388 <commands+0x780>
ffffffffc0200da4:	00001617          	auipc	a2,0x1
ffffffffc0200da8:	36c60613          	addi	a2,a2,876 # ffffffffc0202110 <commands+0x508>
ffffffffc0200dac:	13000593          	li	a1,304
ffffffffc0200db0:	00001517          	auipc	a0,0x1
ffffffffc0200db4:	37850513          	addi	a0,a0,888 # ffffffffc0202128 <commands+0x520>
ffffffffc0200db8:	df4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200dbc:	00001697          	auipc	a3,0x1
ffffffffc0200dc0:	5ac68693          	addi	a3,a3,1452 # ffffffffc0202368 <commands+0x760>
ffffffffc0200dc4:	00001617          	auipc	a2,0x1
ffffffffc0200dc8:	34c60613          	addi	a2,a2,844 # ffffffffc0202110 <commands+0x508>
ffffffffc0200dcc:	12f00593          	li	a1,303
ffffffffc0200dd0:	00001517          	auipc	a0,0x1
ffffffffc0200dd4:	35850513          	addi	a0,a0,856 # ffffffffc0202128 <commands+0x520>
ffffffffc0200dd8:	dd4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200ddc:	00001697          	auipc	a3,0x1
ffffffffc0200de0:	55c68693          	addi	a3,a3,1372 # ffffffffc0202338 <commands+0x730>
ffffffffc0200de4:	00001617          	auipc	a2,0x1
ffffffffc0200de8:	32c60613          	addi	a2,a2,812 # ffffffffc0202110 <commands+0x508>
ffffffffc0200dec:	12d00593          	li	a1,301
ffffffffc0200df0:	00001517          	auipc	a0,0x1
ffffffffc0200df4:	33850513          	addi	a0,a0,824 # ffffffffc0202128 <commands+0x520>
ffffffffc0200df8:	db4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0200dfc:	00001697          	auipc	a3,0x1
ffffffffc0200e00:	52468693          	addi	a3,a3,1316 # ffffffffc0202320 <commands+0x718>
ffffffffc0200e04:	00001617          	auipc	a2,0x1
ffffffffc0200e08:	30c60613          	addi	a2,a2,780 # ffffffffc0202110 <commands+0x508>
ffffffffc0200e0c:	12c00593          	li	a1,300
ffffffffc0200e10:	00001517          	auipc	a0,0x1
ffffffffc0200e14:	31850513          	addi	a0,a0,792 # ffffffffc0202128 <commands+0x520>
ffffffffc0200e18:	d94ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200e1c:	00001697          	auipc	a3,0x1
ffffffffc0200e20:	46c68693          	addi	a3,a3,1132 # ffffffffc0202288 <commands+0x680>
ffffffffc0200e24:	00001617          	auipc	a2,0x1
ffffffffc0200e28:	2ec60613          	addi	a2,a2,748 # ffffffffc0202110 <commands+0x508>
ffffffffc0200e2c:	12000593          	li	a1,288
ffffffffc0200e30:	00001517          	auipc	a0,0x1
ffffffffc0200e34:	2f850513          	addi	a0,a0,760 # ffffffffc0202128 <commands+0x520>
ffffffffc0200e38:	d74ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!PageProperty(p0));
ffffffffc0200e3c:	00001697          	auipc	a3,0x1
ffffffffc0200e40:	4cc68693          	addi	a3,a3,1228 # ffffffffc0202308 <commands+0x700>
ffffffffc0200e44:	00001617          	auipc	a2,0x1
ffffffffc0200e48:	2cc60613          	addi	a2,a2,716 # ffffffffc0202110 <commands+0x508>
ffffffffc0200e4c:	11700593          	li	a1,279
ffffffffc0200e50:	00001517          	auipc	a0,0x1
ffffffffc0200e54:	2d850513          	addi	a0,a0,728 # ffffffffc0202128 <commands+0x520>
ffffffffc0200e58:	d54ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 != NULL);
ffffffffc0200e5c:	00001697          	auipc	a3,0x1
ffffffffc0200e60:	49c68693          	addi	a3,a3,1180 # ffffffffc02022f8 <commands+0x6f0>
ffffffffc0200e64:	00001617          	auipc	a2,0x1
ffffffffc0200e68:	2ac60613          	addi	a2,a2,684 # ffffffffc0202110 <commands+0x508>
ffffffffc0200e6c:	11600593          	li	a1,278
ffffffffc0200e70:	00001517          	auipc	a0,0x1
ffffffffc0200e74:	2b850513          	addi	a0,a0,696 # ffffffffc0202128 <commands+0x520>
ffffffffc0200e78:	d34ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 0);
ffffffffc0200e7c:	00001697          	auipc	a3,0x1
ffffffffc0200e80:	46c68693          	addi	a3,a3,1132 # ffffffffc02022e8 <commands+0x6e0>
ffffffffc0200e84:	00001617          	auipc	a2,0x1
ffffffffc0200e88:	28c60613          	addi	a2,a2,652 # ffffffffc0202110 <commands+0x508>
ffffffffc0200e8c:	0f800593          	li	a1,248
ffffffffc0200e90:	00001517          	auipc	a0,0x1
ffffffffc0200e94:	29850513          	addi	a0,a0,664 # ffffffffc0202128 <commands+0x520>
ffffffffc0200e98:	d14ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200e9c:	00001697          	auipc	a3,0x1
ffffffffc0200ea0:	3ec68693          	addi	a3,a3,1004 # ffffffffc0202288 <commands+0x680>
ffffffffc0200ea4:	00001617          	auipc	a2,0x1
ffffffffc0200ea8:	26c60613          	addi	a2,a2,620 # ffffffffc0202110 <commands+0x508>
ffffffffc0200eac:	0f600593          	li	a1,246
ffffffffc0200eb0:	00001517          	auipc	a0,0x1
ffffffffc0200eb4:	27850513          	addi	a0,a0,632 # ffffffffc0202128 <commands+0x520>
ffffffffc0200eb8:	cf4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200ebc:	00001697          	auipc	a3,0x1
ffffffffc0200ec0:	40c68693          	addi	a3,a3,1036 # ffffffffc02022c8 <commands+0x6c0>
ffffffffc0200ec4:	00001617          	auipc	a2,0x1
ffffffffc0200ec8:	24c60613          	addi	a2,a2,588 # ffffffffc0202110 <commands+0x508>
ffffffffc0200ecc:	0f500593          	li	a1,245
ffffffffc0200ed0:	00001517          	auipc	a0,0x1
ffffffffc0200ed4:	25850513          	addi	a0,a0,600 # ffffffffc0202128 <commands+0x520>
ffffffffc0200ed8:	cd4ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200edc <best_fit_free_pages>:
best_fit_free_pages(struct Page *base, size_t n) {
ffffffffc0200edc:	1141                	addi	sp,sp,-16
ffffffffc0200ede:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200ee0:	14058a63          	beqz	a1,ffffffffc0201034 <best_fit_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc0200ee4:	00259693          	slli	a3,a1,0x2
ffffffffc0200ee8:	96ae                	add	a3,a3,a1
ffffffffc0200eea:	068e                	slli	a3,a3,0x3
ffffffffc0200eec:	96aa                	add	a3,a3,a0
ffffffffc0200eee:	87aa                	mv	a5,a0
ffffffffc0200ef0:	02d50263          	beq	a0,a3,ffffffffc0200f14 <best_fit_free_pages+0x38>
ffffffffc0200ef4:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200ef6:	8b05                	andi	a4,a4,1
ffffffffc0200ef8:	10071e63          	bnez	a4,ffffffffc0201014 <best_fit_free_pages+0x138>
ffffffffc0200efc:	6798                	ld	a4,8(a5)
ffffffffc0200efe:	8b09                	andi	a4,a4,2
ffffffffc0200f00:	10071a63          	bnez	a4,ffffffffc0201014 <best_fit_free_pages+0x138>
        p->flags = 0;
ffffffffc0200f04:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200f08:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0200f0c:	02878793          	addi	a5,a5,40
ffffffffc0200f10:	fed792e3          	bne	a5,a3,ffffffffc0200ef4 <best_fit_free_pages+0x18>
    base->property = n;
ffffffffc0200f14:	2581                	sext.w	a1,a1
ffffffffc0200f16:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0200f18:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200f1c:	4789                	li	a5,2
ffffffffc0200f1e:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free = nr_free + n;
ffffffffc0200f22:	00005697          	auipc	a3,0x5
ffffffffc0200f26:	0ee68693          	addi	a3,a3,238 # ffffffffc0206010 <free_area>
ffffffffc0200f2a:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0200f2c:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0200f2e:	01850613          	addi	a2,a0,24
    nr_free = nr_free + n;
ffffffffc0200f32:	9db9                	addw	a1,a1,a4
ffffffffc0200f34:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0200f36:	0ad78863          	beq	a5,a3,ffffffffc0200fe6 <best_fit_free_pages+0x10a>
            struct Page* page = le2page(le, page_link);
ffffffffc0200f3a:	fe878713          	addi	a4,a5,-24
ffffffffc0200f3e:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc0200f42:	4581                	li	a1,0
            if (base < page) {
ffffffffc0200f44:	00e56a63          	bltu	a0,a4,ffffffffc0200f58 <best_fit_free_pages+0x7c>
    return listelm->next;
ffffffffc0200f48:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0200f4a:	06d70263          	beq	a4,a3,ffffffffc0200fae <best_fit_free_pages+0xd2>
    for (; p != base + n; p ++) {
ffffffffc0200f4e:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0200f50:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0200f54:	fee57ae3          	bgeu	a0,a4,ffffffffc0200f48 <best_fit_free_pages+0x6c>
ffffffffc0200f58:	c199                	beqz	a1,ffffffffc0200f5e <best_fit_free_pages+0x82>
ffffffffc0200f5a:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0200f5e:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200f60:	e390                	sd	a2,0(a5)
ffffffffc0200f62:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0200f64:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0200f66:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc0200f68:	02d70063          	beq	a4,a3,ffffffffc0200f88 <best_fit_free_pages+0xac>
        if (p + p->property == base) {
ffffffffc0200f6c:	ff872803          	lw	a6,-8(a4)
        p = le2page(le, page_link);
ffffffffc0200f70:	fe870593          	addi	a1,a4,-24
        if (p + p->property == base) {
ffffffffc0200f74:	02081613          	slli	a2,a6,0x20
ffffffffc0200f78:	9201                	srli	a2,a2,0x20
ffffffffc0200f7a:	00261793          	slli	a5,a2,0x2
ffffffffc0200f7e:	97b2                	add	a5,a5,a2
ffffffffc0200f80:	078e                	slli	a5,a5,0x3
ffffffffc0200f82:	97ae                	add	a5,a5,a1
ffffffffc0200f84:	02f50f63          	beq	a0,a5,ffffffffc0200fc2 <best_fit_free_pages+0xe6>
    return listelm->next;
ffffffffc0200f88:	7118                	ld	a4,32(a0)
    if (le != &free_list) {
ffffffffc0200f8a:	00d70f63          	beq	a4,a3,ffffffffc0200fa8 <best_fit_free_pages+0xcc>
        if (base + base->property == p) {
ffffffffc0200f8e:	490c                	lw	a1,16(a0)
        p = le2page(le, page_link);
ffffffffc0200f90:	fe870693          	addi	a3,a4,-24
        if (base + base->property == p) {
ffffffffc0200f94:	02059613          	slli	a2,a1,0x20
ffffffffc0200f98:	9201                	srli	a2,a2,0x20
ffffffffc0200f9a:	00261793          	slli	a5,a2,0x2
ffffffffc0200f9e:	97b2                	add	a5,a5,a2
ffffffffc0200fa0:	078e                	slli	a5,a5,0x3
ffffffffc0200fa2:	97aa                	add	a5,a5,a0
ffffffffc0200fa4:	04f68863          	beq	a3,a5,ffffffffc0200ff4 <best_fit_free_pages+0x118>
}
ffffffffc0200fa8:	60a2                	ld	ra,8(sp)
ffffffffc0200faa:	0141                	addi	sp,sp,16
ffffffffc0200fac:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0200fae:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0200fb0:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0200fb2:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0200fb4:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0200fb6:	02d70563          	beq	a4,a3,ffffffffc0200fe0 <best_fit_free_pages+0x104>
    prev->next = next->prev = elm;
ffffffffc0200fba:	8832                	mv	a6,a2
ffffffffc0200fbc:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0200fbe:	87ba                	mv	a5,a4
ffffffffc0200fc0:	bf41                	j	ffffffffc0200f50 <best_fit_free_pages+0x74>
            p->property = p->property + base->property;
ffffffffc0200fc2:	491c                	lw	a5,16(a0)
ffffffffc0200fc4:	0107883b          	addw	a6,a5,a6
ffffffffc0200fc8:	ff072c23          	sw	a6,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200fcc:	57f5                	li	a5,-3
ffffffffc0200fce:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200fd2:	6d10                	ld	a2,24(a0)
ffffffffc0200fd4:	711c                	ld	a5,32(a0)
            base = p;
ffffffffc0200fd6:	852e                	mv	a0,a1
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200fd8:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc0200fda:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc0200fdc:	e390                	sd	a2,0(a5)
ffffffffc0200fde:	b775                	j	ffffffffc0200f8a <best_fit_free_pages+0xae>
ffffffffc0200fe0:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0200fe2:	873e                	mv	a4,a5
ffffffffc0200fe4:	b761                	j	ffffffffc0200f6c <best_fit_free_pages+0x90>
}
ffffffffc0200fe6:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0200fe8:	e390                	sd	a2,0(a5)
ffffffffc0200fea:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0200fec:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0200fee:	ed1c                	sd	a5,24(a0)
ffffffffc0200ff0:	0141                	addi	sp,sp,16
ffffffffc0200ff2:	8082                	ret
            base->property += p->property;
ffffffffc0200ff4:	ff872783          	lw	a5,-8(a4)
ffffffffc0200ff8:	ff070693          	addi	a3,a4,-16
ffffffffc0200ffc:	9dbd                	addw	a1,a1,a5
ffffffffc0200ffe:	c90c                	sw	a1,16(a0)
ffffffffc0201000:	57f5                	li	a5,-3
ffffffffc0201002:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201006:	6314                	ld	a3,0(a4)
ffffffffc0201008:	671c                	ld	a5,8(a4)
}
ffffffffc020100a:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc020100c:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc020100e:	e394                	sd	a3,0(a5)
ffffffffc0201010:	0141                	addi	sp,sp,16
ffffffffc0201012:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201014:	00001697          	auipc	a3,0x1
ffffffffc0201018:	3e468693          	addi	a3,a3,996 # ffffffffc02023f8 <commands+0x7f0>
ffffffffc020101c:	00001617          	auipc	a2,0x1
ffffffffc0201020:	0f460613          	addi	a2,a2,244 # ffffffffc0202110 <commands+0x508>
ffffffffc0201024:	09200593          	li	a1,146
ffffffffc0201028:	00001517          	auipc	a0,0x1
ffffffffc020102c:	10050513          	addi	a0,a0,256 # ffffffffc0202128 <commands+0x520>
ffffffffc0201030:	b7cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc0201034:	00001697          	auipc	a3,0x1
ffffffffc0201038:	3bc68693          	addi	a3,a3,956 # ffffffffc02023f0 <commands+0x7e8>
ffffffffc020103c:	00001617          	auipc	a2,0x1
ffffffffc0201040:	0d460613          	addi	a2,a2,212 # ffffffffc0202110 <commands+0x508>
ffffffffc0201044:	08f00593          	li	a1,143
ffffffffc0201048:	00001517          	auipc	a0,0x1
ffffffffc020104c:	0e050513          	addi	a0,a0,224 # ffffffffc0202128 <commands+0x520>
ffffffffc0201050:	b5cff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201054 <best_fit_alloc_pages>:
    assert(n > 0);
ffffffffc0201054:	c155                	beqz	a0,ffffffffc02010f8 <best_fit_alloc_pages+0xa4>
    if (n > nr_free) {
ffffffffc0201056:	00005597          	auipc	a1,0x5
ffffffffc020105a:	fba58593          	addi	a1,a1,-70 # ffffffffc0206010 <free_area>
ffffffffc020105e:	0105a883          	lw	a7,16(a1)
ffffffffc0201062:	86aa                	mv	a3,a0
ffffffffc0201064:	02089793          	slli	a5,a7,0x20
ffffffffc0201068:	9381                	srli	a5,a5,0x20
ffffffffc020106a:	08a7e563          	bltu	a5,a0,ffffffffc02010f4 <best_fit_alloc_pages+0xa0>
    return listelm->next;
ffffffffc020106e:	659c                	ld	a5,8(a1)
    struct Page *page = NULL;
ffffffffc0201070:	4501                	li	a0,0
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201072:	08b78063          	beq	a5,a1,ffffffffc02010f2 <best_fit_alloc_pages+0x9e>
        if (p->property >= n && (page == NULL || p->property < page->property)) {
ffffffffc0201076:	ff87a703          	lw	a4,-8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc020107a:	fe878813          	addi	a6,a5,-24
        if (p->property >= n && (page == NULL || p->property < page->property)) {
ffffffffc020107e:	02071613          	slli	a2,a4,0x20
ffffffffc0201082:	9201                	srli	a2,a2,0x20
ffffffffc0201084:	00d66763          	bltu	a2,a3,ffffffffc0201092 <best_fit_alloc_pages+0x3e>
ffffffffc0201088:	c501                	beqz	a0,ffffffffc0201090 <best_fit_alloc_pages+0x3c>
ffffffffc020108a:	4910                	lw	a2,16(a0)
ffffffffc020108c:	00c77363          	bgeu	a4,a2,ffffffffc0201092 <best_fit_alloc_pages+0x3e>
            page = p;
ffffffffc0201090:	8542                	mv	a0,a6
ffffffffc0201092:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201094:	feb791e3          	bne	a5,a1,ffffffffc0201076 <best_fit_alloc_pages+0x22>
    if (page != NULL) {
ffffffffc0201098:	cd29                	beqz	a0,ffffffffc02010f2 <best_fit_alloc_pages+0x9e>
    __list_del(listelm->prev, listelm->next);
ffffffffc020109a:	711c                	ld	a5,32(a0)
    return listelm->prev;
ffffffffc020109c:	6d18                	ld	a4,24(a0)
        if (page->property > n) {
ffffffffc020109e:	4910                	lw	a2,16(a0)
            p->property = page->property - n;
ffffffffc02010a0:	0006881b          	sext.w	a6,a3
    prev->next = next;
ffffffffc02010a4:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02010a6:	e398                	sd	a4,0(a5)
        if (page->property > n) {
ffffffffc02010a8:	02061793          	slli	a5,a2,0x20
ffffffffc02010ac:	9381                	srli	a5,a5,0x20
ffffffffc02010ae:	02f6f863          	bgeu	a3,a5,ffffffffc02010de <best_fit_alloc_pages+0x8a>
            struct Page *p = page + n;
ffffffffc02010b2:	00269793          	slli	a5,a3,0x2
ffffffffc02010b6:	97b6                	add	a5,a5,a3
ffffffffc02010b8:	078e                	slli	a5,a5,0x3
ffffffffc02010ba:	97aa                	add	a5,a5,a0
            p->property = page->property - n;
ffffffffc02010bc:	4106063b          	subw	a2,a2,a6
ffffffffc02010c0:	cb90                	sw	a2,16(a5)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02010c2:	4689                	li	a3,2
ffffffffc02010c4:	00878613          	addi	a2,a5,8
ffffffffc02010c8:	40d6302f          	amoor.d	zero,a3,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc02010cc:	6714                	ld	a3,8(a4)
            list_add(prev, &(p->page_link));
ffffffffc02010ce:	01878613          	addi	a2,a5,24
        nr_free -= n;
ffffffffc02010d2:	0105a883          	lw	a7,16(a1)
    prev->next = next->prev = elm;
ffffffffc02010d6:	e290                	sd	a2,0(a3)
ffffffffc02010d8:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02010da:	f394                	sd	a3,32(a5)
    elm->prev = prev;
ffffffffc02010dc:	ef98                	sd	a4,24(a5)
ffffffffc02010de:	410888bb          	subw	a7,a7,a6
ffffffffc02010e2:	0115a823          	sw	a7,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02010e6:	57f5                	li	a5,-3
ffffffffc02010e8:	00850713          	addi	a4,a0,8
ffffffffc02010ec:	60f7302f          	amoand.d	zero,a5,(a4)
}
ffffffffc02010f0:	8082                	ret
}
ffffffffc02010f2:	8082                	ret
        return NULL;
ffffffffc02010f4:	4501                	li	a0,0
ffffffffc02010f6:	8082                	ret
best_fit_alloc_pages(size_t n) {
ffffffffc02010f8:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02010fa:	00001697          	auipc	a3,0x1
ffffffffc02010fe:	2f668693          	addi	a3,a3,758 # ffffffffc02023f0 <commands+0x7e8>
ffffffffc0201102:	00001617          	auipc	a2,0x1
ffffffffc0201106:	00e60613          	addi	a2,a2,14 # ffffffffc0202110 <commands+0x508>
ffffffffc020110a:	06c00593          	li	a1,108
ffffffffc020110e:	00001517          	auipc	a0,0x1
ffffffffc0201112:	01a50513          	addi	a0,a0,26 # ffffffffc0202128 <commands+0x520>
best_fit_alloc_pages(size_t n) {
ffffffffc0201116:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201118:	a94ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc020111c <best_fit_init_memmap>:
best_fit_init_memmap(struct Page *base, size_t n) {
ffffffffc020111c:	1141                	addi	sp,sp,-16
ffffffffc020111e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201120:	c9e1                	beqz	a1,ffffffffc02011f0 <best_fit_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc0201122:	00259693          	slli	a3,a1,0x2
ffffffffc0201126:	96ae                	add	a3,a3,a1
ffffffffc0201128:	068e                	slli	a3,a3,0x3
ffffffffc020112a:	96aa                	add	a3,a3,a0
ffffffffc020112c:	87aa                	mv	a5,a0
ffffffffc020112e:	00d50f63          	beq	a0,a3,ffffffffc020114c <best_fit_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201132:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0201134:	8b05                	andi	a4,a4,1
ffffffffc0201136:	cf49                	beqz	a4,ffffffffc02011d0 <best_fit_init_memmap+0xb4>
        p->property = 0;
ffffffffc0201138:	0007a823          	sw	zero,16(a5)
        p->flags = 0;
ffffffffc020113c:	0007b423          	sd	zero,8(a5)
ffffffffc0201140:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201144:	02878793          	addi	a5,a5,40
ffffffffc0201148:	fed795e3          	bne	a5,a3,ffffffffc0201132 <best_fit_init_memmap+0x16>
    base->property = n;
ffffffffc020114c:	2581                	sext.w	a1,a1
ffffffffc020114e:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201150:	4789                	li	a5,2
ffffffffc0201152:	00850713          	addi	a4,a0,8
ffffffffc0201156:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc020115a:	00005697          	auipc	a3,0x5
ffffffffc020115e:	eb668693          	addi	a3,a3,-330 # ffffffffc0206010 <free_area>
ffffffffc0201162:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201164:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc0201166:	01850613          	addi	a2,a0,24
    nr_free += n;
ffffffffc020116a:	9db9                	addw	a1,a1,a4
ffffffffc020116c:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc020116e:	04d78a63          	beq	a5,a3,ffffffffc02011c2 <best_fit_init_memmap+0xa6>
            struct Page* page = le2page(le, page_link);
ffffffffc0201172:	fe878713          	addi	a4,a5,-24
ffffffffc0201176:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020117a:	4581                	li	a1,0
            if (base < page) {
ffffffffc020117c:	00e56a63          	bltu	a0,a4,ffffffffc0201190 <best_fit_init_memmap+0x74>
    return listelm->next;
ffffffffc0201180:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list) {
ffffffffc0201182:	02d70263          	beq	a4,a3,ffffffffc02011a6 <best_fit_init_memmap+0x8a>
    for (; p != base + n; p ++) {
ffffffffc0201186:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201188:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc020118c:	fee57ae3          	bgeu	a0,a4,ffffffffc0201180 <best_fit_init_memmap+0x64>
ffffffffc0201190:	c199                	beqz	a1,ffffffffc0201196 <best_fit_init_memmap+0x7a>
ffffffffc0201192:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201196:	6398                	ld	a4,0(a5)
}
ffffffffc0201198:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020119a:	e390                	sd	a2,0(a5)
ffffffffc020119c:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020119e:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02011a0:	ed18                	sd	a4,24(a0)
ffffffffc02011a2:	0141                	addi	sp,sp,16
ffffffffc02011a4:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02011a6:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02011a8:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc02011aa:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02011ac:	ed1c                	sd	a5,24(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02011ae:	00d70663          	beq	a4,a3,ffffffffc02011ba <best_fit_init_memmap+0x9e>
    prev->next = next->prev = elm;
ffffffffc02011b2:	8832                	mv	a6,a2
ffffffffc02011b4:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc02011b6:	87ba                	mv	a5,a4
ffffffffc02011b8:	bfc1                	j	ffffffffc0201188 <best_fit_init_memmap+0x6c>
}
ffffffffc02011ba:	60a2                	ld	ra,8(sp)
ffffffffc02011bc:	e290                	sd	a2,0(a3)
ffffffffc02011be:	0141                	addi	sp,sp,16
ffffffffc02011c0:	8082                	ret
ffffffffc02011c2:	60a2                	ld	ra,8(sp)
ffffffffc02011c4:	e390                	sd	a2,0(a5)
ffffffffc02011c6:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02011c8:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02011ca:	ed1c                	sd	a5,24(a0)
ffffffffc02011cc:	0141                	addi	sp,sp,16
ffffffffc02011ce:	8082                	ret
        assert(PageReserved(p));
ffffffffc02011d0:	00001697          	auipc	a3,0x1
ffffffffc02011d4:	25068693          	addi	a3,a3,592 # ffffffffc0202420 <commands+0x818>
ffffffffc02011d8:	00001617          	auipc	a2,0x1
ffffffffc02011dc:	f3860613          	addi	a2,a2,-200 # ffffffffc0202110 <commands+0x508>
ffffffffc02011e0:	04a00593          	li	a1,74
ffffffffc02011e4:	00001517          	auipc	a0,0x1
ffffffffc02011e8:	f4450513          	addi	a0,a0,-188 # ffffffffc0202128 <commands+0x520>
ffffffffc02011ec:	9c0ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc02011f0:	00001697          	auipc	a3,0x1
ffffffffc02011f4:	20068693          	addi	a3,a3,512 # ffffffffc02023f0 <commands+0x7e8>
ffffffffc02011f8:	00001617          	auipc	a2,0x1
ffffffffc02011fc:	f1860613          	addi	a2,a2,-232 # ffffffffc0202110 <commands+0x508>
ffffffffc0201200:	04700593          	li	a1,71
ffffffffc0201204:	00001517          	auipc	a0,0x1
ffffffffc0201208:	f2450513          	addi	a0,a0,-220 # ffffffffc0202128 <commands+0x520>
ffffffffc020120c:	9a0ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201210 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201210:	100027f3          	csrr	a5,sstatus
ffffffffc0201214:	8b89                	andi	a5,a5,2
ffffffffc0201216:	e799                	bnez	a5,ffffffffc0201224 <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0201218:	00005797          	auipc	a5,0x5
ffffffffc020121c:	2307b783          	ld	a5,560(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc0201220:	6f9c                	ld	a5,24(a5)
ffffffffc0201222:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc0201224:	1141                	addi	sp,sp,-16
ffffffffc0201226:	e406                	sd	ra,8(sp)
ffffffffc0201228:	e022                	sd	s0,0(sp)
ffffffffc020122a:	842a                	mv	s0,a0
        intr_disable();
ffffffffc020122c:	a32ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201230:	00005797          	auipc	a5,0x5
ffffffffc0201234:	2187b783          	ld	a5,536(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc0201238:	6f9c                	ld	a5,24(a5)
ffffffffc020123a:	8522                	mv	a0,s0
ffffffffc020123c:	9782                	jalr	a5
ffffffffc020123e:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0201240:	a18ff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0201244:	60a2                	ld	ra,8(sp)
ffffffffc0201246:	8522                	mv	a0,s0
ffffffffc0201248:	6402                	ld	s0,0(sp)
ffffffffc020124a:	0141                	addi	sp,sp,16
ffffffffc020124c:	8082                	ret

ffffffffc020124e <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020124e:	100027f3          	csrr	a5,sstatus
ffffffffc0201252:	8b89                	andi	a5,a5,2
ffffffffc0201254:	e799                	bnez	a5,ffffffffc0201262 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201256:	00005797          	auipc	a5,0x5
ffffffffc020125a:	1f27b783          	ld	a5,498(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc020125e:	739c                	ld	a5,32(a5)
ffffffffc0201260:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0201262:	1101                	addi	sp,sp,-32
ffffffffc0201264:	ec06                	sd	ra,24(sp)
ffffffffc0201266:	e822                	sd	s0,16(sp)
ffffffffc0201268:	e426                	sd	s1,8(sp)
ffffffffc020126a:	842a                	mv	s0,a0
ffffffffc020126c:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc020126e:	9f0ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201272:	00005797          	auipc	a5,0x5
ffffffffc0201276:	1d67b783          	ld	a5,470(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc020127a:	739c                	ld	a5,32(a5)
ffffffffc020127c:	85a6                	mv	a1,s1
ffffffffc020127e:	8522                	mv	a0,s0
ffffffffc0201280:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201282:	6442                	ld	s0,16(sp)
ffffffffc0201284:	60e2                	ld	ra,24(sp)
ffffffffc0201286:	64a2                	ld	s1,8(sp)
ffffffffc0201288:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020128a:	9ceff06f          	j	ffffffffc0200458 <intr_enable>

ffffffffc020128e <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020128e:	100027f3          	csrr	a5,sstatus
ffffffffc0201292:	8b89                	andi	a5,a5,2
ffffffffc0201294:	e799                	bnez	a5,ffffffffc02012a2 <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201296:	00005797          	auipc	a5,0x5
ffffffffc020129a:	1b27b783          	ld	a5,434(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc020129e:	779c                	ld	a5,40(a5)
ffffffffc02012a0:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc02012a2:	1141                	addi	sp,sp,-16
ffffffffc02012a4:	e406                	sd	ra,8(sp)
ffffffffc02012a6:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc02012a8:	9b6ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02012ac:	00005797          	auipc	a5,0x5
ffffffffc02012b0:	19c7b783          	ld	a5,412(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc02012b4:	779c                	ld	a5,40(a5)
ffffffffc02012b6:	9782                	jalr	a5
ffffffffc02012b8:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02012ba:	99eff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02012be:	60a2                	ld	ra,8(sp)
ffffffffc02012c0:	8522                	mv	a0,s0
ffffffffc02012c2:	6402                	ld	s0,0(sp)
ffffffffc02012c4:	0141                	addi	sp,sp,16
ffffffffc02012c6:	8082                	ret

ffffffffc02012c8 <pmm_init>:
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02012c8:	00001797          	auipc	a5,0x1
ffffffffc02012cc:	18078793          	addi	a5,a5,384 # ffffffffc0202448 <best_fit_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02012d0:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc02012d2:	1101                	addi	sp,sp,-32
ffffffffc02012d4:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02012d6:	00001517          	auipc	a0,0x1
ffffffffc02012da:	1aa50513          	addi	a0,a0,426 # ffffffffc0202480 <best_fit_pmm_manager+0x38>
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02012de:	00005497          	auipc	s1,0x5
ffffffffc02012e2:	16a48493          	addi	s1,s1,362 # ffffffffc0206448 <pmm_manager>
void pmm_init(void) {
ffffffffc02012e6:	ec06                	sd	ra,24(sp)
ffffffffc02012e8:	e822                	sd	s0,16(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc02012ea:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02012ec:	dc7fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pmm_manager->init();
ffffffffc02012f0:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02012f2:	00005417          	auipc	s0,0x5
ffffffffc02012f6:	16e40413          	addi	s0,s0,366 # ffffffffc0206460 <va_pa_offset>
    pmm_manager->init();
ffffffffc02012fa:	679c                	ld	a5,8(a5)
ffffffffc02012fc:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02012fe:	57f5                	li	a5,-3
ffffffffc0201300:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0201302:	00001517          	auipc	a0,0x1
ffffffffc0201306:	19650513          	addi	a0,a0,406 # ffffffffc0202498 <best_fit_pmm_manager+0x50>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc020130a:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc020130c:	da7fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0201310:	46c5                	li	a3,17
ffffffffc0201312:	06ee                	slli	a3,a3,0x1b
ffffffffc0201314:	40100613          	li	a2,1025
ffffffffc0201318:	16fd                	addi	a3,a3,-1
ffffffffc020131a:	07e005b7          	lui	a1,0x7e00
ffffffffc020131e:	0656                	slli	a2,a2,0x15
ffffffffc0201320:	00001517          	auipc	a0,0x1
ffffffffc0201324:	19050513          	addi	a0,a0,400 # ffffffffc02024b0 <best_fit_pmm_manager+0x68>
ffffffffc0201328:	d8bfe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020132c:	777d                	lui	a4,0xfffff
ffffffffc020132e:	00006797          	auipc	a5,0x6
ffffffffc0201332:	14178793          	addi	a5,a5,321 # ffffffffc020746f <end+0xfff>
ffffffffc0201336:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201338:	00005517          	auipc	a0,0x5
ffffffffc020133c:	10050513          	addi	a0,a0,256 # ffffffffc0206438 <npage>
ffffffffc0201340:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201344:	00005597          	auipc	a1,0x5
ffffffffc0201348:	0fc58593          	addi	a1,a1,252 # ffffffffc0206440 <pages>
    npage = maxpa / PGSIZE;
ffffffffc020134c:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020134e:	e19c                	sd	a5,0(a1)
ffffffffc0201350:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201352:	4701                	li	a4,0
ffffffffc0201354:	4885                	li	a7,1
ffffffffc0201356:	fff80837          	lui	a6,0xfff80
ffffffffc020135a:	a011                	j	ffffffffc020135e <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc020135c:	619c                	ld	a5,0(a1)
ffffffffc020135e:	97b6                	add	a5,a5,a3
ffffffffc0201360:	07a1                	addi	a5,a5,8
ffffffffc0201362:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201366:	611c                	ld	a5,0(a0)
ffffffffc0201368:	0705                	addi	a4,a4,1
ffffffffc020136a:	02868693          	addi	a3,a3,40
ffffffffc020136e:	01078633          	add	a2,a5,a6
ffffffffc0201372:	fec765e3          	bltu	a4,a2,ffffffffc020135c <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201376:	6190                	ld	a2,0(a1)
ffffffffc0201378:	00279713          	slli	a4,a5,0x2
ffffffffc020137c:	973e                	add	a4,a4,a5
ffffffffc020137e:	fec006b7          	lui	a3,0xfec00
ffffffffc0201382:	070e                	slli	a4,a4,0x3
ffffffffc0201384:	96b2                	add	a3,a3,a2
ffffffffc0201386:	96ba                	add	a3,a3,a4
ffffffffc0201388:	c0200737          	lui	a4,0xc0200
ffffffffc020138c:	08e6ef63          	bltu	a3,a4,ffffffffc020142a <pmm_init+0x162>
ffffffffc0201390:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc0201392:	45c5                	li	a1,17
ffffffffc0201394:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201396:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0201398:	04b6e863          	bltu	a3,a1,ffffffffc02013e8 <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc020139c:	609c                	ld	a5,0(s1)
ffffffffc020139e:	7b9c                	ld	a5,48(a5)
ffffffffc02013a0:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02013a2:	00001517          	auipc	a0,0x1
ffffffffc02013a6:	1a650513          	addi	a0,a0,422 # ffffffffc0202548 <best_fit_pmm_manager+0x100>
ffffffffc02013aa:	d09fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc02013ae:	00004597          	auipc	a1,0x4
ffffffffc02013b2:	c5258593          	addi	a1,a1,-942 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc02013b6:	00005797          	auipc	a5,0x5
ffffffffc02013ba:	0ab7b123          	sd	a1,162(a5) # ffffffffc0206458 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc02013be:	c02007b7          	lui	a5,0xc0200
ffffffffc02013c2:	08f5e063          	bltu	a1,a5,ffffffffc0201442 <pmm_init+0x17a>
ffffffffc02013c6:	6010                	ld	a2,0(s0)
}
ffffffffc02013c8:	6442                	ld	s0,16(sp)
ffffffffc02013ca:	60e2                	ld	ra,24(sp)
ffffffffc02013cc:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc02013ce:	40c58633          	sub	a2,a1,a2
ffffffffc02013d2:	00005797          	auipc	a5,0x5
ffffffffc02013d6:	06c7bf23          	sd	a2,126(a5) # ffffffffc0206450 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02013da:	00001517          	auipc	a0,0x1
ffffffffc02013de:	18e50513          	addi	a0,a0,398 # ffffffffc0202568 <best_fit_pmm_manager+0x120>
}
ffffffffc02013e2:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02013e4:	ccffe06f          	j	ffffffffc02000b2 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02013e8:	6705                	lui	a4,0x1
ffffffffc02013ea:	177d                	addi	a4,a4,-1
ffffffffc02013ec:	96ba                	add	a3,a3,a4
ffffffffc02013ee:	777d                	lui	a4,0xfffff
ffffffffc02013f0:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02013f2:	00c6d513          	srli	a0,a3,0xc
ffffffffc02013f6:	00f57e63          	bgeu	a0,a5,ffffffffc0201412 <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc02013fa:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc02013fc:	982a                	add	a6,a6,a0
ffffffffc02013fe:	00281513          	slli	a0,a6,0x2
ffffffffc0201402:	9542                	add	a0,a0,a6
ffffffffc0201404:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201406:	8d95                	sub	a1,a1,a3
ffffffffc0201408:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc020140a:	81b1                	srli	a1,a1,0xc
ffffffffc020140c:	9532                	add	a0,a0,a2
ffffffffc020140e:	9782                	jalr	a5
}
ffffffffc0201410:	b771                	j	ffffffffc020139c <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc0201412:	00001617          	auipc	a2,0x1
ffffffffc0201416:	10660613          	addi	a2,a2,262 # ffffffffc0202518 <best_fit_pmm_manager+0xd0>
ffffffffc020141a:	06b00593          	li	a1,107
ffffffffc020141e:	00001517          	auipc	a0,0x1
ffffffffc0201422:	11a50513          	addi	a0,a0,282 # ffffffffc0202538 <best_fit_pmm_manager+0xf0>
ffffffffc0201426:	f87fe0ef          	jal	ra,ffffffffc02003ac <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020142a:	00001617          	auipc	a2,0x1
ffffffffc020142e:	0b660613          	addi	a2,a2,182 # ffffffffc02024e0 <best_fit_pmm_manager+0x98>
ffffffffc0201432:	06e00593          	li	a1,110
ffffffffc0201436:	00001517          	auipc	a0,0x1
ffffffffc020143a:	0d250513          	addi	a0,a0,210 # ffffffffc0202508 <best_fit_pmm_manager+0xc0>
ffffffffc020143e:	f6ffe0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201442:	86ae                	mv	a3,a1
ffffffffc0201444:	00001617          	auipc	a2,0x1
ffffffffc0201448:	09c60613          	addi	a2,a2,156 # ffffffffc02024e0 <best_fit_pmm_manager+0x98>
ffffffffc020144c:	08900593          	li	a1,137
ffffffffc0201450:	00001517          	auipc	a0,0x1
ffffffffc0201454:	0b850513          	addi	a0,a0,184 # ffffffffc0202508 <best_fit_pmm_manager+0xc0>
ffffffffc0201458:	f55fe0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc020145c <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc020145c:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201460:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201462:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201466:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201468:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020146c:	f022                	sd	s0,32(sp)
ffffffffc020146e:	ec26                	sd	s1,24(sp)
ffffffffc0201470:	e84a                	sd	s2,16(sp)
ffffffffc0201472:	f406                	sd	ra,40(sp)
ffffffffc0201474:	e44e                	sd	s3,8(sp)
ffffffffc0201476:	84aa                	mv	s1,a0
ffffffffc0201478:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc020147a:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc020147e:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0201480:	03067e63          	bgeu	a2,a6,ffffffffc02014bc <printnum+0x60>
ffffffffc0201484:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0201486:	00805763          	blez	s0,ffffffffc0201494 <printnum+0x38>
ffffffffc020148a:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020148c:	85ca                	mv	a1,s2
ffffffffc020148e:	854e                	mv	a0,s3
ffffffffc0201490:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201492:	fc65                	bnez	s0,ffffffffc020148a <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201494:	1a02                	slli	s4,s4,0x20
ffffffffc0201496:	00001797          	auipc	a5,0x1
ffffffffc020149a:	11278793          	addi	a5,a5,274 # ffffffffc02025a8 <best_fit_pmm_manager+0x160>
ffffffffc020149e:	020a5a13          	srli	s4,s4,0x20
ffffffffc02014a2:	9a3e                	add	s4,s4,a5
}
ffffffffc02014a4:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02014a6:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02014aa:	70a2                	ld	ra,40(sp)
ffffffffc02014ac:	69a2                	ld	s3,8(sp)
ffffffffc02014ae:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02014b0:	85ca                	mv	a1,s2
ffffffffc02014b2:	87a6                	mv	a5,s1
}
ffffffffc02014b4:	6942                	ld	s2,16(sp)
ffffffffc02014b6:	64e2                	ld	s1,24(sp)
ffffffffc02014b8:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02014ba:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02014bc:	03065633          	divu	a2,a2,a6
ffffffffc02014c0:	8722                	mv	a4,s0
ffffffffc02014c2:	f9bff0ef          	jal	ra,ffffffffc020145c <printnum>
ffffffffc02014c6:	b7f9                	j	ffffffffc0201494 <printnum+0x38>

ffffffffc02014c8 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02014c8:	7119                	addi	sp,sp,-128
ffffffffc02014ca:	f4a6                	sd	s1,104(sp)
ffffffffc02014cc:	f0ca                	sd	s2,96(sp)
ffffffffc02014ce:	ecce                	sd	s3,88(sp)
ffffffffc02014d0:	e8d2                	sd	s4,80(sp)
ffffffffc02014d2:	e4d6                	sd	s5,72(sp)
ffffffffc02014d4:	e0da                	sd	s6,64(sp)
ffffffffc02014d6:	fc5e                	sd	s7,56(sp)
ffffffffc02014d8:	f06a                	sd	s10,32(sp)
ffffffffc02014da:	fc86                	sd	ra,120(sp)
ffffffffc02014dc:	f8a2                	sd	s0,112(sp)
ffffffffc02014de:	f862                	sd	s8,48(sp)
ffffffffc02014e0:	f466                	sd	s9,40(sp)
ffffffffc02014e2:	ec6e                	sd	s11,24(sp)
ffffffffc02014e4:	892a                	mv	s2,a0
ffffffffc02014e6:	84ae                	mv	s1,a1
ffffffffc02014e8:	8d32                	mv	s10,a2
ffffffffc02014ea:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02014ec:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02014f0:	5b7d                	li	s6,-1
ffffffffc02014f2:	00001a97          	auipc	s5,0x1
ffffffffc02014f6:	0eaa8a93          	addi	s5,s5,234 # ffffffffc02025dc <best_fit_pmm_manager+0x194>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02014fa:	00001b97          	auipc	s7,0x1
ffffffffc02014fe:	2beb8b93          	addi	s7,s7,702 # ffffffffc02027b8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201502:	000d4503          	lbu	a0,0(s10)
ffffffffc0201506:	001d0413          	addi	s0,s10,1
ffffffffc020150a:	01350a63          	beq	a0,s3,ffffffffc020151e <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc020150e:	c121                	beqz	a0,ffffffffc020154e <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0201510:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201512:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0201514:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201516:	fff44503          	lbu	a0,-1(s0)
ffffffffc020151a:	ff351ae3          	bne	a0,s3,ffffffffc020150e <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020151e:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0201522:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0201526:	4c81                	li	s9,0
ffffffffc0201528:	4881                	li	a7,0
        width = precision = -1;
ffffffffc020152a:	5c7d                	li	s8,-1
ffffffffc020152c:	5dfd                	li	s11,-1
ffffffffc020152e:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0201532:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201534:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201538:	0ff5f593          	zext.b	a1,a1
ffffffffc020153c:	00140d13          	addi	s10,s0,1
ffffffffc0201540:	04b56263          	bltu	a0,a1,ffffffffc0201584 <vprintfmt+0xbc>
ffffffffc0201544:	058a                	slli	a1,a1,0x2
ffffffffc0201546:	95d6                	add	a1,a1,s5
ffffffffc0201548:	4194                	lw	a3,0(a1)
ffffffffc020154a:	96d6                	add	a3,a3,s5
ffffffffc020154c:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc020154e:	70e6                	ld	ra,120(sp)
ffffffffc0201550:	7446                	ld	s0,112(sp)
ffffffffc0201552:	74a6                	ld	s1,104(sp)
ffffffffc0201554:	7906                	ld	s2,96(sp)
ffffffffc0201556:	69e6                	ld	s3,88(sp)
ffffffffc0201558:	6a46                	ld	s4,80(sp)
ffffffffc020155a:	6aa6                	ld	s5,72(sp)
ffffffffc020155c:	6b06                	ld	s6,64(sp)
ffffffffc020155e:	7be2                	ld	s7,56(sp)
ffffffffc0201560:	7c42                	ld	s8,48(sp)
ffffffffc0201562:	7ca2                	ld	s9,40(sp)
ffffffffc0201564:	7d02                	ld	s10,32(sp)
ffffffffc0201566:	6de2                	ld	s11,24(sp)
ffffffffc0201568:	6109                	addi	sp,sp,128
ffffffffc020156a:	8082                	ret
            padc = '0';
ffffffffc020156c:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc020156e:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201572:	846a                	mv	s0,s10
ffffffffc0201574:	00140d13          	addi	s10,s0,1
ffffffffc0201578:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020157c:	0ff5f593          	zext.b	a1,a1
ffffffffc0201580:	fcb572e3          	bgeu	a0,a1,ffffffffc0201544 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0201584:	85a6                	mv	a1,s1
ffffffffc0201586:	02500513          	li	a0,37
ffffffffc020158a:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020158c:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201590:	8d22                	mv	s10,s0
ffffffffc0201592:	f73788e3          	beq	a5,s3,ffffffffc0201502 <vprintfmt+0x3a>
ffffffffc0201596:	ffed4783          	lbu	a5,-2(s10)
ffffffffc020159a:	1d7d                	addi	s10,s10,-1
ffffffffc020159c:	ff379de3          	bne	a5,s3,ffffffffc0201596 <vprintfmt+0xce>
ffffffffc02015a0:	b78d                	j	ffffffffc0201502 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc02015a2:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc02015a6:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015aa:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02015ac:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02015b0:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02015b4:	02d86463          	bltu	a6,a3,ffffffffc02015dc <vprintfmt+0x114>
                ch = *fmt;
ffffffffc02015b8:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02015bc:	002c169b          	slliw	a3,s8,0x2
ffffffffc02015c0:	0186873b          	addw	a4,a3,s8
ffffffffc02015c4:	0017171b          	slliw	a4,a4,0x1
ffffffffc02015c8:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc02015ca:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02015ce:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02015d0:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc02015d4:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02015d8:	fed870e3          	bgeu	a6,a3,ffffffffc02015b8 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc02015dc:	f40ddce3          	bgez	s11,ffffffffc0201534 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc02015e0:	8de2                	mv	s11,s8
ffffffffc02015e2:	5c7d                	li	s8,-1
ffffffffc02015e4:	bf81                	j	ffffffffc0201534 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc02015e6:	fffdc693          	not	a3,s11
ffffffffc02015ea:	96fd                	srai	a3,a3,0x3f
ffffffffc02015ec:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015f0:	00144603          	lbu	a2,1(s0)
ffffffffc02015f4:	2d81                	sext.w	s11,s11
ffffffffc02015f6:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02015f8:	bf35                	j	ffffffffc0201534 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc02015fa:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015fe:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0201602:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201604:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0201606:	bfd9                	j	ffffffffc02015dc <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0201608:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020160a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020160e:	01174463          	blt	a4,a7,ffffffffc0201616 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0201612:	1a088e63          	beqz	a7,ffffffffc02017ce <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0201616:	000a3603          	ld	a2,0(s4)
ffffffffc020161a:	46c1                	li	a3,16
ffffffffc020161c:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020161e:	2781                	sext.w	a5,a5
ffffffffc0201620:	876e                	mv	a4,s11
ffffffffc0201622:	85a6                	mv	a1,s1
ffffffffc0201624:	854a                	mv	a0,s2
ffffffffc0201626:	e37ff0ef          	jal	ra,ffffffffc020145c <printnum>
            break;
ffffffffc020162a:	bde1                	j	ffffffffc0201502 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc020162c:	000a2503          	lw	a0,0(s4)
ffffffffc0201630:	85a6                	mv	a1,s1
ffffffffc0201632:	0a21                	addi	s4,s4,8
ffffffffc0201634:	9902                	jalr	s2
            break;
ffffffffc0201636:	b5f1                	j	ffffffffc0201502 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201638:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020163a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020163e:	01174463          	blt	a4,a7,ffffffffc0201646 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0201642:	18088163          	beqz	a7,ffffffffc02017c4 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0201646:	000a3603          	ld	a2,0(s4)
ffffffffc020164a:	46a9                	li	a3,10
ffffffffc020164c:	8a2e                	mv	s4,a1
ffffffffc020164e:	bfc1                	j	ffffffffc020161e <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201650:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0201654:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201656:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201658:	bdf1                	j	ffffffffc0201534 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc020165a:	85a6                	mv	a1,s1
ffffffffc020165c:	02500513          	li	a0,37
ffffffffc0201660:	9902                	jalr	s2
            break;
ffffffffc0201662:	b545                	j	ffffffffc0201502 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201664:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0201668:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020166a:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020166c:	b5e1                	j	ffffffffc0201534 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc020166e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201670:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201674:	01174463          	blt	a4,a7,ffffffffc020167c <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0201678:	14088163          	beqz	a7,ffffffffc02017ba <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc020167c:	000a3603          	ld	a2,0(s4)
ffffffffc0201680:	46a1                	li	a3,8
ffffffffc0201682:	8a2e                	mv	s4,a1
ffffffffc0201684:	bf69                	j	ffffffffc020161e <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0201686:	03000513          	li	a0,48
ffffffffc020168a:	85a6                	mv	a1,s1
ffffffffc020168c:	e03e                	sd	a5,0(sp)
ffffffffc020168e:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201690:	85a6                	mv	a1,s1
ffffffffc0201692:	07800513          	li	a0,120
ffffffffc0201696:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201698:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc020169a:	6782                	ld	a5,0(sp)
ffffffffc020169c:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020169e:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc02016a2:	bfb5                	j	ffffffffc020161e <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02016a4:	000a3403          	ld	s0,0(s4)
ffffffffc02016a8:	008a0713          	addi	a4,s4,8
ffffffffc02016ac:	e03a                	sd	a4,0(sp)
ffffffffc02016ae:	14040263          	beqz	s0,ffffffffc02017f2 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc02016b2:	0fb05763          	blez	s11,ffffffffc02017a0 <vprintfmt+0x2d8>
ffffffffc02016b6:	02d00693          	li	a3,45
ffffffffc02016ba:	0cd79163          	bne	a5,a3,ffffffffc020177c <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02016be:	00044783          	lbu	a5,0(s0)
ffffffffc02016c2:	0007851b          	sext.w	a0,a5
ffffffffc02016c6:	cf85                	beqz	a5,ffffffffc02016fe <vprintfmt+0x236>
ffffffffc02016c8:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02016cc:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02016d0:	000c4563          	bltz	s8,ffffffffc02016da <vprintfmt+0x212>
ffffffffc02016d4:	3c7d                	addiw	s8,s8,-1
ffffffffc02016d6:	036c0263          	beq	s8,s6,ffffffffc02016fa <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc02016da:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02016dc:	0e0c8e63          	beqz	s9,ffffffffc02017d8 <vprintfmt+0x310>
ffffffffc02016e0:	3781                	addiw	a5,a5,-32
ffffffffc02016e2:	0ef47b63          	bgeu	s0,a5,ffffffffc02017d8 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc02016e6:	03f00513          	li	a0,63
ffffffffc02016ea:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02016ec:	000a4783          	lbu	a5,0(s4)
ffffffffc02016f0:	3dfd                	addiw	s11,s11,-1
ffffffffc02016f2:	0a05                	addi	s4,s4,1
ffffffffc02016f4:	0007851b          	sext.w	a0,a5
ffffffffc02016f8:	ffe1                	bnez	a5,ffffffffc02016d0 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc02016fa:	01b05963          	blez	s11,ffffffffc020170c <vprintfmt+0x244>
ffffffffc02016fe:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201700:	85a6                	mv	a1,s1
ffffffffc0201702:	02000513          	li	a0,32
ffffffffc0201706:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201708:	fe0d9be3          	bnez	s11,ffffffffc02016fe <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020170c:	6a02                	ld	s4,0(sp)
ffffffffc020170e:	bbd5                	j	ffffffffc0201502 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201710:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201712:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0201716:	01174463          	blt	a4,a7,ffffffffc020171e <vprintfmt+0x256>
    else if (lflag) {
ffffffffc020171a:	08088d63          	beqz	a7,ffffffffc02017b4 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc020171e:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0201722:	0a044d63          	bltz	s0,ffffffffc02017dc <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0201726:	8622                	mv	a2,s0
ffffffffc0201728:	8a66                	mv	s4,s9
ffffffffc020172a:	46a9                	li	a3,10
ffffffffc020172c:	bdcd                	j	ffffffffc020161e <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc020172e:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201732:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0201734:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0201736:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc020173a:	8fb5                	xor	a5,a5,a3
ffffffffc020173c:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201740:	02d74163          	blt	a4,a3,ffffffffc0201762 <vprintfmt+0x29a>
ffffffffc0201744:	00369793          	slli	a5,a3,0x3
ffffffffc0201748:	97de                	add	a5,a5,s7
ffffffffc020174a:	639c                	ld	a5,0(a5)
ffffffffc020174c:	cb99                	beqz	a5,ffffffffc0201762 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc020174e:	86be                	mv	a3,a5
ffffffffc0201750:	00001617          	auipc	a2,0x1
ffffffffc0201754:	e8860613          	addi	a2,a2,-376 # ffffffffc02025d8 <best_fit_pmm_manager+0x190>
ffffffffc0201758:	85a6                	mv	a1,s1
ffffffffc020175a:	854a                	mv	a0,s2
ffffffffc020175c:	0ce000ef          	jal	ra,ffffffffc020182a <printfmt>
ffffffffc0201760:	b34d                	j	ffffffffc0201502 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201762:	00001617          	auipc	a2,0x1
ffffffffc0201766:	e6660613          	addi	a2,a2,-410 # ffffffffc02025c8 <best_fit_pmm_manager+0x180>
ffffffffc020176a:	85a6                	mv	a1,s1
ffffffffc020176c:	854a                	mv	a0,s2
ffffffffc020176e:	0bc000ef          	jal	ra,ffffffffc020182a <printfmt>
ffffffffc0201772:	bb41                	j	ffffffffc0201502 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201774:	00001417          	auipc	s0,0x1
ffffffffc0201778:	e4c40413          	addi	s0,s0,-436 # ffffffffc02025c0 <best_fit_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020177c:	85e2                	mv	a1,s8
ffffffffc020177e:	8522                	mv	a0,s0
ffffffffc0201780:	e43e                	sd	a5,8(sp)
ffffffffc0201782:	1cc000ef          	jal	ra,ffffffffc020194e <strnlen>
ffffffffc0201786:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020178a:	01b05b63          	blez	s11,ffffffffc02017a0 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc020178e:	67a2                	ld	a5,8(sp)
ffffffffc0201790:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201794:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201796:	85a6                	mv	a1,s1
ffffffffc0201798:	8552                	mv	a0,s4
ffffffffc020179a:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020179c:	fe0d9ce3          	bnez	s11,ffffffffc0201794 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02017a0:	00044783          	lbu	a5,0(s0)
ffffffffc02017a4:	00140a13          	addi	s4,s0,1
ffffffffc02017a8:	0007851b          	sext.w	a0,a5
ffffffffc02017ac:	d3a5                	beqz	a5,ffffffffc020170c <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02017ae:	05e00413          	li	s0,94
ffffffffc02017b2:	bf39                	j	ffffffffc02016d0 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc02017b4:	000a2403          	lw	s0,0(s4)
ffffffffc02017b8:	b7ad                	j	ffffffffc0201722 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc02017ba:	000a6603          	lwu	a2,0(s4)
ffffffffc02017be:	46a1                	li	a3,8
ffffffffc02017c0:	8a2e                	mv	s4,a1
ffffffffc02017c2:	bdb1                	j	ffffffffc020161e <vprintfmt+0x156>
ffffffffc02017c4:	000a6603          	lwu	a2,0(s4)
ffffffffc02017c8:	46a9                	li	a3,10
ffffffffc02017ca:	8a2e                	mv	s4,a1
ffffffffc02017cc:	bd89                	j	ffffffffc020161e <vprintfmt+0x156>
ffffffffc02017ce:	000a6603          	lwu	a2,0(s4)
ffffffffc02017d2:	46c1                	li	a3,16
ffffffffc02017d4:	8a2e                	mv	s4,a1
ffffffffc02017d6:	b5a1                	j	ffffffffc020161e <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc02017d8:	9902                	jalr	s2
ffffffffc02017da:	bf09                	j	ffffffffc02016ec <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc02017dc:	85a6                	mv	a1,s1
ffffffffc02017de:	02d00513          	li	a0,45
ffffffffc02017e2:	e03e                	sd	a5,0(sp)
ffffffffc02017e4:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02017e6:	6782                	ld	a5,0(sp)
ffffffffc02017e8:	8a66                	mv	s4,s9
ffffffffc02017ea:	40800633          	neg	a2,s0
ffffffffc02017ee:	46a9                	li	a3,10
ffffffffc02017f0:	b53d                	j	ffffffffc020161e <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc02017f2:	03b05163          	blez	s11,ffffffffc0201814 <vprintfmt+0x34c>
ffffffffc02017f6:	02d00693          	li	a3,45
ffffffffc02017fa:	f6d79de3          	bne	a5,a3,ffffffffc0201774 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc02017fe:	00001417          	auipc	s0,0x1
ffffffffc0201802:	dc240413          	addi	s0,s0,-574 # ffffffffc02025c0 <best_fit_pmm_manager+0x178>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201806:	02800793          	li	a5,40
ffffffffc020180a:	02800513          	li	a0,40
ffffffffc020180e:	00140a13          	addi	s4,s0,1
ffffffffc0201812:	bd6d                	j	ffffffffc02016cc <vprintfmt+0x204>
ffffffffc0201814:	00001a17          	auipc	s4,0x1
ffffffffc0201818:	dada0a13          	addi	s4,s4,-595 # ffffffffc02025c1 <best_fit_pmm_manager+0x179>
ffffffffc020181c:	02800513          	li	a0,40
ffffffffc0201820:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201824:	05e00413          	li	s0,94
ffffffffc0201828:	b565                	j	ffffffffc02016d0 <vprintfmt+0x208>

ffffffffc020182a <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020182a:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc020182c:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201830:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201832:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201834:	ec06                	sd	ra,24(sp)
ffffffffc0201836:	f83a                	sd	a4,48(sp)
ffffffffc0201838:	fc3e                	sd	a5,56(sp)
ffffffffc020183a:	e0c2                	sd	a6,64(sp)
ffffffffc020183c:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc020183e:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201840:	c89ff0ef          	jal	ra,ffffffffc02014c8 <vprintfmt>
}
ffffffffc0201844:	60e2                	ld	ra,24(sp)
ffffffffc0201846:	6161                	addi	sp,sp,80
ffffffffc0201848:	8082                	ret

ffffffffc020184a <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc020184a:	715d                	addi	sp,sp,-80
ffffffffc020184c:	e486                	sd	ra,72(sp)
ffffffffc020184e:	e0a6                	sd	s1,64(sp)
ffffffffc0201850:	fc4a                	sd	s2,56(sp)
ffffffffc0201852:	f84e                	sd	s3,48(sp)
ffffffffc0201854:	f452                	sd	s4,40(sp)
ffffffffc0201856:	f056                	sd	s5,32(sp)
ffffffffc0201858:	ec5a                	sd	s6,24(sp)
ffffffffc020185a:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc020185c:	c901                	beqz	a0,ffffffffc020186c <readline+0x22>
ffffffffc020185e:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0201860:	00001517          	auipc	a0,0x1
ffffffffc0201864:	d7850513          	addi	a0,a0,-648 # ffffffffc02025d8 <best_fit_pmm_manager+0x190>
ffffffffc0201868:	84bfe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
readline(const char *prompt) {
ffffffffc020186c:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020186e:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201870:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201872:	4aa9                	li	s5,10
ffffffffc0201874:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201876:	00004b97          	auipc	s7,0x4
ffffffffc020187a:	7b2b8b93          	addi	s7,s7,1970 # ffffffffc0206028 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020187e:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201882:	8a9fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201886:	00054a63          	bltz	a0,ffffffffc020189a <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020188a:	00a95a63          	bge	s2,a0,ffffffffc020189e <readline+0x54>
ffffffffc020188e:	029a5263          	bge	s4,s1,ffffffffc02018b2 <readline+0x68>
        c = getchar();
ffffffffc0201892:	899fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201896:	fe055ae3          	bgez	a0,ffffffffc020188a <readline+0x40>
            return NULL;
ffffffffc020189a:	4501                	li	a0,0
ffffffffc020189c:	a091                	j	ffffffffc02018e0 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc020189e:	03351463          	bne	a0,s3,ffffffffc02018c6 <readline+0x7c>
ffffffffc02018a2:	e8a9                	bnez	s1,ffffffffc02018f4 <readline+0xaa>
        c = getchar();
ffffffffc02018a4:	887fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc02018a8:	fe0549e3          	bltz	a0,ffffffffc020189a <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02018ac:	fea959e3          	bge	s2,a0,ffffffffc020189e <readline+0x54>
ffffffffc02018b0:	4481                	li	s1,0
            cputchar(c);
ffffffffc02018b2:	e42a                	sd	a0,8(sp)
ffffffffc02018b4:	835fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i ++] = c;
ffffffffc02018b8:	6522                	ld	a0,8(sp)
ffffffffc02018ba:	009b87b3          	add	a5,s7,s1
ffffffffc02018be:	2485                	addiw	s1,s1,1
ffffffffc02018c0:	00a78023          	sb	a0,0(a5)
ffffffffc02018c4:	bf7d                	j	ffffffffc0201882 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc02018c6:	01550463          	beq	a0,s5,ffffffffc02018ce <readline+0x84>
ffffffffc02018ca:	fb651ce3          	bne	a0,s6,ffffffffc0201882 <readline+0x38>
            cputchar(c);
ffffffffc02018ce:	81bfe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i] = '\0';
ffffffffc02018d2:	00004517          	auipc	a0,0x4
ffffffffc02018d6:	75650513          	addi	a0,a0,1878 # ffffffffc0206028 <buf>
ffffffffc02018da:	94aa                	add	s1,s1,a0
ffffffffc02018dc:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02018e0:	60a6                	ld	ra,72(sp)
ffffffffc02018e2:	6486                	ld	s1,64(sp)
ffffffffc02018e4:	7962                	ld	s2,56(sp)
ffffffffc02018e6:	79c2                	ld	s3,48(sp)
ffffffffc02018e8:	7a22                	ld	s4,40(sp)
ffffffffc02018ea:	7a82                	ld	s5,32(sp)
ffffffffc02018ec:	6b62                	ld	s6,24(sp)
ffffffffc02018ee:	6bc2                	ld	s7,16(sp)
ffffffffc02018f0:	6161                	addi	sp,sp,80
ffffffffc02018f2:	8082                	ret
            cputchar(c);
ffffffffc02018f4:	4521                	li	a0,8
ffffffffc02018f6:	ff2fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            i --;
ffffffffc02018fa:	34fd                	addiw	s1,s1,-1
ffffffffc02018fc:	b759                	j	ffffffffc0201882 <readline+0x38>

ffffffffc02018fe <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc02018fe:	4781                	li	a5,0
ffffffffc0201900:	00004717          	auipc	a4,0x4
ffffffffc0201904:	70873703          	ld	a4,1800(a4) # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201908:	88ba                	mv	a7,a4
ffffffffc020190a:	852a                	mv	a0,a0
ffffffffc020190c:	85be                	mv	a1,a5
ffffffffc020190e:	863e                	mv	a2,a5
ffffffffc0201910:	00000073          	ecall
ffffffffc0201914:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc0201916:	8082                	ret

ffffffffc0201918 <sbi_set_timer>:
    __asm__ volatile (
ffffffffc0201918:	4781                	li	a5,0
ffffffffc020191a:	00005717          	auipc	a4,0x5
ffffffffc020191e:	b4e73703          	ld	a4,-1202(a4) # ffffffffc0206468 <SBI_SET_TIMER>
ffffffffc0201922:	88ba                	mv	a7,a4
ffffffffc0201924:	852a                	mv	a0,a0
ffffffffc0201926:	85be                	mv	a1,a5
ffffffffc0201928:	863e                	mv	a2,a5
ffffffffc020192a:	00000073          	ecall
ffffffffc020192e:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc0201930:	8082                	ret

ffffffffc0201932 <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc0201932:	4501                	li	a0,0
ffffffffc0201934:	00004797          	auipc	a5,0x4
ffffffffc0201938:	6cc7b783          	ld	a5,1740(a5) # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc020193c:	88be                	mv	a7,a5
ffffffffc020193e:	852a                	mv	a0,a0
ffffffffc0201940:	85aa                	mv	a1,a0
ffffffffc0201942:	862a                	mv	a2,a0
ffffffffc0201944:	00000073          	ecall
ffffffffc0201948:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc020194a:	2501                	sext.w	a0,a0
ffffffffc020194c:	8082                	ret

ffffffffc020194e <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc020194e:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201950:	e589                	bnez	a1,ffffffffc020195a <strnlen+0xc>
ffffffffc0201952:	a811                	j	ffffffffc0201966 <strnlen+0x18>
        cnt ++;
ffffffffc0201954:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201956:	00f58863          	beq	a1,a5,ffffffffc0201966 <strnlen+0x18>
ffffffffc020195a:	00f50733          	add	a4,a0,a5
ffffffffc020195e:	00074703          	lbu	a4,0(a4)
ffffffffc0201962:	fb6d                	bnez	a4,ffffffffc0201954 <strnlen+0x6>
ffffffffc0201964:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0201966:	852e                	mv	a0,a1
ffffffffc0201968:	8082                	ret

ffffffffc020196a <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020196a:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020196e:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201972:	cb89                	beqz	a5,ffffffffc0201984 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0201974:	0505                	addi	a0,a0,1
ffffffffc0201976:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201978:	fee789e3          	beq	a5,a4,ffffffffc020196a <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020197c:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201980:	9d19                	subw	a0,a0,a4
ffffffffc0201982:	8082                	ret
ffffffffc0201984:	4501                	li	a0,0
ffffffffc0201986:	bfed                	j	ffffffffc0201980 <strcmp+0x16>

ffffffffc0201988 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201988:	00054783          	lbu	a5,0(a0)
ffffffffc020198c:	c799                	beqz	a5,ffffffffc020199a <strchr+0x12>
        if (*s == c) {
ffffffffc020198e:	00f58763          	beq	a1,a5,ffffffffc020199c <strchr+0x14>
    while (*s != '\0') {
ffffffffc0201992:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0201996:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201998:	fbfd                	bnez	a5,ffffffffc020198e <strchr+0x6>
    }
    return NULL;
ffffffffc020199a:	4501                	li	a0,0
}
ffffffffc020199c:	8082                	ret

ffffffffc020199e <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc020199e:	ca01                	beqz	a2,ffffffffc02019ae <memset+0x10>
ffffffffc02019a0:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02019a2:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02019a4:	0785                	addi	a5,a5,1
ffffffffc02019a6:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02019aa:	fec79de3          	bne	a5,a2,ffffffffc02019a4 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02019ae:	8082                	ret
