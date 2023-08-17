---
title: React脚手架
date: 2022-07-17 16:44:32
tags: [react]
categories: [前端,react]
---

## 搭建react项目

### 使用webpack

#### yarn

```bash
yarn create react-app 项目名
# or
npm init react-app 项目名
# or 
npx create-react-app 项目名
```

> 使用webpack作为底层服务器，构建比较慢，需要一分钟左右，启动在`3000`端口

### 使用vite构建

```bash
yarn create vite 项目名
```

选择react即可，启动在`5173`端口

## webpack构建的项目

### public中的结构

| 文件名        | 说明                   |
| ------------- | ---------------------- |
| index.html    | 主要的渲染文件         |
| manifest.json | 应用加壳需要的配置文件 |
| robots.txt    | 爬虫协议文件           |

#### 分析index.html

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <!--    %PUBLIC_URL% 表示 public文件夹的路径-->
    <link rel="icon" href="%PUBLIC_URL%/favicon.ico" />
    <!--    开启理想窗口，用于做移动端适应-->
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <!--    配置浏览器的页签+地址栏的颜色（仅用于安卓手机浏览器）-->
    <meta name="theme-color" content="#000000" />
    <!--    配置搜索关键字-->
    <meta
            name="description"
            content="Web site created using create-react-app"
     />
    <!--    用于指定网页添加到手机屏幕的显示的图标-->
    <link rel="apple-touch-icon" href="%PUBLIC_URL%/logo192.png" />
    <!--    应用加壳时的配置文件-->
    <link rel="manifest" href="%PUBLIC_URL%/manifest.json" />
    <title>React App</title>
</head>
<body>
<!--noscript 这个标签是在浏览器不支持js的时候显示的-->
<noscript>You need to enable JavaScript to run this app.</noscript>
<div id="root"></div>
</body>
</html>
```

### src中的结构

| 文件名             | 说明                            |
| ------------------ | ------------------------------- |
| App.js             | 用函数式定义了一个叫做App的组件 |
| App.test.js        | 做测试用的（基本用不到）        |
| index.js           | webpack程序入口文件             |
| reportWebVitals.js | 用于记录页面性能的配置文件      |
| setupTests.js      | 做组件测试的                    |

#### 分析index.js

```js
import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
import App from './App';
import reportWebVitals from './reportWebVitals';

// React 18.x的语法，同Reach.render()
const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  // React.StrictMode包裹App这个组件，开启严格模式
  <React.StrictMode>
    <App  />
  </React.StrictMode>
);

// 记录页面性能
reportWebVitals();
```

### 简化结构

#### public

只剩下`index.html`即可

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <title>React App</title>
</head>
<body>
<div id="root"></div>
</body>
</html>
```

#### src

只剩下`App.js`和`index.js`即可

**App.js**

```js
import React from "react";

class App extends React.Component {
    render() {
        return (
            <div>
                Hello, React
            </div>
        )
    }

}

export default App;
```

**index.js**

```js
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
    <React.StrictMode>
        <App />
    </React.StrictMode>
);
```



## 样式混乱

定义多个组件时，使用的样式文件重复名字的话会产生样式混乱

解决：可以在取名时加上module

## 子组件向父组件传参

子组件：

```tsx
import React, { Component } from 'react'

interface IProps {
    setName: Function
}

class Index extends Component<IProps, null> {
    render () {
        return (
            <div>
                <button onClick={this.props.setName('FSAN')}>点击向父组件传参</button>
            </div>
        )
    }
}

export default Index as any
```

父组件：

```tsx
import React, { Component } from 'react'
import Children from '../Children'

class Index extends Component {
    setName = (name: string) => {
        console.log('这里是父组件：', name)
    }

    render () {
        return (
            <div>
                <Children setName={this.setName} />
            </div>
        )
    }
}

export default Index as any
```

## vite代理跨域

请求地址：`/api/XXX`，接口地址：`http://localhost:5000/api/XXX`

```ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import eslintPlugin from 'vite-plugin-eslint'

// https://vitejs.dev/config/
export default defineConfig({
    plugins: [
        react(),
        eslintPlugin({
            include: ['src/**/*.tsx', 'src/**/*.ts', 'src/*.ts', 'src/*.tsx']
        })
    ],
    server: {
        proxy: {
            '/api': {
                target: 'http://localhost:5000'
            }
        }
    }
})
```

