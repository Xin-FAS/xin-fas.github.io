---
title: python简单爬虫
date: 2022-08-16 22:29:32
tags: [python,爬虫]
---

## 通用头部参数

| 名称            | 说明                                                         |
| --------------- | ------------------------------------------------------------ |
| Cookie          | 用户信息，在headers部分，包含登录校验、签名认证才可能需要cookie |
| User-Agent      | UA是最基本的headers之一，是浏览器类型，其中包含windows系统信息，html版本和浏览器版本和内核信息 |
| Referer         | Referer也是最基本的headers之一——防盗链接，它用来验证你的来源，需要告诉请求地址，是从哪里来的 |
| Origin          | 域名，带http协议的是域名                                     |
| Host            | 主机名称                                                     |
| Content-Type    | 请求内容的类型                                               |
| Content-Length  | 内容的长度                                                   |
| Connection      | 链接方式，TCP的长 短链接                                     |
| Accept-Language | 语言                                                         |
| Accept-Encoding | 编码                                                         |
| Accept          | 获取数据的类型                                               |

> 问题一：如何知道cookie有无加密？
>
> 通过set-cookie属性判断

## 私有头部参数

对于私有的头部参数，可能是时间戳或加密的信息，需要在发起程序中搜索对应名称寻找是如何生成的

| 名称 | 说明           |
| ---- | -------------- |
| sign | 签名，需要解密 |
|      |                |
|      |                |

## 断点找请求信息

1. 复制请求地址（不含网站名，如 `/front/search`）添加到源代码中的xhr断点中，刷新请求
2. 点击下一步或快捷键F9，调试到出现需要的路径（`cacheURL`）
3. 找到请求头（`request`），里面所需的字段名就是前端校验的字段名，都需要模拟填充
4. 再看到请求配置项（`options`）【这步也可以直接在控制台输入`options`查看】，复制data替换
5. 调试完成后删除所有断点

## 关于接口数据搜索为空

### 判断原因

先确定是静态数据还是动态数据，静态数据和动态数据搜索失败有以下问题：

**静态数据：**

1. 字体加密问题

**动态数据：**

1. Unicode编码中文问题
2. 数据加密问题

**判断是否为静态数据：**

直接去源代码的静态代码中查找所要的数据，没有就说明数据是动态加载的

**判断是否为编码问题：**

使用数字去搜索，没有找到数据地址，说明数据经过加密

## 跟栈调试

跟栈调试主要是为了寻找js的加密函数

**具体步骤：**

找到请求资源中的发起程序，找到js源代码，对应行打上断点（点击行号），然后刷新浏览器或点击相同获取资源的地址，在渲染出静态页面后，开始通过跳过函数的形式找数据（就是之前看到很长的字符串），看到数据后，放慢速度找解析后的明文数据（找到后可以直接在控制台输入属性名获取值），然后进入源码解析部分打上断点（这里可取消之前的断点），详细查看找到解析函数的本地地址的源代码复制到自己的js中，再次刷新，选择单步调试（F9），查看传入函数的参数信息，配合上下文可找到其中的变量参数

## 寻找加密函数

加密后的数据data不是为一个正常对象，而是一大串的字符串

> 要知道的原理：
>
> 加密数据要正常在浏览器上显示，肯定在浏览器的js中有解密的操作
>
> 加密的数据无法通过xhr断点调试来找到数据

### 方式一（较为麻烦）：

找到最大的数据源，利用发起程序从源代码中一步步找（具体看上面跟栈调试）

### 方式二（简单）：

利用异步请求为JSON交互的原理，先寻找调用过数据接口的js，然后寻找到`JSON.parse`后面的数据函数即是加密函数，断点后可进入查看

## 解密操作

找到加密函数后，利用变量参数声明一个环境变量，在加密函数中分析加密算法，如`AES`

> 跟栈调试过程中可能会卡住，将调试窗口弹出可缓解
>
> 声明环境变量如下：
>
> ```python
> window = global
> window.c = "3sd&d2"
> window.r = "4h@$udD2s"
> window.a = "*"
> ```

