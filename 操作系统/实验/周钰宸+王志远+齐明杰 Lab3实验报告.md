<h1 align = "center">操作系统实验报告</h1>

<h3 align = "center">实验名称：缺页异常和页面置换    实验地点：图书馆323</h3>

<h4 align = "center">组号：56      小组成员：周钰宸  王志远  齐明杰</h4>

## 一、实验目的

* 了解虚拟内存的Page Fault异常处理实现
* 了解页替换算法在操作系统中的实现
* 学会如何使用多级页表，处理缺页异常（Page Fault），实现页面置换算法。

### 二、实验过程

### 1.练习1：理解基于FIFO的页面替换算法（思考题）

*描述FIFO页面置换算法下，一个页面从被换入到被换出的过程中，会经过代码里哪些函数/宏的处理（或者说，需要调用哪些函数/宏），并用简单的一两句话描述每个函数在过程中做了什么？（为了方便同学们完成练习，所以实际上我们的项目代码和实验指导的还是略有不同，例如我们将FIFO页面置换算法头文件的大部分代码放在了`kern/mm/swap_fifo.c`文件中，这点请同学们注意）*

*至少正确指出10个不同的函数分别做了什么？如果少于10个将酌情给分。我们认为只要函数原型不同，就算两个不同的函数。要求指出对执行过程有实际影响,删去后会导致输出结果不同的函数（例如assert）而不是cprintf这样的函数。如果你选择的函数不能完整地体现”从换入到换出“的过程，比如10个函数都是页面换入的时候调用的，或者解释功能的时候只解释了这10个函数在页面换入时的功能，那么也会扣除一定的分数。*

#### 回答（按照调用的逻辑顺序）：

- **do_pgfault()**

  访问页面缺失时，最先进入该函数进行处理。
  
- **assert()**

  判断每一步执行过程是否正确，确保页面换入换出操作无误。如果出现错误，则触发断言中断。
  
- **find_vma()**

  判断访问出错的虚拟地址是否在该页表的**合法虚拟地址集合（所有可用的虚拟地址/虚拟页的集合，不论当前这个虚拟地址对应的页在内存上还是在硬盘上）**里。

- **get_pte()**

  若合法，则获取该va对应的页表项。**其函数中包含了两种处理即查找和分配的合并，**即依次判断，二级页目录项，一级页目录项，页表项是否存在，若不存在则分配新的项给这些部分。

- **pgdir_alloc_page()-->alloc_page()**

  **若找到的页表项是0，说明是刚刚创建的页表项。**之前不存在该va和pa的映射关系，分配一个物理页。

- **swap in()-->swap out()**

  若存在页表项，说明之前有映射关系，但是对应的物理页被换出，现在需要换入。

- **alloc_page()-->swap out()**

  宏定义的一个函数，分配一个空页来读取硬盘中的内容。

- **swapfs_read()**

  **调用内存和硬盘的I/O接口，读取硬盘中相应的内容到一个内存的物理页，实现换入过程。**底层实现是将内核的一部分内存当成了硬盘空间，然后模仿硬盘每次读取只能分区读取的方式，调用了ide_read_secs()使用memcpy将内存在内核和物理内存之间复制。

- **page_insert()**

  **根据换入的页面和va，建立映射，插入新的页表项，**会刷新TLB。

- **swap_map_swappable()**

  换入页面之后调用，把换入的页面加入到FIFO的交换页队列中。

- **swap out()**

  页面需要换出时调用该函数。换出时机策略是消极策略，只有内存空闲页不够时才会换出。

- **swap_out_victim()  <-- _fifo_swap_out_victim()**

  该函数使用了FIFO页面置换算法，在swap out()中被调用，获取要被换出的页面。

- **swapfs_write()**

  把要换出页面的内容保存到硬盘中。

- **free_page()**

  释放页面，完成换出。

- **tlb_invalidate()**

  刷新TLB

- **list_add()**

  在FIFO具体实现中，**为了将新的页面插入队列中而调用的函数。**实际上是插入head指针的后面。

注意：swap in () 函数只在do_pgfault()中被调用，来处理缺页异常，其中的刷新TLB的操作是在之后的page_insert()中实现。**而swap out ()函数随时可能会被调用，如换入页面时、空闲页分配时等，只要满足消极策略时机，就会被调用。**

