# lab0.5-1 操作系统实验报告

### 姚知言 2211290 贾景顺 2211312 李政远 2211320

## Code




### lab1 Exercise2代码

init.c:kern_init
```cpp {.line-numbers}
idt_init();

//add code here
asm volatile("ebreak");//breakpoint
asm volatile(".word 0x00000000");//illegal
    
clock_init();
```

### lab1 Challenge3代码
trap.c:interrupt_handler
```cpp {.line-numbers}
case IRQ_S_TIMER:
    clock_set_next_event();
    ticks++;
    if(ticks==100){
        print_ticks(); //cprintf("100 ticks\n");
        ticks=0;
        num++;
        if(num==10)
            sbi_shutdown();
    }
    break;
```

trap.c:exception_handler
```cpp {.line-numbers}
case CAUSE_ILLEGAL_INSTRUCTION:
    cprintf("Exception type:Illegal instruction\n");
    cprintf("Illegal instruction caught at 0x%08x\n", tf->epc);
    tf->epc+=4;
    break;
case CAUSE_BREAKPOINT:
    cprintf("Exception type: breakpoint\n");
    cprintf("ebreak caught at 0x%08x\n", tf->epc);
    tf->epc+=2;
    break;
```
### lab1运行结果

可以看到，Exercise2 和 Challenge3 的功能都成功实现。


![](lab1ans.png)

## Problems

### lab0.5 Exercise1:为了熟悉使用qemu和gdb进行调试工作,使用gdb调试QEMU模拟的RISC-V计算机加电开始运行到执行应用程序的第一条指令（即跳转到0x80200000）这个阶段的执行过程，说明RISC-V硬件加电后的几条指令在哪里？完成了哪些功能？要求在报告中简要写出练习过程和回答。

执行$make \, qemu$后，可以看到程序打印了一些内容后进入死循环，完成了验证。

![](lab0.5qemu.png)

通过$gdb$显示$0x1000$后的10条指令，可以看到在加电后的位置执行以下$5$条指令。


![](lab0.5gdb.png)

$auipc \, t0,0x0$将PC+0赋值给t0，即寄存器t0=0x1000。
$addi$指令将a1赋值为t0+32，即寄存器a1=0x1020。
$csrr$指令将csr寄存器mhartid存储在寄存器a0中，即a0=0x1000。
$ld$指令从t0+24的位置读取双字节数据赋值给t0，即t0=0x80000000。
$jr$指令实现跳转到t0的值的位置，即系统跳转到0x80000000。

跳转到0x80000000后，通过OpenSBI bootloader固件，在M层对内核进行初步的设置，将内核代码从硬盘加载到内存中，最终跳转到内核入口0x8020000，进行操作系统的执行阶段。

### lab1 Exercise1:阅读 kern/init/entry.S内容代码，结合操作系统内核启动流程，说明指令 la sp, bootstacktop 完成了什么操作，目的是什么？ tail kern_init 完成了什么操作，目的是什么？

la sp, bootstacktop这条指令用于将一个地址加载到堆栈指针寄存器sp,也就是将bootstacktop的地址栈顶给sp。这可以用于初始化栈指针，以确保程序在执行时能够正确地使用栈空间，也可以为内核或操作系统运行做准备。

tail 指令允许将当前函数的控制流无条件地转移到另一个函数。tail kern_init可以跳转到kern_init 函数的执行同时不需要保留内核初始化之前的栈帧。，目的是减少指令开销，提高程序的执行效率，简化控制流，同时启动内核初始化，避免不必要的返回。

### lab1 Challenge1:回答：描述ucore中处理中断异常的流程（从异常的产生开始），其中mov a0，sp的目的是什么？SAVE_ALL中寄寄存器保存在栈中的位置是什么确定的？对于任何中断，__alltraps 中都需要保存所有寄存器吗？请说明理由。

当CPU执行到某个指令时，如果遇到了需要外部协助的情况（如外设中断）或内部错误（如除零错误），它会暂停当前指令的执行，并将中断源地址记录于stvec这一CSR。在idt_init中，进行外部函数_alltraps的声明，随后通过write_csr(stvec, &__alltraps); 设置 stvec 寄存器的值是 __alltraps 的地址，将程序的执行流跳转至__alltraps。

在alltraps中，首先会通过SAVE_ALL进行上下文的保存——将所有寄存器的值存入内存，然后对临时寄存器a0赋值，以用于后续对trap函数传递参数。通过jal trap指令，程序开始执行trap函数，先进行是interrupt或是exception的判断，随后根据更细节的分类选择相对应的异常处理函数进行异常处理。

异常处理函数完成后，程序会转回去执行jal_trap后的第一条指令，即__trapret，执行定义的宏汇编RESTORE_ALL的指令，进行上下文的恢复，随后通过sret返回进入S态之前的地址。至此，一个完整的中断异常处理流程结束。

move a0，sp这一指令实现了将sp寄存器赋值给临时寄存器a0，又因为sp寄存器存储的值在宏汇编指令延伸后可以指向32个通用寄存器以及4个CSR的值，这36个寄存器的值按trapframe定义的顺序构成了一个trapframe类型的结构体。又因为trap()函数需要一个trapframe变量作为参数传递，因此通过将sp赋值给临时寄存器a0，使得后续可以将a0作为参数传入。

