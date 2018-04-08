---
title: LEDE下绑定静态ARP
date: 2018-04-08 15:06:28
tags: openwrt
categories: 网络
---
公司网关需要ARP绑定，而LEDE默认的arp命令不能修改ARP表，使用ip neigh修改即可。
<!-- more -->
# ARP表

ARP表负责ip地址到MAC地址的映射，如果在arp表中找不到对应mac地址，就会无法到达该ip。

如果有坏人进行arp攻击，伪造网关ip地址对MAC地址的映射，那么你的网络流量会被发往该伪造的网关，进行不可描述的隐私窃取。

公司上网需要每台电脑绑定网关的ARP项目，避免有人伪造网关。

# LEDE修改ARP表

默认的arp命令实际上只能打印出arp表，无法修改。这里使用ip neigh修改

	opkg update
	opkg install iproute2

使用neigh可以打印出当前的ARP表

	root@LEDE:~# ip neigh
	192.168.0.6 dev eth0.2 lladdr 00:11:22:33:5a:bc REACHABLE
	192.168.9.207 dev br-lan  FAILED
	192.168.9.184 dev br-lan lladdr 00:11:22:33:d1:5c REACHABLE
	192.168.0.250 dev eth0.2 lladdr 00:11:22:33:dc:bc STALE

使用add/change可以增加/修改一条项目，添加permanent标志可以修改为静态的ARP条目，直到LEDE重启（否则无法删除）。

	ip neigh add    192.168.200.1 lladdr 00:22:44:66:88:aa nud permanent dev eth0.2
	ip neigh change 192.168.200.1 lladdr 00:22:44:66:88:bb nud permanent dev eth0.2

若使用了permanent标志，则在执行该命令，显示结果中的Flag一列0x6，代表永久条目。

	root@LEDE:~# cat /proc/net/arp
	IP address       HW type     Flags       HW address            Mask     Device
	192.168.9.207    0x1         0x0         b8:ca:3a:a9:61:d7     *        br-lan
	192.168.9.184    0x1         0x2         30:85:a9:21:d1:5c     *        br-lan
	192.168.200.1    0x1         0x6         00:22:44:66:88:bb     *        eth0.2

当192.168.200.1项目对应的nterface（eth0.2）重新连接时候，该ARP条目会失效，显示FAIL，但是也无法删除。

	root@LEDE:~# ip neigh
	192.168.0.6 dev eth0.2 lladdr 00:11:22:33:5a:bc REACHABLE
	192.168.9.207 dev br-lan  FAILED
	192.168.200.1 dev eth0.2  FAILED
	192.168.9.184 dev br-lan lladdr 00:11:22:33:d1:5c REACHABLE
	192.168.0.250 dev eth0.2 lladdr 00:11:22:33:dc:bc STALE

这时候使用ip neigh change即可强制修改该项目。

# 其它方法

使用busybox中arp命令，需要重新编译Busybox，因为太麻烦，就没有尝试了。但是还是写一下

在LEDE源码make menuconfig中，定位到

	Base System –> busybox –> Network Utilities -> 选中arp

编译busybox并安装。

	make package/busybox/compile V=99
	find bin | grep busybox

使用Linux平台喜闻乐见的arp命令修改

	arp -s 192.168.200.1 00:22:44:66:88:bb
	arp -i eth0.2 -s 192.168.200.1 00:22:44:66:88:bb

效果与ip neigh修改一致。

参考链接: [OpenWRT 添加静态ARP (ARP绑定)](https://blog.csdn.net/bingyu9875/article/details/79075523)