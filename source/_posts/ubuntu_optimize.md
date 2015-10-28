title: ubuntu通用优化设置
date: 2015-10-28 22:15:46
tags: ubuntu
categories: 编程
---
自己在反复重装过程总结出的经验。可以供大家参考

## 笔记本开机亮度

每次都是来那个瞎眼的亮度，我也是醉了，14.04居然还没有修复这个bug。
<!-- more -->
跟黑苹果一个吊样。囧

控制亮度的文件位置：
- 对于MBR格式安装的ubuntu，控制亮度在/sys/class/backlight/acpi_video1/brightness
- 对于GPT格式安装的，控制在/sys/class/backlight/intel_backlight/brightness

可以测一下当前的亮度，先手动调节到合适的亮度，打印出当前的亮度值

	cat /sys/class/backlight/intel_backlight/brightness

比如我的是GPT，当前亮度值为480，可以将脚本写入/etc/rc.local进行加载亮度

	vi /etc/rc.local
	echo 480 > cat /sys/class/backlight/intel_backlight/brightness
    
重启看看效果

## 时钟每次比CMOS快8小时

这种状况主要是出现在双系统（win + linux）上，因为win默认是以cmos时间为utc+8后的时间，而ubuntu每次读取cmos时间都是以cmos时间为utc+0，解决方法：[原文链接](http://docs.slackware.com/howtos:hardware:syncing_hardware_clock_and_system_local_time)

解决方法

    vi /etc/default/rcS //将UTC改为no，保存退出
    sudo rm /etc/localtime
    sudo cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    sudo hwclock --systohc --localtime    //将sys-clock与cmos同步

检查是否设置正常：硬件和系统时间一致，且时区为CST。

    sudo hwclock --show //显示cmos中的时间
    sudo date	 //显示当前时间

## 开机自动挂载ntfs
目的是开机自动挂载某个ntfs卷。首先安装gparted看看你的卷是/dev/sdxx多少。然后

	mkdir /media/USER/NTFS
	sudo vi /etc/fstab

在文件中加入挂载命令

	/dev/sdxx /media/USER/NTFS ntfs defaults,locale=zh_CN.UTF-8 0 0 

## 转移chrome缓存

最好的就是关机自动清除缓存，懒人必备，利用ramdisk实现，vi /etc/fstab添加

	tmpfs /dev/shm tmpfs defaults,size=512M 0 0
    
然后退出chrome，建立硬链接。

	sudo rm -rf ~/.cache/google-chrome
	sudo ln -s /dev/shm ~/.cache/google-chrome

测试chrome是否成功：chrome:cache

## 其他

主要是某些小程序安装

gedit disable auto-backup：

	编辑->设置->编辑器 取消选中“保存前创建备份文件”

安装温度监控：

	sudo apt-get install lm-sensors
    sudo sensors-detect
    sudo apt-get install xsensors //或者ksensors(KDE中推荐使用ksensors)
    
滚动条模式：

	使用经典滚动条命令：
	gsettings set com.canonical.desktop.interface scrollbar-mode normal
	恢复overlay scoller滚动条：
	gsettings reset com.canonical.desktop.interface scrollbar-mode
    
修改默认的session for 14.04

	cat /usr/share/xsessions //记下需要设置的session名字
    sudo gedit /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf
    把user-session改为适合。
    
网速指示 for gnome:

    sudo add-apt-repository ppa:nilarimogard/webupd8
    sudo apt-get update
    sudo apt-get install indicator-netspeed
    
cpu表格指示 for gnome:

	sudo apt-get install indicator-multiload
    
