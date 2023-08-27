---
title: Redis学习
date: 2021-09-12 11:20:21
tags: [Redis]
categories: [后端,后端其他]
---

## Redis 简介

Redis是现在最受欢迎的NoSQL数据库之一，即远程字典服务，Redis是一个使用ANSI C编写的开源，包含多种数据结构、支持网络、基于内存、可选持久性的键值对存储数据库

### 特性
* 基于内存运行，性能高效
* 支持分布式，理论上可以无限扩展
* key-value存储系统
* 开源的使用ANSI C语言编写

### 功能

1. 多样的数据类型
2. 持久化
3. 集群 
4. 事务

### 为什么快？

Redis 是单线程的，但是Redis很快，官网表示，Redis是基于内存操作，CPU不是Redis性能瓶颈，Redis的瓶颈是根据机器的内存和网络带宽，既然可以使用单线程来实现，就使用单线程了！
Redis是C语言写的，官方提供的数据为 100000+ 的QPS（每秒处理请求数）

核心：redis是将所有的数据全部放在内存中的，所以说使用单线程去操作效率就是最高的，多线程（CPU上下文会切换：耗时的操作！！！），对于内存系统来说，如果没有上下文切换效率就是最高的！多次读写都是在一个CPU上的，在内存情况下，这个就是最佳的方案！

> 误区：
>
> 1. 高性能的服务器一定是多线程的
> 2. 多线程一定比单线程效率高
## 开始

官网：https://redis.io/

中文网: http://www.redis.cn/

### windows 下使用

使用github托管仓库：http://github.com/dmajkic/redis/releases

或：https://github.com/tporadowski/redis/releases

启动服务：

```bash
redis-server.exe redis.windows.conf
```

启动控制台：

```bash
redis-cli.exe -h 127.0.0.1 -p 6379
ping
```

ping 之后能返回PONG就说明了redis启动正常

### linux下使用

可见docker部署redis

## redis命令基础

### String类型操作

#### 切换库

redis默认是有16个数据库的，默认使用第0个（类似下标）

```bash
select 3
```

如果有(error) NOAUTH Authentication required.报错，则是因为没有登录，先使用auth登录，：如 auth "FSAN"

#### 查看当前库的大小：

```bash
dbsize
```

#### 设置，获取值

```bash
set name FSAN
get name
```

记住在哪个库中就行

#### 获取全部键：

```bash
keys *
```

#### 清空数据库：

清空当前：

```bash
flushdb
```

清空所有：

```bash
flushall
```

#### 判断是否存在key

```bash
exists key
```

如果存在则返回1，不存在则是0


#### 移动值到另一个库中:

```bash
move key 库下标
```

如 move name 1 名字移动到下标1的数据库中，作用于逻辑删除

#### 为键值对设置过期时间

```bash
expire key secoud
```

> secoud为秒数

#### 查看是否过期
```bash
ttl key
```

-1 则无过期
-2 则已过期或不存在该数据


#### 删除数据:

```bash
del key
```

#### 查看当前类型：

```bash
type key
```

#### 获取字符串长度，添加长度

```bash
strlen key # 返回类型和长度
append "new str" # 在字符串后面追加字符串，不存在则新建
```

#### 自增1，自减1：

```bash
incr key # 加一
decr key # 减一
```

#### 增加，减少指定数：

```bash
incrby key 10 # 加10
decrby key 10 # 减10
```

#### setex，setnx（重点）

```bash
setex key secoud "value" # 一次设置三个参数，创建了键值对并设置过期时间（秒）
setnx key "value" # 如果不存在则设置，对于已经存在的不变
```

setnx的返回值状态，0表示设置失败，以后常用于做分布式锁

#### 批量操作：

```bash
mset k1 v1 k2 v2 k3 v3
mget k1 k2 k3
```

设置了三个键值对，获取三个对应的值

```bash
msetnx k1 v2 k2 v3
```

设置k1 k2的值，但如果存在则设置失败
与上面的mget，mset一样，属于原子性操作，要么一起成功，要么就都失败，回滚

#### 对key的巧妙的设计：

key的名称可以这样取：user:{id}:{filed}，如：