寄存器在栈中的位置是由栈指针sp和预设的偏移量共同确定的。偏移量通常是硬编码在SAVE_ALL宏中的，并且与每个寄存器的保存顺序一一对应。通过指令addi sp, sp, -36 * REGBYTES将 sp 寄存器的值向低地址空间延伸 36个寄存器的空间，同时将32个通用寄存器以及4个 CSR 的值存储在此空间内，即参数传递时按照sp指向的地址按照trapframe结构体的定义顺序一一传递。这样，无论栈指针的值如何变化，只要按照相同的顺序和偏移量来保存和恢复寄存器，就能确保上下文的一致性和正确性。


### lab1 Challenge2:回答：在trapentry.S中汇编代码 csrw sscratch, sp；csrrw s0, sscratch, x0实现了什么操作，目的是什么？save all里面保存了stval scause这些csr，而在restore all里面却不还原它们？那这样store的意义何在呢？

csrw sscratch, sp：这条汇编指令实际上是将堆栈指针寄存器 (sp) 的值写入到 sscratch 寄存器中。sscratch 是 RISC-V 中用于存储临时数据的一个特定寄存器，将没有向低地址延申的 sp 寄存器的值进行保存，目的是保存当前堆栈指针保存上下文以便在保存上下文的时候确保 sp 寄存器的值是触发异常后者中断前的值。

csrrw s0, sscratch, x0：这条指令实际上是将 sscratch 寄存器中的值读到 s0 中，并将 x0（零寄存器，始终为零）写入到 sscratch 中，其实就是将sscratch设置为0。将 sscratch 寄存器中的值加载到 s0 寄存器中，是为了保存上下文，即在切换上下文或处理异常时，方便后续使用该值。清零 sscratch 寄存器是为了确保在退出中断或陷入处理时，不会意外地使用 sscratch 中的值，避免潜在数据干扰。

$RESTORE\_ALL$中还原了spec寄存器和sstatues寄存器，但并没有还原sbadaddr和scause。其中sbadaddr寄存器用于存储当运行模式处于S态时，当发生地址错误的操作时，处理器会将错误的地址信息存储在sbadaddr寄存器中，而scause寄存器会将错误信息的原因代码存储，便于在后续的异常处理程序中确定异常类型。

以上两个寄存器没有还原的原因是：两个寄存器存储了错误地址与原因，一方面可以保存上下文，即如果异常处理流程没有正确完成，或者需要基于当前的异常状态进行额外的处理，直接还原stval和scause可能会引入错误或导致不确定的行为；另一方面一旦异常被处理，stval和scause中的信息通常就不再需要了。它们的值在异常处理完成后会被新的上下文或后续操作覆盖。

虽然没有还原，但store仍有意义——当异常发生时，CPU需要保存当前的执行状态，以便在异常处理完毕后能够恢复执行。stval和scause是这一过程中不可或缺的一部分，因为它们提供了关于为何发生异常以及异常处理可能需要的额外信息，并支持后续的异常处理。


## 遇到的问题与解决

在lab1 添加断点过程中，一开始发现找到两个中断后没有进行后面的timer interrupt。

后来通过gdb发现断电指令长度为2字节，对其进行调整后通过。

![](solve.png)

## 实验中涉及的重要知识点

### 进程管理
在 ucore 的进程管理中，进程的创建和调度是至关重要的。每个进程都有一个对应的 PCB，存储着该进程的状态信息、程序计数器、堆栈指针、内存映射及其他必要的进程元数据。uCore使用链表来管理多个 PCB，以便于进行调度和状态转换。上下文切换是进程间切换的核心，涉及到保存当前进程的状态和恢复下一个进程的状态。这不仅包括寄存器的保存和恢复，还可能涉及内存的切换。

### 内存管理
内存管理是系统稳定性和性能的基础，操作系统必须处理内存的动态分配和回收。

### 中断处理
中断是操作系统与硬件交互的桥梁， uCore 维护一个中断向量表，存储不同中断类型的处理程序地址。在中断发生时，处理硬件会根据中断码查询对应的处理函数。在中断处理完成后，uCore 需要能够安全地返回到被中断的上下文中。这涉及到状态恢复和上下文切换，以确保处理程序的顺利执行。

### 异常处理
异常处理机制对于系统的稳定性至关重要，uCore 需要区分培养一般性错误（例如，非法指令、除零等）与可恢复的错误（如页面缺失）。每种异常都有不同的响应策略。当发生异常时，uCore 需捕获当前处理器上下文并记录异常类型。随后转向相应的异常处理程序，以进行处理。在处理异常时，uCore 需要管理堆栈以保存处理状态，确保在处理完成后能够正确返回。对于可恢复的异常（如缺页），uCore 需要实现合理的恢复机制，如重新加载页面或重试操作；而对于不可恢复的异常，则应妥善终止进程，并进行相应的清理工作。

## 重要但暂未涉及的知识点

### 进程调度算法

ucore 可以实现多种调度算法，如轮询调度、优先级调度或多级反馈队列调度。选择合适的调度算法可以提高 CPU 利用率和响应时间。

### 动态内存分配

操作系统必须处理内存的动态分配和回收。uCore 使用伙伴系统或其他内存分配策略来管理空闲内存，并确保内存的高效使用，防止内存碎片的产生。