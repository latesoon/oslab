# lab3 操作系统实验报告

### 姚知言 2211290 贾景顺 2211312 李政远 2211320

### Exercise0：填写已有实验

>本实验依赖实验2/3/4。请把你做的实验2/3/4的代码填入本实验中代码中有“LAB2”/“LAB3”/“LAB4”的注释相应部分。注意：为了能够正确执行lab5的测试应用程序，可能需对已完成的实验2/3/4的代码进行进一步改进。

在代码中对应的位置填入lab2-4的代码，值得注意的是，lab4中仅有两个内核进程需要进行创建和管理，对进程结构`proc_struct`的描述比较简单，而本实验涉及对用户进程的创建、管理等一系列操作，因此对该进程结构体中的成员变量进行了完善，因此需要对lab4中的代码进行部分更新，主要体现在两个方面：

#### 1.  进程分配函数`alloc_proc`

`proc_struct`中扩展了如下部分：

```
int exit_code;                              // exit code (be sent to parent proc)
uint32_t wait_state;                        // waiting state
struct proc_struct *cptr, *yptr, *optr;     // relations between processes
```
其中`exit_code`是退出状态码，用来传递给父进程；`wait_state`来描述进程是否处于等待状态`*cptr`,`*yptr`,`*optr`分别为进程的子进程指针和兄弟进程指针，需要在进程分配时对他们进行正确初始化，代码如下：
```
proc->wait_state=0;
proc->cptr=NULL;
proc->yptr=NULL;
proc->optr=NULL;
```
在分配的初始化过程中，将等待状态`wait_state`设为0,意为为处于等待状态，同时将子进程指针和兄弟进程指针均设为空指针。

#### 2.  进程创建函数`do_fork`

同样，由于用户态进程的引入，需要新增对父进程状态以及进程间关系维护的代码，具体改动如下：

```
current->wait_state = 0;
proc->parent = current;
.
.
.
//list_add(&proc_list, &(proc->list_link)); in set_links
set_links(proc);

```
首先需要将当前进程（也就是父进程）的等待状态设为0，确保其处于可调度状态，同时将新创建进程的父进程设为当前进程。在正确设置内核栈、共享内存、上下文及中断信息等后（省略号部分），需要将新进程插入到进程链表和哈希链表中，此处与lab4相比，还需要通过`set_links`额外设置新进程与其它进程的各类关系。
### Exercise1：加载应用程序并执行

>do_execv函数调用load_icode（位于kern/process/proc.c中）来加载并解析一个处于内存中的ELF执行文件格式的应用程序。你需要补充`load_icode`的第6步，建立相应的用户内存空间来放置应用程序的代码段、数据段等，且要设置好`proc_struct`结构中的成员变量trapframe中的内容，确保在执行此进程后，能够从应用程序设定的起始执行地址开始执行。需设置正确的trapframe内容。

#### 编程实现及解释

在`load_icode`函数中完善如下代码：

```
tf->gpr.sp=USTACKTOP;
tf->epc=elf->e_entry;
tf->status= sstatus & (~SSTATUS_SPP);
tf->status= (tf->status) | SSTATUS_SPIE;
```
这一串代码实现了对进程的`trapframe`相关内容的正确设置，保证程序的中断信息与其运行的初始状态一致，并对中断寄存器的相关位进行设置，下面我们来逐行解析：

`tf->gpr.sp=USTACKTOP;`将通用寄存器中的用户栈指针指向用户栈顶。

`tf->epc=elf->e_entry;`将用户程序的入口地址设置为elf文件的入口地址。

`tf->status= sstatus & (~SSTATUS_SPP);`将中断寄存器赋值给`trapframe`结构体，并清除SPP位，表示中断完成后进入用户态。

`tf->status= (tf->status) | SSTATUS_SPIE;`将寄存器中SPIE位置1,确保中断完成后打开中断开关。

#### 问题解答

>请简要描述这个用户态进程被ucore选择占用CPU执行（RUNNING态）到具体执行应用程序第一条指令的整个经过。

