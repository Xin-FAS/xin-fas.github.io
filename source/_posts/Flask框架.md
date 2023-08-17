---
title: Flask框架
date: 2021-09-13 23:07:47
tags: [python,flask]
categories: [后端,python]
---


## Flask

### 使用flask框架

官网：https://dormousehole.readthedocs.io/en/latest/quickstart.html#id2

> 初始化：

下载：

```bash
pip install flask
```

<!--more-->

1. 按需导入Flask和拆分用的Blueprint（蓝图）
2. 定义一个变量初始化flask框架  Flask("")
3. 在main方法中使用初始化变量的run方法，定义两个参数，host和port

### 最小的程序

```python
from flask import Flask

app = Flask(__name__)

@app.route("/")
def hello_world():
    return "<p>Hello, World!</p>"
```

在控制台启动

```CMD
> set FLASK_APP=hello
> flask run
```

### 使用python启动的最小程序

```python
from flask import Flask

app = Flask("")


@app.route('/hello')
def hello():
    return "Hello World!!"


if __name__ == '__main__':
    app.run(
        host="127.0.0.1",
        port=5000
    )
```

 注意：这里run下的两个参数，host是启动的地址，写0.0.0.0就是使用网络地址http://192.168.214.206:5000/ ，端口号默认5000

### 使用Blueprint

> 写Blueprint

作用：让代码整体更美观，拆分代码块

1. 创建api下的文件，导入Blueprint
2. 定义蓝图的主路径并指定返回的名字
3. 写对应接口

```python
from flask import Blueprint

app = Blueprint('hello', 'hello', url_prefix='/api')


@app.route('/')
def hello():
    return {
        'data': '09/13/21/58',
        'print': 'Hello World!!'
    }
```

注意这里的url_prefix不要写成url_defaults

<br>

> 用Blueprint

在启动的地方先使用import导入文件下的返回值

使用Flask初始化的对象下register_blueprint方法指定名字，在导入时不能重名，所以可以使用as指定副名字

```python
from pythonweb.api.hello import app as hello_api
from flask import Flask

app = Flask("")
app.register_blueprint(hello_api)

if __name__ == '__main__':
    app.run(
        host="127.0.0.1",
        port="5000"
    )
```

### 自定义路径和接口地址

> yaml文件

内容仿造java就可以

```yaml
server:
  port: 5000
  host: 127.0.0.1
```

<br>

> 写提供属性的py文件

思路就是使用yaml模块下的load下的get方法，提取出yaml文件中的属性对应的值，再在主启动中调用

但是yaml下的load模块现在被弃用了，如果还要再使用就得在load中加一个属性，Loader=FullLoader，就要再导入FullLoader模块

get方法的第二个参数是在第一个参数为空时调用的

```python
from yaml import FullLoader, load

ymlLoad = load(open('myConfig/serve.yml', 'r', encoding='utf-8'), Loader=FullLoader)
PORT = ymlLoad.get('server').get('port', 80)
HOST = ymlLoad.get('server').get('host', '127.0.0.1')
```

<br>

> 调用数据

```python
from pythonweb.config.serve import HOST, PORT

...

if __name__ == '__main__':
    app.run(
        host=HOST,
        port=PORT
    )
```

### 使用before和after实现判断

> 判断是否是程序访问

html页面使用axios发起请求

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
</head>
<body>
<h2>123</h2>
<button onclick="send()">发送</button>
</body>
<script src="https://unpkg.com/axios/dist/axios.min.js"></script>
<script>
    let send = () => {
        const data = axios.post("/api/login", {
            username: 'qixin',
            password: '123'
        })
        console.log(res)
    }
</script>
</html>
```

 

在python中的login接口上使用request接收json数据

```
from flask import Blueprint, request

api = Blueprint("login", "login", url_prefix="/api")


@api.route('/login', methods=["GET", "POST"])
def file():
    print(request.json["username"])
    print(request.json["password"])
    if request.json['username'] == "qixin":
        return {
            "status": 200,
            "message": "确认身份成功！"
        }
    else:
        return {
            "status": 404,
            "message": "确认身份失败"
        }
```

在主线路上使用before下的函数，判断ua即可

```python
@app.before_request
def start():
    if not request.headers["User-Agent"].find("PostmanRuntime") == -1:
        return {
            "msg": "请不要使用程序访问！"
        }
```

使用postman测试是否成功：

1. 选择Headers，key:COntent-Type，value:application/json
2. 选择body，写入下列数据

```json
{
    "username":"qixin",
    "password":"123"
}
```

注意：

1. post方法发送的是json形式，使用request下的json方法接收
2. get方法发送的是地址形式，使用request下的args方法接收

### input发送并接收file文件

> 思路：

前端使用input中type样式为file的选择发送文件，然后在button点击事件中拿到input标签下的files属性，再根据下标0拿到数据，创建一个FormData对象，使用addend方法添加键值对形式拿到的数据当做数据使用axios的post方法发送。

后端使用request的files.get方法拿取数据，再使用二进制写入本地的文件夹下

index.html:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
</head>
<body>
<h2>123</h2>
<button onclick="send()">发送</button>
<hr>
<input type="file" id="file1" value="选择...">
<button onclick="sendFile()">提交</button>
</body>
<script src="https://unpkg.com/axios/dist/axios.min.js"></script>
<script>
    let send = async () => {
        const {data: res} = await axios.post("/api/login", {
            username: 'qixin',
            password: '123'
        })
        console.log(res)
    }
    const sendFile = async () => {
        let file = document.getElementById("file1").files[0]
        console.log(file)

        let fileData = new FormData()
        fileData.append("file", file)

        const {data:res} = await axios.post("/api/setFile", fileData)
        console.log(res.url)
    }
</script>
</html>
```

接口：

```python
@app.route('/setFile', methods=["POST"])
def index():
    file = request.files.get("file")
    b = file.stream.read()
    name = file.filename
    with open("static/img/" + name, "wb") as img:
        img.write(b)
    return {
        "msg": 200,
        "url": f"http://122.239.1.117:1234/static/img/{name}"
    }
```

* request中files可以拿到传来的FormData文件，request.remote_addr则可以拿到请求客户端的ip地址（小心这个）





