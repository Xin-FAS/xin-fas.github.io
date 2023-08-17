---
title: Less使用
date: 2022-08-13 10:55:26
tags: [css,less]
categories: [前端]
---

## 介绍

Less（Leaner Style Sheets 的缩写）是一门CSS扩展语言，也成为CSS预处理器。

在CSS的语法基础上，引入了变量，Mixin（混入），运算已经函数等功能，简化了CSS的编写，降低了CSS的维护成本，[进入Less中文网站](http://lesscss.cn)

目前只记录简单使用，主流还是SCSS，详见另一篇

## 配置webstorm自动编译

### 安装less模块

```bash
# 全局安装less
npm i less -g
# 安装less的插件，用于压缩代码
npm i less-plugin-clean-css -g
```

### 配置webstorm

进入 File>Settings>Tools>File Watcher ，添加less编译，全默认就行

> program这个地方填写的是less的cmd文件路径，不知道地址的直接搜索lessc.cmd，一般全局装好less模块就自动补上了

配置完了重启下webstorm，需要注意的是，编译的less文件**需要放置在css文件下**，因为默认配置中就是如此

## Less变量

定义一个变量

```less
@变量名: 值;
```

使用一个变量

```less
属性名: @变量名
```

例如：

```less
@font-color: #666;

body {
  color: @font-color;
}

.box {
  color: @font-color;
}
```

> 变量命名规则：
>
> 1. 必须有@为前缀
> 2. 不能包含特殊字符
> 3. 不能以数字开头
> 4. 大小写敏感
> 4. 必须以`;`结尾
>
> 于SCSS相比：less的变量声明用`@`，而scss使用`$`

## Less嵌套

### 普通使用

```less
@font-color: #666;

body {
  color: @font-color;

  .box {
    color: @font-color;
  }
}
```

### 伪类、结构伪类选择器

```less
@font-color: #666;

body {
  color: @font-color;

  div:first-child {
    color: red;
  }

  &:hover {
    background-color: #00a4ff;
  }
}
```

如果没有`&`，那么编译后就有一个空格，被当作是子类

### 伪元素选择器

同理伪类选择器，使用`&`符号就可以

```less
@font-color: #666;

body {
  color: @font-color;

  &::after{
    content: 'this is after';
  }
}
```

> 总结：在嵌套代码上，less和scss写法相同

## Less运算

```less
@border-width: 10px;

body {
  .box {
    width: 100px - 2px;
    height: 100px * 2;
    border: @border-width + 10 solid #000;
  }
}
```

> 同理，写法和scss是一样的
>
> 注意点：
>
> 1. 在运算符的两边最好留一个空格
> 2. 做运算时，如果两边只有一个单位，就以这个单位为最后运算结果
> 3. 做运算时，如果两边都有单位，则以前面的运算单位为结果
> 3. 新版本除法需要使用括号，如：`font-size: (320px / @span);`

甚至颜色都可以运算：

```less
color: #666 - #222;    // color: #444
```
