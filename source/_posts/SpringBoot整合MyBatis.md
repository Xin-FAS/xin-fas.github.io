---
title: SpringBoot整合MyBatis
date: 2021-08-15 13:15:26
tags: [mybatis,java]
categories: [后端,java]
---
---

## 项目初始化
创建项目，依赖必选MySQL Driver，JDBC API，Spring web
在maven官方仓库中CV MyBatis Spring Boot Starter依赖文件
在配置文件中建立数据连接

### 建立接口类
建立mapper包下接口类

> 使用interface(接口代替class)，写数据库操作

```java
@Mapper
@Repository
public interface UserMapper {
    List<loginUser> queryLoginAll();

    loginUser queryLoginById(int id);

    int addUser(User user);

    int updataUser(User user);

    int deleteUserById(int id);
}
```

### 创建mybatis的配置类

在resources下新建mybatis下mapper下的xml配置文件

1. 复制官网[探究已映射的 SQL 语句](https://mybatis.net.cn/getting-started.html)
2. 修改mapper 对应的 namespace 路径为你的 mapper 类
3. 修改id为定义的接口名字
4. resultType 属性为java实体对象，使用这个需要在配置文件中整合mybatis

```
mybatis:
  type-aliases-package: com.fsan.pojo
  mapper-locations: classpath:mybatis/mapper/*.xml
```

* 将实例对象和配置文件相通 

* classpath指定的resources文件夹，后面不需要加 /

resultType 输出数据格式

parameterType 输入数据格式

无返回值的功能可以全部使用resultType，虽然这很像废话，hhh

然后写对应的接口sql语句

### 使用mybatis
在controller里面创建实例类，在方法里面调用mapper类里的对应方法就可以了
注意：java实体类里面名字一定要和数据库属性名一样，使用mybatis是默认自动赋值封装的

> 使用mybatis手动封装

在mybatis的配置文件中，写查询数据库语句的时候，为查出来的属性使用as定义一个名字，这个名字就可以来进行封装
如：
```java
// 数据库中的属性分别为stuNum，stuPwd
// 实体类属性为username，password

// model
@Data
@AllArgsConstructor
@NoArgsConstructor
@Component
public class loginUser {
    private String username;
    private String password;

}

// mybatis.xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper
        PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.fsan.mapper.UserMapper">
    <select id="queryLoginAll" resultType="loginUser">
        select id,stuNum as username,stuPwd as password from login
    </select>
</mapper>

// controller
@Controller
public class UserControler {
    @Autowired
    private UserMapper userMapper;

    @ResponseBody
    @GetMapping("/getListAll")
    public void getListAll() {
        List<loginUser> listAll = userMapper.queryLoginAll();
        for (loginUser loginUser: listAll){
            System.out.println(loginUser);
        }
    }
}

// 控制台输出
loginUser(username=usetest1, password=pwdtest1)
loginUser(username=usetest2, password=pwdtest2)
null
```

## 注解
**@Mapper** 这个注解表示了这是一个 mybatis 的 Mapper 类

* 也可以在主入口处 使用 **@MapperScan("com.FSAN.mapper")** 手动添加扫描 Mapper 类

**@Repository** 使用这个注解实例化一个对象类，也可以使用万能的 **@Component**

## 总结MyBatis
> 依赖包：

mybatis-spring-boot-starter

> 使用步骤：

1. 导入包
2. 配置文件
3. mybatis 配置
4. 编写 sql
5. service 调用 dao
6. controller 调用 service

## 踩坑记录
1. 配置文件的文件名一定要和Mapper文件名相同
2. 找不到接口的时候就说明是配置文件出现问题，注意配置文件的后缀，一定要看的到才行！！