> 看`server`即可，除了`target`还可以配置：
>
> 1. `changeOrigin: true`   是否改写 origin，设置为 true 之后，就会把请求 API header 中的 origin，改成跟 `target` 里边的域名一样了。
> 2. `rewrite: (path) => path.replace(/^\/api/, "")`   可以把请求的 URL 进行重写，这里因为假设后端的 API 路径不带 `/api` 段，所以我们使用 `rewrite`去掉 `/api`。
>
> 注意一点：请求本地的时候，先是去获取到项目中的静态资源，没找到才会通过代理

## 消息订阅与发布（PubSub）

用于任意组件的沟通

### 下载

```bash
npm i pubsub-js
# or
yarn add pubsub-js
# ts 额外需要
yarn add @types/pubsub-js
```

### 订阅消息

```tsx
token: string = ''

// 页面挂载完毕后订阅数据
componentDidMount () {
    this.token = pubsub.subscribe('demoData', (_, data) => {
        console.log(_, data)
        this.setState({ data })
    })
}

componentWillUnmount () {
    pubsub.unsubscribe(this.token)
}
```

> _ 下划线占位元素用的，类似c#中的弃元

### 发布消息

```tsx
pubsub.publish('demoData', '这是一条消息')
```

> 但是发送后莫名其妙的会有两次接收

## TodoList案例

### ToDoList.tsx

```tsx
// vite.config.ts

import { Component, KeyboardEvent, MouseEvent, createRef } from 'react'
import './ToDoList.scss'

interface IListData {
    [key: string]: string | number | boolean

    id: string
    name: string,
    isChecked: boolean
}

interface IState {
    listData: IListData[],
    delBtnState: boolean
}

class ToDoList extends Component<null, IState> {
    state = {
        listData: [],
        delBtnState: false
    }

    selectAllBox = createRef<HTMLInputElement>()

    // 回车添加
    add = (e: KeyboardEvent<HTMLInputElement>): void => {
        const { key, target }: { key: string, target: HTMLInputElement } = e
        if (key === 'Enter' && target.value) {
            // 去空格
            target.value = target.value.trim()
            // 判断重复
            if (this.state.listData.findIndex((v: IListData) => v.name === target.value) === -1) {
                // 生成唯一id
                const id = (Math.random() * 100).toFixed(0) + Date.now().toString().slice(0, 10)
                this.setState({
                    listData: [
                        ...this.state.listData,
                        {
                            id,
                            name: target.value,
                            isChecked: false
                        } as IListData
                    ]
                })
                // 添加完清空
                target.value = ''
            }
        }
    }

    // 全选事件
    selectAll = (e: MouseEvent) => {
        const target = e.target as HTMLInputElement
        this.setState({
            listData: this.state.listData.filter((v: IListData) => {
                v.isChecked = target.checked
                return true
            })
        })
    }

    // 选中事件
    changeSelect = (id: string): any => ({ target }: { target: HTMLInputElement }): void => {
        const { listData } = this.state
        listData.map((v: IListData) => v.id === id ? { ...v, isChecked: target.checked } : v)
        this.setState({ listData })
        const current = this.selectAllBox.current as HTMLInputElement
        // 全选或取消全选
        current.checked = this.state.listData.findIndex((v: IListData) => !v.isChecked) === -1
    }

    delList = (id: string): any => (): void => {
        this.setState({
            listData: this.state.listData.filter((v: IListData) => v.id !== id)
        })
    }

    delAll = () => {
        this.setState({
            listData: this.state.listData.filter((v: IListData) => !v.isChecked)
        })
    }

    handleMouse = (flag: boolean) => (e: MouseEvent<HTMLDivElement>): void => {
        const target = e.target as HTMLInputElement
        const btnDom = target.children[2] as HTMLButtonElement
        btnDom.style.display = flag ? 'block' : 'none'
        target.style.backgroundColor = flag ? '#ddd' : '#fff'
        this.setState({
            delBtnState: flag
        })
    }

    render () {
        return (
            <div id="todoList">
                <input className="add-input" type="text" onKeyDown={this.add} placeholder="请输入你的任务名称，按回车键确认" />
                <div className="list-box">
                    {this.state.listData.map(({ id, name, value, isChecked }) => {
                        return (
                            <div
                                className="list-item"
                                key={id}
                                onMouseEnter={this.handleMouse(true)}
                                onMouseLeave={this.handleMouse(false)}
                            >
                                <input
                                    type="checkbox"
                                    checked={isChecked}
                                    onClick={this.changeSelect(id)}
                                    name={name}
                                    value={value}
                                    id={id}
                                 />
                                <label htmlFor={id}>{name}</label>
                                <button style={{ display: 'none' }} className="delBtn" onClick={this.delList(id)}>删除
                                </button>
                            </div>
                        )
                    })}
                </div>
                <div className="foo">
                    <input type="checkbox" value="" ref={this.selectAllBox} onClick={this.selectAll} />
                    <span>已完成{this.state.listData.reduce((result: number, v: IListData) => v.isChecked ? result + 1 : result, 0)} / 全部{this.state.listData.length}</span>
                    <button className="delBtn" onClick={this.delAll}>删除全部已完成</button>
                </div>
            </div>
        )
    }
}

export default ToDoList as any
```

