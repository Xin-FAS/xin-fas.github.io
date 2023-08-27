---
title: docker部署python项目
date: 2022-02-20 19:48:47
tags: [Docker,Python]
categories: [后端,服务器]
---

## 流程介绍

1. 开发项目并本地测试通过
2. 编写 Dockerfile 放置项目根目录
3. 打包镜像文件
4. 创建并运行镜像容器

## 创建文件结构

1. 建立一个文件夹，名称随便，如 dockerpython
2. 在文件夹中创建Dockerfile文件，project文件夹（用于存放项目代码，名称随便）
3. 进入project文件夹，执行 `pip freeze > requirements.txt` 生成项目配置文件

4. 输入 Dockerfile 文件内容

```
# 基于的基础镜像
FROM python:3.8

# 代码添加到code文件夹
ADD ./project /code   

# 设置code文件夹是工作目录
WORKDIR /code

# 安装支持
RUN pip install -r requirements.txt

# 设置容器启动时执行的文件
CMD ["python", "/code/main.py"]
```

## 上传至服务器中并生成镜像

1. 将dockerpython文件夹压缩上传到服务器中
2. 使用 unzip 文件名.zip 解压
3. 进入解压后的文件中，执行：`docker build -t python_images .`

> python_images 是生成的镜像名称，不可大写

## 生成容器并运行

```bash
docker run -it -dp5001:5000 --name pythonName python_images
```

退出容器，但不关闭运行：ctrl + p + q