### 2.练习2：深入理解不同分页模式的工作原理（思考题）

*get_pte()函数（位于`kern/mm/pmm.c`）用于在页表中查找或创建页表项，从而实现对指定线性地址对应的物理页的访问和映射操作。这在操作系统中的分页机制下，是实现虚拟内存与物理内存之间映射关系非常重要的内容。*

 - *get_pte()函数中有两段形式类似的代码， 结合sv32，sv39，sv48的异同，解释这两段代码为什么如此相像。*
 - *目前get_pte()函数将页表项的查找和页表项的分配合并在一个函数里，你认为这种写法好吗？有没有必要把两个功能拆开？*

#### 2.1 get_pte()代码的相似性思考

##### 2.1.1 sv32，sv39，sv48的异同

1. **虚拟地址空间大小**：
   - **Sv32**：支持 **32 位**虚拟地址空间，地址分为两个虚拟页号（VPN）和一个偏移量。叶页表条目（PTE）的物理页号（PPN）与偏移量相结合，形成物理地址。
   - **Sv39**：支持 **39 位**虚拟地址空间，分为4KiB的页面。它设计用于512GB 虚拟地址空间足够的系统。**也是我们本次实验中使用的sv39的三级页表模式。**
   - **Sv48**：支持**48 位**虚拟地址空间，用于39位虚拟地址空间不足的系统。Sv48本质上比Sv39多了一个页表级别，将虚拟地址空间增加到256TB，但以增加专用于页表的物理内存、页表遍历的延迟和存储虚拟地址的硬件结构的大小却更大。
2. **页表级别**：
   - **Sv32**：使用两级页表系统。
   - **Sv39**：利用三级页表系统将 27 位虚拟页号（VPNs）映射到44位物理页号（PPNs），同时保持 12 位页偏移未经翻译。**每个页表级别包含2的9次方个PTE**，任何级别都可以是叶PTE，除了标准的4KB页面外，还支持2MB的大页和1GB 的大大页。
   - **Sv48**：与Sv39相比，Sv48 增加了一个页表级别，因此具有四级页表系统。支持Sv48的系统还必须支持Sv39，以便与假设Sv39的监督软件兼容。
3. **地址转换和内存保护**：
   - **Sv32**：通过前面提到的两级页表完成虚拟到物理地址的转换。
   - **Sv39**：虚拟到物理地址的转换算法在RISC-V手册中详细说明，包括 3 个页表级别和 8 字节的PTESIZE。
   - **Sv48**：遵循与Sv39类似的设计，但具有额外的页表级别，因此地址转换将涉及比Sv39多一个级别的页表遍历。

##### 2.1.2 get_pte()两段代码相似性的原因

**回答：**

* 本质上是因为**sv39的三级页表的机制**。结合虚拟地址la，**使用pgdir即satp对应的初始页表。**利用PDX1,PDT0,PTX即二级页目录，页目录和页表的索引，依次找到对应的页目录或者页表项。

* **pgdir[PDX1(la)]：**

  ​		初始页表其中保存了多个对应大大页即二级页目录的项，**根据索引可以找到对应的对应大大页即二级页目录的初始页表的项保存在pdep1中**。然后进行判断：**若!(*pdep1 & PTE_V)即该项位置不存在或者不有效，**那么就需要使用alloc_page分配新的页给这个项，然后，把那个项memset为**全0**，设置好用户态和有效位后结束。

```c++
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
/* blablabla */
pde_t *pdep1 = &pgdir[PDX1(la)];
    if (!(*pdep1 & PTE_V)) {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
}

```

* **&((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)]**:

  ​		本质上与上面同理，但是这里**先利用上次找到的对应的pdep1**，然后将其利用**PDE_ADDR**将其从对应某个大大页的页目录项转换那个大大页的物理地址，然后再使用**KADDR**将其转换为某个大大页的虚拟地址，在这个上面使用**[PDX0(la)]索引的搭配对应某个大页的项**然后保存为pdep0。

  ​		关于剩余的操作和上面同理，只要是其项位置不存在或者不有效就需要对其重新分配，然后将其项值全部置为0。