### ToDoList.scss

```scss
#todoList {
  margin: 20px auto;
  width: 500px;
  border: 1px solid #ccc;
  padding: 10px;
  border-radius: 5px;

  .add-input {
    width: 100%;
    height: 40px;
    line-height: 40px;
    padding-left: 10px;
    outline: none;
    border: 1px solid #ccc;
    margin-bottom: 10px;
    box-sizing: border-box;

    &:focus {
      box-shadow: 0 0 5px #0097ff;
    }
  }

  .list-box {
    display: flex;
    flex-flow: column;
    border: 1px solid #ccc;
    border-bottom: none;

    .list-item {
      border-bottom: 1px solid #ccc;
      height: 40px;
      line-height: 40px;
      padding-left: 5px;
      position: relative;

      label {
        margin-left: 5px;
        cursor: pointer;
      }
      input{
        cursor: pointer;
      }
    }
  }

  .foo {
    margin: 20px 5px;
    position: relative;

    span {
      margin-left: 30px;
    }
  }
  .delBtn{
    background: #cc0019;
    color: #fff;
    border: none;
    border-radius: 6px;
    padding: 5px 15px;
    position: absolute;
    right: 5px;
    top: 50%;
    cursor: pointer;
    transform: translate(0, -50%);

    &:active{
      transform: scale(0.95) translate(0, -51%);
    }
  }
}
```

## 路由实现

### 底层

#### 历史模式（history）

路由是怎么判断刷新和记录的？

利用windom中的history属性可以记录，回到上个页面等操作

存储的结构类似栈结构，后进先出

学习实现基础可以使用`history.js`（原生的api不好用）

#### 哈希模式（Hash）

这个模式就没有用到dom中的history记录，主要就是类似锚点跳转，所以路由后都会有`#`

优点：兼容性极佳

### 下载

```bash
yarn add react-router-dom
# or
npm i react-router-dom
```

### 引入使用

```tsx
<BrowserRouter>
    <div className="aside">
        {/* 路由跳转 */}
        <Link to="/about" className="menu-item">
            About
        </Link>
        <Link to="/home" className="menu-item">
            Home
        </Link>
    </div>
    <div className="container">
        {/* 注册路由 */}
        <Routes>
            <Route path="/about" element={<About />} />
            <Route path="/home" element={<Home />} />
        </Routes>
    </div>
</BrowserRouter>
```

> `Link`和`Route`标签都需要在一个`Router`中，引入的依赖如下：
>
> ```tsx
> import { Link, BrowserRouter, Route } from 'React-Router-Dom'
> import About from '../About'
> import Home from '../Home'
> ```
>
> `About`和`Home`是路由组件，存放在 src / pages 下
>
> 这里的`Route`标签中的`element`属性是`react-router-dom 6.0`以上新版本写法，并且需要`Routes`标签，旧版如下：
>
> ```tsx
> {/* 注册路由 */}
> <Route path="/about" component={About} />
> <Route path="/home" component={Home} />
> ```

又由于所有的页面都需要套一个`Router`控制，所以这个`BrowserRouter`标签就可以写在`main.tsx`中，直接给App组件套上

