---
title: 将Hammer封装为指令使用
date: 2023-08-18 22:33:23
tags: [Vue2, Vue3, JavaScript, TypeScript]
categories: [前端]
---

## Hammer.js

简单介绍：监听手势触发（上下滑动，左右滑动，长按等）

官网文档：https://hammerjs.github.io/getting-started/

## 封装为指令使用（hammer-directive）

使用前记得先安装

```bash
npm i hammerjs
```

### Vue2 版本

```js
import Hammer from 'hammerjs'

// 获取变量类型
const getTypeof = value => Object.prototype.toString.call(value).slice(0, -1).split(' ')[1];
/**
 * 注册hammer事件
 * @param el 注册对象
 * @param key 事件名称
 * @param cb 回调函数
 */
const signInHammer = (el, key, cb) => {
    const hammer = new Hammer(el);
    hammer.on(key, cb);
    if (key === 'swipeup' || key === 'swipedown') hammer.get('swipe').set({ direction: Hammer.DIRECTION_VERTICAL });
}

const hammer = {
    bind(el, binding, vNode) {
        // 遍历修饰符，添加对应事件
        const eventMap = binding.value;
        // 获取当前实例
        const vueInstance = vNode.context;
        for (const key in eventMap) {
            // 绑定目标
            const value = eventMap[key];
            // 目标类型
            const valueTypeof = getTypeof(value)
            const handler = {
                String: () => signInHammer(el, key, vueInstance[value]),
                Function: () => signInHammer(el, key, value)
            }
            if (valueTypeof in handler) handler[valueTypeof]()
            // 其他类型提示绑定失败
            else throw new Error('hammer指令绑定事件不存在！')
        }
    }
}

export default hammer
```

### Vue3 版本



## 使用介绍

引入后注册为指令

```js
import Vue from 'vue'
import hammerDirective from './hammer-directive'

Vue.directive('hammer', hammerDirective)
```

在监听标签上使用（以vue2为例）

```html
<script>
export default {
    methods: {
        swipedown () {
            console.log('向下滑');
        },
        swipeupRemote () {
            console.log('向上滑')
        }
    }
}
</script>

<template>
    <div class="demo" v-hammer="{
        swipedown,
        swipeup: swipeupRemote
    }" />
</template>

<style lang="scss" scoped>
.demo {
    width: 400px;
    height: 400px;
    background: sandybrown;
}
</style>
```

指令传递参数见hammerjs文档中的事件

## 0818版本不完善，待补全
