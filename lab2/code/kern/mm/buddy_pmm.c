#include <pmm.h>
#include <list.h>
#include <string.h>
#include <buddy_pmm.h>
#include <stdio.h>

extern free_area_t free_area;

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static inline size_t up_bound2(size_t x){
	size_t i=1;
	while(i<x) i<<=1;
	return i;
}
static void
buddy_init(void) {
    list_init(&free_list);
    nr_free = 0;
}

static void
buddy_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    size_t flag=0;
    for (; p != base + n; p++) {
        assert(PageReserved(p));
        // 清除当前页框的标志和属性信息，并将页框的引用计数设置为0
        p->property = 0;
        p->flags = flag;
        flag++;
        set_page_ref(p, 0);
    }
    // 初始化第一个块，并设置块大小
    base->property = up_bound2(n)<<1;
    //SetPageProperty(base);
    nr_free += up_bound2(n)<<1;
    // 根据 buddy 系统划分块大小
    struct Page *block = base;
    list_add(&free_list, &(base->page_link)); 
}

static struct Page *
buddy_alloc_pages(size_t n) { 
    assert(n > 0);
    if (n > nr_free) {
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;

    size_t need = up_bound2(n);  // 获取需要分配的阶次

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
            //SetPageProperty(buddy);
            list_add(&free_list, &(buddy->page_link));
            page->property>>=1;
        }
        // 从空闲列表中删除分配的块
        list_del(&(page->page_link));
        //ClearPageProperty(page);
    }
    return page;
    
}

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
   	        //ClearPageProperty(buddy);
  	        order<<=1;
   	 	}
   	 	p->property=order;
   	 	//SetPageProperty(p);
    	// 将合并后的块放入空闲链表
    	list_add(&free_list, &(p->page_link));
    }
}

static size_t
buddy_nr_free_pages(void) {
    return nr_free;
}

static void
buddy_check(void) {

	cprintf("testcase1 begin!\n");
	
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
    
    cprintf("testcase1 finish!\n");
    
    cprintf("testcase2 begin!\n");

    p0 = p1 = p2 = NULL;
    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    assert(p0 != p1 && p0 != p2 && p1 != p2);
    
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);

    assert(page2pa(p0) < npage * PGSIZE);
    assert(page2pa(p1) < npage * PGSIZE);
    assert(page2pa(p2) < npage * PGSIZE);

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    assert(alloc_page() == NULL);

    free_page(p0);
    free_page(p1);
    free_page(p2);
    assert(nr_free == 3);

    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);


    assert(alloc_page() == NULL);

    free_page(p0);
    assert(!list_empty(&free_list));

    struct Page *p;
    assert((p = alloc_page()) == p0);
    assert(alloc_page() == NULL);

    assert(nr_free == 0);
    free_list = free_list_store;
    nr_free = nr_free_store;

    free_page(p0);
    free_page(p1);
    free_page(p2);
    
    cprintf("testcase2 finish!\n");
}

const struct pmm_manager buddy_pmm_manager = {
    .name = "buddy_pmm_manager",
    .init = buddy_init,
    .init_memmap = buddy_init_memmap,
    .alloc_pages = buddy_alloc_pages,
    .free_pages = buddy_free_pages,
    .nr_free_pages = buddy_nr_free_pages,
    .check = buddy_check,
};
