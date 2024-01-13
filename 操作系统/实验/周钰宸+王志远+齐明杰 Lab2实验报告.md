<h1 align = "center">操作系统实验报告</h1>

<h3 align = "center">实验名称：物理内存和页表    实验地点：图书馆324</h3>

<h4 align = "center">组号：56      小组成员：周钰宸  王志远  齐明杰</h4>

## 一、实验目的

- 理解页表的建立和使用方法
- 理解物理内存的管理方法
- 理解页面分配算法

​	实验一过后我们做出来了一个可以启动的系统，实验二主要涉及操作系统的物理内存管理。操作系统为了使

用内存，还需高效地管理内存资源。本次实验我们会了解如何发现系统中的物理内存，然后学习如何建立对

物理内存的初步管理，即了解连续物理内存管理，最后掌握页表相关的操作，即如何建立页表来实现虚拟内

存到物理内存之间的映射，帮助我们对段页式内存管理机制有一个比较全面的了解。本次的实验主要是在实

验一的基础上完成物理内存管理，并建立一个最简单的页表映射

## 二、实验过程

### 1.练习1:**理解** **first-fit** **连续物理内存分配算法**

略

#### QA:你的 first fit 算法是否有进一步的改进空间？

首次适应算法（First Fit）是一种简单且常用的内存分配策略，但确实存在改进的空间。以下是一些可以考虑的改进点：

1. **搜索优化**：
	- 在大型系统中，遍历空闲列表可能会导致性能瓶颈。可以使用**平衡树**或其他高级数据结构来加速搜索过程，但**建立平衡树需要付出一定的代价**，需要综合考虑。
2. **延迟合并**：
	- 当释放页面时，不立即执行合并，而是周期性地执行合并操作，这样可以减少高负载下的性能开销。
3. **分层管理**：
	- 将内存分为多个层次，每个层次有其特定大小的块，即使用**十字链表**类似结构来完成页块的存储。这种方式可以快速找到合适大小的块，减少搜索时间。
4. **预分配和预释放**：
	- 条件允许，可以根据系统的历史负载信息和当前的使用模式，预测将来可能的分配和释放操作，提前进行，从而提高运行时性能。
5. **使用缓存机制**：
	- 对于频繁分配和释放的小块，可以使用一个缓存机制，来加速这些常见的操作。

### 2.练习2:**实现** **Best-Fit** **连续物理内存分配算法**

在Best-Fit代码中，几个函数需要进行填写或修改(TODO注释之间即为完成的代码)：

- **static** **void** best_fit_init_memmap(**struct** Page *****base, **size_t** n)

​	在初始化函数，我们需要分配n个页作为一个页块，对于其中的每个页，均由结构体表示：

```c
struct Page {
    int ref;                       
    uint64_t flags;             
    unsigned int property;         
    list_entry_t page_link;        
};
```

​	对于连续的n个页组成的空闲页块，我们只需要把第一个页设置`property=n`，且设置property标志位(与前述property含义不同)，而对于后续所有页，均**清空当前页框的标志和属性信息，并将页框的引用计数设置为0**即可。

​	初始化n个页组成的空闲页块后，我们需要将其插入到空闲链表中，需要分为两种情况处理：

- 空表为空：

此时空表只有一个元素，其前向指针和后向指针均指向同一个地址(未知)，直接让其后向指针指向该块即可(即后插)。

- 空表不为空：

由于链表的页存储按地址排序，故需要依次遍历，直到遇到大于该初始化块的地址的块，将其插入到这个块的前面，即可完成插入。如果遍历完整个链表均遇不到大于该地址的块，插入链表末尾即可。

​	据此可以完成下面的代码：

```c
static void best_fit_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(PageReserved(p));
        /*LAB2 EXERCISE 2: YOUR CODE*/ 
        // 清空当前页框的标志和属性信息，并将页框的引用计数设置为0
        // TODO -------------------------
        p->flags = p->property = 0;
        set_page_ref(p, 0);
        // TODO -------------------------
    }
    base->property = n;
    SetPageProperty(base);
    nr_free += n;
    if (list_empty(&free_list)) {
        list_add(&free_list, &(base->page_link));
    } else {
        list_entry_t* le = &free_list;
        while ((le = list_next(le)) != &free_list) {
            struct Page* page = le2page(le, page_link);
             /*LAB2 EXERCISE 2: 2113997*/ 
            // 编写代码
            // 1、当base < page时，找到第一个大于base的页，将base插入到它前面，并退出循环
            // 2、当list_next(le) == &free_list时，若已经到达链表结尾，将base插入到链表尾部
            // TODO -------------------------
            if (base < page){
                list_add_before(le, &(base->page_link));
                break;
            }
            else if (list_next(le) == &free_list){
                list_add_after(le, &(base->page_link));
            }
            // TODO -------------------------
        }
    }
}
```

- **static** **struct** Page ***** best_fit_alloc_pages(**size_t** n)

