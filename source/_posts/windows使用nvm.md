---
title: windows使用nvm
date: 2023-08-16 22:22:00
tags: []
categories: [教程文档]
---

## 介绍

NVM是node的版本管理工具，用于在一个设备上同时拥有多个node版本，并快速切换使用对应版本npm，同作者所说，nvm最初是基于Mac/Linux的独立项目，并不包含windows的使用，但是他们还是推出了`nvm for windows`

nvm（mac/linux）：https://github.com/nvm-sh/nvm

nvm for windows：https://github.com/coreybutler/nvm-windows

> 目前作者已打算放弃nvm for windows，开发Runtime（NVM4W 2.0.0）作为下一代windows的node管理工具，更多介绍：https://github.com/coreybutler/nvm-windows/wiki/Runtime

## 准备操作

使用nvm管理前，本地必须要先清空node环境

## 下载并安装nvm for windows

下载地址：https://github.com/coreybutler/nvm-windows/releases

最好使用exe进行安装，后续就不需要手动配置环境变量，下载后跟着一步步走就行了，记一下nvm的安装路径，后续需要修改镜像地址

## 配置镜像地址

打开nvm的安装路径，在文件夹中找到`setting.txt`，把下面两行复制到最后

```txt
node_mirror :https://npm.taobao.org/mirrors/node/
npm_mirror: https://npm.taobao.org/mirrors/npm/
```

## 使用

首先查看下可供下载的版本，除了下面这行命令外，也可以直接去node官网查看https://nodejs.org/en/download/releases

```cmd
nvm list available
```

选择好之后下载，如18.17.1

```cmd
nvm install 18.17.1
```

> 建议使用 LTS（长期支持）版本，`nvm install lts`可以下载最新的LTS版本

最后使用这个版本就可以了

```cmd
nvm use 18
```

使用`use`命令时输入的版本号只要保证可以找到并且唯一就行

## 常用命令

* `nvm install <version>`：下载指定版本，可以用`lts`下载最新的LTS版本，用`latest`下载最新版本
* `nvm uninstall <version>`：卸载指定版本
* `nvm list [available]`：查看本地node版本列表，在末尾键入`available`以显示可供下载的版本列表
* `nvm use <version>`：切换到指定版本，支持开头模糊匹配







