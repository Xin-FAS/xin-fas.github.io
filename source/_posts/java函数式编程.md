---
title: java函数式编程
date: 2022-05-22 12:19:05
tags: [SpringBoot,Lambda,Stream]
categories: [[后端,Java]]
---
## 函数式编程思想
### 概念
面向对象思想需要关注用什么对象完成什么事情。而函数式编程思想就类似于我们数学中的函数。它主要关注的是对数据进行了说明操作。
### 优点
1. 代码简洁，开发快速
2. 接近自然语言，易于理解
3. 易于“并发编程”

## Lambda表达式

### 概念

Lambd是JDK8中一个语法糖。可以看成是一种语法糖，他可以对某些匿名内部类的写法进行简化。它是函数式编程思想的一个重要体现。

### 例1

匿名内部类中简化使用

简化前：

```java
package com.FSAN;

public class LambdaDemo {
    public static void main(String[] args) {
        new Thread(new Runnable() {
            @Override
            public void run() {
                System.out.println("新线程中run方法被执行了");
            }
        }).start();
    }
}
```

简化条件：是一个接口的匿名内部类，并且这个接口只有一个抽象方法要重写

简化后：

```java
package com.FSAN;

public class LambdaDemo {
    public static void main(String[] args) {
//        new Thread(new Runnable() {
//            @Override
//            public void run() {
//                System.out.println("新线程中run方法被执行了");
//            }
//        }).start();

        // 多行不省略
        new Thread(() -> {
            System.out.println("新线程中run方法被执行了");
        }).start();

        // 单行省略
        new Thread(() -> System.out.println("新线程中run方法被执行了")).start();
    }
}
```

### 例2

现在有一个方法，内部调用了`IntBinaryOperator`接口的`applyAsInt`方法，且`IntBinaryOperator`接口中只有`applyAsInt`方法

```java
public static int calculateNum(IntBinaryOperator operator) {
    int a = 10;
    int b = 20;
    return operator.applyAsInt(a, b);
}
```

匿名内部类调用：

```java
int i = calculateNum(new IntBinaryOperator() {
    @Override
    public int applyAsInt(int left, int right) {
        return left + right;
    }
});
System.out.println(i);
```

使用lambda表达式：

```java
int i = calculateNum((int left, int right) -> {
            return left + right;
        }
);
System.out.println(i);
```

继续优化最简形式：省略参数类型和return关键字

```java
int i = calculateNum((left, right) -> left + right);
System.out.println(i);
```

### 例3

```java
public static void pringNum(IntPredicate predicate) {
    int[] arr = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    for (int i : arr) {
        if (predicate.test(i)) {
            System.out.println(i);
        }
    }
}
```

匿名内部类调用方式：

```java
pringNum(new IntPredicate() {
    @Override
    public boolean test(int value) {
        return value % 2 == 0;
    }
});
```

使用lambda表达式：

```java
pringNum(value -> value % 2 == 0);
```

### 例4：结合泛型

```java
public static <R> R typeConver(Function<String, R> function) {
    String str = "12345";
    R result = function.apply(str);
    return result;
}
```

使用匿名内部类：

```java
Integer integer = typeConver(new Function<String, Integer>() {
    @Override
    public Integer apply(String s) {
        return Integer.valueOf(s);
    }
});
System.out.println(integer);
```

使用lambda表达式：

```java
Integer integer1 = typeConver(Integer::valueOf);
System.out.println(integer1);
```

调用`Integer`类的`valueOf`方法处理结果

### 例5

```java
public static void foreachArr(IntConsumer intConsumer) {
    int[] arr = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    for (int i : arr) {
        intConsumer.accept(i);
    }
}
```

匿名内部类调用：

```java
foreachArr(new IntConsumer() {
    @Override
    public void accept(int value) {
        System.out.println(value + "处理后！");
    }
});
```

lambda表达式调用

```java
foreachArr(value -> System.out.println(value + "处理后！"));
```

> 如果是只输出value，可以直接使用：：简化为`foreachArr(System.out::println);`

## Stream流

### 概念

方便对集合和数组进行操作，一个stream流创建之后一定要有终结操作

### 基础使用

#### 初始化

