---
title: react16.x学习
date: 2022-07-08 17:00:45
tags: [react]
categories: [前端,react]
---
# 初识React

相对于js渲染页面来说，react使用空间换取时间，渲染相似数据时，只改变改动的数据

js渲染过程：遍历数据添加dom ——》浏览器dom重新渲染

react渲染过程：遍历数据添加虚拟dom ——》虚拟dom于上次比对，只更新改动的地方 ——》浏览器dom重新渲染

> 以下都是基于React16.x版本开发的单页内容

# Hello, React

创建html，引入`react.development.js`（核心库）和`react-dom.development.js`（dom的操作库），和vue只需要引入一个不一样，react需要引入两个，引入顺序也必须为先引入核心库，再引入`babel.min.js`作为jsx与js的转换

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
    <!--    核心库-->
    <script crossorigin src="https://unpkg.com/react@16.8.6/umd/react.development.js"></script>
    <!--    操作库 -->
    <script crossorigin src="https://unpkg.com/react-dom@16.14.0/umd/react-dom.development.js"></script>
    <!--    编译jsx-->
    <script src="https://unpkg.com/babel-standalone@6.15.0/babel.min.js"></script>
</head>
<body>
<!--准备一个容器-->
<div id="app"></div>
</body>

<script type="text/babel">
    // 创建虚拟dom
    const VDOM = <h1>Hello,React</h1>
    // render(虚拟dom，容器) 渲染虚拟dom
    ReactDOM.render(VDOM, document.getElementById('app'))
</script>
</html>

```

使用jsx语法的时候，script的type就必须使用`text/babel`

> 注意 ReactDOM 别写错，DOM是大写，官网的18版本中`render`函数已经淘汰了

# React中使用jsx与js差别

现在需要创建一个这样的标签

```html
<div id="app">
    <h1 id="title">
        <span>Hello React</span>
    </h1>
</div>
```

## 使用JS

```js
// 创建虚拟dom，createElement(标签名，标签属性，标签内容)
const VDOM = React.createElement('h1', {id: 'title'}, React.createElement('span', {}, 'Hello React'))
// 在容器中渲染
ReactDOM.render(VDOM, document.getElementById('app'))
```

> 这是使用了React创建的虚拟dom，对应的原生js真实dom如下：
>
> ```js
> const h1 = document.createElement('h1')
> h1.id = 'title'
> const span = document.createElement('span')
> span.innerText = 'Hello React'
> h1.appendChild(span)
> const app = document.getElementById('app')
> app.appendChild(h1)
> ```

## 使用JSX（javascript xml）

```jsx
// 创建虚拟dom
const VDOM = (
        <h1 id="title">
            <span>Hello React</span>
        </h1>
    )
// render(虚拟dom，容器) 渲染虚拟dom
ReactDOM.render(VDOM, document.getElementById('app'))
```

> 使用jsx的语法编译后还是上面的样子，只不过自己写的舒服

# react jsx常识

虚拟dom实际上是一个一般对象：`Object`

## 标签中混入js表达式要使用{}

```jsx
const myId = 'tITlE'
const content = 'Hello React'

// 创建虚拟dom
const VDOM = (
    <h1 id={myId}>
        <span>{content}</span>
    </h1>
)
// render(虚拟dom，容器) 渲染虚拟dom
ReactDOM.render(VDOM, document.getElementById('app'))
```

## 样式的类名指定不要使用class，要使用className

在jsx的模板html中，`class`属性已经被替换为`className`了，因为`jsx`怕和`es6`中的`class`关键字发生冲突，使用如下：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
    <!--    核心库-->
    <script crossorigin src="https://unpkg.com/react@16.8.6/umd/react.development.js"></script>
    <!--    操作库 -->
    <script crossorigin src="https://unpkg.com/react-dom@16.14.0/umd/react-dom.development.js"></script>
    <!--    编译jsx-->
    <script src="https://unpkg.com/babel-standalone@6.15.0/babel.min.js"></script>

    <style>
        .title {
            width: 200px;
            background: #eee;
        }
    </style>
</head>
<body>
<!--准备一个容器-->
<div id="app"></div>
</body>

<script type="text/babel">

    const myId = 'tITlE'
    const content = 'Hello React'

    // 创建虚拟dom
    const VDOM = (
        <h1 id={myId.toLowerCase()} className={myId.toLowerCase()}>
            <span>{content}</span>
        </h1>
    )
    // render(虚拟dom，容器) 渲染虚拟dom
    ReactDOM.render(VDOM, document.getElementById('app'))
</script>
</html>
```

## 使用`style`设置样式的时候，需要使用键值对

如下：

```jsx
<h1 id={myId.toLowerCase()} className={myId.toLowerCase()} style={{
    fontSize: '50px'
}}>
```

