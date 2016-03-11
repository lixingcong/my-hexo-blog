title: GPT分区表上硬盘安装ubuntu
date: 2016-03-12 00:21:14
tags: ubuntu
categories: 编程
---
ubuntu我一直都是使用硬盘安装，没有试过烧录到u盘引导安装，因为不想浪费一个优盘。
在gpt分区表电脑上用传统的MBR引导+grub4dos安装方式，将导致安装efi失败，尚不清楚是什么原因。
<!-- more -->

## 新建小分区

新建一个fat32分区（uefi引导不支持ntfs），大约2GB，能装得下ubuntu的镜像，复制iso到该分区下

WinRAR打开iso镜像文件，提取文件：
- boot文件夹、EFI文件夹解压到FAT32分区中
- casper文件夹中的 initrd.lz 和 vmlinuz.efi 解压出来
 
目录结构是这样的：
![](/images/install_ubuntu_on_gpt/files.png)

## 查分区序号

打开diskgenius
- 观察左侧硬盘序号，很简单，自上而下数一下硬盘序号，注意忽略那些移动硬盘，还有虚拟ramdisk，还有u盘。grub是从0开始编号硬盘号：HD0代表第一个硬盘，HD1代表第二个硬盘。
- 观看某一个硬盘里面每一个分区序号，由于diskgenius从ESP分区开始0编号，而grub从1开始编号，所以该fat32分区序号加1就得到grub的序号。

![](/images/install_ubuntu_on_gpt/partions.png)

得到的硬盘号和分区号记下来。
 
## 修改grub配置

使用Notepad++或者类似的第三方记事本应用程序修改FAT32分区的/boot/grub/grub.cfg
*不建议使用系统记事本，无法保存为Unix行尾回车符*

文件中部找到以 menuentry 开头的四段，把它们都删除了，换成下面的menuentry内容，
 
    menuentry "Install Ubuntu on GPT" {
    set root=(hd0,gpt5)
    loopback loop /ubuntu-14.04-desktop-amd64.iso
    linux (loop)/casper/vmlinuz.efi persistent boot=casper iso-scan/filename="/ubuntu-14.04-desktop-amd64.iso" quiet splash ro locale=zh_CN.UTF-8 noprompt --
    initrd (loop)/casper/initrd.lz
    }
    
以上内容，根据每个人电脑实际情况，要修改的地方有：
- set root=(hd0,gpt5) 根据上面获得的硬盘序号改动
- ubuntu-14.04-desktop-amd64.iso 镜像文件名根据实际改动
- initrd.lz 和 vmlinuz.efi 根据实际的解压出来的名称改动

## 添加efi引导项

最后使用 bootice x64 1.3.3 以上的版本EFI引导
引导文件位置：

	\EFI\BOOT\grubx64.efi

顺便勾选“下次从该引导项启动”，重启。进入LiveCD系统
 
## 后续

卸载isodevice卷：少了这一步会分区失败

	sudo umount -l /isodevice

正常安装，选择安装引导器到整个硬盘，而不是windows boot loader
