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
- 以下图为例，我的是三星硬盘作为GPT硬盘，其中左侧RomexRamdisk是虚拟磁盘，忽略它。故SAMSUNG硬盘作为第二个硬盘，序号是HD1，看右侧，EMPTY_5GB分区作为引导分区，计算hd3+1=hd4。故记下这个(hd1,gpt4)

![](/images/install_ubuntu_on_gpt/partions.png)

得到的硬盘号和分区号记下来。
 
## 修改grub配置

使用Notepad++或者类似的第三方记事本应用程序修改FAT32分区的/boot/grub/grub.cfg
*不使用系统自带记事本，因记事本这个坑爹货无法保存为Unix格式+UTF8*

文件中部找到以 menuentry 开头的四段，把它们都删除了，换成下面的menuentry内容，
 
    menuentry "Install Ubuntu on GPT" {
    set root=(hd1,gpt4)
    loopback loop /ubuntu-14.04-desktop-amd64.iso
    linux (loop)/casper/vmlinuz.efi persistent boot=casper iso-scan/filename="/ubuntu-14.04-desktop-amd64.iso" quiet splash ro locale=zh_CN.UTF-8 noprompt --
    initrd (loop)/casper/initrd.lz
    }
    
以上内容，根据每个人电脑实际情况，要修改的地方有：
- set root=(hd1,gpt4) 根据上面获得的硬盘序号改动
- ubuntu-14.04-desktop-amd64.iso 镜像文件名根据实际改动
- initrd.lz 和 vmlinuz.efi 根据实际的解压出来的名称改动

## 添加LiveCD引导项

最后使用 bootice x64 1.3.3 以上的版本:
![](/images/install_ubuntu_on_gpt/bootice.jpeg)

在UEFI选项卡中添加EFI引导项，引导文件位置：

	\EFI\BOOT\grubx64.efi

该引导项起个名字，例如ubuntu_install
顺便勾选“下次从该引导项启动”，重启。进入LiveCD系统

注意：Win10如果直接重启无法进入LiveCD。正确做法：开始菜单-> “设置”-> “恢复”-> “使用高级启动”-> 选择“ubuntu_install”。
 
## 安装前任务

卸载isodevice卷：少了这一步会分区失败

	sudo umount -l /isodevice

正常安装，选择安装引导器到整个硬盘，而不是windows boot loader

安装后可以进入win将liveCD那个分区隐藏，不建议删掉该分区（才占2GB），某天又要重装可以直接重来。

## 引导失败处理

假设安装成功了，现有win8 + ubuntu共存，GPT分区。
某一天出**大事**了：
> 觉得win8该重装了，遂开刀。重装过程中，不慎格式化ESP分区
> 现象：能引导win8，因缺少grubx64.efi而无法引导ubuntu
> 此时ubuntu的ext4分区是完整的，仅缺少ESP中的grub2引导文件

使用LiveCD引导（也就是上面这些步骤，进入grub界面停止。敲击C进入命令行）
我试了grub2命令行执行下列命令，其中gpt5是我的/boot挂载点

	set root=(hd1,gpt5)
    configfile /boot/grub/grub.cfg

可以顺利引导原来硬盘的ubuntu，说明grub.cfg是正常的。
进入ubuntu后，安装boot-repair来进行修复EFI引导。

    sudo apt-add-repository ppa:yannubuntu/boot-repair
    sudo apt-get update
    sudo apt-get install -y boot-repair
    boot-repair
    
点击高级选项
- "GRUB位置" -> 单独的/boot/efi"选择当前引导的ESP分区(/sdb1)
- "GRUB选项" -> 取消勾选"Secure Boot"
- "GRUB选项" -> 勾选"重装GRUB前先移除它

执行操作，按提示下载内核并添加引导。