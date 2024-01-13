<h1 align = "center">操作系统实验报告</h1>

<h3 align = "center">实验名称：中断与中断处理流程    实验地点：图书馆325</h3>

<h4 align = "center">组号：56      小组成员：周钰宸  王志远  齐明杰</h4>

## 一、实验目的

实验1 主要讲解的是中断处理机制。通过本章的学习，我们了解了riscv 的中断处理机制、相关寄存器与指令。我们知道在中断前后需要恢复上下文环境，用一个名为中断帧（TrapFrame）的结构体存储了要保存的各寄存器，并用了很大篇幅解释如何通过精巧的汇编代码实现上下文环境保存与恢复机制。最终，我们通过处理断点和时钟中断验证了我们正确实现了中断机制。

## 二、实验过程

### 1.练习1

`kern/init/entry.S`是`OpenSBI`启动时最先执行的一段汇编代码，在该段代码中，完成了对于内核栈的分配，然后跳转到真正的内核初始化函数进行执行。下面我们对题目中要解析的两句汇编指令进行解析。

1.`la sp, bootstacktop`

该指令将`bootstacktop`这个标签所代表的地址加载给`sp`栈顶寄存器，从而实现内存栈的初始化。在操作系统的引导过程中，最初的栈通常是一个非常小的栈，用于执行引导加载程序（`bootloader`）的一些基本操作。`bootstacktop`就是引导栈的起始地址。

2.`tail kern_init`

该指令通过尾调用的方式跳转执行`kern_init`这个函数进行内核的一系列初始化操作。尾调用就是在调用函数后，不会返回到原来的函数调用位置，而是将控制权传递给被调用的函数，使其成为新的执行上下文。

### 2.练习2

我们实现时钟中断的处理函数代码如下：

```C
        case IRQ_S_TIMER:
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
             /* LAB1 EXERCISE2   YOUR CODE :  */
            clock_set_next_event();
            ticks++;
            if(ticks%TICK_NUM == 0){
            	print_ticks();
            	PRINT_NUM++;
            	if(PRINT_NUM == 10){
            	   sbi_shutdown();
            	}
            }
            
            /*(1)设置下次时钟中断- clock_set_next_event()
             *(2)计数器（ticks）加一
             *(3)当计数器加到100的时候，我们会输出一个`100ticks`表示我们触发了100次时钟中断，同时打印次数（num）加一
            * (4)判断打印次数，当打印次数为10时，调用<sbi.h>中的关机函数关机
            */
            break;
```

在该段代码中，每次触发时钟中断后，我们都先通过调用`clock_set_next_event()`函数来设置下一个时钟中断，然后将中断次数计数器`ticks`加1，判断该次数是否为100的整数倍，若是的话则调用函数打印`100 ticks`，同时把打印次数计数器`PRINT_NUM`也加1。当`PRINT_NUM`的值达到10时，调用`shutdown`函数进行关机。

下面我们简要说明一下时钟中断的处理流程。

最早产生的时钟中断事件是在`kern/init/init.c`文件中产生的，在该文件中有如下代码：

```C
clock_init();  // init clock interrupt
```

该代码则是产生了**第一次**时钟中断，捕捉到该中断后操作系统通过查找`stvec`，调用`trap()`函数，该对中断进行识别分类，然后进入上述的时钟中断处理函数中进行处理。在这里我们主要是要了解如何在该次时钟中断后设置下一次时钟中断。通过如下代码实现：

```C
static inline uint64_t get_cycles(void) {
#if __riscv_xlen == 64
    uint64_t n;
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    return n;
#else
    uint32_t lo, hi, tmp;
    __asm__ __volatile__(
        "1:\n"
        "rdtimeh %0\n"
        "rdtime %1\n"
        "rdtimeh %2\n"
        "bne %0, %2, 1b"
        : "=&r"(hi), "=&r"(lo), "=&r"(tmp));
    return ((uint64_t)hi << 32) | lo;
#endif
}


// Hardcode timebase
static uint64_t timebase = 100000;

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    // timebase = sbi_timebase() / 500;
    clock_set_next_event();

    // initialize time counter 'ticks' to zero
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
```

