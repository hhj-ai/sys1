# 实验5-1: RISC-V汇编程序设计

## 实验目的

- 理解 RISC-V 汇编程序
- 能够用 RISC-V 汇编指令编写简单的汇编程序

## 实验环境

- 操作系统：Windows 10+ 22H2，Ubuntu 22.04+

## 背景知识

### RISC-V 汇编语言

RISC-V 汇编语言是一种基于 RISC-V 指令集架构的低级程序设计语言，它被广泛用于嵌入式系统、操作系统和编译器的开发中。RSIC-V 因为结构规整、内容精简而被广泛应用于课程教学。你们在课上学习了基本的 RISC-V 指令，但由编译器生成的汇编指令中可能含有一些你们没有接触过的指令或伪指令。当遇到这些指令时，请到 [RISC-V ISA Specifications](https://riscv.org/technical/specifications/) 查询相关文档 (Volume 1, Unprivileged Specification)。

### RISC-V 调用约定

RISC-V 调用约定是指在函数调用时，调用方和被调用方之间所达成的一种规定，用于确保函数调用和返回的正确性。RISC-V 调用约定规定了在函数调用和返回时需要保存哪些寄存器的值、哪些寄存器可以被调用者使用等等，以保证程序正确地执行。

以下是 RISC-V 调用约定的一些基本特点：

- 参数传递：函数参数通常通过寄存器传递，前几个参数通常存储在 a0、a1、a2、a3 等寄存器中，更多的参数则会存储在栈中。
- 返回值：函数返回值通常存储在 a0 寄存器中，对于返回值比较复杂的情况，也可以将返回值存储在栈中。
- 寄存器的使用：RISC-V 调用约定规定了哪些寄存器需要被调用方保存，哪些寄存器可以被调用者使用。一般来说，保存 callee-saved 寄存器是被调用者的责任，而调用者则可以使用 caller-saved 寄存器，但需要在函数调用之前将这些寄存器的值保存下来。
- 栈的使用：RISC-V 调用约定还规定了在函数调用期间如何使用栈。在函数调用时，栈用于存储函数的参数、返回地址和 callee-saved 寄存器的值。在函数返回时，栈则被用于恢复调用者保存的寄存器和返回地址。

RISC-V 调用约定的具体文档请查阅 [Calling Convention](https://riscv.org/wp-content/uploads/2015/01/riscv-calling.pdf)。

### SPIKE 模拟器和 RISCV PK

SPIKE 是一个基于 RISC-V ISA 模拟器，它可以让你在非 RISC-V 架构的机器上模拟执行 RISC-V 程序。

RISCV PK(RISC-V Proxy Kernel)是一个基于 RISC-V ISA 的轻量级操作系统内核，它是一个开源项目，由 UC Berkeley 开发并维护。RISCV PK 旨在提供一个最小化的操作系统内核，以便在不同的 RISC-V 处理器上运行各种用户空间应用程序。

### 跳转表

跳转表是一种用于跳转到不同代码块的数据结构。跳转表通常由一组指针或地址组成，这些指针或地址指向不同的代码块。跳转表的实现方式很简单，通常使用数组或哈希表来实现。跳转表通常用于替代大量的 if-else 语句或 switch 语句，可以提高代码的执行效率。当需要根据一个值来选择不同的代码路径时，可以使用跳转表来实现。在跳转表中，每个值都对应着一个指针或地址，这个指针或地址指向对应的代码块。

跳转表在编程语言中广泛应用，特别是在一些低级语言中，如汇编语言和 C 语言。在 RISC-V 汇编中，跳转表通常使用 la(load address)指令来加载地址，然后使用 jr(jump register)或 jalr(jump and link register)指令来进行跳转。

关于跳转表的具体介绍，请参考 CSAPP（深入了解计算机系统）第三章关于 switch 语句的介绍。

### 冒泡排序

冒泡排序是一种简单的排序算法，它重复地遍历需要排序的数组，每次比较相邻的两个元素，如果它们的顺序错误就交换它们。通过不断地交换相邻元素的位置，把大的元素交换到数组的末尾，最终实现整个数组的排序。

具体来说，冒泡排序的过程如下：

1. 从数组的第一个元素开始，依次比较相邻的两个元素，如果它们的顺序错误就交换它们的位置，把大的元素交换到数组的末尾。
2. 继续遍历数组，依次比较相邻的两个元素，重复上述步骤，直到整个数组排序完成。

可以参考该[动画网页](https://visualgo.net/en/sorting)来理解冒泡排序的过程。

## 实验步骤

### 实验环境配置

1. 安装 RISC-V 工具链:

    ```shell
    sudo apt install gcc-riscv64-linux-gnu binutils-riscv64-linux-gnu
    ```

    然后运行 `riscv64-linux-gnu-gcc --version` 命令判断安装是否成功。

2. 选择合适的位置安装 SPIKE 模拟器

    ```shell
    sudo apt install device-tree-compiler
    git clone http://git.zju.edu.cn/zju-sys/sys1/riscv-isa-sim.git
    cd riscv-isa-sim
    mkdir build && cd build
    ../configure
    make -j$(nproc)
    ```

    也可以直接使用我们的提供的安装脚本（需要管理员权限）：
    ```shell
    sudo apt install device-tree-compiler
    git submodule update --init repo/riscv-isa-cosim
    cd repo
    make spike
    ```

3. 选择合适的位置（在 Linux 下，不要在 Windows 下安装）安装 RISC-V Proxy Kernel

    ```shell
    git clone https://git.zju.edu.cn/zju-sys/sys1/riscv-pk.git
    cd riscv-pk
    mkdir build && cd build
    ../configure --host=riscv64-linux-gnu
    make -j$(nproc)
    ```

    也可以直接使用我们的提供的安装脚本（需要管理员权限）：

    ```shell
    git submodule update --init repo/riscv-pk
    cd repo
    make pk
    ```

4. 进入到 `sys1-sp{{ year }}` 文件夹拉取上游修改:

    ```shell
    git pull
    ```

5. 补全 `src/lab5-1/simulate.sh` 脚本中的 `SPIKE_PATH` 和 `PK_PATH` 变量为第二步中 spike 的路径和第三步中 pk 的路径（请确保 shell 脚本中等号左右没有空格）。然后在 `src/lab5-1` 目录下执行 `chmod +x simulate.sh` 命令为 `simulate.sh` 脚本赋予执行权限。
    > 请不要复制 Windows 下的目录，得到目录的最直接方式是在对应目录下执行 pwd，然后复制输出。

6. 在 `src/lab5-1/` 下有一个 Hello World 程序，文件名为 `hello.c`，请在该文件夹下用以下命令编译，并测试是否能执行：

    ```shell
    riscv64-linux-gnu-gcc hello.c -o hello -static
    ./simulate.sh hello
    ```

    预期输出：
    
    > hello, world!


### 理解简单RISC-V程序<font color=Red>10%</font>
在 `src/lab5-1/acc.c` 中，实现了一个简单的累加函数

```c
long long acc(long long a, long long b) {
        long long res = 0;
        for (long long i = a; i <= b; ++i) {
                res += i;
        }
        return res;
}
```

`src/lab5-1/acc_plain.s` 是 `src/lab5-1/acc.c` 对应的一种汇编程序，由以下命令生成:

```shell
riscv64-linux-gnu-gcc -S acc.c -O0 -o acc_plain.s
```

请阅读 `src/lab5-1/acc_plain.s` 回答以下问题:

1. `acc` 是如何获得函数参数的，又是如何返回函数返回值的？<font color=Red>2%</font>
2. `acc` 函数中 `s0` 寄存器的作用是什么，为什么在函数入口处需要执行 `sd s0, 40(sp)` 这条指令，而在这条指令之后的 `addi s0, sp, 48` 这条指令的目的是什么？<font color=Red>2%</font>
3. `acc` 函数的栈帧 (stack frame) 的大小是多少？<font color=Red>1%</font>
4. `acc` 函数栈帧中存储的值有哪些，它们分别存储在哪（相对于 `sp` 或 `s0` 来说）？<font color=Red>2%</font>
5. 请简要解释 `acc` 函数中的for循环是如何在汇编代码中实现的。<font color=Red>1%</font>

> Hint: `src/lab5-1/acc_plain.s` 中出现的 `j .L2` 指令是 `jal x0, .L2` 的伪指令，请参考 [The RISC-V Instruction Set Manual Volume I: User-Level ISA](https://riscv.org/wp-content/uploads/2017/05/riscv-spec-v2.2.pdf) 第 110 页的 Table 20.2。


`src/lab5-1/acc_opt.s` 也是 `src/lab5-1/acc.c` 对应的一种汇编程序，它由另一种命令生成：

```shell
riscv64-linux-gnu-gcc -S acc.c -O2 -o acc_opt.s
```

请阅读 `src/lab5-1/acc_opt.s` 回答以下问题：

1. 请查阅资料简要描述编译选项 `-O0` 和 `-O2` 的区别。<font color=Red>1%</font>
2. 请简要讨论 `src/lab5-1/acc_opt.s` 与 `src/lab5-1/acc_plain.s` 的优劣。<font color=Red>1%</font>

### 理解递归汇编程序<font color=Red>15%</font>

在 `src/lab5-1/factor.c` 中，实现了一个通过递归求解阶乘的函数 `factor`：

```c
long long factor(long long n) {
        if (n == 0) {
                return 1;
        }
        return n * factor(n - 1);
}
```

`src/lab5-1/factor_plain.s` 是 `src/lab5-1/factor.c`对应的一种汇编程序，由以下命令生成:

```shell
riscv64-linux-gnu-gcc -S factor.c -O0 -o factor_plain.s
```

请阅读 `src/lab5-1/factor_plain.s` 回答以下问题:

1. 为什么 `src/lab5-1/factor_plain.s` 中 `factor` 函数的入口处需要执行 `sd ra, 24(sp)` 指令，而 `src/lab5-1/acc_plain.s` 中的 `acc` 函数并没有执行该指令？<font color=Red>2%</font>
2. 请解释在 `call factor` 前的 `mv a0, a5` 这条汇编指令的目的。<font color=Red>2%</font>
3. 请简要描述调用 `factor(10)` 时栈的变化情况；并回答栈最大内存占用是多少，发生在什么时候。<font color=Red>3%</font>
4. 假设栈的大小为4KB，请问 `factor(n)` 的参数 `n` 最大是多少？<font color=Red>2%</font>

> Hint: `mul a5, a4, a5` 的含义是将 a4 寄存器和 a5 寄存器的内容相乘，并将结果放在 a5 寄存器中。call 指令是一条伪指令，参考 [The RISC-V Instruction Set Manual Volume I: User-Level ISA](https://riscv.org/wp-content/uploads/2017/05/riscv-spec-v2.2.pdf) 第 110 页的 Table 20.2。


`src/lab5-1/factor_opt.s` 也是 `src/lab5-1/factor.c` 对应的一种汇编程序，它由另一种命令生成：

```shell
riscv64-linux-gnu-gcc -S factor.c -O2 -o factor_opt.s
```

请阅读 `src/lab5-1/factor_opt.s` 回答以下问题:

1. 请简要描述 `src/lab5-1/factor_opt.s` 和 `src/lab5-1/factor_plain.s` 的区别。<font color=Red>2%</font>
2. 请从栈内存占用的角度比较 `src/lab5-1/factor_opt.s` 和 `src/lab5-1/factor_plain.s` 的优劣。<font color=Red>2%</font>
3. 请查阅*尾递归优化*的相关资料，解释编译器在生成 `src/lab5-1/factor_opt.s` 时做了什么优化，该优化的原理，以及什么时候能进行该优化。<font color=Red>2%</font>

### 理解 switch 语句产生的跳转表<font color=Red>5%</font>

在 `src/lab5-1/switch.c` 中实现了一个简单的基于 switch 语句的函数 `switch_eq`:

```c
int switch_eg(long long x, long long y) {
	long long result = y;
	switch (x) {
	case 20:
		result = result - 5;
	case 21:
		result = result + 19;
		break;
	case 22:
		result += 11;
		break;
	case 24:
	case 26:
		result -= 20;
		break;
	default:
		result = 0;
	}
	return result;
}
```

`src/lab5-1/switch.s` 为该函数的汇编版本，由以下命令生成：

```shell
riscv64-linux-gnu-gcc -S switch.c -O2 -o switch.s
```

请阅读这两个文件并回答以下问题:

1. 请简述在 `src/lab5-1/switch.s` 中是如何实现 switch 语句的。<font color=Red>2%</font>
2. 请简述用跳转表实现 switch 和用 if-else 实现 switch 的优劣，在什么时候应该采用跳转表，在什么时候应该采用 if-else。<font color=Red>3%</font>

> Hint: (1) `lla a4,.L4`的意思是将 .L4 这个 label 的地址加载到 `a4` 寄存器中; (2) 跳转表部分可以参考 CSAPP（深入理解计算机系统）第三章中关于 switch 语句的介绍，虽然 CSAPP 中的介绍是基于 x64 的，但是原理与 RISC-V 上一致。

### 设计冒泡排序的汇编代码<font color=Red>20%</font>

请在 `src/lab5-1/bubble_sort.s` 中实现冒泡排序函数 `bubble_sort`，其函数签名为 `void bubble_sort(long long *arr, long long len)`，该函数将长度为 `len` 的数组 `arr` 在原地从小到大排序。

我们提供了 `src/lab5-1/bubble_sort_test.c` 文件用于测试你的实现是否正确，当你完成 `bubble_sort.s` 的编写后，在 `src/lab5-1/` 文件夹下用以下命令进行编译和测试：

```shell
riscv64-linux-gnu-gcc bubble_sort_test.c bubble_sort.s -o bubble_sort_test -static
./simulate.sh bubble_sort_test
```

如果测试通过，会在终端显示 `Sort Successfully` 的提示信息，否则会输出错误提示。

该实验要求汇编代码要尽可能注释（最好每一行都要有注释）。同时请不要先编写C语言程序再用编译器生成汇编代码，我们会比对你的代码与编译器生成的代码；并且考虑到考试中可能出现手写汇编的题目，请把这次实验的汇编代码编写当作一次练习。

### 设计斐波那契数列的汇编代码<font color=Red>20%</font>

请在 `src/lab5-1/fibonacci.s` 中实现求斐波那契数列第$n$项的函数，其函数签名为 `long long fibonacci(long long n)`。其中 `fibonacci(0) = fibonacci(1) = 1`; `fibonacci(n) = fibonacci(n-1) + fibonacci(n-2), n >= 2`。要求该函数用递归实现，即使你知道可以用动态规划实现，也请用最简单的递归实现。

我们也提供了 `src/lab5-1/fibonacci_test.c` 文件用于测试你的实现是否正确，当你完成 `fibonacci.s` 的编写后，在 `src/lab5-1/` 文件夹下用以下命令进行编译和测试：

```shell
riscv64-linux-gnu-gcc fibonacci_test.c fibonacci.s -o fibonacci_test -static
./simulate.sh fibonacci_test
```

同样的，该实验也要求汇编代码要尽可能注释，并且禁止提交由C语言程序编译生成的汇编代码。

## 实验报告<font color=Red>70%</font>

lab5汇编实验无需验收，故分数完全由报告组成，其中lab5-1（本次）占实验分数的 <font color=Red>70%</font>，lab5-2占 <font color=Red>30%</font>。
请同学们按要求提交实验报告和源代码文件：

1. 实验报告中需包括你对 4.1 到 4.3 节中问题的回答，以及解释 4.4 节与 4.5 节你编写的汇编代码。
2. 源代码文件需要包含 `bubble_sort.s` 和 `fibonacci.s` 两个文件。