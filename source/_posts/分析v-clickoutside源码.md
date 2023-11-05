---
title: 分析v-clickoutside源码
date: 2023-10-30 16:35:30
tags: [JavaScript]
categories: [前端,Vue]
sticky: 10
---

## 如何调试源码

先创建一个`vue2`的项目，对于直接修改使用npm下载的依赖包中的源码代码进行调试是不行的，因为项目中使用的是编译后的element组件代码，也就是`lib`文件夹下的代码。

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

## 先查看工具函数

### on 方法

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

`isServer`：是否为服务端环境，我们可以视为`false`

> 补充`isServer`：Vue.js 是一个用于构建客户端应用的框架，这个属性通常用于在服务端渲染（SSR）时区分客户端和服务端环境。我们并不使用SSR，所以可以视为`false`

可以看到这是一个立即执行函数，只要正常存在`document.addEventListener`，就返回一个方法，这个方法接受三个参数（节点对象，事件名，处理方法），可为对应元素使用`addEventListener`建立监听事件

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

### createDocumentHandler 方法

源码如下：

```js
function createDocumentHandler (el, binding, vnode) {
    return function (mouseup = {}, mousedown = {}) {
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

使用如下：

```js
bind (el, binding, vnode) {
    nodeList.push(el);
    const id = seed++;
    el[ctx] = {
        id,
        documentHandler: createDocumentHandler(el, binding, vnode),
        methodName: binding.expression,
        bindingFn: binding.value
    };
}
// 使用documentHandler的地方
!Vue.prototype.$isServer && on(document, 'mouseup', e => {
    nodeList.forEach(node => node[ctx].documentHandler(e, startClick));
});
```

接受三个参数，这三个参数都是vue指令里面的参数就不说了，重点是返回的方法

`documentHandler`可传入两个参数，看源码中第一个参数传入了`鼠标松开时的dom节点`，第二个参数为`鼠标按下时的dom节点`，内部重点如下：

```js
if (binding.expression &&
    el[ctx].methodName &&
    vnode.context[el[ctx].methodName]) {
    vnode.context[el[ctx].methodName]();
} else {
    el[ctx].bindingFn && el[ctx].bindingFn();
}
```

1. `binding.expression`：指令绑定的字符串，如`v-demo="demoName"`中就是`demoName`，而不是它的值
2. `el[ctx].methodName`：同上，（不能理解为什么还要判断一次）
3. `vnode.context[el[ctx].methodName]`：当前vue实例中存在这个名字（当绑定名的值不是方法时后续就会报错）

所以解释如下：当这个指令有绑定名，并且在当前的实例中存在这个属性就会直接调用，反之，如果这个指令存在绑定名但是这个值并没有在当前实例中，就会直接调用绑定值

尝试了半天也没有想到为什么要区分开这两个情况不直接调用， 我还是太菜了，总结就是一个作用：`调用指令绑定的方法`

分析好重点的部分的作用就只是调用方法后，来看下哪些情况下会直接返空

```js
!vnode || // 当前虚拟节点不存在 或
!vnode.context || // 虚拟节点中不存在当前vue实例 或
!mouseup.target || // 记录的鼠标松开时的元素不存在 或
!mousedown.target || // 记录的鼠标按下时的元素不存在 或
el.contains(mouseup.target) || // 记录的鼠标松开时的元素为当前指令元素或当前指令元素的子元素 或
el.contains(mousedown.target) || // 记录的鼠标按下时的元素为当前指令元素或当前指令元素的子元素 或
el === mouseup.target ||  // 当前元素为记录的鼠标松开时的元素 或 
(vnode.context.popperElm &&  // 当前实例存在 popperElm 对象
(vnode.context.popperElm.contains(mouseup.target) ||  // mouseup 元素节点为popperElm 对象节点的子节点
vnode.context.popperElm.contains(mousedown.target)))  // mousedown 元素节点为popperElm 对象节点的子节点
```

以上判断中最后三行为针对`popper.js`，目前能力不足，但是其他都是很好分析的

总结下重点只有两个：

1. 鼠标按下时的元素不能为指定元素本身或子元素
2. 鼠标抬起的元素不能为指定元素本身或子元素

所以整个`createDocumentHandler`返回的方法分析总结如下：

传入鼠标抬起和按下两个dom节点，如果这两个节点中的元素不为当前元素本身或子元素就调用指令绑定的方法

## 整体的详细分析

```js
import Vue from 'vue';
import { on } from 'element-ui/src/utils/dom';

