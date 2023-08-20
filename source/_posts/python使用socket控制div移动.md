---
title: python使用socket控制div移动
date: 2021-09-23 23:55:02
tags: []
categories: [曾经,python小玩意]
---


## 思路：

还是老样子

1. 使用flask写网页路由（记得跨域）
2. flask-socketIO来创建服务器和封装app（记得跨域）
3. 两个路由网页一个控制一个显示（也可以多个显示）
4. 控制发送请求到服务器，服务器发给显示页面，显示自己判断（判断处写的很妙）

### 代码展示

control.html

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <script src="/static/socket.io.min.js"></script>
    <meta charset="UTF-8">
    <title>控制器</title>
    <style>

        #secondBox {
            width: 500px;
            border: 1px solid #000;
            height: 700px;
            border-radius: 40px;
            float: left;
        }

        #secondBox .headerBox {
            height: 200px;
            font-family: 仿宋, monospace;
            font-size: 80px;
            text-align: center;
            margin-top: 100px
        }

        button {
            width: 100px;
            text-align: center;
            height: 80px;
            border-radius: 20px;
            margin: 10px;
            background: #eee;
            box-shadow: 0px 10px 10px 0 #ccc;
        }

        button:hover {
            background: #fff;
        }

        button:active {
            background: #fff;
            transform: translateY(-5px);
        }

        #up, #center, #down {
            width: 500px;
            text-align: center;
        }

        #center .one {
            border-radius: 50px;
        }
    </style>
</head>
<body>
<div style="margin: auto;width: 800px">
    <div id="secondBox">
        <div class="headerBox">遥控器</div>
        <div id="up">
            <button onclick="send('up')">上</button>
        </div>
        <div id="center">
            <button onclick="send('left')">左</button>
            <button class="one" onclick="start()">建立连接</button>
            <button onclick="send('right')">右</button>
        </div>
        <div id="down">
            <button onclick="send('down')">下</button>
        </div>
    </div>
    <div style="width: 200px;float: right" id="view"></div>
</div>
</body>

<script>
    let socket = io.connect(":5000")
    let send = (path) => {
        socket.emit("move", path)
        let str = "发出了" + path + "请求"
        let viewDiv = document.getElementById("view")
        let p = document.createElement("p")
        p.innerText = str
        viewDiv.appendChild(p)


    }

    const start = () => {
        try {
            alert("已经建立连接，可以使用！")
        } catch (e) {
            alert("连接不成功！看控制台")
            console.log(e)
        }
    }
</script>
</html>
```

Home.html

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>主目录</title>
    <style>
        #box {
            width: 150px;
            height: 150px;
            background: red;
            margin: 100px auto auto;
        }
    </style>
</head>
<body>
<div id="box">
</div>
</body>
<script src="/static/socket.io.min.js"></script>
<script>
    const socket = io.connect(":5000")
    socket.on("move", (data) => {
        move[data]()
        move.move()
    })

    let x = 0
    let y = 0
    const move = {
        up() {
            y -= 50
        },
        left() {
            x -= 50
        },
        right() {
            x += 50
        },
        down() {
            y += 50
        },
        move() {
            document.getElementById("box").style.transform = `translateX(${x}px) translateY(${y}px)`
        }
    }
</script>
</html>
```

main.py

```py
# -*- coding = utf-8 -*-
# @Time : 2021/9/23 21:02
# @Author : FSAN
# @File : main.py
# @Software : PyCharm


from flask import Flask, render_template
from flask_cors import CORS
from flask_socketio import SocketIO, emit

app = Flask("")
CORS(app)

socket = SocketIO()
socket.init_app(app, cors_allowed_origins="*")


@app.route('/')
def index():
    return render_template("Home.html")


@app.route('/control')
def control():
    return render_template("control.html")


@socket.on('message')
def on_message(data):
    print(data)


@socket.on('move')
def on_move(data):
    emit("move", data, broadcast=True)


if __name__ == '__main__':
    socket.run(
        app,
        host="127.0.0.1",
        port=5000,
        debug=True
    )

```

### 细节说明

添加元素忘了的去看js基础

控制器四个按钮发送四个方向到服务器，服务器直接转发到显示的html，在显示的网页上根据接收的值去调用对应的函数做相应操作就行

变量要提前赋值，服务器的debug可以不用写，我是单纯为了调试css样式方便

