---
title: SpringSecurity
date: 2022-03-22 23:45:33
tags: [SpringBoot,Spring Security]
categories: [[后端,Java]]
---

## SpringSecurity介绍

spring security是spring家族中的一个安全管理框架，相对与另外一个安全框架shiro，提供了更丰富的功能（shiro上手更加简单）

一般web应用都需要进行认证和授权：

1. 认证（验证当前访问系统的是不是本系统的用户，并且要确认具体是哪个用户）
2. 授权（经过认证后判断当前哟怒是否有权限进行某个操作）

而认证和授权也是spring security作为安全框架的核心功能。

## 请求到security内部执行的流程

spring security的原理其实就是一个过滤器链，内部包含了提供各种功能的过滤器（Filter）。

### 请求过程：

请求 --->  经过`UsernamePasswordAuthenticationFilter`---> 经过`ExceptionTranslationFilter `---> 经过`FilterSecurityInterceptor` ---> API

>UsernamePasswordAuthenticationFilter（表单登录过滤器）
>
>> 负责处理我们再登录页面填写了用户名密码后的登录请求。
>
>ExceptionTranslationFilter（统一异常处理过滤器）
>
>> 处理过滤器链中抛出的任何AccessDeniedException和AuthenticationException.
>
>FilterSecurityInterceptor（过滤器链中最后一个过滤器，负责权限校验）
>
>> 获取当前request对应的权限配置
>>
>> 调用访问控制器进行鉴权操作等核心功能

### 响应过程

响应也是需要再反过来走一遍过滤器的

APi ---> 经过`FilterSecurityInterceptor` ---> 经过`ExceptionTranslationFilter` ---> 经过`UsernamePasswordAuthenticationFilter` ---> 响应

## 思路分析

### 登录：

1. 自定义登录接口
   1. 调用`ProviderManager`的方法进行认证，通过则生成jwt返回
   2. 把用户信息存入redis（先`序列化redis`）
2. 自定义类实现`UserDetailsService`，将认证过程改为数据库查询（配合`LambdaQueryWrapper`）

>ProviderManager 是 spring security提供的`AuthenticationManager`实现。其主要目的，也就是实现AuthenticationManager接口所定义的方法。
>
>序列化redis：使用fastjson修改序列化redis，使其存入和取出的样式统一，具体代码可以cv
>
>LambdaQueryWrapper：`mybatis-plus`中使用`lambda`表达式写条件查询

### 校验：

1. 定义`jwt`认证过滤器
   1. 获取token
   2. 解析token获取其中的userId
   3. 使用userId从redis中查询用户信息
   4. 存入`SecurityContextHolder`供后续过滤器调用

## 准备工作

1. 启动springboot项目，引入redis，security
2. 导入redis工具类（见redis使用fastjson序列化）
3. 导入jwt和对应工具类（见jjwt工具类）
4. 导入mybatis-plus
5. 配置yml连接mysql和redis
6. 在yml修改security用户名和密码

## 数据库校验用户

### 数据库准备

创建RBAC数据库结构，写对应的实体类（使用@TableName可以mybatis-plus映射指定数据表，并不需要表名一致）

### 写一个类实现UserDetailsService，重写loadUserByUsername

```java
package com.fsan.springsecurity.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.fsan.springsecurity.mapper.SysUserMapper;
import com.fsan.springsecurity.pojo.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.Objects;

@Service
public class UserDetailsServiceImpl implements UserDetailsService {

    @Autowired
    private SysUserMapper sysUserMapper;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {

//         炫技写法：可读性没有下面好
//        List<User> user = new LambdaQueryChainWrapper<>(sysUserMapper)
//                .eq(User::getUserName, username)
//                .list();

        LambdaQueryWrapper<User> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(User::getUserName, username);
        User user = sysUserMapper.selectOne(queryWrapper);

        // 如果没有查询到用户就抛出异常
        if (Objects.isNull(user)){
            throw new RuntimeException("用户名或者密码错误！");
        }

        // TODO 查询对应的权限信息

        // TODO 将数据封装为UserDetails返回
    }
}
```

> 这是使用的条件包装器为LambdaQueryWrapper，并不是传统的QueryWrapper，LambdaQueryWrapper更好用
>
> 使用 Objects.isNull(user) 判断对象是否为空
>
> QueryWrapper到LambdaQueryWrapper的演变见 https://blog.csdn.net/qlzw1990/article/details/116996422

