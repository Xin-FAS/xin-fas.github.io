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
const getType = val => Object.prototype.toString.call(val)
// 创建一个axios请求对象
const createAxiosInstance = (baseOptions, {
    beforeFilter = baseBeforeFilter,
    afterFilter = baseAfterFilter
} = {}) => {
    const axiosInstance = axios.create(Object.assign({}, defaultBaseOptions, baseOptions))
    axiosInstance.interceptors.request.use(beforeFilter)
    axiosInstance.interceptors.response.use(afterFilter)
    return options => {
        const waitInstance = instanceOptions => {
            if (getType(instanceOptions) === '[object Function]')
                return axiosInstance(options)
                    .then(res => instanceOptions(res), void 0)
            const {
                success = e => e,
                error,
                before = () => {},
                after
            } = instanceOptions
            before()
            return axiosInstance(options)
                .then(res => success(res), error)
                .finally(after)
        }
        // 为请求实例添加mock属性
        waitInstance.mock = ({
            success,
            error,
            before = () => {
            },
            after
        } = {}) => (
            // 判断是否为mock实例
            targetMockHTTP => getType(targetMockHTTP) === '[object Promise]' ||
                (
                    before(),
                    targetMockHTTP({
                        success,
                        error,
                        before,
                        after
                    })
                )
        )(MockHTTP(options))
        return waitInstance
    }
}
// mock请求实例（mock实例必须第一个初始化，因为后续要添加这个实例）
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
    UserInstance,
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

## 使用介绍

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
说明：传入`name`为`Xin-FAS`，返回请求`/api/demo?name=Xin-FAS`接口后的`Promise`对象

例二：

```js
DemoAPI('Xin-FAS').mock()
```

说明：传入`name`为`Xin-FAS`，返回请求`/mock/demo?name=Xin-FAS`接口后的`Promise`对象（mock中需要写好拦截）以上两个例子，第二个方法中可传入一个对象，对象参数如下：

```js
DemoAPI('Xin-FAS')({
    success (data) {
    	// 业务请求成功后
    },
    error (msg) {
        // 业务请求失败后
    },
    before () {
        // 请求之前
    },
    after () {
        // 请求之后（无论失败还是成功）
    }
})
```

{% note warning %}

在回调函数中使用普通函数存在`this`指向问题，`this`并不指向当前`vue`实例，所以要使用`this`需要使用箭头函数，如下写法：

```js
DemoAPI('Xin-FAS')({
    success: data => {
    	this.tableData = data
    	// ...
    },
    before: () => this.loading = true,
    after: () => this.loading = false
})
```

{% endnote %}

`success`回调就相当于`promise.then`，`error`回调就相当于`promise.error`，不使用回调形式则返回为`promise`对象，如下

```js
const data = DemoAPI('Xin-FAS')()
// data -> promise
data.then(data => {
    
})
```

但是对于错误处理，直接使用`catch`是无效的，因为默认的`error`回调默认值为`err => err`（上方代码中为空，但是对于`catch`为空则默认 `e => e`）

```js
DemoAPI('Xin-FAS')()
    .then(res => {
        // 正常执行
    })
	.catch(err => {
    	// 永远不会执行到
    })
```

发生业务后的错误处理需要写在`error`回调中

当只需要使用成功回调时，就不需要写对象了，直接写一个函数，作用相同，算是`success`简写形式

```js
DemoAPI('Xin-FAS')({
    success: data => {
    	this.tableData = data
    	// ...
    },
})

// 简写为
DemoAPI('Xin-FAS')(data => {
    this.tableData = data
    // ...
})
```



`await`演示如下

```js
const data = await DemoAPI('Xin-FAS')()
```

```js
const data = await DemoAPI('Xin-FAS')({
    error () {
        // 错误后续处理
    }
})
```

当出现`await`和回调一起使用时

```js
const data = await DemoAPI('Xin-FAS')({
    success (data) {
    	console.log(data) // 正常输出
    }
})
console.log(data) // undefined
```

这是因为`success`中同`then`，需要返回后才能被后续接受

```js
const data = await DemoAPI('Xin-FAS')({
    success (data) {
    	console.log(data) // 正常输出
		return data
    }
})
console.log(data) // 正常输出
```

```js
const data = DemoAPI('Xin-FAS')({
    success (data) {
    	console.log(data) // 正常输出
		return data
    }
})
data.then(res => {
    console.log(res) // 正常输出
})
```

{% note info %}

封装代码中使用了`then`或`catch`为空的情况（当参数不为函数时，自动转为`e => e`），解释如下：https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Promise/then#%E5%8F%82%E6%95%B0

{% endnote %}