`style`后面第一个`{}`表示这是js表达式，第二个才是样式的键值对

## 在模板字符串中只能有一个根标签

如需要在页面上再渲染一个input

```
const VDOM = (
    <div>
        <h1 id={myId.toLowerCase()} className={myId.toLowerCase()} style={{
            fontSize: '50px'
        }}>
            <span>{content}</span>
        </h1>
        <input type="text"/>
    </div>
)
```

## 标签必须闭合

如`input`在html上写的时候：

```html
<div id="app">
    <input type="text">
</div>
```

使用jsx的时候，就需要对input标签做下闭合

代码见上一个中的input标签

## 标签首字母大小写区别

1. 小写字母开头， 则转换为html中同名元素，若html中无同名标签，就报错
2. 大写字母开头，react就会渲染组件，若组件没定义，就报错

## 遍历渲染

在jsx中使用数组的时候，会自动的遍历，如：

```jsx
const demo = ['1','2','3']

// 创建虚拟dom
const VDOM = (
    <div>
        <h1>前端js框架列表</h1>
        <ul>
            <li>{demo}</li>
        </ul>
    </div>
)
// render(虚拟dom，容器) 渲染虚拟dom
ReactDOM.render(VDOM, document.getElementById('app'))
```

页面显示的就是123，但是对于复杂的结构，无法做到自动遍历，如下：

```jsx
const data = [
    {
        id: 1,
        name: 'Angular'
    },
    {
        id: 2,
        name: 'React'
    },
    {
        id: 3,
        name: 'Vue'
    }
]

// 创建虚拟dom
const VDOM = (
    <div>
        <h1>前端js框架列表</h1>
        <ul>
            <li key={v.id}>{data}</li>
        </ul>
    </div>
)
// render(虚拟dom，容器) 渲染虚拟dom
ReactDOM.render(VDOM, document.getElementById('app'))
```

这样会导致报错，所以遍历复杂的数据就要在html标签中插入js代码块了

```jsx
const VDOM = (
    <div>
        <h1>基础渲染</h1>
        <ul>
            {data.map(v => <li key={v.id}> {v.name} </li>)}
        </ul>
    </div>
)
```

> 分析：
>
> `data.map(v => <li> {v.name} </li>)`返回一个改变了的数组，然后由react自动遍历

完整结构：

```jsx
const renderData = data.map(v => <li> {v.name} </li>)
// 创建虚拟dom
const VDOM = (
    <div>
        <h1>基础渲染</h1>
        <ul>
            {renderData}
        </ul>
    </div>
)
```

# React的组件开发

组件开发分为两个部分：

1. 函数式组件（用于函数定义的组件，适用于【简单组件】的定义）
2. 类式组件（适用于【复杂组件】的定义）

## 函数式组件

见名知意，使用函数开发，将html模板封装在函数中使用，如下：

```jsx
const FInput = () => <input className={1 === 1 ? 'input1' : 'input2'} type="text" placeholder="请输入内容"/>
ReactDOM.render(<FInput/>, document.getElementById('app'))
```

> 注意点：
>
> 1. 函数必须要有返回值
> 2. 因为react中组件的首字母需要大写，所以函数名也需要大写
> 3. 记得对组件标签做自闭合

`ReactDOM.render(<FInput/>`实现步骤：

1. React解析组件标签，找到了自定义的组件（没找到就报错）
2. 发现组件是函数定义的，随后调用该函数，将接收返回的虚拟dom转为真实dom后渲染

## 类式组件

使用es6中的类声明一个组件，步骤如下：

1. 创建一个类首字母大写（组件名就是类名），继承`React.Component`
2. 创建`render`方法，返回内容就是组件内容

```jsx
class FInput extends React.Component {
    render() {
        return <input className={1 === 2 ? 'input1' : 'input2'} type="text" placeholder="请输入内容"/>
    }
}
ReactDOM.render(<FInput/>, document.getElementById('app'))
```

> `render`和`ReactDOM.render`两个`render`方法没有关系

内部渲染过程如下：

1. React解析组件标签，找到`FInput`组件
2. 发现这个组件是使用类定义的，随后使用new创建该类的实例
3. 使用实例对象调用了render方法，获取返回的虚拟dom

# 组件实例的三大属性

只有使用类定义的组件有实例属性

## 核心属性1：state

### 理解

1. state 是组件对象最重要的属性，值是对象（可以包含多个key-value的组合）
2. 组件被称为“状态机”，通过更新组件的state来更新对应的页面的显示（重新渲染组件）

### 强烈注意

1. 组件中**render**方法中的**this**为组件实例对象
2. 组件自定义的方法中**this**为**undefined**，如何解决？
   1. 强制绑定this：通过函数对象的bind()
   2. 箭头函数
3. 状态数据，不能直接修改或更新