上述代码中，最核心的就是 设置下一次时钟中断的函数`clock_set_next_event()`，该函数是把**当前的时刻+固定时间间隔**作为下一次产生时钟中断的时间。上述代码里的`get_cycles()`函数是计算执行到当前指令时距CPU开始运转时已经过去了多少周期，当然这里换成具体的时间值也是可以的。

上述代码里还有`clock_init()`函数的定义，可以看到该函数通过调用`clock_set_next_event()`函数来初始化第一次时钟中断。

### 3.扩展练习Challenge1

#### 3.1 ucore 中处理中断异常的流程

1. 操作系统捕捉到计算机运行时产生的异常或中断；
2. 访问`stvec`寄存器，来定位中断处理程序。若`stvec`寄存器最低2位是00，则说明其高位保存的是唯一的中断处理程序的地址；如果是01，说明其高位保存的是中断向量表的地址，操作系统通过不同的异常原因来索引中断向量表以获取处理程序的地址。在本次实验中，我们是在第一种情况下进行实验，因此高位要保存处理程序的地址。
3. 在本实验中我们将`stvec`的值设置成为中断入口点`__alltraps`的地址。进入中断入口点后，操作系统通过`SAVE_ALL`汇编宏来保存上下文，然后进入`trap()`函数进行处理。
4. 在`trap_dispatch()`函数中，根据`tf->casue`的首位来判断捕捉到的是中断还是异常，分别交给`interrupt_handler()`或`exception_handler()`函数来进行处理。
5. 处理完成后，会执行`__trapre`t部分的代码。主要是通过`RESTORE_ALL`汇编宏恢复各个寄存器的值，然后通过`sret`指令把`sepc`的值赋值给`pc`，继续执行中断指令之后的程序指令。

#### 3.2 一些问题

1. `mov a0，sp` 的目的是什么？

   **答：**该指令是把保存上下文之后的栈顶指针寄存器赋值给a0寄存器，a0寄存器是参数寄存器，这样就可以把当前的中断帧作为参数传递给中断处理程序，从而实现对中断的处理。

2. `SAVE_ALL`中寄存器保存在栈中的位置是什么确定的。

   **答：**各个寄存器保存的位置是通过栈顶寄存器sp来索引的。在保存上下文之前我们首先通过指令`addi sp, sp, -36 * REGBYTES`，在内存中开辟出了保存上下文的内存区域，然后我们通过栈顶指针sp来访问该段区域的不同位置，从而把对应的寄存器保存在栈中。

3. 对于任何中断，`__alltraps` 中都需要保存所有寄存器吗？请说明理由。

   **答：**我们知道，保存上下文的目的是为了后续中断处理程序的进行，因此要保存的寄存器取决于中断处理程序的具体需求和设计。我们认为并非所有中断都需要保存所有的寄存器。一方面，对于某些中断，其处理程序可能只会用到几个寄存器，我们只需要将这些寄存器保存下来即可，若所有中断都保存所有寄存器，那会使得系统的性能和效率大大降低；另一方面，有很多寄存器的值实际上是不会受中断影响而改变的，对于这部分寄存器我们完全可以不用保存，减少程序的空间和时间开销。

   

### 4.扩增练习Challenge2

1. `csrw sscratch, sp；csrrw s0, sscratch, x0` 实现了什么操作，目的是什么？

   **答：**`csrw sscratch, sp`指令把原先上文的栈顶指针sp赋值给sscratch寄存器。

   `csrrw s0, sscratch, x0`指令先把sscratch寄存器里存储的上文栈指针的值写入s0寄存器，用于后续存入内存实现上文的保存；然后把零寄存器x0复制给sscratch，实现sscratch的清零，以便后续标识中断前程序处于S态。

   这两句指令实现了上下文的切换，把上文的内容保存在内存之中，然后加载下文，以便安全地执行异常处理，然后在完成后返回原始上下文。

