---
title: 轮播列表组件（carousel）
date: 2023-08-17 08:58:44
tags: [Vue2, Vue3, JavaScript]
categories: [前端,Vue]
---

## 需求

1. 支持水平垂直滚动
2. 支持动态添加数据项
3. 可自定义的左右切换箭头
4. 三种模式可选（无限滚动，循环滚动，按需滚动）

## 使用

以Vue2为例

<iframe src="/iframe/FCarouselList/index.html#/" height="700px"></iframe>

```html
<script>
import FCarouselList from "@/views/FCarouselList.vue";

export default {
    components: { FCarouselList },
    data () {
        return {
            // 初始数据，key名称默认为key
            carouseDataLoad: [],
            carouseDataLoop: [],
            carouseDataInfinite: [],
            // 绑定key值
            carouseKeyLoad: '0load',
            carouseKeyLoop: '0loop',
            carouseKeyInfinite: '0infinite'
        }
    },
    methods: {
        getInitData (val) {
            return Array.from({ length: 5 }, (_, index) => ({
                key: index + val,
                label: `第 ${index + 1} 项数据 `
            }))
        },
        getDemoData () {
            const random = (Math.random() * 1000).toFixed(5) + ''
            return {
                key: random,
                label: '随机数据' + random
            }
        },
        toUnshift (val) {
            this[val].unshift(this.getDemoData())
        },
        toPush (val) {
            this[val].push(this.getDemoData())
        },
        allUnshift () {
            this.toUnshift('carouseDataLoad')
            this.toUnshift('carouseDataLoop')
            this.toUnshift('carouseDataInfinite')
        },
        allPush () {
            this.toPush('carouseDataLoad')
            this.toPush('carouseDataLoop')
            this.toPush('carouseDataInfinite')
        },
        execEvent (name) {
            this.$refs.fCarouselListLoad[name]()
            this.$refs.fCarouselListInfinite[name]()
            this.$refs.fCarouselListLoop[name]()
        }
    },
    mounted () {
        // 异步加载
        setTimeout(() => {
            this.carouseDataLoad = this.getInitData('load')
            this.carouseDataLoop = this.getInitData('loop')
            this.carouseDataInfinite = this.getInitData('infinite')
        }, 1000)
    }
}
</script>

<template>
    <div>
        <h3>功能展示</h3>
        <button @click="allUnshift">向前添加一项</button>
        <button @click="allPush">向后添加一项</button>
        <button @click="execEvent('scrollToPrev')">向前滚动</button>
        <button @click="execEvent('scrollToNext')">向后滚动</button>
        <button @click="execEvent('scrollToLast')">滚动至最后</button>
        <button @click="execEvent('scrollToFirst')">滚动至第一个</button>
        <h3>三种模式展示，鼠标放置显示箭头:</h3>
        无限加载模式，长度：{{ carouseDataLoad.length }}
        <div class="carouse-list__demo-box">
            <FCarouselList
                :data='carouseDataLoad'
                v-model='carouseKeyLoad'
                ref="fCarouselListLoad"
                type="load"
                @loadPrev="toUnshift('carouseDataLoad')"
                @loadNext="toPush('carouseDataLoad')"
            >
                <template #default='{ label }'>
                    <div class="carouse-list__demo-item">
                        {{ label }}
                    </div>
                </template>
            </FCarouselList>
        </div>
        循环模式，长度：{{ carouseDataLoop.length }}
        <div class="carouse-list__demo-box">
            <FCarouselList
                :data='carouseDataLoop'
                v-model='carouseKeyLoop'
                type="loop"
                ref="fCarouselListLoop"
            >
                <template #default='{ label }'>
                    <div class="carouse-list__demo-item">
                        {{ label }}
                    </div>
                </template>
            </FCarouselList>
        </div>
        无限滚动模式（默认），垂直滚动，长度：{{ carouseDataInfinite.length }}
        <div class="carouse-list__demo-box">
            <FCarouselList
                :data='carouseDataInfinite'
                v-model='carouseKeyInfinite'
                ref="fCarouselListInfinite"
                vertical
            >
                <template #default='{ label }'>
                    <div class="carouse-list__demo-item">
                        {{ label }}
                    </div>
                </template>
            </FCarouselList>
        </div>
    </div>
</template>

<style scoped lang="scss">
.carouse-list__demo-box {
    height: 100px;
    border: 1px solid #ccc;
    margin: 20px 0;

    .carouse-list__demo-item {
        background: #AEC3AE;
        line-height: 100px;
        font-size: 30px;
        text-align: center;
        color: white;
    }
}
</style>

```

{% note warning %}

需要注意的点：

1. 轮播的插槽`default`必须有一个根标签，并且只能有一个
2. 当使用`垂直滚动`功能时，父元素一定要存在高度
3. 一定要指定绑定的key，为空时不会显示当前项目（8/29，待优化）

{% endnote %}

## 实际使用举例

完成按需加载滚动列表的功能实现，如：