### 案例一

效果：渲染一个`h1`标签，点击标签改变其中的文字

内容：需要了解js中this的指向问题（见`js中this指向`文章）和jsx语法上的点击事件

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
    <!--    核心库-->
    <script crossorigin src="https://unpkg.com/react@16.8.6/umd/react.development.js"></script>
    <!--    操作库 -->
    <script crossorigin src="https://unpkg.com/react-dom@16.14.0/umd/react-dom.development.js"></script>
    <!--    编译jsx-->
    <script src="https://unpkg.com/babel-standalone@6.15.0/babel.min.js"></script>
</head>
<body>
<div id="app"></div>
</body>
<script type="text/babel">
    class FInput extends React.Component {
        constructor(props) {
            super(props);
            this.state = {
                isHot: true
            }
        }
        render() {
            return <h1 onClick={this.changeState}>今天天气很{this.state.isHot ? '炎热' : '凉爽'}</h1>
        }

        changeState = () => {
            // 禁止直接更新
            // this.state.isHot = !this.state.isHot

            this.setState({
                isHot: !this.state.isHot
            })
        }
    }

    ReactDOM.render(<FInput/>, document.getElementById('app'))
</script>
</html>
```

> 主要注意的事：
>
> 1. `state`属性是直接定义在构造器中的
> 2. `onClick`后面的函数是赋值在`onClick`回调中的，所以类中的`this`是`undefined`（上面使用了箭头函数，所以this可以正常使用）
> 3. `state`中的状态不可以直接更新，需要使用`setState`方法更新

针对以上第二点，有三个解决方法（箭头函数，赋值this，使用bind）

#### 方法一（使用箭头函数）

上面就是

#### 方法二（暂存this）

```jsx
let that

class FInput extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            isHot: true
        }
        that = this
    }

    render() {
        return <h1 onClick={this.changeState}>今天天气很{this.state.isHot ? '炎热' : '凉爽'}</h1>
    }

    changeState() {
        // 禁止直接更新
        // this.state.isHot = !this.state.isHot

        that.setState({
            isHot: !that.state.isHot
        })
    }
}

ReactDOM.render(<FInput/>, document.getElementById('app'))
```

> 原理就是利用构造器中this一定为类的实例对象

#### 方法三（使用bind函数）

```jsx
class FInput extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            isHot: true
        }
        this.changeState = this.changeState.bind(this)
    }

    render() {
        return <h1 onClick={this.changeState}>今天天气很{this.state.isHot ? '炎热' : '凉爽'}</h1>
    }

    changeState() {
        // 禁止直接更新
        // this.state.isHot = !this.state.isHot

        this.setState({
            isHot: !this.state.isHot
        })
    }
}

ReactDOM.render(<FInput/>, document.getElementById('app'))
```

> bind()：在某个对象后使用bind函数可以修改此对象的this指向，并返回一个新的函数，onClick绑定的函数也变成了新的函数，因为名字相同，但是新的changeState是在类的实例对象上，老的是在类的原型链上，所以同名就先找新的
>
> 方法是特殊的属性

### 最简结构

```jsx
class FInput extends React.Component {
    state = {
        isHot: true
    }

    render() {
        return <h1 onClick={this.changeState}>今天天气很{this.state.isHot ? '炎热' : '凉爽'}</h1>
    }

    changeState = () => {
        this.setState({
            isHot: !this.state.isHot
        })
    }
}

ReactDOM.render(<FInput/>, document.getElementById('app'))
```

## 核心属性2：props

### 属性单个传递

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title></title>

    <!--    核心库-->
    <script crossorigin src="https://unpkg.com/react@16.8.6/umd/react.development.js"></script>
    <!--    操作库 -->
    <script crossorigin src="https://unpkg.com/react-dom@16.14.0/umd/react-dom.development.js"></script>
    <!--    编译jsx-->
    <script src="https://unpkg.com/babel-standalone@6.15.0/babel.min.js"></script>
</head>
<body>
<div id="demo1"></div>
<div id="demo2"></div>
<div id="demo3"></div>
</body>


<script type="text/babel">
    class Ul extends React.Component {
        render() {
            const {name, age, cName} = this.props
            return (
                <ul>
                    <li>姓名：{name}</li>
                    <li>年龄：{age}</li>
                    <li>班级：{cName}</li>
                </ul>
            )
        }
    }

    ReactDOM.render(<Ul name='FSAN1' age='18' cName='rj'/>, document.getElementById('demo1'))
    ReactDOM.render(<Ul name='FSAN2' age='19' cName='rj'/>, document.getElementById('demo2'))
    ReactDOM.render(<Ul name='FSAN3' age='20' cName='rj'/>, document.getElementById('demo3'))
</script>
</html>
```

### 属性多个传递