因为loadUserByUsername返回的是UserDetails类型数据，创建一个实体类实现UserDetails，将所有方法重写，并改为返回true

### 创建一个实体类实现UserDetails

```java
package com.fsan.springsecurity.pojo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class LoginUser implements UserDetails {

    private User user;

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return null;
    }

    @Override
    public String getPassword() {
        return user.getPassword();
    }

    @Override
    public String getUsername() {
        return user.getUserName();
    }

    /**
     * true表示没过期
     * @return
     */
    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    /**
     * 是否可用
     * @return
     */
    @Override
    public boolean isEnabled() {
        return true;
    }
}
```

>这里的getUsername和getPassword要改为User实体类的提供的方法，否则数据存入之后，调用getUsername拿取不到这里的getUsername和getPassword要改为User实体类的提供的方法，否则数据存入之后，调用getUsername拿取不到

在`loadUserByUsername`中调用mybatis-plus查询数据库，返回的类型为`UserDetails`对象，但是LoginUser已经对UserDetails类重写了，所以直接`返回LoginUser对象`即可，直接传入查询到的User类型的数据:

```java
package com.fsan.springsecurity.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.fsan.springsecurity.mapper.SysUserMapper;
import com.fsan.springsecurity.pojo.LoginUser;
import com.fsan.springsecurity.pojo.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.Objects;

@Service
public class UserDetailsServiceImpl implements UserDetailsService {

    @Autowired
    private SysUserMapper sysUserMapper;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {

//         炫技写法：可读性没有下面好
//        List<User> user = new LambdaQueryChainWrapper<>(sysUserMapper)
//                .eq(User::getUserName, username)
//                .list();

        LambdaQueryWrapper<User> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(User::getUserName, username);
        User user = sysUserMapper.selectOne(queryWrapper);

        // 如果没有查询到用户就抛出异常
        if (Objects.isNull(user)){
            throw new RuntimeException("用户名或者密码错误！");
        }

        // TODO 查询对应的权限信息

        // 将数据封装为UserDetails返回
        return new LoginUser(user);
    }
}
```

## 密码加密校验

返回的`UserDetails`对象会经过权限过滤器，在权限过滤器中判断输入的用户名，密码和`UserDetails`中存储的用户名密码，但是`UserDetails`对象中默认的密码格式为：`{id}password`，security会根据id判断密码的加密方式，我们一般不会采用默认的方式，所以就需要将`PasswordEncoder`替换为`BCryptPasswordEncoder`

### 测试BCryptPasswordEncoder类的加密和判断：

```java
// 字符串加密：
new BCryptPasswordEncoder().encode("FSAN")    //$2a$10$k8s4LDg6q.QhotMfb/jWCO/fu7nYvAalQveRfwMXj6FVy9/84Mg7G
    
// 字符串解析，是否和同字符串
new BCryptPasswordEncoder().matches("FSAN", "$2a$10$qNin1NOP265Zqme378882uxos.haI3Da9JCi3gPg65GOHb/5t1oGO")  // true
```

>对一个字符串，重复使用加密后也是不同的，内部是随机加盐生成的

### 定义一个Security的配置类，继承WebSecurityConfigurerAdapter，注入BCryptPasswordEncoder

```java
package com.fsan.springsecurity.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

@Configuration
public class SecurityConfig extends WebSecurityConfigurerAdapter {

    @Bean
    public PasswordEncoder passwordEncoder(){
        return new BCryptPasswordEncoder();
    }
}
```

> 也算是使用@Bean修改passwordEncoder
>
> 直接@Autowired注入使用passwordEncoder.encode("FSAN")

## security配置

1. 关闭csrf
2. 不使用session获取SecurityContent
3. 配置不登录就可以访问的接口（匿名登陆）

```java
@Override
protected void configure(HttpSecurity http) throws Exception {
    http
            // 关闭csrf
            .csrf().disable()
            // 不使用session获取securityContent
            .sessionManagement().sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            .and()
            .authorizeRequests()
            // 对于登录接口 允许不登陆使用（允许匿名访问）
            .antMatchers("/user/login").anonymous()
            // 除上面外的所有请求全部需要鉴权认证
            .anyRequest().authenticated();
}
```

### 注入AuthenticationManager权限管理

```java
/**
 * 重写一次AuthenticationManager再使用@Bean注入即可
 *
 * @return
 * @throws Exception
 */
@Bean
@Override
public AuthenticationManager authenticationManagerBean() throws Exception {
    return super.authenticationManagerBean();
}
```

