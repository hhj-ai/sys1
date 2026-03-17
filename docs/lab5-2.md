# 实验5-2: RISC-V 汇编程序调试

## 实验目的

- 掌握 gdb 调试工具的基本命令和使用方法
- 掌握 qemu、spike 模拟器的调试方法
- 学习 openocd 等其他软件

## 实验环境

- 操作系统：Windows 10+ 22H2，Ubuntu 22.04+

## 背景知识

### QEMU

QEMU (Quick EMUlator) 是一个开源的系统模拟器和虚拟机管理器。它能够在不同的主机架构之间进行转换，例如将 RISC-V 的应用程序运行在 x86 平台上。QEMU 还支持运行不同操作系统，如 Linux，Windows 和 macOS 等。除此之外，QEMU 还支持网络协议仿真，使用户能够在虚拟网络中运行和测试网络应用程序。QEMU 的可移植性和灵活性使其成为开发人员、测试人员和系统管理员的重要工具。

QEMU 的基本参数如下：

   - `-nographic`: 不使用图形窗口，使用命令行
   - `-machine`: 指定要 emulate 的机器，可以通过命令 `qemu-system-riscv64 -machine help` 查看可选择的机器选项
   - `-kernel`: 指定内核 image
   - `-append cmdline`: 使用 cmdline 作为内核的命令行
   - `-device`: 指定要模拟的设备，可以通过命令 `qemu-system-riscv64 -device help` 查看可选择的设备，通过命令 `qemu-system-riscv64 -device <device_name>,help` 查看某个设备的命令选项
   - `-drive, file=<file_name>`: 使用 file_name 作为文件系统
   - `-S`: 启动时暂停 CPU 执行
   - `-s`: `-gdb tcp::1234` 的简写
   - `-bios default`: 使用默认的 OpenSBI firmware 作为 bootloader

### GDB

GNU 调试器（GNU Debugger，缩写 gdb）是一个由 GNU 开源组织发布的、UNIX/LINUX 操作系统下的、基于命令行的、功能强大的程序调试工具。借助调试器，我们能够查看另一个程序在执行时实际在做什么（比如访问哪些内存、寄存器），在其他程序崩溃的时候可以比较快速地了解导致程序崩溃的原因。 被调试的程序可以是和gdb在同一台机器上，也可以是不同机器上。

总的来说，gdb 可以有以下 4 个功能：

- 启动程序，并指定可能影响其行为的所有内容
- 使程序在指定条件下停止
- 检查程序停止时发生了什么
- 更改程序中的内容，以便纠正一个bug的影响

GDB 的基本命令如下：

- (gdb) layout asm: 显示汇编代码
- (gdb) start: 单步执行，运行程序，停在第一执行语句
- (gdb) continue: 从断点后继续执行，简写 `c`
- (gdb) next: 单步调试（逐过程，函数直接执行），简写 `n`
- (gdb) step instruction: 执行单条指令，简写 `si`
- (gdb) run: 重新开始运行文件（run-text：加载文本文件，run-bin：加载二进制文件），简写 `r`
- (gdb) backtrace：查看函数的调用的栈帧和层级关系，简写 `bt`
- (gdb) break 设置断点，简写 `b`
    - 断在 foo 函数: `b foo`
    - 断在某地址: `b * 0x80200000`
- (gdb) finish: 结束当前函数，返回到函数调用点
- (gdb) frame: 切换函数的栈帧，简写 `f`
- (gdb) print: 打印值及地址，简写 `p`
- (gdb) info：查看函数内部局部变量的数值，简写 `i`
    - 查看寄存器 ra 的值: `i r ra`
- (gdb) display：追踪查看具体变量值

