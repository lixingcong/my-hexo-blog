title: linux简单的文本处理
date: 2015-10-31 22:13:37
tags: ubuntu
categories: 读书笔记
---
本文为读书摘录。
参考书籍：Classic Shell Scripting
## grep
打印出某行。
<!-- more -->

	ifconfig | grep 127.0.0.1

使用正则表达式BRE或者ERE匹配行：

	ifconfig | grep '\([0-9]*\)\.'
    ifconfig | grep -e '[0-9]*\.'
    
相关文章：[正则表达式学习](http://lixingcong.github.io/2015/10/29/RE_POSIX/)
## sed

什么时候改用/g什么时候不需要：sed对每一行进行一轮匹配。若是一行有多个结果，要加上/g。
加载多个命令需要-e参数。每一个-e后面跟者一个命令
定界符可以是逗号，也可以分号，总之不要跟替换内容重复。
启用overwrite模式，将改动写入到源文件: -i 参数
启用ERE表达式 -r 参数

备份/home/ubuntu的目录结构到/tmp/backup

	mkdir /tmp/backup
    find /home/ubuntu -type d -print |
    sed 's;/home/ubuntu;/temp/backup/;' |
    sed 's;/^/mkdir /' |
    sh -x

删掉空行

	sed '/^$/d' ./1.txt
    
从文件加载命令

	# use global replace because in a line
	echo "s/fuck/love/g" > config  
    echo "I fuck you because I love you, So I love you and fucking you" > text
    sed -f config ./text

仅显示匹配(类似grep)

	printf "one\ntwo\nthree\nfour\none\n" > text
	sed -n '/one/p' ./text

匹配特定行
- 提及两位人名：

        printf "Tom wants to sleep.\nBut Tom has to finish task.\n" > text
        sed '/Tom/ s//& and Jerry/g' ./text
    
- 指定打印哪些行

		sed -n '10,24p' /etc/passwd
    
- 仅替换范围内的行

		# 从含games那行到proxy那行进行替换
		sed '/games/,/proxy/ s/usr/ffffffffffffff/g' /etc/passwd

- 将命令应用于不匹配的某些行

        # 不匹配games的所有行进行替换操作
        sed '/games/ !s/usr/xxxxxxxxxxxxxxxxxx/g' /etc/passwd
        
        

    
小把戏：匹配NULL (由于*表示重复0~INF次)

	echo abc | sed 's/b*/1'
    结果：1abc
    

## cut
字段提取。
取出字段：

	cut -d : -f 1,5 /etc/passwd | head
	cut -d : -f 6 /etc/passwd | tail
    
## join
连接字段
	
    printf "#Sales\njoe\t200\njane\t300\nhreman\t150\nchris\t450\n" > text1
    printf "#Quotas\njoe\t49\njane\t54\nhreman\t20\nchris\t49\n" > text2
    # 删掉注释，然后排序
    sed '/^#/d' text1 | sort > text1.sort
    sed '/^#/d' text2 | sort > text2.sort
    # 以第一个字段作结合
    join text1.sort text2.sort

## awk
打印非空行：

	awk 'NF > 0 {print $0}'
    
实现cut取出字段,-F指定分隔符

	awk -F: '{print "User-name:",$1,",but real name is",$5}' /etc/passwd | head
    # 改动一下，-v设置**为输出分隔符
    awk -F: -v 'OFS=**' '{print $1,$5}' /etc/passwd | head
   
## sort
排序。
修饰符如下：

|字母|说明|字母|说明|
|--|--|--|--|
|b|忽略开头空白|g|以一般的符号数字进行比较，仅用于GNU|
|d|字典顺序|i|忽略无法打印的字符|
|f|不分大小写|n|以整数进行比较|
|r|倒序|-|-|


还是passwd文件。这东西能玩一年

	# -t分隔符 -k表示从第几个字段到第几个字段为key
    # -k2.4,5.6表示从第二个字段的第四个字符开始比较，一直比到第五字段第六字符
	sort -t: -k1,1 /etc/passwd
    
    # -k3nr修饰符表示第三字段，按数字，反向排序
    sort -t: -k3nr /etc/passwd
    
    # 先按第四个字段进行排序，若具有相同第四字段，再以第三个字段进行排序
    sort -t: -k4n -k3n /etc/passwd
    
文本块排序：
假设text为如下内容：

    # SORTKEY: Schlob, Hans Jürgen
    Hans Jürgen Schlob
    Unter den Linden 78
    D-10117 Berlin
    Germany
    
    # SORTKEY: Jones, Adrian
    Adrian Jones
    371 Montgomery Park Road
    Henley-on-Thames RG9 4AJ
    UK
    
    # SORTKEY: Brown, Kim
    Kim Brown
    1841 S Main Street
    Westchester, NY 10502
    USA

先用awk处理标识符。再处理键值，恢复原样：

	cat text | awk -v RS="" '{gsub("\n" , "^Z"); print }' |
    sort -f |
    awk -v ORS="\n\n" '{gsub("\^Z","\n");print }' |
    grep -v 'sort'
    
排序后看看是否重复：

	printf "three\none\ntwo\nthree\nfour\none\nthree\n" > text
    # 显示去掉重复的、排序后记录
    sort latin-numbers | uniq
    # 显示计数
    sort latin-numbers | uniq -c
    # 仅显示重复记录
    sort latin-numbers | uniq -d
    # 仅显示未出现重复
    sort latin-numbers | uniq -u
    
    
## fmt
打开字典，格式化段落为30个字为一行：

	sed -n '999,1020p' /usr/share/dict/words | fmt -w 30
    
    
## wc
计数，words count
	
    echo "hello world, i am the king of the world." > text
    cat text | wc -c  #字节数
    cat text | wc -l  #行数
    cat text | wc -w  #数词