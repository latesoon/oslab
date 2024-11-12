# lab3 swap-lru 设计文档

### 李政远 2211320
## 设计原理

LRU（Least Recently Used）是一种常见的页面替换算法，用于内存管理，特别是在虚拟内存系统中。当物理内存不足时，LRU算法会选择最长时间未被访问的页面进行替换，以腾出空间给新的页面。
LRU算法的核心设计原理是，优先替换在一段时间内最长时间未被访问的页面，因为我们认为最长时间未被访问的页面在未来被访问的可能性最低，因此优先替换这些页面。
整体操作思路为基于时钟系统，在时钟系统刷新时，系统会记录每个页面的Access位来判断是否被访问，最久未被访问的页面会被标记为LRU页面，也就是放在链表的最前端。
而当需要新的物理内存空间时，系统会选择标记为LRU的页面进行替换。

## 核心设计说明：如何实现LRU页面判定
Page结构体可以在memlayout.h中找到详细定义。

```cpp {.line-numbers}
struct Page {
    int ref;                        // page frame's reference counter
    uint64_t flags;                 // array of flags that describe the status of the page frame
    unsigned int property;          // the num of free block, used in first fit pm manager
    list_entry_t page_link;         // free list link
};
```
可以看到，unsigned int类型变量flags原本的用途是标志页帧状态。但该功能在先前实验中并没有被真正使用。在本设计中，我将借用flags的部分位，用于存储页的位置属性，帮助其匹配兄弟页块。

匹配原理为：在初始化过程中，为每个页的flags进行连续赋值，即第一个页面的flags为0，第二个为1，第三个为2，以此类推。

考虑这一问题：因为page指针永远指向空闲页块的开头。

考虑一个简单的页数为8的buddy系统，每个块里面的数字表示了它的flags。

![](buddy.png)

假设我现在要释放的空闲页块大小为1，那么他的兄弟块的flags应该仅仅最后一位与其不同，而其他位完全相同。

若空闲页块大小为4，则其flags后两位应该为0，而倒数第三位则于他的兄弟块不同，其他位应于他的兄弟块相同。

由此，我们就得到了一个基于flags的简单通过异或找到兄弟块的方法。

此处的order表示是要释放的空闲块的大小。
```cpp {.line-numbers}
if (q->flags == (p->flags ^ (order))) {
    buddy = q;
    break;
}
```

## 编程实现

### pmm.c
```cpp {.line-numbers}
#include <buddy_pmm.h>
```

在pmm.c中增加buddy_pmm头文件include，便于后续测试。

### buddy_pmm.h
```cpp {.line-numbers}
#ifndef __KERN_MM_BUDDY_PMM_H__
#define  __KERN_MM_BUDDY_PMM_H__

#include <pmm.h>

extern const struct pmm_manager buddy_pmm_manager;

#endif /* ! __KERN_MM_BUDDY_PMM_H__ */
```
与先前分配方法类似，完成pmm_manager结构体声明。

### buddy_pmm.c
```cpp {.line-numbers}
#include <pmm.h>
#include <list.h>
#include <string.h>
#include <buddy_pmm.h>
#include <stdio.h>

extern free_area_t free_area;

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)
```
与先前分配方法类似的库引用和宏定义。

```cpp {.line-numbers}
static inline size_t up_bound2(size_t x){
	size_t i=1;
	while(i<x) i<<=1;
	return i;
}
```
静态内联函数up_bound2，作用是对于一个页块的页数（要求分配的，初始化的等），取得大于等于其的最小的2的幂次。这与buddy_system对页的存储块大小必须是2的幂次对应。

```cpp {.line-numbers}
static void
buddy_init(void) {
    list_init(&free_list);
    nr_free = 0;
}
```
初始化函数。建立空闲页块链表，初始化空闲页数为0。

```cpp {.line-numbers}
static void
buddy_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    size_t flag=0;
    for (; p != base + n; p++) {
        assert(PageReserved(p));
        // 清除当前页框的属性信息，更新标志，并将页框的引用计数设置为0
        p->property = 0;
        p->flags = flag;
        flag++;
        set_page_ref(p, 0);
    }
    // 初始化第一个块，并设置块大小
    base->property = up_bound2(n)>>1;
    //SetPageProperty(base);
    nr_free += up_bound2(n)>>1;
    // 根据 buddy 系统划分块大小
    struct Page *block = base;
    list_add(&free_list, &(base->page_link)); 
}
```
页分配初始化函数。

1.  首先检查页的数量是否大于0，否则无法进行分配。

2.  对每个页框，清除属性信息和引用计数，并更新标志。

3.  初始化第一个块进入空闲链表，并更新nr_free（为保证所有分配都是合法的，这里使用总分配大小为小于等于可分配内存的最大2的幂次作为base块的大小。）

```cpp {.line-numbers}
static struct Page *
buddy_alloc_pages(size_t n) { 
    assert(n > 0);
    if (n > nr_free) {
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;

    size_t need = up_bound2(n);  // 获取需要分配的块大小

    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        if (p->property >= need && (page == NULL || p->property < page->property)) {
            page = p;
        }
    }
    // 如果找到的块比需要的大，则拆分块
    if (page != NULL) {
    	nr_free -= need;
        while (page->property > need) {
            // 拆分块，减少阶次
            struct Page *buddy = page + (page->property >> 1);
            buddy->property = page->property >> 1;
            list_add(&free_list, &(buddy->page_link));
            page->property>>=1;
        }
        // 从空闲列表中删除分配的块
        list_del(&(page->page_link));
    }
    return page;
}
```
页分配函数。

