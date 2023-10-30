---
title: 分析v-clickoutside源码
date: 2023-10-30 16:35:30
tags: [JavaScript]
categories: [前端,Vue]
---

## 如何调试源码

先创建一个`vue2`的项目，对于直接修改使用npm下载的依赖包中的源码代码进行调试是不行的，因为项目中使用的是编译后的element组件代码，也就是`lib`文件夹下的代码

![Snipaste_2023-09-17_21-37-44.png](https://s2.loli.net/2023/09/17/8z1bothTEuZAsmr.png)

所以正确的调试步骤如下：

1. 进入项目文件夹中拉取`element-ui`源码，`git clone https://github.com/ElemeFE/element.git`
2. 到源码的文件夹中，使用`npm i`完成依赖下载
3. 开始调试/修改代码，最后使用`npm run dist`打包，看到源码文件夹中生成`lib`文件夹即可
4. 在新项目中使用`npm i element-ui -S ./element`，第二个`element`就是第一步拉取的源码文件夹

{% note warning %}

对于上面第二点的提示：高版本node会报错，建议使用`12.22.12`。其他的小报错没有关系，后续能正常使用就行

{% endnote %}

当正确使用本地的源码后，可以在`package.json`中查看到`element-ui`指向为本地源码的文件夹，如下：

![image.png](https://s2.loli.net/2023/10/30/WbXpkqTVmxfna76.png)

后续的更改就只需要修改源码文件夹中的代码，然后`npm run dist`打包即可

## v-clickoutside源码

在源码文件夹下 `/src/utils/clickoutside.js`

```js
import Vue from 'vue';
import { on } from 'element-ui/src/utils/dom';

const nodeList = [];
const ctx = '@@clickoutsideContext';

let startClick;
let seed = 0;

!Vue.prototype.$isServer && on(document, 'mousedown', e => (startClick = e));

!Vue.prototype.$isServer && on(document, 'mouseup', e => {
  nodeList.forEach(node => node[ctx].documentHandler(e, startClick));
});

function createDocumentHandler(el, binding, vnode) {
  return function(mouseup = {}, mousedown = {}) {
    if (!vnode ||
      !vnode.context ||
      !mouseup.target ||
      !mousedown.target ||
      el.contains(mouseup.target) ||
      el.contains(mousedown.target) ||
      el === mouseup.target ||
      (vnode.context.popperElm &&
      (vnode.context.popperElm.contains(mouseup.target) ||
      vnode.context.popperElm.contains(mousedown.target)))) return;

    if (binding.expression &&
      el[ctx].methodName &&
      vnode.context[el[ctx].methodName]) {
      vnode.context[el[ctx].methodName]();
    } else {
      el[ctx].bindingFn && el[ctx].bindingFn();
    }
  };
}

/**
 * v-clickoutside
 * @desc 点击元素外面才会触发的事件
 * @example
 * ```vue
 * <div v-element-clickoutside="handleClose">
 * ```
 */
export default {
  bind(el, binding, vnode) {
    nodeList.push(el);
    const id = seed++;
    el[ctx] = {
      id,
      documentHandler: createDocumentHandler(el, binding, vnode),
      methodName: binding.expression,
      bindingFn: binding.value
    };
  },

  update(el, binding, vnode) {
    el[ctx].documentHandler = createDocumentHandler(el, binding, vnode);
    el[ctx].methodName = binding.expression;
    el[ctx].bindingFn = binding.value;
  },

  unbind(el) {
    let len = nodeList.length;

    for (let i = 0; i < len; i++) {
      if (nodeList[i][ctx].id === el[ctx].id) {
        nodeList.splice(i, 1);
        break;
      }
    }
    delete el[ctx];
  }
};
```

## on方法

先看源码中引入的`on`方法的源码

```js
import { on } from 'element-ui/src/utils/dom';
```

```js
/* istanbul ignore next */
export const on = (function() {
  if (!isServer && document.addEventListener) {
    return function(element, event, handler) {
      if (element && event && handler) {
        element.addEventListener(event, handler, false);
      }
    };
  } else {
    return function(element, event, handler) {
      if (element && event && handler) {
        element.attachEvent('on' + event, handler);
      }
    };
  }
})();
```

可以看到这是一个立即执行函数，里面存在变量`isServer`，是否为服务端，可以视为`false`（具体见下面补充）

> 补充`isServer`：Vue.js 是一个用于构建客户端应用的框架，这个属性通常用于在服务端渲染（SSR）时区分客户端和服务端环境。我们并不使用SSR，所以可以视为`false`

只要正常存在`document.addEventListener`，就返回一个方法，这个方法接受三个参数（节点对象，事件名，处理方法），可为对应元素使用`addEventListener`建立监听事件

> 关于`document.addEventListener`第三个参数
>
> 详情介绍：https://developer.mozilla.org/zh-CN/docs/Web/API/EventTarget/addEventListener
>
> 别人的实例：https://blog.csdn.net/SunDaDa9/article/details/103693062

那么不存在`document.addEventListener`时呢，也是返回一个作用和参数一样的方法，只不过为了兼容`IE`把`addEventListener`换成了`attachEvent`  

> 补充：`addEventListener`为`W3C`标准，除`IE`浏览器使用，而`attachEvent`只能在`IE`浏览器上使用，语法：`Element.attachEvent(Etype,EventName)`，事件名前加`on`，如`onclick`

{% note info %}

总结：`on`函数就是用于注册事件，可以兼容`IE`，以后要使用就可以直接引入使用了，使用如下：

```js
on(document, 'mousedown', e => startClick = e)
```

{% endnote %}

## 继续分析（分段一）

```js
const nodeList = [];
const ctx = '@@clickoutsideContext';

let startClick;
let seed = 0;
```

这四个参数，目前不知道干啥的，见名字

1. `nodeList`：存放node节点
2. `ctx`：某个唯一参数
3. `startClick`：开始点击？
4. `seed`：名次？起源？后代？

没关系，我们后续再确认

## 继续分析（分段二）

```js
!Vue.prototype.$isServer && on(document, 'mousedown', e => (startClick = e));

!Vue.prototype.$isServer && on(document, 'mouseup', e => {
  nodeList.forEach(node => node[ctx].documentHandler(e, startClick));
});
```

一点一点看：

```js
!Vue.prototype.$isServer // 客户端时为true

on(document, 'mousedown', e => (startClick = e)) // 注册一个鼠标按下事件

on(document, 'mouseup', e => {
  nodeList.forEach(node => node[ctx].documentHandler(e, startClick));
}) // 注册一个鼠标松开事件
```

> `mousedown`：https://developer.mozilla.org/zh-CN/docs/Web/API/Element/mousedown_event
>
> `mouseup`：https://developer.mozilla.org/zh-CN/docs/Web/API/Element/mouseup_event

事件内容先不看，先记住有这两个事件，鼠标按下和鼠标松开

## 继续分析（分段三）

```js
bind(el, binding, vnode) {
  nodeList.push(el);
  const id = seed++;
  el[ctx] = {
    id,
    documentHandler: createDocumentHandler(el, binding, vnode),
    methodName: binding.expression,
    bindingFn: binding.value
  };
},
```

首先，把使用指令的元素都添加到了`nodeList`数组中，然后将`seed`的值赋值给了`id`，然后自增，所以就推测出了分段一中`seed`这个属性的作用，就是让每个元素有一个唯一值。

然后，使用这个`createDocumentHandler`方法创建出`documentHandler`属性，下面我们分析`createDocumentHandler`方法，源码如下：

```js
function createDocumentHandler(el, binding, vnode) {
  return function(mouseup = {}, mousedown = {}) {
    if (!vnode ||
      !vnode.context ||
      !mouseup.target ||
      !mousedown.target ||
      el.contains(mouseup.target) ||
      el.contains(mousedown.target) ||
      el === mouseup.target ||
      (vnode.context.popperElm &&
      (vnode.context.popperElm.contains(mouseup.target) ||
      vnode.context.popperElm.contains(mousedown.target)))) return;

    if (binding.expression &&
      el[ctx].methodName &&
      vnode.context[el[ctx].methodName]) {
      vnode.context[el[ctx].methodName]();
    } else {
      el[ctx].bindingFn && el[ctx].bindingFn();
    }
  };
}
```

先看什么条件下直接返回空：

```js
!vnode ||  // 当前虚拟节点不存在 或
!vnode.context ||  // 虚拟节点中不存在当前vue实例 或
!mouseup.target ||  // mouseup 元素节点不存在 或
!mousedown.target ||  // mousedown 元素节点不存在 或
el.contains(mouseup.target) ||  // mouseup 元素节点为当前指令元素的子节点 或
el.contains(mousedown.target) ||  // mousedown 元素节点为当前指令元素的子节点 或
el === mouseup.target ||  // 当前元素为 mouseup 元素节点 或 
(vnode.context.popperElm &&  // 当前实例存在 popperElm 对象
(vnode.context.popperElm.contains(mouseup.target) ||  // mouseup 元素节点为popperElm 对象节点的子节点
vnode.context.popperElm.contains(mousedown.target)))  // mousedown 元素节点为popperElm 对象节点的子节点
```

如果满足以下一个条件就直接返回空

1. 当前虚拟节点不存在
2. 虚拟节点中不存在当前vue实例
3. `mouseup`元素节点不存在
4. `mousedown` 元素节点不存在
5. `mouseup` 元素节点为当前指令元素的子节点
6. `mousedown` 元素节点为当前指令元素的子节点
7. 当前元素为 `mouseup` 元素节点
8. 当前实例中存在`popperElm` 对象并且满足以下一个条件
   1. `mouseup`元素节点为`popperElm` 对象节点的子节点
   2. `mousedown` 元素节点为`popperElm`对象节点的子节点

重点部分：

```js
if (
    binding.expression &&
    el[ctx].methodName &&
    vnode.context[el[ctx].methodName]
) {
    vnode.context[el[ctx].methodName]();
} else {
    el[ctx].bindingFn && el[ctx].bindingFn();
}
```

看第一个判断条件：

```js
binding.expression && el[ctx].methodName && vnode.context[el[ctx].methodName]
```

如果`指令有绑定值` 同时`这个元素上的指令属性中存在绑定值`还同时在当前实例上存在这个绑定值对应方法就直接调用那个方法
