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
 * @param options hammerjs的其他配置，见官网
 */
const signInHammer = (el, key, cb, options = {}) => {
    const hammer = new Hammer(el);
    hammer.on(key, cb);
    // 需要特殊处理的事件
    const eventHandlerMap = {
        setSwipe () {
            hammer.get('swipe').set({
                direction: Hammer.DIRECTION_VERTICAL,
                ...options
            })
        },
        setPinch () {
            hammer.get('pinch').set({
                enable: true,
                ...options
            })
        },
        setRotate () {
            hammer.get('rotate').set({
                enable: true,
                ...options
            })
        },
        setPan () {
            hammer.get('pan').set({
                direction: Hammer.DIRECTION_ALL,
                ...options
            })
        }
    }

    // 监听垂直方向需要配置下
    if (key === 'swipeup' || key === 'swipedown') return eventHandlerMap.setSwipe()
    // 捏合和旋转识别器处于禁用状态，开启
    if (key === 'pinch') return eventHandlerMap.setPinch()
    if (key === 'rotate') return eventHandlerMap.setRotate()
    // pan 事件监听方向
    if (key === 'pan') return eventHandlerMap.setPan()
    // 其他事件可以配置的情况下使用配置
    hammer.get(key)?.set(options)
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
                String: (value, options) => {
                    // 防止事件名输错
                    if (!(value in vueInstance)) throw new Error('不存在当前名称事件：' + value)
                    signInHammer(el, key, vueInstance[value], options)
                },
                Function: (value, options) => signInHammer(el, key, value, options),
                Object: () => {
                    // 使用handler属性注册
                    if (!('handler' in value)) throw new Error('未指定处理事件！')
                    const handlerType = getTypeof(value.handler)
                    if (handlerType in handler) handler[handlerType](value.handler, value.options)
                }
            }
            if (valueTypeof in handler) handler[valueTypeof](value)
            // 其他类型提示绑定失败
            else throw new Error('hammer指令配置类型错误！')
        }
    }
}

export default hammer

```

### Vue3 版本

vue3 版本区别就是在指令的事件名称从`bind`改为了`mounted`，其他没变

```js
...
const hammer = {
    mounted (el, binding, vNode) {
        // 遍历修饰符，添加对应事件
...
```

## 使用介绍

引入后注册为指令（以`Vue3`为例）

```js
import App from './App.vue'
import hammerDirective from "@/hammer-directive"

const app = createApp(App)
app.directive('hammer', hammerDirective)
```

在监听标签上使用

```html
<script setup>
import { reactive } from "vue"
    
const swipeupRemote = () => {
    console.log('向上滑')
}
const swipedown = () => {
    console.log('向下滑')
}
const press = () => {
    console.log('长按2s')
}
const hammerOptions = reactive({
    swipeup: swipeupRemote,
    swipedown,
    press: {
        handler: press,
        options: {
            time: 2000
        }
    }
})
</script>

<template>
    <div
        class="demo"
        v-hammer="hammerOptions"
    />
</template>

<style scoped lang="scss">
.demo {
    width: 400px;
    height: 400px;
    background: sandybrown;
}
</style>

```

可监听事件见hammerjs官网文档，指令的类型如下：

```ts
type eventType = string | Function
type eventHandler = {
    handler: eventType,
    options?: Object
}
interface vHammer {
    [key: string]: eventType | eventHandler,
}
```

当事件名为字符串时，将自动去当前实例找事件，未找到则会出现Error提示