1.  （1-2行）首先检查要分配的页数量是否大于0（若大于，直接报错），是否小于等于当前的空闲页数量（若小于，直接返回分配失败）。
2.  （5行）通过up_bound2函数计算获取实际要分配的块大小。
3.  （12-17行）从空闲链表中找到一个满足要求的最小块。
4.  （19-29行）在找到块的情况下，若找到的块比需要的块大，则进行拆分，将兄弟块链入空闲链表中，重复该过程直到找到大小刚好的块。并释放分配的块。
5.  将找到的页块（若没找到，则为空指针）的指针返回。
```cpp {.line-numbers}
static void
buddy_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    for(size_t i=0;i<n;i++){
    	struct Page *p = base+i;
    	nr_free += 1;
    	// 检查伙伴块是否可以合并
    	size_t order=1;
    	while ((order<<1) < nr_free) {
       	    struct Page *buddy = NULL;
    	    list_entry_t *le = &free_list;

    	    while ((le = list_next(le)) != &free_list) {
        		struct Page *q = le2page(le, page_link);
        		if (q->flags == (p->flags ^ (order))) {
        		    buddy = q;
        		    break;
 	       		}
 	  	    }
  	 		if (buddy ==NULL)break;
  	        // 如果伙伴块也是空闲的，则进行合并
  	        if(p->flags > buddy->flags)
  	        	p = buddy;
   	        list_del(&(buddy->page_link));
  	        order<<=1;
   	 	}
   	 	p->property=order;
    	// 将合并后的块放入空闲链表
    	list_add(&free_list, &(p->page_link));
    }
}
```
页释放函数。
1.  根据要释放的页的指针和页数，逐页进行释放。
2.  （6行）对于每一个释放的页，更新nr_free。
3.  循环遍历空闲链表，寻找伙伴块（14-19行），若未找到退出循环（20行），若找到则将伙伴块从链表中删除并合并，更新新的页指针（22-24行），更新释放块大小（25行）。
4.  将合并后的块链入空闲链表。
```cpp {.line-numbers}
static size_t
buddy_nr_free_pages(void) {
    return nr_free;
}
```
查找空闲页数函数。
```cpp {.line-numbers}
const struct pmm_manager buddy_pmm_manager = {
    .name = "buddy_pmm_manager",
    .init = buddy_init,
    .init_memmap = buddy_init_memmap,
    .alloc_pages = buddy_alloc_pages,
    .free_pages = buddy_free_pages,
    .nr_free_pages = buddy_nr_free_pages,
    .check = buddy_check,
};
```
头文件对应的结构体接口。

## 测试设计及结果

整体测试函数设计如下。
```cpp {.line-numbers}
static void
buddy_check(void) {

    cprintf("testcase1 begin!\n");
	
    //自己设计的测试部分
    
    cprintf("testcase1 finish!\n");
    
    cprintf("testcase2 begin!\n");

    //原有的basic_check
    
    cprintf("testcase2 finish!\n");
}
```
其中，自己设计的测试部分如下。
```cpp {.line-numbers}
    struct Page *p0, *p1, *p2, *p3;

    assert((p0 = alloc_pages(2)) != NULL);
    assert((p1 = alloc_pages(4)) != NULL);
    assert((p2 = alloc_pages(2)) != NULL);
    
    assert(p0 + 4 == p1);
    assert(p0 + 2 == p2);
    
    free_pages(p0,4);
    free_pages(p1,4);
    
    assert((p0 = alloc_pages(2)) != NULL);
    assert((p1 = alloc_pages(4)) != NULL);
    assert((p3 = alloc_pages(2)) != NULL);
    
    assert(p0 + 4 == p1);
    assert(p0 + 2 == p2);
    assert(p2 == p3);
    
    free_pages(p0,8);
    
    assert((p0 = alloc_pages(4)) != NULL);
    assert((p1 = alloc_pages(8)) != NULL);
    assert((p2 = alloc_pages(16)) != NULL);
    
    assert(p0 + 8 == p1);
    assert(p0 + 16 == p2);
    
    free_pages(p0,4);
    free_pages(p1,8);
    free_pages(p2,16);
    
    assert((p0 = alloc_pages(4)) != NULL);
    assert((p1 = alloc_pages(8)) != NULL);
    assert((p2 = alloc_pages(4)) != NULL);
    
    free_pages(p0,4);
    
    assert((p0 = alloc_pages(8)) != NULL);
    assert(p2 + 12 == p0);
    
    free_pages(p0,8);
    
    assert((p0 = alloc_pages(4)) != NULL);
    assert(p2 - 4 == p0);
    
    free_pages(p0,4);
```

该程序进行了多轮分配，除去对每一轮分配成功的确认，还增加了对各次分配返回指针位置的比较，以验证buddy分配功能。

第一轮（3-11行）进行2，4，2的分配，根据buddy程序设计，后两次分配应该分配的是在第一次分配中拆分出来的唯一块。因此，分配结果中p2应等于p0+2，p1应等于p0+4。

![](buddy1.png)

第二轮（13-21行）结构与第一轮相同，主要验证释放的正确性，增加了同一位置指针赋值的比较。验证新的指针成功分配到了刚刚释放的内存空间。

第三轮（23-32行）则是一个4，8，16的分配，同样通过比较指针位置验证功能。

第四轮（34-48行）是一个对p0重复分配释放的一次边分配边释放的测试，更加全面的验证功能。

在执行结束后，再进行原本的basic_check，进一步验证。

测试结果如下：

![](buddy2.png)

可以看到，验证成功。

## 总结

相比于first-fit和best-fit，buddy分配系统能够很好的降低内存碎片化的问题，使得系统更加高效，更好的利用内存。