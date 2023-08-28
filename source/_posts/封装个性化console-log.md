---
title: 封装个性化console.log
date: 2023-08-27 22:13:37
tags: [JavaScript]
categories: [前端,前端其他]
---

## console.log样式介绍

当`console.log`的第一个参数中存在`%c`时，将会对应使用第一个参数后的样式，如下：

```js
console.log('%c测试一', 'color: red')
```

这样就能改变`测试一`的文字颜色，多个样式如下

```js
console.log('%c测试一%c测试二', 'color: red', 'color: blur')
```

只要写多个对应数量的`%c`就可以了

> 更多介绍MDN：https://developer.mozilla.org/en-US/docs/Web/API/Console/log

## 封装需求

1. 能自动合并指定时间内的相同打印内容
2. 以`key - value`的形式打印

## 效果展示

<iframe src="/iframe/个性化打印演示.html" width='100%' height='70px'></iframe>

```html
<script>
import { initLog } from "./f-log";
    
export default {
    methods: {
        printFLog: initLog()
    }
}
</script>

<template>
    <div>
        <p>请打开控制台查看</p>
        <button @click="printFLog('测试标题', '这是一段测试内容')">点击打印</button>
    </div>
</template>

```

`initLog`中还可以传入一个`对象`，可以包含以下参数：

 * titleStyle：标题（key）的样式
 * contentStyle：内容（value）的样式
 * countStyle：统计（count）的样式
 * delay：多久后清除合并统计，默认500毫秒，为`-1`表示不清除

其中，样式的key值可以用小驼峰编写，如下：

```js
export default {
    methods: {
        printFLog: initLog({
            titleStyle: {
                backgroundColor: 'red',
                fontWeight: 'bold'
            },
            delay: -1
        })
    }
}
```

## f-log.js

```js
/**
 * @author Xin-FAS
 */

// 如果样式名为驼峰，则转为中划线
const handlerStyleKey = key => key.replaceAll(/[A-Z]/g, (val, index) => index === '0' ? val : '-' + val.toLowerCase())
// 将对象style转为字符串style
const getStyleStrByObj = obj => Object.entries(obj).reduce((result, [ key, item ]) => result += `${handlerStyleKey(key)}: ${item};`, '')
// 默认样式
const defaultStyle = {
    titleStyle: {
        padding: '3px',
        color: 'white',
        backgroundColor: '#35495e',
        fontSize: '12px',
        borderRadius: '4px 0 0 4px',
        paddingLeft: '13px'
    },
    contentStyle: {
        padding: '3px',
        color: 'white',
        backgroundColor: '#28518a',
        fontSize: '12px',
        borderRadius: '0 4px 4px 0',
        paddingRight: '13px'
    },
    countStyle: {
        padding: '3px',
        color: 'white',
        backgroundColor: 'green',
        fontSize: '12px',
        borderRadius: '4px',
        marginLeft: '5px',
        textAlign: 'center'
    }
}
/**
 * 初始化打印
 * @param titleStyle 标题（key）的样式
 * @param contentStyle 内容（value）的样式
 * @param countStyle 统计（count）的样式
 * @param delay 多久时间内的相同内容会被合并，默认500毫秒
 * @returns {(function(*, *): void)|*}
 */
const initLog = ({
    titleStyle,
    contentStyle,
    countStyle,
    delay = 500
} = {}) => {
    const map = new Map();
    let time
    // 使用自己的样式打印
    const printTemplate = (title, value, logCount = 1) => console.log(
        `%c${title}：%c${value}%c` + (logCount === 1 ? '': `×${logCount}`),
        getStyleStrByObj(Object.assign(defaultStyle.titleStyle, titleStyle)),
        getStyleStrByObj(Object.assign(defaultStyle.contentStyle, contentStyle)),
        getStyleStrByObj(Object.assign(defaultStyle.countStyle, countStyle))
    )
    return (title, value) => {
        // 生成唯一的key准备存入map计算次数
        const key = JSON.stringify({
            title,
            value
        })
        let newCount = 1
        // 如果map中已存在这个key，说明之前打印过了，累加
        if (map.has(key)) newCount = map.get(key) + 1
        map.set(key, newCount)
        // 打印出map中统计好的数据
        printTemplate(title, value, newCount)
        // 定时重置，为 -1 则不重置
        if (delay === -1) return
        setTimeout(() => map.delete(key), delay)
    }
}

export { initLog }
```
