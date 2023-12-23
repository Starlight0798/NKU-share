@ 数据段
.data
fib_info:
    .asciz "The number of fibonacci: "    @ 斐波那契数列提示信息
fib_output:
    .asciz "%d\n"                         @ 输出格式
input_format:
    .asciz "%d"                           @ 输入格式

@ 代码段
.text
.global main                              @ 设置主函数为全局可见

@ 斐波那契函数
fibonacci:
    push {r4-r7, lr}
    cmp r0, #1                             @ 如果 n <= 1
    ble .fib_return_n
    mov r1, #1                             @ i 初始化为 1
    mov r2, #0                             @ a 初始化为 0
    mov r3, #1                             @ b 初始化为 1

.fib_loop:
    add r4, r2, r3                         @ sum = a + b
    mov r2, r3                             @ a 赋值为 b
    mov r3, r4                             @ b 赋值为 sum
    add r1, r1, #1                         @ i 加 1
    cmp r1, r0                             @ 比较 i 和 n
    blt .fib_loop

    mov r0, r3                             @ 返回 b 的值
    pop {r4-r7, pc}

.fib_return_n:
    pop {r4-r7, pc}                        @ 直接返回 n 的值

@ 主函数
main:
    push {r4-r7, lr}

    @ 输入 n
    ldr r0, addr_fib_info
    bl printf
    sub sp, sp, #4                         @ 为 n 分配空间
    ldr r0, addr_input_format
    mov r1, sp
    bl scanf
    ldr r0, [sp]
    add sp, sp, #4

    @ 调用斐波那契函数
    bl fibonacci
    mov r5, r0                             @ ans = r0

    @ 使用0到4初始化 fib_array
    sub sp, sp, #20                        @ 为 fib_array[5] 分配空间
    mov r6, #0                             @ i 初始化为 0
    mov r7, sp                             @ fib_array 的起始地址

.init_loop:
    str r6, [r7], #4                       @ fib_array[i] = i
    add r6, r6, #1                         @ i 加 1
    cmp r6, #5
    blt .init_loop

    @ 输出 ans
    ldr r0, addr_fib_output
    mov r1, r5
    bl printf

    @ 清理并返回
    add sp, sp, #20                        @ 弹出 fib_array
    mov r0, #0
    pop {r4-r7, pc}

addr_fib_info:
    .word fib_info
addr_fib_output:
    .word fib_output
addr_input_format:
    .word input_format
