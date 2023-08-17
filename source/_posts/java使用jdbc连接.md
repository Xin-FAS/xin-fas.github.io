---
title: java使用jdbc连接
date: 2022-03-18 20:35:15
tags: [java,jdbc]
categories: [后端,java]
---

## 准备操作

下载 jar 包：`mysql-connector-java`

> 搜索jar包：https://mvnrepository.com/

整体步骤：

1. 导入jar包
2. 使用`Class.forName("com.mysql.cj.jdbc.Driver")`注册驱动（8.0）
3. 获取conn对象，并使用`prepareStatement`装入`sql`语句
4. 使用pre对应方法执行

## 封装连接工具类

```java
public class getConn {
    private static String url, user, pwd;
    private static Connection conn;

    static {
        url = "jdbc:mysql://XXX.XXX.XXX.XXX:XXXX/FSAN?serverTimezone=UTC&useUnicode=true&characterEncoding=utf-8";
        user = "root";
        pwd = "FSAN";
    }

    public Connection getConn() {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(url, user, pwd);
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return conn;
    }
}
```

## CRUD 操作

### 添加数据

```java
    public String addData(loginUser loginUser) {
        try {
            pre = conn.prepareStatement("insert into loginUser(username,password) VALUES (?,?)");
            pre.setString(1, loginUser.getUsername());
            pre.setString(2, loginUser.getPassword());
            if (pre.executeUpdate() != 0) {
                return "添加成功！";
            } else {
                return "添加失败！";
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return "出现未知错误！";
    }
```

### 修改数据

```java
public String editData(loginUser loginUser) {
    try {
        pre = conn.prepareStatement("update loginUser set username=?,password=? where id=?");
        pre.setString(1, loginUser.getUsername());
        pre.setString(2, loginUser.getPassword());
        pre.setInt(3, loginUser.getId());
        if (pre.executeUpdate() != 0) {
            return "修改成功！";
        } else {
            return "修改失败！";
        }

    } catch (SQLException e) {
        e.printStackTrace();
    }
    return "出现未知错误！";
}
```

### 删除操作

```java
    public String delDataById(int id) {
        try {
            pre = conn.prepareStatement("delete from loginUser where id=?");
            pre.setInt(1, id);
            if (pre.executeUpdate() != 0) return "删除成功！";
            return "id不存在！";
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return "出现未知错误！";
    }
```

### 查询操作

```java
public ArrayList<loginUser> getAllData() {
        try {
            pre = conn.prepareStatement("select * from loginUser");
            ResultSet result = pre.executeQuery();
            while (result.next()) {
                list.add(new loginUser(result.getInt("id"), result.getString("username"), result.getString("password")));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
```

## 完整DB

```java
public class JDBCAbout {
    private static Connection conn;
    private static PreparedStatement pre;
    private static ArrayList<loginUser> list;
    private static loginUser loginUser;

    static {
        conn = new getConn().getConn();
        list = new ArrayList<>();
    }

    public ArrayList<loginUser> getAllData() {
        try {
            pre = conn.prepareStatement("select * from loginUser");
            ResultSet result = pre.executeQuery();
            while (result.next()) {
                list.add(new loginUser(result.getInt("id"), result.getString("username"), result.getString("password")));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public String delDataById(int id) {
        try {
            pre = conn.prepareStatement("delete from loginUser where id=?");
            pre.setInt(1, id);
            if (pre.executeUpdate() != 0) return "删除成功！";
            return "id不存在！";
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return "出现未知错误！";
    }

    public String addData(loginUser loginUser) {
        try {
            pre = conn.prepareStatement("insert into loginUser(username,password) VALUES (?,?)");
            pre.setString(1, loginUser.getUsername());
            pre.setString(2, loginUser.getPassword());
            if (pre.executeUpdate() != 0) {
                return "添加成功！";
            } else {
                return "添加失败！";
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return "出现未知错误！";
    }

    public String editData(loginUser loginUser) {
        try {
            pre = conn.prepareStatement("update loginUser set username=?,password=? where id=?");
            pre.setString(1, loginUser.getUsername());
            pre.setString(2, loginUser.getPassword());
            pre.setInt(3, loginUser.getId());
            if (pre.executeUpdate() != 0) {
                return "修改成功！";
            } else {
                return "修改失败！";
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return "出现未知错误！";
    }

    private void closeAll(Connection conn, PreparedStatement pre) {
        try {
            if (conn != null) {
                conn.close();
            }
            if (pre != null) {
                pre.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
```

