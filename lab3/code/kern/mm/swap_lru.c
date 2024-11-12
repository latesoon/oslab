#include <defs.h>
#include <riscv.h>
#include <stdio.h>
#include <string.h>
#include <swap.h>
#include <swap_fifo.h>
#include <list.h>


extern list_entry_t pra_list_head;

static int
_lru_init_mm(struct mm_struct* mm)
{
    list_init(&pra_list_head);
    mm->sm_priv = &pra_list_head;
  
    return 0;
}

static int _lru_map_swappable(struct mm_struct* mm, uintptr_t addr, struct Page* page, int swap_in) {
    list_entry_t* head = (list_entry_t*)mm->sm_priv;
    list_entry_t* entry = &(page->pra_page_link);
    assert(entry != NULL && head != NULL);

    // 如果链表为空，直接将页面添加到头部
    if (list_empty(head)) {
        list_add(head, entry);
        return 0;
    }

    // 遍历链表，查找页面是否已经在链表中
    list_entry_t* curr_ptr = list_next(head); // 假设 head 是虚拟头节点，next 指向第一个实际节点
    while (curr_ptr != head) { // 遍历直到回到链表头部
        if (le2page(curr_ptr, pra_page_link) == page) {
            list_del(curr_ptr); // 删除找到的页面节点
            break; // 跳出循环
        }
        curr_ptr = list_next(head); // 移动到下一个节点
    }

    // 无论页面之前是否在链表中，都将其添加到头部
    list_add(head, entry);
    return 0;
}

static int
_lru_swap_out_victim(struct mm_struct* mm, struct Page** ptr_page, int in_tick)
{
    list_entry_t* head = (list_entry_t*)mm->sm_priv;
    assert(head != NULL);
    assert(in_tick == 0);
    list_entry_t* entry = list_prev(head);
    if (entry != head) {
        list_del(entry);
        *ptr_page = le2page(entry, pra_page_link);
    }
    else {
        *ptr_page = NULL;
    }
    return 0;
}

static int
_lru_check_swap(void) {
    cprintf("write Virt Page c in fifo_check_swap\n");
    *(unsigned char*)0x3000 = 0x0c;
    assert(pgfault_num == 4);
    cprintf("write Virt Page a in fifo_check_swap\n");
    *(unsigned char*)0x1000 = 0x0a;
    assert(pgfault_num == 4);
    cprintf("write Virt Page d in fifo_check_swap\n");
    *(unsigned char*)0x4000 = 0x0d;
    assert(pgfault_num == 4);
    cprintf("write Virt Page b in fifo_check_swap\n");
    *(unsigned char*)0x2000 = 0x0b;
    assert(pgfault_num == 4);
    cprintf("write Virt Page e in fifo_check_swap\n");
    *(unsigned char*)0x5000 = 0x0e;
    assert(pgfault_num == 5);
    cprintf("write Virt Page d in fifo_check_swap\n");
    *(unsigned char*)0x4000 = 0x0d;
    assert(pgfault_num == 5);
    return 0;
}


static int
_lru_init(void)
{
    return 0;
}

static int
_lru_set_unswappable(struct mm_struct* mm, uintptr_t addr)
{
    return 0;
}

static int
_lru_tick_event(struct mm_struct* mm)
{
    return 0;
}


struct swap_manager swap_manager_lru =
{
     .name = "lru swap manager",
     .init = &_lru_init,
     .init_mm = &_lru_init_mm,
     .tick_event = &_lru_tick_event,
     .map_swappable = &_lru_map_swappable,
     .set_unswappable = &_lru_set_unswappable,
     .swap_out_victim = &_lru_swap_out_victim,
     .check_swap = &_lru_check_swap,
};