const nodeList = []; // 用于存放使用了这个指令的全部元素节点
const ctx = '@@clickoutsideContext'; // 用于在元素节点上添加属性（第五十一行），表示这个指令所添加的唯一属性名

let startClick; // 鼠标按下时的dom节点（看第十行）
let seed = 0; // 使用这个指令的元素的唯一值（第五十行）

!Vue.prototype.$isServer && on(document, 'mouseddown', e => (startClick = e)); // 建立鼠标按下事件，记录给startClick

!Vue.prototype.$isServer && on(document, 'mouseup', e => {
    nodeList.forEach(node => node[ctx].documentHandler(e, startClick)); // 建立鼠标松开事件，遍历全部dom节点，使用元素上的documentHandler方法，来判断和调用方法
});

function createDocumentHandler (el, binding, vnode) {
    return function (mouseup = {}, mousedown = {}) {
        if (
            !vnode || // 当前虚拟节点不存在 或
            !vnode.context || // 虚拟节点中不存在当前vue实例 或
            !mouseup.target || // 记录的鼠标松开时的元素不存在 或
            !mousedown.target || // 记录的鼠标按下时的元素不存在 或
            el.contains(mouseup.target) || // 记录的鼠标松开时的元素为当前指令元素或当前指令元素的子元素 或
            el.contains(mousedown.target) || // 记录的鼠标按下时的元素为当前指令元素或当前指令元素的子元素 或
            el === mouseup.target ||  // 当前元素为记录的鼠标松开时的元素 或
            (vnode.context.popperElm &&  // 当前实例存在 popperElm 对象
                (vnode.context.popperElm.contains(mouseup.target) ||  // mouseup 元素节点为popperElm 对象节点的子节点
                    vnode.context.popperElm.contains(mousedown.target)))  // mousedown 元素节点为popperElm 对象节点的子节点
        ) return;
        if (
            binding.expression && // 指令存在绑定名
            el[ctx].methodName && // 同上
            vnode.context[el[ctx].methodName] // 当前实例中存在绑定名的值
        ) {
            vnode.context[el[ctx].methodName](); // 调用当前实例中绑定名的方法
        } else {
            el[ctx].bindingFn && el[ctx].bindingFn(); // 当前实例中不存在绑定名的值时直接调用指令值方法
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
    bind (el, binding, vnode) {
        nodeList.push(el); // 初始化添加进列表中待监听判断
        const id = seed++; // 让每一个元素的属性唯一
        el[ctx] = { // 记录给监听鼠标的事件使用
            id,
            documentHandler: createDocumentHandler(el, binding, vnode),
            methodName: binding.expression,
            bindingFn: binding.value
        };
    },

    update (el, binding, vnode) { // 值更新时不需要再次添加监听元素列表，只要更新当前元素身上的值即可
        el[ctx].documentHandler = createDocumentHandler(el, binding, vnode);
        el[ctx].methodName = binding.expression;
        el[ctx].bindingFn = binding.value;
    },

    unbind (el) {
        let len = nodeList.length; // 元素卸载时先获取待监听元素列表的长度待后续遍历

        for (let i = 0; i < len; i++) { // 遍历元素列表
            if (nodeList[i][ctx].id === el[ctx].id) { // 当监听列表中元素身上属性的id为当前元素上的id
                nodeList.splice(i, 1); // 移除这个位置一个元素
                break; // 退出循环
            }
        }
        delete el[ctx]; // 最后删除这个元素身上的属性对象
    }
};
```

## 源码总结

这个实现方法主要由鼠标监听事件实现，通过把元素加上自身属性后添加进`nodeList`，然后在鼠标抬起的时候判断鼠标是否在元素之外来触发绑定的方法，唯一让我不理解的就是源码中`methodName`的作用，自己也尝试了外部引入方法，`data`中定义方法，还是在全局的原型链上定义方法，还是无法理解，我太菜了
