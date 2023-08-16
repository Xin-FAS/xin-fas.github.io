---
title: Fetch请求
date: 2022-07-22 12:44:48
tags: [fetch,http请求]
categories: [前端]
---

# Fetch介绍

Fetch是在es6出现的，基于promise设计的，但是Fetch并不是ajax的封装，而是原生的js，无需引入包即可使用，没有XMLHttpRequest对象

# 相比xhr优点

1. 语法更加简单，类似axios
2. 基于es6的Promise对象实现，支持 async / await
3. 对resp，req的操作更加方便

# 使用

## GET请求

```js
fetch('/api/getTestData')
    .then(res => res.json())
    .then(res => {
        console.log('返回消息：', res)
    }).catch(err => {
        console.log('报错信息', err)
    })
```

> 这里需要第一次处理res中的json，第一次是联系服务器成功

或者使用 async / await

```js
sendFetch = async () => {
    // fetch('/api/getTestData')
    //     .then(res => res.json())
    //     .then(res => {
    //         console.log('返回消息：', res)
    //     }).catch(err => {
    //         console.log('报错信息', err)
    //     })
    const res = await fetch('/api/getTestData')
    const jsonRes = await res.json()
    console.log(jsonRes)
}
```

## POST请求

```js
const base = {
    name: 'FSAN',
    age: 20
}
fetch('/api/postTestData', {
    method: 'post',
    body: JSON.stringify(base),
    headers: {
        'Content-Type': 'application/json'
    }
})
    .then(res => res.json())
    .then(res => {
        console.log('返回消息：', res)
    }).catch(err => {
        console.log('报错信息', err)
    })
```
