---
title: vue2+vue-router3自动注册路由
date: 2023-09-06 22:21:00
tags: [Vue2,JavaScript,VueRouter3]
categories: [前端,Vue]
---

## 介绍

这是一个能够自动注册页面至路由的工具函数，支持路由嵌套，自定义页面参数等

## 使用

待写

## autoRouter.js（待写）

```js
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

// 默认注册路径
let defaultRequireList = []
try {
    defaultRequireList.push(require.context('../views-auto', true, /\.vue$/))
} catch (e) {}
try {
    defaultRequireList.push(require.context('../pages-auto', true, /\.vue$/))
} catch (e) {}

const autoRouter = (router, requireList = defaultRequireList) => {
    // 默认路径不存在或无指定路径
    if (!requireList.length) return
    requireList.forEach(requireContext => {
        requireContext.keys().forEach(relativeComPath => {
            // 组件参数
            const componentContext = requireContext(relativeComPath).default
            // 组件名
            const componentsName = toPascalCase(getFileName(relativeComPath, false))
            // 路由name
            const routerName = toKebabCased(componentsName)
            // 页面自定义路由参数
            const componentRouterOptions = componentContext?.routerOptions || {}
            // TODO 待写
        })
    })
}

export default autoRouter
```
