---
title: 轮播组件（carousel）
date: 2023-08-17 08:58:44
tags: [vue2.7]
categories: [自用组件]
---

## 需求

1. 能实现左右上下切换
2. 支持动态添加数据项
3. 可自定义的左右切换箭头
4. 可无缝循环

## 使用

以Vue2为例，最简结构：

```html
<script>
import FCarouselList from "@/components/FCarouselList.vue";
export default {
    components: {
        FCarouselList
    },
    data () {
        return {
            data: [
                {
                    label: '1',
                    keyName: 'label1'
                },
                {
                    label: '2',
                    keyName: 'label2'
                },
                {
                    label: '3',
                    keyName: 'label3'
                },
            ],
            activeKey: ''
        }
    },
    methods: {
        getDemo () {
           return {
               label: Math.round(Math.random() * 1000),
               keyName: Math.random() * 1000 + ''
           }
        },
        unshiftBeforePrev () {
            this.data.unshift(this.getDemo())
            this.toPrev()
        },
        pushBeforeNext () {
            this.data.push(this.getDemo())
            this.toNext()
        },
        toNext () {
            this.$refs.fCarouselList.scrollToNext()
        },
        toPrev () {
            this.$refs.fCarouselList.scrollToPrev()
        },
        toFirst () {
            this.$refs.fCarouselList.scrollToFirst()
        },
        toLast () {
            this.$refs.fCarouselList.scrollToLast()
        }
    }
}
</script>

<template>
    <div class="demo">
        <FCarouselList
            ref="fCarouselList"
            :data="data"
            key-name="keyName"
            v-model="activeKey"
            loop
        >
            <template #default="item">
                <div class="carousel-item">
                    数据：{{ item.label }}
                </div>
            </template>
        </FCarouselList>
        <button @click="unshiftBeforePrev">往前添加数据后上一个</button>
        <button @click="pushBeforeNext">往后添加数据后下一个</button>
        <button @click="toNext">下一个</button>
        <button @click="toPrev">上一个</button>
        <button @click="toFirst">第一个</button>
        <button @click="toLast">最后一个</button>
        <p>{{ activeKey }}</p>
    </div>
</template>

<style lang="scss" scoped>
.demo {
    width: 50%;
    margin: 0 auto;
    height: 100px;

    .carousel-item {
        height: 100%;
        background: sandybrown;
    }
}
</style>
```

{% note warning %}

需要注意的点：

1. `key`的类型一定要是字符串
2. `添加数据后立即切换`操作，当不使用内置方法自己修改绑定值时，需要添加`setTimeout`
3. 当使用`垂直滚动`功能时，一定要让父元素添加高度
4. `template`中的元素并不会默认撑满，为默认大小

<% endnote %>

## 实际使用举例

完成按需加载滚动列表的功能实现，如：

