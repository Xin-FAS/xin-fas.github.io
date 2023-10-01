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
        const waitInstance = (instanceOptions = {}) => {
            if (getType(instanceOptions) === '[object Function]')
                return axiosInstance(options)
                    .then(instanceOptions, e => e)
            const {
                success,
                error = e => e,
                before = () => {},
                after
            } = instanceOptions
            before()
            return axiosInstance(options)
                .then(success, error)
                .finally(after)
        }
        // 为请求实例添加mock属性
        waitInstance.mock = ({
            success,
            error,
            before,
            after
        } = {}) => (
            // 判断是否为mock实例
            targetMockHTTP => getType(targetMockHTTP) === '[object Promise]' ||
                targetMockHTTP({
                    success,
                    error,
                    before,
                    after
                })
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

### 基础使用

此时有如 api 如：`/api/demo`，先定义接口方法（`axios > apis > xxx.js`）

```js
const DemoAPI = name => BaseInstance({
    url: '/demo',
    params: {
        name
    },
    ...
})
```

发出请求（真实地址：`/api/demo?name=Xin-FAS`）

```js
DemoAPI('Xin-FAS')()
```
返回的是正常的`Promise`对象，后续可以正常使用`then`或`await`，但是不能使用`catch`去处理后续错误，理由在下面

发出使用mock的拦截请求（真实地址：`/mock/demo?name=Xin-FAS`）

```js
DemoAPI('Xin-FAS').mock()
```

几个内置的生命周期

```js
DemoAPI('Xin-FAS')({
    success (data) {
    	// 业务请求成功后，同Promise.success
    },
    error (msg) {
        // 业务请求失败后，同Promise.catch
    },
    before () {
        // 请求之前
    },
    after () {
        // 请求之后（无论失败还是成功），同Promise.finally
    }
})
```

### 关于业务上的错误后续处理

不能使用`catch`处理错误的原因在于，已经内置了错误处理，就算是`DemoAPI('Xin-FAS')()`直接使用也不会出现错误拦截，内置默认为`.catch(e => e)`，所以要进行错误的后续操作需要写在`error`中

```js
DemoAPI('Xin-FAS')()
    .then(res => {
        // 正常执行
    })
	.catch(err => {
    	// 永远不会执行到
    })
```

正确使用：

```js
DemoAPI('Xin-FAS')({
    error: msg => {
        // ...
    },
})
```

### this 指向问题

在回调函数中使用普通函数存在`this`指向问题，`this`并不指向当前`vue`实例，所以要使用`this`需要使用箭头函数，如下写法：

```js
// 错误写法
DemoAPI('Xin-FAS')({
    success (data) {
    	this.tableData = data
    	// ...
    },
    before () { this.loading = true },
    after () { this.loading = false }
})
// 正确写法
DemoAPI('Xin-FAS')({
    success: data => {
    	this.tableData = data
    	// ...
    },
    before: () => this.loading = true,
    after: () => this.loading = false
})
```

### 简写形式

当只需要使用到成功处理时，如获取字典列表，可以在第二个方法中直接写一个函数：

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

### await 使用演示

因为返回的是`promise`对象，所以`await`正常使用

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

封装代码中使用了`then`或`finally`为空的情况（当参数不为函数时，自动转为`e => e`），解释如下：https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Promise/then#%E5%8F%82%E6%95%B0

{% endnote %}
