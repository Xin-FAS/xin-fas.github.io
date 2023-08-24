---
title: python使用socketio实现双向通信
date: 2021-09-22 20:37:10
tags: [WebSocket,Python]
categories: [后端,Python]
---

## H5 建立socket连接

### 使用原生对象


#### 建立连接

判断浏览器是否支持websocket服务

```js
if('WebSocket' in window){
    websocket = new WebSocket('ws://localhost:8080')
}
```

建立连接发送数据：

```js
websocket.onopen = () => {
    console.log("建立websocket连接成功！")
}
websocket.onmessage = () => {
    console.log("我收到了默认的消息！")
}
websocket.onerror = () => {
    console.log("连接出错了！")
}
```
建议使用封装更好的socket.io.js

### 使用socket.io.js

#### 下载并引入：

官网：https://socket.io/

中文文档：https://socketio.bootcss.com

4.1.3版本cdn：

```javascript
<script src="https://cdn.bootcdn.net/ajax/libs/socket.io/4.1.3/socket.io.min.js"></script>
```

不考虑空间的话使用不压缩的好，有代码提示和补全


```javascript
let websocket_url = 'http://127.0.0.1:5000'  
let socket = io.connect(websocket_url)
```
> 没错，直接使用http协议，这个库会自动解析并创建websocket对象

#### 简单使用
使用连接对象监听和发送

```js
socket.emit('testRequest',{
	'params' : '测试连接'
})
socket.on("response", (data) => {
	if(data.code == '200'){
		alert(data.msg)
	}else{
		alert("error")
	}
})
```

使用send发送就一定是message接收（与emit的区别）

## python中socket服务编写

python中对应的包为`flask-socketio`

### 步骤：

1. 导入flask-socketio下的SocketIO和emit
2. 导入flask框架，并初始化(记得使用跨域)
3. 使用SocketIO建立服务器连接对象
4. 使用连接对象的init_app方法在flask对象上建立应用服务

> tips:
>
> 1. socket 使用 `cors_allowed_origins="*"`解决跨域
> 2. 如要广播多个网页，要在emit或者send方法后面加上broadcast=True

### 最简结构

```python
from flask-socketio import SocketIO,emit
from flask import Flask
from flask_cors import CORS

app = Flask("")
CORS(app)
socket = SocketIO()
socket.init_app(app, cors_allowed_origins="*")


@socket.on("testRequest")
def on_testRequest(data):
    emit("response", {
        'msg': data.params
    })
    
    
if __name__ == '__main__':
    socket.run(
        app,
        port=5000,
        host="127.0.0.1"
    )
```
