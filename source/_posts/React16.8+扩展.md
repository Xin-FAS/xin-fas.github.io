---
title: React16.8+扩展
date: 2022-07-29 22:33:01
tags: [react]
categories: [前端,react]
---

# setState（状态更新）

在类组件中，setState用于更新state中的数据，有以下两种写法：

1. 对象式：`setState(stateChange, [callback])`
   1. stateChange为一个对象，更新后的数据
   2. callback为render调用后执行的回调函数
2. 函数式`setState(updater, [callback])`
   1. updater为一个函数，返回stateChange作为更新后的数据
   2. update可以接收到state和props
   3. callback同上

> 因为react中setState为同步函数，但是由setState引起的修改操作是异步的，如果要获取最新的状态数据，需要在回调函数中读取

```tsx
setCount = () => {
    // 对象式写法
    const { count } = this.state
    this.setState({ count: count + 1 }, () => {
        console.log('状态更新完毕')
    })

    // 函数式写法
    this.setState((state: any, props) => {
        console.log('接收到的参数', props)
        return {
            count: state.count + 1
        }
    }, () => {
        console.log('状态更新完毕')
    })
}
```

> 手动简化函数式写法：
>
> ```tsx
> // 函数式写法
> this.setState(({ count }: { count: number }) => ({ count: count + 1 }), () => {
>     console.log('状态更新完毕')
> })
> ```

对象式写法其实是函数式写法的语法糖，推荐使用条件：

1. 当修改后的状态不需要在state基础上更新时，使用对象式写法
2. 当需要在state基础上更新时，使用函数式

# lazyload（组件懒加载）

lazyload一般来说是对于路由组件使用的，用法如下：

## 不使用懒加载的路由

```tsx
import MenuLink from './components/MenuLink'
import My from './components/My'

...
<Routes>
    <Route path="/" element={<Navigate to="/main" />} />
    <Route path="/main" element={<MenuLink />} />
    <Route path="/my" element={<My />} />
</Routes>
```

## 使用懒加载

1. 引入lazy，用法类似vue3的defineAsyncComponent
2. 将路由标签使用Suspense标签包裹，并指定加载过程显示组件

```tsx
import React, { Component, lazy, Suspense } from 'react'

const MenuLink = lazy(() => import('./components/MenuLink'))
const My = lazy(() => import('./components/My'))

...
<Suspense fallback={<h1>Loading ...</h1>}>
    <Routes>
        <Route path="/" element={<Navigate to="/main" />} />
        <Route path="/main" element={<MenuLink />} />
        <Route path="/my" element={<My />} />
    </Routes>
</Suspense>
```

> fallback可以直接指定一个组件，像这样 `<Suspense fallback={<Loader/>}>`，这里的Loader组件必须先引入，不可懒加载
>
> lazy不可放入函数组件中，会导致浏览器一直处于加载状态

# Hooks

## useState

因为函数式组件中没有state状态，所以需要引入useState创建一个状态管理，如下：

```tsx
// hooks创建state状态和修改函数
const [countNum, setCountNum]: [countNum: number, setCountNum: (num: number) => void] = useState(0)
```

> const [参数名，更新函数名] = useState(初始值)

setCountNum有两个用法：

1. 直接传递更新后的数据
2. 传递一个函数，回调参数为count，返回的是更新后的数据

```tsx
import { useState } from 'react'

type ISetCount<T> = (callback: ((count: T) => T) | number) => void
const Index = (props: any) => {
    const [count, setCount]: [count: number, setCount: ISetCount<number>] = useState(0)

    const addCount = () => {
        setCount(count + 1)
        setCount(count => count + 1)
    }
    return (
        <>
            <h1>当前值为：{count}</h1>
            <button onClick={addCount}>点击增加</button>
        </>
    )
}
```

> 如果使用解构的方式，推荐第一种，因为第一个参数就是count

## useEffect

在React更新DOM后调用

```tsx
import { useEffect, useState } from 'react'

const Count = () => {
    const [num]: [num: number, setNum: (num: number) => void] = useState(0)
    const [age, setAge]: [num: number, setNum: (num: number) => void] = useState(0)

    useEffect(() => {
        console.log('Effect：渲染完毕', num)
        return () => {
            console.log('Effect：销毁完毕', num)
        }
    }, [num, age])
    return (
        <div>
            <button onClick={() => setAge(age + 1)}>修改</button>
        </div>
    )
}

export default Count
```