在本实验中第一个用户进程是由第二个内核线程initproc通过把hello应用程序执行码覆
盖到initproc的用户虚拟内存空间来创建的，initproc线程的执行主体是`init_main`函数，不同于lab4中的
一系列`print`语句，在本实验中它会通过`kernal_thread`函数，将程序执行流跳转到`user_main`，在缺省时执行宏KERNEL_EXECVE(hello)。
由于ld在链接hello应用程序执行码时定义了两全局变量：
_binary_obj___user_hello_out_start：hello执行码的起始位置；
_binary_obj___user_hello_out_size中：hello执行码的大小，
这两个参数随着宏最终调用`kernel_execve`函数，通过内联汇编，一并被传入到`SYS_exec`进行系统调用，当ucore收到此系统调用后，会执行一系列函数并最终调用`load_icode`函数，其主要工作就是给用户进程建立一个能够让用户进程正常运行的用户环境。
至此，用户进程的用户环境已经搭建完毕。此时initproc将按产生系统调用的函数调用路径原路返回.此时并不会直接开始执行刚刚建立完成的用户进程，而是继续执行`init_main`函数，在`while (do_wait(0, NULL) == 0) {schedule();}`中利用`do_wait`根据 pid 来查找子进程，如果找到了子进程`haskid == 1`，并且该子进程没有处于 `PROC_ZOMBIE` 状态，父进程将进入睡眠状态`PROC_SLEEPING`，并设置 `wait_state` 为 `WT_CHILD`，表示父进程正在等待子进程退出,同时在`schedule`中调度可运行的进程开始执行，即用户态进程开始正式执行。

### Exercise2：父进程复制自己的内存空间给子进程

>创建子进程的函数do_fork在执行中将拷贝当前进程（即父进程）的用户内存地址空间中的合法内容到新进程中（子进程），完成内存资源的复制。具体是通过copy_range函数（位于kern/mm/pmm.c中）实现的，请补充copy_range的实现，确保能够正确执行。

#### 编程实现及解释
在`copy_range`中补充代码如下

```
void *src_kvaddr = page2kva(page);
void *dst_kvaddr = page2kva(npage);
memcpy(dst_kvaddr, src_kvaddr, PGSIZE);
ret = page_insert(to, npage, start, perm);
```

上面四行代码中前两行通过`page2kva`函数分别获取源进程页和目标进程页的内核虚拟地址，随后通过`memcpy`函数，按照字符串逐字符复制，将源进程页的内核虚拟地址复制过去，以此来实现内容的复制。成功复制后，调用`page_insert`函数建立新复制过来的页的物理地址与虚拟地址`start`的页表项映射关系，其中传递的权限参数`perm`与源进程中的用户权限位一致。由于后面需要确保`ret=0`,以确定映射被正确建立，因此我们需要将`page_insert`的返回值赋值给ret。`page_insert`的函数定义如下：

```
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
    pte_t *ptep = get_pte(pgdir, la, 1);
    if (ptep == NULL) {
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_V) {
        struct Page *p = pte2page(*ptep);
        if (p == page) {
            page_ref_dec(page);
        } else {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
    tlb_invalidate(pgdir, la);
    return 0;
```

在该函数中，首先会找到虚拟地址的页表项`ptep`,并判定是否已经和将要建立映射的页建立了对应的映射关系。随后通过`pte_create`创建新的页表项，并将物理页号和权限信息写入。可以看到若是以上操作成功完成，函数将返回0，否则将返回错误代码。

#### 测试结果
运行`make qemu`以及`make grade`,均能得到正确的结果，如下图所示：

![](make_qemu.png)

![](make_grade.png)

#### 问题解答

>如何设计实现Copy on Write机制？给出概要设计，鼓励给出详细设计。
Copy-on-write（简称COW）的基本概念是指如果有多个使用者对一个资源A（比如内存块）进行读操作，则每个使用者只需获得一个指向同一个资源A的指针，就可以该资源了。若某使用者需要对这个资源A进行写操作，系统会对该资源进行拷贝操作，从而使得该“写操作”使用者获得一个该资源A的“私有”拷贝—资源B，可对资源B进行写操作。该“写操作”使用者对资源B的改变对于其他的使用者而言是不可见的，因为其他使用者看到的还是资源A。

详情请见Challenge1。

### Exercise3：阅读分析源代码，理解进程执行 `fork/exec/wait/exit` 的实现，以及系统调用的实现

>请在实验报告中简要说明你对 fork/exec/wait/exit函数的分析。并回答如下问题：
请分析fork/exec/wait/exit的执行流程。重点关注哪些操作是在用户态完成，哪些是在内核态完成？内核态与用户态程序是如何交错执行的？内核态执行结果是如何返回给用户程序的？