建立Author类

```java
package com.FSAN.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class Author {
    private Long id;
    // 姓名
    private String name;
    // 年龄
    private Integer age;
    // 简介
    private String intro;
    // 作品
    private List<Book> books;
}
```

建立Book类

```java
package com.FSAN.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class Book {
    private Long id;
    // 书名
    private String name;
    // 分类
    private String category;
    // 评分
    private Integer score;
    // 简介
    private String intro;
}
```

数据初始化：

```java
package com.FSAN;

import com.FSAN.entity.Author;
import com.FSAN.entity.Book;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class StreamDemo {
    public static List<Author> getAuthors() {
        // 数据初始化
        Author author = new Author(1L, "蒙多", 33, "一个从菜刀中明悟哲理的祖安人", null);
        Author author2 = new Author(2L, "亚索", 15, "狂风也追逐不上思考速度", null);
        Author author3 = new Author(3L, "易", 14, "是这个世界在限制他的思维", null);
        Author author4 = new Author(3L, "易", 14, "是这个世界在限制他的思维", null);

        // 书籍列表
        List<Book> books1 = new ArrayList<>();
        List<Book> books2 = new ArrayList<>();
        List<Book> books3 = new ArrayList<>();

        books1.add(new Book(1L, "刀的两侧是光明与黑暗", "哲学，爱情", 88, "用一把刀划分了爱恨"));
        books1.add(new Book(2L, "一个人不能死在同一把刀下", "个人成长，爱情", 99, "讲述如何从失败中明悟真理"));

        books2.add(new Book(3L, "那风吹不到的地方", "哲学", 85, "带你用思维去领路世界的尽头"));
        books2.add(new Book(3L, "那风吹不到的地方", "哲学", 85, "带你用思维去领路世界的尽头"));
        books2.add(new Book(4L, "吹或不吹", "爱情，个人传记", 56, "一个哲学家的恋爱观注定很难把他所在的时代理解"));

        books3.add(new Book(5L, "你的浏览器我的剑", "爱情", 56, "无法想象一个武者能对他的伴侣这么的宽容"));
        books3.add(new Book(6L, "风与剑", "个人传记", 100, "两个哲学家灵魂和肉体的碰撞会激起怎么样的火花呢？"));
        books3.add(new Book(6L, "风与剑", "个人传记", 100, "两个哲学家灵魂和肉体的碰撞会激起怎么样的火花呢？"));

        author.setBooks(books1);
        author2.setBooks(books2);
        author3.setBooks(books3);
        author4.setBooks(books3);

        List<Author> authList = new ArrayList<>(Arrays.asList(author, author2, author3, author4));
        return authList;
    }
}
```

#### 使用Stream去重并输出年龄大于18的作者姓名

```java
public static void main(String[] args) {
    List<Author> authors = getAuthors();
    authors
            // 将集合转为stream流
            .stream()
            // 去重
            .distinct()
            // 使用filter根据条件过滤掉数据
            .filter(author -> author.getAge() < 18)
            // 使用foreach打印出名称
            .forEach(author -> System.out.println(author.getName()));
}
```

不使用stream流的步骤：

1. 先创建set集合，将list集合中的元素添加到set集合中，去掉重复值
2. 遍历set集合，答应set集合中年龄小于于18的作者名称

```java
// 创建set集合
HashSet<Author> set = new HashSet<>();
// 将list集合添加进set集合中去重
boolean b = set.addAll(authors);
if (b) {
    // 循环遍历出年龄小于18的作者名称
    set.forEach(author -> {
        if (author.getAge() < 18) {
            System.out.println(author.getName());
        }
    });
}
```

### 常用操作

#### 创建流

##### 单列集合

在单列集合（List，Set）的形式下，创建流直接使用`.stream()`

```java
ArrayList<Integer> list = new ArrayList<>();
list.add(1);
list.add(2);
list.add(3);
list.add(4);
list.add(5);
list.add(6);
list.add(6);
list.stream()
        .distinct()
        .forEach(System.out::println);

HashSet<Integer> set = new HashSet<>(list);
set.stream()
        .forEach(System.out::println);
```

##### 多列集合

