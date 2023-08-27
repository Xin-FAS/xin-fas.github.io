---
title: js中深入了解this指向
date: 2022-07-12 14:08:27
tags: [JavaScript]
categories: [前端,前端其他]
---
## 普通函数中的this

我们都知道在普通的函数（使用`function`关键字定义）中，`this`的指的是它所属的对象

但它拥有不同的值，分以下情况决定：

1. 在方法中，`this`指的是所有者对象
2. 单独的情况下，`this`指的是全局对象
3. 在函数中，`this`指的是全局对象
4. 在函数中，严格模式（`"use strict";`）下，`this`是`undefined`
5. 在事件中，`this`指的是接收事件的元素

## 箭头函数中的this

在es6的箭头函数中的this指向是全局对象（window），也就是说无论在哪个对象中都可以指向全局，但是在es6的类中指向是类的实例对象（因为在类的原型链上）

## 详细区别（type="text/javascript"）

使用this作为当前标签的dom对象传递就不展示了

### 简单使用

```js
function demo1() {
    console.log('普通函数中的this：', this) // Window对象
}

demo1()

const demo2 = () => {
    console.log('箭头函数中的this：', this) // Window对象
}
demo2()
```

### 在对象中使用

```js
const obj = {
    name: 'FSAN',
    demo1: function () {
        console.log('在obj对象普通函数中的this：', this) // obj对象
    },
    demo2: () => {
        console.log('在obj对象箭头函数中的this：', this) // Window对象
    }
}
obj.demo1()
obj.demo2()
```

### 在类中使用

```js
class C1 {
    name = 'FSAN'
    // 简写形式
    demo1() {
        console.log('类的普通方法中的this：', this) // 类的实例对象
    }
    demo2 = function () {
        console.log('类的普通方法中的this：', this) // 类的实例对象
    }
    demo3 = () => {
        console.log('类的箭头函数中的this：', this) // 类的实例对象
    }
}
const c1 = new C1()
c1.demo1()
c2.demo2()
c2.demo3()
```

> 可以发现在类中使用哪种方法定义方法对this的指向都没有影响

### 手动严格模式

```js
"use strict";
```

加上这段之后，会改变简单使用中使用function定义的方法中的this指向

```js
function demo1() {
    "use strict";
    console.log('严格模式下普通函数中的this：', this) // undefined
}
```

对其他方法没有影响

## 详细区别（type=“text/babel”）

将js代码通过babel转换，先导入

```js
<script src="https://unpkg.com/babel-standalone@6.15.0/babel.min.js"></script>
```

### 简单使用

```js
function demo1() {
    console.log('babel编译后：普通函数下的this：', this) // undefined
}

demo1()
const demo2 = () => {
    console.log('babel编译后：箭头函数下的this：', this) // undefined
}
demo2()
```

查看转换后源码，分析：

```js
"use strict";

function demo1() {
  console.log('babel编译后：普通函数下的this：', this); // undefined
}

demo1();

const demo2 = () => {
  console.log('babel编译后：箭头函数下的this：', void 0); // undefined
};

demo2();
```

> 转换后，会默认转换为严格模式（对简单定义的普通函数有影响，但是手写严格模式对this没有影响），但是！这里转换后将箭头函数中的this改成了void 0

### 在对象中使用

```js
const obj = {
    name: 'FSAN',
    demo1: function () {
        console.log('babel编译后：obj对象普通函数中的this：', this) // obj对象
    },
    demo2: () => {
        console.log('babel编译后：obj对象箭头函数中的this：', this) // undefined
    }
}
obj.demo1()
obj.demo2()
```

### 在类中使用

#### 由实例对象调用

```js
class C1 {
    name = 'FSAN'

    demo1() {
        console.log('babel编译后：类中普通函数的this：', this) // 类的实例对象
    }

    demo2 = () => {
        console.log('babel编译后：类中箭头函数的this：', this) // 类的实例对象
    }
}

const c1 = new C1()
c1.demo1()
c1.demo2()
```

#### 由其他引用地址调用

```js
class C1 {
    name = 'FSAN'

    demo1() {
        console.log('babel编译后：类中普通函数的this：', this) // 类的实例对象
    }

    demo2() {
        console.log('babel编译后：类中箭头函数的this：', this) // undefined
    }
}

const c1 = new C1()
const demo2 = c1.demo
demo2()
```

要想让`demo2`中的`this`正确指向类的实例对象，只需要让`demo2`使用箭头函数即可

## 总结

1. 在类中构造器的`this`，一定指向类的实例对象
2. 类中的方法由实例对象调用，其中的`this`才是实例对象
3. 使用`babel`转换时，默认使用严格模式会将除了类之外的箭头函数中的this转换为`void 0`（这就是使用babel后，函数中拿到`this`为`undefined`的原因）
