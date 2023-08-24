---
title: springboot发送邮箱
date: 2022-05-17 19:48:35
tags: [SpringBoot]
categories: [[后端,Java]]
---
## 准备工作

1. 导入依赖
2. 配置邮箱服务器

### 导入依赖

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-mail</artifactId>
    <version>2.6.7</version>
</dependency>
```

### 配置邮箱服务器

```yaml
spring:
  mail:
    host: smtp.qq.com
    username: XXXXXX@qq.com
    password: XXXXXXX

mail:
  mailTo: XXXXXXX@qq.com
  mailFrom: XXXXXXX@qq.com
```

> `mailTo`（发送给谁） 和 `mailFrom`（是谁发送） 是自定的，给后续发送邮箱时使用
>
> `host`：表示使用邮箱服务器的地址，其他服务器请往下看
>
> `username`：邮箱名
>
> `password`：邮箱密码，如是qq邮箱，必须要在qq邮箱中设置开启SMTP（电子邮件传输协议），并使用提供的唯一密码

## 发送简易邮箱

使用`SimpleMailMessage`对象即可

```java
// 发送给谁
@Value("${mail.mailTo}")
private String mailTo;

// 谁发送的
@Value("${mail.mailFrom}")
private String mailFrom;

// 指定验证码长度
@Value("${mail.codeLength}")
private Integer codeLength;

// 邮箱发送标题
@Value("${mail.codeSubject}")
private String codeSubject;

@Autowired
private JavaMailSender javaMailSender;

/**
 * 生成验证码
 */
private String createCode() {
    // 时间戳获取
    String time = Long.toString(System.currentTimeMillis());
    // UUID去字母符号取长度-2，加上时间戳最后两位
    return UUID.randomUUID().toString().replaceAll("[a-zA-Z-]", "").substring(0, codeLength - 2) + time.substring(time.length() - 2);
}

@Test
void easySend() {
    SimpleMailMessage simpleMailMessage = new SimpleMailMessage();
    simpleMailMessage.setTo(mailTo);
    simpleMailMessage.setFrom(mailFrom);
    simpleMailMessage.setSubject(codeSubject);
    // 邮件内容
    simpleMailMessage.setText("验证码为：" + createCode());
    try {
        javaMailSender.send(simpleMailMessage);
        log.info("邮件已发送！");
    } catch (MailException e) {
        e.printStackTrace();
        log.error("发送邮件时发生异常！");
    }
}
```

## 发送HTML邮箱

1. 获取message
2. 添加发送内容
3. 发送

```java
// 发送给谁
@Value("${mail.mailTo}")
private String mailTo;

// 谁发送的
@Value("${mail.mailFrom}")
private String mailFrom;

// 指定验证码长度
@Value("${mail.codeLength}")
private Integer codeLength;

// 邮箱发送标题
@Value("${mail.codeSubject}")
private String codeSubject;

@Autowired
private JavaMailSender javaMailSender;

@Test
void htmlSend() {
    String content = "<html>\n" +
            "<body>\n" +
            "    <h3>验证码为：" + createCode() + "</h3>\n" +
            "</body>\n" +
            "</html>";
    // 获取message
    MimeMessage message = javaMailSender.createMimeMessage();
    try {
        MimeMessageHelper mimeMessageHelper = new MimeMessageHelper(message, true);
        mimeMessageHelper.setTo(mailTo);
        mimeMessageHelper.setFrom(mailFrom);
        // 添加html内容
        mimeMessageHelper.setText(content, true);
        mimeMessageHelper.setSubject(codeSubject);
        javaMailSender.send(message);
        log.info("发送HTML邮箱成功！");
    } catch (MessagingException e) {
        e.printStackTrace();
        log.error("发送HTML邮件时发生异常！");
    }
}
```

## 发送图片邮箱

1. 建立message
2. 添加发送对象
3. 获取发送file对象
4. 添加发送

```java
@Test
void sendImg() {
    // 为图片建立唯一值
    String pid = UUID.randomUUID().toString().replace("-", "").substring(0, 3);
    // 图片地址，从src开始
    String imgUrl = "src/main/resources/img/img1.png";
    // src后面cid是固定写法
    String content = "<html><body>这是有图片的邮件：<img src='cid:"+pid+"' ></body></html>";
    // 建立message
    MimeMessage message = javaMailSender.createMimeMessage();

    try {
        MimeMessageHelper mimeMessageHelper = new MimeMessageHelper(message, true);
        mimeMessageHelper.setFrom(mailFrom);
        mimeMessageHelper.setTo(mailTo);
        mimeMessageHelper.setSubject(codeSubject);
        mimeMessageHelper.setText(content, true);
        // 获取对应目录file对象
        FileSystemResource res = new FileSystemResource(new File(imgUrl));
        // 为图片唯一值为pid的添加file文件
        mimeMessageHelper.addInline(pid, res);
        javaMailSender.send(message);
        log.info("邮箱已发送！");
    } catch (MessagingException e) {
        e.printStackTrace();
        log.error("邮箱发送失败！");
    }
}
```
