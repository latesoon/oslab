# lab3 操作系统实验报告

### 姚知言 2211290 贾景顺 2211312 李政远 2211320

### Exercise1：分配并初始化一个进程控制块

>alloc_proc函数（位于kern/process/proc.c中）负责分配并返回一个新的struct proc_struct结构，用于存储新建立的内核线程的管理信息。ucore需要对这个结构进行最基本的初始化，你需要完成这个初始化过程。

在proc.h头文件中，标记了proc_struct结构体的成员，分别为
```cpp {.line-numbers}
struct proc_struct {
    enum proc_state state;                      // Process state
    int pid;                                    // Process ID
    int runs;                                   // the running times of Proces
    uintptr_t kstack;                           // Process kernel stack
    volatile bool need_resched;                 // bool value: need to be rescheduled to release CPU?
    struct proc_struct *parent;                 // the parent process
    struct mm_struct *mm;                       // Process's memory management field
    struct context context;                     // Switch here to run process
    struct trapframe *tf;                       // Trap frame for current interrupt
    uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
    uint32_t flags;                             // Process flag
    char name[PROC_NAME_LEN + 1];               // Process name
    list_entry_t list_link;                     // Process link list 
    list_entry_t hash_link;                     // Process hash list
};
```
而在基本初始化过程中，我需要特别初始化三个成员，为proc->state = PROC_UNINIT;设置了进程的状态为“初始”态，这表示进程已经 “出生”了，正在获取资源茁壮成长中；
proc->pid = -1;设置了进程的pid为-1，这表示进程的“身份证号”还没有办好；
proc->cr3 = boot_cr3; 表明由于该内核线程在内核中运行，故采用为uCore内核已经建立的页表，即设置为在uCore内核页表的起始地址boot_cr3。后续实验中可进一步看出所有内核线程的内核虚地址空间（也包括物理地址空间）是相同的。既然内核线程共用一个映射内核空间的页表，这表示内核空间对所有内核线程都是“可见”的，所以更精确地说，这些内核线程都应该是从属于同一个唯一的“大内核进程”—uCore内核。
其他的则全部初始化为0即可。

>请在实验报告中简要说明你的设计实现过程。请回答如下问题：
请说明proc_struct中struct context context和struct trapframe *tf成员变量含义和在本实验中的作用是啥？（提示通过看代码和编程调试可以判断出来）

struct context context：储存进程当前状态，用于进程切换中上下文的保存与恢复。
struct trapframe tf：内核态中的线程返回用户态所加载的上下文，中断返回时，新进程会恢复保存的trapframe信息至各个寄存器中，然后开始执行用户代码。

### Exercise2：为新创建的内核线程分配资源

>创建一个内核线程需要分配和设置好很多资源。kernel_thread函数通过调用do_fork函数完成具体内核线程的创建工作。do_kernel函数会调用alloc_proc函数来分配并初始化一个进程控制块，但alloc_proc只是找到了一小块内存用以记录进程的必要信息，并没有实际分配这些资源。ucore一般通过do_fork实际创建新的内核线程。do_fork的作用是，创建当前内核线程的一个副本，它们的执行上下文、代码、数据都一样，但是存储位置不同。因此，我们实际需要"fork"的东西就是stack和trapframe。在这个过程中，需要给新内核线程分配资源，并且复制原进程的状态。你需要完成在kern/process/proc.c中的do_fork函数中的处理过程。它的大致执行步骤包括：
调用alloc_proc，首先获得一块用户信息块。
为进程分配一个内核栈。
复制原进程的内存管理信息到新进程（但内核线程不必做此事）
复制原进程上下文到新进程
将新进程添加到进程列表
唤醒新进程
返回新进程号


根据他的大致执行步骤给出代码
```cpp {.line-numbers}
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe* tf)
{
    int ret = -E_NO_FREE_PROC;
    struct proc_struct* proc;
    if (nr_process >= MAX_PROCESS)
    {
        goto fork_out;
    }

    ret = -E_NO_MEM;
    //LAB4:EXERCISE2 YOUR CODE
    //2211320 2211312 2211290
    if ((proc = alloc_proc()) == NULL) 
    {
        goto fork_out;
    }

    if (setup_kstack(proc) != 0)
    {
        goto bad_fork_cleanup_kstack;
    }

    if (copy_mm(clone_flags, proc) != 0)
    {
        goto bad_fork_cleanup_proc;
    }

    copy_thread(proc, stack, tf);

    bool inter_flag;
    local_intr_save(inter_flag);
    {
        proc->pid = get_pid();
        hash_proc(proc);  
        list_add(&proc_list, &(proc->list_link));
    }
    local_intr_restore(inter_flag);

    wakeup_proc(proc);
  
    ret = proc->pid;

fork_out:
    return ret;

bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
    goto fork_out;
}
```

>请在实验报告中简要说明你的设计实现过程。请回答如下问题：
请说明ucore是否做到给每个新fork的线程一个唯一的id？请说明你的分析和理由。
是。

(last_pid,nextsafe]这个区间是空闲的。
在函数get_pid中，如果静态成员last_pid小于next_safe，则当前分配的last_pid一定是安全的，即唯一的PID。
但如果last_pid大于等于next_safe，或者last_pid的值超过MAX_PID，则当前的last_pid就不一定是唯一的PID，此时就需要遍历proc_list，重新对last_pid和next_safe进行设置，为下一次的get_pid调用打下基础。
```cpp {.line-numbers}
// get_pid - alloc a unique pid for process
static int
get_pid(void) {
static_assert(MAX_PID > MAX_PROCESS);
struct proc_struct *proc;
list_entry_t *list = &proc_list, *le;
static int next_safe = MAX_PID, last_pid = MAX_PID;
if (++ last_pid >= MAX_PID) {
last_pid = 1;
goto inside;
}
if (last_pid >= next_safe) {
inside:
next_safe = MAX_PID;
repeat:
le = list;
while ((le = list_next(le)) != list) {
proc = le2proc(le, list_link);
if (proc->pid == last_pid) {
if (++ last_pid >= next_safe) {
if (last_pid >= MAX_PID)
last_pid = 1;
next_safe = MAX_PID;
goto repeat;
}
}
else if (proc->pid > last_pid && next_safe > proc->pid)
next_safe = proc->pid;
}
}
return last_pid;
}
```



### Exercise3：编写proc_run 函数

>proc_run用于将指定的进程切换到CPU上运行。它的大致执行步骤包括：
检查要切换的进程是否与当前正在运行的进程相同，如果相同则不需要切换。
禁用中断。你可以使用/kern/sync/sync.h中定义好的宏local_intr_save(x)和local_intr_restore(x)来实现关、开中断。
切换当前进程为要运行的进程。
切换页表，以便使用新进程的地址空间。/libs/riscv.h中提供了lcr3(unsigned int cr3)函数，可实现修改CR3寄存器值的功能。
实现上下文切换。/kern/process中已经预先编写好了switch.S，其中定义了switch_to()函数。可实现两个进程的context切换。
允许中断。

>请回答如下问题：
在本实验的执行过程中，创建且运行了几个内核线程？

### Challenge：说明语句local_intr_save(intr_flag);....local_intr_restore(intr_flag);是如何实现开关中断的？