## 写登录的controller和service

**controller:**

```java
package com.fsan.springsecurity.controller;

import com.fsan.springsecurity.pojo.ResponseResult;
import com.fsan.springsecurity.pojo.User;
import com.fsan.springsecurity.service.impl.LoginServiceImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
public class LoginController {

    @Autowired
    private LoginServiceImpl loginService;
    /**
     * 登录请求应该是post请求，数据在请求体中json传递
     * @return
     */
    @PostMapping("/user/login")
    public ResponseResult login(@RequestBody User user) {
        return loginService.login(user);
    }
}
```

**service:**

```java
package com.fsan.springsecurity.service.impl;

import com.fsan.springsecurity.Utils.JwtUtil;
import com.fsan.springsecurity.pojo.LoginUser;
import com.fsan.springsecurity.pojo.ResponseResult;
import com.fsan.springsecurity.pojo.User;
import com.fsan.springsecurity.service.LoginService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Objects;

@Service
public class LoginServiceImpl implements LoginService {

    @Autowired
    private AuthenticationManager authenticationManager;

    @Override
    public ResponseResult login(User user) {
        // AuthenticationManager authenticate 进行用户认证
        UsernamePasswordAuthenticationToken authenticationToken = new UsernamePasswordAuthenticationToken(user.getUserName(), user.getPassword());
        Authentication authenticate = authenticationManager.authenticate(authenticationToken);

        // 如果认证没通过，给出相应的提示
        if (Objects.isNull(authenticate)) {
            throw new RuntimeException("登录失败！");
        }

        // 如果认证通过了，先使用UserDetail类型接收，再使用userId生成一个jwt，jwt存入ResponseResult进行返回
        LoginUser loginUser = (LoginUser) authenticate.getPrincipal();
        String userId = loginUser.getUser().getId().toString();
        String token = JwtUtil.createJWT("token", 10, userId);
        // 把完整的用户信息存入redis，userId作为key，使用传入键值对
        HashMap<String, String> dataMap = new HashMap<>();
        dataMap.put("token", token);
        return new ResponseResult(200, dataMap);
    }
}
```

> 使用注入的authenticationManager的authenticate方法传入一个AuthenticationManager类型
>
> 使用`UsernamePasswordAuthenticationToken`，传入用户名和密码即可
>
> `authenticate.getPrincipal()`可以拿取UserDetails类型数据，因为之前的LoginUser实体类已经实现了UserDetails，可以直接接收，使用（LoginUser）指定类型
>
> loginUser.getUser().getId() 拿取登录用户的id，使用jwt的工具类以用户的id生成唯一密钥为"token"，过期时间为10分钟的token
>
> 将返回的消息封装返回，使用map可以使data如{token: 'token'}这种格式

## 到此用户登录请求完毕，开始做jwt过滤器

jwt过滤器主要的功能是接收前端放在请求头的token，使用token获取用户信息，存入`SecurityContextHolder`供后续模块调用

### 定义过滤器

1. 建立filter 下 JwtAuthenticationTokenFilter文件
2. 继承OncePerRequestFilter重写doFilterInternal方法

**需要实现的操作:**

1. 获取请求过来携带的token
2. 解析token
3. 向redis获取用户信息
4. 将用户信息存入SecurityContextHolder

```java
package com.fsan.springsecurity.filter;

import com.fsan.springsecurity.Utils.JwtUtil;
import com.fsan.springsecurity.Utils.RedisUtil;
import com.fsan.springsecurity.pojo.LoginUser;
import io.jsonwebtoken.Claims;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Objects;

@Component
public class JwtAuthenticationTokenFilter extends OncePerRequestFilter {

    @Autowired
    private RedisUtil redisUtil;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {
        // 获取请求中的token
        String token = request.getHeader("token");
        if (!StringUtils.hasText(token)) {
            // token不存在，放行，因为后面也有检测token，但是一定要加上return
            filterChain.doFilter(request, response);
            return;
        }

        // 解析token
        String userId;
        try {
            Claims claims = JwtUtil.parseJWT("token", token);
            userId = claims.getSubject();
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("token非法！");
        }

        // 从redis中获取用户信息
        String redisKey = "login:" + userId;
        LoginUser loginUser = (LoginUser) redisUtil.getCacheObject(redisKey);
        // 判断loginUser是否存在
        if (Objects.isNull(loginUser)) {
            throw new RuntimeException("用户未登录！");
        }

        // TODO 获取权限信息，封装到UsernamePasswordAuthenticationToken

        /**
         * 存入SecurityContextHolder
         * 需要一个Authentication类型，使用UsernamePasswordAuthenticationToken封装即可，但注意需要使用三个参数，添加认证状态为true
         */
        UsernamePasswordAuthenticationToken authenticationToken = new UsernamePasswordAuthenticationToken(loginUser, null, null);
        SecurityContextHolder.getContext().setAuthentication(authenticationToken);

        // 一切存完之后放行，访问下一个过滤器
        filterChain.doFilter(request, response);
    }
}
```

