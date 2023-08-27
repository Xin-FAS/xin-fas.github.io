---
title: docker部署redis
date: 2022-01-20 02:13:30
tags: [Docker,Redis]
categories: [后端,服务器]
---

### 拉取镜像

```bash
docker pull redis
```

### 准备redis配置文件
中文官网：http://www.redis.cn/download.html

去redis中文官网进去点击download解压后拿到redis.conf即可

配置redis.conf，主要配置如下：
1. bind 127.0.0.1  #注释这部分，使redis可以访问外部
2. daemonize no  #用守护线程访问
3. requirepass 你的密码  #给redis设置密码
4. appendonly yes  #redis持久化  默认为no
5. tcp-keepalive 300   #防止出现远程主机强迫关闭了一个现有的连接的错误，默认为300

### 创建docker映射目录

配置文件：/myRedis/redis.conf

持久化文件：/myRedis/data

### 生成容器并启动

```bash
docker run -d -p6380:6379 --name myRedis -v /myRedis/data:/data -v /myRedis/redis.conf:/etc/redis.conf redis redis-server /etc/redis.conf --appendonly yes
```

* redis启动默认端口为6379，映射到宿主机6380
* -v /myRedis/data:/data  将redis容器内的data持久化的数据挂载到宿主机/myRedis/data
* -v /myRedis/redis.conf:/etc/redis.conf   将宿主机配置好的配置文件映射到容器/etc/redis.conf这个位置
* redis-server /etc/redis.conf   关键配置，让redis不是无配置启动，而是使用/etc/redis.conf配置文件

### 查看日志是否成功

```bash
docker logs 容器id
```

### 进入redis命令行

```
root@8810fdef372c:/data# redis-cli
```
