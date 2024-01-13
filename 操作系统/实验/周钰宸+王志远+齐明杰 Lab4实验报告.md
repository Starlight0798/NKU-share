<h1 align = "center">操作系统实验报告</h1>

<h3 align = "center">实验名称：进程管理    实验地点：图书馆323</h3>

<h4 align = "center">组号：56      小组成员：周钰宸  王志远  齐明杰</h4>

## 一、实验目的

* 了解内核线程创建/执行的管理过程

* 了解内核线程的切换和基本调度过程

### 二、实验过程

### 1.练习1：分配并初始化一个进程控制块（需要编码）

*alloc_proc 函数（位于 kern/process/proc.c 中）负责分配并返回一个新的 struct proc_struct 结构，用于存储新建 立的内核线程的管理信息。ucore 需要对这个结构进行最基本的初始化，你需要完成这个初始化过程。 【提示】在 alloc_proc 函数的实现中，需要初始化的 proc_struct 结构中的成员变量至少包括：state/pid/runs/kstack/need_resched/parent/mm/context/tf/cr3/ffags/name。* 

* *请在实验报告中简要说明你的设计实现过程。请回答如下问题：*

* *请说明 proc_struct 中 struct context context 和 struct trapframe tf 成员变量含义和 在本实验中的作用是啥？（提示通过看代码和编程调试可以判断出来）*

#### 回答：

#### 1.1 问题1

alloc_proc函数主要是分配并且初始化一个PCB用于管理新进程的信息。proc_struct 结构的信息如下：

```c++
struct proc_struct {//进程控制块
    enum proc_state state;                      // 进程状态
    int pid;                                    // 进程ID
    int runs;                                   // 运行时间
    uintptr_t kstack;                           // 内核栈位置
    volatile bool need_resched;                 // 是否需要调度
    struct proc_struct *parent;                 // 父进程
    struct mm_struct *mm;                       // 进程的虚拟内存
    struct context context;                     // 进程上下文
    struct trapframe *tf;                       // 当前中断帧的指针
    uintptr_t cr3;                              // 当前页表地址
    uint32_t flags;                             // 进程
    char name[PROC_NAME_LEN + 1];               // 进程名字
    list_entry_t list_link;                     // 进程链表    
    list_entry_t hash_link;                    
};

```

在alloc_proc中我们对每个变量都进行初始化操作，代码如下：

```c++
static struct proc_struct *
alloc_proc(void) {
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
    if (proc != NULL) {
        proc->state = PROC_UNINIT;//给进程设置为未初始化状态
        proc->pid = -1;//未初始化的进程，其pid为-1
        proc->runs = 0;//初始化时间片,刚刚初始化的进程，运行时间一定为零	
        proc->kstack = 0;//内核栈地址,该进程分配的地址为0，因为还没有执行，也没有被重定位，因为默认地址都是从0开始的。
        proc->need_resched = 0;//不需要调度
        proc->parent = NULL;//父进程为空
        proc->mm = NULL;//虚拟内存为空
        memset(&(proc->context), 0, sizeof(struct context));//初始化上下文
        proc->tf = NULL;//中断帧指针为空
        proc->cr3 = boot_cr3;//页目录为内核页目录表的基址
        proc->flags = 0; //标志位为0
        memset(proc->name, 0, PROC_NAME_LEN);//进程名为0
    }
    return proc;
}

```

- state设置为未初始化状态；
- 由于刚创建进程，pid设置为-1；
- 进程运行时间run初始化为0；
- 内核栈地址kstack默认从0开始；
- need_resched是一个用于判断当前进程是否需要被调度的bool类型变量，为1则需要进行调度。初始化为0，表示不需要调度；
- 父进程parent设置为空；
- 内存空间初始化为空；
- 上下文结构体context初始化为0；
- 中断帧指针tf设置为空；
- 页目录cr3设置为为内核页目录表的基址boot_cr3；
- 标志位flags设置为0；
- 进程名name初始化为0；

通过如上代码，完成了对分配得到的新进程的PCB的初始化操作。

#### 1.2 问题2

