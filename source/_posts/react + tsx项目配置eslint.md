---
title: react + tsx项目配置eslint
date: 2022-07-18 13:40:30
tags: [vite,react]
categories: [前端,react]
---
# 创建项目

```bash
yarn create vite 项目名
```

> 选择react-ts

# 使用eslint

## 安装eslint

```bash
yarn add eslint -D
```

## 初始化eslint

```bash
npx eslint --init
# or
npm init @eslint/config
# or
yarn create @eslint/config
```

### 选择配置

1. How would you like to use ESLint? 
   * 选择 To check syntax, find problems, and enforce code style（严格模式）
2. What type of modules does your project use?
   * 选择 JavaScript modules (import/export)（javascript方式）
3. Which framework does your project use?
   * 选择 React.js（选择语言框架）
4. Does your project use TypeScript?
   * 选择yes（是否使用ts）
5. Where does your code run?
   * 使用空格将两个全选上（node环境和浏览器环境）
6. How would you like to define a style for your project?
   * 选择 Use a popular style guide（选择社区推荐设置）
7. Which style guide do you want to follow?
   * 选择 Standard（社区配置）
8. What format do you want your config file to be in?
   * 选择 json
9. Would you like to install them now?
   * 选择 yes （现在安装）
10. Which package manager do you want to use?
    * 选择 yarn（选择包管理工具，视个人选择）

> 以上选择完毕之后，会在项目根目录出现 `.eslintrc.json` 文件

## 添加vite对eslint的支持

```bash
npm i vite-plugin-eslint -D
# or
yarn add vite-plugin-eslint -D
# or
pnpm add vite-plugin-eslint -D
```

## 安装eslint对js解析器和核心

```bash
npm i eslint @babel/core @babel/eslint-parser -D
# or
yarn add eslint @babel/core @babel/eslint-parser -D
```

## 安装eslint对ts的解析器

```bash
yarn add -D typescript @typescript-eslint/parser
# or
npm i --save-dev typescript @typescript-eslint/parser
```

## 配置vite-config.ts文件

```js
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import eslintPlugin from 'vite-plugin-eslint'

export default defineConfig({
    plugins: [
        react(),
        eslintPlugin({
            include: ['src/**/*.tsx', 'src/**/*.ts', 'src/*.ts', 'src/*.tsx']
        })
    ]
})
```

## 配置.eslintrc.json文件中校验规则

```json
{
  "env": {
    "browser": true,
    "es2021": true,
    "node": true
  },
  "extends": [
    "plugin:react/recommended",
    "standard"
  ],
  "parser": "@typescript-eslint/parser",
  "parserOptions": {
    "ecmaFeatures": {
      "jsx": true
    },
    "ecmaVersion": "latest",
    "sourceType": "module"
  },
  "plugins": [
    "react",
    "@typescript-eslint"
  ],
  "rules": {
    // 禁止尾部使用分号“ ; ”
    "semi": [
      2,
      "never"
    ],
    // 禁止使用 var
    "no-var": "error",
    // 缩进4格
    "indent": [
      "error",
      4
    ],
    // 不能空格与tab混用
    "no-mixed-spaces-and-tabs": "error",
    // 使用单引号
    "quotes": [
      2,
      "single"
    ],
    // 关闭显式引入react
    "react/jsx-uses-react": "off",
    "react/react-in-jsx-scope": "off",
    // jsx中使用双引号，js中使用单引号
    "jsx-quotes": [
      "error",
      "prefer-double"
    ],
    // jsx 多行标签右括号与开始标签换行对齐
    "react/jsx-closing-bracket-location": 1,
    // 禁止把undefined赋值给一个变量。
    "no-undef-init": "error",
    // 自闭合标签前留一个空格
    "react/jsx-tag-spacing": 2
  },
  "settings": {
    "react": {
      "version": "detect"
    }
  }
}
```

## 在idea或webstorm中开启项目对eslint的支持

> file > settings > Languages > JavaScript > Code Quality Tools > ESLint

# 其他问题

## 没指定react版本

问题：React version not specified in eslint-plugin-react settings

在`.eslintrc.json`中添加即可

```json
"settings": {
  "react": {
    "version": "detect"
  }
}
```
