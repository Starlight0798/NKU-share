@ 数据段
@ 全局变量及常量的声明
    .data
n:
    .word 0
i:
    .word 2
f:
    .word 1

@ 代码段
    .text
    .align 4
res_msg:
    .asciz "%d的阶乘为: %d\n"
    .align 4
info_msg:
    .asciz "请输入要计算阶乘的数: "
input_format:
    .asciz "%d"
    .align 4

@ 主函数
    .global main
    .type main, %function
main:
    @ mov r7, lr
    push {fp, lr}  @ 保存返回地址栈基地址

    @ 输出提示信息
    adr r0, info_msg
    bl printf

    mov r8, lr
    adr r0, input_format
    sub sp, sp, #4   @ 留出一个4字节的空间，保存用户输入
    mov r1, sp
    bl scanf   
    ldr r2, [sp, #0]  @ 读取用户输入的值
    ldr r1, addr_n
    str r2, [r1]  @ 保存n到对应地址中
    add sp, sp, #4
    mov lr, r8

    @ 调用Factorial函数
    mov r0, r2
    bl Factorial

    @ 准备printf的参数并调用printf函数
   
    adr r0, res_msg
    ldr r1, =n
    ldr r1, [r1]
    mov r2, r4 @ 读取Factorial的返回值
    bl printf

    pop {fp, lr}  @ 返回地址出栈
    bx lr  @ 返回

@ Factorial函数
    .align 4
Factorial:
    push {fp, lr}  @ 保存Factorial函数的返回地址
    mov fp, sp  @ 设置新的栈基地址

    @ 初始化局部变量
    ldr r3, addr_i
    ldr r3, [r3]  @ 变量i
    ldr r4, addr_f
    ldr r4, [r4]  @ 变量f

.LOOP:
    cmp r3, r0  @ 判断i与n大小关系
    bgt .END    @ 当i > n时跳转至END结束循环

    @ 计算阶乘
    mul r4, r4, r3  @ f *= i
    add r3, r3, #1  @ i++

    b .LOOP

.END:
    mov sp, fp  @ 恢复栈指针
    pop {fp, lr}  @ 恢复返回地址
    bx lr  @ 返回

@ 桥接全局变量的地址
addr_n:
    .word n
addr_i:
    .word i
addr_f:
    .word f

    .section   .note.GNU-stack,"",%progbits

