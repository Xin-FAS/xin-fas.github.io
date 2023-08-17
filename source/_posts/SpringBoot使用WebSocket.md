---
title: SpringBoot使用WebSocket
date: 2022-05-19 16:02:15
tags: [java,websocket]
categories: [后端,java]
---

## 导入依赖

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-websocket</artifactId>
</dependency>
```

## 最简结构

### 建立websocket服务类

```java
package com.fsan.socket;

import com.alibaba.fastjson.JSON;
import com.fsan.entity.RespResult;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.AbstractWebSocketHandler;


@Slf4j
@Component
public class WsService extends AbstractWebSocketHandler {

    @Override
    public void afterConnectionEstablished(WebSocketSession session) {
        log.info(session.getId() + "建立ws连接");
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) {
        log.info(session.getId() + "关闭ws连接");
    }

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) {
        String payload = message.getPayload();
        log.info("收到消息：" + payload);
    }
}
```

### websocket配置开启服务

创建 config > SocketConfig.java

```java
package com.fsan.config;

import com.fsan.socket.WsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.socket.config.annotation.EnableWebSocket;
import org.springframework.web.socket.config.annotation.WebSocketConfigurer;
import org.springframework.web.socket.config.annotation.WebSocketHandlerRegistry;

@Configuration
@EnableWebSocket
public class SocketConfig implements WebSocketConfigurer {

    @Autowired
    private WsService wsService;

    @Override
    public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
        registry
                // 添加socket服务
                .addHandler(wsService, "/ws/user")
                // 允许跨域
                .setAllowedOrigins("*");

    }
}
```

这里 "/ws/user" 就是连接路径，如 “ws://localhost:8081/ws/user”

### html页面

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
</head>
<body>
<button onclick="createConn()">建立连接</button>
<input type="text" id="inputVal" placeholder="发送消息">
<button onclick="sendMsg()">发送</button>
</body>

<script>
    let socket;
    const sendMsg = () => {
        socket.send(document.getElementById("inputVal").value)
    }
    const createConn = () => {
        socket = new WebSocket(`ws://localhost:8081/ws/user`)
        socket.onopen = () => {
            document.getElementById("state").innerText = '已连接！'
        }
    }
</script>
</html>
```

## 存储每个socket连接

### 建立websocket管理类

socket > WsSocketManage.java

```java
package com.fsan.socket;

import com.alibaba.fastjson.JSON;
import com.fsan.entity.WsRespResult;
import com.fsan.myEnum.WsRespResultEnum;
import lombok.extern.slf4j.Slf4j;
import org.springframework.util.StringUtils;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;

import java.io.IOException;
import java.util.HashMap;
import java.util.concurrent.ConcurrentHashMap;

@Slf4j
public class WsSocketManage {
    private static ConcurrentHashMap<String, WebSocketSession> wsSession = new ConcurrentHashMap<>();

    /**
     * 添加socket连接
     *
     * @param key     键
     * @param session 对象
     */
    static void add(String key, WebSocketSession session) {
        wsSession.put(key, session);
    }

    /**
     * 删除socket连接
     *
     * @param key 键
     * @return 删除的session
     */
    static WebSocketSession remove(String key) {
        return wsSession.remove(key);
    }

    /**
     * 删除并同步关闭socket连接
     *
     * @param key 键
     */
    static void removeAndClose(String key) {
        WebSocketSession remove = wsSession.remove(key);
        if (!StringUtils.isEmpty(remove)) {
            try {
                remove.close();
            } catch (IOException e) {
                e.printStackTrace();
                // todo 关闭连接异常
            }
        }

    }

    /**
     * 获取socket连接
     *
     * @param key 键
     * @return session对象
     */
    static WebSocketSession get(String key) {
        return wsSession.get(key);
    }

    /**
     * 获取在线人数
     *
     * @return integer
     */
    public static Integer getUserNum() {
        return wsSession.size();
    }