多列集合的形式下，创建流需要先将多列集合（`HashMap`）使用`entrySet`方法转为单列集合（Set集合）

```java
HashMap<String, Integer> map = new HashMap<>();
map.put("one", 20);
map.put("two", 22);
map.put("three", 24);
Set<Map.Entry<String, Integer>> entries = map.entrySet();
entries.stream()
        .distinct()
        .filter((Map.Entry<String, Integer> stringIntegerEntry) -> stringIntegerEntry.getValue() > 20)
        .forEach((Map.Entry<String, Integer> stringIntegerEntry) -> System.out.println(stringIntegerEntry.getKey()));
```

这里的结果是输出map中value大于20的键名

##### 数组

数组使用`stream`流需要使用`Arrays`工具类

```java
int[] ages = new int[]{1, 2, 3, 4, 5, 6};
Arrays.stream(ages)
        .filter(value -> value > 4)
        .forEach(System.out::println);
```

### 中间操作

#### filter（过滤）

在创建流之后，可以使用filter对集合进行过滤，filter内置的是返回值为布尔类型的匿名函数，true表示通过，false表示过滤

过滤掉年龄小于18的作者

```java
List<Author> authors = getAuthors();
authors.stream()
        .filter(author -> author.getAge() > 18)
        .forEach(System.out::println);
```

这里的author可以使用任何名称，匿名函数是这样写的

```java
List<Author> authors = getAuthors();
authors.stream()
        .filter(new Predicate<Author>() {
            @Override
            public boolean test(Author author) {
                return author.getAge() > 18;
            }
        })
        .forEach(System.out::println);
```

#### map（转换）

使用map可以对原数据进行替换，如将authors中只留下年龄，并且输出

```java
List<Author> authors = getAuthors();

authors.stream()
        .map(Author::getAge)
        .forEach(System.out::println);
// 同上
authors.stream()
        .map(author -> author.getAge())
        .forEach(System.out::println);
// 同上
authors.stream()
    	// 下面泛型中，前一个对应authors的类型，后一个对应转换后的类型
        .map(new Function<Author, Integer>() {
            @Override
            public Integer apply(Author author) {
                return author.getAge();
            }
        })
        .forEach(System.out::println);
```

对数据进行多次操作

```java
authors.stream()
        .map(Author::getAge)
        .map(age -> age + 10)
        .forEach(System.out::println);
```

#### distinct（去重）

使用`distinct`对自定义类型去重的时候，要重写存储在集合中类的`equals`方法

```java
List<Author> authors = getAuthors();
authors.stream()
        .distinct()
        .forEach(System.out::println);
```

#### sorted（排序）

##### 空参实现：

使用空参的`sorted()`需要让自定义类实现`Comparable`接口，再重写`compareTo`方法

`Authors`实体类

```java
package com.FSAN.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class Author implements Comparable<Author> {
    private Long id;
    // 姓名
    private String name;
    // 年龄
    private Integer age;
    // 简介
    private String intro;
    // 作品
    private List<Book> books;

    // 比较方法：使用传进来的对象属性减去本身对象的属性就是降序，反之升序
    @Override
    public int compareTo(Author o) {
        return o.getAge() - this.getAge();
    }
}
```

测试类；

```java
List<Author> authors = getAuthors();
authors.stream()
        .sorted()
        .forEach(System.out::println);
```

##### 使用内部类实现

```java
List<Author> authors = getAuthors();
authors.stream()
        .sorted((Author o1, Author o2) -> o2.getAge() - o1.getAge())
        .forEach(System.out::println);
```

#### limit（取数据长度）

```
List<Author> authors = getAuthors();
authors.stream()
        .distinct()
        .limit(2)
        .forEach(System.out::println);
```

> 一般用来手动分页，先排序后取数据个数

#### skip（跳过前几个数据）

```java
List<Author> authors = getAuthors();
authors.stream()
        .distinct()
        .skip(2)
        .forEach(System.out::println);
```

> 结合limit做手动分页

#### flatMap（将流中的对象拆为多个对象）

对比map：

```java
List<Author> authors = getAuthors();
authors.stream()
        .map(Author::getBooks)
        .distinct()
        .forEach(System.out::println);
```

