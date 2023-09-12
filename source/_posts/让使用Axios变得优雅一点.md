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
> > > > `apis`（存放全部api的文件夹）
> > > >
> > > > > `demoModule.js`（demo模块的api）
> > > > >
> > > > > `...js`（xxx模块的api）
> > >
> > > > `interceptor.js`（axios拦截器）
> > > >
> > > > `instances.js`（axios实例）
> > >
> > > `mock`
> > >
> > > > `interceptor.js`（mock拦截器）

以下文件内容中使用到了`element-ui`中的`Message`组件，可自行替换

### axios 下的 interceptor.js（axios拦截器-核心1）

```js
/**
 * @author Xin-FAS
 */

import { clearToken, getToken } from '@/utils/handler-token'
import { Message } from 'element-ui'
import { router } from '@/router'

// 请求拦截器
const baseBeforeFilter = req => (req.headers.token = getToken(), req)
// 响应拦截器
const baseAfterFilter = ({
    status,
    statusText,
    data: {
        msg,
        code,
        data
    }
}) => {
    // 浏览器报错
    if (status !== 200) return Promise.reject(statusText || '响应失败')
        .catch(Message.error)
    // 判断token过期
    if (code === -1) {
        clearToken()
        return router.push('/info')
    }
    if (code !== 200) return Promise.reject(msg || '操作失败')
        .catch(err => {
            // 先统一处理一次，传递后续处理
            Message.error(err)
            return Promise.reject(err)
        })
    return data
}

export {
    baseBeforeFilter,
    baseAfterFilter
}
```

### axios 下 instances.js（axios实例-核心2）

```js
import axios from 'axios'
import { baseAfterFilter, baseBeforeFilter } from '@/http/axios/interceptor'

/**
 * @author Xin-FAS
 */
const defaultBaseOptions = {
    timeout: 6000
}
// 创建一个axios请求对象
const createAxiosInstance = (baseOptions, {
    beforeFilter = baseBeforeFilter,
    afterFilter = baseAfterFilter,
} = {}) => {
    const axiosInstance = axios.create(Object.assign({}, defaultBaseOptions, baseOptions))
    axiosInstance.interceptors.request.use(beforeFilter)
    axiosInstance.interceptors.response.use(afterFilter)
    return options => {
        const waitInstance = (resolve, reject = err => err)=> axiosInstance(options).then(resolve, reject)
        // 为请求实例添加mock属性
        waitInstance.mock = (resolve, reject = err => err)=> (targetMockHTTP =>
            Object.prototype.toString.call(targetMockHTTP) === '[object Promise]' || targetMockHTTP(resolve, reject)
        )(MockHTTP(options))
        return waitInstance
    }
}

// mock请求实例
const MockHTTP = createAxiosInstance({ baseURL: '/mock' })
// 基础公共请求实例
const BaseInstance = createAxiosInstance({ baseURL: '/api' })
// 本地资源请求实例
const LocalInstance = createAxiosInstance({ baseURL: '/src/assets' })
// 用户模块
const UserInstance = createAxiosInstance({ baseURL: '/api/user' })

export {
    BaseInstance,
    LocalInstance,
    UserInstance
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

下列中的实例配置同`axios`配置（`axios > apis > xxx.js`）

```js
const DemoAPI = name => BaseInstance({
    url: '/demo',
    params: {
        name
    },
    ...
})
```

页面中使用，例一：

```js
DemoAPI('Xin-FAS')()
```
说明：传入`name`为`Xin-FAS`，返回`/api/demo?name=Xin-FAS`接口数据

例二：

```js
DemoAPI('Xin-FAS').mock()
```

说明：传入`name`为`Xin-FAS`，返回`/mock/demo?name=Xin-FAS`接口数据，mock中拦截返回

其中，以上两个例子，第二个方法中使用如同`promise.then`，可传入两个函数用于处理`then`和`catch`，如下：

```js
DemoAPI('Xin-FAS')(
    ({ data }) => data.filter(v => v),
    // 接口中msg消息，拦截器中的配置 return Promise.reject(err)
    err => Message.error(err)
)
```

其中第二个函数默认值为`err => err`将错误（code值不为指定值）处理了，所以无法继续使用`catch`接收，真要对错误后续处理可在第二个参数中配置：

```js
DemoAPI('Xin-FAS')(0, err => {
    // 错误后续处理
})
```

```js
DemoAPI('Xin-FAS')()
    .then(res => {
        // 正常执行
    })
	.catch(err => {
    	// 永远不会执行到
    })
```

对于使用`await`正常使用

```js
const data = await DemoAPI('Xin-FAS')()
```

`await` 的错误处理同上，存在默认处理，所以永远不会存在业务上的错误（code值不为指定值），真想要自定处理同上

```js
const data = await DemoAPI('Xin-FAS')(0, err => {
    // 错误后续处理
})
```

基于上方演示，自定义的错误处理一般不存在，如真出现这样的需求，请尝试思考从业务逻辑上找问题，使用最多的场景演示如下：

```js
// 数据初次处理/筛选
const filterData = data => ....
// 真实数据
const data = await DemoAPI('Xin-FAS')(filterData)
// 模拟数据
// const mockData = await DemoAPI('Xin-FAS').mock(filterData)
// 使用处理后的data
```

{% note info %}

对于第二个方法的第一个参数，想要跳过的话可以传入一个非函数参数，因为是封装了`promise.then`功能，如同上方代码中的`0`：

```js
(0, err => {
    // 错误后续处理
})
```

解释如下：https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Promise/then#%E5%8F%82%E6%95%B0

{% endnote %}
