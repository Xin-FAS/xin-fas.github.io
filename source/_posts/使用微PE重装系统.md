---
title: 使用微PE重装系统
date: 2023-08-14 22:24:16
tags: []
categories: [教程文档]
---

## WinPE介绍

微软文档：https://learn.microsoft.com/zh-cn/windows-hardware/manufacture/desktop/winpe-intro

简单来说PE系统（windows预安装系统）主要功能就是用于刷机和修复windows系统

> PE系统也是一个windows系统，只不过这个系统去掉了大部分的功能，只保留了基本的运行环境

## 硬件要求

一个u盘

## 软件要求

1. 一个系统镜像，也就是iso文件，可以去MSDN下载（需要哪个就装哪个，在制作WTG的那篇中对各系统版本有作介绍）
2. 微PE工具箱，下载地址https://www.wepe.com.cn/download.html

## 正式开始

请先满足以上两个要求

### 制作PE盘

打开微PE工具箱，点击右下角USB形状的图标，安装PE到U盘，点开之后，选择好待写入U盘后点击立即安装就可以了

安装完成后，把系统镜像放入U盘中，这样PE盘就制作好了

> 这时查看自己的设备，会多出一个EFI分区，这个分区是用于存放PE系统的分区，不要放入任何东西

### 启动PE系统

直接重启，进入BIOS修改启动选项 Setting > Security 为所用u盘，选好后保存退出

### 重装方法一

进入PE系统后，直接打开U盘，右键镜像文件后装载后跟着提示走

### 重装方法二

#### 磁盘分区

在PE系统中先打开分区工具（DiskGenius），在左边磁盘中选中设备，如下图：

![image.png](https://s2.loli.net/2023/08/14/6EG2HzqsbtoCawY.png)



上图中为右键红框中的HDO:VMwarexxxxxxx，步骤

1. 右键后点击删除所有分区
2. 点击左上角保存更改
3. 右键后点击快速分区

> 自己看清楚哪个才是设备的系统盘，不要选错把自己PE盘格了

会看到如下：

![sp20230814_230414_515.png](https://s2.loli.net/2023/08/14/Cvf1325ril4RPeN.png)

自己选择分区数量和选择分区大小后点击确定就可以了

#### 使用windows安装器

打开桌面上的windows安装器，第一个选择系统镜像，第三个为选择安装驱动器的位置，打开搜索后选择C盘

然后在这个选项中选择需要安装的系统版本

![image.png](https://s2.loli.net/2023/08/14/ziOcPxJl7gbYk9s.png)

选择好了之后其他都不需要改，点击安装，出现的弹窗点击确认等待安装

安装完成之后，拔掉u盘，重启电脑就可以进入系统的初始化页面了

