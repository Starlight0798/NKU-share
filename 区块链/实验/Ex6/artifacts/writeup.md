Name: ['2113997 齐明杰'，'2111231 李帅东']

## Question 1

In the following code-snippet from `Num2Bits`, it looks like `sum_of_bits`
might be a sum of products of signals, making the subsequent constraint not
rank-1. Explain why `sum_of_bits` is actually a _linear combination_ of
signals.

```json
        sum_of_bits += (2 ** i) * bits[i];
```

## Answer 1

 `sum_of_bits` 实际上只是输入信号 `bits[i]` 的线性组合。其原因在于`2**i` 不是信号，而只是一个常量值（由依赖于 `n` 的 `i` 定义）。

## Question 2

Explain, in your own words, the meaning of the `<==` operator.

## Answer 2

`<==` 运算符基本上是 `<--` 和 `===` 运算符的组合，它既分配了一个值给信号，又意味着从分配中派生的合同成立。它基本上只是一种快捷方式，允许我们在分配信号的值是线性组合时避免使用两个运算符。


## Question 3

Suppose you're reading a `circom` program and you see the following:

```json
    signal input a;
    signal input b;
    signal input c;
    (a & 1) * b === c;
```

Explain why this is invalid.

## Answer 3

这个表达式 `(a & 1) * b === c` 是无效的，因为其中使用了 `&` 运算符，表示按位与操作。在电路约束的上下文中，按位`&`操作并不能得到输入信号的线性组合，因此约束不能简化为rank-1形式的 `a*b + c = 0`。因此，给定的表达式违反了在这个上下文中有效约束的要求。

