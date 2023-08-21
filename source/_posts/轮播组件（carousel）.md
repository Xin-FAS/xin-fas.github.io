---
title: 轮播组件（carousel）
date: 2023-08-17 08:58:44
tags: [vue2.7]
categories: [自用组件]
---

## 需求

1. 能实现左右上下切换
2. 支持动态添加
3. 可自定义的左右切换箭头
4. 可自定义的指示器
4. 可无缝循环

## 使用

待完善后补全

## FCarouselList.vue

V1.0 基础待迭代，已实现功能点1，2，5，Vue3版本待完善后补全

```html
<script>
let lock
export default {
    props: {
        // 双向绑定
        value: {
            type: String | Number,
            default: ''
        },
        // 绑定key
        keyName: {
            type: String,
            default: 'key'
        },
        // 初始数据
        initData: {
            type: Array,
            default: []
        },
        // 是否开启循环
        loop: {
            type: Boolean,
            default: true
        },
        // 垂直滚动，需要父元素有高度
        vertical: {
            type: Boolean,
            default: true
        },
    },
    data () {
        return {
            data: [],
            // 当前这次是否为平滑（为了区分从after或before的矫正）
            isSmooth: true,
        }
    },
    watch: {
        data () {
            this.startScroll()
        },
        '$props.value' () {
            this.startScroll(true)
        },
        // 首次 + 深度
        '$props.initData': {
            handler (after) {
                this.data = JSON.parse(JSON.stringify(after))
            },
            deep: true,
            immediate: true
        }
    },
    methods: {
        // 开始滚动，isSmooth：是否平滑滚动
        startScroll (isSmooth = false) {
            this.$nextTick(() => {
                const smooth = isSmooth && this.isSmooth
                const duration = 300
                const carouseList = this.$refs.carouseList
                if (smooth) carouseList.style.transitionDuration = `${duration}ms`
                // 垂直计算高度，水平计算宽度
                if (this.$props.vertical) carouseList.style.transform = `translate3d(0, calc(${ -this.activeIndex } * ${ getComputedStyle(carouseList).height }), 0)`
                else carouseList.style.transform = `translate3d(calc(${ -this.activeIndex } * ${ getComputedStyle(carouseList).width }), 0, 0)`
                // 以下监听待优化
                if (smooth) {
                    lock && clearTimeout(lock)
                    lock = setTimeout(() => {
                        carouseList.style.transitionDuration = '0ms'
                        this.scrollend()
                    }, duration)
                } else {
                    this.scrollend()
                }
            })
        },
        // 使用下标换key
        getKeyByIndex (index) {
            return this.activeData[index][this.$props.keyName]
        },
        // 监听滚动结束
        scrollend (event) {
            if (!this.$props.loop) return
            requestAnimationFrame(() => {
                // 还原滚动状态
                this.isSmooth = true
                const sectionAfterKey = this.sectionAfterKey
                // 如果在上面两个区间中，则调整回去
                if (!sectionAfterKey[0]) return
                this.isSmooth = false
                this.$emit('input', sectionAfterKey[1])
            })
        },
        /**
         * 以下是一些方便父元素操作的快捷方法
         */
        // 滚动至下一个
        scrollToNext () {
            this.$emit('input', this.getKeyByIndex(this.nextIndex))
        },
        // 滚动至上一个
        scrollToPrev () {
            this.$emit('input', this.getKeyByIndex(this.prevIndex))
        },
        // 滚动到首个
        scrollToFirst () {
            this.$emit('input', this.getKeyByIndex(this.firstIndex))
        },
        // 滚动到最后一个
        scrollToLast () {
            this.$emit('input', this.getKeyByIndex(this.lastIndex))
        }
    },
    computed: {
        // 根据当前是否为loop模式，确定使用的数据
        activeData () {
            return this.$props.loop ? this.loopData : this.data
        },
        // 根据当前模式获取第一个下标
        firstIndex () {
            return this.$props.loop ? this.data.length : 0
        },
        // 根据当前模式获取最后一个下标
        lastIndex () {
            return this.data.length - 1 + (this.$props.loop ? this.firstIndex: 0)
        },
        // 需要矫正后的key，[是否需要矫正，矫正后的key]
        sectionAfterKey () {
            const key = this.$props.value
            const execAfter = /(.*?)_after$/.exec(key)
            let execKey
            // 判断after区间
            if (execAfter) execKey = execAfter[1]
            const execBefore = /(.*?)_before$/.exec(key)
            // 判断before区间
            if (execBefore) execKey = execBefore[1]
            if (execKey !== undefined) return [true, execKey]
            return [false, key]
        },
        // 循环时使用的数据
        loopData () {
            // 复制一个，改变key值防止重复
            const copy = (obj, tag) => {
                const keyName = this.$props.keyName
                return {
                    ...obj,
                    [keyName]: `${ obj[keyName] }_${ tag }`
                }
            }
            const copyd = (arr, tag) => {
                const keyName = this.$props.keyName
                return arr.map(v => ({
                    ...v,
                    [keyName]: `${ v[keyName] }_${ tag }`
                }))
            }
            // return [
            //     copy(this.data[this.data.length - 1], 'before'),
            //     ...this.data,
            //     copy(this.data[0], 'after')
            // ]
            return [
                ...copyd(this.data, 'before'),
                ...this.data,
                ...copyd(this.data, 'after')
            ]
        },
        // 当前渲染元素下标
        activeIndex () {
            return this.activeData.findIndex(v => v[this.$props.keyName] === this.$props.value)
        },
        // 下一个元素下标
        nextIndex () {
            // 如果是循环模式，就算到了最后一个也不应该回到初始
            if (this.$props.loop && this.activeIndex === this.activeData.length - 1) return this.activeIndex
            return (this.activeIndex + 1) % this.activeData.length
        },
        // 上一个元素下标
        prevIndex () {
            // 如果是循环模式，就算到了第一个也不应该回到最后
            if (this.$props.loop && this.activeIndex === 0) return this.activeIndex
            return (this.activeIndex - 1 + this.activeData.length) % this.activeData.length
        }
    },
    mounted () {
        // 如果value为空，则默认赋值为第一个数据
        if (!this.$props.value) this.$emit('input', this.getKeyByIndex(this.firstIndex))
    }
}
</script>

<template>
    <div
        class='carouse-list__wrapper'
        :class="{
            'carouse-list__wrapper-vertical': vertical
        }"
    >
        <div
            class='carouse-list__scroll'
            ref='carouseList'
        >
            <slot v-bind='item' v-for='item of activeData'>
                <div class='carouse-list__item-default' :key='item[keyName]'>
                    数据：{{ item.label }}
                </div>
            </slot>
        </div>
    </div>
</template>

<style scoped lang='less'>
.carouse-list__wrapper {
    overflow: hidden;

    .carouse-list__scroll {
        display: flex;
        transform: translate3d(0, 0, 0);
        transition-timing-function: ease;

        & > * {
            flex: 1 0 100%;
        }
    }

    .carouse-list__item-default {
        height: 200px;
        background: #eee;
        padding: 20px;
        box-sizing: border-box;
    }

    &.carouse-list__wrapper-vertical {
        display: flex;
        height: 100%;

        .carouse-list__scroll {
            height: 100%;
            width: 100%;
            flex-direction: column;
        }
    }
}
</style>
```
