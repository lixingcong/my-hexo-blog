title: Makefile读书笔记
date: 2016-01-03 14:37:34
tags: ubuntu
categories: 读书笔记
---
Makefile是帮助我们进行编译的工具，可以简化流程，易于维护，编译不必依赖IDE，当源文件数量较多时候，使用Makefile更适合管理Project的开发。在开源软件中大多采用Makefile进行管理。
<!-- more -->

编译器别名
---

|名称|说明|
|--|--|
|AR|函数库打包程序。默认命令是“ar”|
|AS|汇编语言编译程序。默认命令是“as”|
|CC|C语言编译程序。默认命令是“cc”|
|CXX|C\+\+语言编译程序。默认命令是“g\+\+”|

标志
---

|名称|说明|
|--|--|
|ARFLAGS|函数库打包程序 AR 命令的参数。默认值是“rv”|
|ASFLAGS|汇编语言编译器参数。(当明显地调用“.s”或“.S”文件时)|
|CFLAGS|C 语言编译器参数。|
|CXXFLAGS|C++语言编译器参数。|
|CPPFLAGS|C 预处理器参数。( C 和 Fortran 编译器也会用到)|
|LDFLAGS|链接器参数。(如:“ld”)|

自动化变量
---

|名称|说明|
|--|--|
|$@|目的文件名|
|$<|依赖列表的第一个文件|
|$^|当前规则的整个依赖列表|
|$*|目标文件去掉后缀后的名称|
|$%|当规则的目标文件是一个静态文件时，$%代表静态库的一个成员名|
|$>|它和$%一样只适用于库文件，它的值是库名|
|$?|所有比目标文件新的依赖文件，以空格分隔。如果目标是静态库文件，代表的库成员|
|$+|类似“$^",但它保留了依赖文件中重复出现的文件。主要用在程序链接时的库的交叉引用场合|


一个简单的例子
---

(所有文件都放在相同文件夹中)
main.c中的内容：

	#include <stdio.h>
    #include "hello.h"
    main()
    {
		print_hello();
    }
    
hello.c中的内容：

	#include "hello.h"
    void print_hello()
    {
    	printf("hello_world\n");
    }

hello.h中的内容：

    #ifndef _HELLO_H_
    #define _HELLO_H_
    #include <stdio.h>
    void print_hello();
    #endif

Makefile中的内容：

    CC=gcc
    CFLAG=-I.
    CFLAGS += -Wall -Werror -Wmissing-prototypes
    SRC=hello.c main.c
    OBJS=hello.o main.o

    main:all

    all:$(OBJS)
        $(CC) $(CFLAG) $^ -o a

    $(OBJS):$(SRC)
        $(CC) -c $^ $(CFLAG)

    .PHONY:clean
    clean:
        rm *.o
        rm main