此时的js如下：

```js
window = global
window.c = "3sd&d2"
window.r = "4h@$udD2s"
window.a = "*"

const decode = (n, e) => {
    e = e || "".concat(c).concat(r).concat(a);
    var t = o.a.enc.Utf8.parse(e)
        , i = o.a.AES.decrypt(n, t, {
        mode: o.a.mode.ECB,
        padding: o.a.pad.Pkcs7
    });
    return o.a.enc.Utf8.stringify(i).toString()
}
```

> decrypt 解密的意思，所以这里看到是AES加密算法
>
> 安装crypto-js（前端加密常用）包用与AES解密
>
> ```bash
> npm i crypto-js
> ```

导入crypto-js这个包

```js
const cryptoJs = require('crypto-js')
```

分析加密函数可得，`o.a` 即是AES解密库`cryptoJs`，所以替换即可，最后将获取的加密数据放入即可

```js
const key = "GX/x7w1X1XbC/GMS/..."

const cryptoJs = require('crypto-js')

window = global
window.c = "3sd&d2"
window.r = "4h@$udD2s"
window.a = "*"

const decode = (n, e) => {
    e = e || "".concat(c).concat(r).concat(a);
    var t = cryptoJs.enc.Utf8.parse(e)
        , i = cryptoJs.AES.decrypt(n, t, {
        mode: cryptoJs.mode.ECB,
        padding: cryptoJs.pad.Pkcs7
    });
    return cryptoJs.enc.Utf8.stringify(i).toString()
}

console.log(decode(key));
```

> 这里的e通过跟栈调试发现为空值，所以不用管

以上就是逆向解密，但是上面的加密数据不够完善，大型网站也不止是abs加密

## 使用python执行js代码

现有解密函数如下：

```js
function h(t) {
    const cryptoJS = require('./crypto-js/crypto-js'),
        f = cryptoJS.enc.Utf8.parse("jo8j9wGw%6HbxfFn"),
        m = cryptoJS.enc.Utf8.parse("0123456789ABCDEF"),
        e = cryptoJS.enc.Hex.parse(t),
        n = cryptoJS.enc.Base64.stringify(e),
        a = cryptoJS.AES.decrypt(n, f, {
            iv: m,
            mode: cryptoJS.mode.CBC,
            padding: cryptoJS.pad.Pkcs7
        }),
        r = a.toString(cryptoJS.enc.Utf8);
    return JSON.stringify(r)
}
```

要在python中使用，完成整体流程，就要使用到`PyExecJS`这个包下的`execjs`

安装：

```bash
pip install PyExecJS
```

引入使用：

```python
from execjs import compile
setName = compile('''
    function setName (name) {
        return 'hello ' + name
    }
''').call('setName', 'FSAN')
print(setName) # hello FSAN
```

1. 先使用compile创建一个js的文件环境
2. 然后使用call去执行里面的函数名，传递参数
3. 返回值就是js函数的返回值

> 如果返回的内容有中文的话，会出现乱码问题，进入报错的文件将encoding修改为'utf8'即可

## 完整爬取流程（简单aes加密）

main.py

```python
# -*- coding: utf-8 -*-

from requests import get
from json import loads
from time import sleep
from random import random, randint
from execjs import compile

# 请求头
headers = {
    'Referer': 'https://jzsc.mohurd.gov.cn/data/company',
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36'
}

# 获取本地js解密函数
with open('./main.js', encoding='utf8') as file:
    decryptFn = compile(file.read())


# 请求加密数据
def get_data(page):
    url = f'https://jzsc.mohurd.gov.cn/api/webApi/dataservice/query/comp/list?pg={page}&pgsz=15&total=0'
    sleep(random() + randint(0, 2))
    return get(url=url, headers=headers).text


# 获取分页数据
for page in range(30):
    # 解密后写入本地
    decryptData = decryptFn.call('h', get_data(page))
    with open(f'./jsonData/decryptDataForPage{page}.json', 'w+', encoding='utf8') as file:
        file.write(loads(decryptData))
        print(f'第{page}页数据已保存')
```