> 执行顺序，首次渲染时，渲染完毕先执行，然后执行一次销毁完毕，后再次执行渲染完毕
>
> 后续更新渲染时：销毁完毕（可以获取到更新前的state） -> 渲染完毕
>
> useEffect 第二个参数是一个数组，传递的值作为检测值，在后续更新渲染时，检测值发生变化才会触发 useEffect 中的函数，如这里如果比较值只有一个num，则除了第一次渲染会触发函数，后续点击都不会触发，如果是空数组，则只会在第一次渲染render的时候调用一次

### 自动累加器案例

```tsx
import { useEffect, useState } from 'react'
import root from '../../main'

type ISetCount<T> = (callback: ((count: T) => T) | number) => void
const Index = (props: any) => {
    const [count, setCount]: [count: number, setCount: ISetCount<number>] = useState(0)

    let timer: number
    useEffect(() => {
        // 第一次render和后续更新调用
        timer = setInterval(() => {
            setCount(count => count + 1)
        }, 500)
        return () => {
            // 第一次render调用一次，后续组件卸载调用
            clearInterval(timer)
        }
        // 监听数组中的数据，限制发生改变才调用
    }, [])

    const unNode = () => {
        root.unmount()
    }
    return (
        <>
            <h1>当前值为：{count}</h1>
            <button onClick={unNode}>卸载组件</button>
        </>
    )
}
```

## useRef

```tsx
const inputRef = useRef() as MutableRefObject<HTMLInputElement>
console.log(inputRef.current?.value)
return (
    <>
        <h1>当前值为：{count}</h1>
        <input type="text" ref={inputRef} />
    </>
)
```

> 使用`?.`就算value属性为undefined也不会报错

# Fragment

Fragment标签作用就和vue中的template差不多，当你不想要有一个父标签时可以使用，只支持接收一个参数`key`方便遍历

```tsx
const list = [...Array(100).keys()].map(v => ({ id: v, key: 'F_SAN' + v.toString() }))
return (
    <>
        <h1>当前值为：{count}</h1>
        <button onClick={unNode}>卸载组件</button>
        {
            list.map(v => (
                <Fragment key={v.id}>
                    <p>{v.key}</p>
                </Fragment>
            ))
        }
    </>
)

// <p>F_SAN0</p>
// <p>F_SAN1</p>
// <p>F_SAN2</p>
// <p>F_SAN3</p>
// <p>F_SAN4</p>
// ...
```

> 如果这里是div，那么每个p标签都会套上一个div
>
> `[...Array(100).keys()]`用于生成指定长度数组，内容为0-99

# createContext（上下文）

```tsx
import { createContext } from 'react'
import { nanoid } from 'nanoid'

const { Provider, Consumer } = createContext('默认值')
const C = () => {
    return (
        <div style={{ background: '#EFEFEF', padding: '20px' }}>
            <Consumer>
                {
                    value => {
                        const data = JSON.parse(value)
                        return (
                            <table>
                                <thead>
                                    <tr>
                                        <th>姓名</th>
                                        <th>年龄</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {
                                        data.map((v: any) => (
                                            <tr key={v.id}>
                                                <td>{v.name}</td>
                                                <td>{v.age}</td>
                                            </tr>
                                        ))
                                    }
                                </tbody>
                            </table>
                        )
                    }
                }
            </Consumer>
        </div>
    )
}

const B = () => {
    return (
        <div style={{ background: '#D1D1D1', padding: '20px' }}>
            <h2>这是B组件</h2>
            <C />
        </div>
    )
}

const My = () => {
    const tableData = [
        {
            id: nanoid(),
            name: 'F_SAN',
            age: 20
        },
        {
            id: nanoid(),
            name: 'F_SAN1',
            age: 21
        },
        {
            id: nanoid(),
            name: 'F_SAN2',
            age: 22
        }
    ]
    return (
        <div style={{ background: '#C0A080', padding: '20px' }}>
            <h1>这是A组件</h1>
            <div>A组件的name为</div>
            <Provider value={JSON.stringify(tableData)}>
                <B />
            </Provider>
        </div>
    )
}
export default My
```

可以对于子组件对及其以下的全部孙组件的数据传递