> request.getHeader("token")  这里是取了请求头中token属性的值，但是没有的话就要判断
>
> !StringUtils.hasText(token)  判断token是否存在
>
> JwtUtil.parseJWT("token", token)  第一个token是我设置的加密密钥
>
> claims.getSubject()  使用getSubject方法获取解密之后的值，也就是之前加密的userId

### 在security配置类中添加这个过滤器

添加一个过滤器要指定两个参数

1. 添加的Filter类（过滤器类）
2. 在哪个位置添加

```java
@Override
protected void configure(HttpSecurity http) throws Exception {
    http
            // 关闭csrf
            .csrf().disable()
            // 不使用session获取securityContent
            .sessionManagement().sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            .and()
            .authorizeRequests()
            // 对于登录接口 允许不登陆使用（允许匿名访问）
            .antMatchers("/user/login").anonymous()
            // 除上面外的所有请求全部需要鉴权认证
            .anyRequest().authenticated()

            // 添加请求过滤器
            .and()
            .addFilterBefore(jwtAuthenticationTokenFilter, UsernamePasswordAuthenticationFilter.class);
}
```

> 在UsernamePasswordAuthenticationFilter过滤器之前添加
>
> 这是一个请求判断的过滤器，所以要放在前面

## 授权实现

### 授权基本流程

在SpringSecurity中，会使用默认的`FilterSecurityInterceptor`来进行权限校验。在FilterSecurityInterceptor中会从`SecurityContextHolder`获取其中的Authentication，然后获取其中的权限信息。当前用户是否拥有访问当前资源所需的权限。

所以我们在项目中只需要把当前登录用户的权限信息也`存入Authentication`。

然后设置我们的资源所需要的权限即可。

### 配置类中配置开启权限控制方案

```java
@Configuration
@EnableGlobalMethodSecurity(prePostEnabled = true)
public class SecurityConfig extends WebSecurityConfigurerAdapter {
```

### 使用@PreAuthorize定义方法所需要的权限

```java
@RestController
public class HelloController {

    @RequestMapping("/hello")
    @PreAuthorize("hasAuthority('test')")
    public String hello (){
        return "hello";
    }
}
```

> hasAuthority 这里去调用这个方法判断是否有这个权限，现在是写死的

### 封装权限信息

由于LoginUser中只写了User字段，现在要存权限要加上一个List类型的字段

```java
package com.fsan.springsecurity.pojo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class LoginUser implements UserDetails {

    private User user;

    private List<String> permissions;

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {

        // 把permissions中的String类型转为SimpleGrantedAuthority

        // 方法一：（使用for循环遍历permissions，再使用SimpleGrantedAuthority对象创建）
//        List<GrantedAuthority> newList = new ArrayList<>();
//        for (String permission : permissions) {
//            SimpleGrantedAuthority simpleGrantedAuthority = new SimpleGrantedAuthority(permission);
//            newList.add(simpleGrantedAuthority);
//        }

        // 方法二：（使用集合流的形式将集合中String类型转为GrantedAuthority的实现类SimpleGrantedAuthority）
        List<SimpleGrantedAuthority> newList = permissions.stream()
                .map(SimpleGrantedAuthority::new)
                .collect(Collectors.toList());

        return newList;
    }

    @Override
    public String getPassword() {
        return user.getPassword();
    }

    @Override
    public String getUsername() {
        return user.getUserName();
    }

    /**
     * true表示没过期
     * @return
     */
    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    /**
     * 是否可用
     * @return
     */
    @Override
    public boolean isEnabled() {
        return true;
    }
}
```

