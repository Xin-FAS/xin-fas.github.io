---
title: Redux
date: 2022-07-27 09:16:08
tags: [redux,react]
categories: [[前端]]
---

## Redux介绍

redux是一个专门用来做状态管理的JS库（不是react插件库），前端三大框架都可以使用，但基本和react配合使用，[点击进入官方文档](https://redux.js.org/)

使用条件：

1. 某个组件的状态，需要让其他组件可以随时拿到（共享）
2. 一个组件需要改变另一个组件的状态（通信）
3. 总体原则：能不用就不用，如果不用比较吃力才考虑使用

## 三大核心属性

### action

一个js对象，包含两个属性：

* type：标识属性，值是字符串。多个type用action分开
* payload：数值属性，可选。表示本次动作携带的数据

> 必须带有`type`属性，只是说明有事情发生了这件事，并没有说明应该如何跟更新state

### reducer

一个纯函数，作用：

* 初始化状态
* 修改状态

根据传入的旧状态和action，返回新状态

> `(previousState, action) => newState`

### store

仓库，redux的核心，整合action和reducer

特点：

1. 一个应用只有一个store
2. 获取状态：`store.getState()`
3. 创建`store`时接收`reducer`作为参数：`const store = createStore(reducer)`
4. 发起状态更新时，需要分发action：`store.dispatch(action)`

> 监听状态变化：`const unSubscribe = store.subscribe(() => {})`
>
> 取消监听：`unSubscribe()`

## 下载

```bash
yarn add redux
# or
npm i redux -S
```

## 使用Redux

### 创建store（主要仓库）

新建 `redux / store.ts`

```ts
import { createStore } from 'redux'
import countReducer from './reducers/countReducer'

const store = createStore(countReducer)

export default store
```

> 在react18版本，`createStore`已被标记为弃用，新用法需要用到`redux-thunk`这个中间件（见下面的异步action）

#### 使用RTK（Redux Toolkit）

##### 下载

```bash
npm i @reduxjs/toolkit
# or
yarn add @reduxjs/toolkit
```

##### 创建store对象

```ts
import { configureStore } from '@reduxjs/toolkit'
import countReducer from './reducers/countReducer'

const store = configureStore({
    reducer: countReducer
})

export default store
```

### 创建reducers（执行函数）

新建 `redux / reducers / countReducer.ts`

```ts
export default (state: number = 0, action: {type: string, data: any}) => {
    const { type, data } = action
    console.log(state, action)
    switch (type) {
    case '+':
        return state + data
    case '-':
        return state - data
    default:
        return state
    }
}
```

> 1. state 当前的state树
> 2. action 要处理的行为
> 3. 返回新的state树

### 获取state的值

```js
import store from '../../redux/store'
store.getState()
```

### 使用reducers函数更新state

```js
import store from '../../redux/store'
store.dispatch({ type: '+', data: 1 })
```

> 但是注意：就算更新state中的数据，dom也不会刷新，需要手动监听后刷新

### 手动监听渲染

直接在`main.tsx`中建立redux的监听即可

```tsx
import React from 'react'
import { createRoot } from 'react-dom/client'
import App from './App'
import { BrowserRouter } from 'react-router-dom'
import store from './redux/store'

const rootDom = createRoot(document.getElementById('root') as HTMLElement)

const render = () => {
    rootDom.render(
        <React.StrictMode>
            <BrowserRouter>
                <App />
            </BrowserRouter>
        </React.StrictMode>
    )
}
// 初次渲染
render()
// 监听redux中的状态改变重新渲染
store.subscribe(render)
```

### 小案例

计数器：

```tsx
// Count -> index.tsx
import { Button } from 'antd'
import store from '../../redux/store'

const Count = () => {
    // select标签ref对象
    let selectRef: HTMLSelectElement
    // 操作集合
    const handler: { [k: string]: () => void } = {
        '+' () {
            changeState('+')
        },
        '-' () {
            changeState('-')
        },
        'odd+' () {
            const state = store.getState()
            console.log('当前为：', state)
            if (state % 2 === 1) changeState('+')
        },
        async 'async+' () {
            changeState('+')
        }
    }
    // 改变redux中状态
    const changeState = (type: string) => {
        store.dispatch({ type, data: Number(selectRef.value) })
    }

    return (
        <div>
            <h1>当前求和为：{store.getState()}</h1>
            <select ref={(e: HTMLSelectElement) => {
                selectRef = e
            }}
            >
                <option value="1">1</option>
                <option value="2">2</option>
                <option value="3">3</option>
            </select>
            <Button onClick={handler['+']}>+</Button>
            <Button onClick={handler['-']}>-</Button>
            <Button onClick={handler['odd+']}>当前求和为奇数再加</Button>
            <Button onClick={handler['async+']}>异步加</Button>
        </div>
    )
}

export default Count
```

```ts
// redux -> reducers -> countReducer.ts
export default (state: number = 0, action: {type: string, data: any}) => {
    const { type, data } = action
    console.log(state, action)
    switch (type) {
    case '+':
        return state + data
    case '-':
        return state - data
    default:
        return state
    }
}
```

```ts
// redux -> store.ts
import { createStore } from 'redux'
import countReducer from './reducers/countReducer'

const store = createStore(countReducer)

export default store
```

### 完善结构

#### 封装类型ts文件

```ts
// src -> typeFile.ts
import { Dispatch } from 'react'

export interface IAction<T> {
    type: string,
    data: T
}

type IAsyncActionFn<T> = (dispatch: Dispatch<IAction<T>>) => void

export interface ICreateAction<T> {
    [k: string]: (data: T) => (IAction<T> | IAsyncActionFn<T>)
}

export interface IReducerHandle<T> {
    [k: string]: (state: T, data: T) => T
}
```

#### 封装type常量文件

```ts
// src -> redux -> typeConstant.ts
export const INCREASE = 'increase'
export const DECREASE = 'decrease'
```

#### 用于创建action的文件

```ts
// redux -> countActionCreator.ts
import { Dispatch } from 'react'
import { IAction, ICreateAction } from '../../typeFile'
import { INCREASE, DECREASE } from '../typeConstant'

export default {
    increase: data => ({ type: INCREASE, data }),
    decrease: data => ({ type: DECREASE, data })
} as ICreateAction<number>
```

#### reducer执行文件

```ts
// redux -> reducers -> countReducer.ts
import { INCREASE, DECREASE } from '../typeConstant'
import { Reducer } from 'redux'
import { IAction, IReducerHandle } from '../../typeFile'

const handle: IReducerHandle<number> = {
    [INCREASE]: (state, data) => state + data,
    [DECREASE]: (state, data) => state - data
}

export default ((state = 0, action) => {
    const { type, data } = action
    if (handle[type]) return handle[type](state, data)
    return state
}) as Reducer<number, IAction<number>>

/**
 * 传统switch
 */
// switch (type) {
// case INCREASE:
//     return state + data
// case DECREASE:
//     return state - data
// default:
//     return state
// }
```

### 异步action

同步action就只是封装返回一个有type和data属性的对象

异步action就是返回一个函数，但是需要引入中间件，因为action只能为一个简单的object对象，需要使用中间件配置store

#### 配置中间件

##### 下载中间件

```bash
npm install redux-thunk
# or
yarn add redux-thunk
```

##### 在store.ts中配置

```ts
import { configureStore, applyMiddleware } from '@reduxjs/toolkit'
import countReducer from './reducers/countReducer'
import thunk from 'redux-thunk'

const store = configureStore({
    reducer: countReducer,
    enhancers: [applyMiddleware(thunk)]
})

export default store
```

> 这里用的是RTK（redux toolkit），不知道的[点击此处查看](#使用RTK（Redux-Toolkit）)
>
> 但不知道为什么，我不配置发现也可以正常使用

#### 创建异步action

```ts
import { Dispatch } from 'react'
import { IAction, ICreateAction } from '../../typeFile'
import { INCREASE, DECREASE } from '../typeConstant'

const creatorAction: ICreateAction<number> = {
    increase: data => ({ type: INCREASE, data }),
    decrease: data => ({ type: DECREASE, data }),
    asyncIncrease: data => (dispatch: Dispatch<IAction<number>>) => {
        setTimeout(() => {
            dispatch(creatorAction.increase(data) as IAction<number>)
        }, 1000)
    }
}
export default creatorAction
```

> 返回的回调函数中第一个参数为`dispatch`
>
> 这样调用：
>
> ```ts
> changeState(countAction.asyncIncrease)
> 
> // 根据选中值改变redux中状态
> const changeState = (actionFn: Function) => {
>     store.dispatch(actionFn(Number(selectRef.value)))
> }
> ```

## 使用React-Redux

react看在项目都使用redux状态管理，所以自己出了一个库，就叫[react-redux](https://react-redux.js.org/)，配合原生`redux`使用

### 介绍

1. 所有的UI组件都应该包裹一个容器组件，他们是父子关系
2. 容器组件是真正和redux打交道的，里面可以随意的使用redux的api
3. UI组件中不能使用任何redux的api
4. 容器组件可以传给UI组件的东西
   1. redux中所保存的状态
   2. 用于操作状态的方法
5. 备注：容器给UI传递：状态，操作状态的方法，均通过props传递

### 下载

```bash
npm install react-redux
# or
yarn add react-redux
```

### 创建容器组件

创建 `src/containers/Count/index.ts`

```ts
import Count from '../../components/Count'
import { connect } from 'react-redux'
export default connect()(Count)
```

> 就相当于使用react-redux对UI组件进行了封装，在外面套了层容器
>
> 注意点： 
>
> 1. UI组件中不可出现redux的API，如`store.getState()`
> 2. 容器要有store属性，绑定你的store对象，如下

将渲染的组件从UI组件改为容器组件并为容器组件传递store对象（没有会报错）

```tsx
// App.tsx
import React, { Component } from 'react'
import Count from './containers/Count'
import store from './redux/store'

class App extends Component {
    render () {
        return (
            <div>
                <Count store={store} />
            </div>
        )
    }
}

export default App
```

> 使用了connect连接之后就相当于UI组件变成了容器组件的子组件

### 使用容器组件向UI组件传递状态和函数

在connect方法第一次调用时传递参数即可，在标签处只能使用store

```ts
import Count from '../../components/Count'
import { connect } from 'react-redux'

const stateObject = () => ({
    myName: 'F_SAN'
})

const fnObject = () => ({
    getName: () => '名字为F_SAN'
})

export default connect(stateObject, fnObject)(Count)
```

> connect两个参数返回的都是一个简单对象，第一个传递状态，第二个传递函数

### UI组件接收参数和函数对象

对于class组件来说，直接使用props就可以接收到，对于函数式组件来说，写在第一个参数接收

```tsx
interface IProps {
    myName: string,
    getName(): string
}
const Count = (props: IProps) => {
    const { myName, getName } = props
    console.log(myName, getName())
    
    ...
```

### 修改计数器案例

封装类型接口

```ts
export interface IStateObject {
    count: number
}

export interface IFnObject {
    increase(insertValue: number): void

    decrease(insertValue: number): void

    asyncIncrease(insertValue: number): void
}

export interface IProps extends IStateObject, IFnObject {
}
```

在容器组件中添加获取当前计数器和插入删除api

```ts
import Count from '../../components/Count'
import { connect } from 'react-redux'
import countActionCreator from '../../redux/action/countActionCreator'
import { IStateObject, IFnObject } from '../../typeFile'
import { Dispatch } from 'react'

// 接收的参数即是自动调用的store.getState()
const stateObject = (state: any) => ({
    // 当前redux中的计数值
    count: state
}) as IStateObject

// 接收的参数就是store中的dispatch函数
const fnObject = (dispatch: Dispatch<any>) => ({
    // 通知redux执行增加操作
    increase: insertValue => {
        dispatch(countActionCreator.increase(insertValue))
    },
    // 通知redux执行删除操作
    decrease: insertValue => {
        dispatch(countActionCreator.decrease(insertValue))
    },
    // 异步增加
    asyncIncrease: insertValue => {
        dispatch(countActionCreator.asyncIncrease(insertValue))
    }
}) as IFnObject

export default connect(stateObject, fnObject)(Count)
```

> 所以这里是不需要引用store的，在connect中都封装好了，这里对于fnObject有一个最简的写法（默认分发），直接写成一个对象，而不是返回一个对象
>
> ```ts
> /**
>  * 使用dispatch分发的最简形式，自动使用dispatch调用函数返回值
>  */
> const { increase, decrease, asyncIncrease } = countActionCreator
> const fnObject = {
>     increase,
>     decrease,
>     asyncIncrease
> } as any
> 
> export default connect(stateObject, fnObject)(Count)
> ```

修改后的UI组件：

```tsx
import { Button } from 'antd'
import { IProps } from '../../typeFile'

const Count = (props: IProps) => {
    const { count, increase, decrease, asyncIncrease } = props
    // select标签ref对象
    let selectRef: HTMLSelectElement
    // 操作集合
    const handler: { [k: string]: () => void } = {
        increase () {
            increase(Number(selectRef.value))
        },
        decrease () {
            decrease(Number(selectRef.value))
        },
        increaseByOdd () {
            console.log('当前为：', count)
            if (count % 2 === 1) increase(Number(selectRef.value))
        },
        asyncIncrease () {
            asyncIncrease(Number(selectRef.value))
        }
    }

    return (
        <div>
            <h1>当前求和为：{count}</h1>
            <select ref={(e: HTMLSelectElement) => {
                selectRef = e
            }}
            >
                <option value="1">一</option>
                <option value="2">二</option>
                <option value="3">三</option>
            </select>
            <Button onClick={handler.increase}>+</Button>
            <Button onClick={handler.decrease}>-</Button>
            <Button onClick={handler.increaseByOdd}>当前求和为奇数再加</Button>
            <Button onClick={handler.asyncIncrease}>异步加</Button>
        </div>
    )
}

export default Count
```

> 之前使用redux 的时候，状态发生改变后，页面并不会重新渲染，手动监听当时的代码是这样的：
>
> ```tsx
> const rootDom = createRoot(document.getElementById('root') as HTMLElement)
> 
> const render = () => {
>     rootDom.render(
>         <React.StrictMode>
>             <BrowserRouter>
>                 <App />
>             </BrowserRouter>
>         </React.StrictMode>
>     )
> }
> // 初次渲染
> render()
> // 监听redux中的状态改变重新渲染
> store.subscribe(render)
> ```
>
> 但是，用了react-redux之后，因为是react自己出的，当容器组件的状态发生改变，会自动的渲染一次到UI组件上，就可以省略监听的代码了

### 自动传递store属性（Provider）

对于很多容器组件都需要传递store时，如下写法会太麻烦：

```tsx
import React, { Component } from 'react'
import Count from './containers/Count'
import store from './redux/store'

class App extends Component {
    render () {
        return (
            <div>
                <Count store={store} />
                <Count store={store} />
                <Count store={store} />
                <Count store={store} />
                <Count store={store} />
                <Count store={store} />
            </div>
        )
    }
}

export default App
```

所以就有了`Provider`，我们只需要在main.tsx中将App整个套起来，它就可以自动为每个容器组件加上store属性

```tsx
import React from 'react'
import { createRoot } from 'react-dom/client'
import App from './App'
import { BrowserRouter } from 'react-router-dom'
import { Provider } from 'react-redux'
import store from './redux/store'

const rootDom = createRoot(document.getElementById('root') as HTMLElement)

rootDom.render(
    <React.StrictMode>
        <Provider store={store}>
            <BrowserRouter>
                <App />
            </BrowserRouter>
        </Provider>
    </React.StrictMode>
)
```

### 容器组件和UI组件结构优化

写成多个文件，会使以后的文件成倍增长，所以可以直接将容器组件和UI组件成为一个文件

```tsx
import { connect } from 'react-redux'
import countActionCreator from '../../redux/action/countActionCreator'
import { IProps } from '../../typeFile'
import { Button } from 'antd'

/**
 * UI 组件
 */
const Count = (props: IProps) => {
    const { count, increase, decrease, asyncIncrease } = props
    // select标签ref对象
    let selectRef: HTMLSelectElement
    // 操作集合
    const handler: { [k: string]: () => void } = {
        increase () {
            increase(Number(selectRef.value))
        },
        decrease () {
            decrease(Number(selectRef.value))
        },
        increaseByOdd () {
            console.log('当前为：', count)
            if (count % 2 === 1) increase(Number(selectRef.value))
        },
        asyncIncrease () {
            asyncIncrease(Number(selectRef.value))
        }
    }

    return (
        <div>
            <h1>当前求和为：{count}</h1>
            <select ref={(e: HTMLSelectElement) => {
                selectRef = e
            }}
            >
                <option value="1">一</option>
                <option value="2">二</option>
                <option value="3">三</option>
            </select>
            <Button onClick={handler.increase}>+</Button>
            <Button onClick={handler.decrease}>-</Button>
            <Button onClick={handler.increaseByOdd}>当前求和为奇数再加</Button>
            <Button onClick={handler.asyncIncrease}>异步加</Button>
        </div>
    )
}

/**
 * 容器组件
 * 使用dispatch分发的最简形式，自动使用dispatch调用函数返回值
 */
const { increase, decrease, asyncIncrease } = countActionCreator

export default connect(
    (state: any) => ({
        // 当前redux中的计数值
        count: state
    }), {
        increase,
        decrease,
        asyncIncrease
    })(Count) as any
```

### 多组件共享状态（combineReducers）

在多个组件下，state就不能是个单一的值，就应该是一个对象，多组件步骤如下

1. store处使用`combineReducers`结合多个`reducers`
2. 修改容器组件内的connect传递正常的对象（可以直接在connect中获取到所有数据）

创建Person组件：

```tsx
import { connect } from 'react-redux'
import { Button } from 'antd'
import { addPerson } from '../../redux/action/personAction'
import { useRef, MutableRefObject } from 'react'

const Index = (props: any) => {
    const { addPerson, person, allAttributes } = props
    console.log(allAttributes)
    const name: MutableRefObject<any> = useRef(null)
    const age: MutableRefObject<any> = useRef(null)
    const addBtn = () => {
        addPerson({
            name: name.current.value,
            age: age.current.value
        })
    }
    return (
        <>
            <hr />
            <h1>
                这是人
            </h1>
            <input type="text" ref={name} placeholder="姓名" />
            <input type="text" ref={age} placeholder="年龄" />
            <Button onClick={addBtn}>添加对象</Button>
            <ul>
                {
                    person.map((v: any) => (
                        <li key={v.id}>{v.name} --- {v.age}</li>
                    ))
                }
            </ul>
        </>
    )
}

export default connect((state: any) => ({
    person: state.person,
    allAttributes: state
}), {
    addPerson
})(Index)
```

将store组合成一个对象：

```ts
import { configureStore, applyMiddleware, combineReducers } from '@reduxjs/toolkit'
import count from './reducers/count'
import person from './reducers/person'
import thunk from 'redux-thunk'

const allRedux = combineReducers({
    count,
    person
})
const store = configureStore({
    reducer: allRedux,
    enhancers: [applyMiddleware(thunk)]
})

export default store
```

Person 的 reducer：

```ts
import { IAction } from '../../typeFile'
import { nanoid } from '@reduxjs/toolkit'

const handler: { [k: string]: (data: any, state: any) => any } = {
    addPerson: (state, data) => [{ id: nanoid(), ...data }, ...state]
}

export default (state: any = [], action: IAction<any>) => {
    const { type, data } = action
    if (handler[type]) {
        return handler[type](state, data)
    }
    return state
}
```

> 在reducer中的state属性是单个组件的

### 总结：

1. 使用`@reduxjs/toolkit`创建store文件（下载`redux-thunk`实现中间件异步，多组件需要使用`combineReducers`组合，将最后的组合对象交给store）
2. 创建reducer处理文件，接收state和action(`{type: xxx, data: xxx}`)，暴露一个函数，返回内容就是该组件使用的state，负责具体任务的执行（调用使用`dispatch(action)`）
3. 创建构建action的封装文件（`actionCreator`），使用常量封装type类型，以防调用错误，至此redux构建结束，开始使用react-redux分割
4. 将普通的组件看作UI组件，不能出现关于redux的api，然后使用connect对UI组件进行包装（connect为高阶函数，第一个方法第一个为参数为暴露的state，第二个为action内容对象或方法对象，第二个方法传入UI组件）
5. 从外面传入store对象，可以使用`Provider`标签自动传递
6. 在UI组件中使用props接收（函数式组件直接写第一个参数接收）

## reducer返回对象注意点：

在reducer中，返回的对象地址不可相同，如向数组中添加一个元素后返回这个数组，不可直接使用push或者unshift添加，必须要返回一个深拷贝的数组

### 错误

```ts
import { IAction } from '../../typeFile'
import { nanoid } from '@reduxjs/toolkit'

const handler: { [k: string]: (data: any, state: any) => any } = {
    addPerson: (state, data) => {
        state.unshift({
            id: nanoid(),
            name: data.name,
            age: data.age
        })
        return state
    }
}

export default (state: any = [], action: IAction<any>) => {
    const { type, data } = action
    if (handler[type]) {
        return handler[type](state, data)
    }
    return state
}
```

### 正确

```ts
import { IAction } from '../../typeFile'
import { nanoid } from '@reduxjs/toolkit'

const handler: { [k: string]: (data: any, state: any) => any } = {
    addPerson: (state, data) => [{ id: nanoid(), ...data }, ...state]
}

export default (state: any = [], action: IAction<any>) => {
    const { type, data } = action
    if (handler[type]) {
        return handler[type](state, data)
    }
    return state
}
```