> 注意用法：
>
> 1. Provider标签的value属性表示传递数据，也可以为对象或数组，推荐对象写法，解构时无需考虑顺序
> 2. 向下传递的所有子组件都可以使用Consumer标签来接收数据，内容是一个函数，value即使传递的数据

# useContext（使用上下文）

在`createContext`中，传递过去的参数，使用`Consumer`标签接受较为繁琐，所以就有了`useContext`

```tsx
import { createContext, useContext } from 'react'
import { nanoid } from 'nanoid'

const dataContext = createContext('默认值')
const C = () => {
    const value = useContext(dataContext)
    const data = JSON.parse(value)
    return (
        <div style={{ background: '#EFEFEF', padding: '20px' }}>
            <table>
                <thead>
                    <tr>
                        <th>姓名</th>
                        <th>年龄</th>
                    </tr>
                </thead>
                <tbody>
                    {
                        data.map((v: any) => (
                            <tr key={v.id}>
                                <td>{v.name}</td>
                                <td>{v.age}</td>
                            </tr>
                        ))
                    }
                </tbody>
            </table>
        </div>
    )
}

const B = () => {
    return (
        <div style={{ background: '#D1D1D1', padding: '20px' }}>
            <h2>这是B组件</h2>
            <C />
        </div>
    )
}

const My = () => {
    const tableData = [
        {
            id: nanoid(),
            name: 'F_SAN',
            age: 20
        },
        {
            id: nanoid(),
            name: 'F_SAN1',
            age: 21
        },
        {
            id: nanoid(),
            name: 'F_SAN2',
            age: 22
        }
    ]
    return (
        <div style={{ background: '#C0A080', padding: '20px' }}>
            <h1>这是A组件</h1>
            <div>A组件的name为</div>
            <Provider value={JSON.stringify(tableData)}>
                <B />
            </Provider>
        </div>
    )
}
export default My
```

直接将创建出来的上下文对象交给`useContext`，就可以获取到其中的值

# 优化子父组件渲染

状态更新后的重新渲染会非常影响性能，特别是子组件数量多的情况下

## 类式组件优化

### 方法一：自己修改钩子

```tsx
shouldComponentUpdate (nextProps: Readonly<{}>, nextState: Readonly<{}>, nextContext: any): boolean {
    // 判断更新前后状态，相同则不渲染
    return this.state.name !== nextState.name
}
```

### 方法二：使用PureComponent

```tsx
class Index extends PureComponent {
}
```

> 将Component替换为PureComponent，react将自行浅判断

## 函数式组件优化

```tsx
import React, { useState, useEffect, memo } from 'react'

const IndexChildren = (props: any) => {
    useEffect(() => {
        console.log('children render')
    })
    return (
        <>
            <h1>这是子组件</h1>
            <div>从父组件传递的姓名为：{props.name}</div>
        </>
    )
}

const Index = () => {
    const [count, setCount] = useState(0)
    const [name, setName] = useState('')
    useEffect(() => {
        console.log('parent render')
    })
    return (
        <>
            这是父组件当前更新次数为：{count}，当前姓名为：{name}
            <hr />
            <button onClick={() => setCount(count => count + 1)}>更新状态</button>
            <button onClick={() => setName('FSAN')}>更新传递的姓名</button>
            <IndexChildren name={name} />
            <hr />
        </>
    )
}

export default memo(Index)
```

> memo默认只会浅比较props，如果需要定制比较，可以给第二个参数传入函数
>
> ```tsx
> function MyComponent(props) {
>   /* render using props */
> }
> function areEqual(prevProps, nextProps) {
>   /*
>   return true if passing nextProps to render would return
>   the same result as passing prevProps to render,
>   otherwise return false
>   */
> }
> export default React.memo(MyComponent, areEqual);
> ```
>
> 注意：和`shouldComponentUpdate`不同，如果`props`相同则应返回`true`，否则返回`false`。这点二者正好相反。

# 子父组件两种构成方式

## 使用props

```tsx
import { memo } from 'react'

const Parent = (props: any) => {
    return (
        <>
            <h1>这是Parent组件</h1>
            <div>
                下面是子组件
                <hr />
                {props.children}
            </div>
        </>
    )
}

const Children = () => {
    return (
        <>
            <h1>这是子组件</h1>
        </>
    )
}

const Index = () => {
    return (
        <Parent>
            <Children />
        </Parent>
    )
}

export default memo(Index)
```

