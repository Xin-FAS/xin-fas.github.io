---
title: 优雅的封装rAF
date: 2023-08-25 22:23:28
tags: [JavaScript]
categories: [前端,前端其他]
sticky: 5
---

## 封装需求

1. 支持控制每秒刷新帧数（FPS），节省性能消耗
2. 支持控制持续时间
3. 支持获取实时进度
4. 支持暂停和继续

## 使用

<iframe src="/iframe/rAF封装函数演示.html" width='100%' height='40px'></iframe>

```js
import rAFWithFPS from "./rAFWithFPS"

const { pause, next } = rAFWithFPS(progress => {
    console.group('执行统计')
    console.count('执行次数：')
    console.log('执行进度：', progress)
    console.groupEnd('执行统计')
}, 2000, 60)

// 500毫秒后暂停
setTimeout(() => {
    pause()
    // 暂停1000毫秒后继续
    setTimeout(() => {
        next()
    }, 1000)
}, 500)
```

使用`rAFWithFPS`后可以传递三个参数

1. 执行的回调函数
   1. 参数一：进度，范围 `0 - 1`
   2. 参数二：rAF对象，可使用`cancelAnimationFrame`手动结束
2. 执行时间（毫秒），可传递 -1 表示无限时间，默认 -1
3. 每秒刷新帧数（FPS），默认 30

如上，就是共执行`120（2 * 60）`次回调，执行`30次`后暂停，一秒后继续执行`90次`

## rAFWithFPS.js

```js
/**
 * @author Xin-FAS
 */

/**
 * 以指定的fps执行函数，执行n毫秒后停止，或手动停止
 * @param callback 每次执行的回调，回调值为进度和实例，可以手动停止
 * @param duration 执行时间，默认-1，即无限
 * @param fps 指定fps，默认一秒三十次
 */
const rAFWithFPS = (callback, duration = -1, fps = 30) => {
    // 动画实例
    let rAFInstance,
        // 上一次执行时间
        then = performance.now(),
        // 当次执行时间差
        diff,
        // 当前时间
        now,
        // 已执行时间
        runDuration = 0,
        // 暂停时间差
        pauseDiff,
        // 执行初始时间
        runDurationStart = performance.now()
    // fps 对应的刷新毫秒
    const fpsInterval = 1000 / fps

    // 运行
    const run = () => {
        // 异步执行，不用担心位置
        rAFInstance = requestAnimationFrame(run)
        // 当前时间
        now = performance.now()
        // 获取执行的时间差
        diff = now - then
        // 根据执行插值计算已执行时间
        runDuration += (now - runDurationStart)
        // 获取完执行时间后立马刷新执行初始时间
        runDurationStart = performance.now()
        // 当执行时间大于fps的间隔时间，刷新初始时间
        if (diff > fpsInterval) {
            // 也可以简单使用start = now，以下是对起始值优化
            then = now - (diff % fpsInterval)
            // min 防止最后一次超出
            callback(duration === -1 ? 0 : Math.min(runDuration / duration, 1), rAFInstance)
        }
        // 判断结束时间差，时间到了就结束raf
        if (runDuration > duration && duration !== -1) cancelAnimationFrame(rAFInstance)
    }
    // 暂停，记录时间差
    const pause = () => {
        pauseDiff = performance.now() - then
        rAFInstance = (cancelAnimationFrame(rAFInstance), undefined)
    }
    // 继续
    const next = () => {
        // 如果当前不处于暂停状态
        if (rAFInstance) return
        // 刷新上一次执行时间和初始时间
        const pauseWithNow = performance.now() - pauseDiff
        then = pauseWithNow
        runDurationStart = pauseWithNow
        run()
    }
    run()
    return {
        pause,
        next
    }
}

export default rAFWithFPS
```

{% note info %}

tips：

1. 使用`performance.now()`代替`Date.now()`能获取精度高达微秒的浮点数，更多介绍MDN：https://developer.mozilla.org/en-US/docs/Web/API/Performance/now

2. 使用`now - (diff % fpsInterval)`代替`start = now`，外国友人详细的回答：

   > All you can control is when you're going to skip a frame. A 60 fps monitor always draws at 16ms intervals. For example if you want your game to run at 50fps, you want to skip every 6th frame. You check if 20ms (1000/50) has elapsed, and it hasn't (only 16ms has elapsed) so you skip a frame, then the next frame 32ms has elapsed since you drew, so you draw and reset. But then you'll skip half the frames and run at 30fps. So when you reset you remember you waited 12ms too long last time. So next frame another 16ms passes but you count it as 16+12=28ms so you draw again and you waited 8ms too long

{% endnote %}

{% note warning %}

未知原因：暂停后执行概率出现少执行一次问题，如最后进度在`0.99`，执行次数例子中为`119`次的情况

{% endnote %}
