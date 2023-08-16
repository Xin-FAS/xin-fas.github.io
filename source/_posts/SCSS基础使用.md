---
title: SCSS基础使用
date: 2022-03-24 00:48:27
tags: [scss]
categories: [前端]
---

# SCSS 介绍

在了解scss之前先看看Sass：

## SASS 是什么

Sass 是一门高于 CSS 的元语言，它能用来清晰地、结构化地描述文件样式，有着比普通 CSS 更加强大的功能。Sass 能够提供更简洁、更优雅的语法，同时提供多种功能来创建可维护和管理的样式表。Sass 是采用 Ruby 语言编写的一款 `CSS 预处理语言`，它诞生于2007年，是最大的成熟的 CSS 预处理语言。最初它是为了配合HAML（一种缩进式 HTML 预编译器）而设计的，因此有着和 HTML 一样的缩进式风格。`SASS是CSS3的一个扩展`，增加了规则嵌套、变量、混合、选择器继承等等。通过使用命令行的工具或WEB框架插件把它转换成标准的、格式良好的CSS代码。

Sass官方网站：[http://sass-lang.com](http://sass-lang.com/)

## Scss是什么

Scss 是 `Sass 3` 引入新的语法，是`Sassy CSS`的简写，是`CSS3语法的超集`，也就是说所有有效的CSS3样式也同样适合于Sass。说白了Scss就是Sass的升级版，其语法完全兼容 CSS3，并且继承了 Sass 的强大功能。也就是说，任何标准的 CSS3 样式表都是具有相同语义的有效的 SCSS 文件。另外，SCSS 还能识别大部分 CSS hacks（一些 CSS 小技巧）和特定于浏览器的语法，例如：古老的 IE filter 语法。

由于 Scss 是 CSS 的扩展，因此，所有在 CSS 中正常工作的代码也能在 Scss 中正常工作。也就是说，对于一个 Sass 用户，只需要理解 Sass 扩展部分如何工作的，就能完全理解 Scss。大部分扩展，例如变量、parent references 和 指令都是一致的；唯一不同的是，SCSS 需要使用分号和花括号而不是换行和缩进。

>所以说，Scss就是Sass的升级版，为css3的超集

## Scss 与 Sass异同

这两点的差别主要有以下两个方面

1. 文件扩展名不同，Sass是以“.sass”后缀为扩展名，而Scss是以“.scss”后缀为扩展名。
2. 语法书写不同，Sass是以严格的缩进式语法规则来书写，不带大括号和分号，而Scss则和css的语法书写非常类似。

### 简单的Sass样式代码

```css
#divBox
width: 30%
font-size: 13px
```

### 对应的Scss代码

```css
#divBox {
    width: 30%;
    font-size: 13px;
}
```

# SCSS的主要使用

## 嵌套选择器

SCSS的入门就是使用嵌套选择器,SCSS 允许将一套 CSS 样式嵌套进另一套样式中，内层的样式将它外层的选择器作为父选择器.

### 简单嵌套

**HTML：**

```html
<body>
    <p>你好</p>	
</body>
```

**Scss：**

```css
body {
    p {
        color: red;
    }
}
```

> 嵌套功能避免了重复输入父选择器，而且令复杂的 CSS 结构更易于管理,还可以有更加复杂的嵌套

### 伪类样式的嵌套使用

```scss
body {
  p {
    color: red;
    &:hover {
      color: green;
    }
  }
}
```

> 当我们需要给p标签加上伪类样式的时候，在scss中可以使用&符号指代

**编译后：**

```css
body p {
  color: red;
}
body p:hover {
  color: green;
}
```

## 变量

scss最普遍的就是声明变量,然后在其他的文档中引入,这样方便修改整体的样式,声明变量的方式就是使用$来声明变量.

```scss
$red: red;
$g: green;

body {
  p {
    color: $red;
    &:hover {
      color: $g;
    }
  }
}
```

> 上面的代码中声明了两个变量`$red`和`$g`，分别是红色和绿色，然后再使用的时候，如css一样正常使用即可

在scss中变量也是有作用域的，可以在变量后加上`!global`来把他变为全局变量

```scss
body {
  p {
    $red: #f60 !global;
    font: {
      size: 34px;
      family: "Courier";
      weight: bold;
    }
  }
  div {
    color: $red;
  }
}
```

## 样式的运算

平常在css3中，使用的是`calc`来对不确定的css属性运算，但在scss中可以直接使用运算符，不需要加calc，但是一定要加上单位

```scss
width: 100px + 100px + 100px; //加法
width: 100px - 100px + 100px; //减法
width: 100px * 100 //乘法,注scss的乘法和除法是带单位的
width: (100px/3)  //注意这里需要带括号,如果不带括号会当场分割数子
width: $width / 3 //也可以不带括号,但是里面计算的一定要有声明的变量,因为这个语法css不认识,那么就会被解析成SCSS
width: 100 % 3px //SCSS也支持取模运算
```

# 其他类似函数功能

## mixin

定义指令混入`@mixin `可以将定义的指令混入到一个元素的样式里面去,混入的方式是使用`@include` 来混入

```scss
@mixin mix {
  border: 1px solid red;
}

body {
  p {
    @include mix;
    color: red;
    &:hover {
      color: green;
    }
  }
}
```

其中mixin还可以定义为函数

```scss
@mixin mix($width) {
  border: $width solid red;
}

body {
  p {
    @include mix(2px);
    color: red;
    &:hover {
      color: green;
      @include mix(6px);
    }
  }
}
```

## placeholder（建议了解就好）

# webstorm中自动编译

## 下载scss

```bash
npm i scss -g
```

## 配置

进入 File>Settings>Tools>File Watcher ，添加scss编译，全默认就行

# vueCli中使用

先下载sass的包sass-loader，又因为sass-loader需要依赖node-sass，所以我们需要装两个

> 版本要求：
>
> sass-loader和node-sass对node的版本要求极其严格，三个版本都要对应上，这里提供一组版本：
>
> `nodejs: 16`
>
> `node-sass: ^6.0.1`
>
> `sass-loader: ^10.0.1`
>
> ^ 这个表示则大版本不变的情况下使用最高版本，最低不低于指定版本

## 下载

```bash
npm i -D node-sass@^6.0.1 sass-loader@^10.0.1
# or
yarn add node-sass@^6.0.1 sass-loader@^10.0.1
```

> 如果下载失败的话，先清理下编译文件，还不行就直接下载默认最新版，然后在包管理中修改版本重新下载依赖即可

## 使用演示

```scss
<style lang="scss" scoped>
  .loginBg {
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100vh;

    .loginBox {
      width: 600px;
      height: 400px;
      background: #ccc;
    }
  }
</style>
```

> 使用的时候，直接在style标签中加上`lang="scss"`即可

## 新版使用

### 说明

在某一天啊，我下载依赖，很快啊，就是一堆的gyp报错，原因看了半天，发现又是node-sass的版本对应问题，查阅资料发现，原来sass的官网已经将node-sass标记为过期版本了，已经被dart-sass代替了

### 区别

1. 编译方式
   * node-sass 是用 node(调用 cpp 编写的 libsass)来编译 sass，所以这就是对node版本有要求的原因；
   * dart-sass 是用 drat VM 来编译 sass
2. 生效方式
   * node-sass是自动编译实时的
   * dart-sass需要保存后才会生效

推荐 dart-sass 性能更好（也是 sass 官方使用的），而且 node-sass 因为国情问题经常装不上

### 替换步骤

1. 先卸载`node-sass`
2. 安装`sass`即可

> 按照名字来看，不是应该装`dart-sass`吗，其实`dart-sass`只是官方为了区别`node-sass`而起的名字，在下载时的模块名就是`sass`

#### 卸载node-sass：

```bash
npm uninstall node-sass -D
# or
yarn remove node-sass
```

> 使用npm卸载需要加上版本号，如`node-sass@^6.0.1`

#### 安装sass：

```bash
npm i sass -D
# or
yarn add sass
```

## 总结步骤：

1. 安装sass-loader

```bash
yarn add sass-loader
```

2. 安装sass

```bash
yarn add sass
```

# vite中使用

## 说明

在上面的vueCli中使用需要安装`sass-loader`和`sass`，但是在vite中只要安装`sass`即可

## 下载

```bash
npm i sass -D
# or
yarn add sass
```