    /**
     * 获取请求session中参数map
     *
     * @param session session 对象
     * @return HashMap
     */
    static HashMap<String, String> getQueryToMap(WebSocketSession session) {
        String query = session.getUri().getQuery();
        HashMap<String, String> map = new HashMap<>();
        for (String s : query.split("&")) {
            String[] s1 = s.split("=");
            map.put(s1[0], s1[1]);
        }
        return map;
    }
}

```

> 关于ConcurrentHashMap：
>
> ConcurrentHashMap是HashMap的升级版，HashMap是线程不安全的，而ConcurrentHashMap是线程安全。
>
> session中参数 在前端中就是类似get的params传递 ：ws://localhost:8081/msg/user?name=FSAN

### 建立连接时以用户名存储

```java
package com.fsan.socket;

import com.fsan.stateEnum.WsRespResultEnum;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.AbstractWebSocketHandler;

import java.util.HashMap;


@Slf4j
@Component
public class WsService extends AbstractWebSocketHandler {

    /**
     * 建立连接
     *
     * @param session
     */
    @Override
    public void afterConnectionEstablished(WebSocketSession session) {
        // 解析用户
        HashMap<String, String> queryToMap = WsSocketManage.getQueryToMap(session);
        String name = queryToMap.get("name");
        // 以用户名为key，存储连接
        WsSocketManage.add(name, session);
        log.info(name + "建立ws连接");
        log.info("当前在线人数：" + WsSocketManage.getUserNum());
    }

    /**
     * 断开连接
     *
     * @param session
     * @param status
     */
    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) {
        // 获取断开连接的用户
        String name = WsSocketManage.getQueryToMap(session).get("name");
        // 移除session
        WsSocketManage.removeAndClose(name);
        log.info(name + "关闭ws连接");
        log.info("当前在线人数：" + WsSocketManage.getUserNum());
    }

    /**
     * 收到消息
     *
     * @param session session对象
     * @param message 消息内容
     */
    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) {
        String payload = message.getPayload();
        log.info("收到消息：" + payload);
    }
}

```

### html页面

```java
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
</head>
<body>
<p>当前状态：<span id="state">未连接</span></p>
<p>当前在线人数：<span id="userNum"></span></p>
<button onclick="createConn()">建立连接</button>
<input type="text" id="name" placeholder="登录名">
<input type="text" id="inputVal" placeholder="发送消息">
<button onclick="sendMsg()">发送</button>
</body>

<script>
    let socket;

    const valid = (name) => {
        if (!name) {
            alert("登录名不可为空！")
            return false;
        }
        return true;
    }

    const sendMsg = () => {
        const name = document.getElementById("name").value
        if (!valid(name)) return
        socket.send(document.getElementById("inputVal").value)
    }
    const createConn = () => {
        const name = document.getElementById("name").value
        if (!valid(name)) return
        socket = new WebSocket(`ws://localhost:8081/ws/user?name=${name}`)
    }
</script>
</html>

```

这样对已连接的session对象进行存储之后，就可以进行进一步的通知操作了

## 封装websocket的返回消息

因为socket消息的发送并不是向axios一样，axios前端可以接收指定业务的返回情况，而socket接收返回时不知道是什么业务，所以包装类根据参数数量划分，枚举类根据业务种类划分（越细越好）

### 包装类

创建 entity > WsRespResult.java

```java
package com.fsan.entity;

import com.alibaba.fastjson.JSON;
import com.fsan.stateEnum.WsRespResultEnum;
import com.fsan.socket.WsSocketManage;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.web.socket.TextMessage;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class WsRespResult {
    private Integer code;
    private Object content;
    private Integer userNum;
    private String formName;


    /**
     * 发送给自己
     * @return
     */
    public static TextMessage send(WsRespResultEnum respResultEnum) {
        WsRespResult respResult = new WsRespResult();
        respResult.setCode(respResultEnum.getCode());
        respResult.setContent(respResultEnum.getContent());
        respResult.setUserNum(WsSocketManage.getUserNum());
        return new TextMessage(JSON.toJSONString(respResult));
    }

    /**
     * 发送给对方
     * @return
     */
    public static TextMessage send(WsRespResultEnum respResultEnum, String formName) {
        WsRespResult respResult = new WsRespResult();
        respResult.setCode(respResultEnum.getCode());
        respResult.setContent(respResultEnum.getContent());
        respResult.setFormName(formName);
        respResult.setUserNum(WsSocketManage.getUserNum());
        return new TextMessage(JSON.toJSONString(respResult));
    }

    /**
     * 发送给对方（有内容）
     * @return
     */
    public static TextMessage send(WsRespResultEnum respResultEnum, String formName, String content) {
        WsRespResult respResult = new WsRespResult();
        respResult.setCode(respResultEnum.getCode());
        respResult.setContent(content);
        respResult.setFormName(formName);
        respResult.setUserNum(WsSocketManage.getUserNum());
        return new TextMessage(JSON.toJSONString(respResult));
    }
}

