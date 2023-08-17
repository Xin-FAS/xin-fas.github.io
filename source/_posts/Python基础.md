---
title: Python基础
date: 2021-08-15 19:20:43
tags: [python]
categories: [后端,python]
---
---
## Pyhon准备工作
### 下载python和配置环境
很简单，去 www.pyhton.org下载
打开执行文件，勾选上下面addpath就完成了

## Hello Python
使用的编辑器是官方自带的python入门级IDLE，以后熟练了可以去使用PyCharm
```Python
print("Hello Python!")
```



> pycharm中py文件的初始化配置

打开setting下的Editor下的File and Code Templates

改生成Python文件时的初始化代码：

```
# -*- codeing = utf-8 -*-
# @Time : ${DATE} ${TIME}
# @Author : FSAN
# @File : ${NAME}.py
# @Software : ${PRODUCT_NAME}
```

意思分别是

* 字符编码
* 记录生成python文件的时间
* 作者名字
* 文件名，后面是后缀名
* 编写软件名字，使用product_name可以自动补上pycharm

这些配置最好写上，以后如果写一个工程的话，方便别人看到编写环境



### 小程序
做一个输入判断
```Python
temp = input("不妨猜一下wo现在心里想的是哪个数字：1-10......")
if temp == "Python":
    print("")
    print("对了嗷，一看你就是本人，这是Python，不想这个想啥呢，hhh")
    print("")
    print("全部提示应该是1-10肯定不可能的啦，xswl。")
    print("")
    print("提示因为太长就省略一点，[doge]")
else:
    print("")
    print("错了嗷，再来？？")

print("来？")
```

### 转换数值型
因为使用input接收的数字是字符串类型的
需要使用int()转换才能比较
```Python
>>> num = input("请输入一个数字：")
请输入一个数字：2
>>> num
2
>>> num1 = int(num)
>>> num1
2
>>> num1 == num
False
```

### Input()
作用：用来接收用户输入并返回
就相当于java里面的Scanner

### 变量
变量不能以数字开头
变量可以使用中文，如：

```Python
>>> 一个人 = "qixin"
>>> 一个人
'qixin'
```

变量可以重新赋值
```Python
>>> 一个人 = "qixin"
>>> 一个人
'qixin'
>>> 一个人 = "me"
>>> 一个人
'me'
```

### 换行和print空格
反斜杠加n
\n

> 在print输出后跟个空格

```Python
print('0',a)
print('1')
```



### 快速CV上一条记录（IDLE）
AIt+P

### 打印路径

因为反斜杠之后如果有转义字符，python进行转义

错误：
```Python
>>> print("D:\three\two\one\now")
D:	hree	wo\one
ow
```

办法一： 使用\转义\，从而正常输出
```Python
>>> print("D:\\three\\two\\one\\now")
D:\three\two\one\now
```

办法二：使用原始字符串，在引号前面加上r，从而跳过编译
```Python
>>> print(r"D:\three\two\one\now")
D:\three\two\one\now
```

### 打印图形
#### 方法一：
原理，在一行结束时使用\n换行，再加上\表示没结束，使用Ctrl+J换行

三角形：
```Python
>>> print("\n\
     *     \n\
    ***    \n\
   *****   \n\
  *******")

     *     
    ***    
   *****   
  *******
```

不使用\n换行结果
```Python
>>> print("\
     *     \
    ***    \
   *****   \
  *******")
     *         ***       *****     *******
```