更多命令可以参考[100 个 gdb 小技巧](https://wizardforcel.gitbooks.io/100-gdb-tips/content/index.html)

### Spike

Spike 是一个和 Qemu 类似的指令模拟器。虽然它不像 Qemu 那样支持各种指令集架构，可以模拟复杂的外设，但是在 RISCV 的模拟和支持上，Spike 严格按照 RISCV 的指令集手册逐条执行，对于 RISCV 程序的检查更为严谨。并且 Spike 因其简洁易修改，而被广泛用于科研领域。如果读者想要了解其 RISCV 机制的具体实现，可以阅读 Spike 的[源码](https://github.com/riscv/riscv-isa-sim)。

Spike 的基本参数如下：

- `-p<n>`: 模拟的 core 个数
- `m<a:m,b:n,...>`: 模拟的内存块和对应的内存范围
- `-d`: 交互调试模式
- `--log=<name>`: 将执行的中间 log 保存在文件中
- `-H`: 在等待调试器连接时不执行程序
- `--rbb-port=<port>`: 开放给调试器连接的调试端口

执行`Spike -d <可执行程序名>`就可以在 Spike 上直接执行 riscv 程序，且可以进行汇编级别的调试，调试的基本命令如下：

- (spike) 回车: 单步执行一条汇编程序
- (spike) `help/h`: 查看调试命令介绍
- (spike) `reg <core> <reg>`: 查看指定 core 的通用寄存器的值，core 从 0 开始编号
- (spike) `freg <core> <reg>`: 查看指定 core 的浮点寄存器的值
- (spike) `pc <core>`: 查看指定 core 的当前 pc
- (spike) `mem [core] <hex addr>`: 查看指定 core 对应地址的内存
- (spike) `until pc <core> val`: 执行程序直到指定 core 的 pc 值为 val，类似于 gdb 打断点
- (spike) `quit/q`: 退出 Spike

### Openocd

在 RISCV core 调试的场景下，RISCV 芯片为了方便硬件调试内部的信息会在内部集成一个 debug module，并对外暴露一个 JTAG 接口。调试者可以用 JTAG 线的输入线向 debug module 输入命令，并用输出线得到需要读取的结果。Spike 用于调试的 rbb-port 就是一个模拟的 JTAG 接口，但是我们无法直接用 gdb 对一个 JTAG 接口进行调试，openocd 起到一个中间桥梁的作用，它可以将 jtag 的数据协议和 gdb 的数据协议进行转换，从而实现 gdb 调试 riscv core 的目的。

openocd 的基本参数如下：

- `-f <path_to_config_file>`: 选择 OpenOCD 的配置文件路径。配置文件描述了目标板、调试接口和其他调试选项的设置，如提供的 spike.cfg
- `-c "<command>"}`: 指定要在 OpenOCD 启动时执行的命令，可以多次使用该参数以指定多个命令。
- `-s <path_to_scripts>`: 指定脚本文件路径，包含了一些常用的调试命令和配置选项。
- `-d <debug_level>`: 调试输出的级别，0（禁用调试输出）到 9（最详细的调试输出）之间的值。

## 实验步骤

### qemu 程序调试

#### 实验环境配置

1. 安装 QEMU
   ```shell
   sudo apt install qemu-user
   ```
   运行`qemu-riscv64 --version`检测安装是否成功。

2. 安装 GDB
   ```shell
   sudo apt install gdb-multiarch
   ```
   运行`gdb-multiarch --version`检测安装是否成功。

#### 尝试通过调试破解数据<font color=Red>30%</font>

我们提供了一个 C 文件 `src/lab5-2/challenge.c`。运行下面的命令编译得到可执行文件 challenge，该命令可以让可执行程序不进行优化、且包含调试信息，便于之后的调试和逆向。

```shell
riscv64-linux-gnu-gcc -g -O0 challenge.c -o challenge
```

然后执行该程序：

```shell
qemu-riscv64 challenge
```

如果出现 `qemu-riscv64: Could not open '/lib/ld-linux-riscv64-lp64d.so.1': No such file or directory` 尝试执行以下命令将 /usr 的库搬到搜索位置：

```shell
sudo cp /usr/riscv64-linux-gnu/lib/* /lib/
```

运行后会提示你输入你的学号，输入完成后按下回车键。随后，该程序会根据你的学号计算三组不可见的机密数据，然后依次输出提示语句，要求你依次输入满足这三组机密数据的字符串，字符串有且仅有 0-f 这 16 个字符组成。如果输入满足条件，则会提示通过。（xxx 表示需要输入的数据，其内容因各位同学的学号而异）

```shell
qemu-riscv64 challenge
please input your student ID:xxxxxxxxxx
Welcome to my fiendish little bomb. You have 3 phases with
xxxxx
Phase 1 defused. How about the next one?
xxxxx
Phase 2 defused. How about the next one?
xxxxx
Phase 3 defused.
```

如果中间有数据输入失败，则会看到如下的报错：

```shell
qemu-riscv64 challenge
please input your student ID:xxxxxxxxxx
Welcome to my fiendish little bomb. You have 3 phases with
xxxxx
Phase 1 defused. How about the next one?
xxxxx
Bomb! You fail to defuse the second bomb!
```

三个字符串的内容、长度都是未知，需要大家阅读 C 代码、通过 gdb 调试逆向出满足要求的字符串。这里不允许修改 C 源代码，或者至少要有一个不修改源代码调试得到字符串内容的过程。

提示:

1. 用 `riscv64-linux-gnu-objdump` 可以打印该程序的汇编代码：
    ```shell
    riscv64-linux-gnu-objdump -d challenge > challenge.asm
    ```
    在没有 C 代码的情况下，通过阅读汇编代码可以知道程序的内部细节

2. 利用 GDB 调试该程序，这一步需要开启两个 Terminal（终端），一个 Terminal 用 QEMU 运行程序，另一个 Terminal 使用 GDB 与 QEMU 进行远程通信调试：
    ```shell
    # Terminal 1
    qemu-riscv64 -g 1234 challenge # 1234 为 qemu 开放给 gdb 远程连接的端口

    # Terminal 2
    gdb-multiarch challenge
    (gdb) target remote localhost:1234 # 连接上另一个terminal的 QEMU
    (gdb) b main      # 在 main 函数上设置断点
    (gdb) c           # 继续运行，GDB 会让程序运行直到遇到一个断点（在这里即 main 函数）
    (gdb) b phase_1   # 在 phase_1 函数上设置断点
    (gdb) c           # 继续运行，此时可以在 QEMU 的 Terminal 处输入学号和第一个字符串，然后GDB就会让程序在 phase_1 函数处停止
    ...
    (gdb) q        # 退出gdb
    ```

3. 破译字符串的内容不需要完全理解 phase_x 函数内容。该实验练习的是快速理解汇编代码中关键步骤以及基本的 GDB 调试程序的能力，所以最快速的方法是找到 phase_x 函数的关键点，然后利用 GDB 下断点，并查看断点附近单步跟踪和检查寄存器、变量状态，即可获取快速的到寄存器的结果。

4. 3 个 phase_x 函数考察的调试能力各有侧重：

    - phase_1 考察 C 源码程序的调试，重点在于断点设置和变量查看<font color=Red>10%</font>

    - phase_2 是 phase_1 的升级版本，除了断点设置和变量查看，还要适当进行推断和计算<font color=Red>10%</font>

    - phase_3 考察汇编程序的调试，重点在于汇编寄存器的语义分析和单步跟踪<font color=Red>10%</font>

    每通过一个 phase 获得 10% 的分数。

### spike 程序调试

#### 实验环境配置

1. 安装 spike
    ```shell
    git submodule update --init repo/riscv-isa-cosim
    cd repo
    make spike
    ```
    运行 `spike` 检测安装是否成功。

2. 安装 openocd
    ```shell
    git submodule update --init repo/riscv-openocd
    cd repo
    make openocd
    ```
    运行 `openocd --version` 检测安装是否成功。

如果 `make openocd` 时出现类似于 `configure.ac:32: error: Macro PKG_PROG_PKG_CONFIG is not available. It is usually defined in file pkg.m4 provided by package pkg-config.` 的错误说明找不到 PKG_PROG_PKG_CONFIG 的宏定义，需要运行以下命令安装 pkg-config 来解决：

```shell
sudo apt install pkg-config
```

#### 调试串口工作函数

当我们用 `spike pk challenge` 执行我们的程序的时候，spike 模拟了 riscv 的处理器，pk 模拟了 sbi 和操作系统，challenge 执行在操作系统上的程序。当 challenge 调用 scanf 和 printf 函数读取和输出字符串的时候，其实是使用 spike 模拟的串口（回忆 lab4-2）来进行数据收发的。

bbl 是 riscv-pk 组件的一部分，是一个轻量级的 sbi，uart 的数据收发最终也是被 bbl 调用的，所以请尝试阅读 riscv-pk 中的 bbl 源码和调试 bbl，定位 printf 函数最终执行字符发送的指令。如果之前在本地编译了 riscv-pk，则 bbl 在 repo/build/riscv-pk/ 文件夹中。

首先执行 `spike -H --rbb-port=9824 <bbl的路径>`，该程序会在 spike 上执行 bbl，并开放 9824 端口给调试调试器链接。-H 确保在调试器连接之前 spike 不开始模拟。如果你的 riscv-pk 不是采用在 repo 中 `make pk` 自动安装的，请改为自己安装的riscv-pk下的bbl路径。

```shell
sys1-sp{{ year }}/src/lab5-2# spike -H --rbb-port=9824 ../../repo/build/riscv-pk/bbl
Listening for remote bitbang connection on port 9824.
```

在新的 terminal 执行 `openocd -f spike.cfg`，spike.cfg 中存储了 spike 连接的配置参数，之后 openocd 会自动连接 spike 的调试端口，并且开放 3333 端口给 gdb 进行调试连接，最终起到 spike 和 gdb 的桥梁作用。

```shell
sys1-sp{{ year }}/src/lab5-2# openocd -f spike.cfg 
Open On-Chip Debugger 0.12.0+dev-02917-g58b6a5eab (2023-10-02-16:02)
Licensed under GNU GPL v2
For bug reports, read
        http://openocd.org/doc/doxygen/bugs.html
DEPRECATED! use 'adapter driver' not 'interface'
Info : only one transport option; autoselect 'jtag'
   ...
Info : [riscv.cpu] datacount=2 progbufsize=2
Info : [riscv.cpu] Examined RISC-V core; found 1 harts
Info : [riscv.cpu]  XLEN=64, misa=0x800000000014112d
[riscv.cpu] Target successfully examined.
Info : starting gdb server for riscv.cpu on 3333
Info : Listening on port 3333 for gdb connections
Info : Listening on port 6666 for tcl connections
Info : Listening on port 4444 for telnet connections
```

最后使用 gdb 连接 3333 端口调试即可，执行 `gdb-multiarch ../../repo/build/riscv-pk/bbl` 启动 gdb 并加载目标程序。

```shell
Reading symbols from ../../repo/build/riscv-pk/bbl...
(No debugging symbols found in ../../repo/build/riscv-pk/bbl)
(gdb) target remote : 3333
Remote debugging using : 3333
0x0000000000001000 in ?? ()
(gdb) b printm
Breakpoint 1 at 0x80001c82
(gdb) c
Continuing.

Breakpoint 1, 0x0000000080001c82 in printm ()
(gdb) 
```

提示：

bbl 会调用 printm 函数输出字符串，所以大家可以沿着 printm 函数进行调试找到对应的串口调用函数，进而找到执行串口输出的关键语句。当这条关键指令被执行后，可以看到 spike 界面出现了一个字符串的输出。

```shell
/sys1-sp{{ year }}/src/lab5-2# spike -H --rbb-port=9824 ../../repo/build/riscv-pk/bbl
Listening for remote bitbang connection on port 9824.
h
```

## 5 实验报告<font color=Red>30%</font>

实验报告要求：

1. qemu 调试部分给出调试过程的关键截图，并且给出自己推断得到字符串的调试过程和推断依据。（这次调试过程中不允许修改 C 源代码，更不允许使用 printf 大法）<font color=Red>30%</font>


2. spike 调试部分给出调试过程的关键截图，并且给出 printm 到第一个字符输出的函数调用链、输出字符的关键函数、输出字符那一句汇编。(bonus)

3. 调试定位了串口字符输出的函数之后，阅读 riscv-pk 对应的该函数的源码，尝试理解串口字符输出的具体细节。(bonus)