---
title: 对话框组件（FDialog）
date: 2023-09-15 22:17:15
tags: [Vue2, Vue3]
categories: [前端, Vue]
---

## 介绍

要使用对话框时还要引入其他库，太麻烦了，就自己手撕了一个，凑合着用

## 使用

<iframe src="/iframe/FDialog/index.html#/" height="500px"></iframe>

```html
<script>
import FDialog from "@/pages-auto/FDialog.vue";

export default {
    components: {
        FDialog
    },
    data () {
        return {
            dialogVisible: false,
        }
    },
}
</script>

<template>
    <div>
        <div style="display: flex;justify-content: space-between">
            <button @click="dialogVisible=!dialogVisible">
                {{ dialogVisible ? '关闭' : '打开' }}基础对话框
            </button>
            <button @click="dialogVisible=!dialogVisible">
                {{ dialogVisible ? '关闭' : '打开' }}基础对话框
            </button>
        </div>
        <FDialog
            v-model="dialogVisible"
            width="401px"
            height="200px"
            title="Hello Everyone"
        >
            Note then it ? have a small issue.
        </FDialog>
    </div>
</template>
```

### 插槽

目前存在四个插槽

1. `header`（自定对话框顶部区域）
2. `default`（不解释）
3. `footer`（自定底部区域，存在对话框的内边框）
4. `fixed-footer`（自定底部区域，不存在对话框内边框，可用于做移动端对话框底部）

### 属性

| 属性名        | 说明                                                   | 默认值 |
| ------------- | ------------------------------------------------------ | ------ |
| value/v-model | 双向绑定值，对话框展开状态                             |        |
| title         | 对话框标题（标题和头部插槽都为空时会自动隐藏头部区域） |        |
| width         | 对话框内容宽度                                         | 80%    |
| height        | 对话框内容高度                                         | 60%    |
| mask          | 是否使用遮罩                                           | true   |
| wrapEnterTime | 对话框内容进入过渡时间                                 | 200    |
| wrapLeaveTime | 对话框内容离开过渡时间                                 | 150    |

## FDialog.vue