```

发送给自己和发送给对方的区别就是要不要带上发送者的用户名

### 枚举类

创建 stateEnum > WsRespResultEnum.java

```java
package com.fsan.stateEnum;

public enum WsRespResultEnum {
    CONN_SUCCESS(2000, "连接成功"),
    SENDMSG_SUCCESS(2001, "发送消息成功"),
    USERNUM_UPDATE(2002, "广播所有更新在线人数"),
    ACCEPT_FORMTOALL(2003, "接收到广播消息"),
    ACCEPT_FORMTOUSER(2004, "接收到个人消息");

    private Integer code;
    private Object content;

    WsRespResultEnum(Integer code, Object content) {
        this.code = code;
        this.content = content;
    }

    public Integer getCode() {
        return code;
    }

    public Object getContent() {
        return content;
    }
}
```


## 使用广播实现实时在线人数

### 更改自己连接状态和实时在线人数

#### 管理类新增方法

```java
package com.fsan.socket;

import com.alibaba.fastjson.JSON;
import com.fsan.entity.WsRespResult;
import com.fsan.stateEnum.WsRespResultEnum;
import lombok.extern.slf4j.Slf4j;
import org.springframework.util.StringUtils;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;

import java.io.IOException;
import java.util.HashMap;
import java.util.concurrent.ConcurrentHashMap;

@Slf4j
public class WsSocketManage {
    private static ConcurrentHashMap<String, WebSocketSession> wsSession = new ConcurrentHashMap<>();
    
