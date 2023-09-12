---
title: Vue2.7组合式中使用router3
date: 2023-09-04 21:17:09
tags: [Vue2, JavaScript, VueRouter3]
categories: [前端, Vue]
---

## 介绍

众嗦粥汁，在`setup`的组合式语法中，`this`是无法获取当前`Vue`实例的，所以这在`Vue2.7`项目中使用`vue-router@3`就成为了困难，如下：

```html
<script setup>
// 无效
console.log(this.$router, this.$route)
</script>
```

那`vue-router@3`版本又不支持`hook`，所以可以手动封装一个，先看使用：

```html
<script setup>
import { useRouter, useRoute } from "@/views/routerHook"

const router = useRouter()
const route = useRoute()

// 以下正常使用
console.log(router, route)
</script>
```

这让`router3`封装后可以更加贴合`router4`在`setup`中的使用，只需要跳转时，这种方法并不推荐，更推荐直接引入使用

```js
<script setup>
import router from '@/router'

const toLogin = () => {
    router.push('/login')
}
</script>
```

## routerHook.js

```js
import { getCurrentInstance } from 'vue'

// 获取当前实例，如果不存在则报错
const getInstance = () => {
    const vm = getCurrentInstance()
    if (!vm) throw new Error('只能在setup中使用！')
    return vm
}
// 访问router
export const useRouter = () => getInstance().proxy.$router
// 访问route
export const useRoute = () => getInstance().proxy.$route

```

> `export const route => getInstance().proxy.$route` 这样会导致获取不到实例，必须要在`setup`中调用

## 更多问题

{% note warning %}

`getCurrentInstance` 主要用于需要额外内部访问的官方 vue 库，而不是用于用户态应用程序代码。它被错误地记录在 WIP v3 文档中，但不再被视为公共 API。

`getCurrentInstance()`最初[记录于 2020 年 10 月 4 日](https://github.com/vuejs/docs/pull/590)，但后来在 Vue 的创建者（Evan You）对 Composition API 文档的重大重构中于[2021 年 8 月 31 日删除了该内容。](https://github.com/vuejs/docs/commit/1ea66dc0e67abe5c518d487218bb7e2d6a5c5324)尽管它从文档中删除，`getCurrentInstance()`但仍然：

- [广泛应用于Vue核心](https://github.com/vuejs/core/search?q=getCurrentInstance)。
- [未在代码中记录为已弃用](https://github.com/vuejs/core/blob/d52907f/packages/runtime-core/src/component.ts#L561)。
- [作为高级 API 的一部分导出](https://github.com/vuejs/core/blob/9c304bfe7942a20264235865b4bb5f6e53fdee0d/packages/runtime-core/src/index.ts#L78-L82)。

鉴于它是一个未记录的内部 API，请谨慎使用。

{% endnote %}