利用`babel`+`react`的特性，就可以在标签中使用扩展运算符来传递一个对象中所有属性

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title></title>

    <!--    核心库-->
    <script crossorigin src="https://unpkg.com/react@16.8.6/umd/react.development.js"></script>
    <!--    操作库 -->
    <script crossorigin src="https://unpkg.com/react-dom@16.14.0/umd/react-dom.development.js"></script>
    <!--    编译jsx-->
    <script src="https://unpkg.com/babel-standalone@6.15.0/babel.min.js"></script>
</head>
<body>
<div id="demo1"></div>
<div id="demo2"></div>
<div id="demo3"></div>
</body>


<script type="text/babel">
    class Ul extends React.Component {
        render() {
            const {name, age, cName} = this.props
            return (
                <ul>
                    <li>姓名：{name}</li>
                    <li>年龄：{age}</li>
                    <li>班级：{cName}</li>
                </ul>
            )
        }
    }

    const data = [
        {
            name: 'FSAN1',
            age: 18,
            cName: 'rj'
        },
        {
            name: 'FSAN2',
            age: 19,
            cName: 'rj'
        },
        {
            name: 'FSAN3',
            age: 20,
            cName: 'rj'
        }
    ]
    data.forEach((v, i) => ReactDOM.render(
        <Ul {...v}/>, document.getElementById(`demo${i + 1}`))
    )
</script>
</html>
```

### props输入类型校验

#### 旧方式（react15.5已弃用）

```jsx
Ul.propTypes = {
    name: React.PropTypes.string.isRequired,
    age: React.PropTypes.number
}
```

#### 新方式

引入`prop-types`这个库

```html
<script src="https://cdn.staticfile.org/prop-types/15.8.1/prop-types.js"></script>
```

然后对组件上的propType属性定义：

```jsx
Ul.propTypes = {
    name: PropTypes.string.isRequired,
    age: PropTypes.number
}
```

完整代码：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title></title>

    <!--    核心库-->
    <script crossorigin src="https://unpkg.com/react@16.8.6/umd/react.development.js"></script>
    <!--    操作库 -->
    <script crossorigin src="https://unpkg.com/react-dom@16.14.0/umd/react-dom.development.js"></script>
    <!--    编译jsx-->
    <script src="https://unpkg.com/babel-standalone@6.15.0/babel.min.js"></script>
    <!--    引入props校验js库-->
    <script src="https://cdn.staticfile.org/prop-types/15.8.1/prop-types.js"></script>
</head>
<body>
<div id="demo1"></div>
</body>


<script type="text/babel">
    class Ul extends React.Component {
        render() {
            const {name, age, cName, speak} = this.props
            speak()
            return (
                <ul>
                    <li>姓名：{name}</li>
                    <li>年龄：{age + 1}</li>
                    <li>班级：{cName ? cName : '软件技术'}</li>
                </ul>
            )
        }
    }
    
    // 对prop传递的参数进行参数校验
    Ul.propTypes={
        name: PropTypes.string.isRequired,
        age: PropTypes.number,
        speak: PropTypes.func
    }

    const speak = () => {
        console.log('这是一个函数')
    }
    
    ReactDOM.render(<Ul name={'FSAN'} age={18} speak={speak}/>, document.getElementById(`demo1`))
</script>
</html>
```

> PropTypes支持类似链式一样的写法：`isRequired`表示必填，函数要使用`func`表示

### props默认值

当props参数不传递的时候，页面不会出现错误，只会显示为空，这时候就可以设置默认值

```jsx
// 设置默认值
Ul.defaultProps = {
    name: 'FSAN',
    age: 19
}
```

### 简化props类型和默认值

以上的类型校验和设置默认值都是在设置`Ul`这个类静态属性，又因为这是一个组件，所以这类东西应该放在组件内部才合理

```jsx
class Ul extends React.Component {

    static propTypes = {
        name: PropTypes.string.isRequired,
        age: PropTypes.number,
        speak: PropTypes.func
    }

    static defaultProps = {
        name: 'FSAN',
        age: 19
    }

    render() {
        const {name, age, cName, speak} = this.props
        speak()
        return (
            <ul>
                <li>姓名：{name}</li>
                <li>年龄：{age + 1}</li>
                <li>班级：{cName ? cName : '软件技术'}</li>
            </ul>
        )
    }
}

const speak = () => {
    console.log('这是一个函数')
}

ReactDOM.render(<Ul name={'FSAN'} age={18} speak={speak}/>, document.getElementById(`demo1`))
```

### 构造器的作用

有无构造器只有一个地方有区别：在构造器内部是否可以使用`this.props`

有构造器，接不接收`props`写不写`super`都一样

只有在构造器中接受`props`并使用`super`传递`props`才能在构造器内部使用`this.props`

总结：

