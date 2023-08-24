---
title: React Router 6
date: 2022-07-31 15:43:50
tags: [React]
categories: [前端,React]
---

## 介绍

之前记录的react脚手架中，我记录的全是react router 6的用法，这里来统计一下，也详细记录下react-router

### React Router介绍

React Router 以三个不同的报发布到npm上，它们分别为：

1. react-router：路由的核心库，提供了很多的：组件，钩子
2. react-router-dom：包含了react-router所有内容，并添加一些专门用于DOM的组件，例如`<BrowserRouter>`等
3. react-router-native：包含了react-router所有内容，并添加一些专门用于ReactNative的API，例如`<NativeRouter>`等。

相比React Router 5版本，改变了什么

1. 内置组件的变化：移除`<Switch>`，新增`<Routes>`等
2. 语法的变化：`component={About}`变为`element={<About />}`等
3. 新增多个hook：`useParams`，`useNavigate`，`useMatch`等
4. **官方明确推荐使用函数式组件！！**

## 功能点

### BrowserRouter

不演示

### HashRouter

同上

### Link

同上

### NavLink

同上，在5中使用 activeClassName定义当前样式名，6里面想想className和style使用回调函数就能记起来了，建议封装一个方法中，不然太冗余了

属性`end`，默认为false，当有子路由时，使用end属性可以使访问子路由时父路由不高亮

### Routes和Route

```tsx
<Route caseSensitive path="/main" element={<MenuLink />} />
```

> caseSensitive：是否区分大小写，默认不区分，false

其他不演示了

### Navigate

只要渲染就跳转，如下：

```tsx
import { useState } from 'react'
import { Navigate } from 'react-router-dom'

const Index = () => {
    const [sum, setSum] = useState(0)
    return (
        <>
            当sum值为2时自动跳转到home
            <button onClick={() => setSum(sum + 1)}>点击增加</button>
            {sum === 2 ? <Navigate to="/home" /> : <h2>当前sum值为：{sum}</h2>}
        </>
    )
}

export default Index
```

一般用来做路由重定向

```tsx
<Suspense fallback={<h1>Loading ...</h1>}>
    <Routes>
        <Route path="/" element={<Navigate to="/new" />} />
    </Routes>
</Suspense>
```

> ```tsx
> <Navigate to="/home" replace />
> ```
>
> replace为true可以使路由跳转后无法后退

### useRoutes（important！）

使用useRoutes对路由进行对象化，和vue一样

```tsx
const routes = useRoutes([
    {
        path: '/',
        element: <Navigate to="/main" />
    },
    {
        path: '/main',
        element: <MenuLink />
    },
    {
        path: '/my',
        element: <My />
    },
    {
        path: '/plus',
        element: <ComponentPlus />
    },
    {
        path: '/CP',
        element: <ChildrenAndParent />
    },
    {
        path: '/catch',
        element: <Catch />
    },
    {
        path: '/new',
        element: <RouteNew />
    }
]) as ReactElement

...

return (
    <>
        <Suspense fallback={<h1>Loading ...</h1>}>
            {routes}
        </Suspense>
    </>
)
```

> 一般来说可以直接封装出去，单独一个路由文件（感觉回来了！！），注意这里是`element`属性不是`component`😀

在子组件上，直接使用children属性，同vue：

```tsx
{
    path: '/main',
    element: <Main />,
    children: [
        {
            path: 'goA',
            element: <A />
        }
    ]
},
```

### Outlet（important！）

配合嵌套路由使用，定义渲染位置，同vue中的`router-view`

### useParams

接收路由中携带的params参数`/detail/1/FSAN`，注册路由时需要使用`:参数名`

### useMatch

分析一个地址，如：

```tsx
useMatch('/home/message/detail/:id/:title')
```

> 使用`:参数名`支持匹配

### useSearchParams

接收路由中携带的search参数`/detail?id=1&title=FSAN`

```tsx
const [search, setSearch] = useSearchParams()
console.log(search.get('id'))
console.log(search.get('title'))
setSearch('id=2&title=BSAN')
console.log(search.get('id'))
console.log(search.get('title'))
```

> 使用urlEncoded格式的字符串修改search参数

### useLocaltion（important！）

分析当前路由，并且可以从中获取到传递的state数据

```tsx
import { useLocation } from 'react-router-dom'
console.log(useLocation())
```

link传递state数据

```tsx
<Link to="/home" state={{
    id: 1,
    title: 'FSAN'
}}
/>
```

### useNavigate（important！）

```tsx
const navigate = useNavigate()
const toPath = (path:string) => {
    navigate(path)
    // or
    navigate(path, {
        replace: true,
        state: {
            id: 1,
            title: 'FSAN'
        }
    })
    // or
    navigate(-1)
}
```

> 编程式导航，一看就懂了吧

### useNavigationType

返回当前的导航类型（用户是怎么来的）

| 返回值  | 说明                                       |
| ------- | ------------------------------------------ |
| POP     | 在浏览器中直接打开这个路由组件（刷新页面） |
| PUSH    | 通过跳转进来的                             |
| REPLACE | 通过替代当前路由记录进来的（replace）      |

### useOutlet

查看当前渲染的路由组件

### useResolvedPath

给定一个url值，解析其中的path，search，hash值