```c++
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
 //   	memset(pa, 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
    }
/*  blablabla */
```

* 和上面同理，**不过这次直接得到的是某个页表项，也就是最后一级页表的项了，**直接返回。

```c++
return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
```

* **综上所述：这两段代码如此相近的原因就是因为它们都是依次按照多级页表的映射关系，找到下一级的页目录或者页表项，然后如果出现了不存在或者不有效的情况，就进行了重新分配。**

  如果是**sv32**则只需要进行一次pdep然后直接返回就可以得到页表项，这是因为其只有两层页表关系；而**sv48**则还需要多一层页表递进关系，因此需要pdep2,pdep1和pdep0然后才能返回。

#### 2.2 get_pte()将页表项将查找和分配合并的合理性

**回答：** **我们认为将两个功能都写在get_pte()中这种写法非常合理，而且完全没有必要将其拆开，**甚至拆开会导致不必要的浪费和错误的页面分配，这是因为：、

实际上最重要的会使用get_pte()的地方就是在的**do_pgfault()**中，即发生缺页异常时候的处理。可以发现此时通过get_pte()获取到了出现异常的虚拟地址对应的页表项，**然后判断其*ptep == 0即页表项内容是否为空，即是否是刚刚才创建出来的页表项。**

```c++
int do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr)
{
    /* blablabla */

    pte_t *ptep = NULL;
   
    /* blablabla */
    
    ptep = get_pte(mm->pgdir, addr, 1); //(1) try to find a pte, if pte's
                                        // PT(Page Table) isn't existed, then
                                        // create a PT.
    if (*ptep == 0) //若
    {
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL)
        {
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
            goto failed;
        }
    }
    else
    {
        /* 正常处理 */
    }
}
```

* 即如果我们将查找和分配分开，也就是说查找函数直接返回结果那么也就是:

```c++
pte_t *find_pte(pde_t *pgdir, uintptr_t la, bool create){
    /* blablabla */
pde_t *pdep1 = &pgdir[PDX1(la)];
pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
    /* blablabla */
}
```

这样处理的问题就是会导致即使中间一部分的某个页目录或者页表项实际上是不存在的，那么我们在外面仅根据函数返回值为NULL的结果是**无法确定其究竟是在三级页表的哪一层造成了缺失导致的问题。这样我们也没有办法针对性对其重新分配，分配函数无法针对性对某个层次的页目录或者页表项的缺失进行弥补。即使去查看究竟哪一步出现的问题也会导致不必要的查找的时间损耗。**

而如果将查找和分配合在一起，**那么我们可以在层次递进映射依次取出每一级的页表或者页目录项时候就去查看一下其是否缺失，由此进行针对性的分配和弥补缺失。因此我们觉得把查找和分配写在一个函数中是十分必要的。**

### 3.练习3：给未被映射的地址映射上物理页（需要编程）

补充完成 do_pgfault（mm/vmm.c）函数，给未被映射的地址映射上物理页。设置访问权限的时候需要参考页

面所在 VMA 的权限，同时需要注意映射物理页时需要操作内存控制结构所指定的页表，而不是内核的页表。

请在实验报告中简要说明你的设计实现过程。

**实现过程**：

补充do_pgdefault函数，这个函数用于处理缺页异常：

```c
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);

    pgfault_num++;
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
        goto failed;
    }

    /* IF (write an existed addr ) OR
     *    (write an non_existed addr && addr is writable) OR
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
        perm |= (PTE_R | PTE_W);
    }
    addr = ROUNDDOWN(addr, PGSIZE);

    ret = -E_NO_MEM;

    pte_t *ptep=NULL;
    /*
    * Maybe you want help comment, BELOW comments can help you finish the code
    *
    * Some Useful MACROs and DEFINEs, you can use them in below implementation.
    * MACROs or Functions:
    *   get_pte : get an pte and return the kernel virtual address of this pte for la
    *             if the PT contians this pte didn't exist, alloc a page for PT (notice the 3th parameter '1')
    *   pgdir_alloc_page : call alloc_page & page_insert functions to allocate a page size memory & setup
    *             an addr map pa<--->la with linear address la and the PDT pgdir
    * DEFINES:
    *   VM_WRITE  : If vma->vm_flags & VM_WRITE == 1/0, then the vma is writable/non writable
    *   PTE_W           0x002                   // page table/directory entry flags bit : Writeable
    *   PTE_U           0x004                   // page table/directory entry flags bit : User can access
    * VARIABLES:
    *   mm->pgdir : the PDT of these vma
    *
    */


    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
                                         //PT(Page Table) isn't existed, then
                                         //create a PT.
    if (*ptep == 0) {
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
            goto failed;
        }
    } else {
        /*LAB3 EXERCISE 3: 2113997
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
            swap_in(mm,addr,&page);
            page_insert(mm->pgdir,page,addr,perm);
            swap_map_swappable(mm,addr,page,1);
            page->pra_vaddr = addr;
        } else {
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
failed:
    return ret;
}
```

