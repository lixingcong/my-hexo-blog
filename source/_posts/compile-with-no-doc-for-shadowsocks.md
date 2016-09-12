title: 不编译shadowsocks的文档
date: 2016-07-20 23:35:25
tags: shadowsocks
categories: 网络
---
shadowsocks-libev从2.4.8版本开始增加了asciidoc样式的帮助文档生成，个人感觉意义不太大，手册这玩意再漂亮，谁也不会天天看，要不只看一次就会用了，下次不会用再查。
<!-- more -->
该man page依赖的asciidoc，安装后体积高达1GB，真没必要啊！我的宝贵的搬瓦工这个破3GB磁盘，绝对没空间放下这么庞然大物！

编译主要分为下面两种情况：Make编译和build-deb包

## make

编译时候默认是编译帮助文档的，由于依赖包体积过大可以选择不编译手册(documentation)

	./autogen.sh
	./configure --disable-documentation
	# 四线程编译并安装
	make -j4 install

## build-deb

主要是debian/ubuntu用户

删掉检查依赖asciidoc xmlto

	vi debian/control
	# 删build-depends末尾的asciidoc和xmlto

取消安装Man手册

	vi debian/shadowsocks-libev.install
	# 删usr/share/man/

向configure传递参数：禁用编译文档

	vi debian/rules
	# 找到
	override_dh_auto_configure:
	# 添加这句
	--disable-documentation \

编译

	dpkg-buildpackage -b -us -uc -i
	ls .. | grep shadowsocks

安装前注意备份一份/etc/shadowsocks-libev/config.json，否则安装deb提示覆盖失败

卸载干净旧版本并安装

	dpkg -r shadowsocks-libev && dpkg -P shadowsocks-libev
	dpkg -i shadowsocks-libev_xxxx.deb
	# 解决依赖关系
	apt install -f

