---
title: 移动端布局说明
date: 2022-08-10 16:18:35
tags: [html,布局方案]
categories: [前端]
---
# 浏览器现状

## PC常见

* 360浏览器（双内核IE和Webkit）
* 谷歌浏览器（Webkit内核）
* 火狐浏览器（Gecko内核）
* QQ浏览器（双内核IE和Webkit）
* 百度浏览器（双内核Trident和Blink（Webkit））【已停止维护】
* 搜狗浏览器（Webkit内核）
* IE浏览器【已淘汰，转Edge（Webkit内核）】

## 移动端常见

* UC浏览器
* QQ浏览器
* 欧朋浏览器
* 百度手机浏览器
* 360安全浏览器
* 谷歌浏览器
* 搜狗手机浏览器
* 猎豹浏览器
* 夸克浏览器
* 其他如：Via，Edge

国内的UC和QQ，百度等手机浏览器都是根据Webkit修改过来的内核，国内尚无自主研发的内核，就像国内的手机操作系统都是基于Android修改开发的一样。

总结：要兼容移动端主流浏览器，处理Webkit内核浏览器即可

# 物理像素和物理像素比

物理像素点指的是屏幕显示的最小颗粒，是物理真实存在的。这是厂商在出厂时就设置好了，比如苹果6/7/8 是 750 * 1334
我们开发时候的1px不是一定等于1个物理像素（PC端页面，1个px等于1个物理像素，移动端不是）
一个px能显示的物理像素个数称为物理像素比，如 苹果8 的像素比为2.0，物理像素为750，所以实际开发像素只有350px

> 这个差别来源说明：
> PC端和早前的手机屏幕或者普通手机屏幕都是 1CSS像素 = 1物理像素的
> 但是手机端提出了 Retina（视网膜屏幕）显示技术，可以把更多的物理像素点压缩到屏幕中，从而达到更高的分辨率，所以这就是手机中 物理像素 = 开发像素 * 物理像素比

# 多倍图

对于一张50px * 50px的图片，在手机Retina屏中打开，按照刚才的物理像素比会放大倍数，这样会造成图片模糊
在标准的viewport设置中，使用倍图来提高图片质量，解决在高清设备中的模糊问题
通常使用二倍图，因为iPhone 6/7/8 的影响，但是现在还存在3倍图4倍图的情况，这个看实际开发公司需求
还有一点就是要注意背景图片的缩放问题

## img宽高缩放：

```html
<img src="./img100.png" alt="这是 100px * 100px 的图片" style="width: 50px;height: 50px">
```

在2.0物理像素比的手机中显示，50px宽高css像素会产生100px宽高的物理像素，也就是说100px * 100px的图片刚好填慢，不会产生模糊

## 二倍精灵图

要使用二倍精灵图，不能直接测量xy，正确使用步骤如下：

1. 测量出所需图标的坐标后，各取一半，如二倍图中为 -162px 0，代码中背景偏移就为 -81px 0
2. 需要使用`background-size`属性写精灵图宽度的一半，高度不写或auto

```css
background: url(...) no-repeat -81px 0;
background-size: 200px auto;
```

# 移动端主流方案

## 单独移动端页面（和PC页面分开）

举例：

* 京东商城手机版
* 淘宝触屏版
* 苏宁易购手机版
* ...

> 这类单独制作移动端从路由可以看出，如 m.taobao.com	m.jd.com

技术选型：

* 流式布局（百分比布局）
* flex弹性
* rem + 媒体查询

一般都是混合使用

## 响应式页面兼容移动端

举例：

* 三星手机官网
* ...

缺点：制作麻烦，需要花费大量精力去调试兼容性问题

技术上来说，底层都是根据媒体查询实现的，如tailwindcss，bootstrap

# 移动端CSS初始化

对于移动端的css，初始化就不用手动了，推荐使用 normalize.css

包下载：
```base
npm i normalize.css
```

优点：
1. 保护了有价值的默认值
2. 修复了浏览器的bug
3. 是模块化的
4. 拥有详细的文档

# 特殊样式

```css
* {
    /* 清除点击高亮 */
    -webkit-tap-highlight-color: transparent;
}

input, button {
    /* 移动端浏览器默认外观在ios上加上这个属性才能给按钮和输入框自定义样式 */
	-webkit-appearance: none;   
}

img, a {
    /* 禁用长按页面时的弹出菜单 */
    -webkit-touch-callout: none;
}
```

# 移动端常见布局

## 流式布局

流式布局，就是百分比布局，也称非固定像素布局。主要是针对宽度像素百分比控制实现自动缩放

当盒子被缩放到过大或者过小的时候，盒子内容就会被排挤或填充，所以需要用到以下两个属性：

max-width 最大宽度   min-width 最小宽度

## Flex布局
常见就不说明了；

## rem适配布局

就是依据html标签中的字体大小

## vw/vh布局

1vw(viewport width)  = 1/100 视口宽度

1vh(viewport height) = 1/100 视口高度

基础使用：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width,initial-scale=1.0,minimum-scale=1.0,maximum-scale=1.0,use-scalable=no">
    <title>Title</title>
    <style>
        /* 设计图中有一个 50px * 50px 的盒子，设计图宽度375px，换算为vw */
        div {
            /* （50 / 3.75）vw */
            width: 13.3333vw;
            height: 13.3333vw;
            /* 3.75px字体大小，（3.75 / 3.75）vw */
            font-size: 1vw;
            background-color: #ff7c2d;
        }
    </style>
</head>
<body>
<div>This is viewport</div>
</body>
</html>
```

> 在开发中，vw就够用了，vh不太需要，如b站的布局就是使用的vw

可使用vw代替媒体查询，如下：

```scss
$span: 10;
// 设计图为750px，我分10份，因为10好计算
$font-span: 75;

html {
  font-size: 100vw / $span;
}

// 限制超过750px按照750计算
@media screen and (min-width: 750px) {
    html {
        font-size: 75
    }
}