①**context**作用：进程的上下文，用于进程切换。主要保存了前一个进程的现场（各个寄存器的状态）。在uCore中，所有的进程在内核中也是相对独立的。使用context 保存寄存器的目的就在于在内核态中能够进行上下文之间的切换。实际利用context进行上下文切换的函数是在kern/process/switch.S中定义switch_to。

②**tf**：中断帧的指针，总是指向内核栈的某个位置：当进程从用户空间跳到内核空间时，中断帧记录了进程在被中断前的状态。当内核需要跳回用户空间时，需要调整中断帧以恢复让进程继续执行的各寄存器值。除此之外，uCore内核允许嵌套中断。因此为了保证嵌套中断发生时tf 总是能够指向当前的trapframe，uCore 在内核栈上维护了 tf 的链。

### 2.练习 2：为新创建的内核线程分配资源（需要编码）

*创建一个内核线程需要分配和设置好很多资源。kernel_thread 函数通过调用 do_fork 函数完成具体内核线程 的创建工作。do_kernel 函数会调用 alloc_proc 函数来分配并初始化一个进程控制块，但 alloc_proc 只是找到 了一小块内存用以记录进程的必要信息，并没有实际分配这些资源。ucore 一般通过 do_fork 实际创建新的内 核线程。do_fork 的作用是，创建当前内核线程的一个副本，它们的执行上下文、代码、数据都一样，但是存 储位置不同。因此，我们实际需要”fork”的东西就是 stack 和 trapframe。在这个过程中，需要给新内核线 程分配资源，并且复制原进程的状态。*

* *你需要完成在 kern/process/proc.c 中的 do_fork 函数中的处理过程。请在实验报告中简要说明你的设计实现过程。*

* *请说明 ucore 是否做到给每个新 fork 的线程一个唯一的 id？请说明你的分析和理由。*

#### 回答：

#### 2.1 问题1

根据文档提示，do_fork函数的处理大致可以分为7步，下面我们来按步骤实现该函数：

1. 调用alloc_proc

   ```c++
       if ((proc = alloc_proc()) == NULL) {
           goto fork_out;
       }
   	proc->parent = current;//将子进程的父节点设置为当前进程
   ```

   调用alloc_proc()函数申请内存块，如果失败，直接返回处理。

2. 为进程分配一个内核栈

   ```c++
       if (setup_kstack(proc)) {
           goto bad_fork_cleanup_proc;
       }
   ```

   调用setup_kstack()函数为进程分配一个内核栈。

3. 复制原进程的内存管理信息到新进程（但内核线程不必做此事）

   ```c++
       if(copy_mm(clone_flags, proc)){
           goto bad_fork_cleanup_kstack;
       }
   ```

   ```c++
   static int
   copy_mm(uint32_t clone_flags, struct proc_struct *proc) {
       assert(current->mm == NULL);
       /* do nothing in this project */
       return 0;
   }
   ```

   调用copy_mm()函数，复制父进程的内存信息到子进程。对于这个函数可以看到，进程proc复制还是共享当前进程current，是根据clone_flags来决定的，如果是clone_flags & CLONE_VM（为真），那么就可以拷贝。

   本实验中，仅仅是确定了一下当前进程的虚拟内存为空，并没有做其他事。

4. 复制原进程上下文到新进程

   ```c++
   copy_thread(proc, stack, tf);
   ```

   ```c++
   static void
   copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf) {
       proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
       *(proc->tf) = *tf;
   
       // Set a0 to 0 so a child process knows it's just forked
       proc->tf->gpr.a0 = 0;
       proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
   
       proc->context.ra = (uintptr_t)forkret;
       proc->context.sp = (uintptr_t)(proc->tf);
   }
   ```

   调用copy_thread()函数复制父进程的中断帧和上下文信息。

5. 将新进程添加到进程列表

   ```c++
       bool intr_flag;
       local_intr_save(intr_flag);//屏蔽中断，intr_flag置为1
       {
           proc->pid = get_pid();//获取当前进程PID
           hash_proc(proc); //建立hash映射
           list_add(&proc_list, &(proc->list_link));//加入进程链表
           nr_process ++;//进程数加一
       }
       local_intr_restore(intr_flag);//恢复中断
   ```

   ```c++
   hash_proc(struct proc_struct *proc) {
       list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
   }
   ```

   调用hash_proc()函数把新进程的PCB插入到哈希进程控制链表中，然后通过list_add函数把PCB插入到进程控制链表中，并把总进程数+1。在添加到进程链表的过程中，我们使用了local_intr_save()和local_intr_restore()函数来屏蔽与打开，保证添加进程操作不会被抢断。