使用map去获取作者下的书籍的时候，获取到的是每个作者下书的list对象

```bash
[Book(id=1, name=刀的两侧是光明与黑暗, category=哲学，爱情, score=88, intro=用一把刀划分了爱恨), Book(id=2, name=一个人不能死在同一把刀下, category=个人成长，爱情, score=99, intro=讲述如何从失败中明悟真理)]
[Book(id=3, name=那风吹不到的地方, category=哲学, score=85, intro=带你用思维去领路世界的尽头), Book(id=3, name=那风吹不到的地方, category=哲学, score=85, intro=带你用思维去领路世界的尽头), Book(id=4, name=吹或不吹, category=爱情，个人传记, score=56, intro=一个哲学家的恋爱观注定很难把他所在的时代理解)]
[Book(id=5, name=你的浏览器我的剑, category=爱情, score=56, intro=无法想象一个武者能对他的伴侣这么的宽容), Book(id=6, name=风与剑, category=个人传记, score=100, intro=两个哲学家灵魂和肉体的碰撞会激起怎么样的火花呢？), Book(id=6, name=风与剑, category=个人传记, score=100, intro=两个哲学家灵魂和肉体的碰撞会激起怎么样的火花呢？)]
```

要的效果是获取到全部作者下的所有书籍就需要用到`flatMap`

```java
List<Author> authors = getAuthors();
authors.stream()
        .flatMap(author -> author.getBooks().stream())
        .distinct()
        .forEach(System.out::println);
```

```bash
Book(id=1, name=刀的两侧是光明与黑暗, category=哲学，爱情, score=88, intro=用一把刀划分了爱恨)
Book(id=2, name=一个人不能死在同一把刀下, category=个人成长，爱情, score=99, intro=讲述如何从失败中明悟真理)
Book(id=3, name=那风吹不到的地方, category=哲学, score=85, intro=带你用思维去领路世界的尽头)
Book(id=4, name=吹或不吹, category=爱情，个人传记, score=56, intro=一个哲学家的恋爱观注定很难把他所在的时代理解)
Book(id=5, name=你的浏览器我的剑, category=爱情, score=56, intro=无法想象一个武者能对他的伴侣这么的宽容)
Book(id=6, name=风与剑, category=个人传记, score=100, intro=两个哲学家灵魂和肉体的碰撞会激起怎么样的火花呢？)
```

需要去重时，需要写再转换的后面

### 终结操作

#### forEach

用来遍历其中的数据，不演示，上面有

#### count

拿取数据长度

```java
List<Author> authors = getAuthors();
long count = authors.stream()
        .flatMap(author -> author.getBooks().stream())
        .distinct()
        .count();
System.out.println(count);
```

> 获取所有作者下的书籍数量，去除重复

#### max & min

使用max方法查询数据中年龄最大的作者

```
List<Author> authors = getAuthors();
Optional<Author> max = authors.stream()
        .distinct()
        .max((o1, o2) -> o1.getAge() - o2.getAge());

System.out.println(max.get());
```

使用min方法查询数据库中年龄最小的作者

```java
List<Author> authors = getAuthors();
Optional<Author> min = authors.stream()
        .distinct()
        .min((o1, o2) -> o1.getAge() - o2.getAge());

System.out.println(min.get());
```

在获取max和min的数据的时候，返回的是一个Optional类型的数据，要想获取流中类型的数据需要使用get方法

#### collect

把当前流转换为一个集合

##### 例1

获取一个存放所有作者名字的List集合

```java
List<Author> authors = getAuthors();
List<String> collect = authors.stream()
        .map(Author::getName)
        .distinct()
        .collect(Collectors.toList());
System.out.println(collect);
```

主要就是用到了`Collectors`工具类中的`toList`方法

##### 例2

获取存放所有书名的Set集合

```java
Set<String> collect = authors.stream()
        .flatMap(author -> author.getBooks().stream())
        .map(Book::getName)
        .collect(Collectors.toSet());
System.out.println(collect);
```

思路： 

1. 使用`flatMap`将流转为作者下的书籍信息
2. 使用`map`再次转换流，只拿取书籍中的书名
3. 最后使用`collect`对所有书名进行转换为`set`集合

