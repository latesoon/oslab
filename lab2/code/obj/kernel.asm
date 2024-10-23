
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
ffffffffc020004a:	19d010ef          	jal	ra,ffffffffc02019e6 <memset>
    cons_init();  // init the console
ffffffffc020004e:	3fc000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00002517          	auipc	a0,0x2
ffffffffc0200056:	9a650513          	addi	a0,a0,-1626 # ffffffffc02019f8 <etext>
ffffffffc020005a:	090000ef          	jal	ra,ffffffffc02000ea <cputs>

    print_kerninfo();
ffffffffc020005e:	0dc000ef          	jal	ra,ffffffffc020013a <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	402000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	2aa010ef          	jal	ra,ffffffffc0201310 <pmm_init>

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
ffffffffc02000a6:	46a010ef          	jal	ra,ffffffffc0201510 <vprintfmt>
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
ffffffffc02000dc:	434010ef          	jal	ra,ffffffffc0201510 <vprintfmt>
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
ffffffffc0200140:	8dc50513          	addi	a0,a0,-1828 # ffffffffc0201a18 <etext+0x20>
void print_kerninfo(void) {
ffffffffc0200144:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200146:	f6dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014a:	00000597          	auipc	a1,0x0
ffffffffc020014e:	ee858593          	addi	a1,a1,-280 # ffffffffc0200032 <kern_init>
ffffffffc0200152:	00002517          	auipc	a0,0x2
ffffffffc0200156:	8e650513          	addi	a0,a0,-1818 # ffffffffc0201a38 <etext+0x40>
ffffffffc020015a:	f59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020015e:	00002597          	auipc	a1,0x2
ffffffffc0200162:	89a58593          	addi	a1,a1,-1894 # ffffffffc02019f8 <etext>
ffffffffc0200166:	00002517          	auipc	a0,0x2
ffffffffc020016a:	8f250513          	addi	a0,a0,-1806 # ffffffffc0201a58 <etext+0x60>
ffffffffc020016e:	f45ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200172:	00006597          	auipc	a1,0x6
ffffffffc0200176:	e9e58593          	addi	a1,a1,-354 # ffffffffc0206010 <free_area>
ffffffffc020017a:	00002517          	auipc	a0,0x2
ffffffffc020017e:	8fe50513          	addi	a0,a0,-1794 # ffffffffc0201a78 <etext+0x80>
ffffffffc0200182:	f31ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200186:	00006597          	auipc	a1,0x6
ffffffffc020018a:	2ea58593          	addi	a1,a1,746 # ffffffffc0206470 <end>
ffffffffc020018e:	00002517          	auipc	a0,0x2
ffffffffc0200192:	90a50513          	addi	a0,a0,-1782 # ffffffffc0201a98 <etext+0xa0>
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
ffffffffc02001c0:	8fc50513          	addi	a0,a0,-1796 # ffffffffc0201ab8 <etext+0xc0>
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
ffffffffc02001ce:	91e60613          	addi	a2,a2,-1762 # ffffffffc0201ae8 <etext+0xf0>
ffffffffc02001d2:	04e00593          	li	a1,78
ffffffffc02001d6:	00002517          	auipc	a0,0x2
ffffffffc02001da:	92a50513          	addi	a0,a0,-1750 # ffffffffc0201b00 <etext+0x108>
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
ffffffffc02001ea:	93260613          	addi	a2,a2,-1742 # ffffffffc0201b18 <etext+0x120>
ffffffffc02001ee:	00002597          	auipc	a1,0x2
ffffffffc02001f2:	94a58593          	addi	a1,a1,-1718 # ffffffffc0201b38 <etext+0x140>
ffffffffc02001f6:	00002517          	auipc	a0,0x2
ffffffffc02001fa:	94a50513          	addi	a0,a0,-1718 # ffffffffc0201b40 <etext+0x148>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001fe:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200200:	eb3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200204:	00002617          	auipc	a2,0x2
ffffffffc0200208:	94c60613          	addi	a2,a2,-1716 # ffffffffc0201b50 <etext+0x158>
ffffffffc020020c:	00002597          	auipc	a1,0x2
ffffffffc0200210:	96c58593          	addi	a1,a1,-1684 # ffffffffc0201b78 <etext+0x180>
ffffffffc0200214:	00002517          	auipc	a0,0x2
ffffffffc0200218:	92c50513          	addi	a0,a0,-1748 # ffffffffc0201b40 <etext+0x148>
ffffffffc020021c:	e97ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200220:	00002617          	auipc	a2,0x2
ffffffffc0200224:	96860613          	addi	a2,a2,-1688 # ffffffffc0201b88 <etext+0x190>
ffffffffc0200228:	00002597          	auipc	a1,0x2
ffffffffc020022c:	98058593          	addi	a1,a1,-1664 # ffffffffc0201ba8 <etext+0x1b0>
ffffffffc0200230:	00002517          	auipc	a0,0x2
ffffffffc0200234:	91050513          	addi	a0,a0,-1776 # ffffffffc0201b40 <etext+0x148>
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
ffffffffc020026e:	94e50513          	addi	a0,a0,-1714 # ffffffffc0201bb8 <etext+0x1c0>
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
ffffffffc0200290:	95450513          	addi	a0,a0,-1708 # ffffffffc0201be0 <etext+0x1e8>
ffffffffc0200294:	e1fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    if (tf != NULL) {
ffffffffc0200298:	000b8563          	beqz	s7,ffffffffc02002a2 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020029c:	855e                	mv	a0,s7
ffffffffc020029e:	3a4000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002a2:	00002c17          	auipc	s8,0x2
ffffffffc02002a6:	9aec0c13          	addi	s8,s8,-1618 # ffffffffc0201c50 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002aa:	00002917          	auipc	s2,0x2
ffffffffc02002ae:	95e90913          	addi	s2,s2,-1698 # ffffffffc0201c08 <etext+0x210>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b2:	00002497          	auipc	s1,0x2
ffffffffc02002b6:	95e48493          	addi	s1,s1,-1698 # ffffffffc0201c10 <etext+0x218>
        if (argc == MAXARGS - 1) {
ffffffffc02002ba:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002bc:	00002b17          	auipc	s6,0x2
ffffffffc02002c0:	95cb0b13          	addi	s6,s6,-1700 # ffffffffc0201c18 <etext+0x220>
        argv[argc ++] = buf;
ffffffffc02002c4:	00002a17          	auipc	s4,0x2
ffffffffc02002c8:	874a0a13          	addi	s4,s4,-1932 # ffffffffc0201b38 <etext+0x140>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002cc:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002ce:	854a                	mv	a0,s2
ffffffffc02002d0:	5c2010ef          	jal	ra,ffffffffc0201892 <readline>
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
ffffffffc02002ea:	96ad0d13          	addi	s10,s10,-1686 # ffffffffc0201c50 <commands>
        argv[argc ++] = buf;
ffffffffc02002ee:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f0:	4401                	li	s0,0
ffffffffc02002f2:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002f4:	6be010ef          	jal	ra,ffffffffc02019b2 <strcmp>
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
ffffffffc0200308:	6aa010ef          	jal	ra,ffffffffc02019b2 <strcmp>
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
ffffffffc0200346:	68a010ef          	jal	ra,ffffffffc02019d0 <strchr>
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
ffffffffc0200384:	64c010ef          	jal	ra,ffffffffc02019d0 <strchr>
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
ffffffffc02003a2:	89a50513          	addi	a0,a0,-1894 # ffffffffc0201c38 <etext+0x240>
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
ffffffffc02003de:	8be50513          	addi	a0,a0,-1858 # ffffffffc0201c98 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02003e2:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e4:	ccfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003e8:	65a2                	ld	a1,8(sp)
ffffffffc02003ea:	8522                	mv	a0,s0
ffffffffc02003ec:	ca7ff0ef          	jal	ra,ffffffffc0200092 <vcprintf>
    cprintf("\n");
ffffffffc02003f0:	00002517          	auipc	a0,0x2
ffffffffc02003f4:	da050513          	addi	a0,a0,-608 # ffffffffc0202190 <commands+0x540>
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
ffffffffc0200420:	540010ef          	jal	ra,ffffffffc0201960 <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00006797          	auipc	a5,0x6
ffffffffc020042a:	0007b523          	sd	zero,10(a5) # ffffffffc0206430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00002517          	auipc	a0,0x2
ffffffffc0200432:	88a50513          	addi	a0,a0,-1910 # ffffffffc0201cb8 <commands+0x68>
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
ffffffffc0200446:	51a0106f          	j	ffffffffc0201960 <sbi_set_timer>

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
ffffffffc0200450:	4f60106f          	j	ffffffffc0201946 <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	5260106f          	j	ffffffffc020197a <sbi_console_getchar>

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
ffffffffc0200482:	85a50513          	addi	a0,a0,-1958 # ffffffffc0201cd8 <commands+0x88>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00002517          	auipc	a0,0x2
ffffffffc0200492:	86250513          	addi	a0,a0,-1950 # ffffffffc0201cf0 <commands+0xa0>
ffffffffc0200496:	c1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00002517          	auipc	a0,0x2
ffffffffc02004a0:	86c50513          	addi	a0,a0,-1940 # ffffffffc0201d08 <commands+0xb8>
ffffffffc02004a4:	c0fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00002517          	auipc	a0,0x2
ffffffffc02004ae:	87650513          	addi	a0,a0,-1930 # ffffffffc0201d20 <commands+0xd0>
ffffffffc02004b2:	c01ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00002517          	auipc	a0,0x2
ffffffffc02004bc:	88050513          	addi	a0,a0,-1920 # ffffffffc0201d38 <commands+0xe8>
ffffffffc02004c0:	bf3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00002517          	auipc	a0,0x2
ffffffffc02004ca:	88a50513          	addi	a0,a0,-1910 # ffffffffc0201d50 <commands+0x100>
ffffffffc02004ce:	be5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00002517          	auipc	a0,0x2
ffffffffc02004d8:	89450513          	addi	a0,a0,-1900 # ffffffffc0201d68 <commands+0x118>
ffffffffc02004dc:	bd7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00002517          	auipc	a0,0x2
ffffffffc02004e6:	89e50513          	addi	a0,a0,-1890 # ffffffffc0201d80 <commands+0x130>
ffffffffc02004ea:	bc9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00002517          	auipc	a0,0x2
ffffffffc02004f4:	8a850513          	addi	a0,a0,-1880 # ffffffffc0201d98 <commands+0x148>
ffffffffc02004f8:	bbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00002517          	auipc	a0,0x2
ffffffffc0200502:	8b250513          	addi	a0,a0,-1870 # ffffffffc0201db0 <commands+0x160>
ffffffffc0200506:	badff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00002517          	auipc	a0,0x2
ffffffffc0200510:	8bc50513          	addi	a0,a0,-1860 # ffffffffc0201dc8 <commands+0x178>
ffffffffc0200514:	b9fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00002517          	auipc	a0,0x2
ffffffffc020051e:	8c650513          	addi	a0,a0,-1850 # ffffffffc0201de0 <commands+0x190>
ffffffffc0200522:	b91ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00002517          	auipc	a0,0x2
ffffffffc020052c:	8d050513          	addi	a0,a0,-1840 # ffffffffc0201df8 <commands+0x1a8>
ffffffffc0200530:	b83ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00002517          	auipc	a0,0x2
ffffffffc020053a:	8da50513          	addi	a0,a0,-1830 # ffffffffc0201e10 <commands+0x1c0>
ffffffffc020053e:	b75ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00002517          	auipc	a0,0x2
ffffffffc0200548:	8e450513          	addi	a0,a0,-1820 # ffffffffc0201e28 <commands+0x1d8>
ffffffffc020054c:	b67ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00002517          	auipc	a0,0x2
ffffffffc0200556:	8ee50513          	addi	a0,a0,-1810 # ffffffffc0201e40 <commands+0x1f0>
ffffffffc020055a:	b59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00002517          	auipc	a0,0x2
ffffffffc0200564:	8f850513          	addi	a0,a0,-1800 # ffffffffc0201e58 <commands+0x208>
ffffffffc0200568:	b4bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00002517          	auipc	a0,0x2
ffffffffc0200572:	90250513          	addi	a0,a0,-1790 # ffffffffc0201e70 <commands+0x220>
ffffffffc0200576:	b3dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00002517          	auipc	a0,0x2
ffffffffc0200580:	90c50513          	addi	a0,a0,-1780 # ffffffffc0201e88 <commands+0x238>
ffffffffc0200584:	b2fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00002517          	auipc	a0,0x2
ffffffffc020058e:	91650513          	addi	a0,a0,-1770 # ffffffffc0201ea0 <commands+0x250>
ffffffffc0200592:	b21ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00002517          	auipc	a0,0x2
ffffffffc020059c:	92050513          	addi	a0,a0,-1760 # ffffffffc0201eb8 <commands+0x268>
ffffffffc02005a0:	b13ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00002517          	auipc	a0,0x2
ffffffffc02005aa:	92a50513          	addi	a0,a0,-1750 # ffffffffc0201ed0 <commands+0x280>
ffffffffc02005ae:	b05ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00002517          	auipc	a0,0x2
ffffffffc02005b8:	93450513          	addi	a0,a0,-1740 # ffffffffc0201ee8 <commands+0x298>
ffffffffc02005bc:	af7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00002517          	auipc	a0,0x2
ffffffffc02005c6:	93e50513          	addi	a0,a0,-1730 # ffffffffc0201f00 <commands+0x2b0>
ffffffffc02005ca:	ae9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00002517          	auipc	a0,0x2
ffffffffc02005d4:	94850513          	addi	a0,a0,-1720 # ffffffffc0201f18 <commands+0x2c8>
ffffffffc02005d8:	adbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00002517          	auipc	a0,0x2
ffffffffc02005e2:	95250513          	addi	a0,a0,-1710 # ffffffffc0201f30 <commands+0x2e0>
ffffffffc02005e6:	acdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00002517          	auipc	a0,0x2
ffffffffc02005f0:	95c50513          	addi	a0,a0,-1700 # ffffffffc0201f48 <commands+0x2f8>
ffffffffc02005f4:	abfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00002517          	auipc	a0,0x2
ffffffffc02005fe:	96650513          	addi	a0,a0,-1690 # ffffffffc0201f60 <commands+0x310>
ffffffffc0200602:	ab1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00002517          	auipc	a0,0x2
ffffffffc020060c:	97050513          	addi	a0,a0,-1680 # ffffffffc0201f78 <commands+0x328>
ffffffffc0200610:	aa3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00002517          	auipc	a0,0x2
ffffffffc020061a:	97a50513          	addi	a0,a0,-1670 # ffffffffc0201f90 <commands+0x340>
ffffffffc020061e:	a95ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00002517          	auipc	a0,0x2
ffffffffc0200628:	98450513          	addi	a0,a0,-1660 # ffffffffc0201fa8 <commands+0x358>
ffffffffc020062c:	a87ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00002517          	auipc	a0,0x2
ffffffffc020063a:	98a50513          	addi	a0,a0,-1654 # ffffffffc0201fc0 <commands+0x370>
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
ffffffffc020064e:	98e50513          	addi	a0,a0,-1650 # ffffffffc0201fd8 <commands+0x388>
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
ffffffffc0200666:	98e50513          	addi	a0,a0,-1650 # ffffffffc0201ff0 <commands+0x3a0>
ffffffffc020066a:	a49ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00002517          	auipc	a0,0x2
ffffffffc0200676:	99650513          	addi	a0,a0,-1642 # ffffffffc0202008 <commands+0x3b8>
ffffffffc020067a:	a39ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00002517          	auipc	a0,0x2
ffffffffc0200686:	99e50513          	addi	a0,a0,-1634 # ffffffffc0202020 <commands+0x3d0>
ffffffffc020068a:	a29ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00002517          	auipc	a0,0x2
ffffffffc020069a:	9a250513          	addi	a0,a0,-1630 # ffffffffc0202038 <commands+0x3e8>
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
ffffffffc02006b4:	a6870713          	addi	a4,a4,-1432 # ffffffffc0202118 <commands+0x4c8>
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
ffffffffc02006c6:	9ee50513          	addi	a0,a0,-1554 # ffffffffc02020b0 <commands+0x460>
ffffffffc02006ca:	b2e5                	j	ffffffffc02000b2 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00002517          	auipc	a0,0x2
ffffffffc02006d0:	9c450513          	addi	a0,a0,-1596 # ffffffffc0202090 <commands+0x440>
ffffffffc02006d4:	baf9                	j	ffffffffc02000b2 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00002517          	auipc	a0,0x2
ffffffffc02006da:	97a50513          	addi	a0,a0,-1670 # ffffffffc0202050 <commands+0x400>
ffffffffc02006de:	bad1                	j	ffffffffc02000b2 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00002517          	auipc	a0,0x2
ffffffffc02006e4:	9f050513          	addi	a0,a0,-1552 # ffffffffc02020d0 <commands+0x480>
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
ffffffffc0200714:	9e850513          	addi	a0,a0,-1560 # ffffffffc02020f8 <commands+0x4a8>
ffffffffc0200718:	ba69                	j	ffffffffc02000b2 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc020071a:	00002517          	auipc	a0,0x2
ffffffffc020071e:	95650513          	addi	a0,a0,-1706 # ffffffffc0202070 <commands+0x420>
ffffffffc0200722:	ba41                	j	ffffffffc02000b2 <cprintf>
            print_trapframe(tf);
ffffffffc0200724:	bf39                	j	ffffffffc0200642 <print_trapframe>
}
ffffffffc0200726:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200728:	06400593          	li	a1,100
ffffffffc020072c:	00002517          	auipc	a0,0x2
ffffffffc0200730:	9bc50513          	addi	a0,a0,-1604 # ffffffffc02020e8 <commands+0x498>
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

ffffffffc0200802 <buddy_init>:
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
	return i;
}
static void
buddy_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc020080e:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200812:	8082                	ret

ffffffffc0200814 <buddy_nr_free_pages>:
}

