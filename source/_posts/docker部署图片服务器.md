---
title: docker部署图片服务器
date: 2022-01-19 20:41:59
tags: [Docker,Nginx]
categories: [后端,服务器]
---

## 介绍

图片服务器就是通过配置nginx服务完成的，所以建立nginx容器的过程就省略了，需要注意的是，在`usr/share/nginx/`下建立一个img文件夹用于存放静态文件，也需要挂载出去

## 区分root和alias

使用root：

```
location /img {
    root /static;
}
```

当访问 /img 路径的时候，nginx会映射到 /static/img 下，如 /img/hello.png 会返回容器根目录下 /static/img/hello.png，即用 /static 加上 /img

使用alias：

```
location /img {
	alias /static;
}
```

当访问 /img 路径的时候，nginx会映射到 /static 下，如 /img/hello.png 返回的是 /static/hello.png，即用 /static 替换掉 /img

## 配置nginx

```conf
location /img/ {
    root   /usr/share/nginx/;
    // 开启静态资源预览
    autoindex on;
}

location / {
    root   /usr/share/nginx/html;
	index	index.html;
}
```

完成后：访问 XXXX:XXX/img/hello.png 就等于访问 /usr/share/nginx/img/hello.png 的资源