```tsx
import React from 'react'
import { createRoot } from 'react-dom/client'
import App from './App'
import { BrowserRouter } from 'react-router-dom'

const dom = document.getElementById('root') as HTMLElement
createRoot(dom).render(
    <React.StrictMode>
        <BrowserRouter>
            <App />
        </BrowserRouter>
    </React.StrictMode>
)
```

### Link 和 NavLink

共同点：都是用来跳转的

区别：NavLink 在style和className上支持函数形式

#### 使用NavLink做访问后的样式

新版本：

```tsx
<div className="aside">
    {/* 路由跳转 */}
    <NavLink
        to="/about" 
        className={({ isActive }) => (isActive ? 'menu-item link-active' : 'menu-item')}
    >
        About
    </NavLink>
    <NavLink 
        to="/home" 
        className={({ isActive }) => (isActive ? 'menu-item link-active' : 'menu-item')}
    >
        Home
    </NavLink>
</div>

{/* 或者使用style */}
<div className="aside">
    <NavLink 
        to="/home" 
        className="menu-item"
        style={({ isActive }) => (isActive ? { background: '#787878', color: '#fff' } : {})}
    >
        Home
    </NavLink>
    <NavLink
        to="/about"
        className="menu-item"
        style={({ isActive }) => (isActive ? { background: '#787878', color: '#fff' } : {})}
    >
        About
    </NavLink>
</div>
```

>  在NavLink标签中`style`和`className`都可以写成一个函数，回调参数是一个包含`isActive`的对象，解构出来就可以根据是否正在访问返回对应的样式`
>
> 旧版本写法如下：
>
> ```tsx
> {/* 旧版本 */}
> <NavLink to="/about" activeClassName="link-active" className="menu-item">About</NavLink>
> <NavLink to="/home" activeClassName="link-active" className="menu-item">Home</NavLink>
> ```
>
> 在旧版本中，默认的`activeClassName`为`active`

#### 二次封装NavLink

```tsx
import React, { Component } from 'react'
import { NavLink } from 'react-router-dom'

interface IProps {
    to: string,
    children?: any
}

class Index extends Component<IProps, any> {
    render () {
        const { to, children } = this.props
        // 使用最后一端的首字母大写
        const paths = to.split('/')
        const title = paths[paths.length - 1].slice(0, 1).toUpperCase() + paths[paths.length - 1].slice(1).toLowerCase()
        // 如果标签体没有内容，就使用默认title
        const copyProps = { ...this.props, children: children || title }
        return (
            <>
                <NavLink
                    className={({ isActive }) => (isActive ? 'menu-item link-active' : 'menu-item')}
                    {...copyProps}
                >
                </NavLink>
            </>
        )
    }
}

export default Index

```

> 对于`NavLink`标签，显示的文字不一定要放在标签体，放在`children`也可以，所以从props中传的`children`可以直接解构使用

使用：

```tsx
<div className="aside">
    <MyNavLink to="/about">againAbout</MyNavLink>
    <MyNavLink to="/home" />
</div>
```

> 对于标签体内容，子组件接收的方式是放在`props`的`children`属性中

### Switch使用（旧版本）

在旧版本的时候，使用多个`route`标签注册路由的时候，在同`path`属性时，会将匹配的页面全部显示

解决办法：使用switch标签包裹即可

```tsx
<Switch>
    <Route path='/about' component={About} />
    <Route path='/home' component={Home} />
</Switch>
```

> path 和 component 是一对一的关系
>
> 使用Switch标签可以提高路由效率（单一匹配）
>
> 在新版本中已经弃用，直接正常使用路由即可

### 样式丢失bug（旧版本）

对于多级路由的情况下，刷新时如果使用的相对路径的css就会出现样式丢失的问题，因为多级路径下，相对路径的请求会也会带上上一级路由，然后找不到请求路径，自动跳转到`public`的`index.html`下

解决办法：换为绝对路径，如：`'./css/bootstrap.css'` 改为 `‘/css/bootstrap.css’`或`%PUBLIC_URL%/css/bootstrap.css%`

### 路由模糊与精准匹配

旧版本中路由默认匹配就是模糊匹配，如下：

```tsx
<MyNavLink to="/FSAN/home" />
<Route path='/FSAN' component={Home} />
```

这样是可以正常显示`Home`组件的

但是在新版本中默认就是校准匹配，如上的`path`是匹配不到的

旧版本使用`exact`属性开启精准匹配

```tsx
<Route exact path='/home' component={Home} />
```

> 默认为`exact={true}`，可以省略

### 路由重定向

```tsx
<Routes>
    <Route path="/about" element={<About  />} />
    <Route path="/home" element={<Home  />} />
    <Route path="*" element={<Navigate to="/about" />} />