2. `SAVE_ALL`里面保存了stval,scause 这些csr，而在`RESTORE_ALL`里面却不还原它们？那这样store的意义何在呢？

   **答：**这两个csr仅仅是在中断程序处理的过程中被需要，用来查询中断产生的具体的类别以及相关的原因，用于中断处理程序的执行。而在中断处理程序结束后，我们便不再需要这些信息，并且之后也可以安全地覆盖这两个寄存器，所以就不再进行恢复。

   

### 5.扩展练习Challenge3

我们编程完善的代码如下：

```C
	case CAUSE_ILLEGAL_INSTRUCTION:
		// 非法指令异常处理
		/* LAB1 CHALLENGE3   YOUR CODE : */
	   /*(1)输出指令异常类型（ Illegal instruction）
		*(2)输出异常指令地址
		*(3)更新 tf->epc寄存器
	   */
		cprintf("Exception type:Illegal instruction \n");
		cprintf("Illegal instruction exception at 0x%016llx\n", tf->epc);//采用0x%016llx格式化字符串，用于打印16位十六进制数，这个位置是异常指令的地址,以tf->epc作为参数。
		//%016llx中的%表示格式化指示符的开始，0表示空位补零，16表示总宽度为 16 个字符，llx表示以长长整型十六进制数形式输出。
		tf->epc += 4;//指令长度都为4个字节
		break;
	case CAUSE_BREAKPOINT:
		//断点异常处理
		/* LAB1 CHALLLENGE3   YOUR CODE : */
		/*(1)输出指令异常类型（ breakpoint）
		 *(2)输出异常指令地址
		 *(3)更新 tf->epc寄存器
		*/
		cprintf("Exception type: breakpoint \n");
		cprintf("ebreak caught at 0x%016llx\n", tf->epc);
		tf->epc += 2;//ebreak指令长度为2个字节，为了4字节对齐
		break;
```

在代码中，我们主要解释两个部分。

1. 在输出异常指令的地址时，我们利用了`0x%016llx`格式化字符串，用于打印16位十六进制数，即我们的64位地址。
2. 非法指令异常处理结束后，我们把`tf->epc`的值加了4，这是因为导致该异常的指令`mret`的长度为4字节，因此我们通过该操作便能够成功在程序顺序执行过程中跳过非法指令。断点异常处理结束后，我们把`tf->epc`的值加了2，这是由于导致该异常的指令`ebreak`的长度是2字节，为了保存指令的四字节对其，我们便只加2。

在上述处理结束后，我们通过`RETORE_ALL`和`sret`指令，把更新后的sepc的值赋值给pc，使得程序跳过非法指令继续执行。

## 三、与参考答案的对比

本实验总体来说较为简单，而且答案也较为固定，我们组的答案与参考答案相比差距不大，因此不再过多对比分析。

## 四、实验中的知识点

1.异常和中断的区别

- 异常：程序执行中内部指令执行时出现的错误，例如发生缺页、非法指令等。
- 中断：CPU 的执行过程被外设发来的信号打断，例如时钟中断等。

2.异常与中断的执行流

异常：系统在S态引发异常->保存上下文到栈中->进入异常处理代码->按照异常类型处理并更新结构体epc的值->结束处理，返回引发异常的下一条指令继续执行

中断：时钟中断或其他中断触发->保存上下文到栈中->进入中断处理代码->按照中断类型处理并更新结构体epc的值->结束处理，返回触发中断的下一条指令继续执行

3.系统调用（System Call）：

- 系统调用是用户程序请求操作系统提供服务的一种方式，例如文件操作、进程管理等。
- 中断可以用于触发系统调用，使用户程序进入内核态执行相应的系统调用服务。

4.上下文切换**（**Context Switching）：

- 上下文切换是在操作系统内核中进行的重要操作，用于保存和恢复进程或线程的执行上下文。
- 中断处理通常需要进行上下文切换，以确保中断处理程序执行完毕后，能够返回到被中断的程序继续执行。

5.中断向量表（Interrupt Vector Table）：

- 中断向量表是一个数据结构，包含了所有可能的中断类型及其相应的处理程序入口地址。
- 当中断发生时，CPU会根据中断类型选择正确的中断处理程序入口地址。