Best Fit和First Fit的重要区别在于分配块时，前者遍历整个空闲链表，找到满足所需大小的**最小的**空闲块，而后者只需找到满足所需大小的**第一个**空闲块，因此使用一个变量`min_size`来记录满足要求的最小property值，即可完成下面的代码：

```c
static struct Page * best_fit_alloc_pages(size_t n) {
    assert(n > 0);
    if (n > nr_free) {
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    size_t min_size = nr_free + 1;
     /*LAB2 EXERCISE 2: YOUR CODE*/ 
    // 下面的代码是first-fit的部分代码，请修改下面的代码改为best-fit
    // 遍历空闲链表，查找满足需求的空闲页框
    // 如果找到满足需求的页面，记录该页面以及当前找到的最小连续空闲页框数量

    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        // TODO -------------------------
        if (p->property >= n && p->property < min_size) {
            min_size = p->property;
            page = p;
        }
        // TODO -------------------------
    }

    if (page != NULL) {
        list_entry_t* prev = list_prev(&(page->page_link));
        list_del(&(page->page_link));
        if (page->property > n) {
            struct Page *p = page + n;
            p->property = page->property - n;
            SetPageProperty(p);
            list_add(prev, &(p->page_link));
        }
        nr_free -= n;
        ClearPageProperty(page);
    }
    return page;
}
```

- **static** **void** best_fit_free_pages(**struct** Page *****base, **size_t** n)

该函数的主要作用是释放占用的块，使其成为空闲块，并加入空表中。

Page结构体中flags前两位，一位表示reserved，一位表示property：

```c
#define PG_reserved                 0       
// if this bit=1: the Page is reserved for kernel, cannot be used in alloc/free_pages; otherwise, this bit=0 
#define PG_property                 1       
// if this bit=1: the Page is the head page of a free memory block(contains some continuous_addrress pages), and can be used in alloc_pages; if this bit=0: if the Page is the the head page of a free memory block, then this Page and the memory block is alloced. Or this Page isn't the head page.

```

因此对于重新变为空闲状态的块，需要将其块内第一个页的PG_property属性置位，即`SetPageProperty(base)`

另外Page结构体内property成员表示其之后(包括自己)有多少个空闲页，因此赋为n。

然后再把空表内含有空闲页的个数加n，即完成了页块的释放。

​		释放后需要考虑页块的合并，步骤如下：

1. 判断前面的空闲页块是否与当前页块是连续的，如果是连续的，则将当前页块合并到前面的空闲页块中
2. 首先更新前一个空闲页块的大小，加上当前页块的大小
3. 清除当前页块的属性标记，表示不再是空闲页块
4. 从链表中删除当前页块
5. 将指针指向前一个空闲页块，以便继续检查合并后的连续空闲页块。

据此可以完成下面的代码：

```c
static void best_fit_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    /*LAB2 EXERCISE 2: YOUR CODE*/ 
    // 编写代码
    // 具体来说就是设置当前页块的属性为释放的页块数、并将当前页块标记为已分配状态、最后增加nr_free的值
    // TODO -------------------------
    base->property = n;
    SetPageProperty(base);
    nr_free += n;
    // TODO -------------------------

    if (list_empty(&free_list)) {
        list_add(&free_list, &(base->page_link));
    } else {
        list_entry_t* le = &free_list;
        while ((le = list_next(le)) != &free_list) {
            struct Page* page = le2page(le, page_link);
            if (base < page) {
                list_add_before(le, &(base->page_link));
                break;
            } else if (list_next(le) == &free_list) {
                list_add(le, &(base->page_link));
            }
        }
    }

    list_entry_t* le = list_prev(&(base->page_link));
    if (le != &free_list) {
        p = le2page(le, page_link);
        /*LAB2 EXERCISE 2: YOUR CODE*/ 
         // 编写代码
        // 1、判断前面的空闲页块是否与当前页块是连续的，如果是连续的，则将当前页块合并到前面的空闲页块中
        // 2、首先更新前一个空闲页块的大小，加上当前页块的大小
        // 3、清除当前页块的属性标记，表示不再是空闲页块
        // 4、从链表中删除当前页块
        // 5、将指针指向前一个空闲页块，以便继续检查合并后的连续空闲页块
        // TODO -------------------------
        if ((unsigned int)(base - p) == p->property){
            p->property += base->property;
            ClearPageProperty(base);
            list_del(&(base->page_link));
            base = p;
        }
        // TODO -------------------------
    }

    le = list_next(&(base->page_link));
    if (le != &free_list) {
        p = le2page(le, page_link);
        if (base + base->property == p) {
            base->property += p->property;
            ClearPageProperty(p);
            list_del(&(p->page_link));
        }
    }
}
```

#### QA:你的 Best-Fit 算法是否有进一步的改进空间？

​	与First Fit类似，上述搜索优化，延迟合并，分层管理，预分配和预释放，使用缓存机制等优化均可考虑。

​	另外，由于Best Fit需要遍历整个空闲链表，当链表长度n过大时，时间开销过大，因此可以与只遍历到可用页块的First Fit混合使用。

## 三、与参考答案的对比

略

## 四、实验中的知识点

略
