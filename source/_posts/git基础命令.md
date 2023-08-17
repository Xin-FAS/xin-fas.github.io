---
title: git基础命令
date: 2021-07-15 02:51:43
tags: [git命令]
categories: [其他]
---

## 准备工作
### 下载并安装git工具

 * [点此进入baidu云盘下载](http://pan.baidu.com/s/1hrgTIdu)
 * [点此查看安装教程](http://jingyan.baidu.com/article/e52e36154233ef40c70c5153.html)

### git提交结构

1. 工作区（就是本地初始化地方的文件）
2. 暂存区（add 中的文件）
3. 本地库（commit 打上标签的文件）
4. 远程库（github或gitee仓库） 

### 提交流程

1. 首次利用git提交需要配置好全局用户信息

```bash
git config --global user.name "用户名"
git config --global user.email "邮箱地址"
```

2. 初始化仓库

```bash
git init
```

3. 本地文件提交到暂存区

```bash
git add 文件
```

4. 暂存区加入本地库

```bash
git commit -m "说明"
```

5. 建立本地链接

```bash
git remote add 别名 地址
```

6. 提交对应分支

```bash
git push -u 别名 分支名
```

## 常用命令

### 工作区提交暂存区

```bash
$ git add .
```

> .表示全部提交覆盖，提交更新个别请输入单个文件路径

### 暂存区提交至本地库

```bash
$ git commit -m "测试"
```

在测试后面还可以加一个参数，表示文件名

### 分支操作

#### 查看分支

```bash
$ git branch  // 查看当前分支
$ git branch -v  // 查看当前分支详细 最后一次提交索引 + 备注
```

#### 创建分支

```bash
$ git branch [分支名]
```

使用branch命令，不加是查看，加上名字就是创建

#### 切换分支

```bash
$ git checkout [分支名]
```
#### 分支合并

```bash
$ git merge [合并的分支]
```

如合并远程仓库的master分支和本地的master

```bash
$ git merge origin/merge
```

#### 查看远程分支全部文件

1. 切换到远程分支
2. 使用ll列出全部文件
3. 使用cat查看文件内容

```bash
$ git checkout origin/master
$ ll
$ cat [文件名]
```

>  这里的origin是仓库别名，master是分支名字

### 版本控制

#### 查看版本日志

```bash
$ git log
```

上面这种展开之后太长了，建议下面这种

```bash
$ git reflog
```

#### 回退版本

```bash
$ git reset --hard 索引
```

注意： 这里使用hard回退是工作区，暂存区，本地库一起回退

要实现远程仓库回退，还要重新强制提交一次

> 强制提交
>
> ```bash
> git push -f -u origin master 
> ```

### 本地地址库

#### 查看本地的地址库

```bash
$ git remote -v
```

#### 添加本地的地址

```bash
$ git remote add [别名] [仓库地址]
```

### 推送

```bash
$ git push [别名] [分支名]
```

>  远程仓库里没有对应分支的时候会创建一个
>
> 推送到对应的仓库是要加入团队的，有权限才能推送
>
> 当然这些可以在windows凭据里面查看

### 克隆远程仓库

```bash
$ git clone [仓库地址]
```

将远程仓库克隆下来之后，会自动的将链接取一个别名origin

### 抓取操作

```bash 
$ git fetch origin master
```

仓库别名加上分支，抓取操作将远程的仓库内容抓到本地，但并不会更新工作区

### pull操作

pull操作就是抓取操作加上分支合并操作

```bash
$ git pull origin master
```

* 别名加地址

### 添加到暂存区并加上说明
```bash
$ git add .
$ git commit -m "[对提交文件的说明]"
```
注意：要确保提交文件夹<mark>只有一个.git文件夹</mark>
### 提交暂存区
```bash
$ git branch   #查看本地分支，无误后提交
$ git push -u remote地址
```
### 清空git缓存

```bash
$ git rm -r -f --cached .   #清空git缓存
```

## gitee免费部署

步骤：

1. 创建仓库
2. 提交包含index.html的目录
3. 进入仓库，点击服务下git pages中的启动按钮

## 问题：

### add 后提示warning

描述：`The file will have its original line endings in your working directory`

原因：在 Unix 系统中，行尾用换行符 (LF) 表示。在windows中，一行用回车符（CR）和换行符（LF）表示（CRLF）。当您从 git 获取从 unix 系统上传的代码时，它们将只有一个 LF。

解决：

但这个问题不影响操作，再次add就正常了

如果你觉得烦，对于只在window中运行的项目来说，可以直接关闭

```bash
git config --global core.autocrlf false
```



