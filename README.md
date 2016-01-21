[![][my_pic]][my_url]
[my_pic]: /source/images/default_avatar.jpg
[my_url]: http://lixingcong.github.io

使用主题：[Next](https://github.com/iissnan/hexo-theme-next)

# Hexo部署

## 安装git

[github for windows](https://windows.github.com)
或者使用绿色版git

ubuntu运行

	sudo apt-get install git

安装后配置一下提交者的邮箱和名字

    git config --global user.name "username"
    git config --global user.email "email"

## 安装node.js

[nodejs.org](http://nodejs.org)

Win直接安装，ubuntu则需要安装

	sudo apt-get install nodejs npm


## 创建你的博客文件夹

### 若是全新的仓库：

	mkdir my_hexo_blog.git

### 若是克隆回来的仓库

	git clone https://github.com/lixingcong/my_hexo_blog.git


## 安装hexo并初始化
首先打开git-bash，把hexo安装到系统里面

	sudo npm install -g hexo-cli
    
把hexo的模块modules安装到blog文件夹下

	cd my_hexo_blog.git
	sudo npm install hexo --save

此时目录出现modules文件夹

这时候根据需要初始化hexo文件夹,如果是git clone目录，请不要初始化，防止删掉_config.yml配置文件

	hexo init

## 安装插件
可以用一句命令安装：

	npm install hexo-generator-index hexo-generator-archive hexo-generator-category hexo-generator-tag hexo-server hexo-deployer-git hexo-deployer-heroku hexo-deployer-rsync hexo-deployer-openshift hexo-renderer-marked@0.2 hexo-renderer-stylus@0.2 hexo-generator-feed@1 hexo-generator-sitemap@1 --save

安装完插件后，blog目录下多了package.json，还有modules目录下多了很多插件

## 测试本地预览是否正常使用

	hexo s

浏览器打开localhost:4000是否正常运行，如果不正常使用，重新做一次安装

## 修改配置文件

这里不详述，自己爬文搜索怎么修改配置，毕竟太难总结，我只给出文件位置

+ hexo总配置文件：my_hexo_blog\_config.yml

+ 主题文件：\theme\xxxx\_config.yml

## 使用Haroopress(推荐)或者MarkdownPad书写你的博客

[Haroopress for Linux/Win](http://pad.haroopress.com/)

[MarkdownPad for Windows](http://markdownpad.com/)

[Markdown语法学习](https://www.zybuluo.com/AntLog/note/63228)

日志位置在\source\_posts\，格式为md文件

日志中添加下列代码可以剪短预览

	<!-- more -->

建议保存为英文名字的文件，有时候浏览器中显示中文地址很难看

## 如何删除一篇文章

首先正确删除/source/_post下面的md文件，然后执行

	hexo clean
	hexo g -d

## 生成静态博客

	hexo g

## 打开本地预览

	hexo s

## 提交到lixingcong.github.io

注意只需要提交\public目录下所有文件

	mv public D:\lixingcong.github.io
	cd d:\lixingcong.github.io

### 若是新仓库，需要新建仓库

参考官方帮助：

添加说明文件

首先新建一个txt文档，改名为README.md，然后添加一行注释

	echo # test my hexo blog >> README.md

初始化仓库

	git init

添加所有文件，跟踪所有文件

	git add *

添加commit

	git commit -m "version 1.0"

添加到远程仓库

	git remote add origin https://github.com/lixingcong/lixingcong.github.io
	git push -u origin master

### 若是已创建仓库

查看修改状态
	
	git status

注意将红色文件添加上

可以全部添加跟踪，并且commit

	git commit -a -m "version 1.0"

推送到远处

	git push
    
有时候需要备份成gz，避免重复安装hexo

	tar -zcvf /tmp/my_hexo_blog.tar.gz my_hexo_blog/

# Some Problems

### Git Push总是失败？

很明显，被墙了，该补充一下科学上网的知识了

用过shadowsocks，偶尔push成功，不过听说这ss被GFW盯上了，很不稳定

所以尽早肉身翻墙吧骚年！

### Win下的文件名太长？

在文件系统为NTFS驱动器下，用windows资源管理器中对my_hexo_blog目录进行拷贝或者zip打包，会出现“文件名太长”的提示。无法进行拷贝某些文件。

![](/source/images/readme/error_ntfs.png)

此时在Git_bash里面进行cp即可

	cp -R my_hexo_blog/ ./Copy_hexo_blog

同理，在bash用tar打包应该没问题，我没试过，大家有空试一下。

### Ubuntu下提示/usr/bin/env: node: 没有那个文件或目录?

出现在hexo new “NEW POST”命令中

解决方法：

由于Ubuntu下已经有一个名叫node的库，因此Node.js在ubuntu下默认叫nodejs，需要额外处理一下

	sudo ln -s /usr/bin/node /usr/bin/nodejs

# 更新日志

[Changelog.md](/ChangeLog.md)