6. 唤醒新进程

   ```c++
   wakeup_proc(proc);
   ```

   ```c++
   void
   wakeup_proc(struct proc_struct *proc) {
       assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
       proc->state = PROC_RUNNABLE;
   }
   ```

   调用wakeup_proc()函数来把当前进程的state设置为**PROC_RUNNABLE**。

7. 返回新进程号

   ```c++
   ret = proc->pid;//返回当前进程的PID
   ```

   返回新进程号。

通过如下7个步骤，我们可以完整的实现do_fork函数创建新进程的功能。

#### 2.2 问题2

我们可以查看实验中获取进程id的函数：**get_pid(void)**

```c++
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
                    if (last_pid >= MAX_PID) {
                        last_pid = 1;
                    }
                    next_safe = MAX_PID;
                    goto repeat;
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid) {
                next_safe = proc->pid;
            }
        }
    }
    return last_pid;
}
```

这段代码通过维护一个静态变量`last_pid`来实现为每个新fork的线程分配一个唯一的id。让我们逐步分析：

1. `last_pid`是一个静态变量，它会记录上一个分配的pid。
2. 当`get_pid`函数被调用时，首先检查是否`last_pid`超过了最大的pid值（`MAX_PID`）。如果超过了，将`last_pid`重新设置为1，从头开始分配。
3. 如果`last_pid`没有超过最大值，就进入内部的循环结构。在循环中，它遍历进程列表，检查是否有其他进程已经使用了当前的`last_pid`。如果发现有其他进程使用了相同的pid，就将`last_pid`递增，并继续检查。
4. 如果没有找到其他进程使用当前的`last_pid`，则说明`last_pid`是唯一的，函数返回该值。

这样，通过这个机制，每次调用`get_pid`都会尽力确保分配一个未被使用的唯一pid给新fork的线程。

### 3.练习3：编写 proc_run 函数（需要编码）

*proc_run 用于将指定的进程切换到 CPU 上运行。请回答如下问题：*

* *在本实验的执行过程中，创建且运行了几个内核线程？*

#### 回答：

#### 3.1 问题1

根据文档的提示说明，我们编写的proc_run()函数如下：

```c++
void
proc_run(struct proc_struct *proc) {
    if (proc != current) {
        // LAB4:EXERCISE3
        /*
        * Some Useful MACROs, Functions and DEFINEs, you can use them in below implementation.
        * MACROs or Functions:
        *   local_intr_save():        Disable interrupts
        *   local_intr_restore():     Enable Interrupts
        *   lcr3():                   Modify the value of CR3 register
        *   switch_to():              Context switching between two processes
        */
       bool intr_flag;
       struct proc_struct *prev = current, *next = proc;
       local_intr_save(intr_flag);
       {
            current = proc;
            lcr3(next->cr3);
            switch_to(&(prev->context), &(next->context));
       }
       local_intr_restore(intr_flag);
    }
}
```

此函数**基本思路**是：

- 让 current指向 next内核线程initproc；
- 设置 CR3 寄存器的值为 next 内核线程 initproc 的页目录表起始地址 next->cr3，这实际上是完成进程间的页表切换；
- 由 switch_to函数完成具体的两个线程的执行现场切换，即切换各个寄存器，当 switch_to 函数执行完“ret”指令后，就切换到initproc执行了。

值得注意的是，这里我们使用`local_intr_save()`和`local_intr_restore()`，作用分别是屏蔽中断和打开中断，以免进程切换时其他进程再进行调度，保护进程切换不会被中断。

#### 3.2 问题2

在本实验中，创建且运行了2两个内核线程：

- idleproc：第一个内核进程，完成内核中各个子系统的初始化，之后立即调度，执行其他进程。
- initproc：用于完成实验的功能而调度的内核进程。

### 4.扩展练习 Challenge：

*说明语句 local_intr_save(intr_flag);....local_intr_restore(intr_flag); 是如何 实现开关中断的？*

