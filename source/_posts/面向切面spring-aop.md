---
title: 面向切面spring aop
date: 2022-05-16 20:22:28
tags: [java,aop]
categories: [[后端,java]]
---
# 介绍
AOP （Aspect Orient Programming）,直译过来就是 面向切面编程。AOP 是一种编程思想，是面向对象编程（OOP）的一种补充。面向对象编程将程序抽象成各个层次的对象，而面向切面编程是将程序抽象成各个切面。

# 导入依赖

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-aop</artifactId>
</dependency>
```

# 切面通知注解和执行顺序
## 五种通知注解
| 注解名         | 用法                             |
| -------------- | -------------------------------- |
| @Before        | 前置通知, 在方法执行之前执行     |
| @After         | 后置通知, 在方法执行之后执行     |
| @AfterRunning  | 返回通知, 在方法返回结果之后执行 |
| @AfterThrowing | 异常通知, 在方法抛出异常之后     |
| @Around        | 环绕通知, 围绕着方法执行         |
## 执行顺序
1. @Around
2. @Before
3. 执行方法
4. @Around
5. @After
6. @AfterReturning


# 切点@Pointcut

## 切点表达式标签（10种）

| 标记名      | 作用                                                         |
| ----------- | ------------------------------------------------------------ |
| execution   | 用于匹配方法执行的连接点                                     |
| within      | 用于匹配指定类型内的方法执行                                 |
| this        | 用于匹配当前AOP代理对象类型的执行方法；注意是AOP代理对象的类型匹配，这样就可能包括引入接口也类型匹配 |
| target      | 用于匹配当前目标对象类型的执行方法；注意是目标对象的类型匹配，这样就不包括引入接口也类型匹配 |
| args        | 用于匹配当前执行的方法传入的参数为指定类型的执行方法         |
| @within     | 用于匹配所以持有指定注解类型内的方法                         |
| @target     | 用于匹配当前目标对象类型的执行方法，其中目标对象持有指定的注解 |
| @args       | 用于匹配当前执行的方法传入的参数持有指定注解的执行           |
| @annotation | 用于匹配当前执行方法持有指定注解的方法                       |
| bean        | Spring AOP扩展的，AspectJ没有对于指示符，用于匹配特定名称的Bean对象的执行方法 |

如：

```java
@Pointcut("execution(* com.javacode2018.aop.demo9.test1.Service1.*(..))")
```

## 关于切点中execution表达式

### 常用写法

`execution(public * *(..))`	 表示匹配所有public方法

`execution(* set*(..))`	表达所有以“set”开头的方法

`execution(* com.xyz.service.AccountService.*(..))`	表示匹配所有AccountService接口的方法

`execution(* com.xyz.service.*.*(..))`	表示匹配service包下的所有方法

`execution(* com.xyz.service..*.*(..))`	表示匹配service包和它的子包下的方法

`execution(* *To(..))`	匹配目标类所有以To为后缀的方法

### 基本语法如下：

execution(<修饰符模式>?<返回类型模式><方法名模式>(<参数模式>)<异常模式>?) 除了返回类型模式、方法名模式和参数模式外，其它项都是可选的。

如：`execution(* com.xyz.service.impl..*.*(..))`	解释如下

| 符号                 | 含义                                                 |
| -------------------- | ---------------------------------------------------- |
| 第一个 “  *  ”       | 表示返回值的类型任意                                 |
| com.xyz.service.impl | aop所切的包名                                        |
| 包名后的 “  ..  ”    | 表示当前包及子类                                     |
| 第二个 “  *  ”       | 表示类名，* 即所有类                                 |
| .\*(..)              | 表示任何方法名，括号表示参数，两个点表示任何参数类型 |

# 实现简单的控制台日志

## 输出日志（使用注解控制）

### 自定义注解

因为要演示对被自定义注解标记的类做切面，所以先建立一个自定义注解

annotation > LookResult

```java
package com.fsan.annotation;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Target({ElementType.METHOD, ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
public @interface LookResult {
}
```

在controller处使用

```java
package com.fsan.controller;

import com.fsan.annotation.LookResult;
import com.fsan.annotation.PackResult;
import com.fsan.entity.User;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@PackResult
@RestController
@RequestMapping("/user")
public class UserController {

    @PostMapping("/login")
    @LookResult
    public User login() {
        return new User(1L, "FSAN", "FSAN");
    }
}
```


### 建立切面类

创建 aspect > LogAsp.java

```java
package com.fsan.aspect;

import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;
import org.springframework.stereotype.Component;

@Slf4j
@Aspect
@Component
public class LogAsp {
    
    @Pointcut("@annotation(com.fsan.annotation.LookResult)")
    public void haveLookResultCut() {
    }
    
    @AfterReturning(pointcut = "haveLookResultCut()", returning = "result")
    public void doAfterReturning(JoinPoint joinPoint, Object result) {
        // 获取RequestAttributes
        RequestAttributes requestAttributes = RequestContextHolder.getRequestAttributes();
        // 从获取RequestAttributes中获取HttpServletRequest的信息
        HttpServletRequest request = (HttpServletRequest) requestAttributes
                .resolveReference(RequestAttributes.REFERENCE_REQUEST);

        // 从切面织入点处通过反射机制获取织入点处的方法
        MethodSignature signature = (MethodSignature) joinPoint.getSignature();
        // 获取切入点所在的方法
        Method method = signature.getMethod();

        log.info("==========收到请求==========");
        log.info("请求类名：" + joinPoint.getTarget().getClass().getName());
        log.info("请求方法名：" + method.getName());
        log.info("返回结果：" + JSON.toJSONString(result));
        log.info("请求ip：" + request.getRemoteAddr());
        log.info("==========完毕==========");
    }
}
```

> @Component 必须带上
>
> `@Pointcut("@annotation(com.fsan.annotation.LookResult)") `	为拥有`LookResult`注解的方法建立切点
>
> `@AfterReturning`修饰的注解有两个参数，第一个是切点信息，第二个是方法的方法的返回值

## 错误日志（控制某个包下的所有类）

### 在切面类中使用@AfterThrowing

```java
@AfterThrowing(pointcut = "execution(* com.fsan.service.impl.*.*(..))", throwing = "e")
public void logCutAfterThrowing(JoinPoint joinPoint, Throwable e) {
    log.error("==========程序出现异常==========");
    MethodSignature signature = (MethodSignature) joinPoint.getSignature();
    Method method = signature.getMethod();
    log.error("请求类名：" + joinPoint.getTarget().getClass().getName());
    log.error("请求方法名：" + method.getName());
    log.error("报错原因：" + e.getMessage());
    log.error("==========完毕==========");
}
```

>`@AfterThrowing(pointcut = "execution(* com.fsan.service.impl.*.*(..))", throwing = "e")`	pointcut属性也可以像上面一样先定义切面方法，语法详细看上面，接收错误信息为e

### 跳过某个异常

在有自定义异常的时候，不想输出自己的自定义异常，就可以这样做

```java
@AfterThrowing(pointcut = "execution(* com.fsan.service.impl.*.*(..))", throwing = "e")
public void logCutAfterThrowing(JoinPoint joinPoint, Throwable e) {
    boolean b = e instanceof ValidateException;
    if (!b) {
        log.error("==========程序出现异常==========");
        MethodSignature signature = (MethodSignature) joinPoint.getSignature();
        Method method = signature.getMethod();
        log.error("请求类名：" + joinPoint.getTarget().getClass().getName());
        log.error("请求方法名：" + method.getName());
        log.error("报错原因：" + e.getMessage());
        log.error("==========完毕==========");
    }
}
```

# 其他切点表达式写法

## 定义测试切点（controller下所有类下方法）

```java
@Pointcut("execution(* com.fsan.controller.*.*(..))")
public void demoCut(){}
```

## @Before前置通知

在目标方法的执行之前执行，即在连接点之前进行执行

```java
@Before("demoCut()")
public void doBefore(JoinPoint joinPoint) {
    String methodName = joinPoint.getSignature().getName();
    List<Object> args = Arrays.asList(joinPoint.getArgs());
    log.info("调用方法为：" + methodName);
    log.info("参数为：" + args);
}
```

## @After后置通知

无论连接点方法执行成功还是出现异常，都将执行后置方法。

```java
@After("demoCut()")
public void doAfter(JoinPoint joinPoint){
    String methodName = joinPoint.getSignature().getName();
    List<Object> args = Arrays.asList(joinPoint.getArgs());
    log.info("调用方法为：" + methodName);
    log.info("参数为：" + args);
}
```

方法参数同@before

## @AfterRunning返回通知

当连接点方法成功执行后，返回通知方法才会执行

不演示了，上面有实例

## @AfterThrowing异常通知

异常通知方法只在连接点方法出现异常后才会执行

同不演示了，上面有例子

## @Around环绕通知

环绕通知方法可以包含上面四种通知方法，环绕通知的功能最全面。

```java
@Around("demoCut()")
public Object doAround(ProceedingJoinPoint pdj) {
    // @Before 之前
    String methodName = pdj.getSignature().getName();
    log.info("目标方法为：" + methodName);
    log.info("参数为：" + Arrays.asList(pdj.getArgs()));

    // 准备接收手动执行方法后的返回结果
    Object result = null;

    try {
        // 执行目标方法
        result = pdj.proceed();

        // 返回通知 同 @AfterRunning
        log.info("返回通知消息（环绕通知中）：方法名：" + methodName);
        log.info("返回通知消息（环绕通知中）：返回结果：" + result);
    } catch (Throwable e) {
        // 异常通知 同 @AfterThrowing
        log.info("异常通知消息（环绕通知中）：方法名：" + methodName);
        log.info("异常通知消息（环绕通知中）：异常为：" + e);
    }

    // 后置通知，同 @After
    log.info("后置通知（环绕通知中），方法名：" + methodName);

    // 在返回之前对返回结果进行处理，但是必须要满足原返回类型
    return result;
}
```
