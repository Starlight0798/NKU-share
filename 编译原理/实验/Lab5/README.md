# 2023lab5-类型检查与中间代码生成
For 2023Fall NKUCS Course - Principle of Compilers Lab5

> Lab5: Type Check & Intermediate Code Generation
>
> Author: Emanual20 YoungCoder
> 
> Date: 2023/11/04

## 编译器命令
```
Usage：build/compiler [options] infile
Options:
    -o <file>   Place the output into <file>.
    -t          Print tokens.
    -a          Print abstract syntax tree.
    -i          Print intermediate code
```

## VSCode调试

提供了VSCode调试所需的json文件，使用前需正确设置launch.json中miDebuggerPath中gdb的路径。launch.json中args值即为编译器的参数，可自行调整。

## Makefile使用

* 修改测试路径：

默认测试路径为test，你可以修改为任意要测试的路径。我们已将最终所有测试样例分级上传。

如：要测试level1-1下所有sy文件，可以将makefile中的

```
TEST_PATH ?= test
```

修改为

```
TEST_PATH ?= test/level1-1
```

* 编译：

```
    make
```
编译出我们的编译器。

* 运行：
```
    make run
```
以example.sy文件为输入，输出相应的中间代码到example.ll文件中。

* 测试：
```
    make testlab5
```
该命令会默认搜索test目录下所有的.sy文件，逐个输入到编译器中，生成相应的中间代码.ll文件到test目录中。你还可以指定测试目录：
```
    make testlab5 TEST_PATH=dirpath
```

* 批量测试：
```
    make test
```
对TEST_PATH目录下的每个.sy文件，编译器将其编译成中间代码.ll文件， 再使用llvm将.ll文件汇编成二进制文件后执行， 将得到的输出与标准输出对比， 验证编译器实现的正确性。错误信息描述如下：
|  错误信息   | 描述  |
|  ----  | ----  |
| Compile Timeout  | 生成中间代码超时， 可能是编译器实现错误导致， 也可能是源程序过于庞大导致(可调整超时时间) |
| Compile Error  | 编译错误， 源程序有错误或编译器实现错误 |
|Assemble Error| 汇编错误， 编译器生成的中间代码不能由llvm正确汇编|
| Execute Timeout  |执行超时， 可能是编译器生成了错误的中间代码|
|Execute Error|程序运行时崩溃， 可能原因同Execute Timeout|
|Wrong Answer|答案错误， 执行程序得到的输出与标准输出不同|

具体的错误信息可在对应的.log文件中查看。

* LLVM IR
```
    make llvmir
```
使用llvm编译器生成中间代码。

* 清理:
```
    make clean
```
清除所有可执行文件和测试输出。