</Routes>
```

> 使用`Navigate`标签是新版本的写法， `Routes`标签下面只能使用`Route`标签，将`path=“*”`匹配全部，进行兜底跳转
>
> 旧版本写法如下：
>
> ```tsx
> <Route exact={true} path='/home' component={Home} />
> <Redirect to="/about" />
> ```

### 子组件

先在`Routes`中使用`Route`标签注册路由，然后再包含子组件的页面中需要展示的地方使用`Outlet`标签

```tsx
<Routes>
    <Route path="/about" element={<About />} />
    <Route path="/home" element={<Home />} >
        <Route path="news" element={<News />} />
        <Route path="message" element={<Message />} />
        <Route path="" element={<Navigate to="news" />} />
    </Route>
    <Route path="*" element={<Navigate to="/about" />} />
</Routes>
```

> 这里在`home`组件中注册了两个子路由，并且在点击`home`时重定向到  `/home/news`

Home页面：

```tsx
import React, { Component } from 'react'
import './index.scss'
import { NavLink, Outlet } from 'react-router-dom'

class Index extends Component {
    render () {
        return (
            <>
                我是Home的内容
                <div className="home-header">
                    <NavLink
                        className={({ isActive }) => 'tab-title ' + (isActive ? 'tab-active' : '')}
                        to="news"
                    >News</NavLink>
                    <NavLink
                        className={({ isActive }) => 'tab-title ' + (isActive ? 'tab-active' : '')}
                        to="message"
                    >Message</NavLink>
                </div>
                <div className="home-content">
                    <Outlet />
                </div>
            </>
        )
    }
}

export default Index
```

> 1. 先使用`Route`嵌套标签注册路由
> 2. 在父组件要显示子组件的位置使用`Outlet`标签

### 路由传参

#### params参数（路径传递）

父组件（跳转的时候直接拼接到路径上就行了）：

```tsx
import React, { Component } from 'react'
import { Outlet, Link } from 'react-router-dom'

interface IDetail {
    id: number,
    title: string
}

interface IState {
    detailData: IDetail[]
}

class Index extends Component<any, IState> {
    state = {
        detailData: [
            {
                id: 1,
                title: 'msg001'
            },
            {
                id: 2,
                title: 'msg002'
            },
            {
                id: 3,
                title: 'msg003'
            }
        ]

    }

    render () {
        const { detailData } = this.state
        return (
            <div>
                这是Message组件
                <ul>
                    {
                        detailData.map(v => (
                            <li key={v.id}>
                                <Link to={`${v.id}/${v.title}`}>{v.title}</Link>
                            </li>
                        ))
                    }
                </ul>
                <div style={{ margin: '30px' }}>
                    <Outlet />
                </div>
            </div>
        )
    }
}

export default Index
```

> 这里`Link`中的`to`属性如： `1/msg001`

如果路由需要在路径上携带参数，那么注册时就需要这样写

```tsx
<Route path="message" element={<Message />} >
    <Route path=":id/:title" element={<Detail />} />
</Route>
```

使用冒号后面跟着参数表示接收一个参数

在`Detail`页面就需要使用`hook`钩子获取到传递过来的参数

```tsx
import { useParams } from 'react-router-dom'

const Index = () => {
    const params = useParams()
    console.log(params)
    return (
        <div>
            <p>ID: {params.id}</p>
            <p>TITLE: {params.title}</p>
        </div>
    )
}

export default Index
```

> 在v6中，获取路由中传递的参数只能通过使用`hook`获取
>
> 旧版本获取是放在`props`下的`match`当中的，只能自己从`urlencoded`格式获取数据

#### search参数（问号拼接传递）

同样将参数拼接到路径上即可

```tsx
<ul>
    {
        detailData.map(v => (
            <li key={v.id}>
                <Link to={`detail?id=${v.id}&title=${v.title}`}>{v.title}</Link>
            </li>
        ))
    }