1. 大多时候不需要写构造器，除非你要在构造器中使用`props`，那也用不着`this`

### 在函数式组件中使用props传参

组件实例的有三大属性，只有class定义的组件才有组件实例，函数式组件只有一个props（最新的可以使用hooks）

```jsx
const Ul = (props) => {
    const {name, age, cName} = props
    return (
        <ul>
            <li>姓名：{name}</li>
            <li>年龄：{age + 1}</li>
            <li>班级：{cName}</li>
        </ul>
    )
}

// 对prop传递的参数进行参数校验
Ul.propTypes = {
    name: PropTypes.string.isRequired,
    age: PropTypes.number
}

// 设置默认值
Ul.defaultProps = {
    name: 'FSAN',
    age: 19,
    cName: '软件技术'
}

ReactDOM.render(<Ul name={'FSAN'} age={18}/>, document.getElementById(`demo1`))
```

## 核心属性3：refs

### 字符串形式（最老写法）

存在效率上的问题（过时并在未来版本可能会淘汰）

```jsx
class Cl extends React.Component {

    logInput = (e) => {
        console.log(e)
        console.log(this.refs)
    }

    render() {
        return (
            <div>
                <input type="text" ref="input1"/>
                <button onClick={this.logInput} style={{margin: '20px'}}>输出结果</button>
                <input onBlur={({target}) => this.logInput(target)} ref="input2" type="text"/>
            </div>
        )
    }
}

ReactDOM.render(<Cl/>, document.getElementById('app'))
```

### 回调形式（更新时会有点小问题）

```jsx
class Cl extends React.Component {
    state = {
        num: 1
    }

    logInput = () => {
        console.log(this.inputRef.value)
    }

    render() {
        const {num} = this.state
        return (
            <div>
                <div>渲染次数：{num}</div>
                <input type="text" ref={e => {
                    this.inputRef = e;
                    console.log('ref加载：', e)
                }}/>
                <button onClick={this.logInput} style={{margin: '20px'}}>输出结果</button>
                <button onClick={() => this.setState({num: num + 1})}>重新渲染</button>
            </div>
        )
    }
}

ReactDOM.render(<Cl/>, document.getElementById('app'))
```

> 在页面中的元素发生变化时（render重新渲染），会发现ref加载打印了两次，第一次input的dom对象为null，第二次正常打印，这就是react先清空ref再设置新的，大多数情况无关紧要

使用设置class样式的函数解决这个问题

```jsx
class Cl extends React.Component {
    state = {
        num: 1
    }

    logInput = () => {
        console.log(this.inputRef.value)
    }

    saveInput = (e) => {
        this.inputRef = e;
        console.log('ref加载：', e)
    }

    render() {
        const {num} = this.state
        return (
            <div>
                <div>渲染次数：{num}</div>
                <input type="text" ref={this.saveInput}/>
                <button onClick={this.logInput} style={{margin: '20px'}}>输出结果</button>
                <button onClick={() => this.setState({num: num + 1})}>重新渲染</button>
            </div>
        )
    }
}

ReactDOM.render(<Cl/>, document.getElementById('app'))
```

### API创建形式（推荐）

```jsx
class Cl extends React.Component {
    state = {
        num: 1
    }
    inputRef1 = React.createRef()

    logInput = () => {
        console.log(this.inputRef1.current.value)
    }


    render() {
        const {num} = this.state
        return (
            <div>
                <div>渲染次数：{num}</div>
                <input type="text" ref={this.inputRef1}/>
                <button onClick={this.logInput} style={{margin: '20px'}}>输出结果</button>
                <button onClick={() => this.setState({num: num + 1})}>重新渲染</button>
            </div>
        )
    }
}

ReactDOM.render(<Cl/>, document.getElementById('app'))
```

使用React的createRef这个函数去创建一个响应对象，和vue3一样

# 组件的两个赋值状态

## 受控组件

```jsx
class C1 extends React.Component {
    toLogin = (e) => {
        e.preventDefault() // 阻止表单提交跳转
        alert(`用户名：${this.username.value}，密码：${this.password.value}`)
    }

    render() {
        return (
            <form action="" onSubmit={this.toLogin}>
                用户名：<input ref={e => this.username = e} type="text"/>
                密码：<input ref={e => this.password = e} type="password"/>
                <button>登录</button>
            </form>
        )
    }
}

ReactDOM.render(<C1/>, document.getElementById('app'))
```

> 受控组件的展示就是，当我们点击登录按钮才会去获取input的值，发出登录请求（默认get）

## 非受控组件

