---
title: vue2+vue-router3自动注册路由
date: 2023-09-06 22:21:00
tags: [Vue2,JavaScript,VueRouter3]
categories: [前端,Vue]
---

## 介绍

这是一个能够自动注册页面至路由的工具函数，支持

1. 路由嵌套
2. 自定义参数

## 使用

### 引入

把这个函数放入src目录下，在`main.js`处将`router`对象交给这个函数自动注册`src/views-auto`和`src/pages-auto`文件夹下的所有vue文件，配置参数见：[autoRouter API说明](/2023/09/06/vue2-vue-router3自动注册路由/#autoRouter-API说明)

```js
import router from './router'
import Vue from 'vue'
import autoRouter from "@/auto-router"

autoRouter({
    router,
    log: true
})
```

开启`log`后的打印效果：

![image.png](https://s2.loli.net/2023/09/07/JuegMnBWb3wdt7i.png)

### 例一

如下页面中，文件名（`DemoPage2.vue`）：

```html
<script>
export default {
    routerOptions: {
        path: '/demo-page1',
        parentName: 'DemoPage1'
    },
    mounted () {
    }
}
</script>

<template>
    <div>
        这是已注册页面2
    </div>
</template>
<style scoped lang="scss">
</style>
```

自动注册后的路径为`名称为DemoPage1的父路由/demo-page1`，对于这种存在父路由的配置，会自动去除`/`，同时注册后的`name`为`DemoPage2.vue`

### 例二

文件名（`HomeView1.vue`）

```html
<script>
export default {
    routerOptions: {
        name: 'Home1',
        meta: {
            name: '123'
        }
    },
}
</script>

<template>
    <div>
        这是HomeView1
    </div>
</template>
```

自动注册后的路由为`/home-view1`，路由名称为`Home1`（如果不重复的话），同时保留`meta`，其他参数正常使用

### 例三（最简）

就是啥都不写，文件名（`demo-page1.vue`）

```html
<template>
    <div>
        这是已注册页面1
        <router-view />
    </div>
</template>
```

注册后的路径为 `/demo-page1`，路由名称为`DemoPage1`

其他更多见下方文档，[点击查看](/2023/09/06/vue2-vue-router3自动注册路由/#说明文档)

## autoRouter.js

### vue2 + vue-router3 版本

```js
/**
 * @author Xin-FAS
 */

// 日志功能
let log = false
// 获取文件名
const getFileName = (path, suffix = true) => (suffix ?
    /.*[/\\](.*?)$/ :
    /.*[/\\](.*?)\..*?$/).exec('/' + path)?.[1]
// kebab-cased 转 PascalCase
const toPascalCase = str => (
    str = str.trim(),
    str.replaceAll(/(?:^|-)(.)/g, (_, val) => val.toUpperCase())
)
// PascalCase 转 kebab-cased
const toKebabCased = str => (
    str = str.trim(),
    str.replaceAll(/[A-Z]/g, val => `-${val.toLowerCase()}`).slice(1)
)
// 查询是否存在相同name
const hasRouterByName = (router, name) => router.getRoutes().findIndex(v => v.name === name) !== -1
// 查询是否存在相同path
const hasRouterByPath = (router, path, parentName) => {
    const allRoutes = router.getRoutes()
    if (parentName) path = (allRoutes.find(v => v.name === parentName)?.path || '') + '/' + path
    return allRoutes.findIndex(v => v.path === path) !== -1
}
// 根据parentName处理路由配置中的 /
const handlerPathByParentName = options => {
    const { parentName, path } = options
    if (parentName && path[0] === '/')
        options.path = path.replaceAll(/^\/+/g, '')
    if (!parentName && path[0] !== '/')
        options.path = '/' + options.path
    return options
}
// 验证是否已存在name或path
const validRouter = (router, { parentName, ...routerOptions }) => {
    // 判断是否存在path
    if (hasRouterByPath(router, routerOptions.path, parentName)) throw new Error('path已存在：' + JSON.stringify(routerOptions))
    // 判断是否存在name
    if (hasRouterByName(router, routerOptions.name)) throw new Error('name已存在：' + routerOptions.name)
}
// 注册路由
const addRouter = (router, options) => {
    const { parentName, ...routerOptions } = options
    if (parentName) return addChildRouter(router, options)
    validRouter(router, options)
    router.addRoute(routerOptions)
    if (log) console.log('已添加路由：', routerOptions)
}
// 挂起定时器添加子路由
const addChildRouter = (router, options) => {
    const { parentName, ...routerOptions } = options
    let count = 0
    const time = setInterval(() => {
        count++
        // 父路由存在
        if (hasRouterByName(router, parentName)) {
            clearInterval(time)
            validRouter(router, options)
            router.addRoute(parentName, routerOptions)
            if (log) console.log(`已为 ${parentName} 添加子路由`, routerOptions)
        }
        // 最多等待2500ms
        if (count >= 50) {
            clearInterval(time)
            throw new Error('路由添加失败：' + JSON.stringify(options))
        }

    }, 50)
}

// 默认注册路径
let defaultRequireList = []
try {
    defaultRequireList.push(require.context('./views-auto', true, /\.vue$/))
} catch (e) {}
try {
    defaultRequireList.push(require.context('./pages-auto', true, /\.vue$/))
} catch (e) {}

const autoRouter = ({
    router,
    requireList = defaultRequireList,
    log: setLog
}) => {
    // 默认路径不存在或无指定路径
    if (!requireList.length) return
    log = setLog
    requireList.forEach(requireContext => {
        requireContext.keys().forEach(relativeComPath => {
            // 组件内容
            const component = requireContext(relativeComPath).default
            // 组件名
            const componentsName = toPascalCase(getFileName(relativeComPath, false))
            // 默认路由配置，path = 烤串命名的组件名（为子路由则去除 /），name = 大驼峰命名的组件名
            const defaultRouterOptions = {
                path: toKebabCased(componentsName),
                name: componentsName,
                component
            }
            // 混合页面自定义路由配置
            const routerOptions = Object.assign(
                defaultRouterOptions,
                // 检查渲染路由path
                component?.routerOptions
            )
            addRouter(router, handlerPathByParentName(routerOptions))
        })
    })
}

export default autoRouter
```

## 说明文档

自动注册规则：

1. 使用时自动添加`./views-auto`和`./pages-auto`两个路径，因为只能使用相对路径，建议将`auto-router.js`放入`src`目录中，也就是自动注册`src/views-auto`和`src/pages-auto`下的所有vue文件（不论深度），配置更多路径可自定，见下方`autoRouter`参数说明
2. 自动注册时，在`vue`文件中可添加`routerOptions`对象，见下方`routerOptions`参数说明

### autoRouter API说明

| 参数        | 说明                                                         |
| ----------- | ------------------------------------------------------------ |
| router      | router 对象                                                  |
| log         | 是否开启注册时打印                                           |
| requireList | 自定义文件夹列表，默认 `[require.context('./views-auto', true, /\.vue$/), require.context('./pages-auto', true, /\.vue$/)]`，相对目录下的`./view-auto`和`./pages-auto`两个文件夹 |

代码演示：

```js
autoRouter({
    router,
    log: false,
    requireList: [require.context('./vue-auto', true, /\.vue$/)]
})
```

### routerOptions API说明

在vue页面中可配置：

```html
<script>
export default {
    routerOptions: {
        ...
    },
}
</script>

<template>
    <div>
        测试页面
    </div>
</template>
```

改动参数：

| 参数         | 说明                                                         | 默认值                                      |
| ------------ | ------------------------------------------------------------ | ------------------------------------------- |
| path         | 路由注册地址，会自动处理`/`，所以`/demo`等于`demo`，重复会出现`Error`提示 | `kebab-cased`命名下的文件名，如`demo-page1` |
| name         | 路由注册名称，有路由name重复时会出现`Error`提示              | `PascalCase`命名下的文件名，如：`DemoPage1` |
| routerParent | 父路由名称，父路由页面别忘了写`router-view`                  | 无                                          |

除了上面三个有改动的参数外，其他用法不变，如`redirect`，`meta`，都可以自定义
