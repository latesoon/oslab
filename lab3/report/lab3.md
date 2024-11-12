# lab3 操作系统实验报告

### 姚知言 2211290 贾景顺 2211312 李政远 2211320

### Exercise1：理解基于FIFO的页面替换算法

>描述FIFO页面置换算法下，一个页面从被换入到被换出的过程中，会经过代码里哪些函数/宏的处理（或者说，需要调用哪些函数/宏），并用简单的一两句话描述每个函数在过程中做了什么？（为了方便同学们完成练习，所以实际上我们的项目代码和实验指导的还是略有不同，例如我们将FIFO页面置换算法头文件的大部分代码放在了`kern/mm/swap_fifo.c`文件中，这点请同学们注意）
至少正确指出10个不同的函数分别做了什么？如果少于10个将酌情给分。我们认为只要函数原型不同，就算两个不同的函数。要求指出对执行过程有实际影响,删去后会导致输出结果不同的函数（例如assert）而不是cprintf这样的函数。如果你选择的函数不能完整地体现“从换入到换出”的过程，比如10个函数都是页面换入的时候调用的，或者解释功能的时候只解释了这10个函数在页面换入时的功能，那么也会扣除一定的分数。

### Exercise2：深入理解不同分页模式的工作原理

>get_pte()函数（位于`kern/mm/pmm.c`）用于在页表中查找或创建页表项，从而实现对指定线性地址对应的物理页的访问和映射操作。这在操作系统中的分页机制下，是实现虚拟内存与物理内存之间映射关系非常重要的内容。
get_pte()函数中有两段形式类似的代码， 结合sv32，sv39，sv48的异同，解释这两段代码为什么如此相像。
目前get_pte()函数将页表项的查找和页表项的分配合并在一个函数里，你认为这种写法好吗？有没有必要把两个功能拆开？

### Exercise3：给未被映射的地址映射上物理页

>补充完成do_pgfault（mm/vmm.c）函数，给未被映射的地址映射上物理页。设置访问权限 的时候需要参考页面所在 VMA 的权限，同时需要注意映射物理页时需要操作内存控制 结构所指定的页表，而不是内核的页表。
请在实验报告中简要说明你的设计实现过程。请回答如下问题：
请描述页目录项（Page Directory Entry）和页表项（Page Table Entry）中组成部分对ucore实现页替换算法的潜在用处。
如果ucore的缺页服务例程在执行过程中访问内存，出现了页访问异常，请问硬件要做哪些事情？
数据结构Page的全局变量（其实是一个数组）的每一项与页表中的页目录项和页表项有无对应关系？如果有，其对应关系是啥？

#### 编程实现及解释
```cpp {.line-numbers}
/*LAB3 EXERCISE 3: 2211290 2211312 2211320
* 请你根据以下信息提示，补充函数
* 现在我们认为pte是一个交换条目，那我们应该从磁盘加载数据并放到带有phy addr的页面，
* 并将phy addr与逻辑addr映射，触发交换管理器记录该页面的访问情况
*
*  一些有用的宏和定义，可能会对你接下来代码的编写产生帮助(显然是有帮助的)
*  宏或函数:
*    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
*    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
*    page_insert ： 建立一个Page的phy addr与线性addr la的映射
*    swap_map_swappable ： 设置页面可交换
*/
if (swap_init_ok) {
    struct Page *page = NULL;
    // 你要编写的内容在这里，请基于上文说明以及下文的英文注释完成代码编写
    //(1）According to the mm AND addr, try
    //to load the content of right disk page
    //into the memory which page managed.
    //(2) According to the mm,
    //addr AND page, setup the
    //map of phy addr <--->
    //logical addr
    //(3) make the page swappable.
    swap_in(mm, addr, &page);
    page_insert(mm->pgdir, page, addr, perm);
    swap_map_swappable(mm, addr, page, 1);
    page->pra_vaddr = addr;
} 
else {
    cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
    goto failed;
}
```

#### 问题解答

### Exercise4：补充完成Clock页替换算法

>通过之前的练习，相信大家对FIFO的页面替换算法有了更深入的了解，现在请在我们给出的框架上，填写代码，实现 Clock页替换算法（mm/swap_clock.c）。(提示:要输出curr_ptr的值才能通过make grade)
请在实验报告中简要说明你的设计实现过程。请回答如下问题：
比较Clock页替换算法和FIFO算法的不同。

#### 编程实现及解释

- _clock_init_mm函数 
```cpp {.line-numbers}
static int _clock_init_mm(struct mm_struct *mm)
{    
     // 初始化pra_list_head为空链表
     // 初始化当前指针curr_ptr指向pra_list_head，表示当前页面替换位置为链表头
     // 将mm的私有成员指针指向pra_list_head，用于后续的页面替换算法操作
     list_init(&pra_list_head);
     curr_ptr = &pra_list_head;
     mm->sm_priv = &pra_list_head;
     return 0;
}
```
- _clock_map_swappable函数
```cpp {.line-numbers}
static int _clock_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
    list_entry_t *entry=&(page->pra_page_link);
 
    assert(entry != NULL && curr_ptr != NULL);
    //record the page access situlation
    // link the most recent arrival page at the back of the pra_list_head qeueue.
    // 将页面page插入到页面链表pra_list_head的末尾
    // 将页面的visited标志置为1，表示该页面已被访问
    list_add((&pra_list_head) -> prev, entry);
    page->visited=1;
    return 0;
}
```
- _clock_swap_out_victim函数
```cpp {.line-numbers}
static int _clock_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
         assert(head != NULL);
     assert(in_tick==0);
     /* Select the victim */
     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
     //(2)  set the addr of addr of this page to ptr_page  
    while (1) {
        // 遍历页面链表pra_list_head，查找最早未被访问的页面
        // 获取当前页面对应的Page结构指针
        // 如果当前页面未被访问，则将该页面从页面链表中删除，并将该页面指针赋值给ptr_page作为换出页面
        // 如果当前页面已被访问，则将visited标志置为0，表示该页面已被重新访问
        struct Page * next_ptr = list_next(curr_ptr);
        if(curr_ptr != &pra_list_head){
        	struct Page * page = le2page(curr_ptr, pra_page_link);
        	if(!(page->visited)){
            	list_del(curr_ptr);
            	*ptr_page = page;
            	cprintf("curr_ptr %p\n",curr_ptr);
            	curr_ptr=next_ptr;
            	break;
            }
            page->visited=0;
        }
        curr_ptr=next_ptr;
    }
    return 0;
}
```

#### 测试结果

通过make grade获取成绩。成功通过了所有check要求，得分45/45。

![](grade.png)

#### 问题解答

### Exercise5：阅读代码和实现手册，理解页表映射方式相关知识

>如果我们采用”一个大页“ 的页表映射方式，相比分级页表，有什么好处、优势，有什么坏处、风险？

### Challenge：实现不考虑实现开销和效率的LRU页替换算法

该部分的设计文档单独建立了markdown文件，请参阅lab3 swap-lru.md。