其中，get_pte函数获取该va对应的页表项。其函数中包含了两种处理，即查找和分配的合并，在之后使用了if进行判断：

```c
if (*ptep == 0)
```

其含义是判断获取到的页表项ptep是否为空项，若为空项(即全是0)，则分配对应的物理页给这个页表项即可。

然而如果不是空项，说明**物理页不存在于内存中，而在磁盘中**，需要进行页交换处理。那么使用swap_in函数来将需要的物理页读入内存(当然如果内存不足，自动调用swap_out函数换出，最终一定能成功将该物理页换入)，然后使用page_insert来建立页表项到页之间的映射，最后把其可交换属性设置为真，插入FIFO的队列中。

回答如下问题：

• **请描述页目录项（Page Directory Entry）和页表项（Page Table Entry）中组成部分对 ucore 实现页替换算**

**法的潜在用处**。

**答**：表项中 PTE_A 表示内存页是否被访问过，PTE_D 表示内存页是否被修改过，借助着两位标志位可以实现 **Enhanced Clock 算法**。

- **改进的时钟（Enhanced Clock）页替换算法**：在时钟置换算法中，淘汰一个页面时只考虑了页面是否被

	访问过，但在实际情况中，还应考虑被淘汰的页面是否被修改过。因为淘汰修改过的页面还需要写回

	硬盘，使得其置换代价大于未修改过的页面，所以优先淘汰没有修改的页，减少磁盘操作次数。改进

	的时钟置换算法除了考虑页面的访问情况，还需考虑页面的修改情况。即该算法不但希望淘汰的页面

	是最近未使用的页，而且还希望被淘汰的页是在主存驻留期间其页面内容未被修改过的。这需要为每

	一页的对应页表项内容中增加一位引用位和一位修改位。当该页被访问时，CPU 中的 MMU 硬件将把

	访问位置“1”。当该页被“写”时，CPU 中的 MMU 硬件将把修改位置“1”。这样这两位就存在四种

	可能的组合情况：（0，0）表示最近未被引用也未被修改，首先选择此页淘汰；（0，1）最近未被使用，

	但被修改，其次选择；（1，0）最近使用而未修改，再次选择；（1，1）最近使用且修改，最后选择。该

	算法与时钟算法相比，可进一步减少磁盘的 I/O 操作次数，但为了查找到一个尽可能适合淘汰的页面，

	可能需要经过多次扫描，增加了算法本身的执行开销。

• **如果 ucore 的缺页服务例程在执行过程中访问内存，出现了页访问异常，请问硬件要做哪些事情？**

**答**：如果出现了页访问异常，那么硬件将引发页访问异常的地址将被保存在 cr2 寄存器中，设置错误代码，然后触发 Page Fault 异常，进入do_pgdefault函数处理。

• **数据结构 Page 的全局变量（其实是一个数组）的每一项与页表中的页目录项和页表项有无对应关系？**

**如果有，其对应关系是啥？**

**答**：页表项和页目录项存储的结构体：

```c
struct Page {
    int ref;                        // page frame's reference counter
    uint_t flags;        // array of flags that describe the status of the page frame
    uint_t visited;
    unsigned int property;    // the num of free block, used in first fit pm manager
    list_entry_t page_link;         // free list link
    list_entry_t pra_page_link;     // used for pra (page replace algorithm)
    uintptr_t pra_vaddr;            // used for pra (page replace algorithm)
};
```

