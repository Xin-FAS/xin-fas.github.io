---
title: js数字转中文数字
date: 2023-08-14 18:58:04
tags: [JavaScript]
categories: [前端,前端其他]
---

## 介绍

获取对应数字的中文读法数字字符串，使用如下

```js
getChineseNumber(100000) // 十万
getChineseNumber(10000000) // 一千万
getChineseNumber(1234) // 一千二百三十四
getChineseNumber(0) // 零
getChineseNumber(123456789) // 一亿二千三百四十五万六千七百八十九
getChineseNumber(12312312312312312) // 一亿二千三百一十二万三千一百二十三亿一千二百三十一万二千三百一十二
```

数字需要满足以下条件：

1. 小于10^7
2. 为正整数

## getChineseNumber

```js
const getChineseNumber = num => {
    const arr1 = [ '零', '一', '二', '三', '四', '五', '六', '七', '八', '九' ]
    const arr2 = [ '', '十', '百', '千', '万', '十', '百', '千', '亿', '十', '百', '千', '万', '十', '百', '千', '亿' ]
    if (!num || isNaN(num)) return '零'
    const english = num.toString().split('')
    let result = ''
    for (const [ index, char ] of english.reverse().entries()) result = arr1[+char] + arr2[index] + result
    // 去除空白位
    result = result
        .replace(/零(千|百|十)/g, '零')
        .replace(/十零/g, '十')
    // 去除尾部剩余零
    result = result.replace(/零+$/, '')
    // 去除连续多个零
    result = result.replace(/零+/g, '零')
    // 保留大单位
    result = result
        .replace(/零亿/g, '亿')
        .replace(/零万/g, '万')
    // 去除前置一十为十
    result = result.replace(/^一十/g, '十')
    // 放置1后面全是零
    result = result.replace(/亿万/g, '亿')
    return result
}
```
