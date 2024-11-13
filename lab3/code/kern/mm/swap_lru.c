﻿#include <defs.h>
#include <riscv.h>
#include <stdio.h>
#include <string.h>
#include <swap.h>
#include <swap_lru.h>
#include <list.h>


extern list_entry_t pra_list_head;

static int
_lru_init_mm(struct mm_struct* mm)
{
    list_init(&pra_list_head);
    mm->sm_priv = &pra_list_head;

    return 0;
}

static int
_lru_tick_event(struct mm_struct* mm)
{
    list_entry_t* head = (list_entry_t*)mm->sm_priv;  //head指向哨兵节点
    assert(head != NULL);  //֤确认head被初始化
    list_entry_t* entry = list_next(head); //第一节点
    while (entry != head)
    {
        struct Page* page = le2page(entry, pra_page_link);//entry指向页面
        pte_t* ptep = get_pte(mm->pgdir, page->pra_vaddr, 0);  //entry页面页表项
        if (*ptep & PTE_A)//判断A位是否为1
        {
            list_del(entry);
            list_add(head, entry);
            *ptep &= ~PTE_A;  //A换成0
            tlb_invalidate(mm->pgdir, page->pra_vaddr);
        }
        entry = list_prev(head);
    }
    cprintf("_lru_tick_event is called!\n");

    return 0;
}

static int
_lru_map_swappable(struct mm_struct* mm, uintptr_t addr, struct Page* page, int swap_in)
{

    list_entry_t* head = (list_entry_t*)mm->sm_priv;
    list_entry_t* entry = &(page->pra_page_link);

    assert(entry != NULL && head != NULL);
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
_lru_check_swap(struct mm_struct* mm)
{
    cprintf("write Virt Page c in lru_check_swap\n");
    *(unsigned char*)0x3000 = 0x0c;
    lru_tick_event(mm);
    assert(pgfault_num == 4);
    cprintf("write Virt Page a in lru_check_swap\n");
    *(unsigned char*)0x1000 = 0x0a;
    lru_tick_event(mm);
    assert(pgfault_num == 4);
    cprintf("write Virt Page d in lru_check_swap\n");
    *(unsigned char*)0x4000 = 0x0d;
    lru_tick_event(mm);
    assert(pgfault_num == 4);
    cprintf("write Virt Page b in lru_check_swap\n");
    *(unsigned char*)0x2000 = 0x0b;
    lru_tick_event(mm);
    assert(pgfault_num == 4);
    cprintf("write Virt Page e in lru_check_swap\n");
    *(unsigned char*)0x5000 = 0x0e;
    lru_tick_event(mm);
    assert(pgfault_num == 5);
    cprintf("write Virt Page b in lru_check_swap\n");
    *(unsigned char*)0x2000 = 0x0b;
    lru_tick_event(mm);
    assert(pgfault_num == 5);
    cprintf("write Virt Page a in lru_check_swap\n");
    *(unsigned char*)0x1000 = 0x0a;
    lru_tick_event(mm);
    assert(pgfault_num == 6);
    cprintf("write Virt Page b in lru_check_swap\n");
    *(unsigned char*)0x2000 = 0x0b;
    lru_tick_event(mm);
    assert(pgfault_num == 7);
    cprintf("write Virt Page c in lru_check_swap\n");
    *(unsigned char*)0x3000 = 0x0c;
    lru_tick_event(mm);
    assert(pgfault_num == 8);
    cprintf("write Virt Page d in lru_check_swap\n");
    *(unsigned char*)0x4000 = 0x0d;
    lru_tick_event(mm);
    assert(pgfault_num == 9);
    cprintf("write Virt Page e in lru_check_swap\n");
    *(unsigned char*)0x5000 = 0x0e;
    lru_tick_event(mm);
    assert(pgfault_num == 10);
    cprintf("write Virt Page a in lru_check_swap\n");
    assert(*(unsigned char*)0x1000 == 0x0a);
    *(unsigned char*)0x1000 = 0x0a;
    lru_tick_event(mm);
    assert(pgfault_num == 11);
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