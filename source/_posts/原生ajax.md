---
title: 原生ajax
date: 2021-07-13 02:26:40
tags: [JavaScript,Ajax]
categories: [前端,前端其他]
---

## ajax简介
Ajax（Asynchronous JavaScript and XML），直译为“异步的JavaScript与XML技术”，是一种创建交互式网页应用的网页开发技术，用于创建快速动态网页，由杰西·詹姆士·贾瑞特所提出。与传统的Web应用相比，Ajax通过浏览器与服务器进行少量的数据交换就可以实现网页的异步更新，在不重新加载整个网页的情况下，即可对网页进行更新。


## 简单操作
```javascript
//根据浏览器创建ajax实例
function createXMLHttpRequest() {
    if (window.XMLHttpRequest) {
        xmlHttpRequest = new XMLHttpRequest();
    } else {
        xmlHttpRequest = new ActiveXObject("Microsoft.XMLHTTP");
    }
}
```
### get请求
1. 创建ajax实例对象
2. 设置接口地址
3. 设置回调函数
4. 设置实例对象（请求方式，请求地址，是否异步）
5. 发送
6. 接收判断
```javascript
// 发送请求
function ajaxGet() {
    createXMLHttpRequest();
    String url = "[接口地址]";
    xmlHttpRequest.onreadystatechange = handle;
    xmlHttpRequest.open("GET", url, true);
    xmlHttpRequest.send(null);
}
// 设置回调函数的接收
function handle() {
    if (xmlHttpRequest.readyState == 4 && xmlHttpRequest.status >= 200 && xmlHttpRequest < 300) {
            alert(xmlHttpRequest.responseText)
        }
}
```
### post请求
1. 创建ajax实例对象
2. 设置接口地址
3. 设置实例对象（发送方式，发送地址，是否异步）
4. 设置数据源（只有post需要）
5. 设置请求头
6. 开始发送，使用JSON.stringify（）编译数据
7. 设置回调函数以及判断状态码
8. 接收判断
```javascript
// 发送请求
function ajaxPost() {
    createXMLHttpRequest();
    String url = "[接口地址]";
    xmlHttpRequest.open("POST", url, true);
    var data = {};
    // 设置请求头，让服务器知道发的是json格式
    xmlHttpRequest.setRequestHeader("content-type", "application/json");
    xmlHttpRequest.send(JSON.stringify(data));
    xmlHttpRequest.onreadystatechange = function () {
        if (xmlHttpRequest.readyState == 4 && xmlHttpRequest.status >= 200 && xmlHttpRequest < 300) {
            alert(xmlHttpRequest.responseText)
        }
    }
}
```