</ul>
```

注册路由的时候就不需要额外的操作，正常注册即可

```tsx
<Route path="message" element={<Message />}>
    {/* 使用params参数接收 */}
    {/* <Route path=":id/:title" element={<Detail />} /> */}
    <Route path="detail" element={<Detail />} />
</Route>
```

接收参数使用`hook`中的`useSearchParams`

```tsx
import { useSearchParams } from 'react-router-dom'

const Index = () => {
    // const { id, title } = useParams()
    const [searchParams] = useSearchParams()
    const detailContent = [
        {
            id: 1,
            content: 'FSAN1'
        },
        {
            id: 2,
            content: 'FSAN2'
        },
        {
            id: 3,
            content: 'FSAN3'
        }
    ]
    const { content } = detailContent.find(v => v.id === Number(searchParams.get('id'))) as any

    return (
        <div>
            <p>ID: {searchParams.get('id')}</p>
            <p>TITLE: {searchParams.get('title')}</p>
            <p>CONTENT: {content}</p>
        </div>
    )
}

export default Index
```

> 需要结构出第一个函数，使用第一个函数的`get`方法获取对于数据
>
> 旧版本数据是放在`props`下的`location`中的，并且需要自己从 `urlencoded` 格式中获取
>
> ```tsx
> const swapUrlEncoded = (obj: object | string) => {
>     if (typeof obj === 'object') {
>         return Object.entries(obj).map(v => `${v[0]}=${v[1]}`).join('&')
>     }
>     const result: {[k: string]: any} = {}
>     obj.split('&').forEach(v => {
>         result[v.split('=')[0]] = v.split('=')[1]
>     })
>     return result
> }
> swapUrlEncoded('id=1&title=主题&content=传递内容')
> ```

#### state参数（对象传递）

特点：传递的参数不会在路径中显示出来

注册路由的时候也不用额外操作，正常注册即可

```tsx
<Route path="message" element={<Message />}>
    {/* 使用params传递参数 */}
    {/* <Route path=":id/:title" element={<Detail />} /> */}
    {/* 使用search或state传递参数 */}
    <Route path="detail" element={<Detail />} />
</Route>
```

传递参数时使用state属性传递一个对象

```tsx
<Link to={'detail'} state={{ id: v.id, title: v.title }}>{v.title}</Link>
```

> 在旧版本中是这样写的：
>
> ```tsx
> <Link to={{ pathname: 'detail', state: { id: v.id, title: v.title } }}>{v.title}</Link>
> ```

使用`useLocation`接收参数：

```tsx
import { useLocation } from 'react-router-dom'

const Index = () => {
    const stateParams = useLocation()
    const { id, title }: any = stateParams.state
    console.log(stateParams)

    const detailContent = [
        {
            id: 1,
            content: 'FSAN1'
        },
        {
            id: 2,
            content: 'FSAN2'
        },
        {
            id: 3,
            content: 'FSAN3'
        }
    ]
    const { content } = detailContent.find(v => v.id === Number(id)) as any

    return (
        <div>
            <p>ID: {id}</p>
            <p>TITLE: {title}</p>
            <p>CONTENT: {content}</p>
        </div>
    )
}

export default Index
```

> 旧版本中参数在`props`下`location`中的`state`中

页面刷新的时候，会发现数据还在，原理：我们用的是`BrowserRouter`路由模式，`state`属性放在浏览器的`history`中，`history`中的数据是一直被记录的，但是当清空了浏览器缓存的时候，数据就没了

### 路由覆盖

当我们点击一个路由后，会在栈结构中添加一个路由记录，使用浏览器回退的时候，回退顺序就是根据这个栈结构回退的，要是想让当前路由记录被新增的路由记录覆盖，也就是回退不到上一个页面，使用`replace`属性即可

```tsx
<Link replace to={'detail'} state={{ id: v.id, title: v.title }}>{v.title}</Link>
```

### 编程式导航

```tsx
import { useNavigate } from 'react-router-dom'
const navigate = useNavigate()
// ... 
// params带参
navigate('1/FSAN1')
// search带参
navigate('?id=1&title=FSAN1')
// state带参
navigate('', { state: { id: 1, title: 'FSAN1' } })
```

> 匿名跳转（路由覆盖自己去看`useNavigate`，有个配置对象），回退就直接写数字即可，如`navigate(-1)`
>
> 在旧版本中，需要使用`props`中的`location`对象实现，对于非路由组件，一般组件想要使用路由跳转时，需要使用`withRouter`包裹组件，如下：
>
> ```tsx
> import { withRouter } from 'react-router-dom'
> export default withRouter(Index)
> ```

## 使用UI组件库
### [Material-ui](https://mui.com/zh/material-ui/getting-started/overview/)

material-ui是一个国外的react ui库，使用较为繁琐

### [Ant-design](https://ant.design/index-cn)

ant-design 是由国内蚂蚁金服出的，下列记录基于这个UI库（简称`antd`）

### 下载

```cmd
yarn add antd
# or
npm i antd -D
```

### 导入并使用

在`main.tsx`中先引入`css`文件

```tsx
// main.tsx
import React from 'react'
import { createRoot } from 'react-dom/client'
import App from './App'
import { BrowserRouter } from 'react-router-dom'
import 'antd/dist/antd.css'

const dom = document.getElementById('root') as HTMLElement
createRoot(dom).render(
    <React.StrictMode>
        <BrowserRouter>
            <App />
        </BrowserRouter>
    </React.StrictMode>
)
```

页面中直接使用

```tsx
import React, { Component } from 'react'
import { Button } from 'antd'
class App extends Component {
    render () {
        return (
            <div>
                <Button type="primary">这是一个ant的组件</Button>
            </div>
        )
    }
}

export default App
```

### CRA项目css按需引入

对于CRA（create-react-app）项目来说，可以直接使用官网提供的carco插件进行配置，但我是使用vite构建的，目前暂没找到配置步骤

#### 下载craco

```bash
yarn add @craco/craco
# or
npm i @craco/craco -D
```

#### 修改配置项

```json
/* package.json */
"scripts": {
-   "start": "react-scripts start",
-   "build": "react-scripts build",
-   "test": "react-scripts test",
+   "start": "craco start",
+   "build": "craco build",
+   "test": "craco test",
}
```

#### 创建配置文件

在根目录下创建`craco.config.js`

```js
/* craco.config.js */
module.exports = {
  // ...
};
```

#### 下载babel-plugin-import

`babel-plugin-import`是一个用于按需加载组件代码和样式的 babel 插件

```bash
yarn add babel-plugin-import
```

#### 在`craco.config.js`中配置如下：

```js
module.exports = {
    babel: {
        plugins: [['import', {
            libraryName: 'antd',
            libraryDirectory: 'es',
            style: 'css',
        }]],
    },
};
```

### Vite项目css按需引入

删除在`main.tsx`中的全局引入样式

#### 下载vite-plugin-imp

```bash
yarn add vite-plugin-imp
```

#### 下载less

因为antd的默认样式文件是less文件，编译需要使用less

```bash
yarn add less
```

####  修改vite.config.ts

```ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import eslintPlugin from 'vite-plugin-eslint'
import vitePluginImp from 'vite-plugin-imp'

// https://vitejs.dev/config/
export default defineConfig({
    plugins: [
        react(),
        eslintPlugin({
            include: ['src/**/*.tsx', 'src/**/*.ts', 'src/*.ts', 'src/*.tsx']
        }),
        vitePluginImp({
            libList: [
                {
                    libName: 'antd',
                    style: (name) => `antd/es/${name}/style`
                }
            ]
        })
    ],
    css: {
        preprocessorOptions: {
            less: {
                javascriptEnabled: true,
                modifyVars: {
                    '@primary-color': '#4377FE'// 设置antd主题色
                }
            }
        }
    },
    server: {
        proxy: {
            '/api': {
                target: 'http://localhost:5000'
            }
        }
    }
})

```

添加上`css`，`vitePluginImp`

## 打包后使用serve服务器启动

### 下载

```bash
npm i serve -g
```

> 尝试了使用yarn，结果不行，可能要自己配置环境变量

### 启动打包后的文件

```bash
cd dist
serve
```