    /**
     * 发送给自己
     *
     * @param session          自己
     * @param wsRespResultEnum
     */
    static void sendMsg(WebSocketSession session, WsRespResultEnum wsRespResultEnum) {
        try {
            session.sendMessage(WsRespResult.send(wsRespResultEnum));
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
    
    /**
     * 发送给别人
     *
     * @param sessionTo        发送给
     * @param sessionForm      来自
     * @param wsRespResultEnum
     */
    static void sendMsg(WebSocketSession sessionTo, WebSocketSession sessionForm, WsRespResultEnum wsRespResultEnum) {
        try {
            // 获取发送者的名称
            HashMap<String, String> queryToMap = getQueryToMap(sessionForm);
            String formName = queryToMap.get("name");
            sessionTo.sendMessage(WsRespResult.send(wsRespResultEnum, formName));
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    /**
     * 通知在线人数（广播所有）
     *
     * @param webSocketSession 改动对象
     */
    static void updateUserNum(WebSocketSession webSocketSession) {
        wsSession.forEach((s, session) -> sendMsg(session, webSocketSession, WsRespResultEnum.USERNUM_UPDATE));
    }
}

```

#### 服务类在建立连接之后更新状态

```java
/**
 * 建立连接
 *
 * @param session
 */
@Override
public void afterConnectionEstablished(WebSocketSession session) {
    // 解析用户
    HashMap<String, String> queryToMap = WsSocketManage.getQueryToMap(session);
    String name = queryToMap.get("name");
    // 以用户名为key，存储连接
    WsSocketManage.add(name, session);
    log.info(name + "建立ws连接");
    log.info("当前在线人数：" + WsSocketManage.getUserNum());
    // 返回连接成功
    WsSocketManage.sendMsg(session, WsRespResultEnum.CONN_SUCCESS);
    // 更新所有已连接用户在线人数
    WsSocketManage.updateUserNum(session);
}
```

#### 服务类在断开连接后更新人数

```java
/**
 * 断开连接
 *
 * @param session
 * @param status
 */
@Override
public void afterConnectionClosed(WebSocketSession session, CloseStatus status) {
    // 获取断开连接的用户
    String name = WsSocketManage.getQueryToMap(session).get("name");
    // 移除session
    WsSocketManage.removeAndClose(name);
    // 更新所有已连接用户在线人数
    WsSocketManage.updateUserNum(session);
    log.info(name + "关闭ws连接");
    log.info("当前在线人数：" + WsSocketManage.getUserNum());
}
```

### html页面

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
</head>
<body>
<p>当前状态：<span id="state">未连接</span></p>
<p>当前在线人数：<span id="userNum"></span></p>
<button onclick="createConn()">建立连接</button>
<input type="text" id="name" placeholder="登录名">
<input type="text" id="inputVal" placeholder="发送消息">
<button onclick="sendMsg()">发送</button>
</body>

<script>
    let socket;

    const valid = (name) => {
        if (!name) {
            alert("登录名不可为空！")
            return false;
        }
        return true;
    }

    const sendMsg = () => {
        const name = document.getElementById("name").value
        if (!valid(name)) return
        socket.send(document.getElementById("inputVal").value)
    }
    const createConn = () => {
        const name = document.getElementById("name").value
        if (!valid(name)) return
        socket = new WebSocket(`ws://localhost:8081/ws/user?name=${name}`)
        socket.onmessage = (data) => {
            const {userNum, code} = JSON.parse(data.data)
            switch (code) {
                case 2000:
                    document.getElementById("state").innerText = '已连接！'
                    break;
                case 2001:
                    alert('消息已发送！')
                    break;
                case 2002:
                    document.getElementById("userNum").innerText = userNum
                    break;
            }
        }
    }
</script>
</html>
```

## 群体广播和指定人发送

### 管理类增加方法

```java
/**
 * 发送给别人
 *
 * @param sessionTo        发送给
 * @param sessionForm      来自
 * @param content          内容
 * @param wsRespResultEnum
 */
static void sendMsg(WebSocketSession sessionTo, WebSocketSession sessionForm, WsRespResultEnum wsRespResultEnum, String content) {
    try {
        // 获取发送者的名称
        HashMap<String, String> queryToMap = getQueryToMap(sessionForm);
        String formName = queryToMap.get("name");
        sessionTo.sendMessage(WsRespResult.send(wsRespResultEnum, formName, content));

        // 给发送者通知已成功
        sessionForm.sendMessage(WsRespResult.send(WsRespResultEnum.SENDMSG_SUCCESS));
    } catch (IOException e) {
        e.printStackTrace();
    }
}


/**
 * 广播（不包括自己）
 *
 * @param webSocketSession session 发起广播的对象
 */
static void sendToAll(WebSocketSession webSocketSession, String content) {
    wsSession.forEach((s, session) -> {
        String name = getQueryToMap(webSocketSession).get("name");
        if (!s.equals(name)) {
            sendMsg(session, webSocketSession, WsRespResultEnum.ACCEPT_FORMTOALL, content);
        }
    });
}

/**
 * 发送给某人
 *
 * @param webSocketSession 发送者session
 * @param name             目标用户名
 * @param content          内容
 */
static void sendToUser(WebSocketSession webSocketSession, String name, String content) {
    WebSocketSession toSession = get(name);
    sendMsg(toSession, webSocketSession, WsRespResultEnum.ACCEPT_FORMTOUSER, content);
}
```

### 服务类接收消息时

```java
/**
 * 收到消息
 *
 * @param session session对象
 * @param message 消息内容
 */
@Override
protected void handleTextMessage(WebSocketSession session, TextMessage message) {
    String payload = message.getPayload();
    Map parse = (Map) JSON.parse(payload);
    log.info("收到消息：" + parse);
    String state = (String) parse.get("state");
    String content = (String) parse.get("content");
    switch (state) {
        case "1":
            // 获取接收人
            String toName = (String) parse.get("toName");
            // 指定发送
            WsSocketManage.sendToUser(session, toName, content);
            break;
        case "2":
            // 广播
            WsSocketManage.sendToAll(session, content);
            break;
    }
}
```

> 前端传递格式： 
>
> ```json
> {
>     // 状态（1指定，2广播）
>     state: '',
>     // 发送内容
>     content: '',
>     // 有指定发送时携带接收人
>     toName: ''
> }
> ```

### html页面

增加指定发送人输入框，增加接收广播消息和指定消息

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
</head>
<body>
<div>
    <p>当前状态：<span id="state">未连接</span></p>
    <button onclick="createConn()">建立连接</button>
</div>
<p>当前在线人数：<span id="userNum"></span></p>
<div>
    <input type="text" id="name" placeholder="用户名">
</div>
<input type="text" id="inputVal" placeholder="发送消息">
<button onclick="sendMsgToAll()">发送广播</button>
<input type="text" id="sendToName" placeholder="发送给">
<button onclick="sendMsg()">发送给个人</button>
<div id="sendContent"></div>
</body>

<script>
    let socket;

    const valid = (name) => {
        if (!name) {
            alert("登录名不可为空！")
            return false;
        }
        return true;
    }

    const sendMsgToAll = () => {
        const name = document.getElementById("name").value
        if (!valid(name)) return
        socket.send(JSON.stringify({
            state: '2',
            content: document.getElementById("inputVal").value
        }))
    }

    const sendMsg = () => {
        const name = document.getElementById("name").value
        if (!valid(name)) return
        socket.send(JSON.stringify({
            state: '1',
            content: document.getElementById("inputVal").value,
            toName: document.getElementById("sendToName").value
        }))
    }
    const createConn = () => {
        let p
        let jsonContent
        const name = document.getElementById("name").value
        if (!valid(name)) return
        socket = new WebSocket(`ws://localhost:8081/ws/user?name=${name}`)
        socket.onmessage = (data) => {
            const jsonData = JSON.parse(data.data)
            switch (jsonData.code) {
                // 成功建立连接
                case 2000:
                    document.getElementById("state").innerText = '已连接！'
                    break;
                // 消息发送成功
                case 2001:
                    alert('消息已发送！')
                    break;
                // 显示在线人数
                case 2002:
                    document.getElementById("userNum").innerText = jsonData.userNum
                    break;
                // 接收广播消息
                case 2003:
                    // 动态添加元素节点
                    p = document.createElement("p")
                    jsonContent = JSON.parse(jsonData.content)
                    p.innerText = `收到来自${jsonData.formName}广播：${jsonContent}`
                    document.getElementById("sendContent").appendChild(p)
                    break;
                // 接收指定消息
                case 2004:
                    // 动态添加元素节点
                    p = document.createElement("p")
                    jsonContent = JSON.parse(jsonData.content)
                    p.innerText = `收到来自${jsonData.formName}私信：${jsonContent}`
                    document.getElementById("sendContent").appendChild(p)
                    break;
            }
        }
    }
</script>
</html>
```

> 后端发送广播和消息数据格式：
>
> ```json
> {
>     // 当前状态
>     code: '',
>     // 消息内容或事件名称
>     content: '',
>     // 来自用户名，只在指定发送有
>     formName: '',
>     // 当前在线人数
>     userNum: ''
> }
> ```

## 完整代码

### 服务类

socket > WsService.java

```java
package com.fsan.socket;

import com.alibaba.fastjson.JSON;
import com.fsan.stateEnum.WsRespResultEnum;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.AbstractWebSocketHandler;

import java.util.HashMap;
import java.util.Map;


@Slf4j
@Component
public class WsService extends AbstractWebSocketHandler {

    /**
     * 建立连接
     *
     * @param session
     */
    @Override
    public void afterConnectionEstablished(WebSocketSession session) {
        // 解析用户
        HashMap<String, String> queryToMap = WsSocketManage.getQueryToMap(session);
        String name = queryToMap.get("name");
        // 以用户名为key，存储连接
        WsSocketManage.add(name, session);
        log.info(name + "建立ws连接");
        log.info("当前在线人数：" + WsSocketManage.getUserNum());
        // 返回连接成功
        WsSocketManage.sendMsg(session, WsRespResultEnum.CONN_SUCCESS);
        // 更新所有已连接用户在线人数
        WsSocketManage.updateUserNum(session);
    }

    /**
     * 断开连接
     *
     * @param session
     * @param status
     */
    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) {
        // 获取断开连接的用户
        String name = WsSocketManage.getQueryToMap(session).get("name");
        // 移除session
        WsSocketManage.removeAndClose(name);
        // 更新所有已连接用户在线人数
        WsSocketManage.updateUserNum(session);
        log.info(name + "关闭ws连接");
        log.info("当前在线人数：" + WsSocketManage.getUserNum());
    }

    /**
     * 收到消息
     *
     * @param session session对象
     * @param message 消息内容
     */
    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) {
        String payload = message.getPayload();
        Map parse = (Map) JSON.parse(payload);
        log.info("收到消息：" + parse);
        String state = (String) parse.get("state");
        String content = (String) parse.get("content");
        switch (state) {
            case "1":
                // 获取接收人
                String toName = (String) parse.get("toName");
                // 指定发送
                WsSocketManage.sendToUser(session, toName, content);
                break;
            case "2":
                // 广播
                WsSocketManage.sendToAll(session, content);
                break;
        }
    }
}
```

### 管理类

scoket > WsSocketManage.java

```java
package com.fsan.socket;