#### 回答：

这两句分别是kern/sync.h中定义的中断前后使能信号保存和退出的函数。

```c++
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
        intr_disable();
        return 1;
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
    }
}

#define local_intr_save(x) \
    do {                   \
        x = __intr_save(); \
    } while (0)
#define local_intr_restore(x) __intr_restore(x);

#endif /* !__KERN_SYNC_SYNC_H__ */
```

这两个函数在当时Lab1中有所涉及，主要作用是首先通过定义两个宏函数local_intr_save和local_intr_restore。这两个宏函数会调用两个内联函数intr_save和intr_restore。其中：

1. **intr_save和local_intr_save：**
   * **intr_save：**通过**读取CSR控制和状态寄存器的sstatus中的值**，并对比其是否被设置为了SIE=1，即中断使能位=1。如果中断使能位SIE是1，那么表示中断是被允许的；为0就是不允许的。因此如果中断本来是允许的，就会调用intr.h中的intr_disable禁用中断，否则直接返回，因此本身也不允许。
   * **local_intr_save：**在这个函数其中，用 do-while循环可以确保 **x变量在__intr_save() 函数调用之后被正确赋值，无论中断是否被禁用。**
2. **intr_restore和local_intr_restore：**
   * **intr_restore：**直接根据flag标志位是否为0，intr_enable()重新启用中断。
   * **local_intr_restore：**与save不同，无需返回任何值，恢复中断即可。

由此将两个宏定义函数结合起来， **local_intr_save(intr_flag);....local_intr_restore(intr_flag)就可以实现在一个进程发生切换前禁用中断，切换后重新启用中断，以实现开关中断，保证进程切换原子性的目的。~~如果不这样的就会导致宫老师讲的我和舍友买面包贴标签的尴尬问题。~~**

在**Kernel_Thread**函数中，就设置SSTATUS的SPIE,SIE等标志位实现控制中断开关。

除此之外，**我们在练习3中也通过这个方式控制中断前后的切换。**

```c++
 local_intr_save(intr_flag);
        {
            current = proc;
            lcr3(next->cr3);
            switch_to(&(prev->context), &(next->context));
       }
local_intr_restore(intr_flag);
```

## 三、与参考答案的对比

由于本实验的代码逻辑较为固定，因此我们小组所完成的代码与参考答案差别不大。

## 四、实验中的知识点

### 4.1 进程与线程的关系

​		我们平时编写的源代码，经过编译器编译就变成了可执行文件，我们管这一类文件叫做**程序 **。而当一 个程序被用户或操作系统启动，分配资源，装载进内存开始执行后，它就成为了一个 **进程 **。

​		进程与程序之间最大的不同在于进程是一个“正在运行”的实体，而程序只是一个不动的文件。进程包含程序的内容， 也就是它的静态的代码部分，也包括一些在运行时在可以体现出来的信息，比如堆栈，寄存器等数据，这些组成了进程“正在运行”的特性。 如果我们只关注于那些“正在运行”的部分，我们就从进程当中剥离出来了**线程 **。

​		**一个进程可以对应 一个线程，也可以对应很多线程。这些线程之间往往具有相同的代码，共享一块内存，但是却有不同的CPU执行状态。相比于线程，进程更多的作为一个资源管理的实体（因为操作系统分配网络等资源时往往是基于 进程的），这样线程就作为可以被调度的最小单元，给了调度器更多的调度可能。**

<img src="C:\Users\zyc13\AppData\Roaming\Typora\typora-user-images\image-20231119122959940.png" alt="image-20231119122959940" style="zoom:50%;" />

### 4.2 进程调度

<img src="C:\Users\zyc13\AppData\Roaming\Typora\typora-user-images\image-20231119124853459.png" alt="image-20231119124853459" style="zoom:50%;" />

上OS课时候宫老师提到过，调度的代价是很大的，其中一般涉及：

* 减少上下文切换涉及的寄存器数量
* 减少不必要的权限切换

一些理论上可以处理的方式包括：

* 纤程 Fiber, ucontext
* 协程 coroutine
* 发挥ULT快速切换的优势
* 在编程时提出对程序员的限制，要求他们妥善的设计代码