fork,exec,wait和exit中封装了系统调用函数，这四个函数操作都是在用户态完成的，而当用户态程序触发ebreak或者ecall中断时，会触发trap从而进入内核态，从而发起syscall系统调用，然后会对系统调用的函数进行分发，然后调用sys_fork等内核态运行的操作。  

对于syscall的调用，在tf的a0寄存器寄存了它的系统调用编号，然后它把寄存器里的参数取出来，转发给系统调用编号对应的函数进行处理。  

fork是用户态的一个接口函数，他在ulib.c中实现，具体为调用了sys_fork()，而sys_fork()在syscall.c中被调用，此时为调用syscall(SYS_fork)，而通过SYS_fork的编号，调用do_fork(0, stack, tf)，最终导向了do_fork()函数，创建并初始化了一个新的PCB，初始化一个新的PID，并且设置新的进程状态为UNINIT。实际上是在用户态通过使用系统调用运行内核态的过程。  

wait跟fork同理，也是用户态的一个接口函数，在ulib.c中实现，具体为调用了sys_wait(0, NULL)，而sys_wait(0, NULL)在syscall.c中被调用，此时为调用syscall(SYS_wait)，而通过SYS_wait的编号，调用do_wait(pid, store)，最终导向了do_wait()函数,而do_wait()函数为，当前进程若无子进程,则返回错误;若有子进程,则判定是否为 ZOMBIE 子进程,有则释放子进程的资源,并返回子进程的返回状态码; 若无 ZOMBIE 状态子进程, 则进入 SLEEPING 状态,等子进程唤醒。

exec的形式直接为sys_exec(),封装了do_execve(name, len, binary, size)，作用为调用exit_mmap(mm)&put_pgdir(mm)清除了当前进程的内存布局，再通过调用load_icode，读取ELF映像中的内存布局并且填写，保持进程状态不变，

exit 为清除当前进程几乎所有资源(PCB和内核栈不清除), 将所有子进程(如果有的话)设置为 init 进程(内核), 将当前进程状态设置为 ZOMBIE; 若有父进程在等待当前进程。

具体来说，用户态调用fork等函数，并触发trap进入内核态，根据寄存器参数分发相应的函数指针，触发系统调用的相关函数，类似于sys_exit等，调用完成后内核态通过sret返回用户态，实现交错执行.  

在这些系统调用的执行流程中，用户态和内核态之间的切换是关键的。当用户程序执行系统调用时，会触发从用户态切换到内核态，让操作系统执行相关的内核代码。在系统调用完成后，操作系统会将控制权切回到用户态，让用户程序继续执行。  

>请给出ucore中一个用户态进程的执行状态生命周期图（包执行状态，执行状态之间的变换关系，以及产生变换的事件或函数调用）。（字符方式画即可） 
 
```cpp {.line-numbers}
                                                      ↑ ↑--------->|  |
                                                      | |          ↓  ↓ 
init_main()--> kernel_thread() -->PROC_UNINIT --wakeup_proc()--> RUNNABLE --> exit() --> PROC_ZOMBIE
                                                      | |           |  |                   ↑ ↑
                                                      | |           ↓  ↓                   | |
                                                      | |         do_wait()                | |
                                                      | |           |  |                   ↑ ↑
                                                      ↑ ↑           ↓  ↓                   | |
                                                  pid != 0 <--PROC_SLEEPING --> exit() --> | |
```

### Chellenge1：实现 Copy on Write （COW）机制

>给出实现源码,测试用例和设计报告（包括在cow情况下的各种状态转换（类似有限状态自动机）的说明）。
这个扩展练习涉及到本实验和上一个实验“虚拟内存管理”。在ucore操作系统中，当一个用户父进程创建自己的子进程时，父进程会把其申请的用户空间设置为只读，子进程可共享父进程占用的用户内存空间中的页面（这就是一个共享的资源）。当其中任何一个进程修改此用户内存空间中的某页面时，ucore会通过page fault异常获知该操作，并完成拷贝内存页面，使得两个进程都有各自的内存页面。这样一个进程所做的修改不会被另外一个进程可见了。请在ucore中实现这样的COW机制。
由于COW实现比较复杂，容易引入bug，请参考 https://dirtycow.ninja/ 看看能否在ucore的COW实现中模拟这个错误和解决方案。需要有解释。

### Chellenge2：说明该用户程序是何时被预先加载到内存中的？与我们常用操作系统的加载有何区别，原因是什么？