import com.alibaba.fastjson.JSON;
import com.fsan.entity.WsRespResult;
import com.fsan.stateEnum.WsRespResultEnum;
import lombok.extern.slf4j.Slf4j;
import org.springframework.util.StringUtils;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;

import java.io.IOException;
import java.util.HashMap;
import java.util.concurrent.ConcurrentHashMap;

@Slf4j
public class WsSocketManage {
    private static ConcurrentHashMap<String, WebSocketSession> wsSession = new ConcurrentHashMap<>();

    /**
     * 添加socket连接
     *
     * @param key     键
     * @param session 对象
     */
    static void add(String key, WebSocketSession session) {
        wsSession.put(key, session);
    }

    /**
     * 删除socket连接
     *
     * @param key 键
     * @return 删除的session
     */
    static WebSocketSession remove(String key) {
        return wsSession.remove(key);
    }

    /**
     * 删除并同步关闭socket连接
     *
     * @param key 键
     */
    static void removeAndClose(String key) {
        WebSocketSession remove = wsSession.remove(key);
        if (!StringUtils.isEmpty(remove)) {
            try {
                remove.close();
            } catch (IOException e) {
                e.printStackTrace();
                // todo 关闭连接异常
            }
        }

    }


    /**
     * 获取socket连接
     *
     * @param key 键
     * @return session对象
     */
    static WebSocketSession get(String key) {
        return wsSession.get(key);
    }