![image.png](https://s2.loli.net/2023/08/22/jkVui4v3GrTSnfp.png)

## FCarouselList.vue

### Vue2版本

```html
<script>
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
        // 垂直滚动，需要父元素有高度
        vertical: {
            type: Boolean,
            default: false
        },
        // 轮播类型
        type: {
            type: String,
            default: 'infinite'
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
            lock: void 0
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
                if (!after?.length) return
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
                const duration = 400
                const carouseList = this.$refs.carouseList
                if (smooth) carouseList.style.transitionDuration = `${ duration }ms`
                // 垂直计算高度，水平计算宽度
                if (this.$props.vertical) carouseList.style.transform = `translate3d(0, calc(
                    ${ -this.activeIndex } *
                    ${ getComputedStyle(carouseList).height }
                ), 0)`
                else carouseList.style.transform = `translate3d(calc(
                    ${ -this.activeIndex } *
                    ${ getComputedStyle(carouseList).width }
                ), 0, 0)`
                // 监听结束后关闭时间，开启矫正
                if (!smooth) return this.scrollend()
                this.lock && clearTimeout(this.lock)
                this.lock = setTimeout(() => {
                    carouseList.style.transitionDuration = '0ms'
                    this.scrollend()
                }, duration)
            })
        },
        // 使用下标换key
        getKeyByIndex (index) {
            return this.activeData[index][this.$props.keyName]
        },
        // 滚动结束处理
        scrollend () {
            // 还原滚动状态
            this.isSmooth = true
            // 如果为load模式，判断加载数据
            if (this.$props.type === 'load') {
                // 到达最后一个数据
                if (this.activeIndex === this.firstIndex) this.$emit('loadPrev')
                // 到达第一个数据
                if (this.activeIndex === this.lastIndex) this.$emit('loadNext')
            }
            if (this.$props.type === 'infinite') {
                requestAnimationFrame(() => {
                    const [needChange, changeKey] = this.sectionAfterKey
                    // 如果在上面两个区间中，则调整回去
                    if (!needChange) return
                    this.isSmooth = false
                    this.$emit('input', changeKey)
                })
            }
        },
        /**
         * 操作方法
         */
        // 滚动至下一个
        scrollToNext () {
            this.$emit('change', 'next')
            this.$emit('input', this.getKeyByIndex(this.nextIndex))
        },
        // 滚动至上一个
        scrollToPrev () {
            this.$emit('change', 'prev')
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
        // 根据当前是否为infinite模式，确定使用的数据
        activeData () {
            return this.$props.type === 'infinite' ? this.infiniteData : this.data
        },
        // 根据当前模式获取第一个下标
        firstIndex () {
            return this.$props.type === 'infinite' ? this.renderData.length : 0
        },
        // 根据当前模式获取最后一个下标
        lastIndex () {
            return this.renderData.length - 1 + (this.$props.type === 'infinite' ? this.firstIndex : 0)
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
        // 无限时使用的数据
        infiniteData () {
            // 复制，改变key值防止重复
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
            // 到最后，非循环
            if (this.activeIndex === this.activeData.length - 1 && this.$props.type !== 'loop') return this.activeIndex
            return (this.activeIndex + 1) % this.activeData.length
        },
        // 上一个元素下标
        prevIndex () {
            // 非循环模式
            if (this.activeIndex === 0 && this.$props.type !== 'loop') return this.activeIndex
            return (this.activeIndex - 1 + this.activeData.length) % this.activeData.length
        },
    },
}
</script>

<template>
    <div
        class='carouse-list__wrapper'
        :class="[vertical ? 'carouse-list__wrapper-vertical' : 'carouse-list__wrapper-level']"
        v-if="data.length"
    >
        <div
            class='carouse-list__scroll'
            ref='carouseList'>
            <slot v-bind='item' v-for='item of activeData'>
                <div class='carouse-list__item-default'>
                    数据：{{ item }}
                </div>
            </slot>
        </div>
        <div
            class='carousel__arrow_prev carousel__arrow'
            @click='scrollToPrev'
            v-if="arrow && (type !== 'load' || activeIndex !== firstIndex)"
        >
            <slot name='prev'>
                <svg t='1692708427506' class='icon' viewBox='0 0 1024 1024' version='1.1'
                     xmlns='http://www.w3.org/2000/svg' p-id='7609' width='20' height='20'>
                    <path
                        d='M729.6 931.2l-416-425.6 416-416c9.6-9.6 9.6-25.6 0-35.2-9.6-9.6-25.6-9.6-35.2 0l-432 435.2c-9.6 9.6-9.6 25.6 0 35.2l432 441.6c9.6 9.6 25.6 9.6 35.2 0C739.2 956.8 739.2 940.8 729.6 931.2z'
                        p-id='7610'></path>
                </svg>
            </slot>
        </div>
        <div
            class='carousel__arrow_next carousel__arrow'
            @click='scrollToNext'
            v-if="arrow && (type !== 'load' || activeIndex !== lastIndex)"
        >
            <slot name='next'>
                <svg t='1692708401118' class='icon' viewBox='0 0 1024 1024' version='1.1'
                     xmlns='http://www.w3.org/2000/svg' p-id='7478' id='mx_n_1692708401118' width='20' height='20'>
                    <path
                        d='M761.6 489.6l-432-435.2c-9.6-9.6-25.6-9.6-35.2 0-9.6 9.6-9.6 25.6 0 35.2l416 416-416 425.6c-9.6 9.6-9.6 25.6 0 35.2s25.6 9.6 35.2 0l432-441.6C771.2 515.2 771.2 499.2 761.6 489.6z'
                        p-id='7479'></path>
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

