Travis CI build status: [![Travis CI](https://travis-ci.org/lixingcong/my-hexo-blog.svg?branch=master)](https://travis-ci.org/lixingcong/my-hexo-blog?branch=master)

使用主题：[Next](https://github.com/iissnan/hexo-theme-next)

## Hexo部署

步骤
- 安装nodejs，建议最新版
- 安装npm
- 使用npm安装hexo
- 使用hexo去初始化一个空的文件夹

## 修改配置文件

这里不详述，自己爬文搜索怎么修改配置，毕竟太难总结，我只给出文件位置

+ hexo总配置文件：/_config.yml

+ 主题配置文件：/theme/xxxx/_config.yml

## 使用文本编辑器书写你的博客

[Haroopress for Linux/Windows](http://pad.haroopress.com/)

日志位置在\\source\\_posts\\，格式为md文件

日志中添加下列代码可以剪短预览

	<!-- more -->

建议保存为英文名字的文件

## 生成静态博客并预览

	hexo g
	hexo s

浏览器打开localhost:4000

## Win下的文件名太长？

在文件系统为NTFS驱动器下，用windows资源管理器中对my_hexo_blog目录进行拷贝或者zip打包，会出现“文件名太长”的提示。无法进行拷贝某些文件。

![](/source/images/readme/error_ntfs.png)

此时在Git_bash里面进行cp即可

	cp -R my_hexo_blog/ ./Copy_hexo_blog

同理，在bash用tar打包应该没问题，我没试过，大家有空试一下。

## Ubuntu下提示/usr/bin/env: node: 没有那个文件或目录?

解决方法：

由于Ubuntu下已经有一个名叫nodejs的库，创建link即可，建议link到最新版本的nodjs而不是系统的。

	sudo ln -s /usr/bin/nodejs /usr/bin/node