```html
<script>
export default {
    inheritAttrs: false,
    props: {
        value: {
            type: Boolean,
            default: false,
            require: true
        },
        // 对话框标题
        title: {
            type: String,
            default: ''
        },
        // 对话框内容宽度
        width: {
            type: String,
            default: '80%'
        },
        // 对话框内容高度
        height: {
            type: String,
            default: '60%'
        },
        // 是否使用遮罩
        mask: {
            type: Boolean,
            default: true
        },
        // 对话框内容进入过渡时间
        wrapEnterTime: {
            type: Number,
            default: 200
        },
        // 对话框内容离开过渡时间
        wrapLeaveTime: {
            type: Number,
            default: 150
        }
    },
    data () {
        return {
            clientX: undefined,
            clientY: undefined,
        }
    },
    methods: {
        // 获取body滚动条宽度
        getScrollYWidth () {
            // 浏览器窗口大小 - 页面可视区域宽度
            let cWidth = document.body.clientWidth || document.documentElement.clientWidth;
            let iWidth = window.innerWidth;
            return iWidth - cWidth
        },
        // 去除滚动条
        removeScrollY () {
            setTimeout(() => {
                // 添加失去的滚动条宽度
                const scrollWidth = this.getScrollYWidth()
                document.body.style.overflowY = 'hidden'
                document.body.style.width = `calc(100% - ${scrollWidth}px)`
            })
        },
        // 还原滚动条
        resetScrollY () {
            document.body.style.overflowY = 'auto'
            document.body.style.width = `100%`
        },
        // 关闭对话框
        closeDialog () {
            setTimeout(() => {
                // 离开动画结束后查询dom，是否还存在其他对话框，没有就还原滚动条
                const wrap = document.querySelector('.f-dialog-wrap')
                if (!wrap) this.resetScrollY()
                // 关闭的时候还原初始坐标
                if (!this.$props.value) this.setClientXYInfo()
            }, this.$props.wrapLeaveTime + 50)
        },
        // 通知关闭
        emitsClose () {
            this.$emit('input', false)
        },
        // 赋值坐标
        setClientXYInfo (x, y) {
            this.clientX = x
            this.clientY = y
        },
        // 监听点击事件
        domClick (e) {
            // 对话框打开，没有初始坐标就赋值
            console.log(this.$props.value, this.clientX, this.clientY)
            if (this.$props.value && !this.clientX && !this.clientY)
                this.setClientXYInfo(e.clientX, e.clientY)
        }
    },
    mounted () {
        // 监听鼠标点击冒泡，获取初始坐标
        document.addEventListener('click', this.domClick)
        // 移动到body下，防止打乱布局
        const appDialog = document.querySelector('#app .f-dialog')
        document.body.appendChild(appDialog)
    },
    destroyed () {
        document.removeEventListener('click', this.domClick)
    },
    watch: {
        '$props.value' (after) {
            // 处理浏览器滚动条
            after ? this.removeScrollY() : this.closeDialog()
        }
    },
}
</script>

<template>
    <div class="f-dialog" :style="{
        '--wrap-enter-time': wrapEnterTime,
        '--wrap-leave-time': wrapLeaveTime,
        '--width': width,
        '--height': height,
        '--clientX': clientX,
        '--clientY': clientY
    }">
        <Transition
            mode="out-in"
            enter-active-class="mask-enter"
            leave-active-class="mask-leave"
        >
            <!-- 遮罩 -->
            <div class="f-dialog-mask fixed-screen" @click="emitsClose" v-if="value && mask"/>
        </Transition>
        <Transition
            mode="out-in"
            enter-active-class="wrap-enter"
            leave-active-class="wrap-leave"
        >
            <!-- 内容 -->
            <div class="f-dialog-wrap" v-bind="$attrs" v-if="value">
                <div class="wrap-title" v-if="'header' in $slots || title">
                    <slot name='header'>{{ title }}</slot>
                </div>
                <div class="wrap-body">
                    <slot name="default">default body</slot>
                </div>
                <div class="wrap-footer" v-if="'footer' in $slots">
                    <slot name="footer">default footer</slot>
                </div>
                <div class="wrap-footer-fixed" v-if="'fixed-footer' in $slots">
                    <slot name="fixed-footer">default fixed footer</slot>
                </div>
                <!-- 右上角关闭按钮 -->
                <button class="f-dialog-close" @click="emitsClose">
                    <svg viewBox="64 64 896 896" focusable="false" data-icon="close" width="1em" height="1em" fill="currentColor" aria-hidden="true">
                        <path
                            d="M563.8 512l262.5-312.9c4.4-5.2.7-13.1-6.1-13.1h-79.8c-4.7 0-9.2 2.1-12.3 5.7L511.6 449.8 295.1 191.7c-3-3.6-7.5-5.7-12.3-5.7H203c-6.8 0-10.5 7.9-6.1 13.1L459.4 512 196.9 824.9A7.95 7.95 0 00203 838h79.8c4.7 0 9.2-2.1 12.3-5.7l216.5-258.1 216.5 258.1c3 3.6 7.5 5.7 12.3 5.7h79.8c6.8 0 10.5-7.9 6.1-13.1L563.8 512z">
                        </path>
                    </svg>  
                </button>
            </div>
        </Transition>
    </div>
</template>
<style scoped lang='scss'>
.f-dialog {
    // 遮罩进入
    .mask-enter {
        animation: maskEnter calc(var(--wrap-enter-time) * 1ms + 100ms) linear;
    }
    // 内容进入
    .wrap-enter {
        animation: wrapEnter calc(var(--wrap-enter-time) * 1ms) cubic-bezier(.08,.82,.17,1);
    }
    // 遮罩离开
    .mask-leave {
        animation: maskLeave calc(var(--wrap-leave-time) * 1ms + 100ms) linear;
        pointer-events: none;
    }
    // 内容离开
    .wrap-leave {
        animation: wrapLeave calc(var(--wrap-leave-time) * 1ms) cubic-bezier(.83, 0, .92, .18);
        pointer-events: none;
    }
    .fixed-screen {
        position: fixed;
        left: 0;
        top: 0;
        width: 100%;
        height: 100%;
    }
    .f-dialog-mask {
        background-color: rgba(0, 0, 0, 0.45);
        z-index: 1010;
    }
    // 主内容
    .f-dialog-wrap {
        position: fixed;
        left: 50%;
        top: 50%;
        transform: translate(-50%,-50%);
        width:  var(--width);
        height: var(--height);
        background-color: rgba(255, 255, 255);
        box-shadow: 0 6px 16px 0 rgba(0,0,0,.08), 0 3px 6px -4px rgba(0,0,0,.12), 0 9px 28px 8px rgba(0,0,0,.05);
        border-radius: 8px;
        border: none;
        padding: 20px 24px;
        color: rgba(0,0,0,.88);
        display: flex;
        flex-direction: column;
        font-weight: 400;
        z-index: 1010;
        will-change: opacity, left, top, transform;

        // 右上关闭按钮
        .f-dialog-close {
            position: absolute;
            top: 17px;
            right: 0;
            font-size: 16px;
            display: flex;
            justify-content: center;
            align-items: center;
            inset-inline-end: 17px;
            padding: 0;
            color: rgba(0,0,0,.45);
            font-weight: 600;
            line-height: 1;
            text-decoration: none;
            background: 0 0;
            border-radius: 4px;
            width: 22px;
            height: 22px;
            border: 0;
            outline: 0;
            cursor: pointer;
            transition: color .2s, background-color .2s;

            &:hover {
                background-color: #f0f0f0;
                color: #1d1d1d;
            }

            &:active {
                background-color: #d9d9d9;
                color: #1a1a1a;
            }
        }

        .wrap-title {
            color: rgba(0,0,0,.88);
            font-weight: 600;
            font-size: 16px;
            line-height: 1.5;
            word-wrap: break-word;
            padding-right: 10px;
            margin-bottom: 8px;
        }

        .wrap-body {
            flex: 1;
            min-height: 0;
            font-size: 14px;
            line-height: 1.5;
            word-wrap: break-word;
            font-weight: 400;
            overflow: auto;
        }
        
        .wrap-footer {
            padding-top: 12px;
        }

        .wrap-footer-fixed {
            position: absolute;
            left: 0;
            bottom: 0;
            width: 100%;
        }
    }
}
// 对话框内容进入
@keyframes wrapEnter {
    0% {
        left: calc(var(--clientX) * 1px);
        top: calc(var(--clientY) * 1px);
        transform: translate(-50%, -50%) scale(.2);
        opacity: 0;
    }
    5% {
        opacity: 0;
    }
    100% {
        left: 50%;
        top: 50%;
        transform: translate(-50%, -50%) scale(1);
    } 
}
// 对话框内容离开
@keyframes wrapLeave {
    95% {
        opacity: 0;
    }
    100% {
        left: calc(var(--clientX) * 1px);
        top: calc(var(--clientY) * 1px);
        transform: translate(-50%, -50%) scale(.2);
        opacity: 0;
    } 
}
// 遮罩进入
@keyframes maskEnter {
    0% {
        opacity: 0;
    }
    100% {
        opacity: 1;
    } 
}
// 遮罩离开
@keyframes maskLeave {
    0% {
        opacity: 1;
    }
    100% {
        opacity: 0;
    } 
}
</style>
```