    /**
     * 发送给自己
     *
     * @param session          自己
     * @param wsRespResultEnum
     */
    static void sendMsg(WebSocketSession session, WsRespResultEnum wsRespResultEnum) {
        try {
            session.sendMessage(WsRespResult.send(wsRespResultEnum));
        } catch (IOException e) {
            e.printStackTrace();
        }
    }


    /**
     * 发送给别人
     *
     * @param sessionTo        发送给
     * @param sessionForm      来自
     * @param wsRespResultEnum
     */
    static void sendMsg(WebSocketSession sessionTo, WebSocketSession sessionForm, WsRespResultEnum wsRespResultEnum) {
        try {
            // 获取发送者的名称
            HashMap<String, String> queryToMap = getQueryToMap(sessionForm);
            String formName = queryToMap.get("name");
            sessionTo.sendMessage(WsRespResult.send(wsRespResultEnum, formName));
        } catch (IOException e) {
            e.printStackTrace();
        }
    }


    /**
     * 发送给别人
     *
     * @param sessionTo        发送给
     * @param sessionForm      来自
     * @param content          内容
     * @param wsRespResultEnum
     */
    static void sendMsg(WebSocketSession sessionTo, WebSocketSession sessionForm, WsRespResultEnum wsRespResultEnum, String content) {
        try {
            // 获取发送者的名称
            HashMap<String, String> queryToMap = getQueryToMap(sessionForm);
            String formName = queryToMap.get("name");
            sessionTo.sendMessage(WsRespResult.send(wsRespResultEnum, formName, content));

            // 给发送者通知已成功
            sessionForm.sendMessage(WsRespResult.send(WsRespResultEnum.SENDMSG_SUCCESS));
        } catch (IOException e) {
            e.printStackTrace();
        }
    }


