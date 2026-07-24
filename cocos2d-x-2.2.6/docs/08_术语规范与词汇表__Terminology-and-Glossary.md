# 术语规范与词汇表 __ Terminology and Glossary

> **版本**: 1.0
> **创建日期**: 2026-01-27
> **目的**: 提供Cocos2d-x 2.0.1的标准化术语和词汇表

---

## 目录

1. [核心术语](#核心术语)
2. [渲染术语](#渲染术语)
3. [动画术语](#动画术语)
4. [事件术语](#事件术语)
5. [资源管理术语](#资源管理术语)

---

## 核心术语

| 术语 | 英文 | 定义 |
|-----|------|------|
| 导演 | Director | 管理场景切换和游戏循环的核心类 |
| 场景 | Scene | 游戏场景的容器，包含多个层 |
| 层 | Layer | 用于组织游戏元素的容器，可以处理触摸事件 |
| 节点 | Node | 所有可视对象的基类 |
| 精灵 | Sprite | 可渲染的2D图像对象 |
| 锚点 | Anchor Point | 节点的定位参考点，默认为(0.5, 0.5) |
| 坐标系 | Coordinate System | 用于定位对象的坐标系统，包括世界坐标、节点坐标等 |

---

## 渲染术语

| 术语 | 英文 | 定义 |
|-----|------|------|
| 纹理 | Texture | 应用于3D模型的2D图像 |
| 着色器 | Shader | 用于渲染的GPU程序 |
| 批处理 | Batch Processing | 将多个渲染调用合并为一个以提高性能 |
| 混合模式 | Blend Mode | 控制颜色如何混合的设置 |
| 帧缓冲 | Frame Buffer | 存储渲染结果的内存缓冲区 |

---

## 动画术语

| 术语 | 英文 | 定义 |
|-----|------|------|
| 动作 | Action | 应用于节点的动画效果 |
| 缓动函数 | Easing Function | 控制动画速度变化的数学函数 |
| 序列动作 | Sequence Action | 按顺序执行多个动作 |
| 并行动作 | Spawn Action | 同时执行多个动作 |
| 帧动画 | Frame Animation | 通过切换图像帧实现的动画 |

---

## 事件术语

| 术语 | 英文 | 定义 |
|-----|------|------|
| 触摸事件 | Touch Event | 用户触摸屏幕时触发的事件 |
| 触摸分发器 | Touch Dispatcher | 管理触摸事件分发的类 |
| 触摸处理器 | Touch Handler | 处理触摸事件的回调函数 |
| 优先级 | Priority | 决定事件处理顺序的数值 |

---

## 资源管理术语

| 术语 | 英文 | 定义 |
|-----|------|------|
| 纹理缓存 | Texture Cache | 缓存纹理以提高性能的机制 |
| 精灵帧缓存 | Sprite Frame Cache | 缓存精灵帧以提高性能的机制 |
| 引用计数 | Reference Counting | 管理对象生命周期的内存管理机制 |
| 自动释放池 | Autorelease Pool | 延迟释放对象的内存优化机制 |

---

## 相关文档

- [00_文档索引__Documentation-Index.md](00_文档索引__Documentation-Index.md)
- [01_项目概览__Project-Overview.md](01_项目概览__Project-Overview.md)
- [02_核心类架构__Core-Classes-Architecture.md](02_核心类架构__Core-Classes-Architecture.md)

---

**文档版本**: 1.0
**最后更新**: 2026-01-27
