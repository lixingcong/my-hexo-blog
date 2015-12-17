title: 我的ShadowVPN配置记录v2
date: 2015-12-17 16:41:48
tags: shadowsocks
categories: 网络
---
## 安装

在vps（ubuntu 14.04.3 x64）上面操作：

### 源安装
<!-- more -->
特点：
- daemon守护进程
- 因带有token，适合多客户端
- 0.2.0版：同一子网可以互ping
- 配置方便，傻瓜式
- 缺点：暂时没有研究出多端口监听

方法:

vi /etc/apt/sources.list   添加

	deb http://shadowvpn.org/debian wheezy main
    
更新源，安装

    apt-get update
	apt-get install shadowvpn
    
运行：

	/etc/init.d/shadowvpn start
    
### 编译安装

#### 获取源码

特点：
- 自由度高，可以自己修改功能模块（然而我读不懂代码...）
- 可以编译出Windows版本的客户端
- 监听多端口
- 缺点：有时候会无响应，不知道原因在哪。

安装必要的编译工具

	apt-get install build-essential mingw-w64 autoconf libtool

获取源码，以0.1.6为例（该版本发布于2015.1）

	cd ~
    wget http://entware.dyndns.info/sources/shadowvpn-0.1.6-20150721.tar.bz2
    tar -xvf shadowvpn-0.1.6-20150721.tar.bz2
    cd shadowvpn-0.1.6-20150721/
	
