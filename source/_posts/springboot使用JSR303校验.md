---
title: SpringBoot使用JSR303校验
date: 2022-6-23 13:49:14
tags: [springboot,jsr303]
categories: [后端,java]
---

# 关于JSR303
JSR-303 是JAVA EE 6 中的一项子规范，叫做Bean Validation，Hibernate Validator 是 Bean Validation 的参考实现 . Hibernate Validator 提供了 JSR 303 规范中所有内置 constraint 的实现，除此之外还有一些附加的 constraint。

# 引入依赖

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-validation</artifactId>
</dependency>
```

> 可以直接从spring项目创建时快捷引入

# 校验常用注解

| 注解名   | 作用                                                         |
| -------- | ------------------------------------------------------------ |
| @Null    | 被注释的属性必须为null                                       |
| @NoNull  | 被注释的属性不为null                                         |
| @Min     | 注释在数字类型上，被注释的属性最小值                         |
| @Max     | 同上，被注释的属性最大值                                     |
| @Size    | 注释在字符类型上，被注释的属性的长度限制，如 `@Size(min=3, max=9)` |
| @Pattern | 被注释的属性满足其中的正则规则                               |

> 以上大部分注释都由message属性，表示自定义异常信息

# 简单校验

简单校验就是在一个实体类上对元素写上注释限制，如：

## 实体类（User）

```java
@Data
public class User {
    @TableId(type = IdType.AUTO)
    private Long userId;
    @Size(min = 3, max = 9,message = "用户名由三位到九位字符组成")
    @NotNull(message = "用户名不可为空！")
    private String username;
    @Size(min = 4, max = 12, message = "密码由四位到十二位字符组成")
    @NotNull(message = "密码不可为空！")
    private String password;
    private String sex;
    private String avatar;
    private Long classId;
    private Long roleId;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
    @TableLogic
    private String delLogic;
}
```

## Controller演示

```java
@PostMapping("/valid")
public User valid(@Valid @RequestBody User user, BindingResult result){
    // 解析校验结果
    result.getAllErrors().forEach(e -> {
        // 校验异常的消息
        System.out.println(e.getDefaultMessage());
        // 校验异常的属性
        System.out.println(e.getObjectName());
    });
    return user;
}
```

对于简单的校验来说，需要给校验的属性或实体类使用`@Valid`注解开启校验，在方法后跟上`BindingResult`用于收集jsr303所抛出的校验异常

# 分组校验

分组校验的实际使用常见为：当你有两个接受对象都是同一个实体类，但是类似注册和登录，注册需要填入邮箱地址，登录不需要，这时候就需要对邮箱地址这个属性定义分组校验

分组校验的规则为：在类上的规则后跟上`groups`属性，写一个简单的接口表示一个组即可，如：

## 实体类（User）

```java
@Data
public class User {
    @TableId(type = IdType.AUTO)
    private Long userId;
    @Size(min = 3, max = 9,message = "用户名由三位到九位字符组成",groups = {LoginDto.class, RegisterDto.class})
    @NotNull(message = "用户名不可为空！", groups = {LoginDto.class, RegisterDto.class})
    private String username;
    @Size(min = 4, max = 12,message = "密码由四位到十二位字符组成",groups = {LoginDto.class, RegisterDto.class})
    @NotNull(message = "密码不可为空！", groups = {LoginDto.class, RegisterDto.class})
    private String password;
    private String sex;
    private String avatar;
    private Long classId;
    private Long roleId;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
    @TableLogic
    private String delLogic;
    
    public interface LoginDto{}
    public interface RegisterDto{}
}
```

> 对于一个属性，校验的组可有多个

## Controller演示

```java
@PostMapping("/valid")
public User valid(@Validated(User.LoginDto.class) @RequestBody User user, BindingResult result){
    result.getAllErrors().forEach(e -> {
        System.out.println(e.getDefaultMessage());
        System.out.println(e.getObjectName());
    });
    return user;
}
```

在普通的校验中，使用的是@Valid注解，但是在分组校验中，`@Valid`没有分组的功能，所以要使用`@Validated` ，传入的value值为实体类中定义的分组接口类

> JSR303本身的`@Valid`并不支持分组校验，但是Spring在其基础提供了一个注解`@Validated`支持分组校验。`@Validated`这个注解`value`属性指定需要校验的分组。

# 嵌套校验

同名字，等于在一个Dto或实体类中包含其他实体类的校验情况，加上@Valid即可，就不演示了
