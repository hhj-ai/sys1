# Verilog 高级语法

## generate 语句

下面的代码将二维数组 b 的输出连接到二维数组 a 的输入，我们在 lab0-2 中提到数组之间无法直接赋值，所以只能对数组的每个成员依次连接。但是如果我们的数组是 `wire [3:0] a [255:0]` 和 `wire [3:0] b [255:0]`，难道我们要手动编写 256 个 `assign` 语句，没有更简洁的语法了吗？
```Verilog
wire [3:0] a [3:0];
wire [3:0] b [3:0];

assign b[0] = a[0];
assign b[1] = a[1];
assign b[2] = a[2];
assign b[3] = a[3];
```

Verilog 提供了 `generate` 语句和 `for` 循环来解决这个问题。
```Verilog
wire [3:0] a [3:0];
wire [3:0] b [3:0];

genvar i;
generate
    for(i=0;i<4;i=i+1)begin
        assign b[i] = a[i];
    end
endgenerate
```

`genvar i` 定义了一个仅用于 `generate` 语句内部的变量 i，这个变量仅仅是一个用于代码生成的变量，它不会生成有效的电路，因而也不会提高生成硬件的复杂度。我们可以根据自己的需要为一个 `generate` 块定义多个 `genvar`，并且一个 `genvar` 可以在多个 `generate` 块中使用。

`generate ... endgenerate` 语句块用于硬件代码生成。我们可以在 `generate` 块内部使用 `for` 循环对 `genvar` 进行赋值遍历，这里的语法和 C 语言的 for 循环语法在语法和语义上是一致的，最大的区别可能是 `genvar` 的递增仅支持 `i=i+1`，而不支持 `i+=1` 和 `i++`。

每轮循环都会根据 `genvar` 的值生成对应的 Verilog 代码，例如第一轮 `for` 循环，`i=0`，于是内部就会生成 `assign b[0]=a[0]`；第二轮 `for` 循环使得 `i=1`，于是就会生成代码 `assign b[1]=a[1]`；依此类推就可以得到完整的 `b=a` 的 Verilog 代码。

## integer 变量

细心阅读过 lab1-2 的 `testbench.v` 的同学可能会注意到这段 `for` 循环。我们在仿真的时候希望 data 的值可以遍历 0-7 但是我们不希望手动遍历这些测试样例，这个时候就可以使用 `for` 循环来加速编程效率。
```Verilog
integer i;
initial begin
    ...
    for(i=0;i<8;i=i+1)begin
        data=i[3:0];
        #5;
    end
    ...
end
```
但是 `initial` 块的 `for` 循环语法不同于 `generate` 块，它使用 `integer` 得到变量而不是 `genvar` 变量。`initial` 块的 `for` 循环和 `generate` 的 `for` 循环在语法上是保持一致的，但是语义上有细微区别：generate 的 for 循环生成的语句用于电路描述，相互之间是空间并列关系；`initial` 的 `for` 循环生成的语句用于仿真激励，依次之间是由激励的时间先后关系的。

`integer` 变量是 32 位的变量，可以认为它是一个 32 位 bit 宽的 `reg`。因此它被用于输出赋值的时候需要考虑位宽问题。之于 `integer` 是否会被综合生成电路是要看语境的，如果它被设计者用作真实的 32 位寄存器，那么会生成对应的寄存器组，如果只是被用于提供立即数或者执行 `for` 循环则会被退化为立即数。

除此之外还有 `short`、`longint` 分别是 16 位变量和 64 位变量。

## 参数化编程
即使在 C 语言中，大量使用立即数硬编码也是不合适的，如果某一个硬编码对应的数据发生了变化，所有对应的硬编码都需要随之改动，这将降低代码的可维护性。常用的方法将立即数转换为宏变量或者常量。

### 宏变量参数
如果我们想将下列二维数组的宽度从 4 变为 5，我们需要修改至少 3 处：
```Verilog
wire [3:0] a [3:0];
wire [3:0] b [3:0];

genvar i;
generate
    for(i=0;i<4;i=i+1)begin
        assign b[i] = a[i];
    end
endgenerate
```