> security在从实体类拿出权限列表的时候，使用的是getAuthorities方法，返回值为GrantedAuthority的集合类型，所以要在返回前将集合中字符串转为实现GrantedAuthority的SimpleGrantedAuthority类型
>
> stream()  转为集合流
>
> collect(Collectors.toList())  固定写法，将Stream流转为List对象
>
> map(SimpleGrantedAuthority::new)  将每一个List对象转为map中设置的返回结果
>
> * 如map(Person::getName) 即是将原List中的字符串转为Person类中的getName返回值，所以结果为存储Person类型的列表对象，使用getName获取原List元素
> * 简单理解：map中指定转化后的类型和对原List元素的放置
>
> 取名为 permissions

**但是这样权限的列表每次取出都需要序列化，所以优化如下：**

```java
@JSONField(serialize = false)    
private List<SimpleGrantedAuthority> authorities;

@Override
public Collection<? extends GrantedAuthority> getAuthorities() {

    if (authorities != null) {
        return authorities;
    }
    // 把permissions中的String类型转为SimpleGrantedAuthority

    // 方法一：（使用for循环遍历permissions，再使用SimpleGrantedAuthority对象创建）
    //        List<GrantedAuthority> newList = new ArrayList<>();
    //        for (String permission : permissions) {
    //            SimpleGrantedAuthority simpleGrantedAuthority = new SimpleGrantedAuthority(permission);
    //            newList.add(simpleGrantedAuthority);
    //        }

    // 方法二：（使用集合流的形式将集合中String类型转为GrantedAuthority的实现类SimpleGrantedAuthority）
    authorities = permissions.stream()
        .map(SimpleGrantedAuthority::new)
        .collect(Collectors.toList());

    return authorities;
}
```

> 定义一个属性用来存转换后的权限列表，当有值时直接返回即可
>
> 但是这样在存入redis时，`List<SimpleGrantedAuthority>这种类型是无法存入`的，需要加上`@JSONField(serialize = false)`表示无需序列化

### 从数据库查询权限信息

创建RBAC权限模型（Role-Based Access Control）即：基于角色的权限控制。这是目前最常被开发者使用也是相对易用，通用的权限模型

创建以下五个数据表

1. 用户表（user）
2. 权限表（menu）
3. 角色表（role）
4. 角色权限关联表（role_menu）
5. 用户角色关联表（user_role）

**sql联表根据用户id查询权限:**

```sql
SELECT
	DISTINCT m.perms
FROM
	sys_user_role ur
	LEFT JOIN sys_role r ON ur.role_id = r.id
	LEFT JOIN sys_role_menu rm ON ur.role_id = rm.role_id
	LEFT JOIN sys_menu m ON m.id = rm.menu_id 
WHERE
	user_id = 1
	AND r.`status` = 0 
	AND m.`status` = 0
```

> distinct 排除重复项（因为一个用户可能有多个角色，每个角色的权限会有重复）

## 菜单表的实体类

```java
package com.fsan.springsecurity.pojo;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.util.Date;

/**
 * 菜单表（Menu）实体类
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@TableName(value = "sys_menu")
@JsonInclude(JsonInclude.Include.NON_NULL)
public class Menu implements Serializable {
    private static final Long serialVersionUID = -54979041104113736L;

    @TableId
    private Long id;
    // 菜单名
    private String menuName;
    // 路由地址
    private String path;
    // 组件地址
    private String component;
    // 菜单状态（0显示 1隐藏）
    private String visible;
    // 菜单状态（0正常 1停用）
    private String status;
    // 菜单图标
    private String icon;

    private Long createBy;

    private Date createTime;

    private Long updateBy;

    private Date updateTime;

    // 是否删除（0未删除 1已删除）
    private Integer delFlag;
    // 备注
    private String remark;
}
```

> 实现Serializable类表示该类可以序列化，必须要加上serialVersionUID属性

### 使用mybatis plus自定义配置实现多表联查

1. 创建MenuMapper
2. 创建配置文件
3. 在spring配置文件中指定mapper配置的地址

**创建MenuMapper:**

```java
package com.fsan.springsecurity.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.fsan.springsecurity.pojo.Menu;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MenuMapper extends BaseMapper<Menu> {
    List<String> selectPermsByUserId(Long userid);
}
```

**创建配置文件(resources.mapper.MenuMapper.xml)**

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper
        PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.fsan.springsecurity.mapper.MenuMapper">
    <select id="selectPermsByUserId" resultType="java.lang.String">
      SELECT
         DISTINCT m.perms
      FROM
         sys_user_role ur
         LEFT JOIN sys_role r ON ur.role_id = r.id
         LEFT JOIN sys_role_menu rm ON ur.role_id = rm.role_id
         LEFT JOIN sys_menu m ON m.id = rm.menu_id
      WHERE
         user_id = #{userid}
         AND r.`status` = 0
         AND m.`status` = 0
    </select>