##### 例3

将list列表转以作者名字为key，书籍为value的map集合

```java
List<Author> authors = getAuthors();
Map<String, List<Book>> collect = authors.stream()
        .distinct()
        .collect(Collectors.toMap(Author::getName, Author::getBooks));
System.out.println(collect);
```

使用`Collectors`的`toMap`方法时，需要传入两个函数，返回值就当作map集合的key和value

#### 查找与匹配

##### anyMatch（重要）

判断是否有满足年龄大于10的作者

```java
boolean b = authors.stream()
        .distinct()
        .anyMatch(author -> author.getAge() > 10);
System.out.println(b);
```

类似js中查看数组中是否有某个元素的方法`includes`

##### allMatch（重要）

判断是否所有的作者都是成年人

```java
boolean b = authors.stream()
        .allMatch(author -> author.getAge() > 18);
System.out.println(b);
```

##### noneMatch

判断流中的元素是否都不满足某条件

如：判断所有的作者年龄都不超过100

```java
boolean b = authors.stream()
        .noneMatch(author -> author.getAge() > 100);
System.out.println(b);
```

##### findAny

随机获取一个流中的元素

如：获取其中一个成年作者

```java
List<Author> authors = getAuthors();
Optional<Author> any = authors.stream()
        .filter(author -> author.getAge() > 18)
        .findAny();
System.out.println(any.get());
```

> 注意：返回值为Optional类型的，最后要使用get方法获取到其中的内容

##### findFirst

获取流中第一个元素

如：获取第一个成年作者

```java
List<Author> authors = getAuthors();
Optional<Author> first = authors.stream()
        .filter(author -> author.getAge() > 18)
        .findFirst();
System.out.println(first.get());
```

如：获取年龄最大的作者

```java
List<Author> authors = getAuthors();
Optional<Author> first = authors.stream()
        .sorted((o1, o2) -> o2.getAge() - o1.getAge())
        .findFirst();
System.out.println(first.get());
```

#### reduct归并（重要）

对流中的数据按照你指定的元素计算出一个结果。

我们可以传入一个初始值，它会按照我们的计算方式一次拿流中你的元素和初始化值的基础上进行计算，计算结果再和后面的元素计算。

第一个参数为初始值，第二个参数为自定义的运算

##### 例1

求所有作者年龄的和

对比写法：

```java
Integer i = 0;
for (Author author : authors) {
    i += author.getAge();
}
System.out.println(i);
```

```java
Integer reduce = authors.stream()
        .map(Author::getAge)
        .reduce(0, Integer::sum);
System.out.println(reduce);
```

这里的`Integer::sum`同`(integer, integer2) -> integer + integer2)`

##### 例2

 求出作者中最大的年龄（定义一个最小值）

```java
List<Author> authors = getAuthors();
Integer reduce = authors.stream()
        .map(Author::getAge)
        .reduce(Integer.MIN_VALUE, (inter1, inter2) -> inter1 < inter2 ? inter2 : inter1);
System.out.println(reduce);
```

在赋值初始值的时候，不建议使用0（流中元素有负数就会出现问题），直接使用`Interger`的`MIN_VALUE`（-2的31次方，是int类型能够表示的最小值）

同理可得：求出作者中最小的年龄（定义一个最大值）

```java
List<Author> authors = getAuthors();
Integer reduce = authors.stream()
        .map(Author::getAge)
        .reduce(Integer.MAX_VALUE, (inter1, inter2) -> inter1 > inter2 ? inter2 : inter1);
System.out.println(reduce);
```

##### 例3

使用`reduct`一个参数的方法求作者的最大年龄

```java
List<Author> authors = getAuthors();
Optional<Integer> reduce = authors.stream()
        .map(Author::getAge)
        .reduce((integer, integer2) -> integer > integer2 ? integer : integer2);
System.out.println(reduce.get());
```

使用单个参数的方法时，内部的源码是直接取流中第一个元素作为初始值，其他写法同上

### 基础概念

1. 如果没有终结操作，中间操作是不会进行求值的
2. 流是一次性的，经过了终结操作之后就不能进行其他操作
3. 在操作流中的数据的时候，流中的数据不会被影响
