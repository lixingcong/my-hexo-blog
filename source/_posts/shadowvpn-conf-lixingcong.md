title: 我的ShadowVPN配置记录
date: 2015-09-08 16:41:48
tags: shadowsocks
categories: 网络
---
## 服务端设置

在vps（ubuntu 12.04.5 x64）上面操作：
安装必要的编译工具

	sudo apt-get install build-essential mingw-w64 autoconf libtool
<!-- more -->
获取源码（截止2015.9.8,作者已经停止维护，因为众所周知的喝茶原因）

    wget http://entware.dyndns.info/sources/shadowvpn-0.1.6-20150721.tar.bz2
    tar -xvf shadowvpn-0.1.6-20150721.tar.bz2
    cd shadowvpn-0.1.6-20150721/
    sh ./autogen.sh

### 编译linux服务端

	./configure --enable-static --sysconfdir=/etc
	make && make install
    
### 编辑服务端配置

配置目录：/etc/shadowvpn/
这是server.conf

![](/images/shadowvpn_conf/s_vpn1.png)

这是server_up.sh

![](/images/shadowvpn_conf/s_vpn2.png)

配置方法：

- 打开server.conf
- 修改port=666
- 修改mtu
- 修改密码
    
*PS:修改mtu这一步很重要，会直接影响vpn速度。*
详细的mtu设置讨论帖子：[点击这里](https://github.com/clowwindy/ShadowVPN/issues/77)
大概意思就是如[@linhua55](https://github.com/linhua55)所说的方法：

    MTU of PPPoE is 1452, But it differs between your network.
    首先用Windows插上网线
    进行正常的拨号（若是DHCP，则跳过这步，主要目的是模拟路由器拨号）
    cmd执行 ping -f -l 1452 www.baidu.com
    逐步加大或者减少该值，直到恰好不会出现DF拆包的提示。记下这个mtu
    例如，记下的mtu是1452，计算得到1452-20-8-24=1400
    那么在服务端的server.conf填入1400
    客户端建议也一致填写1400

### 运行服务端

	/usr/local/bin/shadowvpn -c /etc/shadowvpn/server.conf -s start
    
### 多用户客户端

#### 多用户服务端

*以编译成功的0.1.6版本为例，不适合源安装的最新版本*
服务器上面操作：

- 把server.conf sever_up.sh sever_down.sh 拷贝一份，我放到/root/vpn
- 然后打开server.conf
- 修改tun0为tun1
- 修改port=777
- 修改mtu
- 修改up=/root/vpn/server_up.sh
- 修改down=/root/vpn/server_down.sh
- 修改指向不同的pid和log文件
- 然后打开server_up.sh修改网关地址10.8.0.1
- 执行第二个服务端进程实例
		/usr/local/bin/shadowvpn -c /root/vpn/server.conf -s start
        
#### 多用户客户端

修改同样的conf文件，注意Local Subnet为10.8.0.2/24
win客户端的修改local subnet在server_up.bat和down两个文件里

### 另一种安装客户端方法：使用deb源

优点：
- 版本比较新
- 有daemon守护进程

缺点：
- 因带有token，只适合路由器多客户端
- 无法在windows上面使用user——token进行多客户端

方法:

	vi /etc/apt/sources.list   添加
	deb http://shadowvpn.org/debian wheezy main
    apt-get update
	apt-get install shadowvpn
    
直接配置多用户：使用user_token，生成方法见server.conf注释。

## 客户端设置

### ubuntu 14.04 x64客户端

#### 编译

（我不选择使用源安装，理由：很难配置多用户实例）

    sudo apt-get install build-essential mingw-w64 autoconf libtool
    wget http://entware.dyndns.info/sources/shadowvpn-0.1.6-20150721.tar.bz2
    tar -xzvf shadowvpn-0.1.6-20150721.tar.bz2
    cd shadowvpn-0.1.6-20150721/
    sudo sh ./autogen.sh
    sudo ./configure --enable-static --sysconfdir=/etc
	sudo make
    sudo make install
    
#### ubuntu客户端配置
如果是从源安装的，需要修改/etc/init.d/shadowvpn的启动参数为加载client.conf配置文件。否则开机自动启动是server模式，以下内容不适合daemon的实例。

编译版shadowvpn的设置：

改动密码，端口，mtu等（跟服务器一致）

	sudo gedit /etc/shadowvpn/client.conf

添加dns

	sudo gedit /etc/shadowvpn/client_up.sh
    
添加一句

	# Change DNS server to 8.8.8.8
	grep -q "8.8.8.8" /etc/resolv.conf||echo "nameserver 8.8.8.8">>/etc/resolv.conf
    
#### 运行

	sudo shadowvpn -c /etc/shadowvpn/client.conf -s start
    
### Windows客户端

[下载我的预编译版本](/attachments/my_conf_of_shadowvpn/shadowvpn_0.1.6.zip)

#### 交叉编译

在ubuntu 14.04.3 x64下操作：
获取源码方法跟上面linux客户端一致

	./configure --host=i686-w64-mingw32 --enable-static
	make
    
大概一分钟吧~然后从src目录下获得一个shadowvpn.exe，复制到win系统吧！

#### 配置win客户端

先安装tun/tap隧道：
[安装地址(需翻墙)](http://build.openvpn.net/downloads/releases/)
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

	tunip=10.7.0.2

改动接口名称（就是**改名后的tun通道**）

	intf=vpn
    
    
打开client_up.bat和client_down.bat，**同时改动两个文件里面的两个值**
改动服务端的网关

	remote_ip=10.7.0.1 
    
改动“无线网络”英文名

	orig_intf="Wi-Fi"
    
#### 运行

创建一个快捷方式，输入

	shadowvpn.exe -c client.conf -s start

使用**管理员权限**运行即可
待出现 “ server_up.bat Done ” 即可上网
使用结束，注意不能点击右上角x关闭，要按ctrl+c进行还原操作关闭