```jsx
class C1 extends React.Component {
    state = {
        username: '',
        password: ''
    }

    saveUsername = (e) => {
        this.setState({
            username: e.target.value
        })
    }
    savePassword = (e) => {
        this.setState({
            password: e.target.value
        })
    }

    toLogin = (e) => {
        e.preventDefault() // 阻止表单提交跳转
        const {username, password} = this.state
        alert(`用户名：${username}，密码：${password}`)
    }

    render() {
        return (
            <form action="" onSubmit={this.toLogin}>
                用户名：<input onChange={this.saveUsername} type="text"/>
                密码：<input onChange={this.savePassword} type="password"/>
                <button>登录</button>
            </form>
        )
    }
}

ReactDOM.render(<C1/>, document.getElementById('app'))
```

> 在非受控组件中，input就值就像vue中的双向绑定一样，先赋值在一个属性上，要拿的时候直接使用这个属性即可

# 高阶函数（函数柯里化）

在看到上一个非受控组件的时候，保存状态两个函数中冗余度太高，更别说如果是注册的逻辑了，所以可以把这两个函数整合到一起

```jsx
class C1 extends React.Component {
    state = {
        formData: {
            username: '',
            password: ''
        }
    }

    saveFormData = k => e => {
        const {formData} = this.state
        formData[k] = e.target.value
        this.setState({formData})
    }

    toLogin = e => {
        e.preventDefault() // 阻止表单提交跳转
        const {formData} = this.state
        alert(`用户名：${formData.username}，密码：${formData.password}`)
    }

    render() {
        return (
            <form action="" onSubmit={this.toLogin}>
                用户名：<input onChange={this.saveFormData('username')} type="text"/>
                密码：<input onChange={this.saveFormData('password')} type="password"/>
                <button>登录</button>
            </form>
        )
    }
}

ReactDOM.render(<C1/>, document.getElementById('app'))
```

> 柯里化（currying）指的是将一个多参数的函数拆分成一系列函数，每个拆分后的函数都只接受一个参数（unary）

## 简化说明

```jsx
onChange={this.saveFormData('username')}
```

这样是将`saveFormData`这个函数的返回值作为回调函数，所以如果这个函数内这样写就是错误的

```jsx
saveFormData = k => {
    console.log(k)
}
```

这样只会打印一次k，之后点击就是无反应，因为这个函数返回时的是`undefined`

所以如果要使用这种`onChange`绑定的话，返回的一定是一个函数

```jsx
saveFormData = k => {
    return e => {
        
    }
}
```

这时候，传进去的`username`被k接受，然后返回一个函数，当作点击回调，回调时没有参数，e就是event

## 函数柯里化例子

```js
// 正常
const getNum = (a, b) => {
    a++
    return a + b
}
console.log(getNum(1, 2));

// 柯里化
const getNumPlus = a => {
    a++
    return b => {
        return a + b
    }
}

const demo1 = getNumPlus(1)(3)
console.log(demo1)

const demo2 = getNumPlus(1)
console.log(demo2(4));
console.log(demo2(5));

// 简化后
const endGetNum = a => b => a+++b
console.log(endGetNum(1)(2));
```

# 函数生命周期

## 案例一

需要实现文字的透明度变化，和取消元素挂载，需要包括取消组件挂载后关闭定时器

```jsx
    class Demo extends React.Component {
        state = {
            opacity: 1,
            intervalTimer: ''
        }

        removeComponent = () => {
            // 卸载组件
            ReactDOM.unmountComponentAtNode(document.getElementById('app'))
        }

        // 组件挂载完毕的生命周期函数
        componentDidMount() {
            // 改变文字透明度
            this.intervalTimer = setInterval(() => {
                let o = this.state.opacity
                if (o <= 0) o = 1
                this.setState({
                    opacity: o - 0.1
                })
            }, 200)
        }

        // 组件将要取消挂载生命周期函数
        componentWillUnmount() {
            // 清空变化的定时器
            clearInterval(this.intervalTimer)
        }

        render() {
            return (
                <div>
                    <h1 style={{opacity: this.state.opacity}}>React学不会怎么办</h1>
                    <button onClick={this.removeComponent}>不学了</button>
                </div>
            )
        }
    }

    ReactDOM.render(<Demo/>, document.getElementById('app'))
```

> 知识点：
>
> 1. `unmountComponentAtNode()`卸载组件
> 2. `componentWillUnmount()`组件卸载及销毁之前调用
> 3. `componentDidMount()`组件挂载完毕后调用

## 完整生命周期（17.x之前）

### 挂载时

```jsx
class Count extends React.Component {
    state = {
        count: 0
    }

    // 执行顺序：1
    constructor(props) {
        console.log('constructor（构造器）')
        super(props);
    }

    // 执行顺序：2
    componentWillMount() {
        console.log('componentWillMount（组件将要挂载）')
    }

    // 执行顺序：3
    render() {
        console.log('render（组件渲染）')
        return (
            <div>
                <div>当前计数：{this.state.count}</div>
                <button onClick={e => this.setState({count: this.state.count + 1})}>增加</button>
            </div>
        )
    }

    // 执行顺序：4
    componentDidMount() {
        console.log('componentDidMount（组件挂载完毕）')
    }

    // 执行顺序：5
    componentWillUnmount() {
        console.log('componentWillUnmount（组件销毁或卸载之前）')
    }
}

ReactDOM.render(<Count/>, document.getElementById('app'))
```

