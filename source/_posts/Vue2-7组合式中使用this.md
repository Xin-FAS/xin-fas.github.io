---
title: Vue2.7组合式中使用this
date: 2023-09-04 21:54:07
tags: [Vue2, JavaScript]
---

## 介绍

这是一个非常不合理的需求，请谨慎观看。。

能在`setup`的作用域下，在函数内容使用`this`

## 使用

`main.js`中引入

```js
import './setThis'
```

使用`this()`方法

```html
<script setup>

const toMainPage = function () {
    this.$router.push('/main')
}.this()
</script>

<template>
    <div>
        <button @click="toMainPage">跳转</button>
    </div>
</template>
```

这个函数不能是箭头函数，因为这种方法采用修改`this`指向实现

> 关于`vue2.7`组合式中使用`router@3`的功能，第二个方法：[查看](/2023/09/04/Vue2-7组合式中使用router3/)

## setThis.js

```js
import { getCurrentInstance } from 'vue';

Function.prototype.this = function () {
    return this.bind(getCurrentInstance().proxy)
}
```

就是为函数原型添加了一个`this`方法，内容就是通过使用`bind`改变`this`指向后返回新的函数

## 更多问题

就是关于`getCurrentInstance`的使用性，详见：[查看](/2023/09/04/Vue2-7组合式中使用router3/#更多问题)