![image.png](https://s2.loli.net/2023/08/22/jkVui4v3GrTSnfp.png)

## FCarouselList.vue

### Vue2版本

```html
<script>
let lock
export default {
    props: {
        // 双向绑定
        value: {
            type: String,
            default: ''
        },
        // 绑定key
        keyName: {
            type: String,
            default: 'key'
        },
        // 初始数据
        data: {
            type: Array,
            default: []
        },
        // 是否开启循环
        loop: {
            type: Boolean,
            default: false
        },
        // 垂直滚动，需要父元素有高度
        vertical: {
            type: Boolean,
            default: false
        },
        // 显示箭头
        arrow: {
            type: Boolean,
            default: true
        }
    },
    data () {
        return {
            renderData: [],
            // 当前这次是否为平滑（为了区分从after或before的矫正）
            isSmooth: true,
        }
    },
    watch: {
        renderData () {
            this.startScroll()
        },
        '$props.value' (_, before) {
            // 首次赋值不执行平滑滚动
            this.startScroll(before)
        },
        // 首次 + 深度
        '$props.data': {
            handler (after) {
                this.renderData = JSON.parse(JSON.stringify(after))
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
                if (smooth) carouseList.style.transitionDuration = `${ duration }ms`
                // 垂直计算高度，水平计算宽度
                if (this.$props.vertical) carouseList.style.transform = `translate3d(0, calc(${ -this.activeIndex } * ${ getComputedStyle(carouseList).height }), 0)`
                else carouseList.style.transform = `translate3d(calc(${ -this.activeIndex } * ${ getComputedStyle(carouseList).width }), 0, 0)`
                // 监听结束后关闭时间，开启矫正
                if (!smooth) return this.scrollend()
                lock && clearTimeout(lock)
                lock = setTimeout(() => {
                    carouseList.style.transitionDuration = '0ms'
                    this.scrollend()
                }, duration)
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
         * 操作方法
         */
        // 滚动至下一个
        scrollToNext () {
            setTimeout(() => {
                this.$emit('input', this.getKeyByIndex(this.nextIndex))
            })
        },
        // 滚动至上一个
        scrollToPrev () {
            setTimeout(() => {
                this.$emit('input', this.getKeyByIndex(this.prevIndex))
            })
        },
        // 滚动到首个
        scrollToFirst () {
            setTimeout(() => {
                this.$emit('input', this.getKeyByIndex(this.firstIndex))
            })
        },
        // 滚动到最后一个
        scrollToLast () {
            setTimeout(() => {
                this.$emit('input', this.getKeyByIndex(this.lastIndex))
            })
        }
    },
    computed: {
        // 根据当前是否为loop模式，确定使用的数据
        activeData () {
            return this.$props.loop ? this.loopData : this.data
        },
        // 根据当前模式获取第一个下标
        firstIndex () {
            return this.$props.loop ? this.renderData.length : 0
        },
        // 根据当前模式获取最后一个下标
        lastIndex () {
            return this.renderData.length - 1 + (this.$props.loop ? this.firstIndex : 0)
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
            if (execKey !== undefined) return [ true, execKey ]
            return [ false, key ]
        },
        // 循环时使用的数据
        loopData () {
            // 复制一个，改变key值防止重复
            const copy = (arr, tag) => {
                const keyName = this.$props.keyName
                return arr.map(v => ({
                    ...v,
                    [keyName]: `${ v[keyName] }_${ tag }`
                }))
            }
            return [
                ...copy(this.renderData, 'before'),
                ...this.renderData,
                ...copy(this.renderData, 'after')
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
        :class="[vertical ? 'carouse-list__wrapper-vertical' : 'carouse-list__wrapper-level']">
        <div
            class='carouse-list__scroll'
            ref='carouseList'>
            <div class="carouse-list__item" v-for='item of activeData' :key='item[keyName]'>
                <slot v-bind='item'>
                    <div class='carouse-list__item-default'>
                        数据：{{ item }}
                    </div>
                </slot>
            </div>
        </div>
        <div
            class='carousel__arrow_prev carousel__arrow'
            @click='scrollToPrev'
            v-if="arrow"
        >
            <slot name="prev">
                <svg t="1692708427506" class="icon" viewBox="0 0 1024 1024" version="1.1"
                     xmlns="http://www.w3.org/2000/svg" p-id="7609" width="20" height="20">
                    <path
                        d="M729.6 931.2l-416-425.6 416-416c9.6-9.6 9.6-25.6 0-35.2-9.6-9.6-25.6-9.6-35.2 0l-432 435.2c-9.6 9.6-9.6 25.6 0 35.2l432 441.6c9.6 9.6 25.6 9.6 35.2 0C739.2 956.8 739.2 940.8 729.6 931.2z"
                        p-id="7610"></path>
                </svg>
            </slot>
        </div>
        <div
            class='carousel__arrow_next carousel__arrow'
            @click='scrollToNext'
            v-if="arrow"
        >
            <slot name="next">
                <svg t="1692708401118" class="icon" viewBox="0 0 1024 1024" version="1.1"
                     xmlns="http://www.w3.org/2000/svg" p-id="7478" id="mx_n_1692708401118" width="20" height="20">
                    <path
                        d="M761.6 489.6l-432-435.2c-9.6-9.6-25.6-9.6-35.2 0-9.6 9.6-9.6 25.6 0 35.2l416 416-416 425.6c-9.6 9.6-9.6 25.6 0 35.2s25.6 9.6 35.2 0l432-441.6C771.2 515.2 771.2 499.2 761.6 489.6z"
                        p-id="7479"></path>
                </svg>
            </slot>
        </div>
    </div>
</template>

<style scoped lang='scss'>
.carouse-list__wrapper {
    position: relative;
    overflow: hidden;
    height: 100%;

    .carouse-list__scroll {
        display: flex;
        height: 100%;
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

    .carousel__arrow {
        position: absolute;
        font-size: 25px;
        opacity: 0;
        transition: .2s;
        z-index: 100;
        cursor: pointer;
        pointer-events: none;
    }

    &.carouse-list__wrapper-level {
        .carousel__arrow {
            top: 50%;
            transform: translate3d(0, -50%, 0);
        }

        .carousel__arrow_prev {
            left: 2px;
        }

        .carousel__arrow_next {
            right: 2px;
        }
    }

    &.carouse-list__wrapper-vertical {
        display: flex;

        .carouse-list__scroll {
            width: 100%;
            flex-direction: column;
        }

        .carousel__arrow {
            left: 50%;
            transform: translate3d(-50%, 0, 0) rotate(90deg);
        }

        .carousel__arrow_prev {
            top: 2px;
        }

        .carousel__arrow_next {
            bottom: 2px;
        }
    }

    &:hover {
        .carousel__arrow {
            opacity: 1;
            pointer-events: auto;
        }
    }
}
</style>
```

### Vue3后续有时间再添加