其中我们使用了一个`visited`变量，用来记录页面是否被访问。
在`map_swappable`函数，我们把换入的页面加入到FIFO的交换页队列中，此时页面已经被访问，visited置为1.

在`clock_swap_out_victim`，我们根据算法筛选出可用来交换的页面。

​	在CLOCK算法我们使用了visited成员：我们从队尾依次遍历到队头，查看visited变量，如果是0，则该页面可以被用来交换，把它从FIFO页面链表中删除。

​	由于PTE_A 表示内存页是否被访问过，visited与其对应。

### 4.练习4：补充完成Clock页替换算法（需要编程）

通过之前的练习，相信大家对 FIFO 的页面替换算法有了更深入的了解，现在请在我们给出的框架上，填写

代码，实现 Clock 页替换算法页面（mm/swap_clock.c）。请在实验报告中简要说明你的设计实现过程。

**实现过程**：

完成如下各个函数;

- **_clock_init_mm**

```c
static int
_clock_init_mm(struct mm_struct *mm)
{     
     /*LAB3 EXERCISE 4: 2113997*/ 
     // 初始化pra_list_head为空链表
     // 初始化当前指针curr_ptr指向pra_list_head，表示当前页面替换位置为链表头
     // 将mm的私有成员指针指向pra_list_head，用于后续的页面替换算法操作
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     list_init(&pra_list_head);
     curr_ptr = &pra_list_head;
     mm->sm_priv = &pra_list_head;
     return 0;
}
```

根据提示，使用list_init初始化pra_list_head为空链表，然后令curr_ptr指向表头，将mm的私有成员指针指向pra_list_head即可。

- **_clock_map_swappable**

```c
static int
_clock_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
    list_entry_t *entry=&(page->pra_page_link);
 
    assert(entry != NULL && curr_ptr != NULL);
    //record the page access situlation
    /*LAB3 EXERCISE 4: 2113997*/ 
    // link the most recent arrival page at the back of the pra_list_head qeueue.
    // 将页面page插入到页面链表pra_list_head的末尾
    // 将页面的visited标志置为1，表示该页面已被访问
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
    list_add(head, entry);
    page->visited = 1;
    return 0;
}
```

我们这里采用反向插法，即每次均插到链表头(head指向的链表项的下一个)，之后遍历则从链表尾向前遍历即可。

- **_clock_swap_out_victim**

```c
static int
_clock_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
         assert(head != NULL);
     assert(in_tick==0);
     /* Select the victim */
     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
     //(2)  set the addr of addr of this page to ptr_page
    while (1) {
        /*LAB3 EXERCISE 4: 2113997*/ 
        // 编写代码
        // 遍历页面链表pra_list_head，查找最早未被访问的页面
        // 获取当前页面对应的Page结构指针
        // 如果当前页面未被访问，则将该页面从页面链表中删除，并将该页面指针赋值给ptr_page作为换出页面
        // 如果当前页面已被访问，则将visited标志置为0，表示该页面已被重新访问
        if(curr_ptr == head){
            curr_ptr = list_prev(curr_ptr);
            continue;
        }
        struct Page* curr_page = le2page(curr_ptr,pra_page_link);
        if(curr_page->visited == 0){
            cprintf("curr_ptr %p\n", curr_ptr);
            curr_ptr = list_prev(curr_ptr);
            list_del(list_next(curr_ptr));
            *ptr_page = curr_page;
            return 0;
        }
        curr_page->visited = 0;
        curr_ptr = list_prev(curr_ptr);
    }
    return 0;
}
```

​	由于head指针无法利用le2page宏转成Page结构体指针，因此先进行判断。之后从链表尾部(即head指向链表项的前一个项，环形链表)依次向前遍历，直到找到第一个visited=0的项，它便是CLOCK算法找到的换出页面，将其移除可交换页链表。中途遇到的Page有visited=1，将其置为0即可。

回答如下问题：

• **比较 Clock 页替换算法和 FIFO 算法的不同。**

**答**：

