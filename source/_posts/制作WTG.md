---
title: 制作WTG
date: 2023-08-13 21:46:07
tags: []
categories: [教程文档]
---

# WTG介绍

## 是什么

WTG即Windows to go，简称为WTG。对于WTG的规定请看：

https://learn.microsoft.com/zh-cn/windows/deployment/planning/windows-to-go-overview

## 好处

1. WTG和使用它的设备相互独立，资料互不影响
2. WTG的u盘可以随声携带
3. WTG可以让你在不同电脑中使用自己熟悉的环境
4. 即使u盘已经装了WTG系统，但还可以正常使用

# 开始制作

## 硬件准备

一个32g以上u盘

> 个人建议：有条件最好使用外接的固态硬盘

## 下载系统镜像

官方：https://www.microsoft.com/zh-cn/software-download

MSDN（有迅雷推荐使用）：https://msdn.itellyou.cn/?lang=zh-cn

> 版本选择：
>
> 1. Enterprise：企业版（推荐）
> 2. Education：教育版（不推荐）
> 3. Multiple Editions：多个版本，后续可选（推荐）
> 4. Pro：专业版（推荐）
> 5. Pro N：专业版（欧洲）
> 6. Home：家庭版（不推荐）
> 7. Pro xxxxx：专业工作站（推荐）

## 下载WTG辅助工具

萝卜头：https://bbs.luobotou.org/thread-761-1-1.html

## 使用辅助工具

 ![image.png](https://s2.loli.net/2023/08/13/FYsEgWKwfD9Odm4.png)

1. 点击浏览，选择系统镜像

2. 点击选择移动设备（目标u盘）
3. 选择安装分卷（选择系统镜像中的版本，如下载的是多个版本的镜像，看上方的版本选择）

上方选择好之后，在右侧高级功能中点击分区

 ![image.png](https://s2.loli.net/2023/08/13/k6WaBubIeE3sgrw.png)

建议：分两个区，分区1为系统盘

选择好之后点击部署，慢慢等待就可以了

# 使用WTG系统

1. 当软件提示制作完成之后，重启电脑，进入BIOS，具体查看对应主板按键或笔记本按键（通常为F2）
2. 设置系统启动项为你的u盘后F10保存即可（BIOS中Security）

