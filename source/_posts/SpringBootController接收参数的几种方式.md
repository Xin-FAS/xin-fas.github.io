---
title: SpringBootController接收参数的几种方式
date: 2021-08-19 15:44:26
tags: [springboot]
categories: [后端,java]
---

Controller接收参数的常用方法总体可以分为三类
第一类：Get请求通过拼接url进行传递
第二类：Post请求通过请求体进行传递
第三类：通过请求头部进行参数传递。

### @PathVariable 接收参数

请求方式：localhost:8080/login/FSAN

代码示例：
```java
@ResponseBody
@GetMapping("login/{name}")
public void loginUser(@PathVariable String name){
    System.out.println(name);
}
```

### @RequestParam 接收参数

使用这个注解需要注意两个点，一是加了这个参数后则请求中必须传递这个参数，二是@RequestParam这个注解可以指定名字，请求参数必须和指定的这个名字相同，如果不指定，则默认为具体参数名

请求方式：localhost:8080/login?name=FSAN

代码示例：
```java
@ResponseBody
@GetMapping("login")
public void loginUser(@RequestParam("name") String name) {
    System.out.println(name);
}
```

### 无注解传参

这种方式和第2点对比，最大的区别就是这个参数不是必传的，请求路径上可以不传递。

请求方式：localhost:8080/login?name=FSAN

代码示例：
```java
@ResponseBody
@GetMapping("login")
public void loginUser(String name) {
    System.out.println(name);
}
```

### HttpServletRequest 接收参数

请求方式：localhost:8080/login?name=FSAN

代码示例：
```java
@ResponseBody
@GetMapping("login")
public void loginUser(HttpServletRequest httpServletRequest) {
    String name = httpServletRequest.getParameter("name");
    System.out.println(name);
}
```

### @RequestBody 接收请求体参数

这种方式一般用来传递实体对象，加了这个注解后，参数也是必传的。

请求方式：{“name”: FSAN}

代码示例：
```java
@PostMapping("getName")
public void printName(@RequestBody String name) {
    System.out.println(name);
}
```

### @RequestHeader 接收请求头参数

请求方式：将name = FSAN添加到请求头里

代码示例：
```java
@PostMapping("getHeader")
public String getHeader(@RequestHeader String name){
    return "name=" + name;
}
```