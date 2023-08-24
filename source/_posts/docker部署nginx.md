---
title: docker部署nginx
date: 2022-02-08 18:37:02
tags: [Docker,Nginx]
categories: [后端,服务器]
---

## 准备配置文件

对于创建正式的nginx容器需要做磁盘挂载，就需要提前有配置文件，所以先随便生成一个nginx容器用于拷贝配置文件

### 拉取nginx镜像

```bash
docker pull nginx
```

> docker镜像搜索：https://hub.docker.com/

### 创建容器

主要为了拷贝配置文件，创建一个最简单的容器即可

```bash
docker run -dp80:80 --name nginxName nginx
```

### 拷贝出配置文件

先在宿主机建立存放位置，用于存放配置文件和html文件

```bash
cd /
mkdir -p nginx/conf
mkdir -p nginx/html
```
拷贝文件

```bash
# 拷贝配置文件目录和文件
docker cp nginxName:/etc/nginx/nginx.conf /nginx/conf/nginx.conf
docker cp nginxName:/etc/nginx/conf.d /nginx/conf/conf.d

# 拷贝html文件目录
docker cp nginxName:/usr/share/nginx/html /nginx/html/
```

> docker cp：复制一个文件/目录到指定路径，指定容器可以使用容器name或容器id

### 删除临时的nginx容器

```bash
docker stop nginxId
docker rm nginxId

# or 一步到位
docker rm -f nginxId
```

## 正式创建

映射端口到81和对配置文件，html文件做挂载

```bash
docker run \
-dp81:80 \
-v /nginx/conf/nginx.conf:/etc/nginx/nginx.conf \
-v /nginx/conf/conf.d:/etc/nginx/conf.d \
-v /nginx/html:/usr/share/nginx/html \
--name nginxName \
nginx
```

前宿主机，后容器

