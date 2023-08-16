---
title: springboot保存图片
date: 2022-08-19 20:38:53
tags: [springboot,上传图片]
categories: [后端,java]
---

# 关键代码

```java
@Service
public class UserServiceImpl implements UserService {

    @Value("${avatar.intUrl}")
    private String intUrl;

    @Value("${avatar.outUrl}")
    private String outUrl;

    @Override
    public String uploadAvatar(MultipartFile multipartFile) {
        // 获取file文件后缀名
        String[] arrayString = multipartFile.getOriginalFilename().split("\\.");
        String fileSuffix = "." + arrayString[arrayString.length - 1];
        // 新生成文件名，创建File对象
        String fileName = UUID.randomUUID().toString() + System.currentTimeMillis() + fileSuffix;
        File file = new File(intUrl, fileName);
        // 写入指定路径，抛出io异常
        try {
            multipartFile.transferTo(file);
        } catch (IOException e) {
            e.printStackTrace();
        }
        return outUrl + fileName;
    }
}
```
