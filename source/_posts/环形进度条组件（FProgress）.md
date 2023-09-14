---
title: 环形进度条组件（FProgress）
date: 2023-09-14 22:35:57
tags: [Vue2, Vue3]
categories: [前端,Vue]
---

## 介绍

使用svg分段实现，直接上使用

## 使用

<iframe src="/iframe/FProgress/index.html#/" height="400px"></iframe>
vue2演示：

```html
<script>
import FProgress from "@/FProgress.vue";
export default {
    components: {
        FProgress
    },
    data () {
        return {
            fixed: 1,
            value: 50,
            r: 50,
            border: 10,
            color: '#83e63c',
            section: 1,
            timing: x => 1 - Math.pow(1 - x, 5),
            gap: 1
        }
    }
}
</script>

<template>
    <div>
        <div>
            进度：<input type="number" min="0" max="100" step="10" v-model="value">
        </div>
        <div>
            小数位数：<input type="number" min="0" v-model="fixed">
        </div>
        <div>
            半径（不包含边框）：<input type="number" min="0" step="10" v-model="r">
        </div>
        <div>
            边框宽度：<input type="number" min="0" step="1" v-model="border">
        </div>
        <div>
            颜色：<input type="color" v-model="color">
        </div>
        <div>
            分段长度：<input type="number" min="1" v-model="section">
        </div>
        <div>
            分段间隙：<input type="number" min="0" v-model="gap">
        </div>
        <div>
            变化曲线的js函数：{{ timing }}
        </div>
        <div style="display: flex">
            <FProgress
                :value="+value"
                :fixed="+fixed"
                :r="+r"
                :border="+border"
                :color="color"
                :section="+section"
                :gap="+gap"
                :timing="timing"
            />
            默认配置：
            <FProgress
                :value="+value"
            />
        </div>
    </div>
</template>
<style scoped>
input {
    font-size: 20px;
}
</style>
```

## FProgress.vue

### vue2 版本

```html
<script>
export default {
    props: {
        // 半径（不包含边框）
        r: {
            type: Number,
            default: 50
        },
        // 边框宽度
        border: {
            type: Number,
            default: 5
        },
        // 初始化进度 0 - 100
        value: {
            type: Number | String,
            default: 50
        },
        // 颜色
        color: {
            type: String,
            default: '#83e63c'
        },
        // 变化曲线的js函数
        timing: {
            type: Function,
            default: x => 1 - Math.pow(1 - x, 5)
        },
        // 变化时显示的小数位数
        fixed: {
            type: Number,
            default: 2
        },
        // 分段长度:
        section: {
            type: Number,
            default: 1
        },
        // 分段间隙
        gap: {
            type: Number,
            default: 0
        }
    },
    data () {
        return {
            // 颜色
            preColor: this.$props.color,
            // 进度
            preRate: 0,
        }
    },
    computed: {
        // 周长
        C () {
            return 2 * Math.PI * this.$props.r
        },
        // 长和宽
        wh () {
            return 2 * this.$props.r + this.$props.border * 2
        },
        // 自动计算显示进度条
        strokeDasharray () {
            const {
                section,
                gap,
            } = this.$props
            const rate = this.handlerStrRate(this.preRate)
            // TODO 后续自定义各阶段颜色
            // if (rate >= 100) {
            //     this.preColor = '#5eb879'
            // }
            // 要渲染的段长度
            const haveRateLen = rate / 100 * this.C
            const array = [ section, gap ]
            // 可完全渲染的段数
            const sectionCount = Math.floor(haveRateLen / (section + gap))
            const renderArray = Array.from({ length: sectionCount }, _ => array).flat(2).join(' ')
            // 剩余段长度
            const endRenderLen = haveRateLen - sectionCount * (section + gap)
            return `${ renderArray } ${ Math.min(endRenderLen, section) } ${ this.C }`
        }
    },
    methods: {
        // js 动画
        increase (val) {
            // 更新次数
            const updateCount = 200
            let nowT = 0
            let oldY = 0
            const cacheRate = this.preRate
            const update = () => {
                if (++nowT > updateCount) return cancelAnimationFrame(update)
                const y = this.$props.timing(nowT / updateCount) * val
                this.preRate = +(cacheRate + y - oldY).toFixed(this.$props.fixed)
                window.requestAnimationFrame(update)
            }
            window.requestAnimationFrame(update)
        },
        // 预防出现字符串进度
        handlerStrRate (val) {
            if (
                Object.prototype.toString.call(val) === '[object String]' &&
                val.split('%').length
            ) return +val.split('%')[0]
            return val
        },
    },
    watch: {
        '$props.value': {
            handler (after) {
                this.increase(after - this.preRate)
            },
            immediate: true
        },
        '$props.color': {
            handler (after) {
                this.preColor = after
            },
            immediate: true
        }
    }
}
</script>

<template>
    <div
        class="f-progress"
        :style="{
            width: `calc(${wh} * 1px)`,
            height: `calc(${wh} * 1px)`,
            '--pre-color': preColor,
            '--border': border
        }"
    >
        <svg
            xmlns="http://www.w3.org/2000/svg"
            :viewBox="`0 0 ${wh} ${wh}`"
            :width="wh"
            :height="wh"
        >
            <!-- 圆环背景色 -->
            <circle
                class="pie-bg"
                cx="50%"
                cy="50%"
                :r="r"
                :stroke-dasharray="`${section} ${gap}`"
            ></circle>

            <!-- 进度条圆环 -->
            <circle
                class="pie-bar"
                cx="50%"
                cy="50%"
                :r="r"
                :stroke-dasharray="strokeDasharray"
            ></circle>
        </svg>
        <span class="show-pre">{{ handlerStrRate(preRate) }}%</span>
    </div>
</template>
<style scoped lang='scss'>
.f-progress {
    display: flex;
    justify-content: center;
    align-items: center;

    > svg {
        transition: color .6s ease;
        position: absolute;

        circle {
            stroke-dashoffset: 0;
            fill: transparent;
            transform: rotate(-90deg);
            transform-origin: center;
            stroke: var(--pre-color);
            will-change: stroke;
            transition: stroke .6s ease;
            stroke-width: calc(var(--border) * 2px);
        }

        .pie-bg {
            stroke-opacity: .2;
        }

        .pie-bar {
            will-change: stroke-dasharray;
            border-radius: 10px;
        }
    }

    > button {
        position: absolute;
    }
}
</style>
```

### vue3 后续待补