title: Markdown学习笔记
date: 2015-08-25 0:52:31
tags: Markdown
categories: 读书笔记
---

# 标题
生成h1--h6,在文字前面加上 1--6个# 来实现

![](/images/markdown_tutorial/1.png)

<!-- more -->

![](/images/markdown_tutorial/2.png)
# 粗体、斜体


![](/images/markdown_tutorial/3.png)
![](/images/markdown_tutorial/4.png)
# 分割线
![](/images/markdown_tutorial/5.png)
![](/images/markdown_tutorial/6.png)
# 列表
## 无序列表
![](/images/markdown_tutorial/7.png)

效果：

![](/images/markdown_tutorial/8.png)
## 有序列表
![](/images/markdown_tutorial/9.png)

效果：

![](/images/markdown_tutorial/10.png)
## 层次列表
![](/images/markdown_tutorial/16.png)

“*” 后面要加空格，这是必须的，除了 *，还可以使用 + 或者 -。

如果格式出现问题，多加个空行，一般就好了。
效果：


![](/images/markdown_tutorial/17.png)
# 添加超链接、图片

## 最简单的网站链接
![](/images/markdown_tutorial/13.png)

效果：

[www.baidu.com](https://www.baidu.com)

如果在前面加上感叹号！，不会显示文字

## 鼠标移过，有提示文字的链接
方法：
![](/images/markdown_tutorial/11.png)

效果：

一种带提示的链接: [鼠标移过来，**先别单击** ~][hover]
[hover]: http://www.google.com.sg "Google Sg 更快，更好用。好，现在单击吧"

## 点击图片进行链接
方法：

![](/images/markdown_tutorial/12.png)

效果：

[![][jane-eyre-pic]][jane-eyre-douban]
[jane-eyre-pic]: http://img3.douban.com/mpic/s1108264.jpg
[jane-eyre-douban]: http://book.douban.com/subject/1141406/

## 空链接
	[无链接的链接][null-link]
	[null-link]: chrome://not-a-link

效果：（哪怕它只有颜色变化）

[无链接的链接][null-link]
[null-link]: chrome://not-a-link


# 表格
![](/images/markdown_tutorial/14.png)
![](/images/markdown_tutorial/15.png)

# 添加代码框
## 一行代码框
![](/images/markdown_tutorial/18.png)
其中" ` ", 就是esc键下面那个符号

`These words`（加框！！！）

`#include <cstdio>`（添加框！！！）
## 多行代码
方法一：拷贝源代码进来，然后给每行前面加tab，可以通过MarkdownPad软件实现，选中代码，按一下tab即可，很方便。

方法二：
![](/images/markdown_tutorial/19.png)
效果：

	#include <cstdio>
	main()
	{
		printf("markdown\n");
	}

方法三：
首尾加三个`，如图所示
![](/images/markdown_tutorial/26.png)

优点：在gitbub能显示行号。

``` 
bash
$ hexo
generate
```

# 引用
方法：
![](/images/markdown_tutorial/20.png)

> 引用的文字
> 引用的文字
> 引用的文字

（注意引用多行，需要多几下回车键）

若在引用内，还有引用（嵌套），加>>

![](/images/markdown_tutorial/21.png)

效果：


> 引用的文字A


 >> 引言内的引言---嵌套


> 引用的文字B

# 单行长文字
方法一：只需在需要单行长文字的首尾两端加上三个`即可

![](/images/markdown_tutorial/22.png)

方法二：在需要以单行长文字显示的文字段落前加四个空格，类似于代码框

# 首行缩进
行首输入这个，即可缩进，输入多少个就是缩进多少字符

![](/images/markdown_tutorial/23.png)

&nbsp;缩进一个字符缩进一个字符缩进一个字符缩进一个字符缩进一个字符缩进一个字符

&nbsp;&nbsp;缩进两个字符缩进两个字符缩进两个字符缩进两个字符缩进两个字符缩进两个字符

&nbsp;&nbsp;&nbsp;&nbsp;缩进四个字符缩进四个字符缩进四个字符缩进四个字符缩进四个字符缩进四个字符

其他：Markdown语法会忽略首行开头的空格，如果要体现出首行开头空两个的效果，可以使用全角符号下的空格，windows下使用shift+空格切换。

# 脚注（注脚）
![](/images/markdown_tutorial/24.png)

效果：

这是一个注脚测试[^footer1]

[^footer1]: 这是一个测试，用来阐释注脚。

**PS:**实际github上没有脚注功能，实测点脚注就打开了新网页了，可能在某些markdown能用。

# 分割线
只要*或者-大于等于三个就可组成一条平行线。
![](/images/markdown_tutorial/25.png)

但是，使用- - -作为水平分割线时，要在它的前后都空一行，防止- - -被当成标题标记的表示方式。

# 反斜杠
转义符，用于禁用markdown的标记。
输入

	\*这里不会显示斜体\*

测试结果：

\*这里不会显示斜体\*

# 删除线
使用两个~即可、

	~~这是一条删除线~~

效果

~~这是一条删除线~~

# 小型文本
	<small>文本内容</small>
效果：

<small>文本内容</small>

# 后记

markdown不支持居中右对齐，换句话说，不支持任何格式，包括颜色设置。

所谓的加粗和斜体，只是两种强调语法，最终是显示为何种格式都是合理的。

markdownpad很多时候的效果不理想，大部分可能不是你语法的问题，比如\[tor\]功能，出不来。最好把markdown处理器设置为“github 模式”

推荐“stackedit”，一个在线markdown网站

## 摘自
[www.jianshu.com/p/21d355525bdf](http://www.jianshu.com/p/21d355525bdf)