- 先进先出 (First In First Out, FIFO) 页替换算法：该算法总是淘汰最先进入内存的页，即选择在内存中驻

	留时间最久的页予以淘汰。只需把一个应用程序在执行过程中已调入内存的页按先后次序链接成一个

	队列，队列头指向内存中驻留时间最久的页，队列尾指向最近被调入内存的页。这样需要淘汰页时，从

	队列头很容易查找到需要淘汰的页。FIFO 算法只是在应用程序按线性顺序访问地址空间时效果才好，

	否则效率不高。**因为那些常被访问的页，往往在内存中也停留得最久**，结果它们因变“老”而不得不

	被置换出去。FIFO 算法的另一个缺点是，它有一种**异常现象（Belady 现象）**，即在增加放置页的物理页

	帧的情况下，反而使页访问异常次数增多。

- 时钟（Clock）页替换算法：是 LRU 算法的一种近似实现。时钟页替换算法把各个页面组织成环形链表

	的形式，类似于一个钟的表面。然后把一个指针（简称当前指针）指向最老的那个页面，即最先进来

	的那个页面。另外，时钟算法需要在页表项（PTE）中设置了一位访问位来表示此页表项对应的页当前

	**是否被访问过**。当该页被访问时，CPU 中的 MMU 硬件将把访问位置“1”。当操作系统需要淘汰页时，

	对当前指针指向的页所对应的页表项进行查询，如果访问位为“0”，则淘汰该页，如果该页被写过，则

	还要把它换出到硬盘上；如果访问位为“1”，则将该页表项的此位置“0”，继续访问下一个页。该算法

	近似地体现了 LRU 的思想，且易于实现，开销少，需要硬件支持来设置访问位。时钟页替换算法在本

	质上与 FIFO 算法是类似的，不同之处是在时钟页替换算法中跳过了访问位为 1 的页。

*总而言之，CLOCK算法考虑了页表项表示的页是否被访问过，而FIFO不考虑这点。*

### 5.练习5：阅读代码和实现手册，理解页表映射方式相关知识（思考题）

*如果我们采用”一个大页“ 的页表映射方式，相比分级页表，有什么好处、优势，有什么坏处、风险？*

**答**：使用"一个大页"的页表映射方式与分级页表映射方式相比，有以下优势和劣势：

### 优势：

1. **简单性**：使用一个大页的页表映射方式更为简单和直观。
2. **快速访问**：由于只有一个页表，页表查找速度通常更快，从而可以减少内存访问的延迟。
3. **连续内存分配**：大页可以为需要大量连续内存的应用程序提供更好的性能，因为它们减少了页表条目的数量和TLB缺失的可能性。
4. **减少TLB缺失**：由于大页涵盖的物理内存范围更大，TLB中的一个条目可以映射更大的内存范围，从而可能减少TLB缺失的次数。

### 劣势：

1. **浪费内存**：如果应用程序只需要小部分的大页，则剩余的部分将被浪费，导致内存碎片。
2. **不灵活**：大页不适合小内存需求的应用程序。
3. **增加内存压力**：由于每个大页都需要大量的连续内存，因此可能会增加内存分配的压力和碎片化。
4. **可能增加页错误**：如果应用程序访问的内存跨越了多个大页，那么可能会导致更多的页错误。
5. **兼容性问题**：不是所有的硬件和操作系统都支持大页。
6. **安全问题**：大页可能会导致更大范围的内存暴露给恶意软件，增加安全风险

#### 5.1 优势与好处

**1. 简化内存管理：**确实如果直接使用多级页表实现

#### 5.2 坏处和风险

1.内存碎片较多

2.置换代价较大

3.对于标志位的存储更加耗费空间

## 三、与参考答案的对比

由于本实验的代码逻辑较为固定，因此我们小组所完成的代码与参考答案差别不大。

## 四、实验中的知识点

### **4.1 页、页表和多级页表机制：**

**（1）页 (Page)**

- 页是物理内存和虚拟内存之间的一个固定大小的块。当程序需要更多的内存空间时，操作系统会为其分配一个或多个页。
- 页的大小通常是固定的，例如4KB、8KB等，具体大小取决于操作系统和硬件架构。
- 使用页的目的是为了使物理内存的管理更加高效，并支持虚拟内存技术。

**（2）页表 (Page Table)**