main.js（解密函数）

```js
function h(t) {
    const cryptoJS = require('./crypto-js/crypto-js'),
        f = cryptoJS.enc.Utf8.parse("jo8j9wGw%6HbxfFn"),
        m = cryptoJS.enc.Utf8.parse("0123456789ABCDEF"),
        e = cryptoJS.enc.Hex.parse(t),
        n = cryptoJS.enc.Base64.stringify(e),
        a = cryptoJS.AES.decrypt(n, f, {
            iv: m,
            mode: cryptoJS.mode.CBC,
            padding: cryptoJS.pad.Pkcs7
        }),
        r = a.toString(cryptoJS.enc.Utf8);
    return JSON.stringify(r)
}
```

## 常见加密算法

掌握web逆向技术，需要掌握的加密算法有：

1. MD5
2. AES
3. DES
4. RSA
5. HASH
6. ECC
7. SHA

### MD5加密特征

如下：

```js
t = h(t, u, v, w, x[o + 0], y, 3614090360),
w = h(w, t, u, v, x[o + 1], z, 3905402710),
v = h(v, w, t, u, x[o + 2], A, 606105819),
u = h(u, v, w, t, x[o + 3], B, 3250441966),
t = h(t, u, v, w, x[o + 4], y, 4118548399),
w = h(w, t, u, v, x[o + 5], z, 1200080426),
v = h(v, w, t, u, x[o + 6], A, 2821735955),
u = h(u, v, w, t, x[o + 7], B, 4249261313),
t = h(t, u, v, w, x[o + 8], y, 1770035416),
w = h(w, t, u, v, x[o + 9], z, 2336552879),
v = h(v, w, t, u, x[o + 10], A, 4294925233),
u = h(u, v, w, t, x[o + 11], B, 2304563134),
t = h(t, u, v, w, x[o + 12], y, 1804603682),
```

用数字做混淆的就是MD5加密

## 响应数据为纯json渲染

与ajax数据相比：纯json数据在前面会有数据名，如：`mtopjson2({api: ...})`

而ajax前面是没有这个字符串的

## 某案例中的sign解密

在数据源的发起程序中搜索sign，寻找到如下代码段：

```js
var f = "//" + (d.prefix ? d.prefix + "." : "") + (d.subDomain ? d.subDomain + "." : "") + d.mainDomain + "/h5/" + c.api.toLowerCase() + "/" + c.v.toLowerCase() + "/"
              , g = c.appKey || ("waptest" === d.subDomain ? "4272" : "12574478")
              , i = (new Date).getTime()
              , j = h(d.token + "&" + i + "&" + g + "&" + c.data)
              , k = {
                jsv: w,
                appKey: g,
                t: i,
                sign: j
            }
              , l = {
                data: c.data,
                ua: c.ua
            };
```

从这里就可以发现sign这个签名是 `h(d.token + "&" + i + "&" + g + "&" + c.data)`这段生成的

分析：数据主体加密函数是h，打断点后查看直接获取token的值，扣代码到js，先不管是否是动态数据

看到`c.data`就要和请求体中的data比较，因为可能不止一个加密，可跳过再次比较，对上之后，在控制台中输入`c.data`可直接获取

> 为什么不直接复制，要先在控制台打印再复制：
>
> 直接复制会导致其中的引号出现问题，控制台打印出来cv就能用

之后进入h源码中，扣下整个函数后执行代码得到sign值

获取sign值后还需要验证：打断点后获取到i的值（时间戳，看页面上sign值是否和本地得到的sign值相同），相同则解密函数正确

## 其他小知识

### 有提示加密的响应数据

比如在预览数据中，有一个`isEncrypt`属性，那么就可以直接使用这个属性去搜索加密函数

### iv属性判断

在加密过程中发现iv属性设置，就是AES加密模型
