---
title: 让使用Axios变得优雅一点
date: 2023-09-11 21:50:49
tags: [JavaScript, Axios, Mock]
categories: [前端,前端其他]
---

## 介绍

基于axios和mockjs封装，请先安装

```bash
npm i axios mockjs
```

其他不介绍了，直接看使用好了

## 详细流程

### 创建文件结构（不重要，可自己改）

> `src`
>
> > `http`
> >
> > > `axios`
> > >
> > > > `apis`
> > > >
> > > > > `demoModule.js`
> > > > >
> > > > > `...js`
> > >
> > > > `interceptor.js`
> > >
> > > `mock`
> > >
> > > > `interceptor.js`

### 文件内容

### axios 下的 interceptor.js（核心）

```js
/**
 * @author Xin-FAS
 */

import axios from 'axios'
import { clearToken, getToken } from '@/utils/handler-token'

// 请求拦截器
const beforeFilter = req => (req.headers.token = getToken(), req)
// 响应拦截器
const afterFilter = ({
    status,
    statusText,
    data: { msg, data, code }
}) => {
    if (status !== 200) {
        console.error(statusText || '系统异常！')
        return Promise.reject(statusText)
    }
    // 判断token过期
    // if (data.code === 1002) {
    //     router.push('/info')
    //     // 登出操作，清空token + 清空用户信息
    //     clearToken()
    //     const store = useUserStore()
    //     store.user = {}
    // }
    if (code !== 200) {
        console.error(msg || '请求失败！')
        return Promise.reject(msg)
    }
    return { data, msg }
}

const defaultBaseOptions = {
    timeout: 6000
}
// 创建一个axios请求对象
const createAxiosInstance = (baseOptions, addMock = true) => {
    const axiosInstance = axios.create(Object.assign({}, defaultBaseOptions, baseOptions))
    axiosInstance.interceptors.request.use(beforeFilter)
    axiosInstance.interceptors.response.use(afterFilter)
    return options => {
        if (!addMock) return axiosInstance(options)
        const waitInstance = resolve => axiosInstance(options).then(resolve)
        waitInstance.mock = resolve => MockHTTP(options).then(resolve)
        return waitInstance
    }
}

// mock请求头
const MockHTTP = createAxiosInstance({ baseURL: '/mock' }, false)
// 基础公共请求头
const BaseInstance =  createAxiosInstance({ baseURL: '/api' })
// 本地资源请求头
const LocalInstance = createAxiosInstance({ baseURL: '/src/assets' })

export {
    BaseInstance,
    LocalInstance
}
```

### axios 下 apis api文件（例子）

```js
/**
 * @author Xin-FAS
 */
import { BaseInstance } from '@/http/axios/interceptor'

const DemoAPI = name => BaseInstance({
    url: '/demo',
    params: {
        name
    }
})

export {
    DemoAPI
}
```

### mock 下的 interceptor.js（例子）

```js
/**
 * @author Xin-FAS
 */

import { mock } from 'mockjs'

mock(/\/mock\/demo/, 'get', {
    code: 200,
    msg: '操作成功！',
    data: [
        {
            name: '123',
            age: 123
        },
        {
            name: '123',
            age: 123
        },
    ]
})
```

## 使用

### createAxiosInstance 创建时 addMock 为true（默认）

下列中的实例配置同`axios`配置（`axios > apis > xxx.js`）

```js
const DemoAPI = name => BaseInstance({
    url: '/demo',
    params: {
        name
    }
})
```

页面中使用，例一：

```js
DemoAPI('Xin-FAS')()
```
传入`name`为`Xin-FAS`，返回`/api/demo?name=Xin-FAS`接口数据，注意返回此处由拦截器处理`code`

例二：

```js
DemoAPI('Xin-FAS').mock()
```

传入`name`为`Xin-FAS`，返回`/mock/demo?name=Xin-FAS`接口数据，mock中拦截返回

其中，以上两个例子，第二个方法中可传入一个函数用于直接接受接口返回，如下：

```js
await DemoAPI('Xin-FAS')(({ data }) => data.filter(v => v))
```

### createAxiosInstance 创建时 addMock 为 false

以上例子中配置不变，页面使用改变为如下：

例一：

```js
DemoAPI('Xin-FAS')
```

这样就算直接请求了，不需要再执行

例二写法就不存在了，因为原型上已经没有`mock`方法了