</mapper>
```

> 只要将之前写的多表联查语句放上修改用户id即可 #{userid}
>
> id mapper中方法名

**在spring配置文件中指定mapper配置的地址**

```yaml
mybatis-plus:
  mapper-locations: classpath*:/mapper/**/*.xml
```

> 这里查看源码发现默认就是classpath*:/mapper/**/*.xml，所以创建mapper下的配置文件的时候，不定义也没事

### 在UserDetails中获取权限

**先写测试类获取权限列表：**

```java
@Test
void testSelectPermsByUserId() {
    System.out.println(menuMapper.selectPermsByUserId(1L));
}
```

> 使用的userid为Long类型，最后加上 L
>
> 获取数据列表没有问题之后，加入UserDetailsService

**整合进UserDetailsService**

```java
    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {

//         炫技写法：可读性没有下面好
//        List<User> user = new LambdaQueryChainWrapper<>(sysUserMapper)
//                .eq(User::getUserName, username)
//                .list();
        LambdaQueryWrapper<User> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(User::getUserName, username);
        User user = sysUserMapper.selectOne(queryWrapper);
        // 如果没有查询到用户就抛出异常
        if (Objects.isNull(user)) {
            throw new RuntimeException("用户不存在！");
        }

        // 查询对应的权限信息
//        List<String> authList = Arrays.asList("test","admin");
        List<String> authList = menuMapper.selectPermsByUserId(user.getId());

        // 将数据封装为UserDetails返回
        return new LoginUser(user, authList);
    }
```

> 之前使用的是假数据，现在改为获取权限列表之后，在controller处修改真实限制

**在controller处修改真实限制：（以测试为例）**

```java
package com.fsan.springsecurity.controller;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {

    @RequestMapping("/hello")
    @PreAuthorize("hasAuthority('system:test:list')")
    public String hello (){
        return "hello";
    }
}
```

## 自定义权限校验方法

除了直接使用security的hasAuthority, hasAnyAuthority, 等权限校验方法，我们还可以自定义权限校验方法，实现复杂的权限校验

### 创建自定义权限类

```java
@Component("hasMyAuth")
public class UserPreAuth {
    public boolean hasAuthority(String authority) {
        // 获取当前用户的权限
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        LoginUser loginuser = (LoginUser) authentication.getPrincipal();
        List<String> list = loginuser.getPermissions();

        // 判断用户权限集合中是否存在authority
        return list.contains(authority);
    }
}
```

> 通过jwt过滤器存的SecurityContextHolder中拿到当前登录用户的权限列表
>
> getPermissions方法是上面封装的没有转类型的权限数据
>
> @Component("hasMyAuth") 对注入spring容器的bean取别名，方便下一步调用

### 测试

```java
@RestController
public class HelloController {

    @RequestMapping("/hello")
    @PreAuthorize("@hasMyAuth.hasAuthority('system:test:list')")
    public String hello (){
        return "hello";
    }
}
```

> 在SPEL表达式中使用@ 获取容器中bean的别名对象，然后再调用这个对象类的方法

## 数据库联表知识

### MySql LEFT JOIN（左连接）

left join 子句允许您从两个或多个数据库表查询数据。left join子句是select语句的可选部分，出现在form子句之后。

假设需要从t1，t2查询数据。以下语句说明了连接两个表的left join子句的语法：

```sql
SELECT 
    t1.c1, t1.c2, t2.c1, t2.c2
FROM
    t1
        LEFT JOIN
    t2 ON t1.c1 = t2.c1
```

> 连接条件则是t1.c1 = t2.c1
>
> 讲的通俗一点就是：t2表的满足t1.c1 = t2.c1的部分在查询时加入了t1表

### 更多用法：

```sql
SELECT
	c.customerNumber, customerName, orderNumber, status 
FROM
	customers c
	LEFT JOIN orders ON c.customerNumber = o.customerNumber
```

在以上子句中将customers数据表取别名为c，两个字段一致，则可以写作：

```sql
SELECT
	c.customerNumber, customerName, orderNumber, status 
FROM
	customers c
	LEFT JOIN orders USING (customerNumber)