### 更新数据时

```jsx
/**
 * 类似阀门，返回布尔类型，决定是否渲染
 * @param nextProps
 * @param nextState 修改后的state
 * @param nextContext
 * @returns {boolean} 返回 true 之后进入 componentWillUpdate
 */
shouldComponentUpdate(nextProps, nextState, nextContext) {
    console.log('shouldComponentUpdate', nextProps, nextState, nextContext)
    return true
}

/**
 * 组件将要更新的钩子
 * @param nextProps 同上
 * @param nextState 同上
 * @param nextContext 同上
 */
componentWillUpdate(nextProps, nextState, nextContext) {
    console.log('componentWillUpdate', nextProps, nextState, nextContext)
}

/**
 * 组件更新完毕的钩子
 * @param prevProps 改变之前的props
 * @param prevState 改变之前的state
 * @param snapshot
 */
componentDidUpdate(prevProps, prevState, snapshot) {
    console.log('componentDidUpdate', prevProps, prevState, snapshot)
}
```

### 强制更新

```jsx
<button onClick={e => this.forceUpdate()}>强制渲染</button>
```

> 强制更新是不走阀门的，直接到`componentWillUpdate`

### 传递参数时

```jsx
class A extends React.Component {
    state = {
        num: 0
    }

    render() {
        return (
            <div>
                <div>这是父组件A</div>
                <button onClick={e => this.setState({num: this.state.num + 1})}>增加子组件的数字</button>
                <B num={this.state.num}/>
            </div>
        )
    }
}

class B extends React.Component {
    /**
     * 接受传值的时候调用，初始化渲染的时候不会调用
     * @param nextProps 传递的参数
     * @param nextContext
     */
    componentWillReceiveProps(nextProps, nextContext) {
        console.log('componentWillReceiveProps', nextProps)
    }

    render() {
        return (
            <div>
                <div>这是子组件B</div>
                <div>显示的数字为：{this.props.num}</div>
            </div>
        )
    }
}

ReactDOM.render(<A/>, document.getElementById('app'))
```

> 知识点：
>
> 1. `componentWillReceiveProps`

### 总结

最常用的三个钩子：

1. `componentDidMount()`组件挂载完毕之后
2. `render()`
3. `componentWillUnmount()`组件销毁或卸载之前

## 新的生命周期以及变化(17.x)

1. 除了`componentWillUnmount()`之外，其他所有有`will`的生命周期在新版本都需要在前面加上`UNSAFE`（unsafe这里并不是表示不安全，而是在未来使用异步渲染的时候可能会出现问题），具体变化的钩子如下
   1. `componentWillMount()`组件挂载之前  ==》`UNSAFE_componentWillMount()`
   2. `componentWillUpdate()`组件更新之前 ==》`UNSAFE_componentWillUpdate()`
   3. `componentWillReceiveProps()`组件接受参数之前 ==》`UNSAFE_componentWillReceiveProps()`
   
2. 新增两个生命周期

   | 生命周期函数                 | 说明                                                         |
   | ---------------------------- | ------------------------------------------------------------ |
   | `getDerivedStateFromProps()` | 返回对象对state的更新（罕见使用：若state的值在任何时候都取决于props），派生状态会导致代码冗余，并使组件难以维护 |
   | `getSnapshotBeforeUpdate()`  | 更新时在render后，在视图更新之前执行，可以保存更新前的状态，返回的值传递给`componentDidUpdate()`（组件更新完毕），此用法并不常见 |

## 案例二（控制滚动条）

类似直播的弹幕，可随时跟踪最新也可以停止查看

### 新增在顶部

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
    <script crossorigin src="https://unpkg.com/react@18/umd/react.development.js"></script>
    <script crossorigin src="https://unpkg.com/react-dom@18/umd/react-dom.development.js"></script>
    <script src="https://unpkg.com/babel-standalone@6.15.0/babel.min.js"></script>
    <style>
        * {
            padding: 0;
            margin: 0;
        }

        .divBox {
            width: 400px;
            height: 400px;
            overflow: auto;
            margin: auto;
            border: 1px solid #ccc;
        }


        .divBox div {
            height: 60px;
            line-height: 60px;
            cursor: pointer;
        }

        .divBox div:hover {
            background: #f4f4f4;
        }
    </style>