#### 方法二：
原理，使用'''标识，或"""
如：
```Python
>>> print("""
这就是Python吗
什么傻逼编辑器
使用关键字这么多。。。。
""")

这就是Python吗
什么傻逼编辑器
使用关键字这么多。。。。
```

### 重复打印
使用*
```Python
>>> print("buhuibahaizhenyou\n" * 10)
buhuibahaizhenyou
buhuibahaizhenyou
buhuibahaizhenyou
buhuibahaizhenyou
buhuibahaizhenyou
buhuibahaizhenyou
buhuibahaizhenyou
buhuibahaizhenyou
buhuibahaizhenyou
buhuibahaizhenyou
```

### 加程序注释
单独使用三引号字符串
如：
```Python
'''这是一个程序'''
print("woshi shabi")
```

### 使用while循环
格式：
```Python
while 条件:
	true执行
```

* continue 跳出当前一次循环

使用while-else
当while被正常执行完之后触发else的内容，被break打断则不触发

```Python
>>> while i<5:
	print("i的值为: ",i)
	if i==3:
		break
	i+=1
else:
	print("因为while正常执行完，我被执行了")
	print("现在i的值为：",i)
	i = 1
	print("i的值已重置为1")

	
i的值为:  1
i的值为:  2
i的值为:  3
```

使用while-else做七天打卡

```Python
day = 1
while day<=7:
    any = input("输入任意字符进行打卡!!")
    if any == '':
        print("今天还没打卡！！")
        break
    else:
        day+=1
else:
    print("您已连续打卡一周，打工人努力，我的海景别墅就靠你们了！")

'''运行结果'''
输入任意字符进行打卡!!1
输入任意字符进行打卡!!2
输入任意字符进行打卡!!3
输入任意字符进行打卡!!4
输入任意字符进行打卡!!5
输入任意字符进行打卡!!6
输入任意字符进行打卡!!7
您已连续打卡一周，打工人努力，我的海景别墅就靠你们了！
```

使用while打印九九乘法表
```Python
i = 1
while i <=9:
    j=1
    while j<=i:
        print(i,'*',j,'=',j*i, end=' ')
        if j*i<10:
            print('  ',end=' ')
        else:
            print(' ',end=' ')
        j+=1
    print()
    i+=1
print("打印完成！")

'''输出'''
1 * 1 = 1    
2 * 1 = 2    2 * 2 = 4    
3 * 1 = 3    3 * 2 = 6    3 * 3 = 9    
4 * 1 = 4    4 * 2 = 8    4 * 3 = 12   4 * 4 = 16   
5 * 1 = 5    5 * 2 = 10   5 * 3 = 15   5 * 4 = 20   5 * 5 = 25   
6 * 1 = 6    6 * 2 = 12   6 * 3 = 18   6 * 4 = 24   6 * 5 = 30   6 * 6 = 36   
7 * 1 = 7    7 * 2 = 14   7 * 3 = 21   7 * 4 = 28   7 * 5 = 35   7 * 6 = 42   7 * 7 = 49   
8 * 1 = 8    8 * 2 = 16   8 * 3 = 24   8 * 4 = 32   8 * 5 = 40   8 * 6 = 48   8 * 7 = 56   8 * 8 = 64   
9 * 1 = 9    9 * 2 = 18   9 * 3 = 27   9 * 4 = 36   9 * 5 = 45   9 * 6 = 54   9 * 7 = 63   9 * 8 = 72   9 * 9 = 81   
打印完成！
```

* end= ' '防止print的自动换行
* 
### for循环

for in  类似java的for :
格式：
```Python
for num in "12345"
	print(num)

'''输出'''
1
2
3
4
5
```

因为整数无法迭代
想要迭代整数可以使用range()函数，参数三个可选
```Python
print("range(start,stop,step)")
print("一个参数，range(5)")
for num1 in range(5):
    print(num1)
print("两个参数，range(1,5)")
for num2 in range(1,5):
    print(num2)
print("三个参数，range(1,5,2)")
for num3 in range(1,5,2):
    print(num3)

'''输出'''
range(start,stop,step)
一个参数，range(5)
0
1
2
3
4
两个参数，range(1,5)
1
2
3
4
三个参数，range(1,5,2)
1
3
```

### 使用伪随机数
生成一到十的伪随机数
```Python
import random

print(random.randint(1,10))
```

### '攻击' 随机数
让出现的伪随机数固定
这就是为什么叫伪随机数的原因
原理：random是靠当前的时间产生随机数的，只要我们提前保存random的状态，最后读取就行，类似时间宝石，hhh，玩笑

```Python
import random

x = random.getstate()

print(random.randint(1,10))
print(random.randint(1,10))
print(random.randint(1,10))
print(random.randint(1,10))
print(random.randint(1,10))

print("\n开始回退时间了嗷！！木大！！\n")
random.setstate(x)

print(random.randint(1,10))
print(random.randint(1,10))
print(random.randint(1,10))
print(random.randint(1,10))
print(random.randint(1,10))
```
这样，产生的随机数就完全相同

### 浮点数
因为Python和C一样，都是采用IEEE754的标准来存储浮点数的，所以在精度上就有误差
比如：

```Python
>>> 0.3 == 0.1 + 0.2
False
```
这里0.3是小于0.1 + 0.2的

### 精确计算浮点数
使用decimal的Decimal实例化对象
```Python
>>> import decimal
>>> a = decimal.Decimal('0.1')
>>> b = decimal.Decimal('0.2')
>>> a == b
False
>>> a + b == 0.3
False
>>> print(a+b)
0.3
>>> a+b==decimal.Decimal('0.3')
True
```
* 使用 Decimal 方法传进去的值一定要是字符串型的

**扩展知识：**
科学计数法：
在Python里面，输入0.00005，会输出5e-05
这个 e-05 就表示的十的负五次方，也就是0.00001


### 复数
复数由实部和虚部构成
使用 j 定义一个数为虚部，比如

```Python
>>> x = 1 + 2j
>>> print(x)
(1+2j)
>>> print(x.real)
1.0
>>> print(x.imag)
2.0
```
* 使用 real 调用实部
* 使用 imag 调用虚部

### 更多计算方法
|操作|结果|
| :---: | :---: |
|x + y|x加y|
|x - y|x减y|
|x * y|x乘以y|
|x / y|x除以y|
|x // y|x除以y的结果（地板除）|
|x % y|x除以y的余数|
|-x|x的相反数|
|+x|x本身|
|abs(x)|x的绝对值|
|int(x)|将x转换成整数|
|float(x)|将x转换成浮点数|
|complex(re, im)|返回一个复数，re是实部，im是虚部|
|divmod(x, y)|返回(x // y,x % y)|
|pow(x, y)|计算x的y次方|
|x ** y|计算x的y次方|

**地板除：
取比目标结果小的整数，如：**

```Python
>>> 3/2
1.5
>>> 3//2
1

>>> -3/2
-1.5
>>> -3//2
-2
```

pow函数可以传入第三个值，是用来对前两个值运算结果的取余，如：
```Python
>>> pow(2,3)
8
>>> pow(2,3,4)
0
```

结果等同于：2 // 3 % 4
**注意一点：实部和虚部都是使用浮点数存储的，进行计算还需要使用Decimal**

### 关于true和false
使用bool()函数可以直接判断true false
在bool()函数中写字符串就不一样了，除了空字符串是false，其他都是true，哪怕就只有一个空格
数值中0都是false，浮点数0.0也一样
空的数组，空列表，空集合，空对象都是false

### and or not优先级
not > and > or

### 函数语法
写一个叫做getName的函数
```Python
def getName (id):
    if id == 1:
        return '姓：qi'
    elif id == 2:
        return '名：xin'
    else:
        return '没有这个人'

id = input("输入一个数字")
name = getName(id)
print("下面有人吗    " + name)
```

### 一行之内的if语法
```Python
num = input()
print(False) if num==0 else print(True)
```

#### 多分支行内写法

```Python
score = int(input("1-100\n"))
level = ('A' if score>=80 else
         'B' if score>=60 else
         'C' if score>=40 else 'D')
print(level)
```

### 列表
```Python
>>> listName=[1,2,3,5,"FSAN"]
>>> print(listName)
[1, 2, 3, 5, 'FSAN']
>>> 
```

#### 索引列表

列表的索引可以使用负数
如，最后一项的索引值就为负一

列表还可以使用列表切片查看
如：查看下标 0-3
```Python
>>> listName[0:3]
[1, 2, 3]
```

在下标[]中：表示的就是一个范围，如3:是从三开始，:3是到三结束，而什么都不写则是查询全部

```Python
>>> listName[3:]
[5, 'FSAN']
>>> listName[:]
[1, 2, 3, 5, 'FSAN']
>>> listName[3:]
[5, 'FSAN']
>>> listName[:3]
[1, 2, 3]
```

在以上的：后面还可以加：表示跨度值：
```Python
>>> listName[::2]
[1, 3, 'FSAN']
```

#### 使用切片向列表后面添加值：

```Python
>>> listName[len(listName):] = ['new1','new2','new3']
>>> print(listName)
[1, 2, 3, 5, 'FSAN', 'new1', 'new2', 'new3']
```

#### 使用列表的extend函数直接向列表内部添加一个可迭代对象，如：

```Python
>>> addList = ['test1','test2','test3']
>>> listName.extend(addList)
>>> print(listName)
[1, 2, 3, 5, 'FSAN', 'new1', 'new2', 'new3', 'test1', 'test2', 'test3']
```

#### 使用列表的insert方法可以向列表的指定位置插入数据，如：

```Python
>>> print(listName)
[1, 2, 3, 5, 'FSAN', 'new1', 'new2', 'new3', 'test1', 'test2', 'test3', 'endList']
```

#### 使用列表的remove方法可以删除指定的列表数据，如：

```Python
>>> print(listName)
[1, 2, 3, 5, 'FSAN', 'new1', 'new2', 'new3', 'test1', 'test2', 'test3', 'endList']
>>> listName.remove('endList')
>>>> print(listName)
[1, 2, 3, 5, 'FSAN', 'new1', 'new2', 'new3', 'test1', 'test2', 'test3']
```
* 使用remove时，如有多个数据，则只会删除下标最小的那个
* 删除时如果元素不存在则会报错

#### 使用pop方法可以删除对应下标的元素，如：

```Python
>>> listName.pop(0)
1
>>> print(listName)
[2, 3, 5, 'FSAN', 'new1', 'new2', 'new3', 'test1', 'test2', 'test3']
```

#### 使用clean方法清空整个列表

```Python
>>> listName.clean()
```

#### 列表的自动排序

使用列表自带的sort方法
s.sort(key=None,reverse=False): 对列表中的元素进行原地排序（key用于指定一个比较函数，reverse参数用于指定排序结果是否翻转）

```Python
>>> nums = [1,3,4,23,3,4,10,2,19]
>>> print(nums)
[1, 3, 4, 23, 3, 4, 10, 2, 19]
>>> nums.sort()
>>> print(nums)
[1, 2, 3, 3, 4, 4, 10, 19, 23]
>>> nums.sort(reverse=True)
>>> print(nums)
[23, 19, 10, 4, 4, 3, 3, 2, 1]
```
* reverse默认为false，也就是从大到小

#### 查找某个元素的出现次数

```Python
>>> print(nums)
[23, 19, 10, 4, 4, 3, 3, 2, 1]
>>> nums.count(4)
2
```

#### 查找某个元素第一次出现的下标

```Python
>>> print(nums)
[23, 19, 10, 4, 4, 3, 3, 2, 1]
>>> nums.index(4)
3
```
* index(x,[start],[stop])看参数名思意

#### 拷贝一个列表，使用copy()，如：

```Python
>>> nums_copy = nums.copy()
>>> print(nums_copy)
[23, 19, 10, 4, 4, 3, 3, 2, 1]
```

也可以使用切片拷贝：
```Python
nums1_copy = nums1[:]
```

以上拷贝都算是浅拷贝

#### 把两个列表合并为一个列表

```Python
>>> nums1 = [1,2,3]
>>> nums2 = [4,5,6]
>>> nums1 + nums2
```
也可以使用上面提到的使用切片向后面添加一个列表

#### 创建二维列表

```Python
numss1 = [[0,0],[0,0],[0,0]]
numss2 = [[0] * 2] * 3
```
上面两个创建出的列表看起来是一样的，其实不是
比如：
```Python
>>> numss1[1][1] = 1
>>> numss1
[[0, 0], [0, 1], [0, 0]]

>>> numss2[1][1] =1
>>> numss2
[[0, 1], [0, 1], [0, 1]]

>>> numss2[0] is numss2[1]
True
```
使用is判断出numss2这两个是放在一个内存地址的，所以才会一起被改变

### 使用深拷贝
浅拷贝处理一维列表是没有问题的，但是要处理嵌套列表就，如：
```Python
>>> name = [[1,2],[1,2,3]]
>>> name_copy = name.copy()
>>> name_copy
[[1, 2], [1, 2, 3]]
>>> name[1][1] = 3
>>> name
[[1, 2], [1, 3, 3]]
>>> name_copy
[[1, 2], [1, 3, 3]]
```
发现copy的列表也会跟着一起变化
* 也可以使用copy下的copy函数

所以这就要用到深拷贝
步骤：
* 导入copy
* 使用copy下的deepcopy()函数

```Python
>>> import copy
>>> name_deepcopy = copy.deepcopy(name)
>>> name_deepcopy
[[1, 2], [1, 3, 3]]
>>> name[1][1] = 2
>>> name
[[1, 2], [1, 2, 3]]
>>> name_deepcopy
[[1, 2], [1, 3, 3]]
```

#### 原理：

浅拷贝在拷贝嵌套对象的时候只是使用一个新的名字去引用，内容没有真正复制出来
深拷贝才是完完整整的复制了一个

### 输出变量类型

使用type方法

```
a = 10
print(type(a))

// run
<class 'i'>
```

### 使用try处理异常报错

比如找一个不存在的文件

```
try:
    f = open("text1.txt","r")

except:
    pass
print("123")

// run
123
```

在except后面也可以跟上捕获异常的类型，如：except IOError:

### 列表推导式
要把列表里面每个值都 * 2
传统方法就是遍历里面的全部元素，然后重新赋值
这时候就可以使用Python的列表推导式：
```Python
>>> nums = [1,2,3,4]
>>> nums = [i * 2 for i in nums]
>>> nums
[2, 4, 6, 8]
```

### 对文件的操作

注意：每一次打开之后都要关闭，这样才能让别人再打开

> 打开/创建一个文件

```
f = open("test.txt","w")
f.close()
```

* open()  第一个参数是打开的文件名，没有就创建一个，第二个是使用模式，这里用的w模式（写模式，w = write）

注意： open的第二个参数如果不写的话，是只有读取的功能的，没有创建的功能（r模式），下面是模式表：

| 访问模式 | 说明                                                         |
| -------- | ------------------------------------------------------------ |
| **r**    | 以只读方式打开文件。文件的指针将会放在文件的开头。这是默认模式。 |
| **w**    | 打开一个文件只用于写入。如果该文件已存在则将其覆盖。如果该文件不存在，创建新文件。 |
| a        | 打开一个文件用于追加。如果该文件已存在，文件指针将会放在文件的结尾。也就是说，新的内容将会被写入到已有内容之后。如果该文件不存在，创建新文件进行写入。 |
| **rb**   | 以二进制格式打开一个文件用于只读。文件指针将会放在文件的开头，这是默认模式 |
| **wb**   | 以二进制格式打开一个文件只用于写入。如果该文件已存在则将其覆盖。如果该文件不存在，创建新文件。 |
| ab       | 以二进制格式打开一个文件用与追加。如果该文件已存在，文件指针将会放在文件的结尾。也就是说，新的内容将会被写入到已有内容之后。如果该文件不存在，创建新文件进行写入。 |
| r+       | 打开一个文件用于读写。文件指针将会放在文件的开头。           |
| w+       | 打开一个文件用于读写。如果该文件已存在则将其覆盖。如果该文件不存在，创建新文件 |
| a+       | 打开一个文件用于读写。如果该文件已存在，文件指针将会放在文件的结尾。文件打开时会是追加模式。如果该文件不存在，创建新文件用于读写。 |

加粗的四个是最常见的

> 写入数据

```
f = open("test.txt","w")
f.write("hello world!")
f.close()
```

* open文件的对象是在f上，可以直接对f进行操作

<br>

> 读取数据

读取n个字符

```
f = open("test.txt","r")
content = f.read(5)  # 读取五个字符
print(content)
content = f.read(5)  # 如果再读取的话就会接着上次的读取
print(content)
```

原因：因为在一次open操作中，并不是每次操作光标都在文档的开头

<br>

读取n行

```
f = open("test.txt","r")
content = f.readline()  # 读取一行的数据
```

小细节：readline后面可以加个s，就是readlines方法，读取所有行的数据，以列表的格式展示，如：

```
f = open("text.txt", "r")
contents = f.readlines();
i = 1
for content in contents:
    print("%d:%s"%(i, content))
    i += 1
f.close()

// run
1:HELLO,WORLD!

2:HELLO,WORLD!!

3:HELLO,WORLD!!!

4:HELLO,WORLD!!!!

5:HELLO,WORLD!!!!!
```

* %是一个占位符，d数字，s字符，占位完了之后使用%()去赋值，如果只有一个占位的话，不需要加（）
* print默认是换行的，如果不需要换行，在print中加上end="",如print("2:%s"%不换行,end="")

<br>

> 文件重命名

1. 导入os模块
2. 使用rename()方法

```
import os
os.rename("test.txt","正式文件.txt")
```

<br>

>删除文件

也是用os模块中的remove方法

```
os.remove("正式文件.txt")
```

<br>

> 创建文件夹

使用os模块中你的mikdir方法

```
os.mkdir("文件夹min")
```



### 多线程

1. 导入threading插件
2. 使用下的Thread方法去定义操作对象，如def函数

```python
def a(num):
    print(num)


def b(name):
    print(name)

if __name__ == '__main__':
	threading.Thread(a(2))
	threading.Thread(b("test"))
```

还可以这样：

```python
import time

def a(name="fsan", sleep=3):
    print(name)
    time.sleep(sleep)
    print(sleep)
    
if __name__ == '__main__':
    a()
    a("qixin")
    a("wlder", 6)
    
# Run:
wlder
6
qixin
3
fsan
3
```



### if __name__ == '__main__'

模块都有一个变量name,可以在模块中输出查看

```python
print(__name__)  # __main__
```

如果被其他模块导入的话，那么这个name在其他模块中就是导入的方法名
注意：python中导入其他模块的方法时，也就相当于执行

加上if __name__ == '__main__'就等于给个判断谁可以调用方法

> 没写if

```python
# test1
def run():
    print("这里是test1下的run方法")


run()

# test2
import test1

test1.run()

# Run:
这里是test1下的run方法
这里是test1下的run方法
```

* test1中的run被执行了两次，import的时候执行一次，调方法的时候又执行了一次

 <br>

> 写if

```python
# test1
def run():
    print("这里是test1下的run方法")

    
if __name__ == '__main__':
    run()

# test2
import test1

test1.run()

# Run:
这里是test1下的run方法
```

*  这样其他模块调用的时候才正常

### 在字符串中添加input中输入的值

> 方法一

```
jdSearch = input("请输入要在京东搜索的东西！")
url = "https://search.jd.com/Search?keyword=" + jdSearch
print(url)
```

这种是最常见的写法，不是很有b格

<br>

> 方法二

```
jdSearch = input("请输入要在京东搜索的东西！")
url = f"https://search.jd.com/Search?keyword={jdSearch}"
print(url)
```

* 加上f来使字符串可变
* {}调取对应的变量

这种写法就显得更专业

### 打包

安装pyinstaller模块

```python
pip install pyinstaller
```

使用pyinstaller打包：

```python
pyinstaller -F 文件名
```

### 使用正则判断

条件：第一个字符不为数字，由数字字母下划线组成

使用re正则判断

```python
import re

a = input("请输入\n")

# try:
#     int(a[0])
# except:
#     print("首字母不是数字")
rules1 = re.compile(r'''^[^0-9]''')
rules2 = re.compile(r'''^[0-9A-Za-z_]{1,}$''')

s = True

if rules2.match(a) is None:
    print("请使用数字字母下划线组成！")
    s = False
if rules1.match(a) is None:
    print("不能使用数字作为开头！")
    s = False

if s:
    print("通过验证！")
```

* 其中的第一个请求可以使用try报错简单实现

## Python就是方便！！（彩蛋）

在IDLE里输入import this，会出现一首开发者的诗

