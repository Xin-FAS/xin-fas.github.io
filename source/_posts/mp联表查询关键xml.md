---
title: mp联表查询关键xml
date: 2022-04-18 20:53:59
tags: [MyBatisPlus,MyBatis]
categories: [后端,Java]
---

## 一对一

```xml
<resultMap id="getUserMap" type="User" autoMapping="true">
    <association property="job" javaType="Job" autoMapping="true">
        <id property="jobId" column="job_id"/>
        <result property="createTime" column="j_create_time"/>
        <result property="updateTime" column="j_update_time"/>
    </association>
</resultMap>
```

## 一对多

```xml
<resultMap id="UserDtoMap" type="UserDto" autoMapping="true">
    <id property="userId" column="user_id" />
    <collection property="aClass" ofType="com.fas.entity.Class" autoMapping="true">
        <id property="classId" column="class_id" />
        <result property="createTime" column="c_create_time" />
        <result property="updateTime" column="c_update_time" />
    </collection>
</resultMap>
```