```

> using 使用

## 自定义异常处理

如果是认证过程出现的异常会被封装成AuthenticationException然后调用AuthenticationEntryPoint对象的方法取进行异常处理。

如果是授权过程中出想的异常会被封装成AccessDeniedException然后调用AccessDeniedHandler对象的方法取进行异常处理。

所以如果我们需要自定义异常处理，我们只需要自定义AuthenticationEntryPoint和AccessDeniedHandler然后配置给SpringSecurity即可

### 实现AuthenticationEntryPoint完成认证失败的错误处理

1. 创建handler下的`AuthenticationEntryPointImpl`
2. 实现`AuthenticationEntryPoint`，重写`commence`方法
3. 通过设置响应体来将字符串渲染到客户端

**WebUtils:**

```java
package com.fsan.springsecurity.Utils;

import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

public class WebUtils {
    /**
     * 将字符串渲染到客户端
     * @param response 渲染对象
     * @param string 待渲染的字符串
     * @return
     */
    public static String renderString(HttpServletResponse response, String string) {
        try {
            response.setStatus(200);
            response.setContentType("application/json");
            response.setCharacterEncoding("utf-8");
            response.getWriter().print(string);
        } catch (IOException e) {
            e.printStackTrace();
        }
        return null;
    }
}
```

**AuthenticationEntryPointImpl:**

```java
@Component
public class AuthenticationEntryPointImpl implements AuthenticationEntryPoint {
    @Override
    public void commence(HttpServletRequest request, HttpServletResponse response, AuthenticationException authException) throws IOException, ServletException {
        ResponseResult result = new ResponseResult(HttpStatus.UNAUTHORIZED.value(),"用户认证失败，请重新登录！");
        String json = JSON.toJSONString(result);

        // 处理异常
        WebUtils.renderString(response, json);
    }
}
```

> HttpStatus这个枚举类直接指定401报错，记得使用value拿到401
>
> 将ResponseResult转为json字符串然后使用WebUtils的响应体返回客户端
>
> 这里的JSON.toJSONString是fastjson
>
> 404 肯定为请求地址写错了

### 实现AccessDeniedHandler完成权限不足的错误处理

1. 创建handler下的AccessDeniedHandlerImpl
2. 实现AccessDeniedHandler，重写handle方法
3. 设置响应体来返回字符串给客户端

```java
@Component
public class AccessDeniedHandlerImpl implements AccessDeniedHandler {
    @Override
    public void handle(HttpServletRequest request, HttpServletResponse response, AccessDeniedException accessDeniedException) throws IOException, ServletException {
        ResponseResult result = new ResponseResult(HttpStatus.FORBIDDEN.value(),"您的权限不足！");
        String json = JSON.toJSONString(result);

        // 处理异常
        WebUtils.renderString(response, json);
    }
}
```

> 权限不足的错误处理其实和上面的认证失败一样，只是认证失败使用的是401，权限不足返回的错误为403

### 在security配置类中配置异常处理器

```java
@Override
protected void configure(HttpSecurity http) throws Exception {
    http
            // 关闭csrf
            .csrf().disable()
            // 不使用session获取securityContent
            .sessionManagement().sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            .and()
            .authorizeRequests()
            // 对于登录接口 允许不登陆使用（允许匿名访问）
            .antMatchers("/user/login").anonymous()
            // 除上面外的所有请求全部需要鉴权认证
            .anyRequest().authenticated();

    // 添加请求过滤器
    http.addFilterBefore(jwtAuthenticationTokenFilter, UsernamePasswordAuthenticationFilter.class);

    // 配置异常处理器
    http.exceptionHandling()
            .authenticationEntryPoint(authenticationEntryPoint)
            .accessDeniedHandler(accessDeniedHandler);
}
```

## 解决security跨域

非常简单，在配置类中使用cors方法即可

```java
@Override
protected void configure(HttpSecurity http) throws Exception {
    http
            // 关闭csrf
            .csrf().disable()
            // 不使用session获取securityContent
            .sessionManagement().sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            .and()
            .authorizeRequests()
            // 对于登录接口 允许不登陆使用（允许匿名访问）
            .antMatchers("/user/login").anonymous()
            // 除上面外的所有请求全部需要鉴权认证
            .anyRequest().authenticated();

    // 添加请求过滤器
    http.addFilterBefore(jwtAuthenticationTokenFilter, UsernamePasswordAuthenticationFilter.class);

    // 配置异常处理器
    http.exceptionHandling()
            .authenticationEntryPoint(authenticationEntryPoint)
            .accessDeniedHandler(accessDeniedHandler);

    // 允许跨域
    http.cors();
}
```

## 使用权限配置权限控制

在方法上使用注解，在有很多方法需要控制的时候，查找比较麻烦，所以可以在security的配置类中配置全部方法的一个权限情况，方便管理

```java
@Override
protected void configure(HttpSecurity http) throws Exception {
    http
            // 关闭csrf
            .csrf().disable()
            // 不使用session获取securityContent
            .sessionManagement().sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            .and()
            .authorizeRequests()
            // 对于登录接口 允许不登陆使用（允许匿名访问）
            .antMatchers("/user/login").anonymous()
            
            // 添加权限控制
            .antMatchers("/test").hasAuthority("system:dept:list")
            
            // 除上面外的所有请求全部需要鉴权认证
            .anyRequest().authenticated();

    // 添加请求过滤器
    http.addFilterBefore(jwtAuthenticationTokenFilter, UsernamePasswordAuthenticationFilter.class);

    // 配置异常处理器
    http.exceptionHandling()
            .authenticationEntryPoint(authenticationEntryPoint)
            .accessDeniedHandler(accessDeniedHandler);

    // 允许跨域
    http.cors();
}
```

> 在这个方法中直接传入要控制的路径，后续调用的方法和使用注解是一样的

## CSRF

CSRF是指跨站请求伪造（Cross-site request forgery），是web常见的攻击之一。

SpringSecurity去防止CSRF攻击的方式就是通过csrf_token。后端会生成一个csrf_token，前端发起请求的时候需要携带这个csrf_token，后端会有过滤器进行校验，如果没有携带或者是伪造的就不允许访问。

我们可以发现CSRF攻击依靠的是cookie中所携带的认证信息。但是在前后端分离的项目中我们的认证信息其实是token，而token并不是存储在cookie中，并且需要前端代码去把token设置到请求头中才可以，所以csrf攻击也就不用担心了。

## 认证成功和失败处理器

实际上在`UsernamePasswordAuthenticationFilter`进行登录认证的时候，如果登录成功了是会调用`AuthenticationSuccessHandler`的方法进行认证成功后的处理的。AuthenticationSuccessHandler就是登录成功处理器，`AuthenticationFailureHandler`就是登录失败

源码可以查看UsernamePasswordAuthenticationFilter的父类下的doFilter方法

但按照我们上面的jwt流程的话是完全用不到这两个处理器的，这里算是扩展

### 认证成功处理器

写一个类，实现AuthenticationSuccessHandler类

```java
@Slf4j
@Component
public class LoginSuccessHandler implements AuthenticationSuccessHandler {
    @Override
    public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response, Authentication authentication) throws IOException, ServletException {
        log.info("用户认证通过！");
    }
}
```

> 实现AuthenticationSuccessHandler后，下面有两个方法，但是有一个defalut修饰可不重写

在配置类中添加formLogin配置

```java
@Override
protected void configure(HttpSecurity http) throws Exception {
    // 自定义认证成功和失败的处理器
    http.formLogin()
            .successHandler(authenticationSuccessHandler)
            .failureHandler(authenticationFailureHandler);
    
    // 对所有请求开启认证
    http.authorizeRequests().anyRequest().authenticated();
}
```

### 认证失败处理器

创个类，实现AuthenticationFailureHandler类

```java
@Slf4j
@Component
public class LoginFailureHandler implements AuthenticationFailureHandler {
    @Override
    public void onAuthenticationFailure(HttpServletRequest request, HttpServletResponse response, AuthenticationException exception) throws IOException, ServletException {
        log.info("用户认证失败！");
    }
}
```

添加配置类（看上面的成功处理器即可）

## 注销成功处理器

### 注销成功处理器

写一个类实现LogoutSuccessHandler

```java
@Slf4j
@Component
public class MyLogoutSuccessHandler implements LogoutSuccessHandler {
    @Override
    public void onLogoutSuccess(HttpServletRequest request, HttpServletResponse response, Authentication authentication) throws IOException, ServletException {
        log.info("用户注销成功！");
    }
}
```

在配置类中添加相关配置

```java
@Autowired
private MyLogoutSuccessHandler myLogoutSuccessHandler;

// 自定义登录成功和注销成功处理器
http.logout()
        .logoutSuccessHandler(myLogoutSuccessHandler);
```