    /**
     * 获取在线人数
     *
     * @return integer
     */
    public static Integer getUserNum() {
        return wsSession.size();
    }


    /**
     * 获取请求session中参数map
     *
     * @param session session 对象
     * @return HashMap
     */
    static HashMap<String, String> getQueryToMap(WebSocketSession session) {
        String query = session.getUri().getQuery();
        HashMap<String, String> map = new HashMap<>();
        for (String s : query.split("&")) {
            String[] s1 = s.split("=");
            map.put(s1[0], s1[1]);
        }
        return map;
    }


    /**
     * 通知在线人数（广播所有）
     *
     * @param webSocketSession 改动对象
     */
    static void updateUserNum(WebSocketSession webSocketSession) {
        wsSession.forEach((s, session) -> sendMsg(session, webSocketSession, WsRespResultEnum.USERNUM_UPDATE));
    }


    /**
     * 广播（不包括自己）
     *
     * @param webSocketSession session 发起广播的对象
     */
    static void sendToAll(WebSocketSession webSocketSession, String content) {
        wsSession.forEach((s, session) -> {
            String name = getQueryToMap(webSocketSession).get("name");
            if (!s.equals(name)) {
                sendMsg(session, webSocketSession, WsRespResultEnum.ACCEPT_FORMTOALL, content);
            }
        });
    }

    /**
     * 发送给某人
     *
     * @param webSocketSession 发送者session
     * @param name             目标用户名
     * @param content          内容
     */
    static void sendToUser(WebSocketSession webSocketSession, String name, String content) {
        WebSocketSession toSession = get(name);
        sendMsg(toSession, webSocketSession, WsRespResultEnum.ACCEPT_FORMTOUSER, content);
    }
}
```

### 返回包装类

entity > WsRespResult.java

```java
package com.fsan.entity;

import com.alibaba.fastjson.JSON;
import com.fsan.stateEnum.WsRespResultEnum;
import com.fsan.socket.WsSocketManage;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.web.socket.TextMessage;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class WsRespResult {
    private Integer code;
    private Object content;
    private Integer userNum;
    private String formName;


    /**
     * 发送给自己
     * @return
     */
    public static TextMessage send(WsRespResultEnum respResultEnum) {
        WsRespResult respResult = new WsRespResult();
        respResult.setCode(respResultEnum.getCode());
        respResult.setContent(respResultEnum.getContent());
        respResult.setUserNum(WsSocketManage.getUserNum());
        return new TextMessage(JSON.toJSONString(respResult));
    }

    /**
     * 发送给对方
     * @return
     */
    public static TextMessage send(WsRespResultEnum respResultEnum, String formName) {
        WsRespResult respResult = new WsRespResult();
        respResult.setCode(respResultEnum.getCode());
        respResult.setContent(respResultEnum.getContent());
        respResult.setFormName(formName);
        respResult.setUserNum(WsSocketManage.getUserNum());
        return new TextMessage(JSON.toJSONString(respResult));
    }

    /**
     * 发送给对方（有内容）
     * @return
     */
    public static TextMessage send(WsRespResultEnum respResultEnum, String formName, String content) {
        WsRespResult respResult = new WsRespResult();
        respResult.setCode(respResultEnum.getCode());
        respResult.setContent(content);
        respResult.setFormName(formName);
        respResult.setUserNum(WsSocketManage.getUserNum());
        return new TextMessage(JSON.toJSONString(respResult));
    }
}
```

### 状态枚举类

stateEnum > WsRespResultEnum.java

```java
package com.fsan.stateEnum;