```bash
setex user:1:name 10 FSAN
setex user:1:age 10 19
```

设置了user:1:name，user:1:age两个数据，10秒过期
这样可以类似关系型数据库，方便顺序取数据

#### 常用组合式命令：

```bash
getset user:1:name FSAN
```

先获取user:1:name的值，再设置一个新的值

#### 存储对象：

```bash
set myObject {name:FSAN,age:19}
```

看似存储了一个对象，实际在redis中是存储了一个json字符串，本质还是String类型

### List类型操作

#### 添加数据(lpush,rpush)：

```bash
lpush myList end
rpush myList first
```

lpush 对指定列表的左边（left）添加一个值
rpush 对指定列表的右边（right）添加一个值

#### 获取数据(lrange)：

```bash
lrange myList 0 -1
```

lrange获取列表数据，下标从0开始，取到-1（全部获取）
这里的l意思不是left，是list

```bash
127.0.0.1:6379> lrange myList 0 -1
1) "4"
2) "1,2,3"
3) "123312"
127.0.0.1:6379> lrange myList 0 1
1) "4"
2) "1,2,3"
```

从myList中获取下标为0-1的数据



#### 默认移除数据（添加使用push，移除就是pop）

```bash
lpop myList
rpop myList
```

lpop 从左边移除一个数据
rpop 从右边移除一个数据
执行命令之后，会返回被移除的对象



#### 移除指定的值(lrem)

移除myList中值为FSAN的一条数据
```bash
lrem myList 1 FSAN
```
> l(list)rem(remove)



#### 获取列表长度(llen)：

```bash
llen myList
```

> l(list)len(length)


#### 裁剪ltrim（只留下指定范围的数据）

现在有六个数据，FSAN6下标为0，FSAN1下标为5
```bash
127.0.0.1:6379> lrange myList 0 -1
1) "FSAN6"
2) "FSAN5"
3) "FSAN4"
4) "FSAN3"
5) "FSAN2"
6) "FSAN1"
```

只保留下标2到4的数据（即FSAN4，FSAN3，FSAN2）：

```bash
127.0.0.1:6379> ltrim myList 2 4
```



#### 将一个列表的最后一个元素添加到新的列表中（rpoplpush）

```bash
127.0.0.1:6379> rpoplpush myList myListBak
"1"
```
返回值是被移动的参数

#### 更新列表中的元素(lset)：

```bash
127.0.0.1:6379> lset myListBak 0 useLset
OK
```

将myListBak中下标为0的元素更新为"useLset"



#### 在列表的指定元素之前或者之后插入元素（linsert）

```bash
127.0.0.1:6379> linsert myList before 4 10
```

l(list)insert ,在myList列表中的"4"元素之前
如果不存在就会失败

### set（集合）类型

set中的值是无序的，不能重复的

#### set集合中添加元素（sadd）

```bash
127.0.0.1:6379> sadd name FSAN
(integer) 1
```

s(set)add



#### 查看指定set中所有值（smembers）

```bash
127.0.0.1:6379> smembers name
1) "FSAN"
```

s(set)member(成员)s



#### 判断某一个值是不是在set集合中（sismember）

```bash
127.0.0.1:6379> sismember name BSAN
(integer) 0
```

s(set)is member，1：在  0：不在

#### 获取set集合中内容元素的个数（scard）

```bash
127.0.0.1:6379> scard name
(integer) 2
```

#### 移除set集合中的指定元素（srem）

```bash
127.0.0.1:6379> srem name BSAN
(integer) 1
```

* s(set)rem(remove)



#### 从一个集合中随机抽选出元素（srandmember）

```bash
127.0.0.1:6379> srandmember name
"FSAN"
```

* s(set)rand(随机)member
* 可以在后面加上数据，表示抽取的个数

抽两个随机数：

```bash
127.0.0.1:6379> srandmember name 2
1) "FSAN"
2) "BSAN"
```

当数据不够的时候，不会报错，继续返回

#### 随机移除集合中的一个成员（spop）：

```bash
127.0.0.1:6379> spop name 1
1) "BSAN6"
```

pop在列表中是移除在栈顶的一个元素，但是在set集合中成员是无序的，所以变为随机删除了