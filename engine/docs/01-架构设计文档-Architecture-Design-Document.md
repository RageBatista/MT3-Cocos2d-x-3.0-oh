# 01-架构设计文档 Architecture Design Document

## 1. 概述 Overview

### 1.1 项目简介 Project Introduction

Nuclear Engine是一个基于Cocos2d-x的高性能2D游戏引擎，专为移动平台（iOS、Android、Windows Phone）设计。引擎提供了完整的游戏开发功能，包括精灵系统、特效系统、地图系统、粒子系统、渲染系统等核心模块。

Nuclear Engine is a high-performance 2D game engine based on Cocos2d-x, designed specifically for mobile platforms (iOS, Android, Windows Phone). The engine provides comprehensive game development features, including sprite systems, effect systems, map systems, particle systems, rendering systems, and other core modules.

### 1.2 技术栈 Technology Stack

- **编程语言**: C++
- **渲染引擎**: Cocos2d-x 2.0-rc2-x-2.0.1
- **骨骼动画**: Spine
- **平台支持**: iOS、Android、Windows Phone 8
- **构建系统**: Visual Studio (Windows)、Xcode (iOS)、NDK (Android)
- **内存管理**: 自定义NED Malloc分配器

## 2. 系统架构 System Architecture

### 2.1 整体架构图 Overall Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Application Layer                     │
│                   (IApp / Game Logic)                    │
└─────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────┐
│                      Engine Core                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌─────────┐ │
│  │ IEngine  │  │  IWorld  │  │  IEnv    │  │ IQuery  │ │
│  └──────────┘  └──────────┘  └──────────┘  └─────────┘ │
└─────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────┐
│                    Manager Layer                         │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │SpriteManager│  │EffectManager │  │AniManager    │  │
│  └─────────────┘  └──────────────┘  └──────────────┘  │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │ConfigManager│  │FileIOManager │  │SpineManager  │  │
│  └─────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────┐
│                   Component Layer                        │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌────────┐ │
│  │  Sprite  │  │  Effect  │  │ Particle │  │  Map   │ │
│  └──────────┘  └──────────┘  └──────────┘  └────────┘ │
└─────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────┐
│                    Renderer Layer                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │   Renderer   │  │FontManager   │  │StateManager  │ │
│  └──────────────┘  └──────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────┐
│                  Common/Utility Layer                    │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌────────┐ │
│  │  Timer   │  │  Math    │  │  FileIO  │  │  Lock  │ │
│  └──────────┘  └──────────┘  └──────────┘  └────────┘ │
└─────────────────────────────────────────────────────────┘
```

### 2.2 核心模块 Core Modules

#### 2.2.1 引擎核心 Engine Core

**IEngine** - 引擎主接口，提供以下核心功能：
- 引擎初始化与运行控制
- 屏幕管理（分辨率、视口）
- 时间管理（FPS控制、游戏时间）
- 内存管理（GC机制）
- 任务调度（用户任务、定时器）
- 日志系统

**IWorld** - 游戏世界管理：
- 地图加载与卸载
- 精灵管理（创建、删除、层级）
- 特效管理（场景特效、精灵特效）
- 相机控制
- A*寻路系统
- 物理障碍管理

**IEnv** - 环境配置管理：
- 显示模式配置
- FPS控制策略
- 渲染效果配置（夜晚、阴影、半透明）
- 声音系统配置
- 性能优化配置

**IQuery** - 查询接口：
- 动作信息查询
- 精灵层级信息查询

#### 2.2.2 管理器模块 Manager Modules

**SpriteManager** - 精灵管理器
- 精灵生命周期管理
- 精灵资源加载与释放
- 精灵动作管理

**EffectManager** - 特效管理器
- 特效资源管理
- 特效播放控制
- 特效缓存机制

**AniManager** - 动画管理器
- 动画资源加载
- 动画帧管理
- 动画播放控制

**ConfigManager** - 配置管理器
- 配置文件解析
- 配置项管理
- 配置热更新

**FileIOManager** - 文件IO管理器
- 异步文件加载
- 资源缓存管理
- 文件路径管理

**SpineManager** - Spine骨骼动画管理器
- Spine资源加载
- 骨骼动画播放
- 骨骼动画混合

#### 2.2.3 组件模块 Component Modules

**Sprite** - 精灵组件
- 2D/3D精灵支持
- 多层装备系统
- 动作系统
- 移动系统（A*寻路）
- 特效绑定

**Effect** - 特效组件
- 粒子特效
- Ani特效
- Spine特效
- 特效链系统

**Particle** - 粒子系统
- 通用粒子系统
- 特殊粒子系统
- 粒子发射器
- 粒子生命周期管理

**Map** - 地图系统
- 地块管理
- 障碍物管理
- 水域管理
- 步伐声音区域
- 时间效果

#### 2.2.4 渲染模块 Renderer Modules

**Renderer** - 渲染器
- 绘图接口封装
- 渲染状态管理
- 性能统计

**FontManager** - 字体管理器
- 字体资源加载
- 文本渲染
- 字体纹理管理

**StateManager** - 状态管理器
- 渲染状态栈
- 状态切换优化

## 3. 目录结构 Directory Structure

```
engine/
├── astar/              # A*寻路算法模块
│   ├── nuastar.hpp     # A*算法核心
│   ├── nuapath.hpp     # 路径数据结构
│   └── ...
├── common/             # 通用工具模块
│   ├── nuxptypes.h     # 基础类型定义
│   ├── nuxpmaths.h     # 数学库
│   ├── nufileiomanager.h/cpp  # 文件IO管理
│   ├── nutimer.h/cpp   # 定时器
│   └── nedmalloc/      # 自定义内存分配器
├── engine/             # 引擎核心模块
│   ├── nuengine.h/cpp  # 引擎实现
│   ├── nuenv.h/cpp     # 环境管理
│   ├── nuconfigmanager.h/cpp  # 配置管理
│   ├── nuanimanager.h/cpp     # 动画管理
│   ├── nuspinemanager.h/cpp   # Spine管理
│   └── ...
├── renderer/           # 渲染模块
│   ├── nurenderer.h/cpp        # 渲染器
│   ├── nufontmanager.h/cpp     # 字体管理
│   ├── nustatemanager.h/cpp    # 状态管理
│   └── ...
├── sprite/             # 精灵模块
│   ├── nusprite.h/cpp  # 精灵基类
│   ├── nuspritemanager.h/cpp   # 精灵管理器
│   ├── nuspinesprite.h/cpp     # Spine精灵
│   └── ...
├── effect/             # 特效模块
│   ├── nueffect.h/cpp  # 特效基类
│   ├── nueffectmanager.h/cpp   # 特效管理器
│   ├── nuparticleeffect.h/cpp   # 粒子特效
│   └── ...
├── particlesystem/      # 粒子系统模块
│   ├── nuparticlesystem.h/cpp  # 粒子系统
│   ├── nuparticlemanager.h/cpp # 粒子管理器
│   └── ...
├── map/                # 地图模块
│   ├── numap.h/cpp     # 地图核心
│   ├── nupground.h/cpp # 地面
│   ├── nupwaterarea.h/cpp      # 水域
│   └── ...
├── world/              # 世界模块
│   ├── nuworld.h/cpp   # 世界管理
│   ├── numap.h/cpp     # 地图管理
│   ├── nuimmovableobj.h/cpp     # 不可移动对象
│   └── ...
├── soundarea/          # 声音区域模块
│   ├── xpsoundarea.h/cpp       # 声音区域基类
│   ├── stepsoundtype.h/cpp     # 步伐声音类型
│   └── ...
├── tolua++-pkgs/       # Lua绑定配置
│   ├── engine/         # 引擎接口绑定
│   └── ...
└── docs/               # 文档目录
```

## 4. 核心设计模式 Core Design Patterns

### 4.1 单例模式 Singleton Pattern

引擎核心类使用单例模式确保全局唯一实例：
- `GetEngine()` - 命名空间级裸函数，获取 `IEngine` 接口指针（定义于 `engine/nuiengine.h`）
- `Engine::GetInstance()` - 引擎实现类内部获取实例（定义于 `engine/engine/nuengine.h`，非公共接口）

> 注意：`GetEngine()` 是公共 API 入口，不是 `IEngine` 的 `static` 成员方法。

### 4.2 工厂模式 Factory Pattern

精灵和特效的创建使用工厂模式：
- `IWorld::NewSprite()` - 创建世界精灵
- `IEngine::CreateEngineSprite()` - 创建非世界精灵（UI精灵等）
- `IEngine::CreateEffect()` - 创建界面特效
- `IWorld::PlayEffect()` - 播放世界特效

### 4.3 观察者模式 Observer Pattern

通知回调系统：
- `SpriteNotify` - 精灵帧通知
- `SpriteEventNotify` - 精灵事件通知
- `IEffectNotify` - 特效通知

### 4.4 策略模式 Strategy Pattern

渲染和更新策略：
- `NuclearCameraUpdateType` - 相机更新策略
- `NuclearSpriteTranslucentType` - 精灵半透明策略

## 5. 关键技术 Key Technologies

### 5.1 坐标系统 Coordinate System

引擎使用两套坐标系：

**世界坐标** - 实际地图上的像素坐标
- 用于渲染和显示
- 单位：像素

**逻辑坐标** - 可达图、服务器逻辑格子
- 用于寻路和游戏逻辑
- 单位：格子

**转换关系**：
```
世界坐标.x = 逻辑坐标.x * N
世界坐标.y = 逻辑坐标.y
```
其中 N ∈ [1, 2]

### 5.2 内存管理 Memory Management

#### 5.2.1 自定义分配器 Custom Allocator

使用NED Malloc作为默认内存分配器，提供：
- 更好的多线程性能
- 减少内存碎片
- 可配置的内存池

#### 5.2.2 资源GC机制 Resource GC

动画和特效资源的自动回收：
- `SetAniPicGCTime()` - 设置动画图片GC时间（默认20秒）
- `SetAniXapGCTime()` - 设置动画结构GC时间（默认20分钟）
- `GCNow()` - 立即执行GC

#### 5.2.3 内存监控 Memory Monitoring

实时内存监控：
- `GetCurMemSize()` - 获取当前进程使用内存
- `GeCurAvailableMemSize()` - 获取可用内存
- 基于FPS和内存的自动GC触发机制

### 5.3 异步加载 Asynchronous Loading

#### 5.3.1 文件IO异步

`FileIOManager`提供异步文件加载：
- 后台线程加载资源
- 主线程更新已加载资源
- 可配置每帧更新时间

#### 5.3.2 资源预取

精灵和特效支持资源预取：
- `ISprite::PrefetchAction()` - 预取动作资源
- `IEngine::HoldEffect()` - 持有特效资源

### 5.4 渲染优化 Rendering Optimization

#### 5.4.1 批量渲染 Batch Rendering

- `nuxapbatch` - XAP批量渲染
- 减少Draw Call
- 提升渲染性能

#### 5.4.2 视锥裁剪 Frustum Culling

- 只渲染视口内的对象
- 减少不必要的渲染

#### 5.4.3 层级排序 Layer Sorting

- 精灵按Y坐标排序
- 支持多层精灵系统
- 可配置排序频率

### 5.5 A*寻路 A* Pathfinding

#### 5.5.1 寻路算法

基于A*算法的路径查找：
- 支持8方向移动
- 支持障碍掩码
- 支持搜索范围限制

#### 5.5.2 平滑移动 Smooth Movement

- 支持路径平滑处理
- 可配置平滑限制
- 支持弧形移动

## 6. 性能优化 Performance Optimization

### 6.1 FPS控制 FPS Control

- 支持不同窗口状态下的FPS控制
- 默认：激活60FPS，后台60FPS，最小化30FPS
- 可动态调整

### 6.2 任务调度 Task Scheduling

- 用户任务在引擎线程执行
- 可配置每帧任务执行时间
- 支持定时器任务

### 6.3 资源缓存 Resource Caching

- 地表缓存
- 字体纹理缓存
- 特效资源缓存
- 可配置缓存策略

### 6.4 渲染优化 Rendering Optimization

- 使用RenderTarget优化特殊效果
- 精灵阴影优化
- 夜晚效果Shader优化
- 半透明效果优化

## 7. 平台适配 Platform Adaptation

### 7.1 iOS平台

- 使用Objective-C++封装
- 支持ARC（自动引用计数）
- 适配iOS生命周期

### 7.2 Android平台

- NDK编译
- Java层交互
- 适配Android生命周期

### 7.3 Windows Phone平台

- WinRT API
- 异步文件IO
- 触摸事件处理

## 8. 扩展性 Extensibility

### 8.1 Lua绑定 Lua Binding

通过tolua++提供Lua接口：
- 完整的引擎API暴露
- 支持热更新
- 配置文件位于`tolua++-pkgs/`

### 8.2 自定义渲染 Custom Rendering

- 支持自定义Shader
- 支持混合模式
- 支持顶点颜色

### 8.3 插件系统 Plugin System

- 特效插件
- 粒子插件
- 渲染插件

## 9. 安全性 Security

### 9.1 资源加密 Resource Encryption

- 支持资源包加密
- 文件路径混淆

### 9.2 异常处理 Exception Handling

- 完善的错误日志系统
- 异常捕获与恢复
- 资源加载失败处理

## 10. 总结 Summary

Nuclear Engine是一个功能完善、性能优秀的2D游戏引擎，具有以下特点：

1. **模块化设计** - 清晰的模块划分，易于维护和扩展
2. **跨平台支持** - 支持iOS、Android、Windows Phone三大移动平台
3. **高性能** - 优化的渲染和内存管理，支持大量精灵和特效
4. **完整的工具链** - 提供完整的游戏开发所需功能
5. **良好的扩展性** - 支持Lua绑定和自定义渲染

引擎适用于各类2D游戏开发，特别是RPG、ARPG、卡牌等类型的游戏。
