title: 我的eclipse配置
date: 2016-03-15 01:03:48
tags: [python, ubuntu]
categories: 编程
---
记下自己配置这个“臃肿”但是强大的IDE使用方法。写写简单的HTML和python还是比较好用的。
<!-- more -->
### 安装
安装java环境

	sudo apt-get install default-jre

下载eclipse:

	https://www.eclipse.org/downloads/
    
注意下载回来的是已编译好二进制文件，大概280MB，不是那个几十兆的安装器！！

以li用户安装到/home/li/eclipse

不需要安装中文语言包(有bug，因此不建议使用任何语言文件)


### 集成IDE安装

#### pydev

添加update地址   

	http://pydev.org/updates

pydev取消自动插入import:
Pydev->editor->auto import 取消勾选

pydev里面的formatter可以设置空格自动隔开变量和赋值好
pydev->editor->code style->code formatter勾选use space before after assign for keywoed arguments
自动保存已经格式化的文档
pydev->Save Action->勾选Auto-format editor contents before saving
更省事：直接勾选auto2ban8.py。（前提是先安装pepauto）

#### cdt

添加update地址

	http://www.eclipse.org/cdt/downloads.php

发觉CDT的字体设置不能记住，每次重启就丢失字体配置。。。囧

使用GMP库（C/C++），先从官网编译:

    make 
    make check
    make install
    
然后记住终端出现的LIB库文件地址，有可能用到。
程序中加入

	#include <gmp.h>

编译时候加上小写的l代表链接到静态库（*.a)，

	gcc -c main.cpp -lgmp

CDT进行自动补全有点麻烦，没有pydev那么智能。

	http://blog.csdn.net/virus026/article/details/17226371

其实可以bind一个Alt+C到content assist，所有环境下触发按键自动补全

### 其他插件

#### emacs+按键布局
主要功能是在这里用上emacs的快捷键，找回曾经的感觉。
添加update   

	http://www.mulgasoft.com/emacsplus/update-site

设置方法：Windows->perference->General->keys then select a SCHEME!!

#### 窗口配色

先装color theme

	https://eclipse-color-theme.github.com/update

ubuntu的GTK安装这个color conf，因为14.04默认的gtk3很蛋疼，某些主题失效
然后安装深色的全局主题

	https://raw.github.com/guari/eclipse-ui-theme/master/com.github.eclipseuitheme.themes.updatesite

彩色主题

	http://eclipse.jeeeyul.net/update/
    
装完后可以在Genarel->Appereance->Jeeeyul's Theme进行预置调色和手动调色


### 其余优化选项
#### 启动项
startup and shutdown取消不需要的
Spelling关闭
Validation > 勾选“Suspend all validator”。关闭所有校验
Window > Customize Perspective > 移除所有用不到或不想用的内容
Automatic Updates > 取消勾选“Automatically find new updates and notify me”。
Project->取消勾选build automatically
local history关闭，相当于版本控制
hovers 鼠标移过时候的提示信息

#### 自动补全

用eclipse感觉就要徒手全写，或是只有调用类方法，按下”.”时，才有提示出现。eclipse的强大远远不仅于此。只不过这个功能，算是被它对应的快捷键给毁了。这个功能叫“Content Assist”，可以更改快捷键为alt+c

#### 上下文匹配

如果开启“mark occurance”（工具栏的荧光笔按钮），双击选择某单词，就会出现这样的情况：对应于notepad++的上下文单词相同。eclipse会把上下文中该单词所有出现的地方都进行高亮显示，而这个颜色又和我们字体颜色非常接近，完全看不清楚了，这里，把”C/C++ Occurances”和”CC++ Write Occurances”的“Text as”都由“highlighted”改为“Box”即可。这样倒是更像是sublime text的风格。

鼠标悬停后，上下文配对背景色的问题，editor->editor->source hover background 在这里可以把颜色从默认的大白改为“#616161”

#### 默认utf-8编码

windows->Preferences->general->Workspace， Text file encoding，选择Other，改变为UTF-8，以后新建立工程其属性对话框中的Text file encoding即为UTF-8。
右侧Context Types树，点开Text，选择Java Source File，在下面的Default encoding输入框中输入UTF-8，点Update，则设置Java文件编码为UTF-8。其他java应用开发相关的文件 如：properties、XML等已经由Eclipse缺省指定，分别为ISO8859-1，UTF-8，如开发中确需改变编码格式则可以在此指定。

#### 自动换行

	http://ahtik.com/eclipse-update

#### 性能调整

在eclipse.ini添加两行
-XX:+UseParallelGC
-XX:+DisableExplicitGC

#### 备份eclipse的设置

方法一：使用eclipse的导出功能（不推荐，很多配置不能导出）
    工作目录中右键选择Export->General->Preference，这样可以导出epf文件，新的工作空间中可以用Import导入该配置文件，这个方法的确可以导入绝大多数的配置，但是并不全，导入后会丢失很多配置。

方法二：将workspace/.metadata/.plugins/org.eclipse.core.runtime中的.settings文件夹拷贝出来，里面就是所有的配置文件，新建工作空间的时候将该.settings文件夹替换掉新工作空间中的.settings文件夹即可。（有网友是将.plugings文件夹替换，但是.plugings文件夹太大了，实际上就是替换.settings文件夹，.settings只有几百k。）

#### 快捷键key binding

设置快捷键ctrl+i 为、进行选择
首先删掉快捷键Mark word然后设置Set mark command为快捷键Ctrl+i

打开outline/task
Window->Show View->outline

ALT+L自动打开、关闭注释：
搜索Toggle Comment，设置为Editing Text模式都进行toogle。

#### 工程编译与运行

需要使用build和run功能的，先写好makefile放进工程文件夹里面，在终端里面make clean确认没有垃圾文件，然后在project窗口右键工程，“build project”。
可以设置快捷键build project和run

如果发现consule中很多无关工程的编译错误，可以点击右侧的向下三角形，Show->Errors/Warings on project