> 也可以这样直接使用属性传递：
>
> ```tsx
> import { memo } from 'react'
> 
> const Parent = (props: any) => {
>     return (
>         <>
>             <h1>这是Parent组件</h1>
>             <div>
>                 下面是子组件
>                 <hr />
>                 {props.render()}
>             </div>
>         </>
>     )
> }
> 
> const Children = (props: any) => {
>     return (
>         <>
>             <h1>这是子组件</h1>
>         </>
>     )
> }
> 
> const Index = () => {
>     return (
>         <Parent render={Children} />
>     )
> }
> 
> export default memo(Index)
> ```
>
> 使用属性渲染的时候，就可以父组件向子组件传递参数了：
>
> ```tsx
> import { memo } from 'react'
> 
> const Parent = (props: any) => {
>     return (
>         <>
>             <h1>这是Parent组件</h1>
>             <div>
>                 下面是子组件
>                 <hr />
>                 {props.render({
>                     name: 'FSAN'
>                 })}
>             </div>
>         </>
>     )
> }
> 
> const Children = (props: any) => {
>     return (
>         <>
>             <h1>这是子组件</h1>
>             <div>从父组件接收到的参数为：{props.name}</div>
>         </>
>     )
> }
> 
> const Index = () => {
>     return (
>         <Parent render={Children} />
>     )
> }
> 
> export default memo(Index)
> ```

## 直接子组件放入父组件

```tsx
import { memo } from 'react'

const Parent = (props: any) => {
    return (
        <>
            <h1>这是Parent组件</h1>
            <div>
                下面是子组件
                <hr />
                <Children />
            </div>
        </>
    )
}

const Children = () => {
    return (
        <>
            <h1>这是子组件</h1>
        </>
    )
}

export default memo(Parent)
```

> 甚至可以这样：
>
> ```tsx
> <div>
>     下面是子组件
>     <hr />
>     {Children()}
> </div>
> ```
>
> 传递参数：
>
> ```tsx
> import { memo } from 'react'
> 
> const Parent = (props: any) => {
>     return (
>         <>
>             <h1>这是Parent组件</h1>
>             <div>
>                 下面是子组件
>                 <hr />
>                 {Children({
>                     name: 'FSAN'
>                 })}
>             </div>
>         </>
>     )
> }
> 
> const Children = (props:any) => {
>     return (
>         <>
>             <h1>这是子组件</h1>
>             <div>从父组件接收到的参数为：{props.name}</div>
>         </>
>     )
> }
> 
> export default memo(Parent)
> ```

# 错误处理

## 函数式组件

```tsx
const Index = () => {
    // let data = [
    //     {
    //         key: 1,
    //         name: 'FSAN1',
    //         age: 20
    //     },
    //     {
    //         key: 2,
    //         name: 'FSAN2',
    //         age: 22
    //     },
    //     {
    //         key: 3,
    //         name: 'FSAN3',
    //         age: 24
    //     }
    // ]
    const data = ''
    let render
    try {
        render = (
            <>
                {
                    data.map(v => (<p key={v.key}>姓名为：{v.name}; 年龄为：{v.age}</p>))
                }
            </>
        )
    } catch (error) {
        console.log(error)
        render = (
            <h1>发生未知错误！</h1>
        )
    }
    return render
}

export default Index
```

## 类式组件

类式组件可以使用`componentDidCatch`生命周期，它会收集错误，可以返回state对象，最后判断渲染即可

```tsx
class ErrorBoundary extends React.Component {
  state = { 
      hasError: false 
  }

  static getDerivedStateFromError(error) {
    // 更新 state 使下一次渲染能够显示降级后的 UI
    return { hasError: true };
  }

  componentDidCatch(error, errorInfo) {
    // 你同样可以将错误日志上报给服务器
    logErrorToMyService(error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      // 你可以自定义降级后的 UI 并渲染
      return <h1>发生未知错误.</h1>;
    }

    return this.props.children; 
  }
}
```

> 以上是封装好的代码，使用如下：
>
> ```tsx
> <ErrorBoundary>
>     <Header />
> </ErrorBoundary>
> ```

# 组件通信方式总结

1. props：
   1. 普通属性
   2. 渲染函数
2. 消息订阅-发布
   1. pubs-sub，event等
3. 集中式管理
   1. redux，dva等
4. conText（开发用的少，封装用的多）
   1. 生产者-消费者模式
