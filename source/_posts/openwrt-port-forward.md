title: openwrt端口转发
date: 2016-10-03 22:55:18
tags: openwrt
categories: 网络
---
利用minivtun实现点对点非公网NAT穿透，在学校轻松访问家里的路由器。
<!-- more -->
一般这种情况用于

- 家里路由器挂载离线下载
- 家里的WEB网络摄像头监控
- 远程修改某些路由设置
- 远程控制路由器相关的“智能家居”

现在仅考虑以下拓朴图，本文的目的是想让路由C访问路由A，实现C远程控制A。其中A是非智能路由器，使用非Openwrt系统。A下面挂接一个Openwrt路由器B

![](/images/openwrt_port_fwd/topology.png)

前提是A和C能顺利访问该VPS，而且B工作正常。

## minivtun互访

这个[minivtun](https://github.com/rssnsj/minivtun)是我常用的tun点对点隧道软件，工作原理与shadowvpn类似，可以当梯子使用。现有我移植的的[minivtun-openwrt](https://github.com/lixingcong/minivtun-openwrt)，可以自行编译安装在路由上面。

按照文档编译安装，服务端运行监听555端口

	/usr/sbin/minivtun -l 0.0.0.0:555 -a 172.16.0.1/24 -e password -n mv0 -d

路由器B和C，同样使用minivtun实现与VPS对接，这里指定网络设备为mv001

	# Router B: ip 172.16.0.3
	/usr/sbin/minivtun -r [YOUR_VPS]:555 -a 172.16.0.3/24 -e password -n mv001 -d
	
	# Router C: ip 172.16.0.55
	/usr/sbin/minivtun -r [YOUR_VPS]:555 -a 172.16.0.55/24 -e password -n mv001 -d

使用Ping等工具测试路由B能否顺利访问VPS

	ping 172.16.0.1
	
## Openwrt端口转发

以下三个步骤均在路由B操作

### 新建接口

在network->interface标签下添加一个interface: 命名随意，这里命名为minivtun_intf，协议为DHCP Client，手动输入mv001这个物理接口进行绑定（因上面minivtun启动参数设定了mv001网络设备）

![](/images/openwrt_port_fwd/new_interface.png)

检查这个接口minivtun_intf是否获得正确的172.16.0.3/24地址，并且从数字变化过程中看到能有Tx/Rx流量通过。

### 入站防火墙

切换到Network->Firewall->Gerneral，添加一个新的Zone，随意命名为minivtun,指定入站出站转发三个都accept，勾选masquerading和MSS clamping进行伪装路由器。Covered Network只需要勾选两个区域即可，其中必选的是minivtun_intf表示源，另一个是目的地根据需要，可以选WAN或者LAN，如果访问Openwrt局域网就指定LAN，如果要访问WAN（比如上一级路由）就指定WAN

因为我是利用B去访问上一级的A，因此我勾选了WAN

![](/images/openwrt_port_fwd/new_firewall.png)

### 端口转发

切换到Network->Firewall->Port Forward，新建一个转发规则

外部端口随意，（比如外部端口是444，那么在路由C使用minivtun访问172.16.0.3:444就触发端口转发条件）

|项目|备注|我的值|
|--|--|--|
|名字|随意起名|minivtun_port_fwd|
|外部区域|入站防火墙名字|minivtun|
|外部端口|供外部访问端口|800|
|内部区域|目的端口区域|LAN|
|内部IP|目的地址|192.168.200.1|
|内部端口|目的端口|800|

![](/images/openwrt_port_fwd/new_port_forward.png)

## 测试方法

从路由器C浏览器地址栏输入```http://172.16.0.3:800```即可访问路由A的800端口