</head>
<body>
<div id="app"></div>
</body>
<script type="text/babel">
    class Demo extends React.Component {
        state = {
            arrayList: []
        }
        timer
        divBoxRef = React.createRef()

        componentDidMount() {
            this.timer = setInterval(() => {
                this.setState({
                    arrayList: [`这是消息${this.state.arrayList.length + 1}`, ...this.state.arrayList]
                })
            }, 500)
        }


        getSnapshotBeforeUpdate(prevProps, prevState) {
            // 视图更新前判断是否为顶端
            const {scrollTop} = this.divBoxRef.current
            if (scrollTop === 0) {
                // 是，不做操作，跟着最新消息移动
                return null
            } else {
                // 不是，滚动条自动向下滚动，相对静止
                return this.divBoxRef.current.scrollHeight
            }
        }

        componentDidUpdate(prevProps, prevState, height) {
            // this.divBoxRef.current.scrollTop += 60   60渲染的高度
            if (height) {
                let {scrollTop, scrollHeight} = this.divBoxRef.current
                scrollTop += scrollHeight - height
                this.divBoxRef.current.scrollTop = scrollTop
            }
        }

        render() {
            return (
                <div>
                    <div className="divBox" ref={this.divBoxRef}>
                        {this.state.arrayList.map((v, i) => (<div key={i}>{v}</div>))}
                    </div>
                    <button onClick={e => {
                        clearInterval(this.timer);
                        this.divBoxRef.current.scrollHeight = 10
                    }}>停止
                    </button>
                </div>
            )
        }
    }

    ReactDOM.createRoot(document.getElementById('app')).render(<Demo/>)
</script>
</html>
```

### 新增在底部

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
    <script crossorigin src="https://unpkg.com/react@18/umd/react.development.js"></script>
    <script crossorigin src="https://unpkg.com/react-dom@18/umd/react-dom.development.js"></script>
    <script src="https://unpkg.com/babel-standalone@6.15.0/babel.min.js"></script>
    <style>
        * {
            padding: 0;
            margin: 0;
        }

        .divBox {
            width: 400px;
            height: 400px;
            overflow: auto;
            margin: auto;
            border: 1px solid #ccc;
        }


        .divBox div {
            height: 60px;
            line-height: 60px;
            cursor: pointer;
        }

        .divBox div:hover {
            background: #f4f4f4;
        }
    </style>
</head>
<body>
<div id="app"></div>
</body>

<script type="text/babel">
    class Demo extends React.Component {

        state = {
            arrayList: [],
        }
        divBoxRef = React.createRef()

        componentDidMount() {
            setInterval(() => {
                this.setState({
                    arrayList: [...this.state.arrayList, `这是消息${this.state.arrayList.length + 1}`]
                })
            }, 500)
        }

        getSnapshotBeforeUpdate(prevProps, prevState) {
            // 判断是否为底部
            const {scrollTop, scrollHeight, clientHeight} = this.divBoxRef.current
            if (scrollTop + clientHeight === scrollHeight) return scrollHeight
            return null
        }

        componentDidUpdate(prevProps, prevState, snapshot) {
            if (snapshot) {
                // 滚动条顶部高度 = 自身顶部高度 + (改变后容器高度 - 改变前容器高度)
                const {scrollTop, scrollHeight} = this.divBoxRef.current
                this.divBoxRef.current.scrollTop += scrollHeight - snapshot
            }
        }

        render() {
            return (
                <div className="divBox" ref={this.divBoxRef}>
                    {this.state.arrayList.map((v, i) => (<div key={i}>{v}</div>))}
                </div>
            )
        }
    }

    ReactDOM.createRoot(document.getElementById('app')).render(<Demo/>)
</script>
</html>
```

# diffing算法

渲染时对比新旧标签的key和标签本身决定是否要替换

1. 虚拟dom中key的作用（当状态中的数据发生变化时，react会根据【新数据】生成【新的虚拟DOM】，随后React进行【新虚拟DOM】与【旧虚拟DOM】的diff比较，比较规则如下：）
   1. 旧虚拟DOM中找到了与新虚拟DOM相同的key：
      1. 若虚拟DOM中内容没变，直接使用之前的真实DOM
      2. 若虚拟DOM中内容变了，则生成新的真实DOM，随后替换掉页面中之前的真实DOM
   2. 旧虚拟DOM中未找到与新虚拟DOM相同的key
      1. 根据数据创建新的真实DOM，随后渲染到页面
2. 用index作为key可能会引发的问题：
   1. 若对数据进行：逆序添加，逆序删除等破坏顺序操作会产生没有必要下的真实DOM更新 ==> 页面效果没问题，但效率低
   2. 如果结构中还包含输入类的DOM会产生错误DOM更新  ==> 界面有问题
   3. 如果不存在对数据破坏顺序操作，仅用于渲染列表用于展示，使用index作为key没有问题的