static size_t
buddy_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200814:	00006517          	auipc	a0,0x6
ffffffffc0200818:	80c56503          	lwu	a0,-2036(a0) # ffffffffc0206020 <free_area+0x10>
ffffffffc020081c:	8082                	ret

ffffffffc020081e <buddy_alloc_pages>:
    assert(n > 0);
ffffffffc020081e:	c95d                	beqz	a0,ffffffffc02008d4 <buddy_alloc_pages+0xb6>
    if (n > nr_free) {
ffffffffc0200820:	00005817          	auipc	a6,0x5
ffffffffc0200824:	7f080813          	addi	a6,a6,2032 # ffffffffc0206010 <free_area>
ffffffffc0200828:	01082303          	lw	t1,16(a6)
ffffffffc020082c:	02031793          	slli	a5,t1,0x20
ffffffffc0200830:	9381                	srli	a5,a5,0x20
ffffffffc0200832:	08a7ef63          	bltu	a5,a0,ffffffffc02008d0 <buddy_alloc_pages+0xb2>
	while(i<x) i<<=1;
ffffffffc0200836:	4785                	li	a5,1
	size_t i=1;
ffffffffc0200838:	4685                	li	a3,1
	while(i<x) i<<=1;
ffffffffc020083a:	00f50563          	beq	a0,a5,ffffffffc0200844 <buddy_alloc_pages+0x26>
ffffffffc020083e:	0686                	slli	a3,a3,0x1
ffffffffc0200840:	fea6efe3          	bltu	a3,a0,ffffffffc020083e <buddy_alloc_pages+0x20>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200844:	00883583          	ld	a1,8(a6)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200848:	09058463          	beq	a1,a6,ffffffffc02008d0 <buddy_alloc_pages+0xb2>
ffffffffc020084c:	87ae                	mv	a5,a1
    struct Page *page = NULL;
ffffffffc020084e:	4501                	li	a0,0
        if (p->property >= need && (page == NULL || p->property < page->property)) {
ffffffffc0200850:	ff87a703          	lw	a4,-8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc0200854:	fe878893          	addi	a7,a5,-24
        if (p->property >= need && (page == NULL || p->property < page->property)) {
ffffffffc0200858:	02071613          	slli	a2,a4,0x20
ffffffffc020085c:	9201                	srli	a2,a2,0x20
ffffffffc020085e:	00d66763          	bltu	a2,a3,ffffffffc020086c <buddy_alloc_pages+0x4e>
ffffffffc0200862:	c501                	beqz	a0,ffffffffc020086a <buddy_alloc_pages+0x4c>
ffffffffc0200864:	4910                	lw	a2,16(a0)
ffffffffc0200866:	00c77363          	bgeu	a4,a2,ffffffffc020086c <buddy_alloc_pages+0x4e>
            page = p;
ffffffffc020086a:	8546                	mv	a0,a7
ffffffffc020086c:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc020086e:	ff0791e3          	bne	a5,a6,ffffffffc0200850 <buddy_alloc_pages+0x32>
    if (page != NULL) {
ffffffffc0200872:	c125                	beqz	a0,ffffffffc02008d2 <buddy_alloc_pages+0xb4>
        while (page->property > need) {
ffffffffc0200874:	4918                	lw	a4,16(a0)
    	nr_free -= need;
ffffffffc0200876:	40d3033b          	subw	t1,t1,a3
ffffffffc020087a:	00682823          	sw	t1,16(a6)
        while (page->property > need) {
ffffffffc020087e:	02071793          	slli	a5,a4,0x20
ffffffffc0200882:	9381                	srli	a5,a5,0x20
ffffffffc0200884:	04f6f163          	bgeu	a3,a5,ffffffffc02008c6 <buddy_alloc_pages+0xa8>
            struct Page *buddy = page + (page->property >> 1);
ffffffffc0200888:	0017561b          	srliw	a2,a4,0x1
ffffffffc020088c:	00261793          	slli	a5,a2,0x2
ffffffffc0200890:	97b2                	add	a5,a5,a2
ffffffffc0200892:	078e                	slli	a5,a5,0x3
ffffffffc0200894:	97aa                	add	a5,a5,a0
ffffffffc0200896:	0017571b          	srliw	a4,a4,0x1
            buddy->property = page->property >> 1;
ffffffffc020089a:	cb98                	sw	a4,16(a5)
            page->property>>=1;
ffffffffc020089c:	4918                	lw	a4,16(a0)
ffffffffc020089e:	88ae                	mv	a7,a1
            list_add(&free_list, &(buddy->page_link));
ffffffffc02008a0:	01878593          	addi	a1,a5,24
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02008a4:	00b8b023          	sd	a1,0(a7)
            page->property>>=1;
ffffffffc02008a8:	0017561b          	srliw	a2,a4,0x1
    elm->next = next;
ffffffffc02008ac:	0317b023          	sd	a7,32(a5)
    elm->prev = prev;
ffffffffc02008b0:	0107bc23          	sd	a6,24(a5)
ffffffffc02008b4:	c910                	sw	a2,16(a0)
        while (page->property > need) {
ffffffffc02008b6:	1602                	slli	a2,a2,0x20
ffffffffc02008b8:	9201                	srli	a2,a2,0x20
            page->property>>=1;
ffffffffc02008ba:	0017571b          	srliw	a4,a4,0x1
        while (page->property > need) {
ffffffffc02008be:	fcc6e5e3          	bltu	a3,a2,ffffffffc0200888 <buddy_alloc_pages+0x6a>
ffffffffc02008c2:	00b83423          	sd	a1,8(a6)
    __list_del(listelm->prev, listelm->next);
ffffffffc02008c6:	6d18                	ld	a4,24(a0)
ffffffffc02008c8:	711c                	ld	a5,32(a0)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02008ca:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02008cc:	e398                	sd	a4,0(a5)
}
ffffffffc02008ce:	8082                	ret
        return NULL;
ffffffffc02008d0:	4501                	li	a0,0
}
ffffffffc02008d2:	8082                	ret
buddy_alloc_pages(size_t n) { 
ffffffffc02008d4:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02008d6:	00002697          	auipc	a3,0x2
ffffffffc02008da:	87268693          	addi	a3,a3,-1934 # ffffffffc0202148 <commands+0x4f8>
ffffffffc02008de:	00002617          	auipc	a2,0x2
ffffffffc02008e2:	87260613          	addi	a2,a2,-1934 # ffffffffc0202150 <commands+0x500>
ffffffffc02008e6:	02f00593          	li	a1,47
ffffffffc02008ea:	00002517          	auipc	a0,0x2
ffffffffc02008ee:	87e50513          	addi	a0,a0,-1922 # ffffffffc0202168 <commands+0x518>
buddy_alloc_pages(size_t n) { 
ffffffffc02008f2:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02008f4:	ab9ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02008f8 <buddy_check>:

static void
buddy_check(void) {
ffffffffc02008f8:	7139                	addi	sp,sp,-64

	cprintf("testcase1 begin!\n");
ffffffffc02008fa:	00002517          	auipc	a0,0x2
ffffffffc02008fe:	88650513          	addi	a0,a0,-1914 # ffffffffc0202180 <commands+0x530>
buddy_check(void) {
ffffffffc0200902:	fc06                	sd	ra,56(sp)
ffffffffc0200904:	f822                	sd	s0,48(sp)
ffffffffc0200906:	f426                	sd	s1,40(sp)
ffffffffc0200908:	f04a                	sd	s2,32(sp)
ffffffffc020090a:	ec4e                	sd	s3,24(sp)
ffffffffc020090c:	e852                	sd	s4,16(sp)
ffffffffc020090e:	e456                	sd	s5,8(sp)
ffffffffc0200910:	e05a                	sd	s6,0(sp)
	cprintf("testcase1 begin!\n");
ffffffffc0200912:	fa0ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
	
	struct Page *p0, *p1, *p2, *p3;

	assert((p0 = alloc_pages(2)) != NULL);
ffffffffc0200916:	4509                	li	a0,2
ffffffffc0200918:	17b000ef          	jal	ra,ffffffffc0201292 <alloc_pages>
ffffffffc020091c:	3e050c63          	beqz	a0,ffffffffc0200d14 <buddy_check+0x41c>
ffffffffc0200920:	842a                	mv	s0,a0
    assert((p1 = alloc_pages(4)) != NULL);
ffffffffc0200922:	4511                	li	a0,4
ffffffffc0200924:	16f000ef          	jal	ra,ffffffffc0201292 <alloc_pages>
ffffffffc0200928:	892a                	mv	s2,a0
ffffffffc020092a:	3c050563          	beqz	a0,ffffffffc0200cf4 <buddy_check+0x3fc>
    assert((p2 = alloc_pages(2)) != NULL);
ffffffffc020092e:	4509                	li	a0,2
ffffffffc0200930:	163000ef          	jal	ra,ffffffffc0201292 <alloc_pages>
ffffffffc0200934:	84aa                	mv	s1,a0
ffffffffc0200936:	58050f63          	beqz	a0,ffffffffc0200ed4 <buddy_check+0x5dc>
    
    assert(p0 + 4 == p1);
ffffffffc020093a:	0a040793          	addi	a5,s0,160
ffffffffc020093e:	56f91b63          	bne	s2,a5,ffffffffc0200eb4 <buddy_check+0x5bc>
    assert(p0 + 2 == p2);
ffffffffc0200942:	05040793          	addi	a5,s0,80
ffffffffc0200946:	54f51763          	bne	a0,a5,ffffffffc0200e94 <buddy_check+0x59c>
    
    free_pages(p0,4);
ffffffffc020094a:	8522                	mv	a0,s0
ffffffffc020094c:	4591                	li	a1,4
ffffffffc020094e:	183000ef          	jal	ra,ffffffffc02012d0 <free_pages>
    free_pages(p1,4);
ffffffffc0200952:	4591                	li	a1,4
ffffffffc0200954:	854a                	mv	a0,s2
ffffffffc0200956:	17b000ef          	jal	ra,ffffffffc02012d0 <free_pages>
    
    assert((p0 = alloc_pages(2)) != NULL);
ffffffffc020095a:	4509                	li	a0,2
ffffffffc020095c:	137000ef          	jal	ra,ffffffffc0201292 <alloc_pages>
ffffffffc0200960:	842a                	mv	s0,a0
ffffffffc0200962:	50050963          	beqz	a0,ffffffffc0200e74 <buddy_check+0x57c>
    assert((p1 = alloc_pages(4)) != NULL);
ffffffffc0200966:	4511                	li	a0,4
ffffffffc0200968:	12b000ef          	jal	ra,ffffffffc0201292 <alloc_pages>
ffffffffc020096c:	892a                	mv	s2,a0
ffffffffc020096e:	4e050363          	beqz	a0,ffffffffc0200e54 <buddy_check+0x55c>
    assert((p3 = alloc_pages(2)) != NULL);
ffffffffc0200972:	4509                	li	a0,2
ffffffffc0200974:	11f000ef          	jal	ra,ffffffffc0201292 <alloc_pages>
ffffffffc0200978:	4a050e63          	beqz	a0,ffffffffc0200e34 <buddy_check+0x53c>
    
    assert(p0 + 4 == p1);
ffffffffc020097c:	0a040793          	addi	a5,s0,160
ffffffffc0200980:	48f91a63          	bne	s2,a5,ffffffffc0200e14 <buddy_check+0x51c>
    assert(p0 + 2 == p2);
ffffffffc0200984:	05040793          	addi	a5,s0,80
ffffffffc0200988:	46f49663          	bne	s1,a5,ffffffffc0200df4 <buddy_check+0x4fc>
    assert(p2 == p3);
ffffffffc020098c:	64a49463          	bne	s1,a0,ffffffffc0200fd4 <buddy_check+0x6dc>
    
    free_pages(p0,8);
ffffffffc0200990:	8522                	mv	a0,s0
ffffffffc0200992:	45a1                	li	a1,8
ffffffffc0200994:	13d000ef          	jal	ra,ffffffffc02012d0 <free_pages>
    
    assert((p0 = alloc_pages(4)) != NULL);
ffffffffc0200998:	4511                	li	a0,4
ffffffffc020099a:	0f9000ef          	jal	ra,ffffffffc0201292 <alloc_pages>
ffffffffc020099e:	842a                	mv	s0,a0
ffffffffc02009a0:	60050a63          	beqz	a0,ffffffffc0200fb4 <buddy_check+0x6bc>
    assert((p1 = alloc_pages(8)) != NULL);
ffffffffc02009a4:	4521                	li	a0,8
ffffffffc02009a6:	0ed000ef          	jal	ra,ffffffffc0201292 <alloc_pages>
ffffffffc02009aa:	84aa                	mv	s1,a0
ffffffffc02009ac:	5e050463          	beqz	a0,ffffffffc0200f94 <buddy_check+0x69c>
    assert((p2 = alloc_pages(16)) != NULL);
ffffffffc02009b0:	4541                	li	a0,16
ffffffffc02009b2:	0e1000ef          	jal	ra,ffffffffc0201292 <alloc_pages>
ffffffffc02009b6:	892a                	mv	s2,a0
ffffffffc02009b8:	5a050e63          	beqz	a0,ffffffffc0200f74 <buddy_check+0x67c>
    
    assert(p0 + 8 == p1);
ffffffffc02009bc:	14040793          	addi	a5,s0,320
ffffffffc02009c0:	58f49a63          	bne	s1,a5,ffffffffc0200f54 <buddy_check+0x65c>
    assert(p0 + 16 == p2);
ffffffffc02009c4:	28040793          	addi	a5,s0,640
ffffffffc02009c8:	56f51663          	bne	a0,a5,ffffffffc0200f34 <buddy_check+0x63c>
    
    free_pages(p0,4);
ffffffffc02009cc:	4591                	li	a1,4
ffffffffc02009ce:	8522                	mv	a0,s0
ffffffffc02009d0:	101000ef          	jal	ra,ffffffffc02012d0 <free_pages>
    free_pages(p1,8);
ffffffffc02009d4:	8526                	mv	a0,s1
ffffffffc02009d6:	45a1                	li	a1,8
ffffffffc02009d8:	0f9000ef          	jal	ra,ffffffffc02012d0 <free_pages>
    free_pages(p2,16);
ffffffffc02009dc:	45c1                	li	a1,16
ffffffffc02009de:	854a                	mv	a0,s2
ffffffffc02009e0:	0f1000ef          	jal	ra,ffffffffc02012d0 <free_pages>
    
    assert((p0 = alloc_pages(4)) != NULL);
ffffffffc02009e4:	4511                	li	a0,4
ffffffffc02009e6:	0ad000ef          	jal	ra,ffffffffc0201292 <alloc_pages>
ffffffffc02009ea:	84aa                	mv	s1,a0
ffffffffc02009ec:	52050463          	beqz	a0,ffffffffc0200f14 <buddy_check+0x61c>
    assert((p1 = alloc_pages(8)) != NULL);
ffffffffc02009f0:	4521                	li	a0,8
ffffffffc02009f2:	0a1000ef          	jal	ra,ffffffffc0201292 <alloc_pages>
ffffffffc02009f6:	4e050f63          	beqz	a0,ffffffffc0200ef4 <buddy_check+0x5fc>
    assert((p2 = alloc_pages(4)) != NULL);
ffffffffc02009fa:	4511                	li	a0,4
ffffffffc02009fc:	097000ef          	jal	ra,ffffffffc0201292 <alloc_pages>
ffffffffc0200a00:	842a                	mv	s0,a0
ffffffffc0200a02:	6c050963          	beqz	a0,ffffffffc02010d4 <buddy_check+0x7dc>
    
    free_pages(p0,4);
ffffffffc0200a06:	8526                	mv	a0,s1
ffffffffc0200a08:	4591                	li	a1,4
ffffffffc0200a0a:	0c7000ef          	jal	ra,ffffffffc02012d0 <free_pages>
    
    assert((p0 = alloc_pages(8)) != NULL);
ffffffffc0200a0e:	4521                	li	a0,8
ffffffffc0200a10:	083000ef          	jal	ra,ffffffffc0201292 <alloc_pages>
ffffffffc0200a14:	6a050063          	beqz	a0,ffffffffc02010b4 <buddy_check+0x7bc>
    assert(p2 + 12 == p0);
ffffffffc0200a18:	1e040793          	addi	a5,s0,480
ffffffffc0200a1c:	66f51c63          	bne	a0,a5,ffffffffc0201094 <buddy_check+0x79c>
    
    free_pages(p0,8);
ffffffffc0200a20:	45a1                	li	a1,8
ffffffffc0200a22:	0af000ef          	jal	ra,ffffffffc02012d0 <free_pages>
    
    assert((p0 = alloc_pages(4)) != NULL);
ffffffffc0200a26:	4511                	li	a0,4
ffffffffc0200a28:	06b000ef          	jal	ra,ffffffffc0201292 <alloc_pages>
ffffffffc0200a2c:	64050463          	beqz	a0,ffffffffc0201074 <buddy_check+0x77c>
    assert(p2 - 4 == p0);
ffffffffc0200a30:	f6040413          	addi	s0,s0,-160
ffffffffc0200a34:	62851063          	bne	a0,s0,ffffffffc0201054 <buddy_check+0x75c>
    
    free_pages(p0,4);
ffffffffc0200a38:	4591                	li	a1,4
ffffffffc0200a3a:	097000ef          	jal	ra,ffffffffc02012d0 <free_pages>
    
    cprintf("testcase1 finish!\n");
ffffffffc0200a3e:	00002517          	auipc	a0,0x2
ffffffffc0200a42:	8ea50513          	addi	a0,a0,-1814 # ffffffffc0202328 <commands+0x6d8>
ffffffffc0200a46:	e6cff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    
    cprintf("testcase2 begin!\n");
ffffffffc0200a4a:	00002517          	auipc	a0,0x2
ffffffffc0200a4e:	8f650513          	addi	a0,a0,-1802 # ffffffffc0202340 <commands+0x6f0>
ffffffffc0200a52:	e60ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>

    p0 = p1 = p2 = NULL;
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200a56:	4505                	li	a0,1
ffffffffc0200a58:	03b000ef          	jal	ra,ffffffffc0201292 <alloc_pages>
ffffffffc0200a5c:	84aa                	mv	s1,a0
ffffffffc0200a5e:	5c050b63          	beqz	a0,ffffffffc0201034 <buddy_check+0x73c>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200a62:	4505                	li	a0,1
ffffffffc0200a64:	02f000ef          	jal	ra,ffffffffc0201292 <alloc_pages>
ffffffffc0200a68:	892a                	mv	s2,a0
ffffffffc0200a6a:	5a050563          	beqz	a0,ffffffffc0201014 <buddy_check+0x71c>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200a6e:	4505                	li	a0,1
ffffffffc0200a70:	023000ef          	jal	ra,ffffffffc0201292 <alloc_pages>
ffffffffc0200a74:	89aa                	mv	s3,a0
ffffffffc0200a76:	56050f63          	beqz	a0,ffffffffc0200ff4 <buddy_check+0x6fc>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200a7a:	15248d63          	beq	s1,s2,ffffffffc0200bd4 <buddy_check+0x2dc>
ffffffffc0200a7e:	14a48b63          	beq	s1,a0,ffffffffc0200bd4 <buddy_check+0x2dc>
ffffffffc0200a82:	14a90963          	beq	s2,a0,ffffffffc0200bd4 <buddy_check+0x2dc>
    
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200a86:	409c                	lw	a5,0(s1)
ffffffffc0200a88:	16079663          	bnez	a5,ffffffffc0200bf4 <buddy_check+0x2fc>
ffffffffc0200a8c:	00092783          	lw	a5,0(s2)
ffffffffc0200a90:	16079263          	bnez	a5,ffffffffc0200bf4 <buddy_check+0x2fc>
ffffffffc0200a94:	411c                	lw	a5,0(a0)
ffffffffc0200a96:	14079f63          	bnez	a5,ffffffffc0200bf4 <buddy_check+0x2fc>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200a9a:	00006797          	auipc	a5,0x6
ffffffffc0200a9e:	9a67b783          	ld	a5,-1626(a5) # ffffffffc0206440 <pages>
ffffffffc0200aa2:	40f48733          	sub	a4,s1,a5
ffffffffc0200aa6:	870d                	srai	a4,a4,0x3
ffffffffc0200aa8:	00002597          	auipc	a1,0x2
ffffffffc0200aac:	e305b583          	ld	a1,-464(a1) # ffffffffc02028d8 <error_string+0x38>
ffffffffc0200ab0:	02b70733          	mul	a4,a4,a1
ffffffffc0200ab4:	00002617          	auipc	a2,0x2
ffffffffc0200ab8:	e2c63603          	ld	a2,-468(a2) # ffffffffc02028e0 <nbase>

    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200abc:	00006697          	auipc	a3,0x6
ffffffffc0200ac0:	97c6b683          	ld	a3,-1668(a3) # ffffffffc0206438 <npage>
ffffffffc0200ac4:	06b2                	slli	a3,a3,0xc
ffffffffc0200ac6:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200ac8:	0732                	slli	a4,a4,0xc
ffffffffc0200aca:	14d77563          	bgeu	a4,a3,ffffffffc0200c14 <buddy_check+0x31c>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200ace:	40f90733          	sub	a4,s2,a5
ffffffffc0200ad2:	870d                	srai	a4,a4,0x3
ffffffffc0200ad4:	02b70733          	mul	a4,a4,a1
ffffffffc0200ad8:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200ada:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200adc:	16d77c63          	bgeu	a4,a3,ffffffffc0200c54 <buddy_check+0x35c>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200ae0:	40f507b3          	sub	a5,a0,a5
ffffffffc0200ae4:	878d                	srai	a5,a5,0x3
ffffffffc0200ae6:	02b787b3          	mul	a5,a5,a1
ffffffffc0200aea:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200aec:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200aee:	14d7f363          	bgeu	a5,a3,ffffffffc0200c34 <buddy_check+0x33c>

    list_entry_t free_list_store = free_list;
ffffffffc0200af2:	00005417          	auipc	s0,0x5
ffffffffc0200af6:	51e40413          	addi	s0,s0,1310 # ffffffffc0206010 <free_area>
ffffffffc0200afa:	00043b03          	ld	s6,0(s0)
ffffffffc0200afe:	00843a83          	ld	s5,8(s0)
    assert(list_empty(&free_list));

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    assert(alloc_page() == NULL);
ffffffffc0200b02:	4505                	li	a0,1
    elm->prev = elm->next = elm;
ffffffffc0200b04:	e400                	sd	s0,8(s0)
ffffffffc0200b06:	e000                	sd	s0,0(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0200b08:	01042a03          	lw	s4,16(s0)
    nr_free = 0;
ffffffffc0200b0c:	00005797          	auipc	a5,0x5
ffffffffc0200b10:	5007aa23          	sw	zero,1300(a5) # ffffffffc0206020 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200b14:	77e000ef          	jal	ra,ffffffffc0201292 <alloc_pages>
ffffffffc0200b18:	1a051e63          	bnez	a0,ffffffffc0200cd4 <buddy_check+0x3dc>

    free_page(p0);
ffffffffc0200b1c:	4585                	li	a1,1
ffffffffc0200b1e:	8526                	mv	a0,s1
ffffffffc0200b20:	7b0000ef          	jal	ra,ffffffffc02012d0 <free_pages>
    free_page(p1);
ffffffffc0200b24:	4585                	li	a1,1
ffffffffc0200b26:	854a                	mv	a0,s2
ffffffffc0200b28:	7a8000ef          	jal	ra,ffffffffc02012d0 <free_pages>
    free_page(p2);
ffffffffc0200b2c:	4585                	li	a1,1
ffffffffc0200b2e:	854e                	mv	a0,s3
ffffffffc0200b30:	7a0000ef          	jal	ra,ffffffffc02012d0 <free_pages>
    assert(nr_free == 3);
ffffffffc0200b34:	4818                	lw	a4,16(s0)
ffffffffc0200b36:	478d                	li	a5,3
ffffffffc0200b38:	16f71e63          	bne	a4,a5,ffffffffc0200cb4 <buddy_check+0x3bc>

    assert((p0 = alloc_page()) != NULL);
ffffffffc0200b3c:	4505                	li	a0,1
ffffffffc0200b3e:	754000ef          	jal	ra,ffffffffc0201292 <alloc_pages>
ffffffffc0200b42:	84aa                	mv	s1,a0
ffffffffc0200b44:	14050863          	beqz	a0,ffffffffc0200c94 <buddy_check+0x39c>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200b48:	4505                	li	a0,1
ffffffffc0200b4a:	748000ef          	jal	ra,ffffffffc0201292 <alloc_pages>
ffffffffc0200b4e:	89aa                	mv	s3,a0
ffffffffc0200b50:	12050263          	beqz	a0,ffffffffc0200c74 <buddy_check+0x37c>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200b54:	4505                	li	a0,1
ffffffffc0200b56:	73c000ef          	jal	ra,ffffffffc0201292 <alloc_pages>
ffffffffc0200b5a:	892a                	mv	s2,a0
ffffffffc0200b5c:	26050c63          	beqz	a0,ffffffffc0200dd4 <buddy_check+0x4dc>


    assert(alloc_page() == NULL);
ffffffffc0200b60:	4505                	li	a0,1
ffffffffc0200b62:	730000ef          	jal	ra,ffffffffc0201292 <alloc_pages>
ffffffffc0200b66:	24051763          	bnez	a0,ffffffffc0200db4 <buddy_check+0x4bc>

    free_page(p0);
ffffffffc0200b6a:	4585                	li	a1,1
ffffffffc0200b6c:	8526                	mv	a0,s1
ffffffffc0200b6e:	762000ef          	jal	ra,ffffffffc02012d0 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200b72:	641c                	ld	a5,8(s0)
ffffffffc0200b74:	22878063          	beq	a5,s0,ffffffffc0200d94 <buddy_check+0x49c>

    struct Page *p;
    assert((p = alloc_page()) == p0);
ffffffffc0200b78:	4505                	li	a0,1
ffffffffc0200b7a:	718000ef          	jal	ra,ffffffffc0201292 <alloc_pages>
ffffffffc0200b7e:	1ea49b63          	bne	s1,a0,ffffffffc0200d74 <buddy_check+0x47c>
    assert(alloc_page() == NULL);
ffffffffc0200b82:	4505                	li	a0,1
ffffffffc0200b84:	70e000ef          	jal	ra,ffffffffc0201292 <alloc_pages>
ffffffffc0200b88:	1c051663          	bnez	a0,ffffffffc0200d54 <buddy_check+0x45c>

    assert(nr_free == 0);
ffffffffc0200b8c:	481c                	lw	a5,16(s0)
ffffffffc0200b8e:	1a079363          	bnez	a5,ffffffffc0200d34 <buddy_check+0x43c>
    free_list = free_list_store;
    nr_free = nr_free_store;

    free_page(p0);
ffffffffc0200b92:	8526                	mv	a0,s1
ffffffffc0200b94:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200b96:	01643023          	sd	s6,0(s0)
ffffffffc0200b9a:	01543423          	sd	s5,8(s0)
    nr_free = nr_free_store;
ffffffffc0200b9e:	01442823          	sw	s4,16(s0)
    free_page(p0);
ffffffffc0200ba2:	72e000ef          	jal	ra,ffffffffc02012d0 <free_pages>
    free_page(p1);
ffffffffc0200ba6:	854e                	mv	a0,s3
ffffffffc0200ba8:	4585                	li	a1,1
ffffffffc0200baa:	726000ef          	jal	ra,ffffffffc02012d0 <free_pages>
    free_page(p2);
ffffffffc0200bae:	854a                	mv	a0,s2
ffffffffc0200bb0:	4585                	li	a1,1
ffffffffc0200bb2:	71e000ef          	jal	ra,ffffffffc02012d0 <free_pages>
    
    cprintf("testcase2 finish!\n");
}
ffffffffc0200bb6:	7442                	ld	s0,48(sp)
ffffffffc0200bb8:	70e2                	ld	ra,56(sp)
ffffffffc0200bba:	74a2                	ld	s1,40(sp)
ffffffffc0200bbc:	7902                	ld	s2,32(sp)
ffffffffc0200bbe:	69e2                	ld	s3,24(sp)
ffffffffc0200bc0:	6a42                	ld	s4,16(sp)
ffffffffc0200bc2:	6aa2                	ld	s5,8(sp)
ffffffffc0200bc4:	6b02                	ld	s6,0(sp)
    cprintf("testcase2 finish!\n");
ffffffffc0200bc6:	00002517          	auipc	a0,0x2
ffffffffc0200bca:	92a50513          	addi	a0,a0,-1750 # ffffffffc02024f0 <commands+0x8a0>
}
ffffffffc0200bce:	6121                	addi	sp,sp,64
    cprintf("testcase2 finish!\n");
ffffffffc0200bd0:	ce2ff06f          	j	ffffffffc02000b2 <cprintf>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200bd4:	00001697          	auipc	a3,0x1
ffffffffc0200bd8:	7e468693          	addi	a3,a3,2020 # ffffffffc02023b8 <commands+0x768>
ffffffffc0200bdc:	00001617          	auipc	a2,0x1
ffffffffc0200be0:	57460613          	addi	a2,a2,1396 # ffffffffc0202150 <commands+0x500>
ffffffffc0200be4:	0b800593          	li	a1,184
ffffffffc0200be8:	00001517          	auipc	a0,0x1
ffffffffc0200bec:	58050513          	addi	a0,a0,1408 # ffffffffc0202168 <commands+0x518>
ffffffffc0200bf0:	fbcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200bf4:	00001697          	auipc	a3,0x1
ffffffffc0200bf8:	7ec68693          	addi	a3,a3,2028 # ffffffffc02023e0 <commands+0x790>
ffffffffc0200bfc:	00001617          	auipc	a2,0x1
ffffffffc0200c00:	55460613          	addi	a2,a2,1364 # ffffffffc0202150 <commands+0x500>
ffffffffc0200c04:	0ba00593          	li	a1,186
ffffffffc0200c08:	00001517          	auipc	a0,0x1
ffffffffc0200c0c:	56050513          	addi	a0,a0,1376 # ffffffffc0202168 <commands+0x518>
ffffffffc0200c10:	f9cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200c14:	00002697          	auipc	a3,0x2
ffffffffc0200c18:	80c68693          	addi	a3,a3,-2036 # ffffffffc0202420 <commands+0x7d0>
ffffffffc0200c1c:	00001617          	auipc	a2,0x1
ffffffffc0200c20:	53460613          	addi	a2,a2,1332 # ffffffffc0202150 <commands+0x500>
ffffffffc0200c24:	0bc00593          	li	a1,188
ffffffffc0200c28:	00001517          	auipc	a0,0x1
ffffffffc0200c2c:	54050513          	addi	a0,a0,1344 # ffffffffc0202168 <commands+0x518>
ffffffffc0200c30:	f7cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200c34:	00002697          	auipc	a3,0x2
ffffffffc0200c38:	82c68693          	addi	a3,a3,-2004 # ffffffffc0202460 <commands+0x810>
ffffffffc0200c3c:	00001617          	auipc	a2,0x1
ffffffffc0200c40:	51460613          	addi	a2,a2,1300 # ffffffffc0202150 <commands+0x500>
ffffffffc0200c44:	0be00593          	li	a1,190
ffffffffc0200c48:	00001517          	auipc	a0,0x1
ffffffffc0200c4c:	52050513          	addi	a0,a0,1312 # ffffffffc0202168 <commands+0x518>
ffffffffc0200c50:	f5cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200c54:	00001697          	auipc	a3,0x1
ffffffffc0200c58:	7ec68693          	addi	a3,a3,2028 # ffffffffc0202440 <commands+0x7f0>
ffffffffc0200c5c:	00001617          	auipc	a2,0x1
ffffffffc0200c60:	4f460613          	addi	a2,a2,1268 # ffffffffc0202150 <commands+0x500>
ffffffffc0200c64:	0bd00593          	li	a1,189
ffffffffc0200c68:	00001517          	auipc	a0,0x1
ffffffffc0200c6c:	50050513          	addi	a0,a0,1280 # ffffffffc0202168 <commands+0x518>
ffffffffc0200c70:	f3cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c74:	00001697          	auipc	a3,0x1
ffffffffc0200c78:	70468693          	addi	a3,a3,1796 # ffffffffc0202378 <commands+0x728>
ffffffffc0200c7c:	00001617          	auipc	a2,0x1
ffffffffc0200c80:	4d460613          	addi	a2,a2,1236 # ffffffffc0202150 <commands+0x500>
ffffffffc0200c84:	0cf00593          	li	a1,207
ffffffffc0200c88:	00001517          	auipc	a0,0x1
ffffffffc0200c8c:	4e050513          	addi	a0,a0,1248 # ffffffffc0202168 <commands+0x518>
ffffffffc0200c90:	f1cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200c94:	00001697          	auipc	a3,0x1
ffffffffc0200c98:	6c468693          	addi	a3,a3,1732 # ffffffffc0202358 <commands+0x708>
ffffffffc0200c9c:	00001617          	auipc	a2,0x1
ffffffffc0200ca0:	4b460613          	addi	a2,a2,1204 # ffffffffc0202150 <commands+0x500>
ffffffffc0200ca4:	0ce00593          	li	a1,206
ffffffffc0200ca8:	00001517          	auipc	a0,0x1
ffffffffc0200cac:	4c050513          	addi	a0,a0,1216 # ffffffffc0202168 <commands+0x518>
ffffffffc0200cb0:	efcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 3);
ffffffffc0200cb4:	00001697          	auipc	a3,0x1
ffffffffc0200cb8:	7e468693          	addi	a3,a3,2020 # ffffffffc0202498 <commands+0x848>
ffffffffc0200cbc:	00001617          	auipc	a2,0x1
ffffffffc0200cc0:	49460613          	addi	a2,a2,1172 # ffffffffc0202150 <commands+0x500>
ffffffffc0200cc4:	0cc00593          	li	a1,204
ffffffffc0200cc8:	00001517          	auipc	a0,0x1
ffffffffc0200ccc:	4a050513          	addi	a0,a0,1184 # ffffffffc0202168 <commands+0x518>
ffffffffc0200cd0:	edcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200cd4:	00001697          	auipc	a3,0x1
ffffffffc0200cd8:	7ac68693          	addi	a3,a3,1964 # ffffffffc0202480 <commands+0x830>
ffffffffc0200cdc:	00001617          	auipc	a2,0x1
ffffffffc0200ce0:	47460613          	addi	a2,a2,1140 # ffffffffc0202150 <commands+0x500>
ffffffffc0200ce4:	0c700593          	li	a1,199
ffffffffc0200ce8:	00001517          	auipc	a0,0x1
ffffffffc0200cec:	48050513          	addi	a0,a0,1152 # ffffffffc0202168 <commands+0x518>
ffffffffc0200cf0:	ebcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_pages(4)) != NULL);
ffffffffc0200cf4:	00001697          	auipc	a3,0x1
ffffffffc0200cf8:	4c468693          	addi	a3,a3,1220 # ffffffffc02021b8 <commands+0x568>
ffffffffc0200cfc:	00001617          	auipc	a2,0x1
ffffffffc0200d00:	45460613          	addi	a2,a2,1108 # ffffffffc0202150 <commands+0x500>
ffffffffc0200d04:	08100593          	li	a1,129
ffffffffc0200d08:	00001517          	auipc	a0,0x1
ffffffffc0200d0c:	46050513          	addi	a0,a0,1120 # ffffffffc0202168 <commands+0x518>
ffffffffc0200d10:	e9cff0ef          	jal	ra,ffffffffc02003ac <__panic>
	assert((p0 = alloc_pages(2)) != NULL);
ffffffffc0200d14:	00001697          	auipc	a3,0x1
ffffffffc0200d18:	48468693          	addi	a3,a3,1156 # ffffffffc0202198 <commands+0x548>
ffffffffc0200d1c:	00001617          	auipc	a2,0x1
ffffffffc0200d20:	43460613          	addi	a2,a2,1076 # ffffffffc0202150 <commands+0x500>
ffffffffc0200d24:	08000593          	li	a1,128
ffffffffc0200d28:	00001517          	auipc	a0,0x1
ffffffffc0200d2c:	44050513          	addi	a0,a0,1088 # ffffffffc0202168 <commands+0x518>
ffffffffc0200d30:	e7cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(nr_free == 0);
ffffffffc0200d34:	00001697          	auipc	a3,0x1
ffffffffc0200d38:	7ac68693          	addi	a3,a3,1964 # ffffffffc02024e0 <commands+0x890>
ffffffffc0200d3c:	00001617          	auipc	a2,0x1
ffffffffc0200d40:	41460613          	addi	a2,a2,1044 # ffffffffc0202150 <commands+0x500>
ffffffffc0200d44:	0dc00593          	li	a1,220
ffffffffc0200d48:	00001517          	auipc	a0,0x1
ffffffffc0200d4c:	42050513          	addi	a0,a0,1056 # ffffffffc0202168 <commands+0x518>
ffffffffc0200d50:	e5cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200d54:	00001697          	auipc	a3,0x1
ffffffffc0200d58:	72c68693          	addi	a3,a3,1836 # ffffffffc0202480 <commands+0x830>
ffffffffc0200d5c:	00001617          	auipc	a2,0x1
ffffffffc0200d60:	3f460613          	addi	a2,a2,1012 # ffffffffc0202150 <commands+0x500>
ffffffffc0200d64:	0da00593          	li	a1,218
ffffffffc0200d68:	00001517          	auipc	a0,0x1
ffffffffc0200d6c:	40050513          	addi	a0,a0,1024 # ffffffffc0202168 <commands+0x518>
ffffffffc0200d70:	e3cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200d74:	00001697          	auipc	a3,0x1
ffffffffc0200d78:	74c68693          	addi	a3,a3,1868 # ffffffffc02024c0 <commands+0x870>
ffffffffc0200d7c:	00001617          	auipc	a2,0x1
ffffffffc0200d80:	3d460613          	addi	a2,a2,980 # ffffffffc0202150 <commands+0x500>
ffffffffc0200d84:	0d900593          	li	a1,217
ffffffffc0200d88:	00001517          	auipc	a0,0x1
ffffffffc0200d8c:	3e050513          	addi	a0,a0,992 # ffffffffc0202168 <commands+0x518>
ffffffffc0200d90:	e1cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200d94:	00001697          	auipc	a3,0x1
ffffffffc0200d98:	71468693          	addi	a3,a3,1812 # ffffffffc02024a8 <commands+0x858>
ffffffffc0200d9c:	00001617          	auipc	a2,0x1
ffffffffc0200da0:	3b460613          	addi	a2,a2,948 # ffffffffc0202150 <commands+0x500>
ffffffffc0200da4:	0d600593          	li	a1,214
ffffffffc0200da8:	00001517          	auipc	a0,0x1
ffffffffc0200dac:	3c050513          	addi	a0,a0,960 # ffffffffc0202168 <commands+0x518>
ffffffffc0200db0:	dfcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200db4:	00001697          	auipc	a3,0x1
ffffffffc0200db8:	6cc68693          	addi	a3,a3,1740 # ffffffffc0202480 <commands+0x830>
ffffffffc0200dbc:	00001617          	auipc	a2,0x1
ffffffffc0200dc0:	39460613          	addi	a2,a2,916 # ffffffffc0202150 <commands+0x500>
ffffffffc0200dc4:	0d300593          	li	a1,211
ffffffffc0200dc8:	00001517          	auipc	a0,0x1
ffffffffc0200dcc:	3a050513          	addi	a0,a0,928 # ffffffffc0202168 <commands+0x518>
ffffffffc0200dd0:	ddcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200dd4:	00001697          	auipc	a3,0x1
ffffffffc0200dd8:	5c468693          	addi	a3,a3,1476 # ffffffffc0202398 <commands+0x748>
ffffffffc0200ddc:	00001617          	auipc	a2,0x1
ffffffffc0200de0:	37460613          	addi	a2,a2,884 # ffffffffc0202150 <commands+0x500>
ffffffffc0200de4:	0d000593          	li	a1,208
ffffffffc0200de8:	00001517          	auipc	a0,0x1
ffffffffc0200dec:	38050513          	addi	a0,a0,896 # ffffffffc0202168 <commands+0x518>
ffffffffc0200df0:	dbcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 + 2 == p2);
ffffffffc0200df4:	00001697          	auipc	a3,0x1
ffffffffc0200df8:	41468693          	addi	a3,a3,1044 # ffffffffc0202208 <commands+0x5b8>
ffffffffc0200dfc:	00001617          	auipc	a2,0x1
ffffffffc0200e00:	35460613          	addi	a2,a2,852 # ffffffffc0202150 <commands+0x500>
ffffffffc0200e04:	08f00593          	li	a1,143
ffffffffc0200e08:	00001517          	auipc	a0,0x1
ffffffffc0200e0c:	36050513          	addi	a0,a0,864 # ffffffffc0202168 <commands+0x518>
ffffffffc0200e10:	d9cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 + 4 == p1);
ffffffffc0200e14:	00001697          	auipc	a3,0x1
ffffffffc0200e18:	3e468693          	addi	a3,a3,996 # ffffffffc02021f8 <commands+0x5a8>
ffffffffc0200e1c:	00001617          	auipc	a2,0x1
ffffffffc0200e20:	33460613          	addi	a2,a2,820 # ffffffffc0202150 <commands+0x500>
ffffffffc0200e24:	08e00593          	li	a1,142
ffffffffc0200e28:	00001517          	auipc	a0,0x1
ffffffffc0200e2c:	34050513          	addi	a0,a0,832 # ffffffffc0202168 <commands+0x518>
ffffffffc0200e30:	d7cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p3 = alloc_pages(2)) != NULL);
ffffffffc0200e34:	00001697          	auipc	a3,0x1
ffffffffc0200e38:	3e468693          	addi	a3,a3,996 # ffffffffc0202218 <commands+0x5c8>
ffffffffc0200e3c:	00001617          	auipc	a2,0x1
ffffffffc0200e40:	31460613          	addi	a2,a2,788 # ffffffffc0202150 <commands+0x500>
ffffffffc0200e44:	08c00593          	li	a1,140
ffffffffc0200e48:	00001517          	auipc	a0,0x1
ffffffffc0200e4c:	32050513          	addi	a0,a0,800 # ffffffffc0202168 <commands+0x518>
ffffffffc0200e50:	d5cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_pages(4)) != NULL);
ffffffffc0200e54:	00001697          	auipc	a3,0x1
ffffffffc0200e58:	36468693          	addi	a3,a3,868 # ffffffffc02021b8 <commands+0x568>
ffffffffc0200e5c:	00001617          	auipc	a2,0x1
ffffffffc0200e60:	2f460613          	addi	a2,a2,756 # ffffffffc0202150 <commands+0x500>
ffffffffc0200e64:	08b00593          	li	a1,139
ffffffffc0200e68:	00001517          	auipc	a0,0x1
ffffffffc0200e6c:	30050513          	addi	a0,a0,768 # ffffffffc0202168 <commands+0x518>
ffffffffc0200e70:	d3cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_pages(2)) != NULL);
ffffffffc0200e74:	00001697          	auipc	a3,0x1
ffffffffc0200e78:	32468693          	addi	a3,a3,804 # ffffffffc0202198 <commands+0x548>
ffffffffc0200e7c:	00001617          	auipc	a2,0x1
ffffffffc0200e80:	2d460613          	addi	a2,a2,724 # ffffffffc0202150 <commands+0x500>
ffffffffc0200e84:	08a00593          	li	a1,138
ffffffffc0200e88:	00001517          	auipc	a0,0x1
ffffffffc0200e8c:	2e050513          	addi	a0,a0,736 # ffffffffc0202168 <commands+0x518>
ffffffffc0200e90:	d1cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 + 2 == p2);
ffffffffc0200e94:	00001697          	auipc	a3,0x1
ffffffffc0200e98:	37468693          	addi	a3,a3,884 # ffffffffc0202208 <commands+0x5b8>
ffffffffc0200e9c:	00001617          	auipc	a2,0x1
ffffffffc0200ea0:	2b460613          	addi	a2,a2,692 # ffffffffc0202150 <commands+0x500>
ffffffffc0200ea4:	08500593          	li	a1,133
ffffffffc0200ea8:	00001517          	auipc	a0,0x1
ffffffffc0200eac:	2c050513          	addi	a0,a0,704 # ffffffffc0202168 <commands+0x518>
ffffffffc0200eb0:	cfcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 + 4 == p1);
ffffffffc0200eb4:	00001697          	auipc	a3,0x1
ffffffffc0200eb8:	34468693          	addi	a3,a3,836 # ffffffffc02021f8 <commands+0x5a8>
ffffffffc0200ebc:	00001617          	auipc	a2,0x1
ffffffffc0200ec0:	29460613          	addi	a2,a2,660 # ffffffffc0202150 <commands+0x500>
ffffffffc0200ec4:	08400593          	li	a1,132
ffffffffc0200ec8:	00001517          	auipc	a0,0x1
ffffffffc0200ecc:	2a050513          	addi	a0,a0,672 # ffffffffc0202168 <commands+0x518>
ffffffffc0200ed0:	cdcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_pages(2)) != NULL);
ffffffffc0200ed4:	00001697          	auipc	a3,0x1
ffffffffc0200ed8:	30468693          	addi	a3,a3,772 # ffffffffc02021d8 <commands+0x588>
ffffffffc0200edc:	00001617          	auipc	a2,0x1
ffffffffc0200ee0:	27460613          	addi	a2,a2,628 # ffffffffc0202150 <commands+0x500>
ffffffffc0200ee4:	08200593          	li	a1,130
ffffffffc0200ee8:	00001517          	auipc	a0,0x1
ffffffffc0200eec:	28050513          	addi	a0,a0,640 # ffffffffc0202168 <commands+0x518>
ffffffffc0200ef0:	cbcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_pages(8)) != NULL);
ffffffffc0200ef4:	00001697          	auipc	a3,0x1
ffffffffc0200ef8:	37468693          	addi	a3,a3,884 # ffffffffc0202268 <commands+0x618>
ffffffffc0200efc:	00001617          	auipc	a2,0x1
ffffffffc0200f00:	25460613          	addi	a2,a2,596 # ffffffffc0202150 <commands+0x500>
ffffffffc0200f04:	0a000593          	li	a1,160
ffffffffc0200f08:	00001517          	auipc	a0,0x1
ffffffffc0200f0c:	26050513          	addi	a0,a0,608 # ffffffffc0202168 <commands+0x518>
ffffffffc0200f10:	c9cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_pages(4)) != NULL);
ffffffffc0200f14:	00001697          	auipc	a3,0x1
ffffffffc0200f18:	33468693          	addi	a3,a3,820 # ffffffffc0202248 <commands+0x5f8>
ffffffffc0200f1c:	00001617          	auipc	a2,0x1
ffffffffc0200f20:	23460613          	addi	a2,a2,564 # ffffffffc0202150 <commands+0x500>
ffffffffc0200f24:	09f00593          	li	a1,159
ffffffffc0200f28:	00001517          	auipc	a0,0x1
ffffffffc0200f2c:	24050513          	addi	a0,a0,576 # ffffffffc0202168 <commands+0x518>
ffffffffc0200f30:	c7cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 + 16 == p2);
ffffffffc0200f34:	00001697          	auipc	a3,0x1
ffffffffc0200f38:	38468693          	addi	a3,a3,900 # ffffffffc02022b8 <commands+0x668>
ffffffffc0200f3c:	00001617          	auipc	a2,0x1
ffffffffc0200f40:	21460613          	addi	a2,a2,532 # ffffffffc0202150 <commands+0x500>
ffffffffc0200f44:	09900593          	li	a1,153
ffffffffc0200f48:	00001517          	auipc	a0,0x1
ffffffffc0200f4c:	22050513          	addi	a0,a0,544 # ffffffffc0202168 <commands+0x518>
ffffffffc0200f50:	c5cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p0 + 8 == p1);
ffffffffc0200f54:	00001697          	auipc	a3,0x1
ffffffffc0200f58:	35468693          	addi	a3,a3,852 # ffffffffc02022a8 <commands+0x658>
ffffffffc0200f5c:	00001617          	auipc	a2,0x1
ffffffffc0200f60:	1f460613          	addi	a2,a2,500 # ffffffffc0202150 <commands+0x500>
ffffffffc0200f64:	09800593          	li	a1,152
ffffffffc0200f68:	00001517          	auipc	a0,0x1
ffffffffc0200f6c:	20050513          	addi	a0,a0,512 # ffffffffc0202168 <commands+0x518>
ffffffffc0200f70:	c3cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_pages(16)) != NULL);
ffffffffc0200f74:	00001697          	auipc	a3,0x1
ffffffffc0200f78:	31468693          	addi	a3,a3,788 # ffffffffc0202288 <commands+0x638>
ffffffffc0200f7c:	00001617          	auipc	a2,0x1
ffffffffc0200f80:	1d460613          	addi	a2,a2,468 # ffffffffc0202150 <commands+0x500>
ffffffffc0200f84:	09600593          	li	a1,150
ffffffffc0200f88:	00001517          	auipc	a0,0x1
ffffffffc0200f8c:	1e050513          	addi	a0,a0,480 # ffffffffc0202168 <commands+0x518>
ffffffffc0200f90:	c1cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_pages(8)) != NULL);
ffffffffc0200f94:	00001697          	auipc	a3,0x1
ffffffffc0200f98:	2d468693          	addi	a3,a3,724 # ffffffffc0202268 <commands+0x618>
ffffffffc0200f9c:	00001617          	auipc	a2,0x1
ffffffffc0200fa0:	1b460613          	addi	a2,a2,436 # ffffffffc0202150 <commands+0x500>
ffffffffc0200fa4:	09500593          	li	a1,149
ffffffffc0200fa8:	00001517          	auipc	a0,0x1
ffffffffc0200fac:	1c050513          	addi	a0,a0,448 # ffffffffc0202168 <commands+0x518>
ffffffffc0200fb0:	bfcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_pages(4)) != NULL);
ffffffffc0200fb4:	00001697          	auipc	a3,0x1
ffffffffc0200fb8:	29468693          	addi	a3,a3,660 # ffffffffc0202248 <commands+0x5f8>
ffffffffc0200fbc:	00001617          	auipc	a2,0x1
ffffffffc0200fc0:	19460613          	addi	a2,a2,404 # ffffffffc0202150 <commands+0x500>
ffffffffc0200fc4:	09400593          	li	a1,148
ffffffffc0200fc8:	00001517          	auipc	a0,0x1
ffffffffc0200fcc:	1a050513          	addi	a0,a0,416 # ffffffffc0202168 <commands+0x518>
ffffffffc0200fd0:	bdcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p2 == p3);
ffffffffc0200fd4:	00001697          	auipc	a3,0x1
ffffffffc0200fd8:	26468693          	addi	a3,a3,612 # ffffffffc0202238 <commands+0x5e8>
ffffffffc0200fdc:	00001617          	auipc	a2,0x1
ffffffffc0200fe0:	17460613          	addi	a2,a2,372 # ffffffffc0202150 <commands+0x500>
ffffffffc0200fe4:	09000593          	li	a1,144
ffffffffc0200fe8:	00001517          	auipc	a0,0x1
ffffffffc0200fec:	18050513          	addi	a0,a0,384 # ffffffffc0202168 <commands+0x518>
ffffffffc0200ff0:	bbcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200ff4:	00001697          	auipc	a3,0x1
ffffffffc0200ff8:	3a468693          	addi	a3,a3,932 # ffffffffc0202398 <commands+0x748>
ffffffffc0200ffc:	00001617          	auipc	a2,0x1
ffffffffc0201000:	15460613          	addi	a2,a2,340 # ffffffffc0202150 <commands+0x500>
ffffffffc0201004:	0b600593          	li	a1,182
ffffffffc0201008:	00001517          	auipc	a0,0x1
ffffffffc020100c:	16050513          	addi	a0,a0,352 # ffffffffc0202168 <commands+0x518>
ffffffffc0201010:	b9cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201014:	00001697          	auipc	a3,0x1
ffffffffc0201018:	36468693          	addi	a3,a3,868 # ffffffffc0202378 <commands+0x728>
ffffffffc020101c:	00001617          	auipc	a2,0x1
ffffffffc0201020:	13460613          	addi	a2,a2,308 # ffffffffc0202150 <commands+0x500>
ffffffffc0201024:	0b500593          	li	a1,181
ffffffffc0201028:	00001517          	auipc	a0,0x1
ffffffffc020102c:	14050513          	addi	a0,a0,320 # ffffffffc0202168 <commands+0x518>
ffffffffc0201030:	b7cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201034:	00001697          	auipc	a3,0x1
ffffffffc0201038:	32468693          	addi	a3,a3,804 # ffffffffc0202358 <commands+0x708>
ffffffffc020103c:	00001617          	auipc	a2,0x1
ffffffffc0201040:	11460613          	addi	a2,a2,276 # ffffffffc0202150 <commands+0x500>
ffffffffc0201044:	0b400593          	li	a1,180
ffffffffc0201048:	00001517          	auipc	a0,0x1
ffffffffc020104c:	12050513          	addi	a0,a0,288 # ffffffffc0202168 <commands+0x518>
ffffffffc0201050:	b5cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p2 - 4 == p0);
ffffffffc0201054:	00001697          	auipc	a3,0x1
ffffffffc0201058:	2c468693          	addi	a3,a3,708 # ffffffffc0202318 <commands+0x6c8>
ffffffffc020105c:	00001617          	auipc	a2,0x1
ffffffffc0201060:	0f460613          	addi	a2,a2,244 # ffffffffc0202150 <commands+0x500>
ffffffffc0201064:	0ab00593          	li	a1,171
ffffffffc0201068:	00001517          	auipc	a0,0x1
ffffffffc020106c:	10050513          	addi	a0,a0,256 # ffffffffc0202168 <commands+0x518>
ffffffffc0201070:	b3cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_pages(4)) != NULL);
ffffffffc0201074:	00001697          	auipc	a3,0x1
ffffffffc0201078:	1d468693          	addi	a3,a3,468 # ffffffffc0202248 <commands+0x5f8>
ffffffffc020107c:	00001617          	auipc	a2,0x1
ffffffffc0201080:	0d460613          	addi	a2,a2,212 # ffffffffc0202150 <commands+0x500>
ffffffffc0201084:	0aa00593          	li	a1,170
ffffffffc0201088:	00001517          	auipc	a0,0x1
ffffffffc020108c:	0e050513          	addi	a0,a0,224 # ffffffffc0202168 <commands+0x518>
ffffffffc0201090:	b1cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(p2 + 12 == p0);
ffffffffc0201094:	00001697          	auipc	a3,0x1
ffffffffc0201098:	27468693          	addi	a3,a3,628 # ffffffffc0202308 <commands+0x6b8>
ffffffffc020109c:	00001617          	auipc	a2,0x1
ffffffffc02010a0:	0b460613          	addi	a2,a2,180 # ffffffffc0202150 <commands+0x500>
ffffffffc02010a4:	0a600593          	li	a1,166
ffffffffc02010a8:	00001517          	auipc	a0,0x1
ffffffffc02010ac:	0c050513          	addi	a0,a0,192 # ffffffffc0202168 <commands+0x518>
ffffffffc02010b0:	afcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_pages(8)) != NULL);
ffffffffc02010b4:	00001697          	auipc	a3,0x1
ffffffffc02010b8:	23468693          	addi	a3,a3,564 # ffffffffc02022e8 <commands+0x698>
ffffffffc02010bc:	00001617          	auipc	a2,0x1
ffffffffc02010c0:	09460613          	addi	a2,a2,148 # ffffffffc0202150 <commands+0x500>
ffffffffc02010c4:	0a500593          	li	a1,165
ffffffffc02010c8:	00001517          	auipc	a0,0x1
ffffffffc02010cc:	0a050513          	addi	a0,a0,160 # ffffffffc0202168 <commands+0x518>
ffffffffc02010d0:	adcff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_pages(4)) != NULL);
ffffffffc02010d4:	00001697          	auipc	a3,0x1
ffffffffc02010d8:	1f468693          	addi	a3,a3,500 # ffffffffc02022c8 <commands+0x678>
ffffffffc02010dc:	00001617          	auipc	a2,0x1
ffffffffc02010e0:	07460613          	addi	a2,a2,116 # ffffffffc0202150 <commands+0x500>
ffffffffc02010e4:	0a100593          	li	a1,161
ffffffffc02010e8:	00001517          	auipc	a0,0x1
ffffffffc02010ec:	08050513          	addi	a0,a0,128 # ffffffffc0202168 <commands+0x518>
ffffffffc02010f0:	abcff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02010f4 <buddy_free_pages>:
buddy_free_pages(struct Page *base, size_t n) {
ffffffffc02010f4:	1101                	addi	sp,sp,-32
ffffffffc02010f6:	ec06                	sd	ra,24(sp)
ffffffffc02010f8:	e822                	sd	s0,16(sp)
ffffffffc02010fa:	e426                	sd	s1,8(sp)
    assert(n > 0);
ffffffffc02010fc:	cdd5                	beqz	a1,ffffffffc02011b8 <buddy_free_pages+0xc4>
    __list_add(elm, listelm, listelm->next);
ffffffffc02010fe:	00005817          	auipc	a6,0x5
ffffffffc0201102:	f1280813          	addi	a6,a6,-238 # ffffffffc0206010 <free_area>
ffffffffc0201106:	01082783          	lw	a5,16(a6)
ffffffffc020110a:	00259293          	slli	t0,a1,0x2
ffffffffc020110e:	92ae                	add	t0,t0,a1
ffffffffc0201110:	00883e03          	ld	t3,8(a6)
ffffffffc0201114:	00178f9b          	addiw	t6,a5,1
ffffffffc0201118:	028e                	slli	t0,t0,0x3
ffffffffc020111a:	842e                	mv	s0,a1
ffffffffc020111c:	84fe                	mv	s1,t6
ffffffffc020111e:	8f2a                	mv	t5,a0
ffffffffc0201120:	92aa                	add	t0,t0,a0
    	while ((order<<1) < nr_free) {
ffffffffc0201122:	4389                	li	t2,2
ffffffffc0201124:	020f9e93          	slli	t4,t6,0x20
ffffffffc0201128:	020ede93          	srli	t4,t4,0x20
    	struct Page *p = base+i;
ffffffffc020112c:	88fa                	mv	a7,t5
    	while ((order<<1) < nr_free) {
ffffffffc020112e:	4309                	li	t1,2
    	size_t order=1;
ffffffffc0201130:	4505                	li	a0,1
    	while ((order<<1) < nr_free) {
ffffffffc0201132:	03d3f263          	bgeu	t2,t4,ffffffffc0201156 <buddy_free_pages+0x62>
ffffffffc0201136:	87f2                	mv	a5,t3
    	    while ((le = list_next(le)) != &free_list) {
ffffffffc0201138:	01078e63          	beq	a5,a6,ffffffffc0201154 <buddy_free_pages+0x60>
        		if (q->flags == (p->flags ^ (order))) {
ffffffffc020113c:	0088b683          	ld	a3,8(a7)
ffffffffc0201140:	ff07b603          	ld	a2,-16(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201144:	6798                	ld	a4,8(a5)
ffffffffc0201146:	00a6c5b3          	xor	a1,a3,a0
ffffffffc020114a:	02b60963          	beq	a2,a1,ffffffffc020117c <buddy_free_pages+0x88>
ffffffffc020114e:	87ba                	mv	a5,a4
    	    while ((le = list_next(le)) != &free_list) {
ffffffffc0201150:	ff0796e3          	bne	a5,a6,ffffffffc020113c <buddy_free_pages+0x48>
   	 	p->property=order;
ffffffffc0201154:	2501                	sext.w	a0,a0
    	list_add(&free_list, &(p->page_link));
ffffffffc0201156:	01888793          	addi	a5,a7,24
   	 	p->property=order;
ffffffffc020115a:	00a8a823          	sw	a0,16(a7)
    prev->next = next->prev = elm;
ffffffffc020115e:	00fe3023          	sd	a5,0(t3)
ffffffffc0201162:	00f83423          	sd	a5,8(a6)
    elm->next = next;
ffffffffc0201166:	03c8b023          	sd	t3,32(a7)
    elm->prev = prev;
ffffffffc020116a:	0108bc23          	sd	a6,24(a7)
    for(size_t i=0;i<n;i++){
ffffffffc020116e:	028f0f13          	addi	t5,t5,40
ffffffffc0201172:	2f85                	addiw	t6,t6,1
ffffffffc0201174:	025f0863          	beq	t5,t0,ffffffffc02011a4 <buddy_free_pages+0xb0>
ffffffffc0201178:	8e3e                	mv	t3,a5
ffffffffc020117a:	b76d                	j	ffffffffc0201124 <buddy_free_pages+0x30>
  	        if(p->flags > buddy->flags)
ffffffffc020117c:	00d67463          	bgeu	a2,a3,ffffffffc0201184 <buddy_free_pages+0x90>
        		struct Page *q = le2page(le, page_link);
ffffffffc0201180:	fe878893          	addi	a7,a5,-24
    __list_del(listelm->prev, listelm->next);
ffffffffc0201184:	639c                	ld	a5,0(a5)
    	while ((order<<1) < nr_free) {
ffffffffc0201186:	00131693          	slli	a3,t1,0x1
    prev->next = next;
ffffffffc020118a:	e798                	sd	a4,8(a5)
    next->prev = prev;
ffffffffc020118c:	e31c                	sd	a5,0(a4)
    __list_add(elm, listelm, listelm->next);
ffffffffc020118e:	00883e03          	ld	t3,8(a6)
ffffffffc0201192:	01d6f663          	bgeu	a3,t4,ffffffffc020119e <buddy_free_pages+0xaa>
ffffffffc0201196:	851a                	mv	a0,t1
ffffffffc0201198:	87f2                	mv	a5,t3
ffffffffc020119a:	8336                	mv	t1,a3
ffffffffc020119c:	bf71                	j	ffffffffc0201138 <buddy_free_pages+0x44>
   	 	p->property=order;
ffffffffc020119e:	0003051b          	sext.w	a0,t1
ffffffffc02011a2:	bf55                	j	ffffffffc0201156 <buddy_free_pages+0x62>
}
ffffffffc02011a4:	60e2                	ld	ra,24(sp)
    	nr_free += 1;
ffffffffc02011a6:	fff40793          	addi	a5,s0,-1
}
ffffffffc02011aa:	6442                	ld	s0,16(sp)
    	nr_free += 1;
ffffffffc02011ac:	9fa5                	addw	a5,a5,s1
ffffffffc02011ae:	00f82823          	sw	a5,16(a6)
}
ffffffffc02011b2:	64a2                	ld	s1,8(sp)
ffffffffc02011b4:	6105                	addi	sp,sp,32
ffffffffc02011b6:	8082                	ret
    assert(n > 0);
ffffffffc02011b8:	00001697          	auipc	a3,0x1
ffffffffc02011bc:	f9068693          	addi	a3,a3,-112 # ffffffffc0202148 <commands+0x4f8>
ffffffffc02011c0:	00001617          	auipc	a2,0x1
ffffffffc02011c4:	f9060613          	addi	a2,a2,-112 # ffffffffc0202150 <commands+0x500>
ffffffffc02011c8:	05400593          	li	a1,84
ffffffffc02011cc:	00001517          	auipc	a0,0x1
ffffffffc02011d0:	f9c50513          	addi	a0,a0,-100 # ffffffffc0202168 <commands+0x518>
ffffffffc02011d4:	9d8ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02011d8 <buddy_init_memmap>:
buddy_init_memmap(struct Page *base, size_t n) {
ffffffffc02011d8:	1141                	addi	sp,sp,-16
ffffffffc02011da:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02011dc:	cdc1                	beqz	a1,ffffffffc0201274 <buddy_init_memmap+0x9c>
    for (; p != base + n; p++) {
ffffffffc02011de:	00259613          	slli	a2,a1,0x2
ffffffffc02011e2:	962e                	add	a2,a2,a1
ffffffffc02011e4:	060e                	slli	a2,a2,0x3
ffffffffc02011e6:	962a                	add	a2,a2,a0
ffffffffc02011e8:	87aa                	mv	a5,a0
    size_t flag=0;
ffffffffc02011ea:	4681                	li	a3,0
    for (; p != base + n; p++) {
ffffffffc02011ec:	00c50f63          	beq	a0,a2,ffffffffc020120a <buddy_init_memmap+0x32>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02011f0:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc02011f2:	8b05                	andi	a4,a4,1
ffffffffc02011f4:	c32d                	beqz	a4,ffffffffc0201256 <buddy_init_memmap+0x7e>
        p->flags = flag;
ffffffffc02011f6:	e794                	sd	a3,8(a5)
        p->property = 0;
ffffffffc02011f8:	0007a823          	sw	zero,16(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02011fc:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++) {
ffffffffc0201200:	02878793          	addi	a5,a5,40
        flag++;
ffffffffc0201204:	0685                	addi	a3,a3,1
    for (; p != base + n; p++) {
ffffffffc0201206:	fec795e3          	bne	a5,a2,ffffffffc02011f0 <buddy_init_memmap+0x18>
	while(i<x) i<<=1;
ffffffffc020120a:	4705                	li	a4,1
	size_t i=1;
ffffffffc020120c:	4785                	li	a5,1
	while(i<x) i<<=1;
ffffffffc020120e:	04e58063          	beq	a1,a4,ffffffffc020124e <buddy_init_memmap+0x76>
ffffffffc0201212:	0786                	slli	a5,a5,0x1
ffffffffc0201214:	feb7efe3          	bltu	a5,a1,ffffffffc0201212 <buddy_init_memmap+0x3a>
    base->property = up_bound2(n)<<1;
ffffffffc0201218:	0017979b          	slliw	a5,a5,0x1
ffffffffc020121c:	c91c                	sw	a5,16(a0)
ffffffffc020121e:	4785                	li	a5,1
	while(i<x) i<<=1;
ffffffffc0201220:	873e                	mv	a4,a5
ffffffffc0201222:	0786                	slli	a5,a5,0x1
ffffffffc0201224:	feb7eee3          	bltu	a5,a1,ffffffffc0201220 <buddy_init_memmap+0x48>
    nr_free += up_bound2(n)<<1;
ffffffffc0201228:	070a                	slli	a4,a4,0x2
ffffffffc020122a:	2701                	sext.w	a4,a4
ffffffffc020122c:	00005797          	auipc	a5,0x5
ffffffffc0201230:	de478793          	addi	a5,a5,-540 # ffffffffc0206010 <free_area>
ffffffffc0201234:	4b94                	lw	a3,16(a5)
ffffffffc0201236:	6790                	ld	a2,8(a5)
}
ffffffffc0201238:	60a2                	ld	ra,8(sp)
    nr_free += up_bound2(n)<<1;
ffffffffc020123a:	9f35                	addw	a4,a4,a3
    list_add(&free_list, &(base->page_link)); 
ffffffffc020123c:	01850593          	addi	a1,a0,24
    nr_free += up_bound2(n)<<1;
ffffffffc0201240:	cb98                	sw	a4,16(a5)
    prev->next = next->prev = elm;
ffffffffc0201242:	e20c                	sd	a1,0(a2)
ffffffffc0201244:	e78c                	sd	a1,8(a5)
    elm->next = next;
ffffffffc0201246:	f110                	sd	a2,32(a0)
    elm->prev = prev;
ffffffffc0201248:	ed1c                	sd	a5,24(a0)
}
ffffffffc020124a:	0141                	addi	sp,sp,16
ffffffffc020124c:	8082                	ret
    base->property = up_bound2(n)<<1;
ffffffffc020124e:	4789                	li	a5,2
ffffffffc0201250:	c91c                	sw	a5,16(a0)
ffffffffc0201252:	4709                	li	a4,2
ffffffffc0201254:	bfe1                	j	ffffffffc020122c <buddy_init_memmap+0x54>
        assert(PageReserved(p));
ffffffffc0201256:	00001697          	auipc	a3,0x1
ffffffffc020125a:	2b268693          	addi	a3,a3,690 # ffffffffc0202508 <commands+0x8b8>
ffffffffc020125e:	00001617          	auipc	a2,0x1
ffffffffc0201262:	ef260613          	addi	a2,a2,-270 # ffffffffc0202150 <commands+0x500>
ffffffffc0201266:	45f5                	li	a1,29
ffffffffc0201268:	00001517          	auipc	a0,0x1
ffffffffc020126c:	f0050513          	addi	a0,a0,-256 # ffffffffc0202168 <commands+0x518>
ffffffffc0201270:	93cff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc0201274:	00001697          	auipc	a3,0x1
ffffffffc0201278:	ed468693          	addi	a3,a3,-300 # ffffffffc0202148 <commands+0x4f8>
ffffffffc020127c:	00001617          	auipc	a2,0x1
ffffffffc0201280:	ed460613          	addi	a2,a2,-300 # ffffffffc0202150 <commands+0x500>
ffffffffc0201284:	45e5                	li	a1,25
ffffffffc0201286:	00001517          	auipc	a0,0x1
ffffffffc020128a:	ee250513          	addi	a0,a0,-286 # ffffffffc0202168 <commands+0x518>
ffffffffc020128e:	91eff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201292 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201292:	100027f3          	csrr	a5,sstatus
ffffffffc0201296:	8b89                	andi	a5,a5,2
ffffffffc0201298:	e799                	bnez	a5,ffffffffc02012a6 <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc020129a:	00005797          	auipc	a5,0x5
ffffffffc020129e:	1ae7b783          	ld	a5,430(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc02012a2:	6f9c                	ld	a5,24(a5)
ffffffffc02012a4:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc02012a6:	1141                	addi	sp,sp,-16
ffffffffc02012a8:	e406                	sd	ra,8(sp)
ffffffffc02012aa:	e022                	sd	s0,0(sp)
ffffffffc02012ac:	842a                	mv	s0,a0
        intr_disable();
ffffffffc02012ae:	9b0ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02012b2:	00005797          	auipc	a5,0x5
ffffffffc02012b6:	1967b783          	ld	a5,406(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc02012ba:	6f9c                	ld	a5,24(a5)
ffffffffc02012bc:	8522                	mv	a0,s0
ffffffffc02012be:	9782                	jalr	a5
ffffffffc02012c0:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc02012c2:	996ff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc02012c6:	60a2                	ld	ra,8(sp)
ffffffffc02012c8:	8522                	mv	a0,s0
ffffffffc02012ca:	6402                	ld	s0,0(sp)
ffffffffc02012cc:	0141                	addi	sp,sp,16
ffffffffc02012ce:	8082                	ret

ffffffffc02012d0 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02012d0:	100027f3          	csrr	a5,sstatus
ffffffffc02012d4:	8b89                	andi	a5,a5,2
ffffffffc02012d6:	e799                	bnez	a5,ffffffffc02012e4 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc02012d8:	00005797          	auipc	a5,0x5
ffffffffc02012dc:	1707b783          	ld	a5,368(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc02012e0:	739c                	ld	a5,32(a5)
ffffffffc02012e2:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc02012e4:	1101                	addi	sp,sp,-32
ffffffffc02012e6:	ec06                	sd	ra,24(sp)
ffffffffc02012e8:	e822                	sd	s0,16(sp)
ffffffffc02012ea:	e426                	sd	s1,8(sp)
ffffffffc02012ec:	842a                	mv	s0,a0
ffffffffc02012ee:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc02012f0:	96eff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02012f4:	00005797          	auipc	a5,0x5
ffffffffc02012f8:	1547b783          	ld	a5,340(a5) # ffffffffc0206448 <pmm_manager>
ffffffffc02012fc:	739c                	ld	a5,32(a5)
ffffffffc02012fe:	85a6                	mv	a1,s1
ffffffffc0201300:	8522                	mv	a0,s0
ffffffffc0201302:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201304:	6442                	ld	s0,16(sp)
ffffffffc0201306:	60e2                	ld	ra,24(sp)
ffffffffc0201308:	64a2                	ld	s1,8(sp)
ffffffffc020130a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020130c:	94cff06f          	j	ffffffffc0200458 <intr_enable>

ffffffffc0201310 <pmm_init>:
    pmm_manager = &buddy_pmm_manager;
ffffffffc0201310:	00001797          	auipc	a5,0x1
ffffffffc0201314:	22078793          	addi	a5,a5,544 # ffffffffc0202530 <buddy_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201318:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc020131a:	1101                	addi	sp,sp,-32
ffffffffc020131c:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020131e:	00001517          	auipc	a0,0x1
ffffffffc0201322:	24a50513          	addi	a0,a0,586 # ffffffffc0202568 <buddy_pmm_manager+0x38>
    pmm_manager = &buddy_pmm_manager;
ffffffffc0201326:	00005497          	auipc	s1,0x5
ffffffffc020132a:	12248493          	addi	s1,s1,290 # ffffffffc0206448 <pmm_manager>
void pmm_init(void) {
ffffffffc020132e:	ec06                	sd	ra,24(sp)
ffffffffc0201330:	e822                	sd	s0,16(sp)
    pmm_manager = &buddy_pmm_manager;
ffffffffc0201332:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201334:	d7ffe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pmm_manager->init();
ffffffffc0201338:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc020133a:	00005417          	auipc	s0,0x5
ffffffffc020133e:	12640413          	addi	s0,s0,294 # ffffffffc0206460 <va_pa_offset>
    pmm_manager->init();
ffffffffc0201342:	679c                	ld	a5,8(a5)
ffffffffc0201344:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201346:	57f5                	li	a5,-3
ffffffffc0201348:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc020134a:	00001517          	auipc	a0,0x1
ffffffffc020134e:	23650513          	addi	a0,a0,566 # ffffffffc0202580 <buddy_pmm_manager+0x50>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201352:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc0201354:	d5ffe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0201358:	46c5                	li	a3,17
ffffffffc020135a:	06ee                	slli	a3,a3,0x1b
ffffffffc020135c:	40100613          	li	a2,1025
ffffffffc0201360:	16fd                	addi	a3,a3,-1
ffffffffc0201362:	07e005b7          	lui	a1,0x7e00
ffffffffc0201366:	0656                	slli	a2,a2,0x15
ffffffffc0201368:	00001517          	auipc	a0,0x1
ffffffffc020136c:	23050513          	addi	a0,a0,560 # ffffffffc0202598 <buddy_pmm_manager+0x68>
ffffffffc0201370:	d43fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201374:	777d                	lui	a4,0xfffff
ffffffffc0201376:	00006797          	auipc	a5,0x6
ffffffffc020137a:	0f978793          	addi	a5,a5,249 # ffffffffc020746f <end+0xfff>
ffffffffc020137e:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201380:	00005517          	auipc	a0,0x5
ffffffffc0201384:	0b850513          	addi	a0,a0,184 # ffffffffc0206438 <npage>
ffffffffc0201388:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020138c:	00005597          	auipc	a1,0x5
ffffffffc0201390:	0b458593          	addi	a1,a1,180 # ffffffffc0206440 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0201394:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201396:	e19c                	sd	a5,0(a1)
ffffffffc0201398:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020139a:	4701                	li	a4,0
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020139c:	4885                	li	a7,1
ffffffffc020139e:	fff80837          	lui	a6,0xfff80
ffffffffc02013a2:	a011                	j	ffffffffc02013a6 <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc02013a4:	619c                	ld	a5,0(a1)
ffffffffc02013a6:	97b6                	add	a5,a5,a3
ffffffffc02013a8:	07a1                	addi	a5,a5,8
ffffffffc02013aa:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02013ae:	611c                	ld	a5,0(a0)
ffffffffc02013b0:	0705                	addi	a4,a4,1
ffffffffc02013b2:	02868693          	addi	a3,a3,40
ffffffffc02013b6:	01078633          	add	a2,a5,a6
ffffffffc02013ba:	fec765e3          	bltu	a4,a2,ffffffffc02013a4 <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02013be:	6190                	ld	a2,0(a1)
ffffffffc02013c0:	00279713          	slli	a4,a5,0x2
ffffffffc02013c4:	973e                	add	a4,a4,a5
ffffffffc02013c6:	fec006b7          	lui	a3,0xfec00
ffffffffc02013ca:	070e                	slli	a4,a4,0x3
ffffffffc02013cc:	96b2                	add	a3,a3,a2
ffffffffc02013ce:	96ba                	add	a3,a3,a4
ffffffffc02013d0:	c0200737          	lui	a4,0xc0200
ffffffffc02013d4:	08e6ef63          	bltu	a3,a4,ffffffffc0201472 <pmm_init+0x162>
ffffffffc02013d8:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc02013da:	45c5                	li	a1,17
ffffffffc02013dc:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02013de:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc02013e0:	04b6e863          	bltu	a3,a1,ffffffffc0201430 <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02013e4:	609c                	ld	a5,0(s1)
ffffffffc02013e6:	7b9c                	ld	a5,48(a5)
ffffffffc02013e8:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02013ea:	00001517          	auipc	a0,0x1
ffffffffc02013ee:	24650513          	addi	a0,a0,582 # ffffffffc0202630 <buddy_pmm_manager+0x100>
ffffffffc02013f2:	cc1fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc02013f6:	00004597          	auipc	a1,0x4
ffffffffc02013fa:	c0a58593          	addi	a1,a1,-1014 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc02013fe:	00005797          	auipc	a5,0x5
ffffffffc0201402:	04b7bd23          	sd	a1,90(a5) # ffffffffc0206458 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201406:	c02007b7          	lui	a5,0xc0200
ffffffffc020140a:	08f5e063          	bltu	a1,a5,ffffffffc020148a <pmm_init+0x17a>
ffffffffc020140e:	6010                	ld	a2,0(s0)
}
ffffffffc0201410:	6442                	ld	s0,16(sp)
ffffffffc0201412:	60e2                	ld	ra,24(sp)
ffffffffc0201414:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0201416:	40c58633          	sub	a2,a1,a2
ffffffffc020141a:	00005797          	auipc	a5,0x5
ffffffffc020141e:	02c7bb23          	sd	a2,54(a5) # ffffffffc0206450 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201422:	00001517          	auipc	a0,0x1
ffffffffc0201426:	22e50513          	addi	a0,a0,558 # ffffffffc0202650 <buddy_pmm_manager+0x120>
}
ffffffffc020142a:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020142c:	c87fe06f          	j	ffffffffc02000b2 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0201430:	6705                	lui	a4,0x1
ffffffffc0201432:	177d                	addi	a4,a4,-1
ffffffffc0201434:	96ba                	add	a3,a3,a4
ffffffffc0201436:	777d                	lui	a4,0xfffff
ffffffffc0201438:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc020143a:	00c6d513          	srli	a0,a3,0xc
ffffffffc020143e:	00f57e63          	bgeu	a0,a5,ffffffffc020145a <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc0201442:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0201444:	982a                	add	a6,a6,a0
ffffffffc0201446:	00281513          	slli	a0,a6,0x2
ffffffffc020144a:	9542                	add	a0,a0,a6
ffffffffc020144c:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020144e:	8d95                	sub	a1,a1,a3
ffffffffc0201450:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0201452:	81b1                	srli	a1,a1,0xc
ffffffffc0201454:	9532                	add	a0,a0,a2
ffffffffc0201456:	9782                	jalr	a5
}
ffffffffc0201458:	b771                	j	ffffffffc02013e4 <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc020145a:	00001617          	auipc	a2,0x1
ffffffffc020145e:	1a660613          	addi	a2,a2,422 # ffffffffc0202600 <buddy_pmm_manager+0xd0>
ffffffffc0201462:	06b00593          	li	a1,107
ffffffffc0201466:	00001517          	auipc	a0,0x1
ffffffffc020146a:	1ba50513          	addi	a0,a0,442 # ffffffffc0202620 <buddy_pmm_manager+0xf0>
ffffffffc020146e:	f3ffe0ef          	jal	ra,ffffffffc02003ac <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201472:	00001617          	auipc	a2,0x1
ffffffffc0201476:	15660613          	addi	a2,a2,342 # ffffffffc02025c8 <buddy_pmm_manager+0x98>
ffffffffc020147a:	06f00593          	li	a1,111
ffffffffc020147e:	00001517          	auipc	a0,0x1
ffffffffc0201482:	17250513          	addi	a0,a0,370 # ffffffffc02025f0 <buddy_pmm_manager+0xc0>
ffffffffc0201486:	f27fe0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc020148a:	86ae                	mv	a3,a1
ffffffffc020148c:	00001617          	auipc	a2,0x1
ffffffffc0201490:	13c60613          	addi	a2,a2,316 # ffffffffc02025c8 <buddy_pmm_manager+0x98>
ffffffffc0201494:	08a00593          	li	a1,138
ffffffffc0201498:	00001517          	auipc	a0,0x1
ffffffffc020149c:	15850513          	addi	a0,a0,344 # ffffffffc02025f0 <buddy_pmm_manager+0xc0>
ffffffffc02014a0:	f0dfe0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02014a4 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02014a4:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02014a8:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02014aa:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02014ae:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02014b0:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02014b4:	f022                	sd	s0,32(sp)
ffffffffc02014b6:	ec26                	sd	s1,24(sp)
ffffffffc02014b8:	e84a                	sd	s2,16(sp)
ffffffffc02014ba:	f406                	sd	ra,40(sp)
ffffffffc02014bc:	e44e                	sd	s3,8(sp)
ffffffffc02014be:	84aa                	mv	s1,a0
ffffffffc02014c0:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02014c2:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02014c6:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc02014c8:	03067e63          	bgeu	a2,a6,ffffffffc0201504 <printnum+0x60>
ffffffffc02014cc:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc02014ce:	00805763          	blez	s0,ffffffffc02014dc <printnum+0x38>
ffffffffc02014d2:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02014d4:	85ca                	mv	a1,s2
ffffffffc02014d6:	854e                	mv	a0,s3
ffffffffc02014d8:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02014da:	fc65                	bnez	s0,ffffffffc02014d2 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02014dc:	1a02                	slli	s4,s4,0x20
ffffffffc02014de:	00001797          	auipc	a5,0x1
ffffffffc02014e2:	1b278793          	addi	a5,a5,434 # ffffffffc0202690 <buddy_pmm_manager+0x160>
ffffffffc02014e6:	020a5a13          	srli	s4,s4,0x20
ffffffffc02014ea:	9a3e                	add	s4,s4,a5
}
ffffffffc02014ec:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02014ee:	000a4503          	lbu	a0,0(s4)
}
ffffffffc02014f2:	70a2                	ld	ra,40(sp)
ffffffffc02014f4:	69a2                	ld	s3,8(sp)
ffffffffc02014f6:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02014f8:	85ca                	mv	a1,s2
ffffffffc02014fa:	87a6                	mv	a5,s1
}
ffffffffc02014fc:	6942                	ld	s2,16(sp)
ffffffffc02014fe:	64e2                	ld	s1,24(sp)
ffffffffc0201500:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201502:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0201504:	03065633          	divu	a2,a2,a6
ffffffffc0201508:	8722                	mv	a4,s0
ffffffffc020150a:	f9bff0ef          	jal	ra,ffffffffc02014a4 <printnum>
ffffffffc020150e:	b7f9                	j	ffffffffc02014dc <printnum+0x38>

ffffffffc0201510 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0201510:	7119                	addi	sp,sp,-128
ffffffffc0201512:	f4a6                	sd	s1,104(sp)
ffffffffc0201514:	f0ca                	sd	s2,96(sp)
ffffffffc0201516:	ecce                	sd	s3,88(sp)
ffffffffc0201518:	e8d2                	sd	s4,80(sp)
ffffffffc020151a:	e4d6                	sd	s5,72(sp)
ffffffffc020151c:	e0da                	sd	s6,64(sp)
ffffffffc020151e:	fc5e                	sd	s7,56(sp)
ffffffffc0201520:	f06a                	sd	s10,32(sp)
ffffffffc0201522:	fc86                	sd	ra,120(sp)
ffffffffc0201524:	f8a2                	sd	s0,112(sp)
ffffffffc0201526:	f862                	sd	s8,48(sp)
ffffffffc0201528:	f466                	sd	s9,40(sp)
ffffffffc020152a:	ec6e                	sd	s11,24(sp)
ffffffffc020152c:	892a                	mv	s2,a0
ffffffffc020152e:	84ae                	mv	s1,a1
ffffffffc0201530:	8d32                	mv	s10,a2
ffffffffc0201532:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201534:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0201538:	5b7d                	li	s6,-1
ffffffffc020153a:	00001a97          	auipc	s5,0x1
ffffffffc020153e:	18aa8a93          	addi	s5,s5,394 # ffffffffc02026c4 <buddy_pmm_manager+0x194>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201542:	00001b97          	auipc	s7,0x1
ffffffffc0201546:	35eb8b93          	addi	s7,s7,862 # ffffffffc02028a0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020154a:	000d4503          	lbu	a0,0(s10)
ffffffffc020154e:	001d0413          	addi	s0,s10,1
ffffffffc0201552:	01350a63          	beq	a0,s3,ffffffffc0201566 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0201556:	c121                	beqz	a0,ffffffffc0201596 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0201558:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020155a:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc020155c:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020155e:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201562:	ff351ae3          	bne	a0,s3,ffffffffc0201556 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201566:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc020156a:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc020156e:	4c81                	li	s9,0
ffffffffc0201570:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0201572:	5c7d                	li	s8,-1
ffffffffc0201574:	5dfd                	li	s11,-1
ffffffffc0201576:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc020157a:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020157c:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0201580:	0ff5f593          	zext.b	a1,a1
ffffffffc0201584:	00140d13          	addi	s10,s0,1
ffffffffc0201588:	04b56263          	bltu	a0,a1,ffffffffc02015cc <vprintfmt+0xbc>
ffffffffc020158c:	058a                	slli	a1,a1,0x2
ffffffffc020158e:	95d6                	add	a1,a1,s5
ffffffffc0201590:	4194                	lw	a3,0(a1)
ffffffffc0201592:	96d6                	add	a3,a3,s5
ffffffffc0201594:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201596:	70e6                	ld	ra,120(sp)
ffffffffc0201598:	7446                	ld	s0,112(sp)
ffffffffc020159a:	74a6                	ld	s1,104(sp)
ffffffffc020159c:	7906                	ld	s2,96(sp)
ffffffffc020159e:	69e6                	ld	s3,88(sp)
ffffffffc02015a0:	6a46                	ld	s4,80(sp)
ffffffffc02015a2:	6aa6                	ld	s5,72(sp)
ffffffffc02015a4:	6b06                	ld	s6,64(sp)
ffffffffc02015a6:	7be2                	ld	s7,56(sp)
ffffffffc02015a8:	7c42                	ld	s8,48(sp)
ffffffffc02015aa:	7ca2                	ld	s9,40(sp)
ffffffffc02015ac:	7d02                	ld	s10,32(sp)
ffffffffc02015ae:	6de2                	ld	s11,24(sp)
ffffffffc02015b0:	6109                	addi	sp,sp,128
ffffffffc02015b2:	8082                	ret
            padc = '0';
ffffffffc02015b4:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc02015b6:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015ba:	846a                	mv	s0,s10
ffffffffc02015bc:	00140d13          	addi	s10,s0,1
ffffffffc02015c0:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02015c4:	0ff5f593          	zext.b	a1,a1
ffffffffc02015c8:	fcb572e3          	bgeu	a0,a1,ffffffffc020158c <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc02015cc:	85a6                	mv	a1,s1
ffffffffc02015ce:	02500513          	li	a0,37
ffffffffc02015d2:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02015d4:	fff44783          	lbu	a5,-1(s0)
ffffffffc02015d8:	8d22                	mv	s10,s0
ffffffffc02015da:	f73788e3          	beq	a5,s3,ffffffffc020154a <vprintfmt+0x3a>
ffffffffc02015de:	ffed4783          	lbu	a5,-2(s10)
ffffffffc02015e2:	1d7d                	addi	s10,s10,-1
ffffffffc02015e4:	ff379de3          	bne	a5,s3,ffffffffc02015de <vprintfmt+0xce>
ffffffffc02015e8:	b78d                	j	ffffffffc020154a <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc02015ea:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc02015ee:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015f2:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02015f4:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02015f8:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc02015fc:	02d86463          	bltu	a6,a3,ffffffffc0201624 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0201600:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201604:	002c169b          	slliw	a3,s8,0x2
ffffffffc0201608:	0186873b          	addw	a4,a3,s8
ffffffffc020160c:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201610:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0201612:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0201616:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201618:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc020161c:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201620:	fed870e3          	bgeu	a6,a3,ffffffffc0201600 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0201624:	f40ddce3          	bgez	s11,ffffffffc020157c <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0201628:	8de2                	mv	s11,s8
ffffffffc020162a:	5c7d                	li	s8,-1
ffffffffc020162c:	bf81                	j	ffffffffc020157c <vprintfmt+0x6c>
            if (width < 0)
ffffffffc020162e:	fffdc693          	not	a3,s11
ffffffffc0201632:	96fd                	srai	a3,a3,0x3f
ffffffffc0201634:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201638:	00144603          	lbu	a2,1(s0)
ffffffffc020163c:	2d81                	sext.w	s11,s11
ffffffffc020163e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201640:	bf35                	j	ffffffffc020157c <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0201642:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201646:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc020164a:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020164c:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc020164e:	bfd9                	j	ffffffffc0201624 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0201650:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201652:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201656:	01174463          	blt	a4,a7,ffffffffc020165e <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc020165a:	1a088e63          	beqz	a7,ffffffffc0201816 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc020165e:	000a3603          	ld	a2,0(s4)
ffffffffc0201662:	46c1                	li	a3,16
ffffffffc0201664:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201666:	2781                	sext.w	a5,a5
ffffffffc0201668:	876e                	mv	a4,s11
ffffffffc020166a:	85a6                	mv	a1,s1
ffffffffc020166c:	854a                	mv	a0,s2
ffffffffc020166e:	e37ff0ef          	jal	ra,ffffffffc02014a4 <printnum>
            break;
ffffffffc0201672:	bde1                	j	ffffffffc020154a <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0201674:	000a2503          	lw	a0,0(s4)
ffffffffc0201678:	85a6                	mv	a1,s1
ffffffffc020167a:	0a21                	addi	s4,s4,8
ffffffffc020167c:	9902                	jalr	s2
            break;
ffffffffc020167e:	b5f1                	j	ffffffffc020154a <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201680:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201682:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201686:	01174463          	blt	a4,a7,ffffffffc020168e <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc020168a:	18088163          	beqz	a7,ffffffffc020180c <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc020168e:	000a3603          	ld	a2,0(s4)
ffffffffc0201692:	46a9                	li	a3,10
ffffffffc0201694:	8a2e                	mv	s4,a1
ffffffffc0201696:	bfc1                	j	ffffffffc0201666 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201698:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020169c:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020169e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02016a0:	bdf1                	j	ffffffffc020157c <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc02016a2:	85a6                	mv	a1,s1
ffffffffc02016a4:	02500513          	li	a0,37
ffffffffc02016a8:	9902                	jalr	s2
            break;
ffffffffc02016aa:	b545                	j	ffffffffc020154a <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016ac:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc02016b0:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016b2:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02016b4:	b5e1                	j	ffffffffc020157c <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc02016b6:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02016b8:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02016bc:	01174463          	blt	a4,a7,ffffffffc02016c4 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc02016c0:	14088163          	beqz	a7,ffffffffc0201802 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc02016c4:	000a3603          	ld	a2,0(s4)
ffffffffc02016c8:	46a1                	li	a3,8
ffffffffc02016ca:	8a2e                	mv	s4,a1
ffffffffc02016cc:	bf69                	j	ffffffffc0201666 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc02016ce:	03000513          	li	a0,48
ffffffffc02016d2:	85a6                	mv	a1,s1
ffffffffc02016d4:	e03e                	sd	a5,0(sp)
ffffffffc02016d6:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02016d8:	85a6                	mv	a1,s1
ffffffffc02016da:	07800513          	li	a0,120
ffffffffc02016de:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02016e0:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc02016e2:	6782                	ld	a5,0(sp)
ffffffffc02016e4:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02016e6:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc02016ea:	bfb5                	j	ffffffffc0201666 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02016ec:	000a3403          	ld	s0,0(s4)
ffffffffc02016f0:	008a0713          	addi	a4,s4,8
ffffffffc02016f4:	e03a                	sd	a4,0(sp)
ffffffffc02016f6:	14040263          	beqz	s0,ffffffffc020183a <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc02016fa:	0fb05763          	blez	s11,ffffffffc02017e8 <vprintfmt+0x2d8>
ffffffffc02016fe:	02d00693          	li	a3,45
ffffffffc0201702:	0cd79163          	bne	a5,a3,ffffffffc02017c4 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201706:	00044783          	lbu	a5,0(s0)
ffffffffc020170a:	0007851b          	sext.w	a0,a5
ffffffffc020170e:	cf85                	beqz	a5,ffffffffc0201746 <vprintfmt+0x236>
ffffffffc0201710:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201714:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201718:	000c4563          	bltz	s8,ffffffffc0201722 <vprintfmt+0x212>
ffffffffc020171c:	3c7d                	addiw	s8,s8,-1
ffffffffc020171e:	036c0263          	beq	s8,s6,ffffffffc0201742 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0201722:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201724:	0e0c8e63          	beqz	s9,ffffffffc0201820 <vprintfmt+0x310>
ffffffffc0201728:	3781                	addiw	a5,a5,-32
ffffffffc020172a:	0ef47b63          	bgeu	s0,a5,ffffffffc0201820 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc020172e:	03f00513          	li	a0,63
ffffffffc0201732:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201734:	000a4783          	lbu	a5,0(s4)
ffffffffc0201738:	3dfd                	addiw	s11,s11,-1
ffffffffc020173a:	0a05                	addi	s4,s4,1
ffffffffc020173c:	0007851b          	sext.w	a0,a5
ffffffffc0201740:	ffe1                	bnez	a5,ffffffffc0201718 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0201742:	01b05963          	blez	s11,ffffffffc0201754 <vprintfmt+0x244>
ffffffffc0201746:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201748:	85a6                	mv	a1,s1
ffffffffc020174a:	02000513          	li	a0,32
ffffffffc020174e:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201750:	fe0d9be3          	bnez	s11,ffffffffc0201746 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201754:	6a02                	ld	s4,0(sp)
ffffffffc0201756:	bbd5                	j	ffffffffc020154a <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201758:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020175a:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc020175e:	01174463          	blt	a4,a7,ffffffffc0201766 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0201762:	08088d63          	beqz	a7,ffffffffc02017fc <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0201766:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc020176a:	0a044d63          	bltz	s0,ffffffffc0201824 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc020176e:	8622                	mv	a2,s0
ffffffffc0201770:	8a66                	mv	s4,s9
ffffffffc0201772:	46a9                	li	a3,10
ffffffffc0201774:	bdcd                	j	ffffffffc0201666 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc0201776:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020177a:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc020177c:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc020177e:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201782:	8fb5                	xor	a5,a5,a3
ffffffffc0201784:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201788:	02d74163          	blt	a4,a3,ffffffffc02017aa <vprintfmt+0x29a>
ffffffffc020178c:	00369793          	slli	a5,a3,0x3
ffffffffc0201790:	97de                	add	a5,a5,s7
ffffffffc0201792:	639c                	ld	a5,0(a5)
ffffffffc0201794:	cb99                	beqz	a5,ffffffffc02017aa <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201796:	86be                	mv	a3,a5
ffffffffc0201798:	00001617          	auipc	a2,0x1
ffffffffc020179c:	f2860613          	addi	a2,a2,-216 # ffffffffc02026c0 <buddy_pmm_manager+0x190>
ffffffffc02017a0:	85a6                	mv	a1,s1
ffffffffc02017a2:	854a                	mv	a0,s2
ffffffffc02017a4:	0ce000ef          	jal	ra,ffffffffc0201872 <printfmt>
ffffffffc02017a8:	b34d                	j	ffffffffc020154a <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02017aa:	00001617          	auipc	a2,0x1
ffffffffc02017ae:	f0660613          	addi	a2,a2,-250 # ffffffffc02026b0 <buddy_pmm_manager+0x180>
ffffffffc02017b2:	85a6                	mv	a1,s1
ffffffffc02017b4:	854a                	mv	a0,s2
ffffffffc02017b6:	0bc000ef          	jal	ra,ffffffffc0201872 <printfmt>
ffffffffc02017ba:	bb41                	j	ffffffffc020154a <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02017bc:	00001417          	auipc	s0,0x1
ffffffffc02017c0:	eec40413          	addi	s0,s0,-276 # ffffffffc02026a8 <buddy_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02017c4:	85e2                	mv	a1,s8
ffffffffc02017c6:	8522                	mv	a0,s0
ffffffffc02017c8:	e43e                	sd	a5,8(sp)
ffffffffc02017ca:	1cc000ef          	jal	ra,ffffffffc0201996 <strnlen>
ffffffffc02017ce:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02017d2:	01b05b63          	blez	s11,ffffffffc02017e8 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc02017d6:	67a2                	ld	a5,8(sp)
ffffffffc02017d8:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02017dc:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02017de:	85a6                	mv	a1,s1
ffffffffc02017e0:	8552                	mv	a0,s4
ffffffffc02017e2:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02017e4:	fe0d9ce3          	bnez	s11,ffffffffc02017dc <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02017e8:	00044783          	lbu	a5,0(s0)
ffffffffc02017ec:	00140a13          	addi	s4,s0,1
ffffffffc02017f0:	0007851b          	sext.w	a0,a5
ffffffffc02017f4:	d3a5                	beqz	a5,ffffffffc0201754 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02017f6:	05e00413          	li	s0,94
ffffffffc02017fa:	bf39                	j	ffffffffc0201718 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc02017fc:	000a2403          	lw	s0,0(s4)
ffffffffc0201800:	b7ad                	j	ffffffffc020176a <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0201802:	000a6603          	lwu	a2,0(s4)
ffffffffc0201806:	46a1                	li	a3,8
ffffffffc0201808:	8a2e                	mv	s4,a1
ffffffffc020180a:	bdb1                	j	ffffffffc0201666 <vprintfmt+0x156>
ffffffffc020180c:	000a6603          	lwu	a2,0(s4)
ffffffffc0201810:	46a9                	li	a3,10
ffffffffc0201812:	8a2e                	mv	s4,a1
ffffffffc0201814:	bd89                	j	ffffffffc0201666 <vprintfmt+0x156>
ffffffffc0201816:	000a6603          	lwu	a2,0(s4)
ffffffffc020181a:	46c1                	li	a3,16
ffffffffc020181c:	8a2e                	mv	s4,a1
ffffffffc020181e:	b5a1                	j	ffffffffc0201666 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0201820:	9902                	jalr	s2
ffffffffc0201822:	bf09                	j	ffffffffc0201734 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0201824:	85a6                	mv	a1,s1
ffffffffc0201826:	02d00513          	li	a0,45
ffffffffc020182a:	e03e                	sd	a5,0(sp)
ffffffffc020182c:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020182e:	6782                	ld	a5,0(sp)
ffffffffc0201830:	8a66                	mv	s4,s9
ffffffffc0201832:	40800633          	neg	a2,s0
ffffffffc0201836:	46a9                	li	a3,10
ffffffffc0201838:	b53d                	j	ffffffffc0201666 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc020183a:	03b05163          	blez	s11,ffffffffc020185c <vprintfmt+0x34c>
ffffffffc020183e:	02d00693          	li	a3,45
ffffffffc0201842:	f6d79de3          	bne	a5,a3,ffffffffc02017bc <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0201846:	00001417          	auipc	s0,0x1
ffffffffc020184a:	e6240413          	addi	s0,s0,-414 # ffffffffc02026a8 <buddy_pmm_manager+0x178>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020184e:	02800793          	li	a5,40
ffffffffc0201852:	02800513          	li	a0,40
ffffffffc0201856:	00140a13          	addi	s4,s0,1
ffffffffc020185a:	bd6d                	j	ffffffffc0201714 <vprintfmt+0x204>
ffffffffc020185c:	00001a17          	auipc	s4,0x1
ffffffffc0201860:	e4da0a13          	addi	s4,s4,-435 # ffffffffc02026a9 <buddy_pmm_manager+0x179>
ffffffffc0201864:	02800513          	li	a0,40
ffffffffc0201868:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020186c:	05e00413          	li	s0,94
ffffffffc0201870:	b565                	j	ffffffffc0201718 <vprintfmt+0x208>

ffffffffc0201872 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201872:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201874:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201878:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020187a:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020187c:	ec06                	sd	ra,24(sp)
ffffffffc020187e:	f83a                	sd	a4,48(sp)
ffffffffc0201880:	fc3e                	sd	a5,56(sp)
ffffffffc0201882:	e0c2                	sd	a6,64(sp)
ffffffffc0201884:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201886:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201888:	c89ff0ef          	jal	ra,ffffffffc0201510 <vprintfmt>
}
ffffffffc020188c:	60e2                	ld	ra,24(sp)
ffffffffc020188e:	6161                	addi	sp,sp,80
ffffffffc0201890:	8082                	ret

ffffffffc0201892 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201892:	715d                	addi	sp,sp,-80
ffffffffc0201894:	e486                	sd	ra,72(sp)
ffffffffc0201896:	e0a6                	sd	s1,64(sp)
ffffffffc0201898:	fc4a                	sd	s2,56(sp)
ffffffffc020189a:	f84e                	sd	s3,48(sp)
ffffffffc020189c:	f452                	sd	s4,40(sp)
ffffffffc020189e:	f056                	sd	s5,32(sp)
ffffffffc02018a0:	ec5a                	sd	s6,24(sp)
ffffffffc02018a2:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc02018a4:	c901                	beqz	a0,ffffffffc02018b4 <readline+0x22>
ffffffffc02018a6:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc02018a8:	00001517          	auipc	a0,0x1
ffffffffc02018ac:	e1850513          	addi	a0,a0,-488 # ffffffffc02026c0 <buddy_pmm_manager+0x190>
ffffffffc02018b0:	803fe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
readline(const char *prompt) {
ffffffffc02018b4:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02018b6:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02018b8:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02018ba:	4aa9                	li	s5,10
ffffffffc02018bc:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02018be:	00004b97          	auipc	s7,0x4
ffffffffc02018c2:	76ab8b93          	addi	s7,s7,1898 # ffffffffc0206028 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02018c6:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02018ca:	861fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc02018ce:	00054a63          	bltz	a0,ffffffffc02018e2 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02018d2:	00a95a63          	bge	s2,a0,ffffffffc02018e6 <readline+0x54>
ffffffffc02018d6:	029a5263          	bge	s4,s1,ffffffffc02018fa <readline+0x68>
        c = getchar();
ffffffffc02018da:	851fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc02018de:	fe055ae3          	bgez	a0,ffffffffc02018d2 <readline+0x40>
            return NULL;
ffffffffc02018e2:	4501                	li	a0,0
ffffffffc02018e4:	a091                	j	ffffffffc0201928 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02018e6:	03351463          	bne	a0,s3,ffffffffc020190e <readline+0x7c>
ffffffffc02018ea:	e8a9                	bnez	s1,ffffffffc020193c <readline+0xaa>
        c = getchar();
ffffffffc02018ec:	83ffe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc02018f0:	fe0549e3          	bltz	a0,ffffffffc02018e2 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02018f4:	fea959e3          	bge	s2,a0,ffffffffc02018e6 <readline+0x54>
ffffffffc02018f8:	4481                	li	s1,0
            cputchar(c);
ffffffffc02018fa:	e42a                	sd	a0,8(sp)
ffffffffc02018fc:	fecfe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i ++] = c;
ffffffffc0201900:	6522                	ld	a0,8(sp)
ffffffffc0201902:	009b87b3          	add	a5,s7,s1
ffffffffc0201906:	2485                	addiw	s1,s1,1
ffffffffc0201908:	00a78023          	sb	a0,0(a5)
ffffffffc020190c:	bf7d                	j	ffffffffc02018ca <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc020190e:	01550463          	beq	a0,s5,ffffffffc0201916 <readline+0x84>
ffffffffc0201912:	fb651ce3          	bne	a0,s6,ffffffffc02018ca <readline+0x38>
            cputchar(c);
ffffffffc0201916:	fd2fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i] = '\0';
ffffffffc020191a:	00004517          	auipc	a0,0x4
ffffffffc020191e:	70e50513          	addi	a0,a0,1806 # ffffffffc0206028 <buf>
ffffffffc0201922:	94aa                	add	s1,s1,a0
ffffffffc0201924:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201928:	60a6                	ld	ra,72(sp)
ffffffffc020192a:	6486                	ld	s1,64(sp)
ffffffffc020192c:	7962                	ld	s2,56(sp)
ffffffffc020192e:	79c2                	ld	s3,48(sp)
ffffffffc0201930:	7a22                	ld	s4,40(sp)
ffffffffc0201932:	7a82                	ld	s5,32(sp)
ffffffffc0201934:	6b62                	ld	s6,24(sp)
ffffffffc0201936:	6bc2                	ld	s7,16(sp)
ffffffffc0201938:	6161                	addi	sp,sp,80
ffffffffc020193a:	8082                	ret
            cputchar(c);
ffffffffc020193c:	4521                	li	a0,8
ffffffffc020193e:	faafe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            i --;
ffffffffc0201942:	34fd                	addiw	s1,s1,-1
ffffffffc0201944:	b759                	j	ffffffffc02018ca <readline+0x38>

ffffffffc0201946 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc0201946:	4781                	li	a5,0
ffffffffc0201948:	00004717          	auipc	a4,0x4
ffffffffc020194c:	6c073703          	ld	a4,1728(a4) # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201950:	88ba                	mv	a7,a4
ffffffffc0201952:	852a                	mv	a0,a0
ffffffffc0201954:	85be                	mv	a1,a5
ffffffffc0201956:	863e                	mv	a2,a5
ffffffffc0201958:	00000073          	ecall
ffffffffc020195c:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc020195e:	8082                	ret

ffffffffc0201960 <sbi_set_timer>:
    __asm__ volatile (
ffffffffc0201960:	4781                	li	a5,0
ffffffffc0201962:	00005717          	auipc	a4,0x5
ffffffffc0201966:	b0673703          	ld	a4,-1274(a4) # ffffffffc0206468 <SBI_SET_TIMER>
ffffffffc020196a:	88ba                	mv	a7,a4
ffffffffc020196c:	852a                	mv	a0,a0
ffffffffc020196e:	85be                	mv	a1,a5
ffffffffc0201970:	863e                	mv	a2,a5
ffffffffc0201972:	00000073          	ecall
ffffffffc0201976:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc0201978:	8082                	ret

ffffffffc020197a <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc020197a:	4501                	li	a0,0
ffffffffc020197c:	00004797          	auipc	a5,0x4
ffffffffc0201980:	6847b783          	ld	a5,1668(a5) # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc0201984:	88be                	mv	a7,a5
ffffffffc0201986:	852a                	mv	a0,a0
ffffffffc0201988:	85aa                	mv	a1,a0
ffffffffc020198a:	862a                	mv	a2,a0
ffffffffc020198c:	00000073          	ecall
ffffffffc0201990:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201992:	2501                	sext.w	a0,a0
ffffffffc0201994:	8082                	ret

ffffffffc0201996 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0201996:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201998:	e589                	bnez	a1,ffffffffc02019a2 <strnlen+0xc>
ffffffffc020199a:	a811                	j	ffffffffc02019ae <strnlen+0x18>
        cnt ++;
ffffffffc020199c:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020199e:	00f58863          	beq	a1,a5,ffffffffc02019ae <strnlen+0x18>
ffffffffc02019a2:	00f50733          	add	a4,a0,a5
ffffffffc02019a6:	00074703          	lbu	a4,0(a4)
ffffffffc02019aa:	fb6d                	bnez	a4,ffffffffc020199c <strnlen+0x6>
ffffffffc02019ac:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc02019ae:	852e                	mv	a0,a1
ffffffffc02019b0:	8082                	ret

ffffffffc02019b2 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02019b2:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02019b6:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02019ba:	cb89                	beqz	a5,ffffffffc02019cc <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc02019bc:	0505                	addi	a0,a0,1
ffffffffc02019be:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02019c0:	fee789e3          	beq	a5,a4,ffffffffc02019b2 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02019c4:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02019c8:	9d19                	subw	a0,a0,a4
ffffffffc02019ca:	8082                	ret
ffffffffc02019cc:	4501                	li	a0,0
ffffffffc02019ce:	bfed                	j	ffffffffc02019c8 <strcmp+0x16>

ffffffffc02019d0 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02019d0:	00054783          	lbu	a5,0(a0)
ffffffffc02019d4:	c799                	beqz	a5,ffffffffc02019e2 <strchr+0x12>
        if (*s == c) {
ffffffffc02019d6:	00f58763          	beq	a1,a5,ffffffffc02019e4 <strchr+0x14>
    while (*s != '\0') {
ffffffffc02019da:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc02019de:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02019e0:	fbfd                	bnez	a5,ffffffffc02019d6 <strchr+0x6>
    }
    return NULL;
ffffffffc02019e2:	4501                	li	a0,0
}
ffffffffc02019e4:	8082                	ret

ffffffffc02019e6 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02019e6:	ca01                	beqz	a2,ffffffffc02019f6 <memset+0x10>
ffffffffc02019e8:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02019ea:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02019ec:	0785                	addi	a5,a5,1
ffffffffc02019ee:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02019f2:	fec79de3          	bne	a5,a2,ffffffffc02019ec <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02019f6:	8082                	ret