- 页表是一个数据结构，用于存储虚拟页和物理页之间的映射关系。
- 当程序访问一个虚拟地址时，操作系统和硬件会使用页表来查找对应的物理地址。
- 页表通常存储在物理内存中，并由特定的硬件机制（如MMU，Memory Management Unit）进行管理和查找。

**（3）多级页表 (Multi-level Page Table)**

- 由于现代计算机的内存容量非常大，单一的页表可能会非常庞大，从而占用大量的物理内存。为了解决这个问题，引入了多级页表机制。
- 在多级页表中，主页表只包含指向其他页表的指针，而这些子页表再指向更多的页表，如此递归，直到达到实际的物理页映射。
- 这种层次结构允许操作系统只加载当前活跃或正在使用的部分页表到内存中，从而节省内存。
- 例如，x86架构中的二级页表包括一个页目录和多个页表。而在某些架构中，如x86-64，存在四级页表。

总的来说，页、页表和多级页表机制是现代计算机系统中虚拟内存管理的核心组件，它们允许程序认为它们拥有比实际物理内存更多的内存空间，并帮助操作系统更高效地管理物理内存。

### 4.2 页面置换算法：

本次实验涉及的页替换算法（包括扩展练习）：
- **先进先出(First In First Out, FIFO)页替换算法：**该算法总是淘汰最先进入内存的页，即选择在内存中驻留时间最久的页予以淘汰。FIFO 算法只是在应用程序按线性顺序访问地址空间时效果才好，否则效率不高。因为那些常被访问的页，往往在内存中也停留得最久，结果它们因变“老”而不得不被置换出去。**FIFO 算法的另一个缺点是，它有一种异常现象（Belady 现象），即在增加放置页的物理页帧的情况下，反而使页访问异常次数增多。**
- **最久未使用(least recently used, LRU)算法：**利用局部性，通过过去的访问情况预测未来的访问情况，我们可以认为最近还被访问过的页面将来被访问的可能性大，而很久没访问过的页面将来不太可能被访问。
- **时钟（Clock）页替换算法：是 LRU 算法的一种近似实现**。时钟页替换算法把各个页面组织成环形链表的形式，类似于一个钟的表面。然后把一个指针（简称当前指针）指向最老的那个页面，即最先进来的那个页面。另外，时钟算法需要在页表项（PTE）中设置了一位访问位来表示此页表项对应的页当前是否被访问过。当该页被访问时，CPU 中的 MMU 硬件将把访问位置“1”。当操作系统需要淘汰页时，对当前指针指向的页所对应的页表项进行查询，如果访问位为“0”，则淘汰该页，如果该页被写过，则还要把它换出到硬盘上；如果访问位为“1”，则将该页表项的此位置“0”，继续访问下一个页。**该算法近似地体现了 LRU 的思想，且易于实现，开销少，需要硬件支持来设置访问位。时钟页替换算法在本质上与 FIFO 算法是类似的，不同之处是在时钟页替换算法中跳过了访问位为 1 的页。**
- **改进的时钟（Enhanced Clock）页替换算法：**在时钟置换算法中，淘汰一个页面时只考虑了页面是否被访问过，**但在实际情况中，还应考虑被淘汰的页面是否被修改过。因为淘汰修改过的页面还需要写回硬盘，使得其置换代价大于未修改过的页面，所以优先淘汰没有修改的页，减少磁盘操作次数。**改进的时钟置换算法除了考虑页面的访问情况，还需考虑页面的修改情况。即该算法不但希望淘汰的页面是最近未使用的页，而且还希望被淘汰的页是在主存驻留期间其页面内容未被修改过的。这需要为每一页的对应页表项内容中增加一位引用位和一位修改位。当该页被访问时，CPU 中的 MMU 硬件将把访问位置“1”。当该页被“写”时，CPU 中的 MMU 硬件将把修改位置“1”。**这样这两位就存在四种可能的组合情况：（0，0）表示最近未被引用也未被修改，首先选择此页淘汰；（0，1）最近未被使用，但被修改，其次选择；（1，0）最近使用而未修改，再次选择；（1，1）最近使用且修改，最后选择。该算法与时钟算法相比，可进一步减少磁盘的 I/O 操作次数，但为了查找到一个尽可能适合淘汰的页面，可能需要经过多次扫描，增加了算法本身的执行开销。**