但我们可以定义宏变量取代硬编码 3，这样就只需要修改一处就可以了，对应的硬编码都会随之修改：
```Verilog
`define LEN 4
wire [3:0] a [`LEN-1:0];
wire [3:0] b [`LEN-1:0];

genvar i;
generate
    for(i=0;i<`LEN;i=i+1)begin
        assign b[i] = a[i];
    end
endgenerate
```

### localparam 本地参数
宏变量本身只能做简单的文本替换，如果我们想要支持一些 Verilog 参数计算，也可以使用 `localparam` 参数。这就类似于 C 语言定义的 `const` 变量，`localparam` 看起来是定义了一个变量，但是在实际生成的时候只会生成对应的立即数。`localparam` 只能被赋值一次，赋值表达式可以是任意 `localparam`、`parameter`、立即数的计算结果，但是不能是电路的输出，因为 `localparam` 只是提供参数立即数，它不是电路的一部分。
```Verilog
localparam LEN=4;
wire [3:0] a [LEN-1:0];
wire [3:0] b [LEN-1:0];

genvar i;
generate
    for(i=0;i<LEN;i=i+1)begin
        assign b[i] = a[i];
    end
endgenerate
```

另外宏变量可以定义在 `module` 内部也可以定义在 `module` 外部，对整个文件的所有 `module` 都有效；而 `localparam` 只能定义在模块内部，且仅对本模块有效，所以不同模块可以有各自的 `LEN localparam`，而不必担心相互之间存在冲突。

### parameter 变量
假设我们将上面的二维数组赋值封装为一个模块 `dummy`。如果我们希望二维数组宽度为 4，则可以将 `LEN` 修改为 4；如果我们希望二维数组宽度为 5，则可以将 `LEN` 修改为 5；但是，如果我们同时需要宽度为 4 的 `dummy` 部件和宽度为 5 的 `dummy` 部件怎么办？难道将 `dummy` 的代码复制两份，仅仅是为了定义不同的 `localparam`？好在 Verilog 提供了 `parameter` 的模块参数配置语法。
```Verilog
module dummy(
    input ...
    output ...
);
    ...
    localparam LEN=4;
    wire [3:0] a [LEN-1:0];
    wire [3:0] b [LEN-1:0];

    genvar i;
    generate
        for(i=0;i<LEN;i=i+1)begin
            assign b[i] = a[i];
        end
    endgenerate
    ...
endmodule
```

模块名和模块输入输出端口列表之间可以加入 `#( parameter 参数名 = 默认值 ... )` 参数列表，参数可以有多个，依次用 `,` 隔开，参数可以 `=` 提供默认值也可以不提供默认值。
```Verilog
module dummy #(
    parameter LEN = 4
) (
    input ...
    output ...
);
    ...
    wire [3:0] a [LEN-1:0];
    wire [3:0] b [LEN-1:0];

    genvar i;
    generate
        for(i=0;i<LEN;i=i+1)begin
            assign b[i] = a[i];
        end
    endgenerate
    ...
endmodule
```

当我们实例化一个 `dummy` 模块的时候除了需要对输入输出进行连线之外，还需要对所有的参数进行参数配置。如果一个参数没有传参，那么会使用默认值作为参数，但是如果既没有传参也没有默认值就只能报错了。因此通过实例化 `dummy` 的时候给 `LEN` 参数不同的值就可以得到不同二维数组宽度的 `dummy` 电路。
```Verilog
dummy dummy1 (
    ...
);// LEN = 4

dummy #(
    .LEN(5)
) dummy2 (
    ...
);
```

`parameter` 传参的值可以是任意 `parameter`、`localparam`、立即数计算得到的立即数，但是不能是电路输出。特别的 `localparam` 和 `parameter` 的值也可以是字符串。`localparam` 和 `parameter` 的参数类型也不是事先确定的，而是根据传入参数的参数类型动态确定的，例如传入的参数是字符串，参数就是字符串类型，是 32 位立即数就是 32 位立即数类型。
