---
title: spring中@ConfigurationProperties代替@Value
date: 2022-06-25 15:16:33
tags: [springboot]
categories: [[后端,java]]
---

# 需求

注入`application.yml`配置文件中的常量

`application.yml`如下：

```yaml
aboutMe:
  name: FSAN
  age: 21
  height: 172


about-you:
  name: FSAN
  age: 22
  height: 174
  map:
    k1: v1
    k2: v2
  list:
    - FSAN
    - BSAN
  me:
    name: BSAN
    age: 21
    height: 173

```

## 使用@Value

### entity > Me.java

```java
@Data
@AllArgsConstructor
@NoArgsConstructor
@Component
public class Me {
    @Value("${aboutMe.name}")
    private String name;
    @Value("#{${aboutMe.age} - 1}")
    private Integer age;
    @Value("${aboutMe.height}")
    private String height;
}
```

> ${} 匹配式
>
> #{} 运算式

### 测试类中调用测试

```java
@SpringBootTest
class ValueConfigurationApplicationTests {

    @Autowired
    private Me me;

    @Test
    void contextLoads() {
        System.out.println(me);  // Me(name=FSAN, age=20, height=172)
    }
}
```

> 使用注入属性之后，也只能通过注入才能显示注入好的值，使用 `new Me()` 去构造会显示为`null`

## 使用@ConfigurationProperties

### entity > You.java

```java
@Data
@AllArgsConstructor
@NoArgsConstructor
@Component
@ConfigurationProperties("about-you")
public class You {
    private String name;
    private Integer age;
    private Integer height;
    private Map<String, Object> map;
    private List<String> list;
    private Me me;
}
```

> `ConfigurationProperties`使用这个注解的时候，注入的名字不能使用下划线和大写

### 测试类中调用测试

```java
@SpringBootTest
class ValueConfigurationApplicationTests {
    
    @Autowired
    private You you;

    @Test
    void contextLoads() {
        System.out.println(you); // You(name=FSAN, age=22, height=174, map={k1=v1, k2=v2}, list=[FSAN, BSAN], me=Me(name=BSAN, age=21, height=173))
    }
}
```

# 区别

1. @Value 只能注入一个属性，@ConfigurationProperties 能匹配多个
2. @Value 不支持JSR303数据校验，@ConfigurationProperties  配合@Validated 能对数据做校验
3. @Value 不能对复杂对象的直接封装（对象等）