public enum WsRespResultEnum {
    CONN_SUCCESS(2000, "连接成功"),
    SENDMSG_SUCCESS(2001, "发送消息成功"),
    USERNUM_UPDATE(2002, "广播所有更新在线人数"),
    ACCEPT_FORMTOALL(2003, "接收到广播消息"),
    ACCEPT_FORMTOUSER(2004, "接收到个人消息");

    private Integer code;
    private Object content;

    WsRespResultEnum(Integer code, Object content) {
        this.code = code;
        this.content = content;
    }

    public Integer getCode() {
        return code;
    }

    public Object getContent() {
        return content;
    }
}
```

### socket配置类

config > SocketConfig.java

```java
package com.fsan.config;

import com.fsan.socket.WsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.socket.config.annotation.EnableWebSocket;
import org.springframework.web.socket.config.annotation.WebSocketConfigurer;
import org.springframework.web.socket.config.annotation.WebSocketHandlerRegistry;

@Configuration
@EnableWebSocket
public class SocketConfig implements WebSocketConfigurer {

    @Autowired
    private WsService wsService;

    @Override
    public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
        registry
                // 添加socket服务
                .addHandler(wsService, "/ws/user")
                // 允许跨域
                .setAllowedOrigins("*");

    }
}
```

### html页面

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
</head>
<body>
<div>
    <p>当前状态：<span id="state">未连接</span></p>
    <button onclick="createConn()">建立连接</button>
</div>
<p>当前在线人数：<span id="userNum"></span></p>
<div>
    <input type="text" id="name" placeholder="用户名">
</div>
<input type="text" id="inputVal" placeholder="发送消息">
<button onclick="sendMsgToAll()">发送广播</button>
<input type="text" id="sendToName" placeholder="发送给">
<button onclick="sendMsg()">发送给个人</button>
<div id="sendContent"></div>
</body>

<script>
    let socket;

    const valid = (name) => {
        if (!name) {
            alert("登录名不可为空！")
            return false;
        }
        return true;
    }

    const sendMsgToAll = () => {
        const name = document.getElementById("name").value
        if (!valid(name)) return
        socket.send(JSON.stringify({
            state: '2',
            content: document.getElementById("inputVal").value
        }))
    }

    const sendMsg = () => {
        const name = document.getElementById("name").value
        if (!valid(name)) return
        socket.send(JSON.stringify({
            state: '1',
            content: document.getElementById("inputVal").value,
            toName: document.getElementById("sendToName").value
        }))
    }
    const createConn = () => {
        let p
        let jsonContent
        const name = document.getElementById("name").value
        if (!valid(name)) return
        socket = new WebSocket(`ws://localhost:8081/ws/user?name=${name}`)
        socket.onmessage = (data) => {
            const jsonData = JSON.parse(data.data)
            console.log(jsonData);
            switch (jsonData.code) {
                // 成功建立连接
                case 2000:
                    document.getElementById("state").innerText = '已连接！'
                    break;
                // 消息发送成功
                case 2001:
                    alert('消息已发送！')
                    break;
                // 显示在线人数
                case 2002:
                    document.getElementById("userNum").innerText = jsonData.userNum
                    break;
                // 接收广播消息
                case 2003:
                    // 动态添加元素节点
                    p = document.createElement("p")
                    jsonContent = JSON.parse(jsonData.content)
                    p.innerText = `收到来自${jsonData.formName}广播：${jsonContent}`
                    document.getElementById("sendContent").appendChild(p)
                    break;
                // 接收指定消息
                case 2004:
                    // 动态添加元素节点
                    p = document.createElement("p")
                    jsonContent = JSON.parse(jsonData.content)
                    p.innerText = `收到来自${jsonData.formName}私信：${jsonContent}`
                    document.getElementById("sendContent").appendChild(p)
                    break;
            }
        }
    }
</script>
</html>
```

### 最后说明

封装的比较烂，轻喷