*这里有[clowwindy](https://github.com/clowwindy)被喝茶前最后一版的0.2.0的源码：*[下载地址](https://github.com/rains31/ShadowVPN/archive/0.2.0.tar.gz)，未测试，各位可以尝鲜试一下。

（更新libsodium为非必要的步骤）
更新libsodium，[下载地址](https://github.com/jedisct1/libsodium/releases) 。这里以1.0.6版本为例。

	rm -rf ./libsodium
	cd /tmp
	wget https://github.com/jedisct1/libsodium/releases/download/1.0.6/libsodium-1.0.6.tar.gz
	tar -zxf libsodium-1.0.6.tar.gz
	mv libsodium-1.0.6 ~/shadowvpn-0.1.6-20150721/libsodium
	cd ~/shadowvpn-0.1.6-20150721/
	
进行AutoGen生成makefile脚本

	sh ./autogen.sh

#### 编译出linux版

	./configure --enable-static --sysconfdir=/etc
	make && make install
    
运行服务端

	shadowvpn -c /etc/shadowvpn/server.conf -s start
	
提示：安装后建议不删shadowvpn-0.1.6-20150721文件夹，方便日后卸载：

	make uninstall

#### 编译出windows客户端

想偷懒的话，可以直接[下载我的预编译版本](/attachments/my_conf_of_shadowvpn/shadowvpn-win-0.2.0.tar)，不需要自行编译了。

获取源码方法跟上面linux客户端一致

	cd ~/shadowvpn-0.1.6-20150721/
	make clean
	./configure --host=i686-w64-mingw32 --enable-static
	make
    
耗时大概一分钟，然后从src目录下获得一个shadowvpn.exe，使用winscp复制到win系统备用。

#### 编译出openwrt客户端

先进入 [SDK](https://wiki.openwrt.org/doc/howto/obtain.firmware.sdk) 根目录，然后：

    pushd package
    git clone https://github.com/clowwindy/ShadowVPN.git
    popd
    make menuconfig # select Network/ShadowVPN
    make V=s

最后安装ipk即可。

## 配置

### 服务端

在vps上面操作：

	cd /etc/shadowvpn

这是server.conf

![](/images/shadowvpn_conf/s_vpn1.png)

这是server_up.sh

![](/images/shadowvpn_conf/s_vpn2.png)

我修改的小结：
- 打开server.conf
- 若要监听ipv6，修改server=::0
- 修改port=666
- 修改密码
- 修改mtu
- 修改子网netmask(在server_up.bat或者server.conf)

*PS 1:修改mtu这一步很重要，会直接影响vpn速度。*
详细的mtu设置讨论帖子：[帖子点击这里](https://github.com/clowwindy/ShadowVPN/issues/77)
大概意思就是如帖子里面linhua55所说的方法：

    MTU of PPPoE is 1452, But it differs between your network.
    首先用Windows插上网线
    进行正常的拨号（若是DHCP，则跳过这步，主要目的是模拟路由器拨号）
    cmd执行 ping -f -l 1452 www.baidu.com
    逐步加大或者减少该值，直到恰好不会出现DF拆包的提示。记下这个mtu
    例如，记下的mtu是1492，计算得到1492-20-8-24=1440（这是ipv4，对ipv6再减20,）
	注意：mtu减去多少，取决于你的shadowvpn版本，详细看server.conf里面的mtu注释
    那么在服务端的server.conf填入1440
    客户端建议也一致填写1440
    
*PS 2:设置内网netmask这一步也很重要，避免shadowvpn与isp分配到的地址冲突。*
参考[维基百科](https://en.wikipedia.org/wiki/Private_network)进行内网的设置。这里都是假设你具有基本的网络层ip知识。如果你对计算机网络ip不那么熟悉，建议保持shadowvpn默认值网关10.7.0.1。

	首先在电脑上拨号，查看isp给的是否是内网地址
    若是公网地址，那么恭喜你，保留默认的netmask即可
    若是内网地址（10、100、172开头的ip地址），需要参考维基百科的地址设置一个不冲突的内网地址
    比如我的isp分配的地址是10.9.120.2，那我可以在server.conf设netmask为为172.16.0.1/16（不唯一）

### 客户端

#### linux版
修改配置文件与服务器配置一致：(如：ip,port,MTU,password)

	vi /etc/shadowvpn/client.conf
	vi /etc/shadowvpn/client_up.sh

注意conf文件中，net=10.7.0.2/xx设置

	10.7.0.2/xx计算规则是把服务端net=10.7.0.1/xx加一


若是源安装，修改启动模式为客户端。然后重启一下进程

	vi /etc/default/shadowvpn
    CONFIG 改为 /etc/shadowvpn/client.conf 保存
    /etc/init.d/shadowvpn restart

若是编译安装，直接运行进程

	shadowvpn -c /etc/shadowvpn/client.conf -s restart
    
测试一下tun通道是否成功：

	ifconfg 观察tun0的数据RX TX变化
    ping [YOUR_SHADOWVPN_GATEWAY] -w 5
    
确认无误，可以ping通，加入dns即可上网：

	vi /etc/resolv.conf
    nameserver 8.8.8.8  #追加到末尾
    
停止命令：跟启动差不多，只需把start换成stop

#### windows版

先安装tun/tap隧道：[安装地址(需翻墙)](http://build.openvpn.net/downloads/releases/)
选择并下载tap-windows-xxx.exe安装

假设我们通过**无线网络连接**来进行vpn
安装后，重命名网络连接名称（共需重命名2个）

![](/images/shadowvpn_conf/s_vpn3.png)

把编译后的shadowvpn.exe放到一个目录下
然后[下载client.conf等文件](https://github.com/lixingcong/shadowVPN/tree/master/samples/windows)，放到同目录
	
    client.conf
    client_up.bat
    client_down.bat
    

改动client.conf使得跟服务端一样
**tunip=服务端的server.conf中的网关+0.0.0.1**
如果我的Shadowvpn服务端netmask设置为10.7.0.1，那么：

	tunip=10.7.0.2

改动接口名称（就是**改名后的tun通道**）

	intf=vpn
    
    
打开client_up.bat和client_down.bat，**同时改动两个文件里面的两个值**
改动服务端的网关

	remote_ip=10.7.0.1 
    
改动“无线网络”英文名

	orig_intf="Wi-Fi"
    
创建一个快捷方式，输入

	shadowvpn.exe -c client.conf -s start

使用**管理员权限**运行即可
待出现 “ server_up.bat Done ” 即可上网
使用结束，注意不能点击右上角x关闭，要按ctrl+c进行还原操作关闭

#### openwrt版
详见[openwrt-shadowvpn项目](https://github.com/aa65535/openwrt-shadowvpn/releases)，自行参考上文的配置

对于 DNS 污染，可以直接使用 Google DNS 8.8.8.8，或者使用 ChinaDNS 综合使用国内外 DNS 得到更好的解析结果。

可以采用Chinadns设置上游服务器114.114.114.114,8.8.8.8，然后让dns走加密隧道

    route add -host 8.8.8.8 dev tunX （tunX是你ShadowVPN的interface） 
   
路由追踪一下是否走Shadowvpn：

	traceroute 8.8.8.8 

## 多用户

需要注意的是 ShadowVPN 是一个点对点 VPN。意味着对于每个客户端，需要一个对应的服务端。 
可以开启多个服务端进程，用 -c 参数指定不同的配置文件。
请确保对于不同的服务端和客户端， 在 up 和 down 脚本中指定了不同的 IP。

### 服务端

若是源安装比较方便，修改server.conf中的token即可，先生成token

	xxd -l 8 -p /dev/random
    
填入user_token即可，逗号分隔。即可完成。

若是编译安装：*以编译成功的0.1.6版本为例，不适合源安装*

- 把server.conf sever_up.sh sever_down.sh 拷贝一份，我放到/root/vpn
- 然后打开server.conf
- 修改tun0为tun1
- 修改port=777
- 修改mtu
- 修改up=/root/vpn/server_up.sh
- 修改down=/root/vpn/server_down.sh
- 修改指向不同的pid和log文件
- 然后打开server_up.sh修改网关地址和netmask(有可能在server.conf内)
- 执行第二个服务端进程实例
		/usr/local/bin/shadowvpn -c /root/vpn/server.conf -s start

### 客户端

填入对应的token，或者对应的ip+端口。
linux貌似不需要太大改变配置。
windows版注意及时修改同样的conf文件和server_up.bat

#### 后记

截止2015.8.22,作者已经停止维护ShadowVPN，并删除相关代码，因为众所周知的喝茶原因。
![](/images/shadowvpn_conf/tea.png)

我觉得，Shadowvpn是一个比Shadowsocks更强大的工具，可惜，流产了。留下给我们的，是一个早产、有各种bug的版本，使用上有各种不方便，还有难以开展多用户，不适合商家售卖。

需要各位勇士对其进行维护，当然，互联网上做这样擦边球的应用，切记要小号，匿名。




