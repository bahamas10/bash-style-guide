Bash 风格指南
================

本风格指南旨在描述如何编写 bash 脚本，并使其安全和可预测。本指南基于 [this wiki](http://mywiki.wooledge.org)，特别是这个页面：

http://mywiki.wooledge.org/BashGuide/Practices

如本指南中有任何东西并未明确提出，则默认遵循这个 wiki 中所描述的观点。


美学
----------

### 使用制表符还是空格

制表符

### 分号

你无需在命令行中使用分号（我希望是这样），同样也不要在脚本中使用它。


``` bash
# wrong
name='dave';
echo "hello $name";

#right
name='dave'
echo "hello $name"
```

### 函数

不要使用关键字 `function` 创建函数。所有函数中创建的变量都应该声明为局部变量。

``` bash
# wrong
function foo {
    i=foo # this is now global, wrong
}

# right
foo() {
    local i=foo # this is local, preferred
}
```

### 代码块声明

`then` 应与 `if` 放在同一行，`do` 应与 `while` 放在同一行。

``` bash
# wrong
if true
then
    ...
fi

# also wrong, though admittedly looks kinda cool
true && {
    ...
}

# right
if true; then
    ...
fi
```

### 间距

不要超过两个连续的换行符（即不超过一行空行）。


### 注释

注释没有明确的代码风格。除非你重写或者更新注释内容，否则不要因为美观的因素去改动它。



Bash 主义
--------

本风格指南用于 bash。这意味着，如果可以选择，使用 bash 的内建命令或关键字，总是好于外部命令或`sh(1)`的语法。

 
### `test(1)`

使用 `[[ ... ]]` 进行条件测试, 而不是 `[ .. ]` 或 `test ...`

``` bash
# wrong
test -d /etc

# also wrong
[ -d /etc ]

# correct
[[ -d /etc ]]
```

查看 http://mywiki.wooledge.org/BashFAQ/031 了解更多信息。

### 队列

使用 bash 的内部命令生成队列。

``` bash
n=10

# wrong
for f in $(seq 1 5); do
    ...
done

# wrong
for f in $(seq 1 "$n"); do
    ...
done

# right
for f in {1..5}; do
    ...
done

# right
for ((i = 0; i < n; i++)); do
    ...
done
```

### 命令替换

使用 `$(...)` 进行命令替换.

``` bash
foo=`date`  # wrong
foo=$(date) # right
```

### 数学 / 整数操作

使用 `((...))` 和 `$((...))`。

``` bash
a=5
b=4

# wrong
if [[ $a -gt $b ]]; then
    ...
fi

# right
if ((a > b)); then
    ...
fi
```

**不要**使用 `let` 命令。

### 参数扩展

使用[参数扩展](http://mywiki.wooledge.org/BashGuide/Parameters#Parameter_Expansion)要好于使用外部命令，例如 `echo`, `sed`, `awk` 等等。


``` bash
name='bahamas10'

# wrong
prog=$(basename "$0")
nonumbers=$(echo "$name" | sed -e 's/[0-9]//g')

# right
prog=${0##*/}
nonumbers=${name//[0-9]/}
```

### 列出文件

不要使用 [解析 ls(1)](http://mywiki.wooledge.org/ParsingLs)，而使用 bash 内置函数来循环文件。


``` bash
# very wrong, potentially unsafe
for f in $(ls); do
    ...
done

# right
for f in *; do
    ...
done
```

### 查明可执行文件路径

简单声明一点，你肯定不知道，如果你视图找出可执行程序的完整路径，你应该反思你的软件设计了。


查看 http://mywiki.wooledge.org/BashFAQ/028 获取更多信息。

### 数组和列表

只要有可能，尽量使用 bash 数组来代替使用空格（或是换行符、制表符等）分隔的字符串。

``` bash
# wrong
modules='json httpserver jshint'
for module in $modules; do
    npm install -g "$module"
done

# right
modules=(json httpserver jshint)
for module in "${modules[@]}"; do
    npm install -g "$module"
done
```

### 内置读取

只要有可能，使用 bash 内置的 `read` 避免调用外部命令。

例子：

``` bash
fqdn='computer1.daveeddy.com'

IFS=. read hostname domain tld <<< "$fqdn"
echo "$hostname is in $domain.$tld"
# => "computer1 is in daveeddy.com"
```

外部命令
-----------------

### GNU 用户工具

全世界不会都运行在 GNU 或 Linux 上；当调用外部命令时，例如 `awk`, `sed`, `grep`，避免 GNU 特定的选项，使其尽量易于移植。

当你编写 bash ，并且使用给你的所有强大工具和 bash 的内建命令时，你会发现甚至很少有机会需要调用外部命令。


### [UUOC](http://www.smallo.ruhr.de/award.html)

不要在你不需要的时候使用 `cat(1)`。如果程序支持从标准输入读取，使用 bash 重定向传递数据。



``` bash
# wrong
cat file | grep foo

# right
grep foo < file

# also right
grep foo file
```

如果我们能够推断，当程序说它可以通过名称读取文件，并且这样做能获得更好的性能时，我们可以使用这个内置读取文件方法的命令行工具，而不是标准输入。	


风格
-----

### 引号

当字符串需要变量扩展或命令替换插值的时候使用双引号，其它时候使用单引号。


``` bash
# right
foo='Hello World'
bar="You are $USER"

# wrong
foo="hello world"

# possibly wrong, depending on intent
bar='You are $USER'
```

所有将要经历分词的变量都 *必须* 被引用 (1)。如果分词不会发生，变量可以不加引号。


``` bash
foo='hello world'

if [[ -n $foo ]]; then   # 不需要引号 - [[ ... ]] 不会把变量分词
    echo "$foo"          # 需要印号
fi

bar=$foo  # 不需要引号 - 变量不会分词
```


1. 唯一的例外是，如果代码或 bash 控制着这个变量的整个生命周期。这种情况 [basher](https://github.com/bahamas10/basher) 有类似的代码：

``` bash
printf_date_supported=false
if printf '%()T' &>/dev/null; then
    printf_date_supported=true
fi

if $printf_date_supported; then
    ...
fi
```

在这个例子中，虽然在 `if` 声明中的 `$printf_date_supported` 将经历分词，但仍然不需要引号，因为这个变量的内容被明确地控制着，并不会从用户或其它命令里取值。

同样的，例如 `$$`, `$?`, `$#`这些变量，也不需要引号，因为他们绝不会包含空格、制表符或换行符。

然而，如果仍怀有疑问，可以查看[引用所有的扩展](http://mywiki.wooledge.org/Quotes)。

### 变量声明

避免大写的变量名，除非有一个很好的理由使用他们。不要使用 `let` 或 `readonly` 创建变量。`declare` 应该*只用于*关联数组。在函数中，应*始终*使用 `local` 声明变量。


``` bash
# wrong
declare -i foo=5
let foo++
readonly bar='something'
FOOBAR=baz

# right
i=5
((i++))
bar='something'
foobar=baz
```

### shebang

Bash 不总是位于 `/bin/bash`，因此尽量这样来写这一行：

``` bash
#!/usr/bin/env bash
```

### 错误检查

举个例子，`cd` 不总是工作。请务必检查 `cd`（或类似的命令）任何可能的错误，如果错误存在就退出或将错误抛出。  


``` bash
# wrong
cd /some/path # 可能会失败
rm file       # 如果 cd 失败我在哪？我删除了什么？

# right
cd /some/path || exit
rm file
```

### `set -e`

不要设置 `errexit`。如同在 C 语言中，有时你想要得到一个错误，或是你期望什么执行失败，并不意味着你想要退出程序。

http://mywiki.wooledge.org/BashFAQ/105



### `eval`

永远不要使用.

---

没有人会在代码库中接受下面这个链接列出的东西。

http://mywiki.wooledge.org/BashPitfalls

这里也例举了一些如何修复这些问题的例子。

License
-------

